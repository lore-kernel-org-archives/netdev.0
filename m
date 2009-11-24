From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 07/17] sfc: Use a single blink implementation
Date: Tue, 24 Nov 2009 02:03:45 +0000
Message-ID: <1259028225.14645.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:34690 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752349AbZKXCDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 21:03:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only some PHYs have firmware support for a LED blink mode, so we
currently blink the others in a timer function.  Since all PHYs have
simple on and off modes, we don't gain anything by using multiple
blink implementations.  Also, since we have a process context there
is no need to use a timer.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c           |    7 ++--
 drivers/net/sfc/efx.h           |    3 +-
 drivers/net/sfc/ethtool.c       |   16 +++++----
 drivers/net/sfc/falcon_boards.c |   66 +++++++++++++--------------------------
 drivers/net/sfc/net_driver.h    |   18 +++++------
 drivers/net/sfc/phy.h           |    2 +-
 drivers/net/sfc/qt202x_phy.c    |    3 --
 drivers/net/sfc/tenxpress.c     |   24 +++++++++-----
 8 files changed, 62 insertions(+), 77 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 0d0243b..612cd81 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1890,7 +1890,9 @@ int efx_port_dummy_op_int(struct efx_nic *efx)
 	return 0;
 }
 void efx_port_dummy_op_void(struct efx_nic *efx) {}
-void efx_port_dummy_op_blink(struct efx_nic *efx, bool blink) {}
+void efx_port_dummy_op_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
+{
+}
 
 static struct efx_mac_operations efx_dummy_mac_operations = {
 	.reconfigure	= efx_port_dummy_op_void,
@@ -1909,9 +1911,8 @@ static struct efx_phy_operations efx_dummy_phy_operations = {
 static struct efx_board efx_dummy_board_info = {
 	.init		= efx_port_dummy_op_int,
 	.init_leds	= efx_port_dummy_op_void,
-	.set_id_led	= efx_port_dummy_op_blink,
+	.set_id_led	= efx_port_dummy_op_set_id_led,
 	.monitor	= efx_port_dummy_op_int,
-	.blink		= efx_port_dummy_op_blink,
 	.fini		= efx_port_dummy_op_void,
 };
 
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 179e0e3..6f46394 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -69,7 +69,8 @@ extern void efx_hex_dump(const u8 *, unsigned int, const char *);
 /* Dummy PHY ops for PHY drivers */
 extern int efx_port_dummy_op_int(struct efx_nic *efx);
 extern void efx_port_dummy_op_void(struct efx_nic *efx);
-extern void efx_port_dummy_op_blink(struct efx_nic *efx, bool blink);
+extern void
+efx_port_dummy_op_set_id_led(struct efx_nic *efx, enum efx_led_mode mode);
 
 /* MTD */
 #ifdef CONFIG_SFC_MTD
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index a313b61..18e0271 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -187,13 +187,15 @@ static int efx_ethtool_phys_id(struct net_device *net_dev, u32 count)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
-	efx->board_info.blink(efx, 1);
-	set_current_state(TASK_INTERRUPTIBLE);
-	if (count)
-		schedule_timeout(count * HZ);
-	else
-		schedule();
-	efx->board_info.blink(efx, 0);
+	do {
+		efx->board_info.set_id_led(efx, EFX_LED_ON);
+		schedule_timeout_interruptible(HZ / 2);
+
+		efx->board_info.set_id_led(efx, EFX_LED_OFF);
+		schedule_timeout_interruptible(HZ / 2);
+	} while (!signal_pending(current) && --count != 0);
+
+	efx->board_info.set_id_led(efx, EFX_LED_DEFAULT);
 	return 0;
 }
 
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index d31c134..b2505fc 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -29,40 +29,6 @@
 #define FALCON_BOARD_SFN4111T 0x51
 #define FALCON_BOARD_SFN4112F 0x52
 
-/* Blink support. If the PHY has no auto-blink mode so we hang it off a timer */
-#define BLINK_INTERVAL (HZ/2)
-
-static void blink_led_timer(unsigned long context)
-{
-	struct efx_nic *efx = (struct efx_nic *)context;
-	struct efx_board *board = &efx->board_info;
-
-	board->set_id_led(efx, board->blink_state);
-	board->blink_state = !board->blink_state;
-	if (board->blink_resubmit)
-		mod_timer(&board->blink_timer, jiffies + BLINK_INTERVAL);
-}
-
-static void board_blink(struct efx_nic *efx, bool blink)
-{
-	struct efx_board *board = &efx->board_info;
-
-	/* The rtnl mutex serialises all ethtool ioctls, so
-	 * nothing special needs doing here. */
-	if (blink) {
-		board->blink_resubmit = true;
-		board->blink_state = false;
-		setup_timer(&board->blink_timer, blink_led_timer,
-			    (unsigned long)efx);
-		mod_timer(&board->blink_timer, jiffies + BLINK_INTERVAL);
-	} else {
-		board->blink_resubmit = false;
-		if (board->blink_timer.function)
-			del_timer_sync(&board->blink_timer);
-		board->init_leds(efx);
-	}
-}
-
 /*****************************************************************************
  * Support for LM87 sensor chip used on several boards
  */
@@ -469,7 +435,7 @@ static int sfe4001_init(struct efx_nic *efx)
 
 	/* 10Xpress has fixed-function LED pins, so there is no board-specific
 	 * blink code. */
-	efx->board_info.blink = tenxpress_phy_blink;
+	efx->board_info.set_id_led = tenxpress_set_id_led;
 
 	efx->board_info.monitor = sfe4001_check_hw;
 	efx->board_info.fini = sfe4001_fini;
@@ -546,7 +512,7 @@ static int sfn4111t_init(struct efx_nic *efx)
 	if (!efx->board_info.hwmon_client)
 		return -EIO;
 
-	efx->board_info.blink = tenxpress_phy_blink;
+	efx->board_info.set_id_led = tenxpress_set_id_led;
 	efx->board_info.monitor = sfn4111t_check_hw;
 	efx->board_info.fini = sfn4111t_fini;
 
@@ -619,10 +585,11 @@ static void sfe4002_init_leds(struct efx_nic *efx)
 	falcon_qt202x_set_led(efx, SFE4002_FAULT_LED, QUAKE_LED_OFF);
 }
 
