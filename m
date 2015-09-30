From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [RFC v3 net-next 09/10] qed: Add statistics support
Date: Wed, 30 Sep 2015 16:03:36 +0300
Message-ID: <1443618217-18069-10-git-send-email-Yuval.Mintz@qlogic.com>
References: <1443618217-18069-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, <Yuval.Mintz@qlogic.com>,
	Manish Chopra <Manish.Chopra@qlogic.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:44001 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933138AbbI3NET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 09:04:19 -0400
Received: from pps.filterd (m0045602.ppops.net [127.0.0.1])
	by mx0a-0016ce01.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id t8UD35we001279
	for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 06:04:18 -0700
Received: from avcashub1.qlogic.com (avcashub2.qlogic.com [198.70.193.116])
	by mx0a-0016ce01.pphosted.com with ESMTP id 1x5tguwa28-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 06:04:18 -0700
In-Reply-To: <1443618217-18069-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <Manish.Chopra@qlogic.com>

Device statistics can be gathered on-demand. This adds the qed support for
reading the statistics [both function and port] from the device, and adds
to the public API a method for requesting the current statistics.

Signed-off-by: Manish Chopra <Manish.Chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h         |  14 ++
 drivers/net/ethernet/qlogic/qed/qed_dev.c     | 244 +++++++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h |   3 +
 drivers/net/ethernet/qlogic/qed/qed_hsi.h     |  30 ++++
 drivers/net/ethernet/qlogic/qed/qed_l2.c      |   3 +
 include/linux/qed/qed_eth_if.h                |   3 +
 6 files changed, 296 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 4e21d79..f195cbd 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -212,7 +212,20 @@ struct qed_qm_info {
 	u32				pf_rl;
 };
 
