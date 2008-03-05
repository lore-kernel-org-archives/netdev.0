From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [IPV4]: Add an 'rtable' field in struct sk_buff to alias 'dst'
 field and avoid casts
Date: Thu, 06 Mar 2008 00:30:02 +0100
Message-ID: <47CF2CFA.6000704@cosmosbay.com>
References: <47CCF71D.2030800@cosmosbay.com>	<20080303.232342.221759327.davem@davemloft.net>	<47CCFC0B.7060801@cosmosbay.com> <20080303.234649.109971767.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010905060804090409030500"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604007av.neufgp.fr ([84.96.92.120]:53500
	"EHLO neuf-infra-smtp-out-sp604007av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756882AbYCEXoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 18:44:46 -0500
In-Reply-To: <20080303.234649.109971767.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010905060804090409030500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

David Miller a écrit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 04 Mar 2008 08:36:43 +0100
> 
>> Yes, I had this idea, but felt that it was better in this case to have a 
>> dst_hold() that refers to the above affectation.
>>
>> skb->dst = &__fake_rtable.u.dst;
>> dst_hold(skb->dst);
>>
>> instead of
>>
>> skb->rtable = &__fake_rtable;
>> dst_hold(skb->dst);
>>
>> Do you prefer the later ?
> 
> Wouldn't it be pleasant if you could pass
> &__fake_rtable to dst_hold() directly?
> 
> Can't we do that by making it's arg an anonymous union like the thing
> you're doing here?

Hi David

Please find a 2nd version of the patch, respined to last net-2.6.26.
I could not find a clean way to use an anonymous union for dst_hold(), so I 
made a small change in net/bridge/br_netfilter.c

Thank you

[IPV4]: Add an 'rtable' field in struct sk_buff to alias 'dst' field and avoid 
casts

(Anonymous) unions can help us to avoid ugly casts.

A common cast it the (struct rtable *)skb->dst one.

Defining an union like  :
union {
     struct dst_entry *dst;
     struct rtable *rtable;
};
permits to use dkb->rtable in place.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>



--------------010905060804090409030500
Content-Type: text/plain;
 name="rtable_alias.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rtable_alias.patch"

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bbd8d00..7beb239 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -256,7 +256,10 @@ struct sk_buff {
 	ktime_t			tstamp;
 	struct net_device	*dev;
 
-	struct  dst_entry	*dst;
+	union {
+		struct  dst_entry	*dst;
+		struct  rtable		*rtable;
+	};
 	struct	sec_path	*sp;
 
 	/*
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 89cd011..8660cb0 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -195,7 +195,7 @@ static inline int inet_sk_ehashfn(const struct sock *sk)
 
 static inline int inet_iif(const struct sk_buff *skb)
 {
-	return ((struct rtable *)skb->dst)->rt_iif;
+	return skb->rtable->rt_iif;
 }
 
 #endif	/* _INET_SOCK_H */
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 1c0efd8..0278a06 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -223,8 +223,8 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 	}
 	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
 
-	skb->dst = (struct dst_entry *)&__fake_rtable;
-	dst_hold(skb->dst);
+	skb->rtable = &__fake_rtable;
+	dst_hold(&__fake_rtable.u.dst);
 
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_push_encap_header(skb);
@@ -388,8 +388,8 @@ bridged_dnat:
 			skb->pkt_type = PACKET_HOST;
 		}
 	} else {
-		skb->dst = (struct dst_entry *)&__fake_rtable;
-		dst_hold(skb->dst);
+		skb->rtable = &__fake_rtable;
+		dst_hold(&__fake_rtable.u.dst);
 	}
 
 	skb->dev = nf_bridge->physindev;
