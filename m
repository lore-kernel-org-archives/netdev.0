From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 6/23] [PATCH] [XFRM] STATE: Search by address using source address list.
Date: Sat, 29 Jul 2006 18:30:18 +0900
Message-ID: <11541654182334-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:17027 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1751384AbWG2JaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:20 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a support to search transformation states by its addresses
by using source address list.
For Mobile IPv6 usage.
Based on MIPL2 kernel patch.
---
 include/net/xfrm.h     |   11 +++++++++++
 net/ipv4/xfrm4_state.c |   13 +++++++++++++
 net/ipv6/xfrm6_state.c |   25 ++++++++++++++++++++++++
 net/xfrm/xfrm_state.c  |   49 +++++++++++++++++++++++++++++++++++++++++++-----
 net/xfrm/xfrm_user.c   |   13 +++++++++++--
 5 files changed, 104 insertions(+), 7 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 75649da..aaef1c4 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -247,6 +247,9 @@ #endif
 						struct xfrm_tmpl *tmpl,
 						xfrm_address_t *daddr, xfrm_address_t *saddr);
 	struct xfrm_state	*(*state_lookup)(xfrm_address_t *daddr, u32 spi, u8 proto);
+#ifdef CONFIG_XFRM_ADVANCED
+	struct xfrm_state	*(*state_lookup_byaddr)(xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto);
+#endif
 	struct xfrm_state	*(*find_acq)(u8 mode, u32 reqid, u8 proto, 
 					     xfrm_address_t *daddr, xfrm_address_t *saddr, 
 					     int create);
