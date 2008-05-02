From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.26] ucc_geth: Fix a bunch of sparse warnings
Date: Fri,  2 May 2008 13:01:23 -0500
Message-ID: <1209751283-25536-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:49671 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbYEBSBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 14:01:33 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m42I1Pib022693
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 11:01:25 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id m42I1OBa008907
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 13:01:24 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ucc_geth didn't have anything marked as __iomem.  It was also inconsistent
with its use of in/out accessors (using them sometimes, not using them other
times).  Cleaning this up cuts the warnings down from hundreds to just over a
dozen.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/ucc_geth.c         |  276 +++++++++++++++++++++-------------------
 drivers/net/ucc_geth.h         |   48 ++++---
 drivers/net/ucc_geth_ethtool.c |    6 -
 drivers/net/ucc_geth_mii.c     |    4 +-
 4 files changed, 174 insertions(+), 160 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 281ce3d..b3bbb2d 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -62,7 +62,6 @@
 #endif				/* UGETH_VERBOSE_DEBUG */
 #define UGETH_MSG_DEFAULT	(NETIF_MSG_IFUP << 1 ) - 1
 
-void uec_set_ethtool_ops(struct net_device *netdev);
 
 static DEFINE_SPINLOCK(ugeth_lock);
 
@@ -216,7 +215,8 @@ static struct list_head *dequeue(struct list_head *lh)
 	}
 }
 
-static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth, u8 *bd)
+static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth,
+		u8 __iomem *bd)
 {
 	struct sk_buff *skb = NULL;
 
@@ -236,21 +236,22 @@ static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth, u8 *bd)
 
 	skb->dev = ugeth->dev;
 
