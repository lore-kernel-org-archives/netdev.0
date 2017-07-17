From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 09/12] net: dsa: mv88e6xxx: add POT operation
Date: Mon, 17 Jul 2017 13:03:43 -0400
Message-ID: <20170717170346.19555-10-vivien.didelot@savoirfairelinux.com>
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

Add a pot_clear operation to clear the Priority Override Table and wrap
its call into a mv88e6xxx_pot_setup helper.

This allows us to get rid of the MV88E6XXX_FLAG_G2_POT flag.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c    | 34 ++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/chip.h    | 12 +++---------
 drivers/net/dsa/mv88e6xxx/global2.c |  9 +--------
 drivers/net/dsa/mv88e6xxx/global2.h |  7 +++++++
 4 files changed, 45 insertions(+), 17 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 874e2a154834..6351230f82ad 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -926,6 +926,14 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 		dev_err(ds->dev, "p%d: failed to update state\n", port);
 }
 
+static int mv88e6xxx_pot_setup(struct mv88e6xxx_chip *chip)
+{
+	if (chip->info->ops->pot_clear)
+		return chip->info->ops->pot_clear(chip);
+
+	return 0;
+}
+
 static int mv88e6xxx_rsvd2cpu_setup(struct mv88e6xxx_chip *chip)
 {
 	if (chip->info->ops->mgmt_rsvd2cpu)
@@ -2150,6 +2158,10 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 	if (err)
 		goto unlock;
 
+	err = mv88e6xxx_pot_setup(chip);
+	if (err)
+		goto unlock;
+
 	err = mv88e6xxx_rsvd2cpu_setup(chip);
 	if (err)
 		goto unlock;
@@ -2387,6 +2399,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.ppu_enable = mv88e6185_g1_ppu_enable,
 	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
@@ -2443,6 +2456,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2469,6 +2483,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2534,6 +2549,7 @@ static const struct mv88e6xxx_ops mv88e6141_ops = {
 	.set_egress_port = mv88e6390_g1_set_egress_port,
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu =  mv88e6390_g1_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2565,6 +2581,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2589,6 +2606,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2621,6 +2639,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2655,6 +2674,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2688,6 +2708,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2722,6 +2743,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2783,6 +2805,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.set_egress_port = mv88e6390_g1_set_egress_port,
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
@@ -2817,6 +2840,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.set_egress_port = mv88e6390_g1_set_egress_port,
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
@@ -2851,6 +2875,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.set_egress_port = mv88e6390_g1_set_egress_port,
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
@@ -2886,6 +2911,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -2921,6 +2947,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.set_egress_port = mv88e6390_g1_set_egress_port,
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
@@ -2954,6 +2981,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6185_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6185_g1_vtu_loadpurge,
@@ -3019,6 +3047,7 @@ static const struct mv88e6xxx_ops mv88e6341_ops = {
 	.set_egress_port = mv88e6390_g1_set_egress_port,
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu =  mv88e6390_g1_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -3051,6 +3080,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -3083,6 +3113,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -3117,6 +3148,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.set_egress_port = mv88e6095_g1_set_egress_port,
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6352_g2_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
@@ -3154,6 +3186,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.set_egress_port = mv88e6390_g1_set_egress_port,
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
@@ -3190,6 +3223,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.set_egress_port = mv88e6390_g1_set_egress_port,
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
+	.pot_clear = mv88e6xxx_g2_pot_clear,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index 52b52423df1f..822286250aff 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -113,7 +113,6 @@ enum mv88e6xxx_cap {
 	 * The device contains a second set of global 16-bit registers.
 	 */
 	MV88E6XXX_CAP_GLOBAL2,
-	MV88E6XXX_CAP_G2_POT,		/* (0x0f) Priority Override Table */
 };
 
 /* Bitmask of capabilities */
@@ -123,7 +122,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_SMI_DATA		BIT_ULL(MV88E6XXX_CAP_SMI_DATA)
 
 #define MV88E6XXX_FLAG_GLOBAL2		BIT_ULL(MV88E6XXX_CAP_GLOBAL2)
-#define MV88E6XXX_FLAG_G2_POT		BIT_ULL(MV88E6XXX_CAP_G2_POT)
 
 /* Multi-chip Addressing Mode */
 #define MV88E6XXX_FLAGS_MULTI_CHIP	\
@@ -136,12 +134,10 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6185	\
@@ -151,30 +147,25 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAGS_FAMILY_6320	\
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6341	\
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6390	\
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 struct mv88e6xxx_ops;
@@ -313,6 +304,9 @@ struct mv88e6xxx_ops {
 			 struct mii_bus *bus,
 			 int addr, int reg, u16 val);
 
+	/* Priority Override Table operations */
+	int (*pot_clear)(struct mv88e6xxx_chip *chip);
+
 	/* PHY Polling Unit (PPU) operations */
 	int (*ppu_enable)(struct mv88e6xxx_chip *chip);
 	int (*ppu_disable)(struct mv88e6xxx_chip *chip);
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 6b6ebbd6d322..aaf98e818d0d 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -311,7 +311,7 @@ static int mv88e6xxx_g2_pot_write(struct mv88e6xxx_chip *chip, int pointer,
 	return mv88e6xxx_g2_update(chip, MV88E6XXX_G2_PRIO_OVERRIDE, val);
 }
 
-static int mv88e6xxx_g2_clear_pot(struct mv88e6xxx_chip *chip)
+int mv88e6xxx_g2_pot_clear(struct mv88e6xxx_chip *chip)
 {
 	int i, err;
 
@@ -1131,12 +1131,5 @@ int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_POT)) {
-		/* Clear the priority override table. */
-		err = mv88e6xxx_g2_clear_pot(chip);
-		if (err)
-			return err;
-	}
-
 	return 0;
 }
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 487a81146c31..d89d7b810a45 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -264,6 +264,8 @@ void mv88e6xxx_g2_irq_free(struct mv88e6xxx_chip *chip);
 int mv88e6185_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip);
 int mv88e6352_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip);
 
+int mv88e6xxx_g2_pot_clear(struct mv88e6xxx_chip *chip);
+
 extern const struct mv88e6xxx_irq_ops mv88e6097_watchdog_ops;
 extern const struct mv88e6xxx_irq_ops mv88e6390_watchdog_ops;
 
@@ -374,6 +376,11 @@ static inline int mv88e6352_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip)
 	return -EOPNOTSUPP;
 }
 
+static inline int mv88e6xxx_g2_pot_clear(struct mv88e6xxx_chip *chip)
+{
+	return -EOPNOTSUPP;
+}
+
 static const struct mv88e6xxx_irq_ops mv88e6097_watchdog_ops = {};
 static const struct mv88e6xxx_irq_ops mv88e6390_watchdog_ops = {};
 
-- 
2.13.2
