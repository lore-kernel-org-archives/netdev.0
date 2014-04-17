From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC v3 03/10] net: introduce generic switch devices support
Date: Thu, 17 Apr 2014 14:14:30 +0200
Message-ID: <1397736876-11771-4-git-send-email-jiri@resnulli.us>
References: <1397736876-11771-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:60009 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161024AbaDQMO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 08:14:57 -0400
Received: by mail-ee0-f51.google.com with SMTP id c13so603255eek.10
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2014 05:14:55 -0700 (PDT)
In-Reply-To: <1397736876-11771-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this is to provide a possibility to suport various switch
chips. Drivers should implement relevant ndos to do so. So far, only one
ndo for getting physical switch id is in place.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 Documentation/networking/switchdev.txt | 53 ++++++++++++++++++++++++++++++++++
 include/linux/netdevice.h              | 10 +++++++
 include/linux/switchdev.h              | 30 +++++++++++++++++++
 net/Kconfig                            |  6 ++++
 net/core/Makefile                      |  1 +
 net/core/switchdev.c                   | 32 ++++++++++++++++++++
 6 files changed, 132 insertions(+)
 create mode 100644 Documentation/networking/switchdev.txt
 create mode 100644 include/linux/switchdev.h
 create mode 100644 net/core/switchdev.c

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
new file mode 100644
index 0000000..20345cc
--- /dev/null
+++ b/Documentation/networking/switchdev.txt
@@ -0,0 +1,53 @@
+Switch device drivers HOWTO
+===========================
+
+First lets describe a topology a bit. Imagine the following example:
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
+	ndo_swdev_get_id - This returns the same ID for two port netdevices of
+			   the same physical switch chip. This is mandatory to
+			   be implemented by all switch drivers and serves
+			   the caller for recognition of a port netdevice.
+	ndo_swdev_* - Functions that serve for a manipulation of the switch chip
+		      itself. They are not port-specific. Caller might use
+		      arbitrary port netdevice of the same switch and it will
+		      make no difference.
+	ndo_swportdev_* - Functions that serve for a port-specific manipulation.
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8cf4f5e..83e38a0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -991,6 +991,12 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	Callback to use for xmit over the accelerated station. This
  *	is used in place of ndo_start_xmit on accelerated net
  *	devices.
+ *
+ * int (*ndo_swdev_get_id)(struct net_device *dev,
+ *			   struct netdev_phys_item_id *psid);
+ *	Called to get an ID of the switch chip this port is part of.
+ *	If driver implements this, it indicates that it represents a port
+ *	of a switch chip.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1137,6 +1143,10 @@ struct net_device_ops {
 	netdev_tx_t		(*ndo_dfwd_start_xmit) (struct sk_buff *skb,
 							struct net_device *dev,
 							void *priv);
+#ifdef CONFIG_NET_SWITCHDEV
+	int			(*ndo_swdev_get_id)(struct net_device *dev,
+						    struct netdev_phys_item_id *psid);
+#endif
 };
 
 /**
diff --git a/include/linux/switchdev.h b/include/linux/switchdev.h
new file mode 100644
index 0000000..b147dde
--- /dev/null
+++ b/include/linux/switchdev.h
@@ -0,0 +1,30 @@
+/*
+ * include/linux/switchdev.h - Switch device API
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
+#include <linux/sw_flow.h>
+
+#ifdef CONFIG_NET_SWITCHDEV
+
+int swdev_get_id(struct net_device *dev, struct netdev_phys_item_id *psid);
+
+#else
+
+static inline int swdev_get_id(struct net_device *dev,
+			       struct netdev_phys_item_id *psid)
+{
+	return -EOPNOTSUPP;
+}
+
+#endif
+
+#endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/Kconfig b/net/Kconfig
index d1f6f96..b13be7c 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -289,6 +289,12 @@ config NET_FLOW_LIMIT
 	  with many clients some protection against DoS by a single (spoofed)
 	  flow that greatly exceeds average workload.
 
+config NET_SWITCHDEV
+	boolean "Switch device support"
+	depends on INET
+	---help---
+	  This module provides support for hardware switch chips.
+
 menu "Network testing"
 
 config NET_PKTGEN
diff --git a/net/core/Makefile b/net/core/Makefile
index 826b925..4b27dff 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -24,3 +24,4 @@ obj-$(CONFIG_NETWORK_PHY_TIMESTAMPING) += timestamping.o
 obj-$(CONFIG_NET_PTP_CLASSIFY) += ptp_classifier.o
 obj-$(CONFIG_CGROUP_NET_PRIO) += netprio_cgroup.o
 obj-$(CONFIG_CGROUP_NET_CLASSID) += netclassid_cgroup.o
+obj-$(CONFIG_NET_SWITCHDEV) += switchdev.o
diff --git a/net/core/switchdev.c b/net/core/switchdev.c
new file mode 100644
index 0000000..2d275f5
--- /dev/null
+++ b/net/core/switchdev.c
@@ -0,0 +1,32 @@
+/*
+ * net/core/switchdev.c - Switch device API
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
+#include <linux/switchdev.h>
+
+/**
+ *	swdev_get_id - Get ID of a switch
+ *	@dev: port device
+ *	@psid: switch ID
+ *
+ *	Get ID of a switch this port is part of.
+ */
+int swdev_get_id(struct net_device *dev, struct netdev_phys_item_id *psid)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (!ops->ndo_swdev_get_id)
+		return -EOPNOTSUPP;
+	return ops->ndo_swdev_get_id(dev, psid);
+}
+EXPORT_SYMBOL(swdev_get_id);
-- 
1.9.0
