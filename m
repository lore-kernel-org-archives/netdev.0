From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 02/10] switchdev: introduce transaction item queue for attr_set and obj_add
Date: Thu, 24 Sep 2015 10:02:41 +0200
Message-ID: <1443081769-11193-3-git-send-email-jiri@resnulli.us>
References: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36584 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbbIXIC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 04:02:56 -0400
Received: by wicgb1 with SMTP id gb1so238164684wic.1
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 01:02:54 -0700 (PDT)
In-Reply-To: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Now, the memory allocation in prepare/commit state is done separatelly
in each driver (rocker). Introduce the similar mechanism in generic
switchdev code, in form of queue. That can be used not only for memory
allocations, but also for different items. Abort item destruction
is handled as well.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
- added comment blocks to exported functions as suggested by Scott
- made switchdev_trans_init and switchdev_trans_items_destroy static
- added documentation for this to switchdev.txt as suggested by Scott
v2->v3:
- warn in case of transaction item queue is not empty after commit phase
  as suggested by Scott
---
 Documentation/networking/switchdev.txt |  19 ++++++
 drivers/net/ethernet/rocker/rocker.c   |   6 +-
 include/net/switchdev.h                |  24 ++++++-
 net/dsa/slave.c                        |   6 +-
 net/switchdev/switchdev.c              | 111 +++++++++++++++++++++++++++++----
 5 files changed, 146 insertions(+), 20 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index 67e43ee..9f9e258 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -369,3 +369,22 @@ The driver can monitor for updates to arp_tbl using the netevent notifier
 NETEVENT_NEIGH_UPDATE.  The device can be programmed with resolved nexthops
 for the routes as arp_tbl updates.  The driver implements ndo_neigh_destroy
 to know when arp_tbl neighbor entries are purged from the port.
