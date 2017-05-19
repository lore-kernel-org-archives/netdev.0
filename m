From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 05/20] net: dsa: change scope of MDB handlers
Date: Fri, 19 May 2017 17:00:40 -0400
Message-ID: <20170519210055.9366-6-vivien.didelot@savoirfairelinux.com>
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

Change the scope of the switchdev MDB object handlers from the DSA slave
device to the generic DSA port, so that the future port-wide API can
also be used for other port types, such as CPU and DSA links.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 41 ++++++++++++++++++-----------------------
 1 file changed, 18 insertions(+), 23 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index e9c3ea09cc09..0921d306aedf 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -341,46 +341,43 @@ static int dsa_port_fdb_dump(struct dsa_port *dp,
 	return -EOPNOTSUPP;
 }
 
-static int dsa_slave_port_mdb_add(struct net_device *dev,
-				  const struct switchdev_obj_port_mdb *mdb,
-				  struct switchdev_trans *trans)
+static int dsa_port_mdb_add(struct dsa_port *dp,
+			    const struct switchdev_obj_port_mdb *mdb,
+			    struct switchdev_trans *trans)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_switch *ds = dp->ds;
 
 	if (switchdev_trans_ph_prepare(trans)) {
 		if (!ds->ops->port_mdb_prepare || !ds->ops->port_mdb_add)
 			return -EOPNOTSUPP;
 
-		return ds->ops->port_mdb_prepare(ds, p->dp->index, mdb, trans);
+		return ds->ops->port_mdb_prepare(ds, dp->index, mdb, trans);
 	}
 
-	ds->ops->port_mdb_add(ds, p->dp->index, mdb, trans);
+	ds->ops->port_mdb_add(ds, dp->index, mdb, trans);
 
 	return 0;
 }
 
-static int dsa_slave_port_mdb_del(struct net_device *dev,
-				  const struct switchdev_obj_port_mdb *mdb)
+static int dsa_port_mdb_del(struct dsa_port *dp,
+			    const struct switchdev_obj_port_mdb *mdb)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_switch *ds = dp->ds;
 
 	if (ds->ops->port_mdb_del)
-		return ds->ops->port_mdb_del(ds, p->dp->index, mdb);
+		return ds->ops->port_mdb_del(ds, dp->index, mdb);
 
 	return -EOPNOTSUPP;
 }
 
-static int dsa_slave_port_mdb_dump(struct net_device *dev,
-				   struct switchdev_obj_port_mdb *mdb,
-				   switchdev_obj_dump_cb_t *cb)
+static int dsa_port_mdb_dump(struct dsa_port *dp,
+			     struct switchdev_obj_port_mdb *mdb,
+			     switchdev_obj_dump_cb_t *cb)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_switch *ds = dp->ds;
 
 	if (ds->ops->port_mdb_dump)
-		return ds->ops->port_mdb_dump(ds, p->dp->index, mdb, cb);
+		return ds->ops->port_mdb_dump(ds, dp->index, mdb, cb);
 
 	return -EOPNOTSUPP;
 }
@@ -499,8 +496,7 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 		err = dsa_port_fdb_add(dp, SWITCHDEV_OBJ_PORT_FDB(obj), trans);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
-		err = dsa_slave_port_mdb_add(dev, SWITCHDEV_OBJ_PORT_MDB(obj),
-					     trans);
+		err = dsa_port_mdb_add(dp, SWITCHDEV_OBJ_PORT_MDB(obj), trans);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = dsa_slave_port_vlan_add(dev,
@@ -527,7 +523,7 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 		err = dsa_port_fdb_del(dp, SWITCHDEV_OBJ_PORT_FDB(obj));
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
-		err = dsa_slave_port_mdb_del(dev, SWITCHDEV_OBJ_PORT_MDB(obj));
+		err = dsa_port_mdb_del(dp, SWITCHDEV_OBJ_PORT_MDB(obj));
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = dsa_slave_port_vlan_del(dev,
@@ -554,8 +550,7 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 		err = dsa_port_fdb_dump(dp, SWITCHDEV_OBJ_PORT_FDB(obj), cb);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
-		err = dsa_slave_port_mdb_dump(dev, SWITCHDEV_OBJ_PORT_MDB(obj),
-					      cb);
+		err = dsa_port_mdb_dump(dp, SWITCHDEV_OBJ_PORT_MDB(obj), cb);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = dsa_slave_port_vlan_dump(dev,
-- 
2.13.0
