From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/6] netfilter: nf_tables: fix goto action
Date: Tue, 20 May 2014 11:45:22 +0200
Message-ID: <1400579126-6451-3-git-send-email-pablo@netfilter.org>
References: <1400579126-6451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40886 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751788AbaETJpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 05:45:42 -0400
In-Reply-To: <1400579126-6451-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a crash when trying to access the counters and the
default chain policy from the non-base chain that we have reached
via the goto chain. Fix this by falling back on the original base
chain after returning from the custom chain.

While fixing this, kill the inline function to account chain statistics
to improve source code readability.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_core.c |   28 ++++++++++------------------
 1 file changed, 10 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 4368c58..7d83a49 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -66,20 +66,6 @@ struct nft_jumpstack {
 	int			rulenum;
 };
 
-static inline void
-nft_chain_stats(const struct nft_chain *this, const struct nft_pktinfo *pkt,
-		struct nft_jumpstack *jumpstack, unsigned int stackptr)
-{
-	struct nft_stats __percpu *stats;
-	const struct nft_chain *chain = stackptr ? jumpstack[0].chain : this;
-
-	rcu_read_lock_bh();
-	stats = rcu_dereference(nft_base_chain(chain)->stats);
-	__this_cpu_inc(stats->pkts);
-	__this_cpu_add(stats->bytes, pkt->skb->len);
-	rcu_read_unlock_bh();
-}
-
 enum nft_trace {
 	NFT_TRACE_RULE,
 	NFT_TRACE_RETURN,
@@ -117,12 +103,13 @@ static void nft_trace_packet(const struct nft_pktinfo *pkt,
 unsigned int
 nft_do_chain(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
 {
-	const struct nft_chain *chain = ops->priv;
+	const struct nft_chain *chain = ops->priv, *basechain = chain;
 	const struct nft_rule *rule;
 	const struct nft_expr *expr, *last;
 	struct nft_data data[NFT_REG_MAX + 1];
 	unsigned int stackptr = 0;
 	struct nft_jumpstack jumpstack[NFT_JUMP_STACK_SIZE];
+	struct nft_stats __percpu *stats;
 	int rulenum;
 	/*
 	 * Cache cursor to avoid problems in case that the cursor is updated
@@ -209,12 +196,17 @@ next_rule:
 		rulenum = jumpstack[stackptr].rulenum;
 		goto next_rule;
 	}
-	nft_chain_stats(chain, pkt, jumpstack, stackptr);
 
 	if (unlikely(pkt->skb->nf_trace))
-		nft_trace_packet(pkt, chain, ++rulenum, NFT_TRACE_POLICY);
+		nft_trace_packet(pkt, basechain, ++rulenum, NFT_TRACE_POLICY);
+
+	rcu_read_lock_bh();
+	stats = rcu_dereference(nft_base_chain(basechain)->stats);
+	__this_cpu_inc(stats->pkts);
+	__this_cpu_add(stats->bytes, pkt->skb->len);
+	rcu_read_unlock_bh();
 
-	return nft_base_chain(chain)->policy;
+	return nft_base_chain(basechain)->policy;
 }
 EXPORT_SYMBOL_GPL(nft_do_chain);
 
-- 
1.7.10.4
