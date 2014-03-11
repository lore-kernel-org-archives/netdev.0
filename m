From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH RFC 7/9] netfilter: nf_tables: move expression infrastructure to built-in core
Date: Tue, 11 Mar 2014 10:19:18 +0100
Message-ID: <1394529560-3490-8-git-send-email-pablo@netfilter.org>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move expression infrastructure that will be needed by other
classifiers (eg. socket filtering) to nf_tables_core.c and make
this built-in. The basic expressions are also registered from
the core: payload, cmp, immediate, bitwise and byteorder.

I have added a new lock to protect the list of expression which
is common to both nf_tables and nf_tables_sock and converted it
to use rcu.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables_core.h |   26 ++++
 net/netfilter/Kconfig                  |    5 +
 net/netfilter/Makefile                 |    7 +-
 net/netfilter/nf_tables_api.c          |  208 ++++-------------------------
 net/netfilter/nf_tables_core.c         |  225 ++++++++++++++++++++++++++++++++
 net/netfilter/nf_tables_nf.c           |   46 +------
 net/netfilter/nft_cmp.c                |    1 +
 net/netfilter/nft_payload.c            |    1 +
 8 files changed, 286 insertions(+), 233 deletions(-)
 create mode 100644 net/netfilter/nf_tables_core.c

diff --git a/include/net/netfilter/nf_tables_core.h b/include/net/netfilter/nf_tables_core.h
index 004c2aa..98b9c74 100644
--- a/include/net/netfilter/nf_tables_core.h
+++ b/include/net/netfilter/nf_tables_core.h
@@ -81,4 +81,30 @@ static inline bool nft_payload_fast_eval(const struct nft_expr *expr,
 	return true;
 }
 
+#include <net/netfilter/nf_tables.h>
+
+/**
+ *     struct nft_expr_info - nf_tables expression information
+ *
+ *     @ops: Pointer to expression operations
+ *     @tb: array of attributes for this expression
+ */
+struct nft_expr_info {
+       const struct nft_expr_ops       *ops;
+       struct nlattr		       *tb[NFT_EXPR_MAXATTR + 1];
+};
+
+int nft_register_expr(struct nft_expr_type *type);
+void nft_unregister_expr(struct nft_expr_type *type);
+int nf_tables_newexpr(const struct nft_ctx *ctx,
+		      const struct nft_expr_info *info, struct nft_expr *expr);
+int nf_tables_expr_parse(const struct nft_ctx *ctx,
+			 const struct nlattr *nla, struct nft_expr_info *info,
+			 int (*autoload)(const struct nft_ctx *ctx,
+					 const struct nlattr *nla));
+const struct nft_expr_type *__nft_expr_type_get(u8 family,
+						const struct nlattr *nla);
+void nf_tables_expr_destroy(const struct nft_ctx *ctx, struct nft_expr *expr);
+int nf_tables_fill_expr_info(struct sk_buff *skb, const struct nft_expr *expr);
+
 #endif /* _NET_NF_TABLES_CORE_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index e9410d1..5bd91a8 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -413,8 +413,13 @@ config NETFILTER_SYNPROXY
 
 endif # NF_CONNTRACK
 
+config NF_TABLES_CORE
+	boolean
+	default n
+
 config NF_TABLES
 	select NETFILTER_NETLINK
+	select NF_TABLES_CORE
 	tristate "Netfilter nf_tables support"
 	help
 	  nftables is the new packet classification framework that intends to
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index bb9970c..7564485 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -65,9 +65,10 @@ obj-$(CONFIG_NF_NAT_TFTP) += nf_nat_tftp.o
 obj-$(CONFIG_NETFILTER_SYNPROXY) += nf_synproxy_core.o
 
 # nf_tables
-nf_tables-objs += nf_tables_nf.o nf_tables_api.o
-nf_tables-objs += nft_immediate.o nft_cmp.o nft_lookup.o
-nf_tables-objs += nft_bitwise.o nft_byteorder.o nft_payload.o
+obj-$(CONFIG_NF_TABLES_CORE) += nf_tables_core.o nft_payload.o nft_cmp.o \
+				nft_immediate.o nft_bitwise.o nft_byteorder.o
+
+nf_tables-objs += nf_tables_nf.o nf_tables_api.o nft_lookup.o
 
 obj-$(CONFIG_NF_TABLES)		+= nf_tables.o
 obj-$(CONFIG_NF_TABLES_INET)	+= nf_tables_inet.o
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 9879f23..29d6745 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -21,8 +21,6 @@
 #include <net/net_namespace.h>
 #include <net/sock.h>
 
