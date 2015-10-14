From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next v6 07/10] qed: Add link support
Date: Wed, 14 Oct 2015 09:24:11 +0300
Message-ID: <1444803854-1319-8-git-send-email-Yuval.Mintz@qlogic.com>
References: <1444803854-1319-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, <Yuval.Mintz@qlogic.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:51822 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752025AbbJNGZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 02:25:26 -0400
Received: from pps.filterd (m0045602.ppops.net [127.0.0.1])
	by mx0a-0016ce01.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id t9E6Mv9E008564
	for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 23:25:25 -0700
Received: from avcashub1.qlogic.com (avcashub2.qlogic.com [198.70.193.116])
	by mx0a-0016ce01.pphosted.com with ESMTP id 1xhhh480h8-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 23:25:25 -0700
In-Reply-To: <1444803854-1319-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Physical link is handled by the management Firmware.
This patch lays the infrastructure for attention handling in the driver,
as link change notifications arrive via async. attentions,
as well the handling of such notifications.

This patch also extends the API with the protocol drivers by adding registered
callbacks which the protocol driver passes to qed in order to be notified
of async. events originating from the FW/HW.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h      |  20 ++
 drivers/net/ethernet/qlogic/qed/qed_dev.c  | 106 ++++++++-
 drivers/net/ethernet/qlogic/qed/qed_int.c  | 336 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_l2.c   |   9 +
 drivers/net/ethernet/qlogic/qed/qed_main.c | 211 ++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c  | 295 +++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h  | 126 ++++++++++-
 include/linux/qed/qed_eth_if.h             |   4 +
 8 files changed, 1102 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index e82fef1..b046f55 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -107,6 +107,18 @@ enum QED_FEATURE {
 	QED_MAX_FEATURES,
 };
 
