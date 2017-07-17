From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 07/12] net: dsa: mv88e6xxx: distinguish Global 2 Rsvd2CPU
Date: Mon, 17 Jul 2017 13:03:41 -0400
Message-ID: <20170717170346.19555-8-vivien.didelot@savoirfairelinux.com>
References: <20170717170346.19555-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170717170346.19555-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 88E6185 family only has one 16-bit register to mark the 16 802.1D
reserved multicast addresses in the range of 01:80:C2:00:00:0x as MGMT.

The 88E6352 family also has one 16-bit register to mark the 16 GARP
reserved multicast addresses in the range of 01:80:C2:00:00:2x as MGMT.

Split the existing mv88e6095 prefixed mgmt_rsvd2cpu operation into two
distinct mv88e6185 and mv88e6352 prefixed operations, and wrap its call
into a mv88e6xxx_rsvd2cpu_setup helper.

This allows us to also get rid of the MV88E6XXX_CAP_G2_MGMT_EN_* flags.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c    | 55 ++++++++++++++++---------------
 drivers/net/dsa/mv88e6xxx/chip.h    | 17 ----------
 drivers/net/dsa/mv88e6xxx/global2.c | 65 ++++++++++++++++++++++++++++---------
 drivers/net/dsa/mv88e6xxx/global2.h | 11 +++++--
 4 files changed, 86 insertions(+), 62 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 1be0bc5e7c3f..874e2a154834 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -926,6 +926,14 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 		dev_err(ds->dev, "p%d: failed to update state\n", port);
 }
 
+static int mv88e6xxx_rsvd2cpu_setup(struct mv88e6xxx_chip *chip)
+{
+	if (chip->info->ops->mgmt_rsvd2cpu)
+		return chip->info->ops->mgmt_rsvd2cpu(chip);
+
+	return 0;
+}
+
 static int mv88e6xxx_atu_setup(struct mv88e6xxx_chip *chip)
 {
 	int err;
@@ -2142,16 +2150,9 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 	if (err)
 		goto unlock;
 
-	/* Some generations have the configuration of sending reserved
-	 * management frames to the CPU in global2, others in
-	 * global1. Hence it does not fit the two setup functions
-	 * above.
-	 */
-	if (chip->info->ops->mgmt_rsvd2cpu) {
-		err = chip->info->ops->mgmt_rsvd2cpu(chip);
-		if (err)
-			goto unlock;
-	}
+	err = mv88e6xxx_rsvd2cpu_setup(chip);
+	if (err)
+		goto unlock;
 
 unlock:
 	mutex_unlock(&chip->reg_lock);
@@ -2385,7 +2386,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
-	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
 	.ppu_enable = mv88e6185_g1_ppu_enable,
 	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
@@ -2408,7 +2409,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
-	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.mgmt_rsvd2cpu = mv88e6185_g2_mgmt_rsvd2cpu,
 	.ppu_enable = mv88e6185_g1_ppu_enable,
 	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
@@ -2441,7 +2442,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
-	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2467,7 +2468,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
-	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2496,7 +2497,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
-	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.mgmt_rsvd2cpu = mv88e6185_g2_mgmt_rsvd2cpu,
 	.ppu_enable = mv88e6185_g1_ppu_enable,
 	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
@@ -2563,7 +2564,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
-	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2587,7 +2588,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
-	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2619,7 +2620,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
-	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2653,7 +2654,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
-	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2686,7 +2687,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
-	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2720,7 +2721,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
-	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2746,7 +2747,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
-	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.mgmt_rsvd2cpu = mv88e6185_g2_mgmt_rsvd2cpu,
 	.ppu_enable = mv88e6185_g1_ppu_enable,
 	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
@@ -2884,7 +2885,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
-	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2952,7 +2953,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.stats_get_stats = mv88e6320_stats_get_stats,
 	.set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.set_egress_port = mv88e6095_g1_set_egress_port,
-	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6185_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6185_g1_vtu_loadpurge,
@@ -3049,7 +3050,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
-	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -3081,7 +3082,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
-	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -3115,7 +3116,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
-	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index 2e760fd0ad24..48233971759e 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -113,8 +113,6 @@ enum mv88e6xxx_cap {
 	 * The device contains a second set of global 16-bit registers.
 	 */
 	MV88E6XXX_CAP_GLOBAL2,
-	MV88E6XXX_CAP_G2_MGMT_EN_2X,	/* (0x02) MGMT Enable Register 2x */
-	MV88E6XXX_CAP_G2_MGMT_EN_0X,	/* (0x03) MGMT Enable Register 0x */
 	MV88E6XXX_CAP_G2_POT,		/* (0x0f) Priority Override Table */
 };
 
@@ -125,8 +123,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_SMI_DATA		BIT_ULL(MV88E6XXX_CAP_SMI_DATA)
 
 #define MV88E6XXX_FLAG_GLOBAL2		BIT_ULL(MV88E6XXX_CAP_GLOBAL2)
-#define MV88E6XXX_FLAG_G2_MGMT_EN_2X	BIT_ULL(MV88E6XXX_CAP_G2_MGMT_EN_2X)
-#define MV88E6XXX_FLAG_G2_MGMT_EN_0X	BIT_ULL(MV88E6XXX_CAP_G2_MGMT_EN_0X)
 #define MV88E6XXX_FLAG_G2_POT		BIT_ULL(MV88E6XXX_CAP_G2_POT)
 
 /* Multi-chip Addressing Mode */
@@ -136,33 +132,25 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
-	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
-	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6185	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6320	\
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
-	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
@@ -174,16 +162,12 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
-	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
-	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
@@ -418,7 +402,6 @@ struct mv88e6xxx_ops {
 	int (*set_egress_port)(struct mv88e6xxx_chip *chip, int port);
 	const struct mv88e6xxx_irq_ops *watchdog_ops;
 
-	/* Can be either in g1 or g2, so don't use a prefix */
 	int (*mgmt_rsvd2cpu)(struct mv88e6xxx_chip *chip);
 
 	/* Power on/off a SERDES interface */
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index be704c98dcbb..6b6ebbd6d322 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -56,29 +56,65 @@ static int mv88e6xxx_g2_int_mask(struct mv88e6xxx_chip *chip, u16 mask)
 }
 
 /* Offset 0x02: Management Enable 2x */
+
+static int mv88e6xxx_g2_mgmt_enable_2x(struct mv88e6xxx_chip *chip, u16 en2x)
+{
+	return mv88e6xxx_g2_write(chip, MV88E6XXX_G2_MGMT_EN_2X, en2x);
+}
+
 /* Offset 0x03: Management Enable 0x */
 
-int mv88e6095_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip)
+static int mv88e6xxx_g2_mgmt_enable_0x(struct mv88e6xxx_chip *chip, u16 en0x)
 {
+	return mv88e6xxx_g2_write(chip, MV88E6XXX_G2_MGMT_EN_0X, en0x);
+}
+
+/* Offset 0x05: Switch Management Register */
+
+static int mv88e6xxx_g2_switch_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip,
+					     bool enable)
+{
+	u16 val;
 	int err;
 
-	/* Consider the frames with reserved multicast destination
-	 * addresses matching 01:80:c2:00:00:2x as MGMT.
-	 */
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_2X)) {
-		err = mv88e6xxx_g2_write(chip, MV88E6XXX_G2_MGMT_EN_2X, 0xffff);
-		if (err)
-			return err;
-	}
+	err = mv88e6xxx_g2_read(chip, MV88E6XXX_G2_SWITCH_MGMT, &val);
+	if (err)
+		return err;
+
+	if (enable)
+		val |= MV88E6XXX_G2_SWITCH_MGMT_RSVD2CPU;
+	else
+		val &= ~MV88E6XXX_G2_SWITCH_MGMT_RSVD2CPU;
+
+	return mv88e6xxx_g2_write(chip, MV88E6XXX_G2_SWITCH_MGMT, val);
+}
+
+int mv88e6185_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip)
+{
+	int err;
 
 	/* Consider the frames with reserved multicast destination
 	 * addresses matching 01:80:c2:00:00:0x as MGMT.
 	 */
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_0X))
-		return mv88e6xxx_g2_write(chip, MV88E6XXX_G2_MGMT_EN_0X,
-					  0xffff);
+	err = mv88e6xxx_g2_mgmt_enable_0x(chip, 0xffff);
+	if (err)
+		return err;
 
