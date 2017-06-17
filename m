From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH v2 net-next 13/21] ipv6: mark DST_NOGC and remove the operation of dst_free()
Date: Sat, 17 Jun 2017 10:42:36 -0700
Message-ID: <20170617174244.132862-14-tracywwnj@gmail.com>
References: <20170617174244.132862-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33217 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752717AbdFQRno (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 13:43:44 -0400
Received: by mail-pf0-f193.google.com with SMTP id w12so11106910pfk.0
        for <netdev@vger.kernel.org>; Sat, 17 Jun 2017 10:43:44 -0700 (PDT)
In-Reply-To: <20170617174244.132862-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

With the previous preparation patches, we are ready to get rid of the
dst gc operation in ipv6 code and release dst based on refcnt only.
So this patch adds DST_NOGC flag for all IPv6 dst and remove the calls
to dst_free() and its related functions.
At this point, all dst created in ipv6 code do not use the dst gc
anymore and will be destroyed at the point when refcnt drops to 0.

Also, as icmp6 dst route is refcounted during creation and will be freed
by user during its call of dst_release(), there is no need to add this
dst to the icmp6 gc list as well.
Instead, we need to add it into uncached list so that when a
NETDEV_DOWN/NETDEV_UNREGISRER event comes, we can properly go through
these icmp6 dst as well and release the net device properly.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv6/ip6_fib.c | 15 ++-------------
 net/ipv6/route.c   | 49 +++++++++++++++++--------------------------------
 2 files changed, 19 insertions(+), 45 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 265401abb98e..e3b35e146eef 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -153,11 +153,6 @@ static void node_free(struct fib6_node *fn)
 	kmem_cache_free(fib6_node_kmem, fn);
 }
 
-static void rt6_rcu_free(struct rt6_info *rt)
-{
-	call_rcu(&rt->dst.rcu_head, dst_rcu_free);
-}
-
 static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 {
 	int cpu;
@@ -174,7 +169,6 @@ static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 		if (pcpu_rt) {
 			dst_dev_put(&pcpu_rt->dst);
 			dst_release(&pcpu_rt->dst);
-			rt6_rcu_free(pcpu_rt);
 			*ppcpu_rt = NULL;
 		}
 	}
@@ -189,7 +183,6 @@ static void rt6_release(struct rt6_info *rt)
 		rt6_free_pcpu(rt);
 		dst_dev_put(&rt->dst);
 		dst_release(&rt->dst);
-		rt6_rcu_free(rt);
 	}
 }
 
@@ -1108,9 +1101,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 		/* Always release dst as dst->__refcnt is guaranteed
 		 * to be taken before entering this function
 		 */
-		dst_release(&rt->dst);
-		if (!(rt->dst.flags & DST_NOCACHE))
-			dst_free(&rt->dst);
+		dst_release_immediate(&rt->dst);
 	}
 	return err;
 
@@ -1124,9 +1115,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 	/* Always release dst as dst->__refcnt is guaranteed
 	 * to be taken before entering this function
 	 */
-	dst_release(&rt->dst);
-	if (!(rt->dst.flags & DST_NOCACHE))
-		dst_free(&rt->dst);
+	dst_release_immediate(&rt->dst);
 	return err;
 #endif
 }
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c52c51908881..5f859ee67172 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -354,7 +354,8 @@ static struct rt6_info *__ip6_dst_alloc(struct net *net,
 					int flags)
 {
 	struct rt6_info *rt = dst_alloc(&net->ipv6.ip6_dst_ops, dev,
-					1, DST_OBSOLETE_FORCE_CHK, flags);
+					1, DST_OBSOLETE_FORCE_CHK,
+					flags | DST_NOGC);
 
 	if (rt)
 		rt6_info_init(rt);
@@ -381,9 +382,7 @@ struct rt6_info *ip6_dst_alloc(struct net *net,
 				*p =  NULL;
 			}
 		} else {
-			dst_release(&rt->dst);
-			if (!(flags & DST_NOCACHE))
-				dst_destroy((struct dst_entry *)rt);
+			dst_release_immediate(&rt->dst);
 			return NULL;
 		}
 	}
