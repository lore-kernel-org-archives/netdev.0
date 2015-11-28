From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH] net: add support for netdev notifier error injection
Date: Sat, 28 Nov 2015 13:45:28 +0100
Message-ID: <1448714728-12729-1-git-send-email-razor@blackwall.org>
Cc: shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:32901 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbbK1MqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2015 07:46:21 -0500
Received: by wmec201 with SMTP id c201so99181856wme.0
        for <netdev@vger.kernel.org>; Sat, 28 Nov 2015 04:46:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This module allows to insert errors in some of netdevice's notifier
events. All network drivers use these notifiers to signal various events
and to check if they are allowed, e.g. PRECHANGEMTU and CHANGEMTU
afterwards. Until recently I had to run failure tests by injecting
a custom module, but now this infrastructure makes it trivial to test
these failure paths. Some of the recent bugs I fixed were found using
this module.
Here's an example:
 $ cd /sys/kernel/debug/notifier-error-inject/netdev
 $ echo -22 > actions/NETDEV_CHANGEMTU/error
 $ ip link set eth0 mtu 1024
 RTNETLINK answers: Invalid argument

CC: Akinobu Mita <akinobu.mita@gmail.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: netdev <netdev@vger.kernel.org>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
I'm not sure through which tree this should go in, so I haven't put any
tags. I've tested it both against Linus' tree and DaveM's net-next.

 .../fault-injection/notifier-error-inject.txt      | 24 ++++++++++
 lib/Kconfig.debug                                  | 23 +++++++++
 lib/Makefile                                       |  1 +
 lib/netdev-notifier-error-inject.c                 | 54 ++++++++++++++++++++++
 4 files changed, 102 insertions(+)
 create mode 100644 lib/netdev-notifier-error-inject.c

diff --git a/Documentation/fault-injection/notifier-error-inject.txt b/Documentation/fault-injection/notifier-error-inject.txt
index 09adabef513f..71e638a4c497 100644
--- a/Documentation/fault-injection/notifier-error-inject.txt
+++ b/Documentation/fault-injection/notifier-error-inject.txt
@@ -10,6 +10,7 @@ modules that can be used to test the following notifiers.
  * PM notifier
  * Memory hotplug notifier
  * powerpc pSeries reconfig notifier
+ * Netdevice notifier
 
 CPU notifier error injection module
 -----------------------------------
@@ -87,6 +88,29 @@ Possible pSeries reconfig notifier events to be failed are:
  * PSERIES_DRCONF_MEM_ADD
  * PSERIES_DRCONF_MEM_REMOVE
 
+Netdevice notifier error injection module
+----------------------------------------------
+This feature is controlled through debugfs interface
+/sys/kernel/debug/notifier-error-inject/netdev/actions/<notifier event>/error
+
+Netdevice notifier events which can be failed are:
+
+ * NETDEV_REGISTER
+ * NETDEV_CHANGEMTU
+ * NETDEV_CHANGENAME
+ * NETDEV_PRE_UP
+ * NETDEV_PRE_TYPE_CHANGE
+ * NETDEV_POST_INIT
+ * NETDEV_PRECHANGEMTU
+ * NETDEV_PRECHANGEUPPER
+
+Example: Inject netdevice mtu change error (-22 == -EINVAL)
+
+	# cd /sys/kernel/debug/notifier-error-inject/netdev
+	# echo -22 > actions/NETDEV_CHANGEMTU/error
+	# ip link set eth0 mtu 1024
+	RTNETLINK answers: Invalid argument
+
 For more usage examples
 -----------------------
 There are tools/testing/selftests using the notifier error injection features
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 8c15b29d5adc..0d76ecce27bb 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1484,6 +1484,29 @@ config OF_RECONFIG_NOTIFIER_ERROR_INJECT
 
 	  If unsure, say N.
 
