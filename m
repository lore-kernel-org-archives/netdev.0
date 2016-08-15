From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/6] net: dsa: mv88e6xxx: describe PHY page and SerDes
Date: Mon, 15 Aug 2016 17:19:01 -0400
Message-ID: <20160815211902.2236-6-vivien.didelot@savoirfairelinux.com>
References: <20160815211902.2236-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40015 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932289AbcHOVUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 17:20:43 -0400
In-Reply-To: <20160815211902.2236-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add mv88e6xxx_phy_page_{read,write} routines and use them to access the
SerDes PHY device registers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 95 +++++++++++++++++++++++++++++------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 27 ++++++++--
 2 files changed, 105 insertions(+), 17 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 3b0bc88..faa0751 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -238,6 +238,74 @@ static int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
 	return chip->phy_ops->write(chip, addr, reg, val);
 }
 
+static int mv88e6xxx_phy_page_get(struct mv88e6xxx_chip *chip, int phy, u8 page)
+{
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_PHY_PAGE))
+		return -EOPNOTSUPP;
+
+	return mv88e6xxx_phy_write(chip, phy, PHY_PAGE, page);
+}
+
+static void mv88e6xxx_phy_page_put(struct mv88e6xxx_chip *chip, int phy)
+{
+	int err;
+
+	/* Restore PHY page Copper 0x0 for access via the registered MDIO bus */
+	err = mv88e6xxx_phy_write(chip, phy, PHY_PAGE, PHY_PAGE_COPPER);
+	if (unlikely(err)) {
+		dev_err(chip->dev, "failed to restore PHY %d page Copper (%d)\n",
+			phy, err);
+	}
+}
+
+static int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
+				   u8 page, int reg, u16 *val)
+{
+	int err;
+
+	/* There is no paging for registers 22 */
+	if (reg == PHY_PAGE)
+		return -EINVAL;
+
+	err = mv88e6xxx_phy_page_get(chip, phy, page);
+	if (!err) {
+		err = mv88e6xxx_phy_read(chip, phy, reg, val);
+		mv88e6xxx_phy_page_put(chip, phy);
+	}
+
+	return err;
+}
+
+static int mv88e6xxx_phy_page_write(struct mv88e6xxx_chip *chip, int phy,
+				    u8 page, int reg, u16 val)
+{
+	int err;
+
+	/* There is no paging for registers 22 */
+	if (reg == PHY_PAGE)
+		return -EINVAL;
+
+	err = mv88e6xxx_phy_page_get(chip, phy, page);
+	if (!err) {
+		err = mv88e6xxx_phy_write(chip, phy, PHY_PAGE, page);
+		mv88e6xxx_phy_page_put(chip, phy);
+	}
+
+	return err;
+}
+
+static int mv88e6xxx_serdes_read(struct mv88e6xxx_chip *chip, int reg, u16 *val)
+{
+	return mv88e6xxx_phy_page_read(chip, ADDR_SERDES, SERDES_PAGE_FIBER,
+				       reg, val);
+}
+
+static int mv88e6xxx_serdes_write(struct mv88e6xxx_chip *chip, int reg, u16 val)
+{
+	return mv88e6xxx_phy_page_write(chip, ADDR_SERDES, SERDES_PAGE_FIBER,
+					reg, val);
+}
+
 static int mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int addr, int reg,
 			  u16 mask)
 {
@@ -2408,23 +2476,22 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 	return ret;
 }
 
-static int mv88e6xxx_power_on_serdes(struct mv88e6xxx_chip *chip)
+static int mv88e6xxx_serdes_power_on(struct mv88e6xxx_chip *chip)
 {
-	int ret;
+	u16 val;
+	int err;
 
-	ret = _mv88e6xxx_mdio_page_read(chip, REG_FIBER_SERDES,
-					PAGE_FIBER_SERDES, MII_BMCR);
-	if (ret < 0)
-		return ret;
+	/* Clear Power Down bit */
+	err = mv88e6xxx_serdes_read(chip, MII_BMCR, &val);
+	if (err)
+		return err;
 
-	if (ret & BMCR_PDOWN) {
-		ret &= ~BMCR_PDOWN;
-		ret = _mv88e6xxx_mdio_page_write(chip, REG_FIBER_SERDES,
-						 PAGE_FIBER_SERDES, MII_BMCR,
-						 ret);
+	if (val & BMCR_PDOWN) {
+		val &= ~BMCR_PDOWN;
+		err = mv88e6xxx_serdes_write(chip, MII_BMCR, val);
 	}
 
-	return ret;
+	return err;
 }
 
 static int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port,
@@ -2547,7 +2614,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	/* If this port is connected to a SerDes, make sure the SerDes is not
 	 * powered down.
 	 */
-	if (mv88e6xxx_6352_family(chip)) {
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_SERDES)) {
 		ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_STATUS);
 		if (ret < 0)
 			return ret;
