From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 2/4] net: skb->rtable accessor
Date: Tue, 02 Jun 2009 17:14:27 +0200
Message-ID: <4A2541D3.7000208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57212 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166AbZFBPO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 11:14:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define skb_rtable(const struct sk_buff *skb) accessor to get rtable from skb

Delete skb->rtable field

Setting rtable is not allowed, just set dst instead as rtable is an alias.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/appletalk/ipddp.c           |    2 -
 include/linux/skbuff.h                  |    6 ++-
 include/net/route.h                     |    2 -
 net/bridge/br_netfilter.c               |   25 ++++++++------
 net/dccp/ipv4.c                         |    6 +--
 net/ipv4/arp.c                          |    4 +-
 net/ipv4/icmp.c                         |   10 ++---
 net/ipv4/igmp.c                         |    2 -
 net/ipv4/ip_forward.c                   |    2 -
 net/ipv4/ip_gre.c                       |    4 +-
 net/ipv4/ip_input.c                     |    2 -
 net/ipv4/ip_options.c                   |   16 ++++-----
 net/ipv4/ip_output.c                    |   10 ++---
 net/ipv4/ip_sockglue.c                  |    2 -
 net/ipv4/ipip.c                         |    2 -
 net/ipv4/ipmr.c                         |    6 +--
 net/ipv4/netfilter/ipt_MASQUERADE.c     |    2 -
 net/ipv4/netfilter/nf_nat_helper.c      |    4 +-
 net/ipv4/route.c                        |   37 +++++++++++++---------
 net/ipv4/tcp_ipv4.c                     |    4 +-
 net/netfilter/nf_conntrack_netbios_ns.c |    2 -
 net/sched/em_meta.c                     |    4 +-
 net/sctp/protocol.c                     |    8 ++--
 23 files changed, 89 insertions(+), 73 deletions(-)

diff --git a/drivers/net/appletalk/ipddp.c b/drivers/net/appletalk/ipddp.c
index 9832b75..78cea5e 100644
--- a/drivers/net/appletalk/ipddp.c
+++ b/drivers/net/appletalk/ipddp.c
@@ -115,7 +115,7 @@ static struct net_device * __init ipddp_init(void)
  */
 static int ipddp_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	__be32 paddr = ((struct rtable*)skb->dst)->rt_gateway;
