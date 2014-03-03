From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 7/8] can: flexcan: factor out soft reset into seperate funtion
Date: Mon,  3 Mar 2014 14:54:34 +0100
Message-ID: <1393854875-8171-8-git-send-email-mkl@pengutronix.de>
References: <1393854875-8171-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1393854875-8171-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch moves the soft reset into a seperate function.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index dff4fa4..61376ab 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -363,6 +363,21 @@ static int flexcan_chip_unfreeze(struct flexcan_priv *priv)
 	return 0;
 }
 
+static int flexcan_chip_softreset(struct flexcan_priv *priv)
+{
+	struct flexcan_regs __iomem *regs = priv->base;
+	unsigned int timeout = FLEXCAN_TIMEOUT_US / 10;
+
+	flexcan_write(FLEXCAN_MCR_SOFTRST, &regs->mcr);
+	while (timeout-- && (flexcan_read(&regs->mcr) & FLEXCAN_MCR_SOFTRST))
+		usleep_range(10, 20);
+
+	if (flexcan_read(&regs->mcr) & FLEXCAN_MCR_SOFTRST)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
 static int flexcan_get_berr_counter(const struct net_device *dev,
 				    struct can_berr_counter *bec)
 {
@@ -786,16 +801,9 @@ static int flexcan_chip_start(struct net_device *dev)
 		return err;
 
 	/* soft reset */
-	flexcan_write(FLEXCAN_MCR_SOFTRST, &regs->mcr);
-	udelay(10);
-
-	reg_mcr = flexcan_read(&regs->mcr);
-	if (reg_mcr & FLEXCAN_MCR_SOFTRST) {
-		netdev_err(dev, "Failed to softreset can module (mcr=0x%08x)\n",
-			   reg_mcr);
-		err = -ENODEV;
+	err = flexcan_chip_softreset(priv);
+	if (err)
 		goto out_chip_disable;
-	}
 
 	flexcan_set_bittiming(dev);
 
-- 
1.9.0

