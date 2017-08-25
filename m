From: Wei Wang <weiwan@google.com>
Subject: [PATCH net] ipv6: fix sparse warning on rt6i_node
Date: Fri, 25 Aug 2017 15:03:10 -0700
Message-ID: <20170825220310.24863-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33466 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933339AbdHYWDY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 18:03:24 -0400
Received: by mail-pg0-f42.google.com with SMTP id t3so5587342pgt.0
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 15:03:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Commit c5cff8561d2d adds rcu grace period before freeing fib6_node. This
generates a new sparse warning on rt->rt6i_node related code:
  net/ipv6/route.c:1394:30: error: incompatible types in comparison
  expression (different address spaces)
  ./include/net/ip6_fib.h:187:14: error: incompatible types in comparison
  expression (different address spaces)

This commit adds "__rcu" tag for rt6i_node and makes sure corresponding
rcu API is used for it.
After this fix, sparse no longer generates the above warning.

Fixes: c5cff8561d2d ("ipv6: add rcu grace period before freeing fib6_node")
Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip6_fib.h |  2 +-
 net/ipv6/addrconf.c   |  2 +-
 net/ipv6/ip6_fib.c    | 11 +++++++----
 net/ipv6/route.c      |  3 ++-
 4 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index e9c59db92942..af509f801084 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -105,7 +105,7 @@ struct rt6_info {
 	 * the same cache line.
 	 */
 	struct fib6_table		*rt6i_table;
-	struct fib6_node		*rt6i_node;
+	struct fib6_node __rcu		*rt6i_node;
 
 	struct in6_addr			rt6i_gateway;
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3c46e9513a31..936e9ab4dda5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -5556,7 +5556,7 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 		 * our DAD process, so we don't need
 		 * to do it again
 		 */
-		if (!(ifp->rt->rt6i_node))
+		if (!rcu_access_pointer(ifp->rt->rt6i_node))
 			ip6_ins_rt(ifp->rt);
 		if (ifp->idev->cnf.forwarding)
 			addrconf_join_anycast(ifp);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index a5ebf86f6be8..10b4b1f8b838 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -889,7 +889,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 
 		rt->dst.rt6_next = iter;
 		*ins = rt;
-		rt->rt6i_node = fn;
+		rcu_assign_pointer(rt->rt6i_node, fn);
 		atomic_inc(&rt->rt6i_ref);
 		if (!info->skip_notify)
 			inet6_rt_notify(RTM_NEWROUTE, rt, info, nlflags);
@@ -915,7 +915,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			return err;
 
 		*ins = rt;
-		rt->rt6i_node = fn;
+		rcu_assign_pointer(rt->rt6i_node, fn);
 		rt->dst.rt6_next = iter->dst.rt6_next;
 		atomic_inc(&rt->rt6i_ref);
 		if (!info->skip_notify)
@@ -1480,8 +1480,9 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 
 int fib6_del(struct rt6_info *rt, struct nl_info *info)
 {
+	struct fib6_node *fn = rcu_dereference_protected(rt->rt6i_node,
+				    lockdep_is_held(&rt->rt6i_table->tb6_lock));
 	struct net *net = info->nl_net;
-	struct fib6_node *fn = rt->rt6i_node;
 	struct rt6_info **rtp;
 
 #if RT6_DEBUG >= 2
@@ -1670,7 +1671,9 @@ static int fib6_clean_node(struct fib6_walker *w)
 			if (res) {
 #if RT6_DEBUG >= 2
 				pr_debug("%s: del failed: rt=%p@%p err=%d\n",
-					 __func__, rt, rt->rt6i_node, res);
+					 __func__, rt,
+					 rcu_access_pointer(rt->rt6i_node),
+					 res);
 #endif
 				continue;
 			}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a9d3564caf49..33629f2a0f9d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1383,7 +1383,8 @@ static void rt6_do_update_pmtu(struct rt6_info *rt, u32 mtu)
 static bool rt6_cache_allowed_for_pmtu(const struct rt6_info *rt)
 {
 	return !(rt->rt6i_flags & RTF_CACHE) &&
-		(rt->rt6i_flags & RTF_PCPU || rt->rt6i_node);
+		(rt->rt6i_flags & RTF_PCPU ||
+		 rcu_access_pointer(rt->rt6i_node));
 }
 
 static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
-- 
2.14.1.342.g6490525c54-goog
