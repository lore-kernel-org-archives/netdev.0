From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 12/16] [IPv6] prefix: Convert prefix notifications to use rtnl_notify()
Date: Mon, 14 Aug 2006 00:00:12 +0200
Message-ID: <20060814214342.808449542@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:24526 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964988AbWHNVpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:45:17 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=rtnl_convert_ip6_prefix
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes a wrong use of current->pid as netlink pid.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/ipv6/addrconf.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/addrconf.c
+++ net-2.6.19.git/net/ipv6/addrconf.c
@@ -3506,20 +3506,23 @@ static void inet6_prefix_notify(int even
 			 struct prefix_info *pinfo)
 {
 	struct sk_buff *skb;
-	int size = NLMSG_SPACE(sizeof(struct prefixmsg) + INET6_PREFIX_RTA_SPACE);
+	int payload = sizeof(struct prefixmsg) + INET6_PREFIX_RTA_SPACE;
+	int err = -ENOBUFS;
 
-	skb = alloc_skb(size, GFP_ATOMIC);
-	if (!skb) {
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_PREFIX, ENOBUFS);
-		return;
-	}
-	if (inet6_fill_prefix(skb, idev, pinfo, current->pid, 0, event, 0) < 0) {
+	skb = nlmsg_new(nlmsg_total_size(payload), GFP_ATOMIC);
+	if (skb == NULL)
+		goto errout;
+
+	err = inet6_fill_prefix(skb, idev, pinfo, 0, 0, event, 0);
+	if (err < 0) {
 		kfree_skb(skb);
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV6_PREFIX, EINVAL);
-		return;
+		goto errout;
 	}
-	NETLINK_CB(skb).dst_group = RTNLGRP_IPV6_PREFIX;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV6_PREFIX, GFP_ATOMIC);
+
+	err = rtnl_notify(skb, 0, RTNLGRP_IPV6_PREFIX, NULL, GFP_ATOMIC);
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(RTNLGRP_IPV6_PREFIX, err);
 }
 
 static struct rtnetlink_link inet6_rtnetlink_table[RTM_NR_MSGTYPES] = {

