From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net-next] netfilter: nft_counter: rework atomic dump and reset
Date: Sun, 11 Dec 2016 11:43:59 +0100
Message-ID: <1481453040-2675-1-git-send-email-pablo@netfilter.org>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
        davem@davemloft.net, arnd@arndb.de
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57346 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751674AbcLKKoI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 11 Dec 2016 05:44:08 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 042EEBA708
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 11:44:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E9B9FDA814
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 11:44:06 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2E3B4DA801
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 11:44:04 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dump and reset doesn't work unless cmpxchg64() is used both from packet
and control plane paths. This approach is going to be slow though.
Instead, use a percpu seqcount to fetch counters consistently, then
subtract bytes and packets in case a reset was requested.

The cpu that running over the reset code is guaranteed to own this stats
exclusively, we have to turn counters into signed 64bit though so stats
update on reset don't get wrong on underflow.

This patch is based on original sketch from Eric Dumazet.

Fixes: 43da04a593d8 ("netfilter: nf_tables: atomic dump and reset for stateful objects")
Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
v2: adjust stats on reset on the current cpu, turn 64bit counters into signed.

@David: Please, take this into net-next to help speed up thing, thanks!

 net/netfilter/nft_counter.c | 127 +++++++++++++++++++-------------------------
 1 file changed, 55 insertions(+), 72 deletions(-)

diff --git a/net/netfilter/nft_counter.c b/net/netfilter/nft_counter.c
index f6a02c5071c2..7f8422213341 100644
--- a/net/netfilter/nft_counter.c
+++ b/net/netfilter/nft_counter.c
@@ -18,31 +18,33 @@
 #include <net/netfilter/nf_tables.h>
 
 struct nft_counter {
-	u64		bytes;
-	u64		packets;
-};
-
-struct nft_counter_percpu {
-	struct nft_counter	counter;
-	struct u64_stats_sync	syncp;
+	s64		bytes;
+	s64		packets;
 };
 
 struct nft_counter_percpu_priv {
-	struct nft_counter_percpu __percpu *counter;
+	struct nft_counter __percpu *counter;
 };
 
+static DEFINE_PER_CPU(seqcount_t, nft_counter_seq);
+
 static inline void nft_counter_do_eval(struct nft_counter_percpu_priv *priv,
 				       struct nft_regs *regs,
 				       const struct nft_pktinfo *pkt)
 {
-	struct nft_counter_percpu *this_cpu;
+	struct nft_counter *this_cpu;
+	seqcount_t *myseq;
 
 	local_bh_disable();
 	this_cpu = this_cpu_ptr(priv->counter);
-	u64_stats_update_begin(&this_cpu->syncp);
-	this_cpu->counter.bytes += pkt->skb->len;
-	this_cpu->counter.packets++;
-	u64_stats_update_end(&this_cpu->syncp);
+	myseq = this_cpu_ptr(&nft_counter_seq);
+
+	write_seqcount_begin(myseq);
+
+	this_cpu->bytes += pkt->skb->len;
+	this_cpu->packets++;
+
+	write_seqcount_end(myseq);
 	local_bh_enable();
 }
 
