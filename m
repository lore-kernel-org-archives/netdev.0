From: sfeldma@gmail.com
Subject: [PATCH net-next v6 07/23] switchdev: introduce switchdev add/del obj ops
Date: Sat,  9 May 2015 10:40:09 -0700
Message-ID: <1431193225-807-8-git-send-email-sfeldma@gmail.com>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35481 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530AbbEIRnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 13:43:24 -0400
Received: by pdbqd1 with SMTP id qd1so113062442pdb.2
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 10:43:23 -0700 (PDT)
In-Reply-To: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Like switchdev attr get/set, add new switchdev obj add/del.  switchdev objs
will be things like VLANs or FIB entries, so add/del fits better for
objects than get/set used for attributes.

Use same two-phase prepare-commit transaction model as in attr set.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/switchdev.h   |   31 +++++++++++++
 net/switchdev/switchdev.c |  107 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 138 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index aec5e49..4f43300 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -41,6 +41,15 @@ struct switchdev_attr {
 
 struct fib_info;
 
+enum switchdev_obj_id {
+	SWITCHDEV_OBJ_UNDEFINED,
+};
+
+struct switchdev_obj {
+	enum switchdev_obj_id id;
+	enum switchdev_trans trans;
+};
+
 /**
  * struct switchdev_ops - switchdev operations
  *
@@ -48,6 +57,10 @@ struct fib_info;
  *
  * @switchdev_port_attr_set: Set a port attribute (see switchdev_attr).
  *
+ * @switchdev_port_obj_add: Add an object to port (see switchdev_obj).
+ *
+ * @switchdev_port_obj_del: Delete an object from port (see switchdev_obj).
+ *
  * @switchdev_fib_ipv4_add: Called to add/modify IPv4 route to switch device.
  *
  * @switchdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
@@ -57,6 +70,10 @@ struct switchdev_ops {
 					   struct switchdev_attr *attr);
 	int	(*switchdev_port_attr_set)(struct net_device *dev,
 					   struct switchdev_attr *attr);
+	int	(*switchdev_port_obj_add)(struct net_device *dev,
+					  struct switchdev_obj *obj);
+	int	(*switchdev_port_obj_del)(struct net_device *dev,
+					  struct switchdev_obj *obj);
 	int	(*switchdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
 					  int dst_len, struct fib_info *fi,
 					  u8 tos, u8 type, u32 nlflags,
@@ -93,6 +110,8 @@ int switchdev_port_attr_get(struct net_device *dev,
 			    struct switchdev_attr *attr);
 int switchdev_port_attr_set(struct net_device *dev,
 			    struct switchdev_attr *attr);
+int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj);
+int switchdev_port_obj_del(struct net_device *dev, struct switchdev_obj *obj);
 int register_switchdev_notifier(struct notifier_block *nb);
 int unregister_switchdev_notifier(struct notifier_block *nb);
 int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
@@ -125,6 +144,18 @@ static inline int switchdev_port_attr_set(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int switchdev_port_obj_add(struct net_device *dev,
+					 struct switchdev_obj *obj)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int switchdev_port_obj_del(struct net_device *dev,
+					 struct switchdev_obj *obj)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int register_switchdev_notifier(struct notifier_block *nb)
 {
 	return 0;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index a3c3590..3d4d99a 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -187,6 +187,113 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 }
 EXPORT_SYMBOL_GPL(switchdev_port_attr_set);
 
+int __switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
+{
+	const struct switchdev_ops *ops = dev->switchdev_ops;
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	int err = -EOPNOTSUPP;
+
+	if (ops && ops->switchdev_port_obj_add)
+		return ops->switchdev_port_obj_add(dev, obj);
+
+	/* Switch device port(s) may be stacked under
+	 * bond/team/vlan dev, so recurse down to add object on
+	 * each port.
+	 */
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = __switchdev_port_obj_add(lower_dev, obj);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
+/**
+ *	switchdev_port_obj_add - Add port object
+ *
+ *	@dev: port device
+ *	@obj: object to add
+ *
+ *	Use a 2-phase prepare-commit transaction model to ensure
+ *	system is not left in a partially updated state due to
+ *	failure from driver/device.
+ *
+ *	rtnl_lock must be held.
+ */
+int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
+{
+	int err;
+
+	ASSERT_RTNL();
+
+	/* Phase I: prepare for obj add. Driver/device should fail
+	 * here if there are going to be issues in the commit phase,
+	 * such as lack of resources or support.  The driver/device
+	 * should reserve resources needed for the commit phase here,
+	 * but should not commit the obj.
+	 */
+
+	obj->trans = SWITCHDEV_TRANS_PREPARE;
+	err = __switchdev_port_obj_add(dev, obj);
+	if (err) {
+		/* Prepare phase failed: abort the transaction.  Any
+		 * resources reserved in the prepare phase are
+		 * released.
+		 */
+
+		obj->trans = SWITCHDEV_TRANS_ABORT;
+		__switchdev_port_obj_add(dev, obj);
+
+		return err;
+	}
+
+	/* Phase II: commit obj add.  This cannot fail as a fault
+	 * of driver/device.  If it does, it's a bug in the driver/device
+	 * because the driver said everythings was OK in phase I.
+	 */
+
+	obj->trans = SWITCHDEV_TRANS_COMMIT;
+	err = __switchdev_port_obj_add(dev, obj);
+	WARN(err, "%s: Commit of object (id=%d) failed.\n", dev->name, obj->id);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(switchdev_port_obj_add);
+
+/**
+ *	switchdev_port_obj_del - Delete port object
+ *
+ *	@dev: port device
+ *	@obj: object to delete
+ */
+int switchdev_port_obj_del(struct net_device *dev, struct switchdev_obj *obj)
+{
+	const struct switchdev_ops *ops = dev->switchdev_ops;
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	int err = -EOPNOTSUPP;
+
+	if (ops && ops->switchdev_port_obj_del)
+		return ops->switchdev_port_obj_del(dev, obj);
+
+	/* Switch device port(s) may be stacked under
+	 * bond/team/vlan dev, so recurse down to delete object on
+	 * each port.
+	 */
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = switchdev_port_obj_del(lower_dev, obj);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(switchdev_port_obj_del);
+
 static DEFINE_MUTEX(switchdev_mutex);
 static RAW_NOTIFIER_HEAD(switchdev_notif_chain);
 
-- 
1.7.10.4