-static void sfe4002_set_id_led(struct efx_nic *efx, bool state)
+static void sfe4002_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
 {
-	falcon_qt202x_set_led(efx, SFE4002_FAULT_LED, state ? QUAKE_LED_ON :
-			      QUAKE_LED_OFF);
+	falcon_qt202x_set_led(
+		efx, SFE4002_FAULT_LED,
+		(mode == EFX_LED_ON) ? QUAKE_LED_ON : QUAKE_LED_OFF);
 }
 
 static int sfe4002_check_hw(struct efx_nic *efx)
@@ -644,7 +611,6 @@ static int sfe4002_init(struct efx_nic *efx)
 	efx->board_info.monitor = sfe4002_check_hw;
 	efx->board_info.init_leds = sfe4002_init_leds;
 	efx->board_info.set_id_led = sfe4002_set_id_led;
-	efx->board_info.blink = board_blink;
 	efx->board_info.fini = efx_fini_lm87;
 	return 0;
 }
@@ -683,10 +649,23 @@ static void sfn4112f_init_leds(struct efx_nic *efx)
 			      QUAKE_LED_RXLINK | QUAKE_LED_LINK_STAT);
 }
 
-static void sfn4112f_set_id_led(struct efx_nic *efx, bool state)
+static void sfn4112f_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
 {
-	falcon_qt202x_set_led(efx, SFN4112F_LINK_LED,
-			      state ? QUAKE_LED_ON : QUAKE_LED_OFF);
+	int reg;
+
+	switch (mode) {
+	case EFX_LED_OFF:
+		reg = QUAKE_LED_OFF;
+		break;
+	case EFX_LED_ON:
+		reg = QUAKE_LED_ON;
+		break;
+	default:
+		reg = QUAKE_LED_RXLINK | QUAKE_LED_LINK_STAT;
+		break;
+	}
+
+	falcon_qt202x_set_led(efx, SFN4112F_LINK_LED, reg);
 }
 
 static int sfn4112f_check_hw(struct efx_nic *efx)
@@ -703,7 +682,6 @@ static int sfn4112f_init(struct efx_nic *efx)
 	efx->board_info.monitor = sfn4112f_check_hw;
 	efx->board_info.init_leds = sfn4112f_init_leds;
 	efx->board_info.set_id_led = sfn4112f_set_id_led;
-	efx->board_info.blink = board_blink;
 	efx->board_info.fini = efx_fini_lm87;
 	return 0;
 }
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index bc6fb2b..6b05d69 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -388,6 +388,12 @@ struct efx_channel {
 
 };
 
