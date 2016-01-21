From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] qed/qede: use 8.7.3.0 FW.
Date: Thu, 21 Jan 2016 14:28:01 +0200
Message-ID: <1453379281-4303-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Sudarsana Reddy Kalluru <Sudarsana.Kalluru@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:28182 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758970AbcAUM2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 07:28:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the qed* driver into utilizing the 8.7.3.0 FW.
This new FW is required for a lot of new SW features, including:
  - Vlan filtering offload
  - Encapsulation offload support
  - HW ingress aggregations
As well as paving the way for the possibility of adding storage protocols
in the future.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@qlogic.com>
Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h                |   43 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c            |   88 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h            | 2690 +++++++++-----------
 drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c  |   22 +-
 drivers/net/ethernet/qlogic/qed/qed_init_ops.c       |  155 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.c             |   13 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c           |    2 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.c            |   37 +-
 drivers/net/ethernet/qlogic/qed/qed_sp.h             |    2 +-
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c    |   17 +-
 drivers/net/ethernet/qlogic/qede/qede.h              |    5 +-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c      |    6 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c         |  262 +-
 include/linux/qed/common_hsi.h                       |   36 +-
 include/linux/qed/eth_common.h                       |  171 +-
 include/linux/qed/qed_if.h                           |    8 +-
 16 files changed, 1792 insertions(+), 1765 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 1292c36..d34da63 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -70,8 +70,8 @@ struct qed_sb_sp_info;
 struct qed_mcp_info;
 
 struct qed_rt_data {
-	u32 init_val;
-	bool b_valid;
+	u32	*init_val;
+	bool	*b_valid;
 };
 
 /* The PCI personality is not quite synonymous to protocol ID:
@@ -120,6 +120,10 @@ enum QED_PORT_MODE {
 	QED_PORT_MODE_DE_1X25G
 };
 
+enum qed_dev_cap {
+	QED_DEV_CAP_ETH,
+};
+
 struct qed_hw_info {
 	/* PCI personality */
 	enum qed_pci_personality	personality;
@@ -151,6 +155,7 @@ struct qed_hw_info {
 
 	u32				port_mode;
 	u32				hw_mode;
+	unsigned long		device_capabilities;
 };
 
 struct qed_hw_cid_data {
@@ -267,7 +272,7 @@ struct qed_hwfn {
 	struct qed_hw_info		hw_info;
 
 	/* rt_array (for init-tool) */
-	struct qed_rt_data		*rt_data;
+	struct qed_rt_data		rt_data;
 
 	/* SPQ */
 	struct qed_spq			*p_spq;
@@ -350,9 +355,20 @@ struct qed_dev {
 	char	name[NAME_SIZE];
 
 	u8	type;
-#define QED_DEV_TYPE_BB_A0      (0 << 0)
-#define QED_DEV_TYPE_MASK       (0x3)
-#define QED_DEV_TYPE_SHIFT      (0)
+#define QED_DEV_TYPE_BB (0 << 0)
+#define QED_DEV_TYPE_AH BIT(0)
+/* Translate type/revision combo into the proper conditions */
+#define QED_IS_BB(dev)  ((dev)->type == QED_DEV_TYPE_BB)
+#define QED_IS_BB_A0(dev)       (QED_IS_BB(dev) && \
+				 CHIP_REV_IS_A0(dev))
+#define QED_IS_BB_B0(dev)       (QED_IS_BB(dev) && \
+				 CHIP_REV_IS_B0(dev))
+
+#define QED_GET_TYPE(dev)       (QED_IS_BB_A0(dev) ? CHIP_BB_A0 : \
+				 QED_IS_BB_B0(dev) ? CHIP_BB_B0 : CHIP_K2)
+
+	u16	vendor_id;
+	u16	device_id;
 
 	u16	chip_num;
 #define CHIP_NUM_MASK                   0xffff
@@ -361,6 +377,8 @@ struct qed_dev {
 	u16	chip_rev;
 #define CHIP_REV_MASK                   0xf
 #define CHIP_REV_SHIFT                  12
+#define CHIP_REV_IS_A0(_cdev)   (!(_cdev)->chip_rev)
+#define CHIP_REV_IS_B0(_cdev)   ((_cdev)->chip_rev == 1)
 
 	u16				chip_metal;
 #define CHIP_METAL_MASK                 0xff
@@ -375,10 +393,10 @@ struct qed_dev {
 	u8				num_funcs_in_port;
 
 	u8				path_id;
-	enum mf_mode			mf_mode;
-#define IS_MF(_p_hwfn)          (((_p_hwfn)->cdev)->mf_mode != SF)
-#define IS_MF_SI(_p_hwfn)       (((_p_hwfn)->cdev)->mf_mode == MF_NPAR)
-#define IS_MF_SD(_p_hwfn)       (((_p_hwfn)->cdev)->mf_mode == MF_OVLAN)
+	enum qed_mf_mode		mf_mode;
+#define IS_MF_DEFAULT(_p_hwfn)  (((_p_hwfn)->cdev)->mf_mode == QED_MF_DEFAULT)
+#define IS_MF_SI(_p_hwfn)       (((_p_hwfn)->cdev)->mf_mode == QED_MF_NPAR)
+#define IS_MF_SD(_p_hwfn)       (((_p_hwfn)->cdev)->mf_mode == QED_MF_OVLAN)
 
 	int				pcie_width;
 	int				pcie_speed;
@@ -441,11 +459,6 @@ struct qed_dev {
 	const struct firmware		*firmware;
 };
 
-#define QED_GET_TYPE(dev)       (((dev)->type & QED_DEV_TYPE_MASK) >> \
-				 QED_DEV_TYPE_SHIFT)
-#define QED_IS_BB_A0(dev)       (QED_GET_TYPE(dev) == QED_DEV_TYPE_BB_A0)
-#define QED_IS_BB(dev)  (QED_IS_BB_A0(dev))
-
 #define NUM_OF_SBS(dev)         MAX_SB_PER_PATH_BB
 #define NUM_OF_ENG_PFS(dev)     MAX_NUM_PFS_BB
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 817bbd5..bc17ed2 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -341,11 +341,6 @@ void qed_resc_setup(struct qed_dev *cdev)
 	}
 }
 
