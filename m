From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 08/16] [XFRM] netlink: Use nlmsg_new() and type-safe size calculation helpers
Date: Wed, 22 Aug 2007 16:55:46 +0200
Message-ID: <20070822145630.911737091@lsx.localdomain>
References: <20070822145538.861270927@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56953 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763095AbXHVP3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:29:16 -0400
Content-Disposition: inline; filename=nlmsg_new
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Moves all complex message size calculation into own inlined helper
functions and makes use of the type-safe netlink interface.

Using nlmsg_new() simplifies the calculation itself as it takes care
of the netlink header length by itself.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_user.c	2007-08-21 17:04:46.000000000 +0200
+++ net-2.6.24/net/xfrm/xfrm_user.c	2007-08-21 17:07:38.000000000 +0200
@@ -670,7 +670,7 @@ static struct sk_buff *xfrm_state_netlin
 	struct xfrm_dump_info info;
 	struct sk_buff *skb;
 
-	skb = alloc_skb(NLMSG_GOODSIZE, GFP_ATOMIC);
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
@@ -688,6 +688,13 @@ static struct sk_buff *xfrm_state_netlin
 	return skb;
 }
 
+static inline size_t xfrm_spdinfo_msgsize(void)
+{
+	return NLMSG_ALIGN(4)
+	       + nla_total_size(sizeof(struct xfrmu_spdinfo))
+	       + nla_total_size(sizeof(struct xfrmu_spdhinfo));
+}
+
 static int build_spdinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
 {
 	struct xfrmk_spdinfo si;
@@ -729,12 +736,8 @@ static int xfrm_get_spdinfo(struct sk_bu
 	u32 *flags = nlmsg_data(nlh);
 	u32 spid = NETLINK_CB(skb).pid;
 	u32 seq = nlh->nlmsg_seq;
-	int len = NLMSG_LENGTH(sizeof(u32));
 
-	len += RTA_SPACE(sizeof(struct xfrmu_spdinfo));
-	len += RTA_SPACE(sizeof(struct xfrmu_spdhinfo));
-
-	r_skb = alloc_skb(len, GFP_ATOMIC);
+	r_skb = nlmsg_new(xfrm_spdinfo_msgsize(), GFP_ATOMIC);
 	if (r_skb == NULL)
 		return -ENOMEM;
 
@@ -744,6 +747,13 @@ static int xfrm_get_spdinfo(struct sk_bu
 	return nlmsg_unicast(xfrm_nl, r_skb, spid);
 }
 
+static inline size_t xfrm_sadinfo_msgsize(void)
+{
+	return NLMSG_ALIGN(4)
+	       + nla_total_size(sizeof(struct xfrmu_sadhinfo))
+	       + nla_total_size(4); /* XFRMA_SAD_CNT */
+}
+
 static int build_sadinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
 {
 	struct xfrmk_sadinfo si;
@@ -779,13 +789,8 @@ static int xfrm_get_sadinfo(struct sk_bu
 	u32 *flags = nlmsg_data(nlh);
 	u32 spid = NETLINK_CB(skb).pid;
 	u32 seq = nlh->nlmsg_seq;
-	int len = NLMSG_LENGTH(sizeof(u32));
-
-	len += RTA_SPACE(sizeof(struct xfrmu_sadhinfo));
-	len += RTA_SPACE(sizeof(u32));
-
-	r_skb = alloc_skb(len, GFP_ATOMIC);
 
+	r_skb = nlmsg_new(xfrm_sadinfo_msgsize(), GFP_ATOMIC);
 	if (r_skb == NULL)
 		return -ENOMEM;
 
@@ -1311,7 +1316,7 @@ static struct sk_buff *xfrm_policy_netli
 	struct xfrm_dump_info info;
 	struct sk_buff *skb;
 
-	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
@@ -1425,6 +1430,14 @@ static int xfrm_flush_sa(struct sk_buff 
 	return 0;
 }
 
+static inline size_t xfrm_aevent_msgsize(void)
+{
+	return NLMSG_ALIGN(sizeof(struct xfrm_aevent_id))
+	       + nla_total_size(sizeof(struct xfrm_replay_state))
+	       + nla_total_size(sizeof(struct xfrm_lifetime_cur))
+	       + nla_total_size(4) /* XFRM_AE_RTHR */
+	       + nla_total_size(4); /* XFRM_AE_ETHR */
+}
 
 static int build_aevent(struct sk_buff *skb, struct xfrm_state *x, struct km_event *c)
 {
@@ -1469,19 +1482,9 @@ static int xfrm_get_ae(struct sk_buff *s
 	int err;
 	struct km_event c;
 	struct xfrm_aevent_id *p = nlmsg_data(nlh);
-	int len = NLMSG_LENGTH(sizeof(struct xfrm_aevent_id));
 	struct xfrm_usersa_id *id = &p->sa_id;
 
-	len += RTA_SPACE(sizeof(struct xfrm_replay_state));
-	len += RTA_SPACE(sizeof(struct xfrm_lifetime_cur));
-
-	if (p->flags&XFRM_AE_RTHR)
-		len+=RTA_SPACE(sizeof(u32));
-
-	if (p->flags&XFRM_AE_ETHR)
-		len+=RTA_SPACE(sizeof(u32));
-
-	r_skb = alloc_skb(len, GFP_ATOMIC);
+	r_skb = nlmsg_new(xfrm_aevent_msgsize(), GFP_ATOMIC);
 	if (r_skb == NULL)
 		return -ENOMEM;
 
@@ -1824,6 +1827,13 @@ static int copy_to_user_migrate(struct x
 	return nla_put(skb, XFRMA_MIGRATE, sizeof(um), &um);
 }
 
+static inline size_t xfrm_migrate_msgsize(int num_migrate)
+{
+	return NLMSG_ALIGN(sizeof(struct xfrm_userpolicy_id))
+	       + nla_total_size(sizeof(struct xfrm_user_migrate) * num_migrate)
+	       + userpolicy_type_attrsize();
+}
+
 static int build_migrate(struct sk_buff *skb, struct xfrm_migrate *m,
 			 int num_migrate, struct xfrm_selector *sel,
 			 u8 dir, u8 type)
@@ -1861,12 +1871,8 @@ static int xfrm_send_migrate(struct xfrm
 			     struct xfrm_migrate *m, int num_migrate)
 {
 	struct sk_buff *skb;
-	size_t len;
 
-	len = RTA_SPACE(sizeof(struct xfrm_user_migrate) * num_migrate);
-	len += NLMSG_SPACE(sizeof(struct xfrm_userpolicy_id));
-	len += userpolicy_type_attrsize();
-	skb = alloc_skb(len, GFP_ATOMIC);
+	skb = nlmsg_new(xfrm_migrate_msgsize(num_migrate), GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
@@ -2002,6 +2008,11 @@ static void xfrm_netlink_rcv(struct sock
 	} while (qlen);
 }
 
+static inline size_t xfrm_expire_msgsize(void)
+{
+	return NLMSG_ALIGN(sizeof(struct xfrm_user_expire));
+}
+
 static int build_expire(struct sk_buff *skb, struct xfrm_state *x, struct km_event *c)
 {
 	struct xfrm_user_expire *ue;
@@ -2021,9 +2032,8 @@ static int build_expire(struct sk_buff *
 static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
 {
 	struct sk_buff *skb;
-	int len = NLMSG_LENGTH(sizeof(struct xfrm_user_expire));
 
-	skb = alloc_skb(len, GFP_ATOMIC);
+	skb = nlmsg_new(xfrm_expire_msgsize(), GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
@@ -2036,11 +2046,8 @@ static int xfrm_exp_state_notify(struct 
 static int xfrm_aevent_state_notify(struct xfrm_state *x, struct km_event *c)
 {
 	struct sk_buff *skb;
-	int len = NLMSG_LENGTH(sizeof(struct xfrm_aevent_id));
 
-	len += RTA_SPACE(sizeof(struct xfrm_replay_state));
-	len += RTA_SPACE(sizeof(struct xfrm_lifetime_cur));
-	skb = alloc_skb(len, GFP_ATOMIC);
+	skb = nlmsg_new(xfrm_aevent_msgsize(), GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
@@ -2055,9 +2062,9 @@ static int xfrm_notify_sa_flush(struct k
 	struct xfrm_usersa_flush *p;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
-	int len = NLMSG_LENGTH(sizeof(struct xfrm_usersa_flush));
+	int len = NLMSG_ALIGN(sizeof(struct xfrm_usersa_flush));
 
-	skb = alloc_skb(len, GFP_ATOMIC);
+	skb = nlmsg_new(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
@@ -2075,17 +2082,17 @@ static int xfrm_notify_sa_flush(struct k
 	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
 }
 
-static inline int xfrm_sa_len(struct xfrm_state *x)
+static inline size_t xfrm_sa_len(struct xfrm_state *x)
 {
-	int l = 0;
+	size_t l = 0;
 	if (x->aalg)
-		l += RTA_SPACE(alg_len(x->aalg));
+		l += nla_total_size(alg_len(x->aalg));
 	if (x->ealg)
-		l += RTA_SPACE(alg_len(x->ealg));
+		l += nla_total_size(alg_len(x->ealg));
 	if (x->calg)
-		l += RTA_SPACE(sizeof(*x->calg));
+		l += nla_total_size(sizeof(*x->calg));
 	if (x->encap)
-		l += RTA_SPACE(sizeof(*x->encap));
+		l += nla_total_size(sizeof(*x->encap));
 
 	return l;
 }
@@ -2101,12 +2108,12 @@ static int xfrm_notify_sa(struct xfrm_st
 
 	headlen = sizeof(*p);
 	if (c->event == XFRM_MSG_DELSA) {
-		len += RTA_SPACE(headlen);
+		len += nla_total_size(headlen);
 		headlen = sizeof(*id);
 	}
-	len += NLMSG_SPACE(headlen);
+	len += NLMSG_ALIGN(headlen);
 
-	skb = alloc_skb(len, GFP_ATOMIC);
+	skb = nlmsg_new(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
@@ -2175,6 +2182,15 @@ static int xfrm_send_state_notify(struct
 
 }
 
+static inline size_t xfrm_acquire_msgsize(struct xfrm_state *x,
+					  struct xfrm_policy *xp)
+{
+	return NLMSG_ALIGN(sizeof(struct xfrm_user_acquire))
+	       + nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr)
+	       + nla_total_size(xfrm_user_sec_ctx_size(x->security))
+	       + userpolicy_type_attrsize();
+}
+
 static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 			 struct xfrm_tmpl *xt, struct xfrm_policy *xp,
 			 int dir)
@@ -2215,13 +2231,8 @@ static int xfrm_send_acquire(struct xfrm
 			     struct xfrm_policy *xp, int dir)
 {
 	struct sk_buff *skb;
-	size_t len;
 
-	len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
-	len += NLMSG_SPACE(sizeof(struct xfrm_user_acquire));
-	len += RTA_SPACE(xfrm_user_sec_ctx_size(x->security));
-	len += userpolicy_type_attrsize();
-	skb = alloc_skb(len, GFP_ATOMIC);
+	skb = nlmsg_new(xfrm_acquire_msgsize(x, xp), GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
@@ -2290,6 +2301,14 @@ static struct xfrm_policy *xfrm_compile_
 	return xp;
 }
 
+static inline size_t xfrm_polexpire_msgsize(struct xfrm_policy *xp)
+{
+	return NLMSG_ALIGN(sizeof(struct xfrm_user_polexpire))
+	       + nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr)
+	       + nla_total_size(xfrm_user_sec_ctx_size(xp->security))
+	       + userpolicy_type_attrsize();
+}
+
 static int build_polexpire(struct sk_buff *skb, struct xfrm_policy *xp,
 			   int dir, struct km_event *c)
 {
@@ -2321,13 +2340,8 @@ nlmsg_failure:
 static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
 {
 	struct sk_buff *skb;
-	size_t len;
 
-	len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
-	len += NLMSG_SPACE(sizeof(struct xfrm_user_polexpire));
-	len += RTA_SPACE(xfrm_user_sec_ctx_size(xp->security));
-	len += userpolicy_type_attrsize();
-	skb = alloc_skb(len, GFP_ATOMIC);
+	skb = nlmsg_new(xfrm_polexpire_msgsize(xp), GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
@@ -2343,18 +2357,18 @@ static int xfrm_notify_policy(struct xfr
 	struct xfrm_userpolicy_id *id;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
-	int len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
+	int len = nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
 	int headlen;
 
 	headlen = sizeof(*p);
 	if (c->event == XFRM_MSG_DELPOLICY) {
-		len += RTA_SPACE(headlen);
+		len += nla_total_size(headlen);
 		headlen = sizeof(*id);
 	}
 	len += userpolicy_type_attrsize();
-	len += NLMSG_SPACE(headlen);
+	len += NLMSG_ALIGN(headlen);
 
-	skb = alloc_skb(len, GFP_ATOMIC);
+	skb = nlmsg_new(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
@@ -2400,11 +2414,8 @@ static int xfrm_notify_policy_flush(stru
 {
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
-	int len = 0;
-	len += userpolicy_type_attrsize();
-	len += NLMSG_LENGTH(0);
 
-	skb = alloc_skb(len, GFP_ATOMIC);
+	skb = nlmsg_new(userpolicy_type_attrsize(), GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
@@ -2443,6 +2454,11 @@ static int xfrm_send_policy_notify(struc
 
 }
 
+static inline size_t xfrm_report_msgsize(void)
+{
+	return NLMSG_ALIGN(sizeof(struct xfrm_user_report));
+}
+
 static int build_report(struct sk_buff *skb, u8 proto,
 			struct xfrm_selector *sel, xfrm_address_t *addr)
 {
@@ -2471,10 +2487,8 @@ static int xfrm_send_report(u8 proto, st
 			    xfrm_address_t *addr)
 {
 	struct sk_buff *skb;
-	size_t len;
 
-	len = NLMSG_ALIGN(NLMSG_LENGTH(sizeof(struct xfrm_user_report)));
-	skb = alloc_skb(len, GFP_ATOMIC);
+	skb = nlmsg_new(xfrm_report_msgsize(), GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 

-- 

