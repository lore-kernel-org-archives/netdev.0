From: Ananda Raju <Ananda.Raju@neterion.com>
Subject: [patch 1/5] s2io driver updates
Date: Fri, 21 Apr 2006 19:03:13 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10604211900320.15266-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, ravinandan.arakali@neterion.com,
	rapuru.sriram@neterion.com, alicia.pena@neterion.com,
	ananda.raju@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:53194 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1750714AbWDUXDR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 19:03:17 -0400
To: jgarzik@pobox.com, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi,
	This patch contains all the changes that were done to improve 
	performance of s2io driver. one line  description of the changes 
	are 

	1. For Non NAPI case the rx interrupt handler is being called 
	   unconditionally
	2. code optimization and adding prefetch skb->data
	3. Remove modulo operations in fast path
	4. Enable Group Reads and set backoff interval to 0x1000
	5. correct PIC_CNTL_SHARED_SPLITS  macro definition, and reduce 
	   pause parameter
	6. Corrected logic of identifying rx buffer level in rx_buffer_level()
	7. fix DMA map and unmap done with different sizes in 1-buf mode
	8. Removed forcible disabling of ERO
	9. Send up the packets with transfer code = 0x5

Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
---
diff -upNr netdev/drivers/net/s2io-regs.h perf_fixes/drivers/net/s2io-regs.h
--- netdev/drivers/net/s2io-regs.h	2006-04-13 06:47:17.000000000 -0700
+++ perf_fixes/drivers/net/s2io-regs.h	2006-04-13 06:48:16.000000000 -0700
@@ -187,7 +187,7 @@ typedef struct _XENA_dev_config {
 /* PIC Control registers */
 	u64 pic_control;
 #define PIC_CNTL_RX_ALARM_MAP_1                BIT(0)
-#define PIC_CNTL_SHARED_SPLITS(n)              vBIT(n,11,4)
+#define PIC_CNTL_SHARED_SPLITS(n)              vBIT(n,11,5)
 
 	u64 swapper_ctrl;
 #define SWAPPER_CTRL_PIF_R_FE                  BIT(0)
@@ -284,9 +284,13 @@ typedef struct _XENA_dev_config {
 	u64 gpio_control;
 #define GPIO_CTRL_GPIO_0		BIT(8)
 	u64 misc_control;
+#define EXT_REQ_EN			BIT(1)
 #define MISC_LINK_STABILITY_PRD(val)   vBIT(val,29,3)
 
-	u8 unused7_1[0x240 - 0x208];
+	u8 unused7_1[0x230 - 0x208];
+
+	u64 pic_control2;
+	u64 ini_dperr_ctrl;
 
 	u64 wreq_split_mask;
 #define	WREQ_SPLIT_MASK_SET_MASK(val)	vBIT(val, 52, 12)
@@ -493,6 +497,7 @@ typedef struct _XENA_dev_config {
 #define PRC_CTRL_NO_SNOOP_DESC                 BIT(22)
 #define PRC_CTRL_NO_SNOOP_BUFF                 BIT(23)
 #define PRC_CTRL_BIMODAL_INTERRUPT             BIT(37)
+#define PRC_CTRL_GROUP_READS                   BIT(38)
 #define PRC_CTRL_RXD_BACKOFF_INTERVAL(val)     vBIT(val,40,24)
 
 	u64 prc_alarm_action;
diff -upNr netdev/drivers/net/s2io.c perf_fixes/drivers/net/s2io.c
--- netdev/drivers/net/s2io.c	2006-04-13 06:47:17.000000000 -0700
+++ perf_fixes/drivers/net/s2io.c	2006-04-13 08:02:56.000000000 -0700
@@ -106,18 +106,14 @@ static inline int RXD_IS_UP2DT(RxD_t *rx
 #define LOW	2
 static inline int rx_buffer_level(nic_t * sp, int rxb_size, int ring)
 {
-	int level = 0;
 	mac_info_t *mac_control;
 
 	mac_control = &sp->mac_control;
-	if ((mac_control->rings[ring].pkt_cnt - rxb_size) > 16) {
-		level = LOW;
-		if (rxb_size <= rxd_count[sp->rxd_mode]) {
-			level = PANIC;
-		}
-	}
-
-	return level;
+	if (rxb_size <= rxd_count[sp->rxd_mode])
+		return PANIC;
+	else if ((mac_control->rings[ring].pkt_cnt - rxb_size) > 16)
+		return  LOW;
+	return 0;
 }
 
 /* Ethtool related variables and Macros. */
@@ -311,7 +307,7 @@ static unsigned int rts_frm_len[MAX_RX_R
     {[0 ...(MAX_RX_RINGS - 1)] = 0 };
 static unsigned int rx_ring_mode = 1;
 static unsigned int use_continuous_tx_intrs = 1;
-static unsigned int rmac_pause_time = 65535;
+static unsigned int rmac_pause_time = 0x100;
 static unsigned int mc_pause_threshold_q0q3 = 187;
 static unsigned int mc_pause_threshold_q4q7 = 187;
 static unsigned int shared_splits;
@@ -1545,13 +1541,22 @@ static int init_nic(struct s2io_nic *nic
 	val64 |= PIC_CNTL_SHARED_SPLITS(shared_splits);
 	writeq(val64, &bar0->pic_control);
 
+	if (nic->config.bus_speed == 266) {
+		writeq(TXREQTO_VAL(0x7f) | TXREQTO_EN, &bar0->txreqtimeout);
+		writeq(0x0, &bar0->read_retry_delay);
+		writeq(0x0, &bar0->write_retry_delay);
+	}
+
 	/*
 	 * Programming the Herc to split every write transaction
 	 * that does not start on an ADB to reduce disconnects.
 	 */
 	if (nic->device_type == XFRAME_II_DEVICE) {
-		val64 = WREQ_SPLIT_MASK_SET_MASK(255);
-		writeq(val64, &bar0->wreq_split_mask);
+		val64 = EXT_REQ_EN | MISC_LINK_STABILITY_PRD(3);
+		writeq(val64, &bar0->misc_control);
+		val64 = readq(&bar0->pic_control2);
+		val64 &= ~(BIT(13)|BIT(14)|BIT(15));
+		writeq(val64, &bar0->pic_control2);
 	}
 
 	/* Setting Link stability period to 64 ms */ 
@@ -1948,6 +1953,10 @@ static int start_nic(struct s2io_nic *ni
 			val64 |= PRC_CTRL_RC_ENABLED;
 		else
 			val64 |= PRC_CTRL_RC_ENABLED | PRC_CTRL_RING_MODE_3;
+		if (nic->device_type == XFRAME_II_DEVICE)
+			val64 |= PRC_CTRL_GROUP_READS;
+		val64 &= ~PRC_CTRL_RXD_BACKOFF_INTERVAL(0xFFFFFF);
+		val64 |= PRC_CTRL_RXD_BACKOFF_INTERVAL(0x1000);
 		writeq(val64, &bar0->prc_ctrl_n[i]);
 	}
 
@@ -2231,13 +2240,12 @@ static int fill_rx_buffers(struct s2io_n
 	alloc_cnt = mac_control->rings[ring_no].pkt_cnt -
 	    atomic_read(&nic->rx_bufs_left[ring_no]);
 
+	block_no1 = mac_control->rings[ring_no].rx_curr_get_info.block_index;
+	off1 = mac_control->rings[ring_no].rx_curr_get_info.offset;
 	while (alloc_tab < alloc_cnt) {
 		block_no = mac_control->rings[ring_no].rx_curr_put_info.
 		    block_index;
-		block_no1 = mac_control->rings[ring_no].rx_curr_get_info.
-		    block_index;
 		off = mac_control->rings[ring_no].rx_curr_put_info.offset;
-		off1 = mac_control->rings[ring_no].rx_curr_get_info.offset;
 
 		rxdp = mac_control->rings[ring_no].
 				rx_blocks[block_no].rxds[off].virt_addr;
@@ -2307,9 +2315,9 @@ static int fill_rx_buffers(struct s2io_n
 			memset(rxdp, 0, sizeof(RxD1_t));
 			skb_reserve(skb, NET_IP_ALIGN);
 			((RxD1_t*)rxdp)->Buffer0_ptr = pci_map_single
-			    (nic->pdev, skb->data, size, PCI_DMA_FROMDEVICE);
-			rxdp->Control_2 &= (~MASK_BUFFER0_SIZE_1);
-			rxdp->Control_2 |= SET_BUFFER0_SIZE_1(size);
+			    (nic->pdev, skb->data, size - NET_IP_ALIGN,
+				PCI_DMA_FROMDEVICE);
+			rxdp->Control_2 = SET_BUFFER0_SIZE_1(size - NET_IP_ALIGN);
 
 		} else if (nic->rxd_mode >= RXD_MODE_3A) {
 			/*
@@ -2516,7 +2524,7 @@ static int s2io_poll(struct net_device *
 	mac_info_t *mac_control;
 	struct config_param *config;
 	XENA_dev_config_t __iomem *bar0 = nic->bar0;
-	u64 val64;
+	u64 val64 = 0xFFFFFFFFFFFFFFFFULL;
 	int i;
 
 	atomic_inc(&nic->isr_cnt);
@@ -2528,8 +2536,8 @@ static int s2io_poll(struct net_device *
 		nic->pkts_to_process = dev->quota;
 	org_pkts_to_process = nic->pkts_to_process;
 
-	val64 = readq(&bar0->rx_traffic_int);
 	writeq(val64, &bar0->rx_traffic_int);
+	val64 = readl(&bar0->rx_traffic_int);
 
 	for (i = 0; i < config->rx_ring_num; i++) {
 		rx_intr_handler(&mac_control->rings[i]);
@@ -2666,6 +2674,7 @@ static void rx_intr_handler(ring_info_t 
 					 ((RxD3_t*)rxdp)->Buffer2_ptr,
 					 dev->mtu, PCI_DMA_FROMDEVICE);
 		}
+		prefetch(skb->data);
 		rx_osm_handler(ring_data, rxdp);
 		get_info.offset++;
 		ring_data->rx_curr_get_info.offset = get_info.offset;
@@ -2760,7 +2769,8 @@ to loss of link\n");
 		dev_kfree_skb_irq(skb);
 
 		get_info.offset++;
-		get_info.offset %= get_info.fifo_len + 1;
+		if (get_info.offset == get_info.fifo_len + 1)
+			get_info.offset = 0;
 		txdlp = (TxD_t *) fifo_data->list_info
 		    [get_info.offset].list_virt_addr;
 		fifo_data->tx_curr_get_info.offset =
@@ -3545,7 +3555,8 @@ static int s2io_xmit(struct sk_buff *skb
 
 	queue_len = mac_control->fifos[queue].tx_curr_put_info.fifo_len + 1;
 	/* Avoid "put" pointer going beyond "get" pointer */
-	if (txdp->Host_Control || (((put_off + 1) % queue_len) == get_off)) {
+	if (txdp->Host_Control ||
+		   ((put_off+1) == queue_len ? 0 : (put_off+1)) == get_off) {
 		DBG_PRINT(TX_DBG, "Error in xmit, No free TXDs.\n");
 		netif_stop_queue(dev);
 		dev_kfree_skb(skb);
@@ -3655,11 +3666,12 @@ static int s2io_xmit(struct sk_buff *skb
 	mmiowb();
 
 	put_off++;
-	put_off %= mac_control->fifos[queue].tx_curr_put_info.fifo_len + 1;
+	if (put_off == mac_control->fifos[queue].tx_curr_put_info.fifo_len + 1)
+		put_off = 0;
 	mac_control->fifos[queue].tx_curr_put_info.offset = put_off;
 
 	/* Avoid "put" pointer going beyond "get" pointer */
-	if (((put_off + 1) % queue_len) == get_off) {
+	if (((put_off+1) == queue_len ? 0 : (put_off+1)) == get_off) {
 		DBG_PRINT(TX_DBG,
 			  "No free TxDs for xmit, Put: 0x%x Get:0x%x\n",
 			  put_off, get_off);
@@ -3887,43 +3899,37 @@ static irqreturn_t s2io_isr(int irq, voi
 		return IRQ_NONE;
 	}
 
+	val64 = 0xFFFFFFFFFFFFFFFFULL;
 #ifdef CONFIG_S2IO_NAPI
 	if (reason & GEN_INTR_RXTRAFFIC) {
 		if (netif_rx_schedule_prep(dev)) {
-			en_dis_able_nic_intrs(sp, RX_TRAFFIC_INTR,
-					      DISABLE_INTRS);
+			writeq(val64, &bar0->rx_traffic_mask);
 			__netif_rx_schedule(dev);
 		}
 	}
 #else
-	/* If Intr is because of Rx Traffic */
-	if (reason & GEN_INTR_RXTRAFFIC) {
-		/*
-		 * rx_traffic_int reg is an R1 register, writing all 1's
-		 * will ensure that the actual interrupt causing bit get's
-		 * cleared and hence a read can be avoided.
-		 */
-		val64 = 0xFFFFFFFFFFFFFFFFULL;
-		writeq(val64, &bar0->rx_traffic_int);
-		for (i = 0; i < config->rx_ring_num; i++) {
-			rx_intr_handler(&mac_control->rings[i]);
-		}
+	/*
+	 * Rx handler is called by default, without checking for the
+	 * cause of interrupt.
+	 * rx_traffic_int reg is an R1 register, writing all 1's
+	 * will ensure that the actual interrupt causing bit get's
+	 * cleared and hence a read can be avoided.
+	 */
+	writeq(val64, &bar0->rx_traffic_int);
+	for (i = 0; i < config->rx_ring_num; i++) {
+		rx_intr_handler(&mac_control->rings[i]);
 	}
 #endif
 
-	/* If Intr is because of Tx Traffic */
-	if (reason & GEN_INTR_TXTRAFFIC) {
-		/*
-		 * tx_traffic_int reg is an R1 register, writing all 1's
-		 * will ensure that the actual interrupt causing bit get's
-		 * cleared and hence a read can be avoided.
-		 */
-		val64 = 0xFFFFFFFFFFFFFFFFULL;
-		writeq(val64, &bar0->tx_traffic_int);
+	/*
+	 * tx_traffic_int reg is an R1 register, writing all 1's
+	 * will ensure that the actual interrupt causing bit get's
+	 * cleared and hence a read can be avoided.
+	 */
+	writeq(val64, &bar0->tx_traffic_int);
 
-		for (i = 0; i < config->tx_fifo_num; i++)
-			tx_intr_handler(&mac_control->fifos[i]);
-	}
+	for (i = 0; i < config->tx_fifo_num; i++)
+		tx_intr_handler(&mac_control->fifos[i]);
 
 	if (reason & GEN_INTR_TXPIC)
 		s2io_txpic_intr_handle(sp);
@@ -5695,18 +5701,27 @@ static int rx_osm_handler(ring_info_t *r
 		((unsigned long) rxdp->Host_Control);
 	int ring_no = ring_data->ring_no;
 	u16 l3_csum, l4_csum;
+	unsigned long long err = rxdp->Control_1 & RXD_T_CODE;
 	lro_t *lro;
 
 	skb->dev = dev;
-	if (rxdp->Control_1 & RXD_T_CODE) {
-		unsigned long long err = rxdp->Control_1 & RXD_T_CODE;
-		DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%llx\n",
-			  dev->name, err);
-		dev_kfree_skb(skb);
-		sp->stats.rx_crc_errors++;
-		atomic_dec(&sp->rx_bufs_left[ring_no]);
-		rxdp->Host_Control = 0;
-		return 0;
+	if (err) {
+		/*
+		* Drop the packet if bad transfer code. Exception being
+		* 0x5, which could be due to unsupported IPv6 extension header.
+		* In this case, we let stack handle the packet.
+		* Note that in this case, since checksum will be incorrect,
+		* stack will validate the same.
+		*/
+		if (err && ((err >> 48) != 0x5)) {
+			DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%llx\n",
+				dev->name, err);
+			sp->stats.rx_crc_errors++;
+			dev_kfree_skb(skb);
+			atomic_dec(&sp->rx_bufs_left[ring_no]);
+			rxdp->Host_Control = 0;
+			return 0;
+		}
 	}
 
 	/* Updating statistics */
@@ -5918,13 +5933,6 @@ static void s2io_init_pci(nic_t * sp)
 	pci_write_config_word(sp->pdev, PCI_COMMAND,
 			      (pci_cmd | PCI_COMMAND_PARITY));
 	pci_read_config_word(sp->pdev, PCI_COMMAND, &pci_cmd);
-
-	/* Forcibly disabling relaxed ordering capability of the card. */
-	pcix_cmd &= 0xfffd;
-	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
-			      pcix_cmd);
-	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
-			     &(pcix_cmd));
 }
 
 MODULE_AUTHOR("Raghavendra Koushik <raghavendra.koushik@neterion.com>");

