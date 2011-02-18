From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/7] net: Add initial_ref arg to dst_alloc().
Date: Thu, 17 Feb 2011 16:12:04 -0800 (PST)
Message-ID: <20110217.161204.191390404.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57124
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754591Ab1BRAL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 19:11:28 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 73B5724C087
	for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 16:12:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This allows avoiding multiple writes to the initial __refcnt.

The most simplest cases of wanting an initial reference of "1"
in ipv4 and ipv6 have been converted, the rest have been left
along and kept at the existing "0".

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h      |    2 +-
 net/core/dst.c         |    4 ++--
 net/decnet/dn_route.c  |    4 ++--
 net/ipv4/route.c       |    7 ++-----
 net/ipv6/route.c       |    5 ++---
 net/xfrm/xfrm_policy.c |    2 +-
 6 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index e01855d..23b564d 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -352,7 +352,7 @@ static inline struct dst_entry *skb_dst_pop(struct sk_buff *skb)
 }
 
 extern int dst_discard(struct sk_buff *skb);
-extern void * dst_alloc(struct dst_ops * ops);
+extern void *dst_alloc(struct dst_ops * ops, int initial_ref);
 extern void __dst_free(struct dst_entry * dst);
 extern struct dst_entry *dst_destroy(struct dst_entry * dst);
 
diff --git a/net/core/dst.c b/net/core/dst.c
index c1674fd..91104d3 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -166,7 +166,7 @@ EXPORT_SYMBOL(dst_discard);
 
 const u32 dst_default_metrics[RTAX_MAX];
 
-void *dst_alloc(struct dst_ops *ops)
+void *dst_alloc(struct dst_ops *ops, int initial_ref)
 {
 	struct dst_entry *dst;
 
@@ -177,7 +177,7 @@ void *dst_alloc(struct dst_ops *ops)
 	dst = kmem_cache_zalloc(ops->kmem_cachep, GFP_ATOMIC);
 	if (!dst)
 		return NULL;
-	atomic_set(&dst->__refcnt, 0);
+	atomic_set(&dst->__refcnt, initial_ref);
 	dst->ops = ops;
 	dst->lastuse = jiffies;
 	dst->path = dst;
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 42c9c62..06c054d 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1122,7 +1122,7 @@ make_route:
 	if (dev_out->flags & IFF_LOOPBACK)
 		flags |= RTCF_LOCAL;
 
-	rt = dst_alloc(&dn_dst_ops);
+	rt = dst_alloc(&dn_dst_ops, 0);
 	if (rt == NULL)
 		goto e_nobufs;
 
@@ -1383,7 +1383,7 @@ static int dn_route_input_slow(struct sk_buff *skb)
 	}
 
 make_route:
-	rt = dst_alloc(&dn_dst_ops);
+	rt = dst_alloc(&dn_dst_ops, 0);
 	if (rt == NULL)
 		goto e_nobufs;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 79a2871..9841543 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1818,12 +1818,10 @@ static void rt_set_nexthop(struct rtable *rt, struct fib_result *res, u32 itag)
 
 static struct rtable *rt_dst_alloc(bool nopolicy, bool noxfrm)
 {
-	struct rtable *rt = dst_alloc(&ipv4_dst_ops);
+	struct rtable *rt = dst_alloc(&ipv4_dst_ops, 1);
 	if (rt) {
 		rt->dst.obsolete = -1;
 
-		atomic_set(&rt->dst.__refcnt, 1);
-
 		rt->dst.flags = DST_HOST |
 			(nopolicy ? DST_NOPOLICY : 0) |
 			(noxfrm ? DST_NOXFRM : 0);
@@ -2679,12 +2677,11 @@ static int ipv4_dst_blackhole(struct net *net, struct rtable **rp, struct flowi
 {
 	struct rtable *ort = *rp;
 	struct rtable *rt = (struct rtable *)
-		dst_alloc(&ipv4_dst_blackhole_ops);
+		dst_alloc(&ipv4_dst_blackhole_ops, 1);
 
 	if (rt) {
 		struct dst_entry *new = &rt->dst;
 
-		atomic_set(&new->__refcnt, 1);
 		new->__use = 1;
 		new->input = dst_discard;
 		new->output = dst_discard;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ad8556e..7946b53 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -221,7 +221,7 @@ static struct rt6_info ip6_blk_hole_entry_template = {
 /* allocate dst with ip6_dst_ops */
 static inline struct rt6_info *ip6_dst_alloc(struct dst_ops *ops)
 {
-	return (struct rt6_info *)dst_alloc(ops);
+	return (struct rt6_info *)dst_alloc(ops, 0);
 }
 
 static void ip6_dst_destroy(struct dst_entry *dst)
@@ -873,13 +873,12 @@ int ip6_dst_blackhole(struct sock *sk, struct dst_entry **dstp, struct flowi *fl
 {
 	struct rt6_info *ort = (struct rt6_info *) *dstp;
 	struct rt6_info *rt = (struct rt6_info *)
-		dst_alloc(&ip6_dst_blackhole_ops);
+		dst_alloc(&ip6_dst_blackhole_ops, 1);
 	struct dst_entry *new = NULL;
 
 	if (rt) {
 		new = &rt->dst;
 
-		atomic_set(&new->__refcnt, 1);
 		new->__use = 1;
 		new->input = dst_discard;
 		new->output = dst_discard;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 8b3ef40..3f1257a 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1340,7 +1340,7 @@ static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 	default:
 		BUG();
 	}
-	xdst = dst_alloc(dst_ops) ?: ERR_PTR(-ENOBUFS);
+	xdst = dst_alloc(dst_ops, 0) ?: ERR_PTR(-ENOBUFS);
 	xfrm_policy_put_afinfo(afinfo);
 
 	xdst->flo.ops = &xfrm_bundle_fc_ops;
-- 
1.7.4.1

