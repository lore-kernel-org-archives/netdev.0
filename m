From: "Ravinandan Arakali" <ravinandan.arakali@s2io.com>
Subject: [PATCH 2.6.9-rc2 5/12] S2io: module loadable parameters
Date: Thu, 28 Oct 2004 11:34:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <001101c4bd1c$c37a6990$9810100a@S2IOtech.com>
Reply-To: <ravinandan.arakali@s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <leonid.grossman@s2io.com>,
        <raghavendra.koushik@s2io.com>, <rapuru.sriram@s2io.com>,
        <alicia.pena@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Francois Romieu'" <romieu@fr.zoreil.com>
In-reply-to: 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
This patch adds/modifies the following module loadable parameters.

1. Max Txds per List.
2. statistics refresh time
3. pause frame control parameters including gap between two successive frames, threshold 
   watermarks
4. RTI and TTI configuration parameters including ranges, packet counts and timeout periods. 
   For further information please read the section 3.5 of XFrame H/W spec.
5. PCI/PCI-X configuration variables latency_timer, MMRBC and OST.
6. OS offload features TSO (If support available) and checksum offload.
7. If NAPI is not in use, a variable indicate_max_pkts can be used to limit number of Rx 
   side packets processed for one call to Rx Intr handler.

Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>
---
diff -urN vanilla-linux/drivers/net/s2io.c linux-2.6.8.1/drivers/net/s2io.c
--- vanilla-linux/drivers/net/s2io.c	2004-10-11 15:33:35.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.c	2004-10-11 15:34:23.000000000 -0700
@@ -223,14 +223,66 @@
 };
 
 /* Module Loadable parameters. */
-static u32 ring_num;
 static u32 frame_len[MAX_RX_RINGS];
-static u32 ring_len[MAX_RX_RINGS];
-static u32 fifo_num;
-static u32 fifo_len[MAX_TX_FIFOS];
 static u32 rx_prio;
 static u32 tx_prio;
-static u8 latency_timer;
+
+static unsigned int lso_enable = 1;
+#ifndef CONFIG_S2IO_NAPI
+static unsigned int indicate_max_pkts;
+#endif
+static unsigned int cksum_offload_enable = 1;
+static unsigned int tx_fifo_num = 1;
+static unsigned int tx_fifo_len_0 = DEFAULT_FIFO_LEN;
+static unsigned int tx_fifo_len_1;
+static unsigned int tx_fifo_len_2;
+static unsigned int tx_fifo_len_3;
+static unsigned int tx_fifo_len_4;
+static unsigned int tx_fifo_len_5;
+static unsigned int tx_fifo_len_6;
+static unsigned int tx_fifo_len_7;
+static unsigned int max_txds = MAX_SKB_FRAGS;
+static unsigned int rx_ring_num = 1;
+static unsigned int rx_ring_sz_0 = SMALL_BLK_CNT;
+static unsigned int rx_ring_sz_1;
+static unsigned int rx_ring_sz_2;
+static unsigned int rx_ring_sz_3;
+static unsigned int rx_ring_sz_4;
+static unsigned int rx_ring_sz_5;
+static unsigned int rx_ring_sz_6;
+static unsigned int rx_ring_sz_7;
+static unsigned int Stats_refresh_time = 4;
+static unsigned int rmac_pause_time = 65535;
+static unsigned int mc_pause_threshold_q0q3 = 187;
+static unsigned int mc_pause_threshold_q4q7 = 187;
+static unsigned int shared_splits;
+#if defined(__ia64__)
+static unsigned int max_splits_trans = XENA_THREE_SPLIT_TRANSACTION;
+#else
+static unsigned int max_splits_trans = XENA_TWO_SPLIT_TRANSACTION;
+#endif
+static unsigned int tmac_util_period = 5;
+static unsigned int rmac_util_period = 5;
+static unsigned int tx_timer_val = 0xFFF;
+static unsigned int tx_utilz_periodic = 1;
+static unsigned int rx_timer_val = 0xFFF;
+static unsigned int rx_utilz_periodic = 1;
+static unsigned int tx_urange_a = 0xA;
+static unsigned int tx_ufc_a = 0x10;
+static unsigned int tx_urange_b = 0x10;
+static unsigned int tx_ufc_b = 0x20;
+static unsigned int tx_urange_c = 0x30;
+static unsigned int tx_ufc_c = 0x40;
+static unsigned int tx_ufc_d = 0x80;
+static unsigned int rx_urange_a = 0xA;
+static unsigned int rx_ufc_a = 0x1;
+static unsigned int rx_urange_b = 0x10;
+static unsigned int rx_ufc_b = 0x2;
+static unsigned int rx_urange_c = 0x30;
+static unsigned int rx_ufc_c = 0x40;
+static unsigned int rx_ufc_d = 0x80;
+static u8 latency_timer = 0xf8;
+static u8 max_read_byte_cnt = 2;
 
 /* 
  * S2IO device table.
@@ -782,14 +834,16 @@
 
 	/* Enable statistics */
 	writeq(mac_control->stats_mem_phy, &bar0->stat_addr);
