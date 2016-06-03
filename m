From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 3/4] qed: Add iscsi/rdma personalities
Date: Fri, 3 Jun 2016 14:35:34 +0300
Message-ID: <1464953735-2585-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1464953735-2585-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Rajesh.Borundia@qlogic.com>, <shyam.sundar@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:45138 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932393AbcFCLgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 07:36:02 -0400
In-Reply-To: <1464953735-2585-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds in the ecore 2 new personalities in addition to
QED_PCI_ETH - QED_PCI_ISCSI and QED_PCI_ETH_ROCE.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h             |  4 ++
 drivers/net/ethernet/qlogic/qed/qed_dev.c         |  6 +++
 drivers/net/ethernet/qlogic/qed/qed_hsi.h         |  6 ++-
 drivers/net/ethernet/qlogic/qed/qed_main.c        |  5 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.c         | 13 ++++-
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c | 17 +++++-
 include/linux/qed/common_hsi.h                    |  4 +-
 include/linux/qed/qed_if.h                        | 65 +++++++++++++++++++++++
 8 files changed, 114 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 1042f2a..4417f12 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -127,6 +127,8 @@ struct qed_tunn_update_params {
  */
 enum qed_pci_personality {
 	QED_PCI_ETH,
+	QED_PCI_ISCSI,
+	QED_PCI_ETH_ROCE,
 	QED_PCI_DEFAULT /* default in shmem */
 };
 
@@ -170,6 +172,8 @@ enum QED_PORT_MODE {
 
 enum qed_dev_cap {
 	QED_DEV_CAP_ETH,
+	QED_DEV_CAP_ISCSI,
+	QED_DEV_CAP_ROCE,
 };
 
 struct qed_hw_info {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 151173d..30c6d2e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1472,6 +1472,12 @@ static int qed_hw_get_nvm_info(struct qed_hwfn *p_hwfn,
 	if (device_capabilities & NVM_CFG1_GLOB_DEVICE_CAPABILITIES_ETHERNET)
 		__set_bit(QED_DEV_CAP_ETH,
 			  &p_hwfn->hw_info.device_capabilities);
+	if (device_capabilities & NVM_CFG1_GLOB_DEVICE_CAPABILITIES_ISCSI)
+		__set_bit(QED_DEV_CAP_ISCSI,
+			  &p_hwfn->hw_info.device_capabilities);
+	if (device_capabilities & NVM_CFG1_GLOB_DEVICE_CAPABILITIES_ROCE)
+		__set_bit(QED_DEV_CAP_ROCE,
+			  &p_hwfn->hw_info.device_capabilities);
 
 	return qed_mcp_fill_shmem_func_info(p_hwfn, p_ptt);
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 4cd70bf..72e0ad6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -650,7 +650,7 @@ struct mstorm_vf_zone {
 /* personality per PF */
 enum personality_type {
 	BAD_PERSONALITY_TYP,
-	PERSONALITY_RESERVED,
+	PERSONALITY_ISCSI,
 	PERSONALITY_RESERVED2,
 	PERSONALITY_RDMA_AND_ETH,
 	PERSONALITY_RESERVED3,
@@ -7072,6 +7072,8 @@ struct public_func {
 #define FUNC_MF_CFG_PROTOCOL_MASK	0x000000f0
 #define FUNC_MF_CFG_PROTOCOL_SHIFT	4
 #define FUNC_MF_CFG_PROTOCOL_ETHERNET	0x00000000
+#define FUNC_MF_CFG_PROTOCOL_ISCSI              0x00000010
+#define FUNC_MF_CFG_PROTOCOL_ROCE               0x00000030
 #define FUNC_MF_CFG_PROTOCOL_MAX	0x00000030
 
 #define FUNC_MF_CFG_MIN_BW_MASK		0x0000ff00
@@ -7405,6 +7407,8 @@ struct nvm_cfg1_glob {
 	u32 misc_sig;
 	u32 device_capabilities;
 #define NVM_CFG1_GLOB_DEVICE_CAPABILITIES_ETHERNET	0x1
+#define NVM_CFG1_GLOB_DEVICE_CAPABILITIES_ISCSI		0x4
+#define NVM_CFG1_GLOB_DEVICE_CAPABILITIES_ROCE		0x8
 	u32 power_dissipated;
 	u32 power_consumed;
 	u32 efi_version;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index c807f67..f41f78d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -207,6 +207,8 @@ int qed_fill_dev_info(struct qed_dev *cdev,
 	dev_info->pci_mem_start = cdev->pci_params.mem_start;
 	dev_info->pci_mem_end = cdev->pci_params.mem_end;
 	dev_info->pci_irq = cdev->pci_params.irq;
+	dev_info->rdma_supported =
+	    (cdev->hwfns[0].hw_info.personality == QED_PCI_ETH_ROCE);
 	dev_info->is_mf_default = IS_MF_DEFAULT(&cdev->hwfns[0]);
 	ether_addr_copy(dev_info->hw_mac, cdev->hwfns[0].hw_info.hw_mac_addr);
 
@@ -901,7 +903,8 @@ static int qed_slowpath_stop(struct qed_dev *cdev)
 
 	if (IS_PF(cdev)) {
 		qed_free_stream_mem(cdev);
-		qed_sriov_disable(cdev, true);
+		if (IS_QED_ETH_IF(cdev))
+			qed_sriov_disable(cdev, true);
 
 		qed_nic_stop(cdev);
 		qed_slowpath_irq_free(cdev);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 2c143b3..a240f26 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -977,7 +977,18 @@ qed_mcp_get_shmem_proto(struct qed_hwfn *p_hwfn,
 
 	switch (p_info->config & FUNC_MF_CFG_PROTOCOL_MASK) {
 	case FUNC_MF_CFG_PROTOCOL_ETHERNET:
-		*p_proto = QED_PCI_ETH;
+		if (test_bit(QED_DEV_CAP_ROCE,
+			     &p_hwfn->hw_info.device_capabilities))
+			*p_proto = QED_PCI_ETH_ROCE;
+		else
+			*p_proto = QED_PCI_ETH;
+		break;
+	case FUNC_MF_CFG_PROTOCOL_ISCSI:
+		*p_proto = QED_PCI_ISCSI;
+		break;
+	case FUNC_MF_CFG_PROTOCOL_ROCE:
+		DP_NOTICE(p_hwfn, "RoCE personality is not a valid value!\n");
+		rc = -EINVAL;
 		break;
 	default:
 		rc = -EINVAL;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index 63b93fb..a52f3fc 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -358,11 +358,26 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 
 	qed_tunn_set_pf_start_params(p_hwfn, p_tunn,
 				     &p_ramrod->tunnel_config);
-	p_hwfn->hw_info.personality = PERSONALITY_ETH;
 
 	if (IS_MF_SI(p_hwfn))
 		p_ramrod->allow_npar_tx_switching = allow_npar_tx_switch;
 
+	switch (p_hwfn->hw_info.personality) {
+	case QED_PCI_ETH:
+		p_ramrod->personality = PERSONALITY_ETH;
+		break;
+	case QED_PCI_ISCSI:
+		p_ramrod->personality = PERSONALITY_ISCSI;
+		break;
+	case QED_PCI_ETH_ROCE:
+		p_ramrod->personality = PERSONALITY_RDMA_AND_ETH;
+		break;
+	default:
+		DP_NOTICE(p_hwfn, "Unkown personality %d\n",
+			  p_hwfn->hw_info.personality);
+		p_ramrod->personality = PERSONALITY_ETH;
+	}
+
 	if (p_hwfn->cdev->p_iov_info) {
 		struct qed_hw_sriov_info *p_iov = p_hwfn->cdev->p_iov_info;
 
diff --git a/include/linux/qed/common_hsi.h b/include/linux/qed/common_hsi.h
index 077a3b6..40c0ada 100644
--- a/include/linux/qed/common_hsi.h
+++ b/include/linux/qed/common_hsi.h
@@ -517,9 +517,9 @@ enum mf_mode {
 
 /* Per-protocol connection types */
 enum protocol_type {
-	PROTOCOLID_RESERVED1,
+	PROTOCOLID_ISCSI,
 	PROTOCOLID_RESERVED2,
-	PROTOCOLID_RESERVED3,
+	PROTOCOLID_ROCE,
 	PROTOCOLID_CORE,
 	PROTOCOLID_ETH,
 	PROTOCOLID_RESERVED4,
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index 15efccf..e8cc49f 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -58,8 +58,70 @@ struct qed_eth_pf_params {
 	u16 num_cons;
 };
 
+/* Most of the the parameters below are described in the FW iSCSI / TCP HSI */
+struct qed_iscsi_pf_params {
+	u64 glbl_q_params_addr;
+	u64 bdq_pbl_base_addr[2];
+	u32 max_cwnd;
+	u16 cq_num_entries;
+	u16 cmdq_num_entries;
+	u16 dup_ack_threshold;
+	u16 tx_sws_timer;
+	u16 min_rto;
+	u16 min_rto_rt;
+	u16 max_rto;
+
+	/* The following parameters are used during HW-init
+	 * and these parameters need to be passed as arguments
+	 * to update_pf_params routine invoked before slowpath start
+	 */
+	u16 num_cons;
+	u16 num_tasks;
+
+	/* The following parameters are used during protocol-init */
+	u16 half_way_close_timeout;
+	u16 bdq_xoff_threshold[2];
+	u16 bdq_xon_threshold[2];
+	u16 cmdq_xoff_threshold;
+	u16 cmdq_xon_threshold;
+	u16 rq_buffer_size;
+
+	u8 num_sq_pages_in_ring;
+	u8 num_r2tq_pages_in_ring;
+	u8 num_uhq_pages_in_ring;
+	u8 num_queues;
+	u8 log_page_size;
+	u8 rqe_log_size;
+	u8 max_fin_rt;
+	u8 gl_rq_pi;
+	u8 gl_cmd_pi;
+	u8 debug_mode;
+	u8 ll2_ooo_queue_id;
+	u8 ooo_enable;
+
+	u8 is_target;
+	u8 bdq_pbl_num_entries[2];
+};
+
+struct qed_rdma_pf_params {
+	/* Supplied to QED during resource allocation (may affect the ILT and
+	 * the doorbell BAR).
+	 */
+	u32 min_dpis;		/* number of requested DPIs */
+	u32 num_mrs;		/* number of requested memory regions */
+	u32 num_qps;		/* number of requested Queue Pairs */
+	u32 num_srqs;		/* number of requested SRQ */
+	u8 roce_edpm_mode;	/* see QED_ROCE_EDPM_MODE_ENABLE */
+	u8 gl_pi;		/* protocol index */
+
+	/* Will allocate rate limiters to be used with QPs */
+	u8 enable_dcqcn;
+};
+
 struct qed_pf_params {
 	struct qed_eth_pf_params eth_pf_params;
+	struct qed_iscsi_pf_params iscsi_pf_params;
+	struct qed_rdma_pf_params rdma_pf_params;
 };
 
 enum qed_int_mode {
@@ -100,6 +162,8 @@ struct qed_dev_info {
 	/* MFW version */
 	u32		mfw_rev;
 
+	bool rdma_supported;
+
 	u32		flash_size;
 	u8		mf_mode;
 	bool		tx_switching;
@@ -111,6 +175,7 @@ enum qed_sb_type {
 
 enum qed_protocol {
 	QED_PROTOCOL_ETH,
+	QED_PROTOCOL_ISCSI,
 };
 
 struct qed_link_params {
-- 
1.9.3
