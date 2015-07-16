From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 2/8] stmmac: clean up platform/of_match data retrieval
Date: Fri, 17 Jul 2015 00:26:06 +0200
Message-ID: <1437085572-11371-3-git-send-email-manabian@gmail.com>
References: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:35890 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbbGPW0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 18:26:36 -0400
Received: by lagw2 with SMTP id w2so51607889lag.3
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 15:26:35 -0700 (PDT)
In-Reply-To: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor code to clearly separate probing non-dt versus dt. In the
non-dt case platform data must be supplied to probe successfully.
For dt the platform data structure is created and match data is
copied into it. Note that support for supplying platform data in
dt from AUXDATA is dropped as no users in mainline does this.

This change will allow dt dwmac-* drivers to call the config_dt()
function from probe to create the needed platform data struct and
retrieve common dt properties.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 50 +++++++++++++---------
 1 file changed, 29 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 89e40ddc0391..6e6ef859f58a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -105,13 +105,20 @@ static int dwmac1000_validate_ucast_entries(int ucast_entries)
  * set some private fields that will be used by the main at runtime.
  */
 static int stmmac_probe_config_dt(struct platform_device *pdev,
-				  struct plat_stmmacenet_data *plat,
+				  struct plat_stmmacenet_data **plat_dat,
 				  const char **mac)
 {
 	struct device_node *np = pdev->dev.of_node;
+	struct plat_stmmacenet_data *plat;
 	const struct stmmac_of_data *data;
 	struct stmmac_dma_cfg *dma_cfg;
 
+	plat = devm_kzalloc(&pdev->dev, sizeof(*plat), GFP_KERNEL);
+	if (!plat)
+		return -ENOMEM;
+
+	*plat_dat = plat;
+
 	data = of_device_get_match_data(&pdev->dev);
 	if (data) {
 		plat->has_gmac = data->has_gmac;
@@ -180,6 +187,12 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 	 */
 	plat->maxmtu = JUMBO_LEN;
 
+	/* Set default value for multicast hash bins */
+	plat->multicast_filter_bins = HASH_TABLE_SIZE;
+
+	/* Set default value for unicast filter entries */
+	plat->unicast_filter_entries = 1;
+
 	/*
 	 * Currently only the properties needed on SPEAr600
 	 * are provided. All other properties should be added
@@ -242,7 +255,7 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 }
 #else
 static int stmmac_probe_config_dt(struct platform_device *pdev,
-				  struct plat_stmmacenet_data *plat,
+				  struct plat_stmmacenet_data **plat,
 				  const char **mac)
 {
 	return -ENOSYS;
@@ -301,29 +314,24 @@ int stmmac_pltfr_probe(struct platform_device *pdev)
 	if (IS_ERR(stmmac_res.addr))
 		return PTR_ERR(stmmac_res.addr);
 
-	plat_dat = dev_get_platdata(&pdev->dev);
-
-	if (!plat_dat)
-		plat_dat = devm_kzalloc(&pdev->dev,
-					sizeof(struct plat_stmmacenet_data),
-					GFP_KERNEL);
-	if (!plat_dat) {
-		pr_err("%s: ERROR: no memory", __func__);
-		return  -ENOMEM;
-	}
-
-	/* Set default value for multicast hash bins */
-	plat_dat->multicast_filter_bins = HASH_TABLE_SIZE;
-
-	/* Set default value for unicast filter entries */
-	plat_dat->unicast_filter_entries = 1;
-
 	if (pdev->dev.of_node) {
-		ret = stmmac_probe_config_dt(pdev, plat_dat, &stmmac_res.mac);
+		ret = stmmac_probe_config_dt(pdev, &plat_dat, &stmmac_res.mac);
 		if (ret) {
-			pr_err("%s: main dt probe failed", __func__);
+			dev_err(&pdev->dev, "dt configuration failed\n");
 			return ret;
 		}
+	} else {
+		plat_dat = dev_get_platdata(&pdev->dev);
+		if (!plat_dat) {
+			dev_err(&pdev->dev, "no platform data provided\n");
+			return  -EINVAL;
+		}
+
+		/* Set default value for multicast hash bins */
+		plat_dat->multicast_filter_bins = HASH_TABLE_SIZE;
+
+		/* Set default value for unicast filter entries */
+		plat_dat->unicast_filter_entries = 1;
 	}
 
 	/* Custom setup (if needed) */
-- 
1.8.0
