From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 1/3] sit: fix prefix length of ll and v4mapped addresses
Date: Thu, 14 Nov 2013 13:51:05 +0100
Message-ID: <1384433467-4780-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:45296 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089Ab3KNMva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 07:51:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the local IPv4 endpoint is wilcard (0.0.0.0), the prefix length is
correctly set, ie 64 if the address is a link local one or 96 if the address is
a v4 mapped one.
But when the local endpoint is specified, the prefix length is set to 128 for
both kind of address. This patch fix this wrong prefix length.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/addrconf.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cd3fb301da38..4e558e5e0e42 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2555,7 +2555,7 @@ static void sit_add_v4_addrs(struct inet6_dev *idev)
 	struct in6_addr addr;
 	struct net_device *dev;
 	struct net *net = dev_net(idev->dev);
-	int scope;
+	int scope, plen;
 
 	ASSERT_RTNL();
 
@@ -2565,12 +2565,14 @@ static void sit_add_v4_addrs(struct inet6_dev *idev)
 	if (idev->dev->flags&IFF_POINTOPOINT) {
 		addr.s6_addr32[0] = htonl(0xfe800000);
 		scope = IFA_LINK;
+		plen = 64;
 	} else {
 		scope = IPV6_ADDR_COMPATv4;
+		plen = 96;
 	}
 
 	if (addr.s6_addr32[3]) {
-		add_addr(idev, &addr, 128, scope);
+		add_addr(idev, &addr, plen, scope);
 		return;
 	}
 
@@ -2582,7 +2584,6 @@ static void sit_add_v4_addrs(struct inet6_dev *idev)
 			int flag = scope;
 
 			for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next) {
-				int plen;
 
 				addr.s6_addr32[3] = ifa->ifa_local;
 
@@ -2593,10 +2594,6 @@ static void sit_add_v4_addrs(struct inet6_dev *idev)
 						continue;
 					flag |= IFA_HOST;
 				}
-				if (idev->dev->flags&IFF_POINTOPOINT)
-					plen = 64;
-				else
-					plen = 96;
 
 				add_addr(idev, &addr, plen, flag);
 			}
-- 
1.8.4.1