+enum QED_PORT_MODE {
+	QED_PORT_MODE_DE_2X40G,
+	QED_PORT_MODE_DE_2X50G,
+	QED_PORT_MODE_DE_1X100G,
+	QED_PORT_MODE_DE_4X10G_F,
+	QED_PORT_MODE_DE_4X10G_E,
+	QED_PORT_MODE_DE_4X20G,
+	QED_PORT_MODE_DE_1X40G,
+	QED_PORT_MODE_DE_2X25G,
+	QED_PORT_MODE_DE_1X25G
+};
+
 struct qed_hw_info {
 	/* PCI personality */
 	enum qed_pci_personality	personality;
@@ -403,6 +415,13 @@ struct qed_dev {
 	u8				protocol;
 #define IS_QED_ETH_IF(cdev)     ((cdev)->protocol == QED_PROTOCOL_ETH)
 
+	/* Callbacks to protocol driver */
+	union {
+		struct qed_common_cb_ops	*common;
+		struct qed_eth_cb_ops		*eth;
+	} protocol_ops;
+	void				*ops_cookie;
+
 	const struct firmware		*firmware;
 };
 
@@ -452,6 +471,7 @@ static inline u8 qed_concrete_to_sw_fid(struct qed_dev *cdev,
 /* Prototypes */
 int qed_fill_dev_info(struct qed_dev		*cdev,
 		      struct qed_dev_info	*dev_info);
+void qed_link_update(struct qed_hwfn *hwfn);
 u32 qed_unzip_data(struct qed_hwfn *p_hwfn,
 		   u32 input_len, u8 *input_buf,
 		   u32 max_size, u8 *unzip_buf);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 200cde2..079cbfa 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1034,8 +1034,9 @@ static void qed_hw_get_resc(struct qed_hwfn *p_hwfn)
 static int qed_hw_get_nvm_info(struct qed_hwfn	*p_hwfn,
 			       struct qed_ptt	*p_ptt)
 {
-	u32 nvm_cfg1_offset, mf_mode, addr, generic_cont0, nvm_cfg_addr;
-	u32 val;
+	u32 nvm_cfg1_offset, mf_mode, addr, generic_cont0, core_cfg;
+	u32 port_cfg_addr, link_temp, val, nvm_cfg_addr;
+	struct qed_mcp_link_params *link;
 
 	/* Read global nvm_cfg address */
 	nvm_cfg_addr = qed_rd(p_hwfn, p_ptt, MISC_REG_GEN_PURP_CR0);
@@ -1055,6 +1056,48 @@ static int qed_hw_get_nvm_info(struct qed_hwfn	*p_hwfn,
 	       offsetof(struct nvm_cfg1_glob, pci_id);
 	p_hwfn->hw_info.vendor_id = qed_rd(p_hwfn, p_ptt, addr) &
 				    NVM_CFG1_GLOB_VENDOR_ID_MASK;
+
+	addr = MCP_REG_SCRATCH + nvm_cfg1_offset +
+	       offsetof(struct nvm_cfg1, glob) +
+	       offsetof(struct nvm_cfg1_glob, core_cfg);
+
+	core_cfg = qed_rd(p_hwfn, p_ptt, addr);
+
+	switch ((core_cfg & NVM_CFG1_GLOB_NETWORK_PORT_MODE_MASK) >>
+		NVM_CFG1_GLOB_NETWORK_PORT_MODE_OFFSET) {
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_2X40G:
+		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_2X40G;
+		break;
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_2X50G:
+		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_2X50G;
+		break;
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_1X100G:
+		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_1X100G;
+		break;
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_4X10G_F:
+		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_4X10G_F;
+		break;
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_4X10G_E:
+		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_4X10G_E;
+		break;
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_4X20G:
+		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_4X20G;
+		break;
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_1X40G:
+		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_1X40G;
+		break;
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_2X25G:
+		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_2X25G;
+		break;
+	case NVM_CFG1_GLOB_NETWORK_PORT_MODE_DE_1X25G:
+		p_hwfn->hw_info.port_mode = QED_PORT_MODE_DE_1X25G;
+		break;
+	default:
+		DP_NOTICE(p_hwfn, "Unknown port mode in 0x%08x\n",
+			  core_cfg);
+		break;
+	}
+
 	addr = MCP_REG_SCRATCH + nvm_cfg1_offset +
 	       offsetof(struct nvm_cfg1, func[MCP_PF_ID(p_hwfn)]) +
 	       offsetof(struct nvm_cfg1_func, device_id);
@@ -1070,6 +1113,65 @@ static int qed_hw_get_nvm_info(struct qed_hwfn	*p_hwfn,
 			NVM_CFG1_FUNC_VENDOR_DEVICE_ID_OFFSET;
 	}
 
+	/* Read default link configuration */
+	link = &p_hwfn->mcp_info->link_input;
+	port_cfg_addr = MCP_REG_SCRATCH + nvm_cfg1_offset +
+			offsetof(struct nvm_cfg1, port[MFW_PORT(p_hwfn)]);
+	link_temp = qed_rd(p_hwfn, p_ptt,
+			   port_cfg_addr +
+			   offsetof(struct nvm_cfg1_port, speed_cap_mask));
+	link->speed.advertised_speeds =
+		link_temp & NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_MASK;
+
+	p_hwfn->mcp_info->link_capabilities.speed_capabilities =
+						link->speed.advertised_speeds;
+
+	link_temp = qed_rd(p_hwfn, p_ptt,
+			   port_cfg_addr +
+			   offsetof(struct nvm_cfg1_port, link_settings));
+	switch ((link_temp & NVM_CFG1_PORT_DRV_LINK_SPEED_MASK) >>
+		NVM_CFG1_PORT_DRV_LINK_SPEED_OFFSET) {
+	case NVM_CFG1_PORT_DRV_LINK_SPEED_AUTONEG:
+		link->speed.autoneg = true;
+		break;
+	case NVM_CFG1_PORT_DRV_LINK_SPEED_1G:
+		link->speed.forced_speed = 1000;
+		break;
+	case NVM_CFG1_PORT_DRV_LINK_SPEED_10G:
+		link->speed.forced_speed = 10000;
+		break;
+	case NVM_CFG1_PORT_DRV_LINK_SPEED_25G:
+		link->speed.forced_speed = 25000;
+		break;
+	case NVM_CFG1_PORT_DRV_LINK_SPEED_40G:
+		link->speed.forced_speed = 40000;
+		break;
+	case NVM_CFG1_PORT_DRV_LINK_SPEED_50G:
+		link->speed.forced_speed = 50000;
+		break;
+	case NVM_CFG1_PORT_DRV_LINK_SPEED_100G:
+		link->speed.forced_speed = 100000;
+		break;
+	default:
+		DP_NOTICE(p_hwfn, "Unknown Speed in 0x%08x\n",
+			  link_temp);
+	}
+
+	link_temp &= NVM_CFG1_PORT_DRV_FLOW_CONTROL_MASK;
+	link_temp >>= NVM_CFG1_PORT_DRV_FLOW_CONTROL_OFFSET;
+	link->pause.autoneg = !!(link_temp &
+				 NVM_CFG1_PORT_DRV_FLOW_CONTROL_AUTONEG);
+	link->pause.forced_rx = !!(link_temp &
+				   NVM_CFG1_PORT_DRV_FLOW_CONTROL_RX);
+	link->pause.forced_tx = !!(link_temp &
+				   NVM_CFG1_PORT_DRV_FLOW_CONTROL_TX);
+	link->loopback_mode = 0;
+
+	DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
+		   "Read default link: Speed 0x%08x, Adv. Speed 0x%08x, AN: 0x%02x, PAUSE AN: 0x%02x\n",
+		   link->speed.forced_speed, link->speed.advertised_speeds,
+		   link->speed.autoneg, link->pause.autoneg);
+
 	/* Read Multi-function information from shmem */
 	addr = MCP_REG_SCRATCH + nvm_cfg1_offset +
 	       offsetof(struct nvm_cfg1, glob) +
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index 2fff2e1..ccbaec9 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -39,10 +39,214 @@ struct qed_sb_sp_info {
 	struct qed_pi_info	pi_info_arr[PIS_PER_SB];
 };
 
+#define SB_ATTN_ALIGNED_SIZE(p_hwfn) \
+	ALIGNED_TYPE_SIZE(struct atten_status_block, p_hwfn)
+
+#define ATTN_STATE_BITS (0xfff)
+#define ATTN_BITS_MASKABLE      (0x3ff)
+struct qed_sb_attn_info {
+	/* Virtual & Physical address of the SB */
+	struct atten_status_block       *sb_attn;
+	dma_addr_t		      sb_phys;
+
+	/* Last seen running index */
+	u16			     index;
+
+	/* Previously asserted attentions, which are still unasserted */
+	u16			     known_attn;
+
+	/* Cleanup address for the link's general hw attention */
+	u32			     mfw_attn_addr;
+};
+
+static inline u16 qed_attn_update_idx(struct qed_hwfn	   *p_hwfn,
+				      struct qed_sb_attn_info   *p_sb_desc)
+{
+	u16     rc = 0;
+	u16     index;
+
+	/* Make certain HW write took affect */
+	mmiowb();
+
+	index = le16_to_cpu(p_sb_desc->sb_attn->sb_index);
+	if (p_sb_desc->index != index) {
+		p_sb_desc->index	= index;
+		rc		      = QED_SB_ATT_IDX;
+	}
+
+	/* Make certain we got a consistent view with HW */
+	mmiowb();
+
+	return rc;
+}
+
+/**
+ *  @brief qed_int_assertion - handles asserted attention bits
+ *
+ *  @param p_hwfn
+ *  @param asserted_bits newly asserted bits
+ *  @return int
+ */
+static int qed_int_assertion(struct qed_hwfn    *p_hwfn,
+			     u16		asserted_bits)
+{
+	struct qed_sb_attn_info *sb_attn_sw = p_hwfn->p_sb_attn;
+	u32		     igu_mask;
+
+	/* Mask the source of the attention in the IGU */
+	igu_mask = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+			  IGU_REG_ATTENTION_ENABLE);
+	DP_VERBOSE(p_hwfn, NETIF_MSG_INTR, "IGU mask: 0x%08x --> 0x%08x\n",
+		   igu_mask, igu_mask & ~(asserted_bits & ATTN_BITS_MASKABLE));
+	igu_mask &= ~(asserted_bits & ATTN_BITS_MASKABLE);
+	qed_wr(p_hwfn, p_hwfn->p_dpc_ptt, IGU_REG_ATTENTION_ENABLE, igu_mask);
+
+	DP_VERBOSE(p_hwfn, NETIF_MSG_INTR,
+		   "inner known ATTN state: 0x%04x --> 0x%04x\n",
+		   sb_attn_sw->known_attn,
+		   sb_attn_sw->known_attn | asserted_bits);
+	sb_attn_sw->known_attn |= asserted_bits;
+
+	/* Handle MCP events */
+	if (asserted_bits & 0x100) {
+		qed_mcp_handle_events(p_hwfn, p_hwfn->p_dpc_ptt);
+		/* Clean the MCP attention */
+		qed_wr(p_hwfn, p_hwfn->p_dpc_ptt,
+		       sb_attn_sw->mfw_attn_addr, 0);
+	}
+
+	DIRECT_REG_WR((u8 __iomem *)p_hwfn->regview +
+		      GTT_BAR0_MAP_REG_IGU_CMD +
+		      ((IGU_CMD_ATTN_BIT_SET_UPPER -
+			IGU_CMD_INT_ACK_BASE) << 3),
+		      (u32)asserted_bits);
+
+	DP_VERBOSE(p_hwfn, NETIF_MSG_INTR, "set cmd IGU: 0x%04x\n",
+		   asserted_bits);
+
+	return 0;
+}
+
+/**
+ * @brief - handles deassertion of previously asserted attentions.
+ *
+ * @param p_hwfn
+ * @param deasserted_bits - newly deasserted bits
+ * @return int
+ *
+ */
+static int qed_int_deassertion(struct qed_hwfn  *p_hwfn,
+			       u16	      deasserted_bits)
+{
+	struct qed_sb_attn_info *sb_attn_sw = p_hwfn->p_sb_attn;
+	u32 aeu_mask;
+
+	if (deasserted_bits != 0x100)
+		DP_ERR(p_hwfn, "Unexpected - non-link deassertion\n");
+
+	/* Clear IGU indication for the deasserted bits */
+	DIRECT_REG_WR((u8 __iomem *)p_hwfn->regview +
+		      GTT_BAR0_MAP_REG_IGU_CMD +
+		      ((IGU_CMD_ATTN_BIT_CLR_UPPER -
+			IGU_CMD_INT_ACK_BASE) << 3),
+		      ~((u32)deasserted_bits));
+
+	/* Unmask deasserted attentions in IGU */
+	aeu_mask = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+			  IGU_REG_ATTENTION_ENABLE);
+	aeu_mask |= (deasserted_bits & ATTN_BITS_MASKABLE);
+	qed_wr(p_hwfn, p_hwfn->p_dpc_ptt, IGU_REG_ATTENTION_ENABLE, aeu_mask);
+
+	/* Clear deassertion from inner state */
+	sb_attn_sw->known_attn &= ~deasserted_bits;
+
+	return 0;
+}
+
+static int qed_int_attentions(struct qed_hwfn *p_hwfn)
+{
+	struct qed_sb_attn_info	 *p_sb_attn_sw = p_hwfn->p_sb_attn;
+	struct atten_status_block *p_sb_attn = p_sb_attn_sw->sb_attn;
+	u32 attn_bits = 0, attn_acks = 0;
+	u16 asserted_bits, deasserted_bits;
+	__le16 index;
+	int rc = 0;
+
+	/* Read current attention bits/acks - safeguard against attentions
+	 * by guaranting work on a synchronized timeframe
+	 */
+	do {
+		index = p_sb_attn->sb_index;
+		attn_bits = le32_to_cpu(p_sb_attn->atten_bits);
+		attn_acks = le32_to_cpu(p_sb_attn->atten_ack);
+	} while (index != p_sb_attn->sb_index);
+	p_sb_attn->sb_index = index;
+
+	/* Attention / Deassertion are meaningful (and in correct state)
+	 * only when they differ and consistent with known state - deassertion
+	 * when previous attention & current ack, and assertion when current
+	 * attention with no previous attention
+	 */
+	asserted_bits = (attn_bits & ~attn_acks & ATTN_STATE_BITS) &
+		~p_sb_attn_sw->known_attn;
+	deasserted_bits = (~attn_bits & attn_acks & ATTN_STATE_BITS) &
+		p_sb_attn_sw->known_attn;
+
+	if ((asserted_bits & ~0x100) || (deasserted_bits & ~0x100)) {
+		DP_INFO(p_hwfn,
+			"Attention: Index: 0x%04x, Bits: 0x%08x, Acks: 0x%08x, asserted: 0x%04x, De-asserted 0x%04x [Prev. known: 0x%04x]\n",
+			index, attn_bits, attn_acks, asserted_bits,
+			deasserted_bits, p_sb_attn_sw->known_attn);
+	} else if (asserted_bits == 0x100) {
+		DP_INFO(p_hwfn,
+			"MFW indication via attention\n");
+	} else {
+		DP_VERBOSE(p_hwfn, NETIF_MSG_INTR,
+			   "MFW indication [deassertion]\n");
+	}
+
+	if (asserted_bits) {
+		rc = qed_int_assertion(p_hwfn, asserted_bits);
+		if (rc)
+			return rc;
+	}
+
+	if (deasserted_bits) {
+		rc = qed_int_deassertion(p_hwfn, deasserted_bits);
+		if (rc)
+			return rc;
+	}
+
+	return rc;
+}
+
+static void qed_sb_ack_attn(struct qed_hwfn     *p_hwfn,
+			    void __iomem	*igu_addr,
+			    u32		 ack_cons)
+{
+	struct igu_prod_cons_update igu_ack = { 0 };
+
+	igu_ack.sb_id_and_flags =
+		((ack_cons << IGU_PROD_CONS_UPDATE_SB_INDEX_SHIFT) |
+		 (1 << IGU_PROD_CONS_UPDATE_UPDATE_FLAG_SHIFT) |
+		 (IGU_INT_NOP << IGU_PROD_CONS_UPDATE_ENABLE_INT_SHIFT) |
+		 (IGU_SEG_ACCESS_ATTN <<
+		  IGU_PROD_CONS_UPDATE_SEGMENT_ACCESS_SHIFT));
+
+	DIRECT_REG_WR(igu_addr, igu_ack.sb_id_and_flags);
+
+	/* Both segments (interrupts & acks) are written to same place address;
+	 * Need to guarantee all commands will be received (in-order) by HW.
+	 */
+	mmiowb();
+	barrier();
+}
+
 void qed_int_sp_dpc(unsigned long hwfn_cookie)
 {
 	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)hwfn_cookie;
 	struct qed_pi_info *pi_info = NULL;
+	struct qed_sb_attn_info *sb_attn;
 	struct qed_sb_info *sb_info;
 	int arr_size;
 	u16 rc = 0;
@@ -65,6 +269,12 @@ void qed_int_sp_dpc(unsigned long hwfn_cookie)
 		return;
 	}
 
