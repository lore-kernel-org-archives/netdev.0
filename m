From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/3] net: Store ipv4/ipv6 COW'd metrics in inetpeer cache.
Date: Thu, 27 Jan 2011 15:01:54 -0800 (PST)
Message-ID: <20110127.150154.232744192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36922
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753802Ab1A0XBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 18:01:19 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 489C324C089
	for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 15:01:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please note that the IPSEC dst entry metrics keep using
the generic metrics COW'ing mechanism using kmalloc/kfree.

This gives the IPSEC routes an opportunity to use metrics
which are unique to their encapsulated paths.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   18 +++++++++++-------
 net/ipv6/route.c |   33 +++++++++++++++++++++++++++++++--
 2 files changed, 42 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 980030d4..68cee35 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -154,25 +154,30 @@ static void ipv4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 
 static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long old)
 {
-	u32 *p = kmalloc(sizeof(u32) * RTAX_MAX, GFP_ATOMIC);
+	struct rtable *rt = (struct rtable *) dst;
+	struct inet_peer *peer;
+	u32 *p = NULL;
+
+	if (!rt->peer)
+		rt_bind_peer(rt, 1);
 
-	if (p) {
+	peer = rt->peer;
+	if (peer) {
 		u32 *old_p = __DST_METRICS_PTR(old);
 		unsigned long prev, new;
 
-		memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
+		p = peer->metrics;
+		if (inet_metrics_new(peer))
+			memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
 
 		new = (unsigned long) p;
 		prev = cmpxchg(&dst->_metrics, old, new);
 
 		if (prev != old) {
-			kfree(p);
 			p = __DST_METRICS_PTR(prev);
 			if (prev & DST_METRICS_READ_ONLY)
 				p = NULL;
 		} else {
-			struct rtable *rt = (struct rtable *) dst;
-
 			if (rt->fi) {
 				fib_info_put(rt->fi);
 				rt->fi = NULL;
@@ -1753,7 +1758,6 @@ static void ipv4_dst_destroy(struct dst_entry *dst)
 	struct rtable *rt = (struct rtable *) dst;
 	struct inet_peer *peer = rt->peer;
 
-	dst_destroy_metrics_generic(dst);
 	if (rt->fi) {
 		fib_info_put(rt->fi);
 		rt->fi = NULL;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 691798c..72609f1 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -97,6 +97,36 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 					   struct in6_addr *gwaddr, int ifindex);
 #endif
 
+static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
+{
+	struct rt6_info *rt = (struct rt6_info *) dst;
+	struct inet_peer *peer;
+	u32 *p = NULL;
+
+	if (!rt->rt6i_peer)
+		rt6_bind_peer(rt, 1);
+
+	peer = rt->rt6i_peer;
+	if (peer) {
+		u32 *old_p = __DST_METRICS_PTR(old);
+		unsigned long prev, new;
+
+		p = peer->metrics;
+		if (inet_metrics_new(peer))
+			memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
+
+		new = (unsigned long) p;
+		prev = cmpxchg(&dst->_metrics, old, new);
+
+		if (prev != old) {
+			p = __DST_METRICS_PTR(prev);
+			if (prev & DST_METRICS_READ_ONLY)
+				p = NULL;
+		}
+	}
+	return p;
+}
+
 static struct dst_ops ip6_dst_ops_template = {
 	.family			=	AF_INET6,
 	.protocol		=	cpu_to_be16(ETH_P_IPV6),
@@ -105,7 +135,7 @@ static struct dst_ops ip6_dst_ops_template = {
 	.check			=	ip6_dst_check,
 	.default_advmss		=	ip6_default_advmss,
 	.default_mtu		=	ip6_default_mtu,
-	.cow_metrics		=	dst_cow_metrics_generic,
+	.cow_metrics		=	ipv6_cow_metrics,
 	.destroy		=	ip6_dst_destroy,
 	.ifdown			=	ip6_dst_ifdown,
 	.negative_advice	=	ip6_negative_advice,
@@ -198,7 +228,6 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 		rt->rt6i_idev = NULL;
 		in6_dev_put(idev);
 	}
-	dst_destroy_metrics_generic(dst);
 	if (peer) {
 		rt->rt6i_peer = NULL;
 		inet_putpeer(peer);
-- 
1.7.3.4

