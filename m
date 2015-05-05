From: sfeldma@gmail.com
Subject: [PATCH net-next v5 03/21] switchdev: introduce get/set attrs ops
Date: Tue,  5 May 2015 10:34:39 -0700
Message-ID: <1430847297-15728-4-git-send-email-sfeldma@gmail.com>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35108 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965328AbbEEReE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 13:34:04 -0400
Received: by pdbqd1 with SMTP id qd1so203427697pdb.2
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 10:34:03 -0700 (PDT)
In-Reply-To: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Add two new swdev ops for get/set switch port attributes.  Most swdev
interactions on a port are gets or sets on port attributes, so rather than
adding ops for each attribute, let's define clean get/set ops for all
attributes, and then we can have clear, consistent rules on how attributes
propagate on stacked devs.

Add the basic algorithms for get/set attr ops.  Use the same recusive algo
to walk lower devs we've used for STP updates, for example.  For get,
compare attr value for each lower dev and only return success if attr
values match across all lower devs.  For sets, set the same attr value for
all lower devs.  We'll use a two-phase prepare-commit transaction model for
sets.  In the first phase, the driver(s) are asked if attr set is OK.  If
all OK, the commit attr set in second phase.  A driver would NACK the
prepare phase if it can't set the attr due to lack of resources or support,
within it's control.  RTNL lock must be held across both phases because
we'll recurse all lower devs first in prepare phase, and then recurse all
lower devs again in commit phase.  If any lower dev fails the prepare
phase, we need to abort the transaction for all lower devs.

If lower dev recusion isn't desired, allow a flag SWITCHDEV_F_NO_RECURSE to
indicate get/set only work on port (lowest) device.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |   43 ++++++++++++
 net/switchdev/switchdev.c |  169 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 212 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 97b556d..2820438 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -14,6 +14,25 @@
 #include <linux/netdevice.h>
 #include <linux/notifier.h>
 
