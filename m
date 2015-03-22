From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 8/10] rhashtable: Add multiple rehash support
Date: Sun, 22 Mar 2015 18:53:51 +1100
Message-ID: <E1YZahj-0000jF-OM@gondolin.me.apana.org.au>
References: <20150322075300.GA2441@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:58776 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbbCVHyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 03:54:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the missing bits to allow multiple rehashes.  The
read-side as well as remove already handle this correctly.  So it's
only the rehasher and insertion that need modification to handle
this.

Note that this patch doesn't actually enable it so for now rehashing
is still only performed by the worker thread and a user thread if
an explicit shrinking is ordered.

This patch also disables the rhashtable_expand interface because
it is useless since the table is meant to expand automatically.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |   24 ++++++----
 lib/rhashtable.c           |   99 ++++++++++++++++++++++++++++++---------------
 lib/test_rhashtable.c      |   23 +---------
 3 files changed, 85 insertions(+), 61 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 44aa579..cba22d8 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -294,7 +294,6 @@ int rhashtable_insert_slow(struct rhashtable *ht, const void *key,
 			   struct rhash_head *obj,
 			   struct bucket_table *old_tbl);
 
-int rhashtable_expand(struct rhashtable *ht);
 int rhashtable_shrink(struct rhashtable *ht);
 
 int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter);
