From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.21 3/3]S2IO: Statistics for link up/down and memory
 allocated/freed
Date: Thu, 10 May 2007 04:22:25 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10705100419200.23138-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Leonid.Grossman@neterion.com, ramkrishna.vep@neterion.com,
	santosh.rastapur@neterion.com, Sivakumar.Subramani@neterion.com,
	Alicia.Pena@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:47821 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755726AbXEJIWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 04:22:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1. Added statistics for link up/down, last link up/down.
2. Statistics for memory allocated/freed.
3. Changed level of some DBG_PRINTs.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -pNur patch2/drivers/net/s2io.c patch3/drivers/net/s2io.c
--- patch2/drivers/net/s2io.c	2007-04-17 10:45:56.000000000 +0530
+++ patch3/drivers/net/s2io.c	2007-04-17 10:46:32.000000000 +0530
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.22.1"
+#define DRV_VERSION "2.0.23.1"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -282,7 +282,27 @@ static char ethtool_driver_stats_keys[][
 	("lro_flush_due_to_max_pkts"),
 	("lro_avg_aggr_pkts"),
 	("mem_alloc_fail_cnt"),
-	("watchdog_timer_cnt")
+	("watchdog_timer_cnt"),
+	("mem_allocated"),
+	("mem_freed"),
+	("link_up_cnt"),
+	("link_down_cnt"),
+	("link_up_time"),
+	("link_down_time"),
+	("tx_tcode_buf_abort_cnt"),
+	("tx_tcode_desc_abort_cnt"),
+	("tx_tcode_parity_err_cnt"),
+	("tx_tcode_link_loss_cnt"),
+	("tx_tcode_list_proc_err_cnt"),
+	("rx_tcode_parity_err_cnt"),
+	("rx_tcode_abort_cnt"),
+	("rx_tcode_parity_abort_cnt"),
+	("rx_tcode_rda_fail_cnt"),
+	("rx_tcode_unkn_prot_cnt"),
+	("rx_tcode_fcs_err_cnt"),
+	("rx_tcode_buf_size_err_cnt"),
+	("rx_tcode_rxd_corrupt_cnt"),
+	("rx_tcode_unkn_err_cnt")
 };
 
 #define S2IO_XENA_STAT_LEN sizeof(ethtool_xena_stats_keys)/ ETH_GSTRING_LEN
@@ -492,6 +512,7 @@ static int init_shared_mem(struct s2io_n
 
 	struct mac_info *mac_control;
 	struct config_param *config;
+	unsigned long long mem_allocated = 0;
 
 	mac_control = &nic->mac_control;
 	config = &nic->config;
@@ -521,6 +542,7 @@ static int init_shared_mem(struct s2io_n
 				  "Malloc failed for list_info\n");
 			return -ENOMEM;
 		}
