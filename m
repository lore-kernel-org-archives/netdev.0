From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: Implement read-only protection and COW'ing of
 metrics.
Date: Wed, 26 Jan 2011 15:25:38 -0800 (PST)
Message-ID: <20110126.152538.260074157.davem@davemloft.net>
References: <20101215.132113.189700977.davem@davemloft.net>
	<1292529359.2655.2.camel@edumazet-laptop>
	<20101216.115900.183061857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59309
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754164Ab1AZXZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 18:25:03 -0500
In-Reply-To: <20101216.115900.183061857.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric, thanks again for your feedback.  I've taken a stab at fixing the
various races, in particular the one you discovered about metrics
sharing and how this interacts with fib_info releases.

What I've choosen to do is two-fold:

1) Update ->_metrics atomically with cmpxchg once a route becomes publicly
   visible.

2) Remember and grab a reference to the fib_info for shared read-only
   metrics in rt->fi, then release it once the metrics regerence goes
   away.

It sounds expensive but hear me out :-)

First of all, at rt_set_nexthop() time, the atomic we use to grab a
ref to the fib_info is replacing a 60-byte memcpy() into the dst
metrics.

Next, the ->_metrics atomic to un-COW the metrics at destroy time
might in fact be overkill.  Especially once writable metrics live in
the inetpeer cache (that's the next set of patches after this one).

Finally, once this change is stabilized we can be a lot smarter about
what we do at the time an entry is created.  For example, when a route
is looked up for a TCP socket, we essentially know we are going to COW
the route %99.99999 of the time.  So we can pass a hint into TCP's
route lookups in the flow flags field telling it to pre-COW the route.

TCP pre-COW'ing of metrics will thus save several atomics.

Anyways, here is the patch, it is only build tested at this point, but
I wanted to get feedback from you about the basic gist of things
as soon as possible.

Thanks!

diff --git a/include/net/dst.h b/include/net/dst.h
index be5a0d4..94a8c23 100644
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
 #ifdef CONFIG_IP_ROUTE_CLASSID
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
@@ -103,10 +96,69 @@ struct dst_entry {
 
 #ifdef __KERNEL__
 
+extern u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old);
+
+#define DST_METRICS_READ_ONLY	0x1UL
+#define __DST_METRICS_PTR(Y)	\
+	((u32 *)((Y) & ~DST_METRICS_READ_ONLY))
+#define DST_METRICS_PTR(X)	__DST_METRICS_PTR((X)->_metrics)
+
+static inline bool dst_metrics_read_only(const struct dst_entry *dst)
+{
+	return dst->_metrics & DST_METRICS_READ_ONLY;
+}
+
+extern void __dst_destroy_metrics_generic(struct dst_entry *dst, unsigned long old);
+
+static inline void dst_destroy_metrics_generic(struct dst_entry *dst)
+{
+	unsigned long val = dst->_metrics;
+	if (!(val & DST_METRICS_READ_ONLY))
+		__dst_destroy_metrics_generic(dst, val);
+}
+
+static inline u32 *dst_metrics_write_ptr(struct dst_entry *dst)
+{
+	unsigned long p = dst->_metrics;
+
+	if (p & DST_METRICS_READ_ONLY)
+		return dst->ops->cow_metrics(dst, p);
+	return __DST_METRICS_PTR(p);
+}
+
+/* This may only be invoked before the entry has reached global
+ * visibility.
+ */
+static inline void dst_init_metrics(struct dst_entry *dst,
+				    const u32 *src_metrics,
+				    bool read_only)
+{
+	dst->_metrics = ((unsigned long) src_metrics) |
+		(read_only ? DST_METRICS_READ_ONLY : 0);
+}
+
+static inline void dst_copy_metrics(struct dst_entry *dest, const struct dst_entry *src)
+{
+	u32 *dst_metrics = dst_metrics_write_ptr(dest);
+
+	if (dst_metrics) {
+		u32 *src_metrics = DST_METRICS_PTR(src);
+
+		memcpy(dst_metrics, src_metrics, RTAX_MAX * sizeof(u32));
+	}
+}
+
+static inline u32 *dst_metrics_ptr(struct dst_entry *dst)
+{
+	return DST_METRICS_PTR(dst);
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
@@ -131,22 +183,10 @@ dst_metric_advmss(const struct dst_entry *dst)
 
 static inline void dst_metric_set(struct dst_entry *dst, int metric, u32 val)
 {
-	dst->_metrics[metric-1] = val;
-}
-
-static inline void dst_import_metrics(struct dst_entry *dst, const u32 *src_metrics)
-{
-	memcpy(dst->_metrics, src_metrics, RTAX_MAX * sizeof(u32));
-}
+	u32 *p = dst_metrics_write_ptr(dst);
 
-static inline void dst_copy_metrics(struct dst_entry *dest, const struct dst_entry *src)
-{
-	dst_import_metrics(dest, src->_metrics);
-}
-
-static inline u32 *dst_metrics_ptr(struct dst_entry *dst)
-{
-	return dst->_metrics;
+	if (p)
+		p[metric-1] = val;
 }
 
 static inline u32
diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index 21a320b..dc07463 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -18,6 +18,7 @@ struct dst_ops {
 	struct dst_entry *	(*check)(struct dst_entry *, __u32 cookie);
 	unsigned int		(*default_advmss)(const struct dst_entry *);
 	unsigned int		(*default_mtu)(const struct dst_entry *);
+	u32 *			(*cow_metrics)(struct dst_entry *, unsigned long);
 	void			(*destroy)(struct dst_entry *);
 	void			(*ifdown)(struct dst_entry *,
 					  struct net_device *dev, int how);
diff --git a/include/net/route.h b/include/net/route.h
index 93e10c4..5677cbf 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -49,6 +49,7 @@
 
 struct fib_nh;
 struct inet_peer;
+struct fib_info;
 struct rtable {
 	struct dst_entry	dst;
 
@@ -69,6 +70,7 @@ struct rtable {
 	/* Miscellaneous cached information */
 	__be32			rt_spec_dst; /* RFC1122 specific destination */
 	struct inet_peer	*peer; /* long-living peer info */
+	struct fib_info		*fi; /* for client ref to shared metrics */
 };
 
 static inline bool rt_is_input_route(struct rtable *rt)
diff --git a/net/core/dst.c b/net/core/dst.c
index b99c7c7..5788935 100644
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
+	dst_init_metrics(dst, dst_default_metrics, true);
 #if RT_CACHE_DEBUG >= 2
 	atomic_inc(&dst_total);
 #endif
@@ -282,6 +285,42 @@ void dst_release(struct dst_entry *dst)
 }
 EXPORT_SYMBOL(dst_release);
 
+u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old)
+{
+	u32 *p = kmalloc(sizeof(u32) * RTAX_MAX, GFP_ATOMIC);
+
+	if (p) {
+		u32 *old_p = __DST_METRICS_PTR(old);
+		unsigned long prev, new;
+
+		memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
+
+		new = (unsigned long) p;
+		prev = cmpxchg(&dst->_metrics, old, new);
+
+		if (prev != old) {
+			kfree(p);
+			p = __DST_METRICS_PTR(prev);
+			if (prev & DST_METRICS_READ_ONLY)
+				p = NULL;
+		}
+	}
+	return p;
+}
+EXPORT_SYMBOL(dst_cow_metrics_generic);
+
+/* Caller asserts that dst_metrics_read_only(dst) is false.  */
+void __dst_destroy_metrics_generic(struct dst_entry *dst, unsigned long old)
+{
+	unsigned long prev, new;
+
+	new = (unsigned long) dst_default_metrics;
+	prev = cmpxchg(&dst->_metrics, old, new);
+	if (prev == old)
+		kfree(__DST_METRICS_PTR(old));
+}
+EXPORT_SYMBOL(__dst_destroy_metrics_generic);
+
 /**
  * skb_dst_set_noref - sets skb dst, without a reference
  * @skb: buffer
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 5e63636..42c9c62 100644
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
+		dst_init_metrics(&rt->dst, fi->fib_metrics, true);
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
index 3e5b7cc..7fc6301 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -152,6 +152,36 @@ static void ipv4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 {
 }
 
+static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long old)
+{
+	u32 *p = kmalloc(sizeof(u32) * RTAX_MAX, GFP_ATOMIC);
+
+	if (p) {
+		u32 *old_p = __DST_METRICS_PTR(old);
+		unsigned long prev, new;
+
+		memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
+
+		new = (unsigned long) p;
+		prev = cmpxchg(&dst->_metrics, old, new);
+
+		if (prev != old) {
+			kfree(p);
+			p = __DST_METRICS_PTR(prev);
+			if (prev & DST_METRICS_READ_ONLY)
+				p = NULL;
+		} else {
+			struct rtable *rt = (struct rtable *) dst;
+
+			if (rt->fi) {
+				fib_info_put(rt->fi);
+				rt->fi = NULL;
+			}
+		}
+	}
+	return p;
+}
+
 static struct dst_ops ipv4_dst_ops = {
 	.family =		AF_INET,
 	.protocol =		cpu_to_be16(ETH_P_IP),
@@ -159,6 +189,7 @@ static struct dst_ops ipv4_dst_ops = {
 	.check =		ipv4_dst_check,
 	.default_advmss =	ipv4_default_advmss,
 	.default_mtu =		ipv4_default_mtu,
+	.cow_metrics =		ipv4_cow_metrics,
 	.destroy =		ipv4_dst_destroy,
 	.ifdown =		ipv4_dst_ifdown,
 	.negative_advice =	ipv4_negative_advice,
@@ -1720,6 +1751,11 @@ static void ipv4_dst_destroy(struct dst_entry *dst)
 	struct rtable *rt = (struct rtable *) dst;
 	struct inet_peer *peer = rt->peer;
 
+	dst_destroy_metrics_generic(dst);
+	if (rt->fi) {
+		fib_info_put(rt->fi);
+		rt->fi = NULL;
+	}
 	if (peer) {
 		rt->peer = NULL;
 		inet_putpeer(peer);
@@ -1824,7 +1860,9 @@ static void rt_set_nexthop(struct rtable *rt, struct fib_result *res, u32 itag)
 		if (FIB_RES_GW(*res) &&
 		    FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = FIB_RES_GW(*res);
-		dst_import_metrics(dst, fi->fib_metrics);
+		rt->fi = fi;
+		atomic_inc(&fi->fib_clntref);
+		dst_init_metrics(dst, fi->fib_metrics, true);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		dst->tclassid = FIB_RES_NH(*res).nh_tclassid;
 #endif
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index b057d40..19fbdec 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -196,8 +196,11 @@ static void xfrm4_dst_destroy(struct dst_entry *dst)
 {
 	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
 
+	dst_destroy_metrics_generic(dst);
+
 	if (likely(xdst->u.rt.peer))
 		inet_putpeer(xdst->u.rt.peer);
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
index 1534508..45fafa0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -105,6 +105,7 @@ static struct dst_ops ip6_dst_ops_template = {
 	.check			=	ip6_dst_check,
 	.default_advmss		=	ip6_default_advmss,
 	.default_mtu		=	ip6_default_mtu,
+	.cow_metrics		=	dst_cow_metrics_generic,
 	.destroy		=	ip6_dst_destroy,
 	.ifdown			=	ip6_dst_ifdown,
 	.negative_advice	=	ip6_negative_advice,
@@ -125,6 +126,10 @@ static struct dst_ops ip6_dst_blackhole_ops = {
 	.update_pmtu		=	ip6_rt_blackhole_update_pmtu,
 };
 
+static const u32 ip6_template_metrics[RTAX_MAX] = {
+	[RTAX_HOPLIMIT - 1] = 255,
+};
+
 static struct rt6_info ip6_null_entry_template = {
 	.dst = {
 		.__refcnt	= ATOMIC_INIT(1),
@@ -193,6 +198,7 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 		rt->rt6i_idev = NULL;
 		in6_dev_put(idev);
 	}
+	dst_destroy_metrics_generic(dst);
 	if (peer) {
 		BUG_ON(!(rt->rt6i_flags & RTF_CACHE));
 		rt->rt6i_peer = NULL;
@@ -2681,7 +2687,8 @@ static int __net_init ip6_route_net_init(struct net *net)
 	net->ipv6.ip6_null_entry->dst.path =
 		(struct dst_entry *)net->ipv6.ip6_null_entry;
 	net->ipv6.ip6_null_entry->dst.ops = &net->ipv6.ip6_dst_ops;
-	dst_metric_set(&net->ipv6.ip6_null_entry->dst, RTAX_HOPLIMIT, 255);
+	dst_init_metrics(&net->ipv6.ip6_null_entry->dst,
+			 ip6_template_metrics, true);
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	net->ipv6.ip6_prohibit_entry = kmemdup(&ip6_prohibit_entry_template,
@@ -2692,7 +2699,8 @@ static int __net_init ip6_route_net_init(struct net *net)
 	net->ipv6.ip6_prohibit_entry->dst.path =
 		(struct dst_entry *)net->ipv6.ip6_prohibit_entry;
 	net->ipv6.ip6_prohibit_entry->dst.ops = &net->ipv6.ip6_dst_ops;
-	dst_metric_set(&net->ipv6.ip6_prohibit_entry->dst, RTAX_HOPLIMIT, 255);
+	dst_init_metrics(&net->ipv6.ip6_prohibit_entry->dst,
+			 ip6_template_metrics, true);
 
 	net->ipv6.ip6_blk_hole_entry = kmemdup(&ip6_blk_hole_entry_template,
 					       sizeof(*net->ipv6.ip6_blk_hole_entry),
@@ -2702,7 +2710,8 @@ static int __net_init ip6_route_net_init(struct net *net)
 	net->ipv6.ip6_blk_hole_entry->dst.path =
 		(struct dst_entry *)net->ipv6.ip6_blk_hole_entry;
 	net->ipv6.ip6_blk_hole_entry->dst.ops = &net->ipv6.ip6_dst_ops;
-	dst_metric_set(&net->ipv6.ip6_blk_hole_entry->dst, RTAX_HOPLIMIT, 255);
+	dst_init_metrics(&net->ipv6.ip6_blk_hole_entry->dst,
+			 ip6_template_metrics, true);
 #endif
 
 	net->ipv6.sysctl.flush_delay = 0;
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index da87428..834dc02 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -220,6 +220,7 @@ static void xfrm6_dst_destroy(struct dst_entry *dst)
 
 	if (likely(xdst->u.rt6.rt6i_idev))
 		in6_dev_put(xdst->u.rt6.rt6i_idev);
+	dst_destroy_metrics_generic(dst);
 	if (likely(xdst->u.rt6.rt6i_peer))
 		inet_putpeer(xdst->u.rt6.rt6i_peer);
 	xfrm_dst_destroy(xdst);
@@ -257,6 +258,7 @@ static struct dst_ops xfrm6_dst_ops = {
 	.protocol =		cpu_to_be16(ETH_P_IPV6),
 	.gc =			xfrm6_garbage_collect,
 	.update_pmtu =		xfrm6_update_pmtu,
+	.cow_metrics =		dst_cow_metrics_generic,
 	.destroy =		xfrm6_dst_destroy,
 	.ifdown =		xfrm6_dst_ifdown,
 	.local_out =		__ip6_local_out,
