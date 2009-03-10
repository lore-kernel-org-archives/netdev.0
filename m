From: David Miller <davem@davemloft.net>
Subject: Re: XFRM state hash value
Date: Tue, 10 Mar 2009 04:20:51 -0700 (PDT)
Message-ID: <20090310.042051.107256879.davem@davemloft.net>
References: <49B636DB.7010004@dev.6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@dev.6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33106
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754259AbZCJLVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 07:21:06 -0400
In-Reply-To: <49B636DB.7010004@dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Date: Tue, 10 Mar 2009 10:46:03 +0100

> this commit: [XFRM]: Hash xfrm_state objects by source address too. (http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=c1969f294e624d5b642fc8e6ab9468b7c7791fa8)
> introduces src address in hash for state.
> But in some cases, source address is a wildcard when state is inserted. For example, we can have something like this:
> # setkey -c
> add :: ff02::9 ah 0x100 -m transport -A hmac-md5 "cle3goldorakcle3";
> 
> In this case, __xfrm_state_insert() will calculate the hash value with src address set to 0, but xfrm_state_find() will use the real source address to calculate this hash. At the end, no state will be found.
> The most simple way to resolve this pb is to revert the previous patch, but maybe someone has a better idea...
> 

Please try this patch:

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index e25ff62..86b9078 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -748,12 +748,51 @@ static void xfrm_hash_grow_check(struct net *net, int have_hash_collision)
 		schedule_work(&net->xfrm.state_hash_work);
 }
 
+static void xfrm_state_look_at(struct xfrm_policy *pol, struct xfrm_state *x,
+			       struct flowi *fl, unsigned short family,
+			       xfrm_address_t *daddr, xfrm_address_t *saddr,
+			       struct xfrm_state **best, int *acq_in_progress,
+			       int *error)
+{
+	/* Resolution logic:
+	 * 1. There is a valid state with matching selector. Done.
+	 * 2. Valid state with inappropriate selector. Skip.
+	 *
+	 * Entering area of "sysdeps".
+	 *
+	 * 3. If state is not valid, selector is temporary, it selects
+	 *    only session which triggered previous resolution. Key
+	 *    manager will do something to install a state with proper
+	 *    selector.
+	 */
+	if (x->km.state == XFRM_STATE_VALID) {
+		if ((x->sel.family &&
+		     !xfrm_selector_match(&x->sel, fl, x->sel.family)) ||
+		    !security_xfrm_state_pol_flow_match(x, pol, fl))
+			return;
+
+		if (!*best ||
+		    (*best)->km.dying > x->km.dying ||
+		    ((*best)->km.dying == x->km.dying &&
+		     (*best)->curlft.add_time < x->curlft.add_time))
+			*best = x;
+	} else if (x->km.state == XFRM_STATE_ACQ) {
+		*acq_in_progress = 1;
+	} else if (x->km.state == XFRM_STATE_ERROR ||
+		   x->km.state == XFRM_STATE_EXPIRED) {
+		if (xfrm_selector_match(&x->sel, fl, x->sel.family) &&
+		    security_xfrm_state_pol_flow_match(x, pol, fl))
+			*error = -ESRCH;
+	}
+}
+
 struct xfrm_state *
 xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 		struct flowi *fl, struct xfrm_tmpl *tmpl,
 		struct xfrm_policy *pol, int *err,
 		unsigned short family)
 {
+	static xfrm_address_t saddr_wildcard = { };
 	struct net *net = xp_net(pol);
 	unsigned int h;
 	struct hlist_node *entry;
@@ -773,38 +812,21 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 		    xfrm_state_addr_check(x, daddr, saddr, family) &&
 		    tmpl->mode == x->props.mode &&
 		    tmpl->id.proto == x->id.proto &&
-		    (tmpl->id.spi == x->id.spi || !tmpl->id.spi)) {
-			/* Resolution logic:
-			   1. There is a valid state with matching selector.
-			      Done.
-			   2. Valid state with inappropriate selector. Skip.
-
-			   Entering area of "sysdeps".
-
-			   3. If state is not valid, selector is temporary,
-			      it selects only session which triggered
-			      previous resolution. Key manager will do
-			      something to install a state with proper
-			      selector.
-			 */
-			if (x->km.state == XFRM_STATE_VALID) {
-				if ((x->sel.family && !xfrm_selector_match(&x->sel, fl, x->sel.family)) ||
-				    !security_xfrm_state_pol_flow_match(x, pol, fl))
-					continue;
-				if (!best ||
-				    best->km.dying > x->km.dying ||
-				    (best->km.dying == x->km.dying &&
-				     best->curlft.add_time < x->curlft.add_time))
-					best = x;
-			} else if (x->km.state == XFRM_STATE_ACQ) {
-				acquire_in_progress = 1;
-			} else if (x->km.state == XFRM_STATE_ERROR ||
-				   x->km.state == XFRM_STATE_EXPIRED) {
-				if (xfrm_selector_match(&x->sel, fl, x->sel.family) &&
-				    security_xfrm_state_pol_flow_match(x, pol, fl))
-					error = -ESRCH;
-			}
-		}
+		    (tmpl->id.spi == x->id.spi || !tmpl->id.spi))
+			xfrm_state_look_at(pol, x, fl, family, daddr, saddr,
+					   &best, &acquire_in_progress, &error);
+	}
+	h = xfrm_dst_hash(net, daddr, &saddr_wildcard, tmpl->reqid, family);
+	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h, bydst) {
+		if (x->props.family == family &&
+		    x->props.reqid == tmpl->reqid &&
+		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
+		    xfrm_state_addr_check(x, daddr, saddr, family) &&
+		    tmpl->mode == x->props.mode &&
+		    tmpl->id.proto == x->id.proto &&
+		    (tmpl->id.spi == x->id.spi || !tmpl->id.spi))
+			xfrm_state_look_at(pol, x, fl, family, daddr, saddr,
+					   &best, &acquire_in_progress, &error);
 	}
 
 	x = best;
