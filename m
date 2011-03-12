From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/25] xfrm: Eliminate "fl" and "pol" args to
 xfrm_bundle_ok().
Date: Sat, 12 Mar 2011 15:25:31 -0800 (PST)
Message-ID: <20110312.152531.39181803.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37563
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755926Ab1CLXYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:24:54 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 17B3724C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:25:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There is only one caller of xfrm_bundle_ok(), and that always passes these
parameters as NULL.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |   22 +++-------------------
 1 files changed, 3 insertions(+), 19 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b1932a6..9e4aacd 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -50,8 +50,7 @@ static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family);
 static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo);
 static void xfrm_init_pmtu(struct dst_entry *dst);
 static int stale_bundle(struct dst_entry *dst);
-static int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *xdst,
-			  const struct flowi *fl, int family);
+static int xfrm_bundle_ok(struct xfrm_dst *xdst, int family);
 
 
 static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
@@ -2223,7 +2222,7 @@ static struct dst_entry *xfrm_dst_check(struct dst_entry *dst, u32 cookie)
 
 static int stale_bundle(struct dst_entry *dst)
 {
-	return !xfrm_bundle_ok(NULL, (struct xfrm_dst *)dst, NULL, AF_UNSPEC);
+	return !xfrm_bundle_ok((struct xfrm_dst *)dst, AF_UNSPEC);
 }
 
 void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *dev)
@@ -2295,8 +2294,7 @@ static void xfrm_init_pmtu(struct dst_entry *dst)
  * still valid.
  */
 
-static int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *first,
-			  const struct flowi *fl, int family)
+static int xfrm_bundle_ok(struct xfrm_dst *first, int family)
 {
 	struct dst_entry *dst = &first->u.dst;
 	struct xfrm_dst *last;
@@ -2305,26 +2303,12 @@ static int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *first,
 	if (!dst_check(dst->path, ((struct xfrm_dst *)dst)->path_cookie) ||
 	    (dst->dev && !netif_running(dst->dev)))
 		return 0;
-#ifdef CONFIG_XFRM_SUB_POLICY
-	if (fl) {
-		if (first->origin && !flow_cache_uli_match(first->origin, fl))
-			return 0;
-		if (first->partner &&
-		    !xfrm_selector_match(first->partner, fl, family))
-			return 0;
-	}
-#endif
 
 	last = NULL;
 
 	do {
 		struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
 
-		if (fl && !xfrm_selector_match(&dst->xfrm->sel, fl, family))
-			return 0;
-		if (fl && pol &&
-		    !security_xfrm_state_pol_flow_match(dst->xfrm, pol, fl))
-			return 0;
 		if (dst->xfrm->km.state != XFRM_STATE_VALID)
 			return 0;
 		if (xdst->xfrm_genid != dst->xfrm->genid)
-- 
1.7.4.1

