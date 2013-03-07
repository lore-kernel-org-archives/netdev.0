From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 3/9] stmmac: support extend descriptors
Date: Thu,  7 Mar 2013 11:50:13 +0100
Message-ID: <1362653419-1047-4-git-send-email-peppe.cavallaro@st.com>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Cc: bh74.an@samsung.com, ayagond@vayavyalabs.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Rayagond Kokatanur <rayagond@vayavyalabs.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from beta.dmz-us.st.com ([167.4.1.35]:56695 "EHLO beta.dmz-us.st.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932693Ab3CGLrJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 06:47:09 -0500
In-Reply-To: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new driver Koption to support the
extend descriptors available in the chips newer than
the 3.50. In case of the extend descriptors cannot be
supported, at runtime, the probe function will fail.
This support extends the descriptor structure adding
the desc 4, 5, 6, 7 and give us extra information about
the received ethernet payload when it is carrying PTP
packets or TCP/UDP/ICMP over IP packets.
This introduce a small overhead in the receive process
so actually useful to debug and tack some important
fields in the descriptors.
Moreover, this support will be mandatory to have the
PTP version 2 where the extra descriptors 6 and 7
will be used to save the timestamp on enhanced
descriptor structure.

Thanks to Rayagond Kokatanur that sent me some parts
of this code inside the PTPv2 patches.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Rayagond Kokatanur <rayagond@vayavyalabs.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   13 +++++
 drivers/net/ethernet/stmicro/stmmac/common.h       |   29 +++++++++-
 drivers/net/ethernet/stmicro/stmmac/descs.h        |   47 +++++++++++++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    1 +
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |    8 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |    4 +-
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |   58 +++++++++++++++++++-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    1 +
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   25 +++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   38 ++++++++++---
 11 files changed, 206 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index ef703b3..4fa974c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -83,4 +83,17 @@ config STMMAC_USE_HWSTAMP
 	  register will be used to verify if either the IEEE 1588-2008 Advanced
 	  Timestamping (PTPv2) or IEEE 1588-2002 (PTPv1) is actually supported.
 
+config STMMAC_EXTENDED_DESC
+	bool "Enable Extended descriptors (DES4-5-6-7)"
+	depends on STMMAC_ETH
+	default n
+	---help---
+	  This option enhances the descriptors to support the extended status
+	  that gives some information about the receive Ethernet payload when
+	  it is carrying PTP  packets or TCP/UDP/ICMP over IP.
+	  This option cannot be used on GMAC Synopsys older than the 3.50
+	  so the driver's probe will fail in this scenario.
+	  This option also is mandatory for PTPv2 because the extra descriptors
+	  are used for saving timestamps.
+
 endif
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index fa8ff9b..df7123a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -117,6 +117,31 @@ struct stmmac_extra_stats {
 	unsigned long irq_rx_path_in_lpi_mode_n;
 	unsigned long irq_rx_path_exit_lpi_mode_n;
 	unsigned long phy_eee_wakeup_error_n;
+#ifdef CONFIG_STMMAC_EXTENDED_DESC
+	/* Extended RDES status */
+	unsigned long ip_hdr_err;
+	unsigned long ip_payload_err;
+	unsigned long ip_csum_bypassed;
+	unsigned long ipv4_pkt_rcvd;
+	unsigned long ipv6_pkt_rcvd;
+	unsigned long rx_msg_type_ext_no_ptp;
+	unsigned long rx_msg_type_sync;
+	unsigned long rx_msg_type_follow_up;
+	unsigned long rx_msg_type_delay_req;
+	unsigned long rx_msg_type_delay_resp;
+	unsigned long rx_msg_type_pdelay_req;
+	unsigned long rx_msg_type_pdelay_resp;
+	unsigned long rx_msg_type_pdelay_follow_up;
+	unsigned long ptp_frame_type;
+	unsigned long ptp_ver;
+	unsigned long timestamp_dropped;
+	unsigned long av_pkt_rcvd;
+	unsigned long av_tagged_pkt_rcvd;
+	unsigned long vlan_tag_priority_val;
+	unsigned long l3_filter_match;
+	unsigned long l4_filter_match;
+	unsigned long l3_l4_filter_no_match;
+#endif /* CONFIG_STMMAC_EXTENDED_DESC */
 };
 
 /* CSR Frequency Access Defines*/
@@ -289,7 +314,7 @@ struct stmmac_desc_ops {
 	int (*get_rx_frame_len) (struct dma_desc *p, int rx_coe_type);
 	/* Return the reception status looking at the RDES1 */
 	int (*rx_status) (void *data, struct stmmac_extra_stats *x,
-			  struct dma_desc *p);
+			  struct dma_desc *p, int atds);
 	/* Set tx timestamp enable bit */
 	void (*enable_tx_timestamp) (struct dma_desc *p);
 	/* get tx timestamp status */
@@ -305,7 +330,7 @@ struct stmmac_desc_ops {
 struct stmmac_dma_ops {
 	/* DMA core initialization */
 	int (*init) (void __iomem *ioaddr, int pbl, int fb, int mb,
-		     int burst_len, u32 dma_tx, u32 dma_rx);
+		     int burst_len, u32 dma_tx, u32 dma_rx, int atds);
 	/* Dump DMA registers */
 	void (*dump_regs) (void __iomem *ioaddr);
 	/* Set tx/rx threshold in the csr6 register
diff --git a/drivers/net/ethernet/stmicro/stmmac/descs.h b/drivers/net/ethernet/stmicro/stmmac/descs.h
index 223adf9..c3e8fe4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/descs.h
+++ b/drivers/net/ethernet/stmicro/stmmac/descs.h
@@ -60,7 +60,7 @@ struct dma_desc {
 		} rx;
 		struct {
 			/* RDES0 */
-			u32 payload_csum_error:1;
+			u32 rx_mac_addr:1;
 			u32 crc_error:1;
 			u32 dribbling:1;
 			u32 error_gmii:1;
@@ -160,15 +160,56 @@ struct dma_desc {
 	} des01;
 	unsigned int des2;
 	unsigned int des3;
+#ifdef CONFIG_STMMAC_EXTENDED_DESC
+	union {
+		struct {
+			u32 ip_payload_type:3;
+			u32 ip_hdr_err:1;
+			u32 ip_payload_err:1;
+			u32 ip_csum_bypassed:1;
+			u32 ipv4_pkt_rcvd:1;
+			u32 ipv6_pkt_rcvd:1;
+			u32 msg_type:4;
+			u32 ptp_frame_type:1;
+			u32 ptp_ver:1;
+			u32 timestamp_dropped:1;
+			u32 reserved:1;
+			u32 av_pkt_rcvd:1;
+			u32 av_tagged_pkt_rcvd:1;
+			u32 vlan_tag_priority_val:3;
+			u32 reserved3:3;
+			u32 l3_filter_match:1;
+			u32 l4_filter_match:1;
+			u32 l3_l4_filter_no_match:2;
+			u32 reserved4:4;
+		} erx;
+		struct {
+			u32 reserved;
+		} etx;
+	} des4;
+	unsigned int des5; /* Reserved */
+	unsigned int des6; /* Tx/Rx Timestamp Low */
+	unsigned int des7; /* Tx/Rx Timestamp High */
+#endif /* CONFIG_STMMAC_EXTENDED_DESC */
 };
 
 /* Transmit checksum insertion control */
 enum tdes_csum_insertion {
 	cic_disabled = 0,	/* Checksum Insertion Control */
 	cic_only_ip = 1,	/* Only IP header */
-	cic_no_pseudoheader = 2,	/* IP header but pseudoheader
-					 * is not calculated */
+	/* IP header but pseudoheader is not calculated */
+	cic_no_pseudoheader = 2,
 	cic_full = 3,		/* IP header and pseudoheader */
 };
 
+/* Extended RDES4 definitions */
+#define RDES_EXT_NO_PTP			0
+#define RDES_EXT_SYNC			0x1
+#define RDES_EXT_FOLLOW_UP		0x2
+#define RDES_EXT_DELAY_REQ		0x3
+#define RDES_EXT_DELAY_RESP		0x4
+#define RDES_EXT_PDELAY_REQ		0x5
+#define RDES_EXT_PDELAY_RESP		0x6
+#define RDES_EXT_PDELAY_FOLLOW_UP	0x7
+
 #endif /* __DESCS_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index 7ad56af..85466e5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -155,6 +155,7 @@ enum inter_frame_gap {
 /* Programmable burst length (passed thorugh platform)*/
 #define DMA_BUS_MODE_PBL_MASK	0x00003f00	/* Programmable Burst Len */
 #define DMA_BUS_MODE_PBL_SHIFT	8
+#define DMA_BUS_MODE_ATDS	0x00000080	/* Alternate Descriptor Size */
 
 enum rx_tx_priority_ratio {
 	double_ratio = 0x00004000,	/*2:1 */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index bf83c03..f1c4b2c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -30,8 +30,8 @@
 #include "dwmac1000.h"
 #include "dwmac_dma.h"
 
-static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb,
-			      int mb, int burst_len, u32 dma_tx, u32 dma_rx)
+static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
+			      int burst_len, u32 dma_tx, u32 dma_rx, int atds)
 {
 	u32 value = readl(ioaddr + DMA_BUS_MODE);
 	int limit;
@@ -73,6 +73,10 @@ static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb,
 #ifdef CONFIG_STMMAC_DA
 	value |= DMA_BUS_MODE_DA;	/* Rx has priority over tx */
 #endif
+
+	if (atds)
+		value |= DMA_BUS_MODE_ATDS;
+
 	writel(value, ioaddr + DMA_BUS_MODE);
 
 	/* In case of GMAC AXI configuration, program the DMA_AXI_BUS_MODE
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
index c2b4d55..e979a8b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
@@ -32,8 +32,8 @@
 #include "dwmac100.h"
 #include "dwmac_dma.h"
 
-static int dwmac100_dma_init(void __iomem *ioaddr, int pbl, int fb,
-			     int mb, int burst_len, u32 dma_tx, u32 dma_rx)
+static int dwmac100_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
+			     int burst_len, u32 dma_tx, u32 dma_rx, int atds)
 {
 	u32 value = readl(ioaddr + DMA_BUS_MODE);
 	int limit;
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index 4d635d5..50707c5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -150,8 +150,9 @@ static int enh_desc_coe_rdes0(int ipc_err, int type, int payload_err)
 	return ret;
 }
 
+
 static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
-				  struct dma_desc *p)
+				  struct dma_desc *p, int atds)
 {
 	int ret = good_frame;
 	struct net_device_stats *stats = (struct net_device_stats *)data;
@@ -198,7 +199,7 @@ static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 	 * At any rate, we need to understand if the CSUM hw computation is ok
 	 * and report this info to the upper layers. */
 	ret = enh_desc_coe_rdes0(p->des01.erx.ipc_csum_error,
-		p->des01.erx.frame_type, p->des01.erx.payload_csum_error);
+		p->des01.erx.frame_type, p->des01.erx.rx_mac_addr);
 
 	if (unlikely(p->des01.erx.dribbling)) {
 		CHIP_DBG(KERN_ERR "GMAC RX: dribbling error\n");
@@ -225,6 +226,59 @@ static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 		x->rx_vlan++;
 	}
 #endif
