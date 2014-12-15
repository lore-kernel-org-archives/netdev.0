From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/9] rhashtable: Do hashing inside of rhashtable_lookup_compare()
Date: Mon, 15 Dec 2014 13:51:03 +0100
Message-ID: <f0228f042ccfd20766b552e308374451761a7d81.1418647641.git.tgraf@suug.ch>
References: <cover.1418647641.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, paulmck@linux.vnet.ibm.com,
	edumazet@google.com, john.r.fastabend@intel.com,
	josh@joshtriplett.org, netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38895 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496AbaLOMvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 07:51:18 -0500
In-Reply-To: <cover.1418647641.git.tgraf@suug.ch>
In-Reply-To: <cover.1418647641.git.tgraf@suug.ch>
References: <cover.1418647641.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hash the key inside of rhashtable_lookup_compare() like
rhashtable_lookup() does. This allows to simplify the hashing
functions and keep them private.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Cc: netfilter-devel@vger.kernel.org
---
 include/linux/rhashtable.h |  5 +--
 lib/rhashtable.c           | 91 +++++++++++++++-------------------------------
 net/netfilter/nft_hash.c   | 46 ++++++++++++++---------
 net/netlink/af_netlink.c   |  5 +--
 4 files changed, 61 insertions(+), 86 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index b93fd89..1b51221 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -96,9 +96,6 @@ static inline int lockdep_rht_mutex_is_held(const struct rhashtable *ht)
 
 int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params);
 
-u32 rhashtable_hashfn(const struct rhashtable *ht, const void *key, u32 len);
-u32 rhashtable_obj_hashfn(const struct rhashtable *ht, void *ptr);
-
 void rhashtable_insert(struct rhashtable *ht, struct rhash_head *node);
 bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *node);
 void rhashtable_remove_pprev(struct rhashtable *ht, struct rhash_head *obj,
@@ -111,7 +108,7 @@ int rhashtable_expand(struct rhashtable *ht);
 int rhashtable_shrink(struct rhashtable *ht);
 
 void *rhashtable_lookup(const struct rhashtable *ht, const void *key);
-void *rhashtable_lookup_compare(const struct rhashtable *ht, u32 hash,
+void *rhashtable_lookup_compare(const struct rhashtable *ht, const void *key,
 				bool (*compare)(void *, void *), void *arg);
 
 void rhashtable_destroy(const struct rhashtable *ht);
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 6c3c723..1ee0eb6 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -42,69 +42,39 @@ static void *rht_obj(const struct rhashtable *ht, const struct rhash_head *he)
 	return (void *) he - ht->p.head_offset;
 }
 
-static u32 __hashfn(const struct rhashtable *ht, const void *key,
-		      u32 len, u32 hsize)
+static u32 rht_bucket_index(const struct bucket_table *tbl, u32 hash)
 {
-	u32 h;
-
-	h = ht->p.hashfn(key, len, ht->p.hash_rnd);
-
-	return h & (hsize - 1);
-}
-
-/**
- * rhashtable_hashfn - compute hash for key of given length
- * @ht:		hash table to compute for
- * @key:	pointer to key
- * @len:	length of key
- *
- * Computes the hash value using the hash function provided in the 'hashfn'
- * of struct rhashtable_params. The returned value is guaranteed to be
- * smaller than the number of buckets in the hash table.
- */
-u32 rhashtable_hashfn(const struct rhashtable *ht, const void *key, u32 len)
-{
-	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
-
-	return __hashfn(ht, key, len, tbl->size);
+	return hash & (tbl->size - 1);
 }
-EXPORT_SYMBOL_GPL(rhashtable_hashfn);
 
-static u32 obj_hashfn(const struct rhashtable *ht, const void *ptr, u32 hsize)
+static u32 obj_raw_hashfn(const struct rhashtable *ht, const void *ptr)
 {
-	if (unlikely(!ht->p.key_len)) {
-		u32 h;
-
-		h = ht->p.obj_hashfn(ptr, ht->p.hash_rnd);
+	u32 hash;
 
-		return h & (hsize - 1);
-	}
+	if (unlikely(!ht->p.key_len))
+		hash = ht->p.obj_hashfn(ptr, ht->p.hash_rnd);
+	else
+		hash = ht->p.hashfn(ptr + ht->p.key_offset, ht->p.key_len,
+				    ht->p.hash_rnd);
 
-	return __hashfn(ht, ptr + ht->p.key_offset, ht->p.key_len, hsize);
+	return hash;
 }
 
-/**
- * rhashtable_obj_hashfn - compute hash for hashed object
- * @ht:		hash table to compute for
- * @ptr:	pointer to hashed object
- *
- * Computes the hash value using the hash function `hashfn` respectively
- * 'obj_hashfn' depending on whether the hash table is set up to work with
- * a fixed length key. The returned value is guaranteed to be smaller than
- * the number of buckets in the hash table.
- */
-u32 rhashtable_obj_hashfn(const struct rhashtable *ht, void *ptr)
+static u32 key_hashfn(const struct rhashtable *ht, const void *key, u32 len)
 {
 	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
+	u32 hash;
+
+	hash = ht->p.hashfn(key, len, ht->p.hash_rnd);
 
-	return obj_hashfn(ht, ptr, tbl->size);
+	return rht_bucket_index(tbl, hash);
 }
-EXPORT_SYMBOL_GPL(rhashtable_obj_hashfn);
 
 static u32 head_hashfn(const struct rhashtable *ht,
-		       const struct rhash_head *he, u32 hsize)
+		       const struct bucket_table *tbl,
+		       const struct rhash_head *he)
 {
-	return obj_hashfn(ht, rht_obj(ht, he), hsize);
+	return rht_bucket_index(tbl, obj_raw_hashfn(ht, rht_obj(ht, he)));
 }
 
 static struct bucket_table *bucket_table_alloc(size_t nbuckets)
