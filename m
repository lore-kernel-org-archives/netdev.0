From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 02/18] stmmac: rework DMA bus setting and introduce new platform AXI structure
Date: Wed, 9 Dec 2015 09:37:38 +0100
Message-ID: <1449650274-14896-3-git-send-email-peppe.cavallaro@st.com>
References: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:2789 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753319AbbLII2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 03:28:01 -0500
Received: from pps.filterd (m0046037.ppops.net [127.0.0.1])
	by m0046037.ppops.net (8.14.5/8.14.5) with SMTP id tB98Blg0031137
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2015 09:27:59 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by m0046037.ppops.net with ESMTP id 1ynn3af6xa-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 09:27:59 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 19DC234
	for <netdev@vger.kernel.org>; Wed,  9 Dec 2015 08:27:22 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 73FBC4EB2
	for <netdev@vger.kernel.org>; Wed,  9 Dec 2015 08:27:57 +0000 (GMT)
In-Reply-To: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch restructures the DMA bus settings and this is done
by introducing a new platform structure used for programming
the AXI Bus Mode Register inside the DMA module.
This structure can be populated from device-tree as documented in the
binding txt file.

After initializing the DMA, the AXI register can be optionally tuned
for platform drivers based.
This patch also reworks some parameters to make coherent the DMA
configuration now that AXI register is introduced.
For example, the burst_len is managed by using the mentioned axi
support above; so the snps,burst-len parameter has been removed.
It makes sense to provide the AAL parameter from DT to Address-Aligned
Beats inside the Register0 and review the PBL settings when initialize
the engine.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt   |   45 +++++++---
 drivers/net/ethernet/stmicro/stmmac/common.h       |    5 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    2 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |   99 +++++++++++++------
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |    2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |   34 +++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   12 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |    4 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   42 ++++++++-
 include/linux/stmmac.h                             |   17 +++-
 10 files changed, 204 insertions(+), 58 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index f34fc3c..36720d0 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -17,18 +17,6 @@ Required properties:
 	The 1st cell is reset pre-delay in micro seconds.
 	The 2nd cell is reset pulse in micro seconds.
 	The 3rd cell is reset post-delay in micro seconds.
-- snps,pbl		Programmable Burst Length
-- snps,fixed-burst	Program the DMA to use the fixed burst mode
-- snps,mixed-burst	Program the DMA to use the mixed burst mode
-- snps,force_thresh_dma_mode	Force DMA to use the threshold mode for
-				both tx and rx
-- snps,force_sf_dma_mode	Force DMA to use the Store and Forward
-				mode for both tx and rx. This flag is
-				ignored if force_thresh_dma_mode is set.
-- snps,multicast-filter-bins:	Number of multicast filter hash bins
-				supported by this device instance
-- snps,perfect-filter-entries:	Number of perfect filter entries supported
-				by this device instance
 
 Optional properties:
 - resets: Should contain a phandle to the STMMAC reset signal, if any
@@ -44,12 +32,42 @@ Optional properties:
   available this clock is used for programming the Timestamp Addend Register.
   If not passed then the system clock will be used and this is fine on some
   platforms.
-- snps,burst_len: The AXI burst lenth value of the AXI BUS MODE register.
 - tx-fifo-depth: See ethernet.txt file in the same directory
 - rx-fifo-depth: See ethernet.txt file in the same directory
+- snps,pbl		Programmable Burst Length
+- snps,aal		Address-Aligned Beats
+- snps,fixed-burst	Program the DMA to use the fixed burst mode
+- snps,mixed-burst	Program the DMA to use the mixed burst mode
+- snps,force_thresh_dma_mode	Force DMA to use the threshold mode for
+				both tx and rx
+- snps,force_sf_dma_mode	Force DMA to use the Store and Forward
+				mode for both tx and rx. This flag is
+				ignored if force_thresh_dma_mode is set.
+- snps,multicast-filter-bins:	Number of multicast filter hash bins
+				supported by this device instance
+- snps,perfect-filter-entries:	Number of perfect filter entries supported
+				by this device instance
+- AXI BUS Mode parameters: below the list of all the parameters to program the
+			   AXI register inside the DMA module:
+	- snps,lpi_en: enable Low Power Interface
+	- snps,xit_frm: unlock on WoL
+	- snps,wr_osr_lmt: max write oustanding req. limit
+	- snps,rd_osr_lmt: max read oustanding req. limit
+	- snps,kbbe: do not cross 1KiB boundary.
+	- snps,axi_all: align address
+	- snps,blen: this is a vector of supported burst length.
+	- snps,fb: fixed-burst
+	- snps,mb: mixed-burst
+	- snps,rb: rebuild INCRx Burst
 
 Examples:
 
