From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/29] netfilter: nft_set_hash: use nft_rhash prefix for resizable set backend
Date: Fri, 30 Jun 2017 00:53:10 +0200
Message-ID: <1498776807-11124-13-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch prepares the introduction of a non-resizable hashtable
implementation that is significantly faster.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_set_hash.c | 212 +++++++++++++++++++++----------------------
 1 file changed, 106 insertions(+), 106 deletions(-)

diff --git a/net/netfilter/nft_set_hash.c b/net/netfilter/nft_set_hash.c
index 1f1cc33895fd..7c21e3da0d88 100644
--- a/net/netfilter/nft_set_hash.c
+++ b/net/netfilter/nft_set_hash.c
@@ -22,43 +22,43 @@
 #include <net/netfilter/nf_tables.h>
 
 /* We target a hash table size of 4, element hint is 75% of final size */
-#define NFT_HASH_ELEMENT_HINT 3
+#define NFT_RHASH_ELEMENT_HINT 3
 
-struct nft_hash {
+struct nft_rhash {
 	struct rhashtable		ht;
 	struct delayed_work		gc_work;
 };
 
-struct nft_hash_elem {
+struct nft_rhash_elem {
 	struct rhash_head		node;
 	struct nft_set_ext		ext;
 };
 
-struct nft_hash_cmp_arg {
+struct nft_rhash_cmp_arg {
 	const struct nft_set		*set;
 	const u32			*key;
 	u8				genmask;
 };
 
-static inline u32 nft_hash_key(const void *data, u32 len, u32 seed)
+static inline u32 nft_rhash_key(const void *data, u32 len, u32 seed)
 {
-	const struct nft_hash_cmp_arg *arg = data;
+	const struct nft_rhash_cmp_arg *arg = data;
 
 	return jhash(arg->key, len, seed);
 }
 
-static inline u32 nft_hash_obj(const void *data, u32 len, u32 seed)
+static inline u32 nft_rhash_obj(const void *data, u32 len, u32 seed)
 {
-	const struct nft_hash_elem *he = data;
+	const struct nft_rhash_elem *he = data;
 
 	return jhash(nft_set_ext_key(&he->ext), len, seed);
 }
 
-static inline int nft_hash_cmp(struct rhashtable_compare_arg *arg,
-			       const void *ptr)
+static inline int nft_rhash_cmp(struct rhashtable_compare_arg *arg,
+				const void *ptr)
 {
-	const struct nft_hash_cmp_arg *x = arg->key;
-	const struct nft_hash_elem *he = ptr;
+	const struct nft_rhash_cmp_arg *x = arg->key;
+	const struct nft_rhash_elem *he = ptr;
 
 	if (memcmp(nft_set_ext_key(&he->ext), x->key, x->set->klen))
 		return 1;
@@ -69,49 +69,49 @@ static inline int nft_hash_cmp(struct rhashtable_compare_arg *arg,
 	return 0;
 }
 
-static const struct rhashtable_params nft_hash_params = {
-	.head_offset		= offsetof(struct nft_hash_elem, node),
-	.hashfn			= nft_hash_key,
-	.obj_hashfn		= nft_hash_obj,
-	.obj_cmpfn		= nft_hash_cmp,
+static const struct rhashtable_params nft_rhash_params = {
+	.head_offset		= offsetof(struct nft_rhash_elem, node),
+	.hashfn			= nft_rhash_key,
+	.obj_hashfn		= nft_rhash_obj,
+	.obj_cmpfn		= nft_rhash_cmp,
 	.automatic_shrinking	= true,
 };
 
-static bool nft_hash_lookup(const struct net *net, const struct nft_set *set,
-			    const u32 *key, const struct nft_set_ext **ext)
+static bool nft_rhash_lookup(const struct net *net, const struct nft_set *set,
+			     const u32 *key, const struct nft_set_ext **ext)
 {
-	struct nft_hash *priv = nft_set_priv(set);
-	const struct nft_hash_elem *he;
-	struct nft_hash_cmp_arg arg = {
+	struct nft_rhash *priv = nft_set_priv(set);
+	const struct nft_rhash_elem *he;
+	struct nft_rhash_cmp_arg arg = {
 		.genmask = nft_genmask_cur(net),
 		.set	 = set,
 		.key	 = key,
 	};
 
-	he = rhashtable_lookup_fast(&priv->ht, &arg, nft_hash_params);
+	he = rhashtable_lookup_fast(&priv->ht, &arg, nft_rhash_params);
 	if (he != NULL)
 		*ext = &he->ext;
 
 	return !!he;
 }
 
-static bool nft_hash_update(struct nft_set *set, const u32 *key,
-			    void *(*new)(struct nft_set *,
-					 const struct nft_expr *,
-					 struct nft_regs *regs),
-			    const struct nft_expr *expr,
-			    struct nft_regs *regs,
-			    const struct nft_set_ext **ext)
+static bool nft_rhash_update(struct nft_set *set, const u32 *key,
+			     void *(*new)(struct nft_set *,
+					  const struct nft_expr *,
+					  struct nft_regs *regs),
+			     const struct nft_expr *expr,
+			     struct nft_regs *regs,
+			     const struct nft_set_ext **ext)
 {
-	struct nft_hash *priv = nft_set_priv(set);
-	struct nft_hash_elem *he, *prev;
-	struct nft_hash_cmp_arg arg = {
+	struct nft_rhash *priv = nft_set_priv(set);
+	struct nft_rhash_elem *he, *prev;
+	struct nft_rhash_cmp_arg arg = {
 		.genmask = NFT_GENMASK_ANY,
 		.set	 = set,
 		.key	 = key,
 	};
 
-	he = rhashtable_lookup_fast(&priv->ht, &arg, nft_hash_params);
+	he = rhashtable_lookup_fast(&priv->ht, &arg, nft_rhash_params);
 	if (he != NULL)
 		goto out;
 
@@ -120,7 +120,7 @@ static bool nft_hash_update(struct nft_set *set, const u32 *key,
 		goto err1;
 
 	prev = rhashtable_lookup_get_insert_key(&priv->ht, &arg, &he->node,
-						nft_hash_params);
+						nft_rhash_params);
 	if (IS_ERR(prev))
 		goto err2;
 
@@ -140,21 +140,21 @@ static bool nft_hash_update(struct nft_set *set, const u32 *key,
 	return false;
 }
 
-static int nft_hash_insert(const struct net *net, const struct nft_set *set,
-			   const struct nft_set_elem *elem,
-			   struct nft_set_ext **ext)
+static int nft_rhash_insert(const struct net *net, const struct nft_set *set,
+			    const struct nft_set_elem *elem,
+			    struct nft_set_ext **ext)
 {
-	struct nft_hash *priv = nft_set_priv(set);
-	struct nft_hash_elem *he = elem->priv;
-	struct nft_hash_cmp_arg arg = {
+	struct nft_rhash *priv = nft_set_priv(set);
+	struct nft_rhash_elem *he = elem->priv;
+	struct nft_rhash_cmp_arg arg = {
 		.genmask = nft_genmask_next(net),
 		.set	 = set,
 		.key	 = elem->key.val.data,
 	};
-	struct nft_hash_elem *prev;
+	struct nft_rhash_elem *prev;
 
 	prev = rhashtable_lookup_get_insert_key(&priv->ht, &arg, &he->node,
-					       nft_hash_params);
+						nft_rhash_params);
 	if (IS_ERR(prev))
 		return PTR_ERR(prev);
 	if (prev) {
@@ -164,19 +164,19 @@ static int nft_hash_insert(const struct net *net, const struct nft_set *set,
 	return 0;
 }
 
-static void nft_hash_activate(const struct net *net, const struct nft_set *set,
-			      const struct nft_set_elem *elem)
+static void nft_rhash_activate(const struct net *net, const struct nft_set *set,
+			       const struct nft_set_elem *elem)
 {
-	struct nft_hash_elem *he = elem->priv;
+	struct nft_rhash_elem *he = elem->priv;
 
 	nft_set_elem_change_active(net, set, &he->ext);
 	nft_set_elem_clear_busy(&he->ext);
 }
 
-static bool nft_hash_flush(const struct net *net,
-			   const struct nft_set *set, void *priv)
+static bool nft_rhash_flush(const struct net *net,
+			    const struct nft_set *set, void *priv)
 {
-	struct nft_hash_elem *he = priv;
+	struct nft_rhash_elem *he = priv;
 
 	if (!nft_set_elem_mark_busy(&he->ext) ||
 	    !nft_is_active(net, &he->ext)) {
@@ -186,22 +186,22 @@ static bool nft_hash_flush(const struct net *net,
 	return false;
 }
 
-static void *nft_hash_deactivate(const struct net *net,
-				 const struct nft_set *set,
-				 const struct nft_set_elem *elem)
+static void *nft_rhash_deactivate(const struct net *net,
+				  const struct nft_set *set,
+				  const struct nft_set_elem *elem)
 {
-	struct nft_hash *priv = nft_set_priv(set);
-	struct nft_hash_elem *he;
-	struct nft_hash_cmp_arg arg = {
+	struct nft_rhash *priv = nft_set_priv(set);
+	struct nft_rhash_elem *he;
+	struct nft_rhash_cmp_arg arg = {
 		.genmask = nft_genmask_next(net),
 		.set	 = set,
 		.key	 = elem->key.val.data,
 	};
 
 	rcu_read_lock();
-	he = rhashtable_lookup_fast(&priv->ht, &arg, nft_hash_params);
+	he = rhashtable_lookup_fast(&priv->ht, &arg, nft_rhash_params);
 	if (he != NULL &&
-	    !nft_hash_flush(net, set, he))
+	    !nft_rhash_flush(net, set, he))
 		he = NULL;
 
 	rcu_read_unlock();
@@ -209,21 +209,21 @@ static void *nft_hash_deactivate(const struct net *net,
 	return he;
 }
 
-static void nft_hash_remove(const struct net *net,
-			    const struct nft_set *set,
-			    const struct nft_set_elem *elem)
+static void nft_rhash_remove(const struct net *net,
+			     const struct nft_set *set,
+			     const struct nft_set_elem *elem)
 {
-	struct nft_hash *priv = nft_set_priv(set);
-	struct nft_hash_elem *he = elem->priv;
+	struct nft_rhash *priv = nft_set_priv(set);
+	struct nft_rhash_elem *he = elem->priv;
 
-	rhashtable_remove_fast(&priv->ht, &he->node, nft_hash_params);
+	rhashtable_remove_fast(&priv->ht, &he->node, nft_rhash_params);
 }
 
-static void nft_hash_walk(const struct nft_ctx *ctx, struct nft_set *set,
-			  struct nft_set_iter *iter)
+static void nft_rhash_walk(const struct nft_ctx *ctx, struct nft_set *set,
+			   struct nft_set_iter *iter)
 {
-	struct nft_hash *priv = nft_set_priv(set);
-	struct nft_hash_elem *he;
+	struct nft_rhash *priv = nft_set_priv(set);
+	struct nft_rhash_elem *he;
 	struct rhashtable_iter hti;
 	struct nft_set_elem elem;
 	int err;
@@ -272,16 +272,16 @@ static void nft_hash_walk(const struct nft_ctx *ctx, struct nft_set *set,
 	rhashtable_walk_exit(&hti);
 }
 
-static void nft_hash_gc(struct work_struct *work)
+static void nft_rhash_gc(struct work_struct *work)
 {
 	struct nft_set *set;
-	struct nft_hash_elem *he;
-	struct nft_hash *priv;
+	struct nft_rhash_elem *he;
+	struct nft_rhash *priv;
 	struct nft_set_gc_batch *gcb = NULL;
 	struct rhashtable_iter hti;
 	int err;
 
-	priv = container_of(work, struct nft_hash, gc_work.work);
+	priv = container_of(work, struct nft_rhash, gc_work.work);
 	set  = nft_set_container_of(priv);
 
 	err = rhashtable_walk_init(&priv->ht, &hti, GFP_KERNEL);
@@ -307,7 +307,7 @@ static void nft_hash_gc(struct work_struct *work)
 		gcb = nft_set_gc_batch_check(set, gcb, GFP_ATOMIC);
 		if (gcb == NULL)
 			goto out;
-		rhashtable_remove_fast(&priv->ht, &he->node, nft_hash_params);
+		rhashtable_remove_fast(&priv->ht, &he->node, nft_rhash_params);
 		atomic_dec(&set->nelems);
 		nft_set_gc_batch_add(gcb, he);
 	}
@@ -321,55 +321,55 @@ static void nft_hash_gc(struct work_struct *work)
 			   nft_set_gc_interval(set));
 }
 
-static unsigned int nft_hash_privsize(const struct nlattr * const nla[])
+static unsigned int nft_rhash_privsize(const struct nlattr * const nla[])
 {
-	return sizeof(struct nft_hash);
+	return sizeof(struct nft_rhash);
 }
 
-static int nft_hash_init(const struct nft_set *set,
-			 const struct nft_set_desc *desc,
-			 const struct nlattr * const tb[])
+static int nft_rhash_init(const struct nft_set *set,
+			  const struct nft_set_desc *desc,
+			  const struct nlattr * const tb[])
 {
-	struct nft_hash *priv = nft_set_priv(set);
-	struct rhashtable_params params = nft_hash_params;
+	struct nft_rhash *priv = nft_set_priv(set);
+	struct rhashtable_params params = nft_rhash_params;
 	int err;
 
-	params.nelem_hint = desc->size ?: NFT_HASH_ELEMENT_HINT;
+	params.nelem_hint = desc->size ?: NFT_RHASH_ELEMENT_HINT;
 	params.key_len	  = set->klen;
 
 	err = rhashtable_init(&priv->ht, &params);
 	if (err < 0)
 		return err;
 
-	INIT_DEFERRABLE_WORK(&priv->gc_work, nft_hash_gc);
+	INIT_DEFERRABLE_WORK(&priv->gc_work, nft_rhash_gc);
 	if (set->flags & NFT_SET_TIMEOUT)
 		queue_delayed_work(system_power_efficient_wq, &priv->gc_work,
 				   nft_set_gc_interval(set));
 	return 0;
 }
 
-static void nft_hash_elem_destroy(void *ptr, void *arg)
+static void nft_rhash_elem_destroy(void *ptr, void *arg)
 {
 	nft_set_elem_destroy(arg, ptr, true);
 }
 
-static void nft_hash_destroy(const struct nft_set *set)
+static void nft_rhash_destroy(const struct nft_set *set)
 {
-	struct nft_hash *priv = nft_set_priv(set);
+	struct nft_rhash *priv = nft_set_priv(set);
 
 	cancel_delayed_work_sync(&priv->gc_work);
-	rhashtable_free_and_destroy(&priv->ht, nft_hash_elem_destroy,
+	rhashtable_free_and_destroy(&priv->ht, nft_rhash_elem_destroy,
 				    (void *)set);
 }
 
-static bool nft_hash_estimate(const struct nft_set_desc *desc, u32 features,
-			      struct nft_set_estimate *est)
+static bool nft_rhash_estimate(const struct nft_set_desc *desc, u32 features,
+			       struct nft_set_estimate *est)
 {
 	if (desc->size)
-		est->size = sizeof(struct nft_hash) +
+		est->size = sizeof(struct nft_rhash) +
 			    roundup_pow_of_two(desc->size * 4 / 3) *
-			    sizeof(struct nft_hash_elem *) +
-			    desc->size * sizeof(struct nft_hash_elem);
+			    sizeof(struct nft_rhash_elem *) +
+			    desc->size * sizeof(struct nft_rhash_elem);
 	else
 		est->size = ~0;
 
@@ -379,32 +379,32 @@ static bool nft_hash_estimate(const struct nft_set_desc *desc, u32 features,
 	return true;
 }
 
-static struct nft_set_ops nft_hash_ops __read_mostly = {
-	.privsize       = nft_hash_privsize,
-	.elemsize	= offsetof(struct nft_hash_elem, ext),
-	.estimate	= nft_hash_estimate,
-	.init		= nft_hash_init,
-	.destroy	= nft_hash_destroy,
-	.insert		= nft_hash_insert,
-	.activate	= nft_hash_activate,
-	.deactivate	= nft_hash_deactivate,
-	.flush		= nft_hash_flush,
-	.remove		= nft_hash_remove,
-	.lookup		= nft_hash_lookup,
-	.update		= nft_hash_update,
-	.walk		= nft_hash_walk,
+static struct nft_set_ops nft_rhash_ops __read_mostly = {
+	.privsize       = nft_rhash_privsize,
+	.elemsize	= offsetof(struct nft_rhash_elem, ext),
+	.estimate	= nft_rhash_estimate,
+	.init		= nft_rhash_init,
+	.destroy	= nft_rhash_destroy,
+	.insert		= nft_rhash_insert,
+	.activate	= nft_rhash_activate,
+	.deactivate	= nft_rhash_deactivate,
+	.flush		= nft_rhash_flush,
+	.remove		= nft_rhash_remove,
+	.lookup		= nft_rhash_lookup,
+	.update		= nft_rhash_update,
+	.walk		= nft_rhash_walk,
 	.features	= NFT_SET_MAP | NFT_SET_OBJECT | NFT_SET_TIMEOUT,
 	.owner		= THIS_MODULE,
 };
 
 static int __init nft_hash_module_init(void)
 {
-	return nft_register_set(&nft_hash_ops);
+	return nft_register_set(&nft_rhash_ops);
 }
 
 static void __exit nft_hash_module_exit(void)
 {
-	nft_unregister_set(&nft_hash_ops);
+	nft_unregister_set(&nft_rhash_ops);
 }
 
 module_init(nft_hash_module_init);
-- 
2.1.4

