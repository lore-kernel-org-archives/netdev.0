From: Ionut Nicu <ionut.nicu@freescale.com>
Subject: [PATCH 2/2] phylib: add module owner to the mii_bus structure
Date: Fri, 21 Dec 2007 15:57:31 +0200
Message-ID: <1198245451-13929-1-git-send-email-ionut.nicu@freescale.com>
Cc: Ionut Nicu <ionut.nicu@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:59772 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbXLUPFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 10:05:30 -0500
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id lBLDvgGY024309
	for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 06:59:39 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prevent unloading mii bus driver module when other modules have references to some
phydevs on that bus. Added a new member (module owner) to struct mii_bus and added
code to increment the mii bus owner module usage count on phy_connect and decrement
it on phy_disconnect

Set the module owner in the ucc_geth_mdio driver.

Signed-off-by: Ionut Nicu <ionut.nicu@freescale.com>
---
 drivers/net/phy/phy_device.c |    9 ++++++++-
 drivers/net/ucc_geth_mii.c   |    3 +++
 include/linux/phy.h          |    4 ++++
 3 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 5b9e175..7dc5480 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -178,6 +178,10 @@ struct phy_device * phy_connect(struct net_device *dev, const char *phy_id,
 	if (phydev->irq > 0)
 		phy_start_interrupts(phydev);
 
+	/* Increment the usage count of the mii bus owner */
+	if (!try_module_get(phydev->bus->owner))
+		return ERR_PTR(-EFAULT);
+
 	return phydev;
 }
 EXPORT_SYMBOL(phy_connect);
@@ -192,9 +196,12 @@ void phy_disconnect(struct phy_device *phydev)
 		phy_stop_interrupts(phydev);
 
 	phy_stop_machine(phydev);
-	
+
 	phydev->adjust_link = NULL;
 
+	/* Decrement the reference count for the mii bus owner */
+	module_put(phydev->bus->owner);
+
 	phy_detach(phydev);
 }
 EXPORT_SYMBOL(phy_disconnect);
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index a3af4ea..84c7295 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -217,6 +217,9 @@ static int uec_mdio_probe(struct of_device *ofdev, const struct of_device_id *ma
 		}
 	}
 
+	/* register ourselves as the owner of this bus */
+	new_bus->owner = THIS_MODULE;
+
 	err = mdiobus_register(new_bus);
 	if (0 != err) {
 		printk(KERN_ERR "%s: Cannot register as MDIO bus\n",
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 554836e..04ff6a5 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -82,6 +82,10 @@ struct mii_bus {
 	const char *name;
 	int id;
 	void *priv;
+
+	/* The module that owns this bus */
+	struct module *owner;
+
 	int (*read)(struct mii_bus *bus, int phy_id, int regnum);
 	int (*write)(struct mii_bus *bus, int phy_id, int regnum, u16 val);
 	int (*reset)(struct mii_bus *bus);
-- 
1.5.4.rc0

