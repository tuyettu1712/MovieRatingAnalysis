USE imdb;

-- ==========================================================================================
-- 1.0 VIEW DEFINITIONS
/* This block to organize all view creations to reuse through out the code*/
-- ==========================================================================================
-- 1.1 MOVIE GENRE SUMMARY
-- Create view for combined data of movie and genre table
-- ------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS movie_genre;

CREATE VIEW movie_genre AS
SELECT m.id,
       m.title,
       m.year,
       m.date_published,
       m.duration,
       m.country,
       m.worlwide_gross_income,
       m.languages,
       m.production_company,
       g.genre
FROM movie m
INNER JOIN genre g ON m.id = g.movie_id;

-- 1.2 MOVIE RATING SUMMARY
-- Create view for combined data of movie and rating table
-- ------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS movie_ratings;

CREATE VIEW movie_ratings AS
SELECT m.id,
       m.title,
       m.year,
       m.date_published,
       m.duration,
       m.country,
       m.worlwide_gross_income,
       m.languages,
       m.production_company,
       r.avg_rating,
       r.total_votes,
       r.median_rating
FROM movie m
INNER JOIN ratings r ON m.id = r.movie_id;

-- 1.3 MOVIE GENRE RATINGS SUMMARY
-- Create view for combined data of movie, genre, ratings table
-- ------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS movie_genre_ratings;

CREATE VIEW movie_genre_ratings AS
SELECT mr.id,
       mr.title,
       mr.duration,
       mr.avg_rating,
       mr.total_votes,
       mr.median_rating,
       mr.date_published,
       mr.year,
       mr.country,
       g.genre
FROM movie_ratings mr
INNER JOIN genre g ON mr.id = g.movie_id;

-- 1.4 MOVIE GENRE RATINGS DIRECTOR SUMMARY
-- Create view of combined data of movie, genre, rating and director table
-- ------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS movie_genre_ratings_director;

CREATE VIEW movie_genre_ratings_director AS
SELECT m.id,
       m.genre,
       m.title,
       m.avg_rating,
       m.duration,
       m.total_votes,
       m.date_published,
       d.name_id,
       n.name
FROM movie_genre_ratings m
INNER JOIN director_mapping d ON m.id = d.movie_id
INNER JOIN NAMES n ON d.name_id = n.id;

-- 1.5 MOVIE RATINGS ROLE SUMMARY
-- reate view of combined data of movie,ratings and role table
-- ------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS movie_ratings_role;

CREATE VIEW movie_ratings_role AS
SELECT mr.id,
       mr.title,
       mr.total_votes,
       mr.avg_rating,
       mr.country,
       mr.languages,
       mr.median_rating,
       r.category,
       n.name
FROM movie_ratings mr
INNER JOIN role_mapping r ON mr.id = r.movie_id
INNER JOIN NAMES n ON r.name_id = n.id;

-- 1.6 MOVIE RATINGS DIRECTOR SUMMARY
-- Create view of combined data of movie,ratings and director table
-- ------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS movie_ratings_director;

CREATE VIEW movie_ratings_director AS
SELECT m.id AS movie_id,
       d.name_id AS director_id,
       m.date_published,
       m.duration,
       r.avg_rating,
       r.total_votes,
       n.name AS director_name
FROM movie m
INNER JOIN director_mapping d ON m.id = d.movie_id
INNER JOIN NAMES n ON d.name_id = n.id
INNER JOIN ratings r ON m.id = r.movie_id;
        
-- ==========================================================================================
-- 2.0 DATA ANALYSIS
-- ==========================================================================================   

/********************************************************************************************
 * @segment 1: Data Preparation
 * @description: Clean and prepare raw data & basic exploration
 ********************************************************************************************/     

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/
-- Segment 1:
-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q1. Number of rows in each table of the scheme
/*Findings: there are 6 tables available in the database*/
-- -------------------------------------------------------------------------------------------
SELECT TABLE_NAME,
       table_rows
FROM information_schema.tables
WHERE 	table_schema = 'imdb'
		AND table_type = 'BASE TABLE'
ORDER BY table_rows DESC;



 
-- Q2. Which columns in the movie table have null values?
-- Type your code below:
-- -------------------------------------------------------------------------------------------
-- Q2. Number of rows in each table of the scheme
/*Findings: Using DESCRIBE, we can see that movie has id as  NON-NULL PK key and others may 
have NULL values.
There are 9 columns and 4 has NULL values: country,gross income, languages,production company*/
-- -------------------------------------------------------------------------------------------
DESCRIBE movie;

