From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] rhashtable: kill ht->shift atomic operations
Date: Thu, 12 Mar 2015 15:28:40 +0100
Message-ID: <04e26545f9d1b1fbd1297e5701ae72e12539091e.1426156183.git.daniel@iogearbox.net>
Cc: tgraf@suug.ch, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ying Xue <ying.xue@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36542 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788AbbCLO2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 10:28:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c0c09bfdc415 ("rhashtable: avoid unnecessary wakeup for worker
queue") changed ht->shift to be atomic, which is actually unnecessary.

Instead of leaving the current shift in the core rhashtable structure,
it can be cached inside the individual bucket tables.

There, it will only be initialized once during a new table allocation
in the shrink/expansion slow path, and from then onward it stays immutable
for the rest of the bucket table liftime.

That allows shift to be non-atomic. The patch also moves hash_rnd
management into the table setup. The rhashtable structure now consumes
3 instead of 4 cachelines.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Ying Xue <ying.xue@windriver.com>
---
 Applies to current net-next, but also on top of Herbert's cleanups.

 include/linux/rhashtable.h |  6 ++---
 lib/rhashtable.c           | 55 +++++++++++++++++++++-------------------------
 2 files changed, 28 insertions(+), 33 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 5ef8ea5..c93ff8a 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -50,6 +50,7 @@ struct rhash_head {
  * struct bucket_table - Table of hash buckets
  * @size: Number of hash buckets
  * @hash_rnd: Random seed to fold into hash
+ * @shift: Current size (1 << shift)
  * @locks_mask: Mask to apply before accessing locks[]
  * @locks: Array of spinlocks protecting individual buckets
  * @buckets: size * hash buckets
@@ -57,6 +58,7 @@ struct rhash_head {
 struct bucket_table {
 	size_t			size;
 	u32			hash_rnd;
+	u32			shift;
 	unsigned int		locks_mask;
 	spinlock_t		*locks;
 
@@ -99,7 +101,6 @@ struct rhashtable_params {
  * @tbl: Bucket table
  * @future_tbl: Table under construction during expansion/shrinking
  * @nelems: Number of elements in table
- * @shift: Current size (1 << shift)
  * @p: Configuration parameters
  * @run_work: Deferred worker to expand/shrink asynchronously
  * @mutex: Mutex to protect current/future table swapping
@@ -110,12 +111,11 @@ struct rhashtable {
 	struct bucket_table __rcu	*tbl;
 	struct bucket_table __rcu       *future_tbl;
 	atomic_t			nelems;
-	atomic_t			shift;
+	bool                            being_destroyed;
 	struct rhashtable_params	p;
 	struct work_struct		run_work;
 	struct mutex                    mutex;
 	struct list_head		walkers;
-	bool                            being_destroyed;
 };
 
 /**
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index d7f3db5..7a5ca92 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -156,7 +156,7 @@ static void bucket_table_free(const struct bucket_table *tbl)
 }
 
 static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
-					       size_t nbuckets)
+					       size_t nbuckets, u32 hash_rnd)
 {
 	struct bucket_table *tbl = NULL;
 	size_t size;
@@ -171,6 +171,8 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 		return NULL;
 
 	tbl->size = nbuckets;
+	tbl->shift = ilog2(nbuckets);
+	tbl->hash_rnd = hash_rnd;
 
 	if (alloc_bucket_locks(ht, tbl) < 0) {
 		bucket_table_free(tbl);
@@ -186,25 +188,27 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 /**
  * rht_grow_above_75 - returns true if nelems > 0.75 * table-size
  * @ht:		hash table
- * @new_size:	new table size
+ * @tbl:	current table
  */
-static bool rht_grow_above_75(const struct rhashtable *ht, size_t new_size)
+static bool rht_grow_above_75(const struct rhashtable *ht,
+			      const struct bucket_table *tbl)
 {
 	/* Expand table when exceeding 75% load */
-	return atomic_read(&ht->nelems) > (new_size / 4 * 3) &&
-	       (!ht->p.max_shift || atomic_read(&ht->shift) < ht->p.max_shift);
+	return atomic_read(&ht->nelems) > (tbl->size / 4 * 3) &&
+	       (!ht->p.max_shift || tbl->shift < ht->p.max_shift);
 }
 
 /**
  * rht_shrink_below_30 - returns true if nelems < 0.3 * table-size
  * @ht:		hash table
- * @new_size:	new table size
+ * @tbl:	current table
  */
-static bool rht_shrink_below_30(const struct rhashtable *ht, size_t new_size)
+static bool rht_shrink_below_30(const struct rhashtable *ht,
+				const struct bucket_table *tbl)
 {
 	/* Shrink table beneath 30% load */
-	return atomic_read(&ht->nelems) < (new_size * 3 / 10) &&
-	       (atomic_read(&ht->shift) > ht->p.min_shift);
+	return atomic_read(&ht->nelems) < (tbl->size * 3 / 10) &&
+	       tbl->shift > ht->p.min_shift;
 }
 
 static int rhashtable_rehash_one(struct rhashtable *ht, unsigned old_hash)
@@ -316,16 +320,11 @@ int rhashtable_expand(struct rhashtable *ht)
 
 	ASSERT_RHT_MUTEX(ht);
 
-	new_tbl = bucket_table_alloc(ht, old_tbl->size * 2);
+	new_tbl = bucket_table_alloc(ht, old_tbl->size * 2, old_tbl->hash_rnd);
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
-	new_tbl->hash_rnd = old_tbl->hash_rnd;
-
-	atomic_inc(&ht->shift);
-
 	rhashtable_rehash(ht, new_tbl);
-
 	return 0;
 }
 EXPORT_SYMBOL_GPL(rhashtable_expand);
@@ -348,20 +347,15 @@ EXPORT_SYMBOL_GPL(rhashtable_expand);
  */
 int rhashtable_shrink(struct rhashtable *ht)
 {
-	struct bucket_table *new_tbl, *tbl = rht_dereference(ht->tbl, ht);
+	struct bucket_table *new_tbl, *old_tbl = rht_dereference(ht->tbl, ht);
 
 	ASSERT_RHT_MUTEX(ht);
 
-	new_tbl = bucket_table_alloc(ht, tbl->size / 2);
+	new_tbl = bucket_table_alloc(ht, old_tbl->size / 2, old_tbl->hash_rnd);
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
-	new_tbl->hash_rnd = tbl->hash_rnd;
-
-	atomic_dec(&ht->shift);
-
 	rhashtable_rehash(ht, new_tbl);
-
 	return 0;
 }
 EXPORT_SYMBOL_GPL(rhashtable_shrink);
@@ -382,9 +376,9 @@ static void rht_deferred_worker(struct work_struct *work)
 	list_for_each_entry(walker, &ht->walkers, list)
 		walker->resize = true;
 
-	if (rht_grow_above_75(ht, tbl->size))
+	if (rht_grow_above_75(ht, tbl))
 		rhashtable_expand(ht);
-	else if (rht_shrink_below_30(ht, tbl->size))
+	else if (rht_shrink_below_30(ht, tbl))
 		rhashtable_shrink(ht);
 unlock:
 	mutex_unlock(&ht->mutex);
@@ -438,7 +432,7 @@ static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 	rcu_assign_pointer(tbl->buckets[hash], obj);
 
 	atomic_inc(&ht->nelems);
-	if (no_resize_running && rht_grow_above_75(ht, tbl->size))
+	if (no_resize_running && rht_grow_above_75(ht, tbl))
 		schedule_work(&ht->run_work);
 
 exit:
@@ -547,7 +541,7 @@ bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
 		bool no_resize_running = tbl == old_tbl;
 
 		atomic_dec(&ht->nelems);
-		if (no_resize_running && rht_shrink_below_30(ht, tbl->size))
+		if (no_resize_running && rht_shrink_below_30(ht, tbl))
 			schedule_work(&ht->run_work);
 	}
 
@@ -918,6 +912,7 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 {
 	struct bucket_table *tbl;
 	size_t size;
+	u32 hash_rnd;
 
 	size = HASH_DEFAULT_SIZE;
 
@@ -944,14 +939,14 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	else
 		ht->p.locks_mul = BUCKET_LOCKS_PER_CPU;
 
-	tbl = bucket_table_alloc(ht, size);
+	get_random_bytes(&hash_rnd, sizeof(hash_rnd));
+
+	tbl = bucket_table_alloc(ht, size, hash_rnd);
 	if (tbl == NULL)
 		return -ENOMEM;
 
-	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
-
 	atomic_set(&ht->nelems, 0);
-	atomic_set(&ht->shift, ilog2(tbl->size));
+
 	RCU_INIT_POINTER(ht->tbl, tbl);
 	RCU_INIT_POINTER(ht->future_tbl, tbl);
 
-- 
1.9.3
