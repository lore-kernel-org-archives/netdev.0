From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 10/16] [IPv6] route: Convert route notifications to use rtnl_notify()
Date: Mon, 14 Aug 2006 00:00:10 +0200
Message-ID: <20060814214342.175468940@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:23246 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964987AbWHNVpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:45:07 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=rtnl_convert_ip6_route
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes a wrong use of current->pid as netlink pid.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/ipv6/route.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/route.c
+++ net-2.6.19.git/net/ipv6/route.c
@@ -35,7 +35,6 @@
 #include <linux/netdevice.h>
 #include <linux/in6.h>
 #include <linux/init.h>
-#include <linux/netlink.h>
 #include <linux/if_arp.h>
 
 #ifdef 	CONFIG_PROC_FS
@@ -54,6 +53,7 @@
 #include <net/dst.h>
 #include <net/xfrm.h>
 #include <net/netevent.h>
+#include <net/netlink.h>
 
 #include <asm/uaccess.h>
 
@@ -2052,27 +2052,25 @@ void inet6_rt_notify(int event, struct r
 			struct netlink_skb_parms *req)
 {
 	struct sk_buff *skb;
-	int size = NLMSG_SPACE(sizeof(struct rtmsg)+256);
-	u32 pid = current->pid;
-	u32 seq = 0;
-
-	if (req)
-		pid = req->pid;
-	if (nlh)
-		seq = nlh->nlmsg_seq;
-	
-	skb = alloc_skb(size, gfp_any());
-	if (!skb) {
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_ROUTE, ENOBUFS);
-		return;
-	}
-	if (rt6_fill_node(skb, rt, NULL, NULL, 0, event, pid, seq, 0, 0) < 0) {
+	u32 pid = req ? req->pid : 0;
+	u32 seq = nlh ? nlh->nlmsg_seq : 0;
+	int payload = sizeof(struct rtmsg) + 256;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(nlmsg_total_size(payload), gfp_any());
+	if (skb == NULL)
+		goto errout;
+
+	err = rt6_fill_node(skb, rt, NULL, NULL, 0, event, pid, seq, 0, 0);
+	if (err < 0) {
 		kfree_skb(skb);
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_ROUTE, EINVAL);
-		return;
+		goto errout;
 	}
-	NETLINK_CB(skb).dst_group = RTNLGRP_IPV6_ROUTE;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV6_ROUTE, gfp_any());
+
+	err = rtnl_notify(skb, pid, RTNLGRP_IPV6_ROUTE, nlh, gfp_any());
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(RTNLGRP_IPV6_ROUTE, err);
 }
 
 /*

