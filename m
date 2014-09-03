From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: [patch net-next 03/13] net: introduce generic switch
	devices support
Date: Wed,  3 Sep 2014 11:24:50 +0200
Message-ID: <1409736300-12303-4-git-send-email-jiri@resnulli.us>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1409736300-12303-1-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
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
chips. Drivers should implement relevant ndos to do so. Now there is a
couple of ndos defines:
- for getting physical switch id is in place.
- for work with flows.

Note that user can use random port netdevice to access the switch.

Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
---
 Documentation/networking/switchdev.txt |  53 ++++++++++
 MAINTAINERS                            |   7 ++
 include/linux/netdevice.h              |  28 ++++++
 include/net/sw_flow.h                  |  14 +++
 include/net/switchdev.h                |  44 +++++++++
 net/Kconfig                            |   1 +
 net/Makefile                           |   3 +
 net/switchdev/Kconfig                  |   9 ++
 net/switchdev/Makefile                 |   5 +
 net/switchdev/switchdev.c              | 172 +++++++++++++++++++++++++++++++++
 10 files changed, 336 insertions(+)
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
index c9b4b55..4baaf44 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8808,6 +8808,13 @@ F:	lib/swiotlb.c
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
index 9faeea6..6a009d1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -46,9 +46,11 @@
 #include <net/dcbnl.h>
 #endif
 #include <net/netprio_cgroup.h>
+#include <net/sw_flow.h>
 
 #include <linux/netdev_features.h>
 #include <linux/neighbour.h>
+
 #include <uapi/linux/netdevice.h>
 
 struct netpoll_info;
@@ -997,6 +999,24 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	Callback to use for xmit over the accelerated station. This
  *	is used in place of ndo_start_xmit on accelerated net
  *	devices.
+ *
+ * int (*ndo_swdev_get_id)(struct net_device *dev,
+ *			   struct netdev_phys_item_id *psid);
+ *	Called to get an ID of the switch chip this port is part of.
+ *	If driver implements this, it indicates that it represents a port
+ *	of a switch chip.
+ *
+ * int (*ndo_swdev_flow_insert)(struct net_device *dev,
+ *				const struct sw_flow *flow);
+ *	Called to insert a flow into switch device. If driver does
+ *	not implement this, it is assumed that the hw does not have
+ *	a capability to work with flows.
+ *
+ * int (*ndo_swdev_flow_remove)(struct net_device *dev,
+ *				const struct sw_flow *flow);
+ *	Called to remove a flow from switch device. If driver does
+ *	not implement this, it is assumed that the hw does not have
+ *	a capability to work with flows.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1146,6 +1166,14 @@ struct net_device_ops {
 							struct net_device *dev,
 							void *priv);
 	int			(*ndo_get_lock_subclass)(struct net_device *dev);
