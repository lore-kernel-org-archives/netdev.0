From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 5/44] [XFRM] STATE: Add source address list.
Date: Thu, 24 Aug 2006 00:02:06 +0900
Message-ID: <11563453653575-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:61832 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964922AbWHWPCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:50 -0400
To: davem@davemloft.net
In-Reply-To: <11563453653851-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Support source address based searching.
Mobile IPv6 will use it.
Based on MIPL2 kernel patch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/xfrm.h     |   26 ++++++++++++++++++++++++++
 net/ipv4/xfrm4_state.c |    3 +++
 net/ipv6/xfrm6_state.c |    3 +++
 net/xfrm/xfrm_state.c  |   21 +++++++++++++++++++--
 4 files changed, 51 insertions(+), 2 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index c36d603..4933f46 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -96,6 +96,7 @@ struct xfrm_state
 {
 	/* Note: bydst is re-used during gc */
 	struct list_head	bydst;
+	struct list_head	bysrc;
 	struct list_head	byspi;
 
 	atomic_t		refcnt;
@@ -237,6 +238,7 @@ extern int __xfrm_state_delete(struct xf
 struct xfrm_state_afinfo {
 	unsigned short		family;
 	struct list_head	*state_bydst;
+	struct list_head	*state_bysrc;
 	struct list_head	*state_byspi;
 	int			(*init_flags)(struct xfrm_state *x);
 	void			(*init_tempsel)(struct xfrm_state *x, struct flowi *fl,
@@ -422,6 +424,30 @@ unsigned xfrm_dst_hash(xfrm_address_t *a
 }
 
 static __inline__
+unsigned __xfrm4_src_hash(xfrm_address_t *addr)
+{
+	return __xfrm4_dst_hash(addr);
+}
+
+static __inline__
+unsigned __xfrm6_src_hash(xfrm_address_t *addr)
+{
+	return __xfrm6_dst_hash(addr);
+}
+
+static __inline__
+unsigned xfrm_src_hash(xfrm_address_t *addr, unsigned short family)
+{
+	switch (family) {
+	case AF_INET:
+		return __xfrm4_src_hash(addr);
+	case AF_INET6:
+		return __xfrm6_src_hash(addr);
+	}
+	return 0;
+}
+
+static __inline__
 unsigned __xfrm4_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto)
 {
 	unsigned h;
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 97b0c75..c56b258 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -122,6 +122,9 @@ __xfrm4_find_acq(u8 mode, u32 reqid, u8 
 		add_timer(&x0->timer);
 		xfrm_state_hold(x0);
 		list_add_tail(&x0->bydst, xfrm4_state_afinfo.state_bydst+h);
+		h = __xfrm4_src_hash(saddr);
+		xfrm_state_hold(x0);
+		list_add_tail(&x0->bysrc, xfrm4_state_afinfo.state_bysrc+h);
 		wake_up(&km_waitq);
 	}
 	if (x0)
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index a1a1f54..2fb0785 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -126,6 +126,9 @@ __xfrm6_find_acq(u8 mode, u32 reqid, u8 
 		add_timer(&x0->timer);
 		xfrm_state_hold(x0);
 		list_add_tail(&x0->bydst, xfrm6_state_afinfo.state_bydst+h);
+		h = __xfrm6_src_hash(saddr);
+		xfrm_state_hold(x0);
+		list_add_tail(&x0->bysrc, xfrm6_state_afinfo.state_bysrc+h);
 		wake_up(&km_waitq);
 	}
 	if (x0)
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 34c038c..2a99928 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -45,6 +45,7 @@ static DEFINE_SPINLOCK(xfrm_state_lock);
  * Also, it can be used by ah/esp icmp error handler to find offending SA.
  */
 static struct list_head xfrm_state_bydst[XFRM_DST_HSIZE];
+static struct list_head xfrm_state_bysrc[XFRM_DST_HSIZE];
 static struct list_head xfrm_state_byspi[XFRM_DST_HSIZE];
 
 DECLARE_WAIT_QUEUE_HEAD(km_waitq);
@@ -200,6 +201,7 @@ struct xfrm_state *xfrm_state_alloc(void
 		atomic_set(&x->refcnt, 1);
 		atomic_set(&x->tunnel_users, 0);
 		INIT_LIST_HEAD(&x->bydst);
+		INIT_LIST_HEAD(&x->bysrc);
 		INIT_LIST_HEAD(&x->byspi);
 		init_timer(&x->timer);
 		x->timer.function = xfrm_timer_handler;
@@ -240,6 +242,8 @@ int __xfrm_state_delete(struct xfrm_stat
 		spin_lock(&xfrm_state_lock);
 		list_del(&x->bydst);
 		__xfrm_state_put(x);
+		list_del(&x->bysrc);
+		__xfrm_state_put(x);
 		if (x->id.spi) {
 			list_del(&x->byspi);
 			__xfrm_state_put(x);
@@ -415,6 +419,8 @@ xfrm_state_find(xfrm_address_t *daddr, x
 			x->km.state = XFRM_STATE_ACQ;
 			list_add_tail(&x->bydst, xfrm_state_bydst+h);
 			xfrm_state_hold(x);
+			list_add_tail(&x->bysrc, xfrm_state_bysrc+h);
+			xfrm_state_hold(x);
 			if (x->id.spi) {
 				h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, family);
 				list_add(&x->byspi, xfrm_state_byspi+h);
@@ -448,11 +454,19 @@ static void __xfrm_state_insert(struct x
 	list_add(&x->bydst, xfrm_state_bydst+h);
 	xfrm_state_hold(x);
 
-	h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, x->props.family);
+	h = xfrm_src_hash(&x->props.saddr, x->props.family);
 
-	list_add(&x->byspi, xfrm_state_byspi+h);
+	list_add(&x->bysrc, xfrm_state_bysrc+h);
 	xfrm_state_hold(x);
 
+	if (xfrm_id_proto_match(x->id.proto, IPSEC_PROTO_ANY)) {
+		h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto,
+				  x->props.family);
+
+		list_add(&x->byspi, xfrm_state_byspi+h);
+		xfrm_state_hold(x);
+	}
+
 	if (!mod_timer(&x->timer, jiffies + HZ))
 		xfrm_state_hold(x);
 
@@ -1075,6 +1089,7 @@ int xfrm_state_register_afinfo(struct xf
 		err = -ENOBUFS;
 	else {
 		afinfo->state_bydst = xfrm_state_bydst;
+		afinfo->state_bysrc = xfrm_state_bysrc;
 		afinfo->state_byspi = xfrm_state_byspi;
 		xfrm_state_afinfo[afinfo->family] = afinfo;
 	}
@@ -1097,6 +1112,7 @@ int xfrm_state_unregister_afinfo(struct 
 		else {
 			xfrm_state_afinfo[afinfo->family] = NULL;
 			afinfo->state_byspi = NULL;
+			afinfo->state_bysrc = NULL;
 			afinfo->state_bydst = NULL;
 		}
 	}
@@ -1218,6 +1234,7 @@ void __init xfrm_state_init(void)
 
 	for (i=0; i<XFRM_DST_HSIZE; i++) {
 		INIT_LIST_HEAD(&xfrm_state_bydst[i]);
+		INIT_LIST_HEAD(&xfrm_state_bysrc[i]);
 		INIT_LIST_HEAD(&xfrm_state_byspi[i]);
 	}
 	INIT_WORK(&xfrm_state_gc_work, xfrm_state_gc_task, NULL);
-- 
1.4.0

