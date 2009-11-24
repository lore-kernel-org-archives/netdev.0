From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 08/17] sfc: Rename efx_board::init_leds to init_phy and use
	for SFN4111T
Date: Tue, 24 Nov 2009 02:04:23 +0000
Message-ID: <1259028263.14645.19.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:34731 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757599AbZKXCEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 21:04:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_board::init_leds was introduced as a second stage of
initialisation because of the inter-dependency between the board and
PHY.  We want to move board initialisation into NIC probing, which is
too early to use MDIO, so SFN4111T initialisation also needs to be
split.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c           |    2 +-
 drivers/net/sfc/falcon_boards.c |   43 ++++++++++++++++++++++----------------
 drivers/net/sfc/net_driver.h    |   11 +++------
 drivers/net/sfc/qt202x_phy.c    |    2 +-
 drivers/net/sfc/tenxpress.c     |    2 +
 5 files changed, 33 insertions(+), 27 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 612cd81..d7705a7 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1910,7 +1910,7 @@ static struct efx_phy_operations efx_dummy_phy_operations = {
 
 static struct efx_board efx_dummy_board_info = {
 	.init		= efx_port_dummy_op_int,
-	.init_leds	= efx_port_dummy_op_void,
+	.init_phy	= efx_port_dummy_op_void,
 	.set_id_led	= efx_port_dummy_op_set_id_led,
 	.monitor	= efx_port_dummy_op_int,
 	.fini		= efx_port_dummy_op_void,
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index b2505fc..429d3cd 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -499,9 +499,22 @@ static struct i2c_board_info sfn4111t_r5_hwmon_info = {
 	I2C_BOARD_INFO("max6646", 0x4d),
 };
 
+static void sfn4111t_init_phy(struct efx_nic *efx)
+{
+	if (!(efx->phy_mode & PHY_MODE_SPECIAL)) {
+		if (sft9001_wait_boot(efx) != -EINVAL)
+			return;
+
+		efx->phy_mode = PHY_MODE_SPECIAL;
+		efx_stats_disable(efx);
+	}
+
+	sfn4111t_reset(efx);
+	sft9001_wait_boot(efx);
+}
+
 static int sfn4111t_init(struct efx_nic *efx)
 {
-	int i = 0;
 	int rc;
 
 	efx->board_info.hwmon_client =
@@ -512,6 +525,7 @@ static int sfn4111t_init(struct efx_nic *efx)
 	if (!efx->board_info.hwmon_client)
 		return -EIO;
 
+	efx->board_info.init_phy = sfn4111t_init_phy;
 	efx->board_info.set_id_led = tenxpress_set_id_led;
 	efx->board_info.monitor = sfn4111t_check_hw;
 	efx->board_info.fini = sfn4111t_fini;
@@ -520,20 +534,13 @@ static int sfn4111t_init(struct efx_nic *efx)
 	if (rc)
 		goto fail_hwmon;
 
-	do {
-		if (efx->phy_mode & PHY_MODE_SPECIAL) {
-			/* PHY may not generate a 156.25 MHz clock and MAC
-			 * stats fetch will fail. */
-			efx_stats_disable(efx);
-			sfn4111t_reset(efx);
-		}
-		rc = sft9001_wait_boot(efx);
-		if (rc == 0)
-			return 0;
-		efx->phy_mode = PHY_MODE_SPECIAL;
-	} while (rc == -EINVAL && ++i < 2);
+	if (efx->phy_mode & PHY_MODE_SPECIAL)
+		/* PHY may not generate a 156.25 MHz clock and MAC
+		 * stats fetch will fail. */
+		efx_stats_disable(efx);
+
+	return 0;
 
-	device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
 fail_hwmon:
 	i2c_unregister_device(efx->board_info.hwmon_client);
 	return rc;
@@ -574,7 +581,7 @@ static struct i2c_board_info sfe4002_hwmon_info = {
 #define SFE4002_RX_LED    (0)	/* Green */
 #define SFE4002_TX_LED    (1)	/* Amber */
 
-static void sfe4002_init_leds(struct efx_nic *efx)
+static void sfe4002_init_phy(struct efx_nic *efx)
 {
 	/* Set the TX and RX LEDs to reflect status and activity, and the
 	 * fault LED off */
@@ -609,7 +616,7 @@ static int sfe4002_init(struct efx_nic *efx)
 	if (rc)
 		return rc;
 	efx->board_info.monitor = sfe4002_check_hw;
-	efx->board_info.init_leds = sfe4002_init_leds;
+	efx->board_info.init_phy = sfe4002_init_phy;
 	efx->board_info.set_id_led = sfe4002_set_id_led;
 	efx->board_info.fini = efx_fini_lm87;
 	return 0;
@@ -641,7 +648,7 @@ static struct i2c_board_info sfn4112f_hwmon_info = {
 #define SFN4112F_ACT_LED	0
 #define SFN4112F_LINK_LED	1
 
-static void sfn4112f_init_leds(struct efx_nic *efx)
+static void sfn4112f_init_phy(struct efx_nic *efx)
 {
 	falcon_qt202x_set_led(efx, SFN4112F_ACT_LED,
 			      QUAKE_LED_RXLINK | QUAKE_LED_LINK_ACT);
@@ -680,7 +687,7 @@ static int sfn4112f_init(struct efx_nic *efx)
 	if (rc)
 		return rc;
 	efx->board_info.monitor = sfn4112f_check_hw;
-	efx->board_info.init_leds = sfn4112f_init_leds;
+	efx->board_info.init_phy = sfn4112f_init_phy;
 	efx->board_info.set_id_led = sfn4112f_set_id_led;
 	efx->board_info.fini = efx_fini_lm87;
 	return 0;
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 6b05d69..e1df589 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -399,11 +399,11 @@ enum efx_led_mode {
  * @type: Board model type
  * @major: Major rev. ('A', 'B' ...)
  * @minor: Minor rev. (0, 1, ...)
- * @init: Initialisation function
- * @init_leds: Sets up board LEDs. May be called repeatedly.
+ * @init: Allocate resources and initialise peripheral hardware
+ * @init_phy: Do board-specific PHY initialisation
  * @set_id_led: Set state of identifying LED or revert to automatic function
  * @monitor: Board-specific health check function
- * @fini: Cleanup function
+ * @fini: Shut down hardware and free resources
  * @hwmon_client: I2C client for hardware monitor
  * @ioexp_client: I2C client for power/port control
  */
@@ -412,10 +412,7 @@ struct efx_board {
 	int major;
 	int minor;
 	int (*init) (struct efx_nic *nic);
-	/* As the LEDs are typically attached to the PHY, LEDs
-	 * have a separate init callback that happens later than
-	 * board init. */
-	void (*init_leds)(struct efx_nic *efx);
+	void (*init_phy) (struct efx_nic *efx);
 	void (*set_id_led) (struct efx_nic *efx, enum efx_led_mode mode);
 	int (*monitor) (struct efx_nic *nic);
 	void (*fini) (struct efx_nic *nic);
diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index 05c0f9a..f26684f 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -126,7 +126,7 @@ static int qt202x_reset_phy(struct efx_nic *efx)
 	if (rc < 0)
 		goto fail;
 
-	efx->board_info.init_leds(efx);
+	efx->board_info.init_phy(efx);
 
 	return rc;
 
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 6a8e3ea..2923e3d 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -303,6 +303,8 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	u16 old_adv, adv;
 	int rc = 0;
 
+	efx->board_info.init_phy(efx);
+
 	phy_data = kzalloc(sizeof(*phy_data), GFP_KERNEL);
 	if (!phy_data)
 		return -ENOMEM;


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

