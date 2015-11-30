From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git)] stmmac: support Reg_9 to get HW level information
Date: Mon, 30 Nov 2015 11:33:10 +0100
Message-ID: <1448879590-3447-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:4727 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750818AbbK3KYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 05:24:47 -0500
Received: from pps.filterd (m0046037.ppops.net [127.0.0.1])
	by m0046037.ppops.net (8.14.5/8.14.5) with SMTP id tAUA6VxN015205
	for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 11:24:45 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by m0046037.ppops.net with ESMTP id 1ydn4bedff-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 11:24:45 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id DC16A3F
	for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 10:24:09 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas24.st.com [10.75.90.94])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6BC2F2BCF
	for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 10:24:43 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For GMAC newer than 3.40a there is a new register (Reg_9) that provides the
status of all modules of the transmit and receive paths and FIFO status.
These can be exposed via ethtool.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |   26 +++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |   42 +++++++++++
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   75 ++++++++++++++++++++
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   30 ++++++++
 4 files changed, 173 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 623c6ed..f4518bc 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -137,6 +137,31 @@ struct stmmac_extra_stats {
 	unsigned long pcs_link;
 	unsigned long pcs_duplex;
 	unsigned long pcs_speed;
+	/* debug register */
+	unsigned long mtl_tx_status_fifo_full;
+	unsigned long mtl_tx_fifo_not_empty;
+	unsigned long mmtl_fifo_ctrl;
+	unsigned long mtl_tx_fifo_read_ctrl_write;
+	unsigned long mtl_tx_fifo_read_ctrl_wait;
+	unsigned long mtl_tx_fifo_read_ctrl_read;
+	unsigned long mtl_tx_fifo_read_ctrl_idle;
+	unsigned long mac_tx_in_pause;
+	unsigned long mac_tx_frame_ctrl_xfer;
+	unsigned long mac_tx_frame_ctrl_idle;
+	unsigned long mac_tx_frame_ctrl_wait;
+	unsigned long mac_tx_frame_ctrl_pause;
+	unsigned long mac_gmii_tx_proto_engine;
+	unsigned long mtl_rx_fifo_fill_level_full;
+	unsigned long mtl_rx_fifo_fill_above_thresh;
+	unsigned long mtl_rx_fifo_fill_below_thresh;
+	unsigned long mtl_rx_fifo_fill_level_empty;
+	unsigned long mtl_rx_fifo_read_ctrl_flush;
+	unsigned long mtl_rx_fifo_read_ctrl_read_data;
+	unsigned long mtl_rx_fifo_read_ctrl_status;
+	unsigned long mtl_rx_fifo_read_ctrl_idle;
+	unsigned long mtl_rx_fifo_ctrl_active;
+	unsigned long mac_rx_frame_ctrl_fifo;
+	unsigned long mac_gmii_rx_proto_engine;
 };
 
 /* CSR Frequency Access Defines*/
@@ -408,6 +433,7 @@ struct stmmac_ops {
 	void (*set_eee_pls)(struct mac_device_info *hw, int link);
 	void (*ctrl_ane)(struct mac_device_info *hw, bool restart);
 	void (*get_adv)(struct mac_device_info *hw, struct rgmii_adv *adv);
+	void (*debug)(void __iomem *ioaddr, struct stmmac_extra_stats *x);
 };
 
 /* PTP and HW Timer helpers */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index b3fe057..8831a05 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -34,6 +34,7 @@
 #define GMAC_FLOW_CTRL		0x00000018	/* Flow Control */
 #define GMAC_VLAN_TAG		0x0000001c	/* VLAN Tag */
 #define GMAC_VERSION		0x00000020	/* GMAC CORE Version */
+#define GMAC_DEBUG		0x00000024	/* GMAC debug register */
 #define GMAC_WAKEUP_FILTER	0x00000028	/* Wake-up Frame Filter */
 
 #define GMAC_INT_STATUS		0x00000038	/* interrupt status register */
