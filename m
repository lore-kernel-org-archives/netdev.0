From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/30] netfilter: nf_tables: kill nft_pktinfo.ops
Date: Tue, 22 Sep 2015 11:14:09 +0200
Message-ID: <1442913260-3925-20-git-send-email-pablo@netfilter.org>
References: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35090 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757045AbbIVJH4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 05:07:56 -0400
In-Reply-To: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

- Add nft_pktinfo.pf to replace ops->pf
- Add nft_pktinfo.hook to replace ops->hooknum

This simplifies the code, makes it more readable, and likely reduces
cache line misses.  Maintainability is enhanced as the details of
nft_hook_ops are of no concern to the recpients of nft_pktinfo.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h         |    9 ++++-----
 include/net/netfilter/nf_tables_ipv4.h    |    3 +--
 include/net/netfilter/nf_tables_ipv6.h    |    3 +--
 net/bridge/netfilter/nf_tables_bridge.c   |   16 +++++++---------
 net/bridge/netfilter/nft_reject_bridge.c  |   12 ++++++------
 net/ipv4/netfilter/nf_tables_arp.c        |    2 +-
 net/ipv4/netfilter/nf_tables_ipv4.c       |    2 +-
 net/ipv4/netfilter/nft_chain_nat_ipv4.c   |    2 +-
 net/ipv4/netfilter/nft_chain_route_ipv4.c |    2 +-
 net/ipv4/netfilter/nft_dup_ipv4.c         |    2 +-
 net/ipv4/netfilter/nft_masq_ipv4.c        |    2 +-
 net/ipv4/netfilter/nft_redir_ipv4.c       |    2 +-
 net/ipv4/netfilter/nft_reject_ipv4.c      |    5 ++---
 net/ipv6/netfilter/nf_tables_ipv6.c       |    2 +-
 net/ipv6/netfilter/nft_chain_nat_ipv6.c   |    2 +-
 net/ipv6/netfilter/nft_chain_route_ipv6.c |    2 +-
 net/ipv6/netfilter/nft_dup_ipv6.c         |    2 +-
 net/ipv6/netfilter/nft_redir_ipv6.c       |    3 +--
 net/ipv6/netfilter/nft_reject_ipv6.c      |    5 ++---
 net/netfilter/nf_tables_core.c            |    2 +-
 net/netfilter/nf_tables_netdev.c          |   16 +++++++---------
 net/netfilter/nft_log.c                   |    2 +-
 net/netfilter/nft_meta.c                  |    4 ++--
 net/netfilter/nft_queue.c                 |    2 +-
 net/netfilter/nft_reject_inet.c           |   14 +++++++-------
 25 files changed, 54 insertions(+), 64 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index aa8bee7..c0899f9 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -16,7 +16,8 @@ struct nft_pktinfo {
 	struct sk_buff			*skb;
 	const struct net_device		*in;
 	const struct net_device		*out;
-	const struct nf_hook_ops	*ops;
+	u8				pf;
+	u8				hook;
 	u8				nhoff;
 	u8				thoff;
 	u8				tprot;
@@ -25,16 +26,14 @@ struct nft_pktinfo {
 };
 
 static inline void nft_set_pktinfo(struct nft_pktinfo *pkt,
-				   const struct nf_hook_ops *ops,
 				   struct sk_buff *skb,
 				   const struct nf_hook_state *state)
 {
 	pkt->skb = skb;
 	pkt->in = pkt->xt.in = state->in;
 	pkt->out = pkt->xt.out = state->out;
-	pkt->ops = ops;
-	pkt->xt.hooknum = ops->hooknum;
-	pkt->xt.family = ops->pf;
+	pkt->hook = pkt->xt.hooknum = state->hook;
+	pkt->pf = pkt->xt.family = state->pf;
 }
 
 /**
diff --git a/include/net/netfilter/nf_tables_ipv4.h b/include/net/netfilter/nf_tables_ipv4.h
index 2df7f96..ca6ef6b 100644
--- a/include/net/netfilter/nf_tables_ipv4.h
+++ b/include/net/netfilter/nf_tables_ipv4.h
@@ -6,13 +6,12 @@
 
 static inline void
 nft_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
-		     const struct nf_hook_ops *ops,
 		     struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
 	struct iphdr *ip;
 
-	nft_set_pktinfo(pkt, ops, skb, state);
+	nft_set_pktinfo(pkt, skb, state);
 
 	ip = ip_hdr(pkt->skb);
 	pkt->tprot = ip->protocol;
diff --git a/include/net/netfilter/nf_tables_ipv6.h b/include/net/netfilter/nf_tables_ipv6.h
index 97db2e3..8ad39a6 100644
--- a/include/net/netfilter/nf_tables_ipv6.h
+++ b/include/net/netfilter/nf_tables_ipv6.h
@@ -6,14 +6,13 @@
 
 static inline int
 nft_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
-		     const struct nf_hook_ops *ops,
 		     struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
 	int protohdr, thoff = 0;
 	unsigned short frag_off;
 
-	nft_set_pktinfo(pkt, ops, skb, state);
+	nft_set_pktinfo(pkt, skb, state);
 
 	protohdr = ipv6_find_hdr(pkt->skb, &thoff, -1, &frag_off, NULL);
 	/* If malformed, drop it */
diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index a343e62..318d825 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -65,27 +65,25 @@ int nft_bridge_ip6hdr_validate(struct sk_buff *skb)
 EXPORT_SYMBOL_GPL(nft_bridge_ip6hdr_validate);
 
 static inline void nft_bridge_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
-					       const struct nf_hook_ops *ops,
 					       struct sk_buff *skb,
 					       const struct nf_hook_state *state)
 {
 	if (nft_bridge_iphdr_validate(skb))
-		nft_set_pktinfo_ipv4(pkt, ops, skb, state);
+		nft_set_pktinfo_ipv4(pkt, skb, state);
 	else
-		nft_set_pktinfo(pkt, ops, skb, state);
+		nft_set_pktinfo(pkt, skb, state);
 }
 
 static inline void nft_bridge_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
