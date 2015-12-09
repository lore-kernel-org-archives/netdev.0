From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 03/18] stmmac: change descriptor layout
Date: Wed, 9 Dec 2015 09:37:39 +0100
Message-ID: <1449650274-14896-4-git-send-email-peppe.cavallaro@st.com>
References: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:12618 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753265AbbLII2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 03:28:05 -0500
Received: from pps.filterd (m0046037.ppops.net [127.0.0.1])
	by m0046037.ppops.net (8.14.5/8.14.5) with SMTP id tB98BkpA031121
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2015 09:28:03 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by m0046037.ppops.net with ESMTP id 1ynn3af6xs-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 09:28:03 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7400D3D
	for <netdev@vger.kernel.org>; Wed,  9 Dec 2015 08:27:26 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id BF9F1461F
	for <netdev@vger.kernel.org>; Wed,  9 Dec 2015 08:28:01 +0000 (GMT)
In-Reply-To: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch completely changes the descriptor layout to improve
the whole performances due to the single read usage of the
descriptors in critical paths.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/descs.h     |  330 ++++++++++-------------
 drivers/net/ethernet/stmicro/stmmac/descs_com.h |   77 +++---
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c  |  190 +++++++------
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c |  121 +++++----
 4 files changed, 355 insertions(+), 363 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/descs.h b/drivers/net/ethernet/stmicro/stmmac/descs.h
