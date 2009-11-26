From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 06/16] sfc: Clean up struct falcon_board and struct
	falcon_board_data
Date: Thu, 26 Nov 2009 02:09:41 +0000
Message-ID: <1259201381.2806.15.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31172 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbZKZCJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 21:09:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Put all static information in struct falcon_board_type and replace it
with a pointer in struct falcon_board.  Simplify probing aocordingly.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c           |    2 +-
 drivers/net/sfc/ethtool.c       |    6 +-
 drivers/net/sfc/falcon.c        |    4 +-
 drivers/net/sfc/falcon.h        |   34 ++++++++----
 drivers/net/sfc/falcon_boards.c |  115 ++++++++++++++++++---------------------
 drivers/net/sfc/qt202x_phy.c    |    2 +-
 drivers/net/sfc/tenxpress.c     |    2 +-
 7 files changed, 85 insertions(+), 80 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 9f3ef38..dc85efa 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1309,7 +1309,7 @@ static void efx_monitor(struct work_struct *data)
 		goto out_requeue;
 	if (!efx->port_enabled)
 		goto out_unlock;
-	rc = falcon_board(efx)->monitor(efx);
+	rc = falcon_board(efx)->type->monitor(efx);
 	if (rc) {
 		EFX_ERR(efx, "Board sensor %s; shutting down PHY\n",
 			(rc == -ERANGE) ? "reported fault" : "failed");
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index d8915b9..bb9abf2 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -174,14 +174,14 @@ static int efx_ethtool_phys_id(struct net_device *net_dev, u32 count)
 	struct efx_nic *efx = netdev_priv(net_dev);
 
 	do {
-		falcon_board(efx)->set_id_led(efx, EFX_LED_ON);
+		falcon_board(efx)->type->set_id_led(efx, EFX_LED_ON);
 		schedule_timeout_interruptible(HZ / 2);
 
-		falcon_board(efx)->set_id_led(efx, EFX_LED_OFF);
+		falcon_board(efx)->type->set_id_led(efx, EFX_LED_OFF);
 		schedule_timeout_interruptible(HZ / 2);
 	} while (!signal_pending(current) && --count != 0);
 
-	falcon_board(efx)->set_id_led(efx, EFX_LED_DEFAULT);
+	falcon_board(efx)->type->set_id_led(efx, EFX_LED_DEFAULT);
 	return 0;
 }
 
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 2c0be6c..2f1f1fc 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2864,7 +2864,7 @@ int falcon_probe_nic(struct efx_nic *efx)
 	if (rc)
 		goto fail5;
 
