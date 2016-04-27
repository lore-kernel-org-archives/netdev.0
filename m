From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 04/20] net: dsa: pass dsa_port down to drivers FDB ops
Date: Wed, 27 Apr 2016 18:30:01 -0400
Message-ID: <1461796217-18893-5-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39146 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751731AbcD0Wao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 18:30:44 -0400
In-Reply-To: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that DSA as proper structure for DSA ports, pass it down to the
port_fdb_{prepare,add,del,dump} driver functions.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/bcm_sf2.c   | 20 +++++++++++---------
 drivers/net/dsa/mv88e6xxx.c | 22 +++++++++++-----------
 drivers/net/dsa/mv88e6xxx.h |  8 ++++----
 include/net/dsa.h           |  8 ++++----
 net/dsa/slave.c             |  8 ++++----
 5 files changed, 34 insertions(+), 32 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 2d7b297..f7b53fa 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -725,7 +725,7 @@ static int bcm_sf2_arl_op(struct bcm_sf2_priv *priv, int op, int port,
 	return bcm_sf2_arl_read(priv, mac, vid, &ent, &idx, is_valid);
 }
 
-static int bcm_sf2_sw_fdb_prepare(struct dsa_switch *ds, int port,
+static int bcm_sf2_sw_fdb_prepare(struct dsa_switch *ds, struct dsa_port *dp,
 				  const struct switchdev_obj_port_fdb *fdb,
 				  struct switchdev_trans *trans)
 {
@@ -733,22 +733,22 @@ static int bcm_sf2_sw_fdb_prepare(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-static void bcm_sf2_sw_fdb_add(struct dsa_switch *ds, int port,
+static void bcm_sf2_sw_fdb_add(struct dsa_switch *ds, struct dsa_port *dp,
 			       const struct switchdev_obj_port_fdb *fdb,
 			       struct switchdev_trans *trans)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 
-	if (bcm_sf2_arl_op(priv, 0, port, fdb->addr, fdb->vid, true))
+	if (bcm_sf2_arl_op(priv, 0, dp->port, fdb->addr, fdb->vid, true))
 		pr_err("%s: failed to add MAC address\n", __func__);
 }
 
-static int bcm_sf2_sw_fdb_del(struct dsa_switch *ds, int port,
+static int bcm_sf2_sw_fdb_del(struct dsa_switch *ds, struct dsa_port *dp,
 			      const struct switchdev_obj_port_fdb *fdb)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 
-	return bcm_sf2_arl_op(priv, 0, port, fdb->addr, fdb->vid, false);
+	return bcm_sf2_arl_op(priv, 0, dp->port, fdb->addr, fdb->vid, false);
 }
 
 static int bcm_sf2_arl_search_wait(struct bcm_sf2_priv *priv)
@@ -799,16 +799,18 @@ static int bcm_sf2_sw_fdb_copy(struct net_device *dev, int port,
 	return cb(&fdb->obj);
 }
 
-static int bcm_sf2_sw_fdb_dump(struct dsa_switch *ds, int port,
+static int bcm_sf2_sw_fdb_dump(struct dsa_switch *ds, struct dsa_port *dp,
 			       struct switchdev_obj_port_fdb *fdb,
 			       int (*cb)(struct switchdev_obj *obj))
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
-	struct net_device *dev = ds->ports[port];
+	struct net_device *dev;
 	struct bcm_sf2_arl_entry results[2];
 	unsigned int count = 0;
 	int ret;
 
+	dev = ds->ports[dp->port];
+
 	/* Start search operation */
 	core_writel(priv, ARLA_SRCH_STDN, CORE_ARLA_SRCH_CTL);
 
@@ -819,12 +821,12 @@ static int bcm_sf2_sw_fdb_dump(struct dsa_switch *ds, int port,
 
 		/* Read both entries, then return their values back */
 		bcm_sf2_arl_search_rd(priv, 0, &results[0]);
-		ret = bcm_sf2_sw_fdb_copy(dev, port, &results[0], fdb, cb);
+		ret = bcm_sf2_sw_fdb_copy(dev, dp->port, &results[0], fdb, cb);
 		if (ret)
 			return ret;
 
 		bcm_sf2_arl_search_rd(priv, 1, &results[1]);
-		ret = bcm_sf2_sw_fdb_copy(dev, port, &results[1], fdb, cb);
+		ret = bcm_sf2_sw_fdb_copy(dev, dp->port, &results[1], fdb, cb);
 		if (ret)
 			return ret;
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 3f78c73..c1ff763 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2031,7 +2031,7 @@ static int _mv88e6xxx_port_fdb_load(struct dsa_switch *ds, int port,
 	return _mv88e6xxx_atu_load(ds, &entry);
 }
 
-int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
+int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, struct dsa_port *dp,
 			       const struct switchdev_obj_port_fdb *fdb,
 			       struct switchdev_trans *trans)
 {
@@ -2041,7 +2041,7 @@ int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
+void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, struct dsa_port *dp,
 			    const struct switchdev_obj_port_fdb *fdb,
 			    struct switchdev_trans *trans)
 {
@@ -2051,19 +2051,19 @@ void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
 	mutex_lock(&ps->smi_mutex);
-	if (_mv88e6xxx_port_fdb_load(ds, port, fdb->addr, fdb->vid, state))
-		netdev_err(ds->ports[port], "failed to load MAC address\n");
+	if (_mv88e6xxx_port_fdb_load(ds, dp->port, fdb->addr, fdb->vid, state))
+		netdev_err(ds->ports[dp->port], "failed to load MAC address\n");
 	mutex_unlock(&ps->smi_mutex);
 }
 
-int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
+int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, struct dsa_port *dp,
 			   const struct switchdev_obj_port_fdb *fdb)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_port_fdb_load(ds, port, fdb->addr, fdb->vid,
+	ret = _mv88e6xxx_port_fdb_load(ds, dp->port, fdb->addr, fdb->vid,
 				       GLOBAL_ATU_DATA_STATE_UNUSED);
 	mutex_unlock(&ps->smi_mutex);
 
@@ -2156,7 +2156,7 @@ static int _mv88e6xxx_port_fdb_dump_one(struct dsa_switch *ds, u16 fid, u16 vid,
 	return err;
 }
 
-int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
+int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, struct dsa_port *dp,
 			    struct switchdev_obj_port_fdb *fdb,
 			    int (*cb)(struct switchdev_obj *obj))
 {
@@ -2170,11 +2170,11 @@ int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 	mutex_lock(&ps->smi_mutex);
 
 	/* Dump port's default Filtering Information Database (VLAN ID 0) */
-	err = _mv88e6xxx_port_fid_get(ds, port, &fid);
+	err = _mv88e6xxx_port_fid_get(ds, dp->port, &fid);
 	if (err)
 		goto unlock;
 
-	err = _mv88e6xxx_port_fdb_dump_one(ds, fid, 0, port, fdb, cb);
+	err = _mv88e6xxx_port_fdb_dump_one(ds, fid, 0, dp->port, fdb, cb);
 	if (err)
 		goto unlock;
 
@@ -2191,8 +2191,8 @@ int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 		if (!vlan.valid)
 			break;
 
-		err = _mv88e6xxx_port_fdb_dump_one(ds, vlan.fid, vlan.vid, port,
-						   fdb, cb);
+		err = _mv88e6xxx_port_fdb_dump_one(ds, vlan.fid, vlan.vid,
+						   dp->port, fdb, cb);
 		if (err)
 			break;
 	} while (vlan.vid < GLOBAL_VTU_VID_MASK);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 55b8eac..0b6c37a 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -508,15 +508,15 @@ int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
 int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 			     struct switchdev_obj_port_vlan *vlan,
 			     int (*cb)(struct switchdev_obj *obj));
-int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
+int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, struct dsa_port *dp,
 			       const struct switchdev_obj_port_fdb *fdb,
 			       struct switchdev_trans *trans);
-void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
+void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, struct dsa_port *dp,
 			    const struct switchdev_obj_port_fdb *fdb,
 			    struct switchdev_trans *trans);
