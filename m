From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 17/24] [IPV4]: Add ip_local_out
Date: Wed, 07 Nov 2007 22:08:33 +0800
Message-ID: <E1Ipla5-0001I8-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3765 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758096AbXKGO0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:26:34 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV4]: Add ip_local_out

Most callers of the LOCAL_OUT chain will set the IP packet length
and header checksum before doing so.  They also share the same output
function dst_output.

This patch creates a new function called ip_local_out which does all
of that and converts the appropriate users over to it.

Apart from removing duplicate code, it will also help in merging the
IPsec output path once the same thing is done for IPv6.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/ip.h                |    6 +++++
 include/net/ipip.h              |    5 +---
 net/ipv4/igmp.c                 |   12 +----------
 net/ipv4/ip_output.c            |   41 ++++++++++++++++++++++++++--------------
 net/ipv4/ipvs/ip_vs_xmit.c      |    6 +----
 net/ipv4/netfilter/ipt_REJECT.c |    8 -------
 net/ipv4/xfrm4_output.c         |    8 -------
 7 files changed, 41 insertions(+), 45 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 840dd91..dc60ea4 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -102,6 +102,12 @@ extern int		ip_mc_output(struct sk_buff *skb);
 extern int		ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
 extern int		ip_do_nat(struct sk_buff *skb);
 extern void		ip_send_check(struct iphdr *ip);
+extern int		__ip_local_out(struct sk_buff *skb);
+#ifdef CONFIG_NETFILTER
+extern int		ip_local_out(struct sk_buff *skb);
+#else
+#define ip_local_out	__ip_local_out
+#endif
 extern int		ip_queue_xmit(struct sk_buff *skb, int ipfragok);
 extern void		ip_init(void);
 extern int		ip_append_data(struct sock *sk,
diff --git a/include/net/ipip.h b/include/net/ipip.h
index 7cdc914..549e132 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -2,6 +2,7 @@
 #define __NET_IPIP_H 1
 
 #include <linux/if_tunnel.h>
+#include <net/ip.h>
 
 /* Keep error state on tunnel for 30 sec */
 #define IPTUNNEL_ERR_TIMEO	(30*HZ)
@@ -30,11 +31,9 @@ struct ip_tunnel
 	int pkt_len = skb->len;						\
 									\
 	skb->ip_summed = CHECKSUM_NONE;					\
-	iph->tot_len = htons(skb->len);					\
 	ip_select_ident(iph, &rt->u.dst, NULL);				\
-	ip_send_check(iph);						\
 									\
-	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev, dst_output);\
+	err = ip_local_out(skb);					\
 	if (net_xmit_eval(err) == 0) {					\
 		stats->tx_bytes += pkt_len;				\
 		stats->tx_packets++;					\
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 7dbc282..77fa2a8 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -349,17 +349,12 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 
 static int igmpv3_sendpack(struct sk_buff *skb)
 {
-	struct iphdr *pip = ip_hdr(skb);
 	struct igmphdr *pig = igmp_hdr(skb);
-	const int iplen = skb->tail - skb->network_header;
 	const int igmplen = skb->tail - skb->transport_header;
 
-	pip->tot_len = htons(iplen);
-	ip_send_check(pip);
 	pig->csum = ip_compute_csum(igmp_hdr(skb), igmplen);
 
-	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, skb->dev,
-		       dst_output);
+	return ip_local_out(skb);
 }
 
 static int grec_size(struct ip_mc_list *pmc, int type, int gdel, int sdel)
@@ -680,13 +675,11 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	iph->daddr    = dst;
 	iph->saddr    = rt->rt_src;
 	iph->protocol = IPPROTO_IGMP;
-	iph->tot_len  = htons(IGMP_SIZE);
 	ip_select_ident(iph, &rt->u.dst, NULL);
 	((u8*)&iph[1])[0] = IPOPT_RA;
 	((u8*)&iph[1])[1] = 4;
 	((u8*)&iph[1])[2] = 0;
 	((u8*)&iph[1])[3] = 0;
-	ip_send_check(iph);
 
 	ih = (struct igmphdr *)skb_put(skb, sizeof(struct igmphdr));
 	ih->type=type;
@@ -695,8 +688,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	ih->group=group;
 	ih->csum=ip_compute_csum((void *)ih, sizeof(struct igmphdr));
 
-	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		       dst_output);
+	return ip_local_out(skb);
 }
 
 static void igmp_gq_timer_expire(unsigned long data)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e5f7dc2..c652ddb 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -91,6 +91,30 @@ __inline__ void ip_send_check(struct iphdr *iph)
 	iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
 }
 
+int __ip_local_out(struct sk_buff *skb)
+{
+	struct iphdr *iph = ip_hdr(skb);
+
+	iph->tot_len = htons(skb->len);
+	ip_send_check(iph);
+	return nf_hook(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, skb->dst->dev,
+		       dst_output);
+}
+
+#ifdef CONFIG_NETFILTER
+int ip_local_out(struct sk_buff *skb)
+{
+	int err;
+
+	err = __ip_local_out(skb);
+	if (likely(err == 1))
+		err = dst_output(skb);
+
+	return err;
+}
+#endif
+EXPORT_SYMBOL_GPL(ip_local_out);
+
 /* dev_loopback_xmit for use with netfilter. */
 static int ip_dev_loopback_xmit(struct sk_buff *newskb)
 {
@@ -138,20 +162,17 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 	iph->daddr    = rt->rt_dst;
 	iph->saddr    = rt->rt_src;
 	iph->protocol = sk->sk_protocol;
-	iph->tot_len  = htons(skb->len);
 	ip_select_ident(iph, &rt->u.dst, sk);
 
 	if (opt && opt->optlen) {
 		iph->ihl += opt->optlen>>2;
 		ip_options_build(skb, opt, daddr, rt, 0);
 	}
-	ip_send_check(iph);
 
 	skb->priority = sk->sk_priority;
 
 	/* Send it out. */
-	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		       dst_output);
+	return ip_local_out(skb);
 }
 
 EXPORT_SYMBOL_GPL(ip_build_and_send_pkt);
