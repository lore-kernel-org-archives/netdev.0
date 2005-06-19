From: Lv Liangying <lvly@nanjing-fnst.com>
Subject: SNMPv2 "ipv6IfStatsInAddrErrors" counter error
Date: Sun, 19 Jun 2005 16:45:04 -0400
Message-ID: <1119213904.2569.23.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:32668 "EHLO
	localmail.nanjing-fnst.com") by vger.kernel.org with ESMTP
	id S1751334AbWHUDL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:11:28 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, All

   When I tested Linux kernel 2.6.17.7 about statistics
"ipv6IfStatsInAddrErrors", found that this counter couldn't increase
correctly. The criteria is RFC2465:
 ipv6IfStatsInAddrErrors OBJECT-TYPE
      SYNTAX      Counter32
      MAX-ACCESS  read-only
      STATUS      current
      DESCRIPTION
         "The number of input datagrams discarded because
         the IPv6 address in their IPv6 header's destination
         field was not a valid address to be received at
         this entity.  This count includes invalid
         addresses (e.g., ::0) and unsupported addresses
         (e.g., addresses with unallocated prefixes).  For
         entities which are not IPv6 routers and therefore
         do not forward datagrams, this counter includes
         datagrams discarded because the destination address
         was not a local address."
      ::= { ipv6IfStatsEntry 5 }

When I send packet to host with destination that is ether invalid
address(::0) or unsupported addresses(1::1), the Linux kernel just
discard the packet, and the counter doesn't increase(in the function
ip6_pkt_discard).

signed-off by Lv Liangying <lvly@nanjing-fnst.com>

--- old/net/ipv6/route.c	2006-07-25 11:36:01.000000000 +0800
+++ new/net/ipv6/route.c	2006-08-08 16:13:04.000000000 +0800
@@ -1526,6 +1526,10 @@
 
 static int ip6_pkt_discard(struct sk_buff *skb)
 {
+	int type = ipv6_addr_type(&skb->nh.ipv6h->daddr);
+	if (type == IPV6_ADDR_ANY || type == IPV6_ADDR_RESERVED)
+		IP6_INC_STATS(IPSTATS_MIB_INADDRERRORS);
+
 	IP6_INC_STATS(IPSTATS_MIB_OUTNOROUTES);
 	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_NOROUTE, 0, skb->dev);
 	kfree_skb(skb);



