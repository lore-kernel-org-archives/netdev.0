From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 05/16] [XFRM] netlink: Use nla_put()/NLA_PUT() variantes
Date: Wed, 22 Aug 2007 16:55:43 +0200
Message-ID: <20070822145630.481426233@lsx.localdomain>
References: <20070822145538.861270927@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56967 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763105AbXHVP3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:29:18 -0400
Content-Disposition: inline; filename=xfrm_nla_put
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also makes use of copy_sec_ctx() in another place and removes
duplicated code.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_user.c	2007-08-21 16:15:03.000000000 +0200
+++ net-2.6.24/net/xfrm/xfrm_user.c	2007-08-21 16:16:03.000000000 +0200
@@ -576,6 +576,27 @@ struct xfrm_dump_info {
 	int this_idx;
 };
 
+static int copy_sec_ctx(struct xfrm_sec_ctx *s, struct sk_buff *skb)
+{
+	int ctx_size = sizeof(struct xfrm_sec_ctx) + s->ctx_len;
+	struct xfrm_user_sec_ctx *uctx;
+	struct nlattr *attr;
+
+	attr = nla_reserve(skb, XFRMA_SEC_CTX, ctx_size);
+	if (attr == NULL)
+		return -EMSGSIZE;
+
+	uctx = nla_data(attr);
+	uctx->exttype = XFRMA_SEC_CTX;
+	uctx->len = ctx_size;
+	uctx->ctx_doi = s->ctx_doi;
+	uctx->ctx_alg = s->ctx_alg;
+	uctx->ctx_len = s->ctx_len;
+	memcpy(uctx + 1, s->ctx_str, s->ctx_len);
+
+	return 0;
+}
+
 static int dump_one_state(struct xfrm_state *x, int count, void *ptr)
 {
 	struct xfrm_dump_info *sp = ptr;
@@ -596,43 +617,32 @@ static int dump_one_state(struct xfrm_st
 	copy_to_user_state(x, p);
 
 	if (x->aalg)
-		RTA_PUT(skb, XFRMA_ALG_AUTH,
+		NLA_PUT(skb, XFRMA_ALG_AUTH,
 			sizeof(*(x->aalg))+(x->aalg->alg_key_len+7)/8, x->aalg);
 	if (x->ealg)
-		RTA_PUT(skb, XFRMA_ALG_CRYPT,
+		NLA_PUT(skb, XFRMA_ALG_CRYPT,
 			sizeof(*(x->ealg))+(x->ealg->alg_key_len+7)/8, x->ealg);
 	if (x->calg)
-		RTA_PUT(skb, XFRMA_ALG_COMP, sizeof(*(x->calg)), x->calg);
+		NLA_PUT(skb, XFRMA_ALG_COMP, sizeof(*(x->calg)), x->calg);
 
 	if (x->encap)
-		RTA_PUT(skb, XFRMA_ENCAP, sizeof(*x->encap), x->encap);
+		NLA_PUT(skb, XFRMA_ENCAP, sizeof(*x->encap), x->encap);
 
-	if (x->security) {
-		int ctx_size = sizeof(struct xfrm_sec_ctx) +
-				x->security->ctx_len;
-		struct rtattr *rt = __RTA_PUT(skb, XFRMA_SEC_CTX, ctx_size);
-		struct xfrm_user_sec_ctx *uctx = RTA_DATA(rt);
-
-		uctx->exttype = XFRMA_SEC_CTX;
-		uctx->len = ctx_size;
-		uctx->ctx_doi = x->security->ctx_doi;
-		uctx->ctx_alg = x->security->ctx_alg;
-		uctx->ctx_len = x->security->ctx_len;
-		memcpy(uctx + 1, x->security->ctx_str, x->security->ctx_len);
-	}
+	if (x->security && copy_sec_ctx(x->security, skb) < 0)
+		goto nla_put_failure;
 
 	if (x->coaddr)
-		RTA_PUT(skb, XFRMA_COADDR, sizeof(*x->coaddr), x->coaddr);
+		NLA_PUT(skb, XFRMA_COADDR, sizeof(*x->coaddr), x->coaddr);
 
 	if (x->lastused)
-		RTA_PUT(skb, XFRMA_LASTUSED, sizeof(x->lastused), &x->lastused);
+		NLA_PUT_U64(skb, XFRMA_LASTUSED, x->lastused);
 
 	nlmsg_end(skb, nlh);
 out:
 	sp->this_idx++;
 	return 0;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_cancel(skb, nlh);
 	return -EMSGSIZE;
 }
@@ -1193,32 +1203,9 @@ static int copy_to_user_tmpl(struct xfrm
 		up->ealgos = kp->ealgos;
 		up->calgos = kp->calgos;
 	}
-	RTA_PUT(skb, XFRMA_TMPL,
-		(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr),
-		vec);
-
-	return 0;
-
-rtattr_failure:
-	return -1;
-}
-
-static int copy_sec_ctx(struct xfrm_sec_ctx *s, struct sk_buff *skb)
-{
-	int ctx_size = sizeof(struct xfrm_sec_ctx) + s->ctx_len;
-	struct rtattr *rt = __RTA_PUT(skb, XFRMA_SEC_CTX, ctx_size);
-	struct xfrm_user_sec_ctx *uctx = RTA_DATA(rt);
-
-	uctx->exttype = XFRMA_SEC_CTX;
-	uctx->len = ctx_size;
-	uctx->ctx_doi = s->ctx_doi;
-	uctx->ctx_alg = s->ctx_alg;
-	uctx->ctx_len = s->ctx_len;
-	memcpy(uctx + 1, s->ctx_str, s->ctx_len);
-	return 0;
 
- rtattr_failure:
-	return -1;
+	return nla_put(skb, XFRMA_TMPL,
+		       sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr, vec);
 }
 
 static inline int copy_to_user_state_sec_ctx(struct xfrm_state *x, struct sk_buff *skb)
@@ -1240,17 +1227,11 @@ static inline int copy_to_user_sec_ctx(s
 #ifdef CONFIG_XFRM_SUB_POLICY
 static int copy_to_user_policy_type(u8 type, struct sk_buff *skb)
 {
-	struct xfrm_userpolicy_type upt;
+	struct xfrm_userpolicy_type upt = {
+		.type = type,
+	};
 
-	memset(&upt, 0, sizeof(upt));
-	upt.type = type;
-
-	RTA_PUT(skb, XFRMA_POLICY_TYPE, sizeof(upt), &upt);
-
-	return 0;
-
-rtattr_failure:
-	return -1;
+	return nla_put(skb, XFRMA_POLICY_TYPE, sizeof(upt), &upt);
 }
 
 #else
@@ -1440,7 +1421,6 @@ static int build_aevent(struct sk_buff *
 {
 	struct xfrm_aevent_id *id;
 	struct nlmsghdr *nlh;
-	struct xfrm_lifetime_cur ltime;
 
 	nlh = nlmsg_put(skb, c->pid, c->seq, XFRM_MSG_NEWAE, sizeof(*id), 0);
 	if (nlh == NULL)
@@ -1455,27 +1435,19 @@ static int build_aevent(struct sk_buff *
 	id->reqid = x->props.reqid;
 	id->flags = c->data.aevent;
 
-	RTA_PUT(skb, XFRMA_REPLAY_VAL, sizeof(x->replay), &x->replay);
-
-	ltime.bytes = x->curlft.bytes;
-	ltime.packets = x->curlft.packets;
-	ltime.add_time = x->curlft.add_time;
-	ltime.use_time = x->curlft.use_time;
-
-	RTA_PUT(skb, XFRMA_LTIME_VAL, sizeof(struct xfrm_lifetime_cur), &ltime);
+	NLA_PUT(skb, XFRMA_REPLAY_VAL, sizeof(x->replay), &x->replay);
+	NLA_PUT(skb, XFRMA_LTIME_VAL, sizeof(x->curlft), &x->curlft);
 
-	if (id->flags&XFRM_AE_RTHR) {
-		RTA_PUT(skb,XFRMA_REPLAY_THRESH,sizeof(u32),&x->replay_maxdiff);
-	}
+	if (id->flags & XFRM_AE_RTHR)
+		NLA_PUT_U32(skb, XFRMA_REPLAY_THRESH, x->replay_maxdiff);
 
-	if (id->flags&XFRM_AE_ETHR) {
-		u32 etimer = x->replay_maxage*10/HZ;
-		RTA_PUT(skb,XFRMA_ETIMER_THRESH,sizeof(u32),&etimer);
-	}
+	if (id->flags & XFRM_AE_ETHR)
+		NLA_PUT_U32(skb, XFRMA_ETIMER_THRESH,
+			    x->replay_maxage * 10 / HZ);
 
 	return nlmsg_end(skb, nlh);
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_cancel(skb, nlh);
 	return -EMSGSIZE;
 }
@@ -1840,11 +1812,7 @@ static int copy_to_user_migrate(struct x
 	memcpy(&um.new_daddr, &m->new_daddr, sizeof(um.new_daddr));
 	memcpy(&um.new_saddr, &m->new_saddr, sizeof(um.new_saddr));
 
-	RTA_PUT(skb, XFRMA_MIGRATE, sizeof(um), &um);
-	return 0;
-
-rtattr_failure:
-	return -1;
+	return nla_put(skb, XFRMA_MIGRATE, sizeof(um), &um);
 }
 
 static int build_migrate(struct sk_buff *skb, struct xfrm_migrate *m,
@@ -2137,39 +2105,44 @@ static int xfrm_notify_sa(struct xfrm_st
 
 	nlh = nlmsg_put(skb, c->pid, c->seq, c->event, headlen, 0);
 	if (nlh == NULL)
-		goto nlmsg_failure;
+		goto nla_put_failure;
 
 	p = nlmsg_data(nlh);
 	if (c->event == XFRM_MSG_DELSA) {
+		struct nlattr *attr;
+
 		id = nlmsg_data(nlh);
 		memcpy(&id->daddr, &x->id.daddr, sizeof(id->daddr));
 		id->spi = x->id.spi;
 		id->family = x->props.family;
 		id->proto = x->id.proto;
 
-		p = RTA_DATA(__RTA_PUT(skb, XFRMA_SA, sizeof(*p)));
+		attr = nla_reserve(skb, XFRMA_SA, sizeof(*p));
+		if (attr == NULL)
+			goto nla_put_failure;
+
+		p = nla_data(attr);
 	}
 
 	copy_to_user_state(x, p);
 
 	if (x->aalg)
-		RTA_PUT(skb, XFRMA_ALG_AUTH,
+		NLA_PUT(skb, XFRMA_ALG_AUTH,
 			sizeof(*(x->aalg))+(x->aalg->alg_key_len+7)/8, x->aalg);
 	if (x->ealg)
-		RTA_PUT(skb, XFRMA_ALG_CRYPT,
+		NLA_PUT(skb, XFRMA_ALG_CRYPT,
 			sizeof(*(x->ealg))+(x->ealg->alg_key_len+7)/8, x->ealg);
 	if (x->calg)
-		RTA_PUT(skb, XFRMA_ALG_COMP, sizeof(*(x->calg)), x->calg);
+		NLA_PUT(skb, XFRMA_ALG_COMP, sizeof(*(x->calg)), x->calg);
 
 	if (x->encap)
-		RTA_PUT(skb, XFRMA_ENCAP, sizeof(*x->encap), x->encap);
+		NLA_PUT(skb, XFRMA_ENCAP, sizeof(*x->encap), x->encap);
 
 	nlmsg_end(skb, nlh);
 
 	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
 
-nlmsg_failure:
-rtattr_failure:
+nla_put_failure:
 	kfree_skb(skb);
 	return -1;
 }
@@ -2392,6 +2365,8 @@ static int xfrm_notify_policy(struct xfr
 
 	p = nlmsg_data(nlh);
 	if (c->event == XFRM_MSG_DELPOLICY) {
+		struct nlattr *attr;
+
 		id = nlmsg_data(nlh);
 		memset(id, 0, sizeof(*id));
 		id->dir = dir;
@@ -2400,7 +2375,11 @@ static int xfrm_notify_policy(struct xfr
 		else
 			memcpy(&id->sel, &xp->selector, sizeof(id->sel));
 
-		p = RTA_DATA(__RTA_PUT(skb, XFRMA_POLICY, sizeof(*p)));
+		attr = nla_reserve(skb, XFRMA_POLICY, sizeof(*p));
+		if (attr == NULL)
+			goto nlmsg_failure;
+
+		p = nla_data(attr);
 	}
 
 	copy_to_user_policy(xp, p, dir);
@@ -2414,7 +2393,6 @@ static int xfrm_notify_policy(struct xfr
 	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
 
 nlmsg_failure:
-rtattr_failure:
 	kfree_skb(skb);
 	return -1;
 }
@@ -2483,11 +2461,11 @@ static int build_report(struct sk_buff *
 	memcpy(&ur->sel, sel, sizeof(ur->sel));
 
 	if (addr)
-		RTA_PUT(skb, XFRMA_COADDR, sizeof(*addr), addr);
+		NLA_PUT(skb, XFRMA_COADDR, sizeof(*addr), addr);
 
 	return nlmsg_end(skb, nlh);
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_cancel(skb, nlh);
 	return -EMSGSIZE;
 }

-- 

