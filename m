From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 03/25] bnx2x: Statistics
Date: Wed, 13 Aug 2008 17:12:31 +0300
Message-ID: <1218636751.547.77.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yitchak Gertner" <gertner@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4188 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752790AbYHMOM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:12:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Statistics
- Making sure that each drop is accounted for in the driver statistics
- Clearing the FW statistics when driver is loaded to prevent
  inconsistency with HW statistics
- Once error is detected (bnx2x_panic_dump), stop the statistics  
  before other actions (currently it is stopped last and can corrupt 
  the data) - Adding HW checksum error counter to the statistics
- Removing unused variable stats_ticks
- Using macros instead of magic numbers to indicate which statistics are
  shared per port and which are per function

Signed-off-by: Yitchak Gertner <gertner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h         |   11 ++-
 drivers/net/bnx2x_fw_defs.h |    6 +
 drivers/net/bnx2x_main.c    |  228 ++++++++++++++++++++++++++-----------------
 drivers/net/bnx2x_reg.h     |    3 +
 4 files changed, 154 insertions(+), 94 deletions(-)
 mode change 100644 => 100755 drivers/net/bnx2x_main.c

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index dc54602..9cbf0e8 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -258,8 +258,7 @@ struct bnx2x_fastpath {
 
 	unsigned long		tx_pkt,
 				rx_pkt,
-				rx_calls,
-				rx_alloc_failed;
+				rx_calls;
 	/* TPA related */
 	struct sw_rx_bd		tpa_pool[ETH_MAX_AGGREGATION_QUEUES_E1H];
 	u8			tpa_state[ETH_MAX_AGGREGATION_QUEUES_E1H];
@@ -655,6 +654,8 @@ struct bnx2x_eth_stats {
 
 	u32 brb_drop_hi;
 	u32 brb_drop_lo;
+	u32 brb_truncate_hi;
+	u32 brb_truncate_lo;
 
 	u32 jabber_packets_received;
 
@@ -671,6 +672,9 @@ struct bnx2x_eth_stats {
 	u32 mac_discard;
 
 	u32 driver_xoff;
+	u32 rx_err_discard_pkt;
+	u32 rx_skb_alloc_failed;
+	u32 hw_csum_err;
 };
 
 #define STATS_OFFSET32(stat_name) \
@@ -844,7 +848,6 @@ struct bnx2x {
 	u16			rx_ticks_int;
 	u16			rx_ticks;
 
-	u32			stats_ticks;
 	u32			lin_cnt;
 
 	int			state;
@@ -984,7 +987,7 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define PCICFG_LINK_SPEED_SHIFT		16
 
 
-#define BNX2X_NUM_STATS			39
+#define BNX2X_NUM_STATS			42
 #define BNX2X_NUM_TESTS			8
 
 #define BNX2X_MAC_LOOPBACK		0
diff --git a/drivers/net/bnx2x_fw_defs.h b/drivers/net/bnx2x_fw_defs.h
index e3da7f6..6e35761 100644
--- a/drivers/net/bnx2x_fw_defs.h
+++ b/drivers/net/bnx2x_fw_defs.h
@@ -79,6 +79,9 @@
 #define TSTORM_MAC_FILTER_CONFIG_OFFSET(function) \
 	(IS_E1H_OFFSET? (0x3008 + (function * 0x38)) : (0x1508 + \
 	(function * 0x38)))
+#define TSTORM_PER_COUNTER_ID_STATS_OFFSET(port, stats_counter_id) \
+	(IS_E1H_OFFSET ? (0x2010 + (port * 0x5b0) + (stats_counter_id * \
+	0x50)) : (0x4000 + (port * 0x3f0) + (stats_counter_id * 0x38)))
 #define TSTORM_RX_PRODS_OFFSET(port, client_id) \
 	(IS_E1H_OFFSET? (0x3350 + (port * 0x3e8) + (client_id * 0x28)) : \
 	(0x9c0 + (port * 0x2f8) + (client_id * 0x28)))
@@ -157,6 +160,9 @@
 	(IS_E1H_OFFSET? 0x2ac8 : 0xffffffff)
 #define XSTORM_HC_BTR_OFFSET(port) \
 	(IS_E1H_OFFSET? (0xa144 + (port * 0x30)) : (0x1454 + (port * 0x18)))
+#define XSTORM_PER_COUNTER_ID_STATS_OFFSET(port, stats_counter_id) \
+	(IS_E1H_OFFSET ? (0xc000 + (port * 0x3f0) + (stats_counter_id * \
+	0x38)) : (0x3378 + (port * 0x3f0) + (stats_counter_id * 0x38)))
 #define XSTORM_RATE_SHAPING_PER_VN_VARS_OFFSET(function) \
 	(IS_E1H_OFFSET? (0x2528 + (function * 0x70)) : (0x3c20 + \
 	(function * 0x70)))
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
old mode 100644
new mode 100755
index b9d376d..ac46228
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -501,6 +501,9 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 	int i;
 	u16 j, start, end;
 
+	bp->stats_state = STATS_STATE_DISABLED;
+	DP(BNX2X_MSG_STATS, "stats_state - DISABLED\n");
+
 	BNX2X_ERR("begin crash dump -----------------\n");
 
 	for_each_queue(bp, i) {
@@ -511,17 +514,20 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 			  "  tx_bd_prod(%x)  tx_bd_cons(%x)  *tx_cons_sb(%x)\n",
 			  i, fp->tx_pkt_prod, fp->tx_pkt_cons, fp->tx_bd_prod,
 			  fp->tx_bd_cons, le16_to_cpu(*fp->tx_cons_sb));
-		BNX2X_ERR("          rx_comp_prod(%x)  rx_comp_cons(%x)"
-			  "  *rx_cons_sb(%x)  *rx_bd_cons_sb(%x)"
-			  "  rx_sge_prod(%x)  last_max_sge(%x)\n",
-			  fp->rx_comp_prod, fp->rx_comp_cons,
-			  le16_to_cpu(*fp->rx_cons_sb),
-			  le16_to_cpu(*fp->rx_bd_cons_sb),
-			  fp->rx_sge_prod, fp->last_max_sge);
-		BNX2X_ERR("          fp_c_idx(%x)  fp_u_idx(%x)"
-			  "  bd data(%x,%x)  rx_alloc_failed(%lx)\n",
-			  fp->fp_c_idx, fp->fp_u_idx, hw_prods->packets_prod,
-			  hw_prods->bds_prod, fp->rx_alloc_failed);
+		BNX2X_ERR("          rx_bd_prod(%x)  rx_bd_cons(%x)"
+			  "  *rx_bd_cons_sb(%x)  rx_comp_prod(%x)"
+			  "  rx_comp_cons(%x)  *rx_cons_sb(%x)\n",
+			  fp->rx_bd_prod, fp->rx_bd_cons,
+			  le16_to_cpu(*fp->rx_bd_cons_sb), fp->rx_comp_prod,
+			  fp->rx_comp_cons, le16_to_cpu(*fp->rx_cons_sb));
+		BNX2X_ERR("          rx_sge_prod(%x)  last_max_sge(%x)"
+			  "  fp_c_idx(%x)  *sb_c_idx(%x)  fp_u_idx(%x)"
+			  "  *sb_u_idx(%x)  bd data(%x,%x)\n",
+			  fp->rx_sge_prod, fp->last_max_sge, fp->fp_c_idx,
+			  fp->status_blk->c_status_block.status_block_index,
+			  fp->fp_u_idx,
+			  fp->status_blk->u_status_block.status_block_index,
+			  hw_prods->packets_prod, hw_prods->bds_prod);
 
 		start = TX_BD(le16_to_cpu(*fp->tx_cons_sb) - 10);
 		end = TX_BD(le16_to_cpu(*fp->tx_cons_sb) + 245);
@@ -580,9 +586,6 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 	bnx2x_fw_dump(bp);
 	bnx2x_mc_assert(bp);
 	BNX2X_ERR("end crash dump -----------------\n");
-
-	bp->stats_state = STATS_STATE_DISABLED;
-	DP(BNX2X_MSG_STATS, "stats_state - DISABLED\n");
 }
 
 static void bnx2x_int_enable(struct bnx2x *bp)
@@ -1259,7 +1262,7 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		   where we are and drop the whole packet */
 		err = bnx2x_alloc_rx_sge(bp, fp, sge_idx);
 		if (unlikely(err)) {
-			fp->rx_alloc_failed++;
+			bp->eth_stats.rx_skb_alloc_failed++;
 			return err;
 		}
 
@@ -1295,14 +1298,13 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	pci_unmap_single(bp->pdev, pci_unmap_addr(rx_buf, mapping),
 			 bp->rx_buf_use_size, PCI_DMA_FROMDEVICE);
 
-	/* if alloc failed drop the packet and keep the buffer in the bin */
 	if (likely(new_skb)) {
+		/* fix ip xsum and give it to the stack */
+		/* (no need to map the new skb) */
 
 		prefetch(skb);
 		prefetch(((char *)(skb)) + 128);
 
-		/* else fix ip xsum and give it to the stack */
-		/* (no need to map the new skb) */
 #ifdef BNX2X_STOP_ON_ERROR
 		if (pad + len > bp->rx_buf_size) {
 			BNX2X_ERR("skb_put is about to fail...  "
@@ -1351,9 +1353,10 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		fp->tpa_pool[queue].skb = new_skb;
 
 	} else {
+		/* else drop the packet and keep the buffer in the bin */
 		DP(NETIF_MSG_RX_STATUS,
 		   "Failed to allocate new skb - dropping packet!\n");
-		fp->rx_alloc_failed++;
+		bp->eth_stats.rx_skb_alloc_failed++;
 	}
 
 	fp->tpa_state[queue] = BNX2X_TPA_STOP;
@@ -1504,7 +1507,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 				DP(NETIF_MSG_RX_ERR,
 				   "ERROR  flags %x  rx packet %u\n",
 				   cqe_fp_flags, sw_comp_cons);
-				/* TBD make sure MC counts this as a drop */
+				bp->eth_stats.rx_err_discard_pkt++;
 				goto reuse_rx;
 			}
 
@@ -1521,7 +1524,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 					DP(NETIF_MSG_RX_ERR,
 					   "ERROR  packet dropped "
 					   "because of alloc failure\n");
-					fp->rx_alloc_failed++;
+					bp->eth_stats.rx_skb_alloc_failed++;
 					goto reuse_rx;
 				}
 
@@ -1547,7 +1550,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 				DP(NETIF_MSG_RX_ERR,
 				   "ERROR  packet dropped because "
 				   "of alloc failure\n");
-				fp->rx_alloc_failed++;
+				bp->eth_stats.rx_skb_alloc_failed++;
 reuse_rx:
 				bnx2x_reuse_rx_skb(fp, skb, bd_cons, bd_prod);
 				goto next_rx;
@@ -1556,10 +1559,12 @@ reuse_rx:
 			skb->protocol = eth_type_trans(skb, bp->dev);
 
 			skb->ip_summed = CHECKSUM_NONE;
-			if (bp->rx_csum)
+			if (bp->rx_csum) {
 				if (likely(BNX2X_RX_CSUM_OK(cqe)))
 					skb->ip_summed = CHECKSUM_UNNECESSARY;
-
+				else
+					bp->eth_stats.hw_csum_err++;
+			}
 		}
 
 #ifdef BCM_VLAN
@@ -3039,6 +3044,8 @@ static void bnx2x_stats_init(struct bnx2x *bp)
 	memset(&(bp->port.old_nig_stats), 0, sizeof(struct nig_stats));
 	bp->port.old_nig_stats.brb_discard =
 			REG_RD(bp, NIG_REG_STAT0_BRB_DISCARD + port*0x38);
+	bp->port.old_nig_stats.brb_truncate =
+			REG_RD(bp, NIG_REG_STAT0_BRB_TRUNCATE + port*0x38);
 	REG_RD_DMAE(bp, NIG_REG_STAT0_EGRESS_MAC_PKT0 + port*0x50,
 		    &(bp->port.old_nig_stats.egress_mac_pkt0_lo), 2);
 	REG_RD_DMAE(bp, NIG_REG_STAT0_EGRESS_MAC_PKT1 + port*0x50,
@@ -3458,8 +3465,7 @@ static void bnx2x_bmac_stats_update(struct bnx2x *bp)
 	UPDATE_STAT64(rx_stat_grovr, rx_stat_dot3statsframestoolong);
 	UPDATE_STAT64(rx_stat_grfrg, rx_stat_etherstatsfragments);
 	UPDATE_STAT64(rx_stat_grjbr, rx_stat_etherstatsjabbers);
-	UPDATE_STAT64(rx_stat_grxpf, rx_stat_bmac_xpf);
-	UPDATE_STAT64(rx_stat_grxcf, rx_stat_bmac_xcf);
+	UPDATE_STAT64(rx_stat_grxcf, rx_stat_maccontrolframesreceived);
 	UPDATE_STAT64(rx_stat_grxpf, rx_stat_xoffstateentered);
 	UPDATE_STAT64(rx_stat_grxpf, rx_stat_xoffpauseframesreceived);
 	UPDATE_STAT64(tx_stat_gtxpf, tx_stat_outxoffsent);
@@ -3543,6 +3549,8 @@ static int bnx2x_hw_stats_update(struct bnx2x *bp)
 
 	ADD_EXTEND_64(pstats->brb_drop_hi, pstats->brb_drop_lo,
 		      new->brb_discard - old->brb_discard);
+	ADD_EXTEND_64(estats->brb_truncate_hi, estats->brb_truncate_lo,
+		      new->brb_truncate - old->brb_truncate);
 
 	UPDATE_STAT64_NIG(egress_mac_pkt0,
 					etherstatspkts1024octetsto1522octets);
@@ -3720,8 +3728,7 @@ static void bnx2x_net_stats_update(struct bnx2x *bp)
 	nstats->rx_length_errors =
 				estats->rx_stat_etherstatsundersizepkts_lo +
 				estats->jabber_packets_received;
-	nstats->rx_over_errors = estats->brb_drop_lo +
-				 estats->brb_truncate_discard;
+	nstats->rx_over_errors = estats->brb_drop_lo + estats->brb_truncate_lo;
 	nstats->rx_crc_errors = estats->rx_stat_dot3statsfcserrors_lo;
 	nstats->rx_frame_errors = estats->rx_stat_dot3statsalignmenterrors_lo;
 	nstats->rx_fifo_errors = old_tclient->no_buff_discard;
@@ -4201,6 +4208,7 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 			 XSTORM_DEF_SB_HC_DISABLE_OFFSET(func, index), 1);
 
 	bp->stats_pending = 0;
+	bp->set_mac_pending = 0;
 
 	bnx2x_ack_sb(bp, sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
 }
@@ -4370,13 +4378,13 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 		fp->rx_sge_prod = ring_prod;
 
 		/* Allocate BDs and initialize BD ring */
-		fp->rx_comp_cons = fp->rx_alloc_failed = 0;
+		fp->rx_comp_cons = 0;
 		cqe_ring_prod = ring_prod = 0;
 		for (i = 0; i < bp->rx_ring_size; i++) {
 			if (bnx2x_alloc_rx_skb(bp, fp, ring_prod) < 0) {
 				BNX2X_ERR("was only able to allocate "
 					  "%d rx skbs\n", i);
-				fp->rx_alloc_failed++;
+				bp->eth_stats.rx_skb_alloc_failed++;
 				break;
 			}
 			ring_prod = NEXT_RX_IDX(ring_prod);
@@ -4542,7 +4550,7 @@ static void bnx2x_set_client_config(struct bnx2x *bp)
 	int i;
 
 	tstorm_client.mtu = bp->dev->mtu + ETH_OVREHEAD;
-	tstorm_client.statistics_counter_id = 0;
+	tstorm_client.statistics_counter_id = BP_CL_ID(bp);
 	tstorm_client.config_flags =
 				TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE;
 #ifdef BCM_VLAN
@@ -4649,25 +4657,50 @@ static void bnx2x_init_internal(struct bnx2x *bp)
 	bp->rx_mode = BNX2X_RX_MODE_NONE; /* no rx until link is up */
 	bnx2x_set_storm_rx_mode(bp);
 
+	/* reset xstorm per client statistics */
+	for (i = 0; i < sizeof(struct xstorm_per_client_stats) / 4; i++) {
+		REG_WR(bp, BAR_XSTRORM_INTMEM +
+		       XSTORM_PER_COUNTER_ID_STATS_OFFSET(port, BP_CL_ID(bp)) +
+		       i*4, 0);
+	}
+	/* reset tstorm per client statistics */
+	for (i = 0; i < sizeof(struct tstorm_per_client_stats) / 4; i++) {
+		REG_WR(bp, BAR_TSTRORM_INTMEM +
+		       TSTORM_PER_COUNTER_ID_STATS_OFFSET(port, BP_CL_ID(bp)) +
+		       i*4, 0);
+	}
+
+	/* Init statistics related context */
 	stats_flags.collect_eth = 1;
 
-	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_STATS_FLAGS_OFFSET(port),
+	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_STATS_FLAGS_OFFSET(func),
 	       ((u32 *)&stats_flags)[0]);
-	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_STATS_FLAGS_OFFSET(port) + 4,
+	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_STATS_FLAGS_OFFSET(func) + 4,
 	       ((u32 *)&stats_flags)[1]);
 