SELECT sum(title IS NULL) AS title_null,
       sum(YEAR IS NULL) AS year_null_count,
       sum(date_published IS NULL) AS dp_null,
       sum(duration IS NULL) AS duration_null,
       sum(country IS NULL) AS country_null,
       sum(worlwide_gross_income IS NULL) AS income_null,
       sum(languages IS NULL) AS languages_null,
       sum(production_company IS NULL) AS pc_null
FROM movie;




-- Check the column information of the movie table     
-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)
/* Output format for the first part:
+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+

Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- -------------------------------------------------------------------------------------------
-- Q3. Total number of movies released year-wise and month-wise
/*Findings: we see a declining over years. Trend was fluctuating month by month and march being 
the month which have the highesth movie releases.
If we look into each year, 2019 has a significant reduction at year end, probably due to Covid*/
-- -------------------------------------------------------------------------------------------
-- #The total number of movies released each year
SELECT YEAR,
       count(id) AS number_of_movies
FROM movie
GROUP BY YEAR
ORDER BY YEAR;

-- #The total number of movies released each month in 3 years
SELECT month(date_published) AS month_num,
       count(id) AS number_of_movies
FROM movie
GROUP BY month_num
ORDER BY month_num;

-- #The total number of movies released each month in 2017
SELECT month(date_published) AS month_num,
       count(id) AS number_of_movies
FROM movie
WHERE YEAR='2017'
GROUP BY month_num
ORDER BY month_num;

-- #The total number of movies released each month in 2018
SELECT month(date_published) AS month_num,
       count(id) AS number_of_movies
FROM movie
WHERE YEAR='2018'
GROUP BY month_num
ORDER BY month_num;

-- #The total number of movies released each month in 2019
SELECT month(date_published) AS month_num,
       count(id) AS number_of_movies
FROM movie
WHERE YEAR='2019'
GROUP BY month_num
ORDER BY month_num;




/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:
-- -------------------------------------------------------------------------------------------
-- Q4. Movies produced in USA and India in 2019
/*Findings: Movies released in USA doubled that in India with a total of 2 countries 
about a thousand movies in 2019*/
-- -------------------------------------------------------------------------------------------
SELECT CASE
           WHEN upper(country) LIKE '%INDIA%' THEN 'India'
           WHEN upper(country) LIKE '%USA%' THEN 'USA'
       END AS country_name,
       count(id) AS movie_count
FROM movie
WHERE 	(upper(country) LIKE '%INDIA%'
		OR upper(country) LIKE '%USA%')
		AND YEAR = 2019
GROUP BY CASE
             WHEN upper(country) LIKE '%INDIA%' THEN 'India'
             WHEN upper(country) LIKE '%USA%' THEN 'USA'
         END
ORDER BY movie_count DESC;




/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/
-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q5. Unique list of genres
/*Findings: there are 13 different genres available */
-- -------------------------------------------------------------------------------------------
-- # Names of unique genres
SELECT DISTINCT genre AS unique_genre
FROM genre;

-- # The number of unique genres
SELECT count(DISTINCT genre) AS count_genre
FROM genre;




/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */
-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q6. Genre with highest number of movies produced
/*Findings: Drama was with highest number of movies with 4285 total movies overall and 
it kept the first position in 2019 too with 1078 movies */
-- -------------------------------------------------------------------------------------------
-- # Finding the highest number of movies produced by genre in overall
SELECT genre,
       count(id) AS number_produced_movie
FROM movie_genre
GROUP BY genre
ORDER BY number_produced_movie DESC;

-- # Finding the highest number of movies produced by genre in 2019
SELECT genre,
       count(id) AS number_produced_movie
FROM movie_genre
WHERE YEAR = '2019'
GROUP BY genre
ORDER BY number_produced_movie DESC;




/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/
-- Q7. How many movies belong to only one genre?
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q7. Movies with only one genre
/*Findings: there 3245 movies has only one genre associated with them */
-- -------------------------------------------------------------------------------------------
WITH one_genre_list AS
  (SELECT title,
          count(genre)
   FROM movie_genre
   GROUP BY title
   HAVING count(genre)=1)
SELECT count(title) AS movie_with_one_genre
FROM one_genre_list;




