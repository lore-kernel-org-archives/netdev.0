From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH RFC 8/9] netfilter: nf_tables: generalize verdict handling and introduce scopes
Date: Tue, 11 Mar 2014 10:19:19 +0100
Message-ID: <1394529560-3490-9-git-send-email-pablo@netfilter.org>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch allows us to add multiple verdict interpretations depending
on the scope that is specified. This allows us to add different verdict
handling for new classifiers, eg. socket filtering using nf_tables.

The idea is to add a struct nft_verdict_ops that provides the
corresponding interpretation for the given scope. There is an array
of struct nft_verdict_ops for each scope which is accessed only from
user context at configuration stage. I didn't find any good reason
to protect this array with any locking since each position of it
is initialized/reset by the corresponding user (socket filter and
netfilter) in the initialization and module removal path (before
any client can actually access it). This structure is not accessed
from the packet path and the only user is the one that registers it.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h      |   19 ++-
 include/net/netfilter/nf_tables_core.h |   17 ++-
 include/net/netfilter/nft_reject.h     |    3 +-
 net/netfilter/nf_tables_api.c          |  238 ++++++--------------------------
 net/netfilter/nf_tables_core.c         |  224 +++++++++++++++++++++++++++++-
 net/netfilter/nft_bitwise.c            |   11 +-
 net/netfilter/nft_byteorder.c          |    3 +-
 net/netfilter/nft_cmp.c                |   17 ++-
 net/netfilter/nft_compat.c             |    6 +-
 net/netfilter/nft_counter.c            |    3 +-
 net/netfilter/nft_ct.c                 |    9 +-
 net/netfilter/nft_exthdr.c             |    3 +-
 net/netfilter/nft_hash.c               |   12 +-
 net/netfilter/nft_immediate.c          |   10 +-
 net/netfilter/nft_limit.c              |    3 +-
 net/netfilter/nft_log.c                |    3 +-
 net/netfilter/nft_lookup.c             |    3 +-
 net/netfilter/nft_meta.c               |    8 +-
 net/netfilter/nft_nat.c                |    3 +-
 net/netfilter/nft_payload.c            |    3 +-
 net/netfilter/nft_queue.c              |    3 +-
 net/netfilter/nft_rbtree.c             |   12 +-
 net/netfilter/nft_reject.c             |    3 +-
 23 files changed, 365 insertions(+), 251 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 696a916..c4c35c4 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -68,6 +68,11 @@ static inline void nft_data_debug(const struct nft_data *data)
 		 data->data[2], data->data[3]);
 }
 
