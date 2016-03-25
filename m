From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH 04/13] stmmac: add descriptors function for GMAC 4.xx
Date: Fri, 25 Mar 2016 10:14:11 +0100
Message-ID: <1458897260-14104-5-git-send-email-alexandre.torgue@st.com>
References: <1458897260-14104-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Lars Persson <lars.persson@axis.com>
To: <netdev@vger.kernel.org>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:60882 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752395AbcCYJOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 05:14:48 -0400
In-Reply-To: <1458897260-14104-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One of main changes of GMAC 4.xx IP is descriptors management.
-descriptors are only used in ring mode.
-A descriptor is composed of 4 32bits registers (no more extended
 descriptors)
-descriptor mechanism (Tx for example, but it is exactly the same for RX):
-useful registers:
	-DMA_CH#_TxDesc_Ring_Len: length of transmit descriptor
				   ring
	-DMA_CH#_TxDesc_List_Address: start address of the ring
	-DMA_CH#_TxDesc_Tail_Pointer: address of the last
				      descriptor to send + 1.
	-DMA_CH#_TxDesc_Current_App_TxDesc: address of the current
					    descriptor

-The descriptor Tail Pointer register contains the pointer to the
 descriptor address (N). The base address and the current
 descriptor decide the address of the current descriptor that the
 DMA can process. The descriptors up to one location less than the
 one indicated by the descriptor tail pointer (N-1) are owned by
 the DMA. The DMA continues to process the descriptors until the
 following condition occurs:
 "current descriptor pointer == Descriptor Tail pointer"

  Then the DMA goes into suspend mode. The application must perform
  a write to descriptor tail pointer register and update the tail
  pointer to have the following condition and to start a new
      transfer:
  "current descriptor pointer < Descriptor tail pointer"

  The DMA automatically wraps around the base address when the end
  of ring is reached.

-New features are available on IP:
-TSO (TCP Segmentation Offload) for TX only
-Split header: to have header and payload in 2 different buffers

Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index b390161..fa000fd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -2,7 +2,8 @@ obj-$(CONFIG_STMMAC_ETH) += stmmac.o
 stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 	      chain_mode.o dwmac_lib.o dwmac1000_core.o dwmac1000_dma.o	\
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o norm_desc.o	\
-	      mmc_core.o stmmac_hwtstamp.o stmmac_ptp.o $(stmmac-y)
+	      mmc_core.o stmmac_hwtstamp.o stmmac_ptp.o dwmac4_descs.o	\
+	      $(stmmac-y)
 
 # Ordering matters. Generic driver must be last.
 obj-$(CONFIG_STMMAC_PLATFORM)	+= stmmac-platform.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 66e132f..ea7eb0d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -243,6 +243,7 @@ enum rx_frame_status {
 	csum_none = 0x2,
 	llc_snap = 0x4,
 	dma_own = 0x8,
+	rx_not_ls = 0x10,
 };
 
 /* Tx status */
