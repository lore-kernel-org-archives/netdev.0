From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/7] [XFRM] user: Move attribute copying code into copy_to_user_state_extra
Date: Tue, 09 Oct 2007 22:36:35 +0800
Message-ID: <E1IfGCJ-0005MD-00@gondolin.me.apana.org.au>
References: <20071009143517.GA20486@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4995 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753002AbXJIOgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 10:36:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[XFRM] user: Move attribute copying code into copy_to_user_state_extra

Here's a good example of code duplication leading to code rot.  The
notification patch did its own netlink message creation for xfrm states.
It duplicated code that was already in dump_one_state.  Guess what, the
next time (and the time after) when someone updated dump_one_state the
notification path got zilch.

This patch moves that code from dump_one_state to copy_to_user_state_extra
and uses it in xfrm_notify_sa too.  Unfortunately whoever updates this
still needs to update xfrm_sa_len since the notification path wants to
know the exact size for allocation.

At least I've added a comment saying so and if someone still forgest, we'll
have a WARN_ON telling us so.

I also changed the security size calculation to use xfrm_user_sec_ctx since
that's what we actually put into the skb.  However it makes no practical
difference since it has the same size as xfrm_sec_ctx.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/xfrm/xfrm_user.c |   76 +++++++++++++++++++++++++++++++--------------------
 1 files changed, 47 insertions(+), 29 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 52c7fce..2cbbe5e 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -483,9 +483,9 @@ struct xfrm_dump_info {
 
 static int copy_sec_ctx(struct xfrm_sec_ctx *s, struct sk_buff *skb)
 {
-	int ctx_size = sizeof(struct xfrm_sec_ctx) + s->ctx_len;
 	struct xfrm_user_sec_ctx *uctx;
 	struct nlattr *attr;
+	int ctx_size = sizeof(*uctx) + s->ctx_len;
 
 	attr = nla_reserve(skb, XFRMA_SEC_CTX, ctx_size);
 	if (attr == NULL)
@@ -502,23 +502,11 @@ static int copy_sec_ctx(struct xfrm_sec_ctx *s, struct sk_buff *skb)
 	return 0;
 }
 
-static int dump_one_state(struct xfrm_state *x, int count, void *ptr)
+/* Don't change this without updating xfrm_sa_len! */
+static int copy_to_user_state_extra(struct xfrm_state *x,
+				    struct xfrm_usersa_info *p,
+				    struct sk_buff *skb)
 {
-	struct xfrm_dump_info *sp = ptr;
-	struct sk_buff *in_skb = sp->in_skb;
-	struct sk_buff *skb = sp->out_skb;
-	struct xfrm_usersa_info *p;
-	struct nlmsghdr *nlh;
-
-	if (sp->this_idx < sp->start_idx)
-		goto out;
-
-	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).pid, sp->nlmsg_seq,
-			XFRM_MSG_NEWSA, sizeof(*p), sp->nlmsg_flags);
-	if (nlh == NULL)
-		return -EMSGSIZE;
-
-	p = nlmsg_data(nlh);
 	copy_to_user_state(x, p);
 
 	if (x->aalg)
@@ -540,6 +528,35 @@ static int dump_one_state(struct xfrm_state *x, int count, void *ptr)
 	if (x->lastused)
 		NLA_PUT_U64(skb, XFRMA_LASTUSED, x->lastused);
 
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static int dump_one_state(struct xfrm_state *x, int count, void *ptr)
+{
+	struct xfrm_dump_info *sp = ptr;
+	struct sk_buff *in_skb = sp->in_skb;
+	struct sk_buff *skb = sp->out_skb;
+	struct xfrm_usersa_info *p;
+	struct nlmsghdr *nlh;
+	int err;
+
+	if (sp->this_idx < sp->start_idx)
+		goto out;
+
+	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).pid, sp->nlmsg_seq,
+			XFRM_MSG_NEWSA, sizeof(*p), sp->nlmsg_flags);
+	if (nlh == NULL)
+		return -EMSGSIZE;
+
+	p = nlmsg_data(nlh);
+
+	err = copy_to_user_state_extra(x, p, skb);
+	if (err)
+		goto nla_put_failure;
+
 	nlmsg_end(skb, nlh);
 out:
 	sp->this_idx++;
@@ -547,7 +564,7 @@ out:
 
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
-	return -EMSGSIZE;
+	return err;
 }
 
 static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
@@ -1973,6 +1990,14 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 		l += nla_total_size(sizeof(*x->calg));
 	if (x->encap)
 		l += nla_total_size(sizeof(*x->encap));
+	if (x->security)
+		l += nla_total_size(sizeof(struct xfrm_user_sec_ctx) +
+				    x->security->ctx_len);
+	if (x->coaddr)
+		l += nla_total_size(sizeof(*x->coaddr));
+
+	/* Must count this as this may become non-zero behind our back. */
+	l += nla_total_size(sizeof(x->lastused));
 
 	return l;
 }
@@ -2018,23 +2043,16 @@ static int xfrm_notify_sa(struct xfrm_state *x, struct km_event *c)
 		p = nla_data(attr);
 	}
 
-	copy_to_user_state(x, p);
-
-	if (x->aalg)
-		NLA_PUT(skb, XFRMA_ALG_AUTH, alg_len(x->aalg), x->aalg);
-	if (x->ealg)
-		NLA_PUT(skb, XFRMA_ALG_CRYPT, alg_len(x->ealg), x->ealg);
-	if (x->calg)
-		NLA_PUT(skb, XFRMA_ALG_COMP, sizeof(*(x->calg)), x->calg);
-
-	if (x->encap)
-		NLA_PUT(skb, XFRMA_ENCAP, sizeof(*x->encap), x->encap);
+	if (copy_to_user_state_extra(x, p, skb))
+		goto nla_put_failure;
 
 	nlmsg_end(skb, nlh);
 
 	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
 
 nla_put_failure:
+	/* Somebody screwed up with xfrm_sa_len! */
+	WARN_ON(1);
 	kfree_skb(skb);
 	return -1;
 }
