From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 08/53] netns xfrm: per-netns xfrm_state_hmask
Date: Tue, 25 Nov 2008 20:26:40 +0300
Message-ID: <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:4839 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753689AbYKYRXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:23:50 -0500
Received: by nf-out-0910.google.com with SMTP id d3so28104nfc.21
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:23:49 -0800 (PST)
In-Reply-To: <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since hashtables are per-netns, they can be independently resized.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/netns/xfrm.h |    1 +
 net/xfrm/xfrm_state.c    |   31 +++++++++++++++----------------
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index b05ca3f..dbbc0e9 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -16,6 +16,7 @@ struct netns_xfrm {
 	struct hlist_head	*state_bydst;
 	struct hlist_head	*state_bysrc;
 	struct hlist_head	*state_byspi;
+	unsigned int		state_hmask;
 };
 
 #endif
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 66ca1ef..de08ed9 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -44,7 +44,6 @@ u32 sysctl_xfrm_acq_expires __read_mostly = 30;
 
 static DEFINE_SPINLOCK(xfrm_state_lock);
 
-static unsigned int xfrm_state_hmask __read_mostly;
 static unsigned int xfrm_state_hashmax __read_mostly = 1 * 1024 * 1024;
 static unsigned int xfrm_state_num;
 static unsigned int xfrm_state_genid;
@@ -64,20 +63,20 @@ static inline unsigned int xfrm_dst_hash(xfrm_address_t *daddr,
 					 u32 reqid,
 					 unsigned short family)
 {
-	return __xfrm_dst_hash(daddr, saddr, reqid, family, xfrm_state_hmask);
+	return __xfrm_dst_hash(daddr, saddr, reqid, family, init_net.xfrm.state_hmask);
 }
 
 static inline unsigned int xfrm_src_hash(xfrm_address_t *daddr,
 					 xfrm_address_t *saddr,
 					 unsigned short family)
 {
-	return __xfrm_src_hash(daddr, saddr, family, xfrm_state_hmask);
+	return __xfrm_src_hash(daddr, saddr, family, init_net.xfrm.state_hmask);
 }
 
 static inline unsigned int
 xfrm_spi_hash(xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned short family)
 {
-	return __xfrm_spi_hash(daddr, spi, proto, family, xfrm_state_hmask);
+	return __xfrm_spi_hash(daddr, spi, proto, family, init_net.xfrm.state_hmask);
 }
 
 static void xfrm_hash_transfer(struct hlist_head *list,
@@ -113,7 +112,7 @@ static void xfrm_hash_transfer(struct hlist_head *list,
 
 static unsigned long xfrm_hash_new_size(void)
 {
-	return ((xfrm_state_hmask + 1) << 1) *
+	return ((init_net.xfrm.state_hmask + 1) << 1) *
 		sizeof(struct hlist_head);
 }
 
@@ -147,19 +146,19 @@ static void xfrm_hash_resize(struct work_struct *__unused)
 	spin_lock_bh(&xfrm_state_lock);
 
 	nhashmask = (nsize / sizeof(struct hlist_head)) - 1U;
-	for (i = xfrm_state_hmask; i >= 0; i--)
+	for (i = init_net.xfrm.state_hmask; i >= 0; i--)
 		xfrm_hash_transfer(init_net.xfrm.state_bydst+i, ndst, nsrc, nspi,
 				   nhashmask);
 
 	odst = init_net.xfrm.state_bydst;
 	osrc = init_net.xfrm.state_bysrc;
 	ospi = init_net.xfrm.state_byspi;
-	ohashmask = xfrm_state_hmask;
+	ohashmask = init_net.xfrm.state_hmask;
 
 	init_net.xfrm.state_bydst = ndst;
 	init_net.xfrm.state_bysrc = nsrc;
 	init_net.xfrm.state_byspi = nspi;
-	xfrm_state_hmask = nhashmask;
+	init_net.xfrm.state_hmask = nhashmask;
 
 	spin_unlock_bh(&xfrm_state_lock);
 
@@ -582,7 +581,7 @@ xfrm_state_flush_secctx_check(u8 proto, struct xfrm_audit *audit_info)
 {
 	int i, err = 0;
 
-	for (i = 0; i <= xfrm_state_hmask; i++) {
+	for (i = 0; i <= init_net.xfrm.state_hmask; i++) {
 		struct hlist_node *entry;
 		struct xfrm_state *x;
 
@@ -617,7 +616,7 @@ int xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info)
 	if (err)
 		goto out;
 
-	for (i = 0; i <= xfrm_state_hmask; i++) {
+	for (i = 0; i <= init_net.xfrm.state_hmask; i++) {
 		struct hlist_node *entry;
 		struct xfrm_state *x;
 restart:
@@ -652,7 +651,7 @@ void xfrm_sad_getinfo(struct xfrmk_sadinfo *si)
 {
 	spin_lock_bh(&xfrm_state_lock);
 	si->sadcnt = xfrm_state_num;
-	si->sadhcnt = xfrm_state_hmask;
+	si->sadhcnt = init_net.xfrm.state_hmask;
 	si->sadhmcnt = xfrm_state_hashmax;
 	spin_unlock_bh(&xfrm_state_lock);
 }
@@ -754,8 +753,8 @@ __xfrm_state_locate(struct xfrm_state *x, int use_spi, int family)
 static void xfrm_hash_grow_check(int have_hash_collision)
 {
 	if (have_hash_collision &&
-	    (xfrm_state_hmask + 1) < xfrm_state_hashmax &&
-	    xfrm_state_num > xfrm_state_hmask)
+	    (init_net.xfrm.state_hmask + 1) < xfrm_state_hashmax &&
+	    xfrm_state_num > init_net.xfrm.state_hmask)
 		schedule_work(&xfrm_hash_work);
 }
 
@@ -1444,7 +1443,7 @@ static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq)
 {
 	int i;
 
-	for (i = 0; i <= xfrm_state_hmask; i++) {
+	for (i = 0; i <= init_net.xfrm.state_hmask; i++) {
 		struct hlist_node *entry;
 		struct xfrm_state *x;
 
@@ -2088,7 +2087,7 @@ int __net_init xfrm_state_init(struct net *net)
 	net->xfrm.state_byspi = xfrm_hash_alloc(sz);
 	if (!net->xfrm.state_byspi)
 		goto out_byspi;
-	xfrm_state_hmask = ((sz / sizeof(struct hlist_head)) - 1);
+	net->xfrm.state_hmask = ((sz / sizeof(struct hlist_head)) - 1);
 
 	INIT_WORK(&xfrm_state_gc_work, xfrm_state_gc_task);
 	return 0;
@@ -2107,7 +2106,7 @@ void xfrm_state_fini(struct net *net)
 
 	WARN_ON(!list_empty(&net->xfrm.state_all));
 
-	sz = (xfrm_state_hmask + 1) * sizeof(struct hlist_head);
+	sz = (net->xfrm.state_hmask + 1) * sizeof(struct hlist_head);
 	WARN_ON(!hlist_empty(net->xfrm.state_byspi));
 	xfrm_hash_free(net->xfrm.state_byspi, sz);
 	WARN_ON(!hlist_empty(net->xfrm.state_bysrc));
-- 
1.5.6.5

