From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next 10/21] ipv6: take dst->__refcnt for insertion into fib6 tree
Date: Fri, 16 Jun 2017 10:47:33 -0700
Message-ID: <20170616174744.139688-11-tracywwnj@gmail.com>
References: <20170616174744.139688-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33415 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752548AbdFPRsn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 13:48:43 -0400
Received: by mail-pf0-f193.google.com with SMTP id w12so7568207pfk.0
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 10:48:38 -0700 (PDT)
In-Reply-To: <20170616174744.139688-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

In IPv6 routing code, struct rt6_info is created for each static route
and RTF_CACHE route and inserted into fib6 tree. In both cases, dst
ref count is not taken.
As explained in the previous patch, this leads to the need of the dst
garbage collector.

This patch holds ref count of dst before inserting the route into fib6
tree and properly releases the dst when deleting it from the fib6 tree
as a preparation in order to fully get rid of dst gc later.

Also, correct fib6_age() logic to check dst->__refcnt to be 1 to indicate
no user is referencing the dst.

And remove dst_hold() in vrf_rt6_create() as ip6_dst_alloc() already puts
dst->__refcnt to 1.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 drivers/net/vrf.c  |  4 ----
 net/ipv6/ip6_fib.c | 12 +++++++++++-
 net/ipv6/route.c   | 55 ++++++++++++++++++++++++++++++++++++++----------------
 3 files changed, 50 insertions(+), 21 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index c6c0595d267b..d038927acfca 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -583,8 +583,6 @@ static int vrf_rt6_create(struct net_device *dev)
 	if (!rt6)
 		goto out;
 
-	dst_hold(&rt6->dst);
-
 	rt6->rt6i_table = rt6i_table;
 	rt6->dst.output	= vrf_output6;
 
@@ -597,8 +595,6 @@ static int vrf_rt6_create(struct net_device *dev)
 		goto out;
 	}
 
-	dst_hold(&rt6_local->dst);
-
 	rt6_local->rt6i_idev  = in6_dev_get(dev);
 	rt6_local->rt6i_flags = RTF_UP | RTF_NONEXTHOP | RTF_LOCAL;
 	rt6_local->rt6i_table = rt6i_table;
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index deea901746c8..3b728bcb1301 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -172,6 +172,7 @@ static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 		ppcpu_rt = per_cpu_ptr(non_pcpu_rt->rt6i_pcpu, cpu);
 		pcpu_rt = *ppcpu_rt;
 		if (pcpu_rt) {
+			dst_release(&pcpu_rt->dst);
 			rt6_rcu_free(pcpu_rt);
 			*ppcpu_rt = NULL;
 		}
@@ -185,6 +186,7 @@ static void rt6_release(struct rt6_info *rt)
 {
 	if (atomic_dec_and_test(&rt->rt6i_ref)) {
 		rt6_free_pcpu(rt);
+		dst_release(&rt->dst);
 		rt6_rcu_free(rt);
 	}
 }
@@ -1101,6 +1103,10 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 			atomic_inc(&pn->leaf->rt6i_ref);
 		}
 #endif
+		/* Always release dst as dst->__refcnt is guaranteed
+		 * to be taken before entering this function
+		 */
+		dst_release(&rt->dst);
 		if (!(rt->dst.flags & DST_NOCACHE))
 			dst_free(&rt->dst);
 	}
@@ -1113,6 +1119,10 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 st_failure:
 	if (fn && !(fn->fn_flags & (RTN_RTINFO|RTN_ROOT)))
 		fib6_repair_tree(info->nl_net, fn);
+	/* Always release dst as dst->__refcnt is guaranteed
+	 * to be taken before entering this function
+	 */
+	dst_release(&rt->dst);
 	if (!(rt->dst.flags & DST_NOCACHE))
 		dst_free(&rt->dst);
 	return err;
