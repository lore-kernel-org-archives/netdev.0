From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next 09/21] ipv4: mark DST_NOGC and remove the operation of dst_free()
Date: Fri, 16 Jun 2017 10:47:32 -0700
Message-ID: <20170616174744.139688-10-tracywwnj@gmail.com>
References: <20170616174744.139688-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33404 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752469AbdFPRs1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 13:48:27 -0400
Received: by mail-pf0-f196.google.com with SMTP id w12so7568147pfk.0
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 10:48:27 -0700 (PDT)
In-Reply-To: <20170616174744.139688-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

With the previous preparation patches, we are ready to get rid of the
dst gc operation in ipv4 code and release dst based on refcnt only.
So this patch adds DST_NOGC flag for all IPv4 dst and remove the calls
to dst_free().
At this point, all dst created in ipv4 code do not use the dst gc
anymore and will be destroyed at the point when refcnt drops to 0.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv4/fib_semantics.c |  6 ++----
 net/ipv4/route.c         | 15 +++------------
 2 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index f163fa0a1164..ff47ea1408fe 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -153,8 +153,7 @@ static void rt_fibinfo_free(struct rtable __rcu **rtp)
 	 */
 
 	dst_dev_put(&rt->dst);
-	dst_release(&rt->dst);
-	dst_free(&rt->dst);
+	dst_release_immediate(&rt->dst);
 }
 
 static void free_nh_exceptions(struct fib_nh *nh)
@@ -198,8 +197,7 @@ static void rt_fibinfo_free_cpus(struct rtable __rcu * __percpu *rtp)
 		rt = rcu_dereference_protected(*per_cpu_ptr(rtp, cpu), 1);
 		if (rt) {
 			dst_dev_put(&rt->dst);
-			dst_release(&rt->dst);
-			dst_free(&rt->dst);
+			dst_release_immediate(&rt->dst);
 		}
 	}
 	free_percpu(rtp);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 903a12c601ac..80b30c2bf47d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -589,11 +589,6 @@ static void ip_rt_build_flow_key(struct flowi4 *fl4, const struct sock *sk,
 		build_sk_flow_key(fl4, sk);
 }
 
-static inline void rt_free(struct rtable *rt)
-{
-	call_rcu(&rt->dst.rcu_head, dst_rcu_free);
-}
-
 static DEFINE_SPINLOCK(fnhe_lock);
 
 static void fnhe_flush_routes(struct fib_nh_exception *fnhe)
@@ -605,14 +600,12 @@ static void fnhe_flush_routes(struct fib_nh_exception *fnhe)
 		RCU_INIT_POINTER(fnhe->fnhe_rth_input, NULL);
 		dst_dev_put(&rt->dst);
 		dst_release(&rt->dst);
-		rt_free(rt);
 	}
 	rt = rcu_dereference(fnhe->fnhe_rth_output);
 	if (rt) {
 		RCU_INIT_POINTER(fnhe->fnhe_rth_output, NULL);
 		dst_dev_put(&rt->dst);
 		dst_release(&rt->dst);
-		rt_free(rt);
 	}
 }
 
@@ -1341,7 +1334,6 @@ static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
 			if (orig) {
 				dst_dev_put(&orig->dst);
 				dst_release(&orig->dst);
-				rt_free(orig);
 			}
 			ret = true;
 		}
@@ -1374,7 +1366,6 @@ static bool rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 		if (orig) {
 			dst_dev_put(&orig->dst);
 			dst_release(&orig->dst);
-			rt_free(orig);
 		}
 	} else {
 		dst_release(&rt->dst);
@@ -1505,7 +1496,8 @@ struct rtable *rt_dst_alloc(struct net_device *dev,
 	rt = dst_alloc(&ipv4_dst_ops, dev, 1, DST_OBSOLETE_FORCE_CHK,
 		       (will_cache ? 0 : (DST_HOST | DST_NOCACHE)) |
 		       (nopolicy ? DST_NOPOLICY : 0) |
-		       (noxfrm ? DST_NOXFRM : 0));
+		       (noxfrm ? DST_NOXFRM : 0) |
+		       DST_NOGC);
 
 	if (rt) {
 		rt->rt_genid = rt_genid_ipv4(dev_net(dev));
@@ -2511,7 +2503,7 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 	struct rtable *ort = (struct rtable *) dst_orig;
 	struct rtable *rt;
 
-	rt = dst_alloc(&ipv4_dst_blackhole_ops, NULL, 1, DST_OBSOLETE_NONE, 0);
+	rt = dst_alloc(&ipv4_dst_blackhole_ops, NULL, 1, DST_OBSOLETE_NONE, DST_NOGC);
 	if (rt) {
 		struct dst_entry *new = &rt->dst;
 
@@ -2534,7 +2526,6 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_uses_gateway = ort->rt_uses_gateway;
 
 		INIT_LIST_HEAD(&rt->rt_uncached);
-		dst_free(new);
 	}
 
 	dst_release(dst_orig);
-- 
2.13.1.518.g3df882009-goog
