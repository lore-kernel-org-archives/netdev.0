From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 22/53] netns xfrm: propagate netns into bydst/bysrc/byspi hash functions
Date: Tue, 25 Nov 2008 20:26:54 +0300
Message-ID: <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:3932 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753614AbYKYRY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:24:29 -0500
Received: by nf-out-0910.google.com with SMTP id d3so28136nfc.21
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:24:27 -0800 (PST)
In-Reply-To: <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 net/xfrm/xfrm_state.c |   44 +++++++++++++++++++++++---------------------
 1 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 24bd89e..72b2956 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -57,25 +57,27 @@ static void xfrm_audit_state_replay(struct xfrm_state *x,
 #define xfrm_audit_state_replay(x, s, sq)	do { ; } while (0)
 #endif /* CONFIG_AUDITSYSCALL */
 
-static inline unsigned int xfrm_dst_hash(xfrm_address_t *daddr,
+static inline unsigned int xfrm_dst_hash(struct net *net,
+					 xfrm_address_t *daddr,
 					 xfrm_address_t *saddr,
 					 u32 reqid,
 					 unsigned short family)
 {
-	return __xfrm_dst_hash(daddr, saddr, reqid, family, init_net.xfrm.state_hmask);
+	return __xfrm_dst_hash(daddr, saddr, reqid, family, net->xfrm.state_hmask);
 }
 
-static inline unsigned int xfrm_src_hash(xfrm_address_t *daddr,
+static inline unsigned int xfrm_src_hash(struct net *net,
+					 xfrm_address_t *daddr,
 					 xfrm_address_t *saddr,
 					 unsigned short family)
 {
-	return __xfrm_src_hash(daddr, saddr, family, init_net.xfrm.state_hmask);
+	return __xfrm_src_hash(daddr, saddr, family, net->xfrm.state_hmask);
 }
 
 static inline unsigned int
-xfrm_spi_hash(xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned short family)
+xfrm_spi_hash(struct net *net, xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned short family)
 {
-	return __xfrm_spi_hash(daddr, spi, proto, family, init_net.xfrm.state_hmask);
+	return __xfrm_spi_hash(daddr, spi, proto, family, net->xfrm.state_hmask);
 }
 
 static void xfrm_hash_transfer(struct hlist_head *list,
@@ -666,7 +668,7 @@ xfrm_init_tempsel(struct xfrm_state *x, struct flowi *fl,
 
 static struct xfrm_state *__xfrm_state_lookup(xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned short family)
 {
-	unsigned int h = xfrm_spi_hash(daddr, spi, proto, family);
+	unsigned int h = xfrm_spi_hash(&init_net, daddr, spi, proto, family);
 	struct xfrm_state *x;
 	struct hlist_node *entry;
 
@@ -698,7 +700,7 @@ static struct xfrm_state *__xfrm_state_lookup(xfrm_address_t *daddr, __be32 spi,
 
 static struct xfrm_state *__xfrm_state_lookup_byaddr(xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto, unsigned short family)
 {
-	unsigned int h = xfrm_src_hash(daddr, saddr, family);
+	unsigned int h = xfrm_src_hash(&init_net, daddr, saddr, family);
 	struct xfrm_state *x;
 	struct hlist_node *entry;
 
@@ -767,7 +769,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 	to_put = NULL;
 
 	spin_lock_bh(&xfrm_state_lock);
-	h = xfrm_dst_hash(daddr, saddr, tmpl->reqid, family);
+	h = xfrm_dst_hash(&init_net, daddr, saddr, tmpl->reqid, family);
 	hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+h, bydst) {
 		if (x->props.family == family &&
 		    x->props.reqid == tmpl->reqid &&
@@ -839,10 +841,10 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 			x->km.state = XFRM_STATE_ACQ;
 			list_add(&x->km.all, &init_net.xfrm.state_all);
 			hlist_add_head(&x->bydst, init_net.xfrm.state_bydst+h);
-			h = xfrm_src_hash(daddr, saddr, family);
+			h = xfrm_src_hash(&init_net, daddr, saddr, family);
 			hlist_add_head(&x->bysrc, init_net.xfrm.state_bysrc+h);
 			if (x->id.spi) {
-				h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, family);
+				h = xfrm_spi_hash(&init_net, &x->id.daddr, x->id.spi, x->id.proto, family);
 				hlist_add_head(&x->byspi, init_net.xfrm.state_byspi+h);
 			}
 			x->lft.hard_add_expires_seconds = sysctl_xfrm_acq_expires;
@@ -877,7 +879,7 @@ xfrm_stateonly_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 	struct hlist_node *entry;
 
 	spin_lock(&xfrm_state_lock);
-	h = xfrm_dst_hash(daddr, saddr, reqid, family);
+	h = xfrm_dst_hash(&init_net, daddr, saddr, reqid, family);
 	hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+h, bydst) {
 		if (x->props.family == family &&
 		    x->props.reqid == reqid &&
@@ -908,15 +910,15 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 
 	list_add(&x->km.all, &init_net.xfrm.state_all);
 
-	h = xfrm_dst_hash(&x->id.daddr, &x->props.saddr,
+	h = xfrm_dst_hash(&init_net, &x->id.daddr, &x->props.saddr,
 			  x->props.reqid, x->props.family);
 	hlist_add_head(&x->bydst, init_net.xfrm.state_bydst+h);
 
-	h = xfrm_src_hash(&x->id.daddr, &x->props.saddr, x->props.family);
+	h = xfrm_src_hash(&init_net, &x->id.daddr, &x->props.saddr, x->props.family);
 	hlist_add_head(&x->bysrc, init_net.xfrm.state_bysrc+h);
 
 	if (x->id.spi) {
-		h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto,
+		h = xfrm_spi_hash(&init_net, &x->id.daddr, x->id.spi, x->id.proto,
 				  x->props.family);
 
 		hlist_add_head(&x->byspi, init_net.xfrm.state_byspi+h);
@@ -942,7 +944,7 @@ static void __xfrm_state_bump_genids(struct xfrm_state *xnew)
 	struct hlist_node *entry;
 	unsigned int h;
 
-	h = xfrm_dst_hash(&xnew->id.daddr, &xnew->props.saddr, reqid, family);
+	h = xfrm_dst_hash(&init_net, &xnew->id.daddr, &xnew->props.saddr, reqid, family);
 	hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+h, bydst) {
 		if (x->props.family	== family &&
 		    x->props.reqid	== reqid &&
@@ -964,7 +966,7 @@ EXPORT_SYMBOL(xfrm_state_insert);
 /* xfrm_state_lock is held */
 static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 reqid, u8 proto, xfrm_address_t *daddr, xfrm_address_t *saddr, int create)
 {
-	unsigned int h = xfrm_dst_hash(daddr, saddr, reqid, family);
+	unsigned int h = xfrm_dst_hash(&init_net, daddr, saddr, reqid, family);
 	struct hlist_node *entry;
 	struct xfrm_state *x;
 
@@ -1037,7 +1039,7 @@ static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 re
 		add_timer(&x->timer);
 		list_add(&x->km.all, &init_net.xfrm.state_all);
 		hlist_add_head(&x->bydst, init_net.xfrm.state_bydst+h);
-		h = xfrm_src_hash(daddr, saddr, family);
+		h = xfrm_src_hash(&init_net, daddr, saddr, family);
 		hlist_add_head(&x->bysrc, init_net.xfrm.state_bysrc+h);
 
 		init_net.xfrm.state_num++;
@@ -1189,7 +1191,7 @@ struct xfrm_state * xfrm_migrate_state_find(struct xfrm_migrate *m)
 	struct hlist_node *entry;
 
 	if (m->reqid) {
-		h = xfrm_dst_hash(&m->old_daddr, &m->old_saddr,
+		h = xfrm_dst_hash(&init_net, &m->old_daddr, &m->old_saddr,
 				  m->reqid, m->old_family);
 		hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+h, bydst) {
 			if (x->props.mode != m->mode ||
@@ -1206,7 +1208,7 @@ struct xfrm_state * xfrm_migrate_state_find(struct xfrm_migrate *m)
 			return x;
 		}
 	} else {
-		h = xfrm_src_hash(&m->old_daddr, &m->old_saddr,
+		h = xfrm_src_hash(&init_net, &m->old_daddr, &m->old_saddr,
 				  m->old_family);
 		hlist_for_each_entry(x, entry, init_net.xfrm.state_bysrc+h, bysrc) {
 			if (x->props.mode != m->mode ||
@@ -1514,7 +1516,7 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 	}
 	if (x->id.spi) {
 		spin_lock_bh(&xfrm_state_lock);
-		h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, x->props.family);
+		h = xfrm_spi_hash(&init_net, &x->id.daddr, x->id.spi, x->id.proto, x->props.family);
 		hlist_add_head(&x->byspi, init_net.xfrm.state_byspi+h);
 		spin_unlock_bh(&xfrm_state_lock);
 
-- 
1.5.6.5

