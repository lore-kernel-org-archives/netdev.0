From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipv6: Not need to get address prefix
Date: Fri, 20 Dec 2013 13:39:54 +0800
Message-ID: <1387517994-11707-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:64854 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308Ab3LTFkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 00:40:08 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so2144366pbb.17
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 21:40:07 -0800 (PST)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id ye1sm14962363pab.19.2013.12.19.21.40.02
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 21:40:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Since addrconf_get_prefix_route and rt6_get_route_info input the address prefix
to fib6_locate, which does not uses the data which is out of the prefix_len length,
so do not need to use ipv6_addr_prefix to get address prefix for them.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/addrconf.c |    5 +----
 net/ipv6/route.c    |   17 +++--------------
 2 files changed, 4 insertions(+), 18 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3c3425e..def65f6 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -988,12 +988,9 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 	 * --yoshfuji
 	 */
 	if ((ifp->flags & IFA_F_PERMANENT) && onlink < 1) {
-		struct in6_addr prefix;
 		struct rt6_info *rt;
 
-		ipv6_addr_prefix(&prefix, &ifp->addr, ifp->prefix_len);
-
-		rt = addrconf_get_prefix_route(&prefix,
+		rt = addrconf_get_prefix_route(&ifp->addr,
 					       ifp->prefix_len,
 					       ifp->idev->dev,
 					       0, RTF_GATEWAY | RTF_DEFAULT);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 89b2735..47dfc5b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -694,7 +694,6 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 {
 	struct net *net = dev_net(dev);
 	struct route_info *rinfo = (struct route_info *) opt;
-	struct in6_addr prefix_buf, *prefix;
 	unsigned int pref;
 	unsigned long lifetime;
 	struct rt6_info *rt;
@@ -724,20 +723,10 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 
 	lifetime = addrconf_timeout_fixup(ntohl(rinfo->lifetime), HZ);
 
-	if (rinfo->length == 3)
-		prefix = (struct in6_addr *)rinfo->prefix;
-	else {
-		/* this function is safe */
-		ipv6_addr_prefix(&prefix_buf,
-				 (struct in6_addr *)rinfo->prefix,
-				 rinfo->prefix_len);
-		prefix = &prefix_buf;
-	}
-
 	if (rinfo->prefix_len == 0)
 		rt = rt6_get_dflt_router(gwaddr, dev);
 	else
-		rt = rt6_get_route_info(net, prefix, rinfo->prefix_len,
+		rt = rt6_get_route_info(net, rinfo->prefix, rinfo->prefix_len,
 					gwaddr, dev->ifindex);
 
 	if (rt && !lifetime) {
@@ -746,8 +735,8 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 	}
 
 	if (!rt && lifetime)
-		rt = rt6_add_route_info(net, prefix, rinfo->prefix_len, gwaddr, dev->ifindex,
-					pref);
+		rt = rt6_add_route_info(net, rinfo->prefix, rinfo->prefix_len,
+					gwaddr, dev->ifindex, pref);
 	else if (rt)
 		rt->rt6i_flags = RTF_ROUTEINFO |
 				 (rt->rt6i_flags & ~RTF_PREF_MASK) | RTF_PREF(pref);
-- 
1.7.10.4
