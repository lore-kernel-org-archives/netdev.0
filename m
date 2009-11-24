From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 12/17] sfc: Move all I2C stuff into struct falcon_board
Date: Tue, 24 Nov 2009 02:06:02 +0000
Message-ID: <1259028362.14645.27.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:34803 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932121AbZKXCF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 21:05:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c        |   26 +++++++++++++++-----------
 drivers/net/sfc/falcon.h        |    6 ++++--
 drivers/net/sfc/falcon_boards.c |   18 ++++++++++--------
 drivers/net/sfc/net_driver.h    |    3 ---
 4 files changed, 29 insertions(+), 24 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 490bda0..ff15b9d 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2799,6 +2799,7 @@ static void falcon_probe_spi_devices(struct efx_nic *efx)
 int falcon_probe_nic(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data;
+	struct falcon_board *board;
 	int rc;
 
 	/* Allocate storage for hardware specific data */
@@ -2856,13 +2857,15 @@ int falcon_probe_nic(struct efx_nic *efx)
 		goto fail5;
 
 	/* Initialise I2C adapter */
-	efx->i2c_adap.owner = THIS_MODULE;
-	nic_data->i2c_data = falcon_i2c_bit_operations;
-	nic_data->i2c_data.data = efx;
-	efx->i2c_adap.algo_data = &nic_data->i2c_data;
-	efx->i2c_adap.dev.parent = &efx->pci_dev->dev;
-	strlcpy(efx->i2c_adap.name, "SFC4000 GPIO", sizeof(efx->i2c_adap.name));
-	rc = i2c_bit_add_bus(&efx->i2c_adap);
+	board = falcon_board(efx);
+	board->i2c_adap.owner = THIS_MODULE;
+	board->i2c_data = falcon_i2c_bit_operations;
+	board->i2c_data.data = efx;
+	board->i2c_adap.algo_data = &board->i2c_data;
+	board->i2c_adap.dev.parent = &efx->pci_dev->dev;
+	strlcpy(board->i2c_adap.name, "SFC4000 GPIO",
+		sizeof(board->i2c_adap.name));
+	rc = i2c_bit_add_bus(&board->i2c_adap);
 	if (rc)
 		goto fail5;
 
@@ -2875,8 +2878,8 @@ int falcon_probe_nic(struct efx_nic *efx)
 	return 0;
 
  fail6:
-	BUG_ON(i2c_del_adapter(&efx->i2c_adap));
-	memset(&efx->i2c_adap, 0, sizeof(efx->i2c_adap));
+	BUG_ON(i2c_del_adapter(&board->i2c_adap));
+	memset(&board->i2c_adap, 0, sizeof(board->i2c_adap));
  fail5:
 	falcon_remove_spi_devices(efx);
 	falcon_free_buffer(efx, &efx->irq_status);
@@ -3066,14 +3069,15 @@ int falcon_init_nic(struct efx_nic *efx)
 void falcon_remove_nic(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data = efx->nic_data;
+	struct falcon_board *board = falcon_board(efx);
 	int rc;
 
 	falcon_board(efx)->fini(efx);
 
 	/* Remove I2C adapter and clear it in preparation for a retry */
-	rc = i2c_del_adapter(&efx->i2c_adap);
+	rc = i2c_del_adapter(&board->i2c_adap);
 	BUG_ON(rc);
-	memset(&efx->i2c_adap, 0, sizeof(efx->i2c_adap));
+	memset(&board->i2c_adap, 0, sizeof(board->i2c_adap));
 
 	falcon_remove_spi_devices(efx);
 	falcon_free_buffer(efx, &efx->irq_status);
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 3e9696c..0da5ea7 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -40,6 +40,8 @@ static inline int falcon_rev(struct efx_nic *efx)
  * @set_id_led: Set state of identifying LED or revert to automatic function
  * @monitor: Board-specific health check function
  * @fini: Shut down hardware and free resources
+ * @i2c_adap: I2C adapter for on-board peripherals
+ * @i2c_data: Data for bit-banging algorithm
  * @hwmon_client: I2C client for hardware monitor
  * @ioexp_client: I2C client for power/port control
  */
@@ -52,18 +54,18 @@ struct falcon_board {
 	void (*set_id_led) (struct efx_nic *efx, enum efx_led_mode mode);
 	int (*monitor) (struct efx_nic *nic);
 	void (*fini) (struct efx_nic *nic);
+	struct i2c_adapter i2c_adap;
+	struct i2c_algo_bit_data i2c_data;
 	struct i2c_client *hwmon_client, *ioexp_client;
 };
 
 /**
  * struct falcon_nic_data - Falcon NIC state
  * @pci_dev2: The secondary PCI device if present
- * @i2c_data: Operations and state for I2C bit-bashing algorithm
  * @board: Board state and functions
  */
 struct falcon_nic_data {
 	struct pci_dev *pci_dev2;
-	struct i2c_algo_bit_data i2c_data;
 	struct falcon_board board;
 };
 
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index 20aebe0..cdf7a0d 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -51,7 +51,8 @@
 static int efx_init_lm87(struct efx_nic *efx, struct i2c_board_info *info,
 			 const u8 *reg_values)
 {
-	struct i2c_client *client = i2c_new_device(&efx->i2c_adap, info);
+	struct falcon_board *board = falcon_board(efx);
+	struct i2c_client *client = i2c_new_device(&board->i2c_adap, info);
 	int rc;
 
 	if (!client)
@@ -65,7 +66,7 @@ static int efx_init_lm87(struct efx_nic *efx, struct i2c_board_info *info,
 			goto err;
 	}
 
-	falcon_board(efx)->hwmon_client = client;
+	board->hwmon_client = client;
 	return 0;
 
 err:
@@ -290,10 +291,11 @@ fail_on:
 
 static int sfn4111t_reset(struct efx_nic *efx)
 {
+	struct falcon_board *board = falcon_board(efx);
 	efx_oword_t reg;
 
 	/* GPIO 3 and the GPIO register are shared with I2C, so block that */
-	i2c_lock_adapter(&efx->i2c_adap);
+	i2c_lock_adapter(&board->i2c_adap);
 
 	/* Pull RST_N (GPIO 2) low then let it up again, setting the
 	 * FLASH_CFG_1 strap (GPIO 3) appropriately.  Only change the
@@ -309,7 +311,7 @@ static int sfn4111t_reset(struct efx_nic *efx)
 	efx_writeo(efx, &reg, FR_AB_GPIO_CTL);
 	msleep(1);
 
-	i2c_unlock_adapter(&efx->i2c_adap);
+	i2c_unlock_adapter(&board->i2c_adap);
 
 	ssleep(1);
 	return 0;
@@ -416,10 +418,10 @@ static int sfe4001_init(struct efx_nic *efx)
 
 #if defined(CONFIG_SENSORS_LM90) || defined(CONFIG_SENSORS_LM90_MODULE)
 	board->hwmon_client =
-		i2c_new_device(&efx->i2c_adap, &sfe4001_hwmon_info);
+		i2c_new_device(&board->i2c_adap, &sfe4001_hwmon_info);
 #else
 	board->hwmon_client =
-		i2c_new_dummy(&efx->i2c_adap, sfe4001_hwmon_info.addr);
+		i2c_new_dummy(&board->i2c_adap, sfe4001_hwmon_info.addr);
 #endif
 	if (!board->hwmon_client)
 		return -EIO;
@@ -430,7 +432,7 @@ static int sfe4001_init(struct efx_nic *efx)
 	if (rc)
 		goto fail_hwmon;
 
-	board->ioexp_client = i2c_new_dummy(&efx->i2c_adap, PCA9539);
+	board->ioexp_client = i2c_new_dummy(&board->i2c_adap, PCA9539);
 	if (!board->ioexp_client) {
 		rc = -EIO;
 		goto fail_hwmon;
@@ -522,7 +524,7 @@ static int sfn4111t_init(struct efx_nic *efx)
 	int rc;
 
 	board->hwmon_client =
-		i2c_new_device(&efx->i2c_adap,
+		i2c_new_device(&board->i2c_adap,
 			       (board->minor < 5) ?
 			       &sfn4111t_a0_hwmon_info :
 			       &sfn4111t_r5_hwmon_info);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index fdc9e15..55d45a7 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -639,7 +639,6 @@ union efx_multicast_hash {
  * @interrupt_mode: Interrupt mode
  * @irq_rx_adaptive: Adaptive IRQ moderation enabled for RX event queues
  * @irq_rx_moderation: IRQ moderation time for RX event queues
- * @i2c_adap: I2C adapter
  * @state: Device state flag. Serialised by the rtnl_lock.
  * @reset_pending: Pending reset method (normally RESET_TYPE_NONE)
  * @tx_queue: TX DMA queues
@@ -725,8 +724,6 @@ struct efx_nic {
 	bool irq_rx_adaptive;
 	unsigned int irq_rx_moderation;
 
-	struct i2c_adapter i2c_adap;
-
 	enum nic_state state;
 	enum reset_type reset_pending;
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

