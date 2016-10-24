From: Manfred Schlaegl <manfred.schlaegl@ginzinger.com>
Subject: [PATCH] net: fec: hard phy reset on open
Date: Mon, 24 Oct 2016 11:25:40 +0200
Message-ID: <7c3c37c0-7c24-a63c-b441-b1e8085a3c96@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Fugang Duan <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:57828 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934500AbcJXJZq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 05:25:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have seen some problems with auto negotiation on i.MX6 using LAN8720,
after interface down/up.

In our configuration, the ptp clock is used externally as reference
clock for the phy. Some phys (e.g. LAN8720) needs a stable clock while
and after hard reset.
Before this patch, the driver disabled the clock on close but did no
hard reset on open, after enabling the clocks again.

A solution that prevents disabling the clocks on close was considered,
but discarded because of bad power saving behavior.

This patch saves the reset dt properties on probe and does a reset on
every open after clocks where enabled, to make sure the clock is stable
while and after hard reset.

Tested on i.MX6 and i.MX28, both using LAN8720.

Signed-off-by: Manfred Schlaegl <manfred.schlaegl@ginzinger.com>
---
 drivers/net/ethernet/freescale/fec.h      |  4 ++
 drivers/net/ethernet/freescale/fec_main.c | 77 +++++++++++++++++--------------
 2 files changed, 47 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index c865135..379e619 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -498,6 +498,10 @@ struct fec_enet_private {
 	struct clk *clk_enet_out;
 	struct clk *clk_ptp;
 
+	int phy_reset;
+	bool phy_reset_active_high;
+	int phy_reset_msec;
+
 	bool ptp_clk_on;
 	struct mutex ptp_clk_mutex;
 	unsigned int num_tx_queues;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 48a033e..8cc1ec5 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2802,6 +2802,22 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 	return 0;
 }
 
+static void fec_reset_phy(struct fec_enet_private *fep)
+{
+	if (!gpio_is_valid(fep->phy_reset))
+		return;
+
+	gpio_set_value_cansleep(fep->phy_reset, !!fep->phy_reset_active_high);
+
+	if (fep->phy_reset_msec > 20)
+		msleep(fep->phy_reset_msec);
+	else
+		usleep_range(fep->phy_reset_msec * 1000,
+			     fep->phy_reset_msec * 1000 + 1000);
+
+	gpio_set_value_cansleep(fep->phy_reset, !fep->phy_reset_active_high);
+}
+
 static int
 fec_enet_open(struct net_device *ndev)
 {
@@ -2817,6 +2833,8 @@ fec_enet_open(struct net_device *ndev)
 	if (ret)
 		goto clk_enable;
 
+	fec_reset_phy(fep);
+
 	/* I should reset the ring buffers here, but I don't yet know
 	 * a simple way to do that.
 	 */
@@ -3183,52 +3201,39 @@ static int fec_enet_init(struct net_device *ndev)
 	return 0;
 }
 
-#ifdef CONFIG_OF
-static void fec_reset_phy(struct platform_device *pdev)
+static int
+fec_get_reset_phy(struct platform_device *pdev, int *msec, int *phy_reset,
+		  bool *active_high)
 {
-	int err, phy_reset;
-	bool active_high = false;
-	int msec = 1;
+	int err;
 	struct device_node *np = pdev->dev.of_node;
 
-	if (!np)
-		return;
+	if (!np || !of_device_is_available(np))
+		return 0;
 
-	of_property_read_u32(np, "phy-reset-duration", &msec);
+	of_property_read_u32(np, "phy-reset-duration", msec);
 	/* A sane reset duration should not be longer than 1s */
-	if (msec > 1000)
-		msec = 1;
+	if (*msec > 1000)
+		*msec = 1;
 
-	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
-	if (!gpio_is_valid(phy_reset))
-		return;
+	*phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
+	if (!gpio_is_valid(*phy_reset))
+		return 0;
 
-	active_high = of_property_read_bool(np, "phy-reset-active-high");
+	*active_high = of_property_read_bool(np, "phy-reset-active-high");
 
-	err = devm_gpio_request_one(&pdev->dev, phy_reset,
-			active_high ? GPIOF_OUT_INIT_HIGH : GPIOF_OUT_INIT_LOW,
-			"phy-reset");
+	err = devm_gpio_request_one(&pdev->dev, *phy_reset,
+				    *active_high ?
+					GPIOF_OUT_INIT_HIGH :
+					GPIOF_OUT_INIT_LOW,
+				    "phy-reset");
 	if (err) {
 		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n", err);
-		return;
+		return err;
 	}
 
-	if (msec > 20)
-		msleep(msec);
-	else
-		usleep_range(msec * 1000, msec * 1000 + 1000);
-
-	gpio_set_value_cansleep(phy_reset, !active_high);
-}
-#else /* CONFIG_OF */
-static void fec_reset_phy(struct platform_device *pdev)
-{
-	/*
-	 * In case of platform probe, the reset has been done
-	 * by machine code.
-	 */
+	return 0;
 }
-#endif /* CONFIG_OF */
 
 static void
 fec_enet_get_queue_num(struct platform_device *pdev, int *num_tx, int *num_rx)
@@ -3409,7 +3414,10 @@ fec_probe(struct platform_device *pdev)
 	pm_runtime_set_active(&pdev->dev);
 	pm_runtime_enable(&pdev->dev);
 
-	fec_reset_phy(pdev);
+	ret = fec_get_reset_phy(pdev, &fep->phy_reset_msec, &fep->phy_reset,
+				&fep->phy_reset_active_high);
+	if (ret)
+		goto failed_reset;
 
 	if (fep->bufdesc_ex)
 		fec_ptp_init(pdev);
@@ -3467,6 +3475,7 @@ fec_probe(struct platform_device *pdev)
 failed_mii_init:
 failed_irq:
 failed_init:
+failed_reset:
 	fec_ptp_stop(pdev);
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
-- 
2.1.4
