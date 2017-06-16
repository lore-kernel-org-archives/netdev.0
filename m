From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next 19/21] net: remove DST_NOCACHE flag
Date: Fri, 16 Jun 2017 10:47:42 -0700
Message-ID: <20170616174744.139688-20-tracywwnj@gmail.com>
References: <20170616174744.139688-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33491 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752584AbdFPRsh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 13:48:37 -0400
Received: by mail-pf0-f195.google.com with SMTP id w12so7568633pfk.0
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 10:48:37 -0700 (PDT)
In-Reply-To: <20170616174744.139688-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

DST_NOCACHE flag check has been removed from dst_release() and
dst_hold_safe() in a previous patch because all the dst are now ref
counted properly and can be released based on refcnt only.
Looking at the rest of the DST_NOCACHE use, all of them can now be
removed or replaced with other checks.
So this patch gets rid of all the DST_NOCACHE usage and remove this flag
completely.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 drivers/net/vrf.c      |  2 +-
 include/net/dst.h      |  1 -
 include/net/ip6_fib.h  |  2 +-
 net/core/dst.c         |  2 +-
 net/ipv4/route.c       | 23 +++++++++++------------
 net/ipv6/ip6_fib.c     |  4 +---
 net/ipv6/route.c       |  7 ++-----
 net/xfrm/xfrm_policy.c |  1 -
 8 files changed, 17 insertions(+), 25 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index d038927acfca..997ef25189fd 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -563,7 +563,7 @@ static void vrf_rt6_release(struct net_device *dev, struct net_vrf *vrf)
 
 static int vrf_rt6_create(struct net_device *dev)
 {
-	int flags = DST_HOST | DST_NOPOLICY | DST_NOXFRM | DST_NOCACHE;
+	int flags = DST_HOST | DST_NOPOLICY | DST_NOXFRM;
 	struct net_vrf *vrf = netdev_priv(dev);
 	struct net *net = dev_net(dev);
 	struct fib6_table *rt6i_table;
diff --git a/include/net/dst.h b/include/net/dst.h
index 1be82f672c37..642483ed4edf 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -51,7 +51,6 @@ struct dst_entry {
 #define DST_HOST		0x0001
 #define DST_NOXFRM		0x0002
 #define DST_NOPOLICY		0x0004
-#define DST_NOCACHE		0x0010
 #define DST_NOCOUNT		0x0020
 #define DST_FAKE_RTABLE		0x0040
 #define DST_XFRM_TUNNEL		0x0080
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index aa50e2e6fa2a..1a88008cc6f5 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -170,7 +170,7 @@ static inline void rt6_update_expires(struct rt6_info *rt0, int timeout)
 static inline u32 rt6_get_cookie(const struct rt6_info *rt)
 {
 	if (rt->rt6i_flags & RTF_PCPU ||
-	    (unlikely(rt->dst.flags & DST_NOCACHE) && rt->dst.from))
+	    (unlikely(!list_empty(&rt->rt6i_uncached)) && rt->dst.from))
 		rt = (struct rt6_info *)(rt->dst.from);
 
 	return rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
diff --git a/net/core/dst.c b/net/core/dst.c
index 573dcf21b0af..93d6006ac9ce 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -269,7 +269,7 @@ static void __metadata_dst_init(struct metadata_dst *md_dst, u8 optslen)
 
 	dst = &md_dst->dst;
 	dst_init(dst, &md_dst_ops, NULL, 1, DST_OBSOLETE_NONE,
-		 DST_METADATA | DST_NOCACHE | DST_NOCOUNT);
+		 DST_METADATA | DST_NOCOUNT);
 
 	dst->input = dst_md_discard;
 	dst->output = dst_md_discard_out;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9a0f496f8bf4..c816cd53f7fc 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1299,7 +1299,7 @@ static struct fib_nh_exception *find_exception(struct fib_nh *nh, __be32 daddr)
 }
 
 static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
