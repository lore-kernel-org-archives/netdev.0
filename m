From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/17] netfilter: nft_payload: add optimized payload implementation for small loads
Date: Mon, 14 Oct 2013 18:38:48 +0200
Message-ID: <1381768738-17739-8-git-send-email-pablo@netfilter.org>
References: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34764 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757266Ab3JNQjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 12:39:19 -0400
In-Reply-To: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Add an optimized payload expression implementation for small (up to 4 bytes)
aligned data loads from the linear packet area.

This patch also includes original Patrick McHardy's entitled (nf_tables:
inline nft_payload_fast_eval() into main evaluation loop).

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables_core.h |    9 +++++
 net/netfilter/nf_tables_core.c         |   31 +++++++++++++-
 net/netfilter/nft_payload.c            |   69 +++++++++++++++++++-------------
 3 files changed, 81 insertions(+), 28 deletions(-)

diff --git a/include/net/netfilter/nf_tables_core.h b/include/net/netfilter/nf_tables_core.h
index 3df6a9b..fe7b162 100644
--- a/include/net/netfilter/nf_tables_core.h
+++ b/include/net/netfilter/nf_tables_core.h
@@ -27,6 +27,15 @@ extern void nft_bitwise_module_exit(void);
 extern int nft_byteorder_module_init(void);
 extern void nft_byteorder_module_exit(void);
 
+struct nft_payload {
+	enum nft_payload_bases	base:8;
+	u8			offset;
+	u8			len;
+	enum nft_registers	dreg:8;
+};
+
+extern const struct nft_expr_ops nft_payload_fast_ops;
+
 extern int nft_payload_module_init(void);
 extern void nft_payload_module_exit(void);
 
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 2400018..9aede59 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -32,6 +32,34 @@ static void nft_cmp_fast_eval(const struct nft_expr *expr,
 	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
 }
 
+static bool nft_payload_fast_eval(const struct nft_expr *expr,
+				  struct nft_data data[NFT_REG_MAX + 1],
+				  const struct nft_pktinfo *pkt)
+{
+	const struct nft_payload *priv = nft_expr_priv(expr);
+	const struct sk_buff *skb = pkt->skb;
+	struct nft_data *dest = &data[priv->dreg];
+	unsigned char *ptr;
+
+	if (priv->base == NFT_PAYLOAD_NETWORK_HEADER)
+		ptr = skb_network_header(skb);
+	else
+		ptr = skb_transport_header(skb);
+
+	ptr += priv->offset;
+
+	if (unlikely(ptr + priv->len >= skb_tail_pointer(skb)))
+		return false;
+
+	if (priv->len == 2)
+		*(u16 *)dest->data = *(u16 *)ptr;
+	else if (priv->len == 4)
+		*(u32 *)dest->data = *(u32 *)ptr;
+	else
+		*(u8 *)dest->data = *(u8 *)ptr;
+	return true;
+}
+
 unsigned int nft_do_chain(const struct nf_hook_ops *ops,
 			  struct sk_buff *skb,
 			  const struct net_device *in,
@@ -62,7 +90,8 @@ next_rule:
 		nft_rule_for_each_expr(expr, last, rule) {
 			if (expr->ops == &nft_cmp_fast_ops)
 				nft_cmp_fast_eval(expr, data);
-			else
+			else if (expr->ops != &nft_payload_fast_ops ||
+				 !nft_payload_fast_eval(expr, data, &pkt))
 				expr->ops->eval(expr, data, &pkt);
 
 			if (data[NFT_REG_VERDICT].verdict != NFT_CONTINUE)
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index d99db6e..7cf13f7 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -17,13 +17,6 @@
 #include <net/netfilter/nf_tables_core.h>
 #include <net/netfilter/nf_tables.h>
 
-struct nft_payload {
-	enum nft_payload_bases	base:8;
-	u8			offset;
-	u8			len;
-	enum nft_registers	dreg:8;
-};
-
 static void nft_payload_eval(const struct nft_expr *expr,
 			     struct nft_data data[NFT_REG_MAX + 1],
 			     const struct nft_pktinfo *pkt)
@@ -71,27 +64,9 @@ static int nft_payload_init(const struct nft_ctx *ctx,
 	struct nft_payload *priv = nft_expr_priv(expr);
 	int err;
 
-	if (tb[NFTA_PAYLOAD_DREG] == NULL ||
-	    tb[NFTA_PAYLOAD_BASE] == NULL ||
-	    tb[NFTA_PAYLOAD_OFFSET] == NULL ||
-	    tb[NFTA_PAYLOAD_LEN] == NULL)
-		return -EINVAL;
-
-	priv->base = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_BASE]));
-	switch (priv->base) {
-	case NFT_PAYLOAD_LL_HEADER:
-	case NFT_PAYLOAD_NETWORK_HEADER:
-	case NFT_PAYLOAD_TRANSPORT_HEADER:
-		break;
-	default:
-		return -EOPNOTSUPP;
-	}
-
+	priv->base   = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_BASE]));
 	priv->offset = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_OFFSET]));
 	priv->len    = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_LEN]));
-	if (priv->len == 0 ||
-	    priv->len > FIELD_SIZEOF(struct nft_data, data))
-		return -EINVAL;
 
 	priv->dreg = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_DREG]));
 	err = nft_validate_output_register(priv->dreg);
@@ -124,9 +99,49 @@ static const struct nft_expr_ops nft_payload_ops = {
 	.dump		= nft_payload_dump,
 };
 
+const struct nft_expr_ops nft_payload_fast_ops = {
+	.type		= &nft_payload_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_payload)),
+	.eval		= nft_payload_eval,
+	.init		= nft_payload_init,
+	.dump		= nft_payload_dump,
+};
+
+static const struct nft_expr_ops *nft_payload_select_ops(const struct nlattr * const tb[])
+{
+	enum nft_payload_bases base;
+	unsigned int offset, len;
+
+	if (tb[NFTA_PAYLOAD_DREG] == NULL ||
+	    tb[NFTA_PAYLOAD_BASE] == NULL ||
+	    tb[NFTA_PAYLOAD_OFFSET] == NULL ||
+	    tb[NFTA_PAYLOAD_LEN] == NULL)
+		return ERR_PTR(-EINVAL);
+
+	base = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_BASE]));
+	switch (base) {
+	case NFT_PAYLOAD_LL_HEADER:
+	case NFT_PAYLOAD_NETWORK_HEADER:
+	case NFT_PAYLOAD_TRANSPORT_HEADER:
+		break;
+	default:
+		return ERR_PTR(-EOPNOTSUPP);
+	}
+
+	offset = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_OFFSET]));
+	len = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_LEN]));
+	if (len == 0 || len > FIELD_SIZEOF(struct nft_data, data))
+		return ERR_PTR(-EINVAL);
+
+	if (len <= 4 && IS_ALIGNED(offset, len) && base != NFT_PAYLOAD_LL_HEADER)
+		return &nft_payload_fast_ops;
+	else
+		return &nft_payload_ops;
+}
+
 static struct nft_expr_type nft_payload_type __read_mostly = {
 	.name		= "payload",
-	.ops		= &nft_payload_ops,
+	.select_ops	= nft_payload_select_ops,
 	.policy		= nft_payload_policy,
 	.maxattr	= NFTA_PAYLOAD_MAX,
 	.owner		= THIS_MODULE,
-- 
1.7.10.4
