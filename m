From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 11/12] [BRIDGE]: Use rtnl registration interface
Date: Thu, 22 Mar 2007 14:00:06 +0100
Message-ID: <20070322130058.635523370@lsx.localdomain>
References: <20070322125955.055083236@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53668 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752145AbXCVNCV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 09:02:21 -0400
Content-Disposition: inline; filename=rtnl_reg_bridge_convert
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/bridge/br.c
===================================================================
--- net-2.6.22.orig/net/bridge/br.c	2007-03-22 13:23:11.000000000 +0100
+++ net-2.6.22/net/bridge/br.c	2007-03-22 13:24:03.000000000 +0100
@@ -47,7 +47,10 @@ static int __init br_init(void)
 	if (err)
 		goto err_out2;
 
-	br_netlink_init();
+	err = br_netlink_init();
+	if (err)
+		goto err_out3;
+
 	brioctl_set(br_ioctl_deviceless_stub);
 	br_handle_frame_hook = br_handle_frame;
 
@@ -55,7 +58,8 @@ static int __init br_init(void)
 	br_fdb_put_hook = br_fdb_put;
 
 	return 0;
-
+err_out3:
+	unregister_netdevice_notifier(&br_device_notifier);
 err_out2:
 	br_netfilter_fini();
 err_out1:
Index: net-2.6.22/net/bridge/br_netlink.c
===================================================================
--- net-2.6.22.orig/net/bridge/br_netlink.c	2007-03-22 13:23:11.000000000 +0100
+++ net-2.6.22/net/bridge/br_netlink.c	2007-03-22 13:24:03.000000000 +0100
@@ -11,8 +11,7 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/rtnetlink.h>
-#include <net/netlink.h>
+#include <net/rtnetlink.h>
 #include "br_private.h"
 
 static inline size_t br_nlmsg_size(void)
@@ -179,18 +178,19 @@ static int br_rtm_setlink(struct sk_buff
 }
 
 
-static struct rtnetlink_link bridge_rtnetlink_table[RTM_NR_MSGTYPES] = {
-	[RTM_GETLINK - RTM_BASE] = { .dumpit	= br_dump_ifinfo, },
-	[RTM_SETLINK - RTM_BASE] = { .doit      = br_rtm_setlink, },
-};
-
-void __init br_netlink_init(void)
+int __init br_netlink_init(void)
 {
-	rtnetlink_links[PF_BRIDGE] = bridge_rtnetlink_table;
+	if (__rtnl_register(PF_BRIDGE, RTM_GETLINK, NULL, br_dump_ifinfo))
+		return -ENOBUFS;
+
+	/* Only the first call to __rtnl_register can fail */
+	__rtnl_register(PF_BRIDGE, RTM_SETLINK, br_rtm_setlink, NULL);
+
+	return 0;
 }
 
 void __exit br_netlink_fini(void)
 {
-	rtnetlink_links[PF_BRIDGE] = NULL;
+	rtnl_unregister_all(PF_BRIDGE);
 }
 
Index: net-2.6.22/net/bridge/br_private.h
===================================================================
--- net-2.6.22.orig/net/bridge/br_private.h	2007-03-22 13:23:11.000000000 +0100
+++ net-2.6.22/net/bridge/br_private.h	2007-03-22 13:24:03.000000000 +0100
@@ -235,7 +235,7 @@ extern void (*br_fdb_put_hook)(struct ne
 
 
 /* br_netlink.c */
-extern void br_netlink_init(void);
+extern int br_netlink_init(void);
 extern void br_netlink_fini(void);
 extern void br_ifinfo_notify(int event, struct net_bridge_port *port);
 

--

