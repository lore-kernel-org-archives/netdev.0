From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH v2 net-next 06/21] ipv4: take dst->__refcnt when caching dst in fib
Date: Sat, 17 Jun 2017 10:42:29 -0700
Message-ID: <20170617174244.132862-7-tracywwnj@gmail.com>
References: <20170617174244.132862-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34411 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752569AbdFQRni (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 13:43:38 -0400
Received: by mail-pf0-f196.google.com with SMTP id d5so11094773pfe.1
        for <netdev@vger.kernel.org>; Sat, 17 Jun 2017 10:43:37 -0700 (PDT)
In-Reply-To: <20170617174244.132862-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

In IPv4 routing code, fib_nh and fib_nh_exception can hold pointers
to struct rtable but they never increment dst->__refcnt.
This leads to the need of the dst garbage collector because when user
is done with this dst and calls dst_release(), it can only decrement
dst->__refcnt and can not free the dst even it sees dst->__refcnt
drops from 1 to 0 (unless DST_NOCACHE flag is set) because the routing
code might still hold reference to it.
And when the routing code tries to delete a route, it has to put the
dst to the gc_list if dst->__refcnt is not yet 0 and have a gc thread
running periodically to check on dst->__refcnt and finally to free dst
when refcnt becomes 0.

This patch increments dst->__refcnt when
fib_nh/fib_nh_exception holds reference to this dst and properly release
the dst when fib_nh/fib_nh_exception has been updated with a new dst.

This patch is a preparation in order to fully get rid of dst gc later.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv4/fib_semantics.c |  5 ++++-
 net/ipv4/route.c         | 19 ++++++++++++++++---
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 2157dc08c407..53b3e9c2da4c 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -152,6 +152,7 @@ static void rt_fibinfo_free(struct rtable __rcu **rtp)
 	 * free_fib_info_rcu()
 	 */
 
+	dst_release(&rt->dst);
 	dst_free(&rt->dst);
 }
 
@@ -194,8 +195,10 @@ static void rt_fibinfo_free_cpus(struct rtable __rcu * __percpu *rtp)
 		struct rtable *rt;
 
 		rt = rcu_dereference_protected(*per_cpu_ptr(rtp, cpu), 1);
-		if (rt)
+		if (rt) {
+			dst_release(&rt->dst);
 			dst_free(&rt->dst);
+		}
 	}
 	free_percpu(rtp);
 }
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0a843ef2b709..3dee0043117e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -603,11 +603,13 @@ static void fnhe_flush_routes(struct fib_nh_exception *fnhe)
 	rt = rcu_dereference(fnhe->fnhe_rth_input);
 	if (rt) {
 		RCU_INIT_POINTER(fnhe->fnhe_rth_input, NULL);
+		dst_release(&rt->dst);
 		rt_free(rt);
 	}
 	rt = rcu_dereference(fnhe->fnhe_rth_output);
 	if (rt) {
 		RCU_INIT_POINTER(fnhe->fnhe_rth_output, NULL);
+		dst_release(&rt->dst);
 		rt_free(rt);
 	}
 }
@@ -1332,9 +1334,12 @@ static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
 			rt->rt_gateway = daddr;
 
 		if (!(rt->dst.flags & DST_NOCACHE)) {
+			dst_hold(&rt->dst);
 			rcu_assign_pointer(*porig, rt);
-			if (orig)
+			if (orig) {
+				dst_release(&orig->dst);
 				rt_free(orig);
+			}
 			ret = true;
 		}
 
@@ -1357,12 +1362,20 @@ static bool rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 	}
 	orig = *p;
 
+	/* hold dst before doing cmpxchg() to avoid race condition
+	 * on this dst
+	 */
+	dst_hold(&rt->dst);
 	prev = cmpxchg(p, orig, rt);
 	if (prev == orig) {
-		if (orig)
+		if (orig) {
+			dst_release(&orig->dst);
 			rt_free(orig);
-	} else
+		}
+	} else {
+		dst_release(&rt->dst);
 		ret = false;
+	}
 
 	return ret;
 }
-- 
2.13.1.518.g3df882009-goog
