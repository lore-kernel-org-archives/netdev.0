From: Baker Zhang <baker.kernel@gmail.com>
Subject: [PATCH] use xfrm direction when lookup policy
Date: Tue, 19 Mar 2013 22:24:30 +0800
Message-ID: <1363703070-2910-1-git-send-email-baker.zhang@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Baker Zhang <baker.zhang@gmail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

because xfrm policy direction has same value with corresponding
flow direction, so this problem is covered.

In xfrm_lookup and __xfrm_policy_check, flow_cache_lookup is used to
accelerate the lookup.

Flow direction is given to flow_cache_lookup by policy_to_flow_dir.

When the flow cache is mismatched, callback 'resolver' is called.

'resolver' requires xfrm direction,
so convert direction back to xfrm direction.

Signed-off-by: Baker Zhang <baker.zhang@gmail.com>
---
 net/xfrm/xfrm_policy.c |   23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 167c67d..23cea0f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1037,6 +1037,24 @@ __xfrm_policy_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir
 	return xfrm_policy_lookup_bytype(net, XFRM_POLICY_TYPE_MAIN, fl, family, dir);
 }
 
+static int flow_to_policy_dir(int dir)
+{
+	if (XFRM_POLICY_IN == FLOW_DIR_IN &&
+	    XFRM_POLICY_OUT == FLOW_DIR_OUT &&
+	    XFRM_POLICY_FWD == FLOW_DIR_FWD)
+		return dir;
+
+	switch (dir) {
+	default:
+	case FLOW_DIR_IN:
+		return XFRM_POLICY_IN;
+	case FLOW_DIR_OUT:
+		return XFRM_POLICY_OUT;
+	case FLOW_DIR_FWD:
+		return XFRM_POLICY_FWD;
+	}
+}
+
 static struct flow_cache_object *
 xfrm_policy_lookup(struct net *net, const struct flowi *fl, u16 family,
 		   u8 dir, struct flow_cache_object *old_obj, void *ctx)
@@ -1046,7 +1064,7 @@ xfrm_policy_lookup(struct net *net, const struct flowi *fl, u16 family,
 	if (old_obj)
 		xfrm_pol_put(container_of(old_obj, struct xfrm_policy, flo));
 
-	pol = __xfrm_policy_lookup(net, fl, family, dir);
+	pol = __xfrm_policy_lookup(net, fl, family, flow_to_policy_dir(dir));
 	if (IS_ERR_OR_NULL(pol))
 		return ERR_CAST(pol);
 
@@ -1932,7 +1950,8 @@ xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 	 * previous cache entry */
 	if (xdst == NULL) {
 		num_pols = 1;
-		pols[0] = __xfrm_policy_lookup(net, fl, family, dir);
+		pols[0] = __xfrm_policy_lookup(net, fl, family,
+					       flow_to_policy_dir(dir));
 		err = xfrm_expand_policies(fl, family, pols,
 					   &num_pols, &num_xfrms);
 		if (err < 0)
-- 
1.7.9.5
