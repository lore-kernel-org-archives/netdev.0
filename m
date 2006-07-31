From: weidong <weid@nanjing-fnst.com>
Subject: [patch 0/1]SNMPv2 "ipv6IfStatsInHdrErrors" counter error
Date: Mon, 31 Jul 2006 09:24:09 +0000 (UTC)
Message-ID: <1154425534.3329.2.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:29842 "EHLO
	localmail.nanjing-fnst.com") by vger.kernel.org with ESMTP
	id S1751499AbWGaJWm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 05:22:42 -0400
To: netdev@vger.kernel.org, davem@davemloft.net
Date: Tue, 01 Aug 2006 05:45:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, All
  When I tested Linux kernel 2.6.17.7 about statistics
"ipv6IfStatsInHdrErrors", found that this counter couldn't increase
correctly. The criteria is RFC2465:
  ipv6IfStatsInHdrErrors OBJECT-TYPE
      SYNTAX     Counter3
      MAX-ACCESS read-only
      STATUS     current
      DESCRIPTION
         "The number of input datagrams discarded due to
         errors in their IPv6 headers, including version
         number mismatch, other format errors, hop count
         exceeded, errors discovered in processing their
         IPv6 options, etc."
      ::= { ipv6IfStatsEntry 2 }

When I send TTL=0 and TTL=1 a packet to a router which need to be
forwarded, router just sends an ICMPv6 message to tell the sender that
TIME_EXCEED and HOPLIMITS, but no increments for this counter(in the
function ip6_forward).

The following is the patch for this issue. 

diff -ruN old/net/ipv6/ip6_output.c new/net/ipv6/ip6_output.c
--- old/net/ipv6/ip6_output.c	2006-07-25 11:36:01.000000000 +0800
+++ new/net/ipv6/ip6_output.c	2006-07-31 16:16:13.000000000 +0800
@@ -356,6 +356,7 @@
 		skb->dev = dst->dev;
 		icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT,
 			    0, skb->dev);
+		IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
 
 		kfree_skb(skb);
 		return -ETIMEDOUT;

signed-off-by:Wei Dong <weid@nanjing-fnst.com>

Regards
Wei Dong

