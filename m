From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 15/26] can: c_can: Cleanup setup of receive buffers
Date: Fri, 25 Apr 2014 00:00:18 +0200
Message-ID: <1398376829-6771-16-git-send-email-mkl@pengutronix.de>
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

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Alexander Stein <alexander.stein@systec-electronic.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 38 +++++++++++++++++---------------------
 1 file changed, 17 insertions(+), 21 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index d0daef8..e4eaa84 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -125,6 +125,10 @@
 /* For the high buffers we clear the interrupt bit and newdat */
 #define IF_COMM_RCV_HIGH	(IF_COMM_RCV_LOW | IF_COMM_CLR_NEWDAT)
 
+
+/* Receive setup of message objects */
+#define IF_COMM_RCV_SETUP	(IF_COMM_MASK | IF_COMM_ARB | IF_COMM_CONTROL)
+
 /* IFx arbitration */
 #define IF_ARB_MSGVAL		BIT(15)
 #define IF_ARB_MSGXTD		BIT(14)
@@ -142,6 +146,9 @@
 #define IF_MCONT_EOB		BIT(7)
 #define IF_MCONT_DLC_MASK	0xf
 
+#define IF_MCONT_RCV		(IF_MCONT_RXIE | IF_MCONT_UMASK)
+#define IF_MCONT_RCV_EOB	(IF_MCONT_RCV | IF_MCONT_EOB)
+
 /*
  * Use IF1 for RX and IF2 for TX
  */
@@ -424,30 +431,20 @@ static int c_can_read_msg_object(struct net_device *dev, int iface, u32 ctrl)
 }
 
 static void c_can_setup_receive_object(struct net_device *dev, int iface,
-					int objno, unsigned int mask,
-					unsigned int id, unsigned int mcont)
+				       u32 obj, u32 mask, u32 id, u32 mcont)
 {
 	struct c_can_priv *priv = netdev_priv(dev);
 
-	priv->write_reg(priv, C_CAN_IFACE(MASK1_REG, iface),
-			IFX_WRITE_LOW_16BIT(mask));
-
-	/* According to C_CAN documentation, the reserved bit
-	 * in IFx_MASK2 register is fixed 1
-	 */
-	priv->write_reg(priv, C_CAN_IFACE(MASK2_REG, iface),
-			IFX_WRITE_HIGH_16BIT(mask) | BIT(13));
+	mask |= BIT(29);
+	priv->write_reg(priv, C_CAN_IFACE(MASK1_REG, iface), mask);
+	priv->write_reg(priv, C_CAN_IFACE(MASK2_REG, iface), mask >> 16);
 
-	priv->write_reg(priv, C_CAN_IFACE(ARB1_REG, iface),
-			IFX_WRITE_LOW_16BIT(id));
-	priv->write_reg(priv, C_CAN_IFACE(ARB2_REG, iface),
-			(IF_ARB_MSGVAL | IFX_WRITE_HIGH_16BIT(id)));
+	id |= IF_ARB_MSGVAL << 16;
+	priv->write_reg(priv, C_CAN_IFACE(ARB1_REG, iface), id);
+	priv->write_reg(priv, C_CAN_IFACE(ARB2_REG, iface), id >> 16);
 
 	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface), mcont);
-	c_can_object_put(dev, iface, objno, IF_COMM_ALL & ~IF_COMM_TXRQST);
-
-	netdev_dbg(dev, "obj no:%d, msgval:0x%08x\n", objno,
-			c_can_read_reg32(priv, C_CAN_MSGVAL1_REG));
+	c_can_object_put(dev, iface, obj, IF_COMM_RCV_SETUP);
 }
 
 static void c_can_inval_msg_object(struct net_device *dev, int iface, int objno)
@@ -581,11 +578,10 @@ static void c_can_configure_msg_objects(struct net_device *dev)
 
 	/* setup receive message objects */
 	for (i = C_CAN_MSG_OBJ_RX_FIRST; i < C_CAN_MSG_OBJ_RX_LAST; i++)
-		c_can_setup_receive_object(dev, IF_RX, i, 0, 0,
-					   IF_MCONT_RXIE | IF_MCONT_UMASK);
+		c_can_setup_receive_object(dev, IF_RX, i, 0, 0, IF_MCONT_RCV);
 
 	c_can_setup_receive_object(dev, IF_RX, C_CAN_MSG_OBJ_RX_LAST, 0, 0,
-			IF_MCONT_EOB | IF_MCONT_RXIE | IF_MCONT_UMASK);
+				   IF_MCONT_RCV_EOB);
 }
 
 /*
-- 
1.9.0.279.gdc9e3eb