+
+#ifdef CONFIG_STMMAC_EXTENDED_DESC
+	/* On new chips the RDES0[0] is used for looking at the RDES4;
+	 * note that atds won't be set for ID older than 3.50.
+	 */
+	if (unlikely((atds) && (p->des01.erx.rx_mac_addr))) {
+		if (p->des4.erx.ip_hdr_err)
+			x->ip_hdr_err++;
+		if (p->des4.erx.ip_payload_err)
+			x->ip_payload_err++;
+		if (p->des4.erx.ip_csum_bypassed)
+			x->ip_csum_bypassed++;
+		if (p->des4.erx.ipv4_pkt_rcvd)
+			x->ipv4_pkt_rcvd++;
+		if (p->des4.erx.ipv6_pkt_rcvd)
+			x->ipv6_pkt_rcvd++;
+		if (p->des4.erx.msg_type == RDES_EXT_SYNC)
+			x->rx_msg_type_sync++;
+		else if (p->des4.erx.msg_type == RDES_EXT_FOLLOW_UP)
+			x->rx_msg_type_follow_up++;
+		else if (p->des4.erx.msg_type == RDES_EXT_DELAY_REQ)
+			x->rx_msg_type_delay_req++;
+		else if (p->des4.erx.msg_type == RDES_EXT_DELAY_RESP)
+			x->rx_msg_type_delay_resp++;
+		else if (p->des4.erx.msg_type == RDES_EXT_DELAY_REQ)
+			x->rx_msg_type_pdelay_req++;
+		else if (p->des4.erx.msg_type == RDES_EXT_PDELAY_RESP)
+			x->rx_msg_type_pdelay_resp++;
+		else if (p->des4.erx.msg_type == RDES_EXT_PDELAY_FOLLOW_UP)
+			x->rx_msg_type_pdelay_follow_up++;
+		else
+			x->rx_msg_type_ext_no_ptp++;
+		if (p->des4.erx.ptp_frame_type)
+			x->ptp_frame_type++;
+		if (p->des4.erx.ptp_ver)
+			x->ptp_ver++;
+		if (p->des4.erx.timestamp_dropped)
+			x->timestamp_dropped++;
+		if (p->des4.erx.av_pkt_rcvd)
+			x->av_pkt_rcvd++;
+		if (p->des4.erx.av_tagged_pkt_rcvd)
+			x->av_tagged_pkt_rcvd++;
+		if (p->des4.erx.vlan_tag_priority_val)
+			x->vlan_tag_priority_val++;
+		if (p->des4.erx.l3_filter_match)
+			x->l3_filter_match++;
+		if (p->des4.erx.l4_filter_match)
+			x->l4_filter_match++;
+		if (p->des4.erx.l3_l4_filter_no_match)
+			x->l3_l4_filter_no_match++;
+	}
+#endif /* CONFIG_STMMAC_EXTENDED_DESC */
+
 	return ret;
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index edb5e88..9eefb6c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -73,7 +73,7 @@ static int ndesc_get_tx_len(struct dma_desc *p)
  * In case of success, it returns good_frame because the GMAC device
  * is supposed to be able to compute the csum in HW. */
 static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
