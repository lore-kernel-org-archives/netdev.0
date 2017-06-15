From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/8] net: dsa: mv88e6xxx: prefix Global Switch MAC macros
Date: Thu, 15 Jun 2017 12:14:00 -0400
Message-ID: <20170615161406.20546-3-vivien.didelot@savoirfairelinux.com>
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

Prefix and document the Global Switch MAC Address Register macros and
give clear 16-bit register representation.

At the same time, move mv88e6xxx_g1_set_switch_mac in global1.c, where
it belongs.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c    | 19 -------------------
 drivers/net/dsa/mv88e6xxx/global1.c | 27 +++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global1.h | 13 ++++++++++---
 3 files changed, 37 insertions(+), 22 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 9cc10dadf17c..b048f851786a 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1979,25 +1979,6 @@ static void mv88e6xxx_port_disable(struct dsa_switch *ds, int port,
 	mutex_unlock(&chip->reg_lock);
 }
 
-static int mv88e6xxx_g1_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
-{
-	int err;
-
-	err = mv88e6xxx_g1_write(chip, GLOBAL_MAC_01, (addr[0] << 8) | addr[1]);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g1_write(chip, GLOBAL_MAC_23, (addr[2] << 8) | addr[3]);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g1_write(chip, GLOBAL_MAC_45, (addr[4] << 8) | addr[5]);
-	if (err)
-		return err;
-
-	return 0;
-}
-
 static int mv88e6xxx_set_ageing_time(struct dsa_switch *ds,
 				     unsigned int ageing_time)
 {
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index 84559d22bf4e..0ddf1021442b 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -125,6 +125,33 @@ static int mv88e6xxx_g1_wait_init_ready(struct mv88e6xxx_chip *chip)
 	return 0;
 }
 
+/* Offset 0x01: Switch MAC Address Register Bytes 0 & 1
+ * Offset 0x02: Switch MAC Address Register Bytes 2 & 3
+ * Offset 0x03: Switch MAC Address Register Bytes 4 & 5
+ */
+int mv88e6xxx_g1_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
+{
+	u16 reg;
+	int err;
+
+	reg = (addr[0] << 8) | addr[1];
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_MAC_01, reg);
+	if (err)
+		return err;
+
+	reg = (addr[2] << 8) | addr[3];
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_MAC_23, reg);
+	if (err)
+		return err;
+
+	reg = (addr[4] << 8) | addr[5];
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_MAC_45, reg);
+	if (err)
+		return err;
+
+	return 0;
+}
+
 /* Offset 0x04: Switch Global Control Register */
 
 int mv88e6185_g1_reset(struct mv88e6xxx_chip *chip)
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 7ad63a049249..267233d40cb3 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -36,9 +36,14 @@
 #define MV88E6XXX_G1_STS_IRQ_TCAM_DONE			1
 #define MV88E6XXX_G1_STS_IRQ_EEPROM_DONE		0
 
-#define GLOBAL_MAC_01		0x01
-#define GLOBAL_MAC_23		0x02
-#define GLOBAL_MAC_45		0x03
+/* Offset 0x01: Switch MAC Address Register Bytes 0 & 1
+ * Offset 0x02: Switch MAC Address Register Bytes 2 & 3
+ * Offset 0x03: Switch MAC Address Register Bytes 4 & 5
+ */
+#define MV88E6XXX_G1_MAC_01		0x01
+#define MV88E6XXX_G1_MAC_23		0x02
+#define MV88E6XXX_G1_MAC_45		0x03
+
 #define GLOBAL_ATU_FID		0x01
 #define GLOBAL_VTU_FID		0x02
 #define GLOBAL_VTU_FID_MASK	0xfff
@@ -164,6 +169,8 @@ int mv88e6xxx_g1_read(struct mv88e6xxx_chip *chip, int reg, u16 *val);
 int mv88e6xxx_g1_write(struct mv88e6xxx_chip *chip, int reg, u16 val);
 int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask);
 
+int mv88e6xxx_g1_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr);
+
 int mv88e6185_g1_reset(struct mv88e6xxx_chip *chip);
 int mv88e6352_g1_reset(struct mv88e6xxx_chip *chip);
 
-- 
2.13.1
