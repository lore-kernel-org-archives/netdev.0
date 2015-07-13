From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>
Subject: [RFC PATCH 2/2] net: macb: Add support for single mac managing more than one phy
Date: Mon, 13 Jul 2015 10:18:40 +0530
Message-ID: <1436762920-32107-3-git-send-email-punnaia@xilinx.com>
References: <1436762920-32107-1-git-send-email-punnaia@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: harinik@xilinx.com, kpc528@gmail.com,
	kalluripunnaiahchoudary@gmail.com, netdev@vger.kernel.org,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>
To: nicolas.ferre@atmel.com, michals@xilinx.com, anirudh@xilinx.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0053.outbound.protection.outlook.com ([207.46.100.53]:30752
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750970AbbGMEsz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2015 00:48:55 -0400
In-Reply-To: <1436762920-32107-1-git-send-email-punnaia@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added support for single mac managing more than one phy

Signed-off-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
---
 drivers/net/ethernet/cadence/macb.c |   25 ++++++++++++++++++++-----
 drivers/net/ethernet/cadence/macb.h |    4 +++-
 2 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 4833ba1..6d36b76 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -171,6 +171,7 @@ static int macb_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	struct macb *bp = bus->priv;
 	int value;
 
+	spin_lock(&bp->mdio_lock);
 	macb_writel(bp, MAN, (MACB_BF(SOF, MACB_MAN_SOF)
 			      | MACB_BF(RW, MACB_MAN_READ)
 			      | MACB_BF(PHYA, mii_id)
@@ -182,6 +183,7 @@ static int macb_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 		cpu_relax();
 
 	value = MACB_BFEXT(DATA, macb_readl(bp, MAN));
+	spin_unlock(&bp->mdio_lock);
 
 	return value;
 }
@@ -191,6 +193,7 @@ static int macb_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 {
 	struct macb *bp = bus->priv;
 
+	spin_lock(&bp->mdio_lock);
 	macb_writel(bp, MAN, (MACB_BF(SOF, MACB_MAN_SOF)
 			      | MACB_BF(RW, MACB_MAN_WRITE)
 			      | MACB_BF(PHYA, mii_id)
@@ -201,6 +204,7 @@ static int macb_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 	/* wait for end of transfer */
 	while (!MACB_BFEXT(IDLE, macb_readl(bp, NSR)))
 		cpu_relax();
+	spin_unlock(&bp->mdio_lock);
 
 	return 0;
 }
@@ -320,7 +324,7 @@ static int macb_mii_probe(struct net_device *dev)
 	int phy_irq;
 	int ret;
 
-	phydev = phy_find_first(bp->mii_bus);
+	phydev = of_phy_find_device(bp->phy_node);
 	if (!phydev) {
 		netdev_err(dev, "no PHY found\n");
 		return -ENXIO;
@@ -365,8 +369,14 @@ int macb_mii_init(struct macb *bp)
 	struct device_node *np;
 	int err = -ENXIO, i;
 
+	bp->phy_node = of_parse_phandle(bp->pdev->dev.of_node,
+						"phy-handle", 0);
+	np = of_get_parent(bp->phy_node);
 	/* Enable management port */
 	macb_writel(bp, NCR, MACB_BIT(MPE));
+	bp->mii_bus = of_mdio_find_bus(np);
+	if (!bp->has_mdio && bp->mii_bus)
+		goto mii_probe;
 
 	bp->mii_bus = mdiobus_alloc();
 	if (bp->mii_bus == NULL) {
@@ -425,6 +435,7 @@ int macb_mii_init(struct macb *bp)
 	if (err)
 		goto err_out_free_mdio_irq;
 
+mii_probe:
 	err = macb_mii_probe(bp->dev);
 	if (err)
 		goto err_out_unregister_bus;
@@ -2356,6 +2367,7 @@ static int macb_probe(struct platform_device *pdev)
 	bp->isjumbo = of_property_read_bool(pdev->dev.of_node,
 					    "jumbo-supported");
 	spin_lock_init(&bp->lock);
+	spin_lock_init(&bp->mdio_lock);
 
 	/* set the queue register mapping once for all: queue0 has a special
 	 * register mapping but we don't want to test the queue index then
@@ -2479,7 +2491,8 @@ static int macb_probe(struct platform_device *pdev)
 		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
 		goto err_out_free_netdev;
 	}
-
+	err = of_property_read_u32(bp->pdev->dev.of_node, "has-mdio",
+							&bp->has_mdio);
 	err = macb_mii_init(bp);
 	if (err)
 		goto err_out_unregister_netdev;
@@ -2524,9 +2537,11 @@ static int macb_remove(struct platform_device *pdev)
 		bp = netdev_priv(dev);
 		if (bp->phy_dev)
 			phy_disconnect(bp->phy_dev);
-		mdiobus_unregister(bp->mii_bus);
-		kfree(bp->mii_bus->irq);
-		mdiobus_free(bp->mii_bus);
+		if (bp->has_mdio) {
+			mdiobus_unregister(bp->mii_bus);
+			kfree(bp->mii_bus->irq);
+			mdiobus_free(bp->mii_bus);
+		}
 		unregister_netdev(dev);
 		if (!IS_ERR(bp->tx_clk))
 			clk_disable_unprepare(bp->tx_clk);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index f0aa177..0f99f2a 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -825,7 +825,9 @@ struct macb {
 	unsigned int		rx_frm_len_mask;
 	unsigned int		jumbo_max_len;
 	bool			isjumbo;
-
+	unsigned int has_mdio;
+	spinlock_t mdio_lock;
+	struct device_node *phy_node;
 	u64			ethtool_stats[GEM_STATS_LEN];
 };
 
-- 
1.7.4
