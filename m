From: jamal <hadi@cyberus.ca>
Subject: [net-next-2.6 PATCH 6/7] xfrm: Allow user space config of SAD mark
Date: Sun, 14 Feb 2010 10:18:51 -0500
Message-ID: <1266160732-946-7-git-send-email-hadi@cyberus.ca>
References: <xfrm-mark-net-next>
 <1266160732-946-1-git-send-email-hadi@cyberus.ca>
 <1266160732-946-2-git-send-email-hadi@cyberus.ca>
 <1266160732-946-3-git-send-email-hadi@cyberus.ca>
 <1266160732-946-4-git-send-email-hadi@cyberus.ca>
 <1266160732-946-5-git-send-email-hadi@cyberus.ca>
 <1266160732-946-6-git-send-email-hadi@cyberus.ca>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: timo.teras@iki.fi, kaber@trash.net, herbert@gondor.apana.org.au,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f200.google.com ([209.85.221.200]:36241 "EHLO
	mail-qy0-f200.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353Ab0BNPTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 10:19:12 -0500
Received: by mail-qy0-f200.google.com with SMTP id 38so1534948qyk.1
        for <netdev@vger.kernel.org>; Sun, 14 Feb 2010 07:19:11 -0800 (PST)
In-Reply-To: <1266160732-946-6-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

Add ability for netlink userspace to manipulate the SAD
and manipulate the mark, retrieve it and get events with a defined
mark.
MIGRATE may be added later.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 net/xfrm/xfrm_user.c |   72 +++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 57 insertions(+), 15 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 6abe4c0..57b38a3 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -32,7 +32,6 @@
 #endif
 
 #define DUMMY_MARK 0
-static struct xfrm_kmark dummy_mark = {0, 0};
 
 static inline int aead_len(struct xfrm_algo_aead *alg)
 {
@@ -449,6 +448,8 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 			goto error;
 	}
 
+	xfrm_mark_get(attrs, &x->mark);
+
 	err = xfrm_init_state(x);
 	if (err)
 		goto error;
@@ -529,11 +530,13 @@ static struct xfrm_state *xfrm_user_state_lookup(struct net *net,
 						 int *errp)
 {
 	struct xfrm_state *x = NULL;
+	struct xfrm_kmark m;
 	int err;
+	u32 mark = xfrm_mark_get(attrs, &m);
 
 	if (xfrm_id_proto_match(p->proto, IPSEC_PROTO_ANY)) {
 		err = -ESRCH;
-		x = xfrm_state_lookup(net, DUMMY_MARK, &p->daddr, p->spi, p->proto, p->family);
+		x = xfrm_state_lookup(net, mark, &p->daddr, p->spi, p->proto, p->family);
 	} else {
 		xfrm_address_t *saddr = NULL;
 
@@ -544,7 +547,8 @@ static struct xfrm_state *xfrm_user_state_lookup(struct net *net,
 		}
 
 		err = -ESRCH;
-		x = xfrm_state_lookup_byaddr(net, DUMMY_MARK, &p->daddr, saddr,
+		x = xfrm_state_lookup_byaddr(net, mark,
+					     &p->daddr, saddr,
 					     p->proto, p->family);
 	}
 
@@ -686,6 +690,9 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 	if (x->encap)
 		NLA_PUT(skb, XFRMA_ENCAP, sizeof(*x->encap), x->encap);
 
+	if (xfrm_mark_put(skb, &x->mark))
+		goto nla_put_failure;
+
 	if (x->security && copy_sec_ctx(x->security, skb) < 0)
 		goto nla_put_failure;
 
@@ -950,6 +957,8 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 	xfrm_address_t *daddr;
 	int family;
 	int err;
+	u32 mark;
+	struct xfrm_kmark m;
 
 	p = nlmsg_data(nlh);
 	err = verify_userspi_info(p);
@@ -960,8 +969,10 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 	daddr = &p->info.id.daddr;
 
 	x = NULL;
+
+	mark = xfrm_mark_get(attrs, &m);
 	if (p->info.seq) {
-		x = xfrm_find_acq_byseq(net, DUMMY_MARK, p->info.seq);
+		x = xfrm_find_acq_byseq(net, mark, p->info.seq);
 		if (x && xfrm_addr_cmp(&x->id.daddr, daddr, family)) {
 			xfrm_state_put(x);
 			x = NULL;
@@ -969,7 +980,7 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 	}
 
 	if (!x)
-		x = xfrm_find_acq(net, &dummy_mark, p->info.mode, p->info.reqid,
+		x = xfrm_find_acq(net, &m, p->info.mode, p->info.reqid,
 				  p->info.id.proto, daddr,
 				  &p->info.saddr, 1,
 				  family);
@@ -1474,8 +1485,8 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 			if (err)
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(net, DUMMY_MARK, type, p->dir,
-					   &p->sel, ctx, delete, &err);
+		xp = xfrm_policy_bysel_ctx(net, DUMMY_MARK, type, p->dir, &p->sel,
+					   ctx, delete, &err);
 		security_xfrm_policy_free(ctx);
 	}
 	if (xp == NULL)
@@ -1544,6 +1555,7 @@ static inline size_t xfrm_aevent_msgsize(void)
 	return NLMSG_ALIGN(sizeof(struct xfrm_aevent_id))
 	       + nla_total_size(sizeof(struct xfrm_replay_state))
 	       + nla_total_size(sizeof(struct xfrm_lifetime_cur))
+	       + nla_total_size(sizeof(struct xfrm_umark))
 	       + nla_total_size(4) /* XFRM_AE_RTHR */
 	       + nla_total_size(4); /* XFRM_AE_ETHR */
 }
@@ -1576,6 +1588,9 @@ static int build_aevent(struct sk_buff *skb, struct xfrm_state *x, struct km_eve
 		NLA_PUT_U32(skb, XFRMA_ETIMER_THRESH,
 			    x->replay_maxage * 10 / HZ);
 
+	if (xfrm_mark_put(skb, &x->mark))
+		goto nla_put_failure;
+
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
@@ -1591,6 +1606,8 @@ static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct sk_buff *r_skb;
 	int err;
 	struct km_event c;
+	u32 mark;
+	struct xfrm_kmark m;
 	struct xfrm_aevent_id *p = nlmsg_data(nlh);
 	struct xfrm_usersa_id *id = &p->sa_id;
 
@@ -1598,7 +1615,9 @@ static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (r_skb == NULL)
 		return -ENOMEM;
 
-	x = xfrm_state_lookup(net, DUMMY_MARK, &id->daddr, id->spi, id->proto, id->family);
+	mark = xfrm_mark_get(attrs, &m);
+
+	x = xfrm_state_lookup(net, mark, &id->daddr, id->spi, id->proto, id->family);
 	if (x == NULL) {
 		kfree_skb(r_skb);
 		return -ESRCH;
@@ -1629,6 +1648,8 @@ static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_state *x;
 	struct km_event c;
 	int err = - EINVAL;
+	u32 mark = 0;
+	struct xfrm_kmark m;
 	struct xfrm_aevent_id *p = nlmsg_data(nlh);
 	struct nlattr *rp = attrs[XFRMA_REPLAY_VAL];
 	struct nlattr *lt = attrs[XFRMA_LTIME_VAL];
@@ -1640,7 +1661,9 @@ static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (!(nlh->nlmsg_flags&NLM_F_REPLACE))
 		return err;
 
-	x = xfrm_state_lookup(net, DUMMY_MARK, &p->sa_id.daddr, p->sa_id.spi, p->sa_id.proto, p->sa_id.family);
+	mark = xfrm_mark_get(attrs, &m);
+
+	x = xfrm_state_lookup(net, mark, &p->sa_id.daddr, p->sa_id.spi, p->sa_id.proto, p->sa_id.family);
 	if (x == NULL)
 		return -ESRCH;
 
@@ -1722,7 +1745,8 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 			if (err)
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(net, DUMMY_MARK, type, p->dir, &p->sel, ctx, 0, &err);
+		xp = xfrm_policy_bysel_ctx(net, DUMMY_MARK, type, p->dir,
+					   &p->sel, ctx, 0, &err);
 		security_xfrm_policy_free(ctx);
 	}
 	if (xp == NULL)
@@ -1762,8 +1786,10 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	int err;
 	struct xfrm_user_expire *ue = nlmsg_data(nlh);
 	struct xfrm_usersa_info *p = &ue->state;
+	struct xfrm_kmark m;
+	u32 mark = xfrm_mark_get(attrs, &m);;
 
-	x = xfrm_state_lookup(net, DUMMY_MARK, &p->id.daddr, p->id.spi, p->id.proto, p->family);
+	x = xfrm_state_lookup(net, mark, &p->id.daddr, p->id.spi, p->id.proto, p->family);
 
 	err = -ENOENT;
 	if (x == NULL)
@@ -1797,6 +1823,7 @@ static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_user_tmpl *ut;
 	int i;
 	struct nlattr *rt = attrs[XFRMA_TMPL];
+	struct xfrm_kmark mark;
 
 	struct xfrm_user_acquire *ua = nlmsg_data(nlh);
 	struct xfrm_state *x = xfrm_state_alloc(net);
@@ -1805,6 +1832,8 @@ static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (!x)
 		goto nomem;
 
+	xfrm_mark_get(attrs, &mark);
+
 	err = verify_newpolicy_info(&ua->policy);
 	if (err)
 		goto bad_policy;
@@ -1817,7 +1846,8 @@ static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	memcpy(&x->id, &ua->id, sizeof(ua->id));
 	memcpy(&x->props.saddr, &ua->saddr, sizeof(ua->saddr));
 	memcpy(&x->sel, &ua->sel, sizeof(ua->sel));
-
+	xp->mark.m = x->mark.m = mark.m;
+	xp->mark.v = x->mark.v = mark.v;
 	ut = nla_data(rt);
 	/* extract the templates and for each call km_key */
 	for (i = 0; i < xp->xfrm_nr; i++, ut++) {
@@ -2077,6 +2107,7 @@ static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
 	[XFRMA_POLICY_TYPE]	= { .len = sizeof(struct xfrm_userpolicy_type)},
 	[XFRMA_MIGRATE]		= { .len = sizeof(struct xfrm_user_migrate) },
 	[XFRMA_KMADDRESS]	= { .len = sizeof(struct xfrm_user_kmaddress) },
+	[XFRMA_MARK]		= { .len = sizeof(struct xfrm_umark) },
 };
 
 static struct xfrm_link {
@@ -2156,7 +2187,8 @@ static void xfrm_netlink_rcv(struct sk_buff *skb)
 
 static inline size_t xfrm_expire_msgsize(void)
 {
-	return NLMSG_ALIGN(sizeof(struct xfrm_user_expire));
+	return NLMSG_ALIGN(sizeof(struct xfrm_user_expire))
+	       + nla_total_size(sizeof(struct xfrm_umark));
 }
 
 static int build_expire(struct sk_buff *skb, struct xfrm_state *x, struct km_event *c)
@@ -2172,7 +2204,13 @@ static int build_expire(struct sk_buff *skb, struct xfrm_state *x, struct km_eve
 	copy_to_user_state(x, &ue->state);
 	ue->hard = (c->data.hard != 0) ? 1 : 0;
 
+	if (xfrm_mark_put(skb, &x->mark))
+		goto nla_put_failure;
+
 	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	return -EMSGSIZE;
 }
 
 static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
@@ -2184,8 +2222,10 @@ static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_expire(skb, x, c) < 0)
-		BUG();
+	if (build_expire(skb, x, c) < 0) {
+		kfree_skb(skb);
+		return -EMSGSIZE;
+	}
 
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
 }
@@ -2273,6 +2313,7 @@ static int xfrm_notify_sa(struct xfrm_state *x, struct km_event *c)
 	if (c->event == XFRM_MSG_DELSA) {
 		len += nla_total_size(headlen);
 		headlen = sizeof(*id);
+		len += nla_total_size(sizeof(struct xfrm_umark));
 	}
 	len += NLMSG_ALIGN(headlen);
 
@@ -2343,6 +2384,7 @@ static inline size_t xfrm_acquire_msgsize(struct xfrm_state *x,
 {
 	return NLMSG_ALIGN(sizeof(struct xfrm_user_acquire))
 	       + nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr)
+	       + nla_total_size(sizeof(struct xfrm_umark))
 	       + nla_total_size(xfrm_user_sec_ctx_size(x->security))
 	       + userpolicy_type_attrsize();
 }
-- 
1.6.0.4

