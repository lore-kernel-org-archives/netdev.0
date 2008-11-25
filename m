From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 06/53] netns xfrm: per-netns xfrm_state_bysrc hash
Date: Tue, 25 Nov 2008 20:26:38 +0300
Message-ID: <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:4839 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754377AbYKYRXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:23:46 -0500
Received: by nf-out-0910.google.com with SMTP id d3so28104nfc.21
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:23:44 -0800 (PST)
In-Reply-To: <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/netns/xfrm.h |    1 +
 net/xfrm/xfrm_state.c    |   23 ++++++++++++++---------
 2 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 02487b3..bfcd5a3 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -14,6 +14,7 @@ struct netns_xfrm {
 	 * offending SA.
 	 */
 	struct hlist_head	*state_bydst;
+	struct hlist_head	*state_bysrc;
 };
 
 #endif
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 08b7889..52d828b 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -44,7 +44,6 @@ u32 sysctl_xfrm_acq_expires __read_mostly = 30;
 
 static DEFINE_SPINLOCK(xfrm_state_lock);
 
-static struct hlist_head *xfrm_state_bysrc __read_mostly;
 static struct hlist_head *xfrm_state_byspi __read_mostly;
 static unsigned int xfrm_state_hmask __read_mostly;
 static unsigned int xfrm_state_hashmax __read_mostly = 1 * 1024 * 1024;
@@ -154,12 +153,12 @@ static void xfrm_hash_resize(struct work_struct *__unused)
 				   nhashmask);
 
 	odst = init_net.xfrm.state_bydst;
-	osrc = xfrm_state_bysrc;
+	osrc = init_net.xfrm.state_bysrc;
 	ospi = xfrm_state_byspi;
 	ohashmask = xfrm_state_hmask;
 
 	init_net.xfrm.state_bydst = ndst;
-	xfrm_state_bysrc = nsrc;
+	init_net.xfrm.state_bysrc = nsrc;
 	xfrm_state_byspi = nspi;
 	xfrm_state_hmask = nhashmask;
 
@@ -712,7 +711,7 @@ static struct xfrm_state *__xfrm_state_lookup_byaddr(xfrm_address_t *daddr, xfrm
 	struct xfrm_state *x;
 	struct hlist_node *entry;
 
-	hlist_for_each_entry(x, entry, xfrm_state_bysrc+h, bysrc) {
+	hlist_for_each_entry(x, entry, init_net.xfrm.state_bysrc+h, bysrc) {
 		if (x->props.family != family ||
 		    x->id.proto     != proto)
 			continue;
@@ -850,7 +849,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 			list_add(&x->km.all, &init_net.xfrm.state_all);
 			hlist_add_head(&x->bydst, init_net.xfrm.state_bydst+h);
 			h = xfrm_src_hash(daddr, saddr, family);
-			hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
+			hlist_add_head(&x->bysrc, init_net.xfrm.state_bysrc+h);
 			if (x->id.spi) {
 				h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, family);
 				hlist_add_head(&x->byspi, xfrm_state_byspi+h);
@@ -923,7 +922,7 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 	hlist_add_head(&x->bydst, init_net.xfrm.state_bydst+h);
 
 	h = xfrm_src_hash(&x->id.daddr, &x->props.saddr, x->props.family);
-	hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
+	hlist_add_head(&x->bysrc, init_net.xfrm.state_bysrc+h);
 
 	if (x->id.spi) {
 		h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto,
@@ -1048,7 +1047,7 @@ static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 re
 		list_add(&x->km.all, &init_net.xfrm.state_all);
 		hlist_add_head(&x->bydst, init_net.xfrm.state_bydst+h);
 		h = xfrm_src_hash(daddr, saddr, family);
-		hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
+		hlist_add_head(&x->bysrc, init_net.xfrm.state_bysrc+h);
 
 		xfrm_state_num++;
 
@@ -1218,7 +1217,7 @@ struct xfrm_state * xfrm_migrate_state_find(struct xfrm_migrate *m)
 	} else {
 		h = xfrm_src_hash(&m->old_daddr, &m->old_saddr,
 				  m->old_family);
-		hlist_for_each_entry(x, entry, xfrm_state_bysrc+h, bysrc) {
+		hlist_for_each_entry(x, entry, init_net.xfrm.state_bysrc+h, bysrc) {
 			if (x->props.mode != m->mode ||
 			    x->id.proto != m->proto)
 				continue;
@@ -2084,13 +2083,17 @@ int __net_init xfrm_state_init(struct net *net)
 	net->xfrm.state_bydst = xfrm_hash_alloc(sz);
 	if (!net->xfrm.state_bydst)
 		goto out_bydst;
-	xfrm_state_bysrc = xfrm_hash_alloc(sz);
+	net->xfrm.state_bysrc = xfrm_hash_alloc(sz);
+	if (!net->xfrm.state_bysrc)
+		goto out_bysrc;
 	xfrm_state_byspi = xfrm_hash_alloc(sz);
 	xfrm_state_hmask = ((sz / sizeof(struct hlist_head)) - 1);
 
 	INIT_WORK(&xfrm_state_gc_work, xfrm_state_gc_task);
 	return 0;
 
+out_bysrc:
+	xfrm_hash_free(net->xfrm.state_bydst, sz);
 out_bydst:
 	return -ENOMEM;
 }
@@ -2102,6 +2105,8 @@ void xfrm_state_fini(struct net *net)
 	WARN_ON(!list_empty(&net->xfrm.state_all));
 
 	sz = (xfrm_state_hmask + 1) * sizeof(struct hlist_head);
+	WARN_ON(!hlist_empty(net->xfrm.state_bysrc));
+	xfrm_hash_free(net->xfrm.state_bysrc, sz);
 	WARN_ON(!hlist_empty(net->xfrm.state_bydst));
 	xfrm_hash_free(net->xfrm.state_bydst, sz);
 }
-- 
1.5.6.5

