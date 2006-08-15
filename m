From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/10]: [XFRM]: Pull xfrm_state_bydst hash table knowledge
 out of afinfo.
Date: Tue, 15 Aug 2006 04:37:23 -0700 (PDT)
Message-ID: <20060815.043723.92587337.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:64474
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030224AbWHOLh0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 07:37:26 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[XFRM]: Pull xfrm_state_bydst hash table knowledge out of afinfo.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h     |   34 -------------
 net/ipv4/xfrm4_state.c |   50 -------------------
 net/ipv6/xfrm6_state.c |   53 --------------------
 net/xfrm/xfrm_state.c  |  125 ++++++++++++++++++++++++++++++++++++++++++++----
 4 files changed, 115 insertions(+), 147 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 9c5ee9f..e53819f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -235,16 +235,12 @@ extern int __xfrm_state_delete(struct xf
 
 struct xfrm_state_afinfo {
 	unsigned short		family;
-	struct list_head	*state_bydst;
 	struct list_head	*state_byspi;
 	int			(*init_flags)(struct xfrm_state *x);
 	void			(*init_tempsel)(struct xfrm_state *x, struct flowi *fl,
 						struct xfrm_tmpl *tmpl,
 						xfrm_address_t *daddr, xfrm_address_t *saddr);
 	struct xfrm_state	*(*state_lookup)(xfrm_address_t *daddr, u32 spi, u8 proto);
-	struct xfrm_state	*(*find_acq)(u8 mode, u32 reqid, u8 proto, 
-					     xfrm_address_t *daddr, xfrm_address_t *saddr, 
-					     int create);
 };
 
 extern int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo);
