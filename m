From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 4/5] fec: Remove irqs first
Date: Mon, 27 May 2013 10:48:32 -0300
Message-ID: <1369662513-32133-5-git-send-email-fabio.estevam@freescale.com>
References: <1369662513-32133-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <kernel@pengutronix.de>,
	<netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:25800
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932542Ab3E0Ns6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 09:48:58 -0400
In-Reply-To: <1369662513-32133-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During probe the clocks are enabled prior than the acquiring the interrupts.

In the remove function we need to do the opposite: first remove the interrupts
and then disable the clocks.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 58ac0c7..cac667d 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2009,6 +2009,11 @@ fec_drv_remove(struct platform_device *pdev)
 	unregister_netdev(ndev);
 	fec_enet_mii_remove(fep);
 	del_timer_sync(&fep->time_keep);
+	for (i = 0; i < FEC_IRQ_NUM; i++) {
+		int irq = platform_get_irq(pdev, i);
+		if (irq > 0)
+			free_irq(irq, ndev);
+	}
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
 	clk_disable_unprepare(fep->clk_ptp);
@@ -2017,11 +2022,6 @@ fec_drv_remove(struct platform_device *pdev)
 	clk_disable_unprepare(fep->clk_enet_out);
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
-	for (i = 0; i < FEC_IRQ_NUM; i++) {
-		int irq = platform_get_irq(pdev, i);
-		if (irq > 0)
-			free_irq(irq, ndev);
-	}
 	free_netdev(ndev);
 
 	platform_set_drvdata(pdev, NULL);
-- 
1.8.1.2
