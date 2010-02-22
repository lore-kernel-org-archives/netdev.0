From: jamal <hadi@cyberus.ca>
Subject: [net-next-2.6 PATCH 7/7] xfrm: Allow user space manipulation of SPD mark
Date: Mon, 22 Feb 2010 16:33:00 -0500
Message-ID: <1266874380-29593-8-git-send-email-hadi@cyberus.ca>
References: <xfrm-mark-v3>
 <1266874380-29593-1-git-send-email-hadi@cyberus.ca>
 <1266874380-29593-2-git-send-email-hadi@cyberus.ca>
 <1266874380-29593-3-git-send-email-hadi@cyberus.ca>
 <1266874380-29593-4-git-send-email-hadi@cyberus.ca>
 <1266874380-29593-5-git-send-email-hadi@cyberus.ca>
 <1266874380-29593-6-git-send-email-hadi@cyberus.ca>
 <1266874380-29593-7-git-send-email-hadi@cyberus.ca>
Cc: timo.teras@iki.fi, kaber@trash.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:48471 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634Ab0BVVdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 16:33:32 -0500
Received: by mail-bw0-f209.google.com with SMTP id 1so465337bwz.21
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2010 13:33:31 -0800 (PST)
In-Reply-To: <1266874380-29593-7-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

Add ability for netlink userspace to manipulate the SPD
and manipulate the mark, retrieve it and get events with a defined
mark, etc.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 net/xfrm/xfrm_user.c |   31 +++++++++++++++++++++++++------
 1 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 303092f..6106b72 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -31,8 +31,6 @@
 #include <linux/in6.h>
 #endif
 
-#define DUMMY_MARK 0
-
 static inline int aead_len(struct xfrm_algo_aead *alg)
 {
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
@@ -1234,6 +1232,8 @@ static struct xfrm_policy *xfrm_policy_construct(struct net *net, struct xfrm_us
 	if (err)
 		goto error;
 
+	xfrm_mark_get(attrs, &xp->mark);
+
 	return xp;
  error:
 	*errp = err;
@@ -1380,10 +1380,13 @@ static int dump_one_policy(struct xfrm_policy *xp, int dir, int count, void *ptr
 		goto nlmsg_failure;
 	if (copy_to_user_policy_type(xp->type, skb) < 0)
 		goto nlmsg_failure;
+	if (xfrm_mark_put(skb, &xp->mark))
+		goto nla_put_failure;
 
 	nlmsg_end(skb, nlh);
 	return 0;
 
+nla_put_failure:
 nlmsg_failure:
 	nlmsg_cancel(skb, nlh);
 	return -EMSGSIZE;
@@ -1455,6 +1458,8 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	int err;
 	struct km_event c;
 	int delete;
+	struct xfrm_mark m;
+	u32 mark = xfrm_mark_get(attrs, &m);
 
 	p = nlmsg_data(nlh);
 	delete = nlh->nlmsg_type == XFRM_MSG_DELPOLICY;
@@ -1468,7 +1473,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return err;
 
 	if (p->index)
-		xp = xfrm_policy_byid(net, DUMMY_MARK, type, p->dir, p->index, delete, &err);
+		xp = xfrm_policy_byid(net, mark, type, p->dir, p->index, delete, &err);
 	else {
 		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
 		struct xfrm_sec_ctx *ctx;
@@ -1485,7 +1490,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 			if (err)
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(net, DUMMY_MARK, type, p->dir, &p->sel,
+		xp = xfrm_policy_bysel_ctx(net, mark, type, p->dir, &p->sel,
 					   ctx, delete, &err);
 		security_xfrm_policy_free(ctx);
 	}
@@ -1729,13 +1734,15 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_userpolicy_info *p = &up->pol;
 	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err = -ENOENT;
+	struct xfrm_mark m;
+	u32 mark = xfrm_mark_get(attrs, &m);
 
 	err = copy_from_user_policy_type(&type, attrs);
 	if (err)
 		return err;
 
 	if (p->index)
-		xp = xfrm_policy_byid(net, DUMMY_MARK, type, p->dir, p->index, 0, &err);
+		xp = xfrm_policy_byid(net, mark, type, p->dir, p->index, 0, &err);
 	else {
 		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
 		struct xfrm_sec_ctx *ctx;
@@ -1752,7 +1759,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 			if (err)
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(net, DUMMY_MARK, type, p->dir,
+		xp = xfrm_policy_bysel_ctx(net, mark, type, p->dir,
 					   &p->sel, ctx, 0, &err);
 		security_xfrm_policy_free(ctx);
 	}
@@ -2424,9 +2431,12 @@ static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 		goto nlmsg_failure;
 	if (copy_to_user_policy_type(xp->type, skb) < 0)
 		goto nlmsg_failure;
+	if (xfrm_mark_put(skb, &xp->mark))
+		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
 
+nla_put_failure:
 nlmsg_failure:
 	nlmsg_cancel(skb, nlh);
 	return -EMSGSIZE;
@@ -2513,6 +2523,7 @@ static inline size_t xfrm_polexpire_msgsize(struct xfrm_policy *xp)
 	return NLMSG_ALIGN(sizeof(struct xfrm_user_polexpire))
 	       + nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr)
 	       + nla_total_size(xfrm_user_sec_ctx_size(xp->security))
+	       + nla_total_size(sizeof(struct xfrm_mark))
 	       + userpolicy_type_attrsize();
 }
 
@@ -2535,10 +2546,13 @@ static int build_polexpire(struct sk_buff *skb, struct xfrm_policy *xp,
 		goto nlmsg_failure;
 	if (copy_to_user_policy_type(xp->type, skb) < 0)
 		goto nlmsg_failure;
+	if (xfrm_mark_put(skb, &xp->mark))
+		goto nla_put_failure;
 	upe->hard = !!hard;
 
 	return nlmsg_end(skb, nlh);
 
+nla_put_failure:
 nlmsg_failure:
 	nlmsg_cancel(skb, nlh);
 	return -EMSGSIZE;
@@ -2575,6 +2589,7 @@ static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *
 		headlen = sizeof(*id);
 	}
 	len += userpolicy_type_attrsize();
+	len += nla_total_size(sizeof(struct xfrm_mark));
 	len += NLMSG_ALIGN(headlen);
 
 	skb = nlmsg_new(len, GFP_ATOMIC);
@@ -2610,10 +2625,14 @@ static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *
 	if (copy_to_user_policy_type(xp->type, skb) < 0)
 		goto nlmsg_failure;
 
+	if (xfrm_mark_put(skb, &xp->mark))
+		goto nla_put_failure;
+
 	nlmsg_end(skb, nlh);
 
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
 
+nla_put_failure:
 nlmsg_failure:
 	kfree_skb(skb);
 	return -1;
-- 
1.6.0.4

