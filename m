From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v3 net-next v3 4/4] net: dsa: mv88e6xxx: add PPU operations
Date: Mon,  5 Dec 2016 17:30:28 -0500
Message-ID: <20161205223028.20308-5-vivien.didelot@savoirfairelinux.com>
References: <20161205223028.20308-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Stefan Eichenberger <eichest@gmail.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40578 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753113AbcLEWbh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 17:31:37 -0500
In-Reply-To: <20161205223028.20308-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some Marvell chips can enable/disable the PPU on demand. This is needed
to access the PHY registers when there is no indirection mechanism.

Add two new ppu_enable and ppu_disable ops to describe this and finally
get rid of the MV88E6XXX_FLAG_PPU* flags.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 76 ++++++++---------------------------
 drivers/net/dsa/mv88e6xxx/global1.c   | 57 ++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global1.h   |  3 ++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 19 ++-------
 4 files changed, 81 insertions(+), 74 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 5aae5d7..731d262 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -527,58 +527,18 @@ int mv88e6xxx_update(struct mv88e6xxx_chip *chip, int addr, int reg, u16 update)
 
 static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
 {
-	u16 val;
-	int i, err;
+	if (!chip->info->ops->ppu_disable)
+		return 0;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &val);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL,
-				 val & ~GLOBAL_CONTROL_PPU_ENABLE);
-	if (err)
-		return err;
-
-	for (i = 0; i < 16; i++) {
-		err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &val);
-		if (err)
-			return err;
-
-		usleep_range(1000, 2000);
-		val &= GLOBAL_STATUS_PPU_STATE_MASK;
-		if (val != GLOBAL_STATUS_PPU_STATE_POLLING)
-			return 0;
-	}
-
-	return -ETIMEDOUT;
+	return chip->info->ops->ppu_disable(chip);
 }
 
 static int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip)
 {
-	u16 val;
-	int i, err;
+	if (!chip->info->ops->ppu_enable)
+		return 0;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &val);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL,
-				 val | GLOBAL_CONTROL_PPU_ENABLE);
-	if (err)
-		return err;
-
-	for (i = 0; i < 16; i++) {
-		err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &val);
-		if (err)
-			return err;
-
-		usleep_range(1000, 2000);
-		val &= GLOBAL_STATUS_PPU_STATE_MASK;
-		if (val == GLOBAL_STATUS_PPU_STATE_POLLING)
-			return 0;
-	}
-
-	return -ETIMEDOUT;
+	return chip->info->ops->ppu_enable(chip);
 }
 
 static void mv88e6xxx_ppu_reenable_work(struct work_struct *ugly)
@@ -2746,22 +2706,12 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 {
 	struct dsa_switch *ds = chip->ds;
 	u32 upstream_port = dsa_upstream_port(ds);
-	u16 reg;
 	int err;
 
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
+	err = mv88e6xxx_ppu_enable(chip);
 	if (err)
 		return err;
 
@@ -3223,6 +3173,8 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.ppu_enable = mv88e6185_g1_ppu_enable,
+	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
 };
 
@@ -3241,6 +3193,8 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.ppu_enable = mv88e6185_g1_ppu_enable,
+	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
 };
 
@@ -3311,6 +3265,8 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.ppu_enable = mv88e6185_g1_ppu_enable,
+	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
 };
 
@@ -3483,6 +3439,8 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
+	.ppu_enable = mv88e6185_g1_ppu_enable,
+	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
 };
 
@@ -4262,13 +4220,13 @@ static struct mv88e6xxx_chip *mv88e6xxx_alloc_chip(struct device *dev)
 
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
index c868eb0..75af86a 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -35,6 +35,27 @@ int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask)
 
 /* Offset 0x00: Switch Global Status Register */
 