-	val64 = SET_UPDT_PERIOD(8) | STAT_CFG_STAT_RO | STAT_CFG_STAT_EN;
+	val64 = SET_UPDT_PERIOD(Stats_refresh_time) |
+	    STAT_CFG_STAT_RO | STAT_CFG_STAT_EN;
 	writeq(val64, &bar0->stat_cfg);
 
 	/* 
 	 * Initializing the sampling rate for the device to calculate the
 	 * bandwidth utilization.
 	 */
-	val64 = MAC_TX_LINK_UTIL_VAL(0x5) | MAC_RX_LINK_UTIL_VAL(0x5);
+	val64 = MAC_TX_LINK_UTIL_VAL(tmac_util_period) |
+	    MAC_RX_LINK_UTIL_VAL(rmac_util_period);
 	writeq(val64, &bar0->mac_link_util);
 
 
@@ -798,14 +852,18 @@
 	 * Scheme.
 	 */
 	/* TTI Initialization */
-	val64 = TTI_DATA1_MEM_TX_TIMER_VAL(0xFFF) |
-	    TTI_DATA1_MEM_TX_URNG_A(0xA) | TTI_DATA1_MEM_TX_URNG_B(0x10) |
-	    TTI_DATA1_MEM_TX_URNG_C(0x30) | TTI_DATA1_MEM_TX_TIMER_AC_EN;
+	val64 = TTI_DATA1_MEM_TX_TIMER_VAL(tx_timer_val) |
+	    TTI_DATA1_MEM_TX_URNG_A(tx_urange_a) |
+	    TTI_DATA1_MEM_TX_URNG_B(tx_urange_b) |
+	    TTI_DATA1_MEM_TX_URNG_C(tx_urange_c);
+	if (tx_utilz_periodic)
+		val64 |= TTI_DATA1_MEM_TX_TIMER_AC_EN;
 	writeq(val64, &bar0->tti_data1_mem);
 
-	val64 =
-	    TTI_DATA2_MEM_TX_UFC_A(0x10) | TTI_DATA2_MEM_TX_UFC_B(0x20) |
-	    TTI_DATA2_MEM_TX_UFC_C(0x40) | TTI_DATA2_MEM_TX_UFC_D(0x80);
+	val64 = TTI_DATA2_MEM_TX_UFC_A(tx_ufc_a) |
+	    TTI_DATA2_MEM_TX_UFC_B(tx_ufc_b) |
+	    TTI_DATA2_MEM_TX_UFC_C(tx_ufc_c) |
+	    TTI_DATA2_MEM_TX_UFC_D(tx_ufc_d);
 	writeq(val64, &bar0->tti_data2_mem);
 
 	val64 = TTI_CMD_MEM_WE | TTI_CMD_MEM_STROBE_NEW_CMD;
@@ -834,13 +892,19 @@
 	}
 
 	/* RTI Initialization */
