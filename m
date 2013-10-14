From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/17] netfilter: nf_tables: expression ops overloading
Date: Mon, 14 Oct 2013 18:38:46 +0200
Message-ID: <1381768738-17739-6-git-send-email-pablo@netfilter.org>
References: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34753 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757257Ab3JNQjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 12:39:18 -0400
In-Reply-To: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Split the expression ops into two parts and support overloading of
the runtime expression ops based on the requested function through
a ->select_ops() callback.

This can be used to provide optimized implementations, for instance
for loading small aligned amounts of data from the packet or inlining
frequently used operations into the main evaluation loop.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h      |   42 +++++++++----
 net/ipv4/netfilter/nf_table_nat_ipv4.c |   18 ++++--
 net/ipv4/netfilter/nft_reject_ipv4.c   |   18 ++++--
 net/netfilter/nf_tables_api.c          |  101 ++++++++++++++++++--------------
 net/netfilter/nft_bitwise.c            |   18 ++++--
 net/netfilter/nft_byteorder.c          |   18 ++++--
 net/netfilter/nft_cmp.c                |   18 ++++--
 net/netfilter/nft_counter.c            |   22 ++++---
 net/netfilter/nft_ct.c                 |   18 ++++--
 net/netfilter/nft_expr_template.c      |   20 ++++---
 net/netfilter/nft_exthdr.c             |   16 +++--
 net/netfilter/nft_immediate.c          |   18 ++++--
 net/netfilter/nft_limit.c              |   18 ++++--
 net/netfilter/nft_log.c                |   18 ++++--
 net/netfilter/nft_lookup.c             |   16 +++--
 net/netfilter/nft_meta.c               |   18 ++++--
 net/netfilter/nft_payload.c            |   18 ++++--
 17 files changed, 267 insertions(+), 148 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 677dd79..66d0359 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -222,25 +222,45 @@ extern int nf_tables_bind_set(const struct nft_ctx *ctx, struct nft_set *set,
 extern void nf_tables_unbind_set(const struct nft_ctx *ctx, struct nft_set *set,
 				 struct nft_set_binding *binding);
 
+
 /**
- *	struct nft_expr_ops - nf_tables expression operations
+ *	struct nft_expr_type - nf_tables expression type
  *
- *	@eval: Expression evaluation function
- *	@init: initialization function
- *	@destroy: destruction function
- *	@dump: function to dump parameters
+ *	@select_ops: function to select nft_expr_ops
+ *	@ops: default ops, used when no select_ops functions is present
  *	@list: used internally
  *	@name: Identifier
  *	@owner: module reference
  *	@policy: netlink attribute policy
  *	@maxattr: highest netlink attribute number
+ */
+struct nft_expr_type {
+	const struct nft_expr_ops	*(*select_ops)(const struct nlattr * const tb[]);
+	const struct nft_expr_ops	*ops;
+	struct list_head		list;
+	const char			*name;
+	struct module			*owner;
+	const struct nla_policy		*policy;
+	unsigned int			maxattr;
+};
+
+/**
+ *	struct nft_expr_ops - nf_tables expression operations
+ *
+ *	@eval: Expression evaluation function
  *	@size: full expression size, including private data size
+ *	@init: initialization function
+ *	@destroy: destruction function
+ *	@dump: function to dump parameters
+ *	@type: expression type
  */
 struct nft_expr;
 struct nft_expr_ops {
 	void				(*eval)(const struct nft_expr *expr,
 						struct nft_data data[NFT_REG_MAX + 1],
 						const struct nft_pktinfo *pkt);
+	unsigned int			size;
+
 	int				(*init)(const struct nft_ctx *ctx,
 						const struct nft_expr *expr,
 						const struct nlattr * const tb[]);
@@ -248,14 +268,10 @@ struct nft_expr_ops {
 	int				(*dump)(struct sk_buff *skb,
 						const struct nft_expr *expr);
 	const struct nft_data *		(*get_verdict)(const struct nft_expr *expr);
-	struct list_head		list;
-	const char			*name;
-	struct module			*owner;
-	const struct nla_policy		*policy;
-	unsigned int			maxattr;
-	unsigned int			size;
+	const struct nft_expr_type	*type;
 };
 
+#define NFT_EXPR_MAXATTR		16
 #define NFT_EXPR_SIZE(size)		(sizeof(struct nft_expr) + \
 					 ALIGN(size, __alignof__(struct nft_expr)))
 
@@ -418,8 +434,8 @@ extern void nft_unregister_afinfo(struct nft_af_info *);
 extern int nft_register_table(struct nft_table *, int family);
 extern void nft_unregister_table(struct nft_table *, int family);
 
-extern int nft_register_expr(struct nft_expr_ops *);
-extern void nft_unregister_expr(struct nft_expr_ops *);
+extern int nft_register_expr(struct nft_expr_type *);
+extern void nft_unregister_expr(struct nft_expr_type *);
 
 #define MODULE_ALIAS_NFT_FAMILY(family)	\
 	MODULE_ALIAS("nft-afinfo-" __stringify(family))
diff --git a/net/ipv4/netfilter/nf_table_nat_ipv4.c b/net/ipv4/netfilter/nf_table_nat_ipv4.c
index 2a6f184..2ecce39 100644
--- a/net/ipv4/netfilter/nf_table_nat_ipv4.c
+++ b/net/ipv4/netfilter/nf_table_nat_ipv4.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -149,15 +149,21 @@ nla_put_failure:
 	return -1;
 }
 
