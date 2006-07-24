From: Ananda Raju <Ananda.Raju@neterion.com>
Subject: [patch 1/2] s2io driver bug fixes
Date: Mon, 24 Jul 2006 19:52:49 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10607241946040.24957-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, ravinandan.arakali@neterion.com,
	rapuru.sriram@neterion.com, ananda.raju@neterion.com,
	alicia.pena@neterion.com, sivakumar.subramani@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:56462 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S932332AbWGXXwx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 19:52:53 -0400
To: netdev@vger.kernel.org, jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, 
	This patch contains some of the bug fixes and enhancements done to 
	s2io driver. Following are the brief description of changes

	1. Introduced macro "S2IO_PARM_INT" for declaring integer load parameter
	2. UDP_RR test failure, memset txdl after Tx completion 
	3. PXE boot may leave adapter in unknown state so do reset in probe.
	4. Add Tx completion code in netpoll
	5. In s2io_vpd_read() move array vpd_data[] to pointer, saves stack memory 
	6. Fix bug in ethtool online test

Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
---
diff -upNr netdev/drivers/net/s2io.c bug_fixes_1/drivers/net/s2io.c
--- netdev/drivers/net/s2io.c	2006-07-14 07:58:06.000000000 -0700
+++ bug_fixes_1/drivers/net/s2io.c	2006-07-14 09:26:09.000000000 -0700
@@ -370,38 +370,50 @@ static const u64 fix_mac[] = {
 	END_SIGN
 };
 
+MODULE_AUTHOR("Raghavendra Koushik <raghavendra.koushik@neterion.com>");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
+
+
 /* Module Loadable parameters. */
-static unsigned int tx_fifo_num = 1;
-static unsigned int tx_fifo_len[MAX_TX_FIFOS] =
-    {DEFAULT_FIFO_0_LEN, [1 ...(MAX_TX_FIFOS - 1)] = DEFAULT_FIFO_1_7_LEN};
-static unsigned int rx_ring_num = 1;
-static unsigned int rx_ring_sz[MAX_RX_RINGS] =
-    {[0 ...(MAX_RX_RINGS - 1)] = SMALL_BLK_CNT};
-static unsigned int rts_frm_len[MAX_RX_RINGS] =
-    {[0 ...(MAX_RX_RINGS - 1)] = 0 };
-static unsigned int rx_ring_mode = 1;
-static unsigned int use_continuous_tx_intrs = 1;
-static unsigned int rmac_pause_time = 0x100;
-static unsigned int mc_pause_threshold_q0q3 = 187;
-static unsigned int mc_pause_threshold_q4q7 = 187;
-static unsigned int shared_splits;
-static unsigned int tmac_util_period = 5;
-static unsigned int rmac_util_period = 5;
-static unsigned int bimodal = 0;
-static unsigned int l3l4hdr_size = 128;
-#ifndef CONFIG_S2IO_NAPI
-static unsigned int indicate_max_pkts;
-#endif
+S2IO_PARM_INT(tx_fifo_num, 1);
+S2IO_PARM_INT(rx_ring_num, 1);
+
+
+S2IO_PARM_INT(rx_ring_mode, 1);
+S2IO_PARM_INT(use_continuous_tx_intrs, 1);
+S2IO_PARM_INT(rmac_pause_time, 0x100);
+S2IO_PARM_INT(mc_pause_threshold_q0q3, 187);
+S2IO_PARM_INT(mc_pause_threshold_q4q7, 187);
+S2IO_PARM_INT(shared_splits, 0);
+S2IO_PARM_INT(tmac_util_period, 5);
+S2IO_PARM_INT(rmac_util_period, 5);
+S2IO_PARM_INT(bimodal, 0);
+S2IO_PARM_INT(l3l4hdr_size, 128);
 /* Frequency of Rx desc syncs expressed as power of 2 */
-static unsigned int rxsync_frequency = 3;
+S2IO_PARM_INT(rxsync_frequency, 3);
 /* Interrupt type. Values can be 0(INTA), 1(MSI), 2(MSI_X) */
-static unsigned int intr_type = 0;
+S2IO_PARM_INT(intr_type, 0);
 /* Large receive offload feature */
-static unsigned int lro = 0;
+S2IO_PARM_INT(lro, 0);
 /* Max pkts to be aggregated by LRO at one time. If not specified,
  * aggregation happens until we hit max IP pkt size(64K)
  */
