From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next] ucc_geth: separate out rx/tx ring alloc and free operations
Date: Mon, 27 Feb 2012 07:36:29 -0500
Message-ID: <1330346189-25155-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54426 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754013Ab2B0Mgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 07:36:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Factor out the the existing allocation and free operations
so that they can be used individually.

This is to improve code readability, and also to prepare for
possible future changes like better error recovery and more
dynamic configuration (e.g on-the-fly resizing of the rings).

This change represents a straight up relocation of the existing
code into separate routines without changing any of the contained
code itself.  Local variables are relocated as necessary.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[boot tested net-next on mpc8360 once I fixed mpc836x_mds.dts]

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index ec09054..4e3cd2f 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -1856,11 +1856,93 @@ static int ugeth_82xx_filtering_clear_addr_in_paddr(struct ucc_geth_private *uge
 	return hw_clear_addr_in_paddr(ugeth, paddr_num);/* clear in hardware */
 }
 
-static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
+static void ucc_geth_free_rx(struct ucc_geth_private *ugeth)
+{
+	struct ucc_geth_info *ug_info;
+	struct ucc_fast_info *uf_info;
+	u16 i, j;
+	u8 __iomem *bd;
+
+
+	ug_info = ugeth->ug_info;
+	uf_info = &ug_info->uf_info;
+
+	for (i = 0; i < ugeth->ug_info->numQueuesRx; i++) {
+		if (ugeth->p_rx_bd_ring[i]) {
+			/* Return existing data buffers in ring */
+			bd = ugeth->p_rx_bd_ring[i];
+			for (j = 0; j < ugeth->ug_info->bdRingLenRx[i]; j++) {
+				if (ugeth->rx_skbuff[i][j]) {
+					dma_unmap_single(ugeth->dev,
+						in_be32(&((struct qe_bd __iomem *)bd)->buf),
+						ugeth->ug_info->
+						uf_info.max_rx_buf_length +
+						UCC_GETH_RX_DATA_BUF_ALIGNMENT,
+						DMA_FROM_DEVICE);
+					dev_kfree_skb_any(
+						ugeth->rx_skbuff[i][j]);
+					ugeth->rx_skbuff[i][j] = NULL;
+				}
+				bd += sizeof(struct qe_bd);
+			}
+
+			kfree(ugeth->rx_skbuff[i]);
+
+			if (ugeth->ug_info->uf_info.bd_mem_part ==
+			    MEM_PART_SYSTEM)
+				kfree((void *)ugeth->rx_bd_ring_offset[i]);
+			else if (ugeth->ug_info->uf_info.bd_mem_part ==
+				 MEM_PART_MURAM)
+				qe_muram_free(ugeth->rx_bd_ring_offset[i]);
+			ugeth->p_rx_bd_ring[i] = NULL;
+		}
+	}
+
+}
+
+static void ucc_geth_free_tx(struct ucc_geth_private *ugeth)
 {
+	struct ucc_geth_info *ug_info;
+	struct ucc_fast_info *uf_info;
 	u16 i, j;
 	u8 __iomem *bd;
 
+	ug_info = ugeth->ug_info;
+	uf_info = &ug_info->uf_info;
+
+	for (i = 0; i < ugeth->ug_info->numQueuesTx; i++) {
+		bd = ugeth->p_tx_bd_ring[i];
+		if (!bd)
+			continue;
+		for (j = 0; j < ugeth->ug_info->bdRingLenTx[i]; j++) {
+			if (ugeth->tx_skbuff[i][j]) {
+				dma_unmap_single(ugeth->dev,
+						 in_be32(&((struct qe_bd __iomem *)bd)->buf),
+						 (in_be32((u32 __iomem *)bd) &
+						  BD_LENGTH_MASK),
+						 DMA_TO_DEVICE);
+				dev_kfree_skb_any(ugeth->tx_skbuff[i][j]);
+				ugeth->tx_skbuff[i][j] = NULL;
+			}
+		}
+
+		kfree(ugeth->tx_skbuff[i]);
+
+		if (ugeth->p_tx_bd_ring[i]) {
+			if (ugeth->ug_info->uf_info.bd_mem_part ==
+			    MEM_PART_SYSTEM)
+				kfree((void *)ugeth->tx_bd_ring_offset[i]);
+			else if (ugeth->ug_info->uf_info.bd_mem_part ==
+				 MEM_PART_MURAM)
+				qe_muram_free(ugeth->tx_bd_ring_offset[i]);
+			ugeth->p_tx_bd_ring[i] = NULL;
+		}
+	}
+
+}
+
+static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
+{
 	if (!ugeth)
 		return;
 
@@ -1927,64 +2009,8 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 		kfree(ugeth->p_init_enet_param_shadow);
 		ugeth->p_init_enet_param_shadow = NULL;
 	}