index 799c292..2e4c171 100644
--- a/drivers/net/ethernet/stmicro/stmmac/descs.h
+++ b/drivers/net/ethernet/stmicro/stmmac/descs.h
@@ -1,6 +1,6 @@
 /*******************************************************************************
-  Header File to describe the DMA descriptors.
-  Enhanced descriptors have been in case of DWMAC1000 Cores.
+  Header File to describe the DMA descriptors and related definitions.
+  This is for DWMAC100 and 1000 cores.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -24,198 +24,164 @@
 #ifndef __DESCS_H__
 #define __DESCS_H__
 
+#include <linux/bitops.h>
+
+/* Normal receive descriptor defines */
+
+/* RDES0 */
+#define	RDES0_PAYLOAD_CSUM_ERR	BIT(0)
+#define	RDES0_CRC_ERROR		BIT(1)
+#define	RDES0_DRIBBLING		BIT(2)
+#define	RDES0_MII_ERROR		BIT(3)
+#define	RDES0_RECEIVE_WATCHDOG	BIT(4)
+#define	RDES0_FRAME_TYPE	BIT(5)
+#define	RDES0_COLLISION		BIT(6)
+#define	RDES0_IPC_CSUM_ERROR	BIT(7)
+#define	RDES0_LAST_DESCRIPTOR	BIT(8)
+#define	RDES0_FIRST_DESCRIPTOR	BIT(9)
+#define	RDES0_VLAN_TAG		BIT(10)
+#define	RDES0_OVERFLOW_ERROR	BIT(11)
+#define	RDES0_LENGTH_ERROR	BIT(12)
+#define	RDES0_SA_FILTER_FAIL	BIT(13)
+#define	RDES0_DESCRIPTOR_ERROR	BIT(14)
+#define	RDES0_ERROR_SUMMARY	BIT(15)
+#define	RDES0_FRAME_LEN_MASK	GENMASK(29, 16)
+#define RDES0_FRAME_LEN_SHIFT	16
+#define	RDES0_DA_FILTER_FAIL	BIT(30)
+#define	RDES0_OWN		BIT(31)
+			/* RDES1 */
+#define	RDES1_BUFFER1_SIZE_MASK		GENMASK(10, 0)
+#define	RDES1_BUFFER2_SIZE_MASK		GENMASK(21, 11)
+#define	RDES1_BUFFER2_SIZE_SHIFT	11
+#define	RDES1_SECOND_ADDRESS_CHAINED	BIT(24)
+#define	RDES1_END_RING			BIT(25)
+#define	RDES1_DISABLE_IC		BIT(31)
+
+/* Enhanced receive descriptor defines */
+
+/* RDES0 (similar to normal RDES) */
+#define	 ERDES0_RX_MAC_ADDR	BIT(0)
+
+/* RDES1: completely differ from normal desc definitions */
+#define	ERDES1_BUFFER1_SIZE_MASK	GENMASK(12, 0)
+#define	ERDES1_SECOND_ADDRESS_CHAINED	BIT(14)
+#define	ERDES1_END_RING			BIT(15)
+#define	ERDES1_BUFFER2_SIZE_MASK	GENMASK(28, 16)
+#define ERDES1_BUFFER2_SIZE_SHIFT	16
+#define	ERDES1_DISABLE_IC		BIT(31)
+
+/* Normal transmit descriptor defines */
+/* TDES0 */
+#define	TDES0_DEFERRED			BIT(0)
+#define	TDES0_UNDERFLOW_ERROR		BIT(1)
+#define	TDES0_EXCESSIVE_DEFERRAL	BIT(2)
+#define	TDES0_COLLISION_COUNT_MASK	GENMASK(6, 3)
+#define	TDES0_VLAN_FRAME		BIT(7)
+#define	TDES0_EXCESSIVE_COLLISIONS	BIT(8)
+#define	TDES0_LATE_COLLISION		BIT(9)
+#define	TDES0_NO_CARRIER		BIT(10)
+#define	TDES0_LOSS_CARRIER		BIT(11)
+#define	TDES0_PAYLOAD_ERROR		BIT(12)
+#define	TDES0_FRAME_FLUSHED		BIT(13)
+#define	TDES0_JABBER_TIMEOUT		BIT(14)
+#define	TDES0_ERROR_SUMMARY		BIT(15)
+#define	TDES0_IP_HEADER_ERROR		BIT(16)
+#define	TDES0_TIME_STAMP_STATUS		BIT(17)
+#define	TDES0_OWN			BIT(31)
+/* TDES1 */
+#define	TDES1_BUFFER1_SIZE_MASK		GENMASK(10, 0)
+#define	TDES1_BUFFER2_SIZE_MASK		GENMASK(21, 11)
+#define	TDES1_BUFFER2_SIZE_SHIFT	11
+#define	TDES1_TIME_STAMP_ENABLE		BIT(22)
+#define	TDES1_DISABLE_PADDING		BIT(23)
+#define	TDES1_SECOND_ADDRESS_CHAINED	BIT(24)
+#define	TDES1_END_RING			BIT(25)
+#define	TDES1_CRC_DISABLE		BIT(26)
+#define	TDES1_CHECKSUM_INSERTION_MASK	GENMASK(28, 27)
+#define	TDES1_CHECKSUM_INSERTION_SHIFT	27
+#define	TDES1_FIRST_SEGMENT		BIT(29)
+#define	TDES1_LAST_SEGMENT		BIT(30)
+#define	TDES1_INTERRUPT			BIT(31)
+
+/* Enhanced transmit descriptor defines */
+/* TDES0 */
+#define	ETDES0_DEFERRED			BIT(0)
+#define	ETDES0_UNDERFLOW_ERROR		BIT(1)
+#define	ETDES0_EXCESSIVE_DEFERRAL	BIT(2)
+#define	ETDES0_COLLISION_COUNT_MASK	GENMASK(6, 3)
+#define	ETDES0_VLAN_FRAME		BIT(7)
+#define	ETDES0_EXCESSIVE_COLLISIONS	BIT(8)
+#define	ETDES0_LATE_COLLISION		BIT(9)
+#define	ETDES0_NO_CARRIER		BIT(10)
+#define	ETDES0_LOSS_CARRIER		BIT(11)
+#define	ETDES0_PAYLOAD_ERROR		BIT(12)
+#define	ETDES0_FRAME_FLUSHED		BIT(13)
+#define	ETDES0_JABBER_TIMEOUT		BIT(14)
+#define	ETDES0_ERROR_SUMMARY		BIT(15)
+#define	ETDES0_IP_HEADER_ERROR		BIT(16)
+#define	ETDES0_TIME_STAMP_STATUS	BIT(17)
+#define	ETDES0_SECOND_ADDRESS_CHAINED	BIT(20)
+#define	ETDES0_END_RING			BIT(21)
+#define	ETDES0_CHECKSUM_INSERTION_MASK	GENMASK(23, 22)
+#define	ETDES0_CHECKSUM_INSERTION_SHIFT	22
+#define	ETDES0_TIME_STAMP_ENABLE	BIT(25)
+#define	ETDES0_DISABLE_PADDING		BIT(26)
+#define	ETDES0_CRC_DISABLE		BIT(27)
+#define	ETDES0_FIRST_SEGMENT		BIT(28)
+#define	ETDES0_LAST_SEGMENT		BIT(29)
+#define	ETDES0_INTERRUPT		BIT(30)
+#define	ETDES0_OWN			BIT(31)
+/* TDES1 */
+#define	ETDES1_BUFFER1_SIZE_MASK	GENMASK(12, 0)
+#define	ETDES1_BUFFER2_SIZE_MASK	GENMASK(28, 16)
+#define	ETDES1_BUFFER2_SIZE_SHIFT	16
+
+/* Extended Receive descriptor definitions */
+#define	ERDES4_IP_PAYLOAD_TYPE_MASK	GENMASK(2, 6)
+#define	ERDES4_IP_HDR_ERR		BIT(3)
+#define	ERDES4_IP_PAYLOAD_ERR		BIT(4)
+#define	ERDES4_IP_CSUM_BYPASSED		BIT(5)
+#define	ERDES4_IPV4_PKT_RCVD		BIT(6)
+#define	ERDES4_IPV6_PKT_RCVD		BIT(7)
+#define	ERDES4_MSG_TYPE_MASK		GENMASK(11, 8)
+#define	ERDES4_PTP_FRAME_TYPE		BIT(12)
+#define	ERDES4_PTP_VER			BIT(13)
+#define	ERDES4_TIMESTAMP_DROPPED	BIT(14)
+#define	ERDES4_AV_PKT_RCVD		BIT(16)
+#define	ERDES4_AV_TAGGED_PKT_RCVD	BIT(17)
+#define	ERDES4_VLAN_TAG_PRI_VAL_MASK	GENMASK(20, 18)
+#define	ERDES4_L3_FILTER_MATCH		BIT(24)
+#define	ERDES4_L4_FILTER_MATCH		BIT(25)
+#define	ERDES4_L3_L4_FILT_NO_MATCH_MASK	GENMASK(27, 26)
+
+/* Extended RDES4 message type definitions */
+#define RDES_EXT_NO_PTP			0
+#define RDES_EXT_SYNC			1
+#define RDES_EXT_FOLLOW_UP		2
+#define RDES_EXT_DELAY_REQ		3
+#define RDES_EXT_DELAY_RESP		4
+#define RDES_EXT_PDELAY_REQ		5
+#define RDES_EXT_PDELAY_RESP		6
+#define RDES_EXT_PDELAY_FOLLOW_UP	7
+
 /* Basic descriptor structure for normal and alternate descriptors */
 struct dma_desc {
-	/* Receive descriptor */
-	union {
-		struct {
-			/* RDES0 */
-			u32 payload_csum_error:1;
-			u32 crc_error:1;
-			u32 dribbling:1;
-			u32 mii_error:1;
-			u32 receive_watchdog:1;
-			u32 frame_type:1;
-			u32 collision:1;
-			u32 ipc_csum_error:1;
-			u32 last_descriptor:1;
-			u32 first_descriptor:1;
-			u32 vlan_tag:1;
-			u32 overflow_error:1;
-			u32 length_error:1;
-			u32 sa_filter_fail:1;
-			u32 descriptor_error:1;
-			u32 error_summary:1;
-			u32 frame_length:14;
-			u32 da_filter_fail:1;
-			u32 own:1;
-			/* RDES1 */
-			u32 buffer1_size:11;
-			u32 buffer2_size:11;
-			u32 reserved1:2;
-			u32 second_address_chained:1;
-			u32 end_ring:1;
-			u32 reserved2:5;
-			u32 disable_ic:1;
-
-		} rx;
-		struct {
-			/* RDES0 */
-			u32 rx_mac_addr:1;
-			u32 crc_error:1;
-			u32 dribbling:1;
-			u32 error_gmii:1;
-			u32 receive_watchdog:1;
-			u32 frame_type:1;
-			u32 late_collision:1;
-			u32 ipc_csum_error:1;
-			u32 last_descriptor:1;
-			u32 first_descriptor:1;
-			u32 vlan_tag:1;
-			u32 overflow_error:1;
-			u32 length_error:1;
-			u32 sa_filter_fail:1;
-			u32 descriptor_error:1;
-			u32 error_summary:1;
-			u32 frame_length:14;
-			u32 da_filter_fail:1;
-			u32 own:1;
-			/* RDES1 */
-			u32 buffer1_size:13;
-			u32 reserved1:1;
-			u32 second_address_chained:1;
-			u32 end_ring:1;
-			u32 buffer2_size:13;
-			u32 reserved2:2;
-			u32 disable_ic:1;
-		} erx;		/* -- enhanced -- */
-
-		/* Transmit descriptor */
-		struct {
-			/* TDES0 */
-			u32 deferred:1;
-			u32 underflow_error:1;
-			u32 excessive_deferral:1;
-			u32 collision_count:4;
-			u32 vlan_frame:1;
-			u32 excessive_collisions:1;
-			u32 late_collision:1;
-			u32 no_carrier:1;
-			u32 loss_carrier:1;
-			u32 payload_error:1;
-			u32 frame_flushed:1;
-			u32 jabber_timeout:1;
-			u32 error_summary:1;
-			u32 ip_header_error:1;
-			u32 time_stamp_status:1;
-			u32 reserved1:13;
-			u32 own:1;
-			/* TDES1 */
-			u32 buffer1_size:11;
-			u32 buffer2_size:11;
-			u32 time_stamp_enable:1;
-			u32 disable_padding:1;
-			u32 second_address_chained:1;
-			u32 end_ring:1;
-			u32 crc_disable:1;
-			u32 checksum_insertion:2;
-			u32 first_segment:1;
-			u32 last_segment:1;
-			u32 interrupt:1;
-		} tx;
-		struct {
-			/* TDES0 */
-			u32 deferred:1;
-			u32 underflow_error:1;
-			u32 excessive_deferral:1;
-			u32 collision_count:4;
-			u32 vlan_frame:1;
-			u32 excessive_collisions:1;
-			u32 late_collision:1;
-			u32 no_carrier:1;
-			u32 loss_carrier:1;
-			u32 payload_error:1;
-			u32 frame_flushed:1;
-			u32 jabber_timeout:1;
-			u32 error_summary:1;
-			u32 ip_header_error:1;
-			u32 time_stamp_status:1;
-			u32 reserved1:2;
-			u32 second_address_chained:1;
-			u32 end_ring:1;
-			u32 checksum_insertion:2;
-			u32 reserved2:1;
-			u32 time_stamp_enable:1;
-			u32 disable_padding:1;
-			u32 crc_disable:1;
-			u32 first_segment:1;
-			u32 last_segment:1;
-			u32 interrupt:1;
-			u32 own:1;
-			/* TDES1 */
-			u32 buffer1_size:13;
-			u32 reserved3:3;
-			u32 buffer2_size:13;
-			u32 reserved4:3;
-		} etx;		/* -- enhanced -- */
-
-		u64 all_flags;
-	} des01;
+	unsigned int des0;
+	unsigned int des1;
 	unsigned int des2;
 	unsigned int des3;
 };
 
