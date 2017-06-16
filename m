From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next 07/21] ipv4: call dst_dev_put() properly
Date: Fri, 16 Jun 2017 10:47:30 -0700
Message-ID: <20170616174744.139688-8-tracywwnj@gmail.com>
References: <20170616174744.139688-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34534 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752514AbdFPRsa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 13:48:30 -0400
Received: by mail-pf0-f194.google.com with SMTP id d5so7559832pfe.1
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 10:48:30 -0700 (PDT)
In-Reply-To: <20170616174744.139688-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

As the intend of this patch series is to completely remove dst gc,
we need to call dst_dev_put() to release the reference to dst->dev
when removing routes from fib because we won't keep the gc list anymore
and will lose the dst pointer right after removing the routes.
Without the gc list, there is no way to find all the dst's that have
dst->dev pointing to the going-down dev.
Hence, we are doing dst_dev_put() immediately before we lose the last
reference of the dst from the routing code. The next dst_check() will
trigger a route re-lookup to find another route (if there is any).

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv4/fib_semantics.c | 2 ++
 net/ipv4/route.c         | 4 ++++
 2 files changed, 6 insertions(+)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 53b3e9c2da4c..f163fa0a1164 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -152,6 +152,7 @@ static void rt_fibinfo_free(struct rtable __rcu **rtp)
 	 * free_fib_info_rcu()
 	 */
 
+	dst_dev_put(&rt->dst);
 	dst_release(&rt->dst);
 	dst_free(&rt->dst);
 }
@@ -196,6 +197,7 @@ static void rt_fibinfo_free_cpus(struct rtable __rcu * __percpu *rtp)
 
 		rt = rcu_dereference_protected(*per_cpu_ptr(rtp, cpu), 1);
 		if (rt) {
+			dst_dev_put(&rt->dst);
 			dst_release(&rt->dst);
 			dst_free(&rt->dst);
 		}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 3dee0043117e..d986d80258d2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -603,12 +603,14 @@ static void fnhe_flush_routes(struct fib_nh_exception *fnhe)
 	rt = rcu_dereference(fnhe->fnhe_rth_input);
 	if (rt) {
 		RCU_INIT_POINTER(fnhe->fnhe_rth_input, NULL);
+		dst_dev_put(&rt->dst);
 		dst_release(&rt->dst);
 		rt_free(rt);
 	}
 	rt = rcu_dereference(fnhe->fnhe_rth_output);
 	if (rt) {
 		RCU_INIT_POINTER(fnhe->fnhe_rth_output, NULL);
+		dst_dev_put(&rt->dst);
 		dst_release(&rt->dst);
 		rt_free(rt);
 	}
@@ -1337,6 +1339,7 @@ static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
 			dst_hold(&rt->dst);
 			rcu_assign_pointer(*porig, rt);
 			if (orig) {
+				dst_dev_put(&orig->dst);
 				dst_release(&orig->dst);
 				rt_free(orig);
 			}
@@ -1369,6 +1372,7 @@ static bool rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 	prev = cmpxchg(p, orig, rt);
 	if (prev == orig) {
 		if (orig) {
+			dst_dev_put(&orig->dst);
 			dst_release(&orig->dst);
 			rt_free(orig);
 		}
-- 
2.13.1.518.g3df882009-goog
