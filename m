From: anuradhak@cumulusnetworks.com
Subject: [RFC PATCH net-next v3 2/4] switchdev: APIs for setting physical state of the switch port.
Date: Mon, 27 Apr 2015 10:38:22 -0700
Message-ID: <1430156304-13187-3-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:36180 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933012AbbD0Rif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 13:38:35 -0400
Received: by pdea3 with SMTP id a3so135638690pde.3
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 10:38:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

On detecting errors an application can set IFF_PROTO_DOWN on a device.
These switchdev APIs allow the switch device driver to react to
IFF_PROTO_DOWN by doing a phy down on the switch port. Doing this allows
the connected server to react quickly and prevent traffic black holing
in the network.

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
---
 include/net/switchdev.h   |   12 ++++++++++++
 net/core/dev.c            |    6 ++++++
 net/switchdev/switchdev.c |   23 +++++++++++++++++++++++
 3 files changed, 41 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index d2e69ee..5265e05 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -29,6 +29,9 @@ struct fib_info;
  * @swdev_fib_ipv4_add: Called to add/modify IPv4 route to switch device.
  *
  * @swdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
+
+ * @swdev_port_phy_state_set: Called to set the physical state of the switch
+ *   device port.
  */
 struct swdev_ops {
 	int	(*swdev_parent_id_get)(struct net_device *dev,
@@ -41,6 +44,8 @@ struct swdev_ops {
 	int	(*swdev_fib_ipv4_del)(struct net_device *dev, __be32 dst,
 				      int dst_len, struct fib_info *fi,
 				      u8 tos, u8 type, u32 tb_id);
+	int	(*swdev_port_phy_state_set)(struct net_device *dev,
+					    bool enable);
 };
 
 enum netdev_switch_notifier_type {
@@ -69,6 +74,7 @@ netdev_switch_notifier_info_to_dev(const struct netdev_switch_notifier_info *inf
 int netdev_switch_parent_id_get(struct net_device *dev,
 				struct netdev_phys_item_id *psid);
 int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
+int netdev_switch_port_phy_state_set(struct net_device *dev, bool enable);
 int register_netdev_switch_notifier(struct notifier_block *nb);
 int unregister_netdev_switch_notifier(struct notifier_block *nb);
 int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
@@ -101,6 +107,12 @@ static inline int netdev_switch_port_stp_update(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int netdev_switch_port_phy_state_set(struct net_device *dev,
+						bool enable)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int register_netdev_switch_notifier(struct notifier_block *nb)
 {
 	return 0;
diff --git a/net/core/dev.c b/net/core/dev.c
index e9600fa..8607ed8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -135,6 +135,7 @@
 #include <linux/if_macvlan.h>
 #include <linux/errqueue.h>
 #include <linux/hrtimer.h>
+#include <net/switchdev.h>
 
 #include "net-sysfs.h"
 
@@ -5770,6 +5771,11 @@ int __dev_change_flags(struct net_device *dev, unsigned int flags)
 		__dev_set_allmulti(dev, inc, false);
 	}
 
+	if ((old_flags ^ flags) & IFF_PROTO_DOWN)
+		netdev_switch_port_phy_state_set(dev,
+						 (flags & IFF_PROTO_DOWN) ?
+						 false : true);
+
 	return ret;
 }
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 46568b8..5c710cf 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -64,6 +64,29 @@ int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
 }
 EXPORT_SYMBOL_GPL(netdev_switch_port_stp_update);
 
+/**
+ *	netdev_switch_port_phy_state_set - Request switch device to set
+ *					physical state of the port
+ *	@dev: port device
+ *	@enable: port phy state
+ *
+ *	Request switch device to set physical state of the port. This
+ *	API is only available for a device that has a switch port
+ *	associated with it i.e. not available for virtual/software
+ *	devices.
+ */
+int netdev_switch_port_phy_state_set(struct net_device *dev, bool enable)
+{
+	const struct swdev_ops *ops = dev->swdev_ops;
+	int err = -EOPNOTSUPP;
+
+	if (ops && ops->swdev_port_phy_state_set)
+		return ops->swdev_port_phy_state_set(dev, enable);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(netdev_switch_port_phy_state_set);
+
 static DEFINE_MUTEX(netdev_switch_mutex);
 static RAW_NOTIFIER_HEAD(netdev_switch_notif_chain);
 
-- 
1.7.10.4
