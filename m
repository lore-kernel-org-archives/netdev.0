From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: [RFC PATCH] xfrm: fix regression introduced by xdst pcpu cache
Date: Mon, 30 Oct 2017 10:58:43 -0400
Message-ID: <20171030145843.13496-1-sds@tycho.nsa.gov>
Cc: linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
        fw@strlen.de, davem@davemloft.net, herbert@gondor.apana.org.au,
        steffen.klassert@secunet.com, paul@paul-moore.com,
        Stephen Smalley <sds@tycho.nsa.gov>
To: netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since 4.14-rc1, the selinux-testsuite has been encountering sporadic
failures during testing of labeled IPSEC. git bisect pointed to
commit ec30d78c14a813db39a647b6a348b4286 ("xfrm: add xdst pcpu cache").
The xdst pcpu cache is only checking that the policies are the same,
but does not validate that the policy, state, and flow match with respect
to security context labeling.  As a result, the wrong SA could be used
and the receiver could end up performing permission checking and
providing SO_PEERSEC or SCM_SECURITY values for the wrong security context.
security_xfrm_state_pol_flow_match() exists for this purpose and is
already called from xfrm_state_look_at() for matching purposes.
Further, xfrm_state_look_at() also performs a xfrm_selector_match() test,
which is also missing from the xdst pcpu cache logic.  Add calls to both
of these functions when validating the cache entry.  With these changes,
the selinux-testsuite passes all tests again.

Fixes: ec30d78c14a813db39a647b6a348b4286ba4abf5 ("xfrm: add xdst pcpu cache")
Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>
---
This is an RFC because I am not entirely confident in the fix, e.g. is it
sufficient to perform this matching only on the first xfrm or do they all
need to be walked as in xfrm_bundle_ok()?  Also, should we perform this
matching before (as in this patch) or after calling xfrm_bundle_ok()? Also,
do we need to test xfrm->sel.family before calling xfrm_selector_match
(as in this patch) or not - xfrm_state_look_at() does so when the
state is XFRM_STATE_VALID but not when it is _ERROR or _EXPIRED?

 net/xfrm/xfrm_policy.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 2746b62..171818b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1820,6 +1820,11 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
 	    !xfrm_pol_dead(xdst) &&
 	    memcmp(xdst->pols, pols,
 		   sizeof(struct xfrm_policy *) * num_pols) == 0 &&
+	    (!xdst->u.dst.xfrm->sel.family ||
+	     xfrm_selector_match(&xdst->u.dst.xfrm->sel, fl,
+				 xdst->u.dst.xfrm->sel.family)) &&
+	    security_xfrm_state_pol_flow_match(xdst->u.dst.xfrm,
+					       xdst->pols[0], fl) &&
 	    xfrm_bundle_ok(xdst)) {
 		dst_hold(&xdst->u.dst);
 		return xdst;
-- 
2.9.5

