From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH] ipv6: don't use inetpeer to store metrics for routes.
Date: Tue, 06 Sep 2011 15:34:30 +0800
Message-ID: <4E65CD06.2080903@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:24378 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753218Ab1IFHeb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Sep 2011 03:34:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current IPv6 implementation uses inetpeer to store metrics for
routes. The problem of inetpeer is that it doesn't take subnet
prefix length in to consideration. If two routes have the same
address but different prefix length, they share same inetpeer.
So changing metrics of one route also affects the other. The
fix is to allocate separate metrics storage for each route.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
---
 net/ipv6/route.c |   33 ++++++++++++++++++++++-----------
 1 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 9e69eb0..1250f90 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -104,6 +104,9 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 	struct inet_peer *peer;
 	u32 *p = NULL;
 
+	if (!(rt->dst.flags & DST_HOST))
+		return NULL;
+
 	if (!rt->rt6i_peer)
 		rt6_bind_peer(rt, 1);
 
@@ -252,6 +255,9 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 	struct inet6_dev *idev = rt->rt6i_idev;
 	struct inet_peer *peer = rt->rt6i_peer;
 
+	if (!(rt->dst.flags & DST_HOST))
+		dst_destroy_metrics_generic(dst);
+
 	if (idev != NULL) {
 		rt->rt6i_idev = NULL;
 		in6_dev_put(idev);
@@ -723,9 +729,7 @@ static struct rt6_info *rt6_alloc_cow(const struct rt6_info *ort,
 			ipv6_addr_copy(&rt->rt6i_gateway, daddr);
 		}
 
-		rt->rt6i_dst.plen = 128;
 		rt->rt6i_flags |= RTF_CACHE;
-		rt->dst.flags |= DST_HOST;
 
 #ifdef CONFIG_IPV6_SUBTREES
 		if (rt->rt6i_src.plen && saddr) {
@@ -775,9 +779,7 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort,
 	struct rt6_info *rt = ip6_rt_copy(ort, daddr);
 
 	if (rt) {
-		rt->rt6i_dst.plen = 128;
 		rt->rt6i_flags |= RTF_CACHE;
-		rt->dst.flags |= DST_HOST;
 		dst_set_neighbour(&rt->dst, neigh_clone(dst_get_neighbour_raw(&ort->dst)));
 	}
 	return rt;
@@ -1078,12 +1080,15 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 			neigh = NULL;
 	}
 
-	rt->rt6i_idev     = idev;
+	rt->dst.flags |= DST_HOST;
+	rt->dst.output  = ip6_output;
 	dst_set_neighbour(&rt->dst, neigh);
 	atomic_set(&rt->dst.__refcnt, 1);
-	ipv6_addr_copy(&rt->rt6i_dst.addr, addr);
 	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 255);
-	rt->dst.output  = ip6_output;
+
+	ipv6_addr_copy(&rt->rt6i_dst.addr, addr);
+	rt->rt6i_dst.plen = 128;
+	rt->rt6i_idev     = idev;
 
 	spin_lock_bh(&icmp6_dst_lock);
 	rt->dst.next = icmp6_dst_gc_list;
@@ -1261,6 +1266,14 @@ int ip6_route_add(struct fib6_config *cfg)
 	if (rt->rt6i_dst.plen == 128)
 	       rt->dst.flags |= DST_HOST;
 
+	if (!(rt->dst.flags & DST_HOST) && cfg->fc_mx) {
+		u32 *metrics = kzalloc(sizeof(u32) * RTAX_MAX, GFP_KERNEL);
+		if (!metrics) {
+			err = -ENOMEM;
+			goto out;
+		}
+		dst_init_metrics(&rt->dst, metrics, 0);
+	}
 #ifdef CONFIG_IPV6_SUBTREES
 	ipv6_addr_prefix(&rt->rt6i_src.addr, &cfg->fc_src, cfg->fc_src_len);
 	rt->rt6i_src.plen = cfg->fc_src_len;
@@ -1607,9 +1620,6 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 	if (on_link)
 		nrt->rt6i_flags &= ~RTF_GATEWAY;
 
-	nrt->rt6i_dst.plen = 128;
-	nrt->dst.flags |= DST_HOST;
-
 	ipv6_addr_copy(&nrt->rt6i_gateway, (struct in6_addr*)neigh->primary_key);
 	dst_set_neighbour(&nrt->dst, neigh_clone(neigh));
 
@@ -1754,9 +1764,10 @@ static struct rt6_info *ip6_rt_copy(const struct rt6_info *ort,
 	if (rt) {
 		rt->dst.input = ort->dst.input;
 		rt->dst.output = ort->dst.output;
+		rt->dst.flags |= DST_HOST;
 
 		ipv6_addr_copy(&rt->rt6i_dst.addr, dest);
-		rt->rt6i_dst.plen = ort->rt6i_dst.plen;
+		rt->rt6i_dst.plen = 128;
 		dst_copy_metrics(&rt->dst, &ort->dst);
 		rt->dst.error = ort->dst.error;
 		rt->rt6i_idev = ort->rt6i_idev;
-- 
1.7.4.4
