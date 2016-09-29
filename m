From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 02/10] net: dsa: mv88e6xxx: abstract REG_GLOBAL2
Date: Thu, 29 Sep 2016 12:21:54 -0400
Message-ID: <20160929162202.10685-3-vivien.didelot@savoirfairelinux.com>
References: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48781 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755438AbcI2QWZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 12:22:25 -0400
In-Reply-To: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly to the ports, phys, and Global SMI devices, abstract the SMI
device address of the Global 2 registers in a few g2 static helpers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/global2.c   | 78 ++++++++++++++++++++++-------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  1 -
 2 files changed, 49 insertions(+), 30 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 99ed028..f31d553 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -14,6 +14,28 @@
 #include "mv88e6xxx.h"
 #include "global2.h"
 
+#define ADDR_GLOBAL2	0x1c
+
+static int mv88e6xxx_g2_read(struct mv88e6xxx_chip *chip, int reg, u16 *val)
+{
+	return mv88e6xxx_read(chip, ADDR_GLOBAL2, reg, val);
+}
+
+static int mv88e6xxx_g2_write(struct mv88e6xxx_chip *chip, int reg, u16 val)
+{
+	return mv88e6xxx_write(chip, ADDR_GLOBAL2, reg, val);
+}
+
+static int mv88e6xxx_g2_update(struct mv88e6xxx_chip *chip, int reg, u16 update)
+{
+	return mv88e6xxx_update(chip, ADDR_GLOBAL2, reg, update);
+}
+
+static int mv88e6xxx_g2_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask)
+{
+	return mv88e6xxx_wait(chip, ADDR_GLOBAL2, reg, mask);
+}
+
 /* Offset 0x06: Device Mapping Table register */
 
 static int mv88e6xxx_g2_device_mapping_write(struct mv88e6xxx_chip *chip,
@@ -21,7 +43,7 @@ static int mv88e6xxx_g2_device_mapping_write(struct mv88e6xxx_chip *chip,
 {
 	u16 val = (target << 8) | (port & 0xf);
 
-	return mv88e6xxx_update(chip, REG_GLOBAL2, GLOBAL2_DEVICE_MAPPING, val);
+	return mv88e6xxx_g2_update(chip, GLOBAL2_DEVICE_MAPPING, val);
 }
 
 static int mv88e6xxx_g2_set_device_mapping(struct mv88e6xxx_chip *chip)
@@ -58,7 +80,7 @@ static int mv88e6xxx_g2_trunk_mask_write(struct mv88e6xxx_chip *chip, int num,
 	if (hask)
 		val |= GLOBAL2_TRUNK_MASK_HASK;
 
-	return mv88e6xxx_update(chip, REG_GLOBAL2, GLOBAL2_TRUNK_MASK, val);
+	return mv88e6xxx_g2_update(chip, GLOBAL2_TRUNK_MASK, val);
 }
 
 /* Offset 0x08: Trunk Mapping Table register */
@@ -69,7 +91,7 @@ static int mv88e6xxx_g2_trunk_mapping_write(struct mv88e6xxx_chip *chip, int id,
 	const u16 port_mask = BIT(chip->info->num_ports) - 1;
 	u16 val = (id << 11) | (map & port_mask);
 
-	return mv88e6xxx_update(chip, REG_GLOBAL2, GLOBAL2_TRUNK_MAPPING, val);
+	return mv88e6xxx_g2_update(chip, GLOBAL2_TRUNK_MAPPING, val);
 }
 
 static int mv88e6xxx_g2_clear_trunk(struct mv88e6xxx_chip *chip)
@@ -105,15 +127,15 @@ static int mv88e6xxx_g2_clear_irl(struct mv88e6xxx_chip *chip)
 	/* Init all Ingress Rate Limit resources of all ports */
 	for (port = 0; port < chip->info->num_ports; ++port) {
 		/* XXX newer chips (like 88E6390) have different 2-bit ops */
-		err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_IRL_CMD,
-				      GLOBAL2_IRL_CMD_OP_INIT_ALL |
-				      (port << 8));
+		err = mv88e6xxx_g2_write(chip, GLOBAL2_IRL_CMD,
+					 GLOBAL2_IRL_CMD_OP_INIT_ALL |
+					 (port << 8));
 		if (err)
 			break;
 
 		/* Wait for the operation to complete */
-		err = mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_IRL_CMD,
-				     GLOBAL2_IRL_CMD_BUSY);
+		err = mv88e6xxx_g2_wait(chip, GLOBAL2_IRL_CMD,
+					GLOBAL2_IRL_CMD_BUSY);
 		if (err)
 			break;
 	}
