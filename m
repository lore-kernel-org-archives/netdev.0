From: weidong <weid@nanjing-fnst.com>
Subject: SNMPv2 "ipFragFails" counter error
Date: Thu, 31 Aug 2006 09:55:53 +0000 (UTC)
Message-ID: <1157121575.2540.9.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:36491 "EHLO
	localmail.nanjing-fnst.com") by vger.kernel.org with ESMTP
	id S932076AbWHaJzh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 05:55:37 -0400
To: netdev@vger.kernel.org
Date: Fri, 01 Sep 2006 10:39:35 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, All
  When I tested Linux kernel 2.6.17.7 about statistics
"ipFragFails",found that this counter couldn't increase correctly. The
criteria is RFC2011:
RFC2011
  ipFragFails OBJECT-TYPE
    SYNTAX      Counter32
    MAX-ACCESS  read-only
    STATUS      current
    DESCRIPTION
            "The number of IP datagrams that have been discarded because
            they needed to be fragmented at this entity but could not
            be, e.g., because their Don't Fragment flag was set."
    ::= { ip 18 }

When I send big IP packet to a router with DF bit set to 1 which need to
be fragmented, and router just sends an ICMP error message
ICMP_FRAG_NEEDED but no increments for this counter(in the function
ip_fragment).

signed-off-by:Wei Dong <weid@nanjing-fnst.com>

diff -ruN old/net/ipv4/ip_output.c new/net/ipv4/ip_output.c
--- old/net/ipv4/ip_output.c	2006-07-25 11:36:01.000000000 +0800
+++ new/net/ipv4/ip_output.c	2006-08-30 14:30:49.000000000 +0800
@@ -441,6 +441,7 @@
 	iph = skb->nh.iph;
 
 	if (unlikely((iph->frag_off & htons(IP_DF)) && !skb->local_df)) {
+		IP_INC_STATS(IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(dst_mtu(&rt->u.dst)));
 		kfree_skb(skb);



