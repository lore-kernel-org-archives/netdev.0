From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 2/2] net: stmmac: add fixed_phy and phy_addr support using DT file
Date: Fri, 23 Jan 2015 10:41:33 +0800
Message-ID: <1421980893-14475-3-git-send-email-ming.lei@canonical.com>
References: <1421980893-14475-1-git-send-email-ming.lei@canonical.com>
Cc: linux-samsung-soc@vger.kernel.org, Kukjin Kim <kgene@kernel.org>,
	netdev@vger.kernel.org, Byungho An <bh74.an@samsung.com>,
	Ming Lei <ming.lei@canonical.com>
To: linux-arm-kernel@lists.infradead.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <1421980893-14475-1-git-send-email-ming.lei@canonical.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Byungho An <bh74.an@samsung.com>

This patch adds codes for DT file support, fixed_phy and phy_addr
can be set in DT file.

Signed-off-by: Byungho An <bh74.an@samsung.com>
(bypass check for fixed phy)
Signed-off-by: Ming Lei<ming.lei@canonical.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    5 ++++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    7 +++++++
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8c6b7c16..ddb4351 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -847,8 +847,11 @@ static int stmmac_init_phy(struct net_device *dev)
 	 * 0 rather than 0xffff. Catch this here and treat 0 as a non-existent
 	 * device as well.
 	 * Note: phydev->phy_id is the result of reading the UID PHY registers.
+	 * But phy_id returned from fixed phy is always zero, so bypass the
+	 * check for fixed phy.
 	 */
-	if (phydev->phy_id == 0) {
+	if (phydev->phy_id == 0 && (!priv->plat->phy_bus_name ||
+			strcmp(priv->plat->phy_bus_name,"fixed"))) {
 		phy_disconnect(phydev);
 		return -ENODEV;
 	}
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 879e29f..4f11491 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -128,6 +128,7 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 	struct device_node *np = pdev->dev.of_node;
 	struct stmmac_dma_cfg *dma_cfg;
 	const struct of_device_id *device;
+	u32 phy_addr;
 
 	if (!np)
 		return -ENODEV;
@@ -217,6 +218,12 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 		plat->pmt = 1;
 	}
 
+	if (of_find_property(np, "fixed_phy", NULL)) {
+		plat->phy_bus_name = "fixed";
+		of_property_read_u32(np, "phy_addr", &phy_addr);
+		plat->phy_addr = phy_addr;
+	}
+
 	if (of_device_is_compatible(np, "snps,dwmac-3.610") ||
 		of_device_is_compatible(np, "snps,dwmac-3.710")) {
 		plat->enh_desc = 1;
-- 
1.7.9.5
