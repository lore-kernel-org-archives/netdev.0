From: kaber@trash.net
Subject: [PATCH 11/13] ipvs: use enum to instead of magic numbers
Date: Wed,  2 Mar 2011 13:12:51 +0100
Message-ID: <1299067973-15977-12-git-send-email-kaber@trash.net>
References: <1299067973-15977-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32946 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757286Ab1CBMNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 07:13:02 -0500
In-Reply-To: <1299067973-15977-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c |   41 +++++++++++++++++++++++++-------------
 1 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 1f2a4e3..a48239a 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -43,6 +43,13 @@
 
 #include <net/ip_vs.h>
 
+enum {
+	IP_VS_RT_MODE_LOCAL	= 1, /* Allow local dest */
+	IP_VS_RT_MODE_NON_LOCAL	= 2, /* Allow non-local dest */
+	IP_VS_RT_MODE_RDR	= 4, /* Allow redirect from remote daddr to
+				      * local
+				      */
+};
 
 /*
  *      Destination cache to speed up outgoing route lookup
@@ -77,11 +84,7 @@ __ip_vs_dst_check(struct ip_vs_dest *dest, u32 rtos)
 	return dst;
 }
 
-/*
- * Get route to destination or remote server
- * rt_mode: flags, &1=Allow local dest, &2=Allow non-local dest,
- *	    &4=Allow redirect from remote daddr to local
- */
+/* Get route to destination or remote server */
 static struct rtable *
 __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 		   __be32 daddr, u32 rtos, int rt_mode)
@@ -126,15 +129,16 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 	}
 
 	local = rt->rt_flags & RTCF_LOCAL;
-	if (!((local ? 1 : 2) & rt_mode)) {
+	if (!((local ? IP_VS_RT_MODE_LOCAL : IP_VS_RT_MODE_NON_LOCAL) &
+	      rt_mode)) {
 		IP_VS_DBG_RL("Stopping traffic to %s address, dest: %pI4\n",
 			     (rt->rt_flags & RTCF_LOCAL) ?
 			     "local":"non-local", &rt->rt_dst);
 		ip_rt_put(rt);
 		return NULL;
 	}
-	if (local && !(rt_mode & 4) && !((ort = skb_rtable(skb)) &&
-					 ort->rt_flags & RTCF_LOCAL)) {
+	if (local && !(rt_mode & IP_VS_RT_MODE_RDR) &&
+	    !((ort = skb_rtable(skb)) && ort->rt_flags & RTCF_LOCAL)) {
 		IP_VS_DBG_RL("Redirect from non-local address %pI4 to local "
 			     "requires NAT method, dest: %pI4\n",
 			     &ip_hdr(skb)->daddr, &rt->rt_dst);
@@ -383,8 +387,8 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	if (!(rt = __ip_vs_get_out_rt(skb, NULL, iph->daddr,
-				      RT_TOS(iph->tos), 2)))
+	if (!(rt = __ip_vs_get_out_rt(skb, NULL, iph->daddr, RT_TOS(iph->tos),
+				      IP_VS_RT_MODE_NON_LOCAL)))
 		goto tx_error_icmp;
 
 	/* MTU checking */
@@ -512,7 +516,10 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	}
 
 	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
-				      RT_TOS(iph->tos), 1|2|4)))
+				      RT_TOS(iph->tos),
+				      IP_VS_RT_MODE_LOCAL |
+					IP_VS_RT_MODE_NON_LOCAL |
+					IP_VS_RT_MODE_RDR)))
 		goto tx_error_icmp;
 	local = rt->rt_flags & RTCF_LOCAL;
 	/*
@@ -755,7 +762,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
-				      RT_TOS(tos), 1|2)))
+				      RT_TOS(tos), IP_VS_RT_MODE_LOCAL |
+						   IP_VS_RT_MODE_NON_LOCAL)))
 		goto tx_error_icmp;
 	if (rt->rt_flags & RTCF_LOCAL) {
 		ip_rt_put(rt);
@@ -984,7 +992,9 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
-				      RT_TOS(iph->tos), 1|2)))
+				      RT_TOS(iph->tos),
+				      IP_VS_RT_MODE_LOCAL |
+					IP_VS_RT_MODE_NON_LOCAL)))
 		goto tx_error_icmp;
 	if (rt->rt_flags & RTCF_LOCAL) {
 		ip_rt_put(rt);
@@ -1128,7 +1138,10 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 */
 
 	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
-				      RT_TOS(ip_hdr(skb)->tos), 1|2|4)))
+				      RT_TOS(ip_hdr(skb)->tos),
+				      IP_VS_RT_MODE_LOCAL |
+					IP_VS_RT_MODE_NON_LOCAL |
+					IP_VS_RT_MODE_RDR)))
 		goto tx_error_icmp;
 	local = rt->rt_flags & RTCF_LOCAL;
 
-- 
1.7.4

