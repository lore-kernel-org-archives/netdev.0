From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH 4/6] fec: Check the return value from clk_prepare_enable()
Date: Sun, 21 Jul 2013 13:25:02 -0300
Message-ID: <1374423904-2668-5-git-send-email-festevam@gmail.com>
References: <1374423904-2668-1-git-send-email-festevam@gmail.com>
Cc: kernel@pengutronix.de, Frank.Li@freescale.com,
	shawn.guo@linaro.org, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:34305 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755722Ab3GUQZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 12:25:40 -0400
Received: by mail-yh0-f43.google.com with SMTP id b12so2173821yha.16
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 09:25:39 -0700 (PDT)
In-Reply-To: <1374423904-2668-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

clk_prepare_enable() may fail, so let's check its return value and propagate it
in the case of error.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 66 +++++++++++++++++++++++++------
 1 file changed, 54 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 886a372..acc1850 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2103,12 +2103,25 @@ fec_probe(struct platform_device *pdev)
 		fep->bufdesc_ex = 0;
 	}
 
-	clk_prepare_enable(fep->clk_ahb);
-	clk_prepare_enable(fep->clk_ipg);
-	if (fep->clk_enet_out)
-		clk_prepare_enable(fep->clk_enet_out);
-	if (fep->clk_ptp)
-		clk_prepare_enable(fep->clk_ptp);
+	ret = clk_prepare_enable(fep->clk_ahb);
+	if (ret)
+		goto failed_clk;
+
+	ret = clk_prepare_enable(fep->clk_ipg);
+	if (ret)
+		goto failed_clk_ipg;
+
+	if (fep->clk_enet_out) {
+		ret = clk_prepare_enable(fep->clk_enet_out);
+		if (ret)
+			goto failed_clk_enet_out;
+	}
+
+	if (fep->clk_ptp) {
+		ret = clk_prepare_enable(fep->clk_ptp);
+		if (ret)
+			goto failed_clk_ptp;
+	}
 
 	fep->reg_phy = devm_regulator_get(&pdev->dev, "phy");
 	if (!IS_ERR(fep->reg_phy)) {
@@ -2181,9 +2194,12 @@ failed_init:
 failed_regulator:
 	if (fep->clk_ptp)
 		clk_disable_unprepare(fep->clk_ptp);
+failed_clk_ptp:
 	if (fep->clk_enet_out)
 		clk_disable_unprepare(fep->clk_enet_out);
+failed_clk_enet_out:
 	clk_disable_unprepare(fep->clk_ipg);
+failed_clk_ipg:
 	clk_disable_unprepare(fep->clk_ahb);
 failed_clk:
 failed_ioremap:
@@ -2260,18 +2276,44 @@ fec_resume(struct device *dev)
 			return ret;
 	}
 
-	clk_prepare_enable(fep->clk_ahb);
-	clk_prepare_enable(fep->clk_ipg);
-	if (fep->clk_enet_out)
-		clk_prepare_enable(fep->clk_enet_out);
-	if (fep->clk_ptp)
-		clk_prepare_enable(fep->clk_ptp);
+	ret = clk_prepare_enable(fep->clk_ahb);
+	if (ret)
+		goto failed_clk_ahb;
+
+	ret = clk_prepare_enable(fep->clk_ipg);
+	if (ret)
+		goto failed_clk_ipg;
+
+	if (fep->clk_enet_out) {
+		ret = clk_prepare_enable(fep->clk_enet_out);
+		if (ret)
+			goto failed_clk_enet_out;
+	}
+
+	if (fep->clk_ptp) {
+		ret = clk_prepare_enable(fep->clk_ptp);
+		if (ret)
+			goto failed_clk_ptp;
+	}
+
 	if (netif_running(ndev)) {
 		fec_restart(ndev, fep->full_duplex);
 		netif_device_attach(ndev);
 	}
 
 	return 0;
+
+failed_clk_ptp:
+	if (fep->clk_enet_out)
+		clk_disable_unprepare(fep->clk_enet_out);
+failed_clk_enet_out:
+	clk_disable_unprepare(fep->clk_ipg);
+failed_clk_ipg:
+	clk_disable_unprepare(fep->clk_ahb);
+failed_clk_ahb:
+	if (fep->reg_phy)
+		regulator_disable(fep->reg_phy);
+	return ret;
 }
 #endif /* CONFIG_PM_SLEEP */
 
-- 
1.8.1.2
