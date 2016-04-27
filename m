From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 16/20] net: dsa: add tree-wide VLAN ops
Date: Wed, 27 Apr 2016 18:30:13 -0400
Message-ID: <1461796217-18893-17-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39244 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753940AbcD0WbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 18:31:04 -0400
In-Reply-To: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to support cross-chip operations, we need to inform each switch
driver when a port operation occurs in a DSA tree.

Implement tree-wide VLAN operations.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 12 +++++++++
 net/dsa/dsa_priv.h          |  8 ++++++
 net/dsa/slave.c             | 59 ++++++--------------------------------------
 net/dsa/tree.c              | 60 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 87 insertions(+), 52 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 7d29de3..8004d00 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1378,6 +1378,9 @@ int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, struct dsa_port *dp,
 	u16 pvid;
 	int err;
 
+	if (dsa_port_is_external(dp, ds))
+		return -EOPNOTSUPP;
+
 	mutex_lock(&ps->smi_mutex);
 
 	err = _mv88e6xxx_port_pvid_get(ds, dp->port, &pvid);
@@ -1835,6 +1838,9 @@ int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, struct dsa_port *dp,
 {
 	int err;
 
+	if (dsa_port_is_external(dp, ds))
+		return -EOPNOTSUPP;
+
 	/* If the requested port doesn't belong to the same bridge as the VLAN
 	 * members, do not support it (yet) and fallback to software VLAN.
 	 */
@@ -1874,6 +1880,9 @@ void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, struct dsa_port *dp,
 	bool pvid = vlan->flags & BRIDGE_VLAN_INFO_PVID;
 	u16 vid;
 
+	if (dsa_port_is_external(dp, ds))
+		return;
+
 	mutex_lock(&ps->smi_mutex);
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid)
@@ -1930,6 +1939,9 @@ int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, struct dsa_port *dp,
 	u16 pvid, vid;
 	int err = 0;
 
+	if (dsa_port_is_external(dp, ds))
+		return -EOPNOTSUPP;
+
 	mutex_lock(&ps->smi_mutex);
 
 	err = _mv88e6xxx_port_pvid_get(ds, dp->port, &pvid);
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index e8765c3..d743d6a 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -60,6 +60,14 @@ int dsa_tree_port_fdb_del(struct dsa_switch_tree *dst, struct dsa_port *dp,
 int dsa_tree_port_fdb_dump(struct dsa_switch_tree *dst, struct dsa_port *dp,
 			   struct switchdev_obj_port_fdb *fdb,
 			   switchdev_obj_dump_cb_t *cb);
+int dsa_tree_port_vlan_add(struct dsa_switch_tree *dst, struct dsa_port *dp,
+			   const struct switchdev_obj_port_vlan *vlan,
+			   struct switchdev_trans *trans);
+int dsa_tree_port_vlan_del(struct dsa_switch_tree *dst, struct dsa_port *dp,
+			   const struct switchdev_obj_port_vlan *vlan);
+int dsa_tree_port_vlan_dump(struct dsa_switch_tree *dst, struct dsa_port *dp,
+			    struct switchdev_obj_port_vlan *vlan,
+			    switchdev_obj_dump_cb_t *cb);
 
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 90bcf8a..19469dc 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -195,50 +195,6 @@ out:
 	return 0;
 }
 
-static int dsa_slave_port_vlan_add(struct net_device *dev,
-				   const struct switchdev_obj_port_vlan *vlan,
-				   struct switchdev_trans *trans)
-{
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
-
-	if (switchdev_trans_ph_prepare(trans)) {
-		if (!ds->drv->port_vlan_prepare || !ds->drv->port_vlan_add)
-			return -EOPNOTSUPP;
-
-		return ds->drv->port_vlan_prepare(ds, p->dp, vlan, trans);
-	}
-
-	ds->drv->port_vlan_add(ds, p->dp, vlan, trans);
-
-	return 0;
-}
-
-static int dsa_slave_port_vlan_del(struct net_device *dev,
-				   const struct switchdev_obj_port_vlan *vlan)
-{
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
-
-	if (!ds->drv->port_vlan_del)
-		return -EOPNOTSUPP;
-
-	return ds->drv->port_vlan_del(ds, p->dp, vlan);
-}
-
-static int dsa_slave_port_vlan_dump(struct net_device *dev,
-				    struct switchdev_obj_port_vlan *vlan,
-				    switchdev_obj_dump_cb_t *cb)
-{
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
-
-	if (ds->drv->port_vlan_dump)
-		return ds->drv->port_vlan_dump(ds, p->dp, vlan, cb);
-
-	return -EOPNOTSUPP;
-}
-
 static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -323,9 +279,9 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 					    SWITCHDEV_OBJ_PORT_FDB(obj), trans);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
