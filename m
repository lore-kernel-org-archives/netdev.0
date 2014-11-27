From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Subject: [PATCH v3] can: Convert to runtime_pm
Date: Thu, 27 Nov 2014 18:38:53 +0530
Message-ID: <6b6db31d46074512a322eae6e4ef64d4@BN1BFFO11FD038.protection.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
	Kedareswara rao Appana <appanad@xilinx.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>,
	<michal.simek@xilinx.com>, <soren.brinkmann@xilinx.com>,
	<grant.likely@linaro.org>, <robh+dt@kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of enabling/disabling clocks at several locations in the driver,
use the runtime_pm framework. This consolidates the actions for
runtime PM in the appropriate callbacks and makes the driver more
readable and mantainable.

Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
---
Changes for v3:
  - Converted the driver to use runtime_pm.
Changes for v2:
  - Removed the struct platform_device* from suspend/resume
    as suggest by Lothar.

 drivers/net/can/xilinx_can.c |  119 +++++++++++++++++++++++++----------------
 1 files changed, 72 insertions(+), 47 deletions(-)

diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.c
index 8a998e3..1be28ed 100644
--- a/drivers/net/can/xilinx_can.c
+++ b/drivers/net/can/xilinx_can.c
@@ -32,6 +32,7 @@
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
 #include <linux/can/led.h>
+#include <linux/pm_runtime.h>
 
 #define DRIVER_NAME	"xilinx_can"
 
@@ -138,7 +139,7 @@ struct xcan_priv {
 	u32 (*read_reg)(const struct xcan_priv *priv, enum xcan_reg reg);
 	void (*write_reg)(const struct xcan_priv *priv, enum xcan_reg reg,
 			u32 val);
-	struct net_device *dev;
+	struct device *dev;
 	void __iomem *reg_base;
 	unsigned long irq_flags;
 	struct clk *bus_clk;
@@ -842,6 +843,13 @@ static int xcan_open(struct net_device *ndev)
 	struct xcan_priv *priv = netdev_priv(ndev);
 	int ret;
 
+	ret = pm_runtime_get_sync(priv->dev);
+	if (ret < 0) {
+		netdev_err(ndev, "%s: runtime CAN resume failed(%d)\n\r",
+				__func__, ret);
+		return ret;
+	}
+
 	ret = request_irq(ndev->irq, xcan_interrupt, priv->irq_flags,
 			ndev->name, ndev);
 	if (ret < 0) {
@@ -849,29 +857,17 @@ static int xcan_open(struct net_device *ndev)
 		goto err;
 	}
 
-	ret = clk_prepare_enable(priv->can_clk);
-	if (ret) {
-		netdev_err(ndev, "unable to enable device clock\n");
-		goto err_irq;
-	}
-
-	ret = clk_prepare_enable(priv->bus_clk);
-	if (ret) {
-		netdev_err(ndev, "unable to enable bus clock\n");
-		goto err_can_clk;
-	}
-
 	/* Set chip into reset mode */
 	ret = set_reset_mode(ndev);
 	if (ret < 0) {
 		netdev_err(ndev, "mode resetting failed!\n");
-		goto err_bus_clk;
+		goto err_irq;
 	}
 
 	/* Common open */
 	ret = open_candev(ndev);
 	if (ret)
-		goto err_bus_clk;
+		goto err_irq;
 
 	ret = xcan_chip_start(ndev);
 	if (ret < 0) {
@@ -887,13 +883,11 @@ static int xcan_open(struct net_device *ndev)
 
 err_candev:
 	close_candev(ndev);
-err_bus_clk:
-	clk_disable_unprepare(priv->bus_clk);
-err_can_clk:
-	clk_disable_unprepare(priv->can_clk);
 err_irq:
 	free_irq(ndev->irq, ndev);
 err:
+	pm_runtime_put(priv->dev);
+
 	return ret;
 }
 
@@ -910,12 +904,11 @@ static int xcan_close(struct net_device *ndev)
 	netif_stop_queue(ndev);
 	napi_disable(&priv->napi);
 	xcan_chip_stop(ndev);
-	clk_disable_unprepare(priv->bus_clk);
-	clk_disable_unprepare(priv->can_clk);
 	free_irq(ndev->irq, ndev);
 	close_candev(ndev);
 
 	can_led_event(ndev, CAN_LED_EVENT_STOP);
+	pm_runtime_put(priv->dev);
 
 	return 0;
 }
@@ -934,27 +927,21 @@ static int xcan_get_berr_counter(const struct net_device *ndev,
 	struct xcan_priv *priv = netdev_priv(ndev);
 	int ret;
 
-	ret = clk_prepare_enable(priv->can_clk);
-	if (ret)
-		goto err;
+	ret = pm_runtime_get_sync(priv->dev);
+	if (ret < 0) {
+		netdev_err(ndev, "%s: runtime resume failed(%d)\n\r",
+				__func__, ret);
+		return ret;
+	}
 
-	ret = clk_prepare_enable(priv->bus_clk);
-	if (ret)
-		goto err_clk;
 
 	bec->txerr = priv->read_reg(priv, XCAN_ECR_OFFSET) & XCAN_ECR_TEC_MASK;
 	bec->rxerr = ((priv->read_reg(priv, XCAN_ECR_OFFSET) &
 			XCAN_ECR_REC_MASK) >> XCAN_ESR_REC_SHIFT);
 
-	clk_disable_unprepare(priv->bus_clk);
-	clk_disable_unprepare(priv->can_clk);
+	pm_runtime_put(priv->dev);
 
 	return 0;
-
-err_clk:
-	clk_disable_unprepare(priv->can_clk);
-err:
-	return ret;
 }
 
 
