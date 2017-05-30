From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH] net: fix auto-loading of Marvell DSA driver
Date: Tue, 30 May 2017 21:38:18 +0100
Message-ID: <E1dFnuE-0006U0-PM@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:54734 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750811AbdE3UiX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 16:38:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auto-loading of the Marvell DSA driver has stopped working with recent
kernels.  This seems to be due to the change of binding for DSA devices,
moving them from the platform bus to the MDIO bus.

In order for module auto-loading to work, we need to provide a MODALIAS
string in the uevent file for the device.  However, the device core does
not automatically provide this, and needs each bus_type to implement a
uevent method to generate these strings.  The MDIO bus does not provide
such a method, so no MODALIAS string is provided:

.# cat /sys/bus/mdio_bus/devices/f1072004.mdio-mii\:04/uevent
DRIVER=mv88e6085
OF_NAME=switch
OF_FULLNAME=/soc/internal-regs/mdio@72004/switch@4
OF_COMPATIBLE_0=marvell,mv88e6085
OF_COMPATIBLE_N=1

In the case of OF-based devices, the solution is easy -
of_device_uevent_modalias() does the work for us.  After this is done,
the uevent file looks like this:

.# cat /sys/bus/mdio_bus/devices/f1072004.mdio-mii\:04/uevent
DRIVER=mv88e6085
OF_NAME=switch
OF_FULLNAME=/soc/internal-regs/mdio@72004/switch@4
OF_COMPATIBLE_0=marvell,mv88e6085
OF_COMPATIBLE_N=1
MODALIAS=of:NswitchT<NULL>Cmarvell,mv88e6085

which results in auto-loading of the Marvell DSA driver on Clearfog
platforms.

Fixes: c0405563a613 ("ARM: dts: armada-388-clearfog: Utilize new DSA binding")
Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/mdio_bus.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 8e73f5f36e71..f99c21f78b63 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -658,6 +658,18 @@ static int mdio_bus_match(struct device *dev, struct device_driver *drv)
 	return 0;
 }
 
+static int mdio_uevent(struct device *dev, struct kobj_uevent_env *env)
+{
+	int rc;
+
+	/* Some devices have extra OF data and an OF-style MODALIAS */
+	rc = of_device_uevent_modalias(dev, env);
+	if (rc != -ENODEV)
+		return rc;
+
+	return 0;
+}
+
 #ifdef CONFIG_PM
 static int mdio_bus_suspend(struct device *dev)
 {
@@ -708,6 +720,7 @@ static const struct dev_pm_ops mdio_bus_pm_ops = {
 struct bus_type mdio_bus_type = {
 	.name		= "mdio_bus",
 	.match		= mdio_bus_match,
+	.uevent		= mdio_uevent,
 	.pm		= MDIO_BUS_PM_OPS,
 };
 EXPORT_SYMBOL(mdio_bus_type);
-- 
2.7.4
