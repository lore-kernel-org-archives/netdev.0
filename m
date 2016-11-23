From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH 4/4] net: stmmac: stmmac_platform: use correct setup function for gmac4
Date: Wed, 23 Nov 2016 15:25:17 +0100
Message-ID: <1479911117-19917-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Niklas Cassel <niklass@axis.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>

devicetree binding for stmmac states:
- compatible: Should be "snps,dwmac-<ip_version>", "snps,dwmac"
	For backwards compatibility: "st,spear600-gmac" is also supported.

Previously, when specifying "snps,dwmac-4.10a", "snps,dwmac" as your
compatible string, plat_stmmacenet_data would have both has_gmac and
has_gmac4 set.

This would lead to stmmac_hw_init calling dwmac1000_setup rather than
dwmac4_setup, resulting in a non-functional driver.
This happened since the check for has_gmac is done before the check for
has_gmac4. However, the order should not matter, so it does not make sense
to have both set.

If something is valid for both, you should do as the stmmac_interrupt does:
if (priv->plat->has_gmac || priv->plat->has_gmac4) ...

The places where it was obvious that the author actually meant
if (has_gmac || has_gmac4) rather than if (has_gmac) has been updated.

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c  | 4 ++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index d5a8122b6033..dd5b38e4cd1f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -263,7 +263,7 @@ static void stmmac_ethtool_getdrvinfo(struct net_device *dev,
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 
-	if (priv->plat->has_gmac)
+	if (priv->plat->has_gmac || priv->plat->has_gmac4)
 		strlcpy(info->driver, GMAC_ETHTOOL_NAME, sizeof(info->driver));
 	else
 		strlcpy(info->driver, MAC100_ETHTOOL_NAME,
@@ -448,7 +448,7 @@ static void stmmac_ethtool_gregs(struct net_device *dev,
 
 	memset(reg_space, 0x0, REG_SPACE_SIZE);
 
-	if (!priv->plat->has_gmac) {
+	if (!(priv->plat->has_gmac || priv->plat->has_gmac4)) {
 		/* MAC registers */
 		for (i = 0; i < 12; i++)
 			reg_space[i] = readl(priv->ioaddr + (i * 4));
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 4d544c34c1f2..c8a59f396c6e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -291,6 +291,7 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 	if (of_device_is_compatible(np, "snps,dwmac-4.00") ||
 	    of_device_is_compatible(np, "snps,dwmac-4.10a")) {
 		plat->has_gmac4 = 1;
+		plat->has_gmac = 0;
 		plat->pmt = 1;
 		plat->tso_en = of_property_read_bool(np, "snps,tso");
 	}
-- 
2.1.4
