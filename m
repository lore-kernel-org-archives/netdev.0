From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v4 3/7] swdevice: add new apis to set and del bridge port attributes
Date: Thu, 29 Jan 2015 22:40:13 -0800
Message-ID: <1422600017-42393-4-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	ronen.arad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:42337 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbbA3Gk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 01:40:26 -0500
Received: by mail-pa0-f51.google.com with SMTP id fb1so48772541pad.10
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 22:40:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds two new api's netdev_switch_port_bridge_setlink
and netdev_switch_port_bridge_dellink to offload bridge port attributes
to switch port

(The names of the apis look odd with 'switch_port_bridge',
but am more inclined to change the prefix of the api to something else.
Will take any suggestions).

The api's look at the NETIF_F_HW_SWITCH_OFFLOAD feature flag to
pass bridge port attributes to the port device.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/net/switchdev.h   |   37 ++++++++++++++-
 net/switchdev/switchdev.c |  110 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 146 insertions(+), 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 205e636..cfcdac2 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -43,7 +43,14 @@ int register_netdev_switch_notifier(struct notifier_block *nb);
 int unregister_netdev_switch_notifier(struct notifier_block *nb);
 int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
 				 struct netdev_switch_notifier_info *info);
-
+int netdev_switch_port_bridge_setlink(struct net_device *dev,
+				struct nlmsghdr *nlh, u16 flags);
+int netdev_switch_port_bridge_dellink(struct net_device *dev,
+				struct nlmsghdr *nlh, u16 flags);
+int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
+					       struct nlmsghdr *nlh, u16 flags);
+int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
+					       struct nlmsghdr *nlh, u16 flags);
 #else
 
 static inline int netdev_switch_parent_id_get(struct net_device *dev,
@@ -74,6 +81,34 @@ static inline int call_netdev_switch_notifiers(unsigned long val, struct net_dev
 	return NOTIFY_DONE;
 }
 
+static inline int netdev_switch_port_bridge_setlink(struct net_device *dev,
+						    struct nlmsghdr *nlh,
+						    u16 flags)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int netdev_switch_port_bridge_dellink(struct net_device *dev,
+						    struct nlmsghdr *nlh,
+						    u16 flags)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
+							struct nlmsghdr *nlh,
+							u16 flags)
+{
+	return 0;
+}
+
+static inline int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
+							struct nlmsghdr *nlh,
+							u16 flags)
+{
+	return 0;
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 22e02f4..8c1e558 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -115,3 +115,113 @@ int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
 	return err;
 }
 EXPORT_SYMBOL(call_netdev_switch_notifiers);
+
+/**
+ *	netdev_switch_port_bridge_setlink - Notify switch device port of bridge
+ *	port attributes
+ *
+ *	@dev: port device
+ *	@nlh: netlink msg with bridge port attributes
+ *	@flags: bridge setlink flags
+ *
+ *	Notify switch device port of bridge port attributes
+ */
+int netdev_switch_port_bridge_setlink(struct net_device *dev,
+				      struct nlmsghdr *nlh, u16 flags)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
+		return 0;
+
+	if (!ops->ndo_bridge_setlink)
+		return -EOPNOTSUPP;
+
+	return ops->ndo_bridge_setlink(dev, nlh, flags);
+}
+EXPORT_SYMBOL(netdev_switch_port_bridge_setlink);
+
+/**
+ *	netdev_switch_port_bridge_dellink - Notify switch device port of bridge
+ *	port attribute delete
+ *
+ *	@dev: port device
+ *	@nlh: netlink msg with bridge port attributes
+ *	@flags: bridge setlink flags
+ *
+ *	Notify switch device port of bridge port attribute delete
+ */
+int netdev_switch_port_bridge_dellink(struct net_device *dev,
+				      struct nlmsghdr *nlh, u16 flags)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
+		return 0;
+
+	if (!ops->ndo_bridge_dellink)
+		return -EOPNOTSUPP;
+
+	return ops->ndo_bridge_dellink(dev, nlh, flags);
+}
+EXPORT_SYMBOL(netdev_switch_port_bridge_dellink);
+
+/**
+ *	ndo_dflt_netdev_switch_port_bridge_setlink - default ndo bridge setlink
+ *						     op for master devices
+ *
+ *	@dev: port device
+ *	@nlh: netlink msg with bridge port attributes
+ *	@flags: bridge setlink flags
+ *
+ *	Notify master device slaves of bridge port attributes
+ */
+int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
+					       struct nlmsghdr *nlh, u16 flags)
+{
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	int ret = 0, err = 0;
+
+	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
+		return ret;
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = netdev_switch_port_bridge_setlink(lower_dev, nlh, flags);
+		if (err && err != -EOPNOTSUPP)
+			ret = err;
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(ndo_dflt_netdev_switch_port_bridge_setlink);
+
+/**
+ *	ndo_dflt_netdev_switch_port_bridge_dellink - default ndo bridge dellink
+ *						     op for master devices
+ *
+ *	@dev: port device
+ *	@nlh: netlink msg with bridge port attributes
+ *	@flags: bridge dellink flags
+ *
+ *	Notify master device slaves of bridge port attribute deletes
+ */
+int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
+					       struct nlmsghdr *nlh, u16 flags)
+{
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	int ret = 0, err = 0;
+
+	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
+		return ret;
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = netdev_switch_port_bridge_dellink(lower_dev, nlh, flags);
+		if (err && err != -EOPNOTSUPP)
+			ret = err;
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(ndo_dflt_netdev_switch_port_bridge_dellink);
-- 
1.7.10.4
