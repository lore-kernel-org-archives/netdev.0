From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 05/16] c_can: use 32 bit access for D_CAN
Date: Mon,  9 Sep 2013 09:25:02 +0200
Message-ID: <1378711513-2548-6-git-send-email-b.spranger@linutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:37928 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab3IIHZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 03:25:33 -0400
In-Reply-To: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Other than the C_CAN 16 bit memory interface the D_CAN uses a 32bit memory
interface. This causes some trouble while accessing the IFxCMR register in
two 16bit chunks. Use 32bit access on D_CAN.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
---
 drivers/net/can/c_can/c_can.c | 56 +++++++++++++++++++++++++++----------------
 1 file changed, 35 insertions(+), 21 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 886163f..b3cfb85 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -262,11 +262,32 @@ static inline int get_tx_echo_msg_obj(const struct c_can_priv *priv)
 
 static u32 c_can_read_reg32(struct c_can_priv *priv, enum reg index)
 {
-	u32 val = priv->read_reg(priv, index);
-	val |= ((u32) priv->read_reg(priv, index + 1)) << 16;
+	u32 val;
+
+	if (priv->type == BOSCH_D_CAN || priv->type == BOSCH_D_CAN_FLEXCARD) {
+		val = readl(priv->base + priv->regs[index]);
+	} else {
+		val = priv->read_reg(priv, index);
+		val |= ((u32) priv->read_reg(priv, index + 1)) << 16;
+	}
 	return val;
 }
 
+static void c_can_writereg32(struct c_can_priv *priv, enum reg index,
+		u16 high, u16 low)
+{
+	u32 val;
+
+	if (priv->type == BOSCH_D_CAN || priv->type == BOSCH_D_CAN_FLEXCARD) {
+		val = high << 16;
+		val |= low;
+		writel(val, priv->base + priv->regs[index]);
+	} else {
+		priv->write_reg(priv, index + 1, high);
+		priv->write_reg(priv, index, low);
+	}
+}
+
 static void c_can_enable_all_interrupts(struct c_can_priv *priv,
 						int enable)
 {
@@ -309,10 +330,8 @@ static inline void c_can_object_get(struct net_device *dev,
 	 * register and message RAM must be complete in 6 CAN-CLK
 	 * period.
 	 */
-	priv->write_reg(priv, C_CAN_IFACE(COMMSK_REG, iface),
-			IFX_WRITE_LOW_16BIT(mask));
-	priv->write_reg(priv, C_CAN_IFACE(COMREQ_REG, iface),
-			IFX_WRITE_LOW_16BIT(objno));
+	c_can_writereg32(priv, C_CAN_IFACE(COMREQ_REG, iface),
+			IFX_WRITE_LOW_16BIT(mask), IFX_WRITE_LOW_16BIT(objno));
 
 	if (c_can_msg_obj_is_busy(priv, iface))
 		netdev_err(dev, "timed out in object get\n");
@@ -329,9 +348,8 @@ static inline void c_can_object_put(struct net_device *dev,
 	 * register and message RAM must be complete in 6 CAN-CLK
 	 * period.
 	 */
-	priv->write_reg(priv, C_CAN_IFACE(COMMSK_REG, iface),
-			(IF_COMM_WR | IFX_WRITE_LOW_16BIT(mask)));
-	priv->write_reg(priv, C_CAN_IFACE(COMREQ_REG, iface),
+	c_can_writereg32(priv, C_CAN_IFACE(COMREQ_REG, iface),
+			IF_COMM_WR | IFX_WRITE_LOW_16BIT(mask),
 			IFX_WRITE_LOW_16BIT(objno));
 
 	if (c_can_msg_obj_is_busy(priv, iface))
@@ -496,23 +514,19 @@ static void c_can_setup_receive_object(struct net_device *dev, int iface,
 {
 	struct c_can_priv *priv = netdev_priv(dev);
 
-	priv->write_reg(priv, C_CAN_IFACE(MASK1_REG, iface),
-			IFX_WRITE_LOW_16BIT(mask));
-
 	/* According to C_CAN documentation, the reserved bit
 	 * in IFx_MASK2 register is fixed 1
 	 */
-	priv->write_reg(priv, C_CAN_IFACE(MASK2_REG, iface),
-			IFX_WRITE_HIGH_16BIT(mask) | BIT(13));
-
+	c_can_writereg32(priv, C_CAN_IFACE(MASK1_REG, iface),
+			IFX_WRITE_HIGH_16BIT(mask) | BIT(13),
+			IFX_WRITE_LOW_16BIT(mask));
 	id |= IF_ARB_MSGVAL;
-	priv->write_reg(priv, C_CAN_IFACE(ARB1_REG, iface),
-			IFX_WRITE_LOW_16BIT(id));
-	priv->write_reg(priv, C_CAN_IFACE(ARB2_REG, iface),
-			(IFX_WRITE_HIGH_16BIT(id)));
+	c_can_writereg32(priv, C_CAN_IFACE(ARB1_REG, iface),
+			IFX_WRITE_HIGH_16BIT(id), IFX_WRITE_LOW_16BIT(id));
+	c_can_writereg32(priv, C_CAN_IFACE(MSGCTRL_REG, iface), 0, mcont);
 
-	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface), mcont);
-	c_can_object_put(dev, iface, objno, IF_COMM_ALL & ~IF_COMM_TXRQST);
+	c_can_object_put(dev, iface, objno, IF_COMM_WR | IF_COMM_MASK |
+			 IF_COMM_ARB | IF_COMM_CONTROL | IF_COMM_CLR_INT_PND);
 
 	netdev_dbg(dev, "obj no:%d, msgval:0x%08x\n", objno,
 			c_can_read_reg32(priv, C_CAN_MSGVAL1_REG));
-- 
1.8.4.rc3
