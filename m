From: raghavendra.koushik@s2io.com
Subject: [PATCH 2.6.9-rc2 11/12] S2io: modified loadable parameters
Date: Mon,  8 Nov 2004 08:17:46 -0800 (PST)
Message-ID: <20041108161746.A84A53291E@linux.site>
Cc: ravinandan.arakali@s2io.com, raghavendra.koushik@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, romieu@fr.zoreil.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Attached is the patch to implement module loadable parameters as per new API.
Following is the list of changes.
1. Used new module_param() API.
2. List of variables for tx_fifo_len and rx_ring_sz replaced with array.
3. Some of the module parameters which can be set thru setpci command have
   been removed, such as latency_timer, max_read_byte_cnt, max_split_transactions. 
4. Other parameters which were felt to be not required, such as rx_prio, 
   tx_prio have been removed.
5. Interrupt moderation parameters(such as tx_urange_*) are no longer module
   loadable parameters since they can be configured thru' a separate patch
   available to customers.
6. Changed default max_read_byte_count to 1024.
7. If scatter-gather is enabled, checksum is enabled too.
8. Not verifying if module loadable parameters are within valid range
   (verify_load_param() removed).

Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>
Signed-off-by: Ravinandan Arakali <ravinandan.arakali@s2io.com>
---
diff -urN vanilla-linux/drivers/net/s2io.c linux-2.6.8.1/drivers/net/s2io.c
--- vanilla-linux/drivers/net/s2io.c	2004-10-26 16:43:26.315476048 -0700
+++ linux-2.6.8.1/drivers/net/s2io.c	2004-10-26 16:43:19.561502808 -0700
@@ -26,17 +26,13 @@
  *			  	
  * The module loadable parameters that are supported by the driver and a brief
  * explaination of all the variables.
- * ring_num : This can be used to program the number of receive rings used 
+ * rx_ring_num : This can be used to program the number of receive rings used 
  * in the driver.  					
- * frame_len: This is an array of size 8. Using this we can set the maximum 
- * size of the received frame that can be steered into the corrsponding 
- * receive ring.
- * ring_len: This defines the number of descriptors each ring can have. This 
+ * rx_ring_len: This defines the number of descriptors each ring can have. This 
  * is also an array of size 8.
- * fifo_num: This defines the number of Tx FIFOs thats used int the driver.
- * fifo_len: This too is an array of 8. Each element defines the number of 
+ * tx_fifo_num: This defines the number of Tx FIFOs thats used int the driver.
+ * tx_fifo_len: This too is an array of 8. Each element defines the number of 
  * Tx descriptors that can be associated with each corresponding FIFO.
- * latency_timer: This input is programmed into the Latency timer register
  * in PCI Configuration space.
  ************************************************************************/
 
@@ -222,66 +218,22 @@
 };
 
 /* Module Loadable parameters. */
-static u32 frame_len[MAX_RX_RINGS];
-static u32 rx_prio;
-static u32 tx_prio;
-
-static unsigned int lso_enable = 1;
-#ifndef CONFIG_S2IO_NAPI
-static unsigned int indicate_max_pkts;
-#endif
-static unsigned int cksum_offload_enable = 1;
 static unsigned int tx_fifo_num = 1;
-static unsigned int tx_fifo_len_0 = DEFAULT_FIFO_LEN;
-static unsigned int tx_fifo_len_1;
-static unsigned int tx_fifo_len_2;
-static unsigned int tx_fifo_len_3;
-static unsigned int tx_fifo_len_4;
-static unsigned int tx_fifo_len_5;
-static unsigned int tx_fifo_len_6;
-static unsigned int tx_fifo_len_7;
-static unsigned int max_txds = MAX_SKB_FRAGS;
+static unsigned int tx_fifo_len[MAX_TX_FIFOS] =
+    {[0 ...(MAX_TX_FIFOS - 1)] = 0 };
 static unsigned int rx_ring_num = 1;
