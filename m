From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 11/12] xfrm: Stop using dst->next in bundle
 construction.
Date: Wed, 25 Oct 2017 23:04:44 +0900 (KST)
Message-ID: <20171025.230444.1403000317273207793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48368 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932326AbdJYOEr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:04:47 -0400
Received: from localhost (unknown [106.252.28.196])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 2E326133F06AD
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:04:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While building ipsec bundles, blocks of xfrm dsts are linked together
using dst->next from bottom to the top.

The only thing this is used for is initializing the pmtu values of the
xfrm stack, and for updating the mtu values at xfrm_bundle_ok() time.

The bundle pmtu entries must be processed in this order so that pmtu
values lower in the stack of routes can propagate up to the higher
ones.

Avoid using dst->next by simply maintaining an array of dst pointers
as we already do for the xfrm_state objects when building the bundle.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c | 56 ++++++++++++++++++++++++++++----------------------
 1 file changed, 32 insertions(+), 24 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7b80ee7486db..b815884deb16 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -54,7 +54,7 @@ static struct xfrm_policy_afinfo const __rcu *xfrm_policy_afinfo[AF_INET6 + 1]
 static struct kmem_cache *xfrm_dst_cache __read_mostly;
 static __read_mostly seqcount_t xfrm_policy_hash_generation;
 
-static void xfrm_init_pmtu(struct dst_entry *dst);
+static void xfrm_init_pmtu(struct xfrm_dst **bundle, int nr);
 static int stale_bundle(struct dst_entry *dst);
 static int xfrm_bundle_ok(struct xfrm_dst *xdst);
 static void xfrm_policy_queue_process(struct timer_list *t);
@@ -1537,7 +1537,9 @@ static inline int xfrm_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
  */
 
 static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
-					    struct xfrm_state **xfrm, int nx,
+					    struct xfrm_state **xfrm,
+					    struct xfrm_dst **bundle,
+					    int nx,
 					    const struct flowi *fl,
 					    struct dst_entry *dst)
 {
@@ -1572,6 +1574,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 			goto put_states;
 		}
 
+		bundle[i] = xdst;
 		if (!xdst_prev)
 			xdst0 = xdst;
 		else
@@ -1615,7 +1618,6 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		dst1->input = dst_discard;
 		dst1->output = inner_mode->afinfo->output;
 
-		dst1->next = &xdst_prev->u.dst;
 		xdst_prev = xdst;
 
 		header_len += xfrm[i]->props.header_len;
@@ -1633,7 +1635,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		goto free_dst;
 
 	xfrm_init_path(xdst0, dst, nfheader_len);
-	xfrm_init_pmtu(&xdst_prev->u.dst);
+	xfrm_init_pmtu(bundle, nx);
 
 	for (xdst_prev = xdst0; xdst_prev != (struct xfrm_dst *)dst;
 	     xdst_prev = (struct xfrm_dst *) xfrm_dst_child(&xdst_prev->u.dst)) {
@@ -1807,6 +1809,7 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
 {
 	struct net *net = xp_net(pols[0]);
 	struct xfrm_state *xfrm[XFRM_MAX_DEPTH];
+	struct xfrm_dst *bundle[XFRM_MAX_DEPTH];
 	struct xfrm_dst *xdst, *old;
 	struct dst_entry *dst;
 	int err;
@@ -1832,7 +1835,7 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
 		return ERR_PTR(err);
 	}
 
-	dst = xfrm_bundle_create(pols[0], xfrm, err, fl, dst_orig);
+	dst = xfrm_bundle_create(pols[0], xfrm, bundle, err, fl, dst_orig);
 	if (IS_ERR(dst)) {
 		XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTBUNDLEGENERROR);
 		return ERR_CAST(dst);
@@ -2593,12 +2596,14 @@ static struct dst_entry *xfrm_negative_advice(struct dst_entry *dst)
 	return dst;
 }
 
-static void xfrm_init_pmtu(struct dst_entry *dst)
+static void xfrm_init_pmtu(struct xfrm_dst **bundle, int nr)
 {
-	do {
-		struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
+	while (nr--) {
+		struct xfrm_dst *xdst = bundle[nr];
 		u32 pmtu, route_mtu_cached;
+		struct dst_entry *dst;
 
+		dst = &xdst->u.dst;
 		pmtu = dst_mtu(xfrm_dst_child(dst));
 		xdst->child_mtu_cached = pmtu;
 
@@ -2611,7 +2616,7 @@ static void xfrm_init_pmtu(struct dst_entry *dst)
 			pmtu = route_mtu_cached;
 
 		dst_metric_set(dst, RTAX_MTU, pmtu);
-	} while ((dst = dst->next));
+	}
 }
 
 /* Check that the bundle accepts the flow and its components are
@@ -2620,8 +2625,10 @@ static void xfrm_init_pmtu(struct dst_entry *dst)
 
 static int xfrm_bundle_ok(struct xfrm_dst *first)
 {
+	struct xfrm_dst *bundle[XFRM_MAX_DEPTH];
 	struct dst_entry *dst = &first->u.dst;
-	struct xfrm_dst *last;
+	struct xfrm_dst *xdst;
+	int start_from, nr;
 	u32 mtu;
 
 	if (!dst_check(xfrm_dst_path(dst), ((struct xfrm_dst *)dst)->path_cookie) ||
@@ -2631,8 +2638,7 @@ static int xfrm_bundle_ok(struct xfrm_dst *first)
 	if (dst->flags & DST_XFRM_QUEUE)
 		return 1;
 
-	last = NULL;
-
+	start_from = nr = 0;
 	do {
 		struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
 
@@ -2644,9 +2650,11 @@ static int xfrm_bundle_ok(struct xfrm_dst *first)
 		    xdst->policy_genid != atomic_read(&xdst->pols[0]->genid))
 			return 0;
 
+		bundle[nr++] = xdst;
+
 		mtu = dst_mtu(xfrm_dst_child(dst));
 		if (xdst->child_mtu_cached != mtu) {
-			last = xdst;
+			start_from = nr;
 			xdst->child_mtu_cached = mtu;
 		}
 
@@ -2654,30 +2662,30 @@ static int xfrm_bundle_ok(struct xfrm_dst *first)
 			return 0;
 		mtu = dst_mtu(xdst->route);
 		if (xdst->route_mtu_cached != mtu) {
-			last = xdst;
+			start_from = nr;
 			xdst->route_mtu_cached = mtu;
 		}
 
 		dst = xfrm_dst_child(dst);
 	} while (dst->xfrm);
 
-	if (likely(!last))
+	if (likely(!start_from))
 		return 1;
 
-	mtu = last->child_mtu_cached;
-	for (;;) {
-		dst = &last->u.dst;
+	xdst = bundle[start_from - 1];
+	mtu = xdst->child_mtu_cached;
+	while (start_from--) {
+		dst = &xdst->u.dst;
 
 		mtu = xfrm_state_mtu(dst->xfrm, mtu);
-		if (mtu > last->route_mtu_cached)
-			mtu = last->route_mtu_cached;
+		if (mtu > xdst->route_mtu_cached)
+			mtu = xdst->route_mtu_cached;
 		dst_metric_set(dst, RTAX_MTU, mtu);
-
-		if (last == first)
+		if (!start_from)
 			break;
 
-		last = (struct xfrm_dst *)last->u.dst.next;
-		last->child_mtu_cached = mtu;
+		xdst = bundle[start_from - 1];
+		xdst->child_mtu_cached = mtu;
 	}
 
 	return 1;
-- 
2.13.6
