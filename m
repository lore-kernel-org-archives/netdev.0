From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/5] net: dsa: mv88e6xxx: Pass mii_bus to all PHY operations
Date: Tue, 24 Jan 2017 14:53:48 +0100
Message-ID: <1485266031-4980-3-git-send-email-andrew@lunn.ch>
References: <1485266031-4980-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43680 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750708AbdAXNyo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 08:54:44 -0500
In-Reply-To: <1485266031-4980-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for supporting multiple MDIO busses, pass the mii_bus
structure to all PHY operations. It will in future then be clear on
which MDIO bus the operation should be performed.

For reads/write from phylib, the mii_bus is readily available. However
some internal code also access the PHY, e.g. for EEE and SERDES. Make
this code use the one and only currently available MDIO bus.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 42 +++++++++++++++++++++++++----------
 drivers/net/dsa/mv88e6xxx/global2.c   | 10 +++++----
 drivers/net/dsa/mv88e6xxx/global2.h   | 12 ++++++----
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 10 +++++----
 4 files changed, 50 insertions(+), 24 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 374d887e8256..dedccf201452 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -222,14 +222,16 @@ int mv88e6xxx_write(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val)
 	return 0;
 }
 
-static int mv88e6165_phy_read(struct mv88e6xxx_chip *chip, int addr,
-			      int reg, u16 *val)
+static int mv88e6165_phy_read(struct mv88e6xxx_chip *chip,
+			      struct mii_bus *bus,
+			      int addr, int reg, u16 *val)
 {
 	return mv88e6xxx_read(chip, addr, reg, val);
 }
 
-static int mv88e6165_phy_write(struct mv88e6xxx_chip *chip, int addr,
-			       int reg, u16 val)
+static int mv88e6165_phy_write(struct mv88e6xxx_chip *chip,
+			       struct mii_bus *bus,
+			       int addr, int reg, u16 val)
 {
 	return mv88e6xxx_write(chip, addr, reg, val);
 }
@@ -238,22 +240,30 @@ static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
 			      int reg, u16 *val)
 {
 	int addr = phy; /* PHY devices addresses start at 0x0 */
+	struct mii_bus *bus = chip->mdio_bus;
 
 	if (!chip->info->ops->phy_read)
 		return -EOPNOTSUPP;
 
-	return chip->info->ops->phy_read(chip, addr, reg, val);
+	if (!bus)
+		return -EOPNOTSUPP;
+
+	return chip->info->ops->phy_read(chip, bus, addr, reg, val);
 }
 
 static int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
 			       int reg, u16 val)
 {
 	int addr = phy; /* PHY devices addresses start at 0x0 */
+	struct mii_bus *bus = chip->mdio_bus;
 
 	if (!chip->info->ops->phy_write)
 		return -EOPNOTSUPP;
 
-	return chip->info->ops->phy_write(chip, addr, reg, val);
+	if (!bus)
+		return -EOPNOTSUPP;
+
+	return chip->info->ops->phy_write(chip, bus, addr, reg, val);
 }
 
 static int mv88e6xxx_phy_page_get(struct mv88e6xxx_chip *chip, int phy, u8 page)
@@ -623,8 +633,9 @@ static void mv88e6xxx_ppu_state_destroy(struct mv88e6xxx_chip *chip)
 	del_timer_sync(&chip->ppu_timer);
 }
 
