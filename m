From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/8] net: dsa: mv88e6xxx: prefix Global ATU macros
Date: Thu, 15 Jun 2017 12:14:01 -0400
Message-ID: <20170615161406.20546-4-vivien.didelot@savoirfairelinux.com>
References: <20170615161406.20546-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615161406.20546-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prefix and document the Global ATU Registers macros and give clear
16-bit registers representation.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c        | 22 +++++-----
 drivers/net/dsa/mv88e6xxx/global1.h     | 75 +++++++++++++++++++--------------
 drivers/net/dsa/mv88e6xxx/global1_atu.c | 56 ++++++++++++------------
 3 files changed, 85 insertions(+), 68 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b048f851786a..066fa63c6b6e 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1383,7 +1383,7 @@ static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
 	if (err)
 		return err;
 
-	entry.state = GLOBAL_ATU_DATA_STATE_UNUSED;
+	entry.state = MV88E6XXX_G1_ATU_DATA_STATE_UNUSED;
 	ether_addr_copy(entry.mac, addr);
 	eth_addr_dec(entry.mac);
 
@@ -1392,17 +1392,17 @@ static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
 		return err;
 
 	/* Initialize a fresh ATU entry if it isn't found */
-	if (entry.state == GLOBAL_ATU_DATA_STATE_UNUSED ||
+	if (entry.state == MV88E6XXX_G1_ATU_DATA_STATE_UNUSED ||
 	    !ether_addr_equal(entry.mac, addr)) {
 		memset(&entry, 0, sizeof(entry));
 		ether_addr_copy(entry.mac, addr);
 	}
 
 	/* Purge the ATU entry only if no port is using it anymore */
-	if (state == GLOBAL_ATU_DATA_STATE_UNUSED) {
+	if (state == MV88E6XXX_G1_ATU_DATA_STATE_UNUSED) {
 		entry.portvec &= ~BIT(port);
 		if (!entry.portvec)
-			entry.state = GLOBAL_ATU_DATA_STATE_UNUSED;
+			entry.state = MV88E6XXX_G1_ATU_DATA_STATE_UNUSED;
 	} else {
 		entry.portvec |= BIT(port);
 		entry.state = state;
@@ -1429,7 +1429,7 @@ static void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 
 	mutex_lock(&chip->reg_lock);
 	if (mv88e6xxx_port_db_load_purge(chip, port, fdb->addr, fdb->vid,
-					 GLOBAL_ATU_DATA_STATE_UC_STATIC))
+					 MV88E6XXX_G1_ATU_DATA_STATE_UC_STATIC))
 		dev_err(ds->dev, "p%d: failed to load unicast MAC address\n",
 			port);
 	mutex_unlock(&chip->reg_lock);
@@ -1443,7 +1443,7 @@ static int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 
 	mutex_lock(&chip->reg_lock);
 	err = mv88e6xxx_port_db_load_purge(chip, port, fdb->addr, fdb->vid,
-					   GLOBAL_ATU_DATA_STATE_UNUSED);
+					   MV88E6XXX_G1_ATU_DATA_STATE_UNUSED);
 	mutex_unlock(&chip->reg_lock);
 
 	return err;
@@ -1457,7 +1457,7 @@ static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
 	struct mv88e6xxx_atu_entry addr;
 	int err;
 
-	addr.state = GLOBAL_ATU_DATA_STATE_UNUSED;
+	addr.state = MV88E6XXX_G1_ATU_DATA_STATE_UNUSED;
 	eth_broadcast_addr(addr.mac);
 
 	do {
@@ -1465,7 +1465,7 @@ static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
 		if (err)
 			return err;
 
-		if (addr.state == GLOBAL_ATU_DATA_STATE_UNUSED)
+		if (addr.state == MV88E6XXX_G1_ATU_DATA_STATE_UNUSED)
 			break;
 
 		if (addr.trunk || (addr.portvec & BIT(port)) == 0)
@@ -1480,7 +1480,7 @@ static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
 			fdb = SWITCHDEV_OBJ_PORT_FDB(obj);
 			fdb->vid = vid;
 			ether_addr_copy(fdb->addr, addr.mac);
-			if (addr.state == GLOBAL_ATU_DATA_STATE_UC_STATIC)
+			if (addr.state == MV88E6XXX_G1_ATU_DATA_STATE_UC_STATIC)
 				fdb->ndm_state = NUD_NOARP;
 			else
 				fdb->ndm_state = NUD_REACHABLE;
@@ -3755,7 +3755,7 @@ static void mv88e6xxx_port_mdb_add(struct dsa_switch *ds, int port,
 
 	mutex_lock(&chip->reg_lock);
 	if (mv88e6xxx_port_db_load_purge(chip, port, mdb->addr, mdb->vid,
-					 GLOBAL_ATU_DATA_STATE_MC_STATIC))
+					 MV88E6XXX_G1_ATU_DATA_STATE_MC_STATIC))
 		dev_err(ds->dev, "p%d: failed to load multicast MAC address\n",
 			port);
 	mutex_unlock(&chip->reg_lock);
