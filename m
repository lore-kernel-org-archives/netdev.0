From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] PHYLIB mdio fixes #2
Date: Fri, 19 Dec 2008 20:52:36 +0100
Message-ID: <m3r644aqnv.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:58922 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751570AbYLSTwj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2008 14:52:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHYLIB mdio code has more problems in error paths:
- mdiobus_release can be called before bus->state is set to
  MDIOBUS_REGISTERED
- mdiobus_scan allocates resources which need to be freed
- the comment is wrong, the resistors used are actually pull-ups.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -63,7 +63,9 @@ EXPORT_SYMBOL(mdiobus_alloc);
 static void mdiobus_release(struct device *d)
 {
 	struct mii_bus *bus = to_mii_bus(d);
-	BUG_ON(bus->state != MDIOBUS_RELEASED);
+	BUG_ON(bus->state != MDIOBUS_RELEASED &&
+	       /* for compatibility with error handling in drivers */
+	       bus->state != MDIOBUS_ALLOCATED);
 	kfree(bus);
 }
 
@@ -83,8 +85,7 @@ static struct class mdio_bus_class = {
  */
 int mdiobus_register(struct mii_bus *bus)
 {
-	int i;
-	int err = 0;
+	int i, err;
 
 	if (NULL == bus || NULL == bus->name ||
 			NULL == bus->read ||
@@ -116,16 +117,23 @@ int mdiobus_register(struct mii_bus *bus)
 			struct phy_device *phydev;
 
 			phydev = mdiobus_scan(bus, i);
-			if (IS_ERR(phydev))
+			if (IS_ERR(phydev)) {
 				err = PTR_ERR(phydev);
+				goto error;
+			}
 		}
 	}
 
-	if (!err)
-		bus->state = MDIOBUS_REGISTERED;
-
+	bus->state = MDIOBUS_REGISTERED;
 	pr_info("%s: probed\n", bus->name);
+	return 0;
 
+error:
+	while (--i >= 0) {
+		if (bus->phy_map[i])
+			device_unregister(&bus->phy_map[i]->dev);
+	}
+	device_del(&bus->dev);
 	return err;
 }
 EXPORT_SYMBOL(mdiobus_register);
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -232,7 +232,7 @@ struct phy_device * get_phy_device(struct mii_bus *bus, int addr)
 		return NULL;
 
 	/*
-	 * Broken hardware is sometimes missing the pull down resistor on the
+	 * Broken hardware is sometimes missing the pull-up resistor on the
 	 * MDIO line, which results in reads to non-existent devices returning
 	 * 0 rather than 0xffff. Catch this here and treat 0 as a non-existent
 	 * device as well.