+		mem_allocated += list_holder_size;
 		memset(mac_control->fifos[i].list_info, 0, list_holder_size);
 	}
 	for (i = 0; i < config->tx_fifo_num; i++) {
@@ -567,6 +589,7 @@ static int init_shared_mem(struct s2io_n
 					DBG_PRINT(INFO_DBG, "failed for TxDL\n");
 					return -ENOMEM;
 				}
+				mem_allocated += PAGE_SIZE;
 			}
 			while (k < lst_per_page) {
 				int l = (j * lst_per_page) + k;
@@ -584,6 +607,7 @@ static int init_shared_mem(struct s2io_n
 	nic->ufo_in_band_v = kcalloc(size, sizeof(u64), GFP_KERNEL);
 	if (!nic->ufo_in_band_v)
 		return -ENOMEM;
+	 mem_allocated += (size * sizeof(u64));
 
 	/* Allocation and initialization of RXDs in Rings */
 	size = 0;
@@ -641,6 +665,7 @@ static int init_shared_mem(struct s2io_n
 				rx_blocks->block_virt_addr = tmp_v_addr;
 				return -ENOMEM;
 			}
+			mem_allocated += size;
 			memset(tmp_v_addr, 0, size);
 			rx_blocks->block_virt_addr = tmp_v_addr;
 			rx_blocks->block_dma_addr = tmp_p_addr;
@@ -649,6 +674,8 @@ static int init_shared_mem(struct s2io_n
 						  GFP_KERNEL);
 			if (!rx_blocks->rxds)
 				return -ENOMEM;
+			mem_allocated += 
+			(sizeof(struct rxd_info)* rxd_count[nic->rxd_mode]);
 			for (l=0; l<rxd_count[nic->rxd_mode];l++) {
 				rx_blocks->rxds[l].virt_addr =
 					rx_blocks->block_virt_addr +
@@ -691,6 +718,7 @@ static int init_shared_mem(struct s2io_n
 				     GFP_KERNEL);
 			if (!mac_control->rings[i].ba)
 				return -ENOMEM;
+			mem_allocated +=(sizeof(struct buffAdd *) * blk_cnt);
 			for (j = 0; j < blk_cnt; j++) {
 				int k = 0;
 				mac_control->rings[i].ba[j] =
@@ -699,6 +727,8 @@ static int init_shared_mem(struct s2io_n
 						GFP_KERNEL);
 				if (!mac_control->rings[i].ba[j])
 					return -ENOMEM;
+				mem_allocated += (sizeof(struct buffAdd) *  \
+					(rxd_count[nic->rxd_mode] + 1));
 				while (k != rxd_count[nic->rxd_mode]) {
 					ba = &mac_control->rings[i].ba[j][k];
 
@@ -706,6 +736,8 @@ static int init_shared_mem(struct s2io_n
 					    (BUF0_LEN + ALIGN_SIZE, GFP_KERNEL);
 					if (!ba->ba_0_org)
 						return -ENOMEM;
+					mem_allocated += 
+						(BUF0_LEN + ALIGN_SIZE);
 					tmp = (unsigned long)ba->ba_0_org;
 					tmp += ALIGN_SIZE;
 					tmp &= ~((unsigned long) ALIGN_SIZE);
@@ -715,6 +747,8 @@ static int init_shared_mem(struct s2io_n
 					    (BUF1_LEN + ALIGN_SIZE, GFP_KERNEL);
 					if (!ba->ba_1_org)
 						return -ENOMEM;
+					mem_allocated 
+						+= (BUF1_LEN + ALIGN_SIZE);
 					tmp = (unsigned long) ba->ba_1_org;
 					tmp += ALIGN_SIZE;
 					tmp &= ~((unsigned long) ALIGN_SIZE);
@@ -738,6 +772,7 @@ static int init_shared_mem(struct s2io_n
 		 */
 		return -ENOMEM;
 	}
+	mem_allocated += size;
 	mac_control->stats_mem_sz = size;
 
 	tmp_v_addr = mac_control->stats_mem;
@@ -745,7 +780,7 @@ static int init_shared_mem(struct s2io_n
 	memset(tmp_v_addr, 0, size);
 	DBG_PRINT(INIT_DBG, "%s:Ring Mem PHY: 0x%llx\n", dev->name,
 		  (unsigned long long) tmp_p_addr);
-
+	mac_control->stats_info->sw_stat.mem_allocated += mem_allocated;
 	return SUCCESS;
 }
 
@@ -759,12 +794,14 @@ static int init_shared_mem(struct s2io_n
 static void free_shared_mem(struct s2io_nic *nic)
 {
 	int i, j, blk_cnt, size;
+	u32 ufo_size = 0;
 	void *tmp_v_addr;
 	dma_addr_t tmp_p_addr;
 	struct mac_info *mac_control;
 	struct config_param *config;
 	int lst_size, lst_per_page;
 	struct net_device *dev = nic->dev;
+	int page_num = 0;
 
 	if (!nic)
 		return;
@@ -776,8 +813,9 @@ static void free_shared_mem(struct s2io_
 	lst_per_page = PAGE_SIZE / lst_size;
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
-		int page_num = TXD_MEM_PAGE_CNT(config->tx_cfg[i].fifo_len,
-						lst_per_page);
+		ufo_size += config->tx_cfg[i].fifo_len;
+		page_num = TXD_MEM_PAGE_CNT(config->tx_cfg[i].fifo_len,
+							lst_per_page);
 		for (j = 0; j < page_num; j++) {
 			int mem_blks = (j * lst_per_page);
 			if (!mac_control->fifos[i].list_info)
@@ -792,6 +830,8 @@ static void free_shared_mem(struct s2io_
 					    mac_control->fifos[i].
 					    list_info[mem_blks].
 					    list_phy_addr);
+			nic->mac_control.stats_info->sw_stat.mem_freed 
+						+= PAGE_SIZE;
 		}
 		/* If we got a zero DMA address during allocation,
 		 * free the page now
@@ -805,8 +845,12 @@ static void free_shared_mem(struct s2io_
 				dev->name);
 			DBG_PRINT(INIT_DBG, "Virtual address %p\n",
 				mac_control->zerodma_virt_addr);
+			nic->mac_control.stats_info->sw_stat.mem_freed 
+						+= PAGE_SIZE;
 		}
 		kfree(mac_control->fifos[i].list_info);
+		nic->mac_control.stats_info->sw_stat.mem_freed += 
+		(nic->config.tx_cfg[i].fifo_len *sizeof(struct list_info_hold));
 	}
 
 	size = SIZE_OF_BLOCK;
@@ -821,7 +865,10 @@ static void free_shared_mem(struct s2io_
 				break;
 			pci_free_consistent(nic->pdev, size,
 					    tmp_v_addr, tmp_p_addr);
+			nic->mac_control.stats_info->sw_stat.mem_freed += size;
 			kfree(mac_control->rings[i].rx_blocks[j].rxds);
+			nic->mac_control.stats_info->sw_stat.mem_freed += 
+			( sizeof(struct rxd_info)* rxd_count[nic->rxd_mode]);
 		}
 	}
 
@@ -838,12 +885,20 @@ static void free_shared_mem(struct s2io_
 					struct buffAdd *ba =
 						&mac_control->rings[i].ba[j][k];
 					kfree(ba->ba_0_org);
+					nic->mac_control.stats_info->sw_stat.\
+					mem_freed += (BUF0_LEN + ALIGN_SIZE);
 					kfree(ba->ba_1_org);
+					nic->mac_control.stats_info->sw_stat.\
+					mem_freed += (BUF1_LEN + ALIGN_SIZE);
 					k++;
 				}
 				kfree(mac_control->rings[i].ba[j]);
+				nic->mac_control.stats_info->sw_stat.mem_freed 				+= (sizeof(struct buffAdd) * 
+				(rxd_count[nic->rxd_mode] + 1));
 			}
 			kfree(mac_control->rings[i].ba);
+			nic->mac_control.stats_info->sw_stat.mem_freed += 
+			(sizeof(struct buffAdd *) * blk_cnt);
 		}
 	}
 
@@ -852,9 +907,14 @@ static void free_shared_mem(struct s2io_
 				    mac_control->stats_mem_sz,
 				    mac_control->stats_mem,
 				    mac_control->stats_mem_phy);
+		nic->mac_control.stats_info->sw_stat.mem_freed += 
+			mac_control->stats_mem_sz;
 	}
-	if (nic->ufo_in_band_v)
+	if (nic->ufo_in_band_v) {
 		kfree(nic->ufo_in_band_v);
+		nic->mac_control.stats_info->sw_stat.mem_freed 
+			+= (ufo_size * sizeof(u64));
+	}
 }
 
 /**
@@ -2124,10 +2184,12 @@ static void free_tx_buffers(struct s2io_
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		for (j = 0; j < config->tx_cfg[i].fifo_len - 1; j++) {
-			txdp = (struct TxD *) mac_control->fifos[i].list_info[j].
-			    list_virt_addr;
+			txdp = (struct TxD *) \
+			mac_control->fifos[i].list_info[j].list_virt_addr;
 			skb = s2io_txdl_getskb(&mac_control->fifos[i], txdp, j);
 			if (skb) {
+				nic->mac_control.stats_info->sw_stat.mem_freed 
+					+= skb->truesize;
 				dev_kfree_skb(skb);
 				cnt++;
 			}
@@ -2194,6 +2256,8 @@ static int fill_rxd_3buf(struct s2io_nic
 	}
 	frag_list = skb_shinfo(skb)->frag_list;
 	skb->truesize += frag_list->truesize;
+	nic->mac_control.stats_info->sw_stat.mem_allocated 
+		+= frag_list->truesize;
 	frag_list->next = NULL;
 	tmp = (void *)ALIGN((long)frag_list->data, ALIGN_SIZE + 1);
 	frag_list->data = tmp;
@@ -2326,6 +2390,8 @@ static int fill_rx_buffers(struct s2io_n
 				mem_alloc_fail_cnt++;
 			return -ENOMEM ;
 		}
+		nic->mac_control.stats_info->sw_stat.mem_allocated 
+			+= skb->truesize;
 		if (nic->rxd_mode == RXD_MODE_1) {
 			/* 1 buffer mode - normal operation mode */
 			memset(rxdp, 0, sizeof(struct RxD1));
@@ -2333,7 +2399,8 @@ static int fill_rx_buffers(struct s2io_n
 			((struct RxD1*)rxdp)->Buffer0_ptr = pci_map_single
 			    (nic->pdev, skb->data, size - NET_IP_ALIGN,
 				PCI_DMA_FROMDEVICE);
-			rxdp->Control_2 = SET_BUFFER0_SIZE_1(size - NET_IP_ALIGN);
+			rxdp->Control_2 = 
+				SET_BUFFER0_SIZE_1(size - NET_IP_ALIGN);
 
 		} else if (nic->rxd_mode >= RXD_MODE_3A) {
 			/*
@@ -2347,7 +2414,7 @@ static int fill_rx_buffers(struct s2io_n
 			 * payload
 			 */
 
-			/* save the buffer pointers to avoid frequent dma mapping */
+			/* save buffer pointers to avoid frequent dma mapping */
 			Buffer0_ptr = ((struct RxD3*)rxdp)->Buffer0_ptr;
 			Buffer1_ptr = ((struct RxD3*)rxdp)->Buffer1_ptr;
 			memset(rxdp, 0, sizeof(struct RxD3));
@@ -2369,7 +2436,7 @@ static int fill_rx_buffers(struct s2io_n
 					   PCI_DMA_FROMDEVICE);
 			else
 				pci_dma_sync_single_for_device(nic->pdev,
-				    (dma_addr_t) ((struct RxD3*)rxdp)->Buffer0_ptr,
+				(dma_addr_t) ((struct RxD3*)rxdp)->Buffer0_ptr,
 				    BUF0_LEN, PCI_DMA_FROMDEVICE);
 			rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
 			if (nic->rxd_mode == RXD_MODE_3B) {
@@ -2396,6 +2463,8 @@ static int fill_rx_buffers(struct s2io_n
 			} else {
 				/* 3 buffer mode */
 				if (fill_rxd_3buf(nic, rxdp, skb) == -ENOMEM) {
+					nic->mac_control.stats_info->sw_stat.\
+					mem_freed += skb->truesize;
 					dev_kfree_skb_irq(skb);
 					if (first_rxdp) {
 						wmb();
@@ -2496,6 +2565,7 @@ static void free_rxd_blk(struct s2io_nic
 				PCI_DMA_FROMDEVICE);
 			memset(rxdp, 0, sizeof(struct RxD3));
 		}
+		sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
 		dev_kfree_skb(skb);
 		atomic_dec(&sp->rx_bufs_left[ring_no]);
 	}
@@ -2825,13 +2895,35 @@ static void tx_intr_handler(struct fifo_
 				nic->mac_control.stats_info->sw_stat.
 						parity_err_cnt++;
 			}
-			if ((err >> 48) == 0xA) {
-				DBG_PRINT(TX_DBG, "TxD returned due \
-						to loss of link\n");
-			}
-			else {
-				DBG_PRINT(ERR_DBG, "***TxD error %llx\n", err);
-			}
+
+			/* update t_code statistics */
+			err >>= 48;
+			switch(err) {
+				case 2:
+					nic->mac_control.stats_info->sw_stat.
+							tx_buf_abort_cnt++;
+				break;
+
+				case 3:
+					nic->mac_control.stats_info->sw_stat.
+							tx_desc_abort_cnt++;
+				break;
+
+				case 7:
+					nic->mac_control.stats_info->sw_stat.
+							tx_parity_err_cnt++;
+				break;
+
+				case 10:
+					nic->mac_control.stats_info->sw_stat.
+							tx_link_loss_cnt++;
+				break;
+
+				case 15:
+					nic->mac_control.stats_info->sw_stat.
+							tx_list_proc_err_cnt++;
+				break;
+                        }
 		}
 
 		skb = s2io_txdl_getskb(fifo_data, txdlp, get_info.offset);
@@ -2844,6 +2936,7 @@ static void tx_intr_handler(struct fifo_
 
 		/* Updating the statistics block */
 		nic->stats.tx_bytes += skb->len;
+		nic->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
 		dev_kfree_skb_irq(skb);
 
 		get_info.offset++;
@@ -3319,7 +3412,9 @@ static void s2io_reset(struct s2io_nic *
 	u16 subid, pci_cmd;
 	int i;
 	u16 val16;
-	unsigned long long reset_cnt = 0;
+	unsigned long long up_cnt, down_cnt, up_time, down_time, reset_cnt;
+	unsigned long long mem_alloc_cnt, mem_free_cnt, watchdog_cnt;
+
 	DBG_PRINT(INIT_DBG,"%s - Resetting XFrame card %s\n",
 			__FUNCTION__, sp->dev->name);
 
@@ -3385,11 +3480,26 @@ new_way:
 
 	/* Reset device statistics maintained by OS */
 	memset(&sp->stats, 0, sizeof (struct net_device_stats));
-	/* save reset count */
+	
+	up_cnt = sp->mac_control.stats_info->sw_stat.link_up_cnt;
+	down_cnt = sp->mac_control.stats_info->sw_stat.link_down_cnt;
+	up_time = sp->mac_control.stats_info->sw_stat.link_up_time;
+	down_time = sp->mac_control.stats_info->sw_stat.link_down_time;
 	reset_cnt = sp->mac_control.stats_info->sw_stat.soft_reset_cnt;
+	mem_alloc_cnt = sp->mac_control.stats_info->sw_stat.mem_allocated;
+	mem_free_cnt = sp->mac_control.stats_info->sw_stat.mem_freed;
+	watchdog_cnt = sp->mac_control.stats_info->sw_stat.watchdog_timer_cnt;
+	/* save link up/down time/cnt, reset/memory/watchdog cnt */
 	memset(sp->mac_control.stats_info, 0, sizeof(struct stat_block));
-	/* restore reset count */
+	/* restore link up/down time/cnt, reset/memory/watchdog cnt */
+	sp->mac_control.stats_info->sw_stat.link_up_cnt = up_cnt;
+	sp->mac_control.stats_info->sw_stat.link_down_cnt = down_cnt;
+	sp->mac_control.stats_info->sw_stat.link_up_time = up_time;
+	sp->mac_control.stats_info->sw_stat.link_down_time = down_time;
 	sp->mac_control.stats_info->sw_stat.soft_reset_cnt = reset_cnt;
+	sp->mac_control.stats_info->sw_stat.mem_allocated = mem_alloc_cnt;
+	sp->mac_control.stats_info->sw_stat.mem_freed = mem_free_cnt;
+	sp->mac_control.stats_info->sw_stat.watchdog_timer_cnt = watchdog_cnt;
 
 	/* SXE-002: Configure link and activity LED to turn it off */
 	subid = sp->pdev->subsystem_device;
@@ -3677,21 +3787,29 @@ static int s2io_enable_msi_x(struct s2io
 	nic->entries = kmalloc(MAX_REQUESTED_MSI_X * sizeof(struct msix_entry),
 			       GFP_KERNEL);
 	if (nic->entries == NULL) {
-		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", __FUNCTION__);
+		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", \
+			__FUNCTION__);
 		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		return -ENOMEM;
 	}
-	memset(nic->entries, 0, MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
+	nic->mac_control.stats_info->sw_stat.mem_allocated 
+		+= (MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
+	memset(nic->entries, 0,MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
 
 	nic->s2io_entries =
 		kmalloc(MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry),
 				   GFP_KERNEL);
 	if (nic->s2io_entries == NULL) {
-		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", __FUNCTION__);
+		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", 
+			__FUNCTION__);
 		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		kfree(nic->entries);
+		nic->mac_control.stats_info->sw_stat.mem_freed 
+			+= (MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
 		return -ENOMEM;
 	}
+	 nic->mac_control.stats_info->sw_stat.mem_allocated 
+		+= (MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
 	memset(nic->s2io_entries, 0,
 	       MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
 
@@ -3715,7 +3833,8 @@ static int s2io_enable_msi_x(struct s2io
 		rx_mat = readq(&bar0->rx_mat);
 		for (j=0; j<nic->config.rx_ring_num; j++, msix_indx++) {
 			rx_mat |= RX_MAT_SET(j, msix_indx);
-			nic->s2io_entries[msix_indx].arg = &nic->mac_control.rings[j];
+			nic->s2io_entries[msix_indx].arg 
+				= &nic->mac_control.rings[j];
 			nic->s2io_entries[msix_indx].type = MSIX_RING_TYPE;
 			nic->s2io_entries[msix_indx].in_use = MSIX_FLG;
 		}
@@ -3724,7 +3843,8 @@ static int s2io_enable_msi_x(struct s2io
 		tx_mat = readq(&bar0->tx_mat0_n[7]);
 		for (j=0; j<nic->config.rx_ring_num; j++, msix_indx++) {
 			tx_mat |= TX_MAT_SET(i, msix_indx);
-			nic->s2io_entries[msix_indx].arg = &nic->mac_control.rings[j];
+			nic->s2io_entries[msix_indx].arg 
+				= &nic->mac_control.rings[j];
 			nic->s2io_entries[msix_indx].type = MSIX_RING_TYPE;
 			nic->s2io_entries[msix_indx].in_use = MSIX_FLG;
 		}
@@ -3741,7 +3861,11 @@ static int s2io_enable_msi_x(struct s2io
 	if (ret) {
 		DBG_PRINT(ERR_DBG, "%s: Enabling MSIX failed\n", nic->dev->name);
 		kfree(nic->entries);
+		nic->mac_control.stats_info->sw_stat.mem_freed 
+			+= (MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
 		kfree(nic->s2io_entries);
+		nic->mac_control.stats_info->sw_stat.mem_freed 
+		+= (MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
 		nic->entries = NULL;
 		nic->s2io_entries = NULL;
 		nic->avail_msix_vectors = 0;
@@ -3809,10 +3933,16 @@ static int s2io_open(struct net_device *
 
 hw_init_failed:
 	if (sp->intr_type == MSI_X) {
-		if (sp->entries)
+		if (sp->entries) {
 			kfree(sp->entries);
-		if (sp->s2io_entries)
+			sp->mac_control.stats_info->sw_stat.mem_freed 
+			+= (MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
+		}
+		if (sp->s2io_entries) {
 			kfree(sp->s2io_entries);
+			sp->mac_control.stats_info->sw_stat.mem_freed 
+			+= (MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
+		}
 	}
 	return err;
 }
@@ -3873,6 +4003,13 @@ static int s2io_xmit(struct sk_buff *skb
 	config = &sp->config;
 
 	DBG_PRINT(TX_DBG, "%s: In Neterion Tx routine\n", dev->name);
+
+	if (unlikely(skb->len <= 0)) {
+		DBG_PRINT(TX_DBG, "%s:Buffer has no data..\n", dev->name);
+		dev_kfree_skb_any(skb);
+		return 0;
+}
+
 	spin_lock_irqsave(&sp->tx_lock, flags);
 	if (atomic_read(&sp->card_state) == CARD_DOWN) {
 		DBG_PRINT(TX_DBG, "%s: Card going down for reset\n",
@@ -3883,7 +4020,6 @@ static int s2io_xmit(struct sk_buff *skb
 	}
 
 	queue = 0;
-
 	/* Get Fifo number to Transmit based on vlan priority */
 	if (sp->vlgrp && vlan_tx_tag_present(skb)) {
 		vlan_tag = vlan_tx_tag_get(skb);
@@ -3907,14 +4043,6 @@ static int s2io_xmit(struct sk_buff *skb
 		return 0;
 	}
 
-	/* A buffer with no data will be dropped */
-	if (!skb->len) {
-		DBG_PRINT(TX_DBG, "%s:Buffer has no data..\n", dev->name);
-		dev_kfree_skb(skb);
-		spin_unlock_irqrestore(&sp->tx_lock, flags);
-		return 0;
-	}
-
 	offload_type = s2io_offload_type(skb);
 	if (offload_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)) {
 		txdp->Control_1 |= TXD_TCP_LSO_EN;
@@ -4010,7 +4138,7 @@ static int s2io_xmit(struct sk_buff *skb
 			  put_off, get_off);
 		netif_stop_queue(dev);
 	}
-
+	mac_control->stats_info->sw_stat.mem_allocated += skb->truesize;
 	dev->trans_start = jiffies;
 	spin_unlock_irqrestore(&sp->tx_lock, flags);
 
@@ -5026,6 +5154,7 @@ static void s2io_vpd_read(struct s2io_ni
 		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		return;
 	}
+	nic->mac_control.stats_info->sw_stat.mem_allocated += 256;
 
 	for (i = 0; i < 256; i +=4 ) {
 		pci_write_config_byte(nic->pdev, (vpd_addr + 2), i);
@@ -5065,6 +5194,7 @@ static void s2io_vpd_read(struct s2io_ni
 		memcpy(nic->product_name, &vpd_data[3], vpd_data[1]);
 	}
 	kfree(vpd_data);
+	nic->mac_control.stats_info->sw_stat.mem_freed += 256;
 }
 
 /**
@@ -5787,6 +5917,28 @@ static void s2io_get_ethtool_stats(struc
 		tmp_stats[i++] = 0;
 	tmp_stats[i++] = stat_info->sw_stat.mem_alloc_fail_cnt;
 	tmp_stats[i++] = stat_info->sw_stat.watchdog_timer_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.mem_allocated;
+	tmp_stats[i++] = stat_info->sw_stat.mem_freed;
+	tmp_stats[i++] = stat_info->sw_stat.link_up_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.link_down_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.link_up_time;
+	tmp_stats[i++] = stat_info->sw_stat.link_down_time;
+
+	tmp_stats[i++] = stat_info->sw_stat.tx_buf_abort_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.tx_desc_abort_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.tx_parity_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.tx_link_loss_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.tx_list_proc_err_cnt;
+
+	tmp_stats[i++] = stat_info->sw_stat.rx_parity_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rx_abort_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rx_parity_abort_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rx_rda_fail_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rx_unkn_prot_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rx_fcs_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rx_buf_size_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rx_rxd_corrupt_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rx_unkn_err_cnt;
 }
 
 static int s2io_ethtool_get_regs_len(struct net_device *dev)
@@ -6008,7 +6160,7 @@ static void s2io_tasklet(unsigned long d
 			if (ret == -ENOMEM) {
 				DBG_PRINT(INFO_DBG, "%s: Out of ",
 					  dev->name);
-				DBG_PRINT(ERR_DBG, "memory in tasklet\n");
+				DBG_PRINT(INFO_DBG, "memory in tasklet\n");
 				break;
 			} else if (ret == -EFILL) {
 				DBG_PRINT(INFO_DBG,
@@ -6129,6 +6281,8 @@ static int set_rxd_buffer_pointer(struct
 					mem_alloc_fail_cnt++;
 				return -ENOMEM ;
 			}
+			sp->mac_control.stats_info->sw_stat.mem_allocated 
+				+= (*skb)->truesize;
 			/* storing the mapped addr in a temp variable
 			 * such it will be used for next rxd whose
 			 * Host Control is NULL
@@ -6155,6 +6309,8 @@ static int set_rxd_buffer_pointer(struct
 					mem_alloc_fail_cnt++;
 				return -ENOMEM;
 			}
+			sp->mac_control.stats_info->sw_stat.mem_allocated 
+				+= (*skb)->truesize;
 			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2 =
 				pci_map_single(sp->pdev, (*skb)->data,
 					       dev->mtu + 4,
@@ -6185,6 +6341,8 @@ static int set_rxd_buffer_pointer(struct
 					mem_alloc_fail_cnt++;
 				return -ENOMEM;
 			}
+			sp->mac_control.stats_info->sw_stat.mem_allocated 
+				+= (*skb)->truesize;
 			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0 =
 				pci_map_single(sp->pdev, ba->ba_0, BUF0_LEN,
 					       PCI_DMA_FROMDEVICE);
@@ -6208,6 +6366,8 @@ static int set_rxd_buffer_pointer(struct
 			}
 			frag_list = skb_shinfo(*skb)->frag_list;
 			frag_list->next = NULL;
+			sp->mac_control.stats_info->sw_stat.mem_allocated 
+				+= frag_list->truesize;
 			/*
 			 * Buffer-2 receives L4 data payload
 			 */
@@ -6664,7 +6824,53 @@ static int rx_osm_handler(struct ring_in
 		if (err & 0x1) {
 			sp->mac_control.stats_info->sw_stat.parity_err_cnt++;
 		}
+		err >>= 48;
+		switch(err) {
+			case 1:
+				sp->mac_control.stats_info->sw_stat.
+				rx_parity_err_cnt++;
+			break;
+
+			case 2:
+				sp->mac_control.stats_info->sw_stat.
+				rx_abort_cnt++;
+			break;
+
+			case 3:
+				sp->mac_control.stats_info->sw_stat.
+				rx_parity_abort_cnt++;
+			break;
+
+			case 4:
+				sp->mac_control.stats_info->sw_stat.
+				rx_rda_fail_cnt++;
+			break;
+
+			case 5:
+				sp->mac_control.stats_info->sw_stat.
+				rx_unkn_prot_cnt++;
+			break;
+
+			case 6:
+				sp->mac_control.stats_info->sw_stat.
+				rx_fcs_err_cnt++;
+			break;
 
+			case 7:
+				sp->mac_control.stats_info->sw_stat.
+				rx_buf_size_err_cnt++;
+			break;
+
+			case 8:
+				sp->mac_control.stats_info->sw_stat.
+				rx_rxd_corrupt_cnt++;
+			break;
+
+			case 15:
+				sp->mac_control.stats_info->sw_stat.
+				rx_unkn_err_cnt++;
+			break;
+		}
 		/*
 		* Drop the packet if bad transfer code. Exception being
 		* 0x5, which could be due to unsupported IPv6 extension header.
@@ -6672,10 +6878,12 @@ static int rx_osm_handler(struct ring_in
 		* Note that in this case, since checksum will be incorrect,
 		* stack will validate the same.
 		*/
-		if (err && ((err >> 48) != 0x5)) {
+		if (err != 0x5) {
 			DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%llx\n",
 				dev->name, err);
 			sp->stats.rx_crc_errors++;
+			sp->mac_control.stats_info->sw_stat.mem_freed 
+				+= skb->truesize;
 			dev_kfree_skb(skb);
 			atomic_dec(&sp->rx_bufs_left[ring_no]);
 			rxdp->Host_Control = 0;
@@ -6685,7 +6893,6 @@ static int rx_osm_handler(struct ring_in
 
 	/* Updating statistics */
 	rxdp->Host_Control = 0;
-	sp->stats.rx_packets++;
 	if (sp->rxd_mode == RXD_MODE_1) {
 		int len = RXD_GET_BUFFER0_SIZE_1(rxdp->Control_2);
 
@@ -6789,7 +6996,7 @@ static int rx_osm_handler(struct ring_in
 	} else {
 		skb->ip_summed = CHECKSUM_NONE;
 	}
-
+	sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
 	if (!sp->lro) {
 		skb->protocol = eth_type_trans(skb, dev);
 		if ((sp->vlgrp && RXD_GET_VLAN_TAG(rxdp->Control_2) &&
@@ -6838,12 +7045,21 @@ static void s2io_link(struct s2io_nic * 
 		if (link == LINK_DOWN) {
 			DBG_PRINT(ERR_DBG, "%s: Link down\n", dev->name);
 			netif_carrier_off(dev);
+			if(sp->mac_control.stats_info->sw_stat.link_up_cnt)
+			sp->mac_control.stats_info->sw_stat.link_up_time = 
+				jiffies - sp->start_time;
+			sp->mac_control.stats_info->sw_stat.link_down_cnt++;
 		} else {
 			DBG_PRINT(ERR_DBG, "%s: Link Up\n", dev->name);
+			if (sp->mac_control.stats_info->sw_stat.link_down_cnt)
+			sp->mac_control.stats_info->sw_stat.link_down_time = 
+				jiffies - sp->start_time;
+			sp->mac_control.stats_info->sw_stat.link_up_cnt++;
 			netif_carrier_on(dev);
 		}
 	}
 	sp->last_link_state = link;
+	sp->start_time = jiffies;
 }
 
 /**
diff -pNur patch2/drivers/net/s2io.h patch3/drivers/net/s2io.h
--- patch2/drivers/net/s2io.h	2007-04-11 15:30:21.000000000 +0530
+++ patch3/drivers/net/s2io.h	2007-04-11 16:08:34.000000000 +0530
@@ -98,6 +98,29 @@ struct swStat {
 	/* Other statistics */
 	unsigned long long mem_alloc_fail_cnt;
 	unsigned long long watchdog_timer_cnt;
+	unsigned long long mem_allocated;
+	unsigned long long mem_freed;
+	unsigned long long link_up_cnt;
+	unsigned long long link_down_cnt;
+	unsigned long long link_up_time;
+	unsigned long long link_down_time;
+
+	/* Transfer Code statistics */
+	unsigned long long tx_buf_abort_cnt;
+	unsigned long long tx_desc_abort_cnt;
+	unsigned long long tx_parity_err_cnt;
+	unsigned long long tx_link_loss_cnt;
+	unsigned long long tx_list_proc_err_cnt;
+
+	unsigned long long rx_parity_err_cnt;
+	unsigned long long rx_abort_cnt;
+	unsigned long long rx_parity_abort_cnt;
+	unsigned long long rx_rda_fail_cnt;
+	unsigned long long rx_unkn_prot_cnt;
+	unsigned long long rx_fcs_err_cnt;
+	unsigned long long rx_buf_size_err_cnt;
+	unsigned long long rx_rxd_corrupt_cnt;
+	unsigned long long rx_unkn_err_cnt;
 };
 
 /* Xpak releated alarm and warnings */
@@ -827,6 +850,7 @@ struct s2io_nic {
 #define	LINK_UP		2
 
 	int task_flag;
+	unsigned long long start_time;
 #define CARD_DOWN 1
 #define CARD_UP 2
 	atomic_t card_state;

