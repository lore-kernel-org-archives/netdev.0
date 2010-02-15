From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 3/5] xfrm: split nlmsg allocation and data copying
Date: Mon, 15 Feb 2010 17:46:31 +0100
Message-ID: <1266252393-20911-4-git-send-email-fw@strlen.de>
References: <1266252393-20911-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:40215 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755448Ab0BOQqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 11:46:34 -0500
In-Reply-To: <1266252393-20911-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To support 32bit userland with different u64 alignment requirements
than a 64bit kernel (COMPAT_FOR_U64_ALIGNMENT), it is
necessary to prepare messages containing affected structures
twice: once in the format expected by 64bit listeners, one
in the format expected by 32bit applications.

In order to minimize copy & pasting and re-use existing
code where possible, split nlmsg allocation and data copying.

Also, replace foo(..., sizeof(*structure)) with

len = sizeof(*structure);
foo(..., len);

so len can be made conditional if we are preparing a compat message.
This will be done in a followup-patch.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_user.c |  156 ++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 114 insertions(+), 42 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 943c871..bda5c15 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -692,17 +692,16 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-static int dump_one_state(struct xfrm_state *x, int count, void *ptr)
+static int copy_one_state(struct sk_buff *skb, struct xfrm_state *x, struct xfrm_dump_info *sp)
 {
-	struct xfrm_dump_info *sp = ptr;
 	struct sk_buff *in_skb = sp->in_skb;
-	struct sk_buff *skb = sp->out_skb;
 	struct xfrm_usersa_info *p;
 	struct nlmsghdr *nlh;
+	size_t len = sizeof(*p);
 	int err;
 
 	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).pid, sp->nlmsg_seq,
-			XFRM_MSG_NEWSA, sizeof(*p), sp->nlmsg_flags);
+			XFRM_MSG_NEWSA, len, sp->nlmsg_flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -720,6 +719,14 @@ nla_put_failure:
 	return err;
 }
 
+static int dump_one_state(struct xfrm_state *x, int count, void *ptr)
+{
+	struct xfrm_dump_info *sp = ptr;
+	struct sk_buff *skb = sp->out_skb;
+	int ret = copy_one_state(skb, x, sp);
+	return ret;
+}
+
 static int xfrm_dump_sa_done(struct netlink_callback *cb)
 {
 	struct xfrm_state_walk *walk = (struct xfrm_state_walk *) &cb->args[1];
@@ -1345,16 +1352,15 @@ static inline int copy_to_user_policy_type(u8 type, struct sk_buff *skb)
 }
 #endif
 
-static int dump_one_policy(struct xfrm_policy *xp, int dir, int count, void *ptr)
+static int copy_one_policy(struct sk_buff *skb, struct xfrm_policy *xp, int dir, struct xfrm_dump_info *sp)
 {
-	struct xfrm_dump_info *sp = ptr;
 	struct xfrm_userpolicy_info *p;
 	struct sk_buff *in_skb = sp->in_skb;
-	struct sk_buff *skb = sp->out_skb;
 	struct nlmsghdr *nlh;
+	size_t len = sizeof(*p);
 
 	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).pid, sp->nlmsg_seq,
-			XFRM_MSG_NEWPOLICY, sizeof(*p), sp->nlmsg_flags);
+			XFRM_MSG_NEWPOLICY, len, sp->nlmsg_flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -1375,6 +1381,14 @@ nlmsg_failure:
 	return -EMSGSIZE;
 }
 
