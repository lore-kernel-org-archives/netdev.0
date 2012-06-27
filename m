From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH v2 2/5] net: fec: enable regulator for fec phy
Date: Wed, 27 Jun 2012 21:45:21 +0800
Message-ID: <1340804724-29410-3-git-send-email-shawn.guo@linaro.org>
References: <1340804724-29410-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	Florian Fainelli <florian@openwrt.org>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<devicetree-discuss@lists.ozlabs.org>,
	Shawn Guo <shawn.guo@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe006.messaging.microsoft.com ([213.199.154.209]:58148
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752852Ab2F0Nph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 09:45:37 -0400
In-Reply-To: <1340804724-29410-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If bootloader or platform initialization code does not enable the
power supply to fec phy, we need to do it in fec driver before calling
fec_reset_phy to have the phy powered on.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/ethernet/freescale/fec.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index e868a37..4dce9e3 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -49,6 +49,7 @@
 #include <linux/of_gpio.h>
 #include <linux/of_net.h>
 #include <linux/pinctrl/consumer.h>
+#include <linux/regulator/consumer.h>
 
 #include <asm/cacheflush.h>
 
@@ -1546,6 +1547,7 @@ fec_probe(struct platform_device *pdev)
 	const struct of_device_id *of_id;
 	static int dev_id;
 	struct pinctrl *pinctrl;
+	struct regulator *reg_phy;
 
 	of_id = of_match_device(fec_dt_ids, &pdev->dev);
 	if (of_id)
@@ -1632,6 +1634,16 @@ fec_probe(struct platform_device *pdev)
 	clk_prepare_enable(fep->clk_ahb);
 	clk_prepare_enable(fep->clk_ipg);
 
+	reg_phy = devm_regulator_get(&pdev->dev, "phy");
+	if (!IS_ERR(reg_phy)) {
+		ret = regulator_enable(reg_phy);
+		if (ret) {
+			dev_err(&pdev->dev,
+				"Failed to enable phy regulator: %d\n", ret);
+			goto failed_regulator;
+		}
+	}
+
 	fec_reset_phy(pdev);
 
 	ret = fec_enet_init(ndev);
@@ -1655,6 +1667,7 @@ failed_register:
 	fec_enet_mii_remove(fep);
 failed_mii_init:
 failed_init:
+failed_regulator:
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
 failed_pin:
-- 
1.7.5.4
