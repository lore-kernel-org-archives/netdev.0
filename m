From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 08/16] [IPv4] route: Convert route notifications to use rtnl_notify()
Date: Mon, 14 Aug 2006 00:00:08 +0200
Message-ID: <20060814214341.521300269@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:21710 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964985AbWHNVo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:44:57 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=rtnl_convert_ip4_route
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/ipv4/fib_semantics.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/fib_semantics.c
+++ net-2.6.19.git/net/ipv4/fib_semantics.c
@@ -33,7 +33,6 @@
 #include <linux/if_arp.h>
 #include <linux/proc_fs.h>
 #include <linux/skbuff.h>
-#include <linux/netlink.h>
 #include <linux/init.h>
 
 #include <net/arp.h>
@@ -44,6 +43,7 @@
 #include <net/sock.h>
 #include <net/ip_fib.h>
 #include <net/ip_mp_alg.h>
+#include <net/netlink.h>
 
 #include "fib_lookup.h"
 
@@ -278,25 +278,25 @@ void rtmsg_fib(int event, u32 key, struc
 {
 	struct sk_buff *skb;
 	u32 pid = req ? req->pid : n->nlmsg_pid;
-	int size = NLMSG_SPACE(sizeof(struct rtmsg)+256);
+	int payload = sizeof(struct rtmsg) + 256;
+	int err = -ENOBUFS;
 
-	skb = alloc_skb(size, GFP_KERNEL);
-	if (!skb)
-		return;
-
-	if (fib_dump_info(skb, pid, n->nlmsg_seq, event, tb_id,
-			  fa->fa_type, fa->fa_scope, &key, z,
-			  fa->fa_tos,
-			  fa->fa_info, 0) < 0) {
+	skb = nlmsg_new(nlmsg_total_size(payload), GFP_KERNEL);
+	if (skb == NULL)
+		goto errout;
+
+	err = fib_dump_info(skb, pid, n->nlmsg_seq, event, tb_id,
+			    fa->fa_type, fa->fa_scope, &key, z, fa->fa_tos,
+			    fa->fa_info, 0);
+	if (err < 0) {
 		kfree_skb(skb);
-		return;
+		goto errout;
 	}
-	NETLINK_CB(skb).dst_group = RTNLGRP_IPV4_ROUTE;
-	if (n->nlmsg_flags&NLM_F_ECHO)
-		atomic_inc(&skb->users);
-	netlink_broadcast(rtnl, skb, pid, RTNLGRP_IPV4_ROUTE, GFP_KERNEL);
-	if (n->nlmsg_flags&NLM_F_ECHO)
-		netlink_unicast(rtnl, skb, pid, MSG_DONTWAIT);
+
+	err = rtnl_notify(skb, pid, RTNLGRP_IPV4_ROUTE, n, GFP_KERNEL);
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(RTNLGRP_IPV4_ROUTE, err);
 }
 
 /* Return the first fib alias matching TOS with

