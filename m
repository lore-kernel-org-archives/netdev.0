From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 40/53] netns xfrm: per-netns NETLINK_XFRM socket
Date: Tue, 25 Nov 2008 20:27:12 +0300
Message-ID: <1227634045-27534-40-git-send-email-adobriyan@gmail.com>
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
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:29237 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754476AbYKYRZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:25:18 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1144716ugf.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:25:16 -0800 (PST)
In-Reply-To: <1227634045-27534-39-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stub senders to init_net's one temporarily.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/netns/xfrm.h |    2 +
 include/net/xfrm.h       |    7 ++-
 net/xfrm/xfrm_output.c   |    3 +-
 net/xfrm/xfrm_state.c    |    7 +--
 net/xfrm/xfrm_user.c     |  108 +++++++++++++++++++++++++++++++---------------
 5 files changed, 83 insertions(+), 44 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index c53d173..09f3060 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -39,6 +39,8 @@ struct netns_xfrm {
 	struct xfrm_policy_hash	policy_bydst[XFRM_POLICY_MAX * 2];
 	unsigned int		policy_count[XFRM_POLICY_MAX * 2];
 	struct work_struct	policy_hash_work;
+
+	struct sock		*nlsk;
 };
 
 #endif
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index bd25150..e027179 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -48,7 +48,6 @@ DECLARE_SNMP_STAT(struct linux_xfrm_mib, xfrm_statistics);
 #define XFRM_INC_STATS_USER(field)
 #endif
 
-extern struct sock *xfrm_nl;
 extern u32 sysctl_xfrm_aevent_etime;
 extern u32 sysctl_xfrm_aevent_rseqth;
 extern int sysctl_xfrm_larval_drop;
@@ -1516,18 +1515,20 @@ static inline int xfrm_policy_id2dir(u32 index)
 	return index & 7;
 }
 
-static inline int xfrm_aevent_is_on(void)
+#ifdef CONFIG_XFRM
+static inline int xfrm_aevent_is_on(struct net *net)
 {
 	struct sock *nlsk;
 	int ret = 0;
 
 	rcu_read_lock();
-	nlsk = rcu_dereference(xfrm_nl);
+	nlsk = rcu_dereference(net->xfrm.nlsk);
 	if (nlsk)
 		ret = netlink_has_listeners(nlsk, XFRMNLGRP_AEVENTS);
 	rcu_read_unlock();
 	return ret;
 }
+#endif
 
 static inline int xfrm_alg_len(struct xfrm_algo *alg)
 {
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index dc50f1e..ba90e5e 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -41,6 +41,7 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 {
 	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x = dst->xfrm;
+	struct net *net = xs_net(x);
 
 	if (err <= 0)
 		goto resume;
@@ -74,7 +75,7 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 				err = -EOVERFLOW;
 				goto error;
 			}
-			if (xfrm_aevent_is_on())
+			if (xfrm_aevent_is_on(net))
 				xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
 		}
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index ea340bb..21db37a 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -24,9 +24,6 @@
 
 #include "xfrm_hash.h"
 
-struct sock *xfrm_nl;
-EXPORT_SYMBOL(xfrm_nl);
-
 u32 sysctl_xfrm_aevent_etime __read_mostly = XFRM_AE_ETIME;
 EXPORT_SYMBOL(sysctl_xfrm_aevent_etime);
 
@@ -1659,7 +1656,7 @@ static void xfrm_replay_timer_handler(unsigned long data)
 	spin_lock(&x->lock);
 
 	if (x->km.state == XFRM_STATE_VALID) {
-		if (xfrm_aevent_is_on())
+		if (xfrm_aevent_is_on(xs_net(x)))
 			xfrm_replay_notify(x, XFRM_REPLAY_TIMEOUT);
 		else
 			x->xflags |= XFRM_TIME_DEFER;
@@ -1715,7 +1712,7 @@ void xfrm_replay_advance(struct xfrm_state *x, __be32 net_seq)
 		x->replay.bitmap |= (1U << diff);
 	}
 