-	REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_STATS_FLAGS_OFFSET(port),
+	REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_STATS_FLAGS_OFFSET(func),
 	       ((u32 *)&stats_flags)[0]);
-	REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_STATS_FLAGS_OFFSET(port) + 4,
+	REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_STATS_FLAGS_OFFSET(func) + 4,
 	       ((u32 *)&stats_flags)[1]);
 
-	REG_WR(bp, BAR_CSTRORM_INTMEM + CSTORM_STATS_FLAGS_OFFSET(port),
+	REG_WR(bp, BAR_CSTRORM_INTMEM + CSTORM_STATS_FLAGS_OFFSET(func),
 	       ((u32 *)&stats_flags)[0]);
-	REG_WR(bp, BAR_CSTRORM_INTMEM + CSTORM_STATS_FLAGS_OFFSET(port) + 4,
+	REG_WR(bp, BAR_CSTRORM_INTMEM + CSTORM_STATS_FLAGS_OFFSET(func) + 4,
 	       ((u32 *)&stats_flags)[1]);
 
-/*	DP(NETIF_MSG_IFUP, "stats_flags: 0x%08x 0x%08x\n",
-	   ((u32 *)&stats_flags)[0], ((u32 *)&stats_flags)[1]); */
+	REG_WR(bp, BAR_XSTRORM_INTMEM +
+	       XSTORM_ETH_STATS_QUERY_ADDR_OFFSET(func),
+	       U64_LO(bnx2x_sp_mapping(bp, fw_stats)));
+	REG_WR(bp, BAR_XSTRORM_INTMEM +
+	       XSTORM_ETH_STATS_QUERY_ADDR_OFFSET(func) + 4,
+	       U64_HI(bnx2x_sp_mapping(bp, fw_stats)));
+
+	REG_WR(bp, BAR_TSTRORM_INTMEM +
+	       TSTORM_ETH_STATS_QUERY_ADDR_OFFSET(func),
+	       U64_LO(bnx2x_sp_mapping(bp, fw_stats)));
+	REG_WR(bp, BAR_TSTRORM_INTMEM +
+	       TSTORM_ETH_STATS_QUERY_ADDR_OFFSET(func) + 4,
+	       U64_HI(bnx2x_sp_mapping(bp, fw_stats)));
 
 	if (CHIP_IS_E1H(bp)) {
 		REG_WR8(bp, BAR_XSTRORM_INTMEM + XSTORM_FUNCTION_MODE_OFFSET,
@@ -7386,8 +7419,6 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	bp->tx_ticks = 50;
 	bp->rx_ticks = 25;
 
-	bp->stats_ticks = 1000000 & 0xffff00;
-
 	bp->timer_interval = (CHIP_REV_IS_SLOW(bp) ? 5*HZ : HZ);
 	bp->current_interval = (poll ? poll : bp->timer_interval);
 
@@ -8137,7 +8168,6 @@ static int bnx2x_get_coalesce(struct net_device *dev,
 
 	coal->rx_coalesce_usecs = bp->rx_ticks;
 	coal->tx_coalesce_usecs = bp->tx_ticks;
-	coal->stats_block_coalesce_usecs = bp->stats_ticks;
 
 	return 0;
 }
@@ -8155,11 +8185,6 @@ static int bnx2x_set_coalesce(struct net_device *dev,
 	if (bp->tx_ticks > 0x3000)
 		bp->tx_ticks = 0x3000;
 
-	bp->stats_ticks = coal->stats_block_coalesce_usecs;
-	if (bp->stats_ticks > 0xffff00)
-		bp->stats_ticks = 0xffff00;
-	bp->stats_ticks &= 0xffff00;
-
 	if (netif_running(dev))
 		bnx2x_update_coalesce(bp);
 
@@ -8836,76 +8861,99 @@ static const struct {
 	long offset;
 	int size;
 	u32 flags;
-	char string[ETH_GSTRING_LEN];
+#define STATS_FLAGS_PORT		1
+#define STATS_FLAGS_FUNC		2
+	u8 string[ETH_GSTRING_LEN];
 } bnx2x_stats_arr[BNX2X_NUM_STATS] = {
-/* 1 */	{ STATS_OFFSET32(valid_bytes_received_hi),     8, 1, "rx_bytes" },
-	{ STATS_OFFSET32(error_bytes_received_hi),     8, 1, "rx_error_bytes" },
-	{ STATS_OFFSET32(total_bytes_transmitted_hi),  8, 1, "tx_bytes" },
-	{ STATS_OFFSET32(tx_stat_ifhcoutbadoctets_hi), 8, 0, "tx_error_bytes" },
+/* 1 */	{ STATS_OFFSET32(valid_bytes_received_hi),
+				8, STATS_FLAGS_FUNC, "rx_bytes" },
+	{ STATS_OFFSET32(error_bytes_received_hi),
+				8, STATS_FLAGS_FUNC, "rx_error_bytes" },
+	{ STATS_OFFSET32(total_bytes_transmitted_hi),
+				8, STATS_FLAGS_FUNC, "tx_bytes" },
+	{ STATS_OFFSET32(tx_stat_ifhcoutbadoctets_hi),
+				8, STATS_FLAGS_PORT, "tx_error_bytes" },
 	{ STATS_OFFSET32(total_unicast_packets_received_hi),
-						8, 1, "rx_ucast_packets" },
+				8, STATS_FLAGS_FUNC, "rx_ucast_packets" },
 	{ STATS_OFFSET32(total_multicast_packets_received_hi),
-						8, 1, "rx_mcast_packets" },
+				8, STATS_FLAGS_FUNC, "rx_mcast_packets" },
 	{ STATS_OFFSET32(total_broadcast_packets_received_hi),
-						8, 1, "rx_bcast_packets" },
+				8, STATS_FLAGS_FUNC, "rx_bcast_packets" },
 	{ STATS_OFFSET32(total_unicast_packets_transmitted_hi),
-						8, 1, "tx_packets" },
+				8, STATS_FLAGS_FUNC, "tx_packets" },
 	{ STATS_OFFSET32(tx_stat_dot3statsinternalmactransmiterrors_hi),
-						8, 0, "tx_mac_errors" },
+				8, STATS_FLAGS_PORT, "tx_mac_errors" },
 /* 10 */{ STATS_OFFSET32(rx_stat_dot3statscarriersenseerrors_hi),
-						8, 0, "tx_carrier_errors" },
+				8, STATS_FLAGS_PORT, "tx_carrier_errors" },
 	{ STATS_OFFSET32(rx_stat_dot3statsfcserrors_hi),
-						8, 0, "rx_crc_errors" },
+				8, STATS_FLAGS_PORT, "rx_crc_errors" },
 	{ STATS_OFFSET32(rx_stat_dot3statsalignmenterrors_hi),
-						8, 0, "rx_align_errors" },
+				8, STATS_FLAGS_PORT, "rx_align_errors" },
 	{ STATS_OFFSET32(tx_stat_dot3statssinglecollisionframes_hi),
-						8, 0, "tx_single_collisions" },
+				8, STATS_FLAGS_PORT, "tx_single_collisions" },
 	{ STATS_OFFSET32(tx_stat_dot3statsmultiplecollisionframes_hi),
-						8, 0, "tx_multi_collisions" },
+				8, STATS_FLAGS_PORT, "tx_multi_collisions" },
 	{ STATS_OFFSET32(tx_stat_dot3statsdeferredtransmissions_hi),
-						8, 0, "tx_deferred" },
+				8, STATS_FLAGS_PORT, "tx_deferred" },
 	{ STATS_OFFSET32(tx_stat_dot3statsexcessivecollisions_hi),
-						8, 0, "tx_excess_collisions" },
+				8, STATS_FLAGS_PORT, "tx_excess_collisions" },
 	{ STATS_OFFSET32(tx_stat_dot3statslatecollisions_hi),
-						8, 0, "tx_late_collisions" },
+				8, STATS_FLAGS_PORT, "tx_late_collisions" },
 	{ STATS_OFFSET32(tx_stat_etherstatscollisions_hi),
-						8, 0, "tx_total_collisions" },
+				8, STATS_FLAGS_PORT, "tx_total_collisions" },
 	{ STATS_OFFSET32(rx_stat_etherstatsfragments_hi),
-						8, 0, "rx_fragments" },
-/* 20 */{ STATS_OFFSET32(rx_stat_etherstatsjabbers_hi), 8, 0, "rx_jabbers" },
+				8, STATS_FLAGS_PORT, "rx_fragments" },
+/* 20 */{ STATS_OFFSET32(rx_stat_etherstatsjabbers_hi),
+				8, STATS_FLAGS_PORT, "rx_jabbers" },
 	{ STATS_OFFSET32(rx_stat_etherstatsundersizepkts_hi),
-						8, 0, "rx_undersize_packets" },
+				8, STATS_FLAGS_PORT, "rx_undersize_packets" },
 	{ STATS_OFFSET32(jabber_packets_received),
-						4, 1, "rx_oversize_packets" },
+				4, STATS_FLAGS_FUNC, "rx_oversize_packets" },
 	{ STATS_OFFSET32(tx_stat_etherstatspkts64octets_hi),
-						8, 0, "tx_64_byte_packets" },
+				8, STATS_FLAGS_PORT, "tx_64_byte_packets" },
 	{ STATS_OFFSET32(tx_stat_etherstatspkts65octetsto127octets_hi),
-					8, 0, "tx_65_to_127_byte_packets" },
+			8, STATS_FLAGS_PORT, "tx_65_to_127_byte_packets" },
 	{ STATS_OFFSET32(tx_stat_etherstatspkts128octetsto255octets_hi),
-					8, 0, "tx_128_to_255_byte_packets" },
+			8, STATS_FLAGS_PORT, "tx_128_to_255_byte_packets" },
 	{ STATS_OFFSET32(tx_stat_etherstatspkts256octetsto511octets_hi),
-					8, 0, "tx_256_to_511_byte_packets" },
+			8, STATS_FLAGS_PORT, "tx_256_to_511_byte_packets" },
 	{ STATS_OFFSET32(tx_stat_etherstatspkts512octetsto1023octets_hi),
-					8, 0, "tx_512_to_1023_byte_packets" },
+			8, STATS_FLAGS_PORT, "tx_512_to_1023_byte_packets" },
 	{ STATS_OFFSET32(etherstatspkts1024octetsto1522octets_hi),
-					8, 0, "tx_1024_to_1522_byte_packets" },
+			8, STATS_FLAGS_PORT, "tx_1024_to_1522_byte_packets" },
 	{ STATS_OFFSET32(etherstatspktsover1522octets_hi),
-					8, 0, "tx_1523_to_9022_byte_packets" },
+			8, STATS_FLAGS_PORT, "tx_1523_to_9022_byte_packets" },
 /* 30 */{ STATS_OFFSET32(rx_stat_xonpauseframesreceived_hi),
-						8, 0, "rx_xon_frames" },
+				8, STATS_FLAGS_PORT, "rx_xon_frames" },
 	{ STATS_OFFSET32(rx_stat_xoffpauseframesreceived_hi),
-						8, 0, "rx_xoff_frames" },
-	{ STATS_OFFSET32(tx_stat_outxonsent_hi),  8, 0, "tx_xon_frames" },
-	{ STATS_OFFSET32(tx_stat_outxoffsent_hi), 8, 0, "tx_xoff_frames" },
+				8, STATS_FLAGS_PORT, "rx_xoff_frames" },
+	{ STATS_OFFSET32(tx_stat_outxonsent_hi),
+				8, STATS_FLAGS_PORT, "tx_xon_frames" },
+	{ STATS_OFFSET32(tx_stat_outxoffsent_hi),
+				8, STATS_FLAGS_PORT, "tx_xoff_frames" },
 	{ STATS_OFFSET32(rx_stat_maccontrolframesreceived_hi),
-						8, 0, "rx_mac_ctrl_frames" },
-	{ STATS_OFFSET32(mac_filter_discard),   4, 1, "rx_filtered_packets" },
-	{ STATS_OFFSET32(no_buff_discard),      4, 1, "rx_discards" },
-	{ STATS_OFFSET32(xxoverflow_discard),   4, 1, "rx_fw_discards" },
-	{ STATS_OFFSET32(brb_drop_hi),          8, 1, "brb_discard" },
-/* 39 */{ STATS_OFFSET32(brb_truncate_discard), 8, 1, "brb_truncate" }
+				8, STATS_FLAGS_PORT, "rx_mac_ctrl_frames" },
+	{ STATS_OFFSET32(mac_filter_discard),
+				4, STATS_FLAGS_PORT, "rx_filtered_packets" },
+	{ STATS_OFFSET32(no_buff_discard),
+				4, STATS_FLAGS_FUNC, "rx_discards" },
+	{ STATS_OFFSET32(xxoverflow_discard),
+				4, STATS_FLAGS_PORT, "rx_fw_discards" },
+	{ STATS_OFFSET32(brb_drop_hi),
+				8, STATS_FLAGS_PORT, "brb_discard" },
+	{ STATS_OFFSET32(brb_truncate_hi),
+				8, STATS_FLAGS_PORT, "brb_truncate" },
+/* 40 */{ STATS_OFFSET32(rx_err_discard_pkt),
+				4, STATS_FLAGS_FUNC, "rx_phy_ip_err_discards"},
+	{ STATS_OFFSET32(rx_skb_alloc_failed),
+				4, STATS_FLAGS_FUNC, "rx_skb_alloc_discard" },
+/* 42 */{ STATS_OFFSET32(hw_csum_err),
+				4, STATS_FLAGS_FUNC, "rx_csum_offload_errors" }
 };
 