@@ -347,7 +368,6 @@ packet_routed:
 	skb_reset_network_header(skb);
 	iph = ip_hdr(skb);
 	*((__be16 *)iph) = htons((4 << 12) | (5 << 8) | (inet->tos & 0xff));
-	iph->tot_len = htons(skb->len);
 	if (ip_dont_fragment(sk, &rt->u.dst) && !ipfragok)
 		iph->frag_off = htons(IP_DF);
 	else
@@ -366,13 +386,9 @@ packet_routed:
 	ip_select_ident_more(iph, &rt->u.dst, sk,
 			     (skb_shinfo(skb)->gso_segs ?: 1) - 1);
 
-	/* Add an IP checksum. */
-	ip_send_check(iph);
-
 	skb->priority = sk->sk_priority;
 
-	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		       dst_output);
+	return ip_local_out(skb);
 
 no_route:
 	IP_INC_STATS(IPSTATS_MIB_OUTNOROUTES);
@@ -1249,14 +1265,12 @@ int ip_push_pending_frames(struct sock *sk)
 		ip_options_build(skb, opt, inet->cork.addr, rt, 0);
 	}
 	iph->tos = inet->tos;
-	iph->tot_len = htons(skb->len);
 	iph->frag_off = df;
 	ip_select_ident(iph, &rt->u.dst, sk);
 	iph->ttl = ttl;
 	iph->protocol = sk->sk_protocol;
 	iph->saddr = rt->rt_src;
 	iph->daddr = rt->rt_dst;
-	ip_send_check(iph);
 
 	skb->priority = sk->sk_priority;
 	skb->dst = dst_clone(&rt->u.dst);
@@ -1266,8 +1280,7 @@ int ip_push_pending_frames(struct sock *sk)
 			skb_transport_header(skb))->type);
 
 	/* Netfilter gets whole the not fragmented skb. */
-	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
-		      skb->dst->dev, dst_output);
+	err = ip_local_out(skb);
 	if (err) {
 		if (err > 0)
 			err = inet->recverr ? net_xmit_errno(err) : 0;
diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
index 7c074e3..66775ad 100644
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -16,8 +16,8 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/ip.h>
 #include <linux/tcp.h>                  /* for tcphdr */
+#include <net/ip.h>
 #include <net/tcp.h>                    /* for csum_tcpudp_magic */
 #include <net/udp.h>
 #include <net/icmp.h>                   /* for icmp_send */
@@ -406,14 +406,12 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	iph->daddr		=	rt->rt_dst;
 	iph->saddr		=	rt->rt_src;
 	iph->ttl		=	old_iph->ttl;
-	iph->tot_len		=	htons(skb->len);
 	ip_select_ident(iph, &rt->u.dst, NULL);
-	ip_send_check(iph);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	ip_local_out(skb);
 
 	LeaveFunction(10);
 
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index dcf4d21..ccb2a03 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -90,7 +90,6 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 	/* Truncate to length (no data) */
 	tcph->doff = sizeof(struct tcphdr)/4;
 	skb_trim(nskb, ip_hdrlen(nskb) + sizeof(struct tcphdr));
-	niph->tot_len = htons(nskb->len);
 
 	if (tcph->ack) {
 		needs_ack = 0;
@@ -139,18 +138,13 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 	/* Adjust IP TTL */
 	niph->ttl = dst_metric(nskb->dst, RTAX_HOPLIMIT);
 
-	/* Adjust IP checksum */
-	niph->check = 0;
-	niph->check = ip_fast_csum(skb_network_header(nskb), niph->ihl);
-
 	/* "Never happens" */
 	if (nskb->len > dst_mtu(nskb->dst))
 		goto free_nskb;
 
 	nf_ct_attach(nskb, oldskb);
 
-	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, nskb, NULL, nskb->dst->dev,
-		dst_output);
+	ip_local_out(nskb);
 	return;
 
  free_nskb:
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 13fd113..0ffc3d0 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -69,17 +69,12 @@ EXPORT_SYMBOL(xfrm4_prepare_output);
 
 static inline int xfrm4_output_one(struct sk_buff *skb)
 {
-	struct iphdr *iph;
 	int err;
 
 	err = xfrm_output(skb);
 	if (err)
 		goto error_nolock;
 
-	iph = ip_hdr(skb);
-	iph->tot_len = htons(skb->len);
-	ip_send_check(iph);
-
 	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
 	err = 0;
 
@@ -97,8 +92,7 @@ static int xfrm4_output_finish2(struct sk_buff *skb)
 	while (likely((err = xfrm4_output_one(skb)) == 0)) {
 		nf_reset(skb);
 
-		err = nf_hook(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
-			      skb->dst->dev, dst_output);
+		err = __ip_local_out(skb);
 		if (unlikely(err != 1))
 			break;
 
