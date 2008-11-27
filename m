From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] phy: power management support
Date: Thu, 27 Nov 2008 14:57:00 +0100
Message-ID: <1227794220-19872-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:50792 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752604AbYK0N5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 08:57:32 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id DEC4ADB61
	for <netdev@vger.kernel.org>; Thu, 27 Nov 2008 13:57:18 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 84C984C270
	for <netdev@vger.kernel.org>; Thu, 27 Nov 2008 13:57:18 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the power management support into the physical
abstraction layer.

Suspend and resume functions respectively turns on/off the bit 11
into the PHY Basic mode control register.
Generic PHY device starts supporting PM.

In order to support the wake-on LAN and avoid to put in power down
the PHY device, the MDIO is aware of what the Ethernet device wants to do.

Voluntary, no CONFIG_PM defines were added into the sources.
Also generic suspend/resume functions are exported to allow
other drivers use them (such as genphy_config_aneg etc.).

Within the phy_driver_register function, we need to remove the
memset. It overrides the device driver owner and it is not good.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/mdio_bus.c   |   14 ++++++++++----
 drivers/net/phy/phy_device.c |   31 ++++++++++++++++++++++++++++++-
 include/linux/phy.h          |    2 ++
 3 files changed, 42 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 536bda1..cd71e78 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -284,9 +284,12 @@ static int mdio_bus_suspend(struct device * dev, pm_message_t state)
 {
 	int ret = 0;
 	struct device_driver *drv = dev->driver;
+	struct phy_driver *phydrv = to_phy_driver(drv);
+	struct phy_device *phydev = to_phy_device(dev);
 
-	if (drv && drv->suspend)
-		ret = drv->suspend(dev, state);
+	if ((!device_may_wakeup(phydev->dev.parent)) &&
+		(phydrv && phydrv->suspend))
+			ret = phydrv->suspend(phydev);
 
 	return ret;
 }
@@ -295,9 +298,12 @@ static int mdio_bus_resume(struct device * dev)
 {
 	int ret = 0;
 	struct device_driver *drv = dev->driver;
+	struct phy_driver *phydrv = to_phy_driver(drv);
+	struct phy_device *phydev = to_phy_device(dev);
 
-	if (drv && drv->resume)
-		ret = drv->resume(dev);
+	if ((!device_may_wakeup(phydev->dev.parent)) &&
+		(phydrv && phydrv->resume))
+		ret = phydrv->resume(phydev);
 
 	return ret;
 }
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 25acbbd..b51cebb 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -779,7 +779,35 @@ static int genphy_config_init(struct phy_device *phydev)
 
 	return 0;
 }
+int genphy_suspend(struct phy_device *phydev)
+{
+	int value;
+
+	mutex_lock(&phydev->lock);
+
+	value = phy_read(phydev, MII_BMCR);
+	phy_write(phydev, MII_BMCR, (value | BMCR_PDOWN));
+
+	mutex_unlock(&phydev->lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(genphy_suspend);
 
+int genphy_resume(struct phy_device *phydev)
+{
+	int value;
+
+	mutex_lock(&phydev->lock);
+
+	value = phy_read(phydev, MII_BMCR);
+	phy_write(phydev, MII_BMCR, (value & ~BMCR_PDOWN));
+
+	mutex_unlock(&phydev->lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(genphy_resume);
 
 /**
  * phy_probe - probe and init a PHY device
@@ -855,7 +883,6 @@ int phy_driver_register(struct phy_driver *new_driver)
 {
 	int retval;
 
-	memset(&new_driver->driver, 0, sizeof(new_driver->driver));
 	new_driver->driver.name = new_driver->name;
 	new_driver->driver.bus = &mdio_bus_type;
 	new_driver->driver.probe = phy_probe;
@@ -890,6 +917,8 @@ static struct phy_driver genphy_driver = {
 	.features	= 0,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver		= {.owner= THIS_MODULE, },
 };
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 77c4ed6..d7e54d9 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -467,6 +467,8 @@ int genphy_restart_aneg(struct phy_device *phydev);
 int genphy_config_aneg(struct phy_device *phydev);
 int genphy_update_link(struct phy_device *phydev);
 int genphy_read_status(struct phy_device *phydev);
+int genphy_suspend(struct phy_device *phydev);
+int genphy_resume(struct phy_device *phydev);
 void phy_driver_unregister(struct phy_driver *drv);
 int phy_driver_register(struct phy_driver *new_driver);
 void phy_prepare_link(struct phy_device *phydev,
-- 
1.5.6.5

