From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 13/16] [XFRM] netlink: Use nlattr instead of rtattr
Date: Wed, 22 Aug 2007 16:55:51 +0200
Message-ID: <20070822145631.637380607@lsx.localdomain>
References: <20070822145538.861270927@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56961 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763195AbXHVP3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:29:18 -0400
Content-Disposition: inline; filename=xfrm_nlattr
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_user.c	2007-08-21 17:34:29.000000000 +0200
+++ net-2.6.24/net/xfrm/xfrm_user.c	2007-08-21 17:35:13.000000000 +0200
@@ -38,16 +38,16 @@ static inline int alg_len(struct xfrm_al
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
 }
 
-static int verify_one_alg(struct rtattr **attrs, enum xfrm_attr_type_t type)
+static int verify_one_alg(struct nlattr **attrs, enum xfrm_attr_type_t type)
 {
-	struct rtattr *rt = attrs[type];
+	struct nlattr *rt = attrs[type];
 	struct xfrm_algo *algp;
 
 	if (!rt)
 		return 0;
 
-	algp = RTA_DATA(rt);
-	if (RTA_PAYLOAD(rt) < alg_len(algp))
+	algp = nla_data(rt);
+	if (nla_len(rt) < alg_len(algp))
 		return -EINVAL;
 
 	switch (type) {
@@ -75,24 +75,24 @@ static int verify_one_alg(struct rtattr 
 	return 0;
 }
 
-static void verify_one_addr(struct rtattr **attrs, enum xfrm_attr_type_t type,
+static void verify_one_addr(struct nlattr **attrs, enum xfrm_attr_type_t type,
 			   xfrm_address_t **addrp)
 {
-	struct rtattr *rt = attrs[type];
+	struct nlattr *rt = attrs[type];
 
 	if (rt && addrp)
-		*addrp = RTA_DATA(rt);
+		*addrp = nla_data(rt);
 }
 
-static inline int verify_sec_ctx_len(struct rtattr **attrs)
+static inline int verify_sec_ctx_len(struct nlattr **attrs)
 {
-	struct rtattr *rt = attrs[XFRMA_SEC_CTX];
+	struct nlattr *rt = attrs[XFRMA_SEC_CTX];
 	struct xfrm_user_sec_ctx *uctx;
 
 	if (!rt)
 		return 0;
 
-	uctx = RTA_DATA(rt);
+	uctx = nla_data(rt);
 	if (uctx->len != (sizeof(struct xfrm_user_sec_ctx) + uctx->ctx_len))
 		return -EINVAL;
 
@@ -101,7 +101,7 @@ static inline int verify_sec_ctx_len(str
 
 
 static int verify_newsa_info(struct xfrm_usersa_info *p,
-			     struct rtattr **attrs)
+			     struct nlattr **attrs)
 {
 	int err;
 
@@ -191,16 +191,15 @@ out:
 
 static int attach_one_algo(struct xfrm_algo **algpp, u8 *props,
 			   struct xfrm_algo_desc *(*get_byname)(char *, int),
-			   struct rtattr *u_arg)
+			   struct nlattr *rta)
 {
-	struct rtattr *rta = u_arg;
 	struct xfrm_algo *p, *ualg;
 	struct xfrm_algo_desc *algo;
 
 	if (!rta)
 		return 0;
 
-	ualg = RTA_DATA(rta);
+	ualg = nla_data(rta);
 
 	algo = get_byname(ualg->alg_name, 1);
 	if (!algo)
@@ -216,15 +215,14 @@ static int attach_one_algo(struct xfrm_a
 	return 0;
 }
 
-static int attach_encap_tmpl(struct xfrm_encap_tmpl **encapp, struct rtattr *u_arg)
+static int attach_encap_tmpl(struct xfrm_encap_tmpl **encapp, struct nlattr *rta)
 {
-	struct rtattr *rta = u_arg;
 	struct xfrm_encap_tmpl *p, *uencap;
 
 	if (!rta)
 		return 0;
 
-	uencap = RTA_DATA(rta);
+	uencap = nla_data(rta);
 	p = kmemdup(uencap, sizeof(*p), GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
@@ -245,26 +243,25 @@ static inline int xfrm_user_sec_ctx_size
 	return len;
 }
 
-static int attach_sec_ctx(struct xfrm_state *x, struct rtattr *u_arg)
+static int attach_sec_ctx(struct xfrm_state *x, struct nlattr *u_arg)
 {
 	struct xfrm_user_sec_ctx *uctx;
 
 	if (!u_arg)
 		return 0;
 
-	uctx = RTA_DATA(u_arg);
+	uctx = nla_data(u_arg);
 	return security_xfrm_state_alloc(x, uctx);
 }
 
-static int attach_one_addr(xfrm_address_t **addrpp, struct rtattr *u_arg)
+static int attach_one_addr(xfrm_address_t **addrpp, struct nlattr *rta)
 {
-	struct rtattr *rta = u_arg;
 	xfrm_address_t *p, *uaddrp;
 
 	if (!rta)
 		return 0;
 
-	uaddrp = RTA_DATA(rta);
+	uaddrp = nla_data(rta);
 	p = kmemdup(uaddrp, sizeof(*p), GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
@@ -298,23 +295,23 @@ static void copy_from_user_state(struct 
  * somehow made shareable and move it to xfrm_state.c - JHS
  *
 */
-static void xfrm_update_ae_params(struct xfrm_state *x, struct rtattr **attrs)
+static void xfrm_update_ae_params(struct xfrm_state *x, struct nlattr **attrs)
 {
-	struct rtattr *rp = attrs[XFRMA_REPLAY_VAL];
-	struct rtattr *lt = attrs[XFRMA_LTIME_VAL];
-	struct rtattr *et = attrs[XFRMA_ETIMER_THRESH];
-	struct rtattr *rt = attrs[XFRMA_REPLAY_THRESH];
+	struct nlattr *rp = attrs[XFRMA_REPLAY_VAL];
+	struct nlattr *lt = attrs[XFRMA_LTIME_VAL];
+	struct nlattr *et = attrs[XFRMA_ETIMER_THRESH];
+	struct nlattr *rt = attrs[XFRMA_REPLAY_THRESH];
 
 	if (rp) {
 		struct xfrm_replay_state *replay;
-		replay = RTA_DATA(rp);
+		replay = nla_data(rp);
 		memcpy(&x->replay, replay, sizeof(*replay));
 		memcpy(&x->preplay, replay, sizeof(*replay));
 	}
 
 	if (lt) {
 		struct xfrm_lifetime_cur *ltime;
-		ltime = RTA_DATA(lt);
+		ltime = nla_data(lt);
 		x->curlft.bytes = ltime->bytes;
 		x->curlft.packets = ltime->packets;
 		x->curlft.add_time = ltime->add_time;
@@ -322,14 +319,14 @@ static void xfrm_update_ae_params(struct
 	}
 
 	if (et)
-		x->replay_maxage = *(u32*)RTA_DATA(et);
+		x->replay_maxage = nla_get_u32(et);
 
 	if (rt)
-		x->replay_maxdiff = *(u32*)RTA_DATA(rt);
+		x->replay_maxdiff = nla_get_u32(rt);
 }
 
 static struct xfrm_state *xfrm_state_construct(struct xfrm_usersa_info *p,
-					       struct rtattr **attrs,
+					       struct nlattr **attrs,
 					       int *errp)
 {
 	struct xfrm_state *x = xfrm_state_alloc();
@@ -373,7 +370,7 @@ static struct xfrm_state *xfrm_state_con
 
 	/* override default values from above */
 
-	xfrm_update_ae_params(x, (struct rtattr **)attrs);
+	xfrm_update_ae_params(x, attrs);
 
 	return x;
 
@@ -386,7 +383,7 @@ error_no_put:
 }
 
 static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **attrs)
+		struct nlattr **attrs)
 {
 	struct xfrm_usersa_info *p = nlmsg_data(nlh);
 	struct xfrm_state *x;
@@ -427,7 +424,7 @@ out:
 }
 
 static struct xfrm_state *xfrm_user_state_lookup(struct xfrm_usersa_id *p,
-						 struct rtattr **attrs,
+						 struct nlattr **attrs,
 						 int *errp)
 {
 	struct xfrm_state *x = NULL;
@@ -457,7 +454,7 @@ static struct xfrm_state *xfrm_user_stat
 }
 
 static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **attrs)
+		struct nlattr **attrs)
 {
 	struct xfrm_state *x;
 	int err = -ESRCH;
@@ -669,7 +666,7 @@ nla_put_failure:
 }
 
 static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **attrs)
+		struct nlattr **attrs)
 {
 	struct sk_buff *r_skb;
 	u32 *flags = nlmsg_data(nlh);
@@ -722,7 +719,7 @@ nla_put_failure:
 }
 
 static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **attrs)
+		struct nlattr **attrs)
 {
 	struct sk_buff *r_skb;
 	u32 *flags = nlmsg_data(nlh);
@@ -740,7 +737,7 @@ static int xfrm_get_sadinfo(struct sk_bu
 }
 
 static int xfrm_get_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **attrs)
+		struct nlattr **attrs)
 {
 	struct xfrm_usersa_id *p = nlmsg_data(nlh);
 	struct xfrm_state *x;
@@ -786,7 +783,7 @@ static int verify_userspi_info(struct xf
 }
 
 static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **attrs)
+		struct nlattr **attrs)
 {
 	struct xfrm_state *x;
 	struct xfrm_userspi_info *p;
@@ -915,15 +912,15 @@ static int verify_newpolicy_info(struct 
 	return verify_policy_dir(p->dir);
 }
 
-static int copy_from_user_sec_ctx(struct xfrm_policy *pol, struct rtattr **attrs)
+static int copy_from_user_sec_ctx(struct xfrm_policy *pol, struct nlattr **attrs)
 {
-	struct rtattr *rt = attrs[XFRMA_SEC_CTX];
+	struct nlattr *rt = attrs[XFRMA_SEC_CTX];
 	struct xfrm_user_sec_ctx *uctx;
 
 	if (!rt)
 		return 0;
 
-	uctx = RTA_DATA(rt);
+	uctx = nla_data(rt);
 	return security_xfrm_policy_alloc(pol, uctx);
 }
 
@@ -983,35 +980,35 @@ static int validate_tmpl(int nr, struct 
 	return 0;
 }
 
-static int copy_from_user_tmpl(struct xfrm_policy *pol, struct rtattr **attrs)
+static int copy_from_user_tmpl(struct xfrm_policy *pol, struct nlattr **attrs)
 {
-	struct rtattr *rt = attrs[XFRMA_TMPL];
+	struct nlattr *rt = attrs[XFRMA_TMPL];
 
 	if (!rt) {
 		pol->xfrm_nr = 0;
 	} else {
-		struct xfrm_user_tmpl *utmpl = RTA_DATA(rt);
-		int nr = (rt->rta_len - sizeof(*rt)) / sizeof(*utmpl);
+		struct xfrm_user_tmpl *utmpl = nla_data(rt);
+		int nr = nla_len(rt) / sizeof(*utmpl);
 		int err;
 
 		err = validate_tmpl(nr, utmpl, pol->family);
 		if (err)
 			return err;
 
-		copy_templates(pol, RTA_DATA(rt), nr);
+		copy_templates(pol, utmpl, nr);
 	}
 	return 0;
 }
 
-static int copy_from_user_policy_type(u8 *tp, struct rtattr **attrs)
+static int copy_from_user_policy_type(u8 *tp, struct nlattr **attrs)
 {
-	struct rtattr *rt = attrs[XFRMA_POLICY_TYPE];
+	struct nlattr *rt = attrs[XFRMA_POLICY_TYPE];
 	struct xfrm_userpolicy_type *upt;
 	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err;
 
 	if (rt) {
-		upt = RTA_DATA(rt);
+		upt = nla_data(rt);
 		type = upt->type;
 	}
 
@@ -1049,7 +1046,7 @@ static void copy_to_user_policy(struct x
 	p->share = XFRM_SHARE_ANY; /* XXX xp->share */
 }
 
-static struct xfrm_policy *xfrm_policy_construct(struct xfrm_userpolicy_info *p, struct rtattr **attrs, int *errp)
+static struct xfrm_policy *xfrm_policy_construct(struct xfrm_userpolicy_info *p, struct nlattr **attrs, int *errp)
 {
 	struct xfrm_policy *xp = xfrm_policy_alloc(GFP_KERNEL);
 	int err;
@@ -1078,7 +1075,7 @@ static struct xfrm_policy *xfrm_policy_c
 }
 
 static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **attrs)
+		struct nlattr **attrs)
 {
 	struct xfrm_userpolicy_info *p = nlmsg_data(nlh);
 	struct xfrm_policy *xp;
@@ -1271,7 +1268,7 @@ static struct sk_buff *xfrm_policy_netli
 }
 
 static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **attrs)
