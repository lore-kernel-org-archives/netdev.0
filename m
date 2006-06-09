From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] ipv6: order addresses by scope
Date: Fri, 09 Jun 2006 14:14:50 -0400
Message-ID: <4489BA9A.9050508@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070709050202080305070905"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:42654 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1751466AbWFISOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 14:14:53 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070709050202080305070905
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

If IPv6 addresses are ordered by scope, then ipv6_dev_get_saddr() can 
break-out of the device addr_list for() loop when the candidate source 
address scope is less than the destination address scope.

Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------070709050202080305070905
Content-Type: text/x-patch;
 name="ip6order.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ip6order.patch"

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 445006e..e1d6a6f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -509,6 +509,25 @@ void inet6_ifa_finish_destroy(struct ine
 	kfree(ifp);
 }
 
+static void
+ipv6_link_dev_addr(struct inet6_dev *idev, struct inet6_ifaddr *ifp)
+{
+	struct inet6_ifaddr *ifa, **ifap;
+
+	/*
+	 * Each device address list is sorted in order of scope -
+	 * global before linklocal.
+	 */
+	for (ifap = &idev->addr_list; (ifa = *ifap) != NULL;
+	     ifap = &ifa->if_next) {
+		if (ifp->scope > ifa->scope)
+			break;
+	}
+
+	ifp->if_next = *ifap;
+	*ifap = ifp;
+}
+
 /* On success it returns ifp with increased reference count */
 
 static struct inet6_ifaddr *
@@ -574,8 +593,7 @@ ipv6_add_addr(struct inet6_dev *idev, co
 
 	write_lock(&idev->lock);
 	/* Add to inet6_dev unicast addr list. */
-	ifa->if_next = idev->addr_list;
-	idev->addr_list = ifa;
+	ipv6_link_dev_addr(idev, ifa);
 
 #ifdef CONFIG_IPV6_PRIVACY
 	if (ifa->flags&IFA_F_TEMPORARY) {
@@ -982,7 +1000,7 @@ int ipv6_dev_get_saddr(struct net_device
 					continue;
 			} else if (score.scope < hiscore.scope) {
 				if (score.scope < daddr_scope)
-					continue;
+					break; /* addresses sorted by scope */
 				else {
 					score.rule = 2;
 					goto record_it;

--------------070709050202080305070905--