@@ -58,21 +60,21 @@ static inline void nft_counter_obj_eval(struct nft_object *obj,
 static int nft_counter_do_init(const struct nlattr * const tb[],
 			       struct nft_counter_percpu_priv *priv)
 {
-	struct nft_counter_percpu __percpu *cpu_stats;
-	struct nft_counter_percpu *this_cpu;
+	struct nft_counter __percpu *cpu_stats;
+	struct nft_counter *this_cpu;
 
-	cpu_stats = netdev_alloc_pcpu_stats(struct nft_counter_percpu);
+	cpu_stats = alloc_percpu(struct nft_counter);
 	if (cpu_stats == NULL)
 		return -ENOMEM;
 
 	preempt_disable();
 	this_cpu = this_cpu_ptr(cpu_stats);
 	if (tb[NFTA_COUNTER_PACKETS]) {
-	        this_cpu->counter.packets =
+	        this_cpu->packets =
 			be64_to_cpu(nla_get_be64(tb[NFTA_COUNTER_PACKETS]));
 	}
 	if (tb[NFTA_COUNTER_BYTES]) {
-		this_cpu->counter.bytes =
+		this_cpu->bytes =
 			be64_to_cpu(nla_get_be64(tb[NFTA_COUNTER_BYTES]));
 	}
 	preempt_enable();
@@ -100,80 +102,59 @@ static void nft_counter_obj_destroy(struct nft_object *obj)
 	nft_counter_do_destroy(priv);
 }
 
-static void nft_counter_fetch(struct nft_counter_percpu __percpu *counter,
+static void nft_counter_reset(struct nft_counter_percpu_priv __percpu *priv,
 			      struct nft_counter *total)
 {
-	struct nft_counter_percpu *cpu_stats;
-	u64 bytes, packets;
-	unsigned int seq;
-	int cpu;
+	struct nft_counter *this_cpu;
 
-	memset(total, 0, sizeof(*total));
-	for_each_possible_cpu(cpu) {
-		cpu_stats = per_cpu_ptr(counter, cpu);
-		do {
-			seq	= u64_stats_fetch_begin_irq(&cpu_stats->syncp);
-			bytes	= cpu_stats->counter.bytes;
-			packets	= cpu_stats->counter.packets;
-		} while (u64_stats_fetch_retry_irq(&cpu_stats->syncp, seq));
-
-		total->packets += packets;
-		total->bytes += bytes;
-	}
-}
-
-static u64 __nft_counter_reset(u64 *counter)
-{
-	u64 ret, old;
-
-	do {
-		old = *counter;
-		ret = cmpxchg64(counter, old, 0);
-	} while (ret != old);
-
-	return ret;
+	local_bh_disable();
+	this_cpu = this_cpu_ptr(priv->counter);
+	this_cpu->packets -= total->packets;
+	this_cpu->bytes -= total->bytes;
+	local_bh_enable();
 }
 
-static void nft_counter_reset(struct nft_counter_percpu __percpu *counter,
+static void nft_counter_fetch(struct nft_counter_percpu_priv *priv,
 			      struct nft_counter *total)
 {
-	struct nft_counter_percpu *cpu_stats;
+	struct nft_counter *this_cpu;
+	const seqcount_t *myseq;
 	u64 bytes, packets;
 	unsigned int seq;
 	int cpu;
 
 	memset(total, 0, sizeof(*total));
 	for_each_possible_cpu(cpu) {
-		bytes = packets = 0;
-
-		cpu_stats = per_cpu_ptr(counter, cpu);
+		myseq = per_cpu_ptr(&nft_counter_seq, cpu);
+		this_cpu = per_cpu_ptr(priv->counter, cpu);
 		do {
-			seq	= u64_stats_fetch_begin_irq(&cpu_stats->syncp);
-			packets	+= __nft_counter_reset(&cpu_stats->counter.packets);
-			bytes	+= __nft_counter_reset(&cpu_stats->counter.bytes);
-		} while (u64_stats_fetch_retry_irq(&cpu_stats->syncp, seq));
+			seq	= read_seqcount_begin(myseq);
+			bytes	= this_cpu->bytes;
+			packets	= this_cpu->packets;
+		} while (read_seqcount_retry(myseq, seq));
 
-		total->packets += packets;
-		total->bytes += bytes;
+		total->bytes	+= bytes;
+		total->packets	+= packets;
 	}
 }
 
 static int nft_counter_do_dump(struct sk_buff *skb,
-			       const struct nft_counter_percpu_priv *priv,
+			       struct nft_counter_percpu_priv *priv,
 			       bool reset)
 {
 	struct nft_counter total;
 
-	if (reset)
-		nft_counter_reset(priv->counter, &total);
-	else
-		nft_counter_fetch(priv->counter, &total);
+	nft_counter_fetch(priv, &total);
 
 	if (nla_put_be64(skb, NFTA_COUNTER_BYTES, cpu_to_be64(total.bytes),
 			 NFTA_COUNTER_PAD) ||
 	    nla_put_be64(skb, NFTA_COUNTER_PACKETS, cpu_to_be64(total.packets),
 			 NFTA_COUNTER_PAD))
 		goto nla_put_failure;
+
+	if (reset)
+		nft_counter_reset(priv, &total);
+
 	return 0;
 
 nla_put_failure:
@@ -216,7 +197,7 @@ static void nft_counter_eval(const struct nft_expr *expr,
 
 static int nft_counter_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
-	const struct nft_counter_percpu_priv *priv = nft_expr_priv(expr);
+	struct nft_counter_percpu_priv *priv = nft_expr_priv(expr);
 
 	return nft_counter_do_dump(skb, priv, false);
 }
@@ -242,21 +223,20 @@ static int nft_counter_clone(struct nft_expr *dst, const struct nft_expr *src)
 {
 	struct nft_counter_percpu_priv *priv = nft_expr_priv(src);
 	struct nft_counter_percpu_priv *priv_clone = nft_expr_priv(dst);
-	struct nft_counter_percpu __percpu *cpu_stats;
-	struct nft_counter_percpu *this_cpu;
+	struct nft_counter __percpu *cpu_stats;
+	struct nft_counter *this_cpu;
 	struct nft_counter total;
 
-	nft_counter_fetch(priv->counter, &total);
+	nft_counter_fetch(priv, &total);
 
-	cpu_stats = __netdev_alloc_pcpu_stats(struct nft_counter_percpu,
-					      GFP_ATOMIC);
+	cpu_stats = alloc_percpu_gfp(struct nft_counter, GFP_ATOMIC);
 	if (cpu_stats == NULL)
 		return -ENOMEM;
 
 	preempt_disable();
 	this_cpu = this_cpu_ptr(cpu_stats);
-	this_cpu->counter.packets = total.packets;
-	this_cpu->counter.bytes = total.bytes;
+	this_cpu->packets = total.packets;
+	this_cpu->bytes = total.bytes;
 	preempt_enable();
 
 	priv_clone->counter = cpu_stats;
@@ -285,7 +265,10 @@ static struct nft_expr_type nft_counter_type __read_mostly = {
 
 static int __init nft_counter_module_init(void)
 {
-	int err;
+	int cpu, err;
+
+	for_each_possible_cpu(cpu)
+		seqcount_init(per_cpu_ptr(&nft_counter_seq, cpu));
 
 	err = nft_register_obj(&nft_counter_obj);
 	if (err < 0)
-- 
2.1.4
