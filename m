From: raghavendra.koushik@s2io.com
Subject: [PATCH 2.6.9-rc2 7/12] S2io: NAPI fix
Date: Mon,  8 Nov 2004 08:15:28 -0800 (PST)
Message-ID: <20041108161528.B878332914@linux.site>
Cc: ravinandan.arakali@s2io.com, raghavendra.koushik@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, romieu@fr.zoreil.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
This patch contains the following NAPI related fixes.

1. When processing Rx packets, making sure that get offset of ring does not cross the put 
   offset.

2. when NAPI is not in use a new spinlock(put_lock) is used to make sure accessing put 
   offset of ring is atomic.

3. Also introduced a new vaiable put_pos in nic_t to keep track of absolute position of the 
   put pointer of Rx ring.

4. When NAPI is used, fill_rx_buffer is not called from the interrupt handler(s2io_isr) . 

5. In s2io_poll, decrementing packets processed is done inside the while loop unlike out 
   side it as was being done last time.

Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>
Signed-off-by: Ravinandan Arakali <ravinandan.arakali@s2io.com>
---
diff -urN vanilla-linux/drivers/net/s2io.c linux-2.6.8.1/drivers/net/s2io.c
--- vanilla-linux/drivers/net/s2io.c	2004-10-11 21:19:25.051771008 -0700
+++ linux-2.6.8.1/drivers/net/s2io.c	2004-10-11 21:19:44.674787856 -0700
@@ -1565,6 +1565,9 @@
 	    atomic_read(&nic->rx_bufs_left[ring_no]);
 	mac_info_t *mac_control;
 	struct config_param *config;
+#ifndef CONFIG_S2IO_NAPI
+	unsigned long flags;
+#endif
 
 	mac_control = &nic->mac_control;
 	config = &nic->config;
@@ -1612,6 +1615,12 @@
 			DBG_PRINT(INTR_DBG, "%s: Next block at: %p\n",
 				  dev->name, rxdp);
 		}
+#ifndef CONFIG_S2IO_NAPI
+		spin_lock_irqsave(&nic->put_lock, flags);
+		nic->put_pos[ring_no] = (block_no *
+					 (MAX_RXDS_PER_BLOCK + 1)) + off;
+		spin_unlock_irqrestore(&nic->put_lock, flags);
+#endif
 
 		if (rxdp->Control_1 & RXD_OWN_XENA) {
 			mac_control->rx_curr_put_info[ring_no].
@@ -1730,8 +1739,8 @@
 	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) nic->bar0;
 	int pkts_to_process = *budget, pkt_cnt = 0;
 	register u64 val64 = 0;
-	rx_curr_get_info_t offset_info;
-	int i, block_no;
+	rx_curr_get_info_t get_info, put_info;
+	int i, get_block, put_block, get_offset, put_offset, ring_bufs;
 	u16 val16, cksum;
 	struct sk_buff *skb;
 	RxD_t *rxdp;
