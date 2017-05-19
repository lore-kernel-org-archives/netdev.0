From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 15/20] net: dsa: move VLAN handlers
Date: Fri, 19 May 2017 17:00:50 -0400
Message-ID: <20170519210055.9366-16-vivien.didelot@savoirfairelinux.com>
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

Move the DSA port code which handles VLAN objects in port.c, where it
belongs.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h |  8 ++++++++
 net/dsa/port.c     | 41 +++++++++++++++++++++++++++++++++++++++++
 net/dsa/slave.c    | 41 -----------------------------------------
 3 files changed, 49 insertions(+), 41 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index c2a595036746..16021a891095 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -84,6 +84,14 @@ int dsa_port_mdb_del(struct dsa_port *dp,
 		     const struct switchdev_obj_port_mdb *mdb);
 int dsa_port_mdb_dump(struct dsa_port *dp, struct switchdev_obj_port_mdb *mdb,
 		      switchdev_obj_dump_cb_t *cb);
+int dsa_port_vlan_add(struct dsa_port *dp,
+		      const struct switchdev_obj_port_vlan *vlan,
+		      struct switchdev_trans *trans);
+int dsa_port_vlan_del(struct dsa_port *dp,
+		      const struct switchdev_obj_port_vlan *vlan);
+int dsa_port_vlan_dump(struct dsa_port *dp,
+		       struct switchdev_obj_port_vlan *vlan,
+		       switchdev_obj_dump_cb_t *cb);
 
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
diff --git a/net/dsa/port.c b/net/dsa/port.c
index 4ed0124a8d4b..f211b0dfb12d 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -247,3 +247,44 @@ int dsa_port_mdb_dump(struct dsa_port *dp, struct switchdev_obj_port_mdb *mdb,
 
 	return -EOPNOTSUPP;
 }
+
+int dsa_port_vlan_add(struct dsa_port *dp,
+		      const struct switchdev_obj_port_vlan *vlan,
+		      struct switchdev_trans *trans)
+{
+	struct dsa_switch *ds = dp->ds;
+
+	if (switchdev_trans_ph_prepare(trans)) {
+		if (!ds->ops->port_vlan_prepare || !ds->ops->port_vlan_add)
+			return -EOPNOTSUPP;
+
+		return ds->ops->port_vlan_prepare(ds, dp->index, vlan, trans);
+	}
+
+	ds->ops->port_vlan_add(ds, dp->index, vlan, trans);
+
+	return 0;
+}
+
+int dsa_port_vlan_del(struct dsa_port *dp,
+		      const struct switchdev_obj_port_vlan *vlan)
+{
+	struct dsa_switch *ds = dp->ds;
+
+	if (!ds->ops->port_vlan_del)
+		return -EOPNOTSUPP;
+
+	return ds->ops->port_vlan_del(ds, dp->index, vlan);
+}
+
+int dsa_port_vlan_dump(struct dsa_port *dp,
+		       struct switchdev_obj_port_vlan *vlan,
+		       switchdev_obj_dump_cb_t *cb)
+{
+	struct dsa_switch *ds = dp->ds;
+
+	if (ds->ops->port_vlan_dump)
+		return ds->ops->port_vlan_dump(ds, dp->index, vlan, cb);
+
+	return -EOPNOTSUPP;
+}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 9adcb8267d9a..887e26695519 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -204,47 +204,6 @@ static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
 	return 0;
 }
 
-static int dsa_port_vlan_add(struct dsa_port *dp,
-			     const struct switchdev_obj_port_vlan *vlan,
-			     struct switchdev_trans *trans)
-{
-	struct dsa_switch *ds = dp->ds;
-
-	if (switchdev_trans_ph_prepare(trans)) {
-		if (!ds->ops->port_vlan_prepare || !ds->ops->port_vlan_add)
-			return -EOPNOTSUPP;
-
-		return ds->ops->port_vlan_prepare(ds, dp->index, vlan, trans);
-	}
-
-	ds->ops->port_vlan_add(ds, dp->index, vlan, trans);
-
-	return 0;
-}
-
-static int dsa_port_vlan_del(struct dsa_port *dp,
-			     const struct switchdev_obj_port_vlan *vlan)
-{
-	struct dsa_switch *ds = dp->ds;
-
-	if (!ds->ops->port_vlan_del)
-		return -EOPNOTSUPP;
-
-	return ds->ops->port_vlan_del(ds, dp->index, vlan);
-}
-
-static int dsa_port_vlan_dump(struct dsa_port *dp,
-			      struct switchdev_obj_port_vlan *vlan,
-			      switchdev_obj_dump_cb_t *cb)
-{
-	struct dsa_switch *ds = dp->ds;
-
-	if (ds->ops->port_vlan_dump)
-		return ds->ops->port_vlan_dump(ds, dp->index, vlan, cb);
-
-	return -EOPNOTSUPP;
-}
-
 static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-- 
2.13.0
