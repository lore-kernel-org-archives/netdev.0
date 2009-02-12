From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 07/41]bnx2x: Per queue statistics
Date: Thu, 12 Feb 2009 20:36:33 +0200
Message-ID: <1234463793.1863.138.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2663 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758219AbZBLShG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:37:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 07/41]bnx2x: Per queue statistics
Re-ordering the statistics to enhance readability and adding per queue
statistics (available via ethtool -S)

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h         |   67 +++-
 drivers/net/bnx2x_fw_defs.h |    9 +
 drivers/net/bnx2x_hsi.h     |   37 ++-
 drivers/net/bnx2x_main.c    |  804 +++++++++++++++++++++++++++++--------------
 4 files changed, 643 insertions(+), 274 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index cfbeabb..b411497 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -189,6 +189,43 @@ struct sw_rx_page {
 #define NEXT_SGE_MASK_ELEM(el)		(((el) + 1) & RX_SGE_MASK_LEN_MASK)
 
 
+struct bnx2x_eth_q_stats {
+	u32 total_bytes_received_hi;
+	u32 total_bytes_received_lo;
+	u32 total_bytes_transmitted_hi;
+	u32 total_bytes_transmitted_lo;
+	u32 total_unicast_packets_received_hi;
+	u32 total_unicast_packets_received_lo;
+	u32 total_multicast_packets_received_hi;
+	u32 total_multicast_packets_received_lo;
+	u32 total_broadcast_packets_received_hi;
+	u32 total_broadcast_packets_received_lo;
+	u32 total_unicast_packets_transmitted_hi;
+	u32 total_unicast_packets_transmitted_lo;
+	u32 total_multicast_packets_transmitted_hi;
+	u32 total_multicast_packets_transmitted_lo;
+	u32 total_broadcast_packets_transmitted_hi;
+	u32 total_broadcast_packets_transmitted_lo;
+	u32 valid_bytes_received_hi;
+	u32 valid_bytes_received_lo;
+
+	u32 error_bytes_received_hi;
+	u32 error_bytes_received_lo;
+	u32 etherstatsoverrsizepkts_hi;
+	u32 etherstatsoverrsizepkts_lo;
+	u32 no_buff_discard_hi;
+	u32 no_buff_discard_lo;
+
+	u32 driver_xoff;
+	u32 rx_err_discard_pkt;
+	u32 rx_skb_alloc_failed;
+	u32 hw_csum_err;
+};
+
+#define BNX2X_NUM_Q_STATS		11
+#define Q_STATS_OFFSET32(stat_name) \
+			(offsetof(struct bnx2x_eth_q_stats, stat_name) / 4)
+
 struct bnx2x_fastpath {
 
 	struct napi_struct	napi;
@@ -268,6 +305,11 @@ struct bnx2x_fastpath {
 	u64			tpa_queue_used;
 #endif
 
+	struct tstorm_per_client_stats old_tclient;
+	struct ustorm_per_client_stats old_uclient;
+	struct xstorm_per_client_stats old_xclient;
+	struct bnx2x_eth_q_stats eth_q_stats;
+
 	char			name[IFNAMSIZ];
 	struct bnx2x		*bp; /* parent */
 };
@@ -576,6 +618,10 @@ struct bnx2x_eth_stats {
 
 	u32 error_bytes_received_hi;
 	u32 error_bytes_received_lo;
+	u32 etherstatsoverrsizepkts_hi;
+	u32 etherstatsoverrsizepkts_lo;
+	u32 no_buff_discard_hi;
+	u32 no_buff_discard_lo;
 
 	u32 rx_stat_ifhcinbadoctets_hi;
 	u32 rx_stat_ifhcinbadoctets_lo;
@@ -654,19 +700,20 @@ struct bnx2x_eth_stats {
 	u32 tx_stat_bmac_ufl_hi;
 	u32 tx_stat_bmac_ufl_lo;
 
-	u32 brb_drop_hi;
-	u32 brb_drop_lo;
-	u32 brb_truncate_hi;
-	u32 brb_truncate_lo;
-
-	u32 jabber_packets_received;
+	u32 pause_frames_received_hi;
+	u32 pause_frames_received_lo;
+	u32 pause_frames_sent_hi;
+	u32 pause_frames_sent_lo;
 
 	u32 etherstatspkts1024octetsto1522octets_hi;
 	u32 etherstatspkts1024octetsto1522octets_lo;
 	u32 etherstatspktsover1522octets_hi;
 	u32 etherstatspktsover1522octets_lo;
 
-	u32 no_buff_discard;
+	u32 brb_drop_hi;
+	u32 brb_drop_lo;
+	u32 brb_truncate_hi;
+	u32 brb_truncate_lo;
 
 	u32 mac_filter_discard;
 	u32 xxoverflow_discard;
@@ -677,8 +724,11 @@ struct bnx2x_eth_stats {
 	u32 rx_err_discard_pkt;
 	u32 rx_skb_alloc_failed;
 	u32 hw_csum_err;
+
+	u32 nig_timer_max;
 };
 
+#define BNX2X_NUM_STATS			41
 #define STATS_OFFSET32(stat_name) \
 			(offsetof(struct bnx2x_eth_stats, stat_name) / 4)
 
@@ -906,8 +956,6 @@ struct bnx2x {
 	int			executer_idx;
 
 	u16			stats_counter;
-	struct tstorm_per_client_stats old_tclient;
-	struct xstorm_per_client_stats old_xclient;
 	struct bnx2x_eth_stats	eth_stats;
 
 	struct z_stream_s	*strm;
@@ -1008,7 +1056,6 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define PCICFG_LINK_SPEED_SHIFT		16
 
 
-#define BNX2X_NUM_STATS			42
 #define BNX2X_NUM_TESTS			7
 
 #define BNX2X_MAC_LOOPBACK		0
diff --git a/drivers/net/bnx2x_fw_defs.h b/drivers/net/bnx2x_fw_defs.h
index 9eb1d13..59bb132 100644
--- a/drivers/net/bnx2x_fw_defs.h
+++ b/drivers/net/bnx2x_fw_defs.h
@@ -107,6 +107,9 @@
 #define USTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(function) \
 	(IS_E1H_OFFSET ? (0x9508 + ((function>>1) * 0x40) + \
 	((function&1) * 0x100)) : (0x1908 + (function * 0x40)))
+#define USTORM_ETH_STATS_QUERY_ADDR_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x2a50 + (function * 0x8)) : (0x1d98 + \
+	(function * 0x8)))
 #define USTORM_FUNCTION_MODE_OFFSET \
 	(IS_E1H_OFFSET ? 0x2448 : 0xffffffff)
 #define USTORM_HC_BTR_OFFSET(port) \
@@ -117,6 +120,9 @@
 #define USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(function) \
 	(IS_E1H_OFFSET ? (0x2408 + (function * 0x8)) : (0x5308 + \
 	(function * 0x8)))
+#define USTORM_PER_COUNTER_ID_STATS_OFFSET(port, stats_counter_id) \
+	(IS_E1H_OFFSET ? (0x2450 + (port * 0x2d0) + (stats_counter_id * \
+	0x28)) : (0x4740 + (port * 0x2d0) + (stats_counter_id * 0x28)))
 #define USTORM_RX_PRODS_OFFSET(port, client_id) \
 	(IS_E1H_OFFSET ? (0x8000 + (port * 0x4b0) + (client_id * 0x30)) \
 	: (0x5318 + (port * 0x260) + (client_id * 0x20)))
@@ -134,6 +140,9 @@
 #define USTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, cpu_id) \
 	(IS_E1H_OFFSET ? (0x9008 + (port * 0x280) + (cpu_id * 0x28)) : \
 	(0x1408 + (port * 0x280) + (cpu_id * 0x28)))
+#define USTORM_STATS_FLAGS_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x29f0 + (function * 0x8)) : (0x1d80 + \
+	(function * 0x8)))
 #define XSTORM_ASSERT_LIST_INDEX_OFFSET \
 	(IS_E1H_OFFSET ? 0x9000 : 0x1000)
 #define XSTORM_ASSERT_LIST_OFFSET(idx) \
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index 25751a2..40061b3 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -641,7 +641,8 @@ struct drv_port_mb {
 
 	u32 port_stx;
 
-	u32 reserved[2];
+	u32 stat_nig_timer;
+
 
 };
 
@@ -1429,8 +1430,10 @@ struct ustorm_eth_st_context_config {
 #define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA_SHIFT 2
 #define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_SGE_RING (0x1<<3)
 #define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_SGE_RING_SHIFT 3
-#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0 (0xF<<4)
-#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0_SHIFT 4
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS (0x1<<4)
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS_SHIFT 4
+#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0 (0x7<<5)
+#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0_SHIFT 5
 	u8 status_block_id;
 	u8 clientId;
 	u8 sb_index_numbers;
@@ -1455,8 +1458,10 @@ struct ustorm_eth_st_context_config {
 #define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA_SHIFT 2
 #define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_SGE_RING (0x1<<3)
 #define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_SGE_RING_SHIFT 3
-#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0 (0xF<<4)
-#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0_SHIFT 4
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS (0x1<<4)
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS_SHIFT 4
+#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0 (0x7<<5)
+#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0_SHIFT 5
 #endif
 #if defined(__BIG_ENDIAN)
 	u16 bd_buff_size;
@@ -2764,11 +2769,33 @@ struct tstorm_common_stats {
 };
 
 /*
+ * Protocol-common statistics collected by the Ustorm (per client)
+ */
+struct ustorm_per_client_stats {
+	struct regpair ucast_no_buff_bytes;
+	struct regpair mcast_no_buff_bytes;
+	struct regpair bcast_no_buff_bytes;
+	__le32 ucast_no_buff_pkts;
+	__le32 mcast_no_buff_pkts;
+	__le32 bcast_no_buff_pkts;
+	__le16 stats_counter;
+	__le16 reserved0;
+};
+
+/*
+ * Protocol-common statistics collected by the Ustorm
+ */
+struct ustorm_common_stats {
+ struct ustorm_per_client_stats client_statistics[MAX_U_STAT_COUNTER_ID];
+};
+
+/*
  * Eth statistics query structure for the eth_stats_query ramrod
  */
 struct eth_stats_query {
 	struct xstorm_common_stats xstorm_common;
 	struct tstorm_common_stats tstorm_common;
+	struct ustorm_common_stats ustorm_common;
 };
 
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index c27be17..19865d5 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1271,7 +1271,7 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		   where we are and drop the whole packet */
 		err = bnx2x_alloc_rx_sge(bp, fp, sge_idx);
 		if (unlikely(err)) {
-			bp->eth_stats.rx_skb_alloc_failed++;
+			fp->eth_q_stats.rx_skb_alloc_failed++;
 			return err;
 		}
 
@@ -1377,7 +1377,7 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		/* else drop the packet and keep the buffer in the bin */
 		DP(NETIF_MSG_RX_STATUS,
 		   "Failed to allocate new skb - dropping packet!\n");
-		bp->eth_stats.rx_skb_alloc_failed++;
+		fp->eth_q_stats.rx_skb_alloc_failed++;
 	}
 
 	fp->tpa_state[queue] = BNX2X_TPA_STOP;
@@ -1539,7 +1539,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 				DP(NETIF_MSG_RX_ERR,
 				   "ERROR  flags %x  rx packet %u\n",
 				   cqe_fp_flags, sw_comp_cons);
-				bp->eth_stats.rx_err_discard_pkt++;
+				fp->eth_q_stats.rx_err_discard_pkt++;
 				goto reuse_rx;
 			}
 
@@ -1556,7 +1556,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 					DP(NETIF_MSG_RX_ERR,
 					   "ERROR  packet dropped "
 					   "because of alloc failure\n");
-					bp->eth_stats.rx_skb_alloc_failed++;
+					fp->eth_q_stats.rx_skb_alloc_failed++;
 					goto reuse_rx;
 				}
 