@@ -391,36 +387,6 @@ static inline void xfrm_pol_put(struct x
 #define XFRM_DST_HSIZE		1024
 
 static __inline__
-unsigned __xfrm4_dst_hash(xfrm_address_t *addr)
-{
-	unsigned h;
-	h = ntohl(addr->a4);
-	h = (h ^ (h>>16)) % XFRM_DST_HSIZE;
-	return h;
-}
-
-static __inline__
-unsigned __xfrm6_dst_hash(xfrm_address_t *addr)
-{
-	unsigned h;
-	h = ntohl(addr->a6[2]^addr->a6[3]);
-	h = (h ^ (h>>16)) % XFRM_DST_HSIZE;
-	return h;
-}
-
-static __inline__
-unsigned xfrm_dst_hash(xfrm_address_t *addr, unsigned short family)
-{
-	switch (family) {
-	case AF_INET:
-		return __xfrm4_dst_hash(addr);
-	case AF_INET6:
-		return __xfrm6_dst_hash(addr);
-	}
-	return 0;
-}
-
-static __inline__
 unsigned __xfrm4_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto)
 {
 	unsigned h;
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 81e1751..f0a77fc 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -80,61 +80,11 @@ __xfrm4_state_lookup(xfrm_address_t *dad
 	return NULL;
 }
 
-static struct xfrm_state *
-__xfrm4_find_acq(u8 mode, u32 reqid, u8 proto, 
-		 xfrm_address_t *daddr, xfrm_address_t *saddr, 
-		 int create)
-{
-	struct xfrm_state *x, *x0;
-	unsigned h = __xfrm4_dst_hash(daddr);
-
-	x0 = NULL;
-
-	list_for_each_entry(x, xfrm4_state_afinfo.state_bydst+h, bydst) {
-		if (x->props.family == AF_INET &&
-		    daddr->a4 == x->id.daddr.a4 &&
-		    mode == x->props.mode &&
-		    proto == x->id.proto &&
-		    saddr->a4 == x->props.saddr.a4 &&
-		    reqid == x->props.reqid &&
-		    x->km.state == XFRM_STATE_ACQ &&
-		    !x->id.spi) {
-			    x0 = x;
-			    break;
-		    }
-	}
-	if (!x0 && create && (x0 = xfrm_state_alloc()) != NULL) {
-		x0->sel.daddr.a4 = daddr->a4;
-		x0->sel.saddr.a4 = saddr->a4;
-		x0->sel.prefixlen_d = 32;
-		x0->sel.prefixlen_s = 32;
-		x0->props.saddr.a4 = saddr->a4;
-		x0->km.state = XFRM_STATE_ACQ;
-		x0->id.daddr.a4 = daddr->a4;
-		x0->id.proto = proto;
-		x0->props.family = AF_INET;
-		x0->props.mode = mode;
-		x0->props.reqid = reqid;
-		x0->props.family = AF_INET;
-		x0->lft.hard_add_expires_seconds = XFRM_ACQ_EXPIRES;
-		xfrm_state_hold(x0);
-		x0->timer.expires = jiffies + XFRM_ACQ_EXPIRES*HZ;
-		add_timer(&x0->timer);
-		xfrm_state_hold(x0);
-		list_add_tail(&x0->bydst, xfrm4_state_afinfo.state_bydst+h);
-		wake_up(&km_waitq);
-	}
-	if (x0)
-		xfrm_state_hold(x0);
-	return x0;
-}
-
 static struct xfrm_state_afinfo xfrm4_state_afinfo = {
 	.family			= AF_INET,
 	.init_flags		= xfrm4_init_flags,
 	.init_tempsel		= __xfrm4_init_tempsel,
 	.state_lookup		= __xfrm4_state_lookup,
-	.find_acq		= __xfrm4_find_acq,
 };
 
 void __init xfrm4_state_init(void)
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index b33296b..c43e45d 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -81,63 +81,10 @@ __xfrm6_state_lookup(xfrm_address_t *dad
 	return NULL;
 }
 
-static struct xfrm_state *
-__xfrm6_find_acq(u8 mode, u32 reqid, u8 proto, 
-		 xfrm_address_t *daddr, xfrm_address_t *saddr, 
-		 int create)
-{
-	struct xfrm_state *x, *x0;
-	unsigned h = __xfrm6_dst_hash(daddr);
-
-	x0 = NULL;
-
-	list_for_each_entry(x, xfrm6_state_afinfo.state_bydst+h, bydst) {
-		if (x->props.family == AF_INET6 &&
-		    ipv6_addr_equal((struct in6_addr *)daddr, (struct in6_addr *)x->id.daddr.a6) &&
-		    mode == x->props.mode &&
-		    proto == x->id.proto &&
-		    ipv6_addr_equal((struct in6_addr *)saddr, (struct in6_addr *)x->props.saddr.a6) &&
-		    reqid == x->props.reqid &&
-		    x->km.state == XFRM_STATE_ACQ &&
-		    !x->id.spi) {
-			    x0 = x;
-			    break;
-		    }
-	}
-	if (!x0 && create && (x0 = xfrm_state_alloc()) != NULL) {
-		ipv6_addr_copy((struct in6_addr *)x0->sel.daddr.a6,
-			       (struct in6_addr *)daddr);
-		ipv6_addr_copy((struct in6_addr *)x0->sel.saddr.a6,
-			       (struct in6_addr *)saddr);
-		x0->sel.prefixlen_d = 128;
-		x0->sel.prefixlen_s = 128;
-		ipv6_addr_copy((struct in6_addr *)x0->props.saddr.a6,
-			       (struct in6_addr *)saddr);
-		x0->km.state = XFRM_STATE_ACQ;
-		ipv6_addr_copy((struct in6_addr *)x0->id.daddr.a6,
-			       (struct in6_addr *)daddr);
-		x0->id.proto = proto;
-		x0->props.family = AF_INET6;
-		x0->props.mode = mode;
-		x0->props.reqid = reqid;
-		x0->lft.hard_add_expires_seconds = XFRM_ACQ_EXPIRES;
-		xfrm_state_hold(x0);
-		x0->timer.expires = jiffies + XFRM_ACQ_EXPIRES*HZ;
-		add_timer(&x0->timer);
-		xfrm_state_hold(x0);
-		list_add_tail(&x0->bydst, xfrm6_state_afinfo.state_bydst+h);
-		wake_up(&km_waitq);
-	}
-	if (x0)
-		xfrm_state_hold(x0);
-	return x0;
-}
-
 static struct xfrm_state_afinfo xfrm6_state_afinfo = {
 	.family			= AF_INET6,
 	.init_tempsel		= __xfrm6_init_tempsel,
 	.state_lookup		= __xfrm6_state_lookup,
-	.find_acq		= __xfrm6_find_acq,
 };
 
 void __init xfrm6_state_init(void)
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 0021aad..da67054 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -47,6 +47,36 @@ static DEFINE_SPINLOCK(xfrm_state_lock);
 static struct list_head xfrm_state_bydst[XFRM_DST_HSIZE];
 static struct list_head xfrm_state_byspi[XFRM_DST_HSIZE];
 
+static __inline__
+unsigned __xfrm4_dst_hash(xfrm_address_t *addr)
+{
+	unsigned h;
+	h = ntohl(addr->a4);
+	h = (h ^ (h>>16)) % XFRM_DST_HSIZE;
+	return h;
+}
+
+static __inline__
+unsigned __xfrm6_dst_hash(xfrm_address_t *addr)
+{
+	unsigned h;
+	h = ntohl(addr->a6[2]^addr->a6[3]);
+	h = (h ^ (h>>16)) % XFRM_DST_HSIZE;
+	return h;
+}
+
+static __inline__
+unsigned xfrm_dst_hash(xfrm_address_t *addr, unsigned short family)
+{
+	switch (family) {
+	case AF_INET:
+		return __xfrm4_dst_hash(addr);
+	case AF_INET6:
+		return __xfrm6_dst_hash(addr);
+	}
+	return 0;
+}
+
 DECLARE_WAIT_QUEUE_HEAD(km_waitq);
 EXPORT_SYMBOL(km_waitq);
 
@@ -465,6 +495,86 @@ void xfrm_state_insert(struct xfrm_state
 }
 EXPORT_SYMBOL(xfrm_state_insert);
 
+/* xfrm_state_lock is held */
+static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 reqid, u8 proto, xfrm_address_t *daddr, xfrm_address_t *saddr, int create)
+{
+	unsigned int h = xfrm_dst_hash(daddr, family);
+	struct xfrm_state *x;
+
+	list_for_each_entry(x, xfrm_state_bydst+h, bydst) {
+		if (x->props.reqid  != reqid ||
+		    x->props.mode   != mode ||
+		    x->props.family != family ||
+		    x->km.state     != XFRM_STATE_ACQ ||
+		    x->id.spi       != 0)
+			continue;
+
+		switch (family) {
+		case AF_INET:
+			if (x->id.daddr.a4    != daddr->a4 ||
+			    x->props.saddr.a4 != saddr->a4)
+				continue;
+			break;
+		case AF_INET6:
+			if (!ipv6_addr_equal((struct in6_addr *)x->id.daddr.a6,
+					     (struct in6_addr *)daddr) ||
+			    !ipv6_addr_equal((struct in6_addr *)
+					     x->props.saddr.a6,
+					     (struct in6_addr *)saddr))
+				continue;
+			break;
+		};
+
+		xfrm_state_hold(x);
+		return x;
+	}
+
+	if (!create)
+		return NULL;
+
+	x = xfrm_state_alloc();
+	if (likely(x)) {
+		switch (family) {
+		case AF_INET:
+			x->sel.daddr.a4 = daddr->a4;
+			x->sel.saddr.a4 = saddr->a4;
+			x->sel.prefixlen_d = 32;
+			x->sel.prefixlen_s = 32;
+			x->props.saddr.a4 = saddr->a4;
+			x->id.daddr.a4 = daddr->a4;
+			break;
+
+		case AF_INET6:
+			ipv6_addr_copy((struct in6_addr *)x->sel.daddr.a6,
+				       (struct in6_addr *)daddr);
+			ipv6_addr_copy((struct in6_addr *)x->sel.saddr.a6,
+				       (struct in6_addr *)saddr);
+			x->sel.prefixlen_d = 128;
+			x->sel.prefixlen_s = 128;
+			ipv6_addr_copy((struct in6_addr *)x->props.saddr.a6,
+				       (struct in6_addr *)saddr);
+			ipv6_addr_copy((struct in6_addr *)x->id.daddr.a6,
+				       (struct in6_addr *)daddr);
+			break;
+		};
+
+		x->km.state = XFRM_STATE_ACQ;
+		x->id.proto = proto;
+		x->props.family = family;
+		x->props.mode = mode;
+		x->props.reqid = reqid;
+		x->lft.hard_add_expires_seconds = XFRM_ACQ_EXPIRES;
+		xfrm_state_hold(x);
+		x->timer.expires = jiffies + XFRM_ACQ_EXPIRES*HZ;
+		add_timer(&x->timer);
+		xfrm_state_hold(x);
+		list_add_tail(&x->bydst, xfrm_state_bydst+h);
+		wake_up(&km_waitq);
+	}
+
+	return x;
+}
+
 static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq);
 
 int xfrm_state_add(struct xfrm_state *x)
