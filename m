From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH 6/6] fec: Use devm_request_irq()
Date: Sun, 21 Jul 2013 13:25:04 -0300
Message-ID: <1374423904-2668-7-git-send-email-festevam@gmail.com>
References: <1374423904-2668-1-git-send-email-festevam@gmail.com>
Cc: kernel@pengutronix.de, Frank.Li@freescale.com,
	shawn.guo@linaro.org, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f178.google.com ([209.85.213.178]:51629 "EHLO
	mail-ye0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755808Ab3GUQZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 12:25:44 -0400
Received: by mail-ye0-f178.google.com with SMTP id m15so1873298yen.9
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 09:25:43 -0700 (PDT)
In-Reply-To: <1374423904-2668-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Using devm_request_irq() can make the code smaller and cleaner.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 21 +++------------------
 1 file changed, 3 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 03028c4..0642006 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2149,14 +2149,10 @@ fec_probe(struct platform_device *pdev)
 			ret = irq;
 			goto failed_irq;
 		}
-		ret = request_irq(irq, fec_enet_interrupt, IRQF_DISABLED, pdev->name, ndev);
-		if (ret) {
-			while (--i >= 0) {
-				irq = platform_get_irq(pdev, i);
-				free_irq(irq, ndev);
-			}
+		ret = devm_request_irq(&pdev->dev, irq, fec_enet_interrupt,
+				       IRQF_DISABLED, pdev->name, ndev);
+		if (ret)
 			goto failed_irq;
-		}
 	}
 
 	ret = fec_enet_mii_init(pdev);
@@ -2180,11 +2176,6 @@ failed_register:
 	fec_enet_mii_remove(fep);
 failed_mii_init:
 failed_irq:
-	for (i = 0; i < FEC_IRQ_NUM; i++) {
-		irq = platform_get_irq(pdev, i);
-		if (irq > 0)
-			free_irq(irq, ndev);
-	}
 failed_init:
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
@@ -2210,17 +2201,11 @@ fec_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
-	int i;
 
 	cancel_delayed_work_sync(&(fep->delay_work.delay_work));
 	unregister_netdev(ndev);
 	fec_enet_mii_remove(fep);
 	del_timer_sync(&fep->time_keep);
-	for (i = 0; i < FEC_IRQ_NUM; i++) {
-		int irq = platform_get_irq(pdev, i);
-		if (irq > 0)
-			free_irq(irq, ndev);
-	}
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
 	if (fep->clk_ptp)
-- 
1.8.1.2
