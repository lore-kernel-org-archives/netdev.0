From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 6/12 net-2.6.25] [NETNS]: Add namespace parameter to ip_route_output_slow.
Date: Tue, 22 Jan 2008 18:59:23 +0300
Message-ID: <1201017566-16985-6-git-send-email-den@openvz.org>
References: <479612BE.8030409@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:54567 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752894AbYAVP7Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 10:59:25 -0500
In-Reply-To: <479612BE.8030409@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function needs a net namespace to lookup devices, fib tables, etc. in,
so pass it there.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/route.c |   22 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 674575b..c1f9950 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2248,7 +2248,8 @@ static inline int ip_mkroute_output(struct rtable **rp,
  * Major route resolver routine.
  */
 
-static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
+static int ip_route_output_slow(struct net *net, struct rtable **rp,
+				const struct flowi *oldflp)
 {
 	u32 tos	= RT_FL_TOS(oldflp);
 	struct flowi fl = { .nl_u = { .ip4_u =
@@ -2260,7 +2261,7 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 						  RT_SCOPE_UNIVERSE),
 				      } },
 			    .mark = oldflp->mark,
-			    .iif = init_net.loopback_dev->ifindex,
+			    .iif = net->loopback_dev->ifindex,
 			    .oif = oldflp->oif };
 	struct fib_result res;
 	unsigned flags = 0;
@@ -2282,7 +2283,7 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 			goto out;
 
 		/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
-		dev_out = ip_dev_find(&init_net, oldflp->fl4_src);
+		dev_out = ip_dev_find(net, oldflp->fl4_src);
 		if (dev_out == NULL)
 			goto out;
 
@@ -2322,7 +2323,7 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 
 
 	if (oldflp->oif) {
-		dev_out = dev_get_by_index(&init_net, oldflp->oif);
+		dev_out = dev_get_by_index(net, oldflp->oif);
 		err = -ENODEV;
 		if (dev_out == NULL)
 			goto out;
@@ -2356,15 +2357,15 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 			fl.fl4_dst = fl.fl4_src = htonl(INADDR_LOOPBACK);
 		if (dev_out)
 			dev_put(dev_out);
-		dev_out = init_net.loopback_dev;
+		dev_out = net->loopback_dev;
 		dev_hold(dev_out);
-		fl.oif = init_net.loopback_dev->ifindex;
+		fl.oif = net->loopback_dev->ifindex;
 		res.type = RTN_LOCAL;
 		flags |= RTCF_LOCAL;
 		goto make_route;
 	}
 
-	if (fib_lookup(&init_net, &fl, &res)) {
+	if (fib_lookup(net, &fl, &res)) {
 		res.fi = NULL;
 		if (oldflp->oif) {
 			/* Apparently, routing tables are wrong. Assume,
@@ -2403,7 +2404,7 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 			fl.fl4_src = fl.fl4_dst;
 		if (dev_out)
 			dev_put(dev_out);
-		dev_out = init_net.loopback_dev;
+		dev_out = net->loopback_dev;
 		dev_hold(dev_out);
 		fl.oif = dev_out->ifindex;
 		if (res.fi)
@@ -2419,7 +2420,7 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 	else
 #endif
 	if (!res.prefixlen && res.type == RTN_UNICAST && !fl.oif)
-		fib_select_default(&init_net, &fl, &res);
+		fib_select_default(net, &fl, &res);
 
 	if (!fl.fl4_src)
 		fl.fl4_src = FIB_RES_PREFSRC(res);
@@ -2469,7 +2469,7 @@ int __ip_route_output_key(struct rtable **rp, const struct flowi *flp)
 	}
 	rcu_read_unlock_bh();
 
-	return ip_route_output_slow(rp, flp);
+	return ip_route_output_slow(&init_net, rp, flp);
 }
 
 EXPORT_SYMBOL_GPL(__ip_route_output_key);
-- 
1.5.3.rc5

