From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 2/9] phylib: rework to prepare for OF registration of PHYs
Date: Wed, 18 Mar 2009 23:00:21 -0600
Message-ID: <20090319050021.11320.26986.stgit@localhost.localdomain>
References: <20090319050015.11320.61641.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com, avorontsov@ru.mvista.com,
	davem@davemloft.net, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:45392 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560AbZCSFA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 01:00:26 -0400
Received: by rv-out-0506.google.com with SMTP id f9so378330rvb.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 22:00:24 -0700 (PDT)
In-Reply-To: <20090319050015.11320.61641.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

This patch makes changes in preparation for supporting open firmware
device tree descriptions of MDIO busses.  Changes include:
- Cleanup handling of phy_map[] entries; they are already NULLed when
  registering and so don't need to be re-cleared, and it is good practice
  to clear them out when unregistering.
- Split phy_device registration out into a new function so that the
  OF helpers can do two stage registration (separate allocation and
  registration steps).

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
CC: linuxppc-dev@ozlabs.org
CC: netdev@vger.kernel.org
CC: Andy Fleming <afleming@freescale.com>
---

 drivers/net/phy/mdio_bus.c   |   29 +++-------------------------
 drivers/net/phy/phy_device.c |   43 ++++++++++++++++++++++++++++++++++++++----
 include/linux/phy.h          |    1 +
 3 files changed, 43 insertions(+), 30 deletions(-)


diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 811a637..3c39c7b 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -112,7 +112,6 @@ int mdiobus_register(struct mii_bus *bus)
 		bus->reset(bus);
 
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
-		bus->phy_map[i] = NULL;
 		if ((bus->phy_mask & (1 << i)) == 0) {
 			struct phy_device *phydev;
 
@@ -149,6 +148,7 @@ void mdiobus_unregister(struct mii_bus *bus)
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
 		if (bus->phy_map[i])
 			device_unregister(&bus->phy_map[i]->dev);
+		bus->phy_map[i] = NULL;
 	}
 }
 EXPORT_SYMBOL(mdiobus_unregister);
@@ -187,35 +187,12 @@ struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr)
 	if (IS_ERR(phydev) || phydev == NULL)
 		return phydev;
 
-	/* There's a PHY at this address
-	 * We need to set:
-	 * 1) IRQ
-	 * 2) bus_id
-	 * 3) parent
-	 * 4) bus
-	 * 5) mii_bus
-	 * And, we need to register it */
-
-	phydev->irq = bus->irq != NULL ? bus->irq[addr] : PHY_POLL;
-
-	phydev->dev.parent = bus->parent;
-	phydev->dev.bus = &mdio_bus_type;
-	dev_set_name(&phydev->dev, PHY_ID_FMT, bus->id, addr);
-
-	phydev->bus = bus;
-
-	/* Run all of the fixups for this PHY */
-	phy_scan_fixups(phydev);
-
-	err = device_register(&phydev->dev);
+	err = phy_device_register(phydev);
 	if (err) {
-		printk(KERN_ERR "phy %d failed to register\n", addr);
 		phy_device_free(phydev);
-		phydev = NULL;
+		return NULL;
 	}
 
-	bus->phy_map[addr] = phydev;
-
 	return phydev;
 }
 EXPORT_SYMBOL(mdiobus_scan);
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 0a06e4f..793332f 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -39,10 +39,6 @@ MODULE_DESCRIPTION("PHY library");
 MODULE_AUTHOR("Andy Fleming");
 MODULE_LICENSE("GPL");
 
-static struct phy_driver genphy_driver;
-extern int mdio_bus_init(void);
-extern void mdio_bus_exit(void);
-
 void phy_device_free(struct phy_device *phydev)
 {
 	kfree(phydev);
@@ -53,6 +49,10 @@ static void phy_device_release(struct device *dev)
 	phy_device_free(to_phy_device(dev));
 }
 
+static struct phy_driver genphy_driver;
+extern int mdio_bus_init(void);
+extern void mdio_bus_exit(void);
+
 static LIST_HEAD(phy_fixup_list);
 static DEFINE_MUTEX(phy_fixup_lock);
 
@@ -166,6 +166,10 @@ struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
 	dev->addr = addr;
 	dev->phy_id = phy_id;
 	dev->bus = bus;
+	dev->dev.parent = bus->parent;
+	dev->dev.bus = &mdio_bus_type;
+	dev->irq = bus->irq != NULL ? bus->irq[addr] : PHY_POLL;
+	dev_set_name(&dev->dev, PHY_ID_FMT, bus->id, addr);
 
 	dev->state = PHY_DOWN;
 
@@ -237,6 +241,37 @@ struct phy_device * get_phy_device(struct mii_bus *bus, int addr)
 }
 
 /**
+ * phy_device_register - Register the phy device on the MDIO bus
+ * @phy_device: phy_device structure to be added to the MDIO bus
+ */
+int phy_device_register(struct phy_device *phydev)
+{
+	int err;
+
+	/* Don't register a phy if one is already registered at this
+	 * address */
+	if (phydev->bus->phy_map[phydev->addr])
+		return -EINVAL;
+	phydev->bus->phy_map[phydev->addr] = phydev;
+
+	/* Run all of the fixups for this PHY */
+	phy_scan_fixups(phydev);
+
+	err = device_register(&phydev->dev);
+	if (err) {
+		pr_err("phy %d failed to register\n", phydev->addr);
+		goto out;
+	}
+
+	return 0;
+
+ out:
+	phydev->bus->phy_map[phydev->addr] = NULL;
+	return err;
+}
+EXPORT_SYMBOL(phy_device_register);
+
+/**
  * phy_prepare_link - prepares the PHY layer to monitor link status
  * @phydev: target phy_device struct
  * @handler: callback function for link status change notifications
diff --git a/include/linux/phy.h b/include/linux/phy.h
index d7e54d9..a47d64f 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -439,6 +439,7 @@ static inline int phy_write(struct phy_device *phydev, u16 regnum, u16 val)
 
 int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id);
 struct phy_device* get_phy_device(struct mii_bus *bus, int addr);
+int phy_device_register(struct phy_device *phy);
 int phy_clear_interrupt(struct phy_device *phydev);
 int phy_config_interrupt(struct phy_device *phydev, u32 interrupts);
 struct phy_device * phy_attach(struct net_device *dev,

