From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC net-next 01/11] net: Introduce L3 Master device abstraction
Date: Fri, 18 Sep 2015 10:06:15 -0700
Message-ID: <1442595985-7049-2-git-send-email-dsa@cumulusnetworks.com>
References: <1442595985-7049-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, gospo@cumulusnetworks.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33218 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496AbbIRRGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 13:06:39 -0400
Received: by pacex6 with SMTP id ex6so56178951pac.0
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 10:06:38 -0700 (PDT)
In-Reply-To: <1442595985-7049-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

L3 master devices allow users of the abstraction to influence FIB lookups
for enslaved devices. Current API provides a means for the master device
to return a specific FIB table for an enslaved device, to return an
rtable/custom dst and influence the OIF used for fib lookups.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 MAINTAINERS               |   7 +++
 include/linux/netdevice.h |   3 ++
 include/net/l3mdev.h      | 128 ++++++++++++++++++++++++++++++++++++++++++++++
 net/Kconfig               |   1 +
 net/Makefile              |   3 ++
 net/l3mdev/Kconfig        |  10 ++++
 net/l3mdev/Makefile       |   5 ++
 net/l3mdev/l3mdev.c       |  84 ++++++++++++++++++++++++++++++
 8 files changed, 241 insertions(+)
 create mode 100644 include/net/l3mdev.h
 create mode 100644 net/l3mdev/Kconfig
 create mode 100644 net/l3mdev/Makefile
 create mode 100644 net/l3mdev/l3mdev.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 310da4295c70..a88c99988022 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6088,6 +6088,13 @@ F:	Documentation/auxdisplay/ks0108
 F:	drivers/auxdisplay/ks0108.c
 F:	include/linux/ks0108.h
 
