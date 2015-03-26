From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/15] netfilter: nf_tables: convert hash and rbtree to set extensions
Date: Thu, 26 Mar 2015 13:06:58 +0100
Message-ID: <1427371622-4466-12-git-send-email-pablo@netfilter.org>
References: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

The set implementations' private struct will only contain the elements
needed to maintain the search structure, all other elements are moved
to the set extensions.

Element allocation and initialization is performed centrally by
nf_tables_api instead of by the different set implementations'
->insert() functions. A new "elemsize" member in the set ops specifies
the amount of memory to reserve for internal usage. Destruction
will also be moved out of the set implementations by a following patch.

Except for element allocation, the patch is a simple conversion to
using data from the extension area.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |   14 +++--
 net/netfilter/nf_tables_api.c     |  119 +++++++++++++++++++++++++++----------
 net/netfilter/nft_hash.c          |   56 ++++-------------
 net/netfilter/nft_rbtree.c        |   64 +++++++-------------
 4 files changed, 132 insertions(+), 121 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 038f8a6..ef3457c 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -140,8 +140,7 @@ struct nft_userdata {
  *
  *	@cookie: implementation specific element cookie
  *	@key: element key
- *	@data: element data (maps only)
- *	@flags: element flags (end of interval)
+ *	@priv: element private data and extensions
  *
  *	The cookie can be used to store a handle to the element for subsequent
  *	removal.
@@ -149,8 +148,7 @@ struct nft_userdata {
 struct nft_set_elem {
 	void			*cookie;
 	struct nft_data		key;
-	struct nft_data		data;
-	u32			flags;
+	void			*priv;
 };
 
 struct nft_set;
@@ -214,6 +212,7 @@ struct nft_set_estimate {
  *	@destroy: destroy private data of set instance
  *	@list: nf_tables_set_ops list node
  *	@owner: module reference
+ *	@elemsize: element private size
  *	@features: features supported by the implementation
  */
 struct nft_set_ops {
@@ -241,6 +240,7 @@ struct nft_set_ops {
 
 	struct list_head		list;
 	struct module			*owner;
+	unsigned int			elemsize;
 	u32				features;
 };
 
@@ -417,6 +417,12 @@ static inline u8 *nft_set_ext_flags(const struct nft_set_ext *ext)
 	return nft_set_ext(ext, NFT_SET_EXT_FLAGS);
 }
 
+static inline struct nft_set_ext *nft_set_elem_ext(const struct nft_set *set,
+						   void *elem)
+{
+	return elem + set->ops->elemsize;
+}
+
 /**
  *	struct nft_expr_type - nf_tables expression type
  *
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 972c47f..99cb884 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2771,10 +2771,11 @@ static int nf_tables_bind_check_setelem(const struct nft_ctx *ctx,
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
@@ -2889,6 +2890,7 @@ static int nf_tables_fill_setelem(struct sk_buff *skb,
 				  const struct nft_set *set,
 				  const struct nft_set_elem *elem)
 {
+	const struct nft_set_ext *ext = nft_set_elem_ext(set, elem->priv);
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 
@@ -2896,20 +2898,20 @@ static int nf_tables_fill_setelem(struct sk_buff *skb,
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
@@ -3130,15 +3132,42 @@ static struct nft_trans *nft_trans_elem_alloc(struct nft_ctx *ctx,
 	return trans;
 }
 
+static void *nft_set_elem_init(const struct nft_set *set,
+			       const struct nft_set_ext_tmpl *tmpl,
+			       const struct nft_data *key,
+			       const struct nft_data *data,
+			       gfp_t gfp)
+{
+	struct nft_set_ext *ext;
+	void *elem;
+
+	elem = kzalloc(set->ops->elemsize + tmpl->len, gfp);
+	if (elem == NULL)
+		return NULL;
+
+	ext = nft_set_elem_ext(set, elem);
+	nft_set_ext_init(ext, tmpl);
+
+	memcpy(nft_set_ext_key(ext), key, set->klen);
+	if (nft_set_ext_exists(ext, NFT_SET_EXT_DATA))
+		memcpy(nft_set_ext_data(ext), data, set->dlen);
+
+	return elem;
+}
+
 static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 			    const struct nlattr *attr)
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
@@ -3152,22 +3181,26 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
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
@@ -3185,8 +3218,10 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	if (set->ops->get(set, &elem) == 0)
 		goto err2;
 
+	nft_set_ext_add(&tmpl, NFT_SET_EXT_KEY);
+
 	if (nla[NFTA_SET_ELEM_DATA] != NULL) {
-		err = nft_data_init(ctx, &elem.data, &d2, nla[NFTA_SET_ELEM_DATA]);
+		err = nft_data_init(ctx, &data, &d2, nla[NFTA_SET_ELEM_DATA]);
 		if (err < 0)
 			goto err2;
 
@@ -3203,29 +3238,42 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
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
+	elem.priv = nft_set_elem_init(set, &tmpl, &elem.key, &data, GFP_KERNEL);
+	if (elem.priv == NULL)
+		goto err3;
+
+	ext = nft_set_elem_ext(set, elem.priv);
+	if (flags)
+		*nft_set_ext_flags(ext) = flags;
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
@@ -3557,6 +3605,7 @@ static int nf_tables_commit(struct sk_buff *skb)
 	struct net *net = sock_net(skb->sk);
 	struct nft_trans *trans, *next;
 	struct nft_trans_elem *te;
+	struct nft_set_ext *ext;
 
 	/* Bump generation counter, invalidate any dump in progress */
 	while (++net->nft.base_seq == 0);
@@ -3641,14 +3690,16 @@ static int nf_tables_commit(struct sk_buff *skb)
 			break;
 		case NFT_MSG_DELSETELEM:
 			te = (struct nft_trans_elem *)trans->data;
+			ext = nft_set_elem_ext(te->set, te->elem.priv);
+
 			nf_tables_setelem_notify(&trans->ctx, te->set,
 						 &te->elem,
 						 NFT_MSG_DELSETELEM, 0);
 			te->set->ops->get(te->set, &te->elem);
 			nft_data_uninit(&te->elem.key, NFT_DATA_VALUE);
-			if (te->set->flags & NFT_SET_MAP &&
-			    !(te->elem.flags & NFT_SET_ELEM_INTERVAL_END))
-				nft_data_uninit(&te->elem.data, te->set->dtype);
+			if (nft_set_ext_exists(ext, NFT_SET_EXT_DATA))
+				nft_data_uninit(nft_set_ext_data(ext),
+						te->set->dtype);
 			te->set->ops->remove(te->set, &te->elem);
 			nft_trans_destroy(trans);
 			break;
@@ -3691,6 +3742,7 @@ static int nf_tables_abort(struct sk_buff *skb)
 	struct net *net = sock_net(skb->sk);
 	struct nft_trans *trans, *next;
 	struct nft_trans_elem *te;
+	struct nft_set_ext *ext;
 
 	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
 		switch (trans->msg_type) {
@@ -3752,11 +3804,13 @@ static int nf_tables_abort(struct sk_buff *skb)
 		case NFT_MSG_NEWSETELEM:
 			nft_trans_elem_set(trans)->nelems--;
 			te = (struct nft_trans_elem *)trans->data;
+			ext = nft_set_elem_ext(te->set, te->elem.priv);
+
 			te->set->ops->get(te->set, &te->elem);
 			nft_data_uninit(&te->elem.key, NFT_DATA_VALUE);
-			if (te->set->flags & NFT_SET_MAP &&
-			    !(te->elem.flags & NFT_SET_ELEM_INTERVAL_END))
-				nft_data_uninit(&te->elem.data, te->set->dtype);
+			if (nft_set_ext_exists(ext, NFT_SET_EXT_DATA))
+				nft_data_uninit(nft_set_ext_data(ext),
+						te->set->dtype);
 			te->set->ops->remove(te->set, &te->elem);
 			nft_trans_destroy(trans);
 			break;
@@ -3836,13 +3890,18 @@ static int nf_tables_loop_check_setelem(const struct nft_ctx *ctx,
 					const struct nft_set_iter *iter,
 					const struct nft_set_elem *elem)
 {
-	if (elem->flags & NFT_SET_ELEM_INTERVAL_END)
+	const struct nft_set_ext *ext = nft_set_elem_ext(set, elem->priv);
+	const struct nft_data *data;
+
+	if (nft_set_ext_exists(ext, NFT_SET_EXT_FLAGS) &&
+	    *nft_set_ext_flags(ext) & NFT_SET_ELEM_INTERVAL_END)
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
index dc96a7e..15951a8 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -29,8 +29,7 @@ struct nft_hash {
 
 struct nft_hash_elem {
 	struct rhash_head		node;
-	struct nft_data			key;
-	struct nft_data			data[];
+	struct nft_set_ext		ext;
 };
 
 struct nft_hash_cmp_arg {
@@ -51,7 +50,7 @@ static inline u32 nft_hash_obj(const void *data, u32 len, u32 seed)
 {
 	const struct nft_hash_elem *he = data;
 
-	return jhash(&he->key, len, seed);
+	return jhash(nft_set_ext_key(&he->ext), len, seed);
 }
 
 static inline int nft_hash_cmp(struct rhashtable_compare_arg *arg,
@@ -60,7 +59,7 @@ static inline int nft_hash_cmp(struct rhashtable_compare_arg *arg,
 	const struct nft_hash_cmp_arg *x = arg->key;
 	const struct nft_hash_elem *he = ptr;
 
-	if (nft_data_cmp(&he->key, x->key, x->set->klen))
+	if (nft_data_cmp(nft_set_ext_key(&he->ext), x->key, x->set->klen))
 		return 1;
 	return 0;
 }
@@ -78,7 +77,7 @@ static bool nft_hash_lookup(const struct nft_set *set,
 
 	he = rhashtable_lookup_fast(&priv->ht, &arg, nft_hash_params);
 	if (he && set->flags & NFT_SET_MAP)
-		nft_data_copy(data, he->data);
+		nft_data_copy(data, nft_set_ext_data(&he->ext));
 
 	return !!he;
 }
@@ -87,43 +86,22 @@ static int nft_hash_insert(const struct nft_set *set,
 			   const struct nft_set_elem *elem)
 {
 	struct nft_hash *priv = nft_set_priv(set);
-	struct nft_hash_elem *he;
+	struct nft_hash_elem *he = elem->priv;
 	struct nft_hash_cmp_arg arg = {
 		.set	 = set,
 		.key	 = &elem->key,
 	};
-	unsigned int size;
-	int err;
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
-
-	err = rhashtable_lookup_insert_key(&priv->ht, &arg, &he->node,
-					   nft_hash_params);
-	if (err)
-		kfree(he);
 
-	return err;
+	return rhashtable_lookup_insert_key(&priv->ht, &arg, &he->node,
+					    nft_hash_params);
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
 
@@ -150,10 +128,7 @@ static int nft_hash_get(const struct nft_set *set, struct nft_set_elem *elem)
 	if (!he)
 		return -ENOENT;
 
-	elem->cookie = he;
-	elem->flags = 0;
-	if (set->flags & NFT_SET_MAP)
-		nft_data_copy(&elem->data, he->data);
+	elem->priv = he;
 
 	return 0;
 }
@@ -162,7 +137,7 @@ static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 			  struct nft_set_iter *iter)
 {
 	struct nft_hash *priv = nft_set_priv(set);
-	const struct nft_hash_elem *he;
+	struct nft_hash_elem *he;
 	struct rhashtable_iter hti;
 	struct nft_set_elem elem;
 	int err;
@@ -192,10 +167,7 @@ static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 		if (iter->count < iter->skip)
 			goto cont;
 
-		memcpy(&elem.key, &he->key, sizeof(elem.key));
-		if (set->flags & NFT_SET_MAP)
-			memcpy(&elem.data, he->data, sizeof(elem.data));
-		elem.flags = 0;
+		elem.priv = he;
 
 		iter->err = iter->fn(ctx, set, iter, &elem);
 		if (iter->err < 0)
@@ -254,9 +226,6 @@ static bool nft_hash_estimate(const struct nft_set_desc *desc, u32 features,
 	unsigned int esize;
 
 	esize = sizeof(struct nft_hash_elem);
-	if (features & NFT_SET_MAP)
-		esize += FIELD_SIZEOF(struct nft_hash_elem, data[0]);
-
 	if (desc->size) {
 		est->size = sizeof(struct nft_hash) +
 			    roundup_pow_of_two(desc->size * 4 / 3) *
@@ -278,6 +247,7 @@ static bool nft_hash_estimate(const struct nft_set_desc *desc, u32 features,
 
 static struct nft_set_ops nft_hash_ops __read_mostly = {
 	.privsize       = nft_hash_privsize,
+	.elemsize	= offsetof(struct nft_hash_elem, ext),
 	.estimate	= nft_hash_estimate,
 	.init		= nft_hash_init,
 	.destroy	= nft_hash_destroy,
diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index 2c75361..ebf6e60 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -26,9 +26,7 @@ struct nft_rbtree {
 
 struct nft_rbtree_elem {
 	struct rb_node		node;
-	u16			flags;
-	struct nft_data		key;
-	struct nft_data		data[];
+	struct nft_set_ext	ext;
 };
 
 static bool nft_rbtree_lookup(const struct nft_set *set,
@@ -45,7 +43,7 @@ static bool nft_rbtree_lookup(const struct nft_set *set,
 	while (parent != NULL) {
 		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
 
-		d = nft_data_cmp(&rbe->key, key, set->klen);
+		d = nft_data_cmp(nft_set_ext_key(&rbe->ext), key, set->klen);
 		if (d < 0) {
 			parent = parent->rb_left;
 			interval = rbe;
@@ -53,10 +51,12 @@ static bool nft_rbtree_lookup(const struct nft_set *set,
 			parent = parent->rb_right;
 		else {
 found:
-			if (rbe->flags & NFT_SET_ELEM_INTERVAL_END)
+			if (nft_set_ext_exists(&rbe->ext, NFT_SET_EXT_FLAGS) &&
+			    *nft_set_ext_flags(&rbe->ext) &
+			    NFT_SET_ELEM_INTERVAL_END)
 				goto out;
 			if (set->flags & NFT_SET_MAP)
-				nft_data_copy(data, rbe->data);
+				nft_data_copy(data, nft_set_ext_data(&rbe->ext));
 
 			spin_unlock_bh(&nft_rbtree_lock);
 			return true;
@@ -75,10 +75,10 @@ out:
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
@@ -96,7 +96,9 @@ static int __nft_rbtree_insert(const struct nft_set *set,
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
@@ -112,31 +114,13 @@ static int __nft_rbtree_insert(const struct nft_set *set,
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
 
@@ -162,17 +146,15 @@ static int nft_rbtree_get(const struct nft_set *set, struct nft_set_elem *elem)
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
 			return 0;
 		}
 	}
@@ -184,7 +166,7 @@ static void nft_rbtree_walk(const struct nft_ctx *ctx,
 			    struct nft_set_iter *iter)
 {
 	const struct nft_rbtree *priv = nft_set_priv(set);
-	const struct nft_rbtree_elem *rbe;
+	struct nft_rbtree_elem *rbe;
 	struct nft_set_elem elem;
 	struct rb_node *node;
 
@@ -194,11 +176,7 @@ static void nft_rbtree_walk(const struct nft_ctx *ctx,
 			goto cont;
 
 		rbe = rb_entry(node, struct nft_rbtree_elem, node);
-		nft_data_copy(&elem.key, &rbe->key);
-		if (set->flags & NFT_SET_MAP &&
-		    !(rbe->flags & NFT_SET_ELEM_INTERVAL_END))
-			nft_data_copy(&elem.data, rbe->data);
-		elem.flags = rbe->flags;
+		elem.priv = rbe;
 
 		iter->err = iter->fn(ctx, set, iter, &elem);
 		if (iter->err < 0) {
@@ -245,9 +223,6 @@ static bool nft_rbtree_estimate(const struct nft_set_desc *desc, u32 features,
 	unsigned int nsize;
 
 	nsize = sizeof(struct nft_rbtree_elem);
-	if (features & NFT_SET_MAP)
-		nsize += FIELD_SIZEOF(struct nft_rbtree_elem, data[0]);
-
 	if (desc->size)
 		est->size = sizeof(struct nft_rbtree) + desc->size * nsize;
 	else
@@ -260,6 +235,7 @@ static bool nft_rbtree_estimate(const struct nft_set_desc *desc, u32 features,
 
 static struct nft_set_ops nft_rbtree_ops __read_mostly = {
 	.privsize	= nft_rbtree_privsize,
+	.elemsize	= offsetof(struct nft_rbtree_elem, ext),
 	.estimate	= nft_rbtree_estimate,
 	.init		= nft_rbtree_init,
 	.destroy	= nft_rbtree_destroy,
-- 
1.7.10.4

