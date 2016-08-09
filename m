From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 1/6] xfrm: state: use hlist_for_each_entry_rcu helper
Date: Tue,  9 Aug 2016 12:16:04 +0200
Message-ID: <1470737769-30438-2-git-send-email-fw@strlen.de>
References: <1470737769-30438-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43904 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751522AbcHIKQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 06:16:36 -0400
In-Reply-To: <1470737769-30438-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is required once we allow lockless access of bydst/bysrc hash tables.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_state.c | 38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 9895a8c..904ab4d 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -76,18 +76,18 @@ static void xfrm_hash_transfer(struct hlist_head *list,
 		h = __xfrm_dst_hash(&x->id.daddr, &x->props.saddr,
 				    x->props.reqid, x->props.family,
 				    nhashmask);
-		hlist_add_head(&x->bydst, ndsttable+h);
+		hlist_add_head_rcu(&x->bydst, ndsttable + h);
 
 		h = __xfrm_src_hash(&x->id.daddr, &x->props.saddr,
 				    x->props.family,
 				    nhashmask);
-		hlist_add_head(&x->bysrc, nsrctable+h);
+		hlist_add_head_rcu(&x->bysrc, nsrctable + h);
 
 		if (x->id.spi) {
 			h = __xfrm_spi_hash(&x->id.daddr, x->id.spi,
 					    x->id.proto, x->props.family,
 					    nhashmask);
-			hlist_add_head(&x->byspi, nspitable+h);
+			hlist_add_head_rcu(&x->byspi, nspitable + h);
 		}
 	}
 }
@@ -520,10 +520,10 @@ int __xfrm_state_delete(struct xfrm_state *x)
 		x->km.state = XFRM_STATE_DEAD;
 		spin_lock(&net->xfrm.xfrm_state_lock);
 		list_del(&x->km.all);
-		hlist_del(&x->bydst);
-		hlist_del(&x->bysrc);
+		hlist_del_rcu(&x->bydst);
+		hlist_del_rcu(&x->bysrc);
 		if (x->id.spi)
-			hlist_del(&x->byspi);
+			hlist_del_rcu(&x->byspi);
 		net->xfrm.state_num--;
 		spin_unlock(&net->xfrm.xfrm_state_lock);
 
