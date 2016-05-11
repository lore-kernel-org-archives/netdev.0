From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next v2 05/14] qed: IOV l2 functionality
Date: Wed, 11 May 2016 16:36:16 +0300
Message-ID: <1462973785-32532-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1462973785-32532-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:49899 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932671AbcEKNg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 09:36:57 -0400
In-Reply-To: <1462973785-32532-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds sufficient changes to allow VFs l2-configuration flows to work.

While the fastpath of the VF and the PF are meant to be exactly the same,
the configuration of the VF is done by the PF.
This diverges all VF-related configuration flows that originate from a VF,
making them pass through the VF->PF channel and adding sufficient logic
on the PF side to support them.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h          |   1 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c      |  10 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.c       | 456 ++++++++--------
 drivers/net/ethernet/qlogic/qed/qed_l2.h       | 178 +++++++
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |   2 +
 drivers/net/ethernet/qlogic/qed/qed_sriov.c    | 704 +++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.h    |  24 +
 drivers/net/ethernet/qlogic/qed/qed_vf.c       | 445 ++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_vf.h       | 383 +++++++++++++-
 9 files changed, 1957 insertions(+), 246 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_l2.h

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index f9a3576..d7da645 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -532,6 +532,7 @@ struct qed_dev {
 };
 
 #define NUM_OF_VFS(dev)         MAX_NUM_VFS_BB
+#define NUM_OF_L2_QUEUES(dev)	MAX_NUM_L2_QUEUES_BB
 #define NUM_OF_SBS(dev)         MAX_SB_PER_PATH_BB
 #define NUM_OF_ENG_PFS(dev)     MAX_NUM_PFS_BB
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 78e25cf..9d01a16 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -938,7 +938,12 @@ void qed_hw_stop_fastpath(struct qed_dev *cdev)
 
 	for_each_hwfn(cdev, j) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[j];
