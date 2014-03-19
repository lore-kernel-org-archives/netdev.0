From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 2/4] net: introduce switchdev API
Date: Wed, 19 Mar 2014 16:33:50 +0100
Message-ID: <1395243232-32630-3-git-send-email-jiri@resnulli.us>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:47979 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965437AbaCSPeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 11:34:03 -0400
Received: by mail-ee0-f54.google.com with SMTP id d49so6725365eek.41
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 08:34:01 -0700 (PDT)
In-Reply-To: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

switchdev API is designed to allow kernel support for various switch
chips.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/switchdev.h |  62 +++++++++
 net/Kconfig               |  10 ++
 net/core/Makefile         |   1 +
 net/core/switchdev.c      | 330 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 403 insertions(+)
 create mode 100644 include/linux/switchdev.h
 create mode 100644 net/core/switchdev.c

diff --git a/include/linux/switchdev.h b/include/linux/switchdev.h
new file mode 100644
index 0000000..ac6db2d
--- /dev/null
+++ b/include/linux/switchdev.h
@@ -0,0 +1,62 @@
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
+struct swdev_linked_ops {
+};
+
+bool swdev_dev_check(const struct net_device *dev);
+void swdev_link(struct net_device *dev,
+		const struct swdev_linked_ops *linked_ops,
+		void *linked_priv);
+void swdev_unlink(struct net_device *dev);
+void *swdev_linked_priv(const struct net_device *dev);
+bool swdev_is_linked(const struct net_device *dev);
+int swdev_flow_insert(struct net_device *dev, struct sw_flow *flow);
+int swdev_flow_remove(struct net_device *dev, struct sw_flow *flow);
+int swdev_packet_upcall(struct net_device *dev, struct sk_buff *skb);
+
+struct swdev_ops {
+	const char *kind;
+	int (*flow_insert)(struct net_device *dev, struct sw_flow *flow);
+	int (*flow_remove)(struct net_device *dev, struct sw_flow *flow);
+};
+
+struct net_device *swdev_create(const struct swdev_ops *ops);
+void swdev_destroy(struct net_device *dev);
+
+struct swportdev_linked_ops {
+	void (*skb_upcall)(struct net_device *dev, struct sk_buff *skb,
+			   struct sw_flow_key *key, void *linked_priv);
+};
+
+bool swportdev_dev_check(const struct net_device *dev);
+void swportdev_link(struct net_device *dev,
+		    const struct swportdev_linked_ops *linked_ops,
+		    void *linked_priv);
+void swportdev_unlink(struct net_device *dev);
+void *swportdev_linked_priv(const struct net_device *dev);
+bool swportdev_is_linked(const struct net_device *dev);
+
+struct swportdev_ops {
+	const char *kind;
+	netdev_tx_t (*skb_xmit)(struct sk_buff *skb,
+				struct net_device *port_dev);
+};
+
+struct net_device *swportdev_create(struct net_device *dev,
+				    const struct swportdev_ops *ops);
+void swportdev_destroy(struct net_device *port_dev);
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
index 0000000..3b8daaf
--- /dev/null
+++ b/net/core/switchdev.c
@@ -0,0 +1,330 @@
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
+#include <linux/ethtool.h>
+#include <linux/switchdev.h>
+
+#include <net/rtnetlink.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+
+#include <generated/utsrelease.h>
+
+struct swdev {
+	const struct swdev_ops *ops;
+	const struct swdev_linked_ops *linked_ops;
+	void *linked_priv;
+};
+
+static netdev_tx_t swdev_ndo_start_xmit(struct sk_buff *skb,
+					struct net_device *dev)
+{
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+static const struct net_device_ops swdev_netdev_ops = {
+	.ndo_start_xmit = swdev_ndo_start_xmit,
+};
+
+static void swdev_ethtool_get_drvinfo(struct net_device *dev,
+				      struct ethtool_drvinfo *drvinfo)
+{
+	struct swdev *sw = netdev_priv(dev);
+
+	strlcpy(drvinfo->driver, sw->ops->kind, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, UTS_RELEASE, sizeof(drvinfo->version));
+}
+
+static const struct ethtool_ops swdev_ethtool_ops = {
+	.get_drvinfo		= swdev_ethtool_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+};
+
+static void swdev_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+	dev->netdev_ops = &swdev_netdev_ops;
+	dev->ethtool_ops = &swdev_ethtool_ops;
+}
+
+bool swdev_dev_check(const struct net_device *dev)
+{
+	return dev->netdev_ops == &swdev_netdev_ops;
+}
+EXPORT_SYMBOL(swdev_dev_check);
+
+void swdev_link(struct net_device *dev,
+		const struct swdev_linked_ops *linked_ops,
+		void *linked_priv)
+{
+	struct swdev *sw = netdev_priv(dev);
+
+	sw->linked_ops = linked_ops;
+	sw->linked_priv = linked_priv;
+	netdev_info(dev, "Switch device linked\n");
+}
+EXPORT_SYMBOL(swdev_link);
+
+void swdev_unlink(struct net_device *dev)
+{
+	struct swdev *sw = netdev_priv(dev);
+
+	sw->linked_ops = NULL;
+	sw->linked_priv = NULL;
+	netdev_info(dev, "Switch device unlinked\n");
+}
+EXPORT_SYMBOL(swdev_unlink);
+
+void *swdev_linked_priv(const struct net_device *dev)
+{
+	struct swdev *sw = netdev_priv(dev);
+
+	return sw->linked_priv;
+}
+EXPORT_SYMBOL(swdev_linked_priv);
+
+bool swdev_is_linked(const struct net_device *dev)
+{
+	return swdev_linked_priv(dev);
+}
+EXPORT_SYMBOL(swdev_is_linked);
+
+int swdev_flow_insert(struct net_device *dev, struct sw_flow *flow)
+{
+	struct swdev *sw = netdev_priv(dev);
+
+	BUG_ON(!swdev_dev_check(dev));
+	if (!sw->ops->flow_insert)
+		return 0;
+	return sw->ops->flow_insert(dev, flow);
+}
+EXPORT_SYMBOL(swdev_flow_insert);
+
+int swdev_flow_remove(struct net_device *dev, struct sw_flow *flow)
+{
+	struct swdev *sw = netdev_priv(dev);
+
+	BUG_ON(!swdev_dev_check(dev));
+	if (!sw->ops->flow_remove)
+		return 0;
+	return sw->ops->flow_remove(dev, flow);
+}
+EXPORT_SYMBOL(swdev_flow_remove);
+
+struct net_device *swdev_create(const struct swdev_ops *ops)
+{
+	struct net_device *dev;
+	struct swdev *sw;
+	int err;
+
+	dev = alloc_netdev(sizeof(struct swdev), "swdev%d", swdev_setup);
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	err = register_netdevice(dev);
+	if (err)
+		goto err_register_netdevice;
+	sw = netdev_priv(dev);
+	sw->ops = ops;
+	netif_carrier_off(dev);
+	netdev_info(dev, "Switch device created (%s)\n", sw->ops->kind);
+	return dev;
+
+err_register_netdevice:
+	free_netdev(dev);
+	return ERR_PTR(err);
+}
+EXPORT_SYMBOL(swdev_create);
+
+void swdev_destroy(struct net_device *dev)
+{
+	unregister_netdevice(dev);
+	free_netdev(dev);
+	netdev_info(dev, "Switch device destroyed\n");
+}
+EXPORT_SYMBOL(swdev_destroy);
+
+
+struct swportdev {
+	const struct swportdev_ops *ops;
+	const struct swportdev_linked_ops *linked_ops;
+	void *linked_priv;
+};
+
+static netdev_tx_t swportdev_ndo_start_xmit(struct sk_buff *skb,
+					    struct net_device *port_dev)
+{
+	struct swportdev *swp = netdev_priv(port_dev);
+
+	return swp->ops->skb_xmit(skb, port_dev);
+}
+
+static const struct net_device_ops swportdev_netdev_ops = {
+	.ndo_start_xmit = swportdev_ndo_start_xmit,
+};
+
+static void swportdev_ethtool_get_drvinfo(struct net_device *port_dev,
+					  struct ethtool_drvinfo *drvinfo)
+{
+	struct swportdev *swp = netdev_priv(port_dev);
+
+	strlcpy(drvinfo->driver, swp->ops->kind, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, UTS_RELEASE, sizeof(drvinfo->version));
+}
+
+static const struct ethtool_ops swportdev_ethtool_ops = {
+	.get_drvinfo		= swportdev_ethtool_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+};
+static void swportdev_setup(struct net_device *port_dev)
+{
+	ether_setup(port_dev);
+	port_dev->netdev_ops = &swportdev_netdev_ops;
+	port_dev->ethtool_ops = &swportdev_ethtool_ops;
+}
+
+bool swportdev_dev_check(const struct net_device *port_dev)
+{
+	return port_dev->netdev_ops == &swportdev_netdev_ops;
+}
+EXPORT_SYMBOL(swportdev_dev_check);
+
+void swportdev_link(struct net_device *port_dev,
+		    const struct swportdev_linked_ops *linked_ops,
+		    void *linked_priv)
+{
+	struct swportdev *swp = netdev_priv(port_dev);
+
+	swp->linked_priv = linked_priv;
+	netdev_info(port_dev, "Switch port device linked\n");
+}
+EXPORT_SYMBOL(swportdev_link);
+
+void swportdev_unlink(struct net_device *port_dev)
+{
+	struct swportdev *swp = netdev_priv(port_dev);
+
+	swp->linked_ops = NULL;
+	swp->linked_priv = NULL;
+	netdev_info(port_dev, "Switch port device unlinked\n");
+}
+EXPORT_SYMBOL(swportdev_unlink);
+
+void *swportdev_linked_priv(const struct net_device *port_dev)
+{
+	struct swportdev *swp = netdev_priv(port_dev);
+
+	return swp->linked_priv;
+}
+EXPORT_SYMBOL(swportdev_linked_priv);
+
+bool swportdev_is_linked(const struct net_device *port_dev)
+{
+	return swportdev_linked_priv(port_dev);
+}
+EXPORT_SYMBOL(swportdev_is_linked);
+
+void swportdev_skb_upcall(struct net_device *dev, struct sk_buff *skb,
+			  struct sw_flow_key *key, void *linked_priv)
+{
+	struct swportdev *swp = netdev_priv(dev);
+
+	BUG_ON(!swportdev_dev_check(dev));
+	if (!swp->linked_ops->skb_upcall)
+		return;
+	swp->linked_ops->skb_upcall(dev, skb, key, swp->linked_priv);
+}
+EXPORT_SYMBOL(swportdev_skb_upcall);
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
+struct net_device *swportdev_create(struct net_device *dev,
+				    const struct swportdev_ops *ops)
+{
+	struct net_device *port_dev;
+	char name[IFNAMSIZ];
+	struct swportdev *swp;
+	int err;
+
+	err = snprintf(name, IFNAMSIZ, "%sp%%d", dev->name);
+	if (err >= IFNAMSIZ)
+		return ERR_PTR(-EINVAL);
+
+	port_dev = alloc_netdev(sizeof(struct swportdev), name, swportdev_setup);
+	if (!port_dev)
+		return ERR_PTR(-ENOMEM);
+
+	err = register_netdevice(port_dev);
+	if (err)
+		goto err_register_netdevice;
+
+	err = netdev_master_upper_dev_link(port_dev, dev);
+	if (err) {
+		netdev_err(dev, "Device %s failed to set upper link\n",
+			   port_dev->name);
+		goto err_set_upper_link;
+	}
+	swp = netdev_priv(port_dev);
+	err = netdev_rx_handler_register(port_dev, swportdev_handle_frame, swp);
+	if (err) {
+		netdev_err(dev, "Device %s failed to register rx_handler\n",
+			   port_dev->name);
+		goto err_handler_register;
+	}
+
+	swp = netdev_priv(port_dev);
+	swp->ops = ops;
+	netif_carrier_off(port_dev);
+	netdev_info(port_dev, "Switch port device created (%s)\n", swp->ops->kind);
+	return port_dev;
+
+err_handler_register:
+	netdev_upper_dev_unlink(port_dev, dev);
+err_set_upper_link:
+	unregister_netdevice(port_dev);
+err_register_netdevice:
+	free_netdev(port_dev);
+	return ERR_PTR(err);
+}
+EXPORT_SYMBOL(swportdev_create);
+
+void swportdev_destroy(struct net_device *port_dev)
+{
+	struct net_device *dev;
+
+	dev = netdev_master_upper_dev_get(port_dev);
+	BUG_ON(!dev);
+	netdev_rx_handler_unregister(port_dev);
+	netdev_upper_dev_unlink(port_dev, dev);
+	unregister_netdevice(port_dev);
+	free_netdev(port_dev);
+	netdev_info(port_dev, "Switch port device destroyed\n");
+}
+EXPORT_SYMBOL(swportdev_destroy);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Jiri Pirko <jiri@resnulli.us>");
+MODULE_DESCRIPTION("Switch device API");
-- 
1.8.5.3
