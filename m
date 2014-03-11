From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH RFC 9/9] netfilter: nf_tables: add support for socket filtering
Date: Tue, 11 Mar 2014 10:19:20 +0100
Message-ID: <1394529560-3490-10-git-send-email-pablo@netfilter.org>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34716 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753032AbaCKJTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2014 05:19:48 -0400
In-Reply-To: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds SO_ATTACH_NFT_FILTER, which allows you to attach
a socket filter expressed using the suppported expressions via
setsockopt. You can detach the filter through SO_DETACH_NFT_FILTER,
which is actually an alias of SO_DETACH_FILTER that was added for
symmetry.

This patch includes a new NFT_SCOPE_SOCK scope which introduces the
verdict interpretation for the socket filtering. It is mimicing BPF,
thus, the returned value indicates the amount of bytes of the packet
that will be copied to userspace.

I also have registered expression types for this new scope, so you
can currently use the payload, immediate, bitwise, byteorder, meta
and cmp expressions to build filters. Moreover, there is a new
validation callback for the expression types which is used to make
sure you don't select unsupported meta expression types.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/filter.h                 |   11 ++
 include/net/netfilter/nf_tables.h      |    6 +
 include/net/netfilter/nf_tables_core.h |    3 +-
 include/uapi/asm-generic/socket.h      |    4 +
 net/core/sock.c                        |   19 ++
 net/netfilter/Kconfig                  |    8 +
 net/netfilter/Makefile                 |    2 +
 net/netfilter/nf_tables_api.c          |    9 +-
 net/netfilter/nf_tables_core.c         |   18 +-
 net/netfilter/nf_tables_sock.c         |  327 ++++++++++++++++++++++++++++++++
 net/netfilter/nft_bitwise.c            |   24 ++-
 net/netfilter/nft_byteorder.c          |   25 ++-
 net/netfilter/nft_cmp.c                |   25 ++-
 net/netfilter/nft_immediate.c          |   25 ++-
 net/netfilter/nft_meta.c               |   43 ++++-
 net/netfilter/nft_payload.c            |   25 ++-
 16 files changed, 558 insertions(+), 16 deletions(-)
 create mode 100644 net/netfilter/nf_tables_sock.c

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 7cba4c2..594cff7 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -9,6 +9,14 @@
 #include <linux/workqueue.h>
 #include <uapi/linux/filter.h>
 
