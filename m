From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 05/10] qed: Support dynamic s-tag change
Date: Sun, 28 May 2017 18:01:55 +0300
Message-ID: <1495983720-10853-6-git-send-email-Yuval.Mintz@cavium.com>
References: <1495983720-10853-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0081.outbound.protection.outlook.com ([104.47.40.81]:2298
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750974AbdE1PDo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 28 May 2017 11:03:44 -0400
In-Reply-To: <1495983720-10853-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case management firmware indicates a change in the used S-tag,
propagate the configuration to HW and FW.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_hsi.h         |  4 +++-
 drivers/net/ethernet/qlogic/qed/qed_mcp.c         | 26 +++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h    |  2 ++
 drivers/net/ethernet/qlogic/qed/qed_sp.h          |  9 ++++++++
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c | 24 +++++++++++++++++++++
 5 files changed, 64 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index f610e52..24b1458 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -11474,6 +11474,7 @@ struct public_drv_mb {
 
 #define DRV_MSG_CODE_BW_UPDATE_ACK		0x32000000
 #define DRV_MSG_CODE_NIG_DRAIN			0x30000000
+#define DRV_MSG_CODE_S_TAG_UPDATE_ACK		0x3b000000
 #define DRV_MSG_CODE_INITIATE_PF_FLR            0x02010000
 #define DRV_MSG_CODE_VF_DISABLED_DONE		0xc0000000
 #define DRV_MSG_CODE_CFG_VF_MSIX		0xc0010000
@@ -11634,6 +11635,7 @@ struct public_drv_mb {
 #define FW_MSG_CODE_RESOURCE_ALLOC_OK           0x34000000
 #define FW_MSG_CODE_RESOURCE_ALLOC_UNKNOWN      0x35000000
 #define FW_MSG_CODE_RESOURCE_ALLOC_DEPRECATED   0x36000000
+#define FW_MSG_CODE_S_TAG_UPDATE_ACK_DONE	0x3b000000
 #define FW_MSG_CODE_DRV_CFG_VF_MSIX_DONE	0xb0010000
 
 #define FW_MSG_CODE_NVM_OK			0x00010000
@@ -11681,7 +11683,7 @@ enum MFW_DRV_MSG_TYPE {
 	MFW_DRV_MSG_DCBX_OPERATIONAL_MIB_UPDATED,
 	MFW_DRV_MSG_RESERVED4,
 	MFW_DRV_MSG_BW_UPDATE,
-	MFW_DRV_MSG_BW_UPDATE5,
+	MFW_DRV_MSG_S_TAG_UPDATE,
 	MFW_DRV_MSG_GET_LAN_STATS,
 	MFW_DRV_MSG_GET_FCOE_STATS,
 	MFW_DRV_MSG_GET_ISCSI_STATS,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 24c9b71..31c88e1 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -1398,6 +1398,28 @@ static void qed_mcp_update_bw(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 		    &param);
 }
 
+static void qed_mcp_update_stag(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	struct public_func shmem_info;
+	u32 resp = 0, param = 0;
+
+	qed_mcp_get_shmem_func(p_hwfn, p_ptt, &shmem_info, MCP_PF_ID(p_hwfn));
+
+	p_hwfn->mcp_info->func_info.ovlan = (u16)shmem_info.ovlan_stag &
+						 FUNC_MF_CFG_OV_STAG_MASK;
+	p_hwfn->hw_info.ovlan = p_hwfn->mcp_info->func_info.ovlan;
+	if ((p_hwfn->hw_info.hw_mode & BIT(MODE_MF_SD)) &&
+	    (p_hwfn->hw_info.ovlan != QED_MCP_VLAN_UNSET)) {
+		qed_wr(p_hwfn, p_ptt,
+		       NIG_REG_LLH_FUNC_TAG_VALUE, p_hwfn->hw_info.ovlan);
+		qed_sp_pf_update_stag(p_hwfn);
+	}
+
+	/* Acknowledge the MFW */
+	qed_mcp_cmd(p_hwfn, p_ptt, DRV_MSG_CODE_S_TAG_UPDATE_ACK, 0,
+		    &resp, &param);
+}
+
 int qed_mcp_handle_events(struct qed_hwfn *p_hwfn,
 			  struct qed_ptt *p_ptt)
 {
@@ -1453,6 +1475,10 @@ int qed_mcp_handle_events(struct qed_hwfn *p_hwfn,
 		case MFW_DRV_MSG_BW_UPDATE:
 			qed_mcp_update_bw(p_hwfn, p_ptt);
 			break;
+		case MFW_DRV_MSG_S_TAG_UPDATE:
+			qed_mcp_update_stag(p_hwfn, p_ptt);
+			break;
+			break;
 		default:
 			DP_INFO(p_hwfn, "Unimplemented MFW message %d\n", i);
 			rc = -EINVAL;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index f14772b..6abf918 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -242,6 +242,8 @@
 	0x50196cUL
 #define NIG_REG_LLH_CLS_TYPE_DUALMODE \
 	0x501964UL
+#define NIG_REG_LLH_FUNC_TAG_EN 0x5019b0UL
+#define NIG_REG_LLH_FUNC_TAG_VALUE 0x5019d0UL
 #define NIG_REG_LLH_FUNC_FILTER_VALUE \
 	0x501a00UL
 #define NIG_REG_LLH_FUNC_FILTER_VALUE_SIZE \
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp.h b/drivers/net/ethernet/qlogic/qed/qed_sp.h
index ef77de4..b9464f3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp.h
@@ -418,6 +418,15 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 int qed_sp_pf_update(struct qed_hwfn *p_hwfn);
 
 /**
+ * @brief qed_sp_pf_update_stag - Update firmware of new outer tag
+ *
+ * @param p_hwfn
+ *
+ * @return int
+ */
+int qed_sp_pf_update_stag(struct qed_hwfn *p_hwfn);
+
+/**
  * @brief qed_sp_pf_stop - PF Function Stop Ramrod
  *
  * This ramrod is sent to close a Physical Function (PF). It is the last ramrod
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index ab09975..46d0c3c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -514,3 +514,27 @@ int qed_sp_heartbeat_ramrod(struct qed_hwfn *p_hwfn)
 
 	return qed_spq_post(p_hwfn, p_ent, NULL);
 }
+
+int qed_sp_pf_update_stag(struct qed_hwfn *p_hwfn)
+{
+	struct qed_spq_entry *p_ent = NULL;
+	struct qed_sp_init_data init_data;
+	int rc = -EINVAL;
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qed_spq_get_cid(p_hwfn);
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_CB;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
+				 COMMON_RAMROD_PF_UPDATE, PROTOCOLID_COMMON,
+				 &init_data);
+	if (rc)
+		return rc;
+
+	p_ent->ramrod.pf_update.update_mf_vlan_flag = true;
+	p_ent->ramrod.pf_update.mf_vlan = cpu_to_le16(p_hwfn->hw_info.ovlan);
+
+	return qed_spq_post(p_hwfn, p_ent, NULL);
+}
-- 
1.9.3
