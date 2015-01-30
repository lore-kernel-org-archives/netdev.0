From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 5/9] netfilter: nf_tables: convert hash and rbtree to set extensions
Date: Fri, 30 Jan 2015 07:46:30 +0000
Message-ID: <1422603994-5836-6-git-send-email-kaber@trash.net>
References: <1422603994-5836-1-git-send-email-kaber@trash.net>
Cc: tgraf@suug.ch, davem@davemloft.net, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34123 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754176AbbA3Hqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 02:46:51 -0500
In-Reply-To: <1422603994-5836-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_tables.h | 15 ++++---
 net/netfilter/nf_tables_api.c     | 83 ++++++++++++++++++++++++++++-----------
 net/netfilter/nft_hash.c          | 52 +++++++-----------------
 net/netfilter/nft_lookup.c        |  6 ++-
 net/netfilter/nft_rbtree.c        | 68 +++++++++++---------------------
 5 files changed, 112 insertions(+), 112 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 9f2d073..60846da 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -233,8 +233,7 @@ static inline u8 *nft_set_ext_flags(const struct nft_set_ext *ext)
  *
  *	@cookie: implementation specific element cookie
  *	@key: element key
- *	@data: element data (maps only)
- *	@flags: element flags (end of interval)
+ *	@priv: element private data and extensions
  *
  *	The cookie can be used to store a handle to the element for subsequent
  *	removal.
@@ -242,8 +241,7 @@ static inline u8 *nft_set_ext_flags(const struct nft_set_ext *ext)
 struct nft_set_elem {
 	void			*cookie;
 	struct nft_data		key;
-	struct nft_data		data;
-	u32			flags;
+	void			*priv;
 };
 
 struct nft_set;
