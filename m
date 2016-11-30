From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/6] net: dsa: mv88e6xxx: add PPU enable/disable ops
Date: Wed, 30 Nov 2016 17:59:30 -0500
Message-ID: <20161130225930.25510-7-vivien.didelot@savoirfairelinux.com>
References: <20161130225930.25510-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:47554 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755322AbcK3W74 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 17:59:56 -0500
In-Reply-To: <20161130225930.25510-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some Marvell chips can enable/disable the PPU on demand. This is needed
to access the PHY registers when there is no indirection mechanism.

Add two new ppu_enable and ppu_disable ops to describe this and finally
get rid of the MV88E6XXX_FLAG_PPU* flags.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 49 ++++++++++++++++-------------------
 drivers/net/dsa/mv88e6xxx/global1.c   | 28 ++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global1.h   |  2 ++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 18 +++----------
 4 files changed, 56 insertions(+), 41 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index f5d5370..78e3aeb 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -549,15 +549,12 @@ static int mv88e6xxx_ppu_wait(struct mv88e6xxx_chip *chip, bool state)
 
 static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
 {
-	u16 val;
 	int err;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &val);
-	if (err)
-		return err;
+	if (!chip->info->ops->ppu_disable)
+		return 0;
 
-	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL,
-				 val & ~GLOBAL_CONTROL_PPU_ENABLE);
+	err = chip->info->ops->ppu_disable(chip);
 	if (err)
 		return err;
 
@@ -566,15 +563,12 @@ static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
 
 static int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip)
 {
-	u16 val;
 	int err;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &val);
-	if (err)
-		return err;
+	if (!chip->info->ops->ppu_enable)
+		return 0;
 
-	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL,
-				 val | GLOBAL_CONTROL_PPU_ENABLE);
+	err = chip->info->ops->ppu_enable(chip);
 	if (err)
 		return err;
 
@@ -2775,18 +2769,11 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	/* Enable the PHY Polling Unit if present, don't discard any packets,
 	 * and mask all interrupt sources.
 	 */
-	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &reg);
-	if (err < 0)
-		return err;
-
-	reg &= ~GLOBAL_CONTROL_PPU_ENABLE;
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU) ||
-	    mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU_ACTIVE))
-		reg |= GLOBAL_CONTROL_PPU_ENABLE;
-
-	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, reg);
-	if (err)
-		return err;
+	if (chip->info->ops->ppu_enable) {
+		err = chip->info->ops->ppu_enable(chip);
+		if (err)
+			return err;
+	}
 
 	/* Configure the upstream port, and configure it as the port to which
 	 * ingress and egress and ARP monitor frames are to be sent.
@@ -3225,6 +3212,8 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.ppu_polling = mv88e6185_g1_ppu_polling,
+	.ppu_enable = mv88e6xxx_g1_ppu_enable,
+	.ppu_disable = mv88e6xxx_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
 };
 
@@ -3241,6 +3230,8 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.ppu_polling = mv88e6185_g1_ppu_polling,
+	.ppu_enable = mv88e6xxx_g1_ppu_enable,
+	.ppu_disable = mv88e6xxx_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
 };
 
@@ -3257,6 +3248,8 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.ppu_polling = mv88e6185_g1_ppu_polling,
+	.ppu_enable = mv88e6xxx_g1_ppu_enable,
+	.ppu_disable = mv88e6xxx_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
 };
 
@@ -3288,6 +3281,8 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.ppu_polling = mv88e6185_g1_ppu_polling,
+	.ppu_enable = mv88e6xxx_g1_ppu_enable,
+	.ppu_disable = mv88e6xxx_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
 };
 
@@ -3406,6 +3401,8 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.ppu_polling = mv88e6185_g1_ppu_polling,
+	.ppu_enable = mv88e6xxx_g1_ppu_enable,
+	.ppu_disable = mv88e6xxx_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
 };
 
@@ -4037,13 +4034,13 @@ static struct mv88e6xxx_chip *mv88e6xxx_alloc_chip(struct device *dev)
 
 static void mv88e6xxx_phy_init(struct mv88e6xxx_chip *chip)
 {
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU))
+	if (chip->info->ops->ppu_enable && chip->info->ops->ppu_disable)
 		mv88e6xxx_ppu_state_init(chip);
 }
 
 static void mv88e6xxx_phy_destroy(struct mv88e6xxx_chip *chip)
 {
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU))
+	if (chip->info->ops->ppu_enable && chip->info->ops->ppu_disable)
 		mv88e6xxx_ppu_state_destroy(chip);
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index 4d69cec..355231a 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -116,6 +116,34 @@ int mv88e6352_g1_reset(struct mv88e6xxx_chip *chip)
 	return mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, val);
 }
 
+int mv88e6xxx_g1_ppu_enable(struct mv88e6xxx_chip *chip)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &val);
+	if (err)
+		return err;
+
+	val |= GLOBAL_CONTROL_PPU_ENABLE;
+
+	return mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, val);
+}
+
+int mv88e6xxx_g1_ppu_disable(struct mv88e6xxx_chip *chip)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &val);
+	if (err)
+		return err;
+
+	val &= ~GLOBAL_CONTROL_PPU_ENABLE;
+
+	return mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, val);
+}
+
 /* Offset 0x1c: Global Control 2 */
 
 int mv88e6390_g1_stats_set_histogram(struct mv88e6xxx_chip *chip)
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 6f0fb7f..736e4da 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -26,6 +26,8 @@ int mv88e6xxx_g1_init_ready(struct mv88e6xxx_chip *chip, bool *ready);
 
 int mv88e6185_g1_reset(struct mv88e6xxx_chip *chip);
 int mv88e6352_g1_reset(struct mv88e6xxx_chip *chip);
