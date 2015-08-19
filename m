From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/15] netfilter: nft_limit: convert to token-based limiting at nanosecond granularity
Date: Wed, 19 Aug 2015 21:18:22 +0200
Message-ID: <1440011911-4359-7-git-send-email-pablo@netfilter.org>
References: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rework the limit expression to use a token-based limiting approach that refills
the bucket gradually. The tokens are calculated at nanosecond granularity
instead jiffies to improve precision.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_limit.c |   42 ++++++++++++++++++++++++++----------------
 1 file changed, 26 insertions(+), 16 deletions(-)

diff --git a/net/netfilter/nft_limit.c b/net/netfilter/nft_limit.c
index d0788e1..c79703e 100644
--- a/net/netfilter/nft_limit.c
+++ b/net/netfilter/nft_limit.c
@@ -20,10 +20,11 @@
 static DEFINE_SPINLOCK(limit_lock);
 
 struct nft_limit {
+	u64		last;
 	u64		tokens;
+	u64		tokens_max;
 	u64		rate;
-	u64		unit;
-	unsigned long	stamp;
+	u64		nsecs;
 };
 
 static void nft_limit_pkts_eval(const struct nft_expr *expr,
@@ -31,18 +32,23 @@ static void nft_limit_pkts_eval(const struct nft_expr *expr,
 				const struct nft_pktinfo *pkt)
 {
 	struct nft_limit *priv = nft_expr_priv(expr);
+	u64 now, tokens, cost = div_u64(priv->nsecs, priv->rate);
+	s64 delta;
 
 	spin_lock_bh(&limit_lock);
-	if (time_after_eq(jiffies, priv->stamp)) {
-		priv->tokens = priv->rate;
-		priv->stamp = jiffies + priv->unit * HZ;
-	}
-
-	if (priv->tokens >= 1) {
-		priv->tokens--;
+	now = ktime_get_ns();
+	tokens = priv->tokens + now - priv->last;
+	if (tokens > priv->tokens_max)
+		tokens = priv->tokens_max;
+
+	priv->last = now;
+	delta = tokens - cost;
+	if (delta >= 0) {
+		priv->tokens = delta;
 		spin_unlock_bh(&limit_lock);
 		return;
 	}
+	priv->tokens = tokens;
 	spin_unlock_bh(&limit_lock);
 
 	regs->verdict.code = NFT_BREAK;
@@ -58,25 +64,29 @@ static int nft_limit_init(const struct nft_ctx *ctx,
 			  const struct nlattr * const tb[])
 {
 	struct nft_limit *priv = nft_expr_priv(expr);
+	u64 unit;
 
 	if (tb[NFTA_LIMIT_RATE] == NULL ||
 	    tb[NFTA_LIMIT_UNIT] == NULL)
 		return -EINVAL;
 
-	priv->rate   = be64_to_cpu(nla_get_be64(tb[NFTA_LIMIT_RATE]));
-	priv->unit   = be64_to_cpu(nla_get_be64(tb[NFTA_LIMIT_UNIT]));
-	priv->stamp  = jiffies + priv->unit * HZ;
-	priv->tokens = priv->rate;
+	priv->rate = be64_to_cpu(nla_get_be64(tb[NFTA_LIMIT_RATE]));
+	unit = be64_to_cpu(nla_get_be64(tb[NFTA_LIMIT_UNIT]));
+	priv->nsecs = unit * NSEC_PER_SEC;
+	if (priv->rate == 0 || priv->nsecs < unit)
+		return -EOVERFLOW;
+	priv->tokens = priv->tokens_max = priv->nsecs;
+	priv->last = ktime_get_ns();
 	return 0;
 }
 
 static int nft_limit_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_limit *priv = nft_expr_priv(expr);
+	u64 secs = div_u64(priv->nsecs, NSEC_PER_SEC);
 
-	if (nla_put_be64(skb, NFTA_LIMIT_RATE, cpu_to_be64(priv->rate)))
-		goto nla_put_failure;
-	if (nla_put_be64(skb, NFTA_LIMIT_UNIT, cpu_to_be64(priv->unit)))
+	if (nla_put_be64(skb, NFTA_LIMIT_RATE, cpu_to_be64(priv->rate)) ||
+	    nla_put_be64(skb, NFTA_LIMIT_UNIT, cpu_to_be64(secs)))
 		goto nla_put_failure;
 	return 0;
 
-- 
1.7.10.4