@@ -3769,7 +3769,7 @@ static int mv88e6xxx_port_mdb_del(struct dsa_switch *ds, int port,
 
 	mutex_lock(&chip->reg_lock);
 	err = mv88e6xxx_port_db_load_purge(chip, port, mdb->addr, mdb->vid,
-					   GLOBAL_ATU_DATA_STATE_UNUSED);
+					   MV88E6XXX_G1_ATU_DATA_STATE_UNUSED);
 	mutex_unlock(&chip->reg_lock);
 
 	return err;
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 267233d40cb3..126515532d53 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -44,7 +44,9 @@
 #define MV88E6XXX_G1_MAC_23		0x02
 #define MV88E6XXX_G1_MAC_45		0x03
 
-#define GLOBAL_ATU_FID		0x01
+/* Offset 0x01: ATU FID Register */
+#define MV88E6352_G1_ATU_FID		0x01
+
 #define GLOBAL_VTU_FID		0x02
 #define GLOBAL_VTU_FID_MASK	0xfff
 #define GLOBAL_VTU_SID		0x03	/* 6097 6165 6351 6352 */
@@ -87,36 +89,47 @@
 #define GLOBAL_STU_DATA_PORT_STATE_BLOCKING	0x01
 #define GLOBAL_STU_DATA_PORT_STATE_LEARNING	0x02
 #define GLOBAL_STU_DATA_PORT_STATE_FORWARDING	0x03
