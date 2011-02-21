From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 8/9] ax88796: clean up probe and remove function
Date: Mon, 21 Feb 2011 14:03:19 +0100
Message-ID: <1298293400-21570-9-git-send-email-mkl@pengutronix.de>
References: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Cc: Ben Dooks <ben@fluff.org>, Daniel Mack <daniel@caiaq.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35859 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932080Ab1BUNDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 08:03:30 -0500
In-Reply-To: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This way we can remove the struct resource pointers from the private data.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/ax88796.c |   75 ++++++++++++++++++++----------------------------
 1 files changed, 31 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index fd289e5..e62d0ba 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -87,8 +87,6 @@ struct ax_device {
 
 	u32 msg_enable;
 	void __iomem *map2;
-	struct resource *mem;
-	struct resource *mem2;
 	const struct ax_plat_data *plat;
 
 	unsigned char running;
@@ -794,25 +792,24 @@ static int ax_init_dev(struct net_device *dev)
 	return ret;
 }
 
-static int ax_remove(struct platform_device *_dev)
+static int ax_remove(struct platform_device *pdev)
 {
-	struct net_device *dev = platform_get_drvdata(_dev);
+	struct net_device *dev = platform_get_drvdata(pdev);
 	struct ei_device *ei_local = netdev_priv(dev);
-	struct ax_device *ax;
-
-	ax = to_ax_dev(dev);
+	struct ax_device *ax = to_ax_dev(dev);
+	struct resource *mem;
 
 	unregister_netdev(dev);
 	free_irq(dev->irq, dev);
 
 	iounmap(ei_local->mem);
-	release_resource(ax->mem);
-	kfree(ax->mem);
+	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	release_mem_region(mem->start, resource_size(mem));
 
 	if (ax->map2) {
 		iounmap(ax->map2);
-		release_resource(ax->mem2);
-		kfree(ax->mem2);
+		mem = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+		release_mem_region(mem->start, resource_size(mem));
 	}
 
 	free_netdev(dev);
@@ -832,8 +829,8 @@ static int ax_probe(struct platform_device *pdev)
 	struct net_device *dev;
 	struct ei_device *ei_local;
 	struct ax_device *ax;
-	struct resource *res;
-	size_t size;
+	struct resource *irq, *mem, *mem2;
+	resource_size_t mem_size, mem2_size = 0;
 	int ret = 0;
 
 	dev = ax__alloc_ei_netdev(sizeof(struct ax_device));
@@ -853,24 +850,24 @@ static int ax_probe(struct platform_device *pdev)
 	ei_local->rxcr_base = ax->plat->rcr_val;
 
 	/* find the platform resources */
-	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-	if (res == NULL) {
+	irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	if (!irq) {
 		dev_err(&pdev->dev, "no IRQ specified\n");
 		ret = -ENXIO;
 		goto exit_mem;
 	}
 
-	dev->irq = res->start;
-	ax->irqflags = res->flags & IRQF_TRIGGER_MASK;
+	dev->irq = irq->start;
+	ax->irqflags = irq->flags & IRQF_TRIGGER_MASK;
 
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (res == NULL) {
+	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!mem) {
 		dev_err(&pdev->dev, "no MEM specified\n");
 		ret = -ENXIO;
 		goto exit_mem;
 	}
 
-	size = (res->end - res->start) + 1;
+	mem_size = resource_size(mem);
 
 	/*
 	 * setup the register offsets from either the platform data or
@@ -881,50 +878,43 @@ static int ax_probe(struct platform_device *pdev)
 	else {
 		ei_local->reg_offset = ax->reg_offsets;
 		for (ret = 0; ret < 0x18; ret++)
-			ax->reg_offsets[ret] = (size / 0x18) * ret;
+			ax->reg_offsets[ret] = (mem_size / 0x18) * ret;
 	}
 
-	ax->mem = request_mem_region(res->start, size, pdev->name);
-	if (ax->mem == NULL) {
+	if (!request_mem_region(mem->start, mem_size, pdev->name)) {
 		dev_err(&pdev->dev, "cannot reserve registers\n");
 		ret = -ENXIO;
 		goto exit_mem;
 	}
 
-	ei_local->mem = ioremap(res->start, size);
+	ei_local->mem = ioremap(mem->start, mem_size);
 	dev->base_addr = (unsigned long)ei_local->mem;
 
 	if (ei_local->mem == NULL) {
-		dev_err(&pdev->dev, "Cannot ioremap area (%08llx,%08llx)\n",
-			(unsigned long long)res->start,
-			(unsigned long long)res->end);
+		dev_err(&pdev->dev, "Cannot ioremap area %pR\n", mem);
 
 		ret = -ENXIO;
 		goto exit_req;
 	}
 
 	/* look for reset area */
-
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
-	if (res == NULL) {
+	mem2 = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	if (!mem2) {
 		if (!ax->plat->reg_offsets) {
 			for (ret = 0; ret < 0x20; ret++)
-				ax->reg_offsets[ret] = (size / 0x20) * ret;
+				ax->reg_offsets[ret] = (mem_size / 0x20) * ret;
 		}
-
-		ax->map2 = NULL;
 	} else {
-		size = (res->end - res->start) + 1;
+		mem2_size = resource_size(mem2);
 
-		ax->mem2 = request_mem_region(res->start, size, pdev->name);
-		if (ax->mem2 == NULL) {
+		if (!request_mem_region(mem2->start, mem2_size, pdev->name)) {
 			dev_err(&pdev->dev, "cannot reserve registers\n");
 			ret = -ENXIO;
 			goto exit_mem1;
 		}
 
-		ax->map2 = ioremap(res->start, size);
-		if (ax->map2 == NULL) {
+		ax->map2 = ioremap(mem2->start, mem2_size);
+		if (!ax->map2) {
 			dev_err(&pdev->dev, "cannot map reset register\n");
 			ret = -ENXIO;
 			goto exit_mem2;
@@ -934,26 +924,23 @@ static int ax_probe(struct platform_device *pdev)
 	}
 
 	/* got resources, now initialise and register device */
-
 	ret = ax_init_dev(dev);
 	if (!ret)
 		return 0;
 
-	if (ax->map2 == NULL)
+	if (!ax->map2)
 		goto exit_mem1;
 
 	iounmap(ax->map2);
 
  exit_mem2:
-	release_resource(ax->mem2);
-	kfree(ax->mem2);
+	release_mem_region(mem2->start, mem2_size);
 
  exit_mem1:
 	iounmap(ei_local->mem);
 
  exit_req:
-	release_resource(ax->mem);
-	kfree(ax->mem);
+	release_mem_region(mem->start, mem_size);
 
  exit_mem:
 	free_netdev(dev);
-- 
1.7.2.3

