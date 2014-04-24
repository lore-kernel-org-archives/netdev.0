From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 03/26] can: c_can: Make bus off interrupt disable logic work
Date: Fri, 25 Apr 2014 00:00:06 +0200
Message-ID: <1398376829-6771-4-git-send-email-mkl@pengutronix.de>
References: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Thomas Gleixner <tglx@linutronix.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>

The state change handler is called with device interrupts disabled
already. So no point in disabling them again when we enter bus off
state.

But what's worse is that we reenable the interrupts at the end of NAPI
poll unconditionally. So c_can_start() which is called from the
restart timer can trigger interrupts which confuse the hell out of the
half reinitialized driver/hw.

Remove the pointless device interrupt disable in the BUS_OFF handler
and prevent reenabling the device interrupts at the end of the poll
routine when the current state is BUS_OFF.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Alexander Stein <alexander.stein@systec-electronic.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index b1629a4..8c725f4 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -954,11 +954,6 @@ static int c_can_handle_state_change(struct net_device *dev,
 		/* bus-off state */
 		priv->can.state = CAN_STATE_BUS_OFF;
 		cf->can_id |= CAN_ERR_BUSOFF;
-		/*
-		 * disable all interrupts in bus-off mode to ensure that
-		 * the CPU is not hogged down
-		 */
-		c_can_enable_all_interrupts(priv, DISABLE_ALL_INTERRUPTS);
 		can_bus_off(dev);
 		break;
 	default:
@@ -1089,6 +1084,7 @@ static int c_can_poll(struct napi_struct *napi, int quota)
 			netdev_dbg(dev, "entered bus off state\n");
 			work_done += c_can_handle_state_change(dev,
 						C_CAN_BUS_OFF);
+			goto end;
 		}
 
 		/* handle bus recovery events */
@@ -1122,8 +1118,9 @@ static int c_can_poll(struct napi_struct *napi, int quota)
 end:
 	if (work_done < quota) {
 		napi_complete(napi);
-		/* enable all IRQs */
-		c_can_enable_all_interrupts(priv, ENABLE_ALL_INTERRUPTS);
+		/* enable all IRQs if we are not in bus off state */
+		if (priv->can.state != CAN_STATE_BUS_OFF)
+			c_can_enable_all_interrupts(priv, ENABLE_ALL_INTERRUPTS);
 	}
 
 	return work_done;
-- 
1.9.0.279.gdc9e3eb

