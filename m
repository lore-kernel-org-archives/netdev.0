From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] ipv4/route/rtnl: get mcast attributes when dst is multicast
Date: Tue,  4 Dec 2012 12:03:07 +0100
Message-ID: <1354618987-15794-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56600 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765Ab2LDLDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 06:03:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f1ce3062c538 (ipv4: Remove 'rt_dst' from 'struct rtable') removes the
call to ipmr_get_route(), which will get multicast parameters of the route.

I revert the part of the patch that remove this call. I think the goal was only
to get rid of rt_dst field.

The patch is only compiled-tested. My first idea was to remove ipmr_get_route()
because rt_fill_info() was the only user, but it seems the previous patch cleans
the code a bit too much ;-)

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/route.c | 23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index df25142..69135ed 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2232,8 +2232,27 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 	error = rt->dst.error;
 
 	if (rt_is_input_route(rt)) {
-		if (nla_put_u32(skb, RTA_IIF, rt->rt_iif))
-			goto nla_put_failure;
+#ifdef CONFIG_IP_MROUTE
+		if (ipv4_is_multicast(dst) && !ipv4_is_local_multicast(dst) &&
+		    IPV4_DEVCONF_ALL(net, MC_FORWARDING)) {
+			int err = ipmr_get_route(net, skb,
+						 fl4->saddr, fl4->daddr,
+						 r, nowait);
+			if (err <= 0) {
+				if (!nowait) {
+					if (err == 0)
+						return 0;
+					goto nla_put_failure;
+				} else {
+					if (err == -EMSGSIZE)
+						goto nla_put_failure;
+					error = err;
+				}
+			}
+		} else
+#endif
+			if (nla_put_u32(skb, RTA_IIF, rt->rt_iif))
+				goto nla_put_failure;
 	}
 
 	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, expires, error) < 0)
-- 
1.8.0.1
