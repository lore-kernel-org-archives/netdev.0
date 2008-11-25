From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 05/53] netns xfrm: per-netns xfrm_state_bydst hash
Date: Tue, 25 Nov 2008 20:26:37 +0300
Message-ID: <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:40948 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754371AbYKYRXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:23:42 -0500
Received: by ey-out-2122.google.com with SMTP id 6so23228eyi.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:23:41 -0800 (PST)
In-Reply-To: <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/netns/xfrm.h |    9 ++++++++
 net/xfrm/xfrm_state.c    |   50 +++++++++++++++++++++++----------------------
 2 files changed, 35 insertions(+), 24 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 6ae234a..02487b3 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -5,6 +5,15 @@
 
 struct netns_xfrm {
 	struct list_head	state_all;
+	/*
+	 * Hash table to find appropriate SA towards given target (endpoint of
+	 * tunnel or destination of transport mode) allowed by selector.
+	 *
+	 * Main use is finding SA after policy selected tunnel or transport
+	 * mode. Also, it can be used by ah/esp icmp error handler to find
+	 * offending SA.
+	 */
+	struct hlist_head	*state_bydst;
 };
 
 #endif
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 85bb854..08b7889 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -44,13 +44,6 @@ u32 sysctl_xfrm_acq_expires __read_mostly = 30;
 
 static DEFINE_SPINLOCK(xfrm_state_lock);
 
-/* Hash table to find appropriate SA towards given target (endpoint
- * of tunnel or destination of transport mode) allowed by selector.
- *
- * Main use is finding SA after policy selected tunnel or transport mode.
- * Also, it can be used by ah/esp icmp error handler to find offending SA.
- */
-static struct hlist_head *xfrm_state_bydst __read_mostly;
 static struct hlist_head *xfrm_state_bysrc __read_mostly;
 static struct hlist_head *xfrm_state_byspi __read_mostly;
 static unsigned int xfrm_state_hmask __read_mostly;
@@ -157,15 +150,15 @@ static void xfrm_hash_resize(struct work_struct *__unused)
 
 	nhashmask = (nsize / sizeof(struct hlist_head)) - 1U;
 	for (i = xfrm_state_hmask; i >= 0; i--)
