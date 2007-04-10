From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH] Add support for running the Marvell m88e1111 PHY in RGMII
 mode
Date: Tue, 10 Apr 2007 16:57:23 -0500
Message-ID: <20070410165723.472fdc69.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:57110 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753925AbXDJV5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 17:57:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

also adds RX & TX delay bits to help boards with clock skew problems.

Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
please consider for 2.6.22

 drivers/net/phy/marvell.c |   43 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 22aec5c..0b2d4db 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -54,6 +54,12 @@
 #define MII_M1111_PHY_LED_CONTROL	0x18
 #define MII_M1111_PHY_LED_DIRECT	0x4100
 #define MII_M1111_PHY_LED_COMBINE	0x411c
+#define MII_M1111_PHY_EXT_CR		0x14
+#define MII_M1111_RX_DELAY		0x80
+#define MII_M1111_TX_DELAY		0x2
+#define MII_M1111_PHY_EXT_SR		0x1b
+#define MII_M1111_HWCFG_MODE_MASK	0xf
+#define MII_M1111_HWCFG_MODE_RGMII	0xb
 
 MODULE_DESCRIPTION("Marvell PHY driver");
 MODULE_AUTHOR("Andy Fleming");
@@ -131,6 +137,42 @@ static int marvell_config_aneg(struct phy_device *phydev)
 	return err;
 }
 
+static int m88e1111_config_init(struct phy_device *phydev)
+{
+	int err;
+
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII) {
+		int temp;
+
+		temp = phy_read(phydev, MII_M1111_PHY_EXT_CR);
+		if (temp < 0)
+			return temp;
+
+		temp |= (MII_M1111_RX_DELAY | MII_M1111_TX_DELAY);
+
+		err = phy_write(phydev, MII_M1111_PHY_EXT_CR, temp);
+		if (err < 0)
+			return err;
+
+		temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
+		if (temp < 0)
+			return temp;
+
+		temp &= ~(MII_M1111_HWCFG_MODE_MASK);
+		temp |= MII_M1111_HWCFG_MODE_RGMII;
+
+		err = phy_write(phydev, MII_M1111_PHY_EXT_SR, temp);
+		if (err < 0)
+			return err;
+	}
+
+	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
 static int m88e1145_config_init(struct phy_device *phydev)
 {
 	int err;
@@ -216,6 +258,7 @@ static struct phy_driver m88e1111s_driver = {
 	.read_status = &genphy_read_status,
 	.ack_interrupt = &marvell_ack_interrupt,
 	.config_intr = &marvell_config_intr,
+	.config_init = &m88e1111_config_init,
 	.driver = {.owner = THIS_MODULE,},
 };
 
-- 
1.5.0.1

