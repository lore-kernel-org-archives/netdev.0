From: <shh.xie@gmail.com>
Subject: [PATCH 4/6] [v5] phylib: Add generic 10G driver
Date: Wed, 8 Jan 2014 12:27:56 +0800
Message-ID: <1389155276-16043-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Shaohui.Xie@freescale.com>, Andy Fleming <afleming@gmail.com>
To: <davem@davemloft.net>, <jg1.han@samsung.com>,
	<mugunthanvnm@ti.com>, <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe003.messaging.microsoft.com ([207.46.163.26]:54646
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755149AbaAHF4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 00:56:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@gmail.com>

Very incomplete, but will allow for binding an ethernet controller
to it.

Signed-off-by: Andy Fleming <afleming@gmail.com>
Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
resend for v5.

 drivers/net/phy/phy_device.c | 80 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 80 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 748bf07..439b0d4 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -33,6 +33,7 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/phy.h>
+#include <linux/mdio.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -55,6 +56,7 @@ static void phy_device_release(struct device *dev)
 
 enum genphy_driver {
 	GENPHY_DRV_1G,
+	GENPHY_DRV_10G,
 	GENPHY_DRV_MAX
 };
 
@@ -699,6 +701,12 @@ static int genphy_config_advert(struct phy_device *phydev)
 	return changed;
 }
 
+int gen10g_config_advert(struct phy_device *dev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_config_advert);
+
 /**
  * genphy_setup_forced - configures/forces speed/duplex from @phydev
  * @phydev: target phy_device struct
@@ -752,6 +760,11 @@ int genphy_restart_aneg(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_restart_aneg);
 
+int gen10g_restart_aneg(struct phy_device *phydev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_restart_aneg);
 
 /**
  * genphy_config_aneg - restart auto-negotiation or write BMCR
@@ -794,6 +807,12 @@ int genphy_config_aneg(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_config_aneg);
 
+int gen10g_config_aneg(struct phy_device *phydev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_config_aneg);
+
 /**
  * genphy_update_link - update link status in @phydev
  * @phydev: target phy_device struct
@@ -923,6 +942,34 @@ int genphy_read_status(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_read_status);
 
+int gen10g_read_status(struct phy_device *phydev)
+{
+	int devad, reg;
+	u32 mmd_mask = phydev->c45_ids.devices_in_package;
+
+	phydev->link = 1;
+
+	/* For now just lie and say it's 10G all the time */
+	phydev->speed = SPEED_10000;
+	phydev->duplex = DUPLEX_FULL;
+
+	for (devad = 0; mmd_mask; devad++, mmd_mask = mmd_mask >> 1) {
+		if (!(mmd_mask & 1))
+			continue;
+
+		/* Read twice because link state is latched and a
+		 * read moves the current state into the register
+		 */
+		phy_read_mmd(phydev, devad, MDIO_STAT1);
+		reg = phy_read_mmd(phydev, devad, MDIO_STAT1);
+		if (reg < 0 || !(reg & MDIO_STAT1_LSTATUS))
+			phydev->link = 0;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_read_status);
+
 static int genphy_config_init(struct phy_device *phydev)
 {
 	int val;
@@ -969,6 +1016,16 @@ static int genphy_config_init(struct phy_device *phydev)
 
 	return 0;
 }
+
+static int gen10g_config_init(struct phy_device *phydev)
+{
+	/* Temporarily just say we support everything */
+	phydev->supported = SUPPORTED_10000baseT_Full;
+	phydev->advertising = SUPPORTED_10000baseT_Full;
+
+	return 0;
+}
+
 int genphy_suspend(struct phy_device *phydev)
 {
 	int value;
@@ -984,6 +1041,12 @@ int genphy_suspend(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_suspend);
 
+int gen10g_suspend(struct phy_device *phydev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_suspend);
+
 int genphy_resume(struct phy_device *phydev)
 {
 	int value;
@@ -999,6 +1062,12 @@ int genphy_resume(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_resume);
 
+int gen10g_resume(struct phy_device *phydev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_resume);
+
 /**
  * phy_probe - probe and init a PHY device
  * @dev: device to probe and init
@@ -1138,6 +1207,17 @@ static struct phy_driver genphy_driver[] = {
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= {.owner= THIS_MODULE, },
+}, {
+	.phy_id         = 0xffffffff,
+	.phy_id_mask    = 0xffffffff,
+	.name           = "Generic 10G PHY",
+	.config_init    = gen10g_config_init,
+	.features       = 0,
+	.config_aneg    = gen10g_config_aneg,
+	.read_status    = gen10g_read_status,
+	.suspend        = gen10g_suspend,
+	.resume         = gen10g_resume,
+	.driver         = {.owner = THIS_MODULE, },
 } };
 
 static int __init phy_init(void)
-- 
1.8.4.1
