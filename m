From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 4/6] switchdev: move transaction phase enum under transaction structure
Date: Sat, 19 Sep 2015 14:29:09 +0200
Message-ID: <1442665751-10949-5-git-send-email-jiri@resnulli.us>
References: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:34469 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753071AbbISM3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 08:29:22 -0400
Received: by wicfx3 with SMTP id fx3so93204470wic.1
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 05:29:21 -0700 (PDT)
In-Reply-To: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before it disappears completely, move transaction phase enum under
transaction structure and make attr/obj structures a bit cleaner.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c |  4 ++--
 include/net/switchdev.h              |  3 +--
 net/dsa/slave.c                      | 18 ++++++++++--------
 net/switchdev/switchdev.c            | 12 ++++++------
 4 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index de1a367..9750840 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4356,7 +4356,7 @@ static int rocker_port_attr_set(struct net_device *dev,
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	struct rocker_trans rtrans = {
-		.ph = attr->trans_ph,
+		.ph = trans->ph,
 	};
 	int err = 0;
 
@@ -4444,7 +4444,7 @@ static int rocker_port_obj_add(struct net_device *dev,
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	struct rocker_trans rtrans = {
-		.ph = obj->trans_ph,
+		.ph = trans->ph,
 	};
 	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 1e394f1..368a642 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -32,6 +32,7 @@ struct switchdev_trans_item {
 
 struct switchdev_trans {
 	struct list_head item_list;
+	enum switchdev_trans_ph ph;
 };
 
 enum switchdev_attr_id {
@@ -43,7 +44,6 @@ enum switchdev_attr_id {
 
 struct switchdev_attr {
 	enum switchdev_attr_id id;
-	enum switchdev_trans_ph trans_ph;
 	u32 flags;
 	union {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
@@ -63,7 +63,6 @@ enum switchdev_obj_id {
 
 struct switchdev_obj {
 	enum switchdev_obj_id id;
-	enum switchdev_trans_ph trans_ph;
 	int (*cb)(struct net_device *dev, struct switchdev_obj *obj);
 	union {
 		struct switchdev_obj_vlan {		/* PORT_VLAN */
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index ac76fd1..748cc63 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -242,7 +242,8 @@ static int dsa_bridge_check_vlan_range(struct dsa_switch *ds,
 }
 
 static int dsa_slave_port_vlan_add(struct net_device *dev,
-				   struct switchdev_obj *obj)
+				   struct switchdev_obj *obj,
+				   struct switchdev_trans *trans)
 {
 	struct switchdev_obj_vlan *vlan = &obj->u.vlan;
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -250,7 +251,7 @@ static int dsa_slave_port_vlan_add(struct net_device *dev,
 	u16 vid;
 	int err;
 
-	switch (obj->trans_ph) {
+	switch (trans->ph) {
 	case SWITCHDEV_TRANS_PREPARE:
 		if (!ds->drv->port_vlan_add || !ds->drv->port_pvid_set)
 			return -EOPNOTSUPP;
@@ -347,16 +348,17 @@ static int dsa_slave_port_vlan_dump(struct net_device *dev,
 }
 
 static int dsa_slave_port_fdb_add(struct net_device *dev,
-				  struct switchdev_obj *obj)
+				  struct switchdev_obj *obj,
+				  struct switchdev_trans *trans)
 {
 	struct switchdev_obj_fdb *fdb = &obj->u.fdb;
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 	int ret = -EOPNOTSUPP;
 
-	if (obj->trans_ph == SWITCHDEV_TRANS_PREPARE)
+	if (trans->ph == SWITCHDEV_TRANS_PREPARE)
 		ret = ds->drv->port_fdb_add ? 0 : -EOPNOTSUPP;
-	else if (obj->trans_ph == SWITCHDEV_TRANS_COMMIT)
+	else if (trans->ph == SWITCHDEV_TRANS_COMMIT)
 		ret = ds->drv->port_fdb_add(ds, p->port, fdb->addr, fdb->vid);
 
 	return ret;
@@ -463,7 +465,7 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
-		if (attr->trans_ph == SWITCHDEV_TRANS_COMMIT)
+		if (trans->ph == SWITCHDEV_TRANS_COMMIT)
 			ret = dsa_slave_stp_update(dev, attr->u.stp_state);
 		break;
 	default:
@@ -487,10 +489,10 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = dsa_slave_port_fdb_add(dev, obj);
+		err = dsa_slave_port_fdb_add(dev, obj, trans);
 		break;
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = dsa_slave_port_vlan_add(dev, obj);
+		err = dsa_slave_port_vlan_add(dev, obj, trans);
 		break;
 	default:
 		err = -EOPNOTSUPP;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index a3647bf..82f8bcd 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -216,7 +216,7 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 	 * but should not commit the attr.
 	 */
 
-	attr->trans_ph = SWITCHDEV_TRANS_PREPARE;
+	trans.ph = SWITCHDEV_TRANS_PREPARE;
 	err = __switchdev_port_attr_set(dev, attr, &trans);
 	if (err) {
 		/* Prepare phase failed: abort the transaction.  Any
@@ -225,7 +225,7 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 		 */
 
 		if (err != -EOPNOTSUPP) {
-			attr->trans_ph = SWITCHDEV_TRANS_ABORT;
+			trans.ph = SWITCHDEV_TRANS_ABORT;
 			__switchdev_port_attr_set(dev, attr, &trans);
 			switchdev_trans_items_destroy(&trans);
 		}
@@ -238,7 +238,7 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 	 * because the driver said everythings was OK in phase I.
 	 */
 
-	attr->trans_ph = SWITCHDEV_TRANS_COMMIT;
+	trans.ph = SWITCHDEV_TRANS_COMMIT;
 	err = __switchdev_port_attr_set(dev, attr, &trans);
 	WARN(err, "%s: Commit of attribute (id=%d) failed.\n",
 	     dev->name, attr->id);
@@ -302,7 +302,7 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 	 * but should not commit the obj.
 	 */
 
-	obj->trans_ph = SWITCHDEV_TRANS_PREPARE;
+	trans.ph = SWITCHDEV_TRANS_PREPARE;
 	err = __switchdev_port_obj_add(dev, obj, &trans);
 	if (err) {
 		/* Prepare phase failed: abort the transaction.  Any
@@ -311,7 +311,7 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 		 */
 
 		if (err != -EOPNOTSUPP) {
-			obj->trans_ph = SWITCHDEV_TRANS_ABORT;
+			trans.ph = SWITCHDEV_TRANS_ABORT;
 			__switchdev_port_obj_add(dev, obj, &trans);
 			switchdev_trans_items_destroy(&trans);
 		}
@@ -324,7 +324,7 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 	 * because the driver said everythings was OK in phase I.
 	 */
 
-	obj->trans_ph = SWITCHDEV_TRANS_COMMIT;
+	trans.ph = SWITCHDEV_TRANS_COMMIT;
 	err = __switchdev_port_obj_add(dev, obj, &trans);
 	WARN(err, "%s: Commit of object (id=%d) failed.\n", dev->name, obj->id);
 	switchdev_trans_items_destroy(&trans);
-- 
1.9.3
