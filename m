From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 6/44] [XFRM] STATE: Search by address using source address list.
Date: Thu, 24 Aug 2006 00:02:07 +0900
Message-ID: <1156345365651-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:62344 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964923AbWHWPCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:50 -0400
To: davem@davemloft.net
In-Reply-To: <11563453653575-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

This is a support to search transformation states by its addresses
by using source address list for Mobile IPv6 usage.
To use it from user-space, it is also added a message type for
source address as a xfrm state option.
Based on MIPL2 kernel patch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/xfrm.h   |    1 +
 include/net/xfrm.h     |    2 ++
 net/ipv4/xfrm4_state.c |    9 +++++++
 net/ipv6/xfrm6_state.c |   21 +++++++++++++++++
 net/xfrm/xfrm_state.c  |   37 +++++++++++++++++++++++++++---
 net/xfrm/xfrm_user.c   |   59 +++++++++++++++++++++++++++++++++++++++++++-----
 6 files changed, 119 insertions(+), 10 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 5154064..66343d3 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -234,6 +234,7 @@ enum xfrm_attr_type_t {
 	XFRMA_REPLAY_VAL,
 	XFRMA_REPLAY_THRESH,
 	XFRMA_ETIMER_THRESH,
+	XFRMA_SRCADDR,		/* xfrm_address_t */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 4933f46..bd51224 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -245,6 +245,7 @@ struct xfrm_state_afinfo {
 						struct xfrm_tmpl *tmpl,
 						xfrm_address_t *daddr, xfrm_address_t *saddr);
 	struct xfrm_state	*(*state_lookup)(xfrm_address_t *daddr, u32 spi, u8 proto);
+	struct xfrm_state	*(*state_lookup_byaddr)(xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto);
 	struct xfrm_state	*(*find_acq)(u8 mode, u32 reqid, u8 proto, 
 					     xfrm_address_t *daddr, xfrm_address_t *saddr, 
 					     int create);
@@ -937,6 +938,7 @@ extern void xfrm_state_insert(struct xfr
 extern int xfrm_state_add(struct xfrm_state *x);
 extern int xfrm_state_update(struct xfrm_state *x);
 extern struct xfrm_state *xfrm_state_lookup(xfrm_address_t *daddr, u32 spi, u8 proto, unsigned short family);
+extern struct xfrm_state *xfrm_state_lookup_byaddr(xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto, unsigned short family);
 extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
 extern void xfrm_state_flush(u8 proto);
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index c56b258..616be13 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -80,6 +80,14 @@ __xfrm4_state_lookup(xfrm_address_t *dad
 	return NULL;
 }
 
+/* placeholder until ipv4's code is written */
+static struct xfrm_state *
+__xfrm4_state_lookup_byaddr(xfrm_address_t *daddr, xfrm_address_t *saddr,
+			    u8 proto)
+{
+	return NULL;
+}
+
 static struct xfrm_state *
 __xfrm4_find_acq(u8 mode, u32 reqid, u8 proto, 
 		 xfrm_address_t *daddr, xfrm_address_t *saddr, 
@@ -137,6 +145,7 @@ static struct xfrm_state_afinfo xfrm4_st
 	.init_flags		= xfrm4_init_flags,
 	.init_tempsel		= __xfrm4_init_tempsel,
 	.state_lookup		= __xfrm4_state_lookup,
+	.state_lookup_byaddr	= __xfrm4_state_lookup_byaddr,
 	.find_acq		= __xfrm4_find_acq,
 };
 
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 2fb0785..9c95b9d 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -64,6 +64,26 @@ __xfrm6_init_tempsel(struct xfrm_state *
 }
 
 static struct xfrm_state *
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
+
+static struct xfrm_state *
 __xfrm6_state_lookup(xfrm_address_t *daddr, u32 spi, u8 proto)
 {
 	unsigned h = __xfrm6_spi_hash(daddr, spi, proto);
@@ -140,6 +160,7 @@ static struct xfrm_state_afinfo xfrm6_st
 	.family			= AF_INET6,
 	.init_tempsel		= __xfrm6_init_tempsel,
 	.state_lookup		= __xfrm6_state_lookup,
+	.state_lookup_byaddr	= __xfrm6_state_lookup_byaddr,
 	.find_acq		= __xfrm6_find_acq,
 };
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 2a99928..11f480b 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -487,6 +487,16 @@ void xfrm_state_insert(struct xfrm_state
 }
 EXPORT_SYMBOL(xfrm_state_insert);
 
+static inline struct xfrm_state *
+__xfrm_state_locate(struct xfrm_state_afinfo *afinfo, struct xfrm_state *x,
+		    int use_spi)
+{
+	if (use_spi)
+		return afinfo->state_lookup(&x->id.daddr, x->id.spi, x->id.proto);
+	else
+		return afinfo->state_lookup_byaddr(&x->id.daddr, &x->props.saddr, x->id.proto);
+}
+
 static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq);
 
 int xfrm_state_add(struct xfrm_state *x)
@@ -495,6 +505,7 @@ int xfrm_state_add(struct xfrm_state *x)
 	struct xfrm_state *x1;
 	int family;
 	int err;
+	int use_spi = xfrm_id_proto_match(x->id.proto, IPSEC_PROTO_ANY);
 
 	family = x->props.family;
 	afinfo = xfrm_state_get_afinfo(family);
@@ -503,7 +514,7 @@ int xfrm_state_add(struct xfrm_state *x)
 
 	spin_lock_bh(&xfrm_state_lock);
 
-	x1 = afinfo->state_lookup(&x->id.daddr, x->id.spi, x->id.proto);
+	x1 = __xfrm_state_locate(afinfo, x, use_spi);
 	if (x1) {
 		xfrm_state_put(x1);
 		x1 = NULL;
@@ -511,7 +522,7 @@ int xfrm_state_add(struct xfrm_state *x)
 		goto out;
 	}
 
-	if (x->km.seq) {
+	if (use_spi && x->km.seq) {
 		x1 = __xfrm_find_acq_byseq(x->km.seq);
 		if (x1 && xfrm_addr_cmp(&x1->id.daddr, &x->id.daddr, family)) {
 			xfrm_state_put(x1);
@@ -519,7 +530,7 @@ int xfrm_state_add(struct xfrm_state *x)
 		}
 	}
 
-	if (!x1)
+	if (use_spi && !x1)
 		x1 = afinfo->find_acq(
 			x->props.mode, x->props.reqid, x->id.proto,
 			&x->id.daddr, &x->props.saddr, 0);
@@ -548,13 +559,14 @@ int xfrm_state_update(struct xfrm_state 
 	struct xfrm_state_afinfo *afinfo;
 	struct xfrm_state *x1;
 	int err;
+	int use_spi = xfrm_id_proto_match(x->id.proto, IPSEC_PROTO_ANY);
 
 	afinfo = xfrm_state_get_afinfo(x->props.family);
 	if (unlikely(afinfo == NULL))
 		return -EAFNOSUPPORT;
 
 	spin_lock_bh(&xfrm_state_lock);
-	x1 = afinfo->state_lookup(&x->id.daddr, x->id.spi, x->id.proto);
+	x1 = __xfrm_state_locate(afinfo, x, use_spi);
 
 	err = -ESRCH;
 	if (!x1)
@@ -675,6 +687,23 @@ xfrm_state_lookup(xfrm_address_t *daddr,
 EXPORT_SYMBOL(xfrm_state_lookup);
 
 struct xfrm_state *
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
+
+struct xfrm_state *
 xfrm_find_acq(u8 mode, u32 reqid, u8 proto, 
 	      xfrm_address_t *daddr, xfrm_address_t *saddr, 
 	      int create, unsigned short family)
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 3db8515..9eaea73 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -86,6 +86,22 @@ static int verify_encap_tmpl(struct rtat
 	return 0;
 }
 
+static int verify_one_addr(struct rtattr **xfrma, enum xfrm_attr_type_t type,
+			   xfrm_address_t **addrp)
+{
+	struct rtattr *rt = xfrma[type - 1];
+
+	if (!rt)
+		return 0;
+
+	if ((rt->rta_len - sizeof(*rt)) < sizeof(**addrp))
+		return -EINVAL;
+
+	if (addrp)
+		*addrp = RTA_DATA(rt);
+
+	return 0;
+}
 
 static inline int verify_sec_ctx_len(struct rtattr **xfrma)
 {
@@ -416,16 +432,48 @@ out:
 	return err;
 }
 
+static struct xfrm_state *xfrm_user_state_lookup(struct xfrm_usersa_id *p,
+						 struct rtattr **xfrma,
+						 int *errp)
+{
+	struct xfrm_state *x = NULL;
+	int err;
+
+	if (xfrm_id_proto_match(p->proto, IPSEC_PROTO_ANY)) {
+		err = -ESRCH;
+		x = xfrm_state_lookup(&p->daddr, p->spi, p->proto, p->family);
+	} else {
+		xfrm_address_t *saddr = NULL;
+
+		err = verify_one_addr(xfrma, XFRMA_SRCADDR, &saddr);
+		if (err)
+			goto out;
+
+		if (!saddr) {
+			err = -EINVAL;
+			goto out;
+		}
+
+		x = xfrm_state_lookup_byaddr(&p->daddr, saddr, p->proto,
+					     p->family);
+	}
+
+ out:
+	if (!x && errp)
+		*errp = err;
+	return x;
+}
+
 static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
 {
 	struct xfrm_state *x;
-	int err;
+	int err = -ESRCH;
 	struct km_event c;
 	struct xfrm_usersa_id *p = NLMSG_DATA(nlh);
 
-	x = xfrm_state_lookup(&p->daddr, p->spi, p->proto, p->family);
+	x = xfrm_user_state_lookup(p, (struct rtattr **)xfrma, &err);
 	if (x == NULL)
-		return -ESRCH;
+		return err;
 
 	if ((err = security_xfrm_state_delete(x)) != 0)
 		goto out;
@@ -576,10 +624,9 @@ static int xfrm_get_sa(struct sk_buff *s
 	struct xfrm_usersa_id *p = NLMSG_DATA(nlh);
 	struct xfrm_state *x;
 	struct sk_buff *resp_skb;
-	int err;
+	int err = -ESRCH;
 
-	x = xfrm_state_lookup(&p->daddr, p->spi, p->proto, p->family);
-	err = -ESRCH;
+	x = xfrm_user_state_lookup(p, (struct rtattr **)xfrma, &err);
 	if (x == NULL)
 		goto out_noput;
 
-- 
1.4.0

