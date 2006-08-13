From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 15/16] [NET] link: Convert notifications to use rtnl_notify()
Date: Mon, 14 Aug 2006 00:00:15 +0200
Message-ID: <20060814214343.781776800@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:26062 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964992AbWHNVpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:45:33 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=rtnl_convert_link
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/core/rtnetlink.c
===================================================================
--- net-2.6.19.git.orig/net/core/rtnetlink.c
+++ net-2.6.19.git/net/core/rtnetlink.c
@@ -630,20 +630,22 @@ static int rtnl_dump_all(struct sk_buff 
 void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change)
 {
 	struct sk_buff *skb;
-	int size = NLMSG_SPACE(sizeof(struct ifinfomsg) +
-			       sizeof(struct rtnl_link_ifmap) +
-			       sizeof(struct rtnl_link_stats) + 128);
-
-	skb = nlmsg_new(size, GFP_KERNEL);
-	if (!skb)
-		return;
+	int err = -ENOBUFS;
 
-	if (rtnl_fill_ifinfo(skb, dev, NULL, 0, type, 0, 0, change, 0) < 0) {
+	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (skb == NULL)
+		goto errout;
+
+	err = rtnl_fill_ifinfo(skb, dev, NULL, 0, type, 0, 0, change, 0);
+	if (err < 0) {
 		kfree_skb(skb);
-		return;
+		goto errout;
 	}
-	NETLINK_CB(skb).dst_group = RTNLGRP_LINK;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_LINK, GFP_KERNEL);
+
+	err = rtnl_notify(skb, 0, RTNLGRP_LINK, NULL, GFP_KERNEL);
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(RTNLGRP_LINK, err);
 }
 
 /* Protected by RTNL sempahore.  */

