From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/9] net: dsa: mv88e6xxx: split setup of Global 1 and 2
Date: Thu,  7 Jul 2016 08:57:51 -0400
Message-ID: <20160707125758.1547-3-vivien.didelot@savoirfairelinux.com>
References: <20160707125758.1547-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41889 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751909AbcGGM6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 08:58:45 -0400
In-Reply-To: <20160707125758.1547-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Separate the setup of Global 1 and Global 2 internal SMI devices and add
a flag to describe the presence of this second registers set.

Also rearrange the G1 setup in the registers order.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 71 ++++++++++++++++++++++-------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 23 +++++++++---
 2 files changed, 62 insertions(+), 32 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 3feb842..1e39fa6 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2993,13 +2993,12 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	return 0;
 }
 
-static int mv88e6xxx_setup_global(struct mv88e6xxx_chip *chip)
+static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 {
 	struct dsa_switch *ds = chip->ds;
 	u32 upstream_port = dsa_upstream_port(ds);
 	u16 reg;
 	int err;
-	int i;
 
 	/* Enable the PHY Polling Unit if present, don't discard any packets,
 	 * and mask all interrupt sources.
@@ -3040,6 +3039,16 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
+	/* Clear all the VTU and STU entries */
+	err = _mv88e6xxx_vtu_stu_flush(chip);
+	if (err < 0)
+		return err;
+
+	/* Clear all ATU entries */
+	err = _mv88e6xxx_atu_flush(chip, 0, true);
+	if (err)
+		return err;
+
 	/* Configure the IP ToS mapping registers. */
 	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IP_PRI_0, 0x0000);
 	if (err)
@@ -3071,6 +3080,26 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
+	/* Clear the statistics counters for all ports */
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_STATS_OP,
+				   GLOBAL_STATS_OP_FLUSH_ALL);
+	if (err)
+		return err;
+
+	/* Wait for the flush to complete. */
+	err = _mv88e6xxx_stats_wait(chip);
+	if (err)
+		return err;
+
+	return 0;
+}
+
+static int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
+{
+	struct dsa_switch *ds = chip->ds;
+	int err;
+	int i;
+
 	/* Send all frames with destination addresses matching
 	 * 01:80:c2:00:00:0x to the CPU port.
 	 */
@@ -3174,28 +3203,7 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_chip *chip)
 		}
 	}
 
-	/* Clear the statistics counters for all ports */
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_STATS_OP,
-				   GLOBAL_STATS_OP_FLUSH_ALL);
-	if (err)
-		return err;
-
-	/* Wait for the flush to complete. */
-	err = _mv88e6xxx_stats_wait(chip);
-	if (err)
-		return err;
-
-	/* Clear all ATU entries */
-	err = _mv88e6xxx_atu_flush(chip, 0, true);
-	if (err)
-		return err;
-
-	/* Clear all the VTU and STU entries */
-	err = _mv88e6xxx_vtu_stu_flush(chip);
-	if (err < 0)
-		return err;
-
-	return err;
+	return 0;
 }
 
 static int mv88e6xxx_setup(struct dsa_switch *ds)
@@ -3216,12 +3224,21 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 	if (err)
 		goto unlock;
 
-	err = mv88e6xxx_setup_global(chip);
+	/* Setup Switch Port Registers */
+	for (i = 0; i < chip->info->num_ports; i++) {
+		err = mv88e6xxx_setup_port(chip, i);
+		if (err)
+			goto unlock;
+	}
+
+	/* Setup Switch Global 1 Registers */
+	err = mv88e6xxx_g1_setup(chip);
 	if (err)
 		goto unlock;
 
-	for (i = 0; i < chip->info->num_ports; i++) {
-		err = mv88e6xxx_setup_port(chip, i);
+	/* Setup Switch Global 2 Registers */
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_GLOBAL2)) {
+		err = mv88e6xxx_g2_setup(chip);
 		if (err)
 			goto unlock;
 	}
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 2ff62f4..390dac5 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -383,6 +383,11 @@ enum mv88e6xxx_cap {
 	 */
 	MV88E6XXX_CAP_EEPROM,
 
+	/* Switch Global 2 Registers.
+	 * The device contains a second set of global 16-bit registers.
+	 */
+	MV88E6XXX_CAP_GLOBAL2,
+
 	/* Multi-chip Addressing Mode.
 	 * Some chips require an indirect SMI access when their SMI device
 	 * address is not zero. See SMI_CMD and SMI_DATA.
@@ -429,6 +434,7 @@ enum mv88e6xxx_cap {
 /* Bitmask of capabilities */
 #define MV88E6XXX_FLAG_EEE		BIT(MV88E6XXX_CAP_EEE)
 #define MV88E6XXX_FLAG_EEPROM		BIT(MV88E6XXX_CAP_EEPROM)
+#define MV88E6XXX_FLAG_GLOBAL2		BIT(MV88E6XXX_CAP_GLOBAL2)
 #define MV88E6XXX_FLAG_MULTI_CHIP	BIT(MV88E6XXX_CAP_MULTI_CHIP)
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_PPU_ACTIVE	BIT(MV88E6XXX_CAP_PPU_ACTIVE)
@@ -440,31 +446,36 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_VTU		BIT(MV88E6XXX_CAP_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
-	(MV88E6XXX_FLAG_MULTI_CHIP |	\
+	(MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
-	(MV88E6XXX_FLAG_MULTI_CHIP |	\
+	(MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
-	(MV88E6XXX_FLAG_MULTI_CHIP |	\
+	(MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6185	\
-	(MV88E6XXX_FLAG_MULTI_CHIP |	\
+	(MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6320	\
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_EEPROM |	\
+	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
@@ -474,7 +485,8 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
-	(MV88E6XXX_FLAG_MULTI_CHIP |	\
+	(MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
 	 MV88E6XXX_FLAG_STU |		\
@@ -485,6 +497,7 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_EEPROM |	\
+	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
-- 
2.9.0
