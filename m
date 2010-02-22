From: jamal <hadi@cyberus.ca>
Subject: [net-next-2.6 PATCH 3/7] xfrm: SA lookups with mark
Date: Mon, 22 Feb 2010 16:32:56 -0500
Message-ID: <1266874380-29593-4-git-send-email-hadi@cyberus.ca>
References: <xfrm-mark-v3>
 <1266874380-29593-1-git-send-email-hadi@cyberus.ca>
 <1266874380-29593-2-git-send-email-hadi@cyberus.ca>
 <1266874380-29593-3-git-send-email-hadi@cyberus.ca>
Cc: timo.teras@iki.fi, kaber@trash.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:48471 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754668Ab0BVVdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 16:33:23 -0500
Received: by bwz1 with SMTP id 1so465337bwz.21
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2010 13:33:21 -0800 (PST)
In-Reply-To: <1266874380-29593-3-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

Allow mark to be added to the SA lookup

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 net/xfrm/xfrm_state.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 9f85303..17d5b96 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -682,6 +682,8 @@ static struct xfrm_state *__xfrm_state_lookup(struct net *net, u32 mark, xfrm_ad
 		    xfrm_addr_cmp(&x->id.daddr, daddr, family))
 			continue;
 
+		if ((mark & x->mark.m) != x->mark.v)
+			continue;
 		xfrm_state_hold(x);
 		return x;
 	}
@@ -702,6 +704,8 @@ static struct xfrm_state *__xfrm_state_lookup_byaddr(struct net *net, u32 mark,
 		    xfrm_addr_cmp(&x->props.saddr, saddr, family))
 			continue;
 
+		if ((mark & x->mark.m) != x->mark.v)
+			continue;
 		xfrm_state_hold(x);
 		return x;
 	}
@@ -794,6 +798,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h, bydst) {
 		if (x->props.family == family &&
 		    x->props.reqid == tmpl->reqid &&
+		    (mark & x->mark.m) == x->mark.v &&
 		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
 		    xfrm_state_addr_check(x, daddr, saddr, family) &&
 		    tmpl->mode == x->props.mode &&
@@ -809,6 +814,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h_wildcard, bydst) {
 		if (x->props.family == family &&
 		    x->props.reqid == tmpl->reqid &&
+		    (mark & x->mark.m) == x->mark.v &&
 		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
 		    xfrm_state_addr_check(x, daddr, saddr, family) &&
 		    tmpl->mode == x->props.mode &&
@@ -892,6 +898,7 @@ xfrm_stateonly_find(struct net *net, u32 mark,
 	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h, bydst) {
 		if (x->props.family == family &&
 		    x->props.reqid == reqid &&
+		    (mark & x->mark.m) == x->mark.v &&
 		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
 		    xfrm_state_addr_check(x, daddr, saddr, family) &&
 		    mode == x->props.mode &&
@@ -954,11 +961,13 @@ static void __xfrm_state_bump_genids(struct xfrm_state *xnew)
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
@@ -980,6 +989,7 @@ static struct xfrm_state *__find_acq_core(struct net *net, struct xfrm_mark *m,
 	unsigned int h = xfrm_dst_hash(net, daddr, saddr, reqid, family);
 	struct hlist_node *entry;
 	struct xfrm_state *x;
+	u32 mark = m->v & m->m;
 
 	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h, bydst) {
 		if (x->props.reqid  != reqid ||
@@ -988,6 +998,7 @@ static struct xfrm_state *__find_acq_core(struct net *net, struct xfrm_mark *m,
 		    x->km.state     != XFRM_STATE_ACQ ||
 		    x->id.spi       != 0 ||
 		    x->id.proto	    != proto ||
+		    (mark & x->mark.m) != x->mark.v ||
 		    xfrm_addr_cmp(&x->id.daddr, daddr, family) ||
 		    xfrm_addr_cmp(&x->props.saddr, saddr, family))
 			continue;
@@ -1442,6 +1453,7 @@ static struct xfrm_state *__xfrm_find_acq_byseq(struct net *net, u32 mark, u32 s
 
 		hlist_for_each_entry(x, entry, net->xfrm.state_bydst+i, bydst) {
 			if (x->km.seq == seq &&
+			    (mark & x->mark.m) == x->mark.v &&
 			    x->km.state == XFRM_STATE_ACQ) {
 				xfrm_state_hold(x);
 				return x;
-- 
1.6.0.4

