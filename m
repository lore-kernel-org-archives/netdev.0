From: <shh.xie@gmail.com>
Subject: [PATCH 4/6] [v6] phylib: Add generic 10G driver
Date: Fri, 10 Jan 2014 14:27:37 +0800
Message-ID: <1389335257-32733-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Shaohui.Xie@freescale.com>, Andy Fleming <afleming@gmail.com>
To: <davem@davemloft.net>, <jg1.han@samsung.com>,
	<mugunthanvnm@ti.com>, <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Fleming <afleming@gmail.com>

Very incomplete, but will allow for binding an ethernet controller
to it.

Signed-off-by: Andy Fleming <afleming@gmail.com>
Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
changes for v6:
rebased on top of 'net-next' tree. commit id 11b57f90257c1.

 drivers/net/phy/phy_device.c | 81 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 81 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 1cde2b2..18714fe 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -30,6 +30,7 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/phy.h>
+#include <linux/mdio.h>
 #include <linux/io.h>
 #include <linux/uaccess.h>
 
@@ -52,6 +53,7 @@ static void phy_device_release(struct device *dev)
 
 enum genphy_driver {
 	GENPHY_DRV_1G,
+	GENPHY_DRV_10G,
 	GENPHY_DRV_MAX
 };
 
@@ -769,6 +771,12 @@ static int genphy_config_advert(struct phy_device *phydev)
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
@@ -816,6 +824,12 @@ int genphy_restart_aneg(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_restart_aneg);
 
+int gen10g_restart_aneg(struct phy_device *phydev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_restart_aneg);
+
 /**
  * genphy_config_aneg - restart auto-negotiation or write BMCR
  * @phydev: target phy_device struct
@@ -857,6 +871,12 @@ int genphy_config_aneg(struct phy_device *phydev)
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
@@ -988,6 +1008,34 @@ int genphy_read_status(struct phy_device *phydev)
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
@@ -1033,6 +1081,16 @@ static int genphy_config_init(struct phy_device *phydev)
 
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
@@ -1048,6 +1106,12 @@ int genphy_suspend(struct phy_device *phydev)
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
@@ -1063,6 +1127,12 @@ int genphy_resume(struct phy_device *phydev)
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
@@ -1195,6 +1265,17 @@ static struct phy_driver genphy_driver[] = {
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE, },
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
