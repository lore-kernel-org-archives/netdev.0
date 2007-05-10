From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.21 2/3]S2IO: statistics for memory allocation failuers
Date: Thu, 10 May 2007 04:18:54 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10705100408510.23138-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Leonid.Grossman@neterion.com, ramkrishna.vep@neterion.com,
	santosh.rastapur@neterion.com, Sivakumar.Subramani@neterion.com,
	Alicia.Pena@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:47779 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758469AbXEJIS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 04:18:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1. Added code to count the number of memory failures.
2. Added watchdog_timer counter.
3. Changed debug level for some DBG_PRINTS.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -pNur patch1/drivers/net/s2io.c patch2/drivers/net/s2io.c
--- patch1/drivers/net/s2io.c	2007-04-17 10:45:23.000000000 +0530
+++ patch2/drivers/net/s2io.c	2007-04-17 10:45:56.000000000 +0530
@@ -281,6 +281,8 @@ static char ethtool_driver_stats_keys[][
 	("lro_out_of_sequence_pkts"),
 	("lro_flush_due_to_max_pkts"),
 	("lro_avg_aggr_pkts"),
+	("mem_alloc_fail_cnt"),
+	("watchdog_timer_cnt")
 };
 
 #define S2IO_XENA_STAT_LEN sizeof(ethtool_xena_stats_keys)/ ETH_GSTRING_LEN
@@ -2186,6 +2188,7 @@ static int fill_rxd_3buf(struct s2io_nic
 	/* skb_shinfo(skb)->frag_list will have L4 data payload */
 	skb_shinfo(skb)->frag_list = dev_alloc_skb(dev->mtu + ALIGN_SIZE);
 	if (skb_shinfo(skb)->frag_list == NULL) {
+		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		DBG_PRINT(INFO_DBG, "%s: dev_alloc_skb failed\n ", dev->name);
 		return -ENOMEM ;
 	}
@@ -2319,6 +2322,8 @@ static int fill_rx_buffers(struct s2io_n
 				wmb();
 				first_rxdp->Control_1 |= RXD_OWN_XENA;
 			}
+			nic->mac_control.stats_info->sw_stat. \
+				mem_alloc_fail_cnt++;
 			return -ENOMEM ;
 		}
 		if (nic->rxd_mode == RXD_MODE_1) {
@@ -3673,6 +3678,7 @@ static int s2io_enable_msi_x(struct s2io
 			       GFP_KERNEL);
 	if (nic->entries == NULL) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", __FUNCTION__);
+		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		return -ENOMEM;
 	}
 	memset(nic->entries, 0, MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
@@ -3682,6 +3688,7 @@ static int s2io_enable_msi_x(struct s2io
 				   GFP_KERNEL);
 	if (nic->s2io_entries == NULL) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", __FUNCTION__);
+		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		kfree(nic->entries);
 		return -ENOMEM;
 	}
@@ -5015,8 +5022,10 @@ static void s2io_vpd_read(struct s2io_ni
 	strcpy(nic->serial_num, "NOT AVAILABLE");
 
 	vpd_data = kmalloc(256, GFP_KERNEL);
-	if (!vpd_data)
+	if (!vpd_data) {
+		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		return;
+	}
 
 	for (i = 0; i < 256; i +=4 ) {
 		pci_write_config_byte(nic->pdev, (vpd_addr + 2), i);
@@ -5776,6 +5785,8 @@ static void s2io_get_ethtool_stats(struc
 	}
 	else
 		tmp_stats[i++] = 0;
+	tmp_stats[i++] = stat_info->sw_stat.mem_alloc_fail_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.watchdog_timer_cnt;
 }
 
 static int s2io_ethtool_get_regs_len(struct net_device *dev)
@@ -6112,7 +6123,10 @@ static int set_rxd_buffer_pointer(struct
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
 				DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
-				DBG_PRINT(INFO_DBG, "memory to allocate SKBs\n");
+				DBG_PRINT(INFO_DBG, "memory to allocate ");
+				DBG_PRINT(INFO_DBG, "1 buf mode SKBs\n");
+				sp->mac_control.stats_info->sw_stat. \
+					mem_alloc_fail_cnt++;
 				return -ENOMEM ;
 			}
 			/* storing the mapped addr in a temp variable
@@ -6134,8 +6148,11 @@ static int set_rxd_buffer_pointer(struct
 		} else {
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
-				DBG_PRINT(INFO_DBG, "%s: dev_alloc_skb failed\n",
-					dev->name);
+				DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
+				DBG_PRINT(INFO_DBG, "memory to allocate ");
+				DBG_PRINT(INFO_DBG, "2 buf mode SKBs\n");
+				sp->mac_control.stats_info->sw_stat. \
+					mem_alloc_fail_cnt++;
 				return -ENOMEM;
 			}
 			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2 =
@@ -6161,8 +6178,11 @@ static int set_rxd_buffer_pointer(struct
 		} else {
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
-				DBG_PRINT(INFO_DBG, "%s: dev_alloc_skb failed\n",
-					  dev->name);
+				DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
+				DBG_PRINT(INFO_DBG, "memory to allocate ");
+				DBG_PRINT(INFO_DBG, "3 buf mode SKBs\n");
+				sp->mac_control.stats_info->sw_stat. \
+					mem_alloc_fail_cnt++;
 				return -ENOMEM;
 			}
 			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0 =
@@ -6182,6 +6202,8 @@ static int set_rxd_buffer_pointer(struct
 			if (skb_shinfo(*skb)->frag_list == NULL) {
 				DBG_PRINT(ERR_DBG, "%s: dev_alloc_skb \
 					  failed\n ", dev->name);
+				sp->mac_control.stats_info->sw_stat. \
+					mem_alloc_fail_cnt++;
 				return -ENOMEM ;
 			}
 			frag_list = skb_shinfo(*skb)->frag_list;
@@ -6601,6 +6623,7 @@ static void s2io_tx_watchdog(struct net_
 	struct s2io_nic *sp = dev->priv;
 
 	if (netif_carrier_ok(dev)) {
+		sp->mac_control.stats_info->sw_stat.watchdog_timer_cnt++;
 		schedule_work(&sp->rst_timer_task);
 		sp->mac_control.stats_info->sw_stat.soft_reset_cnt++;
 	}
diff -pNur patch1/drivers/net/s2io.h patch2/drivers/net/s2io.h
--- patch1/drivers/net/s2io.h	2007-04-17 10:45:32.000000000 +0530
+++ patch2/drivers/net/s2io.h	2007-04-11 15:30:21.000000000 +0530
@@ -95,6 +95,9 @@ struct swStat {
 	unsigned long long flush_max_pkts;
 	unsigned long long sum_avg_pkts_aggregated;
 	unsigned long long num_aggregations;
+	/* Other statistics */
+	unsigned long long mem_alloc_fail_cnt;
+	unsigned long long watchdog_timer_cnt;
 };
 
 /* Xpak releated alarm and warnings */

