From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/5] rhashtable: Remove gfp_flags from insert and remove functions
Date: Mon, 15 Sep 2014 14:18:00 +0200
Message-ID: <bd3aa4282e89b022620225101ab491e344852f5f.1410782841.git.tgraf@suug.ch>
References: <cover.1410782841.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com, john.r.fastabend@intel.com,
	kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1410782841.git.tgraf@suug.ch>
In-Reply-To: <cover.1410782841.git.tgraf@suug.ch>
References: <cover.1410782841.git.tgraf@suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As the expansion/shrinking is moved to a worker thread, no allocations
will be performed anymore.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h | 10 +++++-----
 lib/rhashtable.c           | 41 +++++++++++++++++------------------------
 net/netfilter/nft_hash.c   |  4 ++--
 net/netlink/af_netlink.c   |  4 ++--
 4 files changed, 26 insertions(+), 33 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index fb298e9d..942fa44 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -96,16 +96,16 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params);
 u32 rhashtable_hashfn(const struct rhashtable *ht, const void *key, u32 len);
 u32 rhashtable_obj_hashfn(const struct rhashtable *ht, void *ptr);
 
-void rhashtable_insert(struct rhashtable *ht, struct rhash_head *node, gfp_t);
-bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *node, gfp_t);
+void rhashtable_insert(struct rhashtable *ht, struct rhash_head *node);
+bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *node);
 void rhashtable_remove_pprev(struct rhashtable *ht, struct rhash_head *obj,
-			     struct rhash_head __rcu **pprev, gfp_t flags);
+			     struct rhash_head __rcu **pprev);
 
 bool rht_grow_above_75(const struct rhashtable *ht, size_t new_size);
 bool rht_shrink_below_30(const struct rhashtable *ht, size_t new_size);
 
