From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 11/16] [XFRM] netlink: Enhance indexing of the attribute array
Date: Wed, 22 Aug 2007 16:55:49 +0200
Message-ID: <20070822145631.348072934@lsx.localdomain>
References: <20070822145538.861270927@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56970 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763227AbXHVP3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:29:18 -0400
Content-Disposition: inline; filename=xfrm_attr_index
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nlmsg_parse() puts attributes at array[type] so the indexing
method can be simpilfied by removing the obscuring "- 1".

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_user.c	2007-08-21 17:31:56.000000000 +0200
+++ net-2.6.24/net/xfrm/xfrm_user.c	2007-08-21 17:34:10.000000000 +0200
@@ -40,7 +40,7 @@ static inline int alg_len(struct xfrm_al
 
 static int verify_one_alg(struct rtattr **xfrma, enum xfrm_attr_type_t type)
 {
-	struct rtattr *rt = xfrma[type - 1];
+	struct rtattr *rt = xfrma[type];
 	struct xfrm_algo *algp;
 
 	if (!rt)
@@ -78,7 +78,7 @@ static int verify_one_alg(struct rtattr 
 static void verify_one_addr(struct rtattr **xfrma, enum xfrm_attr_type_t type,
 			   xfrm_address_t **addrp)
 {
-	struct rtattr *rt = xfrma[type - 1];
+	struct rtattr *rt = xfrma[type];
 
 	if (rt && addrp)
 		*addrp = RTA_DATA(rt);
@@ -86,7 +86,7 @@ static void verify_one_addr(struct rtatt
 
 static inline int verify_sec_ctx_len(struct rtattr **xfrma)
 {
-	struct rtattr *rt = xfrma[XFRMA_SEC_CTX - 1];
+	struct rtattr *rt = xfrma[XFRMA_SEC_CTX];
 	struct xfrm_user_sec_ctx *uctx;
 
 	if (!rt)
@@ -125,35 +125,35 @@ static int verify_newsa_info(struct xfrm
 	err = -EINVAL;
 	switch (p->id.proto) {
 	case IPPROTO_AH:
-		if (!xfrma[XFRMA_ALG_AUTH-1]	||
-		    xfrma[XFRMA_ALG_CRYPT-1]	||
-		    xfrma[XFRMA_ALG_COMP-1])
+		if (!xfrma[XFRMA_ALG_AUTH]	||
+		    xfrma[XFRMA_ALG_CRYPT]	||
+		    xfrma[XFRMA_ALG_COMP])
 			goto out;
 		break;
 
 	case IPPROTO_ESP:
-		if ((!xfrma[XFRMA_ALG_AUTH-1] &&
-		     !xfrma[XFRMA_ALG_CRYPT-1])	||
-		    xfrma[XFRMA_ALG_COMP-1])
+		if ((!xfrma[XFRMA_ALG_AUTH] &&
+		     !xfrma[XFRMA_ALG_CRYPT])	||
+		    xfrma[XFRMA_ALG_COMP])
 			goto out;
 		break;
 
 	case IPPROTO_COMP:
-		if (!xfrma[XFRMA_ALG_COMP-1]	||
-		    xfrma[XFRMA_ALG_AUTH-1]	||
-		    xfrma[XFRMA_ALG_CRYPT-1])
+		if (!xfrma[XFRMA_ALG_COMP]	||
+		    xfrma[XFRMA_ALG_AUTH]	||
+		    xfrma[XFRMA_ALG_CRYPT])
 			goto out;
 		break;
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case IPPROTO_DSTOPTS:
 	case IPPROTO_ROUTING:
-		if (xfrma[XFRMA_ALG_COMP-1]	||
-		    xfrma[XFRMA_ALG_AUTH-1]	||
-		    xfrma[XFRMA_ALG_CRYPT-1]	||
-		    xfrma[XFRMA_ENCAP-1]	||
-		    xfrma[XFRMA_SEC_CTX-1]	||
-		    !xfrma[XFRMA_COADDR-1])
+		if (xfrma[XFRMA_ALG_COMP]	||
+		    xfrma[XFRMA_ALG_AUTH]	||
+		    xfrma[XFRMA_ALG_CRYPT]	||
+		    xfrma[XFRMA_ENCAP]		||
+		    xfrma[XFRMA_SEC_CTX]	||
+		    !xfrma[XFRMA_COADDR])
 			goto out;
 		break;
 #endif
@@ -300,10 +300,10 @@ static void copy_from_user_state(struct 
 */
 static void xfrm_update_ae_params(struct xfrm_state *x, struct rtattr **xfrma)
 {
-	struct rtattr *rp = xfrma[XFRMA_REPLAY_VAL-1];
-	struct rtattr *lt = xfrma[XFRMA_LTIME_VAL-1];
-	struct rtattr *et = xfrma[XFRMA_ETIMER_THRESH-1];
-	struct rtattr *rt = xfrma[XFRMA_REPLAY_THRESH-1];
+	struct rtattr *rp = xfrma[XFRMA_REPLAY_VAL];
+	struct rtattr *lt = xfrma[XFRMA_LTIME_VAL];
+	struct rtattr *et = xfrma[XFRMA_ETIMER_THRESH];
+	struct rtattr *rt = xfrma[XFRMA_REPLAY_THRESH];
 
 	if (rp) {
 		struct xfrm_replay_state *replay;
@@ -342,25 +342,25 @@ static struct xfrm_state *xfrm_state_con
 
 	if ((err = attach_one_algo(&x->aalg, &x->props.aalgo,
 				   xfrm_aalg_get_byname,
-				   xfrma[XFRMA_ALG_AUTH-1])))
+				   xfrma[XFRMA_ALG_AUTH])))
 		goto error;
 	if ((err = attach_one_algo(&x->ealg, &x->props.ealgo,
 				   xfrm_ealg_get_byname,
-				   xfrma[XFRMA_ALG_CRYPT-1])))
+				   xfrma[XFRMA_ALG_CRYPT])))
 		goto error;
 	if ((err = attach_one_algo(&x->calg, &x->props.calgo,
 				   xfrm_calg_get_byname,
-				   xfrma[XFRMA_ALG_COMP-1])))
+				   xfrma[XFRMA_ALG_COMP])))
 		goto error;
-	if ((err = attach_encap_tmpl(&x->encap, xfrma[XFRMA_ENCAP-1])))
+	if ((err = attach_encap_tmpl(&x->encap, xfrma[XFRMA_ENCAP])))
 		goto error;
-	if ((err = attach_one_addr(&x->coaddr, xfrma[XFRMA_COADDR-1])))
+	if ((err = attach_one_addr(&x->coaddr, xfrma[XFRMA_COADDR])))
 		goto error;
 	err = xfrm_init_state(x);
 	if (err)
 		goto error;
 
-	if ((err = attach_sec_ctx(x, xfrma[XFRMA_SEC_CTX-1])))
+	if ((err = attach_sec_ctx(x, xfrma[XFRMA_SEC_CTX])))
 		goto error;
 
 	x->km.seq = p->seq;
@@ -917,7 +917,7 @@ static int verify_newpolicy_info(struct 
 
 static int copy_from_user_sec_ctx(struct xfrm_policy *pol, struct rtattr **xfrma)
 {
-	struct rtattr *rt = xfrma[XFRMA_SEC_CTX-1];
+	struct rtattr *rt = xfrma[XFRMA_SEC_CTX];
 	struct xfrm_user_sec_ctx *uctx;
 
 	if (!rt)
@@ -985,7 +985,7 @@ static int validate_tmpl(int nr, struct 
 
 static int copy_from_user_tmpl(struct xfrm_policy *pol, struct rtattr **xfrma)
 {
-	struct rtattr *rt = xfrma[XFRMA_TMPL-1];
+	struct rtattr *rt = xfrma[XFRMA_TMPL];
 
 	if (!rt) {
 		pol->xfrm_nr = 0;
@@ -1005,7 +1005,7 @@ static int copy_from_user_tmpl(struct xf
 
 static int copy_from_user_policy_type(u8 *tp, struct rtattr **xfrma)
 {
-	struct rtattr *rt = xfrma[XFRMA_POLICY_TYPE-1];
+	struct rtattr *rt = xfrma[XFRMA_POLICY_TYPE];
 	struct xfrm_userpolicy_type *upt;
 	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err;
@@ -1294,7 +1294,7 @@ static int xfrm_get_policy(struct sk_buf
 	if (p->index)
 		xp = xfrm_policy_byid(type, p->dir, p->index, delete, &err);
 	else {
-		struct rtattr *rt = xfrma[XFRMA_SEC_CTX-1];
+		struct rtattr *rt = xfrma[XFRMA_SEC_CTX];
 		struct xfrm_policy tmp;
 
 		err = verify_sec_ctx_len(xfrma);
@@ -1455,8 +1455,8 @@ static int xfrm_new_ae(struct sk_buff *s
 	struct km_event c;
 	int err = - EINVAL;
 	struct xfrm_aevent_id *p = nlmsg_data(nlh);
-	struct rtattr *rp = xfrma[XFRMA_REPLAY_VAL-1];
-	struct rtattr *lt = xfrma[XFRMA_LTIME_VAL-1];
+	struct rtattr *rp = xfrma[XFRMA_REPLAY_VAL];
+	struct rtattr *lt = xfrma[XFRMA_LTIME_VAL];
 
 	if (!lt && !rp)
 		return err;
@@ -1528,7 +1528,7 @@ static int xfrm_add_pol_expire(struct sk
 	if (p->index)
 		xp = xfrm_policy_byid(type, p->dir, p->index, 0, &err);
 	else {
-		struct rtattr *rt = xfrma[XFRMA_SEC_CTX-1];
+		struct rtattr *rt = xfrma[XFRMA_SEC_CTX];
 		struct xfrm_policy tmp;
 
 		err = verify_sec_ctx_len(xfrma);
@@ -1611,7 +1611,7 @@ static int xfrm_add_acquire(struct sk_bu
 	struct xfrm_policy *xp;
 	struct xfrm_user_tmpl *ut;
 	int i;
-	struct rtattr *rt = xfrma[XFRMA_TMPL-1];
+	struct rtattr *rt = xfrma[XFRMA_TMPL];
 
 	struct xfrm_user_acquire *ua = nlmsg_data(nlh);
 	struct xfrm_state *x = xfrm_state_alloc();
@@ -1663,7 +1663,7 @@ static int xfrm_add_acquire(struct sk_bu
 static int copy_from_user_migrate(struct xfrm_migrate *ma,
 				  struct rtattr **xfrma, int *num)
 {
-	struct rtattr *rt = xfrma[XFRMA_MIGRATE-1];
+	struct rtattr *rt = xfrma[XFRMA_MIGRATE];
 	struct xfrm_user_migrate *um;
 	int i, num_migrate;
 
@@ -1700,7 +1700,7 @@ static int xfrm_do_migrate(struct sk_buf
 	int err;
 	int n = 0;
 
-	if (xfrma[XFRMA_MIGRATE-1] == NULL)
+	if (xfrma[XFRMA_MIGRATE] == NULL)
 		return -EINVAL;
 
 	err = copy_from_user_policy_type(&type, (struct rtattr **)xfrma);
@@ -1906,9 +1906,7 @@ static int xfrm_user_rcv_msg(struct sk_b
 		return netlink_dump_start(xfrm_nl, skb, nlh, link->dump, NULL);
 	}
 
-	/* FIXME: Temporary hack, nlmsg_parse() starts at xfrma[1], old code
-	 * expects first attribute at xfrma[0] */
-	err = nlmsg_parse(nlh, xfrm_msg_min[type], xfrma-1, XFRMA_MAX,
+	err = nlmsg_parse(nlh, xfrm_msg_min[type], xfrma, XFRMA_MAX,
 			  xfrma_policy);
 	if (err < 0)
 		return err;

-- 

