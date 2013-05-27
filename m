From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 1/5] fec: Place the phy regulator in the private structure
Date: Mon, 27 May 2013 10:48:29 -0300
Message-ID: <1369662513-32133-2-git-send-email-fabio.estevam@freescale.com>
References: <1369662513-32133-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <kernel@pengutronix.de>,
	<netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe006.messaging.microsoft.com ([216.32.181.186]:43487
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932379Ab3E0Ns7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 09:48:59 -0400
In-Reply-To: <1369662513-32133-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a local reg_phy structure, let's put it inside the private
structure, so that we are able to have access to the regulator structure even
when we are outside fec_probe().

This is in preparation for controlling the FEC PHY regulator in the suspend and
resume functions.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      | 1 +
 drivers/net/ethernet/freescale/fec_main.c | 7 +++----
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 9ce5b71..b11cdbc 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -272,6 +272,7 @@ struct fec_enet_private {
 	int hwts_tx_en;
 	struct timer_list time_keep;
 	struct fec_enet_delayed_work delay_work;
+	struct regulator *reg_phy;
 };
 
 void fec_ptp_init(struct net_device *ndev, struct platform_device *pdev);
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 0936b26..57ac7c3 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1840,7 +1840,6 @@ fec_probe(struct platform_device *pdev)
 	struct resource *r;
 	const struct of_device_id *of_id;
 	static int dev_id;
-	struct regulator *reg_phy;
 
 	of_id = of_match_device(fec_dt_ids, &pdev->dev);
 	if (of_id)
@@ -1919,9 +1918,9 @@ fec_probe(struct platform_device *pdev)
 	clk_prepare_enable(fep->clk_enet_out);
 	clk_prepare_enable(fep->clk_ptp);
 
-	reg_phy = devm_regulator_get(&pdev->dev, "phy");
-	if (!IS_ERR(reg_phy)) {
-		ret = regulator_enable(reg_phy);
+	fep->reg_phy = devm_regulator_get(&pdev->dev, "phy");
+	if (!IS_ERR(fep->reg_phy)) {
+		ret = regulator_enable(fep->reg_phy);
 		if (ret) {
 			dev_err(&pdev->dev,
 				"Failed to enable phy regulator: %d\n", ret);
-- 
1.8.1.2