/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/
-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)
/* Output format:
+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q8. Average duration of movies in each genre
/*Findings: Action has the highest average duration amongst all the genres */
-- -------------------------------------------------------------------------------------------
SELECT genre,
       round(avg(duration), 2) AS avg_duration
FROM movie_genre
GROUP BY genre
ORDER BY avg_duration DESC;




/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/
-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)
/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q9. Rank of the ‘thriller’ genre of movies by number of movies produced
/*Findings: thriller is at 3rd rank with 1484 movies */
-- -------------------------------------------------------------------------------------------
WITH genre_rank AS
  (SELECT genre,
          count(id) AS movie_count,
          RANK() OVER(ORDER BY count(id) DESC) AS genre_rank
   FROM movie_genre
   GROUP BY genre)
SELECT *
FROM genre_rank
WHERE genre = 'Thriller';





/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/
-- Segment 2:
-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q10. Min and max values of columns in movie-rating data
/*Findings: rating range is from 1-10 and number of votes range is 100 to around 730k votes*/
-- -------------------------------------------------------------------------------------------
SELECT min(avg_rating) AS min_avg_rating,
       max(avg_rating) AS max_avg_rating,
       min(total_votes) AS min_total_votes,
       max(total_votes) AS max_total_votes,
       min(median_rating) AS min_median_rating,
       max(median_rating) AS max_median_rating
FROM ratings;




/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/
-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q11. Top 10 movies based on average rating
/*Findings: Kirket and Love in Kilnerry both ranked first and many tied at the 10th places  */
-- -------------------------------------------------------------------------------------------
SELECT title,
       avg_rating,
       movie_rank
FROM
  (SELECT title,
          avg_rating,
          RANK() OVER(ORDER BY avg_rating DESC) AS movie_rank
   FROM movie_ratings) ranked
WHERE movie_rank <=10;





/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/
-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have


-- -------------------------------------------------------------------------------------------
-- Q12. Movie counts by median ratings
/*Findings: Most of movies have media rating of 7  */
-- -------------------------------------------------------------------------------------------
SELECT median_rating,
       count(id) AS movie_count
FROM movie_ratings
GROUP BY median_rating
ORDER BY movie_count DESC;



/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/
-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q13. Production house with the most number of hit movies (average rating > 8)
/*Findings: Both Dream Warrior Pictures and National Theatre Live has most of the hit movies */
-- -------------------------------------------------------------------------------------------
WITH ranked_prod_company AS
  (SELECT production_company,
          count(id) AS movie_count,
          RANK() OVER(ORDER BY count(id) DESC) AS prod_company_rank
   FROM movie_ratings
   WHERE 	avg_rating > 8
			AND production_company IS NOT NULL
			AND production_company != ''
   GROUP BY production_company)
SELECT production_company,
       movie_count,
       prod_company_rank
FROM ranked_prod_company
WHERE prod_company_rank=1;




-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both
-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:
+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q14. Number of movies in each genre during March 2017 in the USA had more than 1,000 votes
/*Findings: Drama is the top genre with 24 movies */
-- -------------------------------------------------------------------------------------------
SELECT genre,
       count(id) AS movie_count
FROM movie_genre_ratings
WHERE 	month(date_published) = 3
		AND year(date_published) = 2017
		AND total_votes > 1000
		AND upper(country) LIKE '%USA%'
GROUP BY genre
ORDER BY movie_count DESC;




-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- -------------------------------------------------------------------------------------------
-- Q15. Movies of each genre that start with the word ‘The’ and an average rating > 8
/*Findings:The brighton miracle is top with 9.5 rating with genre as Drama */
-- -------------------------------------------------------------------------------------------
SELECT title,
       avg_rating,
       genre
FROM movie_genre_ratings
WHERE 	upper(title) LIKE 'THE%'
		AND avg_rating > 8
ORDER BY genre;




-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q16. Movies given a median rating of 8 released between 1 April 2018 and 1 April 2019
/*Findings: there are 361 movies with median rating of 8 within this period  */
-- -------------------------------------------------------------------------------------------
SELECT count(id) AS movie_count
FROM movie_ratings
WHERE 	median_rating = 8
		AND date_published BETWEEN '2018-04-01' AND '2019-04-01';




