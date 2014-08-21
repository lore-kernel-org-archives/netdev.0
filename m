From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 4/4] can: flexcan: handle state passive -> warning transition
Date: Thu, 21 Aug 2014 11:23:22 +0200
Message-ID: <1408613002-29693-5-git-send-email-mkl@pengutronix.de>
References: <1408613002-29693-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Matthias Klein <matthias.klein@optimeas.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1408613002-29693-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Once the CAN-bus is open and a packet is sent, the controller switches
into the PASSIVE state. Once the BUS is closed again it goes the back
err-warning. The TX error counter goes 0 -> 0x80 -> 0x7f.
This patch makes sure that the user learns about this state chang
(CAN_STATE_ERROR_WARNING => CAN_STATE_ERROR_PASSIVE)

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Signed-off-by: Matthias Klein <matthias.klein@optimeas.de>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index a691651..944aa5d 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -549,6 +549,13 @@ static void do_state(struct net_device *dev,
 
 	/* process state changes depending on the new state */
 	switch (new_state) {
+	case CAN_STATE_ERROR_WARNING:
+		netdev_dbg(dev, "Error Warning\n");
+		cf->can_id |= CAN_ERR_CRTL;
+		cf->data[1] = (bec.txerr > bec.rxerr) ?
+			CAN_ERR_CRTL_TX_WARNING :
+			CAN_ERR_CRTL_RX_WARNING;
+		break;
 	case CAN_STATE_ERROR_ACTIVE:
 		netdev_dbg(dev, "Error Active\n");
 		cf->can_id |= CAN_ERR_PROT;
-- 
2.1.0.rc1

