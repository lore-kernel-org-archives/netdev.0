From: David Miller <davem@davemloft.net>
Subject: [PATCH] xfrm_user: Propagate netlink error codes properly.
Date: Wed, 27 Jun 2012 21:57:28 -0700 (PDT)
Message-ID: <20120627.215728.137770920620706227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49679 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789Ab2F1E52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 00:57:28 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 3AFB2584693
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 21:57:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of using a fixed value of "-1" or "-EMSGSIZE", propagate what
the nla_*() interfaces actually return.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h   |   10 +-
 net/xfrm/xfrm_user.c |  394 ++++++++++++++++++++++++++------------------------
 2 files changed, 208 insertions(+), 196 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index e0a55df..17acbc9 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1682,13 +1682,11 @@ static inline int xfrm_mark_get(struct nlattr **attrs, struct xfrm_mark *m)
 
 static inline int xfrm_mark_put(struct sk_buff *skb, const struct xfrm_mark *m)
 {
-	if ((m->m | m->v) &&
-	    nla_put(skb, XFRMA_MARK, sizeof(struct xfrm_mark), m))
-		goto nla_put_failure;
-	return 0;
+	int ret = 0;
 
-nla_put_failure:
-	return -1;
+	if (m->m | m->v)
+		ret = nla_put(skb, XFRMA_MARK, sizeof(struct xfrm_mark), m);
+	return ret;
 }
 
 #endif	/* _NET_XFRM_H */
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 44293b3..5407627 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -754,58 +754,67 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 				    struct xfrm_usersa_info *p,
 				    struct sk_buff *skb)
 {
-	copy_to_user_state(x, p);
-
-	if (x->coaddr &&
-	    nla_put(skb, XFRMA_COADDR, sizeof(*x->coaddr), x->coaddr))
-		goto nla_put_failure;
-
-	if (x->lastused &&
-	    nla_put_u64(skb, XFRMA_LASTUSED, x->lastused))
-		goto nla_put_failure;
-
-	if (x->aead &&
-	    nla_put(skb, XFRMA_ALG_AEAD, aead_len(x->aead), x->aead))
-		goto nla_put_failure;
-
-	if (x->aalg &&
-	    (copy_to_user_auth(x->aalg, skb) ||
-	     nla_put(skb, XFRMA_ALG_AUTH_TRUNC,
-		     xfrm_alg_auth_len(x->aalg), x->aalg)))
-		goto nla_put_failure;
-
-	if (x->ealg &&
-	    nla_put(skb, XFRMA_ALG_CRYPT, xfrm_alg_len(x->ealg), x->ealg))
-		goto nla_put_failure;
-
-	if (x->calg &&
-	    nla_put(skb, XFRMA_ALG_COMP, sizeof(*(x->calg)), x->calg))
-		goto nla_put_failure;
-
-	if (x->encap &&
-	    nla_put(skb, XFRMA_ENCAP, sizeof(*x->encap), x->encap))
-		goto nla_put_failure;
+	int ret = 0;
 
-	if (x->tfcpad &&
-	    nla_put_u32(skb, XFRMA_TFCPAD, x->tfcpad))
-		goto nla_put_failure;
-
-	if (xfrm_mark_put(skb, &x->mark))
-		goto nla_put_failure;
-
-	if (x->replay_esn &&
-	    nla_put(skb, XFRMA_REPLAY_ESN_VAL,
-		    xfrm_replay_state_esn_len(x->replay_esn),
-		    x->replay_esn))
-		goto nla_put_failure;
-
-	if (x->security && copy_sec_ctx(x->security, skb))
-		goto nla_put_failure;
-
-	return 0;
+	copy_to_user_state(x, p);
 
-nla_put_failure:
-	return -EMSGSIZE;
+	if (x->coaddr) {
+		ret = nla_put(skb, XFRMA_COADDR, sizeof(*x->coaddr), x->coaddr);
+		if (ret)
+			goto out;
+	}
+	if (x->lastused) {
+		ret = nla_put_u64(skb, XFRMA_LASTUSED, x->lastused);
+		if (ret)
+			goto out;
+	}
+	if (x->aead) {
+		ret = nla_put(skb, XFRMA_ALG_AEAD, aead_len(x->aead), x->aead);
+		if (ret)
+			goto out;
+	}
+	if (x->aalg) {
+		ret = copy_to_user_auth(x->aalg, skb);
+		if (!ret)
+			ret = nla_put(skb, XFRMA_ALG_AUTH_TRUNC,
+				      xfrm_alg_auth_len(x->aalg), x->aalg);
+		if (ret)
+			goto out;
+	}
+	if (x->ealg) {
+		ret = nla_put(skb, XFRMA_ALG_CRYPT, xfrm_alg_len(x->ealg), x->ealg);
+		if (ret)
+			goto out;
+	}
+	if (x->calg) {
+		ret = nla_put(skb, XFRMA_ALG_COMP, sizeof(*(x->calg)), x->calg);
+		if (ret)
+			goto out;
+	}
+	if (x->encap) {
+		ret = nla_put(skb, XFRMA_ENCAP, sizeof(*x->encap), x->encap);
+		if (ret)
+			goto out;
+	}
+	if (x->tfcpad) {
+		ret = nla_put_u32(skb, XFRMA_TFCPAD, x->tfcpad);
+		if (ret)
+			goto out;
+	}
+	ret = xfrm_mark_put(skb, &x->mark);
+	if (ret)
+		goto out;
+	if (x->replay_esn) {
+		ret = nla_put(skb, XFRMA_REPLAY_ESN_VAL,
+			      xfrm_replay_state_esn_len(x->replay_esn),
+			      x->replay_esn);
+		if (ret)
+			goto out;
+	}
+	if (x->security)
+		ret = copy_sec_ctx(x->security, skb);
+out:
+	return ret;
 }
 
 static int dump_one_state(struct xfrm_state *x, int count, void *ptr)
