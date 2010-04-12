From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/4] IPv6: only notify protocols if address is compeletely gone
Date: Mon, 12 Apr 2010 08:41:34 -0700
Message-ID: <20100412154255.896310012@vyatta.com>
References: <20100412154130.397252857@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:47335 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752540Ab0DLPqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 11:46:52 -0400
Content-Disposition: inline; filename=ipv6-addrconf4.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The notifier for address down should only be called if address is completely
gone, not just being marked as tentative on link transistion. The code
in net-next would case bonding/sctp/s390 to see address disappear on link
down, but they would never see it reappear on link up.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv6/addrconf.c	2010-04-11 14:34:36.919767724 -0700
+++ b/net/ipv6/addrconf.c	2010-04-11 14:35:00.533967946 -0700
@@ -2714,7 +2714,9 @@ static int addrconf_ifdown(struct net_de
 		}
 
 		__ipv6_ifa_notify(RTM_DELADDR, ifa);
-		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
+		if (ifa->dead)
+			atomic_notifier_call_chain(&inet6addr_chain,
+						   NETDEV_DOWN, ifa);
 		in6_ifa_put(ifa);
 
 		write_lock_bh(&idev->lock);

-- 