-int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
+int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, struct dsa_port *dp,
 			   const struct switchdev_obj_port_fdb *fdb);
-int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
+int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, struct dsa_port *dp,
 			    struct switchdev_obj_port_fdb *fdb,
 			    int (*cb)(struct switchdev_obj *obj));
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg);
diff --git a/include/net/dsa.h b/include/net/dsa.h
index fb626ae..65bbf72 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -330,15 +330,15 @@ struct dsa_switch_driver {
 	/*
 	 * Forwarding database
 	 */
-	int	(*port_fdb_prepare)(struct dsa_switch *ds, int port,
+	int	(*port_fdb_prepare)(struct dsa_switch *ds, struct dsa_port *dp,
 				    const struct switchdev_obj_port_fdb *fdb,
 				    struct switchdev_trans *trans);
-	void	(*port_fdb_add)(struct dsa_switch *ds, int port,
+	void	(*port_fdb_add)(struct dsa_switch *ds, struct dsa_port *dp,
 				const struct switchdev_obj_port_fdb *fdb,
 				struct switchdev_trans *trans);
-	int	(*port_fdb_del)(struct dsa_switch *ds, int port,
+	int	(*port_fdb_del)(struct dsa_switch *ds, struct dsa_port *dp,
 				const struct switchdev_obj_port_fdb *fdb);
-	int	(*port_fdb_dump)(struct dsa_switch *ds, int port,
+	int	(*port_fdb_dump)(struct dsa_switch *ds, struct dsa_port *dp,
 				 struct switchdev_obj_port_fdb *fdb,
 				 int (*cb)(struct switchdev_obj *obj));
 };
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 9a8ea9a..1afcbc4 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -256,10 +256,10 @@ static int dsa_slave_port_fdb_add(struct net_device *dev,
 		if (!ds->drv->port_fdb_prepare || !ds->drv->port_fdb_add)
 			return -EOPNOTSUPP;
 
-		return ds->drv->port_fdb_prepare(ds, p->dp->port, fdb, trans);
+		return ds->drv->port_fdb_prepare(ds, p->dp, fdb, trans);
 	}
 
-	ds->drv->port_fdb_add(ds, p->dp->port, fdb, trans);
+	ds->drv->port_fdb_add(ds, p->dp, fdb, trans);
 
 	return 0;
 }
@@ -272,7 +272,7 @@ static int dsa_slave_port_fdb_del(struct net_device *dev,
 	int ret = -EOPNOTSUPP;
 
 	if (ds->drv->port_fdb_del)
-		ret = ds->drv->port_fdb_del(ds, p->dp->port, fdb);
+		ret = ds->drv->port_fdb_del(ds, p->dp, fdb);
 
 	return ret;
 }
@@ -285,7 +285,7 @@ static int dsa_slave_port_fdb_dump(struct net_device *dev,
 	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->drv->port_fdb_dump)
-		return ds->drv->port_fdb_dump(ds, p->dp->port, fdb, cb);
+		return ds->drv->port_fdb_dump(ds, p->dp, fdb, cb);
 
 	return -EOPNOTSUPP;
 }
-- 
2.8.0
