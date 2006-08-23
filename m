From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 14/44] [XFRM] STATE: Introduce care-of address.
Date: Thu, 24 Aug 2006 00:02:15 +0900
Message-ID: <11563453663761-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>,
	Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:65160 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964926AbWHWPCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:50 -0400
To: davem@davemloft.net
In-Reply-To: <1156345366857-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Care-of address is carried by state as a transformation option like IPsec
encryption/authentication algorithm.
Based on MIPL2 kernel patch.

Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/xfrm.h  |    1 +
 include/net/xfrm.h    |    3 +++
 net/xfrm/xfrm_state.c |    6 ++++++
 net/xfrm/xfrm_user.c  |   28 +++++++++++++++++++++++++++-
 4 files changed, 37 insertions(+), 1 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index a7c9e4c..b53f799 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -235,6 +235,7 @@ enum xfrm_attr_type_t {
 	XFRMA_REPLAY_THRESH,
 	XFRMA_ETIMER_THRESH,
 	XFRMA_SRCADDR,		/* xfrm_address_t */
+	XFRMA_COADDR,		/* xfrm_address_t */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index e451fed..aeee0e2 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -135,6 +135,9 @@ struct xfrm_state
 	/* Data for encapsulator */
 	struct xfrm_encap_tmpl	*encap;
 
+	/* Data for care-of address */
+	xfrm_address_t	*coaddr;
+
 	/* IPComp needs an IPIP tunnel for handling uncompressed packets */
 	struct xfrm_state	*tunnel;
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f053715..3da89c0 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -78,6 +78,7 @@ static void xfrm_state_gc_destroy(struct
 	kfree(x->ealg);
 	kfree(x->calg);
 	kfree(x->encap);
+	kfree(x->coaddr);
 	if (x->mode)
 		xfrm_put_mode(x->mode);
 	if (x->type) {
@@ -603,6 +604,11 @@ out:
 	if (likely(x1->km.state == XFRM_STATE_VALID)) {
 		if (x->encap && x1->encap)
 			memcpy(x1->encap, x->encap, sizeof(*x1->encap));
+		if (x->coaddr && x1->coaddr) {
+			memcpy(x1->coaddr, x->coaddr, sizeof(*x1->coaddr));
+		}
+		if (!use_spi && memcmp(&x1->sel, &x->sel, sizeof(x1->sel)))
+			memcpy(&x1->sel, &x->sel, sizeof(x1->sel));
 		memcpy(&x1->lft, &x->lft, sizeof(x1->lft));
 		x1->km.dying = 0;
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 9eaea73..41a02d6 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -186,11 +186,14 @@ #endif
 		goto out;
 	if ((err = verify_sec_ctx_len(xfrma)))
 		goto out;
+	if ((err = verify_one_addr(xfrma, XFRMA_COADDR, NULL)))
+		goto out;
 
 	err = -EINVAL;
 	switch (p->mode) {
 	case XFRM_MODE_TRANSPORT:
 	case XFRM_MODE_TUNNEL:
+	case XFRM_MODE_ROUTEOPTIMIZATION:
 		break;
 
 	default:
@@ -274,6 +277,24 @@ static int attach_sec_ctx(struct xfrm_st
 	return security_xfrm_state_alloc(x, uctx);
 }
 
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
+
 static void copy_from_user_state(struct xfrm_state *x, struct xfrm_usersa_info *p)
 {
 	memcpy(&x->id, &p->id, sizeof(x->id));
@@ -363,7 +384,8 @@ static struct xfrm_state *xfrm_state_con
 		goto error;
 	if ((err = attach_encap_tmpl(&x->encap, xfrma[XFRMA_ENCAP-1])))
 		goto error;
-
+	if ((err = attach_one_addr(&x->coaddr, xfrma[XFRMA_COADDR-1])))
+		goto error;
 	err = xfrm_init_state(x);
 	if (err)
 		goto error;
@@ -567,6 +589,10 @@ static int dump_one_state(struct xfrm_st
 		uctx->ctx_len = x->security->ctx_len;
 		memcpy(uctx + 1, x->security->ctx_str, x->security->ctx_len);
 	}
+
+	if (x->coaddr)
+		RTA_PUT(skb, XFRMA_COADDR, sizeof(*x->coaddr), x->coaddr);
+
 	nlh->nlmsg_len = skb->tail - b;
 out:
 	sp->this_idx++;
-- 
1.4.0

