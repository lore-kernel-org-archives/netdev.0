From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 06/20] net: dsa: change scope of VLAN handlers
Date: Fri, 19 May 2017 17:00:41 -0400
Message-ID: <20170519210055.9366-7-vivien.didelot@savoirfairelinux.com>
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

Change the scope of the switchdev VLAN object handlers from the DSA
slave device to the generic DSA port, so that the future port-wide API
can also be used for other port types, such as CPU and DSA links.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 40 ++++++++++++++++------------------------
 1 file changed, 16 insertions(+), 24 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 0921d306aedf..de39da69fd33 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -254,12 +254,10 @@ static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
 	return 0;
 }
 
-static int dsa_slave_port_vlan_add(struct net_device *dev,
-				   const struct switchdev_obj_port_vlan *vlan,
-				   struct switchdev_trans *trans)
+static int dsa_port_vlan_add(struct dsa_port *dp,
+			     const struct switchdev_obj_port_vlan *vlan,
+			     struct switchdev_trans *trans)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_port *dp = p->dp;
 	struct dsa_switch *ds = dp->ds;
 
 	if (switchdev_trans_ph_prepare(trans)) {
@@ -274,27 +272,25 @@ static int dsa_slave_port_vlan_add(struct net_device *dev,
 	return 0;
 }
 
-static int dsa_slave_port_vlan_del(struct net_device *dev,
-				   const struct switchdev_obj_port_vlan *vlan)
+static int dsa_port_vlan_del(struct dsa_port *dp,
+			     const struct switchdev_obj_port_vlan *vlan)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_switch *ds = dp->ds;
 
 	if (!ds->ops->port_vlan_del)
 		return -EOPNOTSUPP;
 
-	return ds->ops->port_vlan_del(ds, p->dp->index, vlan);
+	return ds->ops->port_vlan_del(ds, dp->index, vlan);
 }
 
-static int dsa_slave_port_vlan_dump(struct net_device *dev,
-				    struct switchdev_obj_port_vlan *vlan,
-				    switchdev_obj_dump_cb_t *cb)
+static int dsa_port_vlan_dump(struct dsa_port *dp,
+			      struct switchdev_obj_port_vlan *vlan,
+			      switchdev_obj_dump_cb_t *cb)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_switch *ds = dp->ds;
 
 	if (ds->ops->port_vlan_dump)
-		return ds->ops->port_vlan_dump(ds, p->dp->index, vlan, cb);
+		return ds->ops->port_vlan_dump(ds, dp->index, vlan, cb);
 
 	return -EOPNOTSUPP;
 }
@@ -499,9 +495,8 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 		err = dsa_port_mdb_add(dp, SWITCHDEV_OBJ_PORT_MDB(obj), trans);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
-		err = dsa_slave_port_vlan_add(dev,
-					      SWITCHDEV_OBJ_PORT_VLAN(obj),
-					      trans);
+		err = dsa_port_vlan_add(dp, SWITCHDEV_OBJ_PORT_VLAN(obj),
+					trans);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -526,8 +521,7 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 		err = dsa_port_mdb_del(dp, SWITCHDEV_OBJ_PORT_MDB(obj));
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
-		err = dsa_slave_port_vlan_del(dev,
-					      SWITCHDEV_OBJ_PORT_VLAN(obj));
+		err = dsa_port_vlan_del(dp, SWITCHDEV_OBJ_PORT_VLAN(obj));
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -553,9 +547,7 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 		err = dsa_port_mdb_dump(dp, SWITCHDEV_OBJ_PORT_MDB(obj), cb);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
-		err = dsa_slave_port_vlan_dump(dev,
-					       SWITCHDEV_OBJ_PORT_VLAN(obj),
-					       cb);
+		err = dsa_port_vlan_dump(dp, SWITCHDEV_OBJ_PORT_VLAN(obj), cb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
-- 
2.13.0