+enum efx_led_mode {
+	EFX_LED_OFF	= 0,
+	EFX_LED_ON	= 1,
+	EFX_LED_DEFAULT	= 2
+};
+
 /**
  * struct efx_board - board information
  * @type: Board model type
@@ -395,13 +401,9 @@ struct efx_channel {
  * @minor: Minor rev. (0, 1, ...)
  * @init: Initialisation function
  * @init_leds: Sets up board LEDs. May be called repeatedly.
- * @set_id_led: Turns the identification LED on or off
- * @blink: Starts/stops blinking
+ * @set_id_led: Set state of identifying LED or revert to automatic function
  * @monitor: Board-specific health check function
  * @fini: Cleanup function
- * @blink_state: Current blink state
- * @blink_resubmit: Blink timer resubmission flag
- * @blink_timer: Blink timer
  * @hwmon_client: I2C client for hardware monitor
  * @ioexp_client: I2C client for power/port control
  */
@@ -414,13 +416,9 @@ struct efx_board {
 	 * have a separate init callback that happens later than
 	 * board init. */
 	void (*init_leds)(struct efx_nic *efx);
-	void (*set_id_led) (struct efx_nic *efx, bool state);
+	void (*set_id_led) (struct efx_nic *efx, enum efx_led_mode mode);
 	int (*monitor) (struct efx_nic *nic);
-	void (*blink) (struct efx_nic *efx, bool start);
 	void (*fini) (struct efx_nic *nic);
-	bool blink_state;
-	bool blink_resubmit;
-	struct timer_list blink_timer;
 	struct i2c_client *hwmon_client, *ioexp_client;
 };
 
diff --git a/drivers/net/sfc/phy.h b/drivers/net/sfc/phy.h
index b5150f3..2ad1cec 100644
--- a/drivers/net/sfc/phy.h
+++ b/drivers/net/sfc/phy.h
@@ -16,7 +16,7 @@
 extern struct efx_phy_operations falcon_sfx7101_phy_ops;
 extern struct efx_phy_operations falcon_sft9001_phy_ops;
 
-extern void tenxpress_phy_blink(struct efx_nic *efx, bool blink);
+extern void tenxpress_set_id_led(struct efx_nic *efx, enum efx_led_mode mode);
 
 /* Wait for the PHY to boot. Return 0 on success, -EINVAL if the PHY failed
  * to boot due to corrupt flash, or some other negative error code. */
diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index 560eb18..05c0f9a 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -228,9 +228,6 @@ static void qt202x_phy_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecm
 
 static void qt202x_phy_fini(struct efx_nic *efx)
 {
-	/* Clobber the LED if it was blinking */
-	efx->board_info.blink(efx, false);
-
 	/* Free the context block */
 	kfree(efx->phy_data);
 	efx->phy_data = NULL;
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 19c78d2..6a8e3ea 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -613,21 +613,29 @@ static void tenxpress_phy_fini(struct efx_nic *efx)
 }
 

-/* Set the RX and TX LEDs and Link LED flashing. The other LEDs
- * (which probably aren't wired anyway) are left in AUTO mode */
-void tenxpress_phy_blink(struct efx_nic *efx, bool blink)
+/* Override the RX, TX and link LEDs */
+void tenxpress_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
 {
 	int reg;
 
-	if (blink)
-		reg = (PMA_PMD_LED_FLASH << PMA_PMD_LED_TX_LBN) |
-			(PMA_PMD_LED_FLASH << PMA_PMD_LED_RX_LBN) |
-			(PMA_PMD_LED_FLASH << PMA_PMD_LED_LINK_LBN);
-	else
+	switch (mode) {
+	case EFX_LED_OFF:
+		reg = (PMA_PMD_LED_OFF << PMA_PMD_LED_TX_LBN) |
+			(PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN) |
+			(PMA_PMD_LED_OFF << PMA_PMD_LED_LINK_LBN);
+		break;
+	case EFX_LED_ON:
+		reg = (PMA_PMD_LED_ON << PMA_PMD_LED_TX_LBN) |
+			(PMA_PMD_LED_ON << PMA_PMD_LED_RX_LBN) |
+			(PMA_PMD_LED_ON << PMA_PMD_LED_LINK_LBN);
+		break;
+	default:
 		if (efx->phy_type == PHY_TYPE_SFX7101)
 			reg = SFX7101_PMA_PMD_LED_DEFAULT;
 		else
 			reg = SFT9001_PMA_PMD_LED_DEFAULT;
+		break;
+	}
 
 	efx_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_LED_OVERR_REG, reg);
 }

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

