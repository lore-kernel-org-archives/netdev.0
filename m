From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 2/3] net: dsa: Propagate VLAN add/del to CPU port(s)
Date: Mon, 21 Nov 2016 11:09:24 -0800
Message-ID: <20161121190925.14530-3-f.fainelli@gmail.com>
References: <20161121190925.14530-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, bridge@lists.linux-foundation.org,
        stephen@networkplumber.org, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, jiri@mellanox.com, idosch@mellanox.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36463 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754188AbcKUTKF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 14:10:05 -0500
Received: by mail-pg0-f65.google.com with SMTP id x23so29285822pgx.3
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 11:10:05 -0800 (PST)
In-Reply-To: <20161121190925.14530-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the bridge layer can call into switchdev to signal programming
requests targeting the bridge master device itself, allow the switch
drivers to implement separate programming of downstream and
upstream/management ports.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 45 +++++++++++++++++++++++++++++++++------------
 1 file changed, 33 insertions(+), 12 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index d0c7bce88743..18288261b964 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -223,35 +223,30 @@ static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
 	return 0;
 }
 
-static int dsa_slave_port_vlan_add(struct net_device *dev,
+static int dsa_slave_port_vlan_add(struct dsa_switch *ds, int port,
 				   const struct switchdev_obj_port_vlan *vlan,
 				   struct switchdev_trans *trans)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
 
 	if (switchdev_trans_ph_prepare(trans)) {
 		if (!ds->ops->port_vlan_prepare || !ds->ops->port_vlan_add)
 			return -EOPNOTSUPP;
 
-		return ds->ops->port_vlan_prepare(ds, p->port, vlan, trans);
+		return ds->ops->port_vlan_prepare(ds, port, vlan, trans);
 	}
 
-	ds->ops->port_vlan_add(ds, p->port, vlan, trans);
+	ds->ops->port_vlan_add(ds, port, vlan, trans);
 
 	return 0;
 }
 
-static int dsa_slave_port_vlan_del(struct net_device *dev,
+static int dsa_slave_port_vlan_del(struct dsa_switch *ds, int port,
 				   const struct switchdev_obj_port_vlan *vlan)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
-
 	if (!ds->ops->port_vlan_del)
 		return -EOPNOTSUPP;
 
-	return ds->ops->port_vlan_del(ds, p->port, vlan);
+	return ds->ops->port_vlan_del(ds, port, vlan);
 }
 
 static int dsa_slave_port_vlan_dump(struct net_device *dev,
@@ -465,8 +460,21 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 				  const struct switchdev_obj *obj,
 				  struct switchdev_trans *trans)
 {
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int port = p->port;
 	int err;
 
+	/* Here we may be called with an orig_dev which is different from dev,
+	 * on purpose, to receive request coming from e.g the bridge master
+	 * device. Although there are no network device associated with CPU/DSA
+	 * ports, we may still have programming operation for these ports.
+	 */
+	if (obj->orig_dev == p->bridge_dev) {
+		ds = ds->dst->ds[0];
+		port = ds->dst->cpu_port;
+	}
+
 	/* For the prepare phase, ensure the full set of changes is feasable in
 	 * one go in order to signal a failure properly. If an operation is not
 	 * supported, return -EOPNOTSUPP.
@@ -483,7 +491,7 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 					     trans);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
-		err = dsa_slave_port_vlan_add(dev,
+		err = dsa_slave_port_vlan_add(ds, port,
 					      SWITCHDEV_OBJ_PORT_VLAN(obj),
 					      trans);
 		break;
@@ -498,8 +506,21 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 static int dsa_slave_port_obj_del(struct net_device *dev,
 				  const struct switchdev_obj *obj)
 {
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int port = p->port;
 	int err;
 
+	/* Here we may be called with an orig_dev which is different from dev,
+	 * on purpose, to receive request coming from e.g the bridge master
+	 * device. Although there are no network device associated with CPU/DSA
+	 * ports, we may still have programming operation for these ports.
+	 */
+	if (obj->orig_dev == p->bridge_dev) {
+		ds = ds->dst->ds[0];
+		port = ds->dst->cpu_port;
+	}
+
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = dsa_slave_port_fdb_del(dev,
@@ -509,7 +530,7 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 		err = dsa_slave_port_mdb_del(dev, SWITCHDEV_OBJ_PORT_MDB(obj));
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
-		err = dsa_slave_port_vlan_del(dev,
+		err = dsa_slave_port_vlan_del(ds, port,
 					      SWITCHDEV_OBJ_PORT_VLAN(obj));
 		break;
 	default:
-- 
2.9.3
