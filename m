From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC v2 4/6] net: introduce switchdev API
Date: Wed, 26 Mar 2014 17:31:10 +0100
Message-ID: <1395851472-10524-5-git-send-email-jiri@resnulli.us>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:59076 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755593AbaCZQba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 12:31:30 -0400
Received: by mail-ee0-f41.google.com with SMTP id t10so1891058eei.28
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 09:31:29 -0700 (PDT)
In-Reply-To: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

switchdev API is designed to allow kernel support for various switch
chips.

It is the responsibility of a driver to create netdevice instances which
represents every port and for the switch master itself. Driver uses
swdev_register and swportdev_register functions to make the core aware
of the fact these netdevices are representing switch and switch ports.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h |  24 +++++++
 include/linux/switchdev.h |  30 ++++++++
 net/Kconfig               |  10 +++
 net/core/Makefile         |   1 +
 net/core/switchdev.c      | 172 ++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 237 insertions(+)
 create mode 100644 include/linux/switchdev.h
 create mode 100644 net/core/switchdev.c

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6b70e6f..5ad80da 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -49,6 +49,8 @@
 
 #include <linux/netdev_features.h>
 #include <linux/neighbour.h>
+#include <linux/sw_flow.h>
+
 #include <uapi/linux/netdevice.h>
 
 struct netpoll_info;
@@ -998,6 +1000,18 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	Callback to use for xmit over the accelerated station. This
  *	is used in place of ndo_start_xmit on accelerated net
  *	devices.
