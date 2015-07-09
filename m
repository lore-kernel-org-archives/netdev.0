From: Krzysztof Kozlowski <k.kozlowski.k@gmail.com>
Subject: [RFT PATCH] net: axienet: Fix devm_ioremap_resource return value check
Date: Thu,  9 Jul 2015 22:21:20 +0900
Message-ID: <1436448080-24775-1-git-send-email-k.kozlowski.k@gmail.com>
Cc: Krzysztof Kozlowski <k.kozlowski.k@gmail.com>,
	<stable@vger.kernel.org>
To: Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	Michal Simek <michal.simek@xilinx.com>,
	=?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Value returned by devm_ioremap_resource() was checked for non-NULL but
devm_ioremap_resource() returns IOMEM_ERR_PTR, not NULL. In case of
error this could lead to dereference of ERR_PTR.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski.k@gmail.com>
Cc: <stable@vger.kernel.org>
Fixes: 46aa27df8853 ("net: axienet: Use devm_* calls")

---

Patch only compile tested.
---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 4208dd7ef101..d95f9aae95e7 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1530,9 +1530,9 @@ static int axienet_probe(struct platform_device *pdev)
 	/* Map device registers */
 	ethres = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	lp->regs = devm_ioremap_resource(&pdev->dev, ethres);
-	if (!lp->regs) {
+	if (IS_ERR(lp->regs)) {
 		dev_err(&pdev->dev, "could not map Axi Ethernet regs.\n");
-		ret = -ENOMEM;
+		ret = PTR_ERR(lp->regs);
 		goto free_netdev;
 	}
 
@@ -1599,9 +1599,9 @@ static int axienet_probe(struct platform_device *pdev)
 		goto free_netdev;
 	}
 	lp->dma_regs = devm_ioremap_resource(&pdev->dev, &dmares);
-	if (!lp->dma_regs) {
+	if (IS_ERR(lp->dma_regs)) {
 		dev_err(&pdev->dev, "could not map DMA regs\n");
-		ret = -ENOMEM;
+		ret = PTR_ERR(lp->dma_regs);
 		goto free_netdev;
 	}
 	lp->rx_irq = irq_of_parse_and_map(np, 1);
-- 
2.1.4