+	stmmac_axi_setup: stmmac-axi-config {
+		snps,wr_osr_lmt = <0xf>;
+		snps,rd_osr_lmt = <0xf>;
+		snps,blen = <256 128 64 32 0 0 0>;
+	};
+
 	gmac0: ethernet@e0800000 {
 		compatible = "st,spear600-gmac";
 		reg = <0xe0800000 0x8000>;
@@ -65,4 +83,5 @@ Examples:
 		tx-fifo-depth = <16384>;
 		clocks = <&clock>;
 		clock-names = "stmmaceth";
+		snps,axi-config = <&stmmac_axi_setup>;
 	};
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index b4f4950..cdc3806 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -27,6 +27,7 @@
 
 #include <linux/etherdevice.h>
 #include <linux/netdevice.h>
+#include <linux/stmmac.h>
 #include <linux/phy.h>
 #include <linux/module.h>
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
@@ -378,7 +379,9 @@ struct stmmac_dma_ops {
 	/* DMA core initialization */
 	int (*reset)(void __iomem *ioaddr);
 	void (*init)(void __iomem *ioaddr, int pbl, int fb, int mb,
-		     int burst_len, u32 dma_tx, u32 dma_rx, int atds);
+		     int aal, u32 dma_tx, u32 dma_rx, int atds);
+	/* Configure the AXI Bus Mode Register */
+	void (*axi)(void __iomem *ioaddr, struct stmmac_axi *axi);
 	/* Dump DMA registers */
 	void (*dump_regs) (void __iomem *ioaddr);
 	/* Set tx/rx threshold in the csr6 register
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index 9d36ae7..b0593a4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -240,7 +240,7 @@ enum rx_tx_priority_ratio {
 #define DMA_BUS_MODE_RPBL_MASK	0x003e0000	/* Rx-Programmable Burst Len */
 #define DMA_BUS_MODE_RPBL_SHIFT	17
 #define DMA_BUS_MODE_USP	0x00800000
-#define DMA_BUS_MODE_PBL	0x01000000
+#define DMA_BUS_MODE_MAXPBL	0x01000000
 #define DMA_BUS_MODE_AAL	0x02000000
 
 /* DMA CRS Control and Status Register Mapping */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index 5f0aea5..da32d60 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -30,24 +30,76 @@
 #include "dwmac1000.h"
 #include "dwmac_dma.h"
 
+static void dwmac1000_dma_axi(void __iomem *ioaddr, struct stmmac_axi *axi)
+{
+	u32 value = readl(ioaddr + DMA_AXI_BUS_MODE);
+	int i;
+
+	pr_info("dwmac1000: Master AXI performs %s burst length\n",
+		!(value & DMA_AXI_UNDEF) ? "fixed" : "any");
+
+	if (axi->axi_lpi_en)
+		value |= DMA_AXI_EN_LPI;
+	if (axi->axi_xit_frm)
+		value |= DMA_AXI_LPI_XIT_FRM;
+
+	value |= (axi->axi_wr_osr_lmt & DMA_AXI_WR_OSR_LMT_MASK) <<
+		 DMA_AXI_WR_OSR_LMT_SHIFT;
+
+	value |= (axi->axi_rd_osr_lmt & DMA_AXI_RD_OSR_LMT_MASK) <<
+		 DMA_AXI_RD_OSR_LMT_SHIFT;
+
+	/* Depending on the UNDEF bit the Master AXI will perform any burst
+	 * length according to the BLEN programmed (by default all BLEN are
+	 * set).
+	 */
+	for (i = 0; i < AXI_BLEN; i++) {
+		switch (axi->axi_blen[i]) {
+		case 256:
+			value |= DMA_AXI_BLEN256;
+			break;
+		case 128:
+			value |= DMA_AXI_BLEN128;
+			break;
+		case 64:
+			value |= DMA_AXI_BLEN64;
+			break;
+		case 32:
+			value |= DMA_AXI_BLEN32;
+			break;
+		case 16:
+			value |= DMA_AXI_BLEN16;
+			break;
+		case 8:
+			value |= DMA_AXI_BLEN8;
+			break;
+		case 4:
+			value |= DMA_AXI_BLEN4;
+			break;
+		}
+	}
+
+	writel(value, ioaddr + DMA_AXI_BUS_MODE);
+}
+
 static void dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
