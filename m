From: Ionut Nicu <ionut.nicu@freescale.com>
Subject: [PATCH][v2] phylib: add module owner to the mii_bus structure
Date: Fri, 28 Dec 2007 19:31:51 +0200
Message-ID: <78b2dab672856274c518f4c523f6f63f59f06dd1.1198861866.git.ionut.nicu@freescale.com>
References: <20071221153713.641f010e@deepthought>
Cc: shemminger@linux-foundation.org,
	Ionut Nicu <ionut.nicu@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-173-Unkn.Local.iNES.RO ([80.86.100.173]:44578 "EHLO
	dev.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751886AbXL1ShL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2007 13:37:11 -0500
In-Reply-To: <20071221153713.641f010e@deepthought>
In-Reply-To: <785b16e8da057c6efb259494258bb30314ccac4c.1198861866.git.ionut.nicu@freescale.com>
References: <785b16e8da057c6efb259494258bb30314ccac4c.1198861866.git.ionut.nicu@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prevent unloading mii bus driver module when other modules have references to some
phydevs on that bus. Added a new member (module owner) to struct mii_bus and added
code to increment the mii bus owner module usage count on phy_connect and decrement
it on phy_disconnect

Set the module owner in the ucc_geth_mdio driver.

Signed-off-by: Ionut Nicu <ionut.nicu@freescale.com>
Tested-by: Emil Medve <Emilian.Medve@Freescale.com>
---
 drivers/net/phy/phy_device.c |    9 ++++++++-
 drivers/net/ucc_geth_mii.c   |    3 +++
 include/linux/phy.h          |    4 ++++
 3 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 5b9e175..ca617ec 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -171,6 +171,10 @@ struct phy_device * phy_connect(struct net_device *dev, const char *phy_id,
 	if (IS_ERR(phydev))
 		return phydev;
 
+	/* Increment the usage count of the mii bus owner */
+	if (!try_module_get(phydev->bus->owner))
+		return ERR_PTR(-EFAULT);
+
 	phy_prepare_link(phydev, handler);
 
 	phy_start_machine(phydev, NULL);
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
1.5.4.rc1

