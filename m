From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v3 net-next v3 3/4] net: dsa: mv88e6xxx: add a soft reset operation
Date: Mon,  5 Dec 2016 17:30:27 -0500
Message-ID: <20161205223028.20308-4-vivien.didelot@savoirfairelinux.com>
References: <20161205223028.20308-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Stefan Eichenberger <eichest@gmail.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161205223028.20308-1-vivien.didelot@savoirfairelinux.com>
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
 drivers/net/dsa/mv88e6xxx/chip.c      |  72 ++++++++++----------
 drivers/net/dsa/mv88e6xxx/global1.c   | 121 ++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global1.h   |   4 ++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  15 +++--
 4 files changed, 172 insertions(+), 40 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 27dfb5d..5aae5d7 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -545,7 +545,8 @@ static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
 			return err;
 
 		usleep_range(1000, 2000);
-		if ((val & GLOBAL_STATUS_PPU_MASK) != GLOBAL_STATUS_PPU_POLLING)
+		val &= GLOBAL_STATUS_PPU_STATE_MASK;
+		if (val != GLOBAL_STATUS_PPU_STATE_POLLING)
 			return 0;
 	}
 
@@ -572,7 +573,8 @@ static int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip)
 			return err;
 
 		usleep_range(1000, 2000);
-		if ((val & GLOBAL_STATUS_PPU_MASK) == GLOBAL_STATUS_PPU_POLLING)
+		val &= GLOBAL_STATUS_PPU_STATE_MASK;
+		if (val == GLOBAL_STATUS_PPU_STATE_POLLING)
 			return 0;
 	}
 
@@ -2356,6 +2358,14 @@ static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
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
@@ -2391,10 +2401,6 @@ static int mv88e6xxx_disable_ports(struct mv88e6xxx_chip *chip)
 
 static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 {
-	bool ppu_active = mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU_ACTIVE);
-	u16 is_reset = (ppu_active ? 0x8800 : 0xc800);
-	unsigned long timeout;
-	u16 reg;
 	int err;
 
 	err = mv88e6xxx_disable_ports(chip);
@@ -2403,34 +2409,7 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 
 	mv88e6xxx_hardware_reset(chip);
 
-	/* Reset the switch. Keep the PPU active if requested. The PPU
-	 * needs to be active to support indirect phy register access
-	 * through global registers 0x18 and 0x19.
-	 */
-	if (ppu_active)
-		err = mv88e6xxx_g1_write(chip, 0x04, 0xc000);
-	else
-		err = mv88e6xxx_g1_write(chip, 0x04, 0xc400);
-	if (err)
-		return err;
-
-	/* Wait up to one second for reset to complete. */
-	timeout = jiffies + 1 * HZ;
-	while (time_before(jiffies, timeout)) {
-		err = mv88e6xxx_g1_read(chip, 0x00, &reg);
-		if (err)
-			return err;
-
-		if ((reg & is_reset) == is_reset)
-			break;
-		usleep_range(1000, 2000);
-	}
-	if (time_after(jiffies, timeout))
-		err = -ETIMEDOUT;
-	else
-		err = 0;
-
-	return err;
+	return mv88e6xxx_software_reset(chip);
 }
 
 static int mv88e6xxx_serdes_power_on(struct mv88e6xxx_chip *chip)
@@ -3244,6 +3223,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6185_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
@@ -3261,6 +3241,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6185_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6097_ops = {
@@ -3285,6 +3266,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
@@ -3304,6 +3286,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
@@ -3328,6 +3311,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6185_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
@@ -3352,6 +3336,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
@@ -3369,6 +3354,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
@@ -3394,6 +3380,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -3421,6 +3408,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -3446,6 +3434,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -3473,6 +3462,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3493,6 +3483,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6185_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6190_ops = {
@@ -3517,6 +3508,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6190x_ops = {
@@ -3541,6 +3533,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6191_ops = {
@@ -3565,6 +3558,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3592,6 +3586,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
@@ -3616,6 +3611,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3642,6 +3638,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3667,6 +3664,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.stats_get_stats = mv88e6320_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
@@ -3692,6 +3690,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
@@ -3717,6 +3716,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3744,6 +3744,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
@@ -3770,6 +3771,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3796,6 +3798,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static const struct mv88e6xxx_ops mv88e6391_ops = {
@@ -3820,6 +3823,7 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
 };
 
 static int mv88e6xxx_verify_madatory_ops(struct mv88e6xxx_chip *chip,
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index 44136ee..c868eb0 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -33,6 +33,127 @@ int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask)
 	return mv88e6xxx_wait(chip, chip->info->global1_addr, reg, mask);
 }
 
+/* Offset 0x00: Switch Global Status Register */
+
+static int mv88e6185_g1_wait_ppu_polling(struct mv88e6xxx_chip *chip)
+{
+	u16 state;
+	int i, err;
+
+	for (i = 0; i < 16; ++i) {
+		err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &state);
+		if (err)
+			return err;
+
+		/* Check the value of the PPUState bits 15:14 */
+		state &= GLOBAL_STATUS_PPU_STATE_MASK;
+		if (state == GLOBAL_STATUS_PPU_STATE_POLLING)
+			return 0;
+
+		usleep_range(1000, 2000);
+	}
+
+	return -ETIMEDOUT;
+}
+
+static int mv88e6352_g1_wait_ppu_polling(struct mv88e6xxx_chip *chip)
+{
+	u16 state;
+	int i, err;
+
+	for (i = 0; i < 16; ++i) {
+		err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &state);
+		if (err)
+			return err;
+
+		/* Check the value of the PPUState (or InitState) bit 15 */
+		if (state & GLOBAL_STATUS_PPU_STATE)
+			return 0;
+
+		usleep_range(1000, 2000);
+	}
+
+	return -ETIMEDOUT;
+}
+
+static int mv88e6xxx_g1_wait_init_ready(struct mv88e6xxx_chip *chip)
+{
+	const unsigned long timeout = jiffies + 1 * HZ;
+	u16 val;
+	int err;
+
+	/* Wait up to 1 second for the switch to be ready. The InitReady bit 11
+	 * is set to a one when all units inside the device (ATU, VTU, etc.)
+	 * have finished their initialization and are ready to accept frames.
+	 */
+	while (time_before(jiffies, timeout)) {
+		err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &val);
+		if (err)
+			return err;
+
+		if (val & GLOBAL_STATUS_INIT_READY)
+			break;
+
+		usleep_range(1000, 2000);
+	}
+
+	if (time_after(jiffies, timeout))
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
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
+	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, val);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g1_wait_init_ready(chip);
+	if (err)
+		return err;
+
+	return mv88e6185_g1_wait_ppu_polling(chip);
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
+	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, val);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g1_wait_init_ready(chip);
+	if (err)
+		return err;
+
+	return mv88e6352_g1_wait_ppu_polling(chip);
+}
+
 /* Offset 0x1a: Monitor Control */
 /* Offset 0x1a: Monitor & MGMT Control on some devices */
 
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index cb61378..9fca215 100644
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
index 13c7cc4..f201d13 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -193,12 +193,12 @@
 
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
+#define GLOBAL_STATUS_INIT_READY	BIT(11)
 #define GLOBAL_STATUS_IRQ_AVB		8
 #define GLOBAL_STATUS_IRQ_DEVICE	7
 #define GLOBAL_STATUS_IRQ_STATS		6
@@ -792,6 +792,9 @@ struct mv88e6xxx_ops {
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
