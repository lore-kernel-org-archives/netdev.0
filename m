From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 12/26] can: c_can: Work around C_CAN RX wreckage
Date: Fri, 25 Apr 2014 00:00:15 +0200
Message-ID: <1398376829-6771-13-git-send-email-mkl@pengutronix.de>
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

Alexander reported that the new optimized handling of the RX fifo
causes random packet loss on Intel PCH C_CAN hardware.

After a few fruitless debugging sessions I got hold of a PCH (eg20t)
afflicted system. That machine does not have the CAN interface wired
up, but it was possible to reproduce the issue with the HW loopback
mode.

As Alexander observed correctly, clearing the NewDat flag along with
reading out the message buffer causes that issue on C_CAN, while D_CAN
handles that correctly.

Instead of restoring the original message buffer handling horror the
following workaround solves the issue:

    transfer buffer to IF without clearing the NewDat
    handle the message
    clear NewDat bit

That's similar to the original code but conditional for C_CAN.

I really wonder why all user manuals (C_CAN, Intel PCH and some more)
recommend to clear the NewDat bit right away. The knows it all Oracle
operated by Gurgle does not unearth any useful information either. I
simply cannot believe that we are the first to uncover that HW issue.

Reported-and-tested-by: Alexander Stein <alexander.stein@systec-electronic.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 13 ++++++++++---
 drivers/net/can/c_can/c_can.h |  1 +
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index c1a8684..5d43c5a 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -647,6 +647,10 @@ static int c_can_start(struct net_device *dev)
 	if (err)
 		return err;
 
+	/* Setup the command for new messages */
+	priv->comm_rcv_high = priv->type != BOSCH_D_CAN ?
+		IF_COMM_RCV_LOW : IF_COMM_RCV_HIGH;
+
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
 
 	/* reset tx helper pointers and the rx mask */
@@ -791,14 +795,15 @@ static u32 c_can_adjust_pending(u32 pend)
 	return pend & ~((1 << lasts) - 1);
 }
 
-static inline void c_can_rx_object_get(struct net_device *dev, u32 obj)
+static inline void c_can_rx_object_get(struct net_device *dev,
+				       struct c_can_priv *priv, u32 obj)
 {
 #ifdef CONFIG_CAN_C_CAN_STRICT_FRAME_ORDERING
 	if (obj < C_CAN_MSG_RX_LOW_LAST)
 		c_can_object_get(dev, IF_RX, obj, IF_COMM_RCV_LOW);
 	else
 #endif
-		c_can_object_get(dev, IF_RX, obj, IF_COMM_RCV_HIGH);
+		c_can_object_get(dev, IF_RX, obj, priv->comm_rcv_high);
 }
 
 static inline void c_can_rx_finalize(struct net_device *dev,
@@ -813,6 +818,8 @@ static inline void c_can_rx_finalize(struct net_device *dev,
 		c_can_activate_all_lower_rx_msg_obj(dev, IF_RX);
 	}
 #endif
+	if (priv->type != BOSCH_D_CAN)
+		c_can_object_get(dev, IF_RX, obj, IF_COMM_CLR_NEWDAT);
 }
 
 static int c_can_read_objects(struct net_device *dev, struct c_can_priv *priv,
@@ -823,7 +830,7 @@ static int c_can_read_objects(struct net_device *dev, struct c_can_priv *priv,
 	while ((obj = ffs(pend)) && quota > 0) {
 		pend &= ~BIT(obj - 1);
 
-		c_can_rx_object_get(dev, obj);
+		c_can_rx_object_get(dev, priv, obj);
 		ctrl = priv->read_reg(priv, C_CAN_IFACE(MSGCTRL_REG, IF_RX));
 
 		if (ctrl & IF_MCONT_MSGLST) {
diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index cd91960..792944c 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -198,6 +198,7 @@ struct c_can_priv {
 	u32 __iomem *raminit_ctrlreg;
 	unsigned int instance;
 	void (*raminit) (const struct c_can_priv *priv, bool enable);
+	u32 comm_rcv_high;
 	u32 rxmasked;
 	u32 dlc[C_CAN_MSG_OBJ_TX_NUM];
 };
-- 
1.9.0.279.gdc9e3eb

