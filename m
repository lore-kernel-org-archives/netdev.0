From: Veena Parat <Veena.Parat@neterion.com>
Subject: [PATCH 2.6.22 3/4]S2IO: Removing 3 buffer mode support from the
 driver
Date: Tue, 19 Jun 2007 06:02:52 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10706190559550.2608-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Leonid.Grossman@neterion.com, ramkrishna.vepa@neterion.com,
	santosh.rastapur@neterion.com, Sivakumar.Subramani@neterion.com,
	sreenivasa.honnur@neterion.com, Alicia.Pena@neterion.com,
	sriram.rapuru@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:48101 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755695AbXFSKCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 06:02:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed 3 buffer mode support from driver - unused feature

Signed-off-by: Veena Parat <veena.parat@neterion.com>
---
diff -urpN patch_2/drivers/net/s2io.c patch_3/drivers/net/s2io.c
--- patch_2/drivers/net/s2io.c	2007-05-21 15:15:11.000000000 +0530
+++ patch_3/drivers/net/s2io.c	2007-06-07 12:11:27.000000000 +0530
@@ -32,7 +32,7 @@
  * rx_ring_sz: This defines the number of receive blocks each ring can have.
  *     This is also an array of size 8.
  * rx_ring_mode: This defines the operation mode of all 8 rings. The valid
- *		values are 1, 2 and 3.
+ *		values are 1 and 2.
  * tx_fifo_num: This defines the number of Tx FIFOs thats used int the driver.
  * tx_fifo_len: This too is an array of 8. Each element defines the number of
  * Tx descriptors that can be associated with each corresponding FIFO.
@@ -90,8 +90,8 @@
 static char s2io_driver_name[] = "Neterion";
 static char s2io_driver_version[] = DRV_VERSION;
 
-static int rxd_size[4] = {32,48,48,64};
-static int rxd_count[4] = {127,85,85,63};
+static int rxd_size[4] = {32,48,64};
+static int rxd_count[4] = {127,85,63};
 
 static inline int RXD_IS_UP2DT(struct RxD_t *rxdp)
 {
@@ -706,7 +706,7 @@ static int init_shared_mem(struct s2io_n
 			    (u64) tmp_p_addr_next;
 		}
 	}
