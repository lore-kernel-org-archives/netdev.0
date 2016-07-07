From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] Need proper type casting before assignment, Remove compilation Warning.
Date: Fri,  8 Jul 2016 00:07:54 +0530
Message-ID: <1467916674-8418-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org,
	Arvind Yadav <arvind.yadav.cs@gmail.com>
To: leoli@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-Return type of 'qe_muram_alloc' is 'unsigned long', That Was trying to
assigned in ucc_fast_tx_virtual_fifo_base_offset and
ucc_fast_rx_virtual_fifo_base_offset. These variable are 'unsigned int'.
So before assginment need a proper type casting.

-Passing value in IS_ERR_VALUE() is wrong, as they pass an 'int'
into a function that takes an 'unsigned long' argument.This happens
to work because the type is sign-extended on 64-bit architectures
before it gets converted into an unsigned type.

-Passing an 'unsigned short' or 'unsigned int'argument into
IS_ERR_VALUE() is guaranteed to be broken, as are 8-bit integers
and types that are wider than 'unsigned long'.

-Any user will get compilation warning for that do not pass an
unsigned long' argument.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/freescale/ucc_geth.c | 71 +++++++++++++++++--------------
 1 file changed, 38 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 5bf1ade..a5086b2 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -273,7 +273,7 @@ static int fill_init_enet_entries(struct ucc_geth_private *ugeth,
 				  unsigned int risc,
 				  int skip_page_for_first_entry)
 {
-	u32 init_enet_offset;
+	unsigned long init_enet_offset;
 	u8 i;
 	int snum;
 
@@ -297,8 +297,8 @@ static int fill_init_enet_entries(struct ucc_geth_private *ugeth,
 			}
 		}
 		*(p_start++) =
-		    ((u8) snum << ENET_INIT_PARAM_SNUM_SHIFT) | init_enet_offset
-		    | risc;
+			((u8)snum << ENET_INIT_PARAM_SNUM_SHIFT)
+			| (u32)init_enet_offset | risc;
 	}
 
 	return 0;
