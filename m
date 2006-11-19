From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/3] [DECnet] address: Calculate accurate message size for netlink notifications
Date: Sun, 19 Nov 2006 23:23:27 +0100
Message-ID: <20061119222420.115227575@lsx.localdomain>
References: <20061119222326.208529546@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:5047 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S933465AbWKSWZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Nov 2006 17:25:29 -0500
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_dn_msgsize
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/net/decnet/dn_dev.c
===================================================================
--- net-2.6.20.orig/net/decnet/dn_dev.c	2006-11-19 18:31:06.000000000 +0100
+++ net-2.6.20/net/decnet/dn_dev.c	2006-11-19 18:33:43.000000000 +0100
@@ -38,7 +38,6 @@
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/skbuff.h>
-#include <linux/rtnetlink.h>
 #include <linux/sysctl.h>
 #include <linux/notifier.h>
 #include <asm/uaccess.h>
@@ -47,6 +46,7 @@
 #include <net/dst.h>
 #include <net/flow.h>
 #include <net/fib_rules.h>
+#include <net/netlink.h>
 #include <net/dn.h>
 #include <net/dn_dev.h>
 #include <net/dn_route.h>
@@ -713,6 +713,14 @@
 	return rv;
 }
 
+static inline size_t dn_ifaddr_nlmsg_size(void)
+{
+	return NLMSG_ALIGN(sizeof(struct ifaddrmsg))
+	       + nla_total_size(IFNAMSIZ) /* IFA_LABEL */
+	       + nla_total_size(2) /* IFA_ADDRESS */
+	       + nla_total_size(2); /* IFA_LOCAL */
+}
+
 static int dn_dev_fill_ifaddr(struct sk_buff *skb, struct dn_ifaddr *ifa,
 				u32 pid, u32 seq, int event, unsigned int flags)
 {
@@ -746,18 +754,15 @@
 static void rtmsg_ifa(int event, struct dn_ifaddr *ifa)
 {
 	struct sk_buff *skb;
-	int payload = sizeof(struct ifaddrmsg) + 128;
 	int err = -ENOBUFS;
 
-	skb = alloc_skb(nlmsg_total_size(payload), GFP_KERNEL);
+	skb = alloc_skb(dn_ifaddr_nlmsg_size(), GFP_KERNEL);
 	if (skb == NULL)
 		goto errout;
 
 	err = dn_dev_fill_ifaddr(skb, ifa, 0, 0, event, 0);
-	if (err < 0) {
-		kfree_skb(skb);
-		goto errout;
-	}
+	/* failure implies BUG in dn_ifaddr_nlmsg_size() */
+	BUG_ON(err < 0);
 
 	err = rtnl_notify(skb, 0, RTNLGRP_DECnet_IFADDR, NULL, GFP_KERNEL);
 errout:

--

