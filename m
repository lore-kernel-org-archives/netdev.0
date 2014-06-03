From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH ipsec] xfrm: fix race between netns cleanup and state expire
 notification
Date: Tue,  3 Jun 2014 10:26:06 +0200 (CEST)
Message-ID: <20140603082606.C28C1A3A9B@unicorn.suse.cz>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34813 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932171AbaFCI0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2014 04:26:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The xfrm_user module registers its pernet init/exit after xfrm
itself so that its net exit function xfrm_user_net_exit() is
executed before xfrm_net_exit() which calls xfrm_state_fini() to
cleanup the SA's (xfrm states). This opens a window between
zeroing net->xfrm.nlsk pointer and deleting all xfrm_state
instances which may access it (via the timer). If an xfrm state
expires in this window, xfrm_exp_state_notify() will pass null
pointer as socket to nlmsg_multicast().

As the notifications are called inside rcu_read_lock() block, it
is sufficient to retrieve the nlsk socket with rcu_dereference()
and check the it for null.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/xfrm/xfrm_user.c | 36 +++++++++++++++++++++++++-----------
 1 file changed, 25 insertions(+), 11 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 8f131c1..c3b7d19 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -955,6 +955,20 @@ static struct sk_buff *xfrm_state_netlink(struct sk_buff *in_skb,
 	return skb;
 }
 
+/* A wrapper for nlmsg_multicast() checking that nlsk is still available.
+ * Must be called with RCU read lock.
+ */
+static inline int xfrm_nlmsg_multicast(struct net *net, struct sk_buff *skb,
+				       u32 pid, unsigned int group)
+{
+	struct sock *nlsk = rcu_dereference(net->xfrm.nlsk);
+
+	if (nlsk)
+		return nlmsg_multicast(nlsk, skb, pid, group, GFP_ATOMIC);
+	else
+		return -1;
+}
+
 static inline size_t xfrm_spdinfo_msgsize(void)
 {
 	return NLMSG_ALIGN(4)
@@ -2265,7 +2279,7 @@ static int xfrm_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 	if (build_migrate(skb, m, num_migrate, k, sel, dir, type) < 0)
 		BUG();
 
-	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_MIGRATE, GFP_ATOMIC);
+	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_MIGRATE);
 }
 #else
 static int xfrm_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
@@ -2456,7 +2470,7 @@ static int xfrm_exp_state_notify(struct xfrm_state *x, const struct km_event *c)
 		return -EMSGSIZE;
 	}
 
-	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
+	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_EXPIRE);
 }
 
 static int xfrm_aevent_state_notify(struct xfrm_state *x, const struct km_event *c)
@@ -2471,7 +2485,7 @@ static int xfrm_aevent_state_notify(struct xfrm_state *x, const struct km_event
 	if (build_aevent(skb, x, c) < 0)
 		BUG();
 
-	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_AEVENTS, GFP_ATOMIC);
+	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_AEVENTS);
 }
 
 static int xfrm_notify_sa_flush(const struct km_event *c)
@@ -2497,7 +2511,7 @@ static int xfrm_notify_sa_flush(const struct km_event *c)
 
 	nlmsg_end(skb, nlh);
 
-	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
+	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_SA);
 }
 
 static inline size_t xfrm_sa_len(struct xfrm_state *x)
@@ -2584,7 +2598,7 @@ static int xfrm_notify_sa(struct xfrm_state *x, const struct km_event *c)
 
 	nlmsg_end(skb, nlh);
 
-	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
+	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_SA);
 
 out_free_skb:
 	kfree_skb(skb);
@@ -2675,7 +2689,7 @@ static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *xt,
 	if (build_acquire(skb, x, xt, xp) < 0)
 		BUG();
 
-	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_ACQUIRE, GFP_ATOMIC);
+	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_ACQUIRE);
 }
 
 /* User gives us xfrm_user_policy_info followed by an array of 0
@@ -2789,7 +2803,7 @@ static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, const struct
 	if (build_polexpire(skb, xp, dir, c) < 0)
 		BUG();
 
-	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
+	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_EXPIRE);
 }
 
 static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, const struct km_event *c)
@@ -2851,7 +2865,7 @@ static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, const struct km_e
 
 	nlmsg_end(skb, nlh);
 
-	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
+	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_POLICY);
 
 out_free_skb:
 	kfree_skb(skb);
@@ -2879,7 +2893,7 @@ static int xfrm_notify_policy_flush(const struct km_event *c)
 
 	nlmsg_end(skb, nlh);
 
-	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
+	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_POLICY);
 
 out_free_skb:
 	kfree_skb(skb);
@@ -2948,7 +2962,7 @@ static int xfrm_send_report(struct net *net, u8 proto,
 	if (build_report(skb, proto, sel, addr) < 0)
 		BUG();
 
-	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_REPORT, GFP_ATOMIC);
+	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_REPORT);
 }
 
 static inline size_t xfrm_mapping_msgsize(void)
@@ -3000,7 +3014,7 @@ static int xfrm_send_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	if (build_mapping(skb, x, ipaddr, sport) < 0)
 		BUG();
 
-	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_MAPPING, GFP_ATOMIC);
+	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_MAPPING);
 }
 
 static bool xfrm_is_alive(const struct km_event *c)
-- 
1.8.4.5
