From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 12/23] [PATCH] [XFRM] STATE: Introduce care-of address.
Date: Sat, 29 Jul 2006 18:30:34 +0900
Message-ID: <11541654341680-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:23171 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1161088AbWG2Jaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:35 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Care-of address is carried by state as a transformation option like IPsec
encryption/authentication algorithm.
Based on MIPL2 kernel patch.
---
 include/linux/xfrm.h  |    1 +
 include/net/xfrm.h    |    5 +++++
 net/xfrm/xfrm_state.c |   10 +++++++++
 net/xfrm/xfrm_user.c  |   53 ++++++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 68 insertions(+), 1 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 47e39f6..597a7c7 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -235,6 +235,7 @@ enum xfrm_attr_type_t {
 	XFRMA_REPLAY_VAL,
 	XFRMA_REPLAY_THRESH,
 	XFRMA_ETIMER_THRESH,
+	XFRMA_ADDR,		/* xfrm_address_t */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index f551bc6..de62a8f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -135,6 +135,11 @@ #endif
 	/* Data for encapsulator */
 	struct xfrm_encap_tmpl	*encap;
 
+#ifdef CONFIG_XFRM_ADVANCED
+	/* Data for care-of address */
+	xfrm_address_t	*coaddr;
+#endif
+
 	/* IPComp needs an IPIP tunnel for handling uncompressed packets */
 	struct xfrm_state	*tunnel;
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 60def7a..1bdeecf 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -80,6 +80,9 @@ static void xfrm_state_gc_destroy(struct
 	kfree(x->ealg);
 	kfree(x->calg);
 	kfree(x->encap);
+#ifdef CONFIG_XFRM_ADVANCED
+	kfree(x->coaddr);
+#endif
 	if (x->type) {
 		x->type->destructor(x);
 		xfrm_put_type(x->type);
@@ -619,6 +622,13 @@ out:
 	if (likely(x1->km.state == XFRM_STATE_VALID)) {
 		if (x->encap && x1->encap)
 			memcpy(x1->encap, x->encap, sizeof(*x1->encap));
+#ifdef CONFIG_XFRM_ADVANCED
+		if (x->coaddr && x1->coaddr) {
+			memcpy(x1->coaddr, x->coaddr, sizeof(*x1->coaddr));
+		}
+		if (!use_spi && memcmp(&x1->sel, &x->sel, sizeof(x1->sel)))
+			memcpy(&x1->sel, &x->sel, sizeof(x1->sel));
+#endif
 		memcpy(&x1->lft, &x->lft, sizeof(x1->lft));
 		x1->km.dying = 0;
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 85051a2..13fe172 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -110,6 +110,21 @@ static inline int verify_sec_ctx_len(str
 	return 0;
 }
 
+#ifdef CONFIG_XFRM_ADVANCED
+static int verify_one_addr(struct rtattr **xfrma)
+{
+	struct rtattr *rt = xfrma[XFRMA_ADDR - 1];
+	xfrm_address_t *addr;
+
+	if (!rt)
+		return 0;
+
+	if ((rt->rta_len - sizeof(*rt)) < sizeof(*addr))
+		return -EINVAL;
+
+	return 0;
+}
+#endif
 
 static int verify_newsa_info(struct xfrm_usersa_info *p,
 			     struct rtattr **xfrma)
@@ -170,11 +185,18 @@ #endif
 		goto out;
 	if ((err = verify_sec_ctx_len(xfrma)))
 		goto out;
+#ifdef CONFIG_XFRM_ADVANCED
+	if ((err = verify_one_addr(xfrma)))
+		goto out;
+#endif
 
 	err = -EINVAL;
 	switch (p->mode) {
 	case XFRM_MODE_TRANSPORT:
 	case XFRM_MODE_TUNNEL:
+#ifdef CONFIG_XFRM_ADVANCED
+	case XFRM_MODE_ROUTEOPTIMIZATION:
+#endif
 		break;
 
 	default:
@@ -258,6 +280,26 @@ static int attach_sec_ctx(struct xfrm_st
 	return security_xfrm_state_alloc(x, uctx);
 }
 
+#ifdef CONFIG_XFRM_ADVANCED
+static int attach_one_addr(xfrm_address_t **addrpp, struct rtattr *u_arg)
+{
+	struct rtattr *rta = u_arg;
+	xfrm_address_t *p, *uaddrp;
+
+	if (!rta)
+		return 0;
+
+	uaddrp = RTA_DATA(rta);
+	p = kmalloc(sizeof(*p), GFP_KERNEL);
+	if (!p)
+		return -ENOMEM;
+
+	memcpy(p, uaddrp, sizeof(*p));
+	*addrpp = p;
+	return 0;
+}
+#endif
+
 static void copy_from_user_state(struct xfrm_state *x, struct xfrm_usersa_info *p)
 {
 	memcpy(&x->id, &p->id, sizeof(x->id));
@@ -347,7 +389,10 @@ static struct xfrm_state *xfrm_state_con
 		goto error;
 	if ((err = attach_encap_tmpl(&x->encap, xfrma[XFRMA_ENCAP-1])))
 		goto error;
-
+#ifdef CONFIG_XFRM_ADVANCED
+	if ((err = attach_one_addr(&x->coaddr, xfrma[XFRMA_ADDR-1])))
+		goto error;
+#endif
 	err = xfrm_init_state(x);
 	if (err)
 		goto error;
@@ -526,6 +571,12 @@ static int dump_one_state(struct xfrm_st
 		uctx->ctx_len = x->security->ctx_len;
 		memcpy(uctx + 1, x->security->ctx_str, x->security->ctx_len);
 	}
+
+#ifdef CONFIG_XFRM_ADVANCED
+	if (x->coaddr)
+		RTA_PUT(skb, XFRMA_ADDR, sizeof(*x->coaddr), x->coaddr);
+#endif
+
 	nlh->nlmsg_len = skb->tail - b;
 out:
 	sp->this_idx++;
-- 
1.4.1

