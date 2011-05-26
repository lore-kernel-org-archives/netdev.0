From: Johan Hovold <jhovold@gmail.com>
Subject: [PATCH] net: davinci_emac: fix dev_err use at probe
Date: Thu, 26 May 2011 16:37:32 +0200
Message-ID: <1306420652-30001-1-git-send-email-jhovold@gmail.com>
Cc: netdev@vger.kernel.org, Johan Hovold <jhovold@gmail.com>
To: Cyril Chemparathy <cyril@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Sriramakrishnan A G <srk@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:61060 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757511Ab1EZOiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 10:38:05 -0400
Received: by eyx24 with SMTP id 24so311561eyx.19
        for <netdev@vger.kernel.org>; Thu, 26 May 2011 07:38:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use platform device rather than net device in dev_err calls before net
device has been registered to avoid messages such as

	(null): DaVinci EMAC: Failed to get EMAC clock

Also replace remaining printks in probe with dev_{err,warn}.

Signed-off-by: Johan Hovold <jhovold@gmail.com>
---
 drivers/net/davinci_emac.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 807b6bb..29a4f06 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -1772,7 +1772,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	/* obtain emac clock from kernel */
 	emac_clk = clk_get(&pdev->dev, NULL);
 	if (IS_ERR(emac_clk)) {
-		printk(KERN_ERR "DaVinci EMAC: Failed to get EMAC clock\n");
+		dev_err(&pdev->dev, "failed to get EMAC clock\n");
 		return -EBUSY;
 	}
 	emac_bus_frequency = clk_get_rate(emac_clk);
@@ -1780,7 +1780,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 
 	ndev = alloc_etherdev(sizeof(struct emac_priv));
 	if (!ndev) {
-		printk(KERN_ERR "DaVinci EMAC: Error allocating net_device\n");
+		dev_err(&pdev->dev, "error allocating net_device\n");
 		clk_put(emac_clk);
 		return -ENOMEM;
 	}
@@ -1795,7 +1795,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 
 	pdata = pdev->dev.platform_data;
 	if (!pdata) {
-		printk(KERN_ERR "DaVinci EMAC: No platform data\n");
+		dev_err(&pdev->dev, "no platform data\n");
 		return -ENODEV;
 	}
 
@@ -1814,7 +1814,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	/* Get EMAC platform data */
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!res) {
-		dev_err(emac_dev, "DaVinci EMAC: Error getting res\n");
+		dev_err(&pdev->dev,"error getting res\n");
 		rc = -ENOENT;
 		goto probe_quit;
 	}
@@ -1822,14 +1822,14 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	priv->emac_base_phys = res->start + pdata->ctrl_reg_offset;
 	size = res->end - res->start + 1;
 	if (!request_mem_region(res->start, size, ndev->name)) {
-		dev_err(emac_dev, "DaVinci EMAC: failed request_mem_region() for regs\n");
+		dev_err(&pdev->dev, "failed request_mem_region() for regs\n");
 		rc = -ENXIO;
 		goto probe_quit;
 	}
 
 	priv->remap_addr = ioremap(res->start, size);
 	if (!priv->remap_addr) {
-		dev_err(emac_dev, "Unable to map IO\n");
+		dev_err(&pdev->dev, "unable to map IO\n");
 		rc = -ENOMEM;
 		release_mem_region(res->start, size);
 		goto probe_quit;
@@ -1863,7 +1863,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 
 	priv->dma = cpdma_ctlr_create(&dma_params);
 	if (!priv->dma) {
-		dev_err(emac_dev, "DaVinci EMAC: Error initializing DMA\n");
+		dev_err(&pdev->dev, "error initializing DMA\n");
 		rc = -ENOMEM;
 		goto no_dma;
 	}
@@ -1879,7 +1879,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
 	if (!res) {
-		dev_err(emac_dev, "DaVinci EMAC: Error getting irq res\n");
+		dev_err(&pdev->dev, "error getting irq res\n");
 		rc = -ENOENT;
 		goto no_irq_res;
 	}
@@ -1888,8 +1888,8 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	if (!is_valid_ether_addr(priv->mac_addr)) {
 		/* Use random MAC if none passed */
 		random_ether_addr(priv->mac_addr);
-		printk(KERN_WARNING "%s: using random MAC addr: %pM\n",
-				__func__, priv->mac_addr);
+		dev_warn(&pdev->dev, "using random MAC addr: %pM\n",
+							priv->mac_addr);
 	}
 
 	ndev->netdev_ops = &emac_netdev_ops;
@@ -1902,7 +1902,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 	rc = register_netdev(ndev);
 	if (rc) {
-		dev_err(emac_dev, "DaVinci EMAC: Error in register_netdev\n");
+		dev_err(&pdev->dev, "error in register_netdev\n");
 		rc = -ENODEV;
 		goto netdev_reg_err;
 	}
-- 
1.7.5.rc3

