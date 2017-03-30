From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 3/9] net: dsa: mv88e6xxx: program the PVT with all ones
Date: Thu, 30 Mar 2017 17:37:09 -0400
Message-ID: <20170330213715.9666-4-vivien.didelot@savoirfairelinux.com>
References: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Cross-chip Port Based VLAN Table (PVT) is currently initialized with
all ones, allowing any external ports to egress frames on local ports.

This commit implements the PVT access functions and programs the PVT
with all ones for the local switch ports only, instead of using the Init
operation. The current behavior is unchanged for the moment.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 31 ++++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx/global2.c   | 52 +++++++++++++++++++++++++++++------
 drivers/net/dsa/mv88e6xxx/global2.h   |  8 ++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  4 +++
 4 files changed, 86 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 2a32bb490f92..fb6a723c2137 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1198,15 +1198,44 @@ static int mv88e6xxx_atu_setup(struct mv88e6xxx_chip *chip)
 	return mv88e6xxx_g1_atu_set_age_time(chip, 300000);
 }
 
+static int mv88e6xxx_pvt_map(struct mv88e6xxx_chip *chip, int dev, int port)
+{
+	u16 pvlan = 0;
+
+	if (!mv88e6xxx_has_pvt(chip))
+		return -EOPNOTSUPP;
+
+	/* Skip the local source device, which uses in-chip port VLAN */
+	if (dev != chip->ds->index)
+		pvlan = mv88e6xxx_port_mask(chip);
+
+	return mv88e6xxx_g2_pvt_write(chip, dev, port, pvlan);
+}
+
 static int mv88e6xxx_pvt_setup(struct mv88e6xxx_chip *chip)
 {
+	int dev, port;
+	int err;
+
 	if (!mv88e6xxx_has_pvt(chip))
 		return 0;
 
 	/* Clear 5 Bit Port for usage with Marvell Link Street devices:
 	 * use 4 bits for the Src_Port/Src_Trunk and 5 bits for the Src_Dev.
 	 */
-	return mv88e6xxx_g2_misc_4_bit_port(chip);
+	err = mv88e6xxx_g2_misc_4_bit_port(chip);
+	if (err)
+		return err;
+
+	for (dev = 0; dev < MV88E6XXX_MAX_PVT_SWITCHES; ++dev) {
+		for (port = 0; port < MV88E6XXX_MAX_PVT_PORTS; ++port) {
+			err = mv88e6xxx_pvt_map(chip, dev, port);
+			if (err)
+				return err;
+		}
+	}
+
+	return 0;
 }
 
 static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index d64f4c15ccb7..7c6bc33a9516 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -172,6 +172,50 @@ static int mv88e6xxx_g2_clear_irl(struct mv88e6xxx_chip *chip)
 	return err;
 }
 
+/* Offset 0x0B: Cross-chip Port VLAN (Addr) Register
+ * Offset 0x0C: Cross-chip Port VLAN Data Register
+ */
+
+static int mv88e6xxx_g2_pvt_op_wait(struct mv88e6xxx_chip *chip)
+{
+	return mv88e6xxx_g2_wait(chip, GLOBAL2_PVT_ADDR, GLOBAL2_PVT_ADDR_BUSY);
+}
+
+static int mv88e6xxx_g2_pvt_op(struct mv88e6xxx_chip *chip, int src_dev,
+			       int src_port, u16 op)
+{
+	int err;
+
+	/* 9-bit Cross-chip PVT pointer: with GLOBAL2_MISC_5_BIT_PORT cleared,
+	 * source device is 5-bit, source port is 4-bit.
+	 */
+	op |= (src_dev & 0x1f) << 4;
+	op |= (src_port & 0xf);
+
+	err = mv88e6xxx_g2_write(chip, GLOBAL2_PVT_ADDR, op);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g2_pvt_op_wait(chip);
+}
+
+int mv88e6xxx_g2_pvt_write(struct mv88e6xxx_chip *chip, int src_dev,
+			   int src_port, u16 data)
+{
+	int err;
+
+	err = mv88e6xxx_g2_pvt_op_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g2_write(chip, GLOBAL2_PVT_DATA, data);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g2_pvt_op(chip, src_dev, src_port,
+				   GLOBAL2_PVT_ADDR_OP_WRITE_PVLAN);
+}
+
 /* Offset 0x0D: Switch MAC/WoL/WoF register */
 
 static int mv88e6xxx_g2_switch_mac_write(struct mv88e6xxx_chip *chip,
@@ -991,14 +1035,6 @@ int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 				return err;
 	}
 
-	if (mv88e6xxx_has_pvt(chip)) {
-		/* Initialize Cross-chip Port VLAN Table to reset defaults */
-		err = mv88e6xxx_g2_write(chip, GLOBAL2_PVT_ADDR,
-					 GLOBAL2_PVT_ADDR_OP_INIT_ONES);
-		if (err)
-			return err;
-	}
-
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_POT)) {
 		/* Clear the priority override table. */
 		err = mv88e6xxx_g2_clear_pot(chip);
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 71fb2ff541ba..96046bb12ca1 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -42,6 +42,8 @@ int mv88e6xxx_g2_get_eeprom16(struct mv88e6xxx_chip *chip,
 int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 			      struct ethtool_eeprom *eeprom, u8 *data);
 
+int mv88e6xxx_g2_pvt_write(struct mv88e6xxx_chip *chip, int src_dev,
+			   int src_port, u16 data);
 int mv88e6xxx_g2_misc_4_bit_port(struct mv88e6xxx_chip *chip);
 
 int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip);
@@ -112,6 +114,12 @@ static inline int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 	return -EOPNOTSUPP;
 }
 
+int mv88e6xxx_g2_pvt_write(struct mv88e6xxx_chip *chip, int src_dev,
+			   int src_port, u16 data)
+{
+	return -EOPNOTSUPP;
+}
+
 int mv88e6xxx_g2_misc_4_bit_port(struct mv88e6xxx_chip *chip)
 {
 	return -EOPNOTSUPP;
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index bcaa55b20f5a..c8f54986996b 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -443,6 +443,10 @@
 
 #define MV88E6XXX_N_FID		4096
 
+/* PVT limits for 4-bit port and 5-bit switch */
+#define MV88E6XXX_MAX_PVT_SWITCHES	32
+#define MV88E6XXX_MAX_PVT_PORTS		16
+
 enum mv88e6xxx_frame_mode {
 	MV88E6XXX_FRAME_MODE_NORMAL,
 	MV88E6XXX_FRAME_MODE_DSA,
-- 
2.12.1