-static unsigned int rx_ring_sz_0 = SMALL_BLK_CNT;
-static unsigned int rx_ring_sz_1;
-static unsigned int rx_ring_sz_2;
-static unsigned int rx_ring_sz_3;
-static unsigned int rx_ring_sz_4;
-static unsigned int rx_ring_sz_5;
-static unsigned int rx_ring_sz_6;
-static unsigned int rx_ring_sz_7;
+static unsigned int rx_ring_sz[MAX_RX_RINGS] =
+    {[0 ...(MAX_RX_RINGS - 1)] = 0 };
 static unsigned int Stats_refresh_time = 4;
 static unsigned int rmac_pause_time = 65535;
 static unsigned int mc_pause_threshold_q0q3 = 187;
 static unsigned int mc_pause_threshold_q4q7 = 187;
 static unsigned int shared_splits;
-#if defined(__ia64__)
-static unsigned int max_splits_trans = XENA_THREE_SPLIT_TRANSACTION;
-#else
-static unsigned int max_splits_trans = XENA_TWO_SPLIT_TRANSACTION;
-#endif
 static unsigned int tmac_util_period = 5;
 static unsigned int rmac_util_period = 5;
-static unsigned int tx_timer_val = 0xFFF;
-static unsigned int tx_utilz_periodic = 1;
-static unsigned int rx_timer_val = 0xFFF;
-static unsigned int rx_utilz_periodic = 1;
-static unsigned int tx_urange_a = 0xA;
-static unsigned int tx_ufc_a = 0x10;
-static unsigned int tx_urange_b = 0x10;
-static unsigned int tx_ufc_b = 0x20;
-static unsigned int tx_urange_c = 0x30;
-static unsigned int tx_ufc_c = 0x40;
-static unsigned int tx_ufc_d = 0x80;
-static unsigned int rx_urange_a = 0xA;
-static unsigned int rx_ufc_a = 0x1;
-static unsigned int rx_urange_b = 0x10;
-static unsigned int rx_ufc_b = 0x2;
-static unsigned int rx_urange_c = 0x30;
-static unsigned int rx_ufc_c = 0x40;
-static unsigned int rx_ufc_d = 0x80;
-static u8 latency_timer = 0xf8;
-static u8 max_read_byte_cnt = 2;
+#ifndef CONFIG_S2IO_NAPI
+static unsigned int indicate_max_pkts;
+#endif
 
 /* 
  * S2IO device table.
@@ -923,17 +875,8 @@
 	 * Disable Rx steering. Hard coding all packets be steered to
 	 * Queue 0 for now. 
 	 */
-	if (rx_prio) {
-		u64 def = 0x8000000000000000ULL, tmp;
-		for (i = 0; i < MAX_RX_RINGS; i++) {
-			tmp = (u64) (def >> (i % config->rx_ring_num));
-			val64 |= (u64) (tmp >> (i * 8));
-		}
-		writeq(val64, &bar0->rts_qos_steering);
-	} else {
-		val64 = 0x8080808080808080ULL;
-		writeq(val64, &bar0->rts_qos_steering);
-	}
+	val64 = 0x8080808080808080ULL;
+	writeq(val64, &bar0->rts_qos_steering);
 
 	/* UDP Fix */
 	val64 = 0;
@@ -964,18 +907,15 @@
 	 * Scheme.
 	 */
 	/* TTI Initialization */
-	val64 = TTI_DATA1_MEM_TX_TIMER_VAL(tx_timer_val) |
-	    TTI_DATA1_MEM_TX_URNG_A(tx_urange_a) |
-	    TTI_DATA1_MEM_TX_URNG_B(tx_urange_b) |
-	    TTI_DATA1_MEM_TX_URNG_C(tx_urange_c);
-	if (tx_utilz_periodic)
-		val64 |= TTI_DATA1_MEM_TX_TIMER_AC_EN;
+	val64 = TTI_DATA1_MEM_TX_TIMER_VAL(0xFFF) |
+	    TTI_DATA1_MEM_TX_URNG_A(0xA) |
+	    TTI_DATA1_MEM_TX_URNG_B(0x10) |
+	    TTI_DATA1_MEM_TX_URNG_C(0x30) | TTI_DATA1_MEM_TX_TIMER_AC_EN;
 	writeq(val64, &bar0->tti_data1_mem);
 
