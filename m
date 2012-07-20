From: David Miller <davem@davemloft.net>
Subject: [PATCH 08/16] net: Document dst->obsolete better.
Date: Fri, 20 Jul 2012 14:25:59 -0700 (PDT)
Message-ID: <20120720.142559.1856240827162577674.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55688 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268Ab2GTV0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 17:26:00 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id C9C44583615
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 14:26:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add a big comment explaining how the field works, and use defines
instead of magic constants for the values assigned to it.

Suggested by Joe Perches.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h      |   14 +++++++++++++-
 net/core/dst.c         |    4 ++--
 net/decnet/dn_route.c  |    4 ++--
 net/ipv4/route.c       |    5 +++--
 net/ipv6/route.c       |    4 ++--
 net/sctp/transport.c   |    2 +-
 net/xfrm/xfrm_policy.c |   23 ++++++++++++-----------
 7 files changed, 35 insertions(+), 21 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 5161046..0df661a 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -65,7 +65,19 @@ struct dst_entry {
 	unsigned short		pending_confirm;
 
 	short			error;
+
+	/* A non-zero value of dst->obsolete forces by-hand validation
+	 * of the route entry.  Positive values are set by the generic
+	 * dst layer to indicate that the entry has been forcefully
+	 * destroyed.
+	 *
+	 * Negative values are used by the implementation layer code to
+	 * force invocation of the dst_ops->check() method.
+	 */
 	short			obsolete;
+#define DST_OBSOLETE_NONE	0
+#define DST_OBSOLETE_DEAD	2
+#define DST_OBSOLETE_FORCE_CHK	-1
 	unsigned short		header_len;	/* more space at head required */
 	unsigned short		trailer_len;	/* space to reserve at tail */
 #ifdef CONFIG_IP_ROUTE_CLASSID
@@ -359,7 +371,7 @@ extern struct dst_entry *dst_destroy(struct dst_entry *dst);
 
 static inline void dst_free(struct dst_entry *dst)
 {
-	if (dst->obsolete > 1)
+	if (dst->obsolete > 0)
 		return;
 	if (!atomic_read(&dst->__refcnt)) {
 		dst = dst_destroy(dst);
diff --git a/net/core/dst.c b/net/core/dst.c
index 07bacff..069d51d 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -94,7 +94,7 @@ loop:
 			 * But we do not have state "obsoleted, but
 			 * referenced by parent", so it is right.
 			 */
-			if (dst->obsolete > 1)
+			if (dst->obsolete > 0)
 				continue;
 
 			___dst_free(dst);
@@ -202,7 +202,7 @@ static void ___dst_free(struct dst_entry *dst)
 	 */
 	if (dst->dev == NULL || !(dst->dev->flags&IFF_UP))
 		dst->input = dst->output = dst_discard;
-	dst->obsolete = 2;
+	dst->obsolete = DST_OBSOLETE_DEAD;
 }
 
 void __dst_free(struct dst_entry *dst)
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 47de90d..23cc11d 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1176,7 +1176,7 @@ make_route:
 	if (dev_out->flags & IFF_LOOPBACK)
 		flags |= RTCF_LOCAL;
 
-	rt = dst_alloc(&dn_dst_ops, dev_out, 1, 0, DST_HOST);
+	rt = dst_alloc(&dn_dst_ops, dev_out, 1, DST_OBSOLETE_NONE, DST_HOST);
 	if (rt == NULL)
 		goto e_nobufs;
 
@@ -1444,7 +1444,7 @@ static int dn_route_input_slow(struct sk_buff *skb)
 	}
 
 make_route:
-	rt = dst_alloc(&dn_dst_ops, out_dev, 0, 0, DST_HOST);
+	rt = dst_alloc(&dn_dst_ops, out_dev, 0, DST_OBSOLETE_NONE, DST_HOST);
 	if (rt == NULL)
 		goto e_nobufs;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d1d5796..50d2498 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1221,7 +1221,7 @@ static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4,
 static struct rtable *rt_dst_alloc(struct net_device *dev,
 				   bool nopolicy, bool noxfrm)
 {
-	return dst_alloc(&ipv4_dst_ops, dev, 1, -1,
+	return dst_alloc(&ipv4_dst_ops, dev, 1, DST_OBSOLETE_FORCE_CHK,
 			 DST_HOST | DST_NOCACHE |
 			 (nopolicy ? DST_NOPOLICY : 0) |
 			 (noxfrm ? DST_NOXFRM : 0));
@@ -1969,9 +1969,10 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
 
 struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_orig)
 {
-	struct rtable *rt = dst_alloc(&ipv4_dst_blackhole_ops, NULL, 1, 0, 0);
 	struct rtable *ort = (struct rtable *) dst_orig;
+	struct rtable *rt;
 
+	rt = dst_alloc(&ipv4_dst_blackhole_ops, NULL, 1, DST_OBSOLETE_NONE, 0);
 	if (rt) {
 		struct dst_entry *new = &rt->dst;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 84f6564..cf02cb9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -281,7 +281,7 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 					     struct fib6_table *table)
 {
 	struct rt6_info *rt = dst_alloc(&net->ipv6.ip6_dst_ops, dev,
-					0, 0, flags);
+					0, DST_OBSOLETE_NONE, flags);
 
 	if (rt) {
 		struct dst_entry *dst = &rt->dst;
@@ -985,7 +985,7 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 	struct rt6_info *rt, *ort = (struct rt6_info *) dst_orig;
 	struct dst_entry *new = NULL;
 
-	rt = dst_alloc(&ip6_dst_blackhole_ops, ort->dst.dev, 1, 0, 0);
+	rt = dst_alloc(&ip6_dst_blackhole_ops, ort->dst.dev, 1, DST_OBSOLETE_NONE, 0);
 	if (rt) {
 		new = &rt->dst;
 
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index a6b7ee9..ec3a12b 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -216,7 +216,7 @@ void sctp_transport_set_owner(struct sctp_transport *transport,
 void sctp_transport_pmtu(struct sctp_transport *transport, struct sock *sk)
 {
 	/* If we don't have a fresh route, look one up */
-	if (!transport->dst || transport->dst->obsolete > 1) {
+	if (!transport->dst || transport->dst->obsolete) {
 		dst_release(transport->dst);
 		transport->af_specific->get_dst(transport, &transport->saddr,
 						&transport->fl, sk);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 65bd1ca5..c5a5165 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1350,7 +1350,7 @@ static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 	default:
 		BUG();
 	}
-	xdst = dst_alloc(dst_ops, NULL, 0, 0, 0);
+	xdst = dst_alloc(dst_ops, NULL, 0, DST_OBSOLETE_NONE, 0);
 
 	if (likely(xdst)) {
 		struct dst_entry *dst = &xdst->u.dst;
@@ -1477,7 +1477,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		dst1->xfrm = xfrm[i];
 		xdst->xfrm_genid = xfrm[i]->genid;
 
-		dst1->obsolete = -1;
+		dst1->obsolete = DST_OBSOLETE_FORCE_CHK;
 		dst1->flags |= DST_HOST;
 		dst1->lastuse = now;
 
@@ -2219,12 +2219,13 @@ EXPORT_SYMBOL(__xfrm_route_forward);
 static struct dst_entry *xfrm_dst_check(struct dst_entry *dst, u32 cookie)
 {
 	/* Code (such as __xfrm4_bundle_create()) sets dst->obsolete
-	 * to "-1" to force all XFRM destinations to get validated by
-	 * dst_ops->check on every use.  We do this because when a
-	 * normal route referenced by an XFRM dst is obsoleted we do
-	 * not go looking around for all parent referencing XFRM dsts
-	 * so that we can invalidate them.  It is just too much work.
-	 * Instead we make the checks here on every use.  For example:
+	 * to DST_OBSOLETE_FORCE_CHK to force all XFRM destinations to
+	 * get validated by dst_ops->check on every use.  We do this
+	 * because when a normal route referenced by an XFRM dst is
+	 * obsoleted we do not go looking around for all parent
+	 * referencing XFRM dsts so that we can invalidate them.  It
+	 * is just too much work.  Instead we make the checks here on
+	 * every use.  For example:
 	 *
 	 *	XFRM dst A --> IPv4 dst X
 	 *
@@ -2234,9 +2235,9 @@ static struct dst_entry *xfrm_dst_check(struct dst_entry *dst, u32 cookie)
 	 * stale_bundle() check.
 	 *
 	 * When a policy's bundle is pruned, we dst_free() the XFRM
-	 * dst which causes it's ->obsolete field to be set to a
-	 * positive non-zero integer.  If an XFRM dst has been pruned
-	 * like this, we want to force a new route lookup.
+	 * dst which causes it's ->obsolete field to be set to
+	 * DST_OBSOLETE_DEAD.  If an XFRM dst has been pruned like
+	 * this, we want to force a new route lookup.
 	 */
 	if (dst->obsolete < 0 && !stale_bundle(dst))
 		return dst;
-- 
1.7.10.4
