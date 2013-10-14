From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/17] netfilter: nf_tables: add trace support
Date: Mon, 14 Oct 2013 18:38:57 +0200
Message-ID: <1381768738-17739-17-git-send-email-pablo@netfilter.org>
References: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34863 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757310Ab3JNQjh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 12:39:37 -0400
In-Reply-To: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for tracing the packet travel through
the ruleset, in a similar fashion to x_tables.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    2 ++
 net/netfilter/nf_tables_api.c     |    1 +
 net/netfilter/nf_tables_core.c    |   57 +++++++++++++++++++++++++++++++++++++
 3 files changed, 60 insertions(+)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 975ad3c..54c4a5c 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -392,6 +392,7 @@ enum nft_chain_flags {
  *	@list: used internally
  *	@rcu_head: used internally
  *	@net: net namespace that this chain belongs to
+ *	@table: table that this chain belongs to
  *	@handle: chain handle
  *	@flags: bitmask of enum nft_chain_flags
  *	@use: number of jump references to this chain
@@ -403,6 +404,7 @@ struct nft_chain {
 	struct list_head		list;
 	struct rcu_head			rcu_head;
 	struct net			*net;
+	struct nft_table		*table;
 	u64				handle;
 	u8				flags;
 	u16				use;
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 79e1418..dcddc49 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -979,6 +979,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 	INIT_LIST_HEAD(&chain->rules);
 	chain->handle = nf_tables_alloc_handle(table);
 	chain->net = net;
+	chain->table = table;
 	nla_strlcpy(chain->name, name, NFT_CHAIN_MAXNAMELEN);
 
 	if (!(table->flags & NFT_TABLE_F_DORMANT) &&
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index d581ef6..cb9e685 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -19,6 +19,7 @@
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables_core.h>
 #include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_log.h>
 
 static void nft_cmp_fast_eval(const struct nft_expr *expr,
 			      struct nft_data data[NFT_REG_MAX + 1])
@@ -63,6 +64,7 @@ static bool nft_payload_fast_eval(const struct nft_expr *expr,
 struct nft_jumpstack {
 	const struct nft_chain	*chain;
 	const struct nft_rule	*rule;
+	int			rulenum;
 };
 
 static inline void
@@ -79,6 +81,40 @@ nft_chain_stats(const struct nft_chain *this, const struct nft_pktinfo *pkt,
 	rcu_read_unlock_bh();
 }
 
+enum nft_trace {
+	NFT_TRACE_RULE,
+	NFT_TRACE_RETURN,
+	NFT_TRACE_POLICY,
+};
+
+static const char *const comments[] = {
+	[NFT_TRACE_RULE]	= "rule",
+	[NFT_TRACE_RETURN]	= "return",
+	[NFT_TRACE_POLICY]	= "policy",
+};
+
+static struct nf_loginfo trace_loginfo = {
+	.type = NF_LOG_TYPE_LOG,
+	.u = {
+		.log = {
+			.level = 4,
+			.logflags = NF_LOG_MASK,
+	        },
+	},
+};
+
+static inline void nft_trace_packet(const struct nft_pktinfo *pkt,
+				    const struct nft_chain *chain,
+				    int rulenum, enum nft_trace type)
+{
+	struct net *net = dev_net(pkt->in ? pkt->in : pkt->out);
+
+	nf_log_packet(net, pkt->xt.family, pkt->hooknum, pkt->skb, pkt->in,
+		      pkt->out, &trace_loginfo, "TRACE: %s:%s:%s:%u ",
+		      chain->table->name, chain->name, comments[type],
+		      rulenum);
+}
+
 unsigned int
 nft_do_chain_pktinfo(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
 {
@@ -88,6 +124,7 @@ nft_do_chain_pktinfo(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
 	struct nft_data data[NFT_REG_MAX + 1];
 	unsigned int stackptr = 0;
 	struct nft_jumpstack jumpstack[NFT_JUMP_STACK_SIZE];
+	int rulenum = 0;
 	/*
 	 * Cache cursor to avoid problems in case that the cursor is updated
 	 * while traversing the ruleset.
@@ -104,6 +141,8 @@ next_rule:
 		if (unlikely(rule->genmask & (1 << gencursor)))
 			continue;
 
+		rulenum++;
+
 		nft_rule_for_each_expr(expr, last, rule) {
 			if (expr->ops == &nft_cmp_fast_ops)
 				nft_cmp_fast_eval(expr, data);
@@ -129,17 +168,28 @@ next_rule:
 	case NF_ACCEPT:
 	case NF_DROP:
 	case NF_QUEUE:
+		if (unlikely(pkt->skb->nf_trace))
+			nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RULE);
+
 		return data[NFT_REG_VERDICT].verdict;
 	case NFT_JUMP:
+		if (unlikely(pkt->skb->nf_trace))
+			nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RULE);
+
 		BUG_ON(stackptr >= NFT_JUMP_STACK_SIZE);
 		jumpstack[stackptr].chain = chain;
 		jumpstack[stackptr].rule  = rule;
+		jumpstack[stackptr].rulenum = rulenum;
 		stackptr++;
 		/* fall through */
 	case NFT_GOTO:
 		chain = data[NFT_REG_VERDICT].chain;
 		goto do_chain;
 	case NFT_RETURN:
+		if (unlikely(pkt->skb->nf_trace))
+			nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RETURN);
+
+		/* fall through */
 	case NFT_CONTINUE:
 		break;
 	default:
@@ -147,13 +197,20 @@ next_rule:
 	}
 
 	if (stackptr > 0) {
+		if (unlikely(pkt->skb->nf_trace))
+			nft_trace_packet(pkt, chain, ++rulenum, NFT_TRACE_RETURN);
+
 		stackptr--;
 		chain = jumpstack[stackptr].chain;
 		rule  = jumpstack[stackptr].rule;
+		rulenum = jumpstack[stackptr].rulenum;
 		goto next_rule;
 	}
 	nft_chain_stats(chain, pkt, jumpstack, stackptr);
 
+	if (unlikely(pkt->skb->nf_trace))
+		nft_trace_packet(pkt, chain, ++rulenum, NFT_TRACE_POLICY);
+
 	return nft_base_chain(chain)->policy;
 }
 EXPORT_SYMBOL_GPL(nft_do_chain_pktinfo);
-- 
1.7.10.4
