From: Richard Leitner <richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/2] net: ethernet: freescale: simplify fec_reset_phy
Date: Thu, 6 Jul 2017 15:05:29 +0200
Message-ID: <1499346330-12166-1-git-send-email-richard.leitner@skidata.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <dev-M/VWbR8SM2SsTnJN9+BGXg@public.gmane.org>,
        Richard Leitner <richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
To: <fugang.duan-3arQi8VN3Tc@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The fec_reset_phy function allowed only one execution during probeing.
As a preparation for future patches move the dt parsing and gpio
allocation to the probe function. The parameters of the phy reset are
added to the fec_enet_private struct. As a result the fec_reset_phy
function may be called anytime after probe.

Signed-off-by: Richard Leitner <richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/ethernet/freescale/fec.h      |  4 ++
 drivers/net/ethernet/freescale/fec_main.c | 85 ++++++++++++++++---------------
 2 files changed, 47 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 5ea740b..3da8084 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -534,6 +534,10 @@ struct fec_enet_private {
 	int	pause_flag;
 	int	wol_flag;
 	u32	quirks;
+	int	phy_reset;
+	int	phy_reset_duration;
+	int	phy_reset_post_delay;
+	bool	phy_reset_active_high;
 
 	struct	napi_struct napi;
 	int	csum_flags;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index f7c8649..cbbf7b8 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3188,62 +3188,36 @@ static int fec_enet_init(struct net_device *ndev)
 }
 
 #ifdef CONFIG_OF
-static int fec_reset_phy(struct platform_device *pdev)
+static int fec_reset_phy(struct net_device *ndev)
 {
-	int err, phy_reset;
-	bool active_high = false;
-	int msec = 1, phy_post_delay = 0;
-	struct device_node *np = pdev->dev.of_node;
-
-	if (!np)
-		return 0;
-
-	err = of_property_read_u32(np, "phy-reset-duration", &msec);
-	/* A sane reset duration should not be longer than 1s */
-	if (!err && msec > 1000)
-		msec = 1;
+	struct fec_enet_private *fep = netdev_priv(ndev);
 
-	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
-	if (phy_reset == -EPROBE_DEFER)
-		return phy_reset;
-	else if (!gpio_is_valid(phy_reset))
+	if (!fep->phy_reset)
 		return 0;
 
-	err = of_property_read_u32(np, "phy-reset-post-delay", &phy_post_delay);
-	/* valid reset duration should be less than 1s */
-	if (!err && phy_post_delay > 1000)
-		return -EINVAL;
-
-	active_high = of_property_read_bool(np, "phy-reset-active-high");
+	gpio_set_value_cansleep(fep->phy_reset, fep->phy_reset_active_high);
 
-	err = devm_gpio_request_one(&pdev->dev, phy_reset,
-			active_high ? GPIOF_OUT_INIT_HIGH : GPIOF_OUT_INIT_LOW,
-			"phy-reset");
-	if (err) {
-		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n", err);
-		return err;
-	}
-
-	if (msec > 20)
-		msleep(msec);
+	if (fep->phy_reset_duration > 20)
+		msleep(fep->phy_reset_duration);
 	else
-		usleep_range(msec * 1000, msec * 1000 + 1000);
+		usleep_range(fep->phy_reset_duration * 1000,
+			     fep->phy_reset_duration * 1000 + 1000);
 
-	gpio_set_value_cansleep(phy_reset, !active_high);
+	gpio_set_value_cansleep(fep->phy_reset, !fep->phy_reset_active_high);
 
-	if (!phy_post_delay)
+	if (!fep->phy_reset_post_delay)
 		return 0;
 
-	if (phy_post_delay > 20)
-		msleep(phy_post_delay);
+	if (fep->phy_reset_post_delay > 20)
+		msleep(fep->phy_reset_post_delay);
 	else
-		usleep_range(phy_post_delay * 1000,
-			     phy_post_delay * 1000 + 1000);
+		usleep_range(fep->phy_reset_post_delay * 1000,
+			     fep->phy_reset_post_delay * 1000 + 1000);
 
 	return 0;
 }
 #else /* CONFIG_OF */
-static int fec_reset_phy(struct platform_device *pdev)
+static int fec_reset_phy(struct net_device *ndev)
 {
 	/*
 	 * In case of platform probe, the reset has been done
@@ -3361,6 +3335,33 @@ fec_probe(struct platform_device *pdev)
 	}
 	fep->phy_node = phy_node;
 
+	fep->phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
+	if (gpio_is_valid(fep->phy_reset)) {
+		ret = of_property_read_u32(np, "phy-reset-duration",
+					   &fep->phy_reset_duration);
+		/* A sane reset duration should not be longer than 1s */
+		if (!ret && fep->phy_reset_post_delay > 1000)
+			fep->phy_reset_post_delay = 1;
+
+		ret = of_property_read_u32(np, "phy-reset-post-delay",
+					   &fep->phy_reset_post_delay);
+		/* valid post reset delay should be less than 1s */
+		if (!ret && fep->phy_reset_post_delay > 1000)
+			fep->phy_reset_post_delay = 1;
+
+		fep->phy_reset_active_high =  of_property_read_bool(np, "phy-reset-active-high");
+
+		ret = devm_gpio_request_one(&pdev->dev, fep->phy_reset,
+					    fep->phy_reset_active_high ? GPIOF_OUT_INIT_HIGH : GPIOF_OUT_INIT_LOW,
+					    "phy-reset");
+		if (ret) {
+			dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n", ret);
+			goto failed_phy;
+		}
+	} else {
+		fep->phy_reset = 0;
+	}
+
 	ret = of_get_phy_mode(pdev->dev.of_node);
 	if (ret < 0) {
 		pdata = dev_get_platdata(&pdev->dev);
@@ -3433,7 +3434,7 @@ fec_probe(struct platform_device *pdev)
 	pm_runtime_set_active(&pdev->dev);
 	pm_runtime_enable(&pdev->dev);
 
-	ret = fec_reset_phy(pdev);
+	ret = fec_reset_phy(ndev);
 	if (ret)
 		goto failed_reset;
 
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
