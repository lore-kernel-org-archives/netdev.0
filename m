From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH v5 3/5] can: kvaser_usb: Fix state handling upon BUS_ERROR
 events
Date: Tue, 20 Jan 2015 16:47:09 -0500
Message-ID: <20150120214709.GC16828@linux>
References: <20141223154654.GB6460@vivalin-002>
 <20150120214409.GA16828@linux>
 <20150120214537.GB16828@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andri Yngvason <andri.yngvason@marel.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150120214537.GB16828@linux>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ahmed S. Darwish <ahmed.darwish@valeo.com>

While being in an ERROR_WARNING state and receiving further
bus error events with error counts in the range of 97-127 inclusive,
the state handling code erroneously reverts back to ERROR_ACTIVE.

As per the CAN standard recommendations, only revert to ERROR_ACTIVE
when the error counters are less than 96.

Moreover, in certain Kvaser models, the BUS_ERROR flag is always set
along with undefined bits in the M16C status register. Thus use
bitwise ops instead of full equality for checking the register
against bus errors.

Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
---
 drivers/net/can/usb/kvaser_usb.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 0386d3f..640b0eb 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -635,10 +635,12 @@ static void kvaser_usb_rx_error_update_can_state(struct kvaser_usb_net_priv *pri
 		new_state = CAN_STATE_BUS_OFF;
 	else if (es->status & M16C_STATE_BUS_PASSIVE)
 		new_state = CAN_STATE_ERROR_PASSIVE;
-
-	if (es->status == M16C_STATE_BUS_ERROR) {
-		if ((cur_state < CAN_STATE_ERROR_WARNING) &&
-		    ((es->txerr >= 96) || (es->rxerr >= 96)))
+	else if (es->status & M16C_STATE_BUS_ERROR) {
+		if ((es->txerr >= 256) || (es->rxerr >= 256))
+			new_state = CAN_STATE_BUS_OFF;
+		else if ((es->txerr >= 128) || (es->rxerr >= 128))
+			new_state = CAN_STATE_ERROR_PASSIVE;
+		else if ((es->txerr >= 96) || (es->rxerr >= 96))
 			new_state = CAN_STATE_ERROR_WARNING;
 		else if (cur_state > CAN_STATE_ERROR_ACTIVE)
 			new_state = CAN_STATE_ERROR_ACTIVE;
@@ -748,15 +750,11 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
 			if (!priv->can.restart_ms)
 				kvaser_usb_simple_msg_async(priv, CMD_STOP_CHIP);
 			netif_carrier_off(priv->netdev);
-		}
-
-		if (es.status == M16C_STATE_BUS_ERROR) {
-			if ((old_state >= CAN_STATE_ERROR_WARNING) ||
-			    (es.txerr < 96 && es.rxerr < 96)) {
-				if (old_state > CAN_STATE_ERROR_ACTIVE) {
-					cf->can_id |= CAN_ERR_PROT;
-					cf->data[2] = CAN_ERR_PROT_ACTIVE;
-				}
+		} else if (es.status & M16C_STATE_BUS_ERROR) {
+			if ((es.txerr < 96 && es.rxerr < 96) &&
+			    (old_state > CAN_STATE_ERROR_ACTIVE)) {
+				cf->can_id |= CAN_ERR_PROT;
+				cf->data[2] = CAN_ERR_PROT_ACTIVE;
 			}
 		}
 
-- 
1.9.1
