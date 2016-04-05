From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/3] net: dsa: make the FDB add function return void
Date: Tue,  5 Apr 2016 11:24:34 -0400
Message-ID: <1459869875-23815-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1459869875-23815-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:47646 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758588AbcDEPZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 11:25:32 -0400
In-Reply-To: <1459869875-23815-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The switchdev design implies that a software error should not happen in
the commit phase since it must have been previously reported in the
prepare phase. If an hardware error occurs during the commit phase,
there is nothing switchdev can do about it.

The DSA layer separates port_fdb_prepare and port_fdb_add for simplicity
and convenience. If an hardware error occurs during the commit phase,
there is no need to report it outside the DSA driver itself.

Make the DSA port_fdb_add routine return void for explicitness.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/bcm_sf2.c   |  9 +++++----
 drivers/net/dsa/mv88e6xxx.c | 12 +++++-------
 drivers/net/dsa/mv88e6xxx.h |  6 +++---
 include/net/dsa.h           |  2 +-
 net/dsa/slave.c             | 16 ++++++++--------
 5 files changed, 22 insertions(+), 23 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index b847624..feebeaa 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -722,13 +722,14 @@ static int bcm_sf2_sw_fdb_prepare(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-static int bcm_sf2_sw_fdb_add(struct dsa_switch *ds, int port,
-			      const struct switchdev_obj_port_fdb *fdb,
-			      struct switchdev_trans *trans)
+static void bcm_sf2_sw_fdb_add(struct dsa_switch *ds, int port,
+			       const struct switchdev_obj_port_fdb *fdb,
+			       struct switchdev_trans *trans)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 
-	return bcm_sf2_arl_op(priv, 0, port, fdb->addr, fdb->vid, true);
+	if (bcm_sf2_arl_op(priv, 0, port, fdb->addr, fdb->vid, true))
+		pr_err("%s: failed to add address\n", __func__);
 }
 
 static int bcm_sf2_sw_fdb_del(struct dsa_switch *ds, int port,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 5a2e46d..bca9a2c 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2090,21 +2090,19 @@ int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
-			   const struct switchdev_obj_port_fdb *fdb,
-			   struct switchdev_trans *trans)
+void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
+			    const struct switchdev_obj_port_fdb *fdb,
+			    struct switchdev_trans *trans)
 {
 	int state = is_multicast_ether_addr(fdb->addr) ?
 		GLOBAL_ATU_DATA_STATE_MC_STATIC :
 		GLOBAL_ATU_DATA_STATE_UC_STATIC;
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_port_fdb_load(ds, port, fdb->addr, fdb->vid, state);
+	if (_mv88e6xxx_port_fdb_load(ds, port, fdb->addr, fdb->vid, state))
+		netdev_warn(ds->ports[port], "cannot load address\n");
 	mutex_unlock(&ps->smi_mutex);
-
-	return ret;
 }
 
 int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 8a62afb..ece008f 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -514,9 +514,9 @@ int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
 			       const struct switchdev_obj_port_fdb *fdb,
 			       struct switchdev_trans *trans);
-int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
-			   const struct switchdev_obj_port_fdb *fdb,
-			   struct switchdev_trans *trans);
+void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
+			    const struct switchdev_obj_port_fdb *fdb,
+			    struct switchdev_trans *trans);
 int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 			   const struct switchdev_obj_port_fdb *fdb);
 int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index eddd0f3..fa42b8c 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -324,7 +324,7 @@ struct dsa_switch_driver {
 	int	(*port_fdb_prepare)(struct dsa_switch *ds, int port,
 				    const struct switchdev_obj_port_fdb *fdb,
 				    struct switchdev_trans *trans);
-	int	(*port_fdb_add)(struct dsa_switch *ds, int port,
+	void	(*port_fdb_add)(struct dsa_switch *ds, int port,
 				const struct switchdev_obj_port_fdb *fdb,
 				struct switchdev_trans *trans);
 	int	(*port_fdb_del)(struct dsa_switch *ds, int port,
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 1c55f96..5a34bab 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -256,17 +256,17 @@ static int dsa_slave_port_fdb_add(struct net_device *dev,
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
-	int ret;
 
-	if (!ds->drv->port_fdb_prepare || !ds->drv->port_fdb_add)
-		return -EOPNOTSUPP;
+	if (switchdev_trans_ph_prepare(trans)) {
+		if (!ds->drv->port_fdb_prepare || !ds->drv->port_fdb_add)
+			return -EOPNOTSUPP;
 
-	if (switchdev_trans_ph_prepare(trans))
-		ret = ds->drv->port_fdb_prepare(ds, p->port, fdb, trans);
-	else
-		ret = ds->drv->port_fdb_add(ds, p->port, fdb, trans);
+		return ds->drv->port_fdb_prepare(ds, p->port, fdb, trans);
+	}
 
-	return ret;
+	ds->drv->port_fdb_add(ds, p->port, fdb, trans);
+
+	return 0;
 }
 
 static int dsa_slave_port_fdb_del(struct net_device *dev,
-- 
2.8.0
