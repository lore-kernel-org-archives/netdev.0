From: John Crispin <john@phrozen.org>
Subject: [PATCH V3] net-next: dsa: add FIB support
Date: Tue, 13 Sep 2016 08:02:21 +0200
Message-ID: <1473746541-52314-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add SWITCHDEV_OBJ_ID_IPV4_FIB support to the DSA layer.

Signed-off-by: John Crispin <john@phrozen.org>
---
Changes in V2
* rebase on latest net-next to fix compile errors

Changes in V3
* fix subject prefix. this needs to go into the next tree

 Documentation/networking/dsa/dsa.txt |   18 +++++++++++++++
 include/net/dsa.h                    |   13 +++++++++++
 net/dsa/slave.c                      |   41 ++++++++++++++++++++++++++++++++++
 3 files changed, 72 insertions(+)

diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
index 6d6c07c..6cd5831 100644
--- a/Documentation/networking/dsa/dsa.txt
+++ b/Documentation/networking/dsa/dsa.txt
@@ -607,6 +607,24 @@ of DSA, would be the its port-based VLAN, used by the associated bridge device.
   function that the driver has to call for each MAC address known to be behind
   the given port. A switchdev object is used to carry the VID and MDB info.
 
+Route offloading
+----------------
+
+- ipv4_fib_prepare: routing layer function invoked to prepare the installation
+  of an ipv4 route into the switches routing database. If the operation is not
+  supported this function should return -EOPNOTSUPP. No hardware setup must be
+  done in this function. See ipv4_fib_add for this and details.
+
+- ipv4_fib_add: routing layer function invoked when a new ipv4 route should be
+  installed into the routing database of the switch, it should be programmed
+  with the route for the specified VLAN ID of the device that the route applies
+  to.
+
+- ipv4_fib_del: routing layer function invoked when an ipv4 route should be
+  removed from the routing database, the switch hardware should be programmed
+  to delete the specified MAC address of the nexthop from the specified VLAN ID
+  if it was mapped into the forwarding database.
+
 TODO
 ====
 
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 7556646..7fdd63e 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -237,6 +237,7 @@ struct switchdev_obj;
 struct switchdev_obj_port_fdb;
 struct switchdev_obj_port_mdb;
 struct switchdev_obj_port_vlan;
+struct switchdev_obj_ipv4_fib;
 
 struct dsa_switch_ops {
 	struct list_head	list;
@@ -386,6 +387,18 @@ struct dsa_switch_ops {
 	int	(*port_mdb_dump)(struct dsa_switch *ds, int port,
 				 struct switchdev_obj_port_mdb *mdb,
 				 int (*cb)(struct switchdev_obj *obj));
+
+	/*
+	 * IPV4 routing
+	 */
+	int	(*ipv4_fib_prepare)(struct dsa_switch *ds, int port,
+				    const struct switchdev_obj_ipv4_fib *fib4,
+				    struct switchdev_trans *trans);
+	int	(*ipv4_fib_add)(struct dsa_switch *ds, int port,
+				const struct switchdev_obj_ipv4_fib *fib4,
+				struct switchdev_trans *trans);
+	int	(*ipv4_fib_del)(struct dsa_switch *ds, int port,
+				const struct switchdev_obj_ipv4_fib *fib4);
 };
 
 void register_switch_driver(struct dsa_switch_ops *type);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 9ecbe78..c974ac0 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -334,6 +334,38 @@ static int dsa_slave_port_mdb_dump(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static int dsa_slave_ipv4_fib_add(struct net_device *dev,
+				  const struct switchdev_obj_ipv4_fib *fib4,
+				  struct switchdev_trans *trans)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int ret;
+
+	if (!ds->ops->ipv4_fib_prepare || !ds->ops->ipv4_fib_add)
+		return -EOPNOTSUPP;
+
+	if (switchdev_trans_ph_prepare(trans))
+		ret = ds->ops->ipv4_fib_prepare(ds, p->port, fib4, trans);
+	else
+		ret = ds->ops->ipv4_fib_add(ds, p->port, fib4, trans);
+
+	return ret;
+}
+
+static int dsa_slave_ipv4_fib_del(struct net_device *dev,
+				  const struct switchdev_obj_ipv4_fib *fib4)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int ret = -EOPNOTSUPP;
+
+	if (ds->ops->ipv4_fib_del)
+		ret = ds->ops->ipv4_fib_del(ds, p->port, fib4);
+
+	return ret;
+}
+
 static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -465,6 +497,11 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 					      SWITCHDEV_OBJ_PORT_VLAN(obj),
 					      trans);
 		break;
+	case SWITCHDEV_OBJ_ID_IPV4_FIB:
+		err = dsa_slave_ipv4_fib_add(dev,
+					     SWITCHDEV_OBJ_IPV4_FIB(obj),
+					     trans);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -490,6 +527,10 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 		err = dsa_slave_port_vlan_del(dev,
 					      SWITCHDEV_OBJ_PORT_VLAN(obj));
 		break;
+	case SWITCHDEV_OBJ_ID_IPV4_FIB:
+		err = dsa_slave_ipv4_fib_del(dev,
+					     SWITCHDEV_OBJ_IPV4_FIB(obj));
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
-- 
1.7.10.4