-	for (i = 0; i < ugeth->ug_info->numQueuesTx; i++) {
-		bd = ugeth->p_tx_bd_ring[i];
-		if (!bd)
-			continue;
-		for (j = 0; j < ugeth->ug_info->bdRingLenTx[i]; j++) {
-			if (ugeth->tx_skbuff[i][j]) {
-				dma_unmap_single(ugeth->dev,
-						 in_be32(&((struct qe_bd __iomem *)bd)->buf),
-						 (in_be32((u32 __iomem *)bd) &
-						  BD_LENGTH_MASK),
-						 DMA_TO_DEVICE);
-				dev_kfree_skb_any(ugeth->tx_skbuff[i][j]);
-				ugeth->tx_skbuff[i][j] = NULL;
-			}
-		}
-
-		kfree(ugeth->tx_skbuff[i]);
-
-		if (ugeth->p_tx_bd_ring[i]) {
-			if (ugeth->ug_info->uf_info.bd_mem_part ==
-			    MEM_PART_SYSTEM)
-				kfree((void *)ugeth->tx_bd_ring_offset[i]);
-			else if (ugeth->ug_info->uf_info.bd_mem_part ==
-				 MEM_PART_MURAM)
-				qe_muram_free(ugeth->tx_bd_ring_offset[i]);
-			ugeth->p_tx_bd_ring[i] = NULL;
-		}
-	}
-	for (i = 0; i < ugeth->ug_info->numQueuesRx; i++) {
-		if (ugeth->p_rx_bd_ring[i]) {
-			/* Return existing data buffers in ring */
-			bd = ugeth->p_rx_bd_ring[i];
-			for (j = 0; j < ugeth->ug_info->bdRingLenRx[i]; j++) {
-				if (ugeth->rx_skbuff[i][j]) {
-					dma_unmap_single(ugeth->dev,
-						in_be32(&((struct qe_bd __iomem *)bd)->buf),
-						ugeth->ug_info->
-						uf_info.max_rx_buf_length +
-						UCC_GETH_RX_DATA_BUF_ALIGNMENT,
-						DMA_FROM_DEVICE);
-					dev_kfree_skb_any(
-						ugeth->rx_skbuff[i][j]);
-					ugeth->rx_skbuff[i][j] = NULL;
-				}
-				bd += sizeof(struct qe_bd);
-			}
-
-			kfree(ugeth->rx_skbuff[i]);
-
-			if (ugeth->ug_info->uf_info.bd_mem_part ==
-			    MEM_PART_SYSTEM)
-				kfree((void *)ugeth->rx_bd_ring_offset[i]);
-			else if (ugeth->ug_info->uf_info.bd_mem_part ==
-				 MEM_PART_MURAM)
-				qe_muram_free(ugeth->rx_bd_ring_offset[i]);
-			ugeth->p_rx_bd_ring[i] = NULL;
-		}
-	}
+	ucc_geth_free_tx(ugeth);
+	ucc_geth_free_rx(ugeth);
 	while (!list_empty(&ugeth->group_hash_q))
 		put_enet_addr_container(ENET_ADDR_CONT_ENTRY
 					(dequeue(&ugeth->group_hash_q)));
@@ -2210,6 +2236,171 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	return 0;
 }
 
