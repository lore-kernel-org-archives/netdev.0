From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 02/16] c_can: add generic D-CAN RAM initialization support
Date: Mon,  9 Sep 2013 09:24:59 +0200
Message-ID: <1378711513-2548-3-git-send-email-b.spranger@linutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:37919 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525Ab3IIHZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 03:25:31 -0400
In-Reply-To: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

D-CAN provides an automatic RAM initialization. The initialization can be
executed while D-CAN is in the init state.

It should be checked if this is compatible with TI's d_can implementation
which does not have or does not use this bit which is here according to the
d_can specification.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
---
 drivers/net/can/c_can/c_can.c | 38 ++++++++++++++++++++++++++++++++++++--
 drivers/net/can/c_can/c_can.h |  2 ++
 2 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index a668cd4..081620b 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -68,6 +68,8 @@
 #define TEST_SILENT		BIT(3)
 #define TEST_BASIC		BIT(2)
 
+#define FUNC_RAMINIT		BIT(3)
+
 /* status register */
 #define STATUS_PDA		BIT(10)
 #define STATUS_BOFF		BIT(7)
@@ -573,6 +575,7 @@ static int c_can_set_bittiming(struct net_device *dev)
 	u32 ten_bit_brp;
 	struct c_can_priv *priv = netdev_priv(dev);
 	const struct can_bittiming *bt = &priv->can.bittiming;
+	int retry;
 
 	/* c_can provides a 6-bit brp and 4-bit brpe fields */
 	ten_bit_brp = bt->brp - 1;
@@ -590,11 +593,42 @@ static int c_can_set_bittiming(struct net_device *dev)
 		"setting BTR=%04x BRPE=%04x\n", reg_btr, reg_brpe);
 
 	ctrl_save = priv->read_reg(priv, C_CAN_CTRL_REG);
-	priv->write_reg(priv, C_CAN_CTRL_REG,
-			ctrl_save | CONTROL_CCE | CONTROL_INIT);
+	ctrl_save &= ~CONTROL_INIT;
+
+	priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_CCE | CONTROL_INIT);
+	retry = 1000;
+	while (!(priv->read_reg(priv, C_CAN_CTRL_REG) & CONTROL_INIT)) {
+		if (!retry) {
+			netdev_info(dev, "CCTRL: set CONTROL_INIT failed\n");
+			return -EIO;
+		}
+		udelay(10);
+		retry--;
+	}
 	priv->write_reg(priv, C_CAN_BTR_REG, reg_btr);
 	priv->write_reg(priv, C_CAN_BRPEXT_REG, reg_brpe);
+
+	priv->write_reg(priv, C_CAN_FUNC_REG, FUNC_RAMINIT);
+	retry = 1000;
+	while (priv->read_reg(priv, C_CAN_FUNC_REG) & FUNC_RAMINIT) {
+		if (!retry) {
+			netdev_info(dev, "CFR: FUNC_RAMINIT failed\n");
+			return -EIO;
+		}
+		udelay(10);
+		retry--;
+	}
+
 	priv->write_reg(priv, C_CAN_CTRL_REG, ctrl_save);
+	retry = 1000;
+	while (priv->read_reg(priv, C_CAN_CTRL_REG) & CONTROL_INIT) {
+		if (!retry) {
+			netdev_info(dev, "CCTRL: clear CONTROL_INIT failed\n");
+			return -EIO;
+		}
+		udelay(10);
+		retry--;
+	}
 
 	return 0;
 }
diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index d2e2d20..9f0eda8 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -61,6 +61,7 @@ enum reg {
 	C_CAN_INTPND2_REG,
 	C_CAN_MSGVAL1_REG,
 	C_CAN_MSGVAL2_REG,
+	C_CAN_FUNC_REG,
 };
 
 static const u16 reg_map_c_can[] = {
@@ -112,6 +113,7 @@ static const u16 reg_map_d_can[] = {
 	[C_CAN_BRPEXT_REG]	= 0x0E,
 	[C_CAN_INT_REG]		= 0x10,
 	[C_CAN_TEST_REG]	= 0x14,
+	[C_CAN_FUNC_REG]	= 0x18,
 	[C_CAN_TXRQST1_REG]	= 0x88,
 	[C_CAN_TXRQST2_REG]	= 0x8A,
 	[C_CAN_NEWDAT1_REG]	= 0x9C,
-- 
1.8.4.rc3