-	val64 = TTI_DATA2_MEM_TX_UFC_A(tx_ufc_a) |
-	    TTI_DATA2_MEM_TX_UFC_B(tx_ufc_b) |
-	    TTI_DATA2_MEM_TX_UFC_C(tx_ufc_c) |
-	    TTI_DATA2_MEM_TX_UFC_D(tx_ufc_d);
+	val64 = TTI_DATA2_MEM_TX_UFC_A(0x10) |
+	    TTI_DATA2_MEM_TX_UFC_B(0x20) |
+	    TTI_DATA2_MEM_TX_UFC_C(0x40) | TTI_DATA2_MEM_TX_UFC_D(0x80);
 	writeq(val64, &bar0->tti_data2_mem);
 
 	val64 = TTI_CMD_MEM_WE | TTI_CMD_MEM_STROBE_NEW_CMD;
@@ -1004,19 +944,16 @@
 	}
 
 	/* RTI Initialization */
-	val64 = RTI_DATA1_MEM_RX_TIMER_VAL(rx_timer_val) |
-	    RTI_DATA1_MEM_RX_URNG_A(rx_urange_a) |
-	    RTI_DATA1_MEM_RX_URNG_B(rx_urange_b) |
-	    RTI_DATA1_MEM_RX_URNG_C(rx_urange_c);
-	if (rx_utilz_periodic)
-		val64 |= RTI_DATA1_MEM_RX_TIMER_AC_EN;
+	val64 = RTI_DATA1_MEM_RX_TIMER_VAL(0xFFF) |
+	    RTI_DATA1_MEM_RX_URNG_A(0xA) |
+	    RTI_DATA1_MEM_RX_URNG_B(0x10) |
+	    RTI_DATA1_MEM_RX_URNG_C(0x30) | RTI_DATA1_MEM_RX_TIMER_AC_EN;
 
 	writeq(val64, &bar0->rti_data1_mem);
 
-	val64 = RTI_DATA2_MEM_RX_UFC_A(rx_ufc_a) |
-	    RTI_DATA2_MEM_RX_UFC_B(rx_ufc_b) |
-	    RTI_DATA2_MEM_RX_UFC_C(rx_ufc_c) |
-	    RTI_DATA2_MEM_RX_UFC_D(rx_ufc_d);
+	val64 = RTI_DATA2_MEM_RX_UFC_A(0x1) |
+	    RTI_DATA2_MEM_RX_UFC_B(0x2) |
+	    RTI_DATA2_MEM_RX_UFC_C(0x40) | RTI_DATA2_MEM_RX_UFC_D(0x80);
 	writeq(val64, &bar0->rti_data2_mem);
 
 	val64 = RTI_CMD_MEM_WE | RTI_CMD_MEM_STROBE_NEW_CMD;
@@ -1675,15 +1612,8 @@
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
-	if (frame_len[ring_no]) {
-		if (frame_len[ring_no] > dev->mtu)
-			dev->mtu = frame_len[ring_no];
-		size = frame_len[ring_no] + HEADER_ETHERNET_II_802_3_SIZE +
-		    HEADER_802_2_SIZE + HEADER_SNAP_SIZE;
-	} else {
-		size = dev->mtu + HEADER_ETHERNET_II_802_3_SIZE +
-		    HEADER_802_2_SIZE + HEADER_SNAP_SIZE;
-	}
+	size = dev->mtu + HEADER_ETHERNET_II_802_3_SIZE +
+	    HEADER_802_2_SIZE + HEADER_SNAP_SIZE;
 
 	while (alloc_tab < alloc_cnt) {
 		block_no = mac_control->rx_curr_put_info[ring_no].
@@ -2768,13 +2698,6 @@
 	}
 
 	queue = 0;
