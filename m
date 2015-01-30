From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/6] rhashtable: Dump bucket tables on locking violation under PROVE_LOCKING
Date: Fri, 30 Jan 2015 01:20:41 +0100
Message-ID: <41f5773f0f8bc9322326d98fae180034f2d78b81.1422576760.git.tgraf@suug.ch>
References: <cover.1422576760.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, ying.xue@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53224 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758671AbbA3AUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 19:20:55 -0500
In-Reply-To: <cover.1422576760.git.tgraf@suug.ch>
In-Reply-To: <cover.1422576760.git.tgraf@suug.ch>
References: <cover.1422576760.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This simplifies debugging of locking violations if compiled with
CONFIG_PROVE_LOCKING.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 99 ++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 75 insertions(+), 24 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 85ec36b..fa11a2e 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -48,26 +48,6 @@ static spinlock_t *bucket_lock(const struct bucket_table *tbl, u32 hash)
 	return &tbl->locks[hash & tbl->locks_mask];
 }
 
-#define ASSERT_RHT_MUTEX(HT) BUG_ON(!lockdep_rht_mutex_is_held(HT))
-#define ASSERT_BUCKET_LOCK(TBL, HASH) \
-	BUG_ON(!lockdep_rht_bucket_is_held(TBL, HASH))
-
-#ifdef CONFIG_PROVE_LOCKING
-int lockdep_rht_mutex_is_held(struct rhashtable *ht)
-{
-	return (debug_locks) ? lockdep_is_held(&ht->mutex) : 1;
-}
-EXPORT_SYMBOL_GPL(lockdep_rht_mutex_is_held);
-
-int lockdep_rht_bucket_is_held(const struct bucket_table *tbl, u32 hash)
-{
-	spinlock_t *lock = bucket_lock(tbl, hash);
-
-	return (debug_locks) ? lockdep_is_held(lock) : 1;
-}
-EXPORT_SYMBOL_GPL(lockdep_rht_bucket_is_held);
-#endif
-
 static void *rht_obj(const struct rhashtable *ht, const struct rhash_head *he)
 {
 	return (void *) he - ht->p.head_offset;
@@ -103,6 +83,77 @@ static u32 head_hashfn(const struct rhashtable *ht,
 	return rht_bucket_index(tbl, obj_raw_hashfn(ht, rht_obj(ht, he)));
 }
 
+#ifdef CONFIG_PROVE_LOCKING
+static void debug_dump_buckets(const struct rhashtable *ht,
+			       const struct bucket_table *tbl)
+{
+	struct rhash_head *he;
+	unsigned int i, hash;
+
+	for (i = 0; i < tbl->size; i++) {
+		pr_warn(" [Bucket %d] ", i);
+		rht_for_each_rcu(he, tbl, i) {
+			hash = head_hashfn(ht, tbl, he);
+			pr_cont("[hash = %#x, lock = %p] ",
+				hash, bucket_lock(tbl, hash));
+		}
+		pr_cont("\n");
+	}
+
+}
+
+static void debug_dump_table(struct rhashtable *ht,
+			     const struct bucket_table *tbl,
+			     unsigned int hash)
+{
+	struct bucket_table *old_tbl, *future_tbl;
+
+	pr_emerg("BUG: lock for hash %#x in table %p not held\n",
+		 hash, tbl);
+
+	rcu_read_lock();
+	future_tbl = rht_dereference_rcu(ht->future_tbl, ht);
+	old_tbl = rht_dereference_rcu(ht->tbl, ht);
+	if (future_tbl != old_tbl) {
+		pr_warn("Future table %p (size: %zd)\n",
+			future_tbl, future_tbl->size);
+		debug_dump_buckets(ht, future_tbl);
+	}
+
+	pr_warn("Table %p (size: %zd)\n", old_tbl, old_tbl->size);
+	debug_dump_buckets(ht, old_tbl);
+
+	rcu_read_unlock();
+}
+
+#define ASSERT_RHT_MUTEX(HT) BUG_ON(!lockdep_rht_mutex_is_held(HT))
+#define ASSERT_BUCKET_LOCK(HT, TBL, HASH)				\
+	do {								\
+		if (unlikely(!lockdep_rht_bucket_is_held(TBL, HASH))) {	\
+			debug_dump_table(HT, TBL, HASH);		\
+			BUG();						\
+		}							\
+	} while (0)
+
+int lockdep_rht_mutex_is_held(struct rhashtable *ht)
+{
+	return (debug_locks) ? lockdep_is_held(&ht->mutex) : 1;
+}
+EXPORT_SYMBOL_GPL(lockdep_rht_mutex_is_held);
+
+int lockdep_rht_bucket_is_held(const struct bucket_table *tbl, u32 hash)
+{
+	spinlock_t *lock = bucket_lock(tbl, hash);
+
+	return (debug_locks) ? lockdep_is_held(lock) : 1;
+}
+EXPORT_SYMBOL_GPL(lockdep_rht_bucket_is_held);
+#else
+#define ASSERT_RHT_MUTEX(HT)
+#define ASSERT_BUCKET_LOCK(HT, TBL, HASH)
+#endif
+
+
 static struct rhash_head __rcu **bucket_tail(struct bucket_table *tbl, u32 n)
 {
 	struct rhash_head __rcu **pprev;
@@ -234,7 +285,7 @@ static void unlock_buckets(struct bucket_table *new_tbl,
  *
  * Returns true if no more work needs to be performed on the bucket.
  */
-static bool hashtable_chain_unzip(const struct rhashtable *ht,
+static bool hashtable_chain_unzip(struct rhashtable *ht,
 				  const struct bucket_table *new_tbl,
 				  struct bucket_table *old_tbl,
 				  size_t old_hash)
@@ -242,7 +293,7 @@ static bool hashtable_chain_unzip(const struct rhashtable *ht,
 	struct rhash_head *he, *p, *next;
 	unsigned int new_hash, new_hash2;
 
-	ASSERT_BUCKET_LOCK(old_tbl, old_hash);
+	ASSERT_BUCKET_LOCK(ht, old_tbl, old_hash);
 
 	/* Old bucket empty, no work needed. */
 	p = rht_dereference_bucket(old_tbl->buckets[old_hash], old_tbl,
@@ -251,7 +302,7 @@ static bool hashtable_chain_unzip(const struct rhashtable *ht,
 		return false;
 
 	new_hash = head_hashfn(ht, new_tbl, p);
-	ASSERT_BUCKET_LOCK(new_tbl, new_hash);
+	ASSERT_BUCKET_LOCK(ht, new_tbl, new_hash);
 
 	/* Advance the old bucket pointer one or more times until it
 	 * reaches a node that doesn't hash to the same bucket as the
@@ -264,7 +315,7 @@ static bool hashtable_chain_unzip(const struct rhashtable *ht,
 		 * bucket lock. This is ensured because the bucket lock
 		 * hash map ignores the highest bit.
 		 */
-		ASSERT_BUCKET_LOCK(new_tbl, new_hash2);
+		ASSERT_BUCKET_LOCK(ht, new_tbl, new_hash2);
 
 		if (new_hash != new_hash2)
 			break;
-- 
1.9.3
