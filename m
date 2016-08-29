From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/3] net: dsa: add MDB support
Date: Mon, 29 Aug 2016 16:32:44 -0400
Message-ID: <20160829203246.18811-2-vivien.didelot@savoirfairelinux.com>
References: <20160829203246.18811-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41203 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754081AbcH2UdQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 16:33:16 -0400
In-Reply-To: <20160829203246.18811-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add SWITCHDEV_OBJ_ID_PORT_MDB support to the DSA layer.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 Documentation/networking/dsa/dsa.txt | 23 +++++++++++++++
 include/net/dsa.h                    | 16 +++++++++++
 net/dsa/slave.c                      | 55 ++++++++++++++++++++++++++++++++++++
 3 files changed, 94 insertions(+)

diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
index 44ed453..6db7bc8 100644
--- a/Documentation/networking/dsa/dsa.txt
+++ b/Documentation/networking/dsa/dsa.txt
@@ -584,6 +584,29 @@ of DSA, would be the its port-based VLAN, used by the associated bridge device.
   function that the driver has to call for each MAC address known to be behind
   the given port. A switchdev object is used to carry the VID and FDB info.
 
+- port_mdb_prepare: bridge layer function invoked when the bridge prepares the
+  installation of a multicast group database entry. If the operation is not
+  supported, this function should return -EOPNOTSUPP to inform the bridge code
+  to fallback to a software implementation. No hardware setup must be done in
+  this function. See port_fdb_add for this and details.
+
+- port_mdb_add: bridge layer function invoked when the bridge wants to install 
+  a multicast group database entry, the switch hardware should be programmed 
+  with the specified address in the specified VLAN ID in the forwarding database 
+  associated with this VLAN ID.
+
+Note: VLAN ID 0 corresponds to the port private database, which, in the context
+of DSA, would be the its port-based VLAN, used by the associated bridge device.
+
+- port_mdb_del: bridge layer function invoked when the bridge wants to remove a
+  multicast group database entry, the switch hardware should be programmed to 
+  delete the specified MAC address from the specified VLAN ID if it was mapped 
+  into this port forwarding database.
+
+- port_mdb_dump: bridge layer function invoked with a switchdev callback
+  function that the driver has to call for each MAC address known to be behind
+  the given port. A switchdev object is used to carry the VID and MDB info.
+
 TODO
 ====
 
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 2ebeba4..39f90c4 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -234,6 +234,7 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 struct switchdev_trans;
 struct switchdev_obj;
 struct switchdev_obj_port_fdb;
+struct switchdev_obj_port_mdb;
 struct switchdev_obj_port_vlan;
 
 struct dsa_switch_ops {
@@ -369,6 +370,21 @@ struct dsa_switch_ops {
 	int	(*port_fdb_dump)(struct dsa_switch *ds, int port,
 				 struct switchdev_obj_port_fdb *fdb,
 				 int (*cb)(struct switchdev_obj *obj));
+
+	/*
+	 * Multicast group database
+	 */
+	int	(*port_mdb_prepare)(struct dsa_switch *ds, int port,
+				    const struct switchdev_obj_port_mdb *mdb,
+				    struct switchdev_trans *trans);
+	void	(*port_mdb_add)(struct dsa_switch *ds, int port,
+				const struct switchdev_obj_port_mdb *mdb,
+				struct switchdev_trans *trans);
+	int	(*port_mdb_del)(struct dsa_switch *ds, int port,
+				const struct switchdev_obj_port_mdb *mdb);
+	int	(*port_mdb_dump)(struct dsa_switch *ds, int port,
+				 struct switchdev_obj_port_mdb *mdb,
+				 int (*cb)(struct switchdev_obj *obj));
 };
 
 void register_switch_driver(struct dsa_switch_ops *type);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 9f6c2a2..9ecbe78 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -290,6 +290,50 @@ static int dsa_slave_port_fdb_dump(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static int dsa_slave_port_mdb_add(struct net_device *dev,
+				  const struct switchdev_obj_port_mdb *mdb,
+				  struct switchdev_trans *trans)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (switchdev_trans_ph_prepare(trans)) {
+		if (!ds->ops->port_mdb_prepare || !ds->ops->port_mdb_add)
+			return -EOPNOTSUPP;
+
+		return ds->ops->port_mdb_prepare(ds, p->port, mdb, trans);
+	}
+
+	ds->ops->port_mdb_add(ds, p->port, mdb, trans);
+
+	return 0;
+}
+
+static int dsa_slave_port_mdb_del(struct net_device *dev,
+				  const struct switchdev_obj_port_mdb *mdb)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (ds->ops->port_mdb_del)
+		return ds->ops->port_mdb_del(ds, p->port, mdb);
+
+	return -EOPNOTSUPP;
+}
+
+static int dsa_slave_port_mdb_dump(struct net_device *dev,
+				   struct switchdev_obj_port_mdb *mdb,
+				   switchdev_obj_dump_cb_t *cb)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (ds->ops->port_mdb_dump)
+		return ds->ops->port_mdb_dump(ds, p->port, mdb, cb);
+
+	return -EOPNOTSUPP;
+}
+
 static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -412,6 +456,10 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 					     SWITCHDEV_OBJ_PORT_FDB(obj),
 					     trans);
 		break;
+	case SWITCHDEV_OBJ_ID_PORT_MDB:
+		err = dsa_slave_port_mdb_add(dev, SWITCHDEV_OBJ_PORT_MDB(obj),
+					     trans);
+		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = dsa_slave_port_vlan_add(dev,
 					      SWITCHDEV_OBJ_PORT_VLAN(obj),
@@ -435,6 +483,9 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 		err = dsa_slave_port_fdb_del(dev,
 					     SWITCHDEV_OBJ_PORT_FDB(obj));
 		break;
+	case SWITCHDEV_OBJ_ID_PORT_MDB:
+		err = dsa_slave_port_mdb_del(dev, SWITCHDEV_OBJ_PORT_MDB(obj));
+		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = dsa_slave_port_vlan_del(dev,
 					      SWITCHDEV_OBJ_PORT_VLAN(obj));
@@ -459,6 +510,10 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 					      SWITCHDEV_OBJ_PORT_FDB(obj),
 					      cb);
 		break;
+	case SWITCHDEV_OBJ_ID_PORT_MDB:
+		err = dsa_slave_port_mdb_dump(dev, SWITCHDEV_OBJ_PORT_MDB(obj),
+					      cb);
+		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = dsa_slave_port_vlan_dump(dev,
 					       SWITCHDEV_OBJ_PORT_VLAN(obj),
-- 
2.9.3
