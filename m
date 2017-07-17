From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 04/10] xfrm_policy: bypass flow_cache_lookup
Date: Mon, 17 Jul 2017 13:57:21 +0200
Message-ID: <20170717115727.26042-5-fw@strlen.de>
References: <20170717115727.26042-1-fw@strlen.de>
Cc: steffen.klassert@secunet.com, ilant@mellanox.com,
        Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43920 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751341AbdGQL5W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 07:57:22 -0400
In-Reply-To: <20170717115727.26042-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of consulting flow cache, call the xfrm bundle/policy lookup
functions directly.  This pretends the flow cache had no entry.

This helps to gradually remove flow cache integration,
followup commit will remove the dead code that this change adds.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_policy.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index ff61d8557929..1c7126ab752c 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2052,13 +2052,12 @@ static struct xfrm_dst *xfrm_create_dummy_bundle(struct net *net,
 }
 
 static struct flow_cache_object *
-xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
-		   struct flow_cache_object *oldflo, void *ctx)
+xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir, struct xfrm_flo *xflo)
 {
-	struct xfrm_flo *xflo = (struct xfrm_flo *)ctx;
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
 	struct xfrm_dst *xdst, *new_xdst;
 	int num_pols = 0, num_xfrms = 0, i, err, pol_dead;
+	struct flow_cache_object *oldflo = NULL;
 
 	/* Check if the policies from old bundle are usable */
 	xdst = NULL;
@@ -2128,8 +2127,6 @@ xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 		dst_release_immediate(&xdst->u.dst);
 	}
 
-	/* We do need to return one reference for original caller */
-	dst_hold(&new_xdst->u.dst);
 	return &new_xdst->flo;
 
 make_dummy_bundle:
@@ -2242,8 +2239,7 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 		    !net->xfrm.policy_count[XFRM_POLICY_OUT])
 			goto nopol;
 
-		flo = flow_cache_lookup(net, fl, family, dir,
-					xfrm_bundle_lookup, &xflo);
+		flo = xfrm_bundle_lookup(net, fl, family, dir, &xflo);
 		if (flo == NULL)
 			goto nopol;
 		if (IS_ERR(flo)) {
@@ -2489,8 +2485,8 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	if (!pol) {
 		struct flow_cache_object *flo;
 
-		flo = flow_cache_lookup(net, &fl, family, fl_dir,
-					xfrm_policy_lookup, NULL);
+		flo = xfrm_policy_lookup(net, &fl, family, dir, NULL, NULL);
+
 		if (IS_ERR_OR_NULL(flo))
 			pol = ERR_CAST(flo);
 		else
-- 
2.13.0