-	val64 = RTI_DATA1_MEM_RX_TIMER_VAL(0xFFF) |
-	    RTI_DATA1_MEM_RX_URNG_A(0xA) | RTI_DATA1_MEM_RX_URNG_B(0x10) |
-	    RTI_DATA1_MEM_RX_URNG_C(0x30) | RTI_DATA1_MEM_RX_TIMER_AC_EN;
+	val64 = RTI_DATA1_MEM_RX_TIMER_VAL(rx_timer_val) |
+	    RTI_DATA1_MEM_RX_URNG_A(rx_urange_a) |
+	    RTI_DATA1_MEM_RX_URNG_B(rx_urange_b) |
+	    RTI_DATA1_MEM_RX_URNG_C(rx_urange_c);
+	if (rx_utilz_periodic)
+		val64 |= RTI_DATA1_MEM_RX_TIMER_AC_EN;
+
 	writeq(val64, &bar0->rti_data1_mem);
 
-	val64 = RTI_DATA2_MEM_RX_UFC_A(0x1) | RTI_DATA2_MEM_RX_UFC_B(0x2) |
-	    RTI_DATA2_MEM_RX_UFC_C(0x40) | RTI_DATA2_MEM_RX_UFC_D(0x80);
+	val64 = RTI_DATA2_MEM_RX_UFC_A(rx_ufc_a) |
+	    RTI_DATA2_MEM_RX_UFC_B(rx_ufc_b) |
+	    RTI_DATA2_MEM_RX_UFC_C(rx_ufc_c) |
+	    RTI_DATA2_MEM_RX_UFC_D(rx_ufc_d);
 	writeq(val64, &bar0->rti_data2_mem);
 
 	val64 = RTI_CMD_MEM_WE | RTI_CMD_MEM_STROBE_NEW_CMD;
@@ -923,7 +987,7 @@
 	 * exceeded the limit pointed by shared_splits
 	 */
 	val64 = readq(&bar0->pic_control);
-	val64 |= PIC_CNTL_SHARED_SPLITS(0);
+	val64 |= PIC_CNTL_SHARED_SPLITS(shared_splits);
 	writeq(val64, &bar0->pic_control);
 
 	return SUCCESS;
@@ -1381,7 +1445,7 @@
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		for (j = 0; j < config->tx_cfg[i].fifo_len - 1; j++) {
 			txdp = mac_control->txdl_start[i] +
-		    		(config->max_txds * j);
+			    (config->max_txds * j);
 			skb =
 			    (struct sk_buff *) ((unsigned long) txdp->
 						Host_Control);
@@ -1807,7 +1871,12 @@
 			mac_control->rx_curr_get_info[i].offset =
 			    offset_info.offset;
 			pkt_cnt++;
+			if ((indicate_max_pkts)
+			    && (pkt_cnt > indicate_max_pkts))
+				break;
 		}
+		if ((indicate_max_pkts) && (pkt_cnt > indicate_max_pkts))
+			break;
 	}
 }
 #endif
@@ -4004,7 +4073,6 @@
 	return SUCCESS;
 }
 
-
 /**
  *  s2io_link - stops/starts the Tx queue.
  *  @sp : private member of the device structure, which is a pointer to the
@@ -4088,17 +4156,23 @@
 				     &latency_timer);
 	}
 
-	/* Set MMRB count to 4096 in PCI-X Command register. */
+	/* Set MMRB count to 2048 in PCI-X Command register. */
+	sp->pcix_cmd &= 0xFFF3;
 	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
-			      (sp->pcix_cmd | 0x0C));
+			      (sp->pcix_cmd | (max_read_byte_cnt << 2)));
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
 			     &(sp->pcix_cmd));
 
 	/*  Setting Maximum outstanding splits based on system type. */
 	sp->pcix_cmd &= 0xFF8F;
 
-	sp->pcix_cmd |=
-	    XENA_MAX_OUTSTANDING_SPLITS(XENA_TWO_SPLIT_TRANSACTION);
+	sp->pcix_cmd |= XENA_MAX_OUTSTANDING_SPLITS(max_splits_trans);
+	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
+			      sp->pcix_cmd);
+	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
+			     &(sp->pcix_cmd));
+	/* Forcibly disabling relaxed ordering capability of the card. */
+	sp->pcix_cmd &= 0xfffd;
 	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
 			      sp->pcix_cmd);
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
@@ -4107,14 +4181,58 @@
 
 MODULE_AUTHOR("Raghavendra Koushik <raghavendra.koushik@s2io.com>");
 MODULE_LICENSE("GPL");
