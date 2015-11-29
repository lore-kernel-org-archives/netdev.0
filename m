From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFCv3 bluetooth-next 2/4] 6lowpan: add debugfs support
Date: Sun, 29 Nov 2015 12:34:40 +0100
Message-ID: <1448796882-316-3-git-send-email-alex.aring@gmail.com>
References: <1448796882-316-1-git-send-email-alex.aring@gmail.com>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, lukasz.duda-hR+23Fw+YnFSHonuZl5R5Q@public.gmane.org,
	martin.gergeleit-6wGqcYweBVc@public.gmane.org, Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1448796882-316-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch will introduce a 6lowpan entry into the debugfs if enabled.
Inside this 6lowpan directory we create a subdirectories of all 6lowpan
interfaces to offer a per interface debugfs support.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/6lowpan.h   |  3 +++
 net/6lowpan/6lowpan_i.h | 28 ++++++++++++++++++++++++++
 net/6lowpan/Kconfig     |  8 ++++++++
 net/6lowpan/Makefile    |  1 +
 net/6lowpan/core.c      | 28 +++++++++++++++++++++++++-
 net/6lowpan/debugfs.c   | 53 +++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 120 insertions(+), 1 deletion(-)
 create mode 100644 net/6lowpan/6lowpan_i.h
 create mode 100644 net/6lowpan/debugfs.c

diff --git a/include/net/6lowpan.h b/include/net/6lowpan.h
index 730211f..2f6a3f2 100644
--- a/include/net/6lowpan.h
+++ b/include/net/6lowpan.h
@@ -53,6 +53,8 @@
 #ifndef __6LOWPAN_H__
 #define __6LOWPAN_H__
 
+#include <linux/debugfs.h>
+
 #include <net/ipv6.h>
 #include <net/net_namespace.h>
 
