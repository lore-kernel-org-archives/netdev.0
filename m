From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/4] can: sja1000: Validate initialization state in start method
Date: Thu, 21 Aug 2014 11:23:19 +0200
Message-ID: <1408613002-29693-2-git-send-email-mkl@pengutronix.de>
References: <1408613002-29693-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Mirza Krak <mirza.krak@hostmobility.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1408613002-29693-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mirza Krak <mirza.krak@hostmobility.com>

When sja1000 is not compiled as module the SJA1000 chip is only
initialized during device registration on kernel boot. Should the chip
get a hardware reset there is no way to reinitialize it without re-
booting the Linux kernel.

This patch adds a check in sja1000_start if the chip is initialized, if
not we initialize it.

Signed-off-by: Mirza Krak <mirza.krak@hostmobility.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sja1000/sja1000.c | 62 +++++++++++++++++++++------------------
 1 file changed, 33 insertions(+), 29 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index d169215..b27ac60 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -172,6 +172,35 @@ static void set_normal_mode(struct net_device *dev)
 	netdev_err(dev, "setting SJA1000 into normal mode failed!\n");
 }
 
+/*
+ * initialize SJA1000 chip:
+ *   - reset chip
+ *   - set output mode
+ *   - set baudrate
+ *   - enable interrupts
+ *   - start operating mode
+ */
+static void chipset_init(struct net_device *dev)
+{
+	struct sja1000_priv *priv = netdev_priv(dev);
+
+	/* set clock divider and output control register */
+	priv->write_reg(priv, SJA1000_CDR, priv->cdr | CDR_PELICAN);
+
+	/* set acceptance filter (accept all) */
+	priv->write_reg(priv, SJA1000_ACCC0, 0x00);
+	priv->write_reg(priv, SJA1000_ACCC1, 0x00);
+	priv->write_reg(priv, SJA1000_ACCC2, 0x00);
+	priv->write_reg(priv, SJA1000_ACCC3, 0x00);
+
+	priv->write_reg(priv, SJA1000_ACCM0, 0xFF);
+	priv->write_reg(priv, SJA1000_ACCM1, 0xFF);
+	priv->write_reg(priv, SJA1000_ACCM2, 0xFF);
+	priv->write_reg(priv, SJA1000_ACCM3, 0xFF);
+
+	priv->write_reg(priv, SJA1000_OCR, priv->ocr | OCR_MODE_NORMAL);
+}
+
 static void sja1000_start(struct net_device *dev)
 {
 	struct sja1000_priv *priv = netdev_priv(dev);
@@ -180,6 +209,10 @@ static void sja1000_start(struct net_device *dev)
 	if (priv->can.state != CAN_STATE_STOPPED)
 		set_reset_mode(dev);
 
+	/* Initialize chip if uninitialized at this stage */
+	if (!(priv->read_reg(priv, SJA1000_CDR) & CDR_PELICAN))
+		chipset_init(dev);
+
 	/* Clear error counters and error code capture */
 	priv->write_reg(priv, SJA1000_TXERR, 0x0);
 	priv->write_reg(priv, SJA1000_RXERR, 0x0);
@@ -237,35 +270,6 @@ static int sja1000_get_berr_counter(const struct net_device *dev,
 }
 
 /*
- * initialize SJA1000 chip:
- *   - reset chip
- *   - set output mode
- *   - set baudrate
- *   - enable interrupts
- *   - start operating mode
- */
-static void chipset_init(struct net_device *dev)
-{
-	struct sja1000_priv *priv = netdev_priv(dev);
-
-	/* set clock divider and output control register */
-	priv->write_reg(priv, SJA1000_CDR, priv->cdr | CDR_PELICAN);
-
-	/* set acceptance filter (accept all) */
-	priv->write_reg(priv, SJA1000_ACCC0, 0x00);
-	priv->write_reg(priv, SJA1000_ACCC1, 0x00);
-	priv->write_reg(priv, SJA1000_ACCC2, 0x00);
-	priv->write_reg(priv, SJA1000_ACCC3, 0x00);
-
-	priv->write_reg(priv, SJA1000_ACCM0, 0xFF);
-	priv->write_reg(priv, SJA1000_ACCM1, 0xFF);
-	priv->write_reg(priv, SJA1000_ACCM2, 0xFF);
-	priv->write_reg(priv, SJA1000_ACCM3, 0xFF);
-
-	priv->write_reg(priv, SJA1000_OCR, priv->ocr | OCR_MODE_NORMAL);
-}
-
-/*
  * transmit a CAN message
  * message layout in the sk_buff should be like this:
  * xx xx xx xx	 ff	 ll   00 11 22 33 44 55 66 77
-- 
2.1.0.rc1

