From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 2/8 (v2)] stmmac: support extend descriptors
Date: Tue, 26 Mar 2013 15:43:06 +0100
Message-ID: <1364308992-27929-3-git-send-email-peppe.cavallaro@st.com>
References: <1364308992-27929-1-git-send-email-peppe.cavallaro@st.com>
Cc: rayagond@vayavyalabs.com, richardcochran@gmail.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:39195 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933525Ab3CZOok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 10:44:40 -0400
In-Reply-To: <1364308992-27929-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to support the extend descriptors available
in the chips newer than the 3.50.

In case of the extend descriptors cannot be supported,
at runtime, the driver will continue to work using the old style.

In detail, this support extends the main descriptor structure
adding new descriptors: 4, 5, 6, 7. The desc4 gives us extra
information about the received ethernet payload when it is
carrying PTP packets or TCP/UDP/ICMP over IP packets.
The descriptors 6 and 7 are used for saving HW L/H timestamps (PTP).

V2: this new version removes the Koption added in the first implementation
because all the checks now to verify if the extended descriptors are
actually supported happen at probe time.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |   29 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   38 ++-
 drivers/net/ethernet/stmicro/stmmac/descs.h        |   51 +++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    1 +
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |    8 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |    4 +-
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |   97 +++--
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |   45 +--
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    7 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   23 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  443 ++++++++++++++------
 11 files changed, 528 insertions(+), 218 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index 08ff51e..688c3f4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -89,27 +89,38 @@ static unsigned int stmmac_is_jumbo_frm(int len, int enh_desc)
 	return ret;
 }
 