-/* Extended descriptor structure (supported by new SYNP GMAC generations) */
+/* Extended descriptor structure (e.g. >= databook 3.50a) */
 struct dma_extended_desc {
-	struct dma_desc basic;
-	union {
-		struct {
-			u32 ip_payload_type:3;
-			u32 ip_hdr_err:1;
-			u32 ip_payload_err:1;
-			u32 ip_csum_bypassed:1;
-			u32 ipv4_pkt_rcvd:1;
-			u32 ipv6_pkt_rcvd:1;
-			u32 msg_type:4;
-			u32 ptp_frame_type:1;
-			u32 ptp_ver:1;
-			u32 timestamp_dropped:1;
-			u32 reserved:1;
-			u32 av_pkt_rcvd:1;
-			u32 av_tagged_pkt_rcvd:1;
-			u32 vlan_tag_priority_val:3;
-			u32 reserved3:3;
-			u32 l3_filter_match:1;
-			u32 l4_filter_match:1;
-			u32 l3_l4_filter_no_match:2;
-			u32 reserved4:4;
-		} erx;
-		struct {
-			u32 reserved;
-		} etx;
-	} des4;
+	struct dma_desc basic;	/* Basic descriptors */
+	unsigned int des4;	/* Extended Status */
 	unsigned int des5;	/* Reserved */
 	unsigned int des6;	/* Tx/Rx Timestamp Low */
 	unsigned int des7;	/* Tx/Rx Timestamp High */
 };
 
 /* Transmit checksum insertion control */
-enum tdes_csum_insertion {
-	cic_disabled = 0,	/* Checksum Insertion Control */
-	cic_only_ip = 1,	/* Only IP header */
-	/* IP header but pseudoheader is not calculated */
-	cic_no_pseudoheader = 2,
-	cic_full = 3,		/* IP header and pseudoheader */
-};
-
-/* Extended RDES4 definitions */
-#define RDES_EXT_NO_PTP			0
-#define RDES_EXT_SYNC			0x1
-#define RDES_EXT_FOLLOW_UP		0x2
-#define RDES_EXT_DELAY_REQ		0x3
-#define RDES_EXT_DELAY_RESP		0x4
-#define RDES_EXT_PDELAY_REQ		0x5
-#define RDES_EXT_PDELAY_RESP		0x6
-#define RDES_EXT_PDELAY_FOLLOW_UP	0x7
+#define	TX_CIC_FULL	3	/* Include IP header and pseudoheader */
 
 #endif /* __DESCS_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/descs_com.h b/drivers/net/ethernet/stmicro/stmmac/descs_com.h
index 6f2cc78..7635a46 100644
--- a/drivers/net/ethernet/stmicro/stmmac/descs_com.h
+++ b/drivers/net/ethernet/stmicro/stmmac/descs_com.h
@@ -35,100 +35,91 @@
 /* Enhanced descriptors */
 static inline void ehn_desc_rx_set_on_ring(struct dma_desc *p, int end)
 {
-	p->des01.erx.buffer2_size = BUF_SIZE_8KiB - 1;
-	if (end)
-		p->des01.erx.end_ring = 1;
-}
+	p->des1 |= ((BUF_SIZE_8KiB - 1) << ERDES1_BUFFER2_SIZE_SHIFT)
+		   & ERDES1_BUFFER2_SIZE_MASK;
 
-static inline void ehn_desc_tx_set_on_ring(struct dma_desc *p, int end)
-{
 	if (end)
-		p->des01.etx.end_ring = 1;
+		p->des1 |= ERDES1_END_RING;
 }
 
-static inline void enh_desc_end_tx_desc_on_ring(struct dma_desc *p, int ter)
+static inline void enh_desc_end_tx_desc_on_ring(struct dma_desc *p, int end)
 {
-	p->des01.etx.end_ring = ter;
+	if (end)
+		p->des0 |= ETDES0_END_RING;
+	else
+		p->des0 &= ~ETDES0_END_RING;
 }
 
 static inline void enh_set_tx_desc_len_on_ring(struct dma_desc *p, int len)
 {
 	if (unlikely(len > BUF_SIZE_4KiB)) {
-		p->des01.etx.buffer1_size = BUF_SIZE_4KiB;
-		p->des01.etx.buffer2_size = len - BUF_SIZE_4KiB;
+		p->des1 |= (((len - BUF_SIZE_4KiB) << ETDES1_BUFFER2_SIZE_SHIFT)
+			    & ETDES1_BUFFER2_SIZE_MASK) | (BUF_SIZE_4KiB
+			    & ETDES1_BUFFER1_SIZE_MASK);
 	} else
-		p->des01.etx.buffer1_size = len;
+		p->des1 |= (len & ETDES1_BUFFER1_SIZE_MASK);
 }
 
 /* Normal descriptors */
 static inline void ndesc_rx_set_on_ring(struct dma_desc *p, int end)
 {
-	p->des01.rx.buffer2_size = BUF_SIZE_2KiB - 1;
-	if (end)
-		p->des01.rx.end_ring = 1;
-}
+	p->des1 |= ((BUF_SIZE_2KiB - 1) << RDES1_BUFFER2_SIZE_SHIFT)
+		    & RDES1_BUFFER2_SIZE_MASK;
 