@@ -1748,29 +1757,40 @@
 	writeq(val64, &bar0->rx_traffic_int);
 
 	for (i = 0; i < config->rx_ring_num; i++) {
-		if (--pkts_to_process < 0) {
-			goto no_rx;
-		}
-		offset_info = mac_control->rx_curr_get_info[i];
-		block_no = offset_info.block_index;
-		rxdp = nic->rx_blocks[i][block_no].block_virt_addr +
-		    offset_info.offset;
-		while (!(rxdp->Control_1 & RXD_OWN_XENA)) {
+		get_info = mac_control->rx_curr_get_info[i];
+		get_block = get_info.block_index;
+		put_info = mac_control->rx_curr_put_info[i];
+		put_block = put_info.block_index;
+		ring_bufs = config->rx_cfg[i].num_rxd;
+		rxdp = nic->rx_blocks[i][get_block].block_virt_addr +
+		    get_info.offset;
+		get_offset = (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+		    get_info.offset;
+		put_offset = (put_block * (MAX_RXDS_PER_BLOCK + 1)) +
+		    put_info.offset;
+		while ((!(rxdp->Control_1 & RXD_OWN_XENA)) &&
+		       (((get_offset + 1) % ring_bufs) != put_offset)) {
+			if (--pkts_to_process < 0) {
+				goto no_rx;
+			}
 			if (rxdp->Control_1 == END_OF_BLOCK) {
 				rxdp =
 				    (RxD_t *) ((unsigned long) rxdp->
 					       Control_2);
-				offset_info.offset++;
-				offset_info.offset %=
+				get_info.offset++;
+				get_info.offset %=
 				    (MAX_RXDS_PER_BLOCK + 1);
-				block_no++;
-				block_no %= nic->block_count[i];
+				get_block++;
+				get_block %= nic->block_count[i];
 				mac_control->rx_curr_get_info[i].
-				    offset = offset_info.offset;
+				    offset = get_info.offset;
 				mac_control->rx_curr_get_info[i].
-				    block_index = block_no;
+				    block_index = get_block;
 				continue;
 			}
+			get_offset =
+			    (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+			    get_info.offset;
 			skb =
 			    (struct sk_buff *) ((unsigned long) rxdp->
 						Host_Control);
@@ -1778,7 +1798,7 @@
 				DBG_PRINT(ERR_DBG, "%s: The skb is ",
 					  dev->name);
 				DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");
-				return 0;
+				goto no_rx;
 			}
 			val64 = RXD_GET_BUFFER0_SIZE(rxdp->Control_2);
 			val16 = (u16) (val64 >> 48);
@@ -1792,34 +1812,44 @@
 					 PCI_DMA_FROMDEVICE);
 			rx_osm_handler(nic, val16, rxdp, i);
 			pkt_cnt++;
-			offset_info.offset++;
-			offset_info.offset %= (MAX_RXDS_PER_BLOCK + 1);
+			get_info.offset++;
+			get_info.offset %= (MAX_RXDS_PER_BLOCK + 1);
 			rxdp =
-			    nic->rx_blocks[i][block_no].block_virt_addr +
-			    offset_info.offset;
+			    nic->rx_blocks[i][get_block].block_virt_addr +
+			    get_info.offset;
 			mac_control->rx_curr_get_info[i].offset =
-			    offset_info.offset;
+			    get_info.offset;
 		}
 	}
 	if (!pkt_cnt)
 		pkt_cnt = 1;
 
-	for (i = 0; i < config->rx_ring_num; i++)
-		fill_rx_buffers(nic, i);
-
 	dev->quota -= pkt_cnt;
 	*budget -= pkt_cnt;
 	netif_rx_complete(dev);
 
+	for (i = 0; i < config->rx_ring_num; i++) {
+		if (fill_rx_buffers(nic, i) == -ENOMEM) {
+			DBG_PRINT(ERR_DBG, "%s:Out of memory", dev->name);
+			DBG_PRINT(ERR_DBG, " in Rx Poll!!\n");
+			break;
+		}
+	}
 	/* Re enable the Rx interrupts. */
 	en_dis_able_nic_intrs(nic, RX_TRAFFIC_INTR, ENABLE_INTRS);
 	return 0;
 
       no_rx:
-	for (i = 0; i < config->rx_ring_num; i++)
-		fill_rx_buffers(nic, i);
 	dev->quota -= pkt_cnt;
 	*budget -= pkt_cnt;
+
+	for (i = 0; i < config->rx_ring_num; i++) {
+		if (fill_rx_buffers(nic, i) == -ENOMEM) {
+			DBG_PRINT(ERR_DBG, "%s:Out of memory", dev->name);
+			DBG_PRINT(ERR_DBG, " in Rx Poll!!\n");
+			break;
+		}
+	}
 	return 1;
 }
 #else
@@ -1840,12 +1870,13 @@
 {
 	struct net_device *dev = (struct net_device *) nic->dev;
 	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) nic->bar0;
