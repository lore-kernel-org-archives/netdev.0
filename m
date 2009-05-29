From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.31 08/10] wimax: Add netlink interface to get device state
Date: Thu, 28 May 2009 18:12:12 -0700
Message-ID: <7f0333eb2f98bbfece4fbfe21076d0a3e49f0bb0.1243559425.git.inaky@linux.intel.com>
References: <cover.1243559425.git.inaky@linux.intel.com>
Cc: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 076-076-148-181.pdx.net ([76.76.148.181]:45064 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752104AbZE2ELm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 00:11:42 -0400
In-Reply-To: <cover.1243559425.git.inaky@linux.intel.com>
In-Reply-To: <cover.1243559425.git.inaky@linux.intel.com>
References: <cover.1243559425.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

wimax connection manager / daemon has to know what is current
state of the device. Previously it was only possible to get
notification whet state has changed.

Note:

 By mistake, the new generic netlink's number for
 WIMAX_GNL_OP_STATE_GET was declared inserting into the existing list
 of API calls, not appending; thus, it'd break existing API.

 Fixed by Inaky Perez-Gonzalez <inaky@linux.intel.com> by moving to
 the tail, where we add to the interface, not modify the interface.

 Thanks to Stephen Hemminger <shemminger@vyatta.com> for catching this.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
---
 include/linux/wimax.h    |    5 +++
 net/wimax/Makefile       |    1 +
 net/wimax/debug-levels.h |    1 +
 net/wimax/debugfs.c      |    1 +
 net/wimax/op-state-get.c |   86 ++++++++++++++++++++++++++++++++++++++++++++++
 net/wimax/stack.c        |    5 ++-
 6 files changed, 98 insertions(+), 1 deletions(-)
 create mode 100644 net/wimax/op-state-get.c

diff --git a/include/linux/wimax.h b/include/linux/wimax.h
index c89de7f..2f7a6b7 100644
--- a/include/linux/wimax.h
+++ b/include/linux/wimax.h
@@ -78,6 +78,7 @@ enum {
 	WIMAX_GNL_OP_RFKILL,	/* Run wimax_rfkill() */
 	WIMAX_GNL_OP_RESET,	/* Run wimax_rfkill() */
 	WIMAX_GNL_RE_STATE_CHANGE,	/* Report: status change */
+	WIMAX_GNL_OP_STATE_GET,		/* Request for current state */
 };
 
 
@@ -113,6 +114,10 @@ enum {
 	WIMAX_GNL_RESET_IFIDX = 1,
 };
 
+/* Atributes for wimax_state_get() */
+enum {
+	WIMAX_GNL_STGET_IFIDX = 1,
+};
 
 /*
  * Attributes for the Report State Change
diff --git a/net/wimax/Makefile b/net/wimax/Makefile
index 5b80b94..8f1510d 100644
--- a/net/wimax/Makefile
+++ b/net/wimax/Makefile
@@ -6,6 +6,7 @@ wimax-y :=		\
 	op-msg.o	\
 	op-reset.o	\
 	op-rfkill.o	\
+	op-state-get.o	\
 	stack.o
 
 wimax-$(CONFIG_DEBUG_FS) += debugfs.o
diff --git a/net/wimax/debug-levels.h b/net/wimax/debug-levels.h
index 1c29123..0975adb 100644
--- a/net/wimax/debug-levels.h
+++ b/net/wimax/debug-levels.h
@@ -36,6 +36,7 @@ enum d_module {
 	D_SUBMODULE_DECLARE(op_msg),
 	D_SUBMODULE_DECLARE(op_reset),
 	D_SUBMODULE_DECLARE(op_rfkill),
+	D_SUBMODULE_DECLARE(op_state_get),
 	D_SUBMODULE_DECLARE(stack),
 };
 
diff --git a/net/wimax/debugfs.c b/net/wimax/debugfs.c
index 94d216a..6c9bedb 100644
--- a/net/wimax/debugfs.c
+++ b/net/wimax/debugfs.c
@@ -61,6 +61,7 @@ int wimax_debugfs_add(struct wimax_dev *wimax_dev)
 	__debugfs_register("wimax_dl_", op_msg, dentry);
 	__debugfs_register("wimax_dl_", op_reset, dentry);
 	__debugfs_register("wimax_dl_", op_rfkill, dentry);
+	__debugfs_register("wimax_dl_", op_state_get, dentry);
 	__debugfs_register("wimax_dl_", stack, dentry);
 	result = 0;
 out:
diff --git a/net/wimax/op-state-get.c b/net/wimax/op-state-get.c
new file mode 100644
index 0000000..a76b8fc
--- /dev/null
+++ b/net/wimax/op-state-get.c
@@ -0,0 +1,86 @@
+/*
+ * Linux WiMAX
+ * Implement and export a method for getting a WiMAX device current state
+ *
+ * Copyright (C) 2009 Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
+ *
+ * Based on previous WiMAX core work by:
+ *  Copyright (C) 2008 Intel Corporation <linux-wimax@intel.com>
+ *  Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version
+ * 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA.
+ */
+
+#include <net/wimax.h>
+#include <net/genetlink.h>
+#include <linux/wimax.h>
+#include <linux/security.h>
+#include "wimax-internal.h"
+
+#define D_SUBMODULE op_state_get
+#include "debug-levels.h"
+
+
+static const
+struct nla_policy wimax_gnl_state_get_policy[WIMAX_GNL_ATTR_MAX + 1] = {
+	[WIMAX_GNL_STGET_IFIDX] = {
+		.type = NLA_U32,
+	},
+};
+
+
+/*
+ * Exporting to user space over generic netlink
+ *
+ * Parse the state get command from user space, return a combination
+ * value that describe the current state.
+ *
+ * No attributes.
+ */
+static
+int wimax_gnl_doit_state_get(struct sk_buff *skb, struct genl_info *info)
+{
+	int result, ifindex;
+	struct wimax_dev *wimax_dev;
+	struct device *dev;
+
+	d_fnstart(3, NULL, "(skb %p info %p)\n", skb, info);
+	result = -ENODEV;
+	if (info->attrs[WIMAX_GNL_STGET_IFIDX] == NULL) {
+		printk(KERN_ERR "WIMAX_GNL_OP_STATE_GET: can't find IFIDX "
+			"attribute\n");
+		goto error_no_wimax_dev;
+	}
+	ifindex = nla_get_u32(info->attrs[WIMAX_GNL_STGET_IFIDX]);
+	wimax_dev = wimax_dev_get_by_genl_info(info, ifindex);
+	if (wimax_dev == NULL)
+		goto error_no_wimax_dev;
+	dev = wimax_dev_to_dev(wimax_dev);
+	/* Execute the operation and send the result back to user space */
+	result = wimax_state_get(wimax_dev);
+	dev_put(wimax_dev->net_dev);
+error_no_wimax_dev:
+	d_fnend(3, NULL, "(skb %p info %p) = %d\n", skb, info, result);
+	return result;
+}
+
+
+struct genl_ops wimax_gnl_state_get = {
+	.cmd = WIMAX_GNL_OP_STATE_GET,
+	.flags = GENL_ADMIN_PERM,
+	.policy = wimax_gnl_state_get_policy,
+	.doit = wimax_gnl_doit_state_get,
+	.dumpit = NULL,
+};
diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index 933e142..79fb7d7 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -402,13 +402,15 @@ EXPORT_SYMBOL_GPL(wimax_dev_init);
 extern struct genl_ops
 	wimax_gnl_msg_from_user,
 	wimax_gnl_reset,
-	wimax_gnl_rfkill;
+	wimax_gnl_rfkill,
+	wimax_gnl_state_get;
 
 static
 struct genl_ops *wimax_gnl_ops[] = {
 	&wimax_gnl_msg_from_user,
 	&wimax_gnl_reset,
 	&wimax_gnl_rfkill,
+	&wimax_gnl_state_get,
 };
 
 
@@ -533,6 +535,7 @@ struct d_level D_LEVEL[] = {
 	D_SUBMODULE_DEFINE(op_msg),
 	D_SUBMODULE_DEFINE(op_reset),
 	D_SUBMODULE_DEFINE(op_rfkill),
+	D_SUBMODULE_DEFINE(op_state_get),
 	D_SUBMODULE_DEFINE(stack),
 };
 size_t D_LEVEL_SIZE = ARRAY_SIZE(D_LEVEL);
-- 
1.6.2.3

