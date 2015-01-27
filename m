From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 4/4] can: kvaser_usb: Fix state handling upon BUS_ERROR events
Date: Tue, 27 Jan 2015 09:01:27 +0100
Message-ID: <1422345687-12839-5-git-send-email-mkl@pengutronix.de>
References: <1422345687-12839-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	"Ahmed S. Darwish" <ahmed.darwish@valeo.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1422345687-12839-1-git-send-email-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ahmed S. Darwish" <ahmed.darwish@valeo.com>

While being in an ERROR_WARNING state, and receiving further
bus error events with error counters still in the ERROR_WARNING
range of 97-127 inclusive, the state handling code erroneously
reverts back to ERROR_ACTIVE.

Per the CAN standard, only revert to ERROR_ACTIVE when the
error counters are less than 96.

Moreover, in certain Kvaser models, the BUS_ERROR flag is
always set along with undefined bits in the M16C status
register. Thus use bitwise operators instead of full equality
for checking that register against bus errors.

Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/kvaser_usb.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 55407b9663a6..7af379ca861b 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -698,9 +698,7 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
 		}
 
 		new_state = CAN_STATE_ERROR_PASSIVE;
-	}
-
-	if (status == M16C_STATE_BUS_ERROR) {
+	} else if (status & M16C_STATE_BUS_ERROR) {
 		if ((priv->can.state < CAN_STATE_ERROR_WARNING) &&
 		    ((txerr >= 96) || (rxerr >= 96))) {
 			cf->can_id |= CAN_ERR_CRTL;
@@ -710,7 +708,8 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
 
 			priv->can.can_stats.error_warning++;
 			new_state = CAN_STATE_ERROR_WARNING;
-		} else if (priv->can.state > CAN_STATE_ERROR_ACTIVE) {
+		} else if ((priv->can.state > CAN_STATE_ERROR_ACTIVE) &&
+			   ((txerr < 96) && (rxerr < 96))) {
 			cf->can_id |= CAN_ERR_PROT;
 			cf->data[2] = CAN_ERR_PROT_ACTIVE;
 
-- 
2.1.4