+
+Transaction item queue
+^^^^^^^^^^^^^^^^^^^^^^
+
+For switchdev ops attr_set and obj_add, there is a 2 phase transaction model
+used. First phase is to "prepare" anything needed, including various checks,
+memory allocation, etc. The goal is to handle the stuff that is not unlikely
+to fail here. The second phase is to "commit" the actual changes.
+
+Switchdev provides an inftrastructure for sharing items (for example memory
+allocations) between the two phases.
+
+The object created by a driver in "prepare" phase and it is queued up by:
+switchdev_trans_item_enqueue()
+During the "commit" phase, the driver gets the object by:
+switchdev_trans_item_dequeue()
+
+If a transaction is aborted during "prepare" phase, switchdev code will handle
+cleanup of the queued-up objects.
diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index cf03b07..dcc6f3f 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4383,7 +4383,8 @@ static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_attr_set(struct net_device *dev,
-				struct switchdev_attr *attr)
+				struct switchdev_attr *attr,
+				struct switchdev_trans *trans)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	int err = 0;
@@ -4467,7 +4468,8 @@ static int rocker_port_fdb_add(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_obj_add(struct net_device *dev,
-			       struct switchdev_obj *obj)
+			       struct switchdev_obj *obj,
+			       struct switchdev_trans *trans)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	const struct switchdev_obj_ipv4_fib *fib4;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 494f510..1e394f1 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -1,6 +1,6 @@
 /*
  * include/net/switchdev.h - Switch device API
- * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ * Copyright (c) 2014-2015 Jiri Pirko <jiri@resnulli.us>
  * Copyright (c) 2014-2015 Scott Feldman <sfeldma@gmail.com>
  *
  * This program is free software; you can redistribute it and/or modify
@@ -13,6 +13,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/notifier.h>
+#include <linux/list.h>
 
 #define SWITCHDEV_F_NO_RECURSE		BIT(0)
 
@@ -23,6 +24,16 @@ enum switchdev_trans_ph {
 	SWITCHDEV_TRANS_COMMIT,
 };
 
+struct switchdev_trans_item {
+	struct list_head list;
+	void *data;
+	void (*destructor)(const void *data);
+};
+
+struct switchdev_trans {
+	struct list_head item_list;
+};
+
 enum switchdev_attr_id {
 	SWITCHDEV_ATTR_UNDEFINED,
 	SWITCHDEV_ATTR_PORT_PARENT_ID,
@@ -77,6 +88,11 @@ struct switchdev_obj {
 	} u;
 };
 
+void switchdev_trans_item_enqueue(struct switchdev_trans *trans,
+				  void *data, void (*destructor)(void const *),
+				  struct switchdev_trans_item *tritem);
+void *switchdev_trans_item_dequeue(struct switchdev_trans *trans);
+
 /**
  * struct switchdev_ops - switchdev operations
  *
@@ -94,9 +110,11 @@ struct switchdev_ops {
 	int	(*switchdev_port_attr_get)(struct net_device *dev,
 					   struct switchdev_attr *attr);
 	int	(*switchdev_port_attr_set)(struct net_device *dev,
-					   struct switchdev_attr *attr);
+					   struct switchdev_attr *attr,
+					   struct switchdev_trans *trans);
 	int	(*switchdev_port_obj_add)(struct net_device *dev,
-					  struct switchdev_obj *obj);
+					  struct switchdev_obj *obj,
+					  struct switchdev_trans *trans);
 	int	(*switchdev_port_obj_del)(struct net_device *dev,
 					  struct switchdev_obj *obj);
 	int	(*switchdev_port_obj_dump)(struct net_device *dev,
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 7f50b74..ac76fd1 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -456,7 +456,8 @@ static int dsa_slave_stp_update(struct net_device *dev, u8 state)
 }
 
 static int dsa_slave_port_attr_set(struct net_device *dev,
-				   struct switchdev_attr *attr)
+				   struct switchdev_attr *attr,
+				   struct switchdev_trans *trans)
 {
 	int ret = 0;
 
@@ -474,7 +475,8 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 }
 
 static int dsa_slave_port_obj_add(struct net_device *dev,
-				  struct switchdev_obj *obj)
+				  struct switchdev_obj *obj,
+				  struct switchdev_trans *trans)
 {
 	int err;
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index df5a544..35e2967 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -1,6 +1,6 @@
 /*
  * net/switchdev/switchdev.c - Switch device API
- * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ * Copyright (c) 2014-2015 Jiri Pirko <jiri@resnulli.us>
  * Copyright (c) 2014-2015 Scott Feldman <sfeldma@gmail.com>
  *
  * This program is free software; you can redistribute it and/or modify
@@ -16,10 +16,83 @@
 #include <linux/notifier.h>
 #include <linux/netdevice.h>
 #include <linux/if_bridge.h>
+#include <linux/list.h>
 #include <net/ip_fib.h>
 #include <net/switchdev.h>
 
 /**
+ *	switchdev_trans_item_enqueue - Enqueue data item to transaction queue
+ *
+ *	@trans: transaction
+ *	@data: pointer to data being queued
+ *	@destructor: data destructor
+ *	@tritem: transaction item being queued
+ *
+ *	Enqeueue data item to transaction queue. tritem is typically placed in
+ *	cointainter pointed at by data pointer. Destructor is called on
+ *	transaction abort and after successful commit phase in case
+ *	the caller did not dequeue the item before.
+ */
+void switchdev_trans_item_enqueue(struct switchdev_trans *trans,
+				  void *data, void (*destructor)(void const *),
+				  struct switchdev_trans_item *tritem)
+{
+	tritem->data = data;
+	tritem->destructor = destructor;
+	list_add_tail(&tritem->list, &trans->item_list);
+}
+EXPORT_SYMBOL_GPL(switchdev_trans_item_enqueue);
+
+static struct switchdev_trans_item *
+__switchdev_trans_item_dequeue(struct switchdev_trans *trans)
+{
+	struct switchdev_trans_item *tritem;
+
+	if (list_empty(&trans->item_list))
+		return NULL;
+	tritem = list_first_entry(&trans->item_list,
+				  struct switchdev_trans_item, list);
+	list_del(&tritem->list);
+	return tritem;
+}
+
+/**
+ *	switchdev_trans_item_dequeue - Dequeue data item from transaction queue
+ *
+ *	@trans: transaction
+ */
+void *switchdev_trans_item_dequeue(struct switchdev_trans *trans)
+{
+	struct switchdev_trans_item *tritem;
+
+	tritem = __switchdev_trans_item_dequeue(trans);
+	BUG_ON(!tritem);
+	return tritem->data;
+}
+EXPORT_SYMBOL_GPL(switchdev_trans_item_dequeue);
+
+static void switchdev_trans_init(struct switchdev_trans *trans)
+{
+	INIT_LIST_HEAD(&trans->item_list);
+}
+
+static void switchdev_trans_items_destroy(struct switchdev_trans *trans)
+{
+	struct switchdev_trans_item *tritem;
+
+	while ((tritem = __switchdev_trans_item_dequeue(trans)))
+		tritem->destructor(tritem->data);
+}
+
+static void switchdev_trans_items_warn_destroy(struct net_device *dev,
+					       struct switchdev_trans *trans)
+{
+	WARN(!list_empty(&trans->item_list), "%s: transaction item queue is not empty.\n",
+	     dev->name);
+	switchdev_trans_items_destroy(trans);
+}
+
+/**
  *	switchdev_port_attr_get - Get port attribute
  *
  *	@dev: port device
@@ -62,7 +135,8 @@ int switchdev_port_attr_get(struct net_device *dev, struct switchdev_attr *attr)
 EXPORT_SYMBOL_GPL(switchdev_port_attr_get);
 
 static int __switchdev_port_attr_set(struct net_device *dev,
-				     struct switchdev_attr *attr)
+				     struct switchdev_attr *attr,
+				     struct switchdev_trans *trans)
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
 	struct net_device *lower_dev;
@@ -70,7 +144,7 @@ static int __switchdev_port_attr_set(struct net_device *dev,
 	int err = -EOPNOTSUPP;
 
 	if (ops && ops->switchdev_port_attr_set)
-		return ops->switchdev_port_attr_set(dev, attr);
+		return ops->switchdev_port_attr_set(dev, attr, trans);
 
 	if (attr->flags & SWITCHDEV_F_NO_RECURSE)
 		return err;
@@ -81,7 +155,7 @@ static int __switchdev_port_attr_set(struct net_device *dev,
 	 */
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = __switchdev_port_attr_set(lower_dev, attr);
+		err = __switchdev_port_attr_set(lower_dev, attr, trans);
 		if (err)
 			break;
 	}
