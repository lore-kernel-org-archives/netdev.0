From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/21] netfilter: nf_tables: get rid of NFT_REG_VERDICT usage
Date: Mon, 13 Apr 2015 21:29:45 +0200
Message-ID: <1428953401-4838-7-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39674 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751603AbbDMTZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 15:25:56 -0400
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Replace the array of registers passed to expressions by a struct nft_regs,
containing the verdict as a seperate member, which aliases to the
NFT_REG_VERDICT register.

This is needed to seperate the verdict from the data registers completely,
so their size can be changed.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |   32 +++++++++++++++++++++++++---
 include/net/netfilter/nft_meta.h         |    4 ++--
 net/bridge/netfilter/nft_meta_bridge.c   |    8 +++----
 net/bridge/netfilter/nft_reject_bridge.c |    6 +++---
 net/ipv4/netfilter/nft_masq_ipv4.c       |    9 +++-----
 net/ipv4/netfilter/nft_redir_ipv4.c      |   11 +++++-----
 net/ipv4/netfilter/nft_reject_ipv4.c     |    4 ++--
 net/ipv6/netfilter/nft_masq_ipv6.c       |    7 ++----
 net/ipv6/netfilter/nft_redir_ipv6.c      |   11 +++++-----
 net/ipv6/netfilter/nft_reject_ipv6.c     |    4 ++--
 net/netfilter/nf_tables_core.c           |   34 +++++++++++++++---------------
 net/netfilter/nft_bitwise.c              |    6 +++---
 net/netfilter/nft_byteorder.c            |    5 +++--
 net/netfilter/nft_cmp.c                  |    6 +++---
 net/netfilter/nft_compat.c               |   26 +++++++++++------------
 net/netfilter/nft_counter.c              |    2 +-
 net/netfilter/nft_ct.c                   |   10 ++++-----
 net/netfilter/nft_dynset.c               |   13 ++++++------
 net/netfilter/nft_exthdr.c               |    6 +++---
 net/netfilter/nft_hash.c                 |    6 +++---
 net/netfilter/nft_immediate.c            |    4 ++--
 net/netfilter/nft_limit.c                |    4 ++--
 net/netfilter/nft_log.c                  |    2 +-
 net/netfilter/nft_lookup.c               |    9 ++++----
 net/netfilter/nft_meta.c                 |   10 ++++-----
 net/netfilter/nft_nat.c                  |   17 +++++++--------
 net/netfilter/nft_payload.c              |    6 +++---
 net/netfilter/nft_queue.c                |    4 ++--
 net/netfilter/nft_reject_inet.c          |    5 +++--
 29 files changed, 146 insertions(+), 125 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 9cc3d55..79582d0 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -36,6 +36,17 @@ static inline void nft_set_pktinfo(struct nft_pktinfo *pkt,
 	pkt->xt.family = ops->pf;
 }
 
