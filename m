From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 5/23] [PATCH] [XFRM] STATE: Add source address list.
Date: Sat, 29 Jul 2006 18:30:12 +0900
Message-ID: <11541654121350-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:16003 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1751384AbWG2JaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:14 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support source address based searching.
Mobile IPv6 will use it.
Based on MIPL2 kernel patch.
---
 include/linux/xfrm.h   |    1 +
 include/net/xfrm.h     |   32 ++++++++++++++++++++++++++++++++
 net/ipv4/xfrm4_state.c |    5 +++++
 net/ipv6/xfrm6_state.c |    5 +++++
 net/xfrm/xfrm_state.c  |   38 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 81 insertions(+), 0 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 7dff1c8..55d1ce4 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -263,6 +263,7 @@ struct xfrm_usersa_id {
 	__u32				spi;
 	__u16				family;
 	__u8				proto;
+	xfrm_address_t			saddr;
 };
 
 struct xfrm_aevent_id {
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ca537b5..75649da 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -94,6 +94,9 @@ struct xfrm_state
 {
 	/* Note: bydst is re-used during gc */
 	struct list_head	bydst;
+#ifdef CONFIG_XFRM_ADVANCED
+	struct list_head	bysrc;
+#endif
 	struct list_head	byspi;
 
 	atomic_t		refcnt;
@@ -235,6 +238,9 @@ struct xfrm_state_afinfo {
 	unsigned short		family;
 	rwlock_t		lock;
 	struct list_head	*state_bydst;
+#ifdef CONFIG_XFRM_ADVANCED
+	struct list_head	*state_bysrc;
+#endif
 	struct list_head	*state_byspi;
 	int			(*init_flags)(struct xfrm_state *x);
 	void			(*init_tempsel)(struct xfrm_state *x, struct flowi *fl,
@@ -411,6 +417,32 @@ unsigned xfrm_dst_hash(xfrm_address_t *a
 	return 0;
 }
 
+#ifdef CONFIG_XFRM_ADVANCED
+static __inline__
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
+#endif
+
 static __inline__
 unsigned __xfrm4_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto)
 {
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 171cdc5..6de2ce0 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -122,6 +122,11 @@ __xfrm4_find_acq(u8 mode, u32 reqid, u8 
 		add_timer(&x0->timer);
 		xfrm_state_hold(x0);
 		list_add_tail(&x0->bydst, xfrm4_state_afinfo.state_bydst+h);
+#ifdef CONFIG_XFRM_ADVANCED
+		h = __xfrm4_src_hash(saddr);
+		xfrm_state_hold(x0);
+		list_add_tail(&x0->bysrc, xfrm4_state_afinfo.state_bysrc+h);
+#endif
 		wake_up(&km_waitq);
 	}
 	if (x0)
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 71c40bb..00b6c17 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -126,6 +126,11 @@ __xfrm6_find_acq(u8 mode, u32 reqid, u8 
 		add_timer(&x0->timer);
 		xfrm_state_hold(x0);
 		list_add_tail(&x0->bydst, xfrm6_state_afinfo.state_bydst+h);
+#ifdef CONFIG_XFRM_ADVANCED
+		h = __xfrm6_src_hash(saddr);
+		xfrm_state_hold(x0);
+		list_add_tail(&x0->bysrc, xfrm6_state_afinfo.state_bysrc+h);
+#endif
 		wake_up(&km_waitq);
 	}
 	if (x0)
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 6cf080f..1942bb1 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -45,6 +45,9 @@ static DEFINE_SPINLOCK(xfrm_state_lock);
  * Also, it can be used by ah/esp icmp error handler to find offending SA.
  */
 static struct list_head xfrm_state_bydst[XFRM_DST_HSIZE];
+#ifdef CONFIG_XFRM_ADVANCED
+static struct list_head xfrm_state_bysrc[XFRM_DST_HSIZE];
+#endif
 static struct list_head xfrm_state_byspi[XFRM_DST_HSIZE];
 
 DECLARE_WAIT_QUEUE_HEAD(km_waitq);
@@ -199,6 +202,9 @@ struct xfrm_state *xfrm_state_alloc(void
 		atomic_set(&x->refcnt, 1);
 		atomic_set(&x->tunnel_users, 0);
 		INIT_LIST_HEAD(&x->bydst);
+#ifdef CONFIG_XFRM_ADVANCED
+		INIT_LIST_HEAD(&x->bysrc);
+#endif
 		INIT_LIST_HEAD(&x->byspi);
 		init_timer(&x->timer);
 		x->timer.function = xfrm_timer_handler;
@@ -239,6 +245,10 @@ int __xfrm_state_delete(struct xfrm_stat
 		spin_lock(&xfrm_state_lock);
 		list_del(&x->bydst);
 		__xfrm_state_put(x);
+#ifdef CONFIG_XFRM_ADVANCED
+		list_del(&x->bysrc);
+		__xfrm_state_put(x);
+#endif
 		if (x->id.spi) {
 			list_del(&x->byspi);
 			__xfrm_state_put(x);
@@ -406,6 +416,10 @@ xfrm_state_find(xfrm_address_t *daddr, x
 			x->km.state = XFRM_STATE_ACQ;
 			list_add_tail(&x->bydst, xfrm_state_bydst+h);
 			xfrm_state_hold(x);
+#ifdef CONFIG_XFRM_ADVANCED
+			list_add_tail(&x->bysrc, xfrm_state_bysrc+h);
+			xfrm_state_hold(x);
+#endif
 			if (x->id.spi) {
 				h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, family);
 				list_add(&x->byspi, xfrm_state_byspi+h);
@@ -439,10 +453,25 @@ static void __xfrm_state_insert(struct x
 	list_add(&x->bydst, xfrm_state_bydst+h);
 	xfrm_state_hold(x);
 
+#ifdef CONFIG_XFRM_ADVANCED
+	h = xfrm_src_hash(&x->props.saddr, x->props.family);
+
+	list_add(&x->bysrc, xfrm_state_bysrc+h);
+	xfrm_state_hold(x);
+
+	if (xfrm_id_proto_match(x->id.proto, IPSEC_PROTO_ANY)) {
+		h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto,
+				  x->props.family);
+
+		list_add(&x->byspi, xfrm_state_byspi+h);
+		xfrm_state_hold(x);
+	}
+#else
 	h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, x->props.family);
 
 	list_add(&x->byspi, xfrm_state_byspi+h);
 	xfrm_state_hold(x);
+#endif
 
 	if (!mod_timer(&x->timer, jiffies + HZ))
 		xfrm_state_hold(x);
@@ -1066,6 +1095,9 @@ int xfrm_state_register_afinfo(struct xf
 		err = -ENOBUFS;
 	else {
 		afinfo->state_bydst = xfrm_state_bydst;
+#ifdef CONFIG_XFRM_ADVANCED
+		afinfo->state_bysrc = xfrm_state_bysrc;
+#endif
 		afinfo->state_byspi = xfrm_state_byspi;
 		xfrm_state_afinfo[afinfo->family] = afinfo;
 	}
@@ -1088,6 +1120,9 @@ int xfrm_state_unregister_afinfo(struct 
 		else {
 			xfrm_state_afinfo[afinfo->family] = NULL;
 			afinfo->state_byspi = NULL;
+#ifdef CONFIG_XFRM_ADVANCED
+			afinfo->state_bysrc = NULL;
+#endif
 			afinfo->state_bydst = NULL;
 		}
 	}
@@ -1210,6 +1245,9 @@ void __init xfrm_state_init(void)
 
 	for (i=0; i<XFRM_DST_HSIZE; i++) {
 		INIT_LIST_HEAD(&xfrm_state_bydst[i]);
+#ifdef CONFIG_XFRM_ADVANCED
+		INIT_LIST_HEAD(&xfrm_state_bysrc[i]);
+#endif
 		INIT_LIST_HEAD(&xfrm_state_byspi[i]);
 	}
 	INIT_WORK(&xfrm_state_gc_work, xfrm_state_gc_task, NULL);
-- 
1.4.1