@@ -2555,7 +2622,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 		if ((ret == PORT_STATUS_CMODE_100BASE_X) ||
 		    (ret == PORT_STATUS_CMODE_1000BASE_X) ||
 		    (ret == PORT_STATUS_CMODE_SGMII)) {
-			ret = mv88e6xxx_power_on_serdes(chip);
+			ret = mv88e6xxx_serdes_power_on(chip);
 			if (ret < 0)
 				return ret;
 		}
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 1dd96e7..1f9bab5 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -30,9 +30,12 @@
 #define SMI_CMD_OP_45_READ_DATA_INC	((3 << 10) | SMI_CMD_BUSY)
 #define SMI_DATA		0x01
 
-/* Fiber/SERDES Registers are located at SMI address F, page 1 */
-#define REG_FIBER_SERDES	0x0f
-#define PAGE_FIBER_SERDES	0x01
+/* PHY Registers */
+#define PHY_PAGE		0x16
+#define PHY_PAGE_COPPER		0x00
+
+#define ADDR_SERDES		0x0f
+#define SERDES_PAGE_FIBER	0x01
 
 #define REG_PORT(p)		(0x10 + (p))
 #define PORT_STATUS		0x00
@@ -394,6 +397,14 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_SMI_CMD,		/* (0x00) SMI Command */
 	MV88E6XXX_CAP_SMI_DATA,		/* (0x01) SMI Data */
 
+	/* PHY Registers.
+	 */
+	MV88E6XXX_CAP_PHY_PAGE,		/* (0x16) Page Register */
+
+	/* Fiber/SERDES Registers (SMI address F).
+	 */
+	MV88E6XXX_CAP_SERDES,
+
 	/* Switch Global 2 Registers.
 	 * The device contains a second set of global 16-bit registers.
 	 */
@@ -441,6 +452,10 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_SMI_CMD		BIT(MV88E6XXX_CAP_SMI_CMD)
 #define MV88E6XXX_FLAG_SMI_DATA		BIT(MV88E6XXX_CAP_SMI_DATA)
 
+#define MV88E6XXX_FLAG_PHY_PAGE		BIT(MV88E6XXX_CAP_PHY_PAGE)
+
+#define MV88E6XXX_FLAG_SERDES		BIT(MV88E6XXX_CAP_SERDES)
+
 #define MV88E6XXX_FLAG_GLOBAL2		BIT(MV88E6XXX_CAP_GLOBAL2)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_2X	BIT(MV88E6XXX_CAP_G2_MGMT_EN_2X)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_0X	BIT(MV88E6XXX_CAP_G2_MGMT_EN_0X)
@@ -482,6 +497,11 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_G2_PVT_ADDR |	\
 	 MV88E6XXX_FLAG_G2_PVT_DATA)
 
+/* Fiber/SERDES Registers at SMI address F, page 1 */
+#define MV88E6XXX_FLAGS_SERDES		\
+	(MV88E6XXX_FLAG_PHY_PAGE |	\
+	 MV88E6XXX_FLAG_SERDES)
+
 /* Indirect PHY access via Global2 SMI PHY registers */
 #define MV88E6XXX_FLAGS_SMI_PHY		\
 	(MV88E6XXX_FLAG_G2_SMI_PHY_CMD |\
@@ -574,6 +594,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAGS_PVT |		\
+	 MV88E6XXX_FLAGS_SERDES |	\
 	 MV88E6XXX_FLAGS_SMI_PHY)
 
 struct mv88e6xxx_info {
-- 
2.9.3
