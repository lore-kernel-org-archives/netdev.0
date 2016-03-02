From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 3/6] qed: Move statistics to L2 code
Date: Wed, 2 Mar 2016 20:26:02 +0200
Message-ID: <1456943165-15198-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456943165-15198-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:31616 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756033AbcCBS00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 13:26:26 -0500
In-Reply-To: <1456943165-15198-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current statistics logic is meant for L2, not for all future protocols.
Move this content to the proper designated file.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c     | 244 +------------------
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h |   2 -
 drivers/net/ethernet/qlogic/qed/qed_l2.c      | 323 ++++++++++++++++++++++++++
 3 files changed, 324 insertions(+), 245 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 2e02e05..d08078f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -677,10 +677,8 @@ int qed_hw_init(struct qed_dev *cdev,
 		bool allow_npar_tx_switch,
 		const u8 *bin_fw_data)
 {
-	struct qed_storm_stats *p_stat;
-	u32 load_code, param, *p_address;
+	u32 load_code, param;
 	int rc, mfw_rc, i;
-	u8 fw_vport = 0;
 
 	rc = qed_init_fw_data(cdev, bin_fw_data);
 	if (rc != 0)
@@ -689,10 +687,6 @@ int qed_hw_init(struct qed_dev *cdev,
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
-		rc = qed_fw_vport(p_hwfn, 0, &fw_vport);
-		if (rc != 0)
-			return rc;
-
 		/* Enable DMAE in PXP */
 		rc = qed_change_pci_hwfn(p_hwfn, p_hwfn->p_main_ptt, true);
 
@@ -756,25 +750,6 @@ int qed_hw_init(struct qed_dev *cdev,
 		}
 
 		p_hwfn->hw_init_done = true;
-
-		/* init PF stats */
-		p_stat = &p_hwfn->storm_stats;
-		p_stat->mstats.address = BAR0_MAP_REG_MSDM_RAM +
-					 MSTORM_QUEUE_STAT_OFFSET(fw_vport);
-		p_stat->mstats.len = sizeof(struct eth_mstorm_per_queue_stat);
-
-		p_stat->ustats.address = BAR0_MAP_REG_USDM_RAM +
-					 USTORM_QUEUE_STAT_OFFSET(fw_vport);
-		p_stat->ustats.len = sizeof(struct eth_ustorm_per_queue_stat);
-
-		p_stat->pstats.address = BAR0_MAP_REG_PSDM_RAM +
-					 PSTORM_QUEUE_STAT_OFFSET(fw_vport);
-		p_stat->pstats.len = sizeof(struct eth_pstorm_per_queue_stat);
-
-		p_address = &p_stat->tstats.address;
-		*p_address = BAR0_MAP_REG_TSDM_RAM +
-			     TSTORM_PORT_STAT_OFFSET(MFW_PORT(p_hwfn));
-		p_stat->tstats.len = sizeof(struct tstorm_per_port_stat);
 	}
 
 	return 0;
@@ -1557,223 +1532,6 @@ void qed_chain_free(struct qed_dev *cdev,
 			  p_chain->p_phys_addr);
 }
 
