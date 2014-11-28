From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 06/21] net: introduce generic switch devices support
Date: Fri, 28 Nov 2014 14:34:17 +0100
Message-ID: <1417181672-11531-7-git-send-email-jiri@resnulli.us>
References: <1417181672-11531-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.co
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:46841 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229AbaK1Nel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 08:34:41 -0500
Received: by mail-wg0-f50.google.com with SMTP id k14so8787570wgh.23
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2014 05:34:40 -0800 (PST)
In-Reply-To: <1417181672-11531-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this is to provide a possibility to support various switch
chips. Drivers should implement relevant ndos to do so. Now there is
only one ndo defined:
- for getting physical switch id is in place.

Note that user can use random port netdevice to access the switch.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Reviewed-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>
---
v3->v4->v5:
-no change
v2->v3:
-fixed documentation typo pointed out by M. Braun
-changed "sw" string to "switch" to avoid confusion
v1->v2:
-no change
---
 Documentation/networking/switchdev.txt | 59 ++++++++++++++++++++++++++++++++++
 MAINTAINERS                            |  7 ++++
 include/linux/netdevice.h              | 10 ++++++
 include/net/switchdev.h                | 30 +++++++++++++++++
 net/Kconfig                            |  1 +
 net/Makefile                           |  3 ++
 net/switchdev/Kconfig                  | 13 ++++++++
 net/switchdev/Makefile                 |  5 +++
 net/switchdev/switchdev.c              | 33 +++++++++++++++++++
 9 files changed, 161 insertions(+)
 create mode 100644 Documentation/networking/switchdev.txt
 create mode 100644 include/net/switchdev.h
 create mode 100644 net/switchdev/Kconfig
 create mode 100644 net/switchdev/Makefile
 create mode 100644 net/switchdev/switchdev.c

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
new file mode 100644
index 0000000..f981a92
--- /dev/null
+++ b/Documentation/networking/switchdev.txt
@@ -0,0 +1,59 @@
+Switch (and switch-ish) device drivers HOWTO
+===========================
+
+Please note that the word "switch" is here used in very generic meaning.
+This include devices supporting L2/L3 but also various flow offloading chips,
+including switches embedded into SR-IOV NICs.
+
+Lets describe a topology a bit. Imagine the following example:
+
+       +----------------------------+    +---------------+
+       |     SOME switch chip       |    |      CPU      |
+       +----------------------------+    +---------------+
+       port1 port2 port3 port4 MNGMNT    |     PCI-E     |
+         |     |     |     |     |       +---------------+
+        PHY   PHY    |     |     |         |  NIC0 NIC1
+                     |     |     |         |   |    |
+                     |     |     +- PCI-E -+   |    |
+                     |     +------- MII -------+    |
+                     +------------- MII ------------+
+
+In this example, there are two independent lines between the switch silicon
+and CPU. NIC0 and NIC1 drivers are not aware of a switch presence. They are
+separate from the switch driver. SOME switch chip is by managed by a driver
+via PCI-E device MNGMNT. Note that MNGMNT device, NIC0 and NIC1 may be
+connected to some other type of bus.
+
+Now, for the previous example show the representation in kernel:
+
+       +----------------------------+    +---------------+
+       |     SOME switch chip       |    |      CPU      |
+       +----------------------------+    +---------------+
+       sw0p0 sw0p1 sw0p2 sw0p3 MNGMNT    |     PCI-E     |
+         |     |     |     |     |       +---------------+
+        PHY   PHY    |     |     |         |  eth0 eth1
+                     |     |     |         |   |    |
+                     |     |     +- PCI-E -+   |    |
+                     |     +------- MII -------+    |
+                     +------------- MII ------------+
+
+Lets call the example switch driver for SOME switch chip "SOMEswitch". This
+driver takes care of PCI-E device MNGMNT. There is a netdevice instance sw0pX
+created for each port of a switch. These netdevices are instances
+of "SOMEswitch" driver. sw0pX netdevices serve as a "representation"
+of the switch chip. eth0 and eth1 are instances of some other existing driver.
+
+The only difference of the switch-port netdevice from the ordinary netdevice
+is that is implements couple more NDOs:
+
+  ndo_switch_parent_id_get - This returns the same ID for two port netdevices
+			     of the same physical switch chip. This is
+			     mandatory to be implemented by all switch drivers
+			     and serves the caller for recognition of a port
+			     netdevice.
+  ndo_switch_parent_* - Functions that serve for a manipulation of the switch
+			chip itself (it can be though of as a "parent" of the
+			port, therefore the name). They are not port-specific.
+			Caller might use arbitrary port netdevice of the same
+			switch and it will make no difference.
+  ndo_switch_port_* - Functions that serve for a port-specific manipulation.
diff --git a/MAINTAINERS b/MAINTAINERS
index a545d68..05addb6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9058,6 +9058,13 @@ F:	lib/swiotlb.c
 F:	arch/*/kernel/pci-swiotlb.c
 F:	include/linux/swiotlb.h
 
+SWITCHDEV
+M:	Jiri Pirko <jiri@resnulli.us>
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	net/switchdev/
+F:	include/net/switchdev.h
+
 SYNOPSYS ARC ARCHITECTURE
 M:	Vineet Gupta <vgupta@synopsys.com>
 S:	Supported
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4bd41d7..3603f31 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1018,6 +1018,12 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	performing GSO on a packet. The device returns true if it is
  *	able to GSO the packet, false otherwise. If the return value is
  *	false the stack will do software GSO.
+ *
+ * int (*ndo_switch_parent_id_get)(struct net_device *dev,
+ *				   struct netdev_phys_item_id *psid);
+ *	Called to get an ID of the switch chip this port is part of.
+ *	If driver implements this, it indicates that it represents a port
+ *	of a switch chip.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1171,6 +1177,10 @@ struct net_device_ops {
 	int			(*ndo_get_lock_subclass)(struct net_device *dev);
 	bool			(*ndo_gso_check) (struct sk_buff *skb,
 						  struct net_device *dev);
+#ifdef CONFIG_NET_SWITCHDEV
+	int			(*ndo_switch_parent_id_get)(struct net_device *dev,
+							    struct netdev_phys_item_id *psid);
+#endif
 };
 
 /**
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
new file mode 100644
index 0000000..7a52360
--- /dev/null
+++ b/include/net/switchdev.h
@@ -0,0 +1,30 @@
+/*
+ * include/net/switchdev.h - Switch device API
+ * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+#ifndef _LINUX_SWITCHDEV_H_
+#define _LINUX_SWITCHDEV_H_
+
+#include <linux/netdevice.h>
+
+#ifdef CONFIG_NET_SWITCHDEV
+
+int netdev_switch_parent_id_get(struct net_device *dev,
+				struct netdev_phys_item_id *psid);
+
+#else
+
+static inline int netdev_switch_parent_id_get(struct net_device *dev,
+					      struct netdev_phys_item_id *psid)
+{
+	return -EOPNOTSUPP;
+}
+
+#endif
+
+#endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/Kconfig b/net/Kconfig
index 99815b5..ff9ffc1 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -228,6 +228,7 @@ source "net/vmw_vsock/Kconfig"
 source "net/netlink/Kconfig"
 source "net/mpls/Kconfig"
 source "net/hsr/Kconfig"
+source "net/switchdev/Kconfig"
 
 config RPS
 	boolean
diff --git a/net/Makefile b/net/Makefile
index 7ed1970..95fc694 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -73,3 +73,6 @@ obj-$(CONFIG_OPENVSWITCH)	+= openvswitch/
 obj-$(CONFIG_VSOCKETS)	+= vmw_vsock/
 obj-$(CONFIG_NET_MPLS_GSO)	+= mpls/
 obj-$(CONFIG_HSR)		+= hsr/
+ifneq ($(CONFIG_NET_SWITCHDEV),)
+obj-y				+= switchdev/
+endif
diff --git a/net/switchdev/Kconfig b/net/switchdev/Kconfig
new file mode 100644
index 0000000..1557545
--- /dev/null
+++ b/net/switchdev/Kconfig
@@ -0,0 +1,13 @@
+#
+# Configuration for Switch device support
+#
+
+config NET_SWITCHDEV
+	boolean "Switch (and switch-ish) device support (EXPERIMENTAL)"
+	depends on INET
+	---help---
+	  This module provides glue between core networking code and device
+	  drivers in order to support hardware switch chips in very generic
+	  meaning of the word "switch". This include devices supporting L2/L3 but
+	  also various flow offloading chips, including switches embedded into
+	  SR-IOV NICs.
diff --git a/net/switchdev/Makefile b/net/switchdev/Makefile
new file mode 100644
index 0000000..5ed63ed
--- /dev/null
+++ b/net/switchdev/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Switch device API
+#
+
+obj-$(CONFIG_NET_SWITCHDEV) += switchdev.o
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
new file mode 100644
index 0000000..66973de
--- /dev/null
+++ b/net/switchdev/switchdev.c
@@ -0,0 +1,33 @@
+/*
+ * net/switchdev/switchdev.c - Switch device API
+ * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <net/switchdev.h>
+
+/**
+ *	netdev_switch_parent_id_get - Get ID of a switch
+ *	@dev: port device
+ *	@psid: switch ID
+ *
+ *	Get ID of a switch this port is part of.
+ */
+int netdev_switch_parent_id_get(struct net_device *dev,
+				struct netdev_phys_item_id *psid)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (!ops->ndo_switch_parent_id_get)
+		return -EOPNOTSUPP;
+	return ops->ndo_switch_parent_id_get(dev, psid);
+}
+EXPORT_SYMBOL(netdev_switch_parent_id_get);
-- 
1.9.3