-static inline void ndesc_tx_set_on_ring(struct dma_desc *p, int end)
-{
 	if (end)
-		p->des01.tx.end_ring = 1;
+		p->des1 |= RDES1_END_RING;
 }
 
-static inline void ndesc_end_tx_desc_on_ring(struct dma_desc *p, int ter)
+static inline void ndesc_end_tx_desc_on_ring(struct dma_desc *p, int end)
 {
-	p->des01.tx.end_ring = ter;
+	if (end)
+		p->des1 |= TDES1_END_RING;
+	else
+		p->des1 &= ~TDES1_END_RING;
 }
 
 static inline void norm_set_tx_desc_len_on_ring(struct dma_desc *p, int len)
 {
 	if (unlikely(len > BUF_SIZE_2KiB)) {
-		p->des01.etx.buffer1_size = BUF_SIZE_2KiB - 1;
-		p->des01.etx.buffer2_size = len - p->des01.etx.buffer1_size;
+		unsigned int buffer1 = (BUF_SIZE_2KiB - 1)
+					& TDES1_BUFFER1_SIZE_MASK;
+		p->des1 |= ((((len - buffer1) << TDES1_BUFFER2_SIZE_SHIFT)
+			    & TDES1_BUFFER2_SIZE_MASK) | buffer1);
 	} else
-		p->des01.tx.buffer1_size = len;
+		p->des1 |= (len & TDES1_BUFFER1_SIZE_MASK);
 }
 
 /* Specific functions used for Chain mode */
 
 /* Enhanced descriptors */
-static inline void ehn_desc_rx_set_on_chain(struct dma_desc *p, int end)
-{
-	p->des01.erx.second_address_chained = 1;
-}
-
-static inline void ehn_desc_tx_set_on_chain(struct dma_desc *p, int end)
+static inline void ehn_desc_rx_set_on_chain(struct dma_desc *p)
 {
-	p->des01.etx.second_address_chained = 1;
+	p->des1 |= ERDES1_SECOND_ADDRESS_CHAINED;
 }
 
-static inline void enh_desc_end_tx_desc_on_chain(struct dma_desc *p, int ter)
+static inline void enh_desc_end_tx_desc_on_chain(struct dma_desc *p)
 {
-	p->des01.etx.second_address_chained = 1;
+	p->des0 |= ETDES0_SECOND_ADDRESS_CHAINED;
 }
 
 static inline void enh_set_tx_desc_len_on_chain(struct dma_desc *p, int len)
 {
-	p->des01.etx.buffer1_size = len;
+	p->des1 |= (len & ETDES1_BUFFER1_SIZE_MASK);
 }
 
 /* Normal descriptors */
 static inline void ndesc_rx_set_on_chain(struct dma_desc *p, int end)
 {
-	p->des01.rx.second_address_chained = 1;
-}
-
-static inline void ndesc_tx_set_on_chain(struct dma_desc *p, int ring_size)
-{
-	p->des01.tx.second_address_chained = 1;
+	p->des1 |= RDES1_SECOND_ADDRESS_CHAINED;
 }
 
-static inline void ndesc_end_tx_desc_on_chain(struct dma_desc *p, int ter)
+static inline void ndesc_tx_set_on_chain(struct dma_desc *p)
 {
-	p->des01.tx.second_address_chained = 1;
+	p->des1 |= TDES1_SECOND_ADDRESS_CHAINED;
 }
 
 static inline void norm_set_tx_desc_len_on_chain(struct dma_desc *p, int len)
 {
-	p->des01.tx.buffer1_size = len;
+	p->des1 |= len & TDES1_BUFFER1_SIZE_MASK;
 }
 #endif /* __DESC_COM_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index 7d94444..716b807 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
   This contains the functions to handle the enhanced descriptors.
 
