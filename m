From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 2/6] switchdev: introduce transaction infrastructure for attr_set and obj_add
Date: Sat, 19 Sep 2015 14:29:07 +0200
Message-ID: <1442665751-10949-3-git-send-email-jiri@resnulli.us>
References: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:38227 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752765AbbISM3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 08:29:19 -0400
Received: by wiclk2 with SMTP id lk2so59508130wic.1
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 05:29:17 -0700 (PDT)
In-Reply-To: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now, the memory allocation in prepare/commit state is done separatelly
in each driver (rocker). Introduce the similar mechanism in generic
switchdev code, in form of queue. That can be used not only for memory
allocations, but also for different items. Commit/abort item destruction
is handled as well.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c |  6 ++-
 include/net/switchdev.h              | 24 ++++++++--
 net/dsa/slave.c                      |  6 ++-
 net/switchdev/switchdev.c            | 87 ++++++++++++++++++++++++++++++------
 4 files changed, 103 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index b5f2ff8..92e1520 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4340,7 +4340,8 @@ static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_attr_set(struct net_device *dev,
-				struct switchdev_attr *attr)
+				struct switchdev_attr *attr,
+				struct switchdev_trans *trans)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	int err = 0;
@@ -4424,7 +4425,8 @@ static int rocker_port_fdb_add(struct rocker_port *rocker_port,
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
index df5a544..a3647bf 100644
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
@@ -16,9 +16,58 @@
 #include <linux/notifier.h>
 #include <linux/netdevice.h>
 #include <linux/if_bridge.h>
+#include <linux/list.h>
 #include <net/ip_fib.h>
 #include <net/switchdev.h>
 
+void switchdev_trans_item_enqueue(struct switchdev_trans *trans,
+				  void *data, void (*destructor)(void const *),
+				  struct switchdev_trans_item *tritem)
+{
+	if (!trans)
+		return;
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
+void switchdev_trans_init(struct switchdev_trans *trans)
+{
+	INIT_LIST_HEAD(&trans->item_list);
+}
+
+void switchdev_trans_items_destroy(struct switchdev_trans *trans)
+{
+	struct switchdev_trans_item *tritem;
+
+	while ((tritem = __switchdev_trans_item_dequeue(trans)))
+	       tritem->destructor(tritem->data);
+}
+
 /**
  *	switchdev_port_attr_get - Get port attribute
  *
@@ -62,7 +111,8 @@ int switchdev_port_attr_get(struct net_device *dev, struct switchdev_attr *attr)
 EXPORT_SYMBOL_GPL(switchdev_port_attr_get);
 
 static int __switchdev_port_attr_set(struct net_device *dev,
-				     struct switchdev_attr *attr)
+				     struct switchdev_attr *attr,
+				     struct switchdev_trans *trans)
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
 	struct net_device *lower_dev;
@@ -70,7 +120,7 @@ static int __switchdev_port_attr_set(struct net_device *dev,
 	int err = -EOPNOTSUPP;
 
 	if (ops && ops->switchdev_port_attr_set)
-		return ops->switchdev_port_attr_set(dev, attr);
+		return ops->switchdev_port_attr_set(dev, attr, trans);
 
 	if (attr->flags & SWITCHDEV_F_NO_RECURSE)
 		return err;
@@ -81,7 +131,7 @@ static int __switchdev_port_attr_set(struct net_device *dev,
 	 */
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = __switchdev_port_attr_set(lower_dev, attr);
+		err = __switchdev_port_attr_set(lower_dev, attr, trans);
 		if (err)
 			break;
 	}
@@ -144,6 +194,7 @@ static int switchdev_port_attr_set_defer(struct net_device *dev,
  */
 int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 {
+	struct switchdev_trans trans;
 	int err;
 
 	if (!rtnl_is_locked()) {
@@ -156,6 +207,8 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 		return switchdev_port_attr_set_defer(dev, attr);
 	}
 
+	switchdev_trans_init(&trans);
+
 	/* Phase I: prepare for attr set. Driver/device should fail
 	 * here if there are going to be issues in the commit phase,
 	 * such as lack of resources or support.  The driver/device
@@ -164,7 +217,7 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 	 */
 
 	attr->trans_ph = SWITCHDEV_TRANS_PREPARE;
-	err = __switchdev_port_attr_set(dev, attr);
+	err = __switchdev_port_attr_set(dev, attr, &trans);
 	if (err) {
 		/* Prepare phase failed: abort the transaction.  Any
 		 * resources reserved in the prepare phase are
@@ -173,7 +226,8 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 
 		if (err != -EOPNOTSUPP) {
 			attr->trans_ph = SWITCHDEV_TRANS_ABORT;
-			__switchdev_port_attr_set(dev, attr);
+			__switchdev_port_attr_set(dev, attr, &trans);
+			switchdev_trans_items_destroy(&trans);
 		}
 
 		return err;
@@ -185,16 +239,18 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 	 */
 
 	attr->trans_ph = SWITCHDEV_TRANS_COMMIT;
-	err = __switchdev_port_attr_set(dev, attr);
+	err = __switchdev_port_attr_set(dev, attr, &trans);
 	WARN(err, "%s: Commit of attribute (id=%d) failed.\n",
 	     dev->name, attr->id);
+	switchdev_trans_items_destroy(&trans);
 
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
@@ -202,7 +258,7 @@ static int __switchdev_port_obj_add(struct net_device *dev,
 	int err = -EOPNOTSUPP;
 
 	if (ops && ops->switchdev_port_obj_add)
-		return ops->switchdev_port_obj_add(dev, obj);
+		return ops->switchdev_port_obj_add(dev, obj, trans);
 
 	/* Switch device port(s) may be stacked under
 	 * bond/team/vlan dev, so recurse down to add object on
@@ -210,7 +266,7 @@ static int __switchdev_port_obj_add(struct net_device *dev,
 	 */
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = __switchdev_port_obj_add(lower_dev, obj);
+		err = __switchdev_port_obj_add(lower_dev, obj, trans);
 		if (err)
 			break;
 	}
@@ -232,10 +288,13 @@ static int __switchdev_port_obj_add(struct net_device *dev,
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
@@ -244,7 +303,7 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 	 */
 
 	obj->trans_ph = SWITCHDEV_TRANS_PREPARE;
-	err = __switchdev_port_obj_add(dev, obj);
+	err = __switchdev_port_obj_add(dev, obj, &trans);
 	if (err) {
 		/* Prepare phase failed: abort the transaction.  Any
 		 * resources reserved in the prepare phase are
@@ -253,7 +312,8 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 
 		if (err != -EOPNOTSUPP) {
 			obj->trans_ph = SWITCHDEV_TRANS_ABORT;
-			__switchdev_port_obj_add(dev, obj);
+			__switchdev_port_obj_add(dev, obj, &trans);
+			switchdev_trans_items_destroy(&trans);
 		}
 
 		return err;
@@ -265,8 +325,9 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 	 */
 
 	obj->trans_ph = SWITCHDEV_TRANS_COMMIT;
-	err = __switchdev_port_obj_add(dev, obj);
+	err = __switchdev_port_obj_add(dev, obj, &trans);
 	WARN(err, "%s: Commit of object (id=%d) failed.\n", dev->name, obj->id);
+	switchdev_trans_items_destroy(&trans);
 
 	return err;
 }
-- 
1.9.3
