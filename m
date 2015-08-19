From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/15] netfilter: nft_limit: add per-byte limiting
Date: Wed, 19 Aug 2015 21:18:26 +0200
Message-ID: <1440011911-4359-11-git-send-email-pablo@netfilter.org>
References: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44936 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751898AbbHSTMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 15:12:52 -0400
In-Reply-To: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new NFTA_LIMIT_TYPE netlink attribute to indicate the type of
limiting.

Contrary to per-packet limiting, the cost is calculated from the packet path
since this depends on the packet length.

The burst attribute indicates the number of bytes in which the rate can be
exceeded.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |    7 ++++
 net/netfilter/nft_limit.c                |   63 ++++++++++++++++++++++++++++--
 2 files changed, 66 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index cafd789..d8c8a7c 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -756,18 +756,25 @@ enum nft_ct_attributes {
 };
 #define NFTA_CT_MAX		(__NFTA_CT_MAX - 1)
 
+enum nft_limit_type {
+	NFT_LIMIT_PKTS,
+	NFT_LIMIT_PKT_BYTES
+};
+
 /**
  * enum nft_limit_attributes - nf_tables limit expression netlink attributes
  *
  * @NFTA_LIMIT_RATE: refill rate (NLA_U64)
  * @NFTA_LIMIT_UNIT: refill unit (NLA_U64)
  * @NFTA_LIMIT_BURST: burst (NLA_U32)
+ * @NFTA_LIMIT_TYPE: type of limit (NLA_U32: enum nft_limit_type)
  */
 enum nft_limit_attributes {
 	NFTA_LIMIT_UNSPEC,
 	NFTA_LIMIT_RATE,
 	NFTA_LIMIT_UNIT,
 	NFTA_LIMIT_BURST,
+	NFTA_LIMIT_TYPE,
 	__NFTA_LIMIT_MAX
 };
 #define NFTA_LIMIT_MAX		(__NFTA_LIMIT_MAX - 1)
diff --git a/net/netfilter/nft_limit.c b/net/netfilter/nft_limit.c
index b418698..5d67938 100644
--- a/net/netfilter/nft_limit.c
+++ b/net/netfilter/nft_limit.c
@@ -83,14 +83,16 @@ static int nft_limit_init(struct nft_limit *limit,
 	return 0;
 }
 
-static int nft_limit_dump(struct sk_buff *skb, const struct nft_limit *limit)
+static int nft_limit_dump(struct sk_buff *skb, const struct nft_limit *limit,
+			  enum nft_limit_type type)
 {
 	u64 secs = div_u64(limit->nsecs, NSEC_PER_SEC);
 	u64 rate = limit->rate - limit->burst;
 
 	if (nla_put_be64(skb, NFTA_LIMIT_RATE, cpu_to_be64(rate)) ||
 	    nla_put_be64(skb, NFTA_LIMIT_UNIT, cpu_to_be64(secs)) ||
-	    nla_put_be32(skb, NFTA_LIMIT_BURST, htonl(limit->burst)))
+	    nla_put_be32(skb, NFTA_LIMIT_BURST, htonl(limit->burst)) ||
+	    nla_put_be32(skb, NFTA_LIMIT_TYPE, htonl(type)))
 		goto nla_put_failure;
 	return 0;
 
@@ -117,6 +119,7 @@ static const struct nla_policy nft_limit_policy[NFTA_LIMIT_MAX + 1] = {
 	[NFTA_LIMIT_RATE]	= { .type = NLA_U64 },
 	[NFTA_LIMIT_UNIT]	= { .type = NLA_U64 },
 	[NFTA_LIMIT_BURST]	= { .type = NLA_U32 },
+	[NFTA_LIMIT_TYPE]	= { .type = NLA_U32 },
 };
 
 static int nft_limit_pkts_init(const struct nft_ctx *ctx,
@@ -138,7 +141,7 @@ static int nft_limit_pkts_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_limit_pkts *priv = nft_expr_priv(expr);
 
-	return nft_limit_dump(skb, &priv->limit);
+	return nft_limit_dump(skb, &priv->limit, NFT_LIMIT_PKTS);
 }
 
 static struct nft_expr_type nft_limit_type;
@@ -150,9 +153,61 @@ static const struct nft_expr_ops nft_limit_pkts_ops = {
 	.dump		= nft_limit_pkts_dump,
 };
 
+static void nft_limit_pkt_bytes_eval(const struct nft_expr *expr,
+				     struct nft_regs *regs,
+				     const struct nft_pktinfo *pkt)
+{
+	struct nft_limit *priv = nft_expr_priv(expr);
+	u64 cost = div_u64(priv->nsecs * pkt->skb->len, priv->rate);
+
+	if (nft_limit_eval(priv, cost))
+		regs->verdict.code = NFT_BREAK;
+}
+
+static int nft_limit_pkt_bytes_init(const struct nft_ctx *ctx,
+				    const struct nft_expr *expr,
+				    const struct nlattr * const tb[])
+{
+	struct nft_limit *priv = nft_expr_priv(expr);
+
+	return nft_limit_init(priv, tb);
+}
+
+static int nft_limit_pkt_bytes_dump(struct sk_buff *skb,
+				    const struct nft_expr *expr)
+{
+	const struct nft_limit *priv = nft_expr_priv(expr);
+
+	return nft_limit_dump(skb, priv, NFT_LIMIT_PKT_BYTES);
+}
+
+static const struct nft_expr_ops nft_limit_pkt_bytes_ops = {
+	.type		= &nft_limit_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_limit)),
+	.eval		= nft_limit_pkt_bytes_eval,
+	.init		= nft_limit_pkt_bytes_init,
+	.dump		= nft_limit_pkt_bytes_dump,
+};
+
+static const struct nft_expr_ops *
+nft_limit_select_ops(const struct nft_ctx *ctx,
+		     const struct nlattr * const tb[])
+{
+	if (tb[NFTA_LIMIT_TYPE] == NULL)
+		return &nft_limit_pkts_ops;
+
+	switch (ntohl(nla_get_be32(tb[NFTA_LIMIT_TYPE]))) {
+	case NFT_LIMIT_PKTS:
+		return &nft_limit_pkts_ops;
+	case NFT_LIMIT_PKT_BYTES:
+		return &nft_limit_pkt_bytes_ops;
+	}
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
 static struct nft_expr_type nft_limit_type __read_mostly = {
 	.name		= "limit",
-	.ops		= &nft_limit_pkts_ops,
+	.select_ops	= nft_limit_select_ops,
 	.policy		= nft_limit_policy,
 	.maxattr	= NFTA_LIMIT_MAX,
 	.flags		= NFT_EXPR_STATEFUL,
-- 
1.7.10.4