-int rhashtable_expand(struct rhashtable *ht, gfp_t flags);
-int rhashtable_shrink(struct rhashtable *ht, gfp_t flags);
+int rhashtable_expand(struct rhashtable *ht);
+int rhashtable_shrink(struct rhashtable *ht);
 
 void *rhashtable_lookup(const struct rhashtable *ht, const void *key);
 void *rhashtable_lookup_compare(const struct rhashtable *ht, u32 hash,
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 8dfec3f..c133d82 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -108,13 +108,13 @@ static u32 head_hashfn(const struct rhashtable *ht,
 	return obj_hashfn(ht, rht_obj(ht, he), hsize);
 }
 
-static struct bucket_table *bucket_table_alloc(size_t nbuckets, gfp_t flags)
+static struct bucket_table *bucket_table_alloc(size_t nbuckets)
 {
 	struct bucket_table *tbl;
 	size_t size;
 
 	size = sizeof(*tbl) + nbuckets * sizeof(tbl->buckets[0]);
-	tbl = kzalloc(size, flags);
+	tbl = kzalloc(size, GFP_KERNEL);
 	if (tbl == NULL)
 		tbl = vzalloc(size);
 
@@ -201,7 +201,6 @@ static void hashtable_chain_unzip(const struct rhashtable *ht,
 /**
  * rhashtable_expand - Expand hash table while allowing concurrent lookups
  * @ht:		the hash table to expand
- * @flags:	allocation flags
  *
  * A secondary bucket array is allocated and the hash entries are migrated
  * while keeping them on both lists until the end of the RCU grace period.
@@ -212,7 +211,7 @@ static void hashtable_chain_unzip(const struct rhashtable *ht,
  * The caller must ensure that no concurrent table mutations take place.
  * It is however valid to have concurrent lookups if they are RCU protected.
  */
-int rhashtable_expand(struct rhashtable *ht, gfp_t flags)
+int rhashtable_expand(struct rhashtable *ht)
 {
 	struct bucket_table *new_tbl, *old_tbl = rht_dereference(ht->tbl, ht);
 	struct rhash_head *he;
@@ -224,7 +223,7 @@ int rhashtable_expand(struct rhashtable *ht, gfp_t flags)
 	if (ht->p.max_shift && ht->shift >= ht->p.max_shift)
 		return 0;
 
-	new_tbl = bucket_table_alloc(old_tbl->size * 2, flags);
+	new_tbl = bucket_table_alloc(old_tbl->size * 2);
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
@@ -282,7 +281,6 @@ EXPORT_SYMBOL_GPL(rhashtable_expand);
 /**
  * rhashtable_shrink - Shrink hash table while allowing concurrent lookups
  * @ht:		the hash table to shrink
- * @flags:	allocation flags
  *
  * This function may only be called in a context where it is safe to call
  * synchronize_rcu(), e.g. not within a rcu_read_lock() section.
@@ -290,7 +288,7 @@ EXPORT_SYMBOL_GPL(rhashtable_expand);
  * The caller must ensure that no concurrent table mutations take place.
  * It is however valid to have concurrent lookups if they are RCU protected.
  */
-int rhashtable_shrink(struct rhashtable *ht, gfp_t flags)
+int rhashtable_shrink(struct rhashtable *ht)
 {
 	struct bucket_table *ntbl, *tbl = rht_dereference(ht->tbl, ht);
 	struct rhash_head __rcu **pprev;
@@ -301,7 +299,7 @@ int rhashtable_shrink(struct rhashtable *ht, gfp_t flags)
 	if (ht->shift <= ht->p.min_shift)
 		return 0;
 
-	ntbl = bucket_table_alloc(tbl->size / 2, flags);
+	ntbl = bucket_table_alloc(tbl->size / 2);
 	if (ntbl == NULL)
 		return -ENOMEM;
 
@@ -342,7 +340,6 @@ EXPORT_SYMBOL_GPL(rhashtable_shrink);
  * rhashtable_insert - insert object into hash hash table
  * @ht:		hash table
  * @obj:	pointer to hash head inside object
- * @flags:	allocation flags (table expansion)
  *
  * Will automatically grow the table via rhashtable_expand() if the the
  * grow_decision function specified at rhashtable_init() returns true.
@@ -350,8 +347,7 @@ EXPORT_SYMBOL_GPL(rhashtable_shrink);
  * The caller must ensure that no concurrent table mutations occur. It is
  * however valid to have concurrent lookups if they are RCU protected.
  */
-void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
-		       gfp_t flags)
+void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
 {
 	struct bucket_table *tbl = rht_dereference(ht->tbl, ht);
 	u32 hash;
@@ -364,7 +360,7 @@ void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 	ht->nelems++;
 
 	if (ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size))
-		rhashtable_expand(ht, flags);
+		rhashtable_expand(ht);
 }
 EXPORT_SYMBOL_GPL(rhashtable_insert);
 
@@ -373,14 +369,13 @@ EXPORT_SYMBOL_GPL(rhashtable_insert);
  * @ht:		hash table
  * @obj:	pointer to hash head inside object
  * @pprev:	pointer to previous element
- * @flags:	allocation flags (table expansion)
  *
  * Identical to rhashtable_remove() but caller is alreayd aware of the element
  * in front of the element to be deleted. This is in particular useful for
  * deletion when combined with walking or lookup.
  */
 void rhashtable_remove_pprev(struct rhashtable *ht, struct rhash_head *obj,
-			     struct rhash_head __rcu **pprev, gfp_t flags)
+			     struct rhash_head __rcu **pprev)
 {
 	struct bucket_table *tbl = rht_dereference(ht->tbl, ht);
 
@@ -391,7 +386,7 @@ void rhashtable_remove_pprev(struct rhashtable *ht, struct rhash_head *obj,
 
 	if (ht->p.shrink_decision &&
 	    ht->p.shrink_decision(ht, tbl->size))
-		rhashtable_shrink(ht, flags);
+		rhashtable_shrink(ht);
 }
 EXPORT_SYMBOL_GPL(rhashtable_remove_pprev);
 
@@ -399,7 +394,6 @@ EXPORT_SYMBOL_GPL(rhashtable_remove_pprev);
  * rhashtable_remove - remove object from hash table
  * @ht:		hash table
  * @obj:	pointer to hash head inside object
- * @flags:	allocation flags (table expansion)
  *
  * Since the hash chain is single linked, the removal operation needs to
  * walk the bucket chain upon removal. The removal operation is thus
@@ -411,8 +405,7 @@ EXPORT_SYMBOL_GPL(rhashtable_remove_pprev);
  * The caller must ensure that no concurrent table mutations occur. It is
  * however valid to have concurrent lookups if they are RCU protected.
  */
-bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj,
-		       gfp_t flags)
+bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
 {
 	struct bucket_table *tbl = rht_dereference(ht->tbl, ht);
 	struct rhash_head __rcu **pprev;
@@ -430,7 +423,7 @@ bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj,
 			continue;
 		}
 
-		rhashtable_remove_pprev(ht, he, pprev, flags);
+		rhashtable_remove_pprev(ht, he, pprev);
 		return true;
 	}
 
@@ -573,7 +566,7 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	if (params->nelem_hint)
 		size = rounded_hashtable_size(params);
 
-	tbl = bucket_table_alloc(size, GFP_KERNEL);
+	tbl = bucket_table_alloc(size);
 	if (tbl == NULL)
 		return -ENOMEM;
 
@@ -708,7 +701,7 @@ static int __init test_rhashtable(struct rhashtable *ht)
 		obj->ptr = TEST_PTR;
 		obj->value = i * 2;
 
-		rhashtable_insert(ht, &obj->node, GFP_KERNEL);
+		rhashtable_insert(ht, &obj->node);
 	}
 
 	rcu_read_lock();