@@ -144,6 +218,7 @@ static int switchdev_port_attr_set_defer(struct net_device *dev,
  */
 int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 {
+	struct switchdev_trans trans;
 	int err;
 
 	if (!rtnl_is_locked()) {
@@ -156,6 +231,8 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 		return switchdev_port_attr_set_defer(dev, attr);
 	}
 
+	switchdev_trans_init(&trans);
+
 	/* Phase I: prepare for attr set. Driver/device should fail
 	 * here if there are going to be issues in the commit phase,
 	 * such as lack of resources or support.  The driver/device
@@ -164,7 +241,7 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 	 */
 
 	attr->trans_ph = SWITCHDEV_TRANS_PREPARE;
-	err = __switchdev_port_attr_set(dev, attr);
+	err = __switchdev_port_attr_set(dev, attr, &trans);
 	if (err) {
 		/* Prepare phase failed: abort the transaction.  Any
 		 * resources reserved in the prepare phase are
@@ -173,7 +250,8 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 
 		if (err != -EOPNOTSUPP) {
 			attr->trans_ph = SWITCHDEV_TRANS_ABORT;
-			__switchdev_port_attr_set(dev, attr);
+			__switchdev_port_attr_set(dev, attr, &trans);
+			switchdev_trans_items_destroy(&trans);
 		}
 
 		return err;
@@ -185,16 +263,18 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 	 */
 
 	attr->trans_ph = SWITCHDEV_TRANS_COMMIT;
-	err = __switchdev_port_attr_set(dev, attr);
+	err = __switchdev_port_attr_set(dev, attr, &trans);
 	WARN(err, "%s: Commit of attribute (id=%d) failed.\n",
 	     dev->name, attr->id);
+	switchdev_trans_items_warn_destroy(dev, &trans);
 
 	return err;
 }
 EXPORT_SYMBOL_GPL(switchdev_port_attr_set);
 
 static int __switchdev_port_obj_add(struct net_device *dev,
-				    struct switchdev_obj *obj)
+				    struct switchdev_obj *obj,
+				    struct switchdev_trans *trans)
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
 	struct net_device *lower_dev;
@@ -202,7 +282,7 @@ static int __switchdev_port_obj_add(struct net_device *dev,
 	int err = -EOPNOTSUPP;
 
 	if (ops && ops->switchdev_port_obj_add)
-		return ops->switchdev_port_obj_add(dev, obj);
+		return ops->switchdev_port_obj_add(dev, obj, trans);
 
 	/* Switch device port(s) may be stacked under
 	 * bond/team/vlan dev, so recurse down to add object on
@@ -210,7 +290,7 @@ static int __switchdev_port_obj_add(struct net_device *dev,
 	 */
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = __switchdev_port_obj_add(lower_dev, obj);
+		err = __switchdev_port_obj_add(lower_dev, obj, trans);
 		if (err)
 			break;
 	}
@@ -232,10 +312,13 @@ static int __switchdev_port_obj_add(struct net_device *dev,
  */
 int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 {
+	struct switchdev_trans trans;
 	int err;
 
 	ASSERT_RTNL();
 
+	switchdev_trans_init(&trans);
+
 	/* Phase I: prepare for obj add. Driver/device should fail
 	 * here if there are going to be issues in the commit phase,
 	 * such as lack of resources or support.  The driver/device
@@ -244,7 +327,7 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 	 */
 
 	obj->trans_ph = SWITCHDEV_TRANS_PREPARE;
-	err = __switchdev_port_obj_add(dev, obj);
+	err = __switchdev_port_obj_add(dev, obj, &trans);
 	if (err) {
 		/* Prepare phase failed: abort the transaction.  Any
 		 * resources reserved in the prepare phase are
@@ -253,7 +336,8 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 
 		if (err != -EOPNOTSUPP) {
 			obj->trans_ph = SWITCHDEV_TRANS_ABORT;
-			__switchdev_port_obj_add(dev, obj);
+			__switchdev_port_obj_add(dev, obj, &trans);
+			switchdev_trans_items_destroy(&trans);
 		}
 
 		return err;
@@ -265,8 +349,9 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 	 */
 
 	obj->trans_ph = SWITCHDEV_TRANS_COMMIT;
-	err = __switchdev_port_obj_add(dev, obj);
+	err = __switchdev_port_obj_add(dev, obj, &trans);
 	WARN(err, "%s: Commit of object (id=%d) failed.\n", dev->name, obj->id);
+	switchdev_trans_items_warn_destroy(dev, &trans);
 
 	return err;
 }
-- 
1.9.3