+#ifdef CONFIG_NF_TABLES_SOCKET
+#include <net/netfilter/nf_tables.h>
+
+int sk_nft_attach_filter(char __user *optval, struct sock *sk);
+int sk_nft_get_filter(struct sock *sk, struct sock_filter __user *ubuf,
+		      unsigned int len);
+#endif
+
 #ifdef CONFIG_COMPAT
 /*
  * A struct sock_filter is architecture independent.
@@ -32,6 +40,9 @@ struct sk_filter {
 	union {
 		struct sock_filter     	insns[0];
 		struct work_struct	work;
+#ifdef CONFIG_NF_TABLES_SOCKET
+		struct nft_expr         expr[0];
+#endif
 	};
 };
 
diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index c4c35c4..62280fc 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -70,6 +70,7 @@ static inline void nft_data_debug(const struct nft_data *data)
 
 enum nft_scope {
 	NFT_SCOPE_NF	= 0,
+	NFT_SCOPE_SOCK,
 	NFT_SCOPE_MAX
 };
 
@@ -258,6 +259,7 @@ void nf_tables_unbind_set(const struct nft_ctx *ctx, struct nft_set *set,
 /**
  *	struct nft_expr_type - nf_tables expression type
  *
+ *	@validate: validate the netlink attributes
  *	@select_ops: function to select nft_expr_ops
  *	@ops: default ops, used when no select_ops functions is present
  *	@list: used internally
@@ -265,9 +267,12 @@ void nf_tables_unbind_set(const struct nft_ctx *ctx, struct nft_set *set,
  *	@owner: module reference
  *	@policy: netlink attribute policy
  *	@maxattr: highest netlink attribute number
+ *	@scope: scope for this expression type
  *	@family: address family for AF-specific types
  */
 struct nft_expr_type {
+	int				(*validate)(const struct nft_ctx *,
+						    const struct nlattr * const tb[]);
 	const struct nft_expr_ops	*(*select_ops)(const struct nft_ctx *,
 						       const struct nlattr * const tb[]);
 	const struct nft_expr_ops	*ops;
@@ -276,6 +281,7 @@ struct nft_expr_type {
 	struct module			*owner;
 	const struct nla_policy		*policy;
 	unsigned int			maxattr;
+	enum nft_scope			scope;
 	u8				family;
 };
 
diff --git a/include/net/netfilter/nf_tables_core.h b/include/net/netfilter/nf_tables_core.h
index 41ced3e..9ff6ec5 100644
--- a/include/net/netfilter/nf_tables_core.h
+++ b/include/net/netfilter/nf_tables_core.h
@@ -98,11 +98,12 @@ int nft_register_expr(struct nft_expr_type *type);
 void nft_unregister_expr(struct nft_expr_type *type);
 int nf_tables_newexpr(const struct nft_ctx *ctx,
 		      const struct nft_expr_info *info, struct nft_expr *expr);
-int nf_tables_expr_parse(const struct nft_ctx *ctx,
+int nf_tables_expr_parse(const struct nft_ctx *ctx, u8 family,
 			 const struct nlattr *nla, struct nft_expr_info *info,
 			 int (*autoload)(const struct nft_ctx *ctx,
 					 const struct nlattr *nla));
 const struct nft_expr_type *__nft_expr_type_get(u8 family,
+						enum nft_scope,
 						const struct nlattr *nla);
 void nf_tables_expr_destroy(const struct nft_ctx *ctx, struct nft_expr *expr);
 int nf_tables_fill_expr_info(struct sk_buff *skb, const struct nft_expr *expr,
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index ea0796b..a3bbe85 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -82,4 +82,8 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_ATTACH_NFT_FILTER	49
+#define SO_DETACH_NFT_FILTER	SO_DETACH_FILTER
+#define SO_NFT_GET_FILTER	SO_ATTACH_NFT_FILTER
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 5b6a943..9176700 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -915,6 +915,16 @@ set_rcvbuf:
 					 sk->sk_max_pacing_rate);
 		break;
 
+#ifdef CONFIG_NF_TABLES_SOCKET
+	case SO_ATTACH_NFT_FILTER:
+		ret = -EINVAL;
+		if (optlen < sizeof(struct nlattr))
+			return -EFAULT;
+
+		ret = sk_nft_attach_filter(optval, sk);
+		break;
+#endif
+
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -1185,6 +1195,15 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sk->sk_max_pacing_rate;
 		break;
 
+#ifdef CONFIG_NF_TABLES_SOCKET
+	case SO_NFT_GET_FILTER:
+		len = sk_nft_get_filter(sk, (struct sock_filter __user *)optval, len);
+		if (len < 0)
+			return len;
+
+		goto lenout;
+#endif
+
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 5bd91a8..4eec678 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -433,6 +433,14 @@ config NF_TABLES
 
 	  To compile it as a module, choose M here.
 
+config NF_TABLES_SOCKET
+	bool "Enable nftables socket filtering"
+	depends on NF_TABLES
+	select NF_TABLES_CORE
+	---help---
+	  This feature allows you to use nf_tables expressions to define
+	  socket filters as an alternative to BPF.
+
 config NF_TABLES_INET
 	depends on NF_TABLES && IPV6
 	select NF_TABLES_IPV4
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 7564485..9c32cbd 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -86,6 +86,8 @@ obj-$(CONFIG_NFT_HASH)		+= nft_hash.o
 obj-$(CONFIG_NFT_COUNTER)	+= nft_counter.o
 obj-$(CONFIG_NFT_LOG)		+= nft_log.o
 
+obj-$(CONFIG_NF_TABLES_SOCKET) += nf_tables_sock.o
+
 # generic X tables 
 obj-$(CONFIG_NETFILTER_XTABLES) += x_tables.o xt_tcpudp.o
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index c616fea..fd40d21 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1399,14 +1399,14 @@ static int nft_expr_autoload(const struct nft_ctx *ctx,
 	request_module("nft-expr-%u-%.*s", ctx->afi->family,
 		       nla_len(nla), (char *)nla_data(nla));
 	nfnl_lock(NFNL_SUBSYS_NFTABLES);
-	if (__nft_expr_type_get(ctx->afi->family, nla))
+	if (__nft_expr_type_get(ctx->afi->family, ctx->scope, nla))
 		return -EAGAIN;
 
 	nfnl_unlock(NFNL_SUBSYS_NFTABLES);
 	request_module("nft-expr-%.*s",
 		       nla_len(nla), (char *)nla_data(nla));
 	nfnl_lock(NFNL_SUBSYS_NFTABLES);
-	if (__nft_expr_type_get(ctx->afi->family, nla))
+	if (__nft_expr_type_get(ctx->afi->family, ctx->scope, nla))
 		return -EAGAIN;
 #endif
 	return -ENOENT;
@@ -1484,8 +1484,9 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 				goto err1;
 			if (n == NFT_RULE_MAXEXPRS)
 				goto err1;
-			err = nf_tables_expr_parse(&ctx, tmp, &info[n],
-						    nft_expr_autoload);
+			err = nf_tables_expr_parse(&ctx, afi->family, tmp,
+						   &info[n],
+						   nft_expr_autoload);
 			if (err < 0)
 				goto err1;
 			size += info[n].ops->size;
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index fe427d4..7a2b542 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -54,12 +54,14 @@ void nft_unregister_expr(struct nft_expr_type *type)
 EXPORT_SYMBOL_GPL(nft_unregister_expr);
 
 const struct nft_expr_type *__nft_expr_type_get(u8 family,
+						enum nft_scope scope,
 						const struct nlattr *nla)
 {
 	const struct nft_expr_type *type;
 
 	list_for_each_entry_rcu(type, &nf_tables_expressions, list) {
 		if (!nla_strcmp(nla, type->name) &&
+		    type->scope == scope &&
 		    (!type->family || type->family == family))
 			return type;
 	}
@@ -68,6 +70,7 @@ const struct nft_expr_type *__nft_expr_type_get(u8 family,
 EXPORT_SYMBOL(__nft_expr_type_get);
 
 static const struct nft_expr_type *nft_expr_type_get(u8 family,
+						     enum nft_scope scope,
 						     const struct nlattr *nla)
 {
 	const struct nft_expr_type *type;
@@ -75,7 +78,7 @@ static const struct nft_expr_type *nft_expr_type_get(u8 family,
 	if (nla == NULL)
 		return ERR_PTR(-EINVAL);
 
-	type = __nft_expr_type_get(family, nla);
+	type = __nft_expr_type_get(family, scope, nla);
 	if (type != NULL && try_module_get(type->owner))
 		return type;
 
@@ -87,8 +90,8 @@ static const struct nla_policy nft_expr_policy[NFTA_EXPR_MAX + 1] = {
 	[NFTA_EXPR_DATA]	= { .type = NLA_NESTED },
 };
 
-int nf_tables_expr_parse(const struct nft_ctx *ctx, const struct nlattr *nla,
-			 struct nft_expr_info *info,
+int nf_tables_expr_parse(const struct nft_ctx *ctx, u8 family,
+			 const struct nlattr *nla, struct nft_expr_info *info,
 			 int (*autoload)(const struct nft_ctx *ctx,
 					 const struct nlattr *nla))
 {
@@ -101,8 +104,8 @@ int nf_tables_expr_parse(const struct nft_ctx *ctx, const struct nlattr *nla,
 	if (err < 0)
 		return err;
 
-	type = nft_expr_type_get(ctx->afi->family, tb[NFTA_EXPR_NAME]);
-	if (IS_ERR(type) < 0) {
+	type = nft_expr_type_get(family, ctx->scope, tb[NFTA_EXPR_NAME]);
+	if (IS_ERR(type)) {
 		if (PTR_ERR(type) == -ENOENT)
 			return autoload(ctx, tb[NFTA_EXPR_NAME]);
 
@@ -143,6 +146,11 @@ int nf_tables_newexpr(const struct nft_ctx *ctx,
 	int err;
 
 	expr->ops = ops;
+	if (ops->type->validate) {
+		err = ops->type->validate(ctx, (const struct nlattr **)info->tb);
+		if (err < 0)
+			goto err1;
+	}
 	if (ops->init) {
 		err = ops->init(ctx, expr, (const struct nlattr **)info->tb);
 		if (err < 0)
diff --git a/net/netfilter/nf_tables_sock.c b/net/netfilter/nf_tables_sock.c
new file mode 100644
index 0000000..533a285
--- /dev/null
+++ b/net/netfilter/nf_tables_sock.c
@@ -0,0 +1,327 @@
+/*
+ * (C) 2014 by Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published
+ * by the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+#include <linux/kernel.h>
+#include <linux/kmod.h>
+#include <linux/module.h>
+#include <linux/filter.h>
+#include <net/sock.h>
+#include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_core.h>
+
+#define nft_filter_for_each_expr(expr, rem) \
+	for (; rem > 0; rem -= expr->ops->size, expr = nft_expr_next(expr))
+
+static unsigned int sk_nft_run_filter(const struct sk_buff *skb,
+				      const struct sock_filter *filter)
+{
+	const struct nft_expr *expr = (const struct nft_expr *)filter;
+	struct sk_filter *fp = container_of(filter, struct sk_filter, insns[0]);
+	struct nft_data data[NFT_REG_MAX + 1];
+	const struct nft_pktinfo pkt = {
+		.skb		= (struct sk_buff *)skb,
+		.in		= skb->dev,
+		.xt.thoff	= skb_transport_offset(skb),
+	};
+	int rem = fp->size;
+
+	data[NFT_REG_VERDICT].verdict = 0;
+	nft_filter_for_each_expr(expr, rem) {
+		if (expr->ops == &nft_cmp_fast_ops)
+			nft_cmp_fast_eval(expr, data);
+		else if (expr->ops != &nft_payload_fast_ops ||
+			 !nft_payload_fast_eval(expr, data, &pkt))
+			expr->ops->eval(expr, data, &pkt);
+		switch (data[NFT_REG_VERDICT].verdict) {
+		case NFT_BREAK:
+			/* we got a mismatch, skip this packet */
+			return 0;
+		}
+	}
+	return data[NFT_REG_VERDICT].verdict;
+}
+
+static void sk_nft_filter_release_rcu(struct rcu_head *rcu)
+{
+	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
+	struct nft_expr *expr = fp->expr;
+	struct nft_ctx ctx = {
+		.scope	= NFT_SCOPE_SOCK,
+	};
+	int rem = fp->size;
+
+	nft_filter_for_each_expr(expr, rem)
+		nf_tables_expr_destroy(&ctx, expr);
+
+	kfree(fp);
+}
+
+/* Maximum number of expressions per filter, like BPF */
+#define SK_NFT_MAX_EXPR	4096
+static struct nft_expr_info *info;
+static DEFINE_MUTEX(nft_expr_info_mutex);
+
+static int nft_sock_expr_autoload(const struct nft_ctx *ctx,
+				  const struct nlattr *nla)
+{
+#ifdef CONFIG_MODULES
+	mutex_unlock(&nft_expr_info_mutex);
+	request_module("nft-expr-%.*s", nla_len(nla), (char *)nla_data(nla));
+	mutex_lock(&nft_expr_info_mutex);
+	if (__nft_expr_type_get(AF_UNSPEC, ctx->scope, nla))
+		return -EAGAIN;
+#endif
+	return -ENOENT;
+}
+
+int sk_nft_attach_filter(char __user *optval, struct sock *sk)
+{
+	struct sk_filter *fp, *old_fp;
+	size_t size;
+	struct nlattr _attr;
+	struct nlattr *attr, *tmp;
+	int err, i, n;
+	struct nft_expr *expr;
+	int ret, rem;
+	struct nft_ctx ctx = {
+		.scope = NFT_SCOPE_SOCK,
+	};
+
+	if (sock_flag(sk, SOCK_FILTER_LOCKED))
+		return -EPERM;
+
+	if (copy_from_user((void *)&_attr, optval, sizeof(struct nlattr))) {
+		err = -EFAULT;
+		goto err1;
+	}
+
+	if (_attr.nla_len < sizeof(struct nlattr)) {
+		err = -EFAULT;
+		goto err1;
+	}
+
+	attr = kmalloc(_attr.nla_len, GFP_KERNEL);
+	if (!attr) {
+		ret = -ENOMEM;
+		goto err1;
+	}
+
+	if (copy_from_user(attr, optval, _attr.nla_len)) {
+		err = -EFAULT;
+		goto err2;
+	}
+retry:
+	size = 0;
+	n = 0;
+	mutex_lock(&nft_expr_info_mutex);
+	nla_for_each_nested(tmp, attr, rem) {
+		err = -EINVAL;
+		if (nla_type(tmp) != NFTA_LIST_ELEM)
+			goto err3;
+		if (n == SK_NFT_MAX_EXPR)
+			goto err3;
+		err = nf_tables_expr_parse(&ctx, AF_UNSPEC, tmp, &info[n],
+					   nft_sock_expr_autoload);
+		if (err < 0) {
+			if (err == -EAGAIN) {
+				for (i = 0; i < n; i++) {
+					if (info[i].ops != NULL)
+						module_put(info[i].ops->type->owner);
+				}
+				mutex_unlock(&nft_expr_info_mutex);
+				goto retry;
+			}
+			goto err3;
+		}
+
+		size += info[n].ops->size;
+		n++;
+	}
+
+	fp = sock_kmalloc(sk, sizeof(struct sk_filter) + size, GFP_KERNEL);
+	if (!fp) {
+		err = -ENOMEM;
+		goto err3;
+	}
+
+	expr = fp->expr;
+	for (i = 0; i < n; i++) {
+		err = nf_tables_newexpr(&ctx, &info[i], expr);
+		if (err < 0)
+			goto err4;
+		info[i].ops = NULL;
+		expr = nft_expr_next(expr);
+	}
+	mutex_unlock(&nft_expr_info_mutex);
+
+	atomic_set(&fp->refcnt, 1);
+	fp->size = size;
+	fp->run_filter = sk_nft_run_filter;
+	fp->release_rcu = sk_nft_filter_release_rcu;
+
+	old_fp = rcu_dereference_protected(sk->sk_filter,
+					   sock_owned_by_user(sk));
+	rcu_assign_pointer(sk->sk_filter, fp);
+
+	if (old_fp)
+		sk_filter_uncharge(sk, old_fp);
+	return 0;
+err4:
+	sock_kfree_s(sk, fp, size);
+err3:
+	for (i = 0; i < n; i++) {
+		if (info[i].ops != NULL)
+			module_put(info[i].ops->type->owner);
+	}
+	mutex_unlock(&nft_expr_info_mutex);
+err2:
+	kfree(attr);
+err1:
+	return err;
+}
+EXPORT_SYMBOL_GPL(sk_nft_attach_filter);
+
+int sk_nft_get_filter(struct sock *sk, struct sock_filter __user *ubuf,
+		      unsigned int len)
+{
+	struct sk_buff *skb;
+	struct sk_filter *fp;
+	int ret = 0, rem;
+	struct nlattr *list;
+	struct nft_expr *expr;
+
+	lock_sock(sk);
+	fp = rcu_dereference_protected(sk->sk_filter, sock_owned_by_user(sk));
+	if (!fp)
+		goto out;
+
+	/* Estimate the size of the bytecode to TLV translation based on
+	 * worst case scenario according to the expressions that we have:
+	 *
+	 * NFTA_RULE_EXPRESSIONS nest	4 bytes
+	 * NFTA_LIST_ELEM nest		4 bytes
+	 * 	4 attribute header	4 * 4 bytes = 16 bytes
+	 *	2 attribute (16 bytes)	2 * 16 bytes = 32 bytes
+	 *	2 attribute (4 bytes)	2 * 4 bytes = 8 bytes     +
+	 * ---------------------------------------------------------
+	 *				64 bytes
+	 */
+	skb = alloc_skb(fp->size * 64, GFP_KERNEL);
+	if (!skb) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	rem = fp->size;
+	list = nla_nest_start(skb, NFTA_RULE_EXPRESSIONS);
+	if (list == NULL)
+		goto nla_put_failure;
+	nft_filter_for_each_expr(expr, rem) {
+		struct nlattr *elem = nla_nest_start(skb, NFTA_LIST_ELEM);
+		if (elem == NULL)
+			goto nla_put_failure;
+		if (nf_tables_fill_expr_info(skb, expr, NFT_SCOPE_SOCK) < 0)
+			goto nla_put_failure;
+		nla_nest_end(skb, elem);
+	}
+	nla_nest_end(skb, list);
+
+	if (copy_to_user(ubuf, skb->data, skb->len)) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	kfree_skb(skb);
+	ret = skb->len;
+out:
+	release_sock(sk);
+	return ret;
+
+nla_put_failure:
+	release_sock(sk);
+	kfree_skb(skb);
+	return -EFAULT;
+}
+EXPORT_SYMBOL_GPL(sk_nft_get_filter);
+
+static const struct nla_policy nft_verdict_policy[NFTA_VERDICT_MAX + 1] = {
+	[NFTA_VERDICT_CODE]	= { .type = NLA_U32 },
+};
+
+static int nft_sock_verdict_init(const struct nft_ctx *ctx,
+				 struct nft_data *data,
+				 struct nft_data_desc *desc,
+				 const struct nlattr *nla)
+{
+	struct nlattr *tb[NFTA_VERDICT_MAX + 1];
+	int err;
+
+	err = nla_parse_nested(tb, NFTA_VERDICT_MAX, nla, nft_verdict_policy);
+	if (err < 0)
+		return err;
+
+	if (!tb[NFTA_VERDICT_CODE])
+		return -EINVAL;
+
+	data->verdict = ntohl(nla_get_be32(tb[NFTA_VERDICT_CODE]));
+	desc->type = NFT_DATA_VERDICT;
+
+	return 0;
+}
+
+static int nft_sock_validate_verdict(const struct nft_ctx *ctx,
+				     enum nft_registers reg,
+				     const struct nft_data *data,
+				     enum nft_data_types type)
+{
+	return 0;
+}
+
+static void nft_sock_verdict_uninit(const struct nft_data *data)
+{
+}
+
+static int nft_sock_verdict_dump(struct sk_buff *skb,
+				 const struct nft_data *data)
+{
+	struct nlattr *nest;
+
+	nest = nla_nest_start(skb, NFTA_DATA_VERDICT);
+	if (!nest)
+		goto nla_put_failure;
+
+	if (nla_put_be32(skb, NFTA_VERDICT_CODE, htonl(data->verdict)))
+		goto nla_put_failure;
+
+	nla_nest_end(skb, nest);
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static const struct nft_verdict_ops nft_data_sock_ops = {
+	.init		= nft_sock_verdict_init,
+	.validate	= nft_sock_validate_verdict,
+	.uninit		= nft_sock_verdict_uninit,
+	.dump		= nft_sock_verdict_dump,
+};
+
+static __init int nft_sock_init(void)
+{
+	info = kmalloc(SK_NFT_MAX_EXPR * sizeof(struct nft_expr_info),
+		       GFP_KERNEL);
+	if (info == NULL) {
+		pr_err("Cannot initialize nft socket filtering");
+		return -ENOMEM;
+	}
+
+	nft_verdict_ops_register(NFT_SCOPE_SOCK, &nft_data_sock_ops);
+	return 0;
+}
+core_initcall(nft_sock_init);
diff --git a/net/netfilter/nft_bitwise.c b/net/netfilter/nft_bitwise.c
index 9e87b67..d8c0dfd 100644
--- a/net/netfilter/nft_bitwise.c
+++ b/net/netfilter/nft_bitwise.c
@@ -136,9 +136,31 @@ static struct nft_expr_type nft_bitwise_type __read_mostly = {
 	.owner		= THIS_MODULE,
 };
 
+static struct nft_expr_type nft_bitwise_sock_type __read_mostly = {
+	.name		= "bitwise",
+	.scope		= NFT_SCOPE_SOCK,
+	.ops		= &nft_bitwise_ops,
+	.policy		= nft_bitwise_policy,
+	.maxattr	= NFTA_BITWISE_MAX,
+	.owner		= THIS_MODULE,
+};
+
 int __init nft_bitwise_module_init(void)
 {
-	return nft_register_expr(&nft_bitwise_type);
+	int err;
+
+	err = nft_register_expr(&nft_bitwise_type);
+	if (err < 0)
+		return err;
+
+	err = nft_register_expr(&nft_bitwise_sock_type);
+	if (err < 0)
+		goto err1;
+
+	return 0;
+err1:
+	nft_unregister_expr(&nft_bitwise_type);
+	return err;
 }
 
 void nft_bitwise_module_exit(void)
diff --git a/net/netfilter/nft_byteorder.c b/net/netfilter/nft_byteorder.c
index baca196..bcaff60 100644
--- a/net/netfilter/nft_byteorder.c
+++ b/net/netfilter/nft_byteorder.c
@@ -163,12 +163,35 @@ static struct nft_expr_type nft_byteorder_type __read_mostly = {
 	.owner		= THIS_MODULE,
 };
 
+static struct nft_expr_type nft_byteorder_sock_type __read_mostly = {
+	.name		= "byteorder",
+	.scope		= NFT_SCOPE_SOCK,
+	.ops		= &nft_byteorder_ops,
+	.policy		= nft_byteorder_policy,
+	.maxattr	= NFTA_BYTEORDER_MAX,
+	.owner		= THIS_MODULE,
+};
+
 int __init nft_byteorder_module_init(void)
 {
-	return nft_register_expr(&nft_byteorder_type);
+	int err;
+
+	err = nft_register_expr(&nft_byteorder_type);
+	if (err < 0)
+		return err;
+
+	err = nft_register_expr(&nft_byteorder_sock_type);
+	if (err < 0)
+		goto err1;
+
+	return 0;
+err1:
+	nft_unregister_expr(&nft_byteorder_type);
+	return err;
 }
 
 void nft_byteorder_module_exit(void)
 {
+	nft_unregister_expr(&nft_byteorder_sock_type);
 	nft_unregister_expr(&nft_byteorder_type);
 }
diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index 3117110..f70b883 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -216,12 +216,35 @@ static struct nft_expr_type nft_cmp_type __read_mostly = {
 	.owner		= THIS_MODULE,
 };
 
+static struct nft_expr_type nft_cmp_sock_type __read_mostly = {
+	.name		= "cmp",
+	.scope		= NFT_SCOPE_SOCK,
+	.select_ops	= nft_cmp_select_ops,
+	.policy		= nft_cmp_policy,
+	.maxattr	= NFTA_CMP_MAX,
+	.owner		= THIS_MODULE,
+};
+
 int __init nft_cmp_module_init(void)
 {
-	return nft_register_expr(&nft_cmp_type);
+	int err;
+
+	err = nft_register_expr(&nft_cmp_type);
+	if (err < 0)
+		return err;
+
+	err = nft_register_expr(&nft_cmp_sock_type);
+	if (err < 0)
+		goto err1;
+
+	return 0;
+err1:
+	nft_unregister_expr(&nft_cmp_type);
+	return err;
 }
 
 void nft_cmp_module_exit(void)
 {
+	nft_unregister_expr(&nft_cmp_sock_type);
 	nft_unregister_expr(&nft_cmp_type);
 }
diff --git a/net/netfilter/nft_immediate.c b/net/netfilter/nft_immediate.c
index ae359f4..3470346 100644
--- a/net/netfilter/nft_immediate.c
+++ b/net/netfilter/nft_immediate.c
@@ -124,12 +124,35 @@ static struct nft_expr_type nft_imm_type __read_mostly = {
 	.owner		= THIS_MODULE,
 };
 
+static struct nft_expr_type nft_imm_sock_type __read_mostly = {
+	.name		= "immediate",
+	.scope		= NFT_SCOPE_SOCK,
+	.ops		= &nft_imm_ops,
+	.policy		= nft_immediate_policy,
+	.maxattr	= NFTA_IMMEDIATE_MAX,
+	.owner		= THIS_MODULE,
+};
+
 int __init nft_immediate_module_init(void)
 {
-	return nft_register_expr(&nft_imm_type);
+	int err;
+
+	err = nft_register_expr(&nft_imm_type);
+	if (err < 0)
+		return err;
+
+	err = nft_register_expr(&nft_imm_sock_type);
+	if (err < 0)
+		goto err1;
+
+	return 0;
+err1:
+	nft_unregister_expr(&nft_imm_type);
+	return err;
 }
 
 void nft_immediate_module_exit(void)
 {
+	nft_unregister_expr(&nft_imm_sock_type);
 	nft_unregister_expr(&nft_imm_type);
 }
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 82c40d8..11df25e 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -321,13 +321,54 @@ static struct nft_expr_type nft_meta_type __read_mostly = {
 	.owner		= THIS_MODULE,
 };
 
+static int nft_meta_type_sock_validate(const struct nft_ctx *ctx,
+				       const struct nlattr * const tb[])
+{
+	switch (ntohl(nla_get_be32(tb[NFTA_META_KEY]))) {
+	case NFT_META_LEN:
+	case NFT_META_PROTOCOL:
+	case NFT_META_PRIORITY:
+	case NFT_META_MARK:
+	case NFT_META_IIF:
+	case NFT_META_IIFNAME:
+	case NFT_META_IIFTYPE:
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static struct nft_expr_type nft_meta_sock_type __read_mostly = {
+	.name		= "meta",
+	.scope		= NFT_SCOPE_SOCK,
+	.validate	= nft_meta_type_sock_validate,
+	.select_ops	= &nft_meta_select_ops,
+	.policy		= nft_meta_policy,
+	.maxattr	= NFTA_META_MAX,
+	.owner		= THIS_MODULE,
+};
+
 static int __init nft_meta_module_init(void)
 {
-	return nft_register_expr(&nft_meta_type);
+	int err;
+
+	err = nft_register_expr(&nft_meta_type);
+	if (err < 0)
+		return err;
+
+	err = nft_register_expr(&nft_meta_sock_type);
+	if (err < 0)
+		goto err1;
+
+	return 0;
+err1:
+	nft_unregister_expr(&nft_meta_type);
+	return err;
 }
 
 static void __exit nft_meta_module_exit(void)
 {
+	nft_unregister_expr(&nft_meta_sock_type);
 	nft_unregister_expr(&nft_meta_type);
 }
 
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index 9deadb6..e40fd67 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -151,12 +151,35 @@ static struct nft_expr_type nft_payload_type __read_mostly = {
 	.owner		= THIS_MODULE,
 };
 
+static struct nft_expr_type nft_payload_sock_type __read_mostly = {
+	.name		= "payload",
+	.scope		= NFT_SCOPE_SOCK,
+	.select_ops	= nft_payload_select_ops,
+	.policy		= nft_payload_policy,
+	.maxattr	= NFTA_PAYLOAD_MAX,
+	.owner		= THIS_MODULE,
+};
+
 int __init nft_payload_module_init(void)
 {
-	return nft_register_expr(&nft_payload_type);
+	int err;
+
+	err = nft_register_expr(&nft_payload_type);
+	if (err < 0)
+		return err;
+
+	err = nft_register_expr(&nft_payload_sock_type);
+	if (err < 0)
+		goto err1;
+
+	return 0;
+err1:
+	nft_unregister_expr(&nft_payload_type);
+	return err;
 }
 
 void nft_payload_module_exit(void)
 {
+	nft_unregister_expr(&nft_payload_sock_type);
 	nft_unregister_expr(&nft_payload_type);
 }
-- 
1.7.10.4