+#define IS_NOT_E1HMF_STAT(bp, i) \
+		(IS_E1HMF(bp) && (bnx2x_stats_arr[i].flags & STATS_FLAGS_PORT))
+
 static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 {
 	struct bnx2x *bp = netdev_priv(dev);
@@ -8914,7 +8962,7 @@ static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 	switch (stringset) {
 	case ETH_SS_STATS:
 		for (i = 0, j = 0; i < BNX2X_NUM_STATS; i++) {
-			if (IS_E1HMF(bp) && (!bnx2x_stats_arr[i].flags))
+			if (IS_NOT_E1HMF_STAT(bp, i))
 				continue;
 			strcpy(buf + j*ETH_GSTRING_LEN,
 			       bnx2x_stats_arr[i].string);
@@ -8934,7 +8982,7 @@ static int bnx2x_get_stats_count(struct net_device *dev)
 	int i, num_stats = 0;
 
 	for (i = 0; i < BNX2X_NUM_STATS; i++) {
-		if (IS_E1HMF(bp) && (!bnx2x_stats_arr[i].flags))
+		if (IS_NOT_E1HMF_STAT(bp, i))
 			continue;
 		num_stats++;
 	}
@@ -8949,7 +8997,7 @@ static void bnx2x_get_ethtool_stats(struct net_device *dev,
 	int i, j;
 
 	for (i = 0, j = 0; i < BNX2X_NUM_STATS; i++) {
-		if (IS_E1HMF(bp) && (!bnx2x_stats_arr[i].flags))
+		if (IS_NOT_E1HMF_STAT(bp, i))
 			continue;
 
 		if (bnx2x_stats_arr[i].size == 0) {
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 15c9a99..40c3a77 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -1727,6 +1727,9 @@
 /* [R 32] Rx statistics : In user packets discarded due to BRB backpressure
    for port0 */
 #define NIG_REG_STAT0_BRB_DISCARD				 0x105f0
+/* [R 32] Rx statistics : In user packets truncated due to BRB backpressure
+   for port0 */
+#define NIG_REG_STAT0_BRB_TRUNCATE				 0x105f8
 /* [WB_R 36] Tx statistics : Number of packets from emac0 or bmac0 that
    between 1024 and 1522 bytes for port0 */
 #define NIG_REG_STAT0_EGRESS_MAC_PKT0				 0x10750
-- 
1.5.3.2