@@ -825,15 +834,12 @@ static int dump_one_state(struct xfrm_state *x, int count, void *ptr)
 	p = nlmsg_data(nlh);
 
 	err = copy_to_user_state_extra(x, p, skb);
-	if (err)
-		goto nla_put_failure;
-
+	if (err) {
+		nlmsg_cancel(skb, nlh);
+		return err;
+	}
 	nlmsg_end(skb, nlh);
 	return 0;
-
-nla_put_failure:
-	nlmsg_cancel(skb, nlh);
-	return err;
 }
 
 static int xfrm_dump_sa_done(struct netlink_callback *cb)
@@ -904,6 +910,7 @@ static int build_spdinfo(struct sk_buff *skb, struct net *net,
 	struct xfrmu_spdinfo spc;
 	struct xfrmu_spdhinfo sph;
 	struct nlmsghdr *nlh;
+	int err;
 	u32 *f;
 
 	nlh = nlmsg_put(skb, pid, seq, XFRM_MSG_NEWSPDINFO, sizeof(u32), 0);
@@ -922,15 +929,15 @@ static int build_spdinfo(struct sk_buff *skb, struct net *net,
 	sph.spdhcnt = si.spdhcnt;
 	sph.spdhmcnt = si.spdhmcnt;
 
-	if (nla_put(skb, XFRMA_SPD_INFO, sizeof(spc), &spc) ||
-	    nla_put(skb, XFRMA_SPD_HINFO, sizeof(sph), &sph))
-		goto nla_put_failure;
+	err = nla_put(skb, XFRMA_SPD_INFO, sizeof(spc), &spc);
+	if (!err)
+		err = nla_put(skb, XFRMA_SPD_HINFO, sizeof(sph), &sph);
+	if (err) {
+		nlmsg_cancel(skb, nlh);
+		return err;
+	}
 
 	return nlmsg_end(skb, nlh);
-
-nla_put_failure:
-	nlmsg_cancel(skb, nlh);
-	return -EMSGSIZE;
 }
 
 static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
@@ -965,6 +972,7 @@ static int build_sadinfo(struct sk_buff *skb, struct net *net,
 	struct xfrmk_sadinfo si;
 	struct xfrmu_sadhinfo sh;
 	struct nlmsghdr *nlh;
+	int err;
 	u32 *f;
 
 	nlh = nlmsg_put(skb, pid, seq, XFRM_MSG_NEWSADINFO, sizeof(u32), 0);
@@ -978,15 +986,15 @@ static int build_sadinfo(struct sk_buff *skb, struct net *net,
 	sh.sadhmcnt = si.sadhmcnt;
 	sh.sadhcnt = si.sadhcnt;
 
-	if (nla_put_u32(skb, XFRMA_SAD_CNT, si.sadcnt) ||
-	    nla_put(skb, XFRMA_SAD_HINFO, sizeof(sh), &sh))
-		goto nla_put_failure;
+	err = nla_put_u32(skb, XFRMA_SAD_CNT, si.sadcnt);
+	if (!err)
+		err = nla_put(skb, XFRMA_SAD_HINFO, sizeof(sh), &sh);
+	if (err) {
+		nlmsg_cancel(skb, nlh);
+		return err;
+	}
 
 	return nlmsg_end(skb, nlh);
-
-nla_put_failure:
-	nlmsg_cancel(skb, nlh);
-	return -EMSGSIZE;
 }
 
 static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
@@ -1439,9 +1447,8 @@ static inline int copy_to_user_state_sec_ctx(struct xfrm_state *x, struct sk_buf
 
 static inline int copy_to_user_sec_ctx(struct xfrm_policy *xp, struct sk_buff *skb)
 {
-	if (xp->security) {
+	if (xp->security)
 		return copy_sec_ctx(xp->security, skb);
-	}
 	return 0;
 }
 static inline size_t userpolicy_type_attrsize(void)
@@ -1477,6 +1484,7 @@ static int dump_one_policy(struct xfrm_policy *xp, int dir, int count, void *ptr
 	struct sk_buff *in_skb = sp->in_skb;
 	struct sk_buff *skb = sp->out_skb;
 	struct nlmsghdr *nlh;
+	int err;
 
 	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).pid, sp->nlmsg_seq,
 			XFRM_MSG_NEWPOLICY, sizeof(*p), sp->nlmsg_flags);
@@ -1485,22 +1493,19 @@ static int dump_one_policy(struct xfrm_policy *xp, int dir, int count, void *ptr
 
 	p = nlmsg_data(nlh);
 	copy_to_user_policy(xp, p, dir);
-	if (copy_to_user_tmpl(xp, skb) < 0)
-		goto nlmsg_failure;
-	if (copy_to_user_sec_ctx(xp, skb))
-		goto nlmsg_failure;
-	if (copy_to_user_policy_type(xp->type, skb) < 0)
-		goto nlmsg_failure;
-	if (xfrm_mark_put(skb, &xp->mark))
-		goto nla_put_failure;
-
+	err = copy_to_user_tmpl(xp, skb);
+	if (!err)
+		err = copy_to_user_sec_ctx(xp, skb);
+	if (!err)
+		err = copy_to_user_policy_type(xp->type, skb);
+	if (!err)
+		err = xfrm_mark_put(skb, &xp->mark);
+	if (err) {
+		nlmsg_cancel(skb, nlh);
+		return err;
+	}
 	nlmsg_end(skb, nlh);
 	return 0;
-
-nla_put_failure:
-nlmsg_failure:
-	nlmsg_cancel(skb, nlh);
-	return -EMSGSIZE;
 }
 
 static int xfrm_dump_policy_done(struct netlink_callback *cb)
@@ -1688,6 +1693,7 @@ static int build_aevent(struct sk_buff *skb, struct xfrm_state *x, const struct
 {
 	struct xfrm_aevent_id *id;
 	struct nlmsghdr *nlh;
+	int err;
 
 	nlh = nlmsg_put(skb, c->pid, c->seq, XFRM_MSG_NEWAE, sizeof(*id), 0);
 	if (nlh == NULL)
@@ -1703,35 +1709,39 @@ static int build_aevent(struct sk_buff *skb, struct xfrm_state *x, const struct
 	id->flags = c->data.aevent;
 
 	if (x->replay_esn) {
-		if (nla_put(skb, XFRMA_REPLAY_ESN_VAL,
-			    xfrm_replay_state_esn_len(x->replay_esn),
-			    x->replay_esn))
-			goto nla_put_failure;
+		err = nla_put(skb, XFRMA_REPLAY_ESN_VAL,
+			      xfrm_replay_state_esn_len(x->replay_esn),
+			      x->replay_esn);
 	} else {
-		if (nla_put(skb, XFRMA_REPLAY_VAL, sizeof(x->replay),
-			    &x->replay))
-			goto nla_put_failure;
+		err = nla_put(skb, XFRMA_REPLAY_VAL, sizeof(x->replay),
+			      &x->replay);
 	}
-	if (nla_put(skb, XFRMA_LTIME_VAL, sizeof(x->curlft), &x->curlft))
-		goto nla_put_failure;
-
-	if ((id->flags & XFRM_AE_RTHR) &&
-	    nla_put_u32(skb, XFRMA_REPLAY_THRESH, x->replay_maxdiff))
-		goto nla_put_failure;
-
-	if ((id->flags & XFRM_AE_ETHR) &&
-	    nla_put_u32(skb, XFRMA_ETIMER_THRESH,
-			x->replay_maxage * 10 / HZ))
-		goto nla_put_failure;
+	if (err)
+		goto out_cancel;
+	err = nla_put(skb, XFRMA_LTIME_VAL, sizeof(x->curlft), &x->curlft);
+	if (err)
+		goto out_cancel;
 
-	if (xfrm_mark_put(skb, &x->mark))
-		goto nla_put_failure;
+	if (id->flags & XFRM_AE_RTHR) {
+		err = nla_put_u32(skb, XFRMA_REPLAY_THRESH, x->replay_maxdiff);
+		if (err)
+			goto out_cancel;
+	}
+	if (id->flags & XFRM_AE_ETHR) {
+		err = nla_put_u32(skb, XFRMA_ETIMER_THRESH,
+				  x->replay_maxage * 10 / HZ);
+		if (err)
+			goto out_cancel;
+	}
+	err = xfrm_mark_put(skb, &x->mark);
+	if (err)
+		goto out_cancel;
 
 	return nlmsg_end(skb, nlh);
 
-nla_put_failure:
+out_cancel:
 	nlmsg_cancel(skb, nlh);
-	return -EMSGSIZE;
+	return err;
 }
 
 static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
@@ -2155,7 +2165,7 @@ static int build_migrate(struct sk_buff *skb, const struct xfrm_migrate *m,
 	const struct xfrm_migrate *mp;
 	struct xfrm_userpolicy_id *pol_id;
 	struct nlmsghdr *nlh;
-	int i;
+	int i, err;
 
 	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_MIGRATE, sizeof(*pol_id), 0);
 	if (nlh == NULL)
@@ -2167,21 +2177,25 @@ static int build_migrate(struct sk_buff *skb, const struct xfrm_migrate *m,
 	memcpy(&pol_id->sel, sel, sizeof(pol_id->sel));
 	pol_id->dir = dir;
 
-	if (k != NULL && (copy_to_user_kmaddress(k, skb) < 0))
-			goto nlmsg_failure;
-
-	if (copy_to_user_policy_type(type, skb) < 0)
-		goto nlmsg_failure;
-
+	if (k != NULL) {
+		err = copy_to_user_kmaddress(k, skb);
+		if (err)
+			goto out_cancel;
+	}
+	err = copy_to_user_policy_type(type, skb);
+	if (err)
+		goto out_cancel;
 	for (i = 0, mp = m ; i < num_migrate; i++, mp++) {
-		if (copy_to_user_migrate(mp, skb) < 0)
-			goto nlmsg_failure;
+		err = copy_to_user_migrate(mp, skb);
+		if (err)
+			goto out_cancel;
 	}
 
 	return nlmsg_end(skb, nlh);
-nlmsg_failure:
+
+out_cancel:
 	nlmsg_cancel(skb, nlh);
-	return -EMSGSIZE;
+	return err;
 }
 
 static int xfrm_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
@@ -2354,6 +2368,7 @@ static int build_expire(struct sk_buff *skb, struct xfrm_state *x, const struct
 {
 	struct xfrm_user_expire *ue;
 	struct nlmsghdr *nlh;
+	int err;
 
 	nlh = nlmsg_put(skb, c->pid, 0, XFRM_MSG_EXPIRE, sizeof(*ue), 0);
 	if (nlh == NULL)
@@ -2363,13 +2378,11 @@ static int build_expire(struct sk_buff *skb, struct xfrm_state *x, const struct
 	copy_to_user_state(x, &ue->state);
 	ue->hard = (c->data.hard != 0) ? 1 : 0;
 
-	if (xfrm_mark_put(skb, &x->mark))
-		goto nla_put_failure;
+	err = xfrm_mark_put(skb, &x->mark);
+	if (err)
+		return err;
 
 	return nlmsg_end(skb, nlh);
-
-nla_put_failure:
-	return -EMSGSIZE;
 }
 
 static int xfrm_exp_state_notify(struct xfrm_state *x, const struct km_event *c)
@@ -2470,7 +2483,7 @@ static int xfrm_notify_sa(struct xfrm_state *x, const struct km_event *c)
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
 	int len = xfrm_sa_len(x);
-	int headlen;
+	int headlen, err;
 
 	headlen = sizeof(*p);
 	if (c->event == XFRM_MSG_DELSA) {
@@ -2485,8 +2498,9 @@ static int xfrm_notify_sa(struct xfrm_state *x, const struct km_event *c)
 		return -ENOMEM;
 
 	nlh = nlmsg_put(skb, c->pid, c->seq, c->event, headlen, 0);
+	err = -EMSGSIZE;
 	if (nlh == NULL)
-		goto nla_put_failure;
+		goto out_free_skb;
 
 	p = nlmsg_data(nlh);
 	if (c->event == XFRM_MSG_DELSA) {
@@ -2499,24 +2513,23 @@ static int xfrm_notify_sa(struct xfrm_state *x, const struct km_event *c)
 		id->proto = x->id.proto;
 
 		attr = nla_reserve(skb, XFRMA_SA, sizeof(*p));
+		err = -EMSGSIZE;
 		if (attr == NULL)
-			goto nla_put_failure;
+			goto out_free_skb;
 
 		p = nla_data(attr);
 	}
-
-	if (copy_to_user_state_extra(x, p, skb))
-		goto nla_put_failure;
+	err = copy_to_user_state_extra(x, p, skb);
+	if (err)
+		goto out_free_skb;
 
 	nlmsg_end(skb, nlh);
 
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
 
-nla_put_failure:
-	/* Somebody screwed up with xfrm_sa_len! */
-	WARN_ON(1);
+out_free_skb:
 	kfree_skb(skb);
-	return -1;
+	return err;
 }
 
 static int xfrm_send_state_notify(struct xfrm_state *x, const struct km_event *c)
@@ -2557,9 +2570,10 @@ static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 			 struct xfrm_tmpl *xt, struct xfrm_policy *xp,
 			 int dir)
 {
+	__u32 seq = xfrm_get_acqseq();
 	struct xfrm_user_acquire *ua;
 	struct nlmsghdr *nlh;
-	__u32 seq = xfrm_get_acqseq();
+	int err;
 
 	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_ACQUIRE, sizeof(*ua), 0);
 	if (nlh == NULL)
@@ -2575,21 +2589,19 @@ static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 	ua->calgos = xt->calgos;
 	ua->seq = x->km.seq = seq;
 
-	if (copy_to_user_tmpl(xp, skb) < 0)
-		goto nlmsg_failure;
-	if (copy_to_user_state_sec_ctx(x, skb))
-		goto nlmsg_failure;
-	if (copy_to_user_policy_type(xp->type, skb) < 0)
-		goto nlmsg_failure;
-	if (xfrm_mark_put(skb, &xp->mark))
-		goto nla_put_failure;
+	err = copy_to_user_tmpl(xp, skb);
+	if (!err)
+		err = copy_to_user_state_sec_ctx(x, skb);
+	if (!err)
+		err = copy_to_user_policy_type(xp->type, skb);
+	if (!err)
+		err = xfrm_mark_put(skb, &xp->mark);
+	if (err) {
+		nlmsg_cancel(skb, nlh);
+		return err;
+	}
 
 	return nlmsg_end(skb, nlh);
-
-nla_put_failure:
-nlmsg_failure:
-	nlmsg_cancel(skb, nlh);
-	return -EMSGSIZE;
 }
 
 static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *xt,
@@ -2681,8 +2693,9 @@ static int build_polexpire(struct sk_buff *skb, struct xfrm_policy *xp,
 			   int dir, const struct km_event *c)
 {
 	struct xfrm_user_polexpire *upe;
-	struct nlmsghdr *nlh;
 	int hard = c->data.hard;
+	struct nlmsghdr *nlh;
+	int err;
 
 	nlh = nlmsg_put(skb, c->pid, 0, XFRM_MSG_POLEXPIRE, sizeof(*upe), 0);
 	if (nlh == NULL)
@@ -2690,22 +2703,20 @@ static int build_polexpire(struct sk_buff *skb, struct xfrm_policy *xp,
 
 	upe = nlmsg_data(nlh);
 	copy_to_user_policy(xp, &upe->pol, dir);
-	if (copy_to_user_tmpl(xp, skb) < 0)
-		goto nlmsg_failure;
-	if (copy_to_user_sec_ctx(xp, skb))
-		goto nlmsg_failure;
-	if (copy_to_user_policy_type(xp->type, skb) < 0)
-		goto nlmsg_failure;
-	if (xfrm_mark_put(skb, &xp->mark))
-		goto nla_put_failure;
+	err = copy_to_user_tmpl(xp, skb);
+	if (!err)
+		err = copy_to_user_sec_ctx(xp, skb);
+	if (!err)
+		err = copy_to_user_policy_type(xp->type, skb);
+	if (!err)
+		err = xfrm_mark_put(skb, &xp->mark);
+	if (err) {
+		nlmsg_cancel(skb, nlh);
+		return err;
+	}
 	upe->hard = !!hard;
 
 	return nlmsg_end(skb, nlh);
-
-nla_put_failure:
-nlmsg_failure:
-	nlmsg_cancel(skb, nlh);
-	return -EMSGSIZE;
 }
 
 static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, const struct km_event *c)
@@ -2725,13 +2736,13 @@ static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, const struct
 
 static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, const struct km_event *c)
 {
+	int len = nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
 	struct net *net = xp_net(xp);
 	struct xfrm_userpolicy_info *p;
 	struct xfrm_userpolicy_id *id;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
-	int len = nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
-	int headlen;
+	int headlen, err;
 
 	headlen = sizeof(*p);
 	if (c->event == XFRM_MSG_DELPOLICY) {
@@ -2747,8 +2758,9 @@ static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, const struct km_e
 		return -ENOMEM;
 
 	nlh = nlmsg_put(skb, c->pid, c->seq, c->event, headlen, 0);
+	err = -EMSGSIZE;
 	if (nlh == NULL)
-		goto nlmsg_failure;
+		goto out_free_skb;
 
 	p = nlmsg_data(nlh);
 	if (c->event == XFRM_MSG_DELPOLICY) {
@@ -2763,29 +2775,29 @@ static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, const struct km_e
 			memcpy(&id->sel, &xp->selector, sizeof(id->sel));
 
 		attr = nla_reserve(skb, XFRMA_POLICY, sizeof(*p));
+		err = -EMSGSIZE;
 		if (attr == NULL)
-			goto nlmsg_failure;
+			goto out_free_skb;
 
 		p = nla_data(attr);
 	}
 
 	copy_to_user_policy(xp, p, dir);
-	if (copy_to_user_tmpl(xp, skb) < 0)
-		goto nlmsg_failure;
-	if (copy_to_user_policy_type(xp->type, skb) < 0)
-		goto nlmsg_failure;
-
-	if (xfrm_mark_put(skb, &xp->mark))
-		goto nla_put_failure;
+	err = copy_to_user_tmpl(xp, skb);
+	if (!err)
+		err = copy_to_user_policy_type(xp->type, skb);
+	if (!err)
+		err = xfrm_mark_put(skb, &xp->mark);
+	if (err)
+		goto out_free_skb;
 
 	nlmsg_end(skb, nlh);
 
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
 
-nla_put_failure:
-nlmsg_failure:
+out_free_skb:
 	kfree_skb(skb);
-	return -1;
+	return err;
 }
 
 static int xfrm_notify_policy_flush(const struct km_event *c)
@@ -2793,24 +2805,27 @@ static int xfrm_notify_policy_flush(const struct km_event *c)
 	struct net *net = c->net;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
+	int err;
 
 	skb = nlmsg_new(userpolicy_type_attrsize(), GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
 	nlh = nlmsg_put(skb, c->pid, c->seq, XFRM_MSG_FLUSHPOLICY, 0, 0);
+	err = -EMSGSIZE;
 	if (nlh == NULL)
-		goto nlmsg_failure;
-	if (copy_to_user_policy_type(c->data.type, skb) < 0)
-		goto nlmsg_failure;
+		goto out_free_skb;
+	err = copy_to_user_policy_type(c->data.type, skb);
+	if (err)
+		goto out_free_skb;
 
 	nlmsg_end(skb, nlh);
 
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
 
-nlmsg_failure:
+out_free_skb:
 	kfree_skb(skb);
-	return -1;
+	return err;
 }
 
 static int xfrm_send_policy_notify(struct xfrm_policy *xp, int dir, const struct km_event *c)
@@ -2853,15 +2868,14 @@ static int build_report(struct sk_buff *skb, u8 proto,
 	ur->proto = proto;
 	memcpy(&ur->sel, sel, sizeof(ur->sel));
 
-	if (addr &&
-	    nla_put(skb, XFRMA_COADDR, sizeof(*addr), addr))
-		goto nla_put_failure;
-
+	if (addr) {
+		int err = nla_put(skb, XFRMA_COADDR, sizeof(*addr), addr);
+		if (err) {
+			nlmsg_cancel(skb, nlh);
+			return err;
+		}
+	}
 	return nlmsg_end(skb, nlh);
-
-nla_put_failure:
-	nlmsg_cancel(skb, nlh);
-	return -EMSGSIZE;
 }
 
 static int xfrm_send_report(struct net *net, u8 proto,
-- 
1.7.10.2
