From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/3] phylib: allow incremental scanning of an mii bus
Date: Wed,  3 Sep 2008 15:20:10 +0200
Message-ID: <1220448012-20347-2-git-send-email-buytenh@wantstofly.org>
References: <1220448012-20347-1-git-send-email-buytenh@wantstofly.org>
Cc: Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:56364 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752066AbYICNUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 09:20:14 -0400
In-Reply-To: <1220448012-20347-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch splits the bus scanning code in mdiobus_register() off
into a separate function, and makes this function available for
calling from external code.  This allows incrementally scanning an
mii bus, e.g. as information about which addresses are 'safe' to
scan becomes available.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/phy/mdio_bus.c |   89 +++++++++++++++++++++++--------------------
 include/linux/phy.h        |    2 +
 2 files changed, 50 insertions(+), 41 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 94e0b7e..e7508c1 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -60,49 +60,14 @@ int mdiobus_register(struct mii_bus *bus)
 		bus->reset(bus);
 
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
-		struct phy_device *phydev;
+		bus->phy_map[i] = NULL;
+		if ((bus->phy_mask & (1 << i)) == 0) {
+			struct phy_device *phydev;
 
-		if (bus->phy_mask & (1 << i)) {
-			bus->phy_map[i] = NULL;
-			continue;
+			phydev = mdiobus_scan(bus, i);
+			if (IS_ERR(phydev))
+				err = PTR_ERR(phydev);
 		}
-
-		phydev = get_phy_device(bus, i);
-
-		if (IS_ERR(phydev))
-			return PTR_ERR(phydev);
-
-		/* There's a PHY at this address
-		 * We need to set:
-		 * 1) IRQ
-		 * 2) bus_id
-		 * 3) parent
-		 * 4) bus
-		 * 5) mii_bus
-		 * And, we need to register it */
-		if (phydev) {
-			phydev->irq = bus->irq[i];
-
-			phydev->dev.parent = bus->dev;
-			phydev->dev.bus = &mdio_bus_type;
-			snprintf(phydev->dev.bus_id, BUS_ID_SIZE, PHY_ID_FMT, bus->id, i);
-
-			phydev->bus = bus;
-
-			/* Run all of the fixups for this PHY */
-			phy_scan_fixups(phydev);
-
-			err = device_register(&phydev->dev);
-
-			if (err) {
-				printk(KERN_ERR "phy %d failed to register\n",
-						i);
-				phy_device_free(phydev);
-				phydev = NULL;
-			}
-		}
-
-		bus->phy_map[i] = phydev;
 	}
 
 	pr_info("%s: probed\n", bus->name);
@@ -122,6 +87,48 @@ void mdiobus_unregister(struct mii_bus *bus)
 }
 EXPORT_SYMBOL(mdiobus_unregister);
 
+struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr)
+{
+	struct phy_device *phydev;
+	int err;
+
+	phydev = get_phy_device(bus, addr);
+	if (IS_ERR(phydev) || phydev == NULL)
+		return phydev;
+
+	/* There's a PHY at this address
+	 * We need to set:
+	 * 1) IRQ
+	 * 2) bus_id
+	 * 3) parent
+	 * 4) bus
+	 * 5) mii_bus
+	 * And, we need to register it */
+
+	phydev->irq = bus->irq != NULL ? bus->irq[addr] : PHY_POLL;
+
+	phydev->dev.parent = bus->dev;
+	phydev->dev.bus = &mdio_bus_type;
+	snprintf(phydev->dev.bus_id, BUS_ID_SIZE, PHY_ID_FMT, bus->id, addr);
+
+	phydev->bus = bus;
+
+	/* Run all of the fixups for this PHY */
+	phy_scan_fixups(phydev);
+
+	err = device_register(&phydev->dev);
+	if (err) {
+		printk(KERN_ERR "phy %d failed to register\n", addr);
+		phy_device_free(phydev);
+		phydev = NULL;
+	}
+
+	bus->phy_map[addr] = phydev;
+
+	return phydev;
+}
+EXPORT_SYMBOL(mdiobus_scan);
+
 /**
  * mdio_bus_match - determine if given PHY driver supports the given PHY device
  * @dev: target PHY device
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 7224c40..5f170f5 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -410,6 +410,8 @@ int phy_start_aneg(struct phy_device *phydev);
 
 int mdiobus_register(struct mii_bus *bus);
 void mdiobus_unregister(struct mii_bus *bus);
+struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr);
+
 void phy_sanitize_settings(struct phy_device *phydev);
 int phy_stop_interrupts(struct phy_device *phydev);
 int phy_enable_interrupts(struct phy_device *phydev);
-- 
1.5.6.4

