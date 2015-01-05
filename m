From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2] rhashtable: involve rhashtable_lookup_insert routine
Date: Mon, 5 Jan 2015 19:33:54 +0800
Message-ID: <1420457634-13017-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:35605 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753516AbbAELeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 06:34:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Involve a new function called rhashtable_lookup_insert() which makes
lookup and insertion atomic under bucket lock protection, helping us
avoid to introduce an extra lock when we search and insert an object
into hash table.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
v2:
 According to Thomas's comments and his given code, below changes
 are made in the version:
 - Locks down the bucket in both the old and new table if a resize is
   in progress to ensure that writers can't remove from the old table
   and can't insert to the new table during the atomic operation.
 - Search for duplicates in the old table if a resize is in progress.
 - Use memcmp() instead of ptr1 != ptr2 to search for duplicates
   assuming we want to avoid key duplicates with this function.
 - add BUG_ON(!ht->p.key_len) for the funciton
 - update rhashtable_lookup_insert() description
 - fix two places of typo.

 include/linux/rhashtable.h |    1 +
 lib/rhashtable.c           |   96 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 95 insertions(+), 2 deletions(-)

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
index cbad192..94fd511 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -493,7 +493,7 @@ static void rht_deferred_worker(struct work_struct *work)
 }
 
 /**
- * rhashtable_insert - insert object into hash hash table
+ * rhashtable_insert - insert object into hash table
  * @ht:		hash table
  * @obj:	pointer to hash head inside object
  *
@@ -621,7 +621,7 @@ EXPORT_SYMBOL_GPL(rhashtable_remove);
  * for a entry with an identical key. The first matching entry is returned.
  *
  * This lookup function may only be used for fixed key hash table (key_len
- * paramter set). It will BUG() if used inappropriately.
+ * parameter set). It will BUG() if used inappropriately.
  *
  * Lookups may occur in parallel with hashtable mutations and resizing.
  */
@@ -700,6 +700,98 @@ restart:
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
+	struct rhash_head *he, *head;
+	spinlock_t *new_bucket_lock, *old_bucket_lock;
+	u32 new_hash, old_hash;
+
+	BUG_ON(!ht->p.key_len);
+
+	rcu_read_lock();
+	old_tbl = rht_dereference_rcu(ht->tbl, ht);
+	old_hash = head_hashfn(ht, old_tbl, obj);
+	old_bucket_lock = bucket_lock(old_tbl, old_hash);
+	spin_lock_bh(old_bucket_lock);
+
+	new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
+	new_hash = head_hashfn(ht, new_tbl, obj);
+	new_bucket_lock = bucket_lock(new_tbl, new_hash);
+	if (unlikely(old_tbl != new_tbl)) {
+		spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED);
+
+		/* Resizing is in progress, search for a matching entry in the
+		 * old table before attempting to insert to the future table.
+		 */
+		rht_for_each(he, old_tbl, old_hash) {
+			if (!memcmp(rht_obj(ht, he) + ht->p.key_offset,
+				    rht_obj(ht, obj) + ht->p.key_offset,
+				    ht->p.key_len))
+				goto entry_exists;
+		}
+	}
+
+	head = rht_dereference_bucket(new_tbl->buckets[new_hash], new_tbl,
+				      new_hash);
+	if (rht_is_a_nulls(head)) {
+		INIT_RHT_NULLS_HEAD(obj->next, ht, new_hash);
+	} else {
+		rht_for_each(he, new_tbl, new_hash) {
+			if (!memcmp(rht_obj(ht, he) + ht->p.key_offset,
+				    rht_obj(ht, obj) + ht->p.key_offset,
+				    ht->p.key_len))
+				goto entry_exists;
+		}
+		RCU_INIT_POINTER(obj->next, head);
+	}
+
+	rcu_assign_pointer(new_tbl->buckets[new_hash], obj);
+	if (unlikely(old_tbl != new_tbl))
+		spin_unlock_bh(new_bucket_lock);
+	spin_unlock_bh(old_bucket_lock);
+
+	atomic_inc(&ht->nelems);
+
+	/* Only grow the table if no resizing is currently in progress. */
+	if (ht->tbl != ht->future_tbl &&
+	    ht->p.grow_decision && ht->p.grow_decision(ht, new_tbl->size))
+		schedule_delayed_work(&ht->run_work, 0);
+
+	rcu_read_unlock();
+
+	return true;
+
+entry_exists:
+	if (unlikely(old_tbl != new_tbl))
+		spin_unlock_bh(new_bucket_lock);
+	spin_unlock_bh(old_bucket_lock);
+	rcu_read_unlock();
+
+	return false;
+}
+EXPORT_SYMBOL_GPL(rhashtable_lookup_insert);
+
 static size_t rounded_hashtable_size(struct rhashtable_params *params)
 {
 	return max(roundup_pow_of_two(params->nelem_hint * 4 / 3),
-- 
1.7.9.5
