From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 6/8] can: flexcan: put TX mailbox into TX_INACTIVE mode after tx-complete
Date: Thu, 18 Sep 2014 12:41:00 +0200
Message-ID: <1411036862-13255-7-git-send-email-mkl@pengutronix.de>
References: <1411036862-13255-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-stable <stable@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1411036862-13255-1-git-send-email-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After sending a RTR frame the TX mailbox becomes a RX_EMPTY mailbox. To avoid
side effects when the RX-FIFO is full, this patch puts the TX mailbox into
TX_INACTIVE mode in the transmission complete interrupt handler. This, of
course, leaves a race window between the actual completion of the transmission
and the handling of tx-complete interrupt. However this is the best we can do
without busy polling the tx complete interrupt.

Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 54061c4..c17ae9e 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -765,6 +765,9 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 		stats->tx_bytes += can_get_echo_skb(dev, 0);
 		stats->tx_packets++;
 		can_led_event(dev, CAN_LED_EVENT_TX);
+		/* after sending a RTR frame mailbox is in RX mode */
+		flexcan_write(FLEXCAN_MB_CODE_TX_INACTIVE,
+			      &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
 		flexcan_write((1 << FLEXCAN_TX_BUF_ID), &regs->iflag1);
 		netif_wake_queue(dev);
 	}
-- 
2.1.0
