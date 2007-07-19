From: Li Yang <leoli@freescale.com>
Subject: [PATCH 2/2] ucc_geth: add support to netif message level
Date: Thu, 19 Jul 2007 11:48:29 +0800
Message-ID: <11848169092098-git-send-email-leoli@freescale.com>
Cc: netdev@vger.kernel.org, Li Yang <leoli@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:48670 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758283AbXGSDhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 23:37:38 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id l6J3bWSM001825
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2007 20:37:33 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id l6J3bSOV016894
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2007 22:37:29 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds netif message level control to the ucc_geth driver.  The level can
be set by module parameter and ethtool.

Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/ucc_geth.c |  315 +++++++++++++++++++++++++++++-------------------
 1 files changed, 190 insertions(+), 125 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 4a3fd62..12e01b2 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -60,11 +60,19 @@
 #else
 #define ugeth_vdbg(fmt, args...) do { } while (0)
 #endif				/* UGETH_VERBOSE_DEBUG */
+#define UGETH_MSG_DEFAULT	(NETIF_MSG_IFUP << 1 ) - 1
 
 void uec_set_ethtool_ops(struct net_device *netdev);
 	
 static DEFINE_SPINLOCK(ugeth_lock);
 
+static struct {
+	u32 msg_enable;
+} debug = { -1 };
+
+module_param_named(debug, debug.msg_enable, int, 0);
+MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., 0xffff=all)");
+
 static struct ucc_geth_info ugeth_primary_info = {
 	.uf_info = {
 		    .bd_mem_part = MEM_PART_SYSTEM,
@@ -282,7 +290,8 @@ static int fill_init_enet_entries(struct ucc_geth_private *ugeth,
 
 	for (i = 0; i < num_entries; i++) {
 		if ((snum = qe_get_snum()) < 0) {
-			ugeth_err("fill_init_enet_entries: Can not get SNUM.");
+			if (netif_msg_ifup(ugeth))
+				ugeth_err("fill_init_enet_entries: Can not get SNUM.");
 			return snum;
 		}
 		if ((i == 0) && skip_page_for_first_entry)
@@ -292,8 +301,8 @@ static int fill_init_enet_entries(struct ucc_geth_private *ugeth,
 			init_enet_offset =
 			    qe_muram_alloc(thread_size, thread_alignment);
 			if (IS_ERR_VALUE(init_enet_offset)) {
-				ugeth_err
-		("fill_init_enet_entries: Can not allocate DPRAM memory.");
+				if (netif_msg_ifup(ugeth))
+					ugeth_err("fill_init_enet_entries: Can not allocate DPRAM memory.");
 				qe_put_snum((u8) snum);
 				return -ENOMEM;
 			}
@@ -1487,9 +1496,9 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 
 	ret_val = init_preamble_length(ug_info->prel, &ug_regs->maccfg2);
 	if (ret_val != 0) {
-		ugeth_err
-		    ("%s: Preamble length must be between 3 and 7 inclusive.",
-		     __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: Preamble length must be between 3 and 7 inclusive.",
+			     __FUNCTION__);
 		return ret_val;
 	}
 
@@ -1727,7 +1736,8 @@ static int ugeth_enable(struct ucc_geth_private *ugeth, enum comm_dir mode)
 
 	/* check if the UCC number is in range. */
 	if (ugeth->ug_info->uf_info.ucc_num >= UCC_MAX_NUM) {
-		ugeth_err("%s: ucc_num out of range.", __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: ucc_num out of range.", __FUNCTION__);
 		return -EINVAL;
 	}
 
@@ -1755,7 +1765,8 @@ static int ugeth_disable(struct ucc_geth_private * ugeth, enum comm_dir mode)
 
 	/* check if the UCC number is in range. */
 	if (ugeth->ug_info->uf_info.ucc_num >= UCC_MAX_NUM) {
-		ugeth_err("%s: ucc_num out of range.", __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: ucc_num out of range.", __FUNCTION__);
 		return -EINVAL;
 	}
 
@@ -2307,7 +2318,9 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 
 	if (!((uf_info->bd_mem_part == MEM_PART_SYSTEM) ||
 	      (uf_info->bd_mem_part == MEM_PART_MURAM))) {
-		ugeth_err("%s: Bad memory partition value.", __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: Bad memory partition value.",
+					__FUNCTION__);
 		return -EINVAL;
 	}
 
@@ -2316,9 +2329,10 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 		if ((ug_info->bdRingLenRx[i] < UCC_GETH_RX_BD_RING_SIZE_MIN) ||
 		    (ug_info->bdRingLenRx[i] %
 		     UCC_GETH_RX_BD_RING_SIZE_ALIGNMENT)) {
-			ugeth_err
-			    ("%s: Rx BD ring length must be multiple of 4,"
-				" no smaller than 8.", __FUNCTION__);
+			if (netif_msg_probe(ugeth))
+				ugeth_err
+				    ("%s: Rx BD ring length must be multiple of 4, no smaller than 8.",
+					__FUNCTION__);
 			return -EINVAL;
 		}
 	}
@@ -2326,9 +2340,10 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	/* Tx BD lengths */
 	for (i = 0; i < ug_info->numQueuesTx; i++) {
 		if (ug_info->bdRingLenTx[i] < UCC_GETH_TX_BD_RING_SIZE_MIN) {
-			ugeth_err
-			    ("%s: Tx BD ring length must be no smaller than 2.",
-			     __FUNCTION__);
+			if (netif_msg_probe(ugeth))
+				ugeth_err
+				    ("%s: Tx BD ring length must be no smaller than 2.",
+				     __FUNCTION__);
 			return -EINVAL;
 		}
 	}
@@ -2336,31 +2351,35 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	/* mrblr */
 	if ((uf_info->max_rx_buf_length == 0) ||
 	    (uf_info->max_rx_buf_length % UCC_GETH_MRBLR_ALIGNMENT)) {
-		ugeth_err
-		    ("%s: max_rx_buf_length must be non-zero multiple of 128.",
-		     __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err
+			    ("%s: max_rx_buf_length must be non-zero multiple of 128.",
+			     __FUNCTION__);
 		return -EINVAL;
 	}
 
 	/* num Tx queues */
 	if (ug_info->numQueuesTx > NUM_TX_QUEUES) {
-		ugeth_err("%s: number of tx queues too large.", __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: number of tx queues too large.", __FUNCTION__);
 		return -EINVAL;
 	}
 
 	/* num Rx queues */
 	if (ug_info->numQueuesRx > NUM_RX_QUEUES) {
-		ugeth_err("%s: number of rx queues too large.", __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: number of rx queues too large.", __FUNCTION__);
 		return -EINVAL;
 	}
 
 	/* l2qt */
 	for (i = 0; i < UCC_GETH_VLAN_PRIORITY_MAX; i++) {
 		if (ug_info->l2qt[i] >= ug_info->numQueuesRx) {
-			ugeth_err
-			    ("%s: VLAN priority table entry must not be"
-				" larger than number of Rx queues.",
-			     __FUNCTION__);
+			if (netif_msg_probe(ugeth))
+				ugeth_err
+				    ("%s: VLAN priority table entry must not be"
+					" larger than number of Rx queues.",
+				     __FUNCTION__);
 			return -EINVAL;
 		}
 	}
@@ -2368,26 +2387,29 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	/* l3qt */
 	for (i = 0; i < UCC_GETH_IP_PRIORITY_MAX; i++) {
 		if (ug_info->l3qt[i] >= ug_info->numQueuesRx) {
-			ugeth_err
-			    ("%s: IP priority table entry must not be"
-				" larger than number of Rx queues.",
-			     __FUNCTION__);
+			if (netif_msg_probe(ugeth))
+				ugeth_err
+				    ("%s: IP priority table entry must not be"
+					" larger than number of Rx queues.",
+				     __FUNCTION__);
 			return -EINVAL;
 		}
 	}
 
 	if (ug_info->cam && !ug_info->ecamptr) {
-		ugeth_err("%s: If cam mode is chosen, must supply cam ptr.",
-			  __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: If cam mode is chosen, must supply cam ptr.",
+				  __FUNCTION__);
 		return -EINVAL;
 	}
 
 	if ((ug_info->numStationAddresses !=
 	     UCC_GETH_NUM_OF_STATION_ADDRESSES_1)
 	    && ug_info->rxExtendedFiltering) {
-		ugeth_err("%s: Number of station addresses greater than 1 "
-			  "not allowed in extended parsing mode.",
-			  __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: Number of station addresses greater than 1 "
+				  "not allowed in extended parsing mode.",
+				  __FUNCTION__);
 		return -EINVAL;
 	}
 
@@ -2400,7 +2422,8 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 		uf_info->uccm_mask |= (UCCE_TXBF_SINGLE_MASK << i);
 	/* Initialize the general fast UCC block. */
 	if (ucc_fast_init(uf_info, &ugeth->uccf)) {
-		ugeth_err("%s: Failed to init uccf.", __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: Failed to init uccf.", __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2453,7 +2476,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		numThreadsRxNumerical = 8;
 		break;
 	default:
-		ugeth_err("%s: Bad number of Rx threads value.", __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Bad number of Rx threads value.",
+				       	__FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 		break;
@@ -2476,7 +2501,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		numThreadsTxNumerical = 8;
 		break;
 	default:
-		ugeth_err("%s: Bad number of Tx threads value.", __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Bad number of Tx threads value.",
+				       	__FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 		break;
@@ -2528,8 +2555,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 					      ug_info->backToBackInterFrameGap,
 					      &ug_regs->ipgifg);
 	if (ret_val != 0) {
-		ugeth_err("%s: IPGIFG initialization parameter too large.",
-			  __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: IPGIFG initialization parameter too large.",
+				  __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -2545,7 +2573,8 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 					  ug_info->collisionWindow,
 					  &ug_regs->hafdup);
 	if (ret_val != 0) {
-		ugeth_err("%s: Half Duplex initialization parameter too large.",
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Half Duplex initialization parameter too large.",
 			  __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
@@ -2598,9 +2627,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 							 tx_bd_ring_offset[j]);
 		}
 		if (!ugeth->p_tx_bd_ring[j]) {
-			ugeth_err
-			    ("%s: Can not allocate memory for Tx bd rings.",
-			     __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err
+				    ("%s: Can not allocate memory for Tx bd rings.",
+				     __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2633,9 +2663,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 							 rx_bd_ring_offset[j]);
 		}
 		if (!ugeth->p_rx_bd_ring[j]) {
-			ugeth_err
-			    ("%s: Can not allocate memory for Rx bd rings.",
-			     __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err
+				    ("%s: Can not allocate memory for Rx bd rings.",
+				     __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2649,8 +2680,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 					      GFP_KERNEL);
 
 		if (ugeth->tx_skbuff[j] == NULL) {
-			ugeth_err("%s: Could not allocate tx_skbuff",
-				  __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err("%s: Could not allocate tx_skbuff",
+					  __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2680,8 +2712,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 					      GFP_KERNEL);
 
 		if (ugeth->rx_skbuff[j] == NULL) {
-			ugeth_err("%s: Could not allocate rx_skbuff",
-				  __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err("%s: Could not allocate rx_skbuff",
+					  __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2712,9 +2745,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	    qe_muram_alloc(sizeof(struct ucc_geth_tx_global_pram),
 			   UCC_GETH_TX_GLOBAL_PRAM_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->tx_glbl_pram_offset)) {
-		ugeth_err
-		    ("%s: Can not allocate DPRAM memory for p_tx_glbl_pram.",
-		     __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate DPRAM memory for p_tx_glbl_pram.",
+			     __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2734,9 +2768,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   32 * (numThreadsTxNumerical == 1),
 			   UCC_GETH_THREAD_DATA_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->thread_dat_tx_offset)) {
-		ugeth_err
-		    ("%s: Can not allocate DPRAM memory for p_thread_data_tx.",
-		     __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate DPRAM memory for p_thread_data_tx.",
+			     __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2762,9 +2797,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   sizeof(struct ucc_geth_send_queue_qd),
 			   UCC_GETH_SEND_QUEUE_QUEUE_DESCRIPTOR_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->send_q_mem_reg_offset)) {
-		ugeth_err
-		    ("%s: Can not allocate DPRAM memory for p_send_q_mem_reg.",
-		     __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate DPRAM memory for p_send_q_mem_reg.",
+			     __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2805,9 +2841,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		    qe_muram_alloc(sizeof(struct ucc_geth_scheduler),
 				   UCC_GETH_SCHEDULER_ALIGNMENT);
 		if (IS_ERR_VALUE(ugeth->scheduler_offset)) {
-			ugeth_err
-			 ("%s: Can not allocate DPRAM memory for p_scheduler.",
-			     __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err
+				 ("%s: Can not allocate DPRAM memory for p_scheduler.",
+				     __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2853,9 +2890,11 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				   (struct ucc_geth_tx_firmware_statistics_pram),
 				   UCC_GETH_TX_STATISTICS_ALIGNMENT);
 		if (IS_ERR_VALUE(ugeth->tx_fw_statistics_pram_offset)) {
-			ugeth_err
-			    ("%s: Can not allocate DPRAM memory for"
-				" p_tx_fw_statistics_pram.", __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err
+				    ("%s: Can not allocate DPRAM memory for"
+					" p_tx_fw_statistics_pram.",
+				       	__FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2892,9 +2931,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	    qe_muram_alloc(sizeof(struct ucc_geth_rx_global_pram),
 			   UCC_GETH_RX_GLOBAL_PRAM_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->rx_glbl_pram_offset)) {
-		ugeth_err
-		    ("%s: Can not allocate DPRAM memory for p_rx_glbl_pram.",
-		     __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate DPRAM memory for p_rx_glbl_pram.",
+			     __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2913,9 +2953,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   sizeof(struct ucc_geth_thread_data_rx),
 			   UCC_GETH_THREAD_DATA_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->thread_dat_rx_offset)) {
-		ugeth_err
-		    ("%s: Can not allocate DPRAM memory for p_thread_data_rx.",
-		     __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate DPRAM memory for p_thread_data_rx.",
+			     __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2936,9 +2977,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				   (struct ucc_geth_rx_firmware_statistics_pram),
 				   UCC_GETH_RX_STATISTICS_ALIGNMENT);
 		if (IS_ERR_VALUE(ugeth->rx_fw_statistics_pram_offset)) {
-			ugeth_err
-				("%s: Can not allocate DPRAM memory for"
-				" p_rx_fw_statistics_pram.", __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err
+					("%s: Can not allocate DPRAM memory for"
+					" p_rx_fw_statistics_pram.", __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2958,9 +3000,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   sizeof(struct ucc_geth_rx_interrupt_coalescing_entry)
 			   + 4, UCC_GETH_RX_INTERRUPT_COALESCING_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->rx_irq_coalescing_tbl_offset)) {
-		ugeth_err
-		    ("%s: Can not allocate DPRAM memory for"
-			" p_rx_irq_coalescing_tbl.", __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate DPRAM memory for"
+				" p_rx_irq_coalescing_tbl.", __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3026,9 +3069,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			    sizeof(struct ucc_geth_rx_prefetched_bds)),
 			   UCC_GETH_RX_BD_QUEUES_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->rx_bd_qs_tbl_offset)) {
-		ugeth_err
-		    ("%s: Can not allocate DPRAM memory for p_rx_bd_qs_tbl.",
-		     __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate DPRAM memory for p_rx_bd_qs_tbl.",
+			     __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3103,8 +3147,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* initialize extended filtering */
 	if (ug_info->rxExtendedFiltering) {
 		if (!ug_info->extendedFilteringChainPointer) {
-			ugeth_err("%s: Null Extended Filtering Chain Pointer.",
-				  __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err("%s: Null Extended Filtering Chain Pointer.",
+					  __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -EINVAL;
 		}
@@ -3115,9 +3160,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		    qe_muram_alloc(sizeof(struct ucc_geth_exf_global_pram),
 		UCC_GETH_RX_EXTENDED_FILTERING_GLOBAL_PARAMETERS_ALIGNMENT);
 		if (IS_ERR_VALUE(ugeth->exf_glbl_param_offset)) {
-			ugeth_err
-				("%s: Can not allocate DPRAM memory for"
-				" p_exf_glbl_param.", __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err
+					("%s: Can not allocate DPRAM memory for"
+					" p_exf_glbl_param.", __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -3162,9 +3208,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	 */
 	if (!(ugeth->p_init_enet_param_shadow =
 	      kmalloc(sizeof(struct ucc_geth_init_pram), GFP_KERNEL))) {
-		ugeth_err
-		    ("%s: Can not allocate memory for"
-			" p_UccInitEnetParamShadows.", __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate memory for"
+				" p_UccInitEnetParamShadows.", __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3197,8 +3244,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_8_BYTES)
 	    && (ug_info->largestexternallookupkeysize !=
 		QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_16_BYTES)) {
-		ugeth_err("%s: Invalid largest External Lookup Key Size.",
-			  __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Invalid largest External Lookup Key Size.",
+				  __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 	}
@@ -3223,8 +3271,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		/* Rx needs one extra for terminator */
 		, size, UCC_GETH_THREAD_RX_PRAM_ALIGNMENT,
 		ug_info->riscRx, 1)) != 0) {
-			ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
-				__FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+				ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
+					__FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -3238,8 +3287,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				    sizeof(struct ucc_geth_thread_tx_pram),
 				    UCC_GETH_THREAD_TX_PRAM_ALIGNMENT,
 				    ug_info->riscTx, 0)) != 0) {
-		ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
-			  __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
+				  __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -3247,8 +3297,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* Load Rx bds with buffers */
 	for (i = 0; i < ug_info->numQueuesRx; i++) {
 		if ((ret_val = rx_bd_buffer_set(ugeth, (u8) i)) != 0) {
-			ugeth_err("%s: Can not fill Rx bds with buffers.",
-				  __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err("%s: Can not fill Rx bds with buffers.",
+					  __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return ret_val;
 		}
@@ -3257,9 +3308,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* Allocate InitEnet command parameter structure */
 	init_enet_pram_offset = qe_muram_alloc(sizeof(struct ucc_geth_init_pram), 4);
 	if (IS_ERR_VALUE(init_enet_pram_offset)) {
-		ugeth_err
-		    ("%s: Can not allocate DPRAM memory for p_init_enet_pram.",
-		     __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate DPRAM memory for p_init_enet_pram.",
+			     __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3429,8 +3481,9 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 		if (!skb ||
 		    (!(bd_status & (R_F | R_L))) ||
 		    (bd_status & R_ERRORS_FATAL)) {
-			ugeth_vdbg("%s, %d: ERROR!!! skb - 0x%08x",
-				   __FUNCTION__, __LINE__, (u32) skb);
+			if (netif_msg_rx_err(ugeth))
+				ugeth_err("%s, %d: ERROR!!! skb - 0x%08x",
+					   __FUNCTION__, __LINE__, (u32) skb);
 			if (skb)
 				dev_kfree_skb_any(skb);
 
@@ -3459,7 +3512,8 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 
 		skb = get_new_skb(ugeth, bd);
 		if (!skb) {
-			ugeth_warn("%s: No Rx Data Buffer", __FUNCTION__);
+			if (netif_msg_rx_err(ugeth))
+				ugeth_warn("%s: No Rx Data Buffer", __FUNCTION__);
 			ugeth->stats.rx_dropped++;
 			break;
 		}
@@ -3650,28 +3704,32 @@ static int ucc_geth_open(struct net_device *dev)
 
 	/* Test station address */
 	if (dev->dev_addr[0] & ENET_GROUP_ADDR) {
-		ugeth_err("%s: Multicast address used for station address"
-			  " - is this what you wanted?", __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Multicast address used for station address"
+				  " - is this what you wanted?", __FUNCTION__);
 		return -EINVAL;
 	}
 
 	err = ucc_struct_init(ugeth);
 	if (err) {
-		ugeth_err("%s: Cannot configure internal struct, aborting.", dev->name);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Cannot configure internal struct, aborting.", dev->name);
 		return err;
 	}
 
 	err = ucc_geth_startup(ugeth);
 	if (err) {
-		ugeth_err("%s: Cannot configure net device, aborting.",
-			  dev->name);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Cannot configure net device, aborting.",
+				  dev->name);
 		return err;
 	}
 
 	err = adjust_enet_interface(ugeth);
 	if (err) {
-		ugeth_err("%s: Cannot configure net device, aborting.",
-			  dev->name);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Cannot configure net device, aborting.",
+				  dev->name);
 		return err;
 	}
 
@@ -3688,7 +3746,8 @@ static int ucc_geth_open(struct net_device *dev)
 
 	err = init_phy(dev);
 	if (err) {
-		ugeth_err("%s: Cannot initialize PHY, aborting.", dev->name);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Cannot initialize PHY, aborting.", dev->name);
 		return err;
 	}
 
@@ -3698,15 +3757,17 @@ static int ucc_geth_open(struct net_device *dev)
 	    request_irq(ugeth->ug_info->uf_info.irq, ucc_geth_irq_handler, 0,
 			"UCC Geth", dev);
 	if (err) {
-		ugeth_err("%s: Cannot get IRQ for net device, aborting.",
-			  dev->name);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Cannot get IRQ for net device, aborting.",
+				  dev->name);
 		ucc_geth_stop(ugeth);
 		return err;
 	}
 
 	err = ugeth_enable(ugeth, COMM_DIR_RX_AND_TX);
 	if (err) {
-		ugeth_err("%s: Cannot enable net device, aborting.", dev->name);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Cannot enable net device, aborting.", dev->name);
 		ucc_geth_stop(ugeth);
 		return err;
 	}
@@ -3789,6 +3850,13 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		return -ENODEV;
 
 	ug_info = &ugeth_info[ucc_num];
+	if (ug_info == NULL) {
+		if (netif_msg_probe(&debug))
+			ugeth_err("%s: [%d] Missing additional data!",
+				       	__FUNCTION__, ucc_num);
+		return -ENODEV;
+	}
+
 	ug_info->uf_info.ucc_num = ucc_num;
 
 	prop = of_get_property(np, "rx-clock", NULL);
@@ -3867,15 +3935,10 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 
 	ug_info->mdio_bus = res.start;
 
-	printk(KERN_INFO "ucc_geth: UCC%1d at 0x%8x (irq = %d) \n",
-		ug_info->uf_info.ucc_num + 1, ug_info->uf_info.regs,
-		ug_info->uf_info.irq);
-
-	if (ug_info == NULL) {
-		ugeth_err("%s: [%d] Missing additional data!", __FUNCTION__,
-			  ucc_num);
-		return -ENODEV;
-	}
+	if (netif_msg_probe(&debug))
+		printk(KERN_INFO "ucc_geth: UCC%1d at 0x%8x (irq = %d) \n",
+			ug_info->uf_info.ucc_num + 1, ug_info->uf_info.regs,
+			ug_info->uf_info.irq);
 
 	/* Create an ethernet device instance */
 	dev = alloc_etherdev(sizeof(*ugeth));
@@ -3910,14 +3973,15 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	dev->mtu = 1500;
 	dev->set_multicast_list = ucc_geth_set_multi;
 
-	ugeth->msg_enable = (NETIF_MSG_IFUP << 1 ) - 1;
+	ugeth->msg_enable = netif_msg_init(debug.msg_enable, UGETH_MSG_DEFAULT);
 	ugeth->phy_interface = phy_interface;
 	ugeth->max_speed = max_speed;
 
 	err = register_netdev(dev);
 	if (err) {
-		ugeth_err("%s: Cannot register net device, aborting.",
-			  dev->name);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: Cannot register net device, aborting.",
+				  dev->name);
 		free_netdev(dev);
 		return err;
 	}
@@ -3971,7 +4035,8 @@ static int __init ucc_geth_init(void)
 	if (ret)
 		return ret;
 
-	printk(KERN_INFO "ucc_geth: " DRV_DESC "\n");
+	if (netif_msg_drv(&debug))
+		printk(KERN_INFO "ucc_geth: " DRV_DESC "\n");
 	for (i = 0; i < 8; i++)
 		memcpy(&(ugeth_info[i]), &ugeth_primary_info,
 		       sizeof(ugeth_primary_info));
-- 
1.5.2.GIT