-			       int burst_len, u32 dma_tx, u32 dma_rx, int atds)
+			       int aal, u32 dma_tx, u32 dma_rx, int atds)
 {
-	u32 value;
+	u32 value = readl(ioaddr + DMA_BUS_MODE);
 
 	/*
-	 * Set the DMA PBL (Programmable Burst Length) mode
-	 * Before stmmac core 3.50 this mode bit was 4xPBL, and
+	 * Set the DMA PBL (Programmable Burst Length) mode.
+	 *
+	 * Note: before stmmac core 3.50 this mode bit was 4xPBL, and
 	 * post 3.5 mode bit acts as 8*PBL.
-	 * For core rev < 3.5, when the core is set for 4xPBL mode, the
-	 * DMA transfers the data in 4, 8, 16, 32, 64 & 128 beats
-	 * depending on pbl value.
-	 * For core rev > 3.5, when the core is set for 8xPBL mode, the
-	 * DMA transfers the data in 8, 16, 32, 64, 128 & 256 beats
-	 * depending on pbl value.
+	 *
+	 * This configuration doesn't take care about the Separate PBL
+	 * so only the bits: 13-8 are programmed with the PBL passed from the
+	 * platform.
 	 */
-	value = DMA_BUS_MODE_PBL | ((pbl << DMA_BUS_MODE_PBL_SHIFT) |
-				    (pbl << DMA_BUS_MODE_RPBL_SHIFT));
+	value |= DMA_BUS_MODE_MAXPBL;
+	value &= ~DMA_BUS_MODE_PBL_MASK;
+	value |= (pbl << DMA_BUS_MODE_PBL_SHIFT);
 
 	/* Set the Fixed burst mode */
 	if (fb)
@@ -60,26 +112,10 @@ static void dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
 	if (atds)
 		value |= DMA_BUS_MODE_ATDS;
 
-	writel(value, ioaddr + DMA_BUS_MODE);
+	if (aal)
+		value |= DMA_BUS_MODE_AAL;
 
-	/* In case of GMAC AXI configuration, program the DMA_AXI_BUS_MODE
-	 * for supported bursts.
-	 *
-	 * Note: This is applicable only for revision GMACv3.61a. For
-	 * older version this register is reserved and shall have no
-	 * effect.
-	 *
-	 * Note:
-	 *  For Fixed Burst Mode: if we directly write 0xFF to this
-	 *  register using the configurations pass from platform code,
-	 *  this would ensure that all bursts supported by core are set
-	 *  and those which are not supported would remain ineffective.
-	 *
-	 *  For Non Fixed Burst Mode: provide the maximum value of the
-	 *  burst length. Any burst equal or below the provided burst
-	 *  length would be allowed to perform.
-	 */
-	writel(burst_len, ioaddr + DMA_AXI_BUS_MODE);
+	writel(value, ioaddr + DMA_BUS_MODE);
 
 	/* Mask interrupts by writing to CSR7 */
 	writel(DMA_INTR_DEFAULT_MASK, ioaddr + DMA_INTR_ENA);
@@ -192,6 +228,7 @@ static void dwmac1000_rx_watchdog(void __iomem *ioaddr, u32 riwt)
 const struct stmmac_dma_ops dwmac1000_dma_ops = {
 	.reset = dwmac_dma_reset,
 	.init = dwmac1000_dma_init,
+	.axi = dwmac1000_dma_axi,
 	.dump_regs = dwmac1000_dump_dma_regs,
 	.dma_mode = dwmac1000_dma_operation_mode,
 	.enable_dma_transmission = dwmac_enable_dma_transmission,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
index c40582a..61f54c9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
@@ -33,7 +33,7 @@
 #include "dwmac_dma.h"
 
 static void dwmac100_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
-			      int burst_len, u32 dma_tx, u32 dma_rx, int atds)
+			      int aal, u32 dma_tx, u32 dma_rx, int atds)
 {
 	/* Enable Application Access by writing to DMA CSR0 */
 	writel(DMA_BUS_MODE_DEFAULT | (pbl << DMA_BUS_MODE_PBL_SHIFT),
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
index 13ca90e..726d9d9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
@@ -41,8 +41,40 @@
 
 /* Rx watchdog register */
 #define DMA_RX_WATCHDOG		0x00001024
-/* AXI Bus Mode */
+
+/* AXI Master Bus Mode */
 #define DMA_AXI_BUS_MODE	0x00001028
+
+#define DMA_AXI_EN_LPI		BIT(31)
+#define DMA_AXI_LPI_XIT_FRM	BIT(30)
+#define DMA_AXI_WR_OSR_LMT	GENMASK(23, 20)
+#define DMA_AXI_WR_OSR_LMT_SHIFT	20
+#define DMA_AXI_WR_OSR_LMT_MASK	0xf
+#define DMA_AXI_RD_OSR_LMT	GENMASK(19, 16)
+#define DMA_AXI_RD_OSR_LMT_SHIFT	16
+#define DMA_AXI_RD_OSR_LMT_MASK	0xf
+
+#define DMA_AXI_OSR_MAX		0xf
+#define DMA_AXI_MAX_OSR_LIMIT ((DMA_AXI_OSR_MAX << DMA_AXI_WR_OSR_LMT_SHIFT) | \
+			       (DMA_AXI_OSR_MAX << DMA_AXI_RD_OSR_LMT_SHIFT))
+#define	DMA_AXI_1KBBE		BIT(13)
+#define DMA_AXI_AAL		BIT(12)
+#define DMA_AXI_BLEN256		BIT(7)
+#define DMA_AXI_BLEN128		BIT(6)
+#define DMA_AXI_BLEN64		BIT(5)
+#define DMA_AXI_BLEN32		BIT(4)
+#define DMA_AXI_BLEN16		BIT(3)
+#define DMA_AXI_BLEN8		BIT(2)
+#define DMA_AXI_BLEN4		BIT(1)
+#define DMA_BURST_LEN_DEFAULT	(DMA_AXI_BLEN256 | DMA_AXI_BLEN128 | \
+				 DMA_AXI_BLEN64 | DMA_AXI_BLEN32 | \
+				 DMA_AXI_BLEN16 | DMA_AXI_BLEN8 | \
+				 DMA_AXI_BLEN4)
+
+#define DMA_AXI_UNDEF		BIT(0)
+
+#define DMA_AXI_BURST_LEN_MASK	0x000000FE
+
 #define DMA_CUR_TX_BUF_ADDR	0x00001050	/* Current Host Tx Buffer */
 #define DMA_CUR_RX_BUF_ADDR	0x00001054	/* Current Host Rx Buffer */
 #define DMA_HW_FEATURE		0x00001058	/* HW Feature Register */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8b75c4b..2dd0279 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1638,7 +1638,7 @@ static void stmmac_check_ether_addr(struct stmmac_priv *priv)
  */
 static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 {
-	int pbl = DEFAULT_DMA_PBL, fixed_burst = 0, burst_len = 0;
+	int pbl = DEFAULT_DMA_PBL, fixed_burst = 0, aal = 0;
 	int mixed_burst = 0;
 	int atds = 0;
 	int ret = 0;
@@ -1647,7 +1647,7 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 		pbl = priv->plat->dma_cfg->pbl;
 		fixed_burst = priv->plat->dma_cfg->fixed_burst;
 		mixed_burst = priv->plat->dma_cfg->mixed_burst;
-		burst_len = priv->plat->dma_cfg->burst_len;
+		aal = priv->plat->dma_cfg->aal;
 	}
 
 	if (priv->extend_desc && (priv->mode == STMMAC_RING_MODE))
