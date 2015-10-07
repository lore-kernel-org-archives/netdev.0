From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/6] net: dsa: push prepare phase in port_fdb_add
Date: Wed,  7 Oct 2015 19:48:30 -0400
Message-ID: <1444261711-1829-6-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the prepare phase is pushed down to the DSA drivers, propagate
it to the port_fdb_add function.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 7 ++++---
 drivers/net/dsa/mv88e6xxx.h | 3 ++-
 include/net/dsa.h           | 3 ++-
 net/dsa/slave.c             | 2 +-
 4 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 9fbb727..916c98e 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1852,16 +1852,17 @@ int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
 }
 
 int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
-			   const unsigned char *addr, u16 vid)
+			   const struct switchdev_obj_port_fdb *fdb,
+			   struct switchdev_trans *trans)
 {
-	int state = is_multicast_ether_addr(addr) ?
+	int state = is_multicast_ether_addr(fdb->addr) ?
 		GLOBAL_ATU_DATA_STATE_MC_STATIC :
 		GLOBAL_ATU_DATA_STATE_UC_STATIC;
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_port_fdb_load(ds, port, addr, vid, state);
+	ret = _mv88e6xxx_port_fdb_load(ds, port, fdb->addr, fdb->vid, state);
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 4475640..e688bee 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -483,7 +483,8 @@ int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
 			       const struct switchdev_obj_port_fdb *fdb,
 			       struct switchdev_trans *trans);
 int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
-			   const unsigned char *addr, u16 vid);
+			   const struct switchdev_obj_port_fdb *fdb,
+			   struct switchdev_trans *trans);
 int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 			   const unsigned char *addr, u16 vid);
 int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 3aee8a5..2d86d31 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -321,7 +321,8 @@ struct dsa_switch_driver {
 				    const struct switchdev_obj_port_fdb *fdb,
 				    struct switchdev_trans *trans);
 	int	(*port_fdb_add)(struct dsa_switch *ds, int port,
-				const unsigned char *addr, u16 vid);
+				const struct switchdev_obj_port_fdb *fdb,
+				struct switchdev_trans *trans);
 	int	(*port_fdb_del)(struct dsa_switch *ds, int port,
 				const unsigned char *addr, u16 vid);
 	int	(*port_fdb_getnext)(struct dsa_switch *ds, int port,
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 48e8c15..6f7f27e 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -354,7 +354,7 @@ static int dsa_slave_port_fdb_add(struct net_device *dev,
 	if (switchdev_trans_ph_prepare(trans))
 		ret = ds->drv->port_fdb_prepare(ds, p->port, fdb, trans);
 	else
-		ret = ds->drv->port_fdb_add(ds, p->port, fdb->addr, fdb->vid);
+		ret = ds->drv->port_fdb_add(ds, p->port, fdb, trans);
 
 	return ret;
 }
-- 
2.6.0