+struct storm_stats {
+	u32     address;
+	u32     len;
+};
+
+struct qed_storm_stats {
+	struct storm_stats mstats;
+	struct storm_stats pstats;
+	struct storm_stats tstats;
+	struct storm_stats ustats;
+};
+
 struct qed_fw_data {
+	struct fw_ver_info	*fw_ver_info;
 	const u8		*modes_tree_buf;
 	union init_op		*init_ops;
 	const u32		*arr_data;
@@ -296,6 +309,7 @@ struct qed_hwfn {
 
 	/* QM init */
 	struct qed_qm_info		qm_info;
+	struct qed_storm_stats		storm_stats;
 
 	/* Buffer for unzipping firmware data */
 	void				*unzip_buf;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index cde72e2..3993584 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -647,8 +647,10 @@ int qed_hw_init(struct qed_dev *cdev,
 		bool allow_npar_tx_switch,
 		const u8 *bin_fw_data)
 {
-	u32 load_code, param;
+	struct qed_storm_stats *p_stat;
+	u32 load_code, param, *p_address;
 	int rc, mfw_rc, i;
+	u8 fw_vport = 0;
 
 	rc = qed_init_fw_data(cdev, bin_fw_data);
 	if (rc != 0)
@@ -657,6 +659,10 @@ int qed_hw_init(struct qed_dev *cdev,
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
+		rc = qed_fw_vport(p_hwfn, 0, &fw_vport);
+		if (rc != 0)
+			return rc;
+
 		/* Enable DMAE in PXP */
 		rc = qed_change_pci_hwfn(p_hwfn, p_hwfn->p_main_ptt, true);
 
@@ -723,6 +729,25 @@ int qed_hw_init(struct qed_dev *cdev,
 		}
 
 		p_hwfn->hw_init_done = true;
+
+		/* init PF stats */
+		p_stat = &p_hwfn->storm_stats;
+		p_stat->mstats.address = BAR0_MAP_REG_MSDM_RAM +
+					 MSTORM_QUEUE_STAT_OFFSET(fw_vport);
+		p_stat->mstats.len = sizeof(struct eth_mstorm_per_queue_stat);
+
+		p_stat->ustats.address = BAR0_MAP_REG_USDM_RAM +
+					 USTORM_QUEUE_STAT_OFFSET(fw_vport);
+		p_stat->ustats.len = sizeof(struct eth_ustorm_per_queue_stat);
+
+		p_stat->pstats.address = BAR0_MAP_REG_PSDM_RAM +
+					 PSTORM_QUEUE_STAT_OFFSET(fw_vport);
+		p_stat->pstats.len = sizeof(struct eth_pstorm_per_queue_stat);
+
+		p_address = &p_stat->tstats.address;
+		*p_address = BAR0_MAP_REG_TSDM_RAM +
+			     TSTORM_PORT_STAT_OFFSET(MFW_PORT(p_hwfn));
+		p_stat->tstats.len = sizeof(struct tstorm_per_port_stat);
 	}
 
 	return 0;
@@ -1503,6 +1528,223 @@ void qed_chain_free(struct qed_dev *cdev,
 			  p_chain->p_phys_addr);
 }
 
+static void __qed_get_vport_stats(struct qed_dev	*cdev,
+				  struct qed_eth_stats  *stats)
+{
+	int i, j;
+
+	memset(stats, 0, sizeof(*stats));
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+		struct eth_mstorm_per_queue_stat mstats;
+		struct eth_ustorm_per_queue_stat ustats;
+		struct eth_pstorm_per_queue_stat pstats;
+		struct tstorm_per_port_stat tstats;
+		struct port_stats port_stats;
+		struct qed_ptt *p_ptt = qed_ptt_acquire(p_hwfn);
+
+		if (!p_ptt) {
+			DP_ERR(p_hwfn, "Failed to acquire ptt\n");
+			continue;
+		}
+
+		memset(&mstats, 0, sizeof(mstats));
+		qed_memcpy_from(p_hwfn, p_ptt, &mstats,
+				p_hwfn->storm_stats.mstats.address,
+				p_hwfn->storm_stats.mstats.len);
+
+		memset(&ustats, 0, sizeof(ustats));
+		qed_memcpy_from(p_hwfn, p_ptt, &ustats,
+				p_hwfn->storm_stats.ustats.address,
+				p_hwfn->storm_stats.ustats.len);
+
+		memset(&pstats, 0, sizeof(pstats));
+		qed_memcpy_from(p_hwfn, p_ptt, &pstats,
+				p_hwfn->storm_stats.pstats.address,
+				p_hwfn->storm_stats.pstats.len);
+
+		memset(&tstats, 0, sizeof(tstats));
+		qed_memcpy_from(p_hwfn, p_ptt, &tstats,
+				p_hwfn->storm_stats.tstats.address,
+				p_hwfn->storm_stats.tstats.len);
+
+		memset(&port_stats, 0, sizeof(port_stats));
+
+		if (p_hwfn->mcp_info)
+			qed_memcpy_from(p_hwfn, p_ptt, &port_stats,
+					p_hwfn->mcp_info->port_addr +
+					offsetof(struct public_port, stats),
+					sizeof(port_stats));
+		qed_ptt_release(p_hwfn, p_ptt);
+
+		stats->no_buff_discards +=
+			HILO_64_REGPAIR(mstats.no_buff_discard);
+		stats->packet_too_big_discard +=
+			HILO_64_REGPAIR(mstats.packet_too_big_discard);
+		stats->ttl0_discard +=
+			HILO_64_REGPAIR(mstats.ttl0_discard);
+		stats->tpa_coalesced_pkts +=
+			HILO_64_REGPAIR(mstats.tpa_coalesced_pkts);
+		stats->tpa_coalesced_events +=
+			HILO_64_REGPAIR(mstats.tpa_coalesced_events);
+		stats->tpa_aborts_num +=
+			HILO_64_REGPAIR(mstats.tpa_aborts_num);
+		stats->tpa_coalesced_bytes +=
+			HILO_64_REGPAIR(mstats.tpa_coalesced_bytes);
+
+		stats->rx_ucast_bytes +=
+			HILO_64_REGPAIR(ustats.rcv_ucast_bytes);
+		stats->rx_mcast_bytes +=
+			HILO_64_REGPAIR(ustats.rcv_mcast_bytes);
+		stats->rx_bcast_bytes +=
+			HILO_64_REGPAIR(ustats.rcv_bcast_bytes);
+		stats->rx_ucast_pkts +=
+			HILO_64_REGPAIR(ustats.rcv_ucast_pkts);
+		stats->rx_mcast_pkts +=
+			HILO_64_REGPAIR(ustats.rcv_mcast_pkts);
+		stats->rx_bcast_pkts +=
+			HILO_64_REGPAIR(ustats.rcv_bcast_pkts);
+
+		stats->mftag_filter_discards +=
+			HILO_64_REGPAIR(tstats.mftag_filter_discard);
+		stats->mac_filter_discards +=
+			HILO_64_REGPAIR(tstats.eth_mac_filter_discard);
+
+		stats->tx_ucast_bytes +=
+			HILO_64_REGPAIR(pstats.sent_ucast_bytes);
+		stats->tx_mcast_bytes +=
+			HILO_64_REGPAIR(pstats.sent_mcast_bytes);
+		stats->tx_bcast_bytes +=
+			HILO_64_REGPAIR(pstats.sent_bcast_bytes);
+		stats->tx_ucast_pkts +=
+			HILO_64_REGPAIR(pstats.sent_ucast_pkts);
+		stats->tx_mcast_pkts +=
+			HILO_64_REGPAIR(pstats.sent_mcast_pkts);
+		stats->tx_bcast_pkts +=
+			HILO_64_REGPAIR(pstats.sent_bcast_pkts);
+		stats->tx_err_drop_pkts +=
+			HILO_64_REGPAIR(pstats.error_drop_pkts);
+		stats->rx_64_byte_packets       += port_stats.pmm.r64;
+		stats->rx_127_byte_packets      += port_stats.pmm.r127;
+		stats->rx_255_byte_packets      += port_stats.pmm.r255;
+		stats->rx_511_byte_packets      += port_stats.pmm.r511;
+		stats->rx_1023_byte_packets     += port_stats.pmm.r1023;
+		stats->rx_1518_byte_packets     += port_stats.pmm.r1518;
+		stats->rx_1522_byte_packets     += port_stats.pmm.r1522;
+		stats->rx_2047_byte_packets     += port_stats.pmm.r2047;
+		stats->rx_4095_byte_packets     += port_stats.pmm.r4095;
+		stats->rx_9216_byte_packets     += port_stats.pmm.r9216;
+		stats->rx_16383_byte_packets    += port_stats.pmm.r16383;
+		stats->rx_crc_errors	    += port_stats.pmm.rfcs;
+		stats->rx_mac_crtl_frames       += port_stats.pmm.rxcf;
+		stats->rx_pause_frames	  += port_stats.pmm.rxpf;
+		stats->rx_pfc_frames	    += port_stats.pmm.rxpp;
+		stats->rx_align_errors	  += port_stats.pmm.raln;
+		stats->rx_carrier_errors	+= port_stats.pmm.rfcr;
+		stats->rx_oversize_packets      += port_stats.pmm.rovr;
+		stats->rx_jabbers	       += port_stats.pmm.rjbr;
+		stats->rx_undersize_packets     += port_stats.pmm.rund;
+		stats->rx_fragments	     += port_stats.pmm.rfrg;
+		stats->tx_64_byte_packets       += port_stats.pmm.t64;
+		stats->tx_65_to_127_byte_packets += port_stats.pmm.t127;
+		stats->tx_128_to_255_byte_packets += port_stats.pmm.t255;
+		stats->tx_256_to_511_byte_packets  += port_stats.pmm.t511;
+		stats->tx_512_to_1023_byte_packets += port_stats.pmm.t1023;
+		stats->tx_1024_to_1518_byte_packets += port_stats.pmm.t1518;
+		stats->tx_1519_to_2047_byte_packets += port_stats.pmm.t2047;
+		stats->tx_2048_to_4095_byte_packets += port_stats.pmm.t4095;
+		stats->tx_4096_to_9216_byte_packets += port_stats.pmm.t9216;
+		stats->tx_9217_to_16383_byte_packets += port_stats.pmm.t16383;
+		stats->tx_pause_frames	  += port_stats.pmm.txpf;
+		stats->tx_pfc_frames	    += port_stats.pmm.txpp;
+		stats->tx_lpi_entry_count       += port_stats.pmm.tlpiec;
+		stats->tx_total_collisions      += port_stats.pmm.tncl;
+		stats->rx_mac_bytes	     += port_stats.pmm.rbyte;
+		stats->rx_mac_uc_packets	+= port_stats.pmm.rxuca;
+		stats->rx_mac_mc_packets	+= port_stats.pmm.rxmca;
+		stats->rx_mac_bc_packets	+= port_stats.pmm.rxbca;
+		stats->rx_mac_frames_ok	 += port_stats.pmm.rxpok;
+		stats->tx_mac_bytes	     += port_stats.pmm.tbyte;
+		stats->tx_mac_uc_packets	+= port_stats.pmm.txuca;
+		stats->tx_mac_mc_packets	+= port_stats.pmm.txmca;
+		stats->tx_mac_bc_packets	+= port_stats.pmm.txbca;
+		stats->tx_mac_ctrl_frames       += port_stats.pmm.txcf;
+
+		for (j = 0; j < 8; j++) {
+			stats->brb_truncates += port_stats.brb.brb_truncate[j];
+			stats->brb_discards += port_stats.brb.brb_discard[j];
+		}
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
+	__qed_get_vport_stats(cdev, stats);
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
+
+		if (!p_ptt) {
+			DP_ERR(p_hwfn, "Failed to acquire ptt\n");
+			continue;
+		}
+
+		memset(&mstats, 0, sizeof(mstats));
+		qed_memcpy_to(p_hwfn, p_ptt,
+			      p_hwfn->storm_stats.mstats.address,
+			      &mstats,
+			      p_hwfn->storm_stats.mstats.len);
+
+		memset(&ustats, 0, sizeof(ustats));
+		qed_memcpy_to(p_hwfn, p_ptt,
+			      p_hwfn->storm_stats.ustats.address,
+			      &ustats,
+			      p_hwfn->storm_stats.ustats.len);
+
+		memset(&pstats, 0, sizeof(pstats));
+		qed_memcpy_to(p_hwfn, p_ptt,
+			      p_hwfn->storm_stats.pstats.address,
+			      &pstats,
+			      p_hwfn->storm_stats.pstats.len);
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
+		__qed_get_vport_stats(cdev, cdev->reset_stats);
+}
+
 int qed_fw_l2_queue(struct qed_hwfn *p_hwfn,
 		    u16 src_id,
 		    u16 *dst_id)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
index 2207483..a8017aa 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
@@ -155,6 +155,9 @@ struct qed_ptt *qed_ptt_acquire(struct qed_hwfn *p_hwfn);
  */
 void qed_ptt_release(struct qed_hwfn	*p_hwfn,
 		     struct qed_ptt	*p_ptt);
+void qed_get_vport_stats(struct qed_dev *cdev,
+			 struct qed_eth_stats   *stats);
+void qed_reset_vport_stats(struct qed_dev *cdev);
 
 enum qed_dmae_address_type_t {
 	QED_DMAE_ADDRESS_HOST_VIRT,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index f94b50c..72da343 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -354,6 +354,36 @@ struct core_conn_context {
 	struct regpair			ustorm_st_padding[2] /* padding */;
 };
 
+struct eth_mstorm_per_queue_stat {
+	struct regpair  ttl0_discard;
+	struct regpair  packet_too_big_discard;
+	struct regpair  no_buff_discard;
+	struct regpair  not_active_discard;
+	struct regpair  tpa_coalesced_pkts;
+	struct regpair  tpa_coalesced_events;
+	struct regpair  tpa_aborts_num;
+	struct regpair  tpa_coalesced_bytes;
+};
+
+struct eth_pstorm_per_queue_stat {
+	struct regpair  sent_ucast_bytes;
+	struct regpair  sent_mcast_bytes;
+	struct regpair  sent_bcast_bytes;
+	struct regpair  sent_ucast_pkts;
+	struct regpair  sent_mcast_pkts;
+	struct regpair  sent_bcast_pkts;
+	struct regpair  error_drop_pkts;
+};
+
+struct eth_ustorm_per_queue_stat {
+	struct regpair  rcv_ucast_bytes;
+	struct regpair  rcv_mcast_bytes;
+	struct regpair  rcv_bcast_bytes;
+	struct regpair  rcv_ucast_pkts;
+	struct regpair  rcv_mcast_pkts;
+	struct regpair  rcv_bcast_pkts;
+};
+
 /* Event Ring Next Page Address */
 struct event_ring_next_addr {
 	struct regpair	addr /* Next Page Address */;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index e4747c6..e0d0dc1 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -1353,6 +1353,8 @@ static int qed_start_vport(struct qed_dev	*cdev,
 			   vport_id, mtu);
 	}
 
+	qed_reset_vport_stats(cdev);
+
 	return 0;
 }
 
@@ -1747,6 +1749,7 @@ static const struct qed_eth_ops qed_eth_ops_pass = {
 	.filter_config = &qed_configure_filter,
 	.fastpath_stop = &qed_fastpath_stop,
 	.eth_cqe_completion = &qed_fp_cqe_completion,
+	.get_vport_stats = &qed_get_vport_stats,
 };
 
 const struct qed_eth_ops	*qed_get_eth_ops(u32 version)
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index cae4877..1244d22 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -149,6 +149,9 @@ struct qed_eth_ops {
 	int (*eth_cqe_completion)(struct qed_dev *cdev,
 				  u8 rss_id,
 				  struct eth_slow_path_rx_cqe *cqe);
+
+	void (*get_vport_stats)(struct qed_dev *cdev,
+				struct qed_eth_stats *stats);
 };
 
 const struct qed_eth_ops *qed_get_eth_ops(u32 version);
-- 
1.9.3
