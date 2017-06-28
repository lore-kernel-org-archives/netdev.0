From: Florian Westphal <fw@strlen.de>
Subject: [RFC net-next 4/9] xfrm_policy: remove always true/false branches
Date: Wed, 28 Jun 2017 15:26:47 +0200
Message-ID: <20170628132652.1275-5-fw@strlen.de>
References: <20170628132652.1275-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:34216 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751754AbdF1N0v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 09:26:51 -0400
In-Reply-To: <20170628132652.1275-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

after previous change oldflo and xdst are always NULL.
These branches were already removed by gcc, this doesn't change code.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_policy.c | 74 ++++++++++----------------------------------------
 1 file changed, 14 insertions(+), 60 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 084736ff2681..64cef0e601b8 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2060,48 +2060,23 @@ xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 {
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
 	struct xfrm_dst *xdst, *new_xdst;
-	int num_pols = 0, num_xfrms = 0, i, err, pol_dead;
-	struct flow_cache_object *oldflo = NULL;
+	int num_pols = 0, num_xfrms = 0, err;
 
 	/* Check if the policies from old bundle are usable */
 	xdst = NULL;
-	if (oldflo) {
-		xdst = container_of(oldflo, struct xfrm_dst, flo);
-		num_pols = xdst->num_pols;
-		num_xfrms = xdst->num_xfrms;
-		pol_dead = 0;
-		for (i = 0; i < num_pols; i++) {
-			pols[i] = xdst->pols[i];
-			pol_dead |= pols[i]->walk.dead;
-		}
-		if (pol_dead) {
-			/* Mark DST_OBSOLETE_DEAD to fail the next
-			 * xfrm_dst_check()
-			 */
-			xdst->u.dst.obsolete = DST_OBSOLETE_DEAD;
-			dst_release_immediate(&xdst->u.dst);
-			xdst = NULL;
-			num_pols = 0;
-			num_xfrms = 0;
-			oldflo = NULL;
-		}
-	}
-
 	/* Resolve policies to use if we couldn't get them from
 	 * previous cache entry */
-	if (xdst == NULL) {
-		num_pols = 1;
-		pols[0] = __xfrm_policy_lookup(net, fl, family,
-					       flow_to_policy_dir(dir));
-		err = xfrm_expand_policies(fl, family, pols,
+	num_pols = 1;
+	pols[0] = __xfrm_policy_lookup(net, fl, family,
+				       flow_to_policy_dir(dir));
+	err = xfrm_expand_policies(fl, family, pols,
 					   &num_pols, &num_xfrms);
-		if (err < 0)
-			goto inc_error;
-		if (num_pols == 0)
-			return NULL;
-		if (num_xfrms <= 0)
-			goto make_dummy_bundle;
-	}
+	if (err < 0)
+		goto inc_error;
+	if (num_pols == 0)
+		return NULL;
+	if (num_xfrms <= 0)
+		goto make_dummy_bundle;
 
 	new_xdst = xfrm_resolve_and_create_bundle(pols, num_pols, fl, family,
 						  xflo->dst_orig);
@@ -2109,26 +2084,10 @@ xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 		err = PTR_ERR(new_xdst);
 		if (err != -EAGAIN)
 			goto error;
-		if (oldflo == NULL)
-			goto make_dummy_bundle;
-		dst_hold(&xdst->u.dst);
-		return oldflo;
+		goto make_dummy_bundle;
 	} else if (new_xdst == NULL) {
 		num_xfrms = 0;
-		if (oldflo == NULL)
-			goto make_dummy_bundle;
-		xdst->num_xfrms = 0;
-		dst_hold(&xdst->u.dst);
-		return oldflo;
-	}
-
-	/* Kill the previous bundle */
-	if (xdst) {
-		/* The policies were stolen for newly generated bundle */
-		xdst->num_pols = 0;
-		/* Mark DST_OBSOLETE_DEAD to fail the next xfrm_dst_check() */
-		xdst->u.dst.obsolete = DST_OBSOLETE_DEAD;
-		dst_release_immediate(&xdst->u.dst);
+		goto make_dummy_bundle;
 	}
 
 	return &new_xdst->flo;
@@ -2152,12 +2111,7 @@ xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 inc_error:
 	XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
 error:
-	if (xdst != NULL) {
-		/* Mark DST_OBSOLETE_DEAD to fail the next xfrm_dst_check() */
-		xdst->u.dst.obsolete = DST_OBSOLETE_DEAD;
-		dst_release_immediate(&xdst->u.dst);
-	} else
-		xfrm_pols_put(pols, num_pols);
+	xfrm_pols_put(pols, num_pols);
 	return ERR_PTR(err);
 }
 
-- 
2.13.0
