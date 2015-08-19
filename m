From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/15] netfilter: nft_limit: factor out shared code with per-byte limiting
Date: Wed, 19 Aug 2015 21:18:23 +0200
Message-ID: <1440011911-4359-8-git-send-email-pablo@netfilter.org>
References: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch prepares the introduction of per-byte limiting.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_limit.c |   86 ++++++++++++++++++++++++++++-----------------
 1 file changed, 53 insertions(+), 33 deletions(-)

diff --git a/net/netfilter/nft_limit.c b/net/netfilter/nft_limit.c
index c79703e..c4d1b1b 100644
--- a/net/netfilter/nft_limit.c
+++ b/net/netfilter/nft_limit.c
@@ -27,65 +27,54 @@ struct nft_limit {
 	u64		nsecs;
 };
 
-static void nft_limit_pkts_eval(const struct nft_expr *expr,
-				struct nft_regs *regs,
-				const struct nft_pktinfo *pkt)
+static inline bool nft_limit_eval(struct nft_limit *limit, u64 cost)
 {
-	struct nft_limit *priv = nft_expr_priv(expr);
-	u64 now, tokens, cost = div_u64(priv->nsecs, priv->rate);
+	u64 now, tokens;
 	s64 delta;
 
 	spin_lock_bh(&limit_lock);
 	now = ktime_get_ns();
-	tokens = priv->tokens + now - priv->last;
-	if (tokens > priv->tokens_max)
-		tokens = priv->tokens_max;
+	tokens = limit->tokens + now - limit->last;
+	if (tokens > limit->tokens_max)
+		tokens = limit->tokens_max;
 
-	priv->last = now;
+	limit->last = now;
 	delta = tokens - cost;
 	if (delta >= 0) {
-		priv->tokens = delta;
+		limit->tokens = delta;
 		spin_unlock_bh(&limit_lock);
-		return;
+		return false;
 	}
-	priv->tokens = tokens;
+	limit->tokens = tokens;
 	spin_unlock_bh(&limit_lock);
-
-	regs->verdict.code = NFT_BREAK;
+	return true;
 }
 
-static const struct nla_policy nft_limit_policy[NFTA_LIMIT_MAX + 1] = {
-	[NFTA_LIMIT_RATE]	= { .type = NLA_U64 },
-	[NFTA_LIMIT_UNIT]	= { .type = NLA_U64 },
-};
-
-static int nft_limit_init(const struct nft_ctx *ctx,
-			  const struct nft_expr *expr,
+static int nft_limit_init(struct nft_limit *limit,
 			  const struct nlattr * const tb[])
 {
-	struct nft_limit *priv = nft_expr_priv(expr);
 	u64 unit;
 
 	if (tb[NFTA_LIMIT_RATE] == NULL ||
 	    tb[NFTA_LIMIT_UNIT] == NULL)
 		return -EINVAL;
 
-	priv->rate = be64_to_cpu(nla_get_be64(tb[NFTA_LIMIT_RATE]));
+	limit->rate = be64_to_cpu(nla_get_be64(tb[NFTA_LIMIT_RATE]));
 	unit = be64_to_cpu(nla_get_be64(tb[NFTA_LIMIT_UNIT]));
-	priv->nsecs = unit * NSEC_PER_SEC;
-	if (priv->rate == 0 || priv->nsecs < unit)
+	limit->nsecs = unit * NSEC_PER_SEC;
+	if (limit->rate == 0 || limit->nsecs < unit)
 		return -EOVERFLOW;
-	priv->tokens = priv->tokens_max = priv->nsecs;
-	priv->last = ktime_get_ns();
+	limit->tokens = limit->tokens_max = limit->nsecs;
+	limit->last = ktime_get_ns();
+
 	return 0;
 }
 
-static int nft_limit_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_limit_dump(struct sk_buff *skb, const struct nft_limit *limit)
 {
-	const struct nft_limit *priv = nft_expr_priv(expr);
-	u64 secs = div_u64(priv->nsecs, NSEC_PER_SEC);
+	u64 secs = div_u64(limit->nsecs, NSEC_PER_SEC);
 
-	if (nla_put_be64(skb, NFTA_LIMIT_RATE, cpu_to_be64(priv->rate)) ||
+	if (nla_put_be64(skb, NFTA_LIMIT_RATE, cpu_to_be64(limit->rate)) ||
 	    nla_put_be64(skb, NFTA_LIMIT_UNIT, cpu_to_be64(secs)))
 		goto nla_put_failure;
 	return 0;
@@ -94,13 +83,44 @@ nla_put_failure:
 	return -1;
 }
 
+static void nft_limit_pkts_eval(const struct nft_expr *expr,
+				struct nft_regs *regs,
+				const struct nft_pktinfo *pkt)
+{
+	struct nft_limit *priv = nft_expr_priv(expr);
+
+	if (nft_limit_eval(priv, div_u64(priv->nsecs, priv->rate)))
+		regs->verdict.code = NFT_BREAK;
+}
+
+static const struct nla_policy nft_limit_policy[NFTA_LIMIT_MAX + 1] = {
+	[NFTA_LIMIT_RATE]	= { .type = NLA_U64 },
+	[NFTA_LIMIT_UNIT]	= { .type = NLA_U64 },
+};
+
+static int nft_limit_pkts_init(const struct nft_ctx *ctx,
+			       const struct nft_expr *expr,
+			       const struct nlattr * const tb[])
+{
+	struct nft_limit *priv = nft_expr_priv(expr);
+
+	return nft_limit_init(priv, tb);
+}
+
+static int nft_limit_pkts_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	const struct nft_limit *priv = nft_expr_priv(expr);
+
+	return nft_limit_dump(skb, priv);
+}
+
 static struct nft_expr_type nft_limit_type;
 static const struct nft_expr_ops nft_limit_pkts_ops = {
 	.type		= &nft_limit_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_limit)),
 	.eval		= nft_limit_pkts_eval,
-	.init		= nft_limit_init,
-	.dump		= nft_limit_dump,
+	.init		= nft_limit_pkts_init,
+	.dump		= nft_limit_pkts_dump,
 };
 
 static struct nft_expr_type nft_limit_type __read_mostly = {
-- 
1.7.10.4

