From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 7/10] rhashtable: Disable automatic shrinking
Date: Sun, 22 Mar 2015 18:53:50 +1100
Message-ID: <E1YZahi-0000iy-Ke@gondolin.me.apana.org.au>
References: <20150322075300.GA2441@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:46954 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbbCVHyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 03:54:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Automatic shrinking is dangerous because it provides an easy
way for an adversary to cause us to do unnecessary work.  Thus
making the resizable hashtable a poor data structure.

This patch disables automatic shrinking but retains a manual
shrink function for those cases where insertions and removals
are overseen by a trusted entity, e.g., nft_hash.

The shrink function will now also shrink to fit rather than halve
the size of the table.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |   15 ---------------
 lib/rhashtable.c           |   44 ++++++++++++++++++++++++++++++--------------
 lib/test_rhashtable.c      |   16 ++++++----------
 3 files changed, 36 insertions(+), 39 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 2a98b95..44aa579 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -252,19 +252,6 @@ static inline bool rht_grow_above_75(const struct rhashtable *ht,
 	       (!ht->p.max_size || tbl->size < ht->p.max_size);
 }
 
-/**
- * rht_shrink_below_30 - returns true if nelems < 0.3 * table-size
- * @ht:		hash table
- * @tbl:	current table
- */
-static inline bool rht_shrink_below_30(const struct rhashtable *ht,
-				       const struct bucket_table *tbl)
-{
-	/* Shrink table beneath 30% load */
-	return atomic_read(&ht->nelems) < (tbl->size * 3 / 10) &&
-	       tbl->size > ht->p.min_size;
-}
-
 /* The bucket lock is selected based on the hash and protects mutations
  * on a group of hash buckets.
  *
@@ -745,8 +732,6 @@ static inline int rhashtable_remove_fast(
 		goto out;
 
 	atomic_dec(&ht->nelems);
-	if (rht_shrink_below_30(ht, tbl))
-		schedule_work(&ht->run_work);
 
 out:
 	rcu_read_unlock();
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 798f01d..08a6123 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -261,30 +261,48 @@ EXPORT_SYMBOL_GPL(rhashtable_expand);
  * rhashtable_shrink - Shrink hash table while allowing concurrent lookups
  * @ht:		the hash table to shrink
  *
- * This function may only be called in a context where it is safe to call
- * synchronize_rcu(), e.g. not within a rcu_read_lock() section.
- *
- * The caller must ensure that no concurrent resizing occurs by holding
- * ht->mutex.
- *
- * The caller must ensure that no concurrent table mutations take place.
- * It is however valid to have concurrent lookups if they are RCU protected.
+ * This function shrinks the hash table to fit, i.e., the smallest
+ * size would not cause it to expand right away automatically.
  *
  * It is valid to have concurrent insertions and deletions protected by per
  * bucket locks or concurrent RCU protected lookups and traversals.
  */
 int rhashtable_shrink(struct rhashtable *ht)
 {
-	struct bucket_table *new_tbl, *old_tbl = rht_dereference(ht->tbl, ht);
+	unsigned size = roundup_pow_of_two(atomic_read(&ht->nelems) * 4 / 3);
+	struct bucket_table *new_tbl;
+	struct bucket_table *tbl;
+	int err;
 
-	ASSERT_RHT_MUTEX(ht);
+	if (size < ht->p.min_size)
+		size = ht->p.min_size;
 
-	new_tbl = bucket_table_alloc(ht, old_tbl->size / 2);
+	new_tbl = bucket_table_alloc(ht, size);
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
+	err = -EEXIST;
+
+	mutex_lock(&ht->mutex);
+	tbl = rht_dereference(ht->tbl, ht);
+	if (rht_dereference(tbl->future_tbl, ht))
+		goto out_free_tbl;
+
+	err = 0;
+	if (tbl->size <= size)
+		goto out_free_tbl;
+
 	rhashtable_rehash(ht, new_tbl);
-	return 0;
+
+	mutex_unlock(&ht->mutex);
+
+out:
+	return err;
+
+out_free_tbl:
+	mutex_unlock(&ht->mutex);
+	bucket_table_free(new_tbl);
+	goto out;
 }
 EXPORT_SYMBOL_GPL(rhashtable_shrink);
 
@@ -302,8 +320,6 @@ static void rht_deferred_worker(struct work_struct *work)
 
 	if (rht_grow_above_75(ht, tbl))
 		rhashtable_expand(ht);
-	else if (rht_shrink_below_30(ht, tbl))
-		rhashtable_shrink(ht);
 unlock:
 	mutex_unlock(&ht->mutex);
 }
diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index a2ba6ad..0ceb332 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -167,17 +167,13 @@ static int __init test_rhashtable(struct rhashtable *ht)
 		rcu_read_unlock();
 	}
 
-	for (i = 0; i < TEST_NEXPANDS; i++) {
-		pr_info("  Table shrinkage iteration %u...\n", i);
-		mutex_lock(&ht->mutex);
-		rhashtable_shrink(ht);
-		mutex_unlock(&ht->mutex);
+	pr_info("  Table shrinkage...\n");
+	rhashtable_shrink(ht);
 
-		rcu_read_lock();
-		pr_info("  Verifying lookups...\n");
-		test_rht_lookup(ht);
-		rcu_read_unlock();
-	}
+	rcu_read_lock();
+	pr_info("  Verifying lookups...\n");
+	test_rht_lookup(ht);
+	rcu_read_unlock();
 
 	rcu_read_lock();
 	test_bucket_stats(ht, true);
