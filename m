From: sfeldma@gmail.com
Subject: [PATCH net-next v4 01/24] switchdev: introduce get/set attrs ops
Date: Sun, 12 Apr 2015 23:16:55 -0700
Message-ID: <1428905838-14920-2-git-send-email-sfeldma@gmail.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:34665 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752835AbbDMGQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:16:34 -0400
Received: by pdbqa5 with SMTP id qa5so96435870pdb.1
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:16:33 -0700 (PDT)
In-Reply-To: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
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
all lower devs.  For sets, set the same attr value for all lower devs.  We'll
use a two-phase prepare-commit transaction model for sets.  In the first phase,
the driver(s) are asked if attr set is OK.  If all OK, the commit attr set in
second phase.  A driver would NACK the prepare phase if it can't set the attr
due to lack of resources or support, within it's control.  RTNL lock must be
held across both phases because we'll recurse all lower devs first in prepare
phase, and then recurse all lower devs again in commit phase.  If any lower dev
fails the prepare phase, we need to abort the transaction for all lower devs.

If lower dev recusion isn't desired, allow a flag SWDEV_F_NO_RECURSE to
indicate get/set only work on port (lowest) device.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |   41 +++++++++++
 net/switchdev/switchdev.c |  176 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 217 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index d2e69ee..1d45621 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -14,6 +14,25 @@
 #include <linux/netdevice.h>
 #include <linux/notifier.h>
 
+#define SWDEV_F_NO_RECURSE		BIT(1)
+
+enum swdev_trans {
+	SWDEV_TRANS_NONE,
+	SWDEV_TRANS_PREPARE,
+	SWDEV_TRANS_ABORT,
+	SWDEV_TRANS_COMMIT,
+};
+
+enum swdev_attr_id {
+	SWDEV_ATTR_UNDEFINED,
+};
+
+struct swdev_attr {
+	enum swdev_attr_id id;
+	enum swdev_trans trans;
+	u32 flags;
+};
+
 struct fib_info;
 
 /**
@@ -23,6 +42,10 @@ struct fib_info;
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
@@ -33,6 +56,10 @@ struct fib_info;
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
@@ -68,6 +95,8 @@ netdev_switch_notifier_info_to_dev(const struct netdev_switch_notifier_info *inf
 
 int netdev_switch_parent_id_get(struct net_device *dev,
 				struct netdev_phys_item_id *psid);
+int swdev_port_attr_get(struct net_device *dev, struct swdev_attr *attr);
+int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr);
 int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
 int register_netdev_switch_notifier(struct notifier_block *nb);
 int unregister_netdev_switch_notifier(struct notifier_block *nb);
@@ -95,6 +124,18 @@ static inline int netdev_switch_parent_id_get(struct net_device *dev,
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
index 46568b8..db0cc7b 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -37,6 +37,182 @@ int netdev_switch_parent_id_get(struct net_device *dev,
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
+struct swdev_attr_set_defer {
+	struct work_struct work;
+	struct net *net;
+	int ifindex;
+	struct swdev_attr attr;
+};
+
+static void swdev_port_attr_set_defer_work(struct work_struct *work)
+{
+	struct swdev_attr_set_defer *aw =
+		container_of(work, struct swdev_attr_set_defer, work);
+	struct net_device *dev;
+	int err;
+
+	rtnl_lock();
+	dev = __dev_get_by_index(aw->net, aw->ifindex);
+	if (dev) {
+		err = swdev_port_attr_set(dev, &aw->attr);
+		WARN(err, "%s: Deferred set of attr (id=%d) failed.\n",
+		     dev->name, aw->attr.id);
+	}
+	rtnl_unlock();
+
+	kfree(work);
+}
+
+static int swdev_port_attr_set_defer(struct net_device *dev,
+				     struct swdev_attr *attr)
+{
+	struct swdev_attr_set_defer *aw;
+
+	aw = kmalloc(sizeof(*aw), GFP_ATOMIC);
+	if (!aw)
+		return -ENOMEM;
+
+	INIT_WORK(&aw->work, swdev_port_attr_set_defer_work);
+
+	aw->net = dev_net(dev);
+	aw->ifindex = dev->ifindex;
+	memcpy(&aw->attr, attr, sizeof(aw->attr));
+
+	schedule_work(&aw->work);
+
+	return 0;
+}
+
+/**
+ *	swdev_port_attr_set - Set port attribute
+ *
+ *	@dev: port device
+ *	@attr: attribute to set
+ *
+ *	Use a 2-phase prepare-commit transaction model to ensure
+ *	system is not left in a partially updated state due to
+ *	failure from driver/device.
+ *
+ *	rtnl_lock must be held.
+ */
+int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
+{
+	int err;
+
+	if (!rtnl_is_locked()) {
+		/* Running prepare-commit transaction across stacked
+		 * devices requires nothing moves, so if rtnl_lock is
+		 * not held, schedule a worker thread to hold rtnl_lock
+		 * while setting attr.
+		 */
+
+		return swdev_port_attr_set_defer(dev, attr);
+	}
+
+	/* Phase I: prepare for attr set. Driver/device should fail
+	 * here if there are going to be issues in the commit phase,
+	 * such as lack of resources or support.  The driver/device
+	 * should reserve resources needed for the commit phase here,
+	 * but should not commit the attr.
+	 */
+
+	attr->trans = SWDEV_TRANS_PREPARE;
+	err = __swdev_port_attr_set(dev, attr);
+	if (err) {
+		/* Prepare phase failed: abort the transaction.  Any
+		 * resources reserved in the prepare phase are
+		 * released.
+		 */
+
+		attr->trans = SWDEV_TRANS_ABORT;
+		__swdev_port_attr_set(dev, attr);
+
+		return err;
+	}
+
+	/* Phase II: commit attr set.  This cannot fail as a fault
+	 * of driver/device.  If it does, it's a bug in the driver/device
+	 * because the driver said everythings was OK in phase I.
+	 */
+
+	attr->trans = SWDEV_TRANS_COMMIT;
+	err = __swdev_port_attr_set(dev, attr);
+	WARN(err, "%s: Commit of attr (id=%d) failed.\n", dev->name, attr->id);
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