@@ -1053,8 +1052,7 @@ static struct rt6_info *rt6_make_pcpu_route(struct rt6_info *rt)
 		prev = cmpxchg(p, NULL, pcpu_rt);
 		if (prev) {
 			/* If someone did it before us, return prev instead */
-			dst_release(&pcpu_rt->dst);
-			dst_destroy(&pcpu_rt->dst);
+			dst_release_immediate(&pcpu_rt->dst);
 			pcpu_rt = prev;
 		}
 	} else {
@@ -1064,8 +1062,7 @@ static struct rt6_info *rt6_make_pcpu_route(struct rt6_info *rt)
 		 * since rt is going away anyway.  The next
 		 * dst_check() will trigger a re-lookup.
 		 */
-		dst_release(&pcpu_rt->dst);
-		dst_destroy(&pcpu_rt->dst);
+		dst_release_immediate(&pcpu_rt->dst);
 		pcpu_rt = rt;
 	}
 	dst_hold(&pcpu_rt->dst);
@@ -1257,9 +1254,8 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 	struct net_device *loopback_dev = net->loopback_dev;
 	struct dst_entry *new = NULL;
 
-
 	rt = dst_alloc(&ip6_dst_blackhole_ops, loopback_dev, 1,
-		       DST_OBSOLETE_NONE, 0);
+		       DST_OBSOLETE_NONE, DST_NOGC);
 	if (rt) {
 		rt6_info_init(rt);
 
@@ -1279,8 +1275,6 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 #ifdef CONFIG_IPV6_SUBTREES
 		memcpy(&rt->rt6i_src, &ort->rt6i_src, sizeof(struct rt6key));
 #endif
-
-		dst_free(new);
 	}
 
 	dst_release(dst_orig);
@@ -1692,12 +1686,10 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	rt->rt6i_idev     = idev;
 	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 0);
 
-	spin_lock_bh(&icmp6_dst_lock);
-	rt->dst.next = icmp6_dst_gc_list;
-	icmp6_dst_gc_list = &rt->dst;
-	spin_unlock_bh(&icmp6_dst_lock);
-
-	fib6_force_start_gc(net);
+	/* Add this dst into uncached_list so that rt6_ifdown() can
+	 * do proper release of the net_device
+	 */
+	rt6_uncached_list_add(rt);
 
 	dst = xfrm_lookup(net, &rt->dst, flowi6_to_flowi(fl6), NULL, 0);
 
@@ -2142,10 +2134,8 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg,
 		dev_put(dev);
 	if (idev)
 		in6_dev_put(idev);
-	if (rt) {
-		dst_release(&rt->dst);
-		dst_free(&rt->dst);
-	}
+	if (rt)
+		dst_release_immediate(&rt->dst);
 
 	return ERR_PTR(err);
 }
@@ -2174,10 +2164,8 @@ int ip6_route_add(struct fib6_config *cfg,
 
 	return err;
 out:
-	if (rt) {
-		dst_release(&rt->dst);
-		dst_free(&rt->dst);
-	}
+	if (rt)
+		dst_release_immediate(&rt->dst);
 
 	return err;
 }
@@ -3206,8 +3194,7 @@ static int ip6_route_multipath_add(struct fib6_config *cfg,
 
 		err = ip6_route_info_append(&rt6_nh_list, rt, &r_cfg);
 		if (err) {
-			dst_release(&rt->dst);
-			dst_free(&rt->dst);
+			dst_release_immediate(&rt->dst);
 			goto cleanup;
 		}
 
@@ -3270,10 +3257,8 @@ static int ip6_route_multipath_add(struct fib6_config *cfg,
 
 cleanup:
 	list_for_each_entry_safe(nh, nh_safe, &rt6_nh_list, next) {
-		if (nh->rt6_info) {
-			dst_release(&nh->rt6_info->dst);
-			dst_free(&nh->rt6_info->dst);
-		}
+		if (nh->rt6_info)
+			dst_release_immediate(&nh->rt6_info->dst);
 		kfree(nh->mxc.mx);
 		list_del(&nh->next);
 		kfree(nh);
-- 
2.13.1.518.g3df882009-goog
