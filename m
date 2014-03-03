From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 5/8] can: flexcan: fix transition from and to freeze mode in chip_{,un}freeze
Date: Mon,  3 Mar 2014 14:54:32 +0100
Message-ID: <1393854875-8171-6-git-send-email-mkl@pengutronix.de>
References: <1393854875-8171-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-stable <stable@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:43425 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754522AbaCCNys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 08:54:48 -0500
In-Reply-To: <1393854875-8171-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch factors out freeze and unfreeze of the CAN core into seperate
functions. Experiments have shown that the transition from and to freeze mode
may take several microseconds, especially the time entering the freeze mode
depends on the current bitrate.

This patch adds a while loop which polls the Freeze Mode ACK bit (FRZ_ACK) that
indicates a successfull mode change. If the function runs into a timeout a
error value is returned.

Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 60 ++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 49 insertions(+), 11 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 6b0fecd..330b5b9 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -325,6 +325,44 @@ static int flexcan_chip_disable(struct flexcan_priv *priv)
 	return 0;
 }
 
+static int flexcan_chip_freeze(struct flexcan_priv *priv)
+{
+	struct flexcan_regs __iomem *regs = priv->base;
+	unsigned int timeout = 1000 * 1000 * 10 / priv->can.bittiming.bitrate;
+	u32 reg;
+
+	reg = flexcan_read(&regs->mcr);
+	reg |= FLEXCAN_MCR_HALT;
+	flexcan_write(reg, &regs->mcr);
+
+	while (timeout-- && !(flexcan_read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK))
+		usleep_range(100, 200);
+
+	if (!(flexcan_read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK))
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int flexcan_chip_unfreeze(struct flexcan_priv *priv)
+{
+	struct flexcan_regs __iomem *regs = priv->base;
+	unsigned int timeout = FLEXCAN_TIMEOUT_US / 10;
+	u32 reg;
+
+	reg = flexcan_read(&regs->mcr);
+	reg &= ~FLEXCAN_MCR_HALT;
+	flexcan_write(reg, &regs->mcr);
+
+	while (timeout-- && (flexcan_read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK))
+		usleep_range(10, 20);
+
+	if (flexcan_read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
 static int flexcan_get_berr_counter(const struct net_device *dev,
 				    struct can_berr_counter *bec)
 {
@@ -756,7 +794,7 @@ static int flexcan_chip_start(struct net_device *dev)
 		netdev_err(dev, "Failed to softreset can module (mcr=0x%08x)\n",
 			   reg_mcr);
 		err = -ENODEV;
-		goto out;
+		goto out_chip_disable;
 	}
 
 	flexcan_set_bittiming(dev);
@@ -826,12 +864,12 @@ static int flexcan_chip_start(struct net_device *dev)
 
 	err = flexcan_transceiver_enable(priv);
 	if (err)
-		goto out;
+		goto out_chip_disable;
 
 	/* synchronize with the can bus */
-	reg_mcr = flexcan_read(&regs->mcr);
-	reg_mcr &= ~FLEXCAN_MCR_HALT;
-	flexcan_write(reg_mcr, &regs->mcr);
+	err = flexcan_chip_unfreeze(priv);
+	if (err)
+		goto out_transceiver_disable;
 
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
 
@@ -844,7 +882,9 @@ static int flexcan_chip_start(struct net_device *dev)
 
 	return 0;
 
- out:
+ out_transceiver_disable:
+	flexcan_transceiver_disable(priv);
+ out_chip_disable:
 	flexcan_chip_disable(priv);
 	return err;
 }
@@ -859,12 +899,10 @@ static void flexcan_chip_stop(struct net_device *dev)
 {
 	struct flexcan_priv *priv = netdev_priv(dev);
 	struct flexcan_regs __iomem *regs = priv->base;
-	u32 reg;
 
-	/* Disable + halt module */
-	reg = flexcan_read(&regs->mcr);
-	reg |= FLEXCAN_MCR_MDIS | FLEXCAN_MCR_HALT;
-	flexcan_write(reg, &regs->mcr);
+	/* freeze + disable module */
+	flexcan_chip_freeze(priv);
+	flexcan_chip_disable(priv);
 
 	/* Disable all interrupts */
 	flexcan_write(0, &regs->imask1);
-- 
1.9.0