-	/* Multi FIFO Tx is disabled for now. */
-	if (!queue && tx_prio) {
-		u8 x = (skb->data)[5];
-		queue = x % config->tx_fifo_num;
-	}
-
-
 	put_off = (u16) mac_control->tx_curr_put_info[queue].offset;
 	get_off = (u16) mac_control->tx_curr_get_info[queue].offset;
 	txdp = (TxD_t *) sp->list_info[queue][put_off].list_virt_addr;
@@ -4612,25 +4535,16 @@
 			      (pci_cmd | PCI_COMMAND_PARITY));
 	pci_read_config_word(sp->pdev, PCI_COMMAND, &pci_cmd);
 
-	/* Set user specified value in Latency Timer */
-	if (latency_timer) {
-		pci_write_config_byte(sp->pdev, PCI_LATENCY_TIMER,
-				      latency_timer);
-		pci_read_config_byte(sp->pdev, PCI_LATENCY_TIMER,
-				     &latency_timer);
-	}
-
-	/* Set MMRB count to 2048 in PCI-X Command register. */
+	/* Set MMRB count to 1024 in PCI-X Command register. */
 	sp->pcix_cmd &= 0xFFF3;
-	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
-			      (sp->pcix_cmd | (max_read_byte_cnt << 2)));
+	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER, (sp->pcix_cmd | (0x1 << 2)));	/* MMRBC 1K */
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
 			     &(sp->pcix_cmd));
 
 	/*  Setting Maximum outstanding splits based on system type. */
 	sp->pcix_cmd &= 0xFF8F;
 
-	sp->pcix_cmd |= XENA_MAX_OUTSTANDING_SPLITS(max_splits_trans);
+	sp->pcix_cmd |= XENA_MAX_OUTSTANDING_SPLITS(0x1);	/* 2 splits. */
 	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
 			      sp->pcix_cmd);
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
@@ -4645,58 +4559,20 @@
 
 MODULE_AUTHOR("Raghavendra Koushik <raghavendra.koushik@s2io.com>");
 MODULE_LICENSE("GPL");
-MODULE_PARM(lso_enable, "i");
+module_param(tx_fifo_num, int, 0);
+module_param_array(tx_fifo_len, int, tx_fifo_num, 0);
+module_param(rx_ring_num, int, 0);
+module_param_array(rx_ring_sz, int, rx_ring_num, 0);
+module_param(Stats_refresh_time, int, 0);
+module_param(rmac_pause_time, int, 0);
+module_param(mc_pause_threshold_q0q3, int, 0);
+module_param(mc_pause_threshold_q4q7, int, 0);
+module_param(shared_splits, int, 0);
+module_param(tmac_util_period, int, 0);
+module_param(rmac_util_period, int, 0);
 #ifndef CONFIG_S2IO_NAPI
-MODULE_PARM(indicate_max_pkts, "i");
+module_param(indicate_max_pkts, int, 0);
 #endif