+static int mv88e6185_g1_wait_ppu_disabled(struct mv88e6xxx_chip *chip)
+{
+	u16 state;
+	int i, err;
+
+	for (i = 0; i < 16; i++) {
+		err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &state);
+		if (err)
+			return err;
+
+		/* Check the value of the PPUState bits 15:14 */
+		state &= GLOBAL_STATUS_PPU_STATE_MASK;
+		if (state != GLOBAL_STATUS_PPU_STATE_POLLING)
+			return 0;
+
+		usleep_range(1000, 2000);
+	}
+
+	return -ETIMEDOUT;
+}
+
 static int mv88e6185_g1_wait_ppu_polling(struct mv88e6xxx_chip *chip)
 {
 	u16 state;
@@ -154,6 +175,42 @@ int mv88e6352_g1_reset(struct mv88e6xxx_chip *chip)
 	return mv88e6352_g1_wait_ppu_polling(chip);
 }
 
+int mv88e6185_g1_ppu_enable(struct mv88e6xxx_chip *chip)
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
+	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, val);
+	if (err)
+		return err;
+
+	return mv88e6185_g1_wait_ppu_polling(chip);
+}
+
+int mv88e6185_g1_ppu_disable(struct mv88e6xxx_chip *chip)
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
+	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, val);
+	if (err)
+		return err;
+
+	return mv88e6185_g1_wait_ppu_disabled(chip);
+}
+
 /* Offset 0x1a: Monitor Control */
 /* Offset 0x1a: Monitor & MGMT Control on some devices */
 
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 9fca215..1aec738 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -23,6 +23,9 @@ int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask);
 int mv88e6185_g1_reset(struct mv88e6xxx_chip *chip);
 int mv88e6352_g1_reset(struct mv88e6xxx_chip *chip);
 
+int mv88e6185_g1_ppu_enable(struct mv88e6xxx_chip *chip);
+int mv88e6185_g1_ppu_disable(struct mv88e6xxx_chip *chip);
+
 int mv88e6xxx_g1_stats_wait(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
 int mv88e6320_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index f201d13..af54bae 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -490,12 +490,6 @@ enum mv88e6xxx_cap {
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
@@ -537,8 +531,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_G2_PVT_DATA	BIT_ULL(MV88E6XXX_CAP_G2_PVT_DATA)
 #define MV88E6XXX_FLAG_G2_POT		BIT_ULL(MV88E6XXX_CAP_G2_POT)
 
-#define MV88E6XXX_FLAG_PPU		BIT_ULL(MV88E6XXX_CAP_PPU)
-#define MV88E6XXX_FLAG_PPU_ACTIVE	BIT_ULL(MV88E6XXX_CAP_PPU_ACTIVE)
 #define MV88E6XXX_FLAG_STU		BIT_ULL(MV88E6XXX_CAP_STU)
 #define MV88E6XXX_FLAG_TEMP		BIT_ULL(MV88E6XXX_CAP_TEMP)
 #define MV88E6XXX_FLAG_TEMP_LIMIT	BIT_ULL(MV88E6XXX_CAP_TEMP_LIMIT)
@@ -567,7 +559,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
-	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
@@ -578,7 +569,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
@@ -605,7 +595,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6320	\
@@ -614,7 +603,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
 	 MV88E6XXX_FLAG_VTU |		\
@@ -630,7 +618,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_VTU |		\
@@ -647,7 +634,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
@@ -662,7 +648,6 @@ struct mv88e6xxx_ops;
 #define MV88E6XXX_FLAGS_FAMILY_6390	\
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
@@ -792,6 +777,10 @@ struct mv88e6xxx_ops {
 	int (*phy_write)(struct mv88e6xxx_chip *chip, int addr, int reg,
 			 u16 val);
 
+	/* PHY Polling Unit (PPU) operations */
+	int (*ppu_enable)(struct mv88e6xxx_chip *chip);
+	int (*ppu_disable)(struct mv88e6xxx_chip *chip);
+
 	/* Switch Software Reset */
 	int (*reset)(struct mv88e6xxx_chip *chip);
 
-- 
2.10.2
