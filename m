From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 08/11] net: dsa: restore mdb dump
Date: Mon, 14 Aug 2017 18:22:39 -0400
Message-ID: <20170814222242.10643-9-vivien.didelot@savoirfairelinux.com>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Maxime Hadjinlian <maxime@devialet.com>,
        Chris Healy <cphealy@gmail.com>,
        Maxim Uvarov <muvarov@gmail.com>,
        Stefan Eichenberger <eichest@gmail.com>,
        Jason Cobham <jcobham@questertangent.com>,
        Juergen Borleis <jbe@pengutronix.de>,
        Tobias Waldekranz <tobias@waldekranz.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The same dsa_fdb_dump_cb_t callback is used since there is no
distinction to do between FDB and MDB entries at this layer.

Implement mv88e6xxx_port_mdb_dump so that multicast addresses associated
to a switch port can be dumped.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 33 +++++++++++++++++++++++++--------
 include/net/dsa.h                |  3 +++
 2 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 918d8f0fe091..2ad32734b6f6 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1380,7 +1380,7 @@ static int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 }
 
 static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
-				      u16 fid, u16 vid, int port,
+				      u16 fid, u16 vid, int port, bool mc,
 				      dsa_fdb_dump_cb_t *cb, void *data)
 {
 	struct mv88e6xxx_atu_entry addr;
@@ -1401,11 +1401,14 @@ static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
 		if (addr.trunk || (addr.portvec & BIT(port)) == 0)
 			continue;
 
-		if (!is_unicast_ether_addr(addr.mac))
+		if ((is_unicast_ether_addr(addr.mac) && mc) ||
+		    (is_multicast_ether_addr(addr.mac) && !mc))
 			continue;
 
-		is_static = (addr.state ==
-			     MV88E6XXX_G1_ATU_DATA_STATE_UC_STATIC);
+		is_static = addr.state == mc ?
+			MV88E6XXX_G1_ATU_DATA_STATE_MC_STATIC :
+			MV88E6XXX_G1_ATU_DATA_STATE_UC_STATIC;
+
 		err = cb(addr.mac, vid, is_static, data);
 		if (err)
 			return err;
@@ -1415,7 +1418,7 @@ static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
 }
 
 static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
-				  dsa_fdb_dump_cb_t *cb, void *data)
+				  bool mc, dsa_fdb_dump_cb_t *cb, void *data)
 {
 	struct mv88e6xxx_vtu_entry vlan = {
 		.vid = chip->info->max_vid,
@@ -1428,7 +1431,7 @@ static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
 	if (err)
 		return err;
 
-	err = mv88e6xxx_port_db_dump_fid(chip, fid, 0, port, cb, data);
+	err = mv88e6xxx_port_db_dump_fid(chip, fid, 0, port, mc, cb, data);
 	if (err)
 		return err;
 
@@ -1442,7 +1445,7 @@ static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
 			break;
 
 		err = mv88e6xxx_port_db_dump_fid(chip, vlan.fid, vlan.vid, port,
-						 cb, data);
+						 mc, cb, data);
 		if (err)
 			return err;
 	} while (vlan.vid < chip->info->max_vid);
@@ -1457,7 +1460,7 @@ static int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 	int err;
 
 	mutex_lock(&chip->reg_lock);
-	err = mv88e6xxx_port_db_dump(chip, port, cb, data);
+	err = mv88e6xxx_port_db_dump(chip, port, false, cb, data);
 	mutex_unlock(&chip->reg_lock);
 
 	return err;
@@ -3777,6 +3780,19 @@ static int mv88e6xxx_port_mdb_del(struct dsa_switch *ds, int port,
 	return err;
 }
 
+static int mv88e6xxx_port_mdb_dump(struct dsa_switch *ds, int port,
+				   dsa_fdb_dump_cb_t *cb, void *data)
+{
+	struct mv88e6xxx_chip *chip = ds->priv;
+	int err;
+
+	mutex_lock(&chip->reg_lock);
+	err = mv88e6xxx_port_db_dump(chip, port, true, cb, data);
+	mutex_unlock(&chip->reg_lock);
+
+	return err;
+}
+
 static const struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.probe			= mv88e6xxx_drv_probe,
 	.get_tag_protocol	= mv88e6xxx_get_tag_protocol,
@@ -3810,6 +3826,7 @@ static const struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.port_mdb_prepare       = mv88e6xxx_port_mdb_prepare,
 	.port_mdb_add           = mv88e6xxx_port_mdb_add,
 	.port_mdb_del           = mv88e6xxx_port_mdb_del,
+	.port_mdb_dump          = mv88e6xxx_port_mdb_dump,
 	.crosschip_bridge_join	= mv88e6xxx_crosschip_bridge_join,
 	.crosschip_bridge_leave	= mv88e6xxx_crosschip_bridge_leave,
 };
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 4ef5d38755d9..1fd419031948 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -288,6 +288,7 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 		return ds->rtable[dst->cpu_dp->ds->index];
 }
 
+/* FDB (and MDB) dump callback */
 typedef int dsa_fdb_dump_cb_t(const unsigned char *addr, u16 vid,
 			      bool is_static, void *data);
 struct dsa_switch_ops {
@@ -417,6 +418,8 @@ struct dsa_switch_ops {
 				struct switchdev_trans *trans);
 	int	(*port_mdb_del)(struct dsa_switch *ds, int port,
 				const struct switchdev_obj_port_mdb *mdb);
+	int	(*port_mdb_dump)(struct dsa_switch *ds, int port,
+				 dsa_fdb_dump_cb_t *cb, void *data);
 	/*
 	 * RXNFC
 	 */
-- 
2.14.0
