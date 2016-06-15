From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] qed: Add Light L2 [ll2] infrastructure
Date: Wed, 15 Jun 2016 13:22:37 +0300
Message-ID: <1465986157-16186-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:41679 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751778AbcFOKWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 06:22:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The qed driver will allow support for several drivers other than
qede, and each of said protocol drivers will require some sort of
L2-like ability to send and receive traffic -
the common use-case would be for control traffic specific for the
protocol that needs to reach user/kernel tools, although other cases
exist as well [some of which are for internal use by firmware].

For that purpose we introduce the Light L2 qed interface - it will provide
a method for drivers other than qede to transmit and receive said packets
from the network. The 'light' in its name is due to its lack of
sophistication in classification and advanced features that exist in the
regular firmware used by qede.

A couple of points of interest:
  - Interface is SKB-based; I.e., protocol drivers would communicate
with qed based on SKBs [as opposed to 'opaque' buffers].

  - This isn't considered datapath, so we're not bothered by issues that
would normally trouble us in regular xmit/recieve [prints, locks, etc.].

  - This adds a new Kconfig option - CONFIG_QED_LL2 which would be
selected by non-qede protocol drivers. But as we currently don't have
any such upstream, qed_ll2.c would not compile on any setup. So it was
added as a selectable user-option, a state that will change on the
submission of the first non-qede protocol driver.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Please consider applying this to 'net-next'.

Thanks,
Yuval
---
 drivers/net/ethernet/qlogic/Kconfig            |    8 +
 drivers/net/ethernet/qlogic/qed/Makefile       |    1 +
 drivers/net/ethernet/qlogic/qed/qed.h          |    8 +
 drivers/net/ethernet/qlogic/qed/qed_cxt.c      |    2 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c      |  120 +-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h  |   20 +
 drivers/net/ethernet/qlogic/qed/qed_hsi.h      |  219 +++
 drivers/net/ethernet/qlogic/qed/qed_ll2.c      | 1696 ++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_ll2.h      |  289 ++++
 drivers/net/ethernet/qlogic/qed/qed_main.c     |   23 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |   22 +
 drivers/net/ethernet/qlogic/qed/qed_sp.h       |    4 +
 include/linux/qed/common_hsi.h                 |    2 +
 include/linux/qed/qed_if.h                     |    1 +
 include/linux/qed/qed_ll2_if.h                 |  140 ++
 15 files changed, 2552 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ll2.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ll2.h
 create mode 100644 include/linux/qed/qed_ll2_if.h

diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index 680d8c7..ebf1107 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -98,6 +98,14 @@ config QED
 	---help---
 	  This enables the support for ...
 
+config QED_LL2
+	bool "Qlogic QED Light L2 interface"
+	default n
+	depends on QED
+	---help---
+	This enables support for Light L2 interface which is required
+	by all qed protocol drivers other than qede.
+
 config QED_SRIOV
 	bool "QLogic QED 25/40/100Gb SR-IOV support"
 	depends on QED && PCI_IOV
diff --git a/drivers/net/ethernet/qlogic/qed/Makefile b/drivers/net/ethernet/qlogic/qed/Makefile
index d1f157e..02f4842 100644
--- a/drivers/net/ethernet/qlogic/qed/Makefile
+++ b/drivers/net/ethernet/qlogic/qed/Makefile
@@ -4,3 +4,4 @@ qed-y := qed_cxt.o qed_dev.o qed_hw.o qed_init_fw_funcs.o qed_init_ops.o \
 	 qed_int.o qed_main.o qed_mcp.o qed_sp_commands.o qed_spq.o qed_l2.o \
 	 qed_selftest.o qed_dcbx.o
 qed-$(CONFIG_QED_SRIOV) += qed_sriov.o qed_vf.o
+qed-$(CONFIG_QED_LL2) += qed_ll2.o
diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 9a63df1..e86f542 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -69,6 +69,7 @@ struct qed_sb_info;
 struct qed_sb_attn_info;
 struct qed_cxt_mngr;
 struct qed_sb_sp_info;
+struct qed_ll2_info;
 struct qed_mcp_info;
 
 struct qed_rt_data {
@@ -149,6 +150,7 @@ enum QED_RESOURCES {
 	QED_MAC,
 	QED_VLAN,
 	QED_ILT,
+	QED_LL2_QUEUE,
 	QED_MAX_RESC,
 };
 
@@ -357,6 +359,8 @@ struct qed_hwfn {
 	struct qed_sb_attn_info		*p_sb_attn;
 
 	/* Protocol related */
+	bool				using_ll2;
+	struct qed_ll2_info		*p_ll2_info;
 	struct qed_pf_params		pf_params;
 
 	bool b_rdma_enabled_in_prs;
@@ -542,6 +546,10 @@ struct qed_dev {
 	} protocol_ops;
 	void				*ops_cookie;
 
+#ifdef CONFIG_QED_LL2
+	struct qed_cb_ll2_info		*ll2;
+	u8				ll2_mac_address[ETH_ALEN];
+#endif
 	const struct firmware		*firmware;
 };
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index 1c35f37..01cf303 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -1860,6 +1860,8 @@ int qed_cxt_set_pf_params(struct qed_hwfn *p_hwfn)
 	/* Set the number of required CORE connections */
 	u32 core_cids = 1; /* SPQ */
 
+	if (p_hwfn->using_ll2)
+		core_cids += 4;
 	qed_cxt_set_proto_cid_count(p_hwfn, PROTOCOLID_CORE, core_cids, 0);
 
 	switch (p_hwfn->hw_info.personality) {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index e45cff4..f485958 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -29,6 +29,7 @@
 #include "qed_hw.h"
 #include "qed_init_ops.h"
 #include "qed_int.h"
+#include "qed_ll2.h"
 #include "qed_mcp.h"
 #include "qed_reg_addr.h"
 #include "qed_sp.h"
@@ -150,6 +151,9 @@ void qed_resc_free(struct qed_dev *cdev)
 		qed_eq_free(p_hwfn, p_hwfn->p_eq);
 		qed_consq_free(p_hwfn, p_hwfn->p_consq);
 		qed_int_free(p_hwfn);
+#ifdef CONFIG_QED_LL2
+		qed_ll2_free(p_hwfn, p_hwfn->p_ll2_info);
+#endif
 		qed_iov_free(p_hwfn);
 		qed_dmae_info_free(p_hwfn);
 		qed_dcbx_info_free(p_hwfn, p_hwfn->p_dcbx_info);
@@ -407,6 +411,9 @@ int qed_qm_reconf(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 
 int qed_resc_alloc(struct qed_dev *cdev)
 {
+#ifdef CONFIG_QED_LL2
+	struct qed_ll2_info *p_ll2_info;
+#endif
 	struct qed_consq *p_consq;
 	struct qed_eq *p_eq;
 	int i, rc = 0;
@@ -522,6 +529,15 @@ int qed_resc_alloc(struct qed_dev *cdev)
 			goto alloc_no_mem;
 		p_hwfn->p_consq = p_consq;
 
+#ifdef CONFIG_QED_LL2
+		if (p_hwfn->using_ll2) {
+			p_ll2_info = qed_ll2_alloc(p_hwfn);
+			if (!p_ll2_info)
+				goto alloc_no_mem;
+			p_hwfn->p_ll2_info = p_ll2_info;
+		}
+#endif
+
 		/* DMA info initialization */
 		rc = qed_dmae_info_alloc(p_hwfn);
 		if (rc) {
@@ -579,6 +595,10 @@ void qed_resc_setup(struct qed_dev *cdev)
 		qed_int_setup(p_hwfn, p_hwfn->p_main_ptt);
 
 		qed_iov_setup(p_hwfn, p_hwfn->p_main_ptt);
+#ifdef CONFIG_QED_LL2
+		if (p_hwfn->using_ll2)
+			qed_ll2_setup(p_hwfn, p_hwfn->p_ll2_info);
+#endif
 	}
 }
 
@@ -1372,6 +1392,7 @@ static int qed_hw_get_resc(struct qed_hwfn *p_hwfn)
 	resc_num[QED_VLAN] = (ETH_NUM_VLAN_FILTERS - 1 /*For vlan0*/) /
 			     num_funcs;
 	resc_num[QED_ILT] = PXP_NUM_ILT_RECORDS_BB / num_funcs;
+	resc_num[QED_LL2_QUEUE] = MAX_NUM_LL2_RX_QUEUES / num_funcs;
 
 	for (i = 0; i < QED_MAX_RESC; i++)
 		resc_start[i] = resc_num[i] * enabled_func_idx;
@@ -1395,7 +1416,8 @@ static int qed_hw_get_resc(struct qed_hwfn *p_hwfn)
 		   "RL = %d start = %d\n"
 		   "MAC = %d start = %d\n"
 		   "VLAN = %d start = %d\n"
-		   "ILT = %d start = %d\n",
+		   "ILT = %d start = %d\n"
+		   "LL2_QUEUE = %d start = %d\n",
 		   p_hwfn->hw_info.resc_num[QED_SB],
 		   p_hwfn->hw_info.resc_start[QED_SB],
 		   p_hwfn->hw_info.resc_num[QED_L2_QUEUE],
@@ -1411,7 +1433,9 @@ static int qed_hw_get_resc(struct qed_hwfn *p_hwfn)
 		   p_hwfn->hw_info.resc_num[QED_VLAN],
 		   p_hwfn->hw_info.resc_start[QED_VLAN],
 		   p_hwfn->hw_info.resc_num[QED_ILT],
-		   p_hwfn->hw_info.resc_start[QED_ILT]);
+		   p_hwfn->hw_info.resc_start[QED_ILT],
+		   RESC_NUM(p_hwfn, QED_LL2_QUEUE),
+		   RESC_START(p_hwfn, QED_LL2_QUEUE));
 
 	return 0;
 }
