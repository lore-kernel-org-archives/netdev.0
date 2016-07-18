From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next v2 05/12] net: dsa: mv88e6xxx: add cap for MGMT Enables bits
Date: Mon, 18 Jul 2016 14:46:21 -0400
Message-ID: <20160718184628.13103-6-vivien.didelot@savoirfairelinux.com>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some switches provide a Rsvd2CPU mechanism used to choose which of the
16 reserved multicast destination addresses matching 01:80:c2:00:00:0x
should be considered as MGMT and thus forwarded to the CPU port.

Other switches extend this mechanism to also configure as MGMT the
additional 16 reserved multicast addresses matching 01:80:c2:00:00:2x.

This mechanism is exposed via two registers in Global 2, and an Rsvd2CPU
enable bit in the management register.

Newer chip (such as 88E6390) has replaced these registers with a new
indirect MGMT mechanism in Global 1.

The patch adds two MV88E6XXX_FLAG_G2_MGMT_EN_{0,2}X flags to describe
the presence of these Global 2 registers. If 88E6390 support is added, a
MV88E6XXX_FLAG_G1_MGMT_CTRL flag will be needed to setup Rsvd2CPU.

Note: all switches still support in parallel the ATU Load operation with
an MGMT Entry State to forward such frames in a less convenient way.

net: dsa: mv88e6xxx: add cap for MGMT Enable 2x
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 43 ++++++++++++++++++++---------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 16 +++++++++++++
 2 files changed, 41 insertions(+), 18 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 5a4a1b7..8199998 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3199,25 +3199,40 @@ static int mv88e6xxx_g2_clear_trunk(struct mv88e6xxx_chip *chip)
 
 static int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 {
+	u16 reg;
 	int err;
 	int i;
 
-	/* Send all frames with destination addresses matching
-	 * 01:80:c2:00:00:0x to the CPU port.
-	 */
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_MGMT_EN_0X,
-				   0xffff);
-	if (err)
-		return err;
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_2X)) {
+		/* Consider the frames with reserved multicast destination
+		 * addresses matching 01:80:c2:00:00:2x as MGMT.
+		 */
+		err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_MGMT_EN_2X,
+				      0xffff);
+		if (err)
+			return err;
+	}
+
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_0X)) {
+		/* Consider the frames with reserved multicast destination
+		 * addresses matching 01:80:c2:00:00:0x as MGMT.
+		 */
+		err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_MGMT_EN_0X,
+				      0xffff);
+		if (err)
+			return err;
+	}
 
 	/* Ignore removed tag data on doubly tagged packets, disable
 	 * flow control messages, force flow control priority to the
 	 * highest, and send all special multicast frames to the CPU
 	 * port at the highest priority.
 	 */
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_SWITCH_MGMT,
-				   0x7 | GLOBAL2_SWITCH_MGMT_RSVD2CPU | 0x70 |
-				   GLOBAL2_SWITCH_MGMT_FORCE_FLOW_CTRL_PRI);
+	reg = GLOBAL2_SWITCH_MGMT_FORCE_FLOW_CTRL_PRI | (0x7 << 4);
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_0X) ||
+	    mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_2X))
+		reg |= GLOBAL2_SWITCH_MGMT_RSVD2CPU | 0x7;
+	err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_SWITCH_MGMT, reg);
 	if (err)
 		return err;
 
@@ -3234,14 +3249,6 @@ static int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
 	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
 	    mv88e6xxx_6320_family(chip)) {
-		/* Send all frames with destination addresses matching
-		 * 01:80:c2:00:00:2x to the CPU port.
-		 */
-		err = _mv88e6xxx_reg_write(chip, REG_GLOBAL2,
-					   GLOBAL2_MGMT_EN_2X, 0xffff);
-		if (err)
-			return err;
-
 		/* Initialise cross-chip port VLAN table to reset
 		 * defaults.
 		 */
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 876d9ea..d13b0b5 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -388,6 +388,8 @@ enum mv88e6xxx_cap {
 	 * The device contains a second set of global 16-bit registers.
 	 */
 	MV88E6XXX_CAP_GLOBAL2,
+	MV88E6XXX_CAP_G2_MGMT_EN_2X,	/* (0x02) MGMT Enable Register 2x */
+	MV88E6XXX_CAP_G2_MGMT_EN_0X,	/* (0x03) MGMT Enable Register 0x */
 
 	/* Multi-chip Addressing Mode.
 	 * Some chips require an indirect SMI access when their SMI device
@@ -436,6 +438,8 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_EEE		BIT(MV88E6XXX_CAP_EEE)
 #define MV88E6XXX_FLAG_EEPROM		BIT(MV88E6XXX_CAP_EEPROM)
 #define MV88E6XXX_FLAG_GLOBAL2		BIT(MV88E6XXX_CAP_GLOBAL2)
+#define MV88E6XXX_FLAG_G2_MGMT_EN_2X	BIT(MV88E6XXX_CAP_G2_MGMT_EN_2X)
+#define MV88E6XXX_FLAG_G2_MGMT_EN_0X	BIT(MV88E6XXX_CAP_G2_MGMT_EN_0X)
 #define MV88E6XXX_FLAG_MULTI_CHIP	BIT(MV88E6XXX_CAP_MULTI_CHIP)
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_PPU_ACTIVE	BIT(MV88E6XXX_CAP_PPU_ACTIVE)
@@ -448,12 +452,15 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
+	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_STU |		\
@@ -461,6 +468,8 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
+	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_SWITCH_MAC |	\
@@ -469,6 +478,7 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6185	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VTU)
@@ -477,6 +487,8 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_EEPROM |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
+	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
@@ -487,6 +499,8 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
+	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
@@ -499,6 +513,8 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_EEPROM |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
+	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
-- 
2.9.0
