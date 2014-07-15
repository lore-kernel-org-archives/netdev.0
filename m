From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/4] netfilter: nf_tables: 64bit stats need some extra synchronization
Date: Tue, 15 Jul 2014 16:05:22 +0200
Message-ID: <1405433122-7440-5-git-send-email-pablo@netfilter.org>
References: <1405433122-7440-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1405433122-7440-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

Use generic u64_stats_sync infrastructure to get proper 64bit stats,
even on 32bit arches, at no extra cost for 64bit arches.

Without this fix, 32bit arches can have some wrong counters at the time
the carry is propagated into upper word.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    6 ++++--
 net/netfilter/nf_tables_api.c     |   15 +++++++++++----
 net/netfilter/nf_tables_core.c    |   10 ++++++----
 3 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 713b0b8..c4d8619 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -6,6 +6,7 @@
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/nf_tables.h>
+#include <linux/u64_stats_sync.h>
 #include <net/netlink.h>
 
 #define NFT_JUMP_STACK_SIZE	16
@@ -528,8 +529,9 @@ enum nft_chain_type {
 };
 
 struct nft_stats {
-	u64 bytes;
-	u64 pkts;
+	u64			bytes;
+	u64			pkts;
+	struct u64_stats_sync	syncp;
 };
 
 #define NFT_HOOK_OPS_MAX		2
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index ac03d74..8746ff9 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -644,13 +644,20 @@ static int nft_dump_stats(struct sk_buff *skb, struct nft_stats __percpu *stats)
 {
 	struct nft_stats *cpu_stats, total;
 	struct nlattr *nest;
+	unsigned int seq;
+	u64 pkts, bytes;
 	int cpu;
 
 	memset(&total, 0, sizeof(total));
 	for_each_possible_cpu(cpu) {
 		cpu_stats = per_cpu_ptr(stats, cpu);
-		total.pkts += cpu_stats->pkts;
-		total.bytes += cpu_stats->bytes;
+		do {
+			seq = u64_stats_fetch_begin_irq(&cpu_stats->syncp);
+			pkts = cpu_stats->pkts;
+			bytes = cpu_stats->bytes;
+		} while (u64_stats_fetch_retry_irq(&cpu_stats->syncp, seq));
+		total.pkts += pkts;
+		total.bytes += bytes;
 	}
 	nest = nla_nest_start(skb, NFTA_CHAIN_COUNTERS);
 	if (nest == NULL)
@@ -875,7 +882,7 @@ static struct nft_stats __percpu *nft_stats_alloc(const struct nlattr *attr)
 	if (!tb[NFTA_COUNTER_BYTES] || !tb[NFTA_COUNTER_PACKETS])
 		return ERR_PTR(-EINVAL);
 
-	newstats = alloc_percpu(struct nft_stats);
+	newstats = netdev_alloc_pcpu_stats(struct nft_stats);
 	if (newstats == NULL)
 		return ERR_PTR(-ENOMEM);
 
@@ -1091,7 +1098,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 			}
 			basechain->stats = stats;
 		} else {
-			stats = alloc_percpu(struct nft_stats);
+			stats = netdev_alloc_pcpu_stats(struct nft_stats);
 			if (IS_ERR(stats)) {
 				module_put(type->owner);
 				kfree(basechain);
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 345acfb..3b90eb2 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -109,7 +109,7 @@ nft_do_chain(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
 	struct nft_data data[NFT_REG_MAX + 1];
 	unsigned int stackptr = 0;
 	struct nft_jumpstack jumpstack[NFT_JUMP_STACK_SIZE];
-	struct nft_stats __percpu *stats;
+	struct nft_stats *stats;
 	int rulenum;
 	/*
 	 * Cache cursor to avoid problems in case that the cursor is updated
@@ -205,9 +205,11 @@ next_rule:
 		nft_trace_packet(pkt, basechain, -1, NFT_TRACE_POLICY);
 
 	rcu_read_lock_bh();
-	stats = rcu_dereference(nft_base_chain(basechain)->stats);
-	__this_cpu_inc(stats->pkts);
-	__this_cpu_add(stats->bytes, pkt->skb->len);
+	stats = this_cpu_ptr(rcu_dereference(nft_base_chain(basechain)->stats));
+	u64_stats_update_begin(&stats->syncp);
+	stats->pkts++;
+	stats->bytes += pkt->skb->len;
+	u64_stats_update_end(&stats->syncp);
 	rcu_read_unlock_bh();
 
 	return nft_base_chain(basechain)->policy;
-- 
1.7.10.4