-			      __be32 daddr)
+			      __be32 daddr, const bool do_cache)
 {
 	bool ret = false;
 
@@ -1328,7 +1328,7 @@ static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
 		if (!rt->rt_gateway)
 			rt->rt_gateway = daddr;
 
-		if (!(rt->dst.flags & DST_NOCACHE)) {
+		if (do_cache) {
 			dst_hold(&rt->dst);
 			rcu_assign_pointer(*porig, rt);
 			if (orig) {
@@ -1441,7 +1441,8 @@ static bool rt_cache_valid(const struct rtable *rt)
 static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 			   const struct fib_result *res,
 			   struct fib_nh_exception *fnhe,
-			   struct fib_info *fi, u16 type, u32 itag)
+			   struct fib_info *fi, u16 type, u32 itag,
+			   const bool do_cache)
 {
 	bool cached = false;
 
@@ -1462,8 +1463,8 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 #endif
 		rt->dst.lwtstate = lwtstate_get(nh->nh_lwtstate);
 		if (unlikely(fnhe))
-			cached = rt_bind_exception(rt, fnhe, daddr);
-		else if (!(rt->dst.flags & DST_NOCACHE))
+			cached = rt_bind_exception(rt, fnhe, daddr, do_cache);
+		else if (do_cache)
 			cached = rt_cache_route(nh, rt);
 		if (unlikely(!cached)) {
 			/* Routes we intend to cache in nexthop exception or
@@ -1471,7 +1472,6 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 			 * However, if we are unsuccessful at storing this
 			 * route into the cache we really need to set it.
 			 */
-			rt->dst.flags |= DST_NOCACHE;
 			if (!rt->rt_gateway)
 				rt->rt_gateway = daddr;
 			rt_add_uncached_list(rt);
@@ -1494,7 +1494,7 @@ struct rtable *rt_dst_alloc(struct net_device *dev,
 	struct rtable *rt;
 
 	rt = dst_alloc(&ipv4_dst_ops, dev, 1, DST_OBSOLETE_FORCE_CHK,
-		       (will_cache ? 0 : (DST_HOST | DST_NOCACHE)) |
+		       (will_cache ? 0 : DST_HOST) |
 		       (nopolicy ? DST_NOPOLICY : 0) |
 		       (noxfrm ? DST_NOXFRM : 0));
 
@@ -1738,7 +1738,8 @@ static int __mkroute_input(struct sk_buff *skb,
 
 	rth->dst.input = ip_forward;
 
-	rt_set_nexthop(rth, daddr, res, fnhe, res->fi, res->type, itag);
+	rt_set_nexthop(rth, daddr, res, fnhe, res->fi, res->type, itag,
+		       do_cache);
 	set_lwt_redirect(rth);
 	skb_dst_set(skb, &rth->dst);
 out:
@@ -2026,10 +2027,8 @@ out:	return err;
 			rth->dst.input = lwtunnel_input;
 		}
 
-		if (unlikely(!rt_cache_route(nh, rth))) {
-			rth->dst.flags |= DST_NOCACHE;
+		if (unlikely(!rt_cache_route(nh, rth)))
 			rt_add_uncached_list(rth);
-		}
 	}
 	skb_dst_set(skb, &rth->dst);
 	err = 0;
@@ -2260,7 +2259,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 #endif
 	}
 
-	rt_set_nexthop(rth, fl4->daddr, res, fnhe, fi, type, 0);
+	rt_set_nexthop(rth, fl4->daddr, res, fnhe, fi, type, 0, do_cache);
 	set_lwt_redirect(rth);
 
 	return rth;
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index c67ec79bf0da..4f3e4657f2d6 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -975,8 +975,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 	int replace_required = 0;
 	int sernum = fib6_new_sernum(info->nl_net);
 
-	if (WARN_ON_ONCE((rt->dst.flags & DST_NOCACHE) &&
-			 !atomic_read(&rt->dst.__refcnt)))
+	if (WARN_ON_ONCE(!atomic_read(&rt->dst.__refcnt)))
 		return -EINVAL;
 
 	if (info->nlh) {
@@ -1073,7 +1072,6 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 		fib6_start_gc(info->nl_net, rt);
 		if (!(rt->rt6i_flags & RTF_CACHE))
 			fib6_prune_clones(info->nl_net, pn);
-		rt->dst.flags &= ~DST_NOCACHE;
 	}
 
 out:
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6b6528fa3292..2e4490076061 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -128,7 +128,6 @@ static void rt6_uncached_list_add(struct rt6_info *rt)
 {
 	struct uncached_list *ul = raw_cpu_ptr(&rt6_uncached_list);
 
-	rt->dst.flags |= DST_NOCACHE;
 	rt->rt6i_uncached_list = ul;
 
 	spin_lock_bh(&ul->lock);
@@ -1326,7 +1325,7 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 	rt6_dst_from_metrics_check(rt);
 
 	if (rt->rt6i_flags & RTF_PCPU ||
-	    (unlikely(dst->flags & DST_NOCACHE) && rt->dst.from))
+	    (unlikely(!list_empty(&rt->rt6i_uncached)) && rt->dst.from))
 		return rt6_dst_from_check(rt, cookie);
 	else
 		return rt6_check(rt, cookie);
@@ -2130,8 +2129,7 @@ static int __ip6_del_rt(struct rt6_info *rt, struct nl_info *info)
 	struct fib6_table *table;
 	struct net *net = dev_net(rt->dst.dev);
 
-	if (rt == net->ipv6.ip6_null_entry ||
-	    rt->dst.flags & DST_NOCACHE) {
+	if (rt == net->ipv6.ip6_null_entry) {
 		err = -ENOENT;
 		goto out;
 	}
@@ -2722,7 +2720,6 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	rt->rt6i_dst.plen = 128;
 	tb_id = l3mdev_fib_table(idev->dev) ? : RT6_TABLE_LOCAL;
 	rt->rt6i_table = fib6_get_table(net, tb_id);
-	rt->dst.flags |= DST_NOCACHE;
 
 	return rt;
 }
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 3f7e77f11112..af8e38f47b5b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2231,7 +2231,6 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 			}
 
 			dst_hold(&xdst->u.dst);
-			xdst->u.dst.flags |= DST_NOCACHE;
 			route = xdst->route;
 		}
 	}
-- 
2.13.1.518.g3df882009-goog
