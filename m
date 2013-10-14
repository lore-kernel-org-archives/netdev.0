From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/17] netfilter: nf_tables: add optimized data comparison for small values
Date: Mon, 14 Oct 2013 18:38:47 +0200
Message-ID: <1381768738-17739-7-git-send-email-pablo@netfilter.org>
References: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34755 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757262Ab3JNQjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 12:39:18 -0400
In-Reply-To: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Add an optimized version of nft_data_cmp() that only handles values of to
4 bytes length.

This patch includes original Patrick McHardy's patch entitled (nf_tables:
inline nft_cmp_fast_eval() into main evaluation loop).

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables_core.h |    8 +++
 net/netfilter/nf_tables_core.c         |   18 ++++-
 net/netfilter/nft_cmp.c                |  116 +++++++++++++++++++++++++-------
 3 files changed, 118 insertions(+), 24 deletions(-)

diff --git a/include/net/netfilter/nf_tables_core.h b/include/net/netfilter/nf_tables_core.h
index 283396c..3df6a9b 100644
--- a/include/net/netfilter/nf_tables_core.h
+++ b/include/net/netfilter/nf_tables_core.h
@@ -7,6 +7,14 @@ extern void nf_tables_core_module_exit(void);
 extern int nft_immediate_module_init(void);
 extern void nft_immediate_module_exit(void);
 
+struct nft_cmp_fast_expr {
+	u32			data;
+	enum nft_registers	sreg:8;
+	u8			len;
+};
+
+extern const struct nft_expr_ops nft_cmp_fast_ops;
+
 extern int nft_cmp_module_init(void);
 extern void nft_cmp_module_exit(void);
 
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index fd0ecd3..2400018 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -20,6 +20,18 @@
 #include <net/netfilter/nf_tables_core.h>
 #include <net/netfilter/nf_tables.h>
 
