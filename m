From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/2] can: mcp251x: fix endless loop in interrupt handler if CANINTF_MERRF is set
Date: Wed, 20 Oct 2010 12:02:25 +0200
Message-ID: <1287568946-32727-2-git-send-email-mkl@pengutronix.de>
References: <1287568946-32727-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: socketcan-core@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:40772 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab0JTKCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 06:02:37 -0400
In-Reply-To: <1287568946-32727-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d3cd15657516141adce387810be8cb377baf020e introduced a bug, the
interrupt handler would loop endlessly if the CANINTF_MERRF bit is set,
because it's not cleared.

This patch fixes the problem by masking out the CANINTF_MERRF and all other
non interesting bits.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/mcp251x.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index c664be2..59f40bc 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -125,8 +125,9 @@
 #  define CANINTF_TX0IF 0x04
 #  define CANINTF_RX1IF 0x02
 #  define CANINTF_RX0IF 0x01
-#  define CANINTF_ERR_TX \
-	(CANINTF_ERRIF | CANINTF_TX2IF | CANINTF_TX1IF | CANINTF_TX0IF)
+#  define CANINTF_RX (CANINTF_RX0IF | CANINTF_RX1IF)
+#  define CANINTF_TX (CANINTF_TX2IF | CANINTF_TX1IF | CANINTF_TX0IF)
+#  define CANINTF_ERR (CANINTF_ERRIF)
 #define EFLG	      0x2d
 #  define EFLG_EWARN	0x01
 #  define EFLG_RXWAR	0x02
@@ -790,6 +791,9 @@ static irqreturn_t mcp251x_can_ist(int irq, void *dev_id)
 
 		mcp251x_read_2regs(spi, CANINTF, &intf, &eflag);
 
+		/* mask out flags we don't care about */
+		intf &= CANINTF_RX | CANINTF_TX | CANINTF_ERR;
+
 		/* receive buffer 0 */
 		if (intf & CANINTF_RX0IF) {
 			mcp251x_hw_rx(spi, 0);
@@ -810,8 +814,8 @@ static irqreturn_t mcp251x_can_ist(int irq, void *dev_id)
 		}
 
 		/* any error or tx interrupt we need to clear? */
-		if (intf & CANINTF_ERR_TX)
-			clear_intf |= intf & CANINTF_ERR_TX;
+		if (intf & (CANINTF_ERR | CANINTF_TX))
+			clear_intf |= intf & (CANINTF_ERR | CANINTF_TX);
 		if (clear_intf)
 			mcp251x_write_bits(spi, CANINTF, clear_intf, 0x00);
 
@@ -887,7 +891,7 @@ static irqreturn_t mcp251x_can_ist(int irq, void *dev_id)
 		if (intf == 0)
 			break;
 
-		if (intf & (CANINTF_TX2IF | CANINTF_TX1IF | CANINTF_TX0IF)) {
+		if (intf & CANINTF_TX) {
 			net->stats.tx_packets++;
 			net->stats.tx_bytes += priv->tx_len - 1;
 			if (priv->tx_len) {
-- 
1.7.0.4

