From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 09/17] sfc: Make board information explicitly
	Falcon-specific
Date: Tue, 24 Nov 2009 02:05:12 +0000
Message-ID: <1259028313.14645.21.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:34752 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757556AbZKXCFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 21:05:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename struct efx_board to struct falcon_board.

Introduce and use inline function to look up board info from struct
efx_nic, in preparation for moving it.

Move board init and fini calls into NIC probe and remove functions.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c           |   25 ++-------
 drivers/net/sfc/ethtool.c       |    6 +-
 drivers/net/sfc/falcon.c        |   11 ++++
 drivers/net/sfc/falcon.h        |    5 ++
 drivers/net/sfc/falcon_boards.c |  106 +++++++++++++++++++++------------------
 drivers/net/sfc/net_driver.h    |    6 +-
 drivers/net/sfc/qt202x_phy.c    |    2 +-
 drivers/net/sfc/tenxpress.c     |    2 +-
 8 files changed, 88 insertions(+), 75 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index d7705a7..c9f8004 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1265,7 +1265,7 @@ static void efx_monitor(struct work_struct *data)
 		goto out_requeue;
 	if (!efx->port_enabled)
 		goto out_unlock;
-	rc = efx->board_info.monitor(efx);
+	rc = falcon_board(efx)->monitor(efx);
 	if (rc) {
 		EFX_ERR(efx, "Board sensor %s; shutting down PHY\n",
 			(rc == -ERANGE) ? "reported fault" : "failed");
@@ -1908,7 +1908,7 @@ static struct efx_phy_operations efx_dummy_phy_operations = {
 	.clear_interrupt = efx_port_dummy_op_void,
 };
 
-static struct efx_board efx_dummy_board_info = {
+static struct falcon_board efx_dummy_board_info = {
 	.init		= efx_port_dummy_op_int,
 	.init_phy	= efx_port_dummy_op_void,
 	.set_id_led	= efx_port_dummy_op_set_id_led,
@@ -2026,10 +2026,6 @@ static void efx_pci_remove_main(struct efx_nic *efx)
 	falcon_fini_interrupt(efx);
 	efx_fini_channels(efx);
 	efx_fini_port(efx);
-
-	/* Shutdown the board, then the NIC and board state */
-	efx->board_info.fini(efx);
-
 	efx_fini_napi(efx);
 	efx_remove_all(efx);
 }
@@ -2089,39 +2085,30 @@ static int efx_pci_probe_main(struct efx_nic *efx)
 	if (rc)
 		goto fail2;
 
-	/* Initialise the board */
-	rc = efx->board_info.init(efx);
-	if (rc) {
-		EFX_ERR(efx, "failed to initialise board\n");
-		goto fail3;
-	}
-
 	rc = falcon_init_nic(efx);
 	if (rc) {
 		EFX_ERR(efx, "failed to initialise NIC\n");
-		goto fail4;
+		goto fail3;
 	}
 
 	rc = efx_init_port(efx);
 	if (rc) {
 		EFX_ERR(efx, "failed to initialise port\n");
-		goto fail5;
+		goto fail4;
 	}
 
 	efx_init_channels(efx);
 
 	rc = falcon_init_interrupt(efx);
 	if (rc)
-		goto fail6;
+		goto fail5;
 
 	return 0;
 
- fail6:
+ fail5:
 	efx_fini_channels(efx);
 	efx_fini_port(efx);
- fail5:
  fail4:
-	efx->board_info.fini(efx);
  fail3:
 	efx_fini_napi(efx);
  fail2:
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 18e0271..bb41532 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -188,14 +188,14 @@ static int efx_ethtool_phys_id(struct net_device *net_dev, u32 count)
 	struct efx_nic *efx = netdev_priv(net_dev);
 
 	do {
-		efx->board_info.set_id_led(efx, EFX_LED_ON);
+		falcon_board(efx)->set_id_led(efx, EFX_LED_ON);
 		schedule_timeout_interruptible(HZ / 2);
 
-		efx->board_info.set_id_led(efx, EFX_LED_OFF);
+		falcon_board(efx)->set_id_led(efx, EFX_LED_OFF);
 		schedule_timeout_interruptible(HZ / 2);
 	} while (!signal_pending(current) && --count != 0);
 
-	efx->board_info.set_id_led(efx, EFX_LED_DEFAULT);
+	falcon_board(efx)->set_id_led(efx, EFX_LED_DEFAULT);
 	return 0;
 }
 
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 865638b..29e79f7 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2877,8 +2877,17 @@ int falcon_probe_nic(struct efx_nic *efx)
 	if (rc)
 		goto fail5;
 
+	rc = falcon_board(efx)->init(efx);
+	if (rc) {
+		EFX_ERR(efx, "failed to initialise board\n");
+		goto fail6;
+	}
+
 	return 0;
 
+ fail6:
+	BUG_ON(i2c_del_adapter(&efx->i2c_adap));
+	memset(&efx->i2c_adap, 0, sizeof(efx->i2c_adap));
  fail5:
 	falcon_remove_spi_devices(efx);
 	falcon_free_buffer(efx, &efx->irq_status);
@@ -3070,6 +3079,8 @@ void falcon_remove_nic(struct efx_nic *efx)
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	int rc;
 
+	falcon_board(efx)->fini(efx);
+
 	/* Remove I2C adapter and clear it in preparation for a retry */
 	rc = i2c_del_adapter(&efx->i2c_adap);
 	BUG_ON(rc);
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 4dd9657..54dad2d 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -29,6 +29,11 @@ static inline int falcon_rev(struct efx_nic *efx)
 	return efx->pci_dev->revision;
 }
 
