From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [5.3] ucc_geth: Fix to avoid IS_ERR_VALUE abuses and dead code on 64bit systems.
Date: Fri,  5 Aug 2016 14:10:42 +0530
Message-ID: <1470386442-7208-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: qiang.zhao@freescale.com, scottwood@freescale.com,
	viresh.kumar@linaro.org, akpm@linux-foundation.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux@roeck-us.net, arnd@arndb.de,
	Arvind Yadav <arvind.yadav.cs@gmail.com>
To: zajec5@gmail.com, leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadband.actcorp.in ([106.51.140.156]:13318 "EHLO
	arvind-ThinkPad-Edge-E431" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752014AbcHHOYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 10:24:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IS_ERR_VALUE() assumes that parameter is an unsigned long.
It can not be used to check if 'unsigned int' is passed insted.
Which tends to reflect an error.
In 64bit architectures sizeof (int) == 4 && sizeof (long) == 8.
IS_ERR_VALUE(x) is ((x) >= (unsigned long)-4095).
IS_ERR_VALUE() of 'unsigned int' is always false because the 32bit
value is zero extended to 64 bits.

Now problem in Freescale QEGigabit Ethernet-:
                                 drivers/net/ethernet/freescale/ucc_geth.c

       init_enet_offset =
          qe_muram_alloc(thread_size, thread_alignment);
       if (IS_ERR_VALUE(init_enet_offset)) {
          if (netif_msg_ifup(ugeth))
             pr_err("Can not allocate DPRAM memory\n");
          qe_put_snum((u8) snum);
          return -ENOMEM;
       }
       ugeth->tx_bd_ring_offset[j] =
          qe_muram_alloc(length,
                        UCC_GETH_TX_BD_RING_ALIGNMENT);
       if (!IS_ERR_VALUE(ugeth->tx_bd_ring_offset[j]))
          ugeth->p_tx_bd_ring[j] = (u8 __iomem *) qe_muram_addr(ugeth->
                                    tx_bd_ring_offset[j]);

       ugeth->rx_bd_ring_offset[j] =
          qe_muram_alloc(length,
                         UCC_GETH_RX_BD_RING_ALIGNMENT);
       if (!IS_ERR_VALUE(ugeth->rx_bd_ring_offset[j]))
           ugeth->p_rx_bd_ring[j] =
                               (u8 __iomem *) qe_muram_addr(ugeth->
                                                rx_bd_ring_offset[j]);

       /* Allocate global tx parameter RAM page */
        ugeth->tx_glbl_pram_offset =
            qe_muram_alloc(sizeof(struct ucc_geth_tx_global_pram),
                           UCC_GETH_TX_GLOBAL_PRAM_ALIGNMENT);
        if (IS_ERR_VALUE(ugeth->tx_glbl_pram_offset)) {
           if (netif_msg_ifup(ugeth))
              pr_err("Can not allocate DPRAM memory for p_tx_glbl_pram\n");
           return -ENOMEM;
        }

        /* Size varies with number of Tx threads */
        ugeth->thread_dat_tx_offset =
            qe_muram_alloc(numThreadsTxNumerical *
                           sizeof(struct ucc_geth_thread_data_tx) +
                           32 * (numThreadsTxNumerical == 1),
                           UCC_GETH_THREAD_DATA_ALIGNMENT);
        if (IS_ERR_VALUE(ugeth->thread_dat_tx_offset)) {
           if (netif_msg_ifup(ugeth))
              pr_err
                  ("Can not allocate DPRAM memory for p_thread_data_tx\n");
           return -ENOMEM;
        }

        /* Size varies with number of Tx queues */
        ugeth->send_q_mem_reg_offset =
            qe_muram_alloc(ug_info->numQueuesTx *
                           sizeof(struct ucc_geth_send_queue_qd),
                           UCC_GETH_SEND_QUEUE_QUEUE_DESCRIPTOR_ALIGNMENT);

        if (IS_ERR_VALUE(ugeth->send_q_mem_reg_offset)) {
           if (netif_msg_ifup(ugeth))
            pr_err("Can not allocate DPRAM memory for p_send_q_mem_reg\n");
           return -ENOMEM;
        }

        ugeth->scheduler_offset =
               qe_muram_alloc(sizeof(struct ucc_geth_scheduler),
                                   UCC_GETH_SCHEDULER_ALIGNMENT);
        if (IS_ERR_VALUE(ugeth->scheduler_offset)) {
           if (netif_msg_ifup(ugeth))
              pr_err("Can not allocate DPRAM memory for p_scheduler\n");
           return -ENOMEM;
        }

        ugeth->tx_fw_statistics_pram_offset =
             qe_muram_alloc(sizeof
                           (struct ucc_geth_tx_firmware_statistics_pram),
                            UCC_GETH_TX_STATISTICS_ALIGNMENT);
        if (IS_ERR_VALUE(ugeth->tx_fw_statistics_pram_offset)) {
           if (netif_msg_ifup(ugeth))
           pr_err(
           "Can not allocate DPRAM memory for p_tx_fw_statistics_pram\n");
          return -ENOMEM;
        }
        /* Allocate global rx parameter RAM page */
        ugeth->rx_glbl_pram_offset =
            qe_muram_alloc(sizeof(struct ucc_geth_rx_global_pram),
                           UCC_GETH_RX_GLOBAL_PRAM_ALIGNMENT);
        if (IS_ERR_VALUE(ugeth->rx_glbl_pram_offset)) {
           if (netif_msg_ifup(ugeth))
             pr_err("Can not allocate DPRAM memory for p_rx_glbl_pram\n");
           return -ENOMEM;
        }
       /* Size varies with number of Rx threads */
        ugeth->thread_dat_rx_offset =
            qe_muram_alloc(numThreadsRxNumerical *
                           sizeof(struct ucc_geth_thread_data_rx),
                           UCC_GETH_THREAD_DATA_ALIGNMENT);
        if (IS_ERR_VALUE(ugeth->thread_dat_rx_offset)) {
           if (netif_msg_ifup(ugeth))
            pr_err("Can not allocate DPRAM memory for p_thread_data_rx\n");
           return -ENOMEM;
        }
        ugeth->rx_fw_statistics_pram_offset =
        qe_muram_alloc(sizeof
                          (struct ucc_geth_rx_firmware_statistics_pram),
                           UCC_GETH_RX_STATISTICS_ALIGNMENT);
       if (IS_ERR_VALUE(ugeth->rx_fw_statistics_pram_offset)) {
           if (netif_msg_ifup(ugeth))
            pr_err(
            "Can not allocate DPRAM memory for p_rx_fw_statistics_pram\n");
           return -ENOMEM;
        }
       /* Size varies with number of Rx queues */
        ugeth->rx_irq_coalescing_tbl_offset =
            qe_muram_alloc(ug_info->numQueuesRx *
                   sizeof(struct ucc_geth_rx_interrupt_coalescing_entry)
                   + 4, UCC_GETH_RX_INTERRUPT_COALESCING_ALIGNMENT);
        if (IS_ERR_VALUE(ugeth->rx_irq_coalescing_tbl_offset)) {
           if (netif_msg_ifup(ugeth))
            pr_err(
            "Can not allocate DPRAM memory for p_rx_irq_coalescing_tbl\n");
           return -ENOMEM;
        }
        /* Size varies with number of Rx queues */
        ugeth->rx_bd_qs_tbl_offset =
           qe_muram_alloc(ug_info->numQueuesRx *
                           (sizeof(struct ucc_geth_rx_bd_queues_entry) +
                            sizeof(struct ucc_geth_rx_prefetched_bds)),
                           UCC_GETH_RX_BD_QUEUES_ALIGNMENT);
        if (IS_ERR_VALUE(ugeth->rx_bd_qs_tbl_offset)) {
           if (netif_msg_ifup(ugeth))
            pr_err("Can not allocate DPRAM memory for p_rx_bd_qs_tbl\n");
           return -ENOMEM;
        }
        ugeth->exf_glbl_param_offset =
           qe_muram_alloc(sizeof(struct ucc_geth_exf_global_pram),
             UCC_GETH_RX_EXTENDED_FILTERING_GLOBAL_PARAMETERS_ALIGNMENT);
        if (IS_ERR_VALUE(ugeth->exf_glbl_param_offset)) {
           if (netif_msg_ifup(ugeth))
             pr_err(
                "Can not allocate DPRAM memory for p_exf_glbl_param\n");
           return -ENOMEM;
        }

        /* Allocate InitEnet command parameter structure */
        init_enet_pram_offset =
                  qe_muram_alloc(sizeof(struct ucc_geth_init_pram), 4);
        if (IS_ERR_VALUE(init_enet_pram_offset)) {
          if (netif_msg_ifup(ugeth))
            pr_err(
               "Can not allocate DPRAM memory for p_init_enet_pram\n");
          return -ENOMEM;
        }
        p_init_enet_pram =
         (struct ucc_geth_init_pram __iomem *)
         qe_muram_addr(init_enet_pram_offset);

qe_muram_alloc (a.k.a. cpm_muram_alloc) returns unsigned long.
Return value store in a u32 (init_enet_offset, exf_glbl_param_offset,
rx_glbl_pram_offset, tx_glbl_pram_offset, send_q_mem_reg_offset,
thread_dat_tx_offset, thread_dat_rx_offset, scheduler_offset,
tx_fw_statistics_pram_offset, rx_fw_statistics_pram_offset,
rx_irq_coalescing_tbl_offset, rx_bd_qs_tbl_offset, tx_bd_ring_offset,
init_enet_pram_offset and rx_bd_ring_offset).
If qe_muram_alloc will return any error, Then IS_ERR_VALUE will always
return 0. it'll not call ucc_fast_free for any failure. Inside 'if code'
will be a dead code on 64bit. Even qe_muram_addr will return wrong
virtual address. Which can cause an error.

 kfree((void *)ugeth->tx_bd_ring_offset[i]);

which is not 64-bit safe when tx_bd_ring_offset is a 32-bit value
that also holds the return value of qe_muram_alloc.
This patch is to avoid these problem on 64bit machine.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/freescale/ucc_geth.c |  7 ++++---
 drivers/net/ethernet/freescale/ucc_geth.h | 26 +++++++++++++-------------
 2 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 5bf1ade..eb1f4e2 100644
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
 
@@ -1871,7 +1871,7 @@ static void ucc_geth_free_rx(struct ucc_geth_private *ugeth)
 
 			if (ugeth->ug_info->uf_info.bd_mem_part ==
 			    MEM_PART_SYSTEM)
-				kfree((void *)ugeth->rx_bd_ring_offset[i]);
+				kfree(ugeth->rx_bd_ring_offset[i]);
 			else if (ugeth->ug_info->uf_info.bd_mem_part ==
 				 MEM_PART_MURAM)
 				qe_muram_free(ugeth->rx_bd_ring_offset[i]);
@@ -2367,7 +2367,8 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	struct ucc_geth __iomem *ug_regs;
 	int ret_val = -EINVAL;
 	u32 remoder = UCC_GETH_REMODER_INIT;
-	u32 init_enet_pram_offset, cecr_subblock, command;
+	unsigned long init_enet_pram_offset;
+	u32 cecr_subblock, command;
 	u32 ifstat, i, j, size, l2qt, l3qt;
 	u16 temoder = UCC_GETH_TEMODER_INIT;
 	u16 test;
diff --git a/drivers/net/ethernet/freescale/ucc_geth.h b/drivers/net/ethernet/freescale/ucc_geth.h
index 5da19b4..1639ffd 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.h
+++ b/drivers/net/ethernet/freescale/ucc_geth.h
@@ -1162,31 +1162,31 @@ struct ucc_geth_private {
 	struct ucc_geth __iomem *ug_regs;
 	struct ucc_geth_init_pram *p_init_enet_param_shadow;
 	struct ucc_geth_exf_global_pram __iomem *p_exf_glbl_param;
-	u32 exf_glbl_param_offset;
+	unsigned long exf_glbl_param_offset;
 	struct ucc_geth_rx_global_pram __iomem *p_rx_glbl_pram;
-	u32 rx_glbl_pram_offset;
+	unsigned long rx_glbl_pram_offset;
 	struct ucc_geth_tx_global_pram __iomem *p_tx_glbl_pram;
-	u32 tx_glbl_pram_offset;
+	unsigned long tx_glbl_pram_offset;
 	struct ucc_geth_send_queue_mem_region __iomem *p_send_q_mem_reg;
-	u32 send_q_mem_reg_offset;
+	unsigned long send_q_mem_reg_offset;
 	struct ucc_geth_thread_data_tx __iomem *p_thread_data_tx;
-	u32 thread_dat_tx_offset;
+	unsigned long thread_dat_tx_offset;
 	struct ucc_geth_thread_data_rx __iomem *p_thread_data_rx;
-	u32 thread_dat_rx_offset;
+	unsigned long thread_dat_rx_offset;
 	struct ucc_geth_scheduler __iomem *p_scheduler;
-	u32 scheduler_offset;
+	unsigned long scheduler_offset;
 	struct ucc_geth_tx_firmware_statistics_pram __iomem *p_tx_fw_statistics_pram;
-	u32 tx_fw_statistics_pram_offset;
+	unsigned long tx_fw_statistics_pram_offset;
 	struct ucc_geth_rx_firmware_statistics_pram __iomem *p_rx_fw_statistics_pram;
-	u32 rx_fw_statistics_pram_offset;
+	unsigned long  rx_fw_statistics_pram_offset;
 	struct ucc_geth_rx_interrupt_coalescing_table __iomem *p_rx_irq_coalescing_tbl;
-	u32 rx_irq_coalescing_tbl_offset;
+	unsigned long rx_irq_coalescing_tbl_offset;
 	struct ucc_geth_rx_bd_queues_entry __iomem *p_rx_bd_qs_tbl;
-	u32 rx_bd_qs_tbl_offset;
+	unsigned long rx_bd_qs_tbl_offset;
 	u8 __iomem *p_tx_bd_ring[NUM_TX_QUEUES];
-	u32 tx_bd_ring_offset[NUM_TX_QUEUES];
+	unsigned long tx_bd_ring_offset[NUM_TX_QUEUES];
 	u8 __iomem *p_rx_bd_ring[NUM_RX_QUEUES];
-	u32 rx_bd_ring_offset[NUM_RX_QUEUES];
+	unsigned long rx_bd_ring_offset[NUM_RX_QUEUES];
 	u8 __iomem *confBd[NUM_TX_QUEUES];
 	u8 __iomem *txBd[NUM_TX_QUEUES];
 	u8 __iomem *rxBd[NUM_RX_QUEUES];
-- 
1.9.1
