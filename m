From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 2/3] sit: link local routes are missing
Date: Thu, 14 Nov 2013 13:51:06 +0100
Message-ID: <1384433467-4780-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1384433467-4780-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:45295 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026Ab3KNMva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 07:51:30 -0500
In-Reply-To: <1384433467-4780-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a link local address was added to a sit interface, the corresponding route
was not configured. This breaks routing protocols that use the link local
address, like OSPFv3.

To ease the code reading, I remove sit_route_add(), which only adds v4 mapped
routes, and add this kind of route directly in sit_add_v4_addrs(). Thus link
local and v4 mapped routes are configured in the same place.

Reported-by: Li Hongjun <hongjun.li@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/addrconf.c | 24 +++++-------------------
 1 file changed, 5 insertions(+), 19 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4e558e5e0e42..237bceb74c4e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2006,23 +2006,6 @@ static void addrconf_add_mroute(struct net_device *dev)
 	ip6_route_add(&cfg);
 }
 
-#if IS_ENABLED(CONFIG_IPV6_SIT)
-static void sit_route_add(struct net_device *dev)
-{
-	struct fib6_config cfg = {
-		.fc_table = RT6_TABLE_MAIN,
-		.fc_metric = IP6_RT_PRIO_ADDRCONF,
-		.fc_ifindex = dev->ifindex,
-		.fc_dst_len = 96,
-		.fc_flags = RTF_UP | RTF_NONEXTHOP,
-		.fc_nlinfo.nl_net = dev_net(dev),
-	};
-
-	/* prefix length - 96 bits "::d.d.d.d" */
-	ip6_route_add(&cfg);
-}
-#endif
-
 static struct inet6_dev *addrconf_add_dev(struct net_device *dev)
 {
 	struct inet6_dev *idev;
@@ -2556,6 +2539,7 @@ static void sit_add_v4_addrs(struct inet6_dev *idev)
 	struct net_device *dev;
 	struct net *net = dev_net(idev->dev);
 	int scope, plen;
+	u32 pflags = 0;
 
 	ASSERT_RTNL();
 
@@ -2569,10 +2553,12 @@ static void sit_add_v4_addrs(struct inet6_dev *idev)
 	} else {
 		scope = IPV6_ADDR_COMPATv4;
 		plen = 96;
+		pflags |= RTF_NONEXTHOP;
 	}
 
 	if (addr.s6_addr32[3]) {
 		add_addr(idev, &addr, plen, scope);
+		addrconf_prefix_route(&addr, plen, idev->dev, 0, pflags);
 		return;
 	}
 
@@ -2596,6 +2582,8 @@ static void sit_add_v4_addrs(struct inet6_dev *idev)
 				}
 
 				add_addr(idev, &addr, plen, flag);
+				addrconf_prefix_route(&addr, plen, idev->dev, 0,
+						      pflags);
 			}
 		}
 	}
@@ -2731,8 +2719,6 @@ static void addrconf_sit_config(struct net_device *dev)
 
 	if (dev->flags&IFF_POINTOPOINT)
 		addrconf_add_mroute(dev);
-	else
-		sit_route_add(dev);
 }
 #endif
 
-- 
1.8.4.1