+enum nft_scope {
+	NFT_SCOPE_NF	= 0,
+	NFT_SCOPE_MAX
+};
+
 /**
  *	struct nft_ctx - nf_tables rule/set context
  *
@@ -78,6 +83,7 @@ static inline void nft_data_debug(const struct nft_data *data)
  * 	@table: the table the chain is contained in
  * 	@chain: the chain the rule is contained in
  *	@nla: netlink attributes
+ *	@scope: the scope for this context
  */
 struct nft_ctx {
 	struct net			*net;
@@ -87,6 +93,7 @@ struct nft_ctx {
 	const struct nft_table		*table;
 	const struct nft_chain		*chain;
 	const struct nlattr * const 	*nla;
+	enum nft_scope			scope;
 };
 
 struct nft_data_desc {
@@ -98,9 +105,11 @@ int nft_data_init(const struct nft_ctx *ctx, struct nft_data *data,
 		  struct nft_data_desc *desc, const struct nlattr *nla);
 int nft_value_init(const struct nft_ctx *ctx, struct nft_data *data,
 		   struct nft_data_desc *desc, const struct nlattr *nla);
-void nft_data_uninit(const struct nft_data *data, enum nft_data_types type);
+void nft_data_uninit(const struct nft_data *data, enum nft_data_types type,
+		     enum nft_scope scope);
 int nft_data_dump(struct sk_buff *skb, int attr, const struct nft_data *data,
-		  enum nft_data_types type, unsigned int len);
+		  enum nft_data_types type, unsigned int len,
+		  enum nft_scope scope);
 
 static inline enum nft_data_types nft_dreg_to_type(enum nft_registers reg)
 {
@@ -178,7 +187,8 @@ struct nft_set_ops {
 	unsigned int			(*privsize)(const struct nlattr * const nla[]);
 	int				(*init)(const struct nft_set *set,
 						const struct nlattr * const nla[]);
-	void				(*destroy)(const struct nft_set *set);
+	void				(*destroy)(const struct nft_ctx *ctx,
+						   const struct nft_set *set);
 
 	struct list_head		list;
 	struct module			*owner;
@@ -294,7 +304,8 @@ struct nft_expr_ops {
 	void				(*destroy)(const struct nft_ctx *ctx,
 						   const struct nft_expr *expr);
 	int				(*dump)(struct sk_buff *skb,
-						const struct nft_expr *expr);
+						const struct nft_expr *expr,
+						enum nft_scope scope);
 	int				(*validate)(const struct nft_ctx *ctx,
 						    const struct nft_expr *expr,
 						    const struct nft_data **data);
diff --git a/include/net/netfilter/nf_tables_core.h b/include/net/netfilter/nf_tables_core.h
index 98b9c74..41ced3e 100644
--- a/include/net/netfilter/nf_tables_core.h
+++ b/include/net/netfilter/nf_tables_core.h
@@ -105,6 +105,21 @@ int nf_tables_expr_parse(const struct nft_ctx *ctx,
 const struct nft_expr_type *__nft_expr_type_get(u8 family,
 						const struct nlattr *nla);
 void nf_tables_expr_destroy(const struct nft_ctx *ctx, struct nft_expr *expr);
-int nf_tables_fill_expr_info(struct sk_buff *skb, const struct nft_expr *expr);
+int nf_tables_fill_expr_info(struct sk_buff *skb, const struct nft_expr *expr,
+			     enum nft_scope scope);
+
+struct nft_verdict_ops {
+	int	(*init)(const struct nft_ctx *ctx, struct nft_data *data,
+			struct nft_data_desc *desc, const struct nlattr *nla);
+	int	(*validate)(const struct nft_ctx *ctx, enum nft_registers reg,
+			    const struct nft_data *data,
+			    enum nft_data_types type);
+	void	(*uninit)(const struct nft_data *data);
+	int	(*dump)(struct sk_buff *skb, const struct nft_data *data);
+};
+
+void nft_verdict_ops_register(enum nft_scope scope,
+			      const struct nft_verdict_ops *ops);
+void nft_verdict_ops_unregister(enum nft_scope scope);
 
 #endif /* _NET_NF_TABLES_CORE_H */
diff --git a/include/net/netfilter/nft_reject.h b/include/net/netfilter/nft_reject.h
index 36b0da2..2f6d96d 100644
--- a/include/net/netfilter/nft_reject.h
+++ b/include/net/netfilter/nft_reject.h
@@ -12,7 +12,8 @@ int nft_reject_init(const struct nft_ctx *ctx,
 		    const struct nft_expr *expr,
 		    const struct nlattr * const tb[]);
 
-int nft_reject_dump(struct sk_buff *skb, const struct nft_expr *expr);
+int nft_reject_dump(struct sk_buff *skb, const struct nft_expr *expr,
+		    enum nft_scope scope);
 
 void nft_reject_ipv4_eval(const struct nft_expr *expr,
 			  struct nft_data data[NFT_REG_MAX + 1],
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 29d6745..c616fea 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1075,6 +1075,7 @@ static void nft_ctx_init(struct nft_ctx *ctx,
 	ctx->table = table;
 	ctx->chain = chain;
 	ctx->nla   = nla;
+	ctx->scope = NFT_SCOPE_NF;
 }
 
 /*
@@ -1160,7 +1161,7 @@ static int nf_tables_fill_rule_info(struct sk_buff *skb, u32 portid, u32 seq,
 		struct nlattr *elem = nla_nest_start(skb, NFTA_LIST_ELEM);
 		if (elem == NULL)
 			goto nla_put_failure;
-		if (nf_tables_fill_expr_info(skb, expr) < 0)
+		if (nf_tables_fill_expr_info(skb, expr, NFT_SCOPE_NF) < 0)
 			goto nla_put_failure;
 		nla_nest_end(skb, elem);
 	}
@@ -2282,7 +2283,7 @@ static void nf_tables_set_destroy(const struct nft_ctx *ctx, struct nft_set *set
 	list_del(&set->list);
 	nf_tables_set_notify(ctx, set, NFT_MSG_DELSET);
 
-	set->ops->destroy(set);
+	set->ops->destroy(ctx, set);
 	module_put(set->ops->owner);
 	kfree(set);
 }
@@ -2425,14 +2426,14 @@ static int nf_tables_fill_setelem(struct sk_buff *skb,
 		goto nla_put_failure;
 
 	if (nft_data_dump(skb, NFTA_SET_ELEM_KEY, &elem->key, NFT_DATA_VALUE,
-			  set->klen) < 0)
+			  set->klen, NFT_SCOPE_NF) < 0)
 		goto nla_put_failure;
 
 	if (set->flags & NFT_SET_MAP &&
 	    !(elem->flags & NFT_SET_ELEM_INTERVAL_END) &&
 	    nft_data_dump(skb, NFTA_SET_ELEM_DATA, &elem->data,
 			  set->dtype == NFT_DATA_VERDICT ? NFT_DATA_VERDICT : NFT_DATA_VALUE,
-			  set->dlen) < 0)
+			  set->dlen, NFT_SCOPE_NF) < 0)
 		goto nla_put_failure;
 
 	if (elem->flags != 0)
@@ -2624,6 +2625,7 @@ static int nft_add_set_elem(const struct nft_ctx *ctx, struct nft_set *set,
 				.afi	= ctx->afi,
 				.table	= ctx->table,
 				.chain	= binding->chain,
+				.scope  = NFT_SCOPE_NF,
 			};
 
 			err = nft_validate_data_load(&bind_ctx, dreg,
@@ -2641,9 +2643,9 @@ static int nft_add_set_elem(const struct nft_ctx *ctx, struct nft_set *set,
 
 err3:
 	if (nla[NFTA_SET_ELEM_DATA] != NULL)
-		nft_data_uninit(&elem.data, d2.type);
+		nft_data_uninit(&elem.data, d2.type, NFT_SCOPE_NF);
 err2:
-	nft_data_uninit(&elem.key, d1.type);
+	nft_data_uninit(&elem.key, d1.type, NFT_SCOPE_NF);
 err1:
 	return err;
 }
@@ -2706,12 +2708,12 @@ static int nft_del_setelem(const struct nft_ctx *ctx, struct nft_set *set,
 
 	set->ops->remove(set, &elem);
 
-	nft_data_uninit(&elem.key, NFT_DATA_VALUE);
+	nft_data_uninit(&elem.key, NFT_DATA_VALUE, NFT_SCOPE_NF);
 	if (set->flags & NFT_SET_MAP)
-		nft_data_uninit(&elem.data, set->dtype);
+		nft_data_uninit(&elem.data, set->dtype, NFT_SCOPE_NF);
 
 err2:
-	nft_data_uninit(&elem.key, desc.type);
+	nft_data_uninit(&elem.key, desc.type, NFT_SCOPE_NF);
 err1:
 	return err;
 }
@@ -2922,42 +2924,6 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
 }
 
 /**
- *	nft_validate_input_register - validate an expressions' input register
- *
- *	@reg: the register number
- *
- * 	Validate that the input register is one of the general purpose
- * 	registers.
- */
-int nft_validate_input_register(enum nft_registers reg)
-{
-	if (reg <= NFT_REG_VERDICT)
-		return -EINVAL;
-	if (reg > NFT_REG_MAX)
-		return -ERANGE;
-	return 0;
-}
-EXPORT_SYMBOL_GPL(nft_validate_input_register);
-
-/**
- *	nft_validate_output_register - validate an expressions' output register
- *
- *	@reg: the register number
- *
- * 	Validate that the output register is one of the general purpose
- * 	registers or the verdict register.
- */
-int nft_validate_output_register(enum nft_registers reg)
-{
-	if (reg < NFT_REG_VERDICT)
-		return -EINVAL;
-	if (reg > NFT_REG_MAX)
-		return -ERANGE;
-	return 0;
-}
-EXPORT_SYMBOL_GPL(nft_validate_output_register);
-
-/**
  *	nft_validate_data_load - validate an expressions' data load
  *
  *	@ctx: context of the expression performing the load
@@ -2970,37 +2936,27 @@ EXPORT_SYMBOL_GPL(nft_validate_output_register);
  * 	that its runtime gathered data, which is always of type
  * 	NFT_DATA_VALUE.
  */
-int nft_validate_data_load(const struct nft_ctx *ctx, enum nft_registers reg,
-			   const struct nft_data *data,
-			   enum nft_data_types type)
+static int nft_validate_verdict(const struct nft_ctx *ctx,
+				enum nft_registers reg,
+				const struct nft_data *data,
+				enum nft_data_types type)
 {
 	int err;
 
-	switch (reg) {
-	case NFT_REG_VERDICT:
-		if (data == NULL || type != NFT_DATA_VERDICT)
-			return -EINVAL;
-
-		if (data->verdict == NFT_GOTO || data->verdict == NFT_JUMP) {
-			err = nf_tables_check_loops(ctx, data->chain);
-			if (err < 0)
-				return err;
+	if (data->verdict == NFT_GOTO || data->verdict == NFT_JUMP) {
+		err = nf_tables_check_loops(ctx, data->chain);
+		if (err < 0)
+			return err;
 
-			if (ctx->chain->level + 1 > data->chain->level) {
-				if (ctx->chain->level + 1 == NFT_JUMP_STACK_SIZE)
-					return -EMLINK;
-				data->chain->level = ctx->chain->level + 1;
-			}
+		if (ctx->chain->level + 1 > data->chain->level) {
+			if (ctx->chain->level + 1 == NFT_JUMP_STACK_SIZE)
+				return -EMLINK;
+			data->chain->level = ctx->chain->level + 1;
 		}
-
-		return 0;
-	default:
-		if (data != NULL && type != NFT_DATA_VALUE)
-			return -EINVAL;
-		return 0;
 	}
+
+	return 0;
 }
-EXPORT_SYMBOL_GPL(nft_validate_data_load);
 
 static const struct nla_policy nft_verdict_policy[NFTA_VERDICT_MAX + 1] = {
 	[NFTA_VERDICT_CODE]	= { .type = NLA_U32 },
@@ -3094,131 +3050,6 @@ nla_put_failure:
 	return -1;
 }
 
-static int nft_do_value_init(const struct nft_ctx *ctx, struct nft_data *data,
-			     struct nft_data_desc *desc,
-			     const struct nlattr *nla)
-{
-	unsigned int len;
-
-	len = nla_len(nla);
-	if (len == 0)
-		return -EINVAL;
-	if (len > sizeof(data->data))
-		return -EOVERFLOW;
-
-	nla_memcpy(data->data, nla, sizeof(data->data));
-	desc->type = NFT_DATA_VALUE;
-	desc->len  = len;
-	return 0;
-}
-
-static int nft_value_dump(struct sk_buff *skb, const struct nft_data *data,
-			  unsigned int len)
-{
-	return nla_put(skb, NFTA_DATA_VALUE, len, data->data);
-}
-
-static const struct nla_policy nft_data_policy[NFTA_DATA_MAX + 1] = {
-	[NFTA_DATA_VALUE]	= { .type = NLA_BINARY,
-				    .len  = FIELD_SIZEOF(struct nft_data, data) },
-	[NFTA_DATA_VERDICT]	= { .type = NLA_NESTED },
-};
-
-static int nft_do_data_init(const struct nft_ctx *ctx, struct nft_data *data,
-			    struct nft_data_desc *desc,
-			    const struct nlattr *nla, bool allow_verdict)
-{
-	struct nlattr *tb[NFTA_DATA_MAX + 1];
-	int err;
-
-	err = nla_parse_nested(tb, NFTA_DATA_MAX, nla, nft_data_policy);
-	if (err < 0)
-		return err;
-
-	if (tb[NFTA_DATA_VALUE])
-		return nft_do_value_init(ctx, data, desc, tb[NFTA_DATA_VALUE]);
-	if (tb[NFTA_DATA_VERDICT] && allow_verdict)
-		return nft_verdict_init(ctx, data, desc, tb[NFTA_DATA_VERDICT]);
-	return -EINVAL;
-}
-
-/**
- *	nft_data_init - parse nf_tables data netlink attributes
- *
- *	@ctx: context of the expression using the data
- *	@data: destination struct nft_data
- *	@desc: data description
- *	@nla: netlink attribute containing data
- *
- *	Parse the netlink data attributes and initialize a struct nft_data.
- *	The type and length of data are returned in the data description.
- *
- *	The caller can indicate that it only wants to accept data of type
- *	NFT_DATA_VALUE by passing NULL for the ctx argument.
- */
-int nft_data_init(const struct nft_ctx *ctx, struct nft_data *data,
-		  struct nft_data_desc *desc, const struct nlattr *nla)
-{
-	return nft_do_data_init(ctx, data, desc, nla, true);
-}
-EXPORT_SYMBOL_GPL(nft_data_init);
-
-int nft_value_init(const struct nft_ctx *ctx, struct nft_data *data,
-		   struct nft_data_desc *desc, const struct nlattr *nla)
-{
-	return nft_do_data_init(ctx, data, desc, nla, false);
-}
-EXPORT_SYMBOL_GPL(nft_value_init);
-
-/**
- *	nft_data_uninit - release a nft_data item
- *
- *	@data: struct nft_data to release
- *	@type: type of data
- *
- *	Release a nft_data item. NFT_DATA_VALUE types can be silently discarded,
- *	all others need to be released by calling this function.
- */
-void nft_data_uninit(const struct nft_data *data, enum nft_data_types type)
-{
-	switch (type) {
-	case NFT_DATA_VALUE:
-		return;
-	case NFT_DATA_VERDICT:
-		return nft_verdict_uninit(data);
-	default:
-		WARN_ON(1);
-	}
-}
-EXPORT_SYMBOL_GPL(nft_data_uninit);
-
-int nft_data_dump(struct sk_buff *skb, int attr, const struct nft_data *data,
-		  enum nft_data_types type, unsigned int len)
-{
-	struct nlattr *nest;
-	int err;
-
-	nest = nla_nest_start(skb, attr);
-	if (nest == NULL)
-		return -1;
-
-	switch (type) {
-	case NFT_DATA_VALUE:
-		err = nft_value_dump(skb, data, len);
-		break;
-	case NFT_DATA_VERDICT:
-		err = nft_verdict_dump(skb, data);
-		break;
-	default:
-		err = -EINVAL;
-		WARN_ON(1);
-	}
-
-	nla_nest_end(skb, nest);
-	return err;
-}
-EXPORT_SYMBOL_GPL(nft_data_dump);
-
 static int nf_tables_init_net(struct net *net)
 {
 	INIT_LIST_HEAD(&net->nft.af_info);
@@ -3230,6 +3061,13 @@ static struct pernet_operations nf_tables_net_ops = {
 	.init	= nf_tables_init_net,
 };
 
+static struct nft_verdict_ops nft_verdict_ops = {
+	.init		= nft_verdict_init,
+	.validate	= nft_validate_verdict,
+	.uninit		= nft_verdict_uninit,
+	.dump		= nft_verdict_dump,
+};
+
 static int __init nf_tables_module_init(void)
 {
 	int err;
@@ -3245,13 +3083,22 @@ static int __init nf_tables_module_init(void)
 	if (err < 0)
 		goto err2;
 
+	nft_verdict_ops_register(NFT_SCOPE_NF, &nft_verdict_ops);
+
 	err = nfnetlink_subsys_register(&nf_tables_subsys);
 	if (err < 0)
 		goto err3;
 
 	pr_info("nf_tables: (c) 2007-2009 Patrick McHardy <kaber@trash.net>\n");
-	return register_pernet_subsys(&nf_tables_net_ops);
+	err = register_pernet_subsys(&nf_tables_net_ops);
+	if (err < 0)
+		goto err4;
+
+	return err;
+err4:
+	nfnetlink_subsys_unregister(&nf_tables_subsys);
 err3:
+	nft_verdict_ops_unregister(NFT_SCOPE_NF);
 	nf_tables_core_module_exit();
 err2:
 	kfree(info);
@@ -3263,6 +3110,7 @@ static void __exit nf_tables_module_exit(void)
 {
 	unregister_pernet_subsys(&nf_tables_net_ops);
 	nfnetlink_subsys_unregister(&nf_tables_subsys);
+	nft_verdict_ops_unregister(NFT_SCOPE_NF);
 	nf_tables_core_module_exit();
 	kfree(info);
 }
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 20bd1f0..fe427d4 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -67,7 +67,8 @@ const struct nft_expr_type *__nft_expr_type_get(u8 family,
 }
 EXPORT_SYMBOL(__nft_expr_type_get);
 
-const struct nft_expr_type *nft_expr_type_get(u8 family, const struct nlattr *nla)
+static const struct nft_expr_type *nft_expr_type_get(u8 family,
+						     const struct nlattr *nla)
 {
 	const struct nft_expr_type *type;
 
@@ -80,7 +81,6 @@ const struct nft_expr_type *nft_expr_type_get(u8 family, const struct nlattr *nl
 
 	return ERR_PTR(-ENOENT);
 }
-EXPORT_SYMBOL_GPL(nft_expr_type_get);
 
 static const struct nla_policy nft_expr_policy[NFTA_EXPR_MAX + 1] = {
 	[NFTA_EXPR_NAME]	= { .type = NLA_STRING },
@@ -165,7 +165,8 @@ void nf_tables_expr_destroy(const struct nft_ctx *ctx, struct nft_expr *expr)
 }
 EXPORT_SYMBOL_GPL(nf_tables_expr_destroy);
 
-int nf_tables_fill_expr_info(struct sk_buff *skb, const struct nft_expr *expr)
+int nf_tables_fill_expr_info(struct sk_buff *skb, const struct nft_expr *expr,
+			     enum nft_scope scope)
 {
 	if (nla_put_string(skb, NFTA_EXPR_NAME, expr->ops->type->name))
 		goto nla_put_failure;
@@ -174,7 +175,7 @@ int nf_tables_fill_expr_info(struct sk_buff *skb, const struct nft_expr *expr)
 		struct nlattr *data = nla_nest_start(skb, NFTA_EXPR_DATA);
 		if (data == NULL)
 			goto nla_put_failure;
-		if (expr->ops->dump(skb, expr) < 0)
+		if (expr->ops->dump(skb, expr, scope) < 0)
 			goto nla_put_failure;
 		nla_nest_end(skb, data);
 	}
@@ -186,6 +187,221 @@ nla_put_failure:
 };
 EXPORT_SYMBOL_GPL(nf_tables_fill_expr_info);
 
+/**
+ *	nft_validate_input_register - validate an expressions' input register
+ *
+ *	@reg: the register number
+ *
+ *	Validate that the input register is one of the general purpose
+ *	registers.
+ */
+int nft_validate_input_register(enum nft_registers reg)
+{
+	if (reg <= NFT_REG_VERDICT)
+		return -EINVAL;
+	if (reg > NFT_REG_MAX)
+		return -ERANGE;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nft_validate_input_register);
+
+/**
+ *	nft_validate_output_register - validate an expressions' output register
+ *
+ *	@reg: the register number
+ *
+ *	Validate that the output register is one of the general purpose
+ *	registers or the verdict register.
+ */
+int nft_validate_output_register(enum nft_registers reg)
+{
+	if (reg < NFT_REG_VERDICT)
+		return -EINVAL;
+	if (reg > NFT_REG_MAX)
+		return -ERANGE;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nft_validate_output_register);
+
+static const struct nft_verdict_ops *verdict_ops[NFT_SCOPE_MAX];
+
+/**
+ *	nft_validate_data_load - validate an expressions' data load
+ *
+ *	@ctx: context of the expression performing the load
+ *	@reg: the destination register number
+ *	@data: the data to load
+ *	@type: the data type
+ *
+ *	Validate that a data load uses the appropriate data type for
+ *	the destination register. A value of NULL for the data means
+ *	that its runtime gathered data, which is always of type
+ *	NFT_DATA_VALUE.
+ */
+int nft_validate_data_load(const struct nft_ctx *ctx, enum nft_registers reg,
+			   const struct nft_data *data,
+			   enum nft_data_types type)
+{
+	switch (reg) {
+	case NFT_REG_VERDICT:
+		if (data == NULL || type != NFT_DATA_VERDICT)
+			return -EINVAL;
+
+		return verdict_ops[ctx->scope]->validate(ctx, reg, data, type);
+	default:
+		if (data != NULL && type != NFT_DATA_VALUE)
+			return -EINVAL;
+		return 0;
+	}
+}
+EXPORT_SYMBOL_GPL(nft_validate_data_load);
+
+/**
+ *	nft_data_uninit - release a nft_data item
+ *
+ *	@data: struct nft_data to release
+ *	@type: type of data
+ *	@scope: scope of this uninitialization
+ *
+ *	Release a nft_data item. NFT_DATA_VALUE types can be silently discarded,
+ *	all others need to be released by calling this function.
+ */
+void nft_data_uninit(const struct nft_data *data, enum nft_data_types type,
+		     enum nft_scope scope)
+{
+	switch (type) {
+	case NFT_DATA_VALUE:
+		return;
+	case NFT_DATA_VERDICT:
+		verdict_ops[scope]->uninit(data);
+		break;
+	default:
+		WARN_ON(1);
+	}
+}
+EXPORT_SYMBOL_GPL(nft_data_uninit);
+
+static int nft_do_value_init(const struct nft_ctx *ctx, struct nft_data *data,
+			     struct nft_data_desc *desc,
+			     const struct nlattr *nla)
+{
+	unsigned int len;
+
+	len = nla_len(nla);
+	if (len == 0)
+		return -EINVAL;
+	if (len > sizeof(data->data))
+		return -EOVERFLOW;
+
+	nla_memcpy(data->data, nla, sizeof(data->data));
+	desc->type = NFT_DATA_VALUE;
+	desc->len  = len;
+	return 0;
+}
+
+static int nft_value_dump(struct sk_buff *skb, const struct nft_data *data,
+			  unsigned int len)
+{
+	return nla_put(skb, NFTA_DATA_VALUE, len, data->data);
+}
+
+static const struct nla_policy nft_data_policy[NFTA_DATA_MAX + 1] = {
+	[NFTA_DATA_VALUE]	= { .type = NLA_BINARY,
+				    .len  = FIELD_SIZEOF(struct nft_data, data) },
+	[NFTA_DATA_VERDICT]	= { .type = NLA_NESTED },
+};
+
+int nft_do_data_init(const struct nft_ctx *ctx, struct nft_data *data,
+		     struct nft_data_desc *desc, const struct nlattr *nla,
+		     bool allow_verdict)
+{
+	struct nlattr *tb[NFTA_DATA_MAX + 1];
+	int err;
+
+	err = nla_parse_nested(tb, NFTA_DATA_MAX, nla, nft_data_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[NFTA_DATA_VALUE])
+		return nft_do_value_init(ctx, data, desc, tb[NFTA_DATA_VALUE]);
+	if (tb[NFTA_DATA_VERDICT] && allow_verdict) {
+		return verdict_ops[ctx->scope]->init(ctx, data, desc,
+						     tb[NFTA_DATA_VERDICT]);
+	}
+	return -EINVAL;
+}
+
+/**
+ *	nft_data_init - parse nf_tables data netlink attributes
+ *
+ *	@ctx: context of the expression using the data
+ *	@data: destination struct nft_data
+ *	@desc: data description
+ *	@nla: netlink attribute containing data
+ *
+ *	Parse the netlink data attributes and initialize a struct nft_data.
+ *	The type and length of data are returned in the data description.
+ *
+ *	The caller can indicate that it only wants to accept data of type
+ *	NFT_DATA_VALUE by passing NULL for the ctx argument.
+ */
+int nft_data_init(const struct nft_ctx *ctx, struct nft_data *data,
+		  struct nft_data_desc *desc, const struct nlattr *nla)
+{
+	return nft_do_data_init(ctx, data, desc, nla, true);
+}
+EXPORT_SYMBOL_GPL(nft_data_init);
+
+int nft_value_init(const struct nft_ctx *ctx, struct nft_data *data,
+		   struct nft_data_desc *desc, const struct nlattr *nla)
+{
+	return nft_do_data_init(ctx, data, desc, nla, false);
+}
+EXPORT_SYMBOL_GPL(nft_value_init);
+
+int nft_data_dump(struct sk_buff *skb, int attr, const struct nft_data *data,
+		  enum nft_data_types type, unsigned int len,
+		  enum nft_scope scope)
+{
+	struct nlattr *nest;
+	int err;
+
+	nest = nla_nest_start(skb, attr);
+	if (nest == NULL)
+		return -1;
+
+	switch (type) {
+	case NFT_DATA_VALUE:
+		err = nft_value_dump(skb, data, len);
+		break;
+	case NFT_DATA_VERDICT:
+		err = verdict_ops[scope]->dump(skb, data);
+		break;
+	default:
+		err = -EINVAL;
+		WARN_ON(1);
+	}
+
+	nla_nest_end(skb, nest);
+	return err;
+}
+EXPORT_SYMBOL_GPL(nft_data_dump);
+
+void nft_verdict_ops_register(enum nft_scope scope,
+			      const struct nft_verdict_ops *ops)
+{
+	BUG_ON(scope >= NFT_SCOPE_MAX || verdict_ops[scope]);
+	verdict_ops[scope] = ops;
+}
+EXPORT_SYMBOL_GPL(nft_verdict_ops_register);
+
+void nft_verdict_ops_unregister(enum nft_scope scope)
+{
+	BUG_ON(scope >= NFT_SCOPE_MAX || !verdict_ops[scope]);
+	verdict_ops[scope] = NULL;
+}
+EXPORT_SYMBOL_GPL(nft_verdict_ops_unregister);
+
 static __init int nf_tables_core_init(void)
 {
 	int err;
diff --git a/net/netfilter/nft_bitwise.c b/net/netfilter/nft_bitwise.c
index 5f944fb..9e87b67 100644
--- a/net/netfilter/nft_bitwise.c
+++ b/net/netfilter/nft_bitwise.c
@@ -78,13 +78,13 @@ static int nft_bitwise_init(const struct nft_ctx *ctx,
 
 	priv->len = ntohl(nla_get_be32(tb[NFTA_BITWISE_LEN]));
 
-	err = nft_value_init(NULL, &priv->mask, &d1, tb[NFTA_BITWISE_MASK]);
+	err = nft_value_init(ctx, &priv->mask, &d1, tb[NFTA_BITWISE_MASK]);
 	if (err < 0)
 		return err;
 	if (d1.len != priv->len)
 		return -EINVAL;
 
-	err = nft_value_init(NULL, &priv->xor, &d2, tb[NFTA_BITWISE_XOR]);
+	err = nft_value_init(ctx, &priv->xor, &d2, tb[NFTA_BITWISE_XOR]);
 	if (err < 0)
 		return err;
 	if (d2.len != priv->len)
@@ -93,7 +93,8 @@ static int nft_bitwise_init(const struct nft_ctx *ctx,
 	return 0;
 }
 
-static int nft_bitwise_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_bitwise_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			    enum nft_scope scope)
 {
 	const struct nft_bitwise *priv = nft_expr_priv(expr);
 
@@ -105,11 +106,11 @@ static int nft_bitwise_dump(struct sk_buff *skb, const struct nft_expr *expr)
 		goto nla_put_failure;
 
 	if (nft_data_dump(skb, NFTA_BITWISE_MASK, &priv->mask,
-			  NFT_DATA_VALUE, priv->len) < 0)
+			  NFT_DATA_VALUE, priv->len, scope) < 0)
 		goto nla_put_failure;
 
 	if (nft_data_dump(skb, NFTA_BITWISE_XOR, &priv->xor,
-			  NFT_DATA_VALUE, priv->len) < 0)
+			  NFT_DATA_VALUE, priv->len, scope) < 0)
 		goto nla_put_failure;
 
 	return 0;
diff --git a/net/netfilter/nft_byteorder.c b/net/netfilter/nft_byteorder.c
index c39ed8d..baca196 100644
--- a/net/netfilter/nft_byteorder.c
+++ b/net/netfilter/nft_byteorder.c
@@ -125,7 +125,8 @@ static int nft_byteorder_init(const struct nft_ctx *ctx,
 	return 0;
 }
 
-static int nft_byteorder_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_byteorder_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			      enum nft_scope scope)
 {
 	const struct nft_byteorder *priv = nft_expr_priv(expr);
 
diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index 0252f63..3117110 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -78,14 +78,15 @@ static int nft_cmp_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	priv->sreg = ntohl(nla_get_be32(tb[NFTA_CMP_SREG]));
 	priv->op = ntohl(nla_get_be32(tb[NFTA_CMP_OP]));
 
-	err = nft_value_init(NULL, &priv->data, &desc, tb[NFTA_CMP_DATA]);
+	err = nft_value_init(ctx, &priv->data, &desc, tb[NFTA_CMP_DATA]);
 	BUG_ON(err < 0);
 
 	priv->len = desc.len;
 	return 0;
 }
 
-static int nft_cmp_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_cmp_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			enum nft_scope scope)
 {
 	const struct nft_cmp_expr *priv = nft_expr_priv(expr);
 
@@ -95,7 +96,7 @@ static int nft_cmp_dump(struct sk_buff *skb, const struct nft_expr *expr)
 		goto nla_put_failure;
 
 	if (nft_data_dump(skb, NFTA_CMP_DATA, &priv->data,
-			  NFT_DATA_VALUE, priv->len) < 0)
+			  NFT_DATA_VALUE, priv->len, scope) < 0)
 		goto nla_put_failure;
 	return 0;
 
@@ -124,7 +125,7 @@ static int nft_cmp_fast_init(const struct nft_ctx *ctx,
 
 	priv->sreg = ntohl(nla_get_be32(tb[NFTA_CMP_SREG]));
 
-	err = nft_value_init(NULL, &data, &desc, tb[NFTA_CMP_DATA]);
+	err = nft_value_init(ctx, &data, &desc, tb[NFTA_CMP_DATA]);
 	BUG_ON(err < 0);
 	desc.len *= BITS_PER_BYTE;
 
@@ -134,7 +135,8 @@ static int nft_cmp_fast_init(const struct nft_ctx *ctx,
 	return 0;
 }
 
-static int nft_cmp_fast_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_cmp_fast_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			     enum nft_scope scope)
 {
 	const struct nft_cmp_fast_expr *priv = nft_expr_priv(expr);
 	struct nft_data data;
@@ -146,7 +148,8 @@ static int nft_cmp_fast_dump(struct sk_buff *skb, const struct nft_expr *expr)
 
 	data.data[0] = priv->data;
 	if (nft_data_dump(skb, NFTA_CMP_DATA, &data,
-			  NFT_DATA_VALUE, priv->len / BITS_PER_BYTE) < 0)
+			  NFT_DATA_VALUE, priv->len / BITS_PER_BYTE,
+			  scope) < 0)
 		goto nla_put_failure;
 	return 0;
 
@@ -195,7 +198,7 @@ nft_cmp_select_ops(const struct nft_ctx *ctx, const struct nlattr * const tb[])
 		return ERR_PTR(-EINVAL);
 	}
 
-	err = nft_value_init(NULL, &data, &desc, tb[NFTA_CMP_DATA]);
+	err = nft_value_init(ctx, &data, &desc, tb[NFTA_CMP_DATA]);
 	if (err < 0)
 		return ERR_PTR(err);
 
diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 8a779be..7426692 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -227,7 +227,8 @@ target_dump_info(struct sk_buff *skb, const struct xt_target *t, const void *in)
 	return ret;
 }
 
-static int nft_target_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_target_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			   enum nft_scope scope)
 {
 	const struct xt_target *target = expr->ops->data;
 	void *info = nft_expr_priv(expr);
@@ -423,7 +424,8 @@ static inline int nft_compat_match_offset(struct xt_match *match)
 #endif
 }
 
