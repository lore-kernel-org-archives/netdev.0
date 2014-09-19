From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: [patch net-next v2 2/9] net: introduce generic switch
	devices support
Date: Fri, 19 Sep 2014 15:49:43 +0200
Message-ID: <1411134590-4586-3-git-send-email-jiri@resnulli.us>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1411134590-4586-1-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

The goal of this is to provide a possibility to suport various switch
chips. Drivers should implement relevant ndos to do so. Now there is
only one ndo defined:
- for getting physical switch id is in place.

Note that user can use random port netdevice to access the switch.

Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
---
 Documentation/networking/switchdev.txt | 53 ++++++++++++++++++++++++++++++++++
 MAINTAINERS                            |  7 +++++
 include/linux/netdevice.h              | 12 ++++++++
 include/net/switchdev.h                | 29 +++++++++++++++++++
 net/Kconfig                            |  1 +
 net/Makefile                           |  3 ++
 net/switchdev/Kconfig                  |  9 ++++++
 net/switchdev/Makefile                 |  5 ++++
 net/switchdev/switchdev.c              | 32 ++++++++++++++++++++
 9 files changed, 151 insertions(+)
 create mode 100644 Documentation/networking/switchdev.txt
 create mode 100644 include/net/switchdev.h
 create mode 100644 net/switchdev/Kconfig
 create mode 100644 net/switchdev/Makefile
 create mode 100644 net/switchdev/switchdev.c

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
new file mode 100644
index 0000000..435746a
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
diff --git a/MAINTAINERS b/MAINTAINERS
index 5e3709e..f1f26db 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8826,6 +8826,13 @@ F:	lib/swiotlb.c
 F:	arch/*/kernel/pci-swiotlb.c
 F:	include/linux/swiotlb.h
 
+SWITCHDEV
+M:	Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
+L:	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
+S:	Supported
+F:	net/switchdev/
+F:	include/net/switchdev.h
+
 SYNOPSYS ARC ARCHITECTURE
 M:	Vineet Gupta <vgupta-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
 S:	Supported
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 13d765f..b290dcf 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -752,6 +752,8 @@ struct netdev_phys_item_id {
 typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
 				       struct sk_buff *skb);
 
+#include <net/switchdev.h>
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -997,6 +999,12 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	Callback to use for xmit over the accelerated station. This
  *	is used in place of ndo_start_xmit on accelerated net
  *	devices.
+ *
+ * int (*ndo_swdev_id_get)(struct net_device *dev,
+ *			   struct netdev_phys_item_id *psid);
+ *	Called to get an ID of the switch chip this port is part of.
+ *	If driver implements this, it indicates that it represents a port
+ *	of a switch chip.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1146,6 +1154,10 @@ struct net_device_ops {
 							struct net_device *dev,
 							void *priv);
 	int			(*ndo_get_lock_subclass)(struct net_device *dev);
+#ifdef CONFIG_NET_SWITCHDEV
+	int			(*ndo_swdev_id_get)(struct net_device *dev,
+						    struct netdev_phys_item_id *psid);
+#endif
 };
 
 /**
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
new file mode 100644
index 0000000..af30f75
--- /dev/null
+++ b/include/net/switchdev.h
@@ -0,0 +1,29 @@
+/*
+ * include/net/switchdev.h - Switch device API
+ * Copyright (c) 2014 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
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
+int swdev_id_get(struct net_device *dev, struct netdev_phys_item_id *psid);
+
+#else
+
+static inline int swdev_id_get(struct net_device *dev,
+			       struct netdev_phys_item_id *psid)
+{
+	return -EOPNOTSUPP;
+}
+
+#endif
+
+#endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/Kconfig b/net/Kconfig
index 4051fdf..89a7fec 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -226,6 +226,7 @@ source "net/vmw_vsock/Kconfig"
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
index 0000000..20e8ed2
--- /dev/null
+++ b/net/switchdev/Kconfig
@@ -0,0 +1,9 @@
+#
+# Configuration for Switch device support
+#
+
+config NET_SWITCHDEV
+	boolean "Switch device support (EXPERIMENTAL)"
+	depends on INET
+	---help---
+	  This module provides support for hardware switch chips.
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
index 0000000..14a5fc9
--- /dev/null
+++ b/net/switchdev/switchdev.c
@@ -0,0 +1,32 @@
+/*
+ * net/switchdev/switchdev.c - Switch device API
+ * Copyright (c) 2014 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
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
+ *	swdev_id_get - Get ID of a switch
+ *	@dev: port device
+ *	@psid: switch ID
+ *
+ *	Get ID of a switch this port is part of.
+ */
+int swdev_id_get(struct net_device *dev, struct netdev_phys_item_id *psid)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (!ops->ndo_swdev_id_get)
+		return -EOPNOTSUPP;
+	return ops->ndo_swdev_id_get(dev, psid);
+}
+EXPORT_SYMBOL(swdev_id_get);
-- 
1.9.3
