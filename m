From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] qed: Utilize FW 8.10.3.0
Date: Thu, 2 Jun 2016 10:23:29 +0300
Message-ID: <1464852209-7175-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:2795 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752023AbcFBHXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 03:23:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The New QED firmware contains several fixes, including:
  - Wrong classification of packets in 4-port devices.
  - Anti-spoof interoperability with encapsulated packets.
  - Tx-switching of encapsulated packets.
It also slightly improves Tx performance of the device.

In addition, this firmware contains the necessary logic for
supporting iscsi & rdma, for which we plan on pushing protocol
drivers in the imminent future.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

This adds a single new checkpatch warning [a 80+ character line in
the firmware HSI].

Please consider applying it to `net-next'.

Thanks,
Yuval
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c          |   68 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h          | 7962 +++++++++-----------
 drivers/net/ethernet/qlogic/qed/qed_hw.c           |    6 +-
 .../net/ethernet/qlogic/qed/qed_init_fw_funcs.c    |  184 +-
 drivers/net/ethernet/qlogic/qed/qed_init_ops.c     |    9 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.c           |  108 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c         |   22 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.c          |   44 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.h          |    3 +
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h     |    8 +-
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c  |    4 +-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c        |   20 +-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c    |    2 +
 drivers/net/ethernet/qlogic/qede/qede_main.c       |   16 +-
 include/linux/qed/common_hsi.h                     |  205 +-
 include/linux/qed/eth_common.h                     |  124 +-
 include/linux/qed/qed_eth_if.h                     |    1 +
 17 files changed, 4129 insertions(+), 4657 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 2d89e8c..e9ce6a7 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -244,6 +244,7 @@ static int qed_init_qm_info(struct qed_hwfn *p_hwfn, bool b_sleepable)
 		qm_info->qm_pq_params[curr_queue].tc_id =
 		    p_hwfn->hw_info.non_offload_tc;
 		qm_info->qm_pq_params[curr_queue].wrr_group = 1;
+		qm_info->qm_pq_params[curr_queue].rl_valid = 1;
 		curr_queue++;
 	}
 
@@ -256,7 +257,10 @@ static int qed_init_qm_info(struct qed_hwfn *p_hwfn, bool b_sleepable)
 	for (i = 0; i < num_ports; i++) {
 		p_qm_port = &qm_info->qm_port_params[i];
 		p_qm_port->active = 1;
-		p_qm_port->num_active_phys_tcs = 4;
+		if (num_ports == 4)
+			p_qm_port->active_phys_tcs = 0x7;
+		else
+			p_qm_port->active_phys_tcs = 0x9f;
 		p_qm_port->num_pbf_cmd_lines = PBF_MAX_CMD_LINES / num_ports;
 		p_qm_port->num_btb_blocks = BTB_MAX_BLOCKS / num_ports;
 	}
@@ -703,8 +707,31 @@ static int qed_hw_init_port(struct qed_hwfn *p_hwfn,
 {
 	int rc = 0;
 
-	rc = qed_init_run(p_hwfn, p_ptt, PHASE_PORT, p_hwfn->port_id,
-			  hw_mode);
+	rc = qed_init_run(p_hwfn, p_ptt, PHASE_PORT, p_hwfn->port_id, hw_mode);
+	if (rc != 0)
+		return rc;
+
+	if (hw_mode & (1 << MODE_MF_SI)) {
+		u8 pf_id = 0;
+
+		if (!qed_hw_init_first_eth(p_hwfn, p_ptt, &pf_id)) {
+			DP_VERBOSE(p_hwfn, NETIF_MSG_IFUP,
+				   "PF[%08x] is first eth on engine\n", pf_id);
+
+			/* We should have configured BIT for ppfid, i.e., the
+			 * relative function number in the port. But there's a
+			 * bug in LLH in BB where the ppfid is actually engine
+			 * based, so we need to take this into account.
+			 */
+			qed_wr(p_hwfn, p_ptt,
+			       NIG_REG_LLH_TAGMAC_DEF_PF_VECTOR, 1 << pf_id);
+		}
+
+		/* Take the protocol-based hit vector if there is a hit,
+		 * otherwise take the other vector.
+		 */
+		qed_wr(p_hwfn, p_ptt, NIG_REG_LLH_CLS_TYPE_DUALMODE, 0x2);
+	}
 	return rc;
 }
 
@@ -773,6 +800,21 @@ static int qed_hw_init_pf(struct qed_hwfn *p_hwfn,
 	/* Pure runtime initializations - directly to the HW  */
 	qed_int_igu_init_pure_rt(p_hwfn, p_ptt, true, true);
 
+	if (hw_mode & (1 << MODE_MF_SI)) {
+		u8 pf_id = 0;
+		u32 val;
+
+		if (!qed_hw_init_first_eth(p_hwfn, p_ptt, &pf_id)) {
+			if (p_hwfn->rel_pf_id == pf_id) {
+				DP_VERBOSE(p_hwfn, NETIF_MSG_IFUP,
+					   "PF[%d] is first ETH on engine\n",
+					   pf_id);
+				val = 1;
+			}
+			qed_wr(p_hwfn, p_ptt, PRS_REG_MSG_INFO, val);
+		}
+	}
+
 	if (b_hw_start) {
 		/* enable interrupts */
 		qed_int_igu_enable(p_hwfn, p_ptt, int_mode);
@@ -1304,31 +1346,31 @@ static int qed_hw_get_nvm_info(struct qed_hwfn *p_hwfn,
 
 	switch ((core_cfg & NVM_CFG1_GLOB_NETWORK_PORT_MODE_MASK) >>
 		NVM_CFG1_GLOB_NETWORK_PORT_MODE_OFFSET) {
-	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_2X40G:
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_BB_2X40G:
 		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_2X40G;
 		break;
-	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_2X50G:
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_2X50G:
 		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_2X50G;
 		break;
-	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_1X100G:
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_BB_1X100G:
 		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_1X100G;
 		break;
-	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_4X10G_F:
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_4X10G_F:
 		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_4X10G_F;
 		break;
-	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_4X10G_E:
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_BB_4X10G_E:
 		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_4X10G_E;
 		break;
-	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_4X20G:
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_BB_4X20G:
 		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_4X20G;
 		break;
-	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_1X40G:
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_1X40G:
 		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_1X40G;
 		break;
-	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_2X25G:
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_2X25G:
 		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_2X25G;
 		break;
-	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_1X25G:
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_1X25G:
 		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_1X25G;
 		break;
 	default:
@@ -1373,7 +1415,7 @@ static int qed_hw_get_nvm_info(struct qed_hwfn *p_hwfn,
 	case NVM_CFG1_PORT_DRV_LINK_SPEED_50G:
 		link->speed.forced_speed = 50000;
 		break;
-	case NVM_CFG1_PORT_DRV_LINK_SPEED_100G:
+	case NVM_CFG1_PORT_DRV_LINK_SPEED_BB_100G:
 		link->speed.forced_speed = 100000;
 		break;
 	default:
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 9afc15f..d104ca7 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -21,9 +21,6 @@
 
 struct qed_hwfn;
 struct qed_ptt;
-/********************************/
-/* Add include to common target */
-/********************************/
 
 /* opcodes for the event ring */
 enum common_event_opcode {
@@ -32,9 +29,10 @@ enum common_event_opcode {
 	COMMON_EVENT_VF_START,
 	COMMON_EVENT_VF_STOP,
 	COMMON_EVENT_VF_PF_CHANNEL,
-	COMMON_EVENT_RESERVED4,
-	COMMON_EVENT_RESERVED5,
-	COMMON_EVENT_RESERVED6,
+	COMMON_EVENT_VF_FLR,
+	COMMON_EVENT_PF_UPDATE,
+	COMMON_EVENT_MALICIOUS_VF,
+	COMMON_EVENT_RL_UPDATE,
 	COMMON_EVENT_EMPTY,
 	MAX_COMMON_EVENT_OPCODE
 };
@@ -42,11 +40,12 @@ enum common_event_opcode {
 /* Common Ramrod Command IDs */
 enum common_ramrod_cmd_id {
 	COMMON_RAMROD_UNUSED,
-	COMMON_RAMROD_PF_START /* PF Function Start Ramrod */,
-	COMMON_RAMROD_PF_STOP /* PF Function Stop Ramrod */,
+	COMMON_RAMROD_PF_START,
+	COMMON_RAMROD_PF_STOP,
 	COMMON_RAMROD_VF_START,
 	COMMON_RAMROD_VF_STOP,
 	COMMON_RAMROD_PF_UPDATE,
+	COMMON_RAMROD_RL_UPDATE,
 	COMMON_RAMROD_EMPTY,
 	MAX_COMMON_RAMROD_CMD_ID
 };
@@ -63,448 +62,448 @@ struct pstorm_core_conn_st_ctx {
 
 /* Core Slowpath Connection storm context of Xstorm */
 struct xstorm_core_conn_st_ctx {
-	__le32		spq_base_lo /* SPQ Ring Base Address low dword */;
-	__le32		spq_base_hi /* SPQ Ring Base Address high dword */;
-	struct regpair	consolid_base_addr;
-	__le16		spq_cons /* SPQ Ring Consumer */;
-	__le16		consolid_cons /* Consolidation Ring Consumer */;
-	__le32		reserved0[55] /* Pad to 15 cycles */;
+	__le32 spq_base_lo;
+	__le32 spq_base_hi;
+	struct regpair consolid_base_addr;
+	__le16 spq_cons;
+	__le16 consolid_cons;
+	__le32 reserved0[55];
 };
 
 struct xstorm_core_conn_ag_ctx {
-	u8	reserved0 /* cdu_validation */;
-	u8	core_state /* state */;
-	u8	flags0;
-#define XSTORM_CORE_CONN_AG_CTX_EXIST_IN_QM0_MASK         0x1
-#define XSTORM_CORE_CONN_AG_CTX_EXIST_IN_QM0_SHIFT        0
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED1_MASK            0x1
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED1_SHIFT           1
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED2_MASK            0x1
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED2_SHIFT           2
-#define XSTORM_CORE_CONN_AG_CTX_EXIST_IN_QM3_MASK         0x1
-#define XSTORM_CORE_CONN_AG_CTX_EXIST_IN_QM3_SHIFT        3
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED3_MASK            0x1
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED3_SHIFT           4
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED4_MASK            0x1
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED4_SHIFT           5
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED5_MASK            0x1   /* bit6 */
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED5_SHIFT           6
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED6_MASK            0x1   /* bit7 */
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED6_SHIFT           7
+	u8 reserved0;
+	u8 core_state;
+	u8 flags0;
+#define XSTORM_CORE_CONN_AG_CTX_EXIST_IN_QM0_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_EXIST_IN_QM0_SHIFT	0
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED1_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED1_SHIFT		1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED2_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED2_SHIFT		2
+#define XSTORM_CORE_CONN_AG_CTX_EXIST_IN_QM3_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_EXIST_IN_QM3_SHIFT	3
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED3_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED3_SHIFT		4
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED4_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED4_SHIFT		5
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED5_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED5_SHIFT		6
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED6_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED6_SHIFT		7
 	u8 flags1;
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED7_MASK            0x1   /* bit8 */
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED7_SHIFT           0
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED8_MASK            0x1   /* bit9 */
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED8_SHIFT           1
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED9_MASK            0x1   /* bit10 */
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED9_SHIFT           2
-#define XSTORM_CORE_CONN_AG_CTX_BIT11_MASK                0x1   /* bit11 */
-#define XSTORM_CORE_CONN_AG_CTX_BIT11_SHIFT               3
-#define XSTORM_CORE_CONN_AG_CTX_BIT12_MASK                0x1   /* bit12 */
-#define XSTORM_CORE_CONN_AG_CTX_BIT12_SHIFT               4
-#define XSTORM_CORE_CONN_AG_CTX_BIT13_MASK                0x1   /* bit13 */
-#define XSTORM_CORE_CONN_AG_CTX_BIT13_SHIFT               5
-#define XSTORM_CORE_CONN_AG_CTX_TX_RULE_ACTIVE_MASK       0x1   /* bit14 */
-#define XSTORM_CORE_CONN_AG_CTX_TX_RULE_ACTIVE_SHIFT      6
-#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_ACTIVE_MASK         0x1   /* bit15 */
-#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_ACTIVE_SHIFT        7
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED7_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED7_SHIFT		0
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED8_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED8_SHIFT		1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED9_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED9_SHIFT		2
+#define XSTORM_CORE_CONN_AG_CTX_BIT11_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_BIT11_SHIFT		3
+#define XSTORM_CORE_CONN_AG_CTX_BIT12_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_BIT12_SHIFT		4
+#define XSTORM_CORE_CONN_AG_CTX_BIT13_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_BIT13_SHIFT		5
+#define XSTORM_CORE_CONN_AG_CTX_TX_RULE_ACTIVE_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_TX_RULE_ACTIVE_SHIFT	6
+#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_ACTIVE_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_ACTIVE_SHIFT	7
 	u8 flags2;
-#define XSTORM_CORE_CONN_AG_CTX_CF0_MASK                  0x3   /* timer0cf */
-#define XSTORM_CORE_CONN_AG_CTX_CF0_SHIFT                 0
-#define XSTORM_CORE_CONN_AG_CTX_CF1_MASK                  0x3   /* timer1cf */
-#define XSTORM_CORE_CONN_AG_CTX_CF1_SHIFT                 2
-#define XSTORM_CORE_CONN_AG_CTX_CF2_MASK                  0x3   /* timer2cf */
-#define XSTORM_CORE_CONN_AG_CTX_CF2_SHIFT                 4
-#define XSTORM_CORE_CONN_AG_CTX_CF3_MASK                  0x3
-#define XSTORM_CORE_CONN_AG_CTX_CF3_SHIFT                 6
+#define XSTORM_CORE_CONN_AG_CTX_CF0_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF0_SHIFT	0
+#define XSTORM_CORE_CONN_AG_CTX_CF1_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF1_SHIFT	2
+#define XSTORM_CORE_CONN_AG_CTX_CF2_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF2_SHIFT	4
+#define XSTORM_CORE_CONN_AG_CTX_CF3_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF3_SHIFT	6
 	u8 flags3;
-#define XSTORM_CORE_CONN_AG_CTX_CF4_MASK                  0x3   /* cf4 */
-#define XSTORM_CORE_CONN_AG_CTX_CF4_SHIFT                 0
-#define XSTORM_CORE_CONN_AG_CTX_CF5_MASK                  0x3   /* cf5 */
-#define XSTORM_CORE_CONN_AG_CTX_CF5_SHIFT                 2
-#define XSTORM_CORE_CONN_AG_CTX_CF6_MASK                  0x3   /* cf6 */
-#define XSTORM_CORE_CONN_AG_CTX_CF6_SHIFT                 4
-#define XSTORM_CORE_CONN_AG_CTX_CF7_MASK                  0x3   /* cf7 */
-#define XSTORM_CORE_CONN_AG_CTX_CF7_SHIFT                 6
+#define XSTORM_CORE_CONN_AG_CTX_CF4_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF4_SHIFT	0
+#define XSTORM_CORE_CONN_AG_CTX_CF5_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF5_SHIFT	2
+#define XSTORM_CORE_CONN_AG_CTX_CF6_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF6_SHIFT	4
+#define XSTORM_CORE_CONN_AG_CTX_CF7_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF7_SHIFT	6
 	u8 flags4;
-#define XSTORM_CORE_CONN_AG_CTX_CF8_MASK                  0x3   /* cf8 */
-#define XSTORM_CORE_CONN_AG_CTX_CF8_SHIFT                 0
-#define XSTORM_CORE_CONN_AG_CTX_CF9_MASK                  0x3   /* cf9 */
-#define XSTORM_CORE_CONN_AG_CTX_CF9_SHIFT                 2
-#define XSTORM_CORE_CONN_AG_CTX_CF10_MASK                 0x3   /* cf10 */
-#define XSTORM_CORE_CONN_AG_CTX_CF10_SHIFT                4
-#define XSTORM_CORE_CONN_AG_CTX_CF11_MASK                 0x3   /* cf11 */
-#define XSTORM_CORE_CONN_AG_CTX_CF11_SHIFT                6
+#define XSTORM_CORE_CONN_AG_CTX_CF8_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF8_SHIFT	0
+#define XSTORM_CORE_CONN_AG_CTX_CF9_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF9_SHIFT	2
+#define XSTORM_CORE_CONN_AG_CTX_CF10_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF10_SHIFT	4
+#define XSTORM_CORE_CONN_AG_CTX_CF11_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF11_SHIFT	6
 	u8 flags5;
-#define XSTORM_CORE_CONN_AG_CTX_CF12_MASK                 0x3   /* cf12 */
-#define XSTORM_CORE_CONN_AG_CTX_CF12_SHIFT                0
-#define XSTORM_CORE_CONN_AG_CTX_CF13_MASK                 0x3   /* cf13 */
-#define XSTORM_CORE_CONN_AG_CTX_CF13_SHIFT                2
-#define XSTORM_CORE_CONN_AG_CTX_CF14_MASK                 0x3   /* cf14 */
-#define XSTORM_CORE_CONN_AG_CTX_CF14_SHIFT                4
-#define XSTORM_CORE_CONN_AG_CTX_CF15_MASK                 0x3   /* cf15 */
-#define XSTORM_CORE_CONN_AG_CTX_CF15_SHIFT                6
+#define XSTORM_CORE_CONN_AG_CTX_CF12_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF12_SHIFT	0
+#define XSTORM_CORE_CONN_AG_CTX_CF13_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF13_SHIFT	2
+#define XSTORM_CORE_CONN_AG_CTX_CF14_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF14_SHIFT	4
+#define XSTORM_CORE_CONN_AG_CTX_CF15_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF15_SHIFT	6
 	u8 flags6;
-#define XSTORM_CORE_CONN_AG_CTX_CONSOLID_PROD_CF_MASK     0x3   /* cf16 */
-#define XSTORM_CORE_CONN_AG_CTX_CONSOLID_PROD_CF_SHIFT    0
-#define XSTORM_CORE_CONN_AG_CTX_CF17_MASK                 0x3
-#define XSTORM_CORE_CONN_AG_CTX_CF17_SHIFT                2
-#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_MASK                0x3   /* cf18 */
-#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_SHIFT               4
-#define XSTORM_CORE_CONN_AG_CTX_TERMINATE_CF_MASK         0x3   /* cf19 */
-#define XSTORM_CORE_CONN_AG_CTX_TERMINATE_CF_SHIFT        6
+#define XSTORM_CORE_CONN_AG_CTX_CONSOLID_PROD_CF_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CONSOLID_PROD_CF_SHIFT	0
+#define XSTORM_CORE_CONN_AG_CTX_CF17_MASK		0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF17_SHIFT		2
+#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_MASK		0x3
+#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_SHIFT		4
+#define XSTORM_CORE_CONN_AG_CTX_TERMINATE_CF_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_TERMINATE_CF_SHIFT	6
 	u8 flags7;
-#define XSTORM_CORE_CONN_AG_CTX_FLUSH_Q0_MASK             0x3   /* cf20 */
-#define XSTORM_CORE_CONN_AG_CTX_FLUSH_Q0_SHIFT            0
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED10_MASK           0x3   /* cf21 */
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED10_SHIFT          2
-#define XSTORM_CORE_CONN_AG_CTX_SLOW_PATH_MASK            0x3   /* cf22 */
-#define XSTORM_CORE_CONN_AG_CTX_SLOW_PATH_SHIFT           4
-#define XSTORM_CORE_CONN_AG_CTX_CF0EN_MASK                0x1   /* cf0en */
-#define XSTORM_CORE_CONN_AG_CTX_CF0EN_SHIFT               6
-#define XSTORM_CORE_CONN_AG_CTX_CF1EN_MASK                0x1   /* cf1en */
-#define XSTORM_CORE_CONN_AG_CTX_CF1EN_SHIFT               7
+#define XSTORM_CORE_CONN_AG_CTX_FLUSH_Q0_MASK		0x3
+#define XSTORM_CORE_CONN_AG_CTX_FLUSH_Q0_SHIFT		0
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED10_MASK		0x3
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED10_SHIFT	2
+#define XSTORM_CORE_CONN_AG_CTX_SLOW_PATH_MASK		0x3
+#define XSTORM_CORE_CONN_AG_CTX_SLOW_PATH_SHIFT		4
+#define XSTORM_CORE_CONN_AG_CTX_CF0EN_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF0EN_SHIFT		6
+#define XSTORM_CORE_CONN_AG_CTX_CF1EN_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF1EN_SHIFT		7
 	u8 flags8;
-#define XSTORM_CORE_CONN_AG_CTX_CF2EN_MASK                0x1   /* cf2en */
-#define XSTORM_CORE_CONN_AG_CTX_CF2EN_SHIFT               0
-#define XSTORM_CORE_CONN_AG_CTX_CF3EN_MASK                0x1   /* cf3en */
-#define XSTORM_CORE_CONN_AG_CTX_CF3EN_SHIFT               1
-#define XSTORM_CORE_CONN_AG_CTX_CF4EN_MASK                0x1   /* cf4en */
-#define XSTORM_CORE_CONN_AG_CTX_CF4EN_SHIFT               2
-#define XSTORM_CORE_CONN_AG_CTX_CF5EN_MASK                0x1   /* cf5en */
-#define XSTORM_CORE_CONN_AG_CTX_CF5EN_SHIFT               3
-#define XSTORM_CORE_CONN_AG_CTX_CF6EN_MASK                0x1   /* cf6en */
-#define XSTORM_CORE_CONN_AG_CTX_CF6EN_SHIFT               4
-#define XSTORM_CORE_CONN_AG_CTX_CF7EN_MASK                0x1   /* cf7en */
-#define XSTORM_CORE_CONN_AG_CTX_CF7EN_SHIFT               5
-#define XSTORM_CORE_CONN_AG_CTX_CF8EN_MASK                0x1   /* cf8en */
-#define XSTORM_CORE_CONN_AG_CTX_CF8EN_SHIFT               6
-#define XSTORM_CORE_CONN_AG_CTX_CF9EN_MASK                0x1   /* cf9en */
-#define XSTORM_CORE_CONN_AG_CTX_CF9EN_SHIFT               7
+#define XSTORM_CORE_CONN_AG_CTX_CF2EN_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF2EN_SHIFT	0
+#define XSTORM_CORE_CONN_AG_CTX_CF3EN_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF3EN_SHIFT	1
+#define XSTORM_CORE_CONN_AG_CTX_CF4EN_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF4EN_SHIFT	2
+#define XSTORM_CORE_CONN_AG_CTX_CF5EN_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF5EN_SHIFT	3
+#define XSTORM_CORE_CONN_AG_CTX_CF6EN_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF6EN_SHIFT	4
+#define XSTORM_CORE_CONN_AG_CTX_CF7EN_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF7EN_SHIFT	5
+#define XSTORM_CORE_CONN_AG_CTX_CF8EN_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF8EN_SHIFT	6
+#define XSTORM_CORE_CONN_AG_CTX_CF9EN_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF9EN_SHIFT	7
 	u8 flags9;
-#define XSTORM_CORE_CONN_AG_CTX_CF10EN_MASK               0x1   /* cf10en */
-#define XSTORM_CORE_CONN_AG_CTX_CF10EN_SHIFT              0
-#define XSTORM_CORE_CONN_AG_CTX_CF11EN_MASK               0x1   /* cf11en */
-#define XSTORM_CORE_CONN_AG_CTX_CF11EN_SHIFT              1
-#define XSTORM_CORE_CONN_AG_CTX_CF12EN_MASK               0x1   /* cf12en */
-#define XSTORM_CORE_CONN_AG_CTX_CF12EN_SHIFT              2
-#define XSTORM_CORE_CONN_AG_CTX_CF13EN_MASK               0x1   /* cf13en */
-#define XSTORM_CORE_CONN_AG_CTX_CF13EN_SHIFT              3
-#define XSTORM_CORE_CONN_AG_CTX_CF14EN_MASK               0x1   /* cf14en */
-#define XSTORM_CORE_CONN_AG_CTX_CF14EN_SHIFT              4
-#define XSTORM_CORE_CONN_AG_CTX_CF15EN_MASK               0x1   /* cf15en */
-#define XSTORM_CORE_CONN_AG_CTX_CF15EN_SHIFT              5
-#define XSTORM_CORE_CONN_AG_CTX_CONSOLID_PROD_CF_EN_MASK  0x1   /* cf16en */
-#define XSTORM_CORE_CONN_AG_CTX_CONSOLID_PROD_CF_EN_SHIFT 6
-#define XSTORM_CORE_CONN_AG_CTX_CF17EN_MASK               0x1
-#define XSTORM_CORE_CONN_AG_CTX_CF17EN_SHIFT              7
+#define XSTORM_CORE_CONN_AG_CTX_CF10EN_MASK			0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF10EN_SHIFT			0
+#define XSTORM_CORE_CONN_AG_CTX_CF11EN_MASK			0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF11EN_SHIFT			1
+#define XSTORM_CORE_CONN_AG_CTX_CF12EN_MASK			0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF12EN_SHIFT			2
+#define XSTORM_CORE_CONN_AG_CTX_CF13EN_MASK			0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF13EN_SHIFT			3
+#define XSTORM_CORE_CONN_AG_CTX_CF14EN_MASK			0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF14EN_SHIFT			4
+#define XSTORM_CORE_CONN_AG_CTX_CF15EN_MASK			0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF15EN_SHIFT			5
+#define XSTORM_CORE_CONN_AG_CTX_CONSOLID_PROD_CF_EN_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_CONSOLID_PROD_CF_EN_SHIFT	6
+#define XSTORM_CORE_CONN_AG_CTX_CF17EN_MASK			0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF17EN_SHIFT			7
 	u8 flags10;
-#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_EN_MASK             0x1   /* cf18en */
-#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_EN_SHIFT            0
-#define XSTORM_CORE_CONN_AG_CTX_TERMINATE_CF_EN_MASK      0x1   /* cf19en */
-#define XSTORM_CORE_CONN_AG_CTX_TERMINATE_CF_EN_SHIFT     1
-#define XSTORM_CORE_CONN_AG_CTX_FLUSH_Q0_EN_MASK          0x1   /* cf20en */
-#define XSTORM_CORE_CONN_AG_CTX_FLUSH_Q0_EN_SHIFT         2
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED11_MASK           0x1   /* cf21en */
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED11_SHIFT          3
-#define XSTORM_CORE_CONN_AG_CTX_SLOW_PATH_EN_MASK         0x1   /* cf22en */
-#define XSTORM_CORE_CONN_AG_CTX_SLOW_PATH_EN_SHIFT        4
-#define XSTORM_CORE_CONN_AG_CTX_CF23EN_MASK               0x1   /* cf23en */
-#define XSTORM_CORE_CONN_AG_CTX_CF23EN_SHIFT              5
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED12_MASK           0x1   /* rule0en */
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED12_SHIFT          6
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED13_MASK           0x1   /* rule1en */
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED13_SHIFT          7
+#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_EN_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_DQ_CF_EN_SHIFT		0
+#define XSTORM_CORE_CONN_AG_CTX_TERMINATE_CF_EN_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_TERMINATE_CF_EN_SHIFT	1
+#define XSTORM_CORE_CONN_AG_CTX_FLUSH_Q0_EN_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_FLUSH_Q0_EN_SHIFT	2
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED11_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED11_SHIFT	3
+#define XSTORM_CORE_CONN_AG_CTX_SLOW_PATH_EN_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_SLOW_PATH_EN_SHIFT	4
+#define XSTORM_CORE_CONN_AG_CTX_CF23EN_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_CF23EN_SHIFT		5
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED12_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED12_SHIFT	6
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED13_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED13_SHIFT	7
 	u8 flags11;
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED14_MASK           0x1   /* rule2en */
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED14_SHIFT          0
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED15_MASK           0x1   /* rule3en */
-#define XSTORM_CORE_CONN_AG_CTX_RESERVED15_SHIFT          1
-#define XSTORM_CORE_CONN_AG_CTX_TX_DEC_RULE_EN_MASK       0x1   /* rule4en */
-#define XSTORM_CORE_CONN_AG_CTX_TX_DEC_RULE_EN_SHIFT      2
-#define XSTORM_CORE_CONN_AG_CTX_RULE5EN_MASK              0x1   /* rule5en */
-#define XSTORM_CORE_CONN_AG_CTX_RULE5EN_SHIFT             3
-#define XSTORM_CORE_CONN_AG_CTX_RULE6EN_MASK              0x1   /* rule6en */
-#define XSTORM_CORE_CONN_AG_CTX_RULE6EN_SHIFT             4
-#define XSTORM_CORE_CONN_AG_CTX_RULE7EN_MASK              0x1   /* rule7en */
-#define XSTORM_CORE_CONN_AG_CTX_RULE7EN_SHIFT             5
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED1_MASK         0x1   /* rule8en */
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED1_SHIFT        6
-#define XSTORM_CORE_CONN_AG_CTX_RULE9EN_MASK              0x1   /* rule9en */
-#define XSTORM_CORE_CONN_AG_CTX_RULE9EN_SHIFT             7
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED14_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED14_SHIFT	0
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED15_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RESERVED15_SHIFT	1
+#define XSTORM_CORE_CONN_AG_CTX_TX_DEC_RULE_EN_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_TX_DEC_RULE_EN_SHIFT	2
+#define XSTORM_CORE_CONN_AG_CTX_RULE5EN_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RULE5EN_SHIFT		3
+#define XSTORM_CORE_CONN_AG_CTX_RULE6EN_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RULE6EN_SHIFT		4
+#define XSTORM_CORE_CONN_AG_CTX_RULE7EN_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RULE7EN_SHIFT		5
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED1_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED1_SHIFT	6
+#define XSTORM_CORE_CONN_AG_CTX_RULE9EN_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RULE9EN_SHIFT		7
 	u8 flags12;
-#define XSTORM_CORE_CONN_AG_CTX_RULE10EN_MASK             0x1   /* rule10en */
-#define XSTORM_CORE_CONN_AG_CTX_RULE10EN_SHIFT            0
-#define XSTORM_CORE_CONN_AG_CTX_RULE11EN_MASK             0x1   /* rule11en */
-#define XSTORM_CORE_CONN_AG_CTX_RULE11EN_SHIFT            1
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED2_MASK         0x1   /* rule12en */
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED2_SHIFT        2
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED3_MASK         0x1   /* rule13en */
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED3_SHIFT        3
-#define XSTORM_CORE_CONN_AG_CTX_RULE14EN_MASK             0x1   /* rule14en */
-#define XSTORM_CORE_CONN_AG_CTX_RULE14EN_SHIFT            4
-#define XSTORM_CORE_CONN_AG_CTX_RULE15EN_MASK             0x1   /* rule15en */
-#define XSTORM_CORE_CONN_AG_CTX_RULE15EN_SHIFT            5
-#define XSTORM_CORE_CONN_AG_CTX_RULE16EN_MASK             0x1   /* rule16en */
-#define XSTORM_CORE_CONN_AG_CTX_RULE16EN_SHIFT            6
-#define XSTORM_CORE_CONN_AG_CTX_RULE17EN_MASK             0x1   /* rule17en */
-#define XSTORM_CORE_CONN_AG_CTX_RULE17EN_SHIFT            7
+#define XSTORM_CORE_CONN_AG_CTX_RULE10EN_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RULE10EN_SHIFT		0
+#define XSTORM_CORE_CONN_AG_CTX_RULE11EN_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RULE11EN_SHIFT		1
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED2_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED2_SHIFT	2
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED3_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED3_SHIFT	3
+#define XSTORM_CORE_CONN_AG_CTX_RULE14EN_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RULE14EN_SHIFT		4
+#define XSTORM_CORE_CONN_AG_CTX_RULE15EN_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RULE15EN_SHIFT		5
+#define XSTORM_CORE_CONN_AG_CTX_RULE16EN_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RULE16EN_SHIFT		6
+#define XSTORM_CORE_CONN_AG_CTX_RULE17EN_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RULE17EN_SHIFT		7
 	u8 flags13;
-#define XSTORM_CORE_CONN_AG_CTX_RULE18EN_MASK             0x1   /* rule18en */
-#define XSTORM_CORE_CONN_AG_CTX_RULE18EN_SHIFT            0
-#define XSTORM_CORE_CONN_AG_CTX_RULE19EN_MASK             0x1   /* rule19en */
-#define XSTORM_CORE_CONN_AG_CTX_RULE19EN_SHIFT            1
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED4_MASK         0x1   /* rule20en */
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED4_SHIFT        2
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED5_MASK         0x1   /* rule21en */
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED5_SHIFT        3
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED6_MASK         0x1   /* rule22en */
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED6_SHIFT        4
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED7_MASK         0x1   /* rule23en */
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED7_SHIFT        5
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED8_MASK         0x1   /* rule24en */
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED8_SHIFT        6
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED9_MASK         0x1   /* rule25en */
-#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED9_SHIFT        7
+#define XSTORM_CORE_CONN_AG_CTX_RULE18EN_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RULE18EN_SHIFT		0
+#define XSTORM_CORE_CONN_AG_CTX_RULE19EN_MASK		0x1
+#define XSTORM_CORE_CONN_AG_CTX_RULE19EN_SHIFT		1
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED4_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED4_SHIFT	2
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED5_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED5_SHIFT	3
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED6_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED6_SHIFT	4
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED7_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED7_SHIFT	5
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED8_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED8_SHIFT	6
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED9_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_A0_RESERVED9_SHIFT	7
 	u8 flags14;
-#define XSTORM_CORE_CONN_AG_CTX_BIT16_MASK                0x1   /* bit16 */
-#define XSTORM_CORE_CONN_AG_CTX_BIT16_SHIFT               0
-#define XSTORM_CORE_CONN_AG_CTX_BIT17_MASK                0x1   /* bit17 */
-#define XSTORM_CORE_CONN_AG_CTX_BIT17_SHIFT               1
-#define XSTORM_CORE_CONN_AG_CTX_BIT18_MASK                0x1   /* bit18 */
-#define XSTORM_CORE_CONN_AG_CTX_BIT18_SHIFT               2
-#define XSTORM_CORE_CONN_AG_CTX_BIT19_MASK                0x1   /* bit19 */
-#define XSTORM_CORE_CONN_AG_CTX_BIT19_SHIFT               3
-#define XSTORM_CORE_CONN_AG_CTX_BIT20_MASK                0x1   /* bit20 */
-#define XSTORM_CORE_CONN_AG_CTX_BIT20_SHIFT               4
-#define XSTORM_CORE_CONN_AG_CTX_BIT21_MASK                0x1   /* bit21 */
-#define XSTORM_CORE_CONN_AG_CTX_BIT21_SHIFT               5
-#define XSTORM_CORE_CONN_AG_CTX_CF23_MASK                 0x3   /* cf23 */
-#define XSTORM_CORE_CONN_AG_CTX_CF23_SHIFT                6
-	u8	byte2 /* byte2 */;
-	__le16	physical_q0 /* physical_q0 */;
-	__le16	consolid_prod /* physical_q1 */;
-	__le16	reserved16 /* physical_q2 */;
-	__le16	tx_bd_cons /* word3 */;
-	__le16	tx_bd_or_spq_prod /* word4 */;
-	__le16	word5 /* word5 */;
-	__le16	conn_dpi /* conn_dpi */;
-	u8	byte3 /* byte3 */;
-	u8	byte4 /* byte4 */;
-	u8	byte5 /* byte5 */;
-	u8	byte6 /* byte6 */;
-	__le32	reg0 /* reg0 */;
-	__le32	reg1 /* reg1 */;
-	__le32	reg2 /* reg2 */;
-	__le32	reg3 /* reg3 */;
-	__le32	reg4 /* reg4 */;
-	__le32	reg5 /* cf_array0 */;
-	__le32	reg6 /* cf_array1 */;
-	__le16	word7 /* word7 */;
-	__le16	word8 /* word8 */;
-	__le16	word9 /* word9 */;
-	__le16	word10 /* word10 */;
-	__le32	reg7 /* reg7 */;
-	__le32	reg8 /* reg8 */;
-	__le32	reg9 /* reg9 */;
-	u8	byte7 /* byte7 */;
-	u8	byte8 /* byte8 */;
-	u8	byte9 /* byte9 */;
-	u8	byte10 /* byte10 */;
-	u8	byte11 /* byte11 */;
-	u8	byte12 /* byte12 */;
-	u8	byte13 /* byte13 */;
-	u8	byte14 /* byte14 */;
-	u8	byte15 /* byte15 */;
-	u8	byte16 /* byte16 */;
-	__le16	word11 /* word11 */;
-	__le32	reg10 /* reg10 */;
-	__le32	reg11 /* reg11 */;
-	__le32	reg12 /* reg12 */;
-	__le32	reg13 /* reg13 */;
-	__le32	reg14 /* reg14 */;
-	__le32	reg15 /* reg15 */;
-	__le32	reg16 /* reg16 */;
-	__le32	reg17 /* reg17 */;
-	__le32	reg18 /* reg18 */;
-	__le32	reg19 /* reg19 */;
-	__le16	word12 /* word12 */;
-	__le16	word13 /* word13 */;
-	__le16	word14 /* word14 */;
-	__le16	word15 /* word15 */;
+#define XSTORM_CORE_CONN_AG_CTX_BIT16_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_BIT16_SHIFT	0
+#define XSTORM_CORE_CONN_AG_CTX_BIT17_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_BIT17_SHIFT	1
+#define XSTORM_CORE_CONN_AG_CTX_BIT18_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_BIT18_SHIFT	2
+#define XSTORM_CORE_CONN_AG_CTX_BIT19_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_BIT19_SHIFT	3
+#define XSTORM_CORE_CONN_AG_CTX_BIT20_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_BIT20_SHIFT	4
+#define XSTORM_CORE_CONN_AG_CTX_BIT21_MASK	0x1
+#define XSTORM_CORE_CONN_AG_CTX_BIT21_SHIFT	5
+#define XSTORM_CORE_CONN_AG_CTX_CF23_MASK	0x3
+#define XSTORM_CORE_CONN_AG_CTX_CF23_SHIFT	6
+	u8 byte2;
+	__le16 physical_q0;
+	__le16 consolid_prod;
+	__le16 reserved16;
+	__le16 tx_bd_cons;
+	__le16 tx_bd_or_spq_prod;
+	__le16 word5;
+	__le16 conn_dpi;
+	u8 byte3;
+	u8 byte4;
+	u8 byte5;
+	u8 byte6;
+	__le32 reg0;
+	__le32 reg1;
+	__le32 reg2;
+	__le32 reg3;
+	__le32 reg4;
+	__le32 reg5;
+	__le32 reg6;
+	__le16 word7;
+	__le16 word8;
+	__le16 word9;
+	__le16 word10;
+	__le32 reg7;
+	__le32 reg8;
+	__le32 reg9;
+	u8 byte7;
+	u8 byte8;
+	u8 byte9;
+	u8 byte10;
+	u8 byte11;
+	u8 byte12;
+	u8 byte13;
+	u8 byte14;
+	u8 byte15;
+	u8 byte16;
+	__le16 word11;
+	__le32 reg10;
+	__le32 reg11;
+	__le32 reg12;
+	__le32 reg13;
+	__le32 reg14;
+	__le32 reg15;
+	__le32 reg16;
+	__le32 reg17;
+	__le32 reg18;
+	__le32 reg19;
+	__le16 word12;
+	__le16 word13;
+	__le16 word14;
+	__le16 word15;
 };
 
 struct tstorm_core_conn_ag_ctx {
-	u8	byte0 /* cdu_validation */;
-	u8	byte1 /* state */;
-	u8	flags0;
-#define TSTORM_CORE_CONN_AG_CTX_BIT0_MASK     0x1       /* exist_in_qm0 */
-#define TSTORM_CORE_CONN_AG_CTX_BIT0_SHIFT    0
-#define TSTORM_CORE_CONN_AG_CTX_BIT1_MASK     0x1       /* exist_in_qm1 */
-#define TSTORM_CORE_CONN_AG_CTX_BIT1_SHIFT    1
-#define TSTORM_CORE_CONN_AG_CTX_BIT2_MASK     0x1       /* bit2 */
-#define TSTORM_CORE_CONN_AG_CTX_BIT2_SHIFT    2
-#define TSTORM_CORE_CONN_AG_CTX_BIT3_MASK     0x1       /* bit3 */
-#define TSTORM_CORE_CONN_AG_CTX_BIT3_SHIFT    3
-#define TSTORM_CORE_CONN_AG_CTX_BIT4_MASK     0x1       /* bit4 */
-#define TSTORM_CORE_CONN_AG_CTX_BIT4_SHIFT    4
-#define TSTORM_CORE_CONN_AG_CTX_BIT5_MASK     0x1       /* bit5 */
-#define TSTORM_CORE_CONN_AG_CTX_BIT5_SHIFT    5
-#define TSTORM_CORE_CONN_AG_CTX_CF0_MASK      0x3       /* timer0cf */
-#define TSTORM_CORE_CONN_AG_CTX_CF0_SHIFT     6
+	u8 byte0;
+	u8 byte1;
+	u8 flags0;
+#define TSTORM_CORE_CONN_AG_CTX_BIT0_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_BIT0_SHIFT	0
+#define TSTORM_CORE_CONN_AG_CTX_BIT1_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_BIT1_SHIFT	1
+#define TSTORM_CORE_CONN_AG_CTX_BIT2_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_BIT2_SHIFT	2
+#define TSTORM_CORE_CONN_AG_CTX_BIT3_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_BIT3_SHIFT	3
+#define TSTORM_CORE_CONN_AG_CTX_BIT4_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_BIT4_SHIFT	4
+#define TSTORM_CORE_CONN_AG_CTX_BIT5_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_BIT5_SHIFT	5
+#define TSTORM_CORE_CONN_AG_CTX_CF0_MASK	0x3
+#define TSTORM_CORE_CONN_AG_CTX_CF0_SHIFT	6
 	u8 flags1;
-#define TSTORM_CORE_CONN_AG_CTX_CF1_MASK      0x3       /* timer1cf */
-#define TSTORM_CORE_CONN_AG_CTX_CF1_SHIFT     0
-#define TSTORM_CORE_CONN_AG_CTX_CF2_MASK      0x3       /* timer2cf */
-#define TSTORM_CORE_CONN_AG_CTX_CF2_SHIFT     2
-#define TSTORM_CORE_CONN_AG_CTX_CF3_MASK      0x3       /* timer_stop_all */
-#define TSTORM_CORE_CONN_AG_CTX_CF3_SHIFT     4
-#define TSTORM_CORE_CONN_AG_CTX_CF4_MASK      0x3       /* cf4 */
-#define TSTORM_CORE_CONN_AG_CTX_CF4_SHIFT     6
+#define TSTORM_CORE_CONN_AG_CTX_CF1_MASK	0x3
+#define TSTORM_CORE_CONN_AG_CTX_CF1_SHIFT	0
+#define TSTORM_CORE_CONN_AG_CTX_CF2_MASK	0x3
+#define TSTORM_CORE_CONN_AG_CTX_CF2_SHIFT	2
+#define TSTORM_CORE_CONN_AG_CTX_CF3_MASK	0x3
+#define TSTORM_CORE_CONN_AG_CTX_CF3_SHIFT	4
+#define TSTORM_CORE_CONN_AG_CTX_CF4_MASK	0x3
+#define TSTORM_CORE_CONN_AG_CTX_CF4_SHIFT	6
 	u8 flags2;
-#define TSTORM_CORE_CONN_AG_CTX_CF5_MASK      0x3       /* cf5 */
-#define TSTORM_CORE_CONN_AG_CTX_CF5_SHIFT     0
-#define TSTORM_CORE_CONN_AG_CTX_CF6_MASK      0x3       /* cf6 */
-#define TSTORM_CORE_CONN_AG_CTX_CF6_SHIFT     2
-#define TSTORM_CORE_CONN_AG_CTX_CF7_MASK      0x3       /* cf7 */
-#define TSTORM_CORE_CONN_AG_CTX_CF7_SHIFT     4
-#define TSTORM_CORE_CONN_AG_CTX_CF8_MASK      0x3       /* cf8 */
-#define TSTORM_CORE_CONN_AG_CTX_CF8_SHIFT     6
+#define TSTORM_CORE_CONN_AG_CTX_CF5_MASK	0x3
+#define TSTORM_CORE_CONN_AG_CTX_CF5_SHIFT	0
+#define TSTORM_CORE_CONN_AG_CTX_CF6_MASK	0x3
+#define TSTORM_CORE_CONN_AG_CTX_CF6_SHIFT	2
+#define TSTORM_CORE_CONN_AG_CTX_CF7_MASK	0x3
+#define TSTORM_CORE_CONN_AG_CTX_CF7_SHIFT	4
+#define TSTORM_CORE_CONN_AG_CTX_CF8_MASK	0x3
+#define TSTORM_CORE_CONN_AG_CTX_CF8_SHIFT	6
 	u8 flags3;
-#define TSTORM_CORE_CONN_AG_CTX_CF9_MASK      0x3       /* cf9 */
-#define TSTORM_CORE_CONN_AG_CTX_CF9_SHIFT     0
-#define TSTORM_CORE_CONN_AG_CTX_CF10_MASK     0x3       /* cf10 */
-#define TSTORM_CORE_CONN_AG_CTX_CF10_SHIFT    2
-#define TSTORM_CORE_CONN_AG_CTX_CF0EN_MASK    0x1       /* cf0en */
-#define TSTORM_CORE_CONN_AG_CTX_CF0EN_SHIFT   4
-#define TSTORM_CORE_CONN_AG_CTX_CF1EN_MASK    0x1       /* cf1en */
-#define TSTORM_CORE_CONN_AG_CTX_CF1EN_SHIFT   5
-#define TSTORM_CORE_CONN_AG_CTX_CF2EN_MASK    0x1       /* cf2en */
-#define TSTORM_CORE_CONN_AG_CTX_CF2EN_SHIFT   6
-#define TSTORM_CORE_CONN_AG_CTX_CF3EN_MASK    0x1       /* cf3en */
-#define TSTORM_CORE_CONN_AG_CTX_CF3EN_SHIFT   7
+#define TSTORM_CORE_CONN_AG_CTX_CF9_MASK	0x3
+#define TSTORM_CORE_CONN_AG_CTX_CF9_SHIFT	0
+#define TSTORM_CORE_CONN_AG_CTX_CF10_MASK	0x3
+#define TSTORM_CORE_CONN_AG_CTX_CF10_SHIFT	2
+#define TSTORM_CORE_CONN_AG_CTX_CF0EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_CF0EN_SHIFT	4
+#define TSTORM_CORE_CONN_AG_CTX_CF1EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_CF1EN_SHIFT	5
+#define TSTORM_CORE_CONN_AG_CTX_CF2EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_CF2EN_SHIFT	6
+#define TSTORM_CORE_CONN_AG_CTX_CF3EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_CF3EN_SHIFT	7
 	u8 flags4;
-#define TSTORM_CORE_CONN_AG_CTX_CF4EN_MASK    0x1       /* cf4en */
-#define TSTORM_CORE_CONN_AG_CTX_CF4EN_SHIFT   0
-#define TSTORM_CORE_CONN_AG_CTX_CF5EN_MASK    0x1       /* cf5en */
-#define TSTORM_CORE_CONN_AG_CTX_CF5EN_SHIFT   1
-#define TSTORM_CORE_CONN_AG_CTX_CF6EN_MASK    0x1       /* cf6en */
-#define TSTORM_CORE_CONN_AG_CTX_CF6EN_SHIFT   2
-#define TSTORM_CORE_CONN_AG_CTX_CF7EN_MASK    0x1       /* cf7en */
-#define TSTORM_CORE_CONN_AG_CTX_CF7EN_SHIFT   3
-#define TSTORM_CORE_CONN_AG_CTX_CF8EN_MASK    0x1       /* cf8en */
-#define TSTORM_CORE_CONN_AG_CTX_CF8EN_SHIFT   4
-#define TSTORM_CORE_CONN_AG_CTX_CF9EN_MASK    0x1       /* cf9en */
-#define TSTORM_CORE_CONN_AG_CTX_CF9EN_SHIFT   5
-#define TSTORM_CORE_CONN_AG_CTX_CF10EN_MASK   0x1       /* cf10en */
-#define TSTORM_CORE_CONN_AG_CTX_CF10EN_SHIFT  6
-#define TSTORM_CORE_CONN_AG_CTX_RULE0EN_MASK  0x1       /* rule0en */
-#define TSTORM_CORE_CONN_AG_CTX_RULE0EN_SHIFT 7
+#define TSTORM_CORE_CONN_AG_CTX_CF4EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_CF4EN_SHIFT	0
+#define TSTORM_CORE_CONN_AG_CTX_CF5EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_CF5EN_SHIFT	1
+#define TSTORM_CORE_CONN_AG_CTX_CF6EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_CF6EN_SHIFT	2
+#define TSTORM_CORE_CONN_AG_CTX_CF7EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_CF7EN_SHIFT	3
+#define TSTORM_CORE_CONN_AG_CTX_CF8EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_CF8EN_SHIFT	4
+#define TSTORM_CORE_CONN_AG_CTX_CF9EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_CF9EN_SHIFT	5
+#define TSTORM_CORE_CONN_AG_CTX_CF10EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_CF10EN_SHIFT	6
+#define TSTORM_CORE_CONN_AG_CTX_RULE0EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_RULE0EN_SHIFT	7
 	u8 flags5;
-#define TSTORM_CORE_CONN_AG_CTX_RULE1EN_MASK  0x1       /* rule1en */
-#define TSTORM_CORE_CONN_AG_CTX_RULE1EN_SHIFT 0
-#define TSTORM_CORE_CONN_AG_CTX_RULE2EN_MASK  0x1       /* rule2en */
-#define TSTORM_CORE_CONN_AG_CTX_RULE2EN_SHIFT 1
-#define TSTORM_CORE_CONN_AG_CTX_RULE3EN_MASK  0x1       /* rule3en */
-#define TSTORM_CORE_CONN_AG_CTX_RULE3EN_SHIFT 2
-#define TSTORM_CORE_CONN_AG_CTX_RULE4EN_MASK  0x1       /* rule4en */
-#define TSTORM_CORE_CONN_AG_CTX_RULE4EN_SHIFT 3
-#define TSTORM_CORE_CONN_AG_CTX_RULE5EN_MASK  0x1       /* rule5en */
-#define TSTORM_CORE_CONN_AG_CTX_RULE5EN_SHIFT 4
-#define TSTORM_CORE_CONN_AG_CTX_RULE6EN_MASK  0x1       /* rule6en */
-#define TSTORM_CORE_CONN_AG_CTX_RULE6EN_SHIFT 5
-#define TSTORM_CORE_CONN_AG_CTX_RULE7EN_MASK  0x1       /* rule7en */
-#define TSTORM_CORE_CONN_AG_CTX_RULE7EN_SHIFT 6
-#define TSTORM_CORE_CONN_AG_CTX_RULE8EN_MASK  0x1       /* rule8en */
-#define TSTORM_CORE_CONN_AG_CTX_RULE8EN_SHIFT 7
-	__le32	reg0 /* reg0 */;
-	__le32	reg1 /* reg1 */;
-	__le32	reg2 /* reg2 */;
-	__le32	reg3 /* reg3 */;
-	__le32	reg4 /* reg4 */;
-	__le32	reg5 /* reg5 */;
-	__le32	reg6 /* reg6 */;
-	__le32	reg7 /* reg7 */;
-	__le32	reg8 /* reg8 */;
-	u8	byte2 /* byte2 */;
-	u8	byte3 /* byte3 */;
-	__le16	word0 /* word0 */;
-	u8	byte4 /* byte4 */;
-	u8	byte5 /* byte5 */;
-	__le16	word1 /* word1 */;
-	__le16	word2 /* conn_dpi */;
-	__le16	word3 /* word3 */;
-	__le32	reg9 /* reg9 */;
-	__le32	reg10 /* reg10 */;
+#define TSTORM_CORE_CONN_AG_CTX_RULE1EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_RULE1EN_SHIFT	0
+#define TSTORM_CORE_CONN_AG_CTX_RULE2EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_RULE2EN_SHIFT	1
+#define TSTORM_CORE_CONN_AG_CTX_RULE3EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_RULE3EN_SHIFT	2
+#define TSTORM_CORE_CONN_AG_CTX_RULE4EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_RULE4EN_SHIFT	3
+#define TSTORM_CORE_CONN_AG_CTX_RULE5EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_RULE5EN_SHIFT	4
+#define TSTORM_CORE_CONN_AG_CTX_RULE6EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_RULE6EN_SHIFT	5
+#define TSTORM_CORE_CONN_AG_CTX_RULE7EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_RULE7EN_SHIFT	6
+#define TSTORM_CORE_CONN_AG_CTX_RULE8EN_MASK	0x1
+#define TSTORM_CORE_CONN_AG_CTX_RULE8EN_SHIFT	7
+	__le32 reg0;
+	__le32 reg1;
+	__le32 reg2;
+	__le32 reg3;
+	__le32 reg4;
+	__le32 reg5;
+	__le32 reg6;
+	__le32 reg7;
+	__le32 reg8;
+	u8 byte2;
+	u8 byte3;
+	__le16 word0;
+	u8 byte4;
+	u8 byte5;
+	__le16 word1;
+	__le16 word2;
+	__le16 word3;
+	__le32 reg9;
+	__le32 reg10;
 };
 
 struct ustorm_core_conn_ag_ctx {
-	u8	reserved /* cdu_validation */;
-	u8	byte1 /* state */;
-	u8	flags0;
-#define USTORM_CORE_CONN_AG_CTX_BIT0_MASK     0x1       /* exist_in_qm0 */
-#define USTORM_CORE_CONN_AG_CTX_BIT0_SHIFT    0
-#define USTORM_CORE_CONN_AG_CTX_BIT1_MASK     0x1       /* exist_in_qm1 */
-#define USTORM_CORE_CONN_AG_CTX_BIT1_SHIFT    1
-#define USTORM_CORE_CONN_AG_CTX_CF0_MASK      0x3       /* timer0cf */
-#define USTORM_CORE_CONN_AG_CTX_CF0_SHIFT     2
-#define USTORM_CORE_CONN_AG_CTX_CF1_MASK      0x3       /* timer1cf */
-#define USTORM_CORE_CONN_AG_CTX_CF1_SHIFT     4
-#define USTORM_CORE_CONN_AG_CTX_CF2_MASK      0x3       /* timer2cf */
-#define USTORM_CORE_CONN_AG_CTX_CF2_SHIFT     6
+	u8 reserved;
+	u8 byte1;
+	u8 flags0;
+#define USTORM_CORE_CONN_AG_CTX_BIT0_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_BIT0_SHIFT	0
+#define USTORM_CORE_CONN_AG_CTX_BIT1_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_BIT1_SHIFT	1
+#define USTORM_CORE_CONN_AG_CTX_CF0_MASK	0x3
+#define USTORM_CORE_CONN_AG_CTX_CF0_SHIFT	2
+#define USTORM_CORE_CONN_AG_CTX_CF1_MASK	0x3
+#define USTORM_CORE_CONN_AG_CTX_CF1_SHIFT	4
+#define USTORM_CORE_CONN_AG_CTX_CF2_MASK	0x3
+#define USTORM_CORE_CONN_AG_CTX_CF2_SHIFT	6
 	u8 flags1;
-#define USTORM_CORE_CONN_AG_CTX_CF3_MASK      0x3       /* timer_stop_all */
-#define USTORM_CORE_CONN_AG_CTX_CF3_SHIFT     0
-#define USTORM_CORE_CONN_AG_CTX_CF4_MASK      0x3       /* cf4 */
-#define USTORM_CORE_CONN_AG_CTX_CF4_SHIFT     2
-#define USTORM_CORE_CONN_AG_CTX_CF5_MASK      0x3       /* cf5 */
-#define USTORM_CORE_CONN_AG_CTX_CF5_SHIFT     4
-#define USTORM_CORE_CONN_AG_CTX_CF6_MASK      0x3       /* cf6 */
-#define USTORM_CORE_CONN_AG_CTX_CF6_SHIFT     6
+#define USTORM_CORE_CONN_AG_CTX_CF3_MASK	0x3
+#define USTORM_CORE_CONN_AG_CTX_CF3_SHIFT	0
+#define USTORM_CORE_CONN_AG_CTX_CF4_MASK	0x3
+#define USTORM_CORE_CONN_AG_CTX_CF4_SHIFT	2
+#define USTORM_CORE_CONN_AG_CTX_CF5_MASK	0x3
+#define USTORM_CORE_CONN_AG_CTX_CF5_SHIFT	4
+#define USTORM_CORE_CONN_AG_CTX_CF6_MASK	0x3
+#define USTORM_CORE_CONN_AG_CTX_CF6_SHIFT	6
 	u8 flags2;
-#define USTORM_CORE_CONN_AG_CTX_CF0EN_MASK    0x1       /* cf0en */
-#define USTORM_CORE_CONN_AG_CTX_CF0EN_SHIFT   0
-#define USTORM_CORE_CONN_AG_CTX_CF1EN_MASK    0x1       /* cf1en */
-#define USTORM_CORE_CONN_AG_CTX_CF1EN_SHIFT   1
-#define USTORM_CORE_CONN_AG_CTX_CF2EN_MASK    0x1       /* cf2en */
-#define USTORM_CORE_CONN_AG_CTX_CF2EN_SHIFT   2
-#define USTORM_CORE_CONN_AG_CTX_CF3EN_MASK    0x1       /* cf3en */
-#define USTORM_CORE_CONN_AG_CTX_CF3EN_SHIFT   3
-#define USTORM_CORE_CONN_AG_CTX_CF4EN_MASK    0x1       /* cf4en */
-#define USTORM_CORE_CONN_AG_CTX_CF4EN_SHIFT   4
-#define USTORM_CORE_CONN_AG_CTX_CF5EN_MASK    0x1       /* cf5en */
-#define USTORM_CORE_CONN_AG_CTX_CF5EN_SHIFT   5
-#define USTORM_CORE_CONN_AG_CTX_CF6EN_MASK    0x1       /* cf6en */
-#define USTORM_CORE_CONN_AG_CTX_CF6EN_SHIFT   6
-#define USTORM_CORE_CONN_AG_CTX_RULE0EN_MASK  0x1       /* rule0en */
-#define USTORM_CORE_CONN_AG_CTX_RULE0EN_SHIFT 7
+#define USTORM_CORE_CONN_AG_CTX_CF0EN_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_CF0EN_SHIFT	0
+#define USTORM_CORE_CONN_AG_CTX_CF1EN_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_CF1EN_SHIFT	1
+#define USTORM_CORE_CONN_AG_CTX_CF2EN_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_CF2EN_SHIFT	2
+#define USTORM_CORE_CONN_AG_CTX_CF3EN_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_CF3EN_SHIFT	3
+#define USTORM_CORE_CONN_AG_CTX_CF4EN_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_CF4EN_SHIFT	4
+#define USTORM_CORE_CONN_AG_CTX_CF5EN_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_CF5EN_SHIFT	5
+#define USTORM_CORE_CONN_AG_CTX_CF6EN_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_CF6EN_SHIFT	6
+#define USTORM_CORE_CONN_AG_CTX_RULE0EN_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_RULE0EN_SHIFT	7
 	u8 flags3;
-#define USTORM_CORE_CONN_AG_CTX_RULE1EN_MASK  0x1       /* rule1en */
-#define USTORM_CORE_CONN_AG_CTX_RULE1EN_SHIFT 0
-#define USTORM_CORE_CONN_AG_CTX_RULE2EN_MASK  0x1       /* rule2en */
-#define USTORM_CORE_CONN_AG_CTX_RULE2EN_SHIFT 1
-#define USTORM_CORE_CONN_AG_CTX_RULE3EN_MASK  0x1       /* rule3en */
-#define USTORM_CORE_CONN_AG_CTX_RULE3EN_SHIFT 2
-#define USTORM_CORE_CONN_AG_CTX_RULE4EN_MASK  0x1       /* rule4en */
-#define USTORM_CORE_CONN_AG_CTX_RULE4EN_SHIFT 3
-#define USTORM_CORE_CONN_AG_CTX_RULE5EN_MASK  0x1       /* rule5en */
-#define USTORM_CORE_CONN_AG_CTX_RULE5EN_SHIFT 4
-#define USTORM_CORE_CONN_AG_CTX_RULE6EN_MASK  0x1       /* rule6en */
-#define USTORM_CORE_CONN_AG_CTX_RULE6EN_SHIFT 5
-#define USTORM_CORE_CONN_AG_CTX_RULE7EN_MASK  0x1       /* rule7en */
-#define USTORM_CORE_CONN_AG_CTX_RULE7EN_SHIFT 6
-#define USTORM_CORE_CONN_AG_CTX_RULE8EN_MASK  0x1       /* rule8en */
-#define USTORM_CORE_CONN_AG_CTX_RULE8EN_SHIFT 7
-	u8	byte2 /* byte2 */;
-	u8	byte3 /* byte3 */;
-	__le16	word0 /* conn_dpi */;
-	__le16	word1 /* word1 */;
-	__le32	rx_producers /* reg0 */;
-	__le32	reg1 /* reg1 */;
-	__le32	reg2 /* reg2 */;
-	__le32	reg3 /* reg3 */;
-	__le16	word2 /* word2 */;
-	__le16	word3 /* word3 */;
+#define USTORM_CORE_CONN_AG_CTX_RULE1EN_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_RULE1EN_SHIFT	0
+#define USTORM_CORE_CONN_AG_CTX_RULE2EN_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_RULE2EN_SHIFT	1
+#define USTORM_CORE_CONN_AG_CTX_RULE3EN_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_RULE3EN_SHIFT	2
+#define USTORM_CORE_CONN_AG_CTX_RULE4EN_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_RULE4EN_SHIFT	3
+#define USTORM_CORE_CONN_AG_CTX_RULE5EN_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_RULE5EN_SHIFT	4
+#define USTORM_CORE_CONN_AG_CTX_RULE6EN_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_RULE6EN_SHIFT	5
+#define USTORM_CORE_CONN_AG_CTX_RULE7EN_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_RULE7EN_SHIFT	6
+#define USTORM_CORE_CONN_AG_CTX_RULE8EN_MASK	0x1
+#define USTORM_CORE_CONN_AG_CTX_RULE8EN_SHIFT	7
+	u8 byte2;
+	u8 byte3;
+	__le16 word0;
+	__le16 word1;
+	__le32 rx_producers;
+	__le32 reg1;
+	__le32 reg2;
+	__le32 reg3;
+	__le16 word2;
+	__le16 word3;
 };
 
 /* The core storm context for the Mstorm */
@@ -519,122 +518,186 @@ struct ustorm_core_conn_st_ctx {
 
 /* core connection context */
 struct core_conn_context {
-	struct ystorm_core_conn_st_ctx	ystorm_st_context;
-	struct regpair			ystorm_st_padding[2] /* padding */;
-	struct pstorm_core_conn_st_ctx	pstorm_st_context;
-	struct regpair			pstorm_st_padding[2];
-	struct xstorm_core_conn_st_ctx	xstorm_st_context;
-	struct xstorm_core_conn_ag_ctx	xstorm_ag_context;
-	struct tstorm_core_conn_ag_ctx	tstorm_ag_context;
-	struct ustorm_core_conn_ag_ctx	ustorm_ag_context;
-	struct mstorm_core_conn_st_ctx	mstorm_st_context;
-	struct ustorm_core_conn_st_ctx	ustorm_st_context;
-	struct regpair			ustorm_st_padding[2] /* padding */;
+	struct ystorm_core_conn_st_ctx ystorm_st_context;
+	struct regpair ystorm_st_padding[2];
+	struct pstorm_core_conn_st_ctx pstorm_st_context;
+	struct regpair pstorm_st_padding[2];
+	struct xstorm_core_conn_st_ctx xstorm_st_context;
+	struct xstorm_core_conn_ag_ctx xstorm_ag_context;
+	struct tstorm_core_conn_ag_ctx tstorm_ag_context;
+	struct ustorm_core_conn_ag_ctx ustorm_ag_context;
+	struct mstorm_core_conn_st_ctx mstorm_st_context;
+	struct ustorm_core_conn_st_ctx ustorm_st_context;
+	struct regpair ustorm_st_padding[2];
+};
+
+struct eth_mstorm_per_pf_stat {
+	struct regpair gre_discard_pkts;
+	struct regpair vxlan_discard_pkts;
+	struct regpair geneve_discard_pkts;
+	struct regpair lb_discard_pkts;
 };
 
 struct eth_mstorm_per_queue_stat {
-	struct regpair  ttl0_discard;
-	struct regpair  packet_too_big_discard;
-	struct regpair  no_buff_discard;
-	struct regpair  not_active_discard;
-	struct regpair  tpa_coalesced_pkts;
-	struct regpair  tpa_coalesced_events;
-	struct regpair  tpa_aborts_num;
-	struct regpair  tpa_coalesced_bytes;
+	struct regpair ttl0_discard;
+	struct regpair packet_too_big_discard;
+	struct regpair no_buff_discard;
+	struct regpair not_active_discard;
+	struct regpair tpa_coalesced_pkts;
+	struct regpair tpa_coalesced_events;
+	struct regpair tpa_aborts_num;
+	struct regpair tpa_coalesced_bytes;
+};
+
+/* Ethernet TX Per PF */
+struct eth_pstorm_per_pf_stat {
+	struct regpair sent_lb_ucast_bytes;
+	struct regpair sent_lb_mcast_bytes;
+	struct regpair sent_lb_bcast_bytes;
+	struct regpair sent_lb_ucast_pkts;
+	struct regpair sent_lb_mcast_pkts;
+	struct regpair sent_lb_bcast_pkts;
+	struct regpair sent_gre_bytes;
+	struct regpair sent_vxlan_bytes;
+	struct regpair sent_geneve_bytes;
+	struct regpair sent_gre_pkts;
+	struct regpair sent_vxlan_pkts;
+	struct regpair sent_geneve_pkts;
+	struct regpair gre_drop_pkts;
+	struct regpair vxlan_drop_pkts;
+	struct regpair geneve_drop_pkts;
+};
+
+/* Ethernet TX Per Queue Stats */
+struct eth_pstorm_per_queue_stat {
+	struct regpair sent_ucast_bytes;
+	struct regpair sent_mcast_bytes;
+	struct regpair sent_bcast_bytes;
+	struct regpair sent_ucast_pkts;
+	struct regpair sent_mcast_pkts;
+	struct regpair sent_bcast_pkts;
+	struct regpair error_drop_pkts;
+};
+
+/* ETH Rx producers data */
+struct eth_rx_rate_limit {
+	__le16 mult;
+	__le16 cnst;
+	u8 add_sub_cnst;
+	u8 reserved0;
+	__le16 reserved1;
 };
 
-struct eth_pstorm_per_queue_stat {
-	struct regpair  sent_ucast_bytes;
-	struct regpair  sent_mcast_bytes;
-	struct regpair  sent_bcast_bytes;
-	struct regpair  sent_ucast_pkts;
-	struct regpair  sent_mcast_pkts;
-	struct regpair  sent_bcast_pkts;
-	struct regpair  error_drop_pkts;
+struct eth_ustorm_per_pf_stat {
+	struct regpair rcv_lb_ucast_bytes;
+	struct regpair rcv_lb_mcast_bytes;
+	struct regpair rcv_lb_bcast_bytes;
+	struct regpair rcv_lb_ucast_pkts;
+	struct regpair rcv_lb_mcast_pkts;
+	struct regpair rcv_lb_bcast_pkts;
+	struct regpair rcv_gre_bytes;
+	struct regpair rcv_vxlan_bytes;
+	struct regpair rcv_geneve_bytes;
+	struct regpair rcv_gre_pkts;
+	struct regpair rcv_vxlan_pkts;
+	struct regpair rcv_geneve_pkts;
 };
 
 struct eth_ustorm_per_queue_stat {
-	struct regpair  rcv_ucast_bytes;
-	struct regpair  rcv_mcast_bytes;
-	struct regpair  rcv_bcast_bytes;
-	struct regpair  rcv_ucast_pkts;
-	struct regpair  rcv_mcast_pkts;
-	struct regpair  rcv_bcast_pkts;
+	struct regpair rcv_ucast_bytes;
+	struct regpair rcv_mcast_bytes;
+	struct regpair rcv_bcast_bytes;
+	struct regpair rcv_ucast_pkts;
+	struct regpair rcv_mcast_pkts;
+	struct regpair rcv_bcast_pkts;
 };
 
 /* Event Ring Next Page Address */
 struct event_ring_next_addr {
-	struct regpair	addr /* Next Page Address */;
-	__le32		reserved[2] /* Reserved */;
+	struct regpair addr;
+	__le32 reserved[2];
 };
 
+/* Event Ring Element */
 union event_ring_element {
-	struct event_ring_entry		entry /* Event Ring Entry */;
-	struct event_ring_next_addr	next_addr;
+	struct event_ring_entry entry;
+	struct event_ring_next_addr next_addr;
+};
+
+/* Major and Minor hsi Versions */
+struct hsi_fp_ver_struct {
+	u8 minor_ver_arr[2];
+	u8 major_ver_arr[2];
 };
 
+/* Mstorm non-triggering VF zone */
 struct mstorm_non_trigger_vf_zone {
 	struct eth_mstorm_per_queue_stat eth_queue_stat;
+	struct eth_rx_prod_data eth_rx_queue_producers[ETH_MAX_NUM_RX_QUEUES_PER_VF];
 };
 
+/* Mstorm VF zone */
 struct mstorm_vf_zone {
 	struct mstorm_non_trigger_vf_zone non_trigger;
+
 };
 
+/* personality per PF */
 enum personality_type {
 	BAD_PERSONALITY_TYP,
 	PERSONALITY_RESERVED,
 	PERSONALITY_RESERVED2,
-	PERSONALITY_RDMA_AND_ETH /* Roce or Iwarp */,
+	PERSONALITY_RDMA_AND_ETH,
 	PERSONALITY_RESERVED3,
 	PERSONALITY_CORE,
-	PERSONALITY_ETH /* Ethernet */,
+	PERSONALITY_ETH,
 	PERSONALITY_RESERVED4,
 	MAX_PERSONALITY_TYPE
 };
 
+/* tunnel configuration */
 struct pf_start_tunnel_config {
-	u8	set_vxlan_udp_port_flg;
-	u8	set_geneve_udp_port_flg;
-	u8	tx_enable_vxlan /* If set, enable VXLAN tunnel in TX path. */;
-	u8	tx_enable_l2geneve;
-	u8	tx_enable_ipgeneve;
-	u8	tx_enable_l2gre /* If set, enable l2 GRE tunnel in TX path. */;
-	u8	tx_enable_ipgre /* If set, enable IP GRE tunnel in TX path. */;
-	u8	tunnel_clss_vxlan /* Classification scheme for VXLAN tunnel. */;
-	u8	tunnel_clss_l2geneve;
-	u8	tunnel_clss_ipgeneve;
-	u8	tunnel_clss_l2gre;
-	u8	tunnel_clss_ipgre;
-	__le16	vxlan_udp_port /* VXLAN tunnel UDP destination port. */;
-	__le16	geneve_udp_port /* GENEVE tunnel UDP destination port. */;
+	u8 set_vxlan_udp_port_flg;
+	u8 set_geneve_udp_port_flg;
+	u8 tx_enable_vxlan;
+	u8 tx_enable_l2geneve;
+	u8 tx_enable_ipgeneve;
+	u8 tx_enable_l2gre;
+	u8 tx_enable_ipgre;
+	u8 tunnel_clss_vxlan;
+	u8 tunnel_clss_l2geneve;
+	u8 tunnel_clss_ipgeneve;
+	u8 tunnel_clss_l2gre;
+	u8 tunnel_clss_ipgre;
+	__le16 vxlan_udp_port;
+	__le16 geneve_udp_port;
 };
 
 /* Ramrod data for PF start ramrod */
 struct pf_start_ramrod_data {
-	struct regpair			event_ring_pbl_addr;
-	struct regpair			consolid_q_pbl_addr;
-	struct pf_start_tunnel_config	tunnel_config;
-	__le16				event_ring_sb_id;
-	u8				base_vf_id;
-	u8				num_vfs;
-	u8				event_ring_num_pages;
-	u8				event_ring_sb_index;
-	u8				path_id;
-	u8				warning_as_error;
-	u8				dont_log_ramrods;
-	u8				personality;
-	__le16				log_type_mask;
-	u8				mf_mode /* Multi function mode */;
-	u8				integ_phase /* Integration phase */;
-	u8				allow_npar_tx_switching;
-	u8				inner_to_outer_pri_map[8];
-	u8				pri_map_valid;
-	u32				outer_tag;
-	u8				reserved0[4];
-};
-
-/* Data for port update ramrod */
+	struct regpair event_ring_pbl_addr;
+	struct regpair consolid_q_pbl_addr;
+	struct pf_start_tunnel_config tunnel_config;
+	__le16 event_ring_sb_id;
+	u8 base_vf_id;
+	u8 num_vfs;
+	u8 event_ring_num_pages;
+	u8 event_ring_sb_index;
+	u8 path_id;
+	u8 warning_as_error;
+	u8 dont_log_ramrods;
+	u8 personality;
+	__le16 log_type_mask;
+	u8 mf_mode;
+	u8 integ_phase;
+	u8 allow_npar_tx_switching;
+	u8 inner_to_outer_pri_map[8];
+	u8 pri_map_valid;
+	__le32 outer_tag;
+	struct hsi_fp_ver_struct hsi_fp_ver;
+
+};
+
 struct protocol_dcb_data {
 	u8 dcb_enable_flag;
 	u8 dcb_priority;
@@ -642,25 +705,24 @@ struct protocol_dcb_data {
 	u8 reserved;
 };
 
-/* tunnel configuration */
 struct pf_update_tunnel_config {
-	u8	update_rx_pf_clss;
-	u8	update_tx_pf_clss;
-	u8	set_vxlan_udp_port_flg;
-	u8	set_geneve_udp_port_flg;
-	u8	tx_enable_vxlan;
-	u8	tx_enable_l2geneve;
-	u8	tx_enable_ipgeneve;
-	u8	tx_enable_l2gre;
-	u8	tx_enable_ipgre;
-	u8	tunnel_clss_vxlan;
-	u8	tunnel_clss_l2geneve;
-	u8	tunnel_clss_ipgeneve;
-	u8	tunnel_clss_l2gre;
-	u8	tunnel_clss_ipgre;
-	__le16	vxlan_udp_port;
-	__le16	geneve_udp_port;
-	__le16	reserved[3];
+	u8 update_rx_pf_clss;
+	u8 update_tx_pf_clss;
+	u8 set_vxlan_udp_port_flg;
+	u8 set_geneve_udp_port_flg;
+	u8 tx_enable_vxlan;
+	u8 tx_enable_l2geneve;
+	u8 tx_enable_ipgeneve;
+	u8 tx_enable_l2gre;
+	u8 tx_enable_ipgre;
+	u8 tunnel_clss_vxlan;
+	u8 tunnel_clss_l2geneve;
+	u8 tunnel_clss_ipgeneve;
+	u8 tunnel_clss_l2gre;
+	u8 tunnel_clss_ipgre;
+	__le16 vxlan_udp_port;
+	__le16 geneve_udp_port;
+	__le16 reserved[3];
 };
 
 struct pf_update_ramrod_data {
@@ -669,38 +731,43 @@ struct pf_update_ramrod_data {
 	u8 update_fcoe_dcb_data_flag;
 	u8 update_iscsi_dcb_data_flag;
 	u8 update_roce_dcb_data_flag;
+	u8 update_iwarp_dcb_data_flag;
 	u8 update_mf_vlan_flag;
-	__le16 mf_vlan;
+	u8 reserved;
 	struct protocol_dcb_data eth_dcb_data;
 	struct protocol_dcb_data fcoe_dcb_data;
 	struct protocol_dcb_data iscsi_dcb_data;
 	struct protocol_dcb_data roce_dcb_data;
-	struct pf_update_tunnel_config	tunnel_config;
-};
-
-/* Tunnel classification scheme */
-enum tunnel_clss {
-	TUNNEL_CLSS_MAC_VLAN = 0,
-	TUNNEL_CLSS_MAC_VNI,
-	TUNNEL_CLSS_INNER_MAC_VLAN,
-	TUNNEL_CLSS_INNER_MAC_VNI,
-	MAX_TUNNEL_CLSS
+	struct protocol_dcb_data iwarp_dcb_data;
+	__le16 mf_vlan;
+	__le16 reserved2;
+	struct pf_update_tunnel_config tunnel_config;
 };
 
+/* Ports mode */
 enum ports_mode {
-	ENGX2_PORTX1 /* 2 engines x 1 port */,
-	ENGX2_PORTX2 /* 2 engines x 2 ports */,
-	ENGX1_PORTX1 /* 1 engine  x 1 port */,
-	ENGX1_PORTX2 /* 1 engine  x 2 ports */,
-	ENGX1_PORTX4 /* 1 engine  x 4 ports */,
+	ENGX2_PORTX1,
+	ENGX2_PORTX2,
+	ENGX1_PORTX1,
+	ENGX1_PORTX2,
+	ENGX1_PORTX4,
 	MAX_PORTS_MODE
 };
 
+/* use to index in hsi_fp_[major|minor]_ver_arr per protocol */
+enum protocol_version_array_key {
+	ETH_VER_KEY = 0,
+	ROCE_VER_KEY,
+	MAX_PROTOCOL_VERSION_ARRAY_KEY
+};
+
+/* Pstorm non-triggering VF zone */
 struct pstorm_non_trigger_vf_zone {
 	struct eth_pstorm_per_queue_stat eth_queue_stat;
 	struct regpair reserved[2];
 };
 
+/* Pstorm VF zone */
 struct pstorm_vf_zone {
 	struct pstorm_non_trigger_vf_zone non_trigger;
 	struct regpair reserved[7];
@@ -708,56 +775,89 @@ struct pstorm_vf_zone {
 
 /* Ramrod Header of SPQE */
 struct ramrod_header {
-	__le32	cid /* Slowpath Connection CID */;
-	u8	cmd_id /* Ramrod Cmd (Per Protocol Type) */;
-	u8	protocol_id /* Ramrod Protocol ID */;
-	__le16	echo /* Ramrod echo */;
+	__le32 cid;
+	u8 cmd_id;
+	u8 protocol_id;
+	__le16 echo;
 };
 
 /* Slowpath Element (SPQE) */
 struct slow_path_element {
-	struct ramrod_header	hdr /* Ramrod Header */;
-	struct regpair		data_ptr;
+	struct ramrod_header hdr;
+	struct regpair data_ptr;
+};
+
+/* Tstorm non-triggering VF zone */
+struct tstorm_non_trigger_vf_zone {
+	struct regpair reserved[2];
 };
 
 struct tstorm_per_port_stat {
-	struct regpair	trunc_error_discard;
-	struct regpair	mac_error_discard;
-	struct regpair	mftag_filter_discard;
-	struct regpair	eth_mac_filter_discard;
-	struct regpair	ll2_mac_filter_discard;
-	struct regpair	ll2_conn_disabled_discard;
-	struct regpair	iscsi_irregular_pkt;
-	struct regpair	fcoe_irregular_pkt;
-	struct regpair	roce_irregular_pkt;
-	struct regpair	eth_irregular_pkt;
-	struct regpair	toe_irregular_pkt;
-	struct regpair	preroce_irregular_pkt;
+	struct regpair trunc_error_discard;
+	struct regpair mac_error_discard;
+	struct regpair mftag_filter_discard;
+	struct regpair eth_mac_filter_discard;
+	struct regpair reserved[5];
+	struct regpair eth_irregular_pkt;
+	struct regpair reserved1[2];
+	struct regpair eth_gre_tunn_filter_discard;
+	struct regpair eth_vxlan_tunn_filter_discard;
+	struct regpair eth_geneve_tunn_filter_discard;
 };
 
+/* Tstorm VF zone */
+struct tstorm_vf_zone {
+	struct tstorm_non_trigger_vf_zone non_trigger;
+};
+
+/* Tunnel classification scheme */
+enum tunnel_clss {
+	TUNNEL_CLSS_MAC_VLAN = 0,
+	TUNNEL_CLSS_MAC_VNI,
+	TUNNEL_CLSS_INNER_MAC_VLAN,
+	TUNNEL_CLSS_INNER_MAC_VNI,
+	TUNNEL_CLSS_MAC_VLAN_DUAL_STAGE,
+	MAX_TUNNEL_CLSS
+};
+
+/* Ustorm non-triggering VF zone */
 struct ustorm_non_trigger_vf_zone {
 	struct eth_ustorm_per_queue_stat eth_queue_stat;
 	struct regpair vf_pf_msg_addr;
 };
 
+/* Ustorm triggering VF zone */
 struct ustorm_trigger_vf_zone {
 	u8 vf_pf_msg_valid;
 	u8 reserved[7];
 };
 
+/* Ustorm VF zone */
 struct ustorm_vf_zone {
 	struct ustorm_non_trigger_vf_zone non_trigger;
 	struct ustorm_trigger_vf_zone trigger;
 };
 
+/* VF-PF channel data */
+struct vf_pf_channel_data {
+	__le32 ready;
+	u8 valid;
+	u8 reserved0;
+	__le16 reserved1;
+};
+
+/* Ramrod data for VF start ramrod */
 struct vf_start_ramrod_data {
 	u8 vf_id;
 	u8 enable_flr_ack;
 	__le16 opaque_fid;
 	u8 personality;
-	u8 reserved[3];
+	u8 reserved[7];
+	struct hsi_fp_ver_struct hsi_fp_ver;
+
 };
 
+/* Ramrod data for VF start ramrod */
 struct vf_stop_ramrod_data {
 	u8 vf_id;
 	u8 reserved0;
@@ -765,94 +865,474 @@ struct vf_stop_ramrod_data {
 	__le32 reserved2;
 };
 
+/* Attentions status block */
 struct atten_status_block {
-	__le32	atten_bits;
-	__le32	atten_ack;
-	__le16	reserved0;
-	__le16	sb_index /* status block running index */;
-	__le32	reserved1;
+	__le32 atten_bits;
+	__le32 atten_ack;
+	__le16 reserved0;
+	__le16 sb_index;
+	__le32 reserved1;
+};
+
+enum command_type_bit {
+	IGU_COMMAND_TYPE_NOP = 0,
+	IGU_COMMAND_TYPE_SET = 1,
+	MAX_COMMAND_TYPE_BIT
+};
+
+/* DMAE command */
+struct dmae_cmd {
+	__le32 opcode;
+#define DMAE_CMD_SRC_MASK		0x1
+#define DMAE_CMD_SRC_SHIFT		0
+#define DMAE_CMD_DST_MASK		0x3
+#define DMAE_CMD_DST_SHIFT		1
+#define DMAE_CMD_C_DST_MASK		0x1
+#define DMAE_CMD_C_DST_SHIFT		3
+#define DMAE_CMD_CRC_RESET_MASK		0x1
+#define DMAE_CMD_CRC_RESET_SHIFT	4
+#define DMAE_CMD_SRC_ADDR_RESET_MASK	0x1
+#define DMAE_CMD_SRC_ADDR_RESET_SHIFT	5
+#define DMAE_CMD_DST_ADDR_RESET_MASK	0x1
+#define DMAE_CMD_DST_ADDR_RESET_SHIFT	6
+#define DMAE_CMD_COMP_FUNC_MASK		0x1
+#define DMAE_CMD_COMP_FUNC_SHIFT	7
+#define DMAE_CMD_COMP_WORD_EN_MASK	0x1
+#define DMAE_CMD_COMP_WORD_EN_SHIFT	8
+#define DMAE_CMD_COMP_CRC_EN_MASK	0x1
+#define DMAE_CMD_COMP_CRC_EN_SHIFT	9
+#define DMAE_CMD_COMP_CRC_OFFSET_MASK	0x7
+#define DMAE_CMD_COMP_CRC_OFFSET_SHIFT 10
+#define DMAE_CMD_RESERVED1_MASK		0x1
+#define DMAE_CMD_RESERVED1_SHIFT	13
+#define DMAE_CMD_ENDIANITY_MODE_MASK	0x3
+#define DMAE_CMD_ENDIANITY_MODE_SHIFT	14
+#define DMAE_CMD_ERR_HANDLING_MASK	0x3
+#define DMAE_CMD_ERR_HANDLING_SHIFT	16
+#define DMAE_CMD_PORT_ID_MASK		0x3
+#define DMAE_CMD_PORT_ID_SHIFT		18
+#define DMAE_CMD_SRC_PF_ID_MASK		0xF
+#define DMAE_CMD_SRC_PF_ID_SHIFT	20
+#define DMAE_CMD_DST_PF_ID_MASK		0xF
+#define DMAE_CMD_DST_PF_ID_SHIFT	24
+#define DMAE_CMD_SRC_VF_ID_VALID_MASK	0x1
+#define DMAE_CMD_SRC_VF_ID_VALID_SHIFT 28
+#define DMAE_CMD_DST_VF_ID_VALID_MASK	0x1
+#define DMAE_CMD_DST_VF_ID_VALID_SHIFT 29
+#define DMAE_CMD_RESERVED2_MASK		0x3
+#define DMAE_CMD_RESERVED2_SHIFT	30
+	__le32 src_addr_lo;
+	__le32 src_addr_hi;
+	__le32 dst_addr_lo;
+	__le32 dst_addr_hi;
+	__le16 length_dw;
+	__le16 opcode_b;
+#define DMAE_CMD_SRC_VF_ID_MASK		0xFF
+#define DMAE_CMD_SRC_VF_ID_SHIFT	0
+#define DMAE_CMD_DST_VF_ID_MASK		0xFF
+#define DMAE_CMD_DST_VF_ID_SHIFT	8
+	__le32 comp_addr_lo;
+	__le32 comp_addr_hi;
+	__le32 comp_val;
+	__le32 crc32;
+	__le32 crc_32_c;
+	__le16 crc16;
+	__le16 crc16_c;
+	__le16 crc10;
+	__le16 reserved;
+	__le16 xsum16;
+	__le16 xsum8;
+};
+
+enum dmae_cmd_comp_crc_en_enum {
+	dmae_cmd_comp_crc_disabled,
+	dmae_cmd_comp_crc_enabled,
+	MAX_DMAE_CMD_COMP_CRC_EN_ENUM
+};
+
+enum dmae_cmd_comp_func_enum {
+	dmae_cmd_comp_func_to_src,
+	dmae_cmd_comp_func_to_dst,
+	MAX_DMAE_CMD_COMP_FUNC_ENUM
+};
+
+enum dmae_cmd_comp_word_en_enum {
+	dmae_cmd_comp_word_disabled,
+	dmae_cmd_comp_word_enabled,
+	MAX_DMAE_CMD_COMP_WORD_EN_ENUM
+};
+
+enum dmae_cmd_c_dst_enum {
+	dmae_cmd_c_dst_pcie,
+	dmae_cmd_c_dst_grc,
+	MAX_DMAE_CMD_C_DST_ENUM
+};
+
+enum dmae_cmd_dst_enum {
+	dmae_cmd_dst_none_0,
+	dmae_cmd_dst_pcie,
+	dmae_cmd_dst_grc,
+	dmae_cmd_dst_none_3,
+	MAX_DMAE_CMD_DST_ENUM
+};
+
+enum dmae_cmd_error_handling_enum {
+	dmae_cmd_error_handling_send_regular_comp,
+	dmae_cmd_error_handling_send_comp_with_err,
+	dmae_cmd_error_handling_dont_send_comp,
+	MAX_DMAE_CMD_ERROR_HANDLING_ENUM
+};
+
+enum dmae_cmd_src_enum {
+	dmae_cmd_src_pcie,
+	dmae_cmd_src_grc,
+	MAX_DMAE_CMD_SRC_ENUM
+};
+
+/* IGU cleanup command */
+struct igu_cleanup {
+	__le32 sb_id_and_flags;
+#define IGU_CLEANUP_RESERVED0_MASK	0x7FFFFFF
+#define IGU_CLEANUP_RESERVED0_SHIFT	0
+#define IGU_CLEANUP_CLEANUP_SET_MASK	0x1
+#define IGU_CLEANUP_CLEANUP_SET_SHIFT	27
+#define IGU_CLEANUP_CLEANUP_TYPE_MASK	0x7
+#define IGU_CLEANUP_CLEANUP_TYPE_SHIFT	28
+#define IGU_CLEANUP_COMMAND_TYPE_MASK	0x1
+#define IGU_CLEANUP_COMMAND_TYPE_SHIFT	31
+	__le32 reserved1;
+};
+
+/* IGU firmware driver command */
+union igu_command {
+	struct igu_prod_cons_update prod_cons_update;
+	struct igu_cleanup cleanup;
+};
+
+/* IGU firmware driver command */
+struct igu_command_reg_ctrl {
+	__le16 opaque_fid;
+	__le16 igu_command_reg_ctrl_fields;
+#define IGU_COMMAND_REG_CTRL_PXP_BAR_ADDR_MASK	0xFFF
+#define IGU_COMMAND_REG_CTRL_PXP_BAR_ADDR_SHIFT	0
+#define IGU_COMMAND_REG_CTRL_RESERVED_MASK	0x7
+#define IGU_COMMAND_REG_CTRL_RESERVED_SHIFT	12
+#define IGU_COMMAND_REG_CTRL_COMMAND_TYPE_MASK	0x1
+#define IGU_COMMAND_REG_CTRL_COMMAND_TYPE_SHIFT	15
+};
+
+/* IGU mapping line structure */
+struct igu_mapping_line {
+	__le32 igu_mapping_line_fields;
+#define IGU_MAPPING_LINE_VALID_MASK		0x1
+#define IGU_MAPPING_LINE_VALID_SHIFT		0
+#define IGU_MAPPING_LINE_VECTOR_NUMBER_MASK	0xFF
+#define IGU_MAPPING_LINE_VECTOR_NUMBER_SHIFT	1
+#define IGU_MAPPING_LINE_FUNCTION_NUMBER_MASK	0xFF
+#define IGU_MAPPING_LINE_FUNCTION_NUMBER_SHIFT	9
+#define IGU_MAPPING_LINE_PF_VALID_MASK		0x1
+#define IGU_MAPPING_LINE_PF_VALID_SHIFT		17
+#define IGU_MAPPING_LINE_IPS_GROUP_MASK		0x3F
+#define IGU_MAPPING_LINE_IPS_GROUP_SHIFT	18
+#define IGU_MAPPING_LINE_RESERVED_MASK		0xFF
+#define IGU_MAPPING_LINE_RESERVED_SHIFT		24
+};
+
+/* IGU MSIX line structure */
+struct igu_msix_vector {
+	struct regpair address;
+	__le32 data;
+	__le32 msix_vector_fields;
+#define IGU_MSIX_VECTOR_MASK_BIT_MASK		0x1
+#define IGU_MSIX_VECTOR_MASK_BIT_SHIFT		0
+#define IGU_MSIX_VECTOR_RESERVED0_MASK		0x7FFF
+#define IGU_MSIX_VECTOR_RESERVED0_SHIFT		1
+#define IGU_MSIX_VECTOR_STEERING_TAG_MASK	0xFF
+#define IGU_MSIX_VECTOR_STEERING_TAG_SHIFT	16
+#define IGU_MSIX_VECTOR_RESERVED1_MASK		0xFF
+#define IGU_MSIX_VECTOR_RESERVED1_SHIFT		24
+};
+
+struct mstorm_core_conn_ag_ctx {
+	u8 byte0;
+	u8 byte1;
+	u8 flags0;
+#define MSTORM_CORE_CONN_AG_CTX_BIT0_MASK	0x1
+#define MSTORM_CORE_CONN_AG_CTX_BIT0_SHIFT	0
+#define MSTORM_CORE_CONN_AG_CTX_BIT1_MASK	0x1
+#define MSTORM_CORE_CONN_AG_CTX_BIT1_SHIFT	1
+#define MSTORM_CORE_CONN_AG_CTX_CF0_MASK	0x3
+#define MSTORM_CORE_CONN_AG_CTX_CF0_SHIFT	2
+#define MSTORM_CORE_CONN_AG_CTX_CF1_MASK	0x3
+#define MSTORM_CORE_CONN_AG_CTX_CF1_SHIFT	4
+#define MSTORM_CORE_CONN_AG_CTX_CF2_MASK	0x3
+#define MSTORM_CORE_CONN_AG_CTX_CF2_SHIFT	6
+	u8 flags1;
+#define MSTORM_CORE_CONN_AG_CTX_CF0EN_MASK	0x1
+#define MSTORM_CORE_CONN_AG_CTX_CF0EN_SHIFT	0
+#define MSTORM_CORE_CONN_AG_CTX_CF1EN_MASK	0x1
+#define MSTORM_CORE_CONN_AG_CTX_CF1EN_SHIFT	1
+#define MSTORM_CORE_CONN_AG_CTX_CF2EN_MASK	0x1
+#define MSTORM_CORE_CONN_AG_CTX_CF2EN_SHIFT	2
+#define MSTORM_CORE_CONN_AG_CTX_RULE0EN_MASK	0x1
+#define MSTORM_CORE_CONN_AG_CTX_RULE0EN_SHIFT	3
+#define MSTORM_CORE_CONN_AG_CTX_RULE1EN_MASK	0x1
+#define MSTORM_CORE_CONN_AG_CTX_RULE1EN_SHIFT	4
+#define MSTORM_CORE_CONN_AG_CTX_RULE2EN_MASK	0x1
+#define MSTORM_CORE_CONN_AG_CTX_RULE2EN_SHIFT	5
+#define MSTORM_CORE_CONN_AG_CTX_RULE3EN_MASK	0x1
+#define MSTORM_CORE_CONN_AG_CTX_RULE3EN_SHIFT	6
+#define MSTORM_CORE_CONN_AG_CTX_RULE4EN_MASK	0x1
+#define MSTORM_CORE_CONN_AG_CTX_RULE4EN_SHIFT	7
+	__le16 word0;
+	__le16 word1;
+	__le32 reg0;
+	__le32 reg1;
 };
 
+/* per encapsulation type enabling flags */
+struct prs_reg_encapsulation_type_en {
+	u8 flags;
+#define PRS_REG_ENCAPSULATION_TYPE_EN_ETH_OVER_GRE_ENABLE_MASK		0x1
+#define PRS_REG_ENCAPSULATION_TYPE_EN_ETH_OVER_GRE_ENABLE_SHIFT		0
+#define PRS_REG_ENCAPSULATION_TYPE_EN_IP_OVER_GRE_ENABLE_MASK		0x1
+#define PRS_REG_ENCAPSULATION_TYPE_EN_IP_OVER_GRE_ENABLE_SHIFT		1
+#define PRS_REG_ENCAPSULATION_TYPE_EN_VXLAN_ENABLE_MASK			0x1
+#define PRS_REG_ENCAPSULATION_TYPE_EN_VXLAN_ENABLE_SHIFT		2
+#define PRS_REG_ENCAPSULATION_TYPE_EN_T_TAG_ENABLE_MASK			0x1
+#define PRS_REG_ENCAPSULATION_TYPE_EN_T_TAG_ENABLE_SHIFT		3
+#define PRS_REG_ENCAPSULATION_TYPE_EN_ETH_OVER_GENEVE_ENABLE_MASK	0x1
+#define PRS_REG_ENCAPSULATION_TYPE_EN_ETH_OVER_GENEVE_ENABLE_SHIFT	4
+#define PRS_REG_ENCAPSULATION_TYPE_EN_IP_OVER_GENEVE_ENABLE_MASK	0x1
+#define PRS_REG_ENCAPSULATION_TYPE_EN_IP_OVER_GENEVE_ENABLE_SHIFT	5
+#define PRS_REG_ENCAPSULATION_TYPE_EN_RESERVED_MASK			0x3
+#define PRS_REG_ENCAPSULATION_TYPE_EN_RESERVED_SHIFT			6
+};
+
+enum pxp_tph_st_hint {
+	TPH_ST_HINT_BIDIR,
+	TPH_ST_HINT_REQUESTER,
+	TPH_ST_HINT_TARGET,
+	TPH_ST_HINT_TARGET_PRIO,
+	MAX_PXP_TPH_ST_HINT
+};
+
+/* QM hardware structure of enable bypass credit mask */
+struct qm_rf_bypass_mask {
+	u8 flags;
+#define QM_RF_BYPASS_MASK_LINEVOQ_MASK		0x1
+#define QM_RF_BYPASS_MASK_LINEVOQ_SHIFT		0
+#define QM_RF_BYPASS_MASK_RESERVED0_MASK	0x1
+#define QM_RF_BYPASS_MASK_RESERVED0_SHIFT	1
+#define QM_RF_BYPASS_MASK_PFWFQ_MASK		0x1
+#define QM_RF_BYPASS_MASK_PFWFQ_SHIFT		2
+#define QM_RF_BYPASS_MASK_VPWFQ_MASK		0x1
+#define QM_RF_BYPASS_MASK_VPWFQ_SHIFT		3
+#define QM_RF_BYPASS_MASK_PFRL_MASK		0x1
+#define QM_RF_BYPASS_MASK_PFRL_SHIFT		4
+#define QM_RF_BYPASS_MASK_VPQCNRL_MASK		0x1
+#define QM_RF_BYPASS_MASK_VPQCNRL_SHIFT		5
+#define QM_RF_BYPASS_MASK_FWPAUSE_MASK		0x1
+#define QM_RF_BYPASS_MASK_FWPAUSE_SHIFT		6
+#define QM_RF_BYPASS_MASK_RESERVED1_MASK	0x1
+#define QM_RF_BYPASS_MASK_RESERVED1_SHIFT	7
+};
+
+/* QM hardware structure of opportunistic credit mask */
+struct qm_rf_opportunistic_mask {
+	__le16 flags;
+#define QM_RF_OPPORTUNISTIC_MASK_LINEVOQ_MASK		0x1
+#define QM_RF_OPPORTUNISTIC_MASK_LINEVOQ_SHIFT		0
+#define QM_RF_OPPORTUNISTIC_MASK_BYTEVOQ_MASK		0x1
+#define QM_RF_OPPORTUNISTIC_MASK_BYTEVOQ_SHIFT		1
+#define QM_RF_OPPORTUNISTIC_MASK_PFWFQ_MASK		0x1
+#define QM_RF_OPPORTUNISTIC_MASK_PFWFQ_SHIFT		2
+#define QM_RF_OPPORTUNISTIC_MASK_VPWFQ_MASK		0x1
+#define QM_RF_OPPORTUNISTIC_MASK_VPWFQ_SHIFT		3
+#define QM_RF_OPPORTUNISTIC_MASK_PFRL_MASK		0x1
+#define QM_RF_OPPORTUNISTIC_MASK_PFRL_SHIFT		4
+#define QM_RF_OPPORTUNISTIC_MASK_VPQCNRL_MASK		0x1
+#define QM_RF_OPPORTUNISTIC_MASK_VPQCNRL_SHIFT		5
+#define QM_RF_OPPORTUNISTIC_MASK_FWPAUSE_MASK		0x1
+#define QM_RF_OPPORTUNISTIC_MASK_FWPAUSE_SHIFT		6
+#define QM_RF_OPPORTUNISTIC_MASK_RESERVED0_MASK		0x1
+#define QM_RF_OPPORTUNISTIC_MASK_RESERVED0_SHIFT	7
+#define QM_RF_OPPORTUNISTIC_MASK_QUEUEEMPTY_MASK	0x1
+#define QM_RF_OPPORTUNISTIC_MASK_QUEUEEMPTY_SHIFT	8
+#define QM_RF_OPPORTUNISTIC_MASK_RESERVED1_MASK		0x7F
+#define QM_RF_OPPORTUNISTIC_MASK_RESERVED1_SHIFT	9
+};
+
+/* QM hardware structure of QM map memory */
+struct qm_rf_pq_map {
+	__le32 reg;
+#define QM_RF_PQ_MAP_PQ_VALID_MASK		0x1
+#define QM_RF_PQ_MAP_PQ_VALID_SHIFT		0
+#define QM_RF_PQ_MAP_RL_ID_MASK			0xFF
+#define QM_RF_PQ_MAP_RL_ID_SHIFT		1
+#define QM_RF_PQ_MAP_VP_PQ_ID_MASK		0x1FF
+#define QM_RF_PQ_MAP_VP_PQ_ID_SHIFT		9
+#define QM_RF_PQ_MAP_VOQ_MASK			0x1F
+#define QM_RF_PQ_MAP_VOQ_SHIFT			18
+#define QM_RF_PQ_MAP_WRR_WEIGHT_GROUP_MASK	0x3
+#define QM_RF_PQ_MAP_WRR_WEIGHT_GROUP_SHIFT	23
+#define QM_RF_PQ_MAP_RL_VALID_MASK		0x1
+#define QM_RF_PQ_MAP_RL_VALID_SHIFT		25
+#define QM_RF_PQ_MAP_RESERVED_MASK		0x3F
+#define QM_RF_PQ_MAP_RESERVED_SHIFT		26
+};
+
+/* Completion params for aggregated interrupt completion */
+struct sdm_agg_int_comp_params {
+	__le16 params;
+#define SDM_AGG_INT_COMP_PARAMS_AGG_INT_INDEX_MASK	0x3F
+#define SDM_AGG_INT_COMP_PARAMS_AGG_INT_INDEX_SHIFT	0
+#define SDM_AGG_INT_COMP_PARAMS_AGG_VECTOR_ENABLE_MASK	0x1
+#define SDM_AGG_INT_COMP_PARAMS_AGG_VECTOR_ENABLE_SHIFT	6
+#define SDM_AGG_INT_COMP_PARAMS_AGG_VECTOR_BIT_MASK	0x1FF
+#define SDM_AGG_INT_COMP_PARAMS_AGG_VECTOR_BIT_SHIFT	7
+};
+
+/* SDM operation gen command (generate aggregative interrupt) */
+struct sdm_op_gen {
+	__le32 command;
+#define SDM_OP_GEN_COMP_PARAM_MASK	0xFFFF
+#define SDM_OP_GEN_COMP_PARAM_SHIFT	0
+#define SDM_OP_GEN_COMP_TYPE_MASK	0xF
+#define SDM_OP_GEN_COMP_TYPE_SHIFT	16
+#define SDM_OP_GEN_RESERVED_MASK	0xFFF
+#define SDM_OP_GEN_RESERVED_SHIFT	20
+};
+
+struct ystorm_core_conn_ag_ctx {
+	u8 byte0;
+	u8 byte1;
+	u8 flags0;
+#define YSTORM_CORE_CONN_AG_CTX_BIT0_MASK	0x1
+#define YSTORM_CORE_CONN_AG_CTX_BIT0_SHIFT	0
+#define YSTORM_CORE_CONN_AG_CTX_BIT1_MASK	0x1
+#define YSTORM_CORE_CONN_AG_CTX_BIT1_SHIFT	1
+#define YSTORM_CORE_CONN_AG_CTX_CF0_MASK	0x3
+#define YSTORM_CORE_CONN_AG_CTX_CF0_SHIFT	2
+#define YSTORM_CORE_CONN_AG_CTX_CF1_MASK	0x3
+#define YSTORM_CORE_CONN_AG_CTX_CF1_SHIFT	4
+#define YSTORM_CORE_CONN_AG_CTX_CF2_MASK	0x3
+#define YSTORM_CORE_CONN_AG_CTX_CF2_SHIFT	6
+	u8 flags1;
+#define YSTORM_CORE_CONN_AG_CTX_CF0EN_MASK	0x1
+#define YSTORM_CORE_CONN_AG_CTX_CF0EN_SHIFT	0
+#define YSTORM_CORE_CONN_AG_CTX_CF1EN_MASK	0x1
+#define YSTORM_CORE_CONN_AG_CTX_CF1EN_SHIFT	1
+#define YSTORM_CORE_CONN_AG_CTX_CF2EN_MASK	0x1
+#define YSTORM_CORE_CONN_AG_CTX_CF2EN_SHIFT	2
+#define YSTORM_CORE_CONN_AG_CTX_RULE0EN_MASK	0x1
+#define YSTORM_CORE_CONN_AG_CTX_RULE0EN_SHIFT	3
+#define YSTORM_CORE_CONN_AG_CTX_RULE1EN_MASK	0x1
+#define YSTORM_CORE_CONN_AG_CTX_RULE1EN_SHIFT	4
+#define YSTORM_CORE_CONN_AG_CTX_RULE2EN_MASK	0x1
+#define YSTORM_CORE_CONN_AG_CTX_RULE2EN_SHIFT	5
+#define YSTORM_CORE_CONN_AG_CTX_RULE3EN_MASK	0x1
+#define YSTORM_CORE_CONN_AG_CTX_RULE3EN_SHIFT	6
+#define YSTORM_CORE_CONN_AG_CTX_RULE4EN_MASK	0x1
+#define YSTORM_CORE_CONN_AG_CTX_RULE4EN_SHIFT	7
+	u8 byte2;
+	u8 byte3;
+	__le16 word0;
+	__le32 reg0;
+	__le32 reg1;
+	__le16 word1;
+	__le16 word2;
+	__le16 word3;
+	__le16 word4;
+	__le32 reg2;
+	__le32 reg3;
+};
+
+/****************************************/
+/* Debug Tools HSI constants and macros */
+/****************************************/
+
 enum block_addr {
-	GRCBASE_GRC		= 0x50000,
-	GRCBASE_MISCS		= 0x9000,
-	GRCBASE_MISC		= 0x8000,
-	GRCBASE_DBU		= 0xa000,
-	GRCBASE_PGLUE_B		= 0x2a8000,
-	GRCBASE_CNIG		= 0x218000,
-	GRCBASE_CPMU		= 0x30000,
-	GRCBASE_NCSI		= 0x40000,
-	GRCBASE_OPTE		= 0x53000,
-	GRCBASE_BMB		= 0x540000,
-	GRCBASE_PCIE		= 0x54000,
-	GRCBASE_MCP		= 0xe00000,
-	GRCBASE_MCP2		= 0x52000,
-	GRCBASE_PSWHST		= 0x2a0000,
-	GRCBASE_PSWHST2		= 0x29e000,
-	GRCBASE_PSWRD		= 0x29c000,
-	GRCBASE_PSWRD2		= 0x29d000,
-	GRCBASE_PSWWR		= 0x29a000,
-	GRCBASE_PSWWR2		= 0x29b000,
-	GRCBASE_PSWRQ		= 0x280000,
-	GRCBASE_PSWRQ2		= 0x240000,
-	GRCBASE_PGLCS		= 0x0,
-	GRCBASE_PTU		= 0x560000,
-	GRCBASE_DMAE		= 0xc000,
-	GRCBASE_TCM		= 0x1180000,
-	GRCBASE_MCM		= 0x1200000,
-	GRCBASE_UCM		= 0x1280000,
-	GRCBASE_XCM		= 0x1000000,
-	GRCBASE_YCM		= 0x1080000,
-	GRCBASE_PCM		= 0x1100000,
-	GRCBASE_QM		= 0x2f0000,
-	GRCBASE_TM		= 0x2c0000,
-	GRCBASE_DORQ		= 0x100000,
-	GRCBASE_BRB		= 0x340000,
-	GRCBASE_SRC		= 0x238000,
-	GRCBASE_PRS		= 0x1f0000,
-	GRCBASE_TSDM		= 0xfb0000,
-	GRCBASE_MSDM		= 0xfc0000,
-	GRCBASE_USDM		= 0xfd0000,
-	GRCBASE_XSDM		= 0xf80000,
-	GRCBASE_YSDM		= 0xf90000,
-	GRCBASE_PSDM		= 0xfa0000,
-	GRCBASE_TSEM		= 0x1700000,
-	GRCBASE_MSEM		= 0x1800000,
-	GRCBASE_USEM		= 0x1900000,
-	GRCBASE_XSEM		= 0x1400000,
-	GRCBASE_YSEM		= 0x1500000,
-	GRCBASE_PSEM		= 0x1600000,
-	GRCBASE_RSS		= 0x238800,
-	GRCBASE_TMLD		= 0x4d0000,
-	GRCBASE_MULD		= 0x4e0000,
-	GRCBASE_YULD		= 0x4c8000,
-	GRCBASE_XYLD		= 0x4c0000,
-	GRCBASE_PRM		= 0x230000,
-	GRCBASE_PBF_PB1		= 0xda0000,
-	GRCBASE_PBF_PB2		= 0xda4000,
-	GRCBASE_RPB		= 0x23c000,
-	GRCBASE_BTB		= 0xdb0000,
-	GRCBASE_PBF		= 0xd80000,
-	GRCBASE_RDIF		= 0x300000,
-	GRCBASE_TDIF		= 0x310000,
-	GRCBASE_CDU		= 0x580000,
-	GRCBASE_CCFC		= 0x2e0000,
-	GRCBASE_TCFC		= 0x2d0000,
-	GRCBASE_IGU		= 0x180000,
-	GRCBASE_CAU		= 0x1c0000,
-	GRCBASE_UMAC		= 0x51000,
-	GRCBASE_XMAC		= 0x210000,
-	GRCBASE_DBG		= 0x10000,
-	GRCBASE_NIG		= 0x500000,
-	GRCBASE_WOL		= 0x600000,
-	GRCBASE_BMBN		= 0x610000,
-	GRCBASE_IPC		= 0x20000,
-	GRCBASE_NWM		= 0x800000,
-	GRCBASE_NWS		= 0x700000,
-	GRCBASE_MS		= 0x6a0000,
-	GRCBASE_PHY_PCIE	= 0x620000,
-	GRCBASE_MISC_AEU	= 0x8000,
-	GRCBASE_BAR0_MAP	= 0x1c00000,
+	GRCBASE_GRC = 0x50000,
+	GRCBASE_MISCS = 0x9000,
+	GRCBASE_MISC = 0x8000,
+	GRCBASE_DBU = 0xa000,
+	GRCBASE_PGLUE_B = 0x2a8000,
+	GRCBASE_CNIG = 0x218000,
+	GRCBASE_CPMU = 0x30000,
+	GRCBASE_NCSI = 0x40000,
+	GRCBASE_OPTE = 0x53000,
+	GRCBASE_BMB = 0x540000,
+	GRCBASE_PCIE = 0x54000,
+	GRCBASE_MCP = 0xe00000,
+	GRCBASE_MCP2 = 0x52000,
+	GRCBASE_PSWHST = 0x2a0000,
+	GRCBASE_PSWHST2 = 0x29e000,
+	GRCBASE_PSWRD = 0x29c000,
+	GRCBASE_PSWRD2 = 0x29d000,
+	GRCBASE_PSWWR = 0x29a000,
+	GRCBASE_PSWWR2 = 0x29b000,
+	GRCBASE_PSWRQ = 0x280000,
+	GRCBASE_PSWRQ2 = 0x240000,
+	GRCBASE_PGLCS = 0x0,
+	GRCBASE_DMAE = 0xc000,
+	GRCBASE_PTU = 0x560000,
+	GRCBASE_TCM = 0x1180000,
+	GRCBASE_MCM = 0x1200000,
+	GRCBASE_UCM = 0x1280000,
+	GRCBASE_XCM = 0x1000000,
+	GRCBASE_YCM = 0x1080000,
+	GRCBASE_PCM = 0x1100000,
+	GRCBASE_QM = 0x2f0000,
+	GRCBASE_TM = 0x2c0000,
+	GRCBASE_DORQ = 0x100000,
+	GRCBASE_BRB = 0x340000,
+	GRCBASE_SRC = 0x238000,
+	GRCBASE_PRS = 0x1f0000,
+	GRCBASE_TSDM = 0xfb0000,
+	GRCBASE_MSDM = 0xfc0000,
+	GRCBASE_USDM = 0xfd0000,
+	GRCBASE_XSDM = 0xf80000,
+	GRCBASE_YSDM = 0xf90000,
+	GRCBASE_PSDM = 0xfa0000,
+	GRCBASE_TSEM = 0x1700000,
+	GRCBASE_MSEM = 0x1800000,
+	GRCBASE_USEM = 0x1900000,
+	GRCBASE_XSEM = 0x1400000,
+	GRCBASE_YSEM = 0x1500000,
+	GRCBASE_PSEM = 0x1600000,
+	GRCBASE_RSS = 0x238800,
+	GRCBASE_TMLD = 0x4d0000,
+	GRCBASE_MULD = 0x4e0000,
+	GRCBASE_YULD = 0x4c8000,
+	GRCBASE_XYLD = 0x4c0000,
+	GRCBASE_PRM = 0x230000,
+	GRCBASE_PBF_PB1 = 0xda0000,
+	GRCBASE_PBF_PB2 = 0xda4000,
+	GRCBASE_RPB = 0x23c000,
+	GRCBASE_BTB = 0xdb0000,
+	GRCBASE_PBF = 0xd80000,
+	GRCBASE_RDIF = 0x300000,
+	GRCBASE_TDIF = 0x310000,
+	GRCBASE_CDU = 0x580000,
+	GRCBASE_CCFC = 0x2e0000,
+	GRCBASE_TCFC = 0x2d0000,
+	GRCBASE_IGU = 0x180000,
+	GRCBASE_CAU = 0x1c0000,
+	GRCBASE_UMAC = 0x51000,
+	GRCBASE_XMAC = 0x210000,
+	GRCBASE_DBG = 0x10000,
+	GRCBASE_NIG = 0x500000,
+	GRCBASE_WOL = 0x600000,
+	GRCBASE_BMBN = 0x610000,
+	GRCBASE_IPC = 0x20000,
+	GRCBASE_NWM = 0x800000,
+	GRCBASE_NWS = 0x700000,
+	GRCBASE_MS = 0x6a0000,
+	GRCBASE_PHY_PCIE = 0x620000,
+	GRCBASE_LED = 0x6b8000,
+	GRCBASE_MISC_AEU = 0x8000,
+	GRCBASE_BAR0_MAP = 0x1c00000,
 	MAX_BLOCK_ADDR
 };
 
@@ -879,8 +1359,8 @@ enum block_id {
 	BLOCK_PSWRQ,
 	BLOCK_PSWRQ2,
 	BLOCK_PGLCS,
-	BLOCK_PTU,
 	BLOCK_DMAE,
+	BLOCK_PTU,
 	BLOCK_TCM,
 	BLOCK_MCM,
 	BLOCK_UCM,
@@ -934,141 +1414,216 @@ enum block_id {
 	BLOCK_NWS,
 	BLOCK_MS,
 	BLOCK_PHY_PCIE,
+	BLOCK_LED,
 	BLOCK_MISC_AEU,
 	BLOCK_BAR0_MAP,
 	MAX_BLOCK_ID
 };
 
-enum command_type_bit {
-	IGU_COMMAND_TYPE_NOP	= 0,
-	IGU_COMMAND_TYPE_SET	= 1,
-	MAX_COMMAND_TYPE_BIT
+/* binary debug buffer types */
+enum bin_dbg_buffer_type {
+	BIN_BUF_DBG_MODE_TREE,
+	BIN_BUF_DBG_DUMP_REG,
+	BIN_BUF_DBG_DUMP_MEM,
+	BIN_BUF_DBG_IDLE_CHK_REGS,
+	BIN_BUF_DBG_IDLE_CHK_IMMS,
+	BIN_BUF_DBG_IDLE_CHK_RULES,
+	BIN_BUF_DBG_IDLE_CHK_PARSING_DATA,
+	BIN_BUF_DBG_ATTN_BLOCKS,
+	BIN_BUF_DBG_ATTN_REGS,
+	BIN_BUF_DBG_ATTN_INDEXES,
+	BIN_BUF_DBG_ATTN_NAME_OFFSETS,
+	BIN_BUF_DBG_PARSING_STRINGS,
+	MAX_BIN_DBG_BUFFER_TYPE
 };
 
-struct dmae_cmd {
-	__le32 opcode;
-#define DMAE_CMD_SRC_MASK              0x1
-#define DMAE_CMD_SRC_SHIFT             0
-#define DMAE_CMD_DST_MASK              0x3
-#define DMAE_CMD_DST_SHIFT             1
-#define DMAE_CMD_C_DST_MASK            0x1
-#define DMAE_CMD_C_DST_SHIFT           3
-#define DMAE_CMD_CRC_RESET_MASK        0x1
-#define DMAE_CMD_CRC_RESET_SHIFT       4
-#define DMAE_CMD_SRC_ADDR_RESET_MASK   0x1
-#define DMAE_CMD_SRC_ADDR_RESET_SHIFT  5
-#define DMAE_CMD_DST_ADDR_RESET_MASK   0x1
-#define DMAE_CMD_DST_ADDR_RESET_SHIFT  6
-#define DMAE_CMD_COMP_FUNC_MASK        0x1
-#define DMAE_CMD_COMP_FUNC_SHIFT       7
-#define DMAE_CMD_COMP_WORD_EN_MASK     0x1
-#define DMAE_CMD_COMP_WORD_EN_SHIFT    8
-#define DMAE_CMD_COMP_CRC_EN_MASK      0x1
-#define DMAE_CMD_COMP_CRC_EN_SHIFT     9
-#define DMAE_CMD_COMP_CRC_OFFSET_MASK  0x7
-#define DMAE_CMD_COMP_CRC_OFFSET_SHIFT 10
-#define DMAE_CMD_RESERVED1_MASK        0x1
-#define DMAE_CMD_RESERVED1_SHIFT       13
-#define DMAE_CMD_ENDIANITY_MODE_MASK   0x3
-#define DMAE_CMD_ENDIANITY_MODE_SHIFT  14
-#define DMAE_CMD_ERR_HANDLING_MASK     0x3
-#define DMAE_CMD_ERR_HANDLING_SHIFT    16
-#define DMAE_CMD_PORT_ID_MASK          0x3
-#define DMAE_CMD_PORT_ID_SHIFT         18
-#define DMAE_CMD_SRC_PF_ID_MASK        0xF
-#define DMAE_CMD_SRC_PF_ID_SHIFT       20
-#define DMAE_CMD_DST_PF_ID_MASK        0xF
-#define DMAE_CMD_DST_PF_ID_SHIFT       24
-#define DMAE_CMD_SRC_VF_ID_VALID_MASK  0x1
-#define DMAE_CMD_SRC_VF_ID_VALID_SHIFT 28
-#define DMAE_CMD_DST_VF_ID_VALID_MASK  0x1
-#define DMAE_CMD_DST_VF_ID_VALID_SHIFT 29
-#define DMAE_CMD_RESERVED2_MASK        0x3
-#define DMAE_CMD_RESERVED2_SHIFT       30
-	__le32	src_addr_lo;
-	__le32	src_addr_hi;
-	__le32	dst_addr_lo;
-	__le32	dst_addr_hi;
-	__le16	length /* Length in DW */;
-	__le16	opcode_b;
-#define DMAE_CMD_SRC_VF_ID_MASK        0xFF     /* Source VF id */
-#define DMAE_CMD_SRC_VF_ID_SHIFT       0
-#define DMAE_CMD_DST_VF_ID_MASK        0xFF     /* Destination VF id */
-#define DMAE_CMD_DST_VF_ID_SHIFT       8
-	__le32	comp_addr_lo /* PCIe completion address low or grc address */;
-	__le32	comp_addr_hi;
-	__le32	comp_val /* Value to write to copmletion address */;
-	__le32	crc32 /* crc16 result */;
-	__le32	crc_32_c /* crc32_c result */;
-	__le16	crc16 /* crc16 result */;
-	__le16	crc16_c /* crc16_c result */;
-	__le16	crc10 /* crc_t10 result */;
-	__le16	reserved;
-	__le16	xsum16 /* checksum16 result  */;
-	__le16	xsum8 /* checksum8 result  */;
+/* Chip IDs */
+enum chip_ids {
+	CHIP_RESERVED,
+	CHIP_BB_B0,
+	CHIP_RESERVED2,
+	MAX_CHIP_IDS
 };
 
-struct igu_cleanup {
-	__le32 sb_id_and_flags;
-#define IGU_CLEANUP_RESERVED0_MASK     0x7FFFFFF
-#define IGU_CLEANUP_RESERVED0_SHIFT    0
-#define IGU_CLEANUP_CLEANUP_SET_MASK   0x1 /* cleanup clear - 0, set - 1 */
-#define IGU_CLEANUP_CLEANUP_SET_SHIFT  27
-#define IGU_CLEANUP_CLEANUP_TYPE_MASK  0x7
-#define IGU_CLEANUP_CLEANUP_TYPE_SHIFT 28
-#define IGU_CLEANUP_COMMAND_TYPE_MASK  0x1
-#define IGU_CLEANUP_COMMAND_TYPE_SHIFT 31
-	__le32 reserved1;
+/* Attention bit mapping */
+struct dbg_attn_bit_mapping {
+	__le16 data;
+#define DBG_ATTN_BIT_MAPPING_VAL_MASK			0x7FFF
+#define DBG_ATTN_BIT_MAPPING_VAL_SHIFT			0
+#define DBG_ATTN_BIT_MAPPING_IS_UNUSED_BIT_CNT_MASK	0x1
+#define DBG_ATTN_BIT_MAPPING_IS_UNUSED_BIT_CNT_SHIFT	15
 };
 
-union igu_command {
-	struct igu_prod_cons_update	prod_cons_update;
-	struct igu_cleanup		cleanup;
+/* Attention block per-type data */
+struct dbg_attn_block_type_data {
+	__le16 names_offset;
+	__le16 reserved1;
+	u8 num_regs;
+	u8 reserved2;
+	__le16 regs_offset;
 };
 
-struct igu_command_reg_ctrl {
-	__le16	opaque_fid;
-	__le16	igu_command_reg_ctrl_fields;
-#define IGU_COMMAND_REG_CTRL_PXP_BAR_ADDR_MASK  0xFFF
-#define IGU_COMMAND_REG_CTRL_PXP_BAR_ADDR_SHIFT 0
-#define IGU_COMMAND_REG_CTRL_RESERVED_MASK      0x7
-#define IGU_COMMAND_REG_CTRL_RESERVED_SHIFT     12
-#define IGU_COMMAND_REG_CTRL_COMMAND_TYPE_MASK  0x1
-#define IGU_COMMAND_REG_CTRL_COMMAND_TYPE_SHIFT 15
+/* Block attentions */
+struct dbg_attn_block {
+	struct dbg_attn_block_type_data per_type_data[2];
 };
 
-struct igu_mapping_line {
-	__le32 igu_mapping_line_fields;
-#define IGU_MAPPING_LINE_VALID_MASK            0x1
-#define IGU_MAPPING_LINE_VALID_SHIFT           0
-#define IGU_MAPPING_LINE_VECTOR_NUMBER_MASK    0xFF
-#define IGU_MAPPING_LINE_VECTOR_NUMBER_SHIFT   1
-#define IGU_MAPPING_LINE_FUNCTION_NUMBER_MASK  0xFF
-#define IGU_MAPPING_LINE_FUNCTION_NUMBER_SHIFT 9
-#define IGU_MAPPING_LINE_PF_VALID_MASK         0x1      /* PF-1, VF-0 */
-#define IGU_MAPPING_LINE_PF_VALID_SHIFT        17
-#define IGU_MAPPING_LINE_IPS_GROUP_MASK        0x3F
-#define IGU_MAPPING_LINE_IPS_GROUP_SHIFT       18
-#define IGU_MAPPING_LINE_RESERVED_MASK         0xFF
-#define IGU_MAPPING_LINE_RESERVED_SHIFT        24
+/* Attention register result */
+struct dbg_attn_reg_result {
+	__le32 data;
+#define DBG_ATTN_REG_RESULT_STS_ADDRESS_MASK	0xFFFFFF
+#define DBG_ATTN_REG_RESULT_STS_ADDRESS_SHIFT	0
+#define DBG_ATTN_REG_RESULT_NUM_ATTN_IDX_MASK	0xFF
+#define DBG_ATTN_REG_RESULT_NUM_ATTN_IDX_SHIFT	24
+	__le16 attn_idx_offset;
+	__le16 reserved;
+	__le32 sts_val;
+	__le32 mask_val;
+};
+
+/* Attention block result */
+struct dbg_attn_block_result {
+	u8 block_id;
+	u8 data;
+#define DBG_ATTN_BLOCK_RESULT_ATTN_TYPE_MASK	0x3
+#define DBG_ATTN_BLOCK_RESULT_ATTN_TYPE_SHIFT	0
+#define DBG_ATTN_BLOCK_RESULT_NUM_REGS_MASK	0x3F
+#define DBG_ATTN_BLOCK_RESULT_NUM_REGS_SHIFT	2
+	__le16 names_offset;
+	struct dbg_attn_reg_result reg_results[15];
+};
+
+/* mode header */
+struct dbg_mode_hdr {
+	__le16 data;
+#define DBG_MODE_HDR_EVAL_MODE_MASK		0x1
+#define DBG_MODE_HDR_EVAL_MODE_SHIFT		0
+#define DBG_MODE_HDR_MODES_BUF_OFFSET_MASK	0x7FFF
+#define DBG_MODE_HDR_MODES_BUF_OFFSET_SHIFT	1
+};
+
+/* Attention register */
+struct dbg_attn_reg {
+	struct dbg_mode_hdr mode;
+	__le16 attn_idx_offset;
+	__le32 data;
+#define DBG_ATTN_REG_STS_ADDRESS_MASK	0xFFFFFF
+#define DBG_ATTN_REG_STS_ADDRESS_SHIFT	0
+#define DBG_ATTN_REG_NUM_ATTN_IDX_MASK	0xFF
+#define DBG_ATTN_REG_NUM_ATTN_IDX_SHIFT	24
+	__le32 sts_clr_address;
+	__le32 mask_address;
+};
+
+/* attention types */
+enum dbg_attn_type {
+	ATTN_TYPE_INTERRUPT,
+	ATTN_TYPE_PARITY,
+	MAX_DBG_ATTN_TYPE
+};
+
+/* Debug status codes */
+enum dbg_status {
+	DBG_STATUS_OK,
+	DBG_STATUS_APP_VERSION_NOT_SET,
+	DBG_STATUS_UNSUPPORTED_APP_VERSION,
+	DBG_STATUS_DBG_BLOCK_NOT_RESET,
+	DBG_STATUS_INVALID_ARGS,
+	DBG_STATUS_OUTPUT_ALREADY_SET,
+	DBG_STATUS_INVALID_PCI_BUF_SIZE,
+	DBG_STATUS_PCI_BUF_ALLOC_FAILED,
+	DBG_STATUS_PCI_BUF_NOT_ALLOCATED,
+	DBG_STATUS_TOO_MANY_INPUTS,
+	DBG_STATUS_INPUT_OVERLAP,
+	DBG_STATUS_HW_ONLY_RECORDING,
+	DBG_STATUS_STORM_ALREADY_ENABLED,
+	DBG_STATUS_STORM_NOT_ENABLED,
+	DBG_STATUS_BLOCK_ALREADY_ENABLED,
+	DBG_STATUS_BLOCK_NOT_ENABLED,
+	DBG_STATUS_NO_INPUT_ENABLED,
+	DBG_STATUS_NO_FILTER_TRIGGER_64B,
+	DBG_STATUS_FILTER_ALREADY_ENABLED,
+	DBG_STATUS_TRIGGER_ALREADY_ENABLED,
+	DBG_STATUS_TRIGGER_NOT_ENABLED,
+	DBG_STATUS_CANT_ADD_CONSTRAINT,
+	DBG_STATUS_TOO_MANY_TRIGGER_STATES,
+	DBG_STATUS_TOO_MANY_CONSTRAINTS,
+	DBG_STATUS_RECORDING_NOT_STARTED,
+	DBG_STATUS_DATA_DIDNT_TRIGGER,
+	DBG_STATUS_NO_DATA_RECORDED,
+	DBG_STATUS_DUMP_BUF_TOO_SMALL,
+	DBG_STATUS_DUMP_NOT_CHUNK_ALIGNED,
+	DBG_STATUS_UNKNOWN_CHIP,
+	DBG_STATUS_VIRT_MEM_ALLOC_FAILED,
+	DBG_STATUS_BLOCK_IN_RESET,
+	DBG_STATUS_INVALID_TRACE_SIGNATURE,
+	DBG_STATUS_INVALID_NVRAM_BUNDLE,
+	DBG_STATUS_NVRAM_GET_IMAGE_FAILED,
+	DBG_STATUS_NON_ALIGNED_NVRAM_IMAGE,
+	DBG_STATUS_NVRAM_READ_FAILED,
+	DBG_STATUS_IDLE_CHK_PARSE_FAILED,
+	DBG_STATUS_MCP_TRACE_BAD_DATA,
+	DBG_STATUS_MCP_TRACE_NO_META,
+	DBG_STATUS_MCP_COULD_NOT_HALT,
+	DBG_STATUS_MCP_COULD_NOT_RESUME,
+	DBG_STATUS_DMAE_FAILED,
+	DBG_STATUS_SEMI_FIFO_NOT_EMPTY,
+	DBG_STATUS_IGU_FIFO_BAD_DATA,
+	DBG_STATUS_MCP_COULD_NOT_MASK_PRTY,
+	DBG_STATUS_FW_ASSERTS_PARSE_FAILED,
+	DBG_STATUS_REG_FIFO_BAD_DATA,
+	DBG_STATUS_PROTECTION_OVERRIDE_BAD_DATA,
+	DBG_STATUS_DBG_ARRAY_NOT_SET,
+	MAX_DBG_STATUS
 };
 
-struct igu_msix_vector {
-	struct regpair	address;
-	__le32		data;
-	__le32		msix_vector_fields;
-#define IGU_MSIX_VECTOR_MASK_BIT_MASK      0x1
-#define IGU_MSIX_VECTOR_MASK_BIT_SHIFT     0
-#define IGU_MSIX_VECTOR_RESERVED0_MASK     0x7FFF
-#define IGU_MSIX_VECTOR_RESERVED0_SHIFT    1
-#define IGU_MSIX_VECTOR_STEERING_TAG_MASK  0xFF
-#define IGU_MSIX_VECTOR_STEERING_TAG_SHIFT 16
-#define IGU_MSIX_VECTOR_RESERVED1_MASK     0xFF
-#define IGU_MSIX_VECTOR_RESERVED1_SHIFT    24
+/********************************/
+/* HSI Init Functions constants */
+/********************************/
+
+/* Number of VLAN priorities */
+#define NUM_OF_VLAN_PRIORITIES	8
+
+/* QM per-port init parameters */
+struct init_qm_port_params {
+	u8 active;
+	u8 active_phys_tcs;
+	__le16 num_pbf_cmd_lines;
+	__le16 num_btb_blocks;
+	__le16 reserved;
 };
 
+/* QM per-PQ init parameters */
+struct init_qm_pq_params {
+	u8 vport_id;
+	u8 tc_id;
+	u8 wrr_group;
+	u8 rl_valid;
+};
+
+/* QM per-vport init parameters */
+struct init_qm_vport_params {
+	__le32 vport_rl;
+	__le16 vport_wfq;
+	__le16 first_tx_pq_id[NUM_OF_TCS];
+};
+
+/**************************************/
+/* Init Tool HSI constants and macros */
+/**************************************/
+
+/* Width of GRC address in bits (addresses are specified in dwords) */
+#define GRC_ADDR_BITS	23
+#define MAX_GRC_ADDR	((1 << GRC_ADDR_BITS) - 1)
+
+/* indicates an init that should be applied to any phase ID */
+#define ANY_PHASE_ID	0xffff
+
+/* Max size in dwords of a zipped array */
+#define MAX_ZIPPED_SIZE	8192
+
 enum init_modes {
-	MODE_BB_A0,
+	MODE_RESERVED,
 	MODE_BB_B0,
 	MODE_RESERVED2,
 	MODE_ASIC,
@@ -1083,7 +1638,8 @@ enum init_modes {
 	MODE_PORTS_PER_ENG_2,
 	MODE_PORTS_PER_ENG_4,
 	MODE_100G,
-	MODE_EAGLE_ENG1_WORKAROUND,
+	MODE_40G,
+	MODE_RESERVED7,
 	MAX_INIT_MODES
 };
 
@@ -1096,484 +1652,302 @@ enum init_phases {
 	MAX_INIT_PHASES
 };
 
-/* per encapsulation type enabling flags */
-struct prs_reg_encapsulation_type_en {
-	u8 flags;
-#define PRS_REG_ENCAPSULATION_TYPE_EN_ETH_OVER_GRE_ENABLE_MASK     0x1
-#define PRS_REG_ENCAPSULATION_TYPE_EN_ETH_OVER_GRE_ENABLE_SHIFT    0
-#define PRS_REG_ENCAPSULATION_TYPE_EN_IP_OVER_GRE_ENABLE_MASK      0x1
-#define PRS_REG_ENCAPSULATION_TYPE_EN_IP_OVER_GRE_ENABLE_SHIFT     1
-#define PRS_REG_ENCAPSULATION_TYPE_EN_VXLAN_ENABLE_MASK            0x1
-#define PRS_REG_ENCAPSULATION_TYPE_EN_VXLAN_ENABLE_SHIFT           2
-#define PRS_REG_ENCAPSULATION_TYPE_EN_T_TAG_ENABLE_MASK            0x1
-#define PRS_REG_ENCAPSULATION_TYPE_EN_T_TAG_ENABLE_SHIFT           3
-#define PRS_REG_ENCAPSULATION_TYPE_EN_ETH_OVER_GENEVE_ENABLE_MASK  0x1
-#define PRS_REG_ENCAPSULATION_TYPE_EN_ETH_OVER_GENEVE_ENABLE_SHIFT 4
-#define PRS_REG_ENCAPSULATION_TYPE_EN_IP_OVER_GENEVE_ENABLE_MASK   0x1
-#define PRS_REG_ENCAPSULATION_TYPE_EN_IP_OVER_GENEVE_ENABLE_SHIFT  5
-#define PRS_REG_ENCAPSULATION_TYPE_EN_RESERVED_MASK                0x3
-#define PRS_REG_ENCAPSULATION_TYPE_EN_RESERVED_SHIFT               6
-};
-
-enum pxp_tph_st_hint {
-	TPH_ST_HINT_BIDIR /* Read/Write access by Host and Device */,
-	TPH_ST_HINT_REQUESTER /* Read/Write access by Device */,
-	TPH_ST_HINT_TARGET,
-	TPH_ST_HINT_TARGET_PRIO,
-	MAX_PXP_TPH_ST_HINT
+enum init_split_types {
+	SPLIT_TYPE_NONE,
+	SPLIT_TYPE_PORT,
+	SPLIT_TYPE_PF,
+	SPLIT_TYPE_PORT_PF,
+	SPLIT_TYPE_VF,
+	MAX_INIT_SPLIT_TYPES
 };
 
-/* QM hardware structure of enable bypass credit mask */
-struct qm_rf_bypass_mask {
-	u8 flags;
-#define QM_RF_BYPASS_MASK_LINEVOQ_MASK    0x1
-#define QM_RF_BYPASS_MASK_LINEVOQ_SHIFT   0
-#define QM_RF_BYPASS_MASK_RESERVED0_MASK  0x1
-#define QM_RF_BYPASS_MASK_RESERVED0_SHIFT 1
-#define QM_RF_BYPASS_MASK_PFWFQ_MASK      0x1
-#define QM_RF_BYPASS_MASK_PFWFQ_SHIFT     2
-#define QM_RF_BYPASS_MASK_VPWFQ_MASK      0x1
-#define QM_RF_BYPASS_MASK_VPWFQ_SHIFT     3
-#define QM_RF_BYPASS_MASK_PFRL_MASK       0x1
-#define QM_RF_BYPASS_MASK_PFRL_SHIFT      4
-#define QM_RF_BYPASS_MASK_VPQCNRL_MASK    0x1
-#define QM_RF_BYPASS_MASK_VPQCNRL_SHIFT   5
-#define QM_RF_BYPASS_MASK_FWPAUSE_MASK    0x1
-#define QM_RF_BYPASS_MASK_FWPAUSE_SHIFT   6
-#define QM_RF_BYPASS_MASK_RESERVED1_MASK  0x1
-#define QM_RF_BYPASS_MASK_RESERVED1_SHIFT 7
-};
-
-/* QM hardware structure of opportunistic credit mask */
-struct qm_rf_opportunistic_mask {
-	__le16 flags;
-#define QM_RF_OPPORTUNISTIC_MASK_LINEVOQ_MASK     0x1
-#define QM_RF_OPPORTUNISTIC_MASK_LINEVOQ_SHIFT    0
-#define QM_RF_OPPORTUNISTIC_MASK_BYTEVOQ_MASK     0x1
-#define QM_RF_OPPORTUNISTIC_MASK_BYTEVOQ_SHIFT    1
-#define QM_RF_OPPORTUNISTIC_MASK_PFWFQ_MASK       0x1
-#define QM_RF_OPPORTUNISTIC_MASK_PFWFQ_SHIFT      2
-#define QM_RF_OPPORTUNISTIC_MASK_VPWFQ_MASK       0x1
-#define QM_RF_OPPORTUNISTIC_MASK_VPWFQ_SHIFT      3
-#define QM_RF_OPPORTUNISTIC_MASK_PFRL_MASK        0x1
-#define QM_RF_OPPORTUNISTIC_MASK_PFRL_SHIFT       4
-#define QM_RF_OPPORTUNISTIC_MASK_VPQCNRL_MASK     0x1
-#define QM_RF_OPPORTUNISTIC_MASK_VPQCNRL_SHIFT    5
-#define QM_RF_OPPORTUNISTIC_MASK_FWPAUSE_MASK     0x1
-#define QM_RF_OPPORTUNISTIC_MASK_FWPAUSE_SHIFT    6
-#define QM_RF_OPPORTUNISTIC_MASK_RESERVED0_MASK   0x1
-#define QM_RF_OPPORTUNISTIC_MASK_RESERVED0_SHIFT  7
-#define QM_RF_OPPORTUNISTIC_MASK_QUEUEEMPTY_MASK  0x1
-#define QM_RF_OPPORTUNISTIC_MASK_QUEUEEMPTY_SHIFT 8
-#define QM_RF_OPPORTUNISTIC_MASK_RESERVED1_MASK   0x7F
-#define QM_RF_OPPORTUNISTIC_MASK_RESERVED1_SHIFT  9
-};
-
-/* QM hardware structure of QM map memory */
-struct qm_rf_pq_map {
-	u32 reg;
-#define QM_RF_PQ_MAP_PQ_VALID_MASK          0x1         /* PQ active */
-#define QM_RF_PQ_MAP_PQ_VALID_SHIFT         0
-#define QM_RF_PQ_MAP_RL_ID_MASK             0xFF        /* RL ID */
-#define QM_RF_PQ_MAP_RL_ID_SHIFT            1
-#define QM_RF_PQ_MAP_VP_PQ_ID_MASK          0x1FF
-#define QM_RF_PQ_MAP_VP_PQ_ID_SHIFT         9
-#define QM_RF_PQ_MAP_VOQ_MASK               0x1F        /* VOQ */
-#define QM_RF_PQ_MAP_VOQ_SHIFT              18
-#define QM_RF_PQ_MAP_WRR_WEIGHT_GROUP_MASK  0x3         /* WRR weight */
-#define QM_RF_PQ_MAP_WRR_WEIGHT_GROUP_SHIFT 23
-#define QM_RF_PQ_MAP_RL_VALID_MASK          0x1         /* RL active */
-#define QM_RF_PQ_MAP_RL_VALID_SHIFT         25
-#define QM_RF_PQ_MAP_RESERVED_MASK          0x3F
-#define QM_RF_PQ_MAP_RESERVED_SHIFT         26
-};
-
-/* Completion params for aggregated interrupt completion */
-struct sdm_agg_int_comp_params {
-	__le16 params;
-#define SDM_AGG_INT_COMP_PARAMS_AGG_INT_INDEX_MASK      0x3F
-#define SDM_AGG_INT_COMP_PARAMS_AGG_INT_INDEX_SHIFT     0
-#define SDM_AGG_INT_COMP_PARAMS_AGG_VECTOR_ENABLE_MASK  0x1
-#define SDM_AGG_INT_COMP_PARAMS_AGG_VECTOR_ENABLE_SHIFT 6
-#define SDM_AGG_INT_COMP_PARAMS_AGG_VECTOR_BIT_MASK     0x1FF
-#define SDM_AGG_INT_COMP_PARAMS_AGG_VECTOR_BIT_SHIFT    7
-};
-
-/* SDM operation gen command (generate aggregative interrupt) */
-struct sdm_op_gen {
-	__le32 command;
-#define SDM_OP_GEN_COMP_PARAM_MASK  0xFFFF      /* completion parameters 0-15 */
-#define SDM_OP_GEN_COMP_PARAM_SHIFT 0
-#define SDM_OP_GEN_COMP_TYPE_MASK   0xF         /* completion type 16-19 */
-#define SDM_OP_GEN_COMP_TYPE_SHIFT  16
-#define SDM_OP_GEN_RESERVED_MASK    0xFFF       /* reserved 20-31 */
-#define SDM_OP_GEN_RESERVED_SHIFT   20
-};
-
-/*********************************** Init ************************************/
-
-/* Width of GRC address in bits (addresses are specified in dwords) */
-#define GRC_ADDR_BITS                   23
-#define MAX_GRC_ADDR                    ((1 << GRC_ADDR_BITS) - 1)
-
-/* indicates an init that should be applied to any phase ID */
-#define ANY_PHASE_ID                    0xffff
-
-/* init pattern size in bytes */
-#define INIT_PATTERN_SIZE_BITS  4
-#define MAX_INIT_PATTERN_SIZE	BIT(INIT_PATTERN_SIZE_BITS)
-
-/* Max size in dwords of a zipped array */
-#define MAX_ZIPPED_SIZE                 8192
-
-/* Global PXP window */
-#define NUM_OF_PXP_WIN                  19
-#define PXP_WIN_DWORD_SIZE_BITS 10
-#define PXP_WIN_DWORD_SIZE		BIT(PXP_WIN_DWORD_SIZE_BITS)
-#define PXP_WIN_BYTE_SIZE_BITS  (PXP_WIN_DWORD_SIZE_BITS + 2)
-#define PXP_WIN_BYTE_SIZE               (PXP_WIN_DWORD_SIZE * 4)
-
-/********************************* GRC Dump **********************************/
-
-/* width of GRC dump register sequence length in bits */
-#define DUMP_SEQ_LEN_BITS                       8
-#define DUMP_SEQ_LEN_MAX_VAL            ((1 << DUMP_SEQ_LEN_BITS) - 1)
-
-/* width of GRC dump memory length in bits */
-#define DUMP_MEM_LEN_BITS                       18
-#define DUMP_MEM_LEN_MAX_VAL            ((1 << DUMP_MEM_LEN_BITS) - 1)
-
-/* width of register type ID in bits */
-#define REG_TYPE_ID_BITS                        6
-#define REG_TYPE_ID_MAX_VAL                     ((1 << REG_TYPE_ID_BITS) - 1)
-
-/* width of block ID in bits */
-#define BLOCK_ID_BITS                           8
-#define BLOCK_ID_MAX_VAL                        ((1 << BLOCK_ID_BITS) - 1)
-
-/******************************** Idle Check *********************************/
-
-/* max number of idle check predicate immediates */
-#define MAX_IDLE_CHK_PRED_IMM           3
-
-/* max number of idle check argument registers */
-#define MAX_IDLE_CHK_READ_REGS          3
-
-/* max number of idle check loops */
-#define MAX_IDLE_CHK_LOOPS                      0x10000
-
-/* max idle check address increment */
-#define MAX_IDLE_CHK_INCREMENT          0x10000
-
-/* inicates an undefined idle check line index */
-#define IDLE_CHK_UNDEFINED_LINE_IDX     0xffffff
-
-/* max number of register values following the idle check header */
-#define IDLE_CHK_MAX_DUMP_REGS          2
-
-/* arguments for IDLE_CHK_MACRO_TYPE_QM_RD_WR */
-#define IDLE_CHK_QM_RD_WR_PTR           0
-#define IDLE_CHK_QM_RD_WR_BANK          1
-
-/**************************************/
-/* HSI Functions constants and macros */
-/**************************************/
-
-/* Number of VLAN priorities */
-#define NUM_OF_VLAN_PRIORITIES                  8
-
-/* the MCP Trace meta data signautre is duplicated in the perl script that
- * generats the NVRAM images.
- */
-#define MCP_TRACE_META_IMAGE_SIGNATURE  0x669955aa
-
 /* Binary buffer header */
 struct bin_buffer_hdr {
-	u32	offset;
-	u32	length /* buffer length in bytes */;
+	__le32 offset;
+	__le32 length;
 };
 
-/* binary buffer types */
-enum bin_buffer_type {
-	BIN_BUF_FW_VER_INFO /* fw_ver_info struct */,
-	BIN_BUF_INIT_CMD /* init commands */,
-	BIN_BUF_INIT_VAL /* init data */,
-	BIN_BUF_INIT_MODE_TREE /* init modes tree */,
-	BIN_BUF_IRO /* internal RAM offsets array */,
-	MAX_BIN_BUFFER_TYPE
-};
-
-/* Chip IDs */
-enum chip_ids {
-	CHIP_BB_A0 /* BB A0 chip ID */,
-	CHIP_BB_B0 /* BB B0 chip ID */,
-	CHIP_K2 /* AH chip ID */,
-	MAX_CHIP_IDS
+/* binary init buffer types */
+enum bin_init_buffer_type {
+	BIN_BUF_FW_VER_INFO,
+	BIN_BUF_INIT_CMD,
+	BIN_BUF_INIT_VAL,
+	BIN_BUF_INIT_MODE_TREE,
+	BIN_BUF_IRO,
+	MAX_BIN_INIT_BUFFER_TYPE
 };
 
+/* init array header: raw */
 struct init_array_raw_hdr {
 	__le32 data;
-#define INIT_ARRAY_RAW_HDR_TYPE_MASK    0xF
-#define INIT_ARRAY_RAW_HDR_TYPE_SHIFT   0
-#define INIT_ARRAY_RAW_HDR_PARAMS_MASK  0xFFFFFFF       /* init array params */
-#define INIT_ARRAY_RAW_HDR_PARAMS_SHIFT 4
+#define INIT_ARRAY_RAW_HDR_TYPE_MASK	0xF
+#define INIT_ARRAY_RAW_HDR_TYPE_SHIFT	0
+#define INIT_ARRAY_RAW_HDR_PARAMS_MASK	0xFFFFFFF
+#define INIT_ARRAY_RAW_HDR_PARAMS_SHIFT	4
 };
 
+/* init array header: standard */
 struct init_array_standard_hdr {
 	__le32 data;
-#define INIT_ARRAY_STANDARD_HDR_TYPE_MASK  0xF
-#define INIT_ARRAY_STANDARD_HDR_TYPE_SHIFT 0
-#define INIT_ARRAY_STANDARD_HDR_SIZE_MASK  0xFFFFFFF
-#define INIT_ARRAY_STANDARD_HDR_SIZE_SHIFT 4
+#define INIT_ARRAY_STANDARD_HDR_TYPE_MASK	0xF
+#define INIT_ARRAY_STANDARD_HDR_TYPE_SHIFT	0
+#define INIT_ARRAY_STANDARD_HDR_SIZE_MASK	0xFFFFFFF
+#define INIT_ARRAY_STANDARD_HDR_SIZE_SHIFT	4
 };
 
+/* init array header: zipped */
 struct init_array_zipped_hdr {
 	__le32 data;
-#define INIT_ARRAY_ZIPPED_HDR_TYPE_MASK         0xF
-#define INIT_ARRAY_ZIPPED_HDR_TYPE_SHIFT        0
-#define INIT_ARRAY_ZIPPED_HDR_ZIPPED_SIZE_MASK  0xFFFFFFF
-#define INIT_ARRAY_ZIPPED_HDR_ZIPPED_SIZE_SHIFT 4
+#define INIT_ARRAY_ZIPPED_HDR_TYPE_MASK		0xF
+#define INIT_ARRAY_ZIPPED_HDR_TYPE_SHIFT	0
+#define INIT_ARRAY_ZIPPED_HDR_ZIPPED_SIZE_MASK	0xFFFFFFF
+#define INIT_ARRAY_ZIPPED_HDR_ZIPPED_SIZE_SHIFT	4
 };
 
+/* init array header: pattern */
 struct init_array_pattern_hdr {
 	__le32 data;
-#define INIT_ARRAY_PATTERN_HDR_TYPE_MASK          0xF
-#define INIT_ARRAY_PATTERN_HDR_TYPE_SHIFT         0
-#define INIT_ARRAY_PATTERN_HDR_PATTERN_SIZE_MASK  0xF
-#define INIT_ARRAY_PATTERN_HDR_PATTERN_SIZE_SHIFT 4
-#define INIT_ARRAY_PATTERN_HDR_REPETITIONS_MASK   0xFFFFFF
-#define INIT_ARRAY_PATTERN_HDR_REPETITIONS_SHIFT  8
+#define INIT_ARRAY_PATTERN_HDR_TYPE_MASK		0xF
+#define INIT_ARRAY_PATTERN_HDR_TYPE_SHIFT		0
+#define INIT_ARRAY_PATTERN_HDR_PATTERN_SIZE_MASK	0xF
+#define INIT_ARRAY_PATTERN_HDR_PATTERN_SIZE_SHIFT	4
+#define INIT_ARRAY_PATTERN_HDR_REPETITIONS_MASK		0xFFFFFF
+#define INIT_ARRAY_PATTERN_HDR_REPETITIONS_SHIFT	8
 };
 
+/* init array header union */
 union init_array_hdr {
-	struct init_array_raw_hdr	raw /* raw init array header */;
-	struct init_array_standard_hdr	standard;
-	struct init_array_zipped_hdr	zipped /* zipped init array header */;
-	struct init_array_pattern_hdr	pattern /* pattern init array header */;
+	struct init_array_raw_hdr raw;
+	struct init_array_standard_hdr standard;
+	struct init_array_zipped_hdr zipped;
+	struct init_array_pattern_hdr pattern;
 };
 
+/* init array types */
 enum init_array_types {
-	INIT_ARR_STANDARD /* standard init array */,
-	INIT_ARR_ZIPPED /* zipped init array */,
-	INIT_ARR_PATTERN /* a repeated pattern */,
+	INIT_ARR_STANDARD,
+	INIT_ARR_ZIPPED,
+	INIT_ARR_PATTERN,
 	MAX_INIT_ARRAY_TYPES
 };
 
 /* init operation: callback */
 struct init_callback_op {
-	__le32	op_data;
-#define INIT_CALLBACK_OP_OP_MASK        0xF
-#define INIT_CALLBACK_OP_OP_SHIFT       0
-#define INIT_CALLBACK_OP_RESERVED_MASK  0xFFFFFFF
-#define INIT_CALLBACK_OP_RESERVED_SHIFT 4
-	__le16	callback_id /* Callback ID */;
-	__le16	block_id /* Blocks ID */;
+	__le32 op_data;
+#define INIT_CALLBACK_OP_OP_MASK	0xF
+#define INIT_CALLBACK_OP_OP_SHIFT	0
+#define INIT_CALLBACK_OP_RESERVED_MASK	0xFFFFFFF
+#define INIT_CALLBACK_OP_RESERVED_SHIFT	4
+	__le16 callback_id;
+	__le16 block_id;
 };
 
 /* init operation: delay */
 struct init_delay_op {
-	__le32	op_data;
-#define INIT_DELAY_OP_OP_MASK        0xF
-#define INIT_DELAY_OP_OP_SHIFT       0
-#define INIT_DELAY_OP_RESERVED_MASK  0xFFFFFFF
-#define INIT_DELAY_OP_RESERVED_SHIFT 4
-	__le32	delay /* delay in us */;
+	__le32 op_data;
+#define INIT_DELAY_OP_OP_MASK		0xF
+#define INIT_DELAY_OP_OP_SHIFT		0
+#define INIT_DELAY_OP_RESERVED_MASK	0xFFFFFFF
+#define INIT_DELAY_OP_RESERVED_SHIFT	4
+	__le32 delay;
 };
 
 /* init operation: if_mode */
 struct init_if_mode_op {
 	__le32 op_data;
-#define INIT_IF_MODE_OP_OP_MASK          0xF
-#define INIT_IF_MODE_OP_OP_SHIFT         0
-#define INIT_IF_MODE_OP_RESERVED1_MASK   0xFFF
-#define INIT_IF_MODE_OP_RESERVED1_SHIFT  4
-#define INIT_IF_MODE_OP_CMD_OFFSET_MASK  0xFFFF
-#define INIT_IF_MODE_OP_CMD_OFFSET_SHIFT 16
-	__le16	reserved2;
-	__le16	modes_buf_offset;
+#define INIT_IF_MODE_OP_OP_MASK			0xF
+#define INIT_IF_MODE_OP_OP_SHIFT		0
+#define INIT_IF_MODE_OP_RESERVED1_MASK		0xFFF
+#define INIT_IF_MODE_OP_RESERVED1_SHIFT		4
+#define INIT_IF_MODE_OP_CMD_OFFSET_MASK		0xFFFF
+#define INIT_IF_MODE_OP_CMD_OFFSET_SHIFT	16
+	__le16 reserved2;
+	__le16 modes_buf_offset;
 };
 
-/*  init operation: if_phase */
+/* init operation: if_phase */
 struct init_if_phase_op {
 	__le32 op_data;
-#define INIT_IF_PHASE_OP_OP_MASK           0xF
-#define INIT_IF_PHASE_OP_OP_SHIFT          0
-#define INIT_IF_PHASE_OP_DMAE_ENABLE_MASK  0x1
-#define INIT_IF_PHASE_OP_DMAE_ENABLE_SHIFT 4
-#define INIT_IF_PHASE_OP_RESERVED1_MASK    0x7FF
-#define INIT_IF_PHASE_OP_RESERVED1_SHIFT   5
-#define INIT_IF_PHASE_OP_CMD_OFFSET_MASK   0xFFFF
-#define INIT_IF_PHASE_OP_CMD_OFFSET_SHIFT  16
+#define INIT_IF_PHASE_OP_OP_MASK		0xF
+#define INIT_IF_PHASE_OP_OP_SHIFT		0
+#define INIT_IF_PHASE_OP_DMAE_ENABLE_MASK	0x1
+#define INIT_IF_PHASE_OP_DMAE_ENABLE_SHIFT	4
+#define INIT_IF_PHASE_OP_RESERVED1_MASK		0x7FF
+#define INIT_IF_PHASE_OP_RESERVED1_SHIFT	5
+#define INIT_IF_PHASE_OP_CMD_OFFSET_MASK	0xFFFF
+#define INIT_IF_PHASE_OP_CMD_OFFSET_SHIFT	16
 	__le32 phase_data;
-#define INIT_IF_PHASE_OP_PHASE_MASK        0xFF /* Init phase */
-#define INIT_IF_PHASE_OP_PHASE_SHIFT       0
-#define INIT_IF_PHASE_OP_RESERVED2_MASK    0xFF
-#define INIT_IF_PHASE_OP_RESERVED2_SHIFT   8
-#define INIT_IF_PHASE_OP_PHASE_ID_MASK     0xFFFF /* Init phase ID */
-#define INIT_IF_PHASE_OP_PHASE_ID_SHIFT    16
+#define INIT_IF_PHASE_OP_PHASE_MASK		0xFF
+#define INIT_IF_PHASE_OP_PHASE_SHIFT		0
+#define INIT_IF_PHASE_OP_RESERVED2_MASK		0xFF
+#define INIT_IF_PHASE_OP_RESERVED2_SHIFT	8
+#define INIT_IF_PHASE_OP_PHASE_ID_MASK		0xFFFF
+#define INIT_IF_PHASE_OP_PHASE_ID_SHIFT		16
 };
 
 /* init mode operators */
 enum init_mode_ops {
-	INIT_MODE_OP_NOT /* init mode not operator */,
-	INIT_MODE_OP_OR /* init mode or operator */,
-	INIT_MODE_OP_AND /* init mode and operator */,
+	INIT_MODE_OP_NOT,
+	INIT_MODE_OP_OR,
+	INIT_MODE_OP_AND,
 	MAX_INIT_MODE_OPS
 };
 
 /* init operation: raw */
 struct init_raw_op {
-	__le32	op_data;
-#define INIT_RAW_OP_OP_MASK      0xF
-#define INIT_RAW_OP_OP_SHIFT     0
-#define INIT_RAW_OP_PARAM1_MASK  0xFFFFFFF      /* init param 1 */
-#define INIT_RAW_OP_PARAM1_SHIFT 4
-	__le32	param2 /* Init param 2 */;
+	__le32 op_data;
+#define INIT_RAW_OP_OP_MASK		0xF
+#define INIT_RAW_OP_OP_SHIFT		0
+#define INIT_RAW_OP_PARAM1_MASK		0xFFFFFFF
+#define INIT_RAW_OP_PARAM1_SHIFT	4
+	__le32 param2;
 };
 
 /* init array params */
 struct init_op_array_params {
-	__le16	size /* array size in dwords */;
-	__le16	offset /* array start offset in dwords */;
+	__le16 size;
+	__le16 offset;
 };
 
 /* Write init operation arguments */
 union init_write_args {
-	__le32				inline_val;
-	__le32				zeros_count;
-	__le32				array_offset;
-	struct init_op_array_params	runtime;
+	__le32 inline_val;
+	__le32 zeros_count;
+	__le32 array_offset;
+	struct init_op_array_params runtime;
 };
 
 /* init operation: write */
 struct init_write_op {
 	__le32 data;
-#define INIT_WRITE_OP_OP_MASK        0xF
-#define INIT_WRITE_OP_OP_SHIFT       0
-#define INIT_WRITE_OP_SOURCE_MASK    0x7
-#define INIT_WRITE_OP_SOURCE_SHIFT   4
-#define INIT_WRITE_OP_RESERVED_MASK  0x1
-#define INIT_WRITE_OP_RESERVED_SHIFT 7
-#define INIT_WRITE_OP_WIDE_BUS_MASK  0x1
-#define INIT_WRITE_OP_WIDE_BUS_SHIFT 8
-#define INIT_WRITE_OP_ADDRESS_MASK   0x7FFFFF
-#define INIT_WRITE_OP_ADDRESS_SHIFT  9
-	union init_write_args args /* Write init operation arguments */;
+#define INIT_WRITE_OP_OP_MASK		0xF
+#define INIT_WRITE_OP_OP_SHIFT		0
+#define INIT_WRITE_OP_SOURCE_MASK	0x7
+#define INIT_WRITE_OP_SOURCE_SHIFT	4
+#define INIT_WRITE_OP_RESERVED_MASK	0x1
+#define INIT_WRITE_OP_RESERVED_SHIFT	7
+#define INIT_WRITE_OP_WIDE_BUS_MASK	0x1
+#define INIT_WRITE_OP_WIDE_BUS_SHIFT	8
+#define INIT_WRITE_OP_ADDRESS_MASK	0x7FFFFF
+#define INIT_WRITE_OP_ADDRESS_SHIFT	9
+	union init_write_args args;
 };
 
 /* init operation: read */
 struct init_read_op {
 	__le32 op_data;
-#define INIT_READ_OP_OP_MASK         0xF
-#define INIT_READ_OP_OP_SHIFT        0
-#define INIT_READ_OP_POLL_TYPE_MASK  0xF
-#define INIT_READ_OP_POLL_TYPE_SHIFT 4
-#define INIT_READ_OP_RESERVED_MASK   0x1
-#define INIT_READ_OP_RESERVED_SHIFT  8
-#define INIT_READ_OP_ADDRESS_MASK    0x7FFFFF
-#define INIT_READ_OP_ADDRESS_SHIFT   9
+#define INIT_READ_OP_OP_MASK		0xF
+#define INIT_READ_OP_OP_SHIFT		0
+#define INIT_READ_OP_POLL_TYPE_MASK	0xF
+#define INIT_READ_OP_POLL_TYPE_SHIFT	4
+#define INIT_READ_OP_RESERVED_MASK	0x1
+#define INIT_READ_OP_RESERVED_SHIFT	8
+#define INIT_READ_OP_ADDRESS_MASK	0x7FFFFF
+#define INIT_READ_OP_ADDRESS_SHIFT	9
 	__le32 expected_val;
+
 };
 
 /* Init operations union */
 union init_op {
-	struct init_raw_op	raw /* raw init operation */;
-	struct init_write_op	write /* write init operation */;
-	struct init_read_op	read /* read init operation */;
-	struct init_if_mode_op	if_mode /* if_mode init operation */;
-	struct init_if_phase_op if_phase /* if_phase init operation */;
-	struct init_callback_op callback /* callback init operation */;
-	struct init_delay_op	delay /* delay init operation */;
+	struct init_raw_op raw;
+	struct init_write_op write;
+	struct init_read_op read;
+	struct init_if_mode_op if_mode;
+	struct init_if_phase_op if_phase;
+	struct init_callback_op callback;
+	struct init_delay_op delay;
 };
 
 /* Init command operation types */
 enum init_op_types {
-	INIT_OP_READ /* GRC read init command */,
-	INIT_OP_WRITE /* GRC write init command */,
+	INIT_OP_READ,
+	INIT_OP_WRITE,
 	INIT_OP_IF_MODE,
 	INIT_OP_IF_PHASE,
-	INIT_OP_DELAY /* delay init command */,
-	INIT_OP_CALLBACK /* callback init command */,
+	INIT_OP_DELAY,
+	INIT_OP_CALLBACK,
 	MAX_INIT_OP_TYPES
 };
 
+/* init polling types */
 enum init_poll_types {
-	INIT_POLL_NONE /* No polling */,
-	INIT_POLL_EQ /* init value is included in the init command */,
-	INIT_POLL_OR /* init value is all zeros */,
-	INIT_POLL_AND /* init value is an array of values */,
+	INIT_POLL_NONE,
+	INIT_POLL_EQ,
+	INIT_POLL_OR,
+	INIT_POLL_AND,
 	MAX_INIT_POLL_TYPES
 };
 
 /* init source types */
 enum init_source_types {
-	INIT_SRC_INLINE /* init value is included in the init command */,
-	INIT_SRC_ZEROS /* init value is all zeros */,
-	INIT_SRC_ARRAY /* init value is an array of values */,
-	INIT_SRC_RUNTIME /* init value is provided during runtime */,
+	INIT_SRC_INLINE,
+	INIT_SRC_ZEROS,
+	INIT_SRC_ARRAY,
+	INIT_SRC_RUNTIME,
 	MAX_INIT_SOURCE_TYPES
 };
 
 /* Internal RAM Offsets macro data */
 struct iro {
-	u32	base /* RAM field offset */;
-	u16	m1 /* multiplier 1 */;
-	u16	m2 /* multiplier 2 */;
-	u16	m3 /* multiplier 3 */;
-	u16	size /* RAM field size */;
+	__le32 base;
+	__le16 m1;
+	__le16 m2;
+	__le16 m3;
+	__le16 size;
 };
 
-/* QM per-port init parameters */
-struct init_qm_port_params {
-	u8	active /* Indicates if this port is active */;
-	u8	num_active_phys_tcs;
-	u16	num_pbf_cmd_lines;
-	u16	num_btb_blocks;
-	__le16	reserved;
-};
-
-/* QM per-PQ init parameters */
-struct init_qm_pq_params {
-	u8	vport_id /* VPORT ID */;
-	u8	tc_id /* TC ID */;
-	u8	wrr_group /* WRR group */;
-	u8	reserved;
-};
+/**
+ * @brief qed_dbg_print_attn - Prints attention registers values in the specified results struct.
+ *
+ * @param p_hwfn
+ * @param results - Pointer to the attention read results
+ *
+ * @return error if one of the following holds:
+ *	- the version wasn't set
+ * Otherwise, returns ok.
+ */
+enum dbg_status qed_dbg_print_attn(struct qed_hwfn *p_hwfn,
+				   struct dbg_attn_block_result *results);
 
-/* QM per-vport init parameters */
-struct init_qm_vport_params {
-	u32	vport_rl;
-	u16	vport_wfq;
-	u16	first_tx_pq_id[NUM_OF_TCS];
-};
+#define MAX_NAME_LEN	16
 
 /* Win 2 */
 #define GTT_BAR0_MAP_REG_IGU_CMD \
 	0x00f000UL
+
 /* Win 3 */
 #define GTT_BAR0_MAP_REG_TSDM_RAM \
 	0x010000UL
+
 /* Win 4 */
 #define GTT_BAR0_MAP_REG_MSDM_RAM \
 	0x011000UL
+
 /* Win 5 */
 #define GTT_BAR0_MAP_REG_MSDM_RAM_1024 \
 	0x012000UL
+
 /* Win 6 */
 #define GTT_BAR0_MAP_REG_USDM_RAM \
 	0x013000UL
+
 /* Win 7 */
 #define GTT_BAR0_MAP_REG_USDM_RAM_1024 \
 	0x014000UL
+
 /* Win 8 */
 #define GTT_BAR0_MAP_REG_USDM_RAM_2048 \
 	0x015000UL
+
 /* Win 9 */
 #define GTT_BAR0_MAP_REG_XSDM_RAM \
 	0x016000UL
+
 /* Win 10 */
 #define GTT_BAR0_MAP_REG_YSDM_RAM \
 	0x017000UL
+
 /* Win 11 */
 #define GTT_BAR0_MAP_REG_PSDM_RAM \
 	0x018000UL
@@ -1584,785 +1958,718 @@ struct init_qm_vport_params {
  * Returns the required host memory size in 4KB units.
  * Must be called before all QM init HSI functions.
  *
- * @param pf_id			- physical function ID
- * @param num_pf_cids	- number of connections used by this PF
- * @param num_vf_cids	- number of connections used by VFs of this PF
- * @param num_tids		- number of tasks used by this PF
- * @param num_pf_pqs	- number of PQs used by this PF
- * @param num_vf_pqs	- number of PQs used by VFs of this PF
+ * @param pf_id - physical function ID
+ * @param num_pf_cids - number of connections used by this PF
+ * @param num_vf_cids - number of connections used by VFs of this PF
+ * @param num_tids - number of tasks used by this PF
+ * @param num_pf_pqs - number of PQs used by this PF
+ * @param num_vf_pqs - number of PQs used by VFs of this PF
  *
  * @return The required host memory size in 4KB units.
  */
-u32 qed_qm_pf_mem_size(u8	pf_id,
-		       u32	num_pf_cids,
-		       u32	num_vf_cids,
-		       u32	num_tids,
-		       u16	num_pf_pqs,
-		       u16	num_vf_pqs);
+u32 qed_qm_pf_mem_size(u8 pf_id,
+		       u32 num_pf_cids,
+		       u32 num_vf_cids,
+		       u32 num_tids, u16 num_pf_pqs, u16 num_vf_pqs);
 
 struct qed_qm_common_rt_init_params {
-	u8				max_ports_per_engine;
-	u8				max_phys_tcs_per_port;
-	bool				pf_rl_en;
-	bool				pf_wfq_en;
-	bool				vport_rl_en;
-	bool				vport_wfq_en;
-	struct init_qm_port_params	*port_params;
+	u8 max_ports_per_engine;
+	u8 max_phys_tcs_per_port;
+	bool pf_rl_en;
+	bool pf_wfq_en;
+	bool vport_rl_en;
+	bool vport_wfq_en;
+	struct init_qm_port_params *port_params;
 };
 
+int qed_qm_common_rt_init(struct qed_hwfn *p_hwfn,
+			  struct qed_qm_common_rt_init_params *p_params);
+
+struct qed_qm_pf_rt_init_params {
+	u8 port_id;
+	u8 pf_id;
+	u8 max_phys_tcs_per_port;
+	bool is_first_pf;
+	u32 num_pf_cids;
+	u32 num_vf_cids;
+	u32 num_tids;
+	u16 start_pq;
+	u16 num_pf_pqs;
+	u16 num_vf_pqs;
+	u8 start_vport;
+	u8 num_vports;
+	u8 pf_wfq;
+	u32 pf_rl;
+	struct init_qm_pq_params *pq_params;
+	struct init_qm_vport_params *vport_params;
+};
+
+int qed_qm_pf_rt_init(struct qed_hwfn *p_hwfn,
+	struct qed_ptt *p_ptt,
+	struct qed_qm_pf_rt_init_params *p_params);
+
 /**
- * @brief qed_qm_common_rt_init - Prepare QM runtime init values for the
- * engine phase.
+ * @brief qed_init_pf_wfq - Initializes the WFQ weight of the specified PF
  *
  * @param p_hwfn
- * @param max_ports_per_engine	- max number of ports per engine in HW
- * @param max_phys_tcs_per_port	- max number of physical TCs per port in HW
- * @param pf_rl_en				- enable per-PF rate limiters
- * @param pf_wfq_en				- enable per-PF WFQ
- * @param vport_rl_en			- enable per-VPORT rate limiters
- * @param vport_wfq_en			- enable per-VPORT WFQ
- * @param port_params			- array of size MAX_NUM_PORTS with
- *						arameters for each port
+ * @param p_ptt - ptt window used for writing the registers
+ * @param pf_id - PF ID
+ * @param pf_wfq - WFQ weight. Must be non-zero.
  *
  * @return 0 on success, -1 on error.
  */
-int qed_qm_common_rt_init(
-	struct qed_hwfn				*p_hwfn,
-	struct qed_qm_common_rt_init_params	*p_params);
-
-struct qed_qm_pf_rt_init_params {
-	u8				port_id;
-	u8				pf_id;
-	u8				max_phys_tcs_per_port;
-	bool				is_first_pf;
-	u32				num_pf_cids;
-	u32				num_vf_cids;
-	u32				num_tids;
-	u16				start_pq;
-	u16				num_pf_pqs;
-	u16				num_vf_pqs;
-	u8				start_vport;
-	u8				num_vports;
-	u8				pf_wfq;
-	u32				pf_rl;
-	struct init_qm_pq_params	*pq_params;
-	struct init_qm_vport_params	*vport_params;
-};
-
-int qed_qm_pf_rt_init(struct qed_hwfn			*p_hwfn,
-		      struct qed_ptt			*p_ptt,
-		      struct qed_qm_pf_rt_init_params	*p_params);
+int qed_init_pf_wfq(struct qed_hwfn *p_hwfn,
+		    struct qed_ptt *p_ptt, u8 pf_id, u16 pf_wfq);
 
 /**
- * @brief qed_init_pf_rl  Initializes the rate limit of the specified PF
+ * @brief qed_init_pf_rl - Initializes the rate limit of the specified PF
  *
  * @param p_hwfn
- * @param p_ptt	- ptt window used for writing the registers
- * @param pf_id	- PF ID
- * @param pf_rl	- rate limit in Mb/sec units
+ * @param p_ptt - ptt window used for writing the registers
+ * @param pf_id - PF ID
+ * @param pf_rl - rate limit in Mb/sec units
  *
  * @return 0 on success, -1 on error.
  */
-int qed_init_pf_rl(struct qed_hwfn	*p_hwfn,
-		   struct qed_ptt	*p_ptt,
-		   u8			pf_id,
-		   u32			pf_rl);
+int qed_init_pf_rl(struct qed_hwfn *p_hwfn,
+		   struct qed_ptt *p_ptt, u8 pf_id, u32 pf_rl);
 
 /**
- * @brief qed_init_vport_rl  Initializes the rate limit of the specified VPORT
+ * @brief qed_init_vport_wfq Initializes the WFQ weight of the specified VPORT
  *
  * @param p_hwfn
- * @param p_ptt		- ptt window used for writing the registers
- * @param vport_id	- VPORT ID
- * @param vport_rl	- rate limit in Mb/sec units
+ * @param p_ptt - ptt window used for writing the registers
+ * @param first_tx_pq_id- An array containing the first Tx PQ ID associated
+ *	  with the VPORT for each TC. This array is filled by
+ *	  qed_qm_pf_rt_init
+ * @param vport_wfq - WFQ weight. Must be non-zero.
  *
  * @return 0 on success, -1 on error.
  */
+int qed_init_vport_wfq(struct qed_hwfn *p_hwfn,
+		       struct qed_ptt *p_ptt,
+		       u16 first_tx_pq_id[NUM_OF_TCS], u16 vport_wfq);
 
-int qed_init_vport_rl(struct qed_hwfn	*p_hwfn,
-		      struct qed_ptt	*p_ptt,
-		      u8		vport_id,
-		      u32		vport_rl);
+/**
+ * @brief qed_init_vport_rl - Initializes the rate limit of the specified VPORT
+ *
+ * @param p_hwfn
+ * @param p_ptt - ptt window used for writing the registers
+ * @param vport_id - VPORT ID
+ * @param vport_rl - rate limit in Mb/sec units
+ *
+ * @return 0 on success, -1 on error.
+ */
+int qed_init_vport_rl(struct qed_hwfn *p_hwfn,
+		      struct qed_ptt *p_ptt, u8 vport_id, u32 vport_rl);
 /**
  * @brief qed_send_qm_stop_cmd  Sends a stop command to the QM
  *
  * @param p_hwfn
- * @param p_ptt	         - ptt window used for writing the registers
+ * @param p_ptt
  * @param is_release_cmd - true for release, false for stop.
- * @param is_tx_pq       - true for Tx PQs, false for Other PQs.
- * @param start_pq       - first PQ ID to stop
- * @param num_pqs        - Number of PQs to stop, starting from start_pq.
+ * @param is_tx_pq - true for Tx PQs, false for Other PQs.
+ * @param start_pq - first PQ ID to stop
+ * @param num_pqs - Number of PQs to stop, starting from start_pq.
  *
- * @return bool, true if successful, false if timeout occurred while waiting
- *					for QM command done.
+ * @return bool, true if successful, false if timeout occured while waiting for QM command done.
  */
+bool qed_send_qm_stop_cmd(struct qed_hwfn *p_hwfn,
+			  struct qed_ptt *p_ptt,
+			  bool is_release_cmd,
+			  bool is_tx_pq, u16 start_pq, u16 num_pqs);
 
-bool qed_send_qm_stop_cmd(struct qed_hwfn	*p_hwfn,
-			  struct qed_ptt	*p_ptt,
-			  bool			is_release_cmd,
-			  bool			is_tx_pq,
-			  u16			start_pq,
-			  u16			num_pqs);
-
+/**
+ * @brief qed_set_vxlan_dest_port - initializes vxlan tunnel destination udp port
+ *
+ * @param p_ptt - ptt window used for writing the registers.
+ * @param dest_port - vxlan destination udp port.
+ */
 void qed_set_vxlan_dest_port(struct qed_hwfn *p_hwfn,
-			     struct qed_ptt  *p_ptt, u16 dest_port);
+			     struct qed_ptt *p_ptt, u16 dest_port);
+
+/**
+ * @brief qed_set_vxlan_enable - enable or disable VXLAN tunnel in HW
+ *
+ * @param p_ptt - ptt window used for writing the registers.
+ * @param vxlan_enable - vxlan enable flag.
+ */
 void qed_set_vxlan_enable(struct qed_hwfn *p_hwfn,
 			  struct qed_ptt *p_ptt, bool vxlan_enable);
+
+/**
+ * @brief qed_set_gre_enable - enable or disable GRE tunnel in HW
+ *
+ * @param p_ptt - ptt window used for writing the registers.
+ * @param eth_gre_enable - eth GRE enable enable flag.
+ * @param ip_gre_enable - IP GRE enable enable flag.
+ */
 void qed_set_gre_enable(struct qed_hwfn *p_hwfn,
-			struct qed_ptt  *p_ptt, bool eth_gre_enable,
-			bool ip_gre_enable);
+			struct qed_ptt *p_ptt,
+			bool eth_gre_enable, bool ip_gre_enable);
+
+/**
+ * @brief qed_set_geneve_dest_port - initializes geneve tunnel destination udp port
+ *
+ * @param p_ptt - ptt window used for writing the registers.
+ * @param dest_port - geneve destination udp port.
+ */
 void qed_set_geneve_dest_port(struct qed_hwfn *p_hwfn,
 			      struct qed_ptt *p_ptt, u16 dest_port);
+
+/**
+ * @brief qed_set_gre_enable - enable or disable GRE tunnel in HW
+ *
+ * @param p_ptt - ptt window used for writing the registers.
+ * @param eth_geneve_enable - eth GENEVE enable enable flag.
+ * @param ip_geneve_enable - IP GENEVE enable enable flag.
+ */
 void qed_set_geneve_enable(struct qed_hwfn *p_hwfn,
-			   struct qed_ptt *p_ptt, bool eth_geneve_enable,
-			   bool ip_geneve_enable);
-
-/* Ystorm flow control mode. Use enum fw_flow_ctrl_mode */
-#define YSTORM_FLOW_CONTROL_MODE_OFFSET  (IRO[0].base)
-#define YSTORM_FLOW_CONTROL_MODE_SIZE    (IRO[0].size)
-/* Tstorm port statistics */
-#define TSTORM_PORT_STAT_OFFSET(port_id) (IRO[1].base + ((port_id) * IRO[1].m1))
-#define TSTORM_PORT_STAT_SIZE            (IRO[1].size)
-/* Tstorm ll2 port statistics */
-#define TSTORM_LL2_PORT_STAT_OFFSET(port_id) \
-				(IRO[2].base + ((port_id) * IRO[2].m1))
-#define TSTORM_LL2_PORT_STAT_SIZE            (IRO[2].size)
-/* Ustorm VF-PF Channel ready flag */
-#define USTORM_VF_PF_CHANNEL_READY_OFFSET(vf_id) \
-				(IRO[3].base +	((vf_id) * IRO[3].m1))
-#define USTORM_VF_PF_CHANNEL_READY_SIZE          (IRO[3].size)
-/* Ustorm Final flr cleanup ack */
-#define USTORM_FLR_FINAL_ACK_OFFSET(pf_id) (IRO[4].base + ((pf_id) * IRO[4].m1))
-#define USTORM_FLR_FINAL_ACK_SIZE          (IRO[4].size)
-/* Ustorm Event ring consumer */
-#define USTORM_EQE_CONS_OFFSET(pf_id)    (IRO[5].base +	((pf_id) * IRO[5].m1))
-#define USTORM_EQE_CONS_SIZE             (IRO[5].size)
-/* Ustorm Common Queue ring consumer */
-#define USTORM_COMMON_QUEUE_CONS_OFFSET(global_queue_id) \
-			(IRO[6].base + ((global_queue_id) * IRO[6].m1))
-#define USTORM_COMMON_QUEUE_CONS_SIZE    (IRO[6].size)
-/* Xstorm Integration Test Data */
-#define XSTORM_INTEG_TEST_DATA_OFFSET    (IRO[7].base)
-#define XSTORM_INTEG_TEST_DATA_SIZE      (IRO[7].size)
-/* Ystorm Integration Test Data */
-#define YSTORM_INTEG_TEST_DATA_OFFSET    (IRO[8].base)
-#define YSTORM_INTEG_TEST_DATA_SIZE      (IRO[8].size)
-/* Pstorm Integration Test Data */
-#define PSTORM_INTEG_TEST_DATA_OFFSET    (IRO[9].base)
-#define PSTORM_INTEG_TEST_DATA_SIZE      (IRO[9].size)
-/* Tstorm Integration Test Data */
-#define TSTORM_INTEG_TEST_DATA_OFFSET    (IRO[10].base)
-#define TSTORM_INTEG_TEST_DATA_SIZE      (IRO[10].size)
-/* Mstorm Integration Test Data */
-#define MSTORM_INTEG_TEST_DATA_OFFSET    (IRO[11].base)
-#define MSTORM_INTEG_TEST_DATA_SIZE      (IRO[11].size)
-/* Ustorm Integration Test Data */
-#define USTORM_INTEG_TEST_DATA_OFFSET    (IRO[12].base)
-#define USTORM_INTEG_TEST_DATA_SIZE      (IRO[12].size)
-/* Tstorm producers */
-#define TSTORM_LL2_RX_PRODS_OFFSET(core_rx_queue_id) \
-			(IRO[13].base + ((core_rx_queue_id) * IRO[13].m1))
-#define TSTORM_LL2_RX_PRODS_SIZE         (IRO[13].size)
-/* Tstorm LightL2 queue statistics */
-#define CORE_LL2_TSTORM_PER_QUEUE_STAT_OFFSET(core_rx_queue_id) \
-			(IRO[14].base + ((core_rx_queue_id) * IRO[14].m1))
-#define CORE_LL2_TSTORM_PER_QUEUE_STAT_SIZE    (IRO[14].size)
-/* Ustorm LiteL2 queue statistics */
-#define CORE_LL2_USTORM_PER_QUEUE_STAT_OFFSET(core_rx_queue_id) \
-			(IRO[15].base +	((core_rx_queue_id) * IRO[15].m1))
-#define CORE_LL2_USTORM_PER_QUEUE_STAT_SIZE    (IRO[15].size)
-/* Pstorm LiteL2 queue statistics */
-#define CORE_LL2_PSTORM_PER_QUEUE_STAT_OFFSET(core_tx_stats_id) \
-			(IRO[16].base +	((core_tx_stats_id) * IRO[16].m1))
-#define CORE_LL2_PSTORM_PER_QUEUE_STAT_SIZE    (IRO[16].size)
-/* Mstorm queue statistics */
-#define MSTORM_QUEUE_STAT_OFFSET(stat_counter_id) \
-			(IRO[17].base + ((stat_counter_id) * IRO[17].m1))
-#define MSTORM_QUEUE_STAT_SIZE                 (IRO[17].size)
-/* Mstorm producers */
-#define MSTORM_PRODS_OFFSET(queue_id) (IRO[18].base + ((queue_id) * IRO[18].m1))
-#define MSTORM_PRODS_SIZE             (IRO[18].size)
-/* TPA agregation timeout in us resolution (on ASIC) */
-#define MSTORM_TPA_TIMEOUT_US_OFFSET  (IRO[19].base)
-#define MSTORM_TPA_TIMEOUT_US_SIZE    (IRO[19].size)
-/* Ustorm queue statistics */
-#define USTORM_QUEUE_STAT_OFFSET(stat_counter_id) \
-			(IRO[20].base + ((stat_counter_id) * IRO[20].m1))
-#define USTORM_QUEUE_STAT_SIZE        (IRO[20].size)
-/* Ustorm queue zone */
-#define USTORM_ETH_QUEUE_ZONE_OFFSET(queue_id) \
-			(IRO[21].base +	((queue_id) * IRO[21].m1))
-#define USTORM_ETH_QUEUE_ZONE_SIZE    (IRO[21].size)
-/* Pstorm queue statistics */
-#define PSTORM_QUEUE_STAT_OFFSET(stat_counter_id) \
-		(IRO[22].base + ((stat_counter_id) * IRO[22].m1))
-#define PSTORM_QUEUE_STAT_SIZE        (IRO[22].size)
-/* Tstorm last parser message */
-#define TSTORM_ETH_PRS_INPUT_OFFSET  (IRO[23].base)
-#define TSTORM_ETH_PRS_INPUT_SIZE    (IRO[23].size)
-/* Tstorm Eth limit Rx rate */
-#define ETH_RX_RATE_LIMIT_OFFSET(pf_id) (IRO[24].base +	((pf_id) * IRO[24].m1))
-#define ETH_RX_RATE_LIMIT_SIZE       (IRO[24].size)
-/* Ystorm queue zone */
-#define YSTORM_ETH_QUEUE_ZONE_OFFSET(queue_id) \
-			(IRO[25].base +	((queue_id) * IRO[25].m1))
-#define YSTORM_ETH_QUEUE_ZONE_SIZE   (IRO[25].size)
-/* Ystorm cqe producer */
-#define YSTORM_TOE_CQ_PROD_OFFSET(rss_id) \
-			(IRO[26].base + ((rss_id) * IRO[26].m1))
-#define YSTORM_TOE_CQ_PROD_SIZE      (IRO[26].size)
-/* Ustorm cqe producer */
-#define USTORM_TOE_CQ_PROD_OFFSET(rss_id) \
-			(IRO[27].base + ((rss_id) * IRO[27].m1))
-#define USTORM_TOE_CQ_PROD_SIZE      (IRO[27].size)
-/* Ustorm grq producer */
-#define USTORM_TOE_GRQ_PROD_OFFSET(pf_id) \
-			(IRO[28].base + ((pf_id) * IRO[28].m1))
-#define USTORM_TOE_GRQ_PROD_SIZE     (IRO[28].size)
-/* Tstorm cmdq-cons of given command queue-id */
-#define TSTORM_SCSI_CMDQ_CONS_OFFSET(cmdq_queue_id) \
-			(IRO[29].base + ((cmdq_queue_id) * IRO[29].m1))
-#define TSTORM_SCSI_CMDQ_CONS_SIZE   (IRO[29].size)
-/* Mstorm rq-cons of given queue-id */
-#define MSTORM_SCSI_RQ_CONS_OFFSET(rq_queue_id) \
-		(IRO[30].base + ((rq_queue_id) * IRO[30].m1))
-#define MSTORM_SCSI_RQ_CONS_SIZE     (IRO[30].size)
-/* Mstorm bdq-external-producer of given BDQ function ID, BDqueue-id */
-#define MSTORM_SCSI_BDQ_EXT_PROD_OFFSET(func_id, bdq_id) \
-	(IRO[31].base + ((func_id) * IRO[31].m1) + ((bdq_id) * IRO[31].m2))
-#define MSTORM_SCSI_BDQ_EXT_PROD_SIZE (IRO[31].size)
-/* Tstorm (reflects M-Storm) bdq-external-producer of given fn ID, BDqueue-id */
-#define TSTORM_SCSI_BDQ_EXT_PROD_OFFSET(func_id, bdq_id) \
-	(IRO[32].base + ((func_id) * IRO[32].m1) + ((bdq_id) * IRO[32].m2))
-#define TSTORM_SCSI_BDQ_EXT_PROD_SIZE (IRO[32].size)
-/* Tstorm iSCSI RX stats */
-#define TSTORM_ISCSI_RX_STATS_OFFSET(pf_id) \
-				(IRO[33].base + ((pf_id) * IRO[33].m1))
-#define TSTORM_ISCSI_RX_STATS_SIZE    (IRO[33].size)
-/* Mstorm iSCSI RX stats */
-#define MSTORM_ISCSI_RX_STATS_OFFSET(pf_id) \
-				(IRO[34].base + ((pf_id) * IRO[34].m1))
-#define MSTORM_ISCSI_RX_STATS_SIZE    (IRO[34].size)
-/* Ustorm iSCSI RX stats */
-#define USTORM_ISCSI_RX_STATS_OFFSET(pf_id) \
-				(IRO[35].base +	((pf_id) * IRO[35].m1))
-#define USTORM_ISCSI_RX_STATS_SIZE    (IRO[35].size)
-/* Xstorm iSCSI TX stats */
-#define XSTORM_ISCSI_TX_STATS_OFFSET(pf_id) \
-				(IRO[36].base +	((pf_id) * IRO[36].m1))
-#define XSTORM_ISCSI_TX_STATS_SIZE    (IRO[36].size)
-/* Ystorm iSCSI TX stats */
-#define YSTORM_ISCSI_TX_STATS_OFFSET(pf_id) \
-				(IRO[37].base +	((pf_id) * IRO[37].m1))
-#define YSTORM_ISCSI_TX_STATS_SIZE    (IRO[37].size)
-/* Pstorm iSCSI TX stats */
-#define PSTORM_ISCSI_TX_STATS_OFFSET(pf_id) \
-				(IRO[38].base +	((pf_id) * IRO[38].m1))
-#define PSTORM_ISCSI_TX_STATS_SIZE    (IRO[38].size)
-/* Tstorm FCoE RX stats */
-#define TSTORM_FCOE_RX_STATS_OFFSET(pf_id) \
-				(IRO[39].base +	((pf_id) * IRO[39].m1))
-#define TSTORM_FCOE_RX_STATS_SIZE      (IRO[39].size)
-/* Mstorm FCoE RX stats */
-#define MSTORM_FCOE_RX_STATS_OFFSET(pf_id) \
-				(IRO[40].base +	((pf_id) * IRO[40].m1))
-#define MSTORM_FCOE_RX_STATS_SIZE      (IRO[40].size)
-/* Pstorm FCoE TX stats */
-#define PSTORM_FCOE_TX_STATS_OFFSET(pf_id) \
-				(IRO[41].base +	((pf_id) * IRO[41].m1))
-#define PSTORM_FCOE_TX_STATS_SIZE      (IRO[41].size)
-/* Pstorm RoCE statistics */
-#define PSTORM_ROCE_STAT_OFFSET(stat_counter_id) \
-			(IRO[42].base + ((stat_counter_id) * IRO[42].m1))
-#define PSTORM_ROCE_STAT_SIZE          (IRO[42].size)
-/* Tstorm RoCE statistics */
-#define TSTORM_ROCE_STAT_OFFSET(stat_counter_id) \
-			(IRO[43].base + ((stat_counter_id) * IRO[43].m1))
-#define TSTORM_ROCE_STAT_SIZE          (IRO[43].size)
-
-static const struct iro iro_arr[44] = {
-	{ 0x10,	   0x0,	   0x0,	   0x0,	   0x8	    },
-	{ 0x47c8,  0x60,   0x0,	   0x0,	   0x60	    },
-	{ 0x5e30,  0x20,   0x0,	   0x0,	   0x20	    },
-	{ 0x510,   0x8,	   0x0,	   0x0,	   0x4	    },
-	{ 0x490,   0x8,	   0x0,	   0x0,	   0x4	    },
-	{ 0x10,	   0x8,	   0x0,	   0x0,	   0x2	    },
-	{ 0x90,	   0x8,	   0x0,	   0x0,	   0x2	    },
-	{ 0x4940,  0x0,	   0x0,	   0x0,	   0x78	    },
-	{ 0x3de0,  0x0,	   0x0,	   0x0,	   0x78	    },
-	{ 0x2998,  0x0,	   0x0,	   0x0,	   0x78	    },
-	{ 0x4750,  0x0,	   0x0,	   0x0,	   0x78	    },
-	{ 0x56d0,  0x0,	   0x0,	   0x0,	   0x78	    },
-	{ 0x7e50,  0x0,	   0x0,	   0x0,	   0x78	    },
-	{ 0x100,   0x8,	   0x0,	   0x0,	   0x8	    },
-	{ 0x5c10,  0x10,   0x0,	   0x0,	   0x10	    },
-	{ 0xb508,  0x30,   0x0,	   0x0,	   0x30	    },
-	{ 0x95c0,  0x30,   0x0,	   0x0,	   0x30	    },
-	{ 0x58a0,  0x40,   0x0,	   0x0,	   0x40	    },
-	{ 0x200,   0x10,   0x0,	   0x0,	   0x8	    },
-	{ 0xa230,  0x0,	   0x0,	   0x0,	   0x4	    },
-	{ 0x8058,  0x40,   0x0,	   0x0,	   0x30	    },
-	{ 0xd00,   0x8,	   0x0,	   0x0,	   0x8	    },
-	{ 0x2b30,  0x80,   0x0,	   0x0,	   0x38	    },
-	{ 0xa808,  0x0,	   0x0,	   0x0,	   0xf0	    },
-	{ 0xa8f8,  0x8,	   0x0,	   0x0,	   0x8	    },
-	{ 0x80,	   0x8,	   0x0,	   0x0,	   0x8	    },
-	{ 0xac0,   0x8,	   0x0,	   0x0,	   0x8	    },
-	{ 0x2580,  0x8,	   0x0,	   0x0,	   0x8	    },
-	{ 0x2500,  0x8,	   0x0,	   0x0,	   0x8	    },
-	{ 0x440,   0x8,	   0x0,	   0x0,	   0x2	    },
-	{ 0x1800,  0x8,	   0x0,	   0x0,	   0x2	    },
-	{ 0x1a00,  0x10,   0x8,	   0x0,	   0x2	    },
-	{ 0x640,   0x10,   0x8,	   0x0,	   0x2	    },
-	{ 0xd9b8,  0x38,   0x0,	   0x0,	   0x24	    },
-	{ 0x11048, 0x10,   0x0,	   0x0,	   0x8	    },
-	{ 0x11678, 0x38,   0x0,	   0x0,	   0x18	    },
-	{ 0xaec0,  0x30,   0x0,	   0x0,	   0x10	    },
-	{ 0x8700,  0x28,   0x0,	   0x0,	   0x18	    },
-	{ 0xec00,  0x10,   0x0,	   0x0,	   0x10	    },
-	{ 0xde38,  0x40,   0x0,	   0x0,	   0x30	    },
-	{ 0x121a8, 0x38,   0x0,	   0x0,	   0x8	    },
-	{ 0xf068,  0x20,   0x0,	   0x0,	   0x20	    },
-	{ 0x2b68,  0x80,   0x0,	   0x0,	   0x10	    },
-	{ 0x4ab8,  0x10,   0x0,	   0x0,	   0x10	    },
+			   struct qed_ptt *p_ptt,
+			   bool eth_geneve_enable, bool ip_geneve_enable);
+
+#define	YSTORM_FLOW_CONTROL_MODE_OFFSET			(IRO[0].base)
+#define	YSTORM_FLOW_CONTROL_MODE_SIZE			(IRO[0].size)
+#define	TSTORM_PORT_STAT_OFFSET(port_id) \
+	(IRO[1].base + ((port_id) * IRO[1].m1))
+#define	TSTORM_PORT_STAT_SIZE				(IRO[1].size)
+#define	USTORM_VF_PF_CHANNEL_READY_OFFSET(vf_id) \
+	(IRO[3].base + ((vf_id) * IRO[3].m1))
+#define	USTORM_VF_PF_CHANNEL_READY_SIZE			(IRO[3].size)
+#define	USTORM_FLR_FINAL_ACK_OFFSET(pf_id) \
+	(IRO[4].base + (pf_id) * IRO[4].m1)
+#define	USTORM_FLR_FINAL_ACK_SIZE			(IRO[4].size)
+#define	USTORM_EQE_CONS_OFFSET(pf_id) \
+	(IRO[5].base + ((pf_id) * IRO[5].m1))
+#define	USTORM_EQE_CONS_SIZE				(IRO[5].size)
+#define	USTORM_ETH_QUEUE_ZONE_OFFSET(queue_zone_id) \
+	(IRO[6].base + ((queue_zone_id) * IRO[6].m1))
+#define	USTORM_ETH_QUEUE_ZONE_SIZE			(IRO[6].size)
+#define	USTORM_COMMON_QUEUE_CONS_OFFSET(queue_zone_id) \
+	(IRO[7].base + ((queue_zone_id) * IRO[7].m1))
+#define	USTORM_COMMON_QUEUE_CONS_SIZE			(IRO[7].size)
+#define	MSTORM_QUEUE_STAT_OFFSET(stat_counter_id) \
+	(IRO[18].base + ((stat_counter_id) * IRO[18].m1))
+#define	MSTORM_QUEUE_STAT_SIZE				(IRO[18].size)
+#define	MSTORM_ETH_PF_PRODS_OFFSET(queue_id) \
+	(IRO[19].base + ((queue_id) * IRO[19].m1))
+#define	MSTORM_ETH_PF_PRODS_SIZE			(IRO[19].size)
+#define	MSTORM_TPA_TIMEOUT_US_OFFSET			(IRO[20].base)
+#define	MSTORM_TPA_TIMEOUT_US_SIZE			(IRO[20].size)
+#define	MSTORM_ETH_PF_STAT_OFFSET(pf_id) \
+	(IRO[21].base + ((pf_id) * IRO[21].m1))
+#define	MSTORM_ETH_PF_STAT_SIZE				(IRO[21].size)
+#define	USTORM_QUEUE_STAT_OFFSET(stat_counter_id) \
+	(IRO[22].base + ((stat_counter_id) * IRO[22].m1))
+#define	USTORM_QUEUE_STAT_SIZE				(IRO[22].size)
+#define	USTORM_ETH_PF_STAT_OFFSET(pf_id) \
+	(IRO[23].base + ((pf_id) * IRO[23].m1))
+#define	USTORM_ETH_PF_STAT_SIZE				(IRO[23].size)
+#define	PSTORM_QUEUE_STAT_OFFSET(stat_counter_id) \
+	(IRO[24].base + ((stat_counter_id) * IRO[24].m1))
+#define	PSTORM_QUEUE_STAT_SIZE				(IRO[24].size)
+#define	PSTORM_ETH_PF_STAT_OFFSET(pf_id) \
+	(IRO[25].base + ((pf_id) * IRO[25].m1))
+#define	PSTORM_ETH_PF_STAT_SIZE				(IRO[25].size)
+#define	PSTORM_CTL_FRAME_ETHTYPE_OFFSET(ethtype) \
+	(IRO[26].base + ((ethtype) * IRO[26].m1))
+#define	PSTORM_CTL_FRAME_ETHTYPE_SIZE			(IRO[26].size)
+#define	TSTORM_ETH_PRS_INPUT_OFFSET			(IRO[27].base)
+#define	TSTORM_ETH_PRS_INPUT_SIZE			(IRO[27].size)
+#define	ETH_RX_RATE_LIMIT_OFFSET(pf_id) \
+	(IRO[28].base + ((pf_id) * IRO[28].m1))
+#define	ETH_RX_RATE_LIMIT_SIZE				(IRO[28].size)
+#define	XSTORM_ETH_QUEUE_ZONE_OFFSET(queue_id) \
+	(IRO[29].base + ((queue_id) * IRO[29].m1))
+#define	XSTORM_ETH_QUEUE_ZONE_SIZE			(IRO[29].size)
+
+static const struct iro iro_arr[46] = {
+	{0x0, 0x0, 0x0, 0x0, 0x8},
+	{0x4cb0, 0x78, 0x0, 0x0, 0x78},
+	{0x6318, 0x20, 0x0, 0x0, 0x20},
+	{0xb00, 0x8, 0x0, 0x0, 0x4},
+	{0xa80, 0x8, 0x0, 0x0, 0x4},
+	{0x0, 0x8, 0x0, 0x0, 0x2},
+	{0x80, 0x8, 0x0, 0x0, 0x4},
+	{0x84, 0x8, 0x0, 0x0, 0x2},
+	{0x4bc0, 0x0, 0x0, 0x0, 0x78},
+	{0x3df0, 0x0, 0x0, 0x0, 0x78},
+	{0x29b0, 0x0, 0x0, 0x0, 0x78},
+	{0x4c38, 0x0, 0x0, 0x0, 0x78},
+	{0x4a48, 0x0, 0x0, 0x0, 0x78},
+	{0x7e48, 0x0, 0x0, 0x0, 0x78},
+	{0xa28, 0x8, 0x0, 0x0, 0x8},
+	{0x60f8, 0x10, 0x0, 0x0, 0x10},
+	{0xb820, 0x30, 0x0, 0x0, 0x30},
+	{0x95b8, 0x30, 0x0, 0x0, 0x30},
+	{0x4c18, 0x80, 0x0, 0x0, 0x40},
+	{0x1f8, 0x4, 0x0, 0x0, 0x4},
+	{0xc9a8, 0x0, 0x0, 0x0, 0x4},
+	{0x4c58, 0x80, 0x0, 0x0, 0x20},
+	{0x8050, 0x40, 0x0, 0x0, 0x30},
+	{0xe770, 0x60, 0x0, 0x0, 0x60},
+	{0x2b48, 0x80, 0x0, 0x0, 0x38},
+	{0xdf88, 0x78, 0x0, 0x0, 0x78},
+	{0x1f8, 0x4, 0x0, 0x0, 0x4},
+	{0xacf0, 0x0, 0x0, 0x0, 0xf0},
+	{0xade0, 0x8, 0x0, 0x0, 0x8},
+	{0x1f8, 0x8, 0x0, 0x0, 0x8},
+	{0xac0, 0x8, 0x0, 0x0, 0x8},
+	{0x2578, 0x8, 0x0, 0x0, 0x8},
+	{0x24f8, 0x8, 0x0, 0x0, 0x8},
+	{0x0, 0x8, 0x0, 0x0, 0x8},
+	{0x200, 0x10, 0x8, 0x0, 0x8},
+	{0xb78, 0x10, 0x8, 0x0, 0x2},
+	{0xd888, 0x38, 0x0, 0x0, 0x24},
+	{0x12120, 0x10, 0x0, 0x0, 0x8},
+	{0x11b20, 0x38, 0x0, 0x0, 0x18},
+	{0xa8c0, 0x30, 0x0, 0x0, 0x10},
+	{0x86f8, 0x28, 0x0, 0x0, 0x18},
+	{0xeff8, 0x10, 0x0, 0x0, 0x10},
+	{0xdd08, 0x48, 0x0, 0x0, 0x38},
+	{0xf460, 0x20, 0x0, 0x0, 0x20},
+	{0x2b80, 0x80, 0x0, 0x0, 0x10},
+	{0x5000, 0x10, 0x0, 0x0, 0x10},
 };
 
 /* Runtime array offsets */
-#define DORQ_REG_PF_MAX_ICID_0_RT_OFFSET                                0
-#define DORQ_REG_PF_MAX_ICID_1_RT_OFFSET                                1
-#define DORQ_REG_PF_MAX_ICID_2_RT_OFFSET                                2
-#define DORQ_REG_PF_MAX_ICID_3_RT_OFFSET                                3
-#define DORQ_REG_PF_MAX_ICID_4_RT_OFFSET                                4
-#define DORQ_REG_PF_MAX_ICID_5_RT_OFFSET                                5
-#define DORQ_REG_PF_MAX_ICID_6_RT_OFFSET                                6
-#define DORQ_REG_PF_MAX_ICID_7_RT_OFFSET                                7
-#define DORQ_REG_VF_MAX_ICID_0_RT_OFFSET                                8
-#define DORQ_REG_VF_MAX_ICID_1_RT_OFFSET                                9
-#define DORQ_REG_VF_MAX_ICID_2_RT_OFFSET                                10
-#define DORQ_REG_VF_MAX_ICID_3_RT_OFFSET                                11
-#define DORQ_REG_VF_MAX_ICID_4_RT_OFFSET                                12
-#define DORQ_REG_VF_MAX_ICID_5_RT_OFFSET                                13
-#define DORQ_REG_VF_MAX_ICID_6_RT_OFFSET                                14
-#define DORQ_REG_VF_MAX_ICID_7_RT_OFFSET                                15
-#define DORQ_REG_PF_WAKE_ALL_RT_OFFSET                                  16
-#define DORQ_REG_TAG1_ETHERTYPE_RT_OFFSET                               17
-#define IGU_REG_PF_CONFIGURATION_RT_OFFSET                              18
-#define IGU_REG_VF_CONFIGURATION_RT_OFFSET                              19
-#define IGU_REG_ATTN_MSG_ADDR_L_RT_OFFSET                               20
-#define IGU_REG_ATTN_MSG_ADDR_H_RT_OFFSET                               21
-#define IGU_REG_LEADING_EDGE_LATCH_RT_OFFSET                            22
-#define IGU_REG_TRAILING_EDGE_LATCH_RT_OFFSET                           23
-#define CAU_REG_CQE_AGG_UNIT_SIZE_RT_OFFSET                             24
-#define CAU_REG_SB_VAR_MEMORY_RT_OFFSET                                 761
-#define CAU_REG_SB_VAR_MEMORY_RT_SIZE                                   736
-#define CAU_REG_SB_VAR_MEMORY_RT_OFFSET                                 761
-#define CAU_REG_SB_VAR_MEMORY_RT_SIZE                                   736
-#define CAU_REG_SB_ADDR_MEMORY_RT_OFFSET                                1497
-#define CAU_REG_SB_ADDR_MEMORY_RT_SIZE                                  736
-#define CAU_REG_PI_MEMORY_RT_OFFSET                                     2233
-#define CAU_REG_PI_MEMORY_RT_SIZE                                       4416
-#define PRS_REG_SEARCH_RESP_INITIATOR_TYPE_RT_OFFSET                    6649
-#define PRS_REG_TASK_ID_MAX_INITIATOR_PF_RT_OFFSET                      6650
-#define PRS_REG_TASK_ID_MAX_INITIATOR_VF_RT_OFFSET                      6651
-#define PRS_REG_TASK_ID_MAX_TARGET_PF_RT_OFFSET                         6652
-#define PRS_REG_TASK_ID_MAX_TARGET_VF_RT_OFFSET                         6653
-#define PRS_REG_SEARCH_TCP_RT_OFFSET                                    6654
-#define PRS_REG_SEARCH_FCOE_RT_OFFSET                                   6655
-#define PRS_REG_SEARCH_ROCE_RT_OFFSET                                   6656
-#define PRS_REG_ROCE_DEST_QP_MAX_VF_RT_OFFSET                           6657
-#define PRS_REG_ROCE_DEST_QP_MAX_PF_RT_OFFSET                           6658
-#define PRS_REG_SEARCH_OPENFLOW_RT_OFFSET                               6659
-#define PRS_REG_SEARCH_NON_IP_AS_OPENFLOW_RT_OFFSET                     6660
-#define PRS_REG_OPENFLOW_SUPPORT_ONLY_KNOWN_OVER_IP_RT_OFFSET           6661
-#define PRS_REG_OPENFLOW_SEARCH_KEY_MASK_RT_OFFSET                      6662
-#define PRS_REG_TAG_ETHERTYPE_0_RT_OFFSET                               6663
-#define PRS_REG_LIGHT_L2_ETHERTYPE_EN_RT_OFFSET                         6664
-#define SRC_REG_FIRSTFREE_RT_OFFSET                                     6665
-#define SRC_REG_FIRSTFREE_RT_SIZE                                       2
-#define SRC_REG_LASTFREE_RT_OFFSET                                      6667
-#define SRC_REG_LASTFREE_RT_SIZE                                        2
-#define SRC_REG_COUNTFREE_RT_OFFSET                                     6669
-#define SRC_REG_NUMBER_HASH_BITS_RT_OFFSET                              6670
-#define PSWRQ2_REG_CDUT_P_SIZE_RT_OFFSET                                6671
-#define PSWRQ2_REG_CDUC_P_SIZE_RT_OFFSET                                6672
-#define PSWRQ2_REG_TM_P_SIZE_RT_OFFSET                                  6673
-#define PSWRQ2_REG_QM_P_SIZE_RT_OFFSET                                  6674
-#define PSWRQ2_REG_SRC_P_SIZE_RT_OFFSET                                 6675
-#define PSWRQ2_REG_TM_FIRST_ILT_RT_OFFSET                               6676
-#define PSWRQ2_REG_TM_LAST_ILT_RT_OFFSET                                6677
-#define PSWRQ2_REG_QM_FIRST_ILT_RT_OFFSET                               6678
-#define PSWRQ2_REG_QM_LAST_ILT_RT_OFFSET                                6679
-#define PSWRQ2_REG_SRC_FIRST_ILT_RT_OFFSET                              6680
-#define PSWRQ2_REG_SRC_LAST_ILT_RT_OFFSET                               6681
-#define PSWRQ2_REG_CDUC_FIRST_ILT_RT_OFFSET                             6682
-#define PSWRQ2_REG_CDUC_LAST_ILT_RT_OFFSET                              6683
-#define PSWRQ2_REG_CDUT_FIRST_ILT_RT_OFFSET                             6684
-#define PSWRQ2_REG_CDUT_LAST_ILT_RT_OFFSET                              6685
-#define PSWRQ2_REG_TSDM_FIRST_ILT_RT_OFFSET                             6686
-#define PSWRQ2_REG_TSDM_LAST_ILT_RT_OFFSET                              6687
-#define PSWRQ2_REG_TM_NUMBER_OF_PF_BLOCKS_RT_OFFSET                     6688
-#define PSWRQ2_REG_CDUT_NUMBER_OF_PF_BLOCKS_RT_OFFSET                   6689
-#define PSWRQ2_REG_CDUC_NUMBER_OF_PF_BLOCKS_RT_OFFSET                   6690
-#define PSWRQ2_REG_TM_VF_BLOCKS_RT_OFFSET                               6691
-#define PSWRQ2_REG_CDUT_VF_BLOCKS_RT_OFFSET                             6692
-#define PSWRQ2_REG_CDUC_VF_BLOCKS_RT_OFFSET                             6693
-#define PSWRQ2_REG_TM_BLOCKS_FACTOR_RT_OFFSET                           6694
-#define PSWRQ2_REG_CDUT_BLOCKS_FACTOR_RT_OFFSET                         6695
-#define PSWRQ2_REG_CDUC_BLOCKS_FACTOR_RT_OFFSET                         6696
-#define PSWRQ2_REG_VF_BASE_RT_OFFSET                                    6697
-#define PSWRQ2_REG_VF_LAST_ILT_RT_OFFSET                                6698
-#define PSWRQ2_REG_WR_MBS0_RT_OFFSET                                    6699
-#define PSWRQ2_REG_RD_MBS0_RT_OFFSET                                    6700
-#define PSWRQ2_REG_DRAM_ALIGN_WR_RT_OFFSET                              6701
-#define PSWRQ2_REG_DRAM_ALIGN_RD_RT_OFFSET                              6702
-#define PSWRQ2_REG_ILT_MEMORY_RT_OFFSET                                 6703
-#define PSWRQ2_REG_ILT_MEMORY_RT_SIZE                                   22000
-#define PGLUE_REG_B_VF_BASE_RT_OFFSET                                   28703
-#define PGLUE_REG_B_CACHE_LINE_SIZE_RT_OFFSET                           28704
-#define PGLUE_REG_B_PF_BAR0_SIZE_RT_OFFSET                              28705
-#define PGLUE_REG_B_PF_BAR1_SIZE_RT_OFFSET                              28706
-#define PGLUE_REG_B_VF_BAR1_SIZE_RT_OFFSET                              28707
-#define TM_REG_VF_ENABLE_CONN_RT_OFFSET                                 28708
-#define TM_REG_PF_ENABLE_CONN_RT_OFFSET                                 28709
-#define TM_REG_PF_ENABLE_TASK_RT_OFFSET                                 28710
-#define TM_REG_GROUP_SIZE_RESOLUTION_CONN_RT_OFFSET                     28711
-#define TM_REG_GROUP_SIZE_RESOLUTION_TASK_RT_OFFSET                     28712
-#define TM_REG_CONFIG_CONN_MEM_RT_OFFSET                                28713
-#define TM_REG_CONFIG_CONN_MEM_RT_SIZE                                  416
-#define TM_REG_CONFIG_TASK_MEM_RT_OFFSET                                29129
-#define TM_REG_CONFIG_TASK_MEM_RT_SIZE                                  512
-#define QM_REG_MAXPQSIZE_0_RT_OFFSET                                    29641
-#define QM_REG_MAXPQSIZE_1_RT_OFFSET                                    29642
-#define QM_REG_MAXPQSIZE_2_RT_OFFSET                                    29643
-#define QM_REG_MAXPQSIZETXSEL_0_RT_OFFSET                               29644
-#define QM_REG_MAXPQSIZETXSEL_1_RT_OFFSET                               29645
-#define QM_REG_MAXPQSIZETXSEL_2_RT_OFFSET                               29646
-#define QM_REG_MAXPQSIZETXSEL_3_RT_OFFSET                               29647
-#define QM_REG_MAXPQSIZETXSEL_4_RT_OFFSET                               29648
-#define QM_REG_MAXPQSIZETXSEL_5_RT_OFFSET                               29649
-#define QM_REG_MAXPQSIZETXSEL_6_RT_OFFSET                               29650
-#define QM_REG_MAXPQSIZETXSEL_7_RT_OFFSET                               29651
-#define QM_REG_MAXPQSIZETXSEL_8_RT_OFFSET                               29652
-#define QM_REG_MAXPQSIZETXSEL_9_RT_OFFSET                               29653
-#define QM_REG_MAXPQSIZETXSEL_10_RT_OFFSET                              29654
-#define QM_REG_MAXPQSIZETXSEL_11_RT_OFFSET                              29655
-#define QM_REG_MAXPQSIZETXSEL_12_RT_OFFSET                              29656
-#define QM_REG_MAXPQSIZETXSEL_13_RT_OFFSET                              29657
-#define QM_REG_MAXPQSIZETXSEL_14_RT_OFFSET                              29658
-#define QM_REG_MAXPQSIZETXSEL_15_RT_OFFSET                              29659
-#define QM_REG_MAXPQSIZETXSEL_16_RT_OFFSET                              29660
-#define QM_REG_MAXPQSIZETXSEL_17_RT_OFFSET                              29661
-#define QM_REG_MAXPQSIZETXSEL_18_RT_OFFSET                              29662
-#define QM_REG_MAXPQSIZETXSEL_19_RT_OFFSET                              29663
-#define QM_REG_MAXPQSIZETXSEL_20_RT_OFFSET                              29664
-#define QM_REG_MAXPQSIZETXSEL_21_RT_OFFSET                              29665
-#define QM_REG_MAXPQSIZETXSEL_22_RT_OFFSET                              29666
-#define QM_REG_MAXPQSIZETXSEL_23_RT_OFFSET                              29667
-#define QM_REG_MAXPQSIZETXSEL_24_RT_OFFSET                              29668
-#define QM_REG_MAXPQSIZETXSEL_25_RT_OFFSET                              29669
-#define QM_REG_MAXPQSIZETXSEL_26_RT_OFFSET                              29670
-#define QM_REG_MAXPQSIZETXSEL_27_RT_OFFSET                              29671
-#define QM_REG_MAXPQSIZETXSEL_28_RT_OFFSET                              29672
-#define QM_REG_MAXPQSIZETXSEL_29_RT_OFFSET                              29673
-#define QM_REG_MAXPQSIZETXSEL_30_RT_OFFSET                              29674
-#define QM_REG_MAXPQSIZETXSEL_31_RT_OFFSET                              29675
-#define QM_REG_MAXPQSIZETXSEL_32_RT_OFFSET                              29676
-#define QM_REG_MAXPQSIZETXSEL_33_RT_OFFSET                              29677
-#define QM_REG_MAXPQSIZETXSEL_34_RT_OFFSET                              29678
-#define QM_REG_MAXPQSIZETXSEL_35_RT_OFFSET                              29679
-#define QM_REG_MAXPQSIZETXSEL_36_RT_OFFSET                              29680
-#define QM_REG_MAXPQSIZETXSEL_37_RT_OFFSET                              29681
-#define QM_REG_MAXPQSIZETXSEL_38_RT_OFFSET                              29682
-#define QM_REG_MAXPQSIZETXSEL_39_RT_OFFSET                              29683
-#define QM_REG_MAXPQSIZETXSEL_40_RT_OFFSET                              29684
-#define QM_REG_MAXPQSIZETXSEL_41_RT_OFFSET                              29685
-#define QM_REG_MAXPQSIZETXSEL_42_RT_OFFSET                              29686
-#define QM_REG_MAXPQSIZETXSEL_43_RT_OFFSET                              29687
-#define QM_REG_MAXPQSIZETXSEL_44_RT_OFFSET                              29688
-#define QM_REG_MAXPQSIZETXSEL_45_RT_OFFSET                              29689
-#define QM_REG_MAXPQSIZETXSEL_46_RT_OFFSET                              29690
-#define QM_REG_MAXPQSIZETXSEL_47_RT_OFFSET                              29691
-#define QM_REG_MAXPQSIZETXSEL_48_RT_OFFSET                              29692
-#define QM_REG_MAXPQSIZETXSEL_49_RT_OFFSET                              29693
-#define QM_REG_MAXPQSIZETXSEL_50_RT_OFFSET                              29694
-#define QM_REG_MAXPQSIZETXSEL_51_RT_OFFSET                              29695
-#define QM_REG_MAXPQSIZETXSEL_52_RT_OFFSET                              29696
-#define QM_REG_MAXPQSIZETXSEL_53_RT_OFFSET                              29697
-#define QM_REG_MAXPQSIZETXSEL_54_RT_OFFSET                              29698
-#define QM_REG_MAXPQSIZETXSEL_55_RT_OFFSET                              29699
-#define QM_REG_MAXPQSIZETXSEL_56_RT_OFFSET                              29700
-#define QM_REG_MAXPQSIZETXSEL_57_RT_OFFSET                              29701
-#define QM_REG_MAXPQSIZETXSEL_58_RT_OFFSET                              29702
-#define QM_REG_MAXPQSIZETXSEL_59_RT_OFFSET                              29703
-#define QM_REG_MAXPQSIZETXSEL_60_RT_OFFSET                              29704
-#define QM_REG_MAXPQSIZETXSEL_61_RT_OFFSET                              29705
-#define QM_REG_MAXPQSIZETXSEL_62_RT_OFFSET                              29706
-#define QM_REG_MAXPQSIZETXSEL_63_RT_OFFSET                              29707
-#define QM_REG_BASEADDROTHERPQ_RT_OFFSET                                29708
-#define QM_REG_BASEADDROTHERPQ_RT_SIZE                                  128
-#define QM_REG_VOQCRDLINE_RT_OFFSET                                     29836
-#define QM_REG_VOQCRDLINE_RT_SIZE                                       20
-#define QM_REG_VOQINITCRDLINE_RT_OFFSET                                 29856
-#define QM_REG_VOQINITCRDLINE_RT_SIZE                                   20
-#define QM_REG_AFULLQMBYPTHRPFWFQ_RT_OFFSET                             29876
-#define QM_REG_AFULLQMBYPTHRVPWFQ_RT_OFFSET                             29877
-#define QM_REG_AFULLQMBYPTHRPFRL_RT_OFFSET                              29878
-#define QM_REG_AFULLQMBYPTHRGLBLRL_RT_OFFSET                            29879
-#define QM_REG_AFULLOPRTNSTCCRDMASK_RT_OFFSET                           29880
-#define QM_REG_WRROTHERPQGRP_0_RT_OFFSET                                29881
-#define QM_REG_WRROTHERPQGRP_1_RT_OFFSET                                29882
-#define QM_REG_WRROTHERPQGRP_2_RT_OFFSET                                29883
-#define QM_REG_WRROTHERPQGRP_3_RT_OFFSET                                29884
-#define QM_REG_WRROTHERPQGRP_4_RT_OFFSET                                29885
-#define QM_REG_WRROTHERPQGRP_5_RT_OFFSET                                29886
-#define QM_REG_WRROTHERPQGRP_6_RT_OFFSET                                29887
-#define QM_REG_WRROTHERPQGRP_7_RT_OFFSET                                29888
-#define QM_REG_WRROTHERPQGRP_8_RT_OFFSET                                29889
-#define QM_REG_WRROTHERPQGRP_9_RT_OFFSET                                29890
-#define QM_REG_WRROTHERPQGRP_10_RT_OFFSET                               29891
-#define QM_REG_WRROTHERPQGRP_11_RT_OFFSET                               29892
-#define QM_REG_WRROTHERPQGRP_12_RT_OFFSET                               29893
-#define QM_REG_WRROTHERPQGRP_13_RT_OFFSET                               29894
-#define QM_REG_WRROTHERPQGRP_14_RT_OFFSET                               29895
-#define QM_REG_WRROTHERPQGRP_15_RT_OFFSET                               29896
-#define QM_REG_WRROTHERGRPWEIGHT_0_RT_OFFSET                            29897
-#define QM_REG_WRROTHERGRPWEIGHT_1_RT_OFFSET                            29898
-#define QM_REG_WRROTHERGRPWEIGHT_2_RT_OFFSET                            29899
-#define QM_REG_WRROTHERGRPWEIGHT_3_RT_OFFSET                            29900
-#define QM_REG_WRRTXGRPWEIGHT_0_RT_OFFSET                               29901
-#define QM_REG_WRRTXGRPWEIGHT_1_RT_OFFSET                               29902
-#define QM_REG_PQTX2PF_0_RT_OFFSET                                      29903
-#define QM_REG_PQTX2PF_1_RT_OFFSET                                      29904
-#define QM_REG_PQTX2PF_2_RT_OFFSET                                      29905
-#define QM_REG_PQTX2PF_3_RT_OFFSET                                      29906
-#define QM_REG_PQTX2PF_4_RT_OFFSET                                      29907
-#define QM_REG_PQTX2PF_5_RT_OFFSET                                      29908
-#define QM_REG_PQTX2PF_6_RT_OFFSET                                      29909
-#define QM_REG_PQTX2PF_7_RT_OFFSET                                      29910
-#define QM_REG_PQTX2PF_8_RT_OFFSET                                      29911
-#define QM_REG_PQTX2PF_9_RT_OFFSET                                      29912
-#define QM_REG_PQTX2PF_10_RT_OFFSET                                     29913
-#define QM_REG_PQTX2PF_11_RT_OFFSET                                     29914
-#define QM_REG_PQTX2PF_12_RT_OFFSET                                     29915
-#define QM_REG_PQTX2PF_13_RT_OFFSET                                     29916
-#define QM_REG_PQTX2PF_14_RT_OFFSET                                     29917
-#define QM_REG_PQTX2PF_15_RT_OFFSET                                     29918
-#define QM_REG_PQTX2PF_16_RT_OFFSET                                     29919
-#define QM_REG_PQTX2PF_17_RT_OFFSET                                     29920
-#define QM_REG_PQTX2PF_18_RT_OFFSET                                     29921
-#define QM_REG_PQTX2PF_19_RT_OFFSET                                     29922
-#define QM_REG_PQTX2PF_20_RT_OFFSET                                     29923
-#define QM_REG_PQTX2PF_21_RT_OFFSET                                     29924
-#define QM_REG_PQTX2PF_22_RT_OFFSET                                     29925
-#define QM_REG_PQTX2PF_23_RT_OFFSET                                     29926
-#define QM_REG_PQTX2PF_24_RT_OFFSET                                     29927
-#define QM_REG_PQTX2PF_25_RT_OFFSET                                     29928
-#define QM_REG_PQTX2PF_26_RT_OFFSET                                     29929
-#define QM_REG_PQTX2PF_27_RT_OFFSET                                     29930
-#define QM_REG_PQTX2PF_28_RT_OFFSET                                     29931
-#define QM_REG_PQTX2PF_29_RT_OFFSET                                     29932
-#define QM_REG_PQTX2PF_30_RT_OFFSET                                     29933
-#define QM_REG_PQTX2PF_31_RT_OFFSET                                     29934
-#define QM_REG_PQTX2PF_32_RT_OFFSET                                     29935
-#define QM_REG_PQTX2PF_33_RT_OFFSET                                     29936
-#define QM_REG_PQTX2PF_34_RT_OFFSET                                     29937
-#define QM_REG_PQTX2PF_35_RT_OFFSET                                     29938
-#define QM_REG_PQTX2PF_36_RT_OFFSET                                     29939
-#define QM_REG_PQTX2PF_37_RT_OFFSET                                     29940
-#define QM_REG_PQTX2PF_38_RT_OFFSET                                     29941
-#define QM_REG_PQTX2PF_39_RT_OFFSET                                     29942
-#define QM_REG_PQTX2PF_40_RT_OFFSET                                     29943
-#define QM_REG_PQTX2PF_41_RT_OFFSET                                     29944
-#define QM_REG_PQTX2PF_42_RT_OFFSET                                     29945
-#define QM_REG_PQTX2PF_43_RT_OFFSET                                     29946
-#define QM_REG_PQTX2PF_44_RT_OFFSET                                     29947
-#define QM_REG_PQTX2PF_45_RT_OFFSET                                     29948
-#define QM_REG_PQTX2PF_46_RT_OFFSET                                     29949
-#define QM_REG_PQTX2PF_47_RT_OFFSET                                     29950
-#define QM_REG_PQTX2PF_48_RT_OFFSET                                     29951
-#define QM_REG_PQTX2PF_49_RT_OFFSET                                     29952
-#define QM_REG_PQTX2PF_50_RT_OFFSET                                     29953
-#define QM_REG_PQTX2PF_51_RT_OFFSET                                     29954
-#define QM_REG_PQTX2PF_52_RT_OFFSET                                     29955
-#define QM_REG_PQTX2PF_53_RT_OFFSET                                     29956
-#define QM_REG_PQTX2PF_54_RT_OFFSET                                     29957
-#define QM_REG_PQTX2PF_55_RT_OFFSET                                     29958
-#define QM_REG_PQTX2PF_56_RT_OFFSET                                     29959
-#define QM_REG_PQTX2PF_57_RT_OFFSET                                     29960
-#define QM_REG_PQTX2PF_58_RT_OFFSET                                     29961
-#define QM_REG_PQTX2PF_59_RT_OFFSET                                     29962
-#define QM_REG_PQTX2PF_60_RT_OFFSET                                     29963
-#define QM_REG_PQTX2PF_61_RT_OFFSET                                     29964
-#define QM_REG_PQTX2PF_62_RT_OFFSET                                     29965
-#define QM_REG_PQTX2PF_63_RT_OFFSET                                     29966
-#define QM_REG_PQOTHER2PF_0_RT_OFFSET                                   29967
-#define QM_REG_PQOTHER2PF_1_RT_OFFSET                                   29968
-#define QM_REG_PQOTHER2PF_2_RT_OFFSET                                   29969
-#define QM_REG_PQOTHER2PF_3_RT_OFFSET                                   29970
-#define QM_REG_PQOTHER2PF_4_RT_OFFSET                                   29971
-#define QM_REG_PQOTHER2PF_5_RT_OFFSET                                   29972
-#define QM_REG_PQOTHER2PF_6_RT_OFFSET                                   29973
-#define QM_REG_PQOTHER2PF_7_RT_OFFSET                                   29974
-#define QM_REG_PQOTHER2PF_8_RT_OFFSET                                   29975
-#define QM_REG_PQOTHER2PF_9_RT_OFFSET                                   29976
-#define QM_REG_PQOTHER2PF_10_RT_OFFSET                                  29977
-#define QM_REG_PQOTHER2PF_11_RT_OFFSET                                  29978
-#define QM_REG_PQOTHER2PF_12_RT_OFFSET                                  29979
-#define QM_REG_PQOTHER2PF_13_RT_OFFSET                                  29980
-#define QM_REG_PQOTHER2PF_14_RT_OFFSET                                  29981
-#define QM_REG_PQOTHER2PF_15_RT_OFFSET                                  29982
-#define QM_REG_RLGLBLPERIOD_0_RT_OFFSET                                 29983
-#define QM_REG_RLGLBLPERIOD_1_RT_OFFSET                                 29984
-#define QM_REG_RLGLBLPERIODTIMER_0_RT_OFFSET                            29985
-#define QM_REG_RLGLBLPERIODTIMER_1_RT_OFFSET                            29986
-#define QM_REG_RLGLBLPERIODSEL_0_RT_OFFSET                              29987
-#define QM_REG_RLGLBLPERIODSEL_1_RT_OFFSET                              29988
-#define QM_REG_RLGLBLPERIODSEL_2_RT_OFFSET                              29989
-#define QM_REG_RLGLBLPERIODSEL_3_RT_OFFSET                              29990
-#define QM_REG_RLGLBLPERIODSEL_4_RT_OFFSET                              29991
-#define QM_REG_RLGLBLPERIODSEL_5_RT_OFFSET                              29992
-#define QM_REG_RLGLBLPERIODSEL_6_RT_OFFSET                              29993
-#define QM_REG_RLGLBLPERIODSEL_7_RT_OFFSET                              29994
-#define QM_REG_RLGLBLINCVAL_RT_OFFSET                                   29995
-#define QM_REG_RLGLBLINCVAL_RT_SIZE                                     256
-#define QM_REG_RLGLBLUPPERBOUND_RT_OFFSET                               30251
-#define QM_REG_RLGLBLUPPERBOUND_RT_SIZE                                 256
-#define QM_REG_RLGLBLCRD_RT_OFFSET                                      30507
-#define QM_REG_RLGLBLCRD_RT_SIZE                                        256
-#define QM_REG_RLGLBLENABLE_RT_OFFSET                                   30763
-#define QM_REG_RLPFPERIOD_RT_OFFSET                                     30764
-#define QM_REG_RLPFPERIODTIMER_RT_OFFSET                                30765
-#define QM_REG_RLPFINCVAL_RT_OFFSET                                     30766
-#define QM_REG_RLPFINCVAL_RT_SIZE                                       16
-#define QM_REG_RLPFUPPERBOUND_RT_OFFSET                                 30782
-#define QM_REG_RLPFUPPERBOUND_RT_SIZE                                   16
-#define QM_REG_RLPFCRD_RT_OFFSET                                        30798
-#define QM_REG_RLPFCRD_RT_SIZE                                          16
-#define QM_REG_RLPFENABLE_RT_OFFSET                                     30814
-#define QM_REG_RLPFVOQENABLE_RT_OFFSET                                  30815
-#define QM_REG_WFQPFWEIGHT_RT_OFFSET                                    30816
-#define QM_REG_WFQPFWEIGHT_RT_SIZE                                      16
-#define QM_REG_WFQPFUPPERBOUND_RT_OFFSET                                30832
-#define QM_REG_WFQPFUPPERBOUND_RT_SIZE                                  16
-#define QM_REG_WFQPFCRD_RT_OFFSET                                       30848
-#define QM_REG_WFQPFCRD_RT_SIZE                                         160
-#define QM_REG_WFQPFENABLE_RT_OFFSET                                    31008
-#define QM_REG_WFQVPENABLE_RT_OFFSET                                    31009
-#define QM_REG_BASEADDRTXPQ_RT_OFFSET                                   31010
-#define QM_REG_BASEADDRTXPQ_RT_SIZE                                     512
-#define QM_REG_TXPQMAP_RT_OFFSET                                        31522
-#define QM_REG_TXPQMAP_RT_SIZE                                          512
-#define QM_REG_WFQVPWEIGHT_RT_OFFSET                                    32034
-#define QM_REG_WFQVPWEIGHT_RT_SIZE                                      512
-#define QM_REG_WFQVPCRD_RT_OFFSET                                       32546
-#define QM_REG_WFQVPCRD_RT_SIZE                                         512
-#define QM_REG_WFQVPMAP_RT_OFFSET                                       33058
-#define QM_REG_WFQVPMAP_RT_SIZE                                         512
-#define QM_REG_WFQPFCRD_MSB_RT_OFFSET                                   33570
-#define QM_REG_WFQPFCRD_MSB_RT_SIZE                                     160
-#define NIG_REG_TAG_ETHERTYPE_0_RT_OFFSET                               33730
-#define NIG_REG_OUTER_TAG_VALUE_LIST0_RT_OFFSET                         33731
-#define NIG_REG_OUTER_TAG_VALUE_LIST1_RT_OFFSET                         33732
-#define NIG_REG_OUTER_TAG_VALUE_LIST2_RT_OFFSET                         33733
-#define NIG_REG_OUTER_TAG_VALUE_LIST3_RT_OFFSET                         33734
-#define NIG_REG_OUTER_TAG_VALUE_MASK_RT_OFFSET                          33735
-#define NIG_REG_LLH_FUNC_TAGMAC_CLS_TYPE_RT_OFFSET                      33736
-#define NIG_REG_LLH_FUNC_TAG_EN_RT_OFFSET                               33737
-#define NIG_REG_LLH_FUNC_TAG_EN_RT_SIZE                                 4
-#define NIG_REG_LLH_FUNC_TAG_HDR_SEL_RT_OFFSET                          33741
-#define NIG_REG_LLH_FUNC_TAG_HDR_SEL_RT_SIZE                            4
-#define NIG_REG_LLH_FUNC_TAG_VALUE_RT_OFFSET                            33745
-#define NIG_REG_LLH_FUNC_TAG_VALUE_RT_SIZE                              4
-#define NIG_REG_LLH_FUNC_NO_TAG_RT_OFFSET                               33749
-#define NIG_REG_LLH_FUNC_FILTER_VALUE_RT_OFFSET                         33750
-#define NIG_REG_LLH_FUNC_FILTER_VALUE_RT_SIZE                           32
-#define NIG_REG_LLH_FUNC_FILTER_EN_RT_OFFSET                            33782
-#define NIG_REG_LLH_FUNC_FILTER_EN_RT_SIZE                              16
-#define NIG_REG_LLH_FUNC_FILTER_MODE_RT_OFFSET                          33798
-#define NIG_REG_LLH_FUNC_FILTER_MODE_RT_SIZE                            16
-#define NIG_REG_LLH_FUNC_FILTER_PROTOCOL_TYPE_RT_OFFSET                 33814
-#define NIG_REG_LLH_FUNC_FILTER_PROTOCOL_TYPE_RT_SIZE                   16
-#define NIG_REG_LLH_FUNC_FILTER_HDR_SEL_RT_OFFSET                       33830
-#define NIG_REG_LLH_FUNC_FILTER_HDR_SEL_RT_SIZE                         16
-#define NIG_REG_TX_EDPM_CTRL_RT_OFFSET                                  33846
-#define CDU_REG_CID_ADDR_PARAMS_RT_OFFSET                               33847
-#define CDU_REG_SEGMENT0_PARAMS_RT_OFFSET                               33848
-#define CDU_REG_SEGMENT1_PARAMS_RT_OFFSET                               33849
-#define CDU_REG_PF_SEG0_TYPE_OFFSET_RT_OFFSET                           33850
-#define CDU_REG_PF_SEG1_TYPE_OFFSET_RT_OFFSET                           33851
-#define CDU_REG_PF_SEG2_TYPE_OFFSET_RT_OFFSET                           33852
-#define CDU_REG_PF_SEG3_TYPE_OFFSET_RT_OFFSET                           33853
-#define CDU_REG_PF_FL_SEG0_TYPE_OFFSET_RT_OFFSET                        33854
-#define CDU_REG_PF_FL_SEG1_TYPE_OFFSET_RT_OFFSET                        33855
-#define CDU_REG_PF_FL_SEG2_TYPE_OFFSET_RT_OFFSET                        33856
-#define CDU_REG_PF_FL_SEG3_TYPE_OFFSET_RT_OFFSET                        33857
-#define CDU_REG_VF_SEG_TYPE_OFFSET_RT_OFFSET                            33858
-#define CDU_REG_VF_FL_SEG_TYPE_OFFSET_RT_OFFSET                         33859
-#define PBF_REG_TAG_ETHERTYPE_0_RT_OFFSET                               33860
-#define PBF_REG_BTB_SHARED_AREA_SIZE_RT_OFFSET                          33861
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ0_RT_OFFSET                        33862
-#define PBF_REG_BTB_GUARANTEED_VOQ0_RT_OFFSET                           33863
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ0_RT_OFFSET                    33864
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ1_RT_OFFSET                        33865
-#define PBF_REG_BTB_GUARANTEED_VOQ1_RT_OFFSET                           33866
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ1_RT_OFFSET                    33867
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ2_RT_OFFSET                        33868
-#define PBF_REG_BTB_GUARANTEED_VOQ2_RT_OFFSET                           33869
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ2_RT_OFFSET                    33870
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ3_RT_OFFSET                        33871
-#define PBF_REG_BTB_GUARANTEED_VOQ3_RT_OFFSET                           33872
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ3_RT_OFFSET                    33873
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ4_RT_OFFSET                        33874
-#define PBF_REG_BTB_GUARANTEED_VOQ4_RT_OFFSET                           33875
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ4_RT_OFFSET                    33876
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ5_RT_OFFSET                        33877
-#define PBF_REG_BTB_GUARANTEED_VOQ5_RT_OFFSET                           33878
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ5_RT_OFFSET                    33879
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ6_RT_OFFSET                        33880
-#define PBF_REG_BTB_GUARANTEED_VOQ6_RT_OFFSET                           33881
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ6_RT_OFFSET                    33882
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ7_RT_OFFSET                        33883
-#define PBF_REG_BTB_GUARANTEED_VOQ7_RT_OFFSET                           33884
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ7_RT_OFFSET                    33885
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ8_RT_OFFSET                        33886
-#define PBF_REG_BTB_GUARANTEED_VOQ8_RT_OFFSET                           33887
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ8_RT_OFFSET                    33888
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ9_RT_OFFSET                        33889
-#define PBF_REG_BTB_GUARANTEED_VOQ9_RT_OFFSET                           33890
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ9_RT_OFFSET                    33891
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ10_RT_OFFSET                       33892
-#define PBF_REG_BTB_GUARANTEED_VOQ10_RT_OFFSET                          33893
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ10_RT_OFFSET                   33894
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ11_RT_OFFSET                       33895
-#define PBF_REG_BTB_GUARANTEED_VOQ11_RT_OFFSET                          33896
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ11_RT_OFFSET                   33897
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ12_RT_OFFSET                       33898
-#define PBF_REG_BTB_GUARANTEED_VOQ12_RT_OFFSET                          33899
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ12_RT_OFFSET                   33900
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ13_RT_OFFSET                       33901
-#define PBF_REG_BTB_GUARANTEED_VOQ13_RT_OFFSET                          33902
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ13_RT_OFFSET                   33903
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ14_RT_OFFSET                       33904
-#define PBF_REG_BTB_GUARANTEED_VOQ14_RT_OFFSET                          33905
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ14_RT_OFFSET                   33906
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ15_RT_OFFSET                       33907
-#define PBF_REG_BTB_GUARANTEED_VOQ15_RT_OFFSET                          33908
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ15_RT_OFFSET                   33909
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ16_RT_OFFSET                       33910
-#define PBF_REG_BTB_GUARANTEED_VOQ16_RT_OFFSET                          33911
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ16_RT_OFFSET                   33912
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ17_RT_OFFSET                       33913
-#define PBF_REG_BTB_GUARANTEED_VOQ17_RT_OFFSET                          33914
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ17_RT_OFFSET                   33915
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ18_RT_OFFSET                       33916
-#define PBF_REG_BTB_GUARANTEED_VOQ18_RT_OFFSET                          33917
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ18_RT_OFFSET                   33918
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ19_RT_OFFSET                       33919
-#define PBF_REG_BTB_GUARANTEED_VOQ19_RT_OFFSET                          33920
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ19_RT_OFFSET                   33921
-#define XCM_REG_CON_PHY_Q3_RT_OFFSET                                    33922
-
-#define RUNTIME_ARRAY_SIZE 33923
+#define DORQ_REG_PF_MAX_ICID_0_RT_OFFSET 0
+#define DORQ_REG_PF_MAX_ICID_1_RT_OFFSET 1
+#define DORQ_REG_PF_MAX_ICID_2_RT_OFFSET 2
+#define DORQ_REG_PF_MAX_ICID_3_RT_OFFSET 3
+#define DORQ_REG_PF_MAX_ICID_4_RT_OFFSET 4
+#define DORQ_REG_PF_MAX_ICID_5_RT_OFFSET 5
+#define DORQ_REG_PF_MAX_ICID_6_RT_OFFSET 6
+#define DORQ_REG_PF_MAX_ICID_7_RT_OFFSET 7
+#define DORQ_REG_VF_MAX_ICID_0_RT_OFFSET 8
+#define DORQ_REG_VF_MAX_ICID_1_RT_OFFSET 9
+#define DORQ_REG_VF_MAX_ICID_2_RT_OFFSET 10
+#define DORQ_REG_VF_MAX_ICID_3_RT_OFFSET 11
+#define DORQ_REG_VF_MAX_ICID_4_RT_OFFSET 12
+#define DORQ_REG_VF_MAX_ICID_5_RT_OFFSET 13
+#define DORQ_REG_VF_MAX_ICID_6_RT_OFFSET 14
+#define DORQ_REG_VF_MAX_ICID_7_RT_OFFSET 15
+#define DORQ_REG_PF_WAKE_ALL_RT_OFFSET 16
+#define DORQ_REG_TAG1_ETHERTYPE_RT_OFFSET 17
+#define IGU_REG_PF_CONFIGURATION_RT_OFFSET 18
+#define IGU_REG_VF_CONFIGURATION_RT_OFFSET 19
+#define IGU_REG_ATTN_MSG_ADDR_L_RT_OFFSET 20
+#define IGU_REG_ATTN_MSG_ADDR_H_RT_OFFSET 21
+#define IGU_REG_LEADING_EDGE_LATCH_RT_OFFSET 22
+#define IGU_REG_TRAILING_EDGE_LATCH_RT_OFFSET 23
+#define CAU_REG_CQE_AGG_UNIT_SIZE_RT_OFFSET 24
+#define CAU_REG_SB_VAR_MEMORY_RT_OFFSET 761
+#define CAU_REG_SB_VAR_MEMORY_RT_SIZE 736
+#define CAU_REG_SB_VAR_MEMORY_RT_OFFSET 761
+#define CAU_REG_SB_VAR_MEMORY_RT_SIZE 736
+#define CAU_REG_SB_ADDR_MEMORY_RT_OFFSET 1497
+#define CAU_REG_SB_ADDR_MEMORY_RT_SIZE 736
+#define CAU_REG_PI_MEMORY_RT_OFFSET 2233
+#define CAU_REG_PI_MEMORY_RT_SIZE 4416
+#define PRS_REG_SEARCH_RESP_INITIATOR_TYPE_RT_OFFSET 6649
+#define PRS_REG_TASK_ID_MAX_INITIATOR_PF_RT_OFFSET 6650
+#define PRS_REG_TASK_ID_MAX_INITIATOR_VF_RT_OFFSET 6651
+#define PRS_REG_TASK_ID_MAX_TARGET_PF_RT_OFFSET 6652
+#define PRS_REG_TASK_ID_MAX_TARGET_VF_RT_OFFSET 6653
+#define PRS_REG_SEARCH_TCP_RT_OFFSET 6654
+#define PRS_REG_SEARCH_FCOE_RT_OFFSET 6655
+#define PRS_REG_SEARCH_ROCE_RT_OFFSET 6656
+#define PRS_REG_ROCE_DEST_QP_MAX_VF_RT_OFFSET 6657
+#define PRS_REG_ROCE_DEST_QP_MAX_PF_RT_OFFSET 6658
+#define PRS_REG_SEARCH_OPENFLOW_RT_OFFSET 6659
+#define PRS_REG_SEARCH_NON_IP_AS_OPENFLOW_RT_OFFSET 6660
+#define PRS_REG_OPENFLOW_SUPPORT_ONLY_KNOWN_OVER_IP_RT_OFFSET 6661
+#define PRS_REG_OPENFLOW_SEARCH_KEY_MASK_RT_OFFSET 6662
+#define PRS_REG_TAG_ETHERTYPE_0_RT_OFFSET 6663
+#define PRS_REG_LIGHT_L2_ETHERTYPE_EN_RT_OFFSET 6664
+#define SRC_REG_FIRSTFREE_RT_OFFSET 6665
+#define SRC_REG_FIRSTFREE_RT_SIZE 2
+#define SRC_REG_LASTFREE_RT_OFFSET 6667
+#define SRC_REG_LASTFREE_RT_SIZE 2
+#define SRC_REG_COUNTFREE_RT_OFFSET 6669
+#define SRC_REG_NUMBER_HASH_BITS_RT_OFFSET 6670
+#define PSWRQ2_REG_CDUT_P_SIZE_RT_OFFSET 6671
+#define PSWRQ2_REG_CDUC_P_SIZE_RT_OFFSET 6672
+#define PSWRQ2_REG_TM_P_SIZE_RT_OFFSET 6673
+#define PSWRQ2_REG_QM_P_SIZE_RT_OFFSET 6674
+#define PSWRQ2_REG_SRC_P_SIZE_RT_OFFSET 6675
+#define PSWRQ2_REG_TSDM_P_SIZE_RT_OFFSET 6676
+#define PSWRQ2_REG_TM_FIRST_ILT_RT_OFFSET 6677
+#define PSWRQ2_REG_TM_LAST_ILT_RT_OFFSET 6678
+#define PSWRQ2_REG_QM_FIRST_ILT_RT_OFFSET 6679
+#define PSWRQ2_REG_QM_LAST_ILT_RT_OFFSET 6680
+#define PSWRQ2_REG_SRC_FIRST_ILT_RT_OFFSET 6681
+#define PSWRQ2_REG_SRC_LAST_ILT_RT_OFFSET 6682
+#define PSWRQ2_REG_CDUC_FIRST_ILT_RT_OFFSET 6683
+#define PSWRQ2_REG_CDUC_LAST_ILT_RT_OFFSET 6684
+#define PSWRQ2_REG_CDUT_FIRST_ILT_RT_OFFSET 6685
+#define PSWRQ2_REG_CDUT_LAST_ILT_RT_OFFSET 6686
+#define PSWRQ2_REG_TSDM_FIRST_ILT_RT_OFFSET 6687
+#define PSWRQ2_REG_TSDM_LAST_ILT_RT_OFFSET 6688
+#define PSWRQ2_REG_TM_NUMBER_OF_PF_BLOCKS_RT_OFFSET 6689
+#define PSWRQ2_REG_CDUT_NUMBER_OF_PF_BLOCKS_RT_OFFSET 6690
+#define PSWRQ2_REG_CDUC_NUMBER_OF_PF_BLOCKS_RT_OFFSET 6691
+#define PSWRQ2_REG_TM_VF_BLOCKS_RT_OFFSET 6692
+#define PSWRQ2_REG_CDUT_VF_BLOCKS_RT_OFFSET 6693
+#define PSWRQ2_REG_CDUC_VF_BLOCKS_RT_OFFSET 6694
+#define PSWRQ2_REG_TM_BLOCKS_FACTOR_RT_OFFSET 6695
+#define PSWRQ2_REG_CDUT_BLOCKS_FACTOR_RT_OFFSET 6696
+#define PSWRQ2_REG_CDUC_BLOCKS_FACTOR_RT_OFFSET 6697
+#define PSWRQ2_REG_VF_BASE_RT_OFFSET 6698
+#define PSWRQ2_REG_VF_LAST_ILT_RT_OFFSET 6699
+#define PSWRQ2_REG_WR_MBS0_RT_OFFSET 6700
+#define PSWRQ2_REG_RD_MBS0_RT_OFFSET 6701
+#define PSWRQ2_REG_DRAM_ALIGN_WR_RT_OFFSET 6702
+#define PSWRQ2_REG_DRAM_ALIGN_RD_RT_OFFSET 6703
+#define PSWRQ2_REG_ILT_MEMORY_RT_OFFSET 6704
+#define PSWRQ2_REG_ILT_MEMORY_RT_SIZE 22000
+#define PGLUE_REG_B_VF_BASE_RT_OFFSET 28704
+#define PGLUE_REG_B_CACHE_LINE_SIZE_RT_OFFSET 28705
+#define PGLUE_REG_B_PF_BAR0_SIZE_RT_OFFSET 28706
+#define PGLUE_REG_B_PF_BAR1_SIZE_RT_OFFSET 28707
+#define PGLUE_REG_B_VF_BAR1_SIZE_RT_OFFSET 28708
+#define TM_REG_VF_ENABLE_CONN_RT_OFFSET 28709
+#define TM_REG_PF_ENABLE_CONN_RT_OFFSET 28710
+#define TM_REG_PF_ENABLE_TASK_RT_OFFSET 28711
+#define TM_REG_GROUP_SIZE_RESOLUTION_CONN_RT_OFFSET 28712
+#define TM_REG_GROUP_SIZE_RESOLUTION_TASK_RT_OFFSET 28713
+#define TM_REG_CONFIG_CONN_MEM_RT_OFFSET 28714
+#define TM_REG_CONFIG_CONN_MEM_RT_SIZE 416
+#define TM_REG_CONFIG_TASK_MEM_RT_OFFSET 29130
+#define TM_REG_CONFIG_TASK_MEM_RT_SIZE 512
+#define QM_REG_MAXPQSIZE_0_RT_OFFSET 29642
+#define QM_REG_MAXPQSIZE_1_RT_OFFSET 29643
+#define QM_REG_MAXPQSIZE_2_RT_OFFSET 29644
+#define QM_REG_MAXPQSIZETXSEL_0_RT_OFFSET 29645
+#define QM_REG_MAXPQSIZETXSEL_1_RT_OFFSET 29646
+#define QM_REG_MAXPQSIZETXSEL_2_RT_OFFSET 29647
+#define QM_REG_MAXPQSIZETXSEL_3_RT_OFFSET 29648
+#define QM_REG_MAXPQSIZETXSEL_4_RT_OFFSET 29649
+#define QM_REG_MAXPQSIZETXSEL_5_RT_OFFSET 29650
+#define QM_REG_MAXPQSIZETXSEL_6_RT_OFFSET 29651
+#define QM_REG_MAXPQSIZETXSEL_7_RT_OFFSET 29652
+#define QM_REG_MAXPQSIZETXSEL_8_RT_OFFSET 29653
+#define QM_REG_MAXPQSIZETXSEL_9_RT_OFFSET 29654
+#define QM_REG_MAXPQSIZETXSEL_10_RT_OFFSET 29655
+#define QM_REG_MAXPQSIZETXSEL_11_RT_OFFSET 29656
+#define QM_REG_MAXPQSIZETXSEL_12_RT_OFFSET 29657
+#define QM_REG_MAXPQSIZETXSEL_13_RT_OFFSET 29658
+#define QM_REG_MAXPQSIZETXSEL_14_RT_OFFSET 29659
+#define QM_REG_MAXPQSIZETXSEL_15_RT_OFFSET 29660
+#define QM_REG_MAXPQSIZETXSEL_16_RT_OFFSET 29661
+#define QM_REG_MAXPQSIZETXSEL_17_RT_OFFSET 29662
+#define QM_REG_MAXPQSIZETXSEL_18_RT_OFFSET 29663
+#define QM_REG_MAXPQSIZETXSEL_19_RT_OFFSET 29664
+#define QM_REG_MAXPQSIZETXSEL_20_RT_OFFSET 29665
+#define QM_REG_MAXPQSIZETXSEL_21_RT_OFFSET 29666
+#define QM_REG_MAXPQSIZETXSEL_22_RT_OFFSET 29667
+#define QM_REG_MAXPQSIZETXSEL_23_RT_OFFSET 29668
+#define QM_REG_MAXPQSIZETXSEL_24_RT_OFFSET 29669
+#define QM_REG_MAXPQSIZETXSEL_25_RT_OFFSET 29670
+#define QM_REG_MAXPQSIZETXSEL_26_RT_OFFSET 29671
+#define QM_REG_MAXPQSIZETXSEL_27_RT_OFFSET 29672
+#define QM_REG_MAXPQSIZETXSEL_28_RT_OFFSET 29673
+#define QM_REG_MAXPQSIZETXSEL_29_RT_OFFSET 29674
+#define QM_REG_MAXPQSIZETXSEL_30_RT_OFFSET 29675
+#define QM_REG_MAXPQSIZETXSEL_31_RT_OFFSET 29676
+#define QM_REG_MAXPQSIZETXSEL_32_RT_OFFSET 29677
+#define QM_REG_MAXPQSIZETXSEL_33_RT_OFFSET 29678
+#define QM_REG_MAXPQSIZETXSEL_34_RT_OFFSET 29679
+#define QM_REG_MAXPQSIZETXSEL_35_RT_OFFSET 29680
+#define QM_REG_MAXPQSIZETXSEL_36_RT_OFFSET 29681
+#define QM_REG_MAXPQSIZETXSEL_37_RT_OFFSET 29682
+#define QM_REG_MAXPQSIZETXSEL_38_RT_OFFSET 29683
+#define QM_REG_MAXPQSIZETXSEL_39_RT_OFFSET 29684
+#define QM_REG_MAXPQSIZETXSEL_40_RT_OFFSET 29685
+#define QM_REG_MAXPQSIZETXSEL_41_RT_OFFSET 29686
+#define QM_REG_MAXPQSIZETXSEL_42_RT_OFFSET 29687
+#define QM_REG_MAXPQSIZETXSEL_43_RT_OFFSET 29688
+#define QM_REG_MAXPQSIZETXSEL_44_RT_OFFSET 29689
+#define QM_REG_MAXPQSIZETXSEL_45_RT_OFFSET 29690
+#define QM_REG_MAXPQSIZETXSEL_46_RT_OFFSET 29691
+#define QM_REG_MAXPQSIZETXSEL_47_RT_OFFSET 29692
+#define QM_REG_MAXPQSIZETXSEL_48_RT_OFFSET 29693
+#define QM_REG_MAXPQSIZETXSEL_49_RT_OFFSET 29694
+#define QM_REG_MAXPQSIZETXSEL_50_RT_OFFSET 29695
+#define QM_REG_MAXPQSIZETXSEL_51_RT_OFFSET 29696
+#define QM_REG_MAXPQSIZETXSEL_52_RT_OFFSET 29697
+#define QM_REG_MAXPQSIZETXSEL_53_RT_OFFSET 29698
+#define QM_REG_MAXPQSIZETXSEL_54_RT_OFFSET 29699
+#define QM_REG_MAXPQSIZETXSEL_55_RT_OFFSET 29700
+#define QM_REG_MAXPQSIZETXSEL_56_RT_OFFSET 29701
+#define QM_REG_MAXPQSIZETXSEL_57_RT_OFFSET 29702
+#define QM_REG_MAXPQSIZETXSEL_58_RT_OFFSET 29703
+#define QM_REG_MAXPQSIZETXSEL_59_RT_OFFSET 29704
+#define QM_REG_MAXPQSIZETXSEL_60_RT_OFFSET 29705
+#define QM_REG_MAXPQSIZETXSEL_61_RT_OFFSET 29706
+#define QM_REG_MAXPQSIZETXSEL_62_RT_OFFSET 29707
+#define QM_REG_MAXPQSIZETXSEL_63_RT_OFFSET 29708
+#define QM_REG_BASEADDROTHERPQ_RT_OFFSET 29709
+#define QM_REG_BASEADDROTHERPQ_RT_SIZE 128
+#define QM_REG_VOQCRDLINE_RT_OFFSET 29837
+#define QM_REG_VOQCRDLINE_RT_SIZE 20
+#define QM_REG_VOQINITCRDLINE_RT_OFFSET 29857
+#define QM_REG_VOQINITCRDLINE_RT_SIZE 20
+#define QM_REG_AFULLQMBYPTHRPFWFQ_RT_OFFSET 29877
+#define QM_REG_AFULLQMBYPTHRVPWFQ_RT_OFFSET 29878
+#define QM_REG_AFULLQMBYPTHRPFRL_RT_OFFSET 29879
+#define QM_REG_AFULLQMBYPTHRGLBLRL_RT_OFFSET 29880
+#define QM_REG_AFULLOPRTNSTCCRDMASK_RT_OFFSET 29881
+#define QM_REG_WRROTHERPQGRP_0_RT_OFFSET 29882
+#define QM_REG_WRROTHERPQGRP_1_RT_OFFSET 29883
+#define QM_REG_WRROTHERPQGRP_2_RT_OFFSET 29884
+#define QM_REG_WRROTHERPQGRP_3_RT_OFFSET 29885
+#define QM_REG_WRROTHERPQGRP_4_RT_OFFSET 29886
+#define QM_REG_WRROTHERPQGRP_5_RT_OFFSET 29887
+#define QM_REG_WRROTHERPQGRP_6_RT_OFFSET 29888
+#define QM_REG_WRROTHERPQGRP_7_RT_OFFSET 29889
+#define QM_REG_WRROTHERPQGRP_8_RT_OFFSET 29890
+#define QM_REG_WRROTHERPQGRP_9_RT_OFFSET 29891
+#define QM_REG_WRROTHERPQGRP_10_RT_OFFSET 29892
+#define QM_REG_WRROTHERPQGRP_11_RT_OFFSET 29893
+#define QM_REG_WRROTHERPQGRP_12_RT_OFFSET 29894
+#define QM_REG_WRROTHERPQGRP_13_RT_OFFSET 29895
+#define QM_REG_WRROTHERPQGRP_14_RT_OFFSET 29896
+#define QM_REG_WRROTHERPQGRP_15_RT_OFFSET 29897
+#define QM_REG_WRROTHERGRPWEIGHT_0_RT_OFFSET 29898
+#define QM_REG_WRROTHERGRPWEIGHT_1_RT_OFFSET 29899
+#define QM_REG_WRROTHERGRPWEIGHT_2_RT_OFFSET 29900
+#define QM_REG_WRROTHERGRPWEIGHT_3_RT_OFFSET 29901
+#define QM_REG_WRRTXGRPWEIGHT_0_RT_OFFSET 29902
+#define QM_REG_WRRTXGRPWEIGHT_1_RT_OFFSET 29903
+#define QM_REG_PQTX2PF_0_RT_OFFSET 29904
+#define QM_REG_PQTX2PF_1_RT_OFFSET 29905
+#define QM_REG_PQTX2PF_2_RT_OFFSET 29906
+#define QM_REG_PQTX2PF_3_RT_OFFSET 29907
+#define QM_REG_PQTX2PF_4_RT_OFFSET 29908
+#define QM_REG_PQTX2PF_5_RT_OFFSET 29909
+#define QM_REG_PQTX2PF_6_RT_OFFSET 29910
+#define QM_REG_PQTX2PF_7_RT_OFFSET 29911
+#define QM_REG_PQTX2PF_8_RT_OFFSET 29912
+#define QM_REG_PQTX2PF_9_RT_OFFSET 29913
+#define QM_REG_PQTX2PF_10_RT_OFFSET 29914
+#define QM_REG_PQTX2PF_11_RT_OFFSET 29915
+#define QM_REG_PQTX2PF_12_RT_OFFSET 29916
+#define QM_REG_PQTX2PF_13_RT_OFFSET 29917
+#define QM_REG_PQTX2PF_14_RT_OFFSET 29918
+#define QM_REG_PQTX2PF_15_RT_OFFSET 29919
+#define QM_REG_PQTX2PF_16_RT_OFFSET 29920
+#define QM_REG_PQTX2PF_17_RT_OFFSET 29921
+#define QM_REG_PQTX2PF_18_RT_OFFSET 29922
+#define QM_REG_PQTX2PF_19_RT_OFFSET 29923
+#define QM_REG_PQTX2PF_20_RT_OFFSET 29924
+#define QM_REG_PQTX2PF_21_RT_OFFSET 29925
+#define QM_REG_PQTX2PF_22_RT_OFFSET 29926
+#define QM_REG_PQTX2PF_23_RT_OFFSET 29927
+#define QM_REG_PQTX2PF_24_RT_OFFSET 29928
+#define QM_REG_PQTX2PF_25_RT_OFFSET 29929
+#define QM_REG_PQTX2PF_26_RT_OFFSET 29930
+#define QM_REG_PQTX2PF_27_RT_OFFSET 29931
+#define QM_REG_PQTX2PF_28_RT_OFFSET 29932
+#define QM_REG_PQTX2PF_29_RT_OFFSET 29933
+#define QM_REG_PQTX2PF_30_RT_OFFSET 29934
+#define QM_REG_PQTX2PF_31_RT_OFFSET 29935
+#define QM_REG_PQTX2PF_32_RT_OFFSET 29936
+#define QM_REG_PQTX2PF_33_RT_OFFSET 29937
+#define QM_REG_PQTX2PF_34_RT_OFFSET 29938
+#define QM_REG_PQTX2PF_35_RT_OFFSET 29939
+#define QM_REG_PQTX2PF_36_RT_OFFSET 29940
+#define QM_REG_PQTX2PF_37_RT_OFFSET 29941
+#define QM_REG_PQTX2PF_38_RT_OFFSET 29942
+#define QM_REG_PQTX2PF_39_RT_OFFSET 29943
+#define QM_REG_PQTX2PF_40_RT_OFFSET 29944
+#define QM_REG_PQTX2PF_41_RT_OFFSET 29945
+#define QM_REG_PQTX2PF_42_RT_OFFSET 29946
+#define QM_REG_PQTX2PF_43_RT_OFFSET 29947
+#define QM_REG_PQTX2PF_44_RT_OFFSET 29948
+#define QM_REG_PQTX2PF_45_RT_OFFSET 29949
+#define QM_REG_PQTX2PF_46_RT_OFFSET 29950
+#define QM_REG_PQTX2PF_47_RT_OFFSET 29951
+#define QM_REG_PQTX2PF_48_RT_OFFSET 29952
+#define QM_REG_PQTX2PF_49_RT_OFFSET 29953
+#define QM_REG_PQTX2PF_50_RT_OFFSET 29954
+#define QM_REG_PQTX2PF_51_RT_OFFSET 29955
+#define QM_REG_PQTX2PF_52_RT_OFFSET 29956
+#define QM_REG_PQTX2PF_53_RT_OFFSET 29957
+#define QM_REG_PQTX2PF_54_RT_OFFSET 29958
+#define QM_REG_PQTX2PF_55_RT_OFFSET 29959
+#define QM_REG_PQTX2PF_56_RT_OFFSET 29960
+#define QM_REG_PQTX2PF_57_RT_OFFSET 29961
+#define QM_REG_PQTX2PF_58_RT_OFFSET 29962
+#define QM_REG_PQTX2PF_59_RT_OFFSET 29963
+#define QM_REG_PQTX2PF_60_RT_OFFSET 29964
+#define QM_REG_PQTX2PF_61_RT_OFFSET 29965
+#define QM_REG_PQTX2PF_62_RT_OFFSET 29966
+#define QM_REG_PQTX2PF_63_RT_OFFSET 29967
+#define QM_REG_PQOTHER2PF_0_RT_OFFSET 29968
+#define QM_REG_PQOTHER2PF_1_RT_OFFSET 29969
+#define QM_REG_PQOTHER2PF_2_RT_OFFSET 29970
+#define QM_REG_PQOTHER2PF_3_RT_OFFSET 29971
+#define QM_REG_PQOTHER2PF_4_RT_OFFSET 29972
+#define QM_REG_PQOTHER2PF_5_RT_OFFSET 29973
+#define QM_REG_PQOTHER2PF_6_RT_OFFSET 29974
+#define QM_REG_PQOTHER2PF_7_RT_OFFSET 29975
+#define QM_REG_PQOTHER2PF_8_RT_OFFSET 29976
+#define QM_REG_PQOTHER2PF_9_RT_OFFSET 29977
+#define QM_REG_PQOTHER2PF_10_RT_OFFSET 29978
+#define QM_REG_PQOTHER2PF_11_RT_OFFSET 29979
+#define QM_REG_PQOTHER2PF_12_RT_OFFSET 29980
+#define QM_REG_PQOTHER2PF_13_RT_OFFSET 29981
+#define QM_REG_PQOTHER2PF_14_RT_OFFSET 29982
+#define QM_REG_PQOTHER2PF_15_RT_OFFSET 29983
+#define QM_REG_RLGLBLPERIOD_0_RT_OFFSET 29984
+#define QM_REG_RLGLBLPERIOD_1_RT_OFFSET 29985
+#define QM_REG_RLGLBLPERIODTIMER_0_RT_OFFSET 29986
+#define QM_REG_RLGLBLPERIODTIMER_1_RT_OFFSET 29987
+#define QM_REG_RLGLBLPERIODSEL_0_RT_OFFSET 29988
+#define QM_REG_RLGLBLPERIODSEL_1_RT_OFFSET 29989
+#define QM_REG_RLGLBLPERIODSEL_2_RT_OFFSET 29990
+#define QM_REG_RLGLBLPERIODSEL_3_RT_OFFSET 29991
+#define QM_REG_RLGLBLPERIODSEL_4_RT_OFFSET 29992
+#define QM_REG_RLGLBLPERIODSEL_5_RT_OFFSET 29993
+#define QM_REG_RLGLBLPERIODSEL_6_RT_OFFSET 29994
+#define QM_REG_RLGLBLPERIODSEL_7_RT_OFFSET 29995
+#define QM_REG_RLGLBLINCVAL_RT_OFFSET 29996
+#define QM_REG_RLGLBLINCVAL_RT_SIZE 256
+#define QM_REG_RLGLBLUPPERBOUND_RT_OFFSET 30252
+#define QM_REG_RLGLBLUPPERBOUND_RT_SIZE 256
+#define QM_REG_RLGLBLCRD_RT_OFFSET 30508
+#define QM_REG_RLGLBLCRD_RT_SIZE 256
+#define QM_REG_RLGLBLENABLE_RT_OFFSET 30764
+#define QM_REG_RLPFPERIOD_RT_OFFSET 30765
+#define QM_REG_RLPFPERIODTIMER_RT_OFFSET 30766
+#define QM_REG_RLPFINCVAL_RT_OFFSET 30767
+#define QM_REG_RLPFINCVAL_RT_SIZE 16
+#define QM_REG_RLPFUPPERBOUND_RT_OFFSET 30783
+#define QM_REG_RLPFUPPERBOUND_RT_SIZE 16
+#define QM_REG_RLPFCRD_RT_OFFSET 30799
+#define QM_REG_RLPFCRD_RT_SIZE 16
+#define QM_REG_RLPFENABLE_RT_OFFSET 30815
+#define QM_REG_RLPFVOQENABLE_RT_OFFSET 30816
+#define QM_REG_WFQPFWEIGHT_RT_OFFSET 30817
+#define QM_REG_WFQPFWEIGHT_RT_SIZE 16
+#define QM_REG_WFQPFUPPERBOUND_RT_OFFSET 30833
+#define QM_REG_WFQPFUPPERBOUND_RT_SIZE 16
+#define QM_REG_WFQPFCRD_RT_OFFSET 30849
+#define QM_REG_WFQPFCRD_RT_SIZE 160
+#define QM_REG_WFQPFENABLE_RT_OFFSET 31009
+#define QM_REG_WFQVPENABLE_RT_OFFSET 31010
+#define QM_REG_BASEADDRTXPQ_RT_OFFSET 31011
+#define QM_REG_BASEADDRTXPQ_RT_SIZE 512
+#define QM_REG_TXPQMAP_RT_OFFSET 31523
+#define QM_REG_TXPQMAP_RT_SIZE 512
+#define QM_REG_WFQVPWEIGHT_RT_OFFSET 32035
+#define QM_REG_WFQVPWEIGHT_RT_SIZE 512
+#define QM_REG_WFQVPCRD_RT_OFFSET 32547
+#define QM_REG_WFQVPCRD_RT_SIZE 512
+#define QM_REG_WFQVPMAP_RT_OFFSET 33059
+#define QM_REG_WFQVPMAP_RT_SIZE 512
+#define QM_REG_WFQPFCRD_MSB_RT_OFFSET 33571
+#define QM_REG_WFQPFCRD_MSB_RT_SIZE 160
+#define NIG_REG_TAG_ETHERTYPE_0_RT_OFFSET 33731
+#define NIG_REG_OUTER_TAG_VALUE_LIST0_RT_OFFSET 33732
+#define NIG_REG_OUTER_TAG_VALUE_LIST1_RT_OFFSET 33733
+#define NIG_REG_OUTER_TAG_VALUE_LIST2_RT_OFFSET 33734
+#define NIG_REG_OUTER_TAG_VALUE_LIST3_RT_OFFSET 33735
+#define NIG_REG_OUTER_TAG_VALUE_MASK_RT_OFFSET 33736
+#define NIG_REG_LLH_FUNC_TAGMAC_CLS_TYPE_RT_OFFSET 33737
+#define NIG_REG_LLH_FUNC_TAG_EN_RT_OFFSET 33738
+#define NIG_REG_LLH_FUNC_TAG_EN_RT_SIZE 4
+#define NIG_REG_LLH_FUNC_TAG_HDR_SEL_RT_OFFSET 33742
+#define NIG_REG_LLH_FUNC_TAG_HDR_SEL_RT_SIZE 4
+#define NIG_REG_LLH_FUNC_TAG_VALUE_RT_OFFSET 33746
+#define NIG_REG_LLH_FUNC_TAG_VALUE_RT_SIZE 4
+#define NIG_REG_LLH_FUNC_NO_TAG_RT_OFFSET 33750
+#define NIG_REG_LLH_FUNC_FILTER_VALUE_RT_OFFSET 33751
+#define NIG_REG_LLH_FUNC_FILTER_VALUE_RT_SIZE 32
+#define NIG_REG_LLH_FUNC_FILTER_EN_RT_OFFSET 33783
+#define NIG_REG_LLH_FUNC_FILTER_EN_RT_SIZE 16
+#define NIG_REG_LLH_FUNC_FILTER_MODE_RT_OFFSET 33799
+#define NIG_REG_LLH_FUNC_FILTER_MODE_RT_SIZE 16
+#define NIG_REG_LLH_FUNC_FILTER_PROTOCOL_TYPE_RT_OFFSET 33815
+#define NIG_REG_LLH_FUNC_FILTER_PROTOCOL_TYPE_RT_SIZE 16
+#define NIG_REG_LLH_FUNC_FILTER_HDR_SEL_RT_OFFSET 33831
+#define NIG_REG_LLH_FUNC_FILTER_HDR_SEL_RT_SIZE 16
+#define NIG_REG_TX_EDPM_CTRL_RT_OFFSET 33847
+#define NIG_REG_ROCE_DUPLICATE_TO_HOST_RT_OFFSET 33848
+#define CDU_REG_CID_ADDR_PARAMS_RT_OFFSET 33849
+#define CDU_REG_SEGMENT0_PARAMS_RT_OFFSET 33850
+#define CDU_REG_SEGMENT1_PARAMS_RT_OFFSET 33851
+#define CDU_REG_PF_SEG0_TYPE_OFFSET_RT_OFFSET 33852
+#define CDU_REG_PF_SEG1_TYPE_OFFSET_RT_OFFSET 33853
+#define CDU_REG_PF_SEG2_TYPE_OFFSET_RT_OFFSET 33854
+#define CDU_REG_PF_SEG3_TYPE_OFFSET_RT_OFFSET 33855
+#define CDU_REG_PF_FL_SEG0_TYPE_OFFSET_RT_OFFSET 33856
+#define CDU_REG_PF_FL_SEG1_TYPE_OFFSET_RT_OFFSET 33857
+#define CDU_REG_PF_FL_SEG2_TYPE_OFFSET_RT_OFFSET 33858
+#define CDU_REG_PF_FL_SEG3_TYPE_OFFSET_RT_OFFSET 33859
+#define CDU_REG_VF_SEG_TYPE_OFFSET_RT_OFFSET 33860
+#define CDU_REG_VF_FL_SEG_TYPE_OFFSET_RT_OFFSET 33861
+#define PBF_REG_TAG_ETHERTYPE_0_RT_OFFSET 33862
+#define PBF_REG_BTB_SHARED_AREA_SIZE_RT_OFFSET 33863
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ0_RT_OFFSET 33864
+#define PBF_REG_BTB_GUARANTEED_VOQ0_RT_OFFSET 33865
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ0_RT_OFFSET 33866
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ1_RT_OFFSET 33867
+#define PBF_REG_BTB_GUARANTEED_VOQ1_RT_OFFSET 33868
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ1_RT_OFFSET 33869
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ2_RT_OFFSET 33870
+#define PBF_REG_BTB_GUARANTEED_VOQ2_RT_OFFSET 33871
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ2_RT_OFFSET 33872
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ3_RT_OFFSET 33873
+#define PBF_REG_BTB_GUARANTEED_VOQ3_RT_OFFSET 33874
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ3_RT_OFFSET 33875
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ4_RT_OFFSET 33876
+#define PBF_REG_BTB_GUARANTEED_VOQ4_RT_OFFSET 33877
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ4_RT_OFFSET 33878
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ5_RT_OFFSET 33879
+#define PBF_REG_BTB_GUARANTEED_VOQ5_RT_OFFSET 33880
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ5_RT_OFFSET 33881
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ6_RT_OFFSET 33882
+#define PBF_REG_BTB_GUARANTEED_VOQ6_RT_OFFSET 33883
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ6_RT_OFFSET 33884
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ7_RT_OFFSET 33885
+#define PBF_REG_BTB_GUARANTEED_VOQ7_RT_OFFSET 33886
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ7_RT_OFFSET 33887
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ8_RT_OFFSET 33888
+#define PBF_REG_BTB_GUARANTEED_VOQ8_RT_OFFSET 33889
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ8_RT_OFFSET 33890
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ9_RT_OFFSET 33891
+#define PBF_REG_BTB_GUARANTEED_VOQ9_RT_OFFSET 33892
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ9_RT_OFFSET 33893
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ10_RT_OFFSET 33894
+#define PBF_REG_BTB_GUARANTEED_VOQ10_RT_OFFSET 33895
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ10_RT_OFFSET 33896
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ11_RT_OFFSET 33897
+#define PBF_REG_BTB_GUARANTEED_VOQ11_RT_OFFSET 33898
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ11_RT_OFFSET 33899
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ12_RT_OFFSET 33900
+#define PBF_REG_BTB_GUARANTEED_VOQ12_RT_OFFSET 33901
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ12_RT_OFFSET 33902
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ13_RT_OFFSET 33903
+#define PBF_REG_BTB_GUARANTEED_VOQ13_RT_OFFSET 33904
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ13_RT_OFFSET 33905
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ14_RT_OFFSET 33906
+#define PBF_REG_BTB_GUARANTEED_VOQ14_RT_OFFSET 33907
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ14_RT_OFFSET 33908
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ15_RT_OFFSET 33909
+#define PBF_REG_BTB_GUARANTEED_VOQ15_RT_OFFSET 33910
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ15_RT_OFFSET 33911
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ16_RT_OFFSET 33912
+#define PBF_REG_BTB_GUARANTEED_VOQ16_RT_OFFSET 33913
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ16_RT_OFFSET 33914
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ17_RT_OFFSET 33915
+#define PBF_REG_BTB_GUARANTEED_VOQ17_RT_OFFSET 33916
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ17_RT_OFFSET 33917
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ18_RT_OFFSET 33918
+#define PBF_REG_BTB_GUARANTEED_VOQ18_RT_OFFSET 33919
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ18_RT_OFFSET 33920
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ19_RT_OFFSET 33921
+#define PBF_REG_BTB_GUARANTEED_VOQ19_RT_OFFSET 33922
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ19_RT_OFFSET 33923
+#define XCM_REG_CON_PHY_Q3_RT_OFFSET 33924
+
+#define RUNTIME_ARRAY_SIZE 33925
 
 /* The eth storm context for the Tstorm */
 struct tstorm_eth_conn_st_ctx {
@@ -2380,266 +2687,266 @@ struct xstorm_eth_conn_st_ctx {
 };
 
 struct xstorm_eth_conn_ag_ctx {
-	u8	reserved0 /* cdu_validation */;
-	u8	eth_state /* state */;
-	u8	flags0;
-#define XSTORM_ETH_CONN_AG_CTX_EXIST_IN_QM0_MASK            0x1
-#define XSTORM_ETH_CONN_AG_CTX_EXIST_IN_QM0_SHIFT           0
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED1_MASK               0x1
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED1_SHIFT              1
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED2_MASK               0x1
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED2_SHIFT              2
-#define XSTORM_ETH_CONN_AG_CTX_EXIST_IN_QM3_MASK            0x1
-#define XSTORM_ETH_CONN_AG_CTX_EXIST_IN_QM3_SHIFT           3
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED3_MASK               0x1 /* bit4 */
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED3_SHIFT              4
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED4_MASK               0x1
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED4_SHIFT              5
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED5_MASK               0x1 /* bit6 */
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED5_SHIFT              6
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED6_MASK               0x1 /* bit7 */
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED6_SHIFT              7
-	u8 flags1;
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED7_MASK               0x1 /* bit8 */
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED7_SHIFT              0
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED8_MASK               0x1 /* bit9 */
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED8_SHIFT              1
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED9_MASK               0x1 /* bit10 */
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED9_SHIFT              2
-#define XSTORM_ETH_CONN_AG_CTX_BIT11_MASK                   0x1 /* bit11 */
-#define XSTORM_ETH_CONN_AG_CTX_BIT11_SHIFT                  3
-#define XSTORM_ETH_CONN_AG_CTX_BIT12_MASK                   0x1 /* bit12 */
-#define XSTORM_ETH_CONN_AG_CTX_BIT12_SHIFT                  4
-#define XSTORM_ETH_CONN_AG_CTX_BIT13_MASK                   0x1 /* bit13 */
-#define XSTORM_ETH_CONN_AG_CTX_BIT13_SHIFT                  5
-#define XSTORM_ETH_CONN_AG_CTX_TX_RULE_ACTIVE_MASK          0x1 /* bit14 */
-#define XSTORM_ETH_CONN_AG_CTX_TX_RULE_ACTIVE_SHIFT         6
-#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_ACTIVE_MASK            0x1 /* bit15 */
-#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_ACTIVE_SHIFT           7
+	u8 reserved0;
+	u8 eth_state;
+	u8 flags0;
+#define XSTORM_ETH_CONN_AG_CTX_EXIST_IN_QM0_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_EXIST_IN_QM0_SHIFT	0
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED1_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED1_SHIFT		1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED2_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED2_SHIFT		2
+#define XSTORM_ETH_CONN_AG_CTX_EXIST_IN_QM3_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_EXIST_IN_QM3_SHIFT	3
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED3_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED3_SHIFT		4
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED4_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED4_SHIFT		5
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED5_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED5_SHIFT		6
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED6_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED6_SHIFT		7
+		u8 flags1;
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED7_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED7_SHIFT		0
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED8_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED8_SHIFT		1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED9_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED9_SHIFT		2
+#define XSTORM_ETH_CONN_AG_CTX_BIT11_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_BIT11_SHIFT		3
+#define XSTORM_ETH_CONN_AG_CTX_BIT12_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_BIT12_SHIFT		4
+#define XSTORM_ETH_CONN_AG_CTX_BIT13_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_BIT13_SHIFT		5
+#define XSTORM_ETH_CONN_AG_CTX_TX_RULE_ACTIVE_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_TX_RULE_ACTIVE_SHIFT	6
+#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_ACTIVE_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_ACTIVE_SHIFT	7
 	u8 flags2;
-#define XSTORM_ETH_CONN_AG_CTX_CF0_MASK                     0x3 /* timer0cf */
-#define XSTORM_ETH_CONN_AG_CTX_CF0_SHIFT                    0
-#define XSTORM_ETH_CONN_AG_CTX_CF1_MASK                     0x3 /* timer1cf */
-#define XSTORM_ETH_CONN_AG_CTX_CF1_SHIFT                    2
-#define XSTORM_ETH_CONN_AG_CTX_CF2_MASK                     0x3 /* timer2cf */
-#define XSTORM_ETH_CONN_AG_CTX_CF2_SHIFT                    4
-#define XSTORM_ETH_CONN_AG_CTX_CF3_MASK                     0x3
-#define XSTORM_ETH_CONN_AG_CTX_CF3_SHIFT                    6
+#define XSTORM_ETH_CONN_AG_CTX_CF0_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_CF0_SHIFT		0
+#define XSTORM_ETH_CONN_AG_CTX_CF1_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_CF1_SHIFT		2
+#define XSTORM_ETH_CONN_AG_CTX_CF2_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_CF2_SHIFT		4
+#define XSTORM_ETH_CONN_AG_CTX_CF3_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_CF3_SHIFT		6
 	u8 flags3;
-#define XSTORM_ETH_CONN_AG_CTX_CF4_MASK                     0x3 /* cf4 */
-#define XSTORM_ETH_CONN_AG_CTX_CF4_SHIFT                    0
-#define XSTORM_ETH_CONN_AG_CTX_CF5_MASK                     0x3 /* cf5 */
-#define XSTORM_ETH_CONN_AG_CTX_CF5_SHIFT                    2
-#define XSTORM_ETH_CONN_AG_CTX_CF6_MASK                     0x3 /* cf6 */
-#define XSTORM_ETH_CONN_AG_CTX_CF6_SHIFT                    4
-#define XSTORM_ETH_CONN_AG_CTX_CF7_MASK                     0x3 /* cf7 */
-#define XSTORM_ETH_CONN_AG_CTX_CF7_SHIFT                    6
-	u8 flags4;
-#define XSTORM_ETH_CONN_AG_CTX_CF8_MASK                     0x3 /* cf8 */
-#define XSTORM_ETH_CONN_AG_CTX_CF8_SHIFT                    0
-#define XSTORM_ETH_CONN_AG_CTX_CF9_MASK                     0x3 /* cf9 */
-#define XSTORM_ETH_CONN_AG_CTX_CF9_SHIFT                    2
-#define XSTORM_ETH_CONN_AG_CTX_CF10_MASK                    0x3 /* cf10 */
-#define XSTORM_ETH_CONN_AG_CTX_CF10_SHIFT                   4
-#define XSTORM_ETH_CONN_AG_CTX_CF11_MASK                    0x3 /* cf11 */
-#define XSTORM_ETH_CONN_AG_CTX_CF11_SHIFT                   6
+#define XSTORM_ETH_CONN_AG_CTX_CF4_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_CF4_SHIFT		0
+#define XSTORM_ETH_CONN_AG_CTX_CF5_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_CF5_SHIFT		2
+#define XSTORM_ETH_CONN_AG_CTX_CF6_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_CF6_SHIFT		4
+#define XSTORM_ETH_CONN_AG_CTX_CF7_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_CF7_SHIFT		6
+		u8 flags4;
+#define XSTORM_ETH_CONN_AG_CTX_CF8_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_CF8_SHIFT		0
+#define XSTORM_ETH_CONN_AG_CTX_CF9_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_CF9_SHIFT		2
+#define XSTORM_ETH_CONN_AG_CTX_CF10_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_CF10_SHIFT		4
+#define XSTORM_ETH_CONN_AG_CTX_CF11_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_CF11_SHIFT		6
 	u8 flags5;
-#define XSTORM_ETH_CONN_AG_CTX_CF12_MASK                    0x3 /* cf12 */
-#define XSTORM_ETH_CONN_AG_CTX_CF12_SHIFT                   0
-#define XSTORM_ETH_CONN_AG_CTX_CF13_MASK                    0x3 /* cf13 */
-#define XSTORM_ETH_CONN_AG_CTX_CF13_SHIFT                   2
-#define XSTORM_ETH_CONN_AG_CTX_CF14_MASK                    0x3 /* cf14 */
-#define XSTORM_ETH_CONN_AG_CTX_CF14_SHIFT                   4
-#define XSTORM_ETH_CONN_AG_CTX_CF15_MASK                    0x3 /* cf15 */
-#define XSTORM_ETH_CONN_AG_CTX_CF15_SHIFT                   6
+#define XSTORM_ETH_CONN_AG_CTX_CF12_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_CF12_SHIFT		0
+#define XSTORM_ETH_CONN_AG_CTX_CF13_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_CF13_SHIFT		2
+#define XSTORM_ETH_CONN_AG_CTX_CF14_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_CF14_SHIFT		4
+#define XSTORM_ETH_CONN_AG_CTX_CF15_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_CF15_SHIFT		6
 	u8 flags6;
-#define XSTORM_ETH_CONN_AG_CTX_GO_TO_BD_CONS_CF_MASK        0x3 /* cf16 */
-#define XSTORM_ETH_CONN_AG_CTX_GO_TO_BD_CONS_CF_SHIFT       0
-#define XSTORM_ETH_CONN_AG_CTX_MULTI_UNICAST_CF_MASK        0x3
-#define XSTORM_ETH_CONN_AG_CTX_MULTI_UNICAST_CF_SHIFT       2
-#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_MASK                   0x3 /* cf18 */
-#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_SHIFT                  4
-#define XSTORM_ETH_CONN_AG_CTX_TERMINATE_CF_MASK            0x3 /* cf19 */
-#define XSTORM_ETH_CONN_AG_CTX_TERMINATE_CF_SHIFT           6
+#define XSTORM_ETH_CONN_AG_CTX_GO_TO_BD_CONS_CF_MASK	0x3
+#define XSTORM_ETH_CONN_AG_CTX_GO_TO_BD_CONS_CF_SHIFT	0
+#define XSTORM_ETH_CONN_AG_CTX_MULTI_UNICAST_CF_MASK	0x3
+#define XSTORM_ETH_CONN_AG_CTX_MULTI_UNICAST_CF_SHIFT	2
+#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_SHIFT		4
+#define XSTORM_ETH_CONN_AG_CTX_TERMINATE_CF_MASK	0x3
+#define XSTORM_ETH_CONN_AG_CTX_TERMINATE_CF_SHIFT	6
 	u8 flags7;
-#define XSTORM_ETH_CONN_AG_CTX_FLUSH_Q0_MASK                0x3 /* cf20 */
-#define XSTORM_ETH_CONN_AG_CTX_FLUSH_Q0_SHIFT               0
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED10_MASK              0x3 /* cf21 */
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED10_SHIFT             2
-#define XSTORM_ETH_CONN_AG_CTX_SLOW_PATH_MASK               0x3 /* cf22 */
-#define XSTORM_ETH_CONN_AG_CTX_SLOW_PATH_SHIFT              4
-#define XSTORM_ETH_CONN_AG_CTX_CF0EN_MASK                   0x1 /* cf0en */
-#define XSTORM_ETH_CONN_AG_CTX_CF0EN_SHIFT                  6
-#define XSTORM_ETH_CONN_AG_CTX_CF1EN_MASK                   0x1 /* cf1en */
-#define XSTORM_ETH_CONN_AG_CTX_CF1EN_SHIFT                  7
+#define XSTORM_ETH_CONN_AG_CTX_FLUSH_Q0_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_FLUSH_Q0_SHIFT		0
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED10_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED10_SHIFT		2
+#define XSTORM_ETH_CONN_AG_CTX_SLOW_PATH_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_SLOW_PATH_SHIFT		4
+#define XSTORM_ETH_CONN_AG_CTX_CF0EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_CF0EN_SHIFT		6
+#define XSTORM_ETH_CONN_AG_CTX_CF1EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_CF1EN_SHIFT		7
 	u8 flags8;
-#define XSTORM_ETH_CONN_AG_CTX_CF2EN_MASK                   0x1 /* cf2en */
-#define XSTORM_ETH_CONN_AG_CTX_CF2EN_SHIFT                  0
-#define XSTORM_ETH_CONN_AG_CTX_CF3EN_MASK                   0x1 /* cf3en */
-#define XSTORM_ETH_CONN_AG_CTX_CF3EN_SHIFT                  1
-#define XSTORM_ETH_CONN_AG_CTX_CF4EN_MASK                   0x1 /* cf4en */
-#define XSTORM_ETH_CONN_AG_CTX_CF4EN_SHIFT                  2
-#define XSTORM_ETH_CONN_AG_CTX_CF5EN_MASK                   0x1 /* cf5en */
-#define XSTORM_ETH_CONN_AG_CTX_CF5EN_SHIFT                  3
-#define XSTORM_ETH_CONN_AG_CTX_CF6EN_MASK                   0x1 /* cf6en */
-#define XSTORM_ETH_CONN_AG_CTX_CF6EN_SHIFT                  4
-#define XSTORM_ETH_CONN_AG_CTX_CF7EN_MASK                   0x1 /* cf7en */
-#define XSTORM_ETH_CONN_AG_CTX_CF7EN_SHIFT                  5
-#define XSTORM_ETH_CONN_AG_CTX_CF8EN_MASK                   0x1 /* cf8en */
-#define XSTORM_ETH_CONN_AG_CTX_CF8EN_SHIFT                  6
-#define XSTORM_ETH_CONN_AG_CTX_CF9EN_MASK                   0x1 /* cf9en */
-#define XSTORM_ETH_CONN_AG_CTX_CF9EN_SHIFT                  7
+#define XSTORM_ETH_CONN_AG_CTX_CF2EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_CF2EN_SHIFT		0
+#define XSTORM_ETH_CONN_AG_CTX_CF3EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_CF3EN_SHIFT		1
+#define XSTORM_ETH_CONN_AG_CTX_CF4EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_CF4EN_SHIFT		2
+#define XSTORM_ETH_CONN_AG_CTX_CF5EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_CF5EN_SHIFT		3
+#define XSTORM_ETH_CONN_AG_CTX_CF6EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_CF6EN_SHIFT		4
+#define XSTORM_ETH_CONN_AG_CTX_CF7EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_CF7EN_SHIFT		5
+#define XSTORM_ETH_CONN_AG_CTX_CF8EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_CF8EN_SHIFT		6
+#define XSTORM_ETH_CONN_AG_CTX_CF9EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_CF9EN_SHIFT		7
 	u8 flags9;
-#define XSTORM_ETH_CONN_AG_CTX_CF10EN_MASK                  0x1 /* cf10en */
-#define XSTORM_ETH_CONN_AG_CTX_CF10EN_SHIFT                 0
-#define XSTORM_ETH_CONN_AG_CTX_CF11EN_MASK                  0x1 /* cf11en */
-#define XSTORM_ETH_CONN_AG_CTX_CF11EN_SHIFT                 1
-#define XSTORM_ETH_CONN_AG_CTX_CF12EN_MASK                  0x1 /* cf12en */
-#define XSTORM_ETH_CONN_AG_CTX_CF12EN_SHIFT                 2
-#define XSTORM_ETH_CONN_AG_CTX_CF13EN_MASK                  0x1 /* cf13en */
-#define XSTORM_ETH_CONN_AG_CTX_CF13EN_SHIFT                 3
-#define XSTORM_ETH_CONN_AG_CTX_CF14EN_MASK                  0x1 /* cf14en */
-#define XSTORM_ETH_CONN_AG_CTX_CF14EN_SHIFT                 4
-#define XSTORM_ETH_CONN_AG_CTX_CF15EN_MASK                  0x1 /* cf15en */
-#define XSTORM_ETH_CONN_AG_CTX_CF15EN_SHIFT                 5
-#define XSTORM_ETH_CONN_AG_CTX_GO_TO_BD_CONS_CF_EN_MASK     0x1 /* cf16en */
-#define XSTORM_ETH_CONN_AG_CTX_GO_TO_BD_CONS_CF_EN_SHIFT    6
-#define XSTORM_ETH_CONN_AG_CTX_MULTI_UNICAST_CF_EN_MASK     0x1
-#define XSTORM_ETH_CONN_AG_CTX_MULTI_UNICAST_CF_EN_SHIFT    7
+#define XSTORM_ETH_CONN_AG_CTX_CF10EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_CF10EN_SHIFT		0
+#define XSTORM_ETH_CONN_AG_CTX_CF11EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_CF11EN_SHIFT		1
+#define XSTORM_ETH_CONN_AG_CTX_CF12EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_CF12EN_SHIFT		2
+#define XSTORM_ETH_CONN_AG_CTX_CF13EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_CF13EN_SHIFT		3
+#define XSTORM_ETH_CONN_AG_CTX_CF14EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_CF14EN_SHIFT		4
+#define XSTORM_ETH_CONN_AG_CTX_CF15EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_CF15EN_SHIFT		5
+#define XSTORM_ETH_CONN_AG_CTX_GO_TO_BD_CONS_CF_EN_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_GO_TO_BD_CONS_CF_EN_SHIFT 6
+#define XSTORM_ETH_CONN_AG_CTX_MULTI_UNICAST_CF_EN_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_MULTI_UNICAST_CF_EN_SHIFT 7
 	u8 flags10;
-#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_EN_MASK                0x1 /* cf18en */
-#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_EN_SHIFT               0
-#define XSTORM_ETH_CONN_AG_CTX_TERMINATE_CF_EN_MASK         0x1 /* cf19en */
-#define XSTORM_ETH_CONN_AG_CTX_TERMINATE_CF_EN_SHIFT        1
-#define XSTORM_ETH_CONN_AG_CTX_FLUSH_Q0_EN_MASK             0x1 /* cf20en */
-#define XSTORM_ETH_CONN_AG_CTX_FLUSH_Q0_EN_SHIFT            2
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED11_MASK              0x1 /* cf21en */
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED11_SHIFT             3
-#define XSTORM_ETH_CONN_AG_CTX_SLOW_PATH_EN_MASK            0x1 /* cf22en */
-#define XSTORM_ETH_CONN_AG_CTX_SLOW_PATH_EN_SHIFT           4
-#define XSTORM_ETH_CONN_AG_CTX_TPH_ENABLE_EN_RESERVED_MASK  0x1 /* cf23en */
+#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_DQ_CF_EN_SHIFT		0
+#define XSTORM_ETH_CONN_AG_CTX_TERMINATE_CF_EN_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_TERMINATE_CF_EN_SHIFT	1
+#define XSTORM_ETH_CONN_AG_CTX_FLUSH_Q0_EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_FLUSH_Q0_EN_SHIFT	2
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED11_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED11_SHIFT		3
+#define XSTORM_ETH_CONN_AG_CTX_SLOW_PATH_EN_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_SLOW_PATH_EN_SHIFT	4
+#define XSTORM_ETH_CONN_AG_CTX_TPH_ENABLE_EN_RESERVED_MASK 0x1
 #define XSTORM_ETH_CONN_AG_CTX_TPH_ENABLE_EN_RESERVED_SHIFT 5
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED12_MASK              0x1 /* rule0en */
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED12_SHIFT             6
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED13_MASK              0x1 /* rule1en */
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED13_SHIFT             7
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED12_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED12_SHIFT		6
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED13_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED13_SHIFT		7
 	u8 flags11;
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED14_MASK              0x1 /* rule2en */
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED14_SHIFT             0
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED15_MASK              0x1 /* rule3en */
-#define XSTORM_ETH_CONN_AG_CTX_RESERVED15_SHIFT             1
-#define XSTORM_ETH_CONN_AG_CTX_TX_DEC_RULE_EN_MASK          0x1 /* rule4en */
-#define XSTORM_ETH_CONN_AG_CTX_TX_DEC_RULE_EN_SHIFT         2
-#define XSTORM_ETH_CONN_AG_CTX_RULE5EN_MASK                 0x1 /* rule5en */
-#define XSTORM_ETH_CONN_AG_CTX_RULE5EN_SHIFT                3
-#define XSTORM_ETH_CONN_AG_CTX_RULE6EN_MASK                 0x1 /* rule6en */
-#define XSTORM_ETH_CONN_AG_CTX_RULE6EN_SHIFT                4
-#define XSTORM_ETH_CONN_AG_CTX_RULE7EN_MASK                 0x1 /* rule7en */
-#define XSTORM_ETH_CONN_AG_CTX_RULE7EN_SHIFT                5
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED1_MASK            0x1 /* rule8en */
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED1_SHIFT           6
-#define XSTORM_ETH_CONN_AG_CTX_RULE9EN_MASK                 0x1 /* rule9en */
-#define XSTORM_ETH_CONN_AG_CTX_RULE9EN_SHIFT                7
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED14_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED14_SHIFT		0
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED15_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RESERVED15_SHIFT		1
+#define XSTORM_ETH_CONN_AG_CTX_TX_DEC_RULE_EN_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_TX_DEC_RULE_EN_SHIFT	2
+#define XSTORM_ETH_CONN_AG_CTX_RULE5EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RULE5EN_SHIFT		3
+#define XSTORM_ETH_CONN_AG_CTX_RULE6EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RULE6EN_SHIFT		4
+#define XSTORM_ETH_CONN_AG_CTX_RULE7EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RULE7EN_SHIFT		5
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED1_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED1_SHIFT	6
+#define XSTORM_ETH_CONN_AG_CTX_RULE9EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RULE9EN_SHIFT		7
 	u8 flags12;
-#define XSTORM_ETH_CONN_AG_CTX_RULE10EN_MASK                0x1 /* rule10en */
-#define XSTORM_ETH_CONN_AG_CTX_RULE10EN_SHIFT               0
-#define XSTORM_ETH_CONN_AG_CTX_RULE11EN_MASK                0x1 /* rule11en */
-#define XSTORM_ETH_CONN_AG_CTX_RULE11EN_SHIFT               1
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED2_MASK            0x1 /* rule12en */
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED2_SHIFT           2
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED3_MASK            0x1 /* rule13en */
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED3_SHIFT           3
-#define XSTORM_ETH_CONN_AG_CTX_RULE14EN_MASK                0x1 /* rule14en */
-#define XSTORM_ETH_CONN_AG_CTX_RULE14EN_SHIFT               4
-#define XSTORM_ETH_CONN_AG_CTX_RULE15EN_MASK                0x1 /* rule15en */
-#define XSTORM_ETH_CONN_AG_CTX_RULE15EN_SHIFT               5
-#define XSTORM_ETH_CONN_AG_CTX_RULE16EN_MASK                0x1 /* rule16en */
-#define XSTORM_ETH_CONN_AG_CTX_RULE16EN_SHIFT               6
-#define XSTORM_ETH_CONN_AG_CTX_RULE17EN_MASK                0x1 /* rule17en */
-#define XSTORM_ETH_CONN_AG_CTX_RULE17EN_SHIFT               7
+#define XSTORM_ETH_CONN_AG_CTX_RULE10EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RULE10EN_SHIFT		0
+#define XSTORM_ETH_CONN_AG_CTX_RULE11EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RULE11EN_SHIFT		1
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED2_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED2_SHIFT	2
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED3_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED3_SHIFT	3
+#define XSTORM_ETH_CONN_AG_CTX_RULE14EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RULE14EN_SHIFT		4
+#define XSTORM_ETH_CONN_AG_CTX_RULE15EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RULE15EN_SHIFT		5
+#define XSTORM_ETH_CONN_AG_CTX_RULE16EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RULE16EN_SHIFT		6
+#define XSTORM_ETH_CONN_AG_CTX_RULE17EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RULE17EN_SHIFT		7
 	u8 flags13;
-#define XSTORM_ETH_CONN_AG_CTX_RULE18EN_MASK                0x1 /* rule18en */
-#define XSTORM_ETH_CONN_AG_CTX_RULE18EN_SHIFT               0
-#define XSTORM_ETH_CONN_AG_CTX_RULE19EN_MASK                0x1 /* rule19en */
-#define XSTORM_ETH_CONN_AG_CTX_RULE19EN_SHIFT               1
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED4_MASK            0x1 /* rule20en */
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED4_SHIFT           2
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED5_MASK            0x1 /* rule21en */
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED5_SHIFT           3
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED6_MASK            0x1 /* rule22en */
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED6_SHIFT           4
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED7_MASK            0x1 /* rule23en */
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED7_SHIFT           5
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED8_MASK            0x1 /* rule24en */
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED8_SHIFT           6
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED9_MASK            0x1 /* rule25en */
-#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED9_SHIFT           7
+#define XSTORM_ETH_CONN_AG_CTX_RULE18EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RULE18EN_SHIFT		0
+#define XSTORM_ETH_CONN_AG_CTX_RULE19EN_MASK		0x1
+#define XSTORM_ETH_CONN_AG_CTX_RULE19EN_SHIFT		1
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED4_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED4_SHIFT	2
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED5_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED5_SHIFT	3
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED6_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED6_SHIFT	4
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED7_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED7_SHIFT	5
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED8_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED8_SHIFT	6
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED9_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_A0_RESERVED9_SHIFT	7
 	u8 flags14;
-#define XSTORM_ETH_CONN_AG_CTX_EDPM_USE_EXT_HDR_MASK        0x1 /* bit16 */
-#define XSTORM_ETH_CONN_AG_CTX_EDPM_USE_EXT_HDR_SHIFT       0
-#define XSTORM_ETH_CONN_AG_CTX_EDPM_SEND_RAW_L3L4_MASK      0x1 /* bit17 */
-#define XSTORM_ETH_CONN_AG_CTX_EDPM_SEND_RAW_L3L4_SHIFT     1
-#define XSTORM_ETH_CONN_AG_CTX_EDPM_INBAND_PROP_HDR_MASK    0x1 /* bit18 */
-#define XSTORM_ETH_CONN_AG_CTX_EDPM_INBAND_PROP_HDR_SHIFT   2
-#define XSTORM_ETH_CONN_AG_CTX_EDPM_SEND_EXT_TUNNEL_MASK    0x1 /* bit19 */
-#define XSTORM_ETH_CONN_AG_CTX_EDPM_SEND_EXT_TUNNEL_SHIFT   3
-#define XSTORM_ETH_CONN_AG_CTX_L2_EDPM_ENABLE_MASK          0x1 /* bit20 */
-#define XSTORM_ETH_CONN_AG_CTX_L2_EDPM_ENABLE_SHIFT         4
-#define XSTORM_ETH_CONN_AG_CTX_ROCE_EDPM_ENABLE_MASK        0x1 /* bit21 */
-#define XSTORM_ETH_CONN_AG_CTX_ROCE_EDPM_ENABLE_SHIFT       5
-#define XSTORM_ETH_CONN_AG_CTX_TPH_ENABLE_MASK              0x3 /* cf23 */
-#define XSTORM_ETH_CONN_AG_CTX_TPH_ENABLE_SHIFT             6
-	u8	edpm_event_id /* byte2 */;
-	__le16	physical_q0 /* physical_q0 */;
-	__le16	word1 /* physical_q1 */;
-	__le16	edpm_num_bds /* physical_q2 */;
-	__le16	tx_bd_cons /* word3 */;
-	__le16	tx_bd_prod /* word4 */;
-	__le16	go_to_bd_cons /* word5 */;
-	__le16	conn_dpi /* conn_dpi */;
-	u8	byte3 /* byte3 */;
-	u8	byte4 /* byte4 */;
-	u8	byte5 /* byte5 */;
-	u8	byte6 /* byte6 */;
-	__le32	reg0 /* reg0 */;
-	__le32	reg1 /* reg1 */;
-	__le32	reg2 /* reg2 */;
-	__le32	reg3 /* reg3 */;
-	__le32	reg4 /* reg4 */;
-	__le32	reg5 /* cf_array0 */;
-	__le32	reg6 /* cf_array1 */;
-	__le16	word7 /* word7 */;
-	__le16	word8 /* word8 */;
-	__le16	word9 /* word9 */;
-	__le16	word10 /* word10 */;
-	__le32	reg7 /* reg7 */;
-	__le32	reg8 /* reg8 */;
-	__le32	reg9 /* reg9 */;
-	u8	byte7 /* byte7 */;
-	u8	byte8 /* byte8 */;
-	u8	byte9 /* byte9 */;
-	u8	byte10 /* byte10 */;
-	u8	byte11 /* byte11 */;
-	u8	byte12 /* byte12 */;
-	u8	byte13 /* byte13 */;
-	u8	byte14 /* byte14 */;
-	u8	byte15 /* byte15 */;
-	u8	byte16 /* byte16 */;
-	__le16	word11 /* word11 */;
-	__le32	reg10 /* reg10 */;
-	__le32	reg11 /* reg11 */;
-	__le32	reg12 /* reg12 */;
-	__le32	reg13 /* reg13 */;
-	__le32	reg14 /* reg14 */;
-	__le32	reg15 /* reg15 */;
-	__le32	reg16 /* reg16 */;
-	__le32	reg17 /* reg17 */;
-	__le32	reg18 /* reg18 */;
-	__le32	reg19 /* reg19 */;
-	__le16	word12 /* word12 */;
-	__le16	word13 /* word13 */;
-	__le16	word14 /* word14 */;
-	__le16	word15 /* word15 */;
+#define XSTORM_ETH_CONN_AG_CTX_EDPM_USE_EXT_HDR_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_EDPM_USE_EXT_HDR_SHIFT	0
+#define XSTORM_ETH_CONN_AG_CTX_EDPM_SEND_RAW_L3L4_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_EDPM_SEND_RAW_L3L4_SHIFT	1
+#define XSTORM_ETH_CONN_AG_CTX_EDPM_INBAND_PROP_HDR_MASK 0x1
+#define XSTORM_ETH_CONN_AG_CTX_EDPM_INBAND_PROP_HDR_SHIFT 2
+#define XSTORM_ETH_CONN_AG_CTX_EDPM_SEND_EXT_TUNNEL_MASK 0x1
+#define XSTORM_ETH_CONN_AG_CTX_EDPM_SEND_EXT_TUNNEL_SHIFT 3
+#define XSTORM_ETH_CONN_AG_CTX_L2_EDPM_ENABLE_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_L2_EDPM_ENABLE_SHIFT	4
+#define XSTORM_ETH_CONN_AG_CTX_ROCE_EDPM_ENABLE_MASK	0x1
+#define XSTORM_ETH_CONN_AG_CTX_ROCE_EDPM_ENABLE_SHIFT	5
+#define XSTORM_ETH_CONN_AG_CTX_TPH_ENABLE_MASK		0x3
+#define XSTORM_ETH_CONN_AG_CTX_TPH_ENABLE_SHIFT		6
+	u8 edpm_event_id;
+	__le16 physical_q0;
+	__le16 quota;
+	__le16 edpm_num_bds;
+	__le16 tx_bd_cons;
+	__le16 tx_bd_prod;
+	__le16 tx_class;
+	__le16 conn_dpi;
+	u8 byte3;
+	u8 byte4;
+	u8 byte5;
+	u8 byte6;
+	__le32 reg0;
+	__le32 reg1;
+	__le32 reg2;
+	__le32 reg3;
+	__le32 reg4;
+	__le32 reg5;
+	__le32 reg6;
+	__le16 word7;
+	__le16 word8;
+	__le16 word9;
+	__le16 word10;
+	__le32 reg7;
+	__le32 reg8;
+	__le32 reg9;
+	u8 byte7;
+	u8 byte8;
+	u8 byte9;
+	u8 byte10;
+	u8 byte11;
+	u8 byte12;
+	u8 byte13;
+	u8 byte14;
+	u8 byte15;
+	u8 byte16;
+	__le16 word11;
+	__le32 reg10;
+	__le32 reg11;
+	__le32 reg12;
+	__le32 reg13;
+	__le32 reg14;
+	__le32 reg15;
+	__le32 reg16;
+	__le32 reg17;
+	__le32 reg18;
+	__le32 reg19;
+	__le16 word12;
+	__le16 word13;
+	__le16 word14;
+	__le16 word15;
 };
 
 /* The eth storm context for the Ystorm */
@@ -2648,220 +2955,220 @@ struct ystorm_eth_conn_st_ctx {
 };
 
 struct ystorm_eth_conn_ag_ctx {
-	u8	byte0 /* cdu_validation */;
-	u8	byte1 /* state */;
-	u8	flags0;
-#define YSTORM_ETH_CONN_AG_CTX_BIT0_MASK                  0x1 /* exist_in_qm0 */
-#define YSTORM_ETH_CONN_AG_CTX_BIT0_SHIFT                 0
-#define YSTORM_ETH_CONN_AG_CTX_BIT1_MASK                  0x1 /* exist_in_qm1 */
-#define YSTORM_ETH_CONN_AG_CTX_BIT1_SHIFT                 1
-#define YSTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_MASK     0x3   /* cf0 */
-#define YSTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_SHIFT    2
-#define YSTORM_ETH_CONN_AG_CTX_PMD_TERMINATE_CF_MASK      0x3   /* cf1 */
-#define YSTORM_ETH_CONN_AG_CTX_PMD_TERMINATE_CF_SHIFT     4
-#define YSTORM_ETH_CONN_AG_CTX_CF2_MASK                   0x3   /* cf2 */
-#define YSTORM_ETH_CONN_AG_CTX_CF2_SHIFT                  6
+	u8 byte0;
+	u8 state;
+	u8 flags0;
+#define YSTORM_ETH_CONN_AG_CTX_BIT0_MASK		0x1
+#define YSTORM_ETH_CONN_AG_CTX_BIT0_SHIFT		0
+#define YSTORM_ETH_CONN_AG_CTX_BIT1_MASK		0x1
+#define YSTORM_ETH_CONN_AG_CTX_BIT1_SHIFT		1
+#define YSTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_MASK	0x3
+#define YSTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_SHIFT	2
+#define YSTORM_ETH_CONN_AG_CTX_PMD_TERMINATE_CF_MASK	0x3
+#define YSTORM_ETH_CONN_AG_CTX_PMD_TERMINATE_CF_SHIFT	4
+#define YSTORM_ETH_CONN_AG_CTX_CF2_MASK			0x3
+#define YSTORM_ETH_CONN_AG_CTX_CF2_SHIFT		6
 	u8 flags1;
-#define YSTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_EN_MASK  0x1   /* cf0en */
-#define YSTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_EN_SHIFT 0
-#define YSTORM_ETH_CONN_AG_CTX_PMD_TERMINATE_CF_EN_MASK   0x1   /* cf1en */
-#define YSTORM_ETH_CONN_AG_CTX_PMD_TERMINATE_CF_EN_SHIFT  1
-#define YSTORM_ETH_CONN_AG_CTX_CF2EN_MASK                 0x1   /* cf2en */
-#define YSTORM_ETH_CONN_AG_CTX_CF2EN_SHIFT                2
-#define YSTORM_ETH_CONN_AG_CTX_RULE0EN_MASK               0x1   /* rule0en */
-#define YSTORM_ETH_CONN_AG_CTX_RULE0EN_SHIFT              3
-#define YSTORM_ETH_CONN_AG_CTX_RULE1EN_MASK               0x1   /* rule1en */
-#define YSTORM_ETH_CONN_AG_CTX_RULE1EN_SHIFT              4
-#define YSTORM_ETH_CONN_AG_CTX_RULE2EN_MASK               0x1   /* rule2en */
-#define YSTORM_ETH_CONN_AG_CTX_RULE2EN_SHIFT              5
-#define YSTORM_ETH_CONN_AG_CTX_RULE3EN_MASK               0x1   /* rule3en */
-#define YSTORM_ETH_CONN_AG_CTX_RULE3EN_SHIFT              6
-#define YSTORM_ETH_CONN_AG_CTX_RULE4EN_MASK               0x1   /* rule4en */
-#define YSTORM_ETH_CONN_AG_CTX_RULE4EN_SHIFT              7
-	u8	byte2 /* byte2 */;
-	u8	byte3 /* byte3 */;
-	__le16	word0 /* word0 */;
-	__le32	terminate_spqe /* reg0 */;
-	__le32	reg1 /* reg1 */;
-	__le16	tx_bd_cons_upd /* word1 */;
-	__le16	word2 /* word2 */;
-	__le16	word3 /* word3 */;
-	__le16	word4 /* word4 */;
-	__le32	reg2 /* reg2 */;
-	__le32	reg3 /* reg3 */;
+#define YSTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_EN_MASK	0x1
+#define YSTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_EN_SHIFT	0
+#define YSTORM_ETH_CONN_AG_CTX_PMD_TERMINATE_CF_EN_MASK		0x1
+#define YSTORM_ETH_CONN_AG_CTX_PMD_TERMINATE_CF_EN_SHIFT	1
+#define YSTORM_ETH_CONN_AG_CTX_CF2EN_MASK			0x1
+#define YSTORM_ETH_CONN_AG_CTX_CF2EN_SHIFT			2
+#define YSTORM_ETH_CONN_AG_CTX_RULE0EN_MASK			0x1
+#define YSTORM_ETH_CONN_AG_CTX_RULE0EN_SHIFT			3
+#define YSTORM_ETH_CONN_AG_CTX_RULE1EN_MASK			0x1
+#define YSTORM_ETH_CONN_AG_CTX_RULE1EN_SHIFT			4
+#define YSTORM_ETH_CONN_AG_CTX_RULE2EN_MASK			0x1
+#define YSTORM_ETH_CONN_AG_CTX_RULE2EN_SHIFT			5
+#define YSTORM_ETH_CONN_AG_CTX_RULE3EN_MASK			0x1
+#define YSTORM_ETH_CONN_AG_CTX_RULE3EN_SHIFT			6
+#define YSTORM_ETH_CONN_AG_CTX_RULE4EN_MASK			0x1
+#define YSTORM_ETH_CONN_AG_CTX_RULE4EN_SHIFT			7
+	u8 tx_q0_int_coallecing_timeset;
+	u8 byte3;
+	__le16 word0;
+	__le32 terminate_spqe;
+	__le32 reg1;
+	__le16 tx_bd_cons_upd;
+	__le16 word2;
+	__le16 word3;
+	__le16 word4;
+	__le32 reg2;
+	__le32 reg3;
 };
 
 struct tstorm_eth_conn_ag_ctx {
-	u8	byte0 /* cdu_validation */;
-	u8	byte1 /* state */;
-	u8	flags0;
-#define TSTORM_ETH_CONN_AG_CTX_BIT0_MASK      0x1       /* exist_in_qm0 */
-#define TSTORM_ETH_CONN_AG_CTX_BIT0_SHIFT     0
-#define TSTORM_ETH_CONN_AG_CTX_BIT1_MASK      0x1       /* exist_in_qm1 */
-#define TSTORM_ETH_CONN_AG_CTX_BIT1_SHIFT     1
-#define TSTORM_ETH_CONN_AG_CTX_BIT2_MASK      0x1       /* bit2 */
-#define TSTORM_ETH_CONN_AG_CTX_BIT2_SHIFT     2
-#define TSTORM_ETH_CONN_AG_CTX_BIT3_MASK      0x1       /* bit3 */
-#define TSTORM_ETH_CONN_AG_CTX_BIT3_SHIFT     3
-#define TSTORM_ETH_CONN_AG_CTX_BIT4_MASK      0x1       /* bit4 */
-#define TSTORM_ETH_CONN_AG_CTX_BIT4_SHIFT     4
-#define TSTORM_ETH_CONN_AG_CTX_BIT5_MASK      0x1       /* bit5 */
-#define TSTORM_ETH_CONN_AG_CTX_BIT5_SHIFT     5
-#define TSTORM_ETH_CONN_AG_CTX_CF0_MASK       0x3       /* timer0cf */
-#define TSTORM_ETH_CONN_AG_CTX_CF0_SHIFT      6
+	u8 byte0;
+	u8 byte1;
+	u8 flags0;
+#define TSTORM_ETH_CONN_AG_CTX_BIT0_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_BIT0_SHIFT		0
+#define TSTORM_ETH_CONN_AG_CTX_BIT1_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_BIT1_SHIFT		1
+#define TSTORM_ETH_CONN_AG_CTX_BIT2_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_BIT2_SHIFT		2
+#define TSTORM_ETH_CONN_AG_CTX_BIT3_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_BIT3_SHIFT		3
+#define TSTORM_ETH_CONN_AG_CTX_BIT4_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_BIT4_SHIFT		4
+#define TSTORM_ETH_CONN_AG_CTX_BIT5_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_BIT5_SHIFT		5
+#define TSTORM_ETH_CONN_AG_CTX_CF0_MASK			0x3
+#define TSTORM_ETH_CONN_AG_CTX_CF0_SHIFT		6
 	u8 flags1;
-#define TSTORM_ETH_CONN_AG_CTX_CF1_MASK       0x3       /* timer1cf */
-#define TSTORM_ETH_CONN_AG_CTX_CF1_SHIFT      0
-#define TSTORM_ETH_CONN_AG_CTX_CF2_MASK       0x3       /* timer2cf */
-#define TSTORM_ETH_CONN_AG_CTX_CF2_SHIFT      2
-#define TSTORM_ETH_CONN_AG_CTX_CF3_MASK       0x3       /* timer_stop_all */
-#define TSTORM_ETH_CONN_AG_CTX_CF3_SHIFT      4
-#define TSTORM_ETH_CONN_AG_CTX_CF4_MASK       0x3       /* cf4 */
-#define TSTORM_ETH_CONN_AG_CTX_CF4_SHIFT      6
+#define TSTORM_ETH_CONN_AG_CTX_CF1_MASK			0x3
+#define TSTORM_ETH_CONN_AG_CTX_CF1_SHIFT		0
+#define TSTORM_ETH_CONN_AG_CTX_CF2_MASK			0x3
+#define TSTORM_ETH_CONN_AG_CTX_CF2_SHIFT		2
+#define TSTORM_ETH_CONN_AG_CTX_CF3_MASK			0x3
+#define TSTORM_ETH_CONN_AG_CTX_CF3_SHIFT		4
+#define TSTORM_ETH_CONN_AG_CTX_CF4_MASK			0x3
+#define TSTORM_ETH_CONN_AG_CTX_CF4_SHIFT		6
 	u8 flags2;
-#define TSTORM_ETH_CONN_AG_CTX_CF5_MASK       0x3       /* cf5 */
-#define TSTORM_ETH_CONN_AG_CTX_CF5_SHIFT      0
-#define TSTORM_ETH_CONN_AG_CTX_CF6_MASK       0x3       /* cf6 */
-#define TSTORM_ETH_CONN_AG_CTX_CF6_SHIFT      2
-#define TSTORM_ETH_CONN_AG_CTX_CF7_MASK       0x3       /* cf7 */
-#define TSTORM_ETH_CONN_AG_CTX_CF7_SHIFT      4
-#define TSTORM_ETH_CONN_AG_CTX_CF8_MASK       0x3       /* cf8 */
-#define TSTORM_ETH_CONN_AG_CTX_CF8_SHIFT      6
+#define TSTORM_ETH_CONN_AG_CTX_CF5_MASK			0x3
+#define TSTORM_ETH_CONN_AG_CTX_CF5_SHIFT		0
+#define TSTORM_ETH_CONN_AG_CTX_CF6_MASK			0x3
+#define TSTORM_ETH_CONN_AG_CTX_CF6_SHIFT		2
+#define TSTORM_ETH_CONN_AG_CTX_CF7_MASK			0x3
+#define TSTORM_ETH_CONN_AG_CTX_CF7_SHIFT		4
+#define TSTORM_ETH_CONN_AG_CTX_CF8_MASK			0x3
+#define TSTORM_ETH_CONN_AG_CTX_CF8_SHIFT		6
 	u8 flags3;
-#define TSTORM_ETH_CONN_AG_CTX_CF9_MASK       0x3       /* cf9 */
-#define TSTORM_ETH_CONN_AG_CTX_CF9_SHIFT      0
-#define TSTORM_ETH_CONN_AG_CTX_CF10_MASK      0x3       /* cf10 */
-#define TSTORM_ETH_CONN_AG_CTX_CF10_SHIFT     2
-#define TSTORM_ETH_CONN_AG_CTX_CF0EN_MASK     0x1       /* cf0en */
-#define TSTORM_ETH_CONN_AG_CTX_CF0EN_SHIFT    4
-#define TSTORM_ETH_CONN_AG_CTX_CF1EN_MASK     0x1       /* cf1en */
-#define TSTORM_ETH_CONN_AG_CTX_CF1EN_SHIFT    5
-#define TSTORM_ETH_CONN_AG_CTX_CF2EN_MASK     0x1       /* cf2en */
-#define TSTORM_ETH_CONN_AG_CTX_CF2EN_SHIFT    6
-#define TSTORM_ETH_CONN_AG_CTX_CF3EN_MASK     0x1       /* cf3en */
-#define TSTORM_ETH_CONN_AG_CTX_CF3EN_SHIFT    7
+#define TSTORM_ETH_CONN_AG_CTX_CF9_MASK			0x3
+#define TSTORM_ETH_CONN_AG_CTX_CF9_SHIFT		0
+#define TSTORM_ETH_CONN_AG_CTX_CF10_MASK		0x3
+#define TSTORM_ETH_CONN_AG_CTX_CF10_SHIFT		2
+#define TSTORM_ETH_CONN_AG_CTX_CF0EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_CF0EN_SHIFT		4
+#define TSTORM_ETH_CONN_AG_CTX_CF1EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_CF1EN_SHIFT		5
+#define TSTORM_ETH_CONN_AG_CTX_CF2EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_CF2EN_SHIFT		6
+#define TSTORM_ETH_CONN_AG_CTX_CF3EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_CF3EN_SHIFT		7
 	u8 flags4;
-#define TSTORM_ETH_CONN_AG_CTX_CF4EN_MASK     0x1       /* cf4en */
-#define TSTORM_ETH_CONN_AG_CTX_CF4EN_SHIFT    0
-#define TSTORM_ETH_CONN_AG_CTX_CF5EN_MASK     0x1       /* cf5en */
-#define TSTORM_ETH_CONN_AG_CTX_CF5EN_SHIFT    1
-#define TSTORM_ETH_CONN_AG_CTX_CF6EN_MASK     0x1       /* cf6en */
-#define TSTORM_ETH_CONN_AG_CTX_CF6EN_SHIFT    2
-#define TSTORM_ETH_CONN_AG_CTX_CF7EN_MASK     0x1       /* cf7en */
-#define TSTORM_ETH_CONN_AG_CTX_CF7EN_SHIFT    3
-#define TSTORM_ETH_CONN_AG_CTX_CF8EN_MASK     0x1       /* cf8en */
-#define TSTORM_ETH_CONN_AG_CTX_CF8EN_SHIFT    4
-#define TSTORM_ETH_CONN_AG_CTX_CF9EN_MASK     0x1       /* cf9en */
-#define TSTORM_ETH_CONN_AG_CTX_CF9EN_SHIFT    5
-#define TSTORM_ETH_CONN_AG_CTX_CF10EN_MASK    0x1       /* cf10en */
-#define TSTORM_ETH_CONN_AG_CTX_CF10EN_SHIFT   6
-#define TSTORM_ETH_CONN_AG_CTX_RULE0EN_MASK   0x1       /* rule0en */
-#define TSTORM_ETH_CONN_AG_CTX_RULE0EN_SHIFT  7
+#define TSTORM_ETH_CONN_AG_CTX_CF4EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_CF4EN_SHIFT		0
+#define TSTORM_ETH_CONN_AG_CTX_CF5EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_CF5EN_SHIFT		1
+#define TSTORM_ETH_CONN_AG_CTX_CF6EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_CF6EN_SHIFT		2
+#define TSTORM_ETH_CONN_AG_CTX_CF7EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_CF7EN_SHIFT		3
+#define TSTORM_ETH_CONN_AG_CTX_CF8EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_CF8EN_SHIFT		4
+#define TSTORM_ETH_CONN_AG_CTX_CF9EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_CF9EN_SHIFT		5
+#define TSTORM_ETH_CONN_AG_CTX_CF10EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_CF10EN_SHIFT		6
+#define TSTORM_ETH_CONN_AG_CTX_RULE0EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_RULE0EN_SHIFT		7
 	u8 flags5;
-#define TSTORM_ETH_CONN_AG_CTX_RULE1EN_MASK   0x1       /* rule1en */
-#define TSTORM_ETH_CONN_AG_CTX_RULE1EN_SHIFT  0
-#define TSTORM_ETH_CONN_AG_CTX_RULE2EN_MASK   0x1       /* rule2en */
-#define TSTORM_ETH_CONN_AG_CTX_RULE2EN_SHIFT  1
-#define TSTORM_ETH_CONN_AG_CTX_RULE3EN_MASK   0x1       /* rule3en */
-#define TSTORM_ETH_CONN_AG_CTX_RULE3EN_SHIFT  2
-#define TSTORM_ETH_CONN_AG_CTX_RULE4EN_MASK   0x1       /* rule4en */
-#define TSTORM_ETH_CONN_AG_CTX_RULE4EN_SHIFT  3
-#define TSTORM_ETH_CONN_AG_CTX_RULE5EN_MASK   0x1       /* rule5en */
-#define TSTORM_ETH_CONN_AG_CTX_RULE5EN_SHIFT  4
-#define TSTORM_ETH_CONN_AG_CTX_RX_BD_EN_MASK  0x1       /* rule6en */
-#define TSTORM_ETH_CONN_AG_CTX_RX_BD_EN_SHIFT 5
-#define TSTORM_ETH_CONN_AG_CTX_RULE7EN_MASK   0x1       /* rule7en */
-#define TSTORM_ETH_CONN_AG_CTX_RULE7EN_SHIFT  6
-#define TSTORM_ETH_CONN_AG_CTX_RULE8EN_MASK   0x1       /* rule8en */
-#define TSTORM_ETH_CONN_AG_CTX_RULE8EN_SHIFT  7
-	__le32	reg0 /* reg0 */;
-	__le32	reg1 /* reg1 */;
-	__le32	reg2 /* reg2 */;
-	__le32	reg3 /* reg3 */;
-	__le32	reg4 /* reg4 */;
-	__le32	reg5 /* reg5 */;
-	__le32	reg6 /* reg6 */;
-	__le32	reg7 /* reg7 */;
-	__le32	reg8 /* reg8 */;
-	u8	byte2 /* byte2 */;
-	u8	byte3 /* byte3 */;
-	__le16	rx_bd_cons /* word0 */;
-	u8	byte4 /* byte4 */;
-	u8	byte5 /* byte5 */;
-	__le16	rx_bd_prod /* word1 */;
-	__le16	word2 /* conn_dpi */;
-	__le16	word3 /* word3 */;
-	__le32	reg9 /* reg9 */;
-	__le32	reg10 /* reg10 */;
+#define TSTORM_ETH_CONN_AG_CTX_RULE1EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_RULE1EN_SHIFT		0
+#define TSTORM_ETH_CONN_AG_CTX_RULE2EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_RULE2EN_SHIFT		1
+#define TSTORM_ETH_CONN_AG_CTX_RULE3EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_RULE3EN_SHIFT		2
+#define TSTORM_ETH_CONN_AG_CTX_RULE4EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_RULE4EN_SHIFT		3
+#define TSTORM_ETH_CONN_AG_CTX_RULE5EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_RULE5EN_SHIFT		4
+#define TSTORM_ETH_CONN_AG_CTX_RX_BD_EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_RX_BD_EN_SHIFT		5
+#define TSTORM_ETH_CONN_AG_CTX_RULE7EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_RULE7EN_SHIFT		6
+#define TSTORM_ETH_CONN_AG_CTX_RULE8EN_MASK		0x1
+#define TSTORM_ETH_CONN_AG_CTX_RULE8EN_SHIFT		7
+	__le32 reg0;
+	__le32 reg1;
+	__le32 reg2;
+	__le32 reg3;
+	__le32 reg4;
+	__le32 reg5;
+	__le32 reg6;
+	__le32 reg7;
+	__le32 reg8;
+	u8 byte2;
+	u8 byte3;
+	__le16 rx_bd_cons;
+	u8 byte4;
+	u8 byte5;
+	__le16 rx_bd_prod;
+	__le16 word2;
+	__le16 word3;
+	__le32 reg9;
+	__le32 reg10;
 };
 
 struct ustorm_eth_conn_ag_ctx {
-	u8	byte0 /* cdu_validation */;
-	u8	byte1 /* state */;
-	u8	flags0;
-#define USTORM_ETH_CONN_AG_CTX_BIT0_MASK                  0x1 /* exist_in_qm0 */
-#define USTORM_ETH_CONN_AG_CTX_BIT0_SHIFT                 0
-#define USTORM_ETH_CONN_AG_CTX_BIT1_MASK                  0x1 /* exist_in_qm1 */
-#define USTORM_ETH_CONN_AG_CTX_BIT1_SHIFT                 1
-#define USTORM_ETH_CONN_AG_CTX_TX_PMD_TERMINATE_CF_MASK   0x3 /* timer0cf */
-#define USTORM_ETH_CONN_AG_CTX_TX_PMD_TERMINATE_CF_SHIFT  2
-#define USTORM_ETH_CONN_AG_CTX_RX_PMD_TERMINATE_CF_MASK   0x3 /* timer1cf */
-#define USTORM_ETH_CONN_AG_CTX_RX_PMD_TERMINATE_CF_SHIFT  4
-#define USTORM_ETH_CONN_AG_CTX_CF2_MASK                   0x3 /* timer2cf */
-#define USTORM_ETH_CONN_AG_CTX_CF2_SHIFT                  6
+	u8 byte0;
+	u8 byte1;
+	u8 flags0;
+#define USTORM_ETH_CONN_AG_CTX_BIT0_MASK			0x1
+#define USTORM_ETH_CONN_AG_CTX_BIT0_SHIFT			0
+#define USTORM_ETH_CONN_AG_CTX_BIT1_MASK			0x1
+#define USTORM_ETH_CONN_AG_CTX_BIT1_SHIFT			1
+#define USTORM_ETH_CONN_AG_CTX_TX_PMD_TERMINATE_CF_MASK		0x3
+#define USTORM_ETH_CONN_AG_CTX_TX_PMD_TERMINATE_CF_SHIFT	2
+#define USTORM_ETH_CONN_AG_CTX_RX_PMD_TERMINATE_CF_MASK		0x3
+#define USTORM_ETH_CONN_AG_CTX_RX_PMD_TERMINATE_CF_SHIFT	4
+#define USTORM_ETH_CONN_AG_CTX_CF2_MASK				0x3
+#define USTORM_ETH_CONN_AG_CTX_CF2_SHIFT			6
 	u8 flags1;
-#define USTORM_ETH_CONN_AG_CTX_CF3_MASK                 0x3 /* timer_stop_all */
-#define USTORM_ETH_CONN_AG_CTX_CF3_SHIFT                0
-#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_MASK           0x3 /* cf4 */
-#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_SHIFT          2
-#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_MASK           0x3 /* cf5 */
-#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_SHIFT          4
-#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_MASK   0x3 /* cf6 */
-#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_SHIFT  6
+#define USTORM_ETH_CONN_AG_CTX_CF3_MASK				0x3
+#define USTORM_ETH_CONN_AG_CTX_CF3_SHIFT			0
+#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_MASK			0x3
+#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_SHIFT			2
+#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_MASK			0x3
+#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_SHIFT			4
+#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_MASK		0x3
+#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_SHIFT		6
 	u8 flags2;
-#define USTORM_ETH_CONN_AG_CTX_TX_PMD_TERMINATE_CF_EN_MASK  0x1 /* cf0en */
-#define USTORM_ETH_CONN_AG_CTX_TX_PMD_TERMINATE_CF_EN_SHIFT 0
-#define USTORM_ETH_CONN_AG_CTX_RX_PMD_TERMINATE_CF_EN_MASK  0x1 /* cf1en */
-#define USTORM_ETH_CONN_AG_CTX_RX_PMD_TERMINATE_CF_EN_SHIFT 1
-#define USTORM_ETH_CONN_AG_CTX_CF2EN_MASK                   0x1 /* cf2en */
-#define USTORM_ETH_CONN_AG_CTX_CF2EN_SHIFT                  2
-#define USTORM_ETH_CONN_AG_CTX_CF3EN_MASK                   0x1 /* cf3en */
-#define USTORM_ETH_CONN_AG_CTX_CF3EN_SHIFT                  3
-#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_EN_MASK            0x1 /* cf4en */
-#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_EN_SHIFT           4
-#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_EN_MASK            0x1 /* cf5en */
-#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_EN_SHIFT           5
-#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_EN_MASK    0x1 /* cf6en */
-#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_EN_SHIFT   6
-#define USTORM_ETH_CONN_AG_CTX_RULE0EN_MASK                 0x1 /* rule0en */
-#define USTORM_ETH_CONN_AG_CTX_RULE0EN_SHIFT                7
+#define USTORM_ETH_CONN_AG_CTX_TX_PMD_TERMINATE_CF_EN_MASK	0x1
+#define USTORM_ETH_CONN_AG_CTX_TX_PMD_TERMINATE_CF_EN_SHIFT	0
+#define USTORM_ETH_CONN_AG_CTX_RX_PMD_TERMINATE_CF_EN_MASK	0x1
+#define USTORM_ETH_CONN_AG_CTX_RX_PMD_TERMINATE_CF_EN_SHIFT	1
+#define USTORM_ETH_CONN_AG_CTX_CF2EN_MASK			0x1
+#define USTORM_ETH_CONN_AG_CTX_CF2EN_SHIFT			2
+#define USTORM_ETH_CONN_AG_CTX_CF3EN_MASK			0x1
+#define USTORM_ETH_CONN_AG_CTX_CF3EN_SHIFT			3
+#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_EN_MASK		0x1
+#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_EN_SHIFT		4
+#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_EN_MASK		0x1
+#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_EN_SHIFT		5
+#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_EN_MASK	0x1
+#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_EN_SHIFT	6
+#define USTORM_ETH_CONN_AG_CTX_RULE0EN_MASK			0x1
+#define USTORM_ETH_CONN_AG_CTX_RULE0EN_SHIFT			7
 	u8 flags3;
-#define USTORM_ETH_CONN_AG_CTX_RULE1EN_MASK                 0x1 /* rule1en */
-#define USTORM_ETH_CONN_AG_CTX_RULE1EN_SHIFT                0
-#define USTORM_ETH_CONN_AG_CTX_RULE2EN_MASK                 0x1 /* rule2en */
-#define USTORM_ETH_CONN_AG_CTX_RULE2EN_SHIFT                1
-#define USTORM_ETH_CONN_AG_CTX_RULE3EN_MASK                 0x1 /* rule3en */
-#define USTORM_ETH_CONN_AG_CTX_RULE3EN_SHIFT                2
-#define USTORM_ETH_CONN_AG_CTX_RULE4EN_MASK                 0x1 /* rule4en */
-#define USTORM_ETH_CONN_AG_CTX_RULE4EN_SHIFT                3
-#define USTORM_ETH_CONN_AG_CTX_RULE5EN_MASK                 0x1 /* rule5en */
-#define USTORM_ETH_CONN_AG_CTX_RULE5EN_SHIFT                4
-#define USTORM_ETH_CONN_AG_CTX_RULE6EN_MASK                 0x1 /* rule6en */
-#define USTORM_ETH_CONN_AG_CTX_RULE6EN_SHIFT                5
-#define USTORM_ETH_CONN_AG_CTX_RULE7EN_MASK                 0x1 /* rule7en */
-#define USTORM_ETH_CONN_AG_CTX_RULE7EN_SHIFT                6
-#define USTORM_ETH_CONN_AG_CTX_RULE8EN_MASK                 0x1 /* rule8en */
-#define USTORM_ETH_CONN_AG_CTX_RULE8EN_SHIFT                7
-	u8	byte2 /* byte2 */;
-	u8	byte3 /* byte3 */;
-	__le16	word0 /* conn_dpi */;
-	__le16	tx_bd_cons /* word1 */;
-	__le32	reg0 /* reg0 */;
-	__le32	reg1 /* reg1 */;
-	__le32	reg2 /* reg2 */;
-	__le32	tx_int_coallecing_timeset /* reg3 */;
-	__le16	tx_drv_bd_cons /* word2 */;
-	__le16	rx_drv_cqe_cons /* word3 */;
+#define USTORM_ETH_CONN_AG_CTX_RULE1EN_MASK			0x1
+#define USTORM_ETH_CONN_AG_CTX_RULE1EN_SHIFT			0
+#define USTORM_ETH_CONN_AG_CTX_RULE2EN_MASK			0x1
+#define USTORM_ETH_CONN_AG_CTX_RULE2EN_SHIFT			1
+#define USTORM_ETH_CONN_AG_CTX_RULE3EN_MASK			0x1
+#define USTORM_ETH_CONN_AG_CTX_RULE3EN_SHIFT			2
+#define USTORM_ETH_CONN_AG_CTX_RULE4EN_MASK			0x1
+#define USTORM_ETH_CONN_AG_CTX_RULE4EN_SHIFT			3
+#define USTORM_ETH_CONN_AG_CTX_RULE5EN_MASK			0x1
+#define USTORM_ETH_CONN_AG_CTX_RULE5EN_SHIFT			4
+#define USTORM_ETH_CONN_AG_CTX_RULE6EN_MASK			0x1
+#define USTORM_ETH_CONN_AG_CTX_RULE6EN_SHIFT			5
+#define USTORM_ETH_CONN_AG_CTX_RULE7EN_MASK			0x1
+#define USTORM_ETH_CONN_AG_CTX_RULE7EN_SHIFT			6
+#define USTORM_ETH_CONN_AG_CTX_RULE8EN_MASK			0x1
+#define USTORM_ETH_CONN_AG_CTX_RULE8EN_SHIFT			7
+	u8 byte2;
+	u8 byte3;
+	__le16 word0;
+	__le16 tx_bd_cons;
+	__le32 reg0;
+	__le32 reg1;
+	__le32 reg2;
+	__le32 tx_int_coallecing_timeset;
+	__le16 tx_drv_bd_cons;
+	__le16 rx_drv_cqe_cons;
 };
 
 /* The eth storm context for the Ustorm */
@@ -2876,47 +3183,75 @@ struct mstorm_eth_conn_st_ctx {
 
 /* eth connection context */
 struct eth_conn_context {
-	struct tstorm_eth_conn_st_ctx	tstorm_st_context;
-	struct regpair			tstorm_st_padding[2];
-	struct pstorm_eth_conn_st_ctx	pstorm_st_context;
-	struct xstorm_eth_conn_st_ctx	xstorm_st_context;
-	struct xstorm_eth_conn_ag_ctx	xstorm_ag_context;
-	struct ystorm_eth_conn_st_ctx	ystorm_st_context;
-	struct ystorm_eth_conn_ag_ctx	ystorm_ag_context;
-	struct tstorm_eth_conn_ag_ctx	tstorm_ag_context;
-	struct ustorm_eth_conn_ag_ctx	ustorm_ag_context;
-	struct ustorm_eth_conn_st_ctx	ustorm_st_context;
-	struct mstorm_eth_conn_st_ctx	mstorm_st_context;
+	struct tstorm_eth_conn_st_ctx tstorm_st_context;
+	struct regpair tstorm_st_padding[2];
+	struct pstorm_eth_conn_st_ctx pstorm_st_context;
+	struct xstorm_eth_conn_st_ctx xstorm_st_context;
+	struct xstorm_eth_conn_ag_ctx xstorm_ag_context;
+	struct ystorm_eth_conn_st_ctx ystorm_st_context;
+	struct ystorm_eth_conn_ag_ctx ystorm_ag_context;
+	struct tstorm_eth_conn_ag_ctx tstorm_ag_context;
+	struct ustorm_eth_conn_ag_ctx ustorm_ag_context;
+	struct ustorm_eth_conn_st_ctx ustorm_st_context;
+	struct mstorm_eth_conn_st_ctx mstorm_st_context;
 };
 
+/* opcodes for the event ring */
+enum eth_event_opcode {
+	ETH_EVENT_UNUSED,
+	ETH_EVENT_VPORT_START,
+	ETH_EVENT_VPORT_UPDATE,
+	ETH_EVENT_VPORT_STOP,
+	ETH_EVENT_TX_QUEUE_START,
+	ETH_EVENT_TX_QUEUE_STOP,
+	ETH_EVENT_RX_QUEUE_START,
+	ETH_EVENT_RX_QUEUE_UPDATE,
+	ETH_EVENT_RX_QUEUE_STOP,
+	ETH_EVENT_FILTERS_UPDATE,
+	ETH_EVENT_RESERVED,
+	ETH_EVENT_RESERVED2,
+	ETH_EVENT_RESERVED3,
+	ETH_EVENT_RX_ADD_UDP_FILTER,
+	ETH_EVENT_RX_DELETE_UDP_FILTER,
+	ETH_EVENT_RESERVED4,
+	ETH_EVENT_RESERVED5,
+	MAX_ETH_EVENT_OPCODE
+};
+
+/* Classify rule types in E2/E3 */
 enum eth_filter_action {
+	ETH_FILTER_ACTION_UNUSED,
 	ETH_FILTER_ACTION_REMOVE,
 	ETH_FILTER_ACTION_ADD,
 	ETH_FILTER_ACTION_REMOVE_ALL,
 	MAX_ETH_FILTER_ACTION
 };
 
+/* Command for adding/removing a classification rule $$KEEP_ENDIANNESS$$ */
 struct eth_filter_cmd {
-	u8      type /* Filter Type (MAC/VLAN/Pair/VNI) */;
-	u8      vport_id /* the vport id */;
-	u8      action /* filter command action: add/remove/replace */;
-	u8      reserved0;
-	__le32  vni;
-	__le16  mac_lsb;
-	__le16  mac_mid;
-	__le16  mac_msb;
-	__le16  vlan_id;
+	u8 type;
+	u8 vport_id;
+	u8 action;
+	u8 reserved0;
+	__le32 vni;
+	__le16 mac_lsb;
+	__le16 mac_mid;
+	__le16 mac_msb;
+	__le16 vlan_id;
 };
 
+/*	$$KEEP_ENDIANNESS$$ */
 struct eth_filter_cmd_header {
-	u8      rx;
-	u8      tx;
-	u8      cmd_cnt;
-	u8      assert_on_error;
-	u8      reserved1[4];
+	u8 rx;
+	u8 tx;
+	u8 cmd_cnt;
+	u8 assert_on_error;
+	u8 reserved1[4];
 };
 
+/* Ethernet filter types: mac/vlan/pair */
 enum eth_filter_type {
+	ETH_FILTER_TYPE_UNUSED,
 	ETH_FILTER_TYPE_MAC,
 	ETH_FILTER_TYPE_VLAN,
 	ETH_FILTER_TYPE_PAIR,
@@ -2929,463 +3264,512 @@ enum eth_filter_type {
 	MAX_ETH_FILTER_TYPE
 };
 
+/* Ethernet Ramrod Command IDs */
 enum eth_ramrod_cmd_id {
 	ETH_RAMROD_UNUSED,
-	ETH_RAMROD_VPORT_START /* VPort Start Ramrod */,
-	ETH_RAMROD_VPORT_UPDATE /* VPort Update Ramrod */,
-	ETH_RAMROD_VPORT_STOP /* VPort Stop Ramrod */,
-	ETH_RAMROD_RX_QUEUE_START /* RX Queue Start Ramrod */,
-	ETH_RAMROD_RX_QUEUE_STOP /* RX Queue Stop Ramrod */,
-	ETH_RAMROD_TX_QUEUE_START /* TX Queue Start Ramrod */,
-	ETH_RAMROD_TX_QUEUE_STOP /* TX Queue Stop Ramrod */,
-	ETH_RAMROD_FILTERS_UPDATE /* Add or Remove Mac/Vlan/Pair filters */,
-	ETH_RAMROD_RX_QUEUE_UPDATE /* RX Queue Update Ramrod */,
-	ETH_RAMROD_RESERVED,
-	ETH_RAMROD_RESERVED2,
-	ETH_RAMROD_RESERVED3,
-	ETH_RAMROD_RESERVED4,
-	ETH_RAMROD_RESERVED5,
-	ETH_RAMROD_RESERVED6,
-	ETH_RAMROD_RESERVED7,
-	ETH_RAMROD_RESERVED8,
+	ETH_RAMROD_VPORT_START,
+	ETH_RAMROD_VPORT_UPDATE,
+	ETH_RAMROD_VPORT_STOP,
+	ETH_RAMROD_RX_QUEUE_START,
+	ETH_RAMROD_RX_QUEUE_STOP,
+	ETH_RAMROD_TX_QUEUE_START,
+	ETH_RAMROD_TX_QUEUE_STOP,
+	ETH_RAMROD_FILTERS_UPDATE,
+	ETH_RAMROD_RX_QUEUE_UPDATE,
+	ETH_RAMROD_RX_CREATE_OPENFLOW_ACTION,
+	ETH_RAMROD_RX_ADD_OPENFLOW_FILTER,
+	ETH_RAMROD_RX_DELETE_OPENFLOW_FILTER,
+	ETH_RAMROD_RX_ADD_UDP_FILTER,
+	ETH_RAMROD_RX_DELETE_UDP_FILTER,
+	ETH_RAMROD_RX_CREATE_GFT_ACTION,
+	ETH_RAMROD_GFT_UPDATE_FILTER,
 	MAX_ETH_RAMROD_CMD_ID
 };
 
+/* return code from eth sp ramrods */
+struct eth_return_code {
+	u8 value;
+#define ETH_RETURN_CODE_ERR_CODE_MASK	0x1F
+#define ETH_RETURN_CODE_ERR_CODE_SHIFT	0
+#define ETH_RETURN_CODE_RESERVED_MASK	0x3
+#define ETH_RETURN_CODE_RESERVED_SHIFT	5
+#define ETH_RETURN_CODE_RX_TX_MASK	0x1
+#define ETH_RETURN_CODE_RX_TX_SHIFT	7
+};
+
+/* What to do in case an error occurs */
 enum eth_tx_err {
-	ETH_TX_ERR_DROP /* Drop erronous packet. */,
+	ETH_TX_ERR_DROP,
 	ETH_TX_ERR_ASSERT_MALICIOUS,
 	MAX_ETH_TX_ERR
 };
 
+/* Array of the different error type behaviors */
 struct eth_tx_err_vals {
 	__le16 values;
-#define ETH_TX_ERR_VALS_ILLEGAL_VLAN_MODE_MASK            0x1
-#define ETH_TX_ERR_VALS_ILLEGAL_VLAN_MODE_SHIFT           0
-#define ETH_TX_ERR_VALS_PACKET_TOO_SMALL_MASK             0x1
-#define ETH_TX_ERR_VALS_PACKET_TOO_SMALL_SHIFT            1
-#define ETH_TX_ERR_VALS_ANTI_SPOOFING_ERR_MASK            0x1
-#define ETH_TX_ERR_VALS_ANTI_SPOOFING_ERR_SHIFT           2
-#define ETH_TX_ERR_VALS_ILLEGAL_INBAND_TAGS_MASK          0x1
-#define ETH_TX_ERR_VALS_ILLEGAL_INBAND_TAGS_SHIFT         3
-#define ETH_TX_ERR_VALS_VLAN_INSERTION_W_INBAND_TAG_MASK  0x1
-#define ETH_TX_ERR_VALS_VLAN_INSERTION_W_INBAND_TAG_SHIFT 4
-#define ETH_TX_ERR_VALS_MTU_VIOLATION_MASK                0x1
-#define ETH_TX_ERR_VALS_MTU_VIOLATION_SHIFT               5
-#define ETH_TX_ERR_VALS_ILLEGAL_CONTROL_FRAME_MASK        0x1
-#define ETH_TX_ERR_VALS_ILLEGAL_CONTROL_FRAME_SHIFT       6
-#define ETH_TX_ERR_VALS_RESERVED_MASK                     0x1FF
-#define ETH_TX_ERR_VALS_RESERVED_SHIFT                    7
-};
-
+#define ETH_TX_ERR_VALS_ILLEGAL_VLAN_MODE_MASK			0x1
+#define ETH_TX_ERR_VALS_ILLEGAL_VLAN_MODE_SHIFT			0
+#define ETH_TX_ERR_VALS_PACKET_TOO_SMALL_MASK			0x1
+#define ETH_TX_ERR_VALS_PACKET_TOO_SMALL_SHIFT			1
+#define ETH_TX_ERR_VALS_ANTI_SPOOFING_ERR_MASK			0x1
+#define ETH_TX_ERR_VALS_ANTI_SPOOFING_ERR_SHIFT			2
+#define ETH_TX_ERR_VALS_ILLEGAL_INBAND_TAGS_MASK		0x1
+#define ETH_TX_ERR_VALS_ILLEGAL_INBAND_TAGS_SHIFT		3
+#define ETH_TX_ERR_VALS_VLAN_INSERTION_W_INBAND_TAG_MASK	0x1
+#define ETH_TX_ERR_VALS_VLAN_INSERTION_W_INBAND_TAG_SHIFT	4
+#define ETH_TX_ERR_VALS_MTU_VIOLATION_MASK			0x1
+#define ETH_TX_ERR_VALS_MTU_VIOLATION_SHIFT			5
+#define ETH_TX_ERR_VALS_ILLEGAL_CONTROL_FRAME_MASK		0x1
+#define ETH_TX_ERR_VALS_ILLEGAL_CONTROL_FRAME_SHIFT		6
+#define ETH_TX_ERR_VALS_RESERVED_MASK				0x1FF
+#define ETH_TX_ERR_VALS_RESERVED_SHIFT				7
+};
+
+/* vport rss configuration data */
 struct eth_vport_rss_config {
 	__le16 capabilities;
-#define ETH_VPORT_RSS_CONFIG_IPV4_CAPABILITY_MASK	0x1
-#define ETH_VPORT_RSS_CONFIG_IPV4_CAPABILITY_SHIFT       0
-#define ETH_VPORT_RSS_CONFIG_IPV6_CAPABILITY_MASK	0x1
-#define ETH_VPORT_RSS_CONFIG_IPV6_CAPABILITY_SHIFT       1
-#define ETH_VPORT_RSS_CONFIG_IPV4_TCP_CAPABILITY_MASK    0x1
-#define ETH_VPORT_RSS_CONFIG_IPV4_TCP_CAPABILITY_SHIFT   2
-#define ETH_VPORT_RSS_CONFIG_IPV6_TCP_CAPABILITY_MASK    0x1
-#define ETH_VPORT_RSS_CONFIG_IPV6_TCP_CAPABILITY_SHIFT   3
-#define ETH_VPORT_RSS_CONFIG_IPV4_UDP_CAPABILITY_MASK    0x1
-#define ETH_VPORT_RSS_CONFIG_IPV4_UDP_CAPABILITY_SHIFT   4
-#define ETH_VPORT_RSS_CONFIG_IPV6_UDP_CAPABILITY_MASK    0x1
-#define ETH_VPORT_RSS_CONFIG_IPV6_UDP_CAPABILITY_SHIFT   5
-#define ETH_VPORT_RSS_CONFIG_EN_5_TUPLE_CAPABILITY_MASK  0x1
-#define ETH_VPORT_RSS_CONFIG_EN_5_TUPLE_CAPABILITY_SHIFT 6
-#define ETH_VPORT_RSS_CONFIG_RESERVED0_MASK	      0x1FF
-#define ETH_VPORT_RSS_CONFIG_RESERVED0_SHIFT	     7
-	u8      rss_id;
-	u8      rss_mode;
-	u8      update_rss_key;
-	u8      update_rss_ind_table;
-	u8      update_rss_capabilities;
-	u8      tbl_size;
-	__le32  reserved2[2];
-	__le16  indirection_table[ETH_RSS_IND_TABLE_ENTRIES_NUM];
-	__le32  rss_key[ETH_RSS_KEY_SIZE_REGS];
-	__le32  reserved3[2];
-};
-
+#define ETH_VPORT_RSS_CONFIG_IPV4_CAPABILITY_MASK		0x1
+#define ETH_VPORT_RSS_CONFIG_IPV4_CAPABILITY_SHIFT		0
+#define ETH_VPORT_RSS_CONFIG_IPV6_CAPABILITY_MASK		0x1
+#define ETH_VPORT_RSS_CONFIG_IPV6_CAPABILITY_SHIFT		1
+#define ETH_VPORT_RSS_CONFIG_IPV4_TCP_CAPABILITY_MASK		0x1
+#define ETH_VPORT_RSS_CONFIG_IPV4_TCP_CAPABILITY_SHIFT		2
+#define ETH_VPORT_RSS_CONFIG_IPV6_TCP_CAPABILITY_MASK		0x1
+#define ETH_VPORT_RSS_CONFIG_IPV6_TCP_CAPABILITY_SHIFT		3
+#define ETH_VPORT_RSS_CONFIG_IPV4_UDP_CAPABILITY_MASK		0x1
+#define ETH_VPORT_RSS_CONFIG_IPV4_UDP_CAPABILITY_SHIFT		4
+#define ETH_VPORT_RSS_CONFIG_IPV6_UDP_CAPABILITY_MASK		0x1
+#define ETH_VPORT_RSS_CONFIG_IPV6_UDP_CAPABILITY_SHIFT		5
+#define ETH_VPORT_RSS_CONFIG_EN_5_TUPLE_CAPABILITY_MASK		0x1
+#define ETH_VPORT_RSS_CONFIG_EN_5_TUPLE_CAPABILITY_SHIFT	6
+#define ETH_VPORT_RSS_CONFIG_RESERVED0_MASK			0x1FF
+#define ETH_VPORT_RSS_CONFIG_RESERVED0_SHIFT			7
+	u8 rss_id;
+	u8 rss_mode;
+	u8 update_rss_key;
+	u8 update_rss_ind_table;
+	u8 update_rss_capabilities;
+	u8 tbl_size;
+	__le32 reserved2[2];
+	__le16 indirection_table[ETH_RSS_IND_TABLE_ENTRIES_NUM];
+
+	__le32 rss_key[ETH_RSS_KEY_SIZE_REGS];
+	__le32 reserved3[2];
+};
+
+/* eth vport RSS mode */
 enum eth_vport_rss_mode {
 	ETH_VPORT_RSS_MODE_DISABLED,
 	ETH_VPORT_RSS_MODE_REGULAR,
 	MAX_ETH_VPORT_RSS_MODE
 };
 
+/* Command for setting classification flags for a vport $$KEEP_ENDIANNESS$$ */
 struct eth_vport_rx_mode {
 	__le16 state;
-#define ETH_VPORT_RX_MODE_UCAST_DROP_ALL_MASK	  0x1
-#define ETH_VPORT_RX_MODE_UCAST_DROP_ALL_SHIFT	 0
-#define ETH_VPORT_RX_MODE_UCAST_ACCEPT_ALL_MASK	0x1
-#define ETH_VPORT_RX_MODE_UCAST_ACCEPT_ALL_SHIFT       1
-#define ETH_VPORT_RX_MODE_UCAST_ACCEPT_UNMATCHED_MASK  0x1
-#define ETH_VPORT_RX_MODE_UCAST_ACCEPT_UNMATCHED_SHIFT 2
-#define ETH_VPORT_RX_MODE_MCAST_DROP_ALL_MASK	  0x1
-#define ETH_VPORT_RX_MODE_MCAST_DROP_ALL_SHIFT	 3
-#define ETH_VPORT_RX_MODE_MCAST_ACCEPT_ALL_MASK	0x1
-#define ETH_VPORT_RX_MODE_MCAST_ACCEPT_ALL_SHIFT       4
-#define ETH_VPORT_RX_MODE_BCAST_ACCEPT_ALL_MASK	0x1
-#define ETH_VPORT_RX_MODE_BCAST_ACCEPT_ALL_SHIFT       5
-#define ETH_VPORT_RX_MODE_RESERVED1_MASK	       0x3FF
-#define ETH_VPORT_RX_MODE_RESERVED1_SHIFT	      6
+#define ETH_VPORT_RX_MODE_UCAST_DROP_ALL_MASK		0x1
+#define ETH_VPORT_RX_MODE_UCAST_DROP_ALL_SHIFT		0
+#define ETH_VPORT_RX_MODE_UCAST_ACCEPT_ALL_MASK		0x1
+#define ETH_VPORT_RX_MODE_UCAST_ACCEPT_ALL_SHIFT	1
+#define ETH_VPORT_RX_MODE_UCAST_ACCEPT_UNMATCHED_MASK	0x1
+#define ETH_VPORT_RX_MODE_UCAST_ACCEPT_UNMATCHED_SHIFT	2
+#define ETH_VPORT_RX_MODE_MCAST_DROP_ALL_MASK		0x1
+#define ETH_VPORT_RX_MODE_MCAST_DROP_ALL_SHIFT		3
+#define ETH_VPORT_RX_MODE_MCAST_ACCEPT_ALL_MASK		0x1
+#define ETH_VPORT_RX_MODE_MCAST_ACCEPT_ALL_SHIFT	4
+#define ETH_VPORT_RX_MODE_BCAST_ACCEPT_ALL_MASK		0x1
+#define ETH_VPORT_RX_MODE_BCAST_ACCEPT_ALL_SHIFT	5
+#define ETH_VPORT_RX_MODE_RESERVED1_MASK		0x3FF
+#define ETH_VPORT_RX_MODE_RESERVED1_SHIFT		6
 	__le16 reserved2[3];
 };
 
+/* Command for setting tpa parameters */
 struct eth_vport_tpa_param {
-	u8	tpa_ipv4_en_flg;
-	u8	tpa_ipv6_en_flg;
-	u8	tpa_ipv4_tunn_en_flg;
-	u8	tpa_ipv6_tunn_en_flg;
-	u8	tpa_pkt_split_flg;
-	u8	tpa_hdr_data_split_flg;
-	u8	tpa_gro_consistent_flg;
-	u8	tpa_max_aggs_num;
-	u16	tpa_max_size;
-	u16	tpa_min_size_to_start;
-	u16	tpa_min_size_to_cont;
-	u8	max_buff_num;
-	u8	reserved;
+	u8 tpa_ipv4_en_flg;
+	u8 tpa_ipv6_en_flg;
+	u8 tpa_ipv4_tunn_en_flg;
+	u8 tpa_ipv6_tunn_en_flg;
+	u8 tpa_pkt_split_flg;
+	u8 tpa_hdr_data_split_flg;
+	u8 tpa_gro_consistent_flg;
+
+	u8 tpa_max_aggs_num;
+
+	__le16 tpa_max_size;
+	__le16 tpa_min_size_to_start;
+
+	__le16 tpa_min_size_to_cont;
+	u8 max_buff_num;
+	u8 reserved;
 };
 
+/* Command for setting classification flags for a vport $$KEEP_ENDIANNESS$$ */
 struct eth_vport_tx_mode {
 	__le16 state;
-#define ETH_VPORT_TX_MODE_UCAST_DROP_ALL_MASK    0x1
-#define ETH_VPORT_TX_MODE_UCAST_DROP_ALL_SHIFT   0
-#define ETH_VPORT_TX_MODE_UCAST_ACCEPT_ALL_MASK  0x1
-#define ETH_VPORT_TX_MODE_UCAST_ACCEPT_ALL_SHIFT 1
-#define ETH_VPORT_TX_MODE_MCAST_DROP_ALL_MASK    0x1
-#define ETH_VPORT_TX_MODE_MCAST_DROP_ALL_SHIFT   2
-#define ETH_VPORT_TX_MODE_MCAST_ACCEPT_ALL_MASK  0x1
-#define ETH_VPORT_TX_MODE_MCAST_ACCEPT_ALL_SHIFT 3
-#define ETH_VPORT_TX_MODE_BCAST_ACCEPT_ALL_MASK  0x1
-#define ETH_VPORT_TX_MODE_BCAST_ACCEPT_ALL_SHIFT 4
-#define ETH_VPORT_TX_MODE_RESERVED1_MASK	 0x7FF
-#define ETH_VPORT_TX_MODE_RESERVED1_SHIFT	5
+#define ETH_VPORT_TX_MODE_UCAST_DROP_ALL_MASK		0x1
+#define ETH_VPORT_TX_MODE_UCAST_DROP_ALL_SHIFT		0
+#define ETH_VPORT_TX_MODE_UCAST_ACCEPT_ALL_MASK		0x1
+#define ETH_VPORT_TX_MODE_UCAST_ACCEPT_ALL_SHIFT	1
+#define ETH_VPORT_TX_MODE_MCAST_DROP_ALL_MASK		0x1
+#define ETH_VPORT_TX_MODE_MCAST_DROP_ALL_SHIFT		2
+#define ETH_VPORT_TX_MODE_MCAST_ACCEPT_ALL_MASK		0x1
+#define ETH_VPORT_TX_MODE_MCAST_ACCEPT_ALL_SHIFT	3
+#define ETH_VPORT_TX_MODE_BCAST_ACCEPT_ALL_MASK		0x1
+#define ETH_VPORT_TX_MODE_BCAST_ACCEPT_ALL_SHIFT	4
+#define ETH_VPORT_TX_MODE_RESERVED1_MASK		0x7FF
+#define ETH_VPORT_TX_MODE_RESERVED1_SHIFT		5
 	__le16 reserved2[3];
 };
 
+/* Ramrod data for rx queue start ramrod */
 struct rx_queue_start_ramrod_data {
-	__le16	  rx_queue_id;
-	__le16	  num_of_pbl_pages;
-	__le16	  bd_max_bytes;
-	__le16	  sb_id;
-	u8	      sb_index;
-	u8	      vport_id;
-	u8	      default_rss_queue_flg;
-	u8	      complete_cqe_flg;
-	u8	      complete_event_flg;
-	u8	      stats_counter_id;
-	u8	      pin_context;
-	u8	      pxp_tph_valid_bd;
-	u8	      pxp_tph_valid_pkt;
-	u8	      pxp_st_hint;
-	__le16	  pxp_st_index;
-	u8		pmd_mode;
-	u8		notify_en;
-	u8		toggle_val;
-	u8		reserved[7];
-	__le16		reserved1;
-	struct regpair	cqe_pbl_addr;
-	struct regpair	bd_base;
-	struct regpair	reserved2;
+	__le16 rx_queue_id;
+	__le16 num_of_pbl_pages;
+	__le16 bd_max_bytes;
+	__le16 sb_id;
+	u8 sb_index;
+	u8 vport_id;
+	u8 default_rss_queue_flg;
+	u8 complete_cqe_flg;
+	u8 complete_event_flg;
+	u8 stats_counter_id;
+	u8 pin_context;
+	u8 pxp_tph_valid_bd;
+	u8 pxp_tph_valid_pkt;
+	u8 pxp_st_hint;
+
+	__le16 pxp_st_index;
+	u8 pmd_mode;
+
+	u8 notify_en;
+	u8 toggle_val;
+
+	u8 vf_rx_prod_index;
+
+	u8 reserved[6];
+	__le16 reserved1;
+	struct regpair cqe_pbl_addr;
+	struct regpair bd_base;
+	struct regpair reserved2;
 };
 
+/* Ramrod data for rx queue start ramrod */
 struct rx_queue_stop_ramrod_data {
-	__le16  rx_queue_id;
-	u8      complete_cqe_flg;
-	u8      complete_event_flg;
-	u8      vport_id;
-	u8      reserved[3];
+	__le16 rx_queue_id;
+	u8 complete_cqe_flg;
+	u8 complete_event_flg;
+	u8 vport_id;
+	u8 reserved[3];
 };
 
+/* Ramrod data for rx queue update ramrod */
 struct rx_queue_update_ramrod_data {
-	__le16	rx_queue_id;
-	u8	complete_cqe_flg;
-	u8	complete_event_flg;
-	u8	vport_id;
-	u8	reserved[4];
-	u8	reserved1;
-	u8	reserved2;
-	u8	reserved3;
-	__le16	reserved4;
-	__le16	reserved5;
+	__le16 rx_queue_id;
+	u8 complete_cqe_flg;
+	u8 complete_event_flg;
+	u8 vport_id;
+	u8 reserved[4];
+	u8 reserved1;
+	u8 reserved2;
+	u8 reserved3;
+	__le16 reserved4;
+	__le16 reserved5;
 	struct regpair reserved6;
 };
 
-struct tx_queue_start_ramrod_data {
-	__le16  sb_id;
-	u8      sb_index;
-	u8      vport_id;
-	u8      reserved0;
-	u8      stats_counter_id;
-	__le16  qm_pq_id;
-	u8      flags;
-#define TX_QUEUE_START_RAMROD_DATA_DISABLE_OPPORTUNISTIC_MASK  0x1
-#define TX_QUEUE_START_RAMROD_DATA_DISABLE_OPPORTUNISTIC_SHIFT 0
-#define TX_QUEUE_START_RAMROD_DATA_TEST_MODE_PKT_DUP_MASK      0x1
-#define TX_QUEUE_START_RAMROD_DATA_TEST_MODE_PKT_DUP_SHIFT     1
-#define TX_QUEUE_START_RAMROD_DATA_TEST_MODE_TX_DEST_MASK      0x1
-#define TX_QUEUE_START_RAMROD_DATA_TEST_MODE_TX_DEST_SHIFT     2
-#define TX_QUEUE_START_RAMROD_DATA_PMD_MODE_MASK               0x1
-#define TX_QUEUE_START_RAMROD_DATA_PMD_MODE_SHIFT              3
-#define TX_QUEUE_START_RAMROD_DATA_NOTIFY_EN_MASK              0x1
-#define TX_QUEUE_START_RAMROD_DATA_NOTIFY_EN_SHIFT             4
-#define TX_QUEUE_START_RAMROD_DATA_PIN_CONTEXT_MASK            0x1
-#define TX_QUEUE_START_RAMROD_DATA_PIN_CONTEXT_SHIFT           5
-#define TX_QUEUE_START_RAMROD_DATA_RESERVED1_MASK              0x3
-#define TX_QUEUE_START_RAMROD_DATA_RESERVED1_SHIFT             6
-	u8	pxp_st_hint;
-	u8	pxp_tph_valid_bd;
-	u8	pxp_tph_valid_pkt;
-	__le16	pxp_st_index;
-	__le16	comp_agg_size;
-	__le16	queue_zone_id;
-	__le16	test_dup_count;
-	__le16	pbl_size;
-	__le16	tx_queue_id;
-	struct regpair	pbl_base_addr;
-	struct regpair	bd_cons_address;
+/* Ramrod data for rx Add UDP Filter */
+struct rx_udp_filter_data {
+	__le16 action_icid;
+	__le16 vlan_id;
+	u8 ip_type;
+	u8 tenant_id_exists;
+	__le16 reserved1;
+	__le32 ip_dst_addr[4];
+	__le32 ip_src_addr[4];
+	__le16 udp_dst_port;
+	__le16 udp_src_port;
+	__le32 tenant_id;
 };
 
+/* Ramrod data for rx queue start ramrod */
+struct tx_queue_start_ramrod_data {
+	__le16 sb_id;
+	u8 sb_index;
+	u8 vport_id;
+	u8 reserved0;
+	u8 stats_counter_id;
+	__le16 qm_pq_id;
+	u8 flags;
+#define TX_QUEUE_START_RAMROD_DATA_DISABLE_OPPORTUNISTIC_MASK	0x1
+#define TX_QUEUE_START_RAMROD_DATA_DISABLE_OPPORTUNISTIC_SHIFT	0
+#define TX_QUEUE_START_RAMROD_DATA_TEST_MODE_PKT_DUP_MASK	0x1
+#define TX_QUEUE_START_RAMROD_DATA_TEST_MODE_PKT_DUP_SHIFT	1
+#define TX_QUEUE_START_RAMROD_DATA_TEST_MODE_TX_DEST_MASK	0x1
+#define TX_QUEUE_START_RAMROD_DATA_TEST_MODE_TX_DEST_SHIFT	2
+#define TX_QUEUE_START_RAMROD_DATA_PMD_MODE_MASK		0x1
+#define TX_QUEUE_START_RAMROD_DATA_PMD_MODE_SHIFT		3
+#define TX_QUEUE_START_RAMROD_DATA_NOTIFY_EN_MASK		0x1
+#define TX_QUEUE_START_RAMROD_DATA_NOTIFY_EN_SHIFT		4
+#define TX_QUEUE_START_RAMROD_DATA_PIN_CONTEXT_MASK		0x1
+#define TX_QUEUE_START_RAMROD_DATA_PIN_CONTEXT_SHIFT		5
+#define TX_QUEUE_START_RAMROD_DATA_RESERVED1_MASK		0x3
+#define TX_QUEUE_START_RAMROD_DATA_RESERVED1_SHIFT		6
+	u8 pxp_st_hint;
+	u8 pxp_tph_valid_bd;
+	u8 pxp_tph_valid_pkt;
+	__le16 pxp_st_index;
+	__le16 comp_agg_size;
+	__le16 queue_zone_id;
+	__le16 test_dup_count;
+	__le16 pbl_size;
+	__le16 tx_queue_id;
+
+	struct regpair pbl_base_addr;
+	struct regpair bd_cons_address;
+};
+
+/* Ramrod data for tx queue stop ramrod */
 struct tx_queue_stop_ramrod_data {
 	__le16 reserved[4];
 };
 
+/* Ramrod data for vport update ramrod */
 struct vport_filter_update_ramrod_data {
-	struct eth_filter_cmd_header    filter_cmd_hdr;
-	struct eth_filter_cmd	   filter_cmds[ETH_FILTER_RULES_COUNT];
+	struct eth_filter_cmd_header filter_cmd_hdr;
+	struct eth_filter_cmd filter_cmds[ETH_FILTER_RULES_COUNT];
 };
 
+/* Ramrod data for vport start ramrod */
 struct vport_start_ramrod_data {
-	u8			      vport_id;
-	u8			      sw_fid;
-	__le16			  mtu;
-	u8			      drop_ttl0_en;
-	u8			      inner_vlan_removal_en;
-	struct eth_vport_rx_mode	rx_mode;
-	struct eth_vport_tx_mode	tx_mode;
-	struct eth_vport_tpa_param      tpa_param;
-	__le16				default_vlan;
-	u8				tx_switching_en;
-	u8				anti_spoofing_en;
-	u8				default_vlan_en;
-	u8				handle_ptp_pkts;
-	u8				silent_vlan_removal_en;
-	u8				untagged;
-	struct eth_tx_err_vals		tx_err_behav;
-	u8				zero_placement_offset;
-	u8				reserved[7];
-};
-
+	u8 vport_id;
+	u8 sw_fid;
+	__le16 mtu;
+	u8 drop_ttl0_en;
+	u8 inner_vlan_removal_en;
+	struct eth_vport_rx_mode rx_mode;
+	struct eth_vport_tx_mode tx_mode;
+	struct eth_vport_tpa_param tpa_param;
+	__le16 default_vlan;
+	u8 tx_switching_en;
+	u8 anti_spoofing_en;
+
+	u8 default_vlan_en;
+
+	u8 handle_ptp_pkts;
+	u8 silent_vlan_removal_en;
+	u8 untagged;
+	struct eth_tx_err_vals tx_err_behav;
+
+	u8 zero_placement_offset;
+	u8 ctl_frame_mac_check_en;
+	u8 ctl_frame_ethtype_check_en;
+	u8 reserved[5];
+};
+
+/* Ramrod data for vport stop ramrod */
 struct vport_stop_ramrod_data {
-	u8      vport_id;
-	u8      reserved[7];
+	u8 vport_id;
+	u8 reserved[7];
 };
 
+/* Ramrod data for vport update ramrod */
 struct vport_update_ramrod_data_cmn {
-	u8	vport_id;
-	u8	update_rx_active_flg;
-	u8	rx_active_flg;
-	u8	update_tx_active_flg;
-	u8	tx_active_flg;
-	u8	update_rx_mode_flg;
-	u8	update_tx_mode_flg;
-	u8	update_approx_mcast_flg;
-	u8	update_rss_flg;
-	u8	update_inner_vlan_removal_en_flg;
-	u8	inner_vlan_removal_en;
-	u8	update_tpa_param_flg;
-	u8	update_tpa_en_flg;
-	u8	update_tx_switching_en_flg;
-	u8	tx_switching_en;
-	u8	update_anti_spoofing_en_flg;
-	u8	anti_spoofing_en;
-	u8	update_handle_ptp_pkts;
-	u8	handle_ptp_pkts;
-	u8	update_default_vlan_en_flg;
-	u8	default_vlan_en;
-	u8	update_default_vlan_flg;
-	__le16	default_vlan;
-	u8	update_accept_any_vlan_flg;
-	u8	accept_any_vlan;
-	u8	silent_vlan_removal_en;
-	u8	update_mtu_flg;
-	__le16	mtu;
-	u8	reserved[2];
+	u8 vport_id;
+	u8 update_rx_active_flg;
+	u8 rx_active_flg;
+	u8 update_tx_active_flg;
+	u8 tx_active_flg;
+	u8 update_rx_mode_flg;
+	u8 update_tx_mode_flg;
+	u8 update_approx_mcast_flg;
+
+	u8 update_rss_flg;
+	u8 update_inner_vlan_removal_en_flg;
+
+	u8 inner_vlan_removal_en;
+	u8 update_tpa_param_flg;
+	u8 update_tpa_en_flg;
+	u8 update_tx_switching_en_flg;
+
+	u8 tx_switching_en;
+	u8 update_anti_spoofing_en_flg;
+
+	u8 anti_spoofing_en;
+	u8 update_handle_ptp_pkts;
+
+	u8 handle_ptp_pkts;
+	u8 update_default_vlan_en_flg;
+
+	u8 default_vlan_en;
+
+	u8 update_default_vlan_flg;
+
+	__le16 default_vlan;
+	u8 update_accept_any_vlan_flg;
+
+	u8 accept_any_vlan;
+	u8 silent_vlan_removal_en;
+	u8 update_mtu_flg;
+
+	__le16 mtu;
+	u8 reserved[2];
 };
 
 struct vport_update_ramrod_mcast {
 	__le32 bins[ETH_MULTICAST_MAC_BINS_IN_REGS];
 };
 
+/* Ramrod data for vport update ramrod */
 struct vport_update_ramrod_data {
-	struct vport_update_ramrod_data_cmn     common;
-	struct eth_vport_rx_mode		rx_mode;
-	struct eth_vport_tx_mode		tx_mode;
-	struct eth_vport_tpa_param	      tpa_param;
-	struct vport_update_ramrod_mcast	approx_mcast;
-	struct eth_vport_rss_config	     rss_config;
+	struct vport_update_ramrod_data_cmn common;
+
+	struct eth_vport_rx_mode rx_mode;
+	struct eth_vport_tx_mode tx_mode;
+	struct eth_vport_tpa_param tpa_param;
+	struct vport_update_ramrod_mcast approx_mcast;
+	struct eth_vport_rss_config rss_config;
 };
 
-#define VF_MAX_STATIC 192       /* In case of K2 */
+#define VF_MAX_STATIC 192
 
-#define MCP_GLOB_PATH_MAX       2
-#define MCP_PORT_MAX            2       /* Global */
-#define MCP_GLOB_PORT_MAX       4       /* Global */
-#define MCP_GLOB_FUNC_MAX       16      /* Global */
+#define MCP_GLOB_PATH_MAX	2
+#define MCP_PORT_MAX		2
+#define MCP_GLOB_PORT_MAX	4
+#define MCP_GLOB_FUNC_MAX	16
 
-typedef u32 offsize_t;                  /* In DWORDS !!! */
 /* Offset from the beginning of the MCP scratchpad */
-#define OFFSIZE_OFFSET_SHIFT    0
-#define OFFSIZE_OFFSET_MASK     0x0000ffff
+#define OFFSIZE_OFFSET_SHIFT	0
+#define OFFSIZE_OFFSET_MASK	0x0000ffff
 /* Size of specific element (not the whole array if any) */
-#define OFFSIZE_SIZE_SHIFT      16
-#define OFFSIZE_SIZE_MASK       0xffff0000
+#define OFFSIZE_SIZE_SHIFT	16
+#define OFFSIZE_SIZE_MASK	0xffff0000
 
-/* SECTION_OFFSET is calculating the offset in bytes out of offsize */
-#define SECTION_OFFSET(_offsize)        ((((_offsize &		    \
-					    OFFSIZE_OFFSET_MASK) >> \
-					   OFFSIZE_OFFSET_SHIFT) << 2))
+#define SECTION_OFFSET(_offsize) ((((_offsize &			\
+				     OFFSIZE_OFFSET_MASK) >>	\
+				    OFFSIZE_OFFSET_SHIFT) << 2))
 
-/* QED_SECTION_SIZE is calculating the size in bytes out of offsize */
-#define QED_SECTION_SIZE(_offsize)              (((_offsize &		 \
-						   OFFSIZE_SIZE_MASK) >> \
-						  OFFSIZE_SIZE_SHIFT) << 2)
+#define QED_SECTION_SIZE(_offsize) (((_offsize &		\
+				      OFFSIZE_SIZE_MASK) >>	\
+				     OFFSIZE_SIZE_SHIFT) << 2)
 
-/* SECTION_ADDR returns the GRC addr of a section, given offsize and index
- * within section.
- */
-#define SECTION_ADDR(_offsize, idx)     (MCP_REG_SCRATCH +	    \
-					 SECTION_OFFSET(_offsize) + \
-					 (QED_SECTION_SIZE(_offsize) * idx))
+#define SECTION_ADDR(_offsize, idx) (MCP_REG_SCRATCH +			\
+				     SECTION_OFFSET(_offsize) +		\
+				     (QED_SECTION_SIZE(_offsize) * idx))
+
+#define SECTION_OFFSIZE_ADDR(_pub_base, _section)	\
+	(_pub_base + offsetof(struct mcp_public_data, sections[_section]))
 
-/* SECTION_OFFSIZE_ADDR returns the GRC addr to the offsize address.
- * Use offsetof, since the OFFSETUP collide with the firmware definition
- */
-#define SECTION_OFFSIZE_ADDR(_pub_base, _section) (_pub_base +		     \
-						   offsetof(struct	     \
-							    mcp_public_data, \
-							    sections[_section]))
 /* PHY configuration */
-struct pmm_phy_cfg {
-	u32	speed;
-#define PMM_SPEED_AUTONEG   0
-
-	u32	pause;  /* bitmask */
-#define PMM_PAUSE_NONE          0x0
-#define PMM_PAUSE_AUTONEG       0x1
-#define PMM_PAUSE_RX            0x2
-#define PMM_PAUSE_TX            0x4
-
-	u32	adv_speed;  /* Default should be the speed_cap_mask */
-	u32	loopback_mode;
-#define PMM_LOOPBACK_NONE               0
-#define PMM_LOOPBACK_INT_PHY    1
-#define PMM_LOOPBACK_EXT_PHY    2
-#define PMM_LOOPBACK_EXT                3
-#define PMM_LOOPBACK_MAC                4
-
-	/* features */
+struct eth_phy_cfg {
+	u32 speed;
+#define ETH_SPEED_AUTONEG	0
+#define ETH_SPEED_SMARTLINQ	0x8
+
+	u32 pause;
+#define ETH_PAUSE_NONE		0x0
+#define ETH_PAUSE_AUTONEG	0x1
+#define ETH_PAUSE_RX		0x2
+#define ETH_PAUSE_TX		0x4
+
+	u32 adv_speed;
+	u32 loopback_mode;
+#define ETH_LOOPBACK_NONE		(0)
+#define ETH_LOOPBACK_INT_PHY		(1)
+#define ETH_LOOPBACK_EXT_PHY		(2)
+#define ETH_LOOPBACK_EXT		(3)
+#define ETH_LOOPBACK_MAC		(4)
+
 	u32 feature_config_flags;
+#define ETH_EEE_MODE_ADV_LPI		(1 << 0)
 };
 
 struct port_mf_cfg {
-	u32	dynamic_cfg; /* device control channel */
-#define PORT_MF_CFG_OV_TAG_MASK              0x0000ffff
-#define PORT_MF_CFG_OV_TAG_SHIFT             0
-#define PORT_MF_CFG_OV_TAG_DEFAULT         PORT_MF_CFG_OV_TAG_MASK
-
-	u32	reserved[1];
-};
-
-/* DO NOT add new fields in the middle
- * MUST be synced with struct pmm_stats_map
- */
-struct pmm_stats {
-	u64	r64;    /* 0x00 (Offset 0x00 ) RX 64-byte frame counter*/
-	u64	r127;   /* 0x01 (Offset 0x08 ) RX 65 to 127 byte frame counter*/
-	u64	r255;
-	u64	r511;
-	u64	r1023;
-	u64	r1518;
-	u64	r1522;
-	u64	r2047;
-	u64	r4095;
-	u64	r9216;
-	u64	r16383;
-	u64	rfcs;   /* 0x0F (Offset 0x58 ) RX FCS error frame counter*/
-	u64	rxcf;   /* 0x10 (Offset 0x60 ) RX control frame counter*/
-	u64	rxpf;   /* 0x11 (Offset 0x68 ) RX pause frame counter*/
-	u64	rxpp;   /* 0x12 (Offset 0x70 ) RX PFC frame counter*/
-	u64	raln;   /* 0x16 (Offset 0x78 ) RX alignment error counter*/
-	u64	rfcr;   /* 0x19 (Offset 0x80 ) RX false carrier counter */
-	u64	rovr;   /* 0x1A (Offset 0x88 ) RX oversized frame counter*/
-	u64	rjbr;   /* 0x1B (Offset 0x90 ) RX jabber frame counter */
-	u64	rund;   /* 0x34 (Offset 0x98 ) RX undersized frame counter */
-	u64	rfrg;   /* 0x35 (Offset 0xa0 ) RX fragment counter */
-	u64	t64;    /* 0x40 (Offset 0xa8 ) TX 64-byte frame counter */
-	u64	t127;
-	u64	t255;
-	u64	t511;
-	u64	t1023;
-	u64	t1518;
-	u64	t2047;
-	u64	t4095;
-	u64	t9216;
-	u64	t16383;
-	u64	txpf;   /* 0x50 (Offset 0xf8 ) TX pause frame counter */
-	u64	txpp;   /* 0x51 (Offset 0x100) TX PFC frame counter */
-	u64	tlpiec;
-	u64	tncl;
-	u64	rbyte;  /* 0x3d (Offset 0x118) RX byte counter */
-	u64	rxuca;  /* 0x0c (Offset 0x120) RX UC frame counter */
-	u64	rxmca;  /* 0x0d (Offset 0x128) RX MC frame counter */
-	u64	rxbca;  /* 0x0e (Offset 0x130) RX BC frame counter */
-	u64	rxpok;
-	u64	tbyte;  /* 0x6f (Offset 0x140) TX byte counter */
-	u64	txuca;  /* 0x4d (Offset 0x148) TX UC frame counter */
-	u64	txmca;  /* 0x4e (Offset 0x150) TX MC frame counter */
-	u64	txbca;  /* 0x4f (Offset 0x158) TX BC frame counter */
-	u64	txcf;   /* 0x54 (Offset 0x160) TX control frame counter */
+	u32 dynamic_cfg;
+#define PORT_MF_CFG_OV_TAG_MASK		0x0000ffff
+#define PORT_MF_CFG_OV_TAG_SHIFT	0
+#define PORT_MF_CFG_OV_TAG_DEFAULT	PORT_MF_CFG_OV_TAG_MASK
+
+	u32 reserved[1];
+};
+
+struct eth_stats {
+	u64 r64;
+	u64 r127;
+	u64 r255;
+	u64 r511;
+	u64 r1023;
+	u64 r1518;
+	u64 r1522;
+	u64 r2047;
+	u64 r4095;
+	u64 r9216;
+	u64 r16383;
+	u64 rfcs;
+	u64 rxcf;
+	u64 rxpf;
+	u64 rxpp;
+	u64 raln;
+	u64 rfcr;
+	u64 rovr;
+	u64 rjbr;
+	u64 rund;
+	u64 rfrg;
+	u64 t64;
+	u64 t127;
+	u64 t255;
+	u64 t511;
+	u64 t1023;
+	u64 t1518;
+	u64 t2047;
+	u64 t4095;
+	u64 t9216;
+	u64 t16383;
+	u64 txpf;
+	u64 txpp;
+	u64 tlpiec;
+	u64 tncl;
+	u64 rbyte;
+	u64 rxuca;
+	u64 rxmca;
+	u64 rxbca;
+	u64 rxpok;
+	u64 tbyte;
+	u64 txuca;
+	u64 txmca;
+	u64 txbca;
+	u64 txcf;
 };
 
 struct brb_stats {
-	u64	brb_truncate[8];
-	u64	brb_discard[8];
+	u64 brb_truncate[8];
+	u64 brb_discard[8];
 };
 
 struct port_stats {
-	struct brb_stats	brb;
-	struct pmm_stats	pmm;
+	struct brb_stats brb;
+	struct eth_stats eth;
 };
 
-#define CMT_TEAM0 0
-#define CMT_TEAM1 1
-#define CMT_TEAM_MAX 2
-
 struct couple_mode_teaming {
 	u8 port_cmt[MCP_GLOB_PORT_MAX];
-#define PORT_CMT_IN_TEAM		BIT(0)
+#define PORT_CMT_IN_TEAM	(1 << 0)
 
-#define PORT_CMT_PORT_ROLE		BIT(1)
-#define PORT_CMT_PORT_INACTIVE      (0 << 1)
-#define PORT_CMT_PORT_ACTIVE		BIT(1)
+#define PORT_CMT_PORT_ROLE	(1 << 1)
+#define PORT_CMT_PORT_INACTIVE	(0 << 1)
+#define PORT_CMT_PORT_ACTIVE	(1 << 1)
 
-#define PORT_CMT_TEAM_MASK		BIT(2)
-#define PORT_CMT_TEAM0              (0 << 2)
-#define PORT_CMT_TEAM1			BIT(2)
+#define PORT_CMT_TEAM_MASK	(1 << 2)
+#define PORT_CMT_TEAM0		(0 << 2)
+#define PORT_CMT_TEAM1		(1 << 2)
 };
 
-/**************************************
-*     LLDP and DCBX HSI structures
-**************************************/
-#define LLDP_CHASSIS_ID_STAT_LEN 4
-#define LLDP_PORT_ID_STAT_LEN 4
-#define DCBX_MAX_APP_PROTOCOL           32
-#define MAX_SYSTEM_LLDP_TLV_DATA    32
+#define LLDP_CHASSIS_ID_STAT_LEN	4
+#define LLDP_PORT_ID_STAT_LEN		4
+#define DCBX_MAX_APP_PROTOCOL		32
+#define MAX_SYSTEM_LLDP_TLV_DATA	32
 
-enum lldp_agent_e {
+enum _lldp_agent {
 	LLDP_NEAREST_BRIDGE = 0,
 	LLDP_NEAREST_NON_TPMR_BRIDGE,
 	LLDP_NEAREST_CUSTOMER_BRIDGE,
@@ -3394,689 +3778,512 @@ enum lldp_agent_e {
 
 struct lldp_config_params_s {
 	u32 config;
-#define LLDP_CONFIG_TX_INTERVAL_MASK        0x000000ff
-#define LLDP_CONFIG_TX_INTERVAL_SHIFT       0
-#define LLDP_CONFIG_HOLD_MASK               0x00000f00
-#define LLDP_CONFIG_HOLD_SHIFT              8
-#define LLDP_CONFIG_MAX_CREDIT_MASK         0x0000f000
-#define LLDP_CONFIG_MAX_CREDIT_SHIFT        12
-#define LLDP_CONFIG_ENABLE_RX_MASK          0x40000000
-#define LLDP_CONFIG_ENABLE_RX_SHIFT         30
-#define LLDP_CONFIG_ENABLE_TX_MASK          0x80000000
-#define LLDP_CONFIG_ENABLE_TX_SHIFT         31
-	u32	local_chassis_id[LLDP_CHASSIS_ID_STAT_LEN];
-	u32	local_port_id[LLDP_PORT_ID_STAT_LEN];
+#define LLDP_CONFIG_TX_INTERVAL_MASK	0x000000ff
+#define LLDP_CONFIG_TX_INTERVAL_SHIFT	0
+#define LLDP_CONFIG_HOLD_MASK		0x00000f00
+#define LLDP_CONFIG_HOLD_SHIFT		8
+#define LLDP_CONFIG_MAX_CREDIT_MASK	0x0000f000
+#define LLDP_CONFIG_MAX_CREDIT_SHIFT	12
+#define LLDP_CONFIG_ENABLE_RX_MASK	0x40000000
+#define LLDP_CONFIG_ENABLE_RX_SHIFT	30
+#define LLDP_CONFIG_ENABLE_TX_MASK	0x80000000
+#define LLDP_CONFIG_ENABLE_TX_SHIFT	31
+	u32 local_chassis_id[LLDP_CHASSIS_ID_STAT_LEN];
+	u32 local_port_id[LLDP_PORT_ID_STAT_LEN];
 };
 
 struct lldp_status_params_s {
-	u32	prefix_seq_num;
-	u32	status; /* TBD */
-
-	/* Holds remote Chassis ID TLV header, subtype and 9B of payload. */
-	u32	peer_chassis_id[LLDP_CHASSIS_ID_STAT_LEN];
-
-	/* Holds remote Port ID TLV header, subtype and 9B of payload. */
-	u32	peer_port_id[LLDP_PORT_ID_STAT_LEN];
-	u32	suffix_seq_num;
+	u32 prefix_seq_num;
+	u32 status;
+	u32 peer_chassis_id[LLDP_CHASSIS_ID_STAT_LEN];
+	u32 peer_port_id[LLDP_PORT_ID_STAT_LEN];
+	u32 suffix_seq_num;
 };
 
 struct dcbx_ets_feature {
 	u32 flags;
-#define DCBX_ETS_ENABLED_MASK                   0x00000001
-#define DCBX_ETS_ENABLED_SHIFT                  0
-#define DCBX_ETS_WILLING_MASK                   0x00000002
-#define DCBX_ETS_WILLING_SHIFT                  1
-#define DCBX_ETS_ERROR_MASK                     0x00000004
-#define DCBX_ETS_ERROR_SHIFT                    2
-#define DCBX_ETS_CBS_MASK                       0x00000008
-#define DCBX_ETS_CBS_SHIFT                      3
-#define DCBX_ETS_MAX_TCS_MASK                   0x000000f0
-#define DCBX_ETS_MAX_TCS_SHIFT                  4
-	u32	pri_tc_tbl[1];
-#define DCBX_ISCSI_OOO_TC                       4
-#define NIG_ETS_ISCSI_OOO_CLIENT_OFFSET         (DCBX_ISCSI_OOO_TC + 1)
-	u32	tc_bw_tbl[2];
-	u32	tc_tsa_tbl[2];
-#define DCBX_ETS_TSA_STRICT                     0
-#define DCBX_ETS_TSA_CBS                        1
-#define DCBX_ETS_TSA_ETS                        2
+#define DCBX_ETS_ENABLED_MASK	0x00000001
+#define DCBX_ETS_ENABLED_SHIFT	0
+#define DCBX_ETS_WILLING_MASK	0x00000002
+#define DCBX_ETS_WILLING_SHIFT	1
+#define DCBX_ETS_ERROR_MASK	0x00000004
+#define DCBX_ETS_ERROR_SHIFT	2
+#define DCBX_ETS_CBS_MASK	0x00000008
+#define DCBX_ETS_CBS_SHIFT	3
+#define DCBX_ETS_MAX_TCS_MASK	0x000000f0
+#define DCBX_ETS_MAX_TCS_SHIFT	4
+#define DCBX_ISCSI_OOO_TC_MASK	0x00000f00
+#define DCBX_ISCSI_OOO_TC_SHIFT	8
+	u32 pri_tc_tbl[1];
+#define DCBX_ISCSI_OOO_TC	(4)
+
+#define NIG_ETS_ISCSI_OOO_CLIENT_OFFSET	(DCBX_ISCSI_OOO_TC + 1)
+#define DCBX_CEE_STRICT_PRIORITY	0xf
+	u32 tc_bw_tbl[2];
+	u32 tc_tsa_tbl[2];
+#define DCBX_ETS_TSA_STRICT	0
+#define DCBX_ETS_TSA_CBS	1
+#define DCBX_ETS_TSA_ETS	2
 };
 
 struct dcbx_app_priority_entry {
 	u32 entry;
-#define DCBX_APP_PRI_MAP_MASK       0x000000ff
-#define DCBX_APP_PRI_MAP_SHIFT      0
-#define DCBX_APP_PRI_0              0x01
-#define DCBX_APP_PRI_1              0x02
-#define DCBX_APP_PRI_2              0x04
-#define DCBX_APP_PRI_3              0x08
-#define DCBX_APP_PRI_4              0x10
-#define DCBX_APP_PRI_5              0x20
-#define DCBX_APP_PRI_6              0x40
-#define DCBX_APP_PRI_7              0x80
-#define DCBX_APP_SF_MASK            0x00000300
-#define DCBX_APP_SF_SHIFT           8
-#define DCBX_APP_SF_ETHTYPE         0
-#define DCBX_APP_SF_PORT            1
-#define DCBX_APP_PROTOCOL_ID_MASK   0xffff0000
-#define DCBX_APP_PROTOCOL_ID_SHIFT  16
-};
-
-/* FW structure in BE */
+#define DCBX_APP_PRI_MAP_MASK		0x000000ff
+#define DCBX_APP_PRI_MAP_SHIFT		0
+#define DCBX_APP_PRI_0			0x01
+#define DCBX_APP_PRI_1			0x02
+#define DCBX_APP_PRI_2			0x04
+#define DCBX_APP_PRI_3			0x08
+#define DCBX_APP_PRI_4			0x10
+#define DCBX_APP_PRI_5			0x20
+#define DCBX_APP_PRI_6			0x40
+#define DCBX_APP_PRI_7			0x80
+#define DCBX_APP_SF_MASK		0x00000300
+#define DCBX_APP_SF_SHIFT		8
+#define DCBX_APP_SF_ETHTYPE		0
+#define DCBX_APP_SF_PORT		1
+#define DCBX_APP_PROTOCOL_ID_MASK	0xffff0000
+#define DCBX_APP_PROTOCOL_ID_SHIFT	16
+};
+
 struct dcbx_app_priority_feature {
 	u32 flags;
-#define DCBX_APP_ENABLED_MASK           0x00000001
-#define DCBX_APP_ENABLED_SHIFT          0
-#define DCBX_APP_WILLING_MASK           0x00000002
-#define DCBX_APP_WILLING_SHIFT          1
-#define DCBX_APP_ERROR_MASK             0x00000004
-#define DCBX_APP_ERROR_SHIFT            2
-/* Not in use
- * #define DCBX_APP_DEFAULT_PRI_MASK       0x00000f00
- * #define DCBX_APP_DEFAULT_PRI_SHIFT      8
- */
-#define DCBX_APP_MAX_TCS_MASK           0x0000f000
-#define DCBX_APP_MAX_TCS_SHIFT          12
-#define DCBX_APP_NUM_ENTRIES_MASK       0x00ff0000
-#define DCBX_APP_NUM_ENTRIES_SHIFT      16
+#define DCBX_APP_ENABLED_MASK		0x00000001
+#define DCBX_APP_ENABLED_SHIFT		0
+#define DCBX_APP_WILLING_MASK		0x00000002
+#define DCBX_APP_WILLING_SHIFT		1
+#define DCBX_APP_ERROR_MASK		0x00000004
+#define DCBX_APP_ERROR_SHIFT		2
+#define DCBX_APP_MAX_TCS_MASK		0x0000f000
+#define DCBX_APP_MAX_TCS_SHIFT		12
+#define DCBX_APP_NUM_ENTRIES_MASK	0x00ff0000
+#define DCBX_APP_NUM_ENTRIES_SHIFT	16
 	struct dcbx_app_priority_entry app_pri_tbl[DCBX_MAX_APP_PROTOCOL];
 };
 
-/* FW structure in BE */
 struct dcbx_features {
-	/* PG feature */
 	struct dcbx_ets_feature ets;
+	u32 pfc;
+#define DCBX_PFC_PRI_EN_BITMAP_MASK	0x000000ff
+#define DCBX_PFC_PRI_EN_BITMAP_SHIFT	0
+#define DCBX_PFC_PRI_EN_BITMAP_PRI_0	0x01
+#define DCBX_PFC_PRI_EN_BITMAP_PRI_1	0x02
+#define DCBX_PFC_PRI_EN_BITMAP_PRI_2	0x04
+#define DCBX_PFC_PRI_EN_BITMAP_PRI_3	0x08
+#define DCBX_PFC_PRI_EN_BITMAP_PRI_4	0x10
+#define DCBX_PFC_PRI_EN_BITMAP_PRI_5	0x20
+#define DCBX_PFC_PRI_EN_BITMAP_PRI_6	0x40
+#define DCBX_PFC_PRI_EN_BITMAP_PRI_7	0x80
+
+#define DCBX_PFC_FLAGS_MASK		0x0000ff00
+#define DCBX_PFC_FLAGS_SHIFT		8
+#define DCBX_PFC_CAPS_MASK		0x00000f00
+#define DCBX_PFC_CAPS_SHIFT		8
+#define DCBX_PFC_MBC_MASK		0x00004000
+#define DCBX_PFC_MBC_SHIFT		14
+#define DCBX_PFC_WILLING_MASK		0x00008000
+#define DCBX_PFC_WILLING_SHIFT		15
+#define DCBX_PFC_ENABLED_MASK		0x00010000
+#define DCBX_PFC_ENABLED_SHIFT		16
+#define DCBX_PFC_ERROR_MASK		0x00020000
+#define DCBX_PFC_ERROR_SHIFT		17
 
-	/* PFC feature */
-	u32			pfc;
-#define DCBX_PFC_PRI_EN_BITMAP_MASK             0x000000ff
-#define DCBX_PFC_PRI_EN_BITMAP_SHIFT            0
-#define DCBX_PFC_PRI_EN_BITMAP_PRI_0            0x01
-#define DCBX_PFC_PRI_EN_BITMAP_PRI_1            0x02
-#define DCBX_PFC_PRI_EN_BITMAP_PRI_2            0x04
-#define DCBX_PFC_PRI_EN_BITMAP_PRI_3            0x08
-#define DCBX_PFC_PRI_EN_BITMAP_PRI_4            0x10
-#define DCBX_PFC_PRI_EN_BITMAP_PRI_5            0x20
-#define DCBX_PFC_PRI_EN_BITMAP_PRI_6            0x40
-#define DCBX_PFC_PRI_EN_BITMAP_PRI_7            0x80
-
-#define DCBX_PFC_FLAGS_MASK                     0x0000ff00
-#define DCBX_PFC_FLAGS_SHIFT                    8
-#define DCBX_PFC_CAPS_MASK                      0x00000f00
-#define DCBX_PFC_CAPS_SHIFT                     8
-#define DCBX_PFC_MBC_MASK                       0x00004000
-#define DCBX_PFC_MBC_SHIFT                      14
-#define DCBX_PFC_WILLING_MASK                   0x00008000
-#define DCBX_PFC_WILLING_SHIFT                  15
-#define DCBX_PFC_ENABLED_MASK                   0x00010000
-#define DCBX_PFC_ENABLED_SHIFT                  16
-#define DCBX_PFC_ERROR_MASK                     0x00020000
-#define DCBX_PFC_ERROR_SHIFT                    17
-
-	/* APP feature */
 	struct dcbx_app_priority_feature app;
 };
 
 struct dcbx_local_params {
 	u32 config;
-#define DCBX_CONFIG_VERSION_MASK            0x00000003
-#define DCBX_CONFIG_VERSION_SHIFT           0
-#define DCBX_CONFIG_VERSION_DISABLED        0
-#define DCBX_CONFIG_VERSION_IEEE            1
-#define DCBX_CONFIG_VERSION_CEE             2
+#define DCBX_CONFIG_VERSION_MASK	0x00000007
+#define DCBX_CONFIG_VERSION_SHIFT	0
+#define DCBX_CONFIG_VERSION_DISABLED	0
+#define DCBX_CONFIG_VERSION_IEEE	1
+#define DCBX_CONFIG_VERSION_CEE		2
+#define DCBX_CONFIG_VERSION_STATIC	4
 
-	u32			flags;
-	struct dcbx_features	features;
+	u32 flags;
+	struct dcbx_features features;
 };
 
 struct dcbx_mib {
-	u32	prefix_seq_num;
-	u32	flags;
-	struct dcbx_features	features;
-	u32			suffix_seq_num;
+	u32 prefix_seq_num;
+	u32 flags;
+	struct dcbx_features features;
+	u32 suffix_seq_num;
 };
 
 struct lldp_system_tlvs_buffer_s {
-	u16	valid;
-	u16	length;
-	u32	data[MAX_SYSTEM_LLDP_TLV_DATA];
+	u16 valid;
+	u16 length;
+	u32 data[MAX_SYSTEM_LLDP_TLV_DATA];
 };
 
-/**************************************/
-/*                                    */
-/*     P U B L I C      G L O B A L   */
-/*                                    */
-/**************************************/
-struct public_global {
-	u32				max_path;
-#define MAX_PATH_BIG_BEAR       2
-#define MAX_PATH_K2             1
-	u32				max_ports;
-#define MODE_1P 1
-#define MODE_2P 2
-#define MODE_3P 3
-#define MODE_4P 4
-	u32				debug_mb_offset;
-	u32				phymod_dbg_mb_offset;
-	struct couple_mode_teaming	cmt;
-	s32				internal_temperature;
-	u32				mfw_ver;
-	u32				running_bundle_id;
+struct dcb_dscp_map {
+	u32 flags;
+#define DCB_DSCP_ENABLE_MASK	0x1
+#define DCB_DSCP_ENABLE_SHIFT	0
+#define DCB_DSCP_ENABLE	1
+	u32 dscp_pri_map[8];
 };
 
-/**************************************/
-/*                                    */
-/*     P U B L I C      P A T H       */
-/*                                    */
-/**************************************/
+struct public_global {
+	u32 max_path;
+	u32 max_ports;
+	u32 debug_mb_offset;
+	u32 phymod_dbg_mb_offset;
+	struct couple_mode_teaming cmt;
+	s32 internal_temperature;
+	u32 mfw_ver;
+	u32 running_bundle_id;
+	s32 external_temperature;
+	u32 mdump_reason;
+};
 
-/****************************************************************************
-* Shared Memory 2 Region                                                   *
-****************************************************************************/
-/* The fw_flr_ack is actually built in the following way:                   */
-/* 8 bit:  PF ack                                                           */
-/* 128 bit: VF ack                                                           */
-/* 8 bit:  ios_dis_ack                                                      */
-/* In order to maintain endianity in the mailbox hsi, we want to keep using */
-/* u32. The fw must have the VF right after the PF since this is how it     */
-/* access arrays(it expects always the VF to reside after the PF, and that  */
-/* makes the calculation much easier for it. )                              */
-/* In order to answer both limitations, and keep the struct small, the code */
-/* will abuse the structure defined here to achieve the actual partition    */
-/* above                                                                    */
-/****************************************************************************/
 struct fw_flr_mb {
-	u32	aggint;
-	u32	opgen_addr;
-	u32	accum_ack;  /* 0..15:PF, 16..207:VF, 256..271:IOV_DIS */
-#define ACCUM_ACK_PF_BASE       0
-#define ACCUM_ACK_PF_SHIFT      0
-
-#define ACCUM_ACK_VF_BASE       8
-#define ACCUM_ACK_VF_SHIFT      3
-
-#define ACCUM_ACK_IOV_DIS_BASE  256
-#define ACCUM_ACK_IOV_DIS_SHIFT 8
+	u32 aggint;
+	u32 opgen_addr;
+	u32 accum_ack;
 };
 
 struct public_path {
-	struct fw_flr_mb	flr_mb;
-	u32			mcp_vf_disabled[VF_MAX_STATIC / 32];
-
-	u32			process_kill;
-#define PROCESS_KILL_COUNTER_MASK               0x0000ffff
-#define PROCESS_KILL_COUNTER_SHIFT              0
-#define PROCESS_KILL_GLOB_AEU_BIT_MASK          0xffff0000
-#define PROCESS_KILL_GLOB_AEU_BIT_SHIFT         16
+	struct fw_flr_mb flr_mb;
+	u32 mcp_vf_disabled[VF_MAX_STATIC / 32];
+
+	u32 process_kill;
+#define PROCESS_KILL_COUNTER_MASK	0x0000ffff
+#define PROCESS_KILL_COUNTER_SHIFT	0
+#define PROCESS_KILL_GLOB_AEU_BIT_MASK	0xffff0000
+#define PROCESS_KILL_GLOB_AEU_BIT_SHIFT	16
 #define GLOBAL_AEU_BIT(aeu_reg_id, aeu_bit) (aeu_reg_id * 32 + aeu_bit)
 };
 
-/**************************************/
-/*                                    */
-/*     P U B L I C      P O R T       */
-/*                                    */
-/**************************************/
-
-/****************************************************************************
-* Driver <-> FW Mailbox                                                    *
-****************************************************************************/
-
 struct public_port {
-	u32 validity_map;   /* 0x0 (4*2 = 0x8) */
-
-	/* validity bits */
-#define MCP_VALIDITY_PCI_CFG                    0x00100000
-#define MCP_VALIDITY_MB                         0x00200000
-#define MCP_VALIDITY_DEV_INFO                   0x00400000
-#define MCP_VALIDITY_RESERVED                   0x00000007
-
-	/* One licensing bit should be set */
-#define MCP_VALIDITY_LIC_KEY_IN_EFFECT_MASK     0x00000038
-#define MCP_VALIDITY_LIC_MANUF_KEY_IN_EFFECT    0x00000008
-#define MCP_VALIDITY_LIC_UPGRADE_KEY_IN_EFFECT  0x00000010
-#define MCP_VALIDITY_LIC_NO_KEY_IN_EFFECT       0x00000020
-
-	/* Active MFW */
-#define MCP_VALIDITY_ACTIVE_MFW_UNKNOWN         0x00000000
-#define MCP_VALIDITY_ACTIVE_MFW_MASK            0x000001c0
-#define MCP_VALIDITY_ACTIVE_MFW_NCSI            0x00000040
-#define MCP_VALIDITY_ACTIVE_MFW_NONE            0x000001c0
+	u32 validity_map;
 
 	u32 link_status;
-#define LINK_STATUS_LINK_UP \
-	0x00000001
-#define LINK_STATUS_SPEED_AND_DUPLEX_MASK                       0x0000001e
-#define LINK_STATUS_SPEED_AND_DUPLEX_1000THD		BIT(1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_1000TFD            (2 << 1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_10G                        (3 << 1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_20G                        (4 << 1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_40G                        (5 << 1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_50G                        (6 << 1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_100G                       (7 << 1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_25G                        (8 << 1)
-
-#define LINK_STATUS_AUTO_NEGOTIATE_ENABLED                      0x00000020
-
-#define LINK_STATUS_AUTO_NEGOTIATE_COMPLETE                     0x00000040
-#define LINK_STATUS_PARALLEL_DETECTION_USED                     0x00000080
-
-#define LINK_STATUS_PFC_ENABLED	\
-	0x00000100
-#define LINK_STATUS_LINK_PARTNER_1000TFD_CAPABLE        0x00000200
-#define LINK_STATUS_LINK_PARTNER_1000THD_CAPABLE        0x00000400
-#define LINK_STATUS_LINK_PARTNER_10G_CAPABLE            0x00000800
-#define LINK_STATUS_LINK_PARTNER_20G_CAPABLE            0x00001000
-#define LINK_STATUS_LINK_PARTNER_40G_CAPABLE            0x00002000
-#define LINK_STATUS_LINK_PARTNER_50G_CAPABLE            0x00004000
-#define LINK_STATUS_LINK_PARTNER_100G_CAPABLE           0x00008000
-#define LINK_STATUS_LINK_PARTNER_25G_CAPABLE            0x00010000
-
-#define LINK_STATUS_LINK_PARTNER_FLOW_CONTROL_MASK      0x000C0000
-#define LINK_STATUS_LINK_PARTNER_NOT_PAUSE_CAPABLE      (0 << 18)
-#define LINK_STATUS_LINK_PARTNER_SYMMETRIC_PAUSE	BIT(18)
-#define LINK_STATUS_LINK_PARTNER_ASYMMETRIC_PAUSE       (2 << 18)
-#define LINK_STATUS_LINK_PARTNER_BOTH_PAUSE                     (3 << 18)
-
-#define LINK_STATUS_SFP_TX_FAULT \
-	0x00100000
-#define LINK_STATUS_TX_FLOW_CONTROL_ENABLED                     0x00200000
-#define LINK_STATUS_RX_FLOW_CONTROL_ENABLED                     0x00400000
-
-	u32			link_status1;
-	u32			ext_phy_fw_version;
-	u32			drv_phy_cfg_addr;
-
-	u32			port_stx;
-
-	u32			stat_nig_timer;
-
-	struct port_mf_cfg	port_mf_config;
-	struct port_stats	stats;
-
-	u32			media_type;
-#define MEDIA_UNSPECIFIED       0x0
-#define MEDIA_SFPP_10G_FIBER    0x1
-#define MEDIA_XFP_FIBER         0x2
-#define MEDIA_DA_TWINAX         0x3
-#define MEDIA_BASE_T            0x4
-#define MEDIA_SFP_1G_FIBER      0x5
-#define MEDIA_KR                0xf0
-#define MEDIA_NOT_PRESENT       0xff
+#define LINK_STATUS_LINK_UP			0x00000001
+#define LINK_STATUS_SPEED_AND_DUPLEX_MASK	0x0000001e
+#define LINK_STATUS_SPEED_AND_DUPLEX_1000THD	(1 << 1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_1000TFD	(2 << 1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_10G	(3 << 1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_20G	(4 << 1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_40G	(5 << 1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_50G	(6 << 1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_100G	(7 << 1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_25G	(8 << 1)
+
+#define LINK_STATUS_AUTO_NEGOTIATE_ENABLED	0x00000020
+
+#define LINK_STATUS_AUTO_NEGOTIATE_COMPLETE	0x00000040
+#define LINK_STATUS_PARALLEL_DETECTION_USED	0x00000080
+
+#define LINK_STATUS_PFC_ENABLED				0x00000100
+#define LINK_STATUS_LINK_PARTNER_1000TFD_CAPABLE 0x00000200
+#define LINK_STATUS_LINK_PARTNER_1000THD_CAPABLE 0x00000400
+#define LINK_STATUS_LINK_PARTNER_10G_CAPABLE		0x00000800
+#define LINK_STATUS_LINK_PARTNER_20G_CAPABLE		0x00001000
+#define LINK_STATUS_LINK_PARTNER_40G_CAPABLE		0x00002000
+#define LINK_STATUS_LINK_PARTNER_50G_CAPABLE		0x00004000
+#define LINK_STATUS_LINK_PARTNER_100G_CAPABLE		0x00008000
+#define LINK_STATUS_LINK_PARTNER_25G_CAPABLE		0x00010000
+
+#define LINK_STATUS_LINK_PARTNER_FLOW_CONTROL_MASK	0x000C0000
+#define LINK_STATUS_LINK_PARTNER_NOT_PAUSE_CAPABLE	(0 << 18)
+#define LINK_STATUS_LINK_PARTNER_SYMMETRIC_PAUSE	(1 << 18)
+#define LINK_STATUS_LINK_PARTNER_ASYMMETRIC_PAUSE	(2 << 18)
+#define LINK_STATUS_LINK_PARTNER_BOTH_PAUSE		(3 << 18)
+
+#define LINK_STATUS_SFP_TX_FAULT			0x00100000
+#define LINK_STATUS_TX_FLOW_CONTROL_ENABLED		0x00200000
+#define LINK_STATUS_RX_FLOW_CONTROL_ENABLED		0x00400000
+#define LINK_STATUS_RX_SIGNAL_PRESENT			0x00800000
+#define LINK_STATUS_MAC_LOCAL_FAULT			0x01000000
+#define LINK_STATUS_MAC_REMOTE_FAULT			0x02000000
+#define LINK_STATUS_UNSUPPORTED_SPD_REQ			0x04000000
+
+	u32 link_status1;
+	u32 ext_phy_fw_version;
+	u32 drv_phy_cfg_addr;
+
+	u32 port_stx;
+
+	u32 stat_nig_timer;
+
+	struct port_mf_cfg port_mf_config;
+	struct port_stats stats;
+
+	u32 media_type;
+#define MEDIA_UNSPECIFIED	0x0
+#define MEDIA_SFPP_10G_FIBER	0x1
+#define MEDIA_XFP_FIBER		0x2
+#define MEDIA_DA_TWINAX		0x3
+#define MEDIA_BASE_T		0x4
+#define MEDIA_SFP_1G_FIBER	0x5
+#define MEDIA_MODULE_FIBER	0x6
+#define MEDIA_KR		0xf0
+#define MEDIA_NOT_PRESENT	0xff
 
 	u32 lfa_status;
-#define LFA_LINK_FLAP_REASON_OFFSET             0
-#define LFA_LINK_FLAP_REASON_MASK               0x000000ff
-#define LFA_NO_REASON                                   (0 << 0)
-#define LFA_LINK_DOWN					BIT(0)
-#define LFA_FORCE_INIT                                  BIT(1)
-#define LFA_LOOPBACK_MISMATCH                           BIT(2)
-#define LFA_SPEED_MISMATCH                              BIT(3)
-#define LFA_FLOW_CTRL_MISMATCH                          BIT(4)
-#define LFA_ADV_SPEED_MISMATCH                          BIT(5)
-#define LINK_FLAP_AVOIDANCE_COUNT_OFFSET        8
-#define LINK_FLAP_AVOIDANCE_COUNT_MASK          0x0000ff00
-#define LINK_FLAP_COUNT_OFFSET                  16
-#define LINK_FLAP_COUNT_MASK                    0x00ff0000
-
-	u32					link_change_count;
-
-	/* LLDP params */
-	struct lldp_config_params_s		lldp_config_params[
-		LLDP_MAX_LLDP_AGENTS];
-	struct lldp_status_params_s		lldp_status_params[
-		LLDP_MAX_LLDP_AGENTS];
-	struct lldp_system_tlvs_buffer_s	system_lldp_tlvs_buf;
+	u32 link_change_count;
+
+	struct lldp_config_params_s lldp_config_params[LLDP_MAX_LLDP_AGENTS];
+	struct lldp_status_params_s lldp_status_params[LLDP_MAX_LLDP_AGENTS];
+	struct lldp_system_tlvs_buffer_s system_lldp_tlvs_buf;
 
 	/* DCBX related MIB */
-	struct dcbx_local_params		local_admin_dcbx_mib;
-	struct dcbx_mib				remote_dcbx_mib;
-	struct dcbx_mib				operational_dcbx_mib;
+	struct dcbx_local_params local_admin_dcbx_mib;
+	struct dcbx_mib remote_dcbx_mib;
+	struct dcbx_mib operational_dcbx_mib;
 
-	u32					fc_npiv_nvram_tbl_addr;
-	u32					fc_npiv_nvram_tbl_size;
-	u32					transceiver_data;
-#define PMM_TRANSCEIVER_STATE_MASK		0x000000FF
-#define PMM_TRANSCEIVER_STATE_SHIFT		0x00000000
-#define PMM_TRANSCEIVER_STATE_PRESENT		0x00000001
-};
+	u32 reserved[2];
+	u32 transceiver_data;
+#define ETH_TRANSCEIVER_STATE_MASK	0x000000FF
+#define ETH_TRANSCEIVER_STATE_SHIFT	0x00000000
+#define ETH_TRANSCEIVER_STATE_UNPLUGGED	0x00000000
+#define ETH_TRANSCEIVER_STATE_PRESENT	0x00000001
+#define ETH_TRANSCEIVER_STATE_VALID	0x00000003
+#define ETH_TRANSCEIVER_STATE_UPDATING	0x00000008
 
-/**************************************/
-/*                                    */
-/*     P U B L I C      F U N C       */
-/*                                    */
-/**************************************/
+	u32 wol_info;
+	u32 wol_pkt_len;
+	u32 wol_pkt_details;
+	struct dcb_dscp_map dcb_dscp_map;
+};
 
 struct public_func {
-	u32	iscsi_boot_signature;
-	u32	iscsi_boot_block_offset;
-
-	u32	mtu_size;
-	u32	c2s_pcp_map_lower;
-	u32	c2s_pcp_map_upper;
-	u32	c2s_pcp_map_default;
-	u32	reserved[4];
-
-	u32	config;
-
-	/* E/R/I/D */
-	/* function 0 of each port cannot be hidden */
-#define FUNC_MF_CFG_FUNC_HIDE                   0x00000001
-#define FUNC_MF_CFG_PAUSE_ON_HOST_RING          0x00000002
-#define FUNC_MF_CFG_PAUSE_ON_HOST_RING_SHIFT    0x00000001
-
-#define FUNC_MF_CFG_PROTOCOL_MASK               0x000000f0
-#define FUNC_MF_CFG_PROTOCOL_SHIFT              4
-#define FUNC_MF_CFG_PROTOCOL_ETHERNET           0x00000000
-#define FUNC_MF_CFG_PROTOCOL_ISCSI              0x00000010
-#define FUNC_MF_CFG_PROTOCOL_FCOE               0x00000020
-#define FUNC_MF_CFG_PROTOCOL_ROCE               0x00000030
-#define FUNC_MF_CFG_PROTOCOL_MAX                0x00000030
-
-	/* MINBW, MAXBW */
-	/* value range - 0..100, increments in 1 %  */
-#define FUNC_MF_CFG_MIN_BW_MASK                 0x0000ff00
-#define FUNC_MF_CFG_MIN_BW_SHIFT                8
-#define FUNC_MF_CFG_MIN_BW_DEFAULT              0x00000000
-#define FUNC_MF_CFG_MAX_BW_MASK                 0x00ff0000
-#define FUNC_MF_CFG_MAX_BW_SHIFT                16
-#define FUNC_MF_CFG_MAX_BW_DEFAULT              0x00640000
-
-	u32	status;
-#define FUNC_STATUS_VLINK_DOWN                  0x00000001
-
-	u32	mac_upper;  /* MAC */
-#define FUNC_MF_CFG_UPPERMAC_MASK               0x0000ffff
-#define FUNC_MF_CFG_UPPERMAC_SHIFT              0
-#define FUNC_MF_CFG_UPPERMAC_DEFAULT            FUNC_MF_CFG_UPPERMAC_MASK
-	u32	mac_lower;
-#define FUNC_MF_CFG_LOWERMAC_DEFAULT            0xffffffff
-
-	u32	fcoe_wwn_port_name_upper;
-	u32	fcoe_wwn_port_name_lower;
-
-	u32	fcoe_wwn_node_name_upper;
-	u32	fcoe_wwn_node_name_lower;
-
-	u32	ovlan_stag; /* tags */
-#define FUNC_MF_CFG_OV_STAG_MASK              0x0000ffff
-#define FUNC_MF_CFG_OV_STAG_SHIFT             0
-#define FUNC_MF_CFG_OV_STAG_DEFAULT           FUNC_MF_CFG_OV_STAG_MASK
-
-	u32	pf_allocation;  /* vf per pf */
-
-	u32	preserve_data;  /* Will be used bt CCM */
-
-	u32	driver_last_activity_ts;
-
-	u32	drv_ack_vf_disabled[VF_MAX_STATIC / 32]; /* 0x0044 */
-
-	u32	drv_id;
-#define DRV_ID_PDA_COMP_VER_MASK        0x0000ffff
-#define DRV_ID_PDA_COMP_VER_SHIFT       0
-
-#define DRV_ID_MCP_HSI_VER_MASK         0x00ff0000
-#define DRV_ID_MCP_HSI_VER_SHIFT        16
-#define DRV_ID_MCP_HSI_VER_CURRENT	BIT(DRV_ID_MCP_HSI_VER_SHIFT)
-
-#define DRV_ID_DRV_TYPE_MASK            0x7f000000
-#define DRV_ID_DRV_TYPE_SHIFT           24
-#define DRV_ID_DRV_TYPE_UNKNOWN         (0 << DRV_ID_DRV_TYPE_SHIFT)
-#define DRV_ID_DRV_TYPE_LINUX           (1 << DRV_ID_DRV_TYPE_SHIFT)
-#define DRV_ID_DRV_TYPE_WINDOWS         (2 << DRV_ID_DRV_TYPE_SHIFT)
-#define DRV_ID_DRV_TYPE_DIAG            (3 << DRV_ID_DRV_TYPE_SHIFT)
-#define DRV_ID_DRV_TYPE_PREBOOT         (4 << DRV_ID_DRV_TYPE_SHIFT)
-#define DRV_ID_DRV_TYPE_SOLARIS         (5 << DRV_ID_DRV_TYPE_SHIFT)
-#define DRV_ID_DRV_TYPE_VMWARE          (6 << DRV_ID_DRV_TYPE_SHIFT)
-#define DRV_ID_DRV_TYPE_FREEBSD         (7 << DRV_ID_DRV_TYPE_SHIFT)
-#define DRV_ID_DRV_TYPE_AIX             (8 << DRV_ID_DRV_TYPE_SHIFT)
-
-#define DRV_ID_DRV_INIT_HW_MASK         0x80000000
-#define DRV_ID_DRV_INIT_HW_SHIFT        31
-#define DRV_ID_DRV_INIT_HW_FLAG         BIT(DRV_ID_DRV_INIT_HW_SHIFT)
-};
+	u32 reserved0[2];
 
-/**************************************/
-/*                                    */
-/*     P U B L I C       M B          */
-/*                                    */
-/**************************************/
-/* This is the only section that the driver can write to, and each */
-/* Basically each driver request to set feature parameters,
- * will be done using a different command, which will be linked
- * to a specific data structure from the union below.
- * For huge strucuture, the common blank structure should be used.
- */
+	u32 mtu_size;
+
+	u32 reserved[7];
+
+	u32 config;
+#define FUNC_MF_CFG_FUNC_HIDE			0x00000001
+#define FUNC_MF_CFG_PAUSE_ON_HOST_RING		0x00000002
+#define FUNC_MF_CFG_PAUSE_ON_HOST_RING_SHIFT	0x00000001
+
+#define FUNC_MF_CFG_PROTOCOL_MASK	0x000000f0
+#define FUNC_MF_CFG_PROTOCOL_SHIFT	4
+#define FUNC_MF_CFG_PROTOCOL_ETHERNET	0x00000000
+#define FUNC_MF_CFG_PROTOCOL_MAX	0x00000030
+
+#define FUNC_MF_CFG_MIN_BW_MASK		0x0000ff00
+#define FUNC_MF_CFG_MIN_BW_SHIFT	8
+#define FUNC_MF_CFG_MIN_BW_DEFAULT	0x00000000
+#define FUNC_MF_CFG_MAX_BW_MASK		0x00ff0000
+#define FUNC_MF_CFG_MAX_BW_SHIFT	16
+#define FUNC_MF_CFG_MAX_BW_DEFAULT	0x00640000
+
+	u32 status;
+#define FUNC_STATUS_VLINK_DOWN		0x00000001
+
+	u32 mac_upper;
+#define FUNC_MF_CFG_UPPERMAC_MASK	0x0000ffff
+#define FUNC_MF_CFG_UPPERMAC_SHIFT	0
+#define FUNC_MF_CFG_UPPERMAC_DEFAULT	FUNC_MF_CFG_UPPERMAC_MASK
+	u32 mac_lower;
+#define FUNC_MF_CFG_LOWERMAC_DEFAULT	0xffffffff
+
+	u32 fcoe_wwn_port_name_upper;
+	u32 fcoe_wwn_port_name_lower;
+
+	u32 fcoe_wwn_node_name_upper;
+	u32 fcoe_wwn_node_name_lower;
+
+	u32 ovlan_stag;
+#define FUNC_MF_CFG_OV_STAG_MASK	0x0000ffff
+#define FUNC_MF_CFG_OV_STAG_SHIFT	0
+#define FUNC_MF_CFG_OV_STAG_DEFAULT	FUNC_MF_CFG_OV_STAG_MASK
+
+	u32 pf_allocation;
+
+	u32 preserve_data;
+
+	u32 driver_last_activity_ts;
+
+	u32 drv_ack_vf_disabled[VF_MAX_STATIC / 32];
+
+	u32 drv_id;
+#define DRV_ID_PDA_COMP_VER_MASK	0x0000ffff
+#define DRV_ID_PDA_COMP_VER_SHIFT	0
+
+#define DRV_ID_MCP_HSI_VER_MASK		0x00ff0000
+#define DRV_ID_MCP_HSI_VER_SHIFT	16
+#define DRV_ID_MCP_HSI_VER_CURRENT	(1 << DRV_ID_MCP_HSI_VER_SHIFT)
+
+#define DRV_ID_DRV_TYPE_MASK		0x7f000000
+#define DRV_ID_DRV_TYPE_SHIFT		24
+#define DRV_ID_DRV_TYPE_UNKNOWN		(0 << DRV_ID_DRV_TYPE_SHIFT)
+#define DRV_ID_DRV_TYPE_LINUX		(1 << DRV_ID_DRV_TYPE_SHIFT)
+
+#define DRV_ID_DRV_INIT_HW_MASK		0x80000000
+#define DRV_ID_DRV_INIT_HW_SHIFT	31
+#define DRV_ID_DRV_INIT_HW_FLAG		(1 << DRV_ID_DRV_INIT_HW_SHIFT)
+};
 
 struct mcp_mac {
-	u32	mac_upper;  /* Upper 16 bits are always zeroes */
-	u32	mac_lower;
+	u32 mac_upper;
+	u32 mac_lower;
 };
 
 struct mcp_val64 {
-	u32	lo;
-	u32	hi;
+	u32 lo;
+	u32 hi;
 };
 
 struct mcp_file_att {
-	u32	nvm_start_addr;
-	u32	len;
+	u32 nvm_start_addr;
+	u32 len;
+};
+
+struct bist_nvm_image_att {
+	u32 return_code;
+	u32 image_type;
+	u32 nvm_start_addr;
+	u32 len;
 };
 
 #define MCP_DRV_VER_STR_SIZE 16
 #define MCP_DRV_VER_STR_SIZE_DWORD (MCP_DRV_VER_STR_SIZE / sizeof(u32))
 #define MCP_DRV_NVM_BUF_LEN 32
 struct drv_version_stc {
-	u32	version;
-	u8	name[MCP_DRV_VER_STR_SIZE - 4];
+	u32 version;
+	u8 name[MCP_DRV_VER_STR_SIZE - 4];
+};
+
+struct lan_stats_stc {
+	u64 ucast_rx_pkts;
+	u64 ucast_tx_pkts;
+	u32 fcs_err;
+	u32 rserved;
+};
+
+struct ocbb_data_stc {
+	u32 ocbb_host_addr;
+	u32 ocsd_host_addr;
+	u32 ocsd_req_update_interval;
+};
+
+#define MAX_NUM_OF_SENSORS 7
+struct temperature_status_stc {
+	u32 num_of_sensors;
+	u32 sensor[MAX_NUM_OF_SENSORS];
+};
+
+/* crash dump configuration header */
+struct mdump_config_stc {
+	u32 version;
+	u32 config;
+	u32 epoc;
+	u32 num_of_logs;
+	u32 valid_logs;
 };
 
 union drv_union_data {
-	u32			ver_str[MCP_DRV_VER_STR_SIZE_DWORD];
-	struct mcp_mac		wol_mac;
+	u32 ver_str[MCP_DRV_VER_STR_SIZE_DWORD];
+	struct mcp_mac wol_mac;
+
+	struct eth_phy_cfg drv_phy_cfg;
 
-	struct pmm_phy_cfg	drv_phy_cfg;
+	struct mcp_val64 val64;
 
-	struct mcp_val64	val64; /* For PHY / AVS commands */
+	u8 raw_data[MCP_DRV_NVM_BUF_LEN];
 
-	u8			raw_data[MCP_DRV_NVM_BUF_LEN];
+	struct mcp_file_att file_att;
 
-	struct mcp_file_att	file_att;
+	u32 ack_vf_disabled[VF_MAX_STATIC / 32];
 
-	u32			ack_vf_disabled[VF_MAX_STATIC / 32];
+	struct drv_version_stc drv_version;
 
-	struct drv_version_stc	drv_version;
+	struct lan_stats_stc lan_stats;
+	u64 reserved_stats[11];
+	struct ocbb_data_stc ocbb_info;
+	struct temperature_status_stc temp_info;
+	struct bist_nvm_image_att nvm_image_att;
+	struct mdump_config_stc mdump_config;
 };
 
 struct public_drv_mb {
 	u32 drv_mb_header;
-#define DRV_MSG_CODE_MASK                       0xffff0000
-#define DRV_MSG_CODE_LOAD_REQ                   0x10000000
-#define DRV_MSG_CODE_LOAD_DONE                  0x11000000
-#define DRV_MSG_CODE_INIT_HW                    0x12000000
-#define DRV_MSG_CODE_UNLOAD_REQ                 0x20000000
-#define DRV_MSG_CODE_UNLOAD_DONE                0x21000000
-#define DRV_MSG_CODE_INIT_PHY                   0x22000000
-	/* Params - FORCE - Reinitialize the link regardless of LFA */
-	/*        - DONT_CARE - Don't flap the link if up */
-#define DRV_MSG_CODE_LINK_RESET                 0x23000000
-
-#define DRV_MSG_CODE_SET_LLDP                   0x24000000
-#define DRV_MSG_CODE_SET_DCBX                   0x25000000
+#define DRV_MSG_CODE_MASK			0xffff0000
+#define DRV_MSG_CODE_LOAD_REQ			0x10000000
+#define DRV_MSG_CODE_LOAD_DONE			0x11000000
+#define DRV_MSG_CODE_INIT_HW			0x12000000
+#define DRV_MSG_CODE_UNLOAD_REQ			0x20000000
+#define DRV_MSG_CODE_UNLOAD_DONE		0x21000000
+#define DRV_MSG_CODE_INIT_PHY			0x22000000
+#define DRV_MSG_CODE_LINK_RESET			0x23000000
+#define DRV_MSG_CODE_SET_DCBX			0x25000000
+
 #define DRV_MSG_CODE_BW_UPDATE_ACK		0x32000000
-#define DRV_MSG_CODE_NIG_DRAIN                  0x30000000
-
-#define DRV_MSG_CODE_INITIATE_FLR               0x02000000
-#define DRV_MSG_CODE_VF_DISABLED_DONE           0xc0000000
-#define DRV_MSG_CODE_CFG_VF_MSIX                0xc0010000
-#define DRV_MSG_CODE_NVM_PUT_FILE_BEGIN         0x00010000
-#define DRV_MSG_CODE_NVM_PUT_FILE_DATA          0x00020000
-#define DRV_MSG_CODE_NVM_GET_FILE_ATT           0x00030000
-#define DRV_MSG_CODE_NVM_READ_NVRAM             0x00050000
-#define DRV_MSG_CODE_NVM_WRITE_NVRAM            0x00060000
-#define DRV_MSG_CODE_NVM_DEL_FILE               0x00080000
-#define DRV_MSG_CODE_MCP_RESET                  0x00090000
-#define DRV_MSG_CODE_SET_SECURE_MODE            0x000a0000
-#define DRV_MSG_CODE_PHY_RAW_READ               0x000b0000
-#define DRV_MSG_CODE_PHY_RAW_WRITE              0x000c0000
-#define DRV_MSG_CODE_PHY_CORE_READ              0x000d0000
-#define DRV_MSG_CODE_PHY_CORE_WRITE             0x000e0000
-#define DRV_MSG_CODE_SET_VERSION                0x000f0000
-
-#define DRV_MSG_CODE_BIST_TEST                  0x001e0000
-#define DRV_MSG_CODE_SET_LED_MODE               0x00200000
-
-#define DRV_MSG_SEQ_NUMBER_MASK                 0x0000ffff
+#define DRV_MSG_CODE_NIG_DRAIN			0x30000000
+#define DRV_MSG_CODE_VF_DISABLED_DONE		0xc0000000
+#define DRV_MSG_CODE_CFG_VF_MSIX		0xc0010000
+#define DRV_MSG_CODE_MCP_RESET			0x00090000
+#define DRV_MSG_CODE_SET_VERSION		0x000f0000
+
+#define DRV_MSG_CODE_BIST_TEST			0x001e0000
+#define DRV_MSG_CODE_SET_LED_MODE		0x00200000
+
+#define DRV_MSG_SEQ_NUMBER_MASK			0x0000ffff
 
 	u32 drv_mb_param;
+#define DRV_MB_PARAM_UNLOAD_WOL_MCP		0x00000001
+#define DRV_MB_PARAM_DCBX_NOTIFY_MASK		0x000000FF
+#define DRV_MB_PARAM_DCBX_NOTIFY_SHIFT		3
+#define DRV_MB_PARAM_CFG_VF_MSIX_VF_ID_SHIFT	0
+#define DRV_MB_PARAM_CFG_VF_MSIX_VF_ID_MASK	0x000000FF
+#define DRV_MB_PARAM_CFG_VF_MSIX_SB_NUM_SHIFT	8
+#define DRV_MB_PARAM_CFG_VF_MSIX_SB_NUM_MASK	0x0000FF00
+
+#define DRV_MB_PARAM_SET_LED_MODE_OPER		0x0
+#define DRV_MB_PARAM_SET_LED_MODE_ON		0x1
+#define DRV_MB_PARAM_SET_LED_MODE_OFF		0x2
 
-	/* UNLOAD_REQ params */
-#define DRV_MB_PARAM_UNLOAD_WOL_UNKNOWN         0x00000000
-#define DRV_MB_PARAM_UNLOAD_WOL_MCP             0x00000001
-#define DRV_MB_PARAM_UNLOAD_WOL_DISABLED        0x00000002
-#define DRV_MB_PARAM_UNLOAD_WOL_ENABLED         0x00000003
-
-	/* UNLOAD_DONE_params */
-#define DRV_MB_PARAM_UNLOAD_NON_D3_POWER        0x00000001
-
-	/* INIT_PHY params */
-#define DRV_MB_PARAM_INIT_PHY_FORCE             0x00000001
-#define DRV_MB_PARAM_INIT_PHY_DONT_CARE         0x00000002
-
-	/* LLDP / DCBX params*/
-#define DRV_MB_PARAM_LLDP_SEND_MASK             0x00000001
-#define DRV_MB_PARAM_LLDP_SEND_SHIFT            0
-#define DRV_MB_PARAM_LLDP_AGENT_MASK            0x00000006
-#define DRV_MB_PARAM_LLDP_AGENT_SHIFT           1
-#define DRV_MB_PARAM_DCBX_NOTIFY_MASK           0x00000008
-#define DRV_MB_PARAM_DCBX_NOTIFY_SHIFT          3
-
-#define DRV_MB_PARAM_NIG_DRAIN_PERIOD_MS_MASK   0x000000FF
-#define DRV_MB_PARAM_NIG_DRAIN_PERIOD_MS_SHIFT  0
-
-#define DRV_MB_PARAM_NVM_PUT_FILE_BEGIN_MFW     0x1
-#define DRV_MB_PARAM_NVM_PUT_FILE_BEGIN_IMAGE   0x2
-
-#define DRV_MB_PARAM_NVM_OFFSET_SHIFT           0
-#define DRV_MB_PARAM_NVM_OFFSET_MASK            0x00FFFFFF
-#define DRV_MB_PARAM_NVM_LEN_SHIFT              24
-#define DRV_MB_PARAM_NVM_LEN_MASK               0xFF000000
-
-#define DRV_MB_PARAM_PHY_ADDR_SHIFT             0
-#define DRV_MB_PARAM_PHY_ADDR_MASK              0x1FF0FFFF
-#define DRV_MB_PARAM_PHY_LANE_SHIFT             16
-#define DRV_MB_PARAM_PHY_LANE_MASK              0x000F0000
-#define DRV_MB_PARAM_PHY_SELECT_PORT_SHIFT      29
-#define DRV_MB_PARAM_PHY_SELECT_PORT_MASK       0x20000000
-#define DRV_MB_PARAM_PHY_PORT_SHIFT             30
-#define DRV_MB_PARAM_PHY_PORT_MASK              0xc0000000
-
-/* configure vf MSIX params*/
-#define DRV_MB_PARAM_CFG_VF_MSIX_VF_ID_SHIFT    0
-#define DRV_MB_PARAM_CFG_VF_MSIX_VF_ID_MASK     0x000000FF
-#define DRV_MB_PARAM_CFG_VF_MSIX_SB_NUM_SHIFT   8
-#define DRV_MB_PARAM_CFG_VF_MSIX_SB_NUM_MASK    0x0000FF00
-
-#define DRV_MB_PARAM_SET_LED_MODE_OPER          0x0
-#define DRV_MB_PARAM_SET_LED_MODE_ON            0x1
-#define DRV_MB_PARAM_SET_LED_MODE_OFF           0x2
-
-#define DRV_MB_PARAM_BIST_UNKNOWN_TEST          0
-#define DRV_MB_PARAM_BIST_REGISTER_TEST         1
-#define DRV_MB_PARAM_BIST_CLOCK_TEST            2
-
-#define DRV_MB_PARAM_BIST_RC_UNKNOWN            0
-#define DRV_MB_PARAM_BIST_RC_PASSED             1
-#define DRV_MB_PARAM_BIST_RC_FAILED             2
-#define DRV_MB_PARAM_BIST_RC_INVALID_PARAMETER          3
-
-#define DRV_MB_PARAM_BIST_TEST_INDEX_SHIFT      0
-#define DRV_MB_PARAM_BIST_TEST_INDEX_MASK       0x000000FF
+#define DRV_MB_PARAM_BIST_REGISTER_TEST		1
+#define DRV_MB_PARAM_BIST_CLOCK_TEST		2
+
+#define DRV_MB_PARAM_BIST_RC_UNKNOWN		0
+#define DRV_MB_PARAM_BIST_RC_PASSED		1
+#define DRV_MB_PARAM_BIST_RC_FAILED		2
+#define DRV_MB_PARAM_BIST_RC_INVALID_PARAMETER	3
+
+#define DRV_MB_PARAM_BIST_TEST_INDEX_SHIFT	0
+#define DRV_MB_PARAM_BIST_TEST_INDEX_MASK	0x000000FF
 
 	u32 fw_mb_header;
-#define FW_MSG_CODE_MASK                        0xffff0000
-#define FW_MSG_CODE_DRV_LOAD_ENGINE             0x10100000
-#define FW_MSG_CODE_DRV_LOAD_PORT               0x10110000
-#define FW_MSG_CODE_DRV_LOAD_FUNCTION           0x10120000
-#define FW_MSG_CODE_DRV_LOAD_REFUSED_PDA        0x10200000
-#define FW_MSG_CODE_DRV_LOAD_REFUSED_HSI        0x10210000
-#define FW_MSG_CODE_DRV_LOAD_REFUSED_DIAG       0x10220000
-#define FW_MSG_CODE_DRV_LOAD_DONE               0x11100000
-#define FW_MSG_CODE_DRV_UNLOAD_ENGINE           0x20110000
-#define FW_MSG_CODE_DRV_UNLOAD_PORT             0x20120000
-#define FW_MSG_CODE_DRV_UNLOAD_FUNCTION         0x20130000
-#define FW_MSG_CODE_DRV_UNLOAD_DONE             0x21100000
-#define FW_MSG_CODE_INIT_PHY_DONE               0x21200000
-#define FW_MSG_CODE_INIT_PHY_ERR_INVALID_ARGS   0x21300000
-#define FW_MSG_CODE_LINK_RESET_DONE             0x23000000
-#define FW_MSG_CODE_SET_LLDP_DONE               0x24000000
-#define FW_MSG_CODE_SET_LLDP_UNSUPPORTED_AGENT  0x24010000
-#define FW_MSG_CODE_SET_DCBX_DONE               0x25000000
-#define FW_MSG_CODE_NIG_DRAIN_DONE              0x30000000
-#define FW_MSG_CODE_VF_DISABLED_DONE            0xb0000000
-#define FW_MSG_CODE_DRV_CFG_VF_MSIX_DONE        0xb0010000
-#define FW_MSG_CODE_FLR_ACK                     0x02000000
-#define FW_MSG_CODE_FLR_NACK                    0x02100000
-
-#define FW_MSG_CODE_NVM_OK                      0x00010000
-#define FW_MSG_CODE_NVM_INVALID_MODE            0x00020000
-#define FW_MSG_CODE_NVM_PREV_CMD_WAS_NOT_FINISHED       0x00030000
-#define FW_MSG_CODE_NVM_FAILED_TO_ALLOCATE_PAGE 0x00040000
-#define FW_MSG_CODE_NVM_INVALID_DIR_FOUND       0x00050000
-#define FW_MSG_CODE_NVM_PAGE_NOT_FOUND          0x00060000
-#define FW_MSG_CODE_NVM_FAILED_PARSING_BNDLE_HEADER 0x00070000
-#define FW_MSG_CODE_NVM_FAILED_PARSING_IMAGE_HEADER 0x00080000
-#define FW_MSG_CODE_NVM_PARSING_OUT_OF_SYNC     0x00090000
-#define FW_MSG_CODE_NVM_FAILED_UPDATING_DIR     0x000a0000
-#define FW_MSG_CODE_NVM_FAILED_TO_FREE_PAGE     0x000b0000
-#define FW_MSG_CODE_NVM_FILE_NOT_FOUND          0x000c0000
-#define FW_MSG_CODE_NVM_OPERATION_FAILED        0x000d0000
-#define FW_MSG_CODE_NVM_FAILED_UNALIGNED        0x000e0000
-#define FW_MSG_CODE_NVM_BAD_OFFSET              0x000f0000
-#define FW_MSG_CODE_NVM_BAD_SIGNATURE           0x00100000
-#define FW_MSG_CODE_NVM_FILE_READ_ONLY          0x00200000
-#define FW_MSG_CODE_NVM_UNKNOWN_FILE            0x00300000
-#define FW_MSG_CODE_NVM_PUT_FILE_FINISH_OK      0x00400000
-#define FW_MSG_CODE_MCP_RESET_REJECT            0x00600000
-#define FW_MSG_CODE_PHY_OK                      0x00110000
-#define FW_MSG_CODE_PHY_ERROR                   0x00120000
-#define FW_MSG_CODE_SET_SECURE_MODE_ERROR       0x00130000
-#define FW_MSG_CODE_SET_SECURE_MODE_OK          0x00140000
-#define FW_MSG_MODE_PHY_PRIVILEGE_ERROR         0x00150000
-#define FW_MSG_CODE_OK                          0x00160000
-
-#define FW_MSG_SEQ_NUMBER_MASK                  0x0000ffff
-
-	u32	fw_mb_param;
-
-	u32	drv_pulse_mb;
-#define DRV_PULSE_SEQ_MASK                      0x00007fff
-#define DRV_PULSE_SYSTEM_TIME_MASK              0xffff0000
-#define DRV_PULSE_ALWAYS_ALIVE                  0x00008000
+#define FW_MSG_CODE_MASK			0xffff0000
+#define FW_MSG_CODE_DRV_LOAD_ENGINE		0x10100000
+#define FW_MSG_CODE_DRV_LOAD_PORT		0x10110000
+#define FW_MSG_CODE_DRV_LOAD_FUNCTION		0x10120000
+#define FW_MSG_CODE_DRV_LOAD_REFUSED_PDA	0x10200000
+#define FW_MSG_CODE_DRV_LOAD_REFUSED_HSI	0x10210000
+#define FW_MSG_CODE_DRV_LOAD_REFUSED_DIAG	0x10220000
+#define FW_MSG_CODE_DRV_LOAD_DONE		0x11100000
+#define FW_MSG_CODE_DRV_UNLOAD_ENGINE		0x20110000
+#define FW_MSG_CODE_DRV_UNLOAD_PORT		0x20120000
+#define FW_MSG_CODE_DRV_UNLOAD_FUNCTION		0x20130000
+#define FW_MSG_CODE_DRV_UNLOAD_DONE		0x21100000
+#define FW_MSG_CODE_DRV_CFG_VF_MSIX_DONE	0xb0010000
+#define FW_MSG_CODE_OK				0x00160000
+
+#define FW_MSG_SEQ_NUMBER_MASK			0x0000ffff
+
+	u32 fw_mb_param;
+
+	u32 drv_pulse_mb;
+#define DRV_PULSE_SEQ_MASK			0x00007fff
+#define DRV_PULSE_SYSTEM_TIME_MASK		0xffff0000
+#define DRV_PULSE_ALWAYS_ALIVE			0x00008000
+
 	u32 mcp_pulse_mb;
-#define MCP_PULSE_SEQ_MASK                      0x00007fff
-#define MCP_PULSE_ALWAYS_ALIVE                  0x00008000
-#define MCP_EVENT_MASK                          0xffff0000
-#define MCP_EVENT_OTHER_DRIVER_RESET_REQ        0x00010000
+#define MCP_PULSE_SEQ_MASK			0x00007fff
+#define MCP_PULSE_ALWAYS_ALIVE			0x00008000
+#define MCP_EVENT_MASK				0xffff0000
+#define MCP_EVENT_OTHER_DRIVER_RESET_REQ	0x00010000
 
 	union drv_union_data union_data;
 };
 
-/* MFW - DRV MB */
-/**********************************************************************
-* Description
-*   Incremental Aggregative
-*   8-bit MFW counter per message
-*   8-bit ack-counter per message
-* Capabilities
-*   Provides up to 256 aggregative message per type
-*   Provides 4 message types in dword
-*   Message type pointers to byte offset
-*   Backward Compatibility by using sizeof for the counters.
-*   No lock requires for 32bit messages
-* Limitations:
-* In case of messages greater than 32bit, a dedicated mechanism(e.g lock)
-* is required to prevent data corruption.
-**********************************************************************/
 enum MFW_DRV_MSG_TYPE {
 	MFW_DRV_MSG_LINK_CHANGE,
 	MFW_DRV_MSG_FLR_FW_ACK_FAILED,
@@ -4084,37 +4291,33 @@ enum MFW_DRV_MSG_TYPE {
 	MFW_DRV_MSG_LLDP_DATA_UPDATED,
 	MFW_DRV_MSG_DCBX_REMOTE_MIB_UPDATED,
 	MFW_DRV_MSG_DCBX_OPERATIONAL_MIB_UPDATED,
-	MFW_DRV_MSG_ERROR_RECOVERY,
+	MFW_DRV_MSG_RESERVED4,
 	MFW_DRV_MSG_BW_UPDATE,
-	MFW_DRV_MSG_S_TAG_UPDATE,
-	MFW_DRV_MSG_GET_LAN_STATS,
-	MFW_DRV_MSG_GET_FCOE_STATS,
-	MFW_DRV_MSG_GET_ISCSI_STATS,
-	MFW_DRV_MSG_GET_RDMA_STATS,
-	MFW_DRV_MSG_FAILURE_DETECTED,
+	MFW_DRV_MSG_BW_UPDATE5,
+	MFW_DRV_MSG_BW_UPDATE6,
+	MFW_DRV_MSG_BW_UPDATE7,
+	MFW_DRV_MSG_BW_UPDATE8,
+	MFW_DRV_MSG_BW_UPDATE9,
+	MFW_DRV_MSG_BW_UPDATE10,
 	MFW_DRV_MSG_TRANSCEIVER_STATE_CHANGE,
+	MFW_DRV_MSG_BW_UPDATE11,
 	MFW_DRV_MSG_MAX
 };
 
-#define MFW_DRV_MSG_MAX_DWORDS(msgs)    (((msgs - 1) >> 2) + 1)
-#define MFW_DRV_MSG_DWORD(msg_id)       (msg_id >> 2)
-#define MFW_DRV_MSG_OFFSET(msg_id)      ((msg_id & 0x3) << 3)
-#define MFW_DRV_MSG_MASK(msg_id)        (0xff << MFW_DRV_MSG_OFFSET(msg_id))
+#define MFW_DRV_MSG_MAX_DWORDS(msgs)	(((msgs - 1) >> 2) + 1)
+#define MFW_DRV_MSG_DWORD(msg_id)	(msg_id >> 2)
+#define MFW_DRV_MSG_OFFSET(msg_id)	((msg_id & 0x3) << 3)
+#define MFW_DRV_MSG_MASK(msg_id)	(0xff << MFW_DRV_MSG_OFFSET(msg_id))
 
 struct public_mfw_mb {
-	u32	sup_msgs;
-	u32	msg[MFW_DRV_MSG_MAX_DWORDS(MFW_DRV_MSG_MAX)];
-	u32	ack[MFW_DRV_MSG_MAX_DWORDS(MFW_DRV_MSG_MAX)];
+	u32 sup_msgs;
+	u32 msg[MFW_DRV_MSG_MAX_DWORDS(MFW_DRV_MSG_MAX)];
+	u32 ack[MFW_DRV_MSG_MAX_DWORDS(MFW_DRV_MSG_MAX)];
 };
 
-/**************************************/
-/*                                    */
-/*     P U B L I C       D A T A      */
-/*                                    */
-/**************************************/
 enum public_sections {
-	PUBLIC_DRV_MB,          /* Points to the first drv_mb of path0 */
-	PUBLIC_MFW_MB,          /* Points to the first mfw_mb of path0 */
+	PUBLIC_DRV_MB,
+	PUBLIC_MFW_MB,
 	PUBLIC_GLOBAL,
 	PUBLIC_PATH,
 	PUBLIC_PORT,
@@ -4122,1080 +4325,177 @@ enum public_sections {
 	PUBLIC_MAX_SECTIONS
 };
 
-struct drv_ver_info_stc {
-	u32	ver;
-	u8	name[32];
-};
-
 struct mcp_public_data {
-	/* The sections fields is an array */
-	u32			num_sections;
-	offsize_t		sections[PUBLIC_MAX_SECTIONS];
-	struct public_drv_mb	drv_mb[MCP_GLOB_FUNC_MAX];
-	struct public_mfw_mb	mfw_mb[MCP_GLOB_FUNC_MAX];
-	struct public_global	global;
-	struct public_path	path[MCP_GLOB_PATH_MAX];
-	struct public_port	port[MCP_GLOB_PORT_MAX];
-	struct public_func	func[MCP_GLOB_FUNC_MAX];
-	struct drv_ver_info_stc drv_info;
+	u32 num_sections;
+	u32 sections[PUBLIC_MAX_SECTIONS];
+	struct public_drv_mb drv_mb[MCP_GLOB_FUNC_MAX];
+	struct public_mfw_mb mfw_mb[MCP_GLOB_FUNC_MAX];
+	struct public_global global;
+	struct public_path path[MCP_GLOB_PATH_MAX];
+	struct public_port port[MCP_GLOB_PORT_MAX];
+	struct public_func func[MCP_GLOB_FUNC_MAX];
 };
 
 struct nvm_cfg_mac_address {
-	u32	mac_addr_hi;
-#define NVM_CFG_MAC_ADDRESS_HI_MASK                             0x0000FFFF
-#define NVM_CFG_MAC_ADDRESS_HI_OFFSET                           0
-
-	u32	mac_addr_lo;
+	u32 mac_addr_hi;
+#define NVM_CFG_MAC_ADDRESS_HI_MASK	0x0000FFFF
+#define NVM_CFG_MAC_ADDRESS_HI_OFFSET	0
+	u32 mac_addr_lo;
 };
 
-/******************************************
-* nvm_cfg1 structs
-******************************************/
-
 struct nvm_cfg1_glob {
-	u32 generic_cont0;					/* 0x0 */
-#define NVM_CFG1_GLOB_BOARD_SWAP_MASK                           0x0000000F
-#define NVM_CFG1_GLOB_BOARD_SWAP_OFFSET                         0
-#define NVM_CFG1_GLOB_BOARD_SWAP_NONE                           0x0
-#define NVM_CFG1_GLOB_BOARD_SWAP_PATH                           0x1
-#define NVM_CFG1_GLOB_BOARD_SWAP_PORT                           0x2
-#define NVM_CFG1_GLOB_BOARD_SWAP_BOTH                           0x3
-#define NVM_CFG1_GLOB_MF_MODE_MASK                              0x00000FF0
-#define NVM_CFG1_GLOB_MF_MODE_OFFSET                            4
-#define NVM_CFG1_GLOB_MF_MODE_MF_ALLOWED                        0x0
-#define NVM_CFG1_GLOB_MF_MODE_DEFAULT                           0x1
-#define NVM_CFG1_GLOB_MF_MODE_SPIO4                             0x2
-#define NVM_CFG1_GLOB_MF_MODE_NPAR1_0                           0x3
-#define NVM_CFG1_GLOB_MF_MODE_NPAR1_5                           0x4
-#define NVM_CFG1_GLOB_MF_MODE_NPAR2_0                           0x5
-#define NVM_CFG1_GLOB_MF_MODE_BD                                0x6
-#define NVM_CFG1_GLOB_MF_MODE_UFP                               0x7
-#define NVM_CFG1_GLOB_FAN_FAILURE_ENFORCEMENT_MASK              0x00001000
-#define NVM_CFG1_GLOB_FAN_FAILURE_ENFORCEMENT_OFFSET            12
-#define NVM_CFG1_GLOB_FAN_FAILURE_ENFORCEMENT_DISABLED          0x0
-#define NVM_CFG1_GLOB_FAN_FAILURE_ENFORCEMENT_ENABLED           0x1
-#define NVM_CFG1_GLOB_AVS_MARGIN_LOW_MASK                       0x001FE000
-#define NVM_CFG1_GLOB_AVS_MARGIN_LOW_OFFSET                     13
-#define NVM_CFG1_GLOB_AVS_MARGIN_HIGH_MASK                      0x1FE00000
-#define NVM_CFG1_GLOB_AVS_MARGIN_HIGH_OFFSET                    21
-#define NVM_CFG1_GLOB_ENABLE_SRIOV_MASK                         0x20000000
-#define NVM_CFG1_GLOB_ENABLE_SRIOV_OFFSET                       29
-#define NVM_CFG1_GLOB_ENABLE_SRIOV_DISABLED                     0x0
-#define NVM_CFG1_GLOB_ENABLE_SRIOV_ENABLED                      0x1
-#define NVM_CFG1_GLOB_ENABLE_ATC_MASK                           0x40000000
-#define NVM_CFG1_GLOB_ENABLE_ATC_OFFSET                         30
-#define NVM_CFG1_GLOB_ENABLE_ATC_DISABLED                       0x0
-#define NVM_CFG1_GLOB_ENABLE_ATC_ENABLED                        0x1
-#define NVM_CFG1_GLOB_CLOCK_SLOWDOWN_MASK                       0x80000000
-#define NVM_CFG1_GLOB_CLOCK_SLOWDOWN_OFFSET                     31
-#define NVM_CFG1_GLOB_CLOCK_SLOWDOWN_DISABLED                   0x0
-#define NVM_CFG1_GLOB_CLOCK_SLOWDOWN_ENABLED                    0x1
-
-	u32	engineering_change[3];				/* 0x4 */
-
-	u32	manufacturing_id;				/* 0x10 */
-
-	u32	serial_number[4];				/* 0x14 */
-
-	u32	pcie_cfg;					/* 0x24 */
-#define NVM_CFG1_GLOB_PCI_GEN_MASK                              0x00000003
-#define NVM_CFG1_GLOB_PCI_GEN_OFFSET                            0
-#define NVM_CFG1_GLOB_PCI_GEN_PCI_GEN1                          0x0
-#define NVM_CFG1_GLOB_PCI_GEN_PCI_GEN2                          0x1
-#define NVM_CFG1_GLOB_PCI_GEN_PCI_GEN3                          0x2
-#define NVM_CFG1_GLOB_BEACON_WOL_ENABLED_MASK                   0x00000004
-#define NVM_CFG1_GLOB_BEACON_WOL_ENABLED_OFFSET                 2
-#define NVM_CFG1_GLOB_BEACON_WOL_ENABLED_DISABLED               0x0
-#define NVM_CFG1_GLOB_BEACON_WOL_ENABLED_ENABLED                0x1
-#define NVM_CFG1_GLOB_ASPM_SUPPORT_MASK                         0x00000018
-#define NVM_CFG1_GLOB_ASPM_SUPPORT_OFFSET                       3
-#define NVM_CFG1_GLOB_ASPM_SUPPORT_L0S_L1_ENABLED               0x0
-#define NVM_CFG1_GLOB_ASPM_SUPPORT_L0S_DISABLED                 0x1
-#define NVM_CFG1_GLOB_ASPM_SUPPORT_L1_DISABLED                  0x2
-#define NVM_CFG1_GLOB_ASPM_SUPPORT_L0S_L1_DISABLED              0x3
-#define NVM_CFG1_GLOB_PREVENT_PCIE_L1_MENTRY_MASK               0x00000020
-#define NVM_CFG1_GLOB_PREVENT_PCIE_L1_MENTRY_OFFSET             5
-#define NVM_CFG1_GLOB_PREVENT_PCIE_L1_MENTRY_DISABLED           0x0
-#define NVM_CFG1_GLOB_PREVENT_PCIE_L1_MENTRY_ENABLED            0x1
-#define NVM_CFG1_GLOB_PCIE_G2_TX_AMPLITUDE_MASK                 0x000003C0
-#define NVM_CFG1_GLOB_PCIE_G2_TX_AMPLITUDE_OFFSET               6
-#define NVM_CFG1_GLOB_PCIE_PREEMPHASIS_MASK                     0x00001C00
-#define NVM_CFG1_GLOB_PCIE_PREEMPHASIS_OFFSET                   10
-#define NVM_CFG1_GLOB_PCIE_PREEMPHASIS_HW                       0x0
-#define NVM_CFG1_GLOB_PCIE_PREEMPHASIS_0DB                      0x1
-#define NVM_CFG1_GLOB_PCIE_PREEMPHASIS_3_5DB                    0x2
-#define NVM_CFG1_GLOB_PCIE_PREEMPHASIS_6_0DB                    0x3
-#define NVM_CFG1_GLOB_WWN_NODE_PREFIX0_MASK                     0x001FE000
-#define NVM_CFG1_GLOB_WWN_NODE_PREFIX0_OFFSET                   13
-#define NVM_CFG1_GLOB_WWN_NODE_PREFIX1_MASK                     0x1FE00000
-#define NVM_CFG1_GLOB_WWN_NODE_PREFIX1_OFFSET                   21
-#define NVM_CFG1_GLOB_NCSI_PACKAGE_ID_MASK                      0x60000000
-#define NVM_CFG1_GLOB_NCSI_PACKAGE_ID_OFFSET                    29
-
-	u32 mgmt_traffic;                                       /* 0x28 */
-#define NVM_CFG1_GLOB_RESERVED60_MASK                           0x00000001
-#define NVM_CFG1_GLOB_RESERVED60_OFFSET                         0
-#define NVM_CFG1_GLOB_RESERVED60_100KHZ                         0x0
-#define NVM_CFG1_GLOB_RESERVED60_400KHZ                         0x1
-#define NVM_CFG1_GLOB_WWN_PORT_PREFIX0_MASK                     0x000001FE
-#define NVM_CFG1_GLOB_WWN_PORT_PREFIX0_OFFSET                   1
-#define NVM_CFG1_GLOB_WWN_PORT_PREFIX1_MASK                     0x0001FE00
-#define NVM_CFG1_GLOB_WWN_PORT_PREFIX1_OFFSET                   9
-#define NVM_CFG1_GLOB_SMBUS_ADDRESS_MASK                        0x01FE0000
-#define NVM_CFG1_GLOB_SMBUS_ADDRESS_OFFSET                      17
-#define NVM_CFG1_GLOB_SIDEBAND_MODE_MASK                        0x06000000
-#define NVM_CFG1_GLOB_SIDEBAND_MODE_OFFSET                      25
-#define NVM_CFG1_GLOB_SIDEBAND_MODE_DISABLED                    0x0
-#define NVM_CFG1_GLOB_SIDEBAND_MODE_RMII                        0x1
-#define NVM_CFG1_GLOB_SIDEBAND_MODE_SGMII                       0x2
-
-	u32 core_cfg;                                           /* 0x2C */
-#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_MASK                    0x000000FF
-#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_OFFSET                  0
-#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_2X40G                0x0
-#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_2X50G                0x1
-#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_1X100G               0x2
-#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_4X10G_F              0x3
-#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_4X10G_E              0x4
-#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_4X20G                0x5
-#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_1X40G                0xB
-#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_2X25G                0xC
-#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_1X25G                0xD
-#define NVM_CFG1_GLOB_EAGLE_ENFORCE_TX_FIR_CFG_MASK             0x00000100
-#define NVM_CFG1_GLOB_EAGLE_ENFORCE_TX_FIR_CFG_OFFSET           8
-#define NVM_CFG1_GLOB_EAGLE_ENFORCE_TX_FIR_CFG_DISABLED         0x0
-#define NVM_CFG1_GLOB_EAGLE_ENFORCE_TX_FIR_CFG_ENABLED          0x1
-#define NVM_CFG1_GLOB_FALCON_ENFORCE_TX_FIR_CFG_MASK            0x00000200
-#define NVM_CFG1_GLOB_FALCON_ENFORCE_TX_FIR_CFG_OFFSET          9
-#define NVM_CFG1_GLOB_FALCON_ENFORCE_TX_FIR_CFG_DISABLED        0x0
-#define NVM_CFG1_GLOB_FALCON_ENFORCE_TX_FIR_CFG_ENABLED         0x1
-#define NVM_CFG1_GLOB_EAGLE_CORE_ADDR_MASK                      0x0003FC00
-#define NVM_CFG1_GLOB_EAGLE_CORE_ADDR_OFFSET                    10
-#define NVM_CFG1_GLOB_FALCON_CORE_ADDR_MASK                     0x03FC0000
-#define NVM_CFG1_GLOB_FALCON_CORE_ADDR_OFFSET                   18
-#define NVM_CFG1_GLOB_AVS_MODE_MASK                             0x1C000000
-#define NVM_CFG1_GLOB_AVS_MODE_OFFSET                           26
-#define NVM_CFG1_GLOB_AVS_MODE_CLOSE_LOOP                       0x0
-#define NVM_CFG1_GLOB_AVS_MODE_OPEN_LOOP                        0x1
-#define NVM_CFG1_GLOB_AVS_MODE_DISABLED                         0x3
-#define NVM_CFG1_GLOB_OVERRIDE_SECURE_MODE_MASK                 0x60000000
-#define NVM_CFG1_GLOB_OVERRIDE_SECURE_MODE_OFFSET               29
-#define NVM_CFG1_GLOB_OVERRIDE_SECURE_MODE_DISABLED             0x0
-#define NVM_CFG1_GLOB_OVERRIDE_SECURE_MODE_ENABLED              0x1
-
-	u32 e_lane_cfg1;					/* 0x30 */
-#define NVM_CFG1_GLOB_RX_LANE0_SWAP_MASK                        0x0000000F
-#define NVM_CFG1_GLOB_RX_LANE0_SWAP_OFFSET                      0
-#define NVM_CFG1_GLOB_RX_LANE1_SWAP_MASK                        0x000000F0
-#define NVM_CFG1_GLOB_RX_LANE1_SWAP_OFFSET                      4
-#define NVM_CFG1_GLOB_RX_LANE2_SWAP_MASK                        0x00000F00
-#define NVM_CFG1_GLOB_RX_LANE2_SWAP_OFFSET                      8
-#define NVM_CFG1_GLOB_RX_LANE3_SWAP_MASK                        0x0000F000
-#define NVM_CFG1_GLOB_RX_LANE3_SWAP_OFFSET                      12
-#define NVM_CFG1_GLOB_TX_LANE0_SWAP_MASK                        0x000F0000
-#define NVM_CFG1_GLOB_TX_LANE0_SWAP_OFFSET                      16
-#define NVM_CFG1_GLOB_TX_LANE1_SWAP_MASK                        0x00F00000
-#define NVM_CFG1_GLOB_TX_LANE1_SWAP_OFFSET                      20
-#define NVM_CFG1_GLOB_TX_LANE2_SWAP_MASK                        0x0F000000
-#define NVM_CFG1_GLOB_TX_LANE2_SWAP_OFFSET                      24
-#define NVM_CFG1_GLOB_TX_LANE3_SWAP_MASK                        0xF0000000
-#define NVM_CFG1_GLOB_TX_LANE3_SWAP_OFFSET                      28
-
-	u32 e_lane_cfg2;					/* 0x34 */
-#define NVM_CFG1_GLOB_RX_LANE0_POL_FLIP_MASK                    0x00000001
-#define NVM_CFG1_GLOB_RX_LANE0_POL_FLIP_OFFSET                  0
-#define NVM_CFG1_GLOB_RX_LANE1_POL_FLIP_MASK                    0x00000002
-#define NVM_CFG1_GLOB_RX_LANE1_POL_FLIP_OFFSET                  1
-#define NVM_CFG1_GLOB_RX_LANE2_POL_FLIP_MASK                    0x00000004
-#define NVM_CFG1_GLOB_RX_LANE2_POL_FLIP_OFFSET                  2
-#define NVM_CFG1_GLOB_RX_LANE3_POL_FLIP_MASK                    0x00000008
-#define NVM_CFG1_GLOB_RX_LANE3_POL_FLIP_OFFSET                  3
-#define NVM_CFG1_GLOB_TX_LANE0_POL_FLIP_MASK                    0x00000010
-#define NVM_CFG1_GLOB_TX_LANE0_POL_FLIP_OFFSET                  4
-#define NVM_CFG1_GLOB_TX_LANE1_POL_FLIP_MASK                    0x00000020
-#define NVM_CFG1_GLOB_TX_LANE1_POL_FLIP_OFFSET                  5
-#define NVM_CFG1_GLOB_TX_LANE2_POL_FLIP_MASK                    0x00000040
-#define NVM_CFG1_GLOB_TX_LANE2_POL_FLIP_OFFSET                  6
-#define NVM_CFG1_GLOB_TX_LANE3_POL_FLIP_MASK                    0x00000080
-#define NVM_CFG1_GLOB_TX_LANE3_POL_FLIP_OFFSET                  7
-#define NVM_CFG1_GLOB_SMBUS_MODE_MASK                           0x00000F00
-#define NVM_CFG1_GLOB_SMBUS_MODE_OFFSET                         8
-#define NVM_CFG1_GLOB_SMBUS_MODE_DISABLED                       0x0
-#define NVM_CFG1_GLOB_SMBUS_MODE_100KHZ                         0x1
-#define NVM_CFG1_GLOB_SMBUS_MODE_400KHZ                         0x2
-#define NVM_CFG1_GLOB_NCSI_MASK                                 0x0000F000
-#define NVM_CFG1_GLOB_NCSI_OFFSET                               12
-#define NVM_CFG1_GLOB_NCSI_DISABLED                             0x0
-#define NVM_CFG1_GLOB_NCSI_ENABLED                              0x1
-
-	u32 f_lane_cfg1;					/* 0x38 */
-#define NVM_CFG1_GLOB_RX_LANE0_SWAP_MASK                        0x0000000F
-#define NVM_CFG1_GLOB_RX_LANE0_SWAP_OFFSET                      0
-#define NVM_CFG1_GLOB_RX_LANE1_SWAP_MASK                        0x000000F0
-#define NVM_CFG1_GLOB_RX_LANE1_SWAP_OFFSET                      4
-#define NVM_CFG1_GLOB_RX_LANE2_SWAP_MASK                        0x00000F00
-#define NVM_CFG1_GLOB_RX_LANE2_SWAP_OFFSET                      8
-#define NVM_CFG1_GLOB_RX_LANE3_SWAP_MASK                        0x0000F000
-#define NVM_CFG1_GLOB_RX_LANE3_SWAP_OFFSET                      12
-#define NVM_CFG1_GLOB_TX_LANE0_SWAP_MASK                        0x000F0000
-#define NVM_CFG1_GLOB_TX_LANE0_SWAP_OFFSET                      16
-#define NVM_CFG1_GLOB_TX_LANE1_SWAP_MASK                        0x00F00000
-#define NVM_CFG1_GLOB_TX_LANE1_SWAP_OFFSET                      20
-#define NVM_CFG1_GLOB_TX_LANE2_SWAP_MASK                        0x0F000000
-#define NVM_CFG1_GLOB_TX_LANE2_SWAP_OFFSET                      24
-#define NVM_CFG1_GLOB_TX_LANE3_SWAP_MASK                        0xF0000000
-#define NVM_CFG1_GLOB_TX_LANE3_SWAP_OFFSET                      28
-
-	u32 f_lane_cfg2;					/* 0x3C */
-#define NVM_CFG1_GLOB_RX_LANE0_POL_FLIP_MASK                    0x00000001
-#define NVM_CFG1_GLOB_RX_LANE0_POL_FLIP_OFFSET                  0
-#define NVM_CFG1_GLOB_RX_LANE1_POL_FLIP_MASK                    0x00000002
-#define NVM_CFG1_GLOB_RX_LANE1_POL_FLIP_OFFSET                  1
-#define NVM_CFG1_GLOB_RX_LANE2_POL_FLIP_MASK                    0x00000004
-#define NVM_CFG1_GLOB_RX_LANE2_POL_FLIP_OFFSET                  2
-#define NVM_CFG1_GLOB_RX_LANE3_POL_FLIP_MASK                    0x00000008
-#define NVM_CFG1_GLOB_RX_LANE3_POL_FLIP_OFFSET                  3
-#define NVM_CFG1_GLOB_TX_LANE0_POL_FLIP_MASK                    0x00000010
-#define NVM_CFG1_GLOB_TX_LANE0_POL_FLIP_OFFSET                  4
-#define NVM_CFG1_GLOB_TX_LANE1_POL_FLIP_MASK                    0x00000020
-#define NVM_CFG1_GLOB_TX_LANE1_POL_FLIP_OFFSET                  5
-#define NVM_CFG1_GLOB_TX_LANE2_POL_FLIP_MASK                    0x00000040
-#define NVM_CFG1_GLOB_TX_LANE2_POL_FLIP_OFFSET                  6
-#define NVM_CFG1_GLOB_TX_LANE3_POL_FLIP_MASK                    0x00000080
-#define NVM_CFG1_GLOB_TX_LANE3_POL_FLIP_OFFSET                  7
-
-	u32 eagle_preemphasis;					/* 0x40 */
-#define NVM_CFG1_GLOB_LANE0_PREEMP_MASK                         0x000000FF
-#define NVM_CFG1_GLOB_LANE0_PREEMP_OFFSET                       0
-#define NVM_CFG1_GLOB_LANE1_PREEMP_MASK                         0x0000FF00
-#define NVM_CFG1_GLOB_LANE1_PREEMP_OFFSET                       8
-#define NVM_CFG1_GLOB_LANE2_PREEMP_MASK                         0x00FF0000
-#define NVM_CFG1_GLOB_LANE2_PREEMP_OFFSET                       16
-#define NVM_CFG1_GLOB_LANE3_PREEMP_MASK                         0xFF000000
-#define NVM_CFG1_GLOB_LANE3_PREEMP_OFFSET                       24
-
-	u32 eagle_driver_current;				/* 0x44 */
-#define NVM_CFG1_GLOB_LANE0_AMP_MASK                            0x000000FF
-#define NVM_CFG1_GLOB_LANE0_AMP_OFFSET                          0
-#define NVM_CFG1_GLOB_LANE1_AMP_MASK                            0x0000FF00
-#define NVM_CFG1_GLOB_LANE1_AMP_OFFSET                          8
-#define NVM_CFG1_GLOB_LANE2_AMP_MASK                            0x00FF0000
-#define NVM_CFG1_GLOB_LANE2_AMP_OFFSET                          16
-#define NVM_CFG1_GLOB_LANE3_AMP_MASK                            0xFF000000
-#define NVM_CFG1_GLOB_LANE3_AMP_OFFSET                          24
-
-	u32 falcon_preemphasis;					/* 0x48 */
-#define NVM_CFG1_GLOB_LANE0_PREEMP_MASK                         0x000000FF
-#define NVM_CFG1_GLOB_LANE0_PREEMP_OFFSET                       0
-#define NVM_CFG1_GLOB_LANE1_PREEMP_MASK                         0x0000FF00
-#define NVM_CFG1_GLOB_LANE1_PREEMP_OFFSET                       8
-#define NVM_CFG1_GLOB_LANE2_PREEMP_MASK                         0x00FF0000
-#define NVM_CFG1_GLOB_LANE2_PREEMP_OFFSET                       16
-#define NVM_CFG1_GLOB_LANE3_PREEMP_MASK                         0xFF000000
-#define NVM_CFG1_GLOB_LANE3_PREEMP_OFFSET                       24
-
-	u32 falcon_driver_current;				/* 0x4C */
-#define NVM_CFG1_GLOB_LANE0_AMP_MASK                            0x000000FF
-#define NVM_CFG1_GLOB_LANE0_AMP_OFFSET                          0
-#define NVM_CFG1_GLOB_LANE1_AMP_MASK                            0x0000FF00
-#define NVM_CFG1_GLOB_LANE1_AMP_OFFSET                          8
-#define NVM_CFG1_GLOB_LANE2_AMP_MASK                            0x00FF0000
-#define NVM_CFG1_GLOB_LANE2_AMP_OFFSET                          16
-#define NVM_CFG1_GLOB_LANE3_AMP_MASK                            0xFF000000
-#define NVM_CFG1_GLOB_LANE3_AMP_OFFSET                          24
-
-	u32	pci_id;						/* 0x50 */
-#define NVM_CFG1_GLOB_VENDOR_ID_MASK                            0x0000FFFF
-#define NVM_CFG1_GLOB_VENDOR_ID_OFFSET                          0
-
-	u32	pci_subsys_id;					/* 0x54 */
-#define NVM_CFG1_GLOB_SUBSYSTEM_VENDOR_ID_MASK                  0x0000FFFF
-#define NVM_CFG1_GLOB_SUBSYSTEM_VENDOR_ID_OFFSET                0
-#define NVM_CFG1_GLOB_SUBSYSTEM_DEVICE_ID_MASK                  0xFFFF0000
-#define NVM_CFG1_GLOB_SUBSYSTEM_DEVICE_ID_OFFSET                16
-
-	u32	bar;						/* 0x58 */
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_MASK                   0x0000000F
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_OFFSET                 0
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_DISABLED               0x0
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_2K                     0x1
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_4K                     0x2
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_8K                     0x3
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_16K                    0x4
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_32K                    0x5
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_64K                    0x6
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_128K                   0x7
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_256K                   0x8
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_512K                   0x9
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_1M                     0xA
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_2M                     0xB
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_4M                     0xC
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_8M                     0xD
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_16M                    0xE
-#define NVM_CFG1_GLOB_EXPANSION_ROM_SIZE_32M                    0xF
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_MASK                     0x000000F0
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_OFFSET                   4
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_DISABLED                 0x0
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_4K                       0x1
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_8K                       0x2
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_16K                      0x3
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_32K                      0x4
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_64K                      0x5
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_128K                     0x6
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_256K                     0x7
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_512K                     0x8
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_1M                       0x9
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_2M                       0xA
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_4M                       0xB
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_8M                       0xC
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_16M                      0xD
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_32M                      0xE
-#define NVM_CFG1_GLOB_VF_PCI_BAR2_SIZE_64M                      0xF
-#define NVM_CFG1_GLOB_BAR2_SIZE_MASK                            0x00000F00
-#define NVM_CFG1_GLOB_BAR2_SIZE_OFFSET                          8
-#define NVM_CFG1_GLOB_BAR2_SIZE_DISABLED                        0x0
-#define NVM_CFG1_GLOB_BAR2_SIZE_64K                             0x1
-#define NVM_CFG1_GLOB_BAR2_SIZE_128K                            0x2
-#define NVM_CFG1_GLOB_BAR2_SIZE_256K                            0x3
-#define NVM_CFG1_GLOB_BAR2_SIZE_512K                            0x4
-#define NVM_CFG1_GLOB_BAR2_SIZE_1M                              0x5
-#define NVM_CFG1_GLOB_BAR2_SIZE_2M                              0x6
-#define NVM_CFG1_GLOB_BAR2_SIZE_4M                              0x7
-#define NVM_CFG1_GLOB_BAR2_SIZE_8M                              0x8
-#define NVM_CFG1_GLOB_BAR2_SIZE_16M                             0x9
-#define NVM_CFG1_GLOB_BAR2_SIZE_32M                             0xA
-#define NVM_CFG1_GLOB_BAR2_SIZE_64M                             0xB
-#define NVM_CFG1_GLOB_BAR2_SIZE_128M                            0xC
-#define NVM_CFG1_GLOB_BAR2_SIZE_256M                            0xD
-#define NVM_CFG1_GLOB_BAR2_SIZE_512M                            0xE
-#define NVM_CFG1_GLOB_BAR2_SIZE_1G                              0xF
-
-	u32 eagle_txfir_main;					/* 0x5C */
-#define NVM_CFG1_GLOB_LANE0_TXFIR_MAIN_MASK                     0x000000FF
-#define NVM_CFG1_GLOB_LANE0_TXFIR_MAIN_OFFSET                   0
-#define NVM_CFG1_GLOB_LANE1_TXFIR_MAIN_MASK                     0x0000FF00
-#define NVM_CFG1_GLOB_LANE1_TXFIR_MAIN_OFFSET                   8
-#define NVM_CFG1_GLOB_LANE2_TXFIR_MAIN_MASK                     0x00FF0000
-#define NVM_CFG1_GLOB_LANE2_TXFIR_MAIN_OFFSET                   16
-#define NVM_CFG1_GLOB_LANE3_TXFIR_MAIN_MASK                     0xFF000000
-#define NVM_CFG1_GLOB_LANE3_TXFIR_MAIN_OFFSET                   24
-
-	u32 eagle_txfir_post;					/* 0x60 */
-#define NVM_CFG1_GLOB_LANE0_TXFIR_POST_MASK                     0x000000FF
-#define NVM_CFG1_GLOB_LANE0_TXFIR_POST_OFFSET                   0
-#define NVM_CFG1_GLOB_LANE1_TXFIR_POST_MASK                     0x0000FF00
-#define NVM_CFG1_GLOB_LANE1_TXFIR_POST_OFFSET                   8
-#define NVM_CFG1_GLOB_LANE2_TXFIR_POST_MASK                     0x00FF0000
-#define NVM_CFG1_GLOB_LANE2_TXFIR_POST_OFFSET                   16
-#define NVM_CFG1_GLOB_LANE3_TXFIR_POST_MASK                     0xFF000000
-#define NVM_CFG1_GLOB_LANE3_TXFIR_POST_OFFSET                   24
-
-	u32 falcon_txfir_main;					/* 0x64 */
-#define NVM_CFG1_GLOB_LANE0_TXFIR_MAIN_MASK                     0x000000FF
-#define NVM_CFG1_GLOB_LANE0_TXFIR_MAIN_OFFSET                   0
-#define NVM_CFG1_GLOB_LANE1_TXFIR_MAIN_MASK                     0x0000FF00
-#define NVM_CFG1_GLOB_LANE1_TXFIR_MAIN_OFFSET                   8
-#define NVM_CFG1_GLOB_LANE2_TXFIR_MAIN_MASK                     0x00FF0000
-#define NVM_CFG1_GLOB_LANE2_TXFIR_MAIN_OFFSET                   16
-#define NVM_CFG1_GLOB_LANE3_TXFIR_MAIN_MASK                     0xFF000000
-#define NVM_CFG1_GLOB_LANE3_TXFIR_MAIN_OFFSET                   24
-
-	u32 falcon_txfir_post;					/* 0x68 */
-#define NVM_CFG1_GLOB_LANE0_TXFIR_POST_MASK                     0x000000FF
-#define NVM_CFG1_GLOB_LANE0_TXFIR_POST_OFFSET                   0
-#define NVM_CFG1_GLOB_LANE1_TXFIR_POST_MASK                     0x0000FF00
-#define NVM_CFG1_GLOB_LANE1_TXFIR_POST_OFFSET                   8
-#define NVM_CFG1_GLOB_LANE2_TXFIR_POST_MASK                     0x00FF0000
-#define NVM_CFG1_GLOB_LANE2_TXFIR_POST_OFFSET                   16
-#define NVM_CFG1_GLOB_LANE3_TXFIR_POST_MASK                     0xFF000000
-#define NVM_CFG1_GLOB_LANE3_TXFIR_POST_OFFSET                   24
-
-	u32 manufacture_ver;					/* 0x6C */
-#define NVM_CFG1_GLOB_MANUF0_VER_MASK                           0x0000003F
-#define NVM_CFG1_GLOB_MANUF0_VER_OFFSET                         0
-#define NVM_CFG1_GLOB_MANUF1_VER_MASK                           0x00000FC0
-#define NVM_CFG1_GLOB_MANUF1_VER_OFFSET                         6
-#define NVM_CFG1_GLOB_MANUF2_VER_MASK                           0x0003F000
-#define NVM_CFG1_GLOB_MANUF2_VER_OFFSET                         12
-#define NVM_CFG1_GLOB_MANUF3_VER_MASK                           0x00FC0000
-#define NVM_CFG1_GLOB_MANUF3_VER_OFFSET                         18
-#define NVM_CFG1_GLOB_MANUF4_VER_MASK                           0x3F000000
-#define NVM_CFG1_GLOB_MANUF4_VER_OFFSET                         24
-
-	u32 manufacture_time;					/* 0x70 */
-#define NVM_CFG1_GLOB_MANUF0_TIME_MASK                          0x0000003F
-#define NVM_CFG1_GLOB_MANUF0_TIME_OFFSET                        0
-#define NVM_CFG1_GLOB_MANUF1_TIME_MASK                          0x00000FC0
-#define NVM_CFG1_GLOB_MANUF1_TIME_OFFSET                        6
-#define NVM_CFG1_GLOB_MANUF2_TIME_MASK                          0x0003F000
-#define NVM_CFG1_GLOB_MANUF2_TIME_OFFSET                        12
-
-	u32 led_global_settings;				/* 0x74 */
-#define NVM_CFG1_GLOB_LED_SWAP_0_MASK                           0x0000000F
-#define NVM_CFG1_GLOB_LED_SWAP_0_OFFSET                         0
-#define NVM_CFG1_GLOB_LED_SWAP_1_MASK                           0x000000F0
-#define NVM_CFG1_GLOB_LED_SWAP_1_OFFSET                         4
-#define NVM_CFG1_GLOB_LED_SWAP_2_MASK                           0x00000F00
-#define NVM_CFG1_GLOB_LED_SWAP_2_OFFSET                         8
-#define NVM_CFG1_GLOB_LED_SWAP_3_MASK                           0x0000F000
-#define NVM_CFG1_GLOB_LED_SWAP_3_OFFSET                         12
-
-	u32	generic_cont1;					/* 0x78 */
-#define NVM_CFG1_GLOB_AVS_DAC_CODE_MASK                         0x000003FF
-#define NVM_CFG1_GLOB_AVS_DAC_CODE_OFFSET                       0
-
-	u32	mbi_version;					/* 0x7C */
-#define NVM_CFG1_GLOB_MBI_VERSION_0_MASK                        0x000000FF
-#define NVM_CFG1_GLOB_MBI_VERSION_0_OFFSET                      0
-#define NVM_CFG1_GLOB_MBI_VERSION_1_MASK                        0x0000FF00
-#define NVM_CFG1_GLOB_MBI_VERSION_1_OFFSET                      8
-#define NVM_CFG1_GLOB_MBI_VERSION_2_MASK                        0x00FF0000
-#define NVM_CFG1_GLOB_MBI_VERSION_2_OFFSET                      16
-
-	u32	mbi_date;					/* 0x80 */
-
-	u32	misc_sig;					/* 0x84 */
-
-	/*  Define the GPIO mapping to switch i2c mux */
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO_0_MASK                   0x000000FF
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO_0_OFFSET                 0
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO_1_MASK                   0x0000FF00
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO_1_OFFSET                 8
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__NA                      0x0
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO0                   0x1
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO1                   0x2
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO2                   0x3
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO3                   0x4
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO4                   0x5
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO5                   0x6
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO6                   0x7
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO7                   0x8
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO8                   0x9
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO9                   0xA
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO10                  0xB
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO11                  0xC
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO12                  0xD
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO13                  0xE
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO14                  0xF
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO15                  0x10
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO16                  0x11
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO17                  0x12
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO18                  0x13
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO19                  0x14
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO20                  0x15
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO21                  0x16
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO22                  0x17
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO23                  0x18
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO24                  0x19
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO25                  0x1A
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO26                  0x1B
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO27                  0x1C
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO28                  0x1D
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO29                  0x1E
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO30                  0x1F
-#define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO31                  0x20
-	u32	device_capabilities;                            /* 0x88 */
-#define NVM_CFG1_GLOB_DEVICE_CAPABILITIES_ETHERNET              0x1
-	u32	power_dissipated;                               /* 0x8C */
-	u32 power_consumed;                                     /* 0x90 */
-	u32	efi_version;                                    /* 0x94 */
-	u32	reserved[42];                                   /* 0x98 */
+	u32 generic_cont0;
+#define NVM_CFG1_GLOB_MF_MODE_MASK		0x00000FF0
+#define NVM_CFG1_GLOB_MF_MODE_OFFSET		4
+#define NVM_CFG1_GLOB_MF_MODE_MF_ALLOWED	0x0
+#define NVM_CFG1_GLOB_MF_MODE_DEFAULT		0x1
+#define NVM_CFG1_GLOB_MF_MODE_SPIO4		0x2
+#define NVM_CFG1_GLOB_MF_MODE_NPAR1_0		0x3
+#define NVM_CFG1_GLOB_MF_MODE_NPAR1_5		0x4
+#define NVM_CFG1_GLOB_MF_MODE_NPAR2_0		0x5
+#define NVM_CFG1_GLOB_MF_MODE_BD		0x6
+#define NVM_CFG1_GLOB_MF_MODE_UFP		0x7
+	u32 engineering_change[3];
+	u32 manufacturing_id;
+	u32 serial_number[4];
+	u32 pcie_cfg;
+	u32 mgmt_traffic;
+	u32 core_cfg;
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_MASK		0x000000FF
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_OFFSET		0
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_BB_2X40G	0x0
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_2X50G		0x1
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_BB_1X100G	0x2
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_4X10G_F		0x3
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_BB_4X10G_E	0x4
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_BB_4X20G	0x5
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_1X40G		0xB
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_2X25G		0xC
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_1X25G		0xD
+#define NVM_CFG1_GLOB_NETWORK_PORT_MODE_4X25G		0xE
+	u32 e_lane_cfg1;
+	u32 e_lane_cfg2;
+	u32 f_lane_cfg1;
+	u32 f_lane_cfg2;
+	u32 mps10_preemphasis;
+	u32 mps10_driver_current;
+	u32 mps25_preemphasis;
+	u32 mps25_driver_current;
+	u32 pci_id;
+	u32 pci_subsys_id;
+	u32 bar;
+	u32 mps10_txfir_main;
+	u32 mps10_txfir_post;
+	u32 mps25_txfir_main;
+	u32 mps25_txfir_post;
+	u32 manufacture_ver;
+	u32 manufacture_time;
+	u32 led_global_settings;
+	u32 generic_cont1;
+	u32 mbi_version;
+	u32 mbi_date;
+	u32 misc_sig;
+	u32 device_capabilities;
+#define NVM_CFG1_GLOB_DEVICE_CAPABILITIES_ETHERNET	0x1
+	u32 power_dissipated;
+	u32 power_consumed;
+	u32 efi_version;
+	u32 multi_network_modes_capability;
+	u32 reserved[41];
 };
 
 struct nvm_cfg1_path {
-	u32 reserved[30];					/* 0x0 */
+	u32 reserved[30];
 };
 
 struct nvm_cfg1_port {
-	u32	reserved__m_relocated_to_option_123;           /* 0x0 */
-	u32	reserved__m_relocated_to_option_124;           /* 0x4 */
-	u32 generic_cont0;					/* 0x8 */
-#define NVM_CFG1_PORT_LED_MODE_MASK                             0x000000FF
-#define NVM_CFG1_PORT_LED_MODE_OFFSET                           0
-#define NVM_CFG1_PORT_LED_MODE_MAC1                             0x0
-#define NVM_CFG1_PORT_LED_MODE_PHY1                             0x1
-#define NVM_CFG1_PORT_LED_MODE_PHY2                             0x2
-#define NVM_CFG1_PORT_LED_MODE_PHY3                             0x3
-#define NVM_CFG1_PORT_LED_MODE_MAC2                             0x4
-#define NVM_CFG1_PORT_LED_MODE_PHY4                             0x5
-#define NVM_CFG1_PORT_LED_MODE_PHY5                             0x6
-#define NVM_CFG1_PORT_LED_MODE_PHY6                             0x7
-#define NVM_CFG1_PORT_LED_MODE_MAC3                             0x8
-#define NVM_CFG1_PORT_LED_MODE_PHY7                             0x9
-#define NVM_CFG1_PORT_LED_MODE_PHY8                             0xA
-#define NVM_CFG1_PORT_LED_MODE_PHY9                             0xB
-#define NVM_CFG1_PORT_LED_MODE_MAC4                             0xC
-#define NVM_CFG1_PORT_LED_MODE_PHY10                            0xD
-#define NVM_CFG1_PORT_LED_MODE_PHY11                            0xE
-#define NVM_CFG1_PORT_LED_MODE_PHY12                            0xF
-#define NVM_CFG1_PORT_ROCE_PRIORITY_MASK                        0x0000FF00
-#define NVM_CFG1_PORT_ROCE_PRIORITY_OFFSET                      8
-#define NVM_CFG1_PORT_DCBX_MODE_MASK                            0x000F0000
-#define NVM_CFG1_PORT_DCBX_MODE_OFFSET                          16
-#define NVM_CFG1_PORT_DCBX_MODE_DISABLED                        0x0
-#define NVM_CFG1_PORT_DCBX_MODE_IEEE                            0x1
-#define NVM_CFG1_PORT_DCBX_MODE_CEE                             0x2
-#define NVM_CFG1_PORT_DCBX_MODE_DYNAMIC                         0x3
-#define NVM_CFG1_PORT_DEFAULT_ENABLED_PROTOCOLS_MASK            0x00F00000
-#define NVM_CFG1_PORT_DEFAULT_ENABLED_PROTOCOLS_OFFSET          20
-#define NVM_CFG1_PORT_DEFAULT_ENABLED_PROTOCOLS_ETHERNET        0x1
-	u32	pcie_cfg;					/* 0xC */
-#define NVM_CFG1_PORT_RESERVED15_MASK                           0x00000007
-#define NVM_CFG1_PORT_RESERVED15_OFFSET                         0
-
-	u32	features;					/* 0x10 */
-#define NVM_CFG1_PORT_ENABLE_WOL_ON_ACPI_PATTERN_MASK           0x00000001
-#define NVM_CFG1_PORT_ENABLE_WOL_ON_ACPI_PATTERN_OFFSET         0
-#define NVM_CFG1_PORT_ENABLE_WOL_ON_ACPI_PATTERN_DISABLED       0x0
-#define NVM_CFG1_PORT_ENABLE_WOL_ON_ACPI_PATTERN_ENABLED        0x1
-#define NVM_CFG1_PORT_MAGIC_PACKET_WOL_MASK                     0x00000002
-#define NVM_CFG1_PORT_MAGIC_PACKET_WOL_OFFSET                   1
-#define NVM_CFG1_PORT_MAGIC_PACKET_WOL_DISABLED                 0x0
-#define NVM_CFG1_PORT_MAGIC_PACKET_WOL_ENABLED                  0x1
-
-	u32 speed_cap_mask;					/* 0x14 */
-#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_MASK            0x0000FFFF
-#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_OFFSET          0
-#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_1G              0x1
-#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_10G             0x2
-#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_25G             0x8
-#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_40G             0x10
-#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_50G             0x20
-#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_100G            0x40
-#define NVM_CFG1_PORT_MFW_SPEED_CAPABILITY_MASK_MASK            0xFFFF0000
-#define NVM_CFG1_PORT_MFW_SPEED_CAPABILITY_MASK_OFFSET          16
-#define NVM_CFG1_PORT_MFW_SPEED_CAPABILITY_MASK_1G              0x1
-#define NVM_CFG1_PORT_MFW_SPEED_CAPABILITY_MASK_10G             0x2
-#define NVM_CFG1_PORT_MFW_SPEED_CAPABILITY_MASK_25G             0x8
-#define NVM_CFG1_PORT_MFW_SPEED_CAPABILITY_MASK_40G             0x10
-#define NVM_CFG1_PORT_MFW_SPEED_CAPABILITY_MASK_50G             0x20
-#define NVM_CFG1_PORT_MFW_SPEED_CAPABILITY_MASK_100G            0x40
-
-	u32 link_settings;					/* 0x18 */
-#define NVM_CFG1_PORT_DRV_LINK_SPEED_MASK                       0x0000000F
-#define NVM_CFG1_PORT_DRV_LINK_SPEED_OFFSET                     0
-#define NVM_CFG1_PORT_DRV_LINK_SPEED_AUTONEG                    0x0
-#define NVM_CFG1_PORT_DRV_LINK_SPEED_1G                         0x1
-#define NVM_CFG1_PORT_DRV_LINK_SPEED_10G                        0x2
-#define NVM_CFG1_PORT_DRV_LINK_SPEED_25G                        0x4
-#define NVM_CFG1_PORT_DRV_LINK_SPEED_40G                        0x5
-#define NVM_CFG1_PORT_DRV_LINK_SPEED_50G                        0x6
-#define NVM_CFG1_PORT_DRV_LINK_SPEED_100G                       0x7
-#define NVM_CFG1_PORT_DRV_FLOW_CONTROL_MASK                     0x00000070
-#define NVM_CFG1_PORT_DRV_FLOW_CONTROL_OFFSET                   4
-#define NVM_CFG1_PORT_DRV_FLOW_CONTROL_AUTONEG                  0x1
-#define NVM_CFG1_PORT_DRV_FLOW_CONTROL_RX                       0x2
-#define NVM_CFG1_PORT_DRV_FLOW_CONTROL_TX                       0x4
-#define NVM_CFG1_PORT_MFW_LINK_SPEED_MASK                       0x00000780
-#define NVM_CFG1_PORT_MFW_LINK_SPEED_OFFSET                     7
-#define NVM_CFG1_PORT_MFW_LINK_SPEED_AUTONEG                    0x0
-#define NVM_CFG1_PORT_MFW_LINK_SPEED_1G                         0x1
-#define NVM_CFG1_PORT_MFW_LINK_SPEED_10G                        0x2
-#define NVM_CFG1_PORT_MFW_LINK_SPEED_25G                        0x4
-#define NVM_CFG1_PORT_MFW_LINK_SPEED_40G                        0x5
-#define NVM_CFG1_PORT_MFW_LINK_SPEED_50G                        0x6
-#define NVM_CFG1_PORT_MFW_LINK_SPEED_100G                       0x7
-#define NVM_CFG1_PORT_MFW_FLOW_CONTROL_MASK                     0x00003800
-#define NVM_CFG1_PORT_MFW_FLOW_CONTROL_OFFSET                   11
-#define NVM_CFG1_PORT_MFW_FLOW_CONTROL_AUTONEG                  0x1
-#define NVM_CFG1_PORT_MFW_FLOW_CONTROL_RX                       0x2
-#define NVM_CFG1_PORT_MFW_FLOW_CONTROL_TX                       0x4
-#define NVM_CFG1_PORT_OPTIC_MODULE_VENDOR_ENFORCEMENT_MASK      0x00004000
-#define NVM_CFG1_PORT_OPTIC_MODULE_VENDOR_ENFORCEMENT_OFFSET    14
-#define NVM_CFG1_PORT_OPTIC_MODULE_VENDOR_ENFORCEMENT_DISABLED  0x0
-#define NVM_CFG1_PORT_OPTIC_MODULE_VENDOR_ENFORCEMENT_ENABLED   0x1
-
-	u32 phy_cfg;						/* 0x1C */
-#define NVM_CFG1_PORT_OPTIONAL_LINK_MODES_MASK                  0x0000FFFF
-#define NVM_CFG1_PORT_OPTIONAL_LINK_MODES_OFFSET                0
-#define NVM_CFG1_PORT_OPTIONAL_LINK_MODES_HIGIG                 0x1
-#define NVM_CFG1_PORT_OPTIONAL_LINK_MODES_SCRAMBLER             0x2
-#define NVM_CFG1_PORT_OPTIONAL_LINK_MODES_FIBER                 0x4
-#define NVM_CFG1_PORT_OPTIONAL_LINK_MODES_DISABLE_CL72_AN       0x8
-#define NVM_CFG1_PORT_OPTIONAL_LINK_MODES_DISABLE_FEC_AN        0x10
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_MASK                 0x00FF0000
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_OFFSET               16
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_BYPASS               0x0
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_KR                   0x2
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_KR2                  0x3
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_KR4                  0x4
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_XFI                  0x8
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_SFI                  0x9
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_1000X                0xB
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_SGMII                0xC
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_XLAUI                0x11
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_XLPPI                0x12
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_CAUI                 0x21
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_CPPI                 0x22
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_25GAUI               0x31
-#define NVM_CFG1_PORT_AN_MODE_MASK                              0xFF000000
-#define NVM_CFG1_PORT_AN_MODE_OFFSET                            24
-#define NVM_CFG1_PORT_AN_MODE_NONE                              0x0
-#define NVM_CFG1_PORT_AN_MODE_CL73                              0x1
-#define NVM_CFG1_PORT_AN_MODE_CL37                              0x2
-#define NVM_CFG1_PORT_AN_MODE_CL73_BAM                          0x3
-#define NVM_CFG1_PORT_AN_MODE_CL37_BAM                          0x4
-#define NVM_CFG1_PORT_AN_MODE_HPAM                              0x5
-#define NVM_CFG1_PORT_AN_MODE_SGMII                             0x6
-
-	u32 mgmt_traffic;					/* 0x20 */
-#define NVM_CFG1_PORT_RESERVED61_MASK                           0x0000000F
-#define NVM_CFG1_PORT_RESERVED61_OFFSET                         0
-
-	u32 ext_phy;						/* 0x24 */
-#define NVM_CFG1_PORT_EXTERNAL_PHY_TYPE_MASK                    0x000000FF
-#define NVM_CFG1_PORT_EXTERNAL_PHY_TYPE_OFFSET                  0
-#define NVM_CFG1_PORT_EXTERNAL_PHY_TYPE_NONE                    0x0
-#define NVM_CFG1_PORT_EXTERNAL_PHY_TYPE_BCM84844                0x1
-#define NVM_CFG1_PORT_EXTERNAL_PHY_ADDRESS_MASK                 0x0000FF00
-#define NVM_CFG1_PORT_EXTERNAL_PHY_ADDRESS_OFFSET               8
-
-	u32 mba_cfg1;						/* 0x28 */
-#define NVM_CFG1_PORT_PREBOOT_OPROM_MASK                        0x00000001
-#define NVM_CFG1_PORT_PREBOOT_OPROM_OFFSET                      0
-#define NVM_CFG1_PORT_PREBOOT_OPROM_DISABLED                    0x0
-#define NVM_CFG1_PORT_PREBOOT_OPROM_ENABLED                     0x1
-#define NVM_CFG1_PORT_RESERVED__M_MBA_BOOT_TYPE_MASK            0x00000006
-#define NVM_CFG1_PORT_RESERVED__M_MBA_BOOT_TYPE_OFFSET          1
-#define NVM_CFG1_PORT_MBA_DELAY_TIME_MASK                       0x00000078
-#define NVM_CFG1_PORT_MBA_DELAY_TIME_OFFSET                     3
-#define NVM_CFG1_PORT_MBA_SETUP_HOT_KEY_MASK                    0x00000080
-#define NVM_CFG1_PORT_MBA_SETUP_HOT_KEY_OFFSET                  7
-#define NVM_CFG1_PORT_MBA_SETUP_HOT_KEY_CTRL_S                  0x0
-#define NVM_CFG1_PORT_MBA_SETUP_HOT_KEY_CTRL_B                  0x1
-#define NVM_CFG1_PORT_MBA_HIDE_SETUP_PROMPT_MASK                0x00000100
-#define NVM_CFG1_PORT_MBA_HIDE_SETUP_PROMPT_OFFSET              8
-#define NVM_CFG1_PORT_MBA_HIDE_SETUP_PROMPT_DISABLED            0x0
-#define NVM_CFG1_PORT_MBA_HIDE_SETUP_PROMPT_ENABLED             0x1
-#define NVM_CFG1_PORT_RESERVED5_MASK                            0x0001FE00
-#define NVM_CFG1_PORT_RESERVED5_OFFSET                          9
-#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_MASK                   0x001E0000
-#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_OFFSET                 17
-#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_AUTONEG                0x0
-#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_1G                     0x1
-#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_10G                    0x2
-#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_25G                    0x4
-#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_40G                    0x5
-#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_50G                    0x6
-#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_100G                   0x7
-#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_SMARTLINQ              0x8
-#define NVM_CFG1_PORT_RESERVED__M_MBA_BOOT_RETRY_COUNT_MASK     0x00E00000
-#define NVM_CFG1_PORT_RESERVED__M_MBA_BOOT_RETRY_COUNT_OFFSET   21
-
-	u32	mba_cfg2;					/* 0x2C */
-#define NVM_CFG1_PORT_RESERVED65_MASK                           0x0000FFFF
-#define NVM_CFG1_PORT_RESERVED65_OFFSET                         0
-#define NVM_CFG1_PORT_RESERVED66_MASK                           0x00010000
-#define NVM_CFG1_PORT_RESERVED66_OFFSET                         16
-
-	u32	vf_cfg;						/* 0x30 */
-#define NVM_CFG1_PORT_RESERVED8_MASK                            0x0000FFFF
-#define NVM_CFG1_PORT_RESERVED8_OFFSET                          0
-#define NVM_CFG1_PORT_RESERVED6_MASK                            0x000F0000
-#define NVM_CFG1_PORT_RESERVED6_OFFSET                          16
-
-	struct nvm_cfg_mac_address	lldp_mac_address;	/* 0x34 */
-
-	u32				led_port_settings;	/* 0x3C */
-#define NVM_CFG1_PORT_LANE_LED_SPD_0_SEL_MASK                   0x000000FF
-#define NVM_CFG1_PORT_LANE_LED_SPD_0_SEL_OFFSET                 0
-#define NVM_CFG1_PORT_LANE_LED_SPD_1_SEL_MASK                   0x0000FF00
-#define NVM_CFG1_PORT_LANE_LED_SPD_1_SEL_OFFSET                 8
-#define NVM_CFG1_PORT_LANE_LED_SPD_2_SEL_MASK                   0x00FF0000
-#define NVM_CFG1_PORT_LANE_LED_SPD_2_SEL_OFFSET                 16
-#define NVM_CFG1_PORT_LANE_LED_SPD__SEL_1G                      0x1
-#define NVM_CFG1_PORT_LANE_LED_SPD__SEL_10G                     0x2
-#define NVM_CFG1_PORT_LANE_LED_SPD__SEL_25G                     0x8
-#define NVM_CFG1_PORT_LANE_LED_SPD__SEL_40G                     0x10
-#define NVM_CFG1_PORT_LANE_LED_SPD__SEL_50G                     0x20
-#define NVM_CFG1_PORT_LANE_LED_SPD__SEL_100G                    0x40
-
-	u32 transceiver_00;					/* 0x40 */
-
-	/*  Define for mapping of transceiver signal module absent */
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_MASK                     0x000000FF
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_OFFSET                   0
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_NA                       0x0
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO0                    0x1
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO1                    0x2
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO2                    0x3
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO3                    0x4
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO4                    0x5
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO5                    0x6
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO6                    0x7
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO7                    0x8
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO8                    0x9
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO9                    0xA
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO10                   0xB
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO11                   0xC
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO12                   0xD
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO13                   0xE
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO14                   0xF
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO15                   0x10
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO16                   0x11
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO17                   0x12
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO18                   0x13
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO19                   0x14
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO20                   0x15
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO21                   0x16
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO22                   0x17
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO23                   0x18
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO24                   0x19
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO25                   0x1A
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO26                   0x1B
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO27                   0x1C
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO28                   0x1D
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO29                   0x1E
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO30                   0x1F
-#define NVM_CFG1_PORT_TRANS_MODULE_ABS_GPIO31                   0x20
-	/*  Define the GPIO mux settings  to switch i2c mux to this port */
-#define NVM_CFG1_PORT_I2C_MUX_SEL_VALUE_0_MASK                  0x00000F00
-#define NVM_CFG1_PORT_I2C_MUX_SEL_VALUE_0_OFFSET                8
-#define NVM_CFG1_PORT_I2C_MUX_SEL_VALUE_1_MASK                  0x0000F000
-#define NVM_CFG1_PORT_I2C_MUX_SEL_VALUE_1_OFFSET                12
-
-	u32 reserved[133];					/* 0x44 */
+	u32 reserved__m_relocated_to_option_123;
+	u32 reserved__m_relocated_to_option_124;
+	u32 generic_cont0;
+#define NVM_CFG1_PORT_DCBX_MODE_MASK				0x000F0000
+#define NVM_CFG1_PORT_DCBX_MODE_OFFSET				16
+#define NVM_CFG1_PORT_DCBX_MODE_DISABLED			0x0
+#define NVM_CFG1_PORT_DCBX_MODE_IEEE				0x1
+#define NVM_CFG1_PORT_DCBX_MODE_CEE				0x2
+#define NVM_CFG1_PORT_DCBX_MODE_DYNAMIC				0x3
+#define NVM_CFG1_PORT_DEFAULT_ENABLED_PROTOCOLS_MASK		0x00F00000
+#define NVM_CFG1_PORT_DEFAULT_ENABLED_PROTOCOLS_OFFSET		20
+#define NVM_CFG1_PORT_DEFAULT_ENABLED_PROTOCOLS_ETHERNET	0x1
+#define NVM_CFG1_PORT_DEFAULT_ENABLED_PROTOCOLS_FCOE		0x2
+#define NVM_CFG1_PORT_DEFAULT_ENABLED_PROTOCOLS_ISCSI		0x4
+	u32 pcie_cfg;
+	u32 features;
+	u32 speed_cap_mask;
+#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_MASK		0x0000FFFF
+#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_OFFSET		0
+#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_1G		0x1
+#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_10G		0x2
+#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_25G		0x8
+#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_40G		0x10
+#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_50G		0x20
+#define NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_BB_100G		0x40
+	u32 link_settings;
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_MASK			0x0000000F
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_OFFSET			0
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_AUTONEG			0x0
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_1G				0x1
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_10G			0x2
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_25G			0x4
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_40G			0x5
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_50G			0x6
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_BB_100G			0x7
+#define NVM_CFG1_PORT_DRV_LINK_SPEED_SMARTLINQ			0x8
+#define NVM_CFG1_PORT_DRV_FLOW_CONTROL_MASK			0x00000070
+#define NVM_CFG1_PORT_DRV_FLOW_CONTROL_OFFSET			4
+#define NVM_CFG1_PORT_DRV_FLOW_CONTROL_AUTONEG			0x1
+#define NVM_CFG1_PORT_DRV_FLOW_CONTROL_RX			0x2
+#define NVM_CFG1_PORT_DRV_FLOW_CONTROL_TX			0x4
+	u32 phy_cfg;
+	u32 mgmt_traffic;
+	u32 ext_phy;
+	u32 mba_cfg1;
+	u32 mba_cfg2;
+	u32 vf_cfg;
+	struct nvm_cfg_mac_address lldp_mac_address;
+	u32 led_port_settings;
+	u32 transceiver_00;
+	u32 device_ids;
+	u32 board_cfg;
+	u32 mnm_10g_cap;
+	u32 mnm_10g_ctrl;
+	u32 mnm_10g_misc;
+	u32 mnm_25g_cap;
+	u32 mnm_25g_ctrl;
+	u32 mnm_25g_misc;
+	u32 mnm_40g_cap;
+	u32 mnm_40g_ctrl;
+	u32 mnm_40g_misc;
+	u32 mnm_50g_cap;
+	u32 mnm_50g_ctrl;
+	u32 mnm_50g_misc;
+	u32 mnm_100g_cap;
+	u32 mnm_100g_ctrl;
+	u32 mnm_100g_misc;
+	u32 reserved[116];
 };
 
 struct nvm_cfg1_func {
-	struct nvm_cfg_mac_address	mac_address;		/* 0x0 */
-
-	u32				rsrv1;			/* 0x8 */
-#define NVM_CFG1_FUNC_RESERVED1_MASK                            0x0000FFFF
-#define NVM_CFG1_FUNC_RESERVED1_OFFSET                          0
-#define NVM_CFG1_FUNC_RESERVED2_MASK                            0xFFFF0000
-#define NVM_CFG1_FUNC_RESERVED2_OFFSET                          16
-
-	u32				rsrv2;			/* 0xC */
-#define NVM_CFG1_FUNC_RESERVED3_MASK                            0x0000FFFF
-#define NVM_CFG1_FUNC_RESERVED3_OFFSET                          0
-#define NVM_CFG1_FUNC_RESERVED4_MASK                            0xFFFF0000
-#define NVM_CFG1_FUNC_RESERVED4_OFFSET                          16
-
-	u32				device_id;		/* 0x10 */
-#define NVM_CFG1_FUNC_MF_VENDOR_DEVICE_ID_MASK                  0x0000FFFF
-#define NVM_CFG1_FUNC_MF_VENDOR_DEVICE_ID_OFFSET                0
-#define NVM_CFG1_FUNC_RESERVED77_MASK                           0xFFFF0000
-#define NVM_CFG1_FUNC_RESERVED77_OFFSET                         16
-
-	u32				cmn_cfg;		/* 0x14 */
-#define NVM_CFG1_FUNC_PREBOOT_BOOT_PROTOCOL_MASK                0x00000007
-#define NVM_CFG1_FUNC_PREBOOT_BOOT_PROTOCOL_OFFSET              0
-#define NVM_CFG1_FUNC_PREBOOT_BOOT_PROTOCOL_PXE                 0x0
-#define NVM_CFG1_FUNC_PREBOOT_BOOT_PROTOCOL_ISCSI_BOOT          0x3
-#define NVM_CFG1_FUNC_PREBOOT_BOOT_PROTOCOL_FCOE_BOOT           0x4
-#define NVM_CFG1_FUNC_PREBOOT_BOOT_PROTOCOL_NONE                0x7
-#define NVM_CFG1_FUNC_VF_PCI_DEVICE_ID_MASK                     0x0007FFF8
-#define NVM_CFG1_FUNC_VF_PCI_DEVICE_ID_OFFSET                   3
-#define NVM_CFG1_FUNC_PERSONALITY_MASK                          0x00780000
-#define NVM_CFG1_FUNC_PERSONALITY_OFFSET                        19
-#define NVM_CFG1_FUNC_PERSONALITY_ETHERNET                      0x0
-#define NVM_CFG1_FUNC_PERSONALITY_ISCSI                         0x1
-#define NVM_CFG1_FUNC_PERSONALITY_FCOE                          0x2
-#define NVM_CFG1_FUNC_PERSONALITY_ROCE                          0x3
-#define NVM_CFG1_FUNC_BANDWIDTH_WEIGHT_MASK                     0x7F800000
-#define NVM_CFG1_FUNC_BANDWIDTH_WEIGHT_OFFSET                   23
-#define NVM_CFG1_FUNC_PAUSE_ON_HOST_RING_MASK                   0x80000000
-#define NVM_CFG1_FUNC_PAUSE_ON_HOST_RING_OFFSET                 31
-#define NVM_CFG1_FUNC_PAUSE_ON_HOST_RING_DISABLED               0x0
-#define NVM_CFG1_FUNC_PAUSE_ON_HOST_RING_ENABLED                0x1
-
-	u32 pci_cfg;						/* 0x18 */
-#define NVM_CFG1_FUNC_NUMBER_OF_VFS_PER_PF_MASK                 0x0000007F
-#define NVM_CFG1_FUNC_NUMBER_OF_VFS_PER_PF_OFFSET               0
-#define NVM_CFG1_FUNC_RESERVESD12_MASK                          0x00003F80
-#define NVM_CFG1_FUNC_RESERVESD12_OFFSET                        7
-#define NVM_CFG1_FUNC_BAR1_SIZE_MASK                            0x0003C000
-#define NVM_CFG1_FUNC_BAR1_SIZE_OFFSET                          14
-#define NVM_CFG1_FUNC_BAR1_SIZE_DISABLED                        0x0
-#define NVM_CFG1_FUNC_BAR1_SIZE_64K                             0x1
-#define NVM_CFG1_FUNC_BAR1_SIZE_128K                            0x2
-#define NVM_CFG1_FUNC_BAR1_SIZE_256K                            0x3
-#define NVM_CFG1_FUNC_BAR1_SIZE_512K                            0x4
-#define NVM_CFG1_FUNC_BAR1_SIZE_1M                              0x5
-#define NVM_CFG1_FUNC_BAR1_SIZE_2M                              0x6
-#define NVM_CFG1_FUNC_BAR1_SIZE_4M                              0x7
-#define NVM_CFG1_FUNC_BAR1_SIZE_8M                              0x8
-#define NVM_CFG1_FUNC_BAR1_SIZE_16M                             0x9
-#define NVM_CFG1_FUNC_BAR1_SIZE_32M                             0xA
-#define NVM_CFG1_FUNC_BAR1_SIZE_64M                             0xB
-#define NVM_CFG1_FUNC_BAR1_SIZE_128M                            0xC
-#define NVM_CFG1_FUNC_BAR1_SIZE_256M                            0xD
-#define NVM_CFG1_FUNC_BAR1_SIZE_512M                            0xE
-#define NVM_CFG1_FUNC_BAR1_SIZE_1G                              0xF
-#define NVM_CFG1_FUNC_MAX_BANDWIDTH_MASK                        0x03FC0000
-#define NVM_CFG1_FUNC_MAX_BANDWIDTH_OFFSET                      18
-
-	struct nvm_cfg_mac_address	fcoe_node_wwn_mac_addr;	/* 0x1C */
-
-	struct nvm_cfg_mac_address	fcoe_port_wwn_mac_addr;	/* 0x24 */
-	u32				preboot_generic_cfg;    /* 0x2C */
-	u32				reserved[8];            /* 0x30 */
+	struct nvm_cfg_mac_address mac_address;
+	u32 rsrv1;
+	u32 rsrv2;
+	u32 device_id;
+	u32 cmn_cfg;
+	u32 pci_cfg;
+	struct nvm_cfg_mac_address fcoe_node_wwn_mac_addr;
+	struct nvm_cfg_mac_address fcoe_port_wwn_mac_addr;
+	u32 preboot_generic_cfg;
+	u32 reserved[8];
 };
 
 struct nvm_cfg1 {
-	struct nvm_cfg1_glob	glob;				/* 0x0 */
-
-	struct nvm_cfg1_path	path[MCP_GLOB_PATH_MAX];	/* 0x140 */
-
-	struct nvm_cfg1_port	port[MCP_GLOB_PORT_MAX];	/* 0x230 */
-
-	struct nvm_cfg1_func	func[MCP_GLOB_FUNC_MAX];	/* 0xB90 */
-};
-
-/******************************************
-* nvm_cfg structs
-******************************************/
-
-enum nvm_cfg_sections {
-	NVM_CFG_SECTION_NVM_CFG1,
-	NVM_CFG_SECTION_MAX
-};
-
-struct nvm_cfg {
-	u32		num_sections;
-	u32		sections_offset[NVM_CFG_SECTION_MAX];
-	struct nvm_cfg1 cfg1;
-};
-
-#define PORT_0          0
-#define PORT_1          1
-#define PORT_2          2
-#define PORT_3          3
-
-extern struct spad_layout g_spad;
-
-#define MCP_SPAD_SIZE                       0x00028000  /* 160 KB */
-
-#define SPAD_OFFSET(addr) (((u32)addr - (u32)CPU_SPAD_BASE))
-
-#define TO_OFFSIZE(_offset, _size)				\
-	(u32)((((u32)(_offset) >> 2) << OFFSIZE_OFFSET_SHIFT) |	\
-	      (((u32)(_size) >> 2) << OFFSIZE_SIZE_SHIFT))
-
-enum spad_sections {
-	SPAD_SECTION_TRACE,
-	SPAD_SECTION_NVM_CFG,
-	SPAD_SECTION_PUBLIC,
-	SPAD_SECTION_PRIVATE,
-	SPAD_SECTION_MAX
-};
-
-struct spad_layout {
-	struct nvm_cfg		nvm_cfg;
-	struct mcp_public_data	public_data;
+	struct nvm_cfg1_glob glob;
+	struct nvm_cfg1_path path[MCP_GLOB_PATH_MAX];
+	struct nvm_cfg1_port port[MCP_GLOB_PORT_MAX];
+	struct nvm_cfg1_func func[MCP_GLOB_FUNC_MAX];
 };
-
-#define CRC_MAGIC_VALUE                     0xDEBB20E3
-#define CRC32_POLYNOMIAL                    0xEDB88320
-#define NVM_CRC_SIZE                            (sizeof(u32))
-
-enum nvm_sw_arbitrator {
-	NVM_SW_ARB_HOST,
-	NVM_SW_ARB_MCP,
-	NVM_SW_ARB_UART,
-	NVM_SW_ARB_RESERVED
-};
-
-/****************************************************************************
-* Boot Strap Region                                                        *
-****************************************************************************/
-struct legacy_bootstrap_region {
-	u32	magic_value;
-#define NVM_MAGIC_VALUE          0x669955aa
-	u32	sram_start_addr;
-	u32	code_len;               /* boot code length (in dwords) */
-	u32	code_start_addr;
-	u32	crc;                    /* 32-bit CRC */
-};
-
-/****************************************************************************
-* Directories Region                                                       *
-****************************************************************************/
-struct nvm_code_entry {
-	u32	image_type;             /* Image type */
-	u32	nvm_start_addr;         /* NVM address of the image */
-	u32	len;                    /* Include CRC */
-	u32	sram_start_addr;
-	u32	sram_run_addr;          /* Relevant in case of MIM only */
-};
-
-enum nvm_image_type {
-	NVM_TYPE_TIM1		= 0x01,
-	NVM_TYPE_TIM2		= 0x02,
-	NVM_TYPE_MIM1		= 0x03,
-	NVM_TYPE_MIM2		= 0x04,
-	NVM_TYPE_MBA		= 0x05,
-	NVM_TYPE_MODULES_PN	= 0x06,
-	NVM_TYPE_VPD		= 0x07,
-	NVM_TYPE_MFW_TRACE1	= 0x08,
-	NVM_TYPE_MFW_TRACE2	= 0x09,
-	NVM_TYPE_NVM_CFG1	= 0x0a,
-	NVM_TYPE_L2B		= 0x0b,
-	NVM_TYPE_DIR1		= 0x0c,
-	NVM_TYPE_EAGLE_FW1	= 0x0d,
-	NVM_TYPE_FALCON_FW1	= 0x0e,
-	NVM_TYPE_PCIE_FW1	= 0x0f,
-	NVM_TYPE_HW_SET		= 0x10,
-	NVM_TYPE_LIM		= 0x11,
-	NVM_TYPE_AVS_FW1	= 0x12,
-	NVM_TYPE_DIR2		= 0x13,
-	NVM_TYPE_CCM		= 0x14,
-	NVM_TYPE_EAGLE_FW2	= 0x15,
-	NVM_TYPE_FALCON_FW2	= 0x16,
-	NVM_TYPE_PCIE_FW2	= 0x17,
-	NVM_TYPE_AVS_FW2	= 0x18,
-
-	NVM_TYPE_MAX,
-};
-
-#define MAX_NVM_DIR_ENTRIES 200
-
-struct nvm_dir {
-	s32 seq;
-#define NVM_DIR_NEXT_MFW_MASK   0x00000001
-#define NVM_DIR_SEQ_MASK        0xfffffffe
-#define NVM_DIR_NEXT_MFW(seq) ((seq) & NVM_DIR_NEXT_MFW_MASK)
-
-#define IS_DIR_SEQ_VALID(seq) ((seq & NVM_DIR_SEQ_MASK) != NVM_DIR_SEQ_MASK)
-
-	u32			num_images;
-	u32			rsrv;
-	struct nvm_code_entry	code[1]; /* Up to MAX_NVM_DIR_ENTRIES */
-};
-
-#define NVM_DIR_SIZE(_num_images) (sizeof(struct nvm_dir) +		 \
-				   (_num_images -			 \
-				    1) * sizeof(struct nvm_code_entry) + \
-				   NVM_CRC_SIZE)
-
-struct nvm_vpd_image {
-	u32	format_revision;
-#define VPD_IMAGE_VERSION        1
-
-	/* This array length depends on the number of VPD fields */
-	u8	vpd_data[1];
-};
-
-/****************************************************************************
-* NVRAM FULL MAP                                                           *
-****************************************************************************/
-#define DIR_ID_1    (0)
-#define DIR_ID_2    (1)
-#define MAX_DIR_IDS (2)
-
-#define MFW_BUNDLE_1    (0)
-#define MFW_BUNDLE_2    (1)
-#define MAX_MFW_BUNDLES (2)
-
-#define FLASH_PAGE_SIZE 0x1000
-#define NVM_DIR_MAX_SIZE    (FLASH_PAGE_SIZE)           /* 4Kb */
-#define ASIC_MIM_MAX_SIZE   (300 * FLASH_PAGE_SIZE)     /* 1.2Mb */
-#define FPGA_MIM_MAX_SIZE   (25 * FLASH_PAGE_SIZE)      /* 60Kb */
-
-#define LIM_MAX_SIZE        ((2 *				      \
-			      FLASH_PAGE_SIZE) -		      \
-			     sizeof(struct legacy_bootstrap_region) - \
-			     NVM_RSV_SIZE)
-#define LIM_OFFSET          (NVM_OFFSET(lim_image))
-#define NVM_RSV_SIZE            (44)
-#define MIM_MAX_SIZE(is_asic) ((is_asic) ? ASIC_MIM_MAX_SIZE : \
-			       FPGA_MIM_MAX_SIZE)
-#define MIM_OFFSET(idx, is_asic) (NVM_OFFSET(dir[MAX_MFW_BUNDLES]) + \
-				  ((idx ==			     \
-				    NVM_TYPE_MIM2) ? MIM_MAX_SIZE(is_asic) : 0))
-#define NVM_FIXED_AREA_SIZE(is_asic) (sizeof(struct nvm_image) + \
-				      MIM_MAX_SIZE(is_asic) * 2)
-
-union nvm_dir_union {
-	struct nvm_dir	dir;
-	u8		page[FLASH_PAGE_SIZE];
-};
-
-/*                        Address
- *  +-------------------+ 0x000000
- *  |    Bootstrap:     |
- *  | magic_number      |
- *  | sram_start_addr   |
- *  | code_len          |
- *  | code_start_addr   |
- *  | crc               |
- *  +-------------------+ 0x000014
- *  | rsrv              |
- *  +-------------------+ 0x000040
- *  | LIM               |
- *  +-------------------+ 0x002000
- *  | Dir1              |
- *  +-------------------+ 0x003000
- *  | Dir2              |
- *  +-------------------+ 0x004000
- *  | MIM1              |
- *  +-------------------+ 0x130000
- *  | MIM2              |
- *  +-------------------+ 0x25C000
- *  | Rest Images:      |
- *  | TIM1/2            |
- *  | MFW_TRACE1/2      |
- *  | Eagle/Falcon FW   |
- *  | PCIE/AVS FW       |
- *  | MBA/CCM/L2B       |
- *  | VPD               |
- *  | optic_modules     |
- *  |  ...              |
- *  +-------------------+ 0x400000
- */
-struct nvm_image {
-/*********** !!!  FIXED SECTIONS  !!! DO NOT MODIFY !!! **********************/
-	/* NVM Offset  (size) */
-	struct legacy_bootstrap_region	bootstrap;
-	u8				rsrv[NVM_RSV_SIZE];
-	u8				lim_image[LIM_MAX_SIZE];
-	union nvm_dir_union		dir[MAX_MFW_BUNDLES];
-
-	/* MIM1_IMAGE                              0x004000 (0x12c000) */
-	/* MIM2_IMAGE                              0x130000 (0x12c000) */
-/*********** !!!  FIXED SECTIONS  !!! DO NOT MODIFY !!! **********************/
-};                              /* 0x134 */
-
-#define NVM_OFFSET(f)	((u32_t)((int_ptr_t)(&(((struct nvm_image *)0)->f))))
-
-struct hw_set_info {
-	u32	reg_type;
-#define GRC_REG_TYPE 1
-#define PHY_REG_TYPE 2
-#define PCI_REG_TYPE 4
-
-	u32	bank_num;
-	u32	pf_num;
-	u32	operation;
-#define READ_OP     1
-#define WRITE_OP    2
-#define RMW_SET_OP  3
-#define RMW_CLR_OP  4
-
-	u32	reg_addr;
-	u32	reg_data;
-
-	u32	reset_type;
-#define POR_RESET_TYPE	BIT(0)
-#define HARD_RESET_TYPE	BIT(1)
-#define CORE_RESET_TYPE	BIT(2)
-#define MCP_RESET_TYPE	BIT(3)
-#define PERSET_ASSERT	BIT(4)
-#define PERSET_DEASSERT	BIT(5)
-};
-
-struct hw_set_image {
-	u32			format_version;
-#define HW_SET_IMAGE_VERSION        1
-	u32			no_hw_sets;
-
-	/* This array length depends on the no_hw_sets */
-	struct hw_set_info	hw_sets[1];
-};
-
-int qed_init_pf_wfq(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
-		    u8 pf_id, u16 pf_wfq);
-int qed_init_vport_wfq(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
-		       u16 first_tx_pq_id[NUM_OF_TCS], u16 vport_wfq);
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hw.c b/drivers/net/ethernet/qlogic/qed/qed_hw.c
index 0ada7fd..7363d2b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hw.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_hw.c
@@ -446,7 +446,7 @@ qed_dmae_post_command(struct qed_hwfn *p_hwfn,
 			   idx_cmd,
 			   le32_to_cpu(command->opcode),
 			   le16_to_cpu(command->opcode_b),
-			   le16_to_cpu(command->length),
+			   le16_to_cpu(command->length_dw),
 			   le32_to_cpu(command->src_addr_hi),
 			   le32_to_cpu(command->src_addr_lo),
 			   le32_to_cpu(command->dst_addr_hi),
@@ -461,7 +461,7 @@ qed_dmae_post_command(struct qed_hwfn *p_hwfn,
 		   idx_cmd,
 		   le32_to_cpu(command->opcode),
 		   le16_to_cpu(command->opcode_b),
-		   le16_to_cpu(command->length),
+		   le16_to_cpu(command->length_dw),
 		   le32_to_cpu(command->src_addr_hi),
 		   le32_to_cpu(command->src_addr_lo),
 		   le32_to_cpu(command->dst_addr_hi),
@@ -645,7 +645,7 @@ static int qed_dmae_execute_sub_operation(struct qed_hwfn *p_hwfn,
 		return -EINVAL;
 	}
 
-	cmd->length = cpu_to_le16((u16)length);
+	cmd->length_dw = cpu_to_le16((u16)length);
 
 	qed_dmae_post_command(p_hwfn, p_ptt);
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
index e8a3b9d..23e455f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
@@ -31,7 +31,6 @@ enum cminterface {
 };
 
 /* general constants */
-#define QM_PQ_ELEMENT_SIZE                      4 /* in bytes */
 #define QM_PQ_MEM_4KB(pq_size)	(pq_size ? DIV_ROUND_UP((pq_size + 1) *	\
 							QM_PQ_ELEMENT_SIZE, \
 							0x1000) : 0)
@@ -44,28 +43,28 @@ enum cminterface {
 /* other PQ constants */
 #define QM_OTHER_PQS_PER_PF                     4
 /* WFQ constants */
-#define QM_WFQ_UPPER_BOUND		6250000
+#define QM_WFQ_UPPER_BOUND		62500000
 #define QM_WFQ_VP_PQ_VOQ_SHIFT          0
 #define QM_WFQ_VP_PQ_PF_SHIFT           5
 #define QM_WFQ_INC_VAL(weight)          ((weight) * 0x9000)
-#define QM_WFQ_MAX_INC_VAL                      4375000
-#define QM_WFQ_INIT_CRD(inc_val)        (2 * (inc_val))
+#define QM_WFQ_MAX_INC_VAL                      43750000
+
 /* RL constants */
-#define QM_RL_UPPER_BOUND                       6250000
+#define QM_RL_UPPER_BOUND                       62500000
 #define QM_RL_PERIOD                            5               /* in us */
 #define QM_RL_PERIOD_CLK_25M            (25 * QM_RL_PERIOD)
+#define QM_RL_MAX_INC_VAL                       43750000
 #define QM_RL_INC_VAL(rate)		max_t(u32,	\
-					      (((rate ? rate : 1000000)	\
-						* QM_RL_PERIOD) / 8), 1)
-#define QM_RL_MAX_INC_VAL                       4375000
+					      (u32)(((rate ? rate : \
+						      1000000) *    \
+						     QM_RL_PERIOD * \
+						     101) / (8 * 100)), 1)
 /* AFullOprtnstcCrdMask constants */
 #define QM_OPPOR_LINE_VOQ_DEF           1
 #define QM_OPPOR_FW_STOP_DEF            0
 #define QM_OPPOR_PQ_EMPTY_DEF           1
-#define EAGLE_WORKAROUND_TC                     7
 /* Command Queue constants */
 #define PBF_CMDQ_PURE_LB_LINES                          150
-#define PBF_CMDQ_EAGLE_WORKAROUND_LINES         8
 #define PBF_CMDQ_LINES_RT_OFFSET(voq)           (		 \
 		PBF_REG_YCMD_QS_NUM_LINES_VOQ0_RT_OFFSET + voq * \
 		(PBF_REG_YCMD_QS_NUM_LINES_VOQ1_RT_OFFSET -	 \
@@ -80,7 +79,6 @@ enum cminterface {
 /* BTB: blocks constants (block size = 256B) */
 #define BTB_JUMBO_PKT_BLOCKS            38
 #define BTB_HEADROOM_BLOCKS                     BTB_JUMBO_PKT_BLOCKS
-#define BTB_EAGLE_WORKAROUND_BLOCKS     4
 #define BTB_PURE_LB_FACTOR                      10
 #define BTB_PURE_LB_RATIO                       7
 /* QM stop command constants */
@@ -107,9 +105,9 @@ enum cminterface {
 						 cmd ## _ ## field,	  \
 						 value)
 /* QM: VOQ macros */
-#define PHYS_VOQ(port, tc, max_phy_tcs_pr_port)	((port) *	\
-						 (max_phy_tcs_pr_port) \
-						 + (tc))
+#define PHYS_VOQ(port, tc, max_phys_tcs_per_port) ((port) *	\
+						   (max_phys_tcs_per_port) + \
+						   (tc))
 #define LB_VOQ(port)				( \
 		MAX_PHYS_VOQS + (port))
 #define VOQ(port, tc, max_phy_tcs_pr_port)	\
@@ -120,8 +118,7 @@ enum cminterface {
 		: LB_VOQ(port))
 /******************** INTERNAL IMPLEMENTATION *********************/
 /* Prepare PF RL enable/disable runtime init values */
-static void qed_enable_pf_rl(struct qed_hwfn *p_hwfn,
-			     bool pf_rl_en)
+static void qed_enable_pf_rl(struct qed_hwfn *p_hwfn, bool pf_rl_en)
 {
 	STORE_RT_REG(p_hwfn, QM_REG_RLPFENABLE_RT_OFFSET, pf_rl_en ? 1 : 0);
 	if (pf_rl_en) {
@@ -130,8 +127,7 @@ static void qed_enable_pf_rl(struct qed_hwfn *p_hwfn,
 			     (1 << MAX_NUM_VOQS) - 1);
 		/* write RL period */
 		STORE_RT_REG(p_hwfn,
-			     QM_REG_RLPFPERIOD_RT_OFFSET,
-			     QM_RL_PERIOD_CLK_25M);
+			     QM_REG_RLPFPERIOD_RT_OFFSET, QM_RL_PERIOD_CLK_25M);
 		STORE_RT_REG(p_hwfn,
 			     QM_REG_RLPFPERIODTIMER_RT_OFFSET,
 			     QM_RL_PERIOD_CLK_25M);
@@ -144,8 +140,7 @@ static void qed_enable_pf_rl(struct qed_hwfn *p_hwfn,
 }
 
 /* Prepare PF WFQ enable/disable runtime init values */
-static void qed_enable_pf_wfq(struct qed_hwfn *p_hwfn,
-			      bool pf_wfq_en)
+static void qed_enable_pf_wfq(struct qed_hwfn *p_hwfn, bool pf_wfq_en)
 {
 	STORE_RT_REG(p_hwfn, QM_REG_WFQPFENABLE_RT_OFFSET, pf_wfq_en ? 1 : 0);
 	/* set credit threshold for QM bypass flow */
@@ -156,8 +151,7 @@ static void qed_enable_pf_wfq(struct qed_hwfn *p_hwfn,
 }
 
 /* Prepare VPORT RL enable/disable runtime init values */
-static void qed_enable_vport_rl(struct qed_hwfn *p_hwfn,
-				bool vport_rl_en)
+static void qed_enable_vport_rl(struct qed_hwfn *p_hwfn, bool vport_rl_en)
 {
 	STORE_RT_REG(p_hwfn, QM_REG_RLGLBLENABLE_RT_OFFSET,
 		     vport_rl_en ? 1 : 0);
@@ -178,8 +172,7 @@ static void qed_enable_vport_rl(struct qed_hwfn *p_hwfn,
 }
 
 /* Prepare VPORT WFQ enable/disable runtime init values */
-static void qed_enable_vport_wfq(struct qed_hwfn *p_hwfn,
-				 bool vport_wfq_en)
+static void qed_enable_vport_wfq(struct qed_hwfn *p_hwfn, bool vport_wfq_en)
 {
 	STORE_RT_REG(p_hwfn, QM_REG_WFQVPENABLE_RT_OFFSET,
 		     vport_wfq_en ? 1 : 0);
@@ -194,8 +187,7 @@ static void qed_enable_vport_wfq(struct qed_hwfn *p_hwfn,
  * the specified VOQ
  */
 static void qed_cmdq_lines_voq_rt_init(struct qed_hwfn *p_hwfn,
-				       u8 voq,
-				       u16 cmdq_lines)
+				       u8 voq, u16 cmdq_lines)
 {
 	u32 qm_line_crd;
 
@@ -221,7 +213,7 @@ static void qed_cmdq_lines_rt_init(
 	u8 max_phys_tcs_per_port,
 	struct init_qm_port_params port_params[MAX_NUM_PORTS])
 {
-	u8 tc, voq, port_id;
+	u8 tc, voq, port_id, num_tcs_in_port;
 
 	/* clear PBF lines for all VOQs */
 	for (voq = 0; voq < MAX_NUM_VOQS; voq++)
@@ -229,22 +221,31 @@ static void qed_cmdq_lines_rt_init(
 	for (port_id = 0; port_id < max_ports_per_engine; port_id++) {
 		if (port_params[port_id].active) {
 			u16 phys_lines, phys_lines_per_tc;
-			u8 phys_tcs = port_params[port_id].num_active_phys_tcs;
 
-			/* find #lines to divide between the active
-			 * physical TCs.
-			 */
+			/* find #lines to divide between active phys TCs */
 			phys_lines = port_params[port_id].num_pbf_cmd_lines -
 				     PBF_CMDQ_PURE_LB_LINES;
 			/* find #lines per active physical TC */
-			phys_lines_per_tc = phys_lines / phys_tcs;
+			num_tcs_in_port = 0;
+			for (tc = 0; tc < NUM_OF_PHYS_TCS; tc++) {
+				if (((port_params[port_id].active_phys_tcs >>
+				      tc) & 0x1) == 1)
+					num_tcs_in_port++;
+			}
+
+			phys_lines_per_tc = phys_lines / num_tcs_in_port;
 			/* init registers per active TC */
-			for (tc = 0; tc < phys_tcs; tc++) {
+			for (tc = 0; tc < NUM_OF_PHYS_TCS; tc++) {
+				if (((port_params[port_id].active_phys_tcs >>
+				      tc) & 0x1) != 1)
+					continue;
+
 				voq = PHYS_VOQ(port_id, tc,
 					       max_phys_tcs_per_port);
 				qed_cmdq_lines_voq_rt_init(p_hwfn, voq,
 							   phys_lines_per_tc);
 			}
+
 			/* init registers for pure LB TC */
 			qed_cmdq_lines_voq_rt_init(p_hwfn, LB_VOQ(port_id),
 						   PBF_CMDQ_PURE_LB_LINES);
@@ -259,34 +260,42 @@ static void qed_btb_blocks_rt_init(
 	struct init_qm_port_params port_params[MAX_NUM_PORTS])
 {
 	u32 usable_blocks, pure_lb_blocks, phys_blocks;
-	u8 tc, voq, port_id;
+	u8 tc, voq, port_id, num_tcs_in_port;
 
 	for (port_id = 0; port_id < max_ports_per_engine; port_id++) {
 		u32 temp;
-		u8 phys_tcs;
 
 		if (!port_params[port_id].active)
 			continue;
 
-		phys_tcs = port_params[port_id].num_active_phys_tcs;
-
 		/* subtract headroom blocks */
 		usable_blocks = port_params[port_id].num_btb_blocks -
 				BTB_HEADROOM_BLOCKS;
 
-		/* find blocks per physical TC. use factor to avoid
-		 * floating arithmethic.
-		 */
+		/* find blocks per physical TC */
+		num_tcs_in_port = 0;
+		for (tc = 0; tc < NUM_OF_PHYS_TCS; tc++) {
+			if (((port_params[port_id].active_phys_tcs >>
+			      tc) & 0x1) == 1)
+				num_tcs_in_port++;
+		}
+
 		pure_lb_blocks = (usable_blocks * BTB_PURE_LB_FACTOR) /
-				 (phys_tcs * BTB_PURE_LB_FACTOR +
+				 (num_tcs_in_port * BTB_PURE_LB_FACTOR +
 				  BTB_PURE_LB_RATIO);
 		pure_lb_blocks = max_t(u32, BTB_JUMBO_PKT_BLOCKS,
 				       pure_lb_blocks / BTB_PURE_LB_FACTOR);
-		phys_blocks = (usable_blocks - pure_lb_blocks) / phys_tcs;
+		phys_blocks = (usable_blocks - pure_lb_blocks) /
+			      num_tcs_in_port;
 
 		/* init physical TCs */
-		for (tc = 0; tc < phys_tcs; tc++) {
-			voq = PHYS_VOQ(port_id, tc, max_phys_tcs_per_port);
+		for (tc = 0; tc < NUM_OF_PHYS_TCS; tc++) {
+			if (((port_params[port_id].active_phys_tcs >>
+			      tc) & 0x1) != 1)
+				continue;
+
+			voq = PHYS_VOQ(port_id, tc,
+				       max_phys_tcs_per_port);
 			STORE_RT_REG(p_hwfn, PBF_BTB_GUARANTEED_RT_OFFSET(voq),
 				     phys_blocks);
 		}
@@ -360,10 +369,11 @@ static void qed_tx_pq_map_rt_init(
 		memset(&tx_pq_map, 0, sizeof(tx_pq_map));
 		SET_FIELD(tx_pq_map.reg, QM_RF_PQ_MAP_PQ_VALID, 1);
 		SET_FIELD(tx_pq_map.reg, QM_RF_PQ_MAP_RL_VALID,
-			  is_vf_pq ? 1 : 0);
+			  p_params->pq_params[i].rl_valid ? 1 : 0);
 		SET_FIELD(tx_pq_map.reg, QM_RF_PQ_MAP_VP_PQ_ID, first_tx_pq_id);
 		SET_FIELD(tx_pq_map.reg, QM_RF_PQ_MAP_RL_ID,
-			  is_vf_pq ? p_params->pq_params[i].vport_id : 0);
+			  p_params->pq_params[i].rl_valid ?
+			  p_params->pq_params[i].vport_id : 0);
 		SET_FIELD(tx_pq_map.reg, QM_RF_PQ_MAP_VOQ, voq);
 		SET_FIELD(tx_pq_map.reg, QM_RF_PQ_MAP_WRR_WEIGHT_GROUP,
 			  p_params->pq_params[i].wrr_group);
@@ -390,25 +400,11 @@ static void qed_tx_pq_map_rt_init(
 	/* store Tx PQ VF mask to size select register */
 	for (i = 0; i < num_tx_pq_vf_masks; i++) {
 		if (tx_pq_vf_mask[i]) {
-			if (is_bb_a0) {
-				u32 curr_mask = 0, addr;
-
-				addr = QM_REG_MAXPQSIZETXSEL_0 + (i * 4);
-				if (!p_params->is_first_pf)
-					curr_mask = qed_rd(p_hwfn, p_ptt,
-							   addr);
-
-				addr = QM_REG_MAXPQSIZETXSEL_0_RT_OFFSET + i;
-
-				STORE_RT_REG(p_hwfn, addr,
-					     curr_mask | tx_pq_vf_mask[i]);
-			} else {
-				u32 addr;
+			u32 addr;
 
-				addr = QM_REG_MAXPQSIZETXSEL_0_RT_OFFSET + i;
-				STORE_RT_REG(p_hwfn, addr,
-					     tx_pq_vf_mask[i]);
-			}
+			addr = QM_REG_MAXPQSIZETXSEL_0_RT_OFFSET + i;
+			STORE_RT_REG(p_hwfn, addr,
+				     tx_pq_vf_mask[i]);
 		}
 	}
 }
@@ -418,8 +414,7 @@ static void qed_other_pq_map_rt_init(struct qed_hwfn *p_hwfn,
 				     u8 port_id,
 				     u8 pf_id,
 				     u32 num_pf_cids,
-				     u32 num_tids,
-				     u32 base_mem_addr_4kb)
+				     u32 num_tids, u32 base_mem_addr_4kb)
 {
 	u16 i, pq_id;
 
@@ -465,15 +460,10 @@ static int qed_pf_wfq_rt_init(struct qed_hwfn *p_hwfn,
 				 (p_params->pf_id % MAX_NUM_PFS_BB);
 
 	inc_val = QM_WFQ_INC_VAL(p_params->pf_wfq);
-	if (inc_val > QM_WFQ_MAX_INC_VAL) {
+	if (!inc_val || inc_val > QM_WFQ_MAX_INC_VAL) {
 		DP_NOTICE(p_hwfn, "Invalid PF WFQ weight configuration");
 		return -1;
 	}
-	STORE_RT_REG(p_hwfn, QM_REG_WFQPFWEIGHT_RT_OFFSET + p_params->pf_id,
-		     inc_val);
-	STORE_RT_REG(p_hwfn,
-		     QM_REG_WFQPFUPPERBOUND_RT_OFFSET + p_params->pf_id,
-		     QM_WFQ_UPPER_BOUND | QM_WFQ_CRD_REG_SIGN_BIT);
 
 	for (i = 0; i < num_tx_pqs; i++) {
 		u8 voq = VOQ(p_params->port_id, p_params->pq_params[i].tc_id,
@@ -481,19 +471,21 @@ static int qed_pf_wfq_rt_init(struct qed_hwfn *p_hwfn,
 
 		OVERWRITE_RT_REG(p_hwfn,
 				 crd_reg_offset + voq * MAX_NUM_PFS_BB,
-				 QM_WFQ_INIT_CRD(inc_val) |
 				 QM_WFQ_CRD_REG_SIGN_BIT);
 	}
 
+	STORE_RT_REG(p_hwfn, QM_REG_WFQPFWEIGHT_RT_OFFSET + p_params->pf_id,
+		     inc_val);
+	STORE_RT_REG(p_hwfn,
+		     QM_REG_WFQPFUPPERBOUND_RT_OFFSET + p_params->pf_id,
+		     QM_WFQ_UPPER_BOUND | QM_WFQ_CRD_REG_SIGN_BIT);
 	return 0;
 }
 
 /* Prepare PF RL runtime init values for the specified PF.
  * Return -1 on error.
  */
-static int qed_pf_rl_rt_init(struct qed_hwfn *p_hwfn,
-			     u8 pf_id,
-			     u32 pf_rl)
+static int qed_pf_rl_rt_init(struct qed_hwfn *p_hwfn, u8 pf_id, u32 pf_rl)
 {
 	u32 inc_val = QM_RL_INC_VAL(pf_rl);
 
@@ -607,9 +599,7 @@ static bool qed_poll_on_qm_cmd_ready(struct qed_hwfn *p_hwfn,
 
 static bool qed_send_qm_cmd(struct qed_hwfn *p_hwfn,
 			    struct qed_ptt *p_ptt,
-			    u32 cmd_addr,
-			    u32 cmd_data_lsb,
-			    u32 cmd_data_msb)
+			    u32 cmd_addr, u32 cmd_data_lsb, u32 cmd_data_msb)
 {
 	if (!qed_poll_on_qm_cmd_ready(p_hwfn, p_ptt))
 		return false;
@@ -627,9 +617,7 @@ static bool qed_send_qm_cmd(struct qed_hwfn *p_hwfn,
 u32 qed_qm_pf_mem_size(u8 pf_id,
 		       u32 num_pf_cids,
 		       u32 num_vf_cids,
-		       u32 num_tids,
-		       u16 num_pf_pqs,
-		       u16 num_vf_pqs)
+		       u32 num_tids, u16 num_pf_pqs, u16 num_vf_pqs)
 {
 	return QM_PQ_MEM_4KB(num_pf_cids) * num_pf_pqs +
 	       QM_PQ_MEM_4KB(num_vf_cids) * num_vf_pqs +
@@ -713,8 +701,7 @@ int qed_qm_pf_rt_init(struct qed_hwfn *p_hwfn,
 }
 
 int qed_init_pf_wfq(struct qed_hwfn *p_hwfn,
-		    struct qed_ptt *p_ptt,
-		    u8 pf_id, u16 pf_wfq)
+		    struct qed_ptt *p_ptt, u8 pf_id, u16 pf_wfq)
 {
 	u32 inc_val = QM_WFQ_INC_VAL(pf_wfq);
 
@@ -728,9 +715,7 @@ int qed_init_pf_wfq(struct qed_hwfn *p_hwfn,
 }
 
 int qed_init_pf_rl(struct qed_hwfn *p_hwfn,
-		   struct qed_ptt *p_ptt,
-		   u8 pf_id,
-		   u32 pf_rl)
+		   struct qed_ptt *p_ptt, u8 pf_id, u32 pf_rl)
 {
 	u32 inc_val = QM_RL_INC_VAL(pf_rl);
 
@@ -749,8 +734,7 @@ int qed_init_pf_rl(struct qed_hwfn *p_hwfn,
 
 int qed_init_vport_wfq(struct qed_hwfn *p_hwfn,
 		       struct qed_ptt *p_ptt,
-		       u16 first_tx_pq_id[NUM_OF_TCS],
-		       u16 vport_wfq)
+		       u16 first_tx_pq_id[NUM_OF_TCS], u16 vport_wfq)
 {
 	u32 inc_val = QM_WFQ_INC_VAL(vport_wfq);
 	u8 tc;
@@ -773,9 +757,7 @@ int qed_init_vport_wfq(struct qed_hwfn *p_hwfn,
 }
 
 int qed_init_vport_rl(struct qed_hwfn *p_hwfn,
-		      struct qed_ptt *p_ptt,
-		      u8 vport_id,
-		      u32 vport_rl)
+		      struct qed_ptt *p_ptt, u8 vport_id, u32 vport_rl)
 {
 	u32 inc_val = QM_RL_INC_VAL(vport_rl);
 
@@ -795,9 +777,7 @@ int qed_init_vport_rl(struct qed_hwfn *p_hwfn,
 bool qed_send_qm_stop_cmd(struct qed_hwfn *p_hwfn,
 			  struct qed_ptt *p_ptt,
 			  bool is_release_cmd,
-			  bool is_tx_pq,
-			  u16 start_pq,
-			  u16 num_pqs)
+			  bool is_tx_pq, u16 start_pq, u16 num_pqs)
 {
 	u32 cmd_arr[QM_CMD_STRUCT_SIZE(QM_STOP_CMD)] = { 0 };
 	u32 pq_mask = 0, last_pq = start_pq + num_pqs - 1, pq_id;
@@ -841,17 +821,15 @@ qed_set_tunnel_type_enable_bit(unsigned long *var, int bit, bool enable)
 #define PRS_ETH_TUNN_FIC_FORMAT	-188897008
 
 void qed_set_vxlan_dest_port(struct qed_hwfn *p_hwfn,
-			     struct qed_ptt *p_ptt,
-			     u16 dest_port)
+			     struct qed_ptt *p_ptt, u16 dest_port)
 {
 	qed_wr(p_hwfn, p_ptt, PRS_REG_VXLAN_PORT, dest_port);
-	qed_wr(p_hwfn, p_ptt, NIG_REG_VXLAN_PORT, dest_port);
+	qed_wr(p_hwfn, p_ptt, NIG_REG_VXLAN_CTRL, dest_port);
 	qed_wr(p_hwfn, p_ptt, PBF_REG_VXLAN_PORT, dest_port);
 }
 
 void qed_set_vxlan_enable(struct qed_hwfn *p_hwfn,
-			  struct qed_ptt *p_ptt,
-			  bool vxlan_enable)
+			  struct qed_ptt *p_ptt, bool vxlan_enable)
 {
 	unsigned long reg_val = 0;
 	u8 shift;
@@ -908,8 +886,7 @@ void qed_set_gre_enable(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 }
 
 void qed_set_geneve_dest_port(struct qed_hwfn *p_hwfn,
-			      struct qed_ptt *p_ptt,
-			      u16 dest_port)
+			      struct qed_ptt *p_ptt, u16 dest_port)
 {
 	qed_wr(p_hwfn, p_ptt, PRS_REG_NGE_PORT, dest_port);
 	qed_wr(p_hwfn, p_ptt, NIG_REG_NGE_PORT, dest_port);
@@ -918,8 +895,7 @@ void qed_set_geneve_dest_port(struct qed_hwfn *p_hwfn,
 
 void qed_set_geneve_enable(struct qed_hwfn *p_hwfn,
 			   struct qed_ptt *p_ptt,
-			   bool eth_geneve_enable,
-			   bool ip_geneve_enable)
+			   bool eth_geneve_enable, bool ip_geneve_enable)
 {
 	unsigned long reg_val = 0;
 	u8 shift;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_init_ops.c b/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
index d358c3b..9866a20 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
@@ -543,8 +543,7 @@ void qed_gtt_init(struct qed_hwfn *p_hwfn)
 			       pxp_global_win[i]);
 }
 
-int qed_init_fw_data(struct qed_dev *cdev,
-		     const u8 *data)
+int qed_init_fw_data(struct qed_dev *cdev, const u8 *data)
 {
 	struct qed_fw_data *fw = cdev->fw_data;
 	struct bin_buffer_hdr *buf_hdr;
@@ -555,7 +554,11 @@ int qed_init_fw_data(struct qed_dev *cdev,
 		return -EINVAL;
 	}
 
-	buf_hdr = (struct bin_buffer_hdr *)data;
+	/* First Dword contains metadata and should be skipped */
+	buf_hdr = (struct bin_buffer_hdr *)(data + sizeof(u32));
+
+	offset = buf_hdr[BIN_BUF_FW_VER_INFO].offset;
+	fw->fw_ver_info = (struct fw_ver_info *)(data + offset);
 
 	offset = buf_hdr[BIN_BUF_INIT_CMD].offset;
 	fw->init_ops = (union init_op *)(data + offset);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 8fba87dd..2ee496e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -575,9 +575,12 @@ int qed_sp_eth_rxq_start_ramrod(struct qed_hwfn *p_hwfn,
 	p_ramrod->num_of_pbl_pages	= cpu_to_le16(cqe_pbl_size);
 	DMA_REGPAIR_LE(p_ramrod->cqe_pbl_addr, cqe_pbl_addr);
 
-	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+	p_ramrod->vf_rx_prod_index = params->vf_qid;
+	if (params->vf_qid)
+		DP_VERBOSE(p_hwfn, QED_MSG_SP,
+			   "Queue is meant for VF rxq[%04x]\n", params->vf_qid);
 
-	return rc;
+	return qed_spq_post(p_hwfn, p_ent, NULL);
 }
 
 static int
@@ -615,7 +618,7 @@ qed_sp_eth_rx_queue_start(struct qed_hwfn *p_hwfn,
 
 	*pp_prod = (u8 __iomem *)p_hwfn->regview +
 				 GTT_BAR0_MAP_REG_MSDM_RAM +
-				 MSTORM_PRODS_OFFSET(abs_l2_queue);
+				 MSTORM_ETH_PF_PRODS_OFFSET(abs_l2_queue);
 
 	/* Init the rcq, rx bd and rx sge (if valid) producers to 0 */
 	__internal_ram_wr(p_hwfn, *pp_prod, sizeof(u64),
@@ -759,9 +762,9 @@ int qed_sp_eth_txq_start_ramrod(struct qed_hwfn  *p_hwfn,
 	struct qed_spq_entry *p_ent = NULL;
 	struct qed_sp_init_data init_data;
 	struct qed_hw_cid_data *p_tx_cid;
-	u8 abs_vport_id;
+	u16 pq_id, abs_tx_q_id = 0;
 	int rc = -EINVAL;
-	u16 pq_id;
+	u8 abs_vport_id;
 
 	/* Store information for the stop */
 	p_tx_cid = &p_hwfn->p_tx_cids[p_params->queue_id];
@@ -772,6 +775,10 @@ int qed_sp_eth_txq_start_ramrod(struct qed_hwfn  *p_hwfn,
 	if (rc)
 		return rc;
 
+	rc = qed_fw_l2_queue(p_hwfn, p_params->queue_id, &abs_tx_q_id);
+	if (rc)
+		return rc;
+
 	/* Get SPQ entry */
 	memset(&init_data, 0, sizeof(init_data));
 	init_data.cid = cid;
@@ -791,6 +798,7 @@ int qed_sp_eth_txq_start_ramrod(struct qed_hwfn  *p_hwfn,
 	p_ramrod->sb_index		= p_params->sb_idx;
 	p_ramrod->stats_counter_id	= stats_id;
 
+	p_ramrod->queue_zone_id		= cpu_to_le16(abs_tx_q_id);
 	p_ramrod->pbl_size		= cpu_to_le16(pbl_size);
 	DMA_REGPAIR_LE(p_ramrod->pbl_base_addr, pbl_addr);
 
@@ -1485,51 +1493,51 @@ static void __qed_get_vport_port_stats(struct qed_hwfn *p_hwfn,
 			offsetof(struct public_port, stats),
 			sizeof(port_stats));
 
-	p_stats->rx_64_byte_packets		+= port_stats.pmm.r64;
-	p_stats->rx_65_to_127_byte_packets	+= port_stats.pmm.r127;
-	p_stats->rx_128_to_255_byte_packets	+= port_stats.pmm.r255;
-	p_stats->rx_256_to_511_byte_packets	+= port_stats.pmm.r511;
-	p_stats->rx_512_to_1023_byte_packets	+= port_stats.pmm.r1023;
-	p_stats->rx_1024_to_1518_byte_packets	+= port_stats.pmm.r1518;
-	p_stats->rx_1519_to_1522_byte_packets	+= port_stats.pmm.r1522;
-	p_stats->rx_1519_to_2047_byte_packets	+= port_stats.pmm.r2047;
-	p_stats->rx_2048_to_4095_byte_packets	+= port_stats.pmm.r4095;
-	p_stats->rx_4096_to_9216_byte_packets	+= port_stats.pmm.r9216;
-	p_stats->rx_9217_to_16383_byte_packets	+= port_stats.pmm.r16383;
-	p_stats->rx_crc_errors			+= port_stats.pmm.rfcs;
-	p_stats->rx_mac_crtl_frames		+= port_stats.pmm.rxcf;
-	p_stats->rx_pause_frames		+= port_stats.pmm.rxpf;
-	p_stats->rx_pfc_frames			+= port_stats.pmm.rxpp;
-	p_stats->rx_align_errors		+= port_stats.pmm.raln;
-	p_stats->rx_carrier_errors		+= port_stats.pmm.rfcr;
-	p_stats->rx_oversize_packets		+= port_stats.pmm.rovr;
-	p_stats->rx_jabbers			+= port_stats.pmm.rjbr;
-	p_stats->rx_undersize_packets		+= port_stats.pmm.rund;
-	p_stats->rx_fragments			+= port_stats.pmm.rfrg;
-	p_stats->tx_64_byte_packets		+= port_stats.pmm.t64;
-	p_stats->tx_65_to_127_byte_packets	+= port_stats.pmm.t127;
-	p_stats->tx_128_to_255_byte_packets	+= port_stats.pmm.t255;
-	p_stats->tx_256_to_511_byte_packets	+= port_stats.pmm.t511;
-	p_stats->tx_512_to_1023_byte_packets	+= port_stats.pmm.t1023;
-	p_stats->tx_1024_to_1518_byte_packets	+= port_stats.pmm.t1518;
-	p_stats->tx_1519_to_2047_byte_packets	+= port_stats.pmm.t2047;
-	p_stats->tx_2048_to_4095_byte_packets	+= port_stats.pmm.t4095;
-	p_stats->tx_4096_to_9216_byte_packets	+= port_stats.pmm.t9216;
-	p_stats->tx_9217_to_16383_byte_packets	+= port_stats.pmm.t16383;
-	p_stats->tx_pause_frames		+= port_stats.pmm.txpf;
-	p_stats->tx_pfc_frames			+= port_stats.pmm.txpp;
-	p_stats->tx_lpi_entry_count		+= port_stats.pmm.tlpiec;
-	p_stats->tx_total_collisions		+= port_stats.pmm.tncl;
-	p_stats->rx_mac_bytes			+= port_stats.pmm.rbyte;
-	p_stats->rx_mac_uc_packets		+= port_stats.pmm.rxuca;
-	p_stats->rx_mac_mc_packets		+= port_stats.pmm.rxmca;
-	p_stats->rx_mac_bc_packets		+= port_stats.pmm.rxbca;
-	p_stats->rx_mac_frames_ok		+= port_stats.pmm.rxpok;
-	p_stats->tx_mac_bytes			+= port_stats.pmm.tbyte;
-	p_stats->tx_mac_uc_packets		+= port_stats.pmm.txuca;
-	p_stats->tx_mac_mc_packets		+= port_stats.pmm.txmca;
-	p_stats->tx_mac_bc_packets		+= port_stats.pmm.txbca;
-	p_stats->tx_mac_ctrl_frames		+= port_stats.pmm.txcf;
+	p_stats->rx_64_byte_packets		+= port_stats.eth.r64;
+	p_stats->rx_65_to_127_byte_packets	+= port_stats.eth.r127;
+	p_stats->rx_128_to_255_byte_packets	+= port_stats.eth.r255;
+	p_stats->rx_256_to_511_byte_packets	+= port_stats.eth.r511;
+	p_stats->rx_512_to_1023_byte_packets	+= port_stats.eth.r1023;
+	p_stats->rx_1024_to_1518_byte_packets	+= port_stats.eth.r1518;
+	p_stats->rx_1519_to_1522_byte_packets	+= port_stats.eth.r1522;
+	p_stats->rx_1519_to_2047_byte_packets	+= port_stats.eth.r2047;
+	p_stats->rx_2048_to_4095_byte_packets	+= port_stats.eth.r4095;
+	p_stats->rx_4096_to_9216_byte_packets	+= port_stats.eth.r9216;
+	p_stats->rx_9217_to_16383_byte_packets	+= port_stats.eth.r16383;
+	p_stats->rx_crc_errors			+= port_stats.eth.rfcs;
+	p_stats->rx_mac_crtl_frames		+= port_stats.eth.rxcf;
+	p_stats->rx_pause_frames		+= port_stats.eth.rxpf;
+	p_stats->rx_pfc_frames			+= port_stats.eth.rxpp;
+	p_stats->rx_align_errors		+= port_stats.eth.raln;
+	p_stats->rx_carrier_errors		+= port_stats.eth.rfcr;
+	p_stats->rx_oversize_packets		+= port_stats.eth.rovr;
+	p_stats->rx_jabbers			+= port_stats.eth.rjbr;
+	p_stats->rx_undersize_packets		+= port_stats.eth.rund;
+	p_stats->rx_fragments			+= port_stats.eth.rfrg;
+	p_stats->tx_64_byte_packets		+= port_stats.eth.t64;
+	p_stats->tx_65_to_127_byte_packets	+= port_stats.eth.t127;
+	p_stats->tx_128_to_255_byte_packets	+= port_stats.eth.t255;
+	p_stats->tx_256_to_511_byte_packets	+= port_stats.eth.t511;
+	p_stats->tx_512_to_1023_byte_packets	+= port_stats.eth.t1023;
+	p_stats->tx_1024_to_1518_byte_packets	+= port_stats.eth.t1518;
+	p_stats->tx_1519_to_2047_byte_packets	+= port_stats.eth.t2047;
+	p_stats->tx_2048_to_4095_byte_packets	+= port_stats.eth.t4095;
+	p_stats->tx_4096_to_9216_byte_packets	+= port_stats.eth.t9216;
+	p_stats->tx_9217_to_16383_byte_packets	+= port_stats.eth.t16383;
+	p_stats->tx_pause_frames		+= port_stats.eth.txpf;
+	p_stats->tx_pfc_frames			+= port_stats.eth.txpp;
+	p_stats->tx_lpi_entry_count		+= port_stats.eth.tlpiec;
+	p_stats->tx_total_collisions		+= port_stats.eth.tncl;
+	p_stats->rx_mac_bytes			+= port_stats.eth.rbyte;
+	p_stats->rx_mac_uc_packets		+= port_stats.eth.rxuca;
+	p_stats->rx_mac_mc_packets		+= port_stats.eth.rxmca;
+	p_stats->rx_mac_bc_packets		+= port_stats.eth.rxbca;
+	p_stats->rx_mac_frames_ok		+= port_stats.eth.rxpok;
+	p_stats->tx_mac_bytes			+= port_stats.eth.tbyte;
+	p_stats->tx_mac_uc_packets		+= port_stats.eth.txuca;
+	p_stats->tx_mac_mc_packets		+= port_stats.eth.txmca;
+	p_stats->tx_mac_bc_packets		+= port_stats.eth.txbca;
+	p_stats->tx_mac_ctrl_frames		+= port_stats.eth.txcf;
 	for (j = 0; j < 8; j++) {
 		p_stats->brb_truncates	+= port_stats.brb.brb_truncate[j];
 		p_stats->brb_discards	+= port_stats.brb.brb_discard[j];
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 7530646..c807f67 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -832,7 +832,8 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 			goto err2;
 		}
 
-		data = cdev->firmware->data;
+		/* First Dword used to diffrentiate between various sources */
+		data = cdev->firmware->data + sizeof(u32);
 	}
 
 	memset(&tunn_info, 0, sizeof(tunn_info));
@@ -991,8 +992,7 @@ static bool qed_can_link_change(struct qed_dev *cdev)
 	return true;
 }
 
-static int qed_set_link(struct qed_dev *cdev,
-			struct qed_link_params *params)
+static int qed_set_link(struct qed_dev *cdev, struct qed_link_params *params)
 {
 	struct qed_hwfn *hwfn;
 	struct qed_mcp_link_params *link_params;
@@ -1032,7 +1032,7 @@ static int qed_set_link(struct qed_dev *cdev,
 				NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_50G;
 		if (params->adv_speeds & 0)
 			link_params->speed.advertised_speeds |=
-				NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_100G;
+			    NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_BB_100G;
 	}
 	if (params->override_flags & QED_LINK_OVERRIDE_SPEED_FORCED_SPEED)
 		link_params->speed.forced_speed = params->forced_speed;
@@ -1053,19 +1053,19 @@ static int qed_set_link(struct qed_dev *cdev,
 	if (params->override_flags & QED_LINK_OVERRIDE_LOOPBACK_MODE) {
 		switch (params->loopback_mode) {
 		case QED_LINK_LOOPBACK_INT_PHY:
-			link_params->loopback_mode = PMM_LOOPBACK_INT_PHY;
+			link_params->loopback_mode = ETH_LOOPBACK_INT_PHY;
 			break;
 		case QED_LINK_LOOPBACK_EXT_PHY:
-			link_params->loopback_mode = PMM_LOOPBACK_EXT_PHY;
+			link_params->loopback_mode = ETH_LOOPBACK_EXT_PHY;
 			break;
 		case QED_LINK_LOOPBACK_EXT:
-			link_params->loopback_mode = PMM_LOOPBACK_EXT;
+			link_params->loopback_mode = ETH_LOOPBACK_EXT;
 			break;
 		case QED_LINK_LOOPBACK_MAC:
-			link_params->loopback_mode = PMM_LOOPBACK_MAC;
+			link_params->loopback_mode = ETH_LOOPBACK_MAC;
 			break;
 		default:
-			link_params->loopback_mode = PMM_LOOPBACK_NONE;
+			link_params->loopback_mode = ETH_LOOPBACK_NONE;
 			break;
 		}
 	}
@@ -1157,7 +1157,7 @@ static void qed_fill_link(struct qed_hwfn *hwfn,
 		NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_50G)
 		if_link->advertised_caps |= 0;
 	if (params.speed.advertised_speeds &
-		NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_100G)
+	    NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_BB_100G)
 		if_link->advertised_caps |= 0;
 
 	if (link_caps.speed_capabilities &
@@ -1174,7 +1174,7 @@ static void qed_fill_link(struct qed_hwfn *hwfn,
 		NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_50G)
 		if_link->supported_caps |= 0;
 	if (link_caps.speed_capabilities &
-		NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_100G)
+	    NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_BB_100G)
 		if_link->supported_caps |= 0;
 
 	if (link.link_up)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 1182361..2c143b3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -531,9 +531,9 @@ static void qed_mcp_handle_transceiver_change(struct qed_hwfn *p_hwfn,
 				  transceiver_data)));
 
 	transceiver_state = GET_FIELD(transceiver_state,
-				      PMM_TRANSCEIVER_STATE);
+				      ETH_TRANSCEIVER_STATE);
 
-	if (transceiver_state == PMM_TRANSCEIVER_STATE_PRESENT)
+	if (transceiver_state == ETH_TRANSCEIVER_STATE_PRESENT)
 		DP_NOTICE(p_hwfn, "Transceiver is present.\n");
 	else
 		DP_NOTICE(p_hwfn, "Transceiver is unplugged.\n");
@@ -668,14 +668,12 @@ static void qed_mcp_handle_link_change(struct qed_hwfn *p_hwfn,
 	qed_link_update(p_hwfn);
 }
 
-int qed_mcp_set_link(struct qed_hwfn *p_hwfn,
-		     struct qed_ptt *p_ptt,
-		     bool b_up)
+int qed_mcp_set_link(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt, bool b_up)
 {
 	struct qed_mcp_link_params *params = &p_hwfn->mcp_info->link_input;
 	struct qed_mcp_mb_params mb_params;
 	union drv_union_data union_data;
-	struct pmm_phy_cfg *phy_cfg;
+	struct eth_phy_cfg *phy_cfg;
 	int rc = 0;
 	u32 cmd;
 
@@ -685,9 +683,9 @@ int qed_mcp_set_link(struct qed_hwfn *p_hwfn,
 	cmd = b_up ? DRV_MSG_CODE_INIT_PHY : DRV_MSG_CODE_LINK_RESET;
 	if (!params->speed.autoneg)
 		phy_cfg->speed = params->speed.forced_speed;
-	phy_cfg->pause |= (params->pause.autoneg) ? PMM_PAUSE_AUTONEG : 0;
-	phy_cfg->pause |= (params->pause.forced_rx) ? PMM_PAUSE_RX : 0;
-	phy_cfg->pause |= (params->pause.forced_tx) ? PMM_PAUSE_TX : 0;
+	phy_cfg->pause |= (params->pause.autoneg) ? ETH_PAUSE_AUTONEG : 0;
+	phy_cfg->pause |= (params->pause.forced_rx) ? ETH_PAUSE_RX : 0;
+	phy_cfg->pause |= (params->pause.forced_tx) ? ETH_PAUSE_TX : 0;
 	phy_cfg->adv_speed = params->speed.advertised_speeds;
 	phy_cfg->loopback_mode = params->loopback_mode;
 
@@ -773,6 +771,34 @@ static u32 qed_mcp_get_shmem_func(struct qed_hwfn *p_hwfn,
 	return size;
 }
 
+int qed_hw_init_first_eth(struct qed_hwfn *p_hwfn,
+			  struct qed_ptt *p_ptt, u8 *p_pf)
+{
+	struct public_func shmem_info;
+	int i;
+
+	/* Find first Ethernet interface in port */
+	for (i = 0; i < NUM_OF_ENG_PFS(p_hwfn->cdev);
+	     i += p_hwfn->cdev->num_ports_in_engines) {
+		qed_mcp_get_shmem_func(p_hwfn, p_ptt, &shmem_info,
+				       MCP_PF_ID_BY_REL(p_hwfn, i));
+
+		if (shmem_info.config & FUNC_MF_CFG_FUNC_HIDE)
+			continue;
+
+		if ((shmem_info.config & FUNC_MF_CFG_PROTOCOL_MASK) ==
+		    FUNC_MF_CFG_PROTOCOL_ETHERNET) {
+			*p_pf = (u8)i;
+			return 0;
+		}
+	}
+
+	DP_NOTICE(p_hwfn,
+		  "Failed to find on port an ethernet interface in MF_SI mode\n");
+
+	return -EINVAL;
+}
+
 static void qed_mcp_update_bw(struct qed_hwfn *p_hwfn,
 			      struct qed_ptt *p_ptt)
 {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index 6dd59eb..7f319aa 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -457,4 +457,7 @@ int __qed_configure_pf_min_bandwidth(struct qed_hwfn *p_hwfn,
 				     struct qed_ptt *p_ptt,
 				     struct qed_mcp_link_state *p_link,
 				     u8 min_bw);
+
+int qed_hw_init_first_eth(struct qed_hwfn *p_hwfn,
+			  struct qed_ptt *p_ptt, u8 *p_pf);
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index 3a6c506..b889585 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -167,6 +167,10 @@
 	0x1800004UL
 #define  NIG_REG_CM_HDR \
 	0x500840UL
+#define NIG_REG_LLH_TAGMAC_DEF_PF_VECTOR \
+	0x50196cUL
+#define NIG_REG_LLH_CLS_TYPE_DUALMODE \
+	0x501964UL
 #define  NCSI_REG_CONFIG	\
 	0x040200UL
 #define  PBF_REG_INIT \
@@ -219,6 +223,8 @@
 	0x230000UL
 #define  PRS_REG_SOFT_RST \
 	0x1f0000UL
+#define PRS_REG_MSG_INFO \
+	0x1f0a1cUL
 #define  PSDM_REG_ENABLE_IN1 \
 	0xfa0004UL
 #define  PSEM_REG_ENABLE_IN \
@@ -460,7 +466,7 @@
 #define NIG_REG_ENC_TYPE_ENABLE_VXLAN_ENABLE			(0x1 << 2)
 #define NIG_REG_ENC_TYPE_ENABLE_VXLAN_ENABLE_SHIFT		2
 
-#define NIG_REG_VXLAN_PORT		0x50105cUL
+#define NIG_REG_VXLAN_CTRL		0x50105cUL
 #define PBF_REG_VXLAN_PORT		0xd80518UL
 #define PBF_REG_NGE_PORT		0xd8051cUL
 #define PRS_REG_NGE_PORT		0x1f086cUL
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index 67f6ce3..1225064 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -332,7 +332,7 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 	p_ramrod->path_id		= QED_PATH_ID(p_hwfn);
 	p_ramrod->dont_log_ramrods	= 0;
 	p_ramrod->log_type_mask		= cpu_to_le16(0xf);
-	p_ramrod->mf_mode = mode;
+
 	switch (mode) {
 	case QED_MF_DEFAULT:
 	case QED_MF_NPAR:
@@ -368,6 +368,8 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 		p_ramrod->base_vf_id = (u8) p_iov->first_vf_in_pf;
 		p_ramrod->num_vfs = (u8) p_iov->total_vfs;
 	}
+	p_ramrod->hsi_fp_ver.major_ver_arr[ETH_VER_KEY] = ETH_HSI_VER_MAJOR;
+	p_ramrod->hsi_fp_ver.minor_ver_arr[ETH_VER_KEY] = ETH_HSI_VER_MINOR;
 
 	DP_VERBOSE(p_hwfn, QED_MSG_SPQ,
 		   "Setting event_ring_sb [id %04x index %02x], outer_tag [%d]\n",
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index c325ee8..eb75b82 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -47,6 +47,8 @@ static int qed_sp_vf_start(struct qed_hwfn *p_hwfn,
 	p_ramrod->opaque_fid = cpu_to_le16(opaque_vfid);
 
 	p_ramrod->personality = PERSONALITY_ETH;
+	p_ramrod->hsi_fp_ver.major_ver_arr[ETH_VER_KEY] = ETH_HSI_VER_MAJOR;
+	p_ramrod->hsi_fp_ver.minor_ver_arr[ETH_VER_KEY] = ETH_HSI_VER_MINOR;
 
 	return qed_spq_post(p_hwfn, p_ent, NULL);
 }
@@ -1585,10 +1587,6 @@ static void qed_iov_vf_mbx_stop_vport(struct qed_hwfn *p_hwfn,
 			     sizeof(struct pfvf_def_resp_tlv), status);
 }
 
-#define TSTORM_QZONE_START   PXP_VF_BAR0_START_SDM_ZONE_A
-#define MSTORM_QZONE_START(dev)   (TSTORM_QZONE_START +	\
-				   (TSTORM_QZONE_SIZE * NUM_OF_L2_QUEUES(dev)))
-
 static void qed_iov_vf_mbx_start_rxq_resp(struct qed_hwfn *p_hwfn,
 					  struct qed_ptt *p_ptt,
 					  struct qed_vf_info *vf, u8 status)
@@ -1606,16 +1604,11 @@ static void qed_iov_vf_mbx_start_rxq_resp(struct qed_hwfn *p_hwfn,
 
 	/* Update the TLV with the response */
 	if (status == PFVF_STATUS_SUCCESS) {
-		u16 hw_qid = 0;
-
 		req = &mbx->req_virt->start_rxq;
-		qed_fw_l2_queue(p_hwfn, vf->vf_queues[req->rx_qid].fw_rx_qid,
-				&hw_qid);
-
-		p_tlv->offset = MSTORM_QZONE_START(p_hwfn->cdev) +
-				hw_qid * MSTORM_QZONE_SIZE +
-				offsetof(struct mstorm_eth_queue_zone,
-					 rx_producers);
+		p_tlv->offset = PXP_VF_BAR0_START_MSDM_ZONE_B +
+				offsetof(struct mstorm_vf_zone,
+					 non_trigger.eth_rx_queue_producers) +
+				sizeof(struct eth_rx_prod_data) * req->rx_qid;
 	}
 
 	qed_iov_send_response(p_hwfn, p_ptt, vf, sizeof(*p_tlv), status);
@@ -1634,6 +1627,7 @@ static void qed_iov_vf_mbx_start_rxq(struct qed_hwfn *p_hwfn,
 	memset(&params, 0, sizeof(params));
 	req = &mbx->req_virt->start_rxq;
 	params.queue_id =  vf->vf_queues[req->rx_qid].fw_rx_qid;
+	params.vf_qid = req->rx_qid;
 	params.vport_id = vf->vport_id;
 	params.sb = req->hw_sb;
 	params.sb_idx = req->sb_index;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index ad3cae3..6836d44 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -910,6 +910,8 @@ static int qede_selftest_transmit_traffic(struct qede_dev *edev,
 	memset(first_bd, 0, sizeof(*first_bd));
 	val = 1 << ETH_TX_1ST_BD_FLAGS_START_BD_SHIFT;
 	first_bd->data.bd_flags.bitfields = val;
+	val = skb->len & ETH_TX_DATA_1ST_BD_PKT_LEN_MASK;
+	first_bd->data.bitfields |= (val << ETH_TX_DATA_1ST_BD_PKT_LEN_SHIFT);
 
 	/* Map skb linear data for DMA and set in the first BD */
 	mapping = dma_map_single(&edev->pdev->dev, skb->data,
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 5d00d14..4f35247 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -577,8 +577,6 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 
 	/* Fill the parsing flags & params according to the requested offload */
 	if (xmit_type & XMIT_L4_CSUM) {
-		u16 temp = 1 << ETH_TX_DATA_1ST_BD_TUNN_CFG_OVERRIDE_SHIFT;
-
 		/* We don't re-calculate IP checksum as it is already done by
 		 * the upper stack
 		 */
@@ -588,14 +586,8 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 		if (xmit_type & XMIT_ENC) {
 			first_bd->data.bd_flags.bitfields |=
 				1 << ETH_TX_1ST_BD_FLAGS_IP_CSUM_SHIFT;
-		} else {
-			/* In cases when OS doesn't indicate for inner offloads
-			 * when packet is tunnelled, we need to override the HW
-			 * tunnel configuration so that packets are treated as
-			 * regular non tunnelled packets and no inner offloads
-			 * are done by the hardware.
-			 */
-			first_bd->data.bitfields |= cpu_to_le16(temp);
+			first_bd->data.bitfields |=
+			    1 << ETH_TX_DATA_1ST_BD_TUNN_FLAG_SHIFT;
 		}
 
 		/* If the packet is IPv6 with extension header, indicate that
@@ -653,6 +645,10 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 			tx_data_bd = (struct eth_tx_bd *)third_bd;
 			data_split = true;
 		}
+	} else {
+		first_bd->data.bitfields |=
+		    (skb->len & ETH_TX_DATA_1ST_BD_PKT_LEN_MASK) <<
+		    ETH_TX_DATA_1ST_BD_PKT_LEN_SHIFT;
 	}
 
 	/* Handle fragmented skb */
diff --git a/include/linux/qed/common_hsi.h b/include/linux/qed/common_hsi.h
index 3f14c7e..285189a 100644
--- a/include/linux/qed/common_hsi.h
+++ b/include/linux/qed/common_hsi.h
@@ -13,9 +13,19 @@
 
 #define X_FINAL_CLEANUP_AGG_INT 1
 
+/* Queue Zone sizes in bytes */
+#define TSTORM_QZONE_SIZE 8
+#define MSTORM_QZONE_SIZE 0
+#define USTORM_QZONE_SIZE 8
+#define XSTORM_QZONE_SIZE 8
+#define YSTORM_QZONE_SIZE 0
+#define PSTORM_QZONE_SIZE 0
+
+#define ETH_MAX_NUM_RX_QUEUES_PER_VF 16
+
 #define FW_MAJOR_VERSION	8
-#define FW_MINOR_VERSION	7
-#define FW_REVISION_VERSION	3
+#define FW_MINOR_VERSION	10
+#define FW_REVISION_VERSION	5
 #define FW_ENGINEERING_VERSION	0
 
 /***********************/
@@ -97,45 +107,86 @@
 #define DQ_XCM_AGG_VAL_SEL_REG6   7
 
 /* XCM agg val selection */
-#define DQ_XCM_ETH_EDPM_NUM_BDS_CMD \
-	DQ_XCM_AGG_VAL_SEL_WORD2
-#define DQ_XCM_ETH_TX_BD_CONS_CMD \
-	DQ_XCM_AGG_VAL_SEL_WORD3
-#define DQ_XCM_CORE_TX_BD_CONS_CMD \
-	DQ_XCM_AGG_VAL_SEL_WORD3
-#define DQ_XCM_ETH_TX_BD_PROD_CMD \
-	DQ_XCM_AGG_VAL_SEL_WORD4
-#define DQ_XCM_CORE_TX_BD_PROD_CMD \
-	DQ_XCM_AGG_VAL_SEL_WORD4
-#define DQ_XCM_CORE_SPQ_PROD_CMD \
-	DQ_XCM_AGG_VAL_SEL_WORD4
-#define DQ_XCM_ETH_GO_TO_BD_CONS_CMD            DQ_XCM_AGG_VAL_SEL_WORD5
+#define	DQ_XCM_CORE_TX_BD_CONS_CMD	DQ_XCM_AGG_VAL_SEL_WORD3
+#define	DQ_XCM_CORE_TX_BD_PROD_CMD	DQ_XCM_AGG_VAL_SEL_WORD4
+#define	DQ_XCM_CORE_SPQ_PROD_CMD	DQ_XCM_AGG_VAL_SEL_WORD4
+#define	DQ_XCM_ETH_EDPM_NUM_BDS_CMD	DQ_XCM_AGG_VAL_SEL_WORD2
+#define	DQ_XCM_ETH_TX_BD_CONS_CMD	DQ_XCM_AGG_VAL_SEL_WORD3
+#define	DQ_XCM_ETH_TX_BD_PROD_CMD	DQ_XCM_AGG_VAL_SEL_WORD4
+#define	DQ_XCM_ETH_GO_TO_BD_CONS_CMD	DQ_XCM_AGG_VAL_SEL_WORD5
+
+/* UCM agg val selection (HW) */
+#define	DQ_UCM_AGG_VAL_SEL_WORD0	0
+#define	DQ_UCM_AGG_VAL_SEL_WORD1	1
+#define	DQ_UCM_AGG_VAL_SEL_WORD2	2
+#define	DQ_UCM_AGG_VAL_SEL_WORD3	3
+#define	DQ_UCM_AGG_VAL_SEL_REG0	4
+#define	DQ_UCM_AGG_VAL_SEL_REG1	5
+#define	DQ_UCM_AGG_VAL_SEL_REG2	6
+#define	DQ_UCM_AGG_VAL_SEL_REG3	7
+
+/* UCM agg val selection (FW) */
+#define DQ_UCM_ETH_PMD_TX_CONS_CMD	DQ_UCM_AGG_VAL_SEL_WORD2
+#define DQ_UCM_ETH_PMD_RX_CONS_CMD	DQ_UCM_AGG_VAL_SEL_WORD3
+#define DQ_UCM_ROCE_CQ_CONS_CMD		DQ_UCM_AGG_VAL_SEL_REG0
+#define DQ_UCM_ROCE_CQ_PROD_CMD		DQ_UCM_AGG_VAL_SEL_REG2
+
+/* TCM agg val selection (HW) */
+#define	DQ_TCM_AGG_VAL_SEL_WORD0	0
+#define	DQ_TCM_AGG_VAL_SEL_WORD1	1
+#define	DQ_TCM_AGG_VAL_SEL_WORD2	2
+#define	DQ_TCM_AGG_VAL_SEL_WORD3	3
+#define	DQ_TCM_AGG_VAL_SEL_REG1		4
+#define	DQ_TCM_AGG_VAL_SEL_REG2		5
+#define	DQ_TCM_AGG_VAL_SEL_REG6		6
+#define	DQ_TCM_AGG_VAL_SEL_REG9		7
+
+/* TCM agg val selection (FW) */
+#define DQ_TCM_L2B_BD_PROD_CMD \
+	DQ_TCM_AGG_VAL_SEL_WORD1
+#define DQ_TCM_ROCE_RQ_PROD_CMD	\
+	DQ_TCM_AGG_VAL_SEL_WORD0
 
 /* XCM agg counter flag selection */
-#define DQ_XCM_AGG_FLG_SHIFT_BIT14  0
-#define DQ_XCM_AGG_FLG_SHIFT_BIT15  1
-#define DQ_XCM_AGG_FLG_SHIFT_CF12   2
-#define DQ_XCM_AGG_FLG_SHIFT_CF13   3
-#define DQ_XCM_AGG_FLG_SHIFT_CF18   4
-#define DQ_XCM_AGG_FLG_SHIFT_CF19   5
-#define DQ_XCM_AGG_FLG_SHIFT_CF22   6
-#define DQ_XCM_AGG_FLG_SHIFT_CF23   7
+#define	DQ_XCM_AGG_FLG_SHIFT_BIT14	0
+#define	DQ_XCM_AGG_FLG_SHIFT_BIT15	1
+#define	DQ_XCM_AGG_FLG_SHIFT_CF12	2
+#define	DQ_XCM_AGG_FLG_SHIFT_CF13	3
+#define	DQ_XCM_AGG_FLG_SHIFT_CF18	4
+#define	DQ_XCM_AGG_FLG_SHIFT_CF19	5
+#define	DQ_XCM_AGG_FLG_SHIFT_CF22	6
+#define	DQ_XCM_AGG_FLG_SHIFT_CF23	7
 
 /* XCM agg counter flag selection */
-#define DQ_XCM_ETH_DQ_CF_CMD		(1 << \
-					DQ_XCM_AGG_FLG_SHIFT_CF18)
-#define DQ_XCM_CORE_DQ_CF_CMD		(1 << \
-					DQ_XCM_AGG_FLG_SHIFT_CF18)
-#define DQ_XCM_ETH_TERMINATE_CMD	(1 << \
-					DQ_XCM_AGG_FLG_SHIFT_CF19)
-#define DQ_XCM_CORE_TERMINATE_CMD	(1 << \
-					DQ_XCM_AGG_FLG_SHIFT_CF19)
-#define DQ_XCM_ETH_SLOW_PATH_CMD	(1 << \
-					DQ_XCM_AGG_FLG_SHIFT_CF22)
-#define DQ_XCM_CORE_SLOW_PATH_CMD	(1 << \
-					DQ_XCM_AGG_FLG_SHIFT_CF22)
-#define DQ_XCM_ETH_TPH_EN_CMD		(1 << \
-					DQ_XCM_AGG_FLG_SHIFT_CF23)
+#define DQ_XCM_CORE_DQ_CF_CMD		(1 << DQ_XCM_AGG_FLG_SHIFT_CF18)
+#define DQ_XCM_CORE_TERMINATE_CMD	(1 << DQ_XCM_AGG_FLG_SHIFT_CF19)
+#define DQ_XCM_CORE_SLOW_PATH_CMD	(1 << DQ_XCM_AGG_FLG_SHIFT_CF22)
+#define DQ_XCM_ETH_DQ_CF_CMD		(1 << DQ_XCM_AGG_FLG_SHIFT_CF18)
+#define DQ_XCM_ETH_TERMINATE_CMD	(1 << DQ_XCM_AGG_FLG_SHIFT_CF19)
+#define DQ_XCM_ETH_SLOW_PATH_CMD	(1 << DQ_XCM_AGG_FLG_SHIFT_CF22)
+#define DQ_XCM_ETH_TPH_EN_CMD		(1 << DQ_XCM_AGG_FLG_SHIFT_CF23)
+
+/* UCM agg counter flag selection (HW) */
+#define	DQ_UCM_AGG_FLG_SHIFT_CF0	0
+#define	DQ_UCM_AGG_FLG_SHIFT_CF1	1
+#define	DQ_UCM_AGG_FLG_SHIFT_CF3	2
+#define	DQ_UCM_AGG_FLG_SHIFT_CF4	3
+#define	DQ_UCM_AGG_FLG_SHIFT_CF5	4
+#define	DQ_UCM_AGG_FLG_SHIFT_CF6	5
+#define	DQ_UCM_AGG_FLG_SHIFT_RULE0EN	6
+#define	DQ_UCM_AGG_FLG_SHIFT_RULE1EN	7
+
+/* UCM agg counter flag selection (FW) */
+#define DQ_UCM_ETH_PMD_TX_ARM_CMD	(1 << DQ_UCM_AGG_FLG_SHIFT_CF4)
+#define DQ_UCM_ETH_PMD_RX_ARM_CMD	(1 << DQ_UCM_AGG_FLG_SHIFT_CF5)
+
+#define	DQ_REGION_SHIFT	(12)
+
+/* DPM */
+#define	DQ_DPM_WQE_BUFF_SIZE	(320)
+
+/* Conn type ranges */
+#define	DQ_CONN_TYPE_RANGE_SHIFT	(4)
 
 /*****************/
 /* QM CONSTANTS  */
@@ -282,8 +333,6 @@
 	(PXP_EXTERNAL_BAR_GLOBAL_WINDOW_START + \
 	 PXP_EXTERNAL_BAR_GLOBAL_WINDOW_LENGTH - 1)
 
-#define PXP_ILT_PAGE_SIZE_NUM_BITS_MIN	12
-#define PXP_ILT_BLOCK_FACTOR_MULTIPLIER	1024
 
 #define PXP_VF_BAR0_START_IGU                   0
 #define PXP_VF_BAR0_IGU_LENGTH                  0x3000
@@ -342,6 +391,9 @@
 
 #define PXP_VF_BAR0_GRC_WINDOW_LENGTH           32
 
+#define PXP_ILT_PAGE_SIZE_NUM_BITS_MIN		12
+#define PXP_ILT_BLOCK_FACTOR_MULTIPLIER		1024
+
 /* ILT Records */
 #define PXP_NUM_ILT_RECORDS_BB 7600
 #define PXP_NUM_ILT_RECORDS_K2 11000
@@ -379,6 +431,38 @@ struct async_data {
 	u8	fw_debug_param;
 };
 
+struct coalescing_timeset {
+	u8 value;
+#define	COALESCING_TIMESET_TIMESET_MASK		0x7F
+#define	COALESCING_TIMESET_TIMESET_SHIFT	0
+#define	COALESCING_TIMESET_VALID_MASK		0x1
+#define	COALESCING_TIMESET_VALID_SHIFT		7
+};
+
+struct common_prs_pf_msg_info {
+	__le32 value;
+#define	COMMON_PRS_PF_MSG_INFO_NPAR_DEFAULT_PF_MASK	0x1
+#define	COMMON_PRS_PF_MSG_INFO_NPAR_DEFAULT_PF_SHIFT	0
+#define	COMMON_PRS_PF_MSG_INFO_FW_DEBUG_1_MASK		0x1
+#define	COMMON_PRS_PF_MSG_INFO_FW_DEBUG_1_SHIFT		1
+#define	COMMON_PRS_PF_MSG_INFO_FW_DEBUG_2_MASK		0x1
+#define	COMMON_PRS_PF_MSG_INFO_FW_DEBUG_2_SHIFT		2
+#define	COMMON_PRS_PF_MSG_INFO_FW_DEBUG_3_MASK		0x1
+#define	COMMON_PRS_PF_MSG_INFO_FW_DEBUG_3_SHIFT		3
+#define	COMMON_PRS_PF_MSG_INFO_RESERVED_MASK		0xFFFFFFF
+#define	COMMON_PRS_PF_MSG_INFO_RESERVED_SHIFT		4
+};
+
+struct common_queue_zone {
+	__le16 ring_drv_data_consumer;
+	__le16 reserved;
+};
+
+struct eth_rx_prod_data {
+	__le16 bd_prod;
+	__le16 cqe_prod;
+};
+
 struct regpair {
 	__le32	lo;
 	__le32	hi;
@@ -388,11 +472,23 @@ struct vf_pf_channel_eqe_data {
 	struct regpair msg_addr;
 };
 
+struct malicious_vf_eqe_data {
+	u8 vf_id;
+	u8 err_id;
+	__le16 reserved[3];
+};
+
+struct initial_cleanup_eqe_data {
+	u8 vf_id;
+	u8 reserved[7];
+};
+
 /* Event Data Union */
 union event_ring_data {
-	u8				bytes[8];
-	struct vf_pf_channel_eqe_data	vf_pf_channel;
-	struct async_data		async_info;
+	u8 bytes[8];
+	struct vf_pf_channel_eqe_data vf_pf_channel;
+	struct malicious_vf_eqe_data malicious_vf;
+	struct initial_cleanup_eqe_data vf_init_cleanup;
 };
 
 /* Event Ring Entry */
@@ -433,6 +529,16 @@ enum protocol_type {
 	MAX_PROTOCOL_TYPE
 };
 
+struct ustorm_eth_queue_zone {
+	struct coalescing_timeset int_coalescing_timeset;
+	u8 reserved[3];
+};
+
+struct ustorm_queue_zone {
+	struct ustorm_eth_queue_zone eth;
+	struct common_queue_zone common;
+};
+
 /* status block structure */
 struct cau_pi_entry {
 	u32 prod;
@@ -683,19 +789,4 @@ struct status_block {
 #define STATUS_BLOCK_ZERO_PAD3_SHIFT  24
 };
 
-struct tunnel_parsing_flags {
-	u8 flags;
-#define TUNNEL_PARSING_FLAGS_TYPE_MASK              0x3
-#define TUNNEL_PARSING_FLAGS_TYPE_SHIFT             0
-#define TUNNEL_PARSING_FLAGS_TENNANT_ID_EXIST_MASK  0x1
-#define TUNNEL_PARSING_FLAGS_TENNANT_ID_EXIST_SHIFT 2
-#define TUNNEL_PARSING_FLAGS_NEXT_PROTOCOL_MASK     0x3
-#define TUNNEL_PARSING_FLAGS_NEXT_PROTOCOL_SHIFT    3
-#define TUNNEL_PARSING_FLAGS_FIRSTHDRIPMATCH_MASK   0x1
-#define TUNNEL_PARSING_FLAGS_FIRSTHDRIPMATCH_SHIFT  5
-#define TUNNEL_PARSING_FLAGS_IPV4_FRAGMENT_MASK     0x1
-#define TUNNEL_PARSING_FLAGS_IPV4_FRAGMENT_SHIFT    6
-#define TUNNEL_PARSING_FLAGS_IPV4_OPTIONS_MASK      0x1
-#define TUNNEL_PARSING_FLAGS_IPV4_OPTIONS_SHIFT     7
-};
 #endif /* __COMMON_HSI__ */
diff --git a/include/linux/qed/eth_common.h b/include/linux/qed/eth_common.h
index 092cb0c..b5ebc69 100644
--- a/include/linux/qed/eth_common.h
+++ b/include/linux/qed/eth_common.h
@@ -12,6 +12,8 @@
 /********************/
 /* ETH FW CONSTANTS */
 /********************/
+#define ETH_HSI_VER_MAJOR                   3
+#define ETH_HSI_VER_MINOR                   0
 #define ETH_CACHE_LINE_SIZE                 64
 
 #define ETH_MAX_RAMROD_PER_CON                          8
@@ -57,19 +59,6 @@
 #define ETH_TPA_CQE_CONT_LEN_LIST_SIZE    6
 #define ETH_TPA_CQE_END_LEN_LIST_SIZE     4
 
-/* Queue Zone sizes */
-#define TSTORM_QZONE_SIZE    0
-#define MSTORM_QZONE_SIZE    sizeof(struct mstorm_eth_queue_zone)
-#define USTORM_QZONE_SIZE    sizeof(struct ustorm_eth_queue_zone)
-#define XSTORM_QZONE_SIZE    0
-#define YSTORM_QZONE_SIZE    sizeof(struct ystorm_eth_queue_zone)
-#define PSTORM_QZONE_SIZE    0
-
-/* Interrupt coalescing TimeSet */
-struct coalescing_timeset {
-	u8	timeset;
-	u8	valid;
-};
 
 struct eth_tx_1st_bd_flags {
 	u8 bitfields;
@@ -97,12 +86,12 @@ struct eth_tx_data_1st_bd {
 	u8				nbds;
 	struct eth_tx_1st_bd_flags	bd_flags;
 	__le16				bitfields;
-#define ETH_TX_DATA_1ST_BD_TUNN_CFG_OVERRIDE_MASK  0x1
-#define ETH_TX_DATA_1ST_BD_TUNN_CFG_OVERRIDE_SHIFT 0
+#define ETH_TX_DATA_1ST_BD_TUNN_FLAG_MASK  0x1
+#define ETH_TX_DATA_1ST_BD_TUNN_FLAG_SHIFT 0
 #define ETH_TX_DATA_1ST_BD_RESERVED0_MASK          0x1
 #define ETH_TX_DATA_1ST_BD_RESERVED0_SHIFT         1
-#define ETH_TX_DATA_1ST_BD_FW_USE_ONLY_MASK        0x3FFF
-#define ETH_TX_DATA_1ST_BD_FW_USE_ONLY_SHIFT       2
+#define ETH_TX_DATA_1ST_BD_PKT_LEN_MASK    0x3FFF
+#define ETH_TX_DATA_1ST_BD_PKT_LEN_SHIFT   2
 };
 
 /* The parsing information data for the second tx bd of a given packet. */
@@ -136,28 +125,51 @@ struct eth_tx_data_2nd_bd {
 #define ETH_TX_DATA_2ND_BD_RESERVED0_SHIFT                13
 };
 
+struct eth_fast_path_cqe_fw_debug {
+	u8 reserved0;
+	u8 reserved1;
+	__le16 reserved2;
+};
+
+/*  tunneling parsing flags */
+struct eth_tunnel_parsing_flags {
+	u8 flags;
+#define	ETH_TUNNEL_PARSING_FLAGS_TYPE_MASK		0x3
+#define	ETH_TUNNEL_PARSING_FLAGS_TYPE_SHIFT		0
+#define	ETH_TUNNEL_PARSING_FLAGS_TENNANT_ID_EXIST_MASK	0x1
+#define	ETH_TUNNEL_PARSING_FLAGS_TENNANT_ID_EXIST_SHIFT	2
+#define	ETH_TUNNEL_PARSING_FLAGS_NEXT_PROTOCOL_MASK	0x3
+#define	ETH_TUNNEL_PARSING_FLAGS_NEXT_PROTOCOL_SHIFT	3
+#define	ETH_TUNNEL_PARSING_FLAGS_FIRSTHDRIPMATCH_MASK	0x1
+#define	ETH_TUNNEL_PARSING_FLAGS_FIRSTHDRIPMATCH_SHIFT	5
+#define	ETH_TUNNEL_PARSING_FLAGS_IPV4_FRAGMENT_MASK	0x1
+#define	ETH_TUNNEL_PARSING_FLAGS_IPV4_FRAGMENT_SHIFT	6
+#define	ETH_TUNNEL_PARSING_FLAGS_IPV4_OPTIONS_MASK	0x1
+#define	ETH_TUNNEL_PARSING_FLAGS_IPV4_OPTIONS_SHIFT	7
+};
+
 /* Regular ETH Rx FP CQE. */
 struct eth_fast_path_rx_reg_cqe {
-	u8	type;
-	u8	bitfields;
+	u8 type;
+	u8 bitfields;
 #define ETH_FAST_PATH_RX_REG_CQE_RSS_HASH_TYPE_MASK  0x7
 #define ETH_FAST_PATH_RX_REG_CQE_RSS_HASH_TYPE_SHIFT 0
 #define ETH_FAST_PATH_RX_REG_CQE_TC_MASK             0xF
 #define ETH_FAST_PATH_RX_REG_CQE_TC_SHIFT            3
 #define ETH_FAST_PATH_RX_REG_CQE_RESERVED0_MASK      0x1
 #define ETH_FAST_PATH_RX_REG_CQE_RESERVED0_SHIFT     7
-	__le16				pkt_len;
-	struct parsing_and_err_flags	pars_flags;
-	__le16				vlan_tag;
-	__le32				rss_hash;
-	__le16				len_on_first_bd;
-	u8				placement_offset;
-	struct tunnel_parsing_flags	tunnel_pars_flags;
-	u8				bd_num;
-	u8				reserved[7];
-	u32				fw_debug;
-	u8				reserved1[3];
-	u8				flags;
+	__le16 pkt_len;
+	struct parsing_and_err_flags pars_flags;
+	__le16 vlan_tag;
+	__le32 rss_hash;
+	__le16 len_on_first_bd;
+	u8 placement_offset;
+	struct eth_tunnel_parsing_flags tunnel_pars_flags;
+	u8 bd_num;
+	u8 reserved[7];
+	struct eth_fast_path_cqe_fw_debug fw_debug;
+	u8 reserved1[3];
+	u8 flags;
 #define ETH_FAST_PATH_RX_REG_CQE_VALID_MASK          0x1
 #define ETH_FAST_PATH_RX_REG_CQE_VALID_SHIFT         0
 #define ETH_FAST_PATH_RX_REG_CQE_VALID_TOGGLE_MASK   0x1
@@ -207,11 +219,11 @@ struct eth_fast_path_rx_tpa_start_cqe {
 	__le32	rss_hash;
 	__le16	len_on_first_bd;
 	u8	placement_offset;
-	struct tunnel_parsing_flags tunnel_pars_flags;
+	struct eth_tunnel_parsing_flags tunnel_pars_flags;
 	u8	tpa_agg_index;
 	u8	header_len;
 	__le16	ext_bd_len_list[ETH_TPA_CQE_START_LEN_LIST_SIZE];
-	u32	fw_debug;
+	struct eth_fast_path_cqe_fw_debug fw_debug;
 };
 
 /* The L4 pseudo checksum mode for Ethernet */
@@ -264,12 +276,25 @@ enum eth_rx_cqe_type {
 	MAX_ETH_RX_CQE_TYPE
 };
 
-/* ETH Rx producers data */
-struct eth_rx_prod_data {
-	__le16	bd_prod;
-	__le16	cqe_prod;
-	__le16	reserved;
-	__le16	reserved1;
+enum eth_rx_tunn_type {
+	ETH_RX_NO_TUNN,
+	ETH_RX_TUNN_GENEVE,
+	ETH_RX_TUNN_GRE,
+	ETH_RX_TUNN_VXLAN,
+	MAX_ETH_RX_TUNN_TYPE
+};
+
+/*  Aggregation end reason. */
+enum eth_tpa_end_reason {
+	ETH_AGG_END_UNUSED,
+	ETH_AGG_END_SP_UPDATE,
+	ETH_AGG_END_MAX_LEN,
+	ETH_AGG_END_LAST_SEG,
+	ETH_AGG_END_TIMEOUT,
+	ETH_AGG_END_NOT_CONSISTENT,
+	ETH_AGG_END_OUT_OF_ORDER,
+	ETH_AGG_END_NON_TPA_SEG,
+	MAX_ETH_TPA_END_REASON
 };
 
 /* The first tx bd of a given packet */
@@ -337,21 +362,18 @@ union eth_tx_bd_types {
 };
 
 /* Mstorm Queue Zone */
-struct mstorm_eth_queue_zone {
-	struct eth_rx_prod_data rx_producers;
-	__le32			reserved[2];
-};
-
-/* Ustorm Queue Zone */
-struct ustorm_eth_queue_zone {
-	struct coalescing_timeset	int_coalescing_timeset;
-	__le16				reserved[3];
+enum eth_tx_tunn_type {
+	ETH_TX_TUNN_GENEVE,
+	ETH_TX_TUNN_TTAG,
+	ETH_TX_TUNN_GRE,
+	ETH_TX_TUNN_VXLAN,
+	MAX_ETH_TX_TUNN_TYPE
 };
 
 /* Ystorm Queue Zone */
-struct ystorm_eth_queue_zone {
-	struct coalescing_timeset	int_coalescing_timeset;
-	__le16				reserved[3];
+struct xstorm_eth_queue_zone {
+	struct coalescing_timeset int_coalescing_timeset;
+	u8 reserved[7];
 };
 
 /* ETH doorbell data */
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index 6ae8cb4..f8ff711 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -113,6 +113,7 @@ struct qed_queue_start_common_params {
 	u8 vport_id;
 	u16 sb;
 	u16 sb_idx;
+	u16 vf_qid;
 };
 
 struct qed_tunn_params {
-- 
1.9.3