-static int mv88e6xxx_phy_ppu_read(struct mv88e6xxx_chip *chip, int addr,
-				  int reg, u16 *val)
+static int mv88e6xxx_phy_ppu_read(struct mv88e6xxx_chip *chip,
+				  struct mii_bus *bus,
+				  int addr, int reg, u16 *val)
 {
 	int err;
 
@@ -637,8 +648,9 @@ static int mv88e6xxx_phy_ppu_read(struct mv88e6xxx_chip *chip, int addr,
 	return err;
 }
 
-static int mv88e6xxx_phy_ppu_write(struct mv88e6xxx_chip *chip, int addr,
-				   int reg, u16 val)
+static int mv88e6xxx_phy_ppu_write(struct mv88e6xxx_chip *chip,
+				   struct mii_bus *bus,
+				   int addr, int reg, u16 val)
 {
 	int err;
 
@@ -2897,8 +2909,11 @@ static int mv88e6xxx_mdio_read(struct mii_bus *bus, int phy, int reg)
 	if (phy >= mv88e6xxx_num_ports(chip))
 		return 0xffff;
 
+	if (!chip->info->ops->phy_read)
+		return -EOPNOTSUPP;
+
 	mutex_lock(&chip->reg_lock);
-	err = mv88e6xxx_phy_read(chip, phy, reg, &val);
+	err = chip->info->ops->phy_read(chip, bus, phy, reg, &val);
 	mutex_unlock(&chip->reg_lock);
 
 	return err ? err : val;
@@ -2912,8 +2927,11 @@ static int mv88e6xxx_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
 	if (phy >= mv88e6xxx_num_ports(chip))
 		return 0xffff;
 
+	if (!chip->info->ops->phy_write)
+		return -EOPNOTSUPP;
+
 	mutex_lock(&chip->reg_lock);
-	err = mv88e6xxx_phy_write(chip, phy, reg, val);
+	err = chip->info->ops->phy_write(chip, bus, phy, reg, val);
 	mutex_unlock(&chip->reg_lock);
 
 	return err;
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index ead2e265c9ef..1f9a12a1fad9 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -501,8 +501,9 @@ static int mv88e6xxx_g2_smi_phy_cmd(struct mv88e6xxx_chip *chip, u16 cmd)
 	return mv88e6xxx_g2_smi_phy_wait(chip);
 }
 
-int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int addr, int reg,
-			      u16 *val)
+int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip,
+			      struct mii_bus *bus,
+			      int addr, int reg, u16 *val)
 {
 	u16 cmd = GLOBAL2_SMI_PHY_CMD_OP_22_READ_DATA | (addr << 5) | reg;
 	int err;
@@ -518,8 +519,9 @@ int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int addr, int reg,
 	return mv88e6xxx_g2_read(chip, GLOBAL2_SMI_PHY_DATA, val);
 }
 
-int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr, int reg,
-			       u16 val)
+int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip,
+			       struct mii_bus *bus,
+			       int addr, int reg, u16 val)
 {
 	u16 cmd = GLOBAL2_SMI_PHY_CMD_OP_22_WRITE_DATA | (addr << 5) | reg;
 	int err;
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 2918f22388f7..00e635279ba1 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -23,10 +23,12 @@ static inline int mv88e6xxx_g2_require(struct mv88e6xxx_chip *chip)
 	return 0;
 }
 
-int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int addr, int reg,
-			      u16 *val);
-int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr, int reg,
-			       u16 val);
+int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip,
+			      struct mii_bus *bus,
+			      int addr, int reg, u16 *val);
+int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip,
+			       struct mii_bus *bus,
+			       int addr, int reg, u16 val);
 int mv88e6xxx_g2_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr);
 
 int mv88e6xxx_g2_get_eeprom8(struct mv88e6xxx_chip *chip,
@@ -57,12 +59,14 @@ static inline int mv88e6xxx_g2_require(struct mv88e6xxx_chip *chip)
 }
 
 static inline int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip,
+					    struct mii_bus *bus,
 					    int addr, int reg, u16 *val)
 {
 	return -EOPNOTSUPP;
 }
 
 static inline int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip,
+					     struct mii_bus *bus,
 					     int addr, int reg, u16 val)
 {
 	return -EOPNOTSUPP;
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index ce8b43b14e96..7d75dd546bf7 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -758,10 +758,12 @@ struct mv88e6xxx_ops {
 
 	int (*set_switch_mac)(struct mv88e6xxx_chip *chip, u8 *addr);
 
-	int (*phy_read)(struct mv88e6xxx_chip *chip, int addr, int reg,
-			u16 *val);
-	int (*phy_write)(struct mv88e6xxx_chip *chip, int addr, int reg,
-			 u16 val);
+	int (*phy_read)(struct mv88e6xxx_chip *chip,
+			struct mii_bus *bus,
+			int addr, int reg, u16 *val);
+	int (*phy_write)(struct mv88e6xxx_chip *chip,
+			 struct mii_bus *bus,
+			 int addr, int reg, u16 val);
 
 	/* PHY Polling Unit (PPU) operations */
 	int (*ppu_enable)(struct mv88e6xxx_chip *chip);
-- 
2.11.0