+config NETDEV_NOTIFIER_ERROR_INJECT
+	tristate "Netdev notifier error injection module"
+	depends on NET && NOTIFIER_ERROR_INJECTION
+	help
+	  This option provides the ability to inject artificial errors to
+	  netdevice notifier chain callbacks.  It is controlled through debugfs
+	  interface /sys/kernel/debug/notifier-error-inject/netdev
+
+	  If the notifier call chain should be failed with some events
+	  notified, write the error code to "actions/<notifier event>/error".
+
+	  Example: Inject netdevice mtu change error (-22 = -EINVAL)
+
+	  # cd /sys/kernel/debug/notifier-error-inject/netdev
+	  # echo -22 > actions/NETDEV_CHANGEMTU/error
+	  # ip link set eth0 mtu 1024
+	  RTNETLINK answers: Invalid argument
+
+	  To compile this code as a module, choose M here: the module will
+	  be called netdev-notifier-error-inject.
+
+	  If unsure, say N.
+
 config FAULT_INJECTION
 	bool "Fault-injection framework"
 	depends on DEBUG_KERNEL
diff --git a/lib/Makefile b/lib/Makefile
index 7f1de26613d2..180dd4d0dd41 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -120,6 +120,7 @@ obj-$(CONFIG_FAULT_INJECTION) += fault-inject.o
 obj-$(CONFIG_NOTIFIER_ERROR_INJECTION) += notifier-error-inject.o
 obj-$(CONFIG_CPU_NOTIFIER_ERROR_INJECT) += cpu-notifier-error-inject.o
 obj-$(CONFIG_PM_NOTIFIER_ERROR_INJECT) += pm-notifier-error-inject.o
+obj-$(CONFIG_NETDEV_NOTIFIER_ERROR_INJECT) += netdev-notifier-error-inject.o
 obj-$(CONFIG_MEMORY_NOTIFIER_ERROR_INJECT) += memory-notifier-error-inject.o
 obj-$(CONFIG_OF_RECONFIG_NOTIFIER_ERROR_INJECT) += \
 	of-reconfig-notifier-error-inject.o
diff --git a/lib/netdev-notifier-error-inject.c b/lib/netdev-notifier-error-inject.c
new file mode 100644
index 000000000000..b2b856675d61
--- /dev/null
+++ b/lib/netdev-notifier-error-inject.c
@@ -0,0 +1,54 @@
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+
+#include "notifier-error-inject.h"
+
+static int priority;
+module_param(priority, int, 0);
+MODULE_PARM_DESC(priority, "specify netdevice notifier priority");
+
+static struct notifier_err_inject netdev_notifier_err_inject = {
+	.actions = {
+		{ NOTIFIER_ERR_INJECT_ACTION(NETDEV_REGISTER) },
+		{ NOTIFIER_ERR_INJECT_ACTION(NETDEV_CHANGEMTU) },
+		{ NOTIFIER_ERR_INJECT_ACTION(NETDEV_CHANGENAME) },
+		{ NOTIFIER_ERR_INJECT_ACTION(NETDEV_PRE_UP) },
+		{ NOTIFIER_ERR_INJECT_ACTION(NETDEV_PRE_TYPE_CHANGE) },
+		{ NOTIFIER_ERR_INJECT_ACTION(NETDEV_POST_INIT) },
+		{ NOTIFIER_ERR_INJECT_ACTION(NETDEV_PRECHANGEMTU) },
+		{ NOTIFIER_ERR_INJECT_ACTION(NETDEV_PRECHANGEUPPER) },
+		{}
+	}
+};
+
+static struct dentry *dir;
+
+static int netdev_err_inject_init(void)
+{
+	int err;
+
+	dir = notifier_err_inject_init("netdev", notifier_err_inject_dir,
+				       &netdev_notifier_err_inject, priority);
+	if (IS_ERR(dir))
+		return PTR_ERR(dir);
+
+	err = register_netdevice_notifier(&netdev_notifier_err_inject.nb);
+	if (err)
+		debugfs_remove_recursive(dir);
+
+	return err;
+}
+
+static void netdev_err_inject_exit(void)
+{
+	unregister_netdevice_notifier(&netdev_notifier_err_inject.nb);
+	debugfs_remove_recursive(dir);
+}
+
+module_init(netdev_err_inject_init);
+module_exit(netdev_err_inject_exit);
+
+MODULE_DESCRIPTION("Netdevice notifier error injection module");
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Nikolay Aleksandrov <razor@blackwall.org>");
-- 
2.4.3