-static void __qed_get_vport_stats(struct qed_dev *cdev,
-				  struct qed_eth_stats  *stats)
-{
-	int i, j;
-
-	memset(stats, 0, sizeof(*stats));
-
-	for_each_hwfn(cdev, i) {
-		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
-		struct eth_mstorm_per_queue_stat mstats;
-		struct eth_ustorm_per_queue_stat ustats;
-		struct eth_pstorm_per_queue_stat pstats;
-		struct tstorm_per_port_stat tstats;
-		struct port_stats port_stats;
-		struct qed_ptt *p_ptt = qed_ptt_acquire(p_hwfn);
-
-		if (!p_ptt) {
-			DP_ERR(p_hwfn, "Failed to acquire ptt\n");
-			continue;
-		}
-
-		memset(&mstats, 0, sizeof(mstats));
-		qed_memcpy_from(p_hwfn, p_ptt, &mstats,
-				p_hwfn->storm_stats.mstats.address,
-				p_hwfn->storm_stats.mstats.len);
-
-		memset(&ustats, 0, sizeof(ustats));
-		qed_memcpy_from(p_hwfn, p_ptt, &ustats,
-				p_hwfn->storm_stats.ustats.address,
-				p_hwfn->storm_stats.ustats.len);
-
-		memset(&pstats, 0, sizeof(pstats));
-		qed_memcpy_from(p_hwfn, p_ptt, &pstats,
-				p_hwfn->storm_stats.pstats.address,
-				p_hwfn->storm_stats.pstats.len);
-
-		memset(&tstats, 0, sizeof(tstats));
-		qed_memcpy_from(p_hwfn, p_ptt, &tstats,
-				p_hwfn->storm_stats.tstats.address,
-				p_hwfn->storm_stats.tstats.len);
-
-		memset(&port_stats, 0, sizeof(port_stats));
-
-		if (p_hwfn->mcp_info)
-			qed_memcpy_from(p_hwfn, p_ptt, &port_stats,
-					p_hwfn->mcp_info->port_addr +
-					offsetof(struct public_port, stats),
-					sizeof(port_stats));
-		qed_ptt_release(p_hwfn, p_ptt);
-
-		stats->no_buff_discards +=
-			HILO_64_REGPAIR(mstats.no_buff_discard);
-		stats->packet_too_big_discard +=
-			HILO_64_REGPAIR(mstats.packet_too_big_discard);
-		stats->ttl0_discard +=
-			HILO_64_REGPAIR(mstats.ttl0_discard);
-		stats->tpa_coalesced_pkts +=
-			HILO_64_REGPAIR(mstats.tpa_coalesced_pkts);
-		stats->tpa_coalesced_events +=
-			HILO_64_REGPAIR(mstats.tpa_coalesced_events);
-		stats->tpa_aborts_num +=
-			HILO_64_REGPAIR(mstats.tpa_aborts_num);
-		stats->tpa_coalesced_bytes +=
-			HILO_64_REGPAIR(mstats.tpa_coalesced_bytes);
-
-		stats->rx_ucast_bytes +=
-			HILO_64_REGPAIR(ustats.rcv_ucast_bytes);
-		stats->rx_mcast_bytes +=
-			HILO_64_REGPAIR(ustats.rcv_mcast_bytes);
-		stats->rx_bcast_bytes +=
-			HILO_64_REGPAIR(ustats.rcv_bcast_bytes);
-		stats->rx_ucast_pkts +=
-			HILO_64_REGPAIR(ustats.rcv_ucast_pkts);
-		stats->rx_mcast_pkts +=
-			HILO_64_REGPAIR(ustats.rcv_mcast_pkts);
-		stats->rx_bcast_pkts +=
-			HILO_64_REGPAIR(ustats.rcv_bcast_pkts);
-
-		stats->mftag_filter_discards +=
-			HILO_64_REGPAIR(tstats.mftag_filter_discard);
-		stats->mac_filter_discards +=
-			HILO_64_REGPAIR(tstats.eth_mac_filter_discard);
-
-		stats->tx_ucast_bytes +=
-			HILO_64_REGPAIR(pstats.sent_ucast_bytes);
-		stats->tx_mcast_bytes +=
-			HILO_64_REGPAIR(pstats.sent_mcast_bytes);
-		stats->tx_bcast_bytes +=
-			HILO_64_REGPAIR(pstats.sent_bcast_bytes);
-		stats->tx_ucast_pkts +=
-			HILO_64_REGPAIR(pstats.sent_ucast_pkts);
-		stats->tx_mcast_pkts +=
-			HILO_64_REGPAIR(pstats.sent_mcast_pkts);
-		stats->tx_bcast_pkts +=
-			HILO_64_REGPAIR(pstats.sent_bcast_pkts);
-		stats->tx_err_drop_pkts +=
-			HILO_64_REGPAIR(pstats.error_drop_pkts);
-		stats->rx_64_byte_packets       += port_stats.pmm.r64;
-		stats->rx_127_byte_packets      += port_stats.pmm.r127;
-		stats->rx_255_byte_packets      += port_stats.pmm.r255;
-		stats->rx_511_byte_packets      += port_stats.pmm.r511;
-		stats->rx_1023_byte_packets     += port_stats.pmm.r1023;
-		stats->rx_1518_byte_packets     += port_stats.pmm.r1518;
-		stats->rx_1522_byte_packets     += port_stats.pmm.r1522;
-		stats->rx_2047_byte_packets     += port_stats.pmm.r2047;
-		stats->rx_4095_byte_packets     += port_stats.pmm.r4095;
-		stats->rx_9216_byte_packets     += port_stats.pmm.r9216;
-		stats->rx_16383_byte_packets    += port_stats.pmm.r16383;
-		stats->rx_crc_errors	    += port_stats.pmm.rfcs;
-		stats->rx_mac_crtl_frames       += port_stats.pmm.rxcf;
-		stats->rx_pause_frames	  += port_stats.pmm.rxpf;
-		stats->rx_pfc_frames	    += port_stats.pmm.rxpp;
-		stats->rx_align_errors	  += port_stats.pmm.raln;
-		stats->rx_carrier_errors	+= port_stats.pmm.rfcr;
-		stats->rx_oversize_packets      += port_stats.pmm.rovr;
-		stats->rx_jabbers	       += port_stats.pmm.rjbr;
-		stats->rx_undersize_packets     += port_stats.pmm.rund;
-		stats->rx_fragments	     += port_stats.pmm.rfrg;
-		stats->tx_64_byte_packets       += port_stats.pmm.t64;
-		stats->tx_65_to_127_byte_packets += port_stats.pmm.t127;
-		stats->tx_128_to_255_byte_packets += port_stats.pmm.t255;
-		stats->tx_256_to_511_byte_packets  += port_stats.pmm.t511;
-		stats->tx_512_to_1023_byte_packets += port_stats.pmm.t1023;
-		stats->tx_1024_to_1518_byte_packets += port_stats.pmm.t1518;
-		stats->tx_1519_to_2047_byte_packets += port_stats.pmm.t2047;
-		stats->tx_2048_to_4095_byte_packets += port_stats.pmm.t4095;
-		stats->tx_4096_to_9216_byte_packets += port_stats.pmm.t9216;
-		stats->tx_9217_to_16383_byte_packets += port_stats.pmm.t16383;
-		stats->tx_pause_frames	  += port_stats.pmm.txpf;
-		stats->tx_pfc_frames	    += port_stats.pmm.txpp;
-		stats->tx_lpi_entry_count       += port_stats.pmm.tlpiec;
-		stats->tx_total_collisions      += port_stats.pmm.tncl;
-		stats->rx_mac_bytes	     += port_stats.pmm.rbyte;
-		stats->rx_mac_uc_packets	+= port_stats.pmm.rxuca;
-		stats->rx_mac_mc_packets	+= port_stats.pmm.rxmca;
-		stats->rx_mac_bc_packets	+= port_stats.pmm.rxbca;
-		stats->rx_mac_frames_ok	 += port_stats.pmm.rxpok;
-		stats->tx_mac_bytes	     += port_stats.pmm.tbyte;
-		stats->tx_mac_uc_packets	+= port_stats.pmm.txuca;
-		stats->tx_mac_mc_packets	+= port_stats.pmm.txmca;
-		stats->tx_mac_bc_packets	+= port_stats.pmm.txbca;
-		stats->tx_mac_ctrl_frames       += port_stats.pmm.txcf;
-
-		for (j = 0; j < 8; j++) {
-			stats->brb_truncates += port_stats.brb.brb_truncate[j];
-			stats->brb_discards += port_stats.brb.brb_discard[j];
-		}
-	}
-}
-
-void qed_get_vport_stats(struct qed_dev *cdev,
-			 struct qed_eth_stats *stats)
-{
-	u32 i;
-
-	if (!cdev) {
-		memset(stats, 0, sizeof(*stats));
-		return;
-	}
-
-	__qed_get_vport_stats(cdev, stats);
-
-	if (!cdev->reset_stats)
-		return;
-
-	/* Reduce the statistics baseline */
-	for (i = 0; i < sizeof(struct qed_eth_stats) / sizeof(u64); i++)
-		((u64 *)stats)[i] -= ((u64 *)cdev->reset_stats)[i];
-}
-
-/* zeroes V-PORT specific portion of stats (Port stats remains untouched) */
-void qed_reset_vport_stats(struct qed_dev *cdev)
-{
-	int i;
-
-	for_each_hwfn(cdev, i) {
-		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
-		struct eth_mstorm_per_queue_stat mstats;
-		struct eth_ustorm_per_queue_stat ustats;
-		struct eth_pstorm_per_queue_stat pstats;
-		struct qed_ptt *p_ptt = qed_ptt_acquire(p_hwfn);
-
-		if (!p_ptt) {
-			DP_ERR(p_hwfn, "Failed to acquire ptt\n");
-			continue;
-		}
-
-		memset(&mstats, 0, sizeof(mstats));
-		qed_memcpy_to(p_hwfn, p_ptt,
-			      p_hwfn->storm_stats.mstats.address,
-			      &mstats,
-			      p_hwfn->storm_stats.mstats.len);
-
-		memset(&ustats, 0, sizeof(ustats));
-		qed_memcpy_to(p_hwfn, p_ptt,
-			      p_hwfn->storm_stats.ustats.address,
-			      &ustats,
-			      p_hwfn->storm_stats.ustats.len);
-
-		memset(&pstats, 0, sizeof(pstats));
-		qed_memcpy_to(p_hwfn, p_ptt,
-			      p_hwfn->storm_stats.pstats.address,
-			      &pstats,
-			      p_hwfn->storm_stats.pstats.len);
-
-		qed_ptt_release(p_hwfn, p_ptt);
-	}
-
-	/* PORT statistics are not necessarily reset, so we need to
-	 * read and create a baseline for future statistics.
-	 */
-	if (!cdev->reset_stats)
-		DP_INFO(cdev, "Reset stats not allocated\n");
-	else
-		__qed_get_vport_stats(cdev, cdev->reset_stats);
-}
-
 int qed_fw_l2_queue(struct qed_hwfn *p_hwfn,
 		    u16 src_id, u16 *dst_id)
 {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
index e29a3ba..155f26b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
@@ -156,8 +156,6 @@ struct qed_ptt *qed_ptt_acquire(struct qed_hwfn *p_hwfn);
  */
 void qed_ptt_release(struct qed_hwfn *p_hwfn,
 		     struct qed_ptt *p_ptt);
-void qed_get_vport_stats(struct qed_dev *cdev,
-			 struct qed_eth_stats   *stats);
 void qed_reset_vport_stats(struct qed_dev *cdev);
 
 enum qed_dmae_address_type_t {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index bba59c5..102ddc7 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -31,6 +31,7 @@
 #include "qed_hsi.h"
 #include "qed_hw.h"
 #include "qed_int.h"
+#include "qed_mcp.h"
 #include "qed_reg_addr.h"
 #include "qed_sp.h"
 
@@ -1231,6 +1232,328 @@ static int qed_filter_ucast_cmd(struct qed_dev *cdev,
 	return rc;
 }
 
+/* Statistics related code */
+static void __qed_get_vport_pstats_addrlen(struct qed_hwfn *p_hwfn,
+					   u32 *p_addr,
+					   u32 *p_len,
+					   u16 statistics_bin)
+{
+	*p_addr = BAR0_MAP_REG_PSDM_RAM +
+		  PSTORM_QUEUE_STAT_OFFSET(statistics_bin);
+	*p_len = sizeof(struct eth_pstorm_per_queue_stat);
+}
+
+static void __qed_get_vport_pstats(struct qed_hwfn *p_hwfn,
+				   struct qed_ptt *p_ptt,
+				   struct qed_eth_stats *p_stats,
+				   u16 statistics_bin)
+{
+	struct eth_pstorm_per_queue_stat pstats;
+	u32 pstats_addr = 0, pstats_len = 0;
+
+	__qed_get_vport_pstats_addrlen(p_hwfn, &pstats_addr, &pstats_len,
+				       statistics_bin);
+
+	memset(&pstats, 0, sizeof(pstats));
+	qed_memcpy_from(p_hwfn, p_ptt, &pstats,
+			pstats_addr, pstats_len);
+
+	p_stats->tx_ucast_bytes +=
+		HILO_64_REGPAIR(pstats.sent_ucast_bytes);
+	p_stats->tx_mcast_bytes +=
+		HILO_64_REGPAIR(pstats.sent_mcast_bytes);
+	p_stats->tx_bcast_bytes +=
+		HILO_64_REGPAIR(pstats.sent_bcast_bytes);
+	p_stats->tx_ucast_pkts +=
+		HILO_64_REGPAIR(pstats.sent_ucast_pkts);
+	p_stats->tx_mcast_pkts +=
+		HILO_64_REGPAIR(pstats.sent_mcast_pkts);
+	p_stats->tx_bcast_pkts +=
+		HILO_64_REGPAIR(pstats.sent_bcast_pkts);
+	p_stats->tx_err_drop_pkts +=
+		HILO_64_REGPAIR(pstats.error_drop_pkts);
+}
+
+static void __qed_get_vport_tstats_addrlen(struct qed_hwfn *p_hwfn,
+					   u32 *p_addr,
+					   u32 *p_len)
+{
+	*p_addr = BAR0_MAP_REG_TSDM_RAM +
+		  TSTORM_PORT_STAT_OFFSET(MFW_PORT(p_hwfn));
+	*p_len = sizeof(struct tstorm_per_port_stat);
+}
+
+static void __qed_get_vport_tstats(struct qed_hwfn *p_hwfn,
+				   struct qed_ptt *p_ptt,
+				   struct qed_eth_stats *p_stats,
+				   u16 statistics_bin)
+{
+	u32 tstats_addr = 0, tstats_len = 0;
+	struct tstorm_per_port_stat tstats;
+
+	__qed_get_vport_tstats_addrlen(p_hwfn, &tstats_addr, &tstats_len);
+
+	memset(&tstats, 0, sizeof(tstats));
+	qed_memcpy_from(p_hwfn, p_ptt, &tstats,
+			tstats_addr, tstats_len);
+
+	p_stats->mftag_filter_discards +=
+		HILO_64_REGPAIR(tstats.mftag_filter_discard);
+	p_stats->mac_filter_discards +=
+		HILO_64_REGPAIR(tstats.eth_mac_filter_discard);
+}
+
+static void __qed_get_vport_ustats_addrlen(struct qed_hwfn *p_hwfn,
+					   u32 *p_addr,
+					   u32 *p_len,
+					   u16 statistics_bin)
+{
+	*p_addr = BAR0_MAP_REG_USDM_RAM +
+		  USTORM_QUEUE_STAT_OFFSET(statistics_bin);
+	*p_len = sizeof(struct eth_ustorm_per_queue_stat);
+}
+
+static void __qed_get_vport_ustats(struct qed_hwfn *p_hwfn,
+				   struct qed_ptt *p_ptt,
+				   struct qed_eth_stats *p_stats,
+				   u16 statistics_bin)
+{
+	struct eth_ustorm_per_queue_stat ustats;
+	u32 ustats_addr = 0, ustats_len = 0;
+
+	__qed_get_vport_ustats_addrlen(p_hwfn, &ustats_addr, &ustats_len,
+				       statistics_bin);
+
+	memset(&ustats, 0, sizeof(ustats));
+	qed_memcpy_from(p_hwfn, p_ptt, &ustats,
+			ustats_addr, ustats_len);
+
+	p_stats->rx_ucast_bytes +=
+		HILO_64_REGPAIR(ustats.rcv_ucast_bytes);
+	p_stats->rx_mcast_bytes +=
+		HILO_64_REGPAIR(ustats.rcv_mcast_bytes);
+	p_stats->rx_bcast_bytes +=
+		HILO_64_REGPAIR(ustats.rcv_bcast_bytes);
+	p_stats->rx_ucast_pkts +=
+		HILO_64_REGPAIR(ustats.rcv_ucast_pkts);
+	p_stats->rx_mcast_pkts +=
+		HILO_64_REGPAIR(ustats.rcv_mcast_pkts);
+	p_stats->rx_bcast_pkts +=
+		HILO_64_REGPAIR(ustats.rcv_bcast_pkts);
+}
+
+static void __qed_get_vport_mstats_addrlen(struct qed_hwfn *p_hwfn,
+					   u32 *p_addr,
+					   u32 *p_len,
+					   u16 statistics_bin)
+{
+	*p_addr = BAR0_MAP_REG_MSDM_RAM +
+		  MSTORM_QUEUE_STAT_OFFSET(statistics_bin);
+	*p_len = sizeof(struct eth_mstorm_per_queue_stat);
+}
+
+static void __qed_get_vport_mstats(struct qed_hwfn *p_hwfn,
+				   struct qed_ptt *p_ptt,
+				   struct qed_eth_stats *p_stats,
+				   u16 statistics_bin)
+{
+	struct eth_mstorm_per_queue_stat mstats;
+	u32 mstats_addr = 0, mstats_len = 0;
+
+	__qed_get_vport_mstats_addrlen(p_hwfn, &mstats_addr, &mstats_len,
+				       statistics_bin);
+
+	memset(&mstats, 0, sizeof(mstats));
+	qed_memcpy_from(p_hwfn, p_ptt, &mstats,
+			mstats_addr, mstats_len);
+
+	p_stats->no_buff_discards +=
+		HILO_64_REGPAIR(mstats.no_buff_discard);
+	p_stats->packet_too_big_discard +=
+		HILO_64_REGPAIR(mstats.packet_too_big_discard);
+	p_stats->ttl0_discard +=
+		HILO_64_REGPAIR(mstats.ttl0_discard);
+	p_stats->tpa_coalesced_pkts +=
+		HILO_64_REGPAIR(mstats.tpa_coalesced_pkts);
+	p_stats->tpa_coalesced_events +=
+		HILO_64_REGPAIR(mstats.tpa_coalesced_events);
+	p_stats->tpa_aborts_num +=
+		HILO_64_REGPAIR(mstats.tpa_aborts_num);
+	p_stats->tpa_coalesced_bytes +=
+		HILO_64_REGPAIR(mstats.tpa_coalesced_bytes);
+}
+
+static void __qed_get_vport_port_stats(struct qed_hwfn *p_hwfn,
+				       struct qed_ptt *p_ptt,
+				       struct qed_eth_stats *p_stats)
+{
+	struct port_stats port_stats;
+	int j;
+
+	memset(&port_stats, 0, sizeof(port_stats));
+
+	qed_memcpy_from(p_hwfn, p_ptt, &port_stats,
+			p_hwfn->mcp_info->port_addr +
+			offsetof(struct public_port, stats),
+			sizeof(port_stats));
+
+	p_stats->rx_64_byte_packets		+= port_stats.pmm.r64;
+	p_stats->rx_127_byte_packets		+= port_stats.pmm.r127;
+	p_stats->rx_255_byte_packets		+= port_stats.pmm.r255;
+	p_stats->rx_511_byte_packets		+= port_stats.pmm.r511;
+	p_stats->rx_1023_byte_packets		+= port_stats.pmm.r1023;
+	p_stats->rx_1518_byte_packets		+= port_stats.pmm.r1518;
+	p_stats->rx_1522_byte_packets		+= port_stats.pmm.r1522;
+	p_stats->rx_2047_byte_packets		+= port_stats.pmm.r2047;
+	p_stats->rx_4095_byte_packets		+= port_stats.pmm.r4095;
+	p_stats->rx_9216_byte_packets		+= port_stats.pmm.r9216;
+	p_stats->rx_16383_byte_packets		+= port_stats.pmm.r16383;
+	p_stats->rx_crc_errors			+= port_stats.pmm.rfcs;
+	p_stats->rx_mac_crtl_frames		+= port_stats.pmm.rxcf;
+	p_stats->rx_pause_frames		+= port_stats.pmm.rxpf;
+	p_stats->rx_pfc_frames			+= port_stats.pmm.rxpp;
+	p_stats->rx_align_errors		+= port_stats.pmm.raln;
+	p_stats->rx_carrier_errors		+= port_stats.pmm.rfcr;
+	p_stats->rx_oversize_packets		+= port_stats.pmm.rovr;
+	p_stats->rx_jabbers			+= port_stats.pmm.rjbr;
+	p_stats->rx_undersize_packets		+= port_stats.pmm.rund;
+	p_stats->rx_fragments			+= port_stats.pmm.rfrg;
+	p_stats->tx_64_byte_packets		+= port_stats.pmm.t64;
+	p_stats->tx_65_to_127_byte_packets	+= port_stats.pmm.t127;
+	p_stats->tx_128_to_255_byte_packets	+= port_stats.pmm.t255;
+	p_stats->tx_256_to_511_byte_packets	+= port_stats.pmm.t511;
+	p_stats->tx_512_to_1023_byte_packets	+= port_stats.pmm.t1023;
+	p_stats->tx_1024_to_1518_byte_packets	+= port_stats.pmm.t1518;
+	p_stats->tx_1519_to_2047_byte_packets	+= port_stats.pmm.t2047;
+	p_stats->tx_2048_to_4095_byte_packets	+= port_stats.pmm.t4095;
+	p_stats->tx_4096_to_9216_byte_packets	+= port_stats.pmm.t9216;
+	p_stats->tx_9217_to_16383_byte_packets	+= port_stats.pmm.t16383;
+	p_stats->tx_pause_frames		+= port_stats.pmm.txpf;
+	p_stats->tx_pfc_frames			+= port_stats.pmm.txpp;
+	p_stats->tx_lpi_entry_count		+= port_stats.pmm.tlpiec;
+	p_stats->tx_total_collisions		+= port_stats.pmm.tncl;
+	p_stats->rx_mac_bytes			+= port_stats.pmm.rbyte;
+	p_stats->rx_mac_uc_packets		+= port_stats.pmm.rxuca;
+	p_stats->rx_mac_mc_packets		+= port_stats.pmm.rxmca;
+	p_stats->rx_mac_bc_packets		+= port_stats.pmm.rxbca;
+	p_stats->rx_mac_frames_ok		+= port_stats.pmm.rxpok;
+	p_stats->tx_mac_bytes			+= port_stats.pmm.tbyte;
+	p_stats->tx_mac_uc_packets		+= port_stats.pmm.txuca;
+	p_stats->tx_mac_mc_packets		+= port_stats.pmm.txmca;
+	p_stats->tx_mac_bc_packets		+= port_stats.pmm.txbca;
+	p_stats->tx_mac_ctrl_frames		+= port_stats.pmm.txcf;
+	for (j = 0; j < 8; j++) {
+		p_stats->brb_truncates	+= port_stats.brb.brb_truncate[j];
+		p_stats->brb_discards	+= port_stats.brb.brb_discard[j];
+	}
+}
+
+static void __qed_get_vport_stats(struct qed_hwfn *p_hwfn,
+				  struct qed_ptt *p_ptt,
+				  struct qed_eth_stats *stats,
+				  u16 statistics_bin)
+{
+	__qed_get_vport_mstats(p_hwfn, p_ptt, stats, statistics_bin);
+	__qed_get_vport_ustats(p_hwfn, p_ptt, stats, statistics_bin);
+	__qed_get_vport_tstats(p_hwfn, p_ptt, stats, statistics_bin);
+	__qed_get_vport_pstats(p_hwfn, p_ptt, stats, statistics_bin);
+
+	if (p_hwfn->mcp_info)
+		__qed_get_vport_port_stats(p_hwfn, p_ptt, stats);
+}
+
+static void _qed_get_vport_stats(struct qed_dev *cdev,
+				 struct qed_eth_stats *stats)
+{
+	u8	fw_vport = 0;
+	int	i;
+
+	memset(stats, 0, sizeof(*stats));
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+		struct qed_ptt *p_ptt;
+
+		/* The main vport index is relative first */
+		if (qed_fw_vport(p_hwfn, 0, &fw_vport)) {
+			DP_ERR(p_hwfn, "No vport available!\n");
+			continue;
+		}
+
+		p_ptt = qed_ptt_acquire(p_hwfn);
+		if (!p_ptt) {
+			DP_ERR(p_hwfn, "Failed to acquire ptt\n");
+			continue;
+		}
+
+		__qed_get_vport_stats(p_hwfn, p_ptt, stats, fw_vport);
+
+		qed_ptt_release(p_hwfn, p_ptt);
+	}
+}
+
+void qed_get_vport_stats(struct qed_dev *cdev,
+			 struct qed_eth_stats *stats)
+{
+	u32 i;
+
+	if (!cdev) {
+		memset(stats, 0, sizeof(*stats));
+		return;
+	}
+
+	_qed_get_vport_stats(cdev, stats);
+
+	if (!cdev->reset_stats)
+		return;
+
+	/* Reduce the statistics baseline */
+	for (i = 0; i < sizeof(struct qed_eth_stats) / sizeof(u64); i++)
+		((u64 *)stats)[i] -= ((u64 *)cdev->reset_stats)[i];
+}
+
+/* zeroes V-PORT specific portion of stats (Port stats remains untouched) */
+void qed_reset_vport_stats(struct qed_dev *cdev)
+{
+	int i;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+		struct eth_mstorm_per_queue_stat mstats;
+		struct eth_ustorm_per_queue_stat ustats;
+		struct eth_pstorm_per_queue_stat pstats;
+		struct qed_ptt *p_ptt = qed_ptt_acquire(p_hwfn);
+		u32 addr = 0, len = 0;
+
+		if (!p_ptt) {
+			DP_ERR(p_hwfn, "Failed to acquire ptt\n");
+			continue;
+		}
+
+		memset(&mstats, 0, sizeof(mstats));
+		__qed_get_vport_mstats_addrlen(p_hwfn, &addr, &len, 0);
+		qed_memcpy_to(p_hwfn, p_ptt, addr, &mstats, len);
+
+		memset(&ustats, 0, sizeof(ustats));
+		__qed_get_vport_ustats_addrlen(p_hwfn, &addr, &len, 0);
+		qed_memcpy_to(p_hwfn, p_ptt, addr, &ustats, len);
+
+		memset(&pstats, 0, sizeof(pstats));
+		__qed_get_vport_pstats_addrlen(p_hwfn, &addr, &len, 0);
+		qed_memcpy_to(p_hwfn, p_ptt, addr, &pstats, len);
+
+		qed_ptt_release(p_hwfn, p_ptt);
+	}
+
+	/* PORT statistics are not necessarily reset, so we need to
+	 * read and create a baseline for future statistics.
+	 */
+	if (!cdev->reset_stats)
+		DP_INFO(cdev, "Reset stats not allocated\n");
+	else
+		_qed_get_vport_stats(cdev, cdev->reset_stats);
+}
+
 static int qed_fill_eth_dev_info(struct qed_dev *cdev,
 				 struct qed_dev_eth_info *info)
 {
-- 
1.9.3
