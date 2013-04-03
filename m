From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 3/7] stmmac: review private structure fields
Date: Wed,  3 Apr 2013 07:41:25 +0200
Message-ID: <1364967689-11155-3-git-send-email-peppe.cavallaro@st.com>
References: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:55029 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762273Ab3DCFlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 01:41:53 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 109408A
	for <netdev@vger.kernel.org>; Wed,  3 Apr 2013 05:41:50 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 479932601
	for <netdev@vger.kernel.org>; Wed,  3 Apr 2013 05:41:50 +0000 (GMT)
In-Reply-To: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

recently many new supports have been added in the stmmac driver w/o taking care
about where each new field had to be placed inside the private structure for
guaranteeing the best cache usage.
This is what I wanted in the beginning, so this patch reorganizes all the fields
in order to keep adjacent fields for cache effect.
I have also tried to optimize them by using pahole.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h |   70 +++++++++++++-------------
 1 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 75f997b..8aa28c5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -35,36 +35,45 @@
 
 struct stmmac_priv {
 	/* Frequently used values are kept adjacent for cache effect */
-	struct dma_desc *dma_tx ____cacheline_aligned;	/* Basic TX desc */
-	struct dma_extended_desc *dma_etx;	/* Extended TX descriptor */
-	dma_addr_t dma_tx_phy;
-	struct sk_buff **tx_skbuff;
-	dma_addr_t *tx_skbuff_dma;
+	struct dma_extended_desc *dma_etx;
+	struct dma_desc *dma_tx ____cacheline_aligned_in_smp;
+	struct sk_buff **tx_skbuff ____cacheline_aligned_in_smp;
 	unsigned int cur_tx;
 	unsigned int dirty_tx;
 	unsigned int dma_tx_size;
+	u32 tx_count_frames;
+	u32 tx_coal_frames;
+	u32 tx_coal_timer;
+	dma_addr_t *tx_skbuff_dma;
+	dma_addr_t dma_tx_phy;
 	int tx_coalesce;
+	int hwts_tx_en;
+	spinlock_t tx_lock;
+	bool tx_path_in_lpi_mode;
+	struct timer_list txtimer;
 
-	struct dma_desc *dma_rx;		/* Basic RX descriptor */
-	struct dma_extended_desc *dma_erx;	/* Extended RX descriptor */
+	struct dma_desc *dma_rx	____cacheline_aligned_in_smp;
+	struct dma_extended_desc *dma_erx ____cacheline_aligned_in_smp;
+	struct sk_buff **rx_skbuff ____cacheline_aligned_in_smp;
 	unsigned int cur_rx;
 	unsigned int dirty_rx;
-	struct sk_buff **rx_skbuff;
+	unsigned int dma_rx_size;
+	unsigned int dma_buf_sz;
+	u32 rx_riwt;
+	int hwts_rx_en;
 	dma_addr_t *rx_skbuff_dma;
+	dma_addr_t dma_rx_phy;
 
+	struct napi_struct napi ____cacheline_aligned_in_smp;
+
+	void __iomem *ioaddr ____cacheline_aligned_in_smp;
 	struct net_device *dev;
-	dma_addr_t dma_rx_phy;
-	unsigned int dma_rx_size;
-	unsigned int dma_buf_sz;
 	struct device *device;
 	struct mac_device_info *hw;
-	void __iomem *ioaddr;
-
-	struct stmmac_extra_stats xstats;
-	struct napi_struct napi;
 	int no_csum_insertion;
+	spinlock_t lock;
 
-	struct phy_device *phydev;
+	struct phy_device *phydev ____cacheline_aligned_in_smp;
 	int oldlink;
 	int speed;
 	int oldduplex;
@@ -73,39 +82,30 @@ struct stmmac_priv {
 	struct mii_bus *mii;
 	int mii_irq[PHY_MAX_ADDR];
 
-	u32 msg_enable;
-	spinlock_t lock;
-	spinlock_t tx_lock;
-	int wolopts;
-	int wol_irq;
+	struct stmmac_extra_stats xstats ____cacheline_aligned_in_smp;
 	struct plat_stmmacenet_data *plat;
-	struct stmmac_counters mmc;
 	struct dma_features dma_cap;
+	struct stmmac_counters mmc;
 	int hw_cap_support;
+	int synopsys_id;
+	u32 msg_enable;
+	int wolopts;
+	int wol_irq;
 	struct clk *stmmac_clk;
 	int clk_csr;
-	int synopsys_id;
 	struct timer_list eee_ctrl_timer;
-	bool tx_path_in_lpi_mode;
 	int lpi_irq;
 	int eee_enabled;
 	int eee_active;
 	int tx_lpi_timer;
-	struct timer_list txtimer;
-	u32 tx_count_frames;
-	u32 tx_coal_frames;
-	u32 tx_coal_timer;
-	int use_riwt;
-	u32 rx_riwt;
+	int pcs;
 	unsigned int mode;
 	int extend_desc;
-	int pcs;
-	int hwts_tx_en;
-	int hwts_rx_en;
-	unsigned int default_addend;
-	u32 adv_ts;
 	struct ptp_clock *ptp_clock;
 	struct ptp_clock_info ptp_clock_ops;
+	unsigned int default_addend;
+	u32 adv_ts;
+	int use_riwt;
 	spinlock_t ptp_lock;
 };
 
-- 
1.7.4.4
