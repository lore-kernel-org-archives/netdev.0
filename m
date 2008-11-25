From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 07/53] netns xfrm: per-netns xfrm_state_byspi hash
Date: Tue, 25 Nov 2008 20:26:39 +0300
Message-ID: <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:41337 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754371AbYKYRXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:23:48 -0500
Received: by ey-out-2122.google.com with SMTP id 6so23232eyi.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:23:46 -0800 (PST)
In-Reply-To: <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/netns/xfrm.h |    1 +
 net/xfrm/xfrm_state.c    |   21 +++++++++++++--------
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index bfcd5a3..b05ca3f 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -15,6 +15,7 @@ struct netns_xfrm {
 	 */
 	struct hlist_head	*state_bydst;
 	struct hlist_head	*state_bysrc;
+	struct hlist_head	*state_byspi;
 };
 
 #endif
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 52d828b..66ca1ef 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -44,7 +44,6 @@ u32 sysctl_xfrm_acq_expires __read_mostly = 30;
 
 static DEFINE_SPINLOCK(xfrm_state_lock);
 
-static struct hlist_head *xfrm_state_byspi __read_mostly;
 static unsigned int xfrm_state_hmask __read_mostly;
 static unsigned int xfrm_state_hashmax __read_mostly = 1 * 1024 * 1024;
 static unsigned int xfrm_state_num;
@@ -154,12 +153,12 @@ static void xfrm_hash_resize(struct work_struct *__unused)
 
 	odst = init_net.xfrm.state_bydst;
 	osrc = init_net.xfrm.state_bysrc;
-	ospi = xfrm_state_byspi;
+	ospi = init_net.xfrm.state_byspi;
 	ohashmask = xfrm_state_hmask;
 
 	init_net.xfrm.state_bydst = ndst;
 	init_net.xfrm.state_bysrc = nsrc;
-	xfrm_state_byspi = nspi;
+	init_net.xfrm.state_byspi = nspi;
 	xfrm_state_hmask = nhashmask;
 
 	spin_unlock_bh(&xfrm_state_lock);
@@ -679,7 +678,7 @@ static struct xfrm_state *__xfrm_state_lookup(xfrm_address_t *daddr, __be32 spi,
 	struct xfrm_state *x;
 	struct hlist_node *entry;
 
-	hlist_for_each_entry(x, entry, xfrm_state_byspi+h, byspi) {
+	hlist_for_each_entry(x, entry, init_net.xfrm.state_byspi+h, byspi) {
 		if (x->props.family != family ||
 		    x->id.spi       != spi ||
 		    x->id.proto     != proto)
@@ -852,7 +851,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 			hlist_add_head(&x->bysrc, init_net.xfrm.state_bysrc+h);
 			if (x->id.spi) {
 				h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, family);
-				hlist_add_head(&x->byspi, xfrm_state_byspi+h);
+				hlist_add_head(&x->byspi, init_net.xfrm.state_byspi+h);
 			}
 			x->lft.hard_add_expires_seconds = sysctl_xfrm_acq_expires;
 			x->timer.expires = jiffies + sysctl_xfrm_acq_expires*HZ;
@@ -928,7 +927,7 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 		h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto,
 				  x->props.family);
 
-		hlist_add_head(&x->byspi, xfrm_state_byspi+h);
+		hlist_add_head(&x->byspi, init_net.xfrm.state_byspi+h);
 	}
 
 	mod_timer(&x->timer, jiffies + HZ);
@@ -1524,7 +1523,7 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 	if (x->id.spi) {
 		spin_lock_bh(&xfrm_state_lock);
 		h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, x->props.family);
-		hlist_add_head(&x->byspi, xfrm_state_byspi+h);
+		hlist_add_head(&x->byspi, init_net.xfrm.state_byspi+h);
 		spin_unlock_bh(&xfrm_state_lock);
 
 		err = 0;
@@ -2086,12 +2085,16 @@ int __net_init xfrm_state_init(struct net *net)
 	net->xfrm.state_bysrc = xfrm_hash_alloc(sz);
 	if (!net->xfrm.state_bysrc)
 		goto out_bysrc;
-	xfrm_state_byspi = xfrm_hash_alloc(sz);
+	net->xfrm.state_byspi = xfrm_hash_alloc(sz);
+	if (!net->xfrm.state_byspi)
+		goto out_byspi;
 	xfrm_state_hmask = ((sz / sizeof(struct hlist_head)) - 1);
 
 	INIT_WORK(&xfrm_state_gc_work, xfrm_state_gc_task);
 	return 0;
 
+out_byspi:
+	xfrm_hash_free(net->xfrm.state_bysrc, sz);
 out_bysrc:
 	xfrm_hash_free(net->xfrm.state_bydst, sz);
 out_bydst:
@@ -2105,6 +2108,8 @@ void xfrm_state_fini(struct net *net)
 	WARN_ON(!list_empty(&net->xfrm.state_all));
 
 	sz = (xfrm_state_hmask + 1) * sizeof(struct hlist_head);
+	WARN_ON(!hlist_empty(net->xfrm.state_byspi));
+	xfrm_hash_free(net->xfrm.state_byspi, sz);
 	WARN_ON(!hlist_empty(net->xfrm.state_bysrc));
 	xfrm_hash_free(net->xfrm.state_bysrc, sz);
 	WARN_ON(!hlist_empty(net->xfrm.state_bydst));
-- 
1.5.6.5

