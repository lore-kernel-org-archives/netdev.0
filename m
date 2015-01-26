From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: replacing a rt6_info needs to purge possible propagated rt6_infos too
Date: Mon, 26 Jan 2015 15:11:17 +0100
Message-ID: <131075b1c8770c414675094c292d394316e8cd17.1422281427.git.hannes@stressinduktion.org>
Cc: lkundrak@v3.sk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:36485 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751910AbbAZOL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 09:11:29 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 932FE20857
	for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 09:11:28 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lubomir Rintel reported that during replacing a route the interface
reference counter isn't correctly decremented.

To quote bug <https://bugzilla.kernel.org/show_bug.cgi?id=91941>:
| [root@rhel7-5 lkundrak]# sh -x lal
| + ip link add dev0 type dummy
| + ip link set dev0 up
| + ip link add dev1 type dummy
| + ip link set dev1 up
| + ip addr add 2001:db8:8086::2/64 dev dev0
| + ip route add 2001:db8:8086::/48 dev dev0 proto static metric 20
| + ip route add 2001:db8:8088::/48 dev dev1 proto static metric 10
| + ip route replace 2001:db8:8086::/48 dev dev1 proto static metric 20
| + ip link del dev0 type dummy
| Message from syslogd@rhel7-5 at Jan 23 10:54:41 ...
|  kernel:unregister_netdevice: waiting for dev0 to become free. Usage count = 2
|
| Message from syslogd@rhel7-5 at Jan 23 10:54:51 ...
|  kernel:unregister_netdevice: waiting for dev0 to become free. Usage count = 2

During replacement of a rt6_info we must walk all parent nodes and check
if the to be replaced rt6_info got propagated. If so, replace it with
an alive one.

Reported-by: Lubomir Rintel <lkundrak@v3.sk>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_fib.c | 45 ++++++++++++++++++++++++++-------------------
 1 file changed, 26 insertions(+), 19 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 53775ee..263ef41 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -661,6 +661,29 @@ static int fib6_commit_metrics(struct dst_entry *dst, struct mx6_config *mxc)
 	return 0;
 }
 
+static void fib6_purge_rt(struct rt6_info *rt, struct fib6_node *fn,
+			  struct net *net)
+{
+	if (atomic_read(&rt->rt6i_ref) != 1) {
+		/* This route is used as dummy address holder in some split
+		 * nodes. It is not leaked, but it still holds other resources,
+		 * which must be released in time. So, scan ascendant nodes
+		 * and replace dummy references to this route with references
+		 * to still alive ones.
+		 */
+		while (fn) {
+			if (!(fn->fn_flags & RTN_RTINFO) && fn->leaf == rt) {
+				fn->leaf = fib6_find_prefix(net, fn);
+				atomic_inc(&fn->leaf->rt6i_ref);
+				rt6_release(rt);
+			}
+			fn = fn->parent;
+		}
+		/* No more references are possible at this point. */
+		BUG_ON(atomic_read(&rt->rt6i_ref) != 1);
+	}
+}
+
 /*
  *	Insert routing information in a node.
  */
@@ -808,11 +831,12 @@ add:
 		rt->dst.rt6_next = iter->dst.rt6_next;
 		atomic_inc(&rt->rt6i_ref);
 		inet6_rt_notify(RTM_NEWROUTE, rt, info);
-		rt6_release(iter);
 		if (!(fn->fn_flags & RTN_RTINFO)) {
 			info->nl_net->ipv6.rt6_stats->fib_route_nodes++;
 			fn->fn_flags |= RTN_RTINFO;
 		}
+		fib6_purge_rt(iter, fn, info->nl_net);
+		rt6_release(iter);
 	}
 
 	return 0;
@@ -1323,24 +1347,7 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 		fn = fib6_repair_tree(net, fn);
 	}
 
-	if (atomic_read(&rt->rt6i_ref) != 1) {
-		/* This route is used as dummy address holder in some split
-		 * nodes. It is not leaked, but it still holds other resources,
-		 * which must be released in time. So, scan ascendant nodes
-		 * and replace dummy references to this route with references
-		 * to still alive ones.
-		 */
-		while (fn) {
-			if (!(fn->fn_flags & RTN_RTINFO) && fn->leaf == rt) {
-				fn->leaf = fib6_find_prefix(net, fn);
-				atomic_inc(&fn->leaf->rt6i_ref);
-				rt6_release(rt);
-			}
-			fn = fn->parent;
-		}
-		/* No more references are possible at this point. */
-		BUG_ON(atomic_read(&rt->rt6i_ref) != 1);
-	}
+	fib6_purge_rt(rt, fn, net);
 
 	inet6_rt_notify(RTM_DELROUTE, rt, info);
 	rt6_release(rt);
-- 
2.1.0
