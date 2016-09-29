From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 08/10] net: dsa: mv88e6xxx: add chip-wide ops
Date: Thu, 29 Sep 2016 12:22:00 -0400
Message-ID: <20160929162202.10685-9-vivien.didelot@savoirfairelinux.com>
References: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48864 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755705AbcI2QWi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 12:22:38 -0400
In-Reply-To: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a mv88e6xxx_ops structure to describe supported chip-wide
functions and assign the correct variant to the chip models.

For the moment, add only PHY access routines. This allows to get rid of
the PHY ops structures and the usage of PHY flags.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 136 +++++++++++++++++++++++++++-------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  28 ++++---
 2 files changed, 121 insertions(+), 43 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index ad31d3e..83a3769 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -238,10 +238,10 @@ static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
 {
 	int addr = phy; /* PHY devices addresses start at 0x0 */
 
-	if (!chip->phy_ops)
+	if (!chip->info->ops->phy_read)
 		return -EOPNOTSUPP;
 
-	return chip->phy_ops->read(chip, addr, reg, val);
+	return chip->info->ops->phy_read(chip, addr, reg, val);
 }
 
 static int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
@@ -249,10 +249,10 @@ static int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
 {
 	int addr = phy; /* PHY devices addresses start at 0x0 */
 
-	if (!chip->phy_ops)
+	if (!chip->info->ops->phy_write)
 		return -EOPNOTSUPP;
 
-	return chip->phy_ops->write(chip, addr, reg, val);
+	return chip->info->ops->phy_write(chip, addr, reg, val);
 }
 
 static int mv88e6xxx_phy_page_get(struct mv88e6xxx_chip *chip, int phy, u8 page)
@@ -515,11 +515,6 @@ static int mv88e6xxx_phy_ppu_write(struct mv88e6xxx_chip *chip, int addr,
 	return err;
 }
 