+#define SWITCHDEV_F_NO_RECURSE		BIT(0)
+
+enum switchdev_trans {
+	SWITCHDEV_TRANS_NONE,
+	SWITCHDEV_TRANS_PREPARE,
+	SWITCHDEV_TRANS_ABORT,
+	SWITCHDEV_TRANS_COMMIT,
+};
+
+enum switchdev_attr_id {
+	SWITCHDEV_ATTR_UNDEFINED,
+};
+
+struct switchdev_attr {
+	enum switchdev_attr_id id;
+	enum switchdev_trans trans;
+	u32 flags;
+};
+
 struct fib_info;
 
 /**
@@ -23,6 +42,10 @@ struct fib_info;
  *   is part of.  If driver implements this, it indicates that it
  *   represents a port of a switch chip.
  *
+ * @switchdev_port_attr_get: Get a port attribute (see switchdev_attr).
+ *
+ * @switchdev_port_attr_set: Set a port attribute (see switchdev_attr).
+ *
  * @switchdev_port_stp_update: Called to notify switch device port of bridge
  *   port STP state change.
  *
@@ -33,6 +56,10 @@ struct fib_info;
 struct switchdev_ops {
 	int	(*switchdev_parent_id_get)(struct net_device *dev,
 					   struct netdev_phys_item_id *psid);
+	int	(*switchdev_port_attr_get)(struct net_device *dev,
+					   struct switchdev_attr *attr);
+	int	(*switchdev_port_attr_set)(struct net_device *dev,
+					   struct switchdev_attr *attr);
 	int	(*switchdev_port_stp_update)(struct net_device *dev, u8 state);
 	int	(*switchdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
 					  int dst_len, struct fib_info *fi,
@@ -68,6 +95,10 @@ switchdev_notifier_info_to_dev(const struct switchdev_notifier_info *info)
 
 int switchdev_parent_id_get(struct net_device *dev,
 			    struct netdev_phys_item_id *psid);
+int switchdev_port_attr_get(struct net_device *dev,
+			    struct switchdev_attr *attr);
+int switchdev_port_attr_set(struct net_device *dev,
+			    struct switchdev_attr *attr);
 int switchdev_port_stp_update(struct net_device *dev, u8 state);
 int register_switchdev_notifier(struct notifier_block *nb);
 int unregister_switchdev_notifier(struct notifier_block *nb);
@@ -95,6 +126,18 @@ static inline int switchdev_parent_id_get(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int switchdev_port_attr_get(struct net_device *dev,
+					  struct switchdev_attr *attr)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int switchdev_port_attr_set(struct net_device *dev,
+					  struct switchdev_attr *attr)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int switchdev_port_stp_update(struct net_device *dev,
 					    u8 state)
 {
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index b7f44a2..8f47187 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -37,6 +37,175 @@ int switchdev_parent_id_get(struct net_device *dev,
 EXPORT_SYMBOL_GPL(switchdev_parent_id_get);
 
 /**
+ *	switchdev_port_attr_get - Get port attribute
+ *
+ *	@dev: port device
+ *	@attr: attribute to get
+ */
+int switchdev_port_attr_get(struct net_device *dev, struct switchdev_attr *attr)
+{
+	const struct switchdev_ops *ops = dev->switchdev_ops;
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	struct switchdev_attr first = {
+		.id = SWITCHDEV_ATTR_UNDEFINED
+	};
+	int err = -EOPNOTSUPP;
+
+	if (ops && ops->switchdev_port_attr_get)
+		return ops->switchdev_port_attr_get(dev, attr);
+
+	if (attr->flags & SWITCHDEV_F_NO_RECURSE)
+		return err;
+
+	/* Switch device port(s) may be stacked under
+	 * bond/team/vlan dev, so recurse down to get attr on
+	 * each port.  Return -ENODATA if attr values don't
+	 * compare across ports.
+	 */
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = switchdev_port_attr_get(lower_dev, attr);
+		if (err)
+			break;
+		if (first.id == SWITCHDEV_ATTR_UNDEFINED)
+			first = *attr;
+		else if (memcmp(&first, attr, sizeof(*attr)))
+			return -ENODATA;
+	}
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(switchdev_port_attr_get);
+
+static int __switchdev_port_attr_set(struct net_device *dev,
+				     struct switchdev_attr *attr)
+{
+	const struct switchdev_ops *ops = dev->switchdev_ops;
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	int err = -EOPNOTSUPP;
+
+	if (ops && ops->switchdev_port_attr_set)
+		return ops->switchdev_port_attr_set(dev, attr);
+
+	if (attr->flags & SWITCHDEV_F_NO_RECURSE)
+		return err;
+
+	/* Switch device port(s) may be stacked under
+	 * bond/team/vlan dev, so recurse down to set attr on
+	 * each port.
+	 */
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = __switchdev_port_attr_set(lower_dev, attr);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
+struct switchdev_attr_set_work {
+	struct work_struct work;
+	struct net_device *dev;
+	struct switchdev_attr attr;
+};
+
+static void switchdev_port_attr_set_work(struct work_struct *work)
+{
+	struct switchdev_attr_set_work *asw =
+		container_of(work, struct switchdev_attr_set_work, work);
+	int err;
+
+	rtnl_lock();
+	err = switchdev_port_attr_set(asw->dev, &asw->attr);
+	BUG_ON(err);
+	rtnl_unlock();
+
+	dev_put(asw->dev);
+	kfree(work);
+}
+
+static int switchdev_port_attr_set_defer(struct net_device *dev,
+					 struct switchdev_attr *attr)
+{
+	struct switchdev_attr_set_work *asw;
+
+	asw = kmalloc(sizeof(*asw), GFP_ATOMIC);
+	if (!asw)
+		return -ENOMEM;
+
+	INIT_WORK(&asw->work, switchdev_port_attr_set_work);
+
+	dev_hold(dev);
+	asw->dev = dev;
+	memcpy(&asw->attr, attr, sizeof(asw->attr));
+
+	schedule_work(&asw->work);
+
+	return 0;
+}
+
+/**
+ *	switchdev_port_attr_set - Set port attribute
+ *
+ *	@dev: port device
+ *	@attr: attribute to set
+ *
+ *	Use a 2-phase prepare-commit transaction model to ensure
+ *	system is not left in a partially updated state due to
+ *	failure from driver/device.
+ */
+int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
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
+		return switchdev_port_attr_set_defer(dev, attr);
+	}
+
+	/* Phase I: prepare for attr set. Driver/device should fail
+	 * here if there are going to be issues in the commit phase,
+	 * such as lack of resources or support.  The driver/device
+	 * should reserve resources needed for the commit phase here,
+	 * but should not commit the attr.
+	 */
+
+	attr->trans = SWITCHDEV_TRANS_PREPARE;
+	err = __switchdev_port_attr_set(dev, attr);
+	if (err) {
+		/* Prepare phase failed: abort the transaction.  Any
+		 * resources reserved in the prepare phase are
+		 * released.
+		 */
+
+		attr->trans = SWITCHDEV_TRANS_ABORT;
+		__switchdev_port_attr_set(dev, attr);
+
+		return err;
+	}
+
+	/* Phase II: commit attr set.  This cannot fail as a fault
+	 * of driver/device.  If it does, it's a bug in the driver/device
+	 * because the driver said everythings was OK in phase I.
+	 */
+
+	attr->trans = SWITCHDEV_TRANS_COMMIT;
+	err = __switchdev_port_attr_set(dev, attr);
+	BUG_ON(err);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(switchdev_port_attr_set);
+
+/**
  *	switchdev_port_stp_update - Notify switch device port of STP
  *					state change
  *	@dev: port device
-- 
1.7.10.4