-		struct qed_ptt *p_ptt   = p_hwfn->p_main_ptt;
+		struct qed_ptt *p_ptt = p_hwfn->p_main_ptt;
+
+		if (IS_VF(cdev)) {
+			qed_vf_pf_int_cleanup(p_hwfn);
+			continue;
+		}
 
 		DP_VERBOSE(p_hwfn,
 			   NETIF_MSG_IFDOWN,
@@ -962,6 +967,9 @@ void qed_hw_stop_fastpath(struct qed_dev *cdev)
 
 void qed_hw_start_fastpath(struct qed_hwfn *p_hwfn)
 {
+	if (IS_VF(p_hwfn->cdev))
+		return;
+
 	/* Re-open incoming traffic */
 	qed_wr(p_hwfn, p_hwfn->p_main_ptt,
 	       NIG_REG_RX_LLH_BRB_GATE_DNTFWD_PERPF, 0x0);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 5978bb5..9f88f2f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -31,125 +31,25 @@
 #include "qed_hsi.h"
 #include "qed_hw.h"
 #include "qed_int.h"
+#include "qed_l2.h"
 #include "qed_mcp.h"
 #include "qed_reg_addr.h"
 #include "qed_sp.h"
 #include "qed_sriov.h"
 
-struct qed_rss_params {
-	u8	update_rss_config;
-	u8	rss_enable;
-	u8	rss_eng_id;
-	u8	update_rss_capabilities;
-	u8	update_rss_ind_table;
-	u8	update_rss_key;
-	u8	rss_caps;
-	u8	rss_table_size_log;
-	u16	rss_ind_table[QED_RSS_IND_TABLE_SIZE];
-	u32	rss_key[QED_RSS_KEY_SIZE];
-};
-
-enum qed_filter_opcode {
-	QED_FILTER_ADD,
-	QED_FILTER_REMOVE,
-	QED_FILTER_MOVE,
-	QED_FILTER_REPLACE,     /* Delete all MACs and add new one instead */
-	QED_FILTER_FLUSH,       /* Removes all filters */
-};
-
-enum qed_filter_ucast_type {
-	QED_FILTER_MAC,
-	QED_FILTER_VLAN,
-	QED_FILTER_MAC_VLAN,
-	QED_FILTER_INNER_MAC,
-	QED_FILTER_INNER_VLAN,
-	QED_FILTER_INNER_PAIR,
-	QED_FILTER_INNER_MAC_VNI_PAIR,
-	QED_FILTER_MAC_VNI_PAIR,
-	QED_FILTER_VNI,
-};
-
-struct qed_filter_ucast {
-	enum qed_filter_opcode		opcode;
-	enum qed_filter_ucast_type	type;
-	u8				is_rx_filter;
-	u8				is_tx_filter;
-	u8				vport_to_add_to;
-	u8				vport_to_remove_from;
-	unsigned char			mac[ETH_ALEN];
-	u8				assert_on_error;
-	u16				vlan;
-	u32				vni;
-};
-
-struct qed_filter_mcast {
-	/* MOVE is not supported for multicast */
-	enum qed_filter_opcode	opcode;
-	u8			vport_to_add_to;
-	u8			vport_to_remove_from;
-	u8			num_mc_addrs;
-#define QED_MAX_MC_ADDRS        64
-	unsigned char		mac[QED_MAX_MC_ADDRS][ETH_ALEN];
-};
-
-struct qed_filter_accept_flags {
-	u8	update_rx_mode_config;
-	u8	update_tx_mode_config;
-	u8	rx_accept_filter;
-	u8	tx_accept_filter;
-#define QED_ACCEPT_NONE         0x01
-#define QED_ACCEPT_UCAST_MATCHED        0x02
-#define QED_ACCEPT_UCAST_UNMATCHED      0x04
-#define QED_ACCEPT_MCAST_MATCHED        0x08
-#define QED_ACCEPT_MCAST_UNMATCHED      0x10
-#define QED_ACCEPT_BCAST                0x20
-};
-
-struct qed_sp_vport_update_params {
-	u16				opaque_fid;
-	u8				vport_id;
-	u8				update_vport_active_rx_flg;
-	u8				vport_active_rx_flg;
-	u8				update_vport_active_tx_flg;
-	u8				vport_active_tx_flg;
-	u8				update_approx_mcast_flg;
-	u8				update_accept_any_vlan_flg;
-	u8				accept_any_vlan;
-	unsigned long			bins[8];
-	struct qed_rss_params		*rss_params;
-	struct qed_filter_accept_flags	accept_flags;
-};
-
-enum qed_tpa_mode {
-	QED_TPA_MODE_NONE,
-	QED_TPA_MODE_UNUSED,
-	QED_TPA_MODE_GRO,
-	QED_TPA_MODE_MAX
-};
-
-struct qed_sp_vport_start_params {
-	enum qed_tpa_mode	tpa_mode;
-	bool			remove_inner_vlan;
-	bool			drop_ttl0;
-	u8			max_buffers_per_cqe;
-	u32			concrete_fid;
-	u16			opaque_fid;
-	u8			vport_id;
-	u16			mtu;
-};
 
 #define QED_MAX_SGES_NUM 16
 #define CRC32_POLY 0x1edc6f41
 
-static int qed_sp_vport_start(struct qed_hwfn *p_hwfn,
-			      struct qed_sp_vport_start_params *p_params)
+int qed_sp_eth_vport_start(struct qed_hwfn *p_hwfn,
+			   struct qed_sp_vport_start_params *p_params)
 {
 	struct vport_start_ramrod_data *p_ramrod = NULL;
 	struct qed_spq_entry *p_ent =  NULL;
 	struct qed_sp_init_data init_data;
+	u8 abs_vport_id = 0;
 	int rc = -EINVAL;
 	u16 rx_mode = 0;
-	u8 abs_vport_id = 0;
 
 	rc = qed_fw_vport(p_hwfn, p_params->vport_id, &abs_vport_id);
 	if (rc != 0)
@@ -206,6 +106,20 @@ static int qed_sp_vport_start(struct qed_hwfn *p_hwfn,
 	return qed_spq_post(p_hwfn, p_ent, NULL);
 }
 
+int qed_sp_vport_start(struct qed_hwfn *p_hwfn,
+		       struct qed_sp_vport_start_params *p_params)
+{
+	if (IS_VF(p_hwfn->cdev)) {
+		return qed_vf_pf_vport_start(p_hwfn, p_params->vport_id,
+					     p_params->mtu,
+					     p_params->remove_inner_vlan,
+					     p_params->tpa_mode,
+					     p_params->max_buffers_per_cqe);
+	}
+
+	return qed_sp_eth_vport_start(p_hwfn, p_params);
+}
+
 static int
 qed_sp_vport_update_rss(struct qed_hwfn *p_hwfn,
 			struct vport_update_ramrod_data *p_ramrod,
@@ -371,11 +285,10 @@ qed_sp_update_mcast_bin(struct qed_hwfn *p_hwfn,
 	}
 }
 
-static int
-qed_sp_vport_update(struct qed_hwfn *p_hwfn,
-		    struct qed_sp_vport_update_params *p_params,
-		    enum spq_mode comp_mode,
-		    struct qed_spq_comp_cb *p_comp_data)
+int qed_sp_vport_update(struct qed_hwfn *p_hwfn,
+			struct qed_sp_vport_update_params *p_params,
+			enum spq_mode comp_mode,
+			struct qed_spq_comp_cb *p_comp_data)
 {
 	struct qed_rss_params *p_rss_params = p_params->rss_params;
 	struct vport_update_ramrod_data_cmn *p_cmn;
@@ -385,6 +298,11 @@ qed_sp_vport_update(struct qed_hwfn *p_hwfn,
 	u8 abs_vport_id = 0;
 	int rc = -EINVAL;
 
+	if (IS_VF(p_hwfn->cdev)) {
+		rc = qed_vf_pf_vport_update(p_hwfn, p_params);
+		return rc;
+	}
+
 	rc = qed_fw_vport(p_hwfn, p_params->vport_id, &abs_vport_id);
 	if (rc != 0)
 		return rc;
@@ -427,9 +345,7 @@ qed_sp_vport_update(struct qed_hwfn *p_hwfn,
 	return qed_spq_post(p_hwfn, p_ent, NULL);
 }
 
-static int qed_sp_vport_stop(struct qed_hwfn *p_hwfn,
-			     u16 opaque_fid,
-			     u8 vport_id)
+int qed_sp_vport_stop(struct qed_hwfn *p_hwfn, u16 opaque_fid, u8 vport_id)
 {
 	struct vport_stop_ramrod_data *p_ramrod;
 	struct qed_sp_init_data init_data;
@@ -437,6 +353,9 @@ static int qed_sp_vport_stop(struct qed_hwfn *p_hwfn,
 	u8 abs_vport_id = 0;
 	int rc;
 
+	if (IS_VF(p_hwfn->cdev))
+		return qed_vf_pf_vport_stop(p_hwfn);
+
 	rc = qed_fw_vport(p_hwfn, vport_id, &abs_vport_id);
 	if (rc != 0)
 		return rc;
@@ -458,13 +377,26 @@ static int qed_sp_vport_stop(struct qed_hwfn *p_hwfn,
 	return qed_spq_post(p_hwfn, p_ent, NULL);
 }
 
+static int
+qed_vf_pf_accept_flags(struct qed_hwfn *p_hwfn,
+		       struct qed_filter_accept_flags *p_accept_flags)
+{
+	struct qed_sp_vport_update_params s_params;
+
+	memset(&s_params, 0, sizeof(s_params));
+	memcpy(&s_params.accept_flags, p_accept_flags,
+	       sizeof(struct qed_filter_accept_flags));
+
+	return qed_vf_pf_vport_update(p_hwfn, &s_params);
+}
+
 static int qed_filter_accept_cmd(struct qed_dev *cdev,
 				 u8 vport,
 				 struct qed_filter_accept_flags accept_flags,
 				 u8 update_accept_any_vlan,
 				 u8 accept_any_vlan,
-				enum spq_mode comp_mode,
-				struct qed_spq_comp_cb *p_comp_data)
+				 enum spq_mode comp_mode,
+				 struct qed_spq_comp_cb *p_comp_data)
 {
 	struct qed_sp_vport_update_params vport_update_params;
 	int i, rc;
@@ -481,6 +413,13 @@ static int qed_filter_accept_cmd(struct qed_dev *cdev,
 
 		vport_update_params.opaque_fid = p_hwfn->hw_info.opaque_fid;
 
+		if (IS_VF(cdev)) {
+			rc = qed_vf_pf_accept_flags(p_hwfn, &accept_flags);
+			if (rc)
+				return rc;
+			continue;
+		}
+
 		rc = qed_sp_vport_update(p_hwfn, &vport_update_params,
 					 comp_mode, p_comp_data);
 		if (rc != 0) {
@@ -515,16 +454,14 @@ static int qed_sp_release_queue_cid(
 	return 0;
 }
 
-static int
-qed_sp_eth_rxq_start_ramrod(struct qed_hwfn *p_hwfn,
-			    u16 opaque_fid,
-			    u32 cid,
-			    struct qed_queue_start_common_params *params,
-			    u8 stats_id,
-			    u16 bd_max_bytes,
-			    dma_addr_t bd_chain_phys_addr,
-			    dma_addr_t cqe_pbl_addr,
-			    u16 cqe_pbl_size)
+int qed_sp_eth_rxq_start_ramrod(struct qed_hwfn *p_hwfn,
+				u16 opaque_fid,
+				u32 cid,
+				struct qed_queue_start_common_params *params,
+				u8 stats_id,
+				u16 bd_max_bytes,
+				dma_addr_t bd_chain_phys_addr,
+				dma_addr_t cqe_pbl_addr, u16 cqe_pbl_size)
 {
 	struct rx_queue_start_ramrod_data *p_ramrod = NULL;
 	struct qed_spq_entry *p_ent = NULL;
@@ -593,8 +530,7 @@ qed_sp_eth_rx_queue_start(struct qed_hwfn *p_hwfn,
 			  u16 bd_max_bytes,
 			  dma_addr_t bd_chain_phys_addr,
 			  dma_addr_t cqe_pbl_addr,
-			  u16 cqe_pbl_size,
-			  void __iomem **pp_prod)
+			  u16 cqe_pbl_size, void __iomem **pp_prod)
 {
 	struct qed_hw_cid_data *p_rx_cid;
 	u64 init_prod_val = 0;
@@ -602,6 +538,16 @@ qed_sp_eth_rx_queue_start(struct qed_hwfn *p_hwfn,
 	u8 abs_stats_id = 0;
 	int rc;
 
+	if (IS_VF(p_hwfn->cdev)) {
+		return qed_vf_pf_rxq_start(p_hwfn,
+					   params->queue_id,
+					   params->sb,
+					   params->sb_idx,
+					   bd_max_bytes,
+					   bd_chain_phys_addr,
+					   cqe_pbl_addr, cqe_pbl_size, pp_prod);
+	}
+
 	rc = qed_fw_l2_queue(p_hwfn, params->queue_id, &abs_l2_queue);
 	if (rc != 0)
 		return rc;
@@ -644,10 +590,9 @@ qed_sp_eth_rx_queue_start(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
-static int qed_sp_eth_rx_queue_stop(struct qed_hwfn *p_hwfn,
-				    u16 rx_queue_id,
-				    bool eq_completion_only,
-				    bool cqe_completion)
+int qed_sp_eth_rx_queue_stop(struct qed_hwfn *p_hwfn,
+			     u16 rx_queue_id,
+			     bool eq_completion_only, bool cqe_completion)
 {
 	struct qed_hw_cid_data *p_rx_cid = &p_hwfn->p_rx_cids[rx_queue_id];
 	struct rx_queue_stop_ramrod_data *p_ramrod = NULL;
@@ -656,6 +601,9 @@ static int qed_sp_eth_rx_queue_stop(struct qed_hwfn *p_hwfn,
 	u16 abs_rx_q_id = 0;
 	int rc = -EINVAL;
 
+	if (IS_VF(p_hwfn->cdev))
+		return qed_vf_pf_rxq_stop(p_hwfn, rx_queue_id, cqe_completion);
+
 	/* Get SPQ entry */
 	memset(&init_data, 0, sizeof(init_data));
 	init_data.cid = p_rx_cid->cid;
@@ -691,15 +639,14 @@ static int qed_sp_eth_rx_queue_stop(struct qed_hwfn *p_hwfn,
 	return qed_sp_release_queue_cid(p_hwfn, p_rx_cid);
 }
 
-static int
-qed_sp_eth_txq_start_ramrod(struct qed_hwfn  *p_hwfn,
-			    u16  opaque_fid,
-			    u32  cid,
-			    struct qed_queue_start_common_params *p_params,
-			    u8  stats_id,
-			    dma_addr_t pbl_addr,
-			    u16 pbl_size,
-			    union qed_qm_pq_params *p_pq_params)
+int qed_sp_eth_txq_start_ramrod(struct qed_hwfn  *p_hwfn,
+				u16  opaque_fid,
+				u32  cid,
+				struct qed_queue_start_common_params *p_params,
+				u8  stats_id,
+				dma_addr_t pbl_addr,
+				u16 pbl_size,
+				union qed_qm_pq_params *p_pq_params)
 {
 	struct tx_queue_start_ramrod_data *p_ramrod = NULL;
 	struct qed_spq_entry *p_ent = NULL;
@@ -753,14 +700,21 @@ qed_sp_eth_tx_queue_start(struct qed_hwfn *p_hwfn,
 			  u16 opaque_fid,
 			  struct qed_queue_start_common_params *p_params,
 			  dma_addr_t pbl_addr,
-			  u16 pbl_size,
-			  void __iomem **pp_doorbell)
+			  u16 pbl_size, void __iomem **pp_doorbell)
 {
 	struct qed_hw_cid_data *p_tx_cid;
 	union qed_qm_pq_params pq_params;
 	u8 abs_stats_id = 0;
 	int rc;
 
+	if (IS_VF(p_hwfn->cdev)) {
+		return qed_vf_pf_txq_start(p_hwfn,
+					   p_params->queue_id,
+					   p_params->sb,
+					   p_params->sb_idx,
+					   pbl_addr, pbl_size, pp_doorbell);
+	}
+
 	rc = qed_fw_vport(p_hwfn, p_params->vport_id, &abs_stats_id);
 	if (rc)
 		return rc;
@@ -801,14 +755,16 @@ qed_sp_eth_tx_queue_start(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
-static int qed_sp_eth_tx_queue_stop(struct qed_hwfn *p_hwfn,
-				    u16 tx_queue_id)
+int qed_sp_eth_tx_queue_stop(struct qed_hwfn *p_hwfn, u16 tx_queue_id)
 {
 	struct qed_hw_cid_data *p_tx_cid = &p_hwfn->p_tx_cids[tx_queue_id];
 	struct qed_spq_entry *p_ent = NULL;
 	struct qed_sp_init_data init_data;
 	int rc = -EINVAL;
 
+	if (IS_VF(p_hwfn->cdev))
+		return qed_vf_pf_txq_stop(p_hwfn, tx_queue_id);
+
 	/* Get SPQ entry */
 	memset(&init_data, 0, sizeof(init_data));
 	init_data.cid = p_tx_cid->cid;
@@ -1004,11 +960,11 @@ qed_filter_ucast_common(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
-static int qed_sp_eth_filter_ucast(struct qed_hwfn *p_hwfn,
-				   u16 opaque_fid,
-				   struct qed_filter_ucast *p_filter_cmd,
-				   enum spq_mode comp_mode,
-				   struct qed_spq_comp_cb *p_comp_data)
+int qed_sp_eth_filter_ucast(struct qed_hwfn *p_hwfn,
+			    u16 opaque_fid,
+			    struct qed_filter_ucast *p_filter_cmd,
+			    enum spq_mode comp_mode,
+			    struct qed_spq_comp_cb *p_comp_data)
 {
 	struct vport_filter_update_ramrod_data	*p_ramrod	= NULL;
 	struct qed_spq_entry			*p_ent		= NULL;
@@ -1106,7 +1062,7 @@ static inline u32 qed_crc32c_le(u32 seed,
 	return qed_calc_crc32c((u8 *)packet_buf, 8, seed, 0);
 }
 
-static u8 qed_mcast_bin_from_mac(u8 *mac)
+u8 qed_mcast_bin_from_mac(u8 *mac)
 {
 	u32 crc = qed_crc32c_le(ETH_MULTICAST_BIN_FROM_MAC_SEED,
 				mac, ETH_ALEN);
@@ -1189,11 +1145,10 @@ qed_sp_eth_filter_mcast(struct qed_hwfn *p_hwfn,
 	return qed_spq_post(p_hwfn, p_ent, NULL);
 }
 
-static int
-qed_filter_mcast_cmd(struct qed_dev *cdev,
-		     struct qed_filter_mcast *p_filter_cmd,
-		     enum spq_mode comp_mode,
-		     struct qed_spq_comp_cb *p_comp_data)
+static int qed_filter_mcast_cmd(struct qed_dev *cdev,
+				struct qed_filter_mcast *p_filter_cmd,
+				enum spq_mode comp_mode,
+				struct qed_spq_comp_cb *p_comp_data)
 {
 	int rc = 0;
 	int i;
@@ -1209,8 +1164,10 @@ qed_filter_mcast_cmd(struct qed_dev *cdev,
 
 		u16 opaque_fid;
 
-		if (rc != 0)
-			break;
+		if (IS_VF(cdev)) {
+			qed_vf_pf_filter_mcast(p_hwfn, p_filter_cmd);
+			continue;
+		}
 
 		opaque_fid = p_hwfn->hw_info.opaque_fid;
 
@@ -1235,8 +1192,10 @@ static int qed_filter_ucast_cmd(struct qed_dev *cdev,
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 		u16 opaque_fid;
 
-		if (rc != 0)
-			break;
+		if (IS_VF(cdev)) {
+			rc = qed_vf_pf_filter_ucast(p_hwfn, p_filter_cmd);
+			continue;
+		}
 
 		opaque_fid = p_hwfn->hw_info.opaque_fid;
 
@@ -1245,6 +1204,8 @@ static int qed_filter_ucast_cmd(struct qed_dev *cdev,
 					     p_filter_cmd,
 					     comp_mode,
 					     p_comp_data);
+		if (rc != 0)
+			break;
 	}
 
 	return rc;
@@ -1253,12 +1214,19 @@ static int qed_filter_ucast_cmd(struct qed_dev *cdev,
 /* Statistics related code */
 static void __qed_get_vport_pstats_addrlen(struct qed_hwfn *p_hwfn,
 					   u32 *p_addr,
-					   u32 *p_len,
-					   u16 statistics_bin)
+					   u32 *p_len, u16 statistics_bin)
 {
-	*p_addr = BAR0_MAP_REG_PSDM_RAM +
-		  PSTORM_QUEUE_STAT_OFFSET(statistics_bin);
-	*p_len = sizeof(struct eth_pstorm_per_queue_stat);
+	if (IS_PF(p_hwfn->cdev)) {
+		*p_addr = BAR0_MAP_REG_PSDM_RAM +
+		    PSTORM_QUEUE_STAT_OFFSET(statistics_bin);
+		*p_len = sizeof(struct eth_pstorm_per_queue_stat);
+	} else {
+		struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+		struct pfvf_acquire_resp_tlv *p_resp = &p_iov->acquire_resp;
+
+		*p_addr = p_resp->pfdev_info.stats_info.pstats.address;
+		*p_len = p_resp->pfdev_info.stats_info.pstats.len;
+	}
 }
 
 static void __qed_get_vport_pstats(struct qed_hwfn *p_hwfn,
@@ -1273,32 +1241,15 @@ static void __qed_get_vport_pstats(struct qed_hwfn *p_hwfn,
 				       statistics_bin);
 
 	memset(&pstats, 0, sizeof(pstats));
-	qed_memcpy_from(p_hwfn, p_ptt, &pstats,
-			pstats_addr, pstats_len);
-
-	p_stats->tx_ucast_bytes +=
-		HILO_64_REGPAIR(pstats.sent_ucast_bytes);
-	p_stats->tx_mcast_bytes +=
-		HILO_64_REGPAIR(pstats.sent_mcast_bytes);
-	p_stats->tx_bcast_bytes +=
-		HILO_64_REGPAIR(pstats.sent_bcast_bytes);
-	p_stats->tx_ucast_pkts +=
-		HILO_64_REGPAIR(pstats.sent_ucast_pkts);
-	p_stats->tx_mcast_pkts +=
-		HILO_64_REGPAIR(pstats.sent_mcast_pkts);
-	p_stats->tx_bcast_pkts +=
-		HILO_64_REGPAIR(pstats.sent_bcast_pkts);
-	p_stats->tx_err_drop_pkts +=
-		HILO_64_REGPAIR(pstats.error_drop_pkts);
-}
-
-static void __qed_get_vport_tstats_addrlen(struct qed_hwfn *p_hwfn,
-					   u32 *p_addr,
-					   u32 *p_len)
-{
-	*p_addr = BAR0_MAP_REG_TSDM_RAM +
-		  TSTORM_PORT_STAT_OFFSET(MFW_PORT(p_hwfn));
-	*p_len = sizeof(struct tstorm_per_port_stat);
+	qed_memcpy_from(p_hwfn, p_ptt, &pstats, pstats_addr, pstats_len);
+
+	p_stats->tx_ucast_bytes += HILO_64_REGPAIR(pstats.sent_ucast_bytes);
+	p_stats->tx_mcast_bytes += HILO_64_REGPAIR(pstats.sent_mcast_bytes);
+	p_stats->tx_bcast_bytes += HILO_64_REGPAIR(pstats.sent_bcast_bytes);
+	p_stats->tx_ucast_pkts += HILO_64_REGPAIR(pstats.sent_ucast_pkts);
+	p_stats->tx_mcast_pkts += HILO_64_REGPAIR(pstats.sent_mcast_pkts);
+	p_stats->tx_bcast_pkts += HILO_64_REGPAIR(pstats.sent_bcast_pkts);
+	p_stats->tx_err_drop_pkts += HILO_64_REGPAIR(pstats.error_drop_pkts);
 }
 
 static void __qed_get_vport_tstats(struct qed_hwfn *p_hwfn,
@@ -1306,14 +1257,23 @@ static void __qed_get_vport_tstats(struct qed_hwfn *p_hwfn,
 				   struct qed_eth_stats *p_stats,
 				   u16 statistics_bin)
 {
-	u32 tstats_addr = 0, tstats_len = 0;
 	struct tstorm_per_port_stat tstats;
+	u32 tstats_addr, tstats_len;
 
-	__qed_get_vport_tstats_addrlen(p_hwfn, &tstats_addr, &tstats_len);
+	if (IS_PF(p_hwfn->cdev)) {
+		tstats_addr = BAR0_MAP_REG_TSDM_RAM +
+		    TSTORM_PORT_STAT_OFFSET(MFW_PORT(p_hwfn));
+		tstats_len = sizeof(struct tstorm_per_port_stat);
+	} else {
+		struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+		struct pfvf_acquire_resp_tlv *p_resp = &p_iov->acquire_resp;
+
+		tstats_addr = p_resp->pfdev_info.stats_info.tstats.address;
+		tstats_len = p_resp->pfdev_info.stats_info.tstats.len;
+	}
 
 	memset(&tstats, 0, sizeof(tstats));
-	qed_memcpy_from(p_hwfn, p_ptt, &tstats,
-			tstats_addr, tstats_len);
+	qed_memcpy_from(p_hwfn, p_ptt, &tstats, tstats_addr, tstats_len);
 
 	p_stats->mftag_filter_discards +=
 		HILO_64_REGPAIR(tstats.mftag_filter_discard);
@@ -1323,12 +1283,19 @@ static void __qed_get_vport_tstats(struct qed_hwfn *p_hwfn,
 
 static void __qed_get_vport_ustats_addrlen(struct qed_hwfn *p_hwfn,
 					   u32 *p_addr,
-					   u32 *p_len,
-					   u16 statistics_bin)
+					   u32 *p_len, u16 statistics_bin)
 {
-	*p_addr = BAR0_MAP_REG_USDM_RAM +
-		  USTORM_QUEUE_STAT_OFFSET(statistics_bin);
-	*p_len = sizeof(struct eth_ustorm_per_queue_stat);
+	if (IS_PF(p_hwfn->cdev)) {
+		*p_addr = BAR0_MAP_REG_USDM_RAM +
+		    USTORM_QUEUE_STAT_OFFSET(statistics_bin);
+		*p_len = sizeof(struct eth_ustorm_per_queue_stat);
+	} else {
+		struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+		struct pfvf_acquire_resp_tlv *p_resp = &p_iov->acquire_resp;
+
+		*p_addr = p_resp->pfdev_info.stats_info.ustats.address;
+		*p_len = p_resp->pfdev_info.stats_info.ustats.len;
+	}
 }
 
 static void __qed_get_vport_ustats(struct qed_hwfn *p_hwfn,
@@ -1343,31 +1310,31 @@ static void __qed_get_vport_ustats(struct qed_hwfn *p_hwfn,
 				       statistics_bin);
 
 	memset(&ustats, 0, sizeof(ustats));
-	qed_memcpy_from(p_hwfn, p_ptt, &ustats,
-			ustats_addr, ustats_len);
-
-	p_stats->rx_ucast_bytes +=
-		HILO_64_REGPAIR(ustats.rcv_ucast_bytes);
-	p_stats->rx_mcast_bytes +=
-		HILO_64_REGPAIR(ustats.rcv_mcast_bytes);
-	p_stats->rx_bcast_bytes +=
-		HILO_64_REGPAIR(ustats.rcv_bcast_bytes);
-	p_stats->rx_ucast_pkts +=
-		HILO_64_REGPAIR(ustats.rcv_ucast_pkts);
-	p_stats->rx_mcast_pkts +=
-		HILO_64_REGPAIR(ustats.rcv_mcast_pkts);
-	p_stats->rx_bcast_pkts +=
-		HILO_64_REGPAIR(ustats.rcv_bcast_pkts);
+	qed_memcpy_from(p_hwfn, p_ptt, &ustats, ustats_addr, ustats_len);
+
+	p_stats->rx_ucast_bytes += HILO_64_REGPAIR(ustats.rcv_ucast_bytes);
+	p_stats->rx_mcast_bytes += HILO_64_REGPAIR(ustats.rcv_mcast_bytes);
+	p_stats->rx_bcast_bytes += HILO_64_REGPAIR(ustats.rcv_bcast_bytes);
+	p_stats->rx_ucast_pkts += HILO_64_REGPAIR(ustats.rcv_ucast_pkts);
+	p_stats->rx_mcast_pkts += HILO_64_REGPAIR(ustats.rcv_mcast_pkts);
+	p_stats->rx_bcast_pkts += HILO_64_REGPAIR(ustats.rcv_bcast_pkts);
 }
 
 static void __qed_get_vport_mstats_addrlen(struct qed_hwfn *p_hwfn,
 					   u32 *p_addr,
-					   u32 *p_len,
-					   u16 statistics_bin)
+					   u32 *p_len, u16 statistics_bin)
 {
-	*p_addr = BAR0_MAP_REG_MSDM_RAM +
-		  MSTORM_QUEUE_STAT_OFFSET(statistics_bin);
-	*p_len = sizeof(struct eth_mstorm_per_queue_stat);
+	if (IS_PF(p_hwfn->cdev)) {
+		*p_addr = BAR0_MAP_REG_MSDM_RAM +
+		    MSTORM_QUEUE_STAT_OFFSET(statistics_bin);
+		*p_len = sizeof(struct eth_mstorm_per_queue_stat);
+	} else {
+		struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+		struct pfvf_acquire_resp_tlv *p_resp = &p_iov->acquire_resp;
+
+		*p_addr = p_resp->pfdev_info.stats_info.mstats.address;
+		*p_len = p_resp->pfdev_info.stats_info.mstats.len;
+	}
 }
 
 static void __qed_get_vport_mstats(struct qed_hwfn *p_hwfn,
@@ -1382,21 +1349,17 @@ static void __qed_get_vport_mstats(struct qed_hwfn *p_hwfn,
 				       statistics_bin);
 
 	memset(&mstats, 0, sizeof(mstats));
-	qed_memcpy_from(p_hwfn, p_ptt, &mstats,
-			mstats_addr, mstats_len);
+	qed_memcpy_from(p_hwfn, p_ptt, &mstats, mstats_addr, mstats_len);
 
-	p_stats->no_buff_discards +=
-		HILO_64_REGPAIR(mstats.no_buff_discard);
+	p_stats->no_buff_discards += HILO_64_REGPAIR(mstats.no_buff_discard);
 	p_stats->packet_too_big_discard +=
 		HILO_64_REGPAIR(mstats.packet_too_big_discard);
-	p_stats->ttl0_discard +=
-		HILO_64_REGPAIR(mstats.ttl0_discard);
+	p_stats->ttl0_discard += HILO_64_REGPAIR(mstats.ttl0_discard);
 	p_stats->tpa_coalesced_pkts +=
 		HILO_64_REGPAIR(mstats.tpa_coalesced_pkts);
 	p_stats->tpa_coalesced_events +=
 		HILO_64_REGPAIR(mstats.tpa_coalesced_events);
-	p_stats->tpa_aborts_num +=
-		HILO_64_REGPAIR(mstats.tpa_aborts_num);
+	p_stats->tpa_aborts_num += HILO_64_REGPAIR(mstats.tpa_aborts_num);
 	p_stats->tpa_coalesced_bytes +=
 		HILO_64_REGPAIR(mstats.tpa_coalesced_bytes);
 }
@@ -1469,44 +1432,49 @@ static void __qed_get_vport_port_stats(struct qed_hwfn *p_hwfn,
 static void __qed_get_vport_stats(struct qed_hwfn *p_hwfn,
 				  struct qed_ptt *p_ptt,
 				  struct qed_eth_stats *stats,
-				  u16 statistics_bin)
+				  u16 statistics_bin, bool b_get_port_stats)
 {
 	__qed_get_vport_mstats(p_hwfn, p_ptt, stats, statistics_bin);
 	__qed_get_vport_ustats(p_hwfn, p_ptt, stats, statistics_bin);
 	__qed_get_vport_tstats(p_hwfn, p_ptt, stats, statistics_bin);
 	__qed_get_vport_pstats(p_hwfn, p_ptt, stats, statistics_bin);
 
-	if (p_hwfn->mcp_info)
+	if (b_get_port_stats && p_hwfn->mcp_info)
 		__qed_get_vport_port_stats(p_hwfn, p_ptt, stats);
 }
 
 static void _qed_get_vport_stats(struct qed_dev *cdev,
 				 struct qed_eth_stats *stats)
 {
-	u8	fw_vport = 0;
-	int	i;
+	u8 fw_vport = 0;
+	int i;
 
 	memset(stats, 0, sizeof(*stats));
 
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
-		struct qed_ptt *p_ptt;
-
-		/* The main vport index is relative first */
-		if (qed_fw_vport(p_hwfn, 0, &fw_vport)) {
-			DP_ERR(p_hwfn, "No vport available!\n");
-			continue;
+		struct qed_ptt *p_ptt = IS_PF(cdev) ? qed_ptt_acquire(p_hwfn)
+						    :  NULL;
+
+		if (IS_PF(cdev)) {
+			/* The main vport index is relative first */
+			if (qed_fw_vport(p_hwfn, 0, &fw_vport)) {
+				DP_ERR(p_hwfn, "No vport available!\n");
+				goto out;
+			}
 		}
 
-		p_ptt = qed_ptt_acquire(p_hwfn);
-		if (!p_ptt) {
+		if (IS_PF(cdev) && !p_ptt) {
 			DP_ERR(p_hwfn, "Failed to acquire ptt\n");
 			continue;
 		}
 
-		__qed_get_vport_stats(p_hwfn, p_ptt, stats, fw_vport);
+		__qed_get_vport_stats(p_hwfn, p_ptt, stats, fw_vport,
+				      IS_PF(cdev) ? true : false);
 
-		qed_ptt_release(p_hwfn, p_ptt);
+out:
+		if (IS_PF(cdev) && p_ptt)
+			qed_ptt_release(p_hwfn, p_ptt);
 	}
 }
 
@@ -1540,10 +1508,11 @@ void qed_reset_vport_stats(struct qed_dev *cdev)
 		struct eth_mstorm_per_queue_stat mstats;
 		struct eth_ustorm_per_queue_stat ustats;
 		struct eth_pstorm_per_queue_stat pstats;
-		struct qed_ptt *p_ptt = qed_ptt_acquire(p_hwfn);
+		struct qed_ptt *p_ptt = IS_PF(cdev) ? qed_ptt_acquire(p_hwfn)
+						    : NULL;
 		u32 addr = 0, len = 0;
 
-		if (!p_ptt) {
+		if (IS_PF(cdev) && !p_ptt) {
 			DP_ERR(p_hwfn, "Failed to acquire ptt\n");
 			continue;
 		}
@@ -1560,7 +1529,8 @@ void qed_reset_vport_stats(struct qed_dev *cdev)
 		__qed_get_vport_pstats_addrlen(p_hwfn, &addr, &len, 0);
 		qed_memcpy_to(p_hwfn, p_ptt, addr, &pstats, len);
 
-		qed_ptt_release(p_hwfn, p_ptt);
+		if (IS_PF(cdev))
+			qed_ptt_release(p_hwfn, p_ptt);
 	}
 
 	/* PORT statistics are not necessarily reset, so we need to
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.h b/drivers/net/ethernet/qlogic/qed/qed_l2.h
new file mode 100644
index 0000000..3b65a45
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.h
@@ -0,0 +1,178 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+#ifndef _QED_L2_H
+#define _QED_L2_H
+#include <linux/types.h>
+#include <linux/io.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/qed/qed_eth_if.h>
+#include "qed.h"
+#include "qed_hw.h"
+#include "qed_sp.h"
+
+enum qed_filter_opcode {
+	QED_FILTER_ADD,
+	QED_FILTER_REMOVE,
+	QED_FILTER_MOVE,
+	QED_FILTER_REPLACE,	/* Delete all MACs and add new one instead */
+	QED_FILTER_FLUSH,	/* Removes all filters */
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
+	enum qed_filter_opcode opcode;
+	enum qed_filter_ucast_type type;
+	u8 is_rx_filter;
+	u8 is_tx_filter;
+	u8 vport_to_add_to;
+	u8 vport_to_remove_from;
+	unsigned char mac[ETH_ALEN];
+	u8 assert_on_error;
+	u16 vlan;
+	u32 vni;
+};
+
+struct qed_filter_mcast {
+	/* MOVE is not supported for multicast */
+	enum qed_filter_opcode opcode;
+	u8 vport_to_add_to;
+	u8 vport_to_remove_from;
+	u8 num_mc_addrs;
+#define QED_MAX_MC_ADDRS        64
+	unsigned char mac[QED_MAX_MC_ADDRS][ETH_ALEN];
+};
+
+int qed_sp_eth_rx_queue_stop(struct qed_hwfn *p_hwfn,
+			     u16 rx_queue_id,
+			     bool eq_completion_only, bool cqe_completion);
+
+int qed_sp_eth_tx_queue_stop(struct qed_hwfn *p_hwfn, u16 tx_queue_id);
+
+enum qed_tpa_mode {
+	QED_TPA_MODE_NONE,
+	QED_TPA_MODE_UNUSED,
+	QED_TPA_MODE_GRO,
+	QED_TPA_MODE_MAX
+};
+
+struct qed_sp_vport_start_params {
+	enum qed_tpa_mode tpa_mode;
+	bool remove_inner_vlan;
+	bool drop_ttl0;
+	u8 max_buffers_per_cqe;
+	u32 concrete_fid;
+	u16 opaque_fid;
+	u8 vport_id;
+	u16 mtu;
+};
+
+int qed_sp_eth_vport_start(struct qed_hwfn *p_hwfn,
+			   struct qed_sp_vport_start_params *p_params);
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
+	u8				update_accept_any_vlan_flg;
+	u8				accept_any_vlan;
+	unsigned long			bins[8];
+	struct qed_rss_params		*rss_params;
+	struct qed_filter_accept_flags	accept_flags;
+};
+
+int qed_sp_vport_update(struct qed_hwfn *p_hwfn,
+			struct qed_sp_vport_update_params *p_params,
+			enum spq_mode comp_mode,
+			struct qed_spq_comp_cb *p_comp_data);
+
+/**
+ * @brief qed_sp_vport_stop -
+ *
+ * This ramrod closes a VPort after all its RX and TX queues are terminated.
+ * An Assert is generated if any queues are left open.
+ *
+ * @param p_hwfn
+ * @param opaque_fid
+ * @param vport_id VPort ID
+ *
+ * @return int
+ */
+int qed_sp_vport_stop(struct qed_hwfn *p_hwfn, u16 opaque_fid, u8 vport_id);
+
+int qed_sp_eth_filter_ucast(struct qed_hwfn *p_hwfn,
+			    u16 opaque_fid,
+			    struct qed_filter_ucast *p_filter_cmd,
+			    enum spq_mode comp_mode,
+			    struct qed_spq_comp_cb *p_comp_data);
+
+int qed_sp_eth_vport_start(struct qed_hwfn *p_hwfn,
+			   struct qed_sp_vport_start_params *p_params);
+
+int qed_sp_eth_rxq_start_ramrod(struct qed_hwfn *p_hwfn,
+				u16 opaque_fid,
+				u32 cid,
+				struct qed_queue_start_common_params *params,
+				u8 stats_id,
+				u16 bd_max_bytes,
+				dma_addr_t bd_chain_phys_addr,
+				dma_addr_t cqe_pbl_addr, u16 cqe_pbl_size);
+
+int qed_sp_eth_txq_start_ramrod(struct qed_hwfn  *p_hwfn,
+				u16  opaque_fid,
+				u32  cid,
+				struct qed_queue_start_common_params *p_params,
+				u8  stats_id,
+				dma_addr_t pbl_addr,
+				u16 pbl_size,
+				union qed_qm_pq_params *p_pq_params);
+
+u8 qed_mcast_bin_from_mac(u8 *mac);
+
+#endif /* _QED_L2_H */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index 80a6217..bb7dcf1 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -427,6 +427,8 @@
 		0x1 << 0)
 #define  IGU_REG_MAPPING_MEMORY \
 	0x184000UL
+#define IGU_REG_STATISTIC_NUM_VF_MSG_SENT \
+	0x180408UL
 #define  MISCS_REG_GENERIC_POR_0	\
 	0x0096d4UL
 #define  MCP_REG_NVM_CFG4 \
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 750166d..82f1eda3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -6,6 +6,7 @@
  * this source tree.
  */
 
+#include <linux/etherdevice.h>
 #include <linux/qed/qed_iov_if.h>
 #include "qed_cxt.h"
 #include "qed_hsi.h"
@@ -486,6 +487,36 @@ static void qed_iov_vf_pglue_clear_err(struct qed_hwfn *p_hwfn,
 	       1 << (abs_vfid & 0x1f));
 }
 
+static void qed_iov_vf_igu_reset(struct qed_hwfn *p_hwfn,
+				 struct qed_ptt *p_ptt, struct qed_vf_info *vf)
+{
+	u16 igu_sb_id;
+	int i;
+
+	/* Set VF masks and configuration - pretend */
+	qed_fid_pretend(p_hwfn, p_ptt, (u16) vf->concrete_fid);
+
+	qed_wr(p_hwfn, p_ptt, IGU_REG_STATISTIC_NUM_VF_MSG_SENT, 0);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+		   "value in VF_CONFIGURATION of vf %d after write %x\n",
+		   vf->abs_vf_id,
+		   qed_rd(p_hwfn, p_ptt, IGU_REG_VF_CONFIGURATION));
+
+	/* unpretend */
+	qed_fid_pretend(p_hwfn, p_ptt, (u16) p_hwfn->hw_info.concrete_fid);
+
+	/* iterate over all queues, clear sb consumer */
+	for (i = 0; i < vf->num_sbs; i++) {
+		igu_sb_id = vf->igu_sbs[i];
+		/* Set then clear... */
+		qed_int_igu_cleanup_sb(p_hwfn, p_ptt, igu_sb_id, 1,
+				       vf->opaque_fid);
+		qed_int_igu_cleanup_sb(p_hwfn, p_ptt, igu_sb_id, 0,
+				       vf->opaque_fid);
+	}
+}
+
 static void qed_iov_vf_igu_set_int(struct qed_hwfn *p_hwfn,
 				   struct qed_ptt *p_ptt,
 				   struct qed_vf_info *vf, bool enable)
@@ -585,6 +616,19 @@ static void qed_iov_config_perm_table(struct qed_hwfn *p_hwfn,
 	}
 }
 
+static void qed_iov_enable_vf_traffic(struct qed_hwfn *p_hwfn,
+				      struct qed_ptt *p_ptt,
+				      struct qed_vf_info *vf)
+{
+	/* Reset vf in IGU - interrupts are still disabled */
+	qed_iov_vf_igu_reset(p_hwfn, p_ptt, vf);
+
+	qed_iov_vf_igu_set_int(p_hwfn, p_ptt, vf, 1);
+
+	/* Permission Table */
+	qed_iov_config_perm_table(p_hwfn, p_ptt, vf, true);
+}
+
 static u8 qed_iov_alloc_vf_igu_sbs(struct qed_hwfn *p_hwfn,
 				   struct qed_ptt *p_ptt,
 				   struct qed_vf_info *vf, u16 num_rx_queues)
@@ -870,6 +914,67 @@ static void qed_iov_send_response(struct qed_hwfn *p_hwfn,
 	       USTORM_VF_PF_CHANNEL_READY_OFFSET(eng_vf_id), 1);
 }
 
+static u16 qed_iov_vport_to_tlv(struct qed_hwfn *p_hwfn,
+				enum qed_iov_vport_update_flag flag)
+{
+	switch (flag) {
+	case QED_IOV_VP_UPDATE_ACTIVATE:
+		return CHANNEL_TLV_VPORT_UPDATE_ACTIVATE;
+	case QED_IOV_VP_UPDATE_MCAST:
+		return CHANNEL_TLV_VPORT_UPDATE_MCAST;
+	case QED_IOV_VP_UPDATE_ACCEPT_PARAM:
+		return CHANNEL_TLV_VPORT_UPDATE_ACCEPT_PARAM;
+	case QED_IOV_VP_UPDATE_RSS:
+		return CHANNEL_TLV_VPORT_UPDATE_RSS;
+	default:
+		return 0;
+	}
+}
+
+static u16 qed_iov_prep_vp_update_resp_tlvs(struct qed_hwfn *p_hwfn,
+					    struct qed_vf_info *p_vf,
+					    struct qed_iov_vf_mbx *p_mbx,
+					    u8 status,
+					    u16 tlvs_mask, u16 tlvs_accepted)
+{
+	struct pfvf_def_resp_tlv *resp;
+	u16 size, total_len, i;
+
+	memset(p_mbx->reply_virt, 0, sizeof(union pfvf_tlvs));
+	p_mbx->offset = (u8 *)p_mbx->reply_virt;
+	size = sizeof(struct pfvf_def_resp_tlv);
+	total_len = size;
+
+	qed_add_tlv(p_hwfn, &p_mbx->offset, CHANNEL_TLV_VPORT_UPDATE, size);
+
+	/* Prepare response for all extended tlvs if they are found by PF */
+	for (i = 0; i < QED_IOV_VP_UPDATE_MAX; i++) {
+		if (!(tlvs_mask & (1 << i)))
+			continue;
+
+		resp = qed_add_tlv(p_hwfn, &p_mbx->offset,
+				   qed_iov_vport_to_tlv(p_hwfn, i), size);
+
+		if (tlvs_accepted & (1 << i))
+			resp->hdr.status = status;
+		else
+			resp->hdr.status = PFVF_STATUS_NOT_SUPPORTED;
+
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_IOV,
+			   "VF[%d] - vport_update response: TLV %d, status %02x\n",
+			   p_vf->relative_vf_id,
+			   qed_iov_vport_to_tlv(p_hwfn, i), resp->hdr.status);
+
+		total_len += size;
+	}
+
+	qed_add_tlv(p_hwfn, &p_mbx->offset, CHANNEL_TLV_LIST_END,
+		    sizeof(struct channel_list_end_tlv));
+
+	return total_len;
+}
+
 static void qed_iov_prepare_resp(struct qed_hwfn *p_hwfn,
 				 struct qed_ptt *p_ptt,
 				 struct qed_vf_info *vf_info,
@@ -918,6 +1023,7 @@ static void qed_iov_vf_cleanup(struct qed_hwfn *p_hwfn,
 	u32 i;
 
 	p_vf->vf_bulletin = 0;
+	p_vf->vport_instance = 0;
 	p_vf->num_mac_filters = 0;
 	p_vf->num_vlan_filters = 0;
 
@@ -925,6 +1031,8 @@ static void qed_iov_vf_cleanup(struct qed_hwfn *p_hwfn,
 	p_vf->num_rxqs = p_vf->num_sbs;
 	p_vf->num_txqs = p_vf->num_sbs;
 
+	p_vf->num_active_rxqs = 0;
+
 	for (i = 0; i < QED_MAX_VF_CHAINS_PER_PF; i++)
 		p_vf->vf_queues[i].rxq_active = 0;
 
@@ -1074,6 +1182,578 @@ out:
 			     sizeof(struct pfvf_acquire_resp_tlv), vfpf_status);
 }
 
+static void qed_iov_vf_mbx_start_vport(struct qed_hwfn *p_hwfn,
+				       struct qed_ptt *p_ptt,
+				       struct qed_vf_info *vf)
+{
+	struct qed_sp_vport_start_params params = { 0 };
+	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
+	struct vfpf_vport_start_tlv *start;
+	u8 status = PFVF_STATUS_SUCCESS;
+	struct qed_vf_info *vf_info;
+	int sb_id;
+	int rc;
+
+	vf_info = qed_iov_get_vf_info(p_hwfn, (u16) vf->relative_vf_id, true);
+	if (!vf_info) {
+		DP_NOTICE(p_hwfn->cdev,
+			  "Failed to get VF info, invalid vfid [%d]\n",
+			  vf->relative_vf_id);
+		return;
+	}
+
+	vf->state = VF_ENABLED;
+	start = &mbx->req_virt->start_vport;
+
+	/* Initialize Status block in CAU */
+	for (sb_id = 0; sb_id < vf->num_sbs; sb_id++) {
+		if (!start->sb_addr[sb_id]) {
+			DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+				   "VF[%d] did not fill the address of SB %d\n",
+				   vf->relative_vf_id, sb_id);
+			break;
+		}
+
+		qed_int_cau_conf_sb(p_hwfn, p_ptt,
+				    start->sb_addr[sb_id],
+				    vf->igu_sbs[sb_id],
+				    vf->abs_vf_id, 1);
+	}
+	qed_iov_enable_vf_traffic(p_hwfn, p_ptt, vf);
+
+	vf->mtu = start->mtu;
+
+	params.tpa_mode = start->tpa_mode;
+	params.remove_inner_vlan = start->inner_vlan_removal;
+
+	params.drop_ttl0 = false;
+	params.concrete_fid = vf->concrete_fid;
+	params.opaque_fid = vf->opaque_fid;
+	params.vport_id = vf->vport_id;
+	params.max_buffers_per_cqe = start->max_buffers_per_cqe;
+	params.mtu = vf->mtu;
+
+	rc = qed_sp_eth_vport_start(p_hwfn, &params);
+	if (rc != 0) {
+		DP_ERR(p_hwfn,
+		       "qed_iov_vf_mbx_start_vport returned error %d\n", rc);
+		status = PFVF_STATUS_FAILURE;
+	} else {
+		vf->vport_instance++;
+	}
+	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_VPORT_START,
+			     sizeof(struct pfvf_def_resp_tlv), status);
+}
+
+static void qed_iov_vf_mbx_stop_vport(struct qed_hwfn *p_hwfn,
+				      struct qed_ptt *p_ptt,
+				      struct qed_vf_info *vf)
+{
+	u8 status = PFVF_STATUS_SUCCESS;
+	int rc;
+
+	vf->vport_instance--;
+
+	rc = qed_sp_vport_stop(p_hwfn, vf->opaque_fid, vf->vport_id);
+	if (rc != 0) {
+		DP_ERR(p_hwfn, "qed_iov_vf_mbx_stop_vport returned error %d\n",
+		       rc);
+		status = PFVF_STATUS_FAILURE;
+	}
+
+	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_VPORT_TEARDOWN,
+			     sizeof(struct pfvf_def_resp_tlv), status);
+}
+
+#define TSTORM_QZONE_START   PXP_VF_BAR0_START_SDM_ZONE_A
+#define MSTORM_QZONE_START(dev)   (TSTORM_QZONE_START +	\
+				   (TSTORM_QZONE_SIZE * NUM_OF_L2_QUEUES(dev)))
+
+static void qed_iov_vf_mbx_start_rxq_resp(struct qed_hwfn *p_hwfn,
+					  struct qed_ptt *p_ptt,
+					  struct qed_vf_info *vf, u8 status)
+{
+	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
+	struct pfvf_start_queue_resp_tlv *p_tlv;
+	struct vfpf_start_rxq_tlv *req;
+
+	mbx->offset = (u8 *)mbx->reply_virt;
+
+	p_tlv = qed_add_tlv(p_hwfn, &mbx->offset, CHANNEL_TLV_START_RXQ,
+			    sizeof(*p_tlv));
+	qed_add_tlv(p_hwfn, &mbx->offset, CHANNEL_TLV_LIST_END,
+		    sizeof(struct channel_list_end_tlv));
+
+	/* Update the TLV with the response */
+	if (status == PFVF_STATUS_SUCCESS) {
+		u16 hw_qid = 0;
+
+		req = &mbx->req_virt->start_rxq;
+		qed_fw_l2_queue(p_hwfn, vf->vf_queues[req->rx_qid].fw_rx_qid,
+				&hw_qid);
+
+		p_tlv->offset = MSTORM_QZONE_START(p_hwfn->cdev) +
+				hw_qid * MSTORM_QZONE_SIZE +
+				offsetof(struct mstorm_eth_queue_zone,
+					 rx_producers);
+	}
+
+	qed_iov_send_response(p_hwfn, p_ptt, vf, sizeof(*p_tlv), status);
+}
+
+static void qed_iov_vf_mbx_start_rxq(struct qed_hwfn *p_hwfn,
+				     struct qed_ptt *p_ptt,
+				     struct qed_vf_info *vf)
+{
+	struct qed_queue_start_common_params params;
+	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
+	u8 status = PFVF_STATUS_SUCCESS;
+	struct vfpf_start_rxq_tlv *req;
+	int rc;
+
+	memset(&params, 0, sizeof(params));
+	req = &mbx->req_virt->start_rxq;
+	params.queue_id =  vf->vf_queues[req->rx_qid].fw_rx_qid;
+	params.vport_id = vf->vport_id;
+	params.sb = req->hw_sb;
+	params.sb_idx = req->sb_index;
+
+	rc = qed_sp_eth_rxq_start_ramrod(p_hwfn, vf->opaque_fid,
+					 vf->vf_queues[req->rx_qid].fw_cid,
+					 &params,
+					 vf->abs_vf_id + 0x10,
+					 req->bd_max_bytes,
+					 req->rxq_addr,
+					 req->cqe_pbl_addr, req->cqe_pbl_size);
+
+	if (rc) {
+		status = PFVF_STATUS_FAILURE;
+	} else {
+		vf->vf_queues[req->rx_qid].rxq_active = true;
+		vf->num_active_rxqs++;
+	}
+
+	qed_iov_vf_mbx_start_rxq_resp(p_hwfn, p_ptt, vf, status);
+}
+
+static void qed_iov_vf_mbx_start_txq(struct qed_hwfn *p_hwfn,
+				     struct qed_ptt *p_ptt,
+				     struct qed_vf_info *vf)
+{
+	u16 length = sizeof(struct pfvf_def_resp_tlv);
+	struct qed_queue_start_common_params params;
+	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
+	union qed_qm_pq_params pq_params;
+	u8 status = PFVF_STATUS_SUCCESS;
+	struct vfpf_start_txq_tlv *req;
+	int rc;
+
+	/* Prepare the parameters which would choose the right PQ */
+	memset(&pq_params, 0, sizeof(pq_params));
+	pq_params.eth.is_vf = 1;
+	pq_params.eth.vf_id = vf->relative_vf_id;
+
+	memset(&params, 0, sizeof(params));
+	req = &mbx->req_virt->start_txq;
+	params.queue_id =  vf->vf_queues[req->tx_qid].fw_tx_qid;
+	params.vport_id = vf->vport_id;
+	params.sb = req->hw_sb;
+	params.sb_idx = req->sb_index;
+
+	rc = qed_sp_eth_txq_start_ramrod(p_hwfn,
+					 vf->opaque_fid,
+					 vf->vf_queues[req->tx_qid].fw_cid,
+					 &params,
+					 vf->abs_vf_id + 0x10,
+					 req->pbl_addr,
+					 req->pbl_size, &pq_params);
+
+	if (rc)
+		status = PFVF_STATUS_FAILURE;
+	else
+		vf->vf_queues[req->tx_qid].txq_active = true;
+
+	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_START_TXQ,
+			     length, status);
+}
+
+static int qed_iov_vf_stop_rxqs(struct qed_hwfn *p_hwfn,
+				struct qed_vf_info *vf,
+				u16 rxq_id, u8 num_rxqs, bool cqe_completion)
+{
+	int rc = 0;
+	int qid;
+
+	if (rxq_id + num_rxqs > ARRAY_SIZE(vf->vf_queues))
+		return -EINVAL;
+
+	for (qid = rxq_id; qid < rxq_id + num_rxqs; qid++) {
+		if (vf->vf_queues[qid].rxq_active) {
+			rc = qed_sp_eth_rx_queue_stop(p_hwfn,
+						      vf->vf_queues[qid].
+						      fw_rx_qid, false,
+						      cqe_completion);
+
+			if (rc)
+				return rc;
+		}
+		vf->vf_queues[qid].rxq_active = false;
+		vf->num_active_rxqs--;
+	}
+
+	return rc;
+}
+
+static int qed_iov_vf_stop_txqs(struct qed_hwfn *p_hwfn,
+				struct qed_vf_info *vf, u16 txq_id, u8 num_txqs)
+{
+	int rc = 0;
+	int qid;
+
+	if (txq_id + num_txqs > ARRAY_SIZE(vf->vf_queues))
+		return -EINVAL;
+
+	for (qid = txq_id; qid < txq_id + num_txqs; qid++) {
+		if (vf->vf_queues[qid].txq_active) {
+			rc = qed_sp_eth_tx_queue_stop(p_hwfn,
+						      vf->vf_queues[qid].
+						      fw_tx_qid);
+
+			if (rc)
+				return rc;
+		}
+		vf->vf_queues[qid].txq_active = false;
+	}
+	return rc;
+}
+
+static void qed_iov_vf_mbx_stop_rxqs(struct qed_hwfn *p_hwfn,
+				     struct qed_ptt *p_ptt,
+				     struct qed_vf_info *vf)
+{
+	u16 length = sizeof(struct pfvf_def_resp_tlv);
+	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
+	u8 status = PFVF_STATUS_SUCCESS;
+	struct vfpf_stop_rxqs_tlv *req;
+	int rc;
+
+	/* We give the option of starting from qid != 0, in this case we
+	 * need to make sure that qid + num_qs doesn't exceed the actual
+	 * amount of queues that exist.
+	 */
+	req = &mbx->req_virt->stop_rxqs;
+	rc = qed_iov_vf_stop_rxqs(p_hwfn, vf, req->rx_qid,
+				  req->num_rxqs, req->cqe_completion);
+	if (rc)
+		status = PFVF_STATUS_FAILURE;
+
+	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_STOP_RXQS,
+			     length, status);
+}
+
+static void qed_iov_vf_mbx_stop_txqs(struct qed_hwfn *p_hwfn,
+				     struct qed_ptt *p_ptt,
+				     struct qed_vf_info *vf)
+{
+	u16 length = sizeof(struct pfvf_def_resp_tlv);
+	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
+	u8 status = PFVF_STATUS_SUCCESS;
+	struct vfpf_stop_txqs_tlv *req;
+	int rc;
+
+	/* We give the option of starting from qid != 0, in this case we
+	 * need to make sure that qid + num_qs doesn't exceed the actual
+	 * amount of queues that exist.
+	 */
+	req = &mbx->req_virt->stop_txqs;
+	rc = qed_iov_vf_stop_txqs(p_hwfn, vf, req->tx_qid, req->num_txqs);
+	if (rc)
+		status = PFVF_STATUS_FAILURE;
+
+	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_STOP_TXQS,
+			     length, status);
+}
+
+void *qed_iov_search_list_tlvs(struct qed_hwfn *p_hwfn,
+			       void *p_tlvs_list, u16 req_type)
+{
+	struct channel_tlv *p_tlv = (struct channel_tlv *)p_tlvs_list;
+	int len = 0;
+
+	do {
+		if (!p_tlv->length) {
+			DP_NOTICE(p_hwfn, "Zero length TLV found\n");
+			return NULL;
+		}
+
+		if (p_tlv->type == req_type) {
+			DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+				   "Extended tlv type %d, length %d found\n",
+				   p_tlv->type, p_tlv->length);
+			return p_tlv;
+		}
+
+		len += p_tlv->length;
+		p_tlv = (struct channel_tlv *)((u8 *)p_tlv + p_tlv->length);
+
+		if ((len + p_tlv->length) > TLV_BUFFER_SIZE) {
+			DP_NOTICE(p_hwfn, "TLVs has overrun the buffer size\n");
+			return NULL;
+		}
+	} while (p_tlv->type != CHANNEL_TLV_LIST_END);
+
+	return NULL;
+}
+
+static void
+qed_iov_vp_update_act_param(struct qed_hwfn *p_hwfn,
+			    struct qed_sp_vport_update_params *p_data,
+			    struct qed_iov_vf_mbx *p_mbx, u16 *tlvs_mask)
+{
+	struct vfpf_vport_update_activate_tlv *p_act_tlv;
+	u16 tlv = CHANNEL_TLV_VPORT_UPDATE_ACTIVATE;
+
+	p_act_tlv = (struct vfpf_vport_update_activate_tlv *)
+		    qed_iov_search_list_tlvs(p_hwfn, p_mbx->req_virt, tlv);
+	if (!p_act_tlv)
+		return;
+
+	p_data->update_vport_active_rx_flg = p_act_tlv->update_rx;
+	p_data->vport_active_rx_flg = p_act_tlv->active_rx;
+	p_data->update_vport_active_tx_flg = p_act_tlv->update_tx;
+	p_data->vport_active_tx_flg = p_act_tlv->active_tx;
+	*tlvs_mask |= 1 << QED_IOV_VP_UPDATE_ACTIVATE;
+}
+
+static void
+qed_iov_vp_update_mcast_bin_param(struct qed_hwfn *p_hwfn,
+				  struct qed_sp_vport_update_params *p_data,
+				  struct qed_iov_vf_mbx *p_mbx, u16 *tlvs_mask)
+{
+	struct vfpf_vport_update_mcast_bin_tlv *p_mcast_tlv;
+	u16 tlv = CHANNEL_TLV_VPORT_UPDATE_MCAST;
+
+	p_mcast_tlv = (struct vfpf_vport_update_mcast_bin_tlv *)
+	    qed_iov_search_list_tlvs(p_hwfn, p_mbx->req_virt, tlv);
+	if (!p_mcast_tlv)
+		return;
+
+	p_data->update_approx_mcast_flg = 1;
+	memcpy(p_data->bins, p_mcast_tlv->bins,
+	       sizeof(unsigned long) * ETH_MULTICAST_MAC_BINS_IN_REGS);
+	*tlvs_mask |= 1 << QED_IOV_VP_UPDATE_MCAST;
+}
+
+static void
+qed_iov_vp_update_accept_flag(struct qed_hwfn *p_hwfn,
+			      struct qed_sp_vport_update_params *p_data,
+			      struct qed_iov_vf_mbx *p_mbx, u16 *tlvs_mask)
+{
+	struct qed_filter_accept_flags *p_flags = &p_data->accept_flags;
+	struct vfpf_vport_update_accept_param_tlv *p_accept_tlv;
+	u16 tlv = CHANNEL_TLV_VPORT_UPDATE_ACCEPT_PARAM;
+
+	p_accept_tlv = (struct vfpf_vport_update_accept_param_tlv *)
+	    qed_iov_search_list_tlvs(p_hwfn, p_mbx->req_virt, tlv);
+	if (!p_accept_tlv)
+		return;
+
+	p_flags->update_rx_mode_config = p_accept_tlv->update_rx_mode;
+	p_flags->rx_accept_filter = p_accept_tlv->rx_accept_filter;
+	p_flags->update_tx_mode_config = p_accept_tlv->update_tx_mode;
+	p_flags->tx_accept_filter = p_accept_tlv->tx_accept_filter;
+	*tlvs_mask |= 1 << QED_IOV_VP_UPDATE_ACCEPT_PARAM;
+}
+
+static void
+qed_iov_vp_update_rss_param(struct qed_hwfn *p_hwfn,
+			    struct qed_vf_info *vf,
+			    struct qed_sp_vport_update_params *p_data,
+			    struct qed_rss_params *p_rss,
+			    struct qed_iov_vf_mbx *p_mbx, u16 *tlvs_mask)
+{
+	struct vfpf_vport_update_rss_tlv *p_rss_tlv;
+	u16 tlv = CHANNEL_TLV_VPORT_UPDATE_RSS;
+	u16 i, q_idx, max_q_idx;
+	u16 table_size;
+
+	p_rss_tlv = (struct vfpf_vport_update_rss_tlv *)
+		    qed_iov_search_list_tlvs(p_hwfn, p_mbx->req_virt, tlv);
+	if (!p_rss_tlv) {
+		p_data->rss_params = NULL;
+		return;
+	}
+
+	memset(p_rss, 0, sizeof(struct qed_rss_params));
+
+	p_rss->update_rss_config = !!(p_rss_tlv->update_rss_flags &
+				      VFPF_UPDATE_RSS_CONFIG_FLAG);
+	p_rss->update_rss_capabilities = !!(p_rss_tlv->update_rss_flags &
+					    VFPF_UPDATE_RSS_CAPS_FLAG);
+	p_rss->update_rss_ind_table = !!(p_rss_tlv->update_rss_flags &
+					 VFPF_UPDATE_RSS_IND_TABLE_FLAG);
+	p_rss->update_rss_key = !!(p_rss_tlv->update_rss_flags &
+				   VFPF_UPDATE_RSS_KEY_FLAG);
+
+	p_rss->rss_enable = p_rss_tlv->rss_enable;
+	p_rss->rss_eng_id = vf->relative_vf_id + 1;
+	p_rss->rss_caps = p_rss_tlv->rss_caps;
+	p_rss->rss_table_size_log = p_rss_tlv->rss_table_size_log;
+	memcpy(p_rss->rss_ind_table, p_rss_tlv->rss_ind_table,
+	       sizeof(p_rss->rss_ind_table));
+	memcpy(p_rss->rss_key, p_rss_tlv->rss_key, sizeof(p_rss->rss_key));
+
+	table_size = min_t(u16, ARRAY_SIZE(p_rss->rss_ind_table),
+			   (1 << p_rss_tlv->rss_table_size_log));
+
+	max_q_idx = ARRAY_SIZE(vf->vf_queues);
+
+	for (i = 0; i < table_size; i++) {
+		u16 index = vf->vf_queues[0].fw_rx_qid;
+
+		q_idx = p_rss->rss_ind_table[i];
+		if (q_idx >= max_q_idx)
+			DP_NOTICE(p_hwfn,
+				  "rss_ind_table[%d] = %d, rxq is out of range\n",
+				  i, q_idx);
+		else if (!vf->vf_queues[q_idx].rxq_active)
+			DP_NOTICE(p_hwfn,
+				  "rss_ind_table[%d] = %d, rxq is not active\n",
+				  i, q_idx);
+		else
+			index = vf->vf_queues[q_idx].fw_rx_qid;
+		p_rss->rss_ind_table[i] = index;
+	}
+
+	p_data->rss_params = p_rss;
+	*tlvs_mask |= 1 << QED_IOV_VP_UPDATE_RSS;
+}
+
+static void qed_iov_vf_mbx_vport_update(struct qed_hwfn *p_hwfn,
+					struct qed_ptt *p_ptt,
+					struct qed_vf_info *vf)
+{
+	struct qed_sp_vport_update_params params;
+	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
+	struct qed_rss_params rss_params;
+	u8 status = PFVF_STATUS_SUCCESS;
+	u16 tlvs_mask = 0;
+	u16 length;
+	int rc;
+
+	memset(&params, 0, sizeof(params));
+	params.opaque_fid = vf->opaque_fid;
+	params.vport_id = vf->vport_id;
+	params.rss_params = NULL;
+
+	/* Search for extended tlvs list and update values
+	 * from VF in struct qed_sp_vport_update_params.
+	 */
+	qed_iov_vp_update_act_param(p_hwfn, &params, mbx, &tlvs_mask);
+	qed_iov_vp_update_mcast_bin_param(p_hwfn, &params, mbx, &tlvs_mask);
+	qed_iov_vp_update_accept_flag(p_hwfn, &params, mbx, &tlvs_mask);
+	qed_iov_vp_update_rss_param(p_hwfn, vf, &params, &rss_params,
+				    mbx, &tlvs_mask);
+
+	/* Just log a message if there is no single extended tlv in buffer.
+	 * When all features of vport update ramrod would be requested by VF
+	 * as extended TLVs in buffer then an error can be returned in response
+	 * if there is no extended TLV present in buffer.
+	 */
+	if (!tlvs_mask) {
+		DP_NOTICE(p_hwfn,
+			  "No feature tlvs found for vport update\n");
+		status = PFVF_STATUS_NOT_SUPPORTED;
+		goto out;
+	}
+
+	rc = qed_sp_vport_update(p_hwfn, &params, QED_SPQ_MODE_EBLOCK, NULL);
+
+	if (rc)
+		status = PFVF_STATUS_FAILURE;
+
+out:
+	length = qed_iov_prep_vp_update_resp_tlvs(p_hwfn, vf, mbx, status,
+						  tlvs_mask, tlvs_mask);
+	qed_iov_send_response(p_hwfn, p_ptt, vf, length, status);
+}
+
+int qed_iov_chk_ucast(struct qed_hwfn *hwfn,
+		      int vfid, struct qed_filter_ucast *params)
+{
+	struct qed_public_vf_info *vf;
+
+	vf = qed_iov_get_public_vf_info(hwfn, vfid, true);
+	if (!vf)
+		return -EINVAL;
+
+	/* No real decision to make; Store the configured MAC */
+	if (params->type == QED_FILTER_MAC ||
+	    params->type == QED_FILTER_MAC_VLAN)
+		ether_addr_copy(vf->mac, params->mac);
+
+	return 0;
+}
+
+static void qed_iov_vf_mbx_ucast_filter(struct qed_hwfn *p_hwfn,
+					struct qed_ptt *p_ptt,
+					struct qed_vf_info *vf)
+{
+	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
+	struct vfpf_ucast_filter_tlv *req;
+	u8 status = PFVF_STATUS_SUCCESS;
+	struct qed_filter_ucast params;
+	int rc;
+
+	/* Prepare the unicast filter params */
+	memset(&params, 0, sizeof(struct qed_filter_ucast));
+	req = &mbx->req_virt->ucast_filter;
+	params.opcode = (enum qed_filter_opcode)req->opcode;
+	params.type = (enum qed_filter_ucast_type)req->type;
+
+	params.is_rx_filter = 1;
+	params.is_tx_filter = 1;
+	params.vport_to_remove_from = vf->vport_id;
+	params.vport_to_add_to = vf->vport_id;
+	memcpy(params.mac, req->mac, ETH_ALEN);
+	params.vlan = req->vlan;
+
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_IOV,
+		   "VF[%d]: opcode 0x%02x type 0x%02x [%s %s] [vport 0x%02x] MAC %02x:%02x:%02x:%02x:%02x:%02x, vlan 0x%04x\n",
+		   vf->abs_vf_id, params.opcode, params.type,
+		   params.is_rx_filter ? "RX" : "",
+		   params.is_tx_filter ? "TX" : "",
+		   params.vport_to_add_to,
+		   params.mac[0], params.mac[1],
+		   params.mac[2], params.mac[3],
+		   params.mac[4], params.mac[5], params.vlan);
+
+	if (!vf->vport_instance) {
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_IOV,
+			   "No VPORT instance available for VF[%d], failing ucast MAC configuration\n",
+			   vf->abs_vf_id);
+		status = PFVF_STATUS_FAILURE;
+		goto out;
+	}
+
+	rc = qed_iov_chk_ucast(p_hwfn, vf->relative_vf_id, &params);
+	if (rc) {
+		status = PFVF_STATUS_FAILURE;
+		goto out;
+	}
+
+	rc = qed_sp_eth_filter_ucast(p_hwfn, vf->opaque_fid, &params,
+				     QED_SPQ_MODE_CB, NULL);
+	if (rc)
+		status = PFVF_STATUS_FAILURE;
+
+out:
+	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_UCAST_FILTER,
+			     sizeof(struct pfvf_def_resp_tlv), status);
+}
+
 static void qed_iov_vf_mbx_int_cleanup(struct qed_hwfn *p_hwfn,
 				       struct qed_ptt *p_ptt,
 				       struct qed_vf_info *vf)
@@ -1365,6 +2045,30 @@ static void qed_iov_process_mbx_req(struct qed_hwfn *p_hwfn,
 		case CHANNEL_TLV_ACQUIRE:
 			qed_iov_vf_mbx_acquire(p_hwfn, p_ptt, p_vf);
 			break;
+		case CHANNEL_TLV_VPORT_START:
+			qed_iov_vf_mbx_start_vport(p_hwfn, p_ptt, p_vf);
+			break;
+		case CHANNEL_TLV_VPORT_TEARDOWN:
+			qed_iov_vf_mbx_stop_vport(p_hwfn, p_ptt, p_vf);
+			break;
+		case CHANNEL_TLV_START_RXQ:
+			qed_iov_vf_mbx_start_rxq(p_hwfn, p_ptt, p_vf);
+			break;
+		case CHANNEL_TLV_START_TXQ:
+			qed_iov_vf_mbx_start_txq(p_hwfn, p_ptt, p_vf);
+			break;
+		case CHANNEL_TLV_STOP_RXQS:
+			qed_iov_vf_mbx_stop_rxqs(p_hwfn, p_ptt, p_vf);
+			break;
+		case CHANNEL_TLV_STOP_TXQS:
+			qed_iov_vf_mbx_stop_txqs(p_hwfn, p_ptt, p_vf);
+			break;
+		case CHANNEL_TLV_VPORT_UPDATE:
+			qed_iov_vf_mbx_vport_update(p_hwfn, p_ptt, p_vf);
+			break;
+		case CHANNEL_TLV_UCAST_FILTER:
+			qed_iov_vf_mbx_ucast_filter(p_hwfn, p_ptt, p_vf);
+			break;
 		case CHANNEL_TLV_CLOSE:
 			qed_iov_vf_mbx_close(p_hwfn, p_ptt, p_vf);
 			break;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index 10794b0..63bce9c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -24,6 +24,14 @@
 #define QED_MAX_VF_CHAINS_PER_PF 16
 #define QED_ETH_VF_NUM_VLAN_FILTERS 2
 
+enum qed_iov_vport_update_flag {
+	QED_IOV_VP_UPDATE_ACTIVATE,
+	QED_IOV_VP_UPDATE_MCAST,
+	QED_IOV_VP_UPDATE_ACCEPT_PARAM,
+	QED_IOV_VP_UPDATE_RSS,
+	QED_IOV_VP_UPDATE_MAX,
+};
+
 struct qed_public_vf_info {
 	/* These copies will later be reflected in the bulletin board,
 	 * but this copy should be newer.
@@ -81,6 +89,7 @@ struct qed_vf_q_info {
 enum vf_state {
 	VF_FREE = 0,		/* VF ready to be acquired holds no resc */
 	VF_ACQUIRED,		/* VF, acquired, but not initalized */
+	VF_ENABLED,		/* VF, Enabled */
 	VF_RESET,		/* VF, FLR'd, pending cleanup */
 	VF_STOPPED		/* VF, Stopped */
 };
@@ -97,6 +106,7 @@ struct qed_vf_info {
 
 	u32 concrete_fid;
 	u16 opaque_fid;
+	u16 mtu;
 
 	u8 vport_id;
 	u8 relative_vf_id;
@@ -105,6 +115,7 @@ struct qed_vf_info {
 					 (p_vf)->abs_vf_id + MAX_NUM_VFS_BB : \
 					 (p_vf)->abs_vf_id)
 
+	u8 vport_instance;
 	u8 num_rxqs;
 	u8 num_txqs;
 
@@ -114,6 +125,7 @@ struct qed_vf_info {
 	u8 num_vlan_filters;
 	struct qed_vf_q_info vf_queues[QED_MAX_VF_CHAINS_PER_PF];
 	u16 igu_sbs[QED_MAX_VF_CHAINS_PER_PF];
+	u8 num_active_rxqs;
 	struct qed_public_vf_info p_vf_info;
 };
 
@@ -238,6 +250,18 @@ int qed_sriov_eqe_event(struct qed_hwfn *p_hwfn,
  */
 int qed_iov_mark_vf_flr(struct qed_hwfn *p_hwfn, u32 *disabled_vfs);
 
+/**
+ * @brief Search extended TLVs in request/reply buffer.
+ *
+ * @param p_hwfn
+ * @param p_tlvs_list - Pointer to tlvs list
+ * @param req_type - Type of TLV
+ *
+ * @return pointer to tlv type if found, otherwise returns NULL.
+ */
+void *qed_iov_search_list_tlvs(struct qed_hwfn *p_hwfn,
+			       void *p_tlvs_list, u16 req_type);
+
 void qed_iov_wq_stop(struct qed_dev *cdev, bool schedule_first);
 int qed_iov_wq_start(struct qed_dev *cdev);
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index 2460e39..961de77 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -311,6 +311,400 @@ free_p_iov:
 	return -ENOMEM;
 }
 
+int qed_vf_pf_rxq_start(struct qed_hwfn *p_hwfn,
+			u8 rx_qid,
+			u16 sb,
+			u8 sb_index,
+			u16 bd_max_bytes,
+			dma_addr_t bd_chain_phys_addr,
+			dma_addr_t cqe_pbl_addr,
+			u16 cqe_pbl_size, void __iomem **pp_prod)
+{
+	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+	struct pfvf_start_queue_resp_tlv *resp;
+	struct vfpf_start_rxq_tlv *req;
+	int rc;
+
+	/* clear mailbox and prep first tlv */
+	req = qed_vf_pf_prep(p_hwfn, CHANNEL_TLV_START_RXQ, sizeof(*req));
+
+	req->rx_qid = rx_qid;
+	req->cqe_pbl_addr = cqe_pbl_addr;
+	req->cqe_pbl_size = cqe_pbl_size;
+	req->rxq_addr = bd_chain_phys_addr;
+	req->hw_sb = sb;
+	req->sb_index = sb_index;
+	req->bd_max_bytes = bd_max_bytes;
+	req->stat_id = -1;
+
+	/* add list termination tlv */
+	qed_add_tlv(p_hwfn, &p_iov->offset,
+		    CHANNEL_TLV_LIST_END, sizeof(struct channel_list_end_tlv));
+
+	resp = &p_iov->pf2vf_reply->queue_start;
+	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
+	if (rc)
+		return rc;
+
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
+		return -EINVAL;
+
+	/* Learn the address of the producer from the response */
+	if (pp_prod) {
+		u64 init_prod_val = 0;
+
+		*pp_prod = (u8 __iomem *)p_hwfn->regview + resp->offset;
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "Rxq[0x%02x]: producer at %p [offset 0x%08x]\n",
+			   rx_qid, *pp_prod, resp->offset);
+
+		/* Init the rcq, rx bd and rx sge (if valid) producers to 0 */
+		__internal_ram_wr(p_hwfn, *pp_prod, sizeof(u64),
+				  (u32 *)&init_prod_val);
+	}
+
+	return rc;
+}
+
+int qed_vf_pf_rxq_stop(struct qed_hwfn *p_hwfn, u16 rx_qid, bool cqe_completion)
+{
+	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+	struct vfpf_stop_rxqs_tlv *req;
+	struct pfvf_def_resp_tlv *resp;
+	int rc;
+
+	/* clear mailbox and prep first tlv */
+	req = qed_vf_pf_prep(p_hwfn, CHANNEL_TLV_STOP_RXQS, sizeof(*req));
+
+	req->rx_qid = rx_qid;
+	req->num_rxqs = 1;
+	req->cqe_completion = cqe_completion;
+
+	/* add list termination tlv */
+	qed_add_tlv(p_hwfn, &p_iov->offset,
+		    CHANNEL_TLV_LIST_END, sizeof(struct channel_list_end_tlv));
+
+	resp = &p_iov->pf2vf_reply->default_resp;
+	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
+	if (rc)
+		return rc;
+
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
+		return -EINVAL;
+
+	return rc;
+}
+
+int qed_vf_pf_txq_start(struct qed_hwfn *p_hwfn,
+			u16 tx_queue_id,
+			u16 sb,
+			u8 sb_index,
+			dma_addr_t pbl_addr,
+			u16 pbl_size, void __iomem **pp_doorbell)
+{
+	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+	struct vfpf_start_txq_tlv *req;
+	struct pfvf_def_resp_tlv *resp;
+	int rc;
+
+	/* clear mailbox and prep first tlv */
+	req = qed_vf_pf_prep(p_hwfn, CHANNEL_TLV_START_TXQ, sizeof(*req));
+
+	req->tx_qid = tx_queue_id;
+
+	/* Tx */
+	req->pbl_addr = pbl_addr;
+	req->pbl_size = pbl_size;
+	req->hw_sb = sb;
+	req->sb_index = sb_index;
+
+	/* add list termination tlv */
+	qed_add_tlv(p_hwfn, &p_iov->offset,
+		    CHANNEL_TLV_LIST_END, sizeof(struct channel_list_end_tlv));
+
+	resp = &p_iov->pf2vf_reply->default_resp;
+	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
+	if (rc)
+		return rc;
+
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
+		return -EINVAL;
+
+	if (pp_doorbell) {
+		u8 cid = p_iov->acquire_resp.resc.cid[tx_queue_id];
+
+		*pp_doorbell = (u8 __iomem *)p_hwfn->doorbells +
+					     qed_db_addr(cid, DQ_DEMS_LEGACY);
+	}
+
+	return rc;
+}
+
+int qed_vf_pf_txq_stop(struct qed_hwfn *p_hwfn, u16 tx_qid)
+{
+	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+	struct vfpf_stop_txqs_tlv *req;
+	struct pfvf_def_resp_tlv *resp;
+	int rc;
+
+	/* clear mailbox and prep first tlv */
+	req = qed_vf_pf_prep(p_hwfn, CHANNEL_TLV_STOP_TXQS, sizeof(*req));
+
+	req->tx_qid = tx_qid;
+	req->num_txqs = 1;
+
+	/* add list termination tlv */
+	qed_add_tlv(p_hwfn, &p_iov->offset,
+		    CHANNEL_TLV_LIST_END, sizeof(struct channel_list_end_tlv));
+
+	resp = &p_iov->pf2vf_reply->default_resp;
+	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
+	if (rc)
+		return rc;
+
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
+		return -EINVAL;
+
+	return rc;
+}
+
+int qed_vf_pf_vport_start(struct qed_hwfn *p_hwfn,
+			  u8 vport_id,
+			  u16 mtu,
+			  u8 inner_vlan_removal,
+			  enum qed_tpa_mode tpa_mode,
+			  u8 max_buffers_per_cqe)
+{
+	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+	struct vfpf_vport_start_tlv *req;
+	struct pfvf_def_resp_tlv *resp;
+	int rc, i;
+
+	/* clear mailbox and prep first tlv */
+	req = qed_vf_pf_prep(p_hwfn, CHANNEL_TLV_VPORT_START, sizeof(*req));
+
+	req->mtu = mtu;
+	req->vport_id = vport_id;
+	req->inner_vlan_removal = inner_vlan_removal;
+	req->tpa_mode = tpa_mode;
+	req->max_buffers_per_cqe = max_buffers_per_cqe;
+
+	/* status blocks */
+	for (i = 0; i < p_hwfn->vf_iov_info->acquire_resp.resc.num_sbs; i++)
+		if (p_hwfn->sbs_info[i])
+			req->sb_addr[i] = p_hwfn->sbs_info[i]->sb_phys;
+
+	/* add list termination tlv */
+	qed_add_tlv(p_hwfn, &p_iov->offset,
+		    CHANNEL_TLV_LIST_END, sizeof(struct channel_list_end_tlv));
+
+	resp = &p_iov->pf2vf_reply->default_resp;
+	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
+	if (rc)
+		return rc;
+
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
+		return -EINVAL;
+
+	return rc;
+}
+
+int qed_vf_pf_vport_stop(struct qed_hwfn *p_hwfn)
+{
+	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+	struct pfvf_def_resp_tlv *resp = &p_iov->pf2vf_reply->default_resp;
+	int rc;
+
+	/* clear mailbox and prep first tlv */
+	qed_vf_pf_prep(p_hwfn, CHANNEL_TLV_VPORT_TEARDOWN,
+		       sizeof(struct vfpf_first_tlv));
+
+	/* add list termination tlv */
+	qed_add_tlv(p_hwfn, &p_iov->offset,
+		    CHANNEL_TLV_LIST_END, sizeof(struct channel_list_end_tlv));
+
+	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
+	if (rc)
+		return rc;
+
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
+		return -EINVAL;
+
+	return rc;
+}
+
+static bool
+qed_vf_handle_vp_update_is_needed(struct qed_hwfn *p_hwfn,
+				  struct qed_sp_vport_update_params *p_data,
+				  u16 tlv)
+{
+	switch (tlv) {
+	case CHANNEL_TLV_VPORT_UPDATE_ACTIVATE:
+		return !!(p_data->update_vport_active_rx_flg ||
+			  p_data->update_vport_active_tx_flg);
+	case CHANNEL_TLV_VPORT_UPDATE_MCAST:
+		return !!p_data->update_approx_mcast_flg;
+	case CHANNEL_TLV_VPORT_UPDATE_ACCEPT_PARAM:
+		return !!(p_data->accept_flags.update_rx_mode_config ||
+			  p_data->accept_flags.update_tx_mode_config);
+	case CHANNEL_TLV_VPORT_UPDATE_RSS:
+		return !!p_data->rss_params;
+	default:
+		DP_INFO(p_hwfn, "Unexpected vport-update TLV[%d]\n",
+			tlv);
+		return false;
+	}
+}
+
+static void
+qed_vf_handle_vp_update_tlvs_resp(struct qed_hwfn *p_hwfn,
+				  struct qed_sp_vport_update_params *p_data)
+{
+	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+	struct pfvf_def_resp_tlv *p_resp;
+	u16 tlv;
+
+	for (tlv = CHANNEL_TLV_VPORT_UPDATE_ACTIVATE;
+	     tlv < CHANNEL_TLV_VPORT_UPDATE_MAX; tlv++) {
+		if (!qed_vf_handle_vp_update_is_needed(p_hwfn, p_data, tlv))
+			continue;
+
+		p_resp = (struct pfvf_def_resp_tlv *)
+			 qed_iov_search_list_tlvs(p_hwfn, p_iov->pf2vf_reply,
+						  tlv);
+		if (p_resp && p_resp->hdr.status)
+			DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+				   "TLV[%d] Configuration %s\n",
+				   tlv,
+				   (p_resp && p_resp->hdr.status) ? "succeeded"
+								  : "failed");
+	}
+}
+
+int qed_vf_pf_vport_update(struct qed_hwfn *p_hwfn,
+			   struct qed_sp_vport_update_params *p_params)
+{
+	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+	struct vfpf_vport_update_tlv *req;
+	struct pfvf_def_resp_tlv *resp;
+	u8 update_rx, update_tx;
+	u32 resp_size = 0;
+	u16 size, tlv;
+	int rc;
+
+	resp = &p_iov->pf2vf_reply->default_resp;
+	resp_size = sizeof(*resp);
+
+	update_rx = p_params->update_vport_active_rx_flg;
+	update_tx = p_params->update_vport_active_tx_flg;
+
+	/* clear mailbox and prep header tlv */
+	qed_vf_pf_prep(p_hwfn, CHANNEL_TLV_VPORT_UPDATE, sizeof(*req));
+
+	/* Prepare extended tlvs */
+	if (update_rx || update_tx) {
+		struct vfpf_vport_update_activate_tlv *p_act_tlv;
+
+		size = sizeof(struct vfpf_vport_update_activate_tlv);
+		p_act_tlv = qed_add_tlv(p_hwfn, &p_iov->offset,
+					CHANNEL_TLV_VPORT_UPDATE_ACTIVATE,
+					size);
+		resp_size += sizeof(struct pfvf_def_resp_tlv);
+
+		if (update_rx) {
+			p_act_tlv->update_rx = update_rx;
+			p_act_tlv->active_rx = p_params->vport_active_rx_flg;
+		}
+
+		if (update_tx) {
+			p_act_tlv->update_tx = update_tx;
+			p_act_tlv->active_tx = p_params->vport_active_tx_flg;
+		}
+	}
+
+	if (p_params->update_approx_mcast_flg) {
+		struct vfpf_vport_update_mcast_bin_tlv *p_mcast_tlv;
+
+		size = sizeof(struct vfpf_vport_update_mcast_bin_tlv);
+		p_mcast_tlv = qed_add_tlv(p_hwfn, &p_iov->offset,
+					  CHANNEL_TLV_VPORT_UPDATE_MCAST, size);
+		resp_size += sizeof(struct pfvf_def_resp_tlv);
+
+		memcpy(p_mcast_tlv->bins, p_params->bins,
+		       sizeof(unsigned long) * ETH_MULTICAST_MAC_BINS_IN_REGS);
+	}
+
+	update_rx = p_params->accept_flags.update_rx_mode_config;
+	update_tx = p_params->accept_flags.update_tx_mode_config;
+
+	if (update_rx || update_tx) {
+		struct vfpf_vport_update_accept_param_tlv *p_accept_tlv;
+
+		tlv = CHANNEL_TLV_VPORT_UPDATE_ACCEPT_PARAM;
+		size = sizeof(struct vfpf_vport_update_accept_param_tlv);
+		p_accept_tlv = qed_add_tlv(p_hwfn, &p_iov->offset, tlv, size);
+		resp_size += sizeof(struct pfvf_def_resp_tlv);
+
+		if (update_rx) {
+			p_accept_tlv->update_rx_mode = update_rx;
+			p_accept_tlv->rx_accept_filter =
+			    p_params->accept_flags.rx_accept_filter;
+		}
+
+		if (update_tx) {
+			p_accept_tlv->update_tx_mode = update_tx;
+			p_accept_tlv->tx_accept_filter =
+			    p_params->accept_flags.tx_accept_filter;
+		}
+	}
+
+	if (p_params->rss_params) {
+		struct qed_rss_params *rss_params = p_params->rss_params;
+		struct vfpf_vport_update_rss_tlv *p_rss_tlv;
+
+		size = sizeof(struct vfpf_vport_update_rss_tlv);
+		p_rss_tlv = qed_add_tlv(p_hwfn,
+					&p_iov->offset,
+					CHANNEL_TLV_VPORT_UPDATE_RSS, size);
+		resp_size += sizeof(struct pfvf_def_resp_tlv);
+
+		if (rss_params->update_rss_config)
+			p_rss_tlv->update_rss_flags |=
+			    VFPF_UPDATE_RSS_CONFIG_FLAG;
+		if (rss_params->update_rss_capabilities)
+			p_rss_tlv->update_rss_flags |=
+			    VFPF_UPDATE_RSS_CAPS_FLAG;
+		if (rss_params->update_rss_ind_table)
+			p_rss_tlv->update_rss_flags |=
+			    VFPF_UPDATE_RSS_IND_TABLE_FLAG;
+		if (rss_params->update_rss_key)
+			p_rss_tlv->update_rss_flags |= VFPF_UPDATE_RSS_KEY_FLAG;
+
+		p_rss_tlv->rss_enable = rss_params->rss_enable;
+		p_rss_tlv->rss_caps = rss_params->rss_caps;
+		p_rss_tlv->rss_table_size_log = rss_params->rss_table_size_log;
+		memcpy(p_rss_tlv->rss_ind_table, rss_params->rss_ind_table,
+		       sizeof(rss_params->rss_ind_table));
+		memcpy(p_rss_tlv->rss_key, rss_params->rss_key,
+		       sizeof(rss_params->rss_key));
+	}
+
+	/* add list termination tlv */
+	qed_add_tlv(p_hwfn, &p_iov->offset,
+		    CHANNEL_TLV_LIST_END, sizeof(struct channel_list_end_tlv));
+
+	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, resp_size);
+	if (rc)
+		return rc;
+
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
+		return -EINVAL;
+
+	qed_vf_handle_vp_update_tlvs_resp(p_hwfn, p_params);
+
+	return rc;
+}
+
 int qed_vf_pf_reset(struct qed_hwfn *p_hwfn)
 {
 	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
@@ -384,6 +778,57 @@ int qed_vf_pf_release(struct qed_hwfn *p_hwfn)
 	return rc;
 }
 
+void qed_vf_pf_filter_mcast(struct qed_hwfn *p_hwfn,
+			    struct qed_filter_mcast *p_filter_cmd)
+{
+	struct qed_sp_vport_update_params sp_params;
+	int i;
+
+	memset(&sp_params, 0, sizeof(sp_params));
+	sp_params.update_approx_mcast_flg = 1;
+
+	if (p_filter_cmd->opcode == QED_FILTER_ADD) {
+		for (i = 0; i < p_filter_cmd->num_mc_addrs; i++) {
+			u32 bit;
+
+			bit = qed_mcast_bin_from_mac(p_filter_cmd->mac[i]);
+			__set_bit(bit, sp_params.bins);
+		}
+	}
+
+	qed_vf_pf_vport_update(p_hwfn, &sp_params);
+}
+
+int qed_vf_pf_filter_ucast(struct qed_hwfn *p_hwfn,
+			   struct qed_filter_ucast *p_ucast)
+{
+	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+	struct vfpf_ucast_filter_tlv *req;
+	struct pfvf_def_resp_tlv *resp;
+	int rc;
+
+	/* clear mailbox and prep first tlv */
+	req = qed_vf_pf_prep(p_hwfn, CHANNEL_TLV_UCAST_FILTER, sizeof(*req));
+	req->opcode = (u8) p_ucast->opcode;
+	req->type = (u8) p_ucast->type;
+	memcpy(req->mac, p_ucast->mac, ETH_ALEN);
+	req->vlan = p_ucast->vlan;
+
+	/* add list termination tlv */
+	qed_add_tlv(p_hwfn, &p_iov->offset,
+		    CHANNEL_TLV_LIST_END, sizeof(struct channel_list_end_tlv));
+
+	resp = &p_iov->pf2vf_reply->default_resp;
+	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
+	if (rc)
+		return rc;
+
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
+		return -EAGAIN;
+
+	return 0;
+}
+
 int qed_vf_pf_int_cleanup(struct qed_hwfn *p_hwfn)
 {
 	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.h b/drivers/net/ethernet/qlogic/qed/qed_vf.h
index f3ce064..81600eb 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.h
@@ -9,6 +9,11 @@
 #ifndef _QED_VF_H
 #define _QED_VF_H
 
+#include "qed_l2.h"
+
+#define T_ETH_INDIRECTION_TABLE_SIZE 128
+#define T_ETH_RSS_KEY_SIZE 10
+
 struct vf_pf_resc_request {
 	u8 num_rxqs;
 	u8 num_txqs;
@@ -25,6 +30,8 @@ struct hw_sb_info {
 	u8 padding[5];
 };
 
+#define TLV_BUFFER_SIZE                 1024
+
 enum {
 	PFVF_STATUS_WAITING,
 	PFVF_STATUS_SUCCESS,
@@ -98,6 +105,23 @@ struct vfpf_acquire_tlv {
 	u32 padding;
 };
 
+/* receive side scaling tlv */
+struct vfpf_vport_update_rss_tlv {
+	struct channel_tlv tl;
+
+	u8 update_rss_flags;
+#define VFPF_UPDATE_RSS_CONFIG_FLAG       BIT(0)
+#define VFPF_UPDATE_RSS_CAPS_FLAG         BIT(1)
+#define VFPF_UPDATE_RSS_IND_TABLE_FLAG    BIT(2)
+#define VFPF_UPDATE_RSS_KEY_FLAG          BIT(3)
+
+	u8 rss_enable;
+	u8 rss_caps;
+	u8 rss_table_size_log;	/* The table size is 2 ^ rss_table_size_log */
+	u16 rss_ind_table[T_ETH_INDIRECTION_TABLE_SIZE];
+	u32 rss_key[T_ETH_RSS_KEY_SIZE];
+};
+
 struct pfvf_storm_stats {
 	u32 address;
 	u32 len;
@@ -169,7 +193,157 @@ struct pfvf_acquire_resp_tlv {
 	u32 padding;
 };
 
-#define TLV_BUFFER_SIZE                 1024
+struct pfvf_start_queue_resp_tlv {
+	struct pfvf_tlv hdr;
+	u32 offset;		/* offset to consumer/producer of queue */
+	u8 padding[4];
+};
+
+/* Setup Queue */
+struct vfpf_start_rxq_tlv {
+	struct vfpf_first_tlv first_tlv;
+
+	/* physical addresses */
+	u64 rxq_addr;
+	u64 deprecated_sge_addr;
+	u64 cqe_pbl_addr;
+
+	u16 cqe_pbl_size;
+	u16 hw_sb;
+	u16 rx_qid;
+	u16 hc_rate;		/* desired interrupts per sec. */
+
+	u16 bd_max_bytes;
+	u16 stat_id;
+	u8 sb_index;
+	u8 padding[3];
+};
+
+struct vfpf_start_txq_tlv {
+	struct vfpf_first_tlv first_tlv;
+
+	/* physical addresses */
+	u64 pbl_addr;
+	u16 pbl_size;
+	u16 stat_id;
+	u16 tx_qid;
+	u16 hw_sb;
+
+	u32 flags;		/* VFPF_QUEUE_FLG_X flags */
+	u16 hc_rate;		/* desired interrupts per sec. */
+	u8 sb_index;
+	u8 padding[3];
+};
+
+/* Stop RX Queue */
+struct vfpf_stop_rxqs_tlv {
+	struct vfpf_first_tlv first_tlv;
+
+	u16 rx_qid;
+	u8 num_rxqs;
+	u8 cqe_completion;
+	u8 padding[4];
+};
+
+/* Stop TX Queues */
+struct vfpf_stop_txqs_tlv {
+	struct vfpf_first_tlv first_tlv;
+
+	u16 tx_qid;
+	u8 num_txqs;
+	u8 padding[5];
+};
+
+struct vfpf_update_rxq_tlv {
+	struct vfpf_first_tlv first_tlv;
+
+	u64 deprecated_sge_addr[PFVF_MAX_QUEUES_PER_VF];
+
+	u16 rx_qid;
+	u8 num_rxqs;
+	u8 flags;
+#define VFPF_RXQ_UPD_INIT_SGE_DEPRECATE_FLAG    BIT(0)
+#define VFPF_RXQ_UPD_COMPLETE_CQE_FLAG          BIT(1)
+#define VFPF_RXQ_UPD_COMPLETE_EVENT_FLAG        BIT(2)
+
+	u8 padding[4];
+};
+
+/* Set Queue Filters */
+struct vfpf_q_mac_vlan_filter {
+	u32 flags;
+#define VFPF_Q_FILTER_DEST_MAC_VALID    0x01
+#define VFPF_Q_FILTER_VLAN_TAG_VALID    0x02
+#define VFPF_Q_FILTER_SET_MAC           0x100	/* set/clear */
+
+	u8 mac[ETH_ALEN];
+	u16 vlan_tag;
+
+	u8 padding[4];
+};
+
+/* Start a vport */
+struct vfpf_vport_start_tlv {
+	struct vfpf_first_tlv first_tlv;
+
+	u64 sb_addr[PFVF_MAX_SBS_PER_VF];
+
+	u32 tpa_mode;
+	u16 dep1;
+	u16 mtu;
+
+	u8 vport_id;
+	u8 inner_vlan_removal;
+
+	u8 only_untagged;
+	u8 max_buffers_per_cqe;
+
+	u8 padding[4];
+};
+
+/* Extended tlvs - need to add rss, mcast, accept mode tlvs */
+struct vfpf_vport_update_activate_tlv {
+	struct channel_tlv tl;
+	u8 update_rx;
+	u8 update_tx;
+	u8 active_rx;
+	u8 active_tx;
+};
+
+struct vfpf_vport_update_mcast_bin_tlv {
+	struct channel_tlv tl;
+	u8 padding[4];
+
+	u64 bins[8];
+};
+
+struct vfpf_vport_update_accept_param_tlv {
+	struct channel_tlv tl;
+	u8 update_rx_mode;
+	u8 update_tx_mode;
+	u8 rx_accept_filter;
+	u8 tx_accept_filter;
+};
+
+/* Primary tlv as a header for various extended tlvs for
+ * various functionalities in vport update ramrod.
+ */
+struct vfpf_vport_update_tlv {
+	struct vfpf_first_tlv first_tlv;
+};
+
+struct vfpf_ucast_filter_tlv {
+	struct vfpf_first_tlv first_tlv;
+
+	u8 opcode;
+	u8 type;
+
+	u8 mac[ETH_ALEN];
+
+	u16 vlan;
+	u16 padding[3];
+};
+
 struct tlv_buffer_size {
 	u8 tlv_buffer[TLV_BUFFER_SIZE];
 };
@@ -177,6 +351,13 @@ struct tlv_buffer_size {
 union vfpf_tlvs {
 	struct vfpf_first_tlv first_tlv;
 	struct vfpf_acquire_tlv acquire;
+	struct vfpf_start_rxq_tlv start_rxq;
+	struct vfpf_start_txq_tlv start_txq;
+	struct vfpf_stop_rxqs_tlv stop_rxqs;
+	struct vfpf_stop_txqs_tlv stop_txqs;
+	struct vfpf_vport_start_tlv start_vport;
+	struct vfpf_vport_update_tlv vport_update;
+	struct vfpf_ucast_filter_tlv ucast_filter;
 	struct channel_list_end_tlv list_end;
 	struct tlv_buffer_size tlv_buf_size;
 };
@@ -185,6 +366,7 @@ union pfvf_tlvs {
 	struct pfvf_def_resp_tlv default_resp;
 	struct pfvf_acquire_resp_tlv acquire_resp;
 	struct tlv_buffer_size tlv_buf_size;
+	struct pfvf_start_queue_resp_tlv queue_start;
 };
 
 struct qed_bulletin_content {
@@ -206,11 +388,28 @@ struct qed_bulletin {
 enum {
 	CHANNEL_TLV_NONE,	/* ends tlv sequence */
 	CHANNEL_TLV_ACQUIRE,
+	CHANNEL_TLV_VPORT_START,
+	CHANNEL_TLV_VPORT_UPDATE,
+	CHANNEL_TLV_VPORT_TEARDOWN,
+	CHANNEL_TLV_START_RXQ,
+	CHANNEL_TLV_START_TXQ,
+	CHANNEL_TLV_STOP_RXQS,
+	CHANNEL_TLV_STOP_TXQS,
 	CHANNEL_TLV_INT_CLEANUP,
 	CHANNEL_TLV_CLOSE,
 	CHANNEL_TLV_RELEASE,
 	CHANNEL_TLV_LIST_END,
-	CHANNEL_TLV_MAX
+	CHANNEL_TLV_UCAST_FILTER,
+	CHANNEL_TLV_VPORT_UPDATE_ACTIVATE,
+	CHANNEL_TLV_VPORT_UPDATE_MCAST,
+	CHANNEL_TLV_VPORT_UPDATE_ACCEPT_PARAM,
+	CHANNEL_TLV_VPORT_UPDATE_RSS,
+	CHANNEL_TLV_MAX,
+
+	/* Required for iterating over vport-update tlvs.
+	 * Will break in case non-sequential vport-update tlvs.
+	 */
+	CHANNEL_TLV_VPORT_UPDATE_MAX = CHANNEL_TLV_VPORT_UPDATE_RSS + 1,
 };
 
 /* This data is held in the qed_hwfn structure for VFs only. */
@@ -282,6 +481,85 @@ void qed_vf_get_fw_version(struct qed_hwfn *p_hwfn,
 int qed_vf_hw_prepare(struct qed_hwfn *p_hwfn);
 
 /**
+ * @brief VF - start the RX Queue by sending a message to the PF
+ * @param p_hwfn
+ * @param cid                   - zero based within the VF
+ * @param rx_queue_id           - zero based within the VF
+ * @param sb                    - VF status block for this queue
+ * @param sb_index              - Index within the status block
+ * @param bd_max_bytes          - maximum number of bytes per bd
+ * @param bd_chain_phys_addr    - physical address of bd chain
+ * @param cqe_pbl_addr          - physical address of pbl
+ * @param cqe_pbl_size          - pbl size
+ * @param pp_prod               - pointer to the producer to be
+ *				  used in fastpath
+ *
+ * @return int
+ */
+int qed_vf_pf_rxq_start(struct qed_hwfn *p_hwfn,
+			u8 rx_queue_id,
+			u16 sb,
+			u8 sb_index,
+			u16 bd_max_bytes,
+			dma_addr_t bd_chain_phys_addr,
+			dma_addr_t cqe_pbl_addr,
+			u16 cqe_pbl_size, void __iomem **pp_prod);
+
+/**
+ * @brief VF - start the TX queue by sending a message to the
+ *        PF.
+ *
+ * @param p_hwfn
+ * @param tx_queue_id           - zero based within the VF
+ * @param sb                    - status block for this queue
+ * @param sb_index              - index within the status block
+ * @param bd_chain_phys_addr    - physical address of tx chain
+ * @param pp_doorbell           - pointer to address to which to
+ *                      write the doorbell too..
+ *
+ * @return int
+ */
+int qed_vf_pf_txq_start(struct qed_hwfn *p_hwfn,
+			u16 tx_queue_id,
+			u16 sb,
+			u8 sb_index,
+			dma_addr_t pbl_addr,
+			u16 pbl_size, void __iomem **pp_doorbell);
+
+/**
+ * @brief VF - stop the RX queue by sending a message to the PF
+ *
+ * @param p_hwfn
+ * @param rx_qid
+ * @param cqe_completion
+ *
+ * @return int
+ */
+int qed_vf_pf_rxq_stop(struct qed_hwfn *p_hwfn,
+		       u16 rx_qid, bool cqe_completion);
+
+/**
+ * @brief VF - stop the TX queue by sending a message to the PF
+ *
+ * @param p_hwfn
+ * @param tx_qid
+ *
+ * @return int
+ */
+int qed_vf_pf_txq_stop(struct qed_hwfn *p_hwfn, u16 tx_qid);
+
+/**
+ * @brief VF - send a vport update command
+ *
+ * @param p_hwfn
+ * @param params
+ *
+ * @return int
+ */
+int qed_vf_pf_vport_update(struct qed_hwfn *p_hwfn,
+			   struct qed_sp_vport_update_params *p_params);
+
+/**
  *
  * @brief VF - send a close message to PF
  *
@@ -311,6 +589,41 @@ int qed_vf_pf_release(struct qed_hwfn *p_hwfn);
 u16 qed_vf_get_igu_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id);
 
 /**
+ * @brief qed_vf_pf_vport_start - perform vport start for VF.
+ *
+ * @param p_hwfn
+ * @param vport_id
+ * @param mtu
+ * @param inner_vlan_removal
+ * @param tpa_mode
+ * @param max_buffers_per_cqe,
+ * @param only_untagged - default behavior regarding vlan acceptance
+ *
+ * @return enum _qed_status
+ */
+int qed_vf_pf_vport_start(struct qed_hwfn *p_hwfn,
+			  u8 vport_id,
+			  u16 mtu,
+			  u8 inner_vlan_removal,
+			  enum qed_tpa_mode tpa_mode,
+			  u8 max_buffers_per_cqe);
+
+/**
+ * @brief qed_vf_pf_vport_stop - stop the VF's vport
+ *
+ * @param p_hwfn
+ *
+ * @return enum _qed_status
+ */
+int qed_vf_pf_vport_stop(struct qed_hwfn *p_hwfn);
+
+int qed_vf_pf_filter_ucast(struct qed_hwfn *p_hwfn,
+			   struct qed_filter_ucast *p_param);
+
+void qed_vf_pf_filter_mcast(struct qed_hwfn *p_hwfn,
+			    struct qed_filter_mcast *p_filter_cmd);
+
+/**
  * @brief qed_vf_pf_int_cleanup - clean the SB of the VF
  *
  * @param p_hwfn
@@ -343,6 +656,46 @@ static inline int qed_vf_hw_prepare(struct qed_hwfn *p_hwfn)
 	return -EINVAL;
 }
 
+static inline int qed_vf_pf_rxq_start(struct qed_hwfn *p_hwfn,
+				      u8 rx_queue_id,
+				      u16 sb,
+				      u8 sb_index,
+				      u16 bd_max_bytes,
+				      dma_addr_t bd_chain_phys_adr,
+				      dma_addr_t cqe_pbl_addr,
+				      u16 cqe_pbl_size, void __iomem **pp_prod)
+{
+	return -EINVAL;
+}
+
+static inline int qed_vf_pf_txq_start(struct qed_hwfn *p_hwfn,
+				      u16 tx_queue_id,
+				      u16 sb,
+				      u8 sb_index,
+				      dma_addr_t pbl_addr,
+				      u16 pbl_size, void __iomem **pp_doorbell)
+{
+	return -EINVAL;
+}
+
+static inline int qed_vf_pf_rxq_stop(struct qed_hwfn *p_hwfn,
+				     u16 rx_qid, bool cqe_completion)
+{
+	return -EINVAL;
+}
+
+static inline int qed_vf_pf_txq_stop(struct qed_hwfn *p_hwfn, u16 tx_qid)
+{
+	return -EINVAL;
+}
+
+static inline int
+qed_vf_pf_vport_update(struct qed_hwfn *p_hwfn,
+		       struct qed_sp_vport_update_params *p_params)
+{
+	return -EINVAL;
+}
+
 static inline int qed_vf_pf_reset(struct qed_hwfn *p_hwfn)
 {
 	return -EINVAL;
@@ -358,6 +711,32 @@ static inline u16 qed_vf_get_igu_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id)
 	return 0;
 }
 
+static inline int qed_vf_pf_vport_start(struct qed_hwfn *p_hwfn,
+					u8 vport_id,
+					u16 mtu,
+					u8 inner_vlan_removal,
+					enum qed_tpa_mode tpa_mode,
+					u8 max_buffers_per_cqe)
+{
+	return -EINVAL;
+}
+
+static inline int qed_vf_pf_vport_stop(struct qed_hwfn *p_hwfn)
+{
+	return -EINVAL;
+}
+
+static inline int qed_vf_pf_filter_ucast(struct qed_hwfn *p_hwfn,
+					 struct qed_filter_ucast *p_param)
+{
+	return -EINVAL;
+}
+
+static inline void qed_vf_pf_filter_mcast(struct qed_hwfn *p_hwfn,
+					  struct qed_filter_mcast *p_filter_cmd)
+{
+}
+
 static inline int qed_vf_pf_int_cleanup(struct qed_hwfn *p_hwfn)
 {
 	return -EINVAL;
-- 
1.9.3
