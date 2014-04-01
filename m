From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 05/16] can: c_can: Wait for CONTROL_INIT to be cleared
Date: Tue,  1 Apr 2014 23:42:19 +0200
Message-ID: <1396388550-23081-6-git-send-email-mkl@pengutronix.de>
References: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Thomas Gleixner <tglx@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>

According to the documentation the CPU must wait for CONTROL_INIT to
be cleared before writing to the baudrate registers.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 6883938..4d08a32 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -566,6 +566,21 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
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
@@ -573,6 +588,7 @@ static int c_can_set_bittiming(struct net_device *dev)
 	u32 ten_bit_brp;
 	struct c_can_priv *priv = netdev_priv(dev);
 	const struct can_bittiming *bt = &priv->can.bittiming;
+	int res;
 
 	/* c_can provides a 6-bit brp and 4-bit brpe fields */
 	ten_bit_brp = bt->brp - 1;
@@ -590,13 +606,17 @@ static int c_can_set_bittiming(struct net_device *dev)
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
-- 
1.9.0.279.gdc9e3eb

