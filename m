From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/21] netfilter: nf_tables: add helper functions for expression handling
Date: Mon, 13 Apr 2015 21:29:55 +0200
Message-ID: <1428953401-4838-17-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39721 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754602AbbDMT0C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 15:26:02 -0400
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Add helper functions for initializing, cloning, dumping and destroying
a single expression that is not part of a rule.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |   13 +++++++++
 net/netfilter/nf_tables_api.c     |   56 +++++++++++++++++++++++++++++++++----
 2 files changed, 64 insertions(+), 5 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index cb42da1..e21623c 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -1,6 +1,7 @@
 #ifndef _NET_NF_TABLES_H
 #define _NET_NF_TABLES_H
 
+#include <linux/module.h>
 #include <linux/list.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter/nfnetlink.h>
@@ -641,6 +642,18 @@ static inline void *nft_expr_priv(const struct nft_expr *expr)
 	return (void *)expr->data;
 }
 
+struct nft_expr *nft_expr_init(const struct nft_ctx *ctx,
+			       const struct nlattr *nla);
+void nft_expr_destroy(const struct nft_ctx *ctx, struct nft_expr *expr);
+int nft_expr_dump(struct sk_buff *skb, unsigned int attr,
+		  const struct nft_expr *expr);
+
+static inline void nft_expr_clone(struct nft_expr *dst, struct nft_expr *src)
+{
+	__module_get(src->ops->type->owner);
+	memcpy(dst, src, src->ops->size);
+}
+
 /**
  *	struct nft_rule - nf_tables rule
  *
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index ed0e70e..e97bee5 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1545,6 +1545,23 @@ nla_put_failure:
 	return -1;
 };
 
+int nft_expr_dump(struct sk_buff *skb, unsigned int attr,
+		  const struct nft_expr *expr)
+{
+	struct nlattr *nest;
+
+	nest = nla_nest_start(skb, attr);
+	if (!nest)
+		goto nla_put_failure;
+	if (nf_tables_fill_expr_info(skb, expr) < 0)
+		goto nla_put_failure;
+	nla_nest_end(skb, nest);
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
 struct nft_expr_info {
 	const struct nft_expr_ops	*ops;
 	struct nlattr			*tb[NFT_EXPR_MAXATTR + 1];
@@ -1622,6 +1639,39 @@ static void nf_tables_expr_destroy(const struct nft_ctx *ctx,
 	module_put(expr->ops->type->owner);
 }
 
+struct nft_expr *nft_expr_init(const struct nft_ctx *ctx,
+			       const struct nlattr *nla)
+{
+	struct nft_expr_info info;
+	struct nft_expr *expr;
+	int err;
+
+	err = nf_tables_expr_parse(ctx, nla, &info);
+	if (err < 0)
+		goto err1;
+
+	err = -ENOMEM;
+	expr = kzalloc(info.ops->size, GFP_KERNEL);
+	if (expr == NULL)
+		goto err2;
+
+	err = nf_tables_newexpr(ctx, &info, expr);
+	if (err < 0)
+		goto err2;
+
+	return expr;
+err2:
+	module_put(info.ops->type->owner);
+err1:
+	return ERR_PTR(err);
+}
+
+void nft_expr_destroy(const struct nft_ctx *ctx, struct nft_expr *expr)
+{
+	nf_tables_expr_destroy(ctx, expr);
+	kfree(expr);
+}
+
 /*
  * Rules
  */
@@ -1703,12 +1753,8 @@ static int nf_tables_fill_rule_info(struct sk_buff *skb, struct net *net,
 	if (list == NULL)
 		goto nla_put_failure;
 	nft_rule_for_each_expr(expr, next, rule) {
-		struct nlattr *elem = nla_nest_start(skb, NFTA_LIST_ELEM);
-		if (elem == NULL)
-			goto nla_put_failure;
-		if (nf_tables_fill_expr_info(skb, expr) < 0)
+		if (nft_expr_dump(skb, NFTA_LIST_ELEM, expr) < 0)
 			goto nla_put_failure;
-		nla_nest_end(skb, elem);
 	}
 	nla_nest_end(skb, list);
 
-- 
1.7.10.4
