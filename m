From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v2] stmmac: CSR clock configuration fix
Date: Thu, 22 Dec 2016 12:38:00 +0000
Message-ID: <7b395fd7dfd0c808243a744393473cbbf89b268a.1482410161.git.jpinto@synopsys.com>
Cc: hock.leong.kweh@intel.com, niklas.cassel@axis.com, pavel@ucw.cz,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: peppe.cavallaro@st.com, davem@davemloft.net,
        seraphin.bonnaffe@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When testing stmmac with my QoS reference design I checked a problem in the
CSR clock configuration that was impossibilitating the phy discovery, since
every read operation returned 0x0000ffff. This patch fixes the issue.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
changes v1->v2 (David Miller)
- DWMAC100 and DWMAC1000 csr clocks masks should also be fixed for the patch
to make sense

 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c | 2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c  | 2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c    | 8 ++++----
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index b21d03f..94223c8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -539,7 +539,7 @@ struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
 	mac->mii.reg_shift = 6;
 	mac->mii.reg_mask = 0x000007C0;
 	mac->mii.clk_csr_shift = 2;
-	mac->mii.clk_csr_mask = 0xF;
+	mac->mii.clk_csr_mask = GENMASK(4, 2);
 
 	/* Get and dump the chip ID */
 	*synopsys_id = stmmac_get_synopsys_id(hwid);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
index a1d582f..8a40e69 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
@@ -197,7 +197,7 @@ struct mac_device_info *dwmac100_setup(void __iomem *ioaddr, int *synopsys_id)
 	mac->mii.reg_shift = 6;
 	mac->mii.reg_mask = 0x000007C0;
 	mac->mii.clk_csr_shift = 2;
-	mac->mii.clk_csr_mask = 0xF;
+	mac->mii.clk_csr_mask = GENMASK(4, 2);
 
 	/* Synopsys Id is not available on old chips */
 	*synopsys_id = 0;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 23322fd..fda01f7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -81,8 +81,8 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
 	value |= (phyaddr << priv->hw->mii.addr_shift)
 		& priv->hw->mii.addr_mask;
 	value |= (phyreg << priv->hw->mii.reg_shift) & priv->hw->mii.reg_mask;
-	value |= (priv->clk_csr & priv->hw->mii.clk_csr_mask)
-		<< priv->hw->mii.clk_csr_shift;
+	value |= (priv->clk_csr << priv->hw->mii.clk_csr_shift)
+		& priv->hw->mii.clk_csr_mask;
 	if (priv->plat->has_gmac4)
 		value |= MII_GMAC4_READ;
 
@@ -122,8 +122,8 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 		& priv->hw->mii.addr_mask;
 	value |= (phyreg << priv->hw->mii.reg_shift) & priv->hw->mii.reg_mask;
 
-	value |= ((priv->clk_csr & priv->hw->mii.clk_csr_mask)
-		<< priv->hw->mii.clk_csr_shift);
+	value |= (priv->clk_csr << priv->hw->mii.clk_csr_shift)
+		& priv->hw->mii.clk_csr_mask;
 	if (priv->plat->has_gmac4)
 		value |= MII_GMAC4_WRITE;
 
-- 
2.9.3
