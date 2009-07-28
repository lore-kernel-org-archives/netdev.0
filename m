From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 4/4] au1000_eth: platform_driver conversion part two
Date: Tue, 28 Jul 2009 23:00:34 +0200
Message-ID: <200907282300.34728.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Manuel Lauss <manuel.lauss@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:47403 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754033AbZG1VAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 17:00:45 -0400
Received: by mail-ew0-f226.google.com with SMTP id 26so359125ewy.37
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 14:00:45 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the au1000_eth driver aware of PHY
configuration passed to it via platform_data. Tested on
Meshcube (aka MTX-1).

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index a344cb3..57cc4f6 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -63,6 +63,7 @@
 #include <asm/processor.h>
 
 #include <au1000.h>
+#include <au1xxx_eth.h>
 #include <prom.h>
 
 #include "au1000_eth.h"
@@ -112,15 +113,15 @@ struct au1000_private *au_macs[NUM_ETH_INTERFACES];
  *
  * PHY detection algorithm
  *
- * If AU1XXX_PHY_STATIC_CONFIG is undefined, the PHY setup is
+ * If phy_static_config is undefined, the PHY setup is
  * autodetected:
  *
  * mii_probe() first searches the current MAC's MII bus for a PHY,
- * selecting the first (or last, if AU1XXX_PHY_SEARCH_HIGHEST_ADDR is
+ * selecting the first (or last, if phy_search_highest_addr is
  * defined) PHY address not already claimed by another netdev.
  *
  * If nothing was found that way when searching for the 2nd ethernet
- * controller's PHY and AU1XXX_PHY1_SEARCH_ON_MAC0 is defined, then
+ * controller's PHY and phy1_search_mac0 is defined, then
  * the first MII bus is searched as well for an unclaimed PHY; this is
  * needed in case of a dual-PHY accessible only through the MAC0's MII
  * bus.
@@ -129,9 +130,7 @@ struct au1000_private *au_macs[NUM_ETH_INTERFACES];
  * controller is not registered to the network subsystem.
  */
 
-/* autodetection defaults */
-#undef  AU1XXX_PHY_SEARCH_HIGHEST_ADDR
-#define AU1XXX_PHY1_SEARCH_ON_MAC0
+/* autodetection defaults: phy1_search_mac0 */
 
 /* static PHY setup
  *
@@ -148,29 +147,6 @@ struct au1000_private *au_macs[NUM_ETH_INTERFACES];
  * specific irq-map
  */
 
-#if defined(CONFIG_MIPS_BOSPORUS)
-/*
- * Micrel/Kendin 5 port switch attached to MAC0,
- * MAC0 is associated with PHY address 5 (== WAN port)
- * MAC1 is not associated with any PHY, since it's connected directly
- * to the switch.
- * no interrupts are used
- */
-# define AU1XXX_PHY_STATIC_CONFIG
-
-# define AU1XXX_PHY0_ADDR  5
-# define AU1XXX_PHY0_BUSID 0
-#  undef AU1XXX_PHY0_IRQ
-
-#  undef AU1XXX_PHY1_ADDR
-#  undef AU1XXX_PHY1_BUSID
-#  undef AU1XXX_PHY1_IRQ
-#endif
-
-#if defined(AU1XXX_PHY0_BUSID) && (AU1XXX_PHY0_BUSID > 0)
-# error MAC0-associated PHY attached 2nd MACs MII bus not supported yet
-#endif
-
 static void enable_mac(struct net_device *dev, int force_reset)
 {
 	unsigned long flags;
@@ -390,67 +366,54 @@ static int mii_probe (struct net_device *dev)
 	struct au1000_private *const aup = netdev_priv(dev);
 	struct phy_device *phydev = NULL;
 
-#if defined(AU1XXX_PHY_STATIC_CONFIG)
-	BUG_ON(aup->mac_id < 0 || aup->mac_id > 1);
+	if (aup->phy_static_config) {
+		BUG_ON(aup->mac_id < 0 || aup->mac_id > 1);
 
-	if(aup->mac_id == 0) { /* get PHY0 */
-# if defined(AU1XXX_PHY0_ADDR)
-		phydev = aup->mii_bus->phy_map[AU1XXX_PHY0_ADDR];
-# else
-		printk (KERN_INFO DRV_NAME ":%s: using PHY-less setup\n",
-			dev->name);
-		return 0;
-# endif /* defined(AU1XXX_PHY0_ADDR) */
-	} else if (aup->mac_id == 1) { /* get PHY1 */
-# if defined(AU1XXX_PHY1_ADDR)
-		phydev = aup->mii_bus->phy_map[AU1XXX_PHY1_ADDR];
-# else
-		printk (KERN_INFO DRV_NAME ":%s: using PHY-less setup\n",
-			dev->name);
+		if (aup->phy_addr)
+			phydev = aup->mii_bus->phy_map[aup->phy_addr];
+		else
+			printk (KERN_INFO DRV_NAME ":%s: using PHY-less setup\n",
+				dev->name);
 		return 0;
-# endif /* defined(AU1XXX_PHY1_ADDR) */
-	}
-
-#else /* defined(AU1XXX_PHY_STATIC_CONFIG) */
-	int phy_addr;
-
-	/* find the first (lowest address) PHY on the current MAC's MII bus */
-	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++)
-		if (aup->mii_bus->phy_map[phy_addr]) {
-			phydev = aup->mii_bus->phy_map[phy_addr];
-# if !defined(AU1XXX_PHY_SEARCH_HIGHEST_ADDR)
-			break; /* break out with first one found */
-# endif
-		}
+	} else {
+		int phy_addr;
+
+		/* find the first (lowest address) PHY on the current MAC's MII bus */
+		for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++)
+			if (aup->mii_bus->phy_map[phy_addr]) {
+				phydev = aup->mii_bus->phy_map[phy_addr];
+				if (!aup->phy_search_highest_addr)
+					break; /* break out with first one found */
+			}
 
-# if defined(AU1XXX_PHY1_SEARCH_ON_MAC0)
-	/* try harder to find a PHY */
-	if (!phydev && (aup->mac_id == 1)) {
-		/* no PHY found, maybe we have a dual PHY? */
-		printk (KERN_INFO DRV_NAME ": no PHY found on MAC1, "
-			"let's see if it's attached to MAC0...\n");
-
-		/* find the first (lowest address) non-attached PHY on
-		 * the MAC0 MII bus */
-		for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
-			if (aup->mac_id == 1)
-				break;
-			struct phy_device *const tmp_phydev =
-				aup->mii_bus->phy_map[phy_addr];
-
-			if (!tmp_phydev)
-				continue; /* no PHY here... */
-
-			if (tmp_phydev->attached_dev)
-				continue; /* already claimed by MAC0 */
-
-			phydev = tmp_phydev;
-			break; /* found it */
+		if (aup->phy1_search_mac0) {
+			/* try harder to find a PHY */
+			if (!phydev && (aup->mac_id == 1)) {
+				/* no PHY found, maybe we have a dual PHY? */
+				printk (KERN_INFO DRV_NAME ": no PHY found on MAC1, "
+					"let's see if it's attached to MAC0...\n");
+
+				/* find the first (lowest address) non-attached PHY on
+		 		* the MAC0 MII bus */
+				for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
+					if (aup->mac_id == 1)
+						break;
+					struct phy_device *const tmp_phydev =
+							aup->mii_bus->phy_map[phy_addr];
+
+					if (!tmp_phydev)
+						continue; /* no PHY here... */
+
+					if (tmp_phydev->attached_dev)
+						continue; /* already claimed by MAC0 */
+
+					phydev = tmp_phydev;
+					break; /* found it */
+				}
+			}
 		}
 	}