-	rx_curr_get_info_t offset_info;
+	rx_curr_get_info_t get_info, put_info;
 	RxD_t *rxdp;
 	struct sk_buff *skb;
 	u16 val16, cksum;
 	register u64 val64 = 0;
-	int i, block_no, pkt_cnt = 0;
+	int get_block, get_offset, put_block, put_offset, ring_bufs;
+	int i, pkt_cnt = 0;
 	mac_info_t *mac_control;
 	struct config_param *config;
 
@@ -1860,25 +1891,37 @@
 	writeq(val64, &bar0->rx_traffic_int);
 
 	for (i = 0; i < config->rx_ring_num; i++) {
-		offset_info = mac_control->rx_curr_get_info[i];
-		block_no = offset_info.block_index;
-		rxdp = nic->rx_blocks[i][block_no].block_virt_addr +
-		    offset_info.offset;
-		while (!(rxdp->Control_1 & RXD_OWN_XENA)) {
+		get_info = mac_control->rx_curr_get_info[i];
+		get_block = get_info.block_index;
+		put_info = mac_control->rx_curr_put_info[i];
+		put_block = put_info.block_index;
+		ring_bufs = config->rx_cfg[i].num_rxd;
+		rxdp = nic->rx_blocks[i][get_block].block_virt_addr +
+		    get_info.offset;
+		get_offset = (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+		    get_info.offset;
+		spin_lock(&nic->put_lock);
+		put_offset = nic->put_pos[i];
+		spin_unlock(&nic->put_lock);
+		while ((!(rxdp->Control_1 & RXD_OWN_XENA)) &&
+		       (((get_offset + 1) % ring_bufs) != put_offset)) {
 			if (rxdp->Control_1 == END_OF_BLOCK) {
 				rxdp = (RxD_t *) ((unsigned long)
 						  rxdp->Control_2);
-				offset_info.offset++;
-				offset_info.offset %=
+				get_info.offset++;
+				get_info.offset %=
 				    (MAX_RXDS_PER_BLOCK + 1);
-				block_no++;
-				block_no %= nic->block_count[i];
+				get_block++;
+				get_block %= nic->block_count[i];
 				mac_control->rx_curr_get_info[i].
-				    offset = offset_info.offset;
+				    offset = get_info.offset;
 				mac_control->rx_curr_get_info[i].
-				    block_index = block_no;
+				    block_index = get_block;
 				continue;
 			}
+			get_offset =
+			    (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+			    get_info.offset;
 			skb = (struct sk_buff *) ((unsigned long)
 						  rxdp->Host_Control);
 			if (skb == NULL) {
@@ -1898,13 +1941,13 @@
 					 HEADER_SNAP_SIZE,
 					 PCI_DMA_FROMDEVICE);
 			rx_osm_handler(nic, val16, rxdp, i);
-			offset_info.offset++;
-			offset_info.offset %= (MAX_RXDS_PER_BLOCK + 1);
+			get_info.offset++;
+			get_info.offset %= (MAX_RXDS_PER_BLOCK + 1);
 			rxdp =
-			    nic->rx_blocks[i][block_no].block_virt_addr +
-			    offset_info.offset;
+			    nic->rx_blocks[i][get_block].block_virt_addr +
+			    get_info.offset;
 			mac_control->rx_curr_get_info[i].offset =
-			    offset_info.offset;
+			    get_info.offset;
 			pkt_cnt++;
 			if ((indicate_max_pkts)
 			    && (pkt_cnt > indicate_max_pkts))
@@ -2575,6 +2618,9 @@
 	struct net_device *dev = (struct net_device *) dev_id;
 	nic_t *sp = dev->priv;
 	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+#ifndef CONFIG_S2IO_NAPI
+	int i, ret;
+#endif
 	u64 reason = 0;
 	mac_info_t *mac_control;
 	struct config_param *config;
@@ -2626,44 +2672,31 @@
 	 * reallocate the buffers from the interrupt handler itself, 
 	 * else schedule a tasklet to reallocate the buffers.
 	 */
-#if 1
-	{
-		int i;
-
-		for (i = 0; i < config->rx_ring_num; i++) {
-			int rxb_size = atomic_read(&sp->rx_bufs_left[i]);
-			int level = rx_buffer_level(sp, rxb_size, i);
-
-			if ((level == PANIC) && (!TASKLET_IN_USE)) {
-				int ret;
+#ifndef CONFIG_S2IO_NAPI
+	for (i = 0; i < config->rx_ring_num; i++) {
+		int rxb_size = atomic_read(&sp->rx_bufs_left[i]);
+		int level = rx_buffer_level(sp, rxb_size, i);
 
-				DBG_PRINT(INTR_DBG, "%s: Rx BD hit ",
+		if ((level == PANIC) && (!TASKLET_IN_USE)) {
+			DBG_PRINT(INTR_DBG, "%s: Rx BD hit ", dev->name);
+			DBG_PRINT(INTR_DBG, "PANIC levels\n");
+			if ((ret = fill_rx_buffers(sp, i)) == -ENOMEM) {
+				DBG_PRINT(ERR_DBG, "%s:Out of memory",
 					  dev->name);
-				DBG_PRINT(INTR_DBG, "PANIC levels\n");
-				if ((ret =
-				     fill_rx_buffers(sp, i)) == -ENOMEM) {
-					DBG_PRINT(ERR_DBG,
-						  "%s:Out of memory",
-						  dev->name);
-					DBG_PRINT(ERR_DBG, " in ISR!!\n");
-					clear_bit(0,
-						  (unsigned long *) (&sp->
-								     tasklet_status));
-					return IRQ_HANDLED;
-				}
+				DBG_PRINT(ERR_DBG, " in ISR!!\n");
 				clear_bit(0,
 					  (unsigned long *) (&sp->
 							     tasklet_status));
-			} else if ((level == LOW)
-				   && (!atomic_read(&sp->tasklet_status))) {
-				tasklet_schedule(&sp->task);
+				return IRQ_HANDLED;
 			}
-
+			clear_bit(0,
+				  (unsigned long *) (&sp->tasklet_status));
+		} else if ((level == LOW)
+			   && (!atomic_read(&sp->tasklet_status))) {
+			tasklet_schedule(&sp->task);
 		}
 
 	}
-#else
-	tasklet_schedule(&sp->task);
 #endif
 
 	return IRQ_HANDLED;
@@ -4583,6 +4616,9 @@
 
 	/* Initialize spinlocks */
 	spin_lock_init(&sp->tx_lock);
+#ifndef CONFIG_S2IO_NAPI
+	spin_lock_init(&sp->put_lock);
+#endif
 
 	/* 
 	 * SXE-002: Configure link and activity LED to init state 
diff -urN vanilla-linux/drivers/net/s2io.h linux-2.6.8.1/drivers/net/s2io.h
--- vanilla-linux/drivers/net/s2io.h	2004-10-11 21:19:25.051771008 -0700
+++ linux-2.6.8.1/drivers/net/s2io.h	2004-10-11 21:19:44.674787856 -0700
@@ -610,6 +610,9 @@
 	atomic_t rx_bufs_left[MAX_RX_RINGS];
 
 	spinlock_t tx_lock;
+#ifndef CONFIG_S2IO_NAPI
+	spinlock_t put_lock;
+#endif
 
 #define PROMISC     1
 #define ALL_MULTI   2
@@ -628,6 +631,11 @@
 	u16 tx_err_count;
 	u16 rx_err_count;
 
+#ifndef CONFIG_S2IO_NAPI
+	/* Index to the absolute position of the put pointer of Rx ring. */
+	int put_pos[MAX_RX_RINGS];
+#endif
+
 	/*
 	 *  Place holders for the virtual and physical addresses of 
 	 *  all the Rx Blocks
