From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 04/20] net: dsa: change scope of FDB handlers
Date: Fri, 19 May 2017 17:00:39 -0400
Message-ID: <20170519210055.9366-5-vivien.didelot@savoirfairelinux.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the scope of the switchdev FDB object handlers from the DSA slave
device to the generic DSA port, so that the future port-wide API can
also be used for other port types, such as CPU and DSA links.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 50 ++++++++++++++++++++++++--------------------------
 1 file changed, 24 insertions(+), 26 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 1ad62ef8c261..e9c3ea09cc09 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -299,47 +299,44 @@ static int dsa_slave_port_vlan_dump(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
-static int dsa_slave_port_fdb_add(struct net_device *dev,
-				  const struct switchdev_obj_port_fdb *fdb,
-				  struct switchdev_trans *trans)
+static int dsa_port_fdb_add(struct dsa_port *dp,
+			    const struct switchdev_obj_port_fdb *fdb,
+			    struct switchdev_trans *trans)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_switch *ds = dp->ds;
 
 	if (switchdev_trans_ph_prepare(trans)) {
 		if (!ds->ops->port_fdb_prepare || !ds->ops->port_fdb_add)
 			return -EOPNOTSUPP;
 
-		return ds->ops->port_fdb_prepare(ds, p->dp->index, fdb, trans);
+		return ds->ops->port_fdb_prepare(ds, dp->index, fdb, trans);
 	}
 
-	ds->ops->port_fdb_add(ds, p->dp->index, fdb, trans);
+	ds->ops->port_fdb_add(ds, dp->index, fdb, trans);
 
 	return 0;
 }
 
-static int dsa_slave_port_fdb_del(struct net_device *dev,
-				  const struct switchdev_obj_port_fdb *fdb)
+static int dsa_port_fdb_del(struct dsa_port *dp,
+			    const struct switchdev_obj_port_fdb *fdb)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_switch *ds = dp->ds;
 	int ret = -EOPNOTSUPP;
 
 	if (ds->ops->port_fdb_del)
-		ret = ds->ops->port_fdb_del(ds, p->dp->index, fdb);
+		ret = ds->ops->port_fdb_del(ds, dp->index, fdb);
 
 	return ret;
 }
 
-static int dsa_slave_port_fdb_dump(struct net_device *dev,
-				   struct switchdev_obj_port_fdb *fdb,
-				   switchdev_obj_dump_cb_t *cb)
+static int dsa_port_fdb_dump(struct dsa_port *dp,
+			     struct switchdev_obj_port_fdb *fdb,
+			     switchdev_obj_dump_cb_t *cb)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_switch *ds = dp->ds;
 
 	if (ds->ops->port_fdb_dump)
-		return ds->ops->port_fdb_dump(ds, p->dp->index, fdb, cb);
+		return ds->ops->port_fdb_dump(ds, dp->index, fdb, cb);
 
 	return -EOPNOTSUPP;
 }
@@ -488,6 +485,8 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 				  const struct switchdev_obj *obj,
 				  struct switchdev_trans *trans)
 {
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = p->dp;
 	int err;
 
 	/* For the prepare phase, ensure the full set of changes is feasable in
@@ -497,9 +496,7 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = dsa_slave_port_fdb_add(dev,
-					     SWITCHDEV_OBJ_PORT_FDB(obj),
-					     trans);
+		err = dsa_port_fdb_add(dp, SWITCHDEV_OBJ_PORT_FDB(obj), trans);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		err = dsa_slave_port_mdb_add(dev, SWITCHDEV_OBJ_PORT_MDB(obj),
@@ -521,12 +518,13 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 static int dsa_slave_port_obj_del(struct net_device *dev,
 				  const struct switchdev_obj *obj)
 {
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = p->dp;
 	int err;
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = dsa_slave_port_fdb_del(dev,
-					     SWITCHDEV_OBJ_PORT_FDB(obj));
+		err = dsa_port_fdb_del(dp, SWITCHDEV_OBJ_PORT_FDB(obj));
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		err = dsa_slave_port_mdb_del(dev, SWITCHDEV_OBJ_PORT_MDB(obj));
@@ -547,13 +545,13 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 				   struct switchdev_obj *obj,
 				   switchdev_obj_dump_cb_t *cb)
 {
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = p->dp;
 	int err;
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = dsa_slave_port_fdb_dump(dev,
-					      SWITCHDEV_OBJ_PORT_FDB(obj),
-					      cb);
+		err = dsa_port_fdb_dump(dp, SWITCHDEV_OBJ_PORT_FDB(obj), cb);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		err = dsa_slave_port_mdb_dump(dev, SWITCHDEV_OBJ_PORT_MDB(obj),
-- 
2.13.0