-#define GLOBAL_ATU_CONTROL	0x0a
-#define GLOBAL_ATU_CONTROL_LEARN2ALL	BIT(3)
-#define GLOBAL_ATU_OP		0x0b
-#define GLOBAL_ATU_OP_BUSY	BIT(15)
-#define GLOBAL_ATU_OP_NOP		(0 << 12)
-#define GLOBAL_ATU_OP_FLUSH_MOVE_ALL		((1 << 12) | GLOBAL_ATU_OP_BUSY)
-#define GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC	((2 << 12) | GLOBAL_ATU_OP_BUSY)
-#define GLOBAL_ATU_OP_LOAD_DB		((3 << 12) | GLOBAL_ATU_OP_BUSY)
-#define GLOBAL_ATU_OP_GET_NEXT_DB	((4 << 12) | GLOBAL_ATU_OP_BUSY)
-#define GLOBAL_ATU_OP_FLUSH_MOVE_ALL_DB		((5 << 12) | GLOBAL_ATU_OP_BUSY)
-#define GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC_DB ((6 << 12) | GLOBAL_ATU_OP_BUSY)
-#define GLOBAL_ATU_OP_GET_CLR_VIOLATION	  ((7 << 12) | GLOBAL_ATU_OP_BUSY)
-#define GLOBAL_ATU_DATA		0x0c
-#define GLOBAL_ATU_DATA_TRUNK			BIT(15)
-#define GLOBAL_ATU_DATA_TRUNK_ID_MASK		0x00f0
-#define GLOBAL_ATU_DATA_TRUNK_ID_SHIFT		4
-#define GLOBAL_ATU_DATA_PORT_VECTOR_MASK	0x3ff0
-#define GLOBAL_ATU_DATA_PORT_VECTOR_SHIFT	4
-#define GLOBAL_ATU_DATA_STATE_MASK		0x0f
-#define GLOBAL_ATU_DATA_STATE_UNUSED		0x00
-#define GLOBAL_ATU_DATA_STATE_UC_MGMT		0x0d
-#define GLOBAL_ATU_DATA_STATE_UC_STATIC		0x0e
-#define GLOBAL_ATU_DATA_STATE_UC_PRIO_OVER	0x0f
-#define GLOBAL_ATU_DATA_STATE_MC_NONE_RATE	0x05
-#define GLOBAL_ATU_DATA_STATE_MC_STATIC		0x07
-#define GLOBAL_ATU_DATA_STATE_MC_MGMT		0x0e
-#define GLOBAL_ATU_DATA_STATE_MC_PRIO_OVER	0x0f
-#define GLOBAL_ATU_MAC_01	0x0d
-#define GLOBAL_ATU_MAC_23	0x0e
-#define GLOBAL_ATU_MAC_45	0x0f
+
+/* Offset 0x0A: ATU Control Register */
+#define MV88E6XXX_G1_ATU_CTL		0x0a
+#define MV88E6XXX_G1_ATU_CTL_LEARN2ALL	0x0008
+
+/* Offset 0x0B: ATU Operation Register */
+#define MV88E6XXX_G1_ATU_OP				0x0b
+#define MV88E6XXX_G1_ATU_OP_BUSY			0x8000
+#define MV88E6XXX_G1_ATU_OP_MASK			0x7000
+#define MV88E6XXX_G1_ATU_OP_NOOP			0x0000
+#define MV88E6XXX_G1_ATU_OP_FLUSH_MOVE_ALL		0x1000
+#define MV88E6XXX_G1_ATU_OP_FLUSH_MOVE_NON_STATIC	0x2000
+#define MV88E6XXX_G1_ATU_OP_LOAD_DB			0x3000
+#define MV88E6XXX_G1_ATU_OP_GET_NEXT_DB			0x4000
+#define MV88E6XXX_G1_ATU_OP_FLUSH_MOVE_ALL_DB		0x5000
+#define MV88E6XXX_G1_ATU_OP_FLUSH_MOVE_NON_STATIC_DB	0x6000
+#define MV88E6XXX_G1_ATU_OP_GET_CLR_VIOLATION		0x7000
+
+/* Offset 0x0C: ATU Data Register */
+#define MV88E6XXX_G1_ATU_DATA				0x0c
+#define MV88E6XXX_G1_ATU_DATA_TRUNK			0x8000
+#define MV88E6XXX_G1_ATU_DATA_TRUNK_ID_MASK		0x00f0
+#define MV88E6XXX_G1_ATU_DATA_PORT_VECTOR_MASK		0x3ff0
+#define MV88E6XXX_G1_ATU_DATA_STATE_MASK		0x000f
+#define MV88E6XXX_G1_ATU_DATA_STATE_UNUSED		0x0000
+#define MV88E6XXX_G1_ATU_DATA_STATE_UC_MGMT		0x000d
+#define MV88E6XXX_G1_ATU_DATA_STATE_UC_STATIC		0x000e
+#define MV88E6XXX_G1_ATU_DATA_STATE_UC_PRIO_OVER	0x000f
+#define MV88E6XXX_G1_ATU_DATA_STATE_MC_NONE_RATE	0x0005
+#define MV88E6XXX_G1_ATU_DATA_STATE_MC_STATIC		0x0007
+#define MV88E6XXX_G1_ATU_DATA_STATE_MC_MGMT		0x000e
+#define MV88E6XXX_G1_ATU_DATA_STATE_MC_PRIO_OVER	0x000f
+
+/* Offset 0x0D: ATU MAC Address Register Bytes 0 & 1
+ * Offset 0x0E: ATU MAC Address Register Bytes 2 & 3
+ * Offset 0x0F: ATU MAC Address Register Bytes 4 & 5
+ */
+#define MV88E6XXX_G1_ATU_MAC01		0x0d
+#define MV88E6XXX_G1_ATU_MAC23		0x0e
+#define MV88E6XXX_G1_ATU_MAC45		0x0f
+
 #define GLOBAL_IP_PRI_0		0x10
 #define GLOBAL_IP_PRI_1		0x11
 #define GLOBAL_IP_PRI_2		0x12
diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
index 6b0cf44dc07d..efeef4b01442 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_atu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
@@ -17,7 +17,7 @@
 
 static int mv88e6xxx_g1_atu_fid_write(struct mv88e6xxx_chip *chip, u16 fid)
 {
-	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_FID, fid & 0xfff);
+	return mv88e6xxx_g1_write(chip, MV88E6352_G1_ATU_FID, fid & 0xfff);
 }
 
 /* Offset 0x0A: ATU Control Register */
@@ -27,16 +27,16 @@ int mv88e6xxx_g1_atu_set_learn2all(struct mv88e6xxx_chip *chip, bool learn2all)
 	u16 val;
 	int err;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_CONTROL, &val);
+	err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_ATU_CTL, &val);
 	if (err)
 		return err;
 
 	if (learn2all)
-		val |= GLOBAL_ATU_CONTROL_LEARN2ALL;
+		val |= MV88E6XXX_G1_ATU_CTL_LEARN2ALL;
 	else
-		val &= ~GLOBAL_ATU_CONTROL_LEARN2ALL;
+		val &= ~MV88E6XXX_G1_ATU_CTL_LEARN2ALL;
 
-	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
+	return mv88e6xxx_g1_write(chip, MV88E6XXX_G1_ATU_CTL, val);
 }
 
 int mv88e6xxx_g1_atu_set_age_time(struct mv88e6xxx_chip *chip,
@@ -55,7 +55,7 @@ int mv88e6xxx_g1_atu_set_age_time(struct mv88e6xxx_chip *chip,
 	/* Round to nearest multiple of coeff */
 	age_time = (msecs + coeff / 2) / coeff;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_CONTROL, &val);
+	err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_ATU_CTL, &val);
 	if (err)
 		return err;
 
@@ -63,7 +63,7 @@ int mv88e6xxx_g1_atu_set_age_time(struct mv88e6xxx_chip *chip,
 	val &= ~0xff0;
 	val |= age_time << 4;
 
-	err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_ATU_CTL, val);
 	if (err)
 		return err;
 
@@ -77,7 +77,8 @@ int mv88e6xxx_g1_atu_set_age_time(struct mv88e6xxx_chip *chip,
 
 static int mv88e6xxx_g1_atu_op_wait(struct mv88e6xxx_chip *chip)
 {
-	return mv88e6xxx_g1_wait(chip, GLOBAL_ATU_OP, GLOBAL_ATU_OP_BUSY);
+	return mv88e6xxx_g1_wait(chip, MV88E6XXX_G1_ATU_OP,
+				 MV88E6XXX_G1_ATU_OP_BUSY);
 }
 
 static int mv88e6xxx_g1_atu_op(struct mv88e6xxx_chip *chip, u16 fid, u16 op)
@@ -93,12 +94,14 @@ static int mv88e6xxx_g1_atu_op(struct mv88e6xxx_chip *chip, u16 fid, u16 op)
 	} else {
 		if (mv88e6xxx_num_databases(chip) > 16) {
 			/* ATU DBNum[7:4] are located in ATU Control 15:12 */
-			err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_CONTROL, &val);
+			err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_ATU_CTL,
+						&val);
 			if (err)
 				return err;
 
 			val = (val & 0x0fff) | ((fid << 8) & 0xf000);
-			err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
+			err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_ATU_CTL,
+						 val);
 			if (err)
 				return err;
 		}
@@ -107,7 +110,8 @@ static int mv88e6xxx_g1_atu_op(struct mv88e6xxx_chip *chip, u16 fid, u16 op)
 		op |= fid & 0xf;
 	}
 
-	err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_OP, op);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_ATU_OP,
+				 MV88E6XXX_G1_ATU_OP_BUSY | op);
 	if (err)
 		return err;
 
@@ -122,13 +126,13 @@ static int mv88e6xxx_g1_atu_data_read(struct mv88e6xxx_chip *chip,
 	u16 val;
 	int err;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_DATA, &val);
+	err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_ATU_DATA, &val);
 	if (err)
 		return err;
 
 	entry->state = val & 0xf;