@@ -1783,7 +1793,7 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 		}
 		gc_args->more++;
 	} else if (rt->rt6i_flags & RTF_CACHE) {
-		if (atomic_read(&rt->dst.__refcnt) == 0 &&
+		if (atomic_read(&rt->dst.__refcnt) == 1 &&
 		    time_after_eq(now, rt->dst.lastuse + gc_args->timeout)) {
 			RT6_TRACE("aging clone %p\n", rt);
 			return -1;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index bc1bc91bb969..908b71188c57 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -354,7 +354,7 @@ static struct rt6_info *__ip6_dst_alloc(struct net *net,
 					int flags)
 {
 	struct rt6_info *rt = dst_alloc(&net->ipv6.ip6_dst_ops, dev,
-					0, DST_OBSOLETE_FORCE_CHK, flags);
+					1, DST_OBSOLETE_FORCE_CHK, flags);
 
 	if (rt)
 		rt6_info_init(rt);
@@ -381,7 +381,9 @@ struct rt6_info *ip6_dst_alloc(struct net *net,
 				*p =  NULL;
 			}
 		} else {
-			dst_destroy((struct dst_entry *)rt);
+			dst_release(&rt->dst);
+			if (!(flags & DST_NOCACHE))
+				dst_destroy((struct dst_entry *)rt);
 			return NULL;
 		}
 	}
@@ -932,9 +934,9 @@ struct rt6_info *rt6_lookup(struct net *net, const struct in6_addr *daddr,
 EXPORT_SYMBOL(rt6_lookup);
 
 /* ip6_ins_rt is called with FREE table->tb6_lock.
-   It takes new route entry, the addition fails by any reason the
-   route is freed. In any case, if caller does not hold it, it may
-   be destroyed.
+ * It takes new route entry, the addition fails by any reason the
+ * route is released.
+ * Caller must hold dst before calling it.
  */
 
 static int __ip6_ins_rt(struct rt6_info *rt, struct nl_info *info,
@@ -957,6 +959,8 @@ int ip6_ins_rt(struct rt6_info *rt)
 	struct nl_info info = {	.nl_net = dev_net(rt->dst.dev), };
 	struct mx6_config mxc = { .mx = NULL, };
 
+	/* Hold dst to account for the reference from the fib6 tree */
+	dst_hold(&rt->dst);
 	return __ip6_ins_rt(rt, &info, &mxc, NULL);
 }
 
@@ -1049,6 +1053,7 @@ static struct rt6_info *rt6_make_pcpu_route(struct rt6_info *rt)
 		prev = cmpxchg(p, NULL, pcpu_rt);
 		if (prev) {
 			/* If someone did it before us, return prev instead */
+			dst_release(&pcpu_rt->dst);
 			dst_destroy(&pcpu_rt->dst);
 			pcpu_rt = prev;
 		}
@@ -1059,6 +1064,7 @@ static struct rt6_info *rt6_make_pcpu_route(struct rt6_info *rt)
 		 * since rt is going away anyway.  The next
 		 * dst_check() will trigger a re-lookup.
 		 */
+		dst_release(&pcpu_rt->dst);
 		dst_destroy(&pcpu_rt->dst);
 		pcpu_rt = rt;
 	}
@@ -1129,12 +1135,15 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 		uncached_rt = ip6_rt_cache_alloc(rt, &fl6->daddr, NULL);
 		dst_release(&rt->dst);
 
-		if (uncached_rt)
+		if (uncached_rt) {
+			/* Uncached_rt's refcnt is taken during ip6_rt_cache_alloc()
+			 * No need for another dst_hold()
+			 */
 			rt6_uncached_list_add(uncached_rt);
-		else
+		} else {
 			uncached_rt = net->ipv6.ip6_null_entry;
-
-		dst_hold(&uncached_rt->dst);
+			dst_hold(&uncached_rt->dst);
+		}
 
 		trace_fib6_table_lookup(net, uncached_rt, table->tb6_id, fl6);
 		return uncached_rt;
@@ -1422,6 +1431,10 @@ static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
 			 * invalidate the sk->sk_dst_cache.
 			 */
 			ip6_ins_rt(nrt6);
+			/* Release the reference taken in
+			 * ip6_rt_cache_alloc()
+			 */
+			dst_release(&nrt6->dst);
 		}
 	}
 }
@@ -1673,7 +1686,6 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 
 	rt->dst.flags |= DST_HOST;
 	rt->dst.output  = ip6_output;
-	atomic_set(&rt->dst.__refcnt, 1);
 	rt->rt6i_gateway  = fl6->daddr;
 	rt->rt6i_dst.addr = fl6->daddr;
 	rt->rt6i_dst.plen = 128;
@@ -2130,8 +2142,10 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg,
 		dev_put(dev);
 	if (idev)
 		in6_dev_put(idev);
-	if (rt)
+	if (rt) {
+		dst_release(&rt->dst);
 		dst_free(&rt->dst);
+	}
 
 	return ERR_PTR(err);
 }
@@ -2160,8 +2174,10 @@ int ip6_route_add(struct fib6_config *cfg,
 
 	return err;
 out:
-	if (rt)
+	if (rt) {
+		dst_release(&rt->dst);
 		dst_free(&rt->dst);
+	}
 
 	return err;
 }
@@ -2398,7 +2414,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	nrt->rt6i_gateway = *(struct in6_addr *)neigh->primary_key;
 
 	if (ip6_ins_rt(nrt))
-		goto out;
+		goto out_release;
 
 	netevent.old = &rt->dst;
 	netevent.new = &nrt->dst;
@@ -2411,6 +2427,12 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 		ip6_del_rt(rt);
 	}
 
+out_release:
+	/* Release the reference taken in
+	 * ip6_rt_cache_alloc()
+	 */
+	dst_release(&nrt->dst);
+
 out:
 	neigh_release(neigh);
 }
@@ -2760,8 +2782,6 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	rt->rt6i_table = fib6_get_table(net, tb_id);
 	rt->dst.flags |= DST_NOCACHE;
 
-	atomic_set(&rt->dst.__refcnt, 1);
-
 	return rt;
 }
 
@@ -3186,6 +3206,7 @@ static int ip6_route_multipath_add(struct fib6_config *cfg,
 
 		err = ip6_route_info_append(&rt6_nh_list, rt, &r_cfg);
 		if (err) {
+			dst_release(&rt->dst);
 			dst_free(&rt->dst);
 			goto cleanup;
 		}
@@ -3249,8 +3270,10 @@ static int ip6_route_multipath_add(struct fib6_config *cfg,
 
 cleanup:
 	list_for_each_entry_safe(nh, nh_safe, &rt6_nh_list, next) {
-		if (nh->rt6_info)
+		if (nh->rt6_info) {
+			dst_release(&nh->rt6_info->dst);
 			dst_free(&nh->rt6_info->dst);
+		}
 		kfree(nh->mxc.mx);
 		list_del(&nh->next);
 		kfree(nh);
-- 
2.13.1.518.g3df882009-goog
