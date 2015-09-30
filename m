From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [RFC v3 net-next 04/10] qed: Add slowpath L2 support
Date: Wed, 30 Sep 2015 16:03:31 +0300
Message-ID: <1443618217-18069-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1443618217-18069-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, <Yuval.Mintz@qlogic.com>,
	Manish Chopra <Manish.Chopra@qlogic.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:43015 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932936AbbI3NEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 09:04:02 -0400
Received: from pps.filterd (m0085408.ppops.net [127.0.0.1])
	by mx0b-0016ce01.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id t8UD2SsK005194
	for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 06:04:02 -0700
Received: from avcashub1.qlogic.com (avcashub2.qlogic.com [198.70.193.116])
	by mx0b-0016ce01.pphosted.com with ESMTP id 1x5tbnw9nj-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 06:04:01 -0700
In-Reply-To: <1443618217-18069-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <Manish.Chopra@qlogic.com>

This patch adds to the qed the support to configure various L2 elements,
such as channels and basic filtering conditions.
It also enhances its public API to allow qede to later utilize this
functionality.

Signed-off-by: Manish Chopra <Manish.Chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c     |  126 ++
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h |   58 +
 drivers/net/ethernet/qlogic/qed/qed_hsi.h     |  294 +++++
 drivers/net/ethernet/qlogic/qed/qed_l2.c      | 1672 +++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_main.c    |   10 +
 drivers/net/ethernet/qlogic/qed/qed_mcp.c     |   16 +
 drivers/net/ethernet/qlogic/qed/qed_mcp.h     |   13 +
 drivers/net/ethernet/qlogic/qed/qed_sp.h      |   27 +
 drivers/net/ethernet/qlogic/qed/qed_spq.c     |   29 +
 include/linux/qed/qed_eth_if.h                |  115 ++
 10 files changed, 2360 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 1053388d..30408b7 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -800,6 +800,60 @@ int qed_hw_stop(struct qed_dev *cdev)
 	return rc;
 }
 
+void qed_hw_stop_fastpath(struct qed_dev *cdev)
+{
+	int i, j;
+
+	for_each_hwfn(cdev, j) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[j];
+		struct qed_ptt *p_ptt   = p_hwfn->p_main_ptt;
+
+		DP_VERBOSE(p_hwfn,
+			   NETIF_MSG_IFDOWN,
+			   "Shutting down the fastpath\n");
+
+		qed_wr(p_hwfn, p_ptt,
+		       NIG_REG_RX_LLH_BRB_GATE_DNTFWD_PERPF, 0x1);
+
+		qed_wr(p_hwfn, p_ptt, PRS_REG_SEARCH_TCP, 0x0);
+		qed_wr(p_hwfn, p_ptt, PRS_REG_SEARCH_UDP, 0x0);
+		qed_wr(p_hwfn, p_ptt, PRS_REG_SEARCH_FCOE, 0x0);
+		qed_wr(p_hwfn, p_ptt, PRS_REG_SEARCH_ROCE, 0x0);
+		qed_wr(p_hwfn, p_ptt, PRS_REG_SEARCH_OPENFLOW, 0x0);
+
+		qed_wr(p_hwfn, p_ptt, TM_REG_PF_ENABLE_CONN, 0x0);
+		qed_wr(p_hwfn, p_ptt, TM_REG_PF_ENABLE_TASK, 0x0);
+		for (i = 0; i < QED_HW_STOP_RETRY_LIMIT; i++) {
+			if ((!qed_rd(p_hwfn, p_ptt,
+				     TM_REG_PF_SCAN_ACTIVE_CONN)) &&
+			    (!qed_rd(p_hwfn, p_ptt,
+				     TM_REG_PF_SCAN_ACTIVE_TASK)))
+				break;
+
+			usleep_range(1000, 2000);
+		}
+		if (i == QED_HW_STOP_RETRY_LIMIT)
+			DP_NOTICE(p_hwfn,
+				  "Timers linear scans are not over [Connection %02x Tasks %02x]\n",
+				  (u8)qed_rd(p_hwfn, p_ptt,
+					     TM_REG_PF_SCAN_ACTIVE_CONN),
+				  (u8)qed_rd(p_hwfn, p_ptt,
+					     TM_REG_PF_SCAN_ACTIVE_TASK));
+
+		qed_int_igu_init_pure_rt(p_hwfn, p_ptt, false, false);
+
+		/* Need to wait 1ms to guarantee SBs are cleared */
+		usleep_range(1000, 2000);
+	}
+}
+
+void qed_hw_start_fastpath(struct qed_hwfn *p_hwfn)
+{
+	/* Re-open incoming traffic */
+	qed_wr(p_hwfn, p_hwfn->p_main_ptt,
+	       NIG_REG_RX_LLH_BRB_GATE_DNTFWD_PERPF, 0x0);
+}
+
 static int qed_reg_assert(struct qed_hwfn *hwfn,
 			  struct qed_ptt *ptt, u32 reg,
 			  bool expected)
@@ -1346,3 +1400,75 @@ void qed_chain_free(struct qed_dev *cdev,
 			  p_chain->p_virt_addr,
 			  p_chain->p_phys_addr);
 }
