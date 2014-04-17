From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC v3 05/10] switchdev: introduce basic support for flows
Date: Thu, 17 Apr 2014 14:14:32 +0200
Message-ID: <1397736876-11771-6-git-send-email-jiri@resnulli.us>
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
Received: from mail-ee0-f47.google.com ([74.125.83.47]:59126 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945891AbaDQMPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 08:15:03 -0400
Received: by mail-ee0-f47.google.com with SMTP id b15so595300eek.6
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2014 05:15:02 -0700 (PDT)
In-Reply-To: <1397736876-11771-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a couple of ndos which can be used to work with flows.
Note that user can use random port netdevice to access the switch.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h | 30 ++++++++++++++++++++++++
 include/linux/switchdev.h | 25 ++++++++++++++++++++
 net/core/switchdev.c      | 58 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 113 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 83e38a0..14bd8b3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -49,6 +49,8 @@
 
 #include <linux/netdev_features.h>
 #include <linux/neighbour.h>
+#include <linux/sw_flow.h>
+
 #include <uapi/linux/netdevice.h>
 
 struct netpoll_info;
@@ -997,6 +999,26 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	Called to get an ID of the switch chip this port is part of.
  *	If driver implements this, it indicates that it represents a port
  *	of a switch chip.
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
+ *
+ * int (*ndo_swdev_flow_action_set)(struct net_device *dev,
+ *				    const struct sw_flow *flow,
+ *				    const struct sw_flow_action *action,
+ *				    size_t action_count);
+ *	Called to set actions for a flow inserted in swtich device.
+ *	If driver does not implement this, it is assumed that the hw does
+ *	not have a capability to work with flows.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1146,6 +1168,14 @@ struct net_device_ops {
 #ifdef CONFIG_NET_SWITCHDEV
 	int			(*ndo_swdev_get_id)(struct net_device *dev,
 						    struct netdev_phys_item_id *psid);
+	int			(*ndo_swdev_flow_insert)(struct net_device *dev,
+							 const struct sw_flow *flow);
+	int			(*ndo_swdev_flow_remove)(struct net_device *dev,
+							 const struct sw_flow *flow);
+	int			(*ndo_swdev_flow_action_set)(struct net_device *dev,
+							     const struct sw_flow *flow,
+							     const struct sw_flow_action *action,
+							     size_t action_count);
 #endif
 };
 
diff --git a/include/linux/switchdev.h b/include/linux/switchdev.h
index b147dde..6f8ce06 100644
--- a/include/linux/switchdev.h
+++ b/include/linux/switchdev.h
@@ -16,6 +16,11 @@
 #ifdef CONFIG_NET_SWITCHDEV
 
 int swdev_get_id(struct net_device *dev, struct netdev_phys_item_id *psid);
+int swdev_flow_insert(struct net_device *dev, const struct sw_flow *flow);
+int swdev_flow_remove(struct net_device *dev, const struct sw_flow *flow);
+int swdev_flow_action_set(struct net_device *dev, const struct sw_flow *flow,
+			  const struct sw_flow_action *action,
+			  size_t action_count);
 
 #else
 
@@ -25,6 +30,26 @@ static inline int swdev_get_id(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
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
+static inline int swdev_flow_action_set(struct net_device *dev,
+					const struct sw_flow *flow,
+					const struct sw_flow_action *action,
+					size_t action_count)
+{
+	return -EOPNOTSUPP;
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/core/switchdev.c b/net/core/switchdev.c
index 2d275f5..cb5b6a2 100644
--- a/net/core/switchdev.c
+++ b/net/core/switchdev.c
@@ -30,3 +30,61 @@ int swdev_get_id(struct net_device *dev, struct netdev_phys_item_id *psid)
 	return ops->ndo_swdev_get_id(dev, psid);
 }
 EXPORT_SYMBOL(swdev_get_id);
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
+	if (!ops->ndo_swdev_flow_insert)
+		return -EOPNOTSUPP;
+	WARN_ON(!ops->ndo_swdev_get_id);
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
+	if (!ops->ndo_swdev_flow_remove)
+		return -EOPNOTSUPP;
+	WARN_ON(!ops->ndo_swdev_get_id);
+	return ops->ndo_swdev_flow_remove(dev, flow);
+}
+EXPORT_SYMBOL(swdev_flow_remove);
+
+/**
+ *	swdev_flow_action_set - Set actions for a flow
+ *	@dev: port device
+ *	@flow: flow descriptor
+ *	@action: array of actions
+ *	@action_count: length of the array of actions
+ *
+ *	Set actions for a flow.
+ */
+int swdev_flow_action_set(struct net_device *dev, const struct sw_flow *flow,
+			  const struct sw_flow_action *action,
+			  size_t action_count)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (!ops->ndo_swdev_flow_action_set)
+		return -EOPNOTSUPP;
+	WARN_ON(!ops->ndo_swdev_get_id);
+	return ops->ndo_swdev_flow_action_set(dev, flow, action, action_count);
+}
+EXPORT_SYMBOL(swdev_flow_action_set);
-- 
1.9.0
