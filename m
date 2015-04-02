From: sfeldma@gmail.com
Subject: [PATCH net-next v3 06/26] switchdev: introduce swdev add/del obj ops
Date: Thu,  2 Apr 2015 01:09:52 -0700
Message-ID: <1427962212-18411-7-git-send-email-sfeldma@gmail.com>
References: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36597 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068AbbDBIJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 04:09:28 -0400
Received: by padcy3 with SMTP id cy3so77260409pad.3
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 01:09:28 -0700 (PDT)
In-Reply-To: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Like swdev attr get/set, add new swdev obj add/del.  swdev objs will be
things like VLANs or FIB entries, so add/del fits better for objects than
get/set used for attributes.

Use same two-phase transaction model as in attr set.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |   31 +++++++++++++
 net/switchdev/switchdev.c |  113 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 144 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 14baa66..d4e5478 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -38,6 +38,15 @@ struct swdev_attr {
 
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
@@ -45,6 +54,10 @@ struct fib_info;
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
@@ -54,6 +67,10 @@ struct swdev_ops {
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
@@ -88,6 +105,8 @@ netdev_switch_notifier_info_to_dev(const struct netdev_switch_notifier_info *inf
 
 int swdev_port_attr_get(struct net_device *dev, struct swdev_attr *attr);
 int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr);
+int swdev_port_obj_add(struct net_device *dev, struct swdev_obj *obj);
+int swdev_port_obj_del(struct net_device *dev, struct swdev_obj *obj);
 int register_netdev_switch_notifier(struct notifier_block *nb);
 int unregister_netdev_switch_notifier(struct notifier_block *nb);
 int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
@@ -120,6 +139,18 @@ static inline int swdev_port_attr_set(struct net_device *dev,
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
index 1a9ae1e..f389e91 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -140,6 +140,119 @@ int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
 }
 EXPORT_SYMBOL_GPL(swdev_port_attr_set);
 
+int __swdev_port_obj_add(struct net_device *dev, struct swdev_obj *obj)
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
+		err = __swdev_port_obj_add(lower_dev, obj);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
+/**
+ *	swdev_port_obj_add - Add port object
+ *
+ *	@dev: port device
+ *	@obj: object to add
+ *
+ *	Use a 2-phase prepare-commit transaction model to ensure
+ * 	system is not left in a partially updated state due to
+ *	failure from driver/device.
+ *
+ *	rtnl_lock must be held.
+ */
+int swdev_port_obj_add(struct net_device *dev, struct swdev_obj *obj)
+{
+	int err;
+
+	ASSERT_RTNL();
+
+	/* Phase I: prepare for obj add. Driver/device should fail
+	 * here if there are going to be issues in the commit phase,
+	 * such as lack of resources or support.  The driver/device
+	 * should not commit the obj add in this phase.
+	 */
+
+	obj->flags &= ~SWDEV_F_TRANS_COMMIT;
+	obj->flags |= SWDEV_F_TRANS_PREPARE;
+
+	err = __swdev_port_obj_add(dev, obj);
+	if (err)
+		return err;
+
+	/* Phase II: commit obj add.  This cannot fail as a fault
+	 * of driver/device.  If it does, it's a bug in the driver/device
+	 * because the driver said everythings was OK in phase I.
+	 */
+
+	obj->flags &= ~SWDEV_F_TRANS_PREPARE;
+	obj->flags |= SWDEV_F_TRANS_COMMIT;
+
+	err = __swdev_port_obj_add(dev, obj);
+	WARN(err, "%s: Commit of object (id=%d) failed.\n", dev->name, obj->id);
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
