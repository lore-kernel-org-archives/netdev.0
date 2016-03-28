From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 9/9] netfilter: ipv4: fix NULL dereference
Date: Mon, 28 Mar 2016 19:58:02 +0200
Message-ID: <1459187882-5357-10-git-send-email-pablo@netfilter.org>
References: <1459187882-5357-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50844 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755182AbcC1R6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2016 13:58:17 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 1438FE838F
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 19:58:16 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id BDBDADA383
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 19:58:16 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 4ADD2DA38E
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 19:58:14 +0200 (CEST)
In-Reply-To: <1459187882-5357-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

Commit fa50d974d104 ("ipv4: Namespaceify ip_default_ttl sysctl knob")
use sock_net(skb->sk) to get the net namespace, but we can't assume
that sk_buff->sk is always exist, so when it is NULL, oops will happen.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Reviewed-by: Nikolay Borisov <kernel@kyup.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/nft_reject_bridge.c | 20 ++++++------
 net/ipv4/netfilter/ipt_SYNPROXY.c        | 54 +++++++++++++++++---------------
 2 files changed, 38 insertions(+), 36 deletions(-)

diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index adc8d72..77f7e7a 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -40,7 +40,8 @@ static void nft_reject_br_push_etherhdr(struct sk_buff *oldskb,
 /* We cannot use oldskb->dev, it can be either bridge device (NF_BRIDGE INPUT)
  * or the bridge port (NF_BRIDGE PREROUTING).
  */
-static void nft_reject_br_send_v4_tcp_reset(struct sk_buff *oldskb,
+static void nft_reject_br_send_v4_tcp_reset(struct net *net,
+					    struct sk_buff *oldskb,
 					    const struct net_device *dev,
 					    int hook)
 {
@@ -48,7 +49,6 @@ static void nft_reject_br_send_v4_tcp_reset(struct sk_buff *oldskb,
 	struct iphdr *niph;
 	const struct tcphdr *oth;
 	struct tcphdr _oth;
-	struct net *net = sock_net(oldskb->sk);
 
 	if (!nft_bridge_iphdr_validate(oldskb))
 		return;
@@ -75,7 +75,8 @@ static void nft_reject_br_send_v4_tcp_reset(struct sk_buff *oldskb,
 	br_deliver(br_port_get_rcu(dev), nskb);
 }
 
-static void nft_reject_br_send_v4_unreach(struct sk_buff *oldskb,
+static void nft_reject_br_send_v4_unreach(struct net *net,
+					  struct sk_buff *oldskb,
 					  const struct net_device *dev,
 					  int hook, u8 code)
 {
@@ -86,7 +87,6 @@ static void nft_reject_br_send_v4_unreach(struct sk_buff *oldskb,
 	void *payload;
 	__wsum csum;
 	u8 proto;
-	struct net *net = sock_net(oldskb->sk);
 
 	if (oldskb->csum_bad || !nft_bridge_iphdr_validate(oldskb))
 		return;
@@ -273,17 +273,17 @@ static void nft_reject_bridge_eval(const struct nft_expr *expr,
 	case htons(ETH_P_IP):
 		switch (priv->type) {
 		case NFT_REJECT_ICMP_UNREACH:
-			nft_reject_br_send_v4_unreach(pkt->skb, pkt->in,
-						      pkt->hook,
+			nft_reject_br_send_v4_unreach(pkt->net, pkt->skb,
+						      pkt->in, pkt->hook,
 						      priv->icmp_code);
 			break;
 		case NFT_REJECT_TCP_RST:
-			nft_reject_br_send_v4_tcp_reset(pkt->skb, pkt->in,
-							pkt->hook);
+			nft_reject_br_send_v4_tcp_reset(pkt->net, pkt->skb,
+							pkt->in, pkt->hook);
 			break;
 		case NFT_REJECT_ICMPX_UNREACH:
-			nft_reject_br_send_v4_unreach(pkt->skb, pkt->in,
-						      pkt->hook,
+			nft_reject_br_send_v4_unreach(pkt->net, pkt->skb,
+						      pkt->in, pkt->hook,
 						      nft_reject_icmp_code(priv->icmp_code));
 			break;
 		}
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 7b8fbb3..db5b875 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -18,10 +18,10 @@
 #include <net/netfilter/nf_conntrack_synproxy.h>
 
 static struct iphdr *
-synproxy_build_ip(struct sk_buff *skb, __be32 saddr, __be32 daddr)
+synproxy_build_ip(struct net *net, struct sk_buff *skb, __be32 saddr,
+		  __be32 daddr)
 {
 	struct iphdr *iph;
-	struct net *net = sock_net(skb->sk);
 
 	skb_reset_network_header(skb);
 	iph = (struct iphdr *)skb_put(skb, sizeof(*iph));
@@ -40,14 +40,12 @@ synproxy_build_ip(struct sk_buff *skb, __be32 saddr, __be32 daddr)
 }
 
 static void
-synproxy_send_tcp(const struct synproxy_net *snet,
+synproxy_send_tcp(struct net *net,
 		  const struct sk_buff *skb, struct sk_buff *nskb,
 		  struct nf_conntrack *nfct, enum ip_conntrack_info ctinfo,
 		  struct iphdr *niph, struct tcphdr *nth,
 		  unsigned int tcp_hdr_size)
 {
-	struct net *net = nf_ct_net(snet->tmpl);
-
 	nth->check = ~tcp_v4_check(tcp_hdr_size, niph->saddr, niph->daddr, 0);
 	nskb->ip_summed   = CHECKSUM_PARTIAL;
 	nskb->csum_start  = (unsigned char *)nth - nskb->head;
@@ -72,7 +70,7 @@ free_nskb:
 }
 
 static void
-synproxy_send_client_synack(const struct synproxy_net *snet,
+synproxy_send_client_synack(struct net *net,
 			    const struct sk_buff *skb, const struct tcphdr *th,
 			    const struct synproxy_options *opts)
 {
@@ -91,7 +89,7 @@ synproxy_send_client_synack(const struct synproxy_net *snet,
 		return;
 	skb_reserve(nskb, MAX_TCP_HEADER);
 
-	niph = synproxy_build_ip(nskb, iph->daddr, iph->saddr);
+	niph = synproxy_build_ip(net, nskb, iph->daddr, iph->saddr);
 
 	skb_reset_transport_header(nskb);
 	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
@@ -109,15 +107,16 @@ synproxy_send_client_synack(const struct synproxy_net *snet,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(snet, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
+	synproxy_send_tcp(net, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
 			  niph, nth, tcp_hdr_size);
 }
 
 static void
-synproxy_send_server_syn(const struct synproxy_net *snet,
+synproxy_send_server_syn(struct net *net,
 			 const struct sk_buff *skb, const struct tcphdr *th,
 			 const struct synproxy_options *opts, u32 recv_seq)
 {
+	struct synproxy_net *snet = synproxy_pernet(net);
 	struct sk_buff *nskb;
 	struct iphdr *iph, *niph;
 	struct tcphdr *nth;
@@ -132,7 +131,7 @@ synproxy_send_server_syn(const struct synproxy_net *snet,
 		return;
 	skb_reserve(nskb, MAX_TCP_HEADER);
 
-	niph = synproxy_build_ip(nskb, iph->saddr, iph->daddr);
+	niph = synproxy_build_ip(net, nskb, iph->saddr, iph->daddr);
 
 	skb_reset_transport_header(nskb);
 	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
@@ -153,12 +152,12 @@ synproxy_send_server_syn(const struct synproxy_net *snet,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(snet, skb, nskb, &snet->tmpl->ct_general, IP_CT_NEW,
+	synproxy_send_tcp(net, skb, nskb, &snet->tmpl->ct_general, IP_CT_NEW,
 			  niph, nth, tcp_hdr_size);
 }
 
 static void
-synproxy_send_server_ack(const struct synproxy_net *snet,
+synproxy_send_server_ack(struct net *net,
 			 const struct ip_ct_tcp *state,
 			 const struct sk_buff *skb, const struct tcphdr *th,
 			 const struct synproxy_options *opts)
@@ -177,7 +176,7 @@ synproxy_send_server_ack(const struct synproxy_net *snet,
 		return;
 	skb_reserve(nskb, MAX_TCP_HEADER);
 
-	niph = synproxy_build_ip(nskb, iph->daddr, iph->saddr);
+	niph = synproxy_build_ip(net, nskb, iph->daddr, iph->saddr);
 
 	skb_reset_transport_header(nskb);
 	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
@@ -193,11 +192,11 @@ synproxy_send_server_ack(const struct synproxy_net *snet,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(snet, skb, nskb, NULL, 0, niph, nth, tcp_hdr_size);
+	synproxy_send_tcp(net, skb, nskb, NULL, 0, niph, nth, tcp_hdr_size);
 }
 
 static void
-synproxy_send_client_ack(const struct synproxy_net *snet,
+synproxy_send_client_ack(struct net *net,
 			 const struct sk_buff *skb, const struct tcphdr *th,
 			 const struct synproxy_options *opts)
 {
@@ -215,7 +214,7 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
 		return;
 	skb_reserve(nskb, MAX_TCP_HEADER);
 
-	niph = synproxy_build_ip(nskb, iph->saddr, iph->daddr);
+	niph = synproxy_build_ip(net, nskb, iph->saddr, iph->daddr);
 
 	skb_reset_transport_header(nskb);
 	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
@@ -231,15 +230,16 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(snet, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
+	synproxy_send_tcp(net, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
 			  niph, nth, tcp_hdr_size);
 }
 
 static bool
-synproxy_recv_client_ack(const struct synproxy_net *snet,
+synproxy_recv_client_ack(struct net *net,
 			 const struct sk_buff *skb, const struct tcphdr *th,
 			 struct synproxy_options *opts, u32 recv_seq)
 {
+	struct synproxy_net *snet = synproxy_pernet(net);
 	int mss;
 
 	mss = __cookie_v4_check(ip_hdr(skb), th, ntohl(th->ack_seq) - 1);
@@ -255,7 +255,7 @@ synproxy_recv_client_ack(const struct synproxy_net *snet,
 	if (opts->options & XT_SYNPROXY_OPT_TIMESTAMP)
 		synproxy_check_timestamp_cookie(opts);
 
-	synproxy_send_server_syn(snet, skb, th, opts, recv_seq);
+	synproxy_send_server_syn(net, skb, th, opts, recv_seq);
 	return true;
 }
 
@@ -263,7 +263,8 @@ static unsigned int
 synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_synproxy_info *info = par->targinfo;
-	struct synproxy_net *snet = synproxy_pernet(par->net);
+	struct net *net = par->net;
+	struct synproxy_net *snet = synproxy_pernet(net);
 	struct synproxy_options opts = {};
 	struct tcphdr *th, _th;
 
@@ -292,12 +293,12 @@ synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 					  XT_SYNPROXY_OPT_SACK_PERM |
 					  XT_SYNPROXY_OPT_ECN);
 
-		synproxy_send_client_synack(snet, skb, th, &opts);
+		synproxy_send_client_synack(net, skb, th, &opts);
 		return NF_DROP;
 
 	} else if (th->ack && !(th->fin || th->rst || th->syn)) {
 		/* ACK from client */
-		synproxy_recv_client_ack(snet, skb, th, &opts, ntohl(th->seq));
+		synproxy_recv_client_ack(net, skb, th, &opts, ntohl(th->seq));
 		return NF_DROP;
 	}
 
@@ -308,7 +309,8 @@ static unsigned int ipv4_synproxy_hook(void *priv,
 				       struct sk_buff *skb,
 				       const struct nf_hook_state *nhs)
 {
-	struct synproxy_net *snet = synproxy_pernet(nhs->net);
+	struct net *net = nhs->net;
+	struct synproxy_net *snet = synproxy_pernet(net);
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
 	struct nf_conn_synproxy *synproxy;
@@ -365,7 +367,7 @@ static unsigned int ipv4_synproxy_hook(void *priv,
 			 * therefore we need to add 1 to make the SYN sequence
 			 * number match the one of first SYN.
 			 */
-			if (synproxy_recv_client_ack(snet, skb, th, &opts,
+			if (synproxy_recv_client_ack(net, skb, th, &opts,
 						     ntohl(th->seq) + 1))
 				this_cpu_inc(snet->stats->cookie_retrans);
 
@@ -391,12 +393,12 @@ static unsigned int ipv4_synproxy_hook(void *priv,
 				  XT_SYNPROXY_OPT_SACK_PERM);
 
 		swap(opts.tsval, opts.tsecr);
-		synproxy_send_server_ack(snet, state, skb, th, &opts);
+		synproxy_send_server_ack(net, state, skb, th, &opts);
 
 		nf_ct_seqadj_init(ct, ctinfo, synproxy->isn - ntohl(th->seq));
 
 		swap(opts.tsval, opts.tsecr);
-		synproxy_send_client_ack(snet, skb, th, &opts);
+		synproxy_send_client_ack(net, skb, th, &opts);
 
 		consume_skb(skb);
 		return NF_STOLEN;
-- 
2.1.4