-			       struct dma_desc *p)
+			       struct dma_desc *p, int atds)
 {
 	int ret = good_frame;
 	struct net_device_stats *stats = (struct net_device_stats *)data;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 665f2a2..50b5f26 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -99,6 +99,7 @@ struct stmmac_priv {
 	int hwts_rx_en;
 	unsigned int default_addend;
 #endif
+	int atds;
 };
 
 extern int phyaddr;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index d1ac39c..5698bf3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -108,6 +108,31 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(irq_rx_path_in_lpi_mode_n),
 	STMMAC_STAT(irq_rx_path_exit_lpi_mode_n),
 	STMMAC_STAT(phy_eee_wakeup_error_n),
+#ifdef CONFIG_STMMAC_EXTENDED_DESC
+	/* Extended RDES status */
+	STMMAC_STAT(ip_hdr_err),
+	STMMAC_STAT(ip_payload_err),
+	STMMAC_STAT(ip_csum_bypassed),
+	STMMAC_STAT(ipv4_pkt_rcvd),
+	STMMAC_STAT(ipv6_pkt_rcvd),
+	STMMAC_STAT(rx_msg_type_ext_no_ptp),
+	STMMAC_STAT(rx_msg_type_sync),
+	STMMAC_STAT(rx_msg_type_follow_up),
+	STMMAC_STAT(rx_msg_type_delay_req),
+	STMMAC_STAT(rx_msg_type_delay_resp),
+	STMMAC_STAT(rx_msg_type_pdelay_req),
+	STMMAC_STAT(rx_msg_type_pdelay_resp),
+	STMMAC_STAT(rx_msg_type_pdelay_follow_up),
+	STMMAC_STAT(ptp_frame_type),
+	STMMAC_STAT(ptp_ver),
+	STMMAC_STAT(timestamp_dropped),
+	STMMAC_STAT(av_pkt_rcvd),
+	STMMAC_STAT(av_tagged_pkt_rcvd),
+	STMMAC_STAT(vlan_tag_priority_val),
+	STMMAC_STAT(l3_filter_match),
+	STMMAC_STAT(l4_filter_match),
+	STMMAC_STAT(l3_l4_filter_no_match),
+#endif /* CONFIG_STMMAC_EXTENDED_DESC */
 };
 #define STMMAC_STATS_LEN ARRAY_SIZE(stmmac_gstrings_stats)
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 3bbd554..6174f34 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1058,15 +1058,29 @@ static u32 stmmac_get_synopsys_id(struct stmmac_priv *priv)
  * @priv : private structure
  * Description: select the Enhanced/Alternate or Normal descriptors
  */