@@ -1582,7 +1582,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 				DP(NETIF_MSG_RX_ERR,
 				   "ERROR  packet dropped because "
 				   "of alloc failure\n");
-				bp->eth_stats.rx_skb_alloc_failed++;
+				fp->eth_q_stats.rx_skb_alloc_failed++;
 reuse_rx:
 				bnx2x_reuse_rx_skb(fp, skb, bd_cons, bd_prod);
 				goto next_rx;
@@ -1595,7 +1595,7 @@ reuse_rx:
 				if (likely(BNX2X_RX_CSUM_OK(cqe)))
 					skb->ip_summed = CHECKSUM_UNNECESSARY;
 				else
-					bp->eth_stats.hw_csum_err++;
+					fp->eth_q_stats.hw_csum_err++;
 			}
 		}
 
@@ -2897,10 +2897,6 @@ static void bnx2x_sp_task(struct work_struct *work)
 	if (status & 0x1)
 		bnx2x_attn_int(bp);
 
-	/* CStorm events: query_stats, port delete ramrod */
-	if (status & 0x2)
-		bp->stats_pending = 0;
-
 	bnx2x_ack_sb(bp, DEF_SB_ID, ATTENTION_ID, le16_to_cpu(bp->def_att_idx),
 		     IGU_INT_NOP, 1);
 	bnx2x_ack_sb(bp, DEF_SB_ID, USTORM_ID, le16_to_cpu(bp->def_u_idx),
@@ -3016,14 +3012,39 @@ static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 	do { \
 		diff = le32_to_cpu(tclient->s) - old_tclient->s; \
 		old_tclient->s = le32_to_cpu(tclient->s); \
-		ADD_EXTEND_64(fstats->t##_hi, fstats->t##_lo, diff); \
+		ADD_EXTEND_64(qstats->t##_hi, qstats->t##_lo, diff); \
+	} while (0)
+
+#define UPDATE_EXTEND_USTAT(s, t) \
+	do { \
+		diff = le32_to_cpu(uclient->s) - le32_to_cpu(old_uclient->s); \
+		old_uclient->s = uclient->s; \
+		ADD_EXTEND_64(qstats->t##_hi, qstats->t##_lo, diff); \
 	} while (0)
 
 #define UPDATE_EXTEND_XSTAT(s, t) \
 	do { \
 		diff = le32_to_cpu(xclient->s) - old_xclient->s; \
 		old_xclient->s = le32_to_cpu(xclient->s); \
-		ADD_EXTEND_64(fstats->t##_hi, fstats->t##_lo, diff); \
+		ADD_EXTEND_64(qstats->t##_hi, qstats->t##_lo, diff); \
+	} while (0)
+
+/* minuend -= subtrahend */
+#define SUB_64(m_hi, s_hi, m_lo, s_lo) \
+	do { \
+		DIFF_64(m_hi, m_hi, s_hi, m_lo, m_lo, s_lo); \
+	} while (0)
+
+/* minuend[hi:lo] -= subtrahend */
+#define SUB_EXTEND_64(m_hi, m_lo, s) \
+	do { \
+		SUB_64(m_hi, 0, m_lo, s); \
+	} while (0)
+
+#define SUB_EXTEND_USTAT(s, t) \
+	do { \
+		diff = le32_to_cpu(uclient->s) - le32_to_cpu(old_uclient->s); \
+		SUB_EXTEND_64(qstats->t##_hi, qstats->t##_lo, diff); \
 	} while (0)
 
 /*
@@ -3050,11 +3071,12 @@ static void bnx2x_storm_stats_post(struct bnx2x *bp)
 {
 	if (!bp->stats_pending) {
 		struct eth_query_ramrod_data ramrod_data = {0};
-		int rc;
+		int i, rc;
 
 		ramrod_data.drv_counter = bp->stats_counter++;
 		ramrod_data.collect_port = bp->port.pmf ? 1 : 0;
-		ramrod_data.ctr_id_vector = (1 << BP_CL_ID(bp));
+		for_each_queue(bp, i)
+			ramrod_data.ctr_id_vector |= (1 << bp->fp[i].cl_id);
 
 		rc = bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_STAT_QUERY, 0,
 				   ((u32 *)&ramrod_data)[1],
@@ -3070,7 +3092,9 @@ static void bnx2x_storm_stats_post(struct bnx2x *bp)
 static void bnx2x_stats_init(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
+	int i;
 
+	bp->stats_pending = 0;
 	bp->executer_idx = 0;
 	bp->stats_counter = 0;
 
@@ -3092,9 +3116,19 @@ static void bnx2x_stats_init(struct bnx2x *bp)
 		    &(bp->port.old_nig_stats.egress_mac_pkt1_lo), 2);
 
 	/* function stats */
+	for_each_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
+
+		memset(&fp->old_tclient, 0,
+		       sizeof(struct tstorm_per_client_stats));
+		memset(&fp->old_uclient, 0,
+		       sizeof(struct ustorm_per_client_stats));
+		memset(&fp->old_xclient, 0,
+		       sizeof(struct xstorm_per_client_stats));
+		memset(&fp->eth_q_stats, 0, sizeof(struct bnx2x_eth_q_stats));
+	}
+
 	memset(&bp->dev->stats, 0, sizeof(struct net_device_stats));
-	memset(&bp->old_tclient, 0, sizeof(struct tstorm_per_client_stats));
-	memset(&bp->old_xclient, 0, sizeof(struct xstorm_per_client_stats));
 	memset(&bp->eth_stats, 0, sizeof(struct bnx2x_eth_stats));
 
 	bp->stats_state = STATS_STATE_DISABLED;
@@ -3108,6 +3142,8 @@ static void bnx2x_hw_stats_post(struct bnx2x *bp)
 	u32 *stats_comp = bnx2x_sp(bp, stats_comp);
 
 	*stats_comp = DMAE_COMP_VAL;
+	if (CHIP_REV_IS_SLOW(bp))
+		return;
 
 	/* loader */
 	if (bp->executer_idx) {
@@ -3497,6 +3533,7 @@ static void bnx2x_bmac_stats_update(struct bnx2x *bp)
 {
 	struct bmac_stats *new = bnx2x_sp(bp, mac_stats.bmac_stats);
 	struct host_port_stats *pstats = bnx2x_sp(bp, port_stats);
+	struct bnx2x_eth_stats *estats = &bp->eth_stats;
 	struct regpair diff;
 
 	UPDATE_STAT64(rx_stat_grerb, rx_stat_ifhcinbadoctets);
@@ -3507,7 +3544,7 @@ static void bnx2x_bmac_stats_update(struct bnx2x *bp)
 	UPDATE_STAT64(rx_stat_grjbr, rx_stat_etherstatsjabbers);
 	UPDATE_STAT64(rx_stat_grxcf, rx_stat_maccontrolframesreceived);
 	UPDATE_STAT64(rx_stat_grxpf, rx_stat_xoffstateentered);
-	UPDATE_STAT64(rx_stat_grxpf, rx_stat_xoffpauseframesreceived);
+	UPDATE_STAT64(rx_stat_grxpf, rx_stat_bmac_xpf);
 	UPDATE_STAT64(tx_stat_gtxpf, tx_stat_outxoffsent);
 	UPDATE_STAT64(tx_stat_gtxpf, tx_stat_flowcontroldone);
 	UPDATE_STAT64(tx_stat_gt64, tx_stat_etherstatspkts64octets);
@@ -3528,12 +3565,23 @@ static void bnx2x_bmac_stats_update(struct bnx2x *bp)
 	UPDATE_STAT64(tx_stat_gterr,
 				tx_stat_dot3statsinternalmactransmiterrors);
 	UPDATE_STAT64(tx_stat_gtufl, tx_stat_bmac_ufl);
+
+	estats->pause_frames_received_hi =
+				pstats->mac_stx[1].rx_stat_bmac_xpf_hi;
+	estats->pause_frames_received_lo =
+				pstats->mac_stx[1].rx_stat_bmac_xpf_lo;
+
+	estats->pause_frames_sent_hi =
+				pstats->mac_stx[1].tx_stat_outxoffsent_hi;
+	estats->pause_frames_sent_lo =
+				pstats->mac_stx[1].tx_stat_outxoffsent_lo;
 }
 
 static void bnx2x_emac_stats_update(struct bnx2x *bp)
 {
 	struct emac_stats *new = bnx2x_sp(bp, mac_stats.emac_stats);
 	struct host_port_stats *pstats = bnx2x_sp(bp, port_stats);
+	struct bnx2x_eth_stats *estats = &bp->eth_stats;
 
 	UPDATE_EXTEND_STAT(rx_stat_ifhcinbadoctets);
 	UPDATE_EXTEND_STAT(tx_stat_ifhcoutbadoctets);
@@ -3566,6 +3614,24 @@ static void bnx2x_emac_stats_update(struct bnx2x *bp)
 	UPDATE_EXTEND_STAT(tx_stat_etherstatspkts1024octetsto1522octets);
 	UPDATE_EXTEND_STAT(tx_stat_etherstatspktsover1522octets);
 	UPDATE_EXTEND_STAT(tx_stat_dot3statsinternalmactransmiterrors);
+
+	estats->pause_frames_received_hi =
+			pstats->mac_stx[1].rx_stat_xonpauseframesreceived_hi;
+	estats->pause_frames_received_lo =
+			pstats->mac_stx[1].rx_stat_xonpauseframesreceived_lo;
+	ADD_64(estats->pause_frames_received_hi,
+	       pstats->mac_stx[1].rx_stat_xoffpauseframesreceived_hi,
+	       estats->pause_frames_received_lo,
+	       pstats->mac_stx[1].rx_stat_xoffpauseframesreceived_lo);
+
+	estats->pause_frames_sent_hi =
+			pstats->mac_stx[1].tx_stat_outxonsent_hi;
+	estats->pause_frames_sent_lo =
+			pstats->mac_stx[1].tx_stat_outxonsent_lo;
+	ADD_64(estats->pause_frames_sent_hi,
+	       pstats->mac_stx[1].tx_stat_outxoffsent_hi,
+	       estats->pause_frames_sent_lo,
+	       pstats->mac_stx[1].tx_stat_outxoffsent_lo);
 }
 
 static int bnx2x_hw_stats_update(struct bnx2x *bp)
@@ -3575,6 +3641,7 @@ static int bnx2x_hw_stats_update(struct bnx2x *bp)
 	struct host_port_stats *pstats = bnx2x_sp(bp, port_stats);
 	struct bnx2x_eth_stats *estats = &bp->eth_stats;
 	struct regpair diff;
+	u32 nig_timer_max;
 
 	if (bp->link_vars.mac_type == MAC_TYPE_BMAC)
 		bnx2x_bmac_stats_update(bp);
@@ -3605,134 +3672,211 @@ static int bnx2x_hw_stats_update(struct bnx2x *bp)
 
 	pstats->host_port_stats_start = ++pstats->host_port_stats_end;
 
+	nig_timer_max = SHMEM_RD(bp, port_mb[BP_PORT(bp)].stat_nig_timer);
+	if (nig_timer_max != estats->nig_timer_max) {
+		estats->nig_timer_max = nig_timer_max;
+		BNX2X_ERR("NIG timer max (%u)\n", estats->nig_timer_max);
+	}
+
 	return 0;
 }
 
 static int bnx2x_storm_stats_update(struct bnx2x *bp)
 {
 	struct eth_stats_query *stats = bnx2x_sp(bp, fw_stats);
-	int cl_id = BP_CL_ID(bp);
 	struct tstorm_per_port_stats *tport =
-				&stats->tstorm_common.port_statistics;
-	struct tstorm_per_client_stats *tclient =
-			&stats->tstorm_common.client_statistics[cl_id];
-	struct tstorm_per_client_stats *old_tclient = &bp->old_tclient;
-	struct xstorm_per_client_stats *xclient =
-			&stats->xstorm_common.client_statistics[cl_id];
-	struct xstorm_per_client_stats *old_xclient = &bp->old_xclient;
+					&stats->tstorm_common.port_statistics;
 	struct host_func_stats *fstats = bnx2x_sp(bp, func_stats);
 	struct bnx2x_eth_stats *estats = &bp->eth_stats;
-	u32 diff;
+	int i;
+
+	memset(&(fstats->total_bytes_received_hi), 0,
+	       sizeof(struct host_func_stats) - 2*sizeof(u32));
+	estats->error_bytes_received_hi = 0;
+	estats->error_bytes_received_lo = 0;
+	estats->etherstatsoverrsizepkts_hi = 0;
+	estats->etherstatsoverrsizepkts_lo = 0;
+	estats->no_buff_discard_hi = 0;
+	estats->no_buff_discard_lo = 0;
 
-	/* are storm stats valid? */
-	if ((u16)(le16_to_cpu(tclient->stats_counter) + 1) !=
+	for_each_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
+		int cl_id = fp->cl_id;
+		struct tstorm_per_client_stats *tclient =
+				&stats->tstorm_common.client_statistics[cl_id];
+		struct tstorm_per_client_stats *old_tclient = &fp->old_tclient;
+		struct ustorm_per_client_stats *uclient =
+				&stats->ustorm_common.client_statistics[cl_id];
+		struct ustorm_per_client_stats *old_uclient = &fp->old_uclient;
+		struct xstorm_per_client_stats *xclient =
+				&stats->xstorm_common.client_statistics[cl_id];
+		struct xstorm_per_client_stats *old_xclient = &fp->old_xclient;
+		struct bnx2x_eth_q_stats *qstats = &fp->eth_q_stats;
+		u32 diff;
+
+		/* are storm stats valid? */
+		if ((u16)(le16_to_cpu(xclient->stats_counter) + 1) !=
 							bp->stats_counter) {
-		DP(BNX2X_MSG_STATS, "stats not updated by tstorm"
-		   "  tstorm counter (%d) != stats_counter (%d)\n",
-		   tclient->stats_counter, bp->stats_counter);
-		return -1;
-	}
-	if ((u16)(le16_to_cpu(xclient->stats_counter) + 1) !=
+			DP(BNX2X_MSG_STATS, "[%d] stats not updated by xstorm"
+			   "  xstorm counter (%d) != stats_counter (%d)\n",
+			   i, xclient->stats_counter, bp->stats_counter);
+			return -1;
+		}
+		if ((u16)(le16_to_cpu(tclient->stats_counter) + 1) !=
 							bp->stats_counter) {
-		DP(BNX2X_MSG_STATS, "stats not updated by xstorm"
-		   "  xstorm counter (%d) != stats_counter (%d)\n",
-		   xclient->stats_counter, bp->stats_counter);
-		return -2;
-	}
+			DP(BNX2X_MSG_STATS, "[%d] stats not updated by tstorm"
+			   "  tstorm counter (%d) != stats_counter (%d)\n",
+			   i, tclient->stats_counter, bp->stats_counter);
+			return -2;
+		}
+		if ((u16)(le16_to_cpu(uclient->stats_counter) + 1) !=
+							bp->stats_counter) {
+			DP(BNX2X_MSG_STATS, "[%d] stats not updated by ustorm"
+			   "  ustorm counter (%d) != stats_counter (%d)\n",
+			   i, uclient->stats_counter, bp->stats_counter);
+			return -4;
+		}
 
-	fstats->total_bytes_received_hi =
-	fstats->valid_bytes_received_hi =
+		qstats->total_bytes_received_hi =
+		qstats->valid_bytes_received_hi =
 				le32_to_cpu(tclient->total_rcv_bytes.hi);
-	fstats->total_bytes_received_lo =
-	fstats->valid_bytes_received_lo =
+		qstats->total_bytes_received_lo =
+		qstats->valid_bytes_received_lo =
 				le32_to_cpu(tclient->total_rcv_bytes.lo);
 
-	estats->error_bytes_received_hi =
+		qstats->error_bytes_received_hi =
 				le32_to_cpu(tclient->rcv_error_bytes.hi);
-	estats->error_bytes_received_lo =
+		qstats->error_bytes_received_lo =
 				le32_to_cpu(tclient->rcv_error_bytes.lo);
-	ADD_64(estats->error_bytes_received_hi,
-	       estats->rx_stat_ifhcinbadoctets_hi,
-	       estats->error_bytes_received_lo,
-	       estats->rx_stat_ifhcinbadoctets_lo);
 
-	ADD_64(fstats->total_bytes_received_hi,
-	       estats->error_bytes_received_hi,
-	       fstats->total_bytes_received_lo,
-	       estats->error_bytes_received_lo);
-
-	UPDATE_EXTEND_TSTAT(rcv_unicast_pkts, total_unicast_packets_received);
-	UPDATE_EXTEND_TSTAT(rcv_multicast_pkts,
-				total_multicast_packets_received);
-	UPDATE_EXTEND_TSTAT(rcv_broadcast_pkts,
-				total_broadcast_packets_received);
-
-	fstats->total_bytes_transmitted_hi =
+		ADD_64(qstats->total_bytes_received_hi,
+		       qstats->error_bytes_received_hi,
+		       qstats->total_bytes_received_lo,
+		       qstats->error_bytes_received_lo);
+
+		UPDATE_EXTEND_TSTAT(rcv_unicast_pkts,
+					total_unicast_packets_received);
+		UPDATE_EXTEND_TSTAT(rcv_multicast_pkts,
+					total_multicast_packets_received);
+		UPDATE_EXTEND_TSTAT(rcv_broadcast_pkts,
+					total_broadcast_packets_received);
+		UPDATE_EXTEND_TSTAT(packets_too_big_discard,
+					etherstatsoverrsizepkts);
+		UPDATE_EXTEND_TSTAT(no_buff_discard, no_buff_discard);
+
+		SUB_EXTEND_USTAT(ucast_no_buff_pkts,
+					total_unicast_packets_received);
+		SUB_EXTEND_USTAT(mcast_no_buff_pkts,
+					total_multicast_packets_received);
+		SUB_EXTEND_USTAT(bcast_no_buff_pkts,
+					total_broadcast_packets_received);
+		UPDATE_EXTEND_USTAT(ucast_no_buff_pkts, no_buff_discard);
+		UPDATE_EXTEND_USTAT(mcast_no_buff_pkts, no_buff_discard);
+		UPDATE_EXTEND_USTAT(bcast_no_buff_pkts, no_buff_discard);
+
+		qstats->total_bytes_transmitted_hi =
 				le32_to_cpu(xclient->total_sent_bytes.hi);
-	fstats->total_bytes_transmitted_lo =
+		qstats->total_bytes_transmitted_lo =
 				le32_to_cpu(xclient->total_sent_bytes.lo);
 
-	UPDATE_EXTEND_XSTAT(unicast_pkts_sent,
-				total_unicast_packets_transmitted);
-	UPDATE_EXTEND_XSTAT(multicast_pkts_sent,
-				total_multicast_packets_transmitted);
-	UPDATE_EXTEND_XSTAT(broadcast_pkts_sent,
-				total_broadcast_packets_transmitted);
+		UPDATE_EXTEND_XSTAT(unicast_pkts_sent,
+					total_unicast_packets_transmitted);
+		UPDATE_EXTEND_XSTAT(multicast_pkts_sent,
+					total_multicast_packets_transmitted);
+		UPDATE_EXTEND_XSTAT(broadcast_pkts_sent,
+					total_broadcast_packets_transmitted);
+
+		old_tclient->checksum_discard = tclient->checksum_discard;
+		old_tclient->ttl0_discard = tclient->ttl0_discard;
+
+		ADD_64(fstats->total_bytes_received_hi,
+		       qstats->total_bytes_received_hi,
+		       fstats->total_bytes_received_lo,
+		       qstats->total_bytes_received_lo);
+		ADD_64(fstats->total_bytes_transmitted_hi,
+		       qstats->total_bytes_transmitted_hi,
+		       fstats->total_bytes_transmitted_lo,
+		       qstats->total_bytes_transmitted_lo);
+		ADD_64(fstats->total_unicast_packets_received_hi,
+		       qstats->total_unicast_packets_received_hi,
+		       fstats->total_unicast_packets_received_lo,
+		       qstats->total_unicast_packets_received_lo);
+		ADD_64(fstats->total_multicast_packets_received_hi,
+		       qstats->total_multicast_packets_received_hi,
+		       fstats->total_multicast_packets_received_lo,
+		       qstats->total_multicast_packets_received_lo);
+		ADD_64(fstats->total_broadcast_packets_received_hi,
+		       qstats->total_broadcast_packets_received_hi,
+		       fstats->total_broadcast_packets_received_lo,
+		       qstats->total_broadcast_packets_received_lo);
+		ADD_64(fstats->total_unicast_packets_transmitted_hi,
+		       qstats->total_unicast_packets_transmitted_hi,
+		       fstats->total_unicast_packets_transmitted_lo,
+		       qstats->total_unicast_packets_transmitted_lo);
+		ADD_64(fstats->total_multicast_packets_transmitted_hi,
+		       qstats->total_multicast_packets_transmitted_hi,
+		       fstats->total_multicast_packets_transmitted_lo,
+		       qstats->total_multicast_packets_transmitted_lo);
+		ADD_64(fstats->total_broadcast_packets_transmitted_hi,
+		       qstats->total_broadcast_packets_transmitted_hi,
+		       fstats->total_broadcast_packets_transmitted_lo,
+		       qstats->total_broadcast_packets_transmitted_lo);
+		ADD_64(fstats->valid_bytes_received_hi,
+		       qstats->valid_bytes_received_hi,
+		       fstats->valid_bytes_received_lo,
+		       qstats->valid_bytes_received_lo);
+
+		ADD_64(estats->error_bytes_received_hi,
+		       qstats->error_bytes_received_hi,
+		       estats->error_bytes_received_lo,
+		       qstats->error_bytes_received_lo);
+		ADD_64(estats->etherstatsoverrsizepkts_hi,
+		       qstats->etherstatsoverrsizepkts_hi,
+		       estats->etherstatsoverrsizepkts_lo,
+		       qstats->etherstatsoverrsizepkts_lo);
+		ADD_64(estats->no_buff_discard_hi, qstats->no_buff_discard_hi,
+		       estats->no_buff_discard_lo, qstats->no_buff_discard_lo);
+	}
+
+	ADD_64(fstats->total_bytes_received_hi,
+	       estats->rx_stat_ifhcinbadoctets_hi,
+	       fstats->total_bytes_received_lo,
+	       estats->rx_stat_ifhcinbadoctets_lo);
 
 	memcpy(estats, &(fstats->total_bytes_received_hi),
 	       sizeof(struct host_func_stats) - 2*sizeof(u32));
 
-	estats->mac_filter_discard = le32_to_cpu(tport->mac_filter_discard);
-	estats->xxoverflow_discard = le32_to_cpu(tport->xxoverflow_discard);
-	estats->brb_truncate_discard =
+	ADD_64(estats->etherstatsoverrsizepkts_hi,
+	       estats->rx_stat_dot3statsframestoolong_hi,
+	       estats->etherstatsoverrsizepkts_lo,
+	       estats->rx_stat_dot3statsframestoolong_lo);
+	ADD_64(estats->error_bytes_received_hi,
+	       estats->rx_stat_ifhcinbadoctets_hi,
+	       estats->error_bytes_received_lo,
+	       estats->rx_stat_ifhcinbadoctets_lo);
+
+	if (bp->port.pmf) {
+		estats->mac_filter_discard =
+				le32_to_cpu(tport->mac_filter_discard);
+		estats->xxoverflow_discard =
+				le32_to_cpu(tport->xxoverflow_discard);
+		estats->brb_truncate_discard =
 				le32_to_cpu(tport->brb_truncate_discard);
-	estats->mac_discard = le32_to_cpu(tport->mac_discard);
-
-	old_tclient->rcv_unicast_bytes.hi =
-				le32_to_cpu(tclient->rcv_unicast_bytes.hi);
-	old_tclient->rcv_unicast_bytes.lo =
-				le32_to_cpu(tclient->rcv_unicast_bytes.lo);
-	old_tclient->rcv_broadcast_bytes.hi =
-				le32_to_cpu(tclient->rcv_broadcast_bytes.hi);
-	old_tclient->rcv_broadcast_bytes.lo =
-				le32_to_cpu(tclient->rcv_broadcast_bytes.lo);
-	old_tclient->rcv_multicast_bytes.hi =
-				le32_to_cpu(tclient->rcv_multicast_bytes.hi);
-	old_tclient->rcv_multicast_bytes.lo =
-				le32_to_cpu(tclient->rcv_multicast_bytes.lo);
-	old_tclient->total_rcv_pkts = le32_to_cpu(tclient->total_rcv_pkts);
-
-	old_tclient->checksum_discard = le32_to_cpu(tclient->checksum_discard);
-	old_tclient->packets_too_big_discard =
-				le32_to_cpu(tclient->packets_too_big_discard);
-	estats->no_buff_discard =
-	old_tclient->no_buff_discard = le32_to_cpu(tclient->no_buff_discard);
-	old_tclient->ttl0_discard = le32_to_cpu(tclient->ttl0_discard);
-
-	old_xclient->total_sent_pkts = le32_to_cpu(xclient->total_sent_pkts);
-	old_xclient->unicast_bytes_sent.hi =
-				le32_to_cpu(xclient->unicast_bytes_sent.hi);
-	old_xclient->unicast_bytes_sent.lo =
-				le32_to_cpu(xclient->unicast_bytes_sent.lo);
-	old_xclient->multicast_bytes_sent.hi =
-				le32_to_cpu(xclient->multicast_bytes_sent.hi);
-	old_xclient->multicast_bytes_sent.lo =
-				le32_to_cpu(xclient->multicast_bytes_sent.lo);
-	old_xclient->broadcast_bytes_sent.hi =
-				le32_to_cpu(xclient->broadcast_bytes_sent.hi);
-	old_xclient->broadcast_bytes_sent.lo =
-				le32_to_cpu(xclient->broadcast_bytes_sent.lo);
+		estats->mac_discard = le32_to_cpu(tport->mac_discard);
+	}
 
 	fstats->host_func_stats_start = ++fstats->host_func_stats_end;
 
+	bp->stats_pending = 0;
+
 	return 0;
 }
 
 static void bnx2x_net_stats_update(struct bnx2x *bp)
 {
-	struct tstorm_per_client_stats *old_tclient = &bp->old_tclient;
 	struct bnx2x_eth_stats *estats = &bp->eth_stats;
 	struct net_device_stats *nstats = &bp->dev->stats;
+	int i;
 
 	nstats->rx_packets =
 		bnx2x_hilo(&estats->total_unicast_packets_received_hi) +
@@ -3744,34 +3888,33 @@ static void bnx2x_net_stats_update(struct bnx2x *bp)
 		bnx2x_hilo(&estats->total_multicast_packets_transmitted_hi) +
 		bnx2x_hilo(&estats->total_broadcast_packets_transmitted_hi);
 
-	nstats->rx_bytes = bnx2x_hilo(&estats->valid_bytes_received_hi);
+	nstats->rx_bytes = bnx2x_hilo(&estats->total_bytes_received_hi);
 
 	nstats->tx_bytes = bnx2x_hilo(&estats->total_bytes_transmitted_hi);
 
-	nstats->rx_dropped = old_tclient->checksum_discard +
-			     estats->mac_discard;
+	nstats->rx_dropped = estats->mac_discard;
+	for_each_queue(bp, i)
+		nstats->rx_dropped +=
+			le32_to_cpu(bp->fp[i].old_tclient.checksum_discard);
+
 	nstats->tx_dropped = 0;
 
 	nstats->multicast =
-		bnx2x_hilo(&estats->total_multicast_packets_transmitted_hi);
+		bnx2x_hilo(&estats->total_multicast_packets_received_hi);
 
 	nstats->collisions =
-			estats->tx_stat_dot3statssinglecollisionframes_lo +
-			estats->tx_stat_dot3statsmultiplecollisionframes_lo +
-			estats->tx_stat_dot3statslatecollisions_lo +
-			estats->tx_stat_dot3statsexcessivecollisions_lo;
-
-	estats->jabber_packets_received =
-				old_tclient->packets_too_big_discard +
-				estats->rx_stat_dot3statsframestoolong_lo;
+		bnx2x_hilo(&estats->tx_stat_etherstatscollisions_hi);
 
 	nstats->rx_length_errors =
-				estats->rx_stat_etherstatsundersizepkts_lo +
-				estats->jabber_packets_received;
-	nstats->rx_over_errors = estats->brb_drop_lo + estats->brb_truncate_lo;
-	nstats->rx_crc_errors = estats->rx_stat_dot3statsfcserrors_lo;
-	nstats->rx_frame_errors = estats->rx_stat_dot3statsalignmenterrors_lo;
-	nstats->rx_fifo_errors = old_tclient->no_buff_discard;
+		bnx2x_hilo(&estats->rx_stat_etherstatsundersizepkts_hi) +
+		bnx2x_hilo(&estats->etherstatsoverrsizepkts_hi);
+	nstats->rx_over_errors = bnx2x_hilo(&estats->brb_drop_hi) +
+				 bnx2x_hilo(&estats->brb_truncate_hi);
+	nstats->rx_crc_errors =
+		bnx2x_hilo(&estats->rx_stat_dot3statsfcserrors_hi);
+	nstats->rx_frame_errors =
+		bnx2x_hilo(&estats->rx_stat_dot3statsalignmenterrors_hi);
+	nstats->rx_fifo_errors = bnx2x_hilo(&estats->no_buff_discard_hi);
 	nstats->rx_missed_errors = estats->xxoverflow_discard;
 
 	nstats->rx_errors = nstats->rx_length_errors +
@@ -3782,46 +3925,61 @@ static void bnx2x_net_stats_update(struct bnx2x *bp)
 			    nstats->rx_missed_errors;
 
 	nstats->tx_aborted_errors =
-			estats->tx_stat_dot3statslatecollisions_lo +
-			estats->tx_stat_dot3statsexcessivecollisions_lo;
-	nstats->tx_carrier_errors = estats->rx_stat_falsecarriererrors_lo;
+		bnx2x_hilo(&estats->tx_stat_dot3statslatecollisions_hi) +
+		bnx2x_hilo(&estats->tx_stat_dot3statsexcessivecollisions_hi);
+	nstats->tx_carrier_errors =
+		bnx2x_hilo(&estats->rx_stat_dot3statscarriersenseerrors_hi);
 	nstats->tx_fifo_errors = 0;
 	nstats->tx_heartbeat_errors = 0;
 	nstats->tx_window_errors = 0;
 
 	nstats->tx_errors = nstats->tx_aborted_errors +
-			    nstats->tx_carrier_errors;
+			    nstats->tx_carrier_errors +
+	    bnx2x_hilo(&estats->tx_stat_dot3statsinternalmactransmiterrors_hi);
+}
+
+static void bnx2x_drv_stats_update(struct bnx2x *bp)
+{
+	struct bnx2x_eth_stats *estats = &bp->eth_stats;
+	int i;
+
+	estats->driver_xoff = 0;
+	estats->rx_err_discard_pkt = 0;
+	estats->rx_skb_alloc_failed = 0;
+	estats->hw_csum_err = 0;
+	for_each_queue(bp, i) {
+		struct bnx2x_eth_q_stats *qstats = &bp->fp[i].eth_q_stats;
+
+		estats->driver_xoff += qstats->driver_xoff;
+		estats->rx_err_discard_pkt += qstats->rx_err_discard_pkt;
+		estats->rx_skb_alloc_failed += qstats->rx_skb_alloc_failed;
+		estats->hw_csum_err += qstats->hw_csum_err;
+	}
 }
 
 static void bnx2x_stats_update(struct bnx2x *bp)
 {
 	u32 *stats_comp = bnx2x_sp(bp, stats_comp);
-	int update = 0;
 
 	if (*stats_comp != DMAE_COMP_VAL)
 		return;
 
 	if (bp->port.pmf)
-		update = (bnx2x_hw_stats_update(bp) == 0);
-
-	update |= (bnx2x_storm_stats_update(bp) == 0);
+		bnx2x_hw_stats_update(bp);
 
-	if (update)
-		bnx2x_net_stats_update(bp);
-
-	else {
-		if (bp->stats_pending) {
-			bp->stats_pending++;
-			if (bp->stats_pending == 3) {
-				BNX2X_ERR("stats not updated for 3 times\n");
-				bnx2x_panic();
-				return;
-			}
-		}
+	if (bnx2x_storm_stats_update(bp) && (bp->stats_pending++ == 3)) {
+		BNX2X_ERR("storm stats were not updated for 3 times\n");
+		bnx2x_panic();
+		return;
 	}
 
+	bnx2x_net_stats_update(bp);
+	bnx2x_drv_stats_update(bp);
+
 	if (bp->msglevel & NETIF_MSG_TIMER) {
-		struct tstorm_per_client_stats *old_tclient = &bp->old_tclient;
+		struct tstorm_per_client_stats *old_tclient =
+							&bp->fp->old_tclient;
+		struct bnx2x_eth_q_stats *qstats = &bp->fp->eth_q_stats;
 		struct bnx2x_eth_stats *estats = &bp->eth_stats;
 		struct net_device_stats *nstats = &bp->dev->stats;
 		int i;
@@ -3836,19 +3994,21 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 		       (u16)(le16_to_cpu(*bp->fp->rx_cons_sb) -
 			     bp->fp->rx_comp_cons),
 		       le16_to_cpu(*bp->fp->rx_cons_sb), nstats->rx_packets);
-		printk(KERN_DEBUG "  %s (Xoff events %u)  brb drops %u\n",
-		       netif_queue_stopped(bp->dev) ? "Xoff" : "Xon",
-		       estats->driver_xoff, estats->brb_drop_lo);
+		printk(KERN_DEBUG "  %s (Xoff events %u)  brb drops %u  "
+				  "brb truncate %u\n",
+		       (netif_queue_stopped(bp->dev) ? "Xoff" : "Xon"),
+		       qstats->driver_xoff,
+		       estats->brb_drop_lo, estats->brb_truncate_lo);
 		printk(KERN_DEBUG "tstats: checksum_discard %u  "
-			"packets_too_big_discard %u  no_buff_discard %u  "
+			"packets_too_big_discard %lu  no_buff_discard %lu  "
 			"mac_discard %u  mac_filter_discard %u  "
 			"xxovrflow_discard %u  brb_truncate_discard %u  "
 			"ttl0_discard %u\n",
 		       old_tclient->checksum_discard,
-		       old_tclient->packets_too_big_discard,
-		       old_tclient->no_buff_discard, estats->mac_discard,
-		       estats->mac_filter_discard, estats->xxoverflow_discard,
-		       estats->brb_truncate_discard,
+		       bnx2x_hilo(&qstats->etherstatsoverrsizepkts_hi),
+		       bnx2x_hilo(&qstats->no_buff_discard_hi),
+		       estats->mac_discard, estats->mac_filter_discard,
+		       estats->xxoverflow_discard, estats->brb_truncate_discard,
 		       old_tclient->ttl0_discard);
 
 		for_each_queue(bp, i) {
@@ -4400,8 +4560,8 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 		for (i = 0; i < bp->rx_ring_size; i++) {
 			if (bnx2x_alloc_rx_skb(bp, fp, ring_prod) < 0) {
 				BNX2X_ERR("was only able to allocate "
-					  "%d rx skbs\n", i);
-				bp->eth_stats.rx_skb_alloc_failed++;
+					  "%d rx skbs on queue[%d]\n", i, j);
+				fp->eth_q_stats.rx_skb_alloc_failed++;
 				break;
 			}
 			ring_prod = NEXT_RX_IDX(ring_prod);
@@ -4490,6 +4650,7 @@ static void bnx2x_init_context(struct bnx2x *bp)
 	for_each_queue(bp, i) {
 		struct eth_context *context = bnx2x_sp(bp, context[i].eth);
 		struct bnx2x_fastpath *fp = &bp->fp[i];
+		u8 cl_id = fp->cl_id;
 		u8 sb_id = FP_SB_ID(fp);
 
 		context->ustorm_st_context.common.sb_index_numbers =
@@ -4497,7 +4658,10 @@ static void bnx2x_init_context(struct bnx2x *bp)
 		context->ustorm_st_context.common.clientId = FP_CL_ID(fp);
 		context->ustorm_st_context.common.status_block_id = sb_id;
 		context->ustorm_st_context.common.flags =
-			USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_MC_ALIGNMENT;
+			(USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_MC_ALIGNMENT |
+			 USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS);
+		context->ustorm_st_context.common.statistics_counter_id =
+						cl_id;
 		context->ustorm_st_context.common.mc_alignment_log_size =
 						BNX2X_RX_ALIGN_SHIFT;
 		context->ustorm_st_context.common.bd_buff_size =
@@ -4568,9 +4732,9 @@ static void bnx2x_set_client_config(struct bnx2x *bp)
 	int i;
 
 	tstorm_client.mtu = bp->dev->mtu;
-	tstorm_client.statistics_counter_id = BP_CL_ID(bp);
 	tstorm_client.config_flags =
-				TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE;
+				(TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE |
+				 TSTORM_ETH_CLIENT_CONFIG_E1HOV_REM_ENABLE);
 #ifdef BCM_VLAN
 	if (bp->rx_mode && bp->vlgrp && (bp->flags & HW_VLAN_RX_FLAG)) {
 		tstorm_client.config_flags |=
@@ -4592,6 +4756,8 @@ static void bnx2x_set_client_config(struct bnx2x *bp)
 	}
 
 	for_each_queue(bp, i) {
+		tstorm_client.statistics_counter_id = bp->fp[i].cl_id;
+
 		REG_WR(bp, BAR_TSTRORM_INTMEM +
 		       TSTORM_CLIENT_CONFIG_OFFSET(port, bp->fp[i].cl_id),
 		       ((u32 *)&tstorm_client)[0]);
@@ -4688,7 +4854,8 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 	struct stats_indication_flags stats_flags = {0};
 	int port = BP_PORT(bp);
 	int func = BP_FUNC(bp);
-	int i;
+	int i, j;
+	u32 offset;
 	u16 max_agg_size;
 
 	if (is_multi(bp)) {
@@ -4708,17 +4875,29 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 	bp->rx_mode = BNX2X_RX_MODE_NONE; /* no rx until link is up */
 	bnx2x_set_storm_rx_mode(bp);
 
-	/* reset xstorm per client statistics */
-	for (i = 0; i < sizeof(struct xstorm_per_client_stats) / 4; i++) {
-		REG_WR(bp, BAR_XSTRORM_INTMEM +
-		       XSTORM_PER_COUNTER_ID_STATS_OFFSET(port, BP_CL_ID(bp)) +
-		       i*4, 0);
-	}
-	/* reset tstorm per client statistics */
-	for (i = 0; i < sizeof(struct tstorm_per_client_stats) / 4; i++) {
-		REG_WR(bp, BAR_TSTRORM_INTMEM +
-		       TSTORM_PER_COUNTER_ID_STATS_OFFSET(port, BP_CL_ID(bp)) +
-		       i*4, 0);
+	for_each_queue(bp, i) {
+		u8 cl_id = bp->fp[i].cl_id;
+
+		/* reset xstorm per client statistics */
+		offset = BAR_XSTRORM_INTMEM +
+			 XSTORM_PER_COUNTER_ID_STATS_OFFSET(port, cl_id);
+		for (j = 0;
+		     j < sizeof(struct xstorm_per_client_stats) / 4; j++)
+			REG_WR(bp, offset + j*4, 0);
+
+		/* reset tstorm per client statistics */
+		offset = BAR_TSTRORM_INTMEM +
+			 TSTORM_PER_COUNTER_ID_STATS_OFFSET(port, cl_id);
+		for (j = 0;
+		     j < sizeof(struct tstorm_per_client_stats) / 4; j++)
+			REG_WR(bp, offset + j*4, 0);
+
+		/* reset ustorm per client statistics */
+		offset = BAR_USTRORM_INTMEM +
+			 USTORM_PER_COUNTER_ID_STATS_OFFSET(port, cl_id);
+		for (j = 0;
+		     j < sizeof(struct ustorm_per_client_stats) / 4; j++)
+			REG_WR(bp, offset + j*4, 0);
 	}
 
 	/* Init statistics related context */
@@ -4734,6 +4913,11 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 	REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_STATS_FLAGS_OFFSET(func) + 4,
 	       ((u32 *)&stats_flags)[1]);
 
+	REG_WR(bp, BAR_USTRORM_INTMEM + USTORM_STATS_FLAGS_OFFSET(func),
+	       ((u32 *)&stats_flags)[0]);
+	REG_WR(bp, BAR_USTRORM_INTMEM + USTORM_STATS_FLAGS_OFFSET(func) + 4,
+	       ((u32 *)&stats_flags)[1]);
+
 	REG_WR(bp, BAR_CSTRORM_INTMEM + CSTORM_STATS_FLAGS_OFFSET(func),
 	       ((u32 *)&stats_flags)[0]);
 	REG_WR(bp, BAR_CSTRORM_INTMEM + CSTORM_STATS_FLAGS_OFFSET(func) + 4,
@@ -4753,6 +4937,13 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 	       TSTORM_ETH_STATS_QUERY_ADDR_OFFSET(func) + 4,
 	       U64_HI(bnx2x_sp_mapping(bp, fw_stats)));
 
+	REG_WR(bp, BAR_USTRORM_INTMEM +
+	       USTORM_ETH_STATS_QUERY_ADDR_OFFSET(func),
+	       U64_LO(bnx2x_sp_mapping(bp, fw_stats)));
+	REG_WR(bp, BAR_USTRORM_INTMEM +
+	       USTORM_ETH_STATS_QUERY_ADDR_OFFSET(func) + 4,
+	       U64_HI(bnx2x_sp_mapping(bp, fw_stats)));
+
 	if (CHIP_IS_E1H(bp)) {
 		REG_WR8(bp, BAR_XSTRORM_INTMEM + XSTORM_FUNCTION_MODE_OFFSET,
 			IS_E1HMF(bp));
@@ -9210,40 +9401,98 @@ static void bnx2x_self_test(struct net_device *dev,
 static const struct {
 	long offset;
 	int size;
+	u8 string[ETH_GSTRING_LEN];
+} bnx2x_q_stats_arr[BNX2X_NUM_Q_STATS] = {
+/* 1 */	{ Q_STATS_OFFSET32(total_bytes_received_hi), 8, "[%d]: rx_bytes" },
+	{ Q_STATS_OFFSET32(error_bytes_received_hi),
+						8, "[%d]: rx_error_bytes" },
+	{ Q_STATS_OFFSET32(total_unicast_packets_received_hi),
+						8, "[%d]: rx_ucast_packets" },
+	{ Q_STATS_OFFSET32(total_multicast_packets_received_hi),
+						8, "[%d]: rx_mcast_packets" },
+	{ Q_STATS_OFFSET32(total_broadcast_packets_received_hi),
+						8, "[%d]: rx_bcast_packets" },
+	{ Q_STATS_OFFSET32(no_buff_discard_hi),	8, "[%d]: rx_discards" },
+	{ Q_STATS_OFFSET32(rx_err_discard_pkt),
+					 4, "[%d]: rx_phy_ip_err_discards"},
+	{ Q_STATS_OFFSET32(rx_skb_alloc_failed),
+					 4, "[%d]: rx_skb_alloc_discard" },
+	{ Q_STATS_OFFSET32(hw_csum_err), 4, "[%d]: rx_csum_offload_errors" },
+
+/* 10 */{ Q_STATS_OFFSET32(total_bytes_transmitted_hi),	8, "[%d]: tx_bytes" },
+	{ Q_STATS_OFFSET32(total_unicast_packets_transmitted_hi),
+							8, "[%d]: tx_packets" }
+};
+
+static const struct {
+	long offset;
+	int size;
 	u32 flags;
 #define STATS_FLAGS_PORT		1
 #define STATS_FLAGS_FUNC		2
+#define STATS_FLAGS_BOTH		(STATS_FLAGS_FUNC | STATS_FLAGS_PORT)
 	u8 string[ETH_GSTRING_LEN];
 } bnx2x_stats_arr[BNX2X_NUM_STATS] = {
-/* 1 */	{ STATS_OFFSET32(valid_bytes_received_hi),
-				8, STATS_FLAGS_FUNC, "rx_bytes" },
+/* 1 */	{ STATS_OFFSET32(total_bytes_received_hi),
+				8, STATS_FLAGS_BOTH, "rx_bytes" },
 	{ STATS_OFFSET32(error_bytes_received_hi),
-				8, STATS_FLAGS_FUNC, "rx_error_bytes" },
-	{ STATS_OFFSET32(total_bytes_transmitted_hi),
-				8, STATS_FLAGS_FUNC, "tx_bytes" },
-	{ STATS_OFFSET32(tx_stat_ifhcoutbadoctets_hi),
-				8, STATS_FLAGS_PORT, "tx_error_bytes" },
+				8, STATS_FLAGS_BOTH, "rx_error_bytes" },
 	{ STATS_OFFSET32(total_unicast_packets_received_hi),
-				8, STATS_FLAGS_FUNC, "rx_ucast_packets" },
+				8, STATS_FLAGS_BOTH, "rx_ucast_packets" },
 	{ STATS_OFFSET32(total_multicast_packets_received_hi),
-				8, STATS_FLAGS_FUNC, "rx_mcast_packets" },
+				8, STATS_FLAGS_BOTH, "rx_mcast_packets" },
 	{ STATS_OFFSET32(total_broadcast_packets_received_hi),
-				8, STATS_FLAGS_FUNC, "rx_bcast_packets" },
-	{ STATS_OFFSET32(total_unicast_packets_transmitted_hi),
-				8, STATS_FLAGS_FUNC, "tx_packets" },
-	{ STATS_OFFSET32(tx_stat_dot3statsinternalmactransmiterrors_hi),
-				8, STATS_FLAGS_PORT, "tx_mac_errors" },
-/* 10 */{ STATS_OFFSET32(rx_stat_dot3statscarriersenseerrors_hi),
-				8, STATS_FLAGS_PORT, "tx_carrier_errors" },
+				8, STATS_FLAGS_BOTH, "rx_bcast_packets" },
 	{ STATS_OFFSET32(rx_stat_dot3statsfcserrors_hi),
 				8, STATS_FLAGS_PORT, "rx_crc_errors" },
 	{ STATS_OFFSET32(rx_stat_dot3statsalignmenterrors_hi),
 				8, STATS_FLAGS_PORT, "rx_align_errors" },
+	{ STATS_OFFSET32(rx_stat_etherstatsundersizepkts_hi),
+				8, STATS_FLAGS_PORT, "rx_undersize_packets" },
+	{ STATS_OFFSET32(etherstatsoverrsizepkts_hi),
+				8, STATS_FLAGS_PORT, "rx_oversize_packets" },
+/* 10 */{ STATS_OFFSET32(rx_stat_etherstatsfragments_hi),
+				8, STATS_FLAGS_PORT, "rx_fragments" },
+	{ STATS_OFFSET32(rx_stat_etherstatsjabbers_hi),
+				8, STATS_FLAGS_PORT, "rx_jabbers" },
+	{ STATS_OFFSET32(no_buff_discard_hi),
+				8, STATS_FLAGS_BOTH, "rx_discards" },
+	{ STATS_OFFSET32(mac_filter_discard),
+				4, STATS_FLAGS_PORT, "rx_filtered_packets" },
+	{ STATS_OFFSET32(xxoverflow_discard),
+				4, STATS_FLAGS_PORT, "rx_fw_discards" },
+	{ STATS_OFFSET32(brb_drop_hi),
+				8, STATS_FLAGS_PORT, "rx_brb_discard" },
+	{ STATS_OFFSET32(brb_truncate_hi),
+				8, STATS_FLAGS_PORT, "rx_brb_truncate" },
+	{ STATS_OFFSET32(pause_frames_received_hi),
+				8, STATS_FLAGS_PORT, "rx_pause_frames" },
+	{ STATS_OFFSET32(rx_stat_maccontrolframesreceived_hi),
+				8, STATS_FLAGS_PORT, "rx_mac_ctrl_frames" },
+	{ STATS_OFFSET32(nig_timer_max),
+			4, STATS_FLAGS_PORT, "rx_constant_pause_events" },
+/* 20 */{ STATS_OFFSET32(rx_err_discard_pkt),
+				4, STATS_FLAGS_BOTH, "rx_phy_ip_err_discards"},
+	{ STATS_OFFSET32(rx_skb_alloc_failed),
+				4, STATS_FLAGS_BOTH, "rx_skb_alloc_discard" },
+	{ STATS_OFFSET32(hw_csum_err),
+				4, STATS_FLAGS_BOTH, "rx_csum_offload_errors" },
+
+	{ STATS_OFFSET32(total_bytes_transmitted_hi),
+				8, STATS_FLAGS_BOTH, "tx_bytes" },
+	{ STATS_OFFSET32(tx_stat_ifhcoutbadoctets_hi),
+				8, STATS_FLAGS_PORT, "tx_error_bytes" },
+	{ STATS_OFFSET32(total_unicast_packets_transmitted_hi),
+				8, STATS_FLAGS_BOTH, "tx_packets" },
+	{ STATS_OFFSET32(tx_stat_dot3statsinternalmactransmiterrors_hi),
+				8, STATS_FLAGS_PORT, "tx_mac_errors" },
+	{ STATS_OFFSET32(rx_stat_dot3statscarriersenseerrors_hi),
+				8, STATS_FLAGS_PORT, "tx_carrier_errors" },
 	{ STATS_OFFSET32(tx_stat_dot3statssinglecollisionframes_hi),
 				8, STATS_FLAGS_PORT, "tx_single_collisions" },
 	{ STATS_OFFSET32(tx_stat_dot3statsmultiplecollisionframes_hi),
 				8, STATS_FLAGS_PORT, "tx_multi_collisions" },
-	{ STATS_OFFSET32(tx_stat_dot3statsdeferredtransmissions_hi),
+/* 30 */{ STATS_OFFSET32(tx_stat_dot3statsdeferredtransmissions_hi),
 				8, STATS_FLAGS_PORT, "tx_deferred" },
 	{ STATS_OFFSET32(tx_stat_dot3statsexcessivecollisions_hi),
 				8, STATS_FLAGS_PORT, "tx_excess_collisions" },
@@ -9251,14 +9500,6 @@ static const struct {
 				8, STATS_FLAGS_PORT, "tx_late_collisions" },
 	{ STATS_OFFSET32(tx_stat_etherstatscollisions_hi),
 				8, STATS_FLAGS_PORT, "tx_total_collisions" },
-	{ STATS_OFFSET32(rx_stat_etherstatsfragments_hi),
-				8, STATS_FLAGS_PORT, "rx_fragments" },
-/* 20 */{ STATS_OFFSET32(rx_stat_etherstatsjabbers_hi),
-				8, STATS_FLAGS_PORT, "rx_jabbers" },
-	{ STATS_OFFSET32(rx_stat_etherstatsundersizepkts_hi),
-				8, STATS_FLAGS_PORT, "rx_undersize_packets" },
-	{ STATS_OFFSET32(jabber_packets_received),
-				4, STATS_FLAGS_FUNC, "rx_oversize_packets" },
 	{ STATS_OFFSET32(tx_stat_etherstatspkts64octets_hi),
 				8, STATS_FLAGS_PORT, "tx_64_byte_packets" },
 	{ STATS_OFFSET32(tx_stat_etherstatspkts65octetsto127octets_hi),
@@ -9271,52 +9512,46 @@ static const struct {
 			8, STATS_FLAGS_PORT, "tx_512_to_1023_byte_packets" },
 	{ STATS_OFFSET32(etherstatspkts1024octetsto1522octets_hi),
 			8, STATS_FLAGS_PORT, "tx_1024_to_1522_byte_packets" },
-	{ STATS_OFFSET32(etherstatspktsover1522octets_hi),
+/* 40 */{ STATS_OFFSET32(etherstatspktsover1522octets_hi),
 			8, STATS_FLAGS_PORT, "tx_1523_to_9022_byte_packets" },
-/* 30 */{ STATS_OFFSET32(rx_stat_xonpauseframesreceived_hi),
-				8, STATS_FLAGS_PORT, "rx_xon_frames" },
-	{ STATS_OFFSET32(rx_stat_xoffpauseframesreceived_hi),
-				8, STATS_FLAGS_PORT, "rx_xoff_frames" },
-	{ STATS_OFFSET32(tx_stat_outxonsent_hi),
-				8, STATS_FLAGS_PORT, "tx_xon_frames" },
-	{ STATS_OFFSET32(tx_stat_outxoffsent_hi),
-				8, STATS_FLAGS_PORT, "tx_xoff_frames" },
-	{ STATS_OFFSET32(rx_stat_maccontrolframesreceived_hi),
-				8, STATS_FLAGS_PORT, "rx_mac_ctrl_frames" },
-	{ STATS_OFFSET32(mac_filter_discard),
-				4, STATS_FLAGS_PORT, "rx_filtered_packets" },
-	{ STATS_OFFSET32(no_buff_discard),
-				4, STATS_FLAGS_FUNC, "rx_discards" },
-	{ STATS_OFFSET32(xxoverflow_discard),
-				4, STATS_FLAGS_PORT, "rx_fw_discards" },
-	{ STATS_OFFSET32(brb_drop_hi),
-				8, STATS_FLAGS_PORT, "brb_discard" },
-	{ STATS_OFFSET32(brb_truncate_hi),
-				8, STATS_FLAGS_PORT, "brb_truncate" },
-/* 40 */{ STATS_OFFSET32(rx_err_discard_pkt),
-				4, STATS_FLAGS_FUNC, "rx_phy_ip_err_discards"},
-	{ STATS_OFFSET32(rx_skb_alloc_failed),
-				4, STATS_FLAGS_FUNC, "rx_skb_alloc_discard" },
-/* 42 */{ STATS_OFFSET32(hw_csum_err),
-				4, STATS_FLAGS_FUNC, "rx_csum_offload_errors" }
+	{ STATS_OFFSET32(pause_frames_sent_hi),
+				8, STATS_FLAGS_PORT, "tx_pause_frames" }
 };
 
-#define IS_NOT_E1HMF_STAT(bp, i) \
-		(IS_E1HMF(bp) && (bnx2x_stats_arr[i].flags & STATS_FLAGS_PORT))
+#define IS_PORT_STAT(i) \
+	((bnx2x_stats_arr[i].flags & STATS_FLAGS_BOTH) == STATS_FLAGS_PORT)
+#define IS_FUNC_STAT(i)		(bnx2x_stats_arr[i].flags & STATS_FLAGS_FUNC)
+#define IS_E1HMF_MODE_STAT(bp) \
+			(IS_E1HMF(bp) && !(bp->msglevel & BNX2X_MSG_STATS))
 
 static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	int i, j;
+	int i, j, k;
 
 	switch (stringset) {
 	case ETH_SS_STATS:
-		for (i = 0, j = 0; i < BNX2X_NUM_STATS; i++) {
-			if (IS_NOT_E1HMF_STAT(bp, i))
-				continue;
-			strcpy(buf + j*ETH_GSTRING_LEN,
-			       bnx2x_stats_arr[i].string);
-			j++;
+		if (is_multi(bp)) {
+			k = 0;
+			for_each_queue(bp, i) {
+				for (j = 0; j < BNX2X_NUM_Q_STATS; j++)
+					sprintf(buf + (k + j)*ETH_GSTRING_LEN,
+						bnx2x_q_stats_arr[j].string, i);
+				k += BNX2X_NUM_Q_STATS;
+			}
+			if (IS_E1HMF_MODE_STAT(bp))
+				break;
+			for (j = 0; j < BNX2X_NUM_STATS; j++)
+				strcpy(buf + (k + j)*ETH_GSTRING_LEN,
+				       bnx2x_stats_arr[j].string);
+		} else {
+			for (i = 0, j = 0; i < BNX2X_NUM_STATS; i++) {
+				if (IS_E1HMF_MODE_STAT(bp) && IS_PORT_STAT(i))
+					continue;
+				strcpy(buf + j*ETH_GSTRING_LEN,
+				       bnx2x_stats_arr[i].string);
+				j++;
+			}
 		}
 		break;
 
@@ -9329,13 +9564,22 @@ static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 static int bnx2x_get_stats_count(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	int i, num_stats = 0;
+	int i, num_stats;
 
-	for (i = 0; i < BNX2X_NUM_STATS; i++) {
-		if (IS_NOT_E1HMF_STAT(bp, i))
-			continue;
-		num_stats++;
+	if (is_multi(bp)) {
+		num_stats = BNX2X_NUM_Q_STATS * BNX2X_NUM_QUEUES(bp);
+		if (!IS_E1HMF_MODE_STAT(bp))
+			num_stats += BNX2X_NUM_STATS;
+	} else {
+		if (IS_E1HMF_MODE_STAT(bp)) {
+			num_stats = 0;
+			for (i = 0; i < BNX2X_NUM_STATS; i++)
+				if (IS_FUNC_STAT(i))
+					num_stats++;
+		} else
+			num_stats = BNX2X_NUM_STATS;
 	}
+
 	return num_stats;
 }
 
@@ -9343,29 +9587,71 @@ static void bnx2x_get_ethtool_stats(struct net_device *dev,
 				    struct ethtool_stats *stats, u64 *buf)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	u32 *hw_stats = (u32 *)&bp->eth_stats;
-	int i, j;
-
-	for (i = 0, j = 0; i < BNX2X_NUM_STATS; i++) {
-		if (IS_NOT_E1HMF_STAT(bp, i))
-			continue;
+	u32 *hw_stats, *offset;
+	int i, j, k;
 
-		if (bnx2x_stats_arr[i].size == 0) {
-			/* skip this counter */
-			buf[j] = 0;
-			j++;
-			continue;
+	if (is_multi(bp)) {
+		k = 0;
+		for_each_queue(bp, i) {
+			hw_stats = (u32 *)&bp->fp[i].eth_q_stats;
+			for (j = 0; j < BNX2X_NUM_Q_STATS; j++) {
+				if (bnx2x_q_stats_arr[j].size == 0) {
+					/* skip this counter */
+					buf[k + j] = 0;
+					continue;
+				}
+				offset = (hw_stats +
+					  bnx2x_q_stats_arr[j].offset);
+				if (bnx2x_q_stats_arr[j].size == 4) {
+					/* 4-byte counter */
+					buf[k + j] = (u64) *offset;
+					continue;
+				}
+				/* 8-byte counter */
+				buf[k + j] = HILO_U64(*offset, *(offset + 1));
+			}
+			k += BNX2X_NUM_Q_STATS;
+		}
+		if (IS_E1HMF_MODE_STAT(bp))
+			return;
+		hw_stats = (u32 *)&bp->eth_stats;
+		for (j = 0; j < BNX2X_NUM_STATS; j++) {
+			if (bnx2x_stats_arr[j].size == 0) {
+				/* skip this counter */
+				buf[k + j] = 0;
+				continue;
+			}
+			offset = (hw_stats + bnx2x_stats_arr[j].offset);
+			if (bnx2x_stats_arr[j].size == 4) {
+				/* 4-byte counter */
+				buf[k + j] = (u64) *offset;
+				continue;
+			}
+			/* 8-byte counter */
+			buf[k + j] = HILO_U64(*offset, *(offset + 1));
 		}
-		if (bnx2x_stats_arr[i].size == 4) {
-			/* 4-byte counter */
-			buf[j] = (u64) *(hw_stats + bnx2x_stats_arr[i].offset);
+	} else {
+		hw_stats = (u32 *)&bp->eth_stats;
+		for (i = 0, j = 0; i < BNX2X_NUM_STATS; i++) {
+			if (IS_E1HMF_MODE_STAT(bp) && IS_PORT_STAT(i))
+				continue;
+			if (bnx2x_stats_arr[i].size == 0) {
+				/* skip this counter */
+				buf[j] = 0;
+				j++;
+				continue;
+			}
+			offset = (hw_stats + bnx2x_stats_arr[i].offset);
+			if (bnx2x_stats_arr[i].size == 4) {
+				/* 4-byte counter */
+				buf[j] = (u64) *offset;
+				j++;
+				continue;
+			}
+			/* 8-byte counter */
+			buf[j] = HILO_U64(*offset, *(offset + 1));
 			j++;
-			continue;
 		}
-		/* 8-byte counter */
-		buf[j] = HILO_U64(*(hw_stats + bnx2x_stats_arr[i].offset),
-				  *(hw_stats + bnx2x_stats_arr[i].offset + 1));
-		j++;
 	}
 }
 
@@ -9750,7 +10036,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	fp = &bp->fp[fp_index];
 
 	if (unlikely(bnx2x_tx_avail(fp) < (skb_shinfo(skb)->nr_frags + 3))) {
-		bp->eth_stats.driver_xoff++,
+		fp->eth_q_stats.driver_xoff++,
 		netif_tx_stop_queue(txq);
 		BNX2X_ERR("BUG! Tx ring full when queue awake!\n");
 		return NETDEV_TX_BUSY;
@@ -9991,7 +10277,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		   if we put Tx into XOFF state. */
 		smp_mb();
 		netif_tx_stop_queue(txq);
-		bp->eth_stats.driver_xoff++;
+		fp->eth_q_stats.driver_xoff++;
 		if (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3)
 			netif_tx_wake_queue(txq);
 	}
-- 
1.5.4.3




