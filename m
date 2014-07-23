From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 2/2] net: phy: Ensure the MDIO bus module is held
Date: Tue, 22 Jul 2014 21:16:10 -0300
Message-ID: <1406074570-13246-3-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1406074570-13246-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:37436 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757301AbaGWAR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 20:17:26 -0400
In-Reply-To: <1406074570-13246-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds proper module_{get,put} to prevent the MDIO bus module
from being unloaded while the phydev is connected. By doing so, we fix
a kernel panic produced when a MDIO driver is removed, but the phydev
that relies on it is attached and running.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/phy/phy_device.c | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 35d753d..a10dc47 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -575,6 +575,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 		      u32 flags, phy_interface_t interface)
 {
 	struct device *d = &phydev->dev;
+	struct module *bus_module;
 	int err;
 
 	/* Assume that if there is no driver, that it doesn't
@@ -599,6 +600,14 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 		return -EBUSY;
 	}
 
+	/* Increment the bus module reference count */
+	bus_module = phydev->bus->dev.driver ?
+		     phydev->bus->dev.driver->owner : NULL;
+	if (!try_module_get(bus_module)) {
+		dev_err(&dev->dev, "failed to get the bus module\n");
+		return -EIO;
+	}
+
 	phydev->attached_dev = dev;
 	dev->phydev = phydev;
 
@@ -614,10 +623,14 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 	 */
 	err = phy_init_hw(phydev);
 	if (err)
-		phy_detach(phydev);
-	else
-		phy_resume(phydev);
+		goto err_module_put;
 
+	phy_resume(phydev);
+	return err;
+
+err_module_put:
+	module_put(bus_module);
+	phy_detach(phydev);
 	return err;
 }
 EXPORT_SYMBOL(phy_attach_direct);
@@ -664,6 +677,10 @@ EXPORT_SYMBOL(phy_attach);
 void phy_detach(struct phy_device *phydev)
 {
 	int i;
+
+	if (phydev->bus->dev.driver)
+		module_put(phydev->bus->dev.driver->owner);
+
 	phydev->attached_dev->phydev = NULL;
 	phydev->attached_dev = NULL;
 	phy_suspend(phydev);
-- 
2.0.1