-	if (xfrm_aevent_is_on())
+	if (xfrm_aevent_is_on(xs_net(x)))
 		xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
 }
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index f6e0272..8b5b01d 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -703,6 +703,7 @@ nla_put_failure:
 static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
+	struct net *net = sock_net(skb->sk);
 	struct sk_buff *r_skb;
 	u32 *flags = nlmsg_data(nlh);
 	u32 spid = NETLINK_CB(skb).pid;
@@ -715,7 +716,7 @@ static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (build_spdinfo(r_skb, spid, seq, *flags) < 0)
 		BUG();
 
-	return nlmsg_unicast(xfrm_nl, r_skb, spid);
+	return nlmsg_unicast(net->xfrm.nlsk, r_skb, spid);
 }
 
 static inline size_t xfrm_sadinfo_msgsize(void)
@@ -756,6 +757,7 @@ nla_put_failure:
 static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
+	struct net *net = sock_net(skb->sk);
 	struct sk_buff *r_skb;
 	u32 *flags = nlmsg_data(nlh);
 	u32 spid = NETLINK_CB(skb).pid;
@@ -768,12 +770,13 @@ static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (build_sadinfo(r_skb, spid, seq, *flags) < 0)
 		BUG();
 
-	return nlmsg_unicast(xfrm_nl, r_skb, spid);
+	return nlmsg_unicast(net->xfrm.nlsk, r_skb, spid);
 }
 
 static int xfrm_get_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
+	struct net *net = &init_net;
 	struct xfrm_usersa_id *p = nlmsg_data(nlh);
 	struct xfrm_state *x;
 	struct sk_buff *resp_skb;
@@ -787,7 +790,7 @@ static int xfrm_get_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (IS_ERR(resp_skb)) {
 		err = PTR_ERR(resp_skb);
 	} else {
-		err = nlmsg_unicast(xfrm_nl, resp_skb, NETLINK_CB(skb).pid);
+		err = nlmsg_unicast(net->xfrm.nlsk, resp_skb, NETLINK_CB(skb).pid);
 	}
 	xfrm_state_put(x);
 out_noput:
@@ -820,6 +823,7 @@ static int verify_userspi_info(struct xfrm_userspi_info *p)
 static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
+	struct net *net = &init_net;
 	struct xfrm_state *x;
 	struct xfrm_userspi_info *p;
 	struct sk_buff *resp_skb;