+static void nft_cmp_fast_eval(const struct nft_expr *expr,
+			      struct nft_data data[NFT_REG_MAX + 1])
+{
+	const struct nft_cmp_fast_expr *priv = nft_expr_priv(expr);
+	u32 mask;
+
+	mask = ~0U >> (sizeof(priv->data) * BITS_PER_BYTE - priv->len);
+	if ((data[priv->sreg].data[0] & mask) == priv->data)
+		return;
+	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
+}
+
 unsigned int nft_do_chain(const struct nf_hook_ops *ops,
 			  struct sk_buff *skb,
 			  const struct net_device *in,
@@ -48,7 +60,11 @@ next_rule:
 	data[NFT_REG_VERDICT].verdict = NFT_CONTINUE;
 	list_for_each_entry_continue_rcu(rule, &chain->rules, list) {
 		nft_rule_for_each_expr(expr, last, rule) {
-			expr->ops->eval(expr, data, &pkt);
+			if (expr->ops == &nft_cmp_fast_ops)
+				nft_cmp_fast_eval(expr, data);
+			else
+				expr->ops->eval(expr, data, &pkt);
+
 			if (data[NFT_REG_VERDICT].verdict != NFT_CONTINUE)
 				break;
 		}
diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index 2c9d5fe..37134f3 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -75,32 +75,11 @@ static int nft_cmp_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	struct nft_data_desc desc;
 	int err;
 
-	if (tb[NFTA_CMP_SREG] == NULL ||
-	    tb[NFTA_CMP_OP] == NULL ||
-	    tb[NFTA_CMP_DATA] == NULL)
-		return -EINVAL;
-
 	priv->sreg = ntohl(nla_get_be32(tb[NFTA_CMP_SREG]));
-	err = nft_validate_input_register(priv->sreg);
-	if (err < 0)
-		return err;
-
 	priv->op = ntohl(nla_get_be32(tb[NFTA_CMP_OP]));
-	switch (priv->op) {
-	case NFT_CMP_EQ:
-	case NFT_CMP_NEQ:
-	case NFT_CMP_LT:
-	case NFT_CMP_LTE:
-	case NFT_CMP_GT:
-	case NFT_CMP_GTE:
-		break;
-	default:
-		return -EINVAL;
-	}
 
 	err = nft_data_init(NULL, &priv->data, &desc, tb[NFTA_CMP_DATA]);
-	if (err < 0)
-		return err;
+	BUG_ON(err < 0);
 
 	priv->len = desc.len;
 	return 0;
@@ -133,9 +112,100 @@ static const struct nft_expr_ops nft_cmp_ops = {
 	.dump		= nft_cmp_dump,
 };
 
+static int nft_cmp_fast_init(const struct nft_ctx *ctx,
+			     const struct nft_expr *expr,
+			     const struct nlattr * const tb[])
+{
+	struct nft_cmp_fast_expr *priv = nft_expr_priv(expr);
+	struct nft_data_desc desc;
+	struct nft_data data;
+	u32 mask;
+	int err;
+
+	priv->sreg = ntohl(nla_get_be32(tb[NFTA_CMP_SREG]));
+
+	err = nft_data_init(NULL, &data, &desc, tb[NFTA_CMP_DATA]);
+	BUG_ON(err < 0);
+	desc.len *= BITS_PER_BYTE;
+
+	mask = ~0U >> (sizeof(priv->data) * BITS_PER_BYTE - desc.len);
+	priv->data = data.data[0] & mask;
+	priv->len  = desc.len;
+	return 0;
+}
+
+static int nft_cmp_fast_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	const struct nft_cmp_fast_expr *priv = nft_expr_priv(expr);
+	struct nft_data data;
+
+	if (nla_put_be32(skb, NFTA_CMP_SREG, htonl(priv->sreg)))
+		goto nla_put_failure;
+	if (nla_put_be32(skb, NFTA_CMP_OP, htonl(NFT_CMP_EQ)))
+		goto nla_put_failure;
+
+	data.data[0] = priv->data;
+	if (nft_data_dump(skb, NFTA_CMP_DATA, &data,
+			  NFT_DATA_VALUE, priv->len / BITS_PER_BYTE) < 0)
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+const struct nft_expr_ops nft_cmp_fast_ops = {
+	.type		= &nft_cmp_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_cmp_fast_expr)),
+	.eval		= NULL,	/* inlined */
+	.init		= nft_cmp_fast_init,
+	.dump		= nft_cmp_fast_dump,
+};
+
+static const struct nft_expr_ops *nft_cmp_select_ops(const struct nlattr * const tb[])
+{
+	struct nft_data_desc desc;
+	struct nft_data data;
+	enum nft_registers sreg;
+	enum nft_cmp_ops op;
+	int err;
+
+	if (tb[NFTA_CMP_SREG] == NULL ||
+	    tb[NFTA_CMP_OP] == NULL ||
+	    tb[NFTA_CMP_DATA] == NULL)
+		return ERR_PTR(-EINVAL);
+
+	sreg = ntohl(nla_get_be32(tb[NFTA_CMP_SREG]));
+	err = nft_validate_input_register(sreg);
+	if (err < 0)
+		return ERR_PTR(err);
+
+	op = ntohl(nla_get_be32(tb[NFTA_CMP_OP]));
+	switch (op) {
+	case NFT_CMP_EQ:
+	case NFT_CMP_NEQ:
+	case NFT_CMP_LT:
+	case NFT_CMP_LTE:
+	case NFT_CMP_GT:
+	case NFT_CMP_GTE:
+		break;
+	default:
+		return ERR_PTR(-EINVAL);
+	}
+
+	err = nft_data_init(NULL, &data, &desc, tb[NFTA_CMP_DATA]);
+	if (err < 0)
+		return ERR_PTR(err);
+
+	if (desc.len <= sizeof(u32) && op == NFT_CMP_EQ)
+		return &nft_cmp_fast_ops;
+	else
+		return &nft_cmp_ops;
+}
+
 static struct nft_expr_type nft_cmp_type __read_mostly = {
 	.name		= "cmp",
-	.ops		= &nft_cmp_ops,
+	.select_ops	= nft_cmp_select_ops,
 	.policy		= nft_cmp_policy,
 	.maxattr	= NFTA_CMP_MAX,
 	.owner		= THIS_MODULE,
-- 
1.7.10.4