+	if (!p_hwfn->p_sb_attn) {
+		DP_ERR(p_hwfn->cdev, "DPC called - no p_sb_attn");
+		return;
+	}
+	sb_attn = p_hwfn->p_sb_attn;
+
 	DP_VERBOSE(p_hwfn, NETIF_MSG_INTR, "DPC Called! (hwfn %p %d)\n",
 		   p_hwfn, p_hwfn->my_id);
 
@@ -87,6 +297,19 @@ void qed_int_sp_dpc(unsigned long hwfn_cookie)
 			   tmp_index, sb_info->sb_ack);
 	}
 
+	if (!sb_attn || !sb_attn->sb_attn) {
+		DP_ERR(
+			p_hwfn->cdev,
+			"Attentions Status block is NULL - cannot check for new attentions!\n");
+	} else {
+		u16 tmp_index = sb_attn->index;
+
+		rc |= qed_attn_update_idx(p_hwfn, sb_attn);
+		DP_VERBOSE(p_hwfn->cdev, NETIF_MSG_INTR,
+			   "Attention indices: 0x%08x --> 0x%08x\n",
+			   tmp_index, sb_attn->index);
+	}
+
 	/* Check if we expect interrupts at this time. if not just ack them */
 	if (!(rc & QED_SB_EVENT_MASK)) {
 		qed_sb_ack(sb_info, IGU_INT_ENABLE, 1);
@@ -100,6 +323,9 @@ void qed_int_sp_dpc(unsigned long hwfn_cookie)
 		return;
 	}
 
+	if (rc & QED_SB_ATT_IDX)
+		qed_int_attentions(p_hwfn);
+
 	if (rc & QED_SB_IDX) {
 		int pi;
 
@@ -111,9 +337,97 @@ void qed_int_sp_dpc(unsigned long hwfn_cookie)
 		}
 	}
 
+	if (sb_attn && (rc & QED_SB_ATT_IDX))
+		/* This should be done before the interrupts are enabled,
+		 * since otherwise a new attention will be generated.
+		 */
+		qed_sb_ack_attn(p_hwfn, sb_info->igu_addr, sb_attn->index);
+
 	qed_sb_ack(sb_info, IGU_INT_ENABLE, 1);
 }
 
