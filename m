From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/47] netfilter: nf_tables: keep chain counters away from hot path
Date: Mon,  4 Sep 2017 00:25:44 +0200
Message-ID: <1504477589-12045-3-git-send-email-pablo@netfilter.org>
References: <1504477589-12045-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504477589-12045-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These chain counters are only used by the iptables-compat tool, that
allow users to use the x_tables extensions from the existing nf_tables
framework. This patch makes nf_tables by ~5% for the general usecase,
ie. native nft users, where no chain counters are used at all.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables_core.h |  2 ++
 net/netfilter/nf_tables_api.c          | 11 +++--------
 net/netfilter/nf_tables_core.c         | 26 ++++++++++++++++++--------
 3 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/include/net/netfilter/nf_tables_core.h b/include/net/netfilter/nf_tables_core.h
index 8f690effec37..424684c33771 100644
--- a/include/net/netfilter/nf_tables_core.h
+++ b/include/net/netfilter/nf_tables_core.h
@@ -49,6 +49,8 @@ struct nft_payload_set {
 };
 
 extern const struct nft_expr_ops nft_payload_fast_ops;
+
+extern struct static_key_false nft_counters_enabled;
 extern struct static_key_false nft_trace_enabled;
 
 #endif /* _NET_NF_TABLES_CORE_H */
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 7843efa33c59..7fbf0070aba1 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1240,6 +1240,8 @@ static void nf_tables_chain_destroy(struct nft_chain *chain)
 
 		module_put(basechain->type->owner);
 		free_percpu(basechain->stats);
+		if (basechain->stats)
+			static_branch_dec(&nft_counters_enabled);
 		if (basechain->ops[0].dev != NULL)
 			dev_put(basechain->ops[0].dev);
 		kfree(basechain);
@@ -1504,14 +1506,7 @@ static int nf_tables_newchain(struct net *net, struct sock *nlsk,
 				return PTR_ERR(stats);
 			}
 			basechain->stats = stats;
-		} else {
-			stats = netdev_alloc_pcpu_stats(struct nft_stats);
-			if (stats == NULL) {
-				nft_chain_release_hook(&hook);
-				kfree(basechain);
-				return -ENOMEM;
-			}
-			rcu_assign_pointer(basechain->stats, stats);
+			static_branch_inc(&nft_counters_enabled);
 		}
 
 		hookfn = hook.type->hooks[hook.num];
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 65dbeadcb118..c5bab08b0d73 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -114,6 +114,22 @@ static bool nft_payload_fast_eval(const struct nft_expr *expr,
 	return true;
 }
 
+DEFINE_STATIC_KEY_FALSE(nft_counters_enabled);
+
+static noinline void nft_update_chain_stats(const struct nft_chain *chain,
+					    const struct nft_pktinfo *pkt)
+{
+	struct nft_stats *stats;
+
+	local_bh_disable();
+	stats = this_cpu_ptr(rcu_dereference(nft_base_chain(chain)->stats));
+	u64_stats_update_begin(&stats->syncp);
+	stats->pkts++;
+	stats->bytes += pkt->skb->len;
+	u64_stats_update_end(&stats->syncp);
+	local_bh_enable();
+}
+
 struct nft_jumpstack {
 	const struct nft_chain	*chain;
 	const struct nft_rule	*rule;
@@ -130,7 +146,6 @@ nft_do_chain(struct nft_pktinfo *pkt, void *priv)
 	struct nft_regs regs;
 	unsigned int stackptr = 0;
 	struct nft_jumpstack jumpstack[NFT_JUMP_STACK_SIZE];
-	struct nft_stats *stats;
 	int rulenum;
 	unsigned int gencursor = nft_genmask_cur(net);
 	struct nft_traceinfo info;
@@ -220,13 +235,8 @@ nft_do_chain(struct nft_pktinfo *pkt, void *priv)
 	nft_trace_packet(&info, basechain, NULL, -1,
 			 NFT_TRACETYPE_POLICY);
 
-	rcu_read_lock_bh();
-	stats = this_cpu_ptr(rcu_dereference(nft_base_chain(basechain)->stats));
-	u64_stats_update_begin(&stats->syncp);
-	stats->pkts++;
-	stats->bytes += pkt->skb->len;
-	u64_stats_update_end(&stats->syncp);
-	rcu_read_unlock_bh();
+	if (static_branch_unlikely(&nft_counters_enabled))
+		nft_update_chain_stats(basechain, pkt);
 
 	return nft_base_chain(basechain)->policy;
 }
-- 
2.1.4


