From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next 09/16] ipv6: grab rt->rt6i_ref before allocating pcpu rt
Date: Fri,  6 Oct 2017 12:06:04 -0700
Message-ID: <20171006190611.110633-10-tracywwnj@gmail.com>
References: <20171006190611.110633-1-tracywwnj@gmail.com>
 <20171006190611.110633-2-tracywwnj@gmail.com>
 <20171006190611.110633-3-tracywwnj@gmail.com>
 <20171006190611.110633-4-tracywwnj@gmail.com>
 <20171006190611.110633-5-tracywwnj@gmail.com>
 <20171006190611.110633-6-tracywwnj@gmail.com>
 <20171006190611.110633-7-tracywwnj@gmail.com>
 <20171006190611.110633-8-tracywwnj@gmail.com>
 <20171006190611.110633-9-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:57079 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752692AbdJFTGs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 15:06:48 -0400
Received: by mail-pf0-f178.google.com with SMTP id g65so9971550pfe.13
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 12:06:48 -0700 (PDT)
In-Reply-To: <20171006190611.110633-9-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

After rwlock is replaced with rcu and spinlock, ip6_pol_route() will be
called with only rcu held. That means rt6 route deletion could happen
simultaneously with rt6_make_pcpu_rt(). This could potentially cause
memory leak if rt6_release() is called right before rt6_make_pcpu_rt()
on the same route.

This patch grabs rt->rt6i_ref safely before calling rt6_make_pcpu_rt()
to make sure rt6_release() will not get triggered while
rt6_make_pcpu_rt() is in progress. And rt6_release() is called after
rt6_make_pcpu_rt() is finished.

Note: As we are incrementing rt->rt6i_ref in ip6_pol_route(), there is a
very slim chance that fib6_purge_rt() will be triggered unnecessarily
when deleting a route if ip6_pol_route() running on another thread picks
this route as well and tries to make pcpu cache for it.

Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/route.c | 58 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 29 insertions(+), 29 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 65130dde276a..941c062389d2 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1070,7 +1070,6 @@ static struct rt6_info *rt6_get_pcpu_route(struct rt6_info *rt)
 
 static struct rt6_info *rt6_make_pcpu_route(struct rt6_info *rt)
 {
-	struct fib6_table *table = rt->rt6i_table;
 	struct rt6_info *pcpu_rt, *prev, **p;
 
 	pcpu_rt = ip6_rt_pcpu_alloc(rt);
@@ -1081,28 +1080,20 @@ static struct rt6_info *rt6_make_pcpu_route(struct rt6_info *rt)
 		return net->ipv6.ip6_null_entry;
 	}
 
-	read_lock_bh(&table->tb6_lock);
-	if (rt->rt6i_pcpu) {
-		p = this_cpu_ptr(rt->rt6i_pcpu);
-		prev = cmpxchg(p, NULL, pcpu_rt);
-		if (prev) {
-			/* If someone did it before us, return prev instead */
-			dst_release_immediate(&pcpu_rt->dst);
-			pcpu_rt = prev;
-		}
-	} else {
-		/* rt has been removed from the fib6 tree
-		 * before we have a chance to acquire the read_lock.
-		 * In this case, don't brother to create a pcpu rt
-		 * since rt is going away anyway.  The next
-		 * dst_check() will trigger a re-lookup.
-		 */
+	dst_hold(&pcpu_rt->dst);
+	p = this_cpu_ptr(rt->rt6i_pcpu);
+	prev = cmpxchg(p, NULL, pcpu_rt);
+	if (prev) {
+		/* If someone did it before us, return prev instead */
+		/* release refcnt taken by ip6_rt_pcpu_alloc() */
+		dst_release_immediate(&pcpu_rt->dst);
+		/* release refcnt taken by above dst_hold() */
 		dst_release_immediate(&pcpu_rt->dst);
-		pcpu_rt = rt;
+		dst_hold(&prev->dst);
+		pcpu_rt = prev;
 	}
-	dst_hold(&pcpu_rt->dst);
+
 	rt6_dst_from_metrics_check(pcpu_rt);
-	read_unlock_bh(&table->tb6_lock);
 	return pcpu_rt;
 }
 
@@ -1683,19 +1674,28 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 		if (pcpu_rt) {
 			read_unlock_bh(&table->tb6_lock);
 		} else {
-			/* We have to do the read_unlock first
-			 * because rt6_make_pcpu_route() may trigger
-			 * ip6_dst_gc() which will take the write_lock.
-			 */
-			dst_hold(&rt->dst);
-			read_unlock_bh(&table->tb6_lock);
-			pcpu_rt = rt6_make_pcpu_route(rt);
-			dst_release(&rt->dst);
+			/* atomic_inc_not_zero() is needed when using rcu */
+			if (atomic_inc_not_zero(&rt->rt6i_ref)) {
+				/* We have to do the read_unlock first
+				 * because rt6_make_pcpu_route() may trigger
+				 * ip6_dst_gc() which will take the write_lock.
+				 *
+				 * No dst_hold() on rt is needed because grabbing
+				 * rt->rt6i_ref makes sure rt can't be released.
+				 */
+				read_unlock_bh(&table->tb6_lock);
+				pcpu_rt = rt6_make_pcpu_route(rt);
+				rt6_release(rt);
+			} else {
+				/* rt is already removed from tree */
+				read_unlock_bh(&table->tb6_lock);
+				pcpu_rt = net->ipv6.ip6_null_entry;
+				dst_hold(&pcpu_rt->dst);
+			}
 		}
 
 		trace_fib6_table_lookup(net, pcpu_rt, table->tb6_id, fl6);
 		return pcpu_rt;
-
 	}
 }
 EXPORT_SYMBOL_GPL(ip6_pol_route);
-- 
2.14.2.920.gcf0c67979c-goog