+static void qed_int_sb_attn_free(struct qed_hwfn *p_hwfn)
+{
+	struct qed_dev	  *cdev   = p_hwfn->cdev;
+	struct qed_sb_attn_info *p_sb   = p_hwfn->p_sb_attn;
+
+	if (p_sb) {
+		if (p_sb->sb_attn)
+			dma_free_coherent(&cdev->pdev->dev,
+					  SB_ATTN_ALIGNED_SIZE(p_hwfn),
+					  p_sb->sb_attn,
+					  p_sb->sb_phys);
+		kfree(p_sb);
+	}
+}
+
+static void qed_int_sb_attn_setup(struct qed_hwfn       *p_hwfn,
+				  struct qed_ptt	*p_ptt)
+{
+	struct qed_sb_attn_info *sb_info = p_hwfn->p_sb_attn;
+
+	memset(sb_info->sb_attn, 0, sizeof(*sb_info->sb_attn));
+
+	sb_info->index	  = 0;
+	sb_info->known_attn     = 0;
+
+	/* Configure Attention Status Block in IGU */
+	qed_wr(p_hwfn, p_ptt, IGU_REG_ATTN_MSG_ADDR_L,
+	       lower_32_bits(p_hwfn->p_sb_attn->sb_phys));
+	qed_wr(p_hwfn, p_ptt, IGU_REG_ATTN_MSG_ADDR_H,
+	       upper_32_bits(p_hwfn->p_sb_attn->sb_phys));
+}
+
+static void qed_int_sb_attn_init(struct qed_hwfn *p_hwfn,
+				 struct qed_ptt	 *p_ptt,
+				 void		 *sb_virt_addr,
+				 dma_addr_t	 sb_phy_addr)
+{
+	struct qed_sb_attn_info *sb_info = p_hwfn->p_sb_attn;
+
+	sb_info->sb_attn = sb_virt_addr;
+	sb_info->sb_phys = sb_phy_addr;
+
+	/* Set the address of cleanup for the mcp attention */
+	sb_info->mfw_attn_addr = (p_hwfn->rel_pf_id << 3) +
+				 MISC_REG_AEU_GENERAL_ATTN_0;
+
+	qed_int_sb_attn_setup(p_hwfn, p_ptt);
+}
+
+static int qed_int_sb_attn_alloc(struct qed_hwfn *p_hwfn,
+				 struct qed_ptt	 *p_ptt)
+{
+	struct qed_dev	  *cdev = p_hwfn->cdev;
+	struct qed_sb_attn_info *p_sb;
+	void		    *p_virt;
+	dma_addr_t	      p_phys = 0;
+
+	/* SB struct */
+	p_sb = kmalloc(sizeof(*p_sb), GFP_ATOMIC);
+	if (!p_sb) {
+		DP_NOTICE(cdev, "Failed to allocate `struct qed_sb_attn_info'\n");
+		return -ENOMEM;
+	}
+
+	/* SB ring  */
+	p_virt = dma_alloc_coherent(&cdev->pdev->dev,
+				    SB_ATTN_ALIGNED_SIZE(p_hwfn),
+				    &p_phys, GFP_KERNEL);
+
+	if (!p_virt) {
+		DP_NOTICE(cdev, "Failed to allocate status block (attentions)\n");
+		kfree(p_sb);
+		return -ENOMEM;
+	}
+
+	/* Attention setup */
+	p_hwfn->p_sb_attn = p_sb;
+	qed_int_sb_attn_init(p_hwfn, p_ptt, p_virt, p_phys);
+
+	return 0;
+}
+
 /* coalescing timeout = timeset << (timer_res + 1) */
 #define QED_CAU_DEF_RX_USECS 24
 #define QED_CAU_DEF_TX_USECS 48