+		struct nlattr **attrs)
 {
 	struct xfrm_policy *xp;
 	struct xfrm_userpolicy_id *p;
@@ -1294,7 +1291,7 @@ static int xfrm_get_policy(struct sk_buf
 	if (p->index)
 		xp = xfrm_policy_byid(type, p->dir, p->index, delete, &err);
 	else {
-		struct rtattr *rt = attrs[XFRMA_SEC_CTX];
+		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
 		struct xfrm_policy tmp;
 
 		err = verify_sec_ctx_len(attrs);
@@ -1303,7 +1300,7 @@ static int xfrm_get_policy(struct sk_buf
 
 		memset(&tmp, 0, sizeof(struct xfrm_policy));
 		if (rt) {
-			struct xfrm_user_sec_ctx *uctx = RTA_DATA(rt);
+			struct xfrm_user_sec_ctx *uctx = nla_data(rt);
 
 			if ((err = security_xfrm_policy_alloc(&tmp, uctx)))
 				return err;
@@ -1345,7 +1342,7 @@ out:
 }
 
 static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **attrs)
+		struct nlattr **attrs)
 {
 	struct km_event c;
 	struct xfrm_usersa_flush *p = nlmsg_data(nlh);
@@ -1411,7 +1408,7 @@ nla_put_failure:
 }
 
 static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **attrs)
+		struct nlattr **attrs)
 {
 	struct xfrm_state *x;
 	struct sk_buff *r_skb;
@@ -1449,14 +1446,14 @@ static int xfrm_get_ae(struct sk_buff *s
 }
 
 static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **attrs)
