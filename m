From: yegorslists@googlemail.com
Subject: [PATCH v2] can: ti_hecc: add missing prepare and unprepare of the clock
Date: Wed, 18 Jan 2017 11:35:57 +0100
Message-ID: <1484735757-21172-1-git-send-email-yegorslists@googlemail.com>
Cc: netdev@vger.kernel.org, mkl@pengutronix.de, wg@grandegger.com,
        Yegor Yefremov <yegorslists@googlemail.com>
To: linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34506 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751444AbdARKgJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 05:36:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yegor Yefremov <yegorslists@googlemail.com>

In order to make the driver work with the common clock framework, this
patch converts the clk_enable()/clk_disable() to
clk_prepare_enable()/clk_disable_unprepare().

Also add error checking for clk_prepare_enable().

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
---
Changes v1 -> v2:
	- add error checking for clk_prepare_enable (Marc Kleine-Budde)

 drivers/net/can/ti_hecc.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index 680d1ff..8771531 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -948,7 +948,12 @@ static int ti_hecc_probe(struct platform_device *pdev)
 	netif_napi_add(ndev, &priv->napi, ti_hecc_rx_poll,
 		HECC_DEF_NAPI_WEIGHT);
 
-	clk_enable(priv->clk);
+	err = clk_prepare_enable(priv->clk);
+	if (err) {
+		dev_err(&pdev->dev, "clk_prepare_enable() failed\n");
+		goto probe_exit_clk;
+	}
+
 	err = register_candev(ndev);
 	if (err) {
 		dev_err(&pdev->dev, "register_candev() failed\n");
@@ -981,7 +986,7 @@ static int ti_hecc_remove(struct platform_device *pdev)
 	struct ti_hecc_priv *priv = netdev_priv(ndev);
 
 	unregister_candev(ndev);
-	clk_disable(priv->clk);
+	clk_disable_unprepare(priv->clk);
 	clk_put(priv->clk);
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	iounmap(priv->base);
@@ -1006,7 +1011,7 @@ static int ti_hecc_suspend(struct platform_device *pdev, pm_message_t state)
 	hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
 	priv->can.state = CAN_STATE_SLEEPING;
 
-	clk_disable(priv->clk);
+	clk_disable_unprepare(priv->clk);
 
 	return 0;
 }
@@ -1016,7 +1021,7 @@ static int ti_hecc_resume(struct platform_device *pdev)
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct ti_hecc_priv *priv = netdev_priv(dev);
 
-	clk_enable(priv->clk);
+	clk_prepare_enable(priv->clk);
 
 	hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
-- 
2.1.4
