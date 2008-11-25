From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 41/53] netns xfrm: xfrm_user module in netns
Date: Tue, 25 Nov 2008 20:27:13 +0300
Message-ID: <1227634045-27534-41-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-23-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-24-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-25-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-26-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-27-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-28-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-29-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-30-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-31-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-32-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-33-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-34-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-35-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-36-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-37-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-38-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-39-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-40-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:41378 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753432AbYKYRZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:25:20 -0500
Received: by ey-out-2122.google.com with SMTP id 6so23508eyi.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:25:19 -0800 (PST)
In-Reply-To: <1227634045-27534-40-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grab netns either from netlink socket, state or policy.

SA and SPD flush are in init_net for now, this requires little
attention, see below.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 net/xfrm/xfrm_user.c |   76 +++++++++++++++++++++++++++++--------------------
 1 files changed, 45 insertions(+), 31 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 8b5b01d..ab8b138 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -316,11 +316,12 @@ static void xfrm_update_ae_params(struct xfrm_state *x, struct nlattr **attrs)
 		x->replay_maxdiff = nla_get_u32(rt);
 }
 
-static struct xfrm_state *xfrm_state_construct(struct xfrm_usersa_info *p,
+static struct xfrm_state *xfrm_state_construct(struct net *net,
+					       struct xfrm_usersa_info *p,
 					       struct nlattr **attrs,
 					       int *errp)
 {
-	struct xfrm_state *x = xfrm_state_alloc(&init_net);
+	struct xfrm_state *x = xfrm_state_alloc(net);
 	int err = -ENOMEM;
 
 	if (!x)
@@ -391,6 +392,7 @@ error_no_put:
 static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
+	struct net *net = sock_net(skb->sk);
 	struct xfrm_usersa_info *p = nlmsg_data(nlh);
 	struct xfrm_state *x;
 	int err;
@@ -403,7 +405,7 @@ static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (err)
 		return err;
 
-	x = xfrm_state_construct(p, attrs, &err);
+	x = xfrm_state_construct(net, p, attrs, &err);
 	if (!x)
 		return err;
 
@@ -431,7 +433,8 @@ out:
 	return err;
 }
 
-static struct xfrm_state *xfrm_user_state_lookup(struct xfrm_usersa_id *p,
+static struct xfrm_state *xfrm_user_state_lookup(struct net *net,
+						 struct xfrm_usersa_id *p,
 						 struct nlattr **attrs,
 						 int *errp)
 {
@@ -440,7 +443,7 @@ static struct xfrm_state *xfrm_user_state_lookup(struct xfrm_usersa_id *p,
 
 	if (xfrm_id_proto_match(p->proto, IPSEC_PROTO_ANY)) {
 		err = -ESRCH;
-		x = xfrm_state_lookup(&init_net, &p->daddr, p->spi, p->proto, p->family);
+		x = xfrm_state_lookup(net, &p->daddr, p->spi, p->proto, p->family);
 	} else {
 		xfrm_address_t *saddr = NULL;
 
@@ -451,7 +454,7 @@ static struct xfrm_state *xfrm_user_state_lookup(struct xfrm_usersa_id *p,
 		}
 
 		err = -ESRCH;
-		x = xfrm_state_lookup_byaddr(&init_net, &p->daddr, saddr,
+		x = xfrm_state_lookup_byaddr(net, &p->daddr, saddr,
 					     p->proto, p->family);
 	}
 
@@ -464,6 +467,7 @@ static struct xfrm_state *xfrm_user_state_lookup(struct xfrm_usersa_id *p,
 static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
+	struct net *net = sock_net(skb->sk);
 	struct xfrm_state *x;
 	int err = -ESRCH;
 	struct km_event c;
@@ -472,7 +476,7 @@ static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	u32 sessionid = NETLINK_CB(skb).sessionid;
 	u32 sid = NETLINK_CB(skb).sid;
 
-	x = xfrm_user_state_lookup(p, attrs, &err);
+	x = xfrm_user_state_lookup(net, p, attrs, &err);
 	if (x == NULL)
 		return err;
 
@@ -615,6 +619,7 @@ static int xfrm_dump_sa_done(struct netlink_callback *cb)
 
 static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
 {
+	struct net *net = sock_net(skb->sk);
 	struct xfrm_state_walk *walk = (struct xfrm_state_walk *) &cb->args[1];
 	struct xfrm_dump_info info;
 
@@ -631,7 +636,7 @@ static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
 		xfrm_state_walk_init(walk, 0);
 	}
 
-	(void) xfrm_state_walk(&init_net, walk, dump_one_state, &info);
+	(void) xfrm_state_walk(net, walk, dump_one_state, &info);
 
 	return skb->len;
 }
@@ -776,13 +781,13 @@ static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 static int xfrm_get_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
-	struct net *net = &init_net;
+	struct net *net = sock_net(skb->sk);
 	struct xfrm_usersa_id *p = nlmsg_data(nlh);
 	struct xfrm_state *x;
 	struct sk_buff *resp_skb;
 	int err = -ESRCH;
 
-	x = xfrm_user_state_lookup(p, attrs, &err);
+	x = xfrm_user_state_lookup(net, p, attrs, &err);
 	if (x == NULL)
 		goto out_noput;
 
@@ -823,7 +828,7 @@ static int verify_userspi_info(struct xfrm_userspi_info *p)
 static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
-	struct net *net = &init_net;
+	struct net *net = sock_net(skb->sk);
 	struct xfrm_state *x;
 	struct xfrm_userspi_info *p;
 	struct sk_buff *resp_skb;
@@ -1082,9 +1087,9 @@ static void copy_to_user_policy(struct xfrm_policy *xp, struct xfrm_userpolicy_i
 	p->share = XFRM_SHARE_ANY; /* XXX xp->share */
 }
 
-static struct xfrm_policy *xfrm_policy_construct(struct xfrm_userpolicy_info *p, struct nlattr **attrs, int *errp)
+static struct xfrm_policy *xfrm_policy_construct(struct net *net, struct xfrm_userpolicy_info *p, struct nlattr **attrs, int *errp)
 {
-	struct xfrm_policy *xp = xfrm_policy_alloc(&init_net, GFP_KERNEL);
+	struct xfrm_policy *xp = xfrm_policy_alloc(net, GFP_KERNEL);
 	int err;
 
 	if (!xp) {
@@ -1114,6 +1119,7 @@ static struct xfrm_policy *xfrm_policy_construct(struct xfrm_userpolicy_info *p,
 static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
+	struct net *net = sock_net(skb->sk);
 	struct xfrm_userpolicy_info *p = nlmsg_data(nlh);
 	struct xfrm_policy *xp;
 	struct km_event c;
@@ -1130,7 +1136,7 @@ static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (err)
 		return err;
 
-	xp = xfrm_policy_construct(p, attrs, &err);
+	xp = xfrm_policy_construct(net, p, attrs, &err);
 	if (!xp)
 		return err;
 
@@ -1267,6 +1273,7 @@ static int xfrm_dump_policy_done(struct netlink_callback *cb)
 
 static int xfrm_dump_policy(struct sk_buff *skb, struct netlink_callback *cb)
 {
+	struct net *net = sock_net(skb->sk);
 	struct xfrm_policy_walk *walk = (struct xfrm_policy_walk *) &cb->args[1];
 	struct xfrm_dump_info info;
 
@@ -1283,7 +1290,7 @@ static int xfrm_dump_policy(struct sk_buff *skb, struct netlink_callback *cb)
 		xfrm_policy_walk_init(walk, XFRM_POLICY_TYPE_ANY);
 	}
 
-	(void) xfrm_policy_walk(&init_net, walk, dump_one_policy, &info);
+	(void) xfrm_policy_walk(net, walk, dump_one_policy, &info);
 
 	return skb->len;
 }
@@ -1315,7 +1322,7 @@ static struct sk_buff *xfrm_policy_netlink(struct sk_buff *in_skb,
 static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
-	struct net *net = &init_net;
+	struct net *net = sock_net(skb->sk);
 	struct xfrm_policy *xp;
 	struct xfrm_userpolicy_id *p;
 	u8 type = XFRM_POLICY_TYPE_MAIN;
@@ -1395,6 +1402,7 @@ out:
 static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
+	struct net *net = sock_net(skb->sk);
 	struct km_event c;
 	struct xfrm_usersa_flush *p = nlmsg_data(nlh);
 	struct xfrm_audit audit_info;
@@ -1403,7 +1411,7 @@ static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	audit_info.loginuid = NETLINK_CB(skb).loginuid;
 	audit_info.sessionid = NETLINK_CB(skb).sessionid;
 	audit_info.secid = NETLINK_CB(skb).sid;
-	err = xfrm_state_flush(&init_net, p->proto, &audit_info);
+	err = xfrm_state_flush(net, p->proto, &audit_info);
 	if (err)
 		return err;
 	c.data.proto = p->proto;
@@ -1462,7 +1470,7 @@ nla_put_failure:
 static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
-	struct net *net = &init_net;
+	struct net *net = sock_net(skb->sk);
 	struct xfrm_state *x;
 	struct sk_buff *r_skb;
 	int err;
@@ -1501,6 +1509,7 @@ static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
+	struct net *net = sock_net(skb->sk);
 	struct xfrm_state *x;
 	struct km_event c;
 	int err = - EINVAL;
@@ -1515,7 +1524,7 @@ static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (!(nlh->nlmsg_flags&NLM_F_REPLACE))
 		return err;
 
-	x = xfrm_state_lookup(&init_net, &p->sa_id.daddr, p->sa_id.spi, p->sa_id.proto, p->sa_id.family);
+	x = xfrm_state_lookup(net, &p->sa_id.daddr, p->sa_id.spi, p->sa_id.proto, p->sa_id.family);
 	if (x == NULL)
 		return -ESRCH;
 
@@ -1540,6 +1549,7 @@ out:
 static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
+	struct net *net = sock_net(skb->sk);
 	struct km_event c;
 	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err;
@@ -1552,7 +1562,7 @@ static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	audit_info.loginuid = NETLINK_CB(skb).loginuid;
 	audit_info.sessionid = NETLINK_CB(skb).sessionid;
 	audit_info.secid = NETLINK_CB(skb).sid;
-	err = xfrm_policy_flush(&init_net, type, &audit_info);
+	err = xfrm_policy_flush(net, type, &audit_info);
 	if (err)
 		return err;
 	c.data.type = type;
@@ -1566,6 +1576,7 @@ static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
+	struct net *net = sock_net(skb->sk);
 	struct xfrm_policy *xp;
 	struct xfrm_user_polexpire *up = nlmsg_data(nlh);
 	struct xfrm_userpolicy_info *p = &up->pol;
@@ -1577,7 +1588,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return err;
 
 	if (p->index)
-		xp = xfrm_policy_byid(&init_net, type, p->dir, p->index, 0, &err);
+		xp = xfrm_policy_byid(net, type, p->dir, p->index, 0, &err);
 	else {
 		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
 		struct xfrm_sec_ctx *ctx;
@@ -1594,7 +1605,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 			if (err)
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(&init_net, type, p->dir, &p->sel, ctx, 0, &err);
+		xp = xfrm_policy_bysel_ctx(net, type, p->dir, &p->sel, ctx, 0, &err);
 		security_xfrm_policy_free(ctx);
 	}
 	if (xp == NULL)
@@ -1629,12 +1640,13 @@ out:
 static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
+	struct net *net = sock_net(skb->sk);
 	struct xfrm_state *x;
 	int err;
 	struct xfrm_user_expire *ue = nlmsg_data(nlh);
 	struct xfrm_usersa_info *p = &ue->state;
 
-	x = xfrm_state_lookup(&init_net, &p->id.daddr, p->id.spi, p->id.proto, p->family);
+	x = xfrm_state_lookup(net, &p->id.daddr, p->id.spi, p->id.proto, p->family);
 
 	err = -ENOENT;
 	if (x == NULL)
@@ -1663,13 +1675,14 @@ out:
 static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
+	struct net *net = sock_net(skb->sk);
 	struct xfrm_policy *xp;
 	struct xfrm_user_tmpl *ut;
 	int i;
 	struct nlattr *rt = attrs[XFRMA_TMPL];
 
 	struct xfrm_user_acquire *ua = nlmsg_data(nlh);
-	struct xfrm_state *x = xfrm_state_alloc(&init_net);
+	struct xfrm_state *x = xfrm_state_alloc(net);
 	int err = -ENOMEM;
 
 	if (!x)
@@ -1683,7 +1696,7 @@ static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	}
 
 	/*   build an XP */
-	xp = xfrm_policy_construct(&ua->policy, attrs, &err);
+	xp = xfrm_policy_construct(net, &ua->policy, attrs, &err);
 	if (!xp) {
 		kfree(x);
 		return err;
@@ -2041,7 +2054,7 @@ static int build_expire(struct sk_buff *skb, struct xfrm_state *x, struct km_eve
 
 static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
 {
-	struct net *net = &init_net;
+	struct net *net = xs_net(x);
 	struct sk_buff *skb;
 
 	skb = nlmsg_new(xfrm_expire_msgsize(), GFP_ATOMIC);
@@ -2056,7 +2069,7 @@ static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
 
 static int xfrm_aevent_state_notify(struct xfrm_state *x, struct km_event *c)
 {
-	struct net *net = &init_net;
+	struct net *net = xs_net(x);
 	struct sk_buff *skb;
 
 	skb = nlmsg_new(xfrm_aevent_msgsize(), GFP_ATOMIC);
@@ -2122,7 +2135,7 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 
 static int xfrm_notify_sa(struct xfrm_state *x, struct km_event *c)
 {
-	struct net *net = &init_net;
+	struct net *net = xs_net(x);
 	struct xfrm_usersa_info *p;
 	struct xfrm_usersa_id *id;
 	struct nlmsghdr *nlh;
@@ -2266,6 +2279,7 @@ static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *xt,
 static struct xfrm_policy *xfrm_compile_policy(struct sock *sk, int opt,
 					       u8 *data, int len, int *dir)
 {
+	struct net *net = sock_net(sk);
 	struct xfrm_userpolicy_info *p = (struct xfrm_userpolicy_info *)data;
 	struct xfrm_user_tmpl *ut = (struct xfrm_user_tmpl *) (p + 1);
 	struct xfrm_policy *xp;
@@ -2304,7 +2318,7 @@ static struct xfrm_policy *xfrm_compile_policy(struct sock *sk, int opt,
 	if (p->dir > XFRM_POLICY_OUT)
 		return NULL;
 
-	xp = xfrm_policy_alloc(&init_net, GFP_KERNEL);
+	xp = xfrm_policy_alloc(net, GFP_KERNEL);
 	if (xp == NULL) {
 		*dir = -ENOBUFS;
 		return NULL;
@@ -2357,7 +2371,7 @@ nlmsg_failure:
 
 static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
 {
-	struct net *net = &init_net;
+	struct net *net = xp_net(xp);
 	struct sk_buff *skb;
 
 	skb = nlmsg_new(xfrm_polexpire_msgsize(xp), GFP_ATOMIC);
@@ -2372,7 +2386,7 @@ static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, struct km_eve
 
 static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *c)
 {
-	struct net *net = &init_net;
+	struct net *net = xp_net(xp);
 	struct xfrm_userpolicy_info *p;
 	struct xfrm_userpolicy_id *id;
 	struct nlmsghdr *nlh;
-- 
1.5.6.5

