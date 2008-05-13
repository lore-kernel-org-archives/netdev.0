From: Nate Case <ncase@xes-inc.com>
Subject: [PATCH] PHYLIB: Add 1000Base-X support for Broadcom bcm5482
Date: Tue, 13 May 2008 11:16:18 -0500
Message-ID: <1210695378.13845.362.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xes-mad.com ([216.165.139.214]:51341 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757458AbYEMRIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 13:08:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Configure the BCM5482S secondary SerDes for 1000Base-X mode when the
appropriate dev_flags are passed in to phy_connect().  This is
needed when the PHY is used for fiber and backplane connections.

Signed-off-by: Nate Case <ncase@xes-inc.com>
---
Note: This contains a few "magic" numbers/bits which are documented
in the comments.  I neglected making #defines for all of these to
keep the change size down, but I'm willing to make them if people want
it enough.  Most are probably 5482 specific.

 drivers/net/phy/broadcom.c |  153 +++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 151 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 60c5cfe..a0ccb96 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -42,10 +42,83 @@
 #define MII_BCM54XX_INT_MDIX	0x2000	/* MDIX status change */
 #define MII_BCM54XX_INT_PSERR	0x4000	/* Pair swap error */
 
+#define MII_BCM54XX_RSV0	0x15	/* Reserved / Expansion registers */
+#define MII_BCM54XX_EXP		0x17	/* Expansion register access */
+#define MII_BCM54XX_EXP_SSD	0x0e00	/* Secondary SerDes select */
+#define MII_BCM54XX_EXP_ER	0x0f00	/* Expansion register select */
+#define MII_BCM54XX_EXP_NONE	0x0000	/* Exp register not selected */
+
+#define MII_BCM54XX_AUX_CTL	0x18
+
+#define MII_BCM54XX_SHD		0x1c	/* 0x1c shadow registers */
+#define MII_BCM54XX_SHD_WRITE	0x8000
+#define MII_BCM54XX_SHD_VAL(x)	((x & 0x1f) << 10)
+#define MII_BCM54XX_SHD_DATA(x)	((x & 0x3ff) << 0)
+
+/*
+ * Device flags for PHYs that can be configured for different operating
+ * modes
+ */
+#define PHY_BCM_FLAGS_VALID		0x80000000
+#define PHY_BCM_FLAGS_INTF_XAUI		0x00000020
+#define PHY_BCM_FLAGS_INTF_SGMII	0x00000010
+#define PHY_BCM_FLAGS_MODE_1000BX	0x00000002
+#define PHY_BCM_FLAGS_MODE_COPPER	0x00000001
+
 MODULE_DESCRIPTION("Broadcom PHY driver");
 MODULE_AUTHOR("Maciej W. Rozycki");
 MODULE_LICENSE("GPL");
 
+/*
+ * Indirect register access functions for the 1000BASE-T/100BASE-TX/10BASE-T
+ * 0x1c shadow registers
+ */
+static inline int
+bcm54xx_shadow_read(struct phy_device *phydev, u16 shadow)
+{
+	phy_write(phydev, MII_BCM54XX_SHD, MII_BCM54XX_SHD_VAL(shadow));
+	return MII_BCM54XX_SHD_DATA(phy_read(phydev, MII_BCM54XX_SHD));
+}
+
+static inline int
+bcm54xx_shadow_write(struct phy_device *phydev, u16 shadow, u16 val)
+{
+	return phy_write(phydev, MII_BCM54XX_SHD, MII_BCM54XX_SHD_WRITE
+		| MII_BCM54XX_SHD_VAL(shadow)
+		| MII_BCM54XX_SHD_DATA(val));
+}
+
+/*
+ * Indirect register access functions for the Expansion Registers
+ */
+static inline int
+bcm54xx_exp_read(struct phy_device *phydev, int sec_serdes, u8 regnum)
+{
+	int val;
+
+	phy_write(phydev, MII_BCM54XX_EXP,
+			(sec_serdes ? MII_BCM54XX_EXP_SSD : MII_BCM54XX_EXP_ER)
+			| regnum);
+	val = phy_read(phydev, MII_BCM54XX_RSV0);
+	phy_write(phydev, MII_BCM54XX_EXP, MII_BCM54XX_EXP_NONE | regnum);
+
+	return val;
+}
+
+static inline int
+bcm54xx_exp_write(struct phy_device *phydev, int sec_serdes, u8 regnum, u16 val)
+{
+	int ret;
+
+	phy_write(phydev, MII_BCM54XX_EXP,
+			(sec_serdes ? MII_BCM54XX_EXP_SSD : MII_BCM54XX_EXP_ER)
+			| regnum);
+	ret = phy_write(phydev, MII_BCM54XX_RSV0, val);
+	phy_write(phydev, MII_BCM54XX_EXP, MII_BCM54XX_EXP_NONE | regnum);
+
+	return ret;
+}
+
 static int bcm54xx_config_init(struct phy_device *phydev)
 {
 	int reg, err;
@@ -70,6 +143,82 @@ static int bcm54xx_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int bcm5482_config_init(struct phy_device *phydev)
+{
+	int err;
+
+	err = bcm54xx_config_init(phydev);
+
+	if (phydev->dev_flags & PHY_BCM_FLAGS_MODE_1000BX) {
+		/*
+		 * Secondary SerDes control (shadow 10100):
+		 *   Enable secondary SerDes and its use as an LED source
+		 */
+		bcm54xx_shadow_write(phydev, 0x14,
+			bcm54xx_shadow_read(phydev, 0x14) | 0x9);
+
+		/*
+		 * Secondary SerDes SGMII Slave (0x15):
+		 *   Enable SGMII slave mode and auto-detection
+		 */
+		bcm54xx_exp_write(phydev, 1, 0x15,
+			bcm54xx_exp_read(phydev, 1, 0x15) | 0x3);
+
+		/*
+		 * Secondary SerDes MII control (0x00):
+		 *   Disable secondary SerDes powerdown
+		 */
+		bcm54xx_exp_write(phydev, 1, 0x00,
+			bcm54xx_exp_read(phydev, 1, 0x00) & ~0x0800);
+
+		/*
+		 * Mode Control register (shadow 11111):
+		 *   Select 1000BASE-X register set (primary SerDes)
+		 */
+		bcm54xx_shadow_write(phydev, 0x1f,
+			bcm54xx_shadow_read(phydev, 0x1f) | 0x1);
+
+		/*
+		 * LED selector 1 register (shadow 01101):
+		 *   LED1=ACTIVITYLED, LED3=LINKSPD[2]
+		 *   (Use LED1 as secondary SerDes ACTIVITY LED)
+		 */
+		bcm54xx_shadow_write(phydev, 0x0d, 0x013);
+
+		/*
+		 * Auto-negotiation doesn't seem to work quite right
+		 * in this mode, so we disable it and force it to the
+		 * right speed/duplex setting.  Only 'link status'
+		 * is important.
+		 */
+		phydev->autoneg = AUTONEG_DISABLE;
+		phydev->speed = SPEED_1000;
+		phydev->duplex = DUPLEX_FULL;
+	}
+
+	return err;
+}
+
+static int bcm5482_read_status(struct phy_device *phydev)
+{
+	int err;
+
+	err = genphy_read_status(phydev);
+
+	if (phydev->dev_flags & PHY_BCM_FLAGS_MODE_1000BX) {
+		/*
+		 * Only link status matters for 1000Base-X mode, so force
+		 * 1000 Mbit/s full-duplex status
+		 */
+		if (phydev->link) {
+			phydev->speed = SPEED_1000;
+			phydev->duplex = DUPLEX_FULL;
+		}
+	}
+
+	return err;
+}
+
 static int bcm54xx_ack_interrupt(struct phy_device *phydev)
 {
 	int reg;
@@ -210,9 +359,9 @@ static struct phy_driver bcm5482_driver = {
 	.name		= "Broadcom BCM5482",
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= bcm54xx_config_init,
+	.config_init	= bcm5482_config_init,
 	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
+	.read_status	= bcm5482_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver 	= { .owner = THIS_MODULE },
-- 
1.5.4.4



