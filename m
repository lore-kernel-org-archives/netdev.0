From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 11/17] stmmac: let dwmac-* drivers handle their own match data
Date: Wed, 29 Jul 2015 00:08:58 +0200
Message-ID: <1438121344-5304-12-git-send-email-manabian@gmail.com>
References: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:32892 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953AbbG1WJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:09:33 -0400
Received: by lbbyj8 with SMTP id yj8so83986186lbb.0
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:09:32 -0700 (PDT)
In-Reply-To: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since only a few of the dwmac-* drivers actually need to use
the OF match move handling into the dwmac-* drivers that need
it. This will also allow dwmac-* drivers to use their own
custom match data structure.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c        |  8 ++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c       | 10 ++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 18 ------------------
 3 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 21193a73acfc..65c1e1afe6a8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -580,8 +580,15 @@ static int rk_gmac_probe(struct platform_device *pdev)
 {
 	struct plat_stmmacenet_data *plat_dat;
 	struct stmmac_resources stmmac_res;
+	const struct stmmac_of_data *data;
 	int ret;
 
+	data = of_device_get_match_data(&pdev->dev);
+	if (!data) {
+		dev_err(&pdev->dev, "no of match data provided\n");
+		return -EINVAL;
+	}
+
 	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
 	if (ret)
 		return ret;
@@ -591,6 +598,7 @@ static int rk_gmac_probe(struct platform_device *pdev)
 		return PTR_ERR(plat_dat);
 
 	plat_dat->has_gmac = true;
+	plat_dat->setup = data->setup;
 	plat_dat->init = rk_gmac_init;
 	plat_dat->exit = rk_gmac_exit;
 	plat_dat->fix_mac_speed = rk_fix_speed;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index b17238aac791..8a977fde1a46 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -21,6 +21,7 @@
 #include <linux/regmap.h>
 #include <linux/clk.h>
 #include <linux/of.h>
+#include <linux/of_device.h>
 #include <linux/of_net.h>
 
 #include "stmmac_platform.h"
@@ -337,10 +338,17 @@ static int sti_dwmac_parse_data(struct sti_dwmac *dwmac,
 static int sti_dwmac_probe(struct platform_device *pdev)
 {
 	struct plat_stmmacenet_data *plat_dat;
+	const struct stmmac_of_data *data;
 	struct stmmac_resources stmmac_res;
 	struct sti_dwmac *dwmac;
 	int ret;
 
+	data = of_device_get_match_data(&pdev->dev);
+	if (!data) {
+		dev_err(&pdev->dev, "No OF match data provided\n");
+		return -EINVAL;
+	}
+
 	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
 	if (ret)
 		return ret;
@@ -360,7 +368,9 @@ static int sti_dwmac_probe(struct platform_device *pdev)
 	}
 
 	plat_dat->bsp_priv = dwmac;
+	plat_dat->init = data->init;
 	plat_dat->exit = sti_dwmac_exit;
+	plat_dat->fix_mac_speed = data->fix_mac_speed;
 
 	ret = plat_dat->init(pdev, plat_dat->bsp_priv);
 	if (ret)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 9c49d95e529a..55e569b330b2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -109,30 +109,12 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 {
 	struct device_node *np = pdev->dev.of_node;
 	struct plat_stmmacenet_data *plat;
-	const struct stmmac_of_data *data;
 	struct stmmac_dma_cfg *dma_cfg;
 
 	plat = devm_kzalloc(&pdev->dev, sizeof(*plat), GFP_KERNEL);
 	if (!plat)
 		return ERR_PTR(-ENOMEM);
 
-	data = of_device_get_match_data(&pdev->dev);
-	if (data) {
-		plat->has_gmac = data->has_gmac;
-		plat->enh_desc = data->enh_desc;
-		plat->tx_coe = data->tx_coe;
-		plat->rx_coe = data->rx_coe;
-		plat->bugged_jumbo = data->bugged_jumbo;
-		plat->pmt = data->pmt;
-		plat->riwt_off = data->riwt_off;
-		plat->fix_mac_speed = data->fix_mac_speed;
-		plat->bus_setup = data->bus_setup;
-		plat->setup = data->setup;
-		plat->free = data->free;
-		plat->init = data->init;
-		plat->exit = data->exit;
-	}
-
 	*mac = of_get_mac_address(np);
 	plat->interface = of_get_phy_mode(np);
 
-- 
1.8.0
