From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH nf-next,v2 1/2] rhashtable: add rhashtable_lookup_get_insert_key()
Date: Thu, 25 Aug 2016 16:41:26 +0200
Message-ID: <1472136087-1338-1-git-send-email-pablo@netfilter.org>
Cc: herbert@gondor.apana.org.au, tgraf@suug.ch, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56820 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756980AbcHYOnU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 10:43:20 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 488CA1022B3
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 16:43:18 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 41CADFF2C8
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 16:43:18 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 32B4BFF2C8
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 16:43:05 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies __rhashtable_insert_fast() so it returns the
existing object that clashes with the one that you want to insert.
In case the object is successfully inserted, NULL is returned.
Otherwise, you get an error via ERR_PTR().

This patch adapts the existing callers of __rhashtable_insert_fast()
so they handle this new logic, and it adds a new
rhashtable_lookup_get_insert_key() interface to fetch this existing
object.

nf_tables needs this change to improve handling of EEXIST cases via
honoring the NLM_F_EXCL flag and by checking if the data part of the
mapping matches what we have.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
v2: Address Herbert's feedback:

    * Modify __rhashtable_insert_fast() so this returns the object if it
    exists, NULL if it does not and the insertion was successful, and
    an ERR_PTR otherwise.
    * Update rhashtable_insert_slow() path too.

 include/linux/rhashtable.h | 70 +++++++++++++++++++++++++++++++++++++---------
 lib/rhashtable.c           | 10 +++++--
 2 files changed, 64 insertions(+), 16 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 3eef080..26b7a05 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -343,7 +343,8 @@ int rhashtable_init(struct rhashtable *ht,
 struct bucket_table *rhashtable_insert_slow(struct rhashtable *ht,
 					    const void *key,
 					    struct rhash_head *obj,
-					    struct bucket_table *old_tbl);
+					    struct bucket_table *old_tbl,
+					    void **data);
 int rhashtable_insert_rehash(struct rhashtable *ht, struct bucket_table *tbl);
 
 int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter,
@@ -563,8 +564,11 @@ restart:
 	return NULL;
 }
 
-/* Internal function, please use rhashtable_insert_fast() instead */
-static inline int __rhashtable_insert_fast(
+/* Internal function, please use rhashtable_insert_fast() instead. This
+ * function returns the existing element already in hashes in there is a clash,
+ * otherwise it returns an error via ERR_PTR().
+ */
+static inline void *__rhashtable_insert_fast(
 	struct rhashtable *ht, const void *key, struct rhash_head *obj,
 	const struct rhashtable_params params)
 {
@@ -577,6 +581,7 @@ static inline int __rhashtable_insert_fast(
 	spinlock_t *lock;
 	unsigned int elasticity;
 	unsigned int hash;
+	void *data = NULL;
 	int err;
 
 restart:
@@ -601,11 +606,14 @@ restart:
 
 	new_tbl = rht_dereference_rcu(tbl->future_tbl, ht);
 	if (unlikely(new_tbl)) {
-		tbl = rhashtable_insert_slow(ht, key, obj, new_tbl);
+		tbl = rhashtable_insert_slow(ht, key, obj, new_tbl, &data);
 		if (!IS_ERR_OR_NULL(tbl))
 			goto slow_path;
 
 		err = PTR_ERR(tbl);
+		if (err == -EEXIST)
+			err = 0;
+
 		goto out;
 	}
 
@@ -619,25 +627,25 @@ slow_path:
 		err = rhashtable_insert_rehash(ht, tbl);
 		rcu_read_unlock();
 		if (err)
-			return err;
+			return ERR_PTR(err);
 
 		goto restart;
 	}
 
-	err = -EEXIST;
+	err = 0;
 	elasticity = ht->elasticity;
 	rht_for_each(head, tbl, hash) {
 		if (key &&
 		    unlikely(!(params.obj_cmpfn ?
 			       params.obj_cmpfn(&arg, rht_obj(ht, head)) :
-			       rhashtable_compare(&arg, rht_obj(ht, head)))))
+			       rhashtable_compare(&arg, rht_obj(ht, head))))) {
+			data = rht_obj(ht, head);
 			goto out;
+		}
 		if (!--elasticity)
 			goto slow_path;
 	}
 
