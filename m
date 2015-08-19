From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/15] netfilter: nft_limit: constant token cost per packet
Date: Wed, 19 Aug 2015 21:18:25 +0200
Message-ID: <1440011911-4359-10-git-send-email-pablo@netfilter.org>
References: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cost per packet can be calculated from the control plane path since this
doesn't ever change.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_limit.c |   25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nft_limit.c b/net/netfilter/nft_limit.c
index d8c5ff1..b418698 100644
--- a/net/netfilter/nft_limit.c
+++ b/net/netfilter/nft_limit.c
@@ -98,13 +98,18 @@ nla_put_failure:
 	return -1;
 }
 
+struct nft_limit_pkts {
+	struct nft_limit	limit;
+	u64			cost;
+};
+
 static void nft_limit_pkts_eval(const struct nft_expr *expr,
 				struct nft_regs *regs,
 				const struct nft_pktinfo *pkt)
 {
-	struct nft_limit *priv = nft_expr_priv(expr);
+	struct nft_limit_pkts *priv = nft_expr_priv(expr);
 
-	if (nft_limit_eval(priv, div_u64(priv->nsecs, priv->rate)))
+	if (nft_limit_eval(&priv->limit, priv->cost))
 		regs->verdict.code = NFT_BREAK;
 }
 
@@ -118,22 +123,28 @@ static int nft_limit_pkts_init(const struct nft_ctx *ctx,
 			       const struct nft_expr *expr,
 			       const struct nlattr * const tb[])
 {
-	struct nft_limit *priv = nft_expr_priv(expr);
+	struct nft_limit_pkts *priv = nft_expr_priv(expr);
+	int err;
 
-	return nft_limit_init(priv, tb);
+	err = nft_limit_init(&priv->limit, tb);
+	if (err < 0)
+		return err;
+
+	priv->cost = div_u64(priv->limit.nsecs, priv->limit.rate);
+	return 0;
 }
 
 static int nft_limit_pkts_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
-	const struct nft_limit *priv = nft_expr_priv(expr);
+	const struct nft_limit_pkts *priv = nft_expr_priv(expr);
 
-	return nft_limit_dump(skb, priv);
+	return nft_limit_dump(skb, &priv->limit);
 }
 
 static struct nft_expr_type nft_limit_type;
 static const struct nft_expr_ops nft_limit_pkts_ops = {
 	.type		= &nft_limit_type,
-	.size		= NFT_EXPR_SIZE(sizeof(struct nft_limit)),
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_limit_pkts)),
 	.eval		= nft_limit_pkts_eval,
 	.init		= nft_limit_pkts_init,
 	.dump		= nft_limit_pkts_dump,
-- 
1.7.10.4

