From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/3] net: dsa: mv88e6xxx: add MDB support
Date: Mon, 29 Aug 2016 16:32:46 -0400
Message-ID: <20160829203246.18811-4-vivien.didelot@savoirfairelinux.com>
References: <20160829203246.18811-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160829203246.18811-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for the MDB operations. This consists of
loading/purging/dumping multicast addresses for a given port in the ATU.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 65 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 65 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 93abfff..812cb47 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2240,6 +2240,15 @@ static int mv88e6xxx_port_db_dump_one(struct mv88e6xxx_chip *chip,
 				fdb->ndm_state = NUD_NOARP;
 			else
 				fdb->ndm_state = NUD_REACHABLE;
+		} else {
+			struct switchdev_obj_port_mdb *mdb;
+
+			if (!is_multicast_ether_addr(addr.mac))
+				continue;
+
+			mdb = SWITCHDEV_OBJ_PORT_MDB(obj);
+			mdb->vid = vid;
+			ether_addr_copy(mdb->addr, addr.mac);
 		}
 
 		err = cb(obj);
@@ -3988,6 +3997,58 @@ free:
 	return NULL;
 }
 
+static int mv88e6xxx_port_mdb_prepare(struct dsa_switch *ds, int port,
+				      const struct switchdev_obj_port_mdb *mdb,
+				      struct switchdev_trans *trans)
+{
+	/* We don't need any dynamic resource from the kernel (yet),
+	 * so skip the prepare phase.
+	 */
+
+	return 0;
+}
+
+static void mv88e6xxx_port_mdb_add(struct dsa_switch *ds, int port,
+				   const struct switchdev_obj_port_mdb *mdb,
+				   struct switchdev_trans *trans)
+{
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+
+	mutex_lock(&chip->reg_lock);
+	if (mv88e6xxx_port_db_load_purge(chip, port, mdb->addr, mdb->vid,
+					 GLOBAL_ATU_DATA_STATE_MC_STATIC))
+		netdev_err(ds->ports[port].netdev, "failed to load multicast MAC address\n");
+	mutex_unlock(&chip->reg_lock);
+}
+
+static int mv88e6xxx_port_mdb_del(struct dsa_switch *ds, int port,
+				  const struct switchdev_obj_port_mdb *mdb)
+{
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	int err;
+
+	mutex_lock(&chip->reg_lock);
+	err = mv88e6xxx_port_db_load_purge(chip, port, mdb->addr, mdb->vid,
+					   GLOBAL_ATU_DATA_STATE_UNUSED);
+	mutex_unlock(&chip->reg_lock);
+
+	return err;
+}
+
+static int mv88e6xxx_port_mdb_dump(struct dsa_switch *ds, int port,
+				   struct switchdev_obj_port_mdb *mdb,
+				   int (*cb)(struct switchdev_obj *obj))
+{
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	int err;
+
+	mutex_lock(&chip->reg_lock);
+	err = mv88e6xxx_port_db_dump(chip, port, &mdb->obj, cb);
+	mutex_unlock(&chip->reg_lock);
+
+	return err;
+}
+
 static struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.probe			= mv88e6xxx_drv_probe,
 	.get_tag_protocol	= mv88e6xxx_get_tag_protocol,
@@ -4023,6 +4084,10 @@ static struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.port_fdb_add           = mv88e6xxx_port_fdb_add,
 	.port_fdb_del           = mv88e6xxx_port_fdb_del,
 	.port_fdb_dump          = mv88e6xxx_port_fdb_dump,
+	.port_mdb_prepare       = mv88e6xxx_port_mdb_prepare,
+	.port_mdb_add           = mv88e6xxx_port_mdb_add,
+	.port_mdb_del           = mv88e6xxx_port_mdb_del,
+	.port_mdb_dump          = mv88e6xxx_port_mdb_dump,
 };
 
 static int mv88e6xxx_register_switch(struct mv88e6xxx_chip *chip,
-- 
2.9.3
