From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH 1/3] stmmac: adding DT parameter for LPI tx clock gating
Date: Wed,  4 Jan 2017 09:43:50 +0000
Message-ID: <6dc3480f471db4d125b6e3885ada2ff75f8a086e.1483372523.git.jpinto@synopsys.com>
References: <cover.1483372523.git.jpinto@synopsys.com>
Cc: lars.persson@axis.com, niklass@axis.com, swarren@nvidia.com,
        treding@nvidia.com, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:49939 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750993AbdADJoF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 04:44:05 -0500
In-Reply-To: <cover.1483372523.git.jpinto@synopsys.com>
In-Reply-To: <cover.1483372523.git.jpinto@synopsys.com>
References: <cover.1483372523.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new parameter to the stmmac DT: snps,en-tx-lpi-clockgating.
It was ported from synopsys/dwc_eth_qos.c and it is useful if lpi tx clock
gating is needed by stmmac users also.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
changes v1 -> v2:
- Nothing changed, just to keep up patch set version

 Documentation/devicetree/bindings/net/stmmac.txt      | 2 ++
 drivers/net/ethernet/stmicro/stmmac/common.h          | 3 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c  | 5 ++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h          | 1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c     | 6 +++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 3 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 3 +++
 include/linux/stmmac.h                                | 1 +
 8 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 128da75..a0c749f 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -49,6 +49,8 @@ Optional properties:
 - snps,force_sf_dma_mode	Force DMA to use the Store and Forward
 				mode for both tx and rx. This flag is
 				ignored if force_thresh_dma_mode is set.
+- snps,en-tx-lpi-clockgating	Enable gating of the MAC TX clock during
+				TX low-power mode
 - snps,multicast-filter-bins:	Number of multicast filter hash bins
 				supported by this device instance
 - snps,perfect-filter-entries:	Number of perfect filter entries supported
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 6c96291..75e2666 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -476,7 +476,8 @@ struct stmmac_ops {
 			      unsigned int reg_n);
 	void (*get_umac_addr)(struct mac_device_info *hw, unsigned char *addr,
 			      unsigned int reg_n);
-	void (*set_eee_mode)(struct mac_device_info *hw);
+	void (*set_eee_mode)(struct mac_device_info *hw,
+			     bool en_tx_lpi_clockgating);
 	void (*reset_eee_mode)(struct mac_device_info *hw);
 	void (*set_eee_timer)(struct mac_device_info *hw, int ls, int tw);
 	void (*set_eee_pls)(struct mac_device_info *hw, int link);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index be3c91c..a5ffca1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -343,11 +343,14 @@ static int dwmac1000_irq_status(struct mac_device_info *hw,
 	return ret;
 }
 
-static void dwmac1000_set_eee_mode(struct mac_device_info *hw)
+static void dwmac1000_set_eee_mode(struct mac_device_info *hw,
+				   bool en_tx_lpi_clockgating)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	u32 value;
 
+	/*TODO - en_tx_lpi_clockgating treatment */
+
 	/* Enable the link status receive on RGMII, SGMII ore SMII
 	 * receive path and instruct the transmit to enter in LPI
 	 * state.
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index 73d1dab..db45134 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -98,6 +98,7 @@ enum power_event {
 #define GMAC4_LPI_TIMER_CTRL	0xd4
 
 /* LPI control and status defines */
+#define GMAC4_LPI_CTRL_STATUS_LPITCSE	BIT(21)	/* LPI Tx Clock Stop Enable */
 #define GMAC4_LPI_CTRL_STATUS_LPITXA	BIT(19)	/* Enable LPI TX Automate */
 #define GMAC4_LPI_CTRL_STATUS_PLS	BIT(17) /* PHY Link Status */
 #define GMAC4_LPI_CTRL_STATUS_LPIEN	BIT(16)	/* LPI Enable */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 02eab79..834f40f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -137,7 +137,8 @@ static void dwmac4_get_umac_addr(struct mac_device_info *hw,
 				   GMAC_ADDR_LOW(reg_n));
 }
 
-static void dwmac4_set_eee_mode(struct mac_device_info *hw)
+static void dwmac4_set_eee_mode(struct mac_device_info *hw,
+				bool en_tx_lpi_clockgating)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	u32 value;
@@ -149,6 +150,9 @@ static void dwmac4_set_eee_mode(struct mac_device_info *hw)
 	value = readl(ioaddr + GMAC4_LPI_CTRL_STATUS);
 	value |= GMAC4_LPI_CTRL_STATUS_LPIEN | GMAC4_LPI_CTRL_STATUS_LPITXA;
 
+	if (en_tx_lpi_clockgating)
+		value |= GMAC4_LPI_CTRL_STATUS_LPITCSE;
+
 	writel(value, ioaddr + GMAC4_LPI_CTRL_STATUS);
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c97870f..f1a0afc 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -239,7 +239,8 @@ static void stmmac_enable_eee_mode(struct stmmac_priv *priv)
 	/* Check and enter in LPI mode */
 	if ((priv->dirty_tx == priv->cur_tx) &&
 	    (priv->tx_path_in_lpi_mode == false))
-		priv->hw->mac->set_eee_mode(priv->hw);
+		priv->hw->mac->set_eee_mode(priv->hw,
+					    priv->plat->en_tx_lpi_clockgating);
 }
 
 /**
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 082cd48..6064fcc 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -249,6 +249,9 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 	plat->force_sf_dma_mode =
 		of_property_read_bool(np, "snps,force_sf_dma_mode");
 
+	plat->en_tx_lpi_clockgating =
+		of_property_read_bool(np, "snps,en-tx-lpi-clockgating");
+
 	/* Set the maxmtu to a default of JUMBO_LEN in case the
 	 * parameter is not present in the device tree.
 	 */
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 266dab9..90fefde 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -143,5 +143,6 @@ struct plat_stmmacenet_data {
 	int has_gmac4;
 	bool tso_en;
 	int mac_port_sel_speed;
+	bool en_tx_lpi_clockgating;
 };
 #endif
-- 
2.9.3
