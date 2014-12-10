From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v2 2/4] swdevice: add new api to set and del bridge port attributes
Date: Wed, 10 Dec 2014 01:05:18 -0800
Message-ID: <1418202320-19491-3-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:57147 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbaLJJFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 04:05:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds two new api's netdev_switch_port_bridge_setlink
and netdev_switch_port_bridge_dellink to offload bridge port attributes
to switch asic

(The names of the apis look odd with 'switch_port_bridge',
but am more inclined to change the prefix of the api to something else.
Will take any suggestions).

The api's look at the NETIF_F_HW_NETFUNC_OFFLOAD feature flag to
pass bridge port attributes to the port device.

If the device has the NETIF_F_HW_NETFUNC_OFFLOAD, but does not support
the bridge port attribute offload ndo, call bridge port attribute ndo's on
the lowerdevs if supported. This is one way to pass bridge port attributes
through stacked netdevs (example when bridge port is a bond and bond slaves
are switch ports).

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/net/switchdev.h   |    5 +++-
 net/switchdev/switchdev.c |   70 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 74 insertions(+), 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 8a6d164..22676b6 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -17,7 +17,10 @@
 int netdev_switch_parent_id_get(struct net_device *dev,
 				struct netdev_phys_item_id *psid);
 int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
-
+int netdev_switch_port_bridge_setlink(struct net_device *dev,
+				struct nlmsghdr *nlh, u16 flags);
+int netdev_switch_port_bridge_dellink(struct net_device *dev,
+				struct nlmsghdr *nlh, u16 flags);
 #else
 
 static inline int netdev_switch_parent_id_get(struct net_device *dev,
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index d162b21..62317e1 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -50,3 +50,73 @@ int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
 	return ops->ndo_switch_port_stp_update(dev, state);
 }
 EXPORT_SYMBOL(netdev_switch_port_stp_update);
+
+/**
+ *	netdev_switch_port_bridge_setlink - Notify switch device port of bridge
+ *	port attributes
+ *
+ *	@dev: port device
+ *	@nlh: netlink msg with bridge port attributes
+ *
+ *	Notify switch device port of bridge port attributes
+ */
+int netdev_switch_port_bridge_setlink(struct net_device *dev,
+									  struct nlmsghdr *nlh, u16 flags)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	int ret = 0, err = 0;
+
+	if (!(dev->features & NETIF_F_HW_NETFUNC_OFFLOAD))
+		return err;
+
+	if (ops->ndo_bridge_setlink) {
+	    WARN_ON(!ops->ndo_switch_parent_id_get);
+	    return ops->ndo_bridge_setlink(dev, nlh, flags);
+	}
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = netdev_switch_port_bridge_setlink(lower_dev, nlh, flags);
+		if (err)
+			ret = err;
+    }
+
+	return ret;
+}
+EXPORT_SYMBOL(netdev_switch_port_bridge_setlink);
+
+/**
+ *	netdev_switch_port_bridge_dellink - Notify switch device port of bridge
+ *	attribute delete
+ *
+ *	@dev: port device
+ *	@nlh: netlink msg with bridge port attributes
+ *
+ *	Notify switch device port of bridge port attribute delete
+ */
+int netdev_switch_port_bridge_dellink(struct net_device *dev,
+									  struct nlmsghdr *nlh, u16 flags)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	int ret = 0, err = 0;
+
+	if (!(dev->features & NETIF_F_HW_NETFUNC_OFFLOAD))
+		return err;
+
+	if (ops->ndo_bridge_dellink) {
+		WARN_ON(!ops->ndo_switch_parent_id_get);
+		return ops->ndo_bridge_dellink(dev, nlh, flags);
+	}
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = netdev_switch_port_bridge_dellink(lower_dev, nlh, flags);
+		if (err)
+			ret = err;
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(netdev_switch_port_bridge_dellink);
-- 
1.7.10.4