+static int ucc_geth_alloc_tx(struct ucc_geth_private *ugeth)
+{
+	struct ucc_geth_info *ug_info;
+	struct ucc_fast_info *uf_info;
+	int length;
+	u16 i, j;
+	u8 __iomem *bd;
+
+	ug_info = ugeth->ug_info;
+	uf_info = &ug_info->uf_info;
+
+	/* Allocate Tx bds */
+	for (j = 0; j < ug_info->numQueuesTx; j++) {
+		/* Allocate in multiple of
+		   UCC_GETH_TX_BD_RING_SIZE_MEMORY_ALIGNMENT,
+		   according to spec */
+		length = ((ug_info->bdRingLenTx[j] * sizeof(struct qe_bd))
+			  / UCC_GETH_TX_BD_RING_SIZE_MEMORY_ALIGNMENT)
+		    * UCC_GETH_TX_BD_RING_SIZE_MEMORY_ALIGNMENT;
+		if ((ug_info->bdRingLenTx[j] * sizeof(struct qe_bd)) %
+		    UCC_GETH_TX_BD_RING_SIZE_MEMORY_ALIGNMENT)
+			length += UCC_GETH_TX_BD_RING_SIZE_MEMORY_ALIGNMENT;
+		if (uf_info->bd_mem_part == MEM_PART_SYSTEM) {
+			u32 align = 4;
+			if (UCC_GETH_TX_BD_RING_ALIGNMENT > 4)
+				align = UCC_GETH_TX_BD_RING_ALIGNMENT;
+			ugeth->tx_bd_ring_offset[j] =
+				(u32) kmalloc((u32) (length + align), GFP_KERNEL);
+
+			if (ugeth->tx_bd_ring_offset[j] != 0)
+				ugeth->p_tx_bd_ring[j] =
+					(u8 __iomem *)((ugeth->tx_bd_ring_offset[j] +
+					align) & ~(align - 1));
+		} else if (uf_info->bd_mem_part == MEM_PART_MURAM) {
+			ugeth->tx_bd_ring_offset[j] =
+			    qe_muram_alloc(length,
+					   UCC_GETH_TX_BD_RING_ALIGNMENT);
+			if (!IS_ERR_VALUE(ugeth->tx_bd_ring_offset[j]))
+				ugeth->p_tx_bd_ring[j] =
+				    (u8 __iomem *) qe_muram_addr(ugeth->
+							 tx_bd_ring_offset[j]);
+		}
+		if (!ugeth->p_tx_bd_ring[j]) {
+			if (netif_msg_ifup(ugeth))
+				ugeth_err
+				    ("%s: Can not allocate memory for Tx bd rings.",
+				     __func__);
+			return -ENOMEM;
+		}
+		/* Zero unused end of bd ring, according to spec */
+		memset_io((void __iomem *)(ugeth->p_tx_bd_ring[j] +
+		       ug_info->bdRingLenTx[j] * sizeof(struct qe_bd)), 0,
+		       length - ug_info->bdRingLenTx[j] * sizeof(struct qe_bd));
+	}
+
+	/* Init Tx bds */
+	for (j = 0; j < ug_info->numQueuesTx; j++) {
+		/* Setup the skbuff rings */
+		ugeth->tx_skbuff[j] = kmalloc(sizeof(struct sk_buff *) *
+					      ugeth->ug_info->bdRingLenTx[j],
+					      GFP_KERNEL);
+
+		if (ugeth->tx_skbuff[j] == NULL) {
+			if (netif_msg_ifup(ugeth))
+				ugeth_err("%s: Could not allocate tx_skbuff",
+					  __func__);
+			return -ENOMEM;
+		}
+
+		for (i = 0; i < ugeth->ug_info->bdRingLenTx[j]; i++)
+			ugeth->tx_skbuff[j][i] = NULL;
+
+		ugeth->skb_curtx[j] = ugeth->skb_dirtytx[j] = 0;
+		bd = ugeth->confBd[j] = ugeth->txBd[j] = ugeth->p_tx_bd_ring[j];
+		for (i = 0; i < ug_info->bdRingLenTx[j]; i++) {
+			/* clear bd buffer */
+			out_be32(&((struct qe_bd __iomem *)bd)->buf, 0);
+			/* set bd status and length */
+			out_be32((u32 __iomem *)bd, 0);
+			bd += sizeof(struct qe_bd);
+		}
+		bd -= sizeof(struct qe_bd);
+		/* set bd status and length */
+		out_be32((u32 __iomem *)bd, T_W); /* for last BD set Wrap bit */
+	}
+
+	return 0;
+}
+
+static int ucc_geth_alloc_rx(struct ucc_geth_private *ugeth)
+{
+	struct ucc_geth_info *ug_info;
+	struct ucc_fast_info *uf_info;
+	int length;
+	u16 i, j;
+	u8 __iomem *bd;
+
+	ug_info = ugeth->ug_info;
+	uf_info = &ug_info->uf_info;
+
+	/* Allocate Rx bds */
+	for (j = 0; j < ug_info->numQueuesRx; j++) {
+		length = ug_info->bdRingLenRx[j] * sizeof(struct qe_bd);
+		if (uf_info->bd_mem_part == MEM_PART_SYSTEM) {
+			u32 align = 4;
+			if (UCC_GETH_RX_BD_RING_ALIGNMENT > 4)
+				align = UCC_GETH_RX_BD_RING_ALIGNMENT;
+			ugeth->rx_bd_ring_offset[j] =
+				(u32) kmalloc((u32) (length + align), GFP_KERNEL);
+			if (ugeth->rx_bd_ring_offset[j] != 0)
+				ugeth->p_rx_bd_ring[j] =
+					(u8 __iomem *)((ugeth->rx_bd_ring_offset[j] +
+					align) & ~(align - 1));
+		} else if (uf_info->bd_mem_part == MEM_PART_MURAM) {
+			ugeth->rx_bd_ring_offset[j] =
+			    qe_muram_alloc(length,
+					   UCC_GETH_RX_BD_RING_ALIGNMENT);
+			if (!IS_ERR_VALUE(ugeth->rx_bd_ring_offset[j]))
+				ugeth->p_rx_bd_ring[j] =
+				    (u8 __iomem *) qe_muram_addr(ugeth->
+							 rx_bd_ring_offset[j]);
+		}
+		if (!ugeth->p_rx_bd_ring[j]) {
+			if (netif_msg_ifup(ugeth))
+				ugeth_err
+				    ("%s: Can not allocate memory for Rx bd rings.",
+				     __func__);
+			return -ENOMEM;
+		}
+	}
+
+	/* Init Rx bds */
+	for (j = 0; j < ug_info->numQueuesRx; j++) {
+		/* Setup the skbuff rings */
+		ugeth->rx_skbuff[j] = kmalloc(sizeof(struct sk_buff *) *
+					      ugeth->ug_info->bdRingLenRx[j],
+					      GFP_KERNEL);
+
+		if (ugeth->rx_skbuff[j] == NULL) {
+			if (netif_msg_ifup(ugeth))
+				ugeth_err("%s: Could not allocate rx_skbuff",
+					  __func__);
+			return -ENOMEM;
+		}
+
+		for (i = 0; i < ugeth->ug_info->bdRingLenRx[j]; i++)
+			ugeth->rx_skbuff[j][i] = NULL;
+
+		ugeth->skb_currx[j] = 0;
+		bd = ugeth->rxBd[j] = ugeth->p_rx_bd_ring[j];
+		for (i = 0; i < ug_info->bdRingLenRx[j]; i++) {
+			/* set bd status and length */
+			out_be32((u32 __iomem *)bd, R_I);
+			/* clear bd buffer */
+			out_be32(&((struct qe_bd __iomem *)bd)->buf, 0);
+			bd += sizeof(struct qe_bd);
+		}
+		bd -= sizeof(struct qe_bd);
+		/* set bd status and length */
+		out_be32((u32 __iomem *)bd, R_W); /* for last BD set Wrap bit */
+	}
+
+	return 0;
+}
+
 static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 {
 	struct ucc_geth_82xx_address_filtering_pram __iomem *p_82xx_addr_filt;
@@ -2222,11 +2413,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	int ret_val = -EINVAL;
 	u32 remoder = UCC_GETH_REMODER_INIT;
 	u32 init_enet_pram_offset, cecr_subblock, command;
-	u32 ifstat, i, j, size, l2qt, l3qt, length;
+	u32 ifstat, i, j, size, l2qt, l3qt;
 	u16 temoder = UCC_GETH_TEMODER_INIT;
 	u16 test;
 	u8 function_code = 0;
-	u8 __iomem *bd;
 	u8 __iomem *endOfRing;
 	u8 numThreadsRxNumerical, numThreadsTxNumerical;
 
@@ -2366,142 +2556,13 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				UCC_GETH_STATISTICS_GATHERING_MODE_HARDWARE),
 				0, &uf_regs->upsmr, &ug_regs->uescr);
 
