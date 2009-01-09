From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ipv6: address preservation on link down
Date: Thu, 8 Jan 2009 17:14:15 -0800
Message-ID: <20090108171415.1d282743@extreme>
References: <20090108135614.23aed603@extreme>
	<20090108.135819.103389689.davem@davemloft.net>
	<20090108140122.5488d84c@extreme>
	<20090108.140339.00980764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47975 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756966AbZAIBOR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 20:14:17 -0500
In-Reply-To: <20090108.140339.00980764.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an interface goes down, IPV6 deletes all addresses unlike IPV4. This
is a problem since it can break routing protocols and other applications.
It looks like this was done to handle DAD, but is a big stick solution when
other code is possible.

The following patch changes the behaviour to delete link local addresses
but keep all configured addresses and restart DAD when interface comes back up.

See also: https://kerneltrap.org/mailarchive/linux-netdev/2008/3/25/1252064/thread

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv6/addrconf.c	2009-01-08 16:43:04.921305933 -0800
+++ b/net/ipv6/addrconf.c	2009-01-08 16:47:04.000301344 -0800
@@ -2678,18 +2678,26 @@ static int addrconf_ifdown(struct net_de
 		write_lock_bh(&idev->lock);
 	}
 #endif
-	while ((ifa = idev->addr_list) != NULL) {
-		idev->addr_list = ifa->if_next;
-		ifa->if_next = NULL;
-		ifa->dead = 1;
-		addrconf_del_timer(ifa);
-		write_unlock_bh(&idev->lock);
-
-		__ipv6_ifa_notify(RTM_DELADDR, ifa);
-		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
-		in6_ifa_put(ifa);
-
-		write_lock_bh(&idev->lock);
+	/* clear regular address list on removal */
+	bifa = &idev->addr_list;
+	while ((ifa = *bifa) != NULL) {
+		if (how || (ipv6_addr_type(&ifa->addr) & IPV6_ADDR_LINKLOCAL)) {
+			*bifa = ifa->if_next;
+			ifa->if_next = NULL;
+			ifa->dead = 1;
+			addrconf_del_timer(ifa);
+			write_unlock_bh(&idev->lock);
+
+			__ipv6_ifa_notify(RTM_DELADDR, ifa);
+			atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
+			in6_ifa_put(ifa);
+
+			write_lock_bh(&idev->lock);
+		} else {
+			/* Force duplicate address detection when link resumes */
+			ifa->flags |= IFA_F_TENTATIVE;
+			bifa = &ifa->if_next;
+		}
 	}
 	write_unlock_bh(&idev->lock);
 
