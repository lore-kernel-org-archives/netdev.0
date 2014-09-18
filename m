From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 5/8] can: flexcan: implement workaround for errata ERR005829
Date: Thu, 18 Sep 2014 12:40:59 +0200
Message-ID: <1411036862-13255-6-git-send-email-mkl@pengutronix.de>
References: <1411036862-13255-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, David Jander <david@protonic.nl>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1411036862-13255-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Jander <david@protonic.nl>

This patch implements the workaround mentioned in ERR005829:

    ERR005829: FlexCAN: FlexCAN does not transmit a message that is enabled to
    be transmitted in a specific moment during the arbitration process.

Workaround: The workaround consists of two extra steps after setting up a
message for transmission:

Step 8: Reserve the first valid mailbox as an inactive mailbox (CODE=0b1000).
If RX FIFO is disabled, this mailbox must be message buffer 0. Otherwise, the
first valid mailbox can be found using the "RX FIFO filters" table in the
FlexCAN chapter of the chip reference manual.

Step 9: Write twice INACTIVE code (0b1000) into the first valid mailbox.

Signed-off-by: David Jander <david@protonic.nl>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index fc076952..54061c4 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -125,7 +125,9 @@
 	 FLEXCAN_ESR_BOFF_INT | FLEXCAN_ESR_ERR_INT)
 
 /* FLEXCAN interrupt flag register (IFLAG) bits */
-#define FLEXCAN_TX_BUF_ID		8
+/* Errata ERR005829 step7: Reserve first valid MB */
+#define FLEXCAN_TX_BUF_RESERVED		8
+#define FLEXCAN_TX_BUF_ID		9
 #define FLEXCAN_IFLAG_BUF(x)		BIT(x)
 #define FLEXCAN_IFLAG_RX_FIFO_OVERFLOW	BIT(7)
 #define FLEXCAN_IFLAG_RX_FIFO_WARN	BIT(6)
@@ -439,6 +441,14 @@ static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	flexcan_write(can_id, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_id);
 	flexcan_write(ctrl, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
 
+	/* Errata ERR005829 step8:
+	 * Write twice INACTIVE(0x8) code to first MB.
+	 */
+	flexcan_write(FLEXCAN_MB_CODE_TX_INACTIVE,
+		      &regs->cantxfg[FLEXCAN_TX_BUF_RESERVED].can_ctrl);
+	flexcan_write(FLEXCAN_MB_CODE_TX_INACTIVE,
+		      &regs->cantxfg[FLEXCAN_TX_BUF_RESERVED].can_ctrl);
+
 	return NETDEV_TX_OK;
 }
 
@@ -885,6 +895,10 @@ static int flexcan_chip_start(struct net_device *dev)
 			      &regs->cantxfg[i].can_ctrl);
 	}
 
+	/* Errata ERR005829: mark first TX mailbox as INACTIVE */
+	flexcan_write(FLEXCAN_MB_CODE_TX_INACTIVE,
+		      &regs->cantxfg[FLEXCAN_TX_BUF_RESERVED].can_ctrl);
+
 	/* mark TX mailbox as INACTIVE */
 	flexcan_write(FLEXCAN_MB_CODE_TX_INACTIVE,
 		      &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
-- 
2.1.0