-static void stmmac_init_dma_chain(struct dma_desc *des, dma_addr_t phy_addr,
-				  unsigned int size)
+static void stmmac_init_dma_chain(void *des, dma_addr_t phy_addr,
+				  unsigned int size, unsigned int extend_desc)
 {
 	/*
 	 * In chained mode the des3 points to the next element in the ring.
 	 * The latest element has to point to the head.
 	 */
 	int i;
-	struct dma_desc *p = des;
 	dma_addr_t dma_phy = phy_addr;
 
-	for (i = 0; i < (size - 1); i++) {
-		dma_phy += sizeof(struct dma_desc);
-		p->des3 = (unsigned int)dma_phy;
-		p++;
+	if (extend_desc) {
+		struct dma_extended_desc *p = (struct dma_extended_desc *) des;
+		for (i = 0; i < (size - 1); i++) {
+			dma_phy += sizeof(struct dma_extended_desc);
+			p->basic.des3 = (unsigned int)dma_phy;
+			p++;
+		}
+		p->basic.des3 = (unsigned int)phy_addr;
+
+	} else {
+		struct dma_desc *p = (struct dma_desc *) des;
+		for (i = 0; i < (size - 1); i++) {
+			dma_phy += sizeof(struct dma_desc);
+			p->des3 = (unsigned int)dma_phy;
+			p++;
+		}
+		p->des3 = (unsigned int)phy_addr;
 	}
-	p->des3 = (unsigned int)phy_addr;
 }
 
 const struct stmmac_chain_mode_ops chain_mode_ops = {
+	.init = stmmac_init_dma_chain,
 	.is_jumbo_frm = stmmac_is_jumbo_frm,
 	.jumbo_frm = stmmac_jumbo_frm,
-	.init_dma_chain = stmmac_init_dma_chain,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index a295532..8a04b7f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -117,6 +117,29 @@ struct stmmac_extra_stats {
 	unsigned long irq_rx_path_in_lpi_mode_n;
 	unsigned long irq_rx_path_exit_lpi_mode_n;
 	unsigned long phy_eee_wakeup_error_n;
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
 };
 
 /* CSR Frequency Access Defines*/
@@ -260,11 +283,10 @@ struct dma_features {
 
 struct stmmac_desc_ops {
 	/* DMA RX descriptor ring initialization */
-	void (*init_rx_desc) (struct dma_desc *p, unsigned int ring_size,
-			      int disable_rx_ic, int mode);
+	void (*init_rx_desc) (struct dma_desc *p, int disable_rx_ic, int mode,
+			      int end);
 	/* DMA TX descriptor ring initialization */
-	void (*init_tx_desc) (struct dma_desc *p, unsigned int ring_size,
-			      int mode);
+	void (*init_tx_desc) (struct dma_desc *p, int mode, int end);
 
 	/* Invoked by the xmit function to prepare the tx descriptor */
 	void (*prepare_tx_desc) (struct dma_desc *p, int is_fs, int len,
@@ -294,12 +316,14 @@ struct stmmac_desc_ops {
 	/* Return the reception status looking at the RDES1 */
 	int (*rx_status) (void *data, struct stmmac_extra_stats *x,
 			  struct dma_desc *p);
+	void (*rx_extended_status) (void *data, struct stmmac_extra_stats *x,
+				    struct dma_extended_desc *p);
 };
 
 struct stmmac_dma_ops {
 	/* DMA core initialization */
 	int (*init) (void __iomem *ioaddr, int pbl, int fb, int mb,
-		     int burst_len, u32 dma_tx, u32 dma_rx);
+		     int burst_len, u32 dma_tx, u32 dma_rx, int atds);
 	/* Dump DMA registers */
 	void (*dump_regs) (void __iomem *ioaddr);
 	/* Set tx/rx threshold in the csr6 register
@@ -371,10 +395,10 @@ struct stmmac_ring_mode_ops {
 };
 
 struct stmmac_chain_mode_ops {
+	void (*init) (void *des, dma_addr_t phy_addr, unsigned int size,
+		      unsigned int extend_desc);
 	unsigned int (*is_jumbo_frm) (int len, int ehn_desc);
 	unsigned int (*jumbo_frm) (void *priv, struct sk_buff *skb, int csum);
-	void (*init_dma_chain) (struct dma_desc *des, dma_addr_t phy_addr,
-				unsigned int size);
 };
 
 struct mac_device_info {
diff --git a/drivers/net/ethernet/stmicro/stmmac/descs.h b/drivers/net/ethernet/stmicro/stmmac/descs.h
index 223adf9..2eca0c0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/descs.h
+++ b/drivers/net/ethernet/stmicro/stmmac/descs.h
@@ -24,6 +24,7 @@
 #ifndef __DESCS_H__
 #define __DESCS_H__
 
+/* Basic descriptor structure for normal and alternate descriptors */
 struct dma_desc {
 	/* Receive descriptor */
 	union {
@@ -60,7 +61,7 @@ struct dma_desc {
 		} rx;
 		struct {
 			/* RDES0 */
-			u32 payload_csum_error:1;
+			u32 rx_mac_addr:1;
 			u32 crc_error:1;
 			u32 dribbling:1;
 			u32 error_gmii:1;
@@ -162,13 +163,57 @@ struct dma_desc {
 	unsigned int des3;
 };
 
+/* Extended descriptor structure (supported by new SYNP GMAC generations) */
+struct dma_extended_desc {
+	struct dma_desc basic;
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
+};
+
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
index 62f9f4e..c1b9ab2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -150,6 +150,57 @@ static int enh_desc_coe_rdes0(int ipc_err, int type, int payload_err)
 	return ret;
 }
 
+static void enh_desc_get_ext_status(void *data, struct stmmac_extra_stats *x,
+				    struct dma_extended_desc *p)
+{
+	if (unlikely(p->basic.des01.erx.rx_mac_addr)) {
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
+}
+
 static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 				  struct dma_desc *p)
 {
@@ -198,7 +249,7 @@ static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 	 * At any rate, we need to understand if the CSUM hw computation is ok
 	 * and report this info to the upper layers. */
 	ret = enh_desc_coe_rdes0(p->des01.erx.ipc_csum_error,
-		p->des01.erx.frame_type, p->des01.erx.payload_csum_error);
+		p->des01.erx.frame_type, p->des01.erx.rx_mac_addr);
 
 	if (unlikely(p->des01.erx.dribbling)) {
 		CHIP_DBG(KERN_ERR "GMAC RX: dribbling error\n");
@@ -225,41 +276,32 @@ static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 		x->rx_vlan++;
 	}
 #endif
+
 	return ret;
 }
 
-static void enh_desc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
-				  int disable_rx_ic, int mode)
+static void enh_desc_init_rx_desc(struct dma_desc *p, int disable_rx_ic,
+				  int mode, int end)
 {
-	int i;
-	for (i = 0; i < ring_size; i++) {
-		p->des01.erx.own = 1;
-		p->des01.erx.buffer1_size = BUF_SIZE_8KiB - 1;
+	p->des01.erx.own = 1;
+	p->des01.erx.buffer1_size = BUF_SIZE_8KiB - 1;
 
-		if (mode == STMMAC_CHAIN_MODE)
-			ehn_desc_rx_set_on_chain(p, (i == ring_size - 1));
-		else
-			ehn_desc_rx_set_on_ring(p, (i == ring_size - 1));
+	if (mode == STMMAC_CHAIN_MODE)
+		ehn_desc_rx_set_on_chain(p, end);
+	else
+		ehn_desc_rx_set_on_ring(p, end);
 
-		if (disable_rx_ic)
-			p->des01.erx.disable_ic = 1;
-		p++;
-	}
+	if (disable_rx_ic)
+		p->des01.erx.disable_ic = 1;
 }
 
-static void enh_desc_init_tx_desc(struct dma_desc *p, unsigned int ring_size,
-				  int mode)
+static void enh_desc_init_tx_desc(struct dma_desc *p, int mode, int end)
 {
-	int i;
-
-	for (i = 0; i < ring_size; i++) {
-		p->des01.etx.own = 0;
-		if (mode == STMMAC_CHAIN_MODE)
-			ehn_desc_tx_set_on_chain(p, (i == ring_size - 1));
-		else
-			ehn_desc_tx_set_on_ring(p, (i == ring_size - 1));
-		p++;
-	}
+	p->des01.etx.own = 0;
+	if (mode == STMMAC_CHAIN_MODE)
+		ehn_desc_tx_set_on_chain(p, end);
+	else
+		ehn_desc_tx_set_on_ring(p, end);
 }
 
 static int enh_desc_get_tx_owner(struct dma_desc *p)
@@ -352,4 +394,5 @@ const struct stmmac_desc_ops enh_desc_ops = {
 	.set_tx_owner = enh_desc_set_tx_owner,
 	.set_rx_owner = enh_desc_set_rx_owner,
 	.get_rx_frame_len = enh_desc_get_rx_frame_len,
+	.rx_extended_status = enh_desc_get_ext_status,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index 88df0b4..47d5094 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -122,37 +122,28 @@ static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 	return ret;
 }
 
-static void ndesc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
-			       int disable_rx_ic, int mode)
+static void ndesc_init_rx_desc(struct dma_desc *p, int disable_rx_ic, int mode,
+			       int end)
 {
-	int i;
-	for (i = 0; i < ring_size; i++) {
-		p->des01.rx.own = 1;
-		p->des01.rx.buffer1_size = BUF_SIZE_2KiB - 1;
-
-		if (mode == STMMAC_CHAIN_MODE)
-			ndesc_rx_set_on_chain(p, (i == ring_size - 1));
-		else
-			ndesc_rx_set_on_ring(p, (i == ring_size - 1));
-
-		if (disable_rx_ic)
-			p->des01.rx.disable_ic = 1;
-		p++;
-	}
+	p->des01.rx.own = 1;
+	p->des01.rx.buffer1_size = BUF_SIZE_2KiB - 1;
+
+	if (mode == STMMAC_CHAIN_MODE)
+		ndesc_rx_set_on_chain(p, end);
+	else
+		ndesc_rx_set_on_ring(p, end);
+
+	if (disable_rx_ic)
+		p->des01.rx.disable_ic = 1;
 }
 
-static void ndesc_init_tx_desc(struct dma_desc *p, unsigned int ring_size,
-			       int mode)
+static void ndesc_init_tx_desc(struct dma_desc *p, int mode, int end)
 {
-	int i;
-	for (i = 0; i < ring_size; i++) {
-		p->des01.tx.own = 0;
-		if (mode == STMMAC_CHAIN_MODE)
-			ndesc_tx_set_on_chain(p, (i == (ring_size - 1)));
-		else
-			ndesc_tx_set_on_ring(p, (i == (ring_size - 1)));
-		p++;
-	}
+	p->des01.tx.own = 0;
+	if (mode == STMMAC_CHAIN_MODE)
+		ndesc_tx_set_on_chain(p, end);
+	else
+		ndesc_tx_set_on_ring(p, end);
 }
 
 static int ndesc_get_tx_owner(struct dma_desc *p)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index e5f2f33..9637d3e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -34,7 +34,8 @@
 
 struct stmmac_priv {
 	/* Frequently used values are kept adjacent for cache effect */
-	struct dma_desc *dma_tx ____cacheline_aligned;
+	struct dma_desc *dma_tx ____cacheline_aligned;	/* Basic TX desc */
+	struct dma_extended_desc *dma_etx;	/* Extended TX descriptor */
 	dma_addr_t dma_tx_phy;
 	struct sk_buff **tx_skbuff;
 	unsigned int cur_tx;
@@ -42,7 +43,8 @@ struct stmmac_priv {
 	unsigned int dma_tx_size;
 	int tx_coalesce;
 
-	struct dma_desc *dma_rx ;
+	struct dma_desc *dma_rx;		/* Basic RX descriptor */
+	struct dma_extended_desc *dma_erx;	/* Extended RX descriptor */
 	unsigned int cur_rx;
 	unsigned int dirty_rx;
 	struct sk_buff **rx_skbuff;
@@ -94,6 +96,7 @@ struct stmmac_priv {
 	int use_riwt;
 	u32 rx_riwt;
 	unsigned int mode;
+	int extend_desc;
 };
 
 extern int phyaddr;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index d1ac39c..f6ad751 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -108,6 +108,29 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(irq_rx_path_in_lpi_mode_n),
 	STMMAC_STAT(irq_rx_path_exit_lpi_mode_n),
 	STMMAC_STAT(phy_eee_wakeup_error_n),
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
 };
 #define STMMAC_STATS_LEN ARRAY_SIZE(stmmac_gstrings_stats)
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index bbee6b3..96fbf86 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -468,29 +468,56 @@ static int stmmac_init_phy(struct net_device *dev)
 }
 
 /**
- * display_ring
+ * stmmac_display_ring
  * @p: pointer to the ring.
  * @size: size of the ring.
- * Description: display all the descriptors within the ring.
+ * Description: display the control/status and buffer descriptors.
  */
-static void display_ring(struct dma_desc *p, int size)
+static void stmmac_display_ring(void *head, int size, int extend_desc)
 {
-	struct tmp_s {
-		u64 a;
-		unsigned int b;
-		unsigned int c;
-	};
 	int i;
+	struct dma_extended_desc *ep = (struct dma_extended_desc *) head;
+	struct dma_desc *p = (struct dma_desc *) head;
+
 	for (i = 0; i < size; i++) {
-		struct tmp_s *x = (struct tmp_s *)(p + i);
-		pr_info("\t%d [0x%x]: DES0=0x%x DES1=0x%x BUF1=0x%x BUF2=0x%x",
-		       i, (unsigned int)virt_to_phys(&p[i]),
-		       (unsigned int)(x->a), (unsigned int)((x->a) >> 32),
-		       x->b, x->c);
+		u64 x;
+		if (extend_desc) {
+			x = *(u64 *) ep;
+			pr_info("%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
+				i, (unsigned int) virt_to_phys(ep),
+				(unsigned int) x, (unsigned int) (x >> 32),
+				ep->basic.des2, ep->basic.des3);
+			ep++;
+		} else {
+			x = *(u64 *) p;
+			pr_info("%d [0x%x]: 0x%x 0x%x 0x%x 0x%x",
+				i, (unsigned int) virt_to_phys(p),
+				(unsigned int) x, (unsigned int) (x >> 32),
+				p->des2, p->des3);
+			p++;
+		}
 		pr_info("\n");
 	}
 }
 
+static void stmmac_display_rings(struct stmmac_priv *priv)
+{
+	unsigned int txsize = priv->dma_tx_size;
+	unsigned int rxsize = priv->dma_rx_size;
+
+	if (priv->extend_desc) {
+		pr_info("Extended RX descriptor ring:\n");
+		stmmac_display_ring((void *) priv->dma_erx, rxsize, 1);
+		pr_info("Extended TX descriptor ring:\n");
+		stmmac_display_ring((void *) priv->dma_etx, txsize, 1);
+	} else {
+		pr_info("RX descriptor ring:\n");
+		stmmac_display_ring((void *)priv->dma_rx, rxsize, 0);
+		pr_info("TX descriptor ring:\n");
+		stmmac_display_ring((void *)priv->dma_tx, txsize, 0);
+	}
+}
+
 static int stmmac_set_bfsize(int mtu, int bufsize)
 {
 	int ret = bufsize;
@@ -507,6 +534,59 @@ static int stmmac_set_bfsize(int mtu, int bufsize)
 	return ret;
 }
 
+static void stmmac_clear_descriptors(struct stmmac_priv *priv)
+{
+	int i;
+	unsigned int txsize = priv->dma_tx_size;
+	unsigned int rxsize = priv->dma_rx_size;
+
+	/* Clear the Rx/Tx descriptors */
+	for (i = 0; i < rxsize; i++)
+		if (priv->extend_desc)
+			priv->hw->desc->init_rx_desc(&priv->dma_erx[i].basic,
+						     priv->use_riwt, priv->mode,
+						     (i == rxsize - 1));
+		else
+			priv->hw->desc->init_rx_desc(&priv->dma_rx[i],
+						     priv->use_riwt, priv->mode,
+						     (i == rxsize - 1));
+	for (i = 0; i < txsize; i++)
+		if (priv->extend_desc)
+			priv->hw->desc->init_tx_desc(&priv->dma_etx[i].basic,
+						     priv->mode,
+						     (i == txsize - 1));
+		else
+			priv->hw->desc->init_tx_desc(&priv->dma_tx[i],
+						     priv->mode,
+						     (i == txsize - 1));
+}
+
+static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
+				  int i)
+{
+	struct sk_buff *skb;
+
+	skb = __netdev_alloc_skb(priv->dev, priv->dma_buf_sz + NET_IP_ALIGN,
+				 GFP_KERNEL);
+	if (unlikely(skb == NULL)) {
+		pr_err("%s: Rx init fails; skb is NULL\n", __func__);
+		return 1;
+	}
+	skb_reserve(skb, NET_IP_ALIGN);
+	priv->rx_skbuff[i] = skb;
+	priv->rx_skbuff_dma[i] = dma_map_single(priv->device, skb->data,
+						priv->dma_buf_sz,
+						DMA_FROM_DEVICE);
+
+	p->des2 = priv->rx_skbuff_dma[i];
+
+	if ((priv->mode == STMMAC_RING_MODE) &&
+	    (priv->dma_buf_sz == BUF_SIZE_16KiB))
+		priv->hw->ring->init_desc3(p);
+
+	return 0;
+}
+
 /**
  * init_dma_desc_rings - init the RX/TX descriptor rings
  * @dev: net device structure
@@ -518,11 +598,9 @@ static void init_dma_desc_rings(struct net_device *dev)
 {
 	int i;
 	struct stmmac_priv *priv = netdev_priv(dev);
-	struct sk_buff *skb;
 	unsigned int txsize = priv->dma_tx_size;
 	unsigned int rxsize = priv->dma_rx_size;
 	unsigned int bfsize = 0;
-	int dis_ic = 0;
 
 	/* Set the max buffer size according to the DESC mode
 	 * and the MTU. Note that RING mode allows 16KiB bsize. */
@@ -535,50 +613,53 @@ static void init_dma_desc_rings(struct net_device *dev)
 	DBG(probe, INFO, "stmmac: txsize %d, rxsize %d, bfsize %d\n",
 	    txsize, rxsize, bfsize);
 
+	if (priv->extend_desc) {
+		priv->dma_erx = dma_alloc_coherent(priv->device, rxsize *
+						   sizeof(struct
+							  dma_extended_desc),
+						   &priv->dma_rx_phy,
+						   GFP_KERNEL);
+		priv->dma_etx = dma_alloc_coherent(priv->device, txsize *
+						   sizeof(struct
+							  dma_extended_desc),
+						   &priv->dma_tx_phy,
+						   GFP_KERNEL);
+		if ((!priv->dma_erx) || (!priv->dma_etx))
+			return;
+	} else {
+		priv->dma_rx = dma_alloc_coherent(priv->device, rxsize *
+						  sizeof(struct dma_desc),
+						  &priv->dma_rx_phy,
+						  GFP_KERNEL);
+		priv->dma_tx = dma_alloc_coherent(priv->device, txsize *
+						  sizeof(struct dma_desc),
+						  &priv->dma_tx_phy,
+						  GFP_KERNEL);
+		if ((!priv->dma_rx) || (!priv->dma_tx))
+			return;
+	}
+
 	priv->rx_skbuff_dma = kmalloc_array(rxsize, sizeof(dma_addr_t),
 					    GFP_KERNEL);
 	priv->rx_skbuff = kmalloc_array(rxsize, sizeof(struct sk_buff *),
 					GFP_KERNEL);
-	priv->dma_rx = dma_alloc_coherent(priv->device,
-					  rxsize * sizeof(struct dma_desc),
-					  &priv->dma_rx_phy, GFP_KERNEL);
 	priv->tx_skbuff = kmalloc_array(txsize, sizeof(struct sk_buff *),
 					GFP_KERNEL);
-	priv->dma_tx = dma_alloc_coherent(priv->device,
-					  txsize * sizeof(struct dma_desc),
-					  &priv->dma_tx_phy, GFP_KERNEL);
-
-	if ((priv->dma_rx == NULL) || (priv->dma_tx == NULL))
-		return;
-
-	DBG(probe, INFO, "stmmac (%s) DMA desc: virt addr (Rx %p, "
-	    "Tx %p)\n\tDMA phy addr (Rx 0x%08x, Tx 0x%08x)\n",
-	    dev->name, priv->dma_rx, priv->dma_tx,
-	    (unsigned int)priv->dma_rx_phy, (unsigned int)priv->dma_tx_phy);
+	if (netif_msg_drv(priv))
+		pr_debug("(%s) dma_rx_phy=0x%08x dma_tx_phy=0x%08x\n", __func__,
+			 (u32) priv->dma_rx_phy, (u32) priv->dma_tx_phy);
 
 	/* RX INITIALIZATION */
-	DBG(probe, INFO, "stmmac: SKB addresses:\n"
-			 "skb\t\tskb data\tdma data\n");
-
+	DBG(probe, INFO, "stmmac: SKB addresses:\nskb\t\tskb data\tdma data\n");
 	for (i = 0; i < rxsize; i++) {
-		struct dma_desc *p = priv->dma_rx + i;
+		struct dma_desc *p;
+		if (priv->extend_desc)
+			p = &((priv->dma_erx + i)->basic);
+		else
+			p = priv->dma_rx + i;
 
-		skb = __netdev_alloc_skb(dev, bfsize + NET_IP_ALIGN,
-					 GFP_KERNEL);
-		if (unlikely(skb == NULL)) {
-			pr_err("%s: Rx init fails; skb is NULL\n", __func__);
+		if (stmmac_init_rx_buffers(priv, p, i))
 			break;
-		}
-		skb_reserve(skb, NET_IP_ALIGN);
-		priv->rx_skbuff[i] = skb;
-		priv->rx_skbuff_dma[i] = dma_map_single(priv->device, skb->data,
-						bfsize, DMA_FROM_DEVICE);
-
-		p->des2 = priv->rx_skbuff_dma[i];
-
-		if ((priv->mode == STMMAC_RING_MODE) &&
-		    (bfsize == BUF_SIZE_16KiB))
-			priv->hw->ring->init_desc3(p);
 
 		DBG(probe, INFO, "[%p]\t[%p]\t[%x]\n", priv->rx_skbuff[i],
 			priv->rx_skbuff[i]->data, priv->rx_skbuff_dma[i]);
@@ -588,35 +669,39 @@ static void init_dma_desc_rings(struct net_device *dev)
 	priv->dma_buf_sz = bfsize;
 	buf_sz = bfsize;
 
+	/* Setup the chained descriptor addresses */
+	if (priv->mode == STMMAC_CHAIN_MODE) {
+		if (priv->extend_desc) {
+			priv->hw->chain->init(priv->dma_erx, priv->dma_rx_phy,
+					      rxsize, 1);
+			priv->hw->chain->init(priv->dma_etx, priv->dma_tx_phy,
+					      txsize, 1);
+		} else {
+			priv->hw->chain->init(priv->dma_rx, priv->dma_rx_phy,
+					      rxsize, 0);
+			priv->hw->chain->init(priv->dma_tx, priv->dma_tx_phy,
+					      txsize, 0);
+		}
+	}
+
 	/* TX INITIALIZATION */
 	for (i = 0; i < txsize; i++) {
+		struct dma_desc *p;
+		if (priv->extend_desc)
+			p = &((priv->dma_etx + i)->basic);
+		else
+			p = priv->dma_tx + i;
+		p->des2 = 0;
 		priv->tx_skbuff[i] = NULL;
-		priv->dma_tx[i].des2 = 0;
 	}
 
-	/* In case of Chained mode this sets the des3 to the next
-	 * element in the chain */
-	if (priv->mode == STMMAC_CHAIN_MODE) {
-		priv->hw->chain->init_dma_chain(priv->dma_rx, priv->dma_rx_phy,
-						rxsize);
-		priv->hw->chain->init_dma_chain(priv->dma_tx, priv->dma_tx_phy,
-						txsize);
-	}
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
 
-	if (priv->use_riwt)
-		dis_ic = 1;
-	/* Clear the Rx/Tx descriptors */
-	priv->hw->desc->init_rx_desc(priv->dma_rx, rxsize, dis_ic, priv->mode);
-	priv->hw->desc->init_tx_desc(priv->dma_tx, txsize, priv->mode);
+	stmmac_clear_descriptors(priv);
 
-	if (netif_msg_hw(priv)) {
-		pr_info("RX descriptor ring:\n");
-		display_ring(priv->dma_rx, rxsize);
-		pr_info("TX descriptor ring:\n");
-		display_ring(priv->dma_tx, txsize);
-	}
+	if (netif_msg_hw(priv))
+		stmmac_display_rings(priv);
 }
 
 static void dma_free_rx_skbufs(struct stmmac_priv *priv)
@@ -639,7 +724,12 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
 
 	for (i = 0; i < priv->dma_tx_size; i++) {
 		if (priv->tx_skbuff[i] != NULL) {
-			struct dma_desc *p = priv->dma_tx + i;
+			struct dma_desc *p;
+			if (priv->extend_desc)
+				p = &((priv->dma_etx + i)->basic);
+			else
+				p = priv->dma_tx + i;
+
 			if (p->des2)
 				dma_unmap_single(priv->device, p->des2,
 						 priv->hw->desc->get_tx_len(p),
@@ -658,12 +748,21 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
 
 	/* Free the region of consistent memory previously allocated for
 	 * the DMA */
-	dma_free_coherent(priv->device,
-			  priv->dma_tx_size * sizeof(struct dma_desc),
-			  priv->dma_tx, priv->dma_tx_phy);
-	dma_free_coherent(priv->device,
-			  priv->dma_rx_size * sizeof(struct dma_desc),
-			  priv->dma_rx, priv->dma_rx_phy);
+	if (!priv->extend_desc) {
+		dma_free_coherent(priv->device,
+				  priv->dma_tx_size * sizeof(struct dma_desc),
+				  priv->dma_tx, priv->dma_tx_phy);
+		dma_free_coherent(priv->device,
+				  priv->dma_rx_size * sizeof(struct dma_desc),
+				  priv->dma_rx, priv->dma_rx_phy);
+	} else {
+		dma_free_coherent(priv->device, priv->dma_tx_size *
+				  sizeof(struct dma_extended_desc),
+				  priv->dma_etx, priv->dma_tx_phy);
+		dma_free_coherent(priv->device, priv->dma_rx_size *
+				  sizeof(struct dma_extended_desc),
+				  priv->dma_erx, priv->dma_rx_phy);
+	}
 	kfree(priv->rx_skbuff_dma);
 	kfree(priv->rx_skbuff);
 	kfree(priv->tx_skbuff);
@@ -710,13 +809,18 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 		int last;
 		unsigned int entry = priv->dirty_tx % txsize;
 		struct sk_buff *skb = priv->tx_skbuff[entry];
-		struct dma_desc *p = priv->dma_tx + entry;
+		struct dma_desc *p;
+
+		if (priv->extend_desc)
+			p = (struct dma_desc *) (priv->dma_etx + entry);
+		else
+			p = priv->dma_tx + entry;
 
 		/* Check if the descriptor is owned by the DMA. */
 		if (priv->hw->desc->get_tx_owner(p))
 			break;
 
-		/* Verify tx error by looking at the last segment */
+		/* Verify tx error by looking at the last segment. */
 		last = priv->hw->desc->get_tx_ls(p);
 		if (likely(last)) {
 			int tx_error =
@@ -785,12 +889,21 @@ static inline void stmmac_disable_dma_irq(struct stmmac_priv *priv)
  */
 static void stmmac_tx_err(struct stmmac_priv *priv)
 {
+	int i;
+	int txsize = priv->dma_tx_size;
 	netif_stop_queue(priv->dev);
 
 	priv->hw->dma->stop_tx(priv->ioaddr);
 	dma_free_tx_skbufs(priv);
-	priv->hw->desc->init_tx_desc(priv->dma_tx, priv->dma_tx_size,
-				     priv->mode);
+	for (i = 0; i < txsize; i++)
+		if (priv->extend_desc)
+			priv->hw->desc->init_tx_desc(&priv->dma_etx[i].basic,
+						     priv->mode,
+						     (i == txsize - 1));
+		else
+			priv->hw->desc->init_tx_desc(&priv->dma_tx[i],
+						     priv->mode,
+						     (i == txsize - 1));
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
 	priv->hw->dma->start_tx(priv->ioaddr);
@@ -864,6 +977,14 @@ static void stmmac_selec_desc_mode(struct stmmac_priv *priv)
 {
 	if (priv->plat->enh_desc) {
 		pr_info(" Enhanced/Alternate descriptors\n");
+
+		/* GMAC older than 3.50 has no extended descriptors */
+		if (priv->synopsys_id >= DWMAC_CORE_3_50) {
+			pr_info("\tEnabled extended descriptors\n");
+			priv->extend_desc = 1;
+		} else
+			pr_warn("Extended descriptors not supported\n");
+
 		priv->hw->desc = &enh_desc_ops;
 	} else {
 		pr_info(" Normal descriptors\n");
@@ -950,6 +1071,7 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 {
 	int pbl = DEFAULT_DMA_PBL, fixed_burst = 0, burst_len = 0;
 	int mixed_burst = 0;
+	int atds = 0;
 
 	/* Some DMA parameters can be passed from the platform;
 	 * in case of these are not passed we keep a default
@@ -961,9 +1083,12 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 		burst_len = priv->plat->dma_cfg->burst_len;
 	}
 
+	if (priv->extend_desc && (priv->mode == STMMAC_RING_MODE))
+		atds = 1;
+
 	return priv->hw->dma->init(priv->ioaddr, pbl, fixed_burst, mixed_burst,
 				   burst_len, priv->dma_tx_phy,
-				   priv->dma_rx_phy);
+				   priv->dma_rx_phy, atds);
 }
 
 /**
@@ -1237,7 +1362,11 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	csum_insertion = (skb->ip_summed == CHECKSUM_PARTIAL);
 
-	desc = priv->dma_tx + entry;
+	if (priv->extend_desc)
+		desc = (struct dma_desc *) (priv->dma_etx + entry);
+	else
+		desc = priv->dma_tx + entry;
+
 	first = desc;
 
 #ifdef STMMAC_XMIT_DEBUG
@@ -1268,14 +1397,17 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
 						csum_insertion, priv->mode);
 	} else
-		desc = priv->dma_tx + entry;
+		desc = first;
 
 	for (i = 0; i < nfrags; i++) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 		int len = skb_frag_size(frag);
 
 		entry = (++priv->cur_tx) % txsize;
-		desc = priv->dma_tx + entry;
+		if (priv->extend_desc)
+			desc = (struct dma_desc *) (priv->dma_etx + entry);
+		else
+			desc = priv->dma_tx + entry;
 
 		TX_DBG("\t[entry %d] segment len: %d\n", entry, len);
 		desc->des2 = skb_frag_dma_map(priv->device, frag, 0, len,
@@ -1319,7 +1451,11 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		       "first=%p, nfrags=%d\n",
 		       (priv->cur_tx % txsize), (priv->dirty_tx % txsize),
 		       entry, first, nfrags);
-		display_ring(priv->dma_tx, txsize);
+		if (priv->extend_desc)
+			stmmac_display_ring((void *)priv->dma_etx, txsize, 1);
+		else
+			stmmac_display_ring((void *)priv->dma_tx, txsize, 0);
+
 		pr_info(">>> frame to be transmitted: ");
 		print_pkt(skb->data, skb->len);
 	}
@@ -1344,10 +1480,16 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 {
 	unsigned int rxsize = priv->dma_rx_size;
 	int bfsize = priv->dma_buf_sz;
-	struct dma_desc *p = priv->dma_rx;
 
 	for (; priv->cur_rx - priv->dirty_rx > 0; priv->dirty_rx++) {
 		unsigned int entry = priv->dirty_rx % rxsize;
+		struct dma_desc *p;
+
+		if (priv->extend_desc)
+			p = (struct dma_desc *) (priv->dma_erx + entry);
+		else
+			p = priv->dma_rx + entry;
+
 		if (likely(priv->rx_skbuff[entry] == NULL)) {
 			struct sk_buff *skb;
 
@@ -1361,16 +1503,16 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 			    dma_map_single(priv->device, skb->data, bfsize,
 					   DMA_FROM_DEVICE);
 
-			(p + entry)->des2 = priv->rx_skbuff_dma[entry];
+			p->des2 = priv->rx_skbuff_dma[entry];
 
 			if (unlikely((priv->mode == STMMAC_RING_MODE) &&
 				     (priv->plat->has_gmac)))
-				priv->hw->ring->refill_desc3(bfsize, p + entry);
+				priv->hw->ring->refill_desc3(bfsize, p);
 
 			RX_DBG(KERN_INFO "\trefill entry #%d\n", entry);
 		}
 		wmb();
-		priv->hw->desc->set_rx_owner(p + entry);
+		priv->hw->desc->set_rx_owner(p);
 		wmb();
 	}
 }
@@ -1381,30 +1523,47 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 	unsigned int entry = priv->cur_rx % rxsize;
 	unsigned int next_entry;
 	unsigned int count = 0;
-	struct dma_desc *p = priv->dma_rx + entry;
-	struct dma_desc *p_next;
 
 #ifdef STMMAC_RX_DEBUG
 	if (netif_msg_hw(priv)) {
 		pr_debug(">>> stmmac_rx: descriptor ring:\n");
-		display_ring(priv->dma_rx, rxsize);
+		if (priv->extend_desc)
+			stmmac_display_ring((void *) priv->dma_erx, rxsize, 1);
+		else
+			stmmac_display_ring((void *)priv->dma_rx, rxsize, 0);
 	}
 #endif
-	while (!priv->hw->desc->get_rx_owner(p)) {
+	while (count < limit) {
 		int status;
+		struct dma_desc *p, *p_next;
 
-		if (count >= limit)
+		if (priv->extend_desc)
+			p = (struct dma_desc *) (priv->dma_erx + entry);
+		else
+			p = priv->dma_rx + entry ;
+
+		if (priv->hw->desc->get_rx_owner(p))
 			break;
 
 		count++;
 
 		next_entry = (++priv->cur_rx) % rxsize;
-		p_next = priv->dma_rx + next_entry;
+		if (priv->extend_desc)
+			p_next = (struct dma_desc *) (priv->dma_erx +
+						      next_entry);
+		else
+			p_next = priv->dma_rx + next_entry;
+
 		prefetch(p_next);
 
 		/* read the status of the incoming frame */
-		status = (priv->hw->desc->rx_status(&priv->dev->stats,
-						    &priv->xstats, p));
+		status = priv->hw->desc->rx_status(&priv->dev->stats,
+						   &priv->xstats, p);
+		if ((priv->extend_desc) && (priv->hw->desc->rx_extended_status))
+			priv->hw->desc->rx_extended_status(&priv->dev->stats,
+							   &priv->xstats,
+							   priv->dma_erx +
+							   entry);
 		if (unlikely(status == discard_frame))
 			priv->dev->stats.rx_errors++;
 		else {
@@ -1459,7 +1618,6 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 			priv->dev->stats.rx_bytes += frame_len;
 		}
 		entry = next_entry;
-		p = p_next;	/* use prefetched values */
 	}
 
 	stmmac_rx_refill(priv);
@@ -1697,40 +1855,51 @@ static struct dentry *stmmac_fs_dir;
 static struct dentry *stmmac_rings_status;
 static struct dentry *stmmac_dma_cap;
 
-static int stmmac_sysfs_ring_read(struct seq_file *seq, void *v)
+static void sysfs_display_ring(void *head, int size, int extend_desc,
+				struct seq_file *seq)
 {
-	struct tmp_s {
-		u64 a;
-		unsigned int b;
-		unsigned int c;
-	};
 	int i;
-	struct net_device *dev = seq->private;
-	struct stmmac_priv *priv = netdev_priv(dev);
-
-	seq_printf(seq, "=======================\n");
-	seq_printf(seq, " RX descriptor ring\n");
-	seq_printf(seq, "=======================\n");
+	struct dma_extended_desc *ep = (struct dma_extended_desc *) head;
+	struct dma_desc *p = (struct dma_desc *) head;
 
-	for (i = 0; i < priv->dma_rx_size; i++) {
-		struct tmp_s *x = (struct tmp_s *)(priv->dma_rx + i);
-		seq_printf(seq, "[%d] DES0=0x%x DES1=0x%x BUF1=0x%x BUF2=0x%x",
-			   i, (unsigned int)(x->a),
-			   (unsigned int)((x->a) >> 32), x->b, x->c);
+	for (i = 0; i < size; i++) {
+		u64 x;
+		if (extend_desc) {
+			x = *(u64 *) ep;
+			seq_printf(seq, "%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
+				   i, (unsigned int) virt_to_phys(ep),
+				   (unsigned int) x, (unsigned int) (x >> 32),
+				   ep->basic.des2, ep->basic.des3);
+			ep++;
+		} else {
+			x = *(u64 *) p;
+			seq_printf(seq, "%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
+				   i, (unsigned int) virt_to_phys(ep),
+				   (unsigned int) x, (unsigned int) (x >> 32),
+				   p->des2, p->des3);
+			p++;
+		}
 		seq_printf(seq, "\n");
 	}
+}
 
-	seq_printf(seq, "\n");
-	seq_printf(seq, "=======================\n");
-	seq_printf(seq, "  TX descriptor ring\n");
-	seq_printf(seq, "=======================\n");
+static int stmmac_sysfs_ring_read(struct seq_file *seq, void *v)
+{
+	struct net_device *dev = seq->private;
+	struct stmmac_priv *priv = netdev_priv(dev);
+	unsigned int txsize = priv->dma_tx_size;
+	unsigned int rxsize = priv->dma_rx_size;
 
-	for (i = 0; i < priv->dma_tx_size; i++) {
-		struct tmp_s *x = (struct tmp_s *)(priv->dma_tx + i);
-		seq_printf(seq, "[%d] DES0=0x%x DES1=0x%x BUF1=0x%x BUF2=0x%x",
-			   i, (unsigned int)(x->a),
-			   (unsigned int)((x->a) >> 32), x->b, x->c);
-		seq_printf(seq, "\n");
+	if (priv->extend_desc) {
+		seq_printf(seq, "Extended RX descriptor ring:\n");
+		sysfs_display_ring((void *) priv->dma_erx, rxsize, 1, seq);
+		seq_printf(seq, "Extended TX descriptor ring:\n");
+		sysfs_display_ring((void *) priv->dma_etx, txsize, 1, seq);
+	} else {
+		seq_printf(seq, "RX descriptor ring:\n");
+		sysfs_display_ring((void *)priv->dma_rx, rxsize, 0, seq);
+		seq_printf(seq, "TX descriptor ring:\n");
+		sysfs_display_ring((void *)priv->dma_tx, txsize, 0, seq);
 	}
 
 	return 0;
@@ -1895,7 +2064,7 @@ static const struct net_device_ops stmmac_netdev_ops = {
  */
 static int stmmac_hw_init(struct stmmac_priv *priv)
 {
-	int ret = 0;
+	int ret;
 	struct mac_device_info *mac;
 
 	/* Identify the MAC HW device */
@@ -1913,6 +2082,9 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 	/* Get and dump the chip ID */
 	priv->synopsys_id = stmmac_get_synopsys_id(priv);
 
+	/* To use alternate (extended) or normal descriptor structures */
+	stmmac_selec_desc_mode(priv);
+
 	/* To use the chained or ring mode */
 	if (chain_mode)	{
 		priv->hw->chain = &chain_mode_ops;
@@ -1947,9 +2119,6 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 	} else
 		pr_info(" No HW DMA feature register supported");
 
-	/* Select the enhnaced/normal descriptor structures */
-	stmmac_selec_desc_mode(priv);
-
 	/* Enable the IPC (Checksum Offload) and check if the feature has been
 	 * enabled during the core configuration. */
 	ret = priv->hw->mac->rx_ipc(priv->ioaddr);
@@ -1969,7 +2138,7 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 		device_set_wakeup_capable(priv->device, 1);
 	}
 
-	return ret;
+	return 0;
 }
 
 /**
@@ -2015,7 +2184,9 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 		priv->plat->phy_addr = phyaddr;
 
 	/* Init MAC and get the capabilities */
-	stmmac_hw_init(priv);
+	ret = stmmac_hw_init(priv);
+	if (ret)
+		goto error_free_netdev;
 
 	ndev->netdev_ops = &stmmac_netdev_ops;
 
@@ -2086,6 +2257,7 @@ error_clk_get:
 	unregister_netdev(ndev);
 error_netdev_register:
 	netif_napi_del(&priv->napi);
+error_free_netdev:
 	free_netdev(ndev);
 
 	return NULL;
@@ -2119,7 +2291,6 @@ int stmmac_dvr_remove(struct net_device *ndev)
 int stmmac_suspend(struct net_device *ndev)
 {
 	struct stmmac_priv *priv = netdev_priv(ndev);
-	int dis_ic = 0;
 	unsigned long flags;
 
 	if (!ndev || !netif_running(ndev))
@@ -2133,19 +2304,13 @@ int stmmac_suspend(struct net_device *ndev)
 	netif_device_detach(ndev);
 	netif_stop_queue(ndev);
 
-	if (priv->use_riwt)
-		dis_ic = 1;
-
 	napi_disable(&priv->napi);
 
 	/* Stop TX/RX DMA */
 	priv->hw->dma->stop_tx(priv->ioaddr);
 	priv->hw->dma->stop_rx(priv->ioaddr);
-	/* Clear the Rx/Tx descriptors */
-	priv->hw->desc->init_rx_desc(priv->dma_rx, priv->dma_rx_size,
-				     dis_ic, priv->mode);
-	priv->hw->desc->init_tx_desc(priv->dma_tx, priv->dma_tx_size,
-				     priv->mode);
+
+	stmmac_clear_descriptors(priv);
 
 	/* Enable Power down mode by programming the PMT regs */
 	if (device_may_wakeup(priv->device))
-- 
1.7.4.4
