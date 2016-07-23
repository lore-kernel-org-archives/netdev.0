From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/25] netfilter: nf_tables: get rid of possible_net_t from set and basechain
Date: Sat, 23 Jul 2016 13:08:25 +0200
Message-ID: <1469272119-29942-12-git-send-email-pablo@netfilter.org>
References: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We can pass the netns pointer as parameter to the functions that need to
gain access to it. From basechains, I didn't find any client for this
field anymore so let's remove this too.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h | 21 +++++++++++----------
 net/netfilter/nf_tables_api.c     | 10 ++++------
 net/netfilter/nft_hash.c          | 20 ++++++++++----------
 net/netfilter/nft_lookup.c        |  2 +-
 net/netfilter/nft_rbtree.c        | 26 ++++++++++++++------------
 5 files changed, 40 insertions(+), 39 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 30c1d94..f2f1339 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -236,7 +236,8 @@ struct nft_expr;
  *	@features: features supported by the implementation
  */
 struct nft_set_ops {
-	bool				(*lookup)(const struct nft_set *set,
+	bool				(*lookup)(const struct net *net,
+						  const struct nft_set *set,
 						  const u32 *key,
 						  const struct nft_set_ext **ext);
 	bool				(*update)(struct nft_set *set,
@@ -248,11 +249,14 @@ struct nft_set_ops {
 						  struct nft_regs *regs,
 						  const struct nft_set_ext **ext);
 
-	int				(*insert)(const struct nft_set *set,
+	int				(*insert)(const struct net *net,
+						  const struct nft_set *set,
 						  const struct nft_set_elem *elem);
-	void				(*activate)(const struct nft_set *set,
+	void				(*activate)(const struct net *net,
+						    const struct nft_set *set,
 						    const struct nft_set_elem *elem);
-	void *				(*deactivate)(const struct nft_set *set,
+	void *				(*deactivate)(const struct net *net,
+						      const struct nft_set *set,
 						      const struct nft_set_elem *elem);
 	void				(*remove)(const struct nft_set *set,
 						  const struct nft_set_elem *elem);
@@ -295,7 +299,6 @@ void nft_unregister_set(struct nft_set_ops *ops);
  *	@udlen: user data length
  *	@udata: user data
  * 	@ops: set ops
- * 	@pnet: network namespace
  * 	@flags: set flags
  *	@genmask: generation mask
  * 	@klen: key length
@@ -318,7 +321,6 @@ struct nft_set {
 	unsigned char			*udata;
 	/* runtime data below here */
 	const struct nft_set_ops	*ops ____cacheline_aligned;
-	possible_net_t			pnet;
 	u16				flags:14,
 					genmask:2;
 	u8				klen;
@@ -804,7 +806,6 @@ struct nft_stats {
  *	struct nft_base_chain - nf_tables base chain
  *
  *	@ops: netfilter hook ops
- *	@pnet: net namespace that this chain belongs to
  *	@type: chain type
  *	@policy: default policy
  *	@stats: per-cpu chain stats
@@ -813,7 +814,6 @@ struct nft_stats {
  */
 struct nft_base_chain {
 	struct nf_hook_ops		ops[NFT_HOOK_OPS_MAX];
-	possible_net_t			pnet;
 	const struct nf_chain_type	*type;
 	u8				policy;
 	u8				flags;
@@ -1009,10 +1009,11 @@ static inline bool nft_set_elem_active(const struct nft_set_ext *ext,
 	return !(ext->genmask & genmask);
 }
 
-static inline void nft_set_elem_change_active(const struct nft_set *set,
+static inline void nft_set_elem_change_active(const struct net *net,
+					      const struct nft_set *set,
 					      struct nft_set_ext *ext)
 {
-	ext->genmask ^= nft_genmask_next(read_pnet(&set->pnet));
+	ext->genmask ^= nft_genmask_next(net);
 }
 
 /*
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 18b7f85..0211eae 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1405,7 +1405,6 @@ static int nf_tables_newchain(struct net *net, struct sock *nlsk,
 			rcu_assign_pointer(basechain->stats, stats);
 		}
 
-		write_pnet(&basechain->pnet, net);
 		basechain->type = type;
 		chain = &basechain->chain;
 
@@ -2841,7 +2840,6 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 	}
 
 	INIT_LIST_HEAD(&set->bindings);
-	write_pnet(&set->pnet, net);
 	set->ops   = ops;
 	set->ktype = ktype;
 	set->klen  = desc.klen;
@@ -3520,7 +3518,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 		goto err4;
 
 	ext->genmask = nft_genmask_cur(ctx->net) | NFT_SET_ELEM_BUSY_MASK;
-	err = set->ops->insert(set, &elem);
+	err = set->ops->insert(ctx->net, set, &elem);
 	if (err < 0)
 		goto err5;
 
@@ -3644,7 +3642,7 @@ static int nft_del_setelem(struct nft_ctx *ctx, struct nft_set *set,
 		goto err3;
 	}
 
-	priv = set->ops->deactivate(set, &elem);
+	priv = set->ops->deactivate(ctx->net, set, &elem);
 	if (priv == NULL) {
 		err = -ENOENT;
 		goto err4;
@@ -4018,7 +4016,7 @@ static int nf_tables_commit(struct net *net, struct sk_buff *skb)
 		case NFT_MSG_NEWSETELEM:
 			te = (struct nft_trans_elem *)trans->data;
 
-			te->set->ops->activate(te->set, &te->elem);
+			te->set->ops->activate(net, te->set, &te->elem);
 			nf_tables_setelem_notify(&trans->ctx, te->set,
 						 &te->elem,
 						 NFT_MSG_NEWSETELEM, 0);
@@ -4143,7 +4141,7 @@ static int nf_tables_abort(struct net *net, struct sk_buff *skb)
 		case NFT_MSG_DELSETELEM:
 			te = (struct nft_trans_elem *)trans->data;
 
-			te->set->ops->activate(te->set, &te->elem);
+			te->set->ops->activate(net, te->set, &te->elem);
 			te->set->ndeact--;
 
 			nft_trans_destroy(trans);
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index ea92481..564fa79 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -71,13 +71,13 @@ static inline int nft_hash_cmp(struct rhashtable_compare_arg *arg,
 	return 0;
 }
 
-static bool nft_hash_lookup(const struct nft_set *set, const u32 *key,
-			    const struct nft_set_ext **ext)
+static bool nft_hash_lookup(const struct net *net, const struct nft_set *set,
+			    const u32 *key, const struct nft_set_ext **ext)
 {
 	struct nft_hash *priv = nft_set_priv(set);
 	const struct nft_hash_elem *he;
 	struct nft_hash_cmp_arg arg = {
-		.genmask = nft_genmask_cur(read_pnet(&set->pnet)),
+		.genmask = nft_genmask_cur(net),
 		.set	 = set,
 		.key	 = key,
 	};
@@ -125,13 +125,13 @@ err1:
 	return false;
 }
 
-static int nft_hash_insert(const struct nft_set *set,
+static int nft_hash_insert(const struct net *net, const struct nft_set *set,
 			   const struct nft_set_elem *elem)
 {
 	struct nft_hash *priv = nft_set_priv(set);
 	struct nft_hash_elem *he = elem->priv;
 	struct nft_hash_cmp_arg arg = {
-		.genmask = nft_genmask_next(read_pnet(&set->pnet)),
+		.genmask = nft_genmask_next(net),
 		.set	 = set,
 		.key	 = elem->key.val.data,
 	};
@@ -140,20 +140,20 @@ static int nft_hash_insert(const struct nft_set *set,
 					    nft_hash_params);
 }
 
-static void nft_hash_activate(const struct nft_set *set,
+static void nft_hash_activate(const struct net *net, const struct nft_set *set,
 			      const struct nft_set_elem *elem)
 {
 	struct nft_hash_elem *he = elem->priv;
 
-	nft_set_elem_change_active(set, &he->ext);
+	nft_set_elem_change_active(net, set, &he->ext);
 	nft_set_elem_clear_busy(&he->ext);
 }
 
-static void *nft_hash_deactivate(const struct nft_set *set,
+static void *nft_hash_deactivate(const struct net *net,
+				 const struct nft_set *set,
 				 const struct nft_set_elem *elem)
 {
 	struct nft_hash *priv = nft_set_priv(set);
-	struct net *net = read_pnet(&set->pnet);
 	struct nft_hash_elem *he;
 	struct nft_hash_cmp_arg arg = {
 		.genmask = nft_genmask_next(net),
@@ -166,7 +166,7 @@ static void *nft_hash_deactivate(const struct nft_set *set,
 	if (he != NULL) {
 		if (!nft_set_elem_mark_busy(&he->ext) ||
 		    !nft_is_active(net, &he->ext))
-			nft_set_elem_change_active(set, &he->ext);
+			nft_set_elem_change_active(net, set, &he->ext);
 		else
 			he = NULL;
 	}
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index b8d18f5..e164325 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -35,7 +35,7 @@ static void nft_lookup_eval(const struct nft_expr *expr,
 	const struct nft_set_ext *ext;
 	bool found;
 
-	found = set->ops->lookup(set, &regs->data[priv->sreg], &ext) ^
+	found = set->ops->lookup(pkt->net, set, &regs->data[priv->sreg], &ext) ^
 		priv->invert;
 
 	if (!found) {
diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index c0f6387..6473936 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -41,13 +41,13 @@ static bool nft_rbtree_equal(const struct nft_set *set, const void *this,
 	return memcmp(this, nft_set_ext_key(&interval->ext), set->klen) == 0;
 }
 
-static bool nft_rbtree_lookup(const struct nft_set *set, const u32 *key,
-			      const struct nft_set_ext **ext)
+static bool nft_rbtree_lookup(const struct net *net, const struct nft_set *set,
+			      const u32 *key, const struct nft_set_ext **ext)
 {
 	const struct nft_rbtree *priv = nft_set_priv(set);
 	const struct nft_rbtree_elem *rbe, *interval = NULL;
+	u8 genmask = nft_genmask_cur(net);
 	const struct rb_node *parent;
-	u8 genmask = nft_genmask_cur(read_pnet(&set->pnet));
 	const void *this;
 	int d;
 
@@ -93,13 +93,13 @@ out:
 	return false;
 }
 
-static int __nft_rbtree_insert(const struct nft_set *set,
+static int __nft_rbtree_insert(const struct net *net, const struct nft_set *set,
 			       struct nft_rbtree_elem *new)
 {
 	struct nft_rbtree *priv = nft_set_priv(set);
+	u8 genmask = nft_genmask_next(net);
 	struct nft_rbtree_elem *rbe;
 	struct rb_node *parent, **p;
-	u8 genmask = nft_genmask_next(read_pnet(&set->pnet));
 	int d;
 
 	parent = NULL;
@@ -132,14 +132,14 @@ static int __nft_rbtree_insert(const struct nft_set *set,
 	return 0;
 }
 
-static int nft_rbtree_insert(const struct nft_set *set,
+static int nft_rbtree_insert(const struct net *net, const struct nft_set *set,
 			     const struct nft_set_elem *elem)
 {
 	struct nft_rbtree_elem *rbe = elem->priv;
 	int err;
 
 	spin_lock_bh(&nft_rbtree_lock);
-	err = __nft_rbtree_insert(set, rbe);
+	err = __nft_rbtree_insert(net, set, rbe);
 	spin_unlock_bh(&nft_rbtree_lock);
 
 	return err;
@@ -156,21 +156,23 @@ static void nft_rbtree_remove(const struct nft_set *set,
 	spin_unlock_bh(&nft_rbtree_lock);
 }
 
-static void nft_rbtree_activate(const struct nft_set *set,
+static void nft_rbtree_activate(const struct net *net,
+				const struct nft_set *set,
 				const struct nft_set_elem *elem)
 {
 	struct nft_rbtree_elem *rbe = elem->priv;
 
-	nft_set_elem_change_active(set, &rbe->ext);
+	nft_set_elem_change_active(net, set, &rbe->ext);
 }
 
-static void *nft_rbtree_deactivate(const struct nft_set *set,
+static void *nft_rbtree_deactivate(const struct net *net,
+				   const struct nft_set *set,
 				   const struct nft_set_elem *elem)
 {
 	const struct nft_rbtree *priv = nft_set_priv(set);
 	const struct rb_node *parent = priv->root.rb_node;
 	struct nft_rbtree_elem *rbe, *this = elem->priv;
-	u8 genmask = nft_genmask_next(read_pnet(&set->pnet));
+	u8 genmask = nft_genmask_next(net);
 	int d;
 
 	while (parent != NULL) {
@@ -196,7 +198,7 @@ static void *nft_rbtree_deactivate(const struct nft_set *set,
 				parent = parent->rb_right;
 				continue;
 			}
-			nft_set_elem_change_active(set, &rbe->ext);
+			nft_set_elem_change_active(net, set, &rbe->ext);
 			return rbe;
 		}
 	}
-- 
2.1.4

