From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH] stmmac: ipq806x: Return error values instead of pointers
Date: Wed,  2 Dec 2015 23:55:15 -0800
Message-ID: <1449129315-1427-1-git-send-email-sboyd@codeaurora.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, Joachim Eastwood <manabian@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Typically we return error pointers when we want to use those
pointers in the non-error case, but this function is just
returning error pointers or NULL for success. Change the style to
plain int to follow normal kernel coding styles.

Cc: Joachim Eastwood <manabian@gmail.com>
Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---
 .../net/ethernet/stmicro/stmmac/dwmac-ipq806x.c    | 24 ++++++++++------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
index 82de68b1a452..36d3355f2fb0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
@@ -198,19 +198,19 @@ static int ipq806x_gmac_set_speed(struct ipq806x_gmac *gmac, unsigned int speed)
 	return 0;
 }
 
-static void *ipq806x_gmac_of_parse(struct ipq806x_gmac *gmac)
+static int ipq806x_gmac_of_parse(struct ipq806x_gmac *gmac)
 {
 	struct device *dev = &gmac->pdev->dev;
 
 	gmac->phy_mode = of_get_phy_mode(dev->of_node);
 	if (gmac->phy_mode < 0) {
 		dev_err(dev, "missing phy mode property\n");
-		return ERR_PTR(-EINVAL);
+		return -EINVAL;
 	}
 
 	if (of_property_read_u32(dev->of_node, "qcom,id", &gmac->id) < 0) {
 		dev_err(dev, "missing qcom id property\n");
-		return ERR_PTR(-EINVAL);
+		return -EINVAL;
 	}
 
 	/* The GMACs are called 1 to 4 in the documentation, but to simplify the
@@ -219,13 +219,13 @@ static void *ipq806x_gmac_of_parse(struct ipq806x_gmac *gmac)
 	 */
 	if (gmac->id < 0 || gmac->id > 3) {
 		dev_err(dev, "invalid gmac id\n");
-		return ERR_PTR(-EINVAL);
+		return -EINVAL;
 	}
 
 	gmac->core_clk = devm_clk_get(dev, "stmmaceth");
 	if (IS_ERR(gmac->core_clk)) {
 		dev_err(dev, "missing stmmaceth clk property\n");
-		return gmac->core_clk;
+		return PTR_ERR(gmac->core_clk);
 	}
 	clk_set_rate(gmac->core_clk, 266000000);
 
@@ -234,18 +234,16 @@ static void *ipq806x_gmac_of_parse(struct ipq806x_gmac *gmac)
 							   "qcom,nss-common");
 	if (IS_ERR(gmac->nss_common)) {
 		dev_err(dev, "missing nss-common node\n");
-		return gmac->nss_common;
+		return PTR_ERR(gmac->nss_common);
 	}
 
 	/* Setup the register map for the qsgmii csr registers */
 	gmac->qsgmii_csr = syscon_regmap_lookup_by_phandle(dev->of_node,
 							   "qcom,qsgmii-csr");
-	if (IS_ERR(gmac->qsgmii_csr)) {
+	if (IS_ERR(gmac->qsgmii_csr))
 		dev_err(dev, "missing qsgmii-csr node\n");
-		return gmac->qsgmii_csr;
-	}
 
-	return NULL;
+	return PTR_ERR_OR_ZERO(gmac->qsgmii_csr);
 }
 
 static void ipq806x_gmac_fix_mac_speed(void *priv, unsigned int speed)
@@ -262,7 +260,7 @@ static int ipq806x_gmac_probe(struct platform_device *pdev)
 	struct device *dev = &pdev->dev;
 	struct ipq806x_gmac *gmac;
 	int val;
-	void *err;
+	int err;
 
 	val = stmmac_get_platform_resources(pdev, &stmmac_res);
 	if (val)
@@ -279,9 +277,9 @@ static int ipq806x_gmac_probe(struct platform_device *pdev)
 	gmac->pdev = pdev;
 
 	err = ipq806x_gmac_of_parse(gmac);
-	if (IS_ERR(err)) {
+	if (err) {
 		dev_err(dev, "device tree parsing error\n");
-		return PTR_ERR(err);
+		return err;
 	}
 
 	regmap_write(gmac->qsgmii_csr, QSGMII_PCS_CAL_LCKDT_CTL,
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project