@@ -527,17 +526,22 @@ static inline int __rhashtable_insert_fast(
 	rcu_read_lock();
 
 	tbl = rht_dereference_rcu(ht->tbl, ht);
-	hash = rht_head_hashfn(ht, tbl, obj, params);
-	lock = rht_bucket_lock(tbl, hash);
-
-	spin_lock_bh(lock);
 
-	/* Because we have already taken the bucket lock in tbl,
-	 * if we find that future_tbl is not yet visible then
-	 * that guarantees all other insertions of the same entry
-	 * will also grab the bucket lock in tbl because until
-	 * the rehash completes ht->tbl won't be changed.
+	/* All insertions must grab the oldest table containing
+	 * the hashed bucket that is yet to be rehashed.
 	 */
+	for (;;) {
+		hash = rht_head_hashfn(ht, tbl, obj, params);
+		lock = rht_bucket_lock(tbl, hash);
+		spin_lock_bh(lock);
+
+		if (tbl->rehash <= hash)
+			break;
+
+		spin_unlock_bh(lock);
+		tbl = rht_dereference_rcu(tbl->future_tbl, ht);
+	}
+
 	new_tbl = rht_dereference_rcu(tbl->future_tbl, ht);
 	if (unlikely(new_tbl)) {
 		err = rhashtable_insert_slow(ht, key, obj, new_tbl);
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 08a6123..c284099 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -136,11 +136,24 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 	return tbl;
 }
 
+static struct bucket_table *rhashtable_last_table(struct rhashtable *ht,
+						  struct bucket_table *tbl)
+{
+	struct bucket_table *new_tbl;
+
+	do {
+		new_tbl = tbl;
+		tbl = rht_dereference_rcu(tbl->future_tbl, ht);
+	} while (tbl);
+
+	return new_tbl;
+}
+
 static int rhashtable_rehash_one(struct rhashtable *ht, unsigned old_hash)
 {
 	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
-	struct bucket_table *new_tbl =
-		rht_dereference(old_tbl->future_tbl, ht) ?: old_tbl;
+	struct bucket_table *new_tbl = rhashtable_last_table(ht,
+		rht_dereference_rcu(old_tbl->future_tbl, ht));
 	struct rhash_head __rcu **pprev = &old_tbl->buckets[old_hash];
 	int err = -ENOENT;
 	struct rhash_head *head, *next, *entry;
@@ -196,12 +209,18 @@ static void rhashtable_rehash_chain(struct rhashtable *ht, unsigned old_hash)
 	spin_unlock_bh(old_bucket_lock);
 }
 
-static void rhashtable_rehash(struct rhashtable *ht,
-			      struct bucket_table *new_tbl)
+static int rhashtable_rehash_attach(struct rhashtable *ht,
+				    struct bucket_table *old_tbl,
+				    struct bucket_table *new_tbl)
 {
-	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
-	struct rhashtable_walker *walker;
-	unsigned old_hash;
+	/* Protect future_tbl using the first bucket lock. */
+	spin_lock_bh(old_tbl->locks);
+
+	/* Did somebody beat us to it? */
+	if (rcu_access_pointer(old_tbl->future_tbl)) {
+		spin_unlock_bh(old_tbl->locks);
+		return -EEXIST;
+	}
 
 	/* Make insertions go into the new, empty table right away. Deletions
 	 * and lookups will be attempted in both tables until we synchronize.
@@ -211,6 +230,22 @@ static void rhashtable_rehash(struct rhashtable *ht,
 	/* Ensure the new table is visible to readers. */
 	smp_wmb();
 
+	spin_unlock_bh(old_tbl->locks);
+
+	return 0;
+}
+
+static int rhashtable_rehash_table(struct rhashtable *ht)
+{
+	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
+	struct bucket_table *new_tbl;
+	struct rhashtable_walker *walker;
+	unsigned old_hash;
+
+	new_tbl = rht_dereference(old_tbl->future_tbl, ht);
+	if (!new_tbl)
+		return 0;
+
 	for (old_hash = 0; old_hash < old_tbl->size; old_hash++)
 		rhashtable_rehash_chain(ht, old_hash);
 
@@ -225,37 +260,29 @@ static void rhashtable_rehash(struct rhashtable *ht,
 	 * remain.
 	 */
 	call_rcu(&old_tbl->rcu, bucket_table_free_rcu);
+
+	return rht_dereference(new_tbl->future_tbl, ht) ? -EAGAIN : 0;
 }
 
-/**
- * rhashtable_expand - Expand hash table while allowing concurrent lookups
- * @ht:		the hash table to expand
- *
- * A secondary bucket array is allocated and the hash entries are migrated.
- *
- * This function may only be called in a context where it is safe to call
- * synchronize_rcu(), e.g. not within a rcu_read_lock() section.
- *
- * The caller must ensure that no concurrent resizing occurs by holding
- * ht->mutex.
- *
- * It is valid to have concurrent insertions and deletions protected by per
- * bucket locks or concurrent RCU protected lookups and traversals.
- */
-int rhashtable_expand(struct rhashtable *ht)
+static int rhashtable_expand(struct rhashtable *ht)
 {
 	struct bucket_table *new_tbl, *old_tbl = rht_dereference(ht->tbl, ht);
+	int err;
 
 	ASSERT_RHT_MUTEX(ht);
 
+	old_tbl = rhashtable_last_table(ht, old_tbl);
+
 	new_tbl = bucket_table_alloc(ht, old_tbl->size * 2);
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
-	rhashtable_rehash(ht, new_tbl);
-	return 0;
+	err = rhashtable_rehash_attach(ht, old_tbl, new_tbl);
+	if (err)
+		bucket_table_free(new_tbl);
+
+	return err;
 }
-EXPORT_SYMBOL_GPL(rhashtable_expand);
 
 /**
  * rhashtable_shrink - Shrink hash table while allowing concurrent lookups
@@ -281,18 +308,19 @@ int rhashtable_shrink(struct rhashtable *ht)
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
-	err = -EEXIST;
-
 	mutex_lock(&ht->mutex);
 	tbl = rht_dereference(ht->tbl, ht);
-	if (rht_dereference(tbl->future_tbl, ht))
-		goto out_free_tbl;
+	tbl = rhashtable_last_table(ht, tbl);
 
 	err = 0;
 	if (tbl->size <= size)
 		goto out_free_tbl;
 
-	rhashtable_rehash(ht, new_tbl);
+	err = rhashtable_rehash_attach(ht, tbl, new_tbl);
+	if (err)
+		goto out_free_tbl;
+
+	schedule_work(&ht->run_work);
 
 	mutex_unlock(&ht->mutex);
 
@@ -310,6 +338,7 @@ static void rht_deferred_worker(struct work_struct *work)
 {
 	struct rhashtable *ht;
 	struct bucket_table *tbl;
+	int err = 0;
 
 	ht = container_of(work, struct rhashtable, run_work);
 	mutex_lock(&ht->mutex);
@@ -317,11 +346,18 @@ static void rht_deferred_worker(struct work_struct *work)
 		goto unlock;
 
 	tbl = rht_dereference(ht->tbl, ht);
+	tbl = rhashtable_last_table(ht, tbl);
 
 	if (rht_grow_above_75(ht, tbl))
 		rhashtable_expand(ht);
+
+	err = rhashtable_rehash_table(ht);
+
 unlock:
 	mutex_unlock(&ht->mutex);
+
+	if (err)
+		schedule_work(&ht->run_work);
 }
 
 int rhashtable_insert_slow(struct rhashtable *ht, const void *key,
@@ -332,6 +368,7 @@ int rhashtable_insert_slow(struct rhashtable *ht, const void *key,
 	unsigned hash;
 	int err = -EEXIST;
 
+	tbl = rhashtable_last_table(ht, tbl);
 	hash = head_hashfn(ht, tbl, obj);
 	spin_lock_nested(rht_bucket_lock(tbl, hash), SINGLE_DEPTH_NESTING);
 
diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 0ceb332..ca78dc2 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -151,26 +151,6 @@ static int __init test_rhashtable(struct rhashtable *ht)
 	}
 
 	rcu_read_lock();
-	test_bucket_stats(ht, true);
-	test_rht_lookup(ht);
-	rcu_read_unlock();
-
-	for (i = 0; i < TEST_NEXPANDS; i++) {
-		pr_info("  Table expansion iteration %u...\n", i);
-		mutex_lock(&ht->mutex);
-		rhashtable_expand(ht);
-		mutex_unlock(&ht->mutex);
-
-		rcu_read_lock();
-		pr_info("  Verifying lookups...\n");
-		test_rht_lookup(ht);
-		rcu_read_unlock();
-	}
-
-	pr_info("  Table shrinkage...\n");
-	rhashtable_shrink(ht);
-
-	rcu_read_lock();
 	pr_info("  Verifying lookups...\n");
 	test_rht_lookup(ht);
 	rcu_read_unlock();
@@ -190,6 +170,9 @@ static int __init test_rhashtable(struct rhashtable *ht)
 		kfree(obj);
 	}
 
+	pr_info("  Table shrinkage...\n");
+	rhashtable_shrink(ht);
+
 	return 0;
 
 error:
