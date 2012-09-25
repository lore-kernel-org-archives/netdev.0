From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] ipv6: del unreachable route when an addr is deleted on lo
Date: Tue, 25 Sep 2012 12:24:59 +0200
Message-ID: <1348568699-3932-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:58897 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723Ab2IYKV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 06:21:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an address is added on loopback (ip -6 a a 2002::1/128 dev lo), two routes
are added:
 - one in the local table:
    local 2002::1 via :: dev lo  proto none  metric 0
 - one the in main table (for the prefix):
    unreachable 2002::1 dev lo  proto kernel  metric 256  error -101

When the address is deleted, the route inserted in the main table remains
because we use rt6_lookup(), which returns NULL when dst->error is set, which
is the case here! Thus, it is better to use ip6_route_lookup() to avoid this
kind of filter.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/addrconf.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6bc85f7..b6b2f9f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -788,8 +788,12 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 		struct in6_addr prefix;
 		struct rt6_info *rt;
 		struct net *net = dev_net(ifp->idev->dev);
+		struct flowi6 fl6 = {};
 		ipv6_addr_prefix(&prefix, &ifp->addr, ifp->prefix_len);
-		rt = rt6_lookup(net, &prefix, NULL, ifp->idev->dev->ifindex, 1);
+		fl6.flowi6_oif = ifp->idev->dev->ifindex;
+		fl6.daddr = prefix;
+		rt = (struct rt6_info *)ip6_route_lookup(net, &fl6,
+							 RT6_LOOKUP_F_IFACE);
 
 		if (rt && addrconf_is_prefix_route(rt)) {
 			if (onlink == 0) {
-- 
1.7.12