-MODULE_PARM(cksum_offload_enable, "i");
-MODULE_PARM(tx_fifo_num, "i");
-MODULE_PARM(tx_fifo_len_0, "i");
-MODULE_PARM(tx_fifo_len_1, "i");
-MODULE_PARM(tx_fifo_len_2, "i");
-MODULE_PARM(tx_fifo_len_3, "i");
-MODULE_PARM(tx_fifo_len_4, "i");
-MODULE_PARM(tx_fifo_len_5, "i");
-MODULE_PARM(tx_fifo_len_6, "i");
-MODULE_PARM(tx_fifo_len_7, "i");
-MODULE_PARM(max_txds, "i");
-MODULE_PARM(rx_ring_num, "i");
-MODULE_PARM(rx_ring_sz_0, "i");
-MODULE_PARM(rx_ring_sz_1, "i");
-MODULE_PARM(rx_ring_sz_2, "i");
-MODULE_PARM(rx_ring_sz_3, "i");
-MODULE_PARM(rx_ring_sz_4, "i");
-MODULE_PARM(rx_ring_sz_5, "i");
-MODULE_PARM(rx_ring_sz_6, "i");
-MODULE_PARM(rx_ring_sz_7, "i");
-MODULE_PARM(Stats_refresh_time, "i");
-MODULE_PARM(rmac_pause_time, "i");
-MODULE_PARM(mc_pause_threshold_q0q3, "i");
-MODULE_PARM(mc_pause_threshold_q4q7, "i");
-MODULE_PARM(shared_splits, "i");
-MODULE_PARM(max_splits_trans, "i");
-MODULE_PARM(tmac_util_period, "i");
-MODULE_PARM(rmac_util_period, "i");
-MODULE_PARM(tx_timer_val, "i");
-MODULE_PARM(tx_utilz_periodic, "i");
-MODULE_PARM(rx_timer_val, "i");
-MODULE_PARM(rx_utilz_periodic, "i");
-MODULE_PARM(tx_urange_a, "i");
-MODULE_PARM(tx_ufc_a, "i");
-MODULE_PARM(tx_urange_b, "i");
-MODULE_PARM(tx_ufc_b, "i");
-MODULE_PARM(tx_urange_c, "i");
-MODULE_PARM(tx_ufc_c, "i");
-MODULE_PARM(tx_ufc_d, "i");
-MODULE_PARM(rx_urange_a, "i");
-MODULE_PARM(rx_ufc_a, "i");
-MODULE_PARM(rx_urange_b, "i");
-MODULE_PARM(rx_ufc_b, "i");
-MODULE_PARM(rx_urange_c, "i");
-MODULE_PARM(rx_ufc_c, "i");
-MODULE_PARM(rx_ufc_d, "i");
-MODULE_PARM(latency_timer, "i");
-MODULE_PARM(max_read_byte_cnt, "i");
 /**
  *  s2io_init_nic - Initialization of the adapter . 
  *  @pdev : structure containing the PCI related information of the device.
@@ -4797,23 +4673,12 @@
 	config = &sp->config;
 
 	/* Tx side parameters. */
+	tx_fifo_len[0] = DEFAULT_FIFO_LEN;	/* Default value. */
 	config->tx_fifo_num = tx_fifo_num;
