From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/6] rhashtable: Fix walker behaviour during rehash
Date: Fri, 13 Mar 2015 20:57:10 +1100
Message-ID: <E1YWML8-0000B6-62@gondolin.me.apana.org.au>
References: <20150313095607.GA598@gondor.apana.org.au>
To: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:55321 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100AbbCMJ5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 05:57:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously whenever the walker encountered a resize it simply
snaps back to the beginning and starts again.  However, this only
works if the rehash started and completed while the walker was
idle.

If the walker attempts to restart while the rehash is still ongoing,
we may miss objects that we shouldn't have.

This patch fixes this by making the walker walk the old table
followed by the new table just like all other readers.  If a
rehash is detected we will still signal our caller of the fact
so they can prepare for duplicates but we will simply continue
the walk onto the new table after the old one is finished either
by us or by the rehasher.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |    8 ++---
 lib/rhashtable.c           |   69 ++++++++++++++++++++++++++++++---------------
 2 files changed, 50 insertions(+), 27 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index c93ff8a..4192682 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -53,6 +53,7 @@ struct rhash_head {
  * @shift: Current size (1 << shift)
  * @locks_mask: Mask to apply before accessing locks[]
  * @locks: Array of spinlocks protecting individual buckets
+ * @walkers: List of active walkers
  * @buckets: size * hash buckets
  */
 struct bucket_table {
@@ -61,6 +62,7 @@ struct bucket_table {
 	u32			shift;
 	unsigned int		locks_mask;
 	spinlock_t		*locks;
+	struct list_head	walkers;
 
 	struct rhash_head __rcu	*buckets[] ____cacheline_aligned_in_smp;
 };
@@ -104,7 +106,6 @@ struct rhashtable_params {
  * @p: Configuration parameters
  * @run_work: Deferred worker to expand/shrink asynchronously
  * @mutex: Mutex to protect current/future table swapping
- * @walkers: List of active walkers
  * @being_destroyed: True if table is set up for destruction
  */
 struct rhashtable {
@@ -115,17 +116,16 @@ struct rhashtable {
 	struct rhashtable_params	p;
 	struct work_struct		run_work;
 	struct mutex                    mutex;
-	struct list_head		walkers;
 };
 
 /**
  * struct rhashtable_walker - Hash table walker
  * @list: List entry on list of walkers
- * @resize: Resize event occured
+ * @tbl: The table that we were walking over
  */
 struct rhashtable_walker {
 	struct list_head list;
-	bool resize;
+	struct bucket_table *tbl;
 };
 
 /**
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index fc0d451..f7c7607 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -170,6 +170,8 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 		return NULL;
 	}
 
+	INIT_LIST_HEAD(&tbl->walkers);
+
 	for (i = 0; i < nbuckets; i++)
 		INIT_RHT_NULLS_HEAD(tbl->buckets[i], ht, i);
 
@@ -264,6 +266,7 @@ static void rhashtable_rehash(struct rhashtable *ht,
 			      struct bucket_table *new_tbl)
 {
 	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
+	struct rhashtable_walker *walker;
 	unsigned old_hash;
 
 	get_random_bytes(&new_tbl->hash_rnd, sizeof(new_tbl->hash_rnd));
@@ -284,6 +287,9 @@ static void rhashtable_rehash(struct rhashtable *ht,
 	/* Publish the new table pointer. */
 	rcu_assign_pointer(ht->tbl, new_tbl);
 
+	list_for_each_entry(walker, &old_tbl->walkers, list)
+		walker->tbl = NULL;
+
 	/* Wait for readers. All new readers will see the new
 	 * table, and thus no references to the old table will
 	 * remain.
@@ -358,7 +364,6 @@ static void rht_deferred_worker(struct work_struct *work)
 {
 	struct rhashtable *ht;
 	struct bucket_table *tbl;
-	struct rhashtable_walker *walker;
 
 	ht = container_of(work, struct rhashtable, run_work);
 	mutex_lock(&ht->mutex);
@@ -367,9 +372,6 @@ static void rht_deferred_worker(struct work_struct *work)
 
 	tbl = rht_dereference(ht->tbl, ht);
 
-	list_for_each_entry(walker, &ht->walkers, list)
-		walker->resize = true;
-
 	if (rht_grow_above_75(ht, tbl))
 		rhashtable_expand(ht);
 	else if (rht_shrink_below_30(ht, tbl))
@@ -725,11 +727,9 @@ int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter)
 	if (!iter->walker)
 		return -ENOMEM;
 
-	INIT_LIST_HEAD(&iter->walker->list);
-	iter->walker->resize = false;
-
 	mutex_lock(&ht->mutex);
-	list_add(&iter->walker->list, &ht->walkers);
+	iter->walker->tbl = rht_dereference(ht->tbl, ht);
+	list_add(&iter->walker->list, &iter->walker->tbl->walkers);
 	mutex_unlock(&ht->mutex);
 
 	return 0;
@@ -745,7 +745,8 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_init);
 void rhashtable_walk_exit(struct rhashtable_iter *iter)
 {
 	mutex_lock(&iter->ht->mutex);
-	list_del(&iter->walker->list);
+	if (iter->walker->tbl)
+		list_del(&iter->walker->list);
 	mutex_unlock(&iter->ht->mutex);
 	kfree(iter->walker);
 }
@@ -767,12 +768,19 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_exit);
  */
 int rhashtable_walk_start(struct rhashtable_iter *iter)
 {
+	struct rhashtable *ht = iter->ht;
+
+	mutex_lock(&ht->mutex);
+
+	if (iter->walker->tbl)
+		list_del(&iter->walker->list);
+
 	rcu_read_lock();
 
-	if (iter->walker->resize) {
-		iter->slot = 0;
-		iter->skip = 0;
-		iter->walker->resize = false;
+	mutex_unlock(&ht->mutex);
+
+	if (!iter->walker->tbl) {
+		iter->walker->tbl = rht_dereference_rcu(ht->tbl, ht);
 		return -EAGAIN;
 	}
 
@@ -794,13 +802,11 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_start);
  */
 void *rhashtable_walk_next(struct rhashtable_iter *iter)
 {
-	const struct bucket_table *tbl;
+	struct bucket_table *tbl = iter->walker->tbl;
 	struct rhashtable *ht = iter->ht;
 	struct rhash_head *p = iter->p;
 	void *obj = NULL;
 
-	tbl = rht_dereference_rcu(ht->tbl, ht);
-
 	if (p) {
 		p = rht_dereference_bucket_rcu(p->next, tbl, iter->slot);
 		goto next;
@@ -826,17 +832,18 @@ next:
 		iter->skip = 0;
 	}
 
-	iter->p = NULL;
-
-out:
-	if (iter->walker->resize) {
-		iter->p = NULL;
+	iter->walker->tbl = rht_dereference_rcu(ht->future_tbl, ht);
+	if (iter->walker->tbl != tbl) {
 		iter->slot = 0;
 		iter->skip = 0;
-		iter->walker->resize = false;
 		return ERR_PTR(-EAGAIN);
 	}
 
+	iter->walker->tbl = NULL;
+	iter->p = NULL;
+
+out:
+
 	return obj;
 }
 EXPORT_SYMBOL_GPL(rhashtable_walk_next);
@@ -849,7 +856,24 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_next);
  */
 void rhashtable_walk_stop(struct rhashtable_iter *iter)
 {
+	struct rhashtable *ht;
+	struct bucket_table *tbl = iter->walker->tbl;
+
 	rcu_read_unlock();
+
+	if (!tbl)
+		return;
+
+	ht = iter->ht;
+
+	mutex_lock(&ht->mutex);
+	if (rht_dereference(ht->tbl, ht) == tbl ||
+	    rht_dereference(ht->future_tbl, ht) == tbl)
+		list_add(&iter->walker->list, &tbl->walkers);
+	else
+		iter->walker->tbl = NULL;
+	mutex_unlock(&ht->mutex);
+
 	iter->p = NULL;
 }
 EXPORT_SYMBOL_GPL(rhashtable_walk_stop);
@@ -927,7 +951,6 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	memset(ht, 0, sizeof(*ht));
 	mutex_init(&ht->mutex);
 	memcpy(&ht->p, params, sizeof(*params));
-	INIT_LIST_HEAD(&ht->walkers);
 
 	if (params->locks_mul)
 		ht->p.locks_mul = roundup_pow_of_two(params->locks_mul);
