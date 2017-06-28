From: Florian Westphal <fw@strlen.de>
Subject: [RFC net-next 7/9] xfrm_policy: make xfrm_bundle_lookup return xfrm dst object
Date: Wed, 28 Jun 2017 15:26:50 +0200
Message-ID: <20170628132652.1275-8-fw@strlen.de>
References: <20170628132652.1275-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:34228 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751974AbdF1N1H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 09:27:07 -0400
In-Reply-To: <20170628132652.1275-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows to remove flow cache object embedded in struct xfrm_dst.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_policy.c | 28 ++++++++++++----------------
 1 file changed, 12 insertions(+), 16 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 86907731f161..5bb049d8e8d5 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2000,15 +2000,13 @@ static struct xfrm_dst *xfrm_create_dummy_bundle(struct net *net,
 	goto out;
 }
 
-static struct flow_cache_object *
+static struct xfrm_dst *
 xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir, struct xfrm_flo *xflo)
 {
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
-	struct xfrm_dst *xdst, *new_xdst;
 	int num_pols = 0, num_xfrms = 0, err;
+	struct xfrm_dst *xdst;
 
-	/* Check if the policies from old bundle are usable */
-	xdst = NULL;
 	/* Resolve policies to use if we couldn't get them from
 	 * previous cache entry */
 	num_pols = 1;
@@ -2022,19 +2020,19 @@ xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 	if (num_xfrms <= 0)
 		goto make_dummy_bundle;
 
-	new_xdst = xfrm_resolve_and_create_bundle(pols, num_pols, fl, family,
+	xdst = xfrm_resolve_and_create_bundle(pols, num_pols, fl, family,
 						  xflo->dst_orig);
-	if (IS_ERR(new_xdst)) {
-		err = PTR_ERR(new_xdst);
+	if (IS_ERR(xdst)) {
+		err = PTR_ERR(xdst);
 		if (err != -EAGAIN)
 			goto error;
 		goto make_dummy_bundle;
-	} else if (new_xdst == NULL) {
+	} else if (xdst == NULL) {
 		num_xfrms = 0;
 		goto make_dummy_bundle;
 	}
 
-	return &new_xdst->flo;
+	return xdst;
 
 make_dummy_bundle:
 	/* We found policies, but there's no bundles to instantiate:
@@ -2050,7 +2048,7 @@ xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 	memcpy(xdst->pols, pols, sizeof(struct xfrm_policy *) * num_pols);
 
 	dst_hold(&xdst->u.dst);
-	return &xdst->flo;
+	return xdst;
 
 inc_error:
 	XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
@@ -2086,7 +2084,6 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 			      const struct sock *sk, int flags)
 {
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
-	struct flow_cache_object *flo;
 	struct xfrm_dst *xdst;
 	struct dst_entry *dst, *route;
 	u16 family = dst_orig->ops->family;
@@ -2141,14 +2138,13 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 		    !net->xfrm.policy_count[XFRM_POLICY_OUT])
 			goto nopol;
 
-		flo = xfrm_bundle_lookup(net, fl, family, dir, &xflo);
-		if (flo == NULL)
+		xdst = xfrm_bundle_lookup(net, fl, family, dir, &xflo);
+		if (xdst == NULL)
 			goto nopol;
-		if (IS_ERR(flo)) {
-			err = PTR_ERR(flo);
+		if (IS_ERR(xdst)) {
+			err = PTR_ERR(xdst);
 			goto dropdst;
 		}
-		xdst = container_of(flo, struct xfrm_dst, flo);
 
 		num_pols = xdst->num_pols;
 		num_xfrms = xdst->num_xfrms;
-- 
2.13.0