-	if (nic->rxd_mode >= RXD_MODE_3A) {
+	if (nic->rxd_mode == RXD_MODE_3B) {
 		/*
 		 * Allocation of Storages for buffer addresses in 2BUFF mode
 		 * and the buffers as well.
@@ -873,7 +873,7 @@ static void free_shared_mem(struct s2io_
 		}
 	}
 
-	if (nic->rxd_mode >= RXD_MODE_3A) {
+	if (nic->rxd_mode == RXD_MODE_3B) {
 		/* Freeing buffer storage addresses in 2BUFF mode. */
 		for (i = 0; i < config->rx_ring_num; i++) {
 			blk_cnt = config->rx_cfg[i].num_rxd /
@@ -894,8 +894,9 @@ static void free_shared_mem(struct s2io_
 					k++;
 				}
 				kfree(mac_control->rings[i].ba[j]);
-				nic->mac_control.stats_info->sw_stat.mem_freed 				+= (sizeof(struct buffAdd) * 
-				(rxd_count[nic->rxd_mode] + 1));
+				nic->mac_control.stats_info->sw_stat.mem_freed 
+					+= (sizeof(struct buffAdd) * 
+					(rxd_count[nic->rxd_mode] + 1));
 			}
 			kfree(mac_control->rings[i].ba);
 			nic->mac_control.stats_info->sw_stat.mem_freed += 
@@ -2236,58 +2237,6 @@ static void stop_nic(struct s2io_nic *ni
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
-	if ((((struct RxD3*)rxdp)->Buffer1_ptr == 0) ||
-		(((struct RxD3*)rxdp)->Buffer1_ptr == DMA_ERROR_CODE)) {
-		nic->mac_control.stats_info->sw_stat.pci_map_fail_cnt++;
-		return -ENOMEM;
-	}
-
-	/* skb_shinfo(skb)->frag_list will have L4 data payload */
-	skb_shinfo(skb)->frag_list = dev_alloc_skb(dev->mtu + ALIGN_SIZE);
-	if (skb_shinfo(skb)->frag_list == NULL) {
-		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
-		pci_unmap_single
-			(nic->pdev, (dma_addr_t)skb->data, l3l4hdr_size + 4,
-			PCI_DMA_FROMDEVICE);
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
-	if ((((struct RxD3*)rxdp)->Buffer2_ptr == 0) ||
-		(((struct RxD3*)rxdp)->Buffer2_ptr == DMA_ERROR_CODE)) {
-		nic->mac_control.stats_info->sw_stat.pci_map_fail_cnt++;
-		return -ENOMEM;
-	}
-	rxdp->Control_2 |= SET_BUFFER1_SIZE_3(l3l4hdr_size + 4);
-	rxdp->Control_2 |= SET_BUFFER2_SIZE_3(dev->mtu);
-
-	return SUCCESS;
-}
-
 /**
  *  fill_rx_buffers - Allocates the Rx side skbs
  *  @nic:  device private variable
@@ -2296,10 +2245,9 @@ static int fill_rxd_3buf(struct s2io_nic
  *  The function allocates Rx side skbs and puts the physical
  *  address of these buffers into the RxD buffer pointers, so that the NIC
  *  can DMA the received frame into these locations.
- *  The NIC supports 3 receive modes, viz
+ *  The NIC supports 2 receive modes, viz
  *  1. single buffer,
- *  2. three buffer and
- *  3. Five buffer modes.
+ *  2. Two buffer modes.
  *  Each mode defines how many fragments the received frame will be split
  *  up into by the NIC. The frame is split into L3 header, L4 Header,
  *  L4 payload in three buffer mode and in 5 buffer mode, L4 payload itself
@@ -2376,7 +2324,7 @@ static int fill_rx_buffers(struct s2io_n
 			(block_no * (rxd_count[nic->rxd_mode] + 1)) + off;
 		}
 		if ((rxdp->Control_1 & RXD_OWN_XENA) &&
-			((nic->rxd_mode >= RXD_MODE_3A) &&
+			((nic->rxd_mode == RXD_MODE_3B) &&
 				(rxdp->Control_2 & BIT(0)))) {
 			mac_control->rings[ring_no].rx_curr_put_info.
 					offset = off;
@@ -2427,16 +2375,12 @@ static int fill_rx_buffers(struct s2io_n
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
 			 *
-			 * 3 buffer mode provides header separation where in
-			 * skb->data will have L3/L4 headers where as
-			 * skb_shinfo(skb)->frag_list will have the L4 data
-			 * payload
 			 */
 
 			/* save buffer pointers to avoid frequent dma mapping */
@@ -2512,19 +2456,6 @@ static int fill_rx_buffers(struct s2io_n
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
@@ -2579,43 +2510,35 @@ static void free_rxd_blk(struct s2io_nic
 		if (!skb) {
 			continue;
 		}
-		if (sp->rxd_mode == RXD_MODE_1) {
-			pci_unmap_single(sp->pdev, (dma_addr_t)
-				 ((struct RxD1*)rxdp)->Buffer0_ptr,
-				 dev->mtu +
-				 HEADER_ETHERNET_II_802_3_SIZE
-				 + HEADER_802_2_SIZE +
-				 HEADER_SNAP_SIZE,
-				 PCI_DMA_FROMDEVICE);
-			memset(rxdp, 0, sizeof(struct RxD1));
-		} else if(sp->rxd_mode == RXD_MODE_3B) {
-			ba = &mac_control->rings[ring_no].
-				ba[blk][j];
-			pci_unmap_single(sp->pdev, (dma_addr_t)
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
-				PCI_DMA_FROMDEVICE);
-			pci_unmap_single(sp->pdev, (dma_addr_t)
-				((struct RxD3*)rxdp)->Buffer1_ptr,
-				l3l4hdr_size + 4,
-				PCI_DMA_FROMDEVICE);
-			pci_unmap_single(sp->pdev, (dma_addr_t)
-				((struct RxD3*)rxdp)->Buffer2_ptr, dev->mtu,
-				PCI_DMA_FROMDEVICE);
-			memset(rxdp, 0, sizeof(struct RxD3));
+		switch(sp->rxd_mode) {
+			case RXD_MODE_1:
+				pci_unmap_single(sp->pdev, (dma_addr_t)
+					 ((struct RxD1*)rxdp)->Buffer0_ptr,
+					 dev->mtu +
+					 HEADER_ETHERNET_II_802_3_SIZE
+					 + HEADER_802_2_SIZE +
+					 HEADER_SNAP_SIZE,
+					 PCI_DMA_FROMDEVICE);
+				memset(rxdp, 0, sizeof(struct RxD1));
+			break;
+
+			case RXD_MODE_3B:
+				ba = &mac_control->rings[ring_no].
+					ba[blk][j];
+				pci_unmap_single(sp->pdev, (dma_addr_t)
+					 ((struct RxD3*)rxdp)->Buffer0_ptr,
+					 BUF0_LEN,
+					 PCI_DMA_FROMDEVICE);
+				pci_unmap_single(sp->pdev, (dma_addr_t)
+					 ((struct RxD3*)rxdp)->Buffer1_ptr,
+					 BUF1_LEN,
+					 PCI_DMA_FROMDEVICE);
+				pci_unmap_single(sp->pdev, (dma_addr_t)
+					 ((struct RxD3*)rxdp)->Buffer2_ptr,
+					 dev->mtu + 4,
+					 PCI_DMA_FROMDEVICE);
+				memset(rxdp, 0, sizeof(struct RxD3));
+			break;
 		}
 		sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
 		dev_kfree_skb(skb);
@@ -2849,36 +2772,29 @@ static void rx_intr_handler(struct ring_
 			spin_unlock(&nic->rx_lock);
 			return;
 		}
-		if (nic->rxd_mode == RXD_MODE_1) {
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD1*)rxdp)->Buffer0_ptr,
-				 dev->mtu +
-				 HEADER_ETHERNET_II_802_3_SIZE +
-				 HEADER_802_2_SIZE +
-				 HEADER_SNAP_SIZE,
-				 PCI_DMA_FROMDEVICE);
-		} else if (nic->rxd_mode == RXD_MODE_3B) {
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer0_ptr,
-				 BUF0_LEN, PCI_DMA_FROMDEVICE);
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer1_ptr,
-				 BUF1_LEN, PCI_DMA_FROMDEVICE);
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer2_ptr,
-				 dev->mtu + 4,
-				 PCI_DMA_FROMDEVICE);
-		} else {
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer0_ptr, BUF0_LEN,
-				 PCI_DMA_FROMDEVICE);
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer1_ptr,
-				 l3l4hdr_size + 4,
-				 PCI_DMA_FROMDEVICE);
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer2_ptr,
-				 dev->mtu, PCI_DMA_FROMDEVICE);
+		switch(nic->rxd_mode) {
+			case RXD_MODE_1:
+				pci_unmap_single(nic->pdev, (dma_addr_t)
+					 ((struct RxD1*)rxdp)->Buffer0_ptr,
+					 dev->mtu +
+					 HEADER_ETHERNET_II_802_3_SIZE +
+					 HEADER_802_2_SIZE +
+					 HEADER_SNAP_SIZE,
+					 PCI_DMA_FROMDEVICE);
+			break;
+
+			case RXD_MODE_3B:
+				pci_unmap_single(nic->pdev, (dma_addr_t)
+					 ((struct RxD3*)rxdp)->Buffer0_ptr,
+					 BUF0_LEN, PCI_DMA_FROMDEVICE);
+				pci_unmap_single(nic->pdev, (dma_addr_t)
+					 ((struct RxD3*)rxdp)->Buffer1_ptr,
+					 BUF1_LEN, PCI_DMA_FROMDEVICE);
+				pci_unmap_single(nic->pdev, (dma_addr_t)
+					 ((struct RxD3*)rxdp)->Buffer2_ptr,
+					 dev->mtu + 4,
+					 PCI_DMA_FROMDEVICE);
+			break;
 		}
 		prefetch(skb->data);
 		rx_osm_handler(ring_data, rxdp);
