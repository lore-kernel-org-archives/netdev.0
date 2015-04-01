From: sfeldma@gmail.com
Subject: [PATCH net-next v2 06/26] switchdev: introduce swdev add/del obj ops
Date: Wed,  1 Apr 2015 03:07:42 -0700
Message-ID: <1427882882-2533-7-git-send-email-sfeldma@gmail.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:35934 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752846AbbDAKGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 06:06:37 -0400
Received: by pdmh5 with SMTP id h5so37926971pdm.3
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 03:06:36 -0700 (PDT)
In-Reply-To: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Like swdev attr get/set, add new swdev obj add/del.  swdev objs will be
things like VLANs or FIB entries, so add/del fits better for objects than
get/set used for attributes.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |   31 +++++++++++++++++++
 net/switchdev/switchdev.c |   74 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 105 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 73fa2a0..39665b4 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -36,6 +36,15 @@ struct swdev_attr {
 
 struct fib_info;
 
+enum swdev_obj_id {
+	SWDEV_OBJ_UNDEFINED,
+};
+
+struct swdev_obj {
+	enum swdev_obj_id id;
+	u32 flags;
+};
+
 /**
  * struct switchdev_ops - switchdev operations
  *
@@ -43,6 +52,10 @@ struct fib_info;
  *
  * @swdev_port_attr_set: Set a port attribute (see swdev_attr).
  *
+ * @swdev_port_obj_add: Add an object to port (see swdev_obj).
+ *
+ * @swdev_port_obj_del: Delete an object from port (see swdev_obj).
+ *
  * @swdev_fib_ipv4_add: Called to add/modify IPv4 route to switch device.
  *
  * @swdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
@@ -52,6 +65,10 @@ struct swdev_ops {
 				       struct swdev_attr *attr);
 	int	(*swdev_port_attr_set)(struct net_device *dev,
 				       struct swdev_attr *attr);
+	int	(*swdev_port_obj_add)(struct net_device *dev,
+				      struct swdev_obj *obj);
+	int	(*swdev_port_obj_del)(struct net_device *dev,
+				      struct swdev_obj *obj);
 	int	(*swdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
 				      int dst_len, struct fib_info *fi,
 				      u8 tos, u8 type, u32 nlflags,
@@ -86,6 +103,8 @@ netdev_switch_notifier_info_to_dev(const struct netdev_switch_notifier_info *inf
 
 int swdev_port_attr_get(struct net_device *dev, struct swdev_attr *attr);
 int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr);
+int swdev_port_obj_add(struct net_device *dev, struct swdev_obj *obj);
+int swdev_port_obj_del(struct net_device *dev, struct swdev_obj *obj);
 int register_netdev_switch_notifier(struct notifier_block *nb);
 int unregister_netdev_switch_notifier(struct notifier_block *nb);
 int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
@@ -118,6 +137,18 @@ static inline int swdev_port_attr_set(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int swdev_port_obj_add(struct net_device *dev,
+				     enum swdev_obj *obj)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int swdev_port_obj_del(struct net_device *dev,
+				     enum swdev_obj *obj)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int register_netdev_switch_notifier(struct notifier_block *nb)
 {
 	return 0;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index ad6d851..6a527f5 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -120,6 +120,80 @@ int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
 }
 EXPORT_SYMBOL_GPL(swdev_port_attr_set);
 
+/**
+ *	swdev_port_obj_add - Add port object
+ *
+ *	@dev: port device
+ *	@obj: object to add
+ */
+int swdev_port_obj_add(struct net_device *dev, struct swdev_obj *obj)
+{
+	const struct swdev_ops *ops = dev->swdev_ops;
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	int err = -EOPNOTSUPP;
+
+	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
+		return err;
+
+	if (ops && ops->swdev_port_obj_add)
+		return ops->swdev_port_obj_add(dev, obj);
+
+	if (obj->flags & SWDEV_F_NO_RECURSE)
+		return err;
+
+	/* Switch device port(s) may be stacked under
+	 * bond/team/vlan dev, so recurse down to add object on
+	 * each port.
+	 */
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = swdev_port_obj_add(lower_dev, obj);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(swdev_port_obj_add);
+
+/**
+ *	swdev_port_obj_del - Delete port object
+ *
+ *	@dev: port device
+ *	@obj: object to delete
+ */
+int swdev_port_obj_del(struct net_device *dev, struct swdev_obj *obj)
+{
+	const struct swdev_ops *ops = dev->swdev_ops;
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	int err = -EOPNOTSUPP;
+
+	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
+		return err;
+
+	if (ops && ops->swdev_port_obj_del)
+		return ops->swdev_port_obj_del(dev, obj);
+
+	if (obj->flags & SWDEV_F_NO_RECURSE)
+		return err;
+
+	/* Switch device port(s) may be stacked under
+	 * bond/team/vlan dev, so recurse down to delete object on
+	 * each port.
+	 */
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = swdev_port_obj_del(lower_dev, obj);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(swdev_port_obj_del);
+
 static DEFINE_MUTEX(netdev_switch_mutex);
 static RAW_NOTIFIER_HEAD(netdev_switch_notif_chain);
 
-- 
1.7.10.4