-#define FINAL_CLEANUP_CMD_OFFSET        (0)
-#define FINAL_CLEANUP_CMD (0x1)
-#define FINAL_CLEANUP_VALID_OFFSET      (6)
-#define FINAL_CLEANUP_VFPF_ID_SHIFT     (7)
-#define FINAL_CLEANUP_COMP (0x2)
 #define FINAL_CLEANUP_POLL_CNT          (100)
 #define FINAL_CLEANUP_POLL_TIME         (10)
 int qed_final_cleanup(struct qed_hwfn *p_hwfn,
@@ -355,12 +350,14 @@ int qed_final_cleanup(struct qed_hwfn *p_hwfn,
 	u32 command = 0, addr, count = FINAL_CLEANUP_POLL_CNT;
 	int rc = -EBUSY;
 
-	addr = GTT_BAR0_MAP_REG_USDM_RAM + USTORM_FLR_FINAL_ACK_OFFSET;
+	addr = GTT_BAR0_MAP_REG_USDM_RAM +
+		USTORM_FLR_FINAL_ACK_OFFSET(p_hwfn->rel_pf_id);
 
-	command |= FINAL_CLEANUP_CMD << FINAL_CLEANUP_CMD_OFFSET;
-	command |= 1 << FINAL_CLEANUP_VALID_OFFSET;
-	command |= id << FINAL_CLEANUP_VFPF_ID_SHIFT;
-	command |= FINAL_CLEANUP_COMP << SDM_OP_GEN_COMP_TYPE_SHIFT;
+	command |= X_FINAL_CLEANUP_AGG_INT <<
+		SDM_AGG_INT_COMP_PARAMS_AGG_INT_INDEX_SHIFT;
+	command |= 1 << SDM_AGG_INT_COMP_PARAMS_AGG_VECTOR_ENABLE_SHIFT;
+	command |= id << SDM_AGG_INT_COMP_PARAMS_AGG_VECTOR_BIT_SHIFT;
+	command |= SDM_COMP_TYPE_AGG_INT << SDM_OP_GEN_COMP_TYPE_SHIFT;
 
 	/* Make sure notification is not set before initiating final cleanup */
 	if (REG_RD(p_hwfn, addr)) {
@@ -415,18 +412,16 @@ static void qed_calc_hw_mode(struct qed_hwfn *p_hwfn)
 	}
 
 	switch (p_hwfn->cdev->mf_mode) {
-	case SF:
-		hw_mode |= 1 << MODE_SF;
+	case QED_MF_DEFAULT:
+	case QED_MF_NPAR:
+		hw_mode |= 1 << MODE_MF_SI;
 		break;
-	case MF_OVLAN:
+	case QED_MF_OVLAN:
 		hw_mode |= 1 << MODE_MF_SD;
 		break;
-	case MF_NPAR:
-		hw_mode |= 1 << MODE_MF_SI;
-		break;
 	default:
-		DP_NOTICE(p_hwfn, "Unsupported MF mode, init as SF\n");
-		hw_mode |= 1 << MODE_SF;
+		DP_NOTICE(p_hwfn, "Unsupported MF mode, init as DEFAULT\n");
+		hw_mode |= 1 << MODE_MF_SI;
 	}
 
 	hw_mode |= 1 << MODE_ASIC;
@@ -1018,8 +1013,7 @@ static void qed_hw_get_resc(struct qed_hwfn *p_hwfn)
 	u32 *resc_num = p_hwfn->hw_info.resc_num;
 	int num_funcs, i;
 
-	num_funcs = IS_MF(p_hwfn) ? MAX_NUM_PFS_BB
-				  : p_hwfn->cdev->num_ports_in_engines;
+	num_funcs = MAX_NUM_PFS_BB;
 
 	resc_num[QED_SB] = min_t(u32,
 				 (MAX_SB_PER_PATH_BB / num_funcs),
@@ -1071,7 +1065,7 @@ static int qed_hw_get_nvm_info(struct qed_hwfn *p_hwfn,
 			       struct qed_ptt *p_ptt)
 {
 	u32 nvm_cfg1_offset, mf_mode, addr, generic_cont0, core_cfg;
-	u32 port_cfg_addr, link_temp, val, nvm_cfg_addr;
+	u32 port_cfg_addr, link_temp, nvm_cfg_addr, device_capabilities;
 	struct qed_mcp_link_params *link;
 
 	/* Read global nvm_cfg address */
@@ -1134,21 +1128,6 @@ static int qed_hw_get_nvm_info(struct qed_hwfn *p_hwfn,
 		break;
 	}
 
-	addr = MCP_REG_SCRATCH + nvm_cfg1_offset +
-	       offsetof(struct nvm_cfg1, func[MCP_PF_ID(p_hwfn)]) +
-	       offsetof(struct nvm_cfg1_func, device_id);
-	val = qed_rd(p_hwfn, p_ptt, addr);
-
-	if (IS_MF(p_hwfn)) {
-		p_hwfn->hw_info.device_id =
-			(val & NVM_CFG1_FUNC_MF_VENDOR_DEVICE_ID_MASK) >>
-			NVM_CFG1_FUNC_MF_VENDOR_DEVICE_ID_OFFSET;
-	} else {
-		p_hwfn->hw_info.device_id =
-			(val & NVM_CFG1_FUNC_VENDOR_DEVICE_ID_MASK) >>
-			NVM_CFG1_FUNC_VENDOR_DEVICE_ID_OFFSET;
-	}
-
 	/* Read default link configuration */
 	link = &p_hwfn->mcp_info->link_input;
 	port_cfg_addr = MCP_REG_SCRATCH + nvm_cfg1_offset +
@@ -1220,18 +1199,28 @@ static int qed_hw_get_nvm_info(struct qed_hwfn *p_hwfn,
 
 	switch (mf_mode) {
 	case NVM_CFG1_GLOB_MF_MODE_MF_ALLOWED:
-		p_hwfn->cdev->mf_mode = MF_OVLAN;
+		p_hwfn->cdev->mf_mode = QED_MF_OVLAN;
 		break;
 	case NVM_CFG1_GLOB_MF_MODE_NPAR1_0:
-		p_hwfn->cdev->mf_mode = MF_NPAR;
+		p_hwfn->cdev->mf_mode = QED_MF_NPAR;
 		break;
-	case NVM_CFG1_GLOB_MF_MODE_FORCED_SF:
-		p_hwfn->cdev->mf_mode = SF;
+	case NVM_CFG1_GLOB_MF_MODE_DEFAULT:
+		p_hwfn->cdev->mf_mode = QED_MF_DEFAULT;
 		break;
 	}
 	DP_INFO(p_hwfn, "Multi function mode is %08x\n",
 		p_hwfn->cdev->mf_mode);
 
+	/* Read Multi-function information from shmem */
+	addr = MCP_REG_SCRATCH + nvm_cfg1_offset +
+		offsetof(struct nvm_cfg1, glob) +
+		offsetof(struct nvm_cfg1_glob, device_capabilities);
+
+	device_capabilities = qed_rd(p_hwfn, p_ptt, addr);
+	if (device_capabilities & NVM_CFG1_GLOB_DEVICE_CAPABILITIES_ETHERNET)
+		__set_bit(QED_DEV_CAP_ETH,
+			  &p_hwfn->hw_info.device_capabilities);
+
 	return qed_mcp_fill_shmem_func_info(p_hwfn, p_ptt);
 }
 
@@ -1293,29 +1282,36 @@ qed_get_hw_info(struct qed_hwfn *p_hwfn,
 
 static void qed_get_dev_info(struct qed_dev *cdev)
 {
+	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
 	u32 tmp;
 
-	cdev->chip_num = (u16)qed_rd(cdev->hwfns, cdev->hwfns[0].p_main_ptt,
+	/* Read Vendor Id / Device Id */
+	pci_read_config_word(cdev->pdev, PCI_VENDOR_ID,
+			     &cdev->vendor_id);
+	pci_read_config_word(cdev->pdev, PCI_DEVICE_ID,
+			     &cdev->device_id);
+	cdev->chip_num = (u16)qed_rd(p_hwfn, p_hwfn->p_main_ptt,
 				     MISCS_REG_CHIP_NUM);
-	cdev->chip_rev = (u16)qed_rd(cdev->hwfns, cdev->hwfns[0].p_main_ptt,
+	cdev->chip_rev = (u16)qed_rd(p_hwfn, p_hwfn->p_main_ptt,
 				     MISCS_REG_CHIP_REV);
 	MASK_FIELD(CHIP_REV, cdev->chip_rev);
 
+	cdev->type = QED_DEV_TYPE_BB;
 	/* Learn number of HW-functions */
-	tmp = qed_rd(cdev->hwfns, cdev->hwfns[0].p_main_ptt,
+	tmp = qed_rd(p_hwfn, p_hwfn->p_main_ptt,
 		     MISCS_REG_CMT_ENABLED_FOR_PAIR);
 
-	if (tmp & (1 << cdev->hwfns[0].rel_pf_id)) {
+	if (tmp & (1 << p_hwfn->rel_pf_id)) {
 		DP_NOTICE(cdev->hwfns, "device in CMT mode\n");
 		cdev->num_hwfns = 2;
 	} else {
 		cdev->num_hwfns = 1;
 	}
 
-	cdev->chip_bond_id = qed_rd(cdev->hwfns, cdev->hwfns[0].p_main_ptt,
+	cdev->chip_bond_id = qed_rd(p_hwfn, p_hwfn->p_main_ptt,
 				    MISCS_REG_CHIP_TEST_REG) >> 4;
 	MASK_FIELD(CHIP_BOND_ID, cdev->chip_bond_id);
-	cdev->chip_metal = (u16)qed_rd(cdev->hwfns, cdev->hwfns[0].p_main_ptt,
+	cdev->chip_metal = (u16)qed_rd(p_hwfn, p_hwfn->p_main_ptt,
 				       MISCS_REG_CHIP_METAL);
 	MASK_FIELD(CHIP_METAL, cdev->chip_metal);
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 264e954..49bbf69 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -34,6 +34,8 @@ enum common_event_opcode {
 	COMMON_EVENT_RESERVED3,
 	COMMON_EVENT_RESERVED4,
 	COMMON_EVENT_RESERVED5,
+	COMMON_EVENT_RESERVED6,
+	COMMON_EVENT_EMPTY,
 	MAX_COMMON_EVENT_OPCODE
 };
 
@@ -45,6 +47,7 @@ enum common_ramrod_cmd_id {
 	COMMON_RAMROD_RESERVED,
 	COMMON_RAMROD_RESERVED2,
 	COMMON_RAMROD_RESERVED3,
+	COMMON_RAMROD_EMPTY,
 	MAX_COMMON_RAMROD_CMD_ID
 };
 
@@ -331,6 +334,179 @@ struct xstorm_core_conn_ag_ctx {
 	__le16	word15 /* word15 */;
 };
 
+struct tstorm_core_conn_ag_ctx {
+	u8	byte0 /* cdu_validation */;
+	u8	byte1 /* state */;
+	u8	flags0;
+#define TSTORM_CORE_CONN_AG_CTX_BIT0_MASK     0x1       /* exist_in_qm0 */
+#define TSTORM_CORE_CONN_AG_CTX_BIT0_SHIFT    0
+#define TSTORM_CORE_CONN_AG_CTX_BIT1_MASK     0x1       /* exist_in_qm1 */
+#define TSTORM_CORE_CONN_AG_CTX_BIT1_SHIFT    1
+#define TSTORM_CORE_CONN_AG_CTX_BIT2_MASK     0x1       /* bit2 */
+#define TSTORM_CORE_CONN_AG_CTX_BIT2_SHIFT    2
+#define TSTORM_CORE_CONN_AG_CTX_BIT3_MASK     0x1       /* bit3 */
+#define TSTORM_CORE_CONN_AG_CTX_BIT3_SHIFT    3
+#define TSTORM_CORE_CONN_AG_CTX_BIT4_MASK     0x1       /* bit4 */
+#define TSTORM_CORE_CONN_AG_CTX_BIT4_SHIFT    4
+#define TSTORM_CORE_CONN_AG_CTX_BIT5_MASK     0x1       /* bit5 */
+#define TSTORM_CORE_CONN_AG_CTX_BIT5_SHIFT    5
+#define TSTORM_CORE_CONN_AG_CTX_CF0_MASK      0x3       /* timer0cf */
+#define TSTORM_CORE_CONN_AG_CTX_CF0_SHIFT     6
+	u8 flags1;
+#define TSTORM_CORE_CONN_AG_CTX_CF1_MASK      0x3       /* timer1cf */
+#define TSTORM_CORE_CONN_AG_CTX_CF1_SHIFT     0
+#define TSTORM_CORE_CONN_AG_CTX_CF2_MASK      0x3       /* timer2cf */
+#define TSTORM_CORE_CONN_AG_CTX_CF2_SHIFT     2
+#define TSTORM_CORE_CONN_AG_CTX_CF3_MASK      0x3       /* timer_stop_all */
+#define TSTORM_CORE_CONN_AG_CTX_CF3_SHIFT     4
+#define TSTORM_CORE_CONN_AG_CTX_CF4_MASK      0x3       /* cf4 */
+#define TSTORM_CORE_CONN_AG_CTX_CF4_SHIFT     6
+	u8 flags2;
+#define TSTORM_CORE_CONN_AG_CTX_CF5_MASK      0x3       /* cf5 */
+#define TSTORM_CORE_CONN_AG_CTX_CF5_SHIFT     0
+#define TSTORM_CORE_CONN_AG_CTX_CF6_MASK      0x3       /* cf6 */
+#define TSTORM_CORE_CONN_AG_CTX_CF6_SHIFT     2
+#define TSTORM_CORE_CONN_AG_CTX_CF7_MASK      0x3       /* cf7 */
+#define TSTORM_CORE_CONN_AG_CTX_CF7_SHIFT     4
+#define TSTORM_CORE_CONN_AG_CTX_CF8_MASK      0x3       /* cf8 */
+#define TSTORM_CORE_CONN_AG_CTX_CF8_SHIFT     6
+	u8 flags3;
+#define TSTORM_CORE_CONN_AG_CTX_CF9_MASK      0x3       /* cf9 */
+#define TSTORM_CORE_CONN_AG_CTX_CF9_SHIFT     0
+#define TSTORM_CORE_CONN_AG_CTX_CF10_MASK     0x3       /* cf10 */
+#define TSTORM_CORE_CONN_AG_CTX_CF10_SHIFT    2
+#define TSTORM_CORE_CONN_AG_CTX_CF0EN_MASK    0x1       /* cf0en */
+#define TSTORM_CORE_CONN_AG_CTX_CF0EN_SHIFT   4
+#define TSTORM_CORE_CONN_AG_CTX_CF1EN_MASK    0x1       /* cf1en */
+#define TSTORM_CORE_CONN_AG_CTX_CF1EN_SHIFT   5
+#define TSTORM_CORE_CONN_AG_CTX_CF2EN_MASK    0x1       /* cf2en */
+#define TSTORM_CORE_CONN_AG_CTX_CF2EN_SHIFT   6
+#define TSTORM_CORE_CONN_AG_CTX_CF3EN_MASK    0x1       /* cf3en */
+#define TSTORM_CORE_CONN_AG_CTX_CF3EN_SHIFT   7
+	u8 flags4;
+#define TSTORM_CORE_CONN_AG_CTX_CF4EN_MASK    0x1       /* cf4en */
+#define TSTORM_CORE_CONN_AG_CTX_CF4EN_SHIFT   0
+#define TSTORM_CORE_CONN_AG_CTX_CF5EN_MASK    0x1       /* cf5en */
+#define TSTORM_CORE_CONN_AG_CTX_CF5EN_SHIFT   1
+#define TSTORM_CORE_CONN_AG_CTX_CF6EN_MASK    0x1       /* cf6en */
+#define TSTORM_CORE_CONN_AG_CTX_CF6EN_SHIFT   2
+#define TSTORM_CORE_CONN_AG_CTX_CF7EN_MASK    0x1       /* cf7en */
+#define TSTORM_CORE_CONN_AG_CTX_CF7EN_SHIFT   3
+#define TSTORM_CORE_CONN_AG_CTX_CF8EN_MASK    0x1       /* cf8en */
+#define TSTORM_CORE_CONN_AG_CTX_CF8EN_SHIFT   4
+#define TSTORM_CORE_CONN_AG_CTX_CF9EN_MASK    0x1       /* cf9en */
+#define TSTORM_CORE_CONN_AG_CTX_CF9EN_SHIFT   5
+#define TSTORM_CORE_CONN_AG_CTX_CF10EN_MASK   0x1       /* cf10en */
+#define TSTORM_CORE_CONN_AG_CTX_CF10EN_SHIFT  6
+#define TSTORM_CORE_CONN_AG_CTX_RULE0EN_MASK  0x1       /* rule0en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE0EN_SHIFT 7
+	u8 flags5;
+#define TSTORM_CORE_CONN_AG_CTX_RULE1EN_MASK  0x1       /* rule1en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE1EN_SHIFT 0
+#define TSTORM_CORE_CONN_AG_CTX_RULE2EN_MASK  0x1       /* rule2en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE2EN_SHIFT 1
+#define TSTORM_CORE_CONN_AG_CTX_RULE3EN_MASK  0x1       /* rule3en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE3EN_SHIFT 2
+#define TSTORM_CORE_CONN_AG_CTX_RULE4EN_MASK  0x1       /* rule4en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE4EN_SHIFT 3
+#define TSTORM_CORE_CONN_AG_CTX_RULE5EN_MASK  0x1       /* rule5en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE5EN_SHIFT 4
+#define TSTORM_CORE_CONN_AG_CTX_RULE6EN_MASK  0x1       /* rule6en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE6EN_SHIFT 5
+#define TSTORM_CORE_CONN_AG_CTX_RULE7EN_MASK  0x1       /* rule7en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE7EN_SHIFT 6
+#define TSTORM_CORE_CONN_AG_CTX_RULE8EN_MASK  0x1       /* rule8en */
+#define TSTORM_CORE_CONN_AG_CTX_RULE8EN_SHIFT 7
+	__le32	reg0 /* reg0 */;
+	__le32	reg1 /* reg1 */;
+	__le32	reg2 /* reg2 */;
+	__le32	reg3 /* reg3 */;
+	__le32	reg4 /* reg4 */;
+	__le32	reg5 /* reg5 */;
+	__le32	reg6 /* reg6 */;
+	__le32	reg7 /* reg7 */;
+	__le32	reg8 /* reg8 */;
+	u8	byte2 /* byte2 */;
+	u8	byte3 /* byte3 */;
+	__le16	word0 /* word0 */;
+	u8	byte4 /* byte4 */;
+	u8	byte5 /* byte5 */;
+	__le16	word1 /* word1 */;
+	__le16	word2 /* conn_dpi */;
+	__le16	word3 /* word3 */;
+	__le32	reg9 /* reg9 */;
+	__le32	reg10 /* reg10 */;
+};
+
+struct ustorm_core_conn_ag_ctx {
+	u8	reserved /* cdu_validation */;
+	u8	byte1 /* state */;
+	u8	flags0;
+#define USTORM_CORE_CONN_AG_CTX_BIT0_MASK     0x1       /* exist_in_qm0 */
+#define USTORM_CORE_CONN_AG_CTX_BIT0_SHIFT    0
+#define USTORM_CORE_CONN_AG_CTX_BIT1_MASK     0x1       /* exist_in_qm1 */
+#define USTORM_CORE_CONN_AG_CTX_BIT1_SHIFT    1
+#define USTORM_CORE_CONN_AG_CTX_CF0_MASK      0x3       /* timer0cf */
+#define USTORM_CORE_CONN_AG_CTX_CF0_SHIFT     2
+#define USTORM_CORE_CONN_AG_CTX_CF1_MASK      0x3       /* timer1cf */
+#define USTORM_CORE_CONN_AG_CTX_CF1_SHIFT     4
+#define USTORM_CORE_CONN_AG_CTX_CF2_MASK      0x3       /* timer2cf */
+#define USTORM_CORE_CONN_AG_CTX_CF2_SHIFT     6
+	u8 flags1;
+#define USTORM_CORE_CONN_AG_CTX_CF3_MASK      0x3       /* timer_stop_all */
+#define USTORM_CORE_CONN_AG_CTX_CF3_SHIFT     0
+#define USTORM_CORE_CONN_AG_CTX_CF4_MASK      0x3       /* cf4 */
+#define USTORM_CORE_CONN_AG_CTX_CF4_SHIFT     2
+#define USTORM_CORE_CONN_AG_CTX_CF5_MASK      0x3       /* cf5 */
+#define USTORM_CORE_CONN_AG_CTX_CF5_SHIFT     4
+#define USTORM_CORE_CONN_AG_CTX_CF6_MASK      0x3       /* cf6 */
+#define USTORM_CORE_CONN_AG_CTX_CF6_SHIFT     6
+	u8 flags2;
+#define USTORM_CORE_CONN_AG_CTX_CF0EN_MASK    0x1       /* cf0en */
+#define USTORM_CORE_CONN_AG_CTX_CF0EN_SHIFT   0
+#define USTORM_CORE_CONN_AG_CTX_CF1EN_MASK    0x1       /* cf1en */
+#define USTORM_CORE_CONN_AG_CTX_CF1EN_SHIFT   1
+#define USTORM_CORE_CONN_AG_CTX_CF2EN_MASK    0x1       /* cf2en */
+#define USTORM_CORE_CONN_AG_CTX_CF2EN_SHIFT   2
+#define USTORM_CORE_CONN_AG_CTX_CF3EN_MASK    0x1       /* cf3en */
+#define USTORM_CORE_CONN_AG_CTX_CF3EN_SHIFT   3
+#define USTORM_CORE_CONN_AG_CTX_CF4EN_MASK    0x1       /* cf4en */
+#define USTORM_CORE_CONN_AG_CTX_CF4EN_SHIFT   4
+#define USTORM_CORE_CONN_AG_CTX_CF5EN_MASK    0x1       /* cf5en */
+#define USTORM_CORE_CONN_AG_CTX_CF5EN_SHIFT   5
+#define USTORM_CORE_CONN_AG_CTX_CF6EN_MASK    0x1       /* cf6en */
+#define USTORM_CORE_CONN_AG_CTX_CF6EN_SHIFT   6
+#define USTORM_CORE_CONN_AG_CTX_RULE0EN_MASK  0x1       /* rule0en */
+#define USTORM_CORE_CONN_AG_CTX_RULE0EN_SHIFT 7
+	u8 flags3;
+#define USTORM_CORE_CONN_AG_CTX_RULE1EN_MASK  0x1       /* rule1en */
+#define USTORM_CORE_CONN_AG_CTX_RULE1EN_SHIFT 0
+#define USTORM_CORE_CONN_AG_CTX_RULE2EN_MASK  0x1       /* rule2en */
+#define USTORM_CORE_CONN_AG_CTX_RULE2EN_SHIFT 1
+#define USTORM_CORE_CONN_AG_CTX_RULE3EN_MASK  0x1       /* rule3en */
+#define USTORM_CORE_CONN_AG_CTX_RULE3EN_SHIFT 2
+#define USTORM_CORE_CONN_AG_CTX_RULE4EN_MASK  0x1       /* rule4en */
+#define USTORM_CORE_CONN_AG_CTX_RULE4EN_SHIFT 3
+#define USTORM_CORE_CONN_AG_CTX_RULE5EN_MASK  0x1       /* rule5en */
+#define USTORM_CORE_CONN_AG_CTX_RULE5EN_SHIFT 4
+#define USTORM_CORE_CONN_AG_CTX_RULE6EN_MASK  0x1       /* rule6en */
+#define USTORM_CORE_CONN_AG_CTX_RULE6EN_SHIFT 5
+#define USTORM_CORE_CONN_AG_CTX_RULE7EN_MASK  0x1       /* rule7en */
+#define USTORM_CORE_CONN_AG_CTX_RULE7EN_SHIFT 6
+#define USTORM_CORE_CONN_AG_CTX_RULE8EN_MASK  0x1       /* rule8en */
+#define USTORM_CORE_CONN_AG_CTX_RULE8EN_SHIFT 7
+	u8	byte2 /* byte2 */;
+	u8	byte3 /* byte3 */;
+	__le16	word0 /* conn_dpi */;
+	__le16	word1 /* word1 */;
+	__le32	rx_producers /* reg0 */;
+	__le32	reg1 /* reg1 */;
+	__le32	reg2 /* reg2 */;
+	__le32	reg3 /* reg3 */;
+	__le16	word2 /* word2 */;
+	__le16	word3 /* word3 */;
+};
+
 /* The core storm context for the Mstorm */
 struct mstorm_core_conn_st_ctx {
 	__le32 reserved[24];
@@ -349,8 +525,9 @@ struct core_conn_context {
 	struct regpair			pstorm_st_padding[2];
 	struct xstorm_core_conn_st_ctx	xstorm_st_context;
 	struct xstorm_core_conn_ag_ctx	xstorm_ag_context;
+	struct tstorm_core_conn_ag_ctx	tstorm_ag_context;
+	struct ustorm_core_conn_ag_ctx	ustorm_ag_context;
 	struct mstorm_core_conn_st_ctx	mstorm_st_context;
-	struct regpair			mstorm_st_padding[2];
 	struct ustorm_core_conn_st_ctx	ustorm_st_context;
 	struct regpair			ustorm_st_padding[2] /* padding */;
 };
@@ -397,10 +574,12 @@ union event_ring_element {
 };
 
 enum personality_type {
+	BAD_PERSONALITY_TYP,
 	PERSONALITY_RESERVED,
 	PERSONALITY_RESERVED2,
 	PERSONALITY_RDMA_AND_ETH /* Roce or Iwarp */,
 	PERSONALITY_RESERVED3,
+	PERSONALITY_CORE,
 	PERSONALITY_ETH /* Ethernet */,
 	PERSONALITY_RESERVED4,
 	MAX_PERSONALITY_TYPE
@@ -570,7 +749,7 @@ enum block_addr {
 	GRCBASE_NWM		= 0x800000,
 	GRCBASE_NWS		= 0x700000,
 	GRCBASE_MS		= 0x6a0000,
-	GRCBASE_PHY_PCIE	= 0x618000,
+	GRCBASE_PHY_PCIE	= 0x620000,
 	GRCBASE_MISC_AEU	= 0x8000,
 	GRCBASE_BAR0_MAP	= 0x1c00000,
 	MAX_BLOCK_ADDR
@@ -795,13 +974,13 @@ enum init_modes {
 	MODE_RESERVED3,
 	MODE_RESERVED4,
 	MODE_RESERVED5,
+	MODE_RESERVED6,
 	MODE_SF,
 	MODE_MF_SD,
 	MODE_MF_SI,
 	MODE_PORTS_PER_ENG_1,
 	MODE_PORTS_PER_ENG_2,
 	MODE_PORTS_PER_ENG_4,
-	MODE_40G,
 	MODE_100G,
 	MODE_EAGLE_ENG1_WORKAROUND,
 	MAX_INIT_MODES
@@ -816,43 +995,6 @@ enum init_phases {
 	MAX_INIT_PHASES
 };
 
-struct mstorm_core_conn_ag_ctx {
-	u8	byte0 /* cdu_validation */;
-	u8	byte1 /* state */;
-	u8	flags0;
-#define MSTORM_CORE_CONN_AG_CTX_BIT0_MASK     0x1       /* exist_in_qm0 */
-#define MSTORM_CORE_CONN_AG_CTX_BIT0_SHIFT    0
-#define MSTORM_CORE_CONN_AG_CTX_BIT1_MASK     0x1       /* exist_in_qm1 */
-#define MSTORM_CORE_CONN_AG_CTX_BIT1_SHIFT    1
-#define MSTORM_CORE_CONN_AG_CTX_CF0_MASK      0x3       /* cf0 */
-#define MSTORM_CORE_CONN_AG_CTX_CF0_SHIFT     2
-#define MSTORM_CORE_CONN_AG_CTX_CF1_MASK      0x3       /* cf1 */
-#define MSTORM_CORE_CONN_AG_CTX_CF1_SHIFT     4
-#define MSTORM_CORE_CONN_AG_CTX_CF2_MASK      0x3       /* cf2 */
-#define MSTORM_CORE_CONN_AG_CTX_CF2_SHIFT     6
-	u8 flags1;
-#define MSTORM_CORE_CONN_AG_CTX_CF0EN_MASK    0x1       /* cf0en */
-#define MSTORM_CORE_CONN_AG_CTX_CF0EN_SHIFT   0
-#define MSTORM_CORE_CONN_AG_CTX_CF1EN_MASK    0x1       /* cf1en */
-#define MSTORM_CORE_CONN_AG_CTX_CF1EN_SHIFT   1
-#define MSTORM_CORE_CONN_AG_CTX_CF2EN_MASK    0x1       /* cf2en */
-#define MSTORM_CORE_CONN_AG_CTX_CF2EN_SHIFT   2
-#define MSTORM_CORE_CONN_AG_CTX_RULE0EN_MASK  0x1       /* rule0en */
-#define MSTORM_CORE_CONN_AG_CTX_RULE0EN_SHIFT 3
-#define MSTORM_CORE_CONN_AG_CTX_RULE1EN_MASK  0x1       /* rule1en */
-#define MSTORM_CORE_CONN_AG_CTX_RULE1EN_SHIFT 4
-#define MSTORM_CORE_CONN_AG_CTX_RULE2EN_MASK  0x1       /* rule2en */
-#define MSTORM_CORE_CONN_AG_CTX_RULE2EN_SHIFT 5
-#define MSTORM_CORE_CONN_AG_CTX_RULE3EN_MASK  0x1       /* rule3en */
-#define MSTORM_CORE_CONN_AG_CTX_RULE3EN_SHIFT 6
-#define MSTORM_CORE_CONN_AG_CTX_RULE4EN_MASK  0x1       /* rule4en */
-#define MSTORM_CORE_CONN_AG_CTX_RULE4EN_SHIFT 7
-	__le16	word0 /* word0 */;
-	__le16	word1 /* word1 */;
-	__le32	reg0 /* reg0 */;
-	__le32	reg1 /* reg1 */;
-};
-
 /* per encapsulation type enabling flags */
 struct prs_reg_encapsulation_type_en {
 	u8 flags;
@@ -927,250 +1069,44 @@ struct qm_rf_opportunistic_mask {
 };
 
 /* QM hardware structure of QM map memory */
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
-struct tstorm_core_conn_ag_ctx {
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
-	u8 flags1;
-#define TSTORM_CORE_CONN_AG_CTX_CF1_MASK      0x3       /* timer1cf */
-#define TSTORM_CORE_CONN_AG_CTX_CF1_SHIFT     0
-#define TSTORM_CORE_CONN_AG_CTX_CF2_MASK      0x3       /* timer2cf */
-#define TSTORM_CORE_CONN_AG_CTX_CF2_SHIFT     2
-#define TSTORM_CORE_CONN_AG_CTX_CF3_MASK      0x3       /* timer_stop_all */
-#define TSTORM_CORE_CONN_AG_CTX_CF3_SHIFT     4
-#define TSTORM_CORE_CONN_AG_CTX_CF4_MASK      0x3       /* cf4 */
-#define TSTORM_CORE_CONN_AG_CTX_CF4_SHIFT     6
-	u8 flags2;
-#define TSTORM_CORE_CONN_AG_CTX_CF5_MASK      0x3       /* cf5 */
-#define TSTORM_CORE_CONN_AG_CTX_CF5_SHIFT     0
-#define TSTORM_CORE_CONN_AG_CTX_CF6_MASK      0x3       /* cf6 */
-#define TSTORM_CORE_CONN_AG_CTX_CF6_SHIFT     2
-#define TSTORM_CORE_CONN_AG_CTX_CF7_MASK      0x3       /* cf7 */
-#define TSTORM_CORE_CONN_AG_CTX_CF7_SHIFT     4
-#define TSTORM_CORE_CONN_AG_CTX_CF8_MASK      0x3       /* cf8 */
-#define TSTORM_CORE_CONN_AG_CTX_CF8_SHIFT     6
-	u8 flags3;
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
-	u8 flags4;
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
-	u8 flags5;
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
+struct qm_rf_pq_map {
+	u32 reg;
+#define QM_RF_PQ_MAP_PQ_VALID_MASK          0x1         /* PQ active */
+#define QM_RF_PQ_MAP_PQ_VALID_SHIFT         0
+#define QM_RF_PQ_MAP_RL_ID_MASK             0xFF        /* RL ID */
+#define QM_RF_PQ_MAP_RL_ID_SHIFT            1
+#define QM_RF_PQ_MAP_VP_PQ_ID_MASK          0x1FF
+#define QM_RF_PQ_MAP_VP_PQ_ID_SHIFT         9
+#define QM_RF_PQ_MAP_VOQ_MASK               0x1F        /* VOQ */
+#define QM_RF_PQ_MAP_VOQ_SHIFT              18
+#define QM_RF_PQ_MAP_WRR_WEIGHT_GROUP_MASK  0x3         /* WRR weight */
+#define QM_RF_PQ_MAP_WRR_WEIGHT_GROUP_SHIFT 23
+#define QM_RF_PQ_MAP_RL_VALID_MASK          0x1         /* RL active */
+#define QM_RF_PQ_MAP_RL_VALID_SHIFT         25
+#define QM_RF_PQ_MAP_RESERVED_MASK          0x3F
+#define QM_RF_PQ_MAP_RESERVED_SHIFT         26
 };
 
-struct ustorm_core_conn_ag_ctx {
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
-	u8 flags1;
-#define USTORM_CORE_CONN_AG_CTX_CF3_MASK      0x3       /* timer_stop_all */
-#define USTORM_CORE_CONN_AG_CTX_CF3_SHIFT     0
-#define USTORM_CORE_CONN_AG_CTX_CF4_MASK      0x3       /* cf4 */
-#define USTORM_CORE_CONN_AG_CTX_CF4_SHIFT     2
-#define USTORM_CORE_CONN_AG_CTX_CF5_MASK      0x3       /* cf5 */
-#define USTORM_CORE_CONN_AG_CTX_CF5_SHIFT     4
-#define USTORM_CORE_CONN_AG_CTX_CF6_MASK      0x3       /* cf6 */
-#define USTORM_CORE_CONN_AG_CTX_CF6_SHIFT     6
-	u8 flags2;
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
-	u8 flags3;
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
+/* Completion params for aggregated interrupt completion */
+struct sdm_agg_int_comp_params {
+	__le16 params;
+#define SDM_AGG_INT_COMP_PARAMS_AGG_INT_INDEX_MASK      0x3F
+#define SDM_AGG_INT_COMP_PARAMS_AGG_INT_INDEX_SHIFT     0
+#define SDM_AGG_INT_COMP_PARAMS_AGG_VECTOR_ENABLE_MASK  0x1
+#define SDM_AGG_INT_COMP_PARAMS_AGG_VECTOR_ENABLE_SHIFT 6
+#define SDM_AGG_INT_COMP_PARAMS_AGG_VECTOR_BIT_MASK     0x1FF
+#define SDM_AGG_INT_COMP_PARAMS_AGG_VECTOR_BIT_SHIFT    7
 };
 
-struct ystorm_core_conn_ag_ctx {
-	u8	byte0 /* cdu_validation */;
-	u8	byte1 /* state */;
-	u8	flags0;
-#define YSTORM_CORE_CONN_AG_CTX_BIT0_MASK     0x1       /* exist_in_qm0 */
-#define YSTORM_CORE_CONN_AG_CTX_BIT0_SHIFT    0
-#define YSTORM_CORE_CONN_AG_CTX_BIT1_MASK     0x1       /* exist_in_qm1 */
-#define YSTORM_CORE_CONN_AG_CTX_BIT1_SHIFT    1
-#define YSTORM_CORE_CONN_AG_CTX_CF0_MASK      0x3       /* cf0 */
-#define YSTORM_CORE_CONN_AG_CTX_CF0_SHIFT     2
-#define YSTORM_CORE_CONN_AG_CTX_CF1_MASK      0x3       /* cf1 */
-#define YSTORM_CORE_CONN_AG_CTX_CF1_SHIFT     4
-#define YSTORM_CORE_CONN_AG_CTX_CF2_MASK      0x3       /* cf2 */
-#define YSTORM_CORE_CONN_AG_CTX_CF2_SHIFT     6
-	u8 flags1;
-#define YSTORM_CORE_CONN_AG_CTX_CF0EN_MASK    0x1       /* cf0en */
-#define YSTORM_CORE_CONN_AG_CTX_CF0EN_SHIFT   0
-#define YSTORM_CORE_CONN_AG_CTX_CF1EN_MASK    0x1       /* cf1en */
-#define YSTORM_CORE_CONN_AG_CTX_CF1EN_SHIFT   1
-#define YSTORM_CORE_CONN_AG_CTX_CF2EN_MASK    0x1       /* cf2en */
-#define YSTORM_CORE_CONN_AG_CTX_CF2EN_SHIFT   2
-#define YSTORM_CORE_CONN_AG_CTX_RULE0EN_MASK  0x1       /* rule0en */
-#define YSTORM_CORE_CONN_AG_CTX_RULE0EN_SHIFT 3
-#define YSTORM_CORE_CONN_AG_CTX_RULE1EN_MASK  0x1       /* rule1en */
-#define YSTORM_CORE_CONN_AG_CTX_RULE1EN_SHIFT 4
-#define YSTORM_CORE_CONN_AG_CTX_RULE2EN_MASK  0x1       /* rule2en */
-#define YSTORM_CORE_CONN_AG_CTX_RULE2EN_SHIFT 5
-#define YSTORM_CORE_CONN_AG_CTX_RULE3EN_MASK  0x1       /* rule3en */
-#define YSTORM_CORE_CONN_AG_CTX_RULE3EN_SHIFT 6
-#define YSTORM_CORE_CONN_AG_CTX_RULE4EN_MASK  0x1       /* rule4en */
-#define YSTORM_CORE_CONN_AG_CTX_RULE4EN_SHIFT 7
-	u8	byte2 /* byte2 */;
-	u8	byte3 /* byte3 */;
-	__le16	word0 /* word0 */;
-	__le32	reg0 /* reg0 */;
-	__le32	reg1 /* reg1 */;
-	__le16	word1 /* word1 */;
-	__le16	word2 /* word2 */;
-	__le16	word3 /* word3 */;
-	__le16	word4 /* word4 */;
-	__le32	reg2 /* reg2 */;
-	__le32	reg3 /* reg3 */;
+/* SDM operation gen command (generate aggregative interrupt) */
+struct sdm_op_gen {
+	__le32 command;
+#define SDM_OP_GEN_COMP_PARAM_MASK  0xFFFF      /* completion parameters 0-15 */
+#define SDM_OP_GEN_COMP_PARAM_SHIFT 0
+#define SDM_OP_GEN_COMP_TYPE_MASK   0xF         /* completion type 16-19 */
+#define SDM_OP_GEN_COMP_TYPE_SHIFT  16
+#define SDM_OP_GEN_RESERVED_MASK    0xFFF       /* reserved 20-31 */
+#define SDM_OP_GEN_RESERVED_SHIFT   20
 };
 
 /*********************************** Init ************************************/
@@ -1274,13 +1210,6 @@ enum chip_ids {
 	MAX_CHIP_IDS
 };
 
-enum idle_chk_severity_types {
-	IDLE_CHK_SEVERITY_ERROR /* idle check failure should cause an error */,
-	IDLE_CHK_SEVERITY_ERROR_NO_TRAFFIC,
-	IDLE_CHK_SEVERITY_WARNING,
-	MAX_IDLE_CHK_SEVERITY_TYPES
-};
-
 struct init_array_raw_hdr {
 	__le32 data;
 #define INIT_ARRAY_RAW_HDR_TYPE_MASK    0xF
@@ -1340,14 +1269,6 @@ struct init_callback_op {
 	__le16	block_id /* Blocks ID */;
 };
 
-/* init comparison types */
-enum init_comparison_types {
-	INIT_COMPARISON_EQ /* init value is included in the init command */,
-	INIT_COMPARISON_OR /* init value is all zeros */,
-	INIT_COMPARISON_AND /* init value is an array of values */,
-	MAX_INIT_COMPARISON_TYPES
-};
-
 /* init operation: delay */
 struct init_delay_op {
 	__le32	op_data;
@@ -1444,12 +1365,10 @@ struct init_read_op {
 	__le32 op_data;
 #define INIT_READ_OP_OP_MASK         0xF
 #define INIT_READ_OP_OP_SHIFT        0
-#define INIT_READ_OP_POLL_COMP_MASK  0x7
-#define INIT_READ_OP_POLL_COMP_SHIFT 4
+#define INIT_READ_OP_POLL_TYPE_MASK  0xF
+#define INIT_READ_OP_POLL_TYPE_SHIFT 4
 #define INIT_READ_OP_RESERVED_MASK   0x1
-#define INIT_READ_OP_RESERVED_SHIFT  7
-#define INIT_READ_OP_POLL_MASK       0x1
-#define INIT_READ_OP_POLL_SHIFT      8
+#define INIT_READ_OP_RESERVED_SHIFT  8
 #define INIT_READ_OP_ADDRESS_MASK    0x7FFFFF
 #define INIT_READ_OP_ADDRESS_SHIFT   9
 	__le32 expected_val;
@@ -1477,6 +1396,14 @@ enum init_op_types {
 	MAX_INIT_OP_TYPES
 };
 
+enum init_poll_types {
+	INIT_POLL_NONE /* No polling */,
+	INIT_POLL_EQ /* init value is included in the init command */,
+	INIT_POLL_OR /* init value is all zeros */,
+	INIT_POLL_AND /* init value is an array of values */,
+	MAX_INIT_POLL_TYPES
+};
+
 /* init source types */
 enum init_source_types {
 	INIT_SRC_INLINE /* init value is included in the init command */,
@@ -1677,175 +1604,213 @@ bool qed_send_qm_stop_cmd(struct qed_hwfn	*p_hwfn,
 			  u16			num_pqs);
 
 /* Ystorm flow control mode. Use enum fw_flow_ctrl_mode */
-#define YSTORM_FLOW_CONTROL_MODE_OFFSET			(IRO[0].base)
-#define YSTORM_FLOW_CONTROL_MODE_SIZE			(IRO[0].size)
+#define YSTORM_FLOW_CONTROL_MODE_OFFSET  (IRO[0].base)
+#define YSTORM_FLOW_CONTROL_MODE_SIZE    (IRO[0].size)
 /* Tstorm port statistics */
-#define TSTORM_PORT_STAT_OFFSET(port_id)		(IRO[1].base + \
-							 ((port_id) * \
-							  IRO[1].m1))
-#define TSTORM_PORT_STAT_SIZE				(IRO[1].size)
+#define TSTORM_PORT_STAT_OFFSET(port_id) (IRO[1].base + ((port_id) * IRO[1].m1))
+#define TSTORM_PORT_STAT_SIZE            (IRO[1].size)
+/* Tstorm ll2 port statistics */
+#define TSTORM_LL2_PORT_STAT_OFFSET(port_id) \
+				(IRO[2].base + ((port_id) * IRO[2].m1))
+#define TSTORM_LL2_PORT_STAT_SIZE            (IRO[2].size)
 /* Ustorm VF-PF Channel ready flag */
-#define USTORM_VF_PF_CHANNEL_READY_OFFSET(vf_id)	(IRO[2].base +	\
-							 ((vf_id) *	\
-							  IRO[2].m1))
-#define USTORM_VF_PF_CHANNEL_READY_SIZE			(IRO[2].size)
+#define USTORM_VF_PF_CHANNEL_READY_OFFSET(vf_id) \
+				(IRO[3].base +	((vf_id) * IRO[3].m1))
+#define USTORM_VF_PF_CHANNEL_READY_SIZE          (IRO[3].size)
 /* Ustorm Final flr cleanup ack */
-#define USTORM_FLR_FINAL_ACK_OFFSET			(IRO[3].base)
-#define USTORM_FLR_FINAL_ACK_SIZE			(IRO[3].size)
+#define USTORM_FLR_FINAL_ACK_OFFSET(pf_id) (IRO[4].base + ((pf_id) * IRO[4].m1))
+#define USTORM_FLR_FINAL_ACK_SIZE          (IRO[4].size)
 /* Ustorm Event ring consumer */
-#define USTORM_EQE_CONS_OFFSET(pf_id)			(IRO[4].base +	\
-							 ((pf_id) *	\
-							  IRO[4].m1))
-#define USTORM_EQE_CONS_SIZE				(IRO[4].size)
-/* Ustorm Completion ring consumer */
-#define USTORM_CQ_CONS_OFFSET(global_queue_id)		(IRO[5].base +	\
-							 ((global_queue_id) * \
-							  IRO[5].m1))
-#define USTORM_CQ_CONS_SIZE				(IRO[5].size)
+#define USTORM_EQE_CONS_OFFSET(pf_id)    (IRO[5].base +	((pf_id) * IRO[5].m1))
+#define USTORM_EQE_CONS_SIZE             (IRO[5].size)
+/* Ustorm Common Queue ring consumer */
+#define USTORM_COMMON_QUEUE_CONS_OFFSET(global_queue_id) \
+			(IRO[6].base + ((global_queue_id) * IRO[6].m1))
+#define USTORM_COMMON_QUEUE_CONS_SIZE    (IRO[6].size)
 /* Xstorm Integration Test Data */
-#define XSTORM_INTEG_TEST_DATA_OFFSET			(IRO[6].base)
-#define XSTORM_INTEG_TEST_DATA_SIZE			(IRO[6].size)
+#define XSTORM_INTEG_TEST_DATA_OFFSET    (IRO[7].base)
+#define XSTORM_INTEG_TEST_DATA_SIZE      (IRO[7].size)
 /* Ystorm Integration Test Data */
-#define YSTORM_INTEG_TEST_DATA_OFFSET			(IRO[7].base)
-#define YSTORM_INTEG_TEST_DATA_SIZE			(IRO[7].size)
+#define YSTORM_INTEG_TEST_DATA_OFFSET    (IRO[8].base)
+#define YSTORM_INTEG_TEST_DATA_SIZE      (IRO[8].size)
 /* Pstorm Integration Test Data */
-#define PSTORM_INTEG_TEST_DATA_OFFSET			(IRO[8].base)
-#define PSTORM_INTEG_TEST_DATA_SIZE			(IRO[8].size)
+#define PSTORM_INTEG_TEST_DATA_OFFSET    (IRO[9].base)
+#define PSTORM_INTEG_TEST_DATA_SIZE      (IRO[9].size)
 /* Tstorm Integration Test Data */
-#define TSTORM_INTEG_TEST_DATA_OFFSET			(IRO[9].base)
-#define TSTORM_INTEG_TEST_DATA_SIZE			(IRO[9].size)
+#define TSTORM_INTEG_TEST_DATA_OFFSET    (IRO[10].base)
+#define TSTORM_INTEG_TEST_DATA_SIZE      (IRO[10].size)
 /* Mstorm Integration Test Data */
-#define MSTORM_INTEG_TEST_DATA_OFFSET			(IRO[10].base)
-#define MSTORM_INTEG_TEST_DATA_SIZE			(IRO[10].size)
+#define MSTORM_INTEG_TEST_DATA_OFFSET    (IRO[11].base)
+#define MSTORM_INTEG_TEST_DATA_SIZE      (IRO[11].size)
 /* Ustorm Integration Test Data */
-#define USTORM_INTEG_TEST_DATA_OFFSET			(IRO[11].base)
-#define USTORM_INTEG_TEST_DATA_SIZE			(IRO[11].size)
+#define USTORM_INTEG_TEST_DATA_OFFSET    (IRO[12].base)
+#define USTORM_INTEG_TEST_DATA_SIZE      (IRO[12].size)
 /* Tstorm producers */
-#define TSTORM_LL2_RX_PRODS_OFFSET(core_rx_queue_id)	(IRO[12].base +	\
-							 ((core_rx_queue_id) * \
-							  IRO[12].m1))
-#define TSTORM_LL2_RX_PRODS_SIZE			(IRO[12].size)
-/* Tstorm LiteL2 queue statistics */
-#define CORE_LL2_TSTORM_PER_QUEUE_STAT_OFFSET(core_rx_q_id) (IRO[13].base + \
-							     ((core_rx_q_id) * \
-							      IRO[13].m1))
-#define CORE_LL2_TSTORM_PER_QUEUE_STAT_SIZE		(IRO[13].size)
+#define TSTORM_LL2_RX_PRODS_OFFSET(core_rx_queue_id) \
+			(IRO[13].base + ((core_rx_queue_id) * IRO[13].m1))
+#define TSTORM_LL2_RX_PRODS_SIZE         (IRO[13].size)
+/* Tstorm LightL2 queue statistics */
+#define CORE_LL2_TSTORM_PER_QUEUE_STAT_OFFSET(core_rx_queue_id) \
+			(IRO[14].base + ((core_rx_queue_id) * IRO[14].m1))
+#define CORE_LL2_TSTORM_PER_QUEUE_STAT_SIZE    (IRO[14].size)
 /* Ustorm LiteL2 queue statistics */
-#define CORE_LL2_USTORM_PER_QUEUE_STAT_OFFSET(core_rx_q_id) (IRO[14].base + \
-							     ((core_rx_q_id) * \
-							      IRO[14].m1))
-#define CORE_LL2_USTORM_PER_QUEUE_STAT_SIZE		(IRO[14].size)
+#define CORE_LL2_USTORM_PER_QUEUE_STAT_OFFSET(core_rx_queue_id) \
+			(IRO[15].base +	((core_rx_queue_id) * IRO[15].m1))
+#define CORE_LL2_USTORM_PER_QUEUE_STAT_SIZE    (IRO[15].size)
 /* Pstorm LiteL2 queue statistics */
-#define CORE_LL2_PSTORM_PER_QUEUE_STAT_OFFSET(core_txst_id) (IRO[15].base + \
-							     ((core_txst_id) * \
-							      IRO[15].m1))
-#define CORE_LL2_PSTORM_PER_QUEUE_STAT_SIZE		(IRO[15].size)
+#define CORE_LL2_PSTORM_PER_QUEUE_STAT_OFFSET(core_tx_stats_id) \
+			(IRO[16].base +	((core_tx_stats_id) * IRO[16].m1))
+#define CORE_LL2_PSTORM_PER_QUEUE_STAT_SIZE    (IRO[16].size)
 /* Mstorm queue statistics */
-#define MSTORM_QUEUE_STAT_OFFSET(stat_counter_id) (IRO[16].base + \
-						   ((stat_counter_id) *	\
-						    IRO[16].m1))
-#define MSTORM_QUEUE_STAT_SIZE				(IRO[16].size)
+#define MSTORM_QUEUE_STAT_OFFSET(stat_counter_id) \
+			(IRO[17].base + ((stat_counter_id) * IRO[17].m1))
+#define MSTORM_QUEUE_STAT_SIZE                 (IRO[17].size)
 /* Mstorm producers */
-#define MSTORM_PRODS_OFFSET(queue_id)			(IRO[17].base +	\
-							 ((queue_id) *	\
-							  IRO[17].m1))
-#define MSTORM_PRODS_SIZE				(IRO[17].size)
+#define MSTORM_PRODS_OFFSET(queue_id) (IRO[18].base + ((queue_id) * IRO[18].m1))
+#define MSTORM_PRODS_SIZE             (IRO[18].size)
 /* TPA agregation timeout in us resolution (on ASIC) */
-#define MSTORM_TPA_TIMEOUT_US_OFFSET			(IRO[18].base)
-#define MSTORM_TPA_TIMEOUT_US_SIZE			(IRO[18].size)
+#define MSTORM_TPA_TIMEOUT_US_OFFSET  (IRO[19].base)
+#define MSTORM_TPA_TIMEOUT_US_SIZE    (IRO[19].size)
 /* Ustorm queue statistics */
-#define USTORM_QUEUE_STAT_OFFSET(stat_counter_id)	(IRO[19].base +	\
-							((stat_counter_id) * \
-							 IRO[19].m1))
-#define USTORM_QUEUE_STAT_SIZE				(IRO[19].size)
+#define USTORM_QUEUE_STAT_OFFSET(stat_counter_id) \
+			(IRO[20].base + ((stat_counter_id) * IRO[20].m1))
+#define USTORM_QUEUE_STAT_SIZE        (IRO[20].size)
 /* Ustorm queue zone */
-#define USTORM_ETH_QUEUE_ZONE_OFFSET(queue_id)		(IRO[20].base +	\
-							 ((queue_id) *	\
-							  IRO[20].m1))
-#define USTORM_ETH_QUEUE_ZONE_SIZE			(IRO[20].size)
+#define USTORM_ETH_QUEUE_ZONE_OFFSET(queue_id) \
+			(IRO[21].base +	((queue_id) * IRO[21].m1))
+#define USTORM_ETH_QUEUE_ZONE_SIZE    (IRO[21].size)
 /* Pstorm queue statistics */
-#define PSTORM_QUEUE_STAT_OFFSET(stat_counter_id)	(IRO[21].base +	\
-							 ((stat_counter_id) * \
-							  IRO[21].m1))
-#define PSTORM_QUEUE_STAT_SIZE				(IRO[21].size)
+#define PSTORM_QUEUE_STAT_OFFSET(stat_counter_id) \
+		(IRO[22].base + ((stat_counter_id) * IRO[22].m1))
+#define PSTORM_QUEUE_STAT_SIZE        (IRO[22].size)
 /* Tstorm last parser message */
-#define TSTORM_ETH_PRS_INPUT_OFFSET(pf_id)		(IRO[22].base +	\
-							 ((pf_id) *	\
-							  IRO[22].m1))
-#define TSTORM_ETH_PRS_INPUT_SIZE			(IRO[22].size)
+#define TSTORM_ETH_PRS_INPUT_OFFSET  (IRO[23].base)
+#define TSTORM_ETH_PRS_INPUT_SIZE    (IRO[23].size)
+/* Tstorm Eth limit Rx rate */
+#define ETH_RX_RATE_LIMIT_OFFSET(pf_id) (IRO[24].base +	((pf_id) * IRO[24].m1))
+#define ETH_RX_RATE_LIMIT_SIZE       (IRO[24].size)
 /* Ystorm queue zone */
-#define YSTORM_ETH_QUEUE_ZONE_OFFSET(queue_id)		(IRO[23].base +	\
-							 ((queue_id) *	\
-							  IRO[23].m1))
-#define YSTORM_ETH_QUEUE_ZONE_SIZE			(IRO[23].size)
+#define YSTORM_ETH_QUEUE_ZONE_OFFSET(queue_id) \
+			(IRO[25].base +	((queue_id) * IRO[25].m1))
+#define YSTORM_ETH_QUEUE_ZONE_SIZE   (IRO[25].size)
 /* Ystorm cqe producer */
-#define YSTORM_TOE_CQ_PROD_OFFSET(rss_id)		(IRO[24].base +	\
-							 ((rss_id) *	\
-							  IRO[24].m1))
-#define YSTORM_TOE_CQ_PROD_SIZE				(IRO[24].size)
+#define YSTORM_TOE_CQ_PROD_OFFSET(rss_id) \
+			(IRO[26].base + ((rss_id) * IRO[26].m1))
+#define YSTORM_TOE_CQ_PROD_SIZE      (IRO[26].size)
 /* Ustorm cqe producer */
-#define USTORM_TOE_CQ_PROD_OFFSET(rss_id)		(IRO[25].base +	\
-							 ((rss_id) *	\
-							  IRO[25].m1))
-#define USTORM_TOE_CQ_PROD_SIZE				(IRO[25].size)
+#define USTORM_TOE_CQ_PROD_OFFSET(rss_id) \
+			(IRO[27].base + ((rss_id) * IRO[27].m1))
+#define USTORM_TOE_CQ_PROD_SIZE      (IRO[27].size)
 /* Ustorm grq producer */
-#define USTORM_TOE_GRQ_PROD_OFFSET(pf_id)		(IRO[26].base +	\
-							 ((pf_id) *	\
-							  IRO[26].m1))
-#define USTORM_TOE_GRQ_PROD_SIZE			(IRO[26].size)
+#define USTORM_TOE_GRQ_PROD_OFFSET(pf_id) \
+			(IRO[28].base + ((pf_id) * IRO[28].m1))
+#define USTORM_TOE_GRQ_PROD_SIZE     (IRO[28].size)
 /* Tstorm cmdq-cons of given command queue-id */
-#define TSTORM_SCSI_CMDQ_CONS_OFFSET(cmdq_queue_id)	(IRO[27].base +	\
-							 ((cmdq_queue_id) * \
-							  IRO[27].m1))
-#define TSTORM_SCSI_CMDQ_CONS_SIZE			(IRO[27].size)
+#define TSTORM_SCSI_CMDQ_CONS_OFFSET(cmdq_queue_id) \
+			(IRO[29].base + ((cmdq_queue_id) * IRO[29].m1))
+#define TSTORM_SCSI_CMDQ_CONS_SIZE   (IRO[29].size)
 /* Mstorm rq-cons of given queue-id */
-#define MSTORM_SCSI_RQ_CONS_OFFSET(rq_queue_id)		(IRO[28].base +	\
-							 ((rq_queue_id) * \
-							  IRO[28].m1))
-#define MSTORM_SCSI_RQ_CONS_SIZE			(IRO[28].size)
+#define MSTORM_SCSI_RQ_CONS_OFFSET(rq_queue_id) \
+		(IRO[30].base + ((rq_queue_id) * IRO[30].m1))
+#define MSTORM_SCSI_RQ_CONS_SIZE     (IRO[30].size)
+/* Mstorm bdq-external-producer of given BDQ function ID, BDqueue-id */
+#define MSTORM_SCSI_BDQ_EXT_PROD_OFFSET(func_id, bdq_id) \
+	(IRO[31].base + ((func_id) * IRO[31].m1) + ((bdq_id) * IRO[31].m2))
+#define MSTORM_SCSI_BDQ_EXT_PROD_SIZE (IRO[31].size)
+/* Tstorm (reflects M-Storm) bdq-external-producer of given fn ID, BDqueue-id */
+#define TSTORM_SCSI_BDQ_EXT_PROD_OFFSET(func_id, bdq_id) \
+	(IRO[32].base + ((func_id) * IRO[32].m1) + ((bdq_id) * IRO[32].m2))
+#define TSTORM_SCSI_BDQ_EXT_PROD_SIZE (IRO[32].size)
+/* Tstorm iSCSI RX stats */
+#define TSTORM_ISCSI_RX_STATS_OFFSET(pf_id) \
+				(IRO[33].base + ((pf_id) * IRO[33].m1))
+#define TSTORM_ISCSI_RX_STATS_SIZE    (IRO[33].size)
+/* Mstorm iSCSI RX stats */
+#define MSTORM_ISCSI_RX_STATS_OFFSET(pf_id) \
+				(IRO[34].base + ((pf_id) * IRO[34].m1))
+#define MSTORM_ISCSI_RX_STATS_SIZE    (IRO[34].size)
+/* Ustorm iSCSI RX stats */
+#define USTORM_ISCSI_RX_STATS_OFFSET(pf_id) \
+				(IRO[35].base +	((pf_id) * IRO[35].m1))
+#define USTORM_ISCSI_RX_STATS_SIZE    (IRO[35].size)
+/* Xstorm iSCSI TX stats */
+#define XSTORM_ISCSI_TX_STATS_OFFSET(pf_id) \
+				(IRO[36].base +	((pf_id) * IRO[36].m1))
+#define XSTORM_ISCSI_TX_STATS_SIZE    (IRO[36].size)
+/* Ystorm iSCSI TX stats */
+#define YSTORM_ISCSI_TX_STATS_OFFSET(pf_id) \
+				(IRO[37].base +	((pf_id) * IRO[37].m1))
+#define YSTORM_ISCSI_TX_STATS_SIZE    (IRO[37].size)
+/* Pstorm iSCSI TX stats */
+#define PSTORM_ISCSI_TX_STATS_OFFSET(pf_id) \
+				(IRO[38].base +	((pf_id) * IRO[38].m1))
+#define PSTORM_ISCSI_TX_STATS_SIZE    (IRO[38].size)
+/* Tstorm FCoE RX stats */
+#define TSTORM_FCOE_RX_STATS_OFFSET(pf_id) \
+				(IRO[39].base +	((pf_id) * IRO[39].m1))
+#define TSTORM_FCOE_RX_STATS_SIZE      (IRO[39].size)
+/* Mstorm FCoE RX stats */
+#define MSTORM_FCOE_RX_STATS_OFFSET(pf_id) \
+				(IRO[40].base +	((pf_id) * IRO[40].m1))
+#define MSTORM_FCOE_RX_STATS_SIZE      (IRO[40].size)
+/* Pstorm FCoE TX stats */
+#define PSTORM_FCOE_TX_STATS_OFFSET(pf_id) \
+				(IRO[41].base +	((pf_id) * IRO[41].m1))
+#define PSTORM_FCOE_TX_STATS_SIZE      (IRO[41].size)
 /* Pstorm RoCE statistics */
-#define PSTORM_ROCE_STAT_OFFSET(stat_counter_id)	(IRO[29].base +	\
-							 ((stat_counter_id) * \
-							  IRO[29].m1))
-#define PSTORM_ROCE_STAT_SIZE				(IRO[29].size)
+#define PSTORM_ROCE_STAT_OFFSET(stat_counter_id) \
+			(IRO[42].base + ((stat_counter_id) * IRO[42].m1))
+#define PSTORM_ROCE_STAT_SIZE          (IRO[42].size)
 /* Tstorm RoCE statistics */
-#define TSTORM_ROCE_STAT_OFFSET(stat_counter_id)	(IRO[30].base +	\
-							 ((stat_counter_id) * \
-							  IRO[30].m1))
-#define TSTORM_ROCE_STAT_SIZE				(IRO[30].size)
-
-static const struct iro iro_arr[31] = {
-	{ 0x10,	  0x0,	 0x0,	0x0,   0x8     },
-	{ 0x4448, 0x60,	 0x0,	0x0,   0x60    },
-	{ 0x498,  0x8,	 0x0,	0x0,   0x4     },
-	{ 0x494,  0x0,	 0x0,	0x0,   0x4     },
-	{ 0x10,	  0x8,	 0x0,	0x0,   0x2     },
-	{ 0x90,	  0x8,	 0x0,	0x0,   0x2     },
-	{ 0x4540, 0x0,	 0x0,	0x0,   0xf8    },
-	{ 0x39e0, 0x0,	 0x0,	0x0,   0xf8    },
-	{ 0x2598, 0x0,	 0x0,	0x0,   0xf8    },
-	{ 0x4350, 0x0,	 0x0,	0x0,   0xf8    },
-	{ 0x52d0, 0x0,	 0x0,	0x0,   0xf8    },
-	{ 0x7a48, 0x0,	 0x0,	0x0,   0xf8    },
-	{ 0x100,  0x8,	 0x0,	0x0,   0x8     },
-	{ 0x5808, 0x10,	 0x0,	0x0,   0x10    },
-	{ 0xb100, 0x30,	 0x0,	0x0,   0x30    },
-	{ 0x95c0, 0x30,	 0x0,	0x0,   0x30    },
-	{ 0x54f8, 0x40,	 0x0,	0x0,   0x40    },
-	{ 0x200,  0x10,	 0x0,	0x0,   0x8     },
-	{ 0x9e70, 0x0,	 0x0,	0x0,   0x4     },
-	{ 0x7ca0, 0x40,	 0x0,	0x0,   0x30    },
-	{ 0xd00,  0x8,	 0x0,	0x0,   0x8     },
-	{ 0x2790, 0x80,	 0x0,	0x0,   0x38    },
-	{ 0xa520, 0xf0,	 0x0,	0x0,   0xf0    },
-	{ 0x80,	  0x8,	 0x0,	0x0,   0x8     },
-	{ 0xac0,  0x8,	 0x0,	0x0,   0x8     },
-	{ 0x2580, 0x8,	 0x0,	0x0,   0x8     },
-	{ 0x2500, 0x8,	 0x0,	0x0,   0x8     },
-	{ 0x440,  0x8,	 0x0,	0x0,   0x2     },
-	{ 0x1800, 0x8,	 0x0,	0x0,   0x2     },
-	{ 0x27c8, 0x80,	 0x0,	0x0,   0x10    },
-	{ 0x4710, 0x10,	 0x0,	0x0,   0x10    },
+#define TSTORM_ROCE_STAT_OFFSET(stat_counter_id) \
+			(IRO[43].base + ((stat_counter_id) * IRO[43].m1))
+#define TSTORM_ROCE_STAT_SIZE          (IRO[43].size)
+
+static const struct iro iro_arr[44] = {
+	{ 0x10,	   0x0,	   0x0,	   0x0,	   0x8	    },
+	{ 0x47c8,  0x60,   0x0,	   0x0,	   0x60	    },
+	{ 0x5e30,  0x20,   0x0,	   0x0,	   0x20	    },
+	{ 0x510,   0x8,	   0x0,	   0x0,	   0x4	    },
+	{ 0x490,   0x8,	   0x0,	   0x0,	   0x4	    },
+	{ 0x10,	   0x8,	   0x0,	   0x0,	   0x2	    },
+	{ 0x90,	   0x8,	   0x0,	   0x0,	   0x2	    },
+	{ 0x4940,  0x0,	   0x0,	   0x0,	   0x78	    },
+	{ 0x3de0,  0x0,	   0x0,	   0x0,	   0x78	    },
+	{ 0x2998,  0x0,	   0x0,	   0x0,	   0x78	    },
+	{ 0x4750,  0x0,	   0x0,	   0x0,	   0x78	    },
+	{ 0x56d0,  0x0,	   0x0,	   0x0,	   0x78	    },
+	{ 0x7e50,  0x0,	   0x0,	   0x0,	   0x78	    },
+	{ 0x100,   0x8,	   0x0,	   0x0,	   0x8	    },
+	{ 0x5c10,  0x10,   0x0,	   0x0,	   0x10	    },
+	{ 0xb508,  0x30,   0x0,	   0x0,	   0x30	    },
+	{ 0x95c0,  0x30,   0x0,	   0x0,	   0x30	    },
+	{ 0x58a0,  0x40,   0x0,	   0x0,	   0x40	    },
+	{ 0x200,   0x10,   0x0,	   0x0,	   0x8	    },
+	{ 0xa230,  0x0,	   0x0,	   0x0,	   0x4	    },
+	{ 0x8058,  0x40,   0x0,	   0x0,	   0x30	    },
+	{ 0xd00,   0x8,	   0x0,	   0x0,	   0x8	    },
+	{ 0x2b30,  0x80,   0x0,	   0x0,	   0x38	    },
+	{ 0xa808,  0x0,	   0x0,	   0x0,	   0xf0	    },
+	{ 0xa8f8,  0x8,	   0x0,	   0x0,	   0x8	    },
+	{ 0x80,	   0x8,	   0x0,	   0x0,	   0x8	    },
+	{ 0xac0,   0x8,	   0x0,	   0x0,	   0x8	    },
+	{ 0x2580,  0x8,	   0x0,	   0x0,	   0x8	    },
+	{ 0x2500,  0x8,	   0x0,	   0x0,	   0x8	    },
+	{ 0x440,   0x8,	   0x0,	   0x0,	   0x2	    },
+	{ 0x1800,  0x8,	   0x0,	   0x0,	   0x2	    },
+	{ 0x1a00,  0x10,   0x8,	   0x0,	   0x2	    },
+	{ 0x640,   0x10,   0x8,	   0x0,	   0x2	    },
+	{ 0xd9b8,  0x38,   0x0,	   0x0,	   0x24	    },
+	{ 0x11048, 0x10,   0x0,	   0x0,	   0x8	    },
+	{ 0x11678, 0x38,   0x0,	   0x0,	   0x18	    },
+	{ 0xaec0,  0x30,   0x0,	   0x0,	   0x10	    },
+	{ 0x8700,  0x28,   0x0,	   0x0,	   0x18	    },
+	{ 0xec00,  0x10,   0x0,	   0x0,	   0x10	    },
+	{ 0xde38,  0x40,   0x0,	   0x0,	   0x30	    },
+	{ 0x121a8, 0x38,   0x0,	   0x0,	   0x8	    },
+	{ 0xf068,  0x20,   0x0,	   0x0,	   0x20	    },
+	{ 0x2b68,  0x80,   0x0,	   0x0,	   0x10	    },
+	{ 0x4ab8,  0x10,   0x0,	   0x0,	   0x10	    },
 };
 
 /* Runtime array offsets */
@@ -1866,426 +1831,427 @@ static const struct iro iro_arr[31] = {
 #define DORQ_REG_VF_MAX_ICID_6_RT_OFFSET                                14
 #define DORQ_REG_VF_MAX_ICID_7_RT_OFFSET                                15
 #define DORQ_REG_PF_WAKE_ALL_RT_OFFSET                                  16
-#define IGU_REG_PF_CONFIGURATION_RT_OFFSET                              17
-#define IGU_REG_VF_CONFIGURATION_RT_OFFSET                              18
-#define IGU_REG_ATTN_MSG_ADDR_L_RT_OFFSET                               19
-#define IGU_REG_ATTN_MSG_ADDR_H_RT_OFFSET                               20
-#define IGU_REG_LEADING_EDGE_LATCH_RT_OFFSET                            21
-#define IGU_REG_TRAILING_EDGE_LATCH_RT_OFFSET                           22
-#define CAU_REG_CQE_AGG_UNIT_SIZE_RT_OFFSET                             23
-#define CAU_REG_SB_VAR_MEMORY_RT_OFFSET                                 760
+#define DORQ_REG_TAG1_ETHERTYPE_RT_OFFSET                               17
+#define IGU_REG_PF_CONFIGURATION_RT_OFFSET                              18
+#define IGU_REG_VF_CONFIGURATION_RT_OFFSET                              19
+#define IGU_REG_ATTN_MSG_ADDR_L_RT_OFFSET                               20
+#define IGU_REG_ATTN_MSG_ADDR_H_RT_OFFSET                               21
+#define IGU_REG_LEADING_EDGE_LATCH_RT_OFFSET                            22
+#define IGU_REG_TRAILING_EDGE_LATCH_RT_OFFSET                           23
+#define CAU_REG_CQE_AGG_UNIT_SIZE_RT_OFFSET                             24
+#define CAU_REG_SB_VAR_MEMORY_RT_OFFSET                                 761
 #define CAU_REG_SB_VAR_MEMORY_RT_SIZE                                   736
-#define CAU_REG_SB_VAR_MEMORY_RT_OFFSET                                 760
+#define CAU_REG_SB_VAR_MEMORY_RT_OFFSET                                 761
 #define CAU_REG_SB_VAR_MEMORY_RT_SIZE                                   736
-#define CAU_REG_SB_ADDR_MEMORY_RT_OFFSET                                1496
+#define CAU_REG_SB_ADDR_MEMORY_RT_OFFSET                                1497
 #define CAU_REG_SB_ADDR_MEMORY_RT_SIZE                                  736
-#define CAU_REG_PI_MEMORY_RT_OFFSET                                     2232
+#define CAU_REG_PI_MEMORY_RT_OFFSET                                     2233
 #define CAU_REG_PI_MEMORY_RT_SIZE                                       4416
-#define PRS_REG_SEARCH_RESP_INITIATOR_TYPE_RT_OFFSET                    6648
-#define PRS_REG_TASK_ID_MAX_INITIATOR_PF_RT_OFFSET                      6649
-#define PRS_REG_TASK_ID_MAX_INITIATOR_VF_RT_OFFSET                      6650
-#define PRS_REG_TASK_ID_MAX_TARGET_PF_RT_OFFSET                         6651
-#define PRS_REG_TASK_ID_MAX_TARGET_VF_RT_OFFSET                         6652
-#define PRS_REG_SEARCH_TCP_RT_OFFSET                                    6653
-#define PRS_REG_SEARCH_FCOE_RT_OFFSET                                   6654
-#define PRS_REG_SEARCH_ROCE_RT_OFFSET                                   6655
-#define PRS_REG_ROCE_DEST_QP_MAX_VF_RT_OFFSET                           6656
-#define PRS_REG_ROCE_DEST_QP_MAX_PF_RT_OFFSET                           6657
-#define PRS_REG_SEARCH_OPENFLOW_RT_OFFSET                               6658
-#define PRS_REG_SEARCH_NON_IP_AS_OPENFLOW_RT_OFFSET                     6659
-#define PRS_REG_OPENFLOW_SUPPORT_ONLY_KNOWN_OVER_IP_RT_OFFSET           6660
-#define PRS_REG_OPENFLOW_SEARCH_KEY_MASK_RT_OFFSET                      6661
-#define PRS_REG_LIGHT_L2_ETHERTYPE_EN_RT_OFFSET                         6662
-#define SRC_REG_FIRSTFREE_RT_OFFSET                                     6663
+#define PRS_REG_SEARCH_RESP_INITIATOR_TYPE_RT_OFFSET                    6649
+#define PRS_REG_TASK_ID_MAX_INITIATOR_PF_RT_OFFSET                      6650
+#define PRS_REG_TASK_ID_MAX_INITIATOR_VF_RT_OFFSET                      6651
+#define PRS_REG_TASK_ID_MAX_TARGET_PF_RT_OFFSET                         6652
+#define PRS_REG_TASK_ID_MAX_TARGET_VF_RT_OFFSET                         6653
+#define PRS_REG_SEARCH_TCP_RT_OFFSET                                    6654
+#define PRS_REG_SEARCH_FCOE_RT_OFFSET                                   6655
+#define PRS_REG_SEARCH_ROCE_RT_OFFSET                                   6656
+#define PRS_REG_ROCE_DEST_QP_MAX_VF_RT_OFFSET                           6657
+#define PRS_REG_ROCE_DEST_QP_MAX_PF_RT_OFFSET                           6658
+#define PRS_REG_SEARCH_OPENFLOW_RT_OFFSET                               6659
+#define PRS_REG_SEARCH_NON_IP_AS_OPENFLOW_RT_OFFSET                     6660
+#define PRS_REG_OPENFLOW_SUPPORT_ONLY_KNOWN_OVER_IP_RT_OFFSET           6661
+#define PRS_REG_OPENFLOW_SEARCH_KEY_MASK_RT_OFFSET                      6662
+#define PRS_REG_TAG_ETHERTYPE_0_RT_OFFSET                               6663
+#define PRS_REG_LIGHT_L2_ETHERTYPE_EN_RT_OFFSET                         6664
+#define SRC_REG_FIRSTFREE_RT_OFFSET                                     6665
 #define SRC_REG_FIRSTFREE_RT_SIZE                                       2
-#define SRC_REG_LASTFREE_RT_OFFSET                                      6665
+#define SRC_REG_LASTFREE_RT_OFFSET                                      6667
 #define SRC_REG_LASTFREE_RT_SIZE                                        2
-#define SRC_REG_COUNTFREE_RT_OFFSET                                     6667
-#define SRC_REG_NUMBER_HASH_BITS_RT_OFFSET                              6668
-#define PSWRQ2_REG_CDUT_P_SIZE_RT_OFFSET                                6669
-#define PSWRQ2_REG_CDUC_P_SIZE_RT_OFFSET                                6670
-#define PSWRQ2_REG_TM_P_SIZE_RT_OFFSET                                  6671
-#define PSWRQ2_REG_QM_P_SIZE_RT_OFFSET                                  6672
-#define PSWRQ2_REG_SRC_P_SIZE_RT_OFFSET                                 6673
-#define PSWRQ2_REG_TM_FIRST_ILT_RT_OFFSET                               6674
-#define PSWRQ2_REG_TM_LAST_ILT_RT_OFFSET                                6675
-#define PSWRQ2_REG_QM_FIRST_ILT_RT_OFFSET                               6676
-#define PSWRQ2_REG_QM_LAST_ILT_RT_OFFSET                                6677
-#define PSWRQ2_REG_SRC_FIRST_ILT_RT_OFFSET                              6678
-#define PSWRQ2_REG_SRC_LAST_ILT_RT_OFFSET                               6679
-#define PSWRQ2_REG_CDUC_FIRST_ILT_RT_OFFSET                             6680
-#define PSWRQ2_REG_CDUC_LAST_ILT_RT_OFFSET                              6681
-#define PSWRQ2_REG_CDUT_FIRST_ILT_RT_OFFSET                             6682
-#define PSWRQ2_REG_CDUT_LAST_ILT_RT_OFFSET                              6683
-#define PSWRQ2_REG_TSDM_FIRST_ILT_RT_OFFSET                             6684
-#define PSWRQ2_REG_TSDM_LAST_ILT_RT_OFFSET                              6685
-#define PSWRQ2_REG_TM_NUMBER_OF_PF_BLOCKS_RT_OFFSET                     6686
-#define PSWRQ2_REG_CDUT_NUMBER_OF_PF_BLOCKS_RT_OFFSET                   6687
-#define PSWRQ2_REG_CDUC_NUMBER_OF_PF_BLOCKS_RT_OFFSET                   6688
-#define PSWRQ2_REG_TM_VF_BLOCKS_RT_OFFSET                               6689
-#define PSWRQ2_REG_CDUT_VF_BLOCKS_RT_OFFSET                             6690
-#define PSWRQ2_REG_CDUC_VF_BLOCKS_RT_OFFSET                             6691
-#define PSWRQ2_REG_TM_BLOCKS_FACTOR_RT_OFFSET                           6692
-#define PSWRQ2_REG_CDUT_BLOCKS_FACTOR_RT_OFFSET                         6693
-#define PSWRQ2_REG_CDUC_BLOCKS_FACTOR_RT_OFFSET                         6694
-#define PSWRQ2_REG_VF_BASE_RT_OFFSET                                    6695
-#define PSWRQ2_REG_VF_LAST_ILT_RT_OFFSET                                6696
-#define PSWRQ2_REG_WR_MBS0_RT_OFFSET                                    6697
-#define PSWRQ2_REG_RD_MBS0_RT_OFFSET                                    6698
-#define PSWRQ2_REG_DRAM_ALIGN_WR_RT_OFFSET                              6699
-#define PSWRQ2_REG_DRAM_ALIGN_RD_RT_OFFSET                              6700
-#define PSWRQ2_REG_ILT_MEMORY_RT_OFFSET                                 6701
+#define SRC_REG_COUNTFREE_RT_OFFSET                                     6669
+#define SRC_REG_NUMBER_HASH_BITS_RT_OFFSET                              6670
+#define PSWRQ2_REG_CDUT_P_SIZE_RT_OFFSET                                6671
+#define PSWRQ2_REG_CDUC_P_SIZE_RT_OFFSET                                6672
+#define PSWRQ2_REG_TM_P_SIZE_RT_OFFSET                                  6673
+#define PSWRQ2_REG_QM_P_SIZE_RT_OFFSET                                  6674
+#define PSWRQ2_REG_SRC_P_SIZE_RT_OFFSET                                 6675
+#define PSWRQ2_REG_TM_FIRST_ILT_RT_OFFSET                               6676
+#define PSWRQ2_REG_TM_LAST_ILT_RT_OFFSET                                6677
+#define PSWRQ2_REG_QM_FIRST_ILT_RT_OFFSET                               6678
+#define PSWRQ2_REG_QM_LAST_ILT_RT_OFFSET                                6679
+#define PSWRQ2_REG_SRC_FIRST_ILT_RT_OFFSET                              6680
+#define PSWRQ2_REG_SRC_LAST_ILT_RT_OFFSET                               6681
+#define PSWRQ2_REG_CDUC_FIRST_ILT_RT_OFFSET                             6682
+#define PSWRQ2_REG_CDUC_LAST_ILT_RT_OFFSET                              6683
+#define PSWRQ2_REG_CDUT_FIRST_ILT_RT_OFFSET                             6684
+#define PSWRQ2_REG_CDUT_LAST_ILT_RT_OFFSET                              6685
+#define PSWRQ2_REG_TSDM_FIRST_ILT_RT_OFFSET                             6686
+#define PSWRQ2_REG_TSDM_LAST_ILT_RT_OFFSET                              6687
+#define PSWRQ2_REG_TM_NUMBER_OF_PF_BLOCKS_RT_OFFSET                     6688
+#define PSWRQ2_REG_CDUT_NUMBER_OF_PF_BLOCKS_RT_OFFSET                   6689
+#define PSWRQ2_REG_CDUC_NUMBER_OF_PF_BLOCKS_RT_OFFSET                   6690
+#define PSWRQ2_REG_TM_VF_BLOCKS_RT_OFFSET                               6691
+#define PSWRQ2_REG_CDUT_VF_BLOCKS_RT_OFFSET                             6692
+#define PSWRQ2_REG_CDUC_VF_BLOCKS_RT_OFFSET                             6693
+#define PSWRQ2_REG_TM_BLOCKS_FACTOR_RT_OFFSET                           6694
+#define PSWRQ2_REG_CDUT_BLOCKS_FACTOR_RT_OFFSET                         6695
+#define PSWRQ2_REG_CDUC_BLOCKS_FACTOR_RT_OFFSET                         6696
+#define PSWRQ2_REG_VF_BASE_RT_OFFSET                                    6697
+#define PSWRQ2_REG_VF_LAST_ILT_RT_OFFSET                                6698
+#define PSWRQ2_REG_WR_MBS0_RT_OFFSET                                    6699
+#define PSWRQ2_REG_RD_MBS0_RT_OFFSET                                    6700
+#define PSWRQ2_REG_DRAM_ALIGN_WR_RT_OFFSET                              6701
+#define PSWRQ2_REG_DRAM_ALIGN_RD_RT_OFFSET                              6702
+#define PSWRQ2_REG_ILT_MEMORY_RT_OFFSET                                 6703
 #define PSWRQ2_REG_ILT_MEMORY_RT_SIZE                                   22000
-#define PGLUE_REG_B_VF_BASE_RT_OFFSET                                   28701
-#define PGLUE_REG_B_CACHE_LINE_SIZE_RT_OFFSET                           28702
-#define PGLUE_REG_B_PF_BAR0_SIZE_RT_OFFSET                              28703
-#define PGLUE_REG_B_PF_BAR1_SIZE_RT_OFFSET                              28704
-#define PGLUE_REG_B_VF_BAR1_SIZE_RT_OFFSET                              28705
-#define TM_REG_VF_ENABLE_CONN_RT_OFFSET                                 28706
-#define TM_REG_PF_ENABLE_CONN_RT_OFFSET                                 28707
-#define TM_REG_PF_ENABLE_TASK_RT_OFFSET                                 28708
-#define TM_REG_GROUP_SIZE_RESOLUTION_CONN_RT_OFFSET                     28709
-#define TM_REG_GROUP_SIZE_RESOLUTION_TASK_RT_OFFSET                     28710
-#define TM_REG_CONFIG_CONN_MEM_RT_OFFSET                                28711
+#define PGLUE_REG_B_VF_BASE_RT_OFFSET                                   28703
+#define PGLUE_REG_B_CACHE_LINE_SIZE_RT_OFFSET                           28704
+#define PGLUE_REG_B_PF_BAR0_SIZE_RT_OFFSET                              28705
+#define PGLUE_REG_B_PF_BAR1_SIZE_RT_OFFSET                              28706
+#define PGLUE_REG_B_VF_BAR1_SIZE_RT_OFFSET                              28707
+#define TM_REG_VF_ENABLE_CONN_RT_OFFSET                                 28708
+#define TM_REG_PF_ENABLE_CONN_RT_OFFSET                                 28709
+#define TM_REG_PF_ENABLE_TASK_RT_OFFSET                                 28710
+#define TM_REG_GROUP_SIZE_RESOLUTION_CONN_RT_OFFSET                     28711
+#define TM_REG_GROUP_SIZE_RESOLUTION_TASK_RT_OFFSET                     28712
+#define TM_REG_CONFIG_CONN_MEM_RT_OFFSET                                28713
 #define TM_REG_CONFIG_CONN_MEM_RT_SIZE                                  416
-#define TM_REG_CONFIG_TASK_MEM_RT_OFFSET                                29127
+#define TM_REG_CONFIG_TASK_MEM_RT_OFFSET                                29129
 #define TM_REG_CONFIG_TASK_MEM_RT_SIZE                                  512
-#define QM_REG_MAXPQSIZE_0_RT_OFFSET                                    29639
-#define QM_REG_MAXPQSIZE_1_RT_OFFSET                                    29640
-#define QM_REG_MAXPQSIZE_2_RT_OFFSET                                    29641
-#define QM_REG_MAXPQSIZETXSEL_0_RT_OFFSET                               29642
-#define QM_REG_MAXPQSIZETXSEL_1_RT_OFFSET                               29643
-#define QM_REG_MAXPQSIZETXSEL_2_RT_OFFSET                               29644
-#define QM_REG_MAXPQSIZETXSEL_3_RT_OFFSET                               29645
-#define QM_REG_MAXPQSIZETXSEL_4_RT_OFFSET                               29646
-#define QM_REG_MAXPQSIZETXSEL_5_RT_OFFSET                               29647
-#define QM_REG_MAXPQSIZETXSEL_6_RT_OFFSET                               29648
-#define QM_REG_MAXPQSIZETXSEL_7_RT_OFFSET                               29649
-#define QM_REG_MAXPQSIZETXSEL_8_RT_OFFSET                               29650
-#define QM_REG_MAXPQSIZETXSEL_9_RT_OFFSET                               29651
-#define QM_REG_MAXPQSIZETXSEL_10_RT_OFFSET                              29652
-#define QM_REG_MAXPQSIZETXSEL_11_RT_OFFSET                              29653
-#define QM_REG_MAXPQSIZETXSEL_12_RT_OFFSET                              29654
-#define QM_REG_MAXPQSIZETXSEL_13_RT_OFFSET                              29655
-#define QM_REG_MAXPQSIZETXSEL_14_RT_OFFSET                              29656
-#define QM_REG_MAXPQSIZETXSEL_15_RT_OFFSET                              29657
-#define QM_REG_MAXPQSIZETXSEL_16_RT_OFFSET                              29658
-#define QM_REG_MAXPQSIZETXSEL_17_RT_OFFSET                              29659
-#define QM_REG_MAXPQSIZETXSEL_18_RT_OFFSET                              29660
-#define QM_REG_MAXPQSIZETXSEL_19_RT_OFFSET                              29661
-#define QM_REG_MAXPQSIZETXSEL_20_RT_OFFSET                              29662
-#define QM_REG_MAXPQSIZETXSEL_21_RT_OFFSET                              29663
-#define QM_REG_MAXPQSIZETXSEL_22_RT_OFFSET                              29664
-#define QM_REG_MAXPQSIZETXSEL_23_RT_OFFSET                              29665
-#define QM_REG_MAXPQSIZETXSEL_24_RT_OFFSET                              29666
-#define QM_REG_MAXPQSIZETXSEL_25_RT_OFFSET                              29667
-#define QM_REG_MAXPQSIZETXSEL_26_RT_OFFSET                              29668
-#define QM_REG_MAXPQSIZETXSEL_27_RT_OFFSET                              29669
-#define QM_REG_MAXPQSIZETXSEL_28_RT_OFFSET                              29670
-#define QM_REG_MAXPQSIZETXSEL_29_RT_OFFSET                              29671
-#define QM_REG_MAXPQSIZETXSEL_30_RT_OFFSET                              29672
-#define QM_REG_MAXPQSIZETXSEL_31_RT_OFFSET                              29673
-#define QM_REG_MAXPQSIZETXSEL_32_RT_OFFSET                              29674
-#define QM_REG_MAXPQSIZETXSEL_33_RT_OFFSET                              29675
-#define QM_REG_MAXPQSIZETXSEL_34_RT_OFFSET                              29676
-#define QM_REG_MAXPQSIZETXSEL_35_RT_OFFSET                              29677
-#define QM_REG_MAXPQSIZETXSEL_36_RT_OFFSET                              29678
-#define QM_REG_MAXPQSIZETXSEL_37_RT_OFFSET                              29679
-#define QM_REG_MAXPQSIZETXSEL_38_RT_OFFSET                              29680
-#define QM_REG_MAXPQSIZETXSEL_39_RT_OFFSET                              29681
-#define QM_REG_MAXPQSIZETXSEL_40_RT_OFFSET                              29682
-#define QM_REG_MAXPQSIZETXSEL_41_RT_OFFSET                              29683
-#define QM_REG_MAXPQSIZETXSEL_42_RT_OFFSET                              29684
-#define QM_REG_MAXPQSIZETXSEL_43_RT_OFFSET                              29685
-#define QM_REG_MAXPQSIZETXSEL_44_RT_OFFSET                              29686
-#define QM_REG_MAXPQSIZETXSEL_45_RT_OFFSET                              29687
-#define QM_REG_MAXPQSIZETXSEL_46_RT_OFFSET                              29688
-#define QM_REG_MAXPQSIZETXSEL_47_RT_OFFSET                              29689
-#define QM_REG_MAXPQSIZETXSEL_48_RT_OFFSET                              29690
-#define QM_REG_MAXPQSIZETXSEL_49_RT_OFFSET                              29691
-#define QM_REG_MAXPQSIZETXSEL_50_RT_OFFSET                              29692
-#define QM_REG_MAXPQSIZETXSEL_51_RT_OFFSET                              29693
-#define QM_REG_MAXPQSIZETXSEL_52_RT_OFFSET                              29694
-#define QM_REG_MAXPQSIZETXSEL_53_RT_OFFSET                              29695
-#define QM_REG_MAXPQSIZETXSEL_54_RT_OFFSET                              29696
-#define QM_REG_MAXPQSIZETXSEL_55_RT_OFFSET                              29697
-#define QM_REG_MAXPQSIZETXSEL_56_RT_OFFSET                              29698
-#define QM_REG_MAXPQSIZETXSEL_57_RT_OFFSET                              29699
-#define QM_REG_MAXPQSIZETXSEL_58_RT_OFFSET                              29700
-#define QM_REG_MAXPQSIZETXSEL_59_RT_OFFSET                              29701
-#define QM_REG_MAXPQSIZETXSEL_60_RT_OFFSET                              29702
-#define QM_REG_MAXPQSIZETXSEL_61_RT_OFFSET                              29703
-#define QM_REG_MAXPQSIZETXSEL_62_RT_OFFSET                              29704
-#define QM_REG_MAXPQSIZETXSEL_63_RT_OFFSET                              29705
-#define QM_REG_BASEADDROTHERPQ_RT_OFFSET                                29706
+#define QM_REG_MAXPQSIZE_0_RT_OFFSET                                    29641
+#define QM_REG_MAXPQSIZE_1_RT_OFFSET                                    29642
+#define QM_REG_MAXPQSIZE_2_RT_OFFSET                                    29643
+#define QM_REG_MAXPQSIZETXSEL_0_RT_OFFSET                               29644
+#define QM_REG_MAXPQSIZETXSEL_1_RT_OFFSET                               29645
+#define QM_REG_MAXPQSIZETXSEL_2_RT_OFFSET                               29646
+#define QM_REG_MAXPQSIZETXSEL_3_RT_OFFSET                               29647
+#define QM_REG_MAXPQSIZETXSEL_4_RT_OFFSET                               29648
+#define QM_REG_MAXPQSIZETXSEL_5_RT_OFFSET                               29649
+#define QM_REG_MAXPQSIZETXSEL_6_RT_OFFSET                               29650
+#define QM_REG_MAXPQSIZETXSEL_7_RT_OFFSET                               29651
+#define QM_REG_MAXPQSIZETXSEL_8_RT_OFFSET                               29652
+#define QM_REG_MAXPQSIZETXSEL_9_RT_OFFSET                               29653
+#define QM_REG_MAXPQSIZETXSEL_10_RT_OFFSET                              29654
+#define QM_REG_MAXPQSIZETXSEL_11_RT_OFFSET                              29655
+#define QM_REG_MAXPQSIZETXSEL_12_RT_OFFSET                              29656
+#define QM_REG_MAXPQSIZETXSEL_13_RT_OFFSET                              29657
+#define QM_REG_MAXPQSIZETXSEL_14_RT_OFFSET                              29658
+#define QM_REG_MAXPQSIZETXSEL_15_RT_OFFSET                              29659
+#define QM_REG_MAXPQSIZETXSEL_16_RT_OFFSET                              29660
+#define QM_REG_MAXPQSIZETXSEL_17_RT_OFFSET                              29661
+#define QM_REG_MAXPQSIZETXSEL_18_RT_OFFSET                              29662
+#define QM_REG_MAXPQSIZETXSEL_19_RT_OFFSET                              29663
+#define QM_REG_MAXPQSIZETXSEL_20_RT_OFFSET                              29664
+#define QM_REG_MAXPQSIZETXSEL_21_RT_OFFSET                              29665
+#define QM_REG_MAXPQSIZETXSEL_22_RT_OFFSET                              29666
+#define QM_REG_MAXPQSIZETXSEL_23_RT_OFFSET                              29667
+#define QM_REG_MAXPQSIZETXSEL_24_RT_OFFSET                              29668
+#define QM_REG_MAXPQSIZETXSEL_25_RT_OFFSET                              29669
+#define QM_REG_MAXPQSIZETXSEL_26_RT_OFFSET                              29670
+#define QM_REG_MAXPQSIZETXSEL_27_RT_OFFSET                              29671
+#define QM_REG_MAXPQSIZETXSEL_28_RT_OFFSET                              29672
+#define QM_REG_MAXPQSIZETXSEL_29_RT_OFFSET                              29673
+#define QM_REG_MAXPQSIZETXSEL_30_RT_OFFSET                              29674
+#define QM_REG_MAXPQSIZETXSEL_31_RT_OFFSET                              29675
+#define QM_REG_MAXPQSIZETXSEL_32_RT_OFFSET                              29676
+#define QM_REG_MAXPQSIZETXSEL_33_RT_OFFSET                              29677
+#define QM_REG_MAXPQSIZETXSEL_34_RT_OFFSET                              29678
+#define QM_REG_MAXPQSIZETXSEL_35_RT_OFFSET                              29679
+#define QM_REG_MAXPQSIZETXSEL_36_RT_OFFSET                              29680
+#define QM_REG_MAXPQSIZETXSEL_37_RT_OFFSET                              29681
+#define QM_REG_MAXPQSIZETXSEL_38_RT_OFFSET                              29682
+#define QM_REG_MAXPQSIZETXSEL_39_RT_OFFSET                              29683
+#define QM_REG_MAXPQSIZETXSEL_40_RT_OFFSET                              29684
+#define QM_REG_MAXPQSIZETXSEL_41_RT_OFFSET                              29685
+#define QM_REG_MAXPQSIZETXSEL_42_RT_OFFSET                              29686
+#define QM_REG_MAXPQSIZETXSEL_43_RT_OFFSET                              29687
+#define QM_REG_MAXPQSIZETXSEL_44_RT_OFFSET                              29688
+#define QM_REG_MAXPQSIZETXSEL_45_RT_OFFSET                              29689
+#define QM_REG_MAXPQSIZETXSEL_46_RT_OFFSET                              29690
+#define QM_REG_MAXPQSIZETXSEL_47_RT_OFFSET                              29691
+#define QM_REG_MAXPQSIZETXSEL_48_RT_OFFSET                              29692
+#define QM_REG_MAXPQSIZETXSEL_49_RT_OFFSET                              29693
+#define QM_REG_MAXPQSIZETXSEL_50_RT_OFFSET                              29694
+#define QM_REG_MAXPQSIZETXSEL_51_RT_OFFSET                              29695
+#define QM_REG_MAXPQSIZETXSEL_52_RT_OFFSET                              29696
+#define QM_REG_MAXPQSIZETXSEL_53_RT_OFFSET                              29697
+#define QM_REG_MAXPQSIZETXSEL_54_RT_OFFSET                              29698
+#define QM_REG_MAXPQSIZETXSEL_55_RT_OFFSET                              29699
+#define QM_REG_MAXPQSIZETXSEL_56_RT_OFFSET                              29700
+#define QM_REG_MAXPQSIZETXSEL_57_RT_OFFSET                              29701
+#define QM_REG_MAXPQSIZETXSEL_58_RT_OFFSET                              29702
+#define QM_REG_MAXPQSIZETXSEL_59_RT_OFFSET                              29703
+#define QM_REG_MAXPQSIZETXSEL_60_RT_OFFSET                              29704
+#define QM_REG_MAXPQSIZETXSEL_61_RT_OFFSET                              29705
+#define QM_REG_MAXPQSIZETXSEL_62_RT_OFFSET                              29706
+#define QM_REG_MAXPQSIZETXSEL_63_RT_OFFSET                              29707
+#define QM_REG_BASEADDROTHERPQ_RT_OFFSET                                29708
 #define QM_REG_BASEADDROTHERPQ_RT_SIZE                                  128
-#define QM_REG_VOQCRDLINE_RT_OFFSET                                     29834
+#define QM_REG_VOQCRDLINE_RT_OFFSET                                     29836
 #define QM_REG_VOQCRDLINE_RT_SIZE                                       20
-#define QM_REG_VOQINITCRDLINE_RT_OFFSET                                 29854
+#define QM_REG_VOQINITCRDLINE_RT_OFFSET                                 29856
 #define QM_REG_VOQINITCRDLINE_RT_SIZE                                   20
-#define QM_REG_AFULLQMBYPTHRPFWFQ_RT_OFFSET                             29874
-#define QM_REG_AFULLQMBYPTHRVPWFQ_RT_OFFSET                             29875
-#define QM_REG_AFULLQMBYPTHRPFRL_RT_OFFSET                              29876
-#define QM_REG_AFULLQMBYPTHRGLBLRL_RT_OFFSET                            29877
-#define QM_REG_AFULLOPRTNSTCCRDMASK_RT_OFFSET                           29878
-#define QM_REG_WRROTHERPQGRP_0_RT_OFFSET                                29879
-#define QM_REG_WRROTHERPQGRP_1_RT_OFFSET                                29880
-#define QM_REG_WRROTHERPQGRP_2_RT_OFFSET                                29881
-#define QM_REG_WRROTHERPQGRP_3_RT_OFFSET                                29882
-#define QM_REG_WRROTHERPQGRP_4_RT_OFFSET                                29883
-#define QM_REG_WRROTHERPQGRP_5_RT_OFFSET                                29884
-#define QM_REG_WRROTHERPQGRP_6_RT_OFFSET                                29885
-#define QM_REG_WRROTHERPQGRP_7_RT_OFFSET                                29886
-#define QM_REG_WRROTHERPQGRP_8_RT_OFFSET                                29887
-#define QM_REG_WRROTHERPQGRP_9_RT_OFFSET                                29888
-#define QM_REG_WRROTHERPQGRP_10_RT_OFFSET                               29889
-#define QM_REG_WRROTHERPQGRP_11_RT_OFFSET                               29890
-#define QM_REG_WRROTHERPQGRP_12_RT_OFFSET                               29891
-#define QM_REG_WRROTHERPQGRP_13_RT_OFFSET                               29892
-#define QM_REG_WRROTHERPQGRP_14_RT_OFFSET                               29893
-#define QM_REG_WRROTHERPQGRP_15_RT_OFFSET                               29894
-#define QM_REG_WRROTHERGRPWEIGHT_0_RT_OFFSET                            29895
-#define QM_REG_WRROTHERGRPWEIGHT_1_RT_OFFSET                            29896
-#define QM_REG_WRROTHERGRPWEIGHT_2_RT_OFFSET                            29897
-#define QM_REG_WRROTHERGRPWEIGHT_3_RT_OFFSET                            29898
-#define QM_REG_WRRTXGRPWEIGHT_0_RT_OFFSET                               29899
-#define QM_REG_WRRTXGRPWEIGHT_1_RT_OFFSET                               29900
-#define QM_REG_PQTX2PF_0_RT_OFFSET                                      29901
-#define QM_REG_PQTX2PF_1_RT_OFFSET                                      29902
-#define QM_REG_PQTX2PF_2_RT_OFFSET                                      29903
-#define QM_REG_PQTX2PF_3_RT_OFFSET                                      29904
-#define QM_REG_PQTX2PF_4_RT_OFFSET                                      29905
-#define QM_REG_PQTX2PF_5_RT_OFFSET                                      29906
-#define QM_REG_PQTX2PF_6_RT_OFFSET                                      29907
-#define QM_REG_PQTX2PF_7_RT_OFFSET                                      29908
-#define QM_REG_PQTX2PF_8_RT_OFFSET                                      29909
-#define QM_REG_PQTX2PF_9_RT_OFFSET                                      29910
-#define QM_REG_PQTX2PF_10_RT_OFFSET                                     29911
-#define QM_REG_PQTX2PF_11_RT_OFFSET                                     29912
-#define QM_REG_PQTX2PF_12_RT_OFFSET                                     29913
-#define QM_REG_PQTX2PF_13_RT_OFFSET                                     29914
-#define QM_REG_PQTX2PF_14_RT_OFFSET                                     29915
-#define QM_REG_PQTX2PF_15_RT_OFFSET                                     29916
-#define QM_REG_PQTX2PF_16_RT_OFFSET                                     29917
-#define QM_REG_PQTX2PF_17_RT_OFFSET                                     29918
-#define QM_REG_PQTX2PF_18_RT_OFFSET                                     29919
-#define QM_REG_PQTX2PF_19_RT_OFFSET                                     29920
-#define QM_REG_PQTX2PF_20_RT_OFFSET                                     29921
-#define QM_REG_PQTX2PF_21_RT_OFFSET                                     29922
-#define QM_REG_PQTX2PF_22_RT_OFFSET                                     29923
-#define QM_REG_PQTX2PF_23_RT_OFFSET                                     29924
-#define QM_REG_PQTX2PF_24_RT_OFFSET                                     29925
-#define QM_REG_PQTX2PF_25_RT_OFFSET                                     29926
-#define QM_REG_PQTX2PF_26_RT_OFFSET                                     29927
-#define QM_REG_PQTX2PF_27_RT_OFFSET                                     29928
-#define QM_REG_PQTX2PF_28_RT_OFFSET                                     29929
-#define QM_REG_PQTX2PF_29_RT_OFFSET                                     29930
-#define QM_REG_PQTX2PF_30_RT_OFFSET                                     29931
-#define QM_REG_PQTX2PF_31_RT_OFFSET                                     29932
-#define QM_REG_PQTX2PF_32_RT_OFFSET                                     29933
-#define QM_REG_PQTX2PF_33_RT_OFFSET                                     29934
-#define QM_REG_PQTX2PF_34_RT_OFFSET                                     29935
-#define QM_REG_PQTX2PF_35_RT_OFFSET                                     29936
-#define QM_REG_PQTX2PF_36_RT_OFFSET                                     29937
-#define QM_REG_PQTX2PF_37_RT_OFFSET                                     29938
-#define QM_REG_PQTX2PF_38_RT_OFFSET                                     29939
-#define QM_REG_PQTX2PF_39_RT_OFFSET                                     29940
-#define QM_REG_PQTX2PF_40_RT_OFFSET                                     29941
-#define QM_REG_PQTX2PF_41_RT_OFFSET                                     29942
-#define QM_REG_PQTX2PF_42_RT_OFFSET                                     29943
-#define QM_REG_PQTX2PF_43_RT_OFFSET                                     29944
-#define QM_REG_PQTX2PF_44_RT_OFFSET                                     29945
-#define QM_REG_PQTX2PF_45_RT_OFFSET                                     29946
-#define QM_REG_PQTX2PF_46_RT_OFFSET                                     29947
-#define QM_REG_PQTX2PF_47_RT_OFFSET                                     29948
-#define QM_REG_PQTX2PF_48_RT_OFFSET                                     29949
-#define QM_REG_PQTX2PF_49_RT_OFFSET                                     29950
-#define QM_REG_PQTX2PF_50_RT_OFFSET                                     29951
-#define QM_REG_PQTX2PF_51_RT_OFFSET                                     29952
-#define QM_REG_PQTX2PF_52_RT_OFFSET                                     29953
-#define QM_REG_PQTX2PF_53_RT_OFFSET                                     29954
-#define QM_REG_PQTX2PF_54_RT_OFFSET                                     29955
-#define QM_REG_PQTX2PF_55_RT_OFFSET                                     29956
-#define QM_REG_PQTX2PF_56_RT_OFFSET                                     29957
-#define QM_REG_PQTX2PF_57_RT_OFFSET                                     29958
-#define QM_REG_PQTX2PF_58_RT_OFFSET                                     29959
-#define QM_REG_PQTX2PF_59_RT_OFFSET                                     29960
-#define QM_REG_PQTX2PF_60_RT_OFFSET                                     29961
-#define QM_REG_PQTX2PF_61_RT_OFFSET                                     29962
-#define QM_REG_PQTX2PF_62_RT_OFFSET                                     29963
-#define QM_REG_PQTX2PF_63_RT_OFFSET                                     29964
-#define QM_REG_PQOTHER2PF_0_RT_OFFSET                                   29965
-#define QM_REG_PQOTHER2PF_1_RT_OFFSET                                   29966
-#define QM_REG_PQOTHER2PF_2_RT_OFFSET                                   29967
-#define QM_REG_PQOTHER2PF_3_RT_OFFSET                                   29968
-#define QM_REG_PQOTHER2PF_4_RT_OFFSET                                   29969
-#define QM_REG_PQOTHER2PF_5_RT_OFFSET                                   29970
-#define QM_REG_PQOTHER2PF_6_RT_OFFSET                                   29971
-#define QM_REG_PQOTHER2PF_7_RT_OFFSET                                   29972
-#define QM_REG_PQOTHER2PF_8_RT_OFFSET                                   29973
-#define QM_REG_PQOTHER2PF_9_RT_OFFSET                                   29974
-#define QM_REG_PQOTHER2PF_10_RT_OFFSET                                  29975
-#define QM_REG_PQOTHER2PF_11_RT_OFFSET                                  29976
-#define QM_REG_PQOTHER2PF_12_RT_OFFSET                                  29977
-#define QM_REG_PQOTHER2PF_13_RT_OFFSET                                  29978
-#define QM_REG_PQOTHER2PF_14_RT_OFFSET                                  29979
-#define QM_REG_PQOTHER2PF_15_RT_OFFSET                                  29980
-#define QM_REG_RLGLBLPERIOD_0_RT_OFFSET                                 29981
-#define QM_REG_RLGLBLPERIOD_1_RT_OFFSET                                 29982
-#define QM_REG_RLGLBLPERIODTIMER_0_RT_OFFSET                            29983
-#define QM_REG_RLGLBLPERIODTIMER_1_RT_OFFSET                            29984
-#define QM_REG_RLGLBLPERIODSEL_0_RT_OFFSET                              29985
-#define QM_REG_RLGLBLPERIODSEL_1_RT_OFFSET                              29986
-#define QM_REG_RLGLBLPERIODSEL_2_RT_OFFSET                              29987
-#define QM_REG_RLGLBLPERIODSEL_3_RT_OFFSET                              29988
-#define QM_REG_RLGLBLPERIODSEL_4_RT_OFFSET                              29989
-#define QM_REG_RLGLBLPERIODSEL_5_RT_OFFSET                              29990
-#define QM_REG_RLGLBLPERIODSEL_6_RT_OFFSET                              29991
-#define QM_REG_RLGLBLPERIODSEL_7_RT_OFFSET                              29992
-#define QM_REG_RLGLBLINCVAL_RT_OFFSET                                   29993
+#define QM_REG_AFULLQMBYPTHRPFWFQ_RT_OFFSET                             29876
+#define QM_REG_AFULLQMBYPTHRVPWFQ_RT_OFFSET                             29877
+#define QM_REG_AFULLQMBYPTHRPFRL_RT_OFFSET                              29878
+#define QM_REG_AFULLQMBYPTHRGLBLRL_RT_OFFSET                            29879
+#define QM_REG_AFULLOPRTNSTCCRDMASK_RT_OFFSET                           29880
+#define QM_REG_WRROTHERPQGRP_0_RT_OFFSET                                29881
+#define QM_REG_WRROTHERPQGRP_1_RT_OFFSET                                29882
+#define QM_REG_WRROTHERPQGRP_2_RT_OFFSET                                29883
+#define QM_REG_WRROTHERPQGRP_3_RT_OFFSET                                29884
+#define QM_REG_WRROTHERPQGRP_4_RT_OFFSET                                29885
+#define QM_REG_WRROTHERPQGRP_5_RT_OFFSET                                29886
+#define QM_REG_WRROTHERPQGRP_6_RT_OFFSET                                29887
+#define QM_REG_WRROTHERPQGRP_7_RT_OFFSET                                29888
+#define QM_REG_WRROTHERPQGRP_8_RT_OFFSET                                29889
+#define QM_REG_WRROTHERPQGRP_9_RT_OFFSET                                29890
+#define QM_REG_WRROTHERPQGRP_10_RT_OFFSET                               29891
+#define QM_REG_WRROTHERPQGRP_11_RT_OFFSET                               29892
+#define QM_REG_WRROTHERPQGRP_12_RT_OFFSET                               29893
+#define QM_REG_WRROTHERPQGRP_13_RT_OFFSET                               29894
+#define QM_REG_WRROTHERPQGRP_14_RT_OFFSET                               29895
+#define QM_REG_WRROTHERPQGRP_15_RT_OFFSET                               29896
+#define QM_REG_WRROTHERGRPWEIGHT_0_RT_OFFSET                            29897
+#define QM_REG_WRROTHERGRPWEIGHT_1_RT_OFFSET                            29898
+#define QM_REG_WRROTHERGRPWEIGHT_2_RT_OFFSET                            29899
+#define QM_REG_WRROTHERGRPWEIGHT_3_RT_OFFSET                            29900
+#define QM_REG_WRRTXGRPWEIGHT_0_RT_OFFSET                               29901
+#define QM_REG_WRRTXGRPWEIGHT_1_RT_OFFSET                               29902
+#define QM_REG_PQTX2PF_0_RT_OFFSET                                      29903
+#define QM_REG_PQTX2PF_1_RT_OFFSET                                      29904
+#define QM_REG_PQTX2PF_2_RT_OFFSET                                      29905
+#define QM_REG_PQTX2PF_3_RT_OFFSET                                      29906
+#define QM_REG_PQTX2PF_4_RT_OFFSET                                      29907
+#define QM_REG_PQTX2PF_5_RT_OFFSET                                      29908
+#define QM_REG_PQTX2PF_6_RT_OFFSET                                      29909
+#define QM_REG_PQTX2PF_7_RT_OFFSET                                      29910
+#define QM_REG_PQTX2PF_8_RT_OFFSET                                      29911
+#define QM_REG_PQTX2PF_9_RT_OFFSET                                      29912
+#define QM_REG_PQTX2PF_10_RT_OFFSET                                     29913
+#define QM_REG_PQTX2PF_11_RT_OFFSET                                     29914
+#define QM_REG_PQTX2PF_12_RT_OFFSET                                     29915
+#define QM_REG_PQTX2PF_13_RT_OFFSET                                     29916
+#define QM_REG_PQTX2PF_14_RT_OFFSET                                     29917
+#define QM_REG_PQTX2PF_15_RT_OFFSET                                     29918
+#define QM_REG_PQTX2PF_16_RT_OFFSET                                     29919
+#define QM_REG_PQTX2PF_17_RT_OFFSET                                     29920
+#define QM_REG_PQTX2PF_18_RT_OFFSET                                     29921
+#define QM_REG_PQTX2PF_19_RT_OFFSET                                     29922
+#define QM_REG_PQTX2PF_20_RT_OFFSET                                     29923
+#define QM_REG_PQTX2PF_21_RT_OFFSET                                     29924
+#define QM_REG_PQTX2PF_22_RT_OFFSET                                     29925
+#define QM_REG_PQTX2PF_23_RT_OFFSET                                     29926
+#define QM_REG_PQTX2PF_24_RT_OFFSET                                     29927
+#define QM_REG_PQTX2PF_25_RT_OFFSET                                     29928
+#define QM_REG_PQTX2PF_26_RT_OFFSET                                     29929
+#define QM_REG_PQTX2PF_27_RT_OFFSET                                     29930
+#define QM_REG_PQTX2PF_28_RT_OFFSET                                     29931
+#define QM_REG_PQTX2PF_29_RT_OFFSET                                     29932
+#define QM_REG_PQTX2PF_30_RT_OFFSET                                     29933
+#define QM_REG_PQTX2PF_31_RT_OFFSET                                     29934
+#define QM_REG_PQTX2PF_32_RT_OFFSET                                     29935
+#define QM_REG_PQTX2PF_33_RT_OFFSET                                     29936
+#define QM_REG_PQTX2PF_34_RT_OFFSET                                     29937
+#define QM_REG_PQTX2PF_35_RT_OFFSET                                     29938
+#define QM_REG_PQTX2PF_36_RT_OFFSET                                     29939
+#define QM_REG_PQTX2PF_37_RT_OFFSET                                     29940
+#define QM_REG_PQTX2PF_38_RT_OFFSET                                     29941
+#define QM_REG_PQTX2PF_39_RT_OFFSET                                     29942
+#define QM_REG_PQTX2PF_40_RT_OFFSET                                     29943
+#define QM_REG_PQTX2PF_41_RT_OFFSET                                     29944
+#define QM_REG_PQTX2PF_42_RT_OFFSET                                     29945
+#define QM_REG_PQTX2PF_43_RT_OFFSET                                     29946
+#define QM_REG_PQTX2PF_44_RT_OFFSET                                     29947
+#define QM_REG_PQTX2PF_45_RT_OFFSET                                     29948
+#define QM_REG_PQTX2PF_46_RT_OFFSET                                     29949
+#define QM_REG_PQTX2PF_47_RT_OFFSET                                     29950
+#define QM_REG_PQTX2PF_48_RT_OFFSET                                     29951
+#define QM_REG_PQTX2PF_49_RT_OFFSET                                     29952
+#define QM_REG_PQTX2PF_50_RT_OFFSET                                     29953
+#define QM_REG_PQTX2PF_51_RT_OFFSET                                     29954
+#define QM_REG_PQTX2PF_52_RT_OFFSET                                     29955
+#define QM_REG_PQTX2PF_53_RT_OFFSET                                     29956
+#define QM_REG_PQTX2PF_54_RT_OFFSET                                     29957
+#define QM_REG_PQTX2PF_55_RT_OFFSET                                     29958
+#define QM_REG_PQTX2PF_56_RT_OFFSET                                     29959
+#define QM_REG_PQTX2PF_57_RT_OFFSET                                     29960
+#define QM_REG_PQTX2PF_58_RT_OFFSET                                     29961
+#define QM_REG_PQTX2PF_59_RT_OFFSET                                     29962
+#define QM_REG_PQTX2PF_60_RT_OFFSET                                     29963
+#define QM_REG_PQTX2PF_61_RT_OFFSET                                     29964
+#define QM_REG_PQTX2PF_62_RT_OFFSET                                     29965
+#define QM_REG_PQTX2PF_63_RT_OFFSET                                     29966
+#define QM_REG_PQOTHER2PF_0_RT_OFFSET                                   29967
+#define QM_REG_PQOTHER2PF_1_RT_OFFSET                                   29968
+#define QM_REG_PQOTHER2PF_2_RT_OFFSET                                   29969
+#define QM_REG_PQOTHER2PF_3_RT_OFFSET                                   29970
+#define QM_REG_PQOTHER2PF_4_RT_OFFSET                                   29971
+#define QM_REG_PQOTHER2PF_5_RT_OFFSET                                   29972
+#define QM_REG_PQOTHER2PF_6_RT_OFFSET                                   29973
+#define QM_REG_PQOTHER2PF_7_RT_OFFSET                                   29974
+#define QM_REG_PQOTHER2PF_8_RT_OFFSET                                   29975
+#define QM_REG_PQOTHER2PF_9_RT_OFFSET                                   29976
+#define QM_REG_PQOTHER2PF_10_RT_OFFSET                                  29977
+#define QM_REG_PQOTHER2PF_11_RT_OFFSET                                  29978
+#define QM_REG_PQOTHER2PF_12_RT_OFFSET                                  29979
+#define QM_REG_PQOTHER2PF_13_RT_OFFSET                                  29980
+#define QM_REG_PQOTHER2PF_14_RT_OFFSET                                  29981
+#define QM_REG_PQOTHER2PF_15_RT_OFFSET                                  29982
+#define QM_REG_RLGLBLPERIOD_0_RT_OFFSET                                 29983
+#define QM_REG_RLGLBLPERIOD_1_RT_OFFSET                                 29984
+#define QM_REG_RLGLBLPERIODTIMER_0_RT_OFFSET                            29985
+#define QM_REG_RLGLBLPERIODTIMER_1_RT_OFFSET                            29986
+#define QM_REG_RLGLBLPERIODSEL_0_RT_OFFSET                              29987
+#define QM_REG_RLGLBLPERIODSEL_1_RT_OFFSET                              29988
+#define QM_REG_RLGLBLPERIODSEL_2_RT_OFFSET                              29989
+#define QM_REG_RLGLBLPERIODSEL_3_RT_OFFSET                              29990
+#define QM_REG_RLGLBLPERIODSEL_4_RT_OFFSET                              29991
+#define QM_REG_RLGLBLPERIODSEL_5_RT_OFFSET                              29992
+#define QM_REG_RLGLBLPERIODSEL_6_RT_OFFSET                              29993
+#define QM_REG_RLGLBLPERIODSEL_7_RT_OFFSET                              29994
+#define QM_REG_RLGLBLINCVAL_RT_OFFSET                                   29995
 #define QM_REG_RLGLBLINCVAL_RT_SIZE                                     256
-#define QM_REG_RLGLBLUPPERBOUND_RT_OFFSET                               30249
+#define QM_REG_RLGLBLUPPERBOUND_RT_OFFSET                               30251
 #define QM_REG_RLGLBLUPPERBOUND_RT_SIZE                                 256
-#define QM_REG_RLGLBLCRD_RT_OFFSET                                      30505
+#define QM_REG_RLGLBLCRD_RT_OFFSET                                      30507
 #define QM_REG_RLGLBLCRD_RT_SIZE                                        256
-#define QM_REG_RLGLBLENABLE_RT_OFFSET                                   30761
-#define QM_REG_RLPFPERIOD_RT_OFFSET                                     30762
-#define QM_REG_RLPFPERIODTIMER_RT_OFFSET                                30763
-#define QM_REG_RLPFINCVAL_RT_OFFSET                                     30764
+#define QM_REG_RLGLBLENABLE_RT_OFFSET                                   30763
+#define QM_REG_RLPFPERIOD_RT_OFFSET                                     30764
+#define QM_REG_RLPFPERIODTIMER_RT_OFFSET                                30765
+#define QM_REG_RLPFINCVAL_RT_OFFSET                                     30766
 #define QM_REG_RLPFINCVAL_RT_SIZE                                       16
-#define QM_REG_RLPFUPPERBOUND_RT_OFFSET                                 30780
+#define QM_REG_RLPFUPPERBOUND_RT_OFFSET                                 30782
 #define QM_REG_RLPFUPPERBOUND_RT_SIZE                                   16
-#define QM_REG_RLPFCRD_RT_OFFSET                                        30796
+#define QM_REG_RLPFCRD_RT_OFFSET                                        30798
 #define QM_REG_RLPFCRD_RT_SIZE                                          16
-#define QM_REG_RLPFENABLE_RT_OFFSET                                     30812
-#define QM_REG_RLPFVOQENABLE_RT_OFFSET                                  30813
-#define QM_REG_WFQPFWEIGHT_RT_OFFSET                                    30814
+#define QM_REG_RLPFENABLE_RT_OFFSET                                     30814
+#define QM_REG_RLPFVOQENABLE_RT_OFFSET                                  30815
+#define QM_REG_WFQPFWEIGHT_RT_OFFSET                                    30816
 #define QM_REG_WFQPFWEIGHT_RT_SIZE                                      16
-#define QM_REG_WFQPFUPPERBOUND_RT_OFFSET                                30830
+#define QM_REG_WFQPFUPPERBOUND_RT_OFFSET                                30832
 #define QM_REG_WFQPFUPPERBOUND_RT_SIZE                                  16
-#define QM_REG_WFQPFCRD_RT_OFFSET                                       30846
+#define QM_REG_WFQPFCRD_RT_OFFSET                                       30848
 #define QM_REG_WFQPFCRD_RT_SIZE                                         160
-#define QM_REG_WFQPFENABLE_RT_OFFSET                                    31006
-#define QM_REG_WFQVPENABLE_RT_OFFSET                                    31007
-#define QM_REG_BASEADDRTXPQ_RT_OFFSET                                   31008
+#define QM_REG_WFQPFENABLE_RT_OFFSET                                    31008
+#define QM_REG_WFQVPENABLE_RT_OFFSET                                    31009
+#define QM_REG_BASEADDRTXPQ_RT_OFFSET                                   31010
 #define QM_REG_BASEADDRTXPQ_RT_SIZE                                     512
-#define QM_REG_TXPQMAP_RT_OFFSET                                        31520
+#define QM_REG_TXPQMAP_RT_OFFSET                                        31522
 #define QM_REG_TXPQMAP_RT_SIZE                                          512
-#define QM_REG_WFQVPWEIGHT_RT_OFFSET                                    32032
+#define QM_REG_WFQVPWEIGHT_RT_OFFSET                                    32034
 #define QM_REG_WFQVPWEIGHT_RT_SIZE                                      512
-#define QM_REG_WFQVPUPPERBOUND_RT_OFFSET                                32544
-#define QM_REG_WFQVPUPPERBOUND_RT_SIZE                                  512
-#define QM_REG_WFQVPCRD_RT_OFFSET                                       33056
+#define QM_REG_WFQVPCRD_RT_OFFSET                                       32546
 #define QM_REG_WFQVPCRD_RT_SIZE                                         512
-#define QM_REG_WFQVPMAP_RT_OFFSET                                       33568
+#define QM_REG_WFQVPMAP_RT_OFFSET                                       33058
 #define QM_REG_WFQVPMAP_RT_SIZE                                         512
-#define QM_REG_WFQPFCRD_MSB_RT_OFFSET                                   34080
+#define QM_REG_WFQPFCRD_MSB_RT_OFFSET                                   33570
 #define QM_REG_WFQPFCRD_MSB_RT_SIZE                                     160
-#define NIG_REG_LLH_CLS_TYPE_DUALMODE_RT_OFFSET                         34240
-#define NIG_REG_OUTER_TAG_VALUE_LIST0_RT_OFFSET                         34241
-#define NIG_REG_OUTER_TAG_VALUE_LIST1_RT_OFFSET                         34242
-#define NIG_REG_OUTER_TAG_VALUE_LIST2_RT_OFFSET                         34243
-#define NIG_REG_OUTER_TAG_VALUE_LIST3_RT_OFFSET                         34244
-#define NIG_REG_OUTER_TAG_VALUE_MASK_RT_OFFSET                          34245
-#define NIG_REG_LLH_FUNC_TAGMAC_CLS_TYPE_RT_OFFSET                      34246
-#define NIG_REG_LLH_FUNC_TAG_EN_RT_OFFSET                               34247
+#define NIG_REG_TAG_ETHERTYPE_0_RT_OFFSET                               33730
+#define NIG_REG_OUTER_TAG_VALUE_LIST0_RT_OFFSET                         33731
+#define NIG_REG_OUTER_TAG_VALUE_LIST1_RT_OFFSET                         33732
+#define NIG_REG_OUTER_TAG_VALUE_LIST2_RT_OFFSET                         33733
+#define NIG_REG_OUTER_TAG_VALUE_LIST3_RT_OFFSET                         33734
+#define NIG_REG_OUTER_TAG_VALUE_MASK_RT_OFFSET                          33735
+#define NIG_REG_LLH_FUNC_TAGMAC_CLS_TYPE_RT_OFFSET                      33736
+#define NIG_REG_LLH_FUNC_TAG_EN_RT_OFFSET                               33737
 #define NIG_REG_LLH_FUNC_TAG_EN_RT_SIZE                                 4
-#define NIG_REG_LLH_FUNC_TAG_HDR_SEL_RT_OFFSET                          34251
+#define NIG_REG_LLH_FUNC_TAG_HDR_SEL_RT_OFFSET                          33741
 #define NIG_REG_LLH_FUNC_TAG_HDR_SEL_RT_SIZE                            4
-#define NIG_REG_LLH_FUNC_TAG_VALUE_RT_OFFSET                            34255
+#define NIG_REG_LLH_FUNC_TAG_VALUE_RT_OFFSET                            33745
 #define NIG_REG_LLH_FUNC_TAG_VALUE_RT_SIZE                              4
-#define NIG_REG_LLH_FUNC_NO_TAG_RT_OFFSET                               34259
-#define NIG_REG_LLH_FUNC_FILTER_VALUE_RT_OFFSET                         34260
+#define NIG_REG_LLH_FUNC_NO_TAG_RT_OFFSET                               33749
+#define NIG_REG_LLH_FUNC_FILTER_VALUE_RT_OFFSET                         33750
 #define NIG_REG_LLH_FUNC_FILTER_VALUE_RT_SIZE                           32
-#define NIG_REG_LLH_FUNC_FILTER_EN_RT_OFFSET                            34292
+#define NIG_REG_LLH_FUNC_FILTER_EN_RT_OFFSET                            33782
 #define NIG_REG_LLH_FUNC_FILTER_EN_RT_SIZE                              16
-#define NIG_REG_LLH_FUNC_FILTER_MODE_RT_OFFSET                          34308
+#define NIG_REG_LLH_FUNC_FILTER_MODE_RT_OFFSET                          33798
 #define NIG_REG_LLH_FUNC_FILTER_MODE_RT_SIZE                            16
-#define NIG_REG_LLH_FUNC_FILTER_PROTOCOL_TYPE_RT_OFFSET                 34324
+#define NIG_REG_LLH_FUNC_FILTER_PROTOCOL_TYPE_RT_OFFSET                 33814
 #define NIG_REG_LLH_FUNC_FILTER_PROTOCOL_TYPE_RT_SIZE                   16
-#define NIG_REG_LLH_FUNC_FILTER_HDR_SEL_RT_OFFSET                       34340
+#define NIG_REG_LLH_FUNC_FILTER_HDR_SEL_RT_OFFSET                       33830
 #define NIG_REG_LLH_FUNC_FILTER_HDR_SEL_RT_SIZE                         16
-#define NIG_REG_TX_EDPM_CTRL_RT_OFFSET                                  34356
-#define CDU_REG_CID_ADDR_PARAMS_RT_OFFSET                               34357
-#define CDU_REG_SEGMENT0_PARAMS_RT_OFFSET                               34358
-#define CDU_REG_SEGMENT1_PARAMS_RT_OFFSET                               34359
-#define CDU_REG_PF_SEG0_TYPE_OFFSET_RT_OFFSET                           34360
-#define CDU_REG_PF_SEG1_TYPE_OFFSET_RT_OFFSET                           34361
-#define CDU_REG_PF_SEG2_TYPE_OFFSET_RT_OFFSET                           34362
-#define CDU_REG_PF_SEG3_TYPE_OFFSET_RT_OFFSET                           34363
-#define CDU_REG_PF_FL_SEG0_TYPE_OFFSET_RT_OFFSET                        34364
-#define CDU_REG_PF_FL_SEG1_TYPE_OFFSET_RT_OFFSET                        34365
-#define CDU_REG_PF_FL_SEG2_TYPE_OFFSET_RT_OFFSET                        34366
-#define CDU_REG_PF_FL_SEG3_TYPE_OFFSET_RT_OFFSET                        34367
-#define CDU_REG_VF_SEG_TYPE_OFFSET_RT_OFFSET                            34368
-#define CDU_REG_VF_FL_SEG_TYPE_OFFSET_RT_OFFSET                         34369
-#define PBF_REG_BTB_SHARED_AREA_SIZE_RT_OFFSET                          34370
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ0_RT_OFFSET                        34371
-#define PBF_REG_BTB_GUARANTEED_VOQ0_RT_OFFSET                           34372
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ0_RT_OFFSET                    34373
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ1_RT_OFFSET                        34374
-#define PBF_REG_BTB_GUARANTEED_VOQ1_RT_OFFSET                           34375
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ1_RT_OFFSET                    34376
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ2_RT_OFFSET                        34377
-#define PBF_REG_BTB_GUARANTEED_VOQ2_RT_OFFSET                           34378
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ2_RT_OFFSET                    34379
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ3_RT_OFFSET                        34380
-#define PBF_REG_BTB_GUARANTEED_VOQ3_RT_OFFSET                           34381
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ3_RT_OFFSET                    34382
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ4_RT_OFFSET                        34383
-#define PBF_REG_BTB_GUARANTEED_VOQ4_RT_OFFSET                           34384
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ4_RT_OFFSET                    34385
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ5_RT_OFFSET                        34386
-#define PBF_REG_BTB_GUARANTEED_VOQ5_RT_OFFSET                           34387
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ5_RT_OFFSET                    34388
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ6_RT_OFFSET                        34389
-#define PBF_REG_BTB_GUARANTEED_VOQ6_RT_OFFSET                           34390
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ6_RT_OFFSET                    34391
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ7_RT_OFFSET                        34392
-#define PBF_REG_BTB_GUARANTEED_VOQ7_RT_OFFSET                           34393
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ7_RT_OFFSET                    34394
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ8_RT_OFFSET                        34395
-#define PBF_REG_BTB_GUARANTEED_VOQ8_RT_OFFSET                           34396
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ8_RT_OFFSET                    34397
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ9_RT_OFFSET                        34398
-#define PBF_REG_BTB_GUARANTEED_VOQ9_RT_OFFSET                           34399
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ9_RT_OFFSET                    34400
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ10_RT_OFFSET                       34401
-#define PBF_REG_BTB_GUARANTEED_VOQ10_RT_OFFSET                          34402
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ10_RT_OFFSET                   34403
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ11_RT_OFFSET                       34404
-#define PBF_REG_BTB_GUARANTEED_VOQ11_RT_OFFSET                          34405
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ11_RT_OFFSET                   34406
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ12_RT_OFFSET                       34407
-#define PBF_REG_BTB_GUARANTEED_VOQ12_RT_OFFSET                          34408
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ12_RT_OFFSET                   34409
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ13_RT_OFFSET                       34410
-#define PBF_REG_BTB_GUARANTEED_VOQ13_RT_OFFSET                          34411
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ13_RT_OFFSET                   34412
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ14_RT_OFFSET                       34413
-#define PBF_REG_BTB_GUARANTEED_VOQ14_RT_OFFSET                          34414
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ14_RT_OFFSET                   34415
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ15_RT_OFFSET                       34416
-#define PBF_REG_BTB_GUARANTEED_VOQ15_RT_OFFSET                          34417
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ15_RT_OFFSET                   34418
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ16_RT_OFFSET                       34419
-#define PBF_REG_BTB_GUARANTEED_VOQ16_RT_OFFSET                          34420
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ16_RT_OFFSET                   34421
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ17_RT_OFFSET                       34422
-#define PBF_REG_BTB_GUARANTEED_VOQ17_RT_OFFSET                          34423
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ17_RT_OFFSET                   34424
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ18_RT_OFFSET                       34425
-#define PBF_REG_BTB_GUARANTEED_VOQ18_RT_OFFSET                          34426
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ18_RT_OFFSET                   34427
-#define PBF_REG_YCMD_QS_NUM_LINES_VOQ19_RT_OFFSET                       34428
-#define PBF_REG_BTB_GUARANTEED_VOQ19_RT_OFFSET                          34429
-#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ19_RT_OFFSET                   34430
-#define XCM_REG_CON_PHY_Q3_RT_OFFSET                                    34431
-
-#define RUNTIME_ARRAY_SIZE 34432
+#define NIG_REG_TX_EDPM_CTRL_RT_OFFSET                                  33846
+#define CDU_REG_CID_ADDR_PARAMS_RT_OFFSET                               33847
+#define CDU_REG_SEGMENT0_PARAMS_RT_OFFSET                               33848
+#define CDU_REG_SEGMENT1_PARAMS_RT_OFFSET                               33849
+#define CDU_REG_PF_SEG0_TYPE_OFFSET_RT_OFFSET                           33850
+#define CDU_REG_PF_SEG1_TYPE_OFFSET_RT_OFFSET                           33851
+#define CDU_REG_PF_SEG2_TYPE_OFFSET_RT_OFFSET                           33852
+#define CDU_REG_PF_SEG3_TYPE_OFFSET_RT_OFFSET                           33853
+#define CDU_REG_PF_FL_SEG0_TYPE_OFFSET_RT_OFFSET                        33854
+#define CDU_REG_PF_FL_SEG1_TYPE_OFFSET_RT_OFFSET                        33855
+#define CDU_REG_PF_FL_SEG2_TYPE_OFFSET_RT_OFFSET                        33856
+#define CDU_REG_PF_FL_SEG3_TYPE_OFFSET_RT_OFFSET                        33857
+#define CDU_REG_VF_SEG_TYPE_OFFSET_RT_OFFSET                            33858
+#define CDU_REG_VF_FL_SEG_TYPE_OFFSET_RT_OFFSET                         33859
+#define PBF_REG_TAG_ETHERTYPE_0_RT_OFFSET                               33860
+#define PBF_REG_BTB_SHARED_AREA_SIZE_RT_OFFSET                          33861
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ0_RT_OFFSET                        33862
+#define PBF_REG_BTB_GUARANTEED_VOQ0_RT_OFFSET                           33863
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ0_RT_OFFSET                    33864
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ1_RT_OFFSET                        33865
+#define PBF_REG_BTB_GUARANTEED_VOQ1_RT_OFFSET                           33866
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ1_RT_OFFSET                    33867
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ2_RT_OFFSET                        33868
+#define PBF_REG_BTB_GUARANTEED_VOQ2_RT_OFFSET                           33869
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ2_RT_OFFSET                    33870
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ3_RT_OFFSET                        33871
+#define PBF_REG_BTB_GUARANTEED_VOQ3_RT_OFFSET                           33872
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ3_RT_OFFSET                    33873
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ4_RT_OFFSET                        33874
+#define PBF_REG_BTB_GUARANTEED_VOQ4_RT_OFFSET                           33875
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ4_RT_OFFSET                    33876
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ5_RT_OFFSET                        33877
+#define PBF_REG_BTB_GUARANTEED_VOQ5_RT_OFFSET                           33878
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ5_RT_OFFSET                    33879
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ6_RT_OFFSET                        33880
+#define PBF_REG_BTB_GUARANTEED_VOQ6_RT_OFFSET                           33881
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ6_RT_OFFSET                    33882
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ7_RT_OFFSET                        33883
+#define PBF_REG_BTB_GUARANTEED_VOQ7_RT_OFFSET                           33884
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ7_RT_OFFSET                    33885
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ8_RT_OFFSET                        33886
+#define PBF_REG_BTB_GUARANTEED_VOQ8_RT_OFFSET                           33887
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ8_RT_OFFSET                    33888
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ9_RT_OFFSET                        33889
+#define PBF_REG_BTB_GUARANTEED_VOQ9_RT_OFFSET                           33890
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ9_RT_OFFSET                    33891
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ10_RT_OFFSET                       33892
+#define PBF_REG_BTB_GUARANTEED_VOQ10_RT_OFFSET                          33893
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ10_RT_OFFSET                   33894
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ11_RT_OFFSET                       33895
+#define PBF_REG_BTB_GUARANTEED_VOQ11_RT_OFFSET                          33896
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ11_RT_OFFSET                   33897
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ12_RT_OFFSET                       33898
+#define PBF_REG_BTB_GUARANTEED_VOQ12_RT_OFFSET                          33899
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ12_RT_OFFSET                   33900
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ13_RT_OFFSET                       33901
+#define PBF_REG_BTB_GUARANTEED_VOQ13_RT_OFFSET                          33902
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ13_RT_OFFSET                   33903
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ14_RT_OFFSET                       33904
+#define PBF_REG_BTB_GUARANTEED_VOQ14_RT_OFFSET                          33905
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ14_RT_OFFSET                   33906
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ15_RT_OFFSET                       33907
+#define PBF_REG_BTB_GUARANTEED_VOQ15_RT_OFFSET                          33908
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ15_RT_OFFSET                   33909
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ16_RT_OFFSET                       33910
+#define PBF_REG_BTB_GUARANTEED_VOQ16_RT_OFFSET                          33911
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ16_RT_OFFSET                   33912
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ17_RT_OFFSET                       33913
+#define PBF_REG_BTB_GUARANTEED_VOQ17_RT_OFFSET                          33914
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ17_RT_OFFSET                   33915
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ18_RT_OFFSET                       33916
+#define PBF_REG_BTB_GUARANTEED_VOQ18_RT_OFFSET                          33917
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ18_RT_OFFSET                   33918
+#define PBF_REG_YCMD_QS_NUM_LINES_VOQ19_RT_OFFSET                       33919
+#define PBF_REG_BTB_GUARANTEED_VOQ19_RT_OFFSET                          33920
+#define PBF_REG_BTB_SHARED_AREA_SETUP_VOQ19_RT_OFFSET                   33921
+#define XCM_REG_CON_PHY_Q3_RT_OFFSET                                    33922
+
+#define RUNTIME_ARRAY_SIZE 33923
 
-/* The eth storm context for the Ystorm */
-struct ystorm_eth_conn_st_ctx {
+/* The eth storm context for the Tstorm */
+struct tstorm_eth_conn_st_ctx {
 	__le32 reserved[4];
 };
 
@@ -2535,41 +2501,253 @@ struct xstorm_eth_conn_ag_ctx {
 	__le32	reg7 /* reg7 */;
 	__le32	reg8 /* reg8 */;
 	__le32	reg9 /* reg9 */;
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
+	u8	byte7 /* byte7 */;
+	u8	byte8 /* byte8 */;
+	u8	byte9 /* byte9 */;
+	u8	byte10 /* byte10 */;
+	u8	byte11 /* byte11 */;
+	u8	byte12 /* byte12 */;
+	u8	byte13 /* byte13 */;
+	u8	byte14 /* byte14 */;
+	u8	byte15 /* byte15 */;
+	u8	byte16 /* byte16 */;
+	__le16	word11 /* word11 */;
+	__le32	reg10 /* reg10 */;
+	__le32	reg11 /* reg11 */;
+	__le32	reg12 /* reg12 */;
+	__le32	reg13 /* reg13 */;
+	__le32	reg14 /* reg14 */;
+	__le32	reg15 /* reg15 */;
+	__le32	reg16 /* reg16 */;
+	__le32	reg17 /* reg17 */;
+	__le32	reg18 /* reg18 */;
+	__le32	reg19 /* reg19 */;
+	__le16	word12 /* word12 */;
+	__le16	word13 /* word13 */;
+	__le16	word14 /* word14 */;
+	__le16	word15 /* word15 */;
+};
+
+/* The eth storm context for the Ystorm */
+struct ystorm_eth_conn_st_ctx {
+	__le32 reserved[8];
+};
+
+struct ystorm_eth_conn_ag_ctx {
+	u8	byte0 /* cdu_validation */;
+	u8	byte1 /* state */;
+	u8	flags0;
+#define YSTORM_ETH_CONN_AG_CTX_BIT0_MASK                  0x1 /* exist_in_qm0 */
+#define YSTORM_ETH_CONN_AG_CTX_BIT0_SHIFT                 0
+#define YSTORM_ETH_CONN_AG_CTX_BIT1_MASK                  0x1 /* exist_in_qm1 */
+#define YSTORM_ETH_CONN_AG_CTX_BIT1_SHIFT                 1
+#define YSTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_MASK     0x3   /* cf0 */
+#define YSTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_SHIFT    2
+#define YSTORM_ETH_CONN_AG_CTX_PMD_TERMINATE_CF_MASK      0x3   /* cf1 */
+#define YSTORM_ETH_CONN_AG_CTX_PMD_TERMINATE_CF_SHIFT     4
+#define YSTORM_ETH_CONN_AG_CTX_CF2_MASK                   0x3   /* cf2 */
+#define YSTORM_ETH_CONN_AG_CTX_CF2_SHIFT                  6
+	u8 flags1;
+#define YSTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_EN_MASK  0x1   /* cf0en */
+#define YSTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_EN_SHIFT 0
+#define YSTORM_ETH_CONN_AG_CTX_PMD_TERMINATE_CF_EN_MASK   0x1   /* cf1en */
+#define YSTORM_ETH_CONN_AG_CTX_PMD_TERMINATE_CF_EN_SHIFT  1
+#define YSTORM_ETH_CONN_AG_CTX_CF2EN_MASK                 0x1   /* cf2en */
+#define YSTORM_ETH_CONN_AG_CTX_CF2EN_SHIFT                2
+#define YSTORM_ETH_CONN_AG_CTX_RULE0EN_MASK               0x1   /* rule0en */
+#define YSTORM_ETH_CONN_AG_CTX_RULE0EN_SHIFT              3
+#define YSTORM_ETH_CONN_AG_CTX_RULE1EN_MASK               0x1   /* rule1en */
+#define YSTORM_ETH_CONN_AG_CTX_RULE1EN_SHIFT              4
+#define YSTORM_ETH_CONN_AG_CTX_RULE2EN_MASK               0x1   /* rule2en */
+#define YSTORM_ETH_CONN_AG_CTX_RULE2EN_SHIFT              5
+#define YSTORM_ETH_CONN_AG_CTX_RULE3EN_MASK               0x1   /* rule3en */
+#define YSTORM_ETH_CONN_AG_CTX_RULE3EN_SHIFT              6
+#define YSTORM_ETH_CONN_AG_CTX_RULE4EN_MASK               0x1   /* rule4en */
+#define YSTORM_ETH_CONN_AG_CTX_RULE4EN_SHIFT              7
+	u8	byte2 /* byte2 */;
+	u8	byte3 /* byte3 */;
+	__le16	word0 /* word0 */;
+	__le32	terminate_spqe /* reg0 */;
+	__le32	reg1 /* reg1 */;
+	__le16	tx_bd_cons_upd /* word1 */;
+	__le16	word2 /* word2 */;
+	__le16	word3 /* word3 */;
+	__le16	word4 /* word4 */;
+	__le32	reg2 /* reg2 */;
+	__le32	reg3 /* reg3 */;
+};
+
+struct tstorm_eth_conn_ag_ctx {
+	u8	byte0 /* cdu_validation */;
+	u8	byte1 /* state */;
+	u8	flags0;
+#define TSTORM_ETH_CONN_AG_CTX_BIT0_MASK      0x1       /* exist_in_qm0 */
+#define TSTORM_ETH_CONN_AG_CTX_BIT0_SHIFT     0
+#define TSTORM_ETH_CONN_AG_CTX_BIT1_MASK      0x1       /* exist_in_qm1 */
+#define TSTORM_ETH_CONN_AG_CTX_BIT1_SHIFT     1
+#define TSTORM_ETH_CONN_AG_CTX_BIT2_MASK      0x1       /* bit2 */
+#define TSTORM_ETH_CONN_AG_CTX_BIT2_SHIFT     2
+#define TSTORM_ETH_CONN_AG_CTX_BIT3_MASK      0x1       /* bit3 */
+#define TSTORM_ETH_CONN_AG_CTX_BIT3_SHIFT     3
+#define TSTORM_ETH_CONN_AG_CTX_BIT4_MASK      0x1       /* bit4 */
+#define TSTORM_ETH_CONN_AG_CTX_BIT4_SHIFT     4
+#define TSTORM_ETH_CONN_AG_CTX_BIT5_MASK      0x1       /* bit5 */
+#define TSTORM_ETH_CONN_AG_CTX_BIT5_SHIFT     5
+#define TSTORM_ETH_CONN_AG_CTX_CF0_MASK       0x3       /* timer0cf */
+#define TSTORM_ETH_CONN_AG_CTX_CF0_SHIFT      6
+	u8 flags1;
+#define TSTORM_ETH_CONN_AG_CTX_CF1_MASK       0x3       /* timer1cf */
+#define TSTORM_ETH_CONN_AG_CTX_CF1_SHIFT      0
+#define TSTORM_ETH_CONN_AG_CTX_CF2_MASK       0x3       /* timer2cf */
+#define TSTORM_ETH_CONN_AG_CTX_CF2_SHIFT      2
+#define TSTORM_ETH_CONN_AG_CTX_CF3_MASK       0x3       /* timer_stop_all */
+#define TSTORM_ETH_CONN_AG_CTX_CF3_SHIFT      4
+#define TSTORM_ETH_CONN_AG_CTX_CF4_MASK       0x3       /* cf4 */
+#define TSTORM_ETH_CONN_AG_CTX_CF4_SHIFT      6
+	u8 flags2;
+#define TSTORM_ETH_CONN_AG_CTX_CF5_MASK       0x3       /* cf5 */
+#define TSTORM_ETH_CONN_AG_CTX_CF5_SHIFT      0
+#define TSTORM_ETH_CONN_AG_CTX_CF6_MASK       0x3       /* cf6 */
+#define TSTORM_ETH_CONN_AG_CTX_CF6_SHIFT      2
+#define TSTORM_ETH_CONN_AG_CTX_CF7_MASK       0x3       /* cf7 */
+#define TSTORM_ETH_CONN_AG_CTX_CF7_SHIFT      4
+#define TSTORM_ETH_CONN_AG_CTX_CF8_MASK       0x3       /* cf8 */
+#define TSTORM_ETH_CONN_AG_CTX_CF8_SHIFT      6
+	u8 flags3;
+#define TSTORM_ETH_CONN_AG_CTX_CF9_MASK       0x3       /* cf9 */
+#define TSTORM_ETH_CONN_AG_CTX_CF9_SHIFT      0
+#define TSTORM_ETH_CONN_AG_CTX_CF10_MASK      0x3       /* cf10 */
+#define TSTORM_ETH_CONN_AG_CTX_CF10_SHIFT     2
+#define TSTORM_ETH_CONN_AG_CTX_CF0EN_MASK     0x1       /* cf0en */
+#define TSTORM_ETH_CONN_AG_CTX_CF0EN_SHIFT    4
+#define TSTORM_ETH_CONN_AG_CTX_CF1EN_MASK     0x1       /* cf1en */
+#define TSTORM_ETH_CONN_AG_CTX_CF1EN_SHIFT    5
+#define TSTORM_ETH_CONN_AG_CTX_CF2EN_MASK     0x1       /* cf2en */
+#define TSTORM_ETH_CONN_AG_CTX_CF2EN_SHIFT    6
+#define TSTORM_ETH_CONN_AG_CTX_CF3EN_MASK     0x1       /* cf3en */
+#define TSTORM_ETH_CONN_AG_CTX_CF3EN_SHIFT    7
+	u8 flags4;
+#define TSTORM_ETH_CONN_AG_CTX_CF4EN_MASK     0x1       /* cf4en */
+#define TSTORM_ETH_CONN_AG_CTX_CF4EN_SHIFT    0
+#define TSTORM_ETH_CONN_AG_CTX_CF5EN_MASK     0x1       /* cf5en */
+#define TSTORM_ETH_CONN_AG_CTX_CF5EN_SHIFT    1
+#define TSTORM_ETH_CONN_AG_CTX_CF6EN_MASK     0x1       /* cf6en */
+#define TSTORM_ETH_CONN_AG_CTX_CF6EN_SHIFT    2
+#define TSTORM_ETH_CONN_AG_CTX_CF7EN_MASK     0x1       /* cf7en */
+#define TSTORM_ETH_CONN_AG_CTX_CF7EN_SHIFT    3
+#define TSTORM_ETH_CONN_AG_CTX_CF8EN_MASK     0x1       /* cf8en */
+#define TSTORM_ETH_CONN_AG_CTX_CF8EN_SHIFT    4
+#define TSTORM_ETH_CONN_AG_CTX_CF9EN_MASK     0x1       /* cf9en */
+#define TSTORM_ETH_CONN_AG_CTX_CF9EN_SHIFT    5
+#define TSTORM_ETH_CONN_AG_CTX_CF10EN_MASK    0x1       /* cf10en */
+#define TSTORM_ETH_CONN_AG_CTX_CF10EN_SHIFT   6
+#define TSTORM_ETH_CONN_AG_CTX_RULE0EN_MASK   0x1       /* rule0en */
+#define TSTORM_ETH_CONN_AG_CTX_RULE0EN_SHIFT  7
+	u8 flags5;
+#define TSTORM_ETH_CONN_AG_CTX_RULE1EN_MASK   0x1       /* rule1en */
+#define TSTORM_ETH_CONN_AG_CTX_RULE1EN_SHIFT  0
+#define TSTORM_ETH_CONN_AG_CTX_RULE2EN_MASK   0x1       /* rule2en */
+#define TSTORM_ETH_CONN_AG_CTX_RULE2EN_SHIFT  1
+#define TSTORM_ETH_CONN_AG_CTX_RULE3EN_MASK   0x1       /* rule3en */
+#define TSTORM_ETH_CONN_AG_CTX_RULE3EN_SHIFT  2
+#define TSTORM_ETH_CONN_AG_CTX_RULE4EN_MASK   0x1       /* rule4en */
+#define TSTORM_ETH_CONN_AG_CTX_RULE4EN_SHIFT  3
+#define TSTORM_ETH_CONN_AG_CTX_RULE5EN_MASK   0x1       /* rule5en */
+#define TSTORM_ETH_CONN_AG_CTX_RULE5EN_SHIFT  4
+#define TSTORM_ETH_CONN_AG_CTX_RX_BD_EN_MASK  0x1       /* rule6en */
+#define TSTORM_ETH_CONN_AG_CTX_RX_BD_EN_SHIFT 5
+#define TSTORM_ETH_CONN_AG_CTX_RULE7EN_MASK   0x1       /* rule7en */
+#define TSTORM_ETH_CONN_AG_CTX_RULE7EN_SHIFT  6
+#define TSTORM_ETH_CONN_AG_CTX_RULE8EN_MASK   0x1       /* rule8en */
+#define TSTORM_ETH_CONN_AG_CTX_RULE8EN_SHIFT  7
+	__le32	reg0 /* reg0 */;
+	__le32	reg1 /* reg1 */;
+	__le32	reg2 /* reg2 */;
+	__le32	reg3 /* reg3 */;
+	__le32	reg4 /* reg4 */;
+	__le32	reg5 /* reg5 */;
+	__le32	reg6 /* reg6 */;
+	__le32	reg7 /* reg7 */;
+	__le32	reg8 /* reg8 */;
+	u8	byte2 /* byte2 */;
+	u8	byte3 /* byte3 */;
+	__le16	rx_bd_cons /* word0 */;
+	u8	byte4 /* byte4 */;
+	u8	byte5 /* byte5 */;
+	__le16	rx_bd_prod /* word1 */;
+	__le16	word2 /* conn_dpi */;
+	__le16	word3 /* word3 */;
+	__le32	reg9 /* reg9 */;
 	__le32	reg10 /* reg10 */;
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
-};
-
-/* The eth storm context for the Tstorm */
-struct tstorm_eth_conn_st_ctx {
-	__le32 reserved[4];
 };
 
-/* The eth storm context for the Mstorm */
-struct mstorm_eth_conn_st_ctx {
-	__le32 reserved[8];
+struct ustorm_eth_conn_ag_ctx {
+	u8	byte0 /* cdu_validation */;
+	u8	byte1 /* state */;
+	u8	flags0;
+#define USTORM_ETH_CONN_AG_CTX_BIT0_MASK                  0x1 /* exist_in_qm0 */
+#define USTORM_ETH_CONN_AG_CTX_BIT0_SHIFT                 0
+#define USTORM_ETH_CONN_AG_CTX_BIT1_MASK                  0x1 /* exist_in_qm1 */
+#define USTORM_ETH_CONN_AG_CTX_BIT1_SHIFT                 1
+#define USTORM_ETH_CONN_AG_CTX_TX_PMD_TERMINATE_CF_MASK   0x3 /* timer0cf */
+#define USTORM_ETH_CONN_AG_CTX_TX_PMD_TERMINATE_CF_SHIFT  2
+#define USTORM_ETH_CONN_AG_CTX_RX_PMD_TERMINATE_CF_MASK   0x3 /* timer1cf */
+#define USTORM_ETH_CONN_AG_CTX_RX_PMD_TERMINATE_CF_SHIFT  4
+#define USTORM_ETH_CONN_AG_CTX_CF2_MASK                   0x3 /* timer2cf */
+#define USTORM_ETH_CONN_AG_CTX_CF2_SHIFT                  6
+	u8 flags1;
+#define USTORM_ETH_CONN_AG_CTX_CF3_MASK                 0x3 /* timer_stop_all */
+#define USTORM_ETH_CONN_AG_CTX_CF3_SHIFT                0
+#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_MASK           0x3 /* cf4 */
+#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_SHIFT          2
+#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_MASK           0x3 /* cf5 */
+#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_SHIFT          4
+#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_MASK   0x3 /* cf6 */
+#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_SHIFT  6
+	u8 flags2;
+#define USTORM_ETH_CONN_AG_CTX_TX_PMD_TERMINATE_CF_EN_MASK  0x1 /* cf0en */
+#define USTORM_ETH_CONN_AG_CTX_TX_PMD_TERMINATE_CF_EN_SHIFT 0
+#define USTORM_ETH_CONN_AG_CTX_RX_PMD_TERMINATE_CF_EN_MASK  0x1 /* cf1en */
+#define USTORM_ETH_CONN_AG_CTX_RX_PMD_TERMINATE_CF_EN_SHIFT 1
+#define USTORM_ETH_CONN_AG_CTX_CF2EN_MASK                   0x1 /* cf2en */
+#define USTORM_ETH_CONN_AG_CTX_CF2EN_SHIFT                  2
+#define USTORM_ETH_CONN_AG_CTX_CF3EN_MASK                   0x1 /* cf3en */
+#define USTORM_ETH_CONN_AG_CTX_CF3EN_SHIFT                  3
+#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_EN_MASK            0x1 /* cf4en */
+#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_EN_SHIFT           4
+#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_EN_MASK            0x1 /* cf5en */
+#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_EN_SHIFT           5
+#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_EN_MASK    0x1 /* cf6en */
+#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_EN_SHIFT   6
+#define USTORM_ETH_CONN_AG_CTX_RULE0EN_MASK                 0x1 /* rule0en */
+#define USTORM_ETH_CONN_AG_CTX_RULE0EN_SHIFT                7
+	u8 flags3;
+#define USTORM_ETH_CONN_AG_CTX_RULE1EN_MASK                 0x1 /* rule1en */
+#define USTORM_ETH_CONN_AG_CTX_RULE1EN_SHIFT                0
+#define USTORM_ETH_CONN_AG_CTX_RULE2EN_MASK                 0x1 /* rule2en */
+#define USTORM_ETH_CONN_AG_CTX_RULE2EN_SHIFT                1
+#define USTORM_ETH_CONN_AG_CTX_RULE3EN_MASK                 0x1 /* rule3en */
+#define USTORM_ETH_CONN_AG_CTX_RULE3EN_SHIFT                2
+#define USTORM_ETH_CONN_AG_CTX_RULE4EN_MASK                 0x1 /* rule4en */
+#define USTORM_ETH_CONN_AG_CTX_RULE4EN_SHIFT                3
+#define USTORM_ETH_CONN_AG_CTX_RULE5EN_MASK                 0x1 /* rule5en */
+#define USTORM_ETH_CONN_AG_CTX_RULE5EN_SHIFT                4
+#define USTORM_ETH_CONN_AG_CTX_RULE6EN_MASK                 0x1 /* rule6en */
+#define USTORM_ETH_CONN_AG_CTX_RULE6EN_SHIFT                5
+#define USTORM_ETH_CONN_AG_CTX_RULE7EN_MASK                 0x1 /* rule7en */
+#define USTORM_ETH_CONN_AG_CTX_RULE7EN_SHIFT                6
+#define USTORM_ETH_CONN_AG_CTX_RULE8EN_MASK                 0x1 /* rule8en */
+#define USTORM_ETH_CONN_AG_CTX_RULE8EN_SHIFT                7
+	u8	byte2 /* byte2 */;
+	u8	byte3 /* byte3 */;
+	__le16	word0 /* conn_dpi */;
+	__le16	tx_bd_cons /* word1 */;
+	__le32	reg0 /* reg0 */;
+	__le32	reg1 /* reg1 */;
+	__le32	reg2 /* reg2 */;
+	__le32	tx_int_coallecing_timeset /* reg3 */;
+	__le16	tx_drv_bd_cons /* word2 */;
+	__le16	rx_drv_cqe_cons /* word3 */;
 };
 
 /* The eth storm context for the Ustorm */
@@ -2577,24 +2755,30 @@ struct ustorm_eth_conn_st_ctx {
 	__le32 reserved[40];
 };
 
+/* The eth storm context for the Mstorm */
+struct mstorm_eth_conn_st_ctx {
+	__le32 reserved[8];
+};
+
 /* eth connection context */
 struct eth_conn_context {
-	struct ystorm_eth_conn_st_ctx	ystorm_st_context;
-	struct regpair			ystorm_st_padding[2] /* padding */;
+	struct tstorm_eth_conn_st_ctx	tstorm_st_context;
+	struct regpair			tstorm_st_padding[2];
 	struct pstorm_eth_conn_st_ctx	pstorm_st_context;
-	struct regpair			pstorm_st_padding[2] /* padding */;
 	struct xstorm_eth_conn_st_ctx	xstorm_st_context;
 	struct xstorm_eth_conn_ag_ctx	xstorm_ag_context;
-	struct tstorm_eth_conn_st_ctx	tstorm_st_context;
-	struct regpair			tstorm_st_padding[2] /* padding */;
-	struct mstorm_eth_conn_st_ctx	mstorm_st_context;
+	struct ystorm_eth_conn_st_ctx	ystorm_st_context;
+	struct ystorm_eth_conn_ag_ctx	ystorm_ag_context;
+	struct tstorm_eth_conn_ag_ctx	tstorm_ag_context;
+	struct ustorm_eth_conn_ag_ctx	ustorm_ag_context;
 	struct ustorm_eth_conn_st_ctx	ustorm_st_context;
+	struct mstorm_eth_conn_st_ctx	mstorm_st_context;
 };
 
 enum eth_filter_action {
 	ETH_FILTER_ACTION_REMOVE,
 	ETH_FILTER_ACTION_ADD,
-	ETH_FILTER_ACTION_REPLACE,
+	ETH_FILTER_ACTION_REMOVE_ALL,
 	MAX_ETH_FILTER_ACTION
 };
 
@@ -2653,6 +2837,32 @@ enum eth_ramrod_cmd_id {
 	MAX_ETH_RAMROD_CMD_ID
 };
 
+enum eth_tx_err {
+	ETH_TX_ERR_DROP /* Drop erronous packet. */,
+	ETH_TX_ERR_ASSERT_MALICIOUS,
+	MAX_ETH_TX_ERR
+};
+
+struct eth_tx_err_vals {
+	__le16 values;
+#define ETH_TX_ERR_VALS_ILLEGAL_VLAN_MODE_MASK            0x1
+#define ETH_TX_ERR_VALS_ILLEGAL_VLAN_MODE_SHIFT           0
+#define ETH_TX_ERR_VALS_PACKET_TOO_SMALL_MASK             0x1
+#define ETH_TX_ERR_VALS_PACKET_TOO_SMALL_SHIFT            1
+#define ETH_TX_ERR_VALS_ANTI_SPOOFING_ERR_MASK            0x1
+#define ETH_TX_ERR_VALS_ANTI_SPOOFING_ERR_SHIFT           2
+#define ETH_TX_ERR_VALS_ILLEGAL_INBAND_TAGS_MASK          0x1
+#define ETH_TX_ERR_VALS_ILLEGAL_INBAND_TAGS_SHIFT         3
+#define ETH_TX_ERR_VALS_VLAN_INSERTION_W_INBAND_TAG_MASK  0x1
+#define ETH_TX_ERR_VALS_VLAN_INSERTION_W_INBAND_TAG_SHIFT 4
+#define ETH_TX_ERR_VALS_MTU_VIOLATION_MASK                0x1
+#define ETH_TX_ERR_VALS_MTU_VIOLATION_SHIFT               5
+#define ETH_TX_ERR_VALS_ILLEGAL_CONTROL_FRAME_MASK        0x1
+#define ETH_TX_ERR_VALS_ILLEGAL_CONTROL_FRAME_SHIFT       6
+#define ETH_TX_ERR_VALS_RESERVED_MASK                     0x1FF
+#define ETH_TX_ERR_VALS_RESERVED_SHIFT                    7
+};
+
 struct eth_vport_rss_config {
 	__le16 capabilities;
 #define ETH_VPORT_RSS_CONFIG_IPV4_CAPABILITY_MASK	0x1
@@ -2669,12 +2879,8 @@ struct eth_vport_rss_config {
 #define ETH_VPORT_RSS_CONFIG_IPV6_UDP_CAPABILITY_SHIFT   5
 #define ETH_VPORT_RSS_CONFIG_EN_5_TUPLE_CAPABILITY_MASK  0x1
 #define ETH_VPORT_RSS_CONFIG_EN_5_TUPLE_CAPABILITY_SHIFT 6
-#define ETH_VPORT_RSS_CONFIG_CALC_4TUP_TCP_FRAG_MASK     0x1
-#define ETH_VPORT_RSS_CONFIG_CALC_4TUP_TCP_FRAG_SHIFT    7
-#define ETH_VPORT_RSS_CONFIG_CALC_4TUP_UDP_FRAG_MASK     0x1
-#define ETH_VPORT_RSS_CONFIG_CALC_4TUP_UDP_FRAG_SHIFT    8
-#define ETH_VPORT_RSS_CONFIG_RESERVED0_MASK	      0x7F
-#define ETH_VPORT_RSS_CONFIG_RESERVED0_SHIFT	     9
+#define ETH_VPORT_RSS_CONFIG_RESERVED0_MASK	      0x1FF
+#define ETH_VPORT_RSS_CONFIG_RESERVED0_SHIFT	     7
 	u8      rss_id;
 	u8      rss_mode;
 	u8      update_rss_key;
@@ -2749,10 +2955,14 @@ struct rx_queue_start_ramrod_data {
 	u8	      pxp_tph_valid_pkt;
 	u8	      pxp_st_hint;
 	__le16	  pxp_st_index;
-	u8	      reserved[4];
-	struct regpair  cqe_pbl_addr;
-	struct regpair  bd_base;
-	struct regpair  sge_base;
+	u8		pmd_mode;
+	u8		notify_en;
+	u8		toggle_val;
+	u8		reserved[7];
+	__le16		reserved1;
+	struct regpair	cqe_pbl_addr;
+	struct regpair	bd_base;
+	struct regpair	reserved2;
 };
 
 struct rx_queue_stop_ramrod_data {
@@ -2764,23 +2974,24 @@ struct rx_queue_stop_ramrod_data {
 };
 
 struct rx_queue_update_ramrod_data {
-	__le16	  rx_queue_id;
-	u8	      complete_cqe_flg;
-	u8	      complete_event_flg;
-	u8	      init_sge_ring_flg;
-	u8	      vport_id;
-	u8	      pxp_tph_valid_sge;
-	u8	      pxp_st_hint;
-	__le16	  pxp_st_index;
-	u8	      reserved[6];
-	struct regpair  sge_base;
+	__le16	rx_queue_id;
+	u8	complete_cqe_flg;
+	u8	complete_event_flg;
+	u8	vport_id;
+	u8	reserved[4];
+	u8	reserved1;
+	u8	reserved2;
+	u8	reserved3;
+	__le16	reserved4;
+	__le16	reserved5;
+	struct regpair reserved6;
 };
 
 struct tx_queue_start_ramrod_data {
 	__le16  sb_id;
 	u8      sb_index;
 	u8      vport_id;
-	u8      tc;
+	u8      reserved0;
 	u8      stats_counter_id;
 	__le16  qm_pq_id;
 	u8      flags;
@@ -2790,18 +3001,25 @@ struct tx_queue_start_ramrod_data {
 #define TX_QUEUE_START_RAMROD_DATA_TEST_MODE_PKT_DUP_SHIFT     1
 #define TX_QUEUE_START_RAMROD_DATA_TEST_MODE_TX_DEST_MASK      0x1
 #define TX_QUEUE_START_RAMROD_DATA_TEST_MODE_TX_DEST_SHIFT     2
-#define TX_QUEUE_START_RAMROD_DATA_RESERVED0_MASK	      0x1F
-#define TX_QUEUE_START_RAMROD_DATA_RESERVED0_SHIFT	     3
-	u8	      pin_context;
-	u8	      pxp_tph_valid_bd;
-	u8	      pxp_tph_valid_pkt;
-	__le16	  pxp_st_index;
-	u8	      pxp_st_hint;
-	u8	      reserved1[3];
-	__le16	  queue_zone_id;
-	__le16	  test_dup_count;
-	__le16	  pbl_size;
-	struct regpair  pbl_base_addr;
+#define TX_QUEUE_START_RAMROD_DATA_PMD_MODE_MASK               0x1
+#define TX_QUEUE_START_RAMROD_DATA_PMD_MODE_SHIFT              3
+#define TX_QUEUE_START_RAMROD_DATA_NOTIFY_EN_MASK              0x1
+#define TX_QUEUE_START_RAMROD_DATA_NOTIFY_EN_SHIFT             4
+#define TX_QUEUE_START_RAMROD_DATA_PIN_CONTEXT_MASK            0x1
+#define TX_QUEUE_START_RAMROD_DATA_PIN_CONTEXT_SHIFT           5
+#define TX_QUEUE_START_RAMROD_DATA_RESERVED1_MASK              0x3
+#define TX_QUEUE_START_RAMROD_DATA_RESERVED1_SHIFT             6
+	u8	pxp_st_hint;
+	u8	pxp_tph_valid_bd;
+	u8	pxp_tph_valid_pkt;
+	__le16	pxp_st_index;
+	__le16	comp_agg_size;
+	__le16	queue_zone_id;
+	__le16	test_dup_count;
+	__le16	pbl_size;
+	__le16	tx_queue_id;
+	struct regpair	pbl_base_addr;
+	struct regpair	bd_cons_address;
 };
 
 struct tx_queue_stop_ramrod_data {
@@ -2822,16 +3040,16 @@ struct vport_start_ramrod_data {
 	struct eth_vport_rx_mode	rx_mode;
 	struct eth_vport_tx_mode	tx_mode;
 	struct eth_vport_tpa_param      tpa_param;
-	__le16			  sge_buff_size;
-	u8			      max_sges_num;
-	u8			      tx_switching_en;
-	u8			      anti_spoofing_en;
-	u8			      default_vlan_en;
-	u8			      handle_ptp_pkts;
-	u8			      silent_vlan_removal_en;
-	__le16			  default_vlan;
-	u8			      untagged;
-	u8			      reserved[7];
+	__le16				default_vlan;
+	u8				tx_switching_en;
+	u8				anti_spoofing_en;
+	u8				default_vlan_en;
+	u8				handle_ptp_pkts;
+	u8				silent_vlan_removal_en;
+	u8				untagged;
+	struct eth_tx_err_vals		tx_err_behav;
+	u8				zero_placement_offset;
+	u8				reserved[7];
 };
 
 struct vport_stop_ramrod_data {
@@ -2840,36 +3058,35 @@ struct vport_stop_ramrod_data {
 };
 
 struct vport_update_ramrod_data_cmn {
-	u8      vport_id;
-	u8      update_rx_active_flg;
-	u8      rx_active_flg;
-	u8      update_tx_active_flg;
-	u8      tx_active_flg;
-	u8      update_rx_mode_flg;
-	u8      update_tx_mode_flg;
-	u8      update_approx_mcast_flg;
-	u8      update_rss_flg;
-	u8      update_inner_vlan_removal_en_flg;
-	u8      inner_vlan_removal_en;
-	u8      update_tpa_param_flg;
-	u8      update_tpa_en_flg;
-	u8      update_sge_param_flg;
-	__le16  sge_buff_size;
-	u8      max_sges_num;
-	u8      update_tx_switching_en_flg;
-	u8      tx_switching_en;
-	u8      update_anti_spoofing_en_flg;
-	u8      anti_spoofing_en;
-	u8      update_handle_ptp_pkts;
-	u8      handle_ptp_pkts;
-	u8      update_default_vlan_en_flg;
-	u8      default_vlan_en;
-	u8      update_default_vlan_flg;
-	__le16  default_vlan;
-	u8      update_accept_any_vlan_flg;
-	u8      accept_any_vlan;
-	u8      silent_vlan_removal_en;
-	u8      reserved;
+	u8	vport_id;
+	u8	update_rx_active_flg;
+	u8	rx_active_flg;
+	u8	update_tx_active_flg;
+	u8	tx_active_flg;
+	u8	update_rx_mode_flg;
+	u8	update_tx_mode_flg;
+	u8	update_approx_mcast_flg;
+	u8	update_rss_flg;
+	u8	update_inner_vlan_removal_en_flg;
+	u8	inner_vlan_removal_en;
+	u8	update_tpa_param_flg;
+	u8	update_tpa_en_flg;
+	u8	update_tx_switching_en_flg;
+	u8	tx_switching_en;
+	u8	update_anti_spoofing_en_flg;
+	u8	anti_spoofing_en;
+	u8	update_handle_ptp_pkts;
+	u8	handle_ptp_pkts;
+	u8	update_default_vlan_en_flg;
+	u8	default_vlan_en;
+	u8	update_default_vlan_flg;
+	__le16	default_vlan;
+	u8	update_accept_any_vlan_flg;
+	u8	accept_any_vlan;
+	u8	silent_vlan_removal_en;
+	u8	update_mtu_flg;
+	__le16	mtu;
+	u8	reserved[2];
 };
 
 struct vport_update_ramrod_mcast {
@@ -2885,436 +3102,6 @@ struct vport_update_ramrod_data {
 	struct eth_vport_rss_config	     rss_config;
 };
 
-struct mstorm_eth_conn_ag_ctx {
-	u8	byte0 /* cdu_validation */;
-	u8	byte1 /* state */;
-	u8	flags0;
-#define MSTORM_ETH_CONN_AG_CTX_EXIST_IN_QM0_MASK  0x1   /* exist_in_qm0 */
-#define MSTORM_ETH_CONN_AG_CTX_EXIST_IN_QM0_SHIFT 0
-#define MSTORM_ETH_CONN_AG_CTX_BIT1_MASK          0x1   /* exist_in_qm1 */
-#define MSTORM_ETH_CONN_AG_CTX_BIT1_SHIFT         1
-#define MSTORM_ETH_CONN_AG_CTX_CF0_MASK           0x3   /* cf0 */
-#define MSTORM_ETH_CONN_AG_CTX_CF0_SHIFT          2
-#define MSTORM_ETH_CONN_AG_CTX_CF1_MASK           0x3   /* cf1 */
-#define MSTORM_ETH_CONN_AG_CTX_CF1_SHIFT          4
-#define MSTORM_ETH_CONN_AG_CTX_CF2_MASK           0x3   /* cf2 */
-#define MSTORM_ETH_CONN_AG_CTX_CF2_SHIFT          6
-	u8 flags1;
-#define MSTORM_ETH_CONN_AG_CTX_CF0EN_MASK         0x1   /* cf0en */
-#define MSTORM_ETH_CONN_AG_CTX_CF0EN_SHIFT        0
-#define MSTORM_ETH_CONN_AG_CTX_CF1EN_MASK         0x1   /* cf1en */
-#define MSTORM_ETH_CONN_AG_CTX_CF1EN_SHIFT        1
-#define MSTORM_ETH_CONN_AG_CTX_CF2EN_MASK         0x1   /* cf2en */
-#define MSTORM_ETH_CONN_AG_CTX_CF2EN_SHIFT        2
-#define MSTORM_ETH_CONN_AG_CTX_RULE0EN_MASK       0x1   /* rule0en */
-#define MSTORM_ETH_CONN_AG_CTX_RULE0EN_SHIFT      3
-#define MSTORM_ETH_CONN_AG_CTX_RULE1EN_MASK       0x1   /* rule1en */
-#define MSTORM_ETH_CONN_AG_CTX_RULE1EN_SHIFT      4
-#define MSTORM_ETH_CONN_AG_CTX_RULE2EN_MASK       0x1   /* rule2en */
-#define MSTORM_ETH_CONN_AG_CTX_RULE2EN_SHIFT      5
-#define MSTORM_ETH_CONN_AG_CTX_RULE3EN_MASK       0x1   /* rule3en */
-#define MSTORM_ETH_CONN_AG_CTX_RULE3EN_SHIFT      6
-#define MSTORM_ETH_CONN_AG_CTX_RULE4EN_MASK       0x1   /* rule4en */
-#define MSTORM_ETH_CONN_AG_CTX_RULE4EN_SHIFT      7
-	__le16	word0 /* word0 */;
-	__le16	word1 /* word1 */;
-	__le32	reg0 /* reg0 */;
-	__le32	reg1 /* reg1 */;
-};
-
-struct tstorm_eth_conn_ag_ctx {
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
-	u8 flags1;
-#define TSTORM_ETH_CONN_AG_CTX_CF1_MASK       0x3       /* timer1cf */
-#define TSTORM_ETH_CONN_AG_CTX_CF1_SHIFT      0
-#define TSTORM_ETH_CONN_AG_CTX_CF2_MASK       0x3       /* timer2cf */
-#define TSTORM_ETH_CONN_AG_CTX_CF2_SHIFT      2
-#define TSTORM_ETH_CONN_AG_CTX_CF3_MASK       0x3       /* timer_stop_all */
-#define TSTORM_ETH_CONN_AG_CTX_CF3_SHIFT      4
-#define TSTORM_ETH_CONN_AG_CTX_CF4_MASK       0x3       /* cf4 */
-#define TSTORM_ETH_CONN_AG_CTX_CF4_SHIFT      6
-	u8 flags2;
-#define TSTORM_ETH_CONN_AG_CTX_CF5_MASK       0x3       /* cf5 */
-#define TSTORM_ETH_CONN_AG_CTX_CF5_SHIFT      0
-#define TSTORM_ETH_CONN_AG_CTX_CF6_MASK       0x3       /* cf6 */
-#define TSTORM_ETH_CONN_AG_CTX_CF6_SHIFT      2
-#define TSTORM_ETH_CONN_AG_CTX_CF7_MASK       0x3       /* cf7 */
-#define TSTORM_ETH_CONN_AG_CTX_CF7_SHIFT      4
-#define TSTORM_ETH_CONN_AG_CTX_CF8_MASK       0x3       /* cf8 */
-#define TSTORM_ETH_CONN_AG_CTX_CF8_SHIFT      6
-	u8 flags3;
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
-	u8 flags4;
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
-	u8 flags5;
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
-};
-
-struct ustorm_eth_conn_ag_ctx {
-	u8	byte0 /* cdu_validation */;
-	u8	byte1 /* state */;
-	u8	flags0;
-#define USTORM_ETH_CONN_AG_CTX_BIT0_MASK                  0x1
-#define USTORM_ETH_CONN_AG_CTX_BIT0_SHIFT                 0
-#define USTORM_ETH_CONN_AG_CTX_BIT1_MASK                  0x1
-#define USTORM_ETH_CONN_AG_CTX_BIT1_SHIFT                 1
-#define USTORM_ETH_CONN_AG_CTX_CF0_MASK                   0x3   /* timer0cf */
-#define USTORM_ETH_CONN_AG_CTX_CF0_SHIFT                  2
-#define USTORM_ETH_CONN_AG_CTX_CF1_MASK                   0x3   /* timer1cf */
-#define USTORM_ETH_CONN_AG_CTX_CF1_SHIFT                  4
-#define USTORM_ETH_CONN_AG_CTX_CF2_MASK                   0x3   /* timer2cf */
-#define USTORM_ETH_CONN_AG_CTX_CF2_SHIFT                  6
-	u8 flags1;
-#define USTORM_ETH_CONN_AG_CTX_CF3_MASK                   0x3
-#define USTORM_ETH_CONN_AG_CTX_CF3_SHIFT                  0
-#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_MASK             0x3   /* cf4 */
-#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_SHIFT            2
-#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_MASK             0x3   /* cf5 */
-#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_SHIFT            4
-#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_MASK     0x3   /* cf6 */
-#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_SHIFT    6
-	u8 flags2;
-#define USTORM_ETH_CONN_AG_CTX_CF0EN_MASK                 0x1   /* cf0en */
-#define USTORM_ETH_CONN_AG_CTX_CF0EN_SHIFT                0
-#define USTORM_ETH_CONN_AG_CTX_CF1EN_MASK                 0x1   /* cf1en */
-#define USTORM_ETH_CONN_AG_CTX_CF1EN_SHIFT                1
-#define USTORM_ETH_CONN_AG_CTX_CF2EN_MASK                 0x1   /* cf2en */
-#define USTORM_ETH_CONN_AG_CTX_CF2EN_SHIFT                2
-#define USTORM_ETH_CONN_AG_CTX_CF3EN_MASK                 0x1   /* cf3en */
-#define USTORM_ETH_CONN_AG_CTX_CF3EN_SHIFT                3
-#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_EN_MASK          0x1   /* cf4en */
-#define USTORM_ETH_CONN_AG_CTX_TX_ARM_CF_EN_SHIFT         4
-#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_EN_MASK          0x1   /* cf5en */
-#define USTORM_ETH_CONN_AG_CTX_RX_ARM_CF_EN_SHIFT         5
-#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_EN_MASK  0x1   /* cf6en */
-#define USTORM_ETH_CONN_AG_CTX_TX_BD_CONS_UPD_CF_EN_SHIFT 6
-#define USTORM_ETH_CONN_AG_CTX_RULE0EN_MASK               0x1   /* rule0en */
-#define USTORM_ETH_CONN_AG_CTX_RULE0EN_SHIFT              7
-	u8 flags3;
-#define USTORM_ETH_CONN_AG_CTX_RULE1EN_MASK               0x1   /* rule1en */
-#define USTORM_ETH_CONN_AG_CTX_RULE1EN_SHIFT              0
-#define USTORM_ETH_CONN_AG_CTX_RULE2EN_MASK               0x1   /* rule2en */
-#define USTORM_ETH_CONN_AG_CTX_RULE2EN_SHIFT              1
-#define USTORM_ETH_CONN_AG_CTX_RULE3EN_MASK               0x1   /* rule3en */
-#define USTORM_ETH_CONN_AG_CTX_RULE3EN_SHIFT              2
-#define USTORM_ETH_CONN_AG_CTX_RULE4EN_MASK               0x1   /* rule4en */
-#define USTORM_ETH_CONN_AG_CTX_RULE4EN_SHIFT              3
-#define USTORM_ETH_CONN_AG_CTX_RULE5EN_MASK               0x1   /* rule5en */
-#define USTORM_ETH_CONN_AG_CTX_RULE5EN_SHIFT              4
-#define USTORM_ETH_CONN_AG_CTX_RULE6EN_MASK               0x1   /* rule6en */
-#define USTORM_ETH_CONN_AG_CTX_RULE6EN_SHIFT              5
-#define USTORM_ETH_CONN_AG_CTX_RULE7EN_MASK               0x1   /* rule7en */
-#define USTORM_ETH_CONN_AG_CTX_RULE7EN_SHIFT              6
-#define USTORM_ETH_CONN_AG_CTX_RULE8EN_MASK               0x1   /* rule8en */
-#define USTORM_ETH_CONN_AG_CTX_RULE8EN_SHIFT              7
-	u8	byte2 /* byte2 */;
-	u8	byte3 /* byte3 */;
-	__le16	word0 /* conn_dpi */;
-	__le16	tx_bd_cons /* word1 */;
-	__le32	reg0 /* reg0 */;
-	__le32	reg1 /* reg1 */;
-	__le32	reg2 /* reg2 */;
-	__le32	reg3 /* reg3 */;
-	__le16	tx_drv_bd_cons /* word2 */;
-	__le16	rx_drv_cqe_cons /* word3 */;
-};
-
-struct xstorm_eth_hw_conn_ag_ctx {
-	u8	reserved0 /* cdu_validation */;
-	u8	eth_state /* state */;
-	u8	flags0;
-#define XSTORM_ETH_HW_CONN_AG_CTX_EXIST_IN_QM0_MASK            0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_EXIST_IN_QM0_SHIFT           0
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED1_MASK               0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED1_SHIFT              1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED2_MASK               0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED2_SHIFT              2
-#define XSTORM_ETH_HW_CONN_AG_CTX_EXIST_IN_QM3_MASK            0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_EXIST_IN_QM3_SHIFT           3
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED3_MASK               0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED3_SHIFT              4
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED4_MASK               0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED4_SHIFT              5
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED5_MASK               0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED5_SHIFT              6
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED6_MASK               0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED6_SHIFT              7
-	u8 flags1;
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED7_MASK               0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED7_SHIFT              0
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED8_MASK               0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED8_SHIFT              1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED9_MASK               0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED9_SHIFT              2
-#define XSTORM_ETH_HW_CONN_AG_CTX_BIT11_MASK                   0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_BIT11_SHIFT                  3
-#define XSTORM_ETH_HW_CONN_AG_CTX_BIT12_MASK                   0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_BIT12_SHIFT                  4
-#define XSTORM_ETH_HW_CONN_AG_CTX_BIT13_MASK                   0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_BIT13_SHIFT                  5
-#define XSTORM_ETH_HW_CONN_AG_CTX_TX_RULE_ACTIVE_MASK          0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_TX_RULE_ACTIVE_SHIFT         6
-#define XSTORM_ETH_HW_CONN_AG_CTX_DQ_CF_ACTIVE_MASK            0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_DQ_CF_ACTIVE_SHIFT           7
-	u8 flags2;
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF0_MASK                     0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF0_SHIFT                    0
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF1_MASK                     0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF1_SHIFT                    2
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF2_MASK                     0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF2_SHIFT                    4
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF3_MASK                     0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF3_SHIFT                    6
-	u8 flags3;
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF4_MASK                     0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF4_SHIFT                    0
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF5_MASK                     0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF5_SHIFT                    2
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF6_MASK                     0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF6_SHIFT                    4
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF7_MASK                     0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF7_SHIFT                    6
-	u8 flags4;
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF8_MASK                     0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF8_SHIFT                    0
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF9_MASK                     0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF9_SHIFT                    2
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF10_MASK                    0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF10_SHIFT                   4
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF11_MASK                    0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF11_SHIFT                   6
-	u8 flags5;
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF12_MASK                    0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF12_SHIFT                   0
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF13_MASK                    0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF13_SHIFT                   2
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF14_MASK                    0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF14_SHIFT                   4
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF15_MASK                    0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF15_SHIFT                   6
-	u8 flags6;
-#define XSTORM_ETH_HW_CONN_AG_CTX_GO_TO_BD_CONS_CF_MASK        0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_GO_TO_BD_CONS_CF_SHIFT       0
-#define XSTORM_ETH_HW_CONN_AG_CTX_MULTI_UNICAST_CF_MASK        0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_MULTI_UNICAST_CF_SHIFT       2
-#define XSTORM_ETH_HW_CONN_AG_CTX_DQ_CF_MASK                   0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_DQ_CF_SHIFT                  4
-#define XSTORM_ETH_HW_CONN_AG_CTX_TERMINATE_CF_MASK            0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_TERMINATE_CF_SHIFT           6
-	u8 flags7;
-#define XSTORM_ETH_HW_CONN_AG_CTX_FLUSH_Q0_MASK                0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_FLUSH_Q0_SHIFT               0
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED10_MASK              0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED10_SHIFT             2
-#define XSTORM_ETH_HW_CONN_AG_CTX_SLOW_PATH_MASK               0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_SLOW_PATH_SHIFT              4
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF0EN_MASK                   0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF0EN_SHIFT                  6
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF1EN_MASK                   0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF1EN_SHIFT                  7
-	u8 flags8;
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF2EN_MASK                   0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF2EN_SHIFT                  0
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF3EN_MASK                   0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF3EN_SHIFT                  1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF4EN_MASK                   0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF4EN_SHIFT                  2
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF5EN_MASK                   0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF5EN_SHIFT                  3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF6EN_MASK                   0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF6EN_SHIFT                  4
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF7EN_MASK                   0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF7EN_SHIFT                  5
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF8EN_MASK                   0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF8EN_SHIFT                  6
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF9EN_MASK                   0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF9EN_SHIFT                  7
-	u8 flags9;
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF10EN_MASK                  0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF10EN_SHIFT                 0
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF11EN_MASK                  0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF11EN_SHIFT                 1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF12EN_MASK                  0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF12EN_SHIFT                 2
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF13EN_MASK                  0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF13EN_SHIFT                 3
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF14EN_MASK                  0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF14EN_SHIFT                 4
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF15EN_MASK                  0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_CF15EN_SHIFT                 5
-#define XSTORM_ETH_HW_CONN_AG_CTX_GO_TO_BD_CONS_CF_EN_MASK     0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_GO_TO_BD_CONS_CF_EN_SHIFT    6
-#define XSTORM_ETH_HW_CONN_AG_CTX_MULTI_UNICAST_CF_EN_MASK     0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_MULTI_UNICAST_CF_EN_SHIFT    7
-	u8 flags10;
-#define XSTORM_ETH_HW_CONN_AG_CTX_DQ_CF_EN_MASK                0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_DQ_CF_EN_SHIFT               0
-#define XSTORM_ETH_HW_CONN_AG_CTX_TERMINATE_CF_EN_MASK         0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_TERMINATE_CF_EN_SHIFT        1
-#define XSTORM_ETH_HW_CONN_AG_CTX_FLUSH_Q0_EN_MASK             0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_FLUSH_Q0_EN_SHIFT            2
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED11_MASK              0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED11_SHIFT             3
-#define XSTORM_ETH_HW_CONN_AG_CTX_SLOW_PATH_EN_MASK            0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_SLOW_PATH_EN_SHIFT           4
-#define XSTORM_ETH_HW_CONN_AG_CTX_TPH_ENABLE_EN_RESERVED_MASK  0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_TPH_ENABLE_EN_RESERVED_SHIFT 5
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED12_MASK              0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED12_SHIFT             6
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED13_MASK              0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED13_SHIFT             7
-	u8 flags11;
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED14_MASK              0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED14_SHIFT             0
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED15_MASK              0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RESERVED15_SHIFT             1
-#define XSTORM_ETH_HW_CONN_AG_CTX_TX_DEC_RULE_EN_MASK          0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_TX_DEC_RULE_EN_SHIFT         2
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE5EN_MASK                 0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE5EN_SHIFT                3
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE6EN_MASK                 0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE6EN_SHIFT                4
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE7EN_MASK                 0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE7EN_SHIFT                5
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED1_MASK            0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED1_SHIFT           6
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE9EN_MASK                 0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE9EN_SHIFT                7
-	u8 flags12;
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE10EN_MASK                0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE10EN_SHIFT               0
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE11EN_MASK                0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE11EN_SHIFT               1
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED2_MASK            0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED2_SHIFT           2
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED3_MASK            0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED3_SHIFT           3
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE14EN_MASK                0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE14EN_SHIFT               4
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE15EN_MASK                0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE15EN_SHIFT               5
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE16EN_MASK                0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE16EN_SHIFT               6
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE17EN_MASK                0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE17EN_SHIFT               7
-	u8 flags13;
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE18EN_MASK                0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE18EN_SHIFT               0
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE19EN_MASK                0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_RULE19EN_SHIFT               1
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED4_MASK            0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED4_SHIFT           2
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED5_MASK            0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED5_SHIFT           3
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED6_MASK            0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED6_SHIFT           4
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED7_MASK            0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED7_SHIFT           5
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED8_MASK            0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED8_SHIFT           6
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED9_MASK            0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_A0_RESERVED9_SHIFT           7
-	u8 flags14;
-#define XSTORM_ETH_HW_CONN_AG_CTX_EDPM_USE_EXT_HDR_MASK        0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_EDPM_USE_EXT_HDR_SHIFT       0
-#define XSTORM_ETH_HW_CONN_AG_CTX_EDPM_SEND_RAW_L3L4_MASK      0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_EDPM_SEND_RAW_L3L4_SHIFT     1
-#define XSTORM_ETH_HW_CONN_AG_CTX_EDPM_INBAND_PROP_HDR_MASK    0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_EDPM_INBAND_PROP_HDR_SHIFT   2
-#define XSTORM_ETH_HW_CONN_AG_CTX_EDPM_SEND_EXT_TUNNEL_MASK    0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_EDPM_SEND_EXT_TUNNEL_SHIFT   3
-#define XSTORM_ETH_HW_CONN_AG_CTX_L2_EDPM_ENABLE_MASK          0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_L2_EDPM_ENABLE_SHIFT         4
-#define XSTORM_ETH_HW_CONN_AG_CTX_ROCE_EDPM_ENABLE_MASK        0x1
-#define XSTORM_ETH_HW_CONN_AG_CTX_ROCE_EDPM_ENABLE_SHIFT       5
-#define XSTORM_ETH_HW_CONN_AG_CTX_TPH_ENABLE_MASK              0x3
-#define XSTORM_ETH_HW_CONN_AG_CTX_TPH_ENABLE_SHIFT             6
-	u8	edpm_event_id /* byte2 */;
-	__le16	physical_q0 /* physical_q0 */;
-	__le16	word1 /* physical_q1 */;
-	__le16	edpm_num_bds /* physical_q2 */;
-	__le16	tx_bd_cons /* word3 */;
-	__le16	tx_bd_prod /* word4 */;
-	__le16	go_to_bd_cons /* word5 */;
-	__le16	conn_dpi /* conn_dpi */;
-};
-
 #define VF_MAX_STATIC 192       /* In case of K2 */
 
 #define MCP_GLOB_PATH_MAX       2
@@ -3818,6 +3605,10 @@ struct public_port {
 	struct dcbx_local_params		local_admin_dcbx_mib;
 	struct dcbx_mib				remote_dcbx_mib;
 	struct dcbx_mib				operational_dcbx_mib;
+
+	u32					fc_npiv_nvram_tbl_addr;
+	u32					fc_npiv_nvram_tbl_size;
+	u32					transceiver_data;
 };
 
 /**************************************/
@@ -3830,7 +3621,11 @@ struct public_func {
 	u32	iscsi_boot_signature;
 	u32	iscsi_boot_block_offset;
 
-	u32	reserved[8];
+	u32	mtu_size;
+	u32	c2s_pcp_map_lower;
+	u32	c2s_pcp_map_upper;
+	u32	c2s_pcp_map_default;
+	u32	reserved[4];
 
 	u32	config;
 
@@ -3894,10 +3689,10 @@ struct public_func {
 #define DRV_ID_MCP_HSI_VER_SHIFT        16
 #define DRV_ID_MCP_HSI_VER_CURRENT	BIT(DRV_ID_MCP_HSI_VER_SHIFT)
 
-#define DRV_ID_DRV_TYPE_MASK            0xff000000
+#define DRV_ID_DRV_TYPE_MASK            0x7f000000
 #define DRV_ID_DRV_TYPE_SHIFT           24
 #define DRV_ID_DRV_TYPE_UNKNOWN         (0 << DRV_ID_DRV_TYPE_SHIFT)
-#define DRV_ID_DRV_TYPE_LINUX		BIT(DRV_ID_DRV_TYPE_SHIFT)
+#define DRV_ID_DRV_TYPE_LINUX           (1 << DRV_ID_DRV_TYPE_SHIFT)
 #define DRV_ID_DRV_TYPE_WINDOWS         (2 << DRV_ID_DRV_TYPE_SHIFT)
 #define DRV_ID_DRV_TYPE_DIAG            (3 << DRV_ID_DRV_TYPE_SHIFT)
 #define DRV_ID_DRV_TYPE_PREBOOT         (4 << DRV_ID_DRV_TYPE_SHIFT)
@@ -3905,6 +3700,10 @@ struct public_func {
 #define DRV_ID_DRV_TYPE_VMWARE          (6 << DRV_ID_DRV_TYPE_SHIFT)
 #define DRV_ID_DRV_TYPE_FREEBSD         (7 << DRV_ID_DRV_TYPE_SHIFT)
 #define DRV_ID_DRV_TYPE_AIX             (8 << DRV_ID_DRV_TYPE_SHIFT)
+
+#define DRV_ID_DRV_INIT_HW_MASK         0x80000000
+#define DRV_ID_DRV_INIT_HW_SHIFT        31
+#define DRV_ID_DRV_INIT_HW_FLAG         BIT(DRV_ID_DRV_INIT_HW_SHIFT)
 };
 
 /**************************************/
@@ -3964,6 +3763,7 @@ struct public_drv_mb {
 #define DRV_MSG_CODE_MASK                       0xffff0000
 #define DRV_MSG_CODE_LOAD_REQ                   0x10000000
 #define DRV_MSG_CODE_LOAD_DONE                  0x11000000
+#define DRV_MSG_CODE_INIT_HW                    0x12000000
 #define DRV_MSG_CODE_UNLOAD_REQ                 0x20000000
 #define DRV_MSG_CODE_UNLOAD_DONE                0x21000000
 #define DRV_MSG_CODE_INIT_PHY                   0x22000000
@@ -4100,6 +3900,7 @@ struct public_drv_mb {
 #define FW_MSG_CODE_SET_SECURE_MODE_ERROR       0x00130000
 #define FW_MSG_CODE_SET_SECURE_MODE_OK          0x00140000
 #define FW_MSG_MODE_PHY_PRIVILEGE_ERROR         0x00150000
+#define FW_MSG_CODE_OK                          0x00160000
 
 #define FW_MSG_SEQ_NUMBER_MASK                  0x0000ffff
 
@@ -4212,7 +4013,7 @@ struct nvm_cfg1_glob {
 #define NVM_CFG1_GLOB_MF_MODE_MASK                              0x00000FF0
 #define NVM_CFG1_GLOB_MF_MODE_OFFSET                            4
 #define NVM_CFG1_GLOB_MF_MODE_MF_ALLOWED                        0x0
-#define NVM_CFG1_GLOB_MF_MODE_FORCED_SF                         0x1
+#define NVM_CFG1_GLOB_MF_MODE_DEFAULT                           0x1
 #define NVM_CFG1_GLOB_MF_MODE_SPIO4                             0x2
 #define NVM_CFG1_GLOB_MF_MODE_NPAR1_0                           0x3
 #define NVM_CFG1_GLOB_MF_MODE_NPAR1_5                           0x4
@@ -4643,8 +4444,12 @@ struct nvm_cfg1_glob {
 #define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO29                  0x1E
 #define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO30                  0x1F
 #define NVM_CFG1_GLOB_I2C_MUX_SEL_GPIO__GPIO31                  0x20
-
-	u32 reserved[46];					/* 0x88 */
+	u32	device_capabilities;                            /* 0x88 */
+#define NVM_CFG1_GLOB_DEVICE_CAPABILITIES_ETHERNET              0x1
+	u32	power_dissipated;                               /* 0x8C */
+	u32 power_consumed;                                     /* 0x90 */
+	u32	efi_version;                                    /* 0x94 */
+	u32	reserved[42];                                   /* 0x98 */
 };
 
 struct nvm_cfg1_path {
@@ -4652,26 +4457,8 @@ struct nvm_cfg1_path {
 };
 
 struct nvm_cfg1_port {
-	u32 power_dissipated;					/* 0x0 */
-#define NVM_CFG1_PORT_POWER_DIS_D0_MASK                         0x000000FF
-#define NVM_CFG1_PORT_POWER_DIS_D0_OFFSET                       0
-#define NVM_CFG1_PORT_POWER_DIS_D1_MASK                         0x0000FF00
-#define NVM_CFG1_PORT_POWER_DIS_D1_OFFSET                       8
-#define NVM_CFG1_PORT_POWER_DIS_D2_MASK                         0x00FF0000
-#define NVM_CFG1_PORT_POWER_DIS_D2_OFFSET                       16
-#define NVM_CFG1_PORT_POWER_DIS_D3_MASK                         0xFF000000
-#define NVM_CFG1_PORT_POWER_DIS_D3_OFFSET                       24
-
-	u32 power_consumed;					/* 0x4 */
-#define NVM_CFG1_PORT_POWER_CONS_D0_MASK                        0x000000FF
-#define NVM_CFG1_PORT_POWER_CONS_D0_OFFSET                      0
-#define NVM_CFG1_PORT_POWER_CONS_D1_MASK                        0x0000FF00
-#define NVM_CFG1_PORT_POWER_CONS_D1_OFFSET                      8
-#define NVM_CFG1_PORT_POWER_CONS_D2_MASK                        0x00FF0000
-#define NVM_CFG1_PORT_POWER_CONS_D2_OFFSET                      16
-#define NVM_CFG1_PORT_POWER_CONS_D3_MASK                        0xFF000000
-#define NVM_CFG1_PORT_POWER_CONS_D3_OFFSET                      24
-
+	u32	reserved__m_relocated_to_option_123;           /* 0x0 */
+	u32	reserved__m_relocated_to_option_124;           /* 0x4 */
 	u32 generic_cont0;					/* 0x8 */
 #define NVM_CFG1_PORT_LED_MODE_MASK                             0x000000FF
 #define NVM_CFG1_PORT_LED_MODE_OFFSET                           0
@@ -4699,7 +4486,9 @@ struct nvm_cfg1_port {
 #define NVM_CFG1_PORT_DCBX_MODE_IEEE                            0x1
 #define NVM_CFG1_PORT_DCBX_MODE_CEE                             0x2
 #define NVM_CFG1_PORT_DCBX_MODE_DYNAMIC                         0x3
-
+#define NVM_CFG1_PORT_DEFAULT_ENABLED_PROTOCOLS_MASK            0x00F00000
+#define NVM_CFG1_PORT_DEFAULT_ENABLED_PROTOCOLS_OFFSET          20
+#define NVM_CFG1_PORT_DEFAULT_ENABLED_PROTOCOLS_ETHERNET        0x1
 	u32	pcie_cfg;					/* 0xC */
 #define NVM_CFG1_PORT_RESERVED15_MASK                           0x00000007
 #define NVM_CFG1_PORT_RESERVED15_OFFSET                         0
@@ -4784,10 +4573,11 @@ struct nvm_cfg1_port {
 #define NVM_CFG1_PORT_SERDES_NET_INTERFACE_SFI                  0x9
 #define NVM_CFG1_PORT_SERDES_NET_INTERFACE_1000X                0xB
 #define NVM_CFG1_PORT_SERDES_NET_INTERFACE_SGMII                0xC
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_XLAUI                0xD
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_CAUI                 0xE
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_XLPPI                0xF
-#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_CPPI                 0x10
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_XLAUI                0x11
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_XLPPI                0x12
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_CAUI                 0x21
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_CPPI                 0x22
+#define NVM_CFG1_PORT_SERDES_NET_INTERFACE_25GAUI               0x31
 #define NVM_CFG1_PORT_AN_MODE_MASK                              0xFF000000
 #define NVM_CFG1_PORT_AN_MODE_OFFSET                            24
 #define NVM_CFG1_PORT_AN_MODE_NONE                              0x0
@@ -4801,9 +4591,6 @@ struct nvm_cfg1_port {
 	u32 mgmt_traffic;					/* 0x20 */
 #define NVM_CFG1_PORT_RESERVED61_MASK                           0x0000000F
 #define NVM_CFG1_PORT_RESERVED61_OFFSET                         0
-#define NVM_CFG1_PORT_RESERVED61_DISABLED                       0x0
-#define NVM_CFG1_PORT_RESERVED61_NCSI_OVER_RMII                 0x1
-#define NVM_CFG1_PORT_RESERVED61_NCSI_OVER_SMBUS                0x2
 
 	u32 ext_phy;						/* 0x24 */
 #define NVM_CFG1_PORT_EXTERNAL_PHY_TYPE_MASK                    0x000000FF
@@ -4814,16 +4601,12 @@ struct nvm_cfg1_port {
 #define NVM_CFG1_PORT_EXTERNAL_PHY_ADDRESS_OFFSET               8
 
 	u32 mba_cfg1;						/* 0x28 */
-#define NVM_CFG1_PORT_MBA_MASK                                  0x00000001
-#define NVM_CFG1_PORT_MBA_OFFSET                                0
-#define NVM_CFG1_PORT_MBA_DISABLED                              0x0
-#define NVM_CFG1_PORT_MBA_ENABLED                               0x1
-#define NVM_CFG1_PORT_MBA_BOOT_TYPE_MASK                        0x00000006
-#define NVM_CFG1_PORT_MBA_BOOT_TYPE_OFFSET                      1
-#define NVM_CFG1_PORT_MBA_BOOT_TYPE_AUTO                        0x0
-#define NVM_CFG1_PORT_MBA_BOOT_TYPE_BBS                         0x1
-#define NVM_CFG1_PORT_MBA_BOOT_TYPE_INT18H                      0x2
-#define NVM_CFG1_PORT_MBA_BOOT_TYPE_INT19H                      0x3
+#define NVM_CFG1_PORT_PREBOOT_OPROM_MASK                        0x00000001
+#define NVM_CFG1_PORT_PREBOOT_OPROM_OFFSET                      0
+#define NVM_CFG1_PORT_PREBOOT_OPROM_DISABLED                    0x0
+#define NVM_CFG1_PORT_PREBOOT_OPROM_ENABLED                     0x1
+#define NVM_CFG1_PORT_RESERVED__M_MBA_BOOT_TYPE_MASK            0x00000006
+#define NVM_CFG1_PORT_RESERVED__M_MBA_BOOT_TYPE_OFFSET          1
 #define NVM_CFG1_PORT_MBA_DELAY_TIME_MASK                       0x00000078
 #define NVM_CFG1_PORT_MBA_DELAY_TIME_OFFSET                     3
 #define NVM_CFG1_PORT_MBA_SETUP_HOT_KEY_MASK                    0x00000080
@@ -4836,61 +4619,30 @@ struct nvm_cfg1_port {
 #define NVM_CFG1_PORT_MBA_HIDE_SETUP_PROMPT_ENABLED             0x1
 #define NVM_CFG1_PORT_RESERVED5_MASK                            0x0001FE00
 #define NVM_CFG1_PORT_RESERVED5_OFFSET                          9
-#define NVM_CFG1_PORT_RESERVED5_DISABLED                        0x0
-#define NVM_CFG1_PORT_RESERVED5_2K                              0x1
-#define NVM_CFG1_PORT_RESERVED5_4K                              0x2
-#define NVM_CFG1_PORT_RESERVED5_8K                              0x3
-#define NVM_CFG1_PORT_RESERVED5_16K                             0x4
-#define NVM_CFG1_PORT_RESERVED5_32K                             0x5
-#define NVM_CFG1_PORT_RESERVED5_64K                             0x6
-#define NVM_CFG1_PORT_RESERVED5_128K                            0x7
-#define NVM_CFG1_PORT_RESERVED5_256K                            0x8
-#define NVM_CFG1_PORT_RESERVED5_512K                            0x9
-#define NVM_CFG1_PORT_RESERVED5_1M                              0xA
-#define NVM_CFG1_PORT_RESERVED5_2M                              0xB
-#define NVM_CFG1_PORT_RESERVED5_4M                              0xC
-#define NVM_CFG1_PORT_RESERVED5_8M                              0xD
-#define NVM_CFG1_PORT_RESERVED5_16M                             0xE
-#define NVM_CFG1_PORT_RESERVED5_32M                             0xF
-#define NVM_CFG1_PORT_MBA_LINK_SPEED_MASK                       0x001E0000
-#define NVM_CFG1_PORT_MBA_LINK_SPEED_OFFSET                     17
-#define NVM_CFG1_PORT_MBA_LINK_SPEED_AUTONEG                    0x0
-#define NVM_CFG1_PORT_MBA_LINK_SPEED_1G                         0x1
-#define NVM_CFG1_PORT_MBA_LINK_SPEED_10G                        0x2
-#define NVM_CFG1_PORT_MBA_LINK_SPEED_25G                        0x4
-#define NVM_CFG1_PORT_MBA_LINK_SPEED_40G                        0x5
-#define NVM_CFG1_PORT_MBA_LINK_SPEED_50G                        0x6
-#define NVM_CFG1_PORT_MBA_LINK_SPEED_100G                       0x7
-#define NVM_CFG1_PORT_MBA_BOOT_RETRY_COUNT_MASK                 0x00E00000
-#define NVM_CFG1_PORT_MBA_BOOT_RETRY_COUNT_OFFSET               21
+#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_MASK                   0x001E0000
+#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_OFFSET                 17
+#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_AUTONEG                0x0
+#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_1G                     0x1
+#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_10G                    0x2
+#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_25G                    0x4
+#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_40G                    0x5
+#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_50G                    0x6
+#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_100G                   0x7
+#define NVM_CFG1_PORT_PREBOOT_LINK_SPEED_SMARTLINQ              0x8
+#define NVM_CFG1_PORT_RESERVED__M_MBA_BOOT_RETRY_COUNT_MASK     0x00E00000
+#define NVM_CFG1_PORT_RESERVED__M_MBA_BOOT_RETRY_COUNT_OFFSET   21
 
 	u32	mba_cfg2;					/* 0x2C */
-#define NVM_CFG1_PORT_MBA_VLAN_VALUE_MASK                       0x0000FFFF
-#define NVM_CFG1_PORT_MBA_VLAN_VALUE_OFFSET                     0
-#define NVM_CFG1_PORT_MBA_VLAN_MASK                             0x00010000
-#define NVM_CFG1_PORT_MBA_VLAN_OFFSET                           16
+#define NVM_CFG1_PORT_RESERVED65_MASK                           0x0000FFFF
+#define NVM_CFG1_PORT_RESERVED65_OFFSET                         0
+#define NVM_CFG1_PORT_RESERVED66_MASK                           0x00010000
+#define NVM_CFG1_PORT_RESERVED66_OFFSET                         16
 
 	u32	vf_cfg;						/* 0x30 */
 #define NVM_CFG1_PORT_RESERVED8_MASK                            0x0000FFFF
 #define NVM_CFG1_PORT_RESERVED8_OFFSET                          0
 #define NVM_CFG1_PORT_RESERVED6_MASK                            0x000F0000
 #define NVM_CFG1_PORT_RESERVED6_OFFSET                          16
-#define NVM_CFG1_PORT_RESERVED6_DISABLED                        0x0
-#define NVM_CFG1_PORT_RESERVED6_4K                              0x1
-#define NVM_CFG1_PORT_RESERVED6_8K                              0x2
-#define NVM_CFG1_PORT_RESERVED6_16K                             0x3
-#define NVM_CFG1_PORT_RESERVED6_32K                             0x4
-#define NVM_CFG1_PORT_RESERVED6_64K                             0x5
-#define NVM_CFG1_PORT_RESERVED6_128K                            0x6
-#define NVM_CFG1_PORT_RESERVED6_256K                            0x7
-#define NVM_CFG1_PORT_RESERVED6_512K                            0x8
-#define NVM_CFG1_PORT_RESERVED6_1M                              0x9
-#define NVM_CFG1_PORT_RESERVED6_2M                              0xA
-#define NVM_CFG1_PORT_RESERVED6_4M                              0xB
-#define NVM_CFG1_PORT_RESERVED6_8M                              0xC
-#define NVM_CFG1_PORT_RESERVED6_16M                             0xD
-#define NVM_CFG1_PORT_RESERVED6_32M                             0xE
-#define NVM_CFG1_PORT_RESERVED6_64M                             0xF
 
 	struct nvm_cfg_mac_address	lldp_mac_address;	/* 0x34 */
 
@@ -4973,18 +4725,16 @@ struct nvm_cfg1_func {
 	u32				device_id;		/* 0x10 */
 #define NVM_CFG1_FUNC_MF_VENDOR_DEVICE_ID_MASK                  0x0000FFFF
 #define NVM_CFG1_FUNC_MF_VENDOR_DEVICE_ID_OFFSET                0
-#define NVM_CFG1_FUNC_VENDOR_DEVICE_ID_MASK                     0xFFFF0000
-#define NVM_CFG1_FUNC_VENDOR_DEVICE_ID_OFFSET                   16
+#define NVM_CFG1_FUNC_RESERVED77_MASK                           0xFFFF0000
+#define NVM_CFG1_FUNC_RESERVED77_OFFSET                         16
 
 	u32				cmn_cfg;		/* 0x14 */
-#define NVM_CFG1_FUNC_MBA_BOOT_PROTOCOL_MASK                    0x00000007
-#define NVM_CFG1_FUNC_MBA_BOOT_PROTOCOL_OFFSET                  0
-#define NVM_CFG1_FUNC_MBA_BOOT_PROTOCOL_PXE                     0x0
-#define NVM_CFG1_FUNC_MBA_BOOT_PROTOCOL_RPL                     0x1
-#define NVM_CFG1_FUNC_MBA_BOOT_PROTOCOL_BOOTP                   0x2
-#define NVM_CFG1_FUNC_MBA_BOOT_PROTOCOL_ISCSI_BOOT              0x3
-#define NVM_CFG1_FUNC_MBA_BOOT_PROTOCOL_FCOE_BOOT               0x4
-#define NVM_CFG1_FUNC_MBA_BOOT_PROTOCOL_NONE                    0x7
+#define NVM_CFG1_FUNC_PREBOOT_BOOT_PROTOCOL_MASK                0x00000007
+#define NVM_CFG1_FUNC_PREBOOT_BOOT_PROTOCOL_OFFSET              0
+#define NVM_CFG1_FUNC_PREBOOT_BOOT_PROTOCOL_PXE                 0x0
+#define NVM_CFG1_FUNC_PREBOOT_BOOT_PROTOCOL_ISCSI_BOOT          0x3
+#define NVM_CFG1_FUNC_PREBOOT_BOOT_PROTOCOL_FCOE_BOOT           0x4
+#define NVM_CFG1_FUNC_PREBOOT_BOOT_PROTOCOL_NONE                0x7
 #define NVM_CFG1_FUNC_VF_PCI_DEVICE_ID_MASK                     0x0007FFF8
 #define NVM_CFG1_FUNC_VF_PCI_DEVICE_ID_OFFSET                   3
 #define NVM_CFG1_FUNC_PERSONALITY_MASK                          0x00780000
@@ -5029,8 +4779,8 @@ struct nvm_cfg1_func {
 	struct nvm_cfg_mac_address	fcoe_node_wwn_mac_addr;	/* 0x1C */
 
 	struct nvm_cfg_mac_address	fcoe_port_wwn_mac_addr;	/* 0x24 */
-
-	u32				reserved[9];		/* 0x2C */
+	u32				preboot_generic_cfg;    /* 0x2C */
+	u32				reserved[8];            /* 0x30 */
 };
 
 struct nvm_cfg1 {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
index 0b21a55..5d91e16 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
@@ -513,17 +513,14 @@ static int qed_pf_rl_rt_init(struct qed_hwfn *p_hwfn,
  * Return -1 on error.
  */
 static int qed_vp_wfq_rt_init(struct qed_hwfn *p_hwfn,
-			      u8 start_vport,
 			      u8 num_vports,
 			      struct init_qm_vport_params *vport_params)
 {
-	u8 tc, i, vport_id;
+	u8	tc, i;
 	u32 inc_val;
 
 	/* go over all PF VPORTs */
-	for (i = 0, vport_id = start_vport; i < num_vports; i++, vport_id++) {
-		u32 temp = QM_REG_WFQVPUPPERBOUND_RT_OFFSET;
-		u16 *pq_ids = &vport_params[i].first_tx_pq_id[0];
+	for (i = 0; i < num_vports; i++) {
 
 		if (!vport_params[i].vport_wfq)
 			continue;
@@ -539,20 +536,16 @@ static int qed_vp_wfq_rt_init(struct qed_hwfn *p_hwfn,
 		 * different TCs
 		 */
 		for (tc = 0; tc < NUM_OF_TCS; tc++) {
-			u16 vport_pq_id = pq_ids[tc];
+			u16 vport_pq_id = vport_params[i].first_tx_pq_id[tc];
 
 			if (vport_pq_id != QM_INVALID_PQ_ID) {
 				STORE_RT_REG(p_hwfn,
-					     QM_REG_WFQVPWEIGHT_RT_OFFSET +
-					     vport_pq_id, inc_val);
-				STORE_RT_REG(p_hwfn, temp + vport_pq_id,
-					     QM_WFQ_UPPER_BOUND |
-					     QM_WFQ_CRD_REG_SIGN_BIT);
-				STORE_RT_REG(p_hwfn,
 					     QM_REG_WFQVPCRD_RT_OFFSET +
 					     vport_pq_id,
-					     QM_WFQ_INIT_CRD(inc_val) |
 					     QM_WFQ_CRD_REG_SIGN_BIT);
+				STORE_RT_REG(p_hwfn,
+					     QM_REG_WFQVPWEIGHT_RT_OFFSET +
+					     vport_pq_id, inc_val);
 			}
 		}
 	}
@@ -709,8 +702,7 @@ int qed_qm_pf_rt_init(struct qed_hwfn *p_hwfn,
 	if (qed_pf_rl_rt_init(p_hwfn, p_params->pf_id, p_params->pf_rl))
 		return -1;
 
-	if (qed_vp_wfq_rt_init(p_hwfn, p_params->start_vport,
-			       p_params->num_vports, vport_params))
+	if (qed_vp_wfq_rt_init(p_hwfn, p_params->num_vports, vport_params))
 		return -1;
 
 	if (qed_vport_rl_rt_init(p_hwfn, p_params->start_vport,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_init_ops.c b/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
index 796f139..b668e83 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
@@ -55,63 +55,99 @@ void qed_init_clear_rt_data(struct qed_hwfn *p_hwfn)
 	int i;
 
 	for (i = 0; i < RUNTIME_ARRAY_SIZE; i++)
-		p_hwfn->rt_data[i].b_valid = false;
+		p_hwfn->rt_data.b_valid[i] = false;
 }
 
 void qed_init_store_rt_reg(struct qed_hwfn *p_hwfn,
 			   u32 rt_offset,
 			   u32 val)
 {
-	p_hwfn->rt_data[rt_offset].init_val = val;
-	p_hwfn->rt_data[rt_offset].b_valid = true;
+	p_hwfn->rt_data.init_val[rt_offset] = val;
+	p_hwfn->rt_data.b_valid[rt_offset] = true;
 }
 
 void qed_init_store_rt_agg(struct qed_hwfn *p_hwfn,
 			   u32 rt_offset,
-			   u32 *val,
+			   u32			*p_val,
 			   size_t size)
 {
 	size_t i;
 
 	for (i = 0; i < size / sizeof(u32); i++) {
-		p_hwfn->rt_data[rt_offset + i].init_val = val[i];
-		p_hwfn->rt_data[rt_offset + i].b_valid = true;
+		p_hwfn->rt_data.init_val[rt_offset + i] = p_val[i];
+		p_hwfn->rt_data.b_valid[rt_offset + i]	= true;
 	}
 }
 
-static void qed_init_rt(struct qed_hwfn *p_hwfn,
-			struct qed_ptt *p_ptt,
-			u32 addr,
-			u32 rt_offset,
-			u32 size)
+static int qed_init_rt(struct qed_hwfn	*p_hwfn,
+		       struct qed_ptt *p_ptt,
+		       u32 addr,
+		       u16 rt_offset,
+		       u16 size,
+		       bool b_must_dmae)
 {
-	struct qed_rt_data *rt_data = p_hwfn->rt_data + rt_offset;
-	u32 i;
+	u32 *p_init_val = &p_hwfn->rt_data.init_val[rt_offset];
+	bool *p_valid = &p_hwfn->rt_data.b_valid[rt_offset];
+	u16 i, segment;
+	int rc = 0;
 
+	/* Since not all RT entries are initialized, go over the RT and
+	 * for each segment of initialized values use DMA.
+	 */
 	for (i = 0; i < size; i++) {
-		if (!rt_data[i].b_valid)
+		if (!p_valid[i])
+			continue;
+
+		/* In case there isn't any wide-bus configuration here,
+		 * simply write the data instead of using dmae.
+		 */
+		if (!b_must_dmae) {
+			qed_wr(p_hwfn, p_ptt, addr + (i << 2),
+			       p_init_val[i]);
 			continue;
-		qed_wr(p_hwfn, p_ptt, addr + (i << 2), rt_data[i].init_val);
+		}
+
+		/* Start of a new segment */
+		for (segment = 1; i + segment < size; segment++)
+			if (!p_valid[i + segment])
+				break;
+
+		rc = qed_dmae_host2grc(p_hwfn, p_ptt,
+				       (uintptr_t)(p_init_val + i),
+				       addr + (i << 2), segment, 0);
+		if (rc != 0)
+			return rc;
+
+		/* Jump over the entire segment, including invalid entry */
+		i += segment;
 	}
+
+	return rc;
 }
 
 int qed_init_alloc(struct qed_hwfn *p_hwfn)
 {
-	struct qed_rt_data *rt_data;
+	struct qed_rt_data *rt_data = &p_hwfn->rt_data;
 
-	rt_data = kzalloc(sizeof(*rt_data) * RUNTIME_ARRAY_SIZE, GFP_ATOMIC);
-	if (!rt_data)
+	rt_data->b_valid = kzalloc(sizeof(bool) * RUNTIME_ARRAY_SIZE,
+				   GFP_KERNEL);
+	if (!rt_data->b_valid)
 		return -ENOMEM;
 
-	p_hwfn->rt_data = rt_data;
+	rt_data->init_val = kzalloc(sizeof(u32) * RUNTIME_ARRAY_SIZE,
+				    GFP_KERNEL);
+	if (!rt_data->init_val) {
+		kfree(rt_data->b_valid);
+		return -ENOMEM;
+	}
 
 	return 0;
 }
 
 void qed_init_free(struct qed_hwfn *p_hwfn)
 {
-	kfree(p_hwfn->rt_data);
-	p_hwfn->rt_data = NULL;
+	kfree(p_hwfn->rt_data.init_val);
+	kfree(p_hwfn->rt_data.b_valid);
 }
 
 static int qed_init_array_dmae(struct qed_hwfn *p_hwfn,
@@ -289,7 +325,8 @@ static int qed_init_cmd_wr(struct qed_hwfn *p_hwfn,
 	case INIT_SRC_RUNTIME:
 		qed_init_rt(p_hwfn, p_ptt, addr,
 			    le16_to_cpu(arg->runtime.offset),
-			    le16_to_cpu(arg->runtime.size));
+			    le16_to_cpu(arg->runtime.size),
+			    b_must_dmae);
 		break;
 	}
 
@@ -316,50 +353,50 @@ static void qed_init_cmd_rd(struct qed_hwfn *p_hwfn,
 			    struct qed_ptt *p_ptt,
 			    struct init_read_op *cmd)
 {
-	u32 data = le32_to_cpu(cmd->op_data);
-	u32 addr = GET_FIELD(data, INIT_READ_OP_ADDRESS) << 2;
+	bool (*comp_check)(u32 val, u32 expected_val);
+	u32 delay = QED_INIT_POLL_PERIOD_US, val;
+	u32 data, addr, poll;
+	int i;
 
-	bool	(*comp_check)(u32	val,
-			      u32	expected_val);
-	u32	delay = QED_INIT_POLL_PERIOD_US, val;
+	data = le32_to_cpu(cmd->op_data);
+	addr = GET_FIELD(data, INIT_READ_OP_ADDRESS) << 2;
+	poll = GET_FIELD(data, INIT_READ_OP_POLL_TYPE);
 
-	val = qed_rd(p_hwfn, p_ptt, addr);
 
-	data = le32_to_cpu(cmd->op_data);
-	if (GET_FIELD(data, INIT_READ_OP_POLL)) {
-		int i;
+	val = qed_rd(p_hwfn, p_ptt, addr);
 
-		switch (GET_FIELD(data, INIT_READ_OP_POLL_COMP)) {
-		case INIT_COMPARISON_EQ:
-			comp_check = comp_eq;
-			break;
-		case INIT_COMPARISON_OR:
-			comp_check = comp_or;
-			break;
-		case INIT_COMPARISON_AND:
-			comp_check = comp_and;
-			break;
-		default:
-			comp_check = NULL;
-			DP_ERR(p_hwfn, "Invalid poll comparison type %08x\n",
-			       data);
-			return;
-		}
+	if (poll == INIT_POLL_NONE)
+		return;
 
-		for (i = 0;
-		     i < QED_INIT_MAX_POLL_COUNT &&
-		     !comp_check(val, le32_to_cpu(cmd->expected_val));
-		     i++) {
-			udelay(delay);
-			val = qed_rd(p_hwfn, p_ptt, addr);
-		}
+	switch (poll) {
+	case INIT_POLL_EQ:
+		comp_check = comp_eq;
+		break;
+	case INIT_POLL_OR:
+		comp_check = comp_or;
+		break;
+	case INIT_POLL_AND:
+		comp_check = comp_and;
+		break;
+	default:
+		DP_ERR(p_hwfn, "Invalid poll comparison type %08x\n",
+		       cmd->op_data);
+		return;
+	}
 
-		if (i == QED_INIT_MAX_POLL_COUNT)
-			DP_ERR(p_hwfn,
-			       "Timeout when polling reg: 0x%08x [ Waiting-for: %08x Got: %08x (comparsion %08x)]\n",
-			       addr, le32_to_cpu(cmd->expected_val),
-			       val, data);
+	data = le32_to_cpu(cmd->expected_val);
+	for (i = 0;
+	     i < QED_INIT_MAX_POLL_COUNT && !comp_check(val, data);
+	     i++) {
+		udelay(delay);
+		val = qed_rd(p_hwfn, p_ptt, addr);
 	}
+
+	if (i == QED_INIT_MAX_POLL_COUNT)
+		DP_ERR(p_hwfn,
+		       "Timeout when polling reg: 0x%08x [ Waiting-for: %08x Got: %08x (comparsion %08x)]\n",
+		       addr, le32_to_cpu(cmd->expected_val),
+		       val, le32_to_cpu(cmd->op_data));
 }
 
 /* init_ops callbacks entry point */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index f72036a..978d07a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -714,7 +714,6 @@ qed_sp_eth_txq_start_ramrod(struct qed_hwfn  *p_hwfn,
 	p_ramrod->sb_id			= cpu_to_le16(p_params->sb);
 	p_ramrod->sb_index		= p_params->sb_idx;
 	p_ramrod->stats_counter_id	= stats_id;
-	p_ramrod->tc			= p_pq_params->eth.tc;
 
 	p_ramrod->pbl_size		= cpu_to_le16(pbl_size);
 	p_ramrod->pbl_base_addr.hi	= DMA_HI_LE(pbl_addr);
@@ -821,9 +820,8 @@ qed_filter_action(enum qed_filter_opcode opcode)
 	case QED_FILTER_REMOVE:
 		action = ETH_FILTER_ACTION_REMOVE;
 		break;
-	case QED_FILTER_REPLACE:
 	case QED_FILTER_FLUSH:
-		action = ETH_FILTER_ACTION_REPLACE;
+		action = ETH_FILTER_ACTION_REMOVE_ALL;
 		break;
 	default:
 		action = MAX_ETH_FILTER_ACTION;
@@ -892,8 +890,7 @@ qed_filter_ucast_common(struct qed_hwfn *p_hwfn,
 	p_ramrod->filter_cmd_hdr.tx = p_filter_cmd->is_tx_filter ? 1 : 0;
 
 	switch (p_filter_cmd->opcode) {
-	case QED_FILTER_FLUSH:
-		p_ramrod->filter_cmd_hdr.cmd_cnt = 0; break;
+	case QED_FILTER_REPLACE:
 	case QED_FILTER_MOVE:
 		p_ramrod->filter_cmd_hdr.cmd_cnt = 2; break;
 	default:
@@ -962,6 +959,12 @@ qed_filter_ucast_common(struct qed_hwfn *p_hwfn,
 
 		p_second_filter->action		= ETH_FILTER_ACTION_ADD;
 		p_second_filter->vport_id	= vport_to_add_to;
+	} else if (p_filter_cmd->opcode == QED_FILTER_REPLACE) {
+		p_first_filter->vport_id = vport_to_add_to;
+		memcpy(p_second_filter, p_first_filter,
+		       sizeof(*p_second_filter));
+		p_first_filter->action	= ETH_FILTER_ACTION_REMOVE_ALL;
+		p_second_filter->action = ETH_FILTER_ACTION_ADD;
 	} else {
 		action = qed_filter_action(p_filter_cmd->opcode);
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 9d76ce2..593f887 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -190,7 +190,7 @@ int qed_fill_dev_info(struct qed_dev *cdev,
 	dev_info->pci_mem_start = cdev->pci_params.mem_start;
 	dev_info->pci_mem_end = cdev->pci_params.mem_end;
 	dev_info->pci_irq = cdev->pci_params.irq;
-	dev_info->is_mf = IS_MF(&cdev->hwfns[0]);
+	dev_info->is_mf_default = IS_MF_DEFAULT(&cdev->hwfns[0]);
 	ether_addr_copy(dev_info->hw_mac, cdev->hwfns[0].hw_info.hw_mac_addr);
 
 	dev_info->fw_major = FW_MAJOR_VERSION;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index ba1b1f1..1457e30 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -720,26 +720,25 @@ int qed_mcp_fill_shmem_func_info(struct qed_hwfn *p_hwfn,
 		return -EINVAL;
 	}
 
-	if (p_hwfn->cdev->mf_mode != SF) {
-		info->bandwidth_min = (shmem_info.config &
-				       FUNC_MF_CFG_MIN_BW_MASK) >>
-				      FUNC_MF_CFG_MIN_BW_SHIFT;
-		if (info->bandwidth_min < 1 || info->bandwidth_min > 100) {
-			DP_INFO(p_hwfn,
-				"bandwidth minimum out of bounds [%02x]. Set to 1\n",
-				info->bandwidth_min);
-			info->bandwidth_min = 1;
-		}
 
-		info->bandwidth_max = (shmem_info.config &
-				       FUNC_MF_CFG_MAX_BW_MASK) >>
-				      FUNC_MF_CFG_MAX_BW_SHIFT;
-		if (info->bandwidth_max < 1 || info->bandwidth_max > 100) {
-			DP_INFO(p_hwfn,
-				"bandwidth maximum out of bounds [%02x]. Set to 100\n",
-				info->bandwidth_max);
-			info->bandwidth_max = 100;
-		}
+	info->bandwidth_min = (shmem_info.config &
+			       FUNC_MF_CFG_MIN_BW_MASK) >>
+			      FUNC_MF_CFG_MIN_BW_SHIFT;
+	if (info->bandwidth_min < 1 || info->bandwidth_min > 100) {
+		DP_INFO(p_hwfn,
+			"bandwidth minimum out of bounds [%02x]. Set to 1\n",
+			info->bandwidth_min);
+		info->bandwidth_min = 1;
+	}
+
+	info->bandwidth_max = (shmem_info.config &
+			       FUNC_MF_CFG_MAX_BW_MASK) >>
+			      FUNC_MF_CFG_MAX_BW_SHIFT;
+	if (info->bandwidth_max < 1 || info->bandwidth_max > 100) {
+		DP_INFO(p_hwfn,
+			"bandwidth maximum out of bounds [%02x]. Set to 100\n",
+			info->bandwidth_max);
+		info->bandwidth_max = 100;
 	}
 
 	if (shmem_info.mac_upper || shmem_info.mac_lower) {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp.h b/drivers/net/ethernet/qlogic/qed/qed_sp.h
index 287fadf..8a83609 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp.h
@@ -343,7 +343,7 @@ int qed_sp_init_request(struct qed_hwfn *p_hwfn,
  */
 
 int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
-		    enum mf_mode mode);
+		    enum qed_mf_mode mode);
 
 /**
  * @brief qed_sp_pf_stop - PF Function Stop Ramrod
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index 6f78791..33090f6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -90,7 +90,7 @@ int qed_sp_init_request(struct qed_hwfn *p_hwfn,
 }
 
 int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
-		    enum mf_mode mode)
+		    enum qed_mf_mode mode)
 {
 	struct qed_sp_init_request_params params;
 	struct pf_start_ramrod_data *p_ramrod = NULL;
@@ -125,6 +125,18 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 	p_ramrod->dont_log_ramrods	= 0;
 	p_ramrod->log_type_mask		= cpu_to_le16(0xf);
 	p_ramrod->mf_mode = mode;
+	switch (mode) {
+	case QED_MF_DEFAULT:
+	case QED_MF_NPAR:
+		p_ramrod->mf_mode = MF_NPAR;
+		break;
+	case QED_MF_OVLAN:
+		p_ramrod->mf_mode = MF_OVLAN;
+		break;
+	default:
+		DP_NOTICE(p_hwfn, "Unsupported MF mode, init as DEFAULT\n");
+		p_ramrod->mf_mode = MF_NPAR;
+	}
 	p_ramrod->outer_tag = p_hwfn->hw_info.ovlan;
 
 	/* Place EQ address in RAMROD */
@@ -142,9 +154,8 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 	p_hwfn->hw_info.personality = PERSONALITY_ETH;
 
 	DP_VERBOSE(p_hwfn, QED_MSG_SPQ,
-		   "Setting event_ring_sb [id %04x index %02x], mf [%s] outer_tag [%d]\n",
+		   "Setting event_ring_sb [id %04x index %02x], outer_tag [%d]\n",
 		   sb, sb_index,
-		   (p_ramrod->mf_mode == SF) ? "SF" : "Multi-Pf",
 		   p_ramrod->outer_tag);
 
 	return qed_spq_post(p_hwfn, p_ent, NULL);
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 7c6caf7..4dbd80e 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -173,9 +173,10 @@ enum QEDE_STATE {
  * skb are built only after the frame was DMA-ed.
  */
 struct sw_rx_data {
-	u8 *data;
+	struct page *data;
 
 	DEFINE_DMA_UNMAP_ADDR(mapping);
+	unsigned int page_offset;
 };
 
 struct qede_rx_queue {
@@ -188,6 +189,7 @@ struct qede_rx_queue {
 	void __iomem		*hw_rxq_prod_addr;
 
 	int			rx_buf_size;
+	unsigned int		rx_buf_seg_size;
 
 	u16			num_rx_buffers;
 	u16			rxq_id;
@@ -281,6 +283,7 @@ void qede_fill_by_demand_stats(struct qede_dev *edev);
 #define NUM_TX_BDS_MIN		128
 #define NUM_TX_BDS_DEF		NUM_TX_BDS_MAX
 
+#define QEDE_RX_HDR_SIZE	256
 #define	for_each_rss(i) for (i = 0; i < edev->num_rss; i++)
 
 #endif /* _QEDE_H_ */
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index e442b85..c49dc10 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -217,9 +217,9 @@ static int qede_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	struct qed_link_params params;
 	u32 speed;
 
-	if (edev->dev_info.common.is_mf) {
+	if (!edev->dev_info.common.is_mf_default) {
 		DP_INFO(edev,
-			"Link parameters can not be changed in MF mode\n");
+			"Link parameters can not be changed in non-default mode\n");
 		return -EOPNOTSUPP;
 	}
 
@@ -428,7 +428,7 @@ static int qede_set_pauseparam(struct net_device *dev,
 	struct qed_link_params params;
 	struct qed_link_output current_link;
 
-	if (!edev->dev_info.common.is_mf) {
+	if (!edev->dev_info.common.is_mf_default) {
 		DP_INFO(edev,
 			"Pause parameters can not be updated in non-default mode\n");
 		return -EOPNOTSUPP;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 6237f10..9446aec 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -330,15 +330,15 @@ static void qede_set_params_for_ipv6_ext(struct sk_buff *skb,
 					 struct eth_tx_3rd_bd *third_bd)
 {
 	u8 l4_proto;
-	u16 bd2_bits = 0, bd2_bits2 = 0;
+	u16 bd2_bits1 = 0, bd2_bits2 = 0;
 
-	bd2_bits2 |= (1 << ETH_TX_DATA_2ND_BD_IPV6_EXT_SHIFT);
+	bd2_bits1 |= (1 << ETH_TX_DATA_2ND_BD_IPV6_EXT_SHIFT);
 
-	bd2_bits |= ((((u8 *)skb_transport_header(skb) - skb->data) >> 1) &
+	bd2_bits2 |= ((((u8 *)skb_transport_header(skb) - skb->data) >> 1) &
 		     ETH_TX_DATA_2ND_BD_L4_HDR_START_OFFSET_W_MASK)
 		    << ETH_TX_DATA_2ND_BD_L4_HDR_START_OFFSET_W_SHIFT;
 
-	bd2_bits2 |= (ETH_L4_PSEUDO_CSUM_CORRECT_LENGTH <<
+	bd2_bits1 |= (ETH_L4_PSEUDO_CSUM_CORRECT_LENGTH <<
 		      ETH_TX_DATA_2ND_BD_L4_PSEUDO_CSUM_MODE_SHIFT);
 
 	if (vlan_get_protocol(skb) == htons(ETH_P_IPV6))
@@ -347,16 +347,15 @@ static void qede_set_params_for_ipv6_ext(struct sk_buff *skb,
 		l4_proto = ip_hdr(skb)->protocol;
 
 	if (l4_proto == IPPROTO_UDP)
-		bd2_bits2 |= 1 << ETH_TX_DATA_2ND_BD_L4_UDP_SHIFT;
+		bd2_bits1 |= 1 << ETH_TX_DATA_2ND_BD_L4_UDP_SHIFT;
 
-	if (third_bd) {
+	if (third_bd)
 		third_bd->data.bitfields |=
-			((tcp_hdrlen(skb) / 4) &
-			 ETH_TX_DATA_3RD_BD_TCP_HDR_LEN_DW_MASK) <<
-			ETH_TX_DATA_3RD_BD_TCP_HDR_LEN_DW_SHIFT;
-	}
+			cpu_to_le16(((tcp_hdrlen(skb) / 4) &
+				ETH_TX_DATA_3RD_BD_TCP_HDR_LEN_DW_MASK) <<
+				ETH_TX_DATA_3RD_BD_TCP_HDR_LEN_DW_SHIFT);
 
-	second_bd->data.bitfields = cpu_to_le16(bd2_bits);
+	second_bd->data.bitfields1 = cpu_to_le16(bd2_bits1);
 	second_bd->data.bitfields2 = cpu_to_le16(bd2_bits2);
 }
 
@@ -464,12 +463,16 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 
 	/* Fill the parsing flags & params according to the requested offload */
 	if (xmit_type & XMIT_L4_CSUM) {
+		u16 temp = 1 << ETH_TX_DATA_1ST_BD_TUNN_CFG_OVERRIDE_SHIFT;
+
 		/* We don't re-calculate IP checksum as it is already done by
 		 * the upper stack
 		 */
 		first_bd->data.bd_flags.bitfields |=
 			1 << ETH_TX_1ST_BD_FLAGS_L4_CSUM_SHIFT;
 
+		first_bd->data.bitfields |= cpu_to_le16(temp);
+
 		/* If the packet is IPv6 with extension header, indicate that
 		 * to FW and pass few params, since the device cracker doesn't
 		 * support parsing IPv6 with extension header/s.
@@ -491,7 +494,7 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 
 		/* @@@TBD - if will not be removed need to check */
 		third_bd->data.bitfields |=
-			(1 << ETH_TX_DATA_3RD_BD_HDR_NBD_SHIFT);
+			cpu_to_le16((1 << ETH_TX_DATA_3RD_BD_HDR_NBD_SHIFT));
 
 		/* Make life easier for FW guys who can't deal with header and
 		 * data on same BD. If we need to split, use the second bd...
@@ -719,26 +722,53 @@ static bool qede_has_tx_work(struct qede_fastpath *fp)
 	return false;
 }
 
-/* This function copies the Rx buffer from the CONS position to the PROD
- * position, since we failed to allocate a new Rx buffer.
+/* This function reuses the buffer(from an offset) from
+ * consumer index to producer index in the bd ring
  */
-static void qede_reuse_rx_data(struct qede_rx_queue *rxq)
+static inline void qede_reuse_page(struct qede_dev *edev,
+				   struct qede_rx_queue *rxq,
+				   struct sw_rx_data *curr_cons)
 {
-	struct eth_rx_bd *rx_bd_cons = qed_chain_consume(&rxq->rx_bd_ring);
 	struct eth_rx_bd *rx_bd_prod = qed_chain_produce(&rxq->rx_bd_ring);
-	struct sw_rx_data *sw_rx_data_cons =
-		&rxq->sw_rx_ring[rxq->sw_rx_cons & NUM_RX_BDS_MAX];
-	struct sw_rx_data *sw_rx_data_prod =
-		&rxq->sw_rx_ring[rxq->sw_rx_prod & NUM_RX_BDS_MAX];
+	DEFINE_DMA_UNMAP_ADDR(new_mapping);
+	struct sw_rx_data *curr_prod;
 
-	dma_unmap_addr_set(sw_rx_data_prod, mapping,
-			   dma_unmap_addr(sw_rx_data_cons, mapping));
+	curr_prod = &rxq->sw_rx_ring[rxq->sw_rx_prod & NUM_RX_BDS_MAX];
+	*curr_prod = *curr_cons;
 
-	sw_rx_data_prod->data = sw_rx_data_cons->data;
-	memcpy(rx_bd_prod, rx_bd_cons, sizeof(struct eth_rx_bd));
+	new_mapping = curr_prod->mapping + curr_prod->page_offset;
+
+	rx_bd_prod->addr.hi = cpu_to_le32(upper_32_bits(new_mapping));
+	rx_bd_prod->addr.lo = cpu_to_le32(lower_32_bits(new_mapping));
 
-	rxq->sw_rx_cons++;
 	rxq->sw_rx_prod++;
+	curr_cons->data = NULL;
+}
+
+static inline int qede_realloc_rx_buffer(struct qede_dev *edev,
+					 struct qede_rx_queue *rxq,
+					 struct sw_rx_data *curr_cons)
+{
+	/* Move to the next segment in the page */
+	curr_cons->page_offset += rxq->rx_buf_seg_size;
+
+	if (curr_cons->page_offset == PAGE_SIZE) {
+		if (unlikely(qede_alloc_rx_buffer(edev, rxq)))
+			return -ENOMEM;
+
+		dma_unmap_page(&edev->pdev->dev,
+			       dma_unmap_addr(curr_cons, mapping),
+			       PAGE_SIZE, DMA_FROM_DEVICE);
+	} else {
+		/* Increment refcount of the page as we don't want
+		 * network stack to take the ownership of the page
+		 * which can be recycled multiple times by the driver.
+		 */
+		atomic_inc(&curr_cons->data->_count);
+		qede_reuse_page(edev, rxq, curr_cons);
+	}
+
+	return 0;
 }
 
 static inline void qede_update_rx_prod(struct qede_dev *edev,
@@ -857,9 +887,10 @@ static int qede_rx_int(struct qede_fastpath *fp, int budget)
 		struct sw_rx_data *sw_rx_data;
 		union eth_rx_cqe *cqe;
 		struct sk_buff *skb;
+		struct page *data;
+		__le16 flags;
 		u16 len, pad;
 		u32 rx_hash;
-		u8 *data;
 
 		/* Get the CQE from the completion ring */
 		cqe = (union eth_rx_cqe *)
@@ -879,56 +910,110 @@ static int qede_rx_int(struct qede_fastpath *fp, int budget)
 		data = sw_rx_data->data;
 
 		fp_cqe = &cqe->fast_path_regular;
-		len =  le16_to_cpu(fp_cqe->pkt_len);
+		len =  le16_to_cpu(fp_cqe->len_on_first_bd);
 		pad = fp_cqe->placement_offset;
+		flags = cqe->fast_path_regular.pars_flags.flags;
 
-		/* For every Rx BD consumed, we allocate a new BD so the BD ring
-		 * is always with a fixed size. If allocation fails, we take the
-		 * consumed BD and return it to the ring in the PROD position.
-		 * The packet that was received on that BD will be dropped (and
-		 * not passed to the upper stack).
-		 */
-		if (likely(qede_alloc_rx_buffer(edev, rxq) == 0)) {
-			dma_unmap_single(&edev->pdev->dev,
-					 dma_unmap_addr(sw_rx_data, mapping),
-					 rxq->rx_buf_size, DMA_FROM_DEVICE);
-
-			/* If this is an error packet then drop it */
-			parse_flag =
-			le16_to_cpu(cqe->fast_path_regular.pars_flags.flags);
-			csum_flag = qede_check_csum(parse_flag);
-			if (csum_flag == QEDE_CSUM_ERROR) {
-				DP_NOTICE(edev,
-					  "CQE in CONS = %u has error, flags = %x, dropping incoming packet\n",
-					  sw_comp_cons, parse_flag);
-				rxq->rx_hw_errors++;
-				kfree(data);
-				goto next_rx;
-			}
-
-			skb = build_skb(data, 0);
+		/* If this is an error packet then drop it */
+		parse_flag = le16_to_cpu(flags);
 
-			if (unlikely(!skb)) {
-				DP_NOTICE(edev,
-					  "Build_skb failed, dropping incoming packet\n");
-				kfree(data);
-				rxq->rx_alloc_errors++;
-				goto next_rx;
-			}
-
-			skb_reserve(skb, pad);
+		csum_flag = qede_check_csum(parse_flag);
+		if (unlikely(csum_flag == QEDE_CSUM_ERROR)) {
+			DP_NOTICE(edev,
+				  "CQE in CONS = %u has error, flags = %x, dropping incoming packet\n",
+				  sw_comp_cons, parse_flag);
+			rxq->rx_hw_errors++;
+			qede_reuse_page(edev, rxq, sw_rx_data);
+			goto next_rx;
+		}
 
-		} else {
+		skb = netdev_alloc_skb(edev->ndev, QEDE_RX_HDR_SIZE);
+		if (unlikely(!skb)) {
 			DP_NOTICE(edev,
-				  "New buffer allocation failed, dropping incoming packet and reusing its buffer\n");
-			qede_reuse_rx_data(rxq);
+				  "Build_skb failed, dropping incoming packet\n");
+			qede_reuse_page(edev, rxq, sw_rx_data);
 			rxq->rx_alloc_errors++;
-			goto next_cqe;
+			goto next_rx;
+		}
+
+		/* Copy data into SKB */
+		if (len + pad <= QEDE_RX_HDR_SIZE) {
+			memcpy(skb_put(skb, len),
+			       page_address(data) + pad +
+				sw_rx_data->page_offset, len);
+			qede_reuse_page(edev, rxq, sw_rx_data);
+		} else {
+			struct skb_frag_struct *frag;
+			unsigned int pull_len;
+			unsigned char *va;
+
+			frag = &skb_shinfo(skb)->frags[0];
+
+			skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, data,
+					pad + sw_rx_data->page_offset,
+					len, rxq->rx_buf_seg_size);
+
+			va = skb_frag_address(frag);
+			pull_len = eth_get_headlen(va, QEDE_RX_HDR_SIZE);
+
+			/* Align the pull_len to optimize memcpy */
+			memcpy(skb->data, va, ALIGN(pull_len, sizeof(long)));
+
+			skb_frag_size_sub(frag, pull_len);
+			frag->page_offset += pull_len;
+			skb->data_len -= pull_len;
+			skb->tail += pull_len;
+
+			if (unlikely(qede_realloc_rx_buffer(edev, rxq,
+							    sw_rx_data))) {
+				DP_ERR(edev, "Failed to allocate rx buffer\n");
+				rxq->rx_alloc_errors++;
+				goto next_cqe;
+			}
 		}
 
-		sw_rx_data->data = NULL;
+		if (fp_cqe->bd_num != 1) {
+			u16 pkt_len = le16_to_cpu(fp_cqe->pkt_len);
+			u8 num_frags;
+
+			pkt_len -= len;
+
+			for (num_frags = fp_cqe->bd_num - 1; num_frags > 0;
+			     num_frags--) {
+				u16 cur_size = pkt_len > rxq->rx_buf_size ?
+						rxq->rx_buf_size : pkt_len;
+				if (unlikely(!cur_size))
+					WARN_ONCE(1,
+						  "Still got %d BDs for mapping jumbo, but length became 0\n",
+						  num_frags);
+
+				if (unlikely(qede_alloc_rx_buffer(edev, rxq)))
+					goto next_cqe;
+
+				rxq->sw_rx_cons++;
+				sw_rx_index = rxq->sw_rx_cons & NUM_RX_BDS_MAX;
+				sw_rx_data = &rxq->sw_rx_ring[sw_rx_index];
+				qed_chain_consume(&rxq->rx_bd_ring);
+				dma_unmap_page(&edev->pdev->dev,
+					       sw_rx_data->mapping,
+					       PAGE_SIZE, DMA_FROM_DEVICE);
+
+				skb_fill_page_desc(skb,
+						   skb_shinfo(skb)->nr_frags++,
+						   sw_rx_data->data, 0,
+						   cur_size);
+
+				skb->truesize += PAGE_SIZE;
+				skb->data_len += cur_size;
+				skb->len += cur_size;
+				pkt_len -= cur_size;
+			}
 
-		skb_put(skb, len);
+			if (pkt_len)
+				DP_ERR(edev,
+				       "Mapped all BDs of jumbo, but still have %d bytes\n",
+				       pkt_len);
+		}
 
 		skb->protocol = eth_type_trans(skb, edev->ndev);
 
@@ -1566,17 +1651,17 @@ static void qede_free_rx_buffers(struct qede_dev *edev,
 
 	for (i = rxq->sw_rx_cons; i != rxq->sw_rx_prod; i++) {
 		struct sw_rx_data *rx_buf;
-		u8 *data;
+		struct page *data;
 
 		rx_buf = &rxq->sw_rx_ring[i & NUM_RX_BDS_MAX];
 		data = rx_buf->data;
 
-		dma_unmap_single(&edev->pdev->dev,
-				 dma_unmap_addr(rx_buf, mapping),
-				 rxq->rx_buf_size, DMA_FROM_DEVICE);
+		dma_unmap_page(&edev->pdev->dev,
+			       dma_unmap_addr(rx_buf, mapping),
+			       PAGE_SIZE, DMA_FROM_DEVICE);
 
 		rx_buf->data = NULL;
-		kfree(data);
+		__free_page(data);
 	}
 }
 
@@ -1600,26 +1685,30 @@ static int qede_alloc_rx_buffer(struct qede_dev *edev,
 	struct sw_rx_data *sw_rx_data;
 	struct eth_rx_bd *rx_bd;
 	dma_addr_t mapping;
+	struct page *data;
 	u16 rx_buf_size;
-	u8 *data;
 
 	rx_buf_size = rxq->rx_buf_size;
 
-	data = kmalloc(rx_buf_size, GFP_ATOMIC);
+	data = alloc_pages(GFP_ATOMIC, 0);
 	if (unlikely(!data)) {
-		DP_NOTICE(edev, "Failed to allocate Rx data\n");
+		DP_NOTICE(edev, "Failed to allocate Rx data [page]\n");
 		return -ENOMEM;
 	}
 
-	mapping = dma_map_single(&edev->pdev->dev, data,
-				 rx_buf_size, DMA_FROM_DEVICE);
+	/* Map the entire page as it would be used
+	 * for multiple RX buffer segment size mapping.
+	 */
+	mapping = dma_map_page(&edev->pdev->dev, data, 0,
+			       PAGE_SIZE, DMA_FROM_DEVICE);
 	if (unlikely(dma_mapping_error(&edev->pdev->dev, mapping))) {
-		kfree(data);
+		__free_page(data);
 		DP_NOTICE(edev, "Failed to map Rx buffer\n");
 		return -ENOMEM;
 	}
 
 	sw_rx_data = &rxq->sw_rx_ring[rxq->sw_rx_prod & NUM_RX_BDS_MAX];
+	sw_rx_data->page_offset = 0;
 	sw_rx_data->data = data;
 
 	dma_unmap_addr_set(sw_rx_data, mapping, mapping);
@@ -1643,13 +1732,16 @@ static int qede_alloc_mem_rxq(struct qede_dev *edev,
 
 	rxq->num_rx_buffers = edev->q_num_rx_buffers;
 
-	rxq->rx_buf_size = NET_IP_ALIGN +
-			   ETH_OVERHEAD +
-			   edev->ndev->mtu +
-			   QEDE_FW_RX_ALIGN_END;
+	rxq->rx_buf_size = NET_IP_ALIGN + ETH_OVERHEAD +
+			   edev->ndev->mtu;
+	if (rxq->rx_buf_size > PAGE_SIZE)
+		rxq->rx_buf_size = PAGE_SIZE;
+
+	/* Segment size to spilt a page in multiple equal parts */
+	rxq->rx_buf_seg_size = roundup_pow_of_two(rxq->rx_buf_size);
 
 	/* Allocate the parallel driver ring for Rx buffers */
-	size = sizeof(*rxq->sw_rx_ring) * NUM_RX_BDS_MAX;
+	size = sizeof(*rxq->sw_rx_ring) * RX_RING_SIZE;
 	rxq->sw_rx_ring = kzalloc(size, GFP_KERNEL);
 	if (!rxq->sw_rx_ring) {
 		DP_ERR(edev, "Rx buffers ring allocation failed\n");
@@ -1660,7 +1752,7 @@ static int qede_alloc_mem_rxq(struct qede_dev *edev,
 	rc = edev->ops->common->chain_alloc(edev->cdev,
 					    QED_CHAIN_USE_TO_CONSUME_PRODUCE,
 					    QED_CHAIN_MODE_NEXT_PTR,
-					    NUM_RX_BDS_MAX,
+					    RX_RING_SIZE,
 					    sizeof(struct eth_rx_bd),
 					    &rxq->rx_bd_ring);
 
@@ -1671,7 +1763,7 @@ static int qede_alloc_mem_rxq(struct qede_dev *edev,
 	rc = edev->ops->common->chain_alloc(edev->cdev,
 					    QED_CHAIN_USE_TO_CONSUME,
 					    QED_CHAIN_MODE_PBL,
-					    NUM_RX_BDS_MAX,
+					    RX_RING_SIZE,
 					    sizeof(union eth_rx_cqe),
 					    &rxq->rx_comp_ring);
 	if (rc)
diff --git a/include/linux/qed/common_hsi.h b/include/linux/qed/common_hsi.h
index 1d1ba2c..53ecb37 100644
--- a/include/linux/qed/common_hsi.h
+++ b/include/linux/qed/common_hsi.h
@@ -11,9 +11,11 @@
 
 #define CORE_SPQE_PAGE_SIZE_BYTES                       4096
 
+#define X_FINAL_CLEANUP_AGG_INT 1
+
 #define FW_MAJOR_VERSION	8
-#define FW_MINOR_VERSION	4
-#define FW_REVISION_VERSION	2
+#define FW_MINOR_VERSION	7
+#define FW_REVISION_VERSION	3
 #define FW_ENGINEERING_VERSION	0
 
 /***********************/
@@ -152,6 +154,9 @@
 /* number of queues in a PF queue group */
 #define QM_PF_QUEUE_GROUP_SIZE	8
 
+/* the size of a single queue element in bytes */
+#define QM_PQ_ELEMENT_SIZE                      4
+
 /* base number of Tx PQs in the CM PQ representation.
  * should be used when storing PQ IDs in CM PQ registers and context
  */
@@ -285,6 +290,16 @@
 #define PXP_NUM_ILT_RECORDS_K2 11000
 #define MAX_NUM_ILT_RECORDS MAX(PXP_NUM_ILT_RECORDS_BB, PXP_NUM_ILT_RECORDS_K2)
 
+#define SDM_COMP_TYPE_NONE              0
+#define SDM_COMP_TYPE_WAKE_THREAD       1
+#define SDM_COMP_TYPE_AGG_INT           2
+#define SDM_COMP_TYPE_CM                3
+#define SDM_COMP_TYPE_LOADER            4
+#define SDM_COMP_TYPE_PXP               5
+#define SDM_COMP_TYPE_INDICATE_ERROR    6
+#define SDM_COMP_TYPE_RELEASE_THREAD    7
+#define SDM_COMP_TYPE_RAM               8
+
 /******************/
 /* PBF CONSTANTS  */
 /******************/
@@ -335,7 +350,7 @@ struct event_ring_entry {
 
 /* Multi function mode */
 enum mf_mode {
-	SF,
+	ERROR_MODE /* Unsupported mode */,
 	MF_OVLAN,
 	MF_NPAR,
 	MAX_MF_MODE
@@ -606,4 +621,19 @@ struct status_block {
 #define STATUS_BLOCK_ZERO_PAD3_SHIFT  24
 };
 
+struct tunnel_parsing_flags {
+	u8 flags;
+#define TUNNEL_PARSING_FLAGS_TYPE_MASK              0x3
+#define TUNNEL_PARSING_FLAGS_TYPE_SHIFT             0
+#define TUNNEL_PARSING_FLAGS_TENNANT_ID_EXIST_MASK  0x1
+#define TUNNEL_PARSING_FLAGS_TENNANT_ID_EXIST_SHIFT 2
+#define TUNNEL_PARSING_FLAGS_NEXT_PROTOCOL_MASK     0x3
+#define TUNNEL_PARSING_FLAGS_NEXT_PROTOCOL_SHIFT    3
+#define TUNNEL_PARSING_FLAGS_FIRSTHDRIPMATCH_MASK   0x1
+#define TUNNEL_PARSING_FLAGS_FIRSTHDRIPMATCH_SHIFT  5
+#define TUNNEL_PARSING_FLAGS_IPV4_FRAGMENT_MASK     0x1
+#define TUNNEL_PARSING_FLAGS_IPV4_FRAGMENT_SHIFT    6
+#define TUNNEL_PARSING_FLAGS_IPV4_OPTIONS_MASK      0x1
+#define TUNNEL_PARSING_FLAGS_IPV4_OPTIONS_SHIFT     7
+};
 #endif /* __COMMON_HSI__ */
diff --git a/include/linux/qed/eth_common.h b/include/linux/qed/eth_common.h
index 320b337..092cb0c 100644
--- a/include/linux/qed/eth_common.h
+++ b/include/linux/qed/eth_common.h
@@ -17,10 +17,8 @@
 #define ETH_MAX_RAMROD_PER_CON                          8
 #define ETH_TX_BD_PAGE_SIZE_BYTES                       4096
 #define ETH_RX_BD_PAGE_SIZE_BYTES                       4096
-#define ETH_RX_SGE_PAGE_SIZE_BYTES                      4096
 #define ETH_RX_CQE_PAGE_SIZE_BYTES                      4096
 #define ETH_RX_NUM_NEXT_PAGE_BDS                        2
-#define ETH_RX_NUM_NEXT_PAGE_SGES                       2
 
 #define ETH_TX_MIN_BDS_PER_NON_LSO_PKT                          1
 #define ETH_TX_MAX_BDS_PER_NON_LSO_PACKET                       18
@@ -34,7 +32,8 @@
 
 #define ETH_NUM_STATISTIC_COUNTERS                      MAX_NUM_VPORTS
 
-#define ETH_REG_CQE_PBL_SIZE                3
+/* Maximum number of buffers, used for RX packet placement */
+#define ETH_RX_MAX_BUFF_PER_PKT             5
 
 /* num of MAC/VLAN filters */
 #define ETH_NUM_MAC_FILTERS                                     512
@@ -54,9 +53,9 @@
 
 /* TPA constants */
 #define ETH_TPA_MAX_AGGS_NUM              64
-#define ETH_TPA_CQE_START_SGL_SIZE        3
-#define ETH_TPA_CQE_CONT_SGL_SIZE         6
-#define ETH_TPA_CQE_END_SGL_SIZE          4
+#define ETH_TPA_CQE_START_LEN_LIST_SIZE   ETH_RX_MAX_BUFF_PER_PKT
+#define ETH_TPA_CQE_CONT_LEN_LIST_SIZE    6
+#define ETH_TPA_CQE_END_LEN_LIST_SIZE     4
 
 /* Queue Zone sizes */
 #define TSTORM_QZONE_SIZE    0
@@ -74,18 +73,18 @@ struct coalescing_timeset {
 
 struct eth_tx_1st_bd_flags {
 	u8 bitfields;
+#define ETH_TX_1ST_BD_FLAGS_START_BD_MASK         0x1
+#define ETH_TX_1ST_BD_FLAGS_START_BD_SHIFT        0
 #define ETH_TX_1ST_BD_FLAGS_FORCE_VLAN_MODE_MASK  0x1
-#define ETH_TX_1ST_BD_FLAGS_FORCE_VLAN_MODE_SHIFT 0
+#define ETH_TX_1ST_BD_FLAGS_FORCE_VLAN_MODE_SHIFT 1
 #define ETH_TX_1ST_BD_FLAGS_IP_CSUM_MASK          0x1
-#define ETH_TX_1ST_BD_FLAGS_IP_CSUM_SHIFT         1
+#define ETH_TX_1ST_BD_FLAGS_IP_CSUM_SHIFT         2
 #define ETH_TX_1ST_BD_FLAGS_L4_CSUM_MASK          0x1
-#define ETH_TX_1ST_BD_FLAGS_L4_CSUM_SHIFT         2
+#define ETH_TX_1ST_BD_FLAGS_L4_CSUM_SHIFT         3
 #define ETH_TX_1ST_BD_FLAGS_VLAN_INSERTION_MASK   0x1
-#define ETH_TX_1ST_BD_FLAGS_VLAN_INSERTION_SHIFT  3
+#define ETH_TX_1ST_BD_FLAGS_VLAN_INSERTION_SHIFT  4
 #define ETH_TX_1ST_BD_FLAGS_LSO_MASK              0x1
-#define ETH_TX_1ST_BD_FLAGS_LSO_SHIFT             4
-#define ETH_TX_1ST_BD_FLAGS_START_BD_MASK         0x1
-#define ETH_TX_1ST_BD_FLAGS_START_BD_SHIFT        5
+#define ETH_TX_1ST_BD_FLAGS_LSO_SHIFT             5
 #define ETH_TX_1ST_BD_FLAGS_TUNN_IP_CSUM_MASK     0x1
 #define ETH_TX_1ST_BD_FLAGS_TUNN_IP_CSUM_SHIFT    6
 #define ETH_TX_1ST_BD_FLAGS_TUNN_L4_CSUM_MASK     0x1
@@ -97,38 +96,44 @@ struct eth_tx_data_1st_bd {
 	__le16				vlan;
 	u8				nbds;
 	struct eth_tx_1st_bd_flags	bd_flags;
-	__le16				fw_use_only;
+	__le16				bitfields;
+#define ETH_TX_DATA_1ST_BD_TUNN_CFG_OVERRIDE_MASK  0x1
+#define ETH_TX_DATA_1ST_BD_TUNN_CFG_OVERRIDE_SHIFT 0
+#define ETH_TX_DATA_1ST_BD_RESERVED0_MASK          0x1
+#define ETH_TX_DATA_1ST_BD_RESERVED0_SHIFT         1
+#define ETH_TX_DATA_1ST_BD_FW_USE_ONLY_MASK        0x3FFF
+#define ETH_TX_DATA_1ST_BD_FW_USE_ONLY_SHIFT       2
 };
 
 /* The parsing information data for the second tx bd of a given packet. */
 struct eth_tx_data_2nd_bd {
 	__le16	tunn_ip_size;
-	__le16	bitfields;
-#define ETH_TX_DATA_2ND_BD_L4_HDR_START_OFFSET_W_MASK     0x1FFF
-#define ETH_TX_DATA_2ND_BD_L4_HDR_START_OFFSET_W_SHIFT    0
-#define ETH_TX_DATA_2ND_BD_RESERVED0_MASK                 0x7
-#define ETH_TX_DATA_2ND_BD_RESERVED0_SHIFT                13
-	__le16	bitfields2;
+	__le16	bitfields1;
 #define ETH_TX_DATA_2ND_BD_TUNN_INNER_L2_HDR_SIZE_W_MASK  0xF
 #define ETH_TX_DATA_2ND_BD_TUNN_INNER_L2_HDR_SIZE_W_SHIFT 0
 #define ETH_TX_DATA_2ND_BD_TUNN_INNER_ETH_TYPE_MASK       0x3
 #define ETH_TX_DATA_2ND_BD_TUNN_INNER_ETH_TYPE_SHIFT      4
 #define ETH_TX_DATA_2ND_BD_DEST_PORT_MODE_MASK            0x3
 #define ETH_TX_DATA_2ND_BD_DEST_PORT_MODE_SHIFT           6
+#define ETH_TX_DATA_2ND_BD_START_BD_MASK                  0x1
+#define ETH_TX_DATA_2ND_BD_START_BD_SHIFT                 8
 #define ETH_TX_DATA_2ND_BD_TUNN_TYPE_MASK                 0x3
-#define ETH_TX_DATA_2ND_BD_TUNN_TYPE_SHIFT                8
+#define ETH_TX_DATA_2ND_BD_TUNN_TYPE_SHIFT                9
 #define ETH_TX_DATA_2ND_BD_TUNN_INNER_IPV6_MASK           0x1
-#define ETH_TX_DATA_2ND_BD_TUNN_INNER_IPV6_SHIFT          10
+#define ETH_TX_DATA_2ND_BD_TUNN_INNER_IPV6_SHIFT          11
 #define ETH_TX_DATA_2ND_BD_IPV6_EXT_MASK                  0x1
-#define ETH_TX_DATA_2ND_BD_IPV6_EXT_SHIFT                 11
+#define ETH_TX_DATA_2ND_BD_IPV6_EXT_SHIFT                 12
 #define ETH_TX_DATA_2ND_BD_TUNN_IPV6_EXT_MASK             0x1
-#define ETH_TX_DATA_2ND_BD_TUNN_IPV6_EXT_SHIFT            12
+#define ETH_TX_DATA_2ND_BD_TUNN_IPV6_EXT_SHIFT            13
 #define ETH_TX_DATA_2ND_BD_L4_UDP_MASK                    0x1
-#define ETH_TX_DATA_2ND_BD_L4_UDP_SHIFT                   13
+#define ETH_TX_DATA_2ND_BD_L4_UDP_SHIFT                   14
 #define ETH_TX_DATA_2ND_BD_L4_PSEUDO_CSUM_MODE_MASK       0x1
-#define ETH_TX_DATA_2ND_BD_L4_PSEUDO_CSUM_MODE_SHIFT      14
-#define ETH_TX_DATA_2ND_BD_RESERVED1_MASK                 0x1
-#define ETH_TX_DATA_2ND_BD_RESERVED1_SHIFT                15
+#define ETH_TX_DATA_2ND_BD_L4_PSEUDO_CSUM_MODE_SHIFT      15
+	__le16 bitfields2;
+#define ETH_TX_DATA_2ND_BD_L4_HDR_START_OFFSET_W_MASK     0x1FFF
+#define ETH_TX_DATA_2ND_BD_L4_HDR_START_OFFSET_W_SHIFT    0
+#define ETH_TX_DATA_2ND_BD_RESERVED0_MASK                 0x7
+#define ETH_TX_DATA_2ND_BD_RESERVED0_SHIFT                13
 };
 
 /* Regular ETH Rx FP CQE. */
@@ -145,11 +150,68 @@ struct eth_fast_path_rx_reg_cqe {
 	struct parsing_and_err_flags	pars_flags;
 	__le16				vlan_tag;
 	__le32				rss_hash;
-	__le16				len_on_bd;
+	__le16				len_on_first_bd;
 	u8				placement_offset;
-	u8				reserved;
-	__le16				pbl[ETH_REG_CQE_PBL_SIZE];
-	u8				reserved1[10];
+	struct tunnel_parsing_flags	tunnel_pars_flags;
+	u8				bd_num;
+	u8				reserved[7];
+	u32				fw_debug;
+	u8				reserved1[3];
+	u8				flags;
+#define ETH_FAST_PATH_RX_REG_CQE_VALID_MASK          0x1
+#define ETH_FAST_PATH_RX_REG_CQE_VALID_SHIFT         0
+#define ETH_FAST_PATH_RX_REG_CQE_VALID_TOGGLE_MASK   0x1
+#define ETH_FAST_PATH_RX_REG_CQE_VALID_TOGGLE_SHIFT  1
+#define ETH_FAST_PATH_RX_REG_CQE_RESERVED2_MASK      0x3F
+#define ETH_FAST_PATH_RX_REG_CQE_RESERVED2_SHIFT     2
+};
+
+/* TPA-continue ETH Rx FP CQE. */
+struct eth_fast_path_rx_tpa_cont_cqe {
+	u8	type;
+	u8	tpa_agg_index;
+	__le16	len_list[ETH_TPA_CQE_CONT_LEN_LIST_SIZE];
+	u8	reserved[5];
+	u8	reserved1;
+	__le16	reserved2[ETH_TPA_CQE_CONT_LEN_LIST_SIZE];
+};
+
+/* TPA-end ETH Rx FP CQE. */
+struct eth_fast_path_rx_tpa_end_cqe {
+	u8	type;
+	u8	tpa_agg_index;
+	__le16	total_packet_len;
+	u8	num_of_bds;
+	u8	end_reason;
+	__le16	num_of_coalesced_segs;
+	__le32	ts_delta;
+	__le16	len_list[ETH_TPA_CQE_END_LEN_LIST_SIZE];
+	u8	reserved1[3];
+	u8	reserved2;
+	__le16	reserved3[ETH_TPA_CQE_END_LEN_LIST_SIZE];
+};
+
+/* TPA-start ETH Rx FP CQE. */
+struct eth_fast_path_rx_tpa_start_cqe {
+	u8	type;
+	u8	bitfields;
+#define ETH_FAST_PATH_RX_TPA_START_CQE_RSS_HASH_TYPE_MASK  0x7
+#define ETH_FAST_PATH_RX_TPA_START_CQE_RSS_HASH_TYPE_SHIFT 0
+#define ETH_FAST_PATH_RX_TPA_START_CQE_TC_MASK             0xF
+#define ETH_FAST_PATH_RX_TPA_START_CQE_TC_SHIFT            3
+#define ETH_FAST_PATH_RX_TPA_START_CQE_RESERVED0_MASK      0x1
+#define ETH_FAST_PATH_RX_TPA_START_CQE_RESERVED0_SHIFT     7
+	__le16	seg_len;
+	struct parsing_and_err_flags pars_flags;
+	__le16	vlan_tag;
+	__le32	rss_hash;
+	__le16	len_on_first_bd;
+	u8	placement_offset;
+	struct tunnel_parsing_flags tunnel_pars_flags;
+	u8	tpa_agg_index;
+	u8	header_len;
+	__le16	ext_bd_len_list[ETH_TPA_CQE_START_LEN_LIST_SIZE];
+	u32	fw_debug;
 };
 
 /* The L4 pseudo checksum mode for Ethernet */
@@ -168,13 +230,26 @@ struct eth_slow_path_rx_cqe {
 	u8	type;
 	u8	ramrod_cmd_id;
 	u8	error_flag;
-	u8	reserved[27];
+	u8	reserved[25];
 	__le16	echo;
+	u8	reserved1;
+	u8	flags;
+/* for PMD mode - valid indication */
+#define ETH_SLOW_PATH_RX_CQE_VALID_MASK         0x1
+#define ETH_SLOW_PATH_RX_CQE_VALID_SHIFT        0
+/* for PMD mode - valid toggle indication */
+#define ETH_SLOW_PATH_RX_CQE_VALID_TOGGLE_MASK  0x1
+#define ETH_SLOW_PATH_RX_CQE_VALID_TOGGLE_SHIFT 1
+#define ETH_SLOW_PATH_RX_CQE_RESERVED2_MASK     0x3F
+#define ETH_SLOW_PATH_RX_CQE_RESERVED2_SHIFT    2
 };
 
 /* union for all ETH Rx CQE types */
 union eth_rx_cqe {
 	struct eth_fast_path_rx_reg_cqe		fast_path_regular;
+	struct eth_fast_path_rx_tpa_start_cqe	fast_path_tpa_start;
+	struct eth_fast_path_rx_tpa_cont_cqe	fast_path_tpa_cont;
+	struct eth_fast_path_rx_tpa_end_cqe	fast_path_tpa_end;
 	struct eth_slow_path_rx_cqe		slow_path;
 };
 
@@ -183,15 +258,18 @@ enum eth_rx_cqe_type {
 	ETH_RX_CQE_TYPE_UNUSED,
 	ETH_RX_CQE_TYPE_REGULAR,
 	ETH_RX_CQE_TYPE_SLOW_PATH,
+	ETH_RX_CQE_TYPE_TPA_START,
+	ETH_RX_CQE_TYPE_TPA_CONT,
+	ETH_RX_CQE_TYPE_TPA_END,
 	MAX_ETH_RX_CQE_TYPE
 };
 
 /* ETH Rx producers data */
 struct eth_rx_prod_data {
 	__le16	bd_prod;
-	__le16	sge_prod;
 	__le16	cqe_prod;
 	__le16	reserved;
+	__le16	reserved1;
 };
 
 /* The first tx bd of a given packet */
@@ -211,12 +289,17 @@ struct eth_tx_2nd_bd {
 /* The parsing information data for the third tx bd of a given packet. */
 struct eth_tx_data_3rd_bd {
 	__le16	lso_mss;
-	u8	bitfields;
+	__le16	bitfields;
 #define ETH_TX_DATA_3RD_BD_TCP_HDR_LEN_DW_MASK  0xF
 #define ETH_TX_DATA_3RD_BD_TCP_HDR_LEN_DW_SHIFT 0
 #define ETH_TX_DATA_3RD_BD_HDR_NBD_MASK         0xF
 #define ETH_TX_DATA_3RD_BD_HDR_NBD_SHIFT        4
-	u8	resereved0[3];
+#define ETH_TX_DATA_3RD_BD_START_BD_MASK        0x1
+#define ETH_TX_DATA_3RD_BD_START_BD_SHIFT       8
+#define ETH_TX_DATA_3RD_BD_RESERVED0_MASK       0x7F
+#define ETH_TX_DATA_3RD_BD_RESERVED0_SHIFT      9
+	u8	tunn_l4_hdr_start_offset_w;
+	u8	tunn_hdr_size_w;
 };
 
 /* The third tx bd of a given packet */
@@ -226,12 +309,24 @@ struct eth_tx_3rd_bd {
 	struct eth_tx_data_3rd_bd	data;
 };
 
+/* Complementary information for the regular tx bd of a given packet. */
+struct eth_tx_data_bd {
+	__le16	reserved0;
+	__le16	bitfields;
+#define ETH_TX_DATA_BD_RESERVED1_MASK  0xFF
+#define ETH_TX_DATA_BD_RESERVED1_SHIFT 0
+#define ETH_TX_DATA_BD_START_BD_MASK   0x1
+#define ETH_TX_DATA_BD_START_BD_SHIFT  8
+#define ETH_TX_DATA_BD_RESERVED2_MASK  0x7F
+#define ETH_TX_DATA_BD_RESERVED2_SHIFT 9
+	__le16 reserved3;
+};
+
 /* The common non-special TX BD ring element */
 struct eth_tx_bd {
 	struct regpair	addr;
 	__le16		nbytes;
-	__le16		reserved0;
-	__le32		reserved1;
+	struct eth_tx_data_bd	data;
 };
 
 union eth_tx_bd_types {
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index d4a32e8..3d43c1d 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -80,7 +80,7 @@ struct qed_dev_info {
 	u8		num_hwfns;
 
 	u8		hw_mac[ETH_ALEN];
-	bool		is_mf;
+	bool		is_mf_default;
 
 	/* FW version */
 	u16		fw_major;
@@ -360,6 +360,12 @@ enum DP_MODULE {
 	/* to be added...up to 0x8000000 */
 };
 
+enum qed_mf_mode {
+	QED_MF_DEFAULT,
+	QED_MF_OVLAN,
+	QED_MF_NPAR,
+};
+
 struct qed_eth_stats {
 	u64	no_buff_discards;
 	u64	packet_too_big_discard;
-- 
1.8.3.1