@@ -930,6 +933,14 @@ extern void xfrm_state_insert(struct xfr
 extern int xfrm_state_add(struct xfrm_state *x);
 extern int xfrm_state_update(struct xfrm_state *x);
 extern struct xfrm_state *xfrm_state_lookup(xfrm_address_t *daddr, u32 spi, u8 proto, unsigned short family);
+#ifdef CONFIG_XFRM_ADVANCED
+extern struct xfrm_state *xfrm_state_lookup_byaddr(xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto, unsigned short family);
+#else
+static inline struct xfrm_state *xfrm_state_lookup_byaddr(xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto, unsigned short family)
+{
+	return NULL;
+}
+#endif
 extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
 extern void xfrm_state_flush(u8 proto);
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 6de2ce0..8b44a75 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -80,6 +80,16 @@ __xfrm4_state_lookup(xfrm_address_t *dad
 	return NULL;
 }
 
+#ifdef CONFIG_XFRM_ADVANCED
+/* placeholder until ipv4's code is written */
+static struct xfrm_state *
+__xfrm4_state_lookup_byaddr(xfrm_address_t *daddr, xfrm_address_t *saddr,
+			    u8 proto)
+{
+	return NULL;
+}
+#endif
+
 static struct xfrm_state *
 __xfrm4_find_acq(u8 mode, u32 reqid, u8 proto, 
 		 xfrm_address_t *daddr, xfrm_address_t *saddr, 
@@ -140,6 +150,9 @@ static struct xfrm_state_afinfo xfrm4_st
 	.init_flags		= xfrm4_init_flags,
 	.init_tempsel		= __xfrm4_init_tempsel,
 	.state_lookup		= __xfrm4_state_lookup,
+#ifdef CONFIG_XFRM_ADVANCED
+	.state_lookup_byaddr	= __xfrm4_state_lookup_byaddr,
+#endif
 	.find_acq		= __xfrm4_find_acq,
 };
 
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 00b6c17..d141030 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -63,6 +63,28 @@ __xfrm6_init_tempsel(struct xfrm_state *
 	x->props.family = AF_INET6;
 }
 
+#ifdef CONFIG_XFRM_ADVANCED
+static struct xfrm_state *
+__xfrm6_state_lookup_byaddr(xfrm_address_t *daddr, xfrm_address_t *saddr,
+			    u8 proto)
+{
+	struct xfrm_state *x = NULL;
+	unsigned h;
+
+	h = __xfrm6_src_hash(saddr);
+	list_for_each_entry(x, xfrm6_state_afinfo.state_bysrc+h, bysrc) {
+		if (x->props.family == AF_INET6 &&
+		    ipv6_addr_equal((struct in6_addr *)daddr, (struct in6_addr *)x->id.daddr.a6) &&
+		    ipv6_addr_equal((struct in6_addr *)saddr, (struct in6_addr *)x->props.saddr.a6) &&
+		    proto == x->id.proto) {
+			xfrm_state_hold(x);
+			return x;
+		}
+	}
+	return NULL;
+}
+#endif
+
 static struct xfrm_state *
 __xfrm6_state_lookup(xfrm_address_t *daddr, u32 spi, u8 proto)
 {
@@ -143,6 +165,9 @@ static struct xfrm_state_afinfo xfrm6_st
 	.lock			= RW_LOCK_UNLOCKED,
 	.init_tempsel		= __xfrm6_init_tempsel,
 	.state_lookup		= __xfrm6_state_lookup,
+#ifdef CONFIG_XFRM_ADVANCED
+	.state_lookup_byaddr	= __xfrm6_state_lookup_byaddr,
+#endif
 	.find_acq		= __xfrm6_find_acq,
 };
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 1942bb1..1eedb85 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -501,6 +501,11 @@ int xfrm_state_add(struct xfrm_state *x)
 	struct xfrm_state *x1;
 	int family;
 	int err;
+#ifdef CONFIG_XFRM_ADVANCED
+	int use_spi = xfrm_id_proto_match(x->id.proto, IPSEC_PROTO_ANY);
+#else
+	int use_spi = 1;
+#endif
 
 	family = x->props.family;
 	afinfo = xfrm_state_get_afinfo(family);
@@ -509,7 +514,12 @@ int xfrm_state_add(struct xfrm_state *x)
 
 	spin_lock_bh(&xfrm_state_lock);
 
-	x1 = afinfo->state_lookup(&x->id.daddr, x->id.spi, x->id.proto);
+	if (use_spi)
+		x1 = afinfo->state_lookup(&x->id.daddr, x->id.spi, x->id.proto);
+#ifdef CONFIG_XFRM_ADVANCED
+	else
+		x1 = afinfo->state_lookup_byaddr(&x->id.daddr, &x->props.saddr, x->id.proto);
+#endif
 	if (x1) {
 		xfrm_state_put(x1);
 		x1 = NULL;
@@ -517,7 +527,7 @@ int xfrm_state_add(struct xfrm_state *x)
 		goto out;
 	}
 
-	if (x->km.seq) {
+	if (use_spi && x->km.seq) {
 		x1 = __xfrm_find_acq_byseq(x->km.seq);
 		if (x1 && xfrm_addr_cmp(&x1->id.daddr, &x->id.daddr, family)) {
 			xfrm_state_put(x1);
@@ -525,7 +535,7 @@ int xfrm_state_add(struct xfrm_state *x)
 		}
 	}
 
-	if (!x1)
+	if (use_spi && !x1)
 		x1 = afinfo->find_acq(
 			x->props.mode, x->props.reqid, x->id.proto,
 			&x->id.daddr, &x->props.saddr, 0);
@@ -552,15 +562,25 @@ EXPORT_SYMBOL(xfrm_state_add);
 int xfrm_state_update(struct xfrm_state *x)
 {
 	struct xfrm_state_afinfo *afinfo;
-	struct xfrm_state *x1;
+	struct xfrm_state *x1 = NULL;
 	int err;
+#ifdef CONFIG_XFRM_ADVANCED
+	int use_spi = xfrm_id_proto_match(x->id.proto, IPSEC_PROTO_ANY);
+#else
+	int use_spi = 1;
+#endif
 
 	afinfo = xfrm_state_get_afinfo(x->props.family);
 	if (unlikely(afinfo == NULL))
 		return -EAFNOSUPPORT;
 
 	spin_lock_bh(&xfrm_state_lock);
-	x1 = afinfo->state_lookup(&x->id.daddr, x->id.spi, x->id.proto);
+	if (use_spi)
+		x1 = afinfo->state_lookup(&x->id.daddr, x->id.spi, x->id.proto);
+#ifdef CONFIG_XFRM_ADVANCED
+	else
+		x1 = afinfo->state_lookup_byaddr(&x->id.daddr, &x->props.saddr, x->id.proto);
+#endif
 
 	err = -ESRCH;
 	if (!x1)
@@ -680,6 +700,25 @@ xfrm_state_lookup(xfrm_address_t *daddr,
 }
 EXPORT_SYMBOL(xfrm_state_lookup);
 
+#ifdef CONFIG_XFRM_ADVANCED
+struct xfrm_state *
+xfrm_state_lookup_byaddr(xfrm_address_t *daddr, xfrm_address_t *saddr,
+			 u8 proto, unsigned short family)
+{
+	struct xfrm_state *x;
+	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
+	if (!afinfo)
+		return NULL;
+
+	spin_lock_bh(&xfrm_state_lock);
+	x = afinfo->state_lookup_byaddr(daddr, saddr, proto);
+	spin_unlock_bh(&xfrm_state_lock);
+	xfrm_state_put_afinfo(afinfo);
+	return x;
+}
+EXPORT_SYMBOL(xfrm_state_lookup_byaddr);
+#endif
+
 struct xfrm_state *
 xfrm_find_acq(u8 mode, u32 reqid, u8 proto, 
 	      xfrm_address_t *daddr, xfrm_address_t *saddr, 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index f92d163..85051a2 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -416,6 +416,15 @@ out:
 	return err;
 }
 
+static struct xfrm_state *xfrm_user_state_lookup(struct xfrm_usersa_id *p)
+{
+	if (xfrm_id_proto_match(p->proto, IPSEC_PROTO_ANY))
+		return xfrm_state_lookup(&p->daddr, p->spi, p->proto, p->family);
+	else
+		return xfrm_state_lookup_byaddr(&p->daddr, &p->saddr, p->proto,
+						p->family);
+}
+
 static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
 {
 	struct xfrm_state *x;
@@ -423,7 +432,7 @@ static int xfrm_del_sa(struct sk_buff *s
 	struct km_event c;
 	struct xfrm_usersa_id *p = NLMSG_DATA(nlh);
 
-	x = xfrm_state_lookup(&p->daddr, p->spi, p->proto, p->family);
+	x = xfrm_user_state_lookup(p);
 	if (x == NULL)
 		return -ESRCH;
 
@@ -576,7 +585,7 @@ static int xfrm_get_sa(struct sk_buff *s
 	struct sk_buff *resp_skb;
 	int err;
 
-	x = xfrm_state_lookup(&p->daddr, p->spi, p->proto, p->family);
+	x = xfrm_user_state_lookup(p);
 	err = -ESRCH;
 	if (x == NULL)
 		goto out_noput;
-- 
1.4.1

