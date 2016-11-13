From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/39] netfilter: nf_tables: use hook state from xt_action_param structure
Date: Sun, 13 Nov 2016 23:25:00 +0100
Message-ID: <1479075933-4491-7-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47636 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964880AbcKMW0H (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 17:26:07 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id C1C21A7E93
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:05 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B00D3DA861
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:05 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id CDC08DA801
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:02 +0100 (CET)
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't copy relevant fields from hook state structure, instead use the
one that is already available in struct xt_action_param.

This patch also adds a set of new wrapper functions to fetch relevant
hook state structure fields.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        | 35 +++++++++++++++++++++++---------
 net/bridge/netfilter/nft_meta_bridge.c   |  2 +-
 net/bridge/netfilter/nft_reject_bridge.c | 30 ++++++++++++++++-----------
 net/ipv4/netfilter/nft_dup_ipv4.c        |  2 +-
 net/ipv4/netfilter/nft_fib_ipv4.c        | 14 ++++++-------
 net/ipv4/netfilter/nft_masq_ipv4.c       |  4 ++--
 net/ipv4/netfilter/nft_redir_ipv4.c      |  3 +--
 net/ipv4/netfilter/nft_reject_ipv4.c     |  4 ++--
 net/ipv6/netfilter/nft_dup_ipv6.c        |  2 +-
 net/ipv6/netfilter/nft_fib_ipv6.c        | 16 +++++++--------
 net/ipv6/netfilter/nft_masq_ipv6.c       |  3 ++-
 net/ipv6/netfilter/nft_redir_ipv6.c      |  3 ++-
 net/ipv6/netfilter/nft_reject_ipv6.c     |  6 +++---
 net/netfilter/nf_dup_netdev.c            |  2 +-
 net/netfilter/nf_tables_core.c           | 10 ++++-----
 net/netfilter/nf_tables_trace.c          |  8 ++++----
 net/netfilter/nft_fib.c                  |  2 +-
 net/netfilter/nft_fib_inet.c             |  2 +-
 net/netfilter/nft_log.c                  |  5 +++--
 net/netfilter/nft_lookup.c               |  5 ++---
 net/netfilter/nft_meta.c                 |  6 +++---
 net/netfilter/nft_queue.c                |  2 +-
 net/netfilter/nft_reject_inet.c          | 18 ++++++++--------
 net/netfilter/nft_rt.c                   |  4 ++--
 24 files changed, 105 insertions(+), 83 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 44060344f958..3295fb85bff6 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -14,27 +14,42 @@
 
 struct nft_pktinfo {
 	struct sk_buff			*skb;
-	struct net			*net;
-	const struct net_device		*in;
-	const struct net_device		*out;
-	u8				pf;
-	u8				hook;
 	bool				tprot_set;
 	u8				tprot;
 	/* for x_tables compatibility */
 	struct xt_action_param		xt;
 };
 
+static inline struct net *nft_net(const struct nft_pktinfo *pkt)
+{
+	return pkt->xt.state->net;
+}
+
+static inline unsigned int nft_hook(const struct nft_pktinfo *pkt)
+{
+	return pkt->xt.state->hook;
+}
+
+static inline u8 nft_pf(const struct nft_pktinfo *pkt)
+{
+	return pkt->xt.state->pf;
+}
+
+static inline const struct net_device *nft_in(const struct nft_pktinfo *pkt)
+{
+	return pkt->xt.state->in;
+}
+
+static inline const struct net_device *nft_out(const struct nft_pktinfo *pkt)
+{
+	return pkt->xt.state->out;
+}
+
 static inline void nft_set_pktinfo(struct nft_pktinfo *pkt,
 				   struct sk_buff *skb,
 				   const struct nf_hook_state *state)
 {
 	pkt->skb = skb;
-	pkt->net = state->net;
-	pkt->in = state->in;
-	pkt->out = state->out;
-	pkt->hook = state->hook;
-	pkt->pf = state->pf;
 	pkt->xt.state = state;
 }
 
diff --git a/net/bridge/netfilter/nft_meta_bridge.c b/net/bridge/netfilter/nft_meta_bridge.c
index ad47a921b701..5974dbc1ea24 100644
--- a/net/bridge/netfilter/nft_meta_bridge.c
+++ b/net/bridge/netfilter/nft_meta_bridge.c
@@ -23,7 +23,7 @@ static void nft_meta_bridge_get_eval(const struct nft_expr *expr,
 				     const struct nft_pktinfo *pkt)
 {
 	const struct nft_meta *priv = nft_expr_priv(expr);
-	const struct net_device *in = pkt->in, *out = pkt->out;
+	const struct net_device *in = nft_in(pkt), *out = nft_out(pkt);
 	u32 *dest = &regs->data[priv->dreg];
 	const struct net_bridge_port *p;
 
diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index 4b3df6b0e3b9..206dc266ecd2 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -315,17 +315,20 @@ static void nft_reject_bridge_eval(const struct nft_expr *expr,
 	case htons(ETH_P_IP):
 		switch (priv->type) {
 		case NFT_REJECT_ICMP_UNREACH:
-			nft_reject_br_send_v4_unreach(pkt->net, pkt->skb,
-						      pkt->in, pkt->hook,
+			nft_reject_br_send_v4_unreach(nft_net(pkt), pkt->skb,
+						      nft_in(pkt),
+						      nft_hook(pkt),
 						      priv->icmp_code);
 			break;
 		case NFT_REJECT_TCP_RST:
-			nft_reject_br_send_v4_tcp_reset(pkt->net, pkt->skb,
-							pkt->in, pkt->hook);
+			nft_reject_br_send_v4_tcp_reset(nft_net(pkt), pkt->skb,
+							nft_in(pkt),
+							nft_hook(pkt));
 			break;
 		case NFT_REJECT_ICMPX_UNREACH:
-			nft_reject_br_send_v4_unreach(pkt->net, pkt->skb,
-						      pkt->in, pkt->hook,
+			nft_reject_br_send_v4_unreach(nft_net(pkt), pkt->skb,
+						      nft_in(pkt),
+						      nft_hook(pkt),
 						      nft_reject_icmp_code(priv->icmp_code));
 			break;
 		}
@@ -333,17 +336,20 @@ static void nft_reject_bridge_eval(const struct nft_expr *expr,
 	case htons(ETH_P_IPV6):
 		switch (priv->type) {
 		case NFT_REJECT_ICMP_UNREACH:
-			nft_reject_br_send_v6_unreach(pkt->net, pkt->skb,
-						      pkt->in, pkt->hook,
+			nft_reject_br_send_v6_unreach(nft_net(pkt), pkt->skb,
+						      nft_in(pkt),
+						      nft_hook(pkt),
 						      priv->icmp_code);
 			break;
 		case NFT_REJECT_TCP_RST:
-			nft_reject_br_send_v6_tcp_reset(pkt->net, pkt->skb,
-							pkt->in, pkt->hook);
+			nft_reject_br_send_v6_tcp_reset(nft_net(pkt), pkt->skb,
+							nft_in(pkt),
+							nft_hook(pkt));
 			break;
 		case NFT_REJECT_ICMPX_UNREACH:
-			nft_reject_br_send_v6_unreach(pkt->net, pkt->skb,
-						      pkt->in, pkt->hook,
+			nft_reject_br_send_v6_unreach(nft_net(pkt), pkt->skb,
+						      nft_in(pkt),
+						      nft_hook(pkt),
 						      nft_reject_icmpv6_code(priv->icmp_code));
 			break;
 		}
diff --git a/net/ipv4/netfilter/nft_dup_ipv4.c b/net/ipv4/netfilter/nft_dup_ipv4.c
index bf855e64fc45..7ab544fbc382 100644
--- a/net/ipv4/netfilter/nft_dup_ipv4.c
+++ b/net/ipv4/netfilter/nft_dup_ipv4.c
@@ -30,7 +30,7 @@ static void nft_dup_ipv4_eval(const struct nft_expr *expr,
 	};
 	int oif = regs->data[priv->sreg_dev];
 
-	nf_dup_ipv4(pkt->net, pkt->skb, pkt->hook, &gw, oif);
+	nf_dup_ipv4(nft_net(pkt), pkt->skb, nft_hook(pkt), &gw, oif);
 }
 
 static int nft_dup_ipv4_init(const struct nft_ctx *ctx,
diff --git a/net/ipv4/netfilter/nft_fib_ipv4.c b/net/ipv4/netfilter/nft_fib_ipv4.c
index db91fd42db67..1b49966484b3 100644
--- a/net/ipv4/netfilter/nft_fib_ipv4.c
+++ b/net/ipv4/netfilter/nft_fib_ipv4.c
@@ -45,9 +45,9 @@ void nft_fib4_eval_type(const struct nft_expr *expr, struct nft_regs *regs,
 	__be32 addr;
 
 	if (priv->flags & NFTA_FIB_F_IIF)
-		dev = pkt->in;
+		dev = nft_in(pkt);
 	else if (priv->flags & NFTA_FIB_F_OIF)
-		dev = pkt->out;
+		dev = nft_out(pkt);
 
 	iph = ip_hdr(pkt->skb);
 	if (priv->flags & NFTA_FIB_F_DADDR)
@@ -55,7 +55,7 @@ void nft_fib4_eval_type(const struct nft_expr *expr, struct nft_regs *regs,
 	else
 		addr = iph->saddr;
 
-	*dst = inet_dev_addr_type(pkt->net, dev, addr);
+	*dst = inet_dev_addr_type(nft_net(pkt), dev, addr);
 }
 EXPORT_SYMBOL_GPL(nft_fib4_eval_type);
 
@@ -89,13 +89,13 @@ void nft_fib4_eval(const struct nft_expr *expr, struct nft_regs *regs,
 	 * Search results for the desired outinterface instead.
 	 */
 	if (priv->flags & NFTA_FIB_F_OIF)
-		oif = pkt->out;
+		oif = nft_out(pkt);
 	else if (priv->flags & NFTA_FIB_F_IIF)
-		oif = pkt->in;
+		oif = nft_in(pkt);
 	else
 		oif = NULL;
 
-	if (pkt->hook == NF_INET_PRE_ROUTING && fib4_is_local(pkt->skb)) {
+	if (nft_hook(pkt) == NF_INET_PRE_ROUTING && fib4_is_local(pkt->skb)) {
 		nft_fib_store_result(dest, priv->result, pkt, LOOPBACK_IFINDEX);
 		return;
 	}
@@ -122,7 +122,7 @@ void nft_fib4_eval(const struct nft_expr *expr, struct nft_regs *regs,
 		fl4.saddr = get_saddr(iph->daddr);
 	}
 
-	if (fib_lookup(pkt->net, &fl4, &res, FIB_LOOKUP_IGNORE_LINKSTATE))
+	if (fib_lookup(nft_net(pkt), &fl4, &res, FIB_LOOKUP_IGNORE_LINKSTATE))
 		return;
 
 	switch (res.type) {
diff --git a/net/ipv4/netfilter/nft_masq_ipv4.c b/net/ipv4/netfilter/nft_masq_ipv4.c
index 51ced81b616c..4f697e431811 100644
--- a/net/ipv4/netfilter/nft_masq_ipv4.c
+++ b/net/ipv4/netfilter/nft_masq_ipv4.c
@@ -31,8 +31,8 @@ static void nft_masq_ipv4_eval(const struct nft_expr *expr,
 		range.max_proto.all =
 			*(__be16 *)&regs->data[priv->sreg_proto_max];
 	}
-	regs->verdict.code = nf_nat_masquerade_ipv4(pkt->skb, pkt->hook,
-						    &range, pkt->out);
+	regs->verdict.code = nf_nat_masquerade_ipv4(pkt->skb, nft_hook(pkt),
+						    &range, nft_out(pkt));
 }
 
 static struct nft_expr_type nft_masq_ipv4_type;
diff --git a/net/ipv4/netfilter/nft_redir_ipv4.c b/net/ipv4/netfilter/nft_redir_ipv4.c
index c09d4381427e..16df0493c5ce 100644
--- a/net/ipv4/netfilter/nft_redir_ipv4.c
+++ b/net/ipv4/netfilter/nft_redir_ipv4.c
@@ -35,8 +35,7 @@ static void nft_redir_ipv4_eval(const struct nft_expr *expr,
 
 	mr.range[0].flags |= priv->flags;
 
-	regs->verdict.code = nf_nat_redirect_ipv4(pkt->skb, &mr,
-						  pkt->hook);
+	regs->verdict.code = nf_nat_redirect_ipv4(pkt->skb, &mr, nft_hook(pkt));
 }
 
 static struct nft_expr_type nft_redir_ipv4_type;
diff --git a/net/ipv4/netfilter/nft_reject_ipv4.c b/net/ipv4/netfilter/nft_reject_ipv4.c
index 2c2553b9026c..517ce93699de 100644
--- a/net/ipv4/netfilter/nft_reject_ipv4.c
+++ b/net/ipv4/netfilter/nft_reject_ipv4.c
@@ -27,10 +27,10 @@ static void nft_reject_ipv4_eval(const struct nft_expr *expr,
 
 	switch (priv->type) {
 	case NFT_REJECT_ICMP_UNREACH:
-		nf_send_unreach(pkt->skb, priv->icmp_code, pkt->hook);
+		nf_send_unreach(pkt->skb, priv->icmp_code, nft_hook(pkt));
 		break;
 	case NFT_REJECT_TCP_RST:
-		nf_send_reset(pkt->net, pkt->skb, pkt->hook);
+		nf_send_reset(nft_net(pkt), pkt->skb, nft_hook(pkt));
 		break;
 	default:
 		break;
diff --git a/net/ipv6/netfilter/nft_dup_ipv6.c b/net/ipv6/netfilter/nft_dup_ipv6.c
index 8bfd470cbe72..26074a8bada7 100644
--- a/net/ipv6/netfilter/nft_dup_ipv6.c
+++ b/net/ipv6/netfilter/nft_dup_ipv6.c
@@ -28,7 +28,7 @@ static void nft_dup_ipv6_eval(const struct nft_expr *expr,
 	struct in6_addr *gw = (struct in6_addr *)&regs->data[priv->sreg_addr];
 	int oif = regs->data[priv->sreg_dev];
 
-	nf_dup_ipv6(pkt->net, pkt->skb, pkt->hook, gw, oif);
+	nf_dup_ipv6(nft_net(pkt), pkt->skb, nft_hook(pkt), gw, oif);
 }
 
 static int nft_dup_ipv6_init(const struct nft_ctx *ctx,
diff --git a/net/ipv6/netfilter/nft_fib_ipv6.c b/net/ipv6/netfilter/nft_fib_ipv6.c
index ff1f1b6b4a4a..d526bb594956 100644
--- a/net/ipv6/netfilter/nft_fib_ipv6.c
+++ b/net/ipv6/netfilter/nft_fib_ipv6.c
@@ -80,17 +80,17 @@ static u32 __nft_fib6_eval_type(const struct nft_fib *priv,
 		return RTN_UNREACHABLE;
 
 	if (priv->flags & NFTA_FIB_F_IIF)
-		dev = pkt->in;
+		dev = nft_in(pkt);
 	else if (priv->flags & NFTA_FIB_F_OIF)
-		dev = pkt->out;
+		dev = nft_out(pkt);
 
 	nft_fib6_flowi_init(&fl6, priv, pkt, dev);
 
 	v6ops = nf_get_ipv6_ops();
-	if (dev && v6ops && v6ops->chk_addr(pkt->net, &fl6.daddr, dev, true))
+	if (dev && v6ops && v6ops->chk_addr(nft_net(pkt), &fl6.daddr, dev, true))
 		ret = RTN_LOCAL;
 
-	route_err = afinfo->route(pkt->net, (struct dst_entry **)&rt,
+	route_err = afinfo->route(nft_net(pkt), (struct dst_entry **)&rt,
 				  flowi6_to_flowi(&fl6), false);
 	if (route_err)
 		goto err;
@@ -158,20 +158,20 @@ void nft_fib6_eval(const struct nft_expr *expr, struct nft_regs *regs,
 	int lookup_flags;
 
 	if (priv->flags & NFTA_FIB_F_IIF)
-		oif = pkt->in;
+		oif = nft_in(pkt);
 	else if (priv->flags & NFTA_FIB_F_OIF)
-		oif = pkt->out;
+		oif = nft_out(pkt);
 
 	lookup_flags = nft_fib6_flowi_init(&fl6, priv, pkt, oif);
 
-	if (pkt->hook == NF_INET_PRE_ROUTING && fib6_is_local(pkt->skb)) {
+	if (nft_hook(pkt) == NF_INET_PRE_ROUTING && fib6_is_local(pkt->skb)) {
 		nft_fib_store_result(dest, priv->result, pkt, LOOPBACK_IFINDEX);
 		return;
 	}
 
 	*dest = 0;
  again:
-	rt = (void *)ip6_route_lookup(pkt->net, &fl6, lookup_flags);
+	rt = (void *)ip6_route_lookup(nft_net(pkt), &fl6, lookup_flags);
 	if (rt->dst.error)
 		goto put_rt_err;
 
diff --git a/net/ipv6/netfilter/nft_masq_ipv6.c b/net/ipv6/netfilter/nft_masq_ipv6.c
index 9597ffb74077..a2aff1277b40 100644
--- a/net/ipv6/netfilter/nft_masq_ipv6.c
+++ b/net/ipv6/netfilter/nft_masq_ipv6.c
@@ -32,7 +32,8 @@ static void nft_masq_ipv6_eval(const struct nft_expr *expr,
 		range.max_proto.all =
 			*(__be16 *)&regs->data[priv->sreg_proto_max];
 	}
-	regs->verdict.code = nf_nat_masquerade_ipv6(pkt->skb, &range, pkt->out);
+	regs->verdict.code = nf_nat_masquerade_ipv6(pkt->skb, &range,
+						    nft_out(pkt));
 }
 
 static struct nft_expr_type nft_masq_ipv6_type;
diff --git a/net/ipv6/netfilter/nft_redir_ipv6.c b/net/ipv6/netfilter/nft_redir_ipv6.c
index aca44e89a881..bfcd5af6bc15 100644
--- a/net/ipv6/netfilter/nft_redir_ipv6.c
+++ b/net/ipv6/netfilter/nft_redir_ipv6.c
@@ -35,7 +35,8 @@ static void nft_redir_ipv6_eval(const struct nft_expr *expr,
 
 	range.flags |= priv->flags;
 
-	regs->verdict.code = nf_nat_redirect_ipv6(pkt->skb, &range, pkt->hook);
+	regs->verdict.code =
+		nf_nat_redirect_ipv6(pkt->skb, &range, nft_hook(pkt));
 }
 
 static struct nft_expr_type nft_redir_ipv6_type;
diff --git a/net/ipv6/netfilter/nft_reject_ipv6.c b/net/ipv6/netfilter/nft_reject_ipv6.c
index 92bda9908bb9..057deeaff1cb 100644
--- a/net/ipv6/netfilter/nft_reject_ipv6.c
+++ b/net/ipv6/netfilter/nft_reject_ipv6.c
@@ -27,11 +27,11 @@ static void nft_reject_ipv6_eval(const struct nft_expr *expr,
 
 	switch (priv->type) {
 	case NFT_REJECT_ICMP_UNREACH:
-		nf_send_unreach6(pkt->net, pkt->skb, priv->icmp_code,
-				 pkt->hook);
+		nf_send_unreach6(nft_net(pkt), pkt->skb, priv->icmp_code,
+				 nft_hook(pkt));
 		break;
 	case NFT_REJECT_TCP_RST:
-		nf_send_reset6(pkt->net, pkt->skb, pkt->hook);
+		nf_send_reset6(nft_net(pkt), pkt->skb, nft_hook(pkt));
 		break;
 	default:
 		break;
diff --git a/net/netfilter/nf_dup_netdev.c b/net/netfilter/nf_dup_netdev.c
index 7ec69723940f..44ae986c383f 100644
--- a/net/netfilter/nf_dup_netdev.c
+++ b/net/netfilter/nf_dup_netdev.c
@@ -19,7 +19,7 @@ void nf_dup_netdev_egress(const struct nft_pktinfo *pkt, int oif)
 	struct net_device *dev;
 	struct sk_buff *skb;
 
-	dev = dev_get_by_index_rcu(pkt->net, oif);
+	dev = dev_get_by_index_rcu(nft_net(pkt), oif);
 	if (dev == NULL)
 		return;
 
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 70de32a6d5c0..b63b1edb76a6 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -53,10 +53,10 @@ static noinline void __nft_trace_packet(struct nft_traceinfo *info,
 
 	nft_trace_notify(info);
 
-	nf_log_trace(pkt->net, pkt->pf, pkt->hook, pkt->skb, pkt->in,
-		     pkt->out, &trace_loginfo, "TRACE: %s:%s:%s:%u ",
-		     chain->table->name, chain->name, comments[type],
-		     rulenum);
+	nf_log_trace(nft_net(pkt), nft_pf(pkt), nft_hook(pkt), pkt->skb,
+		     nft_in(pkt), nft_out(pkt), &trace_loginfo,
+		     "TRACE: %s:%s:%s:%u ",
+		     chain->table->name, chain->name, comments[type], rulenum);
 }
 
 static inline void nft_trace_packet(struct nft_traceinfo *info,
@@ -124,7 +124,7 @@ unsigned int
 nft_do_chain(struct nft_pktinfo *pkt, void *priv)
 {
 	const struct nft_chain *chain = priv, *basechain = chain;
-	const struct net *net = pkt->net;
+	const struct net *net = nft_net(pkt);
 	const struct nft_rule *rule;
 	const struct nft_expr *expr, *last;
 	struct nft_regs regs;
diff --git a/net/netfilter/nf_tables_trace.c b/net/netfilter/nf_tables_trace.c
index ab695f8e2d29..12eb9041dca2 100644
--- a/net/netfilter/nf_tables_trace.c
+++ b/net/netfilter/nf_tables_trace.c
@@ -171,7 +171,7 @@ void nft_trace_notify(struct nft_traceinfo *info)
 	unsigned int size;
 	int event = (NFNL_SUBSYS_NFTABLES << 8) | NFT_MSG_TRACE;
 
-	if (!nfnetlink_has_listeners(pkt->net, NFNLGRP_NFTRACE))
+	if (!nfnetlink_has_listeners(nft_net(pkt), NFNLGRP_NFTRACE))
 		return;
 
 	size = nlmsg_total_size(sizeof(struct nfgenmsg)) +
@@ -207,7 +207,7 @@ void nft_trace_notify(struct nft_traceinfo *info)
 	nfmsg->version		= NFNETLINK_V0;
 	nfmsg->res_id		= 0;
 
-	if (nla_put_be32(skb, NFTA_TRACE_NFPROTO, htonl(pkt->pf)))
+	if (nla_put_be32(skb, NFTA_TRACE_NFPROTO, htonl(nft_pf(pkt))))
 		goto nla_put_failure;
 
 	if (nla_put_be32(skb, NFTA_TRACE_TYPE, htonl(info->type)))
@@ -249,7 +249,7 @@ void nft_trace_notify(struct nft_traceinfo *info)
 		goto nla_put_failure;
 
 	if (!info->packet_dumped) {
-		if (nf_trace_fill_dev_info(skb, pkt->in, pkt->out))
+		if (nf_trace_fill_dev_info(skb, nft_in(pkt), nft_out(pkt)))
 			goto nla_put_failure;
 
 		if (nf_trace_fill_pkt_info(skb, pkt))
@@ -258,7 +258,7 @@ void nft_trace_notify(struct nft_traceinfo *info)
 	}
 
 	nlmsg_end(skb, nlh);
-	nfnetlink_send(skb, pkt->net, 0, NFNLGRP_NFTRACE, 0, GFP_ATOMIC);
+	nfnetlink_send(skb, nft_net(pkt), 0, NFNLGRP_NFTRACE, 0, GFP_ATOMIC);
 	return;
 
  nla_put_failure:
diff --git a/net/netfilter/nft_fib.c b/net/netfilter/nft_fib.c
index 4944a8b7f7a7..249c9b80c150 100644
--- a/net/netfilter/nft_fib.c
+++ b/net/netfilter/nft_fib.c
@@ -144,7 +144,7 @@ void nft_fib_store_result(void *reg, enum nft_fib_result r,
 		*dreg = index;
 		break;
 	case NFT_FIB_RESULT_OIFNAME:
-		dev = dev_get_by_index_rcu(pkt->net, index);
+		dev = dev_get_by_index_rcu(nft_net(pkt), index);
 		strncpy(reg, dev ? dev->name : "", IFNAMSIZ);
 		break;
 	default:
diff --git a/net/netfilter/nft_fib_inet.c b/net/netfilter/nft_fib_inet.c
index fe8943b572b7..9120fc7228f4 100644
--- a/net/netfilter/nft_fib_inet.c
+++ b/net/netfilter/nft_fib_inet.c
@@ -21,7 +21,7 @@ static void nft_fib_inet_eval(const struct nft_expr *expr,
 {
 	const struct nft_fib *priv = nft_expr_priv(expr);
 
-	switch (pkt->pf) {
+	switch (nft_pf(pkt)) {
 	case NFPROTO_IPV4:
 		switch (priv->result) {
 		case NFT_FIB_RESULT_OIF:
diff --git a/net/netfilter/nft_log.c b/net/netfilter/nft_log.c
index 1b01404bb33f..6271e40a3dd6 100644
--- a/net/netfilter/nft_log.c
+++ b/net/netfilter/nft_log.c
@@ -32,8 +32,9 @@ static void nft_log_eval(const struct nft_expr *expr,
 {
 	const struct nft_log *priv = nft_expr_priv(expr);
 
-	nf_log_packet(pkt->net, pkt->pf, pkt->hook, pkt->skb, pkt->in,
-		      pkt->out, &priv->loginfo, "%s", priv->prefix);
+	nf_log_packet(nft_net(pkt), nft_pf(pkt), nft_hook(pkt), pkt->skb,
+		      nft_in(pkt), nft_out(pkt), &priv->loginfo, "%s",
+		      priv->prefix);
 }
 
 static const struct nla_policy nft_log_policy[NFTA_LOG_MAX + 1] = {
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index 8166b6994cc7..a8ce49bcda80 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -35,9 +35,8 @@ static void nft_lookup_eval(const struct nft_expr *expr,
 	const struct nft_set_ext *ext;
 	bool found;
 
-	found = set->ops->lookup(pkt->net, set, &regs->data[priv->sreg], &ext) ^
-		priv->invert;
-
+	found = set->ops->lookup(nft_net(pkt), set, &regs->data[priv->sreg],
+				 &ext) ^ priv->invert;
 	if (!found) {
 		regs->verdict.code = NFT_BREAK;
 		return;
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 64994023bf81..66c7f4b4c49b 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -36,7 +36,7 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 {
 	const struct nft_meta *priv = nft_expr_priv(expr);
 	const struct sk_buff *skb = pkt->skb;
-	const struct net_device *in = pkt->in, *out = pkt->out;
+	const struct net_device *in = nft_in(pkt), *out = nft_out(pkt);
 	struct sock *sk;
 	u32 *dest = &regs->data[priv->dreg];
 
@@ -49,7 +49,7 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		*(__be16 *)dest = skb->protocol;
 		break;
 	case NFT_META_NFPROTO:
-		*dest = pkt->pf;
+		*dest = nft_pf(pkt);
 		break;
 	case NFT_META_L4PROTO:
 		if (!pkt->tprot_set)
@@ -146,7 +146,7 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 			break;
 		}
 
-		switch (pkt->pf) {
+		switch (nft_pf(pkt)) {
 		case NFPROTO_IPV4:
 			if (ipv4_is_multicast(ip_hdr(skb)->daddr))
 				*dest = PACKET_MULTICAST;
diff --git a/net/netfilter/nft_queue.c b/net/netfilter/nft_queue.c
index 393d359a1889..3e19fa1230dc 100644
--- a/net/netfilter/nft_queue.c
+++ b/net/netfilter/nft_queue.c
@@ -43,7 +43,7 @@ static void nft_queue_eval(const struct nft_expr *expr,
 			queue = priv->queuenum + cpu % priv->queues_total;
 		} else {
 			queue = nfqueue_hash(pkt->skb, queue,
-					     priv->queues_total, pkt->pf,
+					     priv->queues_total, nft_pf(pkt),
 					     jhash_initval);
 		}
 	}
diff --git a/net/netfilter/nft_reject_inet.c b/net/netfilter/nft_reject_inet.c
index e79d9ca2ffee..9e90a02cb104 100644
--- a/net/netfilter/nft_reject_inet.c
+++ b/net/netfilter/nft_reject_inet.c
@@ -23,36 +23,36 @@ static void nft_reject_inet_eval(const struct nft_expr *expr,
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
 
-	switch (pkt->pf) {
+	switch (nft_pf(pkt)) {
 	case NFPROTO_IPV4:
 		switch (priv->type) {
 		case NFT_REJECT_ICMP_UNREACH:
 			nf_send_unreach(pkt->skb, priv->icmp_code,
-					pkt->hook);
+					nft_hook(pkt));
 			break;
 		case NFT_REJECT_TCP_RST:
-			nf_send_reset(pkt->net, pkt->skb, pkt->hook);
+			nf_send_reset(nft_net(pkt), pkt->skb, nft_hook(pkt));
 			break;
 		case NFT_REJECT_ICMPX_UNREACH:
 			nf_send_unreach(pkt->skb,
 					nft_reject_icmp_code(priv->icmp_code),
-					pkt->hook);
+					nft_hook(pkt));
 			break;
 		}
 		break;
 	case NFPROTO_IPV6:
 		switch (priv->type) {
 		case NFT_REJECT_ICMP_UNREACH:
-			nf_send_unreach6(pkt->net, pkt->skb, priv->icmp_code,
-					 pkt->hook);
+			nf_send_unreach6(nft_net(pkt), pkt->skb,
+					 priv->icmp_code, nft_hook(pkt));
 			break;
 		case NFT_REJECT_TCP_RST:
-			nf_send_reset6(pkt->net, pkt->skb, pkt->hook);
+			nf_send_reset6(nft_net(pkt), pkt->skb, nft_hook(pkt));
 			break;
 		case NFT_REJECT_ICMPX_UNREACH:
-			nf_send_unreach6(pkt->net, pkt->skb,
+			nf_send_unreach6(nft_net(pkt), pkt->skb,
 					 nft_reject_icmpv6_code(priv->icmp_code),
-					 pkt->hook);
+					 nft_hook(pkt));
 			break;
 		}
 		break;
diff --git a/net/netfilter/nft_rt.c b/net/netfilter/nft_rt.c
index 9e5ec1f67020..d3eb640bc784 100644
--- a/net/netfilter/nft_rt.c
+++ b/net/netfilter/nft_rt.c
@@ -43,14 +43,14 @@ void nft_rt_get_eval(const struct nft_expr *expr,
 		break;
 #endif
 	case NFT_RT_NEXTHOP4:
-		if (pkt->pf != NFPROTO_IPV4)
+		if (nft_pf(pkt) != NFPROTO_IPV4)
 			goto err;
 
 		*dest = rt_nexthop((const struct rtable *)dst,
 				   ip_hdr(skb)->daddr);
 		break;
 	case NFT_RT_NEXTHOP6:
-		if (pkt->pf != NFPROTO_IPV6)
+		if (nft_pf(pkt) != NFPROTO_IPV6)
 			goto err;
 
 		memcpy(dest, rt6_nexthop((struct rt6_info *)dst,
-- 
2.1.4
