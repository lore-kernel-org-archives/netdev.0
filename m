From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 6/8] can: mcp251x: Don't use pdata->model for chip selection anymore
Date: Mon, 18 Oct 2010 15:31:12 +0200
Message-ID: <1287408674-15412-7-git-send-email-mkl@pengutronix.de>
References: <1287408674-15412-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Marc Zyngier <maz@misterjones.org>
To: socketcan-core@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33913 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754457Ab0JRNbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 09:31:22 -0400
In-Reply-To: <1287408674-15412-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit e446630c960946b5c1762e4eadb618becef599e7, i.e. v2.6.35-rc1,
the mcp251x chip model can be selected via the modalias member in the
struct spi_board_info. The driver stores the actual model in the
struct mcp251x_platform_data.

>From the driver point of view the platform_data should be read only.
Since all in-tree users of the mcp251x have already been converted to
the modalias method, this patch moves the "model" member from the
struct mcp251x_platform_data to the driver's private data structure.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Christian Pellegrin <chripell@fsfe.org>
Cc: Marc Zyngier <maz@misterjones.org>
---
 drivers/net/can/mcp251x.c            |   24 ++++++++++++------------
 include/linux/can/platform/mcp251x.h |    4 ----
 2 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index f5e2edd..0386bed 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -38,14 +38,14 @@
  * static struct mcp251x_platform_data mcp251x_info = {
  *         .oscillator_frequency = 8000000,
  *         .board_specific_setup = &mcp251x_setup,
- *         .model = CAN_MCP251X_MCP2510,
  *         .power_enable = mcp251x_power_enable,
  *         .transceiver_enable = NULL,
  * };
  *
  * static struct spi_board_info spi_board_info[] = {
  *         {
- *                 .modalias = "mcp251x",
+ *                 .modalias = "mcp2510",
+ *			// or "mcp2515" depending on your controller
  *                 .platform_data = &mcp251x_info,
  *                 .irq = IRQ_EINT13,
  *                 .max_speed_hz = 2*1000*1000,
@@ -224,10 +224,16 @@ static struct can_bittiming_const mcp251x_bittiming_const = {
 	.brp_inc = 1,
 };
 
+enum mcp251x_model {
+	CAN_MCP251X_MCP2510	= 0x2510,
+	CAN_MCP251X_MCP2515	= 0x2515,
+};
+
 struct mcp251x_priv {
 	struct can_priv	   can;
 	struct net_device *net;
 	struct spi_device *spi;
+	enum mcp251x_model model;
 
 	struct mutex mcp_lock; /* SPI device lock */
 
@@ -362,10 +368,9 @@ static void mcp251x_write_bits(struct spi_device *spi, u8 reg,
 static void mcp251x_hw_tx_frame(struct spi_device *spi, u8 *buf,
 				int len, int tx_buf_idx)
 {
-	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
 	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
 
-	if (pdata->model == CAN_MCP251X_MCP2510) {
+	if (priv->model == CAN_MCP251X_MCP2510) {
 		int i;
 
 		for (i = 1; i < TXBDAT_OFF + len; i++)
@@ -408,9 +413,8 @@ static void mcp251x_hw_rx_frame(struct spi_device *spi, u8 *buf,
 				int buf_idx)
 {
 	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
-	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
 
-	if (pdata->model == CAN_MCP251X_MCP2510) {
+	if (priv->model == CAN_MCP251X_MCP2510) {
 		int i, len;
 
 		for (i = 1; i < RXBDAT_OFF; i++)
@@ -951,16 +955,12 @@ static int __devinit mcp251x_can_probe(struct spi_device *spi)
 	struct net_device *net;
 	struct mcp251x_priv *priv;
 	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
-	int model = spi_get_device_id(spi)->driver_data;
 	int ret = -ENODEV;
 
 	if (!pdata)
 		/* Platform data is required for osc freq */
 		goto error_out;
 
-	if (model)
-		pdata->model = model;
-
 	/* Allocate can/net device */
 	net = alloc_candev(sizeof(struct mcp251x_priv), TX_ECHO_SKB_MAX);
 	if (!net) {
@@ -977,6 +977,7 @@ static int __devinit mcp251x_can_probe(struct spi_device *spi)
 	priv->can.clock.freq = pdata->oscillator_frequency / 2;
 	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES |
 		CAN_CTRLMODE_LOOPBACK | CAN_CTRLMODE_LISTENONLY;
+	priv->model = spi_get_device_id(spi)->driver_data;
 	priv->net = net;
 	dev_set_drvdata(&spi->dev, priv);
 
@@ -1150,8 +1151,7 @@ static int mcp251x_can_resume(struct spi_device *spi)
 #define mcp251x_can_resume NULL
 #endif
 
-static struct spi_device_id mcp251x_id_table[] = {
-	{ "mcp251x", 	0 /* Use pdata.model */ },
+static const struct spi_device_id mcp251x_id_table[] = {
 	{ "mcp2510",	CAN_MCP251X_MCP2510 },
 	{ "mcp2515",	CAN_MCP251X_MCP2515 },
 	{ },
diff --git a/include/linux/can/platform/mcp251x.h b/include/linux/can/platform/mcp251x.h
index dba2826..8e20540 100644
--- a/include/linux/can/platform/mcp251x.h
+++ b/include/linux/can/platform/mcp251x.h
@@ -12,7 +12,6 @@
 /**
  * struct mcp251x_platform_data - MCP251X SPI CAN controller platform data
  * @oscillator_frequency:       - oscillator frequency in Hz
- * @model:                      - actual type of chip
  * @board_specific_setup:       - called before probing the chip (power,reset)
  * @transceiver_enable:         - called to power on/off the transceiver
  * @power_enable:               - called to power on/off the mcp *and* the
@@ -25,9 +24,6 @@
 
 struct mcp251x_platform_data {
 	unsigned long oscillator_frequency;
-	int model;
-#define CAN_MCP251X_MCP2510 0x2510
-#define CAN_MCP251X_MCP2515 0x2515
 	int (*board_specific_setup)(struct spi_device *spi);
 	int (*transceiver_enable)(int enable);
 	int (*power_enable) (int enable);
-- 
1.7.0.4

