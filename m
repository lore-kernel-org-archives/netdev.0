From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH v2 net-next 1/5] qed: Add infrastructure support for tunneling
Date: Thu, 14 Apr 2016 01:38:29 -0400
Message-ID: <1460612313-20323-2-git-send-email-manish.chopra@qlogic.com>
References: <1460612313-20323-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:57030 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752030AbcDNGUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 02:20:13 -0400
In-Reply-To: <1460612313-20323-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds various structure/APIs needed to configure/enable different
tunnel [VXLAN/GRE/GENEVE] parameters on the adapter.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h              |  46 ++++
 drivers/net/ethernet/qlogic/qed/qed_dev.c          |   6 +-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h      |   2 +
 drivers/net/ethernet/qlogic/qed/qed_hsi.h          |  51 ++++-
 .../net/ethernet/qlogic/qed/qed_init_fw_funcs.c    | 127 +++++++++++
 drivers/net/ethernet/qlogic/qed/qed_l2.c           |  31 +++
 drivers/net/ethernet/qlogic/qed/qed_main.c         |   2 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h     |  31 +++
 drivers/net/ethernet/qlogic/qed/qed_sp.h           |   7 +
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c  | 254 +++++++++++++++++++++
 include/linux/qed/qed_eth_if.h                     |  10 +
 11 files changed, 563 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 0f0d2d1..33e2ed6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -74,6 +74,51 @@ struct qed_rt_data {
 	bool	*b_valid;
 };
 
+enum qed_tunn_mode {
+	QED_MODE_L2GENEVE_TUNN,
+	QED_MODE_IPGENEVE_TUNN,
+	QED_MODE_L2GRE_TUNN,
+	QED_MODE_IPGRE_TUNN,
+	QED_MODE_VXLAN_TUNN,
+};
+
+enum qed_tunn_clss {
+	QED_TUNN_CLSS_MAC_VLAN,
+	QED_TUNN_CLSS_MAC_VNI,
+	QED_TUNN_CLSS_INNER_MAC_VLAN,
+	QED_TUNN_CLSS_INNER_MAC_VNI,
+	MAX_QED_TUNN_CLSS,
+};
+
+struct qed_tunn_start_params {
+	unsigned long	tunn_mode;
+	u16		vxlan_udp_port;
+	u16		geneve_udp_port;
+	u8		update_vxlan_udp_port;
+	u8		update_geneve_udp_port;
+	u8		tunn_clss_vxlan;
+	u8		tunn_clss_l2geneve;
+	u8		tunn_clss_ipgeneve;
+	u8		tunn_clss_l2gre;
+	u8		tunn_clss_ipgre;
+};
+
+struct qed_tunn_update_params {
+	unsigned long	tunn_mode_update_mask;
+	unsigned long	tunn_mode;
+	u16		vxlan_udp_port;
+	u16		geneve_udp_port;
+	u8		update_rx_pf_clss;
+	u8		update_tx_pf_clss;
+	u8		update_vxlan_udp_port;
+	u8		update_geneve_udp_port;
+	u8		tunn_clss_vxlan;
+	u8		tunn_clss_l2geneve;
+	u8		tunn_clss_ipgeneve;
+	u8		tunn_clss_l2gre;
+	u8		tunn_clss_ipgre;
+};
+
 /* The PCI personality is not quite synonymous to protocol ID:
  * 1. All personalities need CORE connections
  * 2. The Ethernet personality may support also the RoCE protocol
@@ -430,6 +475,7 @@ struct qed_dev {
 	u8				num_hwfns;
 	struct qed_hwfn			hwfns[MAX_HWFNS_PER_DEVICE];
 
+	unsigned long			tunn_mode;
 	u32				drv_type;
 
 	struct qed_eth_stats		*reset_stats;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index b7d100f..bdae5a5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -558,6 +558,7 @@ static int qed_hw_init_port(struct qed_hwfn *p_hwfn,
 
 static int qed_hw_init_pf(struct qed_hwfn *p_hwfn,
 			  struct qed_ptt *p_ptt,
+			  struct qed_tunn_start_params *p_tunn,
 			  int hw_mode,
 			  bool b_hw_start,
 			  enum qed_int_mode int_mode,
@@ -625,7 +626,7 @@ static int qed_hw_init_pf(struct qed_hwfn *p_hwfn,
 		qed_int_igu_enable(p_hwfn, p_ptt, int_mode);
 
 		/* send function start command */
-		rc = qed_sp_pf_start(p_hwfn, p_hwfn->cdev->mf_mode);
+		rc = qed_sp_pf_start(p_hwfn, p_tunn, p_hwfn->cdev->mf_mode);
 		if (rc)
 			DP_NOTICE(p_hwfn, "Function start ramrod failed\n");
 	}
