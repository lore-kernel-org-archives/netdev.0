From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/6] net: dsa: mv88e6xxx: add a PPU polling op
Date: Wed, 30 Nov 2016 17:59:28 -0500
Message-ID: <20161130225930.25510-5-vivien.didelot@savoirfairelinux.com>
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

Marvell chips with controllable PPU have 2 bits to identify the PPU
state. Chips without PPU control have their PPU enable by default and
have only 1 bit to read the PPU state.

The only state we care about is the PPU active and polling state
(meaning PortStatus registers are available for reading).

Add a .ppu_polling op check this state and use it in the PPU
enable/disable routines. It will also be used later in the switch reset
code.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 70 +++++++++++++++++++++++------------
 drivers/net/dsa/mv88e6xxx/global1.c   | 33 +++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global1.h   |  3 ++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 13 ++++---
 4 files changed, 89 insertions(+), 30 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 6bb7571..db4014c 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -525,10 +525,32 @@ int mv88e6xxx_update(struct mv88e6xxx_chip *chip, int addr, int reg, u16 update)
 	return mv88e6xxx_write(chip, addr, reg, val);
 }
 
+static int mv88e6xxx_ppu_wait(struct mv88e6xxx_chip *chip, bool state)
+{
+	bool polling;
+	int i, err;
+
+	if (!chip->info->ops->ppu_polling)
+		return 0;
+
+	for (i = 0; i < 16; i++) {
+		err = chip->info->ops->ppu_polling(chip, &polling);
+		if (err)
+			return err;
+
+		usleep_range(1000, 2000);
+
+		if (polling == state)
+			return 0;
+	}
+
+	return -ETIMEDOUT;
+}
+
 static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
 {
 	u16 val;
-	int i, err;
+	int err;
 
 	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &val);
 	if (err)
@@ -539,23 +561,13 @@ static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
-	for (i = 0; i < 16; i++) {
-		err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &val);
-		if (err)
-			return err;
-
-		usleep_range(1000, 2000);
-		if ((val & GLOBAL_STATUS_PPU_MASK) != GLOBAL_STATUS_PPU_POLLING)
-			return 0;
-	}
-
-	return -ETIMEDOUT;
+	return mv88e6xxx_ppu_wait(chip, false);
 }
 
 static int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip)
 {
 	u16 val;
-	int i, err;
+	int err;
 
 	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &val);
 	if (err)
@@ -566,17 +578,7 @@ static int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
-	for (i = 0; i < 16; i++) {
-		err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &val);
-		if (err)
-			return err;
-
-		usleep_range(1000, 2000);
-		if ((val & GLOBAL_STATUS_PPU_MASK) == GLOBAL_STATUS_PPU_POLLING)
-			return 0;
-	}
-
-	return -ETIMEDOUT;
+	return mv88e6xxx_ppu_wait(chip, true);
 }
 
 static void mv88e6xxx_ppu_reenable_work(struct work_struct *ugly)
@@ -3212,6 +3214,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.ppu_polling = mv88e6185_g1_ppu_polling,
 	.reset = mv88e6185_g1_reset,
 };
 
@@ -3227,6 +3230,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.ppu_polling = mv88e6185_g1_ppu_polling,
 	.reset = mv88e6185_g1_reset,
 };
 
@@ -3242,6 +3246,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.ppu_polling = mv88e6185_g1_ppu_polling,
 	.reset = mv88e6185_g1_reset,
 };
 
@@ -3272,6 +3277,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.ppu_polling = mv88e6185_g1_ppu_polling,
 	.reset = mv88e6185_g1_reset,
 };
 
@@ -3318,6 +3324,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.ppu_polling = mv88e6352_g1_ppu_polling,
 	.reset = mv88e6352_g1_reset,
 };
 
@@ -3336,6 +3343,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.ppu_polling = mv88e6352_g1_ppu_polling,
 	.reset = mv88e6352_g1_reset,
 };
 
@@ -3352,6 +3360,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.ppu_polling = mv88e6352_g1_ppu_polling,
 	.reset = mv88e6352_g1_reset,
 };
 
@@ -3370,6 +3379,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.ppu_polling = mv88e6352_g1_ppu_polling,
 	.reset = mv88e6352_g1_reset,
 };
 
@@ -3385,6 +3395,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.ppu_polling = mv88e6185_g1_ppu_polling,
 	.reset = mv88e6185_g1_reset,
 };
 
@@ -3402,6 +3413,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.ppu_polling = mv88e6352_g1_ppu_polling,
 	.reset = mv88e6352_g1_reset,
 };
 
@@ -3419,6 +3431,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.ppu_polling = mv88e6352_g1_ppu_polling,
 	.reset = mv88e6352_g1_reset,
 };
 
@@ -3436,6 +3449,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.ppu_polling = mv88e6352_g1_ppu_polling,
 	.reset = mv88e6352_g1_reset,
 };
 
@@ -3454,6 +3468,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.ppu_polling = mv88e6352_g1_ppu_polling,
 	.reset = mv88e6352_g1_reset,
 };
 
