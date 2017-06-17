From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH v2 net-next 18/21] net: remove DST_NOGC flag
Date: Sat, 17 Jun 2017 10:42:41 -0700
Message-ID: <20170617174244.132862-19-tracywwnj@gmail.com>
References: <20170617174244.132862-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36243 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752665AbdFQRns (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 13:43:48 -0400
Received: by mail-pf0-f196.google.com with SMTP id y7so11097319pfd.3
        for <netdev@vger.kernel.org>; Sat, 17 Jun 2017 10:43:48 -0700 (PDT)
In-Reply-To: <20170617174244.132862-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Now that all the components have been changed to release dst based on
refcnt only and not depend on dst gc anymore, we can remove the
temporary flag DST_NOGC.

Note that we also need to remove the DST_NOCACHE check in dst_release()
and dst_hold_safe() because now all the dst are released based on refcnt
and behaves as DST_NOCACHE.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 include/net/dst.h      | 6 +-----
 net/core/dst.c         | 4 +---
 net/decnet/dn_route.c  | 6 ++----
 net/ipv4/route.c       | 5 ++---
 net/ipv6/route.c       | 5 ++---
 net/xfrm/xfrm_policy.c | 2 +-
 6 files changed, 9 insertions(+), 19 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 0c56d1fc4d7f..1be82f672c37 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -57,7 +57,6 @@ struct dst_entry {
 #define DST_XFRM_TUNNEL		0x0080
 #define DST_XFRM_QUEUE		0x0100
 #define DST_METADATA		0x0200
-#define DST_NOGC		0x0400
 
 	short			error;
 
@@ -336,10 +335,7 @@ static inline void skb_dst_force(struct sk_buff *skb)
  */
 static inline bool dst_hold_safe(struct dst_entry *dst)
 {
-	if (dst->flags & (DST_NOCACHE | DST_NOGC))
-		return atomic_inc_not_zero(&dst->__refcnt);
-	dst_hold(dst);
-	return true;
+	return atomic_inc_not_zero(&dst->__refcnt);
 }
 
 /**
diff --git a/net/core/dst.c b/net/core/dst.c
index 30bea01d2262..70543dabb797 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -179,14 +179,12 @@ void dst_release(struct dst_entry *dst)
 {
 	if (dst) {
 		int newrefcnt;
-		unsigned short destroy_after_rcu = dst->flags &
-						   (DST_NOCACHE | DST_NOGC);
 
 		newrefcnt = atomic_dec_return(&dst->__refcnt);
 		if (unlikely(newrefcnt < 0))
 			net_warn_ratelimited("%s: dst:%p refcnt:%d\n",
 					     __func__, dst, newrefcnt);
-		if (!newrefcnt && unlikely(destroy_after_rcu))
+		if (!newrefcnt)
 			call_rcu(&dst->rcu_head, dst_destroy_rcu);
 	}
 }
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index f467c4e3205b..5d17d843ac86 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1179,8 +1179,7 @@ static int dn_route_output_slow(struct dst_entry **pprt, const struct flowidn *o
 	if (dev_out->flags & IFF_LOOPBACK)
 		flags |= RTCF_LOCAL;
 
-	rt = dst_alloc(&dn_dst_ops, dev_out, 1, DST_OBSOLETE_NONE,
-		       DST_HOST | DST_NOGC);
+	rt = dst_alloc(&dn_dst_ops, dev_out, 1, DST_OBSOLETE_NONE, DST_HOST);
 	if (rt == NULL)
 		goto e_nobufs;
 
@@ -1445,8 +1444,7 @@ static int dn_route_input_slow(struct sk_buff *skb)
 	}
 
 make_route:
-	rt = dst_alloc(&dn_dst_ops, out_dev, 1, DST_OBSOLETE_NONE,
-		       DST_HOST | DST_NOGC);
+	rt = dst_alloc(&dn_dst_ops, out_dev, 1, DST_OBSOLETE_NONE, DST_HOST);
 	if (rt == NULL)
 		goto e_nobufs;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 80b30c2bf47d..9a0f496f8bf4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1496,8 +1496,7 @@ struct rtable *rt_dst_alloc(struct net_device *dev,
 	rt = dst_alloc(&ipv4_dst_ops, dev, 1, DST_OBSOLETE_FORCE_CHK,
 		       (will_cache ? 0 : (DST_HOST | DST_NOCACHE)) |
 		       (nopolicy ? DST_NOPOLICY : 0) |
-		       (noxfrm ? DST_NOXFRM : 0) |
-		       DST_NOGC);
+		       (noxfrm ? DST_NOXFRM : 0));
 
 	if (rt) {
 		rt->rt_genid = rt_genid_ipv4(dev_net(dev));
@@ -2503,7 +2502,7 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 	struct rtable *ort = (struct rtable *) dst_orig;
 	struct rtable *rt;
 
-	rt = dst_alloc(&ipv4_dst_blackhole_ops, NULL, 1, DST_OBSOLETE_NONE, DST_NOGC);
+	rt = dst_alloc(&ipv4_dst_blackhole_ops, NULL, 1, DST_OBSOLETE_NONE, 0);
 	if (rt) {
 		struct dst_entry *new = &rt->dst;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c88044b8fa7c..6b6528fa3292 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -354,8 +354,7 @@ static struct rt6_info *__ip6_dst_alloc(struct net *net,
 					int flags)
 {
 	struct rt6_info *rt = dst_alloc(&net->ipv6.ip6_dst_ops, dev,
-					1, DST_OBSOLETE_FORCE_CHK,
-					flags | DST_NOGC);
+					1, DST_OBSOLETE_FORCE_CHK, flags);
 
 	if (rt)
 		rt6_info_init(rt);
@@ -1255,7 +1254,7 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 	struct dst_entry *new = NULL;
 
 	rt = dst_alloc(&ip6_dst_blackhole_ops, loopback_dev, 1,
-		       DST_OBSOLETE_NONE, DST_NOGC);
+		       DST_OBSOLETE_NONE, 0);
 	if (rt) {
 		rt6_info_init(rt);
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 85e1e13639cc..3f7e77f11112 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1622,7 +1622,7 @@ static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 	default:
 		BUG();
 	}
-	xdst = dst_alloc(dst_ops, NULL, 1, DST_OBSOLETE_NONE, DST_NOGC);
+	xdst = dst_alloc(dst_ops, NULL, 1, DST_OBSOLETE_NONE, 0);
 
 	if (likely(xdst)) {
 		struct dst_entry *dst = &xdst->u.dst;
-- 
2.13.1.518.g3df882009-goog
