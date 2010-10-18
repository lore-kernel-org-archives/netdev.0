From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 5/8] can: mcp251x: write intf only when needed
Date: Mon, 18 Oct 2010 15:31:11 +0200
Message-ID: <1287408674-15412-6-git-send-email-mkl@pengutronix.de>
References: <1287408674-15412-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: socketcan-core@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33908 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755444Ab0JRNbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 09:31:21 -0400
In-Reply-To: <1287408674-15412-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces a variable "clear_intf" that hold the bits that
should be cleared. Only read-modify-write register if "clear_intf"
is set.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/mcp251x.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 7e2f951..f5e2edd 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -125,6 +125,8 @@
 #  define CANINTF_TX0IF 0x04
 #  define CANINTF_RX1IF 0x02
 #  define CANINTF_RX0IF 0x01
+#  define CANINTF_ERR_TX \
+	(CANINTF_ERRIF | CANINTF_TX2IF | CANINTF_TX1IF | CANINTF_TX0IF)
 #define EFLG	      0x2d
 #  define EFLG_EWARN	0x01
 #  define EFLG_RXWAR	0x02
@@ -769,10 +771,12 @@ static irqreturn_t mcp251x_can_ist(int irq, void *dev_id)
 	while (!priv->force_quit) {
 		enum can_state new_state;
 		u8 intf, eflag;
+		u8 clear_intf = 0;
 		int can_id = 0, data1 = 0;
 
 		mcp251x_read_2regs(spi, CANINTF, &intf, &eflag);
 
+		/* receive buffer 0 */
 		if (intf & CANINTF_RX0IF) {
 			mcp251x_hw_rx(spi, 0);
 			/* Free one buffer ASAP */
@@ -780,10 +784,17 @@ static irqreturn_t mcp251x_can_ist(int irq, void *dev_id)
 					   0x00);
 		}
 
-		if (intf & CANINTF_RX1IF)
+		/* receive buffer 1 */
+		if (intf & CANINTF_RX1IF) {
 			mcp251x_hw_rx(spi, 1);
+			clear_intf |= CANINTF_RX1IF;
+		}
 
-		mcp251x_write_bits(spi, CANINTF, intf, 0x00);
+		/* any error or tx interrupt we need to clear? */
+		if (intf & CANINTF_ERR_TX)
+			clear_intf |= intf & CANINTF_ERR_TX;
+		if (clear_intf)
+			mcp251x_write_bits(spi, CANINTF, clear_intf, 0x00);
 
 		if (eflag)
 			mcp251x_write_bits(spi, EFLG, eflag, 0x00);
-- 
1.7.0.4