@@ -1660,8 +1660,12 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 	}
 
 	priv->hw->dma->init(priv->ioaddr, pbl, fixed_burst, mixed_burst,
-			    burst_len, priv->dma_tx_phy,
-			    priv->dma_rx_phy, atds);
+			    aal, priv->dma_tx_phy, priv->dma_rx_phy, atds);
+
+	if ((priv->synopsys_id >= DWMAC_CORE_3_50) &&
+	    (priv->plat->axi && priv->hw->dma->axi))
+		priv->hw->dma->axi(priv->ioaddr, priv->plat->axi);
+
 	return ret;
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index d71a721..ae43887 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -81,7 +81,7 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
 	plat->mdio_bus_data->phy_mask = 0;
 
 	plat->dma_cfg->pbl = 32;
-	plat->dma_cfg->burst_len = DMA_AXI_BLEN_256;
+	/* TODO: AXI */
 
 	/* Set default value for multicast hash bins */
 	plat->multicast_filter_bins = HASH_TABLE_SIZE;
@@ -115,8 +115,8 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
 	plat->mdio_bus_data->phy_mask = 0;
 
 	plat->dma_cfg->pbl = 16;
-	plat->dma_cfg->burst_len = DMA_AXI_BLEN_256;
 	plat->dma_cfg->fixed_burst = 1;
