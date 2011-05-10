From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/10] ipvs: Remove all remaining references to
 rt->rt_{src,dst}
Date: Mon, 09 May 2011 22:31:27 -0700 (PDT)
Message-ID: <20110509.223127.102546540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53414
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751546Ab1EJFb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 01:31:59 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3B4A024C087
	for <netdev@vger.kernel.org>; Mon,  9 May 2011 22:31:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These values are always obtainable via the ip_vs_conn flow key.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/ipvs/ip_vs_core.c |    2 +-
 net/netfilter/ipvs/ip_vs_xmit.c |   17 +++++++++++++----
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 07accf6..fa8c1fd 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1384,7 +1384,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	    skb_rtable(skb)->rt_flags & RTCF_LOCAL) {
 		IP_VS_DBG(1, "%s(): "
 			  "local delivery to %pI4 but in FORWARD\n",
-			  __func__, &skb_rtable(skb)->rt_dst);
+			  __func__, &cp->fl.u.ip4.daddr);
 		verdict = NF_DROP;
 	}
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 2a300fe..99e7644 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -510,6 +510,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	struct rtable *rt;		/* Route to the other host */
 	int mtu;
 	struct iphdr *iph = ip_hdr(skb);
+	struct flowi4 *fl4;
 	int local;
 
 	EnterFunction(10);
@@ -549,8 +550,10 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	}
 #endif
 
+	fl4 = &cp->fl.u.ip4;
+
 	/* From world but DNAT to loopback address? */
-	if (local && ipv4_is_loopback(rt->rt_dst) &&
+	if (local && ipv4_is_loopback(fl4->daddr) &&
 	    rt_is_input_route(skb_rtable(skb))) {
 		IP_VS_DBG_RL_PKT(1, AF_INET, pp, skb, 0, "ip_vs_nat_xmit(): "
 				 "stopping DNAT to loopback address");
@@ -767,6 +770,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	__be16 df = old_iph->frag_off;
 	struct iphdr  *iph;			/* Our new IP header */
 	unsigned int max_headroom;		/* The extra header space needed */
+	struct flowi4 *fl4;
 	int    mtu;
 	int ret;
 
@@ -833,6 +837,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb_dst_drop(skb);
 	skb_dst_set(skb, &rt->dst);
 
+	fl4 = &cp->fl.u.ip4;
+
 	/*
 	 *	Push down and install the IPIP header.
 	 */
@@ -842,8 +848,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	iph->frag_off		=	df;
 	iph->protocol		=	IPPROTO_IPIP;
 	iph->tos		=	tos;
-	iph->daddr		=	rt->rt_dst;
-	iph->saddr		=	rt->rt_src;
+	iph->daddr		=	fl4->daddr;
+	iph->saddr		=	fl4->saddr;
 	iph->ttl		=	old_iph->ttl;
 	ip_select_ident(iph, &rt->dst, NULL);
 
@@ -1127,6 +1133,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		struct ip_vs_protocol *pp, int offset)
 {
 	struct rtable	*rt;	/* Route to the other host */
+	struct flowi4 *fl4;
 	int mtu;
 	int rc;
 	int local;
@@ -1176,8 +1183,10 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	}
 #endif
 
+	fl4 = &cp->fl.u.ip4;
+
 	/* From world but DNAT to loopback address? */
-	if (local && ipv4_is_loopback(rt->rt_dst) &&
+	if (local && ipv4_is_loopback(fl4->daddr) &&
 	    rt_is_input_route(skb_rtable(skb))) {
 		IP_VS_DBG(1, "%s(): "
 			  "stopping DNAT to loopback %pI4\n",
-- 
1.7.5.1

