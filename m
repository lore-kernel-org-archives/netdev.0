From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/4] net: Unlink the inetpeer metrics from dst_entry
Date: Thu, 2 Feb 2012 11:12:56 +0100
Message-ID: <20120202101255.GE23142@secunet.com>
References: <20120202101141.GC23142@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48760 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754095Ab2BBKNM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Feb 2012 05:13:12 -0500
Content-Disposition: inline
In-Reply-To: <20120202101141.GC23142@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to be able to exchange the inetpeer metrics,
we remove the direct reference from the dst_entry. We
access them via a new dst_ops method 'metrics' and the
inet_peer pointer of the routes.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/dst.h         |   20 +++++++++++++-------
 include/net/dst_ops.h     |    1 +
 net/bridge/br_netfilter.c |    6 ++++++
 net/decnet/dn_route.c     |    1 +
 net/ipv4/route.c          |   32 +++++++++++++++++---------------
 net/ipv4/xfrm4_policy.c   |    1 +
 net/ipv6/route.c          |   27 +++++++++++++++++----------
 net/ipv6/xfrm6_policy.c   |    1 +
 8 files changed, 57 insertions(+), 32 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 344c8dd..be1ffc8 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -124,6 +124,17 @@ static inline void dst_destroy_metrics_generic(struct dst_entry *dst)
 		__dst_destroy_metrics_generic(dst, val);
 }
 
