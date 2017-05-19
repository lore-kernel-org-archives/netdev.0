From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 13/20] net: dsa: move FDB handlers
Date: Fri, 19 May 2017 17:00:48 -0400
Message-ID: <20170519210055.9366-14-vivien.didelot@savoirfairelinux.com>
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

Move the DSA port code which handles FDB objects in port.c, where it
belongs.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h |  7 +++++++
 net/dsa/port.c     | 40 ++++++++++++++++++++++++++++++++++++++++
 net/dsa/slave.c    | 42 ------------------------------------------
 3 files changed, 47 insertions(+), 42 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index b0f9837bf5ed..d003a2554c7a 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -70,6 +70,13 @@ int dsa_port_vlan_filtering(struct dsa_port *dp, bool vlan_filtering,
 			    struct switchdev_trans *trans);
 int dsa_port_ageing_time(struct dsa_port *dp, clock_t ageing_clock,
 			 struct switchdev_trans *trans);
+int dsa_port_fdb_add(struct dsa_port *dp,
+		     const struct switchdev_obj_port_fdb *fdb,
+		     struct switchdev_trans *trans);
+int dsa_port_fdb_del(struct dsa_port *dp,
+		     const struct switchdev_obj_port_fdb *fdb);
+int dsa_port_fdb_dump(struct dsa_port *dp, struct switchdev_obj_port_fdb *fdb,
+		      switchdev_obj_dump_cb_t *cb);
 
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
diff --git a/net/dsa/port.c b/net/dsa/port.c
index 3382fdc07a11..18ec6d432152 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -167,3 +167,43 @@ int dsa_port_ageing_time(struct dsa_port *dp, clock_t ageing_clock,
 
 	return 0;
 }
+
+int dsa_port_fdb_add(struct dsa_port *dp,
+		     const struct switchdev_obj_port_fdb *fdb,
+		     struct switchdev_trans *trans)
+{
+	struct dsa_switch *ds = dp->ds;
+
+	if (switchdev_trans_ph_prepare(trans)) {
+		if (!ds->ops->port_fdb_prepare || !ds->ops->port_fdb_add)
+			return -EOPNOTSUPP;
+
+		return ds->ops->port_fdb_prepare(ds, dp->index, fdb, trans);
+	}
+
+	ds->ops->port_fdb_add(ds, dp->index, fdb, trans);
+
+	return 0;
+}
+
+int dsa_port_fdb_del(struct dsa_port *dp,
+		     const struct switchdev_obj_port_fdb *fdb)
+{
+	struct dsa_switch *ds = dp->ds;
+
+	if (ds->ops->port_fdb_del)
+		return -EOPNOTSUPP;
+
+	return ds->ops->port_fdb_del(ds, dp->index, fdb);
+}
+
+int dsa_port_fdb_dump(struct dsa_port *dp, struct switchdev_obj_port_fdb *fdb,
+		      switchdev_obj_dump_cb_t *cb)
+{
+	struct dsa_switch *ds = dp->ds;
+
+	if (ds->ops->port_fdb_dump)
+		return ds->ops->port_fdb_dump(ds, dp->index, fdb, cb);
+
+	return -EOPNOTSUPP;
+}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 1b0f396c4314..d9b7bf759f44 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -245,48 +245,6 @@ static int dsa_port_vlan_dump(struct dsa_port *dp,
 	return -EOPNOTSUPP;
 }
 
-static int dsa_port_fdb_add(struct dsa_port *dp,
-			    const struct switchdev_obj_port_fdb *fdb,
-			    struct switchdev_trans *trans)
-{
-	struct dsa_switch *ds = dp->ds;
-
-	if (switchdev_trans_ph_prepare(trans)) {
-		if (!ds->ops->port_fdb_prepare || !ds->ops->port_fdb_add)
-			return -EOPNOTSUPP;
-
-		return ds->ops->port_fdb_prepare(ds, dp->index, fdb, trans);
-	}
-
-	ds->ops->port_fdb_add(ds, dp->index, fdb, trans);
-
-	return 0;
-}
-
-static int dsa_port_fdb_del(struct dsa_port *dp,
-			    const struct switchdev_obj_port_fdb *fdb)
-{
-	struct dsa_switch *ds = dp->ds;
-	int ret = -EOPNOTSUPP;
-
-	if (ds->ops->port_fdb_del)
-		ret = ds->ops->port_fdb_del(ds, dp->index, fdb);
-
-	return ret;
-}
-
-static int dsa_port_fdb_dump(struct dsa_port *dp,
-			     struct switchdev_obj_port_fdb *fdb,
-			     switchdev_obj_dump_cb_t *cb)
-{
-	struct dsa_switch *ds = dp->ds;
-
-	if (ds->ops->port_fdb_dump)
-		return ds->ops->port_fdb_dump(ds, dp->index, fdb, cb);
-
-	return -EOPNOTSUPP;
-}
-
 static int dsa_port_mdb_add(struct dsa_port *dp,
 			    const struct switchdev_obj_port_mdb *mdb,
 			    struct switchdev_trans *trans)
-- 
2.13.0