-	return 0;
+	return mv88e6xxx_g2_switch_mgmt_rsvd2cpu(chip, true);
+}
+
+int mv88e6352_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip)
+{
+	int err;
+
+	/* Consider the frames with reserved multicast destination
+	 * addresses matching 01:80:c2:00:00:2x as MGMT.
+	 */
+	err = mv88e6xxx_g2_mgmt_enable_2x(chip, 0xffff);
+	if (err)
+		return err;
+
+	return mv88e6185_g2_mgmt_rsvd2cpu(chip);
 }
 
 /* Offset 0x06: Device Mapping Table register */
@@ -1081,9 +1117,6 @@ int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 	 * port at the highest priority.
 	 */
 	reg = MV88E6XXX_G2_SWITCH_MGMT_FORCE_FLOW_CTL_PRI | (0x7 << 4);
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_0X) ||
-	    mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_2X))
-		reg |= MV88E6XXX_G2_SWITCH_MGMT_RSVD2CPU | 0x7;
 	err = mv88e6xxx_g2_write(chip, MV88E6XXX_G2_SWITCH_MGMT, reg);
 	if (err)
 		return err;
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 7b21b2556af2..487a81146c31 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -260,7 +260,9 @@ int mv88e6xxx_g2_misc_4_bit_port(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g2_irq_setup(struct mv88e6xxx_chip *chip);
 void mv88e6xxx_g2_irq_free(struct mv88e6xxx_chip *chip);
-int mv88e6095_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip);
+
+int mv88e6185_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip);
+int mv88e6352_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip);
 
 extern const struct mv88e6xxx_irq_ops mv88e6097_watchdog_ops;
 extern const struct mv88e6xxx_irq_ops mv88e6390_watchdog_ops;
@@ -362,7 +364,12 @@ static inline void mv88e6xxx_g2_irq_free(struct mv88e6xxx_chip *chip)
 {
 }
 
-static inline int mv88e6095_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip)
+static inline int mv88e6185_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int mv88e6352_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip)
 {
 	return -EOPNOTSUPP;
 }
-- 
2.13.2