@@ -498,9 +608,9 @@ int xfrm_state_add(struct xfrm_state *x)
 	}
 
 	if (!x1)
-		x1 = afinfo->find_acq(
-			x->props.mode, x->props.reqid, x->id.proto,
-			&x->id.daddr, &x->props.saddr, 0);
+		x1 = __find_acq_core(family, x->props.mode, x->props.reqid,
+				     x->id.proto,
+				     &x->id.daddr, &x->props.saddr, 0);
 
 	__xfrm_state_insert(x);
 	err = 0;
@@ -658,14 +768,11 @@ xfrm_find_acq(u8 mode, u32 reqid, u8 pro
 	      int create, unsigned short family)
 {
 	struct xfrm_state *x;
-	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
-	if (!afinfo)
-		return NULL;
 
 	spin_lock_bh(&xfrm_state_lock);
-	x = afinfo->find_acq(mode, reqid, proto, daddr, saddr, create);
+	x = __find_acq_core(family, mode, reqid, proto, daddr, saddr, create);
 	spin_unlock_bh(&xfrm_state_lock);
-	xfrm_state_put_afinfo(afinfo);
+
 	return x;
 }
 EXPORT_SYMBOL(xfrm_find_acq);
@@ -1066,7 +1173,6 @@ int xfrm_state_register_afinfo(struct xf
 	if (unlikely(xfrm_state_afinfo[afinfo->family] != NULL))
 		err = -ENOBUFS;
 	else {
-		afinfo->state_bydst = xfrm_state_bydst;
 		afinfo->state_byspi = xfrm_state_byspi;
 		xfrm_state_afinfo[afinfo->family] = afinfo;
 	}
@@ -1089,7 +1195,6 @@ int xfrm_state_unregister_afinfo(struct 
 		else {
 			xfrm_state_afinfo[afinfo->family] = NULL;
 			afinfo->state_byspi = NULL;
-			afinfo->state_bydst = NULL;
 		}
 	}
 	write_unlock_bh(&xfrm_state_afinfo_lock);
-- 
1.4.2.rc2.g3e042