-					       const struct nf_hook_ops *ops,
 					       struct sk_buff *skb,
 					       const struct nf_hook_state *state)
 {
 #if IS_ENABLED(CONFIG_IPV6)
 	if (nft_bridge_ip6hdr_validate(skb) &&
-	    nft_set_pktinfo_ipv6(pkt, ops, skb, state) == 0)
+	    nft_set_pktinfo_ipv6(pkt, skb, state) == 0)
 		return;
 #endif
-	nft_set_pktinfo(pkt, ops, skb, state);
+	nft_set_pktinfo(pkt, skb, state);
 }
 
 static unsigned int
@@ -97,13 +95,13 @@ nft_do_chain_bridge(const struct nf_hook_ops *ops,
 
 	switch (eth_hdr(skb)->h_proto) {
 	case htons(ETH_P_IP):
-		nft_bridge_set_pktinfo_ipv4(&pkt, ops, skb, state);
+		nft_bridge_set_pktinfo_ipv4(&pkt, skb, state);
 		break;
 	case htons(ETH_P_IPV6):
-		nft_bridge_set_pktinfo_ipv6(&pkt, ops, skb, state);
+		nft_bridge_set_pktinfo_ipv6(&pkt, skb, state);
 		break;
 	default:
-		nft_set_pktinfo(&pkt, ops, skb, state);
+		nft_set_pktinfo(&pkt, skb, state);
 		break;
 	}
 
diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index 858d848..cee9261 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -273,16 +273,16 @@ static void nft_reject_bridge_eval(const struct nft_expr *expr,
 		switch (priv->type) {
 		case NFT_REJECT_ICMP_UNREACH:
 			nft_reject_br_send_v4_unreach(pkt->skb, pkt->in,
-						      pkt->ops->hooknum,
+						      pkt->hook,
 						      priv->icmp_code);
 			break;
 		case NFT_REJECT_TCP_RST:
 			nft_reject_br_send_v4_tcp_reset(pkt->skb, pkt->in,
-							pkt->ops->hooknum);
+							pkt->hook);
 			break;
 		case NFT_REJECT_ICMPX_UNREACH:
 			nft_reject_br_send_v4_unreach(pkt->skb, pkt->in,
-						      pkt->ops->hooknum,
+						      pkt->hook,
 						      nft_reject_icmp_code(priv->icmp_code));
 			break;
 		}
@@ -291,16 +291,16 @@ static void nft_reject_bridge_eval(const struct nft_expr *expr,
 		switch (priv->type) {
 		case NFT_REJECT_ICMP_UNREACH:
 			nft_reject_br_send_v6_unreach(net, pkt->skb, pkt->in,
-						      pkt->ops->hooknum,
+						      pkt->hook,
 						      priv->icmp_code);
 			break;
 		case NFT_REJECT_TCP_RST:
 			nft_reject_br_send_v6_tcp_reset(net, pkt->skb, pkt->in,
-							pkt->ops->hooknum);
+							pkt->hook);
 			break;
 		case NFT_REJECT_ICMPX_UNREACH:
 			nft_reject_br_send_v6_unreach(net, pkt->skb, pkt->in,
-						      pkt->ops->hooknum,
+						      pkt->hook,
 						      nft_reject_icmpv6_code(priv->icmp_code));
 			break;
 		}
diff --git a/net/ipv4/netfilter/nf_tables_arp.c b/net/ipv4/netfilter/nf_tables_arp.c
index 8412268..883bbf8 100644
--- a/net/ipv4/netfilter/nf_tables_arp.c
+++ b/net/ipv4/netfilter/nf_tables_arp.c
@@ -21,7 +21,7 @@ nft_do_chain_arp(const struct nf_hook_ops *ops,
 {
 	struct nft_pktinfo pkt;
 
-	nft_set_pktinfo(&pkt, ops, skb, state);
+	nft_set_pktinfo(&pkt, skb, state);
 
 	return nft_do_chain(&pkt, ops);
 }
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index aa180d3..805be5c 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -24,7 +24,7 @@ static unsigned int nft_do_chain_ipv4(const struct nf_hook_ops *ops,
 {
 	struct nft_pktinfo pkt;
 
-	nft_set_pktinfo_ipv4(&pkt, ops, skb, state);
+	nft_set_pktinfo_ipv4(&pkt, skb, state);
 
 	return nft_do_chain(&pkt, ops);
 }
diff --git a/net/ipv4/netfilter/nft_chain_nat_ipv4.c b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
index bf5c30a..c3ffecf 100644
--- a/net/ipv4/netfilter/nft_chain_nat_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
@@ -33,7 +33,7 @@ static unsigned int nft_nat_do_chain(const struct nf_hook_ops *ops,
 {
 	struct nft_pktinfo pkt;
 
-	nft_set_pktinfo_ipv4(&pkt, ops, skb, state);
+	nft_set_pktinfo_ipv4(&pkt, skb, state);
 
 	return nft_do_chain(&pkt, ops);
 }
diff --git a/net/ipv4/netfilter/nft_chain_route_ipv4.c b/net/ipv4/netfilter/nft_chain_route_ipv4.c
index e335b0a..2a1e3d8 100644
--- a/net/ipv4/netfilter/nft_chain_route_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_route_ipv4.c
@@ -37,7 +37,7 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	nft_set_pktinfo_ipv4(&pkt, ops, skb, state);
+	nft_set_pktinfo_ipv4(&pkt, skb, state);
 
 	mark = skb->mark;
 	iph = ip_hdr(skb);
diff --git a/net/ipv4/netfilter/nft_dup_ipv4.c b/net/ipv4/netfilter/nft_dup_ipv4.c
index b45932d..30bcf82 100644
--- a/net/ipv4/netfilter/nft_dup_ipv4.c
+++ b/net/ipv4/netfilter/nft_dup_ipv4.c
@@ -30,7 +30,7 @@ static void nft_dup_ipv4_eval(const struct nft_expr *expr,
 	};
 	int oif = regs->data[priv->sreg_dev];
 
-	nf_dup_ipv4(pkt->skb, pkt->ops->hooknum, &gw, oif);
+	nf_dup_ipv4(pkt->skb, pkt->hook, &gw, oif);
 }
 
 static int nft_dup_ipv4_init(const struct nft_ctx *ctx,
diff --git a/net/ipv4/netfilter/nft_masq_ipv4.c b/net/ipv4/netfilter/nft_masq_ipv4.c
index 40e414c..b72ffc5 100644
--- a/net/ipv4/netfilter/nft_masq_ipv4.c
+++ b/net/ipv4/netfilter/nft_masq_ipv4.c
@@ -26,7 +26,7 @@ static void nft_masq_ipv4_eval(const struct nft_expr *expr,
 	memset(&range, 0, sizeof(range));
 	range.flags = priv->flags;
 
-	regs->verdict.code = nf_nat_masquerade_ipv4(pkt->skb, pkt->ops->hooknum,
+	regs->verdict.code = nf_nat_masquerade_ipv4(pkt->skb, pkt->hook,
 						    &range, pkt->out);
 }
 
diff --git a/net/ipv4/netfilter/nft_redir_ipv4.c b/net/ipv4/netfilter/nft_redir_ipv4.c
index d8d795d..c09d438 100644
--- a/net/ipv4/netfilter/nft_redir_ipv4.c
+++ b/net/ipv4/netfilter/nft_redir_ipv4.c
@@ -36,7 +36,7 @@ static void nft_redir_ipv4_eval(const struct nft_expr *expr,
 	mr.range[0].flags |= priv->flags;
 
 	regs->verdict.code = nf_nat_redirect_ipv4(pkt->skb, &mr,
-						  pkt->ops->hooknum);
+						  pkt->hook);
 }
 
 static struct nft_expr_type nft_redir_ipv4_type;
diff --git a/net/ipv4/netfilter/nft_reject_ipv4.c b/net/ipv4/netfilter/nft_reject_ipv4.c
index b07e58b..c1582e0 100644
--- a/net/ipv4/netfilter/nft_reject_ipv4.c
+++ b/net/ipv4/netfilter/nft_reject_ipv4.c
@@ -27,11 +27,10 @@ static void nft_reject_ipv4_eval(const struct nft_expr *expr,
 
 	switch (priv->type) {
 	case NFT_REJECT_ICMP_UNREACH:
-		nf_send_unreach(pkt->skb, priv->icmp_code,
-				pkt->ops->hooknum);
+		nf_send_unreach(pkt->skb, priv->icmp_code, pkt->hook);
 		break;
 	case NFT_REJECT_TCP_RST:
-		nf_send_reset(pkt->skb, pkt->ops->hooknum);
+		nf_send_reset(pkt->skb, pkt->hook);
 		break;
 	default:
 		break;
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index c8148ba..41340b7 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -23,7 +23,7 @@ static unsigned int nft_do_chain_ipv6(const struct nf_hook_ops *ops,
 	struct nft_pktinfo pkt;
 
 	/* malformed packet, drop it */
-	if (nft_set_pktinfo_ipv6(&pkt, ops, skb, state) < 0)
+	if (nft_set_pktinfo_ipv6(&pkt, skb, state) < 0)
 		return NF_DROP;
 
 	return nft_do_chain(&pkt, ops);
diff --git a/net/ipv6/netfilter/nft_chain_nat_ipv6.c b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
index 951bb45..e96feaef 100644
--- a/net/ipv6/netfilter/nft_chain_nat_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
@@ -31,7 +31,7 @@ static unsigned int nft_nat_do_chain(const struct nf_hook_ops *ops,
 {
 	struct nft_pktinfo pkt;
 
-	nft_set_pktinfo_ipv6(&pkt, ops, skb, state);
+	nft_set_pktinfo_ipv6(&pkt, skb, state);
 
 	return nft_do_chain(&pkt, ops);
 }
diff --git a/net/ipv6/netfilter/nft_chain_route_ipv6.c b/net/ipv6/netfilter/nft_chain_route_ipv6.c
index 0dafdaa..d1bcd2e 100644
--- a/net/ipv6/netfilter/nft_chain_route_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_route_ipv6.c
@@ -33,7 +33,7 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 	u32 mark, flowlabel;
 
 	/* malformed packet, drop it */
-	if (nft_set_pktinfo_ipv6(&pkt, ops, skb, state) < 0)
+	if (nft_set_pktinfo_ipv6(&pkt, skb, state) < 0)
 		return NF_DROP;
 
 	/* save source/dest address, mark, hoplimit, flowlabel, priority */
diff --git a/net/ipv6/netfilter/nft_dup_ipv6.c b/net/ipv6/netfilter/nft_dup_ipv6.c
index 0eaa4f6..c81204f 100644
--- a/net/ipv6/netfilter/nft_dup_ipv6.c
+++ b/net/ipv6/netfilter/nft_dup_ipv6.c
@@ -28,7 +28,7 @@ static void nft_dup_ipv6_eval(const struct nft_expr *expr,
 	struct in6_addr *gw = (struct in6_addr *)&regs->data[priv->sreg_addr];
 	int oif = regs->data[priv->sreg_dev];
 
-	nf_dup_ipv6(pkt->skb, pkt->ops->hooknum, gw, oif);
+	nf_dup_ipv6(pkt->skb, pkt->hook, gw, oif);
 }
 
 static int nft_dup_ipv6_init(const struct nft_ctx *ctx,
diff --git a/net/ipv6/netfilter/nft_redir_ipv6.c b/net/ipv6/netfilter/nft_redir_ipv6.c
index effd393..aca44e8 100644
--- a/net/ipv6/netfilter/nft_redir_ipv6.c
+++ b/net/ipv6/netfilter/nft_redir_ipv6.c
@@ -35,8 +35,7 @@ static void nft_redir_ipv6_eval(const struct nft_expr *expr,
 
 	range.flags |= priv->flags;
 
-	regs->verdict.code = nf_nat_redirect_ipv6(pkt->skb, &range,
-						  pkt->ops->hooknum);
+	regs->verdict.code = nf_nat_redirect_ipv6(pkt->skb, &range, pkt->hook);
 }
 
 static struct nft_expr_type nft_redir_ipv6_type;
diff --git a/net/ipv6/netfilter/nft_reject_ipv6.c b/net/ipv6/netfilter/nft_reject_ipv6.c
index d0d1540..ffcac7d 100644
--- a/net/ipv6/netfilter/nft_reject_ipv6.c
+++ b/net/ipv6/netfilter/nft_reject_ipv6.c
@@ -28,11 +28,10 @@ static void nft_reject_ipv6_eval(const struct nft_expr *expr,
 
 	switch (priv->type) {
 	case NFT_REJECT_ICMP_UNREACH:
-		nf_send_unreach6(net, pkt->skb, priv->icmp_code,
-				 pkt->ops->hooknum);
+		nf_send_unreach6(net, pkt->skb, priv->icmp_code, pkt->hook);
 		break;
 	case NFT_REJECT_TCP_RST:
-		nf_send_reset6(net, pkt->skb, pkt->ops->hooknum);
+		nf_send_reset6(net, pkt->skb, pkt->hook);
 		break;
 	default:
 		break;
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 05d0b03..5390830 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -50,7 +50,7 @@ static void __nft_trace_packet(const struct nft_pktinfo *pkt,
 {
 	struct net *net = dev_net(pkt->in ? pkt->in : pkt->out);
 
-	nf_log_trace(net, pkt->xt.family, pkt->ops->hooknum, pkt->skb, pkt->in,
+	nf_log_trace(net, pkt->pf, pkt->hook, pkt->skb, pkt->in,
 		     pkt->out, &trace_loginfo, "TRACE: %s:%s:%s:%u ",
 		     chain->table->name, chain->name, comments[type],
 		     rulenum);
diff --git a/net/netfilter/nf_tables_netdev.c b/net/netfilter/nf_tables_netdev.c
index 2cae4d4..db416a3 100644
--- a/net/netfilter/nf_tables_netdev.c
+++ b/net/netfilter/nf_tables_netdev.c
@@ -17,13 +17,13 @@
 
 static inline void
 nft_netdev_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
-			    const struct nf_hook_ops *ops, struct sk_buff *skb,
+			    struct sk_buff *skb,
 			    const struct nf_hook_state *state)
 {
 	struct iphdr *iph, _iph;
 	u32 len, thoff;
 
-	nft_set_pktinfo(pkt, ops, skb, state);
+	nft_set_pktinfo(pkt, skb, state);
 
 	iph = skb_header_pointer(skb, skb_network_offset(skb), sizeof(*iph),
 				 &_iph);
@@ -48,7 +48,6 @@ nft_netdev_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
 
 static inline void
 __nft_netdev_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
-			      const struct nf_hook_ops *ops,
 			      struct sk_buff *skb,
 			      const struct nf_hook_state *state)
 {
@@ -82,12 +81,11 @@ __nft_netdev_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
 }
 
 static inline void nft_netdev_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
-					       const struct nf_hook_ops *ops,
 					       struct sk_buff *skb,
 					       const struct nf_hook_state *state)
 {
-	nft_set_pktinfo(pkt, ops, skb, state);
-	__nft_netdev_set_pktinfo_ipv6(pkt, ops, skb, state);
+	nft_set_pktinfo(pkt, skb, state);
+	__nft_netdev_set_pktinfo_ipv6(pkt, skb, state);
 }
 
 static unsigned int
@@ -98,13 +96,13 @@ nft_do_chain_netdev(const struct nf_hook_ops *ops, struct sk_buff *skb,
 
 	switch (eth_hdr(skb)->h_proto) {
 	case htons(ETH_P_IP):
-		nft_netdev_set_pktinfo_ipv4(&pkt, ops, skb, state);
+		nft_netdev_set_pktinfo_ipv4(&pkt, skb, state);
 		break;
 	case htons(ETH_P_IPV6):
-		nft_netdev_set_pktinfo_ipv6(&pkt, ops, skb, state);
+		nft_netdev_set_pktinfo_ipv6(&pkt, skb, state);
 		break;
 	default:
-		nft_set_pktinfo(&pkt, ops, skb, state);
+		nft_set_pktinfo(&pkt, skb, state);
 		break;
 	}
 
diff --git a/net/netfilter/nft_log.c b/net/netfilter/nft_log.c
index a13d6a3..c7c7df8 100644
--- a/net/netfilter/nft_log.c
+++ b/net/netfilter/nft_log.c
@@ -33,7 +33,7 @@ static void nft_log_eval(const struct nft_expr *expr,
 	const struct nft_log *priv = nft_expr_priv(expr);
 	struct net *net = dev_net(pkt->in ? pkt->in : pkt->out);
 
-	nf_log_packet(net, pkt->ops->pf, pkt->ops->hooknum, pkt->skb, pkt->in,
+	nf_log_packet(net, pkt->pf, pkt->hook, pkt->skb, pkt->in,
 		      pkt->out, &priv->loginfo, "%s", priv->prefix);
 }
 
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index cb2f13e..e4ad2c2 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -42,7 +42,7 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		*(__be16 *)dest = skb->protocol;
 		break;
 	case NFT_META_NFPROTO:
-		*dest = pkt->ops->pf;
+		*dest = pkt->pf;
 		break;
 	case NFT_META_L4PROTO:
 		*dest = pkt->tprot;
@@ -135,7 +135,7 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 			break;
 		}
 
-		switch (pkt->ops->pf) {
+		switch (pkt->pf) {
 		case NFPROTO_IPV4:
 			if (ipv4_is_multicast(ip_hdr(skb)->daddr))
 				*dest = PACKET_MULTICAST;
diff --git a/net/netfilter/nft_queue.c b/net/netfilter/nft_queue.c
index 96805d2..61d216e 100644
--- a/net/netfilter/nft_queue.c
+++ b/net/netfilter/nft_queue.c
@@ -42,7 +42,7 @@ static void nft_queue_eval(const struct nft_expr *expr,
 			queue = priv->queuenum + cpu % priv->queues_total;
 		} else {
 			queue = nfqueue_hash(pkt->skb, queue,
-					     priv->queues_total, pkt->ops->pf,
+					     priv->queues_total, pkt->pf,
 					     jhash_initval);
 		}
 	}
diff --git a/net/netfilter/nft_reject_inet.c b/net/netfilter/nft_reject_inet.c
index 635dbba..dea6750 100644
--- a/net/netfilter/nft_reject_inet.c
+++ b/net/netfilter/nft_reject_inet.c
@@ -24,20 +24,20 @@ static void nft_reject_inet_eval(const struct nft_expr *expr,
 	struct nft_reject *priv = nft_expr_priv(expr);
 	struct net *net = dev_net((pkt->in != NULL) ? pkt->in : pkt->out);
 
-	switch (pkt->ops->pf) {
+	switch (pkt->pf) {
 	case NFPROTO_IPV4:
 		switch (priv->type) {
 		case NFT_REJECT_ICMP_UNREACH:
 			nf_send_unreach(pkt->skb, priv->icmp_code,
-					pkt->ops->hooknum);
+					pkt->hook);
 			break;
 		case NFT_REJECT_TCP_RST:
-			nf_send_reset(pkt->skb, pkt->ops->hooknum);
+			nf_send_reset(pkt->skb, pkt->hook);
 			break;
 		case NFT_REJECT_ICMPX_UNREACH:
 			nf_send_unreach(pkt->skb,
 					nft_reject_icmp_code(priv->icmp_code),
-					pkt->ops->hooknum);
+					pkt->hook);
 			break;
 		}
 		break;
@@ -45,15 +45,15 @@ static void nft_reject_inet_eval(const struct nft_expr *expr,
 		switch (priv->type) {
 		case NFT_REJECT_ICMP_UNREACH:
 			nf_send_unreach6(net, pkt->skb, priv->icmp_code,
-					 pkt->ops->hooknum);
+					 pkt->hook);
 			break;
 		case NFT_REJECT_TCP_RST:
-			nf_send_reset6(net, pkt->skb, pkt->ops->hooknum);
+			nf_send_reset6(net, pkt->skb, pkt->hook);
 			break;
 		case NFT_REJECT_ICMPX_UNREACH:
 			nf_send_unreach6(net, pkt->skb,
 					 nft_reject_icmpv6_code(priv->icmp_code),
-					 pkt->ops->hooknum);
+					 pkt->hook);
 			break;
 		}
 		break;
-- 
1.7.10.4
