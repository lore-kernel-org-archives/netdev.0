From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2 1/3] rhashtable: involve rhashtable_lookup_compare_insert routine
Date: Mon, 12 Jan 2015 14:52:22 +0800
Message-ID: <1421045544-13670-2-git-send-email-ying.xue@windriver.com>
References: <1421045544-13670-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61150 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbbALGw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 01:52:58 -0500
In-Reply-To: <1421045544-13670-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a new function called rhashtable_lookup_compare_insert()
which is very similar to rhashtable_lookup_insert(). But the former
makes use of users' given compare function to look for an object,
and then inserts it into hash table if found. As the entire process
of search and insertion is under protection of per bucket lock, this
can help users to avoid the involvement of extra lock.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Cc: Thomas Graf <tgraf@suug.ch>
Acked-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h |    5 +++++
 lib/rhashtable.c           |   42 ++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 326acd8..7b9bd77 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -168,7 +168,12 @@ int rhashtable_shrink(struct rhashtable *ht);
 void *rhashtable_lookup(struct rhashtable *ht, const void *key);
 void *rhashtable_lookup_compare(struct rhashtable *ht, const void *key,
 				bool (*compare)(void *, void *), void *arg);
+
 bool rhashtable_lookup_insert(struct rhashtable *ht, struct rhash_head *obj);
+bool rhashtable_lookup_compare_insert(struct rhashtable *ht,
+				      struct rhash_head *obj,
+				      bool (*compare)(void *, void *),
+				      void *arg);
 
 void rhashtable_destroy(struct rhashtable *ht);
 
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 8023b55..ed6ae1a 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -727,6 +727,43 @@ EXPORT_SYMBOL_GPL(rhashtable_lookup_compare);
  */
 bool rhashtable_lookup_insert(struct rhashtable *ht, struct rhash_head *obj)
 {
+	struct rhashtable_compare_arg arg = {
+		.ht = ht,
+		.key = rht_obj(ht, obj) + ht->p.key_offset,
+	};
+
+	BUG_ON(!ht->p.key_len);
+
+	return rhashtable_lookup_compare_insert(ht, obj, &rhashtable_compare,
+						&arg);
+}
+EXPORT_SYMBOL_GPL(rhashtable_lookup_insert);
+
+/**
+ * rhashtable_lookup_compare_insert - search and insert object to hash table
+ *                                    with compare function
+ * @ht:		hash table
+ * @obj:	pointer to hash head inside object
+ * @compare:	compare function, must return true on match
+ * @arg:	argument passed on to compare function
+ *
+ * Locks down the bucket chain in both the old and new table if a resize
+ * is in progress to ensure that writers can't remove from the old table
+ * and can't insert to the new table during the atomic operation of search
+ * and insertion. Searches for duplicates in both the old and new table if
+ * a resize is in progress.
+ *
+ * Lookups may occur in parallel with hashtable mutations and resizing.
+ *
+ * Will trigger an automatic deferred table resizing if the size grows
+ * beyond the watermark indicated by grow_decision() which can be passed
+ * to rhashtable_init().
+ */
+bool rhashtable_lookup_compare_insert(struct rhashtable *ht,
+				      struct rhash_head *obj,
+				      bool (*compare)(void *, void *),
+				      void *arg)
+{
 	struct bucket_table *new_tbl, *old_tbl;
 	spinlock_t *new_bucket_lock, *old_bucket_lock;
 	u32 new_hash, old_hash;
@@ -747,7 +784,8 @@ bool rhashtable_lookup_insert(struct rhashtable *ht, struct rhash_head *obj)
 	if (unlikely(old_tbl != new_tbl))
 		spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED);
 
-	if (rhashtable_lookup(ht, rht_obj(ht, obj) + ht->p.key_offset)) {
+	if (rhashtable_lookup_compare(ht, rht_obj(ht, obj) + ht->p.key_offset,
+				      compare, arg)) {
 		success = false;
 		goto exit;
 	}
@@ -763,7 +801,7 @@ exit:
 
 	return success;
 }
-EXPORT_SYMBOL_GPL(rhashtable_lookup_insert);
+EXPORT_SYMBOL_GPL(rhashtable_lookup_compare_insert);
 
 static size_t rounded_hashtable_size(struct rhashtable_params *params)
 {
-- 
1.7.9.5