-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q17. German movies compared to Italian movies in term of votes
/*Findings: German movies has higher votes with nearly 1.7 times more than Italian movies   */
-- -------------------------------------------------------------------------------------------
WITH language_listing AS
		  (SELECT 'German' AS languages,
				  total_votes
		   FROM movie_ratings
		   WHERE upper(languages) LIKE '%GERMAN%'
		   UNION ALL 
		   SELECT 'Italian' AS languages,
							total_votes
		   FROM movie_ratings
		   WHERE upper(languages) LIKE '%ITALIAN%'),
	total_sum AS
		  (SELECT sum(total_votes) AS total_all_votes
		   FROM language_listing)
SELECT languages AS language_name,
       sum(total_votes) AS total_votes,
       round(sum(total_votes) * 100.0/total_all_votes, 2) AS vote_percentage
FROM language_listing,
     total_sum
GROUP BY languages,
         total_all_votes
ORDER BY total_votes DESC;





/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/
-- Segment 3:
-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q18. Null values of names table
/*Findings: all columns has NULL values, except the "name" column */
-- -------------------------------------------------------------------------------------------
SELECT sum(name IS NULL) AS name_nulls,
       sum(height IS NULL) AS height_nulls,
       sum(date_of_birth IS NULL) AS date_of_birth_nulls,
       sum(known_for_movies IS NULL) AS known_for_movies_nulls
FROM NAMES;






/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/
-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q19. top three genres with the most number of movies with an average rating > 8
/*Findings: With genre-duplicated counting, James Mangold topped with 4 movies, followed by 
Joe Russo & Anthony Russo. If counting without duplication, the top 3 directors have the same
movie numbers with an average rating > 8 of the top 3 genres  */
-- -------------------------------------------------------------------------------------------
WITH top_three_genre AS
  (SELECT genre,
          count(id) AS movie_count
   FROM movie_genre_ratings
   WHERE avg_rating > 8
   GROUP BY genre
   ORDER BY movie_count DESC
   LIMIT 3)
SELECT name AS director_name,
       count(DISTINCT id) AS movie_count
FROM movie_genre_ratings_director
WHERE genre IN
		(SELECT genre
		 FROM top_three_genre)
	AND avg_rating > 8
GROUP BY director_name
ORDER BY movie_count DESC
LIMIT 3;




/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:
+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q20. top two actors whose movies have a median rating >= 8
/*Findings: Mammootty ranked first with 8 movies, followed by Mohanlal with 5 movies  */
-- -------------------------------------------------------------------------------------------
-- Step 1: Ranking actors with a filter (median rating >=8 )- Step 2: get top 2
WITH actor_ranking AS
  (SELECT name AS actor_name,
          count(id) AS movie_count,
          RANK() OVER(ORDER BY count(id) DESC) AS actor_rank
   FROM movie_ratings_role
   WHERE median_rating >= 8
     AND category = 'actor'
   GROUP BY actor_name)
SELECT actor_name,
       movie_count
FROM actor_ranking
WHERE actor_rank <=2;


/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/
-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q21. top three production houses based on the number of votes received by their movies
/*Findings: Marvel Studios ranked first with around 2,6m votes  */
-- -------------------------------------------------------------------------------------------
WITH prod_company_ranking AS
  (SELECT production_company,
          sum(total_votes) AS vote_count,
          RANK() OVER(ORDER BY sum(total_votes) DESC) AS prod_company_rank
   FROM movie_ratings
   GROUP BY production_company)
SELECT production_company,
       vote_count,
       prod_company_rank
FROM prod_company_ranking
WHERE prod_company_rank <= 3;



/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.
Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/
-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q22. the top actor with movies released in India based on their average ratings
/*Findings: Top actor is Vijay Sethupathiwith with more than 23k votes and acted in 5 movies */
-- -------------------------------------------------------------------------------------------
SELECT name AS actor_name,
       sum(total_votes) AS total_votes,
       count(id) AS movie_count,
       round(sum(avg_rating * total_votes) / sum(total_votes), 2) AS actor_avg_rating,
       RANK() OVER(ORDER BY round(sum(avg_rating * total_votes) / sum(total_votes), 2) DESC, sum(total_votes) DESC) AS actor_rank
FROM movie_ratings_role
WHERE category = "actor"
  AND upper(country) LIKE "%INDIA%"
GROUP BY actor_name
HAVING movie_count >= 5;