-static const struct mv88e6xxx_bus_ops mv88e6xxx_phy_ppu_ops = {
-	.read = mv88e6xxx_phy_ppu_read,
-	.write = mv88e6xxx_phy_ppu_write,
-};
-
 static bool mv88e6xxx_6065_family(struct mv88e6xxx_chip *chip)
 {
 	return chip->info->family == MV88E6XXX_FAMILY_6065;
@@ -3214,6 +3209,91 @@ static int mv88e6xxx_set_eeprom(struct dsa_switch *ds,
 	return err;
 }
 
+static const struct mv88e6xxx_ops mv88e6085_ops = {
+	.phy_read = mv88e6xxx_phy_ppu_read,
+	.phy_write = mv88e6xxx_phy_ppu_write,
+};
+
+static const struct mv88e6xxx_ops mv88e6095_ops = {
+	.phy_read = mv88e6xxx_phy_ppu_read,
+	.phy_write = mv88e6xxx_phy_ppu_write,
+};
+
+static const struct mv88e6xxx_ops mv88e6123_ops = {
+	.phy_read = mv88e6xxx_read,
+	.phy_write = mv88e6xxx_write,
+};
+
+static const struct mv88e6xxx_ops mv88e6131_ops = {
+	.phy_read = mv88e6xxx_phy_ppu_read,
+	.phy_write = mv88e6xxx_phy_ppu_write,
+};
+
+static const struct mv88e6xxx_ops mv88e6161_ops = {
+	.phy_read = mv88e6xxx_read,
+	.phy_write = mv88e6xxx_write,
+};
+
+static const struct mv88e6xxx_ops mv88e6165_ops = {
+	.phy_read = mv88e6xxx_read,
+	.phy_write = mv88e6xxx_write,
+};
+
+static const struct mv88e6xxx_ops mv88e6171_ops = {
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+};
+
+static const struct mv88e6xxx_ops mv88e6172_ops = {
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+};
+
+static const struct mv88e6xxx_ops mv88e6175_ops = {
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+};
+
+static const struct mv88e6xxx_ops mv88e6176_ops = {
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+};
+
+static const struct mv88e6xxx_ops mv88e6185_ops = {
+	.phy_read = mv88e6xxx_phy_ppu_read,
+	.phy_write = mv88e6xxx_phy_ppu_write,
+};
+
+static const struct mv88e6xxx_ops mv88e6240_ops = {
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+};
+
+static const struct mv88e6xxx_ops mv88e6320_ops = {
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+};
+
+static const struct mv88e6xxx_ops mv88e6321_ops = {
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+};
+
+static const struct mv88e6xxx_ops mv88e6350_ops = {
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+};
+
+static const struct mv88e6xxx_ops mv88e6351_ops = {
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+};
+
+static const struct mv88e6xxx_ops mv88e6352_ops = {
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+};
+
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	[MV88E6085] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6085,
@@ -3225,6 +3305,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
+		.ops = &mv88e6085_ops,
 	},
 
 	[MV88E6095] = {
@@ -3237,6 +3318,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6095,
+		.ops = &mv88e6095_ops,
 	},
 
 	[MV88E6123] = {
@@ -3249,6 +3331,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
+		.ops = &mv88e6123_ops,
 	},
 
 	[MV88E6131] = {
@@ -3261,6 +3344,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
+		.ops = &mv88e6131_ops,
 	},
 
 	[MV88E6161] = {
@@ -3273,6 +3357,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
+		.ops = &mv88e6161_ops,
 	},
 
 	[MV88E6165] = {
@@ -3285,6 +3370,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
+		.ops = &mv88e6165_ops,
 	},
 
 	[MV88E6171] = {
@@ -3297,6 +3383,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
+		.ops = &mv88e6171_ops,
 	},
 
 	[MV88E6172] = {
@@ -3309,6 +3396,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
+		.ops = &mv88e6172_ops,
 	},
 
 	[MV88E6175] = {
@@ -3321,6 +3409,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
+		.ops = &mv88e6175_ops,
 	},
 
 	[MV88E6176] = {
@@ -3333,6 +3422,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
+		.ops = &mv88e6176_ops,
 	},
 
 	[MV88E6185] = {
@@ -3345,6 +3435,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
+		.ops = &mv88e6185_ops,
 	},
 
 	[MV88E6240] = {
@@ -3357,6 +3448,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
+		.ops = &mv88e6240_ops,
 	},
 
 	[MV88E6320] = {
@@ -3369,6 +3461,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
+		.ops = &mv88e6320_ops,
 	},
 
 	[MV88E6321] = {
@@ -3381,6 +3474,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
+		.ops = &mv88e6321_ops,
 	},
 
 	[MV88E6350] = {
@@ -3393,6 +3487,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
+		.ops = &mv88e6350_ops,
 	},
 
 	[MV88E6351] = {
@@ -3405,6 +3500,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
+		.ops = &mv88e6351_ops,
 	},
 
 	[MV88E6352] = {
@@ -3417,6 +3513,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
+		.ops = &mv88e6352_ops,
 	},
 };
 
@@ -3479,33 +3576,16 @@ static struct mv88e6xxx_chip *mv88e6xxx_alloc_chip(struct device *dev)
 	return chip;
 }
 
-static const struct mv88e6xxx_bus_ops mv88e6xxx_g2_smi_phy_ops = {
-	.read = mv88e6xxx_g2_smi_phy_read,
-	.write = mv88e6xxx_g2_smi_phy_write,
-};
-
-static const struct mv88e6xxx_bus_ops mv88e6xxx_phy_ops = {
-	.read = mv88e6xxx_read,
-	.write = mv88e6xxx_write,
-};
-
 static void mv88e6xxx_phy_init(struct mv88e6xxx_chip *chip)
 {
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_SMI_PHY)) {
-		chip->phy_ops = &mv88e6xxx_g2_smi_phy_ops;
-	} else if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU)) {
-		chip->phy_ops = &mv88e6xxx_phy_ppu_ops;
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU))
 		mv88e6xxx_ppu_state_init(chip);
-	} else {
-		chip->phy_ops = &mv88e6xxx_phy_ops;
-	}
 }
 
 static void mv88e6xxx_phy_destroy(struct mv88e6xxx_chip *chip)
 {
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU)) {
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU))
 		mv88e6xxx_ppu_state_destroy(chip);
