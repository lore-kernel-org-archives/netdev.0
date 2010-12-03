From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 1/2] bonding: add the debugfs facility to the bonding driver
Date: Fri, 03 Dec 2010 11:54:20 +0900
Message-ID: <4CF85BDC.5080806@jp.fujitsu.com>
References: <4CF85B43.2030407@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:51094 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758408Ab0LCCyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 21:54:43 -0500
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB32sfmd015740
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Fri, 3 Dec 2010 11:54:41 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 97B8945DE5C
	for <netdev@vger.kernel.org>; Fri,  3 Dec 2010 11:54:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7537F45DE55
	for <netdev@vger.kernel.org>; Fri,  3 Dec 2010 11:54:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F01BBE38004
	for <netdev@vger.kernel.org>; Fri,  3 Dec 2010 11:54:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8246E1DB8051
	for <netdev@vger.kernel.org>; Fri,  3 Dec 2010 11:54:39 +0900 (JST)
In-Reply-To: <4CF85B43.2030407@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch provides the debugfs facility to the bonding driver.
The "bonding" directory is created in the debugfs root and directories of
each bonding interface (like bond0, bond1...) are created in that.

 # mount -t debugfs none /sys/kernel/debug

 # ls /sys/kernel/debug/bonding
 bond0  bond1

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>

---
 drivers/net/bonding/Makefile       |    2
 drivers/net/bonding/bond_debugfs.c |   90 +++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_main.c    |   10 +++-
 drivers/net/bonding/bonding.h      |    7 ++
 4 files changed, 107 insertions(+), 2 deletions(-)

Index: net-next/drivers/net/bonding/bond_main.c
===================================================================
--- net-next.orig/drivers/net/bonding/bond_main.c
+++ net-next/drivers/net/bonding/bond_main.c
@@ -3507,6 +3507,8 @@ static int bond_event_changename(struct
 	bond_remove_proc_entry(bond);
 	bond_create_proc_entry(bond);

+	bond_debug_reregister(bond);
+
 	return NOTIFY_DONE;
 }

@@ -4789,6 +4791,8 @@ static void bond_uninit(struct net_devic

 	bond_remove_proc_entry(bond);

+	bond_debug_unregister(bond);
+
 	__hw_addr_flush(&bond->mc_list);

 	list_for_each_entry_safe(vlan, tmp, &bond->vlan_list, vlan_list) {
@@ -5191,6 +5195,8 @@ static int bond_init(struct net_device *

 	bond_prepare_sysfs_group(bond);

+	bond_debug_register(bond);
+
 	__hw_addr_init(&bond->mc_list);
 	return 0;
 }
@@ -5312,6 +5318,8 @@ static int __init bonding_init(void)
 	if (res)
 		goto err_link;

+	bond_create_debugfs();
+
 	for (i = 0; i < max_bonds; i++) {
 		res = bond_create(&init_net, NULL);
 		if (res)
@@ -5322,7 +5330,6 @@ static int __init bonding_init(void)
 	if (res)
 		goto err;

-
 	register_netdevice_notifier(&bond_netdev_notifier);
 	register_inetaddr_notifier(&bond_inetaddr_notifier);
 	bond_register_ipv6_notifier();
@@ -5346,6 +5353,7 @@ static void __exit bonding_exit(void)
 	bond_unregister_ipv6_notifier();

 	bond_destroy_sysfs();
+	bond_destroy_debugfs();

 	rtnl_link_unregister(&bond_link_ops);
 	unregister_pernet_subsys(&bond_net_ops);
Index: net-next/drivers/net/bonding/Makefile
===================================================================
--- net-next.orig/drivers/net/bonding/Makefile
+++ net-next/drivers/net/bonding/Makefile
@@ -4,7 +4,7 @@

 obj-$(CONFIG_BONDING) += bonding.o

-bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o
+bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_debugfs.o

 ipv6-$(subst m,y,$(CONFIG_IPV6)) += bond_ipv6.o
 bonding-objs += $(ipv6-y)
Index: net-next/drivers/net/bonding/bond_debugfs.c
===================================================================
--- /dev/null
+++ net-next/drivers/net/bonding/bond_debugfs.c
@@ -0,0 +1,90 @@
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/netdevice.h>
+
+#include "bonding.h"
+
+#ifdef CONFIG_DEBUG_FS
+
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
+
+static struct dentry *bonding_debug_root;
+
+void bond_debug_register(struct bonding *bond)
+{
+	if (!bonding_debug_root)
+		return;
+
+	bond->debug_dir =
+		debugfs_create_dir(bond->dev->name, bonding_debug_root);
+
+	if (!bond->debug_dir) {
+		pr_warning("%s: Warning: failed to regist to debugfs\n",
+			bond->dev->name);
+		return;
+	}
+}
+
+void bond_debug_unregister(struct bonding *bond)
+{
+	debugfs_remove_recursive(bond->debug_dir);
+}
+
+void bond_debug_reregister(struct bonding *bond)
+{
+	struct dentry *d;
+
+	if (!bonding_debug_root)
+		return;
+
+	d = debugfs_rename(bonding_debug_root, bond->debug_dir,
+			   bonding_debug_root, bond->dev->name);
+	if (d) {
+		bond->debug_dir = d;
+	} else {
+		pr_warning("Warning: failed to re-regist, so unregist this\n");
+		bond_debug_unregister(bond);
+	}
+}
+
+void bond_create_debugfs(void)
+{
+	bonding_debug_root = debugfs_create_dir("bonding", NULL);
+
+	if (!bonding_debug_root) {
+		pr_warning("Warning: Cannot create bonding directory"
+				" in debugfs\n");
+	}
+}
+
+void bond_destroy_debugfs(void)
+{
+	debugfs_remove_recursive(bonding_debug_root);
+}
+
+
+#else /* !CONFIG_DEBUG_FS */
+
+void bond_debug_register(struct bonding *bond)
+{
+}
+
+void bond_debug_unregister(struct bonding *bond)
+{
+}
+
+void bond_debug_reregister(struct bonding *bond)
+{
+}
+
+void bond_create_debugfs(void)
+{
+}
+
+void bond_destroy_debugfs(void)
+{
+}
+
+#endif /* CONFIG_DEBUG_FS */
Index: net-next/drivers/net/bonding/bonding.h
===================================================================
--- net-next.orig/drivers/net/bonding/bonding.h
+++ net-next/drivers/net/bonding/bonding.h
@@ -259,6 +259,8 @@ struct bonding {
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct   in6_addr master_ipv6;
 #endif
+	/* debugging suport via debugfs */
+	struct	 dentry *debug_dir;
 };

 /**
@@ -380,6 +382,11 @@ void bond_select_active_slave(struct bon
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_register_arp(struct bonding *);
 void bond_unregister_arp(struct bonding *);
+void bond_create_debugfs(void);
+void bond_destroy_debugfs(void);
+void bond_debug_register(struct bonding *bond);
+void bond_debug_unregister(struct bonding *bond);
+void bond_debug_reregister(struct bonding *bond);

 struct bond_net {
 	struct net *		net;	/* Associated network namespace */

