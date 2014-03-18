From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 01/12] can: c_can: Wait for CONTROL_INIT to be cleared
Date: Tue, 18 Mar 2014 17:19:08 -0000
Message-ID: <20140318171126.593414691@linutronix.de>
References: <20140318171007.528610837@linutronix.de>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=cac-c_can-wait-for-control-init.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to the documentation the CPU must wait for CONTROL_INIT to
be cleared before writing to the baudrate registers.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 drivers/net/can/c_can/c_can.c |   26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)

Index: linux/drivers/net/can/c_can/c_can.c
===================================================================
--- linux.orig/drivers/net/can/c_can/c_can.c
+++ linux/drivers/net/can/c_can/c_can.c
@@ -566,6 +566,21 @@ static netdev_tx_t c_can_start_xmit(stru
 	return NETDEV_TX_OK;
 }
 
+static int c_can_wait_for_ctrl_init(struct net_device *dev,
+				    struct c_can_priv *priv, u32 init)
+{
+	int retry = 0;
+
+	while (init != (priv->read_reg(priv, C_CAN_CTRL_REG) & CONTROL_INIT)) {
+		udelay(10);
+		if (retry++ > 1000) {
+			netdev_err(dev, "CCTRL: set CONTROL_INIT failed\n");
+			return -EIO;
+		}
+	}
+	return 0;
+}
+
 static int c_can_set_bittiming(struct net_device *dev)
 {
 	unsigned int reg_btr, reg_brpe, ctrl_save;
@@ -573,6 +588,7 @@ static int c_can_set_bittiming(struct ne
 	u32 ten_bit_brp;
 	struct c_can_priv *priv = netdev_priv(dev);
 	const struct can_bittiming *bt = &priv->can.bittiming;
+	int res;
 
 	/* c_can provides a 6-bit brp and 4-bit brpe fields */
 	ten_bit_brp = bt->brp - 1;
@@ -590,13 +606,17 @@ static int c_can_set_bittiming(struct ne
 		"setting BTR=%04x BRPE=%04x\n", reg_btr, reg_brpe);
 
 	ctrl_save = priv->read_reg(priv, C_CAN_CTRL_REG);
-	priv->write_reg(priv, C_CAN_CTRL_REG,
-			ctrl_save | CONTROL_CCE | CONTROL_INIT);
+	ctrl_save &= ~CONTROL_INIT;
+	priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_CCE | CONTROL_INIT);
+	res = c_can_wait_for_ctrl_init(dev, priv, CONTROL_INIT);
+	if (res)
+		return res;
+
 	priv->write_reg(priv, C_CAN_BTR_REG, reg_btr);
 	priv->write_reg(priv, C_CAN_BRPEXT_REG, reg_brpe);
 	priv->write_reg(priv, C_CAN_CTRL_REG, ctrl_save);
 
-	return 0;
+	return c_can_wait_for_ctrl_init(dev, priv, 0);
 }
 
 /*
