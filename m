From: Quentin Schulz <quentin.schulz@free-electrons.com>
Subject: [PATCH v4 3/4] can: m_can: factorize clock gating and ungating
Date: Fri,  5 May 2017 15:50:32 +0200
Message-ID: <20170505135033.8349-3-quentin.schulz@free-electrons.com>
References: <20170505135033.8349-1-quentin.schulz@free-electrons.com>
Cc: Quentin Schulz <quentin.schulz@free-electrons.com>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
        thomas.petazzoni@free-electrons.com
To: wg@grandegger.com, mkl@pengutronix.de, mario.huettel@gmx.net,
        socketcan@hartkopp.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170505135033.8349-1-quentin.schulz@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This creates a function to ungate M_CAN clocks and another to gate the
same clocks, then swaps all gating/ungating code with their respective
function.

Signed-off-by: Quentin Schulz <quentin.schulz@free-electrons.com>
---

added in v4

 drivers/net/can/m_can/m_can.c | 45 +++++++++++++++++++++++++------------------
 1 file changed, 26 insertions(+), 19 deletions(-)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index 6115dede671e..653b304d7091 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -621,10 +621,8 @@ static int __m_can_get_berr_counter(const struct net_device *dev,
 	return 0;
 }
 
-static int m_can_get_berr_counter(const struct net_device *dev,
-				  struct can_berr_counter *bec)
+static int m_can_clk_start(struct m_can_priv *priv)
 {
-	struct m_can_priv *priv = netdev_priv(dev);
 	int err;
 
 	err = clk_prepare_enable(priv->hclk);
@@ -632,15 +630,31 @@ static int m_can_get_berr_counter(const struct net_device *dev,
 		return err;
 
 	err = clk_prepare_enable(priv->cclk);
-	if (err) {
+	if (err)
 		clk_disable_unprepare(priv->hclk);
-		return err;
-	}
 
-	__m_can_get_berr_counter(dev, bec);
+	return err;
+}
 
+static void m_can_clk_stop(struct m_can_priv *priv)
+{
 	clk_disable_unprepare(priv->cclk);
 	clk_disable_unprepare(priv->hclk);
+}
+
+static int m_can_get_berr_counter(const struct net_device *dev,
+				  struct can_berr_counter *bec)
+{
+	struct m_can_priv *priv = netdev_priv(dev);
+	int err;
+
+	err = m_can_clk_start(priv);
+	if (err)
+		return err;
+
+	__m_can_get_berr_counter(dev, bec);
+
+	m_can_clk_stop(priv);
 
 	return 0;
 }
@@ -1276,19 +1290,15 @@ static int m_can_open(struct net_device *dev)
 	struct m_can_priv *priv = netdev_priv(dev);
 	int err;
 
-	err = clk_prepare_enable(priv->hclk);
+	err = m_can_clk_start(priv);
 	if (err)
 		return err;
 
-	err = clk_prepare_enable(priv->cclk);
-	if (err)
-		goto exit_disable_hclk;
-
 	/* open the can device */
 	err = open_candev(dev);
 	if (err) {
 		netdev_err(dev, "failed to open can device\n");
-		goto exit_disable_cclk;
+		goto exit_disable_clks;
 	}
 
 	/* register interrupt handler */
@@ -1310,10 +1320,8 @@ static int m_can_open(struct net_device *dev)
 
 exit_irq_fail:
 	close_candev(dev);
-exit_disable_cclk:
-	clk_disable_unprepare(priv->cclk);
-exit_disable_hclk:
-	clk_disable_unprepare(priv->hclk);
+exit_disable_clks:
+	m_can_clk_stop(priv);
 	return err;
 }
 
@@ -1335,8 +1343,7 @@ static int m_can_close(struct net_device *dev)
 	netif_stop_queue(dev);
 	napi_disable(&priv->napi);
 	m_can_stop(dev);
-	clk_disable_unprepare(priv->hclk);
-	clk_disable_unprepare(priv->cclk);
+	m_can_clk_stop(priv);
 	free_irq(dev->irq, dev);
 	close_candev(dev);
 	can_led_event(dev, CAN_LED_EVENT_STOP);
-- 
2.11.0