+	/* AXI (TODO) */
 
 	/* Set default value for multicast hash bins */
 	plat->multicast_filter_bins = HASH_TABLE_SIZE;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index d02691b..76cc581 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -96,6 +96,42 @@ static int dwmac1000_validate_ucast_entries(int ucast_entries)
 }
 
 /**
+ * stmmac_axi_setup - parse DT parameters for programming the AXI register
+ * @pdev: platform device
+ * @priv: driver private struct.
+ * Description:
+ * if required, from device-tree the AXI internal register can be tuned
+ * by using platform parameters.
+ */
+static struct stmmac_axi *stmmac_axi_setup(struct platform_device *pdev)
+{
+	struct device_node *np;
+	struct stmmac_axi *axi;
+
+	np = of_parse_phandle(pdev->dev.of_node, "snps,axi-config", 0);
+	if (!np)
+		return NULL;
+
+	axi = kzalloc(sizeof(axi), GFP_KERNEL);
+	if (!axi)
+		return ERR_PTR(-ENOMEM);
+
+	axi->axi_lpi_en = of_property_read_bool(np, "snps,lpi_en");
+	axi->axi_xit_frm = of_property_read_bool(np, "snps,xit_frm");
+	axi->axi_kbbe = of_property_read_bool(np, "snps,axi_kbbe");
+	axi->axi_axi_all = of_property_read_bool(np, "snps,axi_all");
+	axi->axi_fb = of_property_read_bool(np, "snps,axi_fb");
+	axi->axi_mb = of_property_read_bool(np, "snps,axi_mb");
+	axi->axi_rb =  of_property_read_bool(np, "snps,axi_rb");
+
+	of_property_read_u32(np, "snps,wr_osr_lmt", &axi->axi_wr_osr_lmt);
+	of_property_read_u32(np, "snps,rd_osr_lmt", &axi->axi_rd_osr_lmt);
+	of_property_read_u32_array(np, "snps,blen", axi->axi_blen, AXI_BLEN);
+
+	return axi;
+}
+
+/**
  * stmmac_probe_config_dt - parse device-tree driver parameters
  * @pdev: platform_device structure
  * @plat: driver data platform structure
@@ -216,13 +252,11 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 		}
 		plat->dma_cfg = dma_cfg;
 		of_property_read_u32(np, "snps,pbl", &dma_cfg->pbl);
+		dma_cfg->aal = of_property_read_bool(np, "snps,aal");
 		dma_cfg->fixed_burst =
 			of_property_read_bool(np, "snps,fixed-burst");
 		dma_cfg->mixed_burst =
 			of_property_read_bool(np, "snps,mixed-burst");
-		of_property_read_u32(np, "snps,burst_len", &dma_cfg->burst_len);
-		if (dma_cfg->burst_len < 0 || dma_cfg->burst_len > 256)
-			dma_cfg->burst_len = 0;
 	}
 	plat->force_thresh_dma_mode = of_property_read_bool(np, "snps,force_thresh_dma_mode");
 	if (plat->force_thresh_dma_mode) {
@@ -230,6 +264,8 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 		pr_warn("force_sf_dma_mode is ignored if force_thresh_dma_mode is set.");
 	}
 
+	plat->axi = stmmac_axi_setup(pdev);
+
 	return plat;
 }
 #else
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index eead8ab..6e53fa8 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -90,7 +90,21 @@ struct stmmac_dma_cfg {
 	int pbl;
 	int fixed_burst;
 	int mixed_burst;
-	int burst_len;
+	bool aal;
+};
+
+#define AXI_BLEN	7
+struct stmmac_axi {
+	bool axi_lpi_en;
+	bool axi_xit_frm;
+	u32 axi_wr_osr_lmt;
+	u32 axi_rd_osr_lmt;
+	bool axi_kbbe;
+	bool axi_axi_all;
+	u32 axi_blen[AXI_BLEN];
+	bool axi_fb;
+	bool axi_mb;
+	bool axi_rb;
 };
 
 struct plat_stmmacenet_data {
@@ -122,5 +136,6 @@ struct plat_stmmacenet_data {
 	int (*init)(struct platform_device *pdev, void *priv);
 	void (*exit)(struct platform_device *pdev, void *priv);
 	void *bsp_priv;
+	struct stmmac_axi *axi;
 };
 #endif
-- 
1.7.4.4
