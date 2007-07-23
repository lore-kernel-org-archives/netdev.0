From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: [PATCH net-2.6.22-rc7] xfrm state selection update to use inner addresses
Date: Mon, 23 Jul 2007 11:19:25 -0500
Message-ID: <200707231119.25457.joakim.koskela@hiit.fi>
References: <200707161506.47915.joakim.koskela@hiit.fi> <200707192054.38945.joakim.koskela@hiit.fi> <469FBECB.6080204@trash.net>
Reply-To: joakim.koskela@hiit.fi
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from peter.ietf69.org ([130.129.5.6]:43665 "EHLO smtp.ietf69.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759488AbXGWQdL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2007 12:33:11 -0400
In-Reply-To: <469FBECB.6080204@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch modifies the xfrm state selection logic to use the inner
addresses where the outer have been (incorrectly) used. This is
required for beet mode in general and interfamily setups in both
tunnel and beet mode.

Signed-off-by: Joakim Koskela <jookos@gmail.com>
Signed-off-by: Herbert Xu     <herbert@gondor.apana.org.au>
Signed-off-by: Diego Beltrami <diego.beltrami@gmail.com>
Signed-off-by: Miika Komu     <miika@iki.fi>
---

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 157bfbd..75fdb7d 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1299,7 +1299,8 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy, struct flowi *fl,
 		xfrm_address_t *local  = saddr;
 		struct xfrm_tmpl *tmpl = &policy->xfrm_vec[i];
 
-		if (tmpl->mode == XFRM_MODE_TUNNEL) {
+		if (tmpl->mode == XFRM_MODE_TUNNEL ||
+		    tmpl->mode == XFRM_MODE_BEET) {
 			remote = &tmpl->id.daddr;
 			local = &tmpl->saddr;
 			family = tmpl->encap_family;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index e070c3f..f5d30c4 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -611,7 +611,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 			      selector.
 			 */
 			if (x->km.state == XFRM_STATE_VALID) {
-				if (!xfrm_selector_match(&x->sel, fl, family) ||
+				if (!xfrm_selector_match(&x->sel, fl, x->sel.family) ||
 				    !security_xfrm_state_pol_flow_match(x, pol, fl))
 					continue;
 				if (!best ||
@@ -623,7 +623,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 				acquire_in_progress = 1;
 			} else if (x->km.state == XFRM_STATE_ERROR ||
 				   x->km.state == XFRM_STATE_EXPIRED) {
-				if (xfrm_selector_match(&x->sel, fl, family) &&
+				if (xfrm_selector_match(&x->sel, fl, x->sel.family) &&
 				    security_xfrm_state_pol_flow_match(x, pol, fl))
 					error = -ESRCH;
 			}