@@ -177,6 +178,47 @@ enum inter_frame_gap {
 #define GMAC_FLOW_CTRL_TFE	0x00000002	/* Tx Flow Control Enable */
 #define GMAC_FLOW_CTRL_FCB_BPA	0x00000001	/* Flow Control Busy ... */
 
+/* DEBUG Register defines */
+/* MTL TxStatus FIFO */
+#define GMAC_DEBUG_TXSTSFSTS	BIT(25)	/* MTL TxStatus FIFO Full Status */
+#define GMAC_DEBUG_TXFSTS	BIT(24) /* MTL Tx FIFO Not Empty Status */
+#define GMAC_DEBUG_TWCSTS	BIT(22) /* MTL Tx FIFO Write Controller */
+/* MTL Tx FIFO Read Controller Status */
+#define GMAC_DEBUG_TRCSTS_MASK	GENMASK(21, 20)
+#define GMAC_DEBUG_TRCSTS_SHIFT	20
+#define GMAC_DEBUG_TRCSTS_IDLE	0
+#define GMAC_DEBUG_TRCSTS_READ	1
+#define GMAC_DEBUG_TRCSTS_TXW	2
+#define GMAC_DEBUG_TRCSTS_WRITE	3
+#define GMAC_DEBUG_TXPAUSED	BIT(19) /* MAC Transmitter in PAUSE */
+/* MAC Transmit Frame Controller Status */
+#define GMAC_DEBUG_TFCSTS_MASK	GENMASK(18, 17)
+#define GMAC_DEBUG_TFCSTS_SHIFT	17
+#define GMAC_DEBUG_TFCSTS_IDLE	0
+#define GMAC_DEBUG_TFCSTS_WAIT	1
+#define GMAC_DEBUG_TFCSTS_GEN_PAUSE	2
+#define GMAC_DEBUG_TFCSTS_XFER	3
+/* MAC GMII or MII Transmit Protocol Engine Status */
+#define GMAC_DEBUG_TPESTS	BIT(16)
+#define GMAC_DEBUG_RXFSTS_MASK	GENMASK(9, 8) /* MTL Rx FIFO Fill-level */
+#define GMAC_DEBUG_RXFSTS_SHIFT	8
+#define GMAC_DEBUG_RXFSTS_EMPTY	0
+#define GMAC_DEBUG_RXFSTS_BT	1
+#define GMAC_DEBUG_RXFSTS_AT	2
+#define GMAC_DEBUG_RXFSTS_FULL	3
+#define GMAC_DEBUG_RRCSTS_MASK	GENMASK(6, 5) /* MTL Rx FIFO Read Controller */
+#define GMAC_DEBUG_RRCSTS_SHIFT	5
+#define GMAC_DEBUG_RRCSTS_IDLE	0
+#define GMAC_DEBUG_RRCSTS_RDATA	1
+#define GMAC_DEBUG_RRCSTS_RSTAT	2
+#define GMAC_DEBUG_RRCSTS_FLUSH	3
+#define GMAC_DEBUG_RWCSTS	BIT(4) /* MTL Rx FIFO Write Controller Active */
+/* MAC Receive Frame Controller FIFO Status */
+#define GMAC_DEBUG_RFCFCSTS_MASK	GENMASK(2, 1)
+#define GMAC_DEBUG_RFCFCSTS_SHIFT	1
+/* MAC GMII or MII Receive Protocol Engine Status */
+#define GMAC_DEBUG_RPESTS	BIT(0)
+
 /*--- DMA BLOCK defines ---*/
 /* DMA Bus Mode register defines */
 #define DMA_BUS_MODE_SFT_RESET	0x00000001	/* Software Reset */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index 371a669..c294117 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -397,6 +397,80 @@ static void dwmac1000_get_adv(struct mac_device_info *hw, struct rgmii_adv *adv)
 	adv->lp_pause = (value & GMAC_ANE_PSE) >> GMAC_ANE_PSE_SHIFT;
 }
 
