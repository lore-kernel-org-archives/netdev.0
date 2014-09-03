From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 1/2] ipv6: fix a refcnt leak with peer addr
Date: Wed,  3 Sep 2014 23:59:21 +0200
Message-ID: <1409781562-4191-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: yoshfuji@linux-ipv6.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40260 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756737AbaICV7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 17:59:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no reason to take a refcnt before deleting the peer address route.
It's done some lines below for the local prefix route because
inet6_ifa_finish_destroy() will release it at the end.
For the peer address route, we want to free it right now.

This bug has been introduced by commit
caeaba79009c ("ipv6: add support of peer address").

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/addrconf.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0b239fc1816e..e75ecb1e848b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4777,11 +4777,8 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 
 			rt = rt6_lookup(dev_net(dev), &ifp->peer_addr, NULL,
 					dev->ifindex, 1);
-			if (rt) {
-				dst_hold(&rt->dst);
-				if (ip6_del_rt(rt))
-					dst_free(&rt->dst);
-			}
+			if (rt && ip6_del_rt(rt))
+				dst_free(&rt->dst);
 		}
 		dst_hold(&ifp->rt->dst);
 
-- 
1.9.0
