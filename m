From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 11/17] sfc: Move struct falcon_board into struct
	falcon_nic_data
Date: Tue, 24 Nov 2009 02:05:45 +0000
Message-ID: <1259028345.14645.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:34793 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932095AbZKXCFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 21:05:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c           |   11 +----------
 drivers/net/sfc/falcon.h        |   30 +++++++++++++++++++++++++++++-
 drivers/net/sfc/falcon_boards.c |    9 +++++++++
 drivers/net/sfc/net_driver.h    |   27 ---------------------------
 4 files changed, 39 insertions(+), 38 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index c9f8004..b913211 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1878,7 +1878,7 @@ static struct pci_device_id efx_pci_table[] __devinitdata = {
 
 /**************************************************************************
  *
- * Dummy PHY/MAC/Board operations
+ * Dummy PHY/MAC operations
  *
  * Can be used for some unimplemented operations
  * Needed so all function pointers are valid and do not have to be tested
@@ -1908,14 +1908,6 @@ static struct efx_phy_operations efx_dummy_phy_operations = {
 	.clear_interrupt = efx_port_dummy_op_void,
 };
 
-static struct falcon_board efx_dummy_board_info = {
-	.init		= efx_port_dummy_op_int,
-	.init_phy	= efx_port_dummy_op_void,
-	.set_id_led	= efx_port_dummy_op_set_id_led,
-	.monitor	= efx_port_dummy_op_int,
-	.fini		= efx_port_dummy_op_void,
-};
-
 /**************************************************************************
  *
  * Data housekeeping
@@ -1944,7 +1936,6 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	efx->state = STATE_INIT;
 	efx->reset_pending = RESET_TYPE_NONE;
 	strlcpy(efx->name, pci_name(pci_dev), sizeof(efx->name));
-	efx->board_info = efx_dummy_board_info;
 
 	efx->net_dev = net_dev;
 	efx->rx_checksum_enabled = true;
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 46dd43b..3e9696c 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -31,18 +31,46 @@ static inline int falcon_rev(struct efx_nic *efx)
 }
 
 /**
+ * struct falcon_board - board information
+ * @type: Board model type
+ * @major: Major rev. ('A', 'B' ...)
+ * @minor: Minor rev. (0, 1, ...)
+ * @init: Allocate resources and initialise peripheral hardware
+ * @init_phy: Do board-specific PHY initialisation
+ * @set_id_led: Set state of identifying LED or revert to automatic function
+ * @monitor: Board-specific health check function
+ * @fini: Shut down hardware and free resources
+ * @hwmon_client: I2C client for hardware monitor
+ * @ioexp_client: I2C client for power/port control
+ */
+struct falcon_board {
+	int type;
+	int major;
+	int minor;
+	int (*init) (struct efx_nic *nic);
+	void (*init_phy) (struct efx_nic *efx);
+	void (*set_id_led) (struct efx_nic *efx, enum efx_led_mode mode);
+	int (*monitor) (struct efx_nic *nic);
+	void (*fini) (struct efx_nic *nic);
+	struct i2c_client *hwmon_client, *ioexp_client;
+};
+
+/**
  * struct falcon_nic_data - Falcon NIC state
  * @pci_dev2: The secondary PCI device if present
  * @i2c_data: Operations and state for I2C bit-bashing algorithm
+ * @board: Board state and functions
  */
 struct falcon_nic_data {
 	struct pci_dev *pci_dev2;
 	struct i2c_algo_bit_data i2c_data;
+	struct falcon_board board;
 };
 
 static inline struct falcon_board *falcon_board(struct efx_nic *efx)
 {
-	return &efx->board_info;
+	struct falcon_nic_data *data = efx->nic_data;
+	return &data->board;
 }
 
 extern struct efx_nic_type falcon_a_nic_type;
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index af7cd2a..20aebe0 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -721,12 +721,21 @@ static struct falcon_board_data board_data[] = {
 	  sfn4112f_init },
 };
 
+static struct falcon_board falcon_dummy_board = {
+	.init		= efx_port_dummy_op_int,
+	.init_phy	= efx_port_dummy_op_void,
+	.set_id_led	= efx_port_dummy_op_set_id_led,
+	.monitor	= efx_port_dummy_op_int,
+	.fini		= efx_port_dummy_op_void,
+};
+
 void falcon_probe_board(struct efx_nic *efx, u16 revision_info)
 {
 	struct falcon_board *board = falcon_board(efx);
 	struct falcon_board_data *data = NULL;
 	int i;
 
+	*board = falcon_dummy_board;
 	board->type = FALCON_BOARD_TYPE(revision_info);
 	board->major = FALCON_BOARD_MAJOR(revision_info);
 	board->minor = FALCON_BOARD_MINOR(revision_info);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 9b84c3a..fdc9e15 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -394,31 +394,6 @@ enum efx_led_mode {
 	EFX_LED_DEFAULT	= 2
 };
 
-/**
- * struct falcon_board - board information
- * @type: Board model type
- * @major: Major rev. ('A', 'B' ...)
- * @minor: Minor rev. (0, 1, ...)
- * @init: Allocate resources and initialise peripheral hardware
- * @init_phy: Do board-specific PHY initialisation
- * @set_id_led: Set state of identifying LED or revert to automatic function
- * @monitor: Board-specific health check function
- * @fini: Shut down hardware and free resources
- * @hwmon_client: I2C client for hardware monitor
- * @ioexp_client: I2C client for power/port control
- */
-struct falcon_board {
-	int type;
-	int major;
-	int minor;
-	int (*init) (struct efx_nic *nic);
-	void (*init_phy) (struct efx_nic *efx);
-	void (*set_id_led) (struct efx_nic *efx, enum efx_led_mode mode);
-	int (*monitor) (struct efx_nic *nic);
-	void (*fini) (struct efx_nic *nic);
-	struct i2c_client *hwmon_client, *ioexp_client;
-};
-
 #define STRING_TABLE_LOOKUP(val, member)	\
 	member ## _names[val]
 
@@ -665,7 +640,6 @@ union efx_multicast_hash {
  * @irq_rx_adaptive: Adaptive IRQ moderation enabled for RX event queues
  * @irq_rx_moderation: IRQ moderation time for RX event queues
  * @i2c_adap: I2C adapter
- * @board_info: Board-level information
  * @state: Device state flag. Serialised by the rtnl_lock.
  * @reset_pending: Pending reset method (normally RESET_TYPE_NONE)
  * @tx_queue: TX DMA queues
@@ -752,7 +726,6 @@ struct efx_nic {
 	unsigned int irq_rx_moderation;
 
 	struct i2c_adapter i2c_adap;
-	struct falcon_board board_info;
 
 	enum nic_state state;
 	enum reset_type reset_pending;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

