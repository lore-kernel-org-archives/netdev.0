From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: [PATCH 2/2] net/macb: remove useless calls of devm_free_irq()
Date: Mon, 15 Dec 2014 15:13:32 +0100
Message-ID: <edf8ff9a46dfaa51c9a45eb340e173fdba758ddd.1418651689.git.cyrille.pitchen@atmel.com>
References: <cover.1418651689.git.cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<soren.brinkmann@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:13406 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752554AbaLOOOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 09:14:24 -0500
In-Reply-To: <cover.1418651689.git.cyrille.pitchen@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inside macb_probe(), when devm_request_irq() fails on queue q, there is no need
to call devm_free_irq() on queues 0..q-1 because the managed device resources
are released later when calling free_netdev().

Also removing devm_free_irq() call from macb_remove() for the same reason.

Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 23 ++++++++---------------
 1 file changed, 8 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 81f317f..414f796 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2160,7 +2160,7 @@ static int __init macb_probe(struct platform_device *pdev)
 	int err = -ENXIO;
 	const char *mac;
 	void __iomem *mem;
-	unsigned int hw_q, queue_mask, q, num_queues, q_irq = 0;
+	unsigned int hw_q, queue_mask, q, num_queues;
 	struct clk *pclk, *hclk, *tx_clk;
 
 	regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -2235,11 +2235,11 @@ static int __init macb_probe(struct platform_device *pdev)
 	 * register mapping but we don't want to test the queue index then
 	 * compute the corresponding register offset at run time.
 	 */
-	for (hw_q = 0; hw_q < MACB_MAX_QUEUES; ++hw_q) {
+	for (hw_q = 0, q = 0; hw_q < MACB_MAX_QUEUES; ++hw_q) {
 		if (!(queue_mask & (1 << hw_q)))
 			continue;
 
-		queue = &bp->queues[q_irq];
+		queue = &bp->queues[q];
 		queue->bp = bp;
 		if (hw_q) {
 			queue->ISR  = GEM_ISR(hw_q - 1);
@@ -2261,18 +2261,18 @@ static int __init macb_probe(struct platform_device *pdev)
 		 * must remove the optional gaps that could exist in the
 		 * hardware queue mask.
 		 */
-		queue->irq = platform_get_irq(pdev, q_irq);
+		queue->irq = platform_get_irq(pdev, q);
 		err = devm_request_irq(&pdev->dev, queue->irq, macb_interrupt,
 				       0, dev->name, queue);
 		if (err) {
 			dev_err(&pdev->dev,
 				"Unable to request IRQ %d (error %d)\n",
 				queue->irq, err);
-			goto err_out_free_irq;
+			goto err_out_free_netdev;
 		}
 
 		INIT_WORK(&queue->tx_error_task, macb_tx_error_task);
-		q_irq++;
+		q++;
 	}
 	dev->irq = bp->queues[0].irq;
 
@@ -2350,7 +2350,7 @@ static int __init macb_probe(struct platform_device *pdev)
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
-		goto err_out_free_irq;
+		goto err_out_free_netdev;
 	}
 
 	err = macb_mii_init(bp);
@@ -2373,9 +2373,7 @@ static int __init macb_probe(struct platform_device *pdev)
 
 err_out_unregister_netdev:
 	unregister_netdev(dev);
-err_out_free_irq:
-	for (q = 0, queue = bp->queues; q < q_irq; ++q, ++queue)
-		devm_free_irq(&pdev->dev, queue->irq, queue);
+err_out_free_netdev:
 	free_netdev(dev);
 err_out_disable_clocks:
 	if (!IS_ERR(tx_clk))
@@ -2392,8 +2390,6 @@ static int __exit macb_remove(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct macb *bp;
-	struct macb_queue *queue;
-	unsigned int q;
 
 	dev = platform_get_drvdata(pdev);
 
@@ -2405,9 +2401,6 @@ static int __exit macb_remove(struct platform_device *pdev)
 		kfree(bp->mii_bus->irq);
 		mdiobus_free(bp->mii_bus);
 		unregister_netdev(dev);
-		queue = bp->queues;
-		for (q = 0; q < bp->num_queues; ++q, ++queue)
-			devm_free_irq(&pdev->dev, queue->irq, queue);
 		if (!IS_ERR(bp->tx_clk))
 			clk_disable_unprepare(bp->tx_clk);
 		clk_disable_unprepare(bp->hclk);
-- 
1.8.2.2
