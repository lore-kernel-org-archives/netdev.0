From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/6] rhashtable: Move seed init into bucket_table_alloc
Date: Fri, 13 Mar 2015 20:57:12 +1100
Message-ID: <E1YWMLA-0000Bg-H9@gondolin.me.apana.org.au>
References: <20150313095607.GA598@gondor.apana.org.au>
To: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:47533 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979AbbCMJ5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 05:57:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems that I have already made every rehash redo the random
seed even though my commit message indicated otherwise :)

Since we have already taken that step, this patch goes one step
further and moves the seed initialisation into bucket_table_alloc.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 lib/rhashtable.c |   16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 5d06cc2..e55bbc8 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -142,7 +142,7 @@ static void bucket_table_free(const struct bucket_table *tbl)
 }
 
 static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
-					       size_t nbuckets, u32 hash_rnd)
+					       size_t nbuckets)
 {
 	struct bucket_table *tbl = NULL;
 	size_t size;
@@ -158,7 +158,6 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 
 	tbl->size = nbuckets;
 	tbl->shift = ilog2(nbuckets);
-	tbl->hash_rnd = hash_rnd;
 
 	if (alloc_bucket_locks(ht, tbl) < 0) {
 		bucket_table_free(tbl);
@@ -167,6 +166,8 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 
 	INIT_LIST_HEAD(&tbl->walkers);
 
+	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
+
 	for (i = 0; i < nbuckets; i++)
 		INIT_RHT_NULLS_HEAD(tbl->buckets[i], ht, i);
 
@@ -264,8 +265,6 @@ static void rhashtable_rehash(struct rhashtable *ht,
 	struct rhashtable_walker *walker;
 	unsigned old_hash;
 
-	get_random_bytes(&new_tbl->hash_rnd, sizeof(new_tbl->hash_rnd));
-
 	/* Make insertions go into the new, empty table right away. Deletions
 	 * and lookups will be attempted in both tables until we synchronize.
 	 * The synchronize_rcu() guarantees for the new table to be picked up
@@ -315,7 +314,7 @@ int rhashtable_expand(struct rhashtable *ht)
 
 	ASSERT_RHT_MUTEX(ht);
 
-	new_tbl = bucket_table_alloc(ht, old_tbl->size * 2, old_tbl->hash_rnd);
+	new_tbl = bucket_table_alloc(ht, old_tbl->size * 2);
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
@@ -346,7 +345,7 @@ int rhashtable_shrink(struct rhashtable *ht)
 
 	ASSERT_RHT_MUTEX(ht);
 
-	new_tbl = bucket_table_alloc(ht, old_tbl->size / 2, old_tbl->hash_rnd);
+	new_tbl = bucket_table_alloc(ht, old_tbl->size / 2);
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
@@ -926,7 +925,6 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 {
 	struct bucket_table *tbl;
 	size_t size;
-	u32 hash_rnd;
 
 	size = HASH_DEFAULT_SIZE;
 
@@ -952,9 +950,7 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	else
 		ht->p.locks_mul = BUCKET_LOCKS_PER_CPU;
 
-	get_random_bytes(&hash_rnd, sizeof(hash_rnd));
-
-	tbl = bucket_table_alloc(ht, size, hash_rnd);
+	tbl = bucket_table_alloc(ht, size);
 	if (tbl == NULL)
 		return -ENOMEM;
 
