From: Alexandr Smirnov <asmirnov@ru.mvista.com>
Subject: [PATCH] Marvell PHY m88e1111 driver fix
Date: Wed, 27 Feb 2008 13:21:18 +0300
Message-ID: <20080227102118.GA29397@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vbordug@ru.mvista.com, afleming@freescale.com, mgreer@mvista.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [212.176.242.38] ([212.176.242.38]:49635 "EHLO spb.rtsoft.ru"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752294AbYB0KTM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 05:19:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All

   Marvell PHY m88e1111 (not sure about other models, but think they too) works
in two modes: fiber and copper. In Marvell PHY driver (that we have in current
community kernels) code supported only copper mode, and this is not
configurable, bits for copper mode are simply written in registers during PHY
initialization. This patch adds support for both modes.

   According to 88e1111 manual: when phy is in copper mode, register 22[7:0] = 0
it selects copper banks of registers: 0, 1, 4, 5, 6, 7, 8, 17, 18, 19; in fiber
mode register 22[7:0] = 1 it selects the same banks of registers. There is no
register 10 (that is used in genphy_read_status() function) in these banks.

   Also as stated in manual register 10 is only for page 0 IOW copper mode, and
in fiber mode it probably contains wrong data (even when 22[7:0] = 1).

   I tested this on several boards on where phy is connected in fiber mode
(SERDES). It doesn't work when genphy_read_status() is used.

   At the moment I'm not sure if there's way of using genphy_read_status()
without any modifications to this function.


Signed-off-by: Alexandr Smirnov <asmirnov@ru.mvista.com>

diff -pruN powerpc.orig/drivers/net/phy/marvell.c powerpc/drivers/net/phy/marvell.c
--- powerpc.orig/drivers/net/phy/marvell.c	2008-02-07 14:59:32.000000000 +0300
+++ powerpc/drivers/net/phy/marvell.c	2008-02-27 12:40:32.000000000 +0300
@@ -58,9 +58,25 @@
 #define MII_M1111_RX_DELAY		0x80
 #define MII_M1111_TX_DELAY		0x2
 #define MII_M1111_PHY_EXT_SR		0x1b
-#define MII_M1111_HWCFG_MODE_MASK	0xf
-#define MII_M1111_HWCFG_MODE_RGMII	0xb
+
+#define MII_M1111_HWCFG_MODE_MASK		0xf
+#define MII_M1111_HWCFG_MODE_COPPER_RGMII	0xb
+#define MII_M1111_HWCFG_MODE_FIBER_RGMII	0x3
 #define MII_M1111_HWCFG_MODE_SGMII_NO_CLK	0x4
+#define MII_M1111_HWCFG_FIBER_COPPER_AUTO	0x8000
+#define MII_M1111_HWCFG_FIBER_COPPER_RES	0x2000
+
+#define MII_M1111_COPPER		0
+#define MII_M1111_FIBER			1
+
+#define MII_M1011_PHY_STATUS		0x11
+#define MII_M1011_PHY_STATUS_1000	0x8000
+#define MII_M1011_PHY_STATUS_100	0x4000
+#define MII_M1011_PHY_STATUS_SPD_MASK	0xc000
+#define MII_M1011_PHY_STATUS_FULLDUPLEX	0x2000
+#define MII_M1011_PHY_STATUS_RESOLVED	0x0800
+#define MII_M1011_PHY_STATUS_LINK	0x0400
+
 
 MODULE_DESCRIPTION("Marvell PHY driver");
 MODULE_AUTHOR("Andy Fleming");
@@ -141,12 +157,22 @@ static int marvell_config_aneg(struct ph
 static int m88e1111_config_init(struct phy_device *phydev)
 {
 	int err;
+	int temp;
+	int mode;
+
+	/* Enable Fiber/Copper auto selection */
+	temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
+	temp |= MII_M1111_HWCFG_FIBER_COPPER_AUTO;
+	phy_write(phydev, MII_M1111_PHY_EXT_SR, temp);
+
+	temp = phy_read(phydev, MII_BMCR);
+	temp |= BMCR_RESET;
+	phy_write(phydev, MII_BMCR, temp);
 
 	if ((phydev->interface == PHY_INTERFACE_MODE_RGMII) ||
 	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) ||
 	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
 	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)) {
-		int temp;
 
 		temp = phy_read(phydev, MII_M1111_PHY_EXT_CR);
 		if (temp < 0)
@@ -171,7 +197,13 @@ static int m88e1111_config_init(struct p
 			return temp;
 
 		temp &= ~(MII_M1111_HWCFG_MODE_MASK);
-		temp |= MII_M1111_HWCFG_MODE_RGMII;
+
+		mode = phy_read(phydev, MII_M1111_PHY_EXT_CR);
+
+		if (mode & MII_M1111_HWCFG_FIBER_COPPER_RES)
+			temp |= MII_M1111_HWCFG_MODE_FIBER_RGMII;
+		else
+			temp |= MII_M1111_HWCFG_MODE_COPPER_RGMII;
 
 		err = phy_write(phydev, MII_M1111_PHY_EXT_SR, temp);
 		if (err < 0)
@@ -262,6 +294,93 @@ static int m88e1145_config_init(struct p
 	return 0;
 }
 
+/* marvell_read_status
+ *
+ * Generic status code does not detect Fiber correctly!
+ * Description: 
+ *   Check the link, then figure out the current state
+ *   by comparing what we advertise with what the link partner
+ *   advertises.  Start by checking the gigabit possibilities,
+ *   then move on to 10/100.
+ */
+static int marvell_read_status(struct phy_device *phydev)
+{
+	int adv;
+	int err;
+	int lpa;
+	int status = 0;
+
+	/* Update the link, but return if there
+	 * was an error */
+	err = genphy_update_link(phydev);
+	if (err)
+		return err;
+
+	if (AUTONEG_ENABLE == phydev->autoneg) {
+		status = phy_read(phydev, MII_M1011_PHY_STATUS);
+		if (status < 0)
+			return status;
+
+		lpa = phy_read(phydev, MII_LPA);
+		if (lpa < 0)
+			return lpa;
+
+		adv = phy_read(phydev, MII_ADVERTISE);
+		if (adv < 0)
+			return adv;
+
+		lpa &= adv;
+
+		if (status & MII_M1011_PHY_STATUS_FULLDUPLEX)
+			phydev->duplex = DUPLEX_FULL;
+		else
+			phydev->duplex = DUPLEX_HALF;
+
+		status = status & MII_M1011_PHY_STATUS_SPD_MASK;
+		phydev->pause = phydev->asym_pause = 0;
+
+		switch (status) {
+		case MII_M1011_PHY_STATUS_1000:
+			phydev->speed = SPEED_1000;
+			break;
+
+		case MII_M1011_PHY_STATUS_100:
+			phydev->speed = SPEED_100;
+			break;
+
+		default:
+			phydev->speed = SPEED_10;
+			break;
+		}
+
+		if (phydev->duplex == DUPLEX_FULL) {
+			phydev->pause = lpa & LPA_PAUSE_CAP ? 1 : 0;
+			phydev->asym_pause = lpa & LPA_PAUSE_ASYM ? 1 : 0;
+		}
+	} else {
+		int bmcr = phy_read(phydev, MII_BMCR);
+
+		if (bmcr < 0)
+			return bmcr;
+
+		if (bmcr & BMCR_FULLDPLX)
+			phydev->duplex = DUPLEX_FULL;
+		else
+			phydev->duplex = DUPLEX_HALF;
+
+		if (bmcr & BMCR_SPEED1000)
+			phydev->speed = SPEED_1000;
+		else if (bmcr & BMCR_SPEED100)
+			phydev->speed = SPEED_100;
+		else
+			phydev->speed = SPEED_10;
+
+		phydev->pause = phydev->asym_pause = 0;
+	}
+
+	return 0;
+}
+
 static struct phy_driver marvell_drivers[] = {
 	{
 		.phy_id = 0x01410c60,
@@ -296,7 +415,7 @@ static struct phy_driver marvell_drivers
 		.flags = PHY_HAS_INTERRUPT,
 		.config_init = &m88e1111_config_init,
 		.config_aneg = &marvell_config_aneg,
-		.read_status = &genphy_read_status,
+		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
 		.driver = { .owner = THIS_MODULE },