@@ -170,9 +140,9 @@ static void hashtable_chain_unzip(const struct rhashtable *ht,
 	 * reaches a node that doesn't hash to the same bucket as the
 	 * previous node p. Call the previous node p;
 	 */
-	h = head_hashfn(ht, p, new_tbl->size);
+	h = head_hashfn(ht, new_tbl, p);
 	rht_for_each(he, p->next, ht) {
-		if (head_hashfn(ht, he, new_tbl->size) != h)
+		if (head_hashfn(ht, new_tbl, he) != h)
 			break;
 		p = he;
 	}
@@ -184,7 +154,7 @@ static void hashtable_chain_unzip(const struct rhashtable *ht,
 	next = NULL;
 	if (he) {
 		rht_for_each(he, he->next, ht) {
-			if (head_hashfn(ht, he, new_tbl->size) == h) {
+			if (head_hashfn(ht, new_tbl, he) == h) {
 				next = he;
 				break;
 			}
@@ -237,9 +207,9 @@ int rhashtable_expand(struct rhashtable *ht)
 	 * single imprecise chain.
 	 */
 	for (i = 0; i < new_tbl->size; i++) {
-		h = i & (old_tbl->size - 1);
+		h = rht_bucket_index(old_tbl, i);
 		rht_for_each(he, old_tbl->buckets[h], ht) {
-			if (head_hashfn(ht, he, new_tbl->size) == i) {
+			if (head_hashfn(ht, new_tbl, he) == i) {
 				RCU_INIT_POINTER(new_tbl->buckets[i], he);
 				break;
 			}
@@ -353,7 +323,7 @@ void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
 
 	ASSERT_RHT_MUTEX(ht);
 
-	hash = head_hashfn(ht, obj, tbl->size);
+	hash = head_hashfn(ht, tbl, obj);
 	RCU_INIT_POINTER(obj->next, tbl->buckets[hash]);
 	rcu_assign_pointer(tbl->buckets[hash], obj);
 	ht->nelems++;
@@ -413,7 +383,7 @@ bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
 
 	ASSERT_RHT_MUTEX(ht);
 
-	h = head_hashfn(ht, obj, tbl->size);
+	h = head_hashfn(ht, tbl, obj);
 
 	pprev = &tbl->buckets[h];
 	rht_for_each(he, tbl->buckets[h], ht) {
@@ -452,7 +422,7 @@ void *rhashtable_lookup(const struct rhashtable *ht, const void *key)
 
 	BUG_ON(!ht->p.key_len);
 
-	h = __hashfn(ht, key, ht->p.key_len, tbl->size);
+	h = key_hashfn(ht, key, ht->p.key_len);
 	rht_for_each_rcu(he, tbl->buckets[h], ht) {
 		if (memcmp(rht_obj(ht, he) + ht->p.key_offset, key,
 			   ht->p.key_len))
@@ -467,7 +437,7 @@ EXPORT_SYMBOL_GPL(rhashtable_lookup);
 /**
  * rhashtable_lookup_compare - search hash table with compare function
  * @ht:		hash table
- * @hash:	hash value of desired entry
+ * @key:	the pointer to the key
  * @compare:	compare function, must return true on match
  * @arg:	argument passed on to compare function
  *
@@ -479,15 +449,14 @@ EXPORT_SYMBOL_GPL(rhashtable_lookup);
  *
  * Returns the first entry on which the compare function returned true.
  */
-void *rhashtable_lookup_compare(const struct rhashtable *ht, u32 hash,
+void *rhashtable_lookup_compare(const struct rhashtable *ht, const void *key,
 				bool (*compare)(void *, void *), void *arg)
 {
 	const struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
 	struct rhash_head *he;
+	u32 hash;
 
-	if (unlikely(hash >= tbl->size))
-		return NULL;
-
+	hash = key_hashfn(ht, key, ht->p.key_len);
 	rht_for_each_rcu(he, tbl->buckets[hash], ht) {
 		if (!compare(rht_obj(ht, he), arg))
 			continue;
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 1e316ce..614ee09 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -94,28 +94,40 @@ static void nft_hash_remove(const struct nft_set *set,
 	kfree(he);
 }
 
+struct nft_compare_arg {
+	const struct nft_set *set;
+	struct nft_set_elem *elem;
+};
+
+static bool nft_hash_compare(void *ptr, void *arg)
+{
+	struct nft_hash_elem *he = ptr;
+	struct nft_compare_arg *x = arg;
+
+	if (!nft_data_cmp(&he->key, &x->elem->key, x->set->klen)) {
+		x->elem->cookie = &he->node;
+		x->elem->flags = 0;
+		if (x->set->flags & NFT_SET_MAP)
+			nft_data_copy(&x->elem->data, he->data);
+
+		return true;
+	}
+
+	return false;
+}
+
 static int nft_hash_get(const struct nft_set *set, struct nft_set_elem *elem)
 {
 	const struct rhashtable *priv = nft_set_priv(set);
-	const struct bucket_table *tbl = rht_dereference_rcu(priv->tbl, priv);
-	struct rhash_head __rcu * const *pprev;
-	struct nft_hash_elem *he;
-	u32 h;
-
-	h = rhashtable_hashfn(priv, &elem->key, set->klen);
-	pprev = &tbl->buckets[h];
-	rht_for_each_entry_rcu(he, tbl->buckets[h], node) {
-		if (nft_data_cmp(&he->key, &elem->key, set->klen)) {
-			pprev = &he->node.next;
-			continue;
-		}
+	struct nft_compare_arg arg = {
+		.set = set,
+		.elem = elem,
+	};
 
-		elem->cookie = (void *)pprev;
-		elem->flags = 0;
-		if (set->flags & NFT_SET_MAP)
-			nft_data_copy(&elem->data, he->data);
+	if (rhashtable_lookup_compare(priv, &elem->key,
+				      &nft_hash_compare, &arg))
 		return 0;
-	}
+
 	return -ENOENT;
 }
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ef5f77b..dc8354b 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1022,11 +1022,8 @@ static struct sock *__netlink_lookup(struct netlink_table *table, u32 portid,
 		.net = net,
 		.portid = portid,
 	};
-	u32 hash;
 
-	hash = rhashtable_hashfn(&table->hash, &portid, sizeof(portid));
-
-	return rhashtable_lookup_compare(&table->hash, hash,
+	return rhashtable_lookup_compare(&table->hash, &portid,
 					 &netlink_compare, &arg);
 }
 
-- 
1.9.3
