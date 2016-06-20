From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/3] can: at91_can: RX queue could get stuck at high bus load
Date: Mon, 20 Jun 2016 10:00:29 +0200
Message-ID: <1466409630-6268-3-git-send-email-mkl@pengutronix.de>
References: <1466409630-6268-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Wolfgang Grandegger <wg@grandegger.com>,
	stable@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1466409630-6268-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wolfgang Grandegger <wg@grandegger.com>

At high bus load it could happen that "at91_poll()" enters with all RX
message boxes filled up. If then at the end the "quota" is exceeded as
well, "rx_next" will not be reset to the first RX mailbox and hence the
interrupts remain disabled.

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
Tested-by: Amr Bekhit <amrbekhit@gmail.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/at91_can.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 8b3275d7792a..8f5e93cb7975 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -712,9 +712,10 @@ static int at91_poll_rx(struct net_device *dev, int quota)
 
 	/* upper group completed, look again in lower */
 	if (priv->rx_next > get_mb_rx_low_last(priv) &&
-	    quota > 0 && mb > get_mb_rx_last(priv)) {
+	    mb > get_mb_rx_last(priv)) {
 		priv->rx_next = get_mb_rx_first(priv);
-		goto again;
+		if (quota > 0)
+			goto again;
 	}
 
 	return received;
-- 
2.8.1

