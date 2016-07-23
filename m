From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [v3] UCC_GETH/UCC_FAST: Use IS_ERR_VALUE_U32 API to avoid IS_ERR_VALUE abuses.
Date: Sat, 23 Jul 2016 23:35:51 +0530
Message-ID: <1469297151-9763-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: qiang.zhao@freescale.com, scottwood@freescale.com,
	viresh.kumar@linaro.org, akpm@linux-foundation.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux@roeck-us.net, arnd@arndb.de,
	Arvind Yadav <arvind.yadav.cs@gmail.com>
To: zajec5@gmail.com, leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 51.19-broadband.acttv.in ([106.51.19.103]:31488 "EHLO
	arvind-ThinkPad-Edge-E431" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751201AbcGWSOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2016 14:14:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IS_ERR_VALUE() assumes that its parameter is an unsigned long.
It can not be used to check if an 'unsigned int' reflects an error.
As they pass an 'unsigned int' into a function that takes an
'unsigned long' argument. This happens to work because the type
is sign-extended on 64-bit architectures before it gets converted
into an unsigned type.

However, anything that passes an 'unsigned short' or 'unsigned int'
argument into IS_ERR_VALUE() is guaranteed to be broken, as are
8-bit integers and types that are wider than 'unsigned long'.

It would be nice to any users that are not passing 'unsigned int'
arguments.

Passing value in IS_ERR_VALUE() is wrong, as they pass an
'unsigned int' into a function that takes an 'unsigned long'
argument.This happens to work because the type is sign-extended
on 64-bit architectures before it gets converted into an
unsigned type.

Passing an 'unsigned short' or 'unsigned int'argument into
IS_ERR_VALUE() is guaranteed to be broken, as are 8-bit integers
and types that are wider than 'unsigned long'.

Any user will get compilation warning for that do not pass an
unsigned long' argument.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/bcma/scan.c                       |  2 --
 drivers/net/ethernet/freescale/ucc_geth.c | 30 +++++++++++++++---------------
 drivers/soc/fsl/qe/ucc_fast.c             |  4 ++--
 include/linux/err.h                       |  1 +
 4 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/drivers/bcma/scan.c b/drivers/bcma/scan.c
index 4a2d1b2..319d78e 100644
--- a/drivers/bcma/scan.c
+++ b/drivers/bcma/scan.c
@@ -272,8 +272,6 @@ static struct bcma_device *bcma_find_core_reverse(struct bcma_bus *bus, u16 core
 	return NULL;
 }
 
-#define IS_ERR_VALUE_U32(x) ((x) >= (u32)-MAX_ERRNO)
-
 static int bcma_get_next_core(struct bcma_bus *bus, u32 __iomem **eromptr,
 			      struct bcma_device_id *match, int core_num,
 			      struct bcma_device *core)
diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 5bf1ade..d290dea 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -289,7 +289,7 @@ static int fill_init_enet_entries(struct ucc_geth_private *ugeth,
 		else {
 			init_enet_offset =
 			    qe_muram_alloc(thread_size, thread_alignment);
-			if (IS_ERR_VALUE(init_enet_offset)) {
+			if (IS_ERR_VALUE_U32(init_enet_offset)) {
 				if (netif_msg_ifup(ugeth))
 					pr_err("Can not allocate DPRAM memory\n");
 				qe_put_snum((u8) snum);
@@ -2234,7 +2234,7 @@ static int ucc_geth_alloc_tx(struct ucc_geth_private *ugeth)
 			ugeth->tx_bd_ring_offset[j] =
 			    qe_muram_alloc(length,
 					   UCC_GETH_TX_BD_RING_ALIGNMENT);
-			if (!IS_ERR_VALUE(ugeth->tx_bd_ring_offset[j]))
+			if (!IS_ERR_VALUE_U32(ugeth->tx_bd_ring_offset[j]))
 				ugeth->p_tx_bd_ring[j] =
 				    (u8 __iomem *) qe_muram_addr(ugeth->
 							 tx_bd_ring_offset[j]);
@@ -2311,7 +2311,7 @@ static int ucc_geth_alloc_rx(struct ucc_geth_private *ugeth)
 			ugeth->rx_bd_ring_offset[j] =
 			    qe_muram_alloc(length,
 					   UCC_GETH_RX_BD_RING_ALIGNMENT);
-			if (!IS_ERR_VALUE(ugeth->rx_bd_ring_offset[j]))
+			if (!IS_ERR_VALUE_U32(ugeth->rx_bd_ring_offset[j]))
 				ugeth->p_rx_bd_ring[j] =
 				    (u8 __iomem *) qe_muram_addr(ugeth->
 							 rx_bd_ring_offset[j]);
@@ -2521,7 +2521,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	ugeth->tx_glbl_pram_offset =
 	    qe_muram_alloc(sizeof(struct ucc_geth_tx_global_pram),
 			   UCC_GETH_TX_GLOBAL_PRAM_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->tx_glbl_pram_offset)) {
+	if (IS_ERR_VALUE_U32(ugeth->tx_glbl_pram_offset)) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_tx_glbl_pram\n");
 		return -ENOMEM;
@@ -2541,7 +2541,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   sizeof(struct ucc_geth_thread_data_tx) +
 			   32 * (numThreadsTxNumerical == 1),
 			   UCC_GETH_THREAD_DATA_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->thread_dat_tx_offset)) {
+	if (IS_ERR_VALUE_U32(ugeth->thread_dat_tx_offset)) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_thread_data_tx\n");
 		return -ENOMEM;
@@ -2568,7 +2568,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	    qe_muram_alloc(ug_info->numQueuesTx *
 			   sizeof(struct ucc_geth_send_queue_qd),
 			   UCC_GETH_SEND_QUEUE_QUEUE_DESCRIPTOR_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->send_q_mem_reg_offset)) {
+	if (IS_ERR_VALUE_U32(ugeth->send_q_mem_reg_offset)) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_send_q_mem_reg\n");
 		return -ENOMEM;
@@ -2609,7 +2609,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		ugeth->scheduler_offset =
 		    qe_muram_alloc(sizeof(struct ucc_geth_scheduler),
 				   UCC_GETH_SCHEDULER_ALIGNMENT);
-		if (IS_ERR_VALUE(ugeth->scheduler_offset)) {
+		if (IS_ERR_VALUE_U32(ugeth->scheduler_offset)) {
 			if (netif_msg_ifup(ugeth))
 				pr_err("Can not allocate DPRAM memory for p_scheduler\n");
 			return -ENOMEM;
@@ -2656,7 +2656,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		    qe_muram_alloc(sizeof
 				   (struct ucc_geth_tx_firmware_statistics_pram),
 				   UCC_GETH_TX_STATISTICS_ALIGNMENT);
-		if (IS_ERR_VALUE(ugeth->tx_fw_statistics_pram_offset)) {
+		if (IS_ERR_VALUE_U32(ugeth->tx_fw_statistics_pram_offset)) {
 			if (netif_msg_ifup(ugeth))
 				pr_err("Can not allocate DPRAM memory for p_tx_fw_statistics_pram\n");
 			return -ENOMEM;
@@ -2693,7 +2693,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	ugeth->rx_glbl_pram_offset =
 	    qe_muram_alloc(sizeof(struct ucc_geth_rx_global_pram),
 			   UCC_GETH_RX_GLOBAL_PRAM_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->rx_glbl_pram_offset)) {
+	if (IS_ERR_VALUE_U32(ugeth->rx_glbl_pram_offset)) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_rx_glbl_pram\n");
 		return -ENOMEM;
@@ -2712,7 +2712,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	    qe_muram_alloc(numThreadsRxNumerical *
 			   sizeof(struct ucc_geth_thread_data_rx),
 			   UCC_GETH_THREAD_DATA_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->thread_dat_rx_offset)) {
+	if (IS_ERR_VALUE_U32(ugeth->thread_dat_rx_offset)) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_thread_data_rx\n");
 		return -ENOMEM;
@@ -2733,7 +2733,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		    qe_muram_alloc(sizeof
 				   (struct ucc_geth_rx_firmware_statistics_pram),
 				   UCC_GETH_RX_STATISTICS_ALIGNMENT);
-		if (IS_ERR_VALUE(ugeth->rx_fw_statistics_pram_offset)) {
+		if (IS_ERR_VALUE_U32(ugeth->rx_fw_statistics_pram_offset)) {
 			if (netif_msg_ifup(ugeth))
 				pr_err("Can not allocate DPRAM memory for p_rx_fw_statistics_pram\n");
 			return -ENOMEM;
@@ -2753,7 +2753,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	    qe_muram_alloc(ug_info->numQueuesRx *
 			   sizeof(struct ucc_geth_rx_interrupt_coalescing_entry)
 			   + 4, UCC_GETH_RX_INTERRUPT_COALESCING_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->rx_irq_coalescing_tbl_offset)) {
+	if (IS_ERR_VALUE_U32(ugeth->rx_irq_coalescing_tbl_offset)) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_rx_irq_coalescing_tbl\n");
 		return -ENOMEM;
@@ -2819,7 +2819,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   (sizeof(struct ucc_geth_rx_bd_queues_entry) +
 			    sizeof(struct ucc_geth_rx_prefetched_bds)),
 			   UCC_GETH_RX_BD_QUEUES_ALIGNMENT);
-	if (IS_ERR_VALUE(ugeth->rx_bd_qs_tbl_offset)) {
+	if (IS_ERR_VALUE_U32(ugeth->rx_bd_qs_tbl_offset)) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_rx_bd_qs_tbl\n");
 		return -ENOMEM;
@@ -2905,7 +2905,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		ugeth->exf_glbl_param_offset =
 		    qe_muram_alloc(sizeof(struct ucc_geth_exf_global_pram),
 		UCC_GETH_RX_EXTENDED_FILTERING_GLOBAL_PARAMETERS_ALIGNMENT);
-		if (IS_ERR_VALUE(ugeth->exf_glbl_param_offset)) {
+		if (IS_ERR_VALUE_U32(ugeth->exf_glbl_param_offset)) {
 			if (netif_msg_ifup(ugeth))
 				pr_err("Can not allocate DPRAM memory for p_exf_glbl_param\n");
 			return -ENOMEM;
@@ -3039,7 +3039,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 
 	/* Allocate InitEnet command parameter structure */
 	init_enet_pram_offset = qe_muram_alloc(sizeof(struct ucc_geth_init_pram), 4);
-	if (IS_ERR_VALUE(init_enet_pram_offset)) {
+	if (IS_ERR_VALUE_U32(init_enet_pram_offset)) {
 		if (netif_msg_ifup(ugeth))
 			pr_err("Can not allocate DPRAM memory for p_init_enet_pram\n");
 		return -ENOMEM;
diff --git a/drivers/soc/fsl/qe/ucc_fast.c b/drivers/soc/fsl/qe/ucc_fast.c
index a768931..f7fa59f 100644
--- a/drivers/soc/fsl/qe/ucc_fast.c
+++ b/drivers/soc/fsl/qe/ucc_fast.c
@@ -268,7 +268,7 @@ int ucc_fast_init(struct ucc_fast_info * uf_info, struct ucc_fast_private ** ucc
 	/* Allocate memory for Tx Virtual Fifo */
 	uccf->ucc_fast_tx_virtual_fifo_base_offset =
 	    qe_muram_alloc(uf_info->utfs, UCC_FAST_VIRT_FIFO_REGS_ALIGNMENT);
-	if (IS_ERR_VALUE(uccf->ucc_fast_tx_virtual_fifo_base_offset)) {
+	if (IS_ERR_VALUE_U32(uccf->ucc_fast_tx_virtual_fifo_base_offset)) {
 		printk(KERN_ERR "%s: cannot allocate MURAM for TX FIFO\n",
 			__func__);
 		uccf->ucc_fast_tx_virtual_fifo_base_offset = 0;
@@ -281,7 +281,7 @@ int ucc_fast_init(struct ucc_fast_info * uf_info, struct ucc_fast_private ** ucc
 		qe_muram_alloc(uf_info->urfs +
 			   UCC_FAST_RECEIVE_VIRTUAL_FIFO_SIZE_FUDGE_FACTOR,
 			   UCC_FAST_VIRT_FIFO_REGS_ALIGNMENT);
-	if (IS_ERR_VALUE(uccf->ucc_fast_rx_virtual_fifo_base_offset)) {
+	if (IS_ERR_VALUE_U32(uccf->ucc_fast_rx_virtual_fifo_base_offset)) {
 		printk(KERN_ERR "%s: cannot allocate MURAM for RX FIFO\n",
 			__func__);
 		uccf->ucc_fast_rx_virtual_fifo_base_offset = 0;
diff --git a/include/linux/err.h b/include/linux/err.h
index 1e35588..a42f942 100644
--- a/include/linux/err.h
+++ b/include/linux/err.h
@@ -19,6 +19,7 @@
 #ifndef __ASSEMBLY__
 
 #define IS_ERR_VALUE(x) unlikely((unsigned long)(void *)(x) >= (unsigned long)-MAX_ERRNO)
+#define IS_ERR_VALUE_U32(x) unlikely((unsigned int)(x) >= (unsigned int)-MAX_ERRNO)
 
 static inline void * __must_check ERR_PTR(long error)
 {
-- 
1.9.1
