From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 16/16] [XFRM] netlink: Inline attach_encap_tmpl(), attach_sec_ctx(), and attach_one_addr()
Date: Wed, 22 Aug 2007 16:55:54 +0200
Message-ID: <20070822145632.087638328@lsx.localdomain>
References: <20070822145538.861270927@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56960 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763171AbXHVP3R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:29:17 -0400
Content-Disposition: inline; filename=xfrm_inline_attach_one_addr
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These functions are only used once and are a lot easier to understand if
inlined directly into the function.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_user.c	2007-08-21 23:05:30.000000000 +0200
+++ net-2.6.24/net/xfrm/xfrm_user.c	2007-08-22 16:45:31.000000000 +0200
@@ -214,23 +214,6 @@ static int attach_one_algo(struct xfrm_a
 	return 0;
 }
 
-static int attach_encap_tmpl(struct xfrm_encap_tmpl **encapp, struct nlattr *rta)
-{
-	struct xfrm_encap_tmpl *p, *uencap;
-
-	if (!rta)
-		return 0;
-
-	uencap = nla_data(rta);
-	p = kmemdup(uencap, sizeof(*p), GFP_KERNEL);
-	if (!p)
-		return -ENOMEM;
-
-	*encapp = p;
-	return 0;
-}
-
-
 static inline int xfrm_user_sec_ctx_size(struct xfrm_sec_ctx *xfrm_ctx)
 {
 	int len = 0;
@@ -242,33 +225,6 @@ static inline int xfrm_user_sec_ctx_size
 	return len;
 }
 
-static int attach_sec_ctx(struct xfrm_state *x, struct nlattr *u_arg)
-{
-	struct xfrm_user_sec_ctx *uctx;
-
-	if (!u_arg)
-		return 0;
-
-	uctx = nla_data(u_arg);
-	return security_xfrm_state_alloc(x, uctx);
-}
-
-static int attach_one_addr(xfrm_address_t **addrpp, struct nlattr *rta)
-{
-	xfrm_address_t *p, *uaddrp;
-
-	if (!rta)
-		return 0;
-
-	uaddrp = nla_data(rta);
-	p = kmemdup(uaddrp, sizeof(*p), GFP_KERNEL);
-	if (!p)
-		return -ENOMEM;
-
-	*addrpp = p;
-	return 0;
-}
-
 static void copy_from_user_state(struct xfrm_state *x, struct xfrm_usersa_info *p)
 {
 	memcpy(&x->id, &p->id, sizeof(x->id));
@@ -340,15 +296,27 @@ static struct xfrm_state *xfrm_state_con
 				   xfrm_calg_get_byname,
 				   attrs[XFRMA_ALG_COMP])))
 		goto error;
-	if ((err = attach_encap_tmpl(&x->encap, attrs[XFRMA_ENCAP])))
-		goto error;
-	if ((err = attach_one_addr(&x->coaddr, attrs[XFRMA_COADDR])))
-		goto error;
+
+	if (attrs[XFRMA_ENCAP]) {
+		x->encap = kmemdup(nla_data(attrs[XFRMA_ENCAP]),
+				   sizeof(x->encap), GFP_KERNEL);
+		if (x->encap == NULL)
+			goto error;
+	}
+
+	if (attrs[XFRMA_COADDR]) {
+		x->coaddr = kmemdup(nla_data(attrs[XFRMA_COADDR]),
+				    sizeof(x->coaddr), GFP_KERNEL);
+		if (x->coaddr == NULL)
+			goto error;
+	}
+
 	err = xfrm_init_state(x);
 	if (err)
 		goto error;
 
-	if ((err = attach_sec_ctx(x, attrs[XFRMA_SEC_CTX])))
+	if (attrs[XFRMA_SEC_CTX] &&
+	    security_xfrm_state_alloc(x, nla_data(attrs[XFRMA_SEC_CTX])))
 		goto error;
 
 	x->km.seq = p->seq;

-- 

