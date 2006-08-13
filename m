From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Mon, 14 Aug 2006 00:00:09 +0200
Message-ID: <20060814214341.834971519@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:22222 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964979AbWHNVpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:45:02 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=rtnl_convert_ip6_addr
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes a wrong use of current->pid as netlink pid.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/ipv6/addrconf.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/addrconf.c
+++ net-2.6.19.git/net/ipv6/addrconf.c
@@ -73,6 +73,7 @@
 #include <net/addrconf.h>
 #include <net/tcp.h>
 #include <net/ip.h>
+#include <net/netlink.h>
 #include <linux/if_tunnel.h>
 #include <linux/rtnetlink.h>
 
@@ -3280,20 +3281,23 @@ out_free:
 static void inet6_ifa_notify(int event, struct inet6_ifaddr *ifa)
 {
 	struct sk_buff *skb;
-	int size = NLMSG_SPACE(sizeof(struct ifaddrmsg) + INET6_IFADDR_RTA_SPACE);
+	int payload = sizeof(struct ifaddrmsg) + INET6_IFADDR_RTA_SPACE;
+	int err = -ENOBUFS;
 
-	skb = alloc_skb(size, GFP_ATOMIC);
-	if (!skb) {
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_IFADDR, ENOBUFS);
-		return;
-	}
-	if (inet6_fill_ifaddr(skb, ifa, current->pid, 0, event, 0) < 0) {
+	skb = nlmsg_new(nlmsg_total_size(payload), GFP_ATOMIC);
+	if (skb == NULL)
+		goto errout;
+
+	err = inet6_fill_ifaddr(skb, ifa, 0, 0, event, 0);
+	if (err < 0) {
 		kfree_skb(skb);
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_IFADDR, EINVAL);
-		return;
+		goto errout;
 	}
-	NETLINK_CB(skb).dst_group = RTNLGRP_IPV6_IFADDR;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV6_IFADDR, GFP_ATOMIC);
+
+	err = rtnl_notify(skb, 0, RTNLGRP_IPV6_IFADDR, NULL, GFP_ATOMIC);
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(RTNLGRP_IPV6_IFADDR, err);
 }
 
 static void inline ipv6_store_devconf(struct ipv6_devconf *cnf,

