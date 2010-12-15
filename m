From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH] net: Implement read-only protection and COW'ing of
 metrics.
Date: Wed, 15 Dec 2010 13:21:13 -0800 (PST)
Message-ID: <20101215.132113.189700977.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47774
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752157Ab0LOVUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 16:20:44 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5F11B24C088
	for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 13:21:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Routing metrics are now copy-on-write.

Initially a route entry points it's metrics at a read-only location.
If a routing table entry exists, it will point there.  Else it will
point at the all zero metric place- holder 'dst_default_metrics'.

The writeability state of the metrics is stored in the low bits of the
metrics pointer, we have two bits left to spare if we want to store
more states.

For the initial implementation, COW is implemented simply via kmalloc.
However future enhancements will change this to place the writable
metrics somewhere else, in order to increase sharing.  Very likely
this "somewhere else" will be the inetpeer cache.

Note also that this means that metrics updates may transiently fail
if we cannot COW the metrics successfully.

But even by itself, this patch should decrease memory usage and
increase cache locality especially for routing workloads.  In those
cases the read-only metric copies stay in place and never get written
to.

TCP workloads where metrics get updated, and those rare cases where
PMTU triggers occur, will take a very slight performance hit.  But
that hit will be alleviated when the long-term writable metrics
move to a more sharable location.

Since the metrics storage went from a u32 array of RTAX_MAX entries to
what is essentially a pointer, some retooling of the dst_entry layout
was necessary.

Most importantly, we need to preserve the alignment of the reference
count so that it doesn't share cache lines with the read-mostly state,
as per Eric Dumazet's alignment assertion checks.

The only non-trivial bit here is the move of the 'flags' member into
the writeable cacheline.  This is OK since we are always accessing the
flags around the same moment when we made a modification to the
reference count.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

I have this at the point where it survives basic testing so I thought
I'd post it so people can see it, maybe test it out, and give some
comments.

