From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/15] netfilter: nf_tables: implement set transaction support
Date: Thu, 26 Mar 2015 13:07:02 +0100
Message-ID: <1427371622-4466-16-git-send-email-pablo@netfilter.org>
References: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Set elements are the last object type not supporting transaction support.
Implement similar to the existing rule transactions:

The global transaction counter keeps track of two generations, current
and next. Each element contains a bitmask specifying in which generations
it is inactive.

New elements start out as inactive in the current generation and active
in the next. On commit, the previous next generation becomes the current
generation and the element becomes active. The bitmask is then cleared
to indicate that the element is active in all future generations. If the
transaction is aborted, the element is removed from the set before it
becomes active.

When removing an element, it gets marked as inactive in the next generation.
On commit the next generation becomes active and the therefor the element
inactive. It is then taken out of then set and released. On abort, the
element is marked as active for the next generation again.

Lookups ignore elements not active in the current generation.

The current set types (hash/rbtree) both use a field in the extension area
to store the generation mask. This (currently) does not require any
additional memory since we have some free space in there.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |   33 +++++++++++++++++++------
 net/netfilter/nf_tables_api.c     |   33 +++++++++++++++----------
 net/netfilter/nft_hash.c          |   38 +++++++++++++++++++++--------
 net/netfilter/nft_rbtree.c        |   48 +++++++++++++++++++++++++++++--------
 4 files changed, 112 insertions(+), 40 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 4c46a32..b8cd60d 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -138,15 +138,10 @@ struct nft_userdata {
 /**
  *	struct nft_set_elem - generic representation of set elements
  *
- *	@cookie: implementation specific element cookie
  *	@key: element key
  *	@priv: element private data and extensions
- *
- *	The cookie can be used to store a handle to the element for subsequent
- *	removal.
  */
 struct nft_set_elem {
-	void			*cookie;
 	struct nft_data		key;
 	void			*priv;
 };
@@ -207,6 +202,8 @@ struct nft_set_ext;
  *
  *	@lookup: look up an element within the set
  *	@insert: insert new element into set
+ *	@activate: activate new element in the next generation
+ *	@deactivate: deactivate element in the next generation
  *	@remove: remove element from set
  *	@walk: iterate over all set elemeennts
  *	@privsize: function to return size of set private data
@@ -221,10 +218,12 @@ struct nft_set_ops {
 	bool				(*lookup)(const struct nft_set *set,
 						  const struct nft_data *key,
 						  const struct nft_set_ext **ext);
-	int				(*get)(const struct nft_set *set,
-					       struct nft_set_elem *elem);
 	int				(*insert)(const struct nft_set *set,
 						  const struct nft_set_elem *elem);
+	void				(*activate)(const struct nft_set *set,
+						    const struct nft_set_elem *elem);
+	void *				(*deactivate)(const struct nft_set *set,
+						      const struct nft_set_elem *elem);
 	void				(*remove)(const struct nft_set *set,
 						  const struct nft_set_elem *elem);
 	void				(*walk)(const struct nft_ctx *ctx,
@@ -261,6 +260,7 @@ void nft_unregister_set(struct nft_set_ops *ops);
  * 	@nelems: number of elements
  *	@policy: set parameterization (see enum nft_set_policies)
  * 	@ops: set ops
+ * 	@pnet: network namespace
  * 	@flags: set flags
  * 	@klen: key length
  * 	@dlen: data length
@@ -277,6 +277,7 @@ struct nft_set {
 	u16				policy;
 	/* runtime data below here */
 	const struct nft_set_ops	*ops ____cacheline_aligned;
+	possible_net_t			pnet;
 	u16				flags;
 	u8				klen;
 	u8				dlen;
@@ -355,10 +356,12 @@ struct nft_set_ext_tmpl {
 /**
  *	struct nft_set_ext - set extensions
  *
+ *	@genmask: generation mask
  *	@offset: offsets of individual extension types
  *	@data: beginning of extension data
  */
 struct nft_set_ext {
+	u8	genmask;
 	u8	offset[NFT_SET_EXT_NUM];
 	char	data[0];
 };
@@ -748,6 +751,22 @@ static inline u8 nft_genmask_cur(const struct net *net)
 	return 1 << ACCESS_ONCE(net->nft.gencursor);
 }
 
+/*
+ * Set element transaction helpers
+ */
+
+static inline bool nft_set_elem_active(const struct nft_set_ext *ext,
+				       u8 genmask)
+{
+	return !(ext->genmask & genmask);
+}
+
+static inline void nft_set_elem_change_active(const struct nft_set *set,
+					      struct nft_set_ext *ext)
+{
+	ext->genmask ^= nft_genmask_next(read_pnet(&set->pnet));
+}
+
 /**
  *	struct nft_trans - nf_tables object update in transaction
  *
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 66fa5e9..5604c2d 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2690,6 +2690,7 @@ static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
 		goto err2;
 
 	INIT_LIST_HEAD(&set->bindings);
+	write_pnet(&set->pnet, net);
 	set->ops   = ops;
 	set->ktype = ktype;
 	set->klen  = desc.klen;
@@ -3221,10 +3222,6 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	if (d1.type != NFT_DATA_VALUE || d1.len != set->klen)
 		goto err2;
 
-	err = -EEXIST;
-	if (set->ops->get(set, &elem) == 0)
-		goto err2;
-
 	nft_set_ext_add(&tmpl, NFT_SET_EXT_KEY);
 
 	if (nla[NFTA_SET_ELEM_DATA] != NULL) {
@@ -3266,6 +3263,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	if (trans == NULL)
 		goto err4;
 
+	ext->genmask = nft_genmask_cur(ctx->net);
 	err = set->ops->insert(set, &elem);
 	if (err < 0)
 		goto err5;
@@ -3353,19 +3351,24 @@ static int nft_del_setelem(struct nft_ctx *ctx, struct nft_set *set,
 	if (desc.type != NFT_DATA_VALUE || desc.len != set->klen)
 		goto err2;
 
-	err = set->ops->get(set, &elem);
-	if (err < 0)
-		goto err2;
-
 	trans = nft_trans_elem_alloc(ctx, NFT_MSG_DELSETELEM, set);
 	if (trans == NULL) {
 		err = -ENOMEM;
 		goto err2;
 	}
 
+	elem.priv = set->ops->deactivate(set, &elem);
+	if (elem.priv == NULL) {
+		err = -ENOENT;
+		goto err3;
+	}
+
 	nft_trans_elem(trans) = elem;
 	list_add_tail(&trans->list, &ctx->net->nft.commit_list);
 	return 0;
+
+err3:
+	kfree(trans);
 err2:
 	nft_data_uninit(&elem.key, desc.type);
 err1:
@@ -3692,9 +3695,11 @@ static int nf_tables_commit(struct sk_buff *skb)
 					     NFT_MSG_DELSET, GFP_KERNEL);
 			break;
 		case NFT_MSG_NEWSETELEM:
-			nf_tables_setelem_notify(&trans->ctx,
-						 nft_trans_elem_set(trans),
-						 &nft_trans_elem(trans),
+			te = (struct nft_trans_elem *)trans->data;
+
+			te->set->ops->activate(te->set, &te->elem);
+			nf_tables_setelem_notify(&trans->ctx, te->set,
+						 &te->elem,
 						 NFT_MSG_NEWSETELEM, 0);
 			nft_trans_destroy(trans);
 			break;
@@ -3704,7 +3709,6 @@ static int nf_tables_commit(struct sk_buff *skb)
 			nf_tables_setelem_notify(&trans->ctx, te->set,
 						 &te->elem,
 						 NFT_MSG_DELSETELEM, 0);
-			te->set->ops->get(te->set, &te->elem);
 			te->set->ops->remove(te->set, &te->elem);
 			break;
 		}
@@ -3812,11 +3816,14 @@ static int nf_tables_abort(struct sk_buff *skb)
 			nft_trans_elem_set(trans)->nelems--;
 			te = (struct nft_trans_elem *)trans->data;
 
-			te->set->ops->get(te->set, &te->elem);
 			te->set->ops->remove(te->set, &te->elem);
 			break;
 		case NFT_MSG_DELSETELEM:
+			te = (struct nft_trans_elem *)trans->data;
+
 			nft_trans_elem_set(trans)->nelems++;
+			te->set->ops->activate(te->set, &te->elem);
+
 			nft_trans_destroy(trans);
 			break;
 		}
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 5bee821..c7e1a9d 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -35,6 +35,7 @@ struct nft_hash_elem {
 struct nft_hash_cmp_arg {
 	const struct nft_set		*set;
 	const struct nft_data		*key;
+	u8				genmask;
 };
 
 static const struct rhashtable_params nft_hash_params;
@@ -61,6 +62,8 @@ static inline int nft_hash_cmp(struct rhashtable_compare_arg *arg,
 
 	if (nft_data_cmp(nft_set_ext_key(&he->ext), x->key, x->set->klen))
 		return 1;
+	if (!nft_set_elem_active(&he->ext, x->genmask))
+		return 1;
 	return 0;
 }
 
@@ -71,6 +74,7 @@ static bool nft_hash_lookup(const struct nft_set *set,
 	struct nft_hash *priv = nft_set_priv(set);
 	const struct nft_hash_elem *he;
 	struct nft_hash_cmp_arg arg = {
+		.genmask = nft_genmask_cur(read_pnet(&set->pnet)),
 		.set	 = set,
 		.key	 = key,
 	};
@@ -88,6 +92,7 @@ static int nft_hash_insert(const struct nft_set *set,
 	struct nft_hash *priv = nft_set_priv(set);
 	struct nft_hash_elem *he = elem->priv;
 	struct nft_hash_cmp_arg arg = {
+		.genmask = nft_genmask_next(read_pnet(&set->pnet)),
 		.set	 = set,
 		.key	 = &elem->key,
 	};
@@ -96,30 +101,39 @@ static int nft_hash_insert(const struct nft_set *set,
 					    nft_hash_params);
 }
 
-static void nft_hash_remove(const struct nft_set *set,
-			    const struct nft_set_elem *elem)
+static void nft_hash_activate(const struct nft_set *set,
+			      const struct nft_set_elem *elem)
 {
-	struct nft_hash *priv = nft_set_priv(set);
+	struct nft_hash_elem *he = elem->priv;
 
-	rhashtable_remove_fast(&priv->ht, elem->cookie, nft_hash_params);
+	nft_set_elem_change_active(set, &he->ext);
 }
 
-static int nft_hash_get(const struct nft_set *set, struct nft_set_elem *elem)
+static void *nft_hash_deactivate(const struct nft_set *set,
+				 const struct nft_set_elem *elem)
 {
 	struct nft_hash *priv = nft_set_priv(set);
 	struct nft_hash_elem *he;
 	struct nft_hash_cmp_arg arg = {
+		.genmask = nft_genmask_next(read_pnet(&set->pnet)),
 		.set	 = set,
 		.key	 = &elem->key,
 	};
 
 	he = rhashtable_lookup_fast(&priv->ht, &arg, nft_hash_params);
-	if (!he)
-		return -ENOENT;
+	if (he != NULL)
+		nft_set_elem_change_active(set, &he->ext);
 
-	elem->priv = he;
+	return he;
+}
 
-	return 0;
+static void nft_hash_remove(const struct nft_set *set,
+			    const struct nft_set_elem *elem)
+{
+	struct nft_hash *priv = nft_set_priv(set);
+	struct nft_hash_elem *he = elem->priv;
+
+	rhashtable_remove_fast(&priv->ht, &he->node, nft_hash_params);
 }
 
 static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
@@ -129,6 +143,7 @@ static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 	struct nft_hash_elem *he;
 	struct rhashtable_iter hti;
 	struct nft_set_elem elem;
+	u8 genmask = nft_genmask_cur(read_pnet(&set->pnet));
 	int err;
 
 	err = rhashtable_walk_init(&priv->ht, &hti);
@@ -155,6 +170,8 @@ static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 
 		if (iter->count < iter->skip)
 			goto cont;
+		if (!nft_set_elem_active(&he->ext, genmask))
+			goto cont;
 
 		elem.priv = he;
 
@@ -241,8 +258,9 @@ static struct nft_set_ops nft_hash_ops __read_mostly = {
 	.estimate	= nft_hash_estimate,
 	.init		= nft_hash_init,
 	.destroy	= nft_hash_destroy,
-	.get		= nft_hash_get,
 	.insert		= nft_hash_insert,
+	.activate	= nft_hash_activate,
+	.deactivate	= nft_hash_deactivate,
 	.remove		= nft_hash_remove,
 	.lookup		= nft_hash_lookup,
 	.walk		= nft_hash_walk,
diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index cbba755..42d0ca4 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -29,6 +29,7 @@ struct nft_rbtree_elem {
 	struct nft_set_ext	ext;
 };
 
+
 static bool nft_rbtree_lookup(const struct nft_set *set,
 			      const struct nft_data *key,
 			      const struct nft_set_ext **ext)
@@ -36,6 +37,7 @@ static bool nft_rbtree_lookup(const struct nft_set *set,
 	const struct nft_rbtree *priv = nft_set_priv(set);
 	const struct nft_rbtree_elem *rbe, *interval = NULL;
 	const struct rb_node *parent;
+	u8 genmask = nft_genmask_cur(read_pnet(&set->pnet));
 	int d;
 
 	spin_lock_bh(&nft_rbtree_lock);
@@ -51,6 +53,10 @@ static bool nft_rbtree_lookup(const struct nft_set *set,
 			parent = parent->rb_right;
 		else {
 found:
+			if (!nft_set_elem_active(&rbe->ext, genmask)) {
+				parent = parent->rb_left;
+				continue;
+			}
 			if (nft_set_ext_exists(&rbe->ext, NFT_SET_EXT_FLAGS) &&
 			    *nft_set_ext_flags(&rbe->ext) &
 			    NFT_SET_ELEM_INTERVAL_END)
@@ -77,6 +83,7 @@ static int __nft_rbtree_insert(const struct nft_set *set,
 	struct nft_rbtree *priv = nft_set_priv(set);
 	struct nft_rbtree_elem *rbe;
 	struct rb_node *parent, **p;
+	u8 genmask = nft_genmask_next(read_pnet(&set->pnet));
 	int d;
 
 	parent = NULL;
@@ -91,8 +98,11 @@ static int __nft_rbtree_insert(const struct nft_set *set,
 			p = &parent->rb_left;
 		else if (d > 0)
 			p = &parent->rb_right;
-		else
-			return -EEXIST;
+		else {
+			if (nft_set_elem_active(&rbe->ext, genmask))
+				return -EEXIST;
+			p = &parent->rb_left;
+		}
 	}
 	rb_link_node(&new->node, parent, p);
 	rb_insert_color(&new->node, &priv->root);
@@ -116,18 +126,28 @@ static void nft_rbtree_remove(const struct nft_set *set,
 			      const struct nft_set_elem *elem)
 {
 	struct nft_rbtree *priv = nft_set_priv(set);
-	struct nft_rbtree_elem *rbe = elem->cookie;
+	struct nft_rbtree_elem *rbe = elem->priv;
 
 	spin_lock_bh(&nft_rbtree_lock);
 	rb_erase(&rbe->node, &priv->root);
 	spin_unlock_bh(&nft_rbtree_lock);
 }
 
-static int nft_rbtree_get(const struct nft_set *set, struct nft_set_elem *elem)
+static void nft_rbtree_activate(const struct nft_set *set,
+				const struct nft_set_elem *elem)
+{
+	struct nft_rbtree_elem *rbe = elem->priv;
+
+	nft_set_elem_change_active(set, &rbe->ext);
+}
+
+static void *nft_rbtree_deactivate(const struct nft_set *set,
+				   const struct nft_set_elem *elem)
 {
 	const struct nft_rbtree *priv = nft_set_priv(set);
 	const struct rb_node *parent = priv->root.rb_node;
 	struct nft_rbtree_elem *rbe;
+	u8 genmask = nft_genmask_cur(read_pnet(&set->pnet));
 	int d;
 
 	while (parent != NULL) {
@@ -140,12 +160,15 @@ static int nft_rbtree_get(const struct nft_set *set, struct nft_set_elem *elem)
 		else if (d > 0)
 			parent = parent->rb_right;
 		else {
-			elem->cookie = rbe;
-			elem->priv   = rbe;
-			return 0;
+			if (!nft_set_elem_active(&rbe->ext, genmask)) {
+				parent = parent->rb_left;
+				continue;
+			}
+			nft_set_elem_change_active(set, &rbe->ext);
+			return rbe;
 		}
 	}
-	return -ENOENT;
+	return NULL;
 }
 
 static void nft_rbtree_walk(const struct nft_ctx *ctx,
@@ -156,13 +179,17 @@ static void nft_rbtree_walk(const struct nft_ctx *ctx,
 	struct nft_rbtree_elem *rbe;
 	struct nft_set_elem elem;
 	struct rb_node *node;
+	u8 genmask = nft_genmask_cur(read_pnet(&set->pnet));
 
 	spin_lock_bh(&nft_rbtree_lock);
 	for (node = rb_first(&priv->root); node != NULL; node = rb_next(node)) {
+		rbe = rb_entry(node, struct nft_rbtree_elem, node);
+
 		if (iter->count < iter->skip)
 			goto cont;
+		if (!nft_set_elem_active(&rbe->ext, genmask))
+			goto cont;
 
-		rbe = rb_entry(node, struct nft_rbtree_elem, node);
 		elem.priv = rbe;
 
 		iter->err = iter->fn(ctx, set, iter, &elem);
@@ -228,7 +255,8 @@ static struct nft_set_ops nft_rbtree_ops __read_mostly = {
 	.destroy	= nft_rbtree_destroy,
 	.insert		= nft_rbtree_insert,
 	.remove		= nft_rbtree_remove,
-	.get		= nft_rbtree_get,
+	.deactivate	= nft_rbtree_deactivate,
+	.activate	= nft_rbtree_activate,
 	.lookup		= nft_rbtree_lookup,
 	.walk		= nft_rbtree_walk,
 	.features	= NFT_SET_INTERVAL | NFT_SET_MAP,
-- 
1.7.10.4