-static unsigned int lro_max_pkts = 0xFFFF;
+S2IO_PARM_INT(lro_max_pkts, 0xFFFF);
+#ifndef CONFIG_S2IO_NAPI
+S2IO_PARM_INT(indicate_max_pkts, 0);
+#endif
+
+static unsigned int tx_fifo_len[MAX_TX_FIFOS] =
+    {DEFAULT_FIFO_0_LEN, [1 ...(MAX_TX_FIFOS - 1)] = DEFAULT_FIFO_1_7_LEN};
+static unsigned int rx_ring_sz[MAX_RX_RINGS] =
+    {[0 ...(MAX_RX_RINGS - 1)] = SMALL_BLK_CNT};
+static unsigned int rts_frm_len[MAX_RX_RINGS] =
+    {[0 ...(MAX_RX_RINGS - 1)] = 0 };
+
+module_param_array(tx_fifo_len, uint, NULL, 0);
+module_param_array(rx_ring_sz, uint, NULL, 0);
+module_param_array(rts_frm_len, uint, NULL, 0);
 
 /*
  * S2IO device table.
@@ -464,10 +476,9 @@ static int init_shared_mem(struct s2io_n
 		size += config->tx_cfg[i].fifo_len;
 	}
 	if (size > MAX_AVAILABLE_TXDS) {
-		DBG_PRINT(ERR_DBG, "%s: Requested TxDs too high, ",
-			  __FUNCTION__);
+		DBG_PRINT(ERR_DBG, "s2io: Requested TxDs too high, ");
 		DBG_PRINT(ERR_DBG, "Requested: %d, max supported: 8192\n", size);
-		return FAILURE;
+		return -EINVAL;
 	}
 
 	lst_size = (sizeof(TxD_t) * config->max_txds);
@@ -547,6 +558,7 @@ static int init_shared_mem(struct s2io_n
 	nic->ufo_in_band_v = kmalloc((sizeof(u64) * size), GFP_KERNEL);
 	if (!nic->ufo_in_band_v)
 		return -ENOMEM;
+	memset(nic->ufo_in_band_v, 0, size);
 
 	/* Allocation and initialization of RXDs in Rings */
 	size = 0;
@@ -1213,7 +1225,7 @@ static int init_nic(struct s2io_nic *nic
 		break;
 	}
 
-	/* Enable Tx FIFO partition 0. */
+	/* Enable all configured Tx FIFO partitions */
 	val64 = readq(&bar0->tx_fifo_partition_0);
 	val64 |= (TX_FIFO_PARTITION_EN);
 	writeq(val64, &bar0->tx_fifo_partition_0);
@@ -1650,7 +1662,7 @@ static void en_dis_able_nic_intrs(struct
 			writeq(temp64, &bar0->general_int_mask);
 			/*
 			 * If Hercules adapter enable GPIO otherwise
-			 * disabled all PCIX, Flash, MDIO, IIC and GPIO
+			 * disable all PCIX, Flash, MDIO, IIC and GPIO
 			 * interrupts for now.
 			 * TODO
 			 */
@@ -2119,7 +2131,7 @@ static struct sk_buff *s2io_txdl_getskb(
 				       frag->size, PCI_DMA_TODEVICE);
 		}
 	}
-	txdlp->Host_Control = 0;
+	memset(txdlp,0, (sizeof(TxD_t) * fifo_data->max_txds));
 	return(skb);
 }
 
@@ -2614,23 +2626,23 @@ no_rx:
 }
 #endif
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
 /**
- * s2io_netpoll - Rx interrupt service handler for netpoll support
+ * s2io_netpoll - netpoll event handler entry point
  * @dev : pointer to the device structure.
  * Description:
- * Polling 'interrupt' - used by things like netconsole to send skbs
- * without having to re-enable interrupts. It's not called while
- * the interrupt routine is executing.
+ * 	This function will be called by upper layer to check for events on the
+ * interface in situations where interrupts are disabled. It is used for
+ * specific in-kernel networking tasks, such as remote consoles and kernel
+ * debugging over the network (example netdump in RedHat).
  */