-MODULE_PARM(ring_num, "1-" __MODULE_STRING(1) "i");
-MODULE_PARM(frame_len, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(ring_len, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(fifo_num, "1-" __MODULE_STRING(1) "i");
-MODULE_PARM(fifo_len, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(rx_prio, "1-" __MODULE_STRING(1) "i");
-MODULE_PARM(tx_prio, "1-" __MODULE_STRING(1) "i");
-MODULE_PARM(latency_timer, "1-" __MODULE_STRING(1) "i");
+MODULE_PARM(lso_enable, "i");
+#ifndef CONFIG_S2IO_NAPI
+MODULE_PARM(indicate_max_pkts, "i");
+#endif
+MODULE_PARM(cksum_offload_enable, "i");
+MODULE_PARM(tx_fifo_num, "i");
+MODULE_PARM(tx_fifo_len_0, "i");
+MODULE_PARM(tx_fifo_len_1, "i");
+MODULE_PARM(tx_fifo_len_2, "i");
+MODULE_PARM(tx_fifo_len_3, "i");
+MODULE_PARM(tx_fifo_len_4, "i");
+MODULE_PARM(tx_fifo_len_5, "i");
+MODULE_PARM(tx_fifo_len_6, "i");
+MODULE_PARM(tx_fifo_len_7, "i");
+MODULE_PARM(max_txds, "i");
+MODULE_PARM(rx_ring_num, "i");
+MODULE_PARM(rx_ring_sz_0, "i");
+MODULE_PARM(rx_ring_sz_1, "i");
+MODULE_PARM(rx_ring_sz_2, "i");
+MODULE_PARM(rx_ring_sz_3, "i");
+MODULE_PARM(rx_ring_sz_4, "i");
+MODULE_PARM(rx_ring_sz_5, "i");
+MODULE_PARM(rx_ring_sz_6, "i");
+MODULE_PARM(rx_ring_sz_7, "i");
+MODULE_PARM(Stats_refresh_time, "i");
+MODULE_PARM(rmac_pause_time, "i");
+MODULE_PARM(mc_pause_threshold_q0q3, "i");
+MODULE_PARM(mc_pause_threshold_q4q7, "i");
+MODULE_PARM(shared_splits, "i");
+MODULE_PARM(max_splits_trans, "i");
+MODULE_PARM(tmac_util_period, "i");
+MODULE_PARM(rmac_util_period, "i");
+MODULE_PARM(tx_timer_val, "i");
+MODULE_PARM(tx_utilz_periodic, "i");
+MODULE_PARM(rx_timer_val, "i");
+MODULE_PARM(rx_utilz_periodic, "i");
+MODULE_PARM(tx_urange_a, "i");
+MODULE_PARM(tx_ufc_a, "i");
+MODULE_PARM(tx_urange_b, "i");
+MODULE_PARM(tx_ufc_b, "i");
+MODULE_PARM(tx_urange_c, "i");
+MODULE_PARM(tx_ufc_c, "i");
+MODULE_PARM(tx_ufc_d, "i");
+MODULE_PARM(rx_urange_a, "i");
+MODULE_PARM(rx_ufc_a, "i");
+MODULE_PARM(rx_urange_b, "i");
+MODULE_PARM(rx_ufc_b, "i");
+MODULE_PARM(rx_urange_c, "i");
+MODULE_PARM(rx_ufc_c, "i");
+MODULE_PARM(rx_ufc_d, "i");
+MODULE_PARM(latency_timer, "i");
+MODULE_PARM(max_read_byte_cnt, "i");
 /**
  *  s2io_init_nic - Initialization of the adapter . 
  *  @pdev : structure containing the PCI related information of the device.
@@ -4215,33 +4333,23 @@
 	config = &sp->config;
 
 	/* Tx side parameters. */
-	config->tx_fifo_num = fifo_num ? fifo_num : 1;
-
-	if (!fifo_len[0] && (fifo_num > 1)) {
-		printk(KERN_ERR "Fifo Lens not specified for all FIFOs\n");
-		goto init_failed;
-	}
-
-	if (fifo_len[0]) {
-		int cnt;
-
-		for (cnt = 0; fifo_len[cnt]; cnt++);
-		if (fifo_num) {
-			if (cnt < fifo_num) {
-				printk(KERN_ERR
-				       "Fifo Lens not specified for ");
-				printk(KERN_ERR "all FIFOs\n");
-				goto init_failed;
-			}
-		}
-		for (cnt = 0; cnt < config->tx_fifo_num; cnt++) {
-			config->tx_cfg[cnt].fifo_len = fifo_len[cnt];
-			config->tx_cfg[cnt].fifo_priority = cnt;
-		}
-	} else {
-		config->tx_cfg[0].fifo_len = DEFAULT_FIFO_LEN;
-		config->tx_cfg[0].fifo_priority = 0;
-	}
+	config->tx_fifo_num = tx_fifo_num;
+	config->tx_cfg[0].fifo_len = tx_fifo_len_0;
+	config->tx_cfg[0].fifo_priority = 0;
+	config->tx_cfg[1].fifo_len = tx_fifo_len_1;
+	config->tx_cfg[1].fifo_priority = 1;
+	config->tx_cfg[2].fifo_len = tx_fifo_len_2;
+	config->tx_cfg[2].fifo_priority = 2;
+	config->tx_cfg[3].fifo_len = tx_fifo_len_3;
+	config->tx_cfg[3].fifo_priority = 3;
+	config->tx_cfg[4].fifo_len = tx_fifo_len_4;
+	config->tx_cfg[4].fifo_priority = 4;
+	config->tx_cfg[5].fifo_len = tx_fifo_len_5;
+	config->tx_cfg[5].fifo_priority = 5;
+	config->tx_cfg[6].fifo_len = tx_fifo_len_6;
+	config->tx_cfg[6].fifo_priority = 6;
+	config->tx_cfg[7].fifo_len = tx_fifo_len_7;
+	config->tx_cfg[7].fifo_priority = 7;
 
 	config->tx_intr_type = TXD_INT_TYPE_UTILZ;
 	for (i = 0; i < config->tx_fifo_num; i++) {
@@ -4255,27 +4363,34 @@
 	config->max_txds = MAX_SKB_FRAGS;
 
 	/* Rx side parameters. */
-	config->rx_ring_num = ring_num ? ring_num : 1;
+	config->rx_ring_num = rx_ring_num;
+	config->rx_cfg[0].num_rxd = rx_ring_sz_0 * (MAX_RXDS_PER_BLOCK + 1);
+	config->rx_cfg[0].ring_priority = 0;
+	config->rx_cfg[1].num_rxd = rx_ring_sz_1 * (MAX_RXDS_PER_BLOCK + 1);
+	config->rx_cfg[1].ring_priority = 1;
+	config->rx_cfg[2].num_rxd = rx_ring_sz_2 * (MAX_RXDS_PER_BLOCK + 1);
+	config->rx_cfg[2].ring_priority = 2;
+	config->rx_cfg[3].num_rxd = rx_ring_sz_3 * (MAX_RXDS_PER_BLOCK + 1);
+	config->rx_cfg[3].ring_priority = 3;
+	config->rx_cfg[4].num_rxd = rx_ring_sz_4 * (MAX_RXDS_PER_BLOCK + 1);
+	config->rx_cfg[4].ring_priority = 4;
+	config->rx_cfg[5].num_rxd = rx_ring_sz_5 * (MAX_RXDS_PER_BLOCK + 1);
+	config->rx_cfg[5].ring_priority = 5;
+	config->rx_cfg[6].num_rxd = rx_ring_sz_6 * (MAX_RXDS_PER_BLOCK + 1);
+	config->rx_cfg[6].ring_priority = 6;
+	config->rx_cfg[7].num_rxd = rx_ring_sz_7 * (MAX_RXDS_PER_BLOCK + 1);
+	config->rx_cfg[7].ring_priority = 7;
 
-	if (ring_len[0]) {
-		int cnt;
-		for (cnt = 0; cnt < config->rx_ring_num; cnt++) {
-			config->rx_cfg[cnt].num_rxd = ring_len[cnt];
-			config->rx_cfg[cnt].ring_priority = cnt;
-		}
-	} else {
-		config->rx_cfg[0].num_rxd = SMALL_RXD_CNT;
-		config->rx_cfg[0].ring_priority = 0;
-	}
-
-	for (i = 0; i < config->rx_ring_num; i++) {
+	for (i = 0; i < rx_ring_num; i++) {
 		config->rx_cfg[i].ring_org = RING_ORG_BUFF1;
 		config->rx_cfg[i].f_no_snoop =
 		    (NO_SNOOP_RXD | NO_SNOOP_RXD_BUFFER);
 	}
 
 	/*  Setting Mac Control parameters */
-	mac_control->rmac_pause_time = 0;
+	mac_control->rmac_pause_time = rmac_pause_time;
+	mac_control->mc_pause_threshold_q0q3 = mc_pause_threshold_q0q3;
+	mac_control->mc_pause_threshold_q4q7 = mc_pause_threshold_q4q7;
 
 
 	/* Initialize Ring buffer parameters. */
@@ -4334,11 +4449,14 @@
 	dev->weight = 90;	/* For now. */
 #endif
 
-	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
+	dev->features |= NETIF_F_SG;
+	if (cksum_offload_enable)
+		dev->features |= NETIF_F_IP_CSUM;
 	if (sp->high_dma_flag == TRUE)
 		dev->features |= NETIF_F_HIGHDMA;
 #ifdef NETIF_F_TSO
-	dev->features |= NETIF_F_TSO;
+	if (lso_enable)
+		dev->features |= NETIF_F_TSO;
 #endif
 
 	dev->tx_timeout = &s2io_tx_watchdog;
@@ -4453,7 +4571,6 @@
       bar0_remap_failed:
       mem_alloc_failed:
 	free_shared_mem(sp);
-      init_failed:
 	pci_disable_device(pdev);
 	pci_release_regions(pdev);
 	pci_set_drvdata(pdev, NULL);
@@ -4503,6 +4620,8 @@
 
 int __init s2io_starter(void)
 {
+	if (verify_load_parm())
+		return -ENODEV;
 	return pci_module_init(&s2io_driver);
 }
 
@@ -4519,3 +4638,223 @@
 
 module_init(s2io_starter);
 module_exit(s2io_closer);
+/**
+ * verify_load_parm -  verifies the module loadable parameters
+ * Descriptions: Verifies the module loadable parameters and initializes the
+ * Tx Fifo, Rx Ring and other paramters.
+ */
+
+int verify_load_parm()
+{
+	int fail = 0;
+	if (!((lso_enable == 0) || (lso_enable == 1))) {
+		printk("lso_enable can be either '1' or '0'\n");
+		fail = 1;
+	}
+#ifndef CONFIG_S2IO_NAPI
+	if ((indicate_max_pkts > (0xFFFFFFFF))) {
+		printk
+		    ("indicate_max_pkts can take value greater than zero but less than 2power(32)\n");
+		fail = 1;
+	}
+#endif
+	if (!((cksum_offload_enable == 0) || (cksum_offload_enable == 1))) {
+		printk("cksum_offload_enable can be only '0' or '1' \n");
+		fail = 1;
+	}
+	if ((tx_fifo_num == 0) || (tx_fifo_num > 8)) {
+		printk("tx_fifo_num can take value from 1 to 8\n");
+		fail = 1;
+	}
+	switch (tx_fifo_num) {
+	case 8:
+		if ((tx_fifo_len_7 == 0) || tx_fifo_len_7 > 8192) {
+			printk
+			    ("tx_fifo_len_7 can take value from 1 to 8192\n");
+			fail = 1;
+		}
+	case 7:
+		if ((tx_fifo_len_6 == 0) || tx_fifo_len_6 > 8192) {
+			printk
+			    ("tx_fifo_len_6 can take value from 1 to 8192\n");
+			fail = 1;
+		}
+	case 6:
+		if ((tx_fifo_len_5 == 0) || tx_fifo_len_5 > 8192) {
+			printk
+			    ("tx_fifo_len_5 can take value from 1 to 8192\n");
+			fail = 1;
+		}
+	case 5:
+		if ((tx_fifo_len_4 == 0) || tx_fifo_len_4 > 8192) {
+			printk
+			    ("tx_fifo_len_4 can take value from 1 to 8192\n");
+			fail = 1;
+		}
+	case 4:
+		if ((tx_fifo_len_3 == 0) || tx_fifo_len_3 > 8192) {
+			printk
+			    ("tx_fifo_len_3 can take value from 1 to 8192\n");
+			fail = 1;
+		}
+	case 3:
+		if ((tx_fifo_len_2 == 0) || tx_fifo_len_2 > 8192) {
+			printk
+			    ("tx_fifo_len_2 can take value from 1 to 8192\n");
+			fail = 1;
+		}
+	case 2:
+		if ((tx_fifo_len_1 == 0) || tx_fifo_len_1 > 8192) {
+			printk
+			    ("tx_fifo_len_1 can take value from 1 to 8192\n");
+			fail = 1;
+		}
+	case 1:
+		if ((tx_fifo_len_0 == 0) || tx_fifo_len_0 > 8192) {
+			printk
+			    ("tx_fifo_len_0 can take value from 1 to 8192\n");
+			fail = 1;
+		}
+	}
+	if ((max_txds > 32) || (max_txds < 1)) {
+		printk("max_txds can take value from 1 to 32\n");
+		fail = 1;
+	}
+	if ((rx_ring_num > 8) || (rx_ring_num < 1)) {
+		printk("rx_ring_num can take value from 1 to 8\n");
+		fail = 1;
+	}
+	switch (rx_ring_num) {
+	case 8:
+		if (rx_ring_sz_7 < 1) {
+			printk
+			    ("rx_ring_sz_7 can take value greater than 0\n");
+			fail = 1;
+		}
+	case 7:
+		if (rx_ring_sz_6 < 1) {
+			printk
+			    ("rx_ring_sz_6 can take value greater than 0\n");
+			fail = 1;
+		}
+	case 6:
+		if (rx_ring_sz_5 < 1) {
+			printk
+			    ("rx_ring_sz_5 can take value greater than 0\n");
+			fail = 1;
+		}
+	case 5:
+		if (rx_ring_sz_4 < 1) {
+			printk
+			    ("rx_ring_sz_4 can take value greater than 0\n");
+			fail = 1;
+		}
+	case 4:
+		if (rx_ring_sz_3 < 1) {
+			printk
+			    ("rx_ring_sz_3 can take value greater than 0\n");
+			fail = 1;
+		}
+	case 3:
+		if (rx_ring_sz_2 < 1) {
+			printk
+			    ("rx_ring_sz_2 can take value greater than 0\n");
+			fail = 1;
+		}
+	case 2:
+		if (rx_ring_sz_1 < 1) {
+			printk
+			    ("rx_ring_sz_1 can take value greater than 0\n");
+			fail = 1;
+		}
+	case 1:
+		if (rx_ring_sz_0 < 1) {
+			printk
+			    ("rx_ring_sz_0 can take value greater than 0\n");
+			fail = 1;
+		}
+	}
+	if ((Stats_refresh_time < 1)) {
+		printk
+		    ("Stats_refresh_time cannot be less than 1 second \n");
+		fail = 1;
+	}
+	if (((rmac_pause_time < 0x10) && (rmac_pause_time != 0)) ||
+	    (rmac_pause_time > 0xFFFF)) {
+		printk
+		    ("rmac_pause_time can take value from 16 to 65535\n");
+		fail = 1;
+	}
+	if (max_splits_trans > 7) {
+		printk("max_splits_trans can take value from 0 to 7\n");
+		fail = 1;
+	}
+	if ((mc_pause_threshold_q0q3 > 0xFE)) {
+		printk("mc_pause_threshold_q0q3 cannot exceed 254\n");
+		fail = 1;
+	}
+	if ((mc_pause_threshold_q4q7 > 0xFE)) {
+		printk("mc_pause_threshold_q4q7 cannot exceed 254\n");
+		fail = 1;
+	}
+	if ((latency_timer)
+	    && ((latency_timer < 8) || (latency_timer > 255))) {
+		printk("latency_timer can take value from 8 to 255\n");
+		fail = 1;
+	}
+	if (max_read_byte_cnt > 3) {
+		printk("max_read_byte_cnt can take value from 0 to 3\n");
+		fail = 1;
+	}
+	if (shared_splits > 31) {
+		printk("shared_splits cannot exceed 31\n");
+		fail = 1;
+	}
+	if (rmac_util_period > 0xF) {
+		printk("rmac_util_period cannot exceed 15\n");
+		fail = 1;
+	}
+	if (tmac_util_period > 0xF) {
+		printk("tmac_util_period cannot exceed 15\n");
+		fail = 1;
+	}
+	if ((tx_utilz_periodic > 1) || (rx_utilz_periodic > 1)) {
+		printk
+		    ("tx_utilz_periodic & rx_utilz_periodic can be either "
+		     "'0' or '1'\n");
+		fail = 1;
+	}
+	if (((tx_urange_a > 100) || (tx_urange_b > 100) ||
+		(tx_urange_c > 100)) || (tx_urange_a > tx_urange_b)
+		|| (tx_urange_b > tx_urange_c)) {
+		printk
+		    ("tx_urange_a, tx_urange_b & tx_urange_c can take value "
+		     "from 0 to 100 and range_a can't exceed range_b "
+			"neither can range_b exceed range_c\n");	
+		fail = 1;
+	}
+	if (((rx_urange_a > 100) || (rx_urange_b > 100) ||
+		(rx_urange_c > 100)) || (rx_urange_a > rx_urange_b)
+		|| (rx_urange_b > rx_urange_c)) {
+		printk
+		    ("rx_urange_a, rx_urange_b & rx_urange_c can take value "
+		     "from 0 to 100 and range_a can't exceed range_b "
+			"neither can range_b exceed range_c\n");	
+		fail = 1;
+	}
+	if ((tx_ufc_a > 0xffff) || (tx_ufc_b > 0xffff) ||
+	    (tx_ufc_c > 0xffff) || (tx_ufc_d > 0xffff)) {
+		printk
+		    (" tx_ufc_a, tx_ufc_b, tx_ufc_c, tx_ufc_d can take value"
+		     "from 0 to 65535(0xFFFF)\n");
+		fail = 1;
+	}
+	if ((rx_ufc_a > 0xffff) || (rx_ufc_b > 0xffff) ||
+	    (rx_ufc_c > 0xffff) || (rx_ufc_d > 0xffff)) {
+		printk
+		    (" rx_ufc_a, rx_ufc_b, rx_ufc_c, rx_ufc_d can take value"
+		     "from 0 to 65535(0xFFFF)\n");
+		fail = 1;
+	}
+	return fail;
+}
diff -urN vanilla-linux/drivers/net/s2io.h linux-2.6.8.1/drivers/net/s2io.h
--- vanilla-linux/drivers/net/s2io.h	2004-10-11 15:33:35.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.h	2004-10-11 15:34:23.000000000 -0700
@@ -348,9 +348,9 @@
 	u8 ring_priority;	/*Specifies service priority of ring */
 	/* OSM should not set any two rings with same priority */
 	u8 ring_org;		/*Organization of ring */
-#define RING_ORG_BUFF1           0x01
-#define RX_RING_ORG_BUFF3           0x03
-#define RX_RING_ORG_BUFF5           0x05
+#define RING_ORG_BUFF1		0x01
+#define RX_RING_ORG_BUFF3	0x03
+#define RX_RING_ORG_BUFF5	0x05
 
 	u8 f_no_snoop;
 #define NO_SNOOP_RXD                0x01
