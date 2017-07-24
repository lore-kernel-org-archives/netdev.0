From: Shubhrajyoti Datta <shubhrajyoti.datta@xilinx.com>
Subject: [PATCH] can: xilinx: Enable clocks even when CONFIG_PM is disabled
Date: Mon, 24 Jul 2017 16:06:58 +0530
Message-ID: <1500892618-21428-1-git-send-email-shubhrajyoti.datta@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <mkl@pengutronix.de>,
        <wg@grandegger.com>, <shubhrajyoti.datta@gmail.com>,
        Shubhrajyoti Datta <shubhrajyoti.datta@xilinx.com>
To: <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently the clocks are enabled only in the runtime calls.
When CONFIG_PM is disabled the driver does not work as the
clocks are disabled.
Fix the same by enabling the clocks in probe.

Signed-off-by: Shubhrajyoti Datta <shubhrajyoti.datta@xilinx.com>
---
 drivers/net/can/xilinx_can.c | 31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.c
index 89aec07..ccad76a 100644
--- a/drivers/net/can/xilinx_can.c
+++ b/drivers/net/can/xilinx_can.c
@@ -1145,14 +1145,21 @@ static int xcan_probe(struct platform_device *pdev)
 	priv->write_reg = xcan_write_reg_le;
 	priv->read_reg = xcan_read_reg_le;
 
-	pm_runtime_enable(&pdev->dev);
-	ret = pm_runtime_get_sync(&pdev->dev);
-	if (ret < 0) {
-		netdev_err(ndev, "%s: pm_runtime_get failed(%d)\n",
-			__func__, ret);
-		goto err_pmdisable;
+	ret = clk_prepare_enable(priv->bus_clk);
+	if (ret) {
+		dev_err(&pdev->dev, "Cannot enable clock.\n");
+		goto err_free;
+	}
+
+	ret = clk_prepare_enable(priv->can_clk);
+	if (ret) {
+		dev_err(&pdev->dev, "Cannot enable clock.\n");
+		goto err_clk;
 	}
 
+	pm_runtime_set_active(&pdev->dev);
+	pm_runtime_enable(&pdev->dev);
+
 	if (priv->read_reg(priv, XCAN_SR_OFFSET) != XCAN_SR_CONFIG_MASK) {
 		priv->write_reg = xcan_write_reg_be;
 		priv->read_reg = xcan_read_reg_be;
@@ -1179,9 +1186,11 @@ static int xcan_probe(struct platform_device *pdev)
 	return 0;
 
 err_disableclks:
-	pm_runtime_put(priv->dev);
-err_pmdisable:
 	pm_runtime_disable(&pdev->dev);
+	pm_runtime_set_suspended(&pdev->dev);
+	clk_disable_unprepare(priv->can_clk);
+err_clk:
+	clk_disable_unprepare(priv->bus_clk);
 err_free:
 	free_candev(ndev);
 err:
@@ -1201,6 +1210,12 @@ static int xcan_remove(struct platform_device *pdev)
 	struct xcan_priv *priv = netdev_priv(ndev);
 
 	unregister_candev(ndev);
+
+	if (!pm_runtime_suspended(&pdev->dev)) {
+		clk_disable_unprepare(priv->bus_clk);
+		clk_disable_unprepare(priv->can_clk);
+	}
+
 	pm_runtime_disable(&pdev->dev);
 	netif_napi_del(&priv->napi);
 	free_candev(ndev);
-- 
2.7.4