-	err = 0;
-
 	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
 
 	RCU_INIT_POINTER(obj->next, head);
@@ -652,7 +660,7 @@ out:
 	spin_unlock_bh(lock);
 	rcu_read_unlock();
 
-	return err;
+	return err ? ERR_PTR(err) : data;
 }
 
 /**
@@ -675,7 +683,13 @@ static inline int rhashtable_insert_fast(
 	struct rhashtable *ht, struct rhash_head *obj,
 	const struct rhashtable_params params)
 {
-	return __rhashtable_insert_fast(ht, NULL, obj, params);
+	void *ret;
+
+	ret = __rhashtable_insert_fast(ht, NULL, obj, params);
+	if (IS_ERR(ret))
+		return PTR_ERR(ret);
+
+	return ret == NULL ? 0 : -EEXIST;
 }
 
 /**
@@ -704,11 +718,15 @@ static inline int rhashtable_lookup_insert_fast(
 	const struct rhashtable_params params)
 {
 	const char *key = rht_obj(ht, obj);
+	void *ret;
 
 	BUG_ON(ht->p.obj_hashfn);
 
-	return __rhashtable_insert_fast(ht, key + ht->p.key_offset, obj,
-					params);
+	ret = __rhashtable_insert_fast(ht, key + ht->p.key_offset, obj, params);
+	if (IS_ERR(ret))
+		return PTR_ERR(ret);
+
+	return ret == NULL ? 0 : -EEXIST;
 }
 
 /**
@@ -737,6 +755,32 @@ static inline int rhashtable_lookup_insert_key(
 	struct rhashtable *ht, const void *key, struct rhash_head *obj,
 	const struct rhashtable_params params)
 {
+	void *ret;
+
+	BUG_ON(!ht->p.obj_hashfn || !key);
+
+	ret = __rhashtable_insert_fast(ht, key, obj, params);
+	if (IS_ERR(ret))
+		return PTR_ERR(ret);
+
+	return ret == NULL ? 0 : -EEXIST;
+}
+
+/**
+ * rhashtable_lookup_get_insert_key - lookup and insert object into hash table
+ * @ht:		hash table
+ * @obj:	pointer to hash head inside object
+ * @params:	hash table parameters
+ * @data:	pointer to element data already in hashes
+ *
+ * Just like rhashtable_lookup_insert_key(), but this function returns the
+ * object if it exists, NULL if it does not and the insertion was successful,
+ * and an ERR_PTR otherwise.
+ */
+static inline void *rhashtable_lookup_get_insert_key(
+	struct rhashtable *ht, const void *key, struct rhash_head *obj,
+	const struct rhashtable_params params)
+{
 	BUG_ON(!ht->p.obj_hashfn || !key);
 
 	return __rhashtable_insert_fast(ht, key, obj, params);
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 5d845ff..7a940d9 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -438,7 +438,8 @@ EXPORT_SYMBOL_GPL(rhashtable_insert_rehash);
 struct bucket_table *rhashtable_insert_slow(struct rhashtable *ht,
 					    const void *key,
 					    struct rhash_head *obj,
-					    struct bucket_table *tbl)
+					    struct bucket_table *tbl,
+					    void **data)
 {
 	struct rhash_head *head;
 	unsigned int hash;
@@ -449,8 +450,11 @@ struct bucket_table *rhashtable_insert_slow(struct rhashtable *ht,
 	spin_lock_nested(rht_bucket_lock(tbl, hash), SINGLE_DEPTH_NESTING);
 
 	err = -EEXIST;
-	if (key && rhashtable_lookup_fast(ht, key, ht->p))
-		goto exit;
+	if (key) {
+		*data = rhashtable_lookup_fast(ht, key, ht->p);
+		if (*data)
+			goto exit;
+	}
 
 	err = -E2BIG;
 	if (unlikely(rht_grow_above_max(ht, tbl)))
-- 
2.1.4