+#ifdef CONFIG_NET_SWITCHDEV
+	int			(*ndo_swdev_get_id)(struct net_device *dev,
+						    struct netdev_phys_item_id *psid);
+	int			(*ndo_swdev_flow_insert)(struct net_device *dev,
+							 const struct sw_flow *flow);
+	int			(*ndo_swdev_flow_remove)(struct net_device *dev,
+							 const struct sw_flow *flow);
+#endif
 };
 
 /**
diff --git a/include/net/sw_flow.h b/include/net/sw_flow.h
index 21724f1..3af7758 100644
--- a/include/net/sw_flow.h
+++ b/include/net/sw_flow.h
@@ -81,7 +81,21 @@ struct sw_flow_mask {
 	struct sw_flow_key key;
 };
 
+enum sw_flow_action_type {
+	SW_FLOW_ACTION_TYPE_OUTPUT,
+	SW_FLOW_ACTION_TYPE_VLAN_PUSH,
+	SW_FLOW_ACTION_TYPE_VLAN_POP,
+};
+
 struct sw_flow_action {
+	enum sw_flow_action_type type;
+	union {
+		u32 out_port_ifindex;
+		struct {
+			__be16 vlan_proto;
+			u16 vlan_tci;
+		} vlan;
+	};
 };
 
 struct sw_flow_actions {
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
new file mode 100644
index 0000000..098784b
--- /dev/null
+++ b/include/net/switchdev.h
@@ -0,0 +1,44 @@
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
+#include <net/sw_flow.h>
+
+#ifdef CONFIG_NET_SWITCHDEV
+
+int swdev_get_id(struct net_device *dev, struct netdev_phys_item_id *psid);
+int swdev_flow_insert(struct net_device *dev, const struct sw_flow *flow);
+int swdev_flow_remove(struct net_device *dev, const struct sw_flow *flow);
+
+#else
+
+static inline int swdev_get_id(struct net_device *dev,
+			       struct netdev_phys_item_id *psid)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int swdev_flow_insert(struct net_device *dev,
+				    const struct sw_flow *flow)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int swdev_flow_remove(struct net_device *dev,
+				    const struct sw_flow *flow)
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
index 0000000..e079707
--- /dev/null
+++ b/net/switchdev/switchdev.c
@@ -0,0 +1,172 @@
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
+#include <net/sw_flow.h>
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
+
+static void print_flow_key_tun(const char *prefix,
+			       const struct sw_flow_key *key)
+{
+	pr_debug("%s tun  { id %08llx, s %pI4, d %pI4, f %02x, tos %x, ttl %x }\n",
+		 prefix,
+		 be64_to_cpu(key->tun_key.tun_id), &key->tun_key.ipv4_src,
+		 &key->tun_key.ipv4_dst, ntohs(key->tun_key.tun_flags),
+		 key->tun_key.ipv4_tos, key->tun_key.ipv4_ttl);
+}
+
+static void print_flow_key_phy(const char *prefix,
+			       const struct sw_flow_key *key)
+{
+	pr_debug("%s phy  { prio %08x, mark %04x, in_port %02x }\n",
+		 prefix,
+		 key->phy.priority, key->phy.skb_mark, key->phy.in_port);
+}
+
+static void print_flow_key_eth(const char *prefix,
+			       const struct sw_flow_key *key)
+{
+	pr_debug("%s eth  { sm %pM, dm %pM, tci %04x, type %04x }\n",
+		 prefix,
+		 key->eth.src, key->eth.dst, ntohs(key->eth.tci),
+		 ntohs(key->eth.type));
+}
+
+static void print_flow_key_ip(const char *prefix,
+			      const struct sw_flow_key *key)
+{
+	pr_debug("%s ip   { proto %02x, tos %02x, ttl %02x }\n",
+		 prefix,
+		 key->ip.proto, key->ip.tos, key->ip.ttl);
+}
+
+static void print_flow_key_ipv4(const char *prefix,
+				const struct sw_flow_key *key)
+{
+	pr_debug("%s ipv4 { si %pI4, di %pI4, sm %pM, dm %pM }\n",
+		 prefix,
+		 &key->ipv4.addr.src, &key->ipv4.addr.dst,
+		 key->ipv4.arp.sha, key->ipv4.arp.tha);
+}
+
+static void print_flow_key_misc(const char *prefix,
+				const struct sw_flow_key *key)
+{
+	pr_debug("%s misc { in_port_ifindex %08x }\n",
+		 prefix,
+		 key->misc.in_port_ifindex);
+}
+
+static void print_flow_actions(struct sw_flow_actions *actions)
+{
+	int i;
+
+	pr_debug("  actions:\n");
+	if (!actions)
+		return;
+	for (i = 0; i < actions->count; i++) {
+		struct sw_flow_action *action = &actions->actions[i];
+
+		switch (action->type) {
+		case SW_FLOW_ACTION_TYPE_OUTPUT:
+			pr_debug("    output    { ifindex %u }\n",
+				 action->out_port_ifindex);
+			break;
+		case SW_FLOW_ACTION_TYPE_VLAN_PUSH:
+			pr_debug("    vlan push { proto %04x, tci %04x }\n",
+				 ntohs(action->vlan.vlan_proto),
+				 ntohs(action->vlan.vlan_tci));
+			break;
+		case SW_FLOW_ACTION_TYPE_VLAN_POP:
+			pr_debug("    vlan pop\n");
+			break;
+		}
+	}
+}
+
+#define PREFIX_NONE "      "
+#define PREFIX_MASK "  mask"
+
+static void print_flow(const struct sw_flow *flow, struct net_device *dev,
+		       const char *comment)
+{
+	pr_debug("%s flow %s (%x-%x):\n", dev->name, comment,
+		 flow->mask->range.start, flow->mask->range.end);
+	print_flow_key_tun(PREFIX_NONE, &flow->key);
+	print_flow_key_tun(PREFIX_MASK, &flow->mask->key);
+	print_flow_key_phy(PREFIX_NONE, &flow->key);
+	print_flow_key_phy(PREFIX_MASK, &flow->mask->key);
+	print_flow_key_eth(PREFIX_NONE, &flow->key);
+	print_flow_key_eth(PREFIX_MASK, &flow->mask->key);
+	print_flow_key_ip(PREFIX_NONE, &flow->key);
+	print_flow_key_ip(PREFIX_MASK, &flow->mask->key);
+	print_flow_key_ipv4(PREFIX_NONE, &flow->key);
+	print_flow_key_ipv4(PREFIX_MASK, &flow->mask->key);
+	print_flow_actions(flow->actions);
+}
+
+/**
+ *	swdev_flow_insert - Insert a flow into switch
+ *	@dev: port device
+ *	@flow: flow descriptor
+ *
+ *	Insert a flow into switch this port is part of.
+ */
+int swdev_flow_insert(struct net_device *dev, const struct sw_flow *flow)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	print_flow(flow, dev, "insert");
+	if (!ops->ndo_swdev_flow_insert)
+		return -EOPNOTSUPP;
+	WARN_ON(!ops->ndo_swdev_get_id);
+	BUG_ON(!flow->actions);
+	return ops->ndo_swdev_flow_insert(dev, flow);
+}
+EXPORT_SYMBOL(swdev_flow_insert);
+
+/**
+ *	swdev_flow_remove - Remove a flow from switch
+ *	@dev: port device
+ *	@flow: flow descriptor
+ *
+ *	Remove a flow from switch this port is part of.
+ */
+int swdev_flow_remove(struct net_device *dev, const struct sw_flow *flow)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	print_flow(flow, dev, "remove");
+	if (!ops->ndo_swdev_flow_remove)
+		return -EOPNOTSUPP;
+	WARN_ON(!ops->ndo_swdev_get_id);
+	return ops->ndo_swdev_flow_remove(dev, flow);
+}
+EXPORT_SYMBOL(swdev_flow_remove);
-- 
1.9.3