+ *
+ * int (*ndo_swdev_flow_insert)(struct net_device *dev,
+ *				struct sw_flow *flow);
+ *	Called to insert a flow into switch device. If driver does
+ *	not implement this, it is assumed that the hw does not have
+ *	a capability to work with flows.
+ *
+ * int (*ndo_swdev_flow_remove)(struct net_device *dev,
+ *				struct sw_flow *flow);
+ *	Called to remove a flow from switch device. If driver does
+ *	not implement this, it is assumed that the hw does not have
+ *	a capability to work with flows.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1145,6 +1159,12 @@ struct net_device_ops {
 	netdev_tx_t		(*ndo_dfwd_start_xmit) (struct sk_buff *skb,
 							struct net_device *dev,
 							void *priv);
+#if IS_ENABLED(CONFIG_NET_SWITCHDEV)
+	int			(*ndo_swdev_flow_insert)(struct net_device *dev,
+							 struct sw_flow *flow);
+	int			(*ndo_swdev_flow_remove)(struct net_device *dev,
+							 struct sw_flow *flow);
+#endif
 };
 
 /**
@@ -1205,6 +1225,8 @@ enum netdev_priv_flags {
 	IFF_SUPP_NOFCS			= 1<<19,
 	IFF_LIVE_ADDR_CHANGE		= 1<<20,
 	IFF_MACVLAN			= 1<<21,
+	IFF_SWITCH			= 1<<22,
+	IFF_SWITCH_PORT			= 1<<23,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -1229,6 +1251,8 @@ enum netdev_priv_flags {
 #define IFF_SUPP_NOFCS			IFF_SUPP_NOFCS
 #define IFF_LIVE_ADDR_CHANGE		IFF_LIVE_ADDR_CHANGE
 #define IFF_MACVLAN			IFF_MACVLAN
+#define IFF_SWITCH			IFF_SWITCH
+#define IFF_SWITCH_PORT			IFF_SWITCH_PORT
 
 /*
  *	The DEVICE structure.
diff --git a/include/linux/switchdev.h b/include/linux/switchdev.h
new file mode 100644
index 0000000..e4aeaba
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
+bool swdev_dev_check(const struct net_device *dev);
+int swdev_flow_insert(struct net_device *dev, struct sw_flow *flow);
+int swdev_flow_remove(struct net_device *dev, struct sw_flow *flow);
+int __swdev_register(struct net_device *dev);
+int swdev_register(struct net_device *dev);
+void __swdev_unregister(struct net_device *dev);
+void swdev_unregister(struct net_device *dev);
+
+bool swportdev_dev_check(const struct net_device *dev);
+int __swportdev_register(struct net_device *port_dev, struct net_device *dev);
+int swportdev_register(struct net_device *port_dev, struct net_device *dev);
+void __swportdev_unregister(struct net_device *port_dev);
+void swportdev_unregister(struct net_device *port_dev);
+
+#endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/Kconfig b/net/Kconfig
index e411046..e02ab8d 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -285,6 +285,16 @@ config NET_FLOW_LIMIT
 	  with many clients some protection against DoS by a single (spoofed)
 	  flow that greatly exceeds average workload.
 
+config NET_SWITCHDEV
+	tristate "Switch device"
+	depends on INET
+	---help---
+	  This module provides glue for hardware switch chips so they can be
+	  accessed from userspace via Open vSwitch Netlink API. 
+
+	  To compile this code as a module, choose M here: the
+	  module will be called pktgen.
+
 menu "Network testing"
 
 config NET_PKTGEN
diff --git a/net/core/Makefile b/net/core/Makefile
index 9628c20..426a619 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -23,3 +23,4 @@ obj-$(CONFIG_NET_DROP_MONITOR) += drop_monitor.o
 obj-$(CONFIG_NETWORK_PHY_TIMESTAMPING) += timestamping.o
 obj-$(CONFIG_CGROUP_NET_PRIO) += netprio_cgroup.o
 obj-$(CONFIG_CGROUP_NET_CLASSID) += netclassid_cgroup.o
+obj-$(CONFIG_NET_SWITCHDEV) += switchdev.o
diff --git a/net/core/switchdev.c b/net/core/switchdev.c
new file mode 100644
index 0000000..ccd4fbc
--- /dev/null
+++ b/net/core/switchdev.c
@@ -0,0 +1,172 @@
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
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/switchdev.h>
+#include <net/rtnetlink.h>
+
+bool swdev_dev_check(const struct net_device *dev)
+{
+	return dev->priv_flags & IFF_SWITCH;
+}
+EXPORT_SYMBOL(swdev_dev_check);
+
+int swdev_flow_insert(struct net_device *dev, struct sw_flow *flow)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	BUG_ON(!swdev_dev_check(dev));
+	if (!ops->ndo_swdev_flow_insert)
+		return -EOPNOTSUPP;
+	return ops->ndo_swdev_flow_insert(dev, flow);
+}
+EXPORT_SYMBOL(swdev_flow_insert);
+
+int swdev_flow_remove(struct net_device *dev, struct sw_flow *flow)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	BUG_ON(!swdev_dev_check(dev));
+	if (!ops->ndo_swdev_flow_remove)
+		return -EOPNOTSUPP;
+	return ops->ndo_swdev_flow_remove(dev, flow);
+}
+EXPORT_SYMBOL(swdev_flow_remove);
+
+int __swdev_register(struct net_device *dev)
+{
+	if (dev->priv_flags & IFF_SWITCH) {
+		netdev_err(dev, "Device is already registered as a switch device\n");
+		return -EBUSY;
+	}
+	dev->priv_flags |= IFF_SWITCH;
+	netdev_info(dev, "Switch device registered\n");
+	return 0;
+}
+EXPORT_SYMBOL(__swdev_register);
+
+int swdev_register(struct net_device *dev)
+{
+	int err;
+
+	rtnl_lock();
+	err = __swdev_register(dev);
+	rtnl_unlock();
+	return err;
+}
+EXPORT_SYMBOL(swdev_register);
+
+void __swdev_unregister(struct net_device *dev)
+{
+	dev->priv_flags |= IFF_SWITCH;
+	netdev_info(dev, "Switch device unregistered\n");
+}
+EXPORT_SYMBOL(__swdev_unregister);
+
+void swdev_unregister(struct net_device *dev)
+{
+	rtnl_lock();
+	__swdev_unregister(dev);
+	rtnl_unlock();
+}
+EXPORT_SYMBOL(swdev_unregister);
+
+
+bool swportdev_dev_check(const struct net_device *port_dev)
+{
+	return port_dev->priv_flags & IFF_SWITCH_PORT;
+}
+EXPORT_SYMBOL(swportdev_dev_check);
+
+static rx_handler_result_t swportdev_handle_frame(struct sk_buff **pskb)
+{
+	struct sk_buff *skb = *pskb;
+
+	/* We don't care what comes from port device into rx path.
+	 * If there's something there, it is destined to ETH_P_ALL
+	 * handlers. So just consume it.
+	 */
+	dev_kfree_skb(skb);
+	return RX_HANDLER_CONSUMED;
+}
+
+int __swportdev_register(struct net_device *port_dev, struct net_device *dev)
+{
+	int err;
+
+	if (!(dev->priv_flags & IFF_SWITCH)) {
+		netdev_err(dev, "Device is not a switch device\n");
+		return -EINVAL;
+	}
+	if (port_dev->priv_flags & IFF_SWITCH_PORT) {
+		netdev_err(port_dev, "Device is already registered as a switch port\n");
+		return -EBUSY;
+	}
+	err = netdev_master_upper_dev_link(port_dev, dev);
+	if (err) {
+		netdev_err(dev, "Device %s failed to set upper link\n",
+			   port_dev->name);
+		return err;
+	}
+	err = netdev_rx_handler_register(port_dev, swportdev_handle_frame, NULL);
+	if (err) {
+		netdev_err(dev, "Device %s failed to register rx_handler\n",
+			   port_dev->name);
+		goto err_handler_register;
+	}
+	port_dev->priv_flags |= IFF_SWITCH_PORT;
+	netdev_info(port_dev, "Switch port device registered\n");
+	return 0;
+
+err_handler_register:
+	netdev_upper_dev_unlink(port_dev, dev);
+	return err;
+}
+EXPORT_SYMBOL(__swportdev_register);
+
+int swportdev_register(struct net_device *port_dev, struct net_device *dev)
+{
+	int err;
+
+	rtnl_lock();
+	err = __swportdev_register(port_dev, dev);
+	rtnl_unlock();
+	return err;
+}
+EXPORT_SYMBOL(swportdev_register);
+
+void __swportdev_unregister(struct net_device *port_dev)
+{
+	struct net_device *dev;
+
+	dev = netdev_master_upper_dev_get(port_dev);
+	BUG_ON(!dev);
+	port_dev->priv_flags &= ~IFF_SWITCH_PORT;
+	netdev_rx_handler_unregister(port_dev);
+	netdev_upper_dev_unlink(port_dev, dev);
+	netdev_info(port_dev, "Switch port device unregistered\n");
+}
+EXPORT_SYMBOL(__swportdev_unregister);
+
+void swportdev_unregister(struct net_device *port_dev)
+{
+	rtnl_lock();
+	__swportdev_unregister(port_dev);
+	rtnl_unlock();
+}
+EXPORT_SYMBOL(swportdev_unregister);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Jiri Pirko <jiri@resnulli.us>");
+MODULE_DESCRIPTION("Switch device API");
-- 
1.8.5.3
