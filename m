From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH v2] net: xfrm_user: use BUG_ON instead of if condition
 followed by BUG
Date: Thu, 26 Oct 2017 06:31:35 -0500
Message-ID: <20171026113135.GA8044@embeddedor.com>
References: <20171026054745.Horde.IgJuLhgV7tprdH0lZ5Pdj0U@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway32.websitewelcome.com ([192.185.145.125]:23690 "EHLO
        gateway32.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751232AbdJZLg4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 07:36:56 -0400
Received: from cm17.websitewelcome.com (cm17.websitewelcome.com [100.42.49.20])
        by gateway32.websitewelcome.com (Postfix) with ESMTP id CB3CC271EE9
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 06:31:42 -0500 (CDT)
Content-Disposition: inline
In-Reply-To: <20171026054745.Horde.IgJuLhgV7tprdH0lZ5Pdj0U@gator4166.hostgator.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use BUG_ON instead of if condition followed by BUG.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
Changes in v2:
 Update the code as suggested by Herbert Xu:

 int err;

 err = foo();
 BUG_ON(err < 0);

 net/xfrm/xfrm_user.c | 45 +++++++++++++++++++++++++++------------------
 1 file changed, 27 insertions(+), 18 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index b997f13..fb8c79e 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1147,13 +1147,14 @@ static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
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
@@ -1205,13 +1206,14 @@ static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
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
@@ -1958,8 +1960,9 @@ static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
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
@@ -2386,6 +2389,7 @@ static int xfrm_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 {
 	struct net *net = &init_net;
 	struct sk_buff *skb;
+	int err;
 
 	skb = nlmsg_new(xfrm_migrate_msgsize(num_migrate, !!k, !!encap),
 			GFP_ATOMIC);
@@ -2393,8 +2397,8 @@ static int xfrm_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 		return -ENOMEM;
 
 	/* build migrate */
-	if (build_migrate(skb, m, num_migrate, k, sel, encap, dir, type) < 0)
-		BUG();
+	err = build_migrate(skb, m, num_migrate, k, sel, encap, dir, type);
+	BUG_ON(err < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_MIGRATE);
 }
@@ -2618,13 +2622,14 @@ static int xfrm_aevent_state_notify(struct xfrm_state *x, const struct km_event
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
@@ -3105,13 +3112,14 @@ static int xfrm_send_report(struct net *net, u8 proto,
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
@@ -3152,6 +3160,7 @@ static int xfrm_send_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 {
 	struct net *net = xs_net(x);
 	struct sk_buff *skb;
+	int err;
 
 	if (x->id.proto != IPPROTO_ESP)
 		return -EINVAL;
@@ -3163,8 +3172,8 @@ static int xfrm_send_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
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
