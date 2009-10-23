From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 13/27] sfc: Merge struct efx_blinker into struct efx_board
Date: Fri, 23 Oct 2009 19:31:29 +0100
Message-ID: <1256322689.2785.29.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8760 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905AbZJWSb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:31:26 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon_boards.c |   29 +++++++++++++++--------------
 drivers/net/sfc/net_driver.h    |   21 ++++++---------------
 2 files changed, 21 insertions(+), 29 deletions(-)

diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index 3078c00..f65738b 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -35,30 +35,31 @@
 static void blink_led_timer(unsigned long context)
 {
 	struct efx_nic *efx = (struct efx_nic *)context;
-	struct efx_blinker *bl = &efx->board_info.blinker;
-	efx->board_info.set_id_led(efx, bl->state);
-	bl->state = !bl->state;
-	if (bl->resubmit)
-		mod_timer(&bl->timer, jiffies + BLINK_INTERVAL);
+	struct efx_board *board = &efx->board_info;
+
+	board->set_id_led(efx, board->blink_state);
+	board->blink_state = !board->blink_state;
+	if (board->blink_resubmit)
+		mod_timer(&board->blink_timer, jiffies + BLINK_INTERVAL);
 }
 
 static void board_blink(struct efx_nic *efx, bool blink)
 {
-	struct efx_blinker *blinker = &efx->board_info.blinker;
+	struct efx_board *board = &efx->board_info;
 
 	/* The rtnl mutex serialises all ethtool ioctls, so
 	 * nothing special needs doing here. */
 	if (blink) {
-		blinker->resubmit = true;
-		blinker->state = false;
-		setup_timer(&blinker->timer, blink_led_timer,
+		board->blink_resubmit = true;
+		board->blink_state = false;
+		setup_timer(&board->blink_timer, blink_led_timer,
 			    (unsigned long)efx);
-		mod_timer(&blinker->timer, jiffies + BLINK_INTERVAL);
+		mod_timer(&board->blink_timer, jiffies + BLINK_INTERVAL);
 	} else {
-		blinker->resubmit = false;
-		if (blinker->timer.function)
-			del_timer_sync(&blinker->timer);
-		efx->board_info.init_leds(efx);
+		board->blink_resubmit = false;
+		if (board->blink_timer.function)
+			del_timer_sync(&board->blink_timer);
+		board->init_leds(efx);
 	}
 }
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 91d8952..8e7b854 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -389,19 +389,6 @@ struct efx_channel {
 };
 
 /**
- * struct efx_blinker - S/W LED blinking context
- * @state: Current state - on or off
- * @resubmit: Timer resubmission flag
- * @timer: Control timer for blinking
- */
-struct efx_blinker {
-	bool state;
-	bool resubmit;
-	struct timer_list timer;
-};
-
-
-/**
  * struct efx_board - board information
  * @type: Board model type
  * @major: Major rev. ('A', 'B' ...)
@@ -412,7 +399,9 @@ struct efx_blinker {
  * @blink: Starts/stops blinking
  * @monitor: Board-specific health check function
  * @fini: Cleanup function
- * @blinker: used to blink LEDs in software
+ * @blink_state: Current blink state
+ * @blink_resubmit: Blink timer resubmission flag
+ * @blink_timer: Blink timer
  * @hwmon_client: I2C client for hardware monitor
  * @ioexp_client: I2C client for power/port control
  */
@@ -429,7 +418,9 @@ struct efx_board {
 	int (*monitor) (struct efx_nic *nic);
 	void (*blink) (struct efx_nic *efx, bool start);
 	void (*fini) (struct efx_nic *nic);
-	struct efx_blinker blinker;
+	bool blink_state;
+	bool blink_resubmit;
+	struct timer_list blink_timer;
 	struct i2c_client *hwmon_client, *ioexp_client;
 };
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