-static int nft_match_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_match_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			  enum nft_scope scope)
 {
 	void *info = nft_expr_priv(expr);
 	struct xt_match *match = expr->ops->data;
diff --git a/net/netfilter/nft_counter.c b/net/netfilter/nft_counter.c
index c89ee48..eb6354c 100644
--- a/net/netfilter/nft_counter.c
+++ b/net/netfilter/nft_counter.c
@@ -35,7 +35,8 @@ static void nft_counter_eval(const struct nft_expr *expr,
 	write_sequnlock_bh(&priv->lock);
 }
 
-static int nft_counter_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_counter_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			    enum nft_scope scope)
 {
 	struct nft_counter *priv = nft_expr_priv(expr);
 	unsigned int seq;
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index bd0d41e..09d4f28 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -324,7 +324,8 @@ static void nft_ct_destroy(const struct nft_ctx *ctx,
 	nft_ct_l3proto_module_put(ctx->afi->family);
 }
 
-static int nft_ct_get_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_ct_get_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			   enum nft_scope scope)
 {
 	const struct nft_ct *priv = nft_expr_priv(expr);
 
@@ -351,7 +352,8 @@ nla_put_failure:
 	return -1;
 }
 
-static int nft_ct_set_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_ct_set_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			   enum nft_scope scope)
 {
 	const struct nft_ct *priv = nft_expr_priv(expr);
 
@@ -385,8 +387,7 @@ static const struct nft_expr_ops nft_ct_set_ops = {
 };
 
 static const struct nft_expr_ops *
-nft_ct_select_ops(const struct nft_ctx *ctx,
-		    const struct nlattr * const tb[])
+nft_ct_select_ops(const struct nft_ctx *ctx, const struct nlattr * const tb[])
 {
 	if (tb[NFTA_CT_KEY] == NULL)
 		return ERR_PTR(-EINVAL);
diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index 55c939f..7e55a78 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -80,7 +80,8 @@ static int nft_exthdr_init(const struct nft_ctx *ctx,
 	return nft_validate_data_load(ctx, priv->dreg, NULL, NFT_DATA_VALUE);
 }
 
-static int nft_exthdr_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_exthdr_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			   enum nft_scope scope)
 {
 	const struct nft_exthdr *priv = nft_expr_priv(expr);
 
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 6a1acde..d0e53f9 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -245,12 +245,13 @@ static int nft_hash_insert(const struct nft_set *set,
 	return 0;
 }
 
-static void nft_hash_elem_destroy(const struct nft_set *set,
+static void nft_hash_elem_destroy(const struct nft_ctx *ctx,
+				  const struct nft_set *set,
 				  struct nft_hash_elem *he)
 {
-	nft_data_uninit(&he->key, NFT_DATA_VALUE);
+	nft_data_uninit(&he->key, NFT_DATA_VALUE, ctx->scope);
 	if (set->flags & NFT_SET_MAP)
-		nft_data_uninit(he->data, set->dtype);
+		nft_data_uninit(he->data, set->dtype, ctx->scope);
 	kfree(he);
 }
 
@@ -351,7 +352,8 @@ static int nft_hash_init(const struct nft_set *set,
 	return 0;
 }
 
-static void nft_hash_destroy(const struct nft_set *set)
+static void nft_hash_destroy(const struct nft_ctx *ctx,
+			     const struct nft_set *set)
 {
 	const struct nft_hash *priv = nft_set_priv(set);
 	const struct nft_hash_table *tbl = nft_dereference(priv->tbl);
@@ -362,7 +364,7 @@ static void nft_hash_destroy(const struct nft_set *set)
 		for (he = nft_dereference(tbl->buckets[i]); he != NULL;
 		     he = next) {
 			next = nft_dereference(he->next);
-			nft_hash_elem_destroy(set, he);
+			nft_hash_elem_destroy(ctx, set, he);
 		}
 	}
 	kfree(tbl);
diff --git a/net/netfilter/nft_immediate.c b/net/netfilter/nft_immediate.c
index 810385e..ae359f4 100644
--- a/net/netfilter/nft_immediate.c
+++ b/net/netfilter/nft_immediate.c
@@ -66,7 +66,7 @@ static int nft_immediate_init(const struct nft_ctx *ctx,
 	return 0;
 
 err1:
-	nft_data_uninit(&priv->data, desc.type);
+	nft_data_uninit(&priv->data, desc.type, ctx->scope);
 	return err;
 }
 
@@ -74,10 +74,12 @@ static void nft_immediate_destroy(const struct nft_ctx *ctx,
 				  const struct nft_expr *expr)
 {
 	const struct nft_immediate_expr *priv = nft_expr_priv(expr);
-	return nft_data_uninit(&priv->data, nft_dreg_to_type(priv->dreg));
+	return nft_data_uninit(&priv->data, nft_dreg_to_type(priv->dreg),
+			       ctx->scope);
 }
 
-static int nft_immediate_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_immediate_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			      enum nft_scope scope)
 {
 	const struct nft_immediate_expr *priv = nft_expr_priv(expr);
 
@@ -85,7 +87,7 @@ static int nft_immediate_dump(struct sk_buff *skb, const struct nft_expr *expr)
 		goto nla_put_failure;
 
 	return nft_data_dump(skb, NFTA_IMMEDIATE_DATA, &priv->data,
-			     nft_dreg_to_type(priv->dreg), priv->dlen);
+			     nft_dreg_to_type(priv->dreg), priv->dlen, scope);
 
 nla_put_failure:
 	return -1;
diff --git a/net/netfilter/nft_limit.c b/net/netfilter/nft_limit.c
index 85da5bd..6c058bd 100644
--- a/net/netfilter/nft_limit.c
+++ b/net/netfilter/nft_limit.c
@@ -70,7 +70,8 @@ static int nft_limit_init(const struct nft_ctx *ctx,
 	return 0;
 }
 
-static int nft_limit_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_limit_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			  enum nft_scope scope)
 {
 	const struct nft_limit *priv = nft_expr_priv(expr);
 
diff --git a/net/netfilter/nft_log.c b/net/netfilter/nft_log.c
index 10cfb15..2684262 100644
--- a/net/netfilter/nft_log.c
+++ b/net/netfilter/nft_log.c
@@ -83,7 +83,8 @@ static void nft_log_destroy(const struct nft_ctx *ctx,
 		kfree(priv->prefix);
 }
 
-static int nft_log_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_log_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			enum nft_scope scope)
 {
 	const struct nft_log *priv = nft_expr_priv(expr);
 	const struct nf_loginfo *li = &priv->loginfo;
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index 7fd2bea..38f6b6d 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -97,7 +97,8 @@ static void nft_lookup_destroy(const struct nft_ctx *ctx,
 	nf_tables_unbind_set(ctx, priv->set, &priv->binding);
 }
 
-static int nft_lookup_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_lookup_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			   enum nft_scope scope)
 {
 	const struct nft_lookup *priv = nft_expr_priv(expr);
 
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index e8254ad..82c40d8 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -246,8 +246,8 @@ static int nft_meta_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	return 0;
 }
 
-static int nft_meta_get_dump(struct sk_buff *skb,
-			     const struct nft_expr *expr)
+static int nft_meta_get_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			     enum nft_scope scope)
 {
 	const struct nft_meta *priv = nft_expr_priv(expr);
 
@@ -261,8 +261,8 @@ nla_put_failure:
 	return -1;
 }
 
