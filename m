From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 06/10] xfrm_policy: kill flow to policy dir conversion
Date: Mon, 17 Jul 2017 13:57:23 +0200
Message-ID: <20170717115727.26042-7-fw@strlen.de>
References: <20170717115727.26042-1-fw@strlen.de>
Cc: steffen.klassert@secunet.com, ilant@mellanox.com,
        Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43934 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751348AbdGQL53 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 07:57:29 -0400
In-Reply-To: <20170717115727.26042-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XFRM_POLICY_IN/OUT/FWD are identical to FLOW_DIR_*, so gcc already
removed this function as its just returns the argument.  Again, no
code change.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_policy.c | 46 ++++------------------------------------------
 1 file changed, 4 insertions(+), 42 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 19d457db3a09..9f724a688475 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1187,24 +1187,6 @@ __xfrm_policy_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir
 	return xfrm_policy_lookup_bytype(net, XFRM_POLICY_TYPE_MAIN, fl, family, dir);
 }
 
-static int flow_to_policy_dir(int dir)
-{
-	if (XFRM_POLICY_IN == FLOW_DIR_IN &&
-	    XFRM_POLICY_OUT == FLOW_DIR_OUT &&
-	    XFRM_POLICY_FWD == FLOW_DIR_FWD)
-		return dir;
-
-	switch (dir) {
-	default:
-	case FLOW_DIR_IN:
-		return XFRM_POLICY_IN;
-	case FLOW_DIR_OUT:
-		return XFRM_POLICY_OUT;
-	case FLOW_DIR_FWD:
-		return XFRM_POLICY_FWD;
-	}
-}
-
 static struct flow_cache_object *
 xfrm_policy_lookup(struct net *net, const struct flowi *fl, u16 family,
 		   u8 dir, struct flow_cache_object *old_obj, void *ctx)
@@ -1214,7 +1196,7 @@ xfrm_policy_lookup(struct net *net, const struct flowi *fl, u16 family,
 	if (old_obj)
 		xfrm_pol_put(container_of(old_obj, struct xfrm_policy, flo));
 
-	pol = __xfrm_policy_lookup(net, fl, family, flow_to_policy_dir(dir));
+	pol = __xfrm_policy_lookup(net, fl, family, dir);
 	if (IS_ERR_OR_NULL(pol))
 		return ERR_CAST(pol);
 
@@ -1225,23 +1207,6 @@ xfrm_policy_lookup(struct net *net, const struct flowi *fl, u16 family,
 	return &pol->flo;
 }
 
-static inline int policy_to_flow_dir(int dir)
-{
-	if (XFRM_POLICY_IN == FLOW_DIR_IN &&
-	    XFRM_POLICY_OUT == FLOW_DIR_OUT &&
-	    XFRM_POLICY_FWD == FLOW_DIR_FWD)
-		return dir;
-	switch (dir) {
-	default:
-	case XFRM_POLICY_IN:
-		return FLOW_DIR_IN;
-	case XFRM_POLICY_OUT:
-		return FLOW_DIR_OUT;
-	case XFRM_POLICY_FWD:
-		return FLOW_DIR_FWD;
-	}
-}
-
 static struct xfrm_policy *xfrm_sk_policy_lookup(const struct sock *sk, int dir,
 						 const struct flowi *fl, u16 family)
 {
@@ -1261,7 +1226,7 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(const struct sock *sk, int dir,
 			}
 			err = security_xfrm_policy_lookup(pol->security,
 						      fl->flowi_secid,
-						      policy_to_flow_dir(dir));
+						      dir);
 			if (!err) {
 				if (!xfrm_pol_hold_rcu(pol))
 					goto again;
@@ -2063,8 +2028,7 @@ xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 	/* Resolve policies to use if we couldn't get them from
 	 * previous cache entry */
 	num_pols = 1;
-	pols[0] = __xfrm_policy_lookup(net, fl, family,
-				       flow_to_policy_dir(dir));
+	pols[0] = __xfrm_policy_lookup(net, fl, family, dir);
 	err = xfrm_expand_policies(fl, family, pols,
 					   &num_pols, &num_xfrms);
 	if (err < 0)
@@ -2142,7 +2106,7 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 	struct xfrm_dst *xdst;
 	struct dst_entry *dst, *route;
 	u16 family = dst_orig->ops->family;
-	u8 dir = policy_to_flow_dir(XFRM_POLICY_OUT);
+	u8 dir = XFRM_POLICY_OUT;
 	int i, err, num_pols, num_xfrms = 0, drop_pols = 0;
 
 	dst = NULL;
@@ -2399,12 +2363,10 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	int pi;
 	int reverse;
 	struct flowi fl;
-	u8 fl_dir;
 	int xerr_idx = -1;
 
 	reverse = dir & ~XFRM_POLICY_MASK;
 	dir &= XFRM_POLICY_MASK;
-	fl_dir = policy_to_flow_dir(dir);
 
 	if (__xfrm_decode_session(skb, &fl, family, reverse) < 0) {
 		XFRM_INC_STATS(net, LINUX_MIB_XFRMINHDRERROR);
-- 
2.13.0