+		struct nlattr **attrs)
 {
 	struct xfrm_state *x;
 	struct km_event c;
 	int err = - EINVAL;
 	struct xfrm_aevent_id *p = nlmsg_data(nlh);
-	struct rtattr *rp = attrs[XFRMA_REPLAY_VAL];
-	struct rtattr *lt = attrs[XFRMA_LTIME_VAL];
+	struct nlattr *rp = attrs[XFRMA_REPLAY_VAL];
+	struct nlattr *lt = attrs[XFRMA_LTIME_VAL];
 
 	if (!lt && !rp)
 		return err;
@@ -1488,7 +1485,7 @@ out:
 }
 
 static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **attrs)
+		struct nlattr **attrs)
 {
 	struct km_event c;
 	u8 type = XFRM_POLICY_TYPE_MAIN;
@@ -1513,7 +1510,7 @@ static int xfrm_flush_policy(struct sk_b
 }
 
 static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **attrs)
+		struct nlattr **attrs)
 {
 	struct xfrm_policy *xp;
 	struct xfrm_user_polexpire *up = nlmsg_data(nlh);
@@ -1528,7 +1525,7 @@ static int xfrm_add_pol_expire(struct sk
 	if (p->index)
 		xp = xfrm_policy_byid(type, p->dir, p->index, 0, &err);
 	else {
-		struct rtattr *rt = attrs[XFRMA_SEC_CTX];
+		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
 		struct xfrm_policy tmp;
 
 		err = verify_sec_ctx_len(attrs);
@@ -1537,7 +1534,7 @@ static int xfrm_add_pol_expire(struct sk
 
 		memset(&tmp, 0, sizeof(struct xfrm_policy));
 		if (rt) {
-			struct xfrm_user_sec_ctx *uctx = RTA_DATA(rt);
+			struct xfrm_user_sec_ctx *uctx = nla_data(rt);
 
 			if ((err = security_xfrm_policy_alloc(&tmp, uctx)))
 				return err;
@@ -1574,7 +1571,7 @@ out:
 }
 
 static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **attrs)
+		struct nlattr **attrs)
 {
 	struct xfrm_state *x;
 	int err;
@@ -1606,12 +1603,12 @@ out:
 }
 
 static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **attrs)
+		struct nlattr **attrs)
 {
 	struct xfrm_policy *xp;
 	struct xfrm_user_tmpl *ut;
 	int i;
-	struct rtattr *rt = attrs[XFRMA_TMPL];
+	struct nlattr *rt = attrs[XFRMA_TMPL];
 
 	struct xfrm_user_acquire *ua = nlmsg_data(nlh);
 	struct xfrm_state *x = xfrm_state_alloc();
@@ -1628,7 +1625,7 @@ static int xfrm_add_acquire(struct sk_bu
 	}
 
 	/*   build an XP */
-	xp = xfrm_policy_construct(&ua->policy, (struct rtattr **) attrs, &err);
+	xp = xfrm_policy_construct(&ua->policy, attrs, &err);
 	if (!xp) {
 		kfree(x);
 		return err;
@@ -1638,7 +1635,7 @@ static int xfrm_add_acquire(struct sk_bu
 	memcpy(&x->props.saddr, &ua->saddr, sizeof(ua->saddr));
 	memcpy(&x->sel, &ua->sel, sizeof(ua->sel));
 
-	ut = RTA_DATA(rt);
+	ut = nla_data(rt);
 	/* extract the templates and for each call km_key */
 	for (i = 0; i < xp->xfrm_nr; i++, ut++) {
 		struct xfrm_tmpl *t = &xp->xfrm_vec[i];
@@ -1661,14 +1658,14 @@ static int xfrm_add_acquire(struct sk_bu
 
 #ifdef CONFIG_XFRM_MIGRATE
 static int copy_from_user_migrate(struct xfrm_migrate *ma,
-				  struct rtattr **attrs, int *num)
+				  struct nlattr **attrs, int *num)
 {
-	struct rtattr *rt = attrs[XFRMA_MIGRATE];
+	struct nlattr *rt = attrs[XFRMA_MIGRATE];
 	struct xfrm_user_migrate *um;
 	int i, num_migrate;
 
-	um = RTA_DATA(rt);
-	num_migrate = (rt->rta_len - sizeof(*rt)) / sizeof(*um);
+	um = nla_data(rt);
+	num_migrate = nla_len(rt) / sizeof(*um);
 
 	if (num_migrate <= 0 || num_migrate > XFRM_MAX_DEPTH)
 		return -EINVAL;
@@ -1692,7 +1689,7 @@ static int copy_from_user_migrate(struct
 }
 
 static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
-			   struct rtattr **attrs)
+			   struct nlattr **attrs)
 {
 	struct xfrm_userpolicy_id *pi = nlmsg_data(nlh);
 	struct xfrm_migrate m[XFRM_MAX_DEPTH];
@@ -1703,12 +1700,12 @@ static int xfrm_do_migrate(struct sk_buf
 	if (attrs[XFRMA_MIGRATE] == NULL)
 		return -EINVAL;
 
-	err = copy_from_user_policy_type(&type, (struct rtattr **)attrs);
+	err = copy_from_user_policy_type(&type, attrs);
 	if (err)
 		return err;
 
 	err = copy_from_user_migrate((struct xfrm_migrate *)m,
-				     (struct rtattr **)attrs, &n);
+				     attrs, &n);
 	if (err)
 		return err;
 
@@ -1721,7 +1718,7 @@ static int xfrm_do_migrate(struct sk_buf
 }
 #else
 static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
-			   struct rtattr **attrs)
+			   struct nlattr **attrs)
 {
 	return -ENOPROTOOPT;
 }
@@ -1854,7 +1851,7 @@ static const struct nla_policy xfrma_pol
 };
 
 static struct xfrm_link {
-	int (*doit)(struct sk_buff *, struct nlmsghdr *, struct rtattr **);
+	int (*doit)(struct sk_buff *, struct nlmsghdr *, struct nlattr **);
 	int (*dump)(struct sk_buff *, struct netlink_callback *);
 } xfrm_dispatch[XFRM_NR_MSGTYPES] = {
 	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] = { .doit = xfrm_add_sa        },
@@ -1914,7 +1911,7 @@ static int xfrm_user_rcv_msg(struct sk_b
 	if (link->doit == NULL)
 		return -EINVAL;
 
-	return link->doit(skb, nlh, (struct rtattr **) attrs);
+	return link->doit(skb, nlh, attrs);
 }
 
 static void xfrm_netlink_rcv(struct sock *sk, int len)

-- 

