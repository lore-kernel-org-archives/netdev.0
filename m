From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 6/6] switchdev: split commit and prepare phase into two callbacks
Date: Sat, 19 Sep 2015 14:29:11 +0200
Message-ID: <1442665751-10949-7-git-send-email-jiri@resnulli.us>
References: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:33064 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753970AbbISM30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 08:29:26 -0400
Received: by wiclk2 with SMTP id lk2so93499639wic.0
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 05:29:25 -0700 (PDT)
In-Reply-To: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is nore convenient to have prepare and commit phase for attr_set and
obj_add as separete callbacks. If a driver needs to do it differently, it
can easily do in inside its code.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c |  88 +++++++++++++++++++-------
 include/net/switchdev.h              |  18 +++---
 net/dsa/slave.c                      | 117 +++++++++++++++++++++++------------
 net/switchdev/switchdev.c            |  74 +++++++++++++++++-----
 4 files changed, 210 insertions(+), 87 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 0735d90..42aa86c 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4333,35 +4333,55 @@ static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
 	return err;
 }
 
-static int rocker_port_attr_set(struct net_device *dev,
-				struct switchdev_attr *attr,
-				struct switchdev_trans *trans)
+static int __rocker_port_attr_set(struct rocker_port *rocker_port,
+				  struct switchdev_attr *attr,
+				  struct rocker_trans *rtrans)
 {
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	struct rocker_trans rtrans = {
-		.ph = trans->ph,
-		.trans = trans,
-	};
 	int err = 0;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
-		err = rocker_port_stp_update(rocker_port, &rtrans,
+		err = rocker_port_stp_update(rocker_port, rtrans,
 					     ROCKER_OP_FLAG_NOWAIT,
 					     attr->u.stp_state);
 		break;
 	case SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS:
-		err = rocker_port_brport_flags_set(rocker_port, &rtrans,
+		err = rocker_port_brport_flags_set(rocker_port, rtrans,
 						   attr->u.brport_flags);
 		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
 	}
-
 	return err;
 }
 
+static int rocker_port_attr_pre_set(struct net_device *dev,
+				    struct switchdev_attr *attr,
+				    struct switchdev_trans *trans)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct rocker_trans rtrans = {
+		.ph = ROCKER_TRANS_PH_PREPARE,
+		.trans = trans,
+	};
+
+	return __rocker_port_attr_set(rocker_port, attr, &rtrans);
+}
+
+static int rocker_port_attr_set(struct net_device *dev,
+				struct switchdev_attr *attr,
+				struct switchdev_trans *trans)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct rocker_trans rtrans = {
+		.ph = ROCKER_TRANS_PH_COMMIT,
+		.trans = trans,
+	};
+
+	return __rocker_port_attr_set(rocker_port, attr, &rtrans);
+}
+
 static int rocker_port_vlan_add(struct rocker_port *rocker_port,
 				struct rocker_trans *rtrans, u16 vid, u16 flags)
 {
@@ -4411,40 +4431,60 @@ static int rocker_port_fdb_add(struct rocker_port *rocker_port,
 	return rocker_port_fdb(rocker_port, rtrans, fdb->addr, vlan_id, flags);
 }
 
-static int rocker_port_obj_add(struct net_device *dev,
-			       struct switchdev_obj *obj,
-			       struct switchdev_trans *trans)
+static int __rocker_port_obj_add(struct rocker_port *rocker_port,
+				 struct switchdev_obj *obj,
+				 struct rocker_trans *rtrans)
 {
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	struct rocker_trans rtrans = {
-		.ph = trans->ph,
-		.trans = trans,
-	};
 	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = rocker_port_vlans_add(rocker_port, &rtrans,
+		err = rocker_port_vlans_add(rocker_port, rtrans,
 					    &obj->u.vlan);
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
 		fib4 = &obj->u.ipv4_fib;
-		err = rocker_port_fib_ipv4(rocker_port, &rtrans,
+		err = rocker_port_fib_ipv4(rocker_port, rtrans,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id, 0);
 		break;
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_add(rocker_port, &rtrans, &obj->u.fdb);
+		err = rocker_port_fdb_add(rocker_port, rtrans, &obj->u.fdb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
 	}
-
 	return err;
 }
 
+static int rocker_port_obj_pre_add(struct net_device *dev,
+				   struct switchdev_obj *obj,
+				   struct switchdev_trans *trans)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct rocker_trans rtrans = {
+		.ph = ROCKER_TRANS_PH_PREPARE,
+		.trans = trans,
+	};
+
+	return __rocker_port_obj_add(rocker_port, obj, &rtrans);
+}
+
+static int rocker_port_obj_add(struct net_device *dev,
+			       struct switchdev_obj *obj,
+			       struct switchdev_trans *trans)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct rocker_trans rtrans = {
+		.ph = ROCKER_TRANS_PH_COMMIT,
+		.trans = trans,
+	};
+
+	return __rocker_port_obj_add(rocker_port, obj, &rtrans);
+}
+
 static int rocker_port_vlan_del(struct rocker_port *rocker_port,
 				u16 vid, u16 flags)
 {
@@ -4593,7 +4633,9 @@ static int rocker_port_obj_dump(struct net_device *dev,
 
 static const struct switchdev_ops rocker_port_switchdev_ops = {
 	.switchdev_port_attr_get	= rocker_port_attr_get,
+	.switchdev_port_attr_pre_set	= rocker_port_attr_pre_set,
 	.switchdev_port_attr_set	= rocker_port_attr_set,
+	.switchdev_port_obj_pre_add	= rocker_port_obj_pre_add,
 	.switchdev_port_obj_add		= rocker_port_obj_add,
 	.switchdev_port_obj_del		= rocker_port_obj_del,
 	.switchdev_port_obj_dump	= rocker_port_obj_dump,
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 368a642..30f62f3 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -17,13 +17,6 @@
 
 #define SWITCHDEV_F_NO_RECURSE		BIT(0)
 
-enum switchdev_trans_ph {
-	SWITCHDEV_TRANS_NONE,
-	SWITCHDEV_TRANS_PREPARE,
-	SWITCHDEV_TRANS_ABORT,
-	SWITCHDEV_TRANS_COMMIT,
-};
-
 struct switchdev_trans_item {
 	struct list_head list;
 	void *data;
@@ -32,7 +25,6 @@ struct switchdev_trans_item {
 
 struct switchdev_trans {
 	struct list_head item_list;
-	enum switchdev_trans_ph ph;
 };
 
 enum switchdev_attr_id {
@@ -97,8 +89,12 @@ void *switchdev_trans_item_dequeue(struct switchdev_trans *trans);
  *
  * @switchdev_port_attr_get: Get a port attribute (see switchdev_attr).
  *
+ * @switchdev_port_attr_pre_set: Prepare to set a port attribute (see switchdev_attr).
+ *
  * @switchdev_port_attr_set: Set a port attribute (see switchdev_attr).
  *
+ * @switchdev_port_obj_pre_add: Prepare to add an object to port (see switchdev_obj).
+ *
  * @switchdev_port_obj_add: Add an object to port (see switchdev_obj).
  *
  * @switchdev_port_obj_del: Delete an object from port (see switchdev_obj).
@@ -108,9 +104,15 @@ void *switchdev_trans_item_dequeue(struct switchdev_trans *trans);
 struct switchdev_ops {
 	int	(*switchdev_port_attr_get)(struct net_device *dev,
 					   struct switchdev_attr *attr);
+	int	(*switchdev_port_attr_pre_set)(struct net_device *dev,
+					       struct switchdev_attr *attr,
+					       struct switchdev_trans *trans);
 	int	(*switchdev_port_attr_set)(struct net_device *dev,
 					   struct switchdev_attr *attr,
 					   struct switchdev_trans *trans);
+	int	(*switchdev_port_obj_pre_add)(struct net_device *dev,
+					      struct switchdev_obj *obj,
+					      struct switchdev_trans *trans);
 	int	(*switchdev_port_obj_add)(struct net_device *dev,
 					  struct switchdev_obj *obj,
 					  struct switchdev_trans *trans);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 748cc63..ed773bc 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -241,6 +241,29 @@ static int dsa_bridge_check_vlan_range(struct dsa_switch *ds,
 	return err == -ENOENT ? 0 : err;
 }
 
+static int dsa_slave_port_vlan_pre_add(struct net_device *dev,
+				       struct switchdev_obj *obj,
+				       struct switchdev_trans *trans)
+{
+	struct switchdev_obj_vlan *vlan = &obj->u.vlan;
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int err;
+
+	if (!ds->drv->port_vlan_add || !ds->drv->port_pvid_set)
+		return -EOPNOTSUPP;
+
+	/* If the requested port doesn't belong to the same bridge as
+	 * the VLAN members, fallback to software VLAN (hopefully).
+	 */
+	err = dsa_bridge_check_vlan_range(ds, p->bridge_dev,
+					  vlan->vid_begin,
+					  vlan->vid_end);
+	if (err)
+		return err;
+	return 0;
+}
+
 static int dsa_slave_port_vlan_add(struct net_device *dev,
 				   struct switchdev_obj *obj,
 				   struct switchdev_trans *trans)
@@ -251,35 +274,15 @@ static int dsa_slave_port_vlan_add(struct net_device *dev,
 	u16 vid;
 	int err;
 
-	switch (trans->ph) {
-	case SWITCHDEV_TRANS_PREPARE:
-		if (!ds->drv->port_vlan_add || !ds->drv->port_pvid_set)
-			return -EOPNOTSUPP;
-
-		/* If the requested port doesn't belong to the same bridge as
-		 * the VLAN members, fallback to software VLAN (hopefully).
-		 */
-		err = dsa_bridge_check_vlan_range(ds, p->bridge_dev,
-						  vlan->vid_begin,
-						  vlan->vid_end);
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
+		err = ds->drv->port_vlan_add(ds, p->port, vid,
+					     vlan->flags &
+					     BRIDGE_VLAN_INFO_UNTAGGED);
+		if (!err && vlan->flags & BRIDGE_VLAN_INFO_PVID)
+			err = ds->drv->port_pvid_set(ds, p->port, vid);
 		if (err)
 			return err;
-		break;
-	case SWITCHDEV_TRANS_COMMIT:
-		for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
-			err = ds->drv->port_vlan_add(ds, p->port, vid,
-						     vlan->flags &
-						     BRIDGE_VLAN_INFO_UNTAGGED);
-			if (!err && vlan->flags & BRIDGE_VLAN_INFO_PVID)
-				err = ds->drv->port_pvid_set(ds, p->port, vid);
-			if (err)
-				return err;
-		}
-		break;
-	default:
-		return -EOPNOTSUPP;
 	}
-
 	return 0;
 }
 
@@ -347,6 +350,16 @@ static int dsa_slave_port_vlan_dump(struct net_device *dev,
 	return err == -ENOENT ? 0 : err;
 }
 
+static int dsa_slave_port_fdb_pre_add(struct net_device *dev,
+				      struct switchdev_obj *obj,
+				      struct switchdev_trans *trans)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	return ds->drv->port_fdb_add ? 0 : -EOPNOTSUPP;
+}
+
 static int dsa_slave_port_fdb_add(struct net_device *dev,
 				  struct switchdev_obj *obj,
 				  struct switchdev_trans *trans)
@@ -354,14 +367,8 @@ static int dsa_slave_port_fdb_add(struct net_device *dev,
 	struct switchdev_obj_fdb *fdb = &obj->u.fdb;
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
-	int ret = -EOPNOTSUPP;
-
-	if (trans->ph == SWITCHDEV_TRANS_PREPARE)
-		ret = ds->drv->port_fdb_add ? 0 : -EOPNOTSUPP;
-	else if (trans->ph == SWITCHDEV_TRANS_COMMIT)
-		ret = ds->drv->port_fdb_add(ds, p->port, fdb->addr, fdb->vid);
 
-	return ret;
+	return ds->drv->port_fdb_add(ds, p->port, fdb->addr, fdb->vid);
 }
 
 static int dsa_slave_port_fdb_del(struct net_device *dev,
@@ -457,17 +464,24 @@ static int dsa_slave_stp_update(struct net_device *dev, u8 state)
 	return ret;
 }
 
+static int dsa_slave_port_attr_pre_set(struct net_device *dev,
+				       struct switchdev_attr *attr,
+				       struct switchdev_trans *trans)
+{
+	if (attr->id != SWITCHDEV_ATTR_PORT_STP_STATE)
+		return -EOPNOTSUPP;
+	return 0;
+}
+
 static int dsa_slave_port_attr_set(struct net_device *dev,
 				   struct switchdev_attr *attr,
 				   struct switchdev_trans *trans)
 {
-	int ret = 0;
+	int ret;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
-		if (trans->ph == SWITCHDEV_TRANS_COMMIT)
-			ret = dsa_slave_stp_update(dev, attr->u.stp_state);
-		break;
+		ret = dsa_slave_stp_update(dev, attr->u.stp_state);
 	default:
 		ret = -EOPNOTSUPP;
 		break;
@@ -476,9 +490,9 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 	return ret;
 }
 
-static int dsa_slave_port_obj_add(struct net_device *dev,
-				  struct switchdev_obj *obj,
-				  struct switchdev_trans *trans)
+static int dsa_slave_port_obj_pre_add(struct net_device *dev,
+				      struct switchdev_obj *obj,
+				      struct switchdev_trans *trans)
 {
 	int err;
 
@@ -489,6 +503,27 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_FDB:
+		err = dsa_slave_port_fdb_pre_add(dev, obj, trans);
+		break;
+	case SWITCHDEV_OBJ_PORT_VLAN:
+		err = dsa_slave_port_vlan_pre_add(dev, obj, trans);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
+static int dsa_slave_port_obj_add(struct net_device *dev,
+				  struct switchdev_obj *obj,
+				  struct switchdev_trans *trans)
+{
+	int err;
+
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_PORT_FDB:
 		err = dsa_slave_port_fdb_add(dev, obj, trans);
 		break;
 	case SWITCHDEV_OBJ_PORT_VLAN:
@@ -960,7 +995,9 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 
 static const struct switchdev_ops dsa_slave_switchdev_ops = {
 	.switchdev_port_attr_get	= dsa_slave_port_attr_get,
+	.switchdev_port_attr_pre_set	= dsa_slave_port_attr_pre_set,
 	.switchdev_port_attr_set	= dsa_slave_port_attr_set,
+	.switchdev_port_obj_pre_add	= dsa_slave_port_obj_pre_add,
 	.switchdev_port_obj_add		= dsa_slave_port_obj_add,
 	.switchdev_port_obj_del		= dsa_slave_port_obj_del,
 	.switchdev_port_obj_dump	= dsa_slave_port_obj_dump,
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 82f8bcd..9278643 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -110,6 +110,34 @@ int switchdev_port_attr_get(struct net_device *dev, struct switchdev_attr *attr)
 }
 EXPORT_SYMBOL_GPL(switchdev_port_attr_get);
 
+static int __switchdev_port_attr_pre_set(struct net_device *dev,
+					 struct switchdev_attr *attr,
+					 struct switchdev_trans *trans)
+{
+	const struct switchdev_ops *ops = dev->switchdev_ops;
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	int err = -EOPNOTSUPP;
+
+	if (ops && ops->switchdev_port_attr_pre_set)
+		return ops->switchdev_port_attr_pre_set(dev, attr, trans);
+
+	if (attr->flags & SWITCHDEV_F_NO_RECURSE)
+		return err;
+
+	/* Switch device port(s) may be stacked under
+	 * bond/team/vlan dev, so recurse down to prepare to set attr on
+	 * each port.
+	 */
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = __switchdev_port_attr_pre_set(lower_dev, attr, trans);
+		if (err)
+			break;
+	}
+
+	return err;
+}
 static int __switchdev_port_attr_set(struct net_device *dev,
 				     struct switchdev_attr *attr,
 				     struct switchdev_trans *trans)
@@ -216,20 +244,15 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 	 * but should not commit the attr.
 	 */
 
-	trans.ph = SWITCHDEV_TRANS_PREPARE;
-	err = __switchdev_port_attr_set(dev, attr, &trans);
+	err = __switchdev_port_attr_pre_set(dev, attr, &trans);
 	if (err) {
 		/* Prepare phase failed: abort the transaction.  Any
 		 * resources reserved in the prepare phase are
 		 * released.
 		 */
 
-		if (err != -EOPNOTSUPP) {
-			trans.ph = SWITCHDEV_TRANS_ABORT;
-			__switchdev_port_attr_set(dev, attr, &trans);
+		if (err != -EOPNOTSUPP)
 			switchdev_trans_items_destroy(&trans);
-		}
-
 		return err;
 	}
 
@@ -238,7 +261,6 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 	 * because the driver said everythings was OK in phase I.
 	 */
 
-	trans.ph = SWITCHDEV_TRANS_COMMIT;
 	err = __switchdev_port_attr_set(dev, attr, &trans);
 	WARN(err, "%s: Commit of attribute (id=%d) failed.\n",
 	     dev->name, attr->id);
@@ -274,6 +296,32 @@ static int __switchdev_port_obj_add(struct net_device *dev,
 	return err;
 }
 
+static int __switchdev_port_obj_pre_add(struct net_device *dev,
+					struct switchdev_obj *obj,
+					struct switchdev_trans *trans)
+{
+	const struct switchdev_ops *ops = dev->switchdev_ops;
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	int err = -EOPNOTSUPP;
+
+	if (ops && ops->switchdev_port_obj_pre_add)
+		return ops->switchdev_port_obj_pre_add(dev, obj, trans);
+
+	/* Switch device port(s) may be stacked under
+	 * bond/team/vlan dev, so recurse down to prepare to add object on
+	 * each port.
+	 */
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = __switchdev_port_obj_pre_add(lower_dev, obj, trans);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
 /**
  *	switchdev_port_obj_add - Add port object
  *
@@ -302,20 +350,15 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 	 * but should not commit the obj.
 	 */
 
-	trans.ph = SWITCHDEV_TRANS_PREPARE;
-	err = __switchdev_port_obj_add(dev, obj, &trans);
+	err = __switchdev_port_obj_pre_add(dev, obj, &trans);
 	if (err) {
 		/* Prepare phase failed: abort the transaction.  Any
 		 * resources reserved in the prepare phase are
 		 * released.
 		 */
 
-		if (err != -EOPNOTSUPP) {
-			trans.ph = SWITCHDEV_TRANS_ABORT;
-			__switchdev_port_obj_add(dev, obj, &trans);
+		if (err != -EOPNOTSUPP)
 			switchdev_trans_items_destroy(&trans);
-		}
-
 		return err;
 	}
 
@@ -324,7 +367,6 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 	 * because the driver said everythings was OK in phase I.
 	 */
 
-	trans.ph = SWITCHDEV_TRANS_COMMIT;
 	err = __switchdev_port_obj_add(dev, obj, &trans);
 	WARN(err, "%s: Commit of object (id=%d) failed.\n", dev->name, obj->id);
 	switchdev_trans_items_destroy(&trans);
-- 
1.9.3
