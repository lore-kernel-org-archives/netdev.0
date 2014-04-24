From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 17/26] can: c_can: Cleanup c_can_msg_obj_put/get()
Date: Fri, 25 Apr 2014 00:00:20 +0200
Message-ID: <1398376829-6771-18-git-send-email-mkl@pengutronix.de>
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

Sigh!

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Alexander Stein <alexander.stein@systec-electronic.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 60 ++++++++++++-------------------------------
 1 file changed, 16 insertions(+), 44 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index bf3aed4..c654efb 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -261,61 +261,33 @@ static void c_can_irq_control(struct c_can_priv *priv, bool enable)
 	priv->write_reg(priv, C_CAN_CTRL_REG, ctrl);
 }
 
-static inline int c_can_msg_obj_is_busy(struct c_can_priv *priv, int iface)
+static void c_can_obj_update(struct net_device *dev, int iface, u32 cmd, u32 obj)
 {
-	int count = MIN_TIMEOUT_VALUE;
+	struct c_can_priv *priv = netdev_priv(dev);
+	int cnt, reg = C_CAN_IFACE(COMREQ_REG, iface);
+
+	priv->write_reg(priv, reg + 1, cmd);
+	priv->write_reg(priv, reg, obj);
 
-	while (count && priv->read_reg(priv,
-				C_CAN_IFACE(COMREQ_REG, iface)) &
-				IF_COMR_BUSY) {
-		count--;
+	for (cnt = MIN_TIMEOUT_VALUE; cnt; cnt--) {
+		if (!(priv->read_reg(priv, reg) & IF_COMR_BUSY))
+			return;
 		udelay(1);
 	}
+	netdev_err(dev, "Updating object timed out\n");
 
-	if (!count)
-		return 1;
-
-	return 0;
 }
 
-static inline void c_can_object_get(struct net_device *dev,
-					int iface, int objno, int mask)
+static inline void c_can_object_get(struct net_device *dev, int iface,
+				    u32 obj, u32 cmd)
 {
-	struct c_can_priv *priv = netdev_priv(dev);
-
-	/*
-	 * As per specs, after writting the message object number in the
-	 * IF command request register the transfer b/w interface
-	 * register and message RAM must be complete in 6 CAN-CLK
-	 * period.
-	 */
-	priv->write_reg(priv, C_CAN_IFACE(COMMSK_REG, iface),
-			IFX_WRITE_LOW_16BIT(mask));
-	priv->write_reg(priv, C_CAN_IFACE(COMREQ_REG, iface),
-			IFX_WRITE_LOW_16BIT(objno));
-
-	if (c_can_msg_obj_is_busy(priv, iface))
-		netdev_err(dev, "timed out in object get\n");
+	c_can_obj_update(dev, iface, cmd, obj);
 }
 
-static inline void c_can_object_put(struct net_device *dev,
-					int iface, int objno, int mask)
+static inline void c_can_object_put(struct net_device *dev, int iface,
+				    u32 obj, u32 cmd)
 {
-	struct c_can_priv *priv = netdev_priv(dev);
-
-	/*
-	 * As per specs, after writting the message object number in the
-	 * IF command request register the transfer b/w interface
-	 * register and message RAM must be complete in 6 CAN-CLK
-	 * period.
-	 */
-	priv->write_reg(priv, C_CAN_IFACE(COMMSK_REG, iface),
-			(IF_COMM_WR | IFX_WRITE_LOW_16BIT(mask)));
-	priv->write_reg(priv, C_CAN_IFACE(COMREQ_REG, iface),
-			IFX_WRITE_LOW_16BIT(objno));
-
-	if (c_can_msg_obj_is_busy(priv, iface))
-		netdev_err(dev, "timed out in object put\n");
+	c_can_obj_update(dev, iface, cmd | IF_COMM_WR, obj);
 }
 
 static void c_can_write_msg_object(struct net_device *dev,
-- 
1.9.0.279.gdc9e3eb

