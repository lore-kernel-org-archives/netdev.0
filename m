From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] phy: Don't increment MDIO bus refcount unless it's a different owner
Date: Tue,  6 Dec 2016 20:54:43 -0800
Message-ID: <20161207045443.26246-1-f.fainelli@gmail.com>
Cc: johan@kernel.org, rmk+kernel@arm.linux.org.uk, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35232 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751527AbcLGEyu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 23:54:50 -0500
Received: by mail-oi0-f66.google.com with SMTP id v84so44071419oie.2
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 20:54:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 3e3aaf649416 ("phy: fix mdiobus module safety") fixed the way we
dealt with MDIO bus module reference count, but sort of introduced a
regression in that, if an Ethernet driver registers its own MDIO bus
driver, as is common, we will end up with the Ethernet driver's
module->refnct set to 1, thus preventing this driver from any removal.

Fix this by comparing the network device's device driver owner against
the MDIO bus driver owner, and only if they are different, increment the
MDIO bus module refcount.

Fixes: 3e3aaf649416 ("phy: fix mdiobus module safety")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Russell,

I verified this against the ethoc driver primarily (on a TS7300 board)
and bcmgenet.

Thanks!

 drivers/net/phy/phy_device.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 1a4bf8acad78..c4ceb082e970 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -857,11 +857,17 @@ EXPORT_SYMBOL(phy_attached_print);
 int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 		      u32 flags, phy_interface_t interface)
 {
+	struct module *ndev_owner = dev->dev.parent->driver->owner;
 	struct mii_bus *bus = phydev->mdio.bus;
 	struct device *d = &phydev->mdio.dev;
 	int err;
 
-	if (!try_module_get(bus->owner)) {
+	/* For Ethernet device drivers that register their own MDIO bus, we
+	 * will have bus->owner match ndev_mod, so we do not want to increment
+	 * our own module->refcnt here, otherwise we would not be able to
+	 * unload later on.
+	 */
+	if (ndev_owner != bus->owner && !try_module_get(bus->owner)) {
 		dev_err(&dev->dev, "failed to get the bus module\n");
 		return -EIO;
 	}
@@ -921,7 +927,8 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 
 error:
 	put_device(d);
-	module_put(bus->owner);
+	if (ndev_owner != bus->owner)
+		module_put(bus->owner);
 	return err;
 }
 EXPORT_SYMBOL(phy_attach_direct);
@@ -971,6 +978,8 @@ EXPORT_SYMBOL(phy_attach);
  */
 void phy_detach(struct phy_device *phydev)
 {
+	struct net_device *dev = phydev->attached_dev;
+	struct module *ndev_owner = dev->dev.parent->driver->owner;
 	struct mii_bus *bus;
 	int i;
 
@@ -998,7 +1007,8 @@ void phy_detach(struct phy_device *phydev)
 	bus = phydev->mdio.bus;
 
 	put_device(&phydev->mdio.dev);
-	module_put(bus->owner);
+	if (ndev_owner != bus->owner)
+		module_put(bus->owner);
 }
 EXPORT_SYMBOL(phy_detach);
 
-- 
2.9.3
