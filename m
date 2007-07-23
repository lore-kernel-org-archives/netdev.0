From: Veena Parat <Veena.Parat@neterion.com>
Subject: [PATCH 2.6.22 1/4]S2IO: Removing 3 buffer mode support from the
 driver
Date: Mon, 23 Jul 2007 02:20:51 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10707230219300.2793-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:55800 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756068AbXGWGU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 02:20:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 - Removed 3 buffer mode support from driver - unused feature
 - Incorporated Jeff Garzik's comments on elimination of inline typecasting
 - Code cleanup : Removed a few extra spaces

Signed-off-by: Veena Parat <veena.parat@neterion.com>
---
diff -urpN org/drivers/net/s2io.c patch_1/drivers/net/s2io.c
--- org/drivers/net/s2io.c	2007-07-17 15:05:49.000000000 +0530
+++ patch_1/drivers/net/s2io.c	2007-07-19 14:20:53.000000000 +0530
@@ -32,7 +32,7 @@
  * rx_ring_sz: This defines the number of receive blocks each ring can have.
  *     This is also an array of size 8.
  * rx_ring_mode: This defines the operation mode of all 8 rings. The valid
- *		values are 1, 2 and 3.
+ *		values are 1, 2.
  * tx_fifo_num: This defines the number of Tx FIFOs thats used int the driver.
  * tx_fifo_len: This too is an array of 8. Each element defines the number of
  * Tx descriptors that can be associated with each corresponding FIFO.
@@ -90,8 +90,8 @@
 static char s2io_driver_name[] = "Neterion";
 static char s2io_driver_version[] = DRV_VERSION;
 
-static int rxd_size[4] = {32,48,48,64};
-static int rxd_count[4] = {127,85,85,63};
+static int rxd_size[2] = {32,48};
+static int rxd_count[2] = {127,85};
 
 static inline int RXD_IS_UP2DT(struct RxD_t *rxdp)
 {
@@ -701,7 +701,7 @@ static int init_shared_mem(struct s2io_n
 			    (u64) tmp_p_addr_next;
 		}
 	}
