From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 07/10] xfrm_policy: remove xfrm_policy_lookup
Date: Mon, 17 Jul 2017 13:57:24 +0200
Message-ID: <20170717115727.26042-8-fw@strlen.de>
References: <20170717115727.26042-1-fw@strlen.de>
Cc: steffen.klassert@secunet.com, ilant@mellanox.com,
        Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43944 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751348AbdGQL5d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 07:57:33 -0400
In-Reply-To: <20170717115727.26042-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes the wrapper and renames the __xfrm_policy_lookup variant
to get rid of another place that used flow cache objects.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_policy.c | 36 ++++--------------------------------
 1 file changed, 4 insertions(+), 32 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 9f724a688475..339bb3ac2797 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1175,7 +1175,7 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 }
 
 static struct xfrm_policy *
-__xfrm_policy_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir)
+xfrm_policy_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir)
 {
 #ifdef CONFIG_XFRM_SUB_POLICY
 	struct xfrm_policy *pol;
@@ -1187,26 +1187,6 @@ __xfrm_policy_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir
 	return xfrm_policy_lookup_bytype(net, XFRM_POLICY_TYPE_MAIN, fl, family, dir);
 }
 
-static struct flow_cache_object *
-xfrm_policy_lookup(struct net *net, const struct flowi *fl, u16 family,
-		   u8 dir, struct flow_cache_object *old_obj, void *ctx)
-{
-	struct xfrm_policy *pol;
-
-	if (old_obj)
-		xfrm_pol_put(container_of(old_obj, struct xfrm_policy, flo));
-
-	pol = __xfrm_policy_lookup(net, fl, family, dir);
-	if (IS_ERR_OR_NULL(pol))
-		return ERR_CAST(pol);
-
-	/* Resolver returns two references:
-	 * one for cache and one for caller of flow_cache_lookup() */
-	xfrm_pol_hold(pol);
-
-	return &pol->flo;
-}
-
 static struct xfrm_policy *xfrm_sk_policy_lookup(const struct sock *sk, int dir,
 						 const struct flowi *fl, u16 family)
 {
@@ -2028,7 +2008,7 @@ xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 	/* Resolve policies to use if we couldn't get them from
 	 * previous cache entry */
 	num_pols = 1;
-	pols[0] = __xfrm_policy_lookup(net, fl, family, dir);
+	pols[0] = xfrm_policy_lookup(net, fl, family, dir);
 	err = xfrm_expand_policies(fl, family, pols,
 					   &num_pols, &num_xfrms);
 	if (err < 0)
@@ -2398,16 +2378,8 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 		}
 	}
 
-	if (!pol) {
-		struct flow_cache_object *flo;
-
-		flo = xfrm_policy_lookup(net, &fl, family, dir, NULL, NULL);
-
-		if (IS_ERR_OR_NULL(flo))
-			pol = ERR_CAST(flo);
-		else
-			pol = container_of(flo, struct xfrm_policy, flo);
-	}
+	if (!pol)
+		pol = xfrm_policy_lookup(net, &fl, family, dir);
 
 	if (IS_ERR(pol)) {
 		XFRM_INC_STATS(net, LINUX_MIB_XFRMINPOLERROR);
-- 
2.13.0
