From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 14/20] net: dsa: move MDB handlers
Date: Fri, 19 May 2017 17:00:49 -0400
Message-ID: <20170519210055.9366-15-vivien.didelot@savoirfairelinux.com>
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

Move the DSA port code which handles MDB objects in port.c, where it
belongs.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h |  7 +++++++
 net/dsa/port.c     | 40 ++++++++++++++++++++++++++++++++++++++++
 net/dsa/slave.c    | 41 -----------------------------------------
 3 files changed, 47 insertions(+), 41 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index d003a2554c7a..c2a595036746 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -77,6 +77,13 @@ int dsa_port_fdb_del(struct dsa_port *dp,
 		     const struct switchdev_obj_port_fdb *fdb);
 int dsa_port_fdb_dump(struct dsa_port *dp, struct switchdev_obj_port_fdb *fdb,
 		      switchdev_obj_dump_cb_t *cb);
+int dsa_port_mdb_add(struct dsa_port *dp,
+		     const struct switchdev_obj_port_mdb *mdb,
+		     struct switchdev_trans *trans);
+int dsa_port_mdb_del(struct dsa_port *dp,
+		     const struct switchdev_obj_port_mdb *mdb);
+int dsa_port_mdb_dump(struct dsa_port *dp, struct switchdev_obj_port_mdb *mdb,
+		      switchdev_obj_dump_cb_t *cb);
 
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
diff --git a/net/dsa/port.c b/net/dsa/port.c
index 18ec6d432152..4ed0124a8d4b 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -207,3 +207,43 @@ int dsa_port_fdb_dump(struct dsa_port *dp, struct switchdev_obj_port_fdb *fdb,
 
 	return -EOPNOTSUPP;
 }
+
+int dsa_port_mdb_add(struct dsa_port *dp,
+		     const struct switchdev_obj_port_mdb *mdb,
+		     struct switchdev_trans *trans)
+{
+	struct dsa_switch *ds = dp->ds;
+
+	if (switchdev_trans_ph_prepare(trans)) {
+		if (!ds->ops->port_mdb_prepare || !ds->ops->port_mdb_add)
+			return -EOPNOTSUPP;
+
+		return ds->ops->port_mdb_prepare(ds, dp->index, mdb, trans);
+	}
+
+	ds->ops->port_mdb_add(ds, dp->index, mdb, trans);
+
+	return 0;
+}
+
+int dsa_port_mdb_del(struct dsa_port *dp,
+		     const struct switchdev_obj_port_mdb *mdb)
+{
+	struct dsa_switch *ds = dp->ds;
+
+	if (ds->ops->port_mdb_del)
+		return ds->ops->port_mdb_del(ds, dp->index, mdb);
+
+	return -EOPNOTSUPP;
+}
+
+int dsa_port_mdb_dump(struct dsa_port *dp, struct switchdev_obj_port_mdb *mdb,
+		      switchdev_obj_dump_cb_t *cb)
+{
+	struct dsa_switch *ds = dp->ds;
+
+	if (ds->ops->port_mdb_dump)
+		return ds->ops->port_mdb_dump(ds, dp->index, mdb, cb);
+
+	return -EOPNOTSUPP;
+}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index d9b7bf759f44..9adcb8267d9a 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -245,47 +245,6 @@ static int dsa_port_vlan_dump(struct dsa_port *dp,
 	return -EOPNOTSUPP;
 }
 
-static int dsa_port_mdb_add(struct dsa_port *dp,
-			    const struct switchdev_obj_port_mdb *mdb,
-			    struct switchdev_trans *trans)
-{
-	struct dsa_switch *ds = dp->ds;
-
-	if (switchdev_trans_ph_prepare(trans)) {
-		if (!ds->ops->port_mdb_prepare || !ds->ops->port_mdb_add)
-			return -EOPNOTSUPP;
-
-		return ds->ops->port_mdb_prepare(ds, dp->index, mdb, trans);
-	}
-
-	ds->ops->port_mdb_add(ds, dp->index, mdb, trans);
-
-	return 0;
-}
-
-static int dsa_port_mdb_del(struct dsa_port *dp,
-			    const struct switchdev_obj_port_mdb *mdb)
-{
-	struct dsa_switch *ds = dp->ds;
-
-	if (ds->ops->port_mdb_del)
-		return ds->ops->port_mdb_del(ds, dp->index, mdb);
-
-	return -EOPNOTSUPP;
-}
-
-static int dsa_port_mdb_dump(struct dsa_port *dp,
-			     struct switchdev_obj_port_mdb *mdb,
-			     switchdev_obj_dump_cb_t *cb)
-{
-	struct dsa_switch *ds = dp->ds;
-
-	if (ds->ops->port_mdb_dump)
-		return ds->ops->port_mdb_dump(ds, dp->index, mdb, cb);
-
-	return -EOPNOTSUPP;
-}
-
 static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-- 
2.13.0
