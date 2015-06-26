From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/3] net: bcmgenet: workaround initial read failures for integrated PHYs
Date: Fri, 26 Jun 2015 10:38:33 -0700
Message-ID: <1435340314-10229-4-git-send-email-f.fainelli@gmail.com>
References: <1435340314-10229-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:36721 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbbFZRkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 13:40:14 -0400
Received: by pdcu2 with SMTP id u2so78783865pdc.3
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 10:40:13 -0700 (PDT)
In-Reply-To: <1435340314-10229-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All BCM7xxx integrated Gigabit PHYs have an issue in their MDIO
management controller which will make the initial read or write to them
to fail and return 0xffff. This is a real issue as the typical first
thing we do is read from MII_PHYSID1 and MII_PHYSID2 from get_phy_id()
to register a driver for these PHYs.

Coupled with the workaround in drivers/net/phy/bcm7xxx.c, this
workaround for the MDIO bus controller consists in scanning the list of
PHYs to do this initial read workaround for as part of the MDIO bus
reset routine which is invoked prior to mdiobus_scan().

Once we have a proper PHY driver/device registered, all workarounds are
located there (e.g: power management suspend/resume calls).

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 54 ++++++++++++++++++++++++--
 2 files changed, 51 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 6f2887a5e0be..6159deab8c98 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -594,6 +594,7 @@ struct bcmgenet_priv {
 	wait_queue_head_t wq;
 	struct phy_device *phydev;
 	struct device_node *phy_dn;
+	struct device_node *mdio_dn;
 	struct mii_bus *mii_bus;
 	u16 gphy_rev;
 	struct clk *clk_eee;
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 6bef04e2f735..adf23d2ac488 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -408,6 +408,52 @@ static int bcmgenet_mii_probe(struct net_device *dev)
 	return 0;
 }
 
+/* Workaround for integrated BCM7xxx Gigabit PHYs which have a problem with
+ * their internal MDIO management controller making them fail to successfully
+ * be read from or written to for the first transaction.  We insert a dummy
+ * BMSR read here to make sure that phy_get_device() and get_phy_id() can
+ * correctly read the PHY MII_PHYSID1/2 registers and successfully register a
+ * PHY device for this peripheral.
+ *
+ * Once the PHY driver is registered, we can workaround subsequent reads from
+ * there (e.g: during system-wide power management).
+ *
+ * bus->reset is invoked before mdiobus_scan during mdiobus_register and is
+ * therefore the right location to stick that workaround. Since we do not want
+ * to read from non-existing PHYs, we either use bus->phy_mask or do a manual
+ * Device Tree scan to limit the search area.
+ */
+static int bcmgenet_mii_bus_reset(struct mii_bus *bus)
+{
+	struct net_device *dev = bus->priv;
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+	struct device_node *np = priv->mdio_dn;
+	struct device_node *child = NULL;
+	u32 read_mask = 0;
+	int addr = 0;
+
+	if (!np) {
+		read_mask = 1 << priv->phy_addr;
+	} else {
+		for_each_available_child_of_node(np, child) {
+			addr = of_mdio_parse_addr(&dev->dev, child);
+			if (addr < 0)
+				continue;
+
+			read_mask |= 1 << addr;
+		}
+	}
+
+	for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
+		if (read_mask & 1 << addr) {
+			dev_dbg(&dev->dev, "Workaround for PHY @ %d\n", addr);
+			mdiobus_read(bus, addr, MII_BMSR);
+		}
+	}
+
+	return 0;
+}
+
 static int bcmgenet_mii_alloc(struct bcmgenet_priv *priv)
 {
 	struct mii_bus *bus;
@@ -427,6 +473,7 @@ static int bcmgenet_mii_alloc(struct bcmgenet_priv *priv)
 	bus->parent = &priv->pdev->dev;
 	bus->read = bcmgenet_mii_read;
 	bus->write = bcmgenet_mii_write;
+	bus->reset = bcmgenet_mii_bus_reset;
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-%d",
 		 priv->pdev->name, priv->pdev->id);
 
@@ -443,7 +490,6 @@ static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
 {
 	struct device_node *dn = priv->pdev->dev.of_node;
 	struct device *kdev = &priv->pdev->dev;
-	struct device_node *mdio_dn;
 	char *compat;
 	int ret;
 
@@ -451,14 +497,14 @@ static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
 	if (!compat)
 		return -ENOMEM;
 
-	mdio_dn = of_find_compatible_node(dn, NULL, compat);
+	priv->mdio_dn = of_find_compatible_node(dn, NULL, compat);
 	kfree(compat);
-	if (!mdio_dn) {
+	if (!priv->mdio_dn) {
 		dev_err(kdev, "unable to find MDIO bus node\n");
 		return -ENODEV;
 	}
 
-	ret = of_mdiobus_register(priv->mii_bus, mdio_dn);
+	ret = of_mdiobus_register(priv->mii_bus, priv->mdio_dn);
 	if (ret) {
 		dev_err(kdev, "failed to register MDIO bus\n");
 		return ret;
-- 
2.1.0
