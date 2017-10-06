From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next 11/16] ipv6: replace dst_hold() with dst_hold_safe() in routing code
Date: Fri,  6 Oct 2017 12:06:06 -0700
Message-ID: <20171006190611.110633-12-tracywwnj@gmail.com>
References: <20171006190611.110633-1-tracywwnj@gmail.com>
 <20171006190611.110633-2-tracywwnj@gmail.com>
 <20171006190611.110633-3-tracywwnj@gmail.com>
 <20171006190611.110633-4-tracywwnj@gmail.com>
 <20171006190611.110633-5-tracywwnj@gmail.com>
 <20171006190611.110633-6-tracywwnj@gmail.com>
 <20171006190611.110633-7-tracywwnj@gmail.com>
 <20171006190611.110633-8-tracywwnj@gmail.com>
 <20171006190611.110633-9-tracywwnj@gmail.com>
 <20171006190611.110633-10-tracywwnj@gmail.com>
 <20171006190611.110633-11-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:52118 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752730AbdJFTGv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 15:06:51 -0400
Received: by mail-pg0-f48.google.com with SMTP id u144so7688888pgb.8
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 12:06:51 -0700 (PDT)
In-Reply-To: <20171006190611.110633-11-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

With rwlock, it is safe to call dst_hold() in the read thread because
read thread is guaranteed to be separated from write thread.
However, after we replace rwlock with rcu, it is no longer safe to use
dst_hold(). A dst might already have been deleted but is waiting for the
rcu grace period to pass before freeing the memory when a read thread is
trying to do dst_hold(). This could potentially cause double free issue.

So this commit replaces all dst_hold() with dst_hold_safe() in all read
thread to avoid this double free issue.
And in order to make the code more compact, a new function ip6_hold_safe()
is introduced. It calls dst_hold_safe() first, and if that fails, it will
either fall back to hold and return net->ipv6.ip6_null_entry or set rt to
NULL according to the caller's need.

Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/addrconf.c |  3 ++-
 net/ipv6/route.c    | 71 +++++++++++++++++++++++++++++++++++++++--------------
 2 files changed, 54 insertions(+), 20 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 873afafddfc4..f86e931d555e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2333,7 +2333,8 @@ static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
 			continue;
 		if ((rt->rt6i_flags & noflags) != 0)
 			continue;
-		dst_hold(&rt->dst);
+		if (!dst_hold_safe(&rt->dst))
+			rt = NULL;
 		break;
 	}
 out:
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 941c062389d2..aeb349aea429 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -874,6 +874,23 @@ static struct fib6_node* fib6_backtrack(struct fib6_node *fn,
 	}
 }
 
+static bool ip6_hold_safe(struct net *net, struct rt6_info **prt,
+			  bool null_fallback)
+{
+	struct rt6_info *rt = *prt;
+
+	if (dst_hold_safe(&rt->dst))
+		return true;
+	if (null_fallback) {
+		rt = net->ipv6.ip6_null_entry;
+		dst_hold(&rt->dst);
+	} else {
+		rt = NULL;
+	}
+	*prt = rt;
+	return false;
+}
+
 static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 					     struct fib6_table *table,
 					     struct flowi6 *fl6, int flags)
@@ -898,7 +915,9 @@ static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 	if (rt_cache)
 		rt = rt_cache;
 
-	dst_use(&rt->dst, jiffies);
+	if (ip6_hold_safe(net, &rt, true))
+		dst_use_noref(&rt->dst, jiffies);
+
 	read_unlock_bh(&table->tb6_lock);
 
 	trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
@@ -1061,10 +1080,9 @@ static struct rt6_info *rt6_get_pcpu_route(struct rt6_info *rt)
 	p = this_cpu_ptr(rt->rt6i_pcpu);
 	pcpu_rt = *p;
 
-	if (pcpu_rt) {
-		dst_hold(&pcpu_rt->dst);
+	if (pcpu_rt && ip6_hold_safe(NULL, &pcpu_rt, false))
 		rt6_dst_from_metrics_check(pcpu_rt);
-	}
+
 	return pcpu_rt;
 }
 
@@ -1625,12 +1643,17 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 	if (rt_cache)
 		rt = rt_cache;
 
