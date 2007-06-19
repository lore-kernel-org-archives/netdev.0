From: Veena Parat <Veena.Parat@neterion.com>
Subject: [PATCH 2.6.22 1/4]S2IO: Adding checks to check the return value of
 pci mapping function
Date: Tue, 19 Jun 2007 05:56:34 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10706190549470.2608-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Leonid.Grossman@neterion.com, ramkrishna.vepa@neterion.com,
	santosh.rastapur@neterion.com, Sivakumar.Subramani@neterion.com,
	sreenivasa.honnur@neterion.com, alicia.pena@neterion.com,
	sriram.rapuru@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:48226 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755102AbXFSKLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 06:11:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding checks to check the return value of pci mapping function 

Signed-off-by: Veena Parat <veena.parat@neterion.com>
---
diff -urpN org/drivers/net/s2io.c patch_1/drivers/net/s2io.c
--- org/drivers/net/s2io.c	2007-05-17 20:35:39.000000000 +0530
+++ patch_1/drivers/net/s2io.c	2007-05-17 20:35:55.000000000 +0530
@@ -282,6 +282,7 @@ static char ethtool_driver_stats_keys[][
 	("lro_flush_due_to_max_pkts"),
 	("lro_avg_aggr_pkts"),
 	("mem_alloc_fail_cnt"),
+	{"pci_map_fail_cnt"},
 	("watchdog_timer_cnt"),
 	("mem_allocated"),
 	("mem_freed"),
@@ -2247,10 +2248,19 @@ static int fill_rxd_3buf(struct s2io_nic
 			(nic->pdev, skb->data, l3l4hdr_size + 4,
 			PCI_DMA_FROMDEVICE);
 
+	if ((((struct RxD3*)rxdp)->Buffer1_ptr == 0) ||
+		(((struct RxD3*)rxdp)->Buffer1_ptr == DMA_ERROR_CODE)) {
+		nic->mac_control.stats_info->sw_stat.pci_map_fail_cnt++;
+		return -ENOMEM;
+	}
+
 	/* skb_shinfo(skb)->frag_list will have L4 data payload */
 	skb_shinfo(skb)->frag_list = dev_alloc_skb(dev->mtu + ALIGN_SIZE);
 	if (skb_shinfo(skb)->frag_list == NULL) {
 		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
+		pci_unmap_single
+			(nic->pdev, (dma_addr_t)skb->data, l3l4hdr_size + 4,
+			PCI_DMA_FROMDEVICE);
 		DBG_PRINT(INFO_DBG, "%s: dev_alloc_skb failed\n ", dev->name);
 		return -ENOMEM ;
 	}
@@ -2267,6 +2277,11 @@ static int fill_rxd_3buf(struct s2io_nic
 	((struct RxD3*)rxdp)->Buffer2_ptr = pci_map_single(nic->pdev,
 				frag_list->data, dev->mtu,
 				PCI_DMA_FROMDEVICE);
+	if ((((struct RxD3*)rxdp)->Buffer2_ptr == 0) ||
+		(((struct RxD3*)rxdp)->Buffer2_ptr == DMA_ERROR_CODE)) {
+		nic->mac_control.stats_info->sw_stat.pci_map_fail_cnt++;
+		return -ENOMEM;
+	}
 	rxdp->Control_2 |= SET_BUFFER1_SIZE_3(l3l4hdr_size + 4);
 	rxdp->Control_2 |= SET_BUFFER2_SIZE_3(dev->mtu);
 
@@ -2399,6 +2414,16 @@ static int fill_rx_buffers(struct s2io_n
 			((struct RxD1*)rxdp)->Buffer0_ptr = pci_map_single
 			    (nic->pdev, skb->data, size - NET_IP_ALIGN,
 				PCI_DMA_FROMDEVICE);
+			if ((((struct RxD1*)rxdp)->Buffer0_ptr == 0) ||
+				(((struct RxD1*)rxdp)->Buffer0_ptr == 
+				DMA_ERROR_CODE)) {
+				nic->mac_control.stats_info->sw_stat.
+					pci_map_fail_cnt++;
+				nic->mac_control.stats_info->sw_stat.mem_freed
+					+= skb->truesize;
+				dev_kfree_skb_irq(skb);
+				return -ENOMEM;
+			}
 			rxdp->Control_2 = 
 				SET_BUFFER0_SIZE_1(size - NET_IP_ALIGN);
 
@@ -2430,14 +2455,19 @@ static int fill_rx_buffers(struct s2io_n
 			skb->data = (void *) (unsigned long)tmp;
 			skb_reset_tail_pointer(skb);
 
-			if (!(((struct RxD3*)rxdp)->Buffer0_ptr))
-				((struct RxD3*)rxdp)->Buffer0_ptr =
-				   pci_map_single(nic->pdev, ba->ba_0, BUF0_LEN,
-					   PCI_DMA_FROMDEVICE);
-			else
-				pci_dma_sync_single_for_device(nic->pdev,
-				(dma_addr_t) ((struct RxD3*)rxdp)->Buffer0_ptr,
-				    BUF0_LEN, PCI_DMA_FROMDEVICE);
+			((struct RxD3*)rxdp)->Buffer0_ptr =
+				pci_map_single(nic->pdev, ba->ba_0, BUF0_LEN,
+					PCI_DMA_FROMDEVICE);
+			if ((((struct RxD3*)rxdp)->Buffer0_ptr == 0) ||
+				(((struct RxD3*)rxdp)->Buffer0_ptr == 
+				DMA_ERROR_CODE)) {
+				nic->mac_control.stats_info->sw_stat.
+					pci_map_fail_cnt++;
+				nic->mac_control.stats_info->sw_stat.mem_freed
+					+= skb->truesize;
+				dev_kfree_skb_irq(skb);
+				return -ENOMEM;
+			}
 			rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
 			if (nic->rxd_mode == RXD_MODE_3B) {
 				/* Two buffer mode */
@@ -2447,15 +2477,37 @@ static int fill_rx_buffers(struct s2io_n
 				 * L4 payload
 				 */
 				((struct RxD3*)rxdp)->Buffer2_ptr = pci_map_single
-				(nic->pdev, skb->data, dev->mtu + 4,
-						PCI_DMA_FROMDEVICE);
+					(nic->pdev, skb->data, dev->mtu + 4,
+					PCI_DMA_FROMDEVICE);
+				if ((((struct RxD3*)rxdp)->Buffer2_ptr == 0) ||
+					(((struct RxD3*)rxdp)->Buffer2_ptr == 
+					DMA_ERROR_CODE)) {
+					nic->mac_control.stats_info->sw_stat.
+						pci_map_fail_cnt++;
+					nic->mac_control.stats_info->sw_stat.
+						mem_freed += skb->truesize;
+					dev_kfree_skb_irq(skb);
+					return -ENOMEM;
+				}
 
-				/* Buffer-1 will be dummy buffer. Not used */
-				if (!(((struct RxD3*)rxdp)->Buffer1_ptr)) {
-					((struct RxD3*)rxdp)->Buffer1_ptr =
+				((struct RxD3*)rxdp)->Buffer1_ptr =
 						pci_map_single(nic->pdev,
 						ba->ba_1, BUF1_LEN,
 						PCI_DMA_FROMDEVICE);
+				if ((((struct RxD3*)rxdp)->Buffer1_ptr == 0) ||
+					(((struct RxD3*)rxdp)->Buffer1_ptr == 
+					DMA_ERROR_CODE)) {
+					nic->mac_control.stats_info->sw_stat.
+						pci_map_fail_cnt++;
+					nic->mac_control.stats_info->sw_stat.
+						mem_freed += skb->truesize;
+					pci_unmap_single
+						(nic->pdev, 
+						(dma_addr_t)skb->data,
+						dev->mtu + 4, 
+						PCI_DMA_FROMDEVICE);
+					dev_kfree_skb_irq(skb);
+					return -ENOMEM;
 				}
 				rxdp->Control_2 |= SET_BUFFER1_SIZE_3(1);
 				rxdp->Control_2 |= SET_BUFFER2_SIZE_3
@@ -2655,7 +2707,8 @@ static int s2io_poll(struct net_device *
 
 	for (i = 0; i < config->rx_ring_num; i++) {
 		if (fill_rx_buffers(nic, i) == -ENOMEM) {
-			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
+			DBG_PRINT(INFO_DBG, "%s - %s:Out of memory",
+				__FUNCTION__, dev->name);
 			DBG_PRINT(INFO_DBG, " in Rx Poll!!\n");
 			break;
 		}
@@ -2672,7 +2725,8 @@ no_rx:
 
 	for (i = 0; i < config->rx_ring_num; i++) {
 		if (fill_rx_buffers(nic, i) == -ENOMEM) {
-			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
+			DBG_PRINT(INFO_DBG, "%s - %s:Out of memory",
+				__FUNCTION__,  dev->name);
 			DBG_PRINT(INFO_DBG, " in Rx Poll!!\n");
 			break;
 		}
@@ -2722,7 +2776,8 @@ static void s2io_netpoll(struct net_devi
 
 	for (i = 0; i < config->rx_ring_num; i++) {
 		if (fill_rx_buffers(nic, i) == -ENOMEM) {
-			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
+			DBG_PRINT(INFO_DBG, "%s - %s:Out of memory",
+				 __FUNCTION__, dev->name);
 			DBG_PRINT(INFO_DBG, " in Rx Netpoll!!\n");
 			break;
 		}
@@ -2803,24 +2858,27 @@ static void rx_intr_handler(struct ring_
 				 HEADER_SNAP_SIZE,
 				 PCI_DMA_FROMDEVICE);
 		} else if (nic->rxd_mode == RXD_MODE_3B) {
-			pci_dma_sync_single_for_cpu(nic->pdev, (dma_addr_t)
+			pci_unmap_single(nic->pdev, (dma_addr_t)
 				 ((struct RxD3*)rxdp)->Buffer0_ptr,
 				 BUF0_LEN, PCI_DMA_FROMDEVICE);
 			pci_unmap_single(nic->pdev, (dma_addr_t)
+				 ((struct RxD3*)rxdp)->Buffer1_ptr,
+				 BUF1_LEN, PCI_DMA_FROMDEVICE);
+			pci_unmap_single(nic->pdev, (dma_addr_t)
 				 ((struct RxD3*)rxdp)->Buffer2_ptr,
 				 dev->mtu + 4,
 				 PCI_DMA_FROMDEVICE);
 		} else {
-			pci_dma_sync_single_for_cpu(nic->pdev, (dma_addr_t)
-					 ((struct RxD3*)rxdp)->Buffer0_ptr, BUF0_LEN,
-					 PCI_DMA_FROMDEVICE);
 			pci_unmap_single(nic->pdev, (dma_addr_t)
-					 ((struct RxD3*)rxdp)->Buffer1_ptr,
-					 l3l4hdr_size + 4,
-					 PCI_DMA_FROMDEVICE);
+				 ((struct RxD3*)rxdp)->Buffer0_ptr, BUF0_LEN,
+				 PCI_DMA_FROMDEVICE);
 			pci_unmap_single(nic->pdev, (dma_addr_t)
-					 ((struct RxD3*)rxdp)->Buffer2_ptr,
-					 dev->mtu, PCI_DMA_FROMDEVICE);
+				 ((struct RxD3*)rxdp)->Buffer1_ptr,
+				 l3l4hdr_size + 4,
+				 PCI_DMA_FROMDEVICE);
+			pci_unmap_single(nic->pdev, (dma_addr_t)
+				 ((struct RxD3*)rxdp)->Buffer2_ptr,
+				 dev->mtu, PCI_DMA_FROMDEVICE);
 		}
 		prefetch(skb->data);
 		rx_osm_handler(ring_data, rxdp);
@@ -4082,11 +4140,33 @@ static int s2io_xmit(struct sk_buff *skb
 		txdp->Buffer_Pointer = pci_map_single(sp->pdev,
 					sp->ufo_in_band_v,
 					sizeof(u64), PCI_DMA_TODEVICE);
+		if ((txdp->Buffer_Pointer == 0) ||
+			(txdp->Buffer_Pointer == DMA_ERROR_CODE)) {
+			sp->mac_control.stats_info->sw_stat.pci_map_fail_cnt++;
+			netif_stop_queue(dev);
+			sp->mac_control.stats_info->sw_stat.mem_freed += 
+				skb->truesize;
+			dev_kfree_skb(skb);
+			spin_unlock_irqrestore(&sp->tx_lock, flags);
+			return 0;
+		}
 		txdp++;
 	}
 
 	txdp->Buffer_Pointer = pci_map_single
 	    (sp->pdev, skb->data, frg_len, PCI_DMA_TODEVICE);
+
+	if ((txdp->Buffer_Pointer == 0) ||
+		(txdp->Buffer_Pointer == DMA_ERROR_CODE)) {
+		sp->mac_control.stats_info->sw_stat.pci_map_fail_cnt++;
+		netif_stop_queue(dev);
+		sp->mac_control.stats_info->sw_stat.mem_freed +=
+			skb->truesize;
+		dev_kfree_skb(skb);
+		spin_unlock_irqrestore(&sp->tx_lock, flags);
+		return 0;
+	}
+
 	txdp->Host_Control = (unsigned long) skb;
 	txdp->Control_1 |= TXD_BUFFER0_SIZE(frg_len);
 	if (offload_type == SKB_GSO_UDP)
@@ -4175,11 +4255,13 @@ static int s2io_chk_rx_buffers(struct s2
 			clear_bit(0, (&sp->tasklet_status));
 		} else if (level == LOW)
 			tasklet_schedule(&sp->task);
-
-	} else if (fill_rx_buffers(sp, rng_n) == -ENOMEM) {
-			DBG_PRINT(INFO_DBG, "%s:Out of memory", sp->dev->name);
+	} else {
+		if (fill_rx_buffers(sp, rng_n) == -ENOMEM) {
+			DBG_PRINT(INFO_DBG, "%s - %s:Out of memory",
+				__FUNCTION__,  sp->dev->name);
 			DBG_PRINT(INFO_DBG, " in Rx Intr!!\n");
 	}
+	}
 	return 0;
 }
 
@@ -5916,6 +5998,7 @@ static void s2io_get_ethtool_stats(struc
 	else
 		tmp_stats[i++] = 0;
 	tmp_stats[i++] = stat_info->sw_stat.mem_alloc_fail_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.pci_map_fail_cnt;
 	tmp_stats[i++] = stat_info->sw_stat.watchdog_timer_cnt;
 	tmp_stats[i++] = stat_info->sw_stat.mem_allocated;
 	tmp_stats[i++] = stat_info->sw_stat.mem_freed;
@@ -6158,8 +6241,8 @@ static void s2io_tasklet(unsigned long d
 		for (i = 0; i < config->rx_ring_num; i++) {
 			ret = fill_rx_buffers(sp, i);
 			if (ret == -ENOMEM) {
-				DBG_PRINT(INFO_DBG, "%s: Out of ",
-					  dev->name);
+				DBG_PRINT(INFO_DBG, "%s- %s: Out of ",
+					  __FUNCTION__, dev->name);
 				DBG_PRINT(INFO_DBG, "memory in tasklet\n");
 				break;
 			} else if (ret == -EFILL) {
@@ -6291,6 +6374,16 @@ static int set_rxd_buffer_pointer(struct
 				pci_map_single( sp->pdev, (*skb)->data,
 					size - NET_IP_ALIGN,
 					PCI_DMA_FROMDEVICE);
+			if ((((struct RxD1*)rxdp)->Buffer0_ptr == 0) ||
+				(((struct RxD1*)rxdp)->Buffer0_ptr == 
+				DMA_ERROR_CODE)) {
+				sp->mac_control.stats_info->sw_stat.
+					pci_map_fail_cnt++;
+				sp->mac_control.stats_info->sw_stat.mem_freed +=
+					(*skb)->truesize;
+				dev_kfree_skb(*skb);
+				return -ENOMEM;
+			}
 			rxdp->Host_Control = (unsigned long) (*skb);
 		}
 	} else if ((sp->rxd_mode == RXD_MODE_3B) && (rxdp->Host_Control == 0)) {
@@ -6315,15 +6408,51 @@ static int set_rxd_buffer_pointer(struct
 				pci_map_single(sp->pdev, (*skb)->data,
 					       dev->mtu + 4,
 					       PCI_DMA_FROMDEVICE);
+			if ((((struct RxD3*)rxdp)->Buffer2_ptr == 0) ||
+				(((struct RxD3*)rxdp)->Buffer2_ptr ==
+				DMA_ERROR_CODE)) {
+				sp->mac_control.stats_info->sw_stat.
+					pci_map_fail_cnt++;
+				sp->mac_control.stats_info->sw_stat.mem_freed +=
+					(*skb)->truesize;
+				dev_kfree_skb(*skb);
+				return -ENOMEM;
+			}
 			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0 =
 				pci_map_single( sp->pdev, ba->ba_0, BUF0_LEN,
 						PCI_DMA_FROMDEVICE);
+			if ((((struct RxD3*)rxdp)->Buffer0_ptr == 0) ||
+				(((struct RxD3*)rxdp)->Buffer0_ptr == 
+				DMA_ERROR_CODE)) {
+				sp->mac_control.stats_info->sw_stat.
+					pci_map_fail_cnt++;
+				sp->mac_control.stats_info->sw_stat.mem_freed +=
+					(*skb)->truesize;
+				pci_unmap_single (sp->pdev, 
+					(dma_addr_t)(*skb)->data,
+					dev->mtu + 4, PCI_DMA_FROMDEVICE);
+				dev_kfree_skb(*skb);
+				return -ENOMEM;
+			}
 			rxdp->Host_Control = (unsigned long) (*skb);
 
 			/* Buffer-1 will be dummy buffer not used */
 			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1 =
 				pci_map_single(sp->pdev, ba->ba_1, BUF1_LEN,
 					       PCI_DMA_FROMDEVICE);
+			if ((((struct RxD3*)rxdp)->Buffer0_ptr == 0) ||
+				(((struct RxD3*)rxdp)->Buffer0_ptr == 
+				DMA_ERROR_CODE)) {
+				sp->mac_control.stats_info->sw_stat.
+					pci_map_fail_cnt++;
+				sp->mac_control.stats_info->sw_stat.mem_freed +=
+					(*skb)->truesize;
+				pci_unmap_single (sp->pdev, 
+					(dma_addr_t)(*skb)->data,
+					dev->mtu + 4, PCI_DMA_FROMDEVICE);
+				dev_kfree_skb(*skb);
+				return -ENOMEM;
+			}
 		}
 	} else if ((rxdp->Host_Control == 0)) {
 		/* Three buffer mode */
@@ -6346,11 +6475,31 @@ static int set_rxd_buffer_pointer(struct
 			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0 =
 				pci_map_single(sp->pdev, ba->ba_0, BUF0_LEN,
 					       PCI_DMA_FROMDEVICE);
+			if ((((struct RxD3*)rxdp)->Buffer0_ptr == 0) ||
+				(((struct RxD3*)rxdp)->Buffer0_ptr == 
+				DMA_ERROR_CODE)) {
+				sp->mac_control.stats_info->sw_stat.
+					pci_map_fail_cnt++;
+				sp->mac_control.stats_info->sw_stat.mem_freed +=
+					(*skb)->truesize;
+				dev_kfree_skb(*skb);
+				return -ENOMEM;
+			}
 			/* Buffer-1 receives L3/L4 headers */
 			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1 =
 				pci_map_single( sp->pdev, (*skb)->data,
 						l3l4hdr_size + 4,
 						PCI_DMA_FROMDEVICE);
+			if ((((struct RxD3*)rxdp)->Buffer1_ptr == 0) ||
+				(((struct RxD3*)rxdp)->Buffer1_ptr == 
+				DMA_ERROR_CODE)) {
+				sp->mac_control.stats_info->sw_stat.
+					pci_map_fail_cnt++;
+				sp->mac_control.stats_info->sw_stat.mem_freed +=
+					(*skb)->truesize;
+				dev_kfree_skb(*skb);
+				return -ENOMEM;
+			}
 			/*
 			 * skb_shinfo(skb)->frag_list will have L4
 			 * data payload
@@ -6362,10 +6511,17 @@ static int set_rxd_buffer_pointer(struct
 					  failed\n ", dev->name);
 				sp->mac_control.stats_info->sw_stat. \
 					mem_alloc_fail_cnt++;
+				sp->mac_control.stats_info->sw_stat.mem_freed
+					+= (*skb)->truesize;
+				pci_unmap_single (sp->pdev, 
+					(dma_addr_t)(*skb)->data,
+					l3l4hdr_size + 4, PCI_DMA_FROMDEVICE);
+				dev_kfree_skb(*skb);
 				return -ENOMEM ;
 			}
 			frag_list = skb_shinfo(*skb)->frag_list;
 			frag_list->next = NULL;
+			(*skb)->truesize += frag_list->truesize;
 			sp->mac_control.stats_info->sw_stat.mem_allocated 
 				+= frag_list->truesize;
 			/*
@@ -6374,6 +6530,19 @@ static int set_rxd_buffer_pointer(struct
 			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2 =
 				pci_map_single( sp->pdev, frag_list->data,
 						dev->mtu, PCI_DMA_FROMDEVICE);
+			if ((((struct RxD3*)rxdp)->Buffer2_ptr == 0) ||
+				(((struct RxD3*)rxdp)->Buffer2_ptr ==
+				DMA_ERROR_CODE)) {
+				sp->mac_control.stats_info->sw_stat.
+					pci_map_fail_cnt++;
+				sp->mac_control.stats_info->sw_stat.mem_freed +=
+					(*skb)->truesize;
+				pci_unmap_single (sp->pdev,
+					(dma_addr_t)(*skb)->data,
+					l3l4hdr_size + 4, PCI_DMA_FROMDEVICE);
+				dev_kfree_skb(*skb);
+				return -ENOMEM;
+			}
 		}
 	}
 	return 0;
@@ -6668,8 +6837,8 @@ static int s2io_card_up(struct s2io_nic 
 
 	for (i = 0; i < config->rx_ring_num; i++) {
 		if ((ret = fill_rx_buffers(sp, i))) {
-			DBG_PRINT(ERR_DBG, "%s: Out of memory in Open\n",
-				  dev->name);
+			DBG_PRINT(ERR_DBG, "%s - %s: Out of memory in Open\n",
+				  __FUNCTION__, dev->name);
 			s2io_reset(sp);
 			free_rx_buffers(sp);
 			return -ENOMEM;
diff -urpN org/drivers/net/s2io.h patch_1/drivers/net/s2io.h
--- org/drivers/net/s2io.h	2007-05-17 19:26:16.000000000 +0530
+++ patch_1/drivers/net/s2io.h	2007-05-17 20:34:50.000000000 +0530
@@ -74,6 +74,10 @@ static int debug_level = ERR_DBG;
 /* DEBUG message print. */
 #define DBG_PRINT(dbg_level, args...)  if(!(debug_level<dbg_level)) printk(args)
 
+#ifndef DMA_ERROR_CODE
+#define DMA_ERROR_CODE          (~(dma_addr_t)0x0)
+#endif
+
 /* Protocol assist features of the NIC */
 #define L3_CKSUM_OK 0xFFFF
 #define L4_CKSUM_OK 0xFFFF
@@ -97,6 +101,7 @@ struct swStat {
 	unsigned long long num_aggregations;
 	/* Other statistics */
 	unsigned long long mem_alloc_fail_cnt;
+	unsigned long long pci_map_fail_cnt;
 	unsigned long long watchdog_timer_cnt;
 	unsigned long long mem_allocated;
 	unsigned long long mem_freed;
@@ -851,6 +856,7 @@ struct s2io_nic {
 
 	int task_flag;
 	unsigned long long start_time;
+	unsigned long long max_mem;
 #define CARD_DOWN 1
 #define CARD_UP 2
 	atomic_t card_state;