-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q23. the top five actresses in Hindi movies released in India based on their average ratings
/*Findings: Taapsee Pannu is ranked first based on weighted rating with votes. All top 5
actress equally acted in 5 movies, and Taapsee Pannu has the lowest number of votes. It shows
that her avg_rating is dominantly higher than others, proving her acting quality */
-- -------------------------------------------------------------------------------------------
WITH actress_ranking AS
  (SELECT name AS actress_name,
          sum(total_votes) AS total_votes,
          count(id) AS movie_count,
          round(sum(avg_rating * total_votes) / sum(total_votes), 2) AS actress_avg_rating,
          RANK() OVER(ORDER BY round((sum(avg_rating * total_votes) / sum(total_votes)),2) DESC, sum(total_votes) DESC) AS actress_rank
   FROM movie_ratings_role
   WHERE category = "actress"
		AND upper(country) LIKE "%INDIA%"
		AND upper(languages) LIKE "%HINDI%"
   GROUP BY actress_name
   HAVING movie_count >= 3)
SELECT *
FROM actress_ranking
WHERE actress_rank <= 5
ORDER BY actress_rank;




/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/
/* Q24. Consider thriller movies having at least 25,000 votes. Classify them according to their average ratings in
   the following categories:  
			Rating > 8: Superhit
			Rating between 7 and 8: Hit
			Rating between 5 and 7: One-time-watch
			Rating < 5: Flop
    Note: Sort the output by average ratings (desc).
--------------------------------------------------------------------------------------------*/
/* Output format:
+---------------+-------------------+
| movie_name	|	movie_category	|
+---------------+-------------------+
|	Get Out		|			Hit		|
|		.		|			.		|
|		.		|			.		|
+---------------+-------------------+*/

-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q24. Classifying the thriller movies having at least 25,000 votes
-- -------------------------------------------------------------------------------------------
SELECT title AS movie_name,
       CASE
           WHEN avg_rating > 8 THEN 'Superhit'
           WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit'
           WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch'
           ELSE 'Flop'
       END AS movie_category
FROM movie_genre_ratings
WHERE 	genre = 'Thriller'
		AND total_votes >= 25000
ORDER BY avg_rating DESC;





/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/
-- Segment 4:
-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q25. The genre-wise running total and moving average of the average movie duration
/* Findings: Action movies has longest average duration 112minutes while horror movies has
shortest avg duration. Most of genres between 100-110 minutes. 
Steady running total shows that a balanced distribution of duration. Meanwhile the moving avg 
pattern indicates a consitency in movie duration genre-wise. Drama genre, which we should focus on
fall into the middle-range mainstream group.*/
-- -------------------------------------------------------------------------------------------
WITH genre_duration AS
  (SELECT genre,
          avg(duration) AS avg_duration
   FROM movie_genre
   GROUP BY genre)
SELECT genre,
       round(avg_duration, 2) AS avg_duration,
       round(sum(avg_duration) OVER (ORDER BY genre), 2) AS running_total_duration,
       round(avg(avg_duration) OVER (ORDER BY genre ROWS UNBOUNDED PRECEDING), 2) AS moving_avg_duration
FROM genre_duration
ORDER BY genre;




-- Round is good to have and not a must have; Same thing applies to sorting
-- Let us find top 5 movies of each year with top 3 genres.
-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q26. The five highest-grossing movies of each year that belong to the top three genres
/* Findings: Avengers: Endgame and The Lion King are tops 2 movies with highest income overall,
They are both drama in 2019 */
-- -------------------------------------------------------------------------------------------
WITH movie_genre_update AS
  (SELECT DISTINCT id,
                   title,
                   YEAR,
                   genre,
                   CASE
                       WHEN upper(worlwide_gross_income) LIKE '%INR%' THEN floor(cast(trim(replace(worlwide_gross_income, 'INR', '')) AS DECIMAL))
                       WHEN upper(worlwide_gross_income) LIKE '%$%' THEN floor(cast(trim(replace(worlwide_gross_income, '$', '')) AS DECIMAL))
                   END AS income_updated
   FROM movie_genre),
		genre_ranking AS
  (SELECT genre,
          RANK() OVER(ORDER BY count(id) DESC) AS genre_rank
   FROM movie_genre
   GROUP BY genre),
		movie_ranking AS
  (SELECT genre,
          YEAR,
          title AS movie_name,
          income_updated AS worlwide_gross_income,
          RANK() OVER(PARTITION BY genre, YEAR
                      ORDER BY income_updated DESC) AS movie_rank
   FROM movie_genre_update
   WHERE genre IN
       (SELECT genre
        FROM genre_ranking
        WHERE genre_rank<=3)
     AND income_updated IS NOT NULL)
