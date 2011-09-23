From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH v5 1/3] net/fec: fec_reset_phy() does not need to always succeed
Date: Fri, 23 Sep 2011 20:12:46 +0800
Message-ID: <1316779968-21390-2-git-send-email-shawn.guo@linaro.org>
References: <1316779968-21390-1-git-send-email-shawn.guo@linaro.org>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@linaro.org, Shawn Guo <shawn.guo@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:60621 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753658Ab1IWMLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 08:11:10 -0400
Received: by gwb15 with SMTP id 15so3646219gwb.19
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2011 05:11:09 -0700 (PDT)
In-Reply-To: <1316779968-21390-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FEC can work without a phy reset on some platforms, which means not
very platform necessarily have a phy-reset gpio encoded in device tree.
Even on the platforms that have the gpio, FEC can work without
resetting phy for some cases, e.g. boot loader has done that.

So it makes more sense to have the phy-reset-gpio request failure as
a debug message rather than a warning, and get fec_reset_phy() return
void since the caller does not check the return anyway.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/ethernet/freescale/fec.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 158b82e..9c1d059 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1411,24 +1411,22 @@ static int __devinit fec_get_phy_mode_dt(struct platform_device *pdev)
 	return -ENODEV;
 }
 
-static int __devinit fec_reset_phy(struct platform_device *pdev)
+static void __devinit fec_reset_phy(struct platform_device *pdev)
 {
 	int err, phy_reset;
 	struct device_node *np = pdev->dev.of_node;
 
 	if (!np)
-		return -ENODEV;
+		return;
 
 	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
 	err = gpio_request_one(phy_reset, GPIOF_OUT_INIT_LOW, "phy-reset");
 	if (err) {
-		pr_warn("FEC: failed to get gpio phy-reset: %d\n", err);
-		return err;
+		pr_debug("FEC: failed to get gpio phy-reset: %d\n", err);
+		return;
 	}
 	msleep(1);
 	gpio_set_value(phy_reset, 1);
-
-	return 0;
 }
 #else /* CONFIG_OF */
 static inline int fec_get_phy_mode_dt(struct platform_device *pdev)
@@ -1436,13 +1434,12 @@ static inline int fec_get_phy_mode_dt(struct platform_device *pdev)
 	return -ENODEV;
 }
 
-static inline int fec_reset_phy(struct platform_device *pdev)
+static inline void fec_reset_phy(struct platform_device *pdev)
 {
 	/*
 	 * In case of platform probe, the reset has been done
 	 * by machine code.
 	 */
-	return 0;
 }
 #endif /* CONFIG_OF */
 
-- 
1.7.4.1