+static int dump_one_policy(struct xfrm_policy *xp, int dir, int count, void *ptr)
+{
+	struct xfrm_dump_info *sp = ptr;
+	struct sk_buff *skb = sp->out_skb;
+	int ret = copy_one_policy(skb, xp, dir, sp);
+	return ret;
+}
+
 static int xfrm_dump_policy_done(struct netlink_callback *cb)
 {
 	struct xfrm_policy_walk *walk = (struct xfrm_policy_walk *) &cb->args[1];
@@ -1695,7 +1709,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_user_polexpire *up = nlmsg_data(nlh);
 	struct xfrm_userpolicy_info *p = &up->pol;
 	u8 type = XFRM_POLICY_TYPE_MAIN;
-	int err = -ENOENT;
+	int hard, err = -ENOENT;
 
 	err = copy_from_user_policy_type(&type, attrs);
 	if (err)
@@ -1733,7 +1747,8 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	read_unlock(&xp->lock);
 	err = 0;
-	if (up->hard) {
+	hard = up->hard;
+	if (hard) {
 		uid_t loginuid = NETLINK_CB(skb).loginuid;
 		uid_t sessionid = NETLINK_CB(skb).sessionid;
 		u32 sid = NETLINK_CB(skb).sid;
@@ -1744,7 +1759,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		// reset the timers here?
 		printk("Dont know what to do with soft policy expire\n");
 	}
-	km_policy_expired(xp, p->dir, up->hard, current->pid);
+	km_policy_expired(xp, p->dir, hard, current->pid);
 
 out:
 	xfrm_pol_put(xp);
@@ -1756,7 +1771,7 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 {
 	struct net *net = sock_net(skb->sk);
 	struct xfrm_state *x;
-	int err;
+	int hard, err;
 	struct xfrm_user_expire *ue = nlmsg_data(nlh);
 	struct xfrm_usersa_info *p = &ue->state;
 
@@ -1770,9 +1785,10 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	err = -EINVAL;
 	if (x->km.state != XFRM_STATE_VALID)
 		goto out;
-	km_state_expired(x, ue->hard, current->pid);
+	hard = ue->hard;
+	km_state_expired(x, hard, current->pid);
 
-	if (ue->hard) {
+	if (hard) {
 		uid_t loginuid = NETLINK_CB(skb).loginuid;
 		uid_t sessionid = NETLINK_CB(skb).sessionid;
 		u32 sid = NETLINK_CB(skb).sid;
@@ -2256,26 +2272,35 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 	return l;
 }
 
-static int xfrm_notify_sa(struct xfrm_state *x, struct km_event *c)
+static int xfrm_notify_sa_len(struct xfrm_state *x, const struct km_event *c)
 {
-	struct net *net = xs_net(x);
-	struct xfrm_usersa_info *p;
-	struct xfrm_usersa_id *id;
-	struct nlmsghdr *nlh;
-	struct sk_buff *skb;
 	int len = xfrm_sa_len(x);
-	int headlen;
+	int headlen = sizeof(struct xfrm_usersa_info);
 
-	headlen = sizeof(*p);
 	if (c->event == XFRM_MSG_DELSA) {
 		len += nla_total_size(headlen);
-		headlen = sizeof(*id);
+		headlen = sizeof(struct xfrm_usersa_id);
 	}
 	len += NLMSG_ALIGN(headlen);
 
-	skb = nlmsg_new(len, GFP_ATOMIC);
-	if (skb == NULL)
-		return -ENOMEM;
+	return len;
+}
+
+static int xfrm_notify_sa_headlen(const struct km_event *c)
+{
+	if (c->event == XFRM_MSG_DELSA)
+		return sizeof(struct xfrm_usersa_id);
+	return sizeof(struct xfrm_usersa_info);
+}
+
+static int copy_to_user_xfrm_notify_sa(struct sk_buff *skb,
+                                       struct xfrm_state *x, struct km_event *c)
+{
+	struct xfrm_usersa_info *p;
+	struct xfrm_usersa_id *id;
+	struct nlmsghdr *nlh;
+	int sizeof_xfrm_usersa_info = sizeof(*p);
+	int headlen = xfrm_notify_sa_headlen(c);
 
 	nlh = nlmsg_put(skb, c->pid, c->seq, c->event, headlen, 0);
 	if (nlh == NULL)
@@ -2291,7 +2316,7 @@ static int xfrm_notify_sa(struct xfrm_state *x, struct km_event *c)
 		id->family = x->props.family;
 		id->proto = x->id.proto;
 
-		attr = nla_reserve(skb, XFRMA_SA, sizeof(*p));
+		attr = nla_reserve(skb, XFRMA_SA, sizeof_xfrm_usersa_info);
 		if (attr == NULL)
 			goto nla_put_failure;
 
@@ -2302,6 +2327,25 @@ static int xfrm_notify_sa(struct xfrm_state *x, struct km_event *c)
 		goto nla_put_failure;
 
 	nlmsg_end(skb, nlh);
+	return 0;
+nla_put_failure:
+	/* Somebody screwed up with xfrm_sa_len! */
+	WARN_ON(1);
+	return -1;
+}
+
+static int xfrm_notify_sa(struct xfrm_state *x, struct km_event *c)
+{
+	struct sk_buff *skb;
+	struct net *net = xs_net(x);
+	int len = xfrm_notify_sa_len(x, c);
+
+	skb = nlmsg_new(len, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+
+	if (copy_to_user_xfrm_notify_sa(skb, x, c))
+		goto nla_put_failure;
 
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
 
@@ -2349,10 +2393,11 @@ static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 			 int dir)
 {
 	struct xfrm_user_acquire *ua;
+	size_t len = sizeof(*ua);
 	struct nlmsghdr *nlh;
 	__u32 seq = xfrm_get_acqseq();
 
-	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_ACQUIRE, sizeof(*ua), 0);
+	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_ACQUIRE, len, 0);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -2468,10 +2513,11 @@ static int build_polexpire(struct sk_buff *skb, struct xfrm_policy *xp,
 			   int dir, struct km_event *c)
 {
 	struct xfrm_user_polexpire *upe;
+	size_t len = sizeof(*upe);
 	struct nlmsghdr *nlh;
 	int hard = c->data.hard;
 
-	nlh = nlmsg_put(skb, c->pid, 0, XFRM_MSG_POLEXPIRE, sizeof(*upe), 0);
+	nlh = nlmsg_put(skb, c->pid, 0, XFRM_MSG_POLEXPIRE, len, 0);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -2507,27 +2553,35 @@ static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, struct km_eve
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
 }
 
-static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *c)
+static int xfrm_notify_policy_len(struct xfrm_policy *xp, struct km_event *c)
 {
-	struct net *net = xp_net(xp);
-	struct xfrm_userpolicy_info *p;
-	struct xfrm_userpolicy_id *id;
-	struct nlmsghdr *nlh;
-	struct sk_buff *skb;
 	int len = nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
-	int headlen;
+	int headlen = sizeof(struct xfrm_userpolicy_info);
 
-	headlen = sizeof(*p);
 	if (c->event == XFRM_MSG_DELPOLICY) {
 		len += nla_total_size(headlen);
-		headlen = sizeof(*id);
+		headlen = sizeof(struct xfrm_userpolicy_id);
 	}
 	len += userpolicy_type_attrsize();
 	len += NLMSG_ALIGN(headlen);
+	return len;
+}
 
-	skb = nlmsg_new(len, GFP_ATOMIC);
-	if (skb == NULL)
-		return -ENOMEM;
+static int xfrm_notify_policy_headlen(const struct km_event *c)
+{
+	if (c->event == XFRM_MSG_DELPOLICY)
+		return sizeof(struct xfrm_userpolicy_id);
+	return sizeof(struct xfrm_userpolicy_info);
+}
+
+static int copy_to_user_xfrm_notify_policy(struct sk_buff *skb, int dir,
+                                           struct xfrm_policy *xp, struct km_event *c)
+{
+	struct xfrm_userpolicy_info *p;
+	struct xfrm_userpolicy_id *id;
+	struct nlmsghdr *nlh;
+	int sizeof_xfrm_userpolicy_info = sizeof(*p);
+	int headlen = xfrm_notify_policy_headlen(c);
 
 	nlh = nlmsg_put(skb, c->pid, c->seq, c->event, headlen, 0);
 	if (nlh == NULL)
@@ -2545,7 +2599,7 @@ static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *
 		else
 			memcpy(&id->sel, &xp->selector, sizeof(id->sel));
 
-		attr = nla_reserve(skb, XFRMA_POLICY, sizeof(*p));
+		attr = nla_reserve(skb, XFRMA_POLICY, sizeof_xfrm_userpolicy_info);
 		if (attr == NULL)
 			goto nlmsg_failure;
 
@@ -2560,6 +2614,24 @@ static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *
 
 	nlmsg_end(skb, nlh);
 
+	return 0;
+
+nlmsg_failure:
+	return -1;
+}
+
+static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *c)
+{
+	struct net *net = xp_net(xp);
+	struct sk_buff *skb;
+	int len = xfrm_notify_policy_len(xp, c);
+
+	skb = nlmsg_new(len, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+	if (copy_to_user_xfrm_notify_policy(skb, dir, xp, c))
+		goto nlmsg_failure;
+
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
 
 nlmsg_failure:
-- 
1.6.3.3

