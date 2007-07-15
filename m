From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 2/5] atl1: header file cleanup
Date: Sun, 15 Jul 2007 11:03:26 -0500
Message-ID: <11845154093818-git-send-email-jacliburn@bellsouth.net>
References: <11845154092908-git-send-email-jacliburn@bellsouth.net>
Cc: jacliburn@bellsouth.net, csnook@redhat.com,
	atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf18aec.mail.bellsouth.net ([205.152.59.66]:34313 "EHLO
	imf18aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759292AbXGOQDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 12:03:32 -0400
In-Reply-To: <11845154092908-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unused structure members, improve comments, break long comment lines,
rename a constant to be consistent with others in the file.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atl1/atl1.h      |  155 ++++++++++++++++++++++--------------------
 drivers/net/atl1/atl1_main.c |   20 +++---
 2 files changed, 90 insertions(+), 85 deletions(-)

diff --git a/drivers/net/atl1/atl1.h b/drivers/net/atl1/atl1.h
index a769e7b..991c8b9 100644
--- a/drivers/net/atl1/atl1.h
+++ b/drivers/net/atl1/atl1.h
@@ -43,6 +43,7 @@ extern const struct ethtool_ops atl1_ethtool_ops;
 struct atl1_adapter;
 
 #define ATL1_MAX_INTR		3
+#define ATL1_MAX_TX_BUF_LEN	0x3000	/* 12288 bytes */
 
 #define ATL1_DEFAULT_TPD	256
 #define ATL1_MAX_TPD		1024
@@ -57,29 +58,45 @@ struct atl1_adapter;
 #define ATL1_RRD_DESC(R, i)	ATL1_GET_DESC(R, i, struct rx_return_desc)
 
 /*
+ * This detached comment is preserved for documentation purposes only.
+ * It was originally attached to some code that got deleted, but seems
+ * important enough to keep around...
+ *
+ * <begin detached comment>
  * Some workarounds require millisecond delays and are run during interrupt
  * context.  Most notably, when establishing link, the phy may need tweaking
  * but cannot process phy register reads/writes faster than millisecond
  * intervals...and we establish link due to a "link status change" interrupt.
+ * <end detached comment>
+ */
+
+/*
+ * atl1_ring_header represents a single, contiguous block of DMA space
+ * mapped for the three descriptor rings (tpd, rfd, rrd) and the two
+ * message blocks (cmb, smb) described below
  */
+struct atl1_ring_header {
+	void *desc;		/* virtual address */
+	dma_addr_t dma;		/* physical address*/
+	unsigned int size;	/* length in bytes */
+};
 
 /*
- * wrapper around a pointer to a socket buffer,
- * so a DMA handle can be stored along with the buffer
+ * atl1_buffer is wrapper around a pointer to a socket buffer
+ * so a DMA handle can be stored along with the skb
  */
 struct atl1_buffer {
-	struct sk_buff *skb;
-	u16 length;
-	u16 alloced;
+	struct sk_buff *skb;	/* socket buffer */
+	u16 length;		/* rx buffer length */
+	u16 alloced;		/* 1 if skb allocated */
 	dma_addr_t dma;
 };
 
-#define MAX_TX_BUF_LEN		0x3000	/* 12KB */
-
+/* transmit packet descriptor (tpd) ring */
 struct atl1_tpd_ring {
-	void *desc;		/* pointer to the descriptor ring memory */
-	dma_addr_t dma;		/* physical adress of the descriptor ring */
-	u16 size;		/* length of descriptor ring in bytes */
+	void *desc;		/* descriptor ring virtual address */
+	dma_addr_t dma;		/* descriptor ring physical address */
+	u16 size;		/* descriptor ring length in bytes */
 	u16 count;		/* number of descriptors in the ring */
 	u16 hw_idx;		/* hardware index */
 	atomic_t next_to_clean;
@@ -87,36 +104,34 @@ struct atl1_tpd_ring {
 	struct atl1_buffer *buffer_info;
 };
 
+/* receive free descriptor (rfd) ring */
 struct atl1_rfd_ring {
-	void *desc;
-	dma_addr_t dma;
-	u16 size;
-	u16 count;
+	void *desc;		/* descriptor ring virtual address */
+	dma_addr_t dma;		/* descriptor ring physical address */
+	u16 size;		/* descriptor ring length in bytes */
+	u16 count;		/* number of descriptors in the ring */
 	atomic_t next_to_use;
 	u16 next_to_clean;
 	struct atl1_buffer *buffer_info;
 };
 
+/* receive return descriptor (rrd) ring */
 struct atl1_rrd_ring {
-	void *desc;
-	dma_addr_t dma;
-	unsigned int size;
-	u16 count;
+	void *desc;		/* descriptor ring virtual address */
+	dma_addr_t dma;		/* descriptor ring physical address */
+	unsigned int size;	/* descriptor ring length in bytes */
+	u16 count;		/* number of descriptors in the ring */
 	u16 next_to_use;
 	atomic_t next_to_clean;
 };
 
-struct atl1_ring_header {
-	void *desc;		/* pointer to the descriptor ring memory */
-	dma_addr_t dma;		/* physical adress of the descriptor ring */
-	unsigned int size;	/* length of descriptor ring in bytes */
-};
-
+/* coalescing message block (cmb) */
 struct atl1_cmb {
 	struct coals_msg_block *cmb;
 	dma_addr_t dma;
 };
 
+/* statistics message block (smb) */
 struct atl1_smb {
 	struct stats_msg_block *smb;
 	dma_addr_t dma;
@@ -141,24 +156,26 @@ struct atl1_sft_stats {
 	u64 tx_aborted_errors;
 	u64 tx_window_errors;
 	u64 tx_carrier_errors;
-
-	u64 tx_pause;		/* num Pause packet transmitted. */
-	u64 excecol;		/* num tx packets aborted due to excessive collisions. */
-	u64 deffer;		/* num deferred tx packets */
-	u64 scc;		/* num packets subsequently transmitted successfully w/ single prior collision. */
-	u64 mcc;		/* num packets subsequently transmitted successfully w/ multiple prior collisions. */
+	u64 tx_pause;		/* num pause packets transmitted. */
+	u64 excecol;		/* num tx packets w/ excessive collisions. */
+	u64 deffer;		/* num tx packets deferred */
+	u64 scc;		/* num packets subsequently transmitted
+				 * successfully w/ single prior collision. */
+	u64 mcc;		/* num packets subsequently transmitted
+				 * successfully w/ multiple prior collisions. */
 	u64 latecol;		/* num tx packets  w/ late collisions. */
-	u64 tx_underun;		/* num tx packets aborted due to transmit FIFO underrun, or TRD FIFO underrun */
-	u64 tx_trunc;		/* num tx packets truncated due to size exceeding MTU, regardless whether truncated by Selene or not. (The name doesn't really reflect the meaning in this case.) */
+	u64 tx_underun;		/* num tx packets aborted due to transmit
+				 * FIFO underrun, or TRD FIFO underrun */
+	u64 tx_trunc;		/* num tx packets truncated due to size
+				 * exceeding MTU, regardless whether truncated
+				 * by the chip or not. (The name doesn't really
+				 * reflect the meaning in this case.) */
 	u64 rx_pause;		/* num Pause packets received. */
 	u64 rx_rrd_ov;
 	u64 rx_trunc;
 };
 
-/* board specific private data structure */
-#define ATL1_REGS_LEN	8
-
-/* Structure containing variables used by the shared code */
+/* hardware structure */
 struct atl1_hw {
 	u8 __iomem *hw_addr;
 	struct atl1_adapter *back;
@@ -167,24 +184,35 @@ struct atl1_hw {
 	enum atl1_dma_req_block dmar_block;
 	enum atl1_dma_req_block dmaw_block;
 	u8 preamble_len;
-	u8 max_retry;		/* Retransmission maximum, after which the packet will be discarded */
-	u8 jam_ipg;		/* IPG to start JAM for collision based flow control in half-duplex mode. In units of 8-bit time */
-	u8 ipgt;		/* Desired back to back inter-packet gap. The default is 96-bit time */
-	u8 min_ifg;		/* Minimum number of IFG to enforce in between RX frames. Frame gap below such IFP is dropped */
+	u8 max_retry;		/* Retransmission maximum, after which the
+				 * packet will be discarded */
+	u8 jam_ipg;		/* IPG to start JAM for collision based flow
+				 * control in half-duplex mode. In units of
+				 * 8-bit time */
+	u8 ipgt;		/* Desired back to back inter-packet gap.
+				 * The default is 96-bit time */
+	u8 min_ifg;		/* Minimum number of IFG to enforce in between
+				 * receive frames. Frame gap below such IFP
+				 * is dropped */
 	u8 ipgr1;		/* 64bit Carrier-Sense window */
 	u8 ipgr2;		/* 96-bit IPG window */
-	u8 tpd_burst;		/* Number of TPD to prefetch in cache-aligned burst. Each TPD is 16 bytes long */
-	u8 rfd_burst;		/* Number of RFD to prefetch in cache-aligned burst. Each RFD is 12 bytes long */
+	u8 tpd_burst;		/* Number of TPD to prefetch in cache-aligned
+				 * burst. Each TPD is 16 bytes long */
+	u8 rfd_burst;		/* Number of RFD to prefetch in cache-aligned
+				 * burst. Each RFD is 12 bytes long */
 	u8 rfd_fetch_gap;
-	u8 rrd_burst;		/* Threshold number of RRDs that can be retired in a burst. Each RRD is 16 bytes long */
+	u8 rrd_burst;		/* Threshold number of RRDs that can be retired
+				 * in a burst. Each RRD is 16 bytes long */
 	u8 tpd_fetch_th;
 	u8 tpd_fetch_gap;
 	u16 tx_jumbo_task_th;
-	u16 txf_burst;		/* Number of data bytes to read in a cache-aligned burst. Each SRAM entry is
-				   8 bytes long */
-	u16 rx_jumbo_th;	/* Jumbo packet size for non-VLAN packet. VLAN packets should add 4 bytes */
+	u16 txf_burst;		/* Number of data bytes to read in a cache-
+				 * aligned burst. Each SRAM entry is 8 bytes */
+	u16 rx_jumbo_th;	/* Jumbo packet size for non-VLAN packet. VLAN
+				 * packets should add 4 bytes */
 	u16 rx_jumbo_lkah;
-	u16 rrd_ret_timer;	/* RRD retirement timer. Decrement by 1 after every 512ns passes. */
+	u16 rrd_ret_timer;	/* RRD retirement timer. Decrement by 1 after
+				 * every 512ns passes. */
 	u16 lcol;		/* Collision Window */
 
 	u16 cmb_tpd;
@@ -194,20 +222,12 @@ struct atl1_hw {
 	u32 smb_timer;
 	u16 media_type;
 	u16 autoneg_advertised;
-	u16 pci_cmd_word;
 
 	u16 mii_autoneg_adv_reg;
 	u16 mii_1000t_ctrl_reg;
 
-	u32 mem_rang;
-	u32 txcw;
 	u32 max_frame_size;
 	u32 min_frame_size;
-	u32 mc_filter_type;
-	u32 num_mc_addrs;
-	u32 collision_delta;
-	u32 tx_packet_delta;
-	u16 phy_spd_default;
 
 	u16 dev_rev;
 	u8 revision_id;
@@ -215,21 +235,17 @@ struct atl1_hw {
 	/* spi flash */
 	u8 flash_vendor;
 
-	u8 dma_fairness;
 	u8 mac_addr[ETH_ALEN];
 	u8 perm_mac_addr[ETH_ALEN];
 
-	/* bool phy_preamble_sup; */
 	bool phy_configured;
 };
 
 struct atl1_adapter {
-	/* OS defined structs */
 	struct net_device *netdev;
 	struct pci_dev *pdev;
 	struct net_device_stats net_stats;
 	struct atl1_sft_stats soft_stats;
-
 	struct vlan_group *vlgrp;
 	u32 rx_buffer_len;
 	u32 wol;
@@ -243,9 +259,7 @@ struct atl1_adapter {
 	struct timer_list phy_config_timer;
 	bool phy_timer_pending;
 
-	bool mac_disabled;
-
-	/* All descriptor rings' memory */
+	/* all descriptor rings' memory */
 	struct atl1_ring_header ring_header;
 
 	/* TX */
@@ -258,25 +272,16 @@ struct atl1_adapter {
 	u64 hw_csum_err;
 	u64 hw_csum_good;
 
-	u32 gorcl;
-	u64 gorcl_old;
-
-	/* Interrupt Moderator timer ( 2us resolution) */
-	u16 imt;
-	/* Interrupt Clear timer (2us resolution) */
-	u16 ict;
-
-	/* MII interface info */
-	struct mii_if_info mii;
+	u16 imt;	/* interrupt moderator timer (2us resolution */
+	u16 ict;	/* interrupt clear timer (2us resolution */
+	struct mii_if_info mii;		/* MII interface info */
 
 	/* structs defined in atl1_hw.h */
-	u32 bd_number;		/* board number */
+	u32 bd_number;			/* board number */
 	bool pci_using_64;
 	struct atl1_hw hw;
 	struct atl1_smb smb;
 	struct atl1_cmb cmb;
-
-	u32 pci_state[16];
 };
 
 #endif	/* _ATL1_H_ */
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index ef12dba..6c8cf98 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -1344,21 +1344,21 @@ static void atl1_tx_map(struct atl1_adapter *adapter,
 
 		if (first_buf_len > proto_hdr_len) {
 			len12 = first_buf_len - proto_hdr_len;
-			m = (len12 + MAX_TX_BUF_LEN - 1) / MAX_TX_BUF_LEN;
+			m = (len12 + ATL1_MAX_TX_BUF_LEN - 1) / ATL1_MAX_TX_BUF_LEN;
 			for (i = 0; i < m; i++) {
 				buffer_info =
 				    &tpd_ring->buffer_info[tpd_next_to_use];
 				buffer_info->skb = NULL;
 				buffer_info->length =
-				    (MAX_TX_BUF_LEN >=
-				     len12) ? MAX_TX_BUF_LEN : len12;
+				    (ATL1_MAX_TX_BUF_LEN >=
+				     len12) ? ATL1_MAX_TX_BUF_LEN : len12;
 				len12 -= buffer_info->length;
 				page = virt_to_page(skb->data +
 						 (proto_hdr_len +
-						  i * MAX_TX_BUF_LEN));
+						  i * ATL1_MAX_TX_BUF_LEN));
 				offset = (unsigned long)(skb->data +
 							(proto_hdr_len +
-							i * MAX_TX_BUF_LEN)) &
+							i * ATL1_MAX_TX_BUF_LEN)) &
 							~PAGE_MASK;
 				buffer_info->dma =
 				    pci_map_page(adapter->pdev, page, offset,
@@ -1387,18 +1387,18 @@ static void atl1_tx_map(struct atl1_adapter *adapter,
 		frag = &skb_shinfo(skb)->frags[f];
 		lenf = frag->size;
 
-		m = (lenf + MAX_TX_BUF_LEN - 1) / MAX_TX_BUF_LEN;
+		m = (lenf + ATL1_MAX_TX_BUF_LEN - 1) / ATL1_MAX_TX_BUF_LEN;
 		for (i = 0; i < m; i++) {
 			buffer_info = &tpd_ring->buffer_info[tpd_next_to_use];
 			if (unlikely(buffer_info->skb))
 				BUG();
 			buffer_info->skb = NULL;
 			buffer_info->length =
-			    (lenf > MAX_TX_BUF_LEN) ? MAX_TX_BUF_LEN : lenf;
+			    (lenf > ATL1_MAX_TX_BUF_LEN) ? ATL1_MAX_TX_BUF_LEN : lenf;
 			lenf -= buffer_info->length;
 			buffer_info->dma =
 			    pci_map_page(adapter->pdev, frag->page,
-					 frag->page_offset + i * MAX_TX_BUF_LEN,
+					 frag->page_offset + i * ATL1_MAX_TX_BUF_LEN,
 					 buffer_info->length, PCI_DMA_TODEVICE);
 
 			if (++tpd_next_to_use == tpd_ring->count)
@@ -1516,7 +1516,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		frag_size = skb_shinfo(skb)->frags[f].size;
 		if (frag_size)
 			count +=
-			    (frag_size + MAX_TX_BUF_LEN - 1) / MAX_TX_BUF_LEN;
+			    (frag_size + ATL1_MAX_TX_BUF_LEN - 1) / ATL1_MAX_TX_BUF_LEN;
 	}
 
 	/* mss will be nonzero if we're doing segment offload (TSO/GSO) */
@@ -1532,7 +1532,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			/* need additional TPD ? */
 			if (proto_hdr_len != len)
 				count += (len - proto_hdr_len +
-					MAX_TX_BUF_LEN - 1) / MAX_TX_BUF_LEN;
+					ATL1_MAX_TX_BUF_LEN - 1) / ATL1_MAX_TX_BUF_LEN;
 		}
 	}
 
-- 
1.5.2.2