-static LIST_HEAD(nf_tables_expressions);
-
 /**
  *	nft_register_afinfo - register nf_tables address family info
  *
@@ -1080,188 +1078,6 @@ static void nft_ctx_init(struct nft_ctx *ctx,
 }
 
 /*
- * Expressions
- */
-
-/**
- *	nft_register_expr - register nf_tables expr type
- *	@ops: expr type
- *
- *	Registers the expr type for use with nf_tables. Returns zero on
- *	success or a negative errno code otherwise.
- */
-int nft_register_expr(struct nft_expr_type *type)
-{
-	nfnl_lock(NFNL_SUBSYS_NFTABLES);
-	list_add_tail(&type->list, &nf_tables_expressions);
-	nfnl_unlock(NFNL_SUBSYS_NFTABLES);
-	return 0;
-}
-EXPORT_SYMBOL_GPL(nft_register_expr);
-
-/**
- *	nft_unregister_expr - unregister nf_tables expr type
- *	@ops: expr type
- *
- * 	Unregisters the expr typefor use with nf_tables.
- */
-void nft_unregister_expr(struct nft_expr_type *type)
-{
-	nfnl_lock(NFNL_SUBSYS_NFTABLES);
-	list_del(&type->list);
-	nfnl_unlock(NFNL_SUBSYS_NFTABLES);
-}
-EXPORT_SYMBOL_GPL(nft_unregister_expr);
-
-static const struct nft_expr_type *__nft_expr_type_get(u8 family,
-						       struct nlattr *nla)
-{
-	const struct nft_expr_type *type;
-
-	list_for_each_entry(type, &nf_tables_expressions, list) {
-		if (!nla_strcmp(nla, type->name) &&
-		    (!type->family || type->family == family))
-			return type;
-	}
-	return NULL;
-}
-
-static const struct nft_expr_type *nft_expr_type_get(u8 family,
-						     struct nlattr *nla)
-{
-	const struct nft_expr_type *type;
-
-	if (nla == NULL)
-		return ERR_PTR(-EINVAL);
-
-	type = __nft_expr_type_get(family, nla);
-	if (type != NULL && try_module_get(type->owner))
-		return type;
-
-#ifdef CONFIG_MODULES
-	if (type == NULL) {
-		nfnl_unlock(NFNL_SUBSYS_NFTABLES);
-		request_module("nft-expr-%u-%.*s", family,
-			       nla_len(nla), (char *)nla_data(nla));
-		nfnl_lock(NFNL_SUBSYS_NFTABLES);
-		if (__nft_expr_type_get(family, nla))
-			return ERR_PTR(-EAGAIN);
-
-		nfnl_unlock(NFNL_SUBSYS_NFTABLES);
-		request_module("nft-expr-%.*s",
-			       nla_len(nla), (char *)nla_data(nla));
-		nfnl_lock(NFNL_SUBSYS_NFTABLES);
-		if (__nft_expr_type_get(family, nla))
-			return ERR_PTR(-EAGAIN);
-	}
-#endif
-	return ERR_PTR(-ENOENT);
-}
-
-static const struct nla_policy nft_expr_policy[NFTA_EXPR_MAX + 1] = {
-	[NFTA_EXPR_NAME]	= { .type = NLA_STRING },
-	[NFTA_EXPR_DATA]	= { .type = NLA_NESTED },
-};
-
-static int nf_tables_fill_expr_info(struct sk_buff *skb,
-				    const struct nft_expr *expr)
-{
-	if (nla_put_string(skb, NFTA_EXPR_NAME, expr->ops->type->name))
-		goto nla_put_failure;
-
-	if (expr->ops->dump) {
-		struct nlattr *data = nla_nest_start(skb, NFTA_EXPR_DATA);
-		if (data == NULL)
-			goto nla_put_failure;
-		if (expr->ops->dump(skb, expr) < 0)
-			goto nla_put_failure;
-		nla_nest_end(skb, data);
-	}
-
-	return skb->len;
-
-nla_put_failure:
-	return -1;
-};
-
-struct nft_expr_info {
-	const struct nft_expr_ops	*ops;
-	struct nlattr			*tb[NFT_EXPR_MAXATTR + 1];
-};
-
-static int nf_tables_expr_parse(const struct nft_ctx *ctx,
-				const struct nlattr *nla,
-				struct nft_expr_info *info)
-{
-	const struct nft_expr_type *type;
-	const struct nft_expr_ops *ops;
-	struct nlattr *tb[NFTA_EXPR_MAX + 1];
-	int err;
-
-	err = nla_parse_nested(tb, NFTA_EXPR_MAX, nla, nft_expr_policy);
-	if (err < 0)
-		return err;
-
-	type = nft_expr_type_get(ctx->afi->family, tb[NFTA_EXPR_NAME]);
-	if (IS_ERR(type))
-		return PTR_ERR(type);
-
-	if (tb[NFTA_EXPR_DATA]) {
-		err = nla_parse_nested(info->tb, type->maxattr,
-				       tb[NFTA_EXPR_DATA], type->policy);
-		if (err < 0)
-			goto err1;
-	} else
-		memset(info->tb, 0, sizeof(info->tb[0]) * (type->maxattr + 1));
-
-	if (type->select_ops != NULL) {
-		ops = type->select_ops(ctx,
-				       (const struct nlattr * const *)info->tb);
-		if (IS_ERR(ops)) {
-			err = PTR_ERR(ops);
-			goto err1;
-		}
-	} else
-		ops = type->ops;
-
-	info->ops = ops;
-	return 0;
-
-err1:
-	module_put(type->owner);
-	return err;
-}
-
-static int nf_tables_newexpr(const struct nft_ctx *ctx,
-			     const struct nft_expr_info *info,
-			     struct nft_expr *expr)
-{
-	const struct nft_expr_ops *ops = info->ops;
-	int err;
-
-	expr->ops = ops;
-	if (ops->init) {
-		err = ops->init(ctx, expr, (const struct nlattr **)info->tb);
-		if (err < 0)
-			goto err1;
-	}
-
-	return 0;
-
-err1:
-	expr->ops = NULL;
-	return err;
-}
-
-static void nf_tables_expr_destroy(const struct nft_ctx *ctx,
-				   struct nft_expr *expr)
-{
-	if (expr->ops->destroy)
-		expr->ops->destroy(ctx, expr);
-	module_put(expr->ops->type->owner);
-}
-
-/*
  * Rules
  */
 
