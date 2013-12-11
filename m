From: Soren Brinkmann <soren.brinkmann@xilinx.com>
Subject: [PATCH v2 2/5] net: macb: Migrate to devm clock interface
Date: Tue, 10 Dec 2013 16:07:20 -0800
Message-ID: <1386720443-24100-3-git-send-email-soren.brinkmann@xilinx.com>
References: <1386720443-24100-1-git-send-email-soren.brinkmann@xilinx.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	=?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	Michal Simek <michal.simek@xilinx.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386720443-24100-1-git-send-email-soren.brinkmann@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Migrate to using the device managed interface for clocks and clean up
the associated error paths.

Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
v2:
 - fix typo in commit message
---
 drivers/net/ethernet/cadence/macb.c | 32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 389ccf1362d5..62aa136889a4 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1790,19 +1790,31 @@ static int __init macb_probe(struct platform_device *pdev)
 	spin_lock_init(&bp->lock);
 	INIT_WORK(&bp->tx_error_task, macb_tx_error_task);
 
-	bp->pclk = clk_get(&pdev->dev, "pclk");
+	bp->pclk = devm_clk_get(&pdev->dev, "pclk");
 	if (IS_ERR(bp->pclk)) {
-		dev_err(&pdev->dev, "failed to get macb_clk\n");
+		err = PTR_ERR(bp->pclk);
+		dev_err(&pdev->dev, "failed to get macb_clk (%u)\n", err);
 		goto err_out_free_dev;
 	}
-	clk_prepare_enable(bp->pclk);
 
-	bp->hclk = clk_get(&pdev->dev, "hclk");
+	bp->hclk = devm_clk_get(&pdev->dev, "hclk");
 	if (IS_ERR(bp->hclk)) {
-		dev_err(&pdev->dev, "failed to get hclk\n");
-		goto err_out_put_pclk;
+		err = PTR_ERR(bp->hclk);
+		dev_err(&pdev->dev, "failed to get hclk (%u)\n", err);
+		goto err_out_free_dev;
+	}
+
+	err = clk_prepare_enable(bp->pclk);
+	if (err) {
+		dev_err(&pdev->dev, "failed to enable pclk (%u)\n", err);
+		goto err_out_free_dev;
+	}
+
+	err = clk_prepare_enable(bp->hclk);
+	if (err) {
+		dev_err(&pdev->dev, "failed to enable hclk (%u)\n", err);
+		goto err_out_disable_pclk;
 	}
-	clk_prepare_enable(bp->hclk);
 
 	bp->regs = ioremap(regs->start, resource_size(regs));
 	if (!bp->regs) {
@@ -1908,10 +1920,8 @@ err_out_iounmap:
 	iounmap(bp->regs);
 err_out_disable_clocks:
 	clk_disable_unprepare(bp->hclk);
-	clk_put(bp->hclk);
+err_out_disable_pclk:
 	clk_disable_unprepare(bp->pclk);
-err_out_put_pclk:
-	clk_put(bp->pclk);
 err_out_free_dev:
 	free_netdev(dev);
 err_out:
@@ -1936,9 +1946,7 @@ static int __exit macb_remove(struct platform_device *pdev)
 		free_irq(dev->irq, dev);
 		iounmap(bp->regs);
 		clk_disable_unprepare(bp->hclk);
-		clk_put(bp->hclk);
 		clk_disable_unprepare(bp->pclk);
-		clk_put(bp->pclk);
 		free_netdev(dev);
 	}
 
-- 
1.8.5.1
