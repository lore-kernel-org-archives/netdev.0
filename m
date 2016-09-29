From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 03/10] net: dsa: mv88e6xxx: add flags for FID registers
Date: Thu, 29 Sep 2016 12:21:55 -0400
Message-ID: <20160929162202.10685-4-vivien.didelot@savoirfairelinux.com>
References: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add flags to describe the presence of Global 1 ATU FID register (0x01)
and VTU FID register (0x02), instead of checking families.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 16 +++-------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 24 ++++++++++++++++++++----
 2 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 98dee2c..b7eecc9 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -565,16 +565,6 @@ static unsigned int mv88e6xxx_num_databases(struct mv88e6xxx_chip *chip)
 	return chip->info->num_databases;
 }
 
-static bool mv88e6xxx_has_fid_reg(struct mv88e6xxx_chip *chip)
-{
-	/* Does the device have dedicated FID registers for ATU and VTU ops? */
-	if (mv88e6xxx_6097_family(chip) || mv88e6xxx_6165_family(chip) ||
-	    mv88e6xxx_6351_family(chip) || mv88e6xxx_6352_family(chip))
-		return true;
-
-	return false;
-}
-
 /* We expect the switch to perform auto negotiation if there is a real
  * phy. However, in the case of a fixed link phy, we force the port
  * settings from the fixed link settings.
@@ -978,7 +968,7 @@ static int _mv88e6xxx_atu_cmd(struct mv88e6xxx_chip *chip, u16 fid, u16 cmd)
 	u16 val;
 	int err;
 
-	if (mv88e6xxx_has_fid_reg(chip)) {
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G1_ATU_FID)) {
 		err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_FID, fid);
 		if (err)
 			return err;
@@ -1386,7 +1376,7 @@ static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
 		if (err)
 			return err;
 
-		if (mv88e6xxx_has_fid_reg(chip)) {
+		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G1_VTU_FID)) {
 			err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_FID, &val);
 			if (err)
 				return err;
@@ -1498,7 +1488,7 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 			return err;
 	}
 
-	if (mv88e6xxx_has_fid_reg(chip)) {
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G1_VTU_FID)) {
 		reg = entry->fid & GLOBAL_VTU_FID_MASK;
 		err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_FID, reg);
 		if (err)
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 2f10108..6c8584f 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -170,8 +170,8 @@
 #define GLOBAL_MAC_01		0x01
 #define GLOBAL_MAC_23		0x02
 #define GLOBAL_MAC_45		0x03
-#define GLOBAL_ATU_FID		0x01	/* 6097 6165 6351 6352 */
-#define GLOBAL_VTU_FID		0x02	/* 6097 6165 6351 6352 */
+#define GLOBAL_ATU_FID		0x01
+#define GLOBAL_VTU_FID		0x02
 #define GLOBAL_VTU_FID_MASK	0xfff
 #define GLOBAL_VTU_SID		0x03	/* 6097 6165 6351 6352 */
 #define GLOBAL_VTU_SID_MASK	0x3f
@@ -408,6 +408,11 @@ enum mv88e6xxx_cap {
 	 */
 	MV88E6XXX_CAP_SERDES,
 
+	/* Switch Global (1) Registers.
+	 */
+	MV88E6XXX_CAP_G1_ATU_FID,	/* (0x01) ATU FID Register */
+	MV88E6XXX_CAP_G1_VTU_FID,	/* (0x02) VTU FID Register */
+
 	/* Switch Global 2 Registers.
 	 * The device contains a second set of global 16-bit registers.
 	 */
@@ -460,6 +465,9 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAG_SERDES		BIT_ULL(MV88E6XXX_CAP_SERDES)
 
+#define MV88E6XXX_FLAG_G1_ATU_FID	BIT_ULL(MV88E6XXX_CAP_G1_ATU_FID)
+#define MV88E6XXX_FLAG_G1_VTU_FID	BIT_ULL(MV88E6XXX_CAP_G1_VTU_FID)
+
 #define MV88E6XXX_FLAG_GLOBAL2		BIT_ULL(MV88E6XXX_CAP_GLOBAL2)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_2X	BIT_ULL(MV88E6XXX_CAP_G2_MGMT_EN_2X)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_0X	BIT_ULL(MV88E6XXX_CAP_G2_MGMT_EN_0X)
@@ -519,7 +527,9 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
-	(MV88E6XXX_FLAG_GLOBAL2 |	\
+	(MV88E6XXX_FLAG_G1_ATU_FID |	\
+	 MV88E6XXX_FLAG_G1_VTU_FID |	\
+	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
@@ -531,7 +541,9 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
-	(MV88E6XXX_FLAG_GLOBAL2 |	\
+	(MV88E6XXX_FLAG_G1_ATU_FID |	\
+	 MV88E6XXX_FLAG_G1_VTU_FID |	\
+	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
@@ -570,6 +582,8 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
 	(MV88E6XXX_FLAG_EDSA |		\
+	 MV88E6XXX_FLAG_G1_ATU_FID |	\
+	 MV88E6XXX_FLAG_G1_VTU_FID |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
@@ -587,6 +601,8 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
 	(MV88E6XXX_FLAG_EDSA |		\
 	 MV88E6XXX_FLAG_EEE |		\
+	 MV88E6XXX_FLAG_G1_ATU_FID |	\
+	 MV88E6XXX_FLAG_G1_VTU_FID |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
-- 
2.10.0
