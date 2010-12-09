From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] phy: add the IC+ IP1001 driver
Date: Thu, 9 Dec 2010 10:05:13 +0100
Message-ID: <1291885513-32766-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Peppe CAVALLARO <peppe.cavallaro@st.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:44524 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754914Ab0LIJYn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 04:24:43 -0500
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 6E40A19D
	for <netdev@vger.kernel.org>; Thu,  9 Dec 2010 09:24:36 +0000 (GMT)
Received: from Webmail-eu.st.com (safex1hubcas1.st.com [10.75.90.14])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 7D1C9C35
	for <netdev@vger.kernel.org>; Thu,  9 Dec 2010 09:24:04 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the IC+ IP1001 (Gigabit Ethernet Transceiver) driver.
I've had to add an additional delay (2ns) to adjust RX clock phase at
GMII/ RGMII interface (according to the PHY data-sheet). This helps to
have the RGMII working on some ST platforms.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/Kconfig  |    2 +-
 drivers/net/phy/icplus.c |   59 ++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 55 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index cb3d13e..35fda5a 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -64,7 +64,7 @@ config BCM63XX_PHY
 config ICPLUS_PHY
 	tristate "Drivers for ICPlus PHYs"
 	---help---
-	  Currently supports the IP175C PHY.
+	  Currently supports the IP175C and IP1001 PHYs.
 
 config REALTEK_PHY
 	tristate "Drivers for Realtek PHYs"
diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index c1d2d25..9a09e24 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -30,7 +30,7 @@
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 
-MODULE_DESCRIPTION("ICPlus IP175C PHY driver");
+MODULE_DESCRIPTION("ICPlus IP175C/IC1001 PHY drivers");
 MODULE_AUTHOR("Michael Barkowski");
 MODULE_LICENSE("GPL");
 
@@ -89,6 +89,33 @@ static int ip175c_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int ip1001_config_init(struct phy_device *phydev)
+{
+	int err, value;
+
+	/* Software Reset PHY */
+	value = phy_read(phydev, MII_BMCR);
+	value |= BMCR_RESET;
+	err = phy_write(phydev, MII_BMCR, value);
+	if (err < 0)
+		return err;
+
+	do {
+		value = phy_read(phydev, MII_BMCR);
+	} while (value & BMCR_RESET);
+
+	/* Additional delay (2ns) used to adjust RX clock phase
+	 * at GMII/ RGMII interface */
+	value = phy_read(phydev, 16);
+	value |= 0x3;
+
+	err = phy_write(phydev, 16, value);
+	if (err < 0)
+		return err;
+
+	return err;
+}
+
 static int ip175c_read_status(struct phy_device *phydev)
 {
 	if (phydev->addr == 4) /* WAN port */
@@ -121,21 +148,43 @@ static struct phy_driver ip175c_driver = {
 	.driver		= { .owner = THIS_MODULE,},
 };
 
-static int __init ip175c_init(void)
+static struct phy_driver ip1001_driver = {
+	.phy_id		= 0x02430d90,
+	.name		= "ICPlus IP1001",
+	.phy_id_mask	= 0x0ffffff0,
+	.features	= PHY_GBIT_FEATURES | SUPPORTED_Pause |
+			  SUPPORTED_Asym_Pause,
+	.config_init	= &ip1001_config_init,
+	.config_aneg	= &genphy_config_aneg,
+	.read_status	= &genphy_read_status,
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
+	.driver		= { .owner = THIS_MODULE,},
+};
+
+static int __init icplus_init(void)
 {
+	int ret = 0;
+
+	ret = phy_driver_register(&ip1001_driver);
+	if (ret < 0)
+		return -ENODEV;
+
 	return phy_driver_register(&ip175c_driver);
 }
 
-static void __exit ip175c_exit(void)
+static void __exit icplus_exit(void)
 {
+	phy_driver_unregister(&ip1001_driver);
 	phy_driver_unregister(&ip175c_driver);
 }
 
-module_init(ip175c_init);
-module_exit(ip175c_exit);
+module_init(icplus_init);
+module_exit(icplus_exit);
 
 static struct mdio_device_id __maybe_unused icplus_tbl[] = {
 	{ 0x02430d80, 0x0ffffff0 },
+	{ 0x02430d90, 0x0ffffff0 },
 	{ }
 };
 
-- 
1.5.5.6