@@ -128,7 +150,7 @@ static int mv88e6xxx_g2_switch_mac_write(struct mv88e6xxx_chip *chip,
 {
 	u16 val = (pointer << 8) | data;
 
-	return mv88e6xxx_update(chip, REG_GLOBAL2, GLOBAL2_SWITCH_MAC, val);
+	return mv88e6xxx_g2_update(chip, GLOBAL2_SWITCH_MAC, val);
 }
 
 int mv88e6xxx_g2_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
@@ -151,7 +173,7 @@ static int mv88e6xxx_g2_pot_write(struct mv88e6xxx_chip *chip, int pointer,
 {
 	u16 val = (pointer << 8) | (data & 0x7);
 
-	return mv88e6xxx_update(chip, REG_GLOBAL2, GLOBAL2_PRIO_OVERRIDE, val);
+	return mv88e6xxx_g2_update(chip, GLOBAL2_PRIO_OVERRIDE, val);
 }
 
 static int mv88e6xxx_g2_clear_pot(struct mv88e6xxx_chip *chip)
@@ -174,16 +196,16 @@ static int mv88e6xxx_g2_clear_pot(struct mv88e6xxx_chip *chip)
 
 static int mv88e6xxx_g2_eeprom_wait(struct mv88e6xxx_chip *chip)
 {
-	return mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_EEPROM_CMD,
-			      GLOBAL2_EEPROM_CMD_BUSY |
-			      GLOBAL2_EEPROM_CMD_RUNNING);
+	return mv88e6xxx_g2_wait(chip, GLOBAL2_EEPROM_CMD,
+				 GLOBAL2_EEPROM_CMD_BUSY |
+				 GLOBAL2_EEPROM_CMD_RUNNING);
 }
 
 static int mv88e6xxx_g2_eeprom_cmd(struct mv88e6xxx_chip *chip, u16 cmd)
 {
 	int err;
 
-	err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_EEPROM_CMD, cmd);
+	err = mv88e6xxx_g2_write(chip, GLOBAL2_EEPROM_CMD, cmd);
 	if (err)
 		return err;
 
@@ -204,7 +226,7 @@ static int mv88e6xxx_g2_eeprom_read16(struct mv88e6xxx_chip *chip,
 	if (err)
 		return err;
 
-	return mv88e6xxx_read(chip, REG_GLOBAL2, GLOBAL2_EEPROM_DATA, data);
+	return mv88e6xxx_g2_read(chip, GLOBAL2_EEPROM_DATA, data);
 }
 
 static int mv88e6xxx_g2_eeprom_write16(struct mv88e6xxx_chip *chip,
@@ -217,7 +239,7 @@ static int mv88e6xxx_g2_eeprom_write16(struct mv88e6xxx_chip *chip,
 	if (err)
 		return err;
 
-	err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_EEPROM_DATA, data);
+	err = mv88e6xxx_g2_write(chip, GLOBAL2_EEPROM_DATA, data);
 	if (err)
 		return err;
 
@@ -283,7 +305,7 @@ int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 	int err;
 
 	/* Ensure the RO WriteEn bit is set */
-	err = mv88e6xxx_read(chip, REG_GLOBAL2, GLOBAL2_EEPROM_CMD, &val);
+	err = mv88e6xxx_g2_read(chip, GLOBAL2_EEPROM_CMD, &val);
 	if (err)
 		return err;
 
@@ -346,15 +368,15 @@ int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 
 static int mv88e6xxx_g2_smi_phy_wait(struct mv88e6xxx_chip *chip)
 {
-	return mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_SMI_PHY_CMD,
-			      GLOBAL2_SMI_PHY_CMD_BUSY);
+	return mv88e6xxx_g2_wait(chip, GLOBAL2_SMI_PHY_CMD,
+				 GLOBAL2_SMI_PHY_CMD_BUSY);
 }
 
 static int mv88e6xxx_g2_smi_phy_cmd(struct mv88e6xxx_chip *chip, u16 cmd)
 {
 	int err;
 
-	err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_SMI_PHY_CMD, cmd);
+	err = mv88e6xxx_g2_write(chip, GLOBAL2_SMI_PHY_CMD, cmd);
 	if (err)
 		return err;
 
@@ -375,7 +397,7 @@ int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int addr, int reg,
 	if (err)
 		return err;
 
-	return mv88e6xxx_read(chip, REG_GLOBAL2, GLOBAL2_SMI_PHY_DATA, val);
+	return mv88e6xxx_g2_read(chip, GLOBAL2_SMI_PHY_DATA, val);
 }
 
 int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr, int reg,
