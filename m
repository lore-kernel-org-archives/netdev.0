From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ipv6: use rt6_get_dflt_router to get default router in rt6_route_rcv
Date: Fri, 08 Nov 2013 09:56:53 +0800
Message-ID: <527C44E5.70606@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:2137 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751010Ab3KHB7X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 20:59:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As the rfc 4191 said, the Router Preference and Lifetime values in a
::/0 Route Information Option should override the preference and lifetime
values in the Router Advertisement header. But when the kernel deals with
a ::/0 Route Information Option, the rt6_get_route_info() always return
NULL, that means that overriding will not happen, because those default
routers were added without flag RTF_ROUTEINFO in rt6_add_dflt_router().

In order to deal with that condition, we should call rt6_get_dflt_router
when the prefix length is 0.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/route.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c28cdda..7faa9d5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -731,8 +731,11 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 		prefix = &prefix_buf;
 	}
 
-	rt = rt6_get_route_info(net, prefix, rinfo->prefix_len, gwaddr,
-				dev->ifindex);
+	if (rinfo->prefix_len == 0)
+		rt = rt6_get_dflt_router(gwaddr, dev);
+	else
+		rt = rt6_get_route_info(net, prefix, rinfo->prefix_len,
+					gwaddr, dev->ifindex);
 
 	if (rt && !lifetime) {
 		ip6_del_rt(rt);
-- 
1.8.3.1