-		err = dsa_slave_port_vlan_add(dev,
-					      SWITCHDEV_OBJ_PORT_VLAN(obj),
-					      trans);
+		err = dsa_tree_port_vlan_add(dst, dp,
+					     SWITCHDEV_OBJ_PORT_VLAN(obj),
+					     trans);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -349,8 +305,8 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 					    SWITCHDEV_OBJ_PORT_FDB(obj));
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
-		err = dsa_slave_port_vlan_del(dev,
-					      SWITCHDEV_OBJ_PORT_VLAN(obj));
+		err = dsa_tree_port_vlan_del(dst, dp,
+					     SWITCHDEV_OBJ_PORT_VLAN(obj));
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -375,9 +331,8 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 					     SWITCHDEV_OBJ_PORT_FDB(obj), cb);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
-		err = dsa_slave_port_vlan_dump(dev,
-					       SWITCHDEV_OBJ_PORT_VLAN(obj),
-					       cb);
+		err = dsa_tree_port_vlan_dump(dst, dp,
+					      SWITCHDEV_OBJ_PORT_VLAN(obj), cb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
diff --git a/net/dsa/tree.c b/net/dsa/tree.c
index 8394019..0ef103e 100644
--- a/net/dsa/tree.c
+++ b/net/dsa/tree.c
@@ -125,3 +125,63 @@ int dsa_tree_port_fdb_dump(struct dsa_switch_tree *dst, struct dsa_port *dp,
 
 	return 0;
 }
+
+int dsa_tree_port_vlan_add(struct dsa_switch_tree *dst, struct dsa_port *dp,
+			    const struct switchdev_obj_port_vlan *vlan,
+			    struct switchdev_trans *trans)
+{
+	struct dsa_switch *ds;
+	int err;
+
+	dsa_tree_for_each_switch(dst, ds) {
+		if (switchdev_trans_ph_prepare(trans)) {
+			if (!ds->drv->port_vlan_prepare ||
+			    !ds->drv->port_vlan_add)
+				return -EOPNOTSUPP;
+
+			err = ds->drv->port_vlan_prepare(ds, dp, vlan, trans);
+			if (err)
+				return err;
+		} else {
+			ds->drv->port_vlan_add(ds, dp, vlan, trans);
+		}
+	}
+
+	return 0;
+}
+
+int dsa_tree_port_vlan_del(struct dsa_switch_tree *dst, struct dsa_port *dp,
+			    const struct switchdev_obj_port_vlan *vlan)
+{
+	struct dsa_switch *ds;
+	int err;
+
+	dsa_tree_for_each_switch(dst, ds) {
+		if (!ds->drv->port_vlan_del)
+			return -EOPNOTSUPP;
+
+		err = ds->drv->port_vlan_del(ds, dp, vlan);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+int dsa_tree_port_vlan_dump(struct dsa_switch_tree *dst, struct dsa_port *dp,
+			     struct switchdev_obj_port_vlan *vlan,
+			     switchdev_obj_dump_cb_t *cb)
+{
+	struct dsa_switch *ds;
+	int err;
+
+	dsa_tree_for_each_switch(dst, ds) {
+		if (ds->drv->port_vlan_dump) {
+			err = ds->drv->port_vlan_dump(ds, dp, vlan, cb);
+			if (err && err != -EOPNOTSUPP)
+				return err;
+		}
+	}
+
+	return 0;
+}
-- 
2.8.0
