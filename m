From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 1/3] bonding: add the debugfs facility to the bonding driver
Date: Fri, 10 Dec 2010 16:21:45 -0800
Message-ID: <29210.1292026905@death>
References: <4CF89A00.8030902@jp.fujitsu.com> <4CF89A6E.4090303@jp.fujitsu.com> <4D017F99.2040706@jp.fujitsu.com>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:41740 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757234Ab0LKAVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 19:21:49 -0500
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oBB03jj9021277
	for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 19:03:45 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 22FB64DE803B
	for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 19:19:51 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBB0Lmmj157364
	for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 19:21:48 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBB0LlIZ017151
	for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 19:21:47 -0500
In-reply-to: <4D017F99.2040706@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taku Izumi <izumi.taku@jp.fujitsu.com> wrote:

>
>This patch provides the debugfs facility to the bonding driver.
>The "bonding" directory is created in the debugfs root and directories of
>each bonding interface (like bond0, bond1...) are created in that.
>
> # mount -t debugfs none /sys/kernel/debug
>
> # ls /sys/kernel/debug/bonding
> bond0  bond1
>
>Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>

	Tested replacement patch 1 with original patches 2 and 3.  Works
as advertised, no pesky crashes.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J


>---
> drivers/net/bonding/Makefile       |    2
> drivers/net/bonding/bond_debugfs.c |   96 +++++++++++++++++++++++++++++++++++++
> drivers/net/bonding/bond_main.c    |   10 +++
> drivers/net/bonding/bonding.h      |    9 +++
> 4 files changed, 115 insertions(+), 2 deletions(-)
>
>Index: net-next/drivers/net/bonding/bond_main.c
>===================================================================
>--- net-next.orig/drivers/net/bonding/bond_main.c
>+++ net-next/drivers/net/bonding/bond_main.c
>@@ -3507,6 +3507,8 @@ static int bond_event_changename(struct
> 	bond_remove_proc_entry(bond);
> 	bond_create_proc_entry(bond);
>
>+	bond_debug_reregister(bond);
>+
> 	return NOTIFY_DONE;
> }
>
>@@ -4789,6 +4791,8 @@ static void bond_uninit(struct net_devic
>
> 	bond_remove_proc_entry(bond);
>
>+	bond_debug_unregister(bond);
>+
> 	__hw_addr_flush(&bond->mc_list);
>
> 	list_for_each_entry_safe(vlan, tmp, &bond->vlan_list, vlan_list) {
>@@ -5191,6 +5195,8 @@ static int bond_init(struct net_device *
>
> 	bond_prepare_sysfs_group(bond);
>
>+	bond_debug_register(bond);
>+
> 	__hw_addr_init(&bond->mc_list);
> 	return 0;
> }
>@@ -5312,6 +5318,8 @@ static int __init bonding_init(void)
> 	if (res)
> 		goto err_link;
>
>+	bond_create_debugfs();
>+
> 	for (i = 0; i < max_bonds; i++) {
> 		res = bond_create(&init_net, NULL);
> 		if (res)
>@@ -5322,7 +5330,6 @@ static int __init bonding_init(void)
> 	if (res)
> 		goto err;
>
>-
> 	register_netdevice_notifier(&bond_netdev_notifier);
> 	register_inetaddr_notifier(&bond_inetaddr_notifier);
> 	bond_register_ipv6_notifier();
>@@ -5346,6 +5353,7 @@ static void __exit bonding_exit(void)
> 	bond_unregister_ipv6_notifier();
>
> 	bond_destroy_sysfs();
>+	bond_destroy_debugfs();
>
> 	rtnl_link_unregister(&bond_link_ops);
> 	unregister_pernet_subsys(&bond_net_ops);
>Index: net-next/drivers/net/bonding/Makefile
>===================================================================
>--- net-next.orig/drivers/net/bonding/Makefile
>+++ net-next/drivers/net/bonding/Makefile
>@@ -4,7 +4,7 @@
>
> obj-$(CONFIG_BONDING) += bonding.o
>
>-bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o
>+bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_debugfs.o
>
> ipv6-$(subst m,y,$(CONFIG_IPV6)) += bond_ipv6.o
> bonding-objs += $(ipv6-y)
>Index: net-next/drivers/net/bonding/bond_debugfs.c
>===================================================================
>--- /dev/null
>+++ net-next/drivers/net/bonding/bond_debugfs.c
>@@ -0,0 +1,96 @@
>+#include <linux/kernel.h>
>+#include <linux/module.h>
>+#include <linux/device.h>
>+#include <linux/netdevice.h>
>+
>+#include "bonding.h"
>+
>+#ifdef CONFIG_DEBUG_FS
>+
>+#include <linux/debugfs.h>
>+#include <linux/seq_file.h>
>+
>+static struct dentry *bonding_debug_root;
>+
>+void bond_debug_register(struct bonding *bond)
>+{
>+	if (!bonding_debug_root)
>+		return;
>+
>+	bond->debug_dir =
>+		debugfs_create_dir(bond->dev->name, bonding_debug_root);
>+
>+	if (!bond->debug_dir) {
>+		pr_warning("%s: Warning: failed to register to debugfs\n",
>+			bond->dev->name);
>+		return;
>+	}
>+}
>+
>+void bond_debug_unregister(struct bonding *bond)
>+{
>+	if (!bonding_debug_root)
>+		return;
>+
>+	debugfs_remove_recursive(bond->debug_dir);
>+}
>+
>+void bond_debug_reregister(struct bonding *bond)
>+{
>+	struct dentry *d;
>+
>+	if (!bonding_debug_root)
>+		return;
>+
>+	d = debugfs_rename(bonding_debug_root, bond->debug_dir,
>+			   bonding_debug_root, bond->dev->name);
>+	if (d) {
>+		bond->debug_dir = d;
>+	} else {
>+		pr_warning("%s: Warning: failed to reregister, "
>+				"so just unregister old one\n",
>+				bond->dev->name);
>+		bond_debug_unregister(bond);
>+	}
>+}
>+
>+void bond_create_debugfs(void)
>+{
>+	bonding_debug_root = debugfs_create_dir("bonding", NULL);
>+
>+	if (!bonding_debug_root) {
>+		pr_warning("Warning: Cannot create bonding directory"
>+				" in debugfs\n");
>+	}
>+}
>+
>+void bond_destroy_debugfs(void)
>+{
>+	debugfs_remove_recursive(bonding_debug_root);
>+	bonding_debug_root = NULL;
>+}
>+
>+
>+#else /* !CONFIG_DEBUG_FS */
>+
>+void bond_debug_register(struct bonding *bond)
>+{
>+}
>+
>+void bond_debug_unregister(struct bonding *bond)
>+{
>+}
>+
>+void bond_debug_reregister(struct bonding *bond)
>+{
>+}
>+
>+void bond_create_debugfs(void)
>+{
>+}
>+
>+void bond_destroy_debugfs(void)
>+{
>+}
>+
>+#endif /* CONFIG_DEBUG_FS */
>Index: net-next/drivers/net/bonding/bonding.h
>===================================================================
>--- net-next.orig/drivers/net/bonding/bonding.h
>+++ net-next/drivers/net/bonding/bonding.h
>@@ -259,6 +259,10 @@ struct bonding {
> #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> 	struct   in6_addr master_ipv6;
> #endif
>+#ifdef CONFIG_DEBUG_FS
>+	/* debugging suport via debugfs */
>+	struct	 dentry *debug_dir;
>+#endif /* CONFIG_DEBUG_FS */
> };
>
> /**
>@@ -380,6 +384,11 @@ void bond_select_active_slave(struct bon
> void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
> void bond_register_arp(struct bonding *);
> void bond_unregister_arp(struct bonding *);
>+void bond_create_debugfs(void);
>+void bond_destroy_debugfs(void);
>+void bond_debug_register(struct bonding *bond);
>+void bond_debug_unregister(struct bonding *bond);
>+void bond_debug_reregister(struct bonding *bond);
>
> struct bond_net {
> 	struct net *		net;	/* Associated network namespace */
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
