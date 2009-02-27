From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 8/9] sfc: Clean up LED control
Date: Fri, 27 Feb 2009 23:08:03 +0000
Message-ID: <1235776083.3164.28.camel@achroite>
References: <1235775847.3164.6.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:40687 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755835AbZB0XIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 18:08:07 -0500
In-Reply-To: <1235775847.3164.6.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reinitialise LEDs after overriding them for identification.

Rename set_fault_led method to set_id_led since we always use it for
NIC identification and not faults.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/boards.c     |   11 +++++------
 drivers/net/sfc/efx.c        |    4 ++--
 drivers/net/sfc/net_driver.h |    8 ++++----
 3 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
index 1260875..b709878 100644
--- a/drivers/net/sfc/boards.c
+++ b/drivers/net/sfc/boards.c
@@ -26,7 +26,7 @@ static void blink_led_timer(unsigned long context)
 {
 	struct efx_nic *efx = (struct efx_nic *)context;
 	struct efx_blinker *bl = &efx->board_info.blinker;
-	efx->board_info.set_fault_led(efx, bl->state);
+	efx->board_info.set_id_led(efx, bl->state);
 	bl->state = !bl->state;
 	if (bl->resubmit)
 		mod_timer(&bl->timer, jiffies + BLINK_INTERVAL);
@@ -48,7 +48,7 @@ static void board_blink(struct efx_nic *efx, bool blink)
 		blinker->resubmit = false;
 		if (blinker->timer.function)
 			del_timer_sync(&blinker->timer);
-		efx->board_info.set_fault_led(efx, false);
+		efx->board_info.init_leds(efx);
 	}
 }
 
@@ -185,7 +185,7 @@ static struct i2c_board_info sfe4002_hwmon_info = {
 #define SFE4002_RX_LED    (0)	/* Green */
 #define SFE4002_TX_LED    (1)	/* Amber */
 
-static int sfe4002_init_leds(struct efx_nic *efx)
+static void sfe4002_init_leds(struct efx_nic *efx)
 {
 	/* Set the TX and RX LEDs to reflect status and activity, and the
 	 * fault LED off */
@@ -194,10 +194,9 @@ static int sfe4002_init_leds(struct efx_nic *efx)
 	xfp_set_led(efx, SFE4002_RX_LED,
 		    QUAKE_LED_RXLINK | QUAKE_LED_LINK_ACTSTAT);
 	xfp_set_led(efx, SFE4002_FAULT_LED, QUAKE_LED_OFF);
-	return 0;
 }
 
-static void sfe4002_fault_led(struct efx_nic *efx, bool state)
+static void sfe4002_set_id_led(struct efx_nic *efx, bool state)
 {
 	xfp_set_led(efx, SFE4002_FAULT_LED, state ? QUAKE_LED_ON :
 			QUAKE_LED_OFF);
@@ -221,7 +220,7 @@ static int sfe4002_init(struct efx_nic *efx)
 		return rc;
 	efx->board_info.monitor = sfe4002_check_hw;
 	efx->board_info.init_leds = sfe4002_init_leds;
-	efx->board_info.set_fault_led = sfe4002_fault_led;
+	efx->board_info.set_id_led = sfe4002_set_id_led;
 	efx->board_info.blink = board_blink;
 	efx->board_info.fini = efx_fini_lm87;
 	return 0;
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 7583659..45df110 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1848,8 +1848,8 @@ static struct efx_phy_operations efx_dummy_phy_operations = {
 
 static struct efx_board efx_dummy_board_info = {
 	.init		= efx_port_dummy_op_int,
-	.init_leds	= efx_port_dummy_op_int,
-	.set_fault_led	= efx_port_dummy_op_blink,
+	.init_leds	= efx_port_dummy_op_void,
+	.set_id_led	= efx_port_dummy_op_blink,
 	.monitor	= efx_port_dummy_op_int,
 	.blink		= efx_port_dummy_op_blink,
 	.fini		= efx_port_dummy_op_void,
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index ebc7b63..b81fc72 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -402,8 +402,8 @@ struct efx_blinker {
  * @major: Major rev. ('A', 'B' ...)
  * @minor: Minor rev. (0, 1, ...)
  * @init: Initialisation function
- * @init_leds: Sets up board LEDs
- * @set_fault_led: Turns the fault LED on or off
+ * @init_leds: Sets up board LEDs. May be called repeatedly.
+ * @set_id_led: Turns the identification LED on or off
  * @blink: Starts/stops blinking
  * @monitor: Board-specific health check function
  * @fini: Cleanup function
@@ -419,9 +419,9 @@ struct efx_board {
 	/* As the LEDs are typically attached to the PHY, LEDs
 	 * have a separate init callback that happens later than
 	 * board init. */
-	int (*init_leds)(struct efx_nic *efx);
+	void (*init_leds)(struct efx_nic *efx);
+	void (*set_id_led) (struct efx_nic *efx, bool state);
 	int (*monitor) (struct efx_nic *nic);
-	void (*set_fault_led) (struct efx_nic *efx, bool state);
 	void (*blink) (struct efx_nic *efx, bool start);
 	void (*fini) (struct efx_nic *nic);
 	struct efx_blinker blinker;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