+static void dwmac1000_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x)
+{
+	u32 value = readl(ioaddr + GMAC_DEBUG);
+
+	if (value & GMAC_DEBUG_TXSTSFSTS)
+		x->mtl_tx_status_fifo_full++;
+	if (value & GMAC_DEBUG_TXFSTS)
+		x->mtl_tx_fifo_not_empty++;
+	if (value & GMAC_DEBUG_TWCSTS)
+		x->mmtl_fifo_ctrl++;
+	if (value & GMAC_DEBUG_TRCSTS_MASK) {
+		u32 trcsts = (value & GMAC_DEBUG_TRCSTS_MASK)
+			     >> GMAC_DEBUG_TRCSTS_SHIFT;
+		if (trcsts == GMAC_DEBUG_TRCSTS_WRITE)
+			x->mtl_tx_fifo_read_ctrl_write++;
+		else if (trcsts == GMAC_DEBUG_TRCSTS_TXW)
+			x->mtl_tx_fifo_read_ctrl_wait++;
+		else if (trcsts == GMAC_DEBUG_TRCSTS_READ)
+			x->mtl_tx_fifo_read_ctrl_read++;
+		else
+			x->mtl_tx_fifo_read_ctrl_idle++;
+	}
+	if (value & GMAC_DEBUG_TXPAUSED)
+		x->mac_tx_in_pause++;
+	if (value & GMAC_DEBUG_TFCSTS_MASK) {
+		u32 tfcsts = (value & GMAC_DEBUG_TFCSTS_MASK)
+			      >> GMAC_DEBUG_TFCSTS_SHIFT;
+
+		if (tfcsts == GMAC_DEBUG_TFCSTS_XFER)
+			x->mac_tx_frame_ctrl_xfer++;
+		else if (tfcsts == GMAC_DEBUG_TFCSTS_GEN_PAUSE)
+			x->mac_tx_frame_ctrl_pause++;
+		else if (tfcsts == GMAC_DEBUG_TFCSTS_WAIT)
+			x->mac_tx_frame_ctrl_wait++;
+		else
+			x->mac_tx_frame_ctrl_idle++;
+	}
+	if (value & GMAC_DEBUG_TPESTS)
+		x->mac_gmii_tx_proto_engine++;
+	if (value & GMAC_DEBUG_RXFSTS_MASK) {
+		u32 rxfsts = (value & GMAC_DEBUG_RXFSTS_MASK)
+			     >> GMAC_DEBUG_RRCSTS_SHIFT;
+
+		if (rxfsts == GMAC_DEBUG_RXFSTS_FULL)
+			x->mtl_rx_fifo_fill_level_full++;
+		else if (rxfsts == GMAC_DEBUG_RXFSTS_AT)
+			x->mtl_rx_fifo_fill_above_thresh++;
+		else if (rxfsts == GMAC_DEBUG_RXFSTS_BT)
+			x->mtl_rx_fifo_fill_below_thresh++;
+		else
+			x->mtl_rx_fifo_fill_level_empty++;
+	}
+	if (value & GMAC_DEBUG_RRCSTS_MASK) {
+		u32 rrcsts = (value & GMAC_DEBUG_RRCSTS_MASK) >>
+			     GMAC_DEBUG_RRCSTS_SHIFT;
+
+		if (rrcsts == GMAC_DEBUG_RRCSTS_FLUSH)
+			x->mtl_rx_fifo_read_ctrl_flush++;
+		else if (rrcsts == GMAC_DEBUG_RRCSTS_RSTAT)
+			x->mtl_rx_fifo_read_ctrl_read_data++;
+		else if (rrcsts == GMAC_DEBUG_RRCSTS_RDATA)
+			x->mtl_rx_fifo_read_ctrl_status++;
+		else
+			x->mtl_rx_fifo_read_ctrl_idle++;
+	}
+	if (value & GMAC_DEBUG_RWCSTS)
+		x->mtl_rx_fifo_ctrl_active++;
+	if (value & GMAC_DEBUG_RFCFCSTS_MASK)
+		x->mac_rx_frame_ctrl_fifo = (value & GMAC_DEBUG_RFCFCSTS_MASK)
+					    >> GMAC_DEBUG_RFCFCSTS_SHIFT;
+	if (value & GMAC_DEBUG_RPESTS)
+		x->mac_gmii_rx_proto_engine++;
+}
+
 static const struct stmmac_ops dwmac1000_ops = {
 	.core_init = dwmac1000_core_init,
 	.rx_ipc = dwmac1000_rx_ipc_enable,
@@ -413,6 +487,7 @@ static const struct stmmac_ops dwmac1000_ops = {
 	.set_eee_pls = dwmac1000_set_eee_pls,
 	.ctrl_ane = dwmac1000_ctrl_ane,
 	.get_adv = dwmac1000_get_adv,
+	.debug = dwmac1000_debug,
 };
 
 struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 2e51b81..4c6486c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -136,6 +136,31 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(irq_pcs_ane_n),
 	STMMAC_STAT(irq_pcs_link_n),
 	STMMAC_STAT(irq_rgmii_n),
+	/* DEBUG */
+	STMMAC_STAT(mtl_tx_status_fifo_full),
+	STMMAC_STAT(mtl_tx_fifo_not_empty),
+	STMMAC_STAT(mmtl_fifo_ctrl),
+	STMMAC_STAT(mtl_tx_fifo_read_ctrl_write),
+	STMMAC_STAT(mtl_tx_fifo_read_ctrl_wait),
+	STMMAC_STAT(mtl_tx_fifo_read_ctrl_read),
+	STMMAC_STAT(mtl_tx_fifo_read_ctrl_idle),
+	STMMAC_STAT(mac_tx_in_pause),
+	STMMAC_STAT(mac_tx_frame_ctrl_xfer),
+	STMMAC_STAT(mac_tx_frame_ctrl_idle),
+	STMMAC_STAT(mac_tx_frame_ctrl_wait),
+	STMMAC_STAT(mac_tx_frame_ctrl_pause),
+	STMMAC_STAT(mac_gmii_tx_proto_engine),
+	STMMAC_STAT(mtl_rx_fifo_fill_level_full),
+	STMMAC_STAT(mtl_rx_fifo_fill_above_thresh),
+	STMMAC_STAT(mtl_rx_fifo_fill_below_thresh),
+	STMMAC_STAT(mtl_rx_fifo_fill_level_empty),
+	STMMAC_STAT(mtl_rx_fifo_read_ctrl_flush),
+	STMMAC_STAT(mtl_rx_fifo_read_ctrl_read_data),
+	STMMAC_STAT(mtl_rx_fifo_read_ctrl_status),
+	STMMAC_STAT(mtl_rx_fifo_read_ctrl_idle),
+	STMMAC_STAT(mtl_rx_fifo_ctrl_active),
+	STMMAC_STAT(mac_rx_frame_ctrl_fifo),
+	STMMAC_STAT(mac_gmii_rx_proto_engine),
 };
 #define STMMAC_STATS_LEN ARRAY_SIZE(stmmac_gstrings_stats)
 
@@ -497,6 +522,11 @@ static void stmmac_get_ethtool_stats(struct net_device *dev,
 			if (val)
 				priv->xstats.phy_eee_wakeup_error_n = val;
 		}
+
+		if ((priv->hw->mac->debug) &&
+		    (priv->synopsys_id >= DWMAC_CORE_3_50))
+			priv->hw->mac->debug(priv->ioaddr,
+					     (void *)&priv->xstats);
 	}
 	for (i = 0; i < STMMAC_STATS_LEN; i++) {
 		char *p = (char *)priv + stmmac_gstrings_stats[i].stat_offset;
-- 
1.7.4.4