-static struct nft_expr_ops nft_nat_ops __read_mostly = {
-	.name		= "nat",
+static struct nft_expr_type nft_nat_type;
+static const struct nft_expr_ops nft_nat_ops = {
+	.type		= &nft_nat_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_nat)),
-	.owner		= THIS_MODULE,
 	.eval		= nft_nat_eval,
 	.init		= nft_nat_init,
 	.dump		= nft_nat_dump,
+};
+
+static struct nft_expr_type nft_nat_type __read_mostly = {
+	.name		= "nat",
+	.ops		= &nft_nat_ops,
 	.policy		= nft_nat_policy,
 	.maxattr	= NFTA_NAT_MAX,
+	.owner		= THIS_MODULE,
 };
 
 /*
@@ -382,7 +388,7 @@ static int __init nf_table_nat_init(void)
 	if (err < 0)
 		goto err1;
 
-	err = nft_register_expr(&nft_nat_ops);
+	err = nft_register_expr(&nft_nat_type);
 	if (err < 0)
 		goto err2;
 
@@ -396,7 +402,7 @@ err1:
 
 static void __exit nf_table_nat_exit(void)
 {
-	nft_unregister_expr(&nft_nat_ops);
+	nft_unregister_expr(&nft_nat_type);
 	nft_unregister_table(&nf_table_nat_ipv4, AF_INET);
 }
 
diff --git a/net/ipv4/netfilter/nft_reject_ipv4.c b/net/ipv4/netfilter/nft_reject_ipv4.c
index b4ee8d3..fff5ba1 100644
--- a/net/ipv4/netfilter/nft_reject_ipv4.c
+++ b/net/ipv4/netfilter/nft_reject_ipv4.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -88,25 +88,31 @@ nla_put_failure:
 	return -1;
 }
 
-static struct nft_expr_ops reject_ops __read_mostly = {
-	.name		= "reject",
+static struct nft_expr_type nft_reject_type;
+static const struct nft_expr_ops nft_reject_ops = {
+	.type		= &nft_reject_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_reject)),
-	.owner		= THIS_MODULE,
 	.eval		= nft_reject_eval,
 	.init		= nft_reject_init,
 	.dump		= nft_reject_dump,
+};
+
+static struct nft_expr_type nft_reject_type __read_mostly = {
+	.name		= "reject",
+	.ops		= &nft_reject_ops,
 	.policy		= nft_reject_policy,
 	.maxattr	= NFTA_REJECT_MAX,
+	.owner		= THIS_MODULE,
 };
 
 static int __init nft_reject_module_init(void)
 {
-	return nft_register_expr(&reject_ops);
+	return nft_register_expr(&nft_reject_type);
 }
 
 static void __exit nft_reject_module_exit(void)
 {
-	nft_unregister_expr(&reject_ops);
+	nft_unregister_expr(&nft_reject_type);
 }
 
 module_init(nft_reject_module_init);
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 5092c81..6dac9a3 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -840,64 +840,64 @@ static void nft_ctx_init(struct nft_ctx *ctx,
  */
 
 /**
- *	nft_register_expr - register nf_tables expr operations
- *	@ops: expr operations
+ *	nft_register_expr - register nf_tables expr type
+ *	@ops: expr type
  *
- *	Registers the expr operations for use with nf_tables. Returns zero on
+ *	Registers the expr type for use with nf_tables. Returns zero on
  *	success or a negative errno code otherwise.
  */
