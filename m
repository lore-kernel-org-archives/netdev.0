From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH 2/6] fec: Fix the order for enabling/disabling the clocks
Date: Sun, 21 Jul 2013 13:25:00 -0300
Message-ID: <1374423904-2668-3-git-send-email-festevam@gmail.com>
References: <1374423904-2668-1-git-send-email-festevam@gmail.com>
Cc: kernel@pengutronix.de, Frank.Li@freescale.com,
	shawn.guo@linaro.org, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f179.google.com ([209.85.161.179]:36773 "EHLO
	mail-gg0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755793Ab3GUQbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 12:31:36 -0400
Received: by mail-gg0-f179.google.com with SMTP id c2so1850561ggn.38
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 09:31:35 -0700 (PDT)
In-Reply-To: <1374423904-2668-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

On fec_probe the clocks are enabled in the following order:

clk_ahb -> clk_ipg -> clk_enet_out -> clk_ptp

, so in the error and remove paths we should disabled them in the opposite
order.

Also fix the order in the suspend/resume functions.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index de9bf7a..5e82200 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2179,12 +2179,12 @@ failed_init:
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
 failed_regulator:
-	clk_disable_unprepare(fep->clk_ahb);
-	clk_disable_unprepare(fep->clk_ipg);
-	if (fep->clk_enet_out)
-		clk_disable_unprepare(fep->clk_enet_out);
 	if (fep->clk_ptp)
 		clk_disable_unprepare(fep->clk_ptp);
+	if (fep->clk_enet_out)
+		clk_disable_unprepare(fep->clk_enet_out);
+	clk_disable_unprepare(fep->clk_ipg);
+	clk_disable_unprepare(fep->clk_ahb);
 failed_clk:
 failed_ioremap:
 	free_netdev(ndev);
@@ -2216,8 +2216,8 @@ fec_drv_remove(struct platform_device *pdev)
 		ptp_clock_unregister(fep->ptp_clock);
 	if (fep->clk_enet_out)
 		clk_disable_unprepare(fep->clk_enet_out);
-	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
+	clk_disable_unprepare(fep->clk_ahb);
 	free_netdev(ndev);
 
 	return 0;
@@ -2236,8 +2236,8 @@ fec_suspend(struct device *dev)
 	}
 	if (fep->clk_enet_out)
 		clk_disable_unprepare(fep->clk_enet_out);
-	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
+	clk_disable_unprepare(fep->clk_ahb);
 
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
@@ -2258,10 +2258,10 @@ fec_resume(struct device *dev)
 			return ret;
 	}
 
-	if (fep->clk_enet_out)
-		clk_prepare_enable(fep->clk_enet_out);
 	clk_prepare_enable(fep->clk_ahb);
 	clk_prepare_enable(fep->clk_ipg);
+	if (fep->clk_enet_out)
+		clk_prepare_enable(fep->clk_enet_out);
 	if (netif_running(ndev)) {
 		fec_restart(ndev, fep->full_duplex);
 		netif_device_attach(ndev);
-- 
1.8.1.2
