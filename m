From: Alexander Shiyan <shc_work@mail.ru>
Subject: [PATCH RESEND] can: mcp251x: Replace power callbacks with regulator API
Date: Thu,  8 Aug 2013 16:00:27 +0400
Message-ID: <1375963227-6468-1-git-send-email-shc_work@mail.ru>
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-arm-kernel@lists.infradead.org,
	Eric Miao <eric.y.miao@gmail.com>,
	Russell King <linux@arm.linux.org.uk>,
	Haojian Zhuang <haojian.zhuang@gmail.com>,
	Alexander Shiyan <shc_work@mail.ru>
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
---
 arch/arm/mach-pxa/icontrol.c         |  3 --
 arch/arm/mach-pxa/zeus.c             | 46 ++++++++++----------
 drivers/net/can/mcp251x.c            | 81 +++++++++++++++++++-----------------
 include/linux/can/platform/mcp251x.h | 13 +-----
 4 files changed, 69 insertions(+), 74 deletions(-)

diff --git a/arch/arm/mach-pxa/icontrol.c b/arch/arm/mach-pxa/icontrol.c
index fe31bfc..c98511c 100644
--- a/arch/arm/mach-pxa/icontrol.c
+++ b/arch/arm/mach-pxa/icontrol.c
@@ -73,9 +73,6 @@ static struct pxa2xx_spi_chip mcp251x_chip_info4 = {
 
 static struct mcp251x_platform_data mcp251x_info = {
 	.oscillator_frequency = 16E6,
-	.board_specific_setup = NULL,
-	.power_enable         = NULL,
-	.transceiver_enable   = NULL
 };
 
 static struct spi_board_info mcp251x_board_info[] = {
diff --git a/arch/arm/mach-pxa/zeus.c b/arch/arm/mach-pxa/zeus.c
index f5d4364..a49c886 100644
--- a/arch/arm/mach-pxa/zeus.c
+++ b/arch/arm/mach-pxa/zeus.c
@@ -29,6 +29,8 @@
 #include <linux/i2c/pca953x.h>
 #include <linux/apm-emulation.h>
 #include <linux/can/platform/mcp251x.h>
+#include <linux/regulator/fixed.h>
+#include <linux/regulator/machine.h>
 
 #include <asm/mach-types.h>
 #include <asm/suspend.h>
@@ -391,33 +393,34 @@ static struct pxa2xx_spi_master pxa2xx_spi_ssp3_master_info = {
 };
 
 /* CAN bus on SPI */
-static int zeus_mcp2515_setup(struct spi_device *sdev)
-{
-	int err;
-
-	err = gpio_request(ZEUS_CAN_SHDN_GPIO, "CAN shutdown");
-	if (err)
-		return err;
+static struct regulator_consumer_supply can_regulator_consumer =
+	REGULATOR_SUPPLY("vdd", "mcp251x.0");
 
-	err = gpio_direction_output(ZEUS_CAN_SHDN_GPIO, 1);
-	if (err) {
-		gpio_free(ZEUS_CAN_SHDN_GPIO);
-		return err;
-	}
+static struct regulator_init_data can_regulator_init_data = {
+	.constraints	= {
+		.valid_ops_mask	= REGULATOR_CHANGE_STATUS,
+	},
+	.consumer_supplies	= &can_regulator_consumer,
+	.num_consumer_supplies	= 1,
+};
 
-	return 0;
-}
+static struct fixed_voltage_config can_regulator_pdata = {
+	.supply_name	= "CAN_SHDN",
+	.microvolts	= 3300000,
+	.gpio		= ZEUS_CAN_SHDN_GPIO,
+	.init_data	= &can_regulator_init_data,
+};
 
-static int zeus_mcp2515_transceiver_enable(int enable)
-{
-	gpio_set_value(ZEUS_CAN_SHDN_GPIO, !enable);
-	return 0;
-}
+static struct platform_device can_regulator_device = {
+	.name	= "reg-fixed-volage",
+	.id	= -1,
+	.dev	= {
+		.platform_data	= &can_regulator_pdata,
+	},
+};
 
 static struct mcp251x_platform_data zeus_mcp2515_pdata = {
 	.oscillator_frequency	= 16*1000*1000,
-	.board_specific_setup	= zeus_mcp2515_setup,
-	.power_enable		= zeus_mcp2515_transceiver_enable,
 };
 
 static struct spi_board_info zeus_spi_board_info[] = {
@@ -516,6 +519,7 @@ static struct platform_device *zeus_devices[] __initdata = {
 	&zeus_leds_device,
 	&zeus_pcmcia_device,
 	&zeus_max6369_device,
+	&can_regulator_device,
 };
 
 /* AC'97 */
diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 8cda23b..c220cdf 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -37,9 +37,6 @@
  *
  * static struct mcp251x_platform_data mcp251x_info = {
  *         .oscillator_frequency = 8000000,
- *         .board_specific_setup = &mcp251x_setup,
- *         .power_enable = mcp251x_power_enable,
- *         .transceiver_enable = NULL,
  * };
  *
  * static struct spi_board_info spi_board_info[] = {
@@ -76,6 +73,7 @@
 #include <linux/slab.h>
 #include <linux/spi/spi.h>
 #include <linux/uaccess.h>
+#include <linux/regulator/consumer.h>
 
 /* SPI interface instruction set */
 #define INSTRUCTION_WRITE	0x02
@@ -264,6 +262,8 @@ struct mcp251x_priv {
 #define AFTER_SUSPEND_POWER 4
 #define AFTER_SUSPEND_RESTART 8
 	int restart_tx;
+	struct regulator *power;
+	struct regulator *transceiver;
 };
 
 #define MCP251X_IS(_model) \
@@ -671,12 +671,11 @@ static void mcp251x_open_clean(struct net_device *net)
 {
 	struct mcp251x_priv *priv = netdev_priv(net);
 	struct spi_device *spi = priv->spi;
-	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
 
 	free_irq(spi->irq, priv);
 	mcp251x_hw_sleep(spi);
-	if (pdata->transceiver_enable)
-		pdata->transceiver_enable(0);
+	if (!IS_ERR(priv->transceiver))
+		regulator_disable(priv->transceiver);
 	close_candev(net);
 }
 
@@ -684,7 +683,6 @@ static int mcp251x_stop(struct net_device *net)
 {
 	struct mcp251x_priv *priv = netdev_priv(net);
 	struct spi_device *spi = priv->spi;
-	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
 
 	close_candev(net);
 
@@ -704,8 +702,8 @@ static int mcp251x_stop(struct net_device *net)
 
 	mcp251x_hw_sleep(spi);
 
-	if (pdata->transceiver_enable)
-		pdata->transceiver_enable(0);
+	if (!IS_ERR(priv->transceiver))
+		regulator_disable(priv->transceiver);
 
 	priv->can.state = CAN_STATE_STOPPED;
 
@@ -939,8 +937,8 @@ static int mcp251x_open(struct net_device *net)
 	}
 
 	mutex_lock(&priv->mcp_lock);
-	if (pdata->transceiver_enable)
-		pdata->transceiver_enable(1);
+	if (!IS_ERR(priv->transceiver))
+		regulator_enable(priv->transceiver);
 
 	priv->force_quit = 0;
 	priv->tx_skb = NULL;
@@ -956,8 +954,8 @@ static int mcp251x_open(struct net_device *net)
 				   flags, DEVICE_NAME, priv);
 	if (ret) {
 		dev_err(&spi->dev, "failed to acquire irq %d\n", spi->irq);
-		if (pdata->transceiver_enable)
-			pdata->transceiver_enable(0);
+		if (!IS_ERR(priv->transceiver))
+			regulator_disable(priv->transceiver);
 		close_candev(net);
 		goto open_unlock;
 	}
@@ -1026,6 +1024,21 @@ static int mcp251x_can_probe(struct spi_device *spi)
 		CAN_CTRLMODE_LOOPBACK | CAN_CTRLMODE_LISTENONLY;
 	priv->model = spi_get_device_id(spi)->driver_data;
 	priv->net = net;
+
+	priv->power = devm_regulator_get(&spi->dev, "vdd");
+	priv->transceiver = devm_regulator_get(&spi->dev, "transceiver");
+	if ((PTR_ERR(priv->power) == -EPROBE_DEFER) ||
+	    (PTR_ERR(priv->transceiver) == -EPROBE_DEFER)) {
+		ret = -EPROBE_DEFER;
+		goto error_power;
+	}
+
+	if (!IS_ERR(priv->power)) {
+		ret = regulator_enable(priv->power);
+		if (ret)
+			goto error_power;
+	}
+
 	spi_set_drvdata(spi, priv);
 
 	priv->spi = spi;
@@ -1068,13 +1081,6 @@ static int mcp251x_can_probe(struct spi_device *spi)
 		}
 	}
 
-	if (pdata->power_enable)
-		pdata->power_enable(1);
-
-	/* Call out to platform specific setup */
-	if (pdata->board_specific_setup)
-		pdata->board_specific_setup(spi);
-
 	SET_NETDEV_DEV(net, &spi->dev);
 
 	/* Configure the SPI bus */
@@ -1084,14 +1090,11 @@ static int mcp251x_can_probe(struct spi_device *spi)
 
 	/* Here is OK to not lock the MCP, no one knows about it yet */
 	if (!mcp251x_hw_probe(spi)) {
-		dev_info(&spi->dev, "Probe failed\n");
+		ret = -ENODEV;
 		goto error_probe;
 	}
 	mcp251x_hw_sleep(spi);
 
-	if (pdata->transceiver_enable)
-		pdata->transceiver_enable(0);
-
 	ret = register_candev(net);
 	if (ret)
 		goto error_probe;
@@ -1109,13 +1112,14 @@ error_rx_buf:
 	if (!mcp251x_enable_dma)
 		kfree(priv->spi_tx_buf);
 error_tx_buf:
-	free_candev(net);
 	if (mcp251x_enable_dma)
 		dma_free_coherent(&spi->dev, PAGE_SIZE,
 				  priv->spi_tx_buf, priv->spi_tx_dma);
+	if (!IS_ERR(priv->power))
+		regulator_disable(priv->power);
+error_power:
+	free_candev(net);
 error_alloc:
-	if (pdata->power_enable)
-		pdata->power_enable(0);
 	dev_err(&spi->dev, "probe failed\n");
 error_out:
 	return ret;
@@ -1123,12 +1127,10 @@ error_out:
 
 static int mcp251x_can_remove(struct spi_device *spi)
 {
-	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
 	struct mcp251x_priv *priv = spi_get_drvdata(spi);
 	struct net_device *net = priv->net;
 
 	unregister_candev(net);
-	free_candev(net);
 
 	if (mcp251x_enable_dma) {
 		dma_free_coherent(&spi->dev, PAGE_SIZE,
@@ -1138,8 +1140,10 @@ static int mcp251x_can_remove(struct spi_device *spi)
 		kfree(priv->spi_rx_buf);
 	}
 
-	if (pdata->power_enable)
-		pdata->power_enable(0);
+	if (!IS_ERR(priv->power))
+		regulator_disable(priv->power);
+
+	free_candev(net);
 
 	return 0;
 }
@@ -1163,15 +1167,15 @@ static int mcp251x_can_suspend(struct device *dev)
 		netif_device_detach(net);
 
 		mcp251x_hw_sleep(spi);
-		if (pdata->transceiver_enable)
-			pdata->transceiver_enable(0);
+		if (!IS_ERR(priv->transceiver))
+			regulator_disable(priv->transceiver);
 		priv->after_suspend = AFTER_SUSPEND_UP;
 	} else {
 		priv->after_suspend = AFTER_SUSPEND_DOWN;
 	}
 
-	if (pdata->power_enable) {
-		pdata->power_enable(0);
+	if (!IS_ERR(priv->power))
+		regulator_disable(priv->power);
 		priv->after_suspend |= AFTER_SUSPEND_POWER;
 	}
 
@@ -1185,12 +1189,13 @@ static int mcp251x_can_resume(struct device *dev)
 	struct mcp251x_priv *priv = spi_get_drvdata(spi);
 
 	if (priv->after_suspend & AFTER_SUSPEND_POWER) {
-		pdata->power_enable(1);
+		if (!IS_ERR(priv->power))
+			regulator_enable(priv->power);
 		queue_work(priv->wq, &priv->restart_work);
 	} else {
 		if (priv->after_suspend & AFTER_SUSPEND_UP) {
-			if (pdata->transceiver_enable)
-				pdata->transceiver_enable(1);
+			if (!IS_ERR(priv->transceiver))
+				regulator_enable(priv->transceiver);
 			queue_work(priv->wq, &priv->restart_work);
 		} else {
 			priv->after_suspend = 0;
diff --git a/include/linux/can/platform/mcp251x.h b/include/linux/can/platform/mcp251x.h
index 089fe43..8a27256 100644
--- a/include/linux/can/platform/mcp251x.h
+++ b/include/linux/can/platform/mcp251x.h
@@ -9,26 +9,15 @@
 
 #include <linux/spi/spi.h>
 
-/**
+/*
  * struct mcp251x_platform_data - MCP251X SPI CAN controller platform data
  * @oscillator_frequency:       - oscillator frequency in Hz
  * @irq_flags:                  - IRQF configuration flags
- * @board_specific_setup:       - called before probing the chip (power,reset)
- * @transceiver_enable:         - called to power on/off the transceiver
- * @power_enable:               - called to power on/off the mcp *and* the
- *                                transceiver
- *
- * Please note that you should define power_enable or transceiver_enable or
- * none of them. Defining both of them is no use.
- *
  */
 
 struct mcp251x_platform_data {
 	unsigned long oscillator_frequency;
 	unsigned long irq_flags;
-	int (*board_specific_setup)(struct spi_device *spi);
-	int (*transceiver_enable)(int enable);
-	int (*power_enable) (int enable);
 };
 
 #endif /* __CAN_PLATFORM_MCP251X_H__ */
-- 
1.8.1.5

