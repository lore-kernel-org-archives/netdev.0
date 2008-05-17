From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH v4] PHYLIB: Add 1000Base-X support for Broadcom bcm5482
Date: Sat, 17 May 2008 06:40:39 +0100 (BST)
Message-ID: <Pine.LNX.4.55.0805170619390.4049@cliff.in.clinika.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, Nate Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirk.serum.com.pl ([213.77.9.205]:62730 "EHLO serum.com.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750937AbYEQFlC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 May 2008 01:41:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nate Case <ncase@xes-inc.com>

Configure the BCM5482S secondary SerDes for 1000Base-X mode when the
appropriate dev_flags are passed in to phy_connect().  This is
needed when the PHY is used for fiber and backplane connections.

Signed-off-by: Nate Case <ncase@xes-inc.com>
Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
Jeff,

 I have removed unnecessary "inline" annotations and made a few formatting
adjustments.  I hope Nate agrees with these changes.  Please apply.

  Maciej

diff -up --recursive --new-file linux-2.6.26-rc1-20080505.macro/drivers/net/phy/broadcom.c linux-2.6.26-rc1-20080505/drivers/net/phy/broadcom.c
--- linux-2.6.26-rc1-20080505.macro/drivers/net/phy/broadcom.c	2008-05-05 02:55:39.000000000 +0000
+++ linux-2.6.26-rc1-20080505/drivers/net/phy/broadcom.c	2008-05-16 23:09:23.000000000 +0000
@@ -24,6 +24,12 @@
 #define MII_BCM54XX_ESR		0x11	/* BCM54xx extended status register */
 #define MII_BCM54XX_ESR_IS	0x1000	/* Interrupt status */
 
+#define MII_BCM54XX_EXP_DATA	0x15	/* Expansion register data */
+#define MII_BCM54XX_EXP_SEL	0x17	/* Expansion register select */
+#define MII_BCM54XX_EXP_SEL_SSD	0x0e00	/* Secondary SerDes select */
+#define MII_BCM54XX_EXP_SEL_ER	0x0f00	/* Expansion register select */
+
+#define MII_BCM54XX_AUX_CTL	0x18	/* Auxiliary control register */
 #define MII_BCM54XX_ISR		0x1a	/* BCM54xx interrupt status register */
 #define MII_BCM54XX_IMR		0x1b	/* BCM54xx interrupt mask register */
 #define MII_BCM54XX_INT_CRCERR	0x0001	/* CRC error */
@@ -42,10 +48,120 @@
 #define MII_BCM54XX_INT_MDIX	0x2000	/* MDIX status change */
 #define MII_BCM54XX_INT_PSERR	0x4000	/* Pair swap error */
 
+#define MII_BCM54XX_SHD		0x1c	/* 0x1c shadow registers */
+#define MII_BCM54XX_SHD_WRITE	0x8000
+#define MII_BCM54XX_SHD_VAL(x)	((x & 0x1f) << 10)
+#define MII_BCM54XX_SHD_DATA(x)	((x & 0x3ff) << 0)
+
+/*
+ * Broadcom LED source encodings.  These are used in BCM5461, BCM5481,
+ * BCM5482, and possibly some others.
+ */
+#define BCM_LED_SRC_LINKSPD1	0x0
+#define BCM_LED_SRC_LINKSPD2	0x1
+#define BCM_LED_SRC_XMITLED	0x2
+#define BCM_LED_SRC_ACTIVITYLED	0x3
+#define BCM_LED_SRC_FDXLED	0x4
+#define BCM_LED_SRC_SLAVE	0x5
+#define BCM_LED_SRC_INTR	0x6
+#define BCM_LED_SRC_QUALITY	0x7
+#define BCM_LED_SRC_RCVLED	0x8
+#define BCM_LED_SRC_MULTICOLOR1	0xa
+#define BCM_LED_SRC_OPENSHORT	0xb
+#define BCM_LED_SRC_OFF		0xe	/* Tied high */
+#define BCM_LED_SRC_ON		0xf	/* Tied low */
+
+/*
+ * BCM5482: Shadow registers
+ * Shadow values go into bits [14:10] of register 0x1c to select a shadow
+ * register to access.
+ */
+#define BCM5482_SHD_LEDS1	0x0d	/* 01101: LED Selector 1 */
+					/* LED3 / ~LINKSPD[2] selector */
+#define BCM5482_SHD_LEDS1_LED3(src)	((src & 0xf) << 4)
+					/* LED1 / ~LINKSPD[1] selector */
+#define BCM5482_SHD_LEDS1_LED1(src)	((src & 0xf) << 0)
+#define BCM5482_SHD_SSD		0x14	/* 10100: Secondary SerDes control */
+#define BCM5482_SHD_SSD_LEDM	0x0008	/* SSD LED Mode enable */
+#define BCM5482_SHD_SSD_EN	0x0001	/* SSD enable */
+#define BCM5482_SHD_MODE	0x1f	/* 11111: Mode Control Register */
+#define BCM5482_SHD_MODE_1000BX	0x0001	/* Enable 1000BASE-X registers */
+
+/*
+ * BCM5482: Secondary SerDes registers
+ */
+#define BCM5482_SSD_1000BX_CTL		0x00	/* 1000BASE-X Control */
+#define BCM5482_SSD_1000BX_CTL_PWRDOWN	0x0800	/* Power-down SSD */
+#define BCM5482_SSD_SGMII_SLAVE		0x15	/* SGMII Slave Register */
+#define BCM5482_SSD_SGMII_SLAVE_EN	0x0002	/* Slave mode enable */
+#define BCM5482_SSD_SGMII_SLAVE_AD	0x0001	/* Slave auto-detection */
+
+/*
+ * Device flags for PHYs that can be configured for different operating
+ * modes.
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
+ * 0x1c shadow registers.
+ */
+static int bcm54xx_shadow_read(struct phy_device *phydev, u16 shadow)
+{
+	phy_write(phydev, MII_BCM54XX_SHD, MII_BCM54XX_SHD_VAL(shadow));
+	return MII_BCM54XX_SHD_DATA(phy_read(phydev, MII_BCM54XX_SHD));
+}
+
+static int bcm54xx_shadow_write(struct phy_device *phydev, u16 shadow, u16 val)
+{
+	return phy_write(phydev, MII_BCM54XX_SHD,
+			 MII_BCM54XX_SHD_WRITE |
+			 MII_BCM54XX_SHD_VAL(shadow) |
+			 MII_BCM54XX_SHD_DATA(val));
+}
+
+/*
+ * Indirect register access functions for the Expansion Registers
+ * and Secondary SerDes registers (when sec_serdes=1).
+ */
+static int bcm54xx_exp_read(struct phy_device *phydev,
+			    int sec_serdes, u8 regnum)
+{
+	int val;
+
+	phy_write(phydev, MII_BCM54XX_EXP_SEL,
+		  (sec_serdes ? MII_BCM54XX_EXP_SEL_SSD :
+				MII_BCM54XX_EXP_SEL_ER) |
+		  regnum);
+	val = phy_read(phydev, MII_BCM54XX_EXP_DATA);
+	phy_write(phydev, MII_BCM54XX_EXP_SEL, regnum);
+
+	return val;
+}
+
+static int bcm54xx_exp_write(struct phy_device *phydev,
+			     int sec_serdes, u8 regnum, u16 val)
+{
+	int ret;
+
+	phy_write(phydev, MII_BCM54XX_EXP_SEL,
+		  (sec_serdes ? MII_BCM54XX_EXP_SEL_SSD :
+				MII_BCM54XX_EXP_SEL_ER) |
+		  regnum);
+	ret = phy_write(phydev, MII_BCM54XX_EXP_DATA, val);
+	phy_write(phydev, MII_BCM54XX_EXP_SEL, regnum);
+
+	return ret;
+}
+
 static int bcm54xx_config_init(struct phy_device *phydev)
 {
 	int reg, err;
@@ -70,6 +186,87 @@ static int bcm54xx_config_init(struct ph
 	return 0;
 }
 
+static int bcm5482_config_init(struct phy_device *phydev)
+{
+	int err, reg;
+
+	err = bcm54xx_config_init(phydev);
+
+	if (phydev->dev_flags & PHY_BCM_FLAGS_MODE_1000BX) {
+		/*
+		 * Enable secondary SerDes and its use as an LED source
+		 */
+		reg = bcm54xx_shadow_read(phydev, BCM5482_SHD_SSD);
+		bcm54xx_shadow_write(phydev, BCM5482_SHD_SSD,
+				     reg |
+				     BCM5482_SHD_SSD_LEDM |
+				     BCM5482_SHD_SSD_EN);
+
+		/*
+		 * Enable SGMII slave mode and auto-detection
+		 */
+		reg = bcm54xx_exp_read(phydev, 1, BCM5482_SSD_SGMII_SLAVE);
+		bcm54xx_exp_write(phydev, 1, BCM5482_SSD_SGMII_SLAVE,
+				  reg |
+				  BCM5482_SSD_SGMII_SLAVE_EN |
+				  BCM5482_SSD_SGMII_SLAVE_AD);
+
+		/*
+		 * Disable secondary SerDes powerdown
+		 */
+		reg = bcm54xx_exp_read(phydev, 1, BCM5482_SSD_1000BX_CTL);
+		bcm54xx_exp_write(phydev, 1, BCM5482_SSD_1000BX_CTL,
+				  reg & ~BCM5482_SSD_1000BX_CTL_PWRDOWN);
+
+		/*
+		 * Select 1000BASE-X register set (primary SerDes)
+		 */
+		reg = bcm54xx_shadow_read(phydev, BCM5482_SHD_MODE);
+		bcm54xx_shadow_write(phydev, BCM5482_SHD_MODE,
+				     reg | BCM5482_SHD_MODE_1000BX);
+
+		/*
+		 * LED1=ACTIVITYLED, LED3=LINKSPD[2]
+		 * (Use LED1 as secondary SerDes ACTIVITY LED)
+		 */
+		bcm54xx_shadow_write(phydev, BCM5482_SHD_LEDS1,
+			BCM5482_SHD_LEDS1_LED1(BCM_LED_SRC_ACTIVITYLED) |
+			BCM5482_SHD_LEDS1_LED3(BCM_LED_SRC_LINKSPD2));
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
@@ -210,9 +407,9 @@ static struct phy_driver bcm5482_driver 
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