@@ -672,6 +673,7 @@ static void qed_reset_mb_shadow(struct qed_hwfn *p_hwfn,
 }
 
 int qed_hw_init(struct qed_dev *cdev,
+		struct qed_tunn_start_params *p_tunn,
 		bool b_hw_start,
 		enum qed_int_mode int_mode,
 		bool allow_npar_tx_switch,
@@ -724,7 +726,7 @@ int qed_hw_init(struct qed_dev *cdev,
 		/* Fall into */
 		case FW_MSG_CODE_DRV_LOAD_FUNCTION:
 			rc = qed_hw_init_pf(p_hwfn, p_hwfn->p_main_ptt,
-					    p_hwfn->hw_info.hw_mode,
+					    p_tunn, p_hwfn->hw_info.hw_mode,
 					    b_hw_start, int_mode,
 					    allow_npar_tx_switch);
 			break;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
index d6c7ddf..6aac3f8 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
@@ -62,6 +62,7 @@ void qed_resc_setup(struct qed_dev *cdev);
  * @brief qed_hw_init -
  *
  * @param cdev
+ * @param p_tunn
  * @param b_hw_start
  * @param int_mode - interrupt mode [msix, inta, etc.] to use.
  * @param allow_npar_tx_switch - npar tx switching to be used
@@ -72,6 +73,7 @@ void qed_resc_setup(struct qed_dev *cdev);
  * @return int
  */
 int qed_hw_init(struct qed_dev *cdev,
+		struct qed_tunn_start_params *p_tunn,
 		bool b_hw_start,
 		enum qed_int_mode int_mode,
 		bool allow_npar_tx_switch,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index a368f5e..15e02ab 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -46,7 +46,7 @@ enum common_ramrod_cmd_id {
 	COMMON_RAMROD_PF_STOP /* PF Function Stop Ramrod */,
 	COMMON_RAMROD_RESERVED,
 	COMMON_RAMROD_RESERVED2,
-	COMMON_RAMROD_RESERVED3,
+	COMMON_RAMROD_PF_UPDATE,
 	COMMON_RAMROD_EMPTY,
 	MAX_COMMON_RAMROD_CMD_ID
 };
@@ -626,6 +626,42 @@ struct pf_start_ramrod_data {
 	u8				reserved0[4];
 };
 
+/* tunnel configuration */
+struct pf_update_tunnel_config {
+	u8	update_rx_pf_clss;
+	u8	update_tx_pf_clss;
+	u8	set_vxlan_udp_port_flg;
+	u8	set_geneve_udp_port_flg;
+	u8	tx_enable_vxlan;
+	u8	tx_enable_l2geneve;
+	u8	tx_enable_ipgeneve;
+	u8	tx_enable_l2gre;
+	u8	tx_enable_ipgre;
+	u8	tunnel_clss_vxlan;
+	u8	tunnel_clss_l2geneve;
+	u8	tunnel_clss_ipgeneve;
+	u8	tunnel_clss_l2gre;
+	u8	tunnel_clss_ipgre;
+	__le16	vxlan_udp_port;
+	__le16	geneve_udp_port;
+	__le16	reserved[3];
+};
+
+struct pf_update_ramrod_data {
+	u32				reserved[2];
+	u32				reserved_1[6];
+	struct pf_update_tunnel_config	tunnel_config;
+};
+
+/* Tunnel classification scheme */
+enum tunnel_clss {
+	TUNNEL_CLSS_MAC_VLAN = 0,
+	TUNNEL_CLSS_MAC_VNI,
+	TUNNEL_CLSS_INNER_MAC_VLAN,
+	TUNNEL_CLSS_INNER_MAC_VNI,
+	MAX_TUNNEL_CLSS
+};
+
 enum ports_mode {
 	ENGX2_PORTX1 /* 2 engines x 1 port */,
 	ENGX2_PORTX2 /* 2 engines x 2 ports */,
@@ -1603,6 +1639,19 @@ bool qed_send_qm_stop_cmd(struct qed_hwfn	*p_hwfn,
 			  u16			start_pq,
 			  u16			num_pqs);
 
+void qed_set_vxlan_dest_port(struct qed_hwfn *p_hwfn,
+			     struct qed_ptt  *p_ptt, u16 dest_port);
+void qed_set_vxlan_enable(struct qed_hwfn *p_hwfn,
+			  struct qed_ptt *p_ptt, bool vxlan_enable);
+void qed_set_gre_enable(struct qed_hwfn *p_hwfn,
+			struct qed_ptt  *p_ptt, bool eth_gre_enable,
+			bool ip_gre_enable);
+void qed_set_geneve_dest_port(struct qed_hwfn *p_hwfn,
+			      struct qed_ptt *p_ptt, u16 dest_port);
+void qed_set_geneve_enable(struct qed_hwfn *p_hwfn,
+			   struct qed_ptt *p_ptt, bool eth_geneve_enable,
+			   bool ip_geneve_enable);
+
 /* Ystorm flow control mode. Use enum fw_flow_ctrl_mode */
 #define YSTORM_FLOW_CONTROL_MODE_OFFSET  (IRO[0].base)
 #define YSTORM_FLOW_CONTROL_MODE_SIZE    (IRO[0].size)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
index f55ebdc..1dd5324 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
@@ -788,3 +788,130 @@ bool qed_send_qm_stop_cmd(struct qed_hwfn *p_hwfn,
 
 	return true;
 }
+
+static void
+qed_set_tunnel_type_enable_bit(unsigned long *var, int bit, bool enable)
+{
+	if (enable)
+		set_bit(bit, var);
+	else
+		clear_bit(bit, var);
+}
+
+#define PRS_ETH_TUNN_FIC_FORMAT	-188897008
+
+void qed_set_vxlan_dest_port(struct qed_hwfn *p_hwfn,
+			     struct qed_ptt *p_ptt,
+			     u16 dest_port)
+{
+	qed_wr(p_hwfn, p_ptt, PRS_REG_VXLAN_PORT, dest_port);
+	qed_wr(p_hwfn, p_ptt, NIG_REG_VXLAN_PORT, dest_port);
+	qed_wr(p_hwfn, p_ptt, PBF_REG_VXLAN_PORT, dest_port);
+}
+
+void qed_set_vxlan_enable(struct qed_hwfn *p_hwfn,
+			  struct qed_ptt *p_ptt,
+			  bool vxlan_enable)
+{
+	unsigned long reg_val = 0;
+	u8 shift;
+
+	reg_val = qed_rd(p_hwfn, p_ptt, PRS_REG_ENCAPSULATION_TYPE_EN);
+	shift = PRS_REG_ENCAPSULATION_TYPE_EN_VXLAN_ENABLE_SHIFT;
+	qed_set_tunnel_type_enable_bit(&reg_val, shift, vxlan_enable);
+
+	qed_wr(p_hwfn, p_ptt, PRS_REG_ENCAPSULATION_TYPE_EN, reg_val);
+
+	if (reg_val)
+		qed_wr(p_hwfn, p_ptt, PRS_REG_OUTPUT_FORMAT_4_0,
+		       PRS_ETH_TUNN_FIC_FORMAT);
+
+	reg_val = qed_rd(p_hwfn, p_ptt, NIG_REG_ENC_TYPE_ENABLE);
+	shift = NIG_REG_ENC_TYPE_ENABLE_VXLAN_ENABLE_SHIFT;
+	qed_set_tunnel_type_enable_bit(&reg_val, shift, vxlan_enable);
+
+	qed_wr(p_hwfn, p_ptt, NIG_REG_ENC_TYPE_ENABLE, reg_val);
+
+	qed_wr(p_hwfn, p_ptt, DORQ_REG_L2_EDPM_TUNNEL_VXLAN_EN,
+	       vxlan_enable ? 1 : 0);
+}
+
+void qed_set_gre_enable(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
+			bool eth_gre_enable, bool ip_gre_enable)
+{
+	unsigned long reg_val = 0;
+	u8 shift;
+
+	reg_val = qed_rd(p_hwfn, p_ptt, PRS_REG_ENCAPSULATION_TYPE_EN);
+	shift = PRS_REG_ENCAPSULATION_TYPE_EN_ETH_OVER_GRE_ENABLE_SHIFT;
+	qed_set_tunnel_type_enable_bit(&reg_val, shift, eth_gre_enable);
+
+	shift = PRS_REG_ENCAPSULATION_TYPE_EN_IP_OVER_GRE_ENABLE_SHIFT;
+	qed_set_tunnel_type_enable_bit(&reg_val, shift, ip_gre_enable);
+	qed_wr(p_hwfn, p_ptt, PRS_REG_ENCAPSULATION_TYPE_EN, reg_val);
+	if (reg_val)
+		qed_wr(p_hwfn, p_ptt, PRS_REG_OUTPUT_FORMAT_4_0,
+		       PRS_ETH_TUNN_FIC_FORMAT);
+
+	reg_val = qed_rd(p_hwfn, p_ptt, NIG_REG_ENC_TYPE_ENABLE);
+	shift = NIG_REG_ENC_TYPE_ENABLE_ETH_OVER_GRE_ENABLE_SHIFT;
+	qed_set_tunnel_type_enable_bit(&reg_val, shift, eth_gre_enable);
+
+	shift = NIG_REG_ENC_TYPE_ENABLE_IP_OVER_GRE_ENABLE_SHIFT;
+	qed_set_tunnel_type_enable_bit(&reg_val, shift, ip_gre_enable);
+	qed_wr(p_hwfn, p_ptt, NIG_REG_ENC_TYPE_ENABLE, reg_val);
+
+	qed_wr(p_hwfn, p_ptt, DORQ_REG_L2_EDPM_TUNNEL_GRE_ETH_EN,
+	       eth_gre_enable ? 1 : 0);
+	qed_wr(p_hwfn, p_ptt, DORQ_REG_L2_EDPM_TUNNEL_GRE_IP_EN,
+	       ip_gre_enable ? 1 : 0);
+}
+
+void qed_set_geneve_dest_port(struct qed_hwfn *p_hwfn,
+			      struct qed_ptt *p_ptt,
+			      u16 dest_port)
+{
+	qed_wr(p_hwfn, p_ptt, PRS_REG_NGE_PORT, dest_port);
+	qed_wr(p_hwfn, p_ptt, NIG_REG_NGE_PORT, dest_port);
+	qed_wr(p_hwfn, p_ptt, PBF_REG_NGE_PORT, dest_port);
+}
+
+void qed_set_geneve_enable(struct qed_hwfn *p_hwfn,
+			   struct qed_ptt *p_ptt,
+			   bool eth_geneve_enable,
+			   bool ip_geneve_enable)
+{
+	unsigned long reg_val = 0;
+	u8 shift;
+
+	reg_val = qed_rd(p_hwfn, p_ptt, PRS_REG_ENCAPSULATION_TYPE_EN);
+	shift = PRS_REG_ENCAPSULATION_TYPE_EN_ETH_OVER_GENEVE_ENABLE_SHIFT;
+	qed_set_tunnel_type_enable_bit(&reg_val, shift, eth_geneve_enable);
+
+	shift = PRS_REG_ENCAPSULATION_TYPE_EN_IP_OVER_GENEVE_ENABLE_SHIFT;
+	qed_set_tunnel_type_enable_bit(&reg_val, shift, ip_geneve_enable);
+
+	qed_wr(p_hwfn, p_ptt, PRS_REG_ENCAPSULATION_TYPE_EN, reg_val);
+	if (reg_val)
+		qed_wr(p_hwfn, p_ptt, PRS_REG_OUTPUT_FORMAT_4_0,
+		       PRS_ETH_TUNN_FIC_FORMAT);
+
+	qed_wr(p_hwfn, p_ptt, NIG_REG_NGE_ETH_ENABLE,
+	       eth_geneve_enable ? 1 : 0);
+	qed_wr(p_hwfn, p_ptt, NIG_REG_NGE_IP_ENABLE, ip_geneve_enable ? 1 : 0);
+
+	/* comp ver */
+	reg_val = (ip_geneve_enable || eth_geneve_enable) ? 1 : 0;
+	qed_wr(p_hwfn, p_ptt, NIG_REG_NGE_COMP_VER, reg_val);
+	qed_wr(p_hwfn, p_ptt, PBF_REG_NGE_COMP_VER, reg_val);
+	qed_wr(p_hwfn, p_ptt, PRS_REG_NGE_COMP_VER, reg_val);
+
+	/* EDPM with geneve tunnel not supported in BB_B0 */
+	if (QED_IS_BB_B0(p_hwfn->cdev))
+		return;
+
+	qed_wr(p_hwfn, p_ptt, DORQ_REG_L2_EDPM_TUNNEL_NGE_ETH_EN,
+	       eth_geneve_enable ? 1 : 0);
+	qed_wr(p_hwfn, p_ptt, DORQ_REG_L2_EDPM_TUNNEL_NGE_IP_EN,
+	       ip_geneve_enable ? 1 : 0);
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 5005497..fb5f3b8 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -1884,6 +1884,36 @@ static int qed_stop_txq(struct qed_dev *cdev,
 	return 0;
 }
 
+static int qed_tunn_configure(struct qed_dev *cdev,
+			      struct qed_tunn_params *tunn_params)
+{
+	struct qed_tunn_update_params tunn_info;
+	int i, rc;
+
+	memset(&tunn_info, 0, sizeof(tunn_info));
+	if (tunn_params->update_vxlan_port == 1) {
+		tunn_info.update_vxlan_udp_port = 1;
+		tunn_info.vxlan_udp_port = tunn_params->vxlan_port;
+	}
+
+	if (tunn_params->update_geneve_port == 1) {
+		tunn_info.update_geneve_udp_port = 1;
+		tunn_info.geneve_udp_port = tunn_params->geneve_port;
+	}
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *hwfn = &cdev->hwfns[i];
+
+		rc = qed_sp_pf_update_tunn_cfg(hwfn, &tunn_info,
+					       QED_SPQ_MODE_EBLOCK, NULL);
+
+		if (rc)
+			return rc;
+	}
+
+	return 0;
+}
+
 static int qed_configure_filter_rx_mode(struct qed_dev *cdev,
 					enum qed_filter_rx_mode_type type)
 {
@@ -2026,6 +2056,7 @@ static const struct qed_eth_ops qed_eth_ops_pass = {
 	.fastpath_stop = &qed_fastpath_stop,
 	.eth_cqe_completion = &qed_fp_cqe_completion,
 	.get_vport_stats = &qed_get_vport_stats,
+	.tunn_config = &qed_tunn_configure,
 };
 
 const struct qed_eth_ops *qed_get_eth_ops(void)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index c31d485..1916992 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -776,7 +776,7 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 	/* Start the slowpath */
 	data = cdev->firmware->data;
 
-	rc = qed_hw_init(cdev, true, cdev->int_params.out.int_mode,
+	rc = qed_hw_init(cdev, NULL, true, cdev->int_params.out.int_mode,
 			 true, data);
 	if (rc)
 		goto err2;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index c15b162..55451a4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -427,4 +427,35 @@
 	0x2aae60UL
 #define PGLUE_B_REG_PF_BAR1_SIZE \
 	0x2aae64UL
+#define PRS_REG_ENCAPSULATION_TYPE_EN	0x1f0730UL
+#define PRS_REG_GRE_PROTOCOL		0x1f0734UL
+#define PRS_REG_VXLAN_PORT		0x1f0738UL
+#define PRS_REG_OUTPUT_FORMAT_4_0	0x1f099cUL
+#define NIG_REG_ENC_TYPE_ENABLE		0x501058UL
+
+#define NIG_REG_ENC_TYPE_ENABLE_ETH_OVER_GRE_ENABLE		(0x1 << 0)
+#define NIG_REG_ENC_TYPE_ENABLE_ETH_OVER_GRE_ENABLE_SHIFT	0
+#define NIG_REG_ENC_TYPE_ENABLE_IP_OVER_GRE_ENABLE		(0x1 << 1)
+#define NIG_REG_ENC_TYPE_ENABLE_IP_OVER_GRE_ENABLE_SHIFT	1
+#define NIG_REG_ENC_TYPE_ENABLE_VXLAN_ENABLE			(0x1 << 2)
+#define NIG_REG_ENC_TYPE_ENABLE_VXLAN_ENABLE_SHIFT		2
+
+#define NIG_REG_VXLAN_PORT		0x50105cUL
+#define PBF_REG_VXLAN_PORT		0xd80518UL
+#define PBF_REG_NGE_PORT		0xd8051cUL
+#define PRS_REG_NGE_PORT		0x1f086cUL
+#define NIG_REG_NGE_PORT		0x508b38UL
+
+#define DORQ_REG_L2_EDPM_TUNNEL_GRE_ETH_EN	0x10090cUL
+#define DORQ_REG_L2_EDPM_TUNNEL_GRE_IP_EN	0x100910UL
+#define DORQ_REG_L2_EDPM_TUNNEL_VXLAN_EN	0x100914UL
+#define DORQ_REG_L2_EDPM_TUNNEL_NGE_IP_EN	0x10092cUL
+#define DORQ_REG_L2_EDPM_TUNNEL_NGE_ETH_EN	0x100930UL
+
+#define NIG_REG_NGE_IP_ENABLE			0x508b28UL
+#define NIG_REG_NGE_ETH_ENABLE			0x508b2cUL
+#define NIG_REG_NGE_COMP_VER			0x508b30UL
+#define PBF_REG_NGE_COMP_VER			0xd80524UL
+#define PRS_REG_NGE_COMP_VER			0x1f0878UL
+
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp.h b/drivers/net/ethernet/qlogic/qed/qed_sp.h
index d39f914..4b91cb3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp.h
@@ -52,6 +52,7 @@ int qed_eth_cqe_completion(struct qed_hwfn *p_hwfn,
 
 union ramrod_data {
 	struct pf_start_ramrod_data pf_start;
+	struct pf_update_ramrod_data pf_update;
 	struct rx_queue_start_ramrod_data rx_queue_start;
 	struct rx_queue_update_ramrod_data rx_queue_update;
 	struct rx_queue_stop_ramrod_data rx_queue_stop;
@@ -338,12 +339,14 @@ int qed_sp_init_request(struct qed_hwfn *p_hwfn,
  * to the internal RAM of the UStorm by the Function Start Ramrod.
  *
  * @param p_hwfn
+ * @param p_tunn
  * @param mode
  *
  * @return int
  */
 
 int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
+		    struct qed_tunn_start_params *p_tunn,
 		    enum qed_mf_mode mode);
 
 /**
@@ -362,4 +365,8 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 
 int qed_sp_pf_stop(struct qed_hwfn *p_hwfn);
 
+int qed_sp_pf_update_tunn_cfg(struct qed_hwfn *p_hwfn,
+			      struct qed_tunn_update_params *p_tunn,
+			      enum spq_mode comp_mode,
+			      struct qed_spq_comp_cb *p_comp_data);
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index 1c06c37..306da70 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -87,7 +87,217 @@ int qed_sp_init_request(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
+static enum tunnel_clss qed_tunn_get_clss_type(u8 type)
+{
+	switch (type) {
+	case QED_TUNN_CLSS_MAC_VLAN:
+		return TUNNEL_CLSS_MAC_VLAN;
+	case QED_TUNN_CLSS_MAC_VNI:
+		return TUNNEL_CLSS_MAC_VNI;
+	case QED_TUNN_CLSS_INNER_MAC_VLAN:
+		return TUNNEL_CLSS_INNER_MAC_VLAN;
+	case QED_TUNN_CLSS_INNER_MAC_VNI:
+		return TUNNEL_CLSS_INNER_MAC_VNI;
+	default:
+		return TUNNEL_CLSS_MAC_VLAN;
+	}
+}
+
+static void
+qed_tunn_set_pf_fix_tunn_mode(struct qed_hwfn *p_hwfn,
+			      struct qed_tunn_update_params *p_src,
+			      struct pf_update_tunnel_config *p_tunn_cfg)
+{
+	unsigned long cached_tunn_mode = p_hwfn->cdev->tunn_mode;
+	unsigned long update_mask = p_src->tunn_mode_update_mask;
+	unsigned long tunn_mode = p_src->tunn_mode;
+	unsigned long new_tunn_mode = 0;
+
+	if (test_bit(QED_MODE_L2GRE_TUNN, &update_mask)) {
+		if (test_bit(QED_MODE_L2GRE_TUNN, &tunn_mode))
+			__set_bit(QED_MODE_L2GRE_TUNN, &new_tunn_mode);
+	} else {
+		if (test_bit(QED_MODE_L2GRE_TUNN, &cached_tunn_mode))
+			__set_bit(QED_MODE_L2GRE_TUNN, &new_tunn_mode);
+	}
+
+	if (test_bit(QED_MODE_IPGRE_TUNN, &update_mask)) {
+		if (test_bit(QED_MODE_IPGRE_TUNN, &tunn_mode))
+			__set_bit(QED_MODE_IPGRE_TUNN, &new_tunn_mode);
+	} else {
+		if (test_bit(QED_MODE_IPGRE_TUNN, &cached_tunn_mode))
+			__set_bit(QED_MODE_IPGRE_TUNN, &new_tunn_mode);
+	}
+
+	if (test_bit(QED_MODE_VXLAN_TUNN, &update_mask)) {
+		if (test_bit(QED_MODE_VXLAN_TUNN, &tunn_mode))
+			__set_bit(QED_MODE_VXLAN_TUNN, &new_tunn_mode);
+	} else {
+		if (test_bit(QED_MODE_VXLAN_TUNN, &cached_tunn_mode))
+			__set_bit(QED_MODE_VXLAN_TUNN, &new_tunn_mode);
+	}
+
+	if (p_src->update_geneve_udp_port) {
+		p_tunn_cfg->set_geneve_udp_port_flg = 1;
+		p_tunn_cfg->geneve_udp_port =
+				cpu_to_le16(p_src->geneve_udp_port);
+	}
+
+	if (test_bit(QED_MODE_L2GENEVE_TUNN, &update_mask)) {
+		if (test_bit(QED_MODE_L2GENEVE_TUNN, &tunn_mode))
+			__set_bit(QED_MODE_L2GENEVE_TUNN, &new_tunn_mode);
+	} else {
+		if (test_bit(QED_MODE_L2GENEVE_TUNN, &cached_tunn_mode))
+			__set_bit(QED_MODE_L2GENEVE_TUNN, &new_tunn_mode);
+	}
+
+	if (test_bit(QED_MODE_IPGENEVE_TUNN, &update_mask)) {
+		if (test_bit(QED_MODE_IPGENEVE_TUNN, &tunn_mode))
+			__set_bit(QED_MODE_IPGENEVE_TUNN, &new_tunn_mode);
+	} else {
+		if (test_bit(QED_MODE_IPGENEVE_TUNN, &cached_tunn_mode))
+			__set_bit(QED_MODE_IPGENEVE_TUNN, &new_tunn_mode);
+	}
+
+	p_src->tunn_mode = new_tunn_mode;
+}
+
+static void
+qed_tunn_set_pf_update_params(struct qed_hwfn *p_hwfn,
+			      struct qed_tunn_update_params *p_src,
+			      struct pf_update_tunnel_config *p_tunn_cfg)
+{
+	unsigned long tunn_mode = p_src->tunn_mode;
+	enum tunnel_clss type;
+
+	qed_tunn_set_pf_fix_tunn_mode(p_hwfn, p_src, p_tunn_cfg);
+	p_tunn_cfg->update_rx_pf_clss = p_src->update_rx_pf_clss;
+	p_tunn_cfg->update_tx_pf_clss = p_src->update_tx_pf_clss;
+
+	type = qed_tunn_get_clss_type(p_src->tunn_clss_vxlan);
+	p_tunn_cfg->tunnel_clss_vxlan  = type;
+
+	type = qed_tunn_get_clss_type(p_src->tunn_clss_l2gre);
+	p_tunn_cfg->tunnel_clss_l2gre = type;
+
+	type = qed_tunn_get_clss_type(p_src->tunn_clss_ipgre);
+	p_tunn_cfg->tunnel_clss_ipgre = type;
+
+	if (p_src->update_vxlan_udp_port) {
+		p_tunn_cfg->set_vxlan_udp_port_flg = 1;
+		p_tunn_cfg->vxlan_udp_port = cpu_to_le16(p_src->vxlan_udp_port);
+	}
+
+	if (test_bit(QED_MODE_L2GRE_TUNN, &tunn_mode))
+		p_tunn_cfg->tx_enable_l2gre = 1;
+
+	if (test_bit(QED_MODE_IPGRE_TUNN, &tunn_mode))
+		p_tunn_cfg->tx_enable_ipgre = 1;
+
+	if (test_bit(QED_MODE_VXLAN_TUNN, &tunn_mode))
+		p_tunn_cfg->tx_enable_vxlan = 1;
+
+	if (p_src->update_geneve_udp_port) {
+		p_tunn_cfg->set_geneve_udp_port_flg = 1;
+		p_tunn_cfg->geneve_udp_port =
+				cpu_to_le16(p_src->geneve_udp_port);
+	}
+
+	if (test_bit(QED_MODE_L2GENEVE_TUNN, &tunn_mode))
+		p_tunn_cfg->tx_enable_l2geneve = 1;
+
+	if (test_bit(QED_MODE_IPGENEVE_TUNN, &tunn_mode))
+		p_tunn_cfg->tx_enable_ipgeneve = 1;
+
+	type = qed_tunn_get_clss_type(p_src->tunn_clss_l2geneve);
+	p_tunn_cfg->tunnel_clss_l2geneve = type;
+
+	type = qed_tunn_get_clss_type(p_src->tunn_clss_ipgeneve);
+	p_tunn_cfg->tunnel_clss_ipgeneve = type;
+}
+
+static void qed_set_hw_tunn_mode(struct qed_hwfn *p_hwfn,
+				 struct qed_ptt *p_ptt,
+				 unsigned long tunn_mode)
+{
+	u8 l2gre_enable = 0, ipgre_enable = 0, vxlan_enable = 0;
+	u8 l2geneve_enable = 0, ipgeneve_enable = 0;
+
+	if (test_bit(QED_MODE_L2GRE_TUNN, &tunn_mode))
+		l2gre_enable = 1;
+
+	if (test_bit(QED_MODE_IPGRE_TUNN, &tunn_mode))
+		ipgre_enable = 1;
+
+	if (test_bit(QED_MODE_VXLAN_TUNN, &tunn_mode))
+		vxlan_enable = 1;
+
+	qed_set_gre_enable(p_hwfn, p_ptt, l2gre_enable, ipgre_enable);
+	qed_set_vxlan_enable(p_hwfn, p_ptt, vxlan_enable);
+
+	if (test_bit(QED_MODE_L2GENEVE_TUNN, &tunn_mode))
+		l2geneve_enable = 1;
+
+	if (test_bit(QED_MODE_IPGENEVE_TUNN, &tunn_mode))
+		ipgeneve_enable = 1;
+
+	qed_set_geneve_enable(p_hwfn, p_ptt, l2geneve_enable,
+			      ipgeneve_enable);
+}
+
+static void
+qed_tunn_set_pf_start_params(struct qed_hwfn *p_hwfn,
+			     struct qed_tunn_start_params *p_src,
+			     struct pf_start_tunnel_config *p_tunn_cfg)
+{
+	unsigned long tunn_mode;
+	enum tunnel_clss type;
+
+	if (!p_src)
+		return;
+
+	tunn_mode = p_src->tunn_mode;
+	type = qed_tunn_get_clss_type(p_src->tunn_clss_vxlan);
+	p_tunn_cfg->tunnel_clss_vxlan = type;
+	type = qed_tunn_get_clss_type(p_src->tunn_clss_l2gre);
+	p_tunn_cfg->tunnel_clss_l2gre = type;
+	type = qed_tunn_get_clss_type(p_src->tunn_clss_ipgre);
+	p_tunn_cfg->tunnel_clss_ipgre = type;
+
+	if (p_src->update_vxlan_udp_port) {
+		p_tunn_cfg->set_vxlan_udp_port_flg = 1;
+		p_tunn_cfg->vxlan_udp_port = cpu_to_le16(p_src->vxlan_udp_port);
+	}
+
+	if (test_bit(QED_MODE_L2GRE_TUNN, &tunn_mode))
+		p_tunn_cfg->tx_enable_l2gre = 1;
+
+	if (test_bit(QED_MODE_IPGRE_TUNN, &tunn_mode))
+		p_tunn_cfg->tx_enable_ipgre = 1;
+
+	if (test_bit(QED_MODE_VXLAN_TUNN, &tunn_mode))
+		p_tunn_cfg->tx_enable_vxlan = 1;
+
+	if (p_src->update_geneve_udp_port) {
+		p_tunn_cfg->set_geneve_udp_port_flg = 1;
+		p_tunn_cfg->geneve_udp_port =
+				cpu_to_le16(p_src->geneve_udp_port);
+	}
+
+	if (test_bit(QED_MODE_L2GENEVE_TUNN, &tunn_mode))
+		p_tunn_cfg->tx_enable_l2geneve = 1;
+
+	if (test_bit(QED_MODE_IPGENEVE_TUNN, &tunn_mode))
+		p_tunn_cfg->tx_enable_ipgeneve = 1;
+
+	type = qed_tunn_get_clss_type(p_src->tunn_clss_l2geneve);
+	p_tunn_cfg->tunnel_clss_l2geneve = type;
+	type = qed_tunn_get_clss_type(p_src->tunn_clss_ipgeneve);
+	p_tunn_cfg->tunnel_clss_ipgeneve = type;
+}
+
 int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
+		    struct qed_tunn_start_params *p_tunn,
 		    enum qed_mf_mode mode)
 {
 	struct pf_start_ramrod_data *p_ramrod = NULL;
@@ -143,6 +353,7 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 	DMA_REGPAIR_LE(p_ramrod->consolid_q_pbl_addr,
 		       p_hwfn->p_consq->chain.pbl.p_phys_table);
 
+	qed_tunn_set_pf_start_params(p_hwfn, NULL, NULL);
 	p_hwfn->hw_info.personality = PERSONALITY_ETH;
 
 	DP_VERBOSE(p_hwfn, QED_MSG_SPQ,
@@ -153,6 +364,49 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 	return qed_spq_post(p_hwfn, p_ent, NULL);
 }
 
+/* Set pf update ramrod command params */
+int qed_sp_pf_update_tunn_cfg(struct qed_hwfn *p_hwfn,
+			      struct qed_tunn_update_params *p_tunn,
+			      enum spq_mode comp_mode,
+			      struct qed_spq_comp_cb *p_comp_data)
+{
+	struct qed_spq_entry *p_ent = NULL;
+	struct qed_sp_init_data init_data;
+	int rc = -EINVAL;
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qed_spq_get_cid(p_hwfn);
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = comp_mode;
+	init_data.p_comp_data = p_comp_data;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
+				 COMMON_RAMROD_PF_UPDATE, PROTOCOLID_COMMON,
+				 &init_data);
+	if (rc)
+		return rc;
+
+	qed_tunn_set_pf_update_params(p_hwfn, p_tunn,
+				      &p_ent->ramrod.pf_update.tunnel_config);
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+	if (rc)
+		return rc;
+
+	if (p_tunn->update_vxlan_udp_port)
+		qed_set_vxlan_dest_port(p_hwfn, p_hwfn->p_main_ptt,
+					p_tunn->vxlan_udp_port);
+	if (p_tunn->update_geneve_udp_port)
+		qed_set_geneve_dest_port(p_hwfn, p_hwfn->p_main_ptt,
+					 p_tunn->geneve_udp_port);
+
+	qed_set_hw_tunn_mode(p_hwfn, p_hwfn->p_main_ptt, p_tunn->tunn_mode);
+	p_hwfn->cdev->tunn_mode = p_tunn->tunn_mode;
+
+	return rc;
+}
+
 int qed_sp_pf_stop(struct qed_hwfn *p_hwfn)
 {
 	struct qed_spq_entry *p_ent = NULL;
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index 795c990..3a4c806 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -112,6 +112,13 @@ struct qed_queue_start_common_params {
 	u16 sb_idx;
 };
 
+struct qed_tunn_params {
+	u16 vxlan_port;
+	u8 update_vxlan_port;
+	u16 geneve_port;
+	u8 update_geneve_port;
+};
+
 struct qed_eth_cb_ops {
 	struct qed_common_cb_ops common;
 };
@@ -166,6 +173,9 @@ struct qed_eth_ops {
 
 	void (*get_vport_stats)(struct qed_dev *cdev,
 				struct qed_eth_stats *stats);
+
+	int (*tunn_config)(struct qed_dev *cdev,
+			   struct qed_tunn_params *params);
 };
 
 const struct qed_eth_ops *qed_get_eth_ops(void);
-- 
2.7.2
