From: Alexander Shiyan <shc_work@mail.ru>
Subject: [PATCH 1/3] can: mcp251x: Convert driver to use common clk framework
Date: Wed, 13 Nov 2013 12:42:24 +0400
Message-ID: <1384332144-15211-1-git-send-email-shc_work@mail.ru>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Russell King <linux@arm.linux.org.uk>,
	Sascha Hauer <kernel@pengutronix.de>,
	Eric Miao <eric.y.miao@gmail.com>,
	Haojian Zhuang <haojian.zhuang@gmail.com>,
	Alexander Shiyan <shc_work@mail.ru>
To: linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp12.mail.ru ([94.100.176.89]:35957 "EHLO smtp12.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758727Ab3KMImr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 03:42:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts mcp251x driver to using common clk framework
for getting input frequency. The change was made for the preparation
of the driver work with the devicetree. As a result private header
for the driver is eliminated.
Additionally, all existing users of the driver was converted to use
this feature.

Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
---
 arch/arm/mach-imx/mach-cpuimx51sd.c  | 18 ++++++++++----
 arch/arm/mach-pxa/icontrol.c         | 23 +++++++++++------
 arch/arm/mach-pxa/zeus.c             | 18 ++++++++++----
 drivers/net/can/mcp251x.c            | 48 ++++++++++++++++++------------------
 include/linux/can/platform/mcp251x.h | 21 ----------------
 5 files changed, 65 insertions(+), 63 deletions(-)
 delete mode 100644 include/linux/can/platform/mcp251x.h

diff --git a/arch/arm/mach-imx/mach-cpuimx51sd.c b/arch/arm/mach-imx/mach-cpuimx51sd.c
index 9b5ddf5..493c0fc 100644
--- a/arch/arm/mach-imx/mach-cpuimx51sd.c
+++ b/arch/arm/mach-imx/mach-cpuimx51sd.c
@@ -24,7 +24,8 @@
 #include <linux/interrupt.h>
 #include <linux/i2c-gpio.h>
 #include <linux/spi/spi.h>
-#include <linux/can/platform/mcp251x.h>
+#include <linux/clk-provider.h>
+#include <linux/clkdev.h>
 
 #include <asm/setup.h>
 #include <asm/mach-types.h>
@@ -244,9 +245,14 @@ static struct platform_device hsi2c_gpio_device = {
 	.dev.platform_data	= &pdata,
 };
 
-static struct mcp251x_platform_data mcp251x_info = {
-	.oscillator_frequency = 24E6,
-};
+static void initialize_clocks(void)
+{
+	struct clk *clk24;
+
+	clk24 = clk_register_fixed_rate(NULL, "clk24", NULL,
+					CLK_IS_ROOT, 24000000);
+	clk_register_clkdev(clk24, NULL, "spi0.0");
+}
 
 static struct spi_board_info cpuimx51sd_spi_device[] = {
 	{
@@ -255,7 +261,6 @@ static struct spi_board_info cpuimx51sd_spi_device[] = {
 		.bus_num         = 0,
 		.mode		= SPI_MODE_0,
 		.chip_select     = 0,
-		.platform_data   = &mcp251x_info,
 		/* irq number is run-time assigned */
 	},
 };
@@ -302,6 +307,9 @@ static void __init eukrea_cpuimx51sd_init(void)
 	gpio_direction_output(CAN_RST, 0);
 	msleep(20);
 	gpio_set_value(CAN_RST, 1);
+
+	initialize_clocks();
+
 	imx51_add_ecspi(0, &cpuimx51sd_ecspi1_pdata);
 	cpuimx51sd_spi_device[0].irq = gpio_to_irq(CAN_IRQGPIO);
 	spi_register_board_info(cpuimx51sd_spi_device,
diff --git a/arch/arm/mach-pxa/icontrol.c b/arch/arm/mach-pxa/icontrol.c
index c98511c..ebf453e 100644
--- a/arch/arm/mach-pxa/icontrol.c
+++ b/arch/arm/mach-pxa/icontrol.c
@@ -23,9 +23,10 @@
 #include <mach/pxa320.h>
 #include <mach/mxm8x10.h>
 
+#include <linux/clk-provider.h>
+#include <linux/clkdev.h>
 #include <linux/spi/spi.h>
 #include <linux/spi/pxa2xx_spi.h>
-#include <linux/can/platform/mcp251x.h>
 
 #include "generic.h"
 
@@ -71,9 +72,17 @@ static struct pxa2xx_spi_chip mcp251x_chip_info4 = {
 	.gpio_cs        = ICONTROL_MCP251x_nCS4
 };
 
-static struct mcp251x_platform_data mcp251x_info = {
-	.oscillator_frequency = 16E6,
-};
+static void initialize_clocks(void)
+{
+	struct clk *clk16;
+
+	clk16 = clk_register_fixed_rate(NULL, "clk16", NULL,
+					CLK_IS_ROOT, 16000000);
+	clk_register_clkdev(clk16, NULL, "spi3.0");
+	clk_register_clkdev(clk16, NULL, "spi3.1");
+	clk_register_clkdev(clk16, NULL, "spi4.0");
+	clk_register_clkdev(clk16, NULL, "spi4.1");
+}
 
 static struct spi_board_info mcp251x_board_info[] = {
 	{
@@ -81,7 +90,6 @@ static struct spi_board_info mcp251x_board_info[] = {
 		.max_speed_hz    = 6500000,
 		.bus_num         = 3,
 		.chip_select     = 0,
-		.platform_data   = &mcp251x_info,
 		.controller_data = &mcp251x_chip_info1,
 		.irq             = PXA_GPIO_TO_IRQ(ICONTROL_MCP251x_nIRQ1)
 	},
@@ -90,7 +98,6 @@ static struct spi_board_info mcp251x_board_info[] = {
 		.max_speed_hz    = 6500000,
 		.bus_num         = 3,
 		.chip_select     = 1,
-		.platform_data   = &mcp251x_info,
 		.controller_data = &mcp251x_chip_info2,
 		.irq             = PXA_GPIO_TO_IRQ(ICONTROL_MCP251x_nIRQ2)
 	},
@@ -99,7 +106,6 @@ static struct spi_board_info mcp251x_board_info[] = {
 		.max_speed_hz    = 6500000,
 		.bus_num         = 4,
 		.chip_select     = 0,
-		.platform_data   = &mcp251x_info,
 		.controller_data = &mcp251x_chip_info3,
 		.irq             = PXA_GPIO_TO_IRQ(ICONTROL_MCP251x_nIRQ3)
 	},
@@ -108,7 +114,6 @@ static struct spi_board_info mcp251x_board_info[] = {
 		.max_speed_hz    = 6500000,
 		.bus_num         = 4,
 		.chip_select     = 1,
-		.platform_data   = &mcp251x_info,
 		.controller_data = &mcp251x_chip_info4,
 		.irq             = PXA_GPIO_TO_IRQ(ICONTROL_MCP251x_nIRQ4)
 	}
@@ -173,6 +178,8 @@ static mfp_cfg_t mfp_can_cfg[] __initdata = {
 
 static void __init icontrol_can_init(void)
 {
+	initialize_clocks();
+
 	pxa3xx_mfp_config(ARRAY_AND_SIZE(mfp_can_cfg));
 	platform_add_devices(ARRAY_AND_SIZE(icontrol_spi_devices));
 	spi_register_board_info(ARRAY_AND_SIZE(mcp251x_board_info));
diff --git a/arch/arm/mach-pxa/zeus.c b/arch/arm/mach-pxa/zeus.c
index b19d1c3..7009e6e 100644
--- a/arch/arm/mach-pxa/zeus.c
+++ b/arch/arm/mach-pxa/zeus.c
@@ -28,7 +28,8 @@
 #include <linux/i2c/pxa-i2c.h>
 #include <linux/platform_data/pca953x.h>
 #include <linux/apm-emulation.h>
-#include <linux/can/platform/mcp251x.h>
+#include <linux/clk-provider.h>
+#include <linux/clkdev.h>
 #include <linux/regulator/fixed.h>
 #include <linux/regulator/machine.h>
 
@@ -419,14 +420,18 @@ static struct platform_device can_regulator_device = {
 	},
 };
 
-static struct mcp251x_platform_data zeus_mcp2515_pdata = {
-	.oscillator_frequency	= 16*1000*1000,
-};
+static void initialize_clocks(void)
+{
+	struct clk *clk16;
+
+	clk16 = clk_register_fixed_rate(NULL, "clk16", NULL,
+					CLK_IS_ROOT, 16000000);
+	clk_register_clkdev(clk16, NULL, "spi3.0");
+}
 
 static struct spi_board_info zeus_spi_board_info[] = {
 	[0] = {
 		.modalias	= "mcp2515",
-		.platform_data	= &zeus_mcp2515_pdata,
 		.irq		= PXA_GPIO_TO_IRQ(ZEUS_CAN_GPIO),
 		.max_speed_hz	= 1*1000*1000,
 		.bus_num	= 3,
@@ -859,6 +864,9 @@ static void __init zeus_init(void)
 	pxa_set_ac97_info(&zeus_ac97_info);
 	pxa_set_i2c_info(NULL);
 	i2c_register_board_info(0, ARRAY_AND_SIZE(zeus_i2c_devices));
+
+	initialize_clocks();
+
 	pxa2xx_set_spi_info(3, &pxa2xx_spi_ssp3_master_info);
 	spi_register_board_info(zeus_spi_board_info, ARRAY_SIZE(zeus_spi_board_info));
 }
diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 08ac401..3a8d80b 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -35,30 +35,21 @@
  *
  * Your platform definition file should specify something like:
  *
- * static struct mcp251x_platform_data mcp251x_info = {
- *         .oscillator_frequency = 8000000,
- * };
- *
  * static struct spi_board_info spi_board_info[] = {
  *         {
  *                 .modalias = "mcp2510",
  *			// or "mcp2515" depending on your controller
- *                 .platform_data = &mcp251x_info,
  *                 .irq = IRQ_EINT13,
  *                 .max_speed_hz = 2*1000*1000,
  *                 .chip_select = 2,
  *         },
  * };
- *
- * Please see mcp251x.h for a description of the fields in
- * struct mcp251x_platform_data.
- *
  */
 
 #include <linux/can/core.h>
 #include <linux/can/dev.h>
 #include <linux/can/led.h>
-#include <linux/can/platform/mcp251x.h>
+#include <linux/clk.h>
 #include <linux/completion.h>
 #include <linux/delay.h>
 #include <linux/device.h>
@@ -264,6 +255,7 @@ struct mcp251x_priv {
 	int restart_tx;
 	struct regulator *power;
 	struct regulator *transceiver;
+	struct clk *clk;
 };
 
 #define MCP251X_IS(_model) \
@@ -999,27 +991,30 @@ static int mcp251x_can_probe(struct spi_device *spi)
 {
 	struct net_device *net;
 	struct mcp251x_priv *priv;
-	struct mcp251x_platform_data *pdata = dev_get_platdata(&spi->dev);
-	int ret = -ENODEV;
-
-	if (!pdata)
-		/* Platform data is required for osc freq */
-		goto error_out;
+	int ret;
 
 	/* Allocate can/net device */
 	net = alloc_candev(sizeof(struct mcp251x_priv), TX_ECHO_SKB_MAX);
-	if (!net) {
-		ret = -ENOMEM;
-		goto error_alloc;
-	}
+	if (!net)
+		return -ENOMEM;
 
 	net->netdev_ops = &mcp251x_netdev_ops;
 	net->flags |= IFF_ECHO;
 
 	priv = netdev_priv(net);
+
+	priv->clk = devm_clk_get(&spi->dev, NULL);
+	if (IS_ERR(priv->clk))
+		ret = PTR_ERR(priv->clk);
+	else
+		ret = clk_prepare_enable(priv->clk);
+
+	if (ret)
+		goto error_clk;
+
 	priv->can.bittiming_const = &mcp251x_bittiming_const;
 	priv->can.do_set_mode = mcp251x_do_set_mode;
-	priv->can.clock.freq = pdata->oscillator_frequency / 2;
+	priv->can.clock.freq = clk_get_rate(priv->clk) / 2;
 	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES |
 		CAN_CTRLMODE_LOOPBACK | CAN_CTRLMODE_LISTENONLY;
 	priv->model = spi_get_device_id(spi)->driver_data;
@@ -1117,12 +1112,15 @@ error_tx_buf:
 	if (mcp251x_enable_dma)
 		dma_free_coherent(&spi->dev, PAGE_SIZE,
 				  priv->spi_tx_buf, priv->spi_tx_dma);
+
 	mcp251x_power_enable(priv->power, 0);
+
 error_power:
+	clk_disable_unprepare(priv->clk);
+
+error_clk:
 	free_candev(net);
-error_alloc:
-	dev_err(&spi->dev, "probe failed\n");
-error_out:
+
 	return ret;
 }
 
@@ -1143,6 +1141,8 @@ static int mcp251x_can_remove(struct spi_device *spi)
 
 	mcp251x_power_enable(priv->power, 0);
 
+	clk_disable_unprepare(priv->clk);
+
 	free_candev(net);
 
 	return 0;
diff --git a/include/linux/can/platform/mcp251x.h b/include/linux/can/platform/mcp251x.h
deleted file mode 100644
index dc029db..0000000
--- a/include/linux/can/platform/mcp251x.h
+++ /dev/null
@@ -1,21 +0,0 @@
-#ifndef __CAN_PLATFORM_MCP251X_H__
-#define __CAN_PLATFORM_MCP251X_H__
-
-/*
- *
- * CAN bus driver for Microchip 251x CAN Controller with SPI Interface
- *
- */
-
-#include <linux/spi/spi.h>
-
-/*
- * struct mcp251x_platform_data - MCP251X SPI CAN controller platform data
- * @oscillator_frequency:       - oscillator frequency in Hz
- */
-
-struct mcp251x_platform_data {
-	unsigned long oscillator_frequency;
-};
-
-#endif /* __CAN_PLATFORM_MCP251X_H__ */
-- 
1.8.1.5
