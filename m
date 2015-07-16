From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/2] can: mcp251x: fix resume when device is down
Date: Thu, 16 Jul 2015 10:33:54 +0200
Message-ID: <1437035635-18635-2-git-send-email-mkl@pengutronix.de>
References: <1437035635-18635-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Stefan Agner <stefan@agner.ch>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35395 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbbGPIeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 04:34:00 -0400
In-Reply-To: <1437035635-18635-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Agner <stefan@agner.ch>

If a valid power regulator or a dummy regulator is used (which
happens to be the case when no regulator is specified), restart_work
is queued no matter whether the device was running or not at suspend
time. Since work queues get initialized in the ndo_open callback,
resuming leads to a NULL pointer exception.

Reverse exactly the steps executed at suspend time:
- Enable the power regulator in any case
- Enable the transceiver regulator if the device was running, even in
  case we have a power regulator
- Queue restart_work only in case the device was running

Fixes: bf66f3736a94 ("can: mcp251x: Move to threaded interrupts instead of workqueues.")
Signed-off-by: Stefan Agner <stefan@agner.ch>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/spi/mcp251x.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/can/spi/mcp251x.c b/drivers/net/can/spi/mcp251x.c
index c1a95a34d62e..3b2f34e6ba9b 100644
--- a/drivers/net/can/spi/mcp251x.c
+++ b/drivers/net/can/spi/mcp251x.c
@@ -1222,17 +1222,16 @@ static int __maybe_unused mcp251x_can_resume(struct device *dev)
 	struct spi_device *spi = to_spi_device(dev);
 	struct mcp251x_priv *priv = spi_get_drvdata(spi);
 
-	if (priv->after_suspend & AFTER_SUSPEND_POWER) {
+	if (priv->after_suspend & AFTER_SUSPEND_POWER)
 		mcp251x_power_enable(priv->power, 1);
+
+	if (priv->after_suspend & AFTER_SUSPEND_UP) {
+		mcp251x_power_enable(priv->transceiver, 1);
 		queue_work(priv->wq, &priv->restart_work);
 	} else {
-		if (priv->after_suspend & AFTER_SUSPEND_UP) {
-			mcp251x_power_enable(priv->transceiver, 1);
-			queue_work(priv->wq, &priv->restart_work);
-		} else {
-			priv->after_suspend = 0;
-		}
+		priv->after_suspend = 0;
 	}
+
 	priv->force_quit = 0;
 	enable_irq(spi->irq);
 	return 0;
-- 
2.1.4