@@ -608,9 +608,9 @@ static unsigned int br_nf_local_in(unsigned int hook, struct sk_buff *skb,
 				   const struct net_device *out,
 				   int (*okfn)(struct sk_buff *))
 {
-	if (skb->dst == (struct dst_entry *)&__fake_rtable) {
-		dst_release(skb->dst);
-		skb->dst = NULL;
+	if (skb->rtable == &__fake_rtable) {
+		dst_release(&__fake_rtable.u.dst);
+		skb->rtable = NULL;
 	}
 
 	return NF_ACCEPT;
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 514a40b..17ad69e 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -450,7 +450,7 @@ static struct dst_entry* dccp_v4_route_skb(struct sock *sk,
 					   struct sk_buff *skb)
 {
 	struct rtable *rt;
-	struct flowi fl = { .oif = ((struct rtable *)skb->dst)->rt_iif,
+	struct flowi fl = { .oif = skb->rtable->rt_iif,
 			    .nl_u = { .ip4_u =
 				      { .daddr = ip_hdr(skb)->saddr,
 					.saddr = ip_hdr(skb)->daddr,
@@ -511,7 +511,7 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	if (dccp_hdr(rxskb)->dccph_type == DCCP_PKT_RESET)
 		return;
 
-	if (((struct rtable *)rxskb->dst)->rt_type != RTN_LOCAL)
+	if (rxskb->rtable->rt_type != RTN_LOCAL)
 		return;
 
 	dst = dccp_v4_route_skb(dccp_v4_ctl_socket->sk, rxskb);
@@ -563,8 +563,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 
 	/* Never answer to DCCP_PKT_REQUESTs send to broadcast or multicast */
-	if (((struct rtable *)skb->dst)->rt_flags &
-	    (RTCF_BROADCAST | RTCF_MULTICAST))
+	if (skb->rtable->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
 		return 0;	/* discard, don't send a reset here */
 
 	if (dccp_bad_service_code(sk, service)) {
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 69e80bd..efe01df 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -475,7 +475,7 @@ int arp_find(unsigned char *haddr, struct sk_buff *skb)
 		return 1;
 	}
 
-	paddr = ((struct rtable*)skb->dst)->rt_gateway;
+	paddr = skb->rtable->rt_gateway;
 
 	if (arp_set_predefined(inet_addr_type(&init_net, paddr), haddr, paddr, dev))
 		return 0;
@@ -814,7 +814,7 @@ static int arp_process(struct sk_buff *skb)
 	if (arp->ar_op == htons(ARPOP_REQUEST) &&
 	    ip_route_input(skb, tip, sip, 0, dev) == 0) {
 
-		rt = (struct rtable*)skb->dst;
+		rt = skb->rtable;
 		addr_type = rt->rt_type;
 
 		if (addr_type == RTN_LOCAL) {
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index cee77d6..ff9a8e6 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -381,7 +381,7 @@ static void icmp_push_reply(struct icmp_bxm *icmp_param,
 static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 {
 	struct ipcm_cookie ipc;
-	struct rtable *rt = (struct rtable *)skb->dst;
+	struct rtable *rt = skb->rtable;
 	struct net *net = rt->u.dst.dev->nd_net;
 	struct sock *sk = icmp_sk(net);
 	struct inet_sock *inet = inet_sk(sk);
@@ -438,7 +438,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	struct iphdr *iph;
 	int room;
 	struct icmp_bxm icmp_param;
-	struct rtable *rt = (struct rtable *)skb_in->dst;
+	struct rtable *rt = skb_in->rtable;
 	struct ipcm_cookie ipc;
 	__be32 saddr;
 	u8  tos;
@@ -616,7 +616,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 					     RT_TOS(tos), rt2->u.dst.dev);
 
 			dst_release(&rt2->u.dst);
-			rt2 = (struct rtable *)skb_in->dst;
+			rt2 = skb_in->rtable;
 			skb_in->dst = odst;
 		}
 
@@ -943,7 +943,7 @@ static void icmp_address(struct sk_buff *skb)
 
 static void icmp_address_reply(struct sk_buff *skb)
 {
-	struct rtable *rt = (struct rtable *)skb->dst;
+	struct rtable *rt = skb->rtable;
 	struct net_device *dev = skb->dev;
 	struct in_device *in_dev;
 	struct in_ifaddr *ifa;
@@ -988,7 +988,7 @@ static void icmp_discard(struct sk_buff *skb)
 int icmp_rcv(struct sk_buff *skb)
 {
 	struct icmphdr *icmph;
-	struct rtable *rt = (struct rtable *)skb->dst;
+	struct rtable *rt = skb->rtable;
 
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 		int nh;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index d3f34a7..6a4ee8d 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -948,7 +948,7 @@ int igmp_rcv(struct sk_buff *skb)
 	case IGMPV2_HOST_MEMBERSHIP_REPORT:
 	case IGMPV3_HOST_MEMBERSHIP_REPORT:
 		/* Is it our report looped back? */
-		if (((struct rtable*)skb->dst)->fl.iif == 0)
+		if (skb->rtable->fl.iif == 0)
 			break;
 		/* don't rely on MC router hearing unicast reports */
 		if (skb->pkt_type == PACKET_MULTICAST ||
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 0b3b328..9d6d3be 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -80,7 +80,7 @@ int ip_forward(struct sk_buff *skb)
 	if (!xfrm4_route_forward(skb))
 		goto drop;
 
-	rt = (struct rtable*)skb->dst;
+	rt = skb->rtable;
 
 	if (opt->is_strictroute && rt->rt_dst != rt->rt_gateway)
 		goto sr_failed;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index e7821ba..f9ee844 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -619,7 +619,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 #ifdef CONFIG_NET_IPGRE_BROADCAST
 		if (ipv4_is_multicast(iph->daddr)) {
 			/* Looped back packet, drop it! */
-			if (((struct rtable*)skb->dst)->fl.iif == 0)
+			if (skb->rtable->fl.iif == 0)
 				goto drop;
 			tunnel->stat.multicast++;
 			skb->pkt_type = PACKET_BROADCAST;
@@ -699,7 +699,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 
 		if (skb->protocol == htons(ETH_P_IP)) {
-			rt = (struct rtable*)skb->dst;
+			rt = skb->rtable;
 			if ((dst = rt->rt_gateway) == 0)
 				goto tx_error_icmp;
 		}
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 6563139..d36e310 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -351,7 +351,7 @@ static int ip_rcv_finish(struct sk_buff *skb)
 	if (iph->ihl > 5 && ip_rcv_options(skb))
 		goto drop;
 
-	rt = (struct rtable*)skb->dst;
+	rt = skb->rtable;
 	if (rt->rt_type == RTN_MULTICAST)
 		IP_INC_STATS_BH(IPSTATS_MIB_INMCASTPKTS);
 	else if (rt->rt_type == RTN_BROADCAST)
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index baaedd9..df93a9c 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -107,7 +107,7 @@ int ip_options_echo(struct ip_options * dopt, struct sk_buff * skb)
 	sptr = skb_network_header(skb);
 	dptr = dopt->__data;
 
-	daddr = ((struct rtable*)skb->dst)->rt_spec_dst;
+	daddr = skb->rtable->rt_spec_dst;
 
 	if (sopt->rr) {
 		optlen  = sptr[sopt->rr+1];
@@ -258,7 +258,7 @@ int ip_options_compile(struct ip_options * opt, struct sk_buff * skb)
 	unsigned char * optptr;
 	int optlen;
 	unsigned char * pp_ptr = NULL;
-	struct rtable *rt = skb ? (struct rtable*)skb->dst : NULL;
+	struct rtable *rt = skb ? skb->rtable : NULL;
 
 	if (!opt) {
 		opt = &(IPCB(skb)->opt);
@@ -558,7 +558,7 @@ void ip_forward_options(struct sk_buff *skb)
 {
 	struct   ip_options * opt	= &(IPCB(skb)->opt);
 	unsigned char * optptr;
-	struct rtable *rt = (struct rtable*)skb->dst;
+	struct rtable *rt = skb->rtable;
 	unsigned char *raw = skb_network_header(skb);
 
 	if (opt->rr_needaddr) {
@@ -606,7 +606,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 	__be32 nexthop;
 	struct iphdr *iph = ip_hdr(skb);
 	unsigned char *optptr = skb_network_header(skb) + opt->srr;
-	struct rtable *rt = (struct rtable*)skb->dst;
+	struct rtable *rt = skb->rtable;
 	struct rtable *rt2;
 	int err;
 
@@ -631,13 +631,13 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 		}
 		memcpy(&nexthop, &optptr[srrptr-1], 4);
 
-		rt = (struct rtable*)skb->dst;
-		skb->dst = NULL;
+		rt = skb->rtable;
+		skb->rtable = NULL;
 		err = ip_route_input(skb, nexthop, iph->saddr, iph->tos, skb->dev);
-		rt2 = (struct rtable*)skb->dst;
+		rt2 = skb->rtable;
 		if (err || (rt2->rt_type != RTN_UNICAST && rt2->rt_type != RTN_LOCAL)) {
 			ip_rt_put(rt2);
-			skb->dst = &rt->u.dst;
+			skb->rtable = rt;
 			return -EINVAL;
 		}
 		ip_rt_put(rt);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 341779e..dc494ea 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -142,7 +142,7 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 			  __be32 saddr, __be32 daddr, struct ip_options *opt)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	struct rtable *rt = (struct rtable *)skb->dst;
+	struct rtable *rt = skb->rtable;
 	struct iphdr *iph;
 
 	/* Build the IP header. */
@@ -240,7 +240,7 @@ static int ip_finish_output(struct sk_buff *skb)
 int ip_mc_output(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
-	struct rtable *rt = (struct rtable*)skb->dst;
+	struct rtable *rt = skb->rtable;
 	struct net_device *dev = rt->u.dst.dev;
 
 	/*
@@ -321,7 +321,7 @@ int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
 	/* Skip all of this if the packet is already routed,
 	 * f.e. by something like SCTP.
 	 */
-	rt = (struct rtable *) skb->dst;
+	rt = skb->rtable;
 	if (rt != NULL)
 		goto packet_routed;
 
@@ -441,7 +441,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
 	unsigned int mtu, hlen, left, len, ll_rs, pad;
 	int offset;
 	__be16 not_last_frag;
-	struct rtable *rt = (struct rtable*)skb->dst;
+	struct rtable *rt = skb->rtable;
 	int err = 0;
 
 	dev = rt->u.dst.dev;
@@ -1357,7 +1357,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 	} replyopts;
 	struct ipcm_cookie ipc;
 	__be32 daddr;
-	struct rtable *rt = (struct rtable*)skb->dst;
+	struct rtable *rt = skb->rtable;
 
 	if (ip_options_echo(&replyopts.opt, skb))
 		return;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index de0572c..e7c9e4e 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -57,7 +57,7 @@
 static void ip_cmsg_recv_pktinfo(struct msghdr *msg, struct sk_buff *skb)
 {
 	struct in_pktinfo info;
-	struct rtable *rt = (struct rtable *)skb->dst;
+	struct rtable *rt = skb->rtable;
 
 	info.ipi_addr.s_addr = ip_hdr(skb)->daddr;
 	if (rt) {
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index dbaed69..894bce9 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -528,7 +528,7 @@ static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (!dst) {
 		/* NBMA tunnel */
-		if ((rt = (struct rtable*)skb->dst) == NULL) {
+		if ((rt = skb->rtable) == NULL) {
 			tunnel->stat.tx_fifo_errors++;
 			goto tx_error;
 		}
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a94f52c..7d63d74 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1283,7 +1283,7 @@ static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local
 	if (vif_table[vif].dev != skb->dev) {
 		int true_vifi;
 
-		if (((struct rtable*)skb->dst)->fl.iif == 0) {
+		if (skb->rtable->fl.iif == 0) {
 			/* It is our own packet, looped back.
 			   Very complicated situation...
 
@@ -1357,7 +1357,7 @@ dont_forward:
 int ip_mr_input(struct sk_buff *skb)
 {
 	struct mfc_cache *cache;
-	int local = ((struct rtable*)skb->dst)->rt_flags&RTCF_LOCAL;
+	int local = skb->rtable->rt_flags&RTCF_LOCAL;
 
 	/* Packet is looped back after forward, it should not be
 	   forwarded second time, but still can be delivered locally.
@@ -1594,7 +1594,7 @@ int ipmr_get_route(struct sk_buff *skb, struct rtmsg *rtm, int nowait)
 {
 	int err;
 	struct mfc_cache *cache;
-	struct rtable *rt = (struct rtable*)skb->dst;
+	struct rtable *rt = skb->rtable;
 
 	read_lock(&mrt_lock);
 	cache = ipmr_cache_find(rt->rt_src, rt->rt_dst);
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 313b3fc..c6817b1 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -77,7 +77,7 @@ masquerade_tg(struct sk_buff *skb, const struct net_device *in,
 		return NF_ACCEPT;
 
 	mr = targinfo;
-	rt = (struct rtable *)skb->dst;
+	rt = skb->rtable;
 	newsrc = inet_select_addr(out, rt->rt_gateway, RT_SCOPE_UNIVERSE);
 	if (!newsrc) {
 		printk("MASQUERADE: %s ate my IP address\n", out->name);
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index ca57f47..2fca727 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -139,7 +139,7 @@ nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 			 const char *rep_buffer,
 			 unsigned int rep_len)
 {
-	struct rtable *rt = (struct rtable *)skb->dst;
+	struct rtable *rt = skb->rtable;
 	struct iphdr *iph;
 	struct tcphdr *tcph;
 	int oldlen, datalen;
@@ -217,7 +217,7 @@ nf_nat_mangle_udp_packet(struct sk_buff *skb,
 			 const char *rep_buffer,
 			 unsigned int rep_len)
 {
-	struct rtable *rt = (struct rtable *)skb->dst;
+	struct rtable *rt = skb->rtable;
 	struct iphdr *iph;
 	struct udphdr *udph;
 	int datalen, oldlen;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8c3e165..1051326 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1289,7 +1289,7 @@ reject_redirect:
 
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 {
-	struct rtable *rt = (struct rtable*)dst;
+	struct rtable *rt = (struct rtable *)dst;
 	struct dst_entry *ret = dst;
 
 	if (rt) {
@@ -1330,7 +1330,7 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 
 void ip_rt_send_redirect(struct sk_buff *skb)
 {
-	struct rtable *rt = (struct rtable*)skb->dst;
+	struct rtable *rt = skb->rtable;
 	struct in_device *in_dev = in_dev_get(rt->u.dst.dev);
 
 	if (!in_dev)
@@ -1379,7 +1379,7 @@ out:
 
 static int ip_error(struct sk_buff *skb)
 {
-	struct rtable *rt = (struct rtable*)skb->dst;
+	struct rtable *rt = skb->rtable;
 	unsigned long now;
 	int code;
 
@@ -1548,7 +1548,7 @@ static void ipv4_link_failure(struct sk_buff *skb)
 
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_HOST_UNREACH, 0);
 
-	rt = (struct rtable *) skb->dst;
+	rt = skb->rtable;
 	if (rt)
 		dst_set_expires(&rt->u.dst, 0);
 }
@@ -1708,7 +1708,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	in_dev_put(in_dev);
 	hash = rt_hash(daddr, saddr, dev->ifindex);
-	return rt_intern_hash(hash, rth, (struct rtable**) &skb->dst);
+	return rt_intern_hash(hash, rth, &skb->rtable);
 
 e_nobufs:
 	in_dev_put(in_dev);
@@ -1869,7 +1869,7 @@ static inline int ip_mkroute_input(struct sk_buff *skb,
 
 	/* put it into the cache */
 	hash = rt_hash(daddr, saddr, fl->iif);
-	return rt_intern_hash(hash, rth, (struct rtable**)&skb->dst);
+	return rt_intern_hash(hash, rth, &skb->rtable);
 }
 
 /*
@@ -2025,7 +2025,7 @@ local_input:
 	}
 	rth->rt_type	= res.type;
 	hash = rt_hash(daddr, saddr, fl.iif);
-	err = rt_intern_hash(hash, rth, (struct rtable**)&skb->dst);
+	err = rt_intern_hash(hash, rth, &skb->rtable);
 	goto done;
 
 no_route:
@@ -2091,7 +2091,7 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			dst_use(&rth->u.dst, jiffies);
 			RT_CACHE_STAT_INC(in_hit);
 			rcu_read_unlock();
-			skb->dst = (struct dst_entry*)rth;
+			skb->rtable = rth;
 			return 0;
 		}
 		RT_CACHE_STAT_INC(in_hlist_search);
@@ -2598,7 +2598,7 @@ int ip_route_output_key(struct net *net, struct rtable **rp, struct flowi *flp)
 static int rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 			int nowait, unsigned int flags)
 {
-	struct rtable *rt = (struct rtable*)skb->dst;
+	struct rtable *rt = skb->rtable;
 	struct rtmsg *r;
 	struct nlmsghdr *nlh;
 	long expires;
@@ -2742,7 +2742,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 		err = ip_route_input(skb, dst, src, rtm->rtm_tos, dev);
 		local_bh_enable();
 
-		rt = (struct rtable*) skb->dst;
+		rt = skb->rtable;
 		if (err == 0 && rt->u.dst.error)
 			err = -rt->u.dst.error;
 	} else {
@@ -2762,7 +2762,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	if (err)
 		goto errout_free;
 
-	skb->dst = &rt->u.dst;
+	skb->rtable = rt;
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3873c4d..a79e324 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -552,7 +552,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	if (th->rst)
 		return;
 
-	if (((struct rtable *)skb->dst)->rt_type != RTN_LOCAL)
+	if (skb->rtable->rt_type != RTN_LOCAL)
 		return;
 
 	/* Swap the send and the receive. */
@@ -1262,8 +1262,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 #endif
 
 	/* Never answer to SYNs send to broadcast or multicast */
-	if (((struct rtable *)skb->dst)->rt_flags &
-	    (RTCF_BROADCAST | RTCF_MULTICAST))
+	if (skb->rtable->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
 		goto drop;
 
 	/* TW buckets are converted to open requests without
diff --git a/net/ipv4/udp_ipv4.c b/net/ipv4/udp_ipv4.c
index 40978de..fd14c2c 100644
--- a/net/ipv4/udp_ipv4.c
+++ b/net/ipv4/udp_ipv4.c
@@ -893,7 +893,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	struct sock *sk;
 	struct udphdr *uh = udp_hdr(skb);
 	unsigned short ulen;
-	struct rtable *rt = (struct rtable*)skb->dst;
+	struct rtable *rt = skb->rtable;
 	__be32 saddr = ip_hdr(skb)->saddr;
 	__be32 daddr = ip_hdr(skb)->daddr;
 
diff --git a/net/netfilter/nf_conntrack_netbios_ns.c b/net/netfilter/nf_conntrack_netbios_ns.c
index 9810d81..60dedad 100644
--- a/net/netfilter/nf_conntrack_netbios_ns.c
+++ b/net/netfilter/nf_conntrack_netbios_ns.c
@@ -47,7 +47,7 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 {
 	struct nf_conntrack_expect *exp;
 	struct iphdr *iph = ip_hdr(skb);
-	struct rtable *rt = (struct rtable *)skb->dst;
+	struct rtable *rt = skb->rtable;
 	struct in_device *in_dev;
 	__be32 mask = 0;
 
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 3da4129..72cf86e 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -256,10 +256,10 @@ META_COLLECTOR(int_rtclassid)
 
 META_COLLECTOR(int_rtiif)
 {
-	if (unlikely(skb->dst == NULL))
+	if (unlikely(skb->rtable == NULL))
 		*err = -1;
 	else
-		dst->value = ((struct rtable*) skb->dst)->fl.iif;
+		dst->value = skb->rtable->fl.iif;
 }
 
 /**************************************************************************
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 8d9d929..1afef08 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -363,7 +363,7 @@ static int sctp_v4_addr_valid(union sctp_addr *addr,
 		return 0;
 
 	/* Is this a broadcast address? */
-	if (skb && ((struct rtable *)skb->dst)->rt_flags & RTCF_BROADCAST)
+	if (skb && skb->rtable->rt_flags & RTCF_BROADCAST)
 		return 0;
 
 	return 1;
@@ -539,7 +539,7 @@ static void sctp_v4_get_saddr(struct sctp_association *asoc,
 /* What interface did this skb arrive on? */
 static int sctp_v4_skb_iif(const struct sk_buff *skb)
 {
-	return ((struct rtable *)skb->dst)->rt_iif;
+	return skb->rtable->rt_iif;
 }
 
 /* Was this packet marked by Explicit Congestion Notification? */
@@ -828,8 +828,8 @@ static inline int sctp_v4_xmit(struct sk_buff *skb,
 	SCTP_DEBUG_PRINTK("%s: skb:%p, len:%d, "
 			  "src:%u.%u.%u.%u, dst:%u.%u.%u.%u\n",
 			  __FUNCTION__, skb, skb->len,
-			  NIPQUAD(((struct rtable *)skb->dst)->rt_src),
-			  NIPQUAD(((struct rtable *)skb->dst)->rt_dst));
+			  NIPQUAD(skb->rtable->rt_src),
+			  NIPQUAD(skb->rtable->rt_dst));
 
 	SCTP_INC_STATS(SCTP_MIB_OUTSCTPPACKS);
 	return ip_queue_xmit(skb, ipfragok);

--------------010905060804090409030500--
