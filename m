From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 04/16] [XFRM] netlink: Use nlmsg_broadcast() and nlmsg_unicast()
Date: Wed, 22 Aug 2007 16:55:42 +0200
Message-ID: <20070822145630.343335774@lsx.localdomain>
References: <20070822145538.861270927@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56968 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763210AbXHVP3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:29:18 -0400
Content-Disposition: inline; filename=xfrm_netlink_broadcast
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This simplifies successful return codes from >0 to 0.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_user.c	2007-08-21 16:13:57.000000000 +0200
+++ net-2.6.24/net/xfrm/xfrm_user.c	2007-08-21 16:15:03.000000000 +0200
@@ -800,8 +800,7 @@ static int xfrm_get_sa(struct sk_buff *s
 	if (IS_ERR(resp_skb)) {
 		err = PTR_ERR(resp_skb);
 	} else {
-		err = netlink_unicast(xfrm_nl, resp_skb,
-				      NETLINK_CB(skb).pid, MSG_DONTWAIT);
+		err = nlmsg_unicast(xfrm_nl, resp_skb, NETLINK_CB(skb).pid);
 	}
 	xfrm_state_put(x);
 out_noput:
@@ -882,8 +881,7 @@ static int xfrm_alloc_userspi(struct sk_
 		goto out;
 	}
 
-	err = netlink_unicast(xfrm_nl, resp_skb,
-			      NETLINK_CB(skb).pid, MSG_DONTWAIT);
+	err = nlmsg_unicast(xfrm_nl, resp_skb, NETLINK_CB(skb).pid);
 
 out:
 	xfrm_state_put(x);
@@ -1393,9 +1391,8 @@ static int xfrm_get_policy(struct sk_buf
 		if (IS_ERR(resp_skb)) {
 			err = PTR_ERR(resp_skb);
 		} else {
-			err = netlink_unicast(xfrm_nl, resp_skb,
-					      NETLINK_CB(skb).pid,
-					      MSG_DONTWAIT);
+			err = nlmsg_unicast(xfrm_nl, resp_skb,
+					    NETLINK_CB(skb).pid);
 		}
 	} else {
 		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
@@ -1525,8 +1522,7 @@ static int xfrm_get_ae(struct sk_buff *s
 
 	if (build_aevent(r_skb, x, &c) < 0)
 		BUG();
-	err = netlink_unicast(xfrm_nl, r_skb,
-			      NETLINK_CB(skb).pid, MSG_DONTWAIT);
+	err = nlmsg_unicast(xfrm_nl, r_skb, NETLINK_CB(skb).pid);
 	spin_unlock_bh(&x->lock);
 	xfrm_state_put(x);
 	return err;
@@ -1903,9 +1899,7 @@ static int xfrm_send_migrate(struct xfrm
 	if (build_migrate(skb, m, num_migrate, sel, dir, type) < 0)
 		BUG();
 
-	NETLINK_CB(skb).dst_group = XFRMNLGRP_MIGRATE;
-	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_MIGRATE,
-				 GFP_ATOMIC);
+	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_MIGRATE, GFP_ATOMIC);
 }
 #else
 static int xfrm_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
@@ -2061,8 +2055,7 @@ static int xfrm_exp_state_notify(struct 
 	if (build_expire(skb, x, c) < 0)
 		BUG();
 
-	NETLINK_CB(skb).dst_group = XFRMNLGRP_EXPIRE;
-	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
+	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
 }
 
 static int xfrm_aevent_state_notify(struct xfrm_state *x, struct km_event *c)
@@ -2079,8 +2072,7 @@ static int xfrm_aevent_state_notify(stru
 	if (build_aevent(skb, x, c) < 0)
 		BUG();
 
-	NETLINK_CB(skb).dst_group = XFRMNLGRP_AEVENTS;
-	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_AEVENTS, GFP_ATOMIC);
+	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_AEVENTS, GFP_ATOMIC);
 }
 
 static int xfrm_notify_sa_flush(struct km_event *c)
@@ -2105,8 +2097,7 @@ static int xfrm_notify_sa_flush(struct k
 
 	nlmsg_end(skb, nlh);
 
-	NETLINK_CB(skb).dst_group = XFRMNLGRP_SA;
-	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
+	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
 }
 
 static inline int xfrm_sa_len(struct xfrm_state *x)
@@ -2175,8 +2166,7 @@ static int xfrm_notify_sa(struct xfrm_st
 
 	nlmsg_end(skb, nlh);
 
-	NETLINK_CB(skb).dst_group = XFRMNLGRP_SA;
-	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
+	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
 
 nlmsg_failure:
 rtattr_failure:
@@ -2262,8 +2252,7 @@ static int xfrm_send_acquire(struct xfrm
 	if (build_acquire(skb, x, xt, xp, dir) < 0)
 		BUG();
 
-	NETLINK_CB(skb).dst_group = XFRMNLGRP_ACQUIRE;
-	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_ACQUIRE, GFP_ATOMIC);
+	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_ACQUIRE, GFP_ATOMIC);
 }
 
 /* User gives us xfrm_user_policy_info followed by an array of 0
@@ -2371,8 +2360,7 @@ static int xfrm_exp_policy_notify(struct
 	if (build_polexpire(skb, xp, dir, c) < 0)
 		BUG();
 
-	NETLINK_CB(skb).dst_group = XFRMNLGRP_EXPIRE;
-	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
+	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
 }
 
 static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *c)
@@ -2423,8 +2411,7 @@ static int xfrm_notify_policy(struct xfr
 
 	nlmsg_end(skb, nlh);
 
-	NETLINK_CB(skb).dst_group = XFRMNLGRP_POLICY;
-	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
+	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
 
 nlmsg_failure:
 rtattr_failure:
@@ -2454,8 +2441,7 @@ static int xfrm_notify_policy_flush(stru
 
 	nlmsg_end(skb, nlh);
 
-	NETLINK_CB(skb).dst_group = XFRMNLGRP_POLICY;
-	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
+	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
 
 nlmsg_failure:
 	kfree_skb(skb);
@@ -2520,8 +2506,7 @@ static int xfrm_send_report(u8 proto, st
 	if (build_report(skb, proto, sel, addr) < 0)
 		BUG();
 
-	NETLINK_CB(skb).dst_group = XFRMNLGRP_REPORT;
-	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_REPORT, GFP_ATOMIC);
+	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_REPORT, GFP_ATOMIC);
 }
 
 static struct xfrm_mgr netlink_mgr = {

-- 

