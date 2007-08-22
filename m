From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 10/16] [XFRM] netlink: Establish an attribute policy
Date: Wed, 22 Aug 2007 16:55:48 +0200
Message-ID: <20070822145631.206110433@lsx.localdomain>
References: <20070822145538.861270927@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56964 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763202AbXHVP3R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:29:17 -0400
Content-Disposition: inline; filename=xfrm_attr_policy
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds a policy defining the minimal payload lengths for all the attributes
allowing for most attribute validation checks to be removed from in
the middle of the code path. Makes updates more consistent as many format
errors are recognised earlier, before any changes have been attempted.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_user.c	2007-08-21 17:31:04.000000000 +0200
+++ net-2.6.24/net/xfrm/xfrm_user.c	2007-08-21 17:31:56.000000000 +0200
@@ -42,19 +42,12 @@ static int verify_one_alg(struct rtattr 
 {
 	struct rtattr *rt = xfrma[type - 1];
 	struct xfrm_algo *algp;
-	int len;
 
 	if (!rt)
 		return 0;
 
-	len = (rt->rta_len - sizeof(*rt)) - sizeof(*algp);
-	if (len < 0)
-		return -EINVAL;
-
 	algp = RTA_DATA(rt);
-
-	len -= (algp->alg_key_len + 7U) / 8;
-	if (len < 0)
+	if (RTA_PAYLOAD(rt) < alg_len(algp))
 		return -EINVAL;
 
 	switch (type) {
@@ -82,55 +75,25 @@ static int verify_one_alg(struct rtattr 
 	return 0;
 }
 
-static int verify_encap_tmpl(struct rtattr **xfrma)
-{
-	struct rtattr *rt = xfrma[XFRMA_ENCAP - 1];
-	struct xfrm_encap_tmpl *encap;
-
-	if (!rt)
-		return 0;
-
-	if ((rt->rta_len - sizeof(*rt)) < sizeof(*encap))
-		return -EINVAL;
-
-	return 0;
-}
-
-static int verify_one_addr(struct rtattr **xfrma, enum xfrm_attr_type_t type,
+static void verify_one_addr(struct rtattr **xfrma, enum xfrm_attr_type_t type,
 			   xfrm_address_t **addrp)
 {
 	struct rtattr *rt = xfrma[type - 1];
 
-	if (!rt)
-		return 0;
-
-	if ((rt->rta_len - sizeof(*rt)) < sizeof(**addrp))
-		return -EINVAL;
-
-	if (addrp)
+	if (rt && addrp)
 		*addrp = RTA_DATA(rt);
-
-	return 0;
 }
 
 static inline int verify_sec_ctx_len(struct rtattr **xfrma)
 {
 	struct rtattr *rt = xfrma[XFRMA_SEC_CTX - 1];
 	struct xfrm_user_sec_ctx *uctx;
-	int len = 0;
 
 	if (!rt)
 		return 0;
 
-	if (rt->rta_len < sizeof(*uctx))
-		return -EINVAL;
-
 	uctx = RTA_DATA(rt);
-
-	len += sizeof(struct xfrm_user_sec_ctx);
-	len += uctx->ctx_len;
-
-	if (uctx->len != len)
+	if (uctx->len != (sizeof(struct xfrm_user_sec_ctx) + uctx->ctx_len))
 		return -EINVAL;
 
 	return 0;
@@ -205,12 +168,8 @@ static int verify_newsa_info(struct xfrm
 		goto out;
 	if ((err = verify_one_alg(xfrma, XFRMA_ALG_COMP)))
 		goto out;
-	if ((err = verify_encap_tmpl(xfrma)))
-		goto out;
 	if ((err = verify_sec_ctx_len(xfrma)))
 		goto out;
-	if ((err = verify_one_addr(xfrma, XFRMA_COADDR, NULL)))
-		goto out;
 
 	err = -EINVAL;
 	switch (p->mode) {
@@ -339,9 +298,8 @@ static void copy_from_user_state(struct 
  * somehow made shareable and move it to xfrm_state.c - JHS
  *
 */
-static int xfrm_update_ae_params(struct xfrm_state *x, struct rtattr **xfrma)
+static void xfrm_update_ae_params(struct xfrm_state *x, struct rtattr **xfrma)
 {
-	int err = - EINVAL;
 	struct rtattr *rp = xfrma[XFRMA_REPLAY_VAL-1];
 	struct rtattr *lt = xfrma[XFRMA_LTIME_VAL-1];
 	struct rtattr *et = xfrma[XFRMA_ETIMER_THRESH-1];
@@ -349,8 +307,6 @@ static int xfrm_update_ae_params(struct 
 
 	if (rp) {
 		struct xfrm_replay_state *replay;
-		if (RTA_PAYLOAD(rp) < sizeof(*replay))
-			goto error;
 		replay = RTA_DATA(rp);
 		memcpy(&x->replay, replay, sizeof(*replay));
 		memcpy(&x->preplay, replay, sizeof(*replay));
@@ -358,8 +314,6 @@ static int xfrm_update_ae_params(struct 
 
 	if (lt) {
 		struct xfrm_lifetime_cur *ltime;
-		if (RTA_PAYLOAD(lt) < sizeof(*ltime))
-			goto error;
 		ltime = RTA_DATA(lt);
 		x->curlft.bytes = ltime->bytes;
 		x->curlft.packets = ltime->packets;
@@ -367,21 +321,11 @@ static int xfrm_update_ae_params(struct 
 		x->curlft.use_time = ltime->use_time;
 	}
 
-	if (et) {
-		if (RTA_PAYLOAD(et) < sizeof(u32))
-			goto error;
+	if (et)
 		x->replay_maxage = *(u32*)RTA_DATA(et);
-	}
 
-	if (rt) {
-		if (RTA_PAYLOAD(rt) < sizeof(u32))
-			goto error;
+	if (rt)
 		x->replay_maxdiff = *(u32*)RTA_DATA(rt);
-	}
-
-	return 0;
-error:
-	return err;
 }
 
 static struct xfrm_state *xfrm_state_construct(struct xfrm_usersa_info *p,
@@ -429,9 +373,7 @@ static struct xfrm_state *xfrm_state_con
 
 	/* override default values from above */
 
-	err = xfrm_update_ae_params(x, (struct rtattr **)xfrma);
-	if (err	< 0)
-		goto error;
+	xfrm_update_ae_params(x, (struct rtattr **)xfrma);
 
 	return x;
 
@@ -497,10 +439,7 @@ static struct xfrm_state *xfrm_user_stat
 	} else {
 		xfrm_address_t *saddr = NULL;
 
-		err = verify_one_addr(xfrma, XFRMA_SRCADDR, &saddr);
-		if (err)
-			goto out;
-
+		verify_one_addr(xfrma, XFRMA_SRCADDR, &saddr);
 		if (!saddr) {
 			err = -EINVAL;
 			goto out;
@@ -1072,9 +1011,6 @@ static int copy_from_user_policy_type(u8
 	int err;
 
 	if (rt) {
-		if (rt->rta_len < sizeof(*upt))
-			return -EINVAL;
-
 		upt = RTA_DATA(rt);
 		type = upt->type;
 	}
@@ -1537,10 +1473,8 @@ static int xfrm_new_ae(struct sk_buff *s
 		goto out;
 
 	spin_lock_bh(&x->lock);
-	err = xfrm_update_ae_params(x, xfrma);
+	xfrm_update_ae_params(x, xfrma);
 	spin_unlock_bh(&x->lock);
-	if (err	< 0)
-		goto out;
 
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
@@ -1726,20 +1660,6 @@ static int xfrm_add_acquire(struct sk_bu
 }
 
 #ifdef CONFIG_XFRM_MIGRATE
-static int verify_user_migrate(struct rtattr **xfrma)
-{
-	struct rtattr *rt = xfrma[XFRMA_MIGRATE-1];
-	struct xfrm_user_migrate *um;
-
-	if (!rt)
-		return -EINVAL;
-
-	if ((rt->rta_len - sizeof(*rt)) < sizeof(*um))
-		return -EINVAL;
-
-	return 0;
-}
-
 static int copy_from_user_migrate(struct xfrm_migrate *ma,
 				  struct rtattr **xfrma, int *num)
 {
@@ -1780,9 +1700,8 @@ static int xfrm_do_migrate(struct sk_buf
 	int err;
 	int n = 0;
 
-	err = verify_user_migrate((struct rtattr **)xfrma);
-	if (err)
-		return err;
+	if (xfrma[XFRMA_MIGRATE-1] == NULL)
+		return -EINVAL;
 
 	err = copy_from_user_policy_type(&type, (struct rtattr **)xfrma);
 	if (err)
@@ -1917,6 +1836,23 @@ static const int xfrm_msg_min[XFRM_NR_MS
 
 #undef XMSGSIZE
 
+static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
+	[XFRMA_ALG_AUTH]	= { .len = sizeof(struct xfrm_algo) },
+	[XFRMA_ALG_CRYPT]	= { .len = sizeof(struct xfrm_algo) },
+	[XFRMA_ALG_COMP]	= { .len = sizeof(struct xfrm_algo) },
+	[XFRMA_ENCAP]		= { .len = sizeof(struct xfrm_encap_tmpl) },
+	[XFRMA_TMPL]		= { .len = sizeof(struct xfrm_user_tmpl) },
+	[XFRMA_SEC_CTX]		= { .len = sizeof(struct xfrm_sec_ctx) },
+	[XFRMA_LTIME_VAL]	= { .len = sizeof(struct xfrm_lifetime_cur) },
+	[XFRMA_REPLAY_VAL]	= { .len = sizeof(struct xfrm_replay_state) },
+	[XFRMA_REPLAY_THRESH]	= { .type = NLA_U32 },
+	[XFRMA_ETIMER_THRESH]	= { .type = NLA_U32 },
+	[XFRMA_SRCADDR]		= { .len = sizeof(xfrm_address_t) },
+	[XFRMA_COADDR]		= { .len = sizeof(xfrm_address_t) },
+	[XFRMA_POLICY_TYPE]	= { .len = sizeof(struct xfrm_userpolicy_type)},
+	[XFRMA_MIGRATE]		= { .len = sizeof(struct xfrm_user_migrate) },
+};
+
 static struct xfrm_link {
 	int (*doit)(struct sk_buff *, struct nlmsghdr *, struct rtattr **);
 	int (*dump)(struct sk_buff *, struct netlink_callback *);
@@ -1972,7 +1908,8 @@ static int xfrm_user_rcv_msg(struct sk_b
 
 	/* FIXME: Temporary hack, nlmsg_parse() starts at xfrma[1], old code
 	 * expects first attribute at xfrma[0] */
-	err = nlmsg_parse(nlh, xfrm_msg_min[type], xfrma-1, XFRMA_MAX, NULL);
+	err = nlmsg_parse(nlh, xfrm_msg_min[type], xfrma-1, XFRMA_MAX,
+			  xfrma_policy);
 	if (err < 0)
 		return err;
 

-- 

