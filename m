From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 8/9] phy: add phy_device_remove()
Date: Thu, 24 Sep 2015 20:18:58 +0100
Message-ID: <E1ZfC2k-00036M-A2@rmk-PC.arm.linux.org.uk>
References: <20150924191754.GC21513@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Jason Cooper <jason@lakedaemon.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:44830 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbbIXTTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 15:19:12 -0400
In-Reply-To: <20150924191754.GC21513@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a phy_device_remove() function to complement phy_device_register(),
which undoes the effects of phy_device_register() by removing the phy
device from visibility, but not freeing it.

This allows these details to be moved out of the mdio bus code into
the phy code where this action belongs.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/gianfar.c |  5 +++--
 drivers/net/phy/mdio_bus.c               | 15 ++++++++++-----
 drivers/net/phy/phy_device.c             | 18 ++++++++++++++++++
 include/linux/phy.h                      |  1 +
 4 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 65a16086faec..903211df3288 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1702,7 +1702,6 @@ static void gfar_configure_serdes(struct net_device *dev)
 	tbiphy = of_phy_find_device(priv->tbi_node);
 	if (!tbiphy) {
 		dev_err(&dev->dev, "error: Could not get TBI device\n");
-		put_device(&tbiphy->dev);
 		return;
 	}
 
@@ -1711,8 +1710,10 @@ static void gfar_configure_serdes(struct net_device *dev)
 	 * everything for us?  Resetting it takes the link down and requires
 	 * several seconds for it to come back.
 	 */
-	if (phy_read(tbiphy, MII_BMSR) & BMSR_LSTATUS)
+	if (phy_read(tbiphy, MII_BMSR) & BMSR_LSTATUS) {
+		put_device(&tbiphy->dev);
 		return;
+	}
 
 	/* Single clk mode, mii mode off(for serdes communication) */
 	phy_write(tbiphy, MII_TBICON, TBICON_CLK_SELECT);
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 992406624b7c..c340e412b38f 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -291,8 +291,11 @@ int __mdiobus_register(struct mii_bus *bus, struct module *owner)
 
 error:
 	while (--i >= 0) {
-		if (bus->phy_map[i])
-			device_unregister(&bus->phy_map[i]->dev);
+		struct phy_device *phydev = bus->phy_map[i];
+		if (phydev) {
+			phy_device_remove(phydev);
+			phy_device_free(phydev);
+		}
 	}
 	device_del(&bus->dev);
 	return err;
@@ -307,9 +310,11 @@ void mdiobus_unregister(struct mii_bus *bus)
 	bus->state = MDIOBUS_UNREGISTERED;
 
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
-		if (bus->phy_map[i])
-			device_unregister(&bus->phy_map[i]->dev);
-		bus->phy_map[i] = NULL;
+		struct phy_device *phydev = bus->phy_map[i];
+		if (phydev) {
+			phy_device_remove(phydev);
+			phy_device_free(phydev);
+		}
 	}
 	device_del(&bus->dev);
 }
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 97a4f52addac..f761288abe66 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -384,6 +384,24 @@ int phy_device_register(struct phy_device *phydev)
 EXPORT_SYMBOL(phy_device_register);
 
 /**
+ * phy_device_remove - Remove a previously registered phy device from the MDIO bus
+ * @phydev: phy_device structure to remove
+ *
+ * This doesn't free the phy_device itself, it merely reverses the effects
+ * of phy_device_register(). Use phy_device_free() to free the device
+ * after calling this function.
+ */
+void phy_device_remove(struct phy_device *phydev)
+{
+	struct mii_bus *bus = phydev->bus;
+	int addr = phydev->addr;
+
+	device_del(&phydev->dev);
+	bus->phy_map[addr] = NULL;
+}
+EXPORT_SYMBOL(phy_device_remove);
+
+/**
  * phy_find_first - finds the first PHY device on the bus
  * @bus: the target MII bus
  */
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 11bce44f6d65..4a4e3a092337 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -745,6 +745,7 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 				     struct phy_c45_device_ids *c45_ids);
 struct phy_device *get_phy_device(struct mii_bus *bus, int addr, bool is_c45);
 int phy_device_register(struct phy_device *phy);
+void phy_device_remove(struct phy_device *phydev);
 int phy_init_hw(struct phy_device *phydev);
 int phy_suspend(struct phy_device *phydev);
 int phy_resume(struct phy_device *phydev);
-- 
2.1.0
