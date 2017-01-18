From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/2] can: ti_hecc: add missing prepare and unprepare of the clock
Date: Wed, 18 Jan 2017 13:08:52 +0100
Message-ID: <20170118120852.6095-3-mkl@pengutronix.de>
References: <20170118120852.6095-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Yegor Yefremov <yegorslists@googlemail.com>,
        linux-stable <stable@vger.kernel.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170118120852.6095-1-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yegor Yefremov <yegorslists@googlemail.com>

In order to make the driver work with the common clock framework, this
patch converts the clk_enable()/clk_disable() to
clk_prepare_enable()/clk_disable_unprepare().

Also add error checking for clk_prepare_enable().

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/ti_hecc.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index 680d1ff07a55..6749b1829469 100644
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
@@ -1015,8 +1020,11 @@ static int ti_hecc_resume(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct ti_hecc_priv *priv = netdev_priv(dev);
+	int err;
 
-	clk_enable(priv->clk);
+	err = clk_prepare_enable(priv->clk);
+	if (err)
+		return err;
 
 	hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
-- 
2.11.0