@@ -659,7 +659,7 @@ static struct xfrm_state *__xfrm_state_lookup(struct net *net, u32 mark,
 	unsigned int h = xfrm_spi_hash(net, daddr, spi, proto, family);
 	struct xfrm_state *x;
 
-	hlist_for_each_entry(x, net->xfrm.state_byspi+h, byspi) {
+	hlist_for_each_entry_rcu(x, net->xfrm.state_byspi + h, byspi) {
 		if (x->props.family != family ||
 		    x->id.spi       != spi ||
 		    x->id.proto     != proto ||
@@ -683,7 +683,7 @@ static struct xfrm_state *__xfrm_state_lookup_byaddr(struct net *net, u32 mark,
 	unsigned int h = xfrm_src_hash(net, daddr, saddr, family);
 	struct xfrm_state *x;
 
-	hlist_for_each_entry(x, net->xfrm.state_bysrc+h, bysrc) {
+	hlist_for_each_entry_rcu(x, net->xfrm.state_bysrc + h, bysrc) {
 		if (x->props.family != family ||
 		    x->id.proto     != proto ||
 		    !xfrm_addr_equal(&x->id.daddr, daddr, family) ||
@@ -781,7 +781,7 @@ xfrm_state_find(const xfrm_address_t *daddr, const xfrm_address_t *saddr,
 
 	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 	h = xfrm_dst_hash(net, daddr, saddr, tmpl->reqid, encap_family);
-	hlist_for_each_entry(x, net->xfrm.state_bydst+h, bydst) {
+	hlist_for_each_entry_rcu(x, net->xfrm.state_bydst + h, bydst) {
 		if (x->props.family == encap_family &&
 		    x->props.reqid == tmpl->reqid &&
 		    (mark & x->mark.m) == x->mark.v &&
@@ -797,7 +797,7 @@ xfrm_state_find(const xfrm_address_t *daddr, const xfrm_address_t *saddr,
 		goto found;
 
 	h_wildcard = xfrm_dst_hash(net, daddr, &saddr_wildcard, tmpl->reqid, encap_family);
-	hlist_for_each_entry(x, net->xfrm.state_bydst+h_wildcard, bydst) {
+	hlist_for_each_entry_rcu(x, net->xfrm.state_bydst + h_wildcard, bydst) {
 		if (x->props.family == encap_family &&
 		    x->props.reqid == tmpl->reqid &&
 		    (mark & x->mark.m) == x->mark.v &&
@@ -852,12 +852,12 @@ found:
 		if (km_query(x, tmpl, pol) == 0) {
 			x->km.state = XFRM_STATE_ACQ;
 			list_add(&x->km.all, &net->xfrm.state_all);
-			hlist_add_head(&x->bydst, net->xfrm.state_bydst+h);
+			hlist_add_head_rcu(&x->bydst, net->xfrm.state_bydst + h);
 			h = xfrm_src_hash(net, daddr, saddr, encap_family);
-			hlist_add_head(&x->bysrc, net->xfrm.state_bysrc+h);
+			hlist_add_head_rcu(&x->bysrc, net->xfrm.state_bysrc + h);
 			if (x->id.spi) {
 				h = xfrm_spi_hash(net, &x->id.daddr, x->id.spi, x->id.proto, encap_family);
-				hlist_add_head(&x->byspi, net->xfrm.state_byspi+h);
+				hlist_add_head_rcu(&x->byspi, net->xfrm.state_byspi + h);
 			}
 			x->lft.hard_add_expires_seconds = net->xfrm.sysctl_acq_expires;
 			tasklet_hrtimer_start(&x->mtimer, ktime_set(net->xfrm.sysctl_acq_expires, 0), HRTIMER_MODE_REL);
@@ -945,16 +945,16 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 
 	h = xfrm_dst_hash(net, &x->id.daddr, &x->props.saddr,
 			  x->props.reqid, x->props.family);
-	hlist_add_head(&x->bydst, net->xfrm.state_bydst+h);
+	hlist_add_head_rcu(&x->bydst, net->xfrm.state_bydst + h);
 
 	h = xfrm_src_hash(net, &x->id.daddr, &x->props.saddr, x->props.family);
-	hlist_add_head(&x->bysrc, net->xfrm.state_bysrc+h);
+	hlist_add_head_rcu(&x->bysrc, net->xfrm.state_bysrc + h);
 
 	if (x->id.spi) {
 		h = xfrm_spi_hash(net, &x->id.daddr, x->id.spi, x->id.proto,
 				  x->props.family);
 
-		hlist_add_head(&x->byspi, net->xfrm.state_byspi+h);
+		hlist_add_head_rcu(&x->byspi, net->xfrm.state_byspi + h);
 	}
 
 	tasklet_hrtimer_start(&x->mtimer, ktime_set(1, 0), HRTIMER_MODE_REL);
@@ -1063,9 +1063,9 @@ static struct xfrm_state *__find_acq_core(struct net *net,
 		xfrm_state_hold(x);
 		tasklet_hrtimer_start(&x->mtimer, ktime_set(net->xfrm.sysctl_acq_expires, 0), HRTIMER_MODE_REL);
 		list_add(&x->km.all, &net->xfrm.state_all);
-		hlist_add_head(&x->bydst, net->xfrm.state_bydst+h);
+		hlist_add_head_rcu(&x->bydst, net->xfrm.state_bydst + h);
 		h = xfrm_src_hash(net, daddr, saddr, family);
-		hlist_add_head(&x->bysrc, net->xfrm.state_bysrc+h);
+		hlist_add_head_rcu(&x->bysrc, net->xfrm.state_bysrc + h);
 
 		net->xfrm.state_num++;
 
@@ -1581,7 +1581,7 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 	if (x->id.spi) {
 		spin_lock_bh(&net->xfrm.xfrm_state_lock);
 		h = xfrm_spi_hash(net, &x->id.daddr, x->id.spi, x->id.proto, x->props.family);
-		hlist_add_head(&x->byspi, net->xfrm.state_byspi+h);
+		hlist_add_head_rcu(&x->byspi, net->xfrm.state_byspi + h);
 		spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 
 		err = 0;
-- 
2.7.3