-	if (nic->rxd_mode >= RXD_MODE_3A) {
+	if (nic->rxd_mode == RXD_MODE_3B) {
 		/*
 		 * Allocation of Storages for buffer addresses in 2BUFF mode
 		 * and the buffers as well.
@@ -870,7 +870,7 @@ static void free_shared_mem(struct s2io_
 		}
 	}
 
-	if (nic->rxd_mode >= RXD_MODE_3A) {
+	if (nic->rxd_mode == RXD_MODE_3B) {
 		/* Freeing buffer storage addresses in 2BUFF mode. */
 		for (i = 0; i < config->rx_ring_num; i++) {
 			blk_cnt = config->rx_cfg[i].num_rxd /
@@ -2233,44 +2233,6 @@ static void stop_nic(struct s2io_nic *ni
 	writeq(val64, &bar0->adapter_control);
 }
 
-static int fill_rxd_3buf(struct s2io_nic *nic, struct RxD_t *rxdp, struct \
-				sk_buff *skb)
-{
-	struct net_device *dev = nic->dev;
-	struct sk_buff *frag_list;
-	void *tmp;
-
-	/* Buffer-1 receives L3/L4 headers */
-	((struct RxD3*)rxdp)->Buffer1_ptr = pci_map_single
-			(nic->pdev, skb->data, l3l4hdr_size + 4,
-			PCI_DMA_FROMDEVICE);
-
-	/* skb_shinfo(skb)->frag_list will have L4 data payload */
-	skb_shinfo(skb)->frag_list = dev_alloc_skb(dev->mtu + ALIGN_SIZE);
-	if (skb_shinfo(skb)->frag_list == NULL) {
-		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
-		DBG_PRINT(INFO_DBG, "%s: dev_alloc_skb failed\n ", dev->name);
-		return -ENOMEM ;
-	}
-	frag_list = skb_shinfo(skb)->frag_list;
-	skb->truesize += frag_list->truesize;
-	nic->mac_control.stats_info->sw_stat.mem_allocated 
-		+= frag_list->truesize;
-	frag_list->next = NULL;
-	tmp = (void *)ALIGN((long)frag_list->data, ALIGN_SIZE + 1);
-	frag_list->data = tmp;
-	skb_reset_tail_pointer(frag_list);
-
-	/* Buffer-2 receives L4 data payload */
-	((struct RxD3*)rxdp)->Buffer2_ptr = pci_map_single(nic->pdev,
-				frag_list->data, dev->mtu,
-				PCI_DMA_FROMDEVICE);
-	rxdp->Control_2 |= SET_BUFFER1_SIZE_3(l3l4hdr_size + 4);
-	rxdp->Control_2 |= SET_BUFFER2_SIZE_3(dev->mtu);
-
-	return SUCCESS;
-}
-
 /**
  *  fill_rx_buffers - Allocates the Rx side skbs
  *  @nic:  device private variable
@@ -2307,6 +2269,8 @@ static int fill_rx_buffers(struct s2io_n
 	unsigned long flags;
 	struct RxD_t *first_rxdp = NULL;
 	u64 Buffer0_ptr = 0, Buffer1_ptr = 0;
+	struct RxD1 *rxdp1;
+	struct RxD3 *rxdp3;
 
 	mac_control = &nic->mac_control;
 	config = &nic->config;
@@ -2359,7 +2323,7 @@ static int fill_rx_buffers(struct s2io_n
 			(block_no * (rxd_count[nic->rxd_mode] + 1)) + off;
 		}
 		if ((rxdp->Control_1 & RXD_OWN_XENA) &&
-			((nic->rxd_mode >= RXD_MODE_3A) &&
+			((nic->rxd_mode == RXD_MODE_3B) &&
 				(rxdp->Control_2 & BIT(0)))) {
 			mac_control->rings[ring_no].rx_curr_put_info.
 					offset = off;
@@ -2370,10 +2334,8 @@ static int fill_rx_buffers(struct s2io_n
 				HEADER_802_2_SIZE + HEADER_SNAP_SIZE;
 		if (nic->rxd_mode == RXD_MODE_1)
 			size += NET_IP_ALIGN;
-		else if (nic->rxd_mode == RXD_MODE_3B)
-			size = dev->mtu + ALIGN_SIZE + BUF0_LEN + 4;
 		else
-			size = l3l4hdr_size + ALIGN_SIZE + BUF0_LEN + 4;
+			size = dev->mtu + ALIGN_SIZE + BUF0_LEN + 4;
 
 		/* allocate skb */
 		skb = dev_alloc_skb(size);
@@ -2392,33 +2354,30 @@ static int fill_rx_buffers(struct s2io_n
 			+= skb->truesize;
 		if (nic->rxd_mode == RXD_MODE_1) {
 			/* 1 buffer mode - normal operation mode */
+			rxdp1 = (struct RxD1*)rxdp;
 			memset(rxdp, 0, sizeof(struct RxD1));
 			skb_reserve(skb, NET_IP_ALIGN);
-			((struct RxD1*)rxdp)->Buffer0_ptr = pci_map_single
+			rxdp1->Buffer0_ptr = pci_map_single
 			    (nic->pdev, skb->data, size - NET_IP_ALIGN,
 				PCI_DMA_FROMDEVICE);
 			rxdp->Control_2 = 
 				SET_BUFFER0_SIZE_1(size - NET_IP_ALIGN);
 
-		} else if (nic->rxd_mode >= RXD_MODE_3A) {
+		} else if (nic->rxd_mode == RXD_MODE_3B) {
 			/*
-			 * 2 or 3 buffer mode -
-			 * Both 2 buffer mode and 3 buffer mode provides 128
+			 * 2 buffer mode -
+			 * 2 buffer mode provides 128
 			 * byte aligned receive buffers.
-			 *
-			 * 3 buffer mode provides header separation where in
-			 * skb->data will have L3/L4 headers where as
-			 * skb_shinfo(skb)->frag_list will have the L4 data
-			 * payload
 			 */
 
+			rxdp3 = (struct RxD3*)rxdp;
 			/* save buffer pointers to avoid frequent dma mapping */
-			Buffer0_ptr = ((struct RxD3*)rxdp)->Buffer0_ptr;
-			Buffer1_ptr = ((struct RxD3*)rxdp)->Buffer1_ptr;
+			Buffer0_ptr = rxdp3->Buffer0_ptr;
+			Buffer1_ptr = rxdp3->Buffer1_ptr;
 			memset(rxdp, 0, sizeof(struct RxD3));
 			/* restore the buffer pointers for dma sync*/
-			((struct RxD3*)rxdp)->Buffer0_ptr = Buffer0_ptr;
-			((struct RxD3*)rxdp)->Buffer1_ptr = Buffer1_ptr;
+			rxdp3->Buffer0_ptr = Buffer0_ptr;
+			rxdp3->Buffer1_ptr = Buffer1_ptr;
 
 			ba = &mac_control->rings[ring_no].ba[block_no][off];
 			skb_reserve(skb, BUF0_LEN);
@@ -2428,13 +2387,13 @@ static int fill_rx_buffers(struct s2io_n
 			skb->data = (void *) (unsigned long)tmp;
 			skb_reset_tail_pointer(skb);
 
-			if (!(((struct RxD3*)rxdp)->Buffer0_ptr))
-				((struct RxD3*)rxdp)->Buffer0_ptr =
+			if (!(rxdp3->Buffer0_ptr))
+				rxdp3->Buffer0_ptr =
 				   pci_map_single(nic->pdev, ba->ba_0, BUF0_LEN,
 					   PCI_DMA_FROMDEVICE);
 			else
 				pci_dma_sync_single_for_device(nic->pdev,
-				(dma_addr_t) ((struct RxD3*)rxdp)->Buffer0_ptr,
+				(dma_addr_t) rxdp3->Buffer0_ptr,
 				    BUF0_LEN, PCI_DMA_FROMDEVICE);
 			rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
 			if (nic->rxd_mode == RXD_MODE_3B) {
@@ -2444,13 +2403,13 @@ static int fill_rx_buffers(struct s2io_n
 				 * Buffer2 will have L3/L4 header plus
 				 * L4 payload
 				 */
-				((struct RxD3*)rxdp)->Buffer2_ptr = pci_map_single
+				rxdp3->Buffer2_ptr = pci_map_single
 				(nic->pdev, skb->data, dev->mtu + 4,
 						PCI_DMA_FROMDEVICE);
 
 				/* Buffer-1 will be dummy buffer. Not used */
-				if (!(((struct RxD3*)rxdp)->Buffer1_ptr)) {
-					((struct RxD3*)rxdp)->Buffer1_ptr =
+				if (!(rxdp3->Buffer1_ptr)) {
+					rxdp3->Buffer1_ptr =
 						pci_map_single(nic->pdev,
 						ba->ba_1, BUF1_LEN,
 						PCI_DMA_FROMDEVICE);
@@ -2458,19 +2417,6 @@ static int fill_rx_buffers(struct s2io_n
 				rxdp->Control_2 |= SET_BUFFER1_SIZE_3(1);
 				rxdp->Control_2 |= SET_BUFFER2_SIZE_3
 								(dev->mtu + 4);
-			} else {
-				/* 3 buffer mode */
-				if (fill_rxd_3buf(nic, rxdp, skb) == -ENOMEM) {
-					nic->mac_control.stats_info->sw_stat.\
-					mem_freed += skb->truesize;
-					dev_kfree_skb_irq(skb);
-					if (first_rxdp) {
-						wmb();
-						first_rxdp->Control_1 |=
-							RXD_OWN_XENA;
-					}
-					return -ENOMEM ;
-				}
 			}
 			rxdp->Control_2 |= BIT(0);
 		}
@@ -2515,6 +2461,8 @@ static void free_rxd_blk(struct s2io_nic
 	struct RxD_t *rxdp;
 	struct mac_info *mac_control;
 	struct buffAdd *ba;
+	struct RxD1 *rxdp1;
+	struct RxD3 *rxdp3;
 
 	mac_control = &sp->mac_control;
 	for (j = 0 ; j < rxd_count[sp->rxd_mode]; j++) {
@@ -2526,40 +2474,30 @@ static void free_rxd_blk(struct s2io_nic
 			continue;
 		}
 		if (sp->rxd_mode == RXD_MODE_1) {
+			rxdp1 = (struct RxD1*)rxdp;
 			pci_unmap_single(sp->pdev, (dma_addr_t)
-				 ((struct RxD1*)rxdp)->Buffer0_ptr,
-				 dev->mtu +
-				 HEADER_ETHERNET_II_802_3_SIZE
-				 + HEADER_802_2_SIZE +
-				 HEADER_SNAP_SIZE,
-				 PCI_DMA_FROMDEVICE);
+				rxdp1->Buffer0_ptr,
+				dev->mtu +
+				HEADER_ETHERNET_II_802_3_SIZE
+				+ HEADER_802_2_SIZE +
+				HEADER_SNAP_SIZE,
+				PCI_DMA_FROMDEVICE);
 			memset(rxdp, 0, sizeof(struct RxD1));
 		} else if(sp->rxd_mode == RXD_MODE_3B) {
+			rxdp3 = (struct RxD3*)rxdp;
 			ba = &mac_control->rings[ring_no].
 				ba[blk][j];
 			pci_unmap_single(sp->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer0_ptr,
-				 BUF0_LEN,
-				 PCI_DMA_FROMDEVICE);
-			pci_unmap_single(sp->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer1_ptr,
-				 BUF1_LEN,
-				 PCI_DMA_FROMDEVICE);
-			pci_unmap_single(sp->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer2_ptr,
-				 dev->mtu + 4,
-				 PCI_DMA_FROMDEVICE);
-			memset(rxdp, 0, sizeof(struct RxD3));
-		} else {
-			pci_unmap_single(sp->pdev, (dma_addr_t)
-				((struct RxD3*)rxdp)->Buffer0_ptr, BUF0_LEN,
+				rxdp3->Buffer0_ptr,
+				BUF0_LEN,
 				PCI_DMA_FROMDEVICE);
 			pci_unmap_single(sp->pdev, (dma_addr_t)
-				((struct RxD3*)rxdp)->Buffer1_ptr,
-				l3l4hdr_size + 4,
+				rxdp3->Buffer1_ptr,
+				BUF1_LEN,
 				PCI_DMA_FROMDEVICE);
 			pci_unmap_single(sp->pdev, (dma_addr_t)
-				((struct RxD3*)rxdp)->Buffer2_ptr, dev->mtu,
+				rxdp3->Buffer2_ptr,
+				dev->mtu + 4,
 				PCI_DMA_FROMDEVICE);
 			memset(rxdp, 0, sizeof(struct RxD3));
 		}
@@ -2756,6 +2694,8 @@ static void rx_intr_handler(struct ring_
 	struct sk_buff *skb;
 	int pkt_cnt = 0;
 	int i;
+	struct RxD1* rxdp1;
+	struct RxD3* rxdp3;
 
 	spin_lock(&nic->rx_lock);
 	if (atomic_read(&nic->card_state) == CARD_DOWN) {
@@ -2796,32 +2736,23 @@ static void rx_intr_handler(struct ring_
 			return;
 		}
 		if (nic->rxd_mode == RXD_MODE_1) {
+			rxdp1 = (struct RxD1*)rxdp;
 			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD1*)rxdp)->Buffer0_ptr,
-				 dev->mtu +
-				 HEADER_ETHERNET_II_802_3_SIZE +
-				 HEADER_802_2_SIZE +
-				 HEADER_SNAP_SIZE,
-				 PCI_DMA_FROMDEVICE);
+				rxdp1->Buffer0_ptr,
+				dev->mtu +
+				HEADER_ETHERNET_II_802_3_SIZE +
+				HEADER_802_2_SIZE +
+				HEADER_SNAP_SIZE,
+				PCI_DMA_FROMDEVICE);
 		} else if (nic->rxd_mode == RXD_MODE_3B) {
+			rxdp3 = (struct RxD3*)rxdp;
 			pci_dma_sync_single_for_cpu(nic->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer0_ptr,
-				 BUF0_LEN, PCI_DMA_FROMDEVICE);
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer2_ptr,
-				 dev->mtu + 4,
-				 PCI_DMA_FROMDEVICE);
-		} else {
-			pci_dma_sync_single_for_cpu(nic->pdev, (dma_addr_t)
-					 ((struct RxD3*)rxdp)->Buffer0_ptr, BUF0_LEN,
-					 PCI_DMA_FROMDEVICE);
+				rxdp3->Buffer0_ptr,
+				BUF0_LEN, PCI_DMA_FROMDEVICE);
 			pci_unmap_single(nic->pdev, (dma_addr_t)
-					 ((struct RxD3*)rxdp)->Buffer1_ptr,
-					 l3l4hdr_size + 4,
-					 PCI_DMA_FROMDEVICE);
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-					 ((struct RxD3*)rxdp)->Buffer2_ptr,
-					 dev->mtu, PCI_DMA_FROMDEVICE);
+				rxdp3->Buffer2_ptr,
+				dev->mtu + 4,
+				PCI_DMA_FROMDEVICE);
 		}
 		prefetch(skb->data);
 		rx_osm_handler(ring_data, rxdp);
@@ -4927,8 +4858,6 @@ static void s2io_ethtool_gringparam(stru
 		ering->rx_max_pending = MAX_RX_DESC_1;
 	else if (sp->rxd_mode == RXD_MODE_3B)
 		ering->rx_max_pending = MAX_RX_DESC_2;
-	else if (sp->rxd_mode == RXD_MODE_3A)
-		ering->rx_max_pending = MAX_RX_DESC_3;
 
 	ering->tx_max_pending = MAX_TX_DESC;
 	for (i = 0 ; i < sp->config.tx_fifo_num ; i++) {
@@ -6266,9 +6195,9 @@ static int set_rxd_buffer_pointer(struct
 				u64 *temp2, int size)
 {
 	struct net_device *dev = sp->dev;
-	struct sk_buff *frag_list;
 
 	if ((sp->rxd_mode == RXD_MODE_1) && (rxdp->Host_Control == 0)) {
+		struct RxD1 *rxdp1 = (struct RxD1 *)rxdp;
 		/* allocate skb */
 		if (*skb) {
 			DBG_PRINT(INFO_DBG, "SKB is not NULL\n");
@@ -6277,7 +6206,7 @@ static int set_rxd_buffer_pointer(struct
 			 * using same mapped address for the Rxd
 			 * buffer pointer
 			 */
-			((struct RxD1*)rxdp)->Buffer0_ptr = *temp0;
+			rxdp1->Buffer0_ptr = *temp0;
 		} else {
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
@@ -6294,18 +6223,19 @@ static int set_rxd_buffer_pointer(struct
 			 * such it will be used for next rxd whose
 			 * Host Control is NULL
 			 */
-			((struct RxD1*)rxdp)->Buffer0_ptr = *temp0 =
+			rxdp1->Buffer0_ptr = *temp0 =
 				pci_map_single( sp->pdev, (*skb)->data,
 					size - NET_IP_ALIGN,
 					PCI_DMA_FROMDEVICE);
 			rxdp->Host_Control = (unsigned long) (*skb);
 		}
 	} else if ((sp->rxd_mode == RXD_MODE_3B) && (rxdp->Host_Control == 0)) {
+		struct RxD3 *rxdp3 = (struct RxD3 *)rxdp;
 		/* Two buffer Mode */
 		if (*skb) {
-			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2;
-			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0;
-			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1;
+			rxdp3->Buffer2_ptr = *temp2;
+			rxdp3->Buffer0_ptr = *temp0;
+			rxdp3->Buffer1_ptr = *temp1;
 		} else {
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
@@ -6318,69 +6248,19 @@ static int set_rxd_buffer_pointer(struct
 			}
 			sp->mac_control.stats_info->sw_stat.mem_allocated 
 				+= (*skb)->truesize;
-			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2 =
+			rxdp3->Buffer2_ptr = *temp2 =
 				pci_map_single(sp->pdev, (*skb)->data,
 					       dev->mtu + 4,
 					       PCI_DMA_FROMDEVICE);
-			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0 =
+			rxdp3->Buffer0_ptr = *temp0 =
 				pci_map_single( sp->pdev, ba->ba_0, BUF0_LEN,
 						PCI_DMA_FROMDEVICE);
 			rxdp->Host_Control = (unsigned long) (*skb);
 
 			/* Buffer-1 will be dummy buffer not used */
-			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1 =
+			rxdp3->Buffer1_ptr = *temp1 =
 				pci_map_single(sp->pdev, ba->ba_1, BUF1_LEN,
-					       PCI_DMA_FROMDEVICE);
-		}
-	} else if ((rxdp->Host_Control == 0)) {
-		/* Three buffer mode */
-		if (*skb) {
-			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0;
-			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1;
-			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2;
-		} else {
-			*skb = dev_alloc_skb(size);
-			if (!(*skb)) {
-				DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
-				DBG_PRINT(INFO_DBG, "memory to allocate ");
-				DBG_PRINT(INFO_DBG, "3 buf mode SKBs\n");
-				sp->mac_control.stats_info->sw_stat. \
-					mem_alloc_fail_cnt++;
-				return -ENOMEM;
-			}
-			sp->mac_control.stats_info->sw_stat.mem_allocated 
-				+= (*skb)->truesize;
-			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0 =
-				pci_map_single(sp->pdev, ba->ba_0, BUF0_LEN,
-					       PCI_DMA_FROMDEVICE);
-			/* Buffer-1 receives L3/L4 headers */
-			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1 =
-				pci_map_single( sp->pdev, (*skb)->data,
-						l3l4hdr_size + 4,
 						PCI_DMA_FROMDEVICE);
-			/*
-			 * skb_shinfo(skb)->frag_list will have L4
-			 * data payload
-			 */
-			skb_shinfo(*skb)->frag_list = dev_alloc_skb(dev->mtu +
-								   ALIGN_SIZE);
-			if (skb_shinfo(*skb)->frag_list == NULL) {
-				DBG_PRINT(ERR_DBG, "%s: dev_alloc_skb \
-					  failed\n ", dev->name);
-				sp->mac_control.stats_info->sw_stat. \
-					mem_alloc_fail_cnt++;
-				return -ENOMEM ;
-			}
-			frag_list = skb_shinfo(*skb)->frag_list;
-			frag_list->next = NULL;
-			sp->mac_control.stats_info->sw_stat.mem_allocated 
-				+= frag_list->truesize;
-			/*
-			 * Buffer-2 receives L4 data payload
-			 */
-			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2 =
-				pci_map_single( sp->pdev, frag_list->data,
-						dev->mtu, PCI_DMA_FROMDEVICE);
 		}
 	}
 	return 0;
@@ -6395,10 +6275,6 @@ static void set_rxd_buffer_size(struct s
 		rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
 		rxdp->Control_2 |= SET_BUFFER1_SIZE_3(1);
 		rxdp->Control_2 |= SET_BUFFER2_SIZE_3( dev->mtu + 4);
-	} else {
-		rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
-		rxdp->Control_2 |= SET_BUFFER1_SIZE_3(l3l4hdr_size + 4);
-		rxdp->Control_2 |= SET_BUFFER2_SIZE_3(dev->mtu);
 	}
 }
 
@@ -6420,8 +6296,6 @@ static  int rxd_owner_bit_reset(struct s
 		size += NET_IP_ALIGN;
 	else if (sp->rxd_mode == RXD_MODE_3B)
 		size = dev->mtu + ALIGN_SIZE + BUF0_LEN + 4;
-	else
-		size = l3l4hdr_size + ALIGN_SIZE + BUF0_LEN + 4;
 
 	for (i = 0; i < config->rx_ring_num; i++) {
 		blk_cnt = config->rx_cfg[i].num_rxd /
@@ -6431,7 +6305,7 @@ static  int rxd_owner_bit_reset(struct s
 			for (k = 0; k < rxd_count[sp->rxd_mode]; k++) {
 				rxdp = mac_control->rings[i].
 					rx_blocks[j].rxds[k].virt_addr;
-				if(sp->rxd_mode >= RXD_MODE_3A)
+				if(sp->rxd_mode == RXD_MODE_3B)
 					ba = &mac_control->rings[i].ba[j][k];
 				if (set_rxd_buffer_pointer(sp, rxdp, ba,
 						       &skb,(u64 *)&temp0_64,
@@ -6914,7 +6788,7 @@ static int rx_osm_handler(struct ring_in
 		sp->stats.rx_bytes += len;
 		skb_put(skb, len);
 
-	} else if (sp->rxd_mode >= RXD_MODE_3A) {
+	} else if (sp->rxd_mode == RXD_MODE_3B) {
 		int get_block = ring_data->rx_curr_get_info.block_index;
 		int get_off = ring_data->rx_curr_get_info.offset;
 		int buf0_len = RXD_GET_BUFFER0_SIZE_3(rxdp->Control_2);
@@ -6924,18 +6798,7 @@ static int rx_osm_handler(struct ring_in
 		struct buffAdd *ba = &ring_data->ba[get_block][get_off];
 		sp->stats.rx_bytes += buf0_len + buf2_len;
 		memcpy(buff, ba->ba_0, buf0_len);
-
-		if (sp->rxd_mode == RXD_MODE_3A) {
-			int buf1_len = RXD_GET_BUFFER1_SIZE_3(rxdp->Control_2);
-
-			skb_put(skb, buf1_len);
-			skb->len += buf2_len;
-			skb->data_len += buf2_len;
-			skb_put(skb_shinfo(skb)->frag_list, buf2_len);
-			sp->stats.rx_bytes += buf1_len;
-
-		} else
-			skb_put(skb, buf2_len);
+		skb_put(skb, buf2_len);
 	}
 
 	if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) && ((!sp->lro) ||
@@ -7145,10 +7008,10 @@ static int s2io_verify_parm(struct pci_d
 		*dev_intr_type = INTA;
 	}
 
-	if (rx_ring_mode > 3) {
+	if ((rx_ring_mode != 1) && (rx_ring_mode != 2)) {
 		DBG_PRINT(ERR_DBG, "s2io: Requested ring mode not supported\n");
-		DBG_PRINT(ERR_DBG, "s2io: Defaulting to 3-buffer mode\n");
-		rx_ring_mode = 3;
+		DBG_PRINT(ERR_DBG, "s2io: Defaulting to 1-buffer mode\n");
+		rx_ring_mode = 1;
 	}
 	return SUCCESS;
 }
@@ -7288,8 +7151,6 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		sp->rxd_mode = RXD_MODE_1;
 	if (rx_ring_mode == 2)
 		sp->rxd_mode = RXD_MODE_3B;
-	if (rx_ring_mode == 3)
-		sp->rxd_mode = RXD_MODE_3A;
 
 	sp->intr_type = dev_intr_type;
 
@@ -7565,10 +7426,6 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		    DBG_PRINT(ERR_DBG, "%s: 2-Buffer receive mode enabled\n",
 						dev->name);
 		    break;
-		case RXD_MODE_3A:
-		    DBG_PRINT(ERR_DBG, "%s: 3-Buffer receive mode enabled\n",
-						dev->name);
-		    break;
 	}
 
 	if (napi)
diff -urpN org/drivers/net/s2io.h patch_1/drivers/net/s2io.h
--- org/drivers/net/s2io.h	2007-07-17 15:05:49.000000000 +0530
+++ patch_1/drivers/net/s2io.h	2007-07-19 14:20:53.000000000 +0530
@@ -575,8 +575,7 @@ struct RxD_block {
 #define SIZE_OF_BLOCK	4096
 
 #define RXD_MODE_1	0 /* One Buffer mode */
-#define RXD_MODE_3A	1 /* Three Buffer mode */
-#define RXD_MODE_3B	2 /* Two Buffer mode */
+#define RXD_MODE_3B	1 /* Two Buffer mode */
 
 /* Structure to hold virtual addresses of Buf0 and Buf1 in
  * 2buf mode. */

