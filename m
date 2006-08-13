From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 06/16] [DECNET]: Convert DECnet notifications to use rtnl_notify()
Date: Mon, 14 Aug 2006 00:00:06 +0200
Message-ID: <20060814214340.760951294@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:19150 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964983AbWHNVoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:44:46 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=rtnl_convert_decnet
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/decnet/dn_dev.c
===================================================================
--- net-2.6.19.git.orig/net/decnet/dn_dev.c
+++ net-2.6.19.git/net/decnet/dn_dev.c
@@ -746,20 +746,23 @@ rtattr_failure:
 static void rtmsg_ifa(int event, struct dn_ifaddr *ifa)
 {
 	struct sk_buff *skb;
-	int size = NLMSG_SPACE(sizeof(struct ifaddrmsg)+128);
+	int payload = sizeof(struct ifaddrmsg) + 128;
+	int err = -ENOBUFS;
 
-	skb = alloc_skb(size, GFP_KERNEL);
-	if (!skb) {
-		netlink_set_err(rtnl, 0, RTNLGRP_DECnet_IFADDR, ENOBUFS);
-		return;
-	}
-	if (dn_dev_fill_ifaddr(skb, ifa, 0, 0, event, 0) < 0) {
+	skb = alloc_skb(nlmsg_total_size(payload), GFP_KERNEL);
+	if (skb == NULL)
+		goto errout;
+
+	err = dn_dev_fill_ifaddr(skb, ifa, 0, 0, event, 0);
+	if (err < 0) {
 		kfree_skb(skb);
-		netlink_set_err(rtnl, 0, RTNLGRP_DECnet_IFADDR, EINVAL);
-		return;
+		goto errout;
 	}
-	NETLINK_CB(skb).dst_group = RTNLGRP_DECnet_IFADDR;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_DECnet_IFADDR, GFP_KERNEL);
+
+	err = rtnl_notify(skb, 0, RTNLGRP_DECnet_IFADDR, NULL, GFP_KERNEL);
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(RTNLGRP_DECnet_IFADDR, err);
 }
 
 static int dn_dev_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
Index: net-2.6.19.git/net/decnet/dn_table.c
===================================================================
--- net-2.6.19.git.orig/net/decnet/dn_table.c
+++ net-2.6.19.git/net/decnet/dn_table.c
@@ -333,24 +333,24 @@ static void dn_rtmsg_fib(int event, stru
 {
         struct sk_buff *skb;
         u32 pid = req ? req->pid : 0;
-        int size = NLMSG_SPACE(sizeof(struct rtmsg) + 256);
+	int err = -ENOBUFS;
 
-        skb = alloc_skb(size, GFP_KERNEL);
-        if (!skb)
-                return;
-
-        if (dn_fib_dump_info(skb, pid, nlh->nlmsg_seq, event, tb_id, 
-                                f->fn_type, f->fn_scope, &f->fn_key, z, 
-                                DN_FIB_INFO(f), 0) < 0) {
+        skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+        if (skb == NULL)
+		goto errout;
+
+        err = dn_fib_dump_info(skb, pid, nlh->nlmsg_seq, event, tb_id,
+			       f->fn_type, f->fn_scope, &f->fn_key, z,
+			       DN_FIB_INFO(f), 0);
+	if (err < 0) {
                 kfree_skb(skb);
-                return;
+		goto errout;
         }
-        NETLINK_CB(skb).dst_group = RTNLGRP_DECnet_ROUTE;
-        if (nlh->nlmsg_flags & NLM_F_ECHO)
-                atomic_inc(&skb->users);
-        netlink_broadcast(rtnl, skb, pid, RTNLGRP_DECnet_ROUTE, GFP_KERNEL);
-        if (nlh->nlmsg_flags & NLM_F_ECHO)
-                netlink_unicast(rtnl, skb, pid, MSG_DONTWAIT);
+
+	err = rtnl_notify(skb, pid, RTNLGRP_DECnet_ROUTE, nlh, GFP_KERNEL);
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(RTNLGRP_DECnet_ROUTE, err);
 }
 
 static __inline__ int dn_hash_dump_bucket(struct sk_buff *skb, 

