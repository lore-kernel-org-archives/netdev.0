From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/7] bonding: move mode setting into separate function
Date: Fri, 18 Oct 2013 17:43:34 +0200
Message-ID: <1382111019-1102-3-git-send-email-jiri@resnulli.us>
References: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, stephen@networkplumber.org, vyasevic@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:42233 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756472Ab3JRPnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 11:43:47 -0400
Received: by mail-ee0-f48.google.com with SMTP id e50so989402eek.7
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 08:43:44 -0700 (PDT)
In-Reply-To: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/Makefile       |  2 +-
 drivers/net/bonding/bond_options.c | 55 ++++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   | 45 ++++++++-----------------------
 drivers/net/bonding/bonding.h      |  9 +++++--
 4 files changed, 74 insertions(+), 37 deletions(-)
 create mode 100644 drivers/net/bonding/bond_options.c

diff --git a/drivers/net/bonding/Makefile b/drivers/net/bonding/Makefile
index 09e8b2c..5a5d720 100644
--- a/drivers/net/bonding/Makefile
+++ b/drivers/net/bonding/Makefile
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_BONDING) += bonding.o
 
-bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_debugfs.o bond_netlink.o
+bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_debugfs.o bond_netlink.o bond_options.o
 
 proc-$(CONFIG_PROC_FS) += bond_procfs.o
 bonding-objs += $(proc-y)
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
new file mode 100644
index 0000000..294b766
--- /dev/null
+++ b/drivers/net/bonding/bond_options.c
@@ -0,0 +1,55 @@
+/*
+ * drivers/net/bond/bond_options.c - bonding options
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
+#include <linux/errno.h>
+#include <linux/if.h>
+#include "bonding.h"
+
+static bool bond_mode_is_valid(int mode)
+{
+	int i;
+
+	for (i = 0; bond_mode_tbl[i].modename; i++);
+
+	return mode >= 0 && mode < i;
+}
+
+int bond_option_mode_set(struct bonding *bond, int mode)
+{
+	if (!bond_mode_is_valid(mode)) {
+		pr_err("invalid mode value %d.\n", mode);
+		return -EINVAL;
+	}
+
+	if (bond->dev->flags & IFF_UP) {
+		pr_err("%s: unable to update mode because interface is up.\n",
+		       bond->dev->name);
+		return -EPERM;
+	}
+
+	if (bond_has_slaves(bond)) {
+		pr_err("%s: unable to update mode because bond has slaves.\n",
+			bond->dev->name);
+		return -EPERM;
+	}
+
+	if (BOND_MODE_IS_LB(mode) && bond->params.arp_interval) {
+		pr_err("%s: %s mode is incompatible with arp monitoring.\n",
+		       bond->dev->name, bond_mode_tbl[mode].modename);
+		return -EINVAL;
+	}
+
+	/* don't cache arp_validate between modes */
+	bond->params.arp_validate = BOND_ARP_VALIDATE_NONE;
+	bond->params.mode = mode;
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 03bed0c..c234cec 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -283,49 +283,26 @@ static ssize_t bonding_store_mode(struct device *d,
 				  struct device_attribute *attr,
 				  const char *buf, size_t count)
 {
-	int new_value, ret = count;
+	int new_value, ret;
 	struct bonding *bond = to_bond(d);
 
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	if (bond->dev->flags & IFF_UP) {
-		pr_err("unable to update mode of %s because interface is up.\n",
-		       bond->dev->name);
-		ret = -EPERM;
-		goto out;
-	}
-
-	if (bond_has_slaves(bond)) {
-		pr_err("unable to update mode of %s because it has slaves.\n",
-			bond->dev->name);
-		ret = -EPERM;
-		goto out;
-	}
-
 	new_value = bond_parse_parm(buf, bond_mode_tbl);
 	if (new_value < 0)  {
 		pr_err("%s: Ignoring invalid mode value %.*s.\n",
 		       bond->dev->name, (int)strlen(buf) - 1, buf);
-		ret = -EINVAL;
-		goto out;
+		return -EINVAL;
 	}
-	if ((new_value == BOND_MODE_ALB ||
-	     new_value == BOND_MODE_TLB) &&
-	    bond->params.arp_interval) {
-		pr_err("%s: %s mode is incompatible with arp monitoring.\n",
-		       bond->dev->name, bond_mode_tbl[new_value].modename);
-		ret = -EINVAL;
-		goto out;
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	ret = bond_option_mode_set(bond, new_value);
+	if (!ret) {
+		pr_info("%s: setting mode to %s (%d).\n",
+			bond->dev->name, bond_mode_tbl[new_value].modename,
+			new_value);
+		ret = count;
 	}
 
-	/* don't cache arp_validate between modes */
-	bond->params.arp_validate = BOND_ARP_VALIDATE_NONE;
-	bond->params.mode = new_value;
-	pr_info("%s: setting mode to %s (%d).\n",
-		bond->dev->name, bond_mode_tbl[new_value].modename,
-		new_value);
-out:
 	rtnl_unlock();
 	return ret;
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index a2a353b..7446849 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -58,6 +58,11 @@
 #define TX_QUEUE_OVERRIDE(mode)				\
 			(((mode) == BOND_MODE_ACTIVEBACKUP) ||	\
 			 ((mode) == BOND_MODE_ROUNDROBIN))
+
+#define BOND_MODE_IS_LB(mode)			\
+		(((mode) == BOND_MODE_TLB) ||	\
+		 ((mode) == BOND_MODE_ALB))
+
 /*
  * Less bad way to call ioctl from within the kernel; this needs to be
  * done some other way to get the call out of interrupt context.
@@ -259,8 +264,7 @@ static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
 
 static inline bool bond_is_lb(const struct bonding *bond)
 {
-	return (bond->params.mode == BOND_MODE_TLB ||
-		bond->params.mode == BOND_MODE_ALB);
+	return BOND_MODE_IS_LB(bond->params.mode);
 }
 
 static inline void bond_set_active_slave(struct slave *slave)
@@ -422,6 +426,7 @@ void bond_setup(struct net_device *bond_dev);
 unsigned int bond_get_num_tx_queues(void);
 int bond_netlink_init(void);
 void bond_netlink_fini(void);
+int bond_option_mode_set(struct bonding *bond, int mode);
 
 struct bond_net {
 	struct net *		net;	/* Associated network namespace */
-- 
1.8.3.1