-	config->tx_cfg[0].fifo_len = tx_fifo_len_0;
-	config->tx_cfg[0].fifo_priority = 0;
-	config->tx_cfg[1].fifo_len = tx_fifo_len_1;
-	config->tx_cfg[1].fifo_priority = 1;
-	config->tx_cfg[2].fifo_len = tx_fifo_len_2;
-	config->tx_cfg[2].fifo_priority = 2;
-	config->tx_cfg[3].fifo_len = tx_fifo_len_3;
-	config->tx_cfg[3].fifo_priority = 3;
-	config->tx_cfg[4].fifo_len = tx_fifo_len_4;
-	config->tx_cfg[4].fifo_priority = 4;
-	config->tx_cfg[5].fifo_len = tx_fifo_len_5;
-	config->tx_cfg[5].fifo_priority = 5;
-	config->tx_cfg[6].fifo_len = tx_fifo_len_6;
-	config->tx_cfg[6].fifo_priority = 6;
-	config->tx_cfg[7].fifo_len = tx_fifo_len_7;
-	config->tx_cfg[7].fifo_priority = 7;
+	for (i = 0; i < MAX_TX_FIFOS; i++) {
+		config->tx_cfg[i].fifo_len = tx_fifo_len[i];
+		config->tx_cfg[i].fifo_priority = i;
+	}
 
 	config->tx_intr_type = TXD_INT_TYPE_UTILZ;
 	for (i = 0; i < config->tx_fifo_num; i++) {
@@ -4827,23 +4692,13 @@
 	config->max_txds = MAX_SKB_FRAGS;
 
 	/* Rx side parameters. */
+	rx_ring_sz[0] = SMALL_BLK_CNT;	/* Default value. */
 	config->rx_ring_num = rx_ring_num;
-	config->rx_cfg[0].num_rxd = rx_ring_sz_0 * (MAX_RXDS_PER_BLOCK + 1);
-	config->rx_cfg[0].ring_priority = 0;
-	config->rx_cfg[1].num_rxd = rx_ring_sz_1 * (MAX_RXDS_PER_BLOCK + 1);
-	config->rx_cfg[1].ring_priority = 1;
-	config->rx_cfg[2].num_rxd = rx_ring_sz_2 * (MAX_RXDS_PER_BLOCK + 1);
-	config->rx_cfg[2].ring_priority = 2;
-	config->rx_cfg[3].num_rxd = rx_ring_sz_3 * (MAX_RXDS_PER_BLOCK + 1);
-	config->rx_cfg[3].ring_priority = 3;
-	config->rx_cfg[4].num_rxd = rx_ring_sz_4 * (MAX_RXDS_PER_BLOCK + 1);
-	config->rx_cfg[4].ring_priority = 4;
-	config->rx_cfg[5].num_rxd = rx_ring_sz_5 * (MAX_RXDS_PER_BLOCK + 1);
-	config->rx_cfg[5].ring_priority = 5;
-	config->rx_cfg[6].num_rxd = rx_ring_sz_6 * (MAX_RXDS_PER_BLOCK + 1);
-	config->rx_cfg[6].ring_priority = 6;
-	config->rx_cfg[7].num_rxd = rx_ring_sz_7 * (MAX_RXDS_PER_BLOCK + 1);
-	config->rx_cfg[7].ring_priority = 7;
+	for (i = 0; i < MAX_RX_RINGS; i++) {
+		config->rx_cfg[i].num_rxd = rx_ring_sz[i] *
+		    (MAX_RXDS_PER_BLOCK + 1);
+		config->rx_cfg[i].ring_priority = i;
+	}
 
 	for (i = 0; i < rx_ring_num; i++) {
 		config->rx_cfg[i].ring_org = RING_ORG_BUFF1;
@@ -4910,17 +4765,14 @@
 	 */
 #ifdef CONFIG_S2IO_NAPI
 	dev->poll = s2io_poll;
-	dev->weight = 90;	/* For now. */
+	dev->weight = 90;
 #endif
 
-	dev->features |= NETIF_F_SG;
-	if (cksum_offload_enable)
-		dev->features |= NETIF_F_IP_CSUM;
+	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
 	if (sp->high_dma_flag == TRUE)
 		dev->features |= NETIF_F_HIGHDMA;
 #ifdef NETIF_F_TSO
-	if (lso_enable)
-		dev->features |= NETIF_F_TSO;
+	dev->features |= NETIF_F_TSO;
 #endif
 
 	dev->tx_timeout = &s2io_tx_watchdog;
@@ -5092,8 +4944,6 @@
 
 int __init s2io_starter(void)
 {
-	if (verify_load_parm())
-		return -ENODEV;
 	return pci_module_init(&s2io_driver);
 }
 
@@ -5110,223 +4960,3 @@
 
 module_init(s2io_starter);
 module_exit(s2io_closer);
-/**
- * verify_load_parm -  verifies the module loadable parameters
- * Descriptions: Verifies the module loadable parameters and initializes the
- * Tx Fifo, Rx Ring and other paramters.
- */
-
-int verify_load_parm()
-{
-	int fail = 0;
-	if (!((lso_enable == 0) || (lso_enable == 1))) {
-		printk("lso_enable can be either '1' or '0'\n");
-		fail = 1;
-	}
-#ifndef CONFIG_S2IO_NAPI
-	if ((indicate_max_pkts > (0xFFFFFFFF))) {
-		printk
-		    ("indicate_max_pkts can take value greater than zero but less than 2power(32)\n");
-		fail = 1;
-	}
-#endif
-	if (!((cksum_offload_enable == 0) || (cksum_offload_enable == 1))) {
-		printk("cksum_offload_enable can be only '0' or '1' \n");
-		fail = 1;
-	}
-	if ((tx_fifo_num == 0) || (tx_fifo_num > 8)) {
-		printk("tx_fifo_num can take value from 1 to 8\n");
-		fail = 1;
-	}
-	switch (tx_fifo_num) {
-	case 8:
-		if ((tx_fifo_len_7 == 0) || tx_fifo_len_7 > 8192) {
-			printk
-			    ("tx_fifo_len_7 can take value from 1 to 8192\n");
-			fail = 1;
-		}
-	case 7:
-		if ((tx_fifo_len_6 == 0) || tx_fifo_len_6 > 8192) {
-			printk
-			    ("tx_fifo_len_6 can take value from 1 to 8192\n");
-			fail = 1;
-		}
-	case 6:
-		if ((tx_fifo_len_5 == 0) || tx_fifo_len_5 > 8192) {
-			printk
-			    ("tx_fifo_len_5 can take value from 1 to 8192\n");
-			fail = 1;
-		}
-	case 5:
-		if ((tx_fifo_len_4 == 0) || tx_fifo_len_4 > 8192) {
-			printk
-			    ("tx_fifo_len_4 can take value from 1 to 8192\n");
-			fail = 1;
-		}
-	case 4:
-		if ((tx_fifo_len_3 == 0) || tx_fifo_len_3 > 8192) {
-			printk
-			    ("tx_fifo_len_3 can take value from 1 to 8192\n");
-			fail = 1;
-		}
-	case 3:
-		if ((tx_fifo_len_2 == 0) || tx_fifo_len_2 > 8192) {
-			printk
-			    ("tx_fifo_len_2 can take value from 1 to 8192\n");
-			fail = 1;
-		}
-	case 2:
-		if ((tx_fifo_len_1 == 0) || tx_fifo_len_1 > 8192) {
-			printk
-			    ("tx_fifo_len_1 can take value from 1 to 8192\n");
-			fail = 1;
-		}
-	case 1:
-		if ((tx_fifo_len_0 == 0) || tx_fifo_len_0 > 8192) {
-			printk
-			    ("tx_fifo_len_0 can take value from 1 to 8192\n");
-			fail = 1;
-		}
-	}
-	if ((max_txds > 32) || (max_txds < 1)) {
-		printk("max_txds can take value from 1 to 32\n");
-		fail = 1;
-	}
-	if ((rx_ring_num > 8) || (rx_ring_num < 1)) {
-		printk("rx_ring_num can take value from 1 to 8\n");
-		fail = 1;
-	}
-	switch (rx_ring_num) {
-	case 8:
-		if (rx_ring_sz_7 < 1) {
-			printk
-			    ("rx_ring_sz_7 can take value greater than 0\n");
-			fail = 1;
-		}
-	case 7:
-		if (rx_ring_sz_6 < 1) {
-			printk
-			    ("rx_ring_sz_6 can take value greater than 0\n");
-			fail = 1;
-		}
-	case 6:
-		if (rx_ring_sz_5 < 1) {
-			printk
-			    ("rx_ring_sz_5 can take value greater than 0\n");
-			fail = 1;
-		}
-	case 5:
-		if (rx_ring_sz_4 < 1) {
-			printk
-			    ("rx_ring_sz_4 can take value greater than 0\n");
-			fail = 1;
-		}
-	case 4:
-		if (rx_ring_sz_3 < 1) {
-			printk
-			    ("rx_ring_sz_3 can take value greater than 0\n");
-			fail = 1;
-		}
-	case 3:
-		if (rx_ring_sz_2 < 1) {
-			printk
-			    ("rx_ring_sz_2 can take value greater than 0\n");
-			fail = 1;
-		}
-	case 2:
-		if (rx_ring_sz_1 < 1) {
-			printk
-			    ("rx_ring_sz_1 can take value greater than 0\n");
-			fail = 1;
-		}
-	case 1:
-		if (rx_ring_sz_0 < 1) {
-			printk
-			    ("rx_ring_sz_0 can take value greater than 0\n");
-			fail = 1;
-		}
-	}
-	if ((Stats_refresh_time < 1)) {
-		printk
-		    ("Stats_refresh_time cannot be less than 1 second \n");
-		fail = 1;
-	}
-	if (((rmac_pause_time < 0x10) && (rmac_pause_time != 0)) ||
-	    (rmac_pause_time > 0xFFFF)) {
-		printk
-		    ("rmac_pause_time can take value from 16 to 65535\n");
-		fail = 1;
-	}
-	if (max_splits_trans > 7) {
-		printk("max_splits_trans can take value from 0 to 7\n");
-		fail = 1;
-	}
-	if ((mc_pause_threshold_q0q3 > 0xFE)) {
-		printk("mc_pause_threshold_q0q3 cannot exceed 254\n");
-		fail = 1;
-	}
-	if ((mc_pause_threshold_q4q7 > 0xFE)) {
-		printk("mc_pause_threshold_q4q7 cannot exceed 254\n");
-		fail = 1;
-	}
-	if ((latency_timer)
-	    && ((latency_timer < 8) || (latency_timer > 255))) {
-		printk("latency_timer can take value from 8 to 255\n");
-		fail = 1;
-	}
-	if (max_read_byte_cnt > 3) {
-		printk("max_read_byte_cnt can take value from 0 to 3\n");
-		fail = 1;
-	}
-	if (shared_splits > 31) {
-		printk("shared_splits cannot exceed 31\n");
-		fail = 1;
-	}
-	if (rmac_util_period > 0xF) {
-		printk("rmac_util_period cannot exceed 15\n");
-		fail = 1;
-	}
-	if (tmac_util_period > 0xF) {
-		printk("tmac_util_period cannot exceed 15\n");
-		fail = 1;
-	}
-	if ((tx_utilz_periodic > 1) || (rx_utilz_periodic > 1)) {
-		printk
-		    ("tx_utilz_periodic & rx_utilz_periodic can be either "
-		     "'0' or '1'\n");
-		fail = 1;
-	}
-	if (((tx_urange_a > 100) || (tx_urange_b > 100) ||
-		(tx_urange_c > 100)) || (tx_urange_a > tx_urange_b)
-		|| (tx_urange_b > tx_urange_c)) {
-		printk
-		    ("tx_urange_a, tx_urange_b & tx_urange_c can take value "
-		     "from 0 to 100 and range_a can't exceed range_b "
-		     "neither can range_b exceed range_c\n");
-		fail = 1;
-	}
-	if (((rx_urange_a > 100) || (rx_urange_b > 100) ||
-		(rx_urange_c > 100)) || (rx_urange_a > rx_urange_b)
-		|| (rx_urange_b > rx_urange_c)) {
-		printk
-		    ("rx_urange_a, rx_urange_b & rx_urange_c can take value "
-		     "from 0 to 100 and range_a can't exceed range_b "
-		     "neither can range_b exceed range_c\n");
-		fail = 1;
-	}
-	if ((tx_ufc_a > 0xffff) || (tx_ufc_b > 0xffff) ||
-	    (tx_ufc_c > 0xffff) || (tx_ufc_d > 0xffff)) {
-		printk
-		    (" tx_ufc_a, tx_ufc_b, tx_ufc_c, tx_ufc_d can take value"
-		     "from 0 to 65535(0xFFFF)\n");
-		fail = 1;
-	}
-	if ((rx_ufc_a > 0xffff) || (rx_ufc_b > 0xffff) ||
-	    (rx_ufc_c > 0xffff) || (rx_ufc_d > 0xffff)) {
-		printk
-		    (" rx_ufc_a, rx_ufc_b, rx_ufc_c, rx_ufc_d can take value"
-		     "from 0 to 65535(0xFFFF)\n");
-		fail = 1;
-	}
-	return fail;
-}
diff -urN vanilla-linux/drivers/net/s2io.h linux-2.6.8.1/drivers/net/s2io.h
--- vanilla-linux/drivers/net/s2io.h	2004-10-26 16:43:26.556439416 -0700
+++ linux-2.6.8.1/drivers/net/s2io.h	2004-10-26 16:43:19.800466480 -0700
@@ -873,7 +873,6 @@
 int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
 static irqreturn_t s2io_isr(int irq, void *dev_id, struct pt_regs *regs);
 static int verify_xena_quiescence(u64 val64, int flag);
-int verify_load_parm(void);
 #ifdef SET_ETHTOOL_OPS
 static struct ethtool_ops netdev_ethtool_ops;
 #endif