-static int nft_meta_set_dump(struct sk_buff *skb,
-			     const struct nft_expr *expr)
+static int nft_meta_set_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			     enum nft_scope scope)
 {
 	const struct nft_meta *priv = nft_expr_priv(expr);
 
diff --git a/net/netfilter/nft_nat.c b/net/netfilter/nft_nat.c
index a0195d2..d890584 100644
--- a/net/netfilter/nft_nat.c
+++ b/net/netfilter/nft_nat.c
@@ -152,7 +152,8 @@ static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	return 0;
 }
 
-static int nft_nat_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_nat_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			enum nft_scope scope)
 {
 	const struct nft_nat *priv = nft_expr_priv(expr);
 
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index acb330e..9deadb6 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -75,7 +75,8 @@ static int nft_payload_init(const struct nft_ctx *ctx,
 	return nft_validate_data_load(ctx, priv->dreg, NULL, NFT_DATA_VALUE);
 }
 
-static int nft_payload_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_payload_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			    enum nft_scope scope)
 {
 	const struct nft_payload *priv = nft_expr_priv(expr);
 
diff --git a/net/netfilter/nft_queue.c b/net/netfilter/nft_queue.c
index e8ae2f6..390107b 100644
--- a/net/netfilter/nft_queue.c
+++ b/net/netfilter/nft_queue.c
@@ -82,7 +82,8 @@ static int nft_queue_init(const struct nft_ctx *ctx,
 	return 0;
 }
 
-static int nft_queue_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_queue_dump(struct sk_buff *skb, const struct nft_expr *expr,
+			  enum nft_scope scope)
 {
 	const struct nft_queue *priv = nft_expr_priv(expr);
 
diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index e21d69d..94f2380 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -65,13 +65,14 @@ out:
 	return false;
 }
 
-static void nft_rbtree_elem_destroy(const struct nft_set *set,
+static void nft_rbtree_elem_destroy(const struct nft_ctx *ctx,
+				    const struct nft_set *set,
 				    struct nft_rbtree_elem *rbe)
 {
-	nft_data_uninit(&rbe->key, NFT_DATA_VALUE);
+	nft_data_uninit(&rbe->key, NFT_DATA_VALUE, ctx->scope);
 	if (set->flags & NFT_SET_MAP &&
 	    !(rbe->flags & NFT_SET_ELEM_INTERVAL_END))
-		nft_data_uninit(rbe->data, set->dtype);
+		nft_data_uninit(rbe->data, set->dtype, ctx->scope);
 
 	kfree(rbe);
 }
@@ -209,7 +210,8 @@ static int nft_rbtree_init(const struct nft_set *set,
 	return 0;
 }
 
-static void nft_rbtree_destroy(const struct nft_set *set)
+static void nft_rbtree_destroy(const struct nft_ctx *ctx,
+			       const struct nft_set *set)
 {
 	struct nft_rbtree *priv = nft_set_priv(set);
 	struct nft_rbtree_elem *rbe;
@@ -218,7 +220,7 @@ static void nft_rbtree_destroy(const struct nft_set *set)
 	while ((node = priv->root.rb_node) != NULL) {
 		rb_erase(node, &priv->root);
 		rbe = rb_entry(node, struct nft_rbtree_elem, node);
-		nft_rbtree_elem_destroy(set, rbe);
+		nft_rbtree_elem_destroy(ctx, set, rbe);
 	}
 }
 
diff --git a/net/netfilter/nft_reject.c b/net/netfilter/nft_reject.c
index f3448c2..09bc4b2 100644
--- a/net/netfilter/nft_reject.c
+++ b/net/netfilter/nft_reject.c
@@ -49,7 +49,8 @@ int nft_reject_init(const struct nft_ctx *ctx,
 }
 EXPORT_SYMBOL_GPL(nft_reject_init);
 
-int nft_reject_dump(struct sk_buff *skb, const struct nft_expr *expr)
+int nft_reject_dump(struct sk_buff *skb, const struct nft_expr *expr,
+		    enum nft_scope scope)
 {
 	const struct nft_reject *priv = nft_expr_priv(expr);
 
-- 
1.7.10.4