@@ -719,7 +712,7 @@ static int __init test_rhashtable(struct rhashtable *ht)
 
 	for (i = 0; i < TEST_NEXPANDS; i++) {
 		pr_info("  Table expansion iteration %u...\n", i);
-		rhashtable_expand(ht, GFP_KERNEL);
+		rhashtable_expand(ht);
 
 		rcu_read_lock();
 		pr_info("  Verifying lookups...\n");
@@ -729,7 +722,7 @@ static int __init test_rhashtable(struct rhashtable *ht)
 
 	for (i = 0; i < TEST_NEXPANDS; i++) {
 		pr_info("  Table shrinkage iteration %u...\n", i);
-		rhashtable_shrink(ht, GFP_KERNEL);
+		rhashtable_shrink(ht);
 
 		rcu_read_lock();
 		pr_info("  Verifying lookups...\n");
@@ -744,7 +737,7 @@ static int __init test_rhashtable(struct rhashtable *ht)
 		obj = rhashtable_lookup(ht, &key);
 		BUG_ON(!obj);
 
-		rhashtable_remove(ht, &obj->node, GFP_KERNEL);
+		rhashtable_remove(ht, &obj->node);
 		kfree(obj);
 	}
 
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 28fb8f3..b52873c 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -65,7 +65,7 @@ static int nft_hash_insert(const struct nft_set *set,
 	if (set->flags & NFT_SET_MAP)
 		nft_data_copy(he->data, &elem->data);
 
-	rhashtable_insert(priv, &he->node, GFP_KERNEL);
+	rhashtable_insert(priv, &he->node);
 
 	return 0;
 }
@@ -88,7 +88,7 @@ static void nft_hash_remove(const struct nft_set *set,
 	pprev = elem->cookie;
 	he = rht_dereference((*pprev), priv);
 
-	rhashtable_remove_pprev(priv, he, pprev, GFP_KERNEL);
+	rhashtable_remove_pprev(priv, he, pprev);
 
 	synchronize_rcu();
 	kfree(he);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index c416725..a1e6104 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1082,7 +1082,7 @@ static int netlink_insert(struct sock *sk, struct net *net, u32 portid)
 
 	nlk_sk(sk)->portid = portid;
 	sock_hold(sk);
-	rhashtable_insert(&table->hash, &nlk_sk(sk)->node, GFP_KERNEL);
+	rhashtable_insert(&table->hash, &nlk_sk(sk)->node);
 	err = 0;
 err:
 	mutex_unlock(&nl_sk_hash_lock);
@@ -1095,7 +1095,7 @@ static void netlink_remove(struct sock *sk)
 
 	mutex_lock(&nl_sk_hash_lock);
 	table = &nl_table[sk->sk_protocol];
-	if (rhashtable_remove(&table->hash, &nlk_sk(sk)->node, GFP_KERNEL)) {
+	if (rhashtable_remove(&table->hash, &nlk_sk(sk)->node)) {
 		WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
 		__sock_put(sk);
 	}
-- 
1.9.3