-# endif /* defined(AU1XXX_PHY1_SEARCH_OTHER_BUS) */
 
-#endif /* defined(AU1XXX_PHY_STATIC_CONFIG) */
 	if (!phydev) {
 		printk (KERN_ERR DRV_NAME ":%s: no PHY found\n", dev->name);
 		return -1;
@@ -1039,6 +1002,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 {
 	static unsigned version_printed = 0;
 	struct au1000_private *aup = NULL;
+	struct au1000_eth_platform_data *pd;
 	struct net_device *dev = NULL;
 	db_dest_t *pDB, *pDBfree;
 	int irq, i, err = 0;
@@ -1142,6 +1106,26 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	*aup->enable = 0;
 	aup->mac_enabled = 0;
 
+	pd = pdev->dev.platform_data;
+	if (!pd) {
+		printk(KERN_INFO DRV_NAME ": no platform_data passed, PHY search on MAC0\n");
+		aup->phy1_search_mac0 = 1;
+	} else {
+		aup->phy_static_config = pd->phy_static_config;
+		aup->phy_search_highest_addr = pd->phy_search_highest_addr;
+		aup->phy1_search_mac0 = pd->phy1_search_mac0;
+		aup->phy_addr = pd->phy_addr;
+		aup->phy_busid = pd->phy_busid;
+		aup->phy_irq = pd->phy_irq;
+	}
+
+	if (aup->phy_busid && aup->phy_busid > 0) {
+		printk(KERN_ERR DRV_NAME ": MAC0-associated PHY attached 2nd MACs MII"
+				"bus not supported yet\n");
+		err = -ENODEV;
+		goto err_mdiobus_alloc;
+	}
+
 	aup->mii_bus = mdiobus_alloc();
 	if (aup->mii_bus == NULL) {
 		printk(KERN_ERR DRV_NAME ": failed to allocate mdiobus structure\n");
@@ -1159,16 +1143,10 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	for(i = 0; i < PHY_MAX_ADDR; ++i)
 		aup->mii_bus->irq[i] = PHY_POLL;
 	/* if known, set corresponding PHY IRQs */
-#if defined(AU1XXX_PHY_STATIC_CONFIG)
-# if defined(AU1XXX_PHY0_IRQ)
-	if (AU1XXX_PHY0_BUSID == aup->mac_id)
-		aup->mii_bus->irq[AU1XXX_PHY0_ADDR] = AU1XXX_PHY0_IRQ;
-# endif
-# if defined(AU1XXX_PHY1_IRQ)
-	if (AU1XXX_PHY1_BUSID == aup->mac_id)
-		aup->mii_bus->irq[AU1XXX_PHY1_ADDR] = AU1XXX_PHY1_IRQ;
-# endif
-#endif
+	if (aup->phy_static_config)
+		if (aup->phy_irq && aup->phy_busid == aup->mac_id)
+			aup->mii_bus->irq[aup->phy_addr] = aup->phy_irq;
+	
 	err = mdiobus_register(aup->mii_bus);
 	if (err) {
 		printk(KERN_ERR DRV_NAME " failed to register MDIO bus\n");
diff --git a/drivers/net/au1000_eth.h b/drivers/net/au1000_eth.h
index 824ecd5..f9d29a2 100644
--- a/drivers/net/au1000_eth.h
+++ b/drivers/net/au1000_eth.h
@@ -108,6 +108,15 @@ struct au1000_private {
 	struct phy_device *phy_dev;
 	struct mii_bus *mii_bus;
 
+	/* PHY configuration */
+	int phy_static_config;
+	int phy_search_highest_addr;
+	int phy1_search_mac0;
+
+	int phy_addr;
+	int phy_busid;
+	int phy_irq;
+
 	/* These variables are just for quick access to certain regs addresses. */
 	volatile mac_reg_t *mac;  /* mac registers                      */
 	volatile u32 *enable;     /* address of MAC Enable Register     */
