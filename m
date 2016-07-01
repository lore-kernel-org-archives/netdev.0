From: Sergio Valverde <sergio.valverde@hpe.com>
Subject: [PATCH] Fix race condition in enc28j60 driver
Date: Fri,  1 Jul 2016 11:44:30 -0600
Message-ID: <1467395070-8632-1-git-send-email-sergio.valverde@hpe.com>
Cc: dompe@hpe.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sergio Valverde <sergio.valverde@hpe.com>
To: davem@davemloft.net, mhei@heimpold.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergio Valverde <sergio.valverde@hpe.com>

The interrupt worker code for the enc28j60 relies only on the TXIF flag to
determinate if the packet transmission was completed. However the datasheet
specifies in section 12.1.3 that TXERIF will clear the TXRTS after a
transmit abort. Also in section 12.1.4 that TXIF will be set
when TXRTS transitions from '1' to '0'. Therefore the TXIF flag is enabled
during transmission errors.

This causes a race condition, since the worker code will invoke
enc28j60_tx_clear() -> netif_wake_queue(), potentially invoking the
ndo_start_xmit function to send a new packet. The enc28j60_send_packet function
uses a workqueue that invokes enc28j60_hw_tx(). In between this function is
called, the worker from the interrupt handler will enter the path for error
handler because of the TXERIF flag, causing to invoke enc28j60_tx_clear() again
and releasing the packet scheduled for transmission, causing a kernel crash with
due a NULL pointer.

These crashes due a NULL pointer were observed under stress conditions of the
device. A BUG_ON() sequence was used to validate the issue was fixed, and has
been running without problems for 2 years now.

Signed-off-by: Diego Dompe <dompe@hpe.com>
Acked-by: Sergio Valverde <sergio.valverde@hpe.com>
---
 drivers/net/ethernet/microchip/enc28j60.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
index 7066954..0a26b11 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -1151,7 +1151,8 @@ static void enc28j60_irq_work_handler(struct work_struct *work)
 			enc28j60_phy_read(priv, PHIR);
 		}
 		/* TX complete handler */
-		if ((intflags & EIR_TXIF) != 0) {
+		if (((intflags & EIR_TXIF) != 0) &&
+		    ((intflags & EIR_TXERIF) == 0)) {
 			bool err = false;
 			loop++;
 			if (netif_msg_intr(priv))
@@ -1203,7 +1204,7 @@ static void enc28j60_irq_work_handler(struct work_struct *work)
 					enc28j60_tx_clear(ndev, true);
 			} else
 				enc28j60_tx_clear(ndev, true);
-			locked_reg_bfclr(priv, EIR, EIR_TXERIF);
+			locked_reg_bfclr(priv, EIR, EIR_TXERIF | EIR_TXIF);
 		}
 		/* RX Error handler */
 		if ((intflags & EIR_RXERIF) != 0) {
@@ -1238,6 +1239,8 @@ static void enc28j60_irq_work_handler(struct work_struct *work)
  */
 static void enc28j60_hw_tx(struct enc28j60_net *priv)
 {
+	BUG_ON(!priv->tx_skb);
+
 	if (netif_msg_tx_queued(priv))
 		printk(KERN_DEBUG DRV_NAME
 			": Tx Packet Len:%d\n", priv->tx_skb->len);
--
1.9.1
