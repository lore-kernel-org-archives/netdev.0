From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/10] ipvs: Store a flow key in ip_vs_conn and use it in
 route lookups.
Date: Mon, 09 May 2011 22:31:23 -0700 (PDT)
Message-ID: <20110509.223123.28816978.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53411
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753366Ab1EJFbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 01:31:55 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8338724C087
	for <netdev@vger.kernel.org>; Mon,  9 May 2011 22:31:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a key step in being able to eliminate the remaining references
to rt->rt_{src,dst} in the IPVS code.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_vs.h             |    1 +
 net/netfilter/ipvs/ip_vs_xmit.c |   25 +++++++++++++++++--------
 2 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index e0b7f13..6122c71 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -481,6 +481,7 @@ struct ip_vs_conn {
 	struct net              *net;           /* Name space */
 #endif
 	/* Protocol, addresses and port numbers */
+	struct flowi		fl;
 	u16                     af;             /* address family */
 	__be16                  cport;
 	__be16                  vport;
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index e5ef75b..2a300fe 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -86,19 +86,25 @@ __ip_vs_dst_check(struct ip_vs_dest *dest, u32 rtos)
 
 /* Get route to destination or remote server */
 static struct rtable *
-__ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
+__ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_conn *cp,
+		   struct ip_vs_dest *dest,
 		   __be32 daddr, u32 rtos, int rt_mode)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
+	struct flowi4 *fl4;
 	struct rtable *rt;			/* Route to the other host */
 	struct rtable *ort;			/* Original route */
 	int local;
 
+	fl4 = &cp->fl.u.ip4;
 	if (dest) {
 		spin_lock(&dest->dst_lock);
 		if (!(rt = (struct rtable *)
 		      __ip_vs_dst_check(dest, rtos))) {
-			rt = ip_route_output(net, dest->addr.ip, 0, rtos, 0);
+			memset(fl4, 0, sizeof(*fl4));
+			fl4->daddr = dest->addr.ip;
+			fl4->flowi4_tos = rtos;
+			rt = ip_route_output_key(net, fl4);
 			if (IS_ERR(rt)) {
 				spin_unlock(&dest->dst_lock);
 				IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n",
@@ -113,7 +119,10 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 		daddr = dest->addr.ip;
 		spin_unlock(&dest->dst_lock);
 	} else {
-		rt = ip_route_output(net, daddr, 0, rtos, 0);
+		memset(fl4, 0, sizeof(*fl4));
+		fl4->daddr = daddr;
+		fl4->flowi4_tos = rtos;
+		rt = ip_route_output_key(net, fl4);
 		if (IS_ERR(rt)) {
 			IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n",
 				     &daddr);
@@ -386,7 +395,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	if (!(rt = __ip_vs_get_out_rt(skb, NULL, iph->daddr, RT_TOS(iph->tos),
+	if (!(rt = __ip_vs_get_out_rt(skb, cp, NULL, iph->daddr, RT_TOS(iph->tos),
 				      IP_VS_RT_MODE_NON_LOCAL)))
 		goto tx_error_icmp;
 
@@ -515,7 +524,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
 	}
 
-	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+	if (!(rt = __ip_vs_get_out_rt(skb, cp, cp->dest, cp->daddr.ip,
 				      RT_TOS(iph->tos),
 				      IP_VS_RT_MODE_LOCAL |
 					IP_VS_RT_MODE_NON_LOCAL |
@@ -763,7 +772,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+	if (!(rt = __ip_vs_get_out_rt(skb, cp, cp->dest, cp->daddr.ip,
 				      RT_TOS(tos), IP_VS_RT_MODE_LOCAL |
 						   IP_VS_RT_MODE_NON_LOCAL)))
 		goto tx_error_icmp;
@@ -994,7 +1003,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+	if (!(rt = __ip_vs_get_out_rt(skb, cp, cp->dest, cp->daddr.ip,
 				      RT_TOS(iph->tos),
 				      IP_VS_RT_MODE_LOCAL |
 					IP_VS_RT_MODE_NON_LOCAL)))
@@ -1141,7 +1150,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 * mangle and send the packet here (only for VS/NAT)
 	 */
 
-	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+	if (!(rt = __ip_vs_get_out_rt(skb, cp, cp->dest, cp->daddr.ip,
 				      RT_TOS(ip_hdr(skb)->tos),
 				      IP_VS_RT_MODE_LOCAL |
 					IP_VS_RT_MODE_NON_LOCAL |
-- 
1.7.5.1