-static void stmmac_selec_desc_mode(struct stmmac_priv *priv)
+static int stmmac_selec_desc_mode(struct stmmac_priv *priv)
 {
+	int ret = 0;
+
 	if (priv->plat->enh_desc) {
 		pr_info(" Enhanced/Alternate descriptors\n");
+#ifdef CONFIG_STMMAC_EXTENDED_DESC
+		/* GMAC older than 3.50 has no extended descriptors */
+		if (priv->synopsys_id >= DWMAC_CORE_3_50) {
+			pr_info("\tEnabled extended descriptors\n");
+			priv->atds = 1;
+		} else {
+			pr_err("ERROR: cannot support extended descriptors\n");
+			ret = -EOPNOTSUPP;
+		}
+#endif
 		priv->hw->desc = &enh_desc_ops;
 	} else {
 		pr_info(" Normal descriptors\n");
 		priv->hw->desc = &ndesc_ops;
 	}
+
+	return ret;
 }
 
 /**
@@ -1161,7 +1175,7 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 
 	return priv->hw->dma->init(priv->ioaddr, pbl, fixed_burst, mixed_burst,
 				   burst_len, priv->dma_tx_phy,
-				   priv->dma_rx_phy);
+				   priv->dma_rx_phy, priv->atds);
 }
 
 /**
@@ -1602,7 +1616,8 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 
 		/* read the status of the incoming frame */
 		status = (priv->hw->desc->rx_status(&priv->dev->stats,
-						    &priv->xstats, p));
+						    &priv->xstats, p,
+						    priv->atds));
 		if (unlikely(status == discard_frame)) {
 			priv->dev->stats.rx_errors++;
 #ifdef CONFIG_STMMAC_USE_HWSTAMP
@@ -2117,7 +2132,7 @@ static const struct net_device_ops stmmac_netdev_ops = {
  */
 static int stmmac_hw_init(struct stmmac_priv *priv)
 {
-	int ret = 0;
+	int ret;
 	struct mac_device_info *mac;
 
 	/* Identify the MAC HW device */
@@ -2161,8 +2176,12 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 	} else
 		pr_info(" No HW DMA feature register supported");
 
-	/* Select the enhnaced/normal descriptor structures */
-	stmmac_selec_desc_mode(priv);
+	/* Select the enhnaced/normal descriptor structures and return
+	 * EOPNOTSUPP in case of failing.
+	 */
+	ret = stmmac_selec_desc_mode(priv);
+	if (ret)
+		return ret;
 
 	/* Enable the IPC (Checksum Offload) and check if the feature has been
 	 * enabled during the core configuration. */
@@ -2183,7 +2202,7 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 		device_set_wakeup_capable(priv->device, 1);
 	}
 
-	return ret;
+	return 0;
 }
 
 /**
@@ -2229,7 +2248,9 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 		priv->plat->phy_addr = phyaddr;
 
 	/* Init MAC and get the capabilities */
-	stmmac_hw_init(priv);
+	ret = stmmac_hw_init(priv);
+	if (ret)
+		goto error_free_netdev;
 
 	ndev->netdev_ops = &stmmac_netdev_ops;
 
@@ -2300,6 +2321,7 @@ error_clk_get:
 	unregister_netdev(ndev);
 error_netdev_register:
 	netif_napi_del(&priv->napi);
+error_free_netdev:
 	free_netdev(ndev);
 
 	return NULL;
-- 
1.7.4.4