@@ -348,6 +349,10 @@ struct stmmac_desc_ops {
 	void (*prepare_tx_desc) (struct dma_desc *p, int is_fs, int len,
 				 bool csum_flag, int mode, bool tx_own,
 				 bool ls);
+	void (*prepare_tso_tx_desc)(struct dma_desc *p, int is_fs, int len1,
+				    int len2, bool tx_own, bool ls,
+				    unsigned int tcphdrlen,
+				    unsigned int tcppayloadlen);
 	/* Set/get the owner of the descriptor */
 	void (*set_tx_owner) (struct dma_desc *p);
 	int (*get_tx_owner) (struct dma_desc *p);
@@ -382,6 +387,8 @@ struct stmmac_desc_ops {
 	int (*get_rx_timestamp_status) (void *desc, u32 ats);
 	/* Display ring */
 	void (*display_ring)(void *head, unsigned int size, bool rx);
+	/* set MSS via context descriptor */
+	void (*set_mss)(struct dma_desc *p, unsigned int mss);
 };
 
 extern const struct stmmac_desc_ops enh_desc_ops;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
new file mode 100644
index 0000000..33cbec3
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
@@ -0,0 +1,396 @@
+/*
+ * This contains the functions to handle the descriptors for DesignWare databook
+ * 4.xx.
+ *
+ * Copyright (C) 2015  STMicroelectronics Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * Author: Alexandre Torgue <alexandre.torgue@st.com>
+ */
+
+#include <linux/stmmac.h>
+#include "common.h"
+#include "dwmac4_descs.h"
+
+static int dwmac4_wrback_get_tx_status(void *data, struct stmmac_extra_stats *x,
+				       struct dma_desc *p,
+				       void __iomem *ioaddr)
+{
+	struct net_device_stats *stats = (struct net_device_stats *)data;
+	unsigned int tdes3;
+	int ret = tx_done;
+
+	tdes3 = p->des3;
+
+	/* Get tx owner first */
+	if (unlikely(tdes3 & TDES3_OWN))
+		return tx_dma_own;
+
+	/* Verify tx error by looking at the last segment. */
+	if (likely(!(tdes3 & TDES3_LAST_DESCRIPTOR)))
+		return tx_not_ls;
+
+	if (unlikely(tdes3 & TDES3_ERROR_SUMMARY)) {
+		if (unlikely(tdes3 & TDES3_JABBER_TIMEOUT))
+			x->tx_jabber++;
+		if (unlikely(tdes3 & TDES3_PACKET_FLUSHED))
+			x->tx_frame_flushed++;
+		if (unlikely(tdes3 & TDES3_LOSS_CARRIER)) {
+			x->tx_losscarrier++;
+			stats->tx_carrier_errors++;
+		}
+		if (unlikely(tdes3 & TDES3_NO_CARRIER)) {
+			x->tx_carrier++;
+			stats->tx_carrier_errors++;
+		}
+		if (unlikely((tdes3 & TDES3_LATE_COLLISION) ||
+			     (tdes3 & TDES3_EXCESSIVE_COLLISION)))
+			stats->collisions +=
+			    (tdes3 & TDES3_COLLISION_COUNT_MASK)
+			    >> TDES3_COLLISION_COUNT_SHIFT;
+
+		if (unlikely(tdes3 & TDES3_EXCESSIVE_DEFERRAL))
+			x->tx_deferred++;
+
+		if (unlikely(tdes3 & TDES3_UNDERFLOW_ERROR))
+			x->tx_underflow++;
+
+		if (unlikely(tdes3 & TDES3_IP_HDR_ERROR))
+			x->tx_ip_header_error++;
+
+		if (unlikely(tdes3 & TDES3_PAYLOAD_ERROR))
+			x->tx_payload_error++;
+
+		ret = tx_err;
+	}
+
+	if (unlikely(tdes3 & TDES3_DEFERRED))
+		x->tx_deferred++;
+
+	return ret;
+}
+
+static int dwmac4_wrback_get_rx_status(void *data, struct stmmac_extra_stats *x,
+				       struct dma_desc *p)
+{
+	struct net_device_stats *stats = (struct net_device_stats *)data;
+	unsigned int rdes1 = p->des1;
+	unsigned int rdes2 = p->des2;
+	unsigned int rdes3 = p->des3;
+	int message_type;
+	int ret = good_frame;
+
+	if (unlikely(rdes3 & RDES3_OWN))
+		return dma_own;
+
+	/* Verify rx error by looking at the last segment. */
+	if (likely(!(rdes3 & RDES3_LAST_DESCRIPTOR)))
+		return discard_frame;
+
+	if (unlikely(rdes3 & RDES3_ERROR_SUMMARY)) {
+		if (unlikely(rdes3 & RDES3_GIANT_PACKET))
+			stats->rx_length_errors++;
+		if (unlikely(rdes3 & RDES3_OVERFLOW_ERROR))
+			x->rx_gmac_overflow++;
+
+		if (unlikely(rdes3 & RDES3_RECEIVE_WATCHDOG))
+			x->rx_watchdog++;
+
+		if (unlikely(rdes3 & RDES3_RECEIVE_ERROR))
+			x->rx_mii++;
+
+		if (unlikely(rdes3 & RDES3_CRC_ERROR)) {
+			x->rx_crc++;
+			stats->rx_crc_errors++;
+		}
+
+		if (unlikely(rdes3 & RDES3_DRIBBLE_ERROR))
+			x->dribbling_bit++;
+
+		ret = discard_frame;
+	}
+
+	message_type = (rdes1 & ERDES4_MSG_TYPE_MASK) >> 8;
+
+	if (rdes1 & RDES1_IP_HDR_ERROR)
+		x->ip_hdr_err++;
+	if (rdes1 & RDES1_IP_CSUM_BYPASSED)
+		x->ip_csum_bypassed++;
+	if (rdes1 & RDES1_IPV4_HEADER)
+		x->ipv4_pkt_rcvd++;
+	if (rdes1 & RDES1_IPV6_HEADER)
+		x->ipv6_pkt_rcvd++;
+	if (message_type == RDES_EXT_SYNC)
+		x->rx_msg_type_sync++;
+	else if (message_type == RDES_EXT_FOLLOW_UP)
+		x->rx_msg_type_follow_up++;
+	else if (message_type == RDES_EXT_DELAY_REQ)
+		x->rx_msg_type_delay_req++;
+	else if (message_type == RDES_EXT_DELAY_RESP)
+		x->rx_msg_type_delay_resp++;
+	else if (message_type == RDES_EXT_PDELAY_REQ)
+		x->rx_msg_type_pdelay_req++;
+	else if (message_type == RDES_EXT_PDELAY_RESP)
+		x->rx_msg_type_pdelay_resp++;
+	else if (message_type == RDES_EXT_PDELAY_FOLLOW_UP)
+		x->rx_msg_type_pdelay_follow_up++;
+	else
+		x->rx_msg_type_ext_no_ptp++;
+
+	if (rdes1 & RDES1_PTP_PACKET_TYPE)
+		x->ptp_frame_type++;
+	if (rdes1 & RDES1_PTP_VER)
+		x->ptp_ver++;
+	if (rdes1 & RDES1_TIMESTAMP_DROPPED)
+		x->timestamp_dropped++;
+
+	if (unlikely(rdes2 & RDES2_SA_FILTER_FAIL)) {
+		x->sa_rx_filter_fail++;
+		ret = discard_frame;
+	}
+	if (unlikely(rdes2 & RDES2_DA_FILTER_FAIL)) {
+		x->da_rx_filter_fail++;
+		ret = discard_frame;
+	}
+
+	if (rdes2 & RDES2_L3_FILTER_MATCH)
+		x->l3_filter_match++;
+	if (rdes2 & RDES2_L4_FILTER_MATCH)
+		x->l4_filter_match++;
+	if ((rdes2 & RDES2_L3_L4_FILT_NB_MATCH_MASK)
+	    >> RDES2_L3_L4_FILT_NB_MATCH_SHIFT)
+		x->l3_l4_filter_no_match++;
+
+	return ret;
+}
+
+static int dwmac4_rd_get_tx_len(struct dma_desc *p)
+{
+	return (p->des2 & TDES2_BUFFER1_SIZE_MASK);
+}
+
+static int dwmac4_get_tx_owner(struct dma_desc *p)
+{
+	return (p->des3 & TDES3_OWN) >> TDES3_OWN_SHIFT;
+}
+
+static void dwmac4_set_tx_owner(struct dma_desc *p)
+{
+	p->des3 |= TDES3_OWN;
+}
+
+static void dwmac4_set_rx_owner(struct dma_desc *p)
+{
+	p->des3 |= RDES3_OWN;
+}
+
+static int dwmac4_get_tx_ls(struct dma_desc *p)
+{
+	return (p->des3 & TDES3_LAST_DESCRIPTOR) >> TDES3_LAST_DESCRIPTOR_SHIFT;
+}
+
+static int dwmac4_wrback_get_rx_frame_len(struct dma_desc *p, int rx_coe)
+{
+	return (p->des3 & RDES3_PACKET_SIZE_MASK);
+}
+
+static void dwmac4_rd_enable_tx_timestamp(struct dma_desc *p)
+{
+	p->des2 |= TDES2_TIMESTAMP_ENABLE;
+}
+
+static int dwmac4_wrback_get_tx_timestamp_status(struct dma_desc *p)
+{
+	return (p->des3 & TDES3_TIMESTAMP_STATUS)
+		>> TDES3_TIMESTAMP_STATUS_SHIFT;
+}
+
+/*  NOTE: For RX CTX bit has to be checked before
+ *  HAVE a specific function for TX and another one for RX
+ */
+static u64 dwmac4_wrback_get_timestamp(void *desc, u32 ats)
+{
+	struct dma_desc *p = (struct dma_desc *)desc;
+	u64 ns;
+
+	ns = p->des0;
+	/* convert high/sec time stamp value to nanosecond */
+	ns += p->des1 * 1000000000ULL;
+
+	return ns;
+}
+
+static int dwmac4_context_get_rx_timestamp_status(void *desc, u32 ats)
+{
+	struct dma_desc *p = (struct dma_desc *)desc;
+
+	return (p->des1 & RDES1_TIMESTAMP_AVAILABLE)
+		>> RDES1_TIMESTAMP_AVAILABLE_SHIFT;
+}
+
+static void dwmac4_rd_init_rx_desc(struct dma_desc *p, int disable_rx_ic,
+				   int mode, int end)
+{
+	p->des3 = RDES3_OWN | RDES3_BUFFER1_VALID_ADDR;
+
+	if (!disable_rx_ic)
+		p->des3 |= RDES3_INT_ON_COMPLETION_EN;
+}
+
+static void dwmac4_rd_init_tx_desc(struct dma_desc *p, int mode, int end)
+{
+	p->des0 = 0;
+	p->des1 = 0;
+	p->des2 = 0;
+	p->des3 = 0;
+}
+
+static void dwmac4_rd_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
+				      bool csum_flag, int mode, bool tx_own,
+				      bool ls)
+{
+	unsigned int tdes3 = p->des3;
+
+	if (unlikely(len > BUF_SIZE_16KiB)) {
+		p->des2 |= (((len - BUF_SIZE_16KiB) <<
+			     TDES2_BUFFER2_SIZE_MASK_SHIFT)
+			    & TDES2_BUFFER2_SIZE_MASK)
+			    | (BUF_SIZE_16KiB & TDES2_BUFFER1_SIZE_MASK);
+	} else {
+		p->des2 |= (len & TDES2_BUFFER1_SIZE_MASK);
+	}
+
+	if (is_fs)
+		tdes3 |= TDES3_FIRST_DESCRIPTOR;
+	else
+		tdes3 &= ~TDES3_FIRST_DESCRIPTOR;
+
+	if (likely(csum_flag))
+		tdes3 |= (TX_CIC_FULL << TDES3_CHECKSUM_INSERTION_SHIFT);
+	else
+		tdes3 &= ~(TX_CIC_FULL << TDES3_CHECKSUM_INSERTION_SHIFT);
+
+	if (ls)
+		tdes3 |= TDES3_LAST_DESCRIPTOR;
+	else
+		tdes3 &= ~TDES3_LAST_DESCRIPTOR;
+
+	/* Finally set the OWN bit. Later the DMA will start! */
+	if (tx_own)
+		tdes3 |= TDES3_OWN;
+
+	if (is_fs & tx_own)
+		/* When the own bit, for the first frame, has to be set, all
+		 * descriptors for the same frame has to be set before, to
+		 * avoid race condition.
+		 */
+		wmb();
+
+	p->des3 = tdes3;
+}
+
+static void dwmac4_rd_prepare_tso_tx_desc(struct dma_desc *p, int is_fs,
+					  int len1, int len2, bool tx_own,
+					  bool ls, unsigned int tcphdrlen,
+					  unsigned int tcppayloadlen)
+{
+	unsigned int tdes3 = p->des3;
+
+	if (len1)
+		p->des2 |= (len1 & TDES2_BUFFER1_SIZE_MASK);
+
+	if (len2)
+		p->des2 |= (len2 << TDES2_BUFFER2_SIZE_MASK_SHIFT)
+			    & TDES2_BUFFER2_SIZE_MASK;
+
+	if (is_fs) {
+		tdes3 |= TDES3_FIRST_DESCRIPTOR |
+			 TDES3_TCP_SEGMENTATION_ENABLE |
+			 ((tcphdrlen << TDES3_HDR_LEN_SHIFT) &
+			  TDES3_SLOT_NUMBER_MASK) |
+			 ((tcppayloadlen & TDES3_TCP_PKT_PAYLOAD_MASK));
+	} else {
+		tdes3 &= ~TDES3_FIRST_DESCRIPTOR;
+	}
+
+	if (ls)
+		tdes3 |= TDES3_LAST_DESCRIPTOR;
+	else
+		tdes3 &= ~TDES3_LAST_DESCRIPTOR;
+
+	/* Finally set the OWN bit. Later the DMA will start! */
+	if (tx_own)
+		tdes3 |= TDES3_OWN;
+
+	if (is_fs & tx_own)
+		/* When the own bit, for the first frame, has to be set, all
+		 * descriptors for the same frame has to be set before, to
+		 * avoid race condition.
+		 */
+		wmb();
+
+	p->des3 = tdes3;
+}
+
+static void dwmac4_release_tx_desc(struct dma_desc *p, int mode)
+{
+	p->des2 = 0;
+	p->des3 = 0;
+}
+
+static void dwmac4_rd_set_tx_ic(struct dma_desc *p)
+{
+	p->des2 |= TDES2_INTERRUPT_ON_COMPLETION;
+}
+
+static void dwmac4_display_ring(void *head, unsigned size, bool rx)
+{
+	struct dma_desc *p = (struct dma_desc *)head;
+	int i;
+
+	pr_info("%s descriptor ring:\n", rx ? "RX" : "TX");
+
+	for (i = 0; i < size; i++) {
+		if (p->des0)
+			pr_info("%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
+				i, (unsigned int)virt_to_phys(p),
+				p->des0, p->des1, p->des2, p->des3);
+		p++;
+	}
+}
+
+static void dwmac4_set_mss_ctxt(struct dma_desc *p, unsigned int mss)
+{
+	p->des0 = 0;
+	p->des1 = 0;
+	p->des2 = mss;
+	p->des3 = TDES3_CONTEXT_TYPE | TDES3_CTXT_TCMSSV;
+}
+
+const struct stmmac_desc_ops dwmac4_desc_ops = {
+	.tx_status = dwmac4_wrback_get_tx_status,
+	.rx_status = dwmac4_wrback_get_rx_status,
+	.get_tx_len = dwmac4_rd_get_tx_len,
+	.get_tx_owner = dwmac4_get_tx_owner,
+	.set_tx_owner = dwmac4_set_tx_owner,
+	.set_rx_owner = dwmac4_set_rx_owner,
+	.get_tx_ls = dwmac4_get_tx_ls,
+	.get_rx_frame_len = dwmac4_wrback_get_rx_frame_len,
+	.enable_tx_timestamp = dwmac4_rd_enable_tx_timestamp,
+	.get_tx_timestamp_status = dwmac4_wrback_get_tx_timestamp_status,
+	.get_timestamp = dwmac4_wrback_get_timestamp,
+	.get_rx_timestamp_status = dwmac4_context_get_rx_timestamp_status,
+	.set_tx_ic = dwmac4_rd_set_tx_ic,
+	.prepare_tx_desc = dwmac4_rd_prepare_tx_desc,
+	.prepare_tso_tx_desc = dwmac4_rd_prepare_tso_tx_desc,
+	.release_tx_desc = dwmac4_release_tx_desc,
+	.init_rx_desc = dwmac4_rd_init_rx_desc,
+	.init_tx_desc = dwmac4_rd_init_tx_desc,
+	.display_ring = dwmac4_display_ring,
+	.set_mss = dwmac4_set_mss_ctxt,
+};
+
+const struct stmmac_mode_ops dwmac4_ring_mode_ops = { };
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h
new file mode 100644
index 0000000..0902a2e
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h
@@ -0,0 +1,129 @@
+/*
+ * Header File to describe the DMA descriptors and related definitions specific
+ * for DesignWare databook 4.xx.
+ *
+ * Copyright (C) 2015  STMicroelectronics Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * Author: Alexandre Torgue <alexandre.torgue@st.com>
+ */
+
+#ifndef __DWMAC4_DESCS_H__
+#define __DWMAC4_DESCS_H__
+
+#include <linux/bitops.h>
+
+/* Normal transmit descriptor defines (without split feature) */
+
+/* TDES2 (read format) */
+#define TDES2_BUFFER1_SIZE_MASK		GENMASK(13, 0)
+#define TDES2_VLAN_TAG_MASK		GENMASK(15, 14)
+#define TDES2_BUFFER2_SIZE_MASK		GENMASK(29, 16)
+#define TDES2_BUFFER2_SIZE_MASK_SHIFT	16
+#define TDES2_TIMESTAMP_ENABLE		BIT(30)
+#define TDES2_INTERRUPT_ON_COMPLETION	BIT(31)
+
+/* TDES3 (read format) */
+#define TDES3_PACKET_SIZE_MASK		GENMASK(14, 0)
+#define TDES3_CHECKSUM_INSERTION_MASK	GENMASK(17, 16)
+#define TDES3_CHECKSUM_INSERTION_SHIFT	16
+#define TDES3_TCP_PKT_PAYLOAD_MASK	GENMASK(17, 0)
+#define TDES3_TCP_SEGMENTATION_ENABLE	BIT(18)
+#define TDES3_HDR_LEN_SHIFT		19
+#define TDES3_SLOT_NUMBER_MASK		GENMASK(22, 19)
+#define TDES3_SA_INSERT_CTRL_MASK	GENMASK(25, 23)
+#define TDES3_CRC_PAD_CTRL_MASK		GENMASK(27, 26)
+
+/* TDES3 (write back format) */
+#define TDES3_IP_HDR_ERROR		BIT(0)
+#define TDES3_DEFERRED			BIT(1)
+#define TDES3_UNDERFLOW_ERROR		BIT(2)
+#define TDES3_EXCESSIVE_DEFERRAL	BIT(3)
+#define TDES3_COLLISION_COUNT_MASK	GENMASK(7, 4)
+#define TDES3_COLLISION_COUNT_SHIFT	4
+#define TDES3_EXCESSIVE_COLLISION	BIT(8)
+#define TDES3_LATE_COLLISION		BIT(9)
+#define TDES3_NO_CARRIER		BIT(10)
+#define TDES3_LOSS_CARRIER		BIT(11)
+#define TDES3_PAYLOAD_ERROR		BIT(12)
+#define TDES3_PACKET_FLUSHED		BIT(13)
+#define TDES3_JABBER_TIMEOUT		BIT(14)
+#define TDES3_ERROR_SUMMARY		BIT(15)
+#define TDES3_TIMESTAMP_STATUS		BIT(17)
+#define TDES3_TIMESTAMP_STATUS_SHIFT	17
+
+/* TDES3 context */
+#define TDES3_CTXT_TCMSSV		BIT(26)
+
+/* TDES3 Common */
+#define TDES3_LAST_DESCRIPTOR		BIT(28)
+#define TDES3_LAST_DESCRIPTOR_SHIFT	28
+#define TDES3_FIRST_DESCRIPTOR		BIT(29)
+#define TDES3_CONTEXT_TYPE		BIT(30)
+
+/* TDS3 use for both format (read and write back) */
+#define TDES3_OWN			BIT(31)
+#define TDES3_OWN_SHIFT			31
+
+/* Normal receive descriptor defines (without split feature) */
+
+/* RDES0 (write back format) */
+#define RDES0_VLAN_TAG_MASK		GENMASK(15, 0)
+
+/* RDES1 (write back format) */
+#define RDES1_IP_PAYLOAD_TYPE_MASK	GENMASK(2, 0)
+#define RDES1_IP_HDR_ERROR		BIT(3)
+#define RDES1_IPV4_HEADER		BIT(4)
+#define RDES1_IPV6_HEADER		BIT(5)
+#define RDES1_IP_CSUM_BYPASSED		BIT(6)
+#define RDES1_IP_CSUM_ERROR		BIT(7)
+#define RDES1_PTP_MSG_TYPE_MASK		GENMASK(11, 8)
+#define RDES1_PTP_PACKET_TYPE		BIT(12)
+#define RDES1_PTP_VER			BIT(13)
+#define RDES1_TIMESTAMP_AVAILABLE	BIT(14)
+#define RDES1_TIMESTAMP_AVAILABLE_SHIFT	14
+#define RDES1_TIMESTAMP_DROPPED		BIT(15)
+#define RDES1_IP_TYPE1_CSUM_MASK	GENMASK(31, 16)
+
+/* RDES2 (write back format) */
+#define RDES2_L3_L4_HEADER_SIZE_MASK	GENMASK(9, 0)
+#define RDES2_VLAN_FILTER_STATUS	BIT(15)
+#define RDES2_SA_FILTER_FAIL		BIT(16)
+#define RDES2_DA_FILTER_FAIL		BIT(17)
+#define RDES2_HASH_FILTER_STATUS	BIT(18)
+#define RDES2_MAC_ADDR_MATCH_MASK	GENMASK(26, 19)
+#define RDES2_HASH_VALUE_MATCH_MASK	GENMASK(26, 19)
+#define RDES2_L3_FILTER_MATCH		BIT(27)
+#define RDES2_L4_FILTER_MATCH		BIT(28)
+#define RDES2_L3_L4_FILT_NB_MATCH_MASK	GENMASK(27, 26)
+#define RDES2_L3_L4_FILT_NB_MATCH_SHIFT	26
+
+/* RDES3 (write back format) */
+#define RDES3_PACKET_SIZE_MASK		GENMASK(14, 0)
+#define RDES3_ERROR_SUMMARY		BIT(15)
+#define RDES3_PACKET_LEN_TYPE_MASK	GENMASK(18, 16)
+#define RDES3_DRIBBLE_ERROR		BIT(19)
+#define RDES3_RECEIVE_ERROR		BIT(20)
+#define RDES3_OVERFLOW_ERROR		BIT(21)
+#define RDES3_RECEIVE_WATCHDOG		BIT(22)
+#define RDES3_GIANT_PACKET		BIT(23)
+#define RDES3_CRC_ERROR			BIT(24)
+#define RDES3_RDES0_VALID		BIT(25)
+#define RDES3_RDES1_VALID		BIT(26)
+#define RDES3_RDES2_VALID		BIT(27)
+#define RDES3_LAST_DESCRIPTOR		BIT(28)
+#define RDES3_FIRST_DESCRIPTOR		BIT(29)
+#define RDES3_CONTEXT_DESCRIPTOR	BIT(30)
+
+/* RDES3 (read format) */
+#define RDES3_BUFFER1_VALID_ADDR	BIT(24)
+#define RDES3_BUFFER2_VALID_ADDR	BIT(25)
+#define RDES3_INT_ON_COMPLETION_EN	BIT(30)
+
+/* TDS3 use for both format (read and write back) */
+#define RDES3_OWN			BIT(31)
+
+#endif /* __DWMAC4_DESCS_H__ */
-- 
1.9.1