@@ -394,6 +708,12 @@ static void qed_int_sp_sb_setup(struct qed_hwfn *p_hwfn,
 	else
 		DP_NOTICE(p_hwfn->cdev,
 			  "Failed to setup Slow path status block - NULL pointer\n");
+
+	if (p_hwfn->p_sb_attn)
+		qed_int_sb_attn_setup(p_hwfn, p_ptt);
+	else
+		DP_NOTICE(p_hwfn->cdev,
+			  "Failed to setup attentions status block - NULL pointer\n");
 }
 
 int qed_int_register_cb(struct qed_hwfn		*p_hwfn,
@@ -444,7 +764,7 @@ void qed_int_igu_enable_int(struct qed_hwfn	*p_hwfn,
 			    struct qed_ptt	*p_ptt,
 			    enum qed_int_mode	int_mode)
 {
-	u32 igu_pf_conf = IGU_PF_CONF_FUNC_EN;
+	u32 igu_pf_conf = IGU_PF_CONF_FUNC_EN | IGU_PF_CONF_ATTN_BIT_EN;
 
 	p_hwfn->cdev->int_mode = int_mode;
 	switch (p_hwfn->cdev->int_mode) {
@@ -484,8 +804,15 @@ void qed_int_igu_enable(struct qed_hwfn		*p_hwfn,
 	/* Enable interrupt Generation */
 	qed_int_igu_enable_int(p_hwfn, p_ptt, int_mode);
 
+	/* Configure AEU signal change to produce attentions for link */
+	qed_wr(p_hwfn, p_ptt, IGU_REG_LEADING_EDGE_LATCH, 0xfff);
+	qed_wr(p_hwfn, p_ptt, IGU_REG_TRAILING_EDGE_LATCH, 0xfff);
+
 	/* Flush the writes to IGU */
 	mmiowb();
+
+	/* Unmask AEU signals toward IGU */
+	qed_wr(p_hwfn, p_ptt, MISC_REG_AEU_MASK_ATTN_IGU, 0xff);
 }
 
 void qed_int_igu_disable_int(struct qed_hwfn	*p_hwfn,
@@ -770,13 +1097,18 @@ int qed_int_alloc(struct qed_hwfn	*p_hwfn,
 		DP_ERR(p_hwfn->cdev, "Failed to allocate sp sb mem\n");
 		return rc;
 	}
-
+	rc = qed_int_sb_attn_alloc(p_hwfn, p_ptt);
+	if (rc) {
+		DP_ERR(p_hwfn->cdev, "Failed to allocate sb attn mem\n");
+		return rc;
+	}
 	return rc;
 }
 
 void qed_int_free(struct qed_hwfn *p_hwfn)
 {
 	qed_int_sp_sb_free(p_hwfn);
+	qed_int_sb_attn_free(p_hwfn);
 	qed_int_sp_dpc_free(p_hwfn);
 }
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 5f51512..108ef7f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -1304,6 +1304,14 @@ static int qed_fill_eth_dev_info(struct qed_dev *cdev,
 	return 0;
 }
 
+static void qed_register_eth_ops(struct qed_dev		*cdev,
+				 struct qed_eth_cb_ops	*ops,
+				 void			*cookie)
+{
+	cdev->protocol_ops.eth	= ops;
+	cdev->ops_cookie	= cookie;
+}
+
 static int qed_start_vport(struct qed_dev	*cdev,
 			   u8			vport_id,
 			   u16			mtu,
@@ -1716,6 +1724,7 @@ static int qed_fp_cqe_completion(struct qed_dev			*dev,
 static const struct qed_eth_ops qed_eth_ops_pass = {
 	.common = &qed_common_ops_pass,
 	.fill_dev_info = &qed_fill_eth_dev_info,
+	.register_ops = &qed_register_eth_ops,
 	.vport_start = &qed_start_vport,
 	.vport_stop = &qed_stop_vport,
 	.vport_update = &qed_update_vport,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 1eb8c1b..fb9c5a1 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -904,6 +904,215 @@ static u32 qed_sb_release(struct qed_dev *cdev,
 	return rc;
 }
 
+static int qed_set_link(struct qed_dev *cdev,
+			struct qed_link_params *params)
+{
+	struct qed_hwfn *hwfn;
+	struct qed_mcp_link_params *link_params;
+	struct qed_ptt *ptt;
+	int rc;
+
+	if (!cdev)
+		return -ENODEV;
+
+	/* The link should be set only once per PF */
+	hwfn = &cdev->hwfns[0];
+
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt)
+		return -EBUSY;
+
+	link_params = qed_mcp_get_link_params(hwfn);
+	if (params->override_flags & QED_LINK_OVERRIDE_SPEED_AUTONEG)
+		link_params->speed.autoneg = params->autoneg;
+	if (params->override_flags & QED_LINK_OVERRIDE_SPEED_ADV_SPEEDS) {
+		link_params->speed.advertised_speeds = 0;
+		if ((params->adv_speeds & SUPPORTED_1000baseT_Half) ||
+		    (params->adv_speeds & SUPPORTED_1000baseT_Full))
+			link_params->speed.advertised_speeds |=
+				NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_1G;
+		if (params->adv_speeds & SUPPORTED_10000baseKR_Full)
+			link_params->speed.advertised_speeds |=
+				NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_10G;
+		if (params->adv_speeds & SUPPORTED_40000baseLR4_Full)
+			link_params->speed.advertised_speeds |=
+				NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_40G;
+		if (params->adv_speeds & 0)
+			link_params->speed.advertised_speeds |=
+				NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_50G;
+		if (params->adv_speeds & 0)
+			link_params->speed.advertised_speeds |=
+				NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_100G;
+	}
+	if (params->override_flags & QED_LINK_OVERRIDE_SPEED_FORCED_SPEED)
+		link_params->speed.forced_speed = params->forced_speed;
+
+	rc = qed_mcp_set_link(hwfn, ptt, params->link_up);
+
+	qed_ptt_release(hwfn, ptt);
+
+	return rc;
+}
+
+static int qed_get_port_type(u32 media_type)
+{
+	int port_type;
+
+	switch (media_type) {
+	case MEDIA_SFPP_10G_FIBER:
+	case MEDIA_SFP_1G_FIBER:
+	case MEDIA_XFP_FIBER:
+	case MEDIA_KR:
+		port_type = PORT_FIBRE;
+		break;
+	case MEDIA_DA_TWINAX:
+		port_type = PORT_DA;
+		break;
+	case MEDIA_BASE_T:
+		port_type = PORT_TP;
+		break;
+	case MEDIA_NOT_PRESENT:
+		port_type = PORT_NONE;
+		break;
+	case MEDIA_UNSPECIFIED:
+	default:
+		port_type = PORT_OTHER;
+		break;
+	}
+	return port_type;
+}
+
+static void qed_fill_link(struct qed_hwfn *hwfn,
+			  struct qed_link_output *if_link)
+{
+	struct qed_mcp_link_params params;
+	struct qed_mcp_link_state link;
+	struct qed_mcp_link_capabilities link_caps;
+	u32 media_type;
+
+	memset(if_link, 0, sizeof(*if_link));
+
+	/* Prepare source inputs */
+	memcpy(&params, qed_mcp_get_link_params(hwfn), sizeof(params));
+	memcpy(&link, qed_mcp_get_link_state(hwfn), sizeof(link));
+	memcpy(&link_caps, qed_mcp_get_link_capabilities(hwfn),
+	       sizeof(link_caps));
+
+	/* Set the link parameters to pass to protocol driver */
+	if (link.link_up)
+		if_link->link_up = true;
+
+	/* TODO - at the moment assume supported and advertised speed equal */
+	if_link->supported_caps = SUPPORTED_FIBRE;
+	if (params.speed.autoneg)
+		if_link->supported_caps |= SUPPORTED_Autoneg;
+	if (params.pause.autoneg ||
+	    (params.pause.forced_rx && params.pause.forced_tx))
+		if_link->supported_caps |= SUPPORTED_Asym_Pause;
+	if (params.pause.autoneg || params.pause.forced_rx ||
+	    params.pause.forced_tx)
+		if_link->supported_caps |= SUPPORTED_Pause;
+
+	if_link->advertised_caps = if_link->supported_caps;
+	if (params.speed.advertised_speeds &
+	    NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_1G)
+		if_link->advertised_caps |= SUPPORTED_1000baseT_Half |
+					   SUPPORTED_1000baseT_Full;
+	if (params.speed.advertised_speeds &
+	    NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_10G)
+		if_link->advertised_caps |= SUPPORTED_10000baseKR_Full;
+	if (params.speed.advertised_speeds &
+		NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_40G)
+		if_link->advertised_caps |= SUPPORTED_40000baseLR4_Full;
+	if (params.speed.advertised_speeds &
+		NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_50G)
+		if_link->advertised_caps |= 0;
+	if (params.speed.advertised_speeds &
+		NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_100G)
+		if_link->advertised_caps |= 0;
+
+	if (link_caps.speed_capabilities &
+	    NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_1G)
+		if_link->supported_caps |= SUPPORTED_1000baseT_Half |
+					   SUPPORTED_1000baseT_Full;
+	if (link_caps.speed_capabilities &
+	    NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_10G)
+		if_link->supported_caps |= SUPPORTED_10000baseKR_Full;
+	if (link_caps.speed_capabilities &
+		NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_40G)
+		if_link->supported_caps |= SUPPORTED_40000baseLR4_Full;
+	if (link_caps.speed_capabilities &
+		NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_50G)
+		if_link->supported_caps |= 0;
+	if (link_caps.speed_capabilities &
+		NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_100G)
+		if_link->supported_caps |= 0;
+
+	if (link.link_up)
+		if_link->speed = link.speed;
+
+	/* TODO - fill duplex properly */
+	if_link->duplex = DUPLEX_FULL;
+	qed_mcp_get_media_type(hwfn->cdev, &media_type);
+	if_link->port = qed_get_port_type(media_type);
+
+	if_link->autoneg = params.speed.autoneg;
+
+	if (params.pause.autoneg)
+		if_link->pause_config |= QED_LINK_PAUSE_AUTONEG_ENABLE;
+	if (params.pause.forced_rx)
+		if_link->pause_config |= QED_LINK_PAUSE_RX_ENABLE;
+	if (params.pause.forced_tx)
+		if_link->pause_config |= QED_LINK_PAUSE_TX_ENABLE;
+
+	/* Link partner capabilities */
+	if (link.partner_adv_speed &
+	    QED_LINK_PARTNER_SPEED_1G_HD)
+		if_link->lp_caps |= SUPPORTED_1000baseT_Half;
+	if (link.partner_adv_speed &
+	    QED_LINK_PARTNER_SPEED_1G_FD)
+		if_link->lp_caps |= SUPPORTED_1000baseT_Full;
+	if (link.partner_adv_speed &
+	    QED_LINK_PARTNER_SPEED_10G)
+		if_link->lp_caps |= SUPPORTED_10000baseKR_Full;
+	if (link.partner_adv_speed &
+	    QED_LINK_PARTNER_SPEED_40G)
+		if_link->lp_caps |= SUPPORTED_40000baseLR4_Full;
+	if (link.partner_adv_speed &
+	    QED_LINK_PARTNER_SPEED_50G)
+		if_link->lp_caps |= 0;
+	if (link.partner_adv_speed &
+	    QED_LINK_PARTNER_SPEED_100G)
+		if_link->lp_caps |= 0;
+
+	if (link.an_complete)
+		if_link->lp_caps |= SUPPORTED_Autoneg;
+
+	if (link.partner_adv_pause)
+		if_link->lp_caps |= SUPPORTED_Pause;
+	if (link.partner_adv_pause == QED_LINK_PARTNER_ASYMMETRIC_PAUSE ||
+	    link.partner_adv_pause == QED_LINK_PARTNER_BOTH_PAUSE)
+		if_link->lp_caps |= SUPPORTED_Asym_Pause;
+}
+
+static void qed_get_current_link(struct qed_dev *cdev,
+				 struct qed_link_output *if_link)
+{
+	qed_fill_link(&cdev->hwfns[0], if_link);
+}
+
+void qed_link_update(struct qed_hwfn *hwfn)
+{
+	void *cookie = hwfn->cdev->ops_cookie;
+	struct qed_common_cb_ops *op = hwfn->cdev->protocol_ops.common;
+	struct qed_link_output if_link;
+
+	qed_fill_link(hwfn, &if_link);
+
+	if (IS_LEAD_HWFN(hwfn) && cookie)
+		op->link_update(cookie, &if_link);
+}
+
 static int qed_drain(struct qed_dev *cdev)
 {
 	struct qed_hwfn *hwfn;
@@ -940,6 +1149,8 @@ const struct qed_common_ops qed_common_ops_pass = {
 	.sb_release = &qed_sb_release,
 	.simd_handler_config = &qed_simd_handler_config,
 	.simd_handler_clean = &qed_simd_handler_clean,
+	.set_link = &qed_set_link,
+	.get_link = &qed_get_current_link,
 	.drain = &qed_drain,
 	.update_msglvl = &qed_init_dp,
 	.chain_alloc = &qed_chain_alloc,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 64a0bae..8a769af 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -365,6 +365,252 @@ int qed_mcp_load_req(struct qed_hwfn	*p_hwfn,
 	return 0;
 }
 
+static void qed_mcp_handle_link_change(struct qed_hwfn	*p_hwfn,
+				       struct qed_ptt	*p_ptt,
+				       bool		b_reset)
+{
+	struct qed_mcp_link_state *p_link;
+	u32 status = 0;
+
+	p_link = &p_hwfn->mcp_info->link_output;
+	memset(p_link, 0, sizeof(*p_link));
+	if (!b_reset) {
+		status = qed_rd(p_hwfn, p_ptt,
+				p_hwfn->mcp_info->port_addr +
+				offsetof(struct public_port, link_status));
+		DP_VERBOSE(p_hwfn, (NETIF_MSG_LINK | QED_MSG_SP),
+			   "Received link update [0x%08x] from mfw [Addr 0x%x]\n",
+			   status,
+			   (u32)(p_hwfn->mcp_info->port_addr +
+				 offsetof(struct public_port,
+				 link_status)));
+	} else {
+		DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
+			   "Resetting link indications\n");
+		return;
+	}
+
+	p_link->link_up = !!(status & LINK_STATUS_LINK_UP);
+
+	p_link->full_duplex = true;
+	switch ((status & LINK_STATUS_SPEED_AND_DUPLEX_MASK)) {
+	case LINK_STATUS_SPEED_AND_DUPLEX_100G:
+		p_link->speed = 100000;
+		break;
+	case LINK_STATUS_SPEED_AND_DUPLEX_50G:
+		p_link->speed = 50000;
+		break;
+	case LINK_STATUS_SPEED_AND_DUPLEX_40G:
+		p_link->speed = 40000;
+		break;
+	case LINK_STATUS_SPEED_AND_DUPLEX_25G:
+		p_link->speed = 25000;
+		break;
+	case LINK_STATUS_SPEED_AND_DUPLEX_20G:
+		p_link->speed = 20000;
+		break;
+	case LINK_STATUS_SPEED_AND_DUPLEX_10G:
+		p_link->speed = 10000;
+		break;
+	case LINK_STATUS_SPEED_AND_DUPLEX_1000THD:
+		p_link->full_duplex = false;
+	/* Fall-through */
+	case LINK_STATUS_SPEED_AND_DUPLEX_1000TFD:
+		p_link->speed = 1000;
+		break;
+	default:
+		p_link->speed = 0;
+	}
+
+	/* Correct speed according to bandwidth allocation */
+	if (p_hwfn->mcp_info->func_info.bandwidth_max && p_link->speed) {
+		p_link->speed = p_link->speed *
+				p_hwfn->mcp_info->func_info.bandwidth_max /
+				100;
+		qed_init_pf_rl(p_hwfn, p_ptt, p_hwfn->rel_pf_id,
+			       p_link->speed);
+		DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
+			   "Configured MAX bandwidth to be %08x Mb/sec\n",
+			   p_link->speed);
+	}
+
+	p_link->an = !!(status & LINK_STATUS_AUTO_NEGOTIATE_ENABLED);
+	p_link->an_complete = !!(status &
+				 LINK_STATUS_AUTO_NEGOTIATE_COMPLETE);
+	p_link->parallel_detection = !!(status &
+					LINK_STATUS_PARALLEL_DETECTION_USED);
+	p_link->pfc_enabled = !!(status & LINK_STATUS_PFC_ENABLED);
+
+	p_link->partner_adv_speed |=
+		(status & LINK_STATUS_LINK_PARTNER_1000TFD_CAPABLE) ?
+		QED_LINK_PARTNER_SPEED_1G_FD : 0;
+	p_link->partner_adv_speed |=
+		(status & LINK_STATUS_LINK_PARTNER_1000THD_CAPABLE) ?
+		QED_LINK_PARTNER_SPEED_1G_HD : 0;
+	p_link->partner_adv_speed |=
+		(status & LINK_STATUS_LINK_PARTNER_10G_CAPABLE) ?
+		QED_LINK_PARTNER_SPEED_10G : 0;
+	p_link->partner_adv_speed |=
+		(status & LINK_STATUS_LINK_PARTNER_20G_CAPABLE) ?
+		QED_LINK_PARTNER_SPEED_20G : 0;
+	p_link->partner_adv_speed |=
+		(status & LINK_STATUS_LINK_PARTNER_40G_CAPABLE) ?
+		QED_LINK_PARTNER_SPEED_40G : 0;
+	p_link->partner_adv_speed |=
+		(status & LINK_STATUS_LINK_PARTNER_50G_CAPABLE) ?
+		QED_LINK_PARTNER_SPEED_50G : 0;
+	p_link->partner_adv_speed |=
+		(status & LINK_STATUS_LINK_PARTNER_100G_CAPABLE) ?
+		QED_LINK_PARTNER_SPEED_100G : 0;
+
+	p_link->partner_tx_flow_ctrl_en =
+		!!(status & LINK_STATUS_TX_FLOW_CONTROL_ENABLED);
+	p_link->partner_rx_flow_ctrl_en =
+		!!(status & LINK_STATUS_RX_FLOW_CONTROL_ENABLED);
+
+	switch (status & LINK_STATUS_LINK_PARTNER_FLOW_CONTROL_MASK) {
+	case LINK_STATUS_LINK_PARTNER_SYMMETRIC_PAUSE:
+		p_link->partner_adv_pause = QED_LINK_PARTNER_SYMMETRIC_PAUSE;
+		break;
+	case LINK_STATUS_LINK_PARTNER_ASYMMETRIC_PAUSE:
+		p_link->partner_adv_pause = QED_LINK_PARTNER_ASYMMETRIC_PAUSE;
+		break;
+	case LINK_STATUS_LINK_PARTNER_BOTH_PAUSE:
+		p_link->partner_adv_pause = QED_LINK_PARTNER_BOTH_PAUSE;
+		break;
+	default:
+		p_link->partner_adv_pause = 0;
+	}
+
+	p_link->sfp_tx_fault = !!(status & LINK_STATUS_SFP_TX_FAULT);
+
+	qed_link_update(p_hwfn);
+}
+
+int qed_mcp_set_link(struct qed_hwfn	*p_hwfn,
+		     struct qed_ptt	*p_ptt,
+		     bool		b_up)
+{
+	struct qed_mcp_link_params *params = &p_hwfn->mcp_info->link_input;
+	u32 param = 0, reply = 0, cmd;
+	struct pmm_phy_cfg phy_cfg;
+	int rc = 0;
+	u32 i;
+
+	if (!qed_mcp_is_init(p_hwfn)) {
+		DP_NOTICE(p_hwfn, "MFW is not initialized !\n");
+		return -EBUSY;
+	}
+
+	/* Set the shmem configuration according to params */
+	memset(&phy_cfg, 0, sizeof(phy_cfg));
+	cmd = b_up ? DRV_MSG_CODE_INIT_PHY : DRV_MSG_CODE_LINK_RESET;
+	if (!params->speed.autoneg)
+		phy_cfg.speed = params->speed.forced_speed;
+	phy_cfg.pause |= (params->pause.autoneg) ? PMM_PAUSE_AUTONEG : 0;
+	phy_cfg.pause |= (params->pause.forced_rx) ? PMM_PAUSE_RX : 0;
+	phy_cfg.pause |= (params->pause.forced_tx) ? PMM_PAUSE_TX : 0;
+	phy_cfg.adv_speed	= params->speed.advertised_speeds;
+	phy_cfg.loopback_mode	= params->loopback_mode;
+
+	/* Write the requested configuration to shmem */
+	for (i = 0; i < sizeof(phy_cfg); i += 4)
+		qed_wr(p_hwfn, p_ptt,
+		       p_hwfn->mcp_info->drv_mb_addr +
+		       offsetof(struct public_drv_mb, union_data) + i,
+		       ((u32 *)&phy_cfg)[i >> 2]);
+
+	if (b_up) {
+		DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
+			   "Configuring Link: Speed 0x%08x, Pause 0x%08x, adv_speed 0x%08x, loopback 0x%08x, features 0x%08x\n",
+			   phy_cfg.speed,
+			   phy_cfg.pause,
+			   phy_cfg.adv_speed,
+			   phy_cfg.loopback_mode,
+			   phy_cfg.feature_config_flags);
+	} else {
+		DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
+			   "Resetting link\n");
+	}
+
+	DP_VERBOSE(p_hwfn, QED_MSG_SP, "fw_seq 0x%08x, drv_pulse 0x%x\n",
+		   p_hwfn->mcp_info->drv_mb_seq,
+		   p_hwfn->mcp_info->drv_pulse_seq);
+
+	/* Load Request */
+	rc = qed_mcp_cmd(p_hwfn, p_ptt, cmd, 0, &reply, &param);
+
+	/* if mcp fails to respond we must abort */
+	if (rc) {
+		DP_ERR(p_hwfn, "MCP response failure, aborting\n");
+		return rc;
+	}
+
+	/* Reset the link status if needed */
+	if (!b_up)
+		qed_mcp_handle_link_change(p_hwfn, p_ptt, true);
+
+	return 0;
+}
+
+int qed_mcp_handle_events(struct qed_hwfn	*p_hwfn,
+			  struct qed_ptt	*p_ptt)
+{
+	struct qed_mcp_info	*info	= p_hwfn->mcp_info;
+	int			rc	= 0;
+	bool			found	= false;
+	u16			i;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_SP, "Received message from MFW\n");
+
+	/* Read Messages from MFW */
+	qed_mcp_read_mb(p_hwfn, p_ptt);
+
+	/* Compare current messages to old ones */
+	for (i = 0; i < info->mfw_mb_length; i++) {
+		if (info->mfw_mb_cur[i] == info->mfw_mb_shadow[i])
+			continue;
+
+		found = true;
+
+		DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
+			   "Msg [%d] - old CMD 0x%02x, new CMD 0x%02x\n",
+			   i, info->mfw_mb_shadow[i], info->mfw_mb_cur[i]);
+
+		switch (i) {
+		case MFW_DRV_MSG_LINK_CHANGE:
+			qed_mcp_handle_link_change(p_hwfn, p_ptt, false);
+			break;
+		default:
+			DP_NOTICE(p_hwfn, "Unimplemented MFW message %d\n", i);
+			rc = -EINVAL;
+		}
+	}
+
+	/* ACK everything */
+	for (i = 0; i < MFW_DRV_MSG_MAX_DWORDS(info->mfw_mb_length); i++) {
+		__be32 val = cpu_to_be32(((u32 *)info->mfw_mb_cur)[i]);
+
+		/* MFW expect answer in BE, so we force write in that format */
+		qed_wr(p_hwfn, p_ptt,
+		       info->mfw_mb_addr + sizeof(u32) +
+		       MFW_DRV_MSG_MAX_DWORDS(info->mfw_mb_length) *
+		       sizeof(u32) + i * sizeof(u32),
+		       (__force u32)val);
+	}
+
+	if (!found) {
+		DP_NOTICE(p_hwfn,
+			  "Received an MFW message indication but no new message!\n");
+		rc = -EINVAL;
+	}
+
+	/* Copy the new mfw messages into the shadow */
+	memcpy(info->mfw_mb_shadow, info->mfw_mb_cur, info->mfw_mb_length);
+
+	return rc;
+}
+
 int qed_mcp_get_mfw_ver(struct qed_dev	*cdev,
 			u32		*p_mfw_ver)
 {
@@ -389,6 +635,31 @@ int qed_mcp_get_mfw_ver(struct qed_dev	*cdev,
 	return 0;
 }
 
+int qed_mcp_get_media_type(struct qed_dev       *cdev,
+			   u32		  *p_media_type)
+{
+	struct qed_hwfn *p_hwfn = &cdev->hwfns[0];
+	struct qed_ptt  *p_ptt;
+
+	if (!qed_mcp_is_init(p_hwfn)) {
+		DP_NOTICE(p_hwfn, "MFW is not initialized !\n");
+		return -EBUSY;
+	}
+
+	*p_media_type = MEDIA_UNSPECIFIED;
+
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt)
+		return -EBUSY;
+
+	*p_media_type = qed_rd(p_hwfn, p_ptt, p_hwfn->mcp_info->port_addr +
+			       offsetof(struct public_port, media_type));
+
+	qed_ptt_release(p_hwfn, p_ptt);
+
+	return 0;
+}
+
 static u32 qed_mcp_get_shmem_func(struct qed_hwfn	*p_hwfn,
 				  struct qed_ptt	*p_ptt,
 				  struct public_func	*p_data,
@@ -500,6 +771,30 @@ int qed_mcp_fill_shmem_func_info(struct qed_hwfn	*p_hwfn,
 	return 0;
 }
 
+struct qed_mcp_link_params
+*qed_mcp_get_link_params(struct qed_hwfn *p_hwfn)
+{
+	if (!p_hwfn || !p_hwfn->mcp_info)
+		return NULL;
+	return &p_hwfn->mcp_info->link_input;
+}
+
+struct qed_mcp_link_state
+*qed_mcp_get_link_state(struct qed_hwfn *p_hwfn)
+{
+	if (!p_hwfn || !p_hwfn->mcp_info)
+		return NULL;
+	return &p_hwfn->mcp_info->link_output;
+}
+
+struct qed_mcp_link_capabilities
+*qed_mcp_get_link_capabilities(struct qed_hwfn *p_hwfn)
+{
+	if (!p_hwfn || !p_hwfn->mcp_info)
+		return NULL;
+	return &p_hwfn->mcp_info->link_capabilities;
+}
+
 int qed_mcp_drain(struct qed_hwfn	*p_hwfn,
 		  struct qed_ptt	*p_ptt)
 {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index 160f499..c328a63 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -14,6 +14,59 @@
 #include <linux/slab.h>
 #include "qed_hsi.h"
 
+struct qed_mcp_link_speed_params {
+	bool    autoneg;
+	u32     advertised_speeds;      /* bitmask of DRV_SPEED_CAPABILITY */
+	u32     forced_speed;	   /* In Mb/s */
+};
+
+struct qed_mcp_link_pause_params {
+	bool    autoneg;
+	bool    forced_rx;
+	bool    forced_tx;
+};
+
+struct qed_mcp_link_params {
+	struct qed_mcp_link_speed_params	speed;
+	struct qed_mcp_link_pause_params	pause;
+	u32				     loopback_mode;
+};
+
+struct qed_mcp_link_capabilities {
+	u32 speed_capabilities;
+};
+
+struct qed_mcp_link_state {
+	bool    link_up;
+
+	u32     speed; /* In Mb/s */
+	bool    full_duplex;
+
+	bool    an;
+	bool    an_complete;
+	bool    parallel_detection;
+	bool    pfc_enabled;
+
+#define QED_LINK_PARTNER_SPEED_1G_HD    BIT(0)
+#define QED_LINK_PARTNER_SPEED_1G_FD    BIT(1)
+#define QED_LINK_PARTNER_SPEED_10G      BIT(2)
+#define QED_LINK_PARTNER_SPEED_20G      BIT(3)
+#define QED_LINK_PARTNER_SPEED_40G      BIT(4)
+#define QED_LINK_PARTNER_SPEED_50G      BIT(5)
+#define QED_LINK_PARTNER_SPEED_100G     BIT(6)
+	u32     partner_adv_speed;
+
+	bool    partner_tx_flow_ctrl_en;
+	bool    partner_rx_flow_ctrl_en;
+
+#define QED_LINK_PARTNER_SYMMETRIC_PAUSE (1)
+#define QED_LINK_PARTNER_ASYMMETRIC_PAUSE (2)
+#define QED_LINK_PARTNER_BOTH_PAUSE (3)
+	u8      partner_adv_pause;
+
+	bool    sfp_tx_fault;
+};
+
 struct qed_mcp_function_info {
 	u8				pause_on_host;
 
@@ -44,6 +97,47 @@ struct qed_mcp_drv_version {
 };
 
 /**
+ * @brief - returns the link params of the hw function
+ *
+ * @param p_hwfn
+ *
+ * @returns pointer to link params
+ */
+struct qed_mcp_link_params *qed_mcp_get_link_params(struct qed_hwfn *);
+
+/**
+ * @brief - return the link state of the hw function
+ *
+ * @param p_hwfn
+ *
+ * @returns pointer to link state
+ */
+struct qed_mcp_link_state *qed_mcp_get_link_state(struct qed_hwfn *);
+
+/**
+ * @brief - return the link capabilities of the hw function
+ *
+ * @param p_hwfn
+ *
+ * @returns pointer to link capabilities
+ */
+struct qed_mcp_link_capabilities
+	*qed_mcp_get_link_capabilities(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief Request the MFW to set the the link according to 'link_input'.
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param b_up - raise link if `true'. Reset link if `false'.
+ *
+ * @return int
+ */
+int qed_mcp_set_link(struct qed_hwfn   *p_hwfn,
+		     struct qed_ptt     *p_ptt,
+		     bool               b_up);
+
+/**
  * @brief Get the management firmware version value
  *
  * @param cdev       - qed dev pointer
@@ -55,6 +149,19 @@ int qed_mcp_get_mfw_ver(struct qed_dev	*cdev,
 			u32		*mfw_ver);
 
 /**
+ * @brief Get media type value of the port.
+ *
+ * @param cdev      - qed dev pointer
+ * @param mfw_ver    - media type value
+ *
+ * @return int -
+ *      0 - Operation was successul.
+ *      -EBUSY - Operation failed
+ */
+int qed_mcp_get_media_type(struct qed_dev      *cdev,
+			   u32                  *media_type);
+
+/**
  * @brief General function for sending commands to the MCP
  *        mailbox. It acquire mutex lock for the entire
  *        operation, from sending the request until the MCP
@@ -141,8 +248,10 @@ struct qed_mcp_info {
 	u32					port_addr;
 	u16					drv_mb_seq;
 	u16					drv_pulse_seq;
+	struct qed_mcp_link_params		link_input;
+	struct qed_mcp_link_state		link_output;
+	struct qed_mcp_link_capabilities	link_capabilities;
 	struct qed_mcp_function_info		func_info;
-
 	u8					*mfw_mb_cur;
 	u8					*mfw_mb_shadow;
 	u16					mfw_mb_length;
@@ -181,6 +290,21 @@ void qed_mcp_cmd_port_init(struct qed_hwfn	*p_hwfn,
 int qed_mcp_free(struct qed_hwfn *p_hwfn);
 
 /**
+ * @brief This function is called from the DPC context. After
+ * pointing PTT to the mfw mb, check for events sent by the MCP
+ * to the driver and ack them. In case a critical event
+ * detected, it will be handled here, otherwise the work will be
+ * queued to a sleepable work-queue.
+ *
+ * @param p_hwfn - HW function
+ * @param p_ptt - PTT required for register access
+ * @return int - 0 - operation
+ * was successul.
+ */
+int qed_mcp_handle_events(struct qed_hwfn      *p_hwfn,
+			  struct qed_ptt        *p_ptt);
+
+/**
  * @brief Sends a LOAD_REQ to the MFW, and in case operation
  *        succeed, returns whether this PF is the first on the
  *        chip/engine/port or function. This function should be
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index aeb6855..cae4877 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -103,6 +103,10 @@ struct qed_eth_ops {
 	int (*fill_dev_info)(struct qed_dev *cdev,
 			     struct qed_dev_eth_info *info);
 
+	void (*register_ops)(struct qed_dev *cdev,
+			     struct qed_eth_cb_ops *ops,
+			     void *cookie);
+
 	int (*vport_start)(struct qed_dev *cdev,
 			   u8 vport_id, u16 mtu,
 			   u8 drop_ttl0_flg,
-- 
1.9.3