-	/* Allocate Tx bds */
-	for (j = 0; j < ug_info->numQueuesTx; j++) {
-		/* Allocate in multiple of
-		   UCC_GETH_TX_BD_RING_SIZE_MEMORY_ALIGNMENT,
-		   according to spec */
-		length = ((ug_info->bdRingLenTx[j] * sizeof(struct qe_bd))
-			  / UCC_GETH_TX_BD_RING_SIZE_MEMORY_ALIGNMENT)
-		    * UCC_GETH_TX_BD_RING_SIZE_MEMORY_ALIGNMENT;
-		if ((ug_info->bdRingLenTx[j] * sizeof(struct qe_bd)) %
-		    UCC_GETH_TX_BD_RING_SIZE_MEMORY_ALIGNMENT)
-			length += UCC_GETH_TX_BD_RING_SIZE_MEMORY_ALIGNMENT;
-		if (uf_info->bd_mem_part == MEM_PART_SYSTEM) {
-			u32 align = 4;
-			if (UCC_GETH_TX_BD_RING_ALIGNMENT > 4)
-				align = UCC_GETH_TX_BD_RING_ALIGNMENT;
-			ugeth->tx_bd_ring_offset[j] =
-				(u32) kmalloc((u32) (length + align), GFP_KERNEL);
-
-			if (ugeth->tx_bd_ring_offset[j] != 0)
-				ugeth->p_tx_bd_ring[j] =
-					(u8 __iomem *)((ugeth->tx_bd_ring_offset[j] +
-					align) & ~(align - 1));
-		} else if (uf_info->bd_mem_part == MEM_PART_MURAM) {
-			ugeth->tx_bd_ring_offset[j] =
-			    qe_muram_alloc(length,
-					   UCC_GETH_TX_BD_RING_ALIGNMENT);
-			if (!IS_ERR_VALUE(ugeth->tx_bd_ring_offset[j]))
-				ugeth->p_tx_bd_ring[j] =
-				    (u8 __iomem *) qe_muram_addr(ugeth->
-							 tx_bd_ring_offset[j]);
-		}
-		if (!ugeth->p_tx_bd_ring[j]) {
-			if (netif_msg_ifup(ugeth))
-				ugeth_err
-				    ("%s: Can not allocate memory for Tx bd rings.",
-				     __func__);
-			return -ENOMEM;
-		}
-		/* Zero unused end of bd ring, according to spec */
-		memset_io((void __iomem *)(ugeth->p_tx_bd_ring[j] +
-		       ug_info->bdRingLenTx[j] * sizeof(struct qe_bd)), 0,
-		       length - ug_info->bdRingLenTx[j] * sizeof(struct qe_bd));
-	}
-
-	/* Allocate Rx bds */
-	for (j = 0; j < ug_info->numQueuesRx; j++) {
-		length = ug_info->bdRingLenRx[j] * sizeof(struct qe_bd);
-		if (uf_info->bd_mem_part == MEM_PART_SYSTEM) {
-			u32 align = 4;
-			if (UCC_GETH_RX_BD_RING_ALIGNMENT > 4)
-				align = UCC_GETH_RX_BD_RING_ALIGNMENT;
-			ugeth->rx_bd_ring_offset[j] =
-				(u32) kmalloc((u32) (length + align), GFP_KERNEL);
-			if (ugeth->rx_bd_ring_offset[j] != 0)
-				ugeth->p_rx_bd_ring[j] =
-					(u8 __iomem *)((ugeth->rx_bd_ring_offset[j] +
-					align) & ~(align - 1));
-		} else if (uf_info->bd_mem_part == MEM_PART_MURAM) {
-			ugeth->rx_bd_ring_offset[j] =
-			    qe_muram_alloc(length,
-					   UCC_GETH_RX_BD_RING_ALIGNMENT);
-			if (!IS_ERR_VALUE(ugeth->rx_bd_ring_offset[j]))
-				ugeth->p_rx_bd_ring[j] =
-				    (u8 __iomem *) qe_muram_addr(ugeth->
-							 rx_bd_ring_offset[j]);
-		}
-		if (!ugeth->p_rx_bd_ring[j]) {
-			if (netif_msg_ifup(ugeth))
-				ugeth_err
-				    ("%s: Can not allocate memory for Rx bd rings.",
-				     __func__);
-			return -ENOMEM;
-		}
-	}
-
-	/* Init Tx bds */
-	for (j = 0; j < ug_info->numQueuesTx; j++) {
-		/* Setup the skbuff rings */
-		ugeth->tx_skbuff[j] = kmalloc(sizeof(struct sk_buff *) *
-					      ugeth->ug_info->bdRingLenTx[j],
-					      GFP_KERNEL);
-
-		if (ugeth->tx_skbuff[j] == NULL) {
-			if (netif_msg_ifup(ugeth))
-				ugeth_err("%s: Could not allocate tx_skbuff",
-					  __func__);
-			return -ENOMEM;
-		}
-
-		for (i = 0; i < ugeth->ug_info->bdRingLenTx[j]; i++)
-			ugeth->tx_skbuff[j][i] = NULL;
-
-		ugeth->skb_curtx[j] = ugeth->skb_dirtytx[j] = 0;
-		bd = ugeth->confBd[j] = ugeth->txBd[j] = ugeth->p_tx_bd_ring[j];
-		for (i = 0; i < ug_info->bdRingLenTx[j]; i++) {
-			/* clear bd buffer */
-			out_be32(&((struct qe_bd __iomem *)bd)->buf, 0);
-			/* set bd status and length */
-			out_be32((u32 __iomem *)bd, 0);
-			bd += sizeof(struct qe_bd);
-		}
-		bd -= sizeof(struct qe_bd);
-		/* set bd status and length */
-		out_be32((u32 __iomem *)bd, T_W); /* for last BD set Wrap bit */
-	}
-
-	/* Init Rx bds */
-	for (j = 0; j < ug_info->numQueuesRx; j++) {
-		/* Setup the skbuff rings */
-		ugeth->rx_skbuff[j] = kmalloc(sizeof(struct sk_buff *) *
-					      ugeth->ug_info->bdRingLenRx[j],
-					      GFP_KERNEL);
-
-		if (ugeth->rx_skbuff[j] == NULL) {
-			if (netif_msg_ifup(ugeth))
-				ugeth_err("%s: Could not allocate rx_skbuff",
-					  __func__);
-			return -ENOMEM;
-		}
-
-		for (i = 0; i < ugeth->ug_info->bdRingLenRx[j]; i++)
-			ugeth->rx_skbuff[j][i] = NULL;
+	ret_val = ucc_geth_alloc_tx(ugeth);
+	if (ret_val != 0)
+		return ret_val;
 
-		ugeth->skb_currx[j] = 0;
-		bd = ugeth->rxBd[j] = ugeth->p_rx_bd_ring[j];
-		for (i = 0; i < ug_info->bdRingLenRx[j]; i++) {
-			/* set bd status and length */
-			out_be32((u32 __iomem *)bd, R_I);
-			/* clear bd buffer */
-			out_be32(&((struct qe_bd __iomem *)bd)->buf, 0);
-			bd += sizeof(struct qe_bd);
-		}
-		bd -= sizeof(struct qe_bd);
-		/* set bd status and length */
-		out_be32((u32 __iomem *)bd, R_W); /* for last BD set Wrap bit */
-	}
+	ret_val = ucc_geth_alloc_rx(ugeth);
+	if (ret_val != 0)
+		return ret_val;
 
 	/*
 	 * Global PRAM
-- 
1.7.9.1
