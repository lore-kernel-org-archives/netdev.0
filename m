From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 08/15] nftables: Use pkt->net instead of computing net from the passed net_devices
Date: Fri, 18 Sep 2015 14:33:01 -0500
Message-ID: <1442604788-19718-8-git-send-email-ebiederm@xmission.com>
References: <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/bridge/netfilter/nft_reject_bridge.c | 13 ++++++-------
 net/ipv6/netfilter/nft_reject_ipv6.c     |  6 +++---
 net/netfilter/nf_tables_core.c           |  6 ++----
 net/netfilter/nft_log.c                  |  3 +--
 net/netfilter/nft_reject_inet.c          |  7 +++----
 5 files changed, 15 insertions(+), 20 deletions(-)

diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index cee92612b2cc..fdba3d9fbff3 100644
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
index ffcac7d5da43..533cd5719c59 100644
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
index 539083099c0d..e5c1f332e45e 100644
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
index c7c7df85f0b7..319c22b4bca2 100644
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
index dea6750af6ff..0bc19f97e238 100644
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
2.2.1

