From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/15] netfilter: nft_counter: convert it to use per-cpu counters
Date: Wed, 19 Aug 2015 21:18:17 +0200
Message-ID: <1440011911-4359-2-git-send-email-pablo@netfilter.org>
References: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44876 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751634AbbHSTMc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 15:12:32 -0400
In-Reply-To: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts the existing seqlock to per-cpu counters.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Suggested-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_counter.c |   97 ++++++++++++++++++++++++++++++-------------
 1 file changed, 69 insertions(+), 28 deletions(-)

diff --git a/net/netfilter/nft_counter.c b/net/netfilter/nft_counter.c
index 1759123..1067fb4 100644
--- a/net/netfilter/nft_counter.c
+++ b/net/netfilter/nft_counter.c
@@ -18,39 +18,59 @@
 #include <net/netfilter/nf_tables.h>
 
 struct nft_counter {
-	seqlock_t	lock;
 	u64		bytes;
 	u64		packets;
 };
 
+struct nft_counter_percpu {
+	struct nft_counter	counter;
+	struct u64_stats_sync	syncp;
+};
+
+struct nft_counter_percpu_priv {
+	struct nft_counter_percpu __percpu *counter;
+};
+
 static void nft_counter_eval(const struct nft_expr *expr,
 			     struct nft_regs *regs,
 			     const struct nft_pktinfo *pkt)
 {
-	struct nft_counter *priv = nft_expr_priv(expr);
-
-	write_seqlock_bh(&priv->lock);
-	priv->bytes += pkt->skb->len;
-	priv->packets++;
-	write_sequnlock_bh(&priv->lock);
+	struct nft_counter_percpu_priv *priv = nft_expr_priv(expr);
+	struct nft_counter_percpu *this_cpu;
+
+	local_bh_disable();
+	this_cpu = this_cpu_ptr(priv->counter);
+	u64_stats_update_begin(&this_cpu->syncp);
+	this_cpu->counter.bytes += pkt->skb->len;
+	this_cpu->counter.packets++;
+	u64_stats_update_end(&this_cpu->syncp);
+	local_bh_enable();
 }
 
 static int nft_counter_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
-	struct nft_counter *priv = nft_expr_priv(expr);
+	struct nft_counter_percpu_priv *priv = nft_expr_priv(expr);
+	struct nft_counter_percpu *cpu_stats;
+	struct nft_counter total;
+	u64 bytes, packets;
 	unsigned int seq;
-	u64 bytes;
-	u64 packets;
-
-	do {
-		seq = read_seqbegin(&priv->lock);
-		bytes	= priv->bytes;
-		packets	= priv->packets;
-	} while (read_seqretry(&priv->lock, seq));
-
-	if (nla_put_be64(skb, NFTA_COUNTER_BYTES, cpu_to_be64(bytes)))
-		goto nla_put_failure;
-	if (nla_put_be64(skb, NFTA_COUNTER_PACKETS, cpu_to_be64(packets)))
+	int cpu;
+
+	memset(&total, 0, sizeof(total));
+	for_each_possible_cpu(cpu) {
+		cpu_stats = per_cpu_ptr(priv->counter, cpu);
+		do {
+			seq	= u64_stats_fetch_begin_irq(&cpu_stats->syncp);
+			bytes	= cpu_stats->counter.bytes;
+			packets	= cpu_stats->counter.packets;
+		} while (u64_stats_fetch_retry_irq(&cpu_stats->syncp, seq));
+
+		total.packets += packets;
+		total.bytes += bytes;
+	}
+
+	if (nla_put_be64(skb, NFTA_COUNTER_BYTES, cpu_to_be64(total.bytes)) ||
+	    nla_put_be64(skb, NFTA_COUNTER_PACKETS, cpu_to_be64(total.packets)))
 		goto nla_put_failure;
 	return 0;
 
@@ -67,23 +87,44 @@ static int nft_counter_init(const struct nft_ctx *ctx,
 			    const struct nft_expr *expr,
 			    const struct nlattr * const tb[])
 {
-	struct nft_counter *priv = nft_expr_priv(expr);
+	struct nft_counter_percpu_priv *priv = nft_expr_priv(expr);
+	struct nft_counter_percpu __percpu *cpu_stats;
+	struct nft_counter_percpu *this_cpu;
+
+	cpu_stats = netdev_alloc_pcpu_stats(struct nft_counter_percpu);
+	if (cpu_stats == NULL)
+		return ENOMEM;
+
+	preempt_disable();
+	this_cpu = this_cpu_ptr(cpu_stats);
+	if (tb[NFTA_COUNTER_PACKETS]) {
+	        this_cpu->counter.packets =
+			be64_to_cpu(nla_get_be64(tb[NFTA_COUNTER_PACKETS]));
+	}
+	if (tb[NFTA_COUNTER_BYTES]) {
+		this_cpu->counter.bytes =
+			be64_to_cpu(nla_get_be64(tb[NFTA_COUNTER_BYTES]));
+	}
+	preempt_enable();
+	priv->counter = cpu_stats;
+	return 0;
+}
 
-	if (tb[NFTA_COUNTER_PACKETS])
-	        priv->packets = be64_to_cpu(nla_get_be64(tb[NFTA_COUNTER_PACKETS]));
-	if (tb[NFTA_COUNTER_BYTES])
-		priv->bytes = be64_to_cpu(nla_get_be64(tb[NFTA_COUNTER_BYTES]));
+static void nft_counter_destroy(const struct nft_ctx *ctx,
+				const struct nft_expr *expr)
+{
+	struct nft_counter_percpu_priv *priv = nft_expr_priv(expr);
 
-	seqlock_init(&priv->lock);
-	return 0;
+	free_percpu(priv->counter);
 }
 
 static struct nft_expr_type nft_counter_type;
 static const struct nft_expr_ops nft_counter_ops = {
 	.type		= &nft_counter_type,
-	.size		= NFT_EXPR_SIZE(sizeof(struct nft_counter)),
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_counter_percpu_priv)),
 	.eval		= nft_counter_eval,
 	.init		= nft_counter_init,
+	.destroy	= nft_counter_destroy,
 	.dump		= nft_counter_dump,
 };
 
-- 
1.7.10.4