@@ -388,7 +410,7 @@ int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr, int reg,
 	if (err)
 		return err;
 
-	err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_SMI_PHY_DATA, val);
+	err = mv88e6xxx_g2_write(chip, GLOBAL2_SMI_PHY_DATA, val);
 	if (err)
 		return err;
 
@@ -404,8 +426,7 @@ int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 		/* Consider the frames with reserved multicast destination
 		 * addresses matching 01:80:c2:00:00:2x as MGMT.
 		 */
-		err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_MGMT_EN_2X,
-				      0xffff);
+		err = mv88e6xxx_g2_write(chip, GLOBAL2_MGMT_EN_2X, 0xffff);
 		if (err)
 			return err;
 	}
@@ -414,8 +435,7 @@ int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 		/* Consider the frames with reserved multicast destination
 		 * addresses matching 01:80:c2:00:00:0x as MGMT.
 		 */
-		err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_MGMT_EN_0X,
-				      0xffff);
+		err = mv88e6xxx_g2_write(chip, GLOBAL2_MGMT_EN_0X, 0xffff);
 		if (err)
 			return err;
 	}
@@ -429,7 +449,7 @@ int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_0X) ||
 	    mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_2X))
 		reg |= GLOBAL2_SWITCH_MGMT_RSVD2CPU | 0x7;
-	err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_SWITCH_MGMT, reg);
+	err = mv88e6xxx_g2_write(chip, GLOBAL2_SWITCH_MGMT, reg);
 	if (err)
 		return err;
 
@@ -454,8 +474,8 @@ int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_PVT)) {
 		/* Initialize Cross-chip Port VLAN Table to reset defaults */
-		err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_PVT_ADDR,
-				      GLOBAL2_PVT_ADDR_OP_INIT_ONES);
+		err = mv88e6xxx_g2_write(chip, GLOBAL2_PVT_ADDR,
+					 GLOBAL2_PVT_ADDR_OP_INIT_ONES);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index bf78f6d..2f10108 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -276,7 +276,6 @@
 #define GLOBAL_STATS_COUNTER_32	0x1e
 #define GLOBAL_STATS_COUNTER_01	0x1f
 
-#define REG_GLOBAL2		0x1c
 #define GLOBAL2_INT_SOURCE	0x00
 #define GLOBAL2_INT_MASK	0x01
 #define GLOBAL2_MGMT_EN_2X	0x02
-- 
2.10.0