@@ -1574,6 +1390,27 @@ nf_tables_trans_add(struct nft_ctx *ctx, struct nft_rule *rule)
 	return rupd;
 }
 
+static int nft_expr_autoload(const struct nft_ctx *ctx,
+			     const struct nlattr *nla)
+{
+#ifdef CONFIG_MODULES
+	nfnl_unlock(NFNL_SUBSYS_NFTABLES);
+	request_module("nft-expr-%u-%.*s", ctx->afi->family,
+		       nla_len(nla), (char *)nla_data(nla));
+	nfnl_lock(NFNL_SUBSYS_NFTABLES);
+	if (__nft_expr_type_get(ctx->afi->family, nla))
+		return -EAGAIN;
+
+	nfnl_unlock(NFNL_SUBSYS_NFTABLES);
+	request_module("nft-expr-%.*s",
+		       nla_len(nla), (char *)nla_data(nla));
+	nfnl_lock(NFNL_SUBSYS_NFTABLES);
+	if (__nft_expr_type_get(ctx->afi->family, nla))
+		return -EAGAIN;
+#endif
+	return -ENOENT;
+}
+
 static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 			     const struct nlmsghdr *nlh,
 			     const struct nlattr * const nla[])
@@ -1646,7 +1483,8 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 				goto err1;
 			if (n == NFT_RULE_MAXEXPRS)
 				goto err1;