+	__be32 paddr = skb_rtable(skb)->rt_gateway;
         struct ddpehdr *ddp;
         struct ipddp_route *rt;
         struct atalk_addr *our_addr;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d4d7c66..a3ae3c5 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -324,7 +324,6 @@ struct sk_buff {
 
 	union {
 		struct  dst_entry	*dst;
-		struct  rtable		*rtable;
 		unsigned long		_skb_dst;
 	};
 #ifdef CONFIG_XFRM
@@ -427,6 +426,11 @@ extern void skb_dma_unmap(struct device *dev, struct sk_buff *skb,
 			  enum dma_data_direction dir);
 #endif
 
+static inline struct rtable *skb_rtable(const struct sk_buff *skb)
+{
+	return (struct rtable *)skb->_skb_dst;
+}
+
 extern void kfree_skb(struct sk_buff *skb);
 extern void consume_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
diff --git a/include/net/route.h b/include/net/route.h
index 4e8cae0..40f6346 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -210,7 +210,7 @@ static inline struct inet_peer *rt_get_peer(struct rtable *rt)
 
 static inline int inet_iif(const struct sk_buff *skb)
 {
-	return skb->rtable->rt_iif;
+	return skb_rtable(skb)->rt_iif;
 }
 
 #endif	/* _ROUTE_H */
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index e4a418f..e0ceb66 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -228,6 +228,7 @@ int nf_bridge_copy_header(struct sk_buff *skb)
 static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+	struct rtable *rt;
 
 	if (nf_bridge->mask & BRNF_PKT_TYPE) {
 		skb->pkt_type = PACKET_OTHERHOST;
@@ -235,12 +236,13 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 	}
 	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
 
-	skb->rtable = bridge_parent_rtable(nf_bridge->physindev);
-	if (!skb->rtable) {
+	rt = bridge_parent_rtable(nf_bridge->physindev);
+	if (!rt) {
 		kfree_skb(skb);
 		return 0;
 	}
-	dst_hold(&skb->rtable->u.dst);
+	dst_hold(&rt->u.dst);
+	skb->dst = &rt->u.dst;
 
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_push_encap_header(skb);
@@ -338,6 +340,7 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 	struct net_device *dev = skb->dev;
 	struct iphdr *iph = ip_hdr(skb);
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+	struct rtable *rt;
 	int err;
 
 	if (nf_bridge->mask & BRNF_PKT_TYPE) {
@@ -347,7 +350,6 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
 	if (dnat_took_place(skb)) {
 		if ((err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))) {
-			struct rtable *rt;
 			struct flowi fl = {
 				.nl_u = {
 					.ip4_u = {
@@ -404,12 +406,13 @@ bridged_dnat:
 			skb->pkt_type = PACKET_HOST;
 		}
 	} else {
-		skb->rtable = bridge_parent_rtable(nf_bridge->physindev);
-		if (!skb->rtable) {
+		rt = bridge_parent_rtable(nf_bridge->physindev);
+		if (!rt) {
 			kfree_skb(skb);
 			return 0;
 		}
-		dst_hold(&skb->rtable->u.dst);
+		dst_hold(&rt->u.dst);
+		skb->dst = &rt->u.dst;
 	}
 
 	skb->dev = nf_bridge->physindev;
@@ -628,9 +631,11 @@ static unsigned int br_nf_local_in(unsigned int hook, struct sk_buff *skb,
 				   const struct net_device *out,
 				   int (*okfn)(struct sk_buff *))
 {
-	if (skb->rtable && skb->rtable == bridge_parent_rtable(in)) {
-		dst_release(&skb->rtable->u.dst);
-		skb->rtable = NULL;
+	struct rtable *rt = skb_rtable(skb);
+
+	if (rt && rt == bridge_parent_rtable(in)) {
+		dst_release(&rt->u.dst);
+		skb->dst = NULL;
 	}
 
 	return NF_ACCEPT;
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index d1dd952..2cf48ba 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -452,7 +452,7 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 					   struct sk_buff *skb)
 {
 	struct rtable *rt;
-	struct flowi fl = { .oif = skb->rtable->rt_iif,
+	struct flowi fl = { .oif = skb_rtable(skb)->rt_iif,
 			    .nl_u = { .ip4_u =
 				      { .daddr = ip_hdr(skb)->saddr,
 					.saddr = ip_hdr(skb)->daddr,
@@ -514,7 +514,7 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	if (dccp_hdr(rxskb)->dccph_type == DCCP_PKT_RESET)
 		return;
 
-	if (rxskb->rtable->rt_type != RTN_LOCAL)
+	if (skb_rtable(rxskb)->rt_type != RTN_LOCAL)
 		return;
 
 	dst = dccp_v4_route_skb(net, ctl_sk, rxskb);
@@ -567,7 +567,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 
 	/* Never answer to DCCP_PKT_REQUESTs send to broadcast or multicast */
-	if (skb->rtable->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
+	if (skb_rtable(skb)->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
 		return 0;	/* discard, don't send a reset here */
 
 	if (dccp_bad_service_code(sk, service)) {
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index f11931c..816494f 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -474,7 +474,7 @@ int arp_find(unsigned char *haddr, struct sk_buff *skb)
 		return 1;
 	}
 
-	paddr = skb->rtable->rt_gateway;
+	paddr = skb_rtable(skb)->rt_gateway;
 
 	if (arp_set_predefined(inet_addr_type(dev_net(dev), paddr), haddr, paddr, dev))
 		return 0;
@@ -817,7 +817,7 @@ static int arp_process(struct sk_buff *skb)
 	if (arp->ar_op == htons(ARPOP_REQUEST) &&
 	    ip_route_input(skb, tip, sip, 0, dev) == 0) {
 
-		rt = skb->rtable;
+		rt = skb_rtable(skb);
 		addr_type = rt->rt_type;
 
 		if (addr_type == RTN_LOCAL) {
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 3f50807..94f75ef 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -356,7 +356,7 @@ static void icmp_push_reply(struct icmp_bxm *icmp_param,
 static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 {
 	struct ipcm_cookie ipc;
-	struct rtable *rt = skb->rtable;
+	struct rtable *rt = skb_rtable(skb);
 	struct net *net = dev_net(rt->u.dst.dev);
 	struct sock *sk;
 	struct inet_sock *inet;
@@ -416,7 +416,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	struct iphdr *iph;
 	int room;
 	struct icmp_bxm icmp_param;
-	struct rtable *rt = skb_in->rtable;
+	struct rtable *rt = skb_rtable(skb_in);
 	struct ipcm_cookie ipc;
 	__be32 saddr;
 	u8  tos;
@@ -596,7 +596,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 					     RT_TOS(tos), rt2->u.dst.dev);
 
 			dst_release(&rt2->u.dst);
-			rt2 = skb_in->rtable;
+			rt2 = skb_rtable(skb_in);
 			skb_in->dst = odst;
 		}
 
@@ -926,7 +926,7 @@ static void icmp_address(struct sk_buff *skb)
 
 static void icmp_address_reply(struct sk_buff *skb)
 {
-	struct rtable *rt = skb->rtable;
+	struct rtable *rt = skb_rtable(skb);
 	struct net_device *dev = skb->dev;
 	struct in_device *in_dev;
 	struct in_ifaddr *ifa;
@@ -970,7 +970,7 @@ static void icmp_discard(struct sk_buff *skb)
 int icmp_rcv(struct sk_buff *skb)
 {
 	struct icmphdr *icmph;
-	struct rtable *rt = skb->rtable;
+	struct rtable *rt = skb_rtable(skb);
 	struct net *net = dev_net(rt->u.dst.dev);
 
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index e6058a5..afabd27 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -948,7 +948,7 @@ int igmp_rcv(struct sk_buff *skb)
 	case IGMPV2_HOST_MEMBERSHIP_REPORT:
 	case IGMPV3_HOST_MEMBERSHIP_REPORT:
 		/* Is it our report looped back? */
-		if (skb->rtable->fl.iif == 0)
+		if (skb_rtable(skb)->fl.iif == 0)
 			break;
 		/* don't rely on MC router hearing unicast reports */
 		if (skb->pkt_type == PACKET_MULTICAST ||
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index df3fe50..0761cd9 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -81,7 +81,7 @@ int ip_forward(struct sk_buff *skb)
 	if (!xfrm4_route_forward(skb))
 		goto drop;
 
-	rt = skb->rtable;
+	rt = skb_rtable(skb);
 
 	if (opt->is_strictroute && rt->rt_dst != rt->rt_gateway)
 		goto sr_failed;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 77436e2..85ddad4 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -602,7 +602,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 #ifdef CONFIG_NET_IPGRE_BROADCAST
 		if (ipv4_is_multicast(iph->daddr)) {
 			/* Looped back packet, drop it! */
-			if (skb->rtable->fl.iif == 0)
+			if (skb_rtable(skb)->fl.iif == 0)
 				goto drop;
 			stats->multicast++;
 			skb->pkt_type = PACKET_BROADCAST;
@@ -704,7 +704,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 
 		if (skb->protocol == htons(ETH_P_IP)) {
-			rt = skb->rtable;
+			rt = skb_rtable(skb);
 			if ((dst = rt->rt_gateway) == 0)
 				goto tx_error_icmp;
 		}
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 40f6206..cea784b 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -357,7 +357,7 @@ static int ip_rcv_finish(struct sk_buff *skb)
 	if (iph->ihl > 5 && ip_rcv_options(skb))
 		goto drop;
 
-	rt = skb->rtable;
+	rt = skb_rtable(skb);
 	if (rt->rt_type == RTN_MULTICAST) {
 		IP_UPD_PO_STATS_BH(dev_net(rt->u.dst.dev), IPSTATS_MIB_INMCAST,
 				skb->len);
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 2c88da6..7e1074f 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -102,7 +102,7 @@ int ip_options_echo(struct ip_options * dopt, struct sk_buff * skb)
 	sptr = skb_network_header(skb);
 	dptr = dopt->__data;
 
-	daddr = skb->rtable->rt_spec_dst;
+	daddr = skb_rtable(skb)->rt_spec_dst;
 
 	if (sopt->rr) {
 		optlen  = sptr[sopt->rr+1];
@@ -257,7 +257,7 @@ int ip_options_compile(struct net *net,
 	struct rtable *rt = NULL;
 
 	if (skb != NULL) {
-		rt = skb->rtable;
+		rt = skb_rtable(skb);
 		optptr = (unsigned char *)&(ip_hdr(skb)[1]);
 	} else
 		optptr = opt->__data;
@@ -550,7 +550,7 @@ void ip_forward_options(struct sk_buff *skb)
 {
 	struct   ip_options * opt	= &(IPCB(skb)->opt);
 	unsigned char * optptr;
-	struct rtable *rt = skb->rtable;
+	struct rtable *rt = skb_rtable(skb);
 	unsigned char *raw = skb_network_header(skb);
 
 	if (opt->rr_needaddr) {
@@ -598,7 +598,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 	__be32 nexthop;
 	struct iphdr *iph = ip_hdr(skb);
 	unsigned char *optptr = skb_network_header(skb) + opt->srr;
-	struct rtable *rt = skb->rtable;
+	struct rtable *rt = skb_rtable(skb);
 	struct rtable *rt2;
 	int err;
 
@@ -623,13 +623,13 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 		}
 		memcpy(&nexthop, &optptr[srrptr-1], 4);
 
-		rt = skb->rtable;
-		skb->rtable = NULL;
+		rt = skb_rtable(skb);
+		skb->dst = NULL;
 		err = ip_route_input(skb, nexthop, iph->saddr, iph->tos, skb->dev);
-		rt2 = skb->rtable;
+		rt2 = skb_rtable(skb);
 		if (err || (rt2->rt_type != RTN_UNICAST && rt2->rt_type != RTN_LOCAL)) {
 			ip_rt_put(rt2);
-			skb->rtable = rt;
+			skb->dst = &rt->u.dst;
 			return -EINVAL;
 		}
 		ip_rt_put(rt);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index ea19c37..8d845eb 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -140,7 +140,7 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 			  __be32 saddr, __be32 daddr, struct ip_options *opt)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	struct rtable *rt = skb->rtable;
+	struct rtable *rt = skb_rtable(skb);
 	struct iphdr *iph;
 
 	/* Build the IP header. */
@@ -238,7 +238,7 @@ static int ip_finish_output(struct sk_buff *skb)
 int ip_mc_output(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
-	struct rtable *rt = skb->rtable;
+	struct rtable *rt = skb_rtable(skb);
 	struct net_device *dev = rt->u.dst.dev;
 
 	/*
@@ -319,7 +319,7 @@ int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
 	/* Skip all of this if the packet is already routed,
 	 * f.e. by something like SCTP.
 	 */
-	rt = skb->rtable;
+	rt = skb_rtable(skb);
 	if (rt != NULL)
 		goto packet_routed;
 
@@ -440,7 +440,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	unsigned int mtu, hlen, left, len, ll_rs, pad;
 	int offset;
 	__be16 not_last_frag;
-	struct rtable *rt = skb->rtable;
+	struct rtable *rt = skb_rtable(skb);
 	int err = 0;
 
 	dev = rt->u.dst.dev;
@@ -1362,7 +1362,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 	} replyopts;
 	struct ipcm_cookie ipc;
 	__be32 daddr;
-	struct rtable *rt = skb->rtable;
+	struct rtable *rt = skb_rtable(skb);
 
 	if (ip_options_echo(&replyopts.opt, skb))
 		return;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index cb49936..fc7993e 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -57,7 +57,7 @@
 static void ip_cmsg_recv_pktinfo(struct msghdr *msg, struct sk_buff *skb)
 {
 	struct in_pktinfo info;
-	struct rtable *rt = skb->rtable;
+	struct rtable *rt = skb_rtable(skb);
 
 	info.ipi_addr.s_addr = ip_hdr(skb)->daddr;
 	if (rt) {
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index bb2f1b1..0c6e7bf 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -416,7 +416,7 @@ static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (!dst) {
 		/* NBMA tunnel */
-		if ((rt = skb->rtable) == NULL) {
+		if ((rt = skb_rtable(skb)) == NULL) {
 			stats->tx_fifo_errors++;
 			goto tx_error;
 		}
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 13e9dd3..69dd058 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1354,7 +1354,7 @@ static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local
 	if (net->ipv4.vif_table[vif].dev != skb->dev) {
 		int true_vifi;
 
-		if (skb->rtable->fl.iif == 0) {
+		if (skb_rtable(skb)->fl.iif == 0) {
 			/* It is our own packet, looped back.
 			   Very complicated situation...
 
@@ -1430,7 +1430,7 @@ int ip_mr_input(struct sk_buff *skb)
 {
 	struct mfc_cache *cache;
 	struct net *net = dev_net(skb->dev);
-	int local = skb->rtable->rt_flags&RTCF_LOCAL;
+	int local = skb_rtable(skb)->rt_flags & RTCF_LOCAL;
 
 	/* Packet is looped back after forward, it should not be
 	   forwarded second time, but still can be delivered locally.
@@ -1646,7 +1646,7 @@ int ipmr_get_route(struct net *net,
 {
 	int err;
 	struct mfc_cache *cache;
-	struct rtable *rt = skb->rtable;
+	struct rtable *rt = skb_rtable(skb);
 
 	read_lock(&mrt_lock);
 	cache = ipmr_cache_find(net, rt->rt_src, rt->rt_dst);
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index f389f60..c0992c7 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -72,7 +72,7 @@ masquerade_tg(struct sk_buff *skb, const struct xt_target_param *par)
 		return NF_ACCEPT;
 
 	mr = par->targinfo;
-	rt = skb->rtable;
+	rt = skb_rtable(skb);
 	newsrc = inet_select_addr(par->out, rt->rt_gateway, RT_SCOPE_UNIVERSE);
 	if (!newsrc) {
 		printk("MASQUERADE: %s ate my IP address\n", par->out->name);
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index cf7a42b..155c008 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -140,7 +140,7 @@ nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 			 const char *rep_buffer,
 			 unsigned int rep_len)
 {
-	struct rtable *rt = skb->rtable;
+	struct rtable *rt = skb_rtable(skb);
 	struct iphdr *iph;
 	struct tcphdr *tcph;
 	int oldlen, datalen;
@@ -218,7 +218,7 @@ nf_nat_mangle_udp_packet(struct sk_buff *skb,
 			 const char *rep_buffer,
 			 unsigned int rep_len)
 {
-	struct rtable *rt = skb->rtable;
+	struct rtable *rt = skb_rtable(skb);
 	struct iphdr *iph;
 	struct udphdr *udph;
 	int datalen, oldlen;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 28205e5..f20060a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1064,7 +1064,8 @@ work_done:
 out:	return 0;
 }
 
-static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rtable **rp)
+static int rt_intern_hash(unsigned hash, struct rtable *rt,
+			  struct rtable **rp, struct sk_buff *skb)
 {
 	struct rtable	*rth, **rthp;
 	unsigned long	now;
@@ -1114,7 +1115,10 @@ restart:
 			spin_unlock_bh(rt_hash_lock_addr(hash));
 
 			rt_drop(rt);
-			*rp = rth;
+			if (rp)
+				*rp = rth;
+			else
+				skb->dst = &rth->u.dst;
 			return 0;
 		}
 
@@ -1210,7 +1214,10 @@ restart:
 	rcu_assign_pointer(rt_hash_table[hash].chain, rt);
 
 	spin_unlock_bh(rt_hash_lock_addr(hash));
-	*rp = rt;
+	if (rp)
+		*rp = rt;
+	else
+		skb->dst = &rt->u.dst;
 	return 0;
 }
 
@@ -1407,7 +1414,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 							&netevent);
 
 				rt_del(hash, rth);
-				if (!rt_intern_hash(hash, rt, &rt))
+				if (!rt_intern_hash(hash, rt, &rt, NULL))
 					ip_rt_put(rt);
 				goto do_next;
 			}
@@ -1473,7 +1480,7 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 
 void ip_rt_send_redirect(struct sk_buff *skb)
 {
-	struct rtable *rt = skb->rtable;
+	struct rtable *rt = skb_rtable(skb);
 	struct in_device *in_dev = in_dev_get(rt->u.dst.dev);
 
 	if (!in_dev)
@@ -1521,7 +1528,7 @@ out:
 
 static int ip_error(struct sk_buff *skb)
 {
-	struct rtable *rt = skb->rtable;
+	struct rtable *rt = skb_rtable(skb);
 	unsigned long now;
 	int code;
 
@@ -1698,7 +1705,7 @@ static void ipv4_link_failure(struct sk_buff *skb)
 
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_HOST_UNREACH, 0);
 
-	rt = skb->rtable;
+	rt = skb_rtable(skb);
 	if (rt)
 		dst_set_expires(&rt->u.dst, 0);
 }
@@ -1858,7 +1865,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	in_dev_put(in_dev);
 	hash = rt_hash(daddr, saddr, dev->ifindex, rt_genid(dev_net(dev)));
-	return rt_intern_hash(hash, rth, &skb->rtable);
+	return rt_intern_hash(hash, rth, NULL, skb);
 
 e_nobufs:
 	in_dev_put(in_dev);
@@ -2019,7 +2026,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
 	/* put it into the cache */
 	hash = rt_hash(daddr, saddr, fl->iif,
 		       rt_genid(dev_net(rth->u.dst.dev)));
-	return rt_intern_hash(hash, rth, &skb->rtable);
+	return rt_intern_hash(hash, rth, NULL, skb);
 }
 
 /*
@@ -2175,7 +2182,7 @@ local_input:
 	}
 	rth->rt_type	= res.type;
 	hash = rt_hash(daddr, saddr, fl.iif, rt_genid(net));
-	err = rt_intern_hash(hash, rth, &skb->rtable);
+	err = rt_intern_hash(hash, rth, NULL, skb);
 	goto done;
 
 no_route:
@@ -2244,7 +2251,7 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			dst_use(&rth->u.dst, jiffies);
 			RT_CACHE_STAT_INC(in_hit);
 			rcu_read_unlock();
-			skb->rtable = rth;
+			skb->dst = &rth->u.dst;
 			return 0;
 		}
 		RT_CACHE_STAT_INC(in_hlist_search);
@@ -2420,7 +2427,7 @@ static int ip_mkroute_output(struct rtable **rp,
 	if (err == 0) {
 		hash = rt_hash(oldflp->fl4_dst, oldflp->fl4_src, oldflp->oif,
 			       rt_genid(dev_net(dev_out)));
-		err = rt_intern_hash(hash, rth, rp);
+		err = rt_intern_hash(hash, rth, rp, NULL);
 	}
 
 	return err;
@@ -2763,7 +2770,7 @@ static int rt_fill_info(struct net *net,
 			struct sk_buff *skb, u32 pid, u32 seq, int event,
 			int nowait, unsigned int flags)
 {
-	struct rtable *rt = skb->rtable;
+	struct rtable *rt = skb_rtable(skb);
 	struct rtmsg *r;
 	struct nlmsghdr *nlh;
 	long expires;
@@ -2907,7 +2914,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 		err = ip_route_input(skb, dst, src, rtm->rtm_tos, dev);
 		local_bh_enable();
 
-		rt = skb->rtable;
+		rt = skb_rtable(skb);
 		if (err == 0 && rt->u.dst.error)
 			err = -rt->u.dst.error;
 	} else {
@@ -2927,7 +2934,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	if (err)
 		goto errout_free;
 
-	skb->rtable = rt;
+	skb->dst = &rt->u.dst;
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index fc79e34..319c885 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -546,7 +546,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	if (th->rst)
 		return;
 
-	if (skb->rtable->rt_type != RTN_LOCAL)
+	if (skb_rtable(skb)->rt_type != RTN_LOCAL)
 		return;
 
 	/* Swap the send and the receive. */
@@ -1185,7 +1185,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 #endif
 
 	/* Never answer to SYNs send to broadcast or multicast */
-	if (skb->rtable->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
+	if (skb_rtable(skb)->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
 		goto drop;
 
 	/* TW buckets are converted to open requests without
diff --git a/net/netfilter/nf_conntrack_netbios_ns.c b/net/netfilter/nf_conntrack_netbios_ns.c
index 8a3875e..497b222 100644
--- a/net/netfilter/nf_conntrack_netbios_ns.c
+++ b/net/netfilter/nf_conntrack_netbios_ns.c
@@ -48,7 +48,7 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 {
 	struct nf_conntrack_expect *exp;
 	struct iphdr *iph = ip_hdr(skb);
-	struct rtable *rt = skb->rtable;
+	struct rtable *rt = skb_rtable(skb);
 	struct in_device *in_dev;
 	__be32 mask = 0;
 
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index fad596b..b6b588b 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -258,10 +258,10 @@ META_COLLECTOR(int_rtclassid)
 
 META_COLLECTOR(int_rtiif)
 {
-	if (unlikely(skb->rtable == NULL))
+	if (unlikely(skb_rtable(skb) == NULL))
 		*err = -1;
 	else
-		dst->value = skb->rtable->fl.iif;
+		dst->value = skb_rtable(skb)->fl.iif;
 }
 
 /**************************************************************************
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 8eb3e61..cb2c50d 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -393,7 +393,7 @@ static int sctp_v4_addr_valid(union sctp_addr *addr,
 		return 0;
 
 	/* Is this a broadcast address? */
-	if (skb && skb->rtable->rt_flags & RTCF_BROADCAST)
+	if (skb && skb_rtable(skb)->rt_flags & RTCF_BROADCAST)
 		return 0;
 
 	return 1;
@@ -572,7 +572,7 @@ static void sctp_v4_get_saddr(struct sctp_sock *sk,
 /* What interface did this skb arrive on? */
 static int sctp_v4_skb_iif(const struct sk_buff *skb)
 {
-	return skb->rtable->rt_iif;
+	return skb_rtable(skb)->rt_iif;
 }
 
 /* Was this packet marked by Explicit Congestion Notification? */
@@ -848,8 +848,8 @@ static inline int sctp_v4_xmit(struct sk_buff *skb,
 
 	SCTP_DEBUG_PRINTK("%s: skb:%p, len:%d, src:%pI4, dst:%pI4\n",
 			  __func__, skb, skb->len,
-			  &skb->rtable->rt_src,
-			  &skb->rtable->rt_dst);
+			  &skb_rtable(skb)->rt_src,
+			  &skb_rtable(skb)->rt_dst);
 
 	inet->pmtudisc = transport->param_flags & SPP_PMTUD_ENABLE ?
 			 IP_PMTUDISC_DO : IP_PMTUDISC_DONT;

