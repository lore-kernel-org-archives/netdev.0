From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 09/12] net: axienet: Use devm_* calls
Date: Tue,  5 May 2015 11:26:02 +0200
Message-ID: <ad3095e6ad3fe3b99e2f42c53a6c1d2419595e62.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Cc: Srikanth Thokala <srikanth.thokala@xilinx.com>,
	=?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	monstr@monstr.eu, John Linn <John.Linn@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srikanth Thokala <srikanth.thokala@xilinx.com>

use devm_* calls

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 54 +++++++++++------------
 1 file changed, 27 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 757b2dc30cef..49ae4d50774d 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1499,6 +1499,7 @@ static int axienet_of_probe(struct platform_device *pdev)
 	struct axienet_local *lp;
 	struct net_device *ndev;
 	const void *addr;
+	struct resource *ethres, dmares;
 
 	ndev = alloc_etherdev(sizeof(*lp));
 	if (!ndev)
@@ -1517,12 +1518,14 @@ static int axienet_of_probe(struct platform_device *pdev)
 	lp->dev = &pdev->dev;
 	lp->options = XAE_OPTION_DEFAULTS;
 	/* Map device registers */
-	lp->regs = of_iomap(pdev->dev.of_node, 0);
+	ethres = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	lp->regs = devm_ioremap_resource(&pdev->dev, ethres);
 	if (!lp->regs) {
 		dev_err(&pdev->dev, "could not map Axi Ethernet regs.\n");
 		ret = -ENOMEM;
-		goto nodev;
+		goto free_netdev;
 	}
+
 	/* Setup checksum offload, but default to off if not specified */
 	lp->features = 0;
 
@@ -1580,17 +1583,21 @@ static int axienet_of_probe(struct platform_device *pdev)
 
 	/* Find the DMA node, map the DMA registers, and decode the DMA IRQs */
 	np = of_parse_phandle(pdev->dev.of_node, "axistream-connected", 0);
-	if (!np) {
+	if (IS_ERR(np)) {
 		dev_err(&pdev->dev, "could not find DMA node\n");
-		ret = -ENODEV;
-		goto err_iounmap;
+		ret = PTR_ERR(np);
+		goto free_netdev;
 	}
-	lp->dma_regs = of_iomap(np, 0);
-	if (lp->dma_regs) {
-		dev_dbg(&pdev->dev, "MEM base: %p\n", lp->dma_regs);
-	} else {
-		dev_err(&pdev->dev, "unable to map DMA registers\n");
-		of_node_put(np);
+	ret = of_address_to_resource(np, 0, &dmares);
+	if (ret) {
+		dev_err(&pdev->dev, "unable to get DMA resource\n");
+		goto free_netdev;
+	}
+	lp->dma_regs = devm_ioremap_resource(&pdev->dev, &dmares);
+	if (!lp->dma_regs) {
+		dev_err(&pdev->dev, "could not map DMA regs\n");
+		ret = -ENOMEM;
+		goto free_netdev;
 	}
 	lp->rx_irq = irq_of_parse_and_map(np, 1);
 	lp->tx_irq = irq_of_parse_and_map(np, 0);
@@ -1598,7 +1605,7 @@ static int axienet_of_probe(struct platform_device *pdev)
 	if ((lp->rx_irq <= 0) || (lp->tx_irq <= 0)) {
 		dev_err(&pdev->dev, "could not determine irqs\n");
 		ret = -ENOMEM;
-		goto err_iounmap_2;
+		goto free_netdev;
 	}
 
 	/* Retrieve the MAC address */
@@ -1606,7 +1613,7 @@ static int axienet_of_probe(struct platform_device *pdev)
 	if ((!addr) || (size != 6)) {
 		dev_err(&pdev->dev, "could not find MAC address\n");
 		ret = -ENODEV;
-		goto err_iounmap_2;
+		goto free_netdev;
 	}
 	axienet_set_mac_address(ndev, (void *) addr);
 
@@ -1614,27 +1621,23 @@ static int axienet_of_probe(struct platform_device *pdev)
 	lp->coalesce_count_tx = XAXIDMA_DFT_TX_THRESHOLD;
 
 	lp->phy_node = of_parse_phandle(pdev->dev.of_node, "phy-handle", 0);
-	if (lp->phy_node)
+	if (lp->phy_node) {
 		ret = axienet_mdio_setup(lp, pdev->dev.of_node);
-	if (ret)
-		dev_warn(&pdev->dev, "error registering MDIO bus\n");
+		if (ret)
+			dev_warn(&pdev->dev, "error registering MDIO bus\n");
+	}
 
 	ret = register_netdev(lp->ndev);
 	if (ret) {
 		dev_err(lp->dev, "register_netdev() error (%i)\n", ret);
-		goto err_iounmap_2;
+		goto free_netdev;
 	}
 
 	return 0;
 
-err_iounmap_2:
-	if (lp->dma_regs)
-		iounmap(lp->dma_regs);
-err_iounmap:
-	iounmap(lp->regs);
-nodev:
+free_netdev:
 	free_netdev(ndev);
-	ndev = NULL;
+
 	return ret;
 }
 
@@ -1649,9 +1652,6 @@ static int axienet_of_remove(struct platform_device *pdev)
 	of_node_put(lp->phy_node);
 	lp->phy_node = NULL;
 
-	iounmap(lp->regs);
-	if (lp->dma_regs)
-		iounmap(lp->dma_regs);
 	free_netdev(ndev);
 
 	return 0;
-- 
2.3.5
