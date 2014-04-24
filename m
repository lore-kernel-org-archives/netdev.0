From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 09/26] can: c_can: Avoid status register update for D_CAN
Date: Fri, 25 Apr 2014 00:00:12 +0200
Message-ID: <1398376829-6771-10-git-send-email-mkl@pengutronix.de>
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

On D_CAN the RXOK, TXOK and LEC bits are cleared/set on read of the
status register. No need to update them.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Alexander Stein <alexander.stein@systec-electronic.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 2aae073..b381f7b 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -1041,7 +1041,8 @@ static int c_can_handle_bus_err(struct net_device *dev,
 	}
 
 	/* set a `lec` value so that we can check for updates later */
-	priv->write_reg(priv, C_CAN_STS_REG, LEC_UNUSED);
+	if (priv->type != BOSCH_D_CAN)
+		priv->write_reg(priv, C_CAN_STS_REG, LEC_UNUSED);
 
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
@@ -1066,11 +1067,13 @@ static int c_can_poll(struct napi_struct *napi, int quota)
 					C_CAN_STS_REG);
 
 		/* handle Tx/Rx events */
-		if (priv->current_status & STATUS_TXOK)
+		if (priv->current_status & STATUS_TXOK &&
+		    priv->type != BOSCH_D_CAN)
 			priv->write_reg(priv, C_CAN_STS_REG,
 					priv->current_status & ~STATUS_TXOK);
 
-		if (priv->current_status & STATUS_RXOK)
+		if (priv->current_status & STATUS_RXOK &&
+		    priv->type != BOSCH_D_CAN)
 			priv->write_reg(priv, C_CAN_STS_REG,
 					priv->current_status & ~STATUS_RXOK);
 
-- 
1.9.0.279.gdc9e3eb

