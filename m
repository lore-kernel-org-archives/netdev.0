From: Florian Westphal <fw@strlen.de>
Subject: [RFC net-next 3/9] xfrm_policy: bypass flow_cache_lookup
Date: Wed, 28 Jun 2017 15:26:46 +0200
Message-ID: <20170628132652.1275-4-fw@strlen.de>
References: <20170628132652.1275-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:34212 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751858AbdF1N0x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 09:26:53 -0400
In-Reply-To: <20170628132652.1275-1-fw@strlen.de>
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
index a3dc7ab0b7ed..084736ff2681 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2056,13 +2056,12 @@ static struct xfrm_dst *xfrm_create_dummy_bundle(struct net *net,
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
@@ -2132,8 +2131,6 @@ xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 		dst_release_immediate(&xdst->u.dst);
 	}
 
-	/* We do need to return one reference for original caller */
-	dst_hold(&new_xdst->u.dst);
 	return &new_xdst->flo;
 
 make_dummy_bundle:
@@ -2246,8 +2243,7 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 		    !net->xfrm.policy_count[XFRM_POLICY_OUT])
 			goto nopol;
 
-		flo = flow_cache_lookup(net, fl, family, dir,
-					xfrm_bundle_lookup, &xflo);
+		flo = xfrm_bundle_lookup(net, fl, family, dir, &xflo);
 		if (flo == NULL)
 			goto nopol;
 		if (IS_ERR(flo)) {
@@ -2493,8 +2489,8 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
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