-
-#ifdef CONFIG_NET_POLL_CONTROLLER
 static void s2io_netpoll(struct net_device *dev)
 {
 	nic_t *nic = dev->priv;
 	mac_info_t *mac_control;
 	struct config_param *config;
 	XENA_dev_config_t __iomem *bar0 = nic->bar0;
-	u64 val64;
+	u64 val64 = 0xFFFFFFFFFFFFFFFFULL;
 	int i;
 
 	disable_irq(dev->irq);
@@ -2639,9 +2651,17 @@ static void s2io_netpoll(struct net_devi
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
-	val64 = readq(&bar0->rx_traffic_int);
 	writeq(val64, &bar0->rx_traffic_int);
+	writeq(val64, &bar0->tx_traffic_int);
 
+	/* we need to free up the transmitted skbufs or else netpoll will 
+	 * run out of skbs and will fail and eventually netpoll application such
+	 * as netdump will fail.
+	 */
+	for (i = 0; i < config->tx_fifo_num; i++)
+		tx_intr_handler(&mac_control->fifos[i]);
+
+	/* check for received packet and indicate up to network */
 	for (i = 0; i < config->rx_ring_num; i++)
 		rx_intr_handler(&mac_control->rings[i]);
 
@@ -3327,7 +3347,7 @@ static void s2io_reset(nic_t * sp)
 
 	/* Clear certain PCI/PCI-X fields after reset */
 	if (sp->device_type == XFRAME_II_DEVICE) {
-		/* Clear parity err detect bit */
+		/* Clear "detected parity error" bit */
 		pci_write_config_word(sp->pdev, PCI_STATUS, 0x8000);
 
 		/* Clearing PCIX Ecc status register */
@@ -4942,7 +4962,8 @@ static int write_eeprom(nic_t * sp, int 
 }
 static void s2io_vpd_read(nic_t *nic)
 {
-	u8 vpd_data[256],data;
+	u8 *vpd_data;
+	u8 data;
 	int i=0, cnt, fail = 0;
 	int vpd_addr = 0x80;
 
@@ -4955,6 +4976,10 @@ static void s2io_vpd_read(nic_t *nic)
 		vpd_addr = 0x50;
 	}
 
+	vpd_data = kmalloc(256, GFP_KERNEL);
+	if (!vpd_data)
+		return;
+
 	for (i = 0; i < 256; i +=4 ) {
 		pci_write_config_byte(nic->pdev, (vpd_addr + 2), i);
 		pci_read_config_byte(nic->pdev,  (vpd_addr + 2), &data);
@@ -4977,6 +5002,7 @@ static void s2io_vpd_read(nic_t *nic)
 		memset(nic->product_name, 0, vpd_data[1]);
 		memcpy(nic->product_name, &vpd_data[3], vpd_data[1]);
 	}
+	kfree(vpd_data);
 }
 
 /**
@@ -5295,7 +5321,7 @@ static int s2io_link_test(nic_t * sp, ui
 	else
 		*data = 0;
 
-	return 0;
+	return *data;
 }
 
 /**
@@ -6337,7 +6363,7 @@ static int s2io_card_up(nic_t * sp)
 	s2io_set_multicast(dev);
 
 	if (sp->lro) {
-		/* Initialize max aggregatable pkts based on MTU */
+		/* Initialize max aggregatable pkts per session based on MTU */
 		sp->lro_max_aggr_per_sess = ((1<<16) - 1) / dev->mtu;
 		/* Check if we can use(if specified) user provided value */
 		if (lro_max_pkts < sp->lro_max_aggr_per_sess)
@@ -6438,7 +6464,7 @@ static void s2io_tx_watchdog(struct net_
  *   @cksum : FCS checksum of the frame.
  *   @ring_no : the ring from which this RxD was extracted.
  *   Description:
- *   This function is called by the Tx interrupt serivce routine to perform
+ *   This function is called by the Rx interrupt serivce routine to perform
  *   some OS related operations on the SKB before passing it to the upper
  *   layers. It mainly checks if the checksum is OK, if so adds it to the
  *   SKBs cksum variable, increments the Rx packet count and passes the SKB
@@ -6698,33 +6724,6 @@ static void s2io_init_pci(nic_t * sp)
 	pci_read_config_word(sp->pdev, PCI_COMMAND, &pci_cmd);
 }
 
-MODULE_AUTHOR("Raghavendra Koushik <raghavendra.koushik@neterion.com>");
-MODULE_LICENSE("GPL");
-MODULE_VERSION(DRV_VERSION);
-
-module_param(tx_fifo_num, int, 0);
-module_param(rx_ring_num, int, 0);
-module_param(rx_ring_mode, int, 0);
-module_param_array(tx_fifo_len, uint, NULL, 0);
-module_param_array(rx_ring_sz, uint, NULL, 0);
-module_param_array(rts_frm_len, uint, NULL, 0);
-module_param(use_continuous_tx_intrs, int, 1);
-module_param(rmac_pause_time, int, 0);
-module_param(mc_pause_threshold_q0q3, int, 0);
-module_param(mc_pause_threshold_q4q7, int, 0);
-module_param(shared_splits, int, 0);
-module_param(tmac_util_period, int, 0);
-module_param(rmac_util_period, int, 0);
-module_param(bimodal, bool, 0);
-module_param(l3l4hdr_size, int , 0);
-#ifndef CONFIG_S2IO_NAPI
-module_param(indicate_max_pkts, int, 0);
-#endif
-module_param(rxsync_frequency, int, 0);
-module_param(intr_type, int, 0);
-module_param(lro, int, 0);
-module_param(lro_max_pkts, int, 0);
-
 static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type)
 {
 	if ( tx_fifo_num > 8) {
@@ -6832,8 +6831,8 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	}
 	if (dev_intr_type != MSI_X) {
 		if (pci_request_regions(pdev, s2io_driver_name)) {
-			DBG_PRINT(ERR_DBG, "Request Regions failed\n"),
-			    pci_disable_device(pdev);
+			DBG_PRINT(ERR_DBG, "Request Regions failed\n");
+			pci_disable_device(pdev);
 			return -ENODEV;
 		}
 	}
@@ -6957,7 +6956,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	/*  initialize the shared memory used by the NIC and the host */
 	if (init_shared_mem(sp)) {
 		DBG_PRINT(ERR_DBG, "%s: Memory allocation failed\n",
-			  __FUNCTION__);
+			  dev->name);
 		ret = -ENOMEM;
 		goto mem_alloc_failed;
 	}
@@ -7094,6 +7093,9 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	dev->addr_len = ETH_ALEN;
 	memcpy(dev->dev_addr, sp->def_mac_addr, ETH_ALEN);
 
+	/* reset Nic and bring it to known state */
+	s2io_reset(sp);
+
 	/*
 	 * Initialize the tasklet status and link state flags
 	 * and the card state parameter
@@ -7131,11 +7133,11 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		goto register_failed;
 	}
 	s2io_vpd_read(sp);
-	DBG_PRINT(ERR_DBG, "%s: Neterion %s",dev->name, sp->product_name);
-	DBG_PRINT(ERR_DBG, "(rev %d), Driver version %s\n",
-				get_xena_rev_id(sp->pdev),
-				s2io_driver_version);
 	DBG_PRINT(ERR_DBG, "Copyright(c) 2002-2005 Neterion Inc.\n");
+	DBG_PRINT(ERR_DBG, "%s: Neterion %s (rev %d)\n",dev->name,
+		  sp->product_name, get_xena_rev_id(sp->pdev));
+	DBG_PRINT(ERR_DBG, "%s: Driver version %s\n", dev->name,
+		  s2io_driver_version);
 	DBG_PRINT(ERR_DBG, "%s: MAC ADDR: "
 			  "%02x:%02x:%02x:%02x:%02x:%02x\n", dev->name,
 			  sp->def_mac_addr[0].mac_addr[0],
diff -upNr netdev/drivers/net/s2io.h bug_fixes_1/drivers/net/s2io.h
--- netdev/drivers/net/s2io.h	2006-07-14 07:58:06.000000000 -0700
+++ bug_fixes_1/drivers/net/s2io.h	2006-07-14 08:05:05.000000000 -0700
@@ -1011,4 +1011,9 @@ static void clear_lro_session(lro_t *lro
 static void queue_rx_frame(struct sk_buff *skb);
 static void update_L3L4_header(nic_t *sp, lro_t *lro);
 static void lro_append_pkt(nic_t *sp, lro_t *lro, struct sk_buff *skb, u32 tcp_len);
+
+#define S2IO_PARM_INT(X, def_val) \
+	static unsigned int X = def_val;\
+		module_param(X , uint, 0);
+
 #endif				/* _S2IO_H */