@@ -98,6 +100,7 @@ enum lowpan_lltypes {
 
 struct lowpan_priv {
 	enum lowpan_lltypes lltype;
+	struct dentry *iface_debugfs;
 
 	/* must be last */
 	u8 priv[0] __aligned(sizeof(void *));
diff --git a/net/6lowpan/6lowpan_i.h b/net/6lowpan/6lowpan_i.h
new file mode 100644
index 0000000..d16bb4b
--- /dev/null
+++ b/net/6lowpan/6lowpan_i.h
@@ -0,0 +1,28 @@
+#ifndef __6LOWPAN_I_H
+#define __6LOWPAN_I_H
+
+#include <linux/netdevice.h>
+
+#ifdef CONFIG_6LOWPAN_DEBUGFS
+int lowpan_dev_debugfs_init(struct net_device *dev);
+void lowpan_dev_debugfs_exit(struct net_device *dev);
+
+int __init lowpan_debugfs_init(void);
+void lowpan_debugfs_exit(void);
+#else
+static inline int lowpan_dev_debugfs_init(struct net_device *dev)
+{
+	return 0;
+}
+
+static inline void lowpan_dev_debugfs_exit(struct net_device *dev) { }
+
+static inline int __init lowpan_debugfs_init(void)
+{
+	return 0;
+}
+
+static inline void lowpan_debugfs_exit(void) { }
+#endif /* CONFIG_6LOWPAN_DEBUGFS */
+
+#endif /* __6LOWPAN_I_H */
diff --git a/net/6lowpan/Kconfig b/net/6lowpan/Kconfig
index 7fa0f38..7ecedd7 100644
--- a/net/6lowpan/Kconfig
+++ b/net/6lowpan/Kconfig
@@ -5,6 +5,14 @@ menuconfig 6LOWPAN
 	  This enables IPv6 over Low power Wireless Personal Area Network -
 	  "6LoWPAN" which is supported by IEEE 802.15.4 or Bluetooth stacks.
 
+config 6LOWPAN_DEBUGFS
+	bool "6LoWPAN debugfs support"
+	depends on 6LOWPAN
+	depends on DEBUG_FS
+	---help---
+	  This enables 6LoWPAN debugfs support. For example to manipulate
+	  IPHC context information at runtime.
+
 menuconfig 6LOWPAN_NHC
 	tristate "Next Header Compression Support"
 	depends on 6LOWPAN
diff --git a/net/6lowpan/Makefile b/net/6lowpan/Makefile
index c6ffc55..54cad8d 100644
--- a/net/6lowpan/Makefile
+++ b/net/6lowpan/Makefile
@@ -1,6 +1,7 @@
 obj-$(CONFIG_6LOWPAN) += 6lowpan.o
 
 6lowpan-y := core.o iphc.o nhc.o
+6lowpan-$(CONFIG_6LOWPAN_DEBUGFS) += debugfs.o
 
 #rfc6282 nhcs
 obj-$(CONFIG_6LOWPAN_NHC_DEST) += nhc_dest.o
diff --git a/net/6lowpan/core.c b/net/6lowpan/core.c
index 80fc509..c7f06f5 100644
--- a/net/6lowpan/core.c
+++ b/net/6lowpan/core.c
@@ -15,9 +15,13 @@
 
 #include <net/6lowpan.h>
 
+#include "6lowpan_i.h"
+
 int lowpan_register_netdevice(struct net_device *dev,
 			      enum lowpan_lltypes lltype)
 {
+	int ret;
+
 	dev->addr_len = EUI64_ADDR_LEN;
 	dev->type = ARPHRD_6LOWPAN;
 	dev->mtu = IPV6_MIN_MTU;
@@ -25,7 +29,15 @@ int lowpan_register_netdevice(struct net_device *dev,
 
 	lowpan_priv(dev)->lltype = lltype;
 
-	return register_netdevice(dev);
+	ret = lowpan_dev_debugfs_init(dev);
+	if (ret < 0)
+		return ret;
+
+	ret = register_netdevice(dev);
+	if (ret < 0)
+		lowpan_dev_debugfs_exit(dev);
+
+	return ret;
 }
 EXPORT_SYMBOL(lowpan_register_netdevice);
 
@@ -44,6 +56,7 @@ EXPORT_SYMBOL(lowpan_register_netdev);
 void lowpan_unregister_netdevice(struct net_device *dev)
 {
 	unregister_netdevice(dev);
+	lowpan_dev_debugfs_exit(dev);
 }
 EXPORT_SYMBOL(lowpan_unregister_netdevice);
 
@@ -57,6 +70,12 @@ EXPORT_SYMBOL(lowpan_unregister_netdev);
 
 static int __init lowpan_module_init(void)
 {
+	int ret;
+
+	ret = lowpan_debugfs_init();
+	if (ret < 0)
+		return ret;
+
 	request_module_nowait("ipv6");
 
 	request_module_nowait("nhc_dest");
@@ -69,6 +88,13 @@ static int __init lowpan_module_init(void)
 
 	return 0;
 }
+
+static void __exit lowpan_module_exit(void)
+{
+	lowpan_debugfs_exit();
+}
+
 module_init(lowpan_module_init);
+module_exit(lowpan_module_exit);
 
 MODULE_LICENSE("GPL");
diff --git a/net/6lowpan/debugfs.c b/net/6lowpan/debugfs.c
new file mode 100644
index 0000000..88eef84
--- /dev/null
+++ b/net/6lowpan/debugfs.c
@@ -0,0 +1,53 @@
+/* This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors:
+ * (C) 2015 Pengutronix, Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
+ * Copyright (c)  2015 Nordic Semiconductor. All Rights Reserved.
+ */
+
+#include <net/6lowpan.h>
+
+#include "6lowpan_i.h"
+
+static struct dentry *lowpan_debugfs;
+
+int lowpan_dev_debugfs_init(struct net_device *dev)
+{
+	struct lowpan_priv *lpriv = lowpan_priv(dev);
+
+	/* creating the root */
+	lpriv->iface_debugfs = debugfs_create_dir(dev->name, lowpan_debugfs);
+	if (!lpriv->iface_debugfs)
+		goto fail;
+
+	return 0;
+
+fail:
+	return -EINVAL;
+}
+
+void lowpan_dev_debugfs_exit(struct net_device *dev)
+{
+	debugfs_remove_recursive(lowpan_priv(dev)->iface_debugfs);
+}
+
+int __init lowpan_debugfs_init(void)
+{
+	lowpan_debugfs = debugfs_create_dir("6lowpan", NULL);
+	if (!lowpan_debugfs)
+		return -EINVAL;
+
+	return 0;
+}
+
+void lowpan_debugfs_exit(void)
+{
+	debugfs_remove_recursive(lowpan_debugfs);
+}
-- 
2.6.1
