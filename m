From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 3/4] stmmac: verify the dma_cfg platform fields
Date: Thu, 19 Apr 2012 07:48:21 +0200
Message-ID: <1334814502-29707-3-git-send-email-peppe.cavallaro@st.com>
References: <1334814502-29707-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Viresh Kumar <viresh.kumar@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:49298 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751798Ab2DSFsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 01:48:42 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D9057201
	for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 05:48:39 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 843B518B5
	for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 05:48:39 +0000 (GMT)
In-Reply-To: <1334814502-29707-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently the dma parameters that can be passed from the platform
have been moved from the plat_stmmacenet_data to the stmmac_dma_cfg.

In case of this new structure is not well allocated the driver can
fails. This is an example how this field is managed in ST platforms

static struct stmmac_dma_cfg gmac_dma_setting = {
        .pbl = 32,
};

static struct plat_stmmacenet_data stih415_ethernet_platform_data[] = {
	{
		.dma_cfg = &gmac_dma_setting,
		.has_gmac = 1,
[snip]

This patch so verifies that the dma_cfg passed from the platform.
In case of it is NULL there is no reason that the driver has to fail
and some default values can be passed. These are ok for all the
Synopsys chips and could impact on performances, only.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
cc: Viresh Kumar <viresh.kumar@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   23 ++++++++++++++++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |    7 ++++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    1 -
 4 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 9e42b5d..f5dedcb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -147,6 +147,7 @@ struct stmmac_extra_stats {
 #define DMA_HW_FEAT_FLEXIPPSEN	0x04000000 /* Flexible PPS Output */
 #define DMA_HW_FEAT_SAVLANINS	0x08000000 /* Source Addr or VLAN Insertion */
 #define DMA_HW_FEAT_ACTPHYIF	0x70000000 /* Active/selected PHY interface */
+#define DEFAULT_DMA_PBL		8
 
 enum rx_frame_status { /* IPC status */
 	good_frame = 0,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 9ecd6cf..efc42e1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -919,6 +919,24 @@ static void stmmac_check_ether_addr(struct stmmac_priv *priv)
 						   priv->dev->dev_addr);
 }
 
+static int stmmac_init_dma_engine(struct stmmac_priv *priv)
+{
+	int pbl = DEFAULT_DMA_PBL, fixed_burst = 0, burst_len = 0;
+
+	/* Some DMA parameters can be passed from the platform;
+	 * in case of these are not passed we keep a default
+	 * (good for all the chips) and init the DMA! */
+	if (priv->plat->dma_cfg) {
+		pbl = priv->plat->dma_cfg->pbl;
+		fixed_burst = priv->plat->dma_cfg->fixed_burst;
+		burst_len = priv->plat->dma_cfg->burst_len;
+	}
+
+	return priv->hw->dma->init(priv->ioaddr, pbl, fixed_burst,
+				   burst_len, priv->dma_tx_phy,
+				   priv->dma_rx_phy);
+}
+
 /**
  *  stmmac_open - open entry point of the driver
  *  @dev : pointer to the device structure.
@@ -967,10 +985,7 @@ static int stmmac_open(struct net_device *dev)
 	init_dma_desc_rings(dev);
 
 	/* DMA initialization and SW reset */
-	ret = priv->hw->dma->init(priv->ioaddr, priv->plat->dma_cfg->pbl,
-				  priv->plat->dma_cfg->fixed_burst,
-				  priv->plat->dma_cfg->burst_len,
-				  priv->dma_tx_phy, priv->dma_rx_phy);
+	ret = stmmac_init_dma_engine(priv);
 	if (ret < 0) {
 		pr_err("%s: DMA initialization failed\n", __func__);
 		goto open_error;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 65e0f98..58fab53 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -28,6 +28,7 @@
 
 struct plat_stmmacenet_data plat_dat;
 struct stmmac_mdio_bus_data mdio_data;
+struct stmmac_dma_cfg dma_cfg;
 
 static void stmmac_default_data(void)
 {
@@ -35,8 +36,6 @@ static void stmmac_default_data(void)
 	plat_dat.bus_id = 1;
 	plat_dat.phy_addr = 0;
 	plat_dat.interface = PHY_INTERFACE_MODE_GMII;
-	plat_dat.dma_cfg->pbl = 32;
-	plat_dat.dma_cfg->burst_len = DMA_AXI_BLEN_256;
 	plat_dat.clk_csr = 2;	/* clk_csr_i = 20-35MHz & MDC = clk_csr_i/16 */
 	plat_dat.has_gmac = 1;
 	plat_dat.force_sf_dma_mode = 1;
@@ -45,6 +44,10 @@ static void stmmac_default_data(void)
 	mdio_data.phy_reset = NULL;
 	mdio_data.phy_mask = 0;
 	plat_dat.mdio_bus_data = &mdio_data;
+
+	dma_cfg.pbl = 32;
+	dma_cfg.burst_len = DMA_AXI_BLEN_256;
+	plat_dat.dma_cfg = &dma_cfg;
 }
 
 /**
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index ba30d38..3dd8f08 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -50,7 +50,6 @@ static int __devinit stmmac_probe_config_dt(struct platform_device *pdev,
 	 * once needed on other platforms.
 	 */
 	if (of_device_is_compatible(np, "st,spear600-gmac")) {
-		plat->dma_cfg->pbl = 8;
 		plat->has_gmac = 1;
 		plat->pmt = 1;
 	}
-- 
1.7.4.4
