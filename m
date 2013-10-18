From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/7] bonding: push Netlink bits into separate file
Date: Fri, 18 Oct 2013 17:43:33 +0200
Message-ID: <1382111019-1102-2-git-send-email-jiri@resnulli.us>
References: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, stephen@networkplumber.org, vyasevic@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:54992 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756464Ab3JRPnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 11:43:43 -0400
Received: by mail-ea0-f175.google.com with SMTP id m14so2076911eaj.20
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 08:43:42 -0700 (PDT)
In-Reply-To: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/Makefile       |  2 +-
 drivers/net/bonding/bond_main.c    | 32 ++++------------------
 drivers/net/bonding/bond_netlink.c | 54 ++++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h      |  7 +++++
 4 files changed, 67 insertions(+), 28 deletions(-)
 create mode 100644 drivers/net/bonding/bond_netlink.c

diff --git a/drivers/net/bonding/Makefile b/drivers/net/bonding/Makefile
index 4c21bf6..09e8b2c 100644
--- a/drivers/net/bonding/Makefile
+++ b/drivers/net/bonding/Makefile
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_BONDING) += bonding.o
 
-bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_debugfs.o
+bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_debugfs.o bond_netlink.o
 
 proc-$(CONFIG_PROC_FS) += bond_procfs.o
 bonding-objs += $(proc-y)
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index dfb4f6d..a113e42 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3951,7 +3951,7 @@ static void bond_destructor(struct net_device *bond_dev)
 	free_netdev(bond_dev);
 }
 
-static void bond_setup(struct net_device *bond_dev)
+void bond_setup(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
@@ -4451,32 +4451,11 @@ static int bond_init(struct net_device *bond_dev)
 	return 0;
 }
 
-static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
-{
-	if (tb[IFLA_ADDRESS]) {
-		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
-			return -EINVAL;
-		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
-			return -EADDRNOTAVAIL;
-	}
-	return 0;
-}
-
-static unsigned int bond_get_num_tx_queues(void)
+unsigned int bond_get_num_tx_queues(void)
 {
 	return tx_queues;
 }
 
-static struct rtnl_link_ops bond_link_ops __read_mostly = {
-	.kind			= "bond",
-	.priv_size		= sizeof(struct bonding),
-	.setup			= bond_setup,
-	.validate		= bond_validate,
-	.get_num_tx_queues	= bond_get_num_tx_queues,
-	.get_num_rx_queues	= bond_get_num_tx_queues, /* Use the same number
-							     as for TX queues */
-};
-
 /* Create a new bond based on the specified name and bonding parameters.
  * If name is NULL, obtain a suitable "bond%d" name for us.
  * Caller must NOT hold rtnl_lock; we need to release it here before we
@@ -4563,7 +4542,7 @@ static int __init bonding_init(void)
 	if (res)
 		goto out;
 
-	res = rtnl_link_register(&bond_link_ops);
+	res = bond_netlink_init();
 	if (res)
 		goto err_link;
 
@@ -4579,7 +4558,7 @@ static int __init bonding_init(void)
 out:
 	return res;
 err:
-	rtnl_link_unregister(&bond_link_ops);
+	bond_netlink_fini();
 err_link:
 	unregister_pernet_subsys(&bond_net_ops);
 	goto out;
@@ -4592,7 +4571,7 @@ static void __exit bonding_exit(void)
 
 	bond_destroy_debugfs();
 
-	rtnl_link_unregister(&bond_link_ops);
+	bond_netlink_fini();
 	unregister_pernet_subsys(&bond_net_ops);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -4609,4 +4588,3 @@ MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 MODULE_DESCRIPTION(DRV_DESCRIPTION ", v" DRV_VERSION);
 MODULE_AUTHOR("Thomas Davis, tadavis@lbl.gov and many others");
-MODULE_ALIAS_RTNL_LINK("bond");
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
new file mode 100644
index 0000000..3e5c5f8
--- /dev/null
+++ b/drivers/net/bonding/bond_netlink.c
@@ -0,0 +1,54 @@
+/*
+ * drivers/net/bond/bond_netlink.c - Netlink interface for bonding
+ * Copyright (c) 2013 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/if_link.h>
+#include <linux/if_ether.h>
+#include <net/netlink.h>
+#include <net/rtnetlink.h>
+#include "bonding.h"
+
+static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	if (tb[IFLA_ADDRESS]) {
+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
+			return -EINVAL;
+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+			return -EADDRNOTAVAIL;
+	}
+	return 0;
+}
+
+struct rtnl_link_ops bond_link_ops __read_mostly = {
+	.kind			= "bond",
+	.priv_size		= sizeof(struct bonding),
+	.setup			= bond_setup,
+	.validate		= bond_validate,
+	.get_num_tx_queues	= bond_get_num_tx_queues,
+	.get_num_rx_queues	= bond_get_num_tx_queues, /* Use the same number
+							     as for TX queues */
+};
+
+int __init bond_netlink_init(void)
+{
+	return rtnl_link_register(&bond_link_ops);
+}
+
+void __exit bond_netlink_fini(void)
+{
+	rtnl_link_unregister(&bond_link_ops);
+}
+
+MODULE_ALIAS_RTNL_LINK("bond");
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index bb5c731..a2a353b 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -418,6 +418,10 @@ void bond_debug_register(struct bonding *bond);
 void bond_debug_unregister(struct bonding *bond);
 void bond_debug_reregister(struct bonding *bond);
 const char *bond_mode_name(int mode);
+void bond_setup(struct net_device *bond_dev);
+unsigned int bond_get_num_tx_queues(void);
+int bond_netlink_init(void);
+void bond_netlink_fini(void);
 
 struct bond_net {
 	struct net *		net;	/* Associated network namespace */
@@ -505,4 +509,7 @@ extern const struct bond_parm_tbl fail_over_mac_tbl[];
 extern const struct bond_parm_tbl pri_reselect_tbl[];
 extern struct bond_parm_tbl ad_select_tbl[];
 
+/* exported from bond_netlink.c */
+extern struct rtnl_link_ops bond_link_ops;
+
 #endif /* _LINUX_BONDING_H */
-- 
1.8.3.1