+static inline struct falcon_board *falcon_board(struct efx_nic *efx)
+{
+	return &efx->board_info;
+}
+
 extern struct efx_nic_type falcon_a_nic_type;
 extern struct efx_nic_type falcon_b_nic_type;
 
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index 429d3cd..af7cd2a 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -65,7 +65,7 @@ static int efx_init_lm87(struct efx_nic *efx, struct i2c_board_info *info,
 			goto err;
 	}
 
-	efx->board_info.hwmon_client = client;
+	falcon_board(efx)->hwmon_client = client;
 	return 0;
 
 err:
@@ -75,12 +75,12 @@ err:
 
 static void efx_fini_lm87(struct efx_nic *efx)
 {
-	i2c_unregister_device(efx->board_info.hwmon_client);
+	i2c_unregister_device(falcon_board(efx)->hwmon_client);
 }
 
 static int efx_check_lm87(struct efx_nic *efx, unsigned mask)
 {
-	struct i2c_client *client = efx->board_info.hwmon_client;
+	struct i2c_client *client = falcon_board(efx)->hwmon_client;
 	s32 alarms1, alarms2;
 
 	/* If link is up then do not monitor temperature */
@@ -189,8 +189,8 @@ static inline int efx_check_lm87(struct efx_nic *efx, unsigned mask)
 
 static void sfe4001_poweroff(struct efx_nic *efx)
 {
-	struct i2c_client *ioexp_client = efx->board_info.ioexp_client;
-	struct i2c_client *hwmon_client = efx->board_info.hwmon_client;
+	struct i2c_client *ioexp_client = falcon_board(efx)->ioexp_client;
+	struct i2c_client *hwmon_client = falcon_board(efx)->hwmon_client;
 
 	/* Turn off all power rails and disable outputs */
 	i2c_smbus_write_byte_data(ioexp_client, P0_OUT, 0xff);
@@ -203,8 +203,8 @@ static void sfe4001_poweroff(struct efx_nic *efx)
 
 static int sfe4001_poweron(struct efx_nic *efx)
 {
-	struct i2c_client *hwmon_client = efx->board_info.hwmon_client;
-	struct i2c_client *ioexp_client = efx->board_info.ioexp_client;
+	struct i2c_client *ioexp_client = falcon_board(efx)->ioexp_client;
+	struct i2c_client *hwmon_client = falcon_board(efx)->hwmon_client;
 	unsigned int i, j;
 	int rc;
 	u8 out;
@@ -346,7 +346,7 @@ static ssize_t set_phy_flash_cfg(struct device *dev,
 		efx->phy_mode = new_mode;
 		if (new_mode & PHY_MODE_SPECIAL)
 			efx_stats_disable(efx);
-		if (efx->board_info.type == FALCON_BOARD_SFE4001)
+		if (falcon_board(efx)->type == FALCON_BOARD_SFE4001)
 			err = sfe4001_poweron(efx);
 		else
 			err = sfn4111t_reset(efx);
@@ -363,12 +363,14 @@ static DEVICE_ATTR(phy_flash_cfg, 0644, show_phy_flash_cfg, set_phy_flash_cfg);
 
 static void sfe4001_fini(struct efx_nic *efx)
 {
+	struct falcon_board *board = falcon_board(efx);
+
 	EFX_INFO(efx, "%s\n", __func__);
 
 	device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
 	sfe4001_poweroff(efx);
-	i2c_unregister_device(efx->board_info.ioexp_client);
-	i2c_unregister_device(efx->board_info.hwmon_client);
+	i2c_unregister_device(board->ioexp_client);
+	i2c_unregister_device(board->hwmon_client);
 }
 
 static int sfe4001_check_hw(struct efx_nic *efx)
@@ -387,7 +389,7 @@ static int sfe4001_check_hw(struct efx_nic *efx)
 	 * the power undesirably.
 	 * We know we can read from the IO expander because we did
 	 * it during power-on. Assume failure now is bad news. */
-	status = i2c_smbus_read_byte_data(efx->board_info.ioexp_client, P1_IN);
+	status = i2c_smbus_read_byte_data(falcon_board(efx)->ioexp_client, P1_IN);
 	if (status >= 0 &&
 	    (status & ((1 << P1_AFE_PWD_LBN) | (1 << P1_DSP_PWD25_LBN))) != 0)
 		return 0;
@@ -409,36 +411,37 @@ static struct i2c_board_info sfe4001_hwmon_info = {
  */
 static int sfe4001_init(struct efx_nic *efx)
 {
+	struct falcon_board *board = falcon_board(efx);
 	int rc;
 
 #if defined(CONFIG_SENSORS_LM90) || defined(CONFIG_SENSORS_LM90_MODULE)
-	efx->board_info.hwmon_client =
+	board->hwmon_client =
 		i2c_new_device(&efx->i2c_adap, &sfe4001_hwmon_info);
 #else
-	efx->board_info.hwmon_client =
+	board->hwmon_client =
 		i2c_new_dummy(&efx->i2c_adap, sfe4001_hwmon_info.addr);
 #endif
-	if (!efx->board_info.hwmon_client)
+	if (!board->hwmon_client)
 		return -EIO;
 
 	/* Raise board/PHY high limit from 85 to 90 degrees Celsius */
-	rc = i2c_smbus_write_byte_data(efx->board_info.hwmon_client,
+	rc = i2c_smbus_write_byte_data(board->hwmon_client,
 				       MAX664X_REG_WLHO, 90);
 	if (rc)
 		goto fail_hwmon;
 
-	efx->board_info.ioexp_client = i2c_new_dummy(&efx->i2c_adap, PCA9539);
-	if (!efx->board_info.ioexp_client) {
+	board->ioexp_client = i2c_new_dummy(&efx->i2c_adap, PCA9539);
+	if (!board->ioexp_client) {
 		rc = -EIO;
 		goto fail_hwmon;
 	}
 
 	/* 10Xpress has fixed-function LED pins, so there is no board-specific
 	 * blink code. */
-	efx->board_info.set_id_led = tenxpress_set_id_led;
+	board->set_id_led = tenxpress_set_id_led;
 
-	efx->board_info.monitor = sfe4001_check_hw;
-	efx->board_info.fini = sfe4001_fini;
+	board->monitor = sfe4001_check_hw;
+	board->fini = sfe4001_fini;
 
 	if (efx->phy_mode & PHY_MODE_SPECIAL) {
 		/* PHY won't generate a 156.25 MHz clock and MAC stats fetch
@@ -459,9 +462,9 @@ static int sfe4001_init(struct efx_nic *efx)
 fail_on:
 	sfe4001_poweroff(efx);
 fail_ioexp:
-	i2c_unregister_device(efx->board_info.ioexp_client);
+	i2c_unregister_device(board->ioexp_client);
 fail_hwmon:
-	i2c_unregister_device(efx->board_info.hwmon_client);
+	i2c_unregister_device(board->hwmon_client);
 	return rc;
 }
 
@@ -474,7 +477,7 @@ static int sfn4111t_check_hw(struct efx_nic *efx)
 		return 0;
 
 	/* Test LHIGH, RHIGH, FAULT, EOT and IOT alarms */
-	status = i2c_smbus_read_byte_data(efx->board_info.hwmon_client,
+	status = i2c_smbus_read_byte_data(falcon_board(efx)->hwmon_client,
 					  MAX664X_REG_RSL);
 	if (status < 0)
 		return -EIO;
@@ -488,7 +491,7 @@ static void sfn4111t_fini(struct efx_nic *efx)
 	EFX_INFO(efx, "%s\n", __func__);
 
 	device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
-	i2c_unregister_device(efx->board_info.hwmon_client);
+	i2c_unregister_device(falcon_board(efx)->hwmon_client);
 }
 
 static struct i2c_board_info sfn4111t_a0_hwmon_info = {
@@ -515,20 +518,21 @@ static void sfn4111t_init_phy(struct efx_nic *efx)
 
 static int sfn4111t_init(struct efx_nic *efx)
 {
+	struct falcon_board *board = falcon_board(efx);
 	int rc;
 
-	efx->board_info.hwmon_client =
+	board->hwmon_client =
 		i2c_new_device(&efx->i2c_adap,
-			       (efx->board_info.minor < 5) ?
+			       (board->minor < 5) ?
 			       &sfn4111t_a0_hwmon_info :
 			       &sfn4111t_r5_hwmon_info);
-	if (!efx->board_info.hwmon_client)
+	if (!board->hwmon_client)
 		return -EIO;
 
-	efx->board_info.init_phy = sfn4111t_init_phy;
-	efx->board_info.set_id_led = tenxpress_set_id_led;
-	efx->board_info.monitor = sfn4111t_check_hw;
-	efx->board_info.fini = sfn4111t_fini;
+	board->init_phy = sfn4111t_init_phy;
+	board->set_id_led = tenxpress_set_id_led;
+	board->monitor = sfn4111t_check_hw;
+	board->fini = sfn4111t_fini;
 
 	rc = device_create_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
 	if (rc)
@@ -542,7 +546,7 @@ static int sfn4111t_init(struct efx_nic *efx)
 	return 0;
 
 fail_hwmon:
-	i2c_unregister_device(efx->board_info.hwmon_client);
+	i2c_unregister_device(board->hwmon_client);
 	return rc;
 }
 
@@ -601,10 +605,12 @@ static void sfe4002_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
 
 static int sfe4002_check_hw(struct efx_nic *efx)
 {
+	struct falcon_board *board = falcon_board(efx);
+
 	/* A0 board rev. 4002s report a temperature fault the whole time
 	 * (bad sensor) so we mask it out. */
 	unsigned alarm_mask =
-		(efx->board_info.major == 0 && efx->board_info.minor == 0) ?
+		(board->major == 0 && board->minor == 0) ?
 		~LM87_ALARM_TEMP_EXT1 : ~0;
 
 	return efx_check_lm87(efx, alarm_mask);
@@ -612,13 +618,14 @@ static int sfe4002_check_hw(struct efx_nic *efx)
 
 static int sfe4002_init(struct efx_nic *efx)
 {
+	struct falcon_board *board = falcon_board(efx);
 	int rc = efx_init_lm87(efx, &sfe4002_hwmon_info, sfe4002_lm87_regs);
 	if (rc)
 		return rc;
-	efx->board_info.monitor = sfe4002_check_hw;
-	efx->board_info.init_phy = sfe4002_init_phy;
-	efx->board_info.set_id_led = sfe4002_set_id_led;
-	efx->board_info.fini = efx_fini_lm87;
+	board->monitor = sfe4002_check_hw;
+	board->init_phy = sfe4002_init_phy;
+	board->set_id_led = sfe4002_set_id_led;
+	board->fini = efx_fini_lm87;
 	return 0;
 }
 
@@ -683,13 +690,15 @@ static int sfn4112f_check_hw(struct efx_nic *efx)
 
 static int sfn4112f_init(struct efx_nic *efx)
 {
+	struct falcon_board *board = falcon_board(efx);
+
 	int rc = efx_init_lm87(efx, &sfn4112f_hwmon_info, sfn4112f_lm87_regs);
 	if (rc)
 		return rc;
-	efx->board_info.monitor = sfn4112f_check_hw;
-	efx->board_info.init_phy = sfn4112f_init_phy;
-	efx->board_info.set_id_led = sfn4112f_set_id_led;
-	efx->board_info.fini = efx_fini_lm87;
+	board->monitor = sfn4112f_check_hw;
+	board->init_phy = sfn4112f_init_phy;
+	board->set_id_led = sfn4112f_set_id_led;
+	board->fini = efx_fini_lm87;
 	return 0;
 }
 
@@ -714,24 +723,25 @@ static struct falcon_board_data board_data[] = {
 
 void falcon_probe_board(struct efx_nic *efx, u16 revision_info)
 {
+	struct falcon_board *board = falcon_board(efx);
 	struct falcon_board_data *data = NULL;
 	int i;
 
-	efx->board_info.type = FALCON_BOARD_TYPE(revision_info);
-	efx->board_info.major = FALCON_BOARD_MAJOR(revision_info);
-	efx->board_info.minor = FALCON_BOARD_MINOR(revision_info);
+	board->type = FALCON_BOARD_TYPE(revision_info);
+	board->major = FALCON_BOARD_MAJOR(revision_info);
+	board->minor = FALCON_BOARD_MINOR(revision_info);
 
 	for (i = 0; i < ARRAY_SIZE(board_data); i++)
-		if (board_data[i].type == efx->board_info.type)
+		if (board_data[i].type == board->type)
 			data = &board_data[i];
 
 	if (data) {
 		EFX_INFO(efx, "board is %s rev %c%d\n",
 			 (efx->pci_dev->subsystem_vendor == EFX_VENDID_SFC)
 			 ? data->ref_model : data->gen_type,
-			 'A' + efx->board_info.major, efx->board_info.minor);
-		efx->board_info.init = data->init;
+			 'A' + board->major, board->minor);
+		board->init = data->init;
 	} else {
-		EFX_ERR(efx, "unknown board type %d\n", efx->board_info.type);
+		EFX_ERR(efx, "unknown board type %d\n", board->type);
 	}
 }
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index e1df589..9b84c3a 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -395,7 +395,7 @@ enum efx_led_mode {
 };
 
 /**
- * struct efx_board - board information
+ * struct falcon_board - board information
  * @type: Board model type
  * @major: Major rev. ('A', 'B' ...)
  * @minor: Minor rev. (0, 1, ...)
@@ -407,7 +407,7 @@ enum efx_led_mode {
  * @hwmon_client: I2C client for hardware monitor
  * @ioexp_client: I2C client for power/port control
  */
-struct efx_board {
+struct falcon_board {
 	int type;
 	int major;
 	int minor;
@@ -752,7 +752,7 @@ struct efx_nic {
 	unsigned int irq_rx_moderation;
 
 	struct i2c_adapter i2c_adap;
-	struct efx_board board_info;
+	struct falcon_board board_info;
 
 	enum nic_state state;
 	enum reset_type reset_pending;
diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index f26684f..73bc5ad 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -126,7 +126,7 @@ static int qt202x_reset_phy(struct efx_nic *efx)
 	if (rc < 0)
 		goto fail;
 
-	efx->board_info.init_phy(efx);
+	falcon_board(efx)->init_phy(efx);
 
 	return rc;
 
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 2923e3d..cb5e057 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -303,7 +303,7 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	u16 old_adv, adv;
 	int rc = 0;
 
-	efx->board_info.init_phy(efx);
+	falcon_board(efx)->init_phy(efx);
 
 	phy_data = kzalloc(sizeof(*phy_data), GFP_KERNEL);
 	if (!phy_data)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