-	out_be32(&((struct qe_bd *)bd)->buf,
+	out_be32(&((struct qe_bd __iomem *)bd)->buf,
 		      dma_map_single(NULL,
 				     skb->data,
 				     ugeth->ug_info->uf_info.max_rx_buf_length +
 				     UCC_GETH_RX_DATA_BUF_ALIGNMENT,
 				     DMA_FROM_DEVICE));
 
-	out_be32((u32 *)bd, (R_E | R_I | (in_be32((u32 *)bd) & R_W)));
+	out_be32((u32 __iomem *)bd,
+			(R_E | R_I | (in_be32((u32 __iomem*)bd) & R_W)));
 
 	return skb;
 }
 
 static int rx_bd_buffer_set(struct ucc_geth_private *ugeth, u8 rxQ)
 {
-	u8 *bd;
+	u8 __iomem *bd;
 	u32 bd_status;
 	struct sk_buff *skb;
 	int i;
@@ -259,7 +260,7 @@ static int rx_bd_buffer_set(struct ucc_geth_private *ugeth, u8 rxQ)
 	i = 0;
 
 	do {
-		bd_status = in_be32((u32*)bd);
+		bd_status = in_be32((u32 __iomem *)bd);
 		skb = get_new_skb(ugeth, bd);
 
 		if (!skb)	/* If can not allocate data buffer,
@@ -277,7 +278,7 @@ static int rx_bd_buffer_set(struct ucc_geth_private *ugeth, u8 rxQ)
 }
 
 static int fill_init_enet_entries(struct ucc_geth_private *ugeth,
-				  volatile u32 *p_start,
+				  u32 *p_start,
 				  u8 num_entries,
 				  u32 thread_size,
 				  u32 thread_alignment,
@@ -316,7 +317,7 @@ static int fill_init_enet_entries(struct ucc_geth_private *ugeth,
 }
 
 static int return_init_enet_entries(struct ucc_geth_private *ugeth,
-				    volatile u32 *p_start,
+				    u32 *p_start,
 				    u8 num_entries,
 				    enum qe_risc_allocation risc,
 				    int skip_page_for_first_entry)
@@ -326,21 +327,22 @@ static int return_init_enet_entries(struct ucc_geth_private *ugeth,
 	int snum;
 
 	for (i = 0; i < num_entries; i++) {
+		u32 val = *p_start;
+
 		/* Check that this entry was actually valid --
 		needed in case failed in allocations */
-		if ((*p_start & ENET_INIT_PARAM_RISC_MASK) == risc) {
+		if ((val & ENET_INIT_PARAM_RISC_MASK) == risc) {
 			snum =
-			    (u32) (*p_start & ENET_INIT_PARAM_SNUM_MASK) >>
+			    (u32) (val & ENET_INIT_PARAM_SNUM_MASK) >>
 			    ENET_INIT_PARAM_SNUM_SHIFT;
 			qe_put_snum((u8) snum);
 			if (!((i == 0) && skip_page_for_first_entry)) {
 			/* First entry of Rx does not have page */
 				init_enet_offset =
-				    (in_be32(p_start) &
-				     ENET_INIT_PARAM_PTR_MASK);
+				    (val & ENET_INIT_PARAM_PTR_MASK);
 				qe_muram_free(init_enet_offset);
 			}
-			*(p_start++) = 0;	/* Just for cosmetics */
+			*p_start++ = 0;
 		}
 	}
 
@@ -349,7 +351,7 @@ static int return_init_enet_entries(struct ucc_geth_private *ugeth,
 
 #ifdef DEBUG
 static int dump_init_enet_entries(struct ucc_geth_private *ugeth,
-				  volatile u32 *p_start,
+				  u32 __iomem *p_start,
 				  u8 num_entries,
 				  u32 thread_size,
 				  enum qe_risc_allocation risc,
@@ -360,11 +362,13 @@ static int dump_init_enet_entries(struct ucc_geth_private *ugeth,
 	int snum;
 
 	for (i = 0; i < num_entries; i++) {
+		u32 val = in_be32(p_start);
+
 		/* Check that this entry was actually valid --
 		needed in case failed in allocations */
-		if ((*p_start & ENET_INIT_PARAM_RISC_MASK) == risc) {
+		if ((val & ENET_INIT_PARAM_RISC_MASK) == risc) {
 			snum =
-			    (u32) (*p_start & ENET_INIT_PARAM_SNUM_MASK) >>
+			    (u32) (val & ENET_INIT_PARAM_SNUM_MASK) >>
 			    ENET_INIT_PARAM_SNUM_SHIFT;
 			qe_put_snum((u8) snum);
 			if (!((i == 0) && skip_page_for_first_entry)) {
@@ -440,7 +444,7 @@ static int hw_add_addr_in_paddr(struct ucc_geth_private *ugeth,
 
 static int hw_clear_addr_in_paddr(struct ucc_geth_private *ugeth, u8 paddr_num)
 {
-	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
+	struct ucc_geth_82xx_address_filtering_pram __iomem *p_82xx_addr_filt;
 
 	if (!(paddr_num < NUM_OF_PADDRS)) {
 		ugeth_warn("%s: Illagel paddr_num.", __FUNCTION__);
@@ -448,7 +452,7 @@ static int hw_clear_addr_in_paddr(struct ucc_geth_private *ugeth, u8 paddr_num)
 	}
 
 	p_82xx_addr_filt =
-	    (struct ucc_geth_82xx_address_filtering_pram *) ugeth->p_rx_glbl_pram->
+	    (struct ucc_geth_82xx_address_filtering_pram __iomem *) ugeth->p_rx_glbl_pram->
 	    addressfiltering;
 
 	/* Writing address ff.ff.ff.ff.ff.ff disables address
@@ -463,11 +467,11 @@ static int hw_clear_addr_in_paddr(struct ucc_geth_private *ugeth, u8 paddr_num)
 static void hw_add_addr_in_hash(struct ucc_geth_private *ugeth,
                                 u8 *p_enet_addr)
 {
-	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
+	struct ucc_geth_82xx_address_filtering_pram __iomem *p_82xx_addr_filt;
 	u32 cecr_subblock;
 
 	p_82xx_addr_filt =
-	    (struct ucc_geth_82xx_address_filtering_pram *) ugeth->p_rx_glbl_pram->
+	    (struct ucc_geth_82xx_address_filtering_pram __iomem *) ugeth->p_rx_glbl_pram->
 	    addressfiltering;
 
 	cecr_subblock =
@@ -487,7 +491,7 @@ static void hw_add_addr_in_hash(struct ucc_geth_private *ugeth,
 static void magic_packet_detection_enable(struct ucc_geth_private *ugeth)
 {
 	struct ucc_fast_private *uccf;
-	struct ucc_geth *ug_regs;
+	struct ucc_geth __iomem *ug_regs;
 	u32 maccfg2, uccm;
 
 	uccf = ugeth->uccf;
@@ -507,7 +511,7 @@ static void magic_packet_detection_enable(struct ucc_geth_private *ugeth)
 static void magic_packet_detection_disable(struct ucc_geth_private *ugeth)
 {
 	struct ucc_fast_private *uccf;
-	struct ucc_geth *ug_regs;
+	struct ucc_geth __iomem *ug_regs;
 	u32 maccfg2, uccm;
 
 	uccf = ugeth->uccf;
@@ -538,13 +542,13 @@ static void get_statistics(struct ucc_geth_private *ugeth,
 			   rx_firmware_statistics,
 			   struct ucc_geth_hardware_statistics *hardware_statistics)
 {
-	struct ucc_fast *uf_regs;
-	struct ucc_geth *ug_regs;
+	struct ucc_fast __iomem *uf_regs;
+	struct ucc_geth __iomem *ug_regs;
 	struct ucc_geth_tx_firmware_statistics_pram *p_tx_fw_statistics_pram;
 	struct ucc_geth_rx_firmware_statistics_pram *p_rx_fw_statistics_pram;
 
 	ug_regs = ugeth->ug_regs;
-	uf_regs = (struct ucc_fast *) ug_regs;
+	uf_regs = (struct ucc_fast __iomem *) ug_regs;
 	p_tx_fw_statistics_pram = ugeth->p_tx_fw_statistics_pram;
 	p_rx_fw_statistics_pram = ugeth->p_rx_fw_statistics_pram;
 
@@ -1132,9 +1136,9 @@ static void dump_regs(struct ucc_geth_private *ugeth)
 }
 #endif /* DEBUG */
 
-static void init_default_reg_vals(volatile u32 *upsmr_register,
-				  volatile u32 *maccfg1_register,
-				  volatile u32 *maccfg2_register)
+static void init_default_reg_vals(u32 __iomem *upsmr_register,
+				  u32 __iomem *maccfg1_register,
+				  u32 __iomem *maccfg2_register)
 {
 	out_be32(upsmr_register, UCC_GETH_UPSMR_INIT);
 	out_be32(maccfg1_register, UCC_GETH_MACCFG1_INIT);
@@ -1148,7 +1152,7 @@ static int init_half_duplex_params(int alt_beb,
 				   u8 alt_beb_truncation,
 				   u8 max_retransmissions,
 				   u8 collision_window,
-				   volatile u32 *hafdup_register)
+				   u32 __iomem *hafdup_register)
 {
 	u32 value = 0;
 
@@ -1180,7 +1184,7 @@ static int init_inter_frame_gap_params(u8 non_btb_cs_ipg,
 				       u8 non_btb_ipg,
 				       u8 min_ifg,
 				       u8 btb_ipg,
-				       volatile u32 *ipgifg_register)
+				       u32 __iomem *ipgifg_register)
 {
 	u32 value = 0;
 
@@ -1215,9 +1219,9 @@ int init_flow_control_params(u32 automatic_flow_control_mode,
 				    int tx_flow_control_enable,
 				    u16 pause_period,
 				    u16 extension_field,
-				    volatile u32 *upsmr_register,
-				    volatile u32 *uempr_register,
-				    volatile u32 *maccfg1_register)
+				    u32 __iomem *upsmr_register,
+				    u32 __iomem *uempr_register,
+				    u32 __iomem *maccfg1_register)
 {
 	u32 value = 0;
 
@@ -1243,8 +1247,8 @@ int init_flow_control_params(u32 automatic_flow_control_mode,
 
 static int init_hw_statistics_gathering_mode(int enable_hardware_statistics,
 					     int auto_zero_hardware_statistics,
-					     volatile u32 *upsmr_register,
-					     volatile u16 *uescr_register)
+					     u32 __iomem *upsmr_register,
+					     u16 __iomem *uescr_register)
 {
 	u32 upsmr_value = 0;
 	u16 uescr_value = 0;
@@ -1270,12 +1274,12 @@ static int init_hw_statistics_gathering_mode(int enable_hardware_statistics,
 static int init_firmware_statistics_gathering_mode(int
 		enable_tx_firmware_statistics,
 		int enable_rx_firmware_statistics,
-		volatile u32 *tx_rmon_base_ptr,
+		u32 __iomem *tx_rmon_base_ptr,
 		u32 tx_firmware_statistics_structure_address,
-		volatile u32 *rx_rmon_base_ptr,
+		u32 __iomem *rx_rmon_base_ptr,
 		u32 rx_firmware_statistics_structure_address,
-		volatile u16 *temoder_register,
-		volatile u32 *remoder_register)
+		u16 __iomem *temoder_register,
+		u32 __iomem *remoder_register)
 {
 	/* Note: this function does not check if */
 	/* the parameters it receives are NULL   */
@@ -1307,8 +1311,8 @@ static int init_mac_station_addr_regs(u8 address_byte_0,
 				      u8 address_byte_3,
 				      u8 address_byte_4,
 				      u8 address_byte_5,
-				      volatile u32 *macstnaddr1_register,
-				      volatile u32 *macstnaddr2_register)
+				      u32 __iomem *macstnaddr1_register,
+				      u32 __iomem *macstnaddr2_register)
 {
 	u32 value = 0;
 
@@ -1344,7 +1348,7 @@ static int init_mac_station_addr_regs(u8 address_byte_0,
 }
 
 static int init_check_frame_length_mode(int length_check,
-					volatile u32 *maccfg2_register)
+					u32 __iomem *maccfg2_register)
 {
 	u32 value = 0;
 
@@ -1360,7 +1364,7 @@ static int init_check_frame_length_mode(int length_check,
 }
 
 static int init_preamble_length(u8 preamble_length,
-				volatile u32 *maccfg2_register)
+				u32 __iomem *maccfg2_register)
 {
 	u32 value = 0;
 
@@ -1376,7 +1380,7 @@ static int init_preamble_length(u8 preamble_length,
 
 static int init_rx_parameters(int reject_broadcast,
 			      int receive_short_frames,
-			      int promiscuous, volatile u32 *upsmr_register)
+			      int promiscuous, u32 __iomem *upsmr_register)
 {
 	u32 value = 0;
 
@@ -1403,7 +1407,7 @@ static int init_rx_parameters(int reject_broadcast,
 }
 
 static int init_max_rx_buff_len(u16 max_rx_buf_len,
-				volatile u16 *mrblr_register)
+				u16 __iomem *mrblr_register)
 {
 	/* max_rx_buf_len value must be a multiple of 128 */
 	if ((max_rx_buf_len == 0)
@@ -1415,8 +1419,8 @@ static int init_max_rx_buff_len(u16 max_rx_buf_len,
 }
 
 static int init_min_frame_len(u16 min_frame_length,
-			      volatile u16 *minflr_register,
-			      volatile u16 *mrblr_register)
+			      u16 __iomem *minflr_register,
+			      u16 __iomem *mrblr_register)
 {
 	u16 mrblr_value = 0;
 
@@ -1431,8 +1435,8 @@ static int init_min_frame_len(u16 min_frame_length,
 static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 {
 	struct ucc_geth_info *ug_info;
-	struct ucc_geth *ug_regs;
-	struct ucc_fast *uf_regs;
+	struct ucc_geth __iomem *ug_regs;
+	struct ucc_fast __iomem *uf_regs;
 	int ret_val;
 	u32 upsmr, maccfg2, tbiBaseAddress;
 	u16 value;
@@ -1517,8 +1521,8 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 static void adjust_link(struct net_device *dev)
 {
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
-	struct ucc_geth *ug_regs;
-	struct ucc_fast *uf_regs;
+	struct ucc_geth __iomem *ug_regs;
+	struct ucc_fast __iomem *uf_regs;
 	struct phy_device *phydev = ugeth->phydev;
 	unsigned long flags;
 	int new_state = 0;
@@ -1678,9 +1682,9 @@ static int ugeth_graceful_stop_rx(struct ucc_geth_private * ugeth)
 	uccf = ugeth->uccf;
 
 	/* Clear acknowledge bit */
-	temp = ugeth->p_rx_glbl_pram->rxgstpack;
+	temp = in_8(&ugeth->p_rx_glbl_pram->rxgstpack);
 	temp &= ~GRACEFUL_STOP_ACKNOWLEDGE_RX;
-	ugeth->p_rx_glbl_pram->rxgstpack = temp;
+	out_8(&ugeth->p_rx_glbl_pram->rxgstpack, temp);
 
 	/* Keep issuing command and checking acknowledge bit until
 	it is asserted, according to spec */
@@ -1692,7 +1696,7 @@ static int ugeth_graceful_stop_rx(struct ucc_geth_private * ugeth)
 		qe_issue_cmd(QE_GRACEFUL_STOP_RX, cecr_subblock,
 			     QE_CR_PROTOCOL_ETHERNET, 0);
 
-		temp = ugeth->p_rx_glbl_pram->rxgstpack;
+		temp = in_8(&ugeth->p_rx_glbl_pram->rxgstpack);
 	} while (!(temp & GRACEFUL_STOP_ACKNOWLEDGE_RX));
 
 	uccf->stopped_rx = 1;
@@ -1991,19 +1995,20 @@ static int ugeth_82xx_filtering_clear_all_addr_in_hash(struct ucc_geth_private *
 						       enum enet_addr_type
 						       enet_addr_type)
 {
-	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
+	struct ucc_geth_82xx_address_filtering_pram __iomem *p_82xx_addr_filt;
 	struct ucc_fast_private *uccf;
 	enum comm_dir comm_dir;
 	struct list_head *p_lh;
 	u16 i, num;
-	u32 *addr_h, *addr_l;
+	u32 __iomem *addr_h;
+	u32 __iomem *addr_l;
 	u8 *p_counter;
 
 	uccf = ugeth->uccf;
 
 	p_82xx_addr_filt =
-	    (struct ucc_geth_82xx_address_filtering_pram *) ugeth->p_rx_glbl_pram->
-	    addressfiltering;
+	    (struct ucc_geth_82xx_address_filtering_pram __iomem *)
+	    ugeth->p_rx_glbl_pram->addressfiltering;
 
 	if (enet_addr_type == ENET_ADDR_TYPE_GROUP) {
 		addr_h = &(p_82xx_addr_filt->gaddr_h);
@@ -2079,7 +2084,7 @@ static int ugeth_82xx_filtering_clear_addr_in_paddr(struct ucc_geth_private *uge
 static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 {
 	u16 i, j;
-	u8 *bd;
+	u8 __iomem *bd;
 
 	if (!ugeth)
 		return;
@@ -2154,8 +2159,8 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 		for (j = 0; j < ugeth->ug_info->bdRingLenTx[i]; j++) {
 			if (ugeth->tx_skbuff[i][j]) {
 				dma_unmap_single(NULL,
-						 ((struct qe_bd *)bd)->buf,
-						 (in_be32((u32 *)bd) &
+						 in_be32(&((struct qe_bd __iomem *)bd)->buf),
+						 (in_be32((u32 __iomem *)bd) &
 						  BD_LENGTH_MASK),
 						 DMA_TO_DEVICE);
 				dev_kfree_skb_any(ugeth->tx_skbuff[i][j]);
@@ -2182,7 +2187,7 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 			for (j = 0; j < ugeth->ug_info->bdRingLenRx[i]; j++) {
 				if (ugeth->rx_skbuff[i][j]) {
 					dma_unmap_single(NULL,
-						((struct qe_bd *)bd)->buf,
+						in_be32(&((struct qe_bd __iomem *)bd)->buf),
 						ugeth->ug_info->
 						uf_info.max_rx_buf_length +
 						UCC_GETH_RX_DATA_BUF_ALIGNMENT,
@@ -2218,8 +2223,8 @@ static void ucc_geth_set_multi(struct net_device *dev)
 {
 	struct ucc_geth_private *ugeth;
 	struct dev_mc_list *dmi;
-	struct ucc_fast *uf_regs;
-	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
+	struct ucc_fast __iomem *uf_regs;
+	struct ucc_geth_82xx_address_filtering_pram __iomem *p_82xx_addr_filt;
 	int i;
 
 	ugeth = netdev_priv(dev);
@@ -2228,14 +2233,14 @@ static void ucc_geth_set_multi(struct net_device *dev)
 
 	if (dev->flags & IFF_PROMISC) {
 
-		uf_regs->upsmr |= UPSMR_PRO;
+		out_be32(&uf_regs->upsmr, in_be32(&uf_regs->upsmr) | UPSMR_PRO);
 
 	} else {
 
-		uf_regs->upsmr &= ~UPSMR_PRO;
+		out_be32(&uf_regs->upsmr, in_be32(&uf_regs->upsmr)&~UPSMR_PRO);
 
 		p_82xx_addr_filt =
-		    (struct ucc_geth_82xx_address_filtering_pram *) ugeth->
+		    (struct ucc_geth_82xx_address_filtering_pram __iomem *) ugeth->
 		    p_rx_glbl_pram->addressfiltering;
 
 		if (dev->flags & IFF_ALLMULTI) {
@@ -2270,7 +2275,7 @@ static void ucc_geth_set_multi(struct net_device *dev)
 
 static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 {
-	struct ucc_geth *ug_regs = ugeth->ug_regs;
+	struct ucc_geth __iomem *ug_regs = ugeth->ug_regs;
 	struct phy_device *phydev = ugeth->phydev;
 	u32 tempval;
 
@@ -2419,20 +2424,20 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 		return -ENOMEM;
 	}
 
-	ugeth->ug_regs = (struct ucc_geth *) ioremap(uf_info->regs, sizeof(struct ucc_geth));
+	ugeth->ug_regs = (struct ucc_geth __iomem *) ioremap(uf_info->regs, sizeof(struct ucc_geth));
 
 	return 0;
 }
 
 static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 {
-	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
-	struct ucc_geth_init_pram *p_init_enet_pram;
+	struct ucc_geth_82xx_address_filtering_pram __iomem *p_82xx_addr_filt;
+	struct ucc_geth_init_pram __iomem *p_init_enet_pram;
 	struct ucc_fast_private *uccf;
 	struct ucc_geth_info *ug_info;
 	struct ucc_fast_info *uf_info;
-	struct ucc_fast *uf_regs;
-	struct ucc_geth *ug_regs;
+	struct ucc_fast __iomem *uf_regs;
+	struct ucc_geth __iomem *ug_regs;
 	int ret_val = -EINVAL;
 	u32 remoder = UCC_GETH_REMODER_INIT;
 	u32 init_enet_pram_offset, cecr_subblock, command, maccfg1;
@@ -2440,7 +2445,8 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	u16 temoder = UCC_GETH_TEMODER_INIT;
 	u16 test;
 	u8 function_code = 0;
-	u8 *bd, *endOfRing;
+	u8 __iomem *bd;
+	u8 __iomem *endOfRing;
 	u8 numThreadsRxNumerical, numThreadsTxNumerical;
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
@@ -2602,11 +2608,11 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (UCC_GETH_TX_BD_RING_ALIGNMENT > 4)
 				align = UCC_GETH_TX_BD_RING_ALIGNMENT;
 			ugeth->tx_bd_ring_offset[j] =
-				kmalloc((u32) (length + align), GFP_KERNEL);
+				(u32) kmalloc((u32) (length + align), GFP_KERNEL);
 
 			if (ugeth->tx_bd_ring_offset[j] != 0)
 				ugeth->p_tx_bd_ring[j] =
-					(void*)((ugeth->tx_bd_ring_offset[j] +
+					(u8 __iomem *)((ugeth->tx_bd_ring_offset[j] +
 					align) & ~(align - 1));
 		} else if (uf_info->bd_mem_part == MEM_PART_MURAM) {
 			ugeth->tx_bd_ring_offset[j] =
@@ -2614,7 +2620,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 					   UCC_GETH_TX_BD_RING_ALIGNMENT);
 			if (!IS_ERR_VALUE(ugeth->tx_bd_ring_offset[j]))
 				ugeth->p_tx_bd_ring[j] =
-				    (u8 *) qe_muram_addr(ugeth->
+				    (u8 __iomem *) qe_muram_addr(ugeth->
 							 tx_bd_ring_offset[j]);
 		}
 		if (!ugeth->p_tx_bd_ring[j]) {
@@ -2626,8 +2632,8 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			return -ENOMEM;
 		}
 		/* Zero unused end of bd ring, according to spec */
-		memset(ugeth->p_tx_bd_ring[j] +
-		       ug_info->bdRingLenTx[j] * sizeof(struct qe_bd), 0,
+		memset_io((void __iomem *)(ugeth->p_tx_bd_ring[j] +
+		       ug_info->bdRingLenTx[j] * sizeof(struct qe_bd)), 0,
 		       length - ug_info->bdRingLenTx[j] * sizeof(struct qe_bd));
 	}
 
@@ -2639,10 +2645,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (UCC_GETH_RX_BD_RING_ALIGNMENT > 4)
 				align = UCC_GETH_RX_BD_RING_ALIGNMENT;
 			ugeth->rx_bd_ring_offset[j] =
-				kmalloc((u32) (length + align), GFP_KERNEL);
+				(u32) kmalloc((u32) (length + align), GFP_KERNEL);
 			if (ugeth->rx_bd_ring_offset[j] != 0)
 				ugeth->p_rx_bd_ring[j] =
-					(void*)((ugeth->rx_bd_ring_offset[j] +
+					(u8 __iomem *)((ugeth->rx_bd_ring_offset[j] +
 					align) & ~(align - 1));
 		} else if (uf_info->bd_mem_part == MEM_PART_MURAM) {
 			ugeth->rx_bd_ring_offset[j] =
@@ -2650,7 +2656,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 					   UCC_GETH_RX_BD_RING_ALIGNMENT);
 			if (!IS_ERR_VALUE(ugeth->rx_bd_ring_offset[j]))
 				ugeth->p_rx_bd_ring[j] =
-				    (u8 *) qe_muram_addr(ugeth->
+				    (u8 __iomem *) qe_muram_addr(ugeth->
 							 rx_bd_ring_offset[j]);
 		}
 		if (!ugeth->p_rx_bd_ring[j]) {
@@ -2685,14 +2691,14 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		bd = ugeth->confBd[j] = ugeth->txBd[j] = ugeth->p_tx_bd_ring[j];
 		for (i = 0; i < ug_info->bdRingLenTx[j]; i++) {
 			/* clear bd buffer */
-			out_be32(&((struct qe_bd *)bd)->buf, 0);
+			out_be32(&((struct qe_bd __iomem *)bd)->buf, 0);
 			/* set bd status and length */
-			out_be32((u32 *)bd, 0);
+			out_be32((u32 __iomem *)bd, 0);
 			bd += sizeof(struct qe_bd);
 		}
 		bd -= sizeof(struct qe_bd);
 		/* set bd status and length */
-		out_be32((u32 *)bd, T_W);	/* for last BD set Wrap bit */
+		out_be32((u32 __iomem *)bd, T_W); /* for last BD set Wrap bit */
 	}
 
 	/* Init Rx bds */
@@ -2717,14 +2723,14 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		bd = ugeth->rxBd[j] = ugeth->p_rx_bd_ring[j];
 		for (i = 0; i < ug_info->bdRingLenRx[j]; i++) {
 			/* set bd status and length */
-			out_be32((u32 *)bd, R_I);
+			out_be32((u32 __iomem *)bd, R_I);
 			/* clear bd buffer */
-			out_be32(&((struct qe_bd *)bd)->buf, 0);
+			out_be32(&((struct qe_bd __iomem *)bd)->buf, 0);
 			bd += sizeof(struct qe_bd);
 		}
 		bd -= sizeof(struct qe_bd);
 		/* set bd status and length */
-		out_be32((u32 *)bd, R_W); /* for last BD set Wrap bit */
+		out_be32((u32 __iomem *)bd, R_W); /* for last BD set Wrap bit */
 	}
 
 	/*
@@ -2744,10 +2750,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		return -ENOMEM;
 	}
 	ugeth->p_tx_glbl_pram =
-	    (struct ucc_geth_tx_global_pram *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_tx_global_pram __iomem *) qe_muram_addr(ugeth->
 							tx_glbl_pram_offset);
 	/* Zero out p_tx_glbl_pram */
-	memset(ugeth->p_tx_glbl_pram, 0, sizeof(struct ucc_geth_tx_global_pram));
+	memset_io((void __iomem *)ugeth->p_tx_glbl_pram, 0, sizeof(struct ucc_geth_tx_global_pram));
 
 	/* Fill global PRAM */
 
@@ -2768,7 +2774,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	}
 
 	ugeth->p_thread_data_tx =
-	    (struct ucc_geth_thread_data_tx *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_thread_data_tx __iomem *) qe_muram_addr(ugeth->
 							thread_dat_tx_offset);
 	out_be32(&ugeth->p_tx_glbl_pram->tqptr, ugeth->thread_dat_tx_offset);
 
@@ -2779,7 +2785,8 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 
 	/* iphoffset */
 	for (i = 0; i < TX_IP_OFFSET_ENTRY_MAX; i++)
-		ugeth->p_tx_glbl_pram->iphoffset[i] = ug_info->iphoffset[i];
+		out_8(&ugeth->p_tx_glbl_pram->iphoffset[i],
+				ug_info->iphoffset[i]);
 
 	/* SQPTR */
 	/* Size varies with number of Tx queues */
@@ -2797,7 +2804,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	}
 
 	ugeth->p_send_q_mem_reg =
-	    (struct ucc_geth_send_queue_mem_region *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_send_queue_mem_region __iomem *) qe_muram_addr(ugeth->
 			send_q_mem_reg_offset);
 	out_be32(&ugeth->p_tx_glbl_pram->sqptr, ugeth->send_q_mem_reg_offset);
 
@@ -2841,25 +2848,26 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		}
 
 		ugeth->p_scheduler =
-		    (struct ucc_geth_scheduler *) qe_muram_addr(ugeth->
+		    (struct ucc_geth_scheduler __iomem *) qe_muram_addr(ugeth->
 							   scheduler_offset);
 		out_be32(&ugeth->p_tx_glbl_pram->schedulerbasepointer,
 			 ugeth->scheduler_offset);
 		/* Zero out p_scheduler */
-		memset(ugeth->p_scheduler, 0, sizeof(struct ucc_geth_scheduler));
+		memset_io((void __iomem *)ugeth->p_scheduler, 0, sizeof(struct ucc_geth_scheduler));
 
 		/* Set values in scheduler */
 		out_be32(&ugeth->p_scheduler->mblinterval,
 			 ug_info->mblinterval);
 		out_be16(&ugeth->p_scheduler->nortsrbytetime,
 			 ug_info->nortsrbytetime);
-		ugeth->p_scheduler->fracsiz = ug_info->fracsiz;
-		ugeth->p_scheduler->strictpriorityq = ug_info->strictpriorityq;
-		ugeth->p_scheduler->txasap = ug_info->txasap;
-		ugeth->p_scheduler->extrabw = ug_info->extrabw;
+		out_8(&ugeth->p_scheduler->fracsiz, ug_info->fracsiz);
+		out_8(&ugeth->p_scheduler->strictpriorityq,
+				ug_info->strictpriorityq);
+		out_8(&ugeth->p_scheduler->txasap, ug_info->txasap);
+		out_8(&ugeth->p_scheduler->extrabw, ug_info->extrabw);
 		for (i = 0; i < NUM_TX_QUEUES; i++)
-			ugeth->p_scheduler->weightfactor[i] =
-			    ug_info->weightfactor[i];
+			out_8(&ugeth->p_scheduler->weightfactor[i],
+			    ug_info->weightfactor[i]);
 
 		/* Set pointers to cpucount registers in scheduler */
 		ugeth->p_cpucount[0] = &(ugeth->p_scheduler->cpucount0);
@@ -2890,10 +2898,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			return -ENOMEM;
 		}
 		ugeth->p_tx_fw_statistics_pram =
-		    (struct ucc_geth_tx_firmware_statistics_pram *)
+		    (struct ucc_geth_tx_firmware_statistics_pram __iomem *)
 		    qe_muram_addr(ugeth->tx_fw_statistics_pram_offset);
 		/* Zero out p_tx_fw_statistics_pram */
-		memset(ugeth->p_tx_fw_statistics_pram,
+		memset_io((void __iomem *)ugeth->p_tx_fw_statistics_pram,
 		       0, sizeof(struct ucc_geth_tx_firmware_statistics_pram));
 	}
 
@@ -2930,10 +2938,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		return -ENOMEM;
 	}
 	ugeth->p_rx_glbl_pram =
-	    (struct ucc_geth_rx_global_pram *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_rx_global_pram __iomem *) qe_muram_addr(ugeth->
 							rx_glbl_pram_offset);
 	/* Zero out p_rx_glbl_pram */
-	memset(ugeth->p_rx_glbl_pram, 0, sizeof(struct ucc_geth_rx_global_pram));
+	memset_io((void __iomem *)ugeth->p_rx_glbl_pram, 0, sizeof(struct ucc_geth_rx_global_pram));
 
 	/* Fill global PRAM */
 
@@ -2953,7 +2961,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	}
 
 	ugeth->p_thread_data_rx =
-	    (struct ucc_geth_thread_data_rx *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_thread_data_rx __iomem *) qe_muram_addr(ugeth->
 							thread_dat_rx_offset);
 	out_be32(&ugeth->p_rx_glbl_pram->rqptr, ugeth->thread_dat_rx_offset);
 
@@ -2976,10 +2984,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			return -ENOMEM;
 		}
 		ugeth->p_rx_fw_statistics_pram =
-		    (struct ucc_geth_rx_firmware_statistics_pram *)
+		    (struct ucc_geth_rx_firmware_statistics_pram __iomem *)
 		    qe_muram_addr(ugeth->rx_fw_statistics_pram_offset);
 		/* Zero out p_rx_fw_statistics_pram */
-		memset(ugeth->p_rx_fw_statistics_pram, 0,
+		memset_io((void __iomem *)ugeth->p_rx_fw_statistics_pram, 0,
 		       sizeof(struct ucc_geth_rx_firmware_statistics_pram));
 	}
 
@@ -3000,7 +3008,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	}
 
 	ugeth->p_rx_irq_coalescing_tbl =
-	    (struct ucc_geth_rx_interrupt_coalescing_table *)
+	    (struct ucc_geth_rx_interrupt_coalescing_table __iomem *)
 	    qe_muram_addr(ugeth->rx_irq_coalescing_tbl_offset);
 	out_be32(&ugeth->p_rx_glbl_pram->intcoalescingptr,
 		 ugeth->rx_irq_coalescing_tbl_offset);
@@ -3069,11 +3077,11 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	}
 
 	ugeth->p_rx_bd_qs_tbl =
-	    (struct ucc_geth_rx_bd_queues_entry *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_rx_bd_queues_entry __iomem *) qe_muram_addr(ugeth->
 				    rx_bd_qs_tbl_offset);
 	out_be32(&ugeth->p_rx_glbl_pram->rbdqptr, ugeth->rx_bd_qs_tbl_offset);
 	/* Zero out p_rx_bd_qs_tbl */
-	memset(ugeth->p_rx_bd_qs_tbl,
+	memset_io((void __iomem *)ugeth->p_rx_bd_qs_tbl,
 	       0,
 	       ug_info->numQueuesRx * (sizeof(struct ucc_geth_rx_bd_queues_entry) +
 				       sizeof(struct ucc_geth_rx_prefetched_bds)));
@@ -3133,7 +3141,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		&ugeth->p_rx_glbl_pram->remoder);
 
 	/* function code register */
-	ugeth->p_rx_glbl_pram->rstate = function_code;
+	out_8(&ugeth->p_rx_glbl_pram->rstate, function_code);
 
 	/* initialize extended filtering */
 	if (ug_info->rxExtendedFiltering) {
@@ -3160,7 +3168,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		}
 
 		ugeth->p_exf_glbl_param =
-		    (struct ucc_geth_exf_global_pram *) qe_muram_addr(ugeth->
+		    (struct ucc_geth_exf_global_pram __iomem *) qe_muram_addr(ugeth->
 				 exf_glbl_param_offset);
 		out_be32(&ugeth->p_rx_glbl_pram->exfGlobalParam,
 			 ugeth->exf_glbl_param_offset);
@@ -3175,7 +3183,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			ugeth_82xx_filtering_clear_addr_in_paddr(ugeth, (u8) j);
 
 		p_82xx_addr_filt =
-		    (struct ucc_geth_82xx_address_filtering_pram *) ugeth->
+		    (struct ucc_geth_82xx_address_filtering_pram __iomem *) ugeth->
 		    p_rx_glbl_pram->addressfiltering;
 
 		ugeth_82xx_filtering_clear_all_addr_in_hash(ugeth,
@@ -3307,17 +3315,21 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		return -ENOMEM;
 	}
 	p_init_enet_pram =
-	    (struct ucc_geth_init_pram *) qe_muram_addr(init_enet_pram_offset);
+	    (struct ucc_geth_init_pram __iomem *) qe_muram_addr(init_enet_pram_offset);
 
 	/* Copy shadow InitEnet command parameter structure into PRAM */
-	p_init_enet_pram->resinit1 = ugeth->p_init_enet_param_shadow->resinit1;
-	p_init_enet_pram->resinit2 = ugeth->p_init_enet_param_shadow->resinit2;
-	p_init_enet_pram->resinit3 = ugeth->p_init_enet_param_shadow->resinit3;
-	p_init_enet_pram->resinit4 = ugeth->p_init_enet_param_shadow->resinit4;
+	out_8(&p_init_enet_pram->resinit1,
+			ugeth->p_init_enet_param_shadow->resinit1);
+	out_8(&p_init_enet_pram->resinit2,
+			ugeth->p_init_enet_param_shadow->resinit2);
+	out_8(&p_init_enet_pram->resinit3,
+			ugeth->p_init_enet_param_shadow->resinit3);
+	out_8(&p_init_enet_pram->resinit4,
+			ugeth->p_init_enet_param_shadow->resinit4);
 	out_be16(&p_init_enet_pram->resinit5,
 		 ugeth->p_init_enet_param_shadow->resinit5);
-	p_init_enet_pram->largestexternallookupkeysize =
-	    ugeth->p_init_enet_param_shadow->largestexternallookupkeysize;
+	out_8(&p_init_enet_pram->largestexternallookupkeysize,
+	    ugeth->p_init_enet_param_shadow->largestexternallookupkeysize);
 	out_be32(&p_init_enet_pram->rgftgfrxglobal,
 		 ugeth->p_init_enet_param_shadow->rgftgfrxglobal);
 	for (i = 0; i < ENET_INIT_PARAM_MAX_ENTRIES_RX; i++)
@@ -3371,7 +3383,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 #ifdef CONFIG_UGETH_TX_ON_DEMAND
 	struct ucc_fast_private *uccf;
 #endif
-	u8 *bd;			/* BD pointer */
+	u8 __iomem *bd;			/* BD pointer */
 	u32 bd_status;
 	u8 txQ = 0;
 
@@ -3383,7 +3395,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Start from the next BD that should be filled */
 	bd = ugeth->txBd[txQ];
-	bd_status = in_be32((u32 *)bd);
+	bd_status = in_be32((u32 __iomem *)bd);
 	/* Save the skb pointer so we can free it later */
 	ugeth->tx_skbuff[txQ][ugeth->skb_curtx[txQ]] = skb;
 
@@ -3393,7 +3405,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	     1) & TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
 
 	/* set up the buffer descriptor */
-	out_be32(&((struct qe_bd *)bd)->buf,
+	out_be32(&((struct qe_bd __iomem *)bd)->buf,
 		      dma_map_single(NULL, skb->data, skb->len, DMA_TO_DEVICE));
 
 	/* printk(KERN_DEBUG"skb->data is 0x%x\n",skb->data); */
@@ -3401,7 +3413,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	bd_status = (bd_status & T_W) | T_R | T_I | T_L | skb->len;
 
 	/* set bd status and length */
-	out_be32((u32 *)bd, bd_status);
+	out_be32((u32 __iomem *)bd, bd_status);
 
 	dev->trans_start = jiffies;
 
@@ -3441,7 +3453,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit)
 {
 	struct sk_buff *skb;
-	u8 *bd;
+	u8 __iomem *bd;
 	u16 length, howmany = 0;
 	u32 bd_status;
 	u8 *bdBuffer;
@@ -3454,11 +3466,11 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 	/* collect received buffers */
 	bd = ugeth->rxBd[rxQ];
 
-	bd_status = in_be32((u32 *)bd);
+	bd_status = in_be32((u32 __iomem *)bd);
 
 	/* while there are received buffers and BD is full (~R_E) */
 	while (!((bd_status & (R_E)) || (--rx_work_limit < 0))) {
-		bdBuffer = (u8 *) in_be32(&((struct qe_bd *)bd)->buf);
+		bdBuffer = (u8 *) in_be32(&((struct qe_bd __iomem *)bd)->buf);
 		length = (u16) ((bd_status & BD_LENGTH_MASK) - 4);
 		skb = ugeth->rx_skbuff[rxQ][ugeth->skb_currx[rxQ]];
 
@@ -3516,7 +3528,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 		else
 			bd += sizeof(struct qe_bd);
 
-		bd_status = in_be32((u32 *)bd);
+		bd_status = in_be32((u32 __iomem *)bd);
 	}
 
 	ugeth->rxBd[rxQ] = bd;
@@ -3527,11 +3539,11 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 {
 	/* Start from the next BD that should be filled */
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
-	u8 *bd;			/* BD pointer */
+	u8 __iomem *bd;		/* BD pointer */
 	u32 bd_status;
 
 	bd = ugeth->confBd[txQ];
-	bd_status = in_be32((u32 *)bd);
+	bd_status = in_be32((u32 __iomem *)bd);
 
 	/* Normal processing. */
 	while ((bd_status & T_R) == 0) {
@@ -3561,7 +3573,7 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 			bd += sizeof(struct qe_bd);
 		else
 			bd = ugeth->p_tx_bd_ring[txQ];
-		bd_status = in_be32((u32 *)bd);
+		bd_status = in_be32((u32 __iomem *)bd);
 	}
 	ugeth->confBd[txQ] = bd;
 	return 0;
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index 9f8b758..abc0e22 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -700,8 +700,8 @@ struct ucc_geth_82xx_address_filtering_pram {
 	u32 iaddr_l;		/* individual address filter, low */
 	u32 gaddr_h;		/* group address filter, high */
 	u32 gaddr_l;		/* group address filter, low */
-	struct ucc_geth_82xx_enet_address taddr;
-	struct ucc_geth_82xx_enet_address paddr[NUM_OF_PADDRS];
+	struct ucc_geth_82xx_enet_address __iomem taddr;
+	struct ucc_geth_82xx_enet_address __iomem paddr[NUM_OF_PADDRS];
 	u8 res0[0x40 - 0x38];
 } __attribute__ ((packed));
 
@@ -1186,40 +1186,40 @@ struct ucc_geth_private {
 	struct ucc_fast_private *uccf;
 	struct net_device *dev;
 	struct napi_struct napi;
-	struct ucc_geth *ug_regs;
+	struct ucc_geth __iomem *ug_regs;
 	struct ucc_geth_init_pram *p_init_enet_param_shadow;
-	struct ucc_geth_exf_global_pram *p_exf_glbl_param;
+	struct ucc_geth_exf_global_pram __iomem *p_exf_glbl_param;
 	u32 exf_glbl_param_offset;
-	struct ucc_geth_rx_global_pram *p_rx_glbl_pram;
+	struct ucc_geth_rx_global_pram __iomem *p_rx_glbl_pram;
 	u32 rx_glbl_pram_offset;
-	struct ucc_geth_tx_global_pram *p_tx_glbl_pram;
+	struct ucc_geth_tx_global_pram __iomem *p_tx_glbl_pram;
 	u32 tx_glbl_pram_offset;
-	struct ucc_geth_send_queue_mem_region *p_send_q_mem_reg;
+	struct ucc_geth_send_queue_mem_region __iomem *p_send_q_mem_reg;
 	u32 send_q_mem_reg_offset;
-	struct ucc_geth_thread_data_tx *p_thread_data_tx;
+	struct ucc_geth_thread_data_tx __iomem *p_thread_data_tx;
 	u32 thread_dat_tx_offset;
-	struct ucc_geth_thread_data_rx *p_thread_data_rx;
+	struct ucc_geth_thread_data_rx __iomem *p_thread_data_rx;
 	u32 thread_dat_rx_offset;
-	struct ucc_geth_scheduler *p_scheduler;
+	struct ucc_geth_scheduler __iomem *p_scheduler;
 	u32 scheduler_offset;
-	struct ucc_geth_tx_firmware_statistics_pram *p_tx_fw_statistics_pram;
+	struct ucc_geth_tx_firmware_statistics_pram __iomem *p_tx_fw_statistics_pram;
 	u32 tx_fw_statistics_pram_offset;
-	struct ucc_geth_rx_firmware_statistics_pram *p_rx_fw_statistics_pram;
+	struct ucc_geth_rx_firmware_statistics_pram __iomem *p_rx_fw_statistics_pram;
 	u32 rx_fw_statistics_pram_offset;
-	struct ucc_geth_rx_interrupt_coalescing_table *p_rx_irq_coalescing_tbl;
+	struct ucc_geth_rx_interrupt_coalescing_table __iomem *p_rx_irq_coalescing_tbl;
 	u32 rx_irq_coalescing_tbl_offset;
-	struct ucc_geth_rx_bd_queues_entry *p_rx_bd_qs_tbl;
+	struct ucc_geth_rx_bd_queues_entry __iomem *p_rx_bd_qs_tbl;
 	u32 rx_bd_qs_tbl_offset;
-	u8 *p_tx_bd_ring[NUM_TX_QUEUES];
+	u8 __iomem *p_tx_bd_ring[NUM_TX_QUEUES];
 	u32 tx_bd_ring_offset[NUM_TX_QUEUES];
-	u8 *p_rx_bd_ring[NUM_RX_QUEUES];
+	u8 __iomem *p_rx_bd_ring[NUM_RX_QUEUES];
 	u32 rx_bd_ring_offset[NUM_RX_QUEUES];
-	u8 *confBd[NUM_TX_QUEUES];
-	u8 *txBd[NUM_TX_QUEUES];
-	u8 *rxBd[NUM_RX_QUEUES];
+	u8 __iomem *confBd[NUM_TX_QUEUES];
+	u8 __iomem *txBd[NUM_TX_QUEUES];
+	u8 __iomem *rxBd[NUM_RX_QUEUES];
 	int badFrame[NUM_RX_QUEUES];
 	u16 cpucount[NUM_TX_QUEUES];
-	volatile u16 *p_cpucount[NUM_TX_QUEUES];
+	u16 __iomem *p_cpucount[NUM_TX_QUEUES];
 	int indAddrRegUsed[NUM_OF_PADDRS];
 	u8 paddr[NUM_OF_PADDRS][ENET_NUM_OCTETS_PER_ADDRESS];	/* ethernet address */
 	u8 numGroupAddrInHash;
@@ -1251,4 +1251,12 @@ struct ucc_geth_private {
 	int oldlink;
 };
 
+void uec_set_ethtool_ops(struct net_device *netdev);
+int init_flow_control_params(u32 automatic_flow_control_mode,
+		int rx_flow_control_enable, int tx_flow_control_enable,
+		u16 pause_period, u16 extension_field,
+		u32 __iomem *upsmr_register, u32 __iomem *uempr_register,
+		u32 __iomem *maccfg1_register);
+
+
 #endif				/* __UCC_GETH_H__ */
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index 9a9622c..299b7f1 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -108,12 +108,6 @@ static char rx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
 #define UEC_TX_FW_STATS_LEN ARRAY_SIZE(tx_fw_stat_gstrings)
 #define UEC_RX_FW_STATS_LEN ARRAY_SIZE(rx_fw_stat_gstrings)
 
-extern int init_flow_control_params(u32 automatic_flow_control_mode,
-		int rx_flow_control_enable,
-		int tx_flow_control_enable, u16 pause_period,
-		u16 extension_field, volatile u32 *upsmr_register,
-		volatile u32 *uempr_register, volatile u32 *maccfg1_register);
-
 static int
 uec_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index 2af4907..9404747 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -104,7 +104,7 @@ int uec_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 }
 
 /* Reset the MIIM registers, and wait for the bus to free */
-int uec_mdio_reset(struct mii_bus *bus)
+static int uec_mdio_reset(struct mii_bus *bus)
 {
 	struct ucc_mii_mng __iomem *regs = (void __iomem *)bus->priv;
 	unsigned int timeout = PHY_INIT_TIMEOUT;
@@ -240,7 +240,7 @@ reg_map_fail:
 	return err;
 }
 
-int uec_mdio_remove(struct of_device *ofdev)
+static int uec_mdio_remove(struct of_device *ofdev)
 {
 	struct device *device = &ofdev->dev;
 	struct mii_bus *bus = dev_get_drvdata(device);
-- 
1.5.4.GIT

