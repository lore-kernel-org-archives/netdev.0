From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/8] can: flexcan: fix transition from and to low power mode in chip_{en,dis}able
Date: Mon,  3 Mar 2014 14:54:30 +0100
Message-ID: <1393854875-8171-4-git-send-email-mkl@pengutronix.de>
References: <1393854875-8171-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-stable <stable@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1393854875-8171-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In flexcan_chip_enable() and flexcan_chip_disable() fixed delays are used.
Experiments have shown that the transition from and to low power mode may take
several microseconds.

This patch adds a while loop which polls the Low Power Mode ACK bit (LPM_ACK)
that indicates a successfull mode change. If the function runs into a timeout a
error value is returned.

Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 50 +++++++++++++++++++++++++++++++++++------------
 1 file changed, 38 insertions(+), 12 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 30af702..5af60ab 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -144,6 +144,8 @@
 
 #define FLEXCAN_MB_CODE_MASK		(0xf0ffffff)
 
+#define FLEXCAN_TIMEOUT_US             (50)
+
 /*
  * FLEXCAN hardware feature flags
  *
@@ -269,26 +271,42 @@ static inline int flexcan_has_and_handle_berr(const struct flexcan_priv *priv,
 		(reg_esr & FLEXCAN_ESR_ERR_BUS);
 }
 
-static inline void flexcan_chip_enable(struct flexcan_priv *priv)
+static int flexcan_chip_enable(struct flexcan_priv *priv)
 {
 	struct flexcan_regs __iomem *regs = priv->base;
+	unsigned int timeout = FLEXCAN_TIMEOUT_US / 10;
 	u32 reg;
 
 	reg = flexcan_read(&regs->mcr);
 	reg &= ~FLEXCAN_MCR_MDIS;
 	flexcan_write(reg, &regs->mcr);
 
-	udelay(10);
+	while (timeout-- && (flexcan_read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK))
+		usleep_range(10, 20);
+
+	if (flexcan_read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK)
+		return -ETIMEDOUT;
+
+	return 0;
 }
 
-static inline void flexcan_chip_disable(struct flexcan_priv *priv)
+static int flexcan_chip_disable(struct flexcan_priv *priv)
 {
 	struct flexcan_regs __iomem *regs = priv->base;
+	unsigned int timeout = FLEXCAN_TIMEOUT_US / 10;
 	u32 reg;
 
 	reg = flexcan_read(&regs->mcr);
 	reg |= FLEXCAN_MCR_MDIS;
 	flexcan_write(reg, &regs->mcr);
+
+	while (timeout-- && !(flexcan_read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK))
+		usleep_range(10, 20);
+
+	if (!(flexcan_read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK))
+		return -ETIMEDOUT;
+
+	return 0;
 }
 
 static int flexcan_get_berr_counter(const struct net_device *dev,
@@ -709,7 +727,9 @@ static int flexcan_chip_start(struct net_device *dev)
 	u32 reg_mcr, reg_ctrl;
 
 	/* enable module */
-	flexcan_chip_enable(priv);
+	err = flexcan_chip_enable(priv);
+	if (err)
+		return err;
 
 	/* soft reset */
 	flexcan_write(FLEXCAN_MCR_SOFTRST, &regs->mcr);
@@ -949,12 +969,16 @@ static int register_flexcandev(struct net_device *dev)
 		goto out_disable_ipg;
 
 	/* select "bus clock", chip must be disabled */
-	flexcan_chip_disable(priv);
+	err = flexcan_chip_disable(priv);
+	if (err)
+		goto out_disable_per;
 	reg = flexcan_read(&regs->ctrl);
 	reg |= FLEXCAN_CTRL_CLK_SRC;
 	flexcan_write(reg, &regs->ctrl);
 
-	flexcan_chip_enable(priv);
+	err = flexcan_chip_enable(priv);
+	if (err)
+		goto out_chip_disable;
 
 	/* set freeze, halt and activate FIFO, restrict register access */
 	reg = flexcan_read(&regs->mcr);
@@ -971,14 +995,15 @@ static int register_flexcandev(struct net_device *dev)
 	if (!(reg & FLEXCAN_MCR_FEN)) {
 		netdev_err(dev, "Could not enable RX FIFO, unsupported core\n");
 		err = -ENODEV;
-		goto out_disable_per;
+		goto out_chip_disable;
 	}
 
 	err = register_candev(dev);
 
- out_disable_per:
 	/* disable core and turn off clocks */
+ out_chip_disable:
 	flexcan_chip_disable(priv);
+ out_disable_per:
 	clk_disable_unprepare(priv->clk_per);
  out_disable_ipg:
 	clk_disable_unprepare(priv->clk_ipg);
@@ -1121,8 +1146,11 @@ static int flexcan_suspend(struct device *device)
 {
 	struct net_device *dev = dev_get_drvdata(device);
 	struct flexcan_priv *priv = netdev_priv(dev);
+	int err;
 
-	flexcan_chip_disable(priv);
+	err = flexcan_chip_disable(priv);
+	if (err)
+		return err;
 
 	if (netif_running(dev)) {
 		netif_stop_queue(dev);
@@ -1143,9 +1171,7 @@ static int flexcan_resume(struct device *device)
 		netif_device_attach(dev);
 		netif_start_queue(dev);
 	}
-	flexcan_chip_enable(priv);
-
-	return 0;
+	return flexcan_chip_enable(priv);
 }
 #endif /* CONFIG_PM_SLEEP */
 
-- 
1.9.0

