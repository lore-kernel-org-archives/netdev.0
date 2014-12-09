From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH] stmmac: platform: adjust messages and move to dev level
Date: Tue,  9 Dec 2014 11:59:13 +0200
Message-ID: <1418119153-13355-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4827 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754396AbaLIJ7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 04:59:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch amendes error and warning messages across the platform driver. It
includes the following changes:
 - remove unneccessary message when no memory is available
 - change info level to warn in the validation functions
 - append \n to the end of messages
 - change pr_* macros to dev_*

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 37 ++++++++++++----------
 1 file changed, 21 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 4032b17..e809b30 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -53,6 +53,7 @@ MODULE_DEVICE_TABLE(of, stmmac_dt_ids);
 
 /**
  * dwmac1000_validate_mcast_bins - validates the number of Multicast filter bins
+ * @dev: struct device of the platform device
  * @mcast_bins: Multicast filtering bins
  * Description:
  * this function validates the number of Multicast filtering bins specified
@@ -63,7 +64,7 @@ MODULE_DEVICE_TABLE(of, stmmac_dt_ids);
  * invalid and will cause the filtering algorithm to use Multicast
  * promiscuous mode.
  */
-static int dwmac1000_validate_mcast_bins(int mcast_bins)
+static int dwmac1000_validate_mcast_bins(struct device *dev, int mcast_bins)
 {
 	int x = mcast_bins;
 
@@ -74,8 +75,8 @@ static int dwmac1000_validate_mcast_bins(int mcast_bins)
 		break;
 	default:
 		x = 0;
-		pr_info("Hash table entries set to unexpected value %d",
-			mcast_bins);
+		dev_warn(dev, "Hash table entries set to unexpected value %d\n",
+			 mcast_bins);
 		break;
 	}
 	return x;
@@ -83,6 +84,7 @@ static int dwmac1000_validate_mcast_bins(int mcast_bins)
 
 /**
  * dwmac1000_validate_ucast_entries - validate the Unicast address entries
+ * @dev: struct device of the platform device
  * @ucast_entries: number of Unicast address entries
  * Description:
  * This function validates the number of Unicast address entries supported
@@ -92,7 +94,8 @@ static int dwmac1000_validate_mcast_bins(int mcast_bins)
  * selected, and defaults to 1 Unicast address if an unsupported
  * configuration is selected.
  */
-static int dwmac1000_validate_ucast_entries(int ucast_entries)
+static int dwmac1000_validate_ucast_entries(struct device *dev,
+					    int ucast_entries)
 {
 	int x = ucast_entries;
 
@@ -104,8 +107,9 @@ static int dwmac1000_validate_ucast_entries(int ucast_entries)
 		break;
 	default:
 		x = 1;
-		pr_info("Unicast table entries set to unexpected value %d\n",
-			ucast_entries);
+		dev_warn(dev,
+			 "Unicast table entries set to unexpected value %d\n",
+			 ucast_entries);
 		break;
 	}
 	return x;
@@ -209,9 +213,9 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 		of_property_read_u32(np, "snps,perfect-filter-entries",
 				     &plat->unicast_filter_entries);
 		plat->unicast_filter_entries = dwmac1000_validate_ucast_entries(
-					       plat->unicast_filter_entries);
+				&pdev->dev, plat->unicast_filter_entries);
 		plat->multicast_filter_bins = dwmac1000_validate_mcast_bins(
-					      plat->multicast_filter_bins);
+				&pdev->dev, plat->multicast_filter_bins);
 		plat->has_gmac = 1;
 		plat->pmt = 1;
 	}
@@ -238,7 +242,8 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 	plat->force_thresh_dma_mode = of_property_read_bool(np, "snps,force_thresh_dma_mode");
 	if (plat->force_thresh_dma_mode) {
 		plat->force_sf_dma_mode = 0;
-		pr_warn("force_sf_dma_mode is ignored if force_thresh_dma_mode is set.");
+		dev_warn(&pdev->dev,
+			 "force_sf_dma_mode is ignored if force_thresh_dma_mode is set.\n");
 	}
 
 	return 0;
@@ -280,10 +285,8 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 		plat_dat = devm_kzalloc(&pdev->dev,
 					sizeof(struct plat_stmmacenet_data),
 					GFP_KERNEL);
-	if (!plat_dat) {
-		pr_err("%s: ERROR: no memory", __func__);
+	if (!plat_dat)
 		return  -ENOMEM;
-	}
 
 	/* Set default value for multicast hash bins */
 	plat_dat->multicast_filter_bins = HASH_TABLE_SIZE;
@@ -294,7 +297,8 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 	if (pdev->dev.of_node) {
 		ret = stmmac_probe_config_dt(pdev, plat_dat, &mac);
 		if (ret) {
-			pr_err("%s: main dt probe failed", __func__);
+			dev_err(&pdev->dev, "%s: main dt probe failed\n",
+				__func__);
 			return ret;
 		}
 	}
@@ -313,9 +317,10 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 			return ret;
 	}
 
-	priv = stmmac_dvr_probe(&(pdev->dev), plat_dat, addr);
+	priv = stmmac_dvr_probe(&pdev->dev, plat_dat, addr);
 	if (IS_ERR(priv)) {
-		pr_err("%s: main driver probe failed", __func__);
+		dev_err(&pdev->dev, "%s: main driver probe failed\n",
+			__func__);
 		return PTR_ERR(priv);
 	}
 
@@ -354,7 +359,7 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, priv->dev);
 
-	pr_debug("STMMAC platform driver registration completed");
+	dev_dbg(&pdev->dev, "STMMAC platform driver registration completed\n");
 
 	return 0;
 }
-- 
2.1.3
