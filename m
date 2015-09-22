From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 23/30] netfilter: nf_tables: Use pkt->net instead of computing net from the passed net_devices
Date: Tue, 22 Sep 2015 11:14:13 +0200
Message-ID: <1442913260-3925-24-git-send-email-pablo@netfilter.org>
References: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35180 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757755AbbIVJIC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 05:08:02 -0400
In-Reply-To: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/nft_reject_bridge.c |   13 ++++++-------
 net/ipv6/netfilter/nft_reject_ipv6.c     |    6 +++---
 net/netfilter/nf_tables_core.c           |    6 ++----
 net/netfilter/nft_log.c                  |    3 +--
 net/netfilter/nft_reject_inet.c          |    7 +++----
 5 files changed, 15 insertions(+), 20 deletions(-)

diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index cee9261..fdba3d9 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -261,7 +261,6 @@ static void nft_reject_bridge_eval(const struct nft_expr *expr,
 				   const struct nft_pktinfo *pkt)
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
-	struct net *net = dev_net((pkt->in != NULL) ? pkt->in : pkt->out);
 	const unsigned char *dest = eth_hdr(pkt->skb)->h_dest;
 
 	if (is_broadcast_ether_addr(dest) ||
@@ -290,17 +289,17 @@ static void nft_reject_bridge_eval(const struct nft_expr *expr,
 	case htons(ETH_P_IPV6):
 		switch (priv->type) {
 		case NFT_REJECT_ICMP_UNREACH:
-			nft_reject_br_send_v6_unreach(net, pkt->skb, pkt->in,
-						      pkt->hook,
+			nft_reject_br_send_v6_unreach(pkt->net, pkt->skb,
+						      pkt->in, pkt->hook,
 						      priv->icmp_code);
 			break;
 		case NFT_REJECT_TCP_RST:
-			nft_reject_br_send_v6_tcp_reset(net, pkt->skb, pkt->in,
-							pkt->hook);
+			nft_reject_br_send_v6_tcp_reset(pkt->net, pkt->skb,
+							pkt->in, pkt->hook);
 			break;
 		case NFT_REJECT_ICMPX_UNREACH:
-			nft_reject_br_send_v6_unreach(net, pkt->skb, pkt->in,
-						      pkt->hook,
+			nft_reject_br_send_v6_unreach(pkt->net, pkt->skb,
+						      pkt->in, pkt->hook,
 						      nft_reject_icmpv6_code(priv->icmp_code));
 			break;
 		}
diff --git a/net/ipv6/netfilter/nft_reject_ipv6.c b/net/ipv6/netfilter/nft_reject_ipv6.c
index ffcac7d..533cd57 100644
--- a/net/ipv6/netfilter/nft_reject_ipv6.c
+++ b/net/ipv6/netfilter/nft_reject_ipv6.c
@@ -24,14 +24,14 @@ static void nft_reject_ipv6_eval(const struct nft_expr *expr,
 				 const struct nft_pktinfo *pkt)
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
-	struct net *net = dev_net((pkt->in != NULL) ? pkt->in : pkt->out);
 
 	switch (priv->type) {
 	case NFT_REJECT_ICMP_UNREACH:
-		nf_send_unreach6(net, pkt->skb, priv->icmp_code, pkt->hook);
+		nf_send_unreach6(pkt->net, pkt->skb, priv->icmp_code,
+				 pkt->hook);
 		break;
 	case NFT_REJECT_TCP_RST:
-		nf_send_reset6(net, pkt->skb, pkt->hook);
+		nf_send_reset6(pkt->net, pkt->skb, pkt->hook);
 		break;
 	default:
 		break;
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 5390830..e5c1f33 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -48,9 +48,7 @@ static void __nft_trace_packet(const struct nft_pktinfo *pkt,
 			       const struct nft_chain *chain,
 			       int rulenum, enum nft_trace type)
 {
-	struct net *net = dev_net(pkt->in ? pkt->in : pkt->out);
-
-	nf_log_trace(net, pkt->pf, pkt->hook, pkt->skb, pkt->in,
+	nf_log_trace(pkt->net, pkt->pf, pkt->hook, pkt->skb, pkt->in,
 		     pkt->out, &trace_loginfo, "TRACE: %s:%s:%s:%u ",
 		     chain->table->name, chain->name, comments[type],
 		     rulenum);
@@ -114,7 +112,7 @@ unsigned int
 nft_do_chain(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
 {
 	const struct nft_chain *chain = ops->priv, *basechain = chain;
-	const struct net *net = dev_net(pkt->in ? pkt->in : pkt->out);
+	const struct net *net = pkt->net;
 	const struct nft_rule *rule;
 	const struct nft_expr *expr, *last;
 	struct nft_regs regs;
diff --git a/net/netfilter/nft_log.c b/net/netfilter/nft_log.c
index c7c7df8..319c22b 100644
--- a/net/netfilter/nft_log.c
+++ b/net/netfilter/nft_log.c
@@ -31,9 +31,8 @@ static void nft_log_eval(const struct nft_expr *expr,
 			 const struct nft_pktinfo *pkt)
 {
 	const struct nft_log *priv = nft_expr_priv(expr);
-	struct net *net = dev_net(pkt->in ? pkt->in : pkt->out);
 
-	nf_log_packet(net, pkt->pf, pkt->hook, pkt->skb, pkt->in,
+	nf_log_packet(pkt->net, pkt->pf, pkt->hook, pkt->skb, pkt->in,
 		      pkt->out, &priv->loginfo, "%s", priv->prefix);
 }
 
diff --git a/net/netfilter/nft_reject_inet.c b/net/netfilter/nft_reject_inet.c
index dea6750..0bc19f9 100644
--- a/net/netfilter/nft_reject_inet.c
+++ b/net/netfilter/nft_reject_inet.c
@@ -22,7 +22,6 @@ static void nft_reject_inet_eval(const struct nft_expr *expr,
 				 const struct nft_pktinfo *pkt)
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
-	struct net *net = dev_net((pkt->in != NULL) ? pkt->in : pkt->out);
 
 	switch (pkt->pf) {
 	case NFPROTO_IPV4:
@@ -44,14 +43,14 @@ static void nft_reject_inet_eval(const struct nft_expr *expr,
 	case NFPROTO_IPV6:
 		switch (priv->type) {
 		case NFT_REJECT_ICMP_UNREACH:
-			nf_send_unreach6(net, pkt->skb, priv->icmp_code,
+			nf_send_unreach6(pkt->net, pkt->skb, priv->icmp_code,
 					 pkt->hook);
 			break;
 		case NFT_REJECT_TCP_RST:
-			nf_send_reset6(net, pkt->skb, pkt->hook);
+			nf_send_reset6(pkt->net, pkt->skb, pkt->hook);
 			break;
 		case NFT_REJECT_ICMPX_UNREACH:
-			nf_send_unreach6(net, pkt->skb,
+			nf_send_unreach6(pkt->net, pkt->skb,
 					 nft_reject_icmpv6_code(priv->icmp_code),
 					 pkt->hook);
 			break;
-- 
1.7.10.4