-  Copyright (C) 2007-2009  STMicroelectronics Ltd
+  Copyright (C) 2007-2014  STMicroelectronics Ltd
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -29,44 +29,44 @@
 static int enh_desc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 				  struct dma_desc *p, void __iomem *ioaddr)
 {
-	int ret = 0;
 	struct net_device_stats *stats = (struct net_device_stats *)data;
+	unsigned int tdes0 = p->des0;
+	int ret = 0;
 
-	if (unlikely(p->des01.etx.error_summary)) {
-		if (unlikely(p->des01.etx.jabber_timeout))
+	if (unlikely(tdes0 & ETDES0_ERROR_SUMMARY)) {
+		if (unlikely(tdes0 & ETDES0_JABBER_TIMEOUT))
 			x->tx_jabber++;
 
-		if (unlikely(p->des01.etx.frame_flushed)) {
+		if (unlikely(tdes0 & ETDES0_FRAME_FLUSHED)) {
 			x->tx_frame_flushed++;
 			dwmac_dma_flush_tx_fifo(ioaddr);
 		}
 
-		if (unlikely(p->des01.etx.loss_carrier)) {
+		if (unlikely(tdes0 & ETDES0_LOSS_CARRIER)) {
 			x->tx_losscarrier++;
 			stats->tx_carrier_errors++;
 		}
-		if (unlikely(p->des01.etx.no_carrier)) {
+		if (unlikely(tdes0 & ETDES0_NO_CARRIER)) {
 			x->tx_carrier++;
 			stats->tx_carrier_errors++;
 		}
-		if (unlikely(p->des01.etx.late_collision))
-			stats->collisions += p->des01.etx.collision_count;
-
-		if (unlikely(p->des01.etx.excessive_collisions))
-			stats->collisions += p->des01.etx.collision_count;
+		if (unlikely((tdes0 & ETDES0_LATE_COLLISION) ||
+			     (tdes0 & ETDES0_EXCESSIVE_COLLISIONS)))
+			stats->collisions +=
+				(tdes0 & ETDES0_COLLISION_COUNT_MASK) >> 3;
 
-		if (unlikely(p->des01.etx.excessive_deferral))
+		if (unlikely(tdes0 & ETDES0_EXCESSIVE_DEFERRAL))
 			x->tx_deferred++;
 
-		if (unlikely(p->des01.etx.underflow_error)) {
+		if (unlikely(tdes0 & ETDES0_UNDERFLOW_ERROR)) {
 			dwmac_dma_flush_tx_fifo(ioaddr);
 			x->tx_underflow++;
 		}
 
-		if (unlikely(p->des01.etx.ip_header_error))
+		if (unlikely(tdes0 & ETDES0_IP_HEADER_ERROR))
 			x->tx_ip_header_error++;
 
-		if (unlikely(p->des01.etx.payload_error)) {
+		if (unlikely(tdes0 & ETDES0_PAYLOAD_ERROR)) {
 			x->tx_payload_error++;
 			dwmac_dma_flush_tx_fifo(ioaddr);
 		}
@@ -74,11 +74,11 @@ static int enh_desc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 		ret = -1;
 	}
 
-	if (unlikely(p->des01.etx.deferred))
+	if (unlikely(tdes0 & ETDES0_DEFERRED))
 		x->tx_deferred++;
 
 #ifdef STMMAC_VLAN_TAG_USED
-	if (p->des01.etx.vlan_frame)
+	if (tdes0 & ETDES0_VLAN_FRAME)
 		x->tx_vlan++;
 #endif
 
@@ -87,7 +87,7 @@ static int enh_desc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 
 static int enh_desc_get_tx_len(struct dma_desc *p)
 {
-	return p->des01.etx.buffer1_size;
+	return (p->des1 & ETDES1_BUFFER1_SIZE_MASK);
 }
 
 static int enh_desc_coe_rdes0(int ipc_err, int type, int payload_err)
@@ -126,50 +126,55 @@ static int enh_desc_coe_rdes0(int ipc_err, int type, int payload_err)
 static void enh_desc_get_ext_status(void *data, struct stmmac_extra_stats *x,
 				    struct dma_extended_desc *p)
 {
-	if (unlikely(p->basic.des01.erx.rx_mac_addr)) {
-		if (p->des4.erx.ip_hdr_err)
+	unsigned int rdes0 = p->basic.des0;
+	unsigned int rdes4 = p->des4;
+
+	if (unlikely(rdes0 & ERDES0_RX_MAC_ADDR)) {
+		int message_type = (rdes4 & ERDES4_MSG_TYPE_MASK) >> 8;
+
+		if (rdes4 & ERDES4_IP_HDR_ERR)
 			x->ip_hdr_err++;
-		if (p->des4.erx.ip_payload_err)
+		if (rdes4 & ERDES4_IP_PAYLOAD_ERR)
 			x->ip_payload_err++;
-		if (p->des4.erx.ip_csum_bypassed)
+		if (rdes4 & ERDES4_IP_CSUM_BYPASSED)
 			x->ip_csum_bypassed++;
-		if (p->des4.erx.ipv4_pkt_rcvd)
+		if (rdes4 & ERDES4_IPV4_PKT_RCVD)
 			x->ipv4_pkt_rcvd++;
-		if (p->des4.erx.ipv6_pkt_rcvd)
+		if (rdes4 & ERDES4_IPV6_PKT_RCVD)
 			x->ipv6_pkt_rcvd++;
-		if (p->des4.erx.msg_type == RDES_EXT_SYNC)
+		if (message_type == RDES_EXT_SYNC)
 			x->rx_msg_type_sync++;
-		else if (p->des4.erx.msg_type == RDES_EXT_FOLLOW_UP)
+		else if (message_type == RDES_EXT_FOLLOW_UP)
 			x->rx_msg_type_follow_up++;
-		else if (p->des4.erx.msg_type == RDES_EXT_DELAY_REQ)
+		else if (message_type == RDES_EXT_DELAY_REQ)
 			x->rx_msg_type_delay_req++;
-		else if (p->des4.erx.msg_type == RDES_EXT_DELAY_RESP)
+		else if (message_type == RDES_EXT_DELAY_RESP)
 			x->rx_msg_type_delay_resp++;
-		else if (p->des4.erx.msg_type == RDES_EXT_PDELAY_REQ)
+		else if (message_type == RDES_EXT_PDELAY_REQ)
 			x->rx_msg_type_pdelay_req++;
-		else if (p->des4.erx.msg_type == RDES_EXT_PDELAY_RESP)
+		else if (message_type == RDES_EXT_PDELAY_RESP)
 			x->rx_msg_type_pdelay_resp++;
-		else if (p->des4.erx.msg_type == RDES_EXT_PDELAY_FOLLOW_UP)
+		else if (message_type == RDES_EXT_PDELAY_FOLLOW_UP)
 			x->rx_msg_type_pdelay_follow_up++;
 		else
 			x->rx_msg_type_ext_no_ptp++;
-		if (p->des4.erx.ptp_frame_type)
+		if (rdes4 & ERDES4_PTP_FRAME_TYPE)
 			x->ptp_frame_type++;
-		if (p->des4.erx.ptp_ver)
+		if (rdes4 & ERDES4_PTP_VER)
 			x->ptp_ver++;
-		if (p->des4.erx.timestamp_dropped)
+		if (rdes4 & ERDES4_TIMESTAMP_DROPPED)
 			x->timestamp_dropped++;
-		if (p->des4.erx.av_pkt_rcvd)
+		if (rdes4 & ERDES4_AV_PKT_RCVD)
 			x->av_pkt_rcvd++;
-		if (p->des4.erx.av_tagged_pkt_rcvd)
+		if (rdes4 & ERDES4_AV_TAGGED_PKT_RCVD)
 			x->av_tagged_pkt_rcvd++;
-		if (p->des4.erx.vlan_tag_priority_val)
+		if ((rdes4 & ERDES4_VLAN_TAG_PRI_VAL_MASK) >> 18)
 			x->vlan_tag_priority_val++;
-		if (p->des4.erx.l3_filter_match)
+		if (rdes4 & ERDES4_L3_FILTER_MATCH)
 			x->l3_filter_match++;
-		if (p->des4.erx.l4_filter_match)
+		if (rdes4 & ERDES4_L4_FILTER_MATCH)
 			x->l4_filter_match++;
-		if (p->des4.erx.l3_l4_filter_no_match)
+		if ((rdes4 & ERDES4_L3_L4_FILT_NO_MATCH_MASK) >> 26)
 			x->l3_l4_filter_no_match++;
 	}
 }
@@ -177,30 +182,30 @@ static void enh_desc_get_ext_status(void *data, struct stmmac_extra_stats *x,
 static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 				  struct dma_desc *p)
 {
-	int ret = good_frame;
 	struct net_device_stats *stats = (struct net_device_stats *)data;
+	unsigned int rdes0 = p->des0;
+	int ret = good_frame;
 
-	if (unlikely(p->des01.erx.error_summary)) {
-		if (unlikely(p->des01.erx.descriptor_error)) {
+	if (unlikely(rdes0 & RDES0_ERROR_SUMMARY)) {
+		if (unlikely(rdes0 & RDES0_DESCRIPTOR_ERROR)) {
 			x->rx_desc++;
 			stats->rx_length_errors++;
 		}
-		if (unlikely(p->des01.erx.overflow_error))
+		if (unlikely(rdes0 & RDES0_OVERFLOW_ERROR))
 			x->rx_gmac_overflow++;
 
-		if (unlikely(p->des01.erx.ipc_csum_error))
+		if (unlikely(rdes0 & RDES0_IPC_CSUM_ERROR))
 			pr_err("\tIPC Csum Error/Giant frame\n");
 
-		if (unlikely(p->des01.erx.late_collision)) {
+		if (unlikely(rdes0 & RDES0_COLLISION))
 			stats->collisions++;
-		}
-		if (unlikely(p->des01.erx.receive_watchdog))
+		if (unlikely(rdes0 & RDES0_RECEIVE_WATCHDOG))
 			x->rx_watchdog++;
 
-		if (unlikely(p->des01.erx.error_gmii))
+		if (unlikely(rdes0 & RDES0_MII_ERROR))	/* GMII */
 			x->rx_mii++;
 
-		if (unlikely(p->des01.erx.crc_error)) {
+		if (unlikely(rdes0 & RDES0_CRC_ERROR)) {
 			x->rx_crc++;
 			stats->rx_crc_errors++;
 		}
@@ -211,26 +216,27 @@ static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 	 * It doesn't match with the information reported into the databook.
 	 * At any rate, we need to understand if the CSUM hw computation is ok
 	 * and report this info to the upper layers. */
-	ret = enh_desc_coe_rdes0(p->des01.erx.ipc_csum_error,
-		p->des01.erx.frame_type, p->des01.erx.rx_mac_addr);
+	ret = enh_desc_coe_rdes0(!!(rdes0 & RDES0_IPC_CSUM_ERROR),
+				 !!(rdes0 & RDES0_FRAME_TYPE),
+				 !!(rdes0 & ERDES0_RX_MAC_ADDR));
 
-	if (unlikely(p->des01.erx.dribbling))
+	if (unlikely(rdes0 & RDES0_DRIBBLING))
 		x->dribbling_bit++;
 
-	if (unlikely(p->des01.erx.sa_filter_fail)) {
+	if (unlikely(rdes0 & RDES0_SA_FILTER_FAIL)) {
 		x->sa_rx_filter_fail++;
 		ret = discard_frame;
 	}
-	if (unlikely(p->des01.erx.da_filter_fail)) {
+	if (unlikely(rdes0 & RDES0_DA_FILTER_FAIL)) {
 		x->da_rx_filter_fail++;
 		ret = discard_frame;
 	}
-	if (unlikely(p->des01.erx.length_error)) {
+	if (unlikely(rdes0 & RDES0_LENGTH_ERROR)) {
 		x->rx_length++;
 		ret = discard_frame;
 	}
 #ifdef STMMAC_VLAN_TAG_USED
-	if (p->des01.erx.vlan_tag)
+	if (rdes0 & RDES0_VLAN_TAG)
 		x->rx_vlan++;
 #endif
 
@@ -240,60 +246,59 @@ static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 static void enh_desc_init_rx_desc(struct dma_desc *p, int disable_rx_ic,
 				  int mode, int end)
 {
-	p->des01.all_flags = 0;
-	p->des01.erx.own = 1;
-	p->des01.erx.buffer1_size = BUF_SIZE_8KiB - 1;
+	p->des0 |= RDES0_OWN;
+	p->des1 |= ((BUF_SIZE_8KiB - 1) & ERDES1_BUFFER1_SIZE_MASK);
 
 	if (mode == STMMAC_CHAIN_MODE)
-		ehn_desc_rx_set_on_chain(p, end);
+		ehn_desc_rx_set_on_chain(p);
 	else
 		ehn_desc_rx_set_on_ring(p, end);
 
 	if (disable_rx_ic)
-		p->des01.erx.disable_ic = 1;
+		p->des1 |= ERDES1_DISABLE_IC;
 }
 
 static void enh_desc_init_tx_desc(struct dma_desc *p, int mode, int end)
 {
-	p->des01.all_flags = 0;
+	p->des0 &= ~ETDES0_OWN;
 	if (mode == STMMAC_CHAIN_MODE)
-		ehn_desc_tx_set_on_chain(p, end);
+		enh_desc_end_tx_desc_on_chain(p);
 	else
-		ehn_desc_tx_set_on_ring(p, end);
+		enh_desc_end_tx_desc_on_ring(p, end);
 }
 
 static int enh_desc_get_tx_owner(struct dma_desc *p)
 {
-	return p->des01.etx.own;
+	return (p->des0 & ETDES0_OWN) >> 31;
 }
 
 static int enh_desc_get_rx_owner(struct dma_desc *p)
 {
-	return p->des01.erx.own;
+	return (p->des0 & RDES0_OWN) >> 31;
 }
 
 static void enh_desc_set_tx_owner(struct dma_desc *p)
 {
-	p->des01.etx.own = 1;
+	p->des0 |= ETDES0_OWN;
 }
 
 static void enh_desc_set_rx_owner(struct dma_desc *p)
 {
-	p->des01.erx.own = 1;
+	p->des0 |= RDES0_OWN;
 }
 
 static int enh_desc_get_tx_ls(struct dma_desc *p)
 {
-	return p->des01.etx.last_segment;
+	return (p->des0 & ETDES0_LAST_SEGMENT) >> 29;
 }
 
 static void enh_desc_release_tx_desc(struct dma_desc *p, int mode)
 {
-	int ter = p->des01.etx.end_ring;
+	int ter = (p->des0 & ETDES0_END_RING) >> 21;
 
 	memset(p, 0, offsetof(struct dma_desc, des2));
 	if (mode == STMMAC_CHAIN_MODE)
-		enh_desc_end_tx_desc_on_chain(p, ter);
+		enh_desc_end_tx_desc_on_chain(p);
 	else
 		enh_desc_end_tx_desc_on_ring(p, ter);
 }
@@ -301,49 +306,60 @@ static void enh_desc_release_tx_desc(struct dma_desc *p, int mode)
 static void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 				     int csum_flag, int mode)
 {
-	p->des01.etx.first_segment = is_fs;
+	unsigned int tdes0 = p->des0;
+
+	if (is_fs)
+		tdes0 |= ETDES0_FIRST_SEGMENT;
+	else
+		tdes0 &= ~ETDES0_FIRST_SEGMENT;
+
+	if (likely(csum_flag))
+		tdes0 |= (TX_CIC_FULL << ETDES0_CHECKSUM_INSERTION_SHIFT);
+	else
+		tdes0 &= ~(TX_CIC_FULL << ETDES0_CHECKSUM_INSERTION_SHIFT);
+
+	p->des0 = tdes0;
 
 	if (mode == STMMAC_CHAIN_MODE)
 		enh_set_tx_desc_len_on_chain(p, len);
 	else
 		enh_set_tx_desc_len_on_ring(p, len);
-
-	if (likely(csum_flag))
-		p->des01.etx.checksum_insertion = cic_full;
 }
 
 static void enh_desc_clear_tx_ic(struct dma_desc *p)
 {
-	p->des01.etx.interrupt = 0;
+	p->des0 &= ~ETDES0_INTERRUPT;
 }
 
 static void enh_desc_close_tx_desc(struct dma_desc *p)
 {
-	p->des01.etx.last_segment = 1;
-	p->des01.etx.interrupt = 1;
+	p->des0 |= ETDES0_LAST_SEGMENT | ETDES0_INTERRUPT;
 }
 
 static int enh_desc_get_rx_frame_len(struct dma_desc *p, int rx_coe_type)
 {
+	unsigned int csum = 0;
 	/* The type-1 checksum offload engines append the checksum at
 	 * the end of frame and the two bytes of checksum are added in
 	 * the length.
 	 * Adjust for that in the framelen for type-1 checksum offload
-	 * engines. */
+	 * engines.
+	 */
 	if (rx_coe_type == STMMAC_RX_COE_TYPE1)
-		return p->des01.erx.frame_length - 2;
-	else
-		return p->des01.erx.frame_length;
+		csum = 2;
+
+	return (((p->des0 & RDES0_FRAME_LEN_MASK) >> RDES0_FRAME_LEN_SHIFT) -
+		csum);
 }
 
 static void enh_desc_enable_tx_timestamp(struct dma_desc *p)
 {
-	p->des01.etx.time_stamp_enable = 1;
+	p->des0 |= ETDES0_TIME_STAMP_ENABLE;
 }
 
 static int enh_desc_get_tx_timestamp_status(struct dma_desc *p)
 {
-	return p->des01.etx.time_stamp_status;
+	return (p->des0 & ETDES0_TIME_STAMP_STATUS) >> 17;
 }
 
 static u64 enh_desc_get_timestamp(void *desc, u32 ats)
@@ -368,7 +384,7 @@ static int enh_desc_get_rx_timestamp_status(void *desc, u32 ats)
 {
 	if (ats) {
 		struct dma_extended_desc *p = (struct dma_extended_desc *)desc;
-		return p->basic.des01.erx.ipc_csum_error;
+		return (p->basic.des0 & RDES0_IPC_CSUM_ERROR) >> 7;
 	} else {
 		struct dma_desc *p = (struct dma_desc *)desc;
 		if ((p->des2 == 0xffffffff) && (p->des3 == 0xffffffff))
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index 48c3456..460c573 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -29,33 +29,38 @@
 static int ndesc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 			       struct dma_desc *p, void __iomem *ioaddr)
 {
-	int ret = 0;
 	struct net_device_stats *stats = (struct net_device_stats *)data;
+	unsigned int tdes0 = p->des0;
+	int ret = 0;
 
-	if (unlikely(p->des01.tx.error_summary)) {
-		if (unlikely(p->des01.tx.underflow_error)) {
+	if (unlikely(tdes0 & TDES0_ERROR_SUMMARY)) {
+		if (unlikely(tdes0 & TDES0_UNDERFLOW_ERROR)) {
 			x->tx_underflow++;
 			stats->tx_fifo_errors++;
 		}
-		if (unlikely(p->des01.tx.no_carrier)) {
+		if (unlikely(tdes0 & TDES0_NO_CARRIER)) {
 			x->tx_carrier++;
 			stats->tx_carrier_errors++;
 		}
-		if (unlikely(p->des01.tx.loss_carrier)) {
+		if (unlikely(tdes0 & TDES0_LOSS_CARRIER)) {
 			x->tx_losscarrier++;
 			stats->tx_carrier_errors++;
 		}
-		if (unlikely((p->des01.tx.excessive_deferral) ||
-			     (p->des01.tx.excessive_collisions) ||
-			     (p->des01.tx.late_collision)))
-			stats->collisions += p->des01.tx.collision_count;
+		if (unlikely((tdes0 & TDES0_EXCESSIVE_DEFERRAL) ||
+			     (tdes0 & TDES0_EXCESSIVE_COLLISIONS) ||
+			     (tdes0 & TDES0_LATE_COLLISION))) {
+			unsigned int collisions;
+
+			collisions = (tdes0 & TDES0_COLLISION_COUNT_MASK) >> 3;
+			stats->collisions += collisions;
+		}
 		ret = -1;
 	}
 
-	if (p->des01.etx.vlan_frame)
+	if (tdes0 & TDES0_VLAN_FRAME)
 		x->tx_vlan++;
 
-	if (unlikely(p->des01.tx.deferred))
+	if (unlikely(tdes0 & TDES0_DEFERRED))
 		x->tx_deferred++;
 
 	return ret;
@@ -63,7 +68,7 @@ static int ndesc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 
 static int ndesc_get_tx_len(struct dma_desc *p)
 {
-	return p->des01.tx.buffer1_size;
+	return (p->des1 & RDES1_BUFFER1_SIZE_MASK);
 }
 
 /* This function verifies if each incoming frame has some errors
@@ -74,47 +79,48 @@ static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 			       struct dma_desc *p)
 {
 	int ret = good_frame;
+	unsigned int rdes0 = p->des0;
 	struct net_device_stats *stats = (struct net_device_stats *)data;
 
-	if (unlikely(p->des01.rx.last_descriptor == 0)) {
+	if (unlikely(!(rdes0 & RDES0_LAST_DESCRIPTOR))) {
 		pr_warn("%s: Oversized frame spanned multiple buffers\n",
 			__func__);
 		stats->rx_length_errors++;
 		return discard_frame;
 	}
 
-	if (unlikely(p->des01.rx.error_summary)) {
-		if (unlikely(p->des01.rx.descriptor_error))
+	if (unlikely(rdes0 & RDES0_ERROR_SUMMARY)) {
+		if (unlikely(rdes0 & RDES0_DESCRIPTOR_ERROR))
 			x->rx_desc++;
-		if (unlikely(p->des01.rx.sa_filter_fail))
+		if (unlikely(rdes0 & RDES0_SA_FILTER_FAIL))
 			x->sa_filter_fail++;
-		if (unlikely(p->des01.rx.overflow_error))
+		if (unlikely(rdes0 & RDES0_OVERFLOW_ERROR))
 			x->overflow_error++;
-		if (unlikely(p->des01.rx.ipc_csum_error))
+		if (unlikely(rdes0 & RDES0_IPC_CSUM_ERROR))
 			x->ipc_csum_error++;
-		if (unlikely(p->des01.rx.collision)) {
+		if (unlikely(rdes0 & RDES0_COLLISION)) {
 			x->rx_collision++;
 			stats->collisions++;
 		}
-		if (unlikely(p->des01.rx.crc_error)) {
+		if (unlikely(rdes0 & RDES0_CRC_ERROR)) {
 			x->rx_crc++;
 			stats->rx_crc_errors++;
 		}
 		ret = discard_frame;
 	}
-	if (unlikely(p->des01.rx.dribbling))
+	if (unlikely(rdes0 & RDES0_DRIBBLING))
 		x->dribbling_bit++;
 
-	if (unlikely(p->des01.rx.length_error)) {
+	if (unlikely(rdes0 & RDES0_LENGTH_ERROR)) {
 		x->rx_length++;
 		ret = discard_frame;
 	}
-	if (unlikely(p->des01.rx.mii_error)) {
+	if (unlikely(rdes0 & RDES0_MII_ERROR)) {
 		x->rx_mii++;
 		ret = discard_frame;
 	}
 #ifdef STMMAC_VLAN_TAG_USED
-	if (p->des01.rx.vlan_tag)
+	if (rdes0 & RDES0_VLAN_TAG)
 		x->vlan_tag++;
 #endif
 	return ret;
@@ -123,9 +129,8 @@ static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 static void ndesc_init_rx_desc(struct dma_desc *p, int disable_rx_ic, int mode,
 			       int end)
 {
-	p->des01.all_flags = 0;
-	p->des01.rx.own = 1;
-	p->des01.rx.buffer1_size = BUF_SIZE_2KiB - 1;
+	p->des0 |= RDES0_OWN;
+	p->des1 |= (BUF_SIZE_2KiB - 1) & RDES1_BUFFER1_SIZE_MASK;
 
 	if (mode == STMMAC_CHAIN_MODE)
 		ndesc_rx_set_on_chain(p, end);
@@ -133,50 +138,50 @@ static void ndesc_init_rx_desc(struct dma_desc *p, int disable_rx_ic, int mode,
 		ndesc_rx_set_on_ring(p, end);
 
 	if (disable_rx_ic)
-		p->des01.rx.disable_ic = 1;
+		p->des1 |= RDES1_DISABLE_IC;
 }
 
 static void ndesc_init_tx_desc(struct dma_desc *p, int mode, int end)
 {
-	p->des01.all_flags = 0;
+	p->des0 &= ~TDES0_OWN;
 	if (mode == STMMAC_CHAIN_MODE)
-		ndesc_tx_set_on_chain(p, end);
+		ndesc_tx_set_on_chain(p);
 	else
-		ndesc_tx_set_on_ring(p, end);
+		ndesc_end_tx_desc_on_ring(p, end);
 }
 
 static int ndesc_get_tx_owner(struct dma_desc *p)
 {
-	return p->des01.tx.own;
+	return (p->des0 & TDES0_OWN) >> 31;
 }
 
 static int ndesc_get_rx_owner(struct dma_desc *p)
 {
-	return p->des01.rx.own;
+	return (p->des0 & RDES0_OWN) >> 31;
 }
 
 static void ndesc_set_tx_owner(struct dma_desc *p)
 {
-	p->des01.tx.own = 1;
+	p->des0 |= TDES0_OWN;
 }
 
 static void ndesc_set_rx_owner(struct dma_desc *p)
 {
-	p->des01.rx.own = 1;
+	p->des0 |= RDES0_OWN;
 }
 
 static int ndesc_get_tx_ls(struct dma_desc *p)
 {
-	return p->des01.tx.last_segment;
+	return (p->des1 & TDES1_LAST_SEGMENT) >> 30;
 }
 
 static void ndesc_release_tx_desc(struct dma_desc *p, int mode)
 {
-	int ter = p->des01.tx.end_ring;
+	int ter = (p->des1 & TDES1_END_RING) >> 25;
 
 	memset(p, 0, offsetof(struct dma_desc, des2));
 	if (mode == STMMAC_CHAIN_MODE)
-		ndesc_end_tx_desc_on_chain(p, ter);
+		ndesc_tx_set_on_chain(p);
 	else
 		ndesc_end_tx_desc_on_ring(p, ter);
 }
@@ -184,48 +189,62 @@ static void ndesc_release_tx_desc(struct dma_desc *p, int mode)
 static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 				  int csum_flag, int mode)
 {
-	p->des01.tx.first_segment = is_fs;
+	unsigned int tdes1 = p->des1;
+
+	if (is_fs)
+		tdes1 |= TDES1_FIRST_SEGMENT;
+	else
+		tdes1 &= ~TDES1_FIRST_SEGMENT;
+
+	if (likely(csum_flag))
+		tdes1 |= (TX_CIC_FULL) << TDES1_CHECKSUM_INSERTION_SHIFT;
+	else
+		tdes1 &= ~(TX_CIC_FULL << TDES1_CHECKSUM_INSERTION_SHIFT);
+
+	p->des1 = tdes1;
+
 	if (mode == STMMAC_CHAIN_MODE)
 		norm_set_tx_desc_len_on_chain(p, len);
 	else
 		norm_set_tx_desc_len_on_ring(p, len);
-
-	if (likely(csum_flag))
-		p->des01.tx.checksum_insertion = cic_full;
 }
 
 static void ndesc_clear_tx_ic(struct dma_desc *p)
 {
-	p->des01.tx.interrupt = 0;
+	p->des1 &= ~TDES1_INTERRUPT;
 }
 
 static void ndesc_close_tx_desc(struct dma_desc *p)
 {
-	p->des01.tx.last_segment = 1;
-	p->des01.tx.interrupt = 1;
+	p->des1 |= TDES1_LAST_SEGMENT | TDES1_INTERRUPT;
 }
 
 static int ndesc_get_rx_frame_len(struct dma_desc *p, int rx_coe_type)
 {
+	unsigned int csum = 0;
+
 	/* The type-1 checksum offload engines append the checksum at
 	 * the end of frame and the two bytes of checksum are added in
 	 * the length.
 	 * Adjust for that in the framelen for type-1 checksum offload
-	 * engines. */
+	 * engines
+	 */
 	if (rx_coe_type == STMMAC_RX_COE_TYPE1)
-		return p->des01.rx.frame_length - 2;
-	else
-		return p->des01.rx.frame_length;
+		csum = 2;
+
+	return (((p->des0 & RDES0_FRAME_LEN_MASK) >> RDES0_FRAME_LEN_SHIFT) -
+		csum);
+
 }
 
 static void ndesc_enable_tx_timestamp(struct dma_desc *p)
 {
-	p->des01.tx.time_stamp_enable = 1;
+	p->des1 |= TDES1_TIME_STAMP_ENABLE;
 }
 
 static int ndesc_get_tx_timestamp_status(struct dma_desc *p)
 {
-	return p->des01.tx.time_stamp_status;
+	return (p->des0 & TDES0_TIME_STAMP_STATUS) >> 17;
 }
 
 static u64 ndesc_get_timestamp(void *desc, u32 ats)
-- 
1.7.4.4