@@ -307,12 +305,13 @@ struct nft_set_estimate {
  *	@destroy: destroy private data of set instance
  *	@list: nf_tables_set_ops list node
  *	@owner: module reference
+ *	@elemsize: element private size
  *	@features: features supported by the implementation
  */
 struct nft_set_ops {
 	bool				(*lookup)(const struct nft_set *set,
 						  const struct nft_data *key,
-						  struct nft_data *data);
+						  const struct nft_set_ext **ext);
 	int				(*get)(const struct nft_set *set,
 					       struct nft_set_elem *elem);
 	int				(*insert)(const struct nft_set *set,
@@ -334,6 +333,7 @@ struct nft_set_ops {
 
 	struct list_head		list;
 	struct module			*owner;
+	unsigned int			elemsize;
 	u32				features;
 };
 
@@ -380,6 +380,11 @@ static inline void *nft_set_priv(const struct nft_set *set)
 	return (void *)set->data;
 }
 
+static inline struct nft_set_ext *nft_set_elem_ext(const struct nft_set *set, void *priv)
+{
+	return priv + set->ops->elemsize;
+}
+
 struct nft_set *nf_tables_set_lookup(const struct nft_table *table,
 				     const struct nlattr *nla);
 struct nft_set *nf_tables_set_lookup_byid(const struct net *net,
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index fbc73a0..cad0184 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2743,10 +2743,11 @@ static int nf_tables_bind_check_setelem(const struct nft_ctx *ctx,
 					const struct nft_set_iter *iter,
 					const struct nft_set_elem *elem)
 {
+	const struct nft_set_ext *ext = nft_set_elem_ext(set, elem->priv);
 	enum nft_registers dreg;
 
 	dreg = nft_type_to_reg(set->dtype);
-	return nft_validate_data_load(ctx, dreg, &elem->data,
+	return nft_validate_data_load(ctx, dreg, nft_set_ext_data(ext),
 				      set->dtype == NFT_DATA_VERDICT ?
 				      NFT_DATA_VERDICT : NFT_DATA_VALUE);
 }
@@ -2861,6 +2862,7 @@ static int nf_tables_fill_setelem(struct sk_buff *skb,
 				  const struct nft_set *set,
 				  const struct nft_set_elem *elem)
 {
+	const struct nft_set_ext *ext = nft_set_elem_ext(set, elem->priv);
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 
@@ -2868,20 +2870,20 @@ static int nf_tables_fill_setelem(struct sk_buff *skb,
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	if (nft_data_dump(skb, NFTA_SET_ELEM_KEY, &elem->key, NFT_DATA_VALUE,
-			  set->klen) < 0)
+	if (nft_data_dump(skb, NFTA_SET_ELEM_KEY, nft_set_ext_key(ext),
+			  NFT_DATA_VALUE, set->klen) < 0)
 		goto nla_put_failure;
 
-	if (set->flags & NFT_SET_MAP &&
-	    !(elem->flags & NFT_SET_ELEM_INTERVAL_END) &&
-	    nft_data_dump(skb, NFTA_SET_ELEM_DATA, &elem->data,
+	if (nft_set_ext_exists(ext, NFT_SET_EXT_DATA) &&
+	    nft_data_dump(skb, NFTA_SET_ELEM_DATA, nft_set_ext_data(ext),
 			  set->dtype == NFT_DATA_VERDICT ? NFT_DATA_VERDICT : NFT_DATA_VALUE,
 			  set->dlen) < 0)
 		goto nla_put_failure;
 
-	if (elem->flags != 0)
-		if (nla_put_be32(skb, NFTA_SET_ELEM_FLAGS, htonl(elem->flags)))
-			goto nla_put_failure;
+	if (nft_set_ext_exists(ext, NFT_SET_EXT_FLAGS) &&
+	    nla_put_be32(skb, NFTA_SET_ELEM_FLAGS,
+		         htonl(*nft_set_ext_flags(ext))))
+		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 	return 0;
@@ -3106,10 +3108,14 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 {
 	struct nlattr *nla[NFTA_SET_ELEM_MAX + 1];
 	struct nft_data_desc d1, d2;
+	struct nft_set_ext_tmpl tmpl;
+	struct nft_set_ext *ext;
 	struct nft_set_elem elem;
 	struct nft_set_binding *binding;
+	struct nft_data data;
 	enum nft_registers dreg;
 	struct nft_trans *trans;
+	u32 flags;
 	int err;
 
 	if (set->size && set->nelems == set->size)
@@ -3123,22 +3129,26 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	if (nla[NFTA_SET_ELEM_KEY] == NULL)
 		return -EINVAL;
 
-	elem.flags = 0;
+	nft_set_ext_prepare(&tmpl);
+
+	flags = 0;
 	if (nla[NFTA_SET_ELEM_FLAGS] != NULL) {
-		elem.flags = ntohl(nla_get_be32(nla[NFTA_SET_ELEM_FLAGS]));
-		if (elem.flags & ~NFT_SET_ELEM_INTERVAL_END)
+		flags = ntohl(nla_get_be32(nla[NFTA_SET_ELEM_FLAGS]));
+		if (flags & ~NFT_SET_ELEM_INTERVAL_END)
 			return -EINVAL;
 		if (!(set->flags & NFT_SET_INTERVAL) &&
-		    elem.flags & NFT_SET_ELEM_INTERVAL_END)
+		    flags & NFT_SET_ELEM_INTERVAL_END)
 			return -EINVAL;
+		if (flags != 0)
+			nft_set_ext_add(&tmpl, NFT_SET_EXT_FLAGS);
 	}
 
 	if (set->flags & NFT_SET_MAP) {
 		if (nla[NFTA_SET_ELEM_DATA] == NULL &&
-		    !(elem.flags & NFT_SET_ELEM_INTERVAL_END))
+		    !(flags & NFT_SET_ELEM_INTERVAL_END))
 			return -EINVAL;
 		if (nla[NFTA_SET_ELEM_DATA] != NULL &&
-		    elem.flags & NFT_SET_ELEM_INTERVAL_END)
+		    flags & NFT_SET_ELEM_INTERVAL_END)
 			return -EINVAL;
 	} else {
 		if (nla[NFTA_SET_ELEM_DATA] != NULL)
@@ -3156,8 +3166,10 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	if (set->ops->get(set, &elem) == 0)
 		goto err2;
 
+	nft_set_ext_add(&tmpl, NFT_SET_EXT_KEY);
+
 	if (nla[NFTA_SET_ELEM_DATA] != NULL) {
-		err = nft_data_init(ctx, &elem.data, &d2, nla[NFTA_SET_ELEM_DATA]);
+		err = nft_data_init(ctx, &data, &d2, nla[NFTA_SET_ELEM_DATA]);
 		if (err < 0)
 			goto err2;
 
@@ -3174,29 +3186,46 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 			};
 
 			err = nft_validate_data_load(&bind_ctx, dreg,
-						     &elem.data, d2.type);
+						     &data, d2.type);
 			if (err < 0)
 				goto err3;
 		}
+
+		nft_set_ext_add(&tmpl, NFT_SET_EXT_DATA);
 	}
 
+	err = -ENOMEM;
+	elem.priv = kzalloc(set->ops->elemsize + tmpl.len, GFP_KERNEL);
+	if (elem.priv == NULL)
+		goto err3;
+	ext = elem.priv + set->ops->elemsize;
+
+	nft_set_ext_init(ext, &tmpl);
+	nft_data_copy(nft_set_ext_key(ext), &elem.key);
+	if (flags != 0)
+		*nft_set_ext_flags(ext) = flags;
+	if (nla[NFTA_SET_ELEM_DATA] != NULL)
+		nft_data_copy(nft_set_ext_data(ext), &data);
+
 	trans = nft_trans_elem_alloc(ctx, NFT_MSG_NEWSETELEM, set);
 	if (trans == NULL)
-		goto err3;
+		goto err4;
 
 	err = set->ops->insert(set, &elem);
 	if (err < 0)
-		goto err4;
+		goto err5;
 
 	nft_trans_elem(trans) = elem;
 	list_add_tail(&trans->list, &ctx->net->nft.commit_list);
 	return 0;
 
-err4:
+err5:
 	kfree(trans);
+err4:
+	kfree(elem.priv);
 err3:
 	if (nla[NFTA_SET_ELEM_DATA] != NULL)
-		nft_data_uninit(&elem.data, d2.type);
+		nft_data_uninit(&data, d2.type);
 err2:
 	nft_data_uninit(&elem.key, d1.type);
 err1:
@@ -3617,10 +3646,12 @@ static int nf_tables_commit(struct sk_buff *skb)
 			te->set->ops->get(te->set, &te->elem);
 			te->set->ops->remove(te->set, &te->elem);
 			nft_data_uninit(&te->elem.key, NFT_DATA_VALUE);
+#if 0
 			if (te->elem.flags & NFT_SET_MAP) {
 				nft_data_uninit(&te->elem.data,
 						te->set->dtype);
 			}
+#endif
 			nft_trans_destroy(trans);
 			break;
 		}
@@ -3785,13 +3816,17 @@ static int nf_tables_loop_check_setelem(const struct nft_ctx *ctx,
 					const struct nft_set_iter *iter,
 					const struct nft_set_elem *elem)
 {
-	if (elem->flags & NFT_SET_ELEM_INTERVAL_END)
+	const struct nft_set_ext *ext = nft_set_elem_ext(set, elem->priv);
+	const struct nft_data *data;
+
+	if (*nft_set_ext_flags(ext) & NFT_SET_ELEM_INTERVAL_END)
 		return 0;
 
-	switch (elem->data.verdict) {
+	data = nft_set_ext_data(ext);
+	switch (data->verdict) {
 	case NFT_JUMP:
 	case NFT_GOTO:
-		return nf_tables_check_loops(ctx, elem->data.chain);
+		return nf_tables_check_loops(ctx, data->chain);
 	default:
 		return 0;
 	}
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 75887d7..cba0ad2 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -25,20 +25,19 @@
 
 struct nft_hash_elem {
 	struct rhash_head		node;
-	struct nft_data			key;
-	struct nft_data			data[];
+	struct nft_set_ext		ext;
 };
 
 static bool nft_hash_lookup(const struct nft_set *set,
 			    const struct nft_data *key,
-			    struct nft_data *data)
+			    const struct nft_set_ext **ext)
 {
 	struct rhashtable *priv = nft_set_priv(set);
 	const struct nft_hash_elem *he;
 
 	he = rhashtable_lookup(priv, key);
-	if (he && set->flags & NFT_SET_MAP)
-		nft_data_copy(data, he->data);
+	if (he != NULL)
+		*ext = &he->ext;
 
 	return !!he;
 }
@@ -47,35 +46,18 @@ static int nft_hash_insert(const struct nft_set *set,
 			   const struct nft_set_elem *elem)
 {
 	struct rhashtable *priv = nft_set_priv(set);
-	struct nft_hash_elem *he;
-	unsigned int size;
-
-	if (elem->flags != 0)
-		return -EINVAL;
-
-	size = sizeof(*he);
-	if (set->flags & NFT_SET_MAP)
-		size += sizeof(he->data[0]);
-
-	he = kzalloc(size, GFP_KERNEL);
-	if (he == NULL)
-		return -ENOMEM;
-
-	nft_data_copy(&he->key, &elem->key);
-	if (set->flags & NFT_SET_MAP)
-		nft_data_copy(he->data, &elem->data);
+	struct nft_hash_elem *he = elem->priv;
 
 	rhashtable_insert(priv, &he->node);
-
 	return 0;
 }
 
 static void nft_hash_elem_destroy(const struct nft_set *set,
 				  struct nft_hash_elem *he)
 {
-	nft_data_uninit(&he->key, NFT_DATA_VALUE);
+	nft_data_uninit(nft_set_ext_key(&he->ext), NFT_DATA_VALUE);
 	if (set->flags & NFT_SET_MAP)
-		nft_data_uninit(he->data, set->dtype);
+		nft_data_uninit(nft_set_ext_data(&he->ext), set->dtype);
 	kfree(he);
 }
 
@@ -99,12 +81,10 @@ static bool nft_hash_compare(void *ptr, void *arg)
 	struct nft_hash_elem *he = ptr;
 	struct nft_compare_arg *x = arg;
 
-	if (!nft_data_cmp(&he->key, &x->elem->key, x->set->klen)) {
+	if (!nft_data_cmp(nft_set_ext_key(&he->ext), &x->elem->key,
+			  x->set->klen)) {
 		x->elem->cookie = he;
-		x->elem->flags = 0;
-		if (x->set->flags & NFT_SET_MAP)
-			nft_data_copy(&x->elem->data, he->data);
-
+		x->elem->priv  = he;
 		return true;
 	}
 
@@ -131,7 +111,7 @@ static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 {
 	struct rhashtable *priv = nft_set_priv(set);
 	const struct bucket_table *tbl;
-	const struct nft_hash_elem *he;
+	struct nft_hash_elem *he;
 	struct nft_set_elem elem;
 	unsigned int i;
 
@@ -143,10 +123,7 @@ static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 			if (iter->count < iter->skip)
 				goto cont;
 
-			memcpy(&elem.key, &he->key, sizeof(elem.key));
-			if (set->flags & NFT_SET_MAP)
-				memcpy(&elem.data, he->data, sizeof(elem.data));
-			elem.flags = 0;
+			elem.priv = he;
 
 			iter->err = iter->fn(ctx, set, iter, &elem);
 			if (iter->err < 0)
@@ -170,7 +147,7 @@ static int nft_hash_init(const struct nft_set *set,
 	struct rhashtable_params params = {
 		.nelem_hint = desc->size ? : NFT_HASH_ELEMENT_HINT,
 		.head_offset = offsetof(struct nft_hash_elem, node),
-		.key_offset = offsetof(struct nft_hash_elem, key),
+		.key_offset = offsetof(struct nft_hash_elem, ext) + 8,
 		.key_len = set->klen,
 		.hashfn = jhash,
 		.grow_decision = rht_grow_above_75,
@@ -209,7 +186,7 @@ static bool nft_hash_estimate(const struct nft_set_desc *desc, u32 features,
 
 	esize = sizeof(struct nft_hash_elem);
 	if (features & NFT_SET_MAP)
-		esize += FIELD_SIZEOF(struct nft_hash_elem, data[0]);
+		esize += sizeof(struct nft_data);
 
 	if (desc->size) {
 		est->size = sizeof(struct rhashtable) +
@@ -232,6 +209,7 @@ static bool nft_hash_estimate(const struct nft_set_desc *desc, u32 features,
 
 static struct nft_set_ops nft_hash_ops __read_mostly = {
 	.privsize       = nft_hash_privsize,
+	.elemsize	= offsetof(struct nft_hash_elem, ext),
 	.estimate	= nft_hash_estimate,
 	.init		= nft_hash_init,
 	.destroy	= nft_hash_destroy,
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index 6404a72..cdbf050 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -31,9 +31,13 @@ static void nft_lookup_eval(const struct nft_expr *expr,
 {
 	const struct nft_lookup *priv = nft_expr_priv(expr);
 	const struct nft_set *set = priv->set;
+	const struct nft_set_ext *ext;
 
-	if (set->ops->lookup(set, &data[priv->sreg], &data[priv->dreg]))
+	if (set->ops->lookup(set, &data[priv->sreg], &ext)) {
+		if (set->flags & NFT_SET_MAP)
+			nft_data_copy(&data[priv->dreg], nft_set_ext_data(ext));
 		return;
+	}
 	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
 }
 
diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index 417796f..e721744 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -26,14 +26,12 @@ struct nft_rbtree {
 
 struct nft_rbtree_elem {
 	struct rb_node		node;
-	u16			flags;
-	struct nft_data		key;
-	struct nft_data		data[];
+	struct nft_set_ext	ext;
 };
 
 static bool nft_rbtree_lookup(const struct nft_set *set,
 			      const struct nft_data *key,
-			      struct nft_data *data)
+			      const struct nft_set_ext **ext)
 {
 	const struct nft_rbtree *priv = nft_set_priv(set);
 	const struct nft_rbtree_elem *rbe, *interval = NULL;
@@ -45,7 +43,7 @@ static bool nft_rbtree_lookup(const struct nft_set *set,
 	while (parent != NULL) {
 		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
 
-		d = nft_data_cmp(&rbe->key, key, set->klen);
+		d = nft_data_cmp(nft_set_ext_key(&rbe->ext), key, set->klen);
 		if (d < 0) {
 			parent = parent->rb_left;
 			interval = rbe;
@@ -53,12 +51,12 @@ static bool nft_rbtree_lookup(const struct nft_set *set,
 			parent = parent->rb_right;
 		else {
 found:
-			if (rbe->flags & NFT_SET_ELEM_INTERVAL_END)
+			if (*nft_set_ext_flags(&rbe->ext) &
+			    NFT_SET_ELEM_INTERVAL_END)
 				goto out;
-			if (set->flags & NFT_SET_MAP)
-				nft_data_copy(data, rbe->data);
-
 			spin_unlock_bh(&nft_rbtree_lock);
+			// FIXME: valid?
+			*ext = &rbe->ext;
 			return true;
 		}
 	}
@@ -75,10 +73,10 @@ out:
 static void nft_rbtree_elem_destroy(const struct nft_set *set,
 				    struct nft_rbtree_elem *rbe)
 {
-	nft_data_uninit(&rbe->key, NFT_DATA_VALUE);
+	nft_data_uninit(nft_set_ext_key(&rbe->ext), NFT_DATA_VALUE);
 	if (set->flags & NFT_SET_MAP &&
-	    !(rbe->flags & NFT_SET_ELEM_INTERVAL_END))
-		nft_data_uninit(rbe->data, set->dtype);
+	    nft_set_ext_exists(&rbe->ext, NFT_SET_EXT_DATA))
+		nft_data_uninit(nft_set_ext_data(&rbe->ext), set->dtype);
 
 	kfree(rbe);
 }
@@ -96,7 +94,9 @@ static int __nft_rbtree_insert(const struct nft_set *set,
 	while (*p != NULL) {
 		parent = *p;
 		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
-		d = nft_data_cmp(&rbe->key, &new->key, set->klen);
+		d = nft_data_cmp(nft_set_ext_key(&rbe->ext),
+				 nft_set_ext_key(&new->ext),
+				 set->klen);
 		if (d < 0)
 			p = &parent->rb_left;
 		else if (d > 0)
@@ -112,31 +112,13 @@ static int __nft_rbtree_insert(const struct nft_set *set,
 static int nft_rbtree_insert(const struct nft_set *set,
 			     const struct nft_set_elem *elem)
 {
-	struct nft_rbtree_elem *rbe;
-	unsigned int size;
+	struct nft_rbtree_elem *rbe = elem->priv;
 	int err;
 
-	size = sizeof(*rbe);
-	if (set->flags & NFT_SET_MAP &&
-	    !(elem->flags & NFT_SET_ELEM_INTERVAL_END))
-		size += sizeof(rbe->data[0]);
-
-	rbe = kzalloc(size, GFP_KERNEL);
-	if (rbe == NULL)
-		return -ENOMEM;
-
-	rbe->flags = elem->flags;
-	nft_data_copy(&rbe->key, &elem->key);
-	if (set->flags & NFT_SET_MAP &&
-	    !(rbe->flags & NFT_SET_ELEM_INTERVAL_END))
-		nft_data_copy(rbe->data, &elem->data);
-
 	spin_lock_bh(&nft_rbtree_lock);
 	err = __nft_rbtree_insert(set, rbe);
-	if (err < 0)
-		kfree(rbe);
-
 	spin_unlock_bh(&nft_rbtree_lock);
+
 	return err;
 }
 
@@ -162,17 +144,16 @@ static int nft_rbtree_get(const struct nft_set *set, struct nft_set_elem *elem)
 	while (parent != NULL) {
 		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
 
-		d = nft_data_cmp(&rbe->key, &elem->key, set->klen);
+		d = nft_data_cmp(nft_set_ext_key(&rbe->ext), &elem->key,
+				 set->klen);
 		if (d < 0)
 			parent = parent->rb_left;
 		else if (d > 0)
 			parent = parent->rb_right;
 		else {
 			elem->cookie = rbe;
-			if (set->flags & NFT_SET_MAP &&
-			    !(rbe->flags & NFT_SET_ELEM_INTERVAL_END))
-				nft_data_copy(&elem->data, rbe->data);
-			elem->flags = rbe->flags;
+			elem->priv   = rbe;
+			spin_unlock_bh(&nft_rbtree_lock);
 			return 0;
 		}
 	}
@@ -184,7 +165,7 @@ static void nft_rbtree_walk(const struct nft_ctx *ctx,
 			    struct nft_set_iter *iter)
 {
 	const struct nft_rbtree *priv = nft_set_priv(set);
-	const struct nft_rbtree_elem *rbe;
+	struct nft_rbtree_elem *rbe;
 	struct nft_set_elem elem;
 	struct rb_node *node;
 
@@ -193,11 +174,7 @@ static void nft_rbtree_walk(const struct nft_ctx *ctx,
 			goto cont;
 
 		rbe = rb_entry(node, struct nft_rbtree_elem, node);
-		nft_data_copy(&elem.key, &rbe->key);
-		if (set->flags & NFT_SET_MAP &&
-		    !(rbe->flags & NFT_SET_ELEM_INTERVAL_END))
-			nft_data_copy(&elem.data, rbe->data);
-		elem.flags = rbe->flags;
+		elem.priv = rbe;
 
 		iter->err = iter->fn(ctx, set, iter, &elem);
 		if (iter->err < 0)
@@ -242,7 +219,7 @@ static bool nft_rbtree_estimate(const struct nft_set_desc *desc, u32 features,
 
 	nsize = sizeof(struct nft_rbtree_elem);
 	if (features & NFT_SET_MAP)
-		nsize += FIELD_SIZEOF(struct nft_rbtree_elem, data[0]);
+		nsize += sizeof(struct nft_data);
 
 	if (desc->size)
 		est->size = sizeof(struct nft_rbtree) + desc->size * nsize;
@@ -256,6 +233,7 @@ static bool nft_rbtree_estimate(const struct nft_set_desc *desc, u32 features,
 
 static struct nft_set_ops nft_rbtree_ops __read_mostly = {
 	.privsize	= nft_rbtree_privsize,
+	.elemsize	= offsetof(struct nft_rbtree_elem, ext),
 	.estimate	= nft_rbtree_estimate,
 	.init		= nft_rbtree_init,
 	.destroy	= nft_rbtree_destroy,
-- 
2.1.0