-	if (entry->state != GLOBAL_ATU_DATA_STATE_UNUSED) {
-		entry->trunk = !!(val & GLOBAL_ATU_DATA_TRUNK);
+	if (entry->state != MV88E6XXX_G1_ATU_DATA_STATE_UNUSED) {
+		entry->trunk = !!(val & MV88E6XXX_G1_ATU_DATA_TRUNK);
 		entry->portvec = (val >> 4) & mv88e6xxx_port_mask(chip);
 	}
 
@@ -140,14 +144,14 @@ static int mv88e6xxx_g1_atu_data_write(struct mv88e6xxx_chip *chip,
 {
 	u16 data = entry->state & 0xf;
 
-	if (entry->state != GLOBAL_ATU_DATA_STATE_UNUSED) {
+	if (entry->state != MV88E6XXX_G1_ATU_DATA_STATE_UNUSED) {
 		if (entry->trunk)
-			data |= GLOBAL_ATU_DATA_TRUNK;
+			data |= MV88E6XXX_G1_ATU_DATA_TRUNK;
 
 		data |= (entry->portvec & mv88e6xxx_port_mask(chip)) << 4;
 	}
 
-	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_DATA, data);
+	return mv88e6xxx_g1_write(chip, MV88E6XXX_G1_ATU_DATA, data);
 }
 
 /* Offset 0x0D: ATU MAC Address Register Bytes 0 & 1
@@ -162,7 +166,7 @@ static int mv88e6xxx_g1_atu_mac_read(struct mv88e6xxx_chip *chip,
 	int i, err;
 
 	for (i = 0; i < 3; i++) {
-		err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_MAC_01 + i, &val);
+		err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_ATU_MAC01 + i, &val);
 		if (err)
 			return err;
 
@@ -181,7 +185,7 @@ static int mv88e6xxx_g1_atu_mac_write(struct mv88e6xxx_chip *chip,
 
 	for (i = 0; i < 3; i++) {
 		val = (entry->mac[i * 2] << 8) | entry->mac[i * 2 + 1];
-		err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_MAC_01 + i, val);
+		err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_ATU_MAC01 + i, val);
 		if (err)
 			return err;
 	}
@@ -201,13 +205,13 @@ int mv88e6xxx_g1_atu_getnext(struct mv88e6xxx_chip *chip, u16 fid,
 		return err;
 
 	/* Write the MAC address to iterate from only once */
-	if (entry->state == GLOBAL_ATU_DATA_STATE_UNUSED) {
+	if (entry->state == MV88E6XXX_G1_ATU_DATA_STATE_UNUSED) {
 		err = mv88e6xxx_g1_atu_mac_write(chip, entry);
 		if (err)
 			return err;
 	}
 
-	err = mv88e6xxx_g1_atu_op(chip, fid, GLOBAL_ATU_OP_GET_NEXT_DB);
+	err = mv88e6xxx_g1_atu_op(chip, fid, MV88E6XXX_G1_ATU_OP_GET_NEXT_DB);
 	if (err)
 		return err;
 
@@ -235,7 +239,7 @@ int mv88e6xxx_g1_atu_loadpurge(struct mv88e6xxx_chip *chip, u16 fid,
 	if (err)
 		return err;
 
-	return mv88e6xxx_g1_atu_op(chip, fid, GLOBAL_ATU_OP_LOAD_DB);
+	return mv88e6xxx_g1_atu_op(chip, fid, MV88E6XXX_G1_ATU_OP_LOAD_DB);
 }
 
 static int mv88e6xxx_g1_atu_flushmove(struct mv88e6xxx_chip *chip, u16 fid,
@@ -255,13 +259,13 @@ static int mv88e6xxx_g1_atu_flushmove(struct mv88e6xxx_chip *chip, u16 fid,
 
 	/* Flush/Move all or non-static entries from all or a given database */
 	if (all && fid)
-		op = GLOBAL_ATU_OP_FLUSH_MOVE_ALL_DB;
+		op = MV88E6XXX_G1_ATU_OP_FLUSH_MOVE_ALL_DB;
 	else if (fid)
-		op = GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC_DB;
+		op = MV88E6XXX_G1_ATU_OP_FLUSH_MOVE_NON_STATIC_DB;
 	else if (all)
-		op = GLOBAL_ATU_OP_FLUSH_MOVE_ALL;
+		op = MV88E6XXX_G1_ATU_OP_FLUSH_MOVE_ALL;
 	else
-		op = GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC;
+		op = MV88E6XXX_G1_ATU_OP_FLUSH_MOVE_NON_STATIC;
 
 	return mv88e6xxx_g1_atu_op(chip, fid, op);
 }
-- 
2.13.1
