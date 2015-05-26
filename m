From: Mathieu Olivari <mathieu@codeaurora.org>
Subject: [PATCH 3/5] stmmac: add fixed-link device-tree support
Date: Tue, 26 May 2015 12:27:15 -0700
Message-ID: <1432668437-27763-4-git-send-email-mathieu@codeaurora.org>
References: <1432668437-27763-1-git-send-email-mathieu@codeaurora.org>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-clk@vger.kernel.org, netdev@vger.kernel.org
To: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	mturquette@linaro.org, sboyd@codeaurora.org,
	peppe.cavallaro@st.com, mathieu@codeaurora.org,
	agross@codeaurora.org, joshc@codeaurora.org,
	architt@codeaurora.org, georgi.djakov@linaro.org,
	wsa@the-dreams.de, rnayak@codeaurora.org, davem@davemloft.net,
	vbridger@opensource.altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432668437-27763-1-git-send-email-mathieu@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case DT is used, this change adds the ability to the stmmac driver to
detect a fixed-link PHY, instanciate it, and use it during
phy_connect().

Fixed link PHYs DT usage is described in:
Documentation/devicetree/bindings/net/fixed-link.txt

Signed-off-by: Mathieu Olivari <mathieu@codeaurora.org>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     |  2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 12 +++++++++++-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 31c6416..c46178c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -856,7 +856,7 @@ static int stmmac_init_phy(struct net_device *dev)
 	 * device as well.
 	 * Note: phydev->phy_id is the result of reading the UID PHY registers.
 	 */
-	if (phydev->phy_id == 0) {
+	if (!priv->plat->phy_node && phydev->phy_id == 0) {
 		phy_disconnect(phydev);
 		return -ENODEV;
 	}
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 8d23155..f3918c7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -148,6 +148,14 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 	/* If we find a phy-handle property, use it as the PHY */
 	plat->phy_node = of_parse_phandle(np, "phy-handle", 0);
 
+	/* If phy-handle is not specified, check if we have a fixed-phy */
+	if (!plat->phy_node && of_phy_is_fixed_link(np)) {
+		if ((of_phy_register_fixed_link(np) < 0))
+			return -ENODEV;
+
+		plat->phy_node = of_node_get(np);
+	}
+
 	/* "snps,phy-addr" is not a standard property. Mark it as deprecated
 	 * and warn of its use. Remove this when phy node support is added.
 	 */
@@ -212,8 +220,10 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 	if (of_find_property(np, "snps,pbl", NULL)) {
 		dma_cfg = devm_kzalloc(&pdev->dev, sizeof(*dma_cfg),
 				       GFP_KERNEL);
-		if (!dma_cfg)
+		if (!dma_cfg) {
+			of_node_put(np);
 			return -ENOMEM;
+		}
 		plat->dma_cfg = dma_cfg;
 		of_property_read_u32(np, "snps,pbl", &dma_cfg->pbl);
 		dma_cfg->fixed_burst =
-- 
2.1.4
