From: sfeldma@gmail.com
Subject: [PATCH net-next v2 01/26] switchdev: introduce get/set attrs ops
Date: Wed,  1 Apr 2015 03:07:37 -0700
Message-ID: <1427882882-2533-2-git-send-email-sfeldma@gmail.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:36800 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbbDAKGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 06:06:30 -0400
Received: by pdmh5 with SMTP id h5so37924018pdm.3
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 03:06:29 -0700 (PDT)
In-Reply-To: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Add two new swdev ops for get/set switch port attributes.  Most swdev
interactions on a port are gets or sets on port attributes, so rather than
adding ops for each attribute, let's define clean get/set ops for all
attributes, and then we can have clear, consistent rules on how attributes
propagate on stacked devs.

Add the basic algorithms for get/set attr ops.  Use the same recusive algo to
walk lower devs we've used for STP updates, for example.  For get, compare attr
value for each lower dev and only return success if attr values match across
all lower devs.  For sets, set the same attr value for all lower devs.  If
something goes wrong on one of the lower devs, revert all back to previous attr
value.

If lower dev recusion isn't desired, allow a flag SWDEV_F_NO_RECURSE to
indicate get/set only work on port (lowest) device.

On set, allow a flag SWDEV_F_NO_RECOVER to turn off automatic err recovery.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |   34 +++++++++++++++
 net/switchdev/switchdev.c |  102 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 136 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index d2e69ee..b5a7d06 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -14,6 +14,18 @@
 #include <linux/netdevice.h>
 #include <linux/notifier.h>
 
+#define SWDEV_F_NO_RECURSE		BIT(0)
+#define SWDEV_F_NO_RECOVER		BIT(1)
+
+enum swdev_attr_id {
+	SWDEV_ATTR_UNDEFINED,
+};
+
+struct swdev_attr {
+	enum swdev_attr_id id;
+	u32 flags;
+};
+
 struct fib_info;
 
 /**
@@ -23,6 +35,10 @@ struct fib_info;
  *   is part of.  If driver implements this, it indicates that it
  *   represents a port of a switch chip.
  *
+ * @swdev_port_attr_get: Get a port attribute (see swdev_attr).
+ *
+ * @swdev_port_attr_set: Set a port attribute (see swdev_attr).
+ *
  * @swdev_port_stp_update: Called to notify switch device port of bridge
  *   port STP state change.
  *
@@ -33,6 +49,10 @@ struct fib_info;
 struct swdev_ops {
 	int	(*swdev_parent_id_get)(struct net_device *dev,
 				       struct netdev_phys_item_id *psid);
+	int	(*swdev_port_attr_get)(struct net_device *dev,
+				       struct swdev_attr *attr);
+	int	(*swdev_port_attr_set)(struct net_device *dev,
+				       struct swdev_attr *attr);
 	int	(*swdev_port_stp_update)(struct net_device *dev, u8 state);
 	int	(*swdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
 				      int dst_len, struct fib_info *fi,
@@ -68,6 +88,8 @@ netdev_switch_notifier_info_to_dev(const struct netdev_switch_notifier_info *inf
 
 int netdev_switch_parent_id_get(struct net_device *dev,
 				struct netdev_phys_item_id *psid);
+int swdev_port_attr_get(struct net_device *dev, struct swdev_attr *attr);
+int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr);
 int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
 int register_netdev_switch_notifier(struct notifier_block *nb);
 int unregister_netdev_switch_notifier(struct notifier_block *nb);
@@ -95,6 +117,18 @@ static inline int netdev_switch_parent_id_get(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int swdev_port_attr_get(struct net_device *dev,
+				      enum swdev_attr *attr)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int swdev_port_attr_set(struct net_device *dev,
+				      enum swdev_attr *attr)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int netdev_switch_port_stp_update(struct net_device *dev,
 						u8 state)
 {
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 46568b8..e41cf72 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -37,6 +37,108 @@ int netdev_switch_parent_id_get(struct net_device *dev,
 EXPORT_SYMBOL_GPL(netdev_switch_parent_id_get);
 
 /**
+ *	swdev_port_attr_get - Get port attribute
+ *
+ *	@dev: port device
+ *	@attr: attribute to get
+ */
+int swdev_port_attr_get(struct net_device *dev, struct swdev_attr *attr)
+{
+	const struct swdev_ops *ops = dev->swdev_ops;
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	struct swdev_attr first = {
+		.id = SWDEV_ATTR_UNDEFINED
+	};
+	int err = -EOPNOTSUPP;
+
+	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
+		return err;
+
+	if (ops && ops->swdev_port_attr_get)
+		return ops->swdev_port_attr_get(dev, attr);
+
+	if (attr->flags & SWDEV_F_NO_RECURSE)
+		return err;
+
+	/* Switch device port(s) may be stacked under
+	 * bond/team/vlan dev, so recurse down to get attr on
+	 * each port.  Return -ENODATA if attr values don't
+	 * compare across ports.
+	 */
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = swdev_port_attr_get(lower_dev, attr);
+		if (err)
+			break;
+		if (first.id == SWDEV_ATTR_UNDEFINED)
+			first = *attr;
+		else if (memcmp(&first, attr, sizeof(*attr)))
+			return -ENODATA;
+	}
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(swdev_port_attr_get);
+
+static int __swdev_port_attr_set(struct net_device *dev,
+				 struct swdev_attr *attr)
+{
+	const struct swdev_ops *ops = dev->swdev_ops;
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	int err = -EOPNOTSUPP;
+
+	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
+		return err;
+
+	if (ops && ops->swdev_port_attr_set)
+		return ops->swdev_port_attr_set(dev, attr);
+
+	if (attr->flags & SWDEV_F_NO_RECURSE)
+		return err;
+
+	/* Switch device port(s) may be stacked under
+	 * bond/team/vlan dev, so recurse down to set attr on
+	 * each port.
+	 */
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = __swdev_port_attr_set(lower_dev, attr);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
+/**
+ *	swdev_port_attr_set - Set port attribute
+ *
+ *	@dev: port device
+ *	@attr: attribute to set
+ */
+int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
+{
+	struct swdev_attr prev = *attr;
+	int err, get_err, revert_err;
+
+	get_err = swdev_port_attr_get(dev, &prev);
+
+	err = __swdev_port_attr_set(dev, attr);
+	if (err && !get_err && !(attr->flags & SWDEV_F_NO_RECOVER)) {
+		/* Some err on set: revert to previous value */
+		revert_err = __swdev_port_attr_set(dev, &prev);
+		if (revert_err)
+			netdev_err(dev, "Reverting swdev port attr %d failed\n",
+				   attr->id);
+	}
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(swdev_port_attr_set);
+
+/**
  *	netdev_switch_port_stp_update - Notify switch device port of STP
  *					state change
  *	@dev: port device
-- 
1.7.10.4
