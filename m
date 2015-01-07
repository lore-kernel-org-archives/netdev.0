From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2 3/7] rhashtable: involve rhashtable_lookup_insert routine
Date: Wed, 7 Jan 2015 13:41:54 +0800
Message-ID: <1420609318-3261-4-git-send-email-ying.xue@windriver.com>
References: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <jon.maloy@ericsson.com>,
	<Paul.Gortmaker@windriver.com>, <erik.hugne@ericsson.com>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:61534 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932195AbbAGFmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 00:42:46 -0500
In-Reply-To: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Involve a new function called rhashtable_lookup_insert() which makes
lookup and insertion atomic under bucket lock protection, helping us
avoid to introduce an extra lock when we search and insert an object
into hash table.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h |    1 +
 lib/rhashtable.c           |   97 +++++++++++++++++++++++++++++++++++++-------
 2 files changed, 83 insertions(+), 15 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index de1459c7..73c913f 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -168,6 +168,7 @@ int rhashtable_shrink(struct rhashtable *ht);
 void *rhashtable_lookup(struct rhashtable *ht, const void *key);
 void *rhashtable_lookup_compare(struct rhashtable *ht, const void *key,
 				bool (*compare)(void *, void *), void *arg);
+bool rhashtable_lookup_insert(struct rhashtable *ht, struct rhash_head *obj);
 
 void rhashtable_destroy(struct rhashtable *ht);
 
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 2000685..4430233 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -505,8 +505,26 @@ static void rhashtable_wakeup_worker(struct rhashtable *ht)
 		schedule_delayed_work(&ht->run_work, 0);
 }
 
+static void __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
+				struct bucket_table *tbl, u32 hash)
+{
+	struct rhash_head *head = rht_dereference_bucket(tbl->buckets[hash],
+							 tbl, hash);
+
+	if (rht_is_a_nulls(head))
+		INIT_RHT_NULLS_HEAD(obj->next, ht, hash);
+	else
+		RCU_INIT_POINTER(obj->next, head);
+
+	rcu_assign_pointer(tbl->buckets[hash], obj);
+
+	atomic_inc(&ht->nelems);
+
+	rhashtable_wakeup_worker(ht);
+}
+
 /**
- * rhashtable_insert - insert object into hash hash table
+ * rhashtable_insert - insert object into hash table
  * @ht:		hash table
  * @obj:	pointer to hash head inside object
  *
@@ -523,7 +541,6 @@ static void rhashtable_wakeup_worker(struct rhashtable *ht)
 void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
 {
 	struct bucket_table *tbl;
-	struct rhash_head *head;
 	spinlock_t *lock;
 	unsigned hash;
 
@@ -534,19 +551,9 @@ void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
 	lock = bucket_lock(tbl, hash);
 
 	spin_lock_bh(lock);
-	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
-	if (rht_is_a_nulls(head))
-		INIT_RHT_NULLS_HEAD(obj->next, ht, hash);
-	else
-		RCU_INIT_POINTER(obj->next, head);
-
-	rcu_assign_pointer(tbl->buckets[hash], obj);
+	__rhashtable_insert(ht, obj, tbl, hash);
 	spin_unlock_bh(lock);
 
-	atomic_inc(&ht->nelems);
-
-	rhashtable_wakeup_worker(ht);
-
 	rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(rhashtable_insert);
@@ -560,7 +567,7 @@ EXPORT_SYMBOL_GPL(rhashtable_insert);
  * walk the bucket chain upon removal. The removal operation is thus
  * considerable slow if the hash table is not correctly sized.
  *
- * Will automatically shrink the table via rhashtable_expand() if the the
+ * Will automatically shrink the table via rhashtable_expand() if the
  * shrink_decision function specified at rhashtable_init() returns true.
  *
  * The caller must ensure that no concurrent table mutations occur. It is
@@ -641,7 +648,7 @@ static bool rhashtable_compare(void *ptr, void *arg)
  * for a entry with an identical key. The first matching entry is returned.
  *
  * This lookup function may only be used for fixed key hash table (key_len
- * paramter set). It will BUG() if used inappropriately.
+ * parameter set). It will BUG() if used inappropriately.
  *
  * Lookups may occur in parallel with hashtable mutations and resizing.
  */
@@ -702,6 +709,66 @@ restart:
 }
 EXPORT_SYMBOL_GPL(rhashtable_lookup_compare);
 
+/**
+ * rhashtable_lookup_insert - lookup and insert object into hash table
+ * @ht:		hash table
+ * @obj:	pointer to hash head inside object
+ *
+ * Locks down the bucket chain in both the old and new table if a resize
+ * is in progress to ensure that writers can't remove from the old table
+ * and can't insert to the new table during the atomic operation of search
+ * and insertion. Searches for duplicates in both the old and new table if
+ * a resize is in progress.
+ *
+ * This lookup function may only be used for fixed key hash table (key_len
+ * parameter set). It will BUG() if used inappropriately.
+ *
+ * It is safe to call this function from atomic context.
+ *
+ * Will trigger an automatic deferred table resizing if the size grows
+ * beyond the watermark indicated by grow_decision() which can be passed
+ * to rhashtable_init().
+ */
+bool rhashtable_lookup_insert(struct rhashtable *ht, struct rhash_head *obj)
+{
+	struct bucket_table *new_tbl, *old_tbl;
+	spinlock_t *new_bucket_lock, *old_bucket_lock;
+	u32 new_hash, old_hash;
+	bool success = true;
+
+	BUG_ON(!ht->p.key_len);
+
+	rcu_read_lock();
+
+	old_tbl = rht_dereference_rcu(ht->tbl, ht);
+	old_hash = head_hashfn(ht, old_tbl, obj);
+	old_bucket_lock = bucket_lock(old_tbl, old_hash);
+	spin_lock_bh(old_bucket_lock);
+
+	new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
+	new_hash = head_hashfn(ht, new_tbl, obj);
+	new_bucket_lock = bucket_lock(new_tbl, new_hash);
+	if (unlikely(old_tbl != new_tbl))
+		spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED);
+
+	if (rhashtable_lookup(ht, rht_obj(ht, obj) + ht->p.key_offset)) {
+		success = false;
+		goto exit;
+	}
+
+	__rhashtable_insert(ht, obj, new_tbl, new_hash);
+
+exit:
+	if (unlikely(old_tbl != new_tbl))
+		spin_unlock_bh(new_bucket_lock);
+	spin_unlock_bh(old_bucket_lock);
+
+	rcu_read_unlock();
+
+	return success;
+}
+EXPORT_SYMBOL_GPL(rhashtable_lookup_insert);
+
 static size_t rounded_hashtable_size(struct rhashtable_params *params)
 {
 	return max(roundup_pow_of_two(params->nelem_hint * 4 / 3),
-- 
1.7.9.5