+static inline u32 *dst_metrics_ptr(const struct dst_entry *dst)
+{
+	return dst->ops->metrics(dst);
+}
+
+static inline u32 *dst_metrics_ptr_default(const struct dst_entry *dst)
+{
+	return DST_METRICS_PTR(dst);
+
+}
+
 static inline u32 *dst_metrics_write_ptr(struct dst_entry *dst)
 {
 	unsigned long p = dst->_metrics;
@@ -151,21 +162,16 @@ static inline void dst_copy_metrics(struct dst_entry *dest, const struct dst_ent
 	u32 *dst_metrics = dst_metrics_write_ptr(dest);
 
 	if (dst_metrics) {
-		u32 *src_metrics = DST_METRICS_PTR(src);
+		u32 *src_metrics = dst_metrics_ptr(src);
 
 		memcpy(dst_metrics, src_metrics, RTAX_MAX * sizeof(u32));
 	}
 }
 
-static inline u32 *dst_metrics_ptr(struct dst_entry *dst)
-{
-	return DST_METRICS_PTR(dst);
-}
-
 static inline u32
 dst_metric_raw(const struct dst_entry *dst, const int metric)
 {
-	u32 *p = DST_METRICS_PTR(dst);
+	u32 *p = dst_metrics_ptr(dst);
 
 	return p[metric-1];
 }
diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index e1c2ee0..2c7849b 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -19,6 +19,7 @@ struct dst_ops {
 	unsigned int		(*default_advmss)(const struct dst_entry *);
 	unsigned int		(*mtu)(const struct dst_entry *);
 	u32 *			(*cow_metrics)(struct dst_entry *, unsigned long);
+	u32 *			(*metrics)(const struct dst_entry *);
 	void			(*destroy)(struct dst_entry *);
 	void			(*ifdown)(struct dst_entry *,
 					  struct net_device *dev, int how);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 8412247..74ba4bc 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -109,6 +109,11 @@ static u32 *fake_cow_metrics(struct dst_entry *dst, unsigned long old)
 	return NULL;
 }
 
+static u32 *fake_metrics(const struct dst_entry *dst)
+{
+	return NULL;
+}
+
 static struct neighbour *fake_neigh_lookup(const struct dst_entry *dst, const void *daddr)
 {
 	return NULL;
@@ -124,6 +129,7 @@ static struct dst_ops fake_dst_ops = {
 	.protocol =		cpu_to_be16(ETH_P_IP),
 	.update_pmtu =		fake_update_pmtu,
 	.cow_metrics =		fake_cow_metrics,
+	.metrics =		fake_metrics,
 	.neigh_lookup =		fake_neigh_lookup,
 	.mtu =			fake_mtu,
 };
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index f31ce72..d2e56b0 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -137,6 +137,7 @@ static struct dst_ops dn_dst_ops = {
 	.default_advmss =	dn_dst_default_advmss,
 	.mtu =			dn_dst_mtu,
 	.cow_metrics =		dst_cow_metrics_generic,
+	.metrics =		dst_metrics_ptr_default,
 	.destroy =		dn_dst_destroy,
 	.negative_advice =	dn_dst_negative_advice,
 	.link_failure =		dn_dst_link_failure,
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5099d35..dc22d6f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -155,6 +155,16 @@ static void ipv4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 {
 }
 
+static u32 *ipv4_metrics(const struct dst_entry *dst)
+{
+	const struct rtable *rt = (const struct rtable *) dst;
+
+	if (rt->peer && !inet_metrics_new(rt->peer))
+		return inetpeer_metrics(rt->peer);
+
+	return DST_METRICS_PTR(dst);
+}
+
 static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long old)
 {
 	struct rtable *rt = (struct rtable *) dst;
@@ -167,25 +177,10 @@ static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long old)
 	peer = rt->peer;
 	if (peer) {
 		u32 *old_p = __DST_METRICS_PTR(old);
-		unsigned long prev, new;
 
 		p = inetpeer_metrics(peer);
 		if (inet_metrics_new(peer))
 			memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
-
-		new = (unsigned long) p;
-		prev = cmpxchg(&dst->_metrics, old, new);
-
-		if (prev != old) {
-			p = __DST_METRICS_PTR(prev);
-			if (prev & DST_METRICS_READ_ONLY)
-				p = NULL;
-		} else {
-			if (rt->fi) {
-				fib_info_put(rt->fi);
-				rt->fi = NULL;
-			}
-		}
 	}
 	return p;
 }
@@ -200,6 +195,7 @@ static struct dst_ops ipv4_dst_ops = {
 	.default_advmss =	ipv4_default_advmss,
 	.mtu =			ipv4_mtu,
 	.cow_metrics =		ipv4_cow_metrics,
+	.metrics =		ipv4_metrics,
 	.destroy =		ipv4_dst_destroy,
 	.ifdown =		ipv4_dst_ifdown,
 	.negative_advice =	ipv4_negative_advice,
@@ -2883,6 +2879,11 @@ static u32 *ipv4_rt_blackhole_cow_metrics(struct dst_entry *dst,
 	return NULL;
 }
 
+static u32 *ipv4_rt_blackhole_metrics(const struct dst_entry *dst)
+{
+	return NULL;
+}
+
 static struct dst_ops ipv4_dst_blackhole_ops = {
 	.family			=	AF_INET,
 	.protocol		=	cpu_to_be16(ETH_P_IP),
@@ -2892,6 +2893,7 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
 	.default_advmss		=	ipv4_default_advmss,
 	.update_pmtu		=	ipv4_rt_blackhole_update_pmtu,
 	.cow_metrics		=	ipv4_rt_blackhole_cow_metrics,
+	.metrics		=	ipv4_rt_blackhole_metrics,
 	.neigh_lookup		=	ipv4_neigh_lookup,
 };
 
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index a0b4c5d..7a6ebfe 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -233,6 +233,7 @@ static struct dst_ops xfrm4_dst_ops = {
 	.gc =			xfrm4_garbage_collect,
 	.update_pmtu =		xfrm4_update_pmtu,
 	.cow_metrics =		dst_cow_metrics_generic,
+	.metrics =		dst_metrics_ptr_default,
 	.destroy =		xfrm4_dst_destroy,
 	.ifdown =		xfrm4_dst_ifdown,
 	.local_out =		__ip_local_out,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ea13565..d8b01c0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -88,6 +88,16 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 					   const struct in6_addr *gwaddr, int ifindex);
 #endif
 
+static u32 *ipv6_metrics(const struct dst_entry *dst)
+{
+	const struct rt6_info *rt = (const struct rt6_info *) dst;
+
+	if (rt->rt6i_peer && !inet_metrics_new(rt->rt6i_peer))
+		return inetpeer_metrics(rt->rt6i_peer);
+
+	return DST_METRICS_PTR(dst);
+}
+
 static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 {
 	struct rt6_info *rt = (struct rt6_info *) dst;
@@ -103,20 +113,10 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 	peer = rt->rt6i_peer;
 	if (peer) {
 		u32 *old_p = __DST_METRICS_PTR(old);
-		unsigned long prev, new;
 
 		p = inetpeer_metrics(peer);
 		if (inet_metrics_new(peer))
 			memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
-
-		new = (unsigned long) p;
-		prev = cmpxchg(&dst->_metrics, old, new);
-
-		if (prev != old) {
-			p = __DST_METRICS_PTR(prev);
-			if (prev & DST_METRICS_READ_ONLY)
-				p = NULL;
-		}
 	}
 	return p;
 }
@@ -151,6 +151,7 @@ static struct dst_ops ip6_dst_ops_template = {
 	.default_advmss		=	ip6_default_advmss,
 	.mtu			=	ip6_mtu,
 	.cow_metrics		=	ipv6_cow_metrics,
+	.metrics		=	ipv6_metrics,
 	.destroy		=	ip6_dst_destroy,
 	.ifdown			=	ip6_dst_ifdown,
 	.negative_advice	=	ip6_negative_advice,
@@ -177,6 +178,11 @@ static u32 *ip6_rt_blackhole_cow_metrics(struct dst_entry *dst,
 	return NULL;
 }
 
+static u32 *ip6_rt_blackhole_metrics(const struct dst_entry *dst)
+{
+	return NULL;
+}
+
 static struct dst_ops ip6_dst_blackhole_ops = {
 	.family			=	AF_INET6,
 	.protocol		=	cpu_to_be16(ETH_P_IPV6),
@@ -186,6 +192,7 @@ static struct dst_ops ip6_dst_blackhole_ops = {
 	.default_advmss		=	ip6_default_advmss,
 	.update_pmtu		=	ip6_rt_blackhole_update_pmtu,
 	.cow_metrics		=	ip6_rt_blackhole_cow_metrics,
+	.metrics		=	ip6_rt_blackhole_metrics,
 	.neigh_lookup		=	ip6_neigh_lookup,
 };
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 8ea65e0..af4854c 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -261,6 +261,7 @@ static struct dst_ops xfrm6_dst_ops = {
 	.gc =			xfrm6_garbage_collect,
 	.update_pmtu =		xfrm6_update_pmtu,
 	.cow_metrics =		dst_cow_metrics_generic,
+	.metrics =		dst_metrics_ptr_default,
 	.destroy =		xfrm6_dst_destroy,
 	.ifdown =		xfrm6_dst_ifdown,
 	.local_out =		__ip6_local_out,
-- 
1.7.0.4