@@ -2222,6 +2246,98 @@ int qed_fw_rss_eng(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
+static void qed_llh_mac_to_filter(u32 *p_high, u32 *p_low,
+				  u8 *p_filter)
+{
+	*p_high = p_filter[1] | (p_filter[0] << 8);
+	*p_low = p_filter[5] | (p_filter[4] << 8) |
+		 (p_filter[3] << 16) | (p_filter[2] << 24);
+}
+
+int qed_llh_add_mac_filter(struct qed_hwfn *p_hwfn,
+			   struct qed_ptt *p_ptt, u8 *p_filter)
+{
+	u32 high = 0, low = 0, en;
+	int i;
+
+	if (!(IS_MF_SI(p_hwfn) || IS_MF_DEFAULT(p_hwfn)))
+		return 0;
+
+	qed_llh_mac_to_filter(&high, &low, p_filter);
+
+	/* Find a free entry and utilize it */
+	for (i = 0; i < NIG_REG_LLH_FUNC_FILTER_EN_SIZE; i++) {
+		en = qed_rd(p_hwfn, p_ptt,
+			    NIG_REG_LLH_FUNC_FILTER_EN + i * sizeof(u32));
+		if (en)
+			continue;
+		qed_wr(p_hwfn, p_ptt,
+		       NIG_REG_LLH_FUNC_FILTER_VALUE +
+		       2 * i * sizeof(u32), low);
+		qed_wr(p_hwfn, p_ptt,
+		       NIG_REG_LLH_FUNC_FILTER_VALUE +
+		       (2 * i + 1) * sizeof(u32), high);
+		qed_wr(p_hwfn, p_ptt,
+		       NIG_REG_LLH_FUNC_FILTER_MODE + i * sizeof(u32), 0);
+		qed_wr(p_hwfn, p_ptt,
+		       NIG_REG_LLH_FUNC_FILTER_PROTOCOL_TYPE +
+		       i * sizeof(u32), 0);
+		qed_wr(p_hwfn, p_ptt,
+		       NIG_REG_LLH_FUNC_FILTER_EN + i * sizeof(u32), 1);
+		break;
+	}
+	if (i >= NIG_REG_LLH_FUNC_FILTER_EN_SIZE) {
+		DP_NOTICE(p_hwfn,
+			  "Failed to find an empty LLH filter to utilize\n");
+		return -EINVAL;
+	}
+
+	DP_VERBOSE(p_hwfn, NETIF_MSG_HW,
+		   "MAC: %pM is added at %d\n",
+		   p_filter, i);
+
+	return 0;
+}
+
+void qed_llh_remove_mac_filter(struct qed_hwfn *p_hwfn,
+			       struct qed_ptt *p_ptt, u8 *p_filter)
+{
+	u32 high = 0, low = 0;
+	int i;
+
+	if (!(IS_MF_SI(p_hwfn) || IS_MF_DEFAULT(p_hwfn)))
+		return;
+
+	qed_llh_mac_to_filter(&high, &low, p_filter);
+
+	/* Find the entry and clean it */
+	for (i = 0; i < NIG_REG_LLH_FUNC_FILTER_EN_SIZE; i++) {
+		if (qed_rd(p_hwfn, p_ptt,
+			   NIG_REG_LLH_FUNC_FILTER_VALUE +
+			   2 * i * sizeof(u32)) != low)
+			continue;
+		if (qed_rd(p_hwfn, p_ptt,
+			   NIG_REG_LLH_FUNC_FILTER_VALUE +
+			   (2 * i + 1) * sizeof(u32)) != high)
+			continue;
+
+		qed_wr(p_hwfn, p_ptt,
+		       NIG_REG_LLH_FUNC_FILTER_EN + i * sizeof(u32), 0);
+		qed_wr(p_hwfn, p_ptt,
+		       NIG_REG_LLH_FUNC_FILTER_VALUE + 2 * i * sizeof(u32), 0);
+		qed_wr(p_hwfn, p_ptt,
+		       NIG_REG_LLH_FUNC_FILTER_VALUE +
+		       (2 * i + 1) * sizeof(u32), 0);
+
+		DP_VERBOSE(p_hwfn, NETIF_MSG_HW,
+			   "MAC: %pM is removed from %d\n",
+			   p_filter, i);
+		break;
+	}
+	if (i >= NIG_REG_LLH_FUNC_FILTER_EN_SIZE)
+		DP_NOTICE(p_hwfn, "Tried to remove a non-configured filter\n");
+}
+
 /* Calculate final WFQ values for all vports and configure them.
  * After this configuration each vport will have
  * approx min rate =  min_pf_rate * (vport_wfq / QED_WFQ_UNIT)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
index f810ce4..a03c02b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
@@ -296,6 +296,26 @@ int qed_fw_rss_eng(struct qed_hwfn *p_hwfn,
 		   u8 *dst_id);
 
 /**
+ * @brief qed_llh_add_mac_filter - configures a MAC filter in llh
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param p_filter - MAC to add
+ */
+int qed_llh_add_mac_filter(struct qed_hwfn *p_hwfn,
+			   struct qed_ptt *p_ptt, u8 *p_filter);
+
+/**
+ * @brief qed_llh_remove_mac_filter - removes a MAC filtre from llh
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param p_filter - MAC to remove
+ */
+void qed_llh_remove_mac_filter(struct qed_hwfn *p_hwfn,
+			       struct qed_ptt *p_ptt, u8 *p_filter);
+
+/**
  * *@brief Cleanup of previous driver remains prior to load
  *
  * @param p_hwfn
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 5927840..823182d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -536,6 +536,212 @@ struct core_conn_context {
 	struct regpair ustorm_st_padding[2];
 };
 
+enum core_error_handle {
+	LL2_DROP_PACKET,
+	LL2_DO_NOTHING,
+	LL2_ASSERT,
+	MAX_CORE_ERROR_HANDLE
+};
+
+enum core_event_opcode {
+	CORE_EVENT_TX_QUEUE_START,
+	CORE_EVENT_TX_QUEUE_STOP,
+	CORE_EVENT_RX_QUEUE_START,
+	CORE_EVENT_RX_QUEUE_STOP,
+	MAX_CORE_EVENT_OPCODE
+};
+
+enum core_l4_pseudo_checksum_mode {
+	CORE_L4_PSEUDO_CSUM_CORRECT_LENGTH,
+	CORE_L4_PSEUDO_CSUM_ZERO_LENGTH,
+	MAX_CORE_L4_PSEUDO_CHECKSUM_MODE
+};
+
+struct core_ll2_port_stats {
+	struct regpair gsi_invalid_hdr;
+	struct regpair gsi_invalid_pkt_length;
+	struct regpair gsi_unsupported_pkt_typ;
+	struct regpair gsi_crcchksm_error;
+};
+
+struct core_ll2_pstorm_per_queue_stat {
+	struct regpair sent_ucast_bytes;
+	struct regpair sent_mcast_bytes;
+	struct regpair sent_bcast_bytes;
+	struct regpair sent_ucast_pkts;
+	struct regpair sent_mcast_pkts;
+	struct regpair sent_bcast_pkts;
+};
+
+struct core_ll2_rx_prod {
+	__le16 bd_prod;
+	__le16 cqe_prod;
+	__le32 reserved;
+};
+
+struct core_ll2_tstorm_per_queue_stat {
+	struct regpair packet_too_big_discard;
+	struct regpair no_buff_discard;
+};
+
+struct core_ll2_ustorm_per_queue_stat {
+	struct regpair rcv_ucast_bytes;
+	struct regpair rcv_mcast_bytes;
+	struct regpair rcv_bcast_bytes;
+	struct regpair rcv_ucast_pkts;
+	struct regpair rcv_mcast_pkts;
+	struct regpair rcv_bcast_pkts;
+};
+
+enum core_ramrod_cmd_id {
+	CORE_RAMROD_UNUSED,
+	CORE_RAMROD_RX_QUEUE_START,
+	CORE_RAMROD_TX_QUEUE_START,
+	CORE_RAMROD_RX_QUEUE_STOP,
+	CORE_RAMROD_TX_QUEUE_STOP,
+	MAX_CORE_RAMROD_CMD_ID
+};
+
+struct core_rx_action_on_error {
+	u8 error_type;
+#define CORE_RX_ACTION_ON_ERROR_PACKET_TOO_BIG_MASK	0x3
+#define CORE_RX_ACTION_ON_ERROR_PACKET_TOO_BIG_SHIFT	0
+#define CORE_RX_ACTION_ON_ERROR_NO_BUFF_MASK		0x3
+#define CORE_RX_ACTION_ON_ERROR_NO_BUFF_SHIFT		2
+#define CORE_RX_ACTION_ON_ERROR_RESERVED_MASK		0xF
+#define CORE_RX_ACTION_ON_ERROR_RESERVED_SHIFT		4
+};
+
+struct core_rx_bd {
+	struct regpair addr;
+	__le16 reserved[4];
+};
+
+struct core_rx_bd_with_buff_len {
+	struct regpair addr;
+	__le16 buff_length;
+	__le16 reserved[3];
+};
+
+union core_rx_bd_union {
+	struct core_rx_bd rx_bd;
+	struct core_rx_bd_with_buff_len rx_bd_with_len;
+};
+
+struct core_rx_cqe_opaque_data {
+	__le32 data[2];
+};
+
+enum core_rx_cqe_type {
+	CORE_RX_CQE_ILLIGAL_TYPE,
+	CORE_RX_CQE_TYPE_REGULAR,
+	CORE_RX_CQE_TYPE_GSI_OFFLOAD,
+	CORE_RX_CQE_TYPE_SLOW_PATH,
+	MAX_CORE_RX_CQE_TYPE
+};
+
+struct core_rx_fast_path_cqe {
+	u8 type;
+	u8 placement_offset;
+	struct parsing_and_err_flags parse_flags;
+	__le16 packet_length;
+	__le16 vlan;
+	struct core_rx_cqe_opaque_data opaque_data;
+	__le32 reserved[4];
+};
+
+struct core_rx_slow_path_cqe {
+	u8 type;
+	u8 ramrod_cmd_id;
+	__le16 echo;
+	__le32 reserved1[7];
+};
+
+union core_rx_cqe_union {
+	struct core_rx_fast_path_cqe rx_cqe_fp;
+	struct core_rx_slow_path_cqe rx_cqe_sp;
+};
+
+struct core_rx_start_ramrod_data {
+	struct regpair bd_base;
+	struct regpair cqe_pbl_addr;
+	__le16 mtu;
+	__le16 sb_id;
+	u8 sb_index;
+	u8 complete_cqe_flg;
+	u8 complete_event_flg;
+	u8 drop_ttl0_flg;
+	__le16 num_of_pbl_pages;
+	u8 inner_vlan_removal_en;
+	u8 queue_id;
+	u8 main_func_queue;
+	u8 mf_si_bcast_accept_all;
+	u8 mf_si_mcast_accept_all;
+	struct core_rx_action_on_error action_on_error;
+	u8 reserved[8];
+};
+
+struct core_rx_stop_ramrod_data {
+	u8 complete_cqe_flg;
+	u8 complete_event_flg;
+	u8 queue_id;
+	u8 reserved1;
+	__le16 reserved2[2];
+};
+
+struct core_tx_bd_flags {
+	u8 as_bitfield;
+#define CORE_TX_BD_FLAGS_FORCE_VLAN_MODE_MASK		0x1
+#define CORE_TX_BD_FLAGS_FORCE_VLAN_MODE_SHIFT		0
+#define CORE_TX_BD_FLAGS_VLAN_INSERTION_MASK		0x1
+#define CORE_TX_BD_FLAGS_VLAN_INSERTION_SHIFT		1
+#define CORE_TX_BD_FLAGS_START_BD_MASK			0x1
+#define CORE_TX_BD_FLAGS_START_BD_SHIFT			2
+#define CORE_TX_BD_FLAGS_IP_CSUM_MASK			0x1
+#define CORE_TX_BD_FLAGS_IP_CSUM_SHIFT			3
+#define CORE_TX_BD_FLAGS_L4_CSUM_MASK			0x1
+#define CORE_TX_BD_FLAGS_L4_CSUM_SHIFT			4
+#define CORE_TX_BD_FLAGS_IPV6_EXT_MASK			0x1
+#define CORE_TX_BD_FLAGS_IPV6_EXT_SHIFT			5
+#define CORE_TX_BD_FLAGS_L4_PROTOCOL_MASK		0x1
+#define CORE_TX_BD_FLAGS_L4_PROTOCOL_SHIFT		6
+#define CORE_TX_BD_FLAGS_L4_PSEUDO_CSUM_MODE_MASK	0x1
+#define CORE_TX_BD_FLAGS_L4_PSEUDO_CSUM_MODE_SHIFT	7
+};
+
+struct core_tx_bd {
+	struct regpair addr;
+	__le16 nbytes;
+	__le16 vlan;
+	u8 nbds;
+	struct core_tx_bd_flags bd_flags;
+	__le16 l4_hdr_offset_w;
+};
+
+enum core_tx_dest {
+	CORE_TX_DEST_NW,
+	CORE_TX_DEST_LB,
+	MAX_CORE_TX_DEST
+};
+
+struct core_tx_start_ramrod_data {
+	struct regpair pbl_base_addr;
+	__le16 mtu;
+	__le16 sb_id;
+	u8 sb_index;
+	u8 tx_dest;
+	u8 stats_en;
+	u8 stats_id;
+	__le16 pbl_size;
+	__le16 qm_pq_id;
+	u8 conn_type;
+	u8 resrved[3];
+};
+
+struct core_tx_stop_ramrod_data {
+	__le32 reserved0[2];
+};
+
 struct eth_mstorm_per_pf_stat {
 	struct regpair gre_discard_pkts;
 	struct regpair vxlan_discard_pkts;
@@ -2153,6 +2359,19 @@ void qed_set_geneve_enable(struct qed_hwfn *p_hwfn,
 #define	USTORM_COMMON_QUEUE_CONS_OFFSET(queue_zone_id) \
 	(IRO[7].base + ((queue_zone_id) * IRO[7].m1))
 #define	USTORM_COMMON_QUEUE_CONS_SIZE			(IRO[7].size)
+#define TSTORM_LL2_RX_PRODS_OFFSET(core_rx_queue_id) \
+	(IRO[14].base + ((core_rx_queue_id) * IRO[14].m1))
+#define TSTORM_LL2_RX_PRODS_SIZE			(IRO[14].size)
+#define CORE_LL2_TSTORM_PER_QUEUE_STAT_OFFSET(core_rx_queue_id) \
+	(IRO[15].base +	((core_rx_queue_id) * IRO[15].m1))
+#define CORE_LL2_TSTORM_PER_QUEUE_STAT_SIZE		(IRO[15].size)
+#define CORE_LL2_USTORM_PER_QUEUE_STAT_OFFSET(core_rx_queue_id) \
+	(IRO[16].base + ((core_rx_queue_id) * IRO[16].m1))
+#define CORE_LL2_USTORM_PER_QUEUE_STAT_SIZE		(IRO[16].size)
+/* Pstorm LiteL2 queue statistics */
+#define CORE_LL2_PSTORM_PER_QUEUE_STAT_OFFSET(core_tx_stats_id) \
+	(IRO[17].base + ((core_tx_stats_id) * IRO[17].m1))
+#define CORE_LL2_PSTORM_PER_QUEUE_STAT_SIZE		(IRO[17].size)
 #define	MSTORM_QUEUE_STAT_OFFSET(stat_counter_id) \
 	(IRO[18].base + ((stat_counter_id) * IRO[18].m1))
 #define	MSTORM_QUEUE_STAT_SIZE				(IRO[18].size)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
new file mode 100644
index 0000000..72687c7
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -0,0 +1,1696 @@
+/* QLogic qed NIC Driver
+ *
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/types.h>
+#include <asm/byteorder.h>
+#include <linux/dma-mapping.h>
+#include <linux/if_vlan.h>
+#include <linux/kernel.h>
+#include <linux/pci.h>
+#include <linux/slab.h>
+#include <linux/stddef.h>
+#include <linux/version.h>
+#include <linux/workqueue.h>
+#include <net/ipv6.h>
+#include <linux/bitops.h>
+#include <linux/delay.h>
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/io.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/spinlock.h>
+#include <linux/string.h>
+#include <linux/qed/qed_ll2_if.h>
+#include "qed.h"
+#include "qed_cxt.h"
+#include "qed_dev_api.h"
+#include "qed_hsi.h"
+#include "qed_hw.h"
+#include "qed_int.h"
+#include "qed_ll2.h"
+#include "qed_mcp.h"
+#include "qed_reg_addr.h"
+#include "qed_sp.h"
+
+#define QED_LL2_RX_REGISTERED(ll2)	((ll2)->rx_queue.b_cb_registred)
+#define QED_LL2_TX_REGISTERED(ll2)	((ll2)->tx_queue.b_cb_registred)
+
+#define QED_LL2_TX_SIZE (256)
+#define QED_LL2_RX_SIZE (4096)
+
+struct qed_cb_ll2_info {
+	int rx_cnt;
+	u32 rx_size;
+	u8 handle;
+	bool frags_mapped;
+
+	/* Lock protecting LL2 buffer lists in sleepless context */
+	spinlock_t lock;
+	struct list_head list;
+
+	const struct qed_ll2_cb_ops *cbs;
+	void *cb_cookie;
+};
+
+struct qed_ll2_buffer {
+	struct list_head list;
+	void *data;
+	dma_addr_t phys_addr;
+};
+
+static void qed_ll2b_complete_tx_packet(struct qed_hwfn *p_hwfn,
+					u8 connection_handle,
+					void *cookie,
+					dma_addr_t first_frag_addr,
+					bool b_last_fragment,
+					bool b_last_packet)
+{
+	struct qed_dev *cdev = p_hwfn->cdev;
+	struct sk_buff *skb = cookie;
+
+	/* All we need to do is release the mapping */
+	dma_unmap_single(&p_hwfn->cdev->pdev->dev, first_frag_addr,
+			 skb_headlen(skb), DMA_TO_DEVICE);
+
+	if (cdev->ll2->cbs && cdev->ll2->cbs->tx_cb)
+		cdev->ll2->cbs->tx_cb(cdev->ll2->cb_cookie, skb,
+				      b_last_fragment);
+
+	if (cdev->ll2->frags_mapped)
+		/* Case where mapped frags were received, need to
+		 * free skb with nr_frags marked as 0
+		 */
+		skb_shinfo(skb)->nr_frags = 0;
+
+	dev_kfree_skb_any(skb);
+}
+
+static int qed_ll2_alloc_buffer(struct qed_dev *cdev,
+				u8 **data, dma_addr_t *phys_addr)
+{
+	*data = kmalloc(cdev->ll2->rx_size, GFP_ATOMIC);
+	if (!(*data)) {
+		DP_INFO(cdev, "Failed to allocate LL2 buffer data\n");
+		return -ENOMEM;
+	}
+
+	*phys_addr = dma_map_single(&cdev->pdev->dev,
+				    ((*data) + NET_SKB_PAD),
+				    cdev->ll2->rx_size, DMA_FROM_DEVICE);
+	if (dma_mapping_error(&cdev->pdev->dev, *phys_addr)) {
+		DP_INFO(cdev, "Failed to map LL2 buffer data\n");
+		kfree((*data));
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static int qed_ll2_dealloc_buffer(struct qed_dev *cdev,
+				 struct qed_ll2_buffer *buffer)
+{
+	spin_lock_bh(&cdev->ll2->lock);
+
+	dma_unmap_single(&cdev->pdev->dev, buffer->phys_addr,
+			 cdev->ll2->rx_size, DMA_FROM_DEVICE);
+	kfree(buffer->data);
+	list_del(&buffer->list);
+
+	cdev->ll2->rx_cnt--;
+	if (!cdev->ll2->rx_cnt)
+		DP_INFO(cdev, "All LL2 entries were removed\n");
+
+	spin_unlock_bh(&cdev->ll2->lock);
+
+	return 0;
+}
+
+static void qed_ll2_kill_buffers(struct qed_dev *cdev)
+{
+	struct qed_ll2_buffer *buffer, *tmp_buffer;
+
+	list_for_each_entry_safe(buffer, tmp_buffer, &cdev->ll2->list, list)
+		qed_ll2_dealloc_buffer(cdev, buffer);
+}
+
+void qed_ll2b_complete_rx_packet(struct qed_hwfn *p_hwfn,
+				 u8 connection_handle,
+				 struct qed_ll2_rx_packet *p_pkt,
+				 struct core_rx_fast_path_cqe *p_cqe,
+				 bool b_last_packet)
+{
+	u16 packet_length = le16_to_cpu(p_cqe->packet_length);
+	struct qed_ll2_buffer *buffer = p_pkt->cookie;
+	struct qed_dev *cdev = p_hwfn->cdev;
+	u16 vlan = le16_to_cpu(p_cqe->vlan);
+	u32 opaque_data_0, opaque_data_1;
+	u8 pad = p_cqe->placement_offset;
+	dma_addr_t new_phys_addr;
+	struct sk_buff *skb;
+	bool reuse = false;
+	int rc = -EINVAL;
+	u8 *new_data;
+
+	opaque_data_0 = le32_to_cpu(p_cqe->opaque_data.data[0]);
+	opaque_data_1 = le32_to_cpu(p_cqe->opaque_data.data[1]);
+
+	DP_VERBOSE(p_hwfn,
+		   (NETIF_MSG_RX_STATUS | QED_MSG_STORAGE | NETIF_MSG_PKTDATA),
+		   "Got an LL2 Rx completion: [Buffer at phys 0x%llx, offset 0x%02x] Length 0x%04x Parse_flags 0x%04x vlan 0x%04x Opaque data [0x%08x:0x%08x]\n",
+		   (u64)p_pkt->rx_buf_addr, pad, packet_length,
+		   le16_to_cpu(p_cqe->parse_flags.flags), vlan,
+		   opaque_data_0, opaque_data_1);
+
+	if ((cdev->dp_module & NETIF_MSG_PKTDATA) && buffer->data) {
+		print_hex_dump(KERN_INFO, "",
+			       DUMP_PREFIX_OFFSET, 16, 1,
+			       buffer->data, packet_length, false);
+	}
+
+	/* Determine if data is valid */
+	if (packet_length < ETH_HLEN)
+		reuse = true;
+
+	/* Allocate a replacement for buffer; Reuse upon failure */
+	if (!reuse)
+		rc = qed_ll2_alloc_buffer(p_hwfn->cdev, &new_data,
+					  &new_phys_addr);
+
+	/* If need to reuse or there's no replacement buffer, repost this */
+	if (rc)
+		goto out_post;
+
+	skb = build_skb(buffer->data, 0);
+	if (!skb) {
+		rc = -ENOMEM;
+		goto out_post;
+	}
+
+	pad += NET_SKB_PAD;
+	skb_reserve(skb, pad);
+	skb_put(skb, packet_length);
+	skb_checksum_none_assert(skb);
+
+	/* Get parital ethernet information instead of eth_type_trans(),
+	 * Since we don't have an associated net_device.
+	 */
+	skb_reset_mac_header(skb);
+	skb->protocol = eth_hdr(skb)->h_proto;
+
+	/* Pass SKB onward */
+	if (cdev->ll2->cbs && cdev->ll2->cbs->rx_cb) {
+		if (vlan)
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan);
+		cdev->ll2->cbs->rx_cb(cdev->ll2->cb_cookie, skb,
+				      opaque_data_0, opaque_data_1);
+	}
+
+	/* Update Buffer information and update FW producer */
+	buffer->data = new_data;
+	buffer->phys_addr = new_phys_addr;
+
+out_post:
+	rc = qed_ll2_post_rx_buffer(QED_LEADING_HWFN(cdev), cdev->ll2->handle,
+				    buffer->phys_addr, 0,  buffer, 1);
+
+	if (rc)
+		qed_ll2_dealloc_buffer(cdev, buffer);
+}
+
+static struct qed_ll2_info *__qed_ll2_handle_sanity(struct qed_hwfn *p_hwfn,
+						    u8 connection_handle,
+						    bool b_lock,
+						    bool b_only_active)
+{
+	struct qed_ll2_info *p_ll2_conn, *p_ret = NULL;
+
+	if (connection_handle >= QED_MAX_NUM_OF_LL2_CONNECTIONS)
+		return NULL;
+
+	if (!p_hwfn->p_ll2_info)
+		return NULL;
+
+	p_ll2_conn = &p_hwfn->p_ll2_info[connection_handle];
+
+	if (b_only_active) {
+		if (b_lock)
+			mutex_lock(&p_ll2_conn->mutex);
+		if (p_ll2_conn->b_active)
+			p_ret = p_ll2_conn;
+		if (b_lock)
+			mutex_unlock(&p_ll2_conn->mutex);
+	} else {
+		p_ret = p_ll2_conn;
+	}
+
+	return p_ret;
+}
+
+static struct qed_ll2_info *qed_ll2_handle_sanity(struct qed_hwfn *p_hwfn,
+						  u8 connection_handle)
+{
+	return __qed_ll2_handle_sanity(p_hwfn, connection_handle, false, true);
+}
+
+static struct qed_ll2_info *qed_ll2_handle_sanity_lock(struct qed_hwfn *p_hwfn,
+						       u8 connection_handle)
+{
+	return __qed_ll2_handle_sanity(p_hwfn, connection_handle, true, true);
+}
+
+static struct qed_ll2_info *qed_ll2_handle_sanity_inactive(struct qed_hwfn
+							   *p_hwfn,
+							   u8 connection_handle)
+{
+	return __qed_ll2_handle_sanity(p_hwfn, connection_handle, false, false);
+}
+
+static void qed_ll2_txq_flush(struct qed_hwfn *p_hwfn, u8 connection_handle)
+{
+	bool b_last_packet = false, b_last_frag = false;
+	struct qed_ll2_tx_packet *p_pkt = NULL;
+	struct qed_ll2_info *p_ll2_conn;
+	struct qed_ll2_tx_queue *p_tx;
+
+	p_ll2_conn = qed_ll2_handle_sanity_inactive(p_hwfn, connection_handle);
+	if (!p_ll2_conn)
+		return;
+
+	p_tx = &p_ll2_conn->tx_queue;
+
+	while (!list_empty(&p_tx->active_descq)) {
+		p_pkt = list_first_entry(&p_tx->active_descq,
+					 struct qed_ll2_tx_packet, list_entry);
+		if (!p_pkt)
+			break;
+
+		list_del(&p_pkt->list_entry);
+		b_last_packet = list_empty(&p_tx->active_descq);
+		list_add_tail(&p_pkt->list_entry, &p_tx->free_descq);
+		p_tx->cur_completing_packet = *p_pkt;
+		p_tx->cur_completing_bd_idx = 1;
+		b_last_frag = p_tx->cur_completing_bd_idx == p_pkt->bd_used;
+
+		qed_ll2b_complete_tx_packet(p_hwfn, p_ll2_conn->my_id,
+					    p_pkt->cookie,
+					    p_pkt->bds_set[0].tx_frag,
+					    b_last_frag, b_last_packet);
+	}
+}
+
+static int qed_ll2_txq_completion(struct qed_hwfn *p_hwfn, void *p_cookie)
+{
+	struct qed_ll2_info *p_ll2_conn = p_cookie;
+	struct qed_ll2_tx_queue *p_tx = &p_ll2_conn->tx_queue;
+	u16 new_idx = 0, num_bds = 0, num_bds_in_packet = 0;
+	struct qed_ll2_tx_packet *p_pkt;
+	bool b_last_frag = false;
+	unsigned long flags;
+	int rc = -EINVAL;
+
+	spin_lock_irqsave(&p_tx->lock, flags);
+	if (p_tx->b_completing_packet) {
+		rc = -EBUSY;
+		goto out;
+	}
+
+	new_idx = le16_to_cpu(*p_tx->p_fw_cons);
+	num_bds = ((s16)new_idx - (s16)p_tx->bds_idx);
+	while (num_bds) {
+		if (list_empty(&p_tx->active_descq))
+			goto out;
+
+		p_pkt = list_first_entry(&p_tx->active_descq,
+					 struct qed_ll2_tx_packet, list_entry);
+		if (!p_pkt)
+			goto out;
+
+		p_tx->b_completing_packet = true;
+		p_tx->cur_completing_packet = *p_pkt;
+		num_bds_in_packet = p_pkt->bd_used;
+		list_del(&p_pkt->list_entry);
+
+		if (num_bds < num_bds_in_packet) {
+			DP_NOTICE(p_hwfn,
+				  "Rest of BDs does not cover whole packet\n");
+			goto out;
+		}
+
+		num_bds -= num_bds_in_packet;
+		p_tx->bds_idx += num_bds_in_packet;
+		while (num_bds_in_packet--)
+			qed_chain_consume(&p_tx->txq_chain);
+
+		p_tx->cur_completing_bd_idx = 1;
+		b_last_frag = p_tx->cur_completing_bd_idx == p_pkt->bd_used;
+		list_add_tail(&p_pkt->list_entry, &p_tx->free_descq);
+
+		spin_unlock_irqrestore(&p_tx->lock, flags);
+		qed_ll2b_complete_tx_packet(p_hwfn,
+					    p_ll2_conn->my_id,
+					    p_pkt->cookie,
+					    p_pkt->bds_set[0].tx_frag,
+					    b_last_frag, !num_bds);
+		spin_lock_irqsave(&p_tx->lock, flags);
+	}
+
+	p_tx->b_completing_packet = false;
+	rc = 0;
+out:
+	spin_unlock_irqrestore(&p_tx->lock, flags);
+	return rc;
+}
+
+static int qed_ll2_rxq_completion_reg(struct qed_hwfn *p_hwfn,
+				      struct qed_ll2_info *p_ll2_conn,
+				      union core_rx_cqe_union *p_cqe,
+				      unsigned long lock_flags,
+				      bool b_last_cqe)
+{
+	struct qed_ll2_rx_queue *p_rx = &p_ll2_conn->rx_queue;
+	struct qed_ll2_rx_packet *p_pkt = NULL;
+
+	if (!list_empty(&p_rx->active_descq))
+		p_pkt = list_first_entry(&p_rx->active_descq,
+					 struct qed_ll2_rx_packet, list_entry);
+	if (!p_pkt) {
+		DP_NOTICE(p_hwfn,
+			  "LL2 Rx completion but active_descq is empty\n");
+		return -EIO;
+	}
+	list_del(&p_pkt->list_entry);
+
+	if (qed_chain_consume(&p_rx->rxq_chain) != p_pkt->rxq_bd)
+		DP_NOTICE(p_hwfn,
+			  "Mismatch between active_descq and the LL2 Rx chain\n");
+	list_add_tail(&p_pkt->list_entry, &p_rx->free_descq);
+
+	spin_unlock_irqrestore(&p_rx->lock, lock_flags);
+	qed_ll2b_complete_rx_packet(p_hwfn, p_ll2_conn->my_id,
+				    p_pkt, &p_cqe->rx_cqe_fp, b_last_cqe);
+	spin_lock_irqsave(&p_rx->lock, lock_flags);
+
+	return 0;
+}
+
+static int qed_ll2_rxq_completion(struct qed_hwfn *p_hwfn, void *cookie)
+{
+	struct qed_ll2_info *p_ll2_conn = cookie;
+	struct qed_ll2_rx_queue *p_rx = &p_ll2_conn->rx_queue;
+	union core_rx_cqe_union *cqe = NULL;
+	u16 cq_new_idx = 0, cq_old_idx = 0;
+	unsigned long flags = 0;
+	int rc = 0;
+
+	spin_lock_irqsave(&p_rx->lock, flags);
+	cq_new_idx = le16_to_cpu(*p_rx->p_fw_cons);
+	cq_old_idx = qed_chain_get_cons_idx(&p_rx->rcq_chain);
+
+	while (cq_new_idx != cq_old_idx) {
+		bool b_last_cqe = (cq_new_idx == cq_old_idx);
+
+		cqe = qed_chain_consume(&p_rx->rcq_chain);
+		cq_old_idx = qed_chain_get_cons_idx(&p_rx->rcq_chain);
+
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_LL2,
+			   "LL2 [sw. cons %04x, fw. at %04x] - Got Packet of type %02x\n",
+			   cq_old_idx, cq_new_idx, cqe->rx_cqe_sp.type);
+
+		switch (cqe->rx_cqe_sp.type) {
+		case CORE_RX_CQE_TYPE_SLOW_PATH:
+			DP_NOTICE(p_hwfn, "LL2 - unexpected Rx CQE slowpath\n");
+			rc = -EINVAL;
+			break;
+		case CORE_RX_CQE_TYPE_REGULAR:
+			rc = qed_ll2_rxq_completion_reg(p_hwfn, p_ll2_conn,
+							cqe, flags, b_last_cqe);
+			break;
+		default:
+			rc = -EIO;
+		}
+	}
+
+	spin_unlock_irqrestore(&p_rx->lock, flags);
+	return rc;
+}
+
+void qed_ll2_rxq_flush(struct qed_hwfn *p_hwfn, u8 connection_handle)
+{
+	struct qed_ll2_info *p_ll2_conn = NULL;
+	struct qed_ll2_rx_packet *p_pkt = NULL;
+	struct qed_ll2_rx_queue *p_rx;
+
+	p_ll2_conn = qed_ll2_handle_sanity_inactive(p_hwfn, connection_handle);
+	if (!p_ll2_conn)
+		return;
+
+	p_rx = &p_ll2_conn->rx_queue;
+
+	while (!list_empty(&p_rx->active_descq)) {
+		dma_addr_t rx_buf_addr;
+		void *cookie;
+		bool b_last;
+
+		p_pkt = list_first_entry(&p_rx->active_descq,
+					 struct qed_ll2_rx_packet, list_entry);
+		if (!p_pkt)
+			break;
+
+		list_del(&p_pkt->list_entry);
+		list_add_tail(&p_pkt->list_entry, &p_rx->free_descq);
+
+		rx_buf_addr = p_pkt->rx_buf_addr;
+		cookie = p_pkt->cookie;
+
+		b_last = list_empty(&p_rx->active_descq);
+	}
+}
+
+static int qed_sp_ll2_rx_queue_start(struct qed_hwfn *p_hwfn,
+				     struct qed_ll2_info *p_ll2_conn,
+				     u8 action_on_error)
+{
+	enum qed_ll2_conn_type conn_type = p_ll2_conn->conn_type;
+	struct qed_ll2_rx_queue *p_rx = &p_ll2_conn->rx_queue;
+	struct core_rx_start_ramrod_data *p_ramrod = NULL;
+	struct qed_spq_entry *p_ent = NULL;
+	struct qed_sp_init_data init_data;
+	u16 cqe_pbl_size;
+	int rc = 0;
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = p_ll2_conn->cid;
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
+				 CORE_RAMROD_RX_QUEUE_START,
+				 PROTOCOLID_CORE, &init_data);
+	if (rc)
+		return rc;
+
+	p_ramrod = &p_ent->ramrod.core_rx_queue_start;
+
+	p_ramrod->sb_id = cpu_to_le16(qed_int_get_sp_sb_id(p_hwfn));
+	p_ramrod->sb_index = p_rx->rx_sb_index;
+	p_ramrod->complete_event_flg = 1;
+
+	p_ramrod->mtu = cpu_to_le16(p_ll2_conn->mtu);
+	DMA_REGPAIR_LE(p_ramrod->bd_base,
+		       p_rx->rxq_chain.p_phys_addr);
+	cqe_pbl_size = (u16)qed_chain_get_page_cnt(&p_rx->rxq_chain);
+	p_ramrod->num_of_pbl_pages = cpu_to_le16(cqe_pbl_size);
+	DMA_REGPAIR_LE(p_ramrod->cqe_pbl_addr,
+		       qed_chain_get_pbl_phys(&p_rx->rcq_chain));
+
+	p_ramrod->drop_ttl0_flg = p_ll2_conn->rx_drop_ttl0_flg;
+	p_ramrod->inner_vlan_removal_en = p_ll2_conn->rx_vlan_removal_en;
+	p_ramrod->queue_id = p_ll2_conn->queue_id;
+
+	if ((IS_MF_DEFAULT(p_hwfn) || IS_MF_SI(p_hwfn)) &&
+	    p_ramrod->main_func_queue && (conn_type != QED_LL2_TYPE_ROCE)) {
+		p_ramrod->mf_si_bcast_accept_all = 1;
+		p_ramrod->mf_si_mcast_accept_all = 1;
+	} else {
+		p_ramrod->mf_si_bcast_accept_all = 0;
+		p_ramrod->mf_si_mcast_accept_all = 0;
+	}
+
+	p_ramrod->action_on_error.error_type = action_on_error;
+	return qed_spq_post(p_hwfn, p_ent, NULL);
+}
+
+static int qed_sp_ll2_tx_queue_start(struct qed_hwfn *p_hwfn,
+				     struct qed_ll2_info *p_ll2_conn)
+{
+	enum qed_ll2_conn_type conn_type = p_ll2_conn->conn_type;
+	struct qed_ll2_tx_queue *p_tx = &p_ll2_conn->tx_queue;
+	struct core_tx_start_ramrod_data *p_ramrod = NULL;
+	struct qed_spq_entry *p_ent = NULL;
+	struct qed_sp_init_data init_data;
+	union qed_qm_pq_params pq_params;
+	u16 pq_id = 0, pbl_size;
+	int rc = -EINVAL;
+
+	if (!QED_LL2_TX_REGISTERED(p_ll2_conn))
+		return 0;
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = p_ll2_conn->cid;
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
+				 CORE_RAMROD_TX_QUEUE_START,
+				 PROTOCOLID_CORE, &init_data);
+	if (rc)
+		return rc;
+
+	p_ramrod = &p_ent->ramrod.core_tx_queue_start;
+
+	p_ramrod->sb_id = cpu_to_le16(qed_int_get_sp_sb_id(p_hwfn));
+	p_ramrod->sb_index = p_tx->tx_sb_index;
+	p_ramrod->mtu = cpu_to_le16(p_ll2_conn->mtu);
+	p_ramrod->tx_dest = p_ll2_conn->tx_dest;
+	p_ll2_conn->tx_stats_en = 1;
+	p_ramrod->stats_en = p_ll2_conn->tx_stats_en;
+	p_ramrod->stats_id = p_ll2_conn->tx_stats_id;
+
+	DMA_REGPAIR_LE(p_ramrod->pbl_base_addr,
+		       qed_chain_get_pbl_phys(&p_tx->txq_chain));
+	pbl_size = qed_chain_get_pbl_phys(&p_tx->txq_chain);
+	p_ramrod->pbl_size = cpu_to_le16(pbl_size);
+
+	memset(&pq_params, 0, sizeof(pq_params));
+	pq_params.core.tc = p_ll2_conn->tx_tc;
+	pq_id = qed_get_qm_pq(p_hwfn, PROTOCOLID_CORE, &pq_params);
+	p_ramrod->qm_pq_id = cpu_to_le16(pq_id);
+
+	switch (conn_type) {
+	case QED_LL2_TYPE_ISCSI:
+	case QED_LL2_TYPE_ISCSI_OOO:
+		p_ramrod->conn_type = PROTOCOLID_ISCSI;
+		break;
+	case QED_LL2_TYPE_ROCE:
+		p_ramrod->conn_type = PROTOCOLID_ROCE;
+		break;
+	default:
+		p_ramrod->conn_type = PROTOCOLID_ETH;
+		DP_NOTICE(p_hwfn, "Unknown connection type: %d\n", conn_type);
+	}
+
+	return qed_spq_post(p_hwfn, p_ent, NULL);
+}
+
+static int qed_sp_ll2_rx_queue_stop(struct qed_hwfn *p_hwfn,
+				    struct qed_ll2_info *p_ll2_conn)
+{
+	struct core_rx_stop_ramrod_data *p_ramrod = NULL;
+	struct qed_spq_entry *p_ent = NULL;
+	struct qed_sp_init_data init_data;
+	int rc = -EINVAL;
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = p_ll2_conn->cid;
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
+				 CORE_RAMROD_RX_QUEUE_STOP,
+				 PROTOCOLID_CORE, &init_data);
+	if (rc)
+		return rc;
+
+	p_ramrod = &p_ent->ramrod.core_rx_queue_stop;
+
+	p_ramrod->complete_event_flg = 1;
+	p_ramrod->queue_id = p_ll2_conn->queue_id;
+
+	return qed_spq_post(p_hwfn, p_ent, NULL);
+}
+
+static int qed_sp_ll2_tx_queue_stop(struct qed_hwfn *p_hwfn,
+				    struct qed_ll2_info *p_ll2_conn)
+{
+	struct qed_spq_entry *p_ent = NULL;
+	int rc = -EINVAL;
+	struct qed_sp_init_data init_data;
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = p_ll2_conn->cid;
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
+				 CORE_RAMROD_TX_QUEUE_STOP,
+				 PROTOCOLID_CORE, &init_data);
+	if (rc)
+		return rc;
+
+	return qed_spq_post(p_hwfn, p_ent, NULL);
+}
+
+static int
+qed_ll2_acquire_connection_rx(struct qed_hwfn *p_hwfn,
+			      struct qed_ll2_info *p_ll2_info, u16 rx_num_desc)
+{
+	struct qed_ll2_rx_packet *p_descq;
+	u32 capacity;
+	int rc = 0;
+
+	if (!rx_num_desc)
+		goto out;
+
+	rc = qed_chain_alloc(p_hwfn->cdev,
+			     QED_CHAIN_USE_TO_CONSUME_PRODUCE,
+			     QED_CHAIN_MODE_NEXT_PTR,
+			     QED_CHAIN_CNT_TYPE_U16,
+			     rx_num_desc,
+			     sizeof(struct core_rx_bd),
+			     &p_ll2_info->rx_queue.rxq_chain);
+	if (rc) {
+		DP_NOTICE(p_hwfn, "Failed to allocate ll2 rxq chain\n");
+		goto out;
+	}
+
+	capacity = qed_chain_get_capacity(&p_ll2_info->rx_queue.rxq_chain);
+	p_descq = kcalloc(capacity, sizeof(struct qed_ll2_rx_packet),
+			  GFP_KERNEL);
+	if (!p_descq) {
+		rc = -ENOMEM;
+		DP_NOTICE(p_hwfn, "Failed to allocate ll2 Rx desc\n");
+		goto out;
+	}
+	p_ll2_info->rx_queue.descq_array = p_descq;
+
+	rc = qed_chain_alloc(p_hwfn->cdev,
+			     QED_CHAIN_USE_TO_CONSUME_PRODUCE,
+			     QED_CHAIN_MODE_PBL,
+			     QED_CHAIN_CNT_TYPE_U16,
+			     rx_num_desc,
+			     sizeof(struct core_rx_fast_path_cqe),
+			     &p_ll2_info->rx_queue.rcq_chain);
+	if (rc) {
+		DP_NOTICE(p_hwfn, "Failed to allocate ll2 rcq chain\n");
+		goto out;
+	}
+
+	DP_VERBOSE(p_hwfn, QED_MSG_LL2,
+		   "Allocated LL2 Rxq [Type %08x] with 0x%08x buffers\n",
+		   p_ll2_info->conn_type, rx_num_desc);
+
+out:
+	return rc;
+}
+
+static int qed_ll2_acquire_connection_tx(struct qed_hwfn *p_hwfn,
+					 struct qed_ll2_info *p_ll2_info,
+					 u16 tx_num_desc)
+{
+	struct qed_ll2_tx_packet *p_descq;
+	u32 capacity;
+	int rc = 0;
+
+	if (!tx_num_desc)
+		goto out;
+
+	rc = qed_chain_alloc(p_hwfn->cdev,
+			     QED_CHAIN_USE_TO_CONSUME_PRODUCE,
+			     QED_CHAIN_MODE_PBL,
+			     QED_CHAIN_CNT_TYPE_U16,
+			     tx_num_desc,
+			     sizeof(struct core_tx_bd),
+			     &p_ll2_info->tx_queue.txq_chain);
+	if (rc)
+		goto out;
+
+	capacity = qed_chain_get_capacity(&p_ll2_info->tx_queue.txq_chain);
+	p_descq = kcalloc(capacity, sizeof(struct qed_ll2_tx_packet),
+			  GFP_KERNEL);
+	if (!p_descq) {
+		rc = -ENOMEM;
+		goto out;
+	}
+	p_ll2_info->tx_queue.descq_array = p_descq;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_LL2,
+		   "Allocated LL2 Txq [Type %08x] with 0x%08x buffers\n",
+		   p_ll2_info->conn_type, tx_num_desc);
+
+out:
+	if (rc)
+		DP_NOTICE(p_hwfn,
+			  "Can't allocate memory for Tx LL2 with 0x%08x buffers\n",
+			  tx_num_desc);
+	return rc;
+}
+
+int qed_ll2_acquire_connection(struct qed_hwfn *p_hwfn,
+			       struct qed_ll2_info *p_params,
+			       u16 rx_num_desc,
+			       u16 tx_num_desc,
+			       u8 *p_connection_handle)
+{
+	qed_int_comp_cb_t comp_rx_cb, comp_tx_cb;
+	struct qed_ll2_info *p_ll2_info = NULL;
+	int rc;
+	u8 i;
+
+	if (!p_connection_handle || !p_hwfn->p_ll2_info)
+		return -EINVAL;
+
+	/* Find a free connection to be used */
+	for (i = 0; (i < QED_MAX_NUM_OF_LL2_CONNECTIONS); i++) {
+		mutex_lock(&p_hwfn->p_ll2_info[i].mutex);
+		if (p_hwfn->p_ll2_info[i].b_active) {
+			mutex_unlock(&p_hwfn->p_ll2_info[i].mutex);
+			continue;
+		}
+
+		p_hwfn->p_ll2_info[i].b_active = true;
+		p_ll2_info = &p_hwfn->p_ll2_info[i];
+		mutex_unlock(&p_hwfn->p_ll2_info[i].mutex);
+		break;
+	}
+	if (!p_ll2_info)
+		return -EBUSY;
+
+	p_ll2_info->conn_type = p_params->conn_type;
+	p_ll2_info->mtu = p_params->mtu;
+	p_ll2_info->rx_drop_ttl0_flg = p_params->rx_drop_ttl0_flg;
+	p_ll2_info->rx_vlan_removal_en = p_params->rx_vlan_removal_en;
+	p_ll2_info->tx_tc = p_params->tx_tc;
+	p_ll2_info->tx_dest = p_params->tx_dest;
+	p_ll2_info->ai_err_packet_too_big = p_params->ai_err_packet_too_big;
+	p_ll2_info->ai_err_no_buf = p_params->ai_err_no_buf;
+
+	rc = qed_ll2_acquire_connection_rx(p_hwfn, p_ll2_info, rx_num_desc);
+	if (rc)
+		goto q_allocate_fail;
+
+	rc = qed_ll2_acquire_connection_tx(p_hwfn, p_ll2_info, tx_num_desc);
+	if (rc)
+		goto q_allocate_fail;
+
+	/* Register callbacks for the Rx/Tx queues */
+	comp_rx_cb = qed_ll2_rxq_completion;
+	comp_tx_cb = qed_ll2_txq_completion;
+
+	if (rx_num_desc) {
+		qed_int_register_cb(p_hwfn, comp_rx_cb,
+				    &p_hwfn->p_ll2_info[i],
+				    &p_ll2_info->rx_queue.rx_sb_index,
+				    &p_ll2_info->rx_queue.p_fw_cons);
+		p_ll2_info->rx_queue.b_cb_registred = true;
+	}
+
+	if (tx_num_desc) {
+		qed_int_register_cb(p_hwfn,
+				    comp_tx_cb,
+				    &p_hwfn->p_ll2_info[i],
+				    &p_ll2_info->tx_queue.tx_sb_index,
+				    &p_ll2_info->tx_queue.p_fw_cons);
+		p_ll2_info->tx_queue.b_cb_registred = true;
+	}
+
+	*p_connection_handle = i;
+	return rc;
+
+q_allocate_fail:
+	qed_ll2_release_connection(p_hwfn, i);
+	return -ENOMEM;
+}
+
+static int qed_ll2_establish_connection_rx(struct qed_hwfn *p_hwfn,
+					   struct qed_ll2_info *p_ll2_conn)
+{
+	u8 action_on_error = 0;
+
+	if (!QED_LL2_RX_REGISTERED(p_ll2_conn))
+		return 0;
+
+	DIRECT_REG_WR(p_ll2_conn->rx_queue.set_prod_addr, 0x0);
+
+	SET_FIELD(action_on_error,
+		  CORE_RX_ACTION_ON_ERROR_PACKET_TOO_BIG,
+		  p_ll2_conn->ai_err_packet_too_big);
+	SET_FIELD(action_on_error,
+		  CORE_RX_ACTION_ON_ERROR_NO_BUFF, p_ll2_conn->ai_err_no_buf);
+
+	return qed_sp_ll2_rx_queue_start(p_hwfn, p_ll2_conn, action_on_error);
+}
+
+int qed_ll2_establish_connection(struct qed_hwfn *p_hwfn, u8 connection_handle)
+{
+	struct qed_ll2_info *p_ll2_conn;
+	struct qed_ll2_rx_queue *p_rx;
+	struct qed_ll2_tx_queue *p_tx;
+	int rc = -EINVAL;
+	u32 i, capacity;
+	u8 qid;
+
+	p_ll2_conn = qed_ll2_handle_sanity_lock(p_hwfn, connection_handle);
+	if (!p_ll2_conn)
+		return -EINVAL;
+	p_rx = &p_ll2_conn->rx_queue;
+	p_tx = &p_ll2_conn->tx_queue;
+
+	qed_chain_reset(&p_rx->rxq_chain);
+	qed_chain_reset(&p_rx->rcq_chain);
+	INIT_LIST_HEAD(&p_rx->active_descq);
+	INIT_LIST_HEAD(&p_rx->free_descq);
+	INIT_LIST_HEAD(&p_rx->posting_descq);
+	spin_lock_init(&p_rx->lock);
+	capacity = qed_chain_get_capacity(&p_rx->rxq_chain);
+	for (i = 0; i < capacity; i++)
+		list_add_tail(&p_rx->descq_array[i].list_entry,
+			      &p_rx->free_descq);
+	*p_rx->p_fw_cons = 0;
+
+	qed_chain_reset(&p_tx->txq_chain);
+	INIT_LIST_HEAD(&p_tx->active_descq);
+	INIT_LIST_HEAD(&p_tx->free_descq);
+	INIT_LIST_HEAD(&p_tx->sending_descq);
+	spin_lock_init(&p_tx->lock);
+	capacity = qed_chain_get_capacity(&p_tx->txq_chain);
+	for (i = 0; i < capacity; i++)
+		list_add_tail(&p_tx->descq_array[i].list_entry,
+			      &p_tx->free_descq);
+	p_tx->cur_completing_bd_idx = 0;
+	p_tx->bds_idx = 0;
+	p_tx->b_completing_packet = false;
+	p_tx->cur_send_packet = NULL;
+	p_tx->cur_send_frag_num = 0;
+	p_tx->cur_completing_frag_num = 0;
+	*p_tx->p_fw_cons = 0;
+
+	qed_cxt_acquire_cid(p_hwfn, PROTOCOLID_CORE, &p_ll2_conn->cid);
+
+	qid = p_hwfn->hw_info.resc_start[QED_LL2_QUEUE] + connection_handle;
+	p_ll2_conn->queue_id = qid;
+	p_ll2_conn->tx_stats_id = qid;
+	p_rx->set_prod_addr = (u8 __iomem *)p_hwfn->regview +
+					    GTT_BAR0_MAP_REG_TSDM_RAM +
+					    TSTORM_LL2_RX_PRODS_OFFSET(qid);
+	p_tx->doorbell_addr = (u8 __iomem *)p_hwfn->doorbells +
+					    qed_db_addr(p_ll2_conn->cid,
+							DQ_DEMS_LEGACY);
+
+	rc = qed_ll2_establish_connection_rx(p_hwfn, p_ll2_conn);
+	if (rc)
+		return rc;
+
+	rc = qed_sp_ll2_tx_queue_start(p_hwfn, p_ll2_conn);
+	if (rc)
+		return rc;
+
+	if (p_hwfn->hw_info.personality != QED_PCI_ETH_ROCE)
+		qed_wr(p_hwfn, p_hwfn->p_main_ptt, PRS_REG_USE_LIGHT_L2, 1);
+
+	return rc;
+}
+
+static void qed_ll2_post_rx_buffer_notify_fw(struct qed_hwfn *p_hwfn,
+					     struct qed_ll2_rx_queue *p_rx,
+					     struct qed_ll2_rx_packet *p_curp)
+{
+	struct qed_ll2_rx_packet *p_posting_packet = NULL;
+	struct core_ll2_rx_prod rx_prod = { 0, 0, 0 };
+	bool b_notify_fw = false;
+	u16 bd_prod, cq_prod;
+
+	/* This handles the flushing of already posted buffers */
+	while (!list_empty(&p_rx->posting_descq)) {
+		p_posting_packet = list_first_entry(&p_rx->posting_descq,
+						    struct qed_ll2_rx_packet,
+						    list_entry);
+		list_del(&p_posting_packet->list_entry);
+		list_add_tail(&p_posting_packet->list_entry,
+			      &p_rx->active_descq);
+		b_notify_fw = true;
+	}
+
+	/* This handles the supplied packet [if there is one] */
+	if (p_curp) {
+		list_add_tail(&p_curp->list_entry, &p_rx->active_descq);
+		b_notify_fw = true;
+	}
+
+	if (!b_notify_fw)
+		return;
+
+	bd_prod = qed_chain_get_prod_idx(&p_rx->rxq_chain);
+	cq_prod = qed_chain_get_prod_idx(&p_rx->rcq_chain);
+	rx_prod.bd_prod = cpu_to_le16(bd_prod);
+	rx_prod.cqe_prod = cpu_to_le16(cq_prod);
+	DIRECT_REG_WR(p_rx->set_prod_addr, *((u32 *)&rx_prod));
+}
+
+int qed_ll2_post_rx_buffer(struct qed_hwfn *p_hwfn,
+			   u8 connection_handle,
+			   dma_addr_t addr,
+			   u16 buf_len, void *cookie, u8 notify_fw)
+{
+	struct core_rx_bd_with_buff_len *p_curb = NULL;
+	struct qed_ll2_rx_packet *p_curp = NULL;
+	struct qed_ll2_info *p_ll2_conn;
+	struct qed_ll2_rx_queue *p_rx;
+	unsigned long flags;
+	void *p_data;
+	int rc = 0;
+
+	p_ll2_conn = qed_ll2_handle_sanity(p_hwfn, connection_handle);
+	if (!p_ll2_conn)
+		return -EINVAL;
+	p_rx = &p_ll2_conn->rx_queue;
+
+	spin_lock_irqsave(&p_rx->lock, flags);
+	if (!list_empty(&p_rx->free_descq))
+		p_curp = list_first_entry(&p_rx->free_descq,
+					  struct qed_ll2_rx_packet, list_entry);
+	if (p_curp) {
+		if (qed_chain_get_elem_left(&p_rx->rxq_chain) &&
+		    qed_chain_get_elem_left(&p_rx->rcq_chain)) {
+			p_data = qed_chain_produce(&p_rx->rxq_chain);
+			p_curb = (struct core_rx_bd_with_buff_len *)p_data;
+			qed_chain_produce(&p_rx->rcq_chain);
+		}
+	}
+
+	/* If we're lacking entires, let's try to flush buffers to FW */
+	if (!p_curp || !p_curb) {
+		rc = -EBUSY;
+		p_curp = NULL;
+		goto out_notify;
+	}
+
+	/* We have an Rx packet we can fill */
+	DMA_REGPAIR_LE(p_curb->addr, addr);
+	p_curb->buff_length = cpu_to_le16(buf_len);
+	p_curp->rx_buf_addr = addr;
+	p_curp->cookie = cookie;
+	p_curp->rxq_bd = p_curb;
+	p_curp->buf_length = buf_len;
+	list_del(&p_curp->list_entry);
+
+	/* Check if we only want to enqueue this packet without informing FW */
+	if (!notify_fw) {
+		list_add_tail(&p_curp->list_entry, &p_rx->posting_descq);
+		goto out;
+	}
+
+out_notify:
+	qed_ll2_post_rx_buffer_notify_fw(p_hwfn, p_rx, p_curp);
+out:
+	spin_unlock_irqrestore(&p_rx->lock, flags);
+	return rc;
+}
+
+static void qed_ll2_prepare_tx_packet_set(struct qed_hwfn *p_hwfn,
+					  struct qed_ll2_tx_queue *p_tx,
+					  struct qed_ll2_tx_packet *p_curp,
+					  u8 num_of_bds,
+					  dma_addr_t first_frag,
+					  u16 first_frag_len, void *p_cookie,
+					  u8 notify_fw)
+{
+	list_del(&p_curp->list_entry);
+	p_curp->cookie = p_cookie;
+	p_curp->bd_used = num_of_bds;
+	p_curp->notify_fw = notify_fw;
+	p_tx->cur_send_packet = p_curp;
+	p_tx->cur_send_frag_num = 0;
+
+	p_curp->bds_set[p_tx->cur_send_frag_num].tx_frag = first_frag;
+	p_curp->bds_set[p_tx->cur_send_frag_num].frag_len = first_frag_len;
+	p_tx->cur_send_frag_num++;
+}
+
+static void qed_ll2_prepare_tx_packet_set_bd(struct qed_hwfn *p_hwfn,
+					     struct qed_ll2_info *p_ll2,
+					     struct qed_ll2_tx_packet *p_curp,
+					     u8 num_of_bds,
+					     u16 vlan,
+					     u8 bd_flags,
+					     u16 l4_hdr_offset_w,
+					     dma_addr_t first_frag,
+					     u16 first_frag_len)
+{
+	struct qed_chain *p_tx_chain = &p_ll2->tx_queue.txq_chain;
+	u16 prod_idx = qed_chain_get_prod_idx(p_tx_chain);
+	struct core_tx_bd *start_bd = NULL;
+	u16 frag_idx;
+
+	start_bd = (struct core_tx_bd *)qed_chain_produce(p_tx_chain);
+	start_bd->vlan = cpu_to_le16(vlan);
+	start_bd->l4_hdr_offset_w = cpu_to_le16(l4_hdr_offset_w);
+	start_bd->bd_flags.as_bitfield = bd_flags;
+	start_bd->bd_flags.as_bitfield |= CORE_TX_BD_FLAGS_START_BD_MASK <<
+	    CORE_TX_BD_FLAGS_START_BD_SHIFT;
+	start_bd->nbds = num_of_bds;
+	DMA_REGPAIR_LE(start_bd->addr, first_frag);
+	start_bd->nbytes = cpu_to_le16(first_frag_len);
+
+	DP_VERBOSE(p_hwfn,
+		   (NETIF_MSG_TX_QUEUED | QED_MSG_LL2),
+		   "LL2 [q 0x%02x cid 0x%08x type 0x%08x] Tx Producer at [0x%04x] - set with a %04x bytes %02x BDs buffer at %08x:%08x\n",
+		   p_ll2->queue_id,
+		   p_ll2->cid,
+		   p_ll2->conn_type,
+		   prod_idx,
+		   first_frag_len,
+		   num_of_bds,
+		   le32_to_cpu(start_bd->addr.hi),
+		   le32_to_cpu(start_bd->addr.lo));
+
+	if (p_ll2->tx_queue.cur_send_frag_num == num_of_bds)
+		return;
+
+	/* Need to provide the packet with additional BDs for frags */
+	for (frag_idx = p_ll2->tx_queue.cur_send_frag_num;
+	     frag_idx < num_of_bds; frag_idx++) {
+		struct core_tx_bd **p_bd = &p_curp->bds_set[frag_idx].txq_bd;
+
+		*p_bd = (struct core_tx_bd *)qed_chain_produce(p_tx_chain);
+		(*p_bd)->bd_flags.as_bitfield = 0;
+		(*p_bd)->l4_hdr_offset_w = 0;
+		(*p_bd)->nbds = 0;
+		p_curp->bds_set[frag_idx].tx_frag = 0;
+		p_curp->bds_set[frag_idx].frag_len = 0;
+	}
+}
+
+/* This should be called while the Txq spinlock is being held */
+static void qed_ll2_tx_packet_notify(struct qed_hwfn *p_hwfn,
+				     struct qed_ll2_info *p_ll2_conn)
+{
+	bool b_notify = p_ll2_conn->tx_queue.cur_send_packet->notify_fw;
+	struct qed_ll2_tx_queue *p_tx = &p_ll2_conn->tx_queue;
+	struct qed_ll2_tx_packet *p_pkt = NULL;
+	struct core_db_data db_msg = { 0, 0, 0 };
+	u16 bd_prod;
+
+	/* If there are missing BDs, don't do anything now */
+	if (p_ll2_conn->tx_queue.cur_send_frag_num !=
+	    p_ll2_conn->tx_queue.cur_send_packet->bd_used)
+		return;
+
+	/* Push the current packet to the list and clean after it */
+	list_add_tail(&p_ll2_conn->tx_queue.cur_send_packet->list_entry,
+		      &p_ll2_conn->tx_queue.sending_descq);
+	p_ll2_conn->tx_queue.cur_send_packet = NULL;
+	p_ll2_conn->tx_queue.cur_send_frag_num = 0;
+
+	/* Notify FW of packet only if requested to */
+	if (!b_notify)
+		return;
+
+	bd_prod = qed_chain_get_prod_idx(&p_ll2_conn->tx_queue.txq_chain);
+
+	while (!list_empty(&p_tx->sending_descq)) {
+		p_pkt = list_first_entry(&p_tx->sending_descq,
+					 struct qed_ll2_tx_packet, list_entry);
+		if (!p_pkt)
+			break;
+
+		list_del(&p_pkt->list_entry);
+		list_add_tail(&p_pkt->list_entry, &p_tx->active_descq);
+	}
+
+	SET_FIELD(db_msg.params, CORE_DB_DATA_DEST, DB_DEST_XCM);
+	SET_FIELD(db_msg.params, CORE_DB_DATA_AGG_CMD, DB_AGG_CMD_SET);
+	SET_FIELD(db_msg.params, CORE_DB_DATA_AGG_VAL_SEL,
+		  DQ_XCM_CORE_TX_BD_PROD_CMD);
+	db_msg.agg_flags = DQ_XCM_CORE_DQ_CF_CMD;
+	db_msg.spq_prod = cpu_to_le16(bd_prod);
+
+	/* Make sure the BDs data is updated before ringing the doorbell */
+	wmb();
+
+	DIRECT_REG_WR(p_tx->doorbell_addr, *((u32 *)&db_msg));
+
+	DP_VERBOSE(p_hwfn,
+		   (NETIF_MSG_TX_QUEUED | QED_MSG_LL2),
+		   "LL2 [q 0x%02x cid 0x%08x type 0x%08x] Doorbelled [producer 0x%04x]\n",
+		   p_ll2_conn->queue_id,
+		   p_ll2_conn->cid, p_ll2_conn->conn_type, db_msg.spq_prod);
+}
+
+int qed_ll2_prepare_tx_packet(struct qed_hwfn *p_hwfn,
+			      u8 connection_handle,
+			      u8 num_of_bds,
+			      u16 vlan,
+			      u8 bd_flags,
+			      u16 l4_hdr_offset_w,
+			      dma_addr_t first_frag,
+			      u16 first_frag_len, void *cookie, u8 notify_fw)
+{
+	struct qed_ll2_tx_packet *p_curp = NULL;
+	struct qed_ll2_info *p_ll2_conn = NULL;
+	struct qed_ll2_tx_queue *p_tx;
+	struct qed_chain *p_tx_chain;
+	unsigned long flags;
+	int rc = 0;
+
+	p_ll2_conn = qed_ll2_handle_sanity(p_hwfn, connection_handle);
+	if (!p_ll2_conn)
+		return -EINVAL;
+	p_tx = &p_ll2_conn->tx_queue;
+	p_tx_chain = &p_tx->txq_chain;
+
+	if (num_of_bds > CORE_LL2_TX_MAX_BDS_PER_PACKET)
+		return -EIO;
+
+	spin_lock_irqsave(&p_tx->lock, flags);
+	if (p_tx->cur_send_packet) {
+		rc = -EEXIST;
+		goto out;
+	}
+
+	/* Get entry, but only if we have tx elements for it */
+	if (!list_empty(&p_tx->free_descq))
+		p_curp = list_first_entry(&p_tx->free_descq,
+					  struct qed_ll2_tx_packet, list_entry);
+	if (p_curp && qed_chain_get_elem_left(p_tx_chain) < num_of_bds)
+		p_curp = NULL;
+
+	if (!p_curp) {
+		rc = -EBUSY;
+		goto out;
+	}
+
+	/* Prepare packet and BD, and perhaps send a doorbell to FW */
+	qed_ll2_prepare_tx_packet_set(p_hwfn, p_tx, p_curp,
+				      num_of_bds, first_frag,
+				      first_frag_len, cookie, notify_fw);
+	qed_ll2_prepare_tx_packet_set_bd(p_hwfn, p_ll2_conn, p_curp,
+					 num_of_bds, vlan, bd_flags,
+					 l4_hdr_offset_w,
+					 first_frag, first_frag_len);
+
+	qed_ll2_tx_packet_notify(p_hwfn, p_ll2_conn);
+
+out:
+	spin_unlock_irqrestore(&p_tx->lock, flags);
+	return rc;
+}
+
+int qed_ll2_set_fragment_of_tx_packet(struct qed_hwfn *p_hwfn,
+				      u8 connection_handle,
+				      dma_addr_t addr, u16 nbytes)
+{
+	struct qed_ll2_tx_packet *p_cur_send_packet = NULL;
+	struct qed_ll2_info *p_ll2_conn = NULL;
+	u16 cur_send_frag_num = 0;
+	struct core_tx_bd *p_bd;
+	unsigned long flags;
+
+	p_ll2_conn = qed_ll2_handle_sanity(p_hwfn, connection_handle);
+	if (!p_ll2_conn)
+		return -EINVAL;
+
+	if (!p_ll2_conn->tx_queue.cur_send_packet)
+		return -EINVAL;
+
+	p_cur_send_packet = p_ll2_conn->tx_queue.cur_send_packet;
+	cur_send_frag_num = p_ll2_conn->tx_queue.cur_send_frag_num;
+
+	if (cur_send_frag_num >= p_cur_send_packet->bd_used)
+		return -EINVAL;
+
+	/* Fill the BD information, and possibly notify FW */
+	p_bd = p_cur_send_packet->bds_set[cur_send_frag_num].txq_bd;
+	DMA_REGPAIR_LE(p_bd->addr, addr);
+	p_bd->nbytes = cpu_to_le16(nbytes);
+	p_cur_send_packet->bds_set[cur_send_frag_num].tx_frag = addr;
+	p_cur_send_packet->bds_set[cur_send_frag_num].frag_len = nbytes;
+
+	p_ll2_conn->tx_queue.cur_send_frag_num++;
+
+	spin_lock_irqsave(&p_ll2_conn->tx_queue.lock, flags);
+	qed_ll2_tx_packet_notify(p_hwfn, p_ll2_conn);
+	spin_unlock_irqrestore(&p_ll2_conn->tx_queue.lock, flags);
+
+	return 0;
+}
+
+int qed_ll2_terminate_connection(struct qed_hwfn *p_hwfn, u8 connection_handle)
+{
+	struct qed_ll2_info *p_ll2_conn = NULL;
+	int rc = -EINVAL;
+
+	p_ll2_conn = qed_ll2_handle_sanity_lock(p_hwfn, connection_handle);
+	if (!p_ll2_conn)
+		return -EINVAL;
+
+	/* Stop Tx & Rx of connection, if needed */
+	if (QED_LL2_TX_REGISTERED(p_ll2_conn)) {
+		rc = qed_sp_ll2_tx_queue_stop(p_hwfn, p_ll2_conn);
+		if (rc)
+			return rc;
+		qed_ll2_txq_flush(p_hwfn, connection_handle);
+	}
+
+	if (QED_LL2_RX_REGISTERED(p_ll2_conn)) {
+		rc = qed_sp_ll2_rx_queue_stop(p_hwfn, p_ll2_conn);
+		if (rc)
+			return rc;
+		qed_ll2_rxq_flush(p_hwfn, connection_handle);
+	}
+
+	return rc;
+}
+
+void qed_ll2_release_connection(struct qed_hwfn *p_hwfn, u8 connection_handle)
+{
+	struct qed_ll2_info *p_ll2_conn = NULL;
+
+	p_ll2_conn = qed_ll2_handle_sanity(p_hwfn, connection_handle);
+	if (!p_ll2_conn)
+		return;
+
+	if (QED_LL2_RX_REGISTERED(p_ll2_conn)) {
+		p_ll2_conn->rx_queue.b_cb_registred = false;
+		qed_int_unregister_cb(p_hwfn, p_ll2_conn->rx_queue.rx_sb_index);
+	}
+
+	if (QED_LL2_TX_REGISTERED(p_ll2_conn)) {
+		p_ll2_conn->tx_queue.b_cb_registred = false;
+		qed_int_unregister_cb(p_hwfn, p_ll2_conn->tx_queue.tx_sb_index);
+	}
+
+	kfree(p_ll2_conn->tx_queue.descq_array);
+	qed_chain_free(p_hwfn->cdev, &p_ll2_conn->tx_queue.txq_chain);
+
+	kfree(p_ll2_conn->rx_queue.descq_array);
+	qed_chain_free(p_hwfn->cdev, &p_ll2_conn->rx_queue.rxq_chain);
+	qed_chain_free(p_hwfn->cdev, &p_ll2_conn->rx_queue.rcq_chain);
+
+	qed_cxt_release_cid(p_hwfn, p_ll2_conn->cid);
+
+	mutex_lock(&p_ll2_conn->mutex);
+	p_ll2_conn->b_active = false;
+	mutex_unlock(&p_ll2_conn->mutex);
+}
+
+struct qed_ll2_info *qed_ll2_alloc(struct qed_hwfn *p_hwfn)
+{
+	struct qed_ll2_info *p_ll2_connections;
+	u8 i;
+
+	/* Allocate LL2's set struct */
+	p_ll2_connections = kcalloc(QED_MAX_NUM_OF_LL2_CONNECTIONS,
+				    sizeof(struct qed_ll2_info), GFP_KERNEL);
+	if (!p_ll2_connections) {
+		DP_NOTICE(p_hwfn, "Failed to allocate `struct qed_ll2'\n");
+		return NULL;
+	}
+
+	for (i = 0; i < QED_MAX_NUM_OF_LL2_CONNECTIONS; i++)
+		p_ll2_connections[i].my_id = i;
+
+	return p_ll2_connections;
+}
+
+void qed_ll2_setup(struct qed_hwfn *p_hwfn,
+		   struct qed_ll2_info *p_ll2_connections)
+{
+	int i;
+
+	for (i = 0; i < QED_MAX_NUM_OF_LL2_CONNECTIONS; i++)
+		mutex_init(&p_ll2_connections[i].mutex);
+}
+
+void qed_ll2_free(struct qed_hwfn *p_hwfn,
+		  struct qed_ll2_info *p_ll2_connections)
+{
+	kfree(p_ll2_connections);
+}
+
+static void _qed_ll2_get_tstats(struct qed_hwfn *p_hwfn,
+				struct qed_ptt *p_ptt,
+				struct qed_ll2_info *p_ll2_conn,
+				struct qed_ll2_stats *p_stats)
+{
+	struct core_ll2_tstorm_per_queue_stat tstats;
+	u8 qid = p_ll2_conn->queue_id;
+	u32 tstats_addr;
+
+	memset(&tstats, 0, sizeof(tstats));
+	tstats_addr = BAR0_MAP_REG_TSDM_RAM +
+		      CORE_LL2_TSTORM_PER_QUEUE_STAT_OFFSET(qid);
+	qed_memcpy_from(p_hwfn, p_ptt, &tstats, tstats_addr, sizeof(tstats));
+
+	p_stats->packet_too_big_discard =
+			HILO_64_REGPAIR(tstats.packet_too_big_discard);
+	p_stats->no_buff_discard = HILO_64_REGPAIR(tstats.no_buff_discard);
+}
+
+static void _qed_ll2_get_ustats(struct qed_hwfn *p_hwfn,
+				struct qed_ptt *p_ptt,
+				struct qed_ll2_info *p_ll2_conn,
+				struct qed_ll2_stats *p_stats)
+{
+	struct core_ll2_ustorm_per_queue_stat ustats;
+	u8 qid = p_ll2_conn->queue_id;
+	u32 ustats_addr;
+
+	memset(&ustats, 0, sizeof(ustats));
+	ustats_addr = BAR0_MAP_REG_USDM_RAM +
+		      CORE_LL2_USTORM_PER_QUEUE_STAT_OFFSET(qid);
+	qed_memcpy_from(p_hwfn, p_ptt, &ustats, ustats_addr, sizeof(ustats));
+
+	p_stats->rcv_ucast_bytes = HILO_64_REGPAIR(ustats.rcv_ucast_bytes);
+	p_stats->rcv_mcast_bytes = HILO_64_REGPAIR(ustats.rcv_mcast_bytes);
+	p_stats->rcv_bcast_bytes = HILO_64_REGPAIR(ustats.rcv_bcast_bytes);
+	p_stats->rcv_ucast_pkts = HILO_64_REGPAIR(ustats.rcv_ucast_pkts);
+	p_stats->rcv_mcast_pkts = HILO_64_REGPAIR(ustats.rcv_mcast_pkts);
+	p_stats->rcv_bcast_pkts = HILO_64_REGPAIR(ustats.rcv_bcast_pkts);
+}
+
+static void _qed_ll2_get_pstats(struct qed_hwfn *p_hwfn,
+				struct qed_ptt *p_ptt,
+				struct qed_ll2_info *p_ll2_conn,
+				struct qed_ll2_stats *p_stats)
+{
+	struct core_ll2_pstorm_per_queue_stat pstats;
+	u8 stats_id = p_ll2_conn->tx_stats_id;
+	u32 pstats_addr;
+
+	memset(&pstats, 0, sizeof(pstats));
+	pstats_addr = BAR0_MAP_REG_PSDM_RAM +
+		      CORE_LL2_PSTORM_PER_QUEUE_STAT_OFFSET(stats_id);
+	qed_memcpy_from(p_hwfn, p_ptt, &pstats, pstats_addr, sizeof(pstats));
+
+	p_stats->sent_ucast_bytes = HILO_64_REGPAIR(pstats.sent_ucast_bytes);
+	p_stats->sent_mcast_bytes = HILO_64_REGPAIR(pstats.sent_mcast_bytes);
+	p_stats->sent_bcast_bytes = HILO_64_REGPAIR(pstats.sent_bcast_bytes);
+	p_stats->sent_ucast_pkts = HILO_64_REGPAIR(pstats.sent_ucast_pkts);
+	p_stats->sent_mcast_pkts = HILO_64_REGPAIR(pstats.sent_mcast_pkts);
+	p_stats->sent_bcast_pkts = HILO_64_REGPAIR(pstats.sent_bcast_pkts);
+}
+
+int qed_ll2_get_stats(struct qed_hwfn *p_hwfn,
+		      u8 connection_handle, struct qed_ll2_stats *p_stats)
+{
+	struct qed_ll2_info *p_ll2_conn = NULL;
+	struct qed_ptt *p_ptt;
+
+	memset(p_stats, 0, sizeof(*p_stats));
+
+	if ((connection_handle >= QED_MAX_NUM_OF_LL2_CONNECTIONS) ||
+	    !p_hwfn->p_ll2_info)
+		return -EINVAL;
+
+	p_ll2_conn = &p_hwfn->p_ll2_info[connection_handle];
+
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt) {
+		DP_ERR(p_hwfn, "Failed to acquire ptt\n");
+		return -EINVAL;
+	}
+
+	_qed_ll2_get_tstats(p_hwfn, p_ptt, p_ll2_conn, p_stats);
+	_qed_ll2_get_ustats(p_hwfn, p_ptt, p_ll2_conn, p_stats);
+	if (p_ll2_conn->tx_stats_en)
+		_qed_ll2_get_pstats(p_hwfn, p_ptt, p_ll2_conn, p_stats);
+
+	qed_ptt_release(p_hwfn, p_ptt);
+	return 0;
+}
+
+static void qed_ll2_register_cb_ops(struct qed_dev *cdev,
+				    const struct qed_ll2_cb_ops *ops,
+				    void *cookie)
+{
+	cdev->ll2->cbs = ops;
+	cdev->ll2->cb_cookie = cookie;
+}
+
+static int qed_ll2_start(struct qed_dev *cdev, struct qed_ll2_params *params)
+{
+	struct qed_ll2_info ll2_info;
+	struct qed_ll2_buffer *buffer;
+	enum qed_ll2_conn_type conn_type;
+	struct qed_ptt *p_ptt;
+	int rc, i;
+
+	/* Initialize LL2 locks & lists */
+	INIT_LIST_HEAD(&cdev->ll2->list);
+	spin_lock_init(&cdev->ll2->lock);
+	cdev->ll2->rx_size = NET_SKB_PAD + ETH_HLEN +
+			     L1_CACHE_BYTES + params->mtu;
+	cdev->ll2->frags_mapped = params->frags_mapped;
+
+	/*Allocate memory for LL2 */
+	DP_INFO(cdev, "Allocating LL2 buffers of size %08x bytes\n",
+		cdev->ll2->rx_size);
+	for (i = 0; i < QED_LL2_RX_SIZE; i++) {
+		buffer = kzalloc(sizeof(*buffer), GFP_KERNEL);
+		if (!buffer) {
+			DP_INFO(cdev, "Failed to allocate LL2 buffers\n");
+			goto fail;
+		}
+
+		rc = qed_ll2_alloc_buffer(cdev, (u8 **)&buffer->data,
+					  &buffer->phys_addr);
+		if (rc) {
+			kfree(buffer);
+			goto fail;
+		}
+
+		list_add_tail(&buffer->list, &cdev->ll2->list);
+	}
+
+	switch (QED_LEADING_HWFN(cdev)->hw_info.personality) {
+	case QED_PCI_ISCSI:
+		conn_type = QED_LL2_TYPE_ISCSI;
+		break;
+	case QED_PCI_ETH_ROCE:
+		conn_type = QED_LL2_TYPE_ROCE;
+		break;
+	default:
+		conn_type = QED_LL2_TYPE_TEST;
+	}
+
+	/* Prepare the temporary ll2 information */
+	memset(&ll2_info, 0, sizeof(ll2_info));
+	ll2_info.conn_type = conn_type;
+	ll2_info.mtu = params->mtu;
+	ll2_info.rx_drop_ttl0_flg = params->drop_ttl0_packets;
+	ll2_info.rx_vlan_removal_en = params->rx_vlan_stripping;
+	ll2_info.tx_tc = 0;
+	ll2_info.tx_dest = CORE_TX_DEST_NW;
+
+	rc = qed_ll2_acquire_connection(QED_LEADING_HWFN(cdev), &ll2_info,
+					QED_LL2_RX_SIZE, QED_LL2_TX_SIZE,
+					&cdev->ll2->handle);
+	if (rc) {
+		DP_INFO(cdev, "Failed to acquire LL2 connection\n");
+		goto fail;
+	}
+
+	rc = qed_ll2_establish_connection(QED_LEADING_HWFN(cdev),
+					  cdev->ll2->handle);
+	if (rc) {
+		DP_INFO(cdev, "Failed to establish LL2 connection\n");
+		goto release_fail;
+	}
+
+	/* Post all Rx buffers to FW */
+	spin_lock_bh(&cdev->ll2->lock);
+	list_for_each_entry(buffer, &cdev->ll2->list, list) {
+		rc = qed_ll2_post_rx_buffer(QED_LEADING_HWFN(cdev),
+					    cdev->ll2->handle,
+					    buffer->phys_addr, 0, buffer, 1);
+		if (rc) {
+			DP_INFO(cdev,
+				"Failed to post an Rx buffer; Deleting it\n");
+			dma_unmap_single(&cdev->pdev->dev, buffer->phys_addr,
+					 cdev->ll2->rx_size, DMA_FROM_DEVICE);
+			kfree(buffer->data);
+			list_del(&buffer->list);
+			kfree(buffer);
+		} else {
+			cdev->ll2->rx_cnt++;
+		}
+	}
+	spin_unlock_bh(&cdev->ll2->lock);
+
+	if (!cdev->ll2->rx_cnt) {
+		DP_INFO(cdev, "Failed passing even a single Rx buffer\n");
+		goto release_terminate;
+	}
+
+	if (!is_valid_ether_addr(params->ll2_mac_address)) {
+		DP_INFO(cdev, "Invalid Ethernet address\n");
+		goto release_terminate;
+	}
+
+	p_ptt = qed_ptt_acquire(QED_LEADING_HWFN(cdev));
+	if (!p_ptt) {
+		DP_INFO(cdev, "Failed to acquire PTT\n");
+		goto release_terminate;
+	}
+
+	rc = qed_llh_add_mac_filter(QED_LEADING_HWFN(cdev), p_ptt,
+				    params->ll2_mac_address);
+	qed_ptt_release(QED_LEADING_HWFN(cdev), p_ptt);
+	if (rc) {
+		DP_ERR(cdev, "Failed to allocate LLH filter\n");
+		goto release_terminate_all;
+	}
+
+	ether_addr_copy(cdev->ll2_mac_address, params->ll2_mac_address);
+
+	return 0;
+
+release_terminate_all:
+
+release_terminate:
+	qed_ll2_terminate_connection(QED_LEADING_HWFN(cdev), cdev->ll2->handle);
+release_fail:
+	qed_ll2_release_connection(QED_LEADING_HWFN(cdev), cdev->ll2->handle);
+fail:
+	qed_ll2_kill_buffers(cdev);
+	cdev->ll2->handle = QED_LL2_UNUSED_HANDLE;
+	return -EINVAL;
+}
+
+static int qed_ll2_stop(struct qed_dev *cdev)
+{
+	struct qed_ptt *p_ptt;
+	int rc;
+
+	if (cdev->ll2->handle == QED_LL2_UNUSED_HANDLE)
+		return 0;
+
+	p_ptt = qed_ptt_acquire(QED_LEADING_HWFN(cdev));
+	if (!p_ptt) {
+		DP_INFO(cdev, "Failed to acquire PTT\n");
+		goto fail;
+	}
+
+	qed_llh_remove_mac_filter(QED_LEADING_HWFN(cdev), p_ptt,
+				  cdev->ll2_mac_address);
+	qed_ptt_release(QED_LEADING_HWFN(cdev), p_ptt);
+	eth_zero_addr(cdev->ll2_mac_address);
+
+	rc = qed_ll2_terminate_connection(QED_LEADING_HWFN(cdev),
+					  cdev->ll2->handle);
+	if (rc)
+		DP_INFO(cdev, "Failed to terminate LL2 connection\n");
+
+	qed_ll2_kill_buffers(cdev);
+
+	qed_ll2_release_connection(QED_LEADING_HWFN(cdev), cdev->ll2->handle);
+	cdev->ll2->handle = QED_LL2_UNUSED_HANDLE;
+
+	return rc;
+fail:
+	return -EINVAL;
+}
+
+static int qed_ll2_start_xmit(struct qed_dev *cdev, struct sk_buff *skb)
+{
+	const skb_frag_t *frag;
+	dma_addr_t mapping;
+	int rc = -EINVAL, i;
+	u16 vlan = 0;
+	u8 flags = 0;
+
+	if (unlikely(skb->ip_summed != CHECKSUM_NONE)) {
+		DP_INFO(cdev, "Cannot transmit a Checksumed packet\n");
+		return -EINVAL;
+	}
+
+	if (1 + skb_shinfo(skb)->nr_frags > CORE_LL2_TX_MAX_BDS_PER_PACKET) {
+		DP_ERR(cdev, "Cannot transmit a packet with %d fragments\n",
+		       1 + skb_shinfo(skb)->nr_frags);
+		return -EINVAL;
+	}
+
+	mapping = dma_map_single(&cdev->pdev->dev, skb->data,
+				 skb->len, DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(&cdev->pdev->dev, mapping))) {
+		DP_NOTICE(cdev, "SKB mapping failed\n");
+		return -EINVAL;
+	}
+
+	/* Request HW to calculate IP csum */
+	if (!((vlan_get_protocol(skb) == htons(ETH_P_IPV6)) &&
+	      ipv6_hdr(skb)->nexthdr == NEXTHDR_IPV6))
+		flags |= (1 << CORE_TX_BD_FLAGS_IP_CSUM_SHIFT);
+
+	if (skb_vlan_tag_present(skb)) {
+		vlan = skb_vlan_tag_get(skb);
+		flags |= (1 << CORE_TX_BD_FLAGS_VLAN_INSERTION_SHIFT);
+	}
+
+	rc = qed_ll2_prepare_tx_packet(QED_LEADING_HWFN(cdev),
+				       cdev->ll2->handle,
+				       1 + skb_shinfo(skb)->nr_frags,
+				       vlan, flags, 0, mapping,
+				       skb->len, skb, 1);
+	if (rc)
+		goto err;
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		frag = &skb_shinfo(skb)->frags[i];
+		if (!cdev->ll2->frags_mapped) {
+			mapping = skb_frag_dma_map(&cdev->pdev->dev, frag, 0,
+						   skb_frag_size(frag),
+						   DMA_TO_DEVICE);
+
+			if (unlikely(dma_mapping_error(&cdev->pdev->dev,
+						       mapping))) {
+				DP_NOTICE(cdev,
+					  "Unable to map frag - dropping packet\n");
+				goto err;
+			}
+		} else {
+			mapping = page_to_phys(skb_frag_page(frag)) |
+			    frag->page_offset;
+		}
+
+		rc = qed_ll2_set_fragment_of_tx_packet(QED_LEADING_HWFN(cdev),
+						       cdev->ll2->handle,
+						       mapping,
+						       skb_frag_size(frag));
+
+		/* if failed not much to do here, partial packet has been posted
+		 * we can't free memory, will need to wait for completion.
+		 */
+		if (rc)
+			goto err2;
+	}
+
+	return 0;
+
+err:
+	dma_unmap_single(&cdev->pdev->dev, mapping, skb->len, DMA_TO_DEVICE);
+
+err2:
+	return rc;
+}
+
+static int qed_ll2_stats(struct qed_dev *cdev, struct qed_ll2_stats *stats)
+{
+	if (!cdev->ll2)
+		return -EINVAL;
+
+	return qed_ll2_get_stats(QED_LEADING_HWFN(cdev),
+				 cdev->ll2->handle, stats);
+}
+
+const struct qed_ll2_ops qed_ll2_ops_pass = {
+	.start = &qed_ll2_start,
+	.stop = &qed_ll2_stop,
+	.start_xmit = &qed_ll2_start_xmit,
+	.register_cb_ops = &qed_ll2_register_cb_ops,
+	.get_stats = &qed_ll2_stats,
+};
+
+int qed_ll2_alloc_if(struct qed_dev *cdev)
+{
+	cdev->ll2 = kzalloc(sizeof(*cdev->ll2), GFP_KERNEL);
+	return cdev->ll2 ? 0 : -ENOMEM;
+}
+
+void qed_ll2_dealloc_if(struct qed_dev *cdev)
+{
+	kfree(cdev->ll2);
+	cdev->ll2 = NULL;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.h b/drivers/net/ethernet/qlogic/qed/qed_ll2.h
new file mode 100644
index 0000000..a037c48
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.h
@@ -0,0 +1,289 @@
+/* QLogic qed NIC Driver
+ *
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_LL2_H
+#define _QED_LL2_H
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/qed/qed_chain.h>
+#include <linux/qed/qed_ll2_if.h>
+#include "qed.h"
+#include "qed_hsi.h"
+#include "qed_sp.h"
+
+#define QED_MAX_NUM_OF_LL2_CONNECTIONS                    (4)
+
+enum qed_ll2_conn_type {
+	QED_LL2_TYPE_RESERVED,
+	QED_LL2_TYPE_ISCSI,
+	QED_LL2_TYPE_TEST,
+	QED_LL2_TYPE_ISCSI_OOO,
+	QED_LL2_TYPE_RESERVED2,
+	QED_LL2_TYPE_ROCE,
+	QED_LL2_TYPE_RESERVED3,
+	MAX_QED_LL2_RX_CONN_TYPE
+};
+
+struct qed_ll2_rx_packet {
+	struct list_head list_entry;
+	struct core_rx_bd_with_buff_len *rxq_bd;
+	dma_addr_t rx_buf_addr;
+	u16 buf_length;
+	void *cookie;
+	u8 placement_offset;
+	u16 parse_flags;
+	u16 packet_length;
+	u16 vlan;
+	u32 opaque_data[2];
+};
+
+struct qed_ll2_tx_packet {
+	struct list_head list_entry;
+	u16 bd_used;
+	u16 vlan;
+	u16 l4_hdr_offset_w;
+	u8 bd_flags;
+	bool notify_fw;
+	void *cookie;
+
+	struct {
+		struct core_tx_bd *txq_bd;
+		dma_addr_t tx_frag;
+		u16 frag_len;
+	} bds_set[ETH_TX_MAX_BDS_PER_NON_LSO_PACKET];
+};
+
+struct qed_ll2_rx_queue {
+	/* Lock protecting the Rx queue manipulation */
+	spinlock_t lock;
+	struct qed_chain rxq_chain;
+	struct qed_chain rcq_chain;
+	u8 rx_sb_index;
+	bool b_cb_registred;
+	__le16 *p_fw_cons;
+	struct list_head active_descq;
+	struct list_head free_descq;
+	struct list_head posting_descq;
+	struct qed_ll2_rx_packet *descq_array;
+	void __iomem *set_prod_addr;
+};
+
+struct qed_ll2_tx_queue {
+	/* Lock protecting the Tx queue manipulation */
+	spinlock_t lock;
+	struct qed_chain txq_chain;
+	u8 tx_sb_index;
+	bool b_cb_registred;
+	__le16 *p_fw_cons;
+	struct list_head active_descq;
+	struct list_head free_descq;
+	struct list_head sending_descq;
+	struct qed_ll2_tx_packet *descq_array;
+	struct qed_ll2_tx_packet *cur_send_packet;
+	struct qed_ll2_tx_packet cur_completing_packet;
+	u16 cur_completing_bd_idx;
+	void __iomem *doorbell_addr;
+	u16 bds_idx;
+	u16 cur_send_frag_num;
+	u16 cur_completing_frag_num;
+	bool b_completing_packet;
+};
+
+struct qed_ll2_info {
+	/* Lock protecting the state of LL2 */
+	struct mutex mutex;
+	enum qed_ll2_conn_type conn_type;
+	u32 cid;
+	u8 my_id;
+	u8 queue_id;
+	u8 tx_stats_id;
+	bool b_active;
+	u16 mtu;
+	u8 rx_drop_ttl0_flg;
+	u8 rx_vlan_removal_en;
+	u8 tx_tc;
+	enum core_tx_dest tx_dest;
+	enum core_error_handle ai_err_packet_too_big;
+	enum core_error_handle ai_err_no_buf;
+	u8 tx_stats_en;
+	struct qed_ll2_rx_queue rx_queue;
+	struct qed_ll2_tx_queue tx_queue;
+};
+
+/**
+ * @brief qed_ll2_acquire_connection - allocate resources,
+ *        starts rx & tx (if relevant) queues pair. Provides
+ *        connecion handler as output parameter.
+ *
+ * @param p_hwfn
+ * @param p_params		Contain various configuration properties
+ * @param rx_num_desc
+ * @param tx_num_desc
+ *
+ * @param p_connection_handle  Output container for LL2 connection's handle
+ *
+ * @return 0 on success, failure otherwise
+ */
+int qed_ll2_acquire_connection(struct qed_hwfn *p_hwfn,
+			       struct qed_ll2_info *p_params,
+			       u16 rx_num_desc,
+			       u16 tx_num_desc,
+			       u8 *p_connection_handle);
+
+/**
+ * @brief qed_ll2_establish_connection - start previously
+ *        allocated LL2 queues pair
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param connection_handle	LL2 connection's handle obtained from
+ *                              qed_ll2_require_connection
+ *
+ * @return 0 on success, failure otherwise
+ */
+int qed_ll2_establish_connection(struct qed_hwfn *p_hwfn, u8 connection_handle);
+
+/**
+ * @brief qed_ll2_post_rx_buffers - submit buffers to LL2 Rx queue.
+ *
+ * @param p_hwfn
+ * @param connection_handle	LL2 connection's handle obtained from
+ *				qed_ll2_require_connection
+ * @param addr			rx (physical address) buffers to submit
+ * @param cookie
+ * @param notify_fw		produce corresponding Rx BD immediately
+ *
+ * @return 0 on success, failure otherwise
+ */
+int qed_ll2_post_rx_buffer(struct qed_hwfn *p_hwfn,
+			   u8 connection_handle,
+			   dma_addr_t addr,
+			   u16 buf_len, void *cookie, u8 notify_fw);
+
+/**
+ * @brief qed_ll2_prepare_tx_packet - request for start Tx BD
+ *				      to prepare Tx packet submission to FW.
+ *
+ * @param p_hwfn
+ * @param connection_handle	LL2 connection's handle obtained from
+ *				qed_ll2_require_connection
+ * @param num_of_bds		a number of requested BD equals a number of
+ *				fragments in Tx packet
+ * @param vlan			VLAN to insert to packet (if insertion set)
+ * @param bd_flags
+ * @param l4_hdr_offset_w	L4 Header Offset from start of packet
+ *				(in words). This is needed if both l4_csum
+ *				and ipv6_ext are set
+ * @param first_frag
+ * @param first_frag_len
+ * @param cookie
+ *
+ * @param notify_fw
+ *
+ * @return 0 on success, failure otherwise
+ */
+int qed_ll2_prepare_tx_packet(struct qed_hwfn *p_hwfn,
+			      u8 connection_handle,
+			      u8 num_of_bds,
+			      u16 vlan,
+			      u8 bd_flags,
+			      u16 l4_hdr_offset_w,
+			      dma_addr_t first_frag,
+			      u16 first_frag_len, void *cookie, u8 notify_fw);
+
+/**
+ * @brief qed_ll2_release_connection -	releases resources
+ *					allocated for LL2 connection
+ *
+ * @param p_hwfn
+ * @param connection_handle		LL2 connection's handle obtained from
+ *					qed_ll2_require_connection
+ */
+void qed_ll2_release_connection(struct qed_hwfn *p_hwfn, u8 connection_handle);
+
+/**
+ * @brief qed_ll2_set_fragment_of_tx_packet -	provides fragments to fill
+ *						Tx BD of BDs requested by
+ *						qed_ll2_prepare_tx_packet
+ *
+ * @param p_hwfn
+ * @param connection_handle			LL2 connection's handle
+ *						obtained from
+ *						qed_ll2_require_connection
+ * @param addr
+ * @param nbytes
+ *
+ * @return 0 on success, failure otherwise
+ */
+int qed_ll2_set_fragment_of_tx_packet(struct qed_hwfn *p_hwfn,
+				      u8 connection_handle,
+				      dma_addr_t addr, u16 nbytes);
+
+/**
+ * @brief qed_ll2_terminate_connection -	stops Tx/Rx queues
+ *
+ *
+ * @param p_hwfn
+ * @param connection_handle			LL2 connection's handle
+ *						obtained from
+ *						qed_ll2_require_connection
+ *
+ * @return 0 on success, failure otherwise
+ */
+int qed_ll2_terminate_connection(struct qed_hwfn *p_hwfn, u8 connection_handle);
+
+/**
+ * @brief qed_ll2_get_stats -	get LL2 queue's statistics
+ *
+ *
+ * @param p_hwfn
+ * @param connection_handle	LL2 connection's handle obtained from
+ *				qed_ll2_require_connection
+ * @param p_stats
+ *
+ * @return 0 on success, failure otherwise
+ */
+int qed_ll2_get_stats(struct qed_hwfn *p_hwfn,
+		      u8 connection_handle, struct qed_ll2_stats *p_stats);
+
+/**
+ * @brief qed_ll2_alloc - Allocates LL2 connections set
+ *
+ * @param p_hwfn
+ *
+ * @return pointer to alocated qed_ll2_info or NULL
+ */
+struct qed_ll2_info *qed_ll2_alloc(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_ll2_setup - Inits LL2 connections set
+ *
+ * @param p_hwfn
+ * @param p_ll2_connections
+ *
+ */
+void qed_ll2_setup(struct qed_hwfn *p_hwfn,
+		   struct qed_ll2_info *p_ll2_connections);
+
+/**
+ * @brief qed_ll2_free - Releases LL2 connections set
+ *
+ * @param p_hwfn
+ * @param p_ll2_connections
+ *
+ */
+void qed_ll2_free(struct qed_hwfn *p_hwfn,
+		  struct qed_ll2_info *p_ll2_connections);
+
+#endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 6c4606b..6250c7f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -22,11 +22,13 @@
 #include <linux/etherdevice.h>
 #include <linux/vmalloc.h>
 #include <linux/qed/qed_if.h>
+#include <linux/qed/qed_ll2_if.h>
 
 #include "qed.h"
 #include "qed_sriov.h"
 #include "qed_sp.h"
 #include "qed_dev_api.h"
+#include "qed_ll2.h"
 #include "qed_mcp.h"
 #include "qed_hw.h"
 #include "qed_selftest.h"
@@ -599,7 +601,16 @@ static int qed_nic_reset(struct qed_dev *cdev)
 
 static int qed_nic_setup(struct qed_dev *cdev)
 {
-	int rc;
+	int rc, i;
+
+	/* Determine if interface is going to require LL2 */
+	if (QED_LEADING_HWFN(cdev)->hw_info.personality != QED_PCI_ETH) {
+		for (i = 0; i < cdev->num_hwfns; i++) {
+			struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+			p_hwfn->using_ll2 = true;
+		}
+	}
 
 	rc = qed_resc_alloc(cdev);
 	if (rc)
@@ -859,6 +870,12 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 	DP_INFO(cdev,
 		"HW initialization and function start completed successfully\n");
 
+	/* Allocate LL2 interface if needed */
+	if (QED_LEADING_HWFN(cdev)->using_ll2) {
+		rc = qed_ll2_alloc_if(cdev);
+		if (rc)
+			goto err3;
+	}
 	if (IS_PF(cdev)) {
 		hwfn = QED_LEADING_HWFN(cdev);
 		drv_version.version = (params->drv_major << 24) |
@@ -879,6 +896,8 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 
 	return 0;
 
+err3:
+	qed_hw_stop(cdev);
 err2:
 	qed_hw_timers_stop_all(cdev);
 	if (IS_PF(cdev))
@@ -901,6 +920,8 @@ static int qed_slowpath_stop(struct qed_dev *cdev)
 	if (!cdev)
 		return -ENODEV;
 
+	qed_ll2_dealloc_if(cdev);
+
 	if (IS_PF(cdev)) {
 		qed_free_stream_mem(cdev);
 		if (IS_QED_ETH_IF(cdev))
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index aa08ddb..c4b2f5a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -200,6 +200,26 @@
 	0x50196cUL
 #define NIG_REG_LLH_CLS_TYPE_DUALMODE \
 	0x501964UL
+#define NIG_REG_LLH_FUNC_FILTER_VALUE \
+	0x501a00UL
+#define NIG_REG_LLH_FUNC_FILTER_VALUE_SIZE \
+	32
+#define NIG_REG_LLH_FUNC_FILTER_EN \
+	0x501a80UL
+#define NIG_REG_LLH_FUNC_FILTER_EN_SIZE	\
+	16
+#define NIG_REG_LLH_FUNC_FILTER_MODE \
+	0x501ac0UL
+#define NIG_REG_LLH_FUNC_FILTER_MODE_SIZE \
+	16
+#define NIG_REG_LLH_FUNC_FILTER_PROTOCOL_TYPE \
+	0x501b00UL
+#define NIG_REG_LLH_FUNC_FILTER_PROTOCOL_TYPE_SIZE \
+	16
+#define NIG_REG_LLH_FUNC_FILTER_HDR_SEL	\
+	0x501b40UL
+#define NIG_REG_LLH_FUNC_FILTER_HDR_SEL_SIZE \
+	16
 #define  NCSI_REG_CONFIG	\
 	0x040200UL
 #define  PBF_REG_INIT \
@@ -256,6 +276,8 @@
 	0x1f0a1cUL
 #define PRS_REG_ROCE_DEST_QP_MAX_PF \
 	0x1f0430UL
+#define PRS_REG_USE_LIGHT_L2 \
+	0x1f096cUL
 #define  PSDM_REG_ENABLE_IN1 \
 	0xfa0004UL
 #define  PSEM_REG_ENABLE_IN \
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp.h b/drivers/net/ethernet/qlogic/qed/qed_sp.h
index a548504..a3c539f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp.h
@@ -61,6 +61,10 @@ union ramrod_data {
 	struct vport_start_ramrod_data vport_start;
 	struct vport_stop_ramrod_data vport_stop;
 	struct vport_update_ramrod_data vport_update;
+	struct core_rx_start_ramrod_data core_rx_queue_start;
+	struct core_rx_stop_ramrod_data core_rx_queue_stop;
+	struct core_tx_start_ramrod_data core_tx_queue_start;
+	struct core_tx_stop_ramrod_data core_tx_queue_stop;
 	struct vport_filter_update_ramrod_data vport_filter_update;
 
 	struct rdma_init_func_ramrod_data rdma_init_func;
diff --git a/include/linux/qed/common_hsi.h b/include/linux/qed/common_hsi.h
index 40c0ada..69e5dfd 100644
--- a/include/linux/qed/common_hsi.h
+++ b/include/linux/qed/common_hsi.h
@@ -23,6 +23,8 @@
 #define PSTORM_QZONE_SIZE 0
 
 #define ETH_MAX_NUM_RX_QUEUES_PER_VF 16
+#define CORE_LL2_TX_MAX_BDS_PER_PACKET                          12
+#define MAX_NUM_LL2_RX_QUEUES                                   32
 
 #define FW_MAJOR_VERSION	8
 #define FW_MINOR_VERSION	10
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index e1d5122..ca5e487 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -574,6 +574,7 @@ enum DP_MODULE {
 	QED_MSG_SP	= 0x100000,
 	QED_MSG_STORAGE = 0x200000,
 	QED_MSG_CXT	= 0x800000,
+	QED_MSG_LL2	= 0x1000000,
 	QED_MSG_ILT	= 0x2000000,
 	QED_MSG_ROCE	= 0x4000000,
 	QED_MSG_DEBUG	= 0x8000000,
diff --git a/include/linux/qed/qed_ll2_if.h b/include/linux/qed/qed_ll2_if.h
new file mode 100644
index 0000000..0164cca
--- /dev/null
+++ b/include/linux/qed/qed_ll2_if.h
@@ -0,0 +1,140 @@
+/* QLogic qed NIC Driver
+ *
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_LL2_IF_H
+#define _QED_LL2_IF_H
+
+#include <linux/types.h>
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/pci.h>
+#include <linux/skbuff.h>
+#include <linux/types.h>
+#include <linux/version.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/qed/qed_if.h>
+
+struct qed_ll2_stats {
+	u64 gsi_invalid_hdr;
+	u64 gsi_invalid_pkt_length;
+	u64 gsi_unsupported_pkt_typ;
+	u64 gsi_crcchksm_error;
+
+	u64 packet_too_big_discard;
+	u64 no_buff_discard;
+
+	u64 rcv_ucast_bytes;
+	u64 rcv_mcast_bytes;
+	u64 rcv_bcast_bytes;
+	u64 rcv_ucast_pkts;
+	u64 rcv_mcast_pkts;
+	u64 rcv_bcast_pkts;
+
+	u64 sent_ucast_bytes;
+	u64 sent_mcast_bytes;
+	u64 sent_bcast_bytes;
+	u64 sent_ucast_pkts;
+	u64 sent_mcast_pkts;
+	u64 sent_bcast_pkts;
+};
+
+#define QED_LL2_UNUSED_HANDLE   (0xff)
+
+struct qed_ll2_cb_ops {
+	int (*rx_cb)(void *, struct sk_buff *, u32, u32);
+	int (*tx_cb)(void *, struct sk_buff *, bool);
+};
+
+struct qed_ll2_params {
+	u16 mtu;
+	bool drop_ttl0_packets;
+	bool rx_vlan_stripping;
+	u8 tx_tc;
+	bool frags_mapped;
+	u8 ll2_mac_address[ETH_ALEN];
+};
+
+struct qed_ll2_ops {
+/**
+ * @brief start - initializes ll2
+ *
+ * @param cdev
+ * @param params - protocol driver configuration for the ll2.
+ *
+ * @return 0 on success, otherwise error value.
+ */
+	int (*start)(struct qed_dev *cdev, struct qed_ll2_params *params);
+
+/**
+ * @brief stop - stops the ll2
+ *
+ * @param cdev
+ *
+ * @return 0 on success, otherwise error value.
+ */
+	int (*stop)(struct qed_dev *cdev);
+
+/**
+ * @brief start_xmit - transmits an skb over the ll2 interface
+ *
+ * @param cdev
+ * @param skb
+ *
+ * @return 0 on success, otherwise error value.
+ */
+	int (*start_xmit)(struct qed_dev *cdev, struct sk_buff *skb);
+
+/**
+ * @brief register_cb_ops - protocol driver register the callback for Rx/Tx
+ * packets. Should be called before `start'.
+ *
+ * @param cdev
+ * @param cookie - to be passed to the callback functions.
+ * @param ops - the callback functions to register for Rx / Tx.
+ *
+ * @return 0 on success, otherwise error value.
+ */
+	void (*register_cb_ops)(struct qed_dev *cdev,
+				const struct qed_ll2_cb_ops *ops,
+				void *cookie);
+
+/**
+ * @brief get LL2 related statistics
+ *
+ * @param cdev
+ * @param stats - pointer to struct that would be filled with stats
+ *
+ * @return 0 on success, error otherwise.
+ */
+	int (*get_stats)(struct qed_dev *cdev, struct qed_ll2_stats *stats);
+};
+
+#ifdef CONFIG_QED_LL2
+int qed_ll2_alloc_if(struct qed_dev *);
+void qed_ll2_dealloc_if(struct qed_dev *);
+#else
+static const struct qed_ll2_ops qed_ll2_ops_pass = {
+	.start = NULL,
+	.stop = NULL,
+	.start_xmit = NULL,
+	.register_cb_ops = NULL,
+	.get_stats = NULL,
+};
+
+static inline int qed_ll2_alloc_if(struct qed_dev *cdev)
+{
+	return 0;
+}
+
+static inline void qed_ll2_dealloc_if(struct qed_dev *cdev)
+{
+}
+#endif
+#endif
-- 
1.9.3
