From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 7/7] can: flexcan: Deferred on Regulator return EPROBE_DEFER
Date: Sun, 22 Mar 2015 20:13:38 +0100
Message-ID: <1427051618-28318-8-git-send-email-mkl@pengutronix.de>
References: <1427051618-28318-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Andreas Werner <kernel@andy89.org>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1427051618-28318-1-git-send-email-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreas Werner <kernel@andy89.org>

Return EPROBE_DEFER if Regulator returns EPROBE_DEFER

If the Flexcan driver is built into kernel and a regulator is used to
enable the CAN transceiver, the Flexcan driver may not use the regulator.

When initializing the Flexcan device with a regulator defined in the device
tree, but not initialized, the regulator subsystem returns EPROBE_DEFER, hence
the Flexcan init fails.

The solution for this is to return EPROBE_DEFER if regulator is not initialized
and wait until the regulator is initialized.

Signed-off-by: Andreas Werner <kernel@andy89.org>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index ee944ae6bb96..ad0a7e8c2c2b 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -1157,12 +1157,19 @@ static int flexcan_probe(struct platform_device *pdev)
 	const struct flexcan_devtype_data *devtype_data;
 	struct net_device *dev;
 	struct flexcan_priv *priv;
+	struct regulator *reg_xceiver;
 	struct resource *mem;
 	struct clk *clk_ipg = NULL, *clk_per = NULL;
 	void __iomem *base;
 	int err, irq;
 	u32 clock_freq = 0;
 
+	reg_xceiver = devm_regulator_get(&pdev->dev, "xceiver");
+	if (PTR_ERR(reg_xceiver) == -EPROBE_DEFER)
+		return -EPROBE_DEFER;
+	else if (IS_ERR(reg_xceiver))
+		reg_xceiver = NULL;
+
 	if (pdev->dev.of_node)
 		of_property_read_u32(pdev->dev.of_node,
 						"clock-frequency", &clock_freq);
@@ -1223,9 +1230,7 @@ static int flexcan_probe(struct platform_device *pdev)
 	priv->pdata = dev_get_platdata(&pdev->dev);
 	priv->devtype_data = devtype_data;
 
-	priv->reg_xceiver = devm_regulator_get(&pdev->dev, "xceiver");
-	if (IS_ERR(priv->reg_xceiver))
-		priv->reg_xceiver = NULL;
+	priv->reg_xceiver = reg_xceiver;
 
 	netif_napi_add(dev, &priv->napi, flexcan_poll, FLEXCAN_NAPI_WEIGHT);
 
-- 
2.1.4