@@ -967,15 +954,45 @@ static const struct net_device_ops xcan_netdev_ops = {
 
 /**
  * xcan_suspend - Suspend method for the driver
- * @dev:	Address of the platform_device structure
+ * @dev:	Address of the net_device structure
  *
  * Put the driver into low power mode.
- * Return: 0 always
+ * Return: 0 on success and failure value on error
  */
 static int __maybe_unused xcan_suspend(struct device *dev)
 {
-	struct platform_device *pdev = dev_get_drvdata(dev);
-	struct net_device *ndev = platform_get_drvdata(pdev);
+	if (!device_may_wakeup(dev))
+		return pm_runtime_force_suspend(dev);
+
+	return 0;
+}
+
+/**
+ * xcan_resume - Resume from suspend
+ * @dev:	Address of the net_device structure
+ *
+ * Resume operation after suspend.
+ * Return: 0 on success and failure value on error
+ */
+static int __maybe_unused xcan_resume(struct device *dev)
+{
+	if (!device_may_wakeup(dev))
+		return pm_runtime_force_resume(dev);
+
+	return 0;
+
+}
+
+/**
+ * xcan_runtime_suspend - Runtime suspend method for the driver
+ * @dev:	Address of the net_device structure
+ *
+ * Put the driver into low power mode.
+ * Return: 0 always
+ */
+static int __maybe_unused xcan_runtime_suspend(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
 	struct xcan_priv *priv = netdev_priv(ndev);
 
 	if (netif_running(ndev)) {
@@ -993,16 +1010,15 @@ static int __maybe_unused xcan_suspend(struct device *dev)
 }
 
 /**
- * xcan_resume - Resume from suspend
- * @dev:	Address of the platformdevice structure
+ * xcan_runtime_resume - Runtime resume from suspend
+ * @dev:	Address of the net_device structure
  *
  * Resume operation after suspend.
  * Return: 0 on success and failure value on error
  */
-static int __maybe_unused xcan_resume(struct device *dev)
+static int __maybe_unused xcan_runtime_resume(struct device *dev)
 {
-	struct platform_device *pdev = dev_get_drvdata(dev);
-	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct net_device *ndev = dev_get_drvdata(dev);
 	struct xcan_priv *priv = netdev_priv(ndev);
 	int ret;
 
@@ -1030,7 +1046,10 @@ static int __maybe_unused xcan_resume(struct device *dev)
 	return 0;
 }
 
-static SIMPLE_DEV_PM_OPS(xcan_dev_pm_ops, xcan_suspend, xcan_resume);
+static const struct dev_pm_ops xcan_dev_pm_ops = {
+	SET_SYSTEM_SLEEP_PM_OPS(xcan_suspend, xcan_resume)
+	SET_PM_RUNTIME_PM_OPS(xcan_runtime_suspend, xcan_runtime_resume, NULL)
+};
 
 /**
  * xcan_probe - Platform registration call
@@ -1071,7 +1090,7 @@ static int xcan_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	priv = netdev_priv(ndev);
-	priv->dev = ndev;
+	priv->dev = &pdev->dev;
 	priv->can.bittiming_const = &xcan_bittiming_const;
 	priv->can.do_set_mode = xcan_do_set_mode;
 	priv->can.do_get_berr_counter = xcan_get_berr_counter;
@@ -1137,6 +1156,11 @@ static int xcan_probe(struct platform_device *pdev)
 
 	netif_napi_add(ndev, &priv->napi, xcan_rx_poll, rx_max);
 
+	pm_runtime_set_active(&pdev->dev);
+	pm_runtime_irq_safe(&pdev->dev);
+	pm_runtime_enable(&pdev->dev);
+	pm_runtime_get_sync(&pdev->dev);
+
 	ret = register_candev(ndev);
 	if (ret) {
 		dev_err(&pdev->dev, "fail to register failed (err=%d)\n", ret);
@@ -1144,8 +1168,9 @@ static int xcan_probe(struct platform_device *pdev)
 	}
 
 	devm_can_led_init(ndev);
-	clk_disable_unprepare(priv->bus_clk);
-	clk_disable_unprepare(priv->can_clk);
+
+	pm_runtime_put(&pdev->dev);
+
 	netdev_dbg(ndev, "reg_base=0x%p irq=%d clock=%d, tx fifo depth:%d\n",
 			priv->reg_base, ndev->irq, priv->can.clock.freq,
 			priv->tx_max);
-- 
1.7.4