Once this is solidified I'll work on the inetpeer metrics stuff.

 include/net/dst.h       |   80 +++++++++++++++++++++++++++++++----------------
 include/net/dst_ops.h   |    1 +
 net/core/dst.c          |   27 ++++++++++++++++
 net/decnet/dn_route.c   |   18 +++++++---
 net/ipv4/route.c        |    5 ++-
 net/ipv4/xfrm4_policy.c |    4 ++
 net/ipv6/route.c        |   16 +++++++--
 net/ipv6/xfrm6_policy.c |    4 ++
 8 files changed, 119 insertions(+), 36 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 93b0310..985dbb4 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -40,24 +40,10 @@ struct dst_entry {
 	struct rcu_head		rcu_head;
 	struct dst_entry	*child;
 	struct net_device       *dev;
-	short			error;
-	short			obsolete;
-	int			flags;
-#define DST_HOST		0x0001
-#define DST_NOXFRM		0x0002
-#define DST_NOPOLICY		0x0004
-#define DST_NOHASH		0x0008
-#define DST_NOCACHE		0x0010
+	struct  dst_ops	        *ops;
+	unsigned long		_metrics;
 	unsigned long		expires;
-
-	unsigned short		header_len;	/* more space at head required */
-	unsigned short		trailer_len;	/* space to reserve at tail */
-
-	unsigned int		rate_tokens;
-	unsigned long		rate_last;	/* rate limiting for ICMP */
-
 	struct dst_entry	*path;
-
 	struct neighbour	*neighbour;
 	struct hh_cache		*hh;
 #ifdef CONFIG_XFRM
@@ -68,17 +54,16 @@ struct dst_entry {
 	int			(*input)(struct sk_buff*);
 	int			(*output)(struct sk_buff*);
 
-	struct  dst_ops	        *ops;
-
-	u32			_metrics[RTAX_MAX];
-
+	short			error;
+	short			obsolete;
+	unsigned short		header_len;	/* more space at head required */
+	unsigned short		trailer_len;	/* space to reserve at tail */
 #ifdef CONFIG_NET_CLS_ROUTE
 	__u32			tclassid;
 #else
 	__u32			__pad2;
 #endif
 
-
 	/*
 	 * Align __refcnt to a 64 bytes alignment
 	 * (L1_CACHE_SIZE would be too much)
@@ -93,6 +78,14 @@ struct dst_entry {
 	atomic_t		__refcnt;	/* client references	*/
 	int			__use;
 	unsigned long		lastuse;
+	unsigned long		rate_last;	/* rate limiting for ICMP */
+	unsigned int		rate_tokens;
+	int			flags;
+#define DST_HOST		0x0001
+#define DST_NOXFRM		0x0002
+#define DST_NOPOLICY		0x0004
+#define DST_NOHASH		0x0008
+#define DST_NOCACHE		0x0010
 	union {
 		struct dst_entry	*next;
 		struct rtable __rcu	*rt_next;
@@ -103,10 +96,31 @@ struct dst_entry {
 
 #ifdef __KERNEL__
 
+extern bool dst_cow_metrics_generic(struct dst_entry *dst);
+extern void dst_destroy_metrics_generic(struct dst_entry *dst);
+
+#define DST_METRICS_READ_ONLY	0x1UL
+#define DST_METRICS_PTR(X)	\
+	((u32 *)((X)->_metrics & ~DST_METRICS_READ_ONLY))
+
+static inline bool dst_metrics_read_only(const struct dst_entry *dst)
+{
+	return dst->_metrics & DST_METRICS_READ_ONLY;
+}
+
+static inline bool dst_metrics_can_write(struct dst_entry *dst)
+{
+	if (dst_metrics_read_only(dst))
+		return dst->ops->cow_metrics(dst);
+	return true;
+}
+
 static inline u32
 dst_metric_raw(const struct dst_entry *dst, const int metric)
 {
-	return dst->_metrics[metric-1];
+	u32 *p = DST_METRICS_PTR(dst);
+
+	return p[metric-1];
 }
 
 static inline u32
@@ -131,22 +145,34 @@ dst_metric_advmss(const struct dst_entry *dst)
 
 static inline void dst_metric_set(struct dst_entry *dst, int metric, u32 val)
 {
-	dst->_metrics[metric-1] = val;
+	if (dst_metrics_can_write(dst)) {
+		u32 *p = DST_METRICS_PTR(dst);
+
+		p[metric-1] = val;
+	}
 }
 
-static inline void dst_import_metrics(struct dst_entry *dst, const u32 *src_metrics)
+static inline void dst_attach_metrics(struct dst_entry *dst,
+				      const u32 *src_metrics,
+				      bool read_only)
 {
-	memcpy(dst->_metrics, src_metrics, RTAX_MAX * sizeof(u32));
+	dst->_metrics = ((unsigned long) src_metrics) |
+		(read_only ? DST_METRICS_READ_ONLY : 0);
 }
 
 static inline void dst_copy_metrics(struct dst_entry *dest, const struct dst_entry *src)
 {
-	dst_import_metrics(dest, src->_metrics);
+	if (dst_metrics_can_write(dest)) {
+		u32 *dst_metrics = DST_METRICS_PTR(dest);
+		u32 *src_metrics = DST_METRICS_PTR(src);
+
+		memcpy(dst_metrics, src_metrics, RTAX_MAX * sizeof(u32));
+	}
 }
 
 static inline u32 *dst_metrics_ptr(struct dst_entry *dst)
 {
-	return dst->_metrics;
+	return DST_METRICS_PTR(dst);
 }
 
 static inline u32
diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index 21a320b..731999d 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -18,6 +18,7 @@ struct dst_ops {
 	struct dst_entry *	(*check)(struct dst_entry *, __u32 cookie);
 	unsigned int		(*default_advmss)(const struct dst_entry *);
 	unsigned int		(*default_mtu)(const struct dst_entry *);
+	bool			(*cow_metrics)(struct dst_entry *);
 	void			(*destroy)(struct dst_entry *);
 	void			(*ifdown)(struct dst_entry *,
 					  struct net_device *dev, int how);
diff --git a/net/core/dst.c b/net/core/dst.c
index b99c7c7..36df659 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -164,6 +164,8 @@ int dst_discard(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(dst_discard);
 
+static const u32 dst_default_metrics[RTAX_MAX];
+
 void *dst_alloc(struct dst_ops *ops)
 {
 	struct dst_entry *dst;
@@ -180,6 +182,7 @@ void *dst_alloc(struct dst_ops *ops)
 	dst->lastuse = jiffies;
 	dst->path = dst;
 	dst->input = dst->output = dst_discard;
+	dst_attach_metrics(dst, dst_default_metrics, true);
 #if RT_CACHE_DEBUG >= 2
 	atomic_inc(&dst_total);
 #endif
@@ -282,6 +285,30 @@ void dst_release(struct dst_entry *dst)
 }
 EXPORT_SYMBOL(dst_release);
 
+bool dst_cow_metrics_generic(struct dst_entry *dst)
+{
+	u32 *p = kmalloc(sizeof(u32) * RTAX_MAX, GFP_ATOMIC);
+	u32 *old_p;
+
+	if (!p)
+		return false;
+
+	old_p = DST_METRICS_PTR(dst);
+	memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
+
+	dst_attach_metrics(dst, p, false);
+
+	return true;
+}
+EXPORT_SYMBOL(dst_cow_metrics_generic);
+
+void dst_destroy_metrics_generic(struct dst_entry *dst)
+{
+	if (!dst_metrics_read_only(dst))
+		kfree(DST_METRICS_PTR(dst));
+}
+EXPORT_SYMBOL(dst_destroy_metrics_generic);
+
 /**
  * skb_dst_set_noref - sets skb dst, without a reference
  * @skb: buffer
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 5e63636..a672c77 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -112,6 +112,7 @@ static int dn_dst_gc(struct dst_ops *ops);
 static struct dst_entry *dn_dst_check(struct dst_entry *, __u32);
 static unsigned int dn_dst_default_advmss(const struct dst_entry *dst);
 static unsigned int dn_dst_default_mtu(const struct dst_entry *dst);
+static void dn_dst_destroy(struct dst_entry *);
 static struct dst_entry *dn_dst_negative_advice(struct dst_entry *);
 static void dn_dst_link_failure(struct sk_buff *);
 static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu);
@@ -133,11 +134,18 @@ static struct dst_ops dn_dst_ops = {
 	.check =		dn_dst_check,
 	.default_advmss =	dn_dst_default_advmss,
 	.default_mtu =		dn_dst_default_mtu,
+	.cow_metrics =		dst_cow_metrics_generic,
+	.destroy =		dn_dst_destroy,
 	.negative_advice =	dn_dst_negative_advice,
 	.link_failure =		dn_dst_link_failure,
 	.update_pmtu =		dn_dst_update_pmtu,
 };
 
+static void dn_dst_destroy(struct dst_entry *dst)
+{
+	dst_destroy_metrics_generic(dst);
+}
+
 static __inline__ unsigned dn_hash(__le16 src, __le16 dst)
 {
 	__u16 tmp = (__u16 __force)(src ^ dst);
@@ -814,14 +822,14 @@ static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
 {
 	struct dn_fib_info *fi = res->fi;
 	struct net_device *dev = rt->dst.dev;
+	unsigned int mss_metric;
 	struct neighbour *n;
-	unsigned int metric;
 
 	if (fi) {
 		if (DN_FIB_RES_GW(*res) &&
 		    DN_FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = DN_FIB_RES_GW(*res);
-		dst_import_metrics(&rt->dst, fi->fib_metrics);
+		dst_attach_metrics(&rt->dst, fi->fib_metrics, true);
 	}
 	rt->rt_type = res->type;
 
@@ -834,10 +842,10 @@ static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
 
 	if (dst_metric(&rt->dst, RTAX_MTU) > rt->dst.dev->mtu)
 		dst_metric_set(&rt->dst, RTAX_MTU, rt->dst.dev->mtu);
-	metric = dst_metric_raw(&rt->dst, RTAX_ADVMSS);
-	if (metric) {
+	mss_metric = dst_metric_raw(&rt->dst, RTAX_ADVMSS);
+	if (mss_metric) {
 		unsigned int mss = dn_mss_from_pmtu(dev, dst_mtu(&rt->dst));
-		if (metric > mss)
+		if (mss_metric > mss)
 			dst_metric_set(&rt->dst, RTAX_ADVMSS, mss);
 	}
 	return 0;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ae52096..5cf549d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -159,6 +159,7 @@ static struct dst_ops ipv4_dst_ops = {
 	.check =		ipv4_dst_check,
 	.default_advmss =	ipv4_default_advmss,
 	.default_mtu =		ipv4_default_mtu,
+	.cow_metrics =		dst_cow_metrics_generic,
 	.destroy =		ipv4_dst_destroy,
 	.ifdown =		ipv4_dst_ifdown,
 	.negative_advice =	ipv4_negative_advice,
@@ -1740,6 +1741,8 @@ static void ipv4_dst_destroy(struct dst_entry *dst)
 		rt->peer = NULL;
 		inet_putpeer(peer);
 	}
+
+	dst_destroy_metrics_generic(dst);
 }
 
 
@@ -1840,7 +1843,7 @@ static void rt_set_nexthop(struct rtable *rt, struct fib_result *res, u32 itag)
 		if (FIB_RES_GW(*res) &&
 		    FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = FIB_RES_GW(*res);
-		dst_import_metrics(dst, fi->fib_metrics);
+		dst_attach_metrics(dst, fi->fib_metrics, true);
 #ifdef CONFIG_NET_CLS_ROUTE
 		dst->tclassid = FIB_RES_NH(*res).nh_tclassid;
 #endif
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index b057d40..e4d2b3a 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -198,6 +198,9 @@ static void xfrm4_dst_destroy(struct dst_entry *dst)
 
 	if (likely(xdst->u.rt.peer))
 		inet_putpeer(xdst->u.rt.peer);
+
+	dst_destroy_metrics_generic(dst);
+
 	xfrm_dst_destroy(xdst);
 }
 
@@ -215,6 +218,7 @@ static struct dst_ops xfrm4_dst_ops = {
 	.protocol =		cpu_to_be16(ETH_P_IP),
 	.gc =			xfrm4_garbage_collect,
 	.update_pmtu =		xfrm4_update_pmtu,
+	.cow_metrics =		dst_cow_metrics_generic,
 	.destroy =		xfrm4_dst_destroy,
 	.ifdown =		xfrm4_dst_ifdown,
 	.local_out =		__ip_local_out,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e7efb26..8073f26 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -107,6 +107,7 @@ static struct dst_ops ip6_dst_ops_template = {
 	.check			=	ip6_dst_check,
 	.default_advmss		=	ip6_default_advmss,
 	.default_mtu		=	ip6_default_mtu,
+	.cow_metrics		=	dst_cow_metrics_generic,
 	.destroy		=	ip6_dst_destroy,
 	.ifdown			=	ip6_dst_ifdown,
 	.negative_advice	=	ip6_negative_advice,
@@ -127,6 +128,10 @@ static struct dst_ops ip6_dst_blackhole_ops = {
 	.update_pmtu		=	ip6_rt_blackhole_update_pmtu,
 };
 
+static const u32 ip6_template_metrics[RTAX_MAX] = {
+	[RTAX_HOPLIMIT - 1] = 255,
+};
+
 static struct rt6_info ip6_null_entry_template = {
 	.dst = {
 		.__refcnt	= ATOMIC_INIT(1),
@@ -200,6 +205,8 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 		rt->rt6i_peer = NULL;
 		inet_putpeer(peer);
 	}
+
+	dst_destroy_metrics_generic(dst);
 }
 
 void rt6_bind_peer(struct rt6_info *rt, int create)
@@ -2683,7 +2690,8 @@ static int __net_init ip6_route_net_init(struct net *net)
 	net->ipv6.ip6_null_entry->dst.path =
 		(struct dst_entry *)net->ipv6.ip6_null_entry;
 	net->ipv6.ip6_null_entry->dst.ops = &net->ipv6.ip6_dst_ops;
-	dst_metric_set(&net->ipv6.ip6_null_entry->dst, RTAX_HOPLIMIT, 255);
+	dst_attach_metrics(&net->ipv6.ip6_null_entry->dst,
+			   ip6_template_metrics, true);
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	net->ipv6.ip6_prohibit_entry = kmemdup(&ip6_prohibit_entry_template,
@@ -2694,7 +2702,8 @@ static int __net_init ip6_route_net_init(struct net *net)
 	net->ipv6.ip6_prohibit_entry->dst.path =
 		(struct dst_entry *)net->ipv6.ip6_prohibit_entry;
 	net->ipv6.ip6_prohibit_entry->dst.ops = &net->ipv6.ip6_dst_ops;
-	dst_metric_set(&net->ipv6.ip6_prohibit_entry->dst, RTAX_HOPLIMIT, 255);
+	dst_attach_metrics(&net->ipv6.ip6_prohibit_entry->dst,
+			   ip6_template_metrics, true);
 
 	net->ipv6.ip6_blk_hole_entry = kmemdup(&ip6_blk_hole_entry_template,
 					       sizeof(*net->ipv6.ip6_blk_hole_entry),
@@ -2704,7 +2713,8 @@ static int __net_init ip6_route_net_init(struct net *net)
 	net->ipv6.ip6_blk_hole_entry->dst.path =
 		(struct dst_entry *)net->ipv6.ip6_blk_hole_entry;
 	net->ipv6.ip6_blk_hole_entry->dst.ops = &net->ipv6.ip6_dst_ops;
-	dst_metric_set(&net->ipv6.ip6_blk_hole_entry->dst, RTAX_HOPLIMIT, 255);
+	dst_attach_metrics(&net->ipv6.ip6_blk_hole_entry->dst,
+			   ip6_template_metrics, true);
 #endif
 
 	net->ipv6.sysctl.flush_delay = 0;
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 7e74023..78d9d7b 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -216,6 +216,9 @@ static void xfrm6_dst_destroy(struct dst_entry *dst)
 
 	if (likely(xdst->u.rt6.rt6i_idev))
 		in6_dev_put(xdst->u.rt6.rt6i_idev);
+
+	dst_destroy_metrics_generic(dst);
+
 	xfrm_dst_destroy(xdst);
 }
 
@@ -251,6 +254,7 @@ static struct dst_ops xfrm6_dst_ops = {
 	.protocol =		cpu_to_be16(ETH_P_IPV6),
 	.gc =			xfrm6_garbage_collect,
 	.update_pmtu =		xfrm6_update_pmtu,
+	.cow_metrics =		dst_cow_metrics_generic,
 	.destroy =		xfrm6_dst_destroy,
 	.ifdown =		xfrm6_dst_ifdown,
 	.local_out =		__ip6_local_out,
-- 
1.7.3.2

