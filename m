From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 06/10] can: at91_can: implement and use at91_get_berr_counter
Date: Thu, 21 Oct 2010 13:01:18 +0200
Message-ID: <1287658882-26914-7-git-send-email-mkl@pengutronix.de>
References: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: socketcan-core@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34924 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757054Ab0JULB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:01:27 -0400
In-Reply-To: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/at91_can.c |   25 ++++++++++++++++++-------
 1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 6187813..4fa0aa0 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -275,6 +275,18 @@ static int at91_set_bittiming(struct net_device *dev)
 	return 0;
 }
 
+static int at91_get_berr_counter(const struct net_device *dev,
+		struct can_berr_counter *bec)
+{
+	const struct at91_priv *priv = netdev_priv(dev);
+	u32 reg_ecr = at91_read(priv, AT91_ECR);
+
+	bec->rxerr = reg_ecr & 0xff;
+	bec->txerr = reg_ecr >> 16;
+
+	return 0;
+}
+
 static void at91_chip_start(struct net_device *dev)
 {
 	struct at91_priv *priv = netdev_priv(dev);
@@ -764,12 +776,10 @@ static void at91_irq_err_state(struct net_device *dev,
 		struct can_frame *cf, enum can_state new_state)
 {
 	struct at91_priv *priv = netdev_priv(dev);
-	u32 reg_idr = 0, reg_ier = 0, reg_ecr;
-	u8 tec, rec;
+	u32 reg_idr = 0, reg_ier = 0;
+	struct can_berr_counter bec;
 
-	reg_ecr = at91_read(priv, AT91_ECR);
-	rec = reg_ecr & 0xff;
-	tec = reg_ecr >> 16;
+	at91_get_berr_counter(dev, &bec);
 
 	switch (priv->can.state) {
 	case CAN_STATE_ERROR_ACTIVE:
@@ -784,7 +794,7 @@ static void at91_irq_err_state(struct net_device *dev,
 			priv->can.can_stats.error_warning++;
 
 			cf->can_id |= CAN_ERR_CRTL;
-			cf->data[1] = (tec > rec) ?
+			cf->data[1] = (bec.txerr > bec.rxerr) ?
 				CAN_ERR_CRTL_TX_WARNING :
 				CAN_ERR_CRTL_RX_WARNING;
 		}
@@ -800,7 +810,7 @@ static void at91_irq_err_state(struct net_device *dev,
 			priv->can.can_stats.error_passive++;
 
 			cf->can_id |= CAN_ERR_CRTL;
-			cf->data[1] = (tec > rec) ?
+			cf->data[1] = (bec.txerr > bec.rxerr) ?
 				CAN_ERR_CRTL_TX_PASSIVE :
 				CAN_ERR_CRTL_RX_PASSIVE;
 		}
@@ -1078,6 +1088,7 @@ static int __devinit at91_can_probe(struct platform_device *pdev)
 	priv->can.bittiming_const = &at91_bittiming_const;
 	priv->can.do_set_bittiming = at91_set_bittiming;
 	priv->can.do_set_mode = at91_set_mode;
+	priv->can.do_get_berr_counter = at91_get_berr_counter;
 	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
 	priv->reg_base = addr;
 	priv->dev = dev;
-- 
1.7.0.4