@@ -4919,8 +4835,6 @@ static void s2io_ethtool_gringparam(stru
 		ering->rx_max_pending = MAX_RX_DESC_1;
 	else if (sp->rxd_mode == RXD_MODE_3B)
 		ering->rx_max_pending = MAX_RX_DESC_2;
-	else if (sp->rxd_mode == RXD_MODE_3A)
-		ering->rx_max_pending = MAX_RX_DESC_3;
 
 	ering->tx_max_pending = MAX_TX_DESC;
 	for (i = 0 ; i < sp->config.tx_fifo_num ; i++) {
@@ -6259,208 +6173,132 @@ static int set_rxd_buffer_pointer(struct
 				u64 *temp2, int size)
 {
 	struct net_device *dev = sp->dev;
-	struct sk_buff *frag_list;
+	
+	if (rxdp->Host_Control)
+		return 0;
 
-	if ((sp->rxd_mode == RXD_MODE_1) && (rxdp->Host_Control == 0)) {
-		/* allocate skb */
-		if (*skb) {
-			DBG_PRINT(INFO_DBG, "SKB is not NULL\n");
-			/*
-			 * As Rx frame are not going to be processed,
-			 * using same mapped address for the Rxd
-			 * buffer pointer
-			 */
-			((struct RxD1*)rxdp)->Buffer0_ptr = *temp0;
-		} else {
-			*skb = dev_alloc_skb(size);
-			if (!(*skb)) {
-				DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
-				DBG_PRINT(INFO_DBG, "memory to allocate ");
-				DBG_PRINT(INFO_DBG, "1 buf mode SKBs\n");
-				sp->mac_control.stats_info->sw_stat. \
-					mem_alloc_fail_cnt++;
-				return -ENOMEM ;
-			}
-			sp->mac_control.stats_info->sw_stat.mem_allocated 
-				+= (*skb)->truesize;
-			/* storing the mapped addr in a temp variable
-			 * such it will be used for next rxd whose
-			 * Host Control is NULL
-			 */
-			((struct RxD1*)rxdp)->Buffer0_ptr = *temp0 =
-				pci_map_single( sp->pdev, (*skb)->data,
-					size - NET_IP_ALIGN,
-					PCI_DMA_FROMDEVICE);
-			if ((((struct RxD1*)rxdp)->Buffer0_ptr == 0) ||
-				(((struct RxD1*)rxdp)->Buffer0_ptr == 
-				DMA_ERROR_CODE)) {
-				sp->mac_control.stats_info->sw_stat.
-					pci_map_fail_cnt++;
-				sp->mac_control.stats_info->sw_stat.mem_freed +=
-					(*skb)->truesize;
-				dev_kfree_skb(*skb);
-				return -ENOMEM;
-			}
-			rxdp->Host_Control = (unsigned long) (*skb);
-		}
-	} else if ((sp->rxd_mode == RXD_MODE_3B) && (rxdp->Host_Control == 0)) {
-		/* Two buffer Mode */
-		if (*skb) {
-			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2;
-			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0;
-			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1;
-		} else {
-			*skb = dev_alloc_skb(size);
-			if (!(*skb)) {
-				DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
-				DBG_PRINT(INFO_DBG, "memory to allocate ");
-				DBG_PRINT(INFO_DBG, "2 buf mode SKBs\n");
-				sp->mac_control.stats_info->sw_stat. \
-					mem_alloc_fail_cnt++;
-				return -ENOMEM;
-			}
-			sp->mac_control.stats_info->sw_stat.mem_allocated 
-				+= (*skb)->truesize;
-			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2 =
-				pci_map_single(sp->pdev, (*skb)->data,
-					       dev->mtu + 4,
-					       PCI_DMA_FROMDEVICE);
-			if ((((struct RxD3*)rxdp)->Buffer2_ptr == 0) ||
-				(((struct RxD3*)rxdp)->Buffer2_ptr ==
-				DMA_ERROR_CODE)) {
+	switch(sp->rxd_mode) {
+		case RXD_MODE_1:
+			/* allocate skb */
+			if (*skb) {
+				DBG_PRINT(INFO_DBG, "SKB is not NULL\n");
+				/*
+				 * As Rx frame are not going to be processed,
+				 * using same mapped address for the Rxd
+				 * buffer pointer
+				 */
+				((struct RxD1*)rxdp)->Buffer0_ptr = *temp0;
+			} else {
+				*skb = dev_alloc_skb(size);
+				if (!(*skb)) {
+					DBG_PRINT(INFO_DBG, "%s: Out of ",
+						dev->name);
+					DBG_PRINT(INFO_DBG, 
+						"memory to allocate ");
+					DBG_PRINT(INFO_DBG, 
+						"1 buf mode SKBs\n");
+					sp->mac_control.stats_info->sw_stat.
+						mem_alloc_fail_cnt++;
+					return -ENOMEM ;
+				}
 				sp->mac_control.stats_info->sw_stat.
-					pci_map_fail_cnt++;
-				sp->mac_control.stats_info->sw_stat.mem_freed +=
-					(*skb)->truesize;
-				dev_kfree_skb(*skb);
-				return -ENOMEM;
-			}
-			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0 =
-				pci_map_single( sp->pdev, ba->ba_0, BUF0_LEN,
+					mem_allocated += (*skb)->truesize;
+				/* storing the mapped addr in a temp variable
+				 * such it will be used for next rxd whose
+				 * Host Control is NULL
+				 */
+				((struct RxD1*)rxdp)->Buffer0_ptr = *temp0 =
+					pci_map_single( sp->pdev, (*skb)->data,
+						size - NET_IP_ALIGN,
 						PCI_DMA_FROMDEVICE);
-			if ((((struct RxD3*)rxdp)->Buffer0_ptr == 0) ||
-				(((struct RxD3*)rxdp)->Buffer0_ptr == 
-				DMA_ERROR_CODE)) {
-				sp->mac_control.stats_info->sw_stat.
-					pci_map_fail_cnt++;
-				sp->mac_control.stats_info->sw_stat.mem_freed +=
-					(*skb)->truesize;
-				pci_unmap_single (sp->pdev, 
-					(dma_addr_t)(*skb)->data,
-					dev->mtu + 4, PCI_DMA_FROMDEVICE);
-				dev_kfree_skb(*skb);
-				return -ENOMEM;
+				if ((((struct RxD1*)rxdp)->Buffer0_ptr == 0) ||
+					(((struct RxD1*)rxdp)->Buffer0_ptr ==
+					DMA_ERROR_CODE)) {
+					sp->mac_control.stats_info->sw_stat.
+						pci_map_fail_cnt++;
+					sp->mac_control.stats_info->sw_stat.
+						mem_freed += (*skb)->truesize;
+					dev_kfree_skb(*skb);
+					return -ENOMEM;
+				}
+				rxdp->Host_Control = (unsigned long) (*skb);
 			}
-			rxdp->Host_Control = (unsigned long) (*skb);
+		break;
 
-			/* Buffer-1 will be dummy buffer not used */
-			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1 =
-				pci_map_single(sp->pdev, ba->ba_1, BUF1_LEN,
-					       PCI_DMA_FROMDEVICE);
-			if ((((struct RxD3*)rxdp)->Buffer0_ptr == 0) ||
-				(((struct RxD3*)rxdp)->Buffer0_ptr == 
-				DMA_ERROR_CODE)) {
-				sp->mac_control.stats_info->sw_stat.
-					pci_map_fail_cnt++;
-				sp->mac_control.stats_info->sw_stat.mem_freed +=
-					(*skb)->truesize;
-				pci_unmap_single (sp->pdev, 
-					(dma_addr_t)(*skb)->data,
-					dev->mtu + 4, PCI_DMA_FROMDEVICE);
-				dev_kfree_skb(*skb);
-				return -ENOMEM;
-			}
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
-			if ((((struct RxD3*)rxdp)->Buffer0_ptr == 0) ||
-				(((struct RxD3*)rxdp)->Buffer0_ptr == 
-				DMA_ERROR_CODE)) {
+		case RXD_MODE_3B:
+			/* Two buffer Mode */
+			if (*skb) {
+				((struct RxD3*)rxdp)->Buffer2_ptr = *temp2;
+				((struct RxD3*)rxdp)->Buffer0_ptr = *temp0;
+				((struct RxD3*)rxdp)->Buffer1_ptr = *temp1;
+			} else {
+				*skb = dev_alloc_skb(size);
+				if (!(*skb)) {
+					DBG_PRINT(INFO_DBG, "%s: Out of ",
+						dev->name);
+					DBG_PRINT(INFO_DBG, 
+						"memory to allocate ");
+					DBG_PRINT(INFO_DBG, 
+						"2 buf mode SKBs\n");
+					sp->mac_control.stats_info->sw_stat.
+						mem_alloc_fail_cnt++;
+					return -ENOMEM;
+				}
 				sp->mac_control.stats_info->sw_stat.
-					pci_map_fail_cnt++;
-				sp->mac_control.stats_info->sw_stat.mem_freed +=
-					(*skb)->truesize;
-				dev_kfree_skb(*skb);
-				return -ENOMEM;
-			}
-			/* Buffer-1 receives L3/L4 headers */
-			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1 =
-				pci_map_single( sp->pdev, (*skb)->data,
-						l3l4hdr_size + 4,
+					mem_allocated += (*skb)->truesize;
+				((struct RxD3*)rxdp)->Buffer2_ptr = *temp2 =
+					pci_map_single(sp->pdev, (*skb)->data,
+						       dev->mtu + 4,
+						       PCI_DMA_FROMDEVICE);
+				if ((((struct RxD3*)rxdp)->Buffer2_ptr == 0) ||
+					(((struct RxD3*)rxdp)->Buffer2_ptr ==
+					DMA_ERROR_CODE)) {
+					sp->mac_control.stats_info->sw_stat.
+						pci_map_fail_cnt++;
+					sp->mac_control.stats_info->sw_stat.
+						mem_freed += (*skb)->truesize;
+					dev_kfree_skb(*skb);
+					return -ENOMEM;
+				}
+				((struct RxD3*)rxdp)->Buffer0_ptr = *temp0 =
+					pci_map_single( sp->pdev, ba->ba_0, 
+						BUF0_LEN, PCI_DMA_FROMDEVICE);
+				if ((((struct RxD3*)rxdp)->Buffer0_ptr == 0) ||
+					(((struct RxD3*)rxdp)->Buffer0_ptr == 
+					DMA_ERROR_CODE)) {
+					sp->mac_control.stats_info->sw_stat.
+						pci_map_fail_cnt++;
+					sp->mac_control.stats_info->sw_stat.
+						mem_freed += (*skb)->truesize;
+					pci_unmap_single (sp->pdev, 
+						(dma_addr_t)(*skb)->data,
+						dev->mtu + 4, 
 						PCI_DMA_FROMDEVICE);
-			if ((((struct RxD3*)rxdp)->Buffer1_ptr == 0) ||
-				(((struct RxD3*)rxdp)->Buffer1_ptr == 
-				DMA_ERROR_CODE)) {
-				sp->mac_control.stats_info->sw_stat.
-					pci_map_fail_cnt++;
-				sp->mac_control.stats_info->sw_stat.mem_freed +=
-					(*skb)->truesize;
-				dev_kfree_skb(*skb);
-				return -ENOMEM;
-			}
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
-				sp->mac_control.stats_info->sw_stat.mem_freed
-					+= (*skb)->truesize;
-				pci_unmap_single (sp->pdev, 
-					(dma_addr_t)(*skb)->data,
-					l3l4hdr_size + 4, PCI_DMA_FROMDEVICE);
-				dev_kfree_skb(*skb);
-				return -ENOMEM ;
-			}
-			frag_list = skb_shinfo(*skb)->frag_list;
-			frag_list->next = NULL;
-			(*skb)->truesize += frag_list->truesize;
-			sp->mac_control.stats_info->sw_stat.mem_allocated 
-				+= frag_list->truesize;
-			/*
-			 * Buffer-2 receives L4 data payload
-			 */
-			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2 =
-				pci_map_single( sp->pdev, frag_list->data,
-						dev->mtu, PCI_DMA_FROMDEVICE);
-			if ((((struct RxD3*)rxdp)->Buffer2_ptr == 0) ||
-				(((struct RxD3*)rxdp)->Buffer2_ptr ==
-				DMA_ERROR_CODE)) {
-				sp->mac_control.stats_info->sw_stat.
-					pci_map_fail_cnt++;
-				sp->mac_control.stats_info->sw_stat.mem_freed +=
-					(*skb)->truesize;
-				pci_unmap_single (sp->pdev,
-					(dma_addr_t)(*skb)->data,
-					l3l4hdr_size + 4, PCI_DMA_FROMDEVICE);
-				dev_kfree_skb(*skb);
-				return -ENOMEM;
+					dev_kfree_skb(*skb);
+					return -ENOMEM;
+				}
+				rxdp->Host_Control = (unsigned long) (*skb);
+
+				/* Buffer-1 will be dummy buffer not used */
+				((struct RxD3*)rxdp)->Buffer1_ptr = *temp1 =
+					pci_map_single(sp->pdev, ba->ba_1, 
+					BUF1_LEN, PCI_DMA_FROMDEVICE);
+				if ((((struct RxD3*)rxdp)->Buffer0_ptr == 0) ||
+					(((struct RxD3*)rxdp)->Buffer0_ptr == 
+					DMA_ERROR_CODE)) {
+					sp->mac_control.stats_info->sw_stat.
+						pci_map_fail_cnt++;
+					sp->mac_control.stats_info->sw_stat.
+						mem_freed += (*skb)->truesize;
+					pci_unmap_single (sp->pdev, 
+						(dma_addr_t)(*skb)->data,
+						dev->mtu + 4, 
+						PCI_DMA_FROMDEVICE);
+					dev_kfree_skb(*skb);
+					return -ENOMEM;
+				}
 			}
-		}
+		break;
 	}
 	return 0;
 }
@@ -6468,16 +6306,16 @@ static void set_rxd_buffer_size(struct s
 				int size)
 {
 	struct net_device *dev = sp->dev;
-	if (sp->rxd_mode == RXD_MODE_1) {
-		rxdp->Control_2 = SET_BUFFER0_SIZE_1( size - NET_IP_ALIGN);
-	} else if (sp->rxd_mode == RXD_MODE_3B) {
-		rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
-		rxdp->Control_2 |= SET_BUFFER1_SIZE_3(1);
-		rxdp->Control_2 |= SET_BUFFER2_SIZE_3( dev->mtu + 4);
-	} else {
-		rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
-		rxdp->Control_2 |= SET_BUFFER1_SIZE_3(l3l4hdr_size + 4);
-		rxdp->Control_2 |= SET_BUFFER2_SIZE_3(dev->mtu);
+	switch(sp->rxd_mode) {
+		case RXD_MODE_1:
+			rxdp->Control_2 = SET_BUFFER0_SIZE_1( size - 
+						NET_IP_ALIGN);
+		break;
+		case RXD_MODE_3B:
+			rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
+			rxdp->Control_2 |= SET_BUFFER1_SIZE_3(1);
+			rxdp->Control_2 |= SET_BUFFER2_SIZE_3( dev->mtu + 4);
+		break;
 	}
 }
 
@@ -6510,7 +6348,7 @@ static  int rxd_owner_bit_reset(struct s
 			for (k = 0; k < rxd_count[sp->rxd_mode]; k++) {
 				rxdp = mac_control->rings[i].
 					rx_blocks[j].rxds[k].virt_addr;
-				if(sp->rxd_mode >= RXD_MODE_3A)
+				if(sp->rxd_mode == RXD_MODE_3B)
 					ba = &mac_control->rings[i].ba[j][k];
 				if (set_rxd_buffer_pointer(sp, rxdp, ba,
 						       &skb,(u64 *)&temp0_64,
@@ -6966,7 +6804,7 @@ static int rx_osm_handler(struct ring_in
 		sp->stats.rx_bytes += len;
 		skb_put(skb, len);
 
-	} else if (sp->rxd_mode >= RXD_MODE_3A) {
+	} else if (sp->rxd_mode == RXD_MODE_3B) {
 		int get_block = ring_data->rx_curr_get_info.block_index;
 		int get_off = ring_data->rx_curr_get_info.offset;
 		int buf0_len = RXD_GET_BUFFER0_SIZE_3(rxdp->Control_2);
@@ -6977,17 +6815,7 @@ static int rx_osm_handler(struct ring_in
 		sp->stats.rx_bytes += buf0_len + buf2_len;
 		memcpy(buff, ba->ba_0, buf0_len);
 
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
@@ -7214,10 +7042,10 @@ static int s2io_verify_parm(struct pci_d
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
@@ -7349,8 +7177,6 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		sp->rxd_mode = RXD_MODE_1;
 	if (rx_ring_mode == 2)
 		sp->rxd_mode = RXD_MODE_3B;
-	if (rx_ring_mode == 3)
-		sp->rxd_mode = RXD_MODE_3A;
 
 	sp->intr_type = dev_intr_type;
 
@@ -7627,10 +7453,6 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		    DBG_PRINT(ERR_DBG, "%s: 2-Buffer receive mode enabled\n",
 						dev->name);
 		    break;
-		case RXD_MODE_3A:
-		    DBG_PRINT(ERR_DBG, "%s: 3-Buffer receive mode enabled\n",
-						dev->name);
-		    break;
 	}
 
 	if (napi)
diff -urpN patch_2/drivers/net/s2io.h patch_3/drivers/net/s2io.h
--- patch_2/drivers/net/s2io.h	2007-05-21 15:15:11.000000000 +0530
+++ patch_3/drivers/net/s2io.h	2007-05-21 15:32:26.000000000 +0530
@@ -580,8 +580,7 @@ struct RxD_block {
 #define SIZE_OF_BLOCK	4096
 
 #define RXD_MODE_1	0 /* One Buffer mode */
-#define RXD_MODE_3A	1 /* Three Buffer mode */
-#define RXD_MODE_3B	2 /* Two Buffer mode */
+#define RXD_MODE_3B	1 /* Two Buffer mode */
 
 /* Structure to hold virtual addresses of Buf0 and Buf1 in
  * 2buf mode. */

