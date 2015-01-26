From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH v6 4/7] can: kvaser_usb: Fix state handling upon BUS_ERROR
 events
Date: Mon, 26 Jan 2015 07:25:43 +0200
Message-ID: <20150126052543.GE3014@Darwish.PC>
References: <20141223154654.GB6460@vivalin-002>
 <20150126051755.GA3014@Darwish.PC>
 <20150126052039.GB3014@Darwish.PC>
 <20150126052254.GC3014@Darwish.PC>
 <20150126052406.GD3014@Darwish.PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Andri Yngvason <andri.yngvason@marel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150126052406.GD3014@Darwish.PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ahmed S. Darwish <ahmed.darwish@valeo.com>

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
---
 drivers/net/can/usb/kvaser_usb.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 55407b9..7af379c 100644
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
1.7.7.6
