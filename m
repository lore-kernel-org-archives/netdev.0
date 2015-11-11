From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/10] netfilter: nf_tables: add clone interface to expression operations
Date: Wed, 11 Nov 2015 18:33:43 +0100
Message-ID: <1447263223-22662-11-git-send-email-pablo@netfilter.org>
References: <1447263223-22662-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1447263223-22662-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the conversion of the counter expressions to make it percpu, we
need to clone the percpu memory area, otherwise we crash when using
counters from flow tables.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h | 16 +++++++++++--
 net/netfilter/nft_counter.c       | 49 ++++++++++++++++++++++++++++++++-------
 net/netfilter/nft_dynset.c        |  5 ++--
 3 files changed, 58 insertions(+), 12 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index c9149cc..4bd7508 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -618,6 +618,8 @@ struct nft_expr_ops {
 	void				(*eval)(const struct nft_expr *expr,
 						struct nft_regs *regs,
 						const struct nft_pktinfo *pkt);
+	int				(*clone)(struct nft_expr *dst,
+						 const struct nft_expr *src);
 	unsigned int			size;
 
 	int				(*init)(const struct nft_ctx *ctx,
@@ -660,10 +662,20 @@ void nft_expr_destroy(const struct nft_ctx *ctx, struct nft_expr *expr);
 int nft_expr_dump(struct sk_buff *skb, unsigned int attr,
 		  const struct nft_expr *expr);
 
-static inline void nft_expr_clone(struct nft_expr *dst, struct nft_expr *src)
+static inline int nft_expr_clone(struct nft_expr *dst, struct nft_expr *src)
 {
+	int err;
+
 	__module_get(src->ops->type->owner);
-	memcpy(dst, src, src->ops->size);
+	if (src->ops->clone) {
+		dst->ops = src->ops;
+		err = src->ops->clone(dst, src);
+		if (err < 0)
+			return err;
+	} else {
+		memcpy(dst, src, src->ops->size);
+	}
+	return 0;
 }
 
 /**
diff --git a/net/netfilter/nft_counter.c b/net/netfilter/nft_counter.c
index 1067fb4..c7808fc 100644
--- a/net/netfilter/nft_counter.c
+++ b/net/netfilter/nft_counter.c
@@ -47,27 +47,34 @@ static void nft_counter_eval(const struct nft_expr *expr,
 	local_bh_enable();
 }
 
-static int nft_counter_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static void nft_counter_fetch(const struct nft_counter_percpu __percpu *counter,
+			      struct nft_counter *total)
 {
-	struct nft_counter_percpu_priv *priv = nft_expr_priv(expr);
-	struct nft_counter_percpu *cpu_stats;
-	struct nft_counter total;
+	const struct nft_counter_percpu *cpu_stats;
 	u64 bytes, packets;
 	unsigned int seq;
 	int cpu;
 
-	memset(&total, 0, sizeof(total));
+	memset(total, 0, sizeof(*total));
 	for_each_possible_cpu(cpu) {
-		cpu_stats = per_cpu_ptr(priv->counter, cpu);
+		cpu_stats = per_cpu_ptr(counter, cpu);
 		do {
 			seq	= u64_stats_fetch_begin_irq(&cpu_stats->syncp);
 			bytes	= cpu_stats->counter.bytes;
 			packets	= cpu_stats->counter.packets;
 		} while (u64_stats_fetch_retry_irq(&cpu_stats->syncp, seq));
 
-		total.packets += packets;
-		total.bytes += bytes;
+		total->packets += packets;
+		total->bytes += bytes;
 	}
+}
+
+static int nft_counter_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	struct nft_counter_percpu_priv *priv = nft_expr_priv(expr);
+	struct nft_counter total;
+
+	nft_counter_fetch(priv->counter, &total);
 
 	if (nla_put_be64(skb, NFTA_COUNTER_BYTES, cpu_to_be64(total.bytes)) ||
 	    nla_put_be64(skb, NFTA_COUNTER_PACKETS, cpu_to_be64(total.packets)))
@@ -118,6 +125,31 @@ static void nft_counter_destroy(const struct nft_ctx *ctx,
 	free_percpu(priv->counter);
 }
 
+static int nft_counter_clone(struct nft_expr *dst, const struct nft_expr *src)
+{
+	struct nft_counter_percpu_priv *priv = nft_expr_priv(src);
+	struct nft_counter_percpu_priv *priv_clone = nft_expr_priv(dst);
+	struct nft_counter_percpu __percpu *cpu_stats;
+	struct nft_counter_percpu *this_cpu;
+	struct nft_counter total;
+
+	nft_counter_fetch(priv->counter, &total);
+
+	cpu_stats = __netdev_alloc_pcpu_stats(struct nft_counter_percpu,
+					      GFP_ATOMIC);
+	if (cpu_stats == NULL)
+		return ENOMEM;
+
+	preempt_disable();
+	this_cpu = this_cpu_ptr(cpu_stats);
+	this_cpu->counter.packets = total.packets;
+	this_cpu->counter.bytes = total.bytes;
+	preempt_enable();
+
+	priv_clone->counter = cpu_stats;
+	return 0;
+}
+
 static struct nft_expr_type nft_counter_type;
 static const struct nft_expr_ops nft_counter_ops = {
 	.type		= &nft_counter_type,
@@ -126,6 +158,7 @@ static const struct nft_expr_ops nft_counter_ops = {
 	.init		= nft_counter_init,
 	.destroy	= nft_counter_destroy,
 	.dump		= nft_counter_dump,
+	.clone		= nft_counter_clone,
 };
 
 static struct nft_expr_type nft_counter_type __read_mostly = {
diff --git a/net/netfilter/nft_dynset.c b/net/netfilter/nft_dynset.c
index 513a8ef..9dec3bd 100644
--- a/net/netfilter/nft_dynset.c
+++ b/net/netfilter/nft_dynset.c
@@ -50,8 +50,9 @@ static void *nft_dynset_new(struct nft_set *set, const struct nft_expr *expr,
 	}
 
 	ext = nft_set_elem_ext(set, elem);
-	if (priv->expr != NULL)
-		nft_expr_clone(nft_set_ext_expr(ext), priv->expr);
+	if (priv->expr != NULL &&
+	    nft_expr_clone(nft_set_ext_expr(ext), priv->expr) < 0)
+		return NULL;
 
 	return elem;
 }
-- 
2.1.4