-		xfrm_hash_transfer(xfrm_state_bydst+i, ndst, nsrc, nspi,
+		xfrm_hash_transfer(init_net.xfrm.state_bydst+i, ndst, nsrc, nspi,
 				   nhashmask);
 
-	odst = xfrm_state_bydst;
+	odst = init_net.xfrm.state_bydst;
 	osrc = xfrm_state_bysrc;
 	ospi = xfrm_state_byspi;
 	ohashmask = xfrm_state_hmask;
 
-	xfrm_state_bydst = ndst;
+	init_net.xfrm.state_bydst = ndst;
 	xfrm_state_bysrc = nsrc;
 	xfrm_state_byspi = nspi;
 	xfrm_state_hmask = nhashmask;
@@ -595,7 +588,7 @@ xfrm_state_flush_secctx_check(u8 proto, struct xfrm_audit *audit_info)
 		struct hlist_node *entry;
 		struct xfrm_state *x;
 
-		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
+		hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+i, bydst) {
 			if (xfrm_id_proto_match(x->id.proto, proto) &&
 			   (err = security_xfrm_state_delete(x)) != 0) {
 				xfrm_audit_state_delete(x, 0,
@@ -630,7 +623,7 @@ int xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info)
 		struct hlist_node *entry;
 		struct xfrm_state *x;
 restart:
-		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
+		hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+i, bydst) {
 			if (!xfrm_state_kern(x) &&
 			    xfrm_id_proto_match(x->id.proto, proto)) {
 				xfrm_state_hold(x);
@@ -785,7 +778,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 
 	spin_lock_bh(&xfrm_state_lock);
 	h = xfrm_dst_hash(daddr, saddr, tmpl->reqid, family);
-	hlist_for_each_entry(x, entry, xfrm_state_bydst+h, bydst) {
+	hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+h, bydst) {
 		if (x->props.family == family &&
 		    x->props.reqid == tmpl->reqid &&
 		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
@@ -855,7 +848,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 		if (km_query(x, tmpl, pol) == 0) {
 			x->km.state = XFRM_STATE_ACQ;
 			list_add(&x->km.all, &init_net.xfrm.state_all);
-			hlist_add_head(&x->bydst, xfrm_state_bydst+h);
+			hlist_add_head(&x->bydst, init_net.xfrm.state_bydst+h);
 			h = xfrm_src_hash(daddr, saddr, family);
 			hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
 			if (x->id.spi) {
@@ -895,7 +888,7 @@ xfrm_stateonly_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 
 	spin_lock(&xfrm_state_lock);
 	h = xfrm_dst_hash(daddr, saddr, reqid, family);
-	hlist_for_each_entry(x, entry, xfrm_state_bydst+h, bydst) {
+	hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+h, bydst) {
 		if (x->props.family == family &&
 		    x->props.reqid == reqid &&
 		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
@@ -927,7 +920,7 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 
 	h = xfrm_dst_hash(&x->id.daddr, &x->props.saddr,
 			  x->props.reqid, x->props.family);
-	hlist_add_head(&x->bydst, xfrm_state_bydst+h);
+	hlist_add_head(&x->bydst, init_net.xfrm.state_bydst+h);
 
 	h = xfrm_src_hash(&x->id.daddr, &x->props.saddr, x->props.family);
 	hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
@@ -960,7 +953,7 @@ static void __xfrm_state_bump_genids(struct xfrm_state *xnew)
 	unsigned int h;
 
 	h = xfrm_dst_hash(&xnew->id.daddr, &xnew->props.saddr, reqid, family);
-	hlist_for_each_entry(x, entry, xfrm_state_bydst+h, bydst) {
+	hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+h, bydst) {
 		if (x->props.family	== family &&
 		    x->props.reqid	== reqid &&
 		    !xfrm_addr_cmp(&x->id.daddr, &xnew->id.daddr, family) &&
@@ -985,7 +978,7 @@ static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 re
 	struct hlist_node *entry;
 	struct xfrm_state *x;
 
-	hlist_for_each_entry(x, entry, xfrm_state_bydst+h, bydst) {
+	hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+h, bydst) {
 		if (x->props.reqid  != reqid ||
 		    x->props.mode   != mode ||
 		    x->props.family != family ||
@@ -1053,7 +1046,7 @@ static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 re
 		x->timer.expires = jiffies + sysctl_xfrm_acq_expires*HZ;
 		add_timer(&x->timer);
 		list_add(&x->km.all, &init_net.xfrm.state_all);
-		hlist_add_head(&x->bydst, xfrm_state_bydst+h);
+		hlist_add_head(&x->bydst, init_net.xfrm.state_bydst+h);
 		h = xfrm_src_hash(daddr, saddr, family);
 		hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
 
@@ -1208,7 +1201,7 @@ struct xfrm_state * xfrm_migrate_state_find(struct xfrm_migrate *m)
 	if (m->reqid) {
 		h = xfrm_dst_hash(&m->old_daddr, &m->old_saddr,
 				  m->reqid, m->old_family);
-		hlist_for_each_entry(x, entry, xfrm_state_bydst+h, bydst) {
+		hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+h, bydst) {
 			if (x->props.mode != m->mode ||
 			    x->id.proto != m->proto)
 				continue;
@@ -1457,7 +1450,7 @@ static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq)
 		struct hlist_node *entry;
 		struct xfrm_state *x;
 
-		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
+		hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+i, bydst) {
 			if (x->km.seq == seq &&
 			    x->km.state == XFRM_STATE_ACQ) {
 				xfrm_state_hold(x);
@@ -2088,20 +2081,29 @@ int __net_init xfrm_state_init(struct net *net)
 
 	sz = sizeof(struct hlist_head) * 8;
 
-	xfrm_state_bydst = xfrm_hash_alloc(sz);
+	net->xfrm.state_bydst = xfrm_hash_alloc(sz);
+	if (!net->xfrm.state_bydst)
+		goto out_bydst;
 	xfrm_state_bysrc = xfrm_hash_alloc(sz);
 	xfrm_state_byspi = xfrm_hash_alloc(sz);
-	if (!xfrm_state_bydst || !xfrm_state_bysrc || !xfrm_state_byspi)
-		panic("XFRM: Cannot allocate bydst/bysrc/byspi hashes.");
 	xfrm_state_hmask = ((sz / sizeof(struct hlist_head)) - 1);
 
 	INIT_WORK(&xfrm_state_gc_work, xfrm_state_gc_task);
 	return 0;
+
+out_bydst:
+	return -ENOMEM;
 }
 
 void xfrm_state_fini(struct net *net)
 {
+	unsigned int sz;
+
 	WARN_ON(!list_empty(&net->xfrm.state_all));
+
+	sz = (xfrm_state_hmask + 1) * sizeof(struct hlist_head);
+	WARN_ON(!hlist_empty(net->xfrm.state_bydst));
+	xfrm_hash_free(net->xfrm.state_bydst, sz);
 }
 
 #ifdef CONFIG_AUDITSYSCALL
-- 
1.5.6.5

