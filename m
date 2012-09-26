From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH] ipv6: don't add link local route when there is no link local address
Date: Wed, 26 Sep 2012 15:09:22 +0200
Message-ID: <1348664962-4018-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:32893 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753619Ab2IZNGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 09:06:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an address is added on loopback (ip -6 a a 2002::1/128 dev lo), a route
to fe80::/64 is added in the main table:
  unreachable fe80::/64 dev lo  proto kernel  metric 256  error -101

This route does not match any prefix (no fe80:: address on lo). In fact,
addrconf_dev_config() will not add link local address because this function
filters interfaces by type. If the link local address is added manually, the
route to the link local prefix will be automatically added by
addrconf_add_linklocal().
Note also, that this route is not deleted when the address is removed.

After looking at the code, it seems that addrconf_add_lroute() is redundant with
addrconf_add_linklocal(), because this function will add the link local route
when the link local address is configured.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/addrconf.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ea3e9af..041664b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1782,14 +1782,6 @@ static void sit_route_add(struct net_device *dev)
 }
 #endif
 
-static void addrconf_add_lroute(struct net_device *dev)
-{
-	struct in6_addr addr;
-
-	ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
-	addrconf_prefix_route(&addr, 64, dev, 0, 0);
-}
-
 static struct inet6_dev *addrconf_add_dev(struct net_device *dev)
 {
 	struct inet6_dev *idev;
@@ -1807,8 +1799,6 @@ static struct inet6_dev *addrconf_add_dev(struct net_device *dev)
 	if (!(dev->flags & IFF_LOOPBACK))
 		addrconf_add_mroute(dev);
 
-	/* Add link local route */
-	addrconf_add_lroute(dev);
 	return idev;
 }
 
@@ -2489,7 +2479,6 @@ static void addrconf_sit_config(struct net_device *dev)
 
 	if (dev->flags&IFF_POINTOPOINT) {
 		addrconf_add_mroute(dev);
-		addrconf_add_lroute(dev);
 	} else
 		sit_route_add(dev);
 }
-- 
1.7.12
