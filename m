From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 15/20] net: dsa: add tree-wide FDB ops
Date: Wed, 27 Apr 2016 18:30:12 -0400
Message-ID: <1461796217-18893-16-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to support cross-chip operations, we need to inform each switch
driver when a port operation occurs in a DSA tree.

Implement tree-wide FDB operations.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/bcm_sf2.c   | 12 ++++++++
 drivers/net/dsa/mv88e6xxx.c | 12 ++++++++
 net/dsa/dsa_priv.h          |  9 ++++++
 net/dsa/slave.c             | 68 ++++++++++-----------------------------------
 net/dsa/tree.c              | 61 ++++++++++++++++++++++++++++++++++++++++
 5 files changed, 109 insertions(+), 53 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 0a91ea9..6e634e5 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -733,6 +733,9 @@ static int bcm_sf2_sw_fdb_prepare(struct dsa_switch *ds, struct dsa_port *dp,
 				  const struct switchdev_obj_port_fdb *fdb,
 				  struct switchdev_trans *trans)
 {
+	if (dsa_port_is_external(dp, ds))
+		return -EOPNOTSUPP;
+
 	/* We do not need to do anything specific here yet */
 	return 0;
 }
@@ -743,6 +746,9 @@ static void bcm_sf2_sw_fdb_add(struct dsa_switch *ds, struct dsa_port *dp,
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 
+	if (dsa_port_is_external(dp, ds))
+		return;
+
 	if (bcm_sf2_arl_op(priv, 0, dp->port, fdb->addr, fdb->vid, true))
 		pr_err("%s: failed to add MAC address\n", __func__);
 }
@@ -752,6 +758,9 @@ static int bcm_sf2_sw_fdb_del(struct dsa_switch *ds, struct dsa_port *dp,
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 
+	if (dsa_port_is_external(dp, ds))
+		return -EOPNOTSUPP;
+
 	return bcm_sf2_arl_op(priv, 0, dp->port, fdb->addr, fdb->vid, false);
 }
 
