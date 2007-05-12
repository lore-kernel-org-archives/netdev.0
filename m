From: Corey Mutter <crm-netdev@the-machine.mutternet.com>
Subject: [PATCH 1/1] Reverse sense of promisc tests in ip6_mc_input
Date: Sat, 12 May 2007 18:51:35 -0400
Message-ID: <20070512225135.GA1143@nc.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound.mailhop.org ([63.208.196.171]:1046 "EHLO
	outbound.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998AbXELXOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2007 19:14:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Corey Mutter <crm-netdev@mutternet.com>

Reverse the sense of the promiscuous-mode tests in ip6_mc_input(). 

Signed-off-by: Corey Mutter <crm-netdev@mutternet.com>

---

I had been suspicious of this code for a while, but just assumed I must 
have been missing something. However, I did some tests and, sure enough, 
I can open a socket and it will see IPv6 multicast packets come in, then 
the packets will stop coming in when I turn on IFF_ALLMULTI on the 
interface. 

In my tests, this change works more like I'd expect; I can open a 
socket, and it doesn't see any multicast packets (unless I join a group 
or something) until after I turn on IFF_ALLMULTI. 

--- linux-2.6.21.1/net/ipv6/ip6_input.c	2007-04-27 17:49:26.000000000 -0400
+++ linux/net/ipv6/ip6_input.c	2007-05-12 18:19:09.597750000 -0400
@@ -235,7 +235,7 @@ int ip6_mc_input(struct sk_buff *skb)
 	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_INMCASTPKTS);
 
 	hdr = skb->nh.ipv6h;
-	deliver = likely(!(skb->dev->flags & (IFF_PROMISC|IFF_ALLMULTI))) ||
+	deliver = unlikely(skb->dev->flags & (IFF_PROMISC|IFF_ALLMULTI)) ||
 	    ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, NULL);
 
 	/*
