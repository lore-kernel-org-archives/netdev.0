From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.26 4/5]S2io: Fixes for Multi ring support
Date: Wed, 23 Apr 2008 13:33:46 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10804231333020.10279-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:39496 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752823AbYDWReE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 13:34:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes for multi ring support -
	- Access respective rx ring directly in fill_rx_buffers.
	- Moved rx_bufs_left struct s2io_nic to struct ring_info.
	- Added per ring variable rxd_mode, rxd_count, dev, pdev. 

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -pNur 2.6.26_version_p123/drivers/net/s2io.c 2.6.26_version_p4/drivers/net/s2io.c
--- 2.6.26_version_p123/drivers/net/s2io.c	2008-04-21 11:33:46.000000000 -0700
+++ 2.6.26_version_p4/drivers/net/s2io.c	2008-04-15 12:07:57.000000000 -0700
@@ -2499,8 +2499,7 @@ static void stop_nic(struct s2io_nic *ni
 
 /**
  *  fill_rx_buffers - Allocates the Rx side skbs
- *  @nic:  device private variable
- *  @ring_no: ring number
+ *  @ring_info: per ring structure
  *  Description:
  *  The function allocates Rx side skbs and puts the physical
  *  address of these buffers into the RxD buffer pointers, so that the NIC
@@ -2518,103 +2517,94 @@ static void stop_nic(struct s2io_nic *ni
  *  SUCCESS on success or an appropriate -ve value on failure.
  */
 
-static int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
+static int fill_rx_buffers(struct ring_info *ring)
 {
-	struct net_device *dev = nic->dev;
 	struct sk_buff *skb;
 	struct RxD_t *rxdp;
-	int off, off1, size, block_no, block_no1;
+	int off, size, block_no, block_no1;
 	u32 alloc_tab = 0;
 	u32 alloc_cnt;
-	struct mac_info *mac_control;
-	struct config_param *config;
 	u64 tmp;
 	struct buffAdd *ba;
 	struct RxD_t *first_rxdp = NULL;
 	u64 Buffer0_ptr = 0, Buffer1_ptr = 0;
+	int rxd_index = 0;
 	struct RxD1 *rxdp1;
 	struct RxD3 *rxdp3;
-	struct swStat *stats = &nic->mac_control.stats_info->sw_stat;
+	struct swStat *stats = &ring->nic->mac_control.stats_info->sw_stat;
 
-	mac_control = &nic->mac_control;
-	config = &nic->config;
-	alloc_cnt = mac_control->rings[ring_no].pkt_cnt -
-	    atomic_read(&nic->rx_bufs_left[ring_no]);
+	alloc_cnt = ring->pkt_cnt - ring->rx_bufs_left;
 
-	block_no1 = mac_control->rings[ring_no].rx_curr_get_info.block_index;
-	off1 = mac_control->rings[ring_no].rx_curr_get_info.offset;
+	block_no1 = ring->rx_curr_get_info.block_index;
 	while (alloc_tab < alloc_cnt) {
-		block_no = mac_control->rings[ring_no].rx_curr_put_info.
-		    block_index;
-		off = mac_control->rings[ring_no].rx_curr_put_info.offset;
+		block_no = ring->rx_curr_put_info.block_index;
 
-		rxdp = mac_control->rings[ring_no].
-				rx_blocks[block_no].rxds[off].virt_addr;
+		off = ring->rx_curr_put_info.offset;
+
+		rxdp = ring->rx_blocks[block_no].rxds[off].virt_addr;
 
-		if ((block_no == block_no1) && (off == off1) &&
-					(rxdp->Host_Control)) {
+		rxd_index = off + 1;
+		if (block_no)
+			rxd_index += (block_no * ring->rxd_count);
+
+		if ((block_no == block_no1) && 
+			(off == ring->rx_curr_get_info.offset) &&
+			(rxdp->Host_Control)) {
 			DBG_PRINT(INTR_DBG, "%s: Get and Put",
-				  dev->name);
+				ring->dev->name);
 			DBG_PRINT(INTR_DBG, " info equated\n");
 			goto end;
 		}
-		if (off && (off == rxd_count[nic->rxd_mode])) {
-			mac_control->rings[ring_no].rx_curr_put_info.
-			    block_index++;
-			if (mac_control->rings[ring_no].rx_curr_put_info.
-			    block_index == mac_control->rings[ring_no].
-					block_count)
-				mac_control->rings[ring_no].rx_curr_put_info.
-					block_index = 0;
-			block_no = mac_control->rings[ring_no].
-					rx_curr_put_info.block_index;
-			if (off == rxd_count[nic->rxd_mode])
-				off = 0;
-			mac_control->rings[ring_no].rx_curr_put_info.
-				offset = off;
-			rxdp = mac_control->rings[ring_no].
-				rx_blocks[block_no].block_virt_addr;
+		if (off && (off == ring->rxd_count)) {
+			ring->rx_curr_put_info.block_index++;
+			if (ring->rx_curr_put_info.block_index ==
+							ring->block_count)
+				ring->rx_curr_put_info.block_index = 0;
+			block_no = ring->rx_curr_put_info.block_index;
+			off = 0;
+			ring->rx_curr_put_info.offset = off;
+			rxdp = ring->rx_blocks[block_no].block_virt_addr;
 			DBG_PRINT(INTR_DBG, "%s: Next block at: %p\n",
-				  dev->name, rxdp);
+				  ring->dev->name, rxdp);
+
 		}
 
 		if ((rxdp->Control_1 & RXD_OWN_XENA) &&
-			((nic->rxd_mode == RXD_MODE_3B) &&
+			((ring->rxd_mode == RXD_MODE_3B) &&
 				(rxdp->Control_2 & s2BIT(0)))) {
-			mac_control->rings[ring_no].rx_curr_put_info.
-					offset = off;
+			ring->rx_curr_put_info.offset = off;
 			goto end;
 		}
 		/* calculate size of skb based on ring mode */
-		size = dev->mtu + HEADER_ETHERNET_II_802_3_SIZE +
+		size = ring->mtu + HEADER_ETHERNET_II_802_3_SIZE +
 				HEADER_802_2_SIZE + HEADER_SNAP_SIZE;
-		if (nic->rxd_mode == RXD_MODE_1)
+		if (ring->rxd_mode == RXD_MODE_1)
 			size += NET_IP_ALIGN;
 		else
-			size = dev->mtu + ALIGN_SIZE + BUF0_LEN + 4;
+			size = ring->mtu + ALIGN_SIZE + BUF0_LEN + 4;
 
 		/* allocate skb */
 		skb = dev_alloc_skb(size);
 		if(!skb) {
-			DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
+			DBG_PRINT(INFO_DBG, "%s: Out of ", ring->dev->name);
 			DBG_PRINT(INFO_DBG, "memory to allocate SKBs\n");
 			if (first_rxdp) {
 				wmb();
 				first_rxdp->Control_1 |= RXD_OWN_XENA;
 			}
-			nic->mac_control.stats_info->sw_stat. \
-				mem_alloc_fail_cnt++;
+			stats->mem_alloc_fail_cnt++;
+				
 			return -ENOMEM ;
 		}
-		nic->mac_control.stats_info->sw_stat.mem_allocated
-			+= skb->truesize;
-		if (nic->rxd_mode == RXD_MODE_1) {
+		stats->mem_allocated += skb->truesize;
+
+		if (ring->rxd_mode == RXD_MODE_1) {
 			/* 1 buffer mode - normal operation mode */
 			rxdp1 = (struct RxD1*)rxdp;
 			memset(rxdp, 0, sizeof(struct RxD1));
 			skb_reserve(skb, NET_IP_ALIGN);
 			rxdp1->Buffer0_ptr = pci_map_single
-			    (nic->pdev, skb->data, size - NET_IP_ALIGN,
+			    (ring->pdev, skb->data, size - NET_IP_ALIGN,
 				PCI_DMA_FROMDEVICE);
 			if( (rxdp1->Buffer0_ptr == 0) ||
 				(rxdp1->Buffer0_ptr ==
@@ -2623,8 +2613,8 @@ static int fill_rx_buffers(struct s2io_n
 
 			rxdp->Control_2 =
 				SET_BUFFER0_SIZE_1(size - NET_IP_ALIGN);
-
-		} else if (nic->rxd_mode == RXD_MODE_3B) {
+			rxdp->Host_Control = (unsigned long) (skb);
+		} else if (ring->rxd_mode == RXD_MODE_3B) {
 			/*
 			 * 2 buffer mode -
 			 * 2 buffer mode provides 128
@@ -2640,7 +2630,7 @@ static int fill_rx_buffers(struct s2io_n
 			rxdp3->Buffer0_ptr = Buffer0_ptr;
 			rxdp3->Buffer1_ptr = Buffer1_ptr;
 
-			ba = &mac_control->rings[ring_no].ba[block_no][off];
+			ba = &ring->ba[block_no][off];
 			skb_reserve(skb, BUF0_LEN);
 			tmp = (u64)(unsigned long) skb->data;
 			tmp += ALIGN_SIZE;
@@ -2650,10 +2640,10 @@ static int fill_rx_buffers(struct s2io_n
 
 			if (!(rxdp3->Buffer0_ptr))
 				rxdp3->Buffer0_ptr =
-				   pci_map_single(nic->pdev, ba->ba_0, BUF0_LEN,
-					   PCI_DMA_FROMDEVICE);
+				   pci_map_single(ring->pdev, ba->ba_0,
+					BUF0_LEN, PCI_DMA_FROMDEVICE);
 			else
-				pci_dma_sync_single_for_device(nic->pdev,
+				pci_dma_sync_single_for_device(ring->pdev,
 				(dma_addr_t) rxdp3->Buffer0_ptr,
 				    BUF0_LEN, PCI_DMA_FROMDEVICE);
 			if( (rxdp3->Buffer0_ptr == 0) ||
@@ -2661,7 +2651,7 @@ static int fill_rx_buffers(struct s2io_n
 				goto pci_map_failed;
 
 			rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
-			if (nic->rxd_mode == RXD_MODE_3B) {
+			if (ring->rxd_mode == RXD_MODE_3B) {
 				/* Two buffer mode */
 
 				/*
@@ -2669,39 +2659,42 @@ static int fill_rx_buffers(struct s2io_n
 				 * L4 payload
 				 */
 				rxdp3->Buffer2_ptr = pci_map_single
-				(nic->pdev, skb->data, dev->mtu + 4,
+				(ring->pdev, skb->data, ring->mtu + 4,
 						PCI_DMA_FROMDEVICE);
 
 				if( (rxdp3->Buffer2_ptr == 0) ||
 					(rxdp3->Buffer2_ptr == DMA_ERROR_CODE))
 					goto pci_map_failed;
 
-				rxdp3->Buffer1_ptr =
-						pci_map_single(nic->pdev,
+				if (!rxdp3->Buffer1_ptr)
+					rxdp3->Buffer1_ptr =
+						pci_map_single(ring->pdev,
 						ba->ba_1, BUF1_LEN,
 						PCI_DMA_FROMDEVICE);
+
 				if( (rxdp3->Buffer1_ptr == 0) ||
 					(rxdp3->Buffer1_ptr == DMA_ERROR_CODE)) {
 					pci_unmap_single
-						(nic->pdev,
-						(dma_addr_t)rxdp3->Buffer2_ptr,
-						dev->mtu + 4,
+						(ring->pdev,
+						(dma_addr_t)(unsigned long)
+						skb->data,
+						ring->mtu + 4,
 						PCI_DMA_FROMDEVICE);
 					goto pci_map_failed;
 				}
 				rxdp->Control_2 |= SET_BUFFER1_SIZE_3(1);
 				rxdp->Control_2 |= SET_BUFFER2_SIZE_3
-								(dev->mtu + 4);
+								(ring->mtu + 4);
 			}
 			rxdp->Control_2 |= s2BIT(0);
+			rxdp->Host_Control = (unsigned long) (skb);
 		}
-		rxdp->Host_Control = (unsigned long) (skb);
 		if (alloc_tab & ((1 << rxsync_frequency) - 1))
 			rxdp->Control_1 |= RXD_OWN_XENA;
 		off++;
-		if (off == (rxd_count[nic->rxd_mode] + 1))
+		if (off == (ring->rxd_count + 1))
 			off = 0;
-		mac_control->rings[ring_no].rx_curr_put_info.offset = off;
+		ring->rx_curr_put_info.offset = off;
 
 		rxdp->Control_2 |= SET_RXD_MARKER;
 		if (!(alloc_tab & ((1 << rxsync_frequency) - 1))) {
@@ -2711,7 +2704,7 @@ static int fill_rx_buffers(struct s2io_n
 			}
 			first_rxdp = rxdp;
 		}
-		atomic_inc(&nic->rx_bufs_left[ring_no]);
+		ring->rx_bufs_left += 1;
 		alloc_tab++;
 	}
 
@@ -2783,7 +2776,7 @@ static void free_rxd_blk(struct s2io_nic
 		}
 		sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
 		dev_kfree_skb(skb);
-		atomic_dec(&sp->rx_bufs_left[ring_no]);
+		mac_control->rings[ring_no].rx_bufs_left -= 1;
 	}
 }
 
@@ -2814,7 +2807,7 @@ static void free_rx_buffers(struct s2io_
 		mac_control->rings[i].rx_curr_get_info.block_index = 0;
 		mac_control->rings[i].rx_curr_put_info.offset = 0;
 		mac_control->rings[i].rx_curr_get_info.offset = 0;
-		atomic_set(&sp->rx_bufs_left[i], 0);
+		mac_control->rings[i].rx_bufs_left = 0;
 		DBG_PRINT(INIT_DBG, "%s:Freed 0x%x Rx Buffers on ring%d\n",
 			  dev->name, buf_cnt, i);
 	}
@@ -2864,7 +2857,7 @@ static int s2io_poll(struct napi_struct 
 	netif_rx_complete(dev, napi);
 
 	for (i = 0; i < config->rx_ring_num; i++) {
-		if (fill_rx_buffers(nic, i) == -ENOMEM) {
+		if (fill_rx_buffers(&mac_control->rings[i]) == -ENOMEM) {
 			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
 			DBG_PRINT(INFO_DBG, " in Rx Poll!!\n");
 			break;
@@ -2877,7 +2870,7 @@ static int s2io_poll(struct napi_struct 
 
 no_rx:
 	for (i = 0; i < config->rx_ring_num; i++) {
-		if (fill_rx_buffers(nic, i) == -ENOMEM) {
+		if (fill_rx_buffers(&mac_control->rings[i]) == -ENOMEM) {
 			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
 			DBG_PRINT(INFO_DBG, " in Rx Poll!!\n");
 			break;
@@ -2928,7 +2921,7 @@ static void s2io_netpoll(struct net_devi
 		rx_intr_handler(&mac_control->rings[i]);
 
 	for (i = 0; i < config->rx_ring_num; i++) {
-		if (fill_rx_buffers(nic, i) == -ENOMEM) {
+		if (fill_rx_buffers(&mac_control->rings[i]) == -ENOMEM) {
 			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
 			DBG_PRINT(INFO_DBG, " in Rx Netpoll!!\n");
 			break;
@@ -2953,8 +2946,6 @@ static void s2io_netpoll(struct net_devi
  */
 static void rx_intr_handler(struct ring_info *ring_data)
 {
-	struct s2io_nic *nic = ring_data->nic;
-	struct net_device *dev = (struct net_device *) nic->dev;
 	int get_block, put_block;
 	struct rx_curr_get_info get_info, put_info;
 	struct RxD_t *rxdp;
@@ -2977,33 +2968,34 @@ static void rx_intr_handler(struct ring_
 		 */
 		if ((get_block == put_block) &&
 		    (get_info.offset + 1) == put_info.offset) {
-			DBG_PRINT(INTR_DBG, "%s: Ring Full\n",dev->name);
+			DBG_PRINT(INTR_DBG, "%s: Ring Full\n",
+				ring_data->dev->name);
 			break;
 		}
 		skb = (struct sk_buff *) ((unsigned long)rxdp->Host_Control);
 		if (skb == NULL) {
 			DBG_PRINT(ERR_DBG, "%s: The skb is ",
-				  dev->name);
+				  ring_data->dev->name);
 			DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");
 			return;
 		}
-		if (nic->rxd_mode == RXD_MODE_1) {
+		if (ring_data->rxd_mode == RXD_MODE_1) {
 			rxdp1 = (struct RxD1*)rxdp;
-			pci_unmap_single(nic->pdev, (dma_addr_t)
+			pci_unmap_single(ring_data->pdev, (dma_addr_t)
 				rxdp1->Buffer0_ptr,
-				dev->mtu +
+				ring_data->mtu +
 				HEADER_ETHERNET_II_802_3_SIZE +
 				HEADER_802_2_SIZE +
 				HEADER_SNAP_SIZE,
 				PCI_DMA_FROMDEVICE);
-		} else if (nic->rxd_mode == RXD_MODE_3B) {
+		} else if (ring_data->rxd_mode == RXD_MODE_3B) {
 			rxdp3 = (struct RxD3*)rxdp;
-			pci_dma_sync_single_for_cpu(nic->pdev, (dma_addr_t)
+			pci_dma_sync_single_for_cpu(ring_data->pdev, (dma_addr_t)
 				rxdp3->Buffer0_ptr,
 				BUF0_LEN, PCI_DMA_FROMDEVICE);
-			pci_unmap_single(nic->pdev, (dma_addr_t)
+			pci_unmap_single(ring_data->pdev, (dma_addr_t)
 				rxdp3->Buffer2_ptr,
-				dev->mtu + 4,
+				ring_data->mtu + 4,
 				PCI_DMA_FROMDEVICE);
 		}
 		prefetch(skb->data);
@@ -3012,7 +3004,7 @@ static void rx_intr_handler(struct ring_
 		ring_data->rx_curr_get_info.offset = get_info.offset;
 		rxdp = ring_data->rx_blocks[get_block].
 				rxds[get_info.offset].virt_addr;
-		if (get_info.offset == rxd_count[nic->rxd_mode]) {
+		if (get_info.offset == rxd_count[ring_data->rxd_mode]) {
 			get_info.offset = 0;
 			ring_data->rx_curr_get_info.offset = get_info.offset;
 			get_block++;
@@ -3022,9 +3014,11 @@ static void rx_intr_handler(struct ring_
 			rxdp = ring_data->rx_blocks[get_block].block_virt_addr;
 		}
 
-		nic->pkts_to_process -= 1;
-		if ((napi) && (!nic->pkts_to_process))
-			break;
+		if(ring_data->nic->config.napi){
+			ring_data->nic->pkts_to_process -= 1;
+			if (!ring_data->nic->pkts_to_process)
+				break;
+		}
 		pkt_cnt++;
 		if ((indicate_max_pkts) && (pkt_cnt > indicate_max_pkts))
 			break;
@@ -3034,7 +3028,7 @@ static void rx_intr_handler(struct ring_
 		for (i=0; i<MAX_LRO_SESSIONS; i++) {
 			struct lro *lro = &ring_data->lro0_n[i];
 			if (lro->in_use) {
-				update_L3L4_header(nic, lro);
+				update_L3L4_header(ring_data->nic, lro);
 				queue_rx_frame(lro->parent, lro->vlan_tag);
 				clear_lro_session(lro);
 			}
@@ -4333,10 +4327,10 @@ s2io_alarm_handle(unsigned long data)
 	mod_timer(&sp->alarm_timer, jiffies + HZ / 2);
 }
 
-static int s2io_chk_rx_buffers(struct s2io_nic *sp, int rng_n)
+static int s2io_chk_rx_buffers(struct ring_info *ring)
 {
-	if (fill_rx_buffers(sp, rng_n) == -ENOMEM) {
-		DBG_PRINT(INFO_DBG, "%s:Out of memory", sp->dev->name);
+	if (fill_rx_buffers(ring) == -ENOMEM) {
+		DBG_PRINT(INFO_DBG, "%s:Out of memory", ring->dev->name);
 		DBG_PRINT(INFO_DBG, " in Rx Intr!!\n");
 	}
 	return 0;
@@ -4351,7 +4345,7 @@ static irqreturn_t s2io_msix_ring_handle
 		return IRQ_HANDLED;
 
 	rx_intr_handler(ring);
-	s2io_chk_rx_buffers(sp, ring->ring_no);
+	s2io_chk_rx_buffers(ring);
 
 	return IRQ_HANDLED;
 }
@@ -4809,7 +4803,7 @@ static irqreturn_t s2io_isr(int irq, voi
 		 */
 		if (!config->napi) {
 			for (i = 0; i < config->rx_ring_num; i++)
-				s2io_chk_rx_buffers(sp, i);
+				s2io_chk_rx_buffers(&mac_control->rings[i]);
 		}
 		writeq(sp->general_int_mask, &bar0->general_int_mask);
 		readl(&bar0->general_int_status);
@@ -7165,7 +7159,9 @@ static int s2io_card_up(struct s2io_nic 
 	config = &sp->config;
 
 	for (i = 0; i < config->rx_ring_num; i++) {
-		if ((ret = fill_rx_buffers(sp, i))) {
+		mac_control->rings[i].mtu = dev->mtu;
+		ret = fill_rx_buffers(&mac_control->rings[i]);
+		if (ret) {
 			DBG_PRINT(ERR_DBG, "%s: Out of memory in Open\n",
 				  dev->name);
 			s2io_reset(sp);
@@ -7173,7 +7169,7 @@ static int s2io_card_up(struct s2io_nic 
 			return -ENOMEM;
 		}
 		DBG_PRINT(INFO_DBG, "Buf in ring:%d is %d:\n", i,
-			  atomic_read(&sp->rx_bufs_left[i]));
+			  mac_control->rings[i].rx_bufs_left);
 	}
 
 	/* Initialise napi */
@@ -7308,7 +7304,7 @@ static void s2io_tx_watchdog(struct net_
 static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 {
 	struct s2io_nic *sp = ring_data->nic;
-	struct net_device *dev = (struct net_device *) sp->dev;
+	struct net_device *dev = (struct net_device *) ring_data->dev;
 	struct sk_buff *skb = (struct sk_buff *)
 		((unsigned long) rxdp->Host_Control);
 	int ring_no = ring_data->ring_no;
@@ -7385,7 +7381,7 @@ static int rx_osm_handler(struct ring_in
 			sp->mac_control.stats_info->sw_stat.mem_freed
 				+= skb->truesize;
 			dev_kfree_skb(skb);
-			atomic_dec(&sp->rx_bufs_left[ring_no]);
+			ring_data->rx_bufs_left -= 1;
 			rxdp->Host_Control = 0;
 			return 0;
 		}
@@ -7494,7 +7490,7 @@ send_up:
 	queue_rx_frame(skb, RXD_GET_VLAN_TAG(rxdp->Control_2));
 	dev->last_rx = jiffies;
 aggregate:
-	atomic_dec(&sp->rx_bufs_left[ring_no]);
+	sp->mac_control.rings[ring_no].rx_bufs_left -= 1;
 	return SUCCESS;
 }
 
@@ -7846,10 +7842,15 @@ s2io_init_nic(struct pci_dev *pdev, cons
 
 	/* Rx side parameters. */
 	config->rx_ring_num = rx_ring_num;
-	for (i = 0; i < MAX_RX_RINGS; i++) {
+	for (i = 0; i < config->rx_ring_num; i++) {
 		config->rx_cfg[i].num_rxd = rx_ring_sz[i] *
 		    (rxd_count[sp->rxd_mode] + 1);
 		config->rx_cfg[i].ring_priority = i;
+		mac_control->rings[i].rx_bufs_left = 0;
+		mac_control->rings[i].rxd_mode = sp->rxd_mode;
+		mac_control->rings[i].rxd_count = rxd_count[sp->rxd_mode];
+		mac_control->rings[i].pdev = sp->pdev;
+		mac_control->rings[i].dev = sp->dev;
 	}
 
 	for (i = 0; i < rx_ring_num; i++) {
@@ -7864,10 +7865,6 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	mac_control->mc_pause_threshold_q4q7 = mc_pause_threshold_q4q7;
 
 
-	/* Initialize Ring buffer parameters. */
-	for (i = 0; i < config->rx_ring_num; i++)
-		atomic_set(&sp->rx_bufs_left[i], 0);
-
 	/*  initialize the shared memory used by the NIC and the host */
 	if (init_shared_mem(sp)) {
 		DBG_PRINT(ERR_DBG, "%s: Memory allocation failed\n",
diff -pNur 2.6.26_version_p123/drivers/net/s2io.h 2.6.26_version_p4/drivers/net/s2io.h
--- 2.6.26_version_p123/drivers/net/s2io.h	2008-04-21 11:33:46.000000000 -0700
+++ 2.6.26_version_p4/drivers/net/s2io.h	2008-04-14 23:33:05.000000000 -0700
@@ -703,10 +703,28 @@ struct ring_info {
 	/* The ring number */
 	int ring_no;
 
-#define MAX_LRO_SESSIONS	32
+	/* per-ring buffer counter */
+	u32 rx_bufs_left;
+
+	#define MAX_LRO_SESSIONS	32
 	struct lro lro0_n[MAX_LRO_SESSIONS];
 	u8		lro;
 
+	/* copy of sp->rxd_mode flag */
+	int rxd_mode;
+
+	/* Number of rxds per block for the rxd_mode */
+	int rxd_count;
+
+	/* copy of sp pointer */
+	struct s2io_nic *nic;
+
+	/* copy of sp->dev pointer */
+	struct net_device *dev;
+
+	/* copy of sp->pdev pointer */
+	struct pci_dev *pdev;
+
 	/*
 	 *  Place holders for the virtual and physical addresses of
 	 *  all the Rx Blocks
@@ -727,9 +745,11 @@ struct ring_info {
 	 */
 	struct rx_curr_get_info rx_curr_get_info;
 
+	/* interface MTU value */
+        unsigned mtu;
+    
 	/* Buffer Address store. */
 	struct buffAdd **ba;
-	struct s2io_nic *nic;
 
 	/* per-Ring statistics */
 	unsigned long rx_packets;
@@ -880,8 +900,6 @@ struct s2io_nic {
 	/* Space to back up the PCI config space */
 	u32 config_space[256 / sizeof(u32)];
 
-	atomic_t rx_bufs_left[MAX_RX_RINGS];
-
 #define PROMISC     1
 #define ALL_MULTI   2
 

