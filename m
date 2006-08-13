From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 05/16] [NEIGH]: Convert neighbour notifications ot use rtnl_notify()
Date: Mon, 14 Aug 2006 00:00:05 +0200
Message-ID: <20060814214340.423050244@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:17870 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964980AbWHNVol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:44:41 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=rtnl_convert_neigh
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/core/neighbour.c
===================================================================
--- net-2.6.19.git.orig/net/core/neighbour.c
+++ net-2.6.19.git/net/core/neighbour.c
@@ -2406,36 +2406,35 @@ static struct file_operations neigh_stat
 #endif /* CONFIG_PROC_FS */
 
 #ifdef CONFIG_ARPD
-void neigh_app_ns(struct neighbour *n)
+static void __neigh_notify(struct neighbour *n, int type, int flags)
 {
 	struct sk_buff *skb;
+	int err = -ENOBUFS;
 
 	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
 	if (skb == NULL)
-		return;
+		goto errout;
 
-	if (neigh_fill_info(skb, n, 0, 0, RTM_GETNEIGH, NLM_F_REQUEST) <= 0)
+	err = neigh_fill_info(skb, n, 0, 0, type, flags);
+	if (err < 0) {
 		kfree_skb(skb);
-	else {
-		NETLINK_CB(skb).dst_group  = RTNLGRP_NEIGH;
-		netlink_broadcast(rtnl, skb, 0, RTNLGRP_NEIGH, GFP_ATOMIC);
+		goto errout;
 	}
+
+	err = rtnl_notify(skb, 0, RTNLGRP_NEIGH, NULL, GFP_ATOMIC);
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(RTNLGRP_NEIGH, err);
 }
 
-static void neigh_app_notify(struct neighbour *n)
+void neigh_app_ns(struct neighbour *n)
 {
-	struct sk_buff *skb;
-
-	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
-	if (skb == NULL)
-		return;
+	__neigh_notify(n, RTM_GETNEIGH, NLM_F_REQUEST);
+}
 
-	if (neigh_fill_info(skb, n, 0, 0, RTM_NEWNEIGH, 0) <= 0)
-		kfree_skb(skb);
-	else {
-		NETLINK_CB(skb).dst_group  = RTNLGRP_NEIGH;
-		netlink_broadcast(rtnl, skb, 0, RTNLGRP_NEIGH, GFP_ATOMIC);
-	}
+static void neigh_app_notify(struct neighbour *n)
+{
+	__neigh_notify(n, RTM_NEWNEIGH, 0);
 }
 
 #endif /* CONFIG_ARPD */

