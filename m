From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 02/16] [XFRM] netlink: Use nlmsg_end() and nlmsg_cancel()
Date: Wed, 22 Aug 2007 16:55:40 +0200
Message-ID: <20070822145630.052210318@lsx.localdomain>
References: <20070822145538.861270927@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56957 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763108AbXHVP3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:29:16 -0400
Content-Disposition: inline; filename=xfrm_nlmsg_end
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_user.c	2007-08-21 16:10:34.000000000 +0200
+++ net-2.6.24/net/xfrm/xfrm_user.c	2007-08-21 16:12:20.000000000 +0200
@@ -583,7 +583,6 @@ static int dump_one_state(struct xfrm_st
 	struct sk_buff *skb = sp->out_skb;
 	struct xfrm_usersa_info *p;
 	struct nlmsghdr *nlh;
-	unsigned char *b = skb_tail_pointer(skb);
 
 	if (sp->this_idx < sp->start_idx)
 		goto out;
@@ -628,14 +627,14 @@ static int dump_one_state(struct xfrm_st
 	if (x->lastused)
 		RTA_PUT(skb, XFRMA_LASTUSED, sizeof(x->lastused), &x->lastused);
 
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
+	nlmsg_end(skb, nlh);
 out:
 	sp->this_idx++;
 	return 0;
 
 rtattr_failure:
-	nlmsg_trim(skb, b);
-	return -1;
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
@@ -1270,7 +1269,6 @@ static int dump_one_policy(struct xfrm_p
 	struct sk_buff *in_skb = sp->in_skb;
 	struct sk_buff *skb = sp->out_skb;
 	struct nlmsghdr *nlh;
-	unsigned char *b = skb_tail_pointer(skb);
 
 	if (sp->this_idx < sp->start_idx)
 		goto out;
@@ -1289,14 +1287,14 @@ static int dump_one_policy(struct xfrm_p
 	if (copy_to_user_policy_type(xp->type, skb) < 0)
 		goto nlmsg_failure;
 
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
+	nlmsg_end(skb, nlh);
 out:
 	sp->this_idx++;
 	return 0;
 
 nlmsg_failure:
-	nlmsg_trim(skb, b);
-	return -1;
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 static int xfrm_dump_policy(struct sk_buff *skb, struct netlink_callback *cb)
@@ -1446,7 +1444,6 @@ static int build_aevent(struct sk_buff *
 	struct xfrm_aevent_id *id;
 	struct nlmsghdr *nlh;
 	struct xfrm_lifetime_cur ltime;
-	unsigned char *b = skb_tail_pointer(skb);
 
 	nlh = nlmsg_put(skb, c->pid, c->seq, XFRM_MSG_NEWAE, sizeof(*id), 0);
 	if (nlh == NULL)
@@ -1479,12 +1476,11 @@ static int build_aevent(struct sk_buff *
 		RTA_PUT(skb,XFRMA_ETIMER_THRESH,sizeof(u32),&etimer);
 	}
 
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
-	return skb->len;
+	return nlmsg_end(skb, nlh);
 
 rtattr_failure:
-	nlmsg_trim(skb, b);
-	return -1;
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
@@ -1862,7 +1858,6 @@ static int build_migrate(struct sk_buff 
 	struct xfrm_migrate *mp;
 	struct xfrm_userpolicy_id *pol_id;
 	struct nlmsghdr *nlh;
-	unsigned char *b = skb_tail_pointer(skb);
 	int i;
 
 	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_MIGRATE, sizeof(*pol_id), 0);
@@ -1883,11 +1878,10 @@ static int build_migrate(struct sk_buff 
 			goto nlmsg_failure;
 	}
 
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
-	return skb->len;
+	return nlmsg_end(skb, nlh);
 nlmsg_failure:
-	nlmsg_trim(skb, b);
-	return -1;
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 static int xfrm_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
@@ -2043,7 +2037,6 @@ static int build_expire(struct sk_buff *
 {
 	struct xfrm_user_expire *ue;
 	struct nlmsghdr *nlh;
-	unsigned char *b = skb_tail_pointer(skb);
 
 	nlh = nlmsg_put(skb, c->pid, 0, XFRM_MSG_EXPIRE, sizeof(*ue), 0);
 	if (nlh == NULL)
@@ -2053,8 +2046,7 @@ static int build_expire(struct sk_buff *
 	copy_to_user_state(x, &ue->state);
 	ue->hard = (c->data.hard != 0) ? 1 : 0;
 
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
-	return skb->len;
+	return nlmsg_end(skb, nlh);
 }
 
 static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
@@ -2096,13 +2088,11 @@ static int xfrm_notify_sa_flush(struct k
 	struct xfrm_usersa_flush *p;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
-	sk_buff_data_t b;
 	int len = NLMSG_LENGTH(sizeof(struct xfrm_usersa_flush));
 
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
-	b = skb->tail;
 
 	nlh = nlmsg_put(skb, c->pid, c->seq, XFRM_MSG_FLUSHSA, sizeof(*p), 0);
 	if (nlh == NULL) {
@@ -2113,7 +2103,7 @@ static int xfrm_notify_sa_flush(struct k
 	p = NLMSG_DATA(nlh);
 	p->proto = c->data.proto;
 
-	nlh->nlmsg_len = skb->tail - b;
+	nlmsg_end(skb, nlh);
 
 	NETLINK_CB(skb).dst_group = XFRMNLGRP_SA;
 	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
@@ -2140,7 +2130,6 @@ static int xfrm_notify_sa(struct xfrm_st
 	struct xfrm_usersa_id *id;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
-	sk_buff_data_t b;
 	int len = xfrm_sa_len(x);
 	int headlen;
 
@@ -2154,7 +2143,6 @@ static int xfrm_notify_sa(struct xfrm_st
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
-	b = skb->tail;
 
 	nlh = nlmsg_put(skb, c->pid, c->seq, c->event, headlen, 0);
 	if (nlh == NULL)
@@ -2185,7 +2173,7 @@ static int xfrm_notify_sa(struct xfrm_st
 	if (x->encap)
 		RTA_PUT(skb, XFRMA_ENCAP, sizeof(*x->encap), x->encap);
 
-	nlh->nlmsg_len = skb->tail - b;
+	nlmsg_end(skb, nlh);
 
 	NETLINK_CB(skb).dst_group = XFRMNLGRP_SA;
 	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
@@ -2225,7 +2213,6 @@ static int build_acquire(struct sk_buff 
 {
 	struct xfrm_user_acquire *ua;
 	struct nlmsghdr *nlh;
-	unsigned char *b = skb_tail_pointer(skb);
 	__u32 seq = xfrm_get_acqseq();
 
 	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_ACQUIRE, sizeof(*ua), 0);
@@ -2249,12 +2236,11 @@ static int build_acquire(struct sk_buff 
 	if (copy_to_user_policy_type(xp->type, skb) < 0)
 		goto nlmsg_failure;
 
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
-	return skb->len;
+	return nlmsg_end(skb, nlh);
 
 nlmsg_failure:
-	nlmsg_trim(skb, b);
-	return -1;
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *xt,
@@ -2345,7 +2331,6 @@ static int build_polexpire(struct sk_buf
 	struct xfrm_user_polexpire *upe;
 	struct nlmsghdr *nlh;
 	int hard = c->data.hard;
-	unsigned char *b = skb_tail_pointer(skb);
 
 	nlh = nlmsg_put(skb, c->pid, 0, XFRM_MSG_POLEXPIRE, sizeof(*upe), 0);
 	if (nlh == NULL)
@@ -2361,12 +2346,11 @@ static int build_polexpire(struct sk_buf
 		goto nlmsg_failure;
 	upe->hard = !!hard;
 
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
-	return skb->len;
+	return nlmsg_end(skb, nlh);
 
 nlmsg_failure:
-	nlmsg_trim(skb, b);
-	return -1;
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
@@ -2397,7 +2381,6 @@ static int xfrm_notify_policy(struct xfr
 	struct xfrm_userpolicy_id *id;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
-	sk_buff_data_t b;
 	int len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
 	int headlen;
 
@@ -2414,7 +2397,6 @@ static int xfrm_notify_policy(struct xfr
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
-	b = skb->tail;
 
 	nlh = nlmsg_put(skb, c->pid, c->seq, c->event, headlen, 0);
 	if (nlh == NULL)
@@ -2439,7 +2421,7 @@ static int xfrm_notify_policy(struct xfr
 	if (copy_to_user_policy_type(xp->type, skb) < 0)
 		goto nlmsg_failure;
 
-	nlh->nlmsg_len = skb->tail - b;
+	nlmsg_end(skb, nlh);
 
 	NETLINK_CB(skb).dst_group = XFRMNLGRP_POLICY;
 	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
@@ -2454,7 +2436,6 @@ static int xfrm_notify_policy_flush(stru
 {
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
-	sk_buff_data_t b;
 	int len = 0;
 #ifdef CONFIG_XFRM_SUB_POLICY
 	len += RTA_SPACE(sizeof(struct xfrm_userpolicy_type));
@@ -2464,8 +2445,6 @@ static int xfrm_notify_policy_flush(stru
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
-	b = skb->tail;
-
 
 	nlh = nlmsg_put(skb, c->pid, c->seq, XFRM_MSG_FLUSHPOLICY, 0, 0);
 	if (nlh == NULL)
@@ -2473,7 +2452,7 @@ static int xfrm_notify_policy_flush(stru
 	if (copy_to_user_policy_type(c->data.type, skb) < 0)
 		goto nlmsg_failure;
 
-	nlh->nlmsg_len = skb->tail - b;
+	nlmsg_end(skb, nlh);
 
 	NETLINK_CB(skb).dst_group = XFRMNLGRP_POLICY;
 	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
@@ -2508,7 +2487,6 @@ static int build_report(struct sk_buff *
 {
 	struct xfrm_user_report *ur;
 	struct nlmsghdr *nlh;
-	unsigned char *b = skb_tail_pointer(skb);
 
 	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_REPORT, sizeof(*ur), 0);
 	if (nlh == NULL)
@@ -2521,12 +2499,11 @@ static int build_report(struct sk_buff *
 	if (addr)
 		RTA_PUT(skb, XFRMA_COADDR, sizeof(*addr), addr);
 
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
-	return skb->len;
+	return nlmsg_end(skb, nlh);
 
 rtattr_failure:
-	nlmsg_trim(skb, b);
-	return -1;
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 static int xfrm_send_report(u8 proto, struct xfrm_selector *sel,

-- 

