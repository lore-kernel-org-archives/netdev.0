From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH v2 5/8] net/macb: fix probe sequence to setup clocks earlier
Date: Tue, 31 Mar 2015 15:02:03 +0200
Message-ID: <1427806926-18887-6-git-send-email-nicolas.ferre@atmel.com>
References: <1427806926-18887-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	<michal.simek@xilinx.com>, <punnaia@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427806926-18887-1-git-send-email-nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As accessing the peripheral registers need the clocks to be set, we have to
enable them as soon as possible. Their configuration depend on the type of
device used and determined by the DT compatible string. That lead to add
another initialization function in the DT configuration structure.
As the device private structure length depend on an information read in the
registers, we have to store the clock pointers in temporary variables before
feeding the structure fields.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---

Changes in v2:
- add fixes for probe sequence related to clocks

 drivers/net/ethernet/cadence/macb.c | 169 ++++++++++++++++++++++--------------
 drivers/net/ethernet/cadence/macb.h |   2 +
 2 files changed, 104 insertions(+), 67 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index e27bc6964402..205f4b86d9da 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2184,51 +2184,67 @@ static void macb_probe_queues(void __iomem *mem,
 			(*num_queues)++;
 }
 
-static int macb_init(struct platform_device *pdev)
+static int macb_clk_init(struct platform_device *pdev, struct clk **pclk,
+			 struct clk **hclk, struct clk **tx_clk)
 {
-	struct net_device *dev = platform_get_drvdata(pdev);
-	unsigned int hw_q, q;
-	struct macb *bp = netdev_priv(dev);
-	struct macb_queue *queue;
 	int err;
-	u32 val;
 
-	bp->pclk = devm_clk_get(&pdev->dev, "pclk");
-	if (IS_ERR(bp->pclk)) {
-		err = PTR_ERR(bp->pclk);
+	*pclk = devm_clk_get(&pdev->dev, "pclk");
+	if (IS_ERR(*pclk)) {
+		err = PTR_ERR(*pclk);
 		dev_err(&pdev->dev, "failed to get macb_clk (%u)\n", err);
 		return err;
 	}
 
-	bp->hclk = devm_clk_get(&pdev->dev, "hclk");
-	if (IS_ERR(bp->hclk)) {
-		err = PTR_ERR(bp->hclk);
+	*hclk = devm_clk_get(&pdev->dev, "hclk");
+	if (IS_ERR(*hclk)) {
+		err = PTR_ERR(*hclk);
 		dev_err(&pdev->dev, "failed to get hclk (%u)\n", err);
 		return err;
 	}
 
-	bp->tx_clk = devm_clk_get(&pdev->dev, "tx_clk");
-	if (IS_ERR(bp->tx_clk))
-		bp->tx_clk = NULL;
+	*tx_clk = devm_clk_get(&pdev->dev, "tx_clk");
+	if (IS_ERR(*tx_clk))
+		*tx_clk = NULL;
 
-	err = clk_prepare_enable(bp->pclk);
+	err = clk_prepare_enable(*pclk);
 	if (err) {
 		dev_err(&pdev->dev, "failed to enable pclk (%u)\n", err);
 		return err;
 	}
 
-	err = clk_prepare_enable(bp->hclk);
+	err = clk_prepare_enable(*hclk);
 	if (err) {
 		dev_err(&pdev->dev, "failed to enable hclk (%u)\n", err);
 		goto err_disable_pclk;
 	}
 
-	err = clk_prepare_enable(bp->tx_clk);
+	err = clk_prepare_enable(*tx_clk);
 	if (err) {
 		dev_err(&pdev->dev, "failed to enable tx_clk (%u)\n", err);
 		goto err_disable_hclk;
 	}
 
+	return 0;
+
+err_disable_hclk:
+	clk_disable_unprepare(*hclk);
+
+err_disable_pclk:
+	clk_disable_unprepare(*pclk);
+
+	return err;
+}
+
+static int macb_init(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	unsigned int hw_q, q;
+	struct macb *bp = netdev_priv(dev);
+	struct macb_queue *queue;
+	int err;
+	u32 val;
+
 	/* set the queue register mapping once for all: queue0 has a special
 	 * register mapping but we don't want to test the queue index then
 	 * compute the corresponding register offset at run time.
@@ -2266,7 +2282,7 @@ static int macb_init(struct platform_device *pdev)
 			dev_err(&pdev->dev,
 				"Unable to request IRQ %d (error %d)\n",
 				queue->irq, err);
-			goto err_disable_tx_clk;
+			return err;
 		}
 
 		INIT_WORK(&queue->tx_error_task, macb_tx_error_task);
@@ -2322,17 +2338,6 @@ static int macb_init(struct platform_device *pdev)
 	macb_writel(bp, NCFGR, val);
 
 	return 0;
-
-err_disable_tx_clk:
-	clk_disable_unprepare(bp->tx_clk);
-
-err_disable_hclk:
-	clk_disable_unprepare(bp->hclk);
-
-err_disable_pclk:
-	clk_disable_unprepare(bp->pclk);
-
-	return err;
 }
 
 #if defined(CONFIG_OF)
@@ -2600,30 +2605,41 @@ static const struct net_device_ops at91ether_netdev_ops = {
 #endif
 };
 
-static int at91ether_init(struct platform_device *pdev)
+static int at91ether_clk_init(struct platform_device *pdev, struct clk **pclk,
+			      struct clk **hclk, struct clk **tx_clk)
 {
-	struct net_device *dev = platform_get_drvdata(pdev);
-	struct macb *bp = netdev_priv(dev);
 	int err;
-	u32 reg;
 
-	bp->pclk = devm_clk_get(&pdev->dev, "ether_clk");
-	if (IS_ERR(bp->pclk))
-		return PTR_ERR(bp->pclk);
+	*hclk = NULL;
+	*tx_clk = NULL;
+
+	*pclk = devm_clk_get(&pdev->dev, "ether_clk");
+	if (IS_ERR(*pclk))
+		return PTR_ERR(*pclk);
 
-	err = clk_prepare_enable(bp->pclk);
+	err = clk_prepare_enable(*pclk);
 	if (err) {
 		dev_err(&pdev->dev, "failed to enable pclk (%u)\n", err);
 		return err;
 	}
 
+	return 0;
+}
+
+static int at91ether_init(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct macb *bp = netdev_priv(dev);
+	int err;
+	u32 reg;
+
 	dev->netdev_ops = &at91ether_netdev_ops;
 	dev->ethtool_ops = &macb_ethtool_ops;
 
 	err = devm_request_irq(&pdev->dev, dev->irq, at91ether_interrupt,
 			       0, dev->name, dev);
 	if (err)
-		goto err_disable_clk;
+		return err;
 
 	macb_writel(bp, NCR, 0);
 
@@ -2634,37 +2650,37 @@ static int at91ether_init(struct platform_device *pdev)
 	macb_writel(bp, NCFGR, reg);
 
 	return 0;
-
-err_disable_clk:
-	clk_disable_unprepare(bp->pclk);
-
-	return err;
 }
 
 static const struct macb_config at91sam9260_config = {
 	.caps = MACB_CAPS_USRIO_HAS_CLKEN | MACB_CAPS_USRIO_DEFAULT_IS_MII,
+	.clk_init = macb_clk_init,
 	.init = macb_init,
 };
 
 static const struct macb_config pc302gem_config = {
 	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
 	.dma_burst_length = 16,
+	.clk_init = macb_clk_init,
 	.init = macb_init,
 };
 
 static const struct macb_config sama5d3_config = {
 	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
 	.dma_burst_length = 16,
+	.clk_init = macb_clk_init,
 	.init = macb_init,
 };
 
 static const struct macb_config sama5d4_config = {
 	.caps = 0,
 	.dma_burst_length = 4,
+	.clk_init = macb_clk_init,
 	.init = macb_init,
 };
 
 static const struct macb_config emac_config = {
+	.clk_init = at91ether_clk_init,
 	.init = at91ether_init,
 };
 
@@ -2685,9 +2701,13 @@ MODULE_DEVICE_TABLE(of, macb_dt_ids);
 
 static int macb_probe(struct platform_device *pdev)
 {
+	int (*clk_init)(struct platform_device *, struct clk **,
+			struct clk **, struct clk **)
+					      = macb_clk_init;
 	int (*init)(struct platform_device *) = macb_init;
 	struct device_node *np = pdev->dev.of_node;
 	const struct macb_config *macb_config = NULL;
+	struct clk *pclk, *hclk, *tx_clk;
 	unsigned int queue_mask, num_queues;
 	struct macb_platform_data *pdata;
 	struct phy_device *phydev;
@@ -2698,15 +2718,34 @@ static int macb_probe(struct platform_device *pdev)
 	struct macb *bp;
 	int err;
 
+	if (np) {
+		const struct of_device_id *match;
+
+		match = of_match_node(macb_dt_ids, np);
+		if (match && match->data) {
+			macb_config = match->data;
+			clk_init = macb_config->clk_init;
+			init = macb_config->init;
+		}
+	}
+
+	err = clk_init(pdev, &pclk, &hclk, &tx_clk);
+	if (err)
+		return err;
+
 	regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	mem = devm_ioremap_resource(&pdev->dev, regs);
-	if (IS_ERR(mem))
-		return PTR_ERR(mem);
+	if (IS_ERR(mem)) {
+		err = PTR_ERR(mem);
+		goto err_disable_clocks;
+	}
 
 	macb_probe_queues(mem, &queue_mask, &num_queues);
 	dev = alloc_etherdev_mq(sizeof(*bp), num_queues);
-	if (!dev)
-		return -ENOMEM;
+	if (!dev) {
+		err = -ENOMEM;
+		goto err_disable_clocks;
+	}
 
 	dev->base_addr = regs->start;
 
@@ -2718,27 +2757,23 @@ static int macb_probe(struct platform_device *pdev)
 	bp->regs = mem;
 	bp->num_queues = num_queues;
 	bp->queue_mask = queue_mask;
+	if (macb_config)
+		bp->dma_burst_length = macb_config->dma_burst_length;
+	bp->pclk = pclk;
+	bp->hclk = hclk;
+	bp->tx_clk = tx_clk;
 	spin_lock_init(&bp->lock);
 
-	if (np) {
-		const struct of_device_id *match;
-
-		match = of_match_node(macb_dt_ids, np);
-		if (match && match->data) {
-			macb_config = match->data;
-			bp->dma_burst_length = macb_config->dma_burst_length;
-			init = macb_config->init;
-		}
-	}
-
 	/* setup capabilities */
 	macb_configure_caps(bp, macb_config);
 
 	platform_set_drvdata(pdev, dev);
 
 	dev->irq = platform_get_irq(pdev, 0);
-	if (dev->irq < 0)
-		return dev->irq;
+	if (dev->irq < 0) {
+		err = dev->irq;
+		goto err_disable_clocks;
+	}
 
 	mac = of_get_mac_address(np);
 	if (mac)
@@ -2765,7 +2800,7 @@ static int macb_probe(struct platform_device *pdev)
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
-		goto err_disable_clocks;
+		goto err_out_unregister_netdev;
 	}
 
 	err = macb_mii_init(bp);
@@ -2787,14 +2822,14 @@ static int macb_probe(struct platform_device *pdev)
 err_out_unregister_netdev:
 	unregister_netdev(dev);
 
-err_disable_clocks:
-	clk_disable_unprepare(bp->tx_clk);
-	clk_disable_unprepare(bp->hclk);
-	clk_disable_unprepare(bp->pclk);
-
 err_out_free_netdev:
 	free_netdev(dev);
 
+err_disable_clocks:
+	clk_disable_unprepare(tx_clk);
+	clk_disable_unprepare(hclk);
+	clk_disable_unprepare(pclk);
+
 	return err;
 }
 
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 0b6afac91bfe..5f9950e84c5e 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -754,6 +754,8 @@ struct macb_or_gem_ops {
 struct macb_config {
 	u32			caps;
 	unsigned int		dma_burst_length;
+	int	(*clk_init)(struct platform_device *pdev, struct clk **pclk,
+			    struct clk **hclk, struct clk **tx_clk);
 	int	(*init)(struct platform_device *pdev);
 };
 
-- 
2.1.3
