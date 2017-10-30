From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 7/8] net: xfrm_user: use BUG_ON instead of if condition followed by BUG
Date: Mon, 30 Oct 2017 09:39:34 +0100
Message-ID: <1509352775-9563-8-git-send-email-steffen.klassert@secunet.com>
References: <1509352775-9563-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:41272 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932087AbdJ3Ijp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 04:39:45 -0400
In-Reply-To: <1509352775-9563-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>

Use BUG_ON instead of if condition followed by BUG.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 45 +++++++++++++++++++++++++++------------------
 1 file changed, 27 insertions(+), 18 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index f7a12aa..bbc390e 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1146,13 +1146,14 @@ static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	u32 *flags = nlmsg_data(nlh);
 	u32 sportid = NETLINK_CB(skb).portid;
 	u32 seq = nlh->nlmsg_seq;
+	int err;
 
 	r_skb = nlmsg_new(xfrm_spdinfo_msgsize(), GFP_ATOMIC);
 	if (r_skb == NULL)
 		return -ENOMEM;
 
-	if (build_spdinfo(r_skb, net, sportid, seq, *flags) < 0)
-		BUG();
+	err = build_spdinfo(r_skb, net, sportid, seq, *flags);
+	BUG_ON(err < 0);
 
 	return nlmsg_unicast(net->xfrm.nlsk, r_skb, sportid);
 }
@@ -1204,13 +1205,14 @@ static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	u32 *flags = nlmsg_data(nlh);
 	u32 sportid = NETLINK_CB(skb).portid;
 	u32 seq = nlh->nlmsg_seq;
+	int err;
 
 	r_skb = nlmsg_new(xfrm_sadinfo_msgsize(), GFP_ATOMIC);
 	if (r_skb == NULL)
 		return -ENOMEM;
 
-	if (build_sadinfo(r_skb, net, sportid, seq, *flags) < 0)
-		BUG();
+	err = build_sadinfo(r_skb, net, sportid, seq, *flags);
+	BUG_ON(err < 0);
 
 	return nlmsg_unicast(net->xfrm.nlsk, r_skb, sportid);
 }
@@ -1957,8 +1959,9 @@ static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	c.seq = nlh->nlmsg_seq;
 	c.portid = nlh->nlmsg_pid;
 
-	if (build_aevent(r_skb, x, &c) < 0)
-		BUG();
+	err = build_aevent(r_skb, x, &c);
+	BUG_ON(err < 0);
+
 	err = nlmsg_unicast(net->xfrm.nlsk, r_skb, NETLINK_CB(skb).portid);
 	spin_unlock_bh(&x->lock);
 	xfrm_state_put(x);
@@ -2385,6 +2388,7 @@ static int xfrm_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 {
 	struct net *net = &init_net;
 	struct sk_buff *skb;
+	int err;
 
 	skb = nlmsg_new(xfrm_migrate_msgsize(num_migrate, !!k, !!encap),
 			GFP_ATOMIC);
@@ -2392,8 +2396,8 @@ static int xfrm_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 		return -ENOMEM;
 
 	/* build migrate */
-	if (build_migrate(skb, m, num_migrate, k, sel, encap, dir, type) < 0)
-		BUG();
+	err = build_migrate(skb, m, num_migrate, k, sel, encap, dir, type);
+	BUG_ON(err < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_MIGRATE);
 }
@@ -2617,13 +2621,14 @@ static int xfrm_aevent_state_notify(struct xfrm_state *x, const struct km_event
 {
 	struct net *net = xs_net(x);
 	struct sk_buff *skb;
+	int err;
 
 	skb = nlmsg_new(xfrm_aevent_msgsize(x), GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_aevent(skb, x, c) < 0)
-		BUG();
+	err = build_aevent(skb, x, c);
+	BUG_ON(err < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_AEVENTS);
 }
@@ -2830,13 +2835,14 @@ static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *xt,
 {
 	struct net *net = xs_net(x);
 	struct sk_buff *skb;
+	int err;
 
 	skb = nlmsg_new(xfrm_acquire_msgsize(x, xp), GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_acquire(skb, x, xt, xp) < 0)
-		BUG();
+	err = build_acquire(skb, x, xt, xp);
+	BUG_ON(err < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_ACQUIRE);
 }
@@ -2945,13 +2951,14 @@ static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, const struct
 {
 	struct net *net = xp_net(xp);
 	struct sk_buff *skb;
+	int err;
 
 	skb = nlmsg_new(xfrm_polexpire_msgsize(xp), GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_polexpire(skb, xp, dir, c) < 0)
-		BUG();
+	err = build_polexpire(skb, xp, dir, c);
+	BUG_ON(err < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_EXPIRE);
 }
@@ -3106,13 +3113,14 @@ static int xfrm_send_report(struct net *net, u8 proto,
 			    struct xfrm_selector *sel, xfrm_address_t *addr)
 {
 	struct sk_buff *skb;
+	int err;
 
 	skb = nlmsg_new(xfrm_report_msgsize(), GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_report(skb, proto, sel, addr) < 0)
-		BUG();
+	err = build_report(skb, proto, sel, addr);
+	BUG_ON(err < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_REPORT);
 }
@@ -3153,6 +3161,7 @@ static int xfrm_send_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 {
 	struct net *net = xs_net(x);
 	struct sk_buff *skb;
+	int err;
 
 	if (x->id.proto != IPPROTO_ESP)
 		return -EINVAL;
@@ -3164,8 +3173,8 @@ static int xfrm_send_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_mapping(skb, x, ipaddr, sport) < 0)
-		BUG();
+	err = build_mapping(skb, x, ipaddr, sport);
+	BUG_ON(err < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_MAPPING);
 }
-- 
2.7.4
