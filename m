From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 6/7] net: bcmgenet: Drop legacy MDIO code
Date: Mon, 31 Jul 2017 12:04:27 -0700
Message-ID: <20170731190429.24204-7-f.fainelli@gmail.com>
References: <20170731190429.24204-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, jaedon.shin@gmail.com,
        pgynther@google.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33521 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751535AbdGaTEv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 15:04:51 -0400
Received: by mail-wr0-f195.google.com with SMTP id y43so32291857wrd.0
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 12:04:50 -0700 (PDT)
In-Reply-To: <20170731190429.24204-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have fully migrated to the mdio-bcm-unimac driver, drop the
legacy MDIO bus code which did duplicate a fair amount of code.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmmii.c | 125 ---------------------------
 1 file changed, 125 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 368d5eab306b..7fdc352628f9 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -28,59 +28,6 @@
 
 #include "bcmgenet.h"
 
-/* read a value from the MII */
-static int bcmgenet_mii_read(struct mii_bus *bus, int phy_id, int location)
-{
-	int ret;
-	struct net_device *dev = bus->priv;
-	struct bcmgenet_priv *priv = netdev_priv(dev);
-	u32 reg;
-
-	bcmgenet_umac_writel(priv, (MDIO_RD | (phy_id << MDIO_PMD_SHIFT) |
-			     (location << MDIO_REG_SHIFT)), UMAC_MDIO_CMD);
-	/* Start MDIO transaction*/
-	reg = bcmgenet_umac_readl(priv, UMAC_MDIO_CMD);
-	reg |= MDIO_START_BUSY;
-	bcmgenet_umac_writel(priv, reg, UMAC_MDIO_CMD);
-	wait_event_timeout(priv->wq,
-			   !(bcmgenet_umac_readl(priv, UMAC_MDIO_CMD)
-			   & MDIO_START_BUSY),
-			   HZ / 100);
-	ret = bcmgenet_umac_readl(priv, UMAC_MDIO_CMD);
-
-	/* Some broken devices are known not to release the line during
-	 * turn-around, e.g: Broadcom BCM53125 external switches, so check for
-	 * that condition here and ignore the MDIO controller read failure
-	 * indication.
-	 */
-	if (!(bus->phy_ignore_ta_mask & 1 << phy_id) && (ret & MDIO_READ_FAIL))
-		return -EIO;
-
-	return ret & 0xffff;
-}
-
-/* write a value to the MII */
-static int bcmgenet_mii_write(struct mii_bus *bus, int phy_id,
-			      int location, u16 val)
-{
-	struct net_device *dev = bus->priv;
-	struct bcmgenet_priv *priv = netdev_priv(dev);
-	u32 reg;
-
-	bcmgenet_umac_writel(priv, (MDIO_WR | (phy_id << MDIO_PMD_SHIFT) |
-			     (location << MDIO_REG_SHIFT) | (0xffff & val)),
-			     UMAC_MDIO_CMD);
-	reg = bcmgenet_umac_readl(priv, UMAC_MDIO_CMD);
-	reg |= MDIO_START_BUSY;
-	bcmgenet_umac_writel(priv, reg, UMAC_MDIO_CMD);
-	wait_event_timeout(priv->wq,
-			   !(bcmgenet_umac_readl(priv, UMAC_MDIO_CMD) &
-			   MDIO_START_BUSY),
-			   HZ / 100);
-
-	return 0;
-}
-
 /* setup netdev link state when PHY link status change and
  * update UMAC and RGMII block when link up
  */
@@ -393,78 +340,6 @@ int bcmgenet_mii_probe(struct net_device *dev)
 	return 0;
 }
 
-/* Workaround for integrated BCM7xxx Gigabit PHYs which have a problem with
- * their internal MDIO management controller making them fail to successfully
- * be read from or written to for the first transaction.  We insert a dummy
- * BMSR read here to make sure that phy_get_device() and get_phy_id() can
- * correctly read the PHY MII_PHYSID1/2 registers and successfully register a
- * PHY device for this peripheral.
- *
- * Once the PHY driver is registered, we can workaround subsequent reads from
- * there (e.g: during system-wide power management).
- *
- * bus->reset is invoked before mdiobus_scan during mdiobus_register and is
- * therefore the right location to stick that workaround. Since we do not want
- * to read from non-existing PHYs, we either use bus->phy_mask or do a manual
- * Device Tree scan to limit the search area.
- */
-static int bcmgenet_mii_bus_reset(struct mii_bus *bus)
-{
-	struct net_device *dev = bus->priv;
-	struct bcmgenet_priv *priv = netdev_priv(dev);
-	struct device_node *np = priv->mdio_dn;
-	struct device_node *child = NULL;
-	u32 read_mask = 0;
-	int addr = 0;
-
-	if (!np) {
-		read_mask = 1 << priv->phy_addr;
-	} else {
-		for_each_available_child_of_node(np, child) {
-			addr = of_mdio_parse_addr(&dev->dev, child);
-			if (addr < 0)
-				continue;
-
-			read_mask |= 1 << addr;
-		}
-	}
-
-	for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
-		if (read_mask & 1 << addr) {
-			dev_dbg(&dev->dev, "Workaround for PHY @ %d\n", addr);
-			mdiobus_read(bus, addr, MII_BMSR);
-		}
-	}
-
-	return 0;
-}
-
-static int bcmgenet_mii_alloc(struct bcmgenet_priv *priv)
-{
-	struct mii_bus *bus;
-
-	if (priv->mii_bus)
-		return 0;
-
-	priv->mii_bus = mdiobus_alloc();
-	if (!priv->mii_bus) {
-		pr_err("failed to allocate\n");
-		return -ENOMEM;
-	}
-
-	bus = priv->mii_bus;
-	bus->priv = priv->dev;
-	bus->name = "bcmgenet MII bus";
-	bus->parent = &priv->pdev->dev;
-	bus->read = bcmgenet_mii_read;
-	bus->write = bcmgenet_mii_write;
-	bus->reset = bcmgenet_mii_bus_reset;
-	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-%d",
-		 priv->pdev->name, priv->pdev->id);
-
-	return 0;
-}
-
 static struct device_node *bcmgenet_mii_of_find_mdio(struct bcmgenet_priv *priv)
 {
 	struct device_node *dn = priv->pdev->dev.of_node;
-- 
2.9.3
