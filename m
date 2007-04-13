From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6] SNMP: Fix {In,Out}NoRoutes statistics.
Date: Fri, 13 Apr 2007 17:39:48 +0900 (JST)
Message-ID: <20070413.173948.133962302.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	mitch@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:41485 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752906AbXDMIiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 04:38:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A packet which is being discarded because of no routes in the
forwarding path should not be counted as OutNoRoutes but as
InNoRoutes.
Additionally, on this occasion, a packet whose destinaion is
not valid should be counted as InAddrErrors separately.

Based on patch from Mitsuru Chinen <mitch@linux.vnet.ibm.com>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/route.c |   31 ++++++++++++++++++++-----------
 1 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3931b33..ad058a9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1775,13 +1775,22 @@ int ipv6_route_ioctl(unsigned int cmd, void __user *arg)
  *	Drop the packet on the floor
  */
 
-static inline int ip6_pkt_drop(struct sk_buff *skb, int code)
-{
-	int type = ipv6_addr_type(&skb->nh.ipv6h->daddr);
-	if (type == IPV6_ADDR_ANY || type == IPV6_ADDR_RESERVED)
-		IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_INADDRERRORS);
-
-	IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_OUTNOROUTES);
+static inline int ip6_pkt_drop(struct sk_buff *skb, int code,
+			       int ipstats_mib_noroutes)
+{
+	int type;
+	switch (ipstats_mib_noroutes) {
+	case IPSTATS_MIB_INNOROUTES:
+		type = ipv6_addr_type(&skb->nh.ipv6h->daddr);
+		if (type == IPV6_ADDR_ANY || type == IPV6_ADDR_RESERVED) {
+			IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_INADDRERRORS);
+			break;
+		}
+		/* FALLTHROUGH */
+	case IPSTATS_MIB_OUTNOROUTES:
+		IP6_INC_STATS(ip6_dst_idev(skb->dst), ipstats_mib_noroutes);
+		break;
+	}
 	icmpv6_send(skb, ICMPV6_DEST_UNREACH, code, 0, skb->dev);
 	kfree_skb(skb);
 	return 0;
@@ -1789,26 +1798,26 @@ static inline int ip6_pkt_drop(struct sk_buff *skb, int code)
 
 static int ip6_pkt_discard(struct sk_buff *skb)
 {
-	return ip6_pkt_drop(skb, ICMPV6_NOROUTE);
+	return ip6_pkt_drop(skb, ICMPV6_NOROUTE, IPSTATS_MIB_INNOROUTES);
 }
 
 static int ip6_pkt_discard_out(struct sk_buff *skb)
 {
 	skb->dev = skb->dst->dev;
-	return ip6_pkt_discard(skb);
+	return ip6_pkt_drop(skb, ICMPV6_NOROUTE, IPSTATS_MIB_OUTNOROUTES);
 }
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 
 static int ip6_pkt_prohibit(struct sk_buff *skb)
 {
-	return ip6_pkt_drop(skb, ICMPV6_ADM_PROHIBITED);
+	return ip6_pkt_drop(skb, ICMPV6_ADM_PROHIBITED, IPSTATS_MIB_INNOROUTES);
 }
 
 static int ip6_pkt_prohibit_out(struct sk_buff *skb)
 {
 	skb->dev = skb->dst->dev;
-	return ip6_pkt_prohibit(skb);
+	return ip6_pkt_drop(skb, ICMPV6_ADM_PROHIBITED, IPSTATS_MIB_OUTNOROUTES);
 }
 
 static int ip6_pkt_blk_hole(struct sk_buff *skb)
-- 
1.5.1


