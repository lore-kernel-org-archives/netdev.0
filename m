From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] rcar_can: support all input clocks
Date: Wed, 30 Jul 2014 01:45:34 +0400
Message-ID: <201407300145.34797.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: netdev@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When writing the driver, I didn't give enough attention to the possible sources
of the CAN clock: although the value of the CLKR register was specified by  the
platform data, the driver only handled one case, that is CAN clock being sourced
from the clkp1 clock, the same that clocks the whole CAN module. In order to fix
that overlook, we'll have to handle the CAN clock separately from the peripheral
clock (however, clkp1 will be specified for a CAN device only once)...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the 'linux-can-next.git' repo, however it's a fix, not a
cleanup.

 drivers/net/can/rcar_can.c |   39 ++++++++++++++++++++++++++++++++++-----
 1 file changed, 34 insertions(+), 5 deletions(-)

Index: linux-can-next/drivers/net/can/rcar_can.c
===================================================================
--- linux-can-next.orig/drivers/net/can/rcar_can.c
+++ linux-can-next/drivers/net/can/rcar_can.c
@@ -87,6 +87,7 @@ struct rcar_can_priv {
 	struct napi_struct napi;
 	struct rcar_can_regs __iomem *regs;
 	struct clk *clk;
+	struct clk *can_clk;
 	u8 tx_dlc[RCAR_CAN_FIFO_DEPTH];
 	u32 tx_head;
 	u32 tx_tail;
@@ -505,14 +506,20 @@ static int rcar_can_open(struct net_devi
 
 	err = clk_prepare_enable(priv->clk);
 	if (err) {
-		netdev_err(ndev, "clk_prepare_enable() failed, error %d\n",
+		netdev_err(ndev, "failed to enable periperal clock, error %d\n",
 			   err);
 		goto out;
 	}
+	err = clk_prepare_enable(priv->can_clk);
+	if (err) {
+		netdev_err(ndev, "failed to enable CAN clock, error %d\n",
+			   err);
+		goto out_clock;
+	}
 	err = open_candev(ndev);
 	if (err) {
 		netdev_err(ndev, "open_candev() failed, error %d\n", err);
-		goto out_clock;
+		goto out_can_clock;
 	}
 	napi_enable(&priv->napi);
 	err = request_irq(ndev->irq, rcar_can_interrupt, 0, ndev->name, ndev);
@@ -527,6 +534,8 @@ static int rcar_can_open(struct net_devi
 out_close:
 	napi_disable(&priv->napi);
 	close_candev(ndev);
+out_can_clock:
+	clk_disable_unprepare(priv->can_clk);
 out_clock:
 	clk_disable_unprepare(priv->clk);
 out:
@@ -565,6 +574,7 @@ static int rcar_can_close(struct net_dev
 	rcar_can_stop(ndev);
 	free_irq(ndev->irq, ndev);
 	napi_disable(&priv->napi);
+	clk_disable_unprepare(priv->can_clk);
 	clk_disable_unprepare(priv->clk);
 	close_candev(ndev);
 	can_led_event(ndev, CAN_LED_EVENT_STOP);
@@ -715,6 +725,12 @@ static int rcar_can_get_berr_counter(con
 	return 0;
 }
 
+static const char * const clock_names[] = {
+	[CLKR_CLKP1]	= "clkp1",
+	[CLKR_CLKP2]	= "clkp2",
+	[CLKR_CLKEXT]	= "can_clk",
+};
+
 static int rcar_can_probe(struct platform_device *pdev)
 {
 	struct rcar_can_platform_data *pdata;
@@ -753,10 +769,23 @@ static int rcar_can_probe(struct platfor
 
 	priv = netdev_priv(ndev);
 
-	priv->clk = devm_clk_get(&pdev->dev, NULL);
+	priv->clk = devm_clk_get(&pdev->dev, "clkp1");
 	if (IS_ERR(priv->clk)) {
 		err = PTR_ERR(priv->clk);
-		dev_err(&pdev->dev, "cannot get clock: %d\n", err);
+		dev_err(&pdev->dev, "cannot get peripheral clock: %d\n", err);
+		goto fail_clk;
+	}
+
+	if (pdata->clock_select > CLKR_CLKEXT) {
+		err = -EINVAL;
+		dev_err(&pdev->dev, "invalid CAN clock selected\n");
+		goto fail_clk;
+	}
+	priv->can_clk = devm_clk_get(&pdev->dev,
+				     clock_names[pdata->clock_select]);
+	if (IS_ERR(priv->can_clk)) {
+		err = PTR_ERR(priv->can_clk);
+		dev_err(&pdev->dev, "cannot get CAN clock: %d\n", err);
 		goto fail_clk;
 	}
 
@@ -766,7 +795,7 @@ static int rcar_can_probe(struct platfor
 	priv->ndev = ndev;
 	priv->regs = addr;
 	priv->clock_select = pdata->clock_select;
-	priv->can.clock.freq = clk_get_rate(priv->clk);
+	priv->can.clock.freq = clk_get_rate(priv->can_clk);
 	priv->can.bittiming_const = &rcar_can_bittiming_const;
 	priv->can.do_set_mode = rcar_can_do_set_mode;
 	priv->can.do_get_berr_counter = rcar_can_get_berr_counter;
