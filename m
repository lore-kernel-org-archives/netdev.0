From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 6/6] rhashtable: Move future_tbl into struct bucket_table
Date: Sat, 14 Mar 2015 13:57:25 +1100
Message-ID: <E1YWcGT-0002ol-Ue@gondolin.me.apana.org.au>
References: <20150314025339.GA10585@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:50579 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596AbbCNC5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 22:57:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves future_tbl to open up the possibility of having
multiple rehashes on the same table.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |    5 +++--
 lib/rhashtable.c           |   27 +++++++++++----------------
 2 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index ed7562a..1695378 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -56,6 +56,7 @@ struct rhash_head {
  * @locks: Array of spinlocks protecting individual buckets
  * @walkers: List of active walkers
  * @rcu: RCU structure for freeing the table
+ * @future_tbl: Table under construction during rehashing
  * @buckets: size * hash buckets
  */
 struct bucket_table {
@@ -68,6 +69,8 @@ struct bucket_table {
 	struct list_head	walkers;
 	struct rcu_head		rcu;
 
+	struct bucket_table __rcu *future_tbl;
+
 	struct rhash_head __rcu	*buckets[] ____cacheline_aligned_in_smp;
 };
 
@@ -105,7 +108,6 @@ struct rhashtable_params {
 /**
  * struct rhashtable - Hash table handle
  * @tbl: Bucket table
- * @future_tbl: Table under construction during expansion/shrinking
  * @nelems: Number of elements in table
  * @p: Configuration parameters
  * @run_work: Deferred worker to expand/shrink asynchronously
@@ -114,7 +116,6 @@ struct rhashtable_params {
  */
 struct rhashtable {
 	struct bucket_table __rcu	*tbl;
-	struct bucket_table __rcu       *future_tbl;
 	atomic_t			nelems;
 	bool                            being_destroyed;
 	struct rhashtable_params	p;
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index ff4ea17..9d53a46 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -207,8 +207,9 @@ static bool rht_shrink_below_30(const struct rhashtable *ht,
 
 static int rhashtable_rehash_one(struct rhashtable *ht, unsigned old_hash)
 {
-	struct bucket_table *new_tbl = rht_dereference(ht->future_tbl, ht);
 	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
+	struct bucket_table *new_tbl =
+		rht_dereference(old_tbl->future_tbl, ht) ?: old_tbl;
 	struct rhash_head __rcu **pprev = &old_tbl->buckets[old_hash];
 	int err = -ENOENT;
 	struct rhash_head *head, *next, *entry;
@@ -273,10 +274,8 @@ static void rhashtable_rehash(struct rhashtable *ht,
 
 	/* Make insertions go into the new, empty table right away. Deletions
 	 * and lookups will be attempted in both tables until we synchronize.
-	 * The synchronize_rcu() guarantees for the new table to be picked up
-	 * so no new additions go into the old table while we relink.
 	 */
-	rcu_assign_pointer(ht->future_tbl, new_tbl);
+	rcu_assign_pointer(old_tbl->future_tbl, new_tbl);
 
 	/* Ensure the new table is visible to readers. */
 	smp_wmb();
@@ -400,7 +399,7 @@ static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 	 * also grab the bucket lock in old_tbl because until the
 	 * rehash completes ht->tbl won't be changed.
 	 */
-	tbl = rht_dereference_rcu(ht->future_tbl, ht);
+	tbl = rht_dereference_rcu(old_tbl->future_tbl, ht) ?: old_tbl;
 	if (tbl != old_tbl) {
 		hash = head_hashfn(ht, tbl, obj);
 		spin_lock_nested(bucket_lock(tbl, hash), SINGLE_DEPTH_NESTING);
@@ -525,7 +524,7 @@ bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
 	 * visible then that guarantees the entry to still be in
 	 * old_tbl if it exists.
 	 */
-	tbl = rht_dereference_rcu(ht->future_tbl, ht);
+	tbl = rht_dereference_rcu(old_tbl->future_tbl, ht) ?: old_tbl;
 	if (!ret && old_tbl != tbl)
 		ret = __rhashtable_remove(ht, tbl, obj);
 
@@ -599,7 +598,7 @@ EXPORT_SYMBOL_GPL(rhashtable_lookup);
 void *rhashtable_lookup_compare(struct rhashtable *ht, const void *key,
 				bool (*compare)(void *, void *), void *arg)
 {
-	const struct bucket_table *tbl, *old_tbl;
+	const struct bucket_table *tbl;
 	struct rhash_head *he;
 	u32 hash;
 
@@ -618,9 +617,8 @@ restart:
 	/* Ensure we see any new tables. */
 	smp_rmb();
 
-	old_tbl = tbl;
-	tbl = rht_dereference_rcu(ht->future_tbl, ht);
-	if (unlikely(tbl != old_tbl))
+	tbl = rht_dereference_rcu(tbl->future_tbl, ht);
+	if (unlikely(tbl))
 		goto restart;
 	rcu_read_unlock();
 
@@ -830,14 +828,13 @@ next:
 		iter->skip = 0;
 	}
 
-	iter->walker->tbl = rht_dereference_rcu(ht->future_tbl, ht);
-	if (iter->walker->tbl != tbl) {
+	iter->walker->tbl = rht_dereference_rcu(tbl->future_tbl, ht);
+	if (iter->walker->tbl) {
 		iter->slot = 0;
 		iter->skip = 0;
 		return ERR_PTR(-EAGAIN);
 	}
 
-	iter->walker->tbl = NULL;
 	iter->p = NULL;
 
 out:
@@ -865,8 +862,7 @@ void rhashtable_walk_stop(struct rhashtable_iter *iter)
 	ht = iter->ht;
 
 	mutex_lock(&ht->mutex);
-	if (rht_dereference(ht->tbl, ht) == tbl ||
-	    rht_dereference(ht->future_tbl, ht) == tbl)
+	if (tbl->rehash < tbl->size)
 		list_add(&iter->walker->list, &tbl->walkers);
 	else
 		iter->walker->tbl = NULL;
@@ -961,7 +957,6 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	atomic_set(&ht->nelems, 0);
 
 	RCU_INIT_POINTER(ht->tbl, tbl);
-	RCU_INIT_POINTER(ht->future_tbl, tbl);
 
 	INIT_WORK(&ht->run_work, rht_deferred_worker);
 