-			err = nf_tables_expr_parse(&ctx, tmp, &info[n]);
+			err = nf_tables_expr_parse(&ctx, tmp, &info[n],
+						    nft_expr_autoload);
 			if (err < 0)
 				goto err1;
 			size += info[n].ops->size;
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
new file mode 100644
index 0000000..20bd1f0
--- /dev/null
+++ b/net/netfilter/nf_tables_core.c
@@ -0,0 +1,225 @@
+/*
+ * Copyright (c) 2007-2009 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2012-2014 Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Development of this code funded by Astaro AG (http://www.astaro.com/)
+ */
+#include <linux/module.h>
+#include <linux/list.h>
+#include <net/netlink.h>
+#include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_core.h>
+#include <linux/netfilter/nf_tables.h>
+
+/*
+ * Expressions
+ */
+
+static LIST_HEAD(nf_tables_expressions);
+static DEFINE_MUTEX(nf_tables_expr_mutex);
+
+/**
+ *	nft_register_expr - register nf_tables expr type
+ *	@ops: expr type
+ *
+ *	Registers the expr type for use with nf_tables. Returns zero on
+ *	success or a negative errno code otherwise.
+ */
+int nft_register_expr(struct nft_expr_type *type)
+{
+	mutex_lock(&nf_tables_expr_mutex);
+	list_add_tail(&type->list, &nf_tables_expressions);
+	mutex_unlock(&nf_tables_expr_mutex);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nft_register_expr);
+
+/**
+ *	nft_unregister_expr - unregister nf_tables expr type
+ *	@ops: expr type
+ *
+ *	Unregisters the expr typefor use with nf_tables.
+ */
+void nft_unregister_expr(struct nft_expr_type *type)
+{
+	mutex_lock(&nf_tables_expr_mutex);
+	list_del(&type->list);
+	mutex_unlock(&nf_tables_expr_mutex);
+	synchronize_rcu();
+}
+EXPORT_SYMBOL_GPL(nft_unregister_expr);
+
+const struct nft_expr_type *__nft_expr_type_get(u8 family,
+						const struct nlattr *nla)
+{
+	const struct nft_expr_type *type;
+
+	list_for_each_entry_rcu(type, &nf_tables_expressions, list) {
+		if (!nla_strcmp(nla, type->name) &&
+		    (!type->family || type->family == family))
+			return type;
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(__nft_expr_type_get);
+
+const struct nft_expr_type *nft_expr_type_get(u8 family, const struct nlattr *nla)
+{
+	const struct nft_expr_type *type;
+
+	if (nla == NULL)
+		return ERR_PTR(-EINVAL);
+
+	type = __nft_expr_type_get(family, nla);
+	if (type != NULL && try_module_get(type->owner))
+		return type;
+
+	return ERR_PTR(-ENOENT);
+}
+EXPORT_SYMBOL_GPL(nft_expr_type_get);
+
+static const struct nla_policy nft_expr_policy[NFTA_EXPR_MAX + 1] = {
+	[NFTA_EXPR_NAME]	= { .type = NLA_STRING },
+	[NFTA_EXPR_DATA]	= { .type = NLA_NESTED },
+};
+
+int nf_tables_expr_parse(const struct nft_ctx *ctx, const struct nlattr *nla,
+			 struct nft_expr_info *info,
+			 int (*autoload)(const struct nft_ctx *ctx,
+					 const struct nlattr *nla))
+{
+	const struct nft_expr_type *type;
+	const struct nft_expr_ops *ops;
+	struct nlattr *tb[NFTA_EXPR_MAX + 1];
+	int err;
+
+	err = nla_parse_nested(tb, NFTA_EXPR_MAX, nla, nft_expr_policy);
+	if (err < 0)
+		return err;
+
+	type = nft_expr_type_get(ctx->afi->family, tb[NFTA_EXPR_NAME]);
+	if (IS_ERR(type) < 0) {
+		if (PTR_ERR(type) == -ENOENT)
+			return autoload(ctx, tb[NFTA_EXPR_NAME]);
+
+		return PTR_ERR(type);
+	}
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
+		ops = type->select_ops(ctx,
+				       (const struct nlattr * const *)info->tb);
+		if (IS_ERR(ops)) {
+			err = PTR_ERR(ops);
+			goto err1;
+		}
+	} else
+		ops = type->ops;
+
+	info->ops = ops;
+	return 0;
+
+err1:
+	module_put(type->owner);
+	return err;
+}
+EXPORT_SYMBOL_GPL(nf_tables_expr_parse);
+
+int nf_tables_newexpr(const struct nft_ctx *ctx,
+		      const struct nft_expr_info *info, struct nft_expr *expr)
+{
+	const struct nft_expr_ops *ops = info->ops;
+	int err;
+
+	expr->ops = ops;
+	if (ops->init) {
+		err = ops->init(ctx, expr, (const struct nlattr **)info->tb);
+		if (err < 0)
+			goto err1;
+	}
+
+	return 0;
+
+err1:
+	expr->ops = NULL;
+	return err;
+}
+EXPORT_SYMBOL_GPL(nf_tables_newexpr);
+
+void nf_tables_expr_destroy(const struct nft_ctx *ctx, struct nft_expr *expr)
+{
+	if (expr->ops->destroy)
+		expr->ops->destroy(ctx, expr);
+	module_put(expr->ops->type->owner);
+}
+EXPORT_SYMBOL_GPL(nf_tables_expr_destroy);
+
+int nf_tables_fill_expr_info(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	if (nla_put_string(skb, NFTA_EXPR_NAME, expr->ops->type->name))
+		goto nla_put_failure;
+
+	if (expr->ops->dump) {
+		struct nlattr *data = nla_nest_start(skb, NFTA_EXPR_DATA);
+		if (data == NULL)
+			goto nla_put_failure;
+		if (expr->ops->dump(skb, expr) < 0)
+			goto nla_put_failure;
+		nla_nest_end(skb, data);
+	}
+
+	return skb->len;
+
+nla_put_failure:
+	return -1;
+};
+EXPORT_SYMBOL_GPL(nf_tables_fill_expr_info);
+
+static __init int nf_tables_core_init(void)
+{
+	int err;
+
+	err = nft_immediate_module_init();
+	if (err < 0)
+		goto err1;
+
+	err = nft_cmp_module_init();
+	if (err < 0)
+		goto err2;
+
+	err = nft_bitwise_module_init();
+	if (err < 0)
+		goto err3;
+
+	err = nft_byteorder_module_init();
+	if (err < 0)
+		goto err4;
+
+	err = nft_payload_module_init();
+	if (err < 0)
+		goto err5;
+
+	return 0;
+err5:
+	nft_byteorder_module_exit();
+err4:
+	nft_bitwise_module_exit();
+err3:
+	nft_cmp_module_exit();
+err2:
+	nft_immediate_module_exit();
+err1:
+	return err;
+}
+core_initcall(nf_tables_core_init);
diff --git a/net/netfilter/nf_tables_nf.c b/net/netfilter/nf_tables_nf.c
index d71a0be..a9d2fa4 100644
--- a/net/netfilter/nf_tables_nf.c
+++ b/net/netfilter/nf_tables_nf.c
@@ -180,54 +180,10 @@ EXPORT_SYMBOL_GPL(nft_do_chain);
 
 int __init nf_tables_core_module_init(void)
 {
-	int err;
-
-	err = nft_immediate_module_init();
-	if (err < 0)
-		goto err1;
-
-	err = nft_cmp_module_init();
-	if (err < 0)
-		goto err2;
-
-	err = nft_lookup_module_init();
-	if (err < 0)
-		goto err3;
-
-	err = nft_bitwise_module_init();
-	if (err < 0)
-		goto err4;
-
-	err = nft_byteorder_module_init();
-	if (err < 0)
-		goto err5;
-
-	err = nft_payload_module_init();
-	if (err < 0)
-		goto err6;
-
-	return 0;
-
-err6:
-	nft_byteorder_module_exit();
-err5:
-	nft_bitwise_module_exit();
-err4:
-	nft_lookup_module_exit();
-err3:
-	nft_cmp_module_exit();
-err2:
-	nft_immediate_module_exit();
-err1:
-	return err;
+	return nft_lookup_module_init();
 }
 
 void nf_tables_core_module_exit(void)
 {
-	nft_payload_module_exit();
-	nft_byteorder_module_exit();
-	nft_bitwise_module_exit();
 	nft_lookup_module_exit();
-	nft_cmp_module_exit();
-	nft_immediate_module_exit();
 }
diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index 7758c1c..0252f63 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -161,6 +161,7 @@ const struct nft_expr_ops nft_cmp_fast_ops = {
 	.init		= nft_cmp_fast_init,
 	.dump		= nft_cmp_fast_dump,
 };
+EXPORT_SYMBOL_GPL(nft_cmp_fast_ops);
 
 static const struct nft_expr_ops *
 nft_cmp_select_ops(const struct nft_ctx *ctx, const struct nlattr * const tb[])
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index a2aeb31..acb330e 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -106,6 +106,7 @@ const struct nft_expr_ops nft_payload_fast_ops = {
 	.init		= nft_payload_init,
 	.dump		= nft_payload_dump,
 };
+EXPORT_SYMBOL_GPL(nft_payload_fast_ops);
 
 static const struct nft_expr_ops *
 nft_payload_select_ops(const struct nft_ctx *ctx,
-- 
1.7.10.4

