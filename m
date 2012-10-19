From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 2/6] net: Document dst->obsolete better.
Date: Fri, 19 Oct 2012 15:21:21 -0400
Message-ID: <20121019192121.GB8315@kvack.org>
References: <20121019191347.GD13515@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:43173 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757252Ab2JSTVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 15:21:22 -0400
Content-Disposition: inline
In-Reply-To: <20121019191347.GD13515@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f5b0a8743601a4477419171f5046bd07d1c080a0
Author: David S. Miller <davem@davemloft.net>
Date:   Thu Jul 19 12:31:33 2012 -0700

    net: Document dst->obsolete better.

    Add a big comment explaining how the field works, and use defines
    instead of magic constants for the values assigned to it.

    Suggested by Joe Perches.

    Signed-off-by: David S. Miller <davem@davemloft.net>

This is a slightly modified backport of the above commit to cover additional
locationsi of dst.u.obsolete = -1.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 include/net/dst.h      |   14 +++++++++++++-
 net/core/dst.c         |    4 ++--
 net/ipv4/route.c       |   12 ++++++------
 net/sctp/output.c      |    2 +-
 net/xfrm/xfrm_policy.c |   21 +++++++++++----------
 5 files changed, 33 insertions(+), 20 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 5a900dd..938b525 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -42,7 +42,19 @@ struct dst_entry
 	struct dst_entry	*child;
 	struct net_device       *dev;
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
 	int			flags;
 #define DST_HOST		1
 #define DST_NOXFRM		2
@@ -200,7 +212,7 @@ extern struct dst_entry *dst_destroy(struct dst_entry * dst);
 
 static inline void dst_free(struct dst_entry * dst)
 {
-	if (dst->obsolete > 1)
+	if (dst->obsolete > 0)
 		return;
 	if (!atomic_read(&dst->__refcnt)) {
 		dst = dst_destroy(dst);
diff --git a/net/core/dst.c b/net/core/dst.c
index cb1b348..5eb9929 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -99,7 +99,7 @@ loop:
 			 * But we do not have state "obsoleted, but
 			 * referenced by parent", so it is right.
 			 */
-			if (dst->obsolete > 1)
+			if (dst->obsolete > 0)
 				continue;
 
 			___dst_free(dst);
@@ -193,7 +193,7 @@ static void ___dst_free(struct dst_entry * dst)
 	if (dst->dev == NULL || !(dst->dev->flags&IFF_UP)) {
 		dst->input = dst->output = dst_discard;
 	}
-	dst->obsolete = 2;
+	dst->obsolete = DST_OBSOLETE_DEAD;
 }
 
 void __dst_free(struct dst_entry * dst)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f16d19b..f79a9a8 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1412,7 +1412,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 					dev_hold(rt->u.dst.dev);
 				if (rt->idev)
 					in_dev_hold(rt->idev);
-				rt->u.dst.obsolete	= -1;
+				rt->u.dst.obsolete	= DST_OBSOLETE_FORCE_CHK;
 				rt->u.dst.lastuse	= jiffies;
 				rt->u.dst.path		= &rt->u.dst;
 				rt->u.dst.neighbour	= NULL;
@@ -1865,7 +1865,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		goto e_nobufs;
 
 	rth->u.dst.output = ip_rt_bug;
-	rth->u.dst.obsolete = -1;
+	rth->u.dst.obsolete = DST_OBSOLETE_FORCE_CHK;
 
 	atomic_set(&rth->u.dst.__refcnt, 1);
 	rth->u.dst.flags= DST_HOST;
@@ -2026,7 +2026,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->fl.oif 	= 0;
 	rth->rt_spec_dst= spec_dst;
 
-	rth->u.dst.obsolete = -1;
+	rth->u.dst.obsolete = DST_OBSOLETE_FORCE_CHK;
 	rth->u.dst.input = ip_forward;
 	rth->u.dst.output = ip_output;
 	rth->rt_genid = rt_genid(dev_net(rth->u.dst.dev));
@@ -2191,7 +2191,7 @@ local_input:
 		goto e_nobufs;
 
 	rth->u.dst.output= ip_rt_bug;
-	rth->u.dst.obsolete = -1;
+	rth->u.dst.obsolete = DST_OBSOLETE_FORCE_CHK;
 	rth->rt_genid = rt_genid(net);
 
 	atomic_set(&rth->u.dst.__refcnt, 1);
@@ -2417,7 +2417,7 @@ static int __mkroute_output(struct rtable **result,
 	rth->rt_spec_dst= fl->fl4_src;
 
 	rth->u.dst.output = ip_output;
-	rth->u.dst.obsolete = -1;
+	rth->u.dst.obsolete = DST_OBSOLETE_FORCE_CHK;
 	rth->rt_genid = rt_genid(dev_net(dev_out));
 
 	RT_CACHE_STAT_INC(out_slow_tot);
@@ -2747,7 +2747,7 @@ static int ipv4_dst_blackhole(struct net *net, struct rtable **rp, struct flowi
 	if (rt) {
 		struct dst_entry *new = &rt->u.dst;
 
-		new->obsolete = -1;
+		new->obsolete = DST_OBSOLETE_FORCE_CHK;
 		atomic_set(&new->__refcnt, 1);
 		new->__use = 1;
 		new->input = dst_discard;
diff --git a/net/sctp/output.c b/net/sctp/output.c
index d494100..a6fc861 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -375,7 +375,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	skb_set_owner_w(nskb, sk);
 
 	/* The 'obsolete' field of dst is set to 2 when a dst is freed. */
-	if (!dst || (dst->obsolete > 1)) {
+	if (!dst || dst->obsolete) {
 		dst_release(dst);
 		sctp_transport_route(tp, NULL, sctp_sk(sk));
 		if (asoc && (asoc->param_flags & SPP_PMTUD_ENABLE)) {
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index cb81ca3..1ae61bd 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1421,7 +1421,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		dst1->xfrm = xfrm[i];
 		xdst->genid = xfrm[i]->genid;
 
-		dst1->obsolete = -1;
+		dst1->obsolete = DST_OBSOLETE_FORCE_CHK;
 		dst1->flags |= DST_HOST;
 		dst1->lastuse = now;
 
@@ -2049,12 +2049,13 @@ EXPORT_SYMBOL(__xfrm_route_forward);
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
@@ -2064,9 +2065,9 @@ static struct dst_entry *xfrm_dst_check(struct dst_entry *dst, u32 cookie)
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
1.7.1


-- 
"Thought is the essence of where you are now."