+L3MDEV
+M:	David Ahern <dsa@cumulusnetworks.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	net/l3mdev
+F:	include/net/l3mdev.h
+
 LAPB module
 L:	linux-x25@vger.kernel.org
 S:	Orphan
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b791405958b4..320625d181fd 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1586,6 +1586,9 @@ struct net_device {
 #ifdef CONFIG_NET_SWITCHDEV
 	const struct switchdev_ops *switchdev_ops;
 #endif
+#ifdef CONFIG_NET_L3_MASTER_DEV
+	const struct l3mdev_ops	*l3mdev_ops;
+#endif
 
 	const struct header_ops *header_ops;
 
diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
new file mode 100644
index 000000000000..3892637d2f0e
--- /dev/null
+++ b/include/net/l3mdev.h
@@ -0,0 +1,128 @@
+/*
+ * include/net/l3mdev.h - L3 master device API
+ * Copyright (c) 2015 Cumulus Networks
+ * Copyright (c) 2015 David Ahern <dsa@cumulusnetworks.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+#ifndef _NET_L3MDEV_H_
+#define _NET_L3MDEV_H_
+
+#include <linux/netdevice.h>
+
+/**
+ * struct l3mdev_ops - l3mdev operations
+ *
+ * @l3mdev_fib_table: Get FIB table id to use for lookups
+ *
+ * @l3dev_get_rtable: Get cached IPv4 rtable (dst_entry) for device
+ */
+
+struct l3mdev_ops {
+	u32		(*l3mdev_fib_table)(const struct net_device *dev);
+	struct rtable *	(*l3mdev_get_rtable)(const struct net_device *dev,
+					     const struct flowi4 *fl4);
+};
+
+#ifdef CONFIG_NET_L3_MASTER_DEV
+
+int l3mdev_master_ifindex_rcu(struct net_device *dev);
+static inline int l3mdev_master_ifindex(struct net_device *dev)
+{
+	int ifindex;
+
+	rcu_read_lock();
+	ifindex = l3mdev_master_ifindex_rcu(dev);
+	rcu_read_unlock();
+
+	return ifindex;
+}
+
+/* get index of an interface to use for FIB lookups. For devices
+ * enslaved to an L3 master device FIB lookups are based on the
+ * master index
+ */
+static inline int l3mdev_fib_oif_rcu(struct net_device *dev)
+{
+	return l3mdev_master_ifindex_rcu(dev) ? : dev->ifindex;
+}
+
+static inline int l3mdev_fib_oif(struct net_device *dev)
+{
+	int oif;
+
+	rcu_read_lock();
+	oif = l3mdev_fib_oif_rcu(dev);
+	rcu_read_unlock();
+
+	return oif;
+}
+
+u32 l3mdev_fib_table_rcu(const struct net_device *dev);
+u32 l3mdev_fib_table_by_index(struct net *net, int ifindex);
+static inline u32 l3mdev_fib_table(const struct net_device *dev)
+{
+	u32 tb_id;
+
+	rcu_read_lock();
+	tb_id = l3mdev_fib_table_rcu(dev);
+	rcu_read_unlock();
+
+	return tb_id;
+}
+
+/* netif_is_l3_master already checked by caller */
+static inline struct rtable *l3mdev_get_rtable(const struct net_device *dev,
+					       const struct flowi4 *fl4)
+{
+	if (dev->l3mdev_ops->l3mdev_get_rtable)
+		return dev->l3mdev_ops->l3mdev_get_rtable(dev, fl4);
+
+	return NULL;
+}
+
+#else
+
+static inline int l3mdev_master_ifindex_rcu(struct net_device *dev)
+{
+	return 0;
+}
+static inline int l3mdev_master_ifindex(struct net_device *dev)
+{
+	return 0;
+}
+
+static inline int l3mdev_fib_oif_rcu(struct net_device *dev)
+{
+	return dev ? dev->ifindex : 0;
+}
+static inline int l3mdev_fib_oif(struct net_device *dev)
+{
+	return dev ? dev->ifindex : 0;
+}
+
+static inline u32 l3mdev_fib_table_rcu(const struct net_device *dev)
+{
+	return 0;
+}
+static inline u32 l3mdev_fib_table(const struct net_device *dev)
+{
+	return 0;
+}
+static inline u32 l3mdev_fib_table_by_index(struct net *net, int ifindex)
+{
+	return 0;
+}
+
+static inline struct rtable *l3mdev_get_rtable(const struct net_device *dev,
+					       const struct flowi4 *fl4)
+{
+	return NULL;
+}
+
+#endif
+
+#endif /* _NET_L3MDEV_H_ */
diff --git a/net/Kconfig b/net/Kconfig
index 7021c1bf44d6..127da94ae25e 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -232,6 +232,7 @@ source "net/netlink/Kconfig"
 source "net/mpls/Kconfig"
 source "net/hsr/Kconfig"
 source "net/switchdev/Kconfig"
+source "net/l3mdev/Kconfig"
 
 config RPS
 	bool
diff --git a/net/Makefile b/net/Makefile
index 3995613e5510..a5d04098dfce 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -74,3 +74,6 @@ obj-$(CONFIG_HSR)		+= hsr/
 ifneq ($(CONFIG_NET_SWITCHDEV),)
 obj-y				+= switchdev/
 endif
+ifneq ($(CONFIG_NET_L3_MASTER_DEV),)
+obj-y				+= l3mdev/
+endif
diff --git a/net/l3mdev/Kconfig b/net/l3mdev/Kconfig
new file mode 100644
index 000000000000..5d47325037bc
--- /dev/null
+++ b/net/l3mdev/Kconfig
@@ -0,0 +1,10 @@
+#
+# Configuration for L3 master device support
+#
+
+config NET_L3_MASTER_DEV
+	bool "L3 Master device support"
+	depends on INET || IPV6
+	---help---
+	  This module provides glue between core networking code and device
+	  drivers to support L3 master devices like VRF.
diff --git a/net/l3mdev/Makefile b/net/l3mdev/Makefile
new file mode 100644
index 000000000000..84a53a6f609a
--- /dev/null
+++ b/net/l3mdev/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the L3 device API
+#
+
+obj-$(CONFIG_NET_L3_MASTER_DEV) += l3mdev.o
diff --git a/net/l3mdev/l3mdev.c b/net/l3mdev/l3mdev.c
new file mode 100644
index 000000000000..52e6ece48c3d
--- /dev/null
+++ b/net/l3mdev/l3mdev.c
@@ -0,0 +1,84 @@
+#include <linux/netdevice.h>
+#include <net/l3mdev.h>
+
+/**
+ *	l3mdev_master_ifindex - get index of L3 master device
+ *	@dev: targeted interface
+ */
+
+int l3mdev_master_ifindex_rcu(struct net_device *dev)
+{
+	int ifindex = 0;
+
+	if (!dev)
+		return 0;
+
+	if (netif_is_l3_master(dev)) {
+		ifindex = dev->ifindex;
+
+	} else if (dev->flags & IFF_SLAVE) {
+		struct net_device *master;
+
+		master = netdev_master_upper_dev_get_rcu(dev);
+		if (netif_is_l3_master(master))
+			ifindex = master->ifindex;
+	}
+
+	return ifindex;
+}
+
+/**
+ *	l3mdev_fib_table - get FIB table id associated with an L3
+ *                             master interface
+ *	@dev: targeted interface
+ */
+
+u32 l3mdev_fib_table_rcu(const struct net_device *dev)
+{
+	u32 tb_id = 0;
+
+	if (!dev)
+		return 0;
+
+	if (netif_is_l3_master(dev)) {
+		if (dev->l3mdev_ops->l3mdev_fib_table)
+			tb_id = dev->l3mdev_ops->l3mdev_fib_table(dev);
+
+	} else if (dev->flags & IFF_SLAVE) {
+		/* TO-DO: remove the need for typecast.
+		 * Users of netdev_master_upper_dev_get_rcu need non-const,
+		 * but current inet_*type functions take a const
+		 */
+		struct net_device *_dev = (struct net_device *) dev;
+		const struct net_device *master;
+
+		master = netdev_master_upper_dev_get_rcu(_dev);
+		if (!master)
+			return 0;
+
+		if (netif_is_l3_master(master) &&
+		    master->l3mdev_ops->l3mdev_fib_table)
+			tb_id = master->l3mdev_ops->l3mdev_fib_table(master);
+	}
+
+	return tb_id;
+}
+
+u32 l3mdev_fib_table_by_index(struct net *net, int ifindex)
+{
+	struct net_device *dev;
+	u32 tb_id = 0;
+
+	if (!ifindex)
+		return 0;
+
+	rcu_read_lock();
+
+	dev = dev_get_by_index_rcu(net, ifindex);
+	if (dev)
+		tb_id = l3mdev_fib_table_rcu(dev);
+
+	rcu_read_unlock();
+
+	return tb_id;
+}
-- 
1.9.1
