From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 06/17] net: dsa: mv88e6xxx: rework ATU Load/Purge
Date: Sat, 11 Mar 2017 16:12:52 -0500
Message-ID: <20170311211303.24560-7-vivien.didelot@savoirfairelinux.com>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All Marvell switch chips have an ATU accessed using the same Global (1)
register layout. Only the handling of the FID differs as more bits were
necessary to support more and more databases.

Add and use a fresh documented implementation of the ATU Load/Purge.

The static mv88e6xxx_g1_atu_{fid_write,op_wait,op,data_write,mac_write}
functions won't need to be exposed in the end so for the moment keep
their counterparts _mv88e6xxx_atu_{wait,cmd,data_write,mac_write} as is,
since they are still used by other ATU operations.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c        |  22 +------
 drivers/net/dsa/mv88e6xxx/global1.h     |   2 +
 drivers/net/dsa/mv88e6xxx/global1_atu.c | 108 ++++++++++++++++++++++++++++++++
 3 files changed, 111 insertions(+), 21 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 1ee0c05f624e..95dbf581b54a 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2045,26 +2045,6 @@ static int _mv88e6xxx_atu_mac_read(struct mv88e6xxx_chip *chip,
 	return 0;
 }
 
-static int _mv88e6xxx_atu_load(struct mv88e6xxx_chip *chip,
-			       struct mv88e6xxx_atu_entry *entry)
-{
-	int ret;
-
-	ret = _mv88e6xxx_atu_wait(chip);
-	if (ret < 0)
-		return ret;
-
-	ret = _mv88e6xxx_atu_mac_write(chip, entry->mac);
-	if (ret < 0)
-		return ret;
-
-	ret = _mv88e6xxx_atu_data_write(chip, entry);
-	if (ret < 0)
-		return ret;
-
-	return _mv88e6xxx_atu_cmd(chip, entry->fid, GLOBAL_ATU_OP_LOAD_DB);
-}
-
 static int _mv88e6xxx_atu_getnext(struct mv88e6xxx_chip *chip, u16 fid,
 				  struct mv88e6xxx_atu_entry *entry);
 
@@ -2132,7 +2112,7 @@ static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
 		entry.state = state;
 	}
 
-	return _mv88e6xxx_atu_load(chip, &entry);
+	return mv88e6xxx_g1_atu_loadpurge(chip, vlan.fid, &entry);
 }
 
 static int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 18322d05225a..2c03f2e04639 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -41,5 +41,7 @@ int mv88e6390_g1_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g1_atu_set_learn2all(struct mv88e6xxx_chip *chip, bool learn2all);
 int mv88e6xxx_g1_atu_set_age_time(struct mv88e6xxx_chip *chip,
 				  unsigned int msecs);
+int mv88e6xxx_g1_atu_loadpurge(struct mv88e6xxx_chip *chip, u16 fid,
+			       struct mv88e6xxx_atu_entry *entry);
 
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
index 843a21e05f7b..09190559178b 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_atu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
@@ -13,6 +13,13 @@
 #include "mv88e6xxx.h"
 #include "global1.h"
 
+/* Offset 0x01: ATU FID Register */
+
+static int mv88e6xxx_g1_atu_fid_write(struct mv88e6xxx_chip *chip, u16 fid)
+{
+	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_FID, fid & 0xfff);
+}
+
 /* Offset 0x0A: ATU Control Register */
 
 int mv88e6xxx_g1_atu_set_learn2all(struct mv88e6xxx_chip *chip, bool learn2all)
@@ -58,3 +65,104 @@ int mv88e6xxx_g1_atu_set_age_time(struct mv88e6xxx_chip *chip,
 
 	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
 }
+
+/* Offset 0x0B: ATU Operation Register */
+
+static int mv88e6xxx_g1_atu_op_wait(struct mv88e6xxx_chip *chip)
+{
+	return mv88e6xxx_g1_wait(chip, GLOBAL_ATU_OP, GLOBAL_ATU_OP_BUSY);
+}
+
+static int mv88e6xxx_g1_atu_op(struct mv88e6xxx_chip *chip, u16 fid, u16 op)
+{
+	u16 val;
+	int err;
+
+	/* FID bits are dispatched all around gradually as more are supported */
+	if (mv88e6xxx_num_databases(chip) > 256) {
+		err = mv88e6xxx_g1_atu_fid_write(chip, fid);
+		if (err)
+			return err;
+	} else {
+		if (mv88e6xxx_num_databases(chip) > 16) {
+			/* ATU DBNum[7:4] are located in ATU Control 15:12 */
+			err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_CONTROL, &val);
+			if (err)
+				return err;
+
+			val = (val & 0x0fff) | ((fid << 8) & 0xf000);
+			err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
+			if (err)
+				return err;
+		}
+
+		/* ATU DBNum[3:0] are located in ATU Operation 3:0 */
+		op |= fid & 0xf;
+	}
+
+	err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_OP, op);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g1_atu_op_wait(chip);
+}
+
+/* Offset 0x0C: ATU Data Register */
+
+static int mv88e6xxx_g1_atu_data_write(struct mv88e6xxx_chip *chip,
+				       struct mv88e6xxx_atu_entry *entry)
+{
+	u16 data = entry->state & 0xf;
+
+	if (entry->state != GLOBAL_ATU_DATA_STATE_UNUSED) {
+		if (entry->trunk)
+			data |= GLOBAL_ATU_DATA_TRUNK;
+
+		data |= (entry->portv_trunkid & mv88e6xxx_port_mask(chip)) << 4;
+	}
+
+	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_DATA, data);
+}
+
+/* Offset 0x0D: ATU MAC Address Register Bytes 0 & 1
+ * Offset 0x0E: ATU MAC Address Register Bytes 2 & 3
+ * Offset 0x0F: ATU MAC Address Register Bytes 4 & 5
+ */
+
+static int mv88e6xxx_g1_atu_mac_write(struct mv88e6xxx_chip *chip,
+				      struct mv88e6xxx_atu_entry *entry)
+{
+	u16 val;
+	int i, err;
+
+	for (i = 0; i < 3; i++) {
+		val = (entry->mac[i * 2] << 8) | entry->mac[i * 2 + 1];
+		err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_MAC_01 + i, val);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+/* Address Translation Unit operations */
+
+int mv88e6xxx_g1_atu_loadpurge(struct mv88e6xxx_chip *chip, u16 fid,
+			       struct mv88e6xxx_atu_entry *entry)
+{
+	int err;
+
+	err = mv88e6xxx_g1_atu_op_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g1_atu_mac_write(chip, entry);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g1_atu_data_write(chip, entry);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g1_atu_op(chip, fid, GLOBAL_ATU_OP_LOAD_DB);
+}
-- 
2.12.0