SELECT genre,
       YEAR,
       movie_name,
       worlwide_gross_income,
       movie_rank
FROM movie_ranking
WHERE movie_rank <= 5
ORDER BY genre,
         YEAR,
         movie_rank;





-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

-- -------------------------------------------------------------------------------------------
-- Q27. the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies
/*  Star Cinema is the top produciton house with 7 movies, followed by Twentieth Century Fox */
-- -------------------------------------------------------------------------------------------
WITH top_production_houses AS
  (SELECT production_company,
          count(id) AS movie_count,
          rank() OVER (ORDER BY count(id) DESC) AS prod_comp_rank
   FROM movie_ratings
   WHERE median_rating >= 8
     AND position(',' IN languages) > 0 -- Movies with multiple languages
     AND production_company IS NOT NULL
   GROUP BY production_company)
SELECT production_company,
       movie_count,
       prod_comp_rank
FROM top_production_houses
WHERE prod_comp_rank <= 2
ORDER BY prod_comp_rank;






-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language

-- Q28. Who are the top 3 actresses based on the number of Super Hit movies (Superhit movie: average rating of movie > 8) in 'drama' genre?
-- Note: Consider only superhit movies to calculate the actress average ratings.
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes
-- should act as the tie breaker. If number of votes are same, sort alphabetically by actress name.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	  actress_avg_rating |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.6000		     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

-- Type your code below:
-- -------------------------------------------------------------------------------------------
-- Q28. the top 3 actresses based on the number of Super Hit movies (Superhit movie: average rating of movie > 8) in 'drama' genre
/* For super hit drama, Sangeetha Bhat is ranked first based on the weighted avg rating even though her total votes is not high  */
-- -------------------------------------------------------------------------------------------
WITH superhit_movies AS
-- Step 1: Find actress in superhit movies with average rating > 8 in the 'drama' genre
(SELECT id,
        name AS actress_name,
        avg_rating,
        total_votes,
        avg_rating * total_votes AS weighted_rating
   FROM movie_ratings_role m
   INNER JOIN genre g ON m.id = g.movie_id
   WHERE genre = 'drama' -- Filter for drama genre
     AND avg_rating > 8 -- Only consider superhit movies
     AND category = 'actress') -- Filter to only include actresses 
-- Step 2: Calculate total votes, count of movies, and weighted average for each actress
SELECT actress_name,
       sum(total_votes) AS total_votes,
       count(id) AS movie_count,
       round(sum(weighted_rating) / sum(total_votes), 2) AS actress_avg_rating,
       RANK() OVER (ORDER BY sum(weighted_rating) / sum(total_votes) DESC, sum(total_votes) DESC, actress_name) AS actress_rank
FROM superhit_movies
GROUP BY actress_name
ORDER BY actress_rank
LIMIT 3; -- Get the top 3 actresses





/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

-- -------------------------------------------------------------------------------------------
-- Q29. Details of top 9 directors
/* All directors shown have 4-5 movies, with Andrew Jones having the most (5 movies). Times between
movies ranges from 112 to 331 days. */
-- -------------------------------------------------------------------------------------------
WITH next_date_published_summary AS
  (SELECT 	movie_id,
			director_id,
			director_name,
			duration,
			avg_rating,
			total_votes,
			date_published,
			LEAD(date_published, 1) OVER(PARTITION BY director_id ORDER BY date_published) AS next_date_published
   FROM movie_ratings_director),
     top_director_summary AS
  (SELECT *,
          datediff(next_date_published, date_published) AS date_difference
   FROM next_date_published_summary)
SELECT director_id,
       director_name,
       count(movie_id) AS number_of_movies,
       round(AVG(date_difference), 2) AS avg_inter_movie_days,
       round(AVG(avg_rating), 2) AS avg_rating,
       sum(total_votes) AS total_votes,
       min(avg_rating) AS min_rating,
       max(avg_rating) AS max_rating,
       sum(duration) AS total_duration
FROM top_director_summary
GROUP BY director_id,
         director_name
ORDER BY number_of_movies DESC
LIMIT 9;