+int mv88e6xxx_g1_ppu_enable(struct mv88e6xxx_chip *chip);
+int mv88e6xxx_g1_ppu_disable(struct mv88e6xxx_chip *chip);
 
 int mv88e6xxx_g1_stats_wait(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index cd0f414..116766c 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -460,12 +460,6 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_G2_PVT_DATA,	/* (0x0c) Cross Chip Port VLAN Data */
 	MV88E6XXX_CAP_G2_POT,		/* (0x0f) Priority Override Table */
 
-	/* PHY Polling Unit.
-	 * See GLOBAL_CONTROL_PPU_ENABLE and GLOBAL_STATUS_PPU_POLLING.
-	 */
-	MV88E6XXX_CAP_PPU,
-	MV88E6XXX_CAP_PPU_ACTIVE,
-
 	/* Per VLAN Spanning Tree Unit (STU).
 	 * The Port State database, if present, is accessed through VTU
 	 * operations and dedicated SID registers. See GLOBAL_VTU_SID.
@@ -508,8 +502,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_G2_PVT_DATA	BIT_ULL(MV88E6XXX_CAP_G2_PVT_DATA)
 #define MV88E6XXX_FLAG_G2_POT		BIT_ULL(MV88E6XXX_CAP_G2_POT)
 
-#define MV88E6XXX_FLAG_PPU		BIT_ULL(MV88E6XXX_CAP_PPU)
-#define MV88E6XXX_FLAG_PPU_ACTIVE	BIT_ULL(MV88E6XXX_CAP_PPU_ACTIVE)
 #define MV88E6XXX_FLAG_STU		BIT_ULL(MV88E6XXX_CAP_STU)
 #define MV88E6XXX_FLAG_TEMP		BIT_ULL(MV88E6XXX_CAP_TEMP)
 #define MV88E6XXX_FLAG_TEMP_LIMIT	BIT_ULL(MV88E6XXX_CAP_TEMP_LIMIT)
@@ -538,7 +530,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
-	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
@@ -549,7 +540,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
@@ -576,7 +566,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6320	\
@@ -586,7 +575,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
 	 MV88E6XXX_FLAG_VTU |		\
@@ -603,7 +591,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_VTU |		\
@@ -621,7 +608,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
@@ -636,7 +622,6 @@ struct mv88e6xxx_ops;
 #define MV88E6XXX_FLAGS_FAMILY_6390	\
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
@@ -767,6 +752,9 @@ struct mv88e6xxx_ops {
 
 	/* PHY Polling Unit (PPU) operations */
 	int (*ppu_polling)(struct mv88e6xxx_chip *chip, bool *polling);
+	int (*ppu_enable)(struct mv88e6xxx_chip *chip);
+	int (*ppu_disable)(struct mv88e6xxx_chip *chip);
+
 	/* Switch Software Reset */
 	int (*reset)(struct mv88e6xxx_chip *chip);
 
-- 
2.10.2