-	}
 }
 
 static int mv88e6xxx_smi_init(struct mv88e6xxx_chip *chip,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index b9ef769..8e12902 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -427,8 +427,6 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_G2_POT,		/* (0x0f) Priority Override Table */
 	MV88E6XXX_CAP_G2_EEPROM_CMD,	/* (0x14) EEPROM Command */
 	MV88E6XXX_CAP_G2_EEPROM_DATA,	/* (0x15) EEPROM Data */
-	MV88E6XXX_CAP_G2_SMI_PHY_CMD,	/* (0x18) SMI PHY Command */
-	MV88E6XXX_CAP_G2_SMI_PHY_DATA,	/* (0x19) SMI PHY Data */
 
 	/* PHY Polling Unit.
 	 * See GLOBAL_CONTROL_PPU_ENABLE and GLOBAL_STATUS_PPU_POLLING.
@@ -479,8 +477,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_G2_POT		BIT_ULL(MV88E6XXX_CAP_G2_POT)
 #define MV88E6XXX_FLAG_G2_EEPROM_CMD	BIT_ULL(MV88E6XXX_CAP_G2_EEPROM_CMD)
 #define MV88E6XXX_FLAG_G2_EEPROM_DATA	BIT_ULL(MV88E6XXX_CAP_G2_EEPROM_DATA)
-#define MV88E6XXX_FLAG_G2_SMI_PHY_CMD	BIT_ULL(MV88E6XXX_CAP_G2_SMI_PHY_CMD)
-#define MV88E6XXX_FLAG_G2_SMI_PHY_DATA	BIT_ULL(MV88E6XXX_CAP_G2_SMI_PHY_DATA)
 
 #define MV88E6XXX_FLAG_PPU		BIT_ULL(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_PPU_ACTIVE	BIT_ULL(MV88E6XXX_CAP_PPU_ACTIVE)
@@ -514,11 +510,6 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_PHY_PAGE |	\
 	 MV88E6XXX_FLAG_SERDES)
 
-/* Indirect PHY access via Global2 SMI PHY registers */
-#define MV88E6XXX_FLAGS_SMI_PHY		\
-	(MV88E6XXX_FLAG_G2_SMI_PHY_CMD |\
-	 MV88E6XXX_FLAG_G2_SMI_PHY_DATA)
-
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
@@ -577,8 +568,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_EEPROM16 |	\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAGS_PVT |		\
-	 MV88E6XXX_FLAGS_SMI_PHY)
+	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
 	(MV88E6XXX_FLAG_EDSA |		\
@@ -595,8 +585,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAGS_PVT |		\
-	 MV88E6XXX_FLAGS_SMI_PHY)
+	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
 	(MV88E6XXX_FLAG_EDSA |		\
@@ -617,8 +606,9 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAGS_PVT |		\
-	 MV88E6XXX_FLAGS_SERDES |	\
-	 MV88E6XXX_FLAGS_SMI_PHY)
+	 MV88E6XXX_FLAGS_SERDES)
+
+struct mv88e6xxx_ops;
 
 struct mv88e6xxx_info {
 	enum mv88e6xxx_family family;
@@ -630,6 +620,7 @@ struct mv88e6xxx_info {
 	unsigned int global1_addr;
 	unsigned int age_time_coeff;
 	unsigned long long flags;
+	const struct mv88e6xxx_ops *ops;
 };
 
 struct mv88e6xxx_atu_entry {
@@ -710,6 +701,13 @@ struct mv88e6xxx_bus_ops {
 	int (*write)(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val);
 };
 
+struct mv88e6xxx_ops {
+	int (*phy_read)(struct mv88e6xxx_chip *chip, int addr, int reg,
+			u16 *val);
+	int (*phy_write)(struct mv88e6xxx_chip *chip, int addr, int reg,
+			 u16 val);
+};
+
 enum stat_type {
 	BANK0,
 	BANK1,
-- 
2.10.0
