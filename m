From: Veena Parat <Veena.Parat@neterion.com>
Subject: [PATCH 2.6.22 3/4]S2IO: Checking for the return value of pci map
 function
Date: Mon, 23 Jul 2007 02:37:14 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10707230233480.2793-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:55928 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757322AbXGWGhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 02:37:17 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 - Checking for the return value of pci map function
 - Implemented Francois Romieu's comments on eliminating code duplication
   using goto
 - Implemented Francois Romieu's comments on using a temporary variable for
   accessing statistics structure

Signed-off-by: Veena Parat <veena.parat@neterion.com>
---
diff -urpN patch_2/drivers/net/s2io.c patch_3/drivers/net/s2io.c
--- patch_2/drivers/net/s2io.c	2007-07-19 15:09:20.000000000 +0530
+++ patch_3/drivers/net/s2io.c	2007-07-19 17:44:54.000000000 +0530
@@ -282,6 +282,7 @@ static char ethtool_driver_stats_keys[][
 	("lro_flush_due_to_max_pkts"),
 	("lro_avg_aggr_pkts"),
 	("mem_alloc_fail_cnt"),
+	("pci_map_fail_cnt"),
 	("watchdog_timer_cnt"),
 	("mem_allocated"),
 	("mem_freed"),
@@ -2271,6 +2272,7 @@ static int fill_rx_buffers(struct s2io_n
 	u64 Buffer0_ptr = 0, Buffer1_ptr = 0;
 	struct RxD1 *rxdp1;
 	struct RxD3 *rxdp3;
+	struct swStat *stats = &nic->mac_control.stats_info->sw_stat;
 
 	mac_control = &nic->mac_control;
 	config = &nic->config;
@@ -2360,6 +2362,11 @@ static int fill_rx_buffers(struct s2io_n
 			rxdp1->Buffer0_ptr = pci_map_single
 			    (nic->pdev, skb->data, size - NET_IP_ALIGN,
 				PCI_DMA_FROMDEVICE);
+			if( (rxdp1->Buffer0_ptr == 0) ||
+				(rxdp1->Buffer0_ptr ==
+				DMA_ERROR_CODE))
+				goto pci_map_failed;
+
 			rxdp->Control_2 = 
 				SET_BUFFER0_SIZE_1(size - NET_IP_ALIGN);
 
@@ -2395,6 +2402,10 @@ static int fill_rx_buffers(struct s2io_n
 				pci_dma_sync_single_for_device(nic->pdev,
 				(dma_addr_t) rxdp3->Buffer0_ptr,
 				    BUF0_LEN, PCI_DMA_FROMDEVICE);
+			if( (rxdp3->Buffer0_ptr == 0) ||
+				(rxdp3->Buffer0_ptr == DMA_ERROR_CODE))
+				goto pci_map_failed;
+
 			rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
 			if (nic->rxd_mode == RXD_MODE_3B) {
 				/* Two buffer mode */
@@ -2407,12 +2418,22 @@ static int fill_rx_buffers(struct s2io_n
 				(nic->pdev, skb->data, dev->mtu + 4,
 						PCI_DMA_FROMDEVICE);
 
-				/* Buffer-1 will be dummy buffer. Not used */
-				if (!(rxdp3->Buffer1_ptr)) {
-					rxdp3->Buffer1_ptr =
+				if( (rxdp3->Buffer2_ptr == 0) ||
+					(rxdp3->Buffer2_ptr == DMA_ERROR_CODE))
+					goto pci_map_failed;
+
+				rxdp3->Buffer1_ptr =
 						pci_map_single(nic->pdev,
 						ba->ba_1, BUF1_LEN,
 						PCI_DMA_FROMDEVICE);
+				if( (rxdp3->Buffer1_ptr == 0) ||
+					(rxdp3->Buffer1_ptr == DMA_ERROR_CODE)) {
+					pci_unmap_single
+						(nic->pdev,
+						(dma_addr_t)skb->data,
+						dev->mtu + 4,
+						PCI_DMA_FROMDEVICE);
+					goto pci_map_failed;
 				}
 				rxdp->Control_2 |= SET_BUFFER1_SIZE_3(1);
 				rxdp->Control_2 |= SET_BUFFER2_SIZE_3
@@ -2451,6 +2472,11 @@ static int fill_rx_buffers(struct s2io_n
 	}
 
 	return SUCCESS;
+pci_map_failed:
+	stats->pci_map_fail_cnt++;
+	stats->mem_freed += skb->truesize;
+	dev_kfree_skb_irq(skb);
+	return -ENOMEM;
 }
 
 static void free_rxd_blk(struct s2io_nic *sp, int ring_no, int blk)
@@ -3882,6 +3908,7 @@ static int s2io_xmit(struct sk_buff *skb
 	struct mac_info *mac_control;
 	struct config_param *config;
 	int offload_type;
+	struct swStat *stats = &sp->mac_control.stats_info->sw_stat;
 
 	mac_control = &sp->mac_control;
 	config = &sp->config;
@@ -3966,11 +3993,18 @@ static int s2io_xmit(struct sk_buff *skb
 		txdp->Buffer_Pointer = pci_map_single(sp->pdev,
 					sp->ufo_in_band_v,
 					sizeof(u64), PCI_DMA_TODEVICE);
+		if((txdp->Buffer_Pointer == 0) ||
+			(txdp->Buffer_Pointer == DMA_ERROR_CODE))
+			goto pci_map_failed;
 		txdp++;
 	}
 
 	txdp->Buffer_Pointer = pci_map_single
 	    (sp->pdev, skb->data, frg_len, PCI_DMA_TODEVICE);
+	if((txdp->Buffer_Pointer == 0) ||
+		(txdp->Buffer_Pointer == DMA_ERROR_CODE))
+		goto pci_map_failed;
+
 	txdp->Host_Control = (unsigned long) skb;
 	txdp->Control_1 |= TXD_BUFFER0_SIZE(frg_len);
 	if (offload_type == SKB_GSO_UDP)
@@ -4027,6 +4061,13 @@ static int s2io_xmit(struct sk_buff *skb
 	spin_unlock_irqrestore(&sp->tx_lock, flags);
 
 	return 0;
+pci_map_failed:
+	stats->pci_map_fail_cnt++;
+	netif_stop_queue(dev);
+	stats->mem_freed += skb->truesize;
+	dev_kfree_skb(skb);
+	spin_unlock_irqrestore(&sp->tx_lock, flags);
+	return 0;
 }
 
 static void
@@ -5769,6 +5810,7 @@ static void s2io_get_ethtool_stats(struc
 	else
 		tmp_stats[i++] = 0;
 	tmp_stats[i++] = stat_info->sw_stat.mem_alloc_fail_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.pci_map_fail_cnt;
 	tmp_stats[i++] = stat_info->sw_stat.watchdog_timer_cnt;
 	tmp_stats[i++] = stat_info->sw_stat.mem_allocated;
 	tmp_stats[i++] = stat_info->sw_stat.mem_freed;
@@ -6112,6 +6154,7 @@ static int set_rxd_buffer_pointer(struct
 				u64 *temp2, int size)
 {
 	struct net_device *dev = sp->dev;
+	struct swStat *stats = &sp->mac_control.stats_info->sw_stat;
 
 	if ((sp->rxd_mode == RXD_MODE_1) && (rxdp->Host_Control == 0)) {
 		struct RxD1 *rxdp1 = (struct RxD1 *)rxdp;
@@ -6144,6 +6187,10 @@ static int set_rxd_buffer_pointer(struct
 				pci_map_single( sp->pdev, (*skb)->data,
 					size - NET_IP_ALIGN,
 					PCI_DMA_FROMDEVICE);
+			if( (rxdp1->Buffer0_ptr == 0) ||
+				(rxdp1->Buffer0_ptr == DMA_ERROR_CODE)) {
+				goto memalloc_failed;
+			}
 			rxdp->Host_Control = (unsigned long) (*skb);
 		}
 	} else if ((sp->rxd_mode == RXD_MODE_3B) && (rxdp->Host_Control == 0)) {
@@ -6169,19 +6216,43 @@ static int set_rxd_buffer_pointer(struct
 				pci_map_single(sp->pdev, (*skb)->data,
 					       dev->mtu + 4,
 					       PCI_DMA_FROMDEVICE);
+			if( (rxdp3->Buffer2_ptr == 0) ||
+				(rxdp3->Buffer2_ptr == DMA_ERROR_CODE)) {
+				goto memalloc_failed;
+			}
 			rxdp3->Buffer0_ptr = *temp0 =
 				pci_map_single( sp->pdev, ba->ba_0, BUF0_LEN,
 						PCI_DMA_FROMDEVICE);
+			if( (rxdp3->Buffer0_ptr == 0) ||
+				(rxdp3->Buffer0_ptr == DMA_ERROR_CODE)) {
+				pci_unmap_single (sp->pdev,
+					(dma_addr_t)(*skb)->data,
+					dev->mtu + 4, PCI_DMA_FROMDEVICE);
+				goto memalloc_failed;
+			}
 			rxdp->Host_Control = (unsigned long) (*skb);
 
 			/* Buffer-1 will be dummy buffer not used */
 			rxdp3->Buffer1_ptr = *temp1 =
 				pci_map_single(sp->pdev, ba->ba_1, BUF1_LEN,
 						PCI_DMA_FROMDEVICE);
+			if( (rxdp3->Buffer1_ptr == 0) ||
+				(rxdp3->Buffer1_ptr == DMA_ERROR_CODE)) {
+				pci_unmap_single (sp->pdev,
+					(dma_addr_t)(*skb)->data,
+					dev->mtu + 4, PCI_DMA_FROMDEVICE);
+				goto memalloc_failed;
+			}
 		}
 	}
 	return 0;
+	memalloc_failed:
+		stats->pci_map_fail_cnt++;
+		stats->mem_freed += (*skb)->truesize;
+		dev_kfree_skb(*skb);
+		return -ENOMEM;
 }
+
 static void set_rxd_buffer_size(struct s2io_nic *sp, struct RxD_t *rxdp,
 				int size)
 {
diff -urpN patch_2/drivers/net/s2io.h patch_3/drivers/net/s2io.h
--- patch_2/drivers/net/s2io.h	2007-07-19 15:09:20.000000000 +0530
+++ patch_3/drivers/net/s2io.h	2007-07-19 16:45:26.000000000 +0530
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

