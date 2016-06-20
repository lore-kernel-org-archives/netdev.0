From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/3] can: c_can: Update D_CAN TX and RX functions to 32 bit - fix Altera Cyclone access
Date: Mon, 20 Jun 2016 10:00:28 +0200
Message-ID: <1466409630-6268-2-git-send-email-mkl@pengutronix.de>
References: <1466409630-6268-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Thor Thayer <tthayer@opensource.altera.com>,
	stable@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1466409630-6268-1-git-send-email-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thor Thayer <tthayer@opensource.altera.com>

When testing CAN write floods on Altera's CycloneV, the first 2 bytes
are sometimes 0x00, 0x00 or corrupted instead of the values sent. Also
observed bytes 4 & 5 were corrupted in some cases.

The D_CAN Data registers are 32 bits and changing from 16 bit writes to
32 bit writes fixes the problem.

Testing performed on Altera CycloneV (D_CAN).  Requesting tests on other
C_CAN & D_CAN platforms.

Reported-by: Richard Andrysek <richard.andrysek@gomtec.de>
Signed-off-by: Thor Thayer <tthayer@opensource.altera.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 38 +++++++++++++++++++++++++++++++-------
 1 file changed, 31 insertions(+), 7 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index f91b094288da..e3dccd3200d5 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -332,9 +332,23 @@ static void c_can_setup_tx_object(struct net_device *dev, int iface,
 
 	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface), ctrl);
 
-	for (i = 0; i < frame->can_dlc; i += 2) {
-		priv->write_reg(priv, C_CAN_IFACE(DATA1_REG, iface) + i / 2,
-				frame->data[i] | (frame->data[i + 1] << 8));
+	if (priv->type == BOSCH_D_CAN) {
+		u32 data = 0, dreg = C_CAN_IFACE(DATA1_REG, iface);
+
+		for (i = 0; i < frame->can_dlc; i += 4, dreg += 2) {
+			data = (u32)frame->data[i];
+			data |= (u32)frame->data[i + 1] << 8;
+			data |= (u32)frame->data[i + 2] << 16;
+			data |= (u32)frame->data[i + 3] << 24;
+			priv->write_reg32(priv, dreg, data);
+		}
+	} else {
+		for (i = 0; i < frame->can_dlc; i += 2) {
+			priv->write_reg(priv,
+					C_CAN_IFACE(DATA1_REG, iface) + i / 2,
+					frame->data[i] |
+					(frame->data[i + 1] << 8));
+		}
 	}
 }
 
@@ -402,10 +416,20 @@ static int c_can_read_msg_object(struct net_device *dev, int iface, u32 ctrl)
 	} else {
 		int i, dreg = C_CAN_IFACE(DATA1_REG, iface);
 
-		for (i = 0; i < frame->can_dlc; i += 2, dreg ++) {
-			data = priv->read_reg(priv, dreg);
-			frame->data[i] = data;
-			frame->data[i + 1] = data >> 8;
+		if (priv->type == BOSCH_D_CAN) {
+			for (i = 0; i < frame->can_dlc; i += 4, dreg += 2) {
+				data = priv->read_reg32(priv, dreg);
+				frame->data[i] = data;
+				frame->data[i + 1] = data >> 8;
+				frame->data[i + 2] = data >> 16;
+				frame->data[i + 3] = data >> 24;
+			}
+		} else {
+			for (i = 0; i < frame->can_dlc; i += 2, dreg++) {
+				data = priv->read_reg(priv, dreg);
+				frame->data[i] = data;
+				frame->data[i + 1] = data >> 8;
+			}
 		}
 	}
 
-- 
2.8.1
