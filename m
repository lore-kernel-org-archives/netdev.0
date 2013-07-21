From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH 1/6] fec: Do not enable/disable optional clocks unconditionally
Date: Sun, 21 Jul 2013 13:24:59 -0300
Message-ID: <1374423904-2668-2-git-send-email-festevam@gmail.com>
References: <1374423904-2668-1-git-send-email-festevam@gmail.com>
Cc: kernel@pengutronix.de, Frank.Li@freescale.com,
	shawn.guo@linaro.org, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f174.google.com ([209.85.213.174]:57994 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755881Ab3GUQcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 12:32:14 -0400
Received: by mail-ye0-f174.google.com with SMTP id q9so95241yen.33
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 09:32:13 -0700 (PDT)
In-Reply-To: <1374423904-2668-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

clk_enet_out and clk_ptp are optional clocks, so we should not enable/disable
them unconditionally.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index f0f0e96..de9bf7a 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2105,8 +2105,10 @@ fec_probe(struct platform_device *pdev)
 
 	clk_prepare_enable(fep->clk_ahb);
 	clk_prepare_enable(fep->clk_ipg);
-	clk_prepare_enable(fep->clk_enet_out);
-	clk_prepare_enable(fep->clk_ptp);
+	if (fep->clk_enet_out)
+		clk_prepare_enable(fep->clk_enet_out);
+	if (fep->clk_ptp)
+		clk_prepare_enable(fep->clk_ptp);
 
 	fep->reg_phy = devm_regulator_get(&pdev->dev, "phy");
 	if (!IS_ERR(fep->reg_phy)) {
@@ -2179,8 +2181,10 @@ failed_init:
 failed_regulator:
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
-	clk_disable_unprepare(fep->clk_enet_out);
-	clk_disable_unprepare(fep->clk_ptp);
+	if (fep->clk_enet_out)
+		clk_disable_unprepare(fep->clk_enet_out);
+	if (fep->clk_ptp)
+		clk_disable_unprepare(fep->clk_ptp);
 failed_clk:
 failed_ioremap:
 	free_netdev(ndev);
@@ -2206,10 +2210,12 @@ fec_drv_remove(struct platform_device *pdev)
 	}
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
-	clk_disable_unprepare(fep->clk_ptp);
+	if (fep->clk_ptp)
+		clk_disable_unprepare(fep->clk_ptp);
 	if (fep->ptp_clock)
 		ptp_clock_unregister(fep->ptp_clock);
-	clk_disable_unprepare(fep->clk_enet_out);
+	if (fep->clk_enet_out)
+		clk_disable_unprepare(fep->clk_enet_out);
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
 	free_netdev(ndev);
@@ -2228,7 +2234,8 @@ fec_suspend(struct device *dev)
 		fec_stop(ndev);
 		netif_device_detach(ndev);
 	}
-	clk_disable_unprepare(fep->clk_enet_out);
+	if (fep->clk_enet_out)
+		clk_disable_unprepare(fep->clk_enet_out);
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
 
@@ -2251,7 +2258,8 @@ fec_resume(struct device *dev)
 			return ret;
 	}
 
-	clk_prepare_enable(fep->clk_enet_out);
+	if (fep->clk_enet_out)
+		clk_prepare_enable(fep->clk_enet_out);
 	clk_prepare_enable(fep->clk_ahb);
 	clk_prepare_enable(fep->clk_ipg);
 	if (netif_running(ndev)) {
-- 
1.8.1.2