@@ -2232,9 +2232,10 @@ static int ucc_geth_alloc_tx(struct ucc_geth_private *ugeth)
 					align) & ~(align - 1));
 		} else if (uf_info->bd_mem_part == MEM_PART_MURAM) {
 			ugeth->tx_bd_ring_offset[j] =
-			    qe_muram_alloc(length,
+			    (u32)qe_muram_alloc(length,
 					   UCC_GETH_TX_BD_RING_ALIGNMENT);
-			if (!IS_ERR_VALUE(ugeth->tx_bd_ring_offset[j]))
+			if (!IS_ERR_VALUE(
+				(unsigned long)ugeth->tx_bd_ring_offset[j]))
 				ugeth->p_tx_bd_ring[j] =
 				    (u8 __iomem *) qe_muram_addr(ugeth->
 							 tx_bd_ring_offset[j]);
@@ -2309,9 +2310,10 @@ static int ucc_geth_alloc_rx(struct ucc_geth_private *ugeth)
 					align) & ~(align - 1));
 		} else if (uf_info->bd_mem_part == MEM_PART_MURAM) {
 			ugeth->rx_bd_ring_offset[j] =
-			    qe_muram_alloc(length,
+			    (u32)qe_muram_alloc(length,
 					   UCC_GETH_RX_BD_RING_ALIGNMENT);
-			if (!IS_ERR_VALUE(ugeth->rx_bd_ring_offset[j]))
+			if (!IS_ERR_VALUE(
+				(unsigned long)ugeth->rx_bd_ring_offset[j]))
 				ugeth->p_rx_bd_ring[j] =
 				    (u8 __iomem *) qe_muram_addr(ugeth->
 							 rx_bd_ring_offset[j]);
@@ -2367,7 +2369,8 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	struct ucc_geth __iomem *ug_regs;
 	int ret_val = -EINVAL;
 	u32 remoder = UCC_GETH_REMODER_INIT;
-	u32 init_enet_pram_offset, cecr_subblock, command;
+	u32 cecr_subblock, command;
+	unsigned long init_enet_pram_offset;
 	u32 ifstat, i, j, size, l2qt, l3qt;
 	u16 temoder = UCC_GETH_TEMODER_INIT;
 	u16 test;
@@ -2519,9 +2522,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* Tx global PRAM */
 	/* Allocate global tx parameter RAM page */
 	ugeth->tx_glbl_pram_offset =
-	    qe_muram_alloc(sizeof(struct ucc_geth_tx_global_pram),
+	    (u32)qe_muram_alloc(sizeof(struct ucc_geth_tx_global_pram),
 			   UCC_GETH_TX_GLOBAL_PRAM_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->tx_glbl_pram_offset)) {
+	if (IS_ERR_VALUE((unsigned long)ugeth->tx_glbl_pram_offset)) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_tx_glbl_pram\n");
 		return -ENOMEM;
@@ -2537,11 +2540,11 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* TQPTR */
 	/* Size varies with number of Tx threads */
 	ugeth->thread_dat_tx_offset =
-	    qe_muram_alloc(numThreadsTxNumerical *
+	   (u32)qe_muram_alloc(numThreadsTxNumerical *
 			   sizeof(struct ucc_geth_thread_data_tx) +
 			   32 * (numThreadsTxNumerical == 1),
 			   UCC_GETH_THREAD_DATA_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->thread_dat_tx_offset)) {
+	if (IS_ERR_VALUE((unsigned long)ugeth->thread_dat_tx_offset)) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_thread_data_tx\n");
 		return -ENOMEM;
@@ -2565,10 +2568,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* SQPTR */
 	/* Size varies with number of Tx queues */
 	ugeth->send_q_mem_reg_offset =
-	    qe_muram_alloc(ug_info->numQueuesTx *
-			   sizeof(struct ucc_geth_send_queue_qd),
+	    (u32)qe_muram_alloc(ug_info->numQueuesTx
+			   * sizeof(struct ucc_geth_send_queue_qd),
 			   UCC_GETH_SEND_QUEUE_QUEUE_DESCRIPTOR_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->send_q_mem_reg_offset)) {
+	if (IS_ERR_VALUE((unsigned long)ugeth->send_q_mem_reg_offset)) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_send_q_mem_reg\n");
 		return -ENOMEM;
@@ -2607,9 +2610,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	if (ug_info->numQueuesTx > 1) {
 	/* scheduler exists only if more than 1 tx queue */
 		ugeth->scheduler_offset =
-		    qe_muram_alloc(sizeof(struct ucc_geth_scheduler),
+		    (u32)qe_muram_alloc(sizeof(struct ucc_geth_scheduler),
 				   UCC_GETH_SCHEDULER_ALIGNMENT);
-		if (IS_ERR_VALUE(ugeth->scheduler_offset)) {
+		if (IS_ERR_VALUE((unsigned long)ugeth->scheduler_offset)) {
 			if (netif_msg_ifup(ugeth))
 				pr_err("Can not allocate DPRAM memory for p_scheduler\n");
 			return -ENOMEM;
@@ -2653,10 +2656,11 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	if (ug_info->
 	    statisticsMode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_TX) {
 		ugeth->tx_fw_statistics_pram_offset =
-		    qe_muram_alloc(sizeof
+		    (u32)qe_muram_alloc(sizeof
 				   (struct ucc_geth_tx_firmware_statistics_pram),
 				   UCC_GETH_TX_STATISTICS_ALIGNMENT);
-		if (IS_ERR_VALUE(ugeth->tx_fw_statistics_pram_offset)) {
+		if (IS_ERR_VALUE(
+			(unsigned long)ugeth->tx_fw_statistics_pram_offset)) {
 			if (netif_msg_ifup(ugeth))
 				pr_err("Can not allocate DPRAM memory for p_tx_fw_statistics_pram\n");
 			return -ENOMEM;
@@ -2691,9 +2695,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* Rx global PRAM */
 	/* Allocate global rx parameter RAM page */
 	ugeth->rx_glbl_pram_offset =
-	    qe_muram_alloc(sizeof(struct ucc_geth_rx_global_pram),
+	    (u32)qe_muram_alloc(sizeof(struct ucc_geth_rx_global_pram),
 			   UCC_GETH_RX_GLOBAL_PRAM_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->rx_glbl_pram_offset)) {
+	if (IS_ERR_VALUE((unsigned long)ugeth->rx_glbl_pram_offset)) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_rx_glbl_pram\n");
 		return -ENOMEM;
@@ -2709,10 +2713,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* RQPTR */
 	/* Size varies with number of Rx threads */
 	ugeth->thread_dat_rx_offset =
-	    qe_muram_alloc(numThreadsRxNumerical *
+	    (u32)qe_muram_alloc(numThreadsRxNumerical *
 			   sizeof(struct ucc_geth_thread_data_rx),
 			   UCC_GETH_THREAD_DATA_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->thread_dat_rx_offset)) {
+	if (IS_ERR_VALUE((unsigned long)ugeth->thread_dat_rx_offset)) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_thread_data_rx\n");
 		return -ENOMEM;
@@ -2730,10 +2734,11 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	if (ug_info->
 	    statisticsMode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX) {
 		ugeth->rx_fw_statistics_pram_offset =
-		    qe_muram_alloc(sizeof
+		    (u32)qe_muram_alloc(sizeof
 				   (struct ucc_geth_rx_firmware_statistics_pram),
 				   UCC_GETH_RX_STATISTICS_ALIGNMENT);
-		if (IS_ERR_VALUE(ugeth->rx_fw_statistics_pram_offset)) {
+		if (IS_ERR_VALUE(
+			(unsigned long)ugeth->rx_fw_statistics_pram_offset)) {
 			if (netif_msg_ifup(ugeth))
 				pr_err("Can not allocate DPRAM memory for p_rx_fw_statistics_pram\n");
 			return -ENOMEM;
@@ -2750,10 +2755,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 
 	/* Size varies with number of Rx queues */
 	ugeth->rx_irq_coalescing_tbl_offset =
-	    qe_muram_alloc(ug_info->numQueuesRx *
-			   sizeof(struct ucc_geth_rx_interrupt_coalescing_entry)
-			   + 4, UCC_GETH_RX_INTERRUPT_COALESCING_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->rx_irq_coalescing_tbl_offset)) {
+	    (u32)qe_muram_alloc(ug_info->numQueuesRx
+			* sizeof(struct ucc_geth_rx_interrupt_coalescing_entry)
+			* + 4, UCC_GETH_RX_INTERRUPT_COALESCING_ALIGNMENT);
+	if (IS_ERR_VALUE((unsigned long)ugeth->rx_irq_coalescing_tbl_offset)) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_rx_irq_coalescing_tbl\n");
 		return -ENOMEM;
@@ -2815,11 +2820,11 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* RBDQPTR */
 	/* Size varies with number of Rx queues */
 	ugeth->rx_bd_qs_tbl_offset =
-	    qe_muram_alloc(ug_info->numQueuesRx *
+	    (u32)qe_muram_alloc(ug_info->numQueuesRx *
 			   (sizeof(struct ucc_geth_rx_bd_queues_entry) +
 			    sizeof(struct ucc_geth_rx_prefetched_bds)),
 			   UCC_GETH_RX_BD_QUEUES_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->rx_bd_qs_tbl_offset)) {
+	if (IS_ERR_VALUE((unsigned long)ugeth->rx_bd_qs_tbl_offset)) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_rx_bd_qs_tbl\n");
 		return -ENOMEM;
@@ -2903,9 +2908,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		/* Allocate memory for extended filtering Mode Global
 		Parameters */
 		ugeth->exf_glbl_param_offset =
-		    qe_muram_alloc(sizeof(struct ucc_geth_exf_global_pram),
+		    (u32)qe_muram_alloc(sizeof(struct ucc_geth_exf_global_pram),
 		UCC_GETH_RX_EXTENDED_FILTERING_GLOBAL_PARAMETERS_ALIGNMENT);
-		if (IS_ERR_VALUE(ugeth->exf_glbl_param_offset)) {
+		if (IS_ERR_VALUE((unsigned long)ugeth->exf_glbl_param_offset)) {
 			if (netif_msg_ifup(ugeth))
 				pr_err("Can not allocate DPRAM memory for p_exf_glbl_param\n");
 			return -ENOMEM;
-- 
1.9.1