@@ -813,6 +822,9 @@ static int bcm_sf2_sw_fdb_dump(struct dsa_switch *ds, struct dsa_port *dp,
 	unsigned int count = 0;
 	int ret;
 
+	if (dsa_port_is_external(dp, ds))
+		return -EOPNOTSUPP;
+
 	dev = ds->ports[dp->port];
 
 	/* Start search operation */
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 6fef29b..7d29de3 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2037,6 +2037,9 @@ int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, struct dsa_port *dp,
 			       const struct switchdev_obj_port_fdb *fdb,
 			       struct switchdev_trans *trans)
 {
+	if (dsa_port_is_external(dp, ds))
+		return -EOPNOTSUPP;
+
 	/* We don't need any dynamic resource from the kernel (yet),
 	 * so skip the prepare phase.
 	 */
@@ -2052,6 +2055,9 @@ void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, struct dsa_port *dp,
 		GLOBAL_ATU_DATA_STATE_UC_STATIC;
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
+	if (dsa_port_is_external(dp, ds))
+		return;
+
 	mutex_lock(&ps->smi_mutex);
 	if (_mv88e6xxx_port_fdb_load(ds, dp->port, fdb->addr, fdb->vid, state))
 		netdev_err(ds->ports[dp->port], "failed to load MAC address\n");
@@ -2064,6 +2070,9 @@ int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, struct dsa_port *dp,
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
+	if (dsa_port_is_external(dp, ds))
+		return -EOPNOTSUPP;
+
 	mutex_lock(&ps->smi_mutex);
 	ret = _mv88e6xxx_port_fdb_load(ds, dp->port, fdb->addr, fdb->vid,
 				       GLOBAL_ATU_DATA_STATE_UNUSED);
@@ -2169,6 +2178,9 @@ int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, struct dsa_port *dp,
 	u16 fid;
 	int err;
 
+	if (dsa_port_is_external(dp, ds))
+		return -EOPNOTSUPP;
+
 	mutex_lock(&ps->smi_mutex);
 
 	/* Dump port's default Filtering Information Database (VLAN ID 0) */
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 6e08b3d..e8765c3 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -14,6 +14,7 @@
 #include <linux/phy.h>
 #include <linux/netdevice.h>
 #include <linux/netpoll.h>
+#include <net/switchdev.h>
 
 struct dsa_device_ops {
 	struct sk_buff *(*xmit)(struct sk_buff *skb, struct net_device *dev);
@@ -51,6 +52,14 @@ int dsa_tree_bridge_port_join(struct dsa_switch_tree *dst, struct dsa_port *dp,
 			      struct net_device *br);
 void dsa_tree_bridge_port_leave(struct dsa_switch_tree *dst,
 				struct dsa_port *dp, struct net_device *br);
+int dsa_tree_port_fdb_add(struct dsa_switch_tree *dst, struct dsa_port *dp,
+			  const struct switchdev_obj_port_fdb *fdb,
+			  struct switchdev_trans *trans);
+int dsa_tree_port_fdb_del(struct dsa_switch_tree *dst, struct dsa_port *dp,
+			  const struct switchdev_obj_port_fdb *fdb);
+int dsa_tree_port_fdb_dump(struct dsa_switch_tree *dst, struct dsa_port *dp,
+			   struct switchdev_obj_port_fdb *fdb,
+			   switchdev_obj_dump_cb_t *cb);
 
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 7123ae2..90bcf8a 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -239,51 +239,6 @@ static int dsa_slave_port_vlan_dump(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
-static int dsa_slave_port_fdb_add(struct net_device *dev,
-				  const struct switchdev_obj_port_fdb *fdb,
-				  struct switchdev_trans *trans)
-{
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
-
-	if (switchdev_trans_ph_prepare(trans)) {
-		if (!ds->drv->port_fdb_prepare || !ds->drv->port_fdb_add)
-			return -EOPNOTSUPP;
-
-		return ds->drv->port_fdb_prepare(ds, p->dp, fdb, trans);
-	}
-
-	ds->drv->port_fdb_add(ds, p->dp, fdb, trans);
-
-	return 0;
-}
-
-static int dsa_slave_port_fdb_del(struct net_device *dev,
-				  const struct switchdev_obj_port_fdb *fdb)
-{
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
-	int ret = -EOPNOTSUPP;
-
-	if (ds->drv->port_fdb_del)
-		ret = ds->drv->port_fdb_del(ds, p->dp, fdb);
-
-	return ret;
-}
-
-static int dsa_slave_port_fdb_dump(struct net_device *dev,
-				   struct switchdev_obj_port_fdb *fdb,
-				   switchdev_obj_dump_cb_t *cb)
-{
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
-
-	if (ds->drv->port_fdb_dump)
-		return ds->drv->port_fdb_dump(ds, p->dp, fdb, cb);
-
-	return -EOPNOTSUPP;
-}
-
 static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -352,6 +307,9 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 				  const struct switchdev_obj *obj,
 				  struct switchdev_trans *trans)
 {
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = p->dp;
+	struct dsa_switch_tree *dst = dp->ds->dst;
 	int err;
 
 	/* For the prepare phase, ensure the full set of changes is feasable in
@@ -361,9 +319,8 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = dsa_slave_port_fdb_add(dev,
-					     SWITCHDEV_OBJ_PORT_FDB(obj),
-					     trans);
+		err = dsa_tree_port_fdb_add(dst, dp,
+					    SWITCHDEV_OBJ_PORT_FDB(obj), trans);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = dsa_slave_port_vlan_add(dev,
@@ -381,12 +338,15 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 static int dsa_slave_port_obj_del(struct net_device *dev,
 				  const struct switchdev_obj *obj)
 {
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = p->dp;
+	struct dsa_switch_tree *dst = dp->ds->dst;
 	int err;
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = dsa_slave_port_fdb_del(dev,
-					     SWITCHDEV_OBJ_PORT_FDB(obj));
+		err = dsa_tree_port_fdb_del(dst, dp,
+					    SWITCHDEV_OBJ_PORT_FDB(obj));
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = dsa_slave_port_vlan_del(dev,
@@ -404,13 +364,15 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 				   struct switchdev_obj *obj,
 				   switchdev_obj_dump_cb_t *cb)
 {
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = p->dp;
+	struct dsa_switch_tree *dst = dp->ds->dst;
 	int err;
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = dsa_slave_port_fdb_dump(dev,
-					      SWITCHDEV_OBJ_PORT_FDB(obj),
-					      cb);
+		err = dsa_tree_port_fdb_dump(dst, dp,
+					     SWITCHDEV_OBJ_PORT_FDB(obj), cb);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = dsa_slave_port_vlan_dump(dev,
diff --git a/net/dsa/tree.c b/net/dsa/tree.c
index d3f5aea..8394019 100644
--- a/net/dsa/tree.c
+++ b/net/dsa/tree.c
@@ -11,6 +11,7 @@
 #include <linux/if_bridge.h>
 #include <linux/list.h>
 #include <linux/netdevice.h>
+#include <net/switchdev.h>
 
 #include "dsa_priv.h"
 
@@ -64,3 +65,63 @@ void dsa_tree_bridge_port_leave(struct dsa_switch_tree *dst,
 						    BR_STATE_FORWARDING);
 	}
 }
+
+int dsa_tree_port_fdb_add(struct dsa_switch_tree *dst, struct dsa_port *dp,
+			  const struct switchdev_obj_port_fdb *fdb,
+			  struct switchdev_trans *trans)
+{
+	struct dsa_switch *ds;
+	int err;
+
+	dsa_tree_for_each_switch(dst, ds) {
+		if (switchdev_trans_ph_prepare(trans)) {
+			if (!ds->drv->port_fdb_prepare ||
+			    !ds->drv->port_fdb_add)
+				return -EOPNOTSUPP;
+
+			err = ds->drv->port_fdb_prepare(ds, dp, fdb, trans);
+			if (err)
+				return err;
+		} else {
+			ds->drv->port_fdb_add(ds, dp, fdb, trans);
+		}
+	}
+
+	return 0;
+}
+
+int dsa_tree_port_fdb_del(struct dsa_switch_tree *dst, struct dsa_port *dp,
+			  const struct switchdev_obj_port_fdb *fdb)
+{
+	struct dsa_switch *ds;
+	int err;
+
+	dsa_tree_for_each_switch(dst, ds) {
+		if (!ds->drv->port_fdb_del)
+			return -EOPNOTSUPP;
+
+		err = ds->drv->port_fdb_del(ds, dp, fdb);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+int dsa_tree_port_fdb_dump(struct dsa_switch_tree *dst, struct dsa_port *dp,
+			   struct switchdev_obj_port_fdb *fdb,
+			   switchdev_obj_dump_cb_t *cb)
+{
+	struct dsa_switch *ds;
+	int err;
+
+	dsa_tree_for_each_switch(dst, ds) {
+		if (ds->drv->port_fdb_dump) {
+			err = ds->drv->port_fdb_dump(ds, dp, fdb, cb);
+			if (err && err != -EOPNOTSUPP)
+				return err;
+		}
+	}
+
+	return 0;
+}
-- 
2.8.0
