From: jamal <hadi@cyberus.ca>
Subject: [net-next-2.6 PATCH 3/7] xfrm: SA lookups with mark
Date: Sun, 14 Feb 2010 10:18:48 -0500
Message-ID: <1266160732-946-4-git-send-email-hadi@cyberus.ca>
References: <xfrm-mark-net-next>
 <1266160732-946-1-git-send-email-hadi@cyberus.ca>
 <1266160732-946-2-git-send-email-hadi@cyberus.ca>
 <1266160732-946-3-git-send-email-hadi@cyberus.ca>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: timo.teras@iki.fi, kaber@trash.net, herbert@gondor.apana.org.au,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:54675 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275Ab0BNPTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 10:19:07 -0500
Received: by qw-out-2122.google.com with SMTP id 5so313013qwi.37
        for <netdev@vger.kernel.org>; Sun, 14 Feb 2010 07:19:07 -0800 (PST)
In-Reply-To: <1266160732-946-3-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

Allow mark to be added to the SA lookup

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 net/xfrm/xfrm_state.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index fcf0d9f..151c6d6 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -678,6 +678,8 @@ static struct xfrm_state *__xfrm_state_lookup(struct net *net, u32 mark, xfrm_ad
 		    xfrm_addr_cmp(&x->id.daddr, daddr, family))
 			continue;
 
+		if ((mark & x->mark.m) != x->mark.v)
+			continue;
 		xfrm_state_hold(x);
 		return x;
 	}
@@ -698,6 +700,8 @@ static struct xfrm_state *__xfrm_state_lookup_byaddr(struct net *net, u32 mark,
 		    xfrm_addr_cmp(&x->props.saddr, saddr, family))
 			continue;
 
+		if ((mark & x->mark.m) != x->mark.v)
+			continue;
 		xfrm_state_hold(x);
 		return x;
 	}
@@ -790,6 +794,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h, bydst) {
 		if (x->props.family == family &&
 		    x->props.reqid == tmpl->reqid &&
+		    (mark & x->mark.m) == x->mark.v &&
 		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
 		    xfrm_state_addr_check(x, daddr, saddr, family) &&
 		    tmpl->mode == x->props.mode &&
@@ -805,6 +810,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h_wildcard, bydst) {
 		if (x->props.family == family &&
 		    x->props.reqid == tmpl->reqid &&
+		    (mark & x->mark.m) == x->mark.v &&
 		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
 		    xfrm_state_addr_check(x, daddr, saddr, family) &&
 		    tmpl->mode == x->props.mode &&
@@ -888,6 +894,7 @@ xfrm_stateonly_find(struct net *net, u32 mark,
 	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h, bydst) {
 		if (x->props.family == family &&
 		    x->props.reqid == reqid &&
+		    (mark & x->mark.m) == x->mark.v &&
 		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
 		    xfrm_state_addr_check(x, daddr, saddr, family) &&
 		    mode == x->props.mode &&
@@ -950,11 +957,13 @@ static void __xfrm_state_bump_genids(struct xfrm_state *xnew)
 	struct xfrm_state *x;
 	struct hlist_node *entry;
 	unsigned int h;
+	u32 mark = xnew->mark.v & xnew->mark.m;
 
 	h = xfrm_dst_hash(net, &xnew->id.daddr, &xnew->props.saddr, reqid, family);
 	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h, bydst) {
 		if (x->props.family	== family &&
 		    x->props.reqid	== reqid &&
+		    (mark & x->mark.m) == x->mark.v &&
 		    !xfrm_addr_cmp(&x->id.daddr, &xnew->id.daddr, family) &&
 		    !xfrm_addr_cmp(&x->props.saddr, &xnew->props.saddr, family))
 			x->genid = xfrm_state_genid;
@@ -976,6 +985,7 @@ static struct xfrm_state *__find_acq_core(struct net *net, struct xfrm_kmark *m,
 	unsigned int h = xfrm_dst_hash(net, daddr, saddr, reqid, family);
 	struct hlist_node *entry;
 	struct xfrm_state *x;
+	u32 mark = m->v & m->m;
 
 	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h, bydst) {
 		if (x->props.reqid  != reqid ||
@@ -984,6 +994,7 @@ static struct xfrm_state *__find_acq_core(struct net *net, struct xfrm_kmark *m,
 		    x->km.state     != XFRM_STATE_ACQ ||
 		    x->id.spi       != 0 ||
 		    x->id.proto	    != proto ||
+		    (mark & x->mark.m) != x->mark.v ||
 		    xfrm_addr_cmp(&x->id.daddr, daddr, family) ||
 		    xfrm_addr_cmp(&x->props.saddr, saddr, family))
 			continue;
@@ -1444,6 +1455,7 @@ static struct xfrm_state *__xfrm_find_acq_byseq(struct net *net, u32 mark, u32 s
 
 		hlist_for_each_entry(x, entry, net->xfrm.state_bydst+i, bydst) {
 			if (x->km.seq == seq &&
+			    (mark & x->mark.m) == x->mark.v &&
 			    x->km.state == XFRM_STATE_ACQ) {
 				xfrm_state_hold(x);
 				return x;
-- 
1.6.0.4