@@ -837,7 +841,7 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	x = NULL;
 	if (p->info.seq) {
-		x = xfrm_find_acq_byseq(&init_net, p->info.seq);
+		x = xfrm_find_acq_byseq(net, p->info.seq);
 		if (x && xfrm_addr_cmp(&x->id.daddr, daddr, family)) {
 			xfrm_state_put(x);
 			x = NULL;
@@ -845,7 +849,7 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 	}
 
 	if (!x)
-		x = xfrm_find_acq(&init_net, p->info.mode, p->info.reqid,
+		x = xfrm_find_acq(net, p->info.mode, p->info.reqid,
 				  p->info.id.proto, daddr,
 				  &p->info.saddr, 1,
 				  family);
@@ -863,7 +867,7 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 		goto out;
 	}
 
-	err = nlmsg_unicast(xfrm_nl, resp_skb, NETLINK_CB(skb).pid);
+	err = nlmsg_unicast(net->xfrm.nlsk, resp_skb, NETLINK_CB(skb).pid);
 
 out:
 	xfrm_state_put(x);
@@ -1311,6 +1315,7 @@ static struct sk_buff *xfrm_policy_netlink(struct sk_buff *in_skb,
 static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
+	struct net *net = &init_net;
 	struct xfrm_policy *xp;
 	struct xfrm_userpolicy_id *p;
 	u8 type = XFRM_POLICY_TYPE_MAIN;
@@ -1330,7 +1335,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return err;
 
 	if (p->index)
-		xp = xfrm_policy_byid(&init_net, type, p->dir, p->index, delete, &err);
+		xp = xfrm_policy_byid(net, type, p->dir, p->index, delete, &err);
 	else {
 		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
 		struct xfrm_sec_ctx *ctx;
@@ -1347,7 +1352,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 			if (err)
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(&init_net, type, p->dir, &p->sel, ctx,
+		xp = xfrm_policy_bysel_ctx(net, type, p->dir, &p->sel, ctx,
 					   delete, &err);
 		security_xfrm_policy_free(ctx);
 	}
@@ -1361,7 +1366,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		if (IS_ERR(resp_skb)) {
 			err = PTR_ERR(resp_skb);
 		} else {
-			err = nlmsg_unicast(xfrm_nl, resp_skb,
+			err = nlmsg_unicast(net->xfrm.nlsk, resp_skb,
 					    NETLINK_CB(skb).pid);
 		}
 	} else {
@@ -1457,6 +1462,7 @@ nla_put_failure:
 static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
+	struct net *net = &init_net;
 	struct xfrm_state *x;
 	struct sk_buff *r_skb;
 	int err;
@@ -1468,7 +1474,7 @@ static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (r_skb == NULL)
 		return -ENOMEM;
 
-	x = xfrm_state_lookup(&init_net, &id->daddr, id->spi, id->proto, id->family);
+	x = xfrm_state_lookup(net, &id->daddr, id->spi, id->proto, id->family);
 	if (x == NULL) {
 		kfree_skb(r_skb);
 		return -ESRCH;
@@ -1486,7 +1492,7 @@ static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	if (build_aevent(r_skb, x, &c) < 0)
 		BUG();
-	err = nlmsg_unicast(xfrm_nl, r_skb, NETLINK_CB(skb).pid);
+	err = nlmsg_unicast(net->xfrm.nlsk, r_skb, NETLINK_CB(skb).pid);
 	spin_unlock_bh(&x->lock);
 	xfrm_state_put(x);
 	return err;
@@ -1869,6 +1875,7 @@ static int xfrm_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
 			     struct xfrm_migrate *m, int num_migrate,
 			     struct xfrm_kmaddress *k)
 {
+	struct net *net = &init_net;
 	struct sk_buff *skb;
 
 	skb = nlmsg_new(xfrm_migrate_msgsize(num_migrate, !!k), GFP_ATOMIC);
@@ -1879,7 +1886,7 @@ static int xfrm_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
 	if (build_migrate(skb, m, num_migrate, k, sel, dir, type) < 0)
 		BUG();
 
-	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_MIGRATE, GFP_ATOMIC);
+	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_MIGRATE, GFP_ATOMIC);
 }
 #else
 static int xfrm_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
@@ -1968,6 +1975,7 @@ static struct xfrm_link {
 
 static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
+	struct net *net = sock_net(skb->sk);
 	struct nlattr *attrs[XFRMA_MAX+1];
 	struct xfrm_link *link;
 	int type, err;
@@ -1989,7 +1997,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (link->dump == NULL)
 			return -EINVAL;
 
-		return netlink_dump_start(xfrm_nl, skb, nlh, link->dump, link->done);
+		return netlink_dump_start(net->xfrm.nlsk, skb, nlh, link->dump, link->done);
 	}
 
 	err = nlmsg_parse(nlh, xfrm_msg_min[type], attrs, XFRMA_MAX,
@@ -2033,6 +2041,7 @@ static int build_expire(struct sk_buff *skb, struct xfrm_state *x, struct km_eve
 
 static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
 {
+	struct net *net = &init_net;
 	struct sk_buff *skb;
 
 	skb = nlmsg_new(xfrm_expire_msgsize(), GFP_ATOMIC);
@@ -2042,11 +2051,12 @@ static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
 	if (build_expire(skb, x, c) < 0)
 		BUG();
 
-	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
+	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
 }
 
 static int xfrm_aevent_state_notify(struct xfrm_state *x, struct km_event *c)
 {
+	struct net *net = &init_net;
 	struct sk_buff *skb;
 
 	skb = nlmsg_new(xfrm_aevent_msgsize(), GFP_ATOMIC);
@@ -2056,11 +2066,12 @@ static int xfrm_aevent_state_notify(struct xfrm_state *x, struct km_event *c)
 	if (build_aevent(skb, x, c) < 0)
 		BUG();
 
-	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_AEVENTS, GFP_ATOMIC);
+	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_AEVENTS, GFP_ATOMIC);
 }
 
 static int xfrm_notify_sa_flush(struct km_event *c)
 {
+	struct net *net = &init_net;
 	struct xfrm_usersa_flush *p;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
@@ -2081,7 +2092,7 @@ static int xfrm_notify_sa_flush(struct km_event *c)
 
 	nlmsg_end(skb, nlh);
 
-	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
+	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
 }
 
 static inline size_t xfrm_sa_len(struct xfrm_state *x)
@@ -2111,6 +2122,7 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 
 static int xfrm_notify_sa(struct xfrm_state *x, struct km_event *c)
 {
+	struct net *net = &init_net;
 	struct xfrm_usersa_info *p;
 	struct xfrm_usersa_id *id;
 	struct nlmsghdr *nlh;
@@ -2155,7 +2167,7 @@ static int xfrm_notify_sa(struct xfrm_state *x, struct km_event *c)
 
 	nlmsg_end(skb, nlh);
 
-	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
+	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
 
 nla_put_failure:
 	/* Somebody screwed up with xfrm_sa_len! */
@@ -2235,6 +2247,7 @@ nlmsg_failure:
 static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *xt,
 			     struct xfrm_policy *xp, int dir)
 {
+	struct net *net = xs_net(x);
 	struct sk_buff *skb;
 
 	skb = nlmsg_new(xfrm_acquire_msgsize(x, xp), GFP_ATOMIC);
@@ -2244,7 +2257,7 @@ static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *xt,
 	if (build_acquire(skb, x, xt, xp, dir) < 0)
 		BUG();
 
-	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_ACQUIRE, GFP_ATOMIC);
+	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_ACQUIRE, GFP_ATOMIC);
 }
 
 /* User gives us xfrm_user_policy_info followed by an array of 0
@@ -2344,6 +2357,7 @@ nlmsg_failure:
 
 static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
 {
+	struct net *net = &init_net;
 	struct sk_buff *skb;
 
 	skb = nlmsg_new(xfrm_polexpire_msgsize(xp), GFP_ATOMIC);
@@ -2353,11 +2367,12 @@ static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, struct km_eve
 	if (build_polexpire(skb, xp, dir, c) < 0)
 		BUG();
 
-	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
+	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
 }
 
 static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *c)
 {
+	struct net *net = &init_net;
 	struct xfrm_userpolicy_info *p;
 	struct xfrm_userpolicy_id *id;
 	struct nlmsghdr *nlh;
@@ -2408,7 +2423,7 @@ static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *
 
 	nlmsg_end(skb, nlh);
 
-	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
+	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
 
 nlmsg_failure:
 	kfree_skb(skb);
@@ -2417,6 +2432,7 @@ nlmsg_failure:
 
 static int xfrm_notify_policy_flush(struct km_event *c)
 {
+	struct net *net = &init_net;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
 
@@ -2432,7 +2448,7 @@ static int xfrm_notify_policy_flush(struct km_event *c)
 
 	nlmsg_end(skb, nlh);
 
-	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
+	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
 
 nlmsg_failure:
 	kfree_skb(skb);
@@ -2491,6 +2507,7 @@ nla_put_failure:
 static int xfrm_send_report(u8 proto, struct xfrm_selector *sel,
 			    xfrm_address_t *addr)
 {
+	struct net *net = &init_net;
 	struct sk_buff *skb;
 
 	skb = nlmsg_new(xfrm_report_msgsize(), GFP_ATOMIC);
@@ -2500,7 +2517,7 @@ static int xfrm_send_report(u8 proto, struct xfrm_selector *sel,
 	if (build_report(skb, proto, sel, addr) < 0)
 		BUG();
 
-	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_REPORT, GFP_ATOMIC);
+	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_REPORT, GFP_ATOMIC);
 }
 
 static inline size_t xfrm_mapping_msgsize(void)
@@ -2536,6 +2553,7 @@ static int build_mapping(struct sk_buff *skb, struct xfrm_state *x,
 static int xfrm_send_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 			     __be16 sport)
 {
+	struct net *net = xs_net(x);
 	struct sk_buff *skb;
 
 	if (x->id.proto != IPPROTO_ESP)
@@ -2551,7 +2569,7 @@ static int xfrm_send_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	if (build_mapping(skb, x, ipaddr, sport) < 0)
 		BUG();
 
-	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_MAPPING, GFP_ATOMIC);
+	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_MAPPING, GFP_ATOMIC);
 }
 
 static struct xfrm_mgr netlink_mgr = {
@@ -2565,33 +2583,53 @@ static struct xfrm_mgr netlink_mgr = {
 	.new_mapping	= xfrm_send_mapping,
 };
 
-static int __init xfrm_user_init(void)
+static int __net_init xfrm_user_net_init(struct net *net)
 {
 	struct sock *nlsk;
 
-	printk(KERN_INFO "Initializing XFRM netlink socket\n");
-
-	nlsk = netlink_kernel_create(&init_net, NETLINK_XFRM, XFRMNLGRP_MAX,
+	nlsk = netlink_kernel_create(net, NETLINK_XFRM, XFRMNLGRP_MAX,
 				     xfrm_netlink_rcv, NULL, THIS_MODULE);
 	if (nlsk == NULL)
 		return -ENOMEM;
-	rcu_assign_pointer(xfrm_nl, nlsk);
-
-	xfrm_register_km(&netlink_mgr);
-
+	rcu_assign_pointer(net->xfrm.nlsk, nlsk);
 	return 0;
 }
 
-static void __exit xfrm_user_exit(void)
+static void __net_exit xfrm_user_net_exit(struct net *net)
 {
-	struct sock *nlsk = xfrm_nl;
+	struct sock *nlsk = net->xfrm.nlsk;
 
-	xfrm_unregister_km(&netlink_mgr);
-	rcu_assign_pointer(xfrm_nl, NULL);
+	rcu_assign_pointer(net->xfrm.nlsk, NULL);
 	synchronize_rcu();
 	netlink_kernel_release(nlsk);
 }
 
+static struct pernet_operations xfrm_user_net_ops = {
+	.init = xfrm_user_net_init,
+	.exit = xfrm_user_net_exit,
+};
+
+static int __init xfrm_user_init(void)
+{
+	int rv;
+
+	printk(KERN_INFO "Initializing XFRM netlink socket\n");
+
+	rv = register_pernet_subsys(&xfrm_user_net_ops);
+	if (rv < 0)
+		return rv;
+	rv = xfrm_register_km(&netlink_mgr);
+	if (rv < 0)
+		unregister_pernet_subsys(&xfrm_user_net_ops);
+	return rv;
+}
+
+static void __exit xfrm_user_exit(void)
+{
+	xfrm_unregister_km(&netlink_mgr);
+	unregister_pernet_subsys(&xfrm_user_net_ops);
+}
+
 module_init(xfrm_user_init);
 module_exit(xfrm_user_exit);
 MODULE_LICENSE("GPL");
-- 
1.5.6.5

