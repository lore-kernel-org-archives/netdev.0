From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 4/8] can: flexcan: factor out transceiver {en,dis}able into seperate functions
Date: Mon,  3 Mar 2014 14:54:31 +0100
Message-ID: <1393854875-8171-5-git-send-email-mkl@pengutronix.de>
References: <1393854875-8171-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-stable <stable@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1393854875-8171-1-git-send-email-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch moves the transceiver enable and disable into seperate functions,
where the NULL pointer check is hidden.

Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 27 ++++++++++++++++++++-------
 1 file changed, 20 insertions(+), 7 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 5af60ab..6b0fecd 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -264,6 +264,22 @@ static inline void flexcan_write(u32 val, void __iomem *addr)
 }
 #endif
 
+static inline int flexcan_transceiver_enable(const struct flexcan_priv *priv)
+{
+	if (!priv->reg_xceiver)
+		return 0;
+
+	return regulator_enable(priv->reg_xceiver);
+}
+
+static inline int flexcan_transceiver_disable(const struct flexcan_priv *priv)
+{
+	if (!priv->reg_xceiver)
+		return 0;
+
+	return regulator_disable(priv->reg_xceiver);
+}
+
 static inline int flexcan_has_and_handle_berr(const struct flexcan_priv *priv,
 					      u32 reg_esr)
 {
@@ -808,11 +824,9 @@ static int flexcan_chip_start(struct net_device *dev)
 	if (priv->devtype_data->features & FLEXCAN_HAS_V10_FEATURES)
 		flexcan_write(0x0, &regs->rxfgmask);
 
-	if (priv->reg_xceiver)	{
-		err = regulator_enable(priv->reg_xceiver);
-		if (err)
-			goto out;
-	}
+	err = flexcan_transceiver_enable(priv);
+	if (err)
+		goto out;
 
 	/* synchronize with the can bus */
 	reg_mcr = flexcan_read(&regs->mcr);
@@ -857,8 +871,7 @@ static void flexcan_chip_stop(struct net_device *dev)
 	flexcan_write(priv->reg_ctrl_default & ~FLEXCAN_CTRL_ERR_ALL,
 		      &regs->ctrl);
 
-	if (priv->reg_xceiver)
-		regulator_disable(priv->reg_xceiver);
+	flexcan_transceiver_disable(priv);
 	priv->can.state = CAN_STATE_STOPPED;
 
 	return;
-- 
1.9.0
