From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/10] switchdev: move transaction phase enum under transaction structure
Date: Tue, 22 Sep 2015 15:53:45 +0200
Message-ID: <1442930031-4732-4-git-send-email-jiri@resnulli.us>
References: <1442930031-4732-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:32944 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933217AbbIVNx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 09:53:58 -0400
Received: by wiclk2 with SMTP id lk2so194182634wic.0
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 06:53:57 -0700 (PDT)
In-Reply-To: <1442930031-4732-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Before it disappears completely, move transaction phase enum under
transaction structure and make attr/obj structures a bit cleaner.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.c | 17 +++++++++--------
 include/net/switchdev.h              |  3 +--
 net/dsa/slave.c                      | 18 ++++++++++--------
 net/switchdev/switchdev.c            | 12 ++++++------
 4 files changed, 26 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 92e1520..45e500f 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4346,7 +4346,7 @@ static int rocker_port_attr_set(struct net_device *dev,
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	int err = 0;
 
-	switch (attr->trans_ph) {
+	switch (trans->ph) {
 	case SWITCHDEV_TRANS_PREPARE:
 		BUG_ON(!list_empty(&rocker_port->trans_mem));
 		break;
@@ -4359,12 +4359,12 @@ static int rocker_port_attr_set(struct net_device *dev,
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
-		err = rocker_port_stp_update(rocker_port, attr->trans_ph,
+		err = rocker_port_stp_update(rocker_port, trans->ph,
 					     ROCKER_OP_FLAG_NOWAIT,
 					     attr->u.stp_state);
 		break;
 	case SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS:
-		err = rocker_port_brport_flags_set(rocker_port, attr->trans_ph,
+		err = rocker_port_brport_flags_set(rocker_port, trans->ph,
 						   attr->u.brport_flags);
 		break;
 	default:
@@ -4432,7 +4432,7 @@ static int rocker_port_obj_add(struct net_device *dev,
 	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
-	switch (obj->trans_ph) {
+	switch (trans->ph) {
 	case SWITCHDEV_TRANS_PREPARE:
 		BUG_ON(!list_empty(&rocker_port->trans_mem));
 		break;
@@ -4445,17 +4445,17 @@ static int rocker_port_obj_add(struct net_device *dev,
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
-		err = rocker_port_vlans_add(rocker_port, obj->trans_ph,
+		err = rocker_port_vlans_add(rocker_port, trans->ph,
 					    &obj->u.vlan);
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
 		fib4 = &obj->u.ipv4_fib;
-		err = rocker_port_fib_ipv4(rocker_port, obj->trans_ph,
+		err = rocker_port_fib_ipv4(rocker_port, trans->ph,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id, 0);
 		break;
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_add(rocker_port, obj->trans_ph, &obj->u.fdb);
+		err = rocker_port_fdb_add(rocker_port, trans->ph, &obj->u.fdb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -4526,7 +4526,8 @@ static int rocker_port_obj_del(struct net_device *dev,
 					   ROCKER_OP_FLAG_REMOVE);
 		break;
 	case SWITCHDEV_OBJ_PORT_FDB:
-		err = rocker_port_fdb_del(rocker_port, obj->trans_ph, &obj->u.fdb);
+		err = rocker_port_fdb_del(rocker_port, SWITCHDEV_TRANS_NONE,
+					  &obj->u.fdb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
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
index 55a8411..221a6a4 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -214,7 +214,7 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 	 * but should not commit the attr.
 	 */
 
-	attr->trans_ph = SWITCHDEV_TRANS_PREPARE;
+	trans.ph = SWITCHDEV_TRANS_PREPARE;
 	err = __switchdev_port_attr_set(dev, attr, &trans);
 	if (err) {
 		/* Prepare phase failed: abort the transaction.  Any
@@ -223,7 +223,7 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 		 */
 
 		if (err != -EOPNOTSUPP) {
-			attr->trans_ph = SWITCHDEV_TRANS_ABORT;
+			trans.ph = SWITCHDEV_TRANS_ABORT;
 			__switchdev_port_attr_set(dev, attr, &trans);
 			switchdev_trans_items_destroy(&trans);
 		}
@@ -236,7 +236,7 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 	 * because the driver said everythings was OK in phase I.
 	 */
 
-	attr->trans_ph = SWITCHDEV_TRANS_COMMIT;
+	trans.ph = SWITCHDEV_TRANS_COMMIT;
 	err = __switchdev_port_attr_set(dev, attr, &trans);
 	WARN(err, "%s: Commit of attribute (id=%d) failed.\n",
 	     dev->name, attr->id);
@@ -300,7 +300,7 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 	 * but should not commit the obj.
 	 */
 
-	obj->trans_ph = SWITCHDEV_TRANS_PREPARE;
+	trans.ph = SWITCHDEV_TRANS_PREPARE;
 	err = __switchdev_port_obj_add(dev, obj, &trans);
 	if (err) {
 		/* Prepare phase failed: abort the transaction.  Any
@@ -309,7 +309,7 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 		 */
 
 		if (err != -EOPNOTSUPP) {
-			obj->trans_ph = SWITCHDEV_TRANS_ABORT;
+			trans.ph = SWITCHDEV_TRANS_ABORT;
 			__switchdev_port_obj_add(dev, obj, &trans);
 			switchdev_trans_items_destroy(&trans);
 		}
@@ -322,7 +322,7 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 	 * because the driver said everythings was OK in phase I.
 	 */
 
-	obj->trans_ph = SWITCHDEV_TRANS_COMMIT;
+	trans.ph = SWITCHDEV_TRANS_COMMIT;
 	err = __switchdev_port_obj_add(dev, obj, &trans);
 	WARN(err, "%s: Commit of object (id=%d) failed.\n", dev->name, obj->id);
 	switchdev_trans_items_destroy(&trans);
-- 
1.9.3
