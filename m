From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 13/16] [BRIDGE]: Convert notifications to use rtnl_notify()
Date: Mon, 14 Aug 2006 00:00:13 +0200
Message-ID: <20060814214343.123867825@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:24782 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964986AbWHNVpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:45:22 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=rtnl_convert_bridge
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes a wrong use of current->pid as netlink pid.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/bridge/br_netlink.c
===================================================================
--- net-2.6.19.git.orig/net/bridge/br_netlink.c
+++ net-2.6.19.git/net/bridge/br_netlink.c
@@ -12,6 +12,7 @@
 
 #include <linux/kernel.h>
 #include <linux/rtnetlink.h>
+#include <net/netlink.h>
 #include "br_private.h"
 
 /*
@@ -76,26 +77,24 @@ rtattr_failure:
 void br_ifinfo_notify(int event, struct net_bridge_port *port)
 {
 	struct sk_buff *skb;
-	int err = -ENOMEM;
+	int payload = sizeof(struct ifinfomsg) + 128;
+	int err = -ENOBUFS;
 
 	pr_debug("bridge notify event=%d\n", event);
-	skb = alloc_skb(NLMSG_SPACE(sizeof(struct ifinfomsg) + 128),
-			GFP_ATOMIC);
-	if (!skb)
-		goto err_out;
+	skb = nlmsg_new(nlmsg_total_size(payload), GFP_ATOMIC);
+	if (skb == NULL)
+		goto errout;
+
+	err = br_fill_ifinfo(skb, port, 0, 0, event, 0);
+	if (err < 0) {
+		kfree_skb(skb);
+		goto errout;
+	}
 
-	err = br_fill_ifinfo(skb, port, current->pid, 0, event, 0);
+	err = rtnl_notify(skb, 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
+errout:
 	if (err < 0)
-		goto err_kfree;
-
-	NETLINK_CB(skb).dst_group = RTNLGRP_LINK;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_LINK, GFP_ATOMIC);
-	return;
-
-err_kfree:
-	kfree_skb(skb);
-err_out:
-	netlink_set_err(rtnl, 0, RTNLGRP_LINK, err);
+		rtnl_set_sk_err(RTNLGRP_LINK, err);
 }
 
 /*