+
+int qed_fw_l2_queue(struct qed_hwfn *p_hwfn,
+		    u16 src_id,
+		    u16 *dst_id)
+{
+	if (src_id >= RESC_NUM(p_hwfn, QED_L2_QUEUE)) {
+		u16 min, max;
+
+		min     = (u16)RESC_START(p_hwfn, QED_L2_QUEUE);
+		max     = min + RESC_NUM(p_hwfn, QED_L2_QUEUE);
+		DP_NOTICE(
+			p_hwfn,
+			"l2_queue id [%d] is not valid, available indices [%d - %d]\n",
+			src_id,
+			min,
+			max);
+
+		return -EINVAL;
+	}
+
+	*dst_id = RESC_START(p_hwfn, QED_L2_QUEUE) + src_id;
+
+	return 0;
+}
+
+int qed_fw_vport(struct qed_hwfn	*p_hwfn,
+		 u8		     src_id,
+		 u8		     *dst_id)
+{
+	if (src_id >= RESC_NUM(p_hwfn, QED_VPORT)) {
+		u8 min, max;
+
+		min     = (u8)RESC_START(p_hwfn, QED_VPORT);
+		max     = min + RESC_NUM(p_hwfn, QED_VPORT);
+		DP_NOTICE(
+			p_hwfn,
+			"vport id [%d] is not valid, available indices [%d - %d]\n",
+			src_id,
+			min,
+			max);
+
+		return -EINVAL;
+	}
+
+	*dst_id = RESC_START(p_hwfn, QED_VPORT) + src_id;
+
+	return 0;
+}
+
+int qed_fw_rss_eng(struct qed_hwfn      *p_hwfn,
+		   u8		   src_id,
+		   u8		   *dst_id)
+{
+	if (src_id >= RESC_NUM(p_hwfn, QED_RSS_ENG)) {
+		u8 min, max;
+
+		min     = (u8)RESC_START(p_hwfn, QED_RSS_ENG);
+		max     = min + RESC_NUM(p_hwfn, QED_RSS_ENG);
+		DP_NOTICE(
+			p_hwfn,
+			"rss_eng id [%d] is not valid, available indices [%d - %d]\n",
+			src_id,
+			min,
+			max);
+
+		return -EINVAL;
+	}
+
+	*dst_id = RESC_START(p_hwfn, QED_RSS_ENG) + src_id;
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
index 1579035..2207483 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
@@ -86,6 +86,25 @@ int qed_hw_init(struct qed_dev			*cdev,
 int qed_hw_stop(struct qed_dev *cdev);
 
 /**
+ * @brief qed_hw_stop_fastpath -should be called incase
+ *		slowpath is still required for the device,
+ *		but fastpath is not.
+ *
+ * @param cdev
+ *
+ */
+void qed_hw_stop_fastpath(struct qed_dev *cdev);
+
+/**
+ * @brief qed_hw_start_fastpath -restart fastpath traffic,
+ *		only if hw_stop_fastpath was called
+ *
+ * @param cdev
+ *
+ */
+void qed_hw_start_fastpath(struct qed_hwfn *p_hwfn);
+
+/**
  * @brief qed_hw_reset -
  *
  * @param cdev
@@ -206,6 +225,45 @@ void qed_chain_free(struct qed_dev	*cdev,
 		    struct qed_chain	*p_chain);
 
 /**
+ * @@brief qed_fw_l2_queue - Get absolute L2 queue ID
+ *
+ *  @param p_hwfn
+ *  @param src_id - relative to p_hwfn
+ *  @param dst_id - absolute per engine
+ *
+ *  @return int
+ */
+int qed_fw_l2_queue(struct qed_hwfn	*p_hwfn,
+		    u16			src_id,
+		    u16			*dst_id);
+
+/**
+ * @@brief qed_fw_vport - Get absolute vport ID
+ *
+ *  @param p_hwfn
+ *  @param src_id - relative to p_hwfn
+ *  @param dst_id - absolute per engine
+ *
+ *  @return int
+ */
+int qed_fw_vport(struct qed_hwfn	*p_hwfn,
+		 u8			src_id,
+		 u8			*dst_id);
+
+/**
+ * @@brief qed_fw_rss_eng - Get absolute RSS engine ID
+ *
+ *  @param p_hwfn
+ *  @param src_id - relative to p_hwfn
+ *  @param dst_id - absolute per engine
+ *
+ *  @return int
+ */
+int qed_fw_rss_eng(struct qed_hwfn	*p_hwfn,
+		   u8			src_id,
+		   u8			*dst_id);
+
+/**
  * *@brief Cleanup of previous driver remains prior to load
  *
  * @param p_hwfn
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 52a6d68..f94b50c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -2567,6 +2567,300 @@ struct eth_conn_context {
 	struct ustorm_eth_conn_st_ctx	ustorm_st_context;
 };
 
+enum eth_filter_action {
+	ETH_FILTER_ACTION_REMOVE,
+	ETH_FILTER_ACTION_ADD,
+	ETH_FILTER_ACTION_REPLACE,
+	MAX_ETH_FILTER_ACTION
+};
+
+struct eth_filter_cmd {
+	u8      type /* Filter Type (MAC/VLAN/Pair/VNI) */;
+	u8      vport_id /* the vport id */;
+	u8      action /* filter command action: add/remove/replace */;
+	u8      reserved0;
+	__le32  vni;
+	__le16  mac_lsb;
+	__le16  mac_mid;
+	__le16  mac_msb;
+	__le16  vlan_id;
+};
+
+struct eth_filter_cmd_header {
+	u8      rx;
+	u8      tx;
+	u8      cmd_cnt;
+	u8      assert_on_error;
+	u8      reserved1[4];
+};
+
+enum eth_filter_type {
+	ETH_FILTER_TYPE_MAC,
+	ETH_FILTER_TYPE_VLAN,
+	ETH_FILTER_TYPE_PAIR,
+	ETH_FILTER_TYPE_INNER_MAC,
+	ETH_FILTER_TYPE_INNER_VLAN,
+	ETH_FILTER_TYPE_INNER_PAIR,
+	ETH_FILTER_TYPE_INNER_MAC_VNI_PAIR,
+	ETH_FILTER_TYPE_MAC_VNI_PAIR,
+	ETH_FILTER_TYPE_VNI,
+	MAX_ETH_FILTER_TYPE
+};
+
+enum eth_ramrod_cmd_id {
+	ETH_RAMROD_UNUSED,
+	ETH_RAMROD_VPORT_START /* VPort Start Ramrod */,
+	ETH_RAMROD_VPORT_UPDATE /* VPort Update Ramrod */,
+	ETH_RAMROD_VPORT_STOP /* VPort Stop Ramrod */,
+	ETH_RAMROD_RX_QUEUE_START /* RX Queue Start Ramrod */,
+	ETH_RAMROD_RX_QUEUE_STOP /* RX Queue Stop Ramrod */,
+	ETH_RAMROD_TX_QUEUE_START /* TX Queue Start Ramrod */,
+	ETH_RAMROD_TX_QUEUE_STOP /* TX Queue Stop Ramrod */,
+	ETH_RAMROD_FILTERS_UPDATE /* Add or Remove Mac/Vlan/Pair filters */,
+	ETH_RAMROD_RX_QUEUE_UPDATE /* RX Queue Update Ramrod */,
+	ETH_RAMROD_RESERVED,
+	ETH_RAMROD_RESERVED2,
+	ETH_RAMROD_RESERVED3,
+	ETH_RAMROD_RESERVED4,
+	ETH_RAMROD_RESERVED5,
+	ETH_RAMROD_RESERVED6,
+	ETH_RAMROD_RESERVED7,
+	ETH_RAMROD_RESERVED8,
+	MAX_ETH_RAMROD_CMD_ID
+};
+
+struct eth_vport_rss_config {
+	__le16 capabilities;
+#define ETH_VPORT_RSS_CONFIG_IPV4_CAPABILITY_MASK	0x1
+#define ETH_VPORT_RSS_CONFIG_IPV4_CAPABILITY_SHIFT       0
+#define ETH_VPORT_RSS_CONFIG_IPV6_CAPABILITY_MASK	0x1
+#define ETH_VPORT_RSS_CONFIG_IPV6_CAPABILITY_SHIFT       1
+#define ETH_VPORT_RSS_CONFIG_IPV4_TCP_CAPABILITY_MASK    0x1
+#define ETH_VPORT_RSS_CONFIG_IPV4_TCP_CAPABILITY_SHIFT   2
+#define ETH_VPORT_RSS_CONFIG_IPV6_TCP_CAPABILITY_MASK    0x1
+#define ETH_VPORT_RSS_CONFIG_IPV6_TCP_CAPABILITY_SHIFT   3
+#define ETH_VPORT_RSS_CONFIG_IPV4_UDP_CAPABILITY_MASK    0x1
+#define ETH_VPORT_RSS_CONFIG_IPV4_UDP_CAPABILITY_SHIFT   4
+#define ETH_VPORT_RSS_CONFIG_IPV6_UDP_CAPABILITY_MASK    0x1
+#define ETH_VPORT_RSS_CONFIG_IPV6_UDP_CAPABILITY_SHIFT   5
+#define ETH_VPORT_RSS_CONFIG_EN_5_TUPLE_CAPABILITY_MASK  0x1
+#define ETH_VPORT_RSS_CONFIG_EN_5_TUPLE_CAPABILITY_SHIFT 6
+#define ETH_VPORT_RSS_CONFIG_CALC_4TUP_TCP_FRAG_MASK     0x1
+#define ETH_VPORT_RSS_CONFIG_CALC_4TUP_TCP_FRAG_SHIFT    7
+#define ETH_VPORT_RSS_CONFIG_CALC_4TUP_UDP_FRAG_MASK     0x1
+#define ETH_VPORT_RSS_CONFIG_CALC_4TUP_UDP_FRAG_SHIFT    8
+#define ETH_VPORT_RSS_CONFIG_RESERVED0_MASK	      0x7F
+#define ETH_VPORT_RSS_CONFIG_RESERVED0_SHIFT	     9
+	u8      rss_id;
+	u8      rss_mode;
+	u8      update_rss_key;
+	u8      update_rss_ind_table;
+	u8      update_rss_capabilities;
+	u8      tbl_size;
+	__le32  reserved2[2];
+	__le16  indirection_table[ETH_RSS_IND_TABLE_ENTRIES_NUM];
+	__le32  rss_key[ETH_RSS_KEY_SIZE_REGS];
+	__le32  reserved3[2];
+};
+
+enum eth_vport_rss_mode {
+	ETH_VPORT_RSS_MODE_DISABLED,
+	ETH_VPORT_RSS_MODE_REGULAR,
+	MAX_ETH_VPORT_RSS_MODE
+};
+
+struct eth_vport_rx_mode {
+	__le16 state;
+#define ETH_VPORT_RX_MODE_UCAST_DROP_ALL_MASK	  0x1
+#define ETH_VPORT_RX_MODE_UCAST_DROP_ALL_SHIFT	 0
+#define ETH_VPORT_RX_MODE_UCAST_ACCEPT_ALL_MASK	0x1
+#define ETH_VPORT_RX_MODE_UCAST_ACCEPT_ALL_SHIFT       1
+#define ETH_VPORT_RX_MODE_UCAST_ACCEPT_UNMATCHED_MASK  0x1
+#define ETH_VPORT_RX_MODE_UCAST_ACCEPT_UNMATCHED_SHIFT 2
+#define ETH_VPORT_RX_MODE_MCAST_DROP_ALL_MASK	  0x1
+#define ETH_VPORT_RX_MODE_MCAST_DROP_ALL_SHIFT	 3
+#define ETH_VPORT_RX_MODE_MCAST_ACCEPT_ALL_MASK	0x1
+#define ETH_VPORT_RX_MODE_MCAST_ACCEPT_ALL_SHIFT       4
+#define ETH_VPORT_RX_MODE_BCAST_ACCEPT_ALL_MASK	0x1
+#define ETH_VPORT_RX_MODE_BCAST_ACCEPT_ALL_SHIFT       5
+#define ETH_VPORT_RX_MODE_RESERVED1_MASK	       0x3FF
+#define ETH_VPORT_RX_MODE_RESERVED1_SHIFT	      6
+	__le16 reserved2[3];
+};
+
+struct eth_vport_tpa_param {
+	u64     reserved[2];
+};
+
+struct eth_vport_tx_mode {
+	__le16 state;
+#define ETH_VPORT_TX_MODE_UCAST_DROP_ALL_MASK    0x1
+#define ETH_VPORT_TX_MODE_UCAST_DROP_ALL_SHIFT   0
+#define ETH_VPORT_TX_MODE_UCAST_ACCEPT_ALL_MASK  0x1
+#define ETH_VPORT_TX_MODE_UCAST_ACCEPT_ALL_SHIFT 1
+#define ETH_VPORT_TX_MODE_MCAST_DROP_ALL_MASK    0x1
+#define ETH_VPORT_TX_MODE_MCAST_DROP_ALL_SHIFT   2
+#define ETH_VPORT_TX_MODE_MCAST_ACCEPT_ALL_MASK  0x1
+#define ETH_VPORT_TX_MODE_MCAST_ACCEPT_ALL_SHIFT 3
+#define ETH_VPORT_TX_MODE_BCAST_ACCEPT_ALL_MASK  0x1
+#define ETH_VPORT_TX_MODE_BCAST_ACCEPT_ALL_SHIFT 4
+#define ETH_VPORT_TX_MODE_RESERVED1_MASK	 0x7FF
+#define ETH_VPORT_TX_MODE_RESERVED1_SHIFT	5
+	__le16 reserved2[3];
+};
+
+struct rx_queue_start_ramrod_data {
+	__le16	  rx_queue_id;
+	__le16	  num_of_pbl_pages;
+	__le16	  bd_max_bytes;
+	__le16	  sb_id;
+	u8	      sb_index;
+	u8	      vport_id;
+	u8	      default_rss_queue_flg;
+	u8	      complete_cqe_flg;
+	u8	      complete_event_flg;
+	u8	      stats_counter_id;
+	u8	      pin_context;
+	u8	      pxp_tph_valid_bd;
+	u8	      pxp_tph_valid_pkt;
+	u8	      pxp_st_hint;
+	__le16	  pxp_st_index;
+	u8	      reserved[4];
+	struct regpair  cqe_pbl_addr;
+	struct regpair  bd_base;
+	struct regpair  sge_base;
+};
+
+struct rx_queue_stop_ramrod_data {
+	__le16  rx_queue_id;
+	u8      complete_cqe_flg;
+	u8      complete_event_flg;
+	u8      vport_id;
+	u8      reserved[3];
+};
+
+struct rx_queue_update_ramrod_data {
+	__le16	  rx_queue_id;
+	u8	      complete_cqe_flg;
+	u8	      complete_event_flg;
+	u8	      init_sge_ring_flg;
+	u8	      vport_id;
+	u8	      pxp_tph_valid_sge;
+	u8	      pxp_st_hint;
+	__le16	  pxp_st_index;
+	u8	      reserved[6];
+	struct regpair  sge_base;
+};
+
+struct tx_queue_start_ramrod_data {
+	__le16  sb_id;
+	u8      sb_index;
+	u8      vport_id;
+	u8      tc;
+	u8      stats_counter_id;
+	__le16  qm_pq_id;
+	u8      flags;
+#define TX_QUEUE_START_RAMROD_DATA_DISABLE_OPPORTUNISTIC_MASK  0x1
+#define TX_QUEUE_START_RAMROD_DATA_DISABLE_OPPORTUNISTIC_SHIFT 0
+#define TX_QUEUE_START_RAMROD_DATA_TEST_MODE_PKT_DUP_MASK      0x1
+#define TX_QUEUE_START_RAMROD_DATA_TEST_MODE_PKT_DUP_SHIFT     1
+#define TX_QUEUE_START_RAMROD_DATA_TEST_MODE_TX_DEST_MASK      0x1
+#define TX_QUEUE_START_RAMROD_DATA_TEST_MODE_TX_DEST_SHIFT     2
+#define TX_QUEUE_START_RAMROD_DATA_RESERVED0_MASK	      0x1F
+#define TX_QUEUE_START_RAMROD_DATA_RESERVED0_SHIFT	     3
+	u8	      pin_context;
+	u8	      pxp_tph_valid_bd;
+	u8	      pxp_tph_valid_pkt;
+	__le16	  pxp_st_index;
+	u8	      pxp_st_hint;
+	u8	      reserved1[3];
+	__le16	  queue_zone_id;
+	__le16	  test_dup_count;
+	__le16	  pbl_size;
+	struct regpair  pbl_base_addr;
+};
+
+struct tx_queue_stop_ramrod_data {
+	__le16 reserved[4];
+};
+
+struct vport_filter_update_ramrod_data {
+	struct eth_filter_cmd_header    filter_cmd_hdr;
+	struct eth_filter_cmd	   filter_cmds[ETH_FILTER_RULES_COUNT];
+};
+
+struct vport_start_ramrod_data {
+	u8			      vport_id;
+	u8			      sw_fid;
+	__le16			  mtu;
+	u8			      drop_ttl0_en;
+	u8			      inner_vlan_removal_en;
+	struct eth_vport_rx_mode	rx_mode;
+	struct eth_vport_tx_mode	tx_mode;
+	struct eth_vport_tpa_param      tpa_param;
+	__le16			  sge_buff_size;
+	u8			      max_sges_num;
+	u8			      tx_switching_en;
+	u8			      anti_spoofing_en;
+	u8			      default_vlan_en;
+	u8			      handle_ptp_pkts;
+	u8			      silent_vlan_removal_en;
+	__le16			  default_vlan;
+	u8			      untagged;
+	u8			      reserved[7];
+};
+
+struct vport_stop_ramrod_data {
+	u8      vport_id;
+	u8      reserved[7];
+};
+
+struct vport_update_ramrod_data_cmn {
+	u8      vport_id;
+	u8      update_rx_active_flg;
+	u8      rx_active_flg;
+	u8      update_tx_active_flg;
+	u8      tx_active_flg;
+	u8      update_rx_mode_flg;
+	u8      update_tx_mode_flg;
+	u8      update_approx_mcast_flg;
+	u8      update_rss_flg;
+	u8      update_inner_vlan_removal_en_flg;
+	u8      inner_vlan_removal_en;
+	u8      update_tpa_param_flg;
+	u8      update_tpa_en_flg;
+	u8      update_sge_param_flg;
+	__le16  sge_buff_size;
+	u8      max_sges_num;
+	u8      update_tx_switching_en_flg;
+	u8      tx_switching_en;
+	u8      update_anti_spoofing_en_flg;
+	u8      anti_spoofing_en;
+	u8      update_handle_ptp_pkts;
+	u8      handle_ptp_pkts;
+	u8      update_default_vlan_en_flg;
+	u8      default_vlan_en;
+	u8      update_default_vlan_flg;
+	__le16  default_vlan;
+	u8      update_accept_any_vlan_flg;
+	u8      accept_any_vlan;
+	u8      silent_vlan_removal_en;
+	u8      reserved;
+};
+
+struct vport_update_ramrod_mcast {
+	__le32 bins[ETH_MULTICAST_MAC_BINS_IN_REGS];
+};
+
+struct vport_update_ramrod_data {
+	struct vport_update_ramrod_data_cmn     common;
+	struct eth_vport_rx_mode		rx_mode;
+	struct eth_vport_tx_mode		tx_mode;
+	struct eth_vport_tpa_param	      tpa_param;
+	struct vport_update_ramrod_mcast	approx_mcast;
+	struct eth_vport_rss_config	     rss_config;
+};
+
 struct mstorm_eth_conn_ag_ctx {
 	u8	byte0 /* cdu_validation */;
 	u8	byte1 /* state */;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index a8620b5..71f21dc 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -34,6 +34,1257 @@
 #include "qed_reg_addr.h"
 #include "qed_sp.h"
 
+enum qed_rss_caps {
+	QED_RSS_IPV4		= 0x1,
+	QED_RSS_IPV6		= 0x2,
+	QED_RSS_IPV4_TCP	= 0x4,
+	QED_RSS_IPV6_TCP	= 0x8,
+	QED_RSS_IPV4_UDP	= 0x10,
+	QED_RSS_IPV6_UDP	= 0x20,
+};
+
+/* Should be the same as ETH_RSS_IND_TABLE_ENTRIES_NUM */
+#define QED_RSS_IND_TABLE_SIZE 128
+#define QED_RSS_KEY_SIZE 10 /* size in 32b chunks */
+
+struct qed_rss_params {
+	u8	update_rss_config;
+	u8	rss_enable;
+	u8	rss_eng_id;
+	u8	update_rss_capabilities;
+	u8	update_rss_ind_table;
+	u8	update_rss_key;
+	u8	rss_caps;
+	u8	rss_table_size_log;
+	u16	rss_ind_table[QED_RSS_IND_TABLE_SIZE];
+	u32	rss_key[QED_RSS_KEY_SIZE];
+};
+
+enum qed_filter_opcode {
+	QED_FILTER_ADD,
+	QED_FILTER_REMOVE,
+	QED_FILTER_MOVE,
+	QED_FILTER_REPLACE,     /* Delete all MACs and add new one instead */
+	QED_FILTER_FLUSH,       /* Removes all filters */
+};
+
+enum qed_filter_ucast_type {
+	QED_FILTER_MAC,
+	QED_FILTER_VLAN,
+	QED_FILTER_MAC_VLAN,
+	QED_FILTER_INNER_MAC,
+	QED_FILTER_INNER_VLAN,
+	QED_FILTER_INNER_PAIR,
+	QED_FILTER_INNER_MAC_VNI_PAIR,
+	QED_FILTER_MAC_VNI_PAIR,
+	QED_FILTER_VNI,
+};
+
+struct qed_filter_ucast {
+	enum qed_filter_opcode		opcode;
+	enum qed_filter_ucast_type	type;
+	u8				is_rx_filter;
+	u8				is_tx_filter;
+	u8				vport_to_add_to;
+	u8				vport_to_remove_from;
+	unsigned char			mac[ETH_ALEN];
+	u8				assert_on_error;
+	u16				vlan;
+	u32				vni;
+};
+
+struct qed_filter_mcast {
+	/* MOVE is not supported for multicast */
+	enum qed_filter_opcode	opcode;
+	u8			vport_to_add_to;
+	u8			vport_to_remove_from;
+	u8			num_mc_addrs;
+#define QED_MAX_MC_ADDRS        64
+	unsigned char		mac[QED_MAX_MC_ADDRS][ETH_ALEN];
+};
+
+struct qed_filter_accept_flags {
+	u8	update_rx_mode_config;
+	u8	update_tx_mode_config;
+	u8	rx_accept_filter;
+	u8	tx_accept_filter;
+#define QED_ACCEPT_NONE         0x01
+#define QED_ACCEPT_UCAST_MATCHED        0x02
+#define QED_ACCEPT_UCAST_UNMATCHED      0x04
+#define QED_ACCEPT_MCAST_MATCHED        0x08
+#define QED_ACCEPT_MCAST_UNMATCHED      0x10
+#define QED_ACCEPT_BCAST                0x20
+};
+
+struct qed_sp_vport_update_params {
+	u16				opaque_fid;
+	u8				vport_id;
+	u8				update_vport_active_rx_flg;
+	u8				vport_active_rx_flg;
+	u8				update_vport_active_tx_flg;
+	u8				vport_active_tx_flg;
+	u8				update_approx_mcast_flg;
+	unsigned long			bins[8];
+	struct qed_rss_params		*rss_params;
+	struct qed_filter_accept_flags	accept_flags;
+};
+
+#define QED_MAX_SGES_NUM 16
+#define CRC32_POLY 0x1edc6f41
+
+static int qed_sp_vport_start(struct qed_hwfn *p_hwfn,
+			      u32 concrete_fid,
+			      u16 opaque_fid,
+			      u8 vport_id,
+			      u16 mtu,
+			      u8 drop_ttl0_flg,
+			      u8 inner_vlan_removal_en_flg)
+{
+	int				rc		= -EPIPE;
+	struct vport_start_ramrod_data	*p_ramrod	= NULL;
+	struct qed_spq_entry		*p_ent		= NULL;
+	u16				rx_mode		= 0;
+	u8				abs_vport_id	= 0;
+
+	rc = qed_fw_vport(p_hwfn, vport_id, &abs_vport_id);
+	if (rc != 0)
+		return rc;
+
+	rc = qed_sp_init_request(&p_ent,
+				 qed_spq_get_cid(p_hwfn),
+				 opaque_fid,
+				 p_hwfn,
+				 ETH_RAMROD_VPORT_START,
+				 PROTOCOLID_ETH,
+				 sizeof(*p_ramrod),
+				 QED_SPQ_MODE_EBLOCK,
+				 NULL);
+
+	if (rc != 0)
+		return rc;
+
+	p_ramrod		= &p_ent->ramrod.vport_start;
+	p_ramrod->vport_id	= abs_vport_id;
+
+	p_ramrod->mtu			= cpu_to_le16(mtu);
+	p_ramrod->inner_vlan_removal_en = inner_vlan_removal_en_flg;
+	p_ramrod->drop_ttl0_en		= drop_ttl0_flg;
+
+	SET_FIELD(rx_mode, ETH_VPORT_RX_MODE_UCAST_DROP_ALL, 1);
+	SET_FIELD(rx_mode, ETH_VPORT_RX_MODE_MCAST_DROP_ALL, 1);
+
+	p_ramrod->rx_mode.state = cpu_to_le16(rx_mode);
+
+	/* TPA related fields */
+	memset(&p_ramrod->tpa_param, 0,
+	       sizeof(struct eth_vport_tpa_param));
+
+	/* Software Function ID in hwfn (PFs are 0 - 15, VFs are 16 - 135) */
+	p_ramrod->sw_fid = qed_concrete_to_sw_fid(p_hwfn->cdev,
+						  concrete_fid);
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+
+	return rc;
+}
+
+static int
+qed_sp_vport_update_rss(struct qed_hwfn			*p_hwfn,
+			struct vport_update_ramrod_data *p_ramrod,
+			struct qed_rss_params		*p_rss_params)
+{
+	int	rc		= 0;
+	u16	abs_l2_queue	= 0;
+	int	i;
+
+	if (!p_rss_params) {
+		p_ramrod->common.update_rss_flg = 0;
+		return rc;
+	}
+
+	BUILD_BUG_ON(QED_RSS_IND_TABLE_SIZE !=
+		     ETH_RSS_IND_TABLE_ENTRIES_NUM);
+
+	rc = qed_fw_rss_eng(p_hwfn, p_rss_params->rss_eng_id,
+			    &p_ramrod->rss_config.rss_id);
+	if (rc != 0)
+		return rc;
+
+	p_ramrod->common.update_rss_flg =
+		p_rss_params->update_rss_config;
+	p_ramrod->rss_config.update_rss_capabilities =
+		p_rss_params->update_rss_capabilities;
+	p_ramrod->rss_config.update_rss_ind_table =
+		p_rss_params->update_rss_ind_table;
+	p_ramrod->rss_config.update_rss_key = p_rss_params->update_rss_key;
+
+	p_ramrod->rss_config.rss_mode = p_rss_params->rss_enable ?
+		ETH_VPORT_RSS_MODE_REGULAR : ETH_VPORT_RSS_MODE_DISABLED;
+
+	p_ramrod->rss_config.capabilities = 0;
+
+	SET_FIELD(p_ramrod->rss_config.capabilities,
+		  ETH_VPORT_RSS_CONFIG_IPV4_CAPABILITY,
+		  !!(p_rss_params->rss_caps & QED_RSS_IPV4));
+	SET_FIELD(p_ramrod->rss_config.capabilities,
+		  ETH_VPORT_RSS_CONFIG_IPV6_CAPABILITY,
+		  !!(p_rss_params->rss_caps & QED_RSS_IPV6));
+	SET_FIELD(p_ramrod->rss_config.capabilities,
+		  ETH_VPORT_RSS_CONFIG_IPV4_TCP_CAPABILITY,
+		  !!(p_rss_params->rss_caps & QED_RSS_IPV4_TCP));
+	SET_FIELD(p_ramrod->rss_config.capabilities,
+		  ETH_VPORT_RSS_CONFIG_IPV6_TCP_CAPABILITY,
+		  !!(p_rss_params->rss_caps & QED_RSS_IPV6_TCP));
+	SET_FIELD(p_ramrod->rss_config.capabilities,
+		  ETH_VPORT_RSS_CONFIG_IPV4_UDP_CAPABILITY,
+		  !!(p_rss_params->rss_caps & QED_RSS_IPV4_UDP));
+	SET_FIELD(p_ramrod->rss_config.capabilities,
+		  ETH_VPORT_RSS_CONFIG_IPV6_UDP_CAPABILITY,
+		  !!(p_rss_params->rss_caps & QED_RSS_IPV6_UDP));
+	p_ramrod->rss_config.tbl_size =
+		p_rss_params->rss_table_size_log;
+	p_ramrod->rss_config.capabilities =
+		cpu_to_le16(p_ramrod->rss_config.capabilities);
+
+	DP_VERBOSE(
+		p_hwfn,
+		NETIF_MSG_IFUP,
+		"update rss flag %d, rss_mode = %d, update_caps = %d, capabilities = %d, update_ind = %d, update_rss_key = %d\n",
+		p_ramrod->common.update_rss_flg,
+		p_ramrod->rss_config.rss_mode,
+		p_ramrod->rss_config.update_rss_capabilities,
+		p_ramrod->rss_config.capabilities,
+		p_ramrod->rss_config.update_rss_ind_table,
+		p_ramrod->rss_config.update_rss_key);
+
+	for (i = 0; i < QED_RSS_IND_TABLE_SIZE; i++) {
+		rc = qed_fw_l2_queue(p_hwfn,
+				     (u8)p_rss_params->rss_ind_table[i],
+				     &abs_l2_queue);
+		if (rc != 0)
+			return rc;
+
+		p_ramrod->rss_config.indirection_table[i] =
+			cpu_to_le16(abs_l2_queue);
+		DP_VERBOSE(p_hwfn, NETIF_MSG_IFUP, "i= %d, queue = %d\n",
+			   i, p_ramrod->rss_config.indirection_table[i]);
+	}
+
+	for (i = 0; i < 10; i++)
+		p_ramrod->rss_config.rss_key[i] =
+			cpu_to_le32(p_rss_params->rss_key[i]);
+
+	return rc;
+}
+
+static void
+qed_sp_update_accept_mode(struct qed_hwfn			*p_hwfn,
+			  struct vport_update_ramrod_data	*p_ramrod,
+			  struct qed_filter_accept_flags	accept_flags)
+{
+	p_ramrod->common.update_rx_mode_flg =
+		accept_flags.update_rx_mode_config;
+
+	p_ramrod->common.update_tx_mode_flg =
+		accept_flags.update_tx_mode_config;
+
+	/* Set Rx mode accept flags */
+	if (p_ramrod->common.update_rx_mode_flg) {
+		__le16	*state		= &p_ramrod->rx_mode.state;
+		u8	accept_filter	= accept_flags.rx_accept_filter;
+
+		SET_FIELD(*state, ETH_VPORT_RX_MODE_UCAST_DROP_ALL,
+			  !(!!(accept_filter & QED_ACCEPT_UCAST_MATCHED) ||
+			    !!(accept_filter & QED_ACCEPT_UCAST_UNMATCHED)));
+
+		SET_FIELD(*state, ETH_VPORT_RX_MODE_UCAST_ACCEPT_UNMATCHED,
+			  !!(accept_filter & QED_ACCEPT_UCAST_UNMATCHED));
+
+		SET_FIELD(*state, ETH_VPORT_RX_MODE_MCAST_DROP_ALL,
+			  !(!!(accept_filter & QED_ACCEPT_MCAST_MATCHED) ||
+			    !!(accept_filter & QED_ACCEPT_MCAST_UNMATCHED)));
+
+		SET_FIELD(*state, ETH_VPORT_RX_MODE_MCAST_ACCEPT_ALL,
+			  (!!(accept_filter & QED_ACCEPT_MCAST_MATCHED) &&
+			   !!(accept_filter & QED_ACCEPT_MCAST_UNMATCHED)));
+
+		SET_FIELD(*state, ETH_VPORT_RX_MODE_BCAST_ACCEPT_ALL,
+			  !!(accept_filter & QED_ACCEPT_BCAST));
+
+		DP_VERBOSE(p_hwfn, QED_MSG_SP,
+			   "p_ramrod->rx_mode.state = 0x%x\n",
+			   p_ramrod->rx_mode.state);
+	}
+
+	/* Set Tx mode accept flags */
+	if (p_ramrod->common.update_tx_mode_flg) {
+		__le16	*state		= &p_ramrod->tx_mode.state;
+		u8	accept_filter	= accept_flags.tx_accept_filter;
+
+		SET_FIELD(*state, ETH_VPORT_TX_MODE_UCAST_DROP_ALL,
+			  !!(accept_filter & QED_ACCEPT_NONE));
+
+		SET_FIELD(*state, ETH_VPORT_TX_MODE_UCAST_ACCEPT_ALL,
+			  (!!(accept_filter & QED_ACCEPT_UCAST_MATCHED) &&
+			   !!(accept_filter & QED_ACCEPT_UCAST_UNMATCHED)));
+
+		SET_FIELD(*state, ETH_VPORT_TX_MODE_MCAST_DROP_ALL,
+			  !!(accept_filter & QED_ACCEPT_NONE));
+
+		SET_FIELD(*state, ETH_VPORT_TX_MODE_MCAST_ACCEPT_ALL,
+			  (!!(accept_filter & QED_ACCEPT_MCAST_MATCHED) &&
+			   !!(accept_filter & QED_ACCEPT_MCAST_UNMATCHED)));
+
+		SET_FIELD(*state, ETH_VPORT_TX_MODE_BCAST_ACCEPT_ALL,
+			  !!(accept_filter & QED_ACCEPT_BCAST));
+
+		DP_VERBOSE(p_hwfn, QED_MSG_SP,
+			   "p_ramrod->tx_mode.state = 0x%x\n",
+			   p_ramrod->tx_mode.state);
+	}
+}
+
+static void
+qed_sp_update_mcast_bin(struct qed_hwfn				*p_hwfn,
+			struct vport_update_ramrod_data		*p_ramrod,
+			struct qed_sp_vport_update_params	*p_params)
+{
+	int i;
+
+	memset(&p_ramrod->approx_mcast.bins, 0,
+	       sizeof(p_ramrod->approx_mcast.bins));
+
+	if (p_params->update_approx_mcast_flg) {
+		p_ramrod->common.update_approx_mcast_flg = 1;
+		for (i = 0; i < ETH_MULTICAST_MAC_BINS_IN_REGS; i++) {
+			u32 *p_bins = (u32 *)p_params->bins;
+
+			p_ramrod->approx_mcast.bins[i] =
+				cpu_to_le32(p_bins[i]);
+		}
+	}
+}
+
+static int
+qed_sp_vport_update(struct qed_hwfn *p_hwfn,
+		    struct qed_sp_vport_update_params *p_params,
+		    enum spq_mode comp_mode,
+		    struct qed_spq_comp_cb *p_comp_data)
+{
+	int				rc		= -EPIPE;
+	struct qed_rss_params		*p_rss_params	= p_params->rss_params;
+	struct vport_update_ramrod_data *p_ramrod	= NULL;
+	struct qed_spq_entry		*p_ent		= NULL;
+	u8				abs_vport_id	= 0;
+
+	rc = qed_fw_vport(p_hwfn, p_params->vport_id, &abs_vport_id);
+	if (rc != 0)
+		return rc;
+
+	rc = qed_sp_init_request(&p_ent,
+				 qed_spq_get_cid(p_hwfn),
+				 p_params->opaque_fid,
+				 p_hwfn,
+				 ETH_RAMROD_VPORT_UPDATE,
+				 PROTOCOLID_ETH,
+				 sizeof(*p_ramrod),
+				 comp_mode,
+				 p_comp_data);
+
+	if (rc != 0)
+		return rc;
+
+	/* Copy input params to ramrod according to FW struct */
+	p_ramrod = &p_ent->ramrod.vport_update;
+
+	p_ramrod->common.vport_id = abs_vport_id;
+
+	p_ramrod->common.rx_active_flg		= p_params->vport_active_rx_flg;
+	p_ramrod->common.update_rx_active_flg	=
+		p_params->update_vport_active_rx_flg;
+	p_ramrod->common.tx_active_flg		= p_params->vport_active_tx_flg;
+	p_ramrod->common.update_tx_active_flg	=
+		p_params->update_vport_active_tx_flg;
+
+	rc = qed_sp_vport_update_rss(p_hwfn, p_ramrod, p_rss_params);
+	if (rc != 0) {
+		/* Return spq entry which is taken in qed_sp_init_request()*/
+		qed_spq_return_entry(p_hwfn, p_ent);
+		return rc;
+	}
+
+	/* Update mcast bins for VFs, PF doesn't use this functionality */
+	qed_sp_update_mcast_bin(p_hwfn, p_ramrod, p_params);
+
+	qed_sp_update_accept_mode(p_hwfn, p_ramrod, p_params->accept_flags);
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+
+	return rc;
+}
+
+static int qed_sp_vport_stop(struct qed_hwfn *p_hwfn,
+			     u16 opaque_fid,
+			     u8 vport_id)
+{
+	int				rc;
+	struct vport_stop_ramrod_data	*p_ramrod;
+	struct qed_spq_entry		*p_ent;
+	u8				abs_vport_id = 0;
+
+	rc = qed_fw_vport(p_hwfn, vport_id, &abs_vport_id);
+	if (rc != 0)
+		return rc;
+
+	rc = qed_sp_init_request(&p_ent,
+				 qed_spq_get_cid(p_hwfn),
+				 opaque_fid,
+				 p_hwfn,
+				 ETH_RAMROD_VPORT_STOP,
+				 PROTOCOLID_ETH,
+				 sizeof(*p_ramrod),
+				 QED_SPQ_MODE_EBLOCK,
+				 NULL);
+
+	if (rc != 0)
+		return rc;
+
+	p_ramrod		= &p_ent->ramrod.vport_stop;
+	p_ramrod->vport_id	= abs_vport_id;
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+
+	return rc;
+}
+
+static int qed_filter_accept_cmd(struct qed_dev *cdev,
+				 u8 vport,
+				 struct qed_filter_accept_flags accept_flags,
+				 enum spq_mode comp_mode,
+				 struct qed_spq_comp_cb *p_comp_data)
+{
+	struct qed_sp_vport_update_params	vport_update_params;
+	int					i, rc;
+
+	/* Prepare and send the vport rx_mode change */
+	memset(&vport_update_params, 0, sizeof(vport_update_params));
+	vport_update_params.vport_id		= vport;
+	vport_update_params.accept_flags	= accept_flags;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		vport_update_params.opaque_fid = p_hwfn->hw_info.opaque_fid;
+
+		rc = qed_sp_vport_update(p_hwfn, &vport_update_params,
+					 comp_mode, p_comp_data);
+		if (rc != 0) {
+			DP_ERR(cdev, "Update rx_mode failed %d\n", rc);
+			return rc;
+		}
+
+		DP_VERBOSE(p_hwfn, QED_MSG_SP,
+			   "Accept filter configured, flags = [Rx]%x [Tx]%x\n",
+			   accept_flags.rx_accept_filter,
+			   accept_flags.tx_accept_filter);
+	}
+
+	return 0;
+}
+
+static int qed_sp_release_queue_cid(
+	struct qed_hwfn		*p_hwfn,
+	struct qed_hw_cid_data	*p_cid_data)
+{
+	if (!p_cid_data->b_cid_allocated)
+		return 0;
+
+	qed_cxt_release_cid(p_hwfn, p_cid_data->cid);
+
+	p_cid_data->b_cid_allocated = false;
+
+	return 0;
+}
+
+static int qed_sp_eth_rxq_start_ramrod(
+	struct qed_hwfn *p_hwfn,
+	u16		opaque_fid,
+	u32		cid,
+	u16		rx_queue_id,
+	u8		vport_id,
+	u8		stats_id,
+	u16		sb,
+	u8		sb_index,
+	u16		bd_max_bytes,
+	dma_addr_t	bd_chain_phys_addr,
+	dma_addr_t	cqe_pbl_addr,
+	u16		cqe_pbl_size)
+{
+	struct qed_hw_cid_data			*p_rx_cid =
+		&p_hwfn->p_rx_cids[rx_queue_id];
+	int					rc		= -EPIPE;
+	struct qed_spq_entry			*p_ent		= NULL;
+	struct rx_queue_start_ramrod_data	*p_ramrod	= NULL;
+	u16					abs_rx_q_id	= 0;
+	u8					abs_vport_id	= 0;
+
+	/* Store information for the stop */
+	p_rx_cid->cid		= cid;
+	p_rx_cid->opaque_fid	= opaque_fid;
+	p_rx_cid->vport_id	= vport_id;
+
+	rc = qed_fw_vport(p_hwfn, vport_id, &abs_vport_id);
+	if (rc != 0)
+		return rc;
+
+	rc = qed_fw_l2_queue(p_hwfn, rx_queue_id, &abs_rx_q_id);
+	if (rc != 0)
+		return rc;
+
+	DP_VERBOSE(
+		p_hwfn,
+		QED_MSG_SP,
+		"opaque_fid=0x%x, cid=0x%x, rx_qid=0x%x, vport_id=0x%x, sb_id=0x%x\n",
+		opaque_fid,
+		cid,
+		rx_queue_id,
+		vport_id,
+		sb);
+	rc = qed_sp_init_request(&p_ent,
+				 cid,
+				 opaque_fid,
+				 p_hwfn,
+				 ETH_RAMROD_RX_QUEUE_START,
+				 PROTOCOLID_ETH,
+				 sizeof(*p_ramrod),
+				 QED_SPQ_MODE_EBLOCK,
+				 NULL);
+
+	if (rc != 0)
+		return rc;
+
+	p_ramrod = &p_ent->ramrod.rx_queue_start;
+
+	p_ramrod->sb_id			= cpu_to_le16(sb);
+	p_ramrod->sb_index		= sb_index;
+	p_ramrod->vport_id		= abs_vport_id;
+	p_ramrod->stats_counter_id	= stats_id;
+	p_ramrod->rx_queue_id		= cpu_to_le16(abs_rx_q_id);
+	p_ramrod->complete_cqe_flg	= 0;
+	p_ramrod->complete_event_flg	= 1;
+
+	p_ramrod->bd_max_bytes	= cpu_to_le16(bd_max_bytes);
+	p_ramrod->bd_base.hi	= DMA_HI_LE(bd_chain_phys_addr);
+	p_ramrod->bd_base.lo	= DMA_LO_LE(bd_chain_phys_addr);
+
+	p_ramrod->num_of_pbl_pages	= cpu_to_le16(cqe_pbl_size);
+	p_ramrod->cqe_pbl_addr.hi	= DMA_HI_LE(cqe_pbl_addr);
+	p_ramrod->cqe_pbl_addr.lo	= DMA_LO_LE(cqe_pbl_addr);
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+
+	return rc;
+}
+
+static int qed_sp_eth_rx_queue_start(struct qed_hwfn	*p_hwfn,
+				     u16	opaque_fid,
+				     u8		rx_queue_id,
+				     u8		vport_id,
+				     u8		stats_id,
+				     u16	sb,
+				     u8		sb_index,
+				     u16	bd_max_bytes,
+				     dma_addr_t	bd_chain_phys_addr,
+				     dma_addr_t	cqe_pbl_addr,
+				     u16	cqe_pbl_size,
+				     void __iomem	**pp_prod)
+{
+	struct qed_hw_cid_data	*p_rx_cid =
+		&p_hwfn->p_rx_cids[rx_queue_id];
+	u8			abs_stats_id	= 0;
+	u16			abs_l2_queue	= 0;
+	int			rc;
+	u64			init_prod_val = 0;
+
+	rc = qed_fw_l2_queue(p_hwfn, rx_queue_id, &abs_l2_queue);
+	if (rc != 0)
+		return rc;
+
+	rc = qed_fw_vport(p_hwfn, stats_id, &abs_stats_id);
+	if (rc != 0)
+		return rc;
+
+	*pp_prod = (u8 __iomem *)p_hwfn->regview +
+		GTT_BAR0_MAP_REG_MSDM_RAM +
+		MSTORM_PRODS_OFFSET(abs_l2_queue);
+
+	/* Init the rcq, rx bd and rx sge (if valid) producers to 0 */
+	__internal_ram_wr(p_hwfn, *pp_prod, sizeof(u64),
+			  (u32 *)(&init_prod_val));
+
+	/* Allocate a CID for the queue */
+	rc = qed_cxt_acquire_cid(p_hwfn, PROTOCOLID_ETH,
+				 &p_rx_cid->cid);
+	if (rc != 0) {
+		DP_NOTICE(p_hwfn, "Failed to acquire cid\n");
+		return rc;
+	}
+	p_rx_cid->b_cid_allocated = true;
+
+	rc = qed_sp_eth_rxq_start_ramrod(p_hwfn,
+					 opaque_fid,
+					 p_rx_cid->cid,
+					 rx_queue_id,
+					 vport_id,
+					 abs_stats_id,
+					 sb,
+					 sb_index,
+					 bd_max_bytes,
+					 bd_chain_phys_addr,
+					 cqe_pbl_addr,
+					 cqe_pbl_size);
+
+	if (rc != 0)
+		qed_sp_release_queue_cid(p_hwfn, p_rx_cid);
+
+	return rc;
+}
+
+static int qed_sp_eth_rx_queue_stop(struct qed_hwfn *p_hwfn,
+				    u16 rx_queue_id,
+				    bool eq_completion_only,
+				    bool cqe_completion)
+{
+	int					rc		= -EPIPE;
+	struct qed_spq_entry			*p_ent		= NULL;
+	struct rx_queue_stop_ramrod_data	*p_ramrod	= NULL;
+	struct qed_hw_cid_data			*p_rx_cid	=
+		&p_hwfn->p_rx_cids[rx_queue_id];
+	u16					abs_rx_q_id = 0;
+
+	rc = qed_sp_init_request(&p_ent,
+				 p_rx_cid->cid,
+				 p_rx_cid->opaque_fid,
+				 p_hwfn,
+				 ETH_RAMROD_RX_QUEUE_STOP,
+				 PROTOCOLID_ETH,
+				 sizeof(*p_ramrod),
+				 QED_SPQ_MODE_EBLOCK,
+				 NULL);
+
+	if (rc != 0)
+		return rc;
+
+	p_ramrod = &p_ent->ramrod.rx_queue_stop;
+
+	qed_fw_vport(p_hwfn, p_rx_cid->vport_id, &p_ramrod->vport_id);
+	qed_fw_l2_queue(p_hwfn, rx_queue_id, &abs_rx_q_id);
+	p_ramrod->rx_queue_id = cpu_to_le16(abs_rx_q_id);
+
+	/* Cleaning the queue requires the completion to arrive there.
+	 * In addition, VFs require the answer to come as eqe to PF.
+	 */
+	p_ramrod->complete_cqe_flg =
+		(!!(p_rx_cid->opaque_fid == p_hwfn->hw_info.opaque_fid) &&
+		 !eq_completion_only) || cqe_completion;
+	p_ramrod->complete_event_flg =
+		!(p_rx_cid->opaque_fid == p_hwfn->hw_info.opaque_fid) ||
+		eq_completion_only;
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+
+	if (rc != 0)
+		return rc;
+
+	return qed_sp_release_queue_cid(p_hwfn, p_rx_cid);
+}
+
+static int qed_sp_eth_txq_start_ramrod(struct qed_hwfn *p_hwfn,
+				       u16 opaque_fid,
+				       u16 tx_queue_id,
+				       u32 cid,
+				       u8 vport_id,
+				       u8 stats_id,
+				       u16 sb,
+				       u8 sb_index,
+				       dma_addr_t pbl_addr,
+				       u16 pbl_size,
+				       union qed_qm_pq_params *p_pq_params)
+{
+	struct qed_hw_cid_data			*p_tx_cid =
+		&p_hwfn->p_tx_cids[tx_queue_id];
+	int					rc		= -EPIPE;
+	struct qed_spq_entry			*p_ent		= NULL;
+	struct tx_queue_start_ramrod_data	*p_ramrod	= NULL;
+	u16					pq_id;
+	u8					abs_vport_id;
+
+	/* Store information for the stop */
+	p_tx_cid->cid		= cid;
+	p_tx_cid->opaque_fid	= opaque_fid;
+
+	rc = qed_fw_vport(p_hwfn, vport_id, &abs_vport_id);
+	if (rc != 0)
+		return rc;
+
+	rc = qed_sp_init_request(&p_ent,
+				 cid,
+				 opaque_fid,
+				 p_hwfn,
+				 ETH_RAMROD_TX_QUEUE_START,
+				 PROTOCOLID_ETH,
+				 sizeof(*p_ramrod),
+				 QED_SPQ_MODE_EBLOCK,
+				 NULL);
+
+	if (rc != 0)
+		return rc;
+
+	p_ramrod		= &p_ent->ramrod.tx_queue_start;
+	p_ramrod->vport_id	= abs_vport_id;
+
+	p_ramrod->sb_id			= cpu_to_le16(sb);
+	p_ramrod->sb_index		= sb_index;
+	p_ramrod->stats_counter_id	= stats_id;
+	p_ramrod->tc			= p_pq_params->eth.tc;
+
+	p_ramrod->pbl_size		= cpu_to_le16(pbl_size);
+	p_ramrod->pbl_base_addr.hi	= DMA_HI_LE(pbl_addr);
+	p_ramrod->pbl_base_addr.lo	= DMA_LO_LE(pbl_addr);
+
+	pq_id			= qed_get_qm_pq(p_hwfn,
+						PROTOCOLID_ETH,
+						p_pq_params);
+	p_ramrod->qm_pq_id	= cpu_to_le16(pq_id);
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+
+	return rc;
+}
+
+static int qed_sp_eth_tx_queue_start(struct qed_hwfn *p_hwfn,
+				     u16 opaque_fid,
+				     u16 tx_queue_id,
+				     u8 vport_id,
+				     u8 stats_id,
+				     u16 sb,
+				     u8 sb_index,
+				     dma_addr_t pbl_addr,
+				     u16 pbl_size,
+				     void __iomem **pp_doorbell)
+{
+	struct qed_hw_cid_data	*p_tx_cid = &p_hwfn->p_tx_cids[tx_queue_id];
+	union qed_qm_pq_params	pq_params;
+	int			rc;
+	u8			abs_stats_id = 0;
+
+	rc = qed_fw_vport(p_hwfn, stats_id, &abs_stats_id);
+	if (rc != 0)
+		return rc;
+
+	memset(p_tx_cid, 0, sizeof(*p_tx_cid));
+	memset(&pq_params, 0, sizeof(pq_params));
+
+	/* Allocate a CID for the queue */
+	rc = qed_cxt_acquire_cid(p_hwfn, PROTOCOLID_ETH,
+				 &p_tx_cid->cid);
+	if (rc != 0) {
+		DP_NOTICE(p_hwfn, "Failed to acquire cid\n");
+		return rc;
+	}
+	p_tx_cid->b_cid_allocated = true;
+
+	DP_VERBOSE(
+		p_hwfn,
+		QED_MSG_SP,
+		"opaque_fid=0x%x, cid=0x%x, tx_qid=0x%x, vport_id=0x%x, sb_id=0x%x\n",
+		opaque_fid,
+		p_tx_cid->cid,
+		tx_queue_id,
+		vport_id,
+		sb);
+
+	/* TODO - set tc in the pq_params for multi-cos */
+	rc = qed_sp_eth_txq_start_ramrod(p_hwfn,
+					 opaque_fid,
+					 tx_queue_id,
+					 p_tx_cid->cid,
+					 vport_id,
+					 abs_stats_id,
+					 sb,
+					 sb_index,
+					 pbl_addr,
+					 pbl_size,
+					 &pq_params);
+
+	*pp_doorbell = (u8 __iomem *)p_hwfn->doorbells +
+		DB_ADDR(p_tx_cid->cid, DQ_DEMS_LEGACY);
+
+	if (rc != 0)
+		qed_sp_release_queue_cid(p_hwfn, p_tx_cid);
+
+	return rc;
+}
+
+static int qed_sp_eth_tx_queue_stop(struct qed_hwfn *p_hwfn,
+				    u16 tx_queue_id)
+{
+	int					rc		= -EPIPE;
+	struct qed_spq_entry			*p_ent		= NULL;
+	struct tx_queue_stop_ramrod_data	*p_ramrod	= NULL;
+	struct qed_hw_cid_data			*p_tx_cid	=
+		&p_hwfn->p_tx_cids[tx_queue_id];
+
+	rc = qed_sp_init_request(&p_ent,
+				 p_tx_cid->cid,
+				 p_tx_cid->opaque_fid,
+				 p_hwfn,
+				 ETH_RAMROD_TX_QUEUE_STOP,
+				 PROTOCOLID_ETH,
+				 sizeof(*p_ramrod),
+				 QED_SPQ_MODE_EBLOCK,
+				 NULL);
+
+	if (rc != 0)
+		return rc;
+
+	p_ramrod = &p_ent->ramrod.tx_queue_stop;
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+
+	if (rc != 0)
+		return rc;
+
+	return qed_sp_release_queue_cid(p_hwfn, p_tx_cid);
+}
+
+static enum eth_filter_action
+qed_filter_action(enum qed_filter_opcode opcode)
+{
+	enum eth_filter_action action = MAX_ETH_FILTER_ACTION;
+
+	switch (opcode) {
+	case QED_FILTER_ADD:
+		action = ETH_FILTER_ACTION_ADD;
+		break;
+	case QED_FILTER_REMOVE:
+		action = ETH_FILTER_ACTION_REMOVE;
+		break;
+	case QED_FILTER_REPLACE:
+	case QED_FILTER_FLUSH:
+		action = ETH_FILTER_ACTION_REPLACE;
+		break;
+	default:
+		action = MAX_ETH_FILTER_ACTION;
+	}
+
+	return action;
+}
+
+static void qed_set_fw_mac_addr(__le16	*fw_msb,
+				__le16	*fw_mid,
+				__le16	*fw_lsb,
+				u8	*mac)
+{
+	((u8 *)fw_msb)[0]	= mac[1];
+	((u8 *)fw_msb)[1]	= mac[0];
+	((u8 *)fw_mid)[0]	= mac[3];
+	((u8 *)fw_mid)[1]	= mac[2];
+	((u8 *)fw_lsb)[0]	= mac[5];
+	((u8 *)fw_lsb)[1]	= mac[4];
+}
+
+static int
+qed_filter_ucast_common(struct qed_hwfn		*p_hwfn,
+			u16			opaque_fid,
+			struct qed_filter_ucast *p_filter_cmd,
+			struct vport_filter_update_ramrod_data
+						**pp_ramrod,
+			struct qed_spq_entry	**pp_ent,
+			enum spq_mode		comp_mode,
+			struct qed_spq_comp_cb	*p_comp_data)
+{
+	int					rc;
+	struct vport_filter_update_ramrod_data	*p_ramrod;
+	struct eth_filter_cmd			*p_first_filter;
+	struct eth_filter_cmd			*p_second_filter;
+	enum eth_filter_action			action;
+	u8					vport_to_add_to		= 0,
+						vport_to_remove_from	= 0;
+
+	rc = qed_fw_vport(p_hwfn, p_filter_cmd->vport_to_remove_from,
+			  &vport_to_remove_from);
+	if (rc != 0)
+		return rc;
+
+	rc = qed_fw_vport(p_hwfn, p_filter_cmd->vport_to_add_to,
+			  &vport_to_add_to);
+	if (rc != 0)
+		return rc;
+
+	rc = qed_sp_init_request(pp_ent,
+				 qed_spq_get_cid(p_hwfn),
+				 opaque_fid,
+				 p_hwfn,
+				 ETH_RAMROD_FILTERS_UPDATE,
+				 PROTOCOLID_ETH,
+				 sizeof(**pp_ramrod),
+				 comp_mode,
+				 p_comp_data);
+
+	if (rc != 0)
+		return rc;
+
+	*pp_ramrod =
+		&(*pp_ent)->ramrod.vport_filter_update;
+	p_ramrod			= *pp_ramrod;
+	p_ramrod->filter_cmd_hdr.rx	= p_filter_cmd->is_rx_filter ? 1 : 0;
+	p_ramrod->filter_cmd_hdr.tx = p_filter_cmd->is_tx_filter ? 1 : 0;
+
+	switch (p_filter_cmd->opcode) {
+	case QED_FILTER_FLUSH:
+		p_ramrod->filter_cmd_hdr.cmd_cnt = 0; break;
+	case QED_FILTER_MOVE:
+		p_ramrod->filter_cmd_hdr.cmd_cnt = 2; break;
+	default:
+		p_ramrod->filter_cmd_hdr.cmd_cnt = 1; break;
+	}
+
+	p_first_filter	= &p_ramrod->filter_cmds[0];
+	p_second_filter = &p_ramrod->filter_cmds[1];
+
+	switch (p_filter_cmd->type) {
+	case QED_FILTER_MAC:
+		p_first_filter->type = ETH_FILTER_TYPE_MAC; break;
+	case QED_FILTER_VLAN:
+		p_first_filter->type = ETH_FILTER_TYPE_VLAN; break;
+	case QED_FILTER_MAC_VLAN:
+		p_first_filter->type = ETH_FILTER_TYPE_PAIR; break;
+	case QED_FILTER_INNER_MAC:
+		p_first_filter->type = ETH_FILTER_TYPE_INNER_MAC; break;
+	case QED_FILTER_INNER_VLAN:
+		p_first_filter->type = ETH_FILTER_TYPE_INNER_VLAN; break;
+	case QED_FILTER_INNER_PAIR:
+		p_first_filter->type = ETH_FILTER_TYPE_INNER_PAIR; break;
+	case QED_FILTER_INNER_MAC_VNI_PAIR:
+		p_first_filter->type = ETH_FILTER_TYPE_INNER_MAC_VNI_PAIR;
+		break;
+	case QED_FILTER_MAC_VNI_PAIR:
+		p_first_filter->type = ETH_FILTER_TYPE_MAC_VNI_PAIR; break;
+	case QED_FILTER_VNI:
+		p_first_filter->type = ETH_FILTER_TYPE_VNI; break;
+	}
+
+	if ((p_first_filter->type == ETH_FILTER_TYPE_MAC) ||
+	    (p_first_filter->type == ETH_FILTER_TYPE_PAIR) ||
+	    (p_first_filter->type == ETH_FILTER_TYPE_INNER_MAC) ||
+	    (p_first_filter->type == ETH_FILTER_TYPE_INNER_PAIR) ||
+	    (p_first_filter->type == ETH_FILTER_TYPE_INNER_MAC_VNI_PAIR) ||
+	    (p_first_filter->type == ETH_FILTER_TYPE_MAC_VNI_PAIR)) {
+		qed_set_fw_mac_addr(&p_first_filter->mac_msb,
+				    &p_first_filter->mac_mid,
+				    &p_first_filter->mac_lsb,
+				    (u8 *)p_filter_cmd->mac);
+	}
+
+	if ((p_first_filter->type == ETH_FILTER_TYPE_VLAN) ||
+	    (p_first_filter->type == ETH_FILTER_TYPE_PAIR) ||
+	    (p_first_filter->type == ETH_FILTER_TYPE_INNER_VLAN) ||
+	    (p_first_filter->type == ETH_FILTER_TYPE_INNER_PAIR))
+		p_first_filter->vlan_id = cpu_to_le16(p_filter_cmd->vlan);
+
+	if ((p_first_filter->type == ETH_FILTER_TYPE_INNER_MAC_VNI_PAIR) ||
+	    (p_first_filter->type == ETH_FILTER_TYPE_MAC_VNI_PAIR) ||
+	    (p_first_filter->type == ETH_FILTER_TYPE_VNI))
+		p_first_filter->vni = cpu_to_le32(p_filter_cmd->vni);
+
+	if (p_filter_cmd->opcode == QED_FILTER_MOVE) {
+		p_second_filter->type		= p_first_filter->type;
+		p_second_filter->mac_msb	= p_first_filter->mac_msb;
+		p_second_filter->mac_mid	= p_first_filter->mac_mid;
+		p_second_filter->mac_lsb	= p_first_filter->mac_lsb;
+		p_second_filter->vlan_id	= p_first_filter->vlan_id;
+		p_second_filter->vni		= p_first_filter->vni;
+
+		p_first_filter->action = ETH_FILTER_ACTION_REMOVE;
+
+		p_first_filter->vport_id = vport_to_remove_from;
+
+		p_second_filter->action		= ETH_FILTER_ACTION_ADD;
+		p_second_filter->vport_id	= vport_to_add_to;
+	} else {
+		action = qed_filter_action(p_filter_cmd->opcode);
+
+		if (action == MAX_ETH_FILTER_ACTION) {
+			DP_NOTICE(p_hwfn,
+				  "%d is not supported yet\n",
+				  p_filter_cmd->opcode);
+			return -EPIPE;
+		}
+
+		p_first_filter->action		= action;
+		p_first_filter->vport_id	=
+			(p_filter_cmd->opcode == QED_FILTER_REMOVE) ?
+			vport_to_remove_from : vport_to_add_to;
+	}
+
+	return 0;
+}
+
+static int qed_sp_eth_filter_ucast(struct qed_hwfn *p_hwfn,
+				   u16 opaque_fid,
+				   struct qed_filter_ucast *p_filter_cmd,
+				   enum spq_mode comp_mode,
+				   struct qed_spq_comp_cb *p_comp_data)
+{
+	struct vport_filter_update_ramrod_data	*p_ramrod	= NULL;
+	struct qed_spq_entry			*p_ent		= NULL;
+	struct eth_filter_cmd_header		*p_header;
+	int					rc;
+
+	rc = qed_filter_ucast_common(p_hwfn, opaque_fid, p_filter_cmd,
+				     &p_ramrod, &p_ent,
+				     comp_mode, p_comp_data);
+	if (rc != 0) {
+		DP_ERR(p_hwfn, "Uni. filter command failed %d\n", rc);
+		return rc;
+	}
+	p_header			= &p_ramrod->filter_cmd_hdr;
+	p_header->assert_on_error	= p_filter_cmd->assert_on_error;
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+	if (rc != 0) {
+		DP_ERR(p_hwfn,
+		       "Unicast filter ADD command failed %d\n",
+		       rc);
+		return rc;
+	}
+
+	DP_VERBOSE(
+		p_hwfn,
+		QED_MSG_SP,
+		"Unicast filter configured, opcode = %s, type = %s, cmd_cnt = %d, is_rx_filter = %d, is_tx_filter = %d\n",
+		(p_filter_cmd->opcode == QED_FILTER_ADD) ? "ADD" :
+		((p_filter_cmd->opcode == QED_FILTER_REMOVE) ?
+		 "REMOVE" :
+		 ((p_filter_cmd->opcode == QED_FILTER_MOVE) ?
+		     "MOVE" : "REPLACE")),
+		(p_filter_cmd->type == QED_FILTER_MAC) ? "MAC" :
+		((p_filter_cmd->type == QED_FILTER_VLAN) ?
+		 "VLAN" : "MAC & VLAN"),
+		p_ramrod->filter_cmd_hdr.cmd_cnt,
+		p_filter_cmd->is_rx_filter,
+		p_filter_cmd->is_tx_filter);
+	DP_VERBOSE(
+		p_hwfn,
+		QED_MSG_SP,
+		"vport_to_add_to = %d, vport_to_remove_from = %d, mac = %2x:%2x:%2x:%2x:%2x:%2x, vlan = %d\n",
+		p_filter_cmd->vport_to_add_to,
+		p_filter_cmd->vport_to_remove_from,
+		p_filter_cmd->mac[0],
+		p_filter_cmd->mac[1],
+		p_filter_cmd->mac[2],
+		p_filter_cmd->mac[3],
+		p_filter_cmd->mac[4],
+		p_filter_cmd->mac[5],
+		p_filter_cmd->vlan);
+
+	return 0;
+}
+
+/*******************************************************************************
+ * Description:
+ *         Calculates crc 32 on a buffer
+ *         Note: crc32_length MUST be aligned to 8
+ * Return:
+ ******************************************************************************/
+static u32 qed_calc_crc32c(u8	*crc32_packet,
+			   u32	crc32_length,
+			   u32	crc32_seed,
+			   u8	complement)
+{
+	u32	byte		= 0;
+	u32	bit		= 0;
+	u8	msb		= 0;
+	u8	current_byte	= 0;
+	u32	crc32_result	= crc32_seed;
+
+	if ((!crc32_packet) ||
+	    (crc32_length == 0) ||
+	    ((crc32_length % 8) != 0))
+		return crc32_result;
+	for (byte = 0; byte < crc32_length; byte++) {
+		current_byte = crc32_packet[byte];
+		for (bit = 0; bit < 8; bit++) {
+			msb		= (u8)(crc32_result >> 31);
+			crc32_result	= crc32_result << 1;
+			if (msb != (0x1 & (current_byte >> bit))) {
+				crc32_result	= crc32_result ^ CRC32_POLY;
+				crc32_result	|= 1; /*crc32_result[0] = 1;*/
+			}
+		}
+	}
+	return crc32_result;
+}
+
+static inline u32 qed_crc32c_le(u32	seed,
+				u8	*mac,
+				u32	len)
+{
+	u32 packet_buf[2] = { 0 };
+
+	memcpy((u8 *)(&packet_buf[0]), &mac[0], 6);
+	return qed_calc_crc32c((u8 *)packet_buf, 8, seed, 0);
+}
+
+static u8 qed_mcast_bin_from_mac(u8 *mac)
+{
+	u32 crc = qed_crc32c_le(ETH_MULTICAST_BIN_FROM_MAC_SEED,
+				mac, ETH_ALEN);
+
+	return crc & 0xff;
+}
+
+static int
+qed_sp_eth_filter_mcast(struct qed_hwfn		*p_hwfn,
+			u16			opaque_fid,
+			struct qed_filter_mcast *p_filter_cmd,
+			enum spq_mode		comp_mode,
+			struct qed_spq_comp_cb	*p_comp_data)
+{
+	struct vport_update_ramrod_data *p_ramrod	= NULL;
+	struct qed_spq_entry		*p_ent		= NULL;
+	int				rc;
+	unsigned long			bins[ETH_MULTICAST_MAC_BINS_IN_REGS];
+	u8				abs_vport_id = 0;
+	int				i;
+
+	if (p_filter_cmd->opcode == QED_FILTER_ADD) {
+		rc = qed_fw_vport(p_hwfn, p_filter_cmd->vport_to_add_to,
+				  &abs_vport_id);
+		if (rc != 0)
+			return rc;
+	} else {
+		rc = qed_fw_vport(p_hwfn, p_filter_cmd->vport_to_remove_from,
+				  &abs_vport_id);
+		if (rc != 0)
+			return rc;
+	}
+
+	rc = qed_sp_init_request(&p_ent,
+				 qed_spq_get_cid(p_hwfn),
+				 p_hwfn->hw_info.opaque_fid,
+				 p_hwfn,
+				 ETH_RAMROD_VPORT_UPDATE,
+				 PROTOCOLID_ETH,
+				 sizeof(*p_ramrod),
+				 comp_mode,
+				 p_comp_data);
+
+	if (rc != 0) {
+		DP_ERR(p_hwfn, "Multi-cast command failed %d\n", rc);
+		return rc;
+	}
+
+	p_ramrod =
+		&p_ent->ramrod.vport_update;
+	p_ramrod->common.update_approx_mcast_flg = 1;
+
+	/* explicitly clear out the entire vector */
+	memset(&p_ramrod->approx_mcast.bins,
+	       0, sizeof(p_ramrod->approx_mcast.bins));
+	memset(bins, 0, sizeof(unsigned long) *
+	       ETH_MULTICAST_MAC_BINS_IN_REGS);
+	/* filter ADD op is explicit set op and it removes
+	 *  any existing filters for the vport
+	 */
+	if (p_filter_cmd->opcode == QED_FILTER_ADD) {
+		for (i = 0; i < p_filter_cmd->num_mc_addrs; i++) {
+			u32 bit;
+
+			bit = qed_mcast_bin_from_mac(p_filter_cmd->mac[i]);
+			__set_bit(bit, bins);
+		}
+
+		/* Convert to correct endianity */
+		for (i = 0; i < ETH_MULTICAST_MAC_BINS_IN_REGS; i++) {
+			u32 *p_bins = (u32 *)bins;
+
+			p_ramrod->approx_mcast.bins[i] =
+				cpu_to_le32(p_bins[i]);
+		}
+	}
+
+	p_ramrod->common.vport_id = abs_vport_id;
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+	if (rc != 0) {
+		DP_ERR(p_hwfn, "Multicast filter command failed %d\n", rc);
+		return rc;
+	}
+	return rc;
+}
+
+static int
+qed_filter_mcast_cmd(struct qed_dev *cdev,
+		     struct qed_filter_mcast *p_filter_cmd,
+		     enum spq_mode comp_mode,
+		     struct qed_spq_comp_cb *p_comp_data)
+{
+	int	rc = 0;
+	int	i;
+
+	/* only ADD and REMOVE operations are supported for multi-cast */
+	if ((QED_FILTER_ADD != p_filter_cmd->opcode &&
+	     (QED_FILTER_REMOVE != p_filter_cmd->opcode)) ||
+	    (p_filter_cmd->num_mc_addrs > QED_MAX_MC_ADDRS))
+		return -EINVAL;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		u16		opaque_fid;
+
+		if (rc != 0)
+			break;
+
+		opaque_fid = p_hwfn->hw_info.opaque_fid;
+
+		rc = qed_sp_eth_filter_mcast(p_hwfn,
+					     opaque_fid,
+					     p_filter_cmd,
+					     comp_mode,
+					     p_comp_data);
+	}
+	return rc;
+}
+
+static int qed_filter_ucast_cmd(struct qed_dev *cdev,
+				struct qed_filter_ucast *p_filter_cmd,
+				enum spq_mode comp_mode,
+				struct qed_spq_comp_cb *p_comp_data)
+{
+	int	rc = 0;
+	int	i;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+		u16		opaque_fid;
+
+		if (rc != 0)
+			break;
+
+		opaque_fid = p_hwfn->hw_info.opaque_fid;
+
+		rc = qed_sp_eth_filter_ucast(p_hwfn,
+					     opaque_fid,
+					     p_filter_cmd,
+					     comp_mode,
+					     p_comp_data);
+	}
+
+	return rc;
+}
+
 static int qed_fill_eth_dev_info(struct qed_dev *cdev,
 				 struct qed_dev_eth_info *info)
 {
@@ -63,9 +1314,430 @@ static int qed_fill_eth_dev_info(struct qed_dev *cdev,
 	return 0;
 }
 
+static int qed_start_vport(struct qed_dev	*cdev,
+			   u8			vport_id,
+			   u16			mtu,
+			   u8			drop_ttl0_flg,
+			   u8			inner_vlan_removal_en_flg)
+{
+	int rc, i;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn		= &cdev->hwfns[i];
+
+		rc = qed_sp_vport_start(p_hwfn,
+					p_hwfn->hw_info.concrete_fid,
+					p_hwfn->hw_info.opaque_fid,
+					vport_id,
+					mtu,
+					drop_ttl0_flg,
+					inner_vlan_removal_en_flg);
+
+		if (rc) {
+			DP_ERR(cdev, "Failed to start VPORT\n");
+			return rc;
+		}
+
+		qed_hw_start_fastpath(p_hwfn);
+
+		DP_VERBOSE(cdev, (QED_MSG_SPQ | NETIF_MSG_IFUP),
+			   "Started V-PORT %d with MTU %d\n",
+			   vport_id, mtu);
+	}
+
+	return 0;
+}
+
+static int qed_stop_vport(struct qed_dev	*cdev,
+			  u8			vport_id)
+{
+	int rc, i;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		rc = qed_sp_vport_stop(p_hwfn,
+				       p_hwfn->hw_info.opaque_fid,
+				       vport_id);
+
+		if (rc) {
+			DP_ERR(cdev, "Failed to stop VPORT\n");
+			return rc;
+		}
+	}
+	return 0;
+}
+
+static int qed_update_vport(struct qed_dev *cdev,
+			    struct qed_update_vport_params *params)
+{
+	struct qed_sp_vport_update_params	sp_params;
+	struct qed_rss_params			sp_rss_params;
+	int					rc, i;
+
+	if (!cdev)
+		return -ENODEV;
+
+	memset(&sp_params, 0, sizeof(sp_params));
+	memset(&sp_rss_params, 0, sizeof(sp_rss_params));
+
+	/* Translate protocol params into sp params */
+	sp_params.vport_id = params->vport_id;
+	sp_params.update_vport_active_rx_flg =
+		params->update_vport_active_flg;
+	sp_params.update_vport_active_tx_flg =
+		params->update_vport_active_flg;
+	sp_params.vport_active_rx_flg = params->vport_active_flg;
+	sp_params.vport_active_tx_flg = params->vport_active_flg;
+
+	/* RSS - is a bit tricky, since upper-layer isn't familiar with hwfns.
+	 * We need to re-fix the rss values per engine for CMT.
+	 */
+	if (cdev->num_hwfns > 1 && params->update_rss_flg) {
+		struct qed_update_vport_rss_params	*rss =
+			&params->rss_params;
+		int					k, max = 0;
+
+		/* Find largest entry, since it's possible RSS needs to
+		 * be disabled [in case only 1 queue per-hwfn]
+		 */
+		for (k = 0; k < QED_RSS_IND_TABLE_SIZE; k++)
+			max = (max > rss->rss_ind_table[k]) ?
+				max : rss->rss_ind_table[k];
+
+		/* Either fix RSS values or disable RSS */
+		if (cdev->num_hwfns < max + 1) {
+			int divisor = (max + cdev->num_hwfns - 1) /
+				cdev->num_hwfns;
+
+			DP_VERBOSE(cdev, (QED_MSG_SPQ | NETIF_MSG_IFUP),
+				   "CMT - fixing RSS values (modulo %02x)\n",
+				   divisor);
+
+			for (k = 0; k < QED_RSS_IND_TABLE_SIZE; k++)
+				rss->rss_ind_table[k] =
+					rss->rss_ind_table[k] % divisor;
+		} else {
+			DP_VERBOSE(cdev, (QED_MSG_SPQ | NETIF_MSG_IFUP),
+				   "CMT - 1 queue per-hwfn; Disabling RSS\n");
+			params->update_rss_flg = 0;
+		}
+	}
+
+	/* Now, update the RSS configuration for actual configuration */
+	if (params->update_rss_flg) {
+		sp_rss_params.update_rss_config		= 1;
+		sp_rss_params.rss_enable		= 1;
+		sp_rss_params.update_rss_capabilities	= 1;
+		sp_rss_params.update_rss_ind_table	= 1;
+		sp_rss_params.update_rss_key		= 1;
+		sp_rss_params.rss_caps			= QED_RSS_IPV4 |
+			QED_RSS_IPV6 |
+			QED_RSS_IPV4_TCP | QED_RSS_IPV6_TCP;
+		sp_rss_params.rss_table_size_log = 7; /* 2^7 = 128 */
+		memcpy(sp_rss_params.rss_ind_table,
+		       params->rss_params.rss_ind_table,
+		       QED_RSS_IND_TABLE_SIZE * sizeof(u16));
+		memcpy(sp_rss_params.rss_key, params->rss_params.rss_key,
+		       QED_RSS_KEY_SIZE * sizeof(u32));
+	}
+	sp_params.rss_params = &sp_rss_params;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		sp_params.opaque_fid	= p_hwfn->hw_info.opaque_fid;
+		rc			= qed_sp_vport_update(
+				p_hwfn,
+				&sp_params,
+				QED_SPQ_MODE_EBLOCK,
+				NULL);
+		if (rc) {
+			DP_ERR(cdev, "Failed to update VPORT\n");
+			return rc;
+		}
+
+		DP_VERBOSE(cdev, (QED_MSG_SPQ | NETIF_MSG_IFUP),
+			   "Updated V-PORT %d: active_flag %d [update %d]\n",
+			   params->vport_id, params->vport_active_flg,
+			   params->update_vport_active_flg);
+	}
+
+	return 0;
+}
+
+static int qed_start_rxq(struct qed_dev *cdev,
+			 u8		rss_id,
+			 u8		rx_queue_id,
+			 u8		vport_id,
+			 u16		sb,
+			 u8		sb_index,
+			 u16		bd_max_bytes,
+			 dma_addr_t	bd_chain_phys_addr,
+			 dma_addr_t	cqe_pbl_addr,
+			 u16		cqe_pbl_size,
+			 void __iomem	**pp_prod)
+{
+	struct qed_hwfn *p_hwfn;
+	int		rc, hwfn_index;
+
+	hwfn_index	= rss_id % cdev->num_hwfns;
+	p_hwfn		= &cdev->hwfns[hwfn_index];
+
+	rc = qed_sp_eth_rx_queue_start(p_hwfn,
+				       p_hwfn->hw_info.opaque_fid,
+				       rx_queue_id / cdev->num_hwfns,
+				       vport_id,
+				       vport_id,
+				       sb,
+				       sb_index,
+				       bd_max_bytes,
+				       bd_chain_phys_addr,
+				       cqe_pbl_addr,
+				       cqe_pbl_size,
+				       pp_prod);
+
+	if (rc) {
+		DP_ERR(cdev, "Failed to start RXQ#%d\n", rx_queue_id);
+		return rc;
+	}
+
+	DP_VERBOSE(cdev, (QED_MSG_SPQ | NETIF_MSG_IFUP),
+		   "Started RX-Q %d [rss %d] on V-PORT %d and SB %d\n",
+		   rx_queue_id, rss_id, vport_id,
+		   sb);
+
+	return 0;
+}
+
+static int qed_stop_rxq(struct qed_dev			*cdev,
+			struct qed_stop_rxq_params	*params)
+{
+	int		rc, hwfn_index;
+	struct qed_hwfn *p_hwfn;
+
+	hwfn_index	= params->rss_id % cdev->num_hwfns;
+	p_hwfn		= &cdev->hwfns[hwfn_index];
+
+	rc = qed_sp_eth_rx_queue_stop(p_hwfn,
+				      params->rx_queue_id / cdev->num_hwfns,
+				      params->eq_completion_only,
+				      false);
+	if (rc) {
+		DP_ERR(cdev, "Failed to stop RXQ#%d\n", params->rx_queue_id);
+		return rc;
+	}
+
+	return 0;
+}
+
+static int qed_start_txq(struct qed_dev *cdev,
+			 u8		rss_id,
+			 u16		tx_queue_id,
+			 u8		vport_id,
+			 u16		sb,
+			 u8		sb_index,
+			 dma_addr_t	pbl_addr,
+			 u16		pbl_size,
+			 void __iomem	**pp_doorbell)
+{
+	struct qed_hwfn *p_hwfn;
+	int		rc, hwfn_index;
+
+	hwfn_index	= rss_id % cdev->num_hwfns;
+	p_hwfn		= &cdev->hwfns[hwfn_index];
+
+	rc = qed_sp_eth_tx_queue_start(p_hwfn,
+				       p_hwfn->hw_info.opaque_fid,
+				       tx_queue_id / cdev->num_hwfns,
+				       vport_id,
+				       vport_id,
+				       sb,
+				       sb_index,
+				       pbl_addr,
+				       pbl_size,
+				       pp_doorbell);
+
+	if (rc) {
+		DP_ERR(cdev, "Failed to start TXQ#%d\n", tx_queue_id);
+		return rc;
+	}
+
+	DP_VERBOSE(cdev, (QED_MSG_SPQ | NETIF_MSG_IFUP),
+		   "Started TX-Q %d [rss %d] on V-PORT %d and SB %d\n",
+		   tx_queue_id, rss_id, vport_id,
+		   sb);
+
+	return 0;
+}
+
+#define QED_HW_STOP_RETRY_LIMIT (10)
+static int qed_fastpath_stop(struct qed_dev *cdev)
+{
+	qed_hw_stop_fastpath(cdev);
+
+	return 0;
+}
+
+static int qed_stop_txq(struct qed_dev			*cdev,
+			struct qed_stop_txq_params	*params)
+{
+	struct qed_hwfn *p_hwfn;
+	int		rc, hwfn_index;
+
+	hwfn_index	= params->rss_id % cdev->num_hwfns;
+	p_hwfn		= &cdev->hwfns[hwfn_index];
+
+	rc = qed_sp_eth_tx_queue_stop(p_hwfn,
+				      params->tx_queue_id / cdev->num_hwfns);
+	if (rc) {
+		DP_ERR(cdev, "Failed to stop TXQ#%d\n", params->tx_queue_id);
+		return rc;
+	}
+
+	return 0;
+}
+
+static int qed_configure_filter_rx_mode(struct qed_dev			*cdev,
+					enum qed_filter_rx_mode_type	type)
+{
+	struct qed_filter_accept_flags accept_flags;
+
+	memset(&accept_flags, 0, sizeof(accept_flags));
+
+	accept_flags.update_rx_mode_config	= 1;
+	accept_flags.update_tx_mode_config	= 1;
+	accept_flags.rx_accept_filter		= QED_ACCEPT_UCAST_MATCHED |
+		QED_ACCEPT_MCAST_MATCHED |
+		QED_ACCEPT_BCAST;
+	accept_flags.tx_accept_filter = QED_ACCEPT_UCAST_MATCHED |
+		QED_ACCEPT_MCAST_MATCHED |
+		QED_ACCEPT_BCAST;
+
+	if (type == QED_FILTER_RX_MODE_TYPE_PROMISC)
+		accept_flags.rx_accept_filter |= QED_ACCEPT_UCAST_UNMATCHED |
+			QED_ACCEPT_MCAST_UNMATCHED;
+	else if (type == QED_FILTER_RX_MODE_TYPE_MULTI_PROMISC)
+		accept_flags.rx_accept_filter |= QED_ACCEPT_MCAST_UNMATCHED;
+
+	return qed_filter_accept_cmd(cdev, 0, accept_flags,
+				     QED_SPQ_MODE_CB, NULL);
+}
+
+static int qed_configure_filter_ucast(struct qed_dev			*cdev,
+				      struct qed_filter_ucast_params	*params)
+{
+	struct qed_filter_ucast ucast;
+
+	if (!params->vlan_valid && !params->mac_valid) {
+		DP_NOTICE(
+			cdev,
+			"Tried configuring a unicast filter, but both MAC and VLAN are not set\n");
+		return -EINVAL;
+	}
+
+	memset(&ucast, 0, sizeof(ucast));
+	switch (params->type) {
+	case QED_FILTER_XCAST_TYPE_ADD:
+		ucast.opcode = QED_FILTER_ADD;
+		break;
+	case QED_FILTER_XCAST_TYPE_DEL:
+		ucast.opcode = QED_FILTER_REMOVE;
+		break;
+	case QED_FILTER_XCAST_TYPE_REPLACE:
+		ucast.opcode = QED_FILTER_REPLACE;
+		break;
+	default:
+		DP_NOTICE(cdev, "Unknown unicast filter type %d\n",
+			  params->type);
+	}
+
+	if (params->vlan_valid && params->mac_valid) {
+		ucast.type = QED_FILTER_MAC_VLAN;
+		ether_addr_copy(ucast.mac, params->mac);
+		ucast.vlan = params->vlan;
+	} else if (params->mac_valid) {
+		ucast.type = QED_FILTER_MAC;
+		ether_addr_copy(ucast.mac, params->mac);
+	} else {
+		ucast.type	= QED_FILTER_VLAN;
+		ucast.vlan	= params->vlan;
+	}
+
+	ucast.is_rx_filter	= true;
+	ucast.is_tx_filter	= true;
+
+	return qed_filter_ucast_cmd(cdev, &ucast, QED_SPQ_MODE_CB, NULL);
+}
+
+static int qed_configure_filter_mcast(struct qed_dev			*cdev,
+				      struct qed_filter_mcast_params	*params)
+{
+	struct qed_filter_mcast mcast;
+	int			i;
+
+	memset(&mcast, 0, sizeof(mcast));
+	switch (params->type) {
+	case QED_FILTER_XCAST_TYPE_ADD:
+		mcast.opcode = QED_FILTER_ADD;
+		break;
+	case QED_FILTER_XCAST_TYPE_DEL:
+		mcast.opcode = QED_FILTER_REMOVE;
+		break;
+	default:
+		DP_NOTICE(cdev, "Unknown multicast filter type %d\n",
+			  params->type);
+	}
+
+	mcast.num_mc_addrs = params->num;
+	for (i = 0; i < mcast.num_mc_addrs; i++)
+		ether_addr_copy(mcast.mac[i], params->mac[i]);
+
+	return qed_filter_mcast_cmd(cdev, &mcast,
+				    QED_SPQ_MODE_CB, NULL);
+}
+
+static int qed_configure_filter(struct qed_dev			*cdev,
+				struct qed_filter_params	*params)
+{
+	enum qed_filter_rx_mode_type accept_flags;
+
+	switch (params->type) {
+	case QED_FILTER_TYPE_UCAST:
+		return qed_configure_filter_ucast(cdev, &params->filter.ucast);
+	case QED_FILTER_TYPE_MCAST:
+		return qed_configure_filter_mcast(cdev, &params->filter.mcast);
+	case QED_FILTER_TYPE_RX_MODE:
+		accept_flags = params->filter.accept_flags;
+		return qed_configure_filter_rx_mode(cdev, accept_flags);
+	default:
+		DP_NOTICE(cdev, "Unknown filter type %d\n",
+			  (int)params->type);
+		return -EINVAL;
+	}
+}
+
+static int qed_fp_cqe_completion(struct qed_dev			*dev,
+				 u8				rss_id,
+				 struct eth_slow_path_rx_cqe	*cqe)
+{
+	return qed_eth_cqe_completion(&dev->hwfns[rss_id % dev->num_hwfns],
+				      cqe);
+}
+
 static const struct qed_eth_ops qed_eth_ops_pass = {
 	.common = &qed_common_ops_pass,
 	.fill_dev_info = &qed_fill_eth_dev_info,
+	.vport_start = &qed_start_vport,
+	.vport_stop = &qed_stop_vport,
+	.vport_update = &qed_update_vport,
+	.q_rx_start = &qed_start_rxq,
+	.q_rx_stop = &qed_stop_rxq,
+	.q_tx_start = &qed_start_txq,
+	.q_tx_stop = &qed_stop_txq,
+	.filter_config = &qed_configure_filter,
+	.fastpath_stop = &qed_fastpath_stop,
+	.eth_cqe_completion = &qed_fp_cqe_completion,
 };
 
 const struct qed_eth_ops	*qed_get_eth_ops(u32 version)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index f2870d6..0e0a1d1 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -187,6 +187,8 @@ err0:
 int qed_fill_dev_info(struct qed_dev *cdev,
 		      struct qed_dev_info *dev_info)
 {
+	struct qed_ptt  *ptt;
+
 	memset(dev_info, 0, sizeof(struct qed_dev_info));
 
 	dev_info->num_hwfns = cdev->num_hwfns;
@@ -204,6 +206,14 @@ int qed_fill_dev_info(struct qed_dev *cdev,
 
 	qed_mcp_get_mfw_ver(cdev, &dev_info->mfw_rev);
 
+	ptt = qed_ptt_acquire(QED_LEADING_HWFN(cdev));
+	if (ptt) {
+		qed_mcp_get_flash_size(QED_LEADING_HWFN(cdev), ptt,
+				       &dev_info->flash_size);
+
+		qed_ptt_release(QED_LEADING_HWFN(cdev), ptt);
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 7e4fa07..bd68b9a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -548,6 +548,22 @@ int qed_mcp_drain(struct qed_hwfn	*p_hwfn,
 	return rc;
 }
 
+int qed_mcp_get_flash_size(struct qed_hwfn	*p_hwfn,
+			   struct qed_ptt	*p_ptt,
+			   u32			*p_flash_size)
+{
+	u32 flash_size;
+
+	flash_size	= qed_rd(p_hwfn, p_ptt, MCP_REG_NVM_CFG4);
+	flash_size	= (flash_size & MCP_REG_NVM_CFG4_FLASH_SIZE) >>
+		MCP_REG_NVM_CFG4_FLASH_SIZE_SHIFT;
+	flash_size = (1 << (flash_size + MCP_BYTES_PER_MBIT_SHIFT));
+
+	*p_flash_size = flash_size;
+
+	return 0;
+}
+
 int
 qed_mcp_send_drv_version(struct qed_hwfn		*p_hwfn,
 			 struct qed_ptt			*p_ptt,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index 5f11720..160f499 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -89,6 +89,19 @@ int qed_mcp_drain(struct qed_hwfn	*p_hwfn,
 		  struct qed_ptt	*p_ptt);
 
 /**
+ * @brief Get the flash size value
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param p_flash_size  - flash size in bytes to be filled.
+ *
+ * @return int - 0 - operation was successul.
+ */
+int qed_mcp_get_flash_size(struct qed_hwfn     *p_hwfn,
+			   struct qed_ptt       *p_ptt,
+			   u32 *p_flash_size);
+
+/**
  * @brief Send driver version to MFW
  *
  * @param p_hwfn
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp.h b/drivers/net/ethernet/qlogic/qed/qed_sp.h
index 71c03d9..97dd499 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp.h
@@ -31,8 +31,35 @@ struct qed_spq_comp_cb {
 	void	*cookie;
 };
 
+/**
+ * @brief qed_eth_cqe_completion - handles the completion of a
+ *        ramrod on the cqe ring
+ *
+ * @param p_hwfn
+ * @param cqe
+ *
+ * @return int
+ */
+int qed_eth_cqe_completion(struct qed_hwfn		*p_hwfn,
+			   struct eth_slow_path_rx_cqe	*cqe);
+
+/**
+ *  @file
+ *
+ *  QED Slow-hwfn queue interface
+ */
+
 union ramrod_data {
 	struct pf_start_ramrod_data			pf_start;
+	struct rx_queue_start_ramrod_data		rx_queue_start;
+	struct rx_queue_update_ramrod_data		rx_queue_update;
+	struct rx_queue_stop_ramrod_data		rx_queue_stop;
+	struct tx_queue_start_ramrod_data		tx_queue_start;
+	struct tx_queue_stop_ramrod_data		tx_queue_stop;
+	struct vport_start_ramrod_data			vport_start;
+	struct vport_stop_ramrod_data			vport_stop;
+	struct vport_update_ramrod_data			vport_update;
+	struct vport_filter_update_ramrod_data		vport_filter_update;
 };
 
 #define EQ_MAX_CREDIT   0xffffffff
diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
index 2ca5b66..2627821 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
@@ -387,6 +387,35 @@ void qed_eq_free(struct qed_hwfn	*p_hwfn,
 }
 
 /***************************************************************************
+* CQE API - manipulate EQ functionality
+***************************************************************************/
+static int qed_cqe_completion(
+	struct qed_hwfn			*p_hwfn,
+	struct eth_slow_path_rx_cqe	*cqe,
+	enum protocol_type		protocol)
+{
+	/* @@@tmp - it's possible we'll eventually want to handle some
+	 * actual commands that can arrive here, but for now this is only
+	 * used to complete the ramrod using the echo value on the cqe
+	 */
+	return qed_spq_completion(p_hwfn, cqe->echo, 0, NULL);
+}
+
+int qed_eth_cqe_completion(struct qed_hwfn		*p_hwfn,
+			   struct eth_slow_path_rx_cqe	*cqe)
+{
+	int rc;
+
+	rc = qed_cqe_completion(p_hwfn, cqe, PROTOCOLID_ETH);
+	if (rc)
+		DP_NOTICE(p_hwfn,
+			  "Failed to handle RXQ CQE [cmd 0x%02x]\n",
+			  cqe->ramrod_cmd_id);
+
+	return rc;
+}
+
+/***************************************************************************
 * Slow hwfn Queue (spq)
 ***************************************************************************/
 void qed_spq_setup(struct qed_hwfn *p_hwfn)
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index fbd8700..aeb6855 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -24,12 +24,127 @@ struct qed_dev_eth_info {
 	u8	num_vlan_filters;
 };
 
+struct qed_update_vport_rss_params {
+	u16	rss_ind_table[128];
+	u32	rss_key[10];
+};
+
+struct qed_update_vport_params {
+	u8 vport_id;
+	u8 update_vport_active_flg;
+	u8 vport_active_flg;
+	u8 update_rss_flg;
+	struct qed_update_vport_rss_params rss_params;
+};
+
+struct qed_stop_rxq_params {
+	u8 rss_id;
+	u8 rx_queue_id;
+	u8 vport_id;
+	bool eq_completion_only;
+};
+
+struct qed_stop_txq_params {
+	u8 rss_id;
+	u8 tx_queue_id;
+};
+
+enum qed_filter_rx_mode_type {
+	QED_FILTER_RX_MODE_TYPE_REGULAR,
+	QED_FILTER_RX_MODE_TYPE_MULTI_PROMISC,
+	QED_FILTER_RX_MODE_TYPE_PROMISC,
+};
+
+enum qed_filter_xcast_params_type {
+	QED_FILTER_XCAST_TYPE_ADD,
+	QED_FILTER_XCAST_TYPE_DEL,
+	QED_FILTER_XCAST_TYPE_REPLACE,
+};
+
+struct qed_filter_ucast_params {
+	enum qed_filter_xcast_params_type type;
+	u8 vlan_valid;
+	u16 vlan;
+	u8 mac_valid;
+	unsigned char mac[ETH_ALEN];
+};
+
+struct qed_filter_mcast_params {
+	enum qed_filter_xcast_params_type type;
+	u8 num;
+	unsigned char mac[64][ETH_ALEN];
+};
+
+union qed_filter_type_params {
+	enum qed_filter_rx_mode_type accept_flags;
+	struct qed_filter_ucast_params ucast;
+	struct qed_filter_mcast_params mcast;
+};
+
+enum qed_filter_type {
+	QED_FILTER_TYPE_UCAST,
+	QED_FILTER_TYPE_MCAST,
+	QED_FILTER_TYPE_RX_MODE,
+	QED_MAX_FILTER_TYPES,
+};
+
+struct qed_filter_params {
+	enum qed_filter_type type;
+	union qed_filter_type_params filter;
+};
+
+struct qed_eth_cb_ops {
+	struct qed_common_cb_ops common;
+};
+
 struct qed_eth_ops {
 	const struct qed_common_ops *common;
 
 	int (*fill_dev_info)(struct qed_dev *cdev,
 			     struct qed_dev_eth_info *info);
 
+	int (*vport_start)(struct qed_dev *cdev,
+			   u8 vport_id, u16 mtu,
+			   u8 drop_ttl0_flg,
+			   u8 inner_vlan_removal_en_flg);
+
+	int (*vport_stop)(struct qed_dev *cdev,
+			  u8 vport_id);
+
+	int (*vport_update)(struct qed_dev *cdev,
+			    struct qed_update_vport_params *params);
+
+	int (*q_rx_start)(struct qed_dev *cdev,
+			  u8 rss_id, u8 rx_queue_id,
+			  u8 vport_id, u16 sb,
+			  u8 sb_index, u16 bd_max_bytes,
+			  dma_addr_t bd_chain_phys_addr,
+			  dma_addr_t cqe_pbl_addr,
+			  u16 cqe_pbl_size,
+			  void __iomem **pp_prod);
+
+	int (*q_rx_stop)(struct qed_dev *cdev,
+			 struct qed_stop_rxq_params *params);
+
+	int (*q_tx_start)(struct qed_dev *cdev,
+			  u8 rss_id, u16 tx_queue_id,
+			  u8 vport_id, u16 sb,
+			  u8 sb_index,
+			  dma_addr_t pbl_addr,
+			  u16 pbl_size,
+			  void __iomem **pp_doorbell);
+
+	int (*q_tx_stop)(struct qed_dev *cdev,
+			 struct qed_stop_txq_params *params);
+
+	int (*filter_config)(struct qed_dev *cdev,
+			     struct qed_filter_params *params);
+
+	int (*fastpath_stop)(struct qed_dev *cdev);
+
+	int (*eth_cqe_completion)(struct qed_dev *cdev,
+				  u8 rss_id,
+				  struct eth_slow_path_rx_cqe *cqe);
 };
 
 const struct qed_eth_ops *qed_get_eth_ops(u32 version);
-- 
1.9.3
