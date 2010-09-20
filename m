From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] xfrm: Allow different selector family in temporary state
Date: Mon, 20 Sep 2010 13:52:53 +0200
Message-ID: <20100920115253.GG4134@gauss.secunet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Egerer <thomas.egerer@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:42438 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755350Ab0ITLsM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Sep 2010 07:48:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Egerer <thomas.egerer@secunet.com>

The family parameter xfrm_state_find is used to find a state matching a
certain policy. This value is set to the template's family
(encap_family) right before xfrm_state_find is called.
The family parameter is however also used to construct a temporary state
in xfrm_state_find itself which is wrong for inter-family scenarios
because it produces a selector for the wrong family. Since this selector
is included in the xfrm_user_acquire structure, user space programs
misinterpret IPv6 addresses as IPv4 and vice versa.
This patch splits up the original init_tempsel function into a part that
initializes the selector respectively the props and id of the temporary
state, to allow for differing ip address families whithin the state.

Signed-off-by: Thomas Egerer <thomas.egerer@secunet.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h     |    4 ++--
 net/ipv4/xfrm4_state.c |   33 +++++++++++++++++++--------------
 net/ipv6/xfrm6_state.c |   33 +++++++++++++++++++--------------
 net/xfrm/xfrm_policy.c |    5 ++---
 net/xfrm/xfrm_state.c  |   45 +++++++++++++++++++++++++++------------------
 5 files changed, 69 insertions(+), 51 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index fc8f36d..4f53532 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -298,8 +298,8 @@ struct xfrm_state_afinfo {
 	const struct xfrm_type	*type_map[IPPROTO_MAX];
 	struct xfrm_mode	*mode_map[XFRM_MODE_MAX];
 	int			(*init_flags)(struct xfrm_state *x);
-	void			(*init_tempsel)(struct xfrm_state *x, struct flowi *fl,
-						struct xfrm_tmpl *tmpl,
+	void			(*init_tempsel)(struct xfrm_selector *sel, struct flowi *fl);
+	void			(*init_temprop)(struct xfrm_state *x, struct xfrm_tmpl *tmpl,
 						xfrm_address_t *daddr, xfrm_address_t *saddr);
 	int			(*tmpl_sort)(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n);
 	int			(*state_sort)(struct xfrm_state **dst, struct xfrm_state **src, int n);
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 1ef1366..4794762 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -21,21 +21,25 @@ static int xfrm4_init_flags(struct xfrm_state *x)
 }
 
 static void
-__xfrm4_init_tempsel(struct xfrm_state *x, struct flowi *fl,
-		     struct xfrm_tmpl *tmpl,
-		     xfrm_address_t *daddr, xfrm_address_t *saddr)
+__xfrm4_init_tempsel(struct xfrm_selector *sel, struct flowi *fl)
+{
+	sel->daddr.a4 = fl->fl4_dst;
+	sel->saddr.a4 = fl->fl4_src;
+	sel->dport = xfrm_flowi_dport(fl);
+	sel->dport_mask = htons(0xffff);
+	sel->sport = xfrm_flowi_sport(fl);
+	sel->sport_mask = htons(0xffff);
+	sel->family = AF_INET;
+	sel->prefixlen_d = 32;
+	sel->prefixlen_s = 32;
+	sel->proto = fl->proto;
+	sel->ifindex = fl->oif;
+}
+
+static void
+xfrm4_init_temprop(struct xfrm_state *x, struct xfrm_tmpl *tmpl,
+		   xfrm_address_t *daddr, xfrm_address_t *saddr)
 {
-	x->sel.daddr.a4 = fl->fl4_dst;
-	x->sel.saddr.a4 = fl->fl4_src;
-	x->sel.dport = xfrm_flowi_dport(fl);
-	x->sel.dport_mask = htons(0xffff);
-	x->sel.sport = xfrm_flowi_sport(fl);
-	x->sel.sport_mask = htons(0xffff);
-	x->sel.family = AF_INET;
-	x->sel.prefixlen_d = 32;
-	x->sel.prefixlen_s = 32;
-	x->sel.proto = fl->proto;
-	x->sel.ifindex = fl->oif;
 	x->id = tmpl->id;
 	if (x->id.daddr.a4 == 0)
 		x->id.daddr.a4 = daddr->a4;
@@ -70,6 +74,7 @@ static struct xfrm_state_afinfo xfrm4_state_afinfo = {
 	.owner			= THIS_MODULE,
 	.init_flags		= xfrm4_init_flags,
 	.init_tempsel		= __xfrm4_init_tempsel,
+	.init_temprop		= xfrm4_init_temprop,
 	.output			= xfrm4_output,
 	.extract_input		= xfrm4_extract_input,
 	.extract_output		= xfrm4_extract_output,
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index f417b77..a67575d 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -20,23 +20,27 @@
 #include <net/addrconf.h>
 
 static void
-__xfrm6_init_tempsel(struct xfrm_state *x, struct flowi *fl,
-		     struct xfrm_tmpl *tmpl,
-		     xfrm_address_t *daddr, xfrm_address_t *saddr)
+__xfrm6_init_tempsel(struct xfrm_selector *sel, struct flowi *fl)
 {
 	/* Initialize temporary selector matching only
 	 * to current session. */
-	ipv6_addr_copy((struct in6_addr *)&x->sel.daddr, &fl->fl6_dst);
-	ipv6_addr_copy((struct in6_addr *)&x->sel.saddr, &fl->fl6_src);
-	x->sel.dport = xfrm_flowi_dport(fl);
-	x->sel.dport_mask = htons(0xffff);
-	x->sel.sport = xfrm_flowi_sport(fl);
-	x->sel.sport_mask = htons(0xffff);
-	x->sel.family = AF_INET6;
-	x->sel.prefixlen_d = 128;
-	x->sel.prefixlen_s = 128;
-	x->sel.proto = fl->proto;
-	x->sel.ifindex = fl->oif;
+	ipv6_addr_copy((struct in6_addr *)&sel->daddr, &fl->fl6_dst);
+	ipv6_addr_copy((struct in6_addr *)&sel->saddr, &fl->fl6_src);
+	sel->dport = xfrm_flowi_dport(fl);
+	sel->dport_mask = htons(0xffff);
+	sel->sport = xfrm_flowi_sport(fl);
+	sel->sport_mask = htons(0xffff);
+	sel->family = AF_INET6;
+	sel->prefixlen_d = 128;
+	sel->prefixlen_s = 128;
+	sel->proto = fl->proto;
+	sel->ifindex = fl->oif;
+}
+
+static void
+xfrm6_init_temprop(struct xfrm_state *x, struct xfrm_tmpl *tmpl,
+		   xfrm_address_t *daddr, xfrm_address_t *saddr)
+{
 	x->id = tmpl->id;
 	if (ipv6_addr_any((struct in6_addr*)&x->id.daddr))
 		memcpy(&x->id.daddr, daddr, sizeof(x->sel.daddr));
@@ -168,6 +172,7 @@ static struct xfrm_state_afinfo xfrm6_state_afinfo = {
 	.eth_proto		= htons(ETH_P_IPV6),
 	.owner			= THIS_MODULE,
 	.init_tempsel		= __xfrm6_init_tempsel,
+	.init_temprop		= xfrm6_init_temprop,
 	.tmpl_sort		= __xfrm6_tmpl_sort,
 	.state_sort		= __xfrm6_state_sort,
 	.output			= xfrm6_output,
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 2b3ed7a..cbab6e1 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1175,9 +1175,8 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy, struct flowi *fl,
 		    tmpl->mode == XFRM_MODE_BEET) {
 			remote = &tmpl->id.daddr;
 			local = &tmpl->saddr;
-			family = tmpl->encap_family;
-			if (xfrm_addr_any(local, family)) {
-				error = xfrm_get_saddr(net, &tmp, remote, family);
+			if (xfrm_addr_any(local, tmpl->encap_family)) {
+				error = xfrm_get_saddr(net, &tmp, remote, tmpl->encap_family);
 				if (error)
 					goto fail;
 				local = &tmp;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 5208b12..eb96ce5 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -656,15 +656,23 @@ void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si)
 EXPORT_SYMBOL(xfrm_sad_getinfo);
 
 static int
-xfrm_init_tempsel(struct xfrm_state *x, struct flowi *fl,
-		  struct xfrm_tmpl *tmpl,
-		  xfrm_address_t *daddr, xfrm_address_t *saddr,
-		  unsigned short family)
+xfrm_init_tempstate(struct xfrm_state *x, struct flowi *fl,
+		    struct xfrm_tmpl *tmpl,
+		    xfrm_address_t *daddr, xfrm_address_t *saddr,
+		    unsigned short family)
 {
 	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
 	if (!afinfo)
 		return -1;
-	afinfo->init_tempsel(x, fl, tmpl, daddr, saddr);
+	afinfo->init_tempsel(&x->sel, fl);
+
+	if (family != tmpl->encap_family) {
+		xfrm_state_put_afinfo(afinfo);
+		afinfo = xfrm_state_get_afinfo(tmpl->encap_family);
+		if (!afinfo)
+			return -1;
+	}
+	afinfo->init_temprop(x, tmpl, daddr, saddr);
 	xfrm_state_put_afinfo(afinfo);
 	return 0;
 }
@@ -790,37 +798,38 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 	int error = 0;
 	struct xfrm_state *best = NULL;
 	u32 mark = pol->mark.v & pol->mark.m;
+	unsigned short encap_family = tmpl->encap_family;
 
 	to_put = NULL;
 
 	spin_lock_bh(&xfrm_state_lock);
-	h = xfrm_dst_hash(net, daddr, saddr, tmpl->reqid, family);
+	h = xfrm_dst_hash(net, daddr, saddr, tmpl->reqid, encap_family);
 	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h, bydst) {
-		if (x->props.family == family &&
+		if (x->props.family == encap_family &&
 		    x->props.reqid == tmpl->reqid &&
 		    (mark & x->mark.m) == x->mark.v &&
 		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
-		    xfrm_state_addr_check(x, daddr, saddr, family) &&
+		    xfrm_state_addr_check(x, daddr, saddr, encap_family) &&
 		    tmpl->mode == x->props.mode &&
 		    tmpl->id.proto == x->id.proto &&
 		    (tmpl->id.spi == x->id.spi || !tmpl->id.spi))
-			xfrm_state_look_at(pol, x, fl, family, daddr, saddr,
+			xfrm_state_look_at(pol, x, fl, encap_family, daddr, saddr,
 					   &best, &acquire_in_progress, &error);
 	}
 	if (best)
 		goto found;
 
-	h_wildcard = xfrm_dst_hash(net, daddr, &saddr_wildcard, tmpl->reqid, family);
+	h_wildcard = xfrm_dst_hash(net, daddr, &saddr_wildcard, tmpl->reqid, encap_family);
 	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h_wildcard, bydst) {
-		if (x->props.family == family &&
+		if (x->props.family == encap_family &&
 		    x->props.reqid == tmpl->reqid &&
 		    (mark & x->mark.m) == x->mark.v &&
 		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
-		    xfrm_state_addr_check(x, daddr, saddr, family) &&
+		    xfrm_state_addr_check(x, daddr, saddr, encap_family) &&
 		    tmpl->mode == x->props.mode &&
 		    tmpl->id.proto == x->id.proto &&
 		    (tmpl->id.spi == x->id.spi || !tmpl->id.spi))
-			xfrm_state_look_at(pol, x, fl, family, daddr, saddr,
+			xfrm_state_look_at(pol, x, fl, encap_family, daddr, saddr,
 					   &best, &acquire_in_progress, &error);
 	}
 
@@ -829,7 +838,7 @@ found:
 	if (!x && !error && !acquire_in_progress) {
 		if (tmpl->id.spi &&
 		    (x0 = __xfrm_state_lookup(net, mark, daddr, tmpl->id.spi,
-					      tmpl->id.proto, family)) != NULL) {
+					      tmpl->id.proto, encap_family)) != NULL) {
 			to_put = x0;
 			error = -EEXIST;
 			goto out;
@@ -839,9 +848,9 @@ found:
 			error = -ENOMEM;
 			goto out;
 		}
-		/* Initialize temporary selector matching only
+		/* Initialize temporary state matching only
 		 * to current session. */
-		xfrm_init_tempsel(x, fl, tmpl, daddr, saddr, family);
+		xfrm_init_tempstate(x, fl, tmpl, daddr, saddr, family);
 		memcpy(&x->mark, &pol->mark, sizeof(x->mark));
 
 		error = security_xfrm_state_alloc_acquire(x, pol->security, fl->secid);
@@ -856,10 +865,10 @@ found:
 			x->km.state = XFRM_STATE_ACQ;
 			list_add(&x->km.all, &net->xfrm.state_all);
 			hlist_add_head(&x->bydst, net->xfrm.state_bydst+h);
-			h = xfrm_src_hash(net, daddr, saddr, family);
+			h = xfrm_src_hash(net, daddr, saddr, encap_family);
 			hlist_add_head(&x->bysrc, net->xfrm.state_bysrc+h);
 			if (x->id.spi) {
-				h = xfrm_spi_hash(net, &x->id.daddr, x->id.spi, x->id.proto, family);
+				h = xfrm_spi_hash(net, &x->id.daddr, x->id.spi, x->id.proto, encap_family);
 				hlist_add_head(&x->byspi, net->xfrm.state_byspi+h);
 			}
 			x->lft.hard_add_expires_seconds = net->xfrm.sysctl_acq_expires;
-- 
1.7.0.4

