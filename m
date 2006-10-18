From: Thomas Graf <tgraf@suug.ch>
Subject: [IPv6] route: Fix prohibit and blackhole routing decision
Date: Wed, 18 Oct 2006 12:06:19 +0200
Message-ID: <20061018100619.GR12964@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:19850 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932143AbWJRKF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 06:05:59 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lookups resolving to ip6_blk_hole_entry must result in silently
discarding the packets whereas an ip6_pkt_prohibit_entry is
supposed to cause an ICMPV6_ADM_PROHIBITED message to be sent.

Thanks to Kim Nordlund <kim.nordlund@nokia.com> for noticing
this bug.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/ipv6/route.c
===================================================================
--- net-2.6.orig/net/ipv6/route.c	2006-10-18 11:06:45.000000000 +0200
+++ net-2.6/net/ipv6/route.c	2006-10-18 11:48:27.000000000 +0200
@@ -94,6 +94,9 @@
 
 static int		ip6_pkt_discard(struct sk_buff *skb);
 static int		ip6_pkt_discard_out(struct sk_buff *skb);
+static int		ip6_pkt_prohibit(struct sk_buff *skb);
+static int		ip6_pkt_prohibit_out(struct sk_buff *skb);
+static int		ip6_pkt_blk_hole(struct sk_buff *skb);
 static void		ip6_link_failure(struct sk_buff *skb);
 static void		ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
 
@@ -150,8 +153,8 @@
 			.obsolete	= -1,
 			.error		= -EACCES,
 			.metrics	= { [RTAX_HOPLIMIT - 1] = 255, },
-			.input		= ip6_pkt_discard,
-			.output		= ip6_pkt_discard_out,
+			.input		= ip6_pkt_prohibit,
+			.output		= ip6_pkt_prohibit_out,
 			.ops		= &ip6_dst_ops,
 			.path		= (struct dst_entry*)&ip6_prohibit_entry,
 		}
@@ -170,8 +173,8 @@
 			.obsolete	= -1,
 			.error		= -EINVAL,
 			.metrics	= { [RTAX_HOPLIMIT - 1] = 255, },
-			.input		= ip6_pkt_discard,
-			.output		= ip6_pkt_discard_out,
+			.input		= ip6_pkt_blk_hole,
+			.output		= ip6_pkt_blk_hole,
 			.ops		= &ip6_dst_ops,
 			.path		= (struct dst_entry*)&ip6_blk_hole_entry,
 		}
@@ -1743,24 +1746,46 @@
  *	Drop the packet on the floor
  */
 
-static int ip6_pkt_discard(struct sk_buff *skb)
+static inline int ip6_pkt_drop(struct sk_buff *skb, int code)
 {
 	int type = ipv6_addr_type(&skb->nh.ipv6h->daddr);
 	if (type == IPV6_ADDR_ANY || type == IPV6_ADDR_RESERVED)
 		IP6_INC_STATS(IPSTATS_MIB_INADDRERRORS);
 
 	IP6_INC_STATS(IPSTATS_MIB_OUTNOROUTES);
-	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_NOROUTE, 0, skb->dev);
+	icmpv6_send(skb, ICMPV6_DEST_UNREACH, code, 0, skb->dev);
 	kfree_skb(skb);
 	return 0;
 }
 
+static int ip6_pkt_discard(struct sk_buff *skb)
+{
+	return ip6_pkt_drop(skb, ICMPV6_NOROUTE);
+}
+
 static int ip6_pkt_discard_out(struct sk_buff *skb)
 {
 	skb->dev = skb->dst->dev;
 	return ip6_pkt_discard(skb);
 }
 
+static int ip6_pkt_prohibit(struct sk_buff *skb)
+{
+	return ip6_pkt_drop(skb, ICMPV6_ADM_PROHIBITED);
+}
+
+static int ip6_pkt_prohibit_out(struct sk_buff *skb)
+{
+	skb->dev = skb->dst->dev;
+	return ip6_pkt_prohibit(skb);
+}
+
+static int ip6_pkt_blk_hole(struct sk_buff *skb)
+{
+	kfree_skb(skb);
+	return 0;
+}
+
 /*
  *	Allocate a dst for local (unicast / anycast) address.
  */
