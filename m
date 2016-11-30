From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/6] net: dsa: mv88e6xxx: add a software reset op
Date: Wed, 30 Nov 2016 17:59:27 -0500
Message-ID: <20161130225930.25510-4-vivien.didelot@savoirfairelinux.com>
References: <20161130225930.25510-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161130225930.25510-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marvell chips have different way to issue a software reset.

Old chips (such as 88E6060) have a reset bit in an ATU control register.

Newer chips moved this bit in a Global control register. Chips with
controllable PPU should reset the PPU when resetting the switch.

Add a new reset operation to implement these differences and introduce a
mv88e6xxx_software_reset() helper to wrap it conveniently.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 42 ++++++++++++++++++++++++++++-------
 drivers/net/dsa/mv88e6xxx/global1.c   | 35 +++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global1.h   |  4 ++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  3 +++
 4 files changed, 76 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 4a862c2..6bb7571 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2361,6 +2361,14 @@ static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 	mutex_unlock(&chip->reg_lock);
 }
 
+static int mv88e6xxx_software_reset(struct mv88e6xxx_chip *chip)
+{
+	if (chip->info->ops->reset)
+		return chip->info->ops->reset(chip);
+
+	return 0;
+}
+
 static void mv88e6xxx_hardware_reset(struct mv88e6xxx_chip *chip)
 {
 	struct gpio_desc *gpiod = chip->reset;
@@ -2408,14 +2416,7 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 
 	mv88e6xxx_hardware_reset(chip);
 
-	/* Reset the switch. Keep the PPU active if requested. The PPU
-	 * needs to be active to support indirect phy register access
-	 * through global registers 0x18 and 0x19.
-	 */
-	if (ppu_active)
-		err = mv88e6xxx_g1_write(chip, 0x04, 0xc000);
-	else
-		err = mv88e6xxx_g1_write(chip, 0x04, 0xc400);
+	err = mv88e6xxx_software_reset(chip);
 	if (err)
 		return err;
 
@@ -3211,6 +3212,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.reset = mv88e6185_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
@@ -3225,6 +3227,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.reset = mv88e6185_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6097_ops = {
@@ -3239,6 +3242,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.reset = mv88e6185_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
@@ -3253,6 +3257,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
@@ -3267,6 +3272,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.reset = mv88e6185_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
@@ -3281,6 +3287,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
@@ -3295,6 +3302,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
@@ -3310,6 +3318,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -3327,6 +3336,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -3342,6 +3352,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -3359,6 +3370,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3373,6 +3385,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.reset = mv88e6185_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6190_ops = {
@@ -3389,6 +3402,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6190x_ops = {
@@ -3405,6 +3419,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6191_ops = {
@@ -3421,6 +3436,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3438,6 +3454,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
@@ -3454,6 +3471,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3470,6 +3488,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6320_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3486,6 +3505,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6320_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
@@ -3501,6 +3521,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
@@ -3516,6 +3537,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3533,6 +3555,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
@@ -3549,6 +3572,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3565,6 +3589,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6391_ops = {
@@ -3581,6 +3606,7 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index 5fcf23d..27f37a7 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -33,6 +33,41 @@ int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask)
 	return mv88e6xxx_wait(chip, chip->info->global1_addr, reg, mask);
 }
 
+/* Offset 0x04: Switch Global Control Register */
+
+int mv88e6185_g1_reset(struct mv88e6xxx_chip *chip)
+{
+	u16 val;
+	int err;
+
+	/* Set the SWReset bit 15 along with the PPUEn bit 14, to also restart
+	 * the PPU, including re-doing PHY detection and initialization
+	 */
+	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &val);
+	if (err)
+		return err;
+
+	val |= GLOBAL_CONTROL_SW_RESET;
+	val |= GLOBAL_CONTROL_PPU_ENABLE;
+
+	return mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, val);
+}
+
+int mv88e6352_g1_reset(struct mv88e6xxx_chip *chip)
+{
+	u16 val;
+	int err;
+
+	/* Set the SWReset bit 15 */
+	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &val);
+	if (err)
+		return err;
+
+	val |= GLOBAL_CONTROL_SW_RESET;
+
+	return mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, val);
+}
+
 /* Offset 0x1c: Global Control 2 */
 
 int mv88e6390_g1_stats_set_histogram(struct mv88e6xxx_chip *chip)
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index df3794c..868a281 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -19,6 +19,10 @@
 int mv88e6xxx_g1_read(struct mv88e6xxx_chip *chip, int reg, u16 *val);
 int mv88e6xxx_g1_write(struct mv88e6xxx_chip *chip, int reg, u16 val);
 int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask);
+
+int mv88e6185_g1_reset(struct mv88e6xxx_chip *chip);
+int mv88e6352_g1_reset(struct mv88e6xxx_chip *chip);
+
 int mv88e6xxx_g1_stats_wait(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
 int mv88e6320_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index ab52c37..9e51405 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -765,6 +765,9 @@ struct mv88e6xxx_ops {
 	int (*phy_write)(struct mv88e6xxx_chip *chip, int addr, int reg,
 			 u16 val);
 
+	/* Switch Software Reset */
+	int (*reset)(struct mv88e6xxx_chip *chip);
+
 	/* RGMII Receive/Transmit Timing Control
 	 * Add delay on PHY_INTERFACE_MODE_RGMII_*ID, no delay otherwise.
 	 */
-- 
2.10.2
