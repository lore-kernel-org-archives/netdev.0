From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH v4 1/3] ethernet: arc: remove use of 'struct platform_device'
Date: Tue, 26 Aug 2014 13:14:49 +0000
Message-ID: <1409058891-30790-1-git-send-email-romain.perier@gmail.com>
Cc: heiko@sntech.de, tklauser@distanz.ch, b.galvani@gmail.com,
	eric.dumazet@gmail.com, yongjun_wei@trendmicro.com.cn,
	f.fainelli@gmail.com, netdev@vger.kernel.org, arnd@arndb.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:34711 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754695AbaHZNOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 09:14:51 -0400
Received: by mail-wi0-f181.google.com with SMTP id bs8so4123777wib.14
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 06:14:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a preparation of an api changes for the emac_main.c module.
The involved functions are arc_emac_probe and arc_emac_remove.

Signed-off-by: Romain Perier <romain.perier@gmail.com>
---
 drivers/net/ethernet/arc/emac_main.c | 64 +++++++++++++++++++-----------------
 1 file changed, 33 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index fe5cfea..761b936 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -673,6 +673,7 @@ static const struct net_device_ops arc_emac_netdev_ops = {
 
 static int arc_emac_probe(struct platform_device *pdev)
 {
+	struct device *dev = &pdev->dev;
 	struct resource res_regs;
 	struct device_node *phy_node;
 	struct arc_emac_priv *priv;
@@ -681,27 +682,27 @@ static int arc_emac_probe(struct platform_device *pdev)
 	unsigned int id, clock_frequency, irq;
 	int err;
 
-	if (!pdev->dev.of_node)
+	if (!dev->of_node)
 		return -ENODEV;
 
 	/* Get PHY from device tree */
-	phy_node = of_parse_phandle(pdev->dev.of_node, "phy", 0);
+	phy_node = of_parse_phandle(dev->of_node, "phy", 0);
 	if (!phy_node) {
-		dev_err(&pdev->dev, "failed to retrieve phy description from device tree\n");
+		dev_err(dev, "failed to retrieve phy description from device tree\n");
 		return -ENODEV;
 	}
 
 	/* Get EMAC registers base address from device tree */
-	err = of_address_to_resource(pdev->dev.of_node, 0, &res_regs);
+	err = of_address_to_resource(dev->of_node, 0, &res_regs);
 	if (err) {
-		dev_err(&pdev->dev, "failed to retrieve registers base from device tree\n");
+		dev_err(dev, "failed to retrieve registers base from device tree\n");
 		return -ENODEV;
 	}
 
 	/* Get IRQ from device tree */
-	irq = irq_of_parse_and_map(pdev->dev.of_node, 0);
+	irq = irq_of_parse_and_map(dev->of_node, 0);
 	if (!irq) {
-		dev_err(&pdev->dev, "failed to retrieve <irq> value from device tree\n");
+		dev_err(dev, "failed to retrieve <irq> value from device tree\n");
 		return -ENODEV;
 	}
 
@@ -709,8 +710,8 @@ static int arc_emac_probe(struct platform_device *pdev)
 	if (!ndev)
 		return -ENOMEM;
 
-	platform_set_drvdata(pdev, ndev);
-	SET_NETDEV_DEV(ndev, &pdev->dev);
+	dev_set_drvdata(dev, ndev);
+	SET_NETDEV_DEV(ndev, dev);
 
 	ndev->netdev_ops = &arc_emac_netdev_ops;
 	ndev->ethtool_ops = &arc_emac_ethtool_ops;
@@ -719,28 +720,28 @@ static int arc_emac_probe(struct platform_device *pdev)
 	ndev->flags &= ~IFF_MULTICAST;
 
 	priv = netdev_priv(ndev);
-	priv->dev = &pdev->dev;
+	priv->dev = dev;
 
-	priv->regs = devm_ioremap_resource(&pdev->dev, &res_regs);
+	priv->regs = devm_ioremap_resource(dev, &res_regs);
 	if (IS_ERR(priv->regs)) {
 		err = PTR_ERR(priv->regs);
 		goto out_netdev;
 	}
-	dev_dbg(&pdev->dev, "Registers base address is 0x%p\n", priv->regs);
+	dev_dbg(dev, "Registers base address is 0x%p\n", priv->regs);
 
-	priv->clk = of_clk_get(pdev->dev.of_node, 0);
+	priv->clk = of_clk_get(dev->of_node, 0);
 	if (IS_ERR(priv->clk)) {
 		/* Get CPU clock frequency from device tree */
-		if (of_property_read_u32(pdev->dev.of_node, "clock-frequency",
+		if (of_property_read_u32(dev->of_node, "clock-frequency",
 					&clock_frequency)) {
-			dev_err(&pdev->dev, "failed to retrieve <clock-frequency> from device tree\n");
+			dev_err(dev, "failed to retrieve <clock-frequency> from device tree\n");
 			err = -EINVAL;
 			goto out_netdev;
 		}
 	} else {
 		err = clk_prepare_enable(priv->clk);
 		if (err) {
-			dev_err(&pdev->dev, "failed to enable clock\n");
+			dev_err(dev, "failed to enable clock\n");
 			goto out_clkget;
 		}
 
@@ -751,28 +752,28 @@ static int arc_emac_probe(struct platform_device *pdev)
 
 	/* Check for EMAC revision 5 or 7, magic number */
 	if (!(id == 0x0005fd02 || id == 0x0007fd02)) {
-		dev_err(&pdev->dev, "ARC EMAC not detected, id=0x%x\n", id);
+		dev_err(dev, "ARC EMAC not detected, id=0x%x\n", id);
 		err = -ENODEV;
 		goto out_clken;
 	}
-	dev_info(&pdev->dev, "ARC EMAC detected with id: 0x%x\n", id);
+	dev_info(dev, "ARC EMAC detected with id: 0x%x\n", id);
 
 	/* Set poll rate so that it polls every 1 ms */
 	arc_reg_set(priv, R_POLLRATE, clock_frequency / 1000000);
 
 	ndev->irq = irq;
-	dev_info(&pdev->dev, "IRQ is %d\n", ndev->irq);
+	dev_info(dev, "IRQ is %d\n", ndev->irq);
 
 	/* Register interrupt handler for device */
-	err = devm_request_irq(&pdev->dev, ndev->irq, arc_emac_intr, 0,
+	err = devm_request_irq(dev, ndev->irq, arc_emac_intr, 0,
 			       ndev->name, ndev);
 	if (err) {
-		dev_err(&pdev->dev, "could not allocate IRQ\n");
+		dev_err(dev, "could not allocate IRQ\n");
 		goto out_clken;
 	}
 
 	/* Get MAC address from device tree */
-	mac_addr = of_get_mac_address(pdev->dev.of_node);
+	mac_addr = of_get_mac_address(dev->of_node);
 
 	if (mac_addr)
 		memcpy(ndev->dev_addr, mac_addr, ETH_ALEN);
@@ -780,14 +781,14 @@ static int arc_emac_probe(struct platform_device *pdev)
 		eth_hw_addr_random(ndev);
 
 	arc_emac_set_address_internal(ndev);
-	dev_info(&pdev->dev, "MAC address is now %pM\n", ndev->dev_addr);
+	dev_info(dev, "MAC address is now %pM\n", ndev->dev_addr);
 
 	/* Do 1 allocation instead of 2 separate ones for Rx and Tx BD rings */
-	priv->rxbd = dmam_alloc_coherent(&pdev->dev, RX_RING_SZ + TX_RING_SZ,
+	priv->rxbd = dmam_alloc_coherent(dev, RX_RING_SZ + TX_RING_SZ,
 					 &priv->rxbd_dma, GFP_KERNEL);
 
 	if (!priv->rxbd) {
-		dev_err(&pdev->dev, "failed to allocate data buffers\n");
+		dev_err(dev, "failed to allocate data buffers\n");
 		err = -ENOMEM;
 		goto out_clken;
 	}
@@ -795,31 +796,31 @@ static int arc_emac_probe(struct platform_device *pdev)
 	priv->txbd = priv->rxbd + RX_BD_NUM;
 
 	priv->txbd_dma = priv->rxbd_dma + RX_RING_SZ;
-	dev_dbg(&pdev->dev, "EMAC Device addr: Rx Ring [0x%x], Tx Ring[%x]\n",
+	dev_dbg(dev, "EMAC Device addr: Rx Ring [0x%x], Tx Ring[%x]\n",
 		(unsigned int)priv->rxbd_dma, (unsigned int)priv->txbd_dma);
 
 	err = arc_mdio_probe(pdev, priv);
 	if (err) {
-		dev_err(&pdev->dev, "failed to probe MII bus\n");
+		dev_err(dev, "failed to probe MII bus\n");
 		goto out_clken;
 	}
 
 	priv->phy_dev = of_phy_connect(ndev, phy_node, arc_emac_adjust_link, 0,
 				       PHY_INTERFACE_MODE_MII);
 	if (!priv->phy_dev) {
-		dev_err(&pdev->dev, "of_phy_connect() failed\n");
+		dev_err(dev, "of_phy_connect() failed\n");
 		err = -ENODEV;
 		goto out_mdio;
 	}
 
-	dev_info(&pdev->dev, "connected to %s phy with id 0x%x\n",
+	dev_info(dev, "connected to %s phy with id 0x%x\n",
 		 priv->phy_dev->drv->name, priv->phy_dev->phy_id);
 
 	netif_napi_add(ndev, &priv->napi, arc_emac_poll, ARC_EMAC_NAPI_WEIGHT);
 
 	err = register_netdev(ndev);
 	if (err) {
-		dev_err(&pdev->dev, "failed to register network device\n");
+		dev_err(dev, "failed to register network device\n");
 		goto out_netif_api;
 	}
 
@@ -844,7 +845,8 @@ out_netdev:
 
 static int arc_emac_remove(struct platform_device *pdev)
 {
-	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct device *dev = &pdev->dev;
+	struct net_device *ndev = dev_get_drvdata(dev);
 	struct arc_emac_priv *priv = netdev_priv(ndev);
 
 	phy_disconnect(priv->phy_dev);
-- 
1.9.1