-	rc = falcon_board(efx)->init(efx);
+	rc = falcon_board(efx)->type->init(efx);
 	if (rc) {
 		EFX_ERR(efx, "failed to initialise board\n");
 		goto fail6;
@@ -3067,7 +3067,7 @@ void falcon_remove_nic(struct efx_nic *efx)
 	struct falcon_board *board = falcon_board(efx);
 	int rc;
 
-	falcon_board(efx)->fini(efx);
+	board->type->fini(efx);
 
 	/* Remove I2C adapter and clear it in preparation for a retry */
 	rc = i2c_del_adapter(&board->i2c_adap);
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index ea6ac06..b331889 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -31,29 +31,41 @@ static inline int falcon_rev(struct efx_nic *efx)
 }
 
 /**
- * struct falcon_board - board information
- * @type: Board model type
- * @major: Major rev. ('A', 'B' ...)
- * @minor: Minor rev. (0, 1, ...)
+ * struct falcon_board_type - board operations and type information
+ * @id: Board type id, as found in NVRAM
+ * @ref_model: Model number of Solarflare reference design
+ * @gen_type: Generic board type description
  * @init: Allocate resources and initialise peripheral hardware
  * @init_phy: Do board-specific PHY initialisation
+ * @fini: Shut down hardware and free resources
  * @set_id_led: Set state of identifying LED or revert to automatic function
  * @monitor: Board-specific health check function
- * @fini: Shut down hardware and free resources
+ */
+struct falcon_board_type {
+	u8 id;
+	const char *ref_model;
+	const char *gen_type;
+	int (*init) (struct efx_nic *nic);
+	void (*init_phy) (struct efx_nic *efx);
+	void (*fini) (struct efx_nic *nic);
+	void (*set_id_led) (struct efx_nic *efx, enum efx_led_mode mode);
+	int (*monitor) (struct efx_nic *nic);
+};
+
+/**
+ * struct falcon_board - board information
+ * @type: Type of board
+ * @major: Major rev. ('A', 'B' ...)
+ * @minor: Minor rev. (0, 1, ...)
  * @i2c_adap: I2C adapter for on-board peripherals
  * @i2c_data: Data for bit-banging algorithm
  * @hwmon_client: I2C client for hardware monitor
  * @ioexp_client: I2C client for power/port control
  */
 struct falcon_board {
-	int type;
+	const struct falcon_board_type *type;
 	int major;
 	int minor;
-	int (*init) (struct efx_nic *nic);
-	void (*init_phy) (struct efx_nic *efx);
-	void (*set_id_led) (struct efx_nic *efx, enum efx_led_mode mode);
-	int (*monitor) (struct efx_nic *nic);
-	void (*fini) (struct efx_nic *nic);
 	struct i2c_adapter i2c_adap;
 	struct i2c_algo_bit_data i2c_data;
 	struct i2c_client *hwmon_client, *ioexp_client;
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index f05c9d3..ac1258e 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -348,7 +348,7 @@ static ssize_t set_phy_flash_cfg(struct device *dev,
 		efx->phy_mode = new_mode;
 		if (new_mode & PHY_MODE_SPECIAL)
 			efx_stats_disable(efx);
-		if (falcon_board(efx)->type == FALCON_BOARD_SFE4001)
+		if (falcon_board(efx)->type->id == FALCON_BOARD_SFE4001)
 			err = sfe4001_poweron(efx);
 		else
 			err = sfn4111t_reset(efx);
@@ -438,13 +438,6 @@ static int sfe4001_init(struct efx_nic *efx)
 		goto fail_hwmon;
 	}
 
-	/* 10Xpress has fixed-function LED pins, so there is no board-specific
-	 * blink code. */
-	board->set_id_led = tenxpress_set_id_led;
-
-	board->monitor = sfe4001_check_hw;
-	board->fini = sfe4001_fini;
-
 	if (efx->phy_mode & PHY_MODE_SPECIAL) {
 		/* PHY won't generate a 156.25 MHz clock and MAC stats fetch
 		 * will fail. */
@@ -531,11 +524,6 @@ static int sfn4111t_init(struct efx_nic *efx)
 	if (!board->hwmon_client)
 		return -EIO;
 
-	board->init_phy = sfn4111t_init_phy;
-	board->set_id_led = tenxpress_set_id_led;
-	board->monitor = sfn4111t_check_hw;
-	board->fini = sfn4111t_fini;
-
 	rc = device_create_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
 	if (rc)
 		goto fail_hwmon;
@@ -620,15 +608,7 @@ static int sfe4002_check_hw(struct efx_nic *efx)
 
 static int sfe4002_init(struct efx_nic *efx)
 {
-	struct falcon_board *board = falcon_board(efx);
-	int rc = efx_init_lm87(efx, &sfe4002_hwmon_info, sfe4002_lm87_regs);
-	if (rc)
-		return rc;
-	board->monitor = sfe4002_check_hw;
-	board->init_phy = sfe4002_init_phy;
-	board->set_id_led = sfe4002_set_id_led;
-	board->fini = efx_fini_lm87;
-	return 0;
+	return efx_init_lm87(efx, &sfe4002_hwmon_info, sfe4002_lm87_regs);
 }
 
 /*****************************************************************************
@@ -692,67 +672,80 @@ static int sfn4112f_check_hw(struct efx_nic *efx)
 
 static int sfn4112f_init(struct efx_nic *efx)
 {
-	struct falcon_board *board = falcon_board(efx);
-
-	int rc = efx_init_lm87(efx, &sfn4112f_hwmon_info, sfn4112f_lm87_regs);
-	if (rc)
-		return rc;
-	board->monitor = sfn4112f_check_hw;
-	board->init_phy = sfn4112f_init_phy;
-	board->set_id_led = sfn4112f_set_id_led;
-	board->fini = efx_fini_lm87;
-	return 0;
+	return efx_init_lm87(efx, &sfn4112f_hwmon_info, sfn4112f_lm87_regs);
 }
 
-/* This will get expanded as board-specific details get moved out of the
- * PHY drivers. */
-struct falcon_board_data {
-	u8 type;
-	const char *ref_model;
-	const char *gen_type;
-	int (*init) (struct efx_nic *nic);
-};
-
-
-static struct falcon_board_data board_data[] = {
-	{ FALCON_BOARD_SFE4001, "SFE4001", "10GBASE-T adapter", sfe4001_init },
-	{ FALCON_BOARD_SFE4002, "SFE4002", "XFP adapter", sfe4002_init },
-	{ FALCON_BOARD_SFN4111T, "SFN4111T", "100/1000/10GBASE-T adapter",
-	  sfn4111t_init },
-	{ FALCON_BOARD_SFN4112F, "SFN4112F", "SFP+ adapter",
-	  sfn4112f_init },
+static const struct falcon_board_type board_types[] = {
+	{
+		.id		= FALCON_BOARD_SFE4001,
+		.ref_model	= "SFE4001",
+		.gen_type	= "10GBASE-T adapter",
+		.init		= sfe4001_init,
+		.init_phy	= efx_port_dummy_op_void,
+		.fini		= sfe4001_fini,
+		.set_id_led	= tenxpress_set_id_led,
+		.monitor	= sfe4001_check_hw,
+	},
+	{
+		.id		= FALCON_BOARD_SFE4002,
+		.ref_model	= "SFE4002",
+		.gen_type	= "XFP adapter",
+		.init		= sfe4002_init,
+		.init_phy	= sfe4002_init_phy,
+		.fini		= efx_fini_lm87,
+		.set_id_led	= sfe4002_set_id_led,
+		.monitor	= sfe4002_check_hw,
+	},
+	{
+		.id		= FALCON_BOARD_SFN4111T,
+		.ref_model	= "SFN4111T",
+		.gen_type	= "100/1000/10GBASE-T adapter",
+		.init		= sfn4111t_init,
+		.init_phy	= sfn4111t_init_phy,
+		.fini		= sfn4111t_fini,
+		.set_id_led	= tenxpress_set_id_led,
+		.monitor	= sfn4111t_check_hw,
+	},
+	{
+		.id		= FALCON_BOARD_SFN4112F,
+		.ref_model	= "SFN4112F",
+		.gen_type	= "SFP+ adapter",
+		.init		= sfn4112f_init,
+		.init_phy	= sfn4112f_init_phy,
+		.fini		= efx_fini_lm87,
+		.set_id_led	= sfn4112f_set_id_led,
+		.monitor	= sfn4112f_check_hw,
+	},
 };
 
-static struct falcon_board falcon_dummy_board = {
+static const struct falcon_board_type falcon_dummy_board = {
 	.init		= efx_port_dummy_op_int,
 	.init_phy	= efx_port_dummy_op_void,
+	.fini		= efx_port_dummy_op_void,
 	.set_id_led	= efx_port_dummy_op_set_id_led,
 	.monitor	= efx_port_dummy_op_int,
-	.fini		= efx_port_dummy_op_void,
 };
 
 void falcon_probe_board(struct efx_nic *efx, u16 revision_info)
 {
 	struct falcon_board *board = falcon_board(efx);
-	struct falcon_board_data *data = NULL;
+	u8 type_id = FALCON_BOARD_TYPE(revision_info);
 	int i;
 
-	*board = falcon_dummy_board;
-	board->type = FALCON_BOARD_TYPE(revision_info);
 	board->major = FALCON_BOARD_MAJOR(revision_info);
 	board->minor = FALCON_BOARD_MINOR(revision_info);
 
-	for (i = 0; i < ARRAY_SIZE(board_data); i++)
-		if (board_data[i].type == board->type)
-			data = &board_data[i];
+	for (i = 0; i < ARRAY_SIZE(board_types); i++)
+		if (board_types[i].id == type_id)
+			board->type = &board_types[i];
 
-	if (data) {
+	if (board->type) {
 		EFX_INFO(efx, "board is %s rev %c%d\n",
 			 (efx->pci_dev->subsystem_vendor == EFX_VENDID_SFC)
-			 ? data->ref_model : data->gen_type,
+			 ? board->type->ref_model : board->type->gen_type,
 			 'A' + board->major, board->minor);
-		board->init = data->init;
 	} else {
-		EFX_ERR(efx, "unknown board type %d\n", board->type);
+		EFX_ERR(efx, "unknown board type %d\n", type_id);
+		board->type = &falcon_dummy_board;
 	}
 }
diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index 8208ac0..f9c354e 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -126,7 +126,7 @@ static int qt202x_reset_phy(struct efx_nic *efx)
 	if (rc < 0)
 		goto fail;
 
-	falcon_board(efx)->init_phy(efx);
+	falcon_board(efx)->type->init_phy(efx);
 
 	return rc;
 
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index b001f38..a95402d 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -303,7 +303,7 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	u16 old_adv, adv;
 	int rc = 0;
 
-	falcon_board(efx)->init_phy(efx);
+	falcon_board(efx)->type->init_phy(efx);
 
 	phy_data = kzalloc(sizeof(*phy_data), GFP_KERNEL);
 	if (!phy_data)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

