From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] rhashtable: involve rhashtable_lookup_insert routine
Date: Mon, 5 Jan 2015 16:46:18 +0800
Message-ID: <1420447578-19320-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:32787 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbbAEIqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 03:46:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Involve a new function called rhashtable_lookup_insert() which makes
lookup and insertion atomic under bucket lock protection, helping us
avoid to introduce an extra lock when we search and insert an object
into hash table.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Cc: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h |    1 +
 lib/rhashtable.c           |   62 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 62 insertions(+), 1 deletion(-)

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
index cbad192..04e0af7 100644
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
@@ -700,6 +700,66 @@ restart:
 }
 EXPORT_SYMBOL_GPL(rhashtable_lookup_compare);
 
+/**
+ * rhashtable_lookup_insert - lookup and insert object into hash table
+ * @ht:		hash table
+ * @obj:	pointer to hash head inside object
+ *
+ * Computes the hash value for the given object and traverses the bucket
+ * chain checking whether the object exists in the chain or not. If it's
+ * not found, the object is then inserted into the bucket chain. As the
+ * bucket lock is held during the process of lookup and insertion, this
+ * helps to avoid extra lock involvement.
+ *
+ * It is safe to call this function from atomic context.
+ *
+ * Will trigger an automatic deferred table resizing if the size grows
+ * beyond the watermark indicated by grow_decision() which can be passed
+ * to rhashtable_init().
+ */
+bool rhashtable_lookup_insert(struct rhashtable *ht, struct rhash_head *obj)
+{
+	struct bucket_table *tbl;
+	struct rhash_head *he, *head;
+	spinlock_t *lock;
+	unsigned int hash;
+
+	rcu_read_lock();
+
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+	hash = head_hashfn(ht, tbl, obj);
+	lock = bucket_lock(tbl, hash);
+
+	spin_lock_bh(lock);
+	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
+	if (rht_is_a_nulls(head)) {
+		INIT_RHT_NULLS_HEAD(obj->next, ht, hash);
+	} else {
+		rht_for_each(he, tbl, hash) {
+			if (he == obj) {
+				spin_unlock_bh(lock);
+				rcu_read_unlock();
+				return false;
+			}
+		}
+		RCU_INIT_POINTER(obj->next, head);
+	}
+	rcu_assign_pointer(tbl->buckets[hash], obj);
+	spin_unlock_bh(lock);
+
+	atomic_inc(&ht->nelems);
+
+	/* Only grow the table if no resizing is currently in progress. */
+	if (ht->tbl != ht->future_tbl &&
+	    ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size))
+		schedule_delayed_work(&ht->run_work, 0);
+
+	rcu_read_unlock();
+
+	return true;
+}
+EXPORT_SYMBOL_GPL(rhashtable_lookup_insert);
+
 static size_t rounded_hashtable_size(struct rhashtable_params *params)
 {
 	return max(roundup_pow_of_two(params->nelem_hint * 4 / 3),
-- 
1.7.9.5