+/**
+ * 	struct nft_verdict - nf_tables verdict
+ *
+ * 	@code: nf_tables/netfilter verdict code
+ * 	@chain: destination chain for NFT_JUMP/NFT_GOTO
+ */
+struct nft_verdict {
+	u32				code;
+	struct nft_chain		*chain;
+};
+
 struct nft_data {
 	union {
 		u32				data[4];
@@ -46,6 +57,21 @@ struct nft_data {
 	};
 } __attribute__((aligned(__alignof__(u64))));
 
+/**
+ *	struct nft_regs - nf_tables register set
+ *
+ *	@data: data registers
+ *	@verdict: verdict register
+ *
+ *	The first four data registers alias to the verdict register.
+ */
+struct nft_regs {
+	union {
+		struct nft_data 	data[NFT_REG_MAX + 1];
+		struct nft_verdict	verdict;
+	};
+};
+
 static inline int nft_data_cmp(const struct nft_data *d1,
 			       const struct nft_data *d2,
 			       unsigned int len)
@@ -221,9 +247,9 @@ struct nft_set_ops {
 						  const struct nft_data *key,
 						  void *(*new)(struct nft_set *,
 							       const struct nft_expr *,
-							       struct nft_data []),
+							       struct nft_regs *),
 						  const struct nft_expr *expr,
-						  struct nft_data data[],
+						  struct nft_regs *regs,
 						  const struct nft_set_ext **ext);
 
 	int				(*insert)(const struct nft_set *set,
@@ -583,7 +609,7 @@ struct nft_expr_type {
 struct nft_expr;
 struct nft_expr_ops {
 	void				(*eval)(const struct nft_expr *expr,
-						struct nft_data data[NFT_REG_MAX + 1],
+						struct nft_regs *regs,
 						const struct nft_pktinfo *pkt);
 	unsigned int			size;
 
diff --git a/include/net/netfilter/nft_meta.h b/include/net/netfilter/nft_meta.h
index 0ee47c3..711887a 100644
--- a/include/net/netfilter/nft_meta.h
+++ b/include/net/netfilter/nft_meta.h
@@ -26,11 +26,11 @@ int nft_meta_set_dump(struct sk_buff *skb,
 		      const struct nft_expr *expr);
 
 void nft_meta_get_eval(const struct nft_expr *expr,
-		       struct nft_data data[NFT_REG_MAX + 1],
+		       struct nft_regs *regs,
 		       const struct nft_pktinfo *pkt);
 
 void nft_meta_set_eval(const struct nft_expr *expr,
-		       struct nft_data data[NFT_REG_MAX + 1],
+		       struct nft_regs *regs,
 		       const struct nft_pktinfo *pkt);
 
 #endif
diff --git a/net/bridge/netfilter/nft_meta_bridge.c b/net/bridge/netfilter/nft_meta_bridge.c
index 54d9847..f0dfa38 100644
--- a/net/bridge/netfilter/nft_meta_bridge.c
+++ b/net/bridge/netfilter/nft_meta_bridge.c
@@ -19,12 +19,12 @@
 #include "../br_private.h"
 
 static void nft_meta_bridge_get_eval(const struct nft_expr *expr,
-				     struct nft_data data[NFT_REG_MAX + 1],
+				     struct nft_regs *regs,
 				     const struct nft_pktinfo *pkt)
 {
 	const struct nft_meta *priv = nft_expr_priv(expr);
 	const struct net_device *in = pkt->in, *out = pkt->out;
-	struct nft_data *dest = &data[priv->dreg];
+	struct nft_data *dest = &regs->data[priv->dreg];
 	const struct net_bridge_port *p;
 
 	switch (priv->key) {
@@ -43,9 +43,9 @@ static void nft_meta_bridge_get_eval(const struct nft_expr *expr,
 	strncpy((char *)dest->data, p->br->dev->name, sizeof(dest->data));
 	return;
 out:
-	return nft_meta_get_eval(expr, data, pkt);
+	return nft_meta_get_eval(expr, regs, pkt);
 err:
-	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
+	regs->verdict.code = NFT_BREAK;
 }
 
 static int nft_meta_bridge_get_init(const struct nft_ctx *ctx,
diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index ae8141f..858d848 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -257,8 +257,8 @@ static void nft_reject_br_send_v6_unreach(struct net *net,
 }
 
 static void nft_reject_bridge_eval(const struct nft_expr *expr,
-				 struct nft_data data[NFT_REG_MAX + 1],
-				 const struct nft_pktinfo *pkt)
+				   struct nft_regs *regs,
+				   const struct nft_pktinfo *pkt)
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
 	struct net *net = dev_net((pkt->in != NULL) ? pkt->in : pkt->out);
@@ -310,7 +310,7 @@ static void nft_reject_bridge_eval(const struct nft_expr *expr,
 		break;
 	}
 out:
-	data[NFT_REG_VERDICT].verdict = NF_DROP;
+	regs->verdict.code = NF_DROP;
 }
 
 static int nft_reject_bridge_validate(const struct nft_ctx *ctx,
diff --git a/net/ipv4/netfilter/nft_masq_ipv4.c b/net/ipv4/netfilter/nft_masq_ipv4.c
index 665de06..40e414c 100644
--- a/net/ipv4/netfilter/nft_masq_ipv4.c
+++ b/net/ipv4/netfilter/nft_masq_ipv4.c
@@ -17,20 +17,17 @@
 #include <net/netfilter/ipv4/nf_nat_masquerade.h>
 
 static void nft_masq_ipv4_eval(const struct nft_expr *expr,
-			       struct nft_data data[NFT_REG_MAX + 1],
+			       struct nft_regs *regs,
 			       const struct nft_pktinfo *pkt)
 {
 	struct nft_masq *priv = nft_expr_priv(expr);
 	struct nf_nat_range range;
-	unsigned int verdict;
 
 	memset(&range, 0, sizeof(range));
 	range.flags = priv->flags;
 
-	verdict = nf_nat_masquerade_ipv4(pkt->skb, pkt->ops->hooknum,
-					 &range, pkt->out);
-
-	data[NFT_REG_VERDICT].verdict = verdict;
+	regs->verdict.code = nf_nat_masquerade_ipv4(pkt->skb, pkt->ops->hooknum,
+						    &range, pkt->out);
 }
 
 static struct nft_expr_type nft_masq_ipv4_type;
diff --git a/net/ipv4/netfilter/nft_redir_ipv4.c b/net/ipv4/netfilter/nft_redir_ipv4.c
index 6ecfce6..312cf6f 100644
--- a/net/ipv4/netfilter/nft_redir_ipv4.c
+++ b/net/ipv4/netfilter/nft_redir_ipv4.c
@@ -18,26 +18,25 @@
 #include <net/netfilter/nft_redir.h>
 
 static void nft_redir_ipv4_eval(const struct nft_expr *expr,
-				struct nft_data data[NFT_REG_MAX + 1],
+				struct nft_regs *regs,
 				const struct nft_pktinfo *pkt)
 {
 	struct nft_redir *priv = nft_expr_priv(expr);
 	struct nf_nat_ipv4_multi_range_compat mr;
-	unsigned int verdict;
 
 	memset(&mr, 0, sizeof(mr));
 	if (priv->sreg_proto_min) {
 		mr.range[0].min.all =
-			*(__be16 *)&data[priv->sreg_proto_min].data[0];
+			*(__be16 *)&regs->data[priv->sreg_proto_min].data[0];
 		mr.range[0].max.all =
-			*(__be16 *)&data[priv->sreg_proto_max].data[0];
+			*(__be16 *)&regs->data[priv->sreg_proto_max].data[0];
 		mr.range[0].flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
 	}
 
 	mr.range[0].flags |= priv->flags;
 
-	verdict = nf_nat_redirect_ipv4(pkt->skb, &mr, pkt->ops->hooknum);
-	data[NFT_REG_VERDICT].verdict = verdict;
+	regs->verdict.code = nf_nat_redirect_ipv4(pkt->skb, &mr,
+						  pkt->ops->hooknum);
 }
 
 static struct nft_expr_type nft_redir_ipv4_type;
diff --git a/net/ipv4/netfilter/nft_reject_ipv4.c b/net/ipv4/netfilter/nft_reject_ipv4.c
index a7621fa..b07e58b 100644
--- a/net/ipv4/netfilter/nft_reject_ipv4.c
+++ b/net/ipv4/netfilter/nft_reject_ipv4.c
@@ -20,7 +20,7 @@
 #include <net/netfilter/nft_reject.h>
 
 static void nft_reject_ipv4_eval(const struct nft_expr *expr,
-				 struct nft_data data[NFT_REG_MAX + 1],
+				 struct nft_regs *regs,
 				 const struct nft_pktinfo *pkt)
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
@@ -37,7 +37,7 @@ static void nft_reject_ipv4_eval(const struct nft_expr *expr,
 		break;
 	}
 
-	data[NFT_REG_VERDICT].verdict = NF_DROP;
+	regs->verdict.code = NF_DROP;
 }
 
 static struct nft_expr_type nft_reject_ipv4_type;
diff --git a/net/ipv6/netfilter/nft_masq_ipv6.c b/net/ipv6/netfilter/nft_masq_ipv6.c
index 529c119..cd1ac16 100644
--- a/net/ipv6/netfilter/nft_masq_ipv6.c
+++ b/net/ipv6/netfilter/nft_masq_ipv6.c
@@ -18,19 +18,16 @@
 #include <net/netfilter/ipv6/nf_nat_masquerade.h>
 
 static void nft_masq_ipv6_eval(const struct nft_expr *expr,
-			       struct nft_data data[NFT_REG_MAX + 1],
+			       struct nft_regs *regs,
 			       const struct nft_pktinfo *pkt)
 {
 	struct nft_masq *priv = nft_expr_priv(expr);
 	struct nf_nat_range range;
-	unsigned int verdict;
 
 	memset(&range, 0, sizeof(range));
 	range.flags = priv->flags;
 
-	verdict = nf_nat_masquerade_ipv6(pkt->skb, &range, pkt->out);
-
-	data[NFT_REG_VERDICT].verdict = verdict;
+	regs->verdict.code = nf_nat_masquerade_ipv6(pkt->skb, &range, pkt->out);
 }
 
 static struct nft_expr_type nft_masq_ipv6_type;
diff --git a/net/ipv6/netfilter/nft_redir_ipv6.c b/net/ipv6/netfilter/nft_redir_ipv6.c
index 11820b6..0eed774 100644
--- a/net/ipv6/netfilter/nft_redir_ipv6.c
+++ b/net/ipv6/netfilter/nft_redir_ipv6.c
@@ -18,26 +18,25 @@
 #include <net/netfilter/nf_nat_redirect.h>
 
 static void nft_redir_ipv6_eval(const struct nft_expr *expr,
-				struct nft_data data[NFT_REG_MAX + 1],
+				struct nft_regs *regs,
 				const struct nft_pktinfo *pkt)
 {
 	struct nft_redir *priv = nft_expr_priv(expr);
 	struct nf_nat_range range;
-	unsigned int verdict;
 
 	memset(&range, 0, sizeof(range));
 	if (priv->sreg_proto_min) {
 		range.min_proto.all =
-			*(__be16 *)&data[priv->sreg_proto_min].data[0];
+			*(__be16 *)&regs->data[priv->sreg_proto_min].data[0];
 		range.max_proto.all =
-			*(__be16 *)&data[priv->sreg_proto_max].data[0];
+			*(__be16 *)&regs->data[priv->sreg_proto_max].data[0];
 		range.flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
 	}
 
 	range.flags |= priv->flags;
 
-	verdict = nf_nat_redirect_ipv6(pkt->skb, &range, pkt->ops->hooknum);
-	data[NFT_REG_VERDICT].verdict = verdict;
+	regs->verdict.code = nf_nat_redirect_ipv6(pkt->skb, &range,
+						  pkt->ops->hooknum);
 }
 
 static struct nft_expr_type nft_redir_ipv6_type;
diff --git a/net/ipv6/netfilter/nft_reject_ipv6.c b/net/ipv6/netfilter/nft_reject_ipv6.c
index 71c7be5..d0d1540 100644
--- a/net/ipv6/netfilter/nft_reject_ipv6.c
+++ b/net/ipv6/netfilter/nft_reject_ipv6.c
@@ -20,7 +20,7 @@
 #include <net/netfilter/ipv6/nf_reject.h>
 
 static void nft_reject_ipv6_eval(const struct nft_expr *expr,
-				 struct nft_data data[NFT_REG_MAX + 1],
+				 struct nft_regs *regs,
 				 const struct nft_pktinfo *pkt)
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
@@ -38,7 +38,7 @@ static void nft_reject_ipv6_eval(const struct nft_expr *expr,
 		break;
 	}
 
-	data[NFT_REG_VERDICT].verdict = NF_DROP;
+	regs->verdict.code = NF_DROP;
 }
 
 static struct nft_expr_type nft_reject_ipv6_type;
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 7caf08a..667cdf0 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -65,23 +65,23 @@ static inline void nft_trace_packet(const struct nft_pktinfo *pkt,
 }
 
 static void nft_cmp_fast_eval(const struct nft_expr *expr,
-			      struct nft_data data[NFT_REG_MAX + 1])
+			      struct nft_regs *regs)
 {
 	const struct nft_cmp_fast_expr *priv = nft_expr_priv(expr);
 	u32 mask = nft_cmp_fast_mask(priv->len);
 
-	if ((data[priv->sreg].data[0] & mask) == priv->data)
+	if ((regs->data[priv->sreg].data[0] & mask) == priv->data)
 		return;
-	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
+	regs->verdict.code = NFT_BREAK;
 }
 
 static bool nft_payload_fast_eval(const struct nft_expr *expr,
-				  struct nft_data data[NFT_REG_MAX + 1],
+				  struct nft_regs *regs,
 				  const struct nft_pktinfo *pkt)
 {
 	const struct nft_payload *priv = nft_expr_priv(expr);
 	const struct sk_buff *skb = pkt->skb;
-	struct nft_data *dest = &data[priv->dreg];
+	struct nft_data *dest = &regs->data[priv->dreg];
 	unsigned char *ptr;
 
 	if (priv->base == NFT_PAYLOAD_NETWORK_HEADER)
@@ -116,7 +116,7 @@ nft_do_chain(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
 	const struct net *net = read_pnet(&nft_base_chain(basechain)->pnet);
 	const struct nft_rule *rule;
 	const struct nft_expr *expr, *last;
-	struct nft_data data[NFT_REG_MAX + 1];
+	struct nft_regs regs;
 	unsigned int stackptr = 0;
 	struct nft_jumpstack jumpstack[NFT_JUMP_STACK_SIZE];
 	struct nft_stats *stats;
@@ -127,7 +127,7 @@ do_chain:
 	rulenum = 0;
 	rule = list_entry(&chain->rules, struct nft_rule, list);
 next_rule:
-	data[NFT_REG_VERDICT].verdict = NFT_CONTINUE;
+	regs.verdict.code = NFT_CONTINUE;
 	list_for_each_entry_continue_rcu(rule, &chain->rules, list) {
 
 		/* This rule is not active, skip. */
@@ -138,18 +138,18 @@ next_rule:
 
 		nft_rule_for_each_expr(expr, last, rule) {
 			if (expr->ops == &nft_cmp_fast_ops)
-				nft_cmp_fast_eval(expr, data);
+				nft_cmp_fast_eval(expr, &regs);
 			else if (expr->ops != &nft_payload_fast_ops ||
-				 !nft_payload_fast_eval(expr, data, pkt))
-				expr->ops->eval(expr, data, pkt);
+				 !nft_payload_fast_eval(expr, &regs, pkt))
+				expr->ops->eval(expr, &regs, pkt);
 
-			if (data[NFT_REG_VERDICT].verdict != NFT_CONTINUE)
+			if (regs.verdict.code != NFT_CONTINUE)
 				break;
 		}
 
-		switch (data[NFT_REG_VERDICT].verdict) {
+		switch (regs.verdict.code) {
 		case NFT_BREAK:
-			data[NFT_REG_VERDICT].verdict = NFT_CONTINUE;
+			regs.verdict.code = NFT_CONTINUE;
 			continue;
 		case NFT_CONTINUE:
 			nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RULE);
@@ -158,15 +158,15 @@ next_rule:
 		break;
 	}
 
-	switch (data[NFT_REG_VERDICT].verdict & NF_VERDICT_MASK) {
+	switch (regs.verdict.code & NF_VERDICT_MASK) {
 	case NF_ACCEPT:
 	case NF_DROP:
 	case NF_QUEUE:
 		nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RULE);
-		return data[NFT_REG_VERDICT].verdict;
+		return regs.verdict.code;
 	}
 
-	switch (data[NFT_REG_VERDICT].verdict) {
+	switch (regs.verdict.code) {
 	case NFT_JUMP:
 		BUG_ON(stackptr >= NFT_JUMP_STACK_SIZE);
 		jumpstack[stackptr].chain = chain;
@@ -177,7 +177,7 @@ next_rule:
 	case NFT_GOTO:
 		nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RULE);
 
-		chain = data[NFT_REG_VERDICT].chain;
+		chain = regs.verdict.chain;
 		goto do_chain;
 	case NFT_CONTINUE:
 		rulenum++;
diff --git a/net/netfilter/nft_bitwise.c b/net/netfilter/nft_bitwise.c
index 60050ee..2b8f518 100644
--- a/net/netfilter/nft_bitwise.c
+++ b/net/netfilter/nft_bitwise.c
@@ -26,12 +26,12 @@ struct nft_bitwise {
 };
 
 static void nft_bitwise_eval(const struct nft_expr *expr,
-			     struct nft_data data[NFT_REG_MAX + 1],
+			     struct nft_regs *regs,
 			     const struct nft_pktinfo *pkt)
 {
 	const struct nft_bitwise *priv = nft_expr_priv(expr);
-	const struct nft_data *src = &data[priv->sreg];
-	struct nft_data *dst = &data[priv->dreg];
+	const struct nft_data *src = &regs->data[priv->sreg];
+	struct nft_data *dst = &regs->data[priv->dreg];
 	unsigned int i;
 
 	for (i = 0; i < DIV_ROUND_UP(priv->len, 4); i++) {
diff --git a/net/netfilter/nft_byteorder.c b/net/netfilter/nft_byteorder.c
index f34bfbd..48fbfa3 100644
--- a/net/netfilter/nft_byteorder.c
+++ b/net/netfilter/nft_byteorder.c
@@ -26,11 +26,12 @@ struct nft_byteorder {
 };
 
 static void nft_byteorder_eval(const struct nft_expr *expr,
-			       struct nft_data data[NFT_REG_MAX + 1],
+			       struct nft_regs *regs,
 			       const struct nft_pktinfo *pkt)
 {
 	const struct nft_byteorder *priv = nft_expr_priv(expr);
-	struct nft_data *src = &data[priv->sreg], *dst = &data[priv->dreg];
+	struct nft_data *src = &regs->data[priv->sreg];
+	struct nft_data *dst = &regs->data[priv->dreg];
 	union { u32 u32; u16 u16; } *s, *d;
 	unsigned int i;
 
diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index 17e9b8b..59391e6 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -25,13 +25,13 @@ struct nft_cmp_expr {
 };
 
 static void nft_cmp_eval(const struct nft_expr *expr,
-			 struct nft_data data[NFT_REG_MAX + 1],
+			 struct nft_regs *regs,
 			 const struct nft_pktinfo *pkt)
 {
 	const struct nft_cmp_expr *priv = nft_expr_priv(expr);
 	int d;
 
-	d = nft_data_cmp(&data[priv->sreg], &priv->data, priv->len);
+	d = nft_data_cmp(&regs->data[priv->sreg], &priv->data, priv->len);
 	switch (priv->op) {
 	case NFT_CMP_EQ:
 		if (d != 0)
@@ -59,7 +59,7 @@ static void nft_cmp_eval(const struct nft_expr *expr,
 	return;
 
 mismatch:
-	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
+	regs->verdict.code = NFT_BREAK;
 }
 
 static const struct nla_policy nft_cmp_policy[NFTA_CMP_MAX + 1] = {
diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 0d137c1..7f29cfc 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -55,7 +55,7 @@ nft_compat_set_par(struct xt_action_param *par, void *xt, const void *xt_info)
 }
 
 static void nft_target_eval_xt(const struct nft_expr *expr,
-			       struct nft_data data[NFT_REG_MAX + 1],
+			       struct nft_regs *regs,
 			       const struct nft_pktinfo *pkt)
 {
 	void *info = nft_expr_priv(expr);
@@ -72,16 +72,16 @@ static void nft_target_eval_xt(const struct nft_expr *expr,
 
 	switch (ret) {
 	case XT_CONTINUE:
-		data[NFT_REG_VERDICT].verdict = NFT_CONTINUE;
+		regs->verdict.code = NFT_CONTINUE;
 		break;
 	default:
-		data[NFT_REG_VERDICT].verdict = ret;
+		regs->verdict.code = ret;
 		break;
 	}
 }
 
 static void nft_target_eval_bridge(const struct nft_expr *expr,
-				   struct nft_data data[NFT_REG_MAX + 1],
+				   struct nft_regs *regs,
 				   const struct nft_pktinfo *pkt)
 {
 	void *info = nft_expr_priv(expr);
@@ -98,19 +98,19 @@ static void nft_target_eval_bridge(const struct nft_expr *expr,
 
 	switch (ret) {
 	case EBT_ACCEPT:
-		data[NFT_REG_VERDICT].verdict = NF_ACCEPT;
+		regs->verdict.code = NF_ACCEPT;
 		break;
 	case EBT_DROP:
-		data[NFT_REG_VERDICT].verdict = NF_DROP;
+		regs->verdict.code = NF_DROP;
 		break;
 	case EBT_CONTINUE:
-		data[NFT_REG_VERDICT].verdict = NFT_CONTINUE;
+		regs->verdict.code = NFT_CONTINUE;
 		break;
 	case EBT_RETURN:
-		data[NFT_REG_VERDICT].verdict = NFT_RETURN;
+		regs->verdict.code = NFT_RETURN;
 		break;
 	default:
-		data[NFT_REG_VERDICT].verdict = ret;
+		regs->verdict.code = ret;
 		break;
 	}
 }
@@ -304,7 +304,7 @@ static int nft_target_validate(const struct nft_ctx *ctx,
 }
 
 static void nft_match_eval(const struct nft_expr *expr,
-			   struct nft_data data[NFT_REG_MAX + 1],
+			   struct nft_regs *regs,
 			   const struct nft_pktinfo *pkt)
 {
 	void *info = nft_expr_priv(expr);
@@ -317,16 +317,16 @@ static void nft_match_eval(const struct nft_expr *expr,
 	ret = match->match(skb, (struct xt_action_param *)&pkt->xt);
 
 	if (pkt->xt.hotdrop) {
-		data[NFT_REG_VERDICT].verdict = NF_DROP;
+		regs->verdict.code = NF_DROP;
 		return;
 	}
 
 	switch (ret ? 1 : 0) {
 	case 1:
-		data[NFT_REG_VERDICT].verdict = NFT_CONTINUE;
+		regs->verdict.code = NFT_CONTINUE;
 		break;
 	case 0:
-		data[NFT_REG_VERDICT].verdict = NFT_BREAK;
+		regs->verdict.code = NFT_BREAK;
 		break;
 	}
 }
diff --git a/net/netfilter/nft_counter.c b/net/netfilter/nft_counter.c
index c89ee48..0f6367e 100644
--- a/net/netfilter/nft_counter.c
+++ b/net/netfilter/nft_counter.c
@@ -24,7 +24,7 @@ struct nft_counter {
 };
 
 static void nft_counter_eval(const struct nft_expr *expr,
-			     struct nft_data data[NFT_REG_MAX + 1],
+			     struct nft_regs *regs,
 			     const struct nft_pktinfo *pkt)
 {
 	struct nft_counter *priv = nft_expr_priv(expr);
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 6bf6ed7..077e06b 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -31,11 +31,11 @@ struct nft_ct {
 };
 
 static void nft_ct_get_eval(const struct nft_expr *expr,
-			    struct nft_data data[NFT_REG_MAX + 1],
+			    struct nft_regs *regs,
 			    const struct nft_pktinfo *pkt)
 {
 	const struct nft_ct *priv = nft_expr_priv(expr);
-	struct nft_data *dest = &data[priv->dreg];
+	struct nft_data *dest = &regs->data[priv->dreg];
 	enum ip_conntrack_info ctinfo;
 	const struct nf_conn *ct;
 	const struct nf_conn_help *help;
@@ -146,17 +146,17 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 	}
 	return;
 err:
-	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
+	regs->verdict.code = NFT_BREAK;
 }
 
 static void nft_ct_set_eval(const struct nft_expr *expr,
-			    struct nft_data data[NFT_REG_MAX + 1],
+			    struct nft_regs *regs,
 			    const struct nft_pktinfo *pkt)
 {
 	const struct nft_ct *priv = nft_expr_priv(expr);
 	struct sk_buff *skb = pkt->skb;
 #ifdef CONFIG_NF_CONNTRACK_MARK
-	u32 value = data[priv->sreg].data[0];
+	u32 value = regs->data[priv->sreg].data[0];
 #endif
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
diff --git a/net/netfilter/nft_dynset.c b/net/netfilter/nft_dynset.c
index 3ea52b7..e398f6d 100644
--- a/net/netfilter/nft_dynset.c
+++ b/net/netfilter/nft_dynset.c
@@ -27,7 +27,7 @@ struct nft_dynset {
 };
 
 static void *nft_dynset_new(struct nft_set *set, const struct nft_expr *expr,
-			    struct nft_data data[NFT_REG_MAX + 1])
+			    struct nft_regs *regs)
 {
 	const struct nft_dynset *priv = nft_expr_priv(expr);
 	u64 timeout;
@@ -38,7 +38,8 @@ static void *nft_dynset_new(struct nft_set *set, const struct nft_expr *expr,
 
 	timeout = priv->timeout ? : set->timeout;
 	elem = nft_set_elem_init(set, &priv->tmpl,
-				 &data[priv->sreg_key], &data[priv->sreg_data],
+				 &regs->data[priv->sreg_key],
+				 &regs->data[priv->sreg_data],
 				 timeout, GFP_ATOMIC);
 	if (elem == NULL) {
 		if (set->size)
@@ -48,7 +49,7 @@ static void *nft_dynset_new(struct nft_set *set, const struct nft_expr *expr,
 }
 
 static void nft_dynset_eval(const struct nft_expr *expr,
-			    struct nft_data data[NFT_REG_MAX + 1],
+			    struct nft_regs *regs,
 			    const struct nft_pktinfo *pkt)
 {
 	const struct nft_dynset *priv = nft_expr_priv(expr);
@@ -56,8 +57,8 @@ static void nft_dynset_eval(const struct nft_expr *expr,
 	const struct nft_set_ext *ext;
 	u64 timeout;
 
-	if (set->ops->update(set, &data[priv->sreg_key], nft_dynset_new,
-			     expr, data, &ext)) {
+	if (set->ops->update(set, &regs->data[priv->sreg_key], nft_dynset_new,
+			     expr, regs, &ext)) {
 		if (priv->op == NFT_DYNSET_OP_UPDATE &&
 		    nft_set_ext_exists(ext, NFT_SET_EXT_EXPIRATION)) {
 			timeout = priv->timeout ? : set->timeout;
@@ -66,7 +67,7 @@ static void nft_dynset_eval(const struct nft_expr *expr,
 		}
 	}
 
-	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
+	regs->verdict.code = NFT_BREAK;
 }
 
 static const struct nla_policy nft_dynset_policy[NFTA_DYNSET_MAX + 1] = {
diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index 8c4981c..2480af7 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -26,11 +26,11 @@ struct nft_exthdr {
 };
 
 static void nft_exthdr_eval(const struct nft_expr *expr,
-			    struct nft_data data[NFT_REG_MAX + 1],
+			    struct nft_regs *regs,
 			    const struct nft_pktinfo *pkt)
 {
 	struct nft_exthdr *priv = nft_expr_priv(expr);
-	struct nft_data *dest = &data[priv->dreg];
+	struct nft_data *dest = &regs->data[priv->dreg];
 	unsigned int offset = 0;
 	int err;
 
@@ -43,7 +43,7 @@ static void nft_exthdr_eval(const struct nft_expr *expr,
 		goto err;
 	return;
 err:
-	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
+	regs->verdict.code = NFT_BREAK;
 }
 
 static const struct nla_policy nft_exthdr_policy[NFTA_EXTHDR_MAX + 1] = {
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index bc23806..b1101f7 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -93,9 +93,9 @@ static bool nft_hash_lookup(const struct nft_set *set,
 static bool nft_hash_update(struct nft_set *set, const struct nft_data *key,
 			    void *(*new)(struct nft_set *,
 					 const struct nft_expr *,
-					 struct nft_data []),
+					 struct nft_regs *regs),
 			    const struct nft_expr *expr,
-			    struct nft_data data[],
+			    struct nft_regs *regs,
 			    const struct nft_set_ext **ext)
 {
 	struct nft_hash *priv = nft_set_priv(set);
@@ -110,7 +110,7 @@ static bool nft_hash_update(struct nft_set *set, const struct nft_data *key,
 	if (he != NULL)
 		goto out;
 
-	he = new(set, expr, data);
+	he = new(set, expr, regs);
 	if (he == NULL)
 		goto err1;
 	if (rhashtable_lookup_insert_key(&priv->ht, &arg, &he->node,
diff --git a/net/netfilter/nft_immediate.c b/net/netfilter/nft_immediate.c
index a164c04..29cc739 100644
--- a/net/netfilter/nft_immediate.c
+++ b/net/netfilter/nft_immediate.c
@@ -24,12 +24,12 @@ struct nft_immediate_expr {
 };
 
 static void nft_immediate_eval(const struct nft_expr *expr,
-			       struct nft_data data[NFT_REG_MAX + 1],
+			       struct nft_regs *regs,
 			       const struct nft_pktinfo *pkt)
 {
 	const struct nft_immediate_expr *priv = nft_expr_priv(expr);
 
-	nft_data_copy(&data[priv->dreg], &priv->data);
+	nft_data_copy(&regs->data[priv->dreg], &priv->data);
 }
 
 static const struct nla_policy nft_immediate_policy[NFTA_IMMEDIATE_MAX + 1] = {
diff --git a/net/netfilter/nft_limit.c b/net/netfilter/nft_limit.c
index 85da5bd..c862045 100644
--- a/net/netfilter/nft_limit.c
+++ b/net/netfilter/nft_limit.c
@@ -27,7 +27,7 @@ struct nft_limit {
 };
 
 static void nft_limit_eval(const struct nft_expr *expr,
-			   struct nft_data data[NFT_REG_MAX + 1],
+			   struct nft_regs *regs,
 			   const struct nft_pktinfo *pkt)
 {
 	struct nft_limit *priv = nft_expr_priv(expr);
@@ -45,7 +45,7 @@ static void nft_limit_eval(const struct nft_expr *expr,
 	}
 	spin_unlock_bh(&limit_lock);
 
-	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
+	regs->verdict.code = NFT_BREAK;
 }
 
 static const struct nla_policy nft_limit_policy[NFTA_LIMIT_MAX + 1] = {
diff --git a/net/netfilter/nft_log.c b/net/netfilter/nft_log.c
index e18af9db..a13d6a3 100644
--- a/net/netfilter/nft_log.c
+++ b/net/netfilter/nft_log.c
@@ -27,7 +27,7 @@ struct nft_log {
 };
 
 static void nft_log_eval(const struct nft_expr *expr,
-			 struct nft_data data[NFT_REG_MAX + 1],
+			 struct nft_regs *regs,
 			 const struct nft_pktinfo *pkt)
 {
 	const struct nft_log *priv = nft_expr_priv(expr);
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index 8fc0d18..01dba68 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -26,19 +26,20 @@ struct nft_lookup {
 };
 
 static void nft_lookup_eval(const struct nft_expr *expr,
-			    struct nft_data data[NFT_REG_MAX + 1],
+			    struct nft_regs *regs,
 			    const struct nft_pktinfo *pkt)
 {
 	const struct nft_lookup *priv = nft_expr_priv(expr);
 	const struct nft_set *set = priv->set;
 	const struct nft_set_ext *ext;
 
-	if (set->ops->lookup(set, &data[priv->sreg], &ext)) {
+	if (set->ops->lookup(set, &regs->data[priv->sreg], &ext)) {
 		if (set->flags & NFT_SET_MAP)
-			nft_data_copy(&data[priv->dreg], nft_set_ext_data(ext));
+			nft_data_copy(&regs->data[priv->dreg],
+				      nft_set_ext_data(ext));
 		return;
 	}
-	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
+	regs->verdict.code = NFT_BREAK;
 }
 
 static const struct nla_policy nft_lookup_policy[NFTA_LOOKUP_MAX + 1] = {
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 0ae6bb7..3f11c0b 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -25,13 +25,13 @@
 #include <net/netfilter/nft_meta.h>
 
 void nft_meta_get_eval(const struct nft_expr *expr,
-		       struct nft_data data[NFT_REG_MAX + 1],
+		       struct nft_regs *regs,
 		       const struct nft_pktinfo *pkt)
 {
 	const struct nft_meta *priv = nft_expr_priv(expr);
 	const struct sk_buff *skb = pkt->skb;
 	const struct net_device *in = pkt->in, *out = pkt->out;
-	struct nft_data *dest = &data[priv->dreg];
+	struct nft_data *dest = &regs->data[priv->dreg];
 
 	switch (priv->key) {
 	case NFT_META_LEN:
@@ -177,17 +177,17 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 	return;
 
 err:
-	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
+	regs->verdict.code = NFT_BREAK;
 }
 EXPORT_SYMBOL_GPL(nft_meta_get_eval);
 
 void nft_meta_set_eval(const struct nft_expr *expr,
-		       struct nft_data data[NFT_REG_MAX + 1],
+		       struct nft_regs *regs,
 		       const struct nft_pktinfo *pkt)
 {
 	const struct nft_meta *meta = nft_expr_priv(expr);
 	struct sk_buff *skb = pkt->skb;
-	u32 value = data[meta->sreg].data[0];
+	u32 value = regs->data[meta->sreg].data[0];
 
 	switch (meta->key) {
 	case NFT_META_MARK:
diff --git a/net/netfilter/nft_nat.c b/net/netfilter/nft_nat.c
index 0897a80..b723311 100644
--- a/net/netfilter/nft_nat.c
+++ b/net/netfilter/nft_nat.c
@@ -37,7 +37,7 @@ struct nft_nat {
 };
 
 static void nft_nat_eval(const struct nft_expr *expr,
-			 struct nft_data data[NFT_REG_MAX + 1],
+			 struct nft_regs *regs,
 			 const struct nft_pktinfo *pkt)
 {
 	const struct nft_nat *priv = nft_expr_priv(expr);
@@ -49,16 +49,16 @@ static void nft_nat_eval(const struct nft_expr *expr,
 	if (priv->sreg_addr_min) {
 		if (priv->family == AF_INET) {
 			range.min_addr.ip = (__force __be32)
-					data[priv->sreg_addr_min].data[0];
+					regs->data[priv->sreg_addr_min].data[0];
 			range.max_addr.ip = (__force __be32)
-					data[priv->sreg_addr_max].data[0];
+					regs->data[priv->sreg_addr_max].data[0];
 
 		} else {
 			memcpy(range.min_addr.ip6,
-			       data[priv->sreg_addr_min].data,
+			       &regs->data[priv->sreg_addr_min].data,
 			       sizeof(struct nft_data));
 			memcpy(range.max_addr.ip6,
-			       data[priv->sreg_addr_max].data,
+			       &regs->data[priv->sreg_addr_max].data,
 			       sizeof(struct nft_data));
 		}
 		range.flags |= NF_NAT_RANGE_MAP_IPS;
@@ -66,16 +66,15 @@ static void nft_nat_eval(const struct nft_expr *expr,
 
 	if (priv->sreg_proto_min) {
 		range.min_proto.all =
-			*(__be16 *)&data[priv->sreg_proto_min].data[0];
+			*(__be16 *)&regs->data[priv->sreg_proto_min].data[0];
 		range.max_proto.all =
-			*(__be16 *)&data[priv->sreg_proto_max].data[0];
+			*(__be16 *)&regs->data[priv->sreg_proto_max].data[0];
 		range.flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
 	}
 
 	range.flags |= priv->flags;
 
-	data[NFT_REG_VERDICT].verdict =
-		nf_nat_setup_info(ct, &range, priv->type);
+	regs->verdict.code = nf_nat_setup_info(ct, &range, priv->type);
 }
 
 static const struct nla_policy nft_nat_policy[NFTA_NAT_MAX + 1] = {
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index b2a9ef9..14247c5 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -18,12 +18,12 @@
 #include <net/netfilter/nf_tables.h>
 
 static void nft_payload_eval(const struct nft_expr *expr,
-			     struct nft_data data[NFT_REG_MAX + 1],
+			     struct nft_regs *regs,
 			     const struct nft_pktinfo *pkt)
 {
 	const struct nft_payload *priv = nft_expr_priv(expr);
 	const struct sk_buff *skb = pkt->skb;
-	struct nft_data *dest = &data[priv->dreg];
+	struct nft_data *dest = &regs->data[priv->dreg];
 	int offset;
 
 	switch (priv->base) {
@@ -47,7 +47,7 @@ static void nft_payload_eval(const struct nft_expr *expr,
 		goto err;
 	return;
 err:
-	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
+	regs->verdict.code = NFT_BREAK;
 }
 
 static const struct nla_policy nft_payload_policy[NFTA_PAYLOAD_MAX + 1] = {
diff --git a/net/netfilter/nft_queue.c b/net/netfilter/nft_queue.c
index e8ae2f6..96805d2 100644
--- a/net/netfilter/nft_queue.c
+++ b/net/netfilter/nft_queue.c
@@ -28,7 +28,7 @@ struct nft_queue {
 };
 
 static void nft_queue_eval(const struct nft_expr *expr,
-			   struct nft_data data[NFT_REG_MAX + 1],
+			   struct nft_regs *regs,
 			   const struct nft_pktinfo *pkt)
 {
 	struct nft_queue *priv = nft_expr_priv(expr);
@@ -51,7 +51,7 @@ static void nft_queue_eval(const struct nft_expr *expr,
 	if (priv->flags & NFT_QUEUE_FLAG_BYPASS)
 		ret |= NF_VERDICT_FLAG_QUEUE_BYPASS;
 
-	data[NFT_REG_VERDICT].verdict = ret;
+	regs->verdict.code = ret;
 }
 
 static const struct nla_policy nft_queue_policy[NFTA_QUEUE_MAX + 1] = {
diff --git a/net/netfilter/nft_reject_inet.c b/net/netfilter/nft_reject_inet.c
index 9287711..62cabee 100644
--- a/net/netfilter/nft_reject_inet.c
+++ b/net/netfilter/nft_reject_inet.c
@@ -18,7 +18,7 @@
 #include <net/netfilter/ipv6/nf_reject.h>
 
 static void nft_reject_inet_eval(const struct nft_expr *expr,
-				 struct nft_data data[NFT_REG_MAX + 1],
+				 struct nft_regs *regs,
 				 const struct nft_pktinfo *pkt)
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
@@ -58,7 +58,8 @@ static void nft_reject_inet_eval(const struct nft_expr *expr,
 		}
 		break;
 	}
-	data[NFT_REG_VERDICT].verdict = NF_DROP;
+
+	regs->verdict.code = NF_DROP;
 }
 
 static int nft_reject_inet_init(const struct nft_ctx *ctx,
-- 
1.7.10.4