-	if (rt == net->ipv6.ip6_null_entry || (rt->rt6i_flags & RTF_CACHE)) {
-		dst_use(&rt->dst, jiffies);
+	if (rt == net->ipv6.ip6_null_entry) {
+		read_unlock_bh(&table->tb6_lock);
+		dst_hold(&rt->dst);
+		trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
+		return rt;
+	} else if (rt->rt6i_flags & RTF_CACHE) {
+		if (ip6_hold_safe(net, &rt, true)) {
+			dst_use_noref(&rt->dst, jiffies);
+			rt6_dst_from_metrics_check(rt);
+		}
 		read_unlock_bh(&table->tb6_lock);
-
-		rt6_dst_from_metrics_check(rt);
-
 		trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
 		return rt;
 	} else if (unlikely((fl6->flowi6_flags & FLOWI_FLAG_KNOWN_NH) &&
@@ -1643,7 +1666,13 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 
 		struct rt6_info *uncached_rt;
 
-		dst_use(&rt->dst, jiffies);
+		if (ip6_hold_safe(net, &rt, true)) {
+			dst_use_noref(&rt->dst, jiffies);
+		} else {
+			read_unlock_bh(&table->tb6_lock);
+			uncached_rt = rt;
+			goto uncached_rt_out;
+		}
 		read_unlock_bh(&table->tb6_lock);
 
 		uncached_rt = ip6_rt_cache_alloc(rt, &fl6->daddr, NULL);
@@ -1659,6 +1688,7 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 			dst_hold(&uncached_rt->dst);
 		}
 
+uncached_rt_out:
 		trace_fib6_table_lookup(net, uncached_rt, table->tb6_id, fl6);
 		return uncached_rt;
 
@@ -1667,8 +1697,7 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 
 		struct rt6_info *pcpu_rt;
 
-		rt->dst.lastuse = jiffies;
-		rt->dst.__use++;
+		dst_use_noref(&rt->dst, jiffies);
 		pcpu_rt = rt6_get_pcpu_route(rt);
 
 		if (pcpu_rt) {
@@ -2130,7 +2159,7 @@ static struct rt6_info *__ip6_route_redirect(struct net *net,
 	}
 
 out:
-	dst_hold(&rt->dst);
+	ip6_hold_safe(net, &rt, true);
 
 	read_unlock_bh(&table->tb6_lock);
 
@@ -2841,7 +2870,8 @@ static int ip6_route_del(struct fib6_config *cfg,
 				continue;
 			if (cfg->fc_protocol && cfg->fc_protocol != rt->rt6i_protocol)
 				continue;
-			dst_hold(&rt->dst);
+			if (!dst_hold_safe(&rt->dst))
+				break;
 			read_unlock_bh(&table->tb6_lock);
 
 			/* if gateway was specified only delete the one hop */
@@ -3038,7 +3068,7 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 			continue;
 		if (!ipv6_addr_equal(&rt->rt6i_gateway, gwaddr))
 			continue;
-		dst_hold(&rt->dst);
+		ip6_hold_safe(NULL, &rt, false);
 		break;
 	}
 out:
@@ -3096,7 +3126,7 @@ struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_dev
 			break;
 	}
 	if (rt)
-		dst_hold(&rt->dst);
+		ip6_hold_safe(NULL, &rt, false);
 	read_unlock_bh(&table->tb6_lock);
 	return rt;
 }
@@ -3139,9 +3169,12 @@ static void __rt6_purge_dflt_routers(struct fib6_table *table)
 	for (rt = table->tb6_root.leaf; rt; rt = rt->dst.rt6_next) {
 		if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF) &&
 		    (!rt->rt6i_idev || rt->rt6i_idev->cnf.accept_ra != 2)) {
-			dst_hold(&rt->dst);
-			read_unlock_bh(&table->tb6_lock);
-			ip6_del_rt(rt);
+			if (dst_hold_safe(&rt->dst)) {
+				read_unlock_bh(&table->tb6_lock);
+				ip6_del_rt(rt);
+			} else {
+				read_unlock_bh(&table->tb6_lock);
+			}
 			goto restart;
 		}
 	}
-- 
2.14.2.920.gcf0c67979c-goog