-int nft_register_expr(struct nft_expr_ops *ops)
+int nft_register_expr(struct nft_expr_type *type)
 {
 	nfnl_lock(NFNL_SUBSYS_NFTABLES);
-	list_add_tail(&ops->list, &nf_tables_expressions);
+	list_add_tail(&type->list, &nf_tables_expressions);
 	nfnl_unlock(NFNL_SUBSYS_NFTABLES);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nft_register_expr);
 
 /**
- *	nft_unregister_expr - unregister nf_tables expr operations
- *	@ops: expr operations
+ *	nft_unregister_expr - unregister nf_tables expr type
+ *	@ops: expr type
  *
- * 	Unregisters the expr operations for use with nf_tables.
+ * 	Unregisters the expr typefor use with nf_tables.
  */
-void nft_unregister_expr(struct nft_expr_ops *ops)
+void nft_unregister_expr(struct nft_expr_type *type)
 {
 	nfnl_lock(NFNL_SUBSYS_NFTABLES);
-	list_del(&ops->list);
+	list_del(&type->list);
 	nfnl_unlock(NFNL_SUBSYS_NFTABLES);
 }
 EXPORT_SYMBOL_GPL(nft_unregister_expr);
 
-static const struct nft_expr_ops *__nft_expr_ops_get(struct nlattr *nla)
+static const struct nft_expr_type *__nft_expr_type_get(struct nlattr *nla)
 {
-	const struct nft_expr_ops *ops;
+	const struct nft_expr_type *type;
 
-	list_for_each_entry(ops, &nf_tables_expressions, list) {
-		if (!nla_strcmp(nla, ops->name))
-			return ops;
+	list_for_each_entry(type, &nf_tables_expressions, list) {
+		if (!nla_strcmp(nla, type->name))
+			return type;
 	}
 	return NULL;
 }
 
-static const struct nft_expr_ops *nft_expr_ops_get(struct nlattr *nla)
+static const struct nft_expr_type *nft_expr_type_get(struct nlattr *nla)
 {
-	const struct nft_expr_ops *ops;
+	const struct nft_expr_type *type;
 
 	if (nla == NULL)
 		return ERR_PTR(-EINVAL);
 
-	ops = __nft_expr_ops_get(nla);
-	if (ops != NULL && try_module_get(ops->owner))
-		return ops;
+	type = __nft_expr_type_get(nla);
+	if (type != NULL && try_module_get(type->owner))
+		return type;
 
 #ifdef CONFIG_MODULES
-	if (ops == NULL) {
+	if (type == NULL) {
 		nfnl_unlock(NFNL_SUBSYS_NFTABLES);
 		request_module("nft-expr-%.*s",
 			       nla_len(nla), (char *)nla_data(nla));
 		nfnl_lock(NFNL_SUBSYS_NFTABLES);
-		if (__nft_expr_ops_get(nla))
+		if (__nft_expr_type_get(nla))
 			return ERR_PTR(-EAGAIN);
 	}
 #endif
@@ -912,7 +912,7 @@ static const struct nla_policy nft_expr_policy[NFTA_EXPR_MAX + 1] = {
 static int nf_tables_fill_expr_info(struct sk_buff *skb,
 				    const struct nft_expr *expr)
 {
-	if (nla_put_string(skb, NFTA_EXPR_NAME, expr->ops->name))
+	if (nla_put_string(skb, NFTA_EXPR_NAME, expr->ops->type->name))
 		goto nla_put_failure;
 
 	if (expr->ops->dump) {
@@ -932,28 +932,52 @@ nla_put_failure:
 
 struct nft_expr_info {
 	const struct nft_expr_ops	*ops;
-	struct nlattr			*tb[NFTA_EXPR_MAX + 1];
+	struct nlattr			*tb[NFT_EXPR_MAXATTR + 1];
 };
 
 static int nf_tables_expr_parse(const struct nlattr *nla,
 				struct nft_expr_info *info)
 {
+	const struct nft_expr_type *type;
 	const struct nft_expr_ops *ops;
+	struct nlattr *tb[NFTA_EXPR_MAX + 1];
 	int err;
 
-	err = nla_parse_nested(info->tb, NFTA_EXPR_MAX, nla, nft_expr_policy);
+	err = nla_parse_nested(tb, NFTA_EXPR_MAX, nla, nft_expr_policy);
 	if (err < 0)
 		return err;
 
-	ops = nft_expr_ops_get(info->tb[NFTA_EXPR_NAME]);
-	if (IS_ERR(ops))
-		return PTR_ERR(ops);
+	type = nft_expr_type_get(tb[NFTA_EXPR_NAME]);
+	if (IS_ERR(type))
+		return PTR_ERR(type);
+
+	if (tb[NFTA_EXPR_DATA]) {
+		err = nla_parse_nested(info->tb, type->maxattr,
+				       tb[NFTA_EXPR_DATA], type->policy);
+		if (err < 0)
+			goto err1;
+	} else
+		memset(info->tb, 0, sizeof(info->tb[0]) * (type->maxattr + 1));
+
+	if (type->select_ops != NULL) {
+		ops = type->select_ops((const struct nlattr * const *)info->tb);
+		if (IS_ERR(ops)) {
+			err = PTR_ERR(ops);
+			goto err1;
+		}
+	} else
+		ops = type->ops;
+
 	info->ops = ops;
 	return 0;
+
+err1:
+	module_put(type->owner);
+	return err;
 }
 
 static int nf_tables_newexpr(const struct nft_ctx *ctx,
-			     struct nft_expr_info *info,
+			     const struct nft_expr_info *info,
 			     struct nft_expr *expr)
 {
 	const struct nft_expr_ops *ops = info->ops;
@@ -961,23 +985,11 @@ static int nf_tables_newexpr(const struct nft_ctx *ctx,
 
 	expr->ops = ops;
 	if (ops->init) {
-		struct nlattr *ma[ops->maxattr + 1];
-
-		if (info->tb[NFTA_EXPR_DATA]) {
-			err = nla_parse_nested(ma, ops->maxattr,
-					       info->tb[NFTA_EXPR_DATA],
-					       ops->policy);
-			if (err < 0)
-				goto err1;
-		} else
-			memset(ma, 0, sizeof(ma[0]) * (ops->maxattr + 1));
-
-		err = ops->init(ctx, expr, (const struct nlattr **)ma);
+		err = ops->init(ctx, expr, (const struct nlattr **)info->tb);
 		if (err < 0)
 			goto err1;
 	}
 
-	info->ops = NULL;
 	return 0;
 
 err1:
@@ -989,7 +1001,7 @@ static void nf_tables_expr_destroy(struct nft_expr *expr)
 {
 	if (expr->ops->destroy)
 		expr->ops->destroy(expr);
-	module_put(expr->ops->owner);
+	module_put(expr->ops->type->owner);
 }
 
 /*
@@ -1313,6 +1325,7 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 		err = nf_tables_newexpr(&ctx, &info[i], expr);
 		if (err < 0)
 			goto err2;
+		info[i].ops = NULL;
 		expr = nft_expr_next(expr);
 	}
 
@@ -1341,7 +1354,7 @@ err2:
 err1:
 	for (i = 0; i < n; i++) {
 		if (info[i].ops != NULL)
-			module_put(info[i].ops->owner);
+			module_put(info[i].ops->type->owner);
 	}
 	return err;
 }
diff --git a/net/netfilter/nft_bitwise.c b/net/netfilter/nft_bitwise.c
index 0f75015..4fb6ee2 100644
--- a/net/netfilter/nft_bitwise.c
+++ b/net/netfilter/nft_bitwise.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -118,23 +118,29 @@ nla_put_failure:
 	return -1;
 }
 
-static struct nft_expr_ops nft_bitwise_ops __read_mostly = {
-	.name		= "bitwise",
+static struct nft_expr_type nft_bitwise_type;
+static const struct nft_expr_ops nft_bitwise_ops = {
+	.type		= &nft_bitwise_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_bitwise)),
-	.owner		= THIS_MODULE,
 	.eval		= nft_bitwise_eval,
 	.init		= nft_bitwise_init,
 	.dump		= nft_bitwise_dump,
+};
+
+static struct nft_expr_type nft_bitwise_type __read_mostly = {
+	.name		= "bitwise",
+	.ops		= &nft_bitwise_ops,
 	.policy		= nft_bitwise_policy,
 	.maxattr	= NFTA_BITWISE_MAX,
+	.owner		= THIS_MODULE,
 };
 
 int __init nft_bitwise_module_init(void)
 {
-	return nft_register_expr(&nft_bitwise_ops);
+	return nft_register_expr(&nft_bitwise_type);
 }
 
 void nft_bitwise_module_exit(void)
 {
-	nft_unregister_expr(&nft_bitwise_ops);
+	nft_unregister_expr(&nft_bitwise_type);
 }
diff --git a/net/netfilter/nft_byteorder.c b/net/netfilter/nft_byteorder.c
index 8b0657a..c39ed8d 100644
--- a/net/netfilter/nft_byteorder.c
+++ b/net/netfilter/nft_byteorder.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -145,23 +145,29 @@ nla_put_failure:
 	return -1;
 }
 
-static struct nft_expr_ops nft_byteorder_ops __read_mostly = {
-	.name		= "byteorder",
+static struct nft_expr_type nft_byteorder_type;
+static const struct nft_expr_ops nft_byteorder_ops = {
+	.type		= &nft_byteorder_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_byteorder)),
-	.owner		= THIS_MODULE,
 	.eval		= nft_byteorder_eval,
 	.init		= nft_byteorder_init,
 	.dump		= nft_byteorder_dump,
+};
+
+static struct nft_expr_type nft_byteorder_type __read_mostly = {
+	.name		= "byteorder",
+	.ops		= &nft_byteorder_ops,
 	.policy		= nft_byteorder_policy,
 	.maxattr	= NFTA_BYTEORDER_MAX,
+	.owner		= THIS_MODULE,
 };
 
 int __init nft_byteorder_module_init(void)
 {
-	return nft_register_expr(&nft_byteorder_ops);
+	return nft_register_expr(&nft_byteorder_type);
 }
 
 void nft_byteorder_module_exit(void)
 {
-	nft_unregister_expr(&nft_byteorder_ops);
+	nft_unregister_expr(&nft_byteorder_type);
 }
diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index e734d67..2c9d5fe 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -124,23 +124,29 @@ nla_put_failure:
 	return -1;
 }
 
-static struct nft_expr_ops nft_cmp_ops __read_mostly = {
-	.name		= "cmp",
+static struct nft_expr_type nft_cmp_type;
+static const struct nft_expr_ops nft_cmp_ops = {
+	.type		= &nft_cmp_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_cmp_expr)),
-	.owner		= THIS_MODULE,
 	.eval		= nft_cmp_eval,
 	.init		= nft_cmp_init,
 	.dump		= nft_cmp_dump,
+};
+
+static struct nft_expr_type nft_cmp_type __read_mostly = {
+	.name		= "cmp",
+	.ops		= &nft_cmp_ops,
 	.policy		= nft_cmp_policy,
 	.maxattr	= NFTA_CMP_MAX,
+	.owner		= THIS_MODULE,
 };
 
 int __init nft_cmp_module_init(void)
 {
-	return nft_register_expr(&nft_cmp_ops);
+	return nft_register_expr(&nft_cmp_type);
 }
 
 void nft_cmp_module_exit(void)
 {
-	nft_unregister_expr(&nft_cmp_ops);
+	nft_unregister_expr(&nft_cmp_type);
 }
diff --git a/net/netfilter/nft_counter.c b/net/netfilter/nft_counter.c
index 33c5d36..c89ee48 100644
--- a/net/netfilter/nft_counter.c
+++ b/net/netfilter/nft_counter.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -78,25 +78,31 @@ static int nft_counter_init(const struct nft_ctx *ctx,
 	return 0;
 }
 
-static struct nft_expr_ops nft_counter_ops __read_mostly = {
-	.name		= "counter",
+static struct nft_expr_type nft_counter_type;
+static const struct nft_expr_ops nft_counter_ops = {
+	.type		= &nft_counter_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_counter)),
-	.policy		= nft_counter_policy,
-	.maxattr	= NFTA_COUNTER_MAX,
-	.owner		= THIS_MODULE,
 	.eval		= nft_counter_eval,
 	.init		= nft_counter_init,
 	.dump		= nft_counter_dump,
 };
 
+static struct nft_expr_type nft_counter_type __read_mostly = {
+	.name		= "counter",
+	.ops		= &nft_counter_ops,
+	.policy		= nft_counter_policy,
+	.maxattr	= NFTA_COUNTER_MAX,
+	.owner		= THIS_MODULE,
+};
+
 static int __init nft_counter_module_init(void)
 {
-	return nft_register_expr(&nft_counter_ops);
+	return nft_register_expr(&nft_counter_type);
 }
 
 static void __exit nft_counter_module_exit(void)
 {
-	nft_unregister_expr(&nft_counter_ops);
+	nft_unregister_expr(&nft_counter_type);
 }
 
 module_init(nft_counter_module_init);
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index a1756d6..955f4e6 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -222,26 +222,32 @@ nla_put_failure:
 	return -1;
 }
 
-static struct nft_expr_ops nft_ct_ops __read_mostly = {
-	.name		= "ct",
+static struct nft_expr_type nft_ct_type;
+static const struct nft_expr_ops nft_ct_ops = {
+	.type		= &nft_ct_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_ct)),
-	.owner		= THIS_MODULE,
 	.eval		= nft_ct_eval,
 	.init		= nft_ct_init,
 	.destroy	= nft_ct_destroy,
 	.dump		= nft_ct_dump,
+};
+
+static struct nft_expr_type nft_ct_type __read_mostly = {
+	.name		= "ct",
+	.ops		= &nft_ct_ops,
 	.policy		= nft_ct_policy,
 	.maxattr	= NFTA_CT_MAX,
+	.owner		= THIS_MODULE,
 };
 
 static int __init nft_ct_module_init(void)
 {
-	return nft_register_expr(&nft_ct_ops);
+	return nft_register_expr(&nft_ct_type);
 }
 
 static void __exit nft_ct_module_exit(void)
 {
-	nft_unregister_expr(&nft_ct_ops);
+	nft_unregister_expr(&nft_ct_type);
 }
 
 module_init(nft_ct_module_init);
diff --git a/net/netfilter/nft_expr_template.c b/net/netfilter/nft_expr_template.c
index 9fc8eb3..b6eed4d 100644
--- a/net/netfilter/nft_expr_template.c
+++ b/net/netfilter/nft_expr_template.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -33,7 +33,7 @@ static const struct nla_policy nft_template_policy[NFTA_TEMPLATE_MAX + 1] = {
 
 static int nft_template_init(const struct nft_ctx *ctx,
 			   const struct nft_expr *expr,
-			   const struct nlattr *tb[])
+			   const struct nlattr * const tb[])
 {
 	struct nft_template *priv = nft_expr_priv(expr);
 
@@ -58,26 +58,32 @@ nla_put_failure:
 	return -1;
 }
 
-static struct nft_expr_ops template_ops __read_mostly = {
-	.name		= "template",
+static struct nft_expr_type nft_template_type;
+static const struct nft_expr_ops nft_template_ops = {
+	.type		= &nft_template_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_template)),
-	.owner		= THIS_MODULE,
 	.eval		= nft_template_eval,
 	.init		= nft_template_init,
 	.destroy	= nft_template_destroy,
 	.dump		= nft_template_dump,
+};
+
+static struct nft_expr_type nft_template_type __read_mostly = {
+	.name		= "template",
+	.ops		= &nft_template_ops,
 	.policy		= nft_template_policy,
 	.maxattr	= NFTA_TEMPLATE_MAX,
+	.owner		= THIS_MODULE,
 };
 
 static int __init nft_template_module_init(void)
 {
-	return nft_register_expr(&template_ops);
+	return nft_register_expr(&nft_template_type);
 }
 
 static void __exit nft_template_module_exit(void)
 {
-	nft_unregister_expr(&template_ops);
+	nft_unregister_expr(&nft_template_type);
 }
 
 module_init(nft_template_module_init);
diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index 21c6a6b..8e0bb75 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -98,25 +98,31 @@ nla_put_failure:
 	return -1;
 }
 
-static struct nft_expr_ops exthdr_ops __read_mostly = {
-	.name		= "exthdr",
+static struct nft_expr_type nft_exthdr_type;
+static const struct nft_expr_ops nft_exthdr_ops = {
+	.type		= &nft_exthdr_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_exthdr)),
-	.owner		= THIS_MODULE,
 	.eval		= nft_exthdr_eval,
 	.init		= nft_exthdr_init,
 	.dump		= nft_exthdr_dump,
+};
+
+static struct nft_expr_type nft_exthdr_type __read_mostly = {
+	.name		= "exthdr",
+	.ops		= &nft_exthdr_ops,
 	.policy		= nft_exthdr_policy,
 	.maxattr	= NFTA_EXTHDR_MAX,
+	.owner		= THIS_MODULE,
 };
 
 static int __init nft_exthdr_module_init(void)
 {
-	return nft_register_expr(&exthdr_ops);
+	return nft_register_expr(&nft_exthdr_type);
 }
 
 static void __exit nft_exthdr_module_exit(void)
 {
-	nft_unregister_expr(&exthdr_ops);
+	nft_unregister_expr(&nft_exthdr_type);
 }
 
 module_init(nft_exthdr_module_init);
diff --git a/net/netfilter/nft_immediate.c b/net/netfilter/nft_immediate.c
index 78334bf..1bfeeaf 100644
--- a/net/netfilter/nft_immediate.c
+++ b/net/netfilter/nft_immediate.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -100,25 +100,31 @@ static const struct nft_data *nft_immediate_get_verdict(const struct nft_expr *e
 		return NULL;
 }
 
-static struct nft_expr_ops nft_imm_ops __read_mostly = {
-	.name		= "immediate",
+static struct nft_expr_type nft_imm_type;
+static const struct nft_expr_ops nft_imm_ops = {
+	.type		= &nft_imm_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_immediate_expr)),
-	.owner		= THIS_MODULE,
 	.eval		= nft_immediate_eval,
 	.init		= nft_immediate_init,
 	.destroy	= nft_immediate_destroy,
 	.dump		= nft_immediate_dump,
 	.get_verdict	= nft_immediate_get_verdict,
+};
+
+static struct nft_expr_type nft_imm_type __read_mostly = {
+	.name		= "immediate",
+	.ops		= &nft_imm_ops,
 	.policy		= nft_immediate_policy,
 	.maxattr	= NFTA_IMMEDIATE_MAX,
+	.owner		= THIS_MODULE,
 };
 
 int __init nft_immediate_module_init(void)
 {
-	return nft_register_expr(&nft_imm_ops);
+	return nft_register_expr(&nft_imm_type);
 }
 
 void nft_immediate_module_exit(void)
 {
-	nft_unregister_expr(&nft_imm_ops);
+	nft_unregister_expr(&nft_imm_type);
 }
diff --git a/net/netfilter/nft_limit.c b/net/netfilter/nft_limit.c
index e0e3fc8..85da5bd 100644
--- a/net/netfilter/nft_limit.c
+++ b/net/netfilter/nft_limit.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -84,25 +84,31 @@ nla_put_failure:
 	return -1;
 }
 
-static struct nft_expr_ops nft_limit_ops __read_mostly = {
-	.name		= "limit",
+static struct nft_expr_type nft_limit_type;
+static const struct nft_expr_ops nft_limit_ops = {
+	.type		= &nft_limit_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_limit)),
-	.owner		= THIS_MODULE,
 	.eval		= nft_limit_eval,
 	.init		= nft_limit_init,
 	.dump		= nft_limit_dump,
+};
+
+static struct nft_expr_type nft_limit_type __read_mostly = {
+	.name		= "limit",
+	.ops		= &nft_limit_ops,
 	.policy		= nft_limit_policy,
 	.maxattr	= NFTA_LIMIT_MAX,
+	.owner		= THIS_MODULE,
 };
 
 static int __init nft_limit_module_init(void)
 {
-	return nft_register_expr(&nft_limit_ops);
+	return nft_register_expr(&nft_limit_type);
 }
 
 static void __exit nft_limit_module_exit(void)
 {
-	nft_unregister_expr(&nft_limit_ops);
+	nft_unregister_expr(&nft_limit_type);
 }
 
 module_init(nft_limit_module_init);
diff --git a/net/netfilter/nft_log.c b/net/netfilter/nft_log.c
index da495c3..57cad07 100644
--- a/net/netfilter/nft_log.c
+++ b/net/netfilter/nft_log.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -110,26 +110,32 @@ nla_put_failure:
 	return -1;
 }
 
-static struct nft_expr_ops nft_log_ops __read_mostly = {
-	.name		= "log",
+static struct nft_expr_type nft_log_type;
+static const struct nft_expr_ops nft_log_ops = {
+	.type		= &nft_log_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_log)),
-	.owner		= THIS_MODULE,
 	.eval		= nft_log_eval,
 	.init		= nft_log_init,
 	.destroy	= nft_log_destroy,
 	.dump		= nft_log_dump,
+};
+
+static struct nft_expr_type nft_log_type __read_mostly = {
+	.name		= "log",
+	.ops		= &nft_log_ops,
 	.policy		= nft_log_policy,
 	.maxattr	= NFTA_LOG_MAX,
+	.owner		= THIS_MODULE,
 };
 
 static int __init nft_log_module_init(void)
 {
-	return nft_register_expr(&nft_log_ops);
+	return nft_register_expr(&nft_log_type);
 }
 
 static void __exit nft_log_module_exit(void)
 {
-	nft_unregister_expr(&nft_log_ops);
+	nft_unregister_expr(&nft_log_type);
 }
 
 module_init(nft_log_module_init);
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index 4962d21..8a6116b 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -112,24 +112,30 @@ nla_put_failure:
 	return -1;
 }
 
-static struct nft_expr_ops nft_lookup_ops __read_mostly = {
-	.name		= "lookup",
+static struct nft_expr_type nft_lookup_type;
+static const struct nft_expr_ops nft_lookup_ops = {
+	.type		= &nft_lookup_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_lookup)),
-	.owner		= THIS_MODULE,
 	.eval		= nft_lookup_eval,
 	.init		= nft_lookup_init,
 	.destroy	= nft_lookup_destroy,
 	.dump		= nft_lookup_dump,
+};
+
+static struct nft_expr_type nft_lookup_type __read_mostly = {
+	.name		= "lookup",
+	.ops		= &nft_lookup_ops,
 	.policy		= nft_lookup_policy,
 	.maxattr	= NFTA_LOOKUP_MAX,
+	.owner		= THIS_MODULE,
 };
 
 int __init nft_lookup_module_init(void)
 {
-	return nft_register_expr(&nft_lookup_ops);
+	return nft_register_expr(&nft_lookup_type);
 }
 
 void nft_lookup_module_exit(void)
 {
-	nft_unregister_expr(&nft_lookup_ops);
+	nft_unregister_expr(&nft_lookup_type);
 }
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 96735aa..8c28220 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -193,25 +193,31 @@ nla_put_failure:
 	return -1;
 }
 
-static struct nft_expr_ops nft_meta_ops __read_mostly = {
-	.name		= "meta",
+static struct nft_expr_type nft_meta_type;
+static const struct nft_expr_ops nft_meta_ops = {
+	.type		= &nft_meta_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_meta)),
-	.owner		= THIS_MODULE,
 	.eval		= nft_meta_eval,
 	.init		= nft_meta_init,
 	.dump		= nft_meta_dump,
+};
+
+static struct nft_expr_type nft_meta_type __read_mostly = {
+	.name		= "meta",
+	.ops		= &nft_meta_ops,
 	.policy		= nft_meta_policy,
 	.maxattr	= NFTA_META_MAX,
+	.owner		= THIS_MODULE,
 };
 
 static int __init nft_meta_module_init(void)
 {
-	return nft_register_expr(&nft_meta_ops);
+	return nft_register_expr(&nft_meta_type);
 }
 
 static void __exit nft_meta_module_exit(void)
 {
-	nft_unregister_expr(&nft_meta_ops);
+	nft_unregister_expr(&nft_meta_type);
 }
 
 module_init(nft_meta_module_init);
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index 329f134..d99db6e 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -115,23 +115,29 @@ nla_put_failure:
 	return -1;
 }
 
-static struct nft_expr_ops nft_payload_ops __read_mostly = {
-	.name		= "payload",
+static struct nft_expr_type nft_payload_type;
+static const struct nft_expr_ops nft_payload_ops = {
+	.type		= &nft_payload_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_payload)),
-	.owner		= THIS_MODULE,
 	.eval		= nft_payload_eval,
 	.init		= nft_payload_init,
 	.dump		= nft_payload_dump,
+};
+
+static struct nft_expr_type nft_payload_type __read_mostly = {
+	.name		= "payload",
+	.ops		= &nft_payload_ops,
 	.policy		= nft_payload_policy,
 	.maxattr	= NFTA_PAYLOAD_MAX,
+	.owner		= THIS_MODULE,
 };
 
 int __init nft_payload_module_init(void)
 {
-	return nft_register_expr(&nft_payload_ops);
+	return nft_register_expr(&nft_payload_type);
 }
 
 void nft_payload_module_exit(void)
 {
-	nft_unregister_expr(&nft_payload_ops);
+	nft_unregister_expr(&nft_payload_type);
 }
-- 
1.7.10.4