@@ -3471,6 +3486,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.ppu_polling = mv88e6352_g1_ppu_polling,
 	.reset = mv88e6352_g1_reset,
 };
 
@@ -3521,6 +3537,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.ppu_polling = mv88e6352_g1_ppu_polling,
 	.reset = mv88e6352_g1_reset,
 };
 
@@ -3537,6 +3554,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.ppu_polling = mv88e6352_g1_ppu_polling,
 	.reset = mv88e6352_g1_reset,
 };
 
@@ -3555,6 +3573,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.ppu_polling = mv88e6352_g1_ppu_polling,
 	.reset = mv88e6352_g1_reset,
 };
 
@@ -3572,6 +3591,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.ppu_polling = mv88e6352_g1_ppu_polling,
 	.reset = mv88e6352_g1_reset,
 };
 
@@ -3589,6 +3609,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.ppu_polling = mv88e6352_g1_ppu_polling,
 	.reset = mv88e6352_g1_reset,
 };
 
@@ -3606,6 +3627,7 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.ppu_polling = mv88e6352_g1_ppu_polling,
 	.reset = mv88e6352_g1_reset,
 };
 
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index 27f37a7..371d96a 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -33,6 +33,39 @@ int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask)
 	return mv88e6xxx_wait(chip, chip->info->global1_addr, reg, mask);
 }
 
+/* Offset 0x00: Switch Global Status Register */
+
+int mv88e6185_g1_ppu_polling(struct mv88e6xxx_chip *chip, bool *polling)
+{
+	u16 state;
+	int err;
+
+	/* Check the value of the PPUState bits 15:14 */
+	err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &state);
+	if (err)
+		return err;
+
+	state &= GLOBAL_STATUS_PPU_STATE_MASK;
+	*polling = state == GLOBAL_STATUS_PPU_STATE_POLLING;
+
+	return 0;
+}
+
+int mv88e6352_g1_ppu_polling(struct mv88e6xxx_chip *chip, bool *polling)
+{
+	u16 state;
+	int err;
+
+	/* Check the value of the PPUState (or InitState) bit 15 */
+	err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &state);
+	if (err)
+		return err;
+
+	*polling = !!(state & GLOBAL_STATUS_PPU_STATE);
+
+	return 0;
+}
+
 /* Offset 0x04: Switch Global Control Register */
 
 int mv88e6185_g1_reset(struct mv88e6xxx_chip *chip)
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 868a281..cdccf473 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -20,6 +20,9 @@ int mv88e6xxx_g1_read(struct mv88e6xxx_chip *chip, int reg, u16 *val);
 int mv88e6xxx_g1_write(struct mv88e6xxx_chip *chip, int reg, u16 val);
 int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask);
 
+int mv88e6185_g1_ppu_polling(struct mv88e6xxx_chip *chip, bool *polling);
+int mv88e6352_g1_ppu_polling(struct mv88e6xxx_chip *chip, bool *polling);
+
 int mv88e6185_g1_reset(struct mv88e6xxx_chip *chip);
 int mv88e6352_g1_reset(struct mv88e6xxx_chip *chip);
 
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 9e51405..9ae228c 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -175,12 +175,11 @@
 
 #define GLOBAL_STATUS		0x00
 #define GLOBAL_STATUS_PPU_STATE BIT(15) /* 6351 and 6171 */
-/* Two bits for 6165, 6185 etc */
-#define GLOBAL_STATUS_PPU_MASK		(0x3 << 14)
-#define GLOBAL_STATUS_PPU_DISABLED_RST	(0x0 << 14)
-#define GLOBAL_STATUS_PPU_INITIALIZING	(0x1 << 14)
-#define GLOBAL_STATUS_PPU_DISABLED	(0x2 << 14)
-#define GLOBAL_STATUS_PPU_POLLING	(0x3 << 14)
+#define GLOBAL_STATUS_PPU_STATE_MASK		(0x3 << 14) /* 6165 6185 */
+#define GLOBAL_STATUS_PPU_STATE_DISABLED_RST	(0x0 << 14)
+#define GLOBAL_STATUS_PPU_STATE_INITIALIZING	(0x1 << 14)
+#define GLOBAL_STATUS_PPU_STATE_DISABLED	(0x2 << 14)
+#define GLOBAL_STATUS_PPU_STATE_POLLING		(0x3 << 14)
 #define GLOBAL_STATUS_IRQ_AVB		8
 #define GLOBAL_STATUS_IRQ_DEVICE	7
 #define GLOBAL_STATUS_IRQ_STATS		6
@@ -765,6 +764,8 @@ struct mv88e6xxx_ops {
 	int (*phy_write)(struct mv88e6xxx_chip *chip, int addr, int reg,
 			 u16 val);
 
+	/* PHY Polling Unit (PPU) operations */
+	int (*ppu_polling)(struct mv88e6xxx_chip *chip, bool *polling);
 	/* Switch Software Reset */
 	int (*reset)(struct mv88e6xxx_chip *chip);
 
-- 
2.10.2
