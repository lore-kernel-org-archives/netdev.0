From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/2] drivers:net: delete premature free_irq
Date: Mon,  2 Sep 2013 11:54:21 +0200
Message-ID: <1378115661-5371-3-git-send-email-Julia.Lawall@lip6.fr>
References: <1378115661-5371-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Wan ZongShun <mcuos.com@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378115661-5371-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Free_irq is not needed if there has been no request_irq.  Free_irq is
removed from both the probe and remove functions.  The correct request_irq
and free_irq are found in the open and close functions.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression e;
@@

*e = platform_get_irq(...);
... when != request_irq(e,...)
*free_irq(e,...)
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
Not tested.

 drivers/net/ethernet/nuvoton/w90p910_ether.c |   11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index dcfe58f..79645f7 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -1014,7 +1014,7 @@ static int w90p910_ether_probe(struct platform_device *pdev)
 	if (ether->rxirq < 0) {
 		dev_err(&pdev->dev, "failed to get ether rx irq\n");
 		error = -ENXIO;
-		goto failed_free_txirq;
+		goto failed_free_io;
 	}
 
 	platform_set_drvdata(pdev, dev);
@@ -1023,7 +1023,7 @@ static int w90p910_ether_probe(struct platform_device *pdev)
 	if (IS_ERR(ether->clk)) {
 		dev_err(&pdev->dev, "failed to get ether clock\n");
 		error = PTR_ERR(ether->clk);
-		goto failed_free_rxirq;
+		goto failed_free_io;
 	}
 
 	ether->rmiiclk = clk_get(&pdev->dev, "RMII");
@@ -1049,10 +1049,6 @@ failed_put_rmiiclk:
 	clk_put(ether->rmiiclk);
 failed_put_clk:
 	clk_put(ether->clk);
-failed_free_rxirq:
-	free_irq(ether->rxirq, pdev);
-failed_free_txirq:
-	free_irq(ether->txirq, pdev);
 failed_free_io:
 	iounmap(ether->reg);
 failed_free_mem:
@@ -1075,9 +1071,6 @@ static int w90p910_ether_remove(struct platform_device *pdev)
 	iounmap(ether->reg);
 	release_mem_region(ether->res->start, resource_size(ether->res));
 
-	free_irq(ether->txirq, dev);
-	free_irq(ether->rxirq, dev);
-
 	del_timer_sync(&ether->check_timer);
 
 	free_netdev(dev);
