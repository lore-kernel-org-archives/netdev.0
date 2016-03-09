From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 3/4] qed: Notify of transciever changes
Date: Wed, 9 Mar 2016 09:16:25 +0200
Message-ID: <1457507786-6603-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1457507786-6603-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zvi Nachmani <Zvi.Nachmani@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:40555 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752589AbcCIHQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 02:16:58 -0500
In-Reply-To: <1457507786-6603-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zvi Nachmani <Zvi.Nachmani@qlogic.com>

Handle a new message from the MFW, one that indicate that the transciever
state has changed, and log that into the system logs.

Signed-off-by: Zvi Nachmani <Zvi.Nachmani@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_hsi.h | 11 +++++++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 30 ++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 592e0e6..6296747 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -3609,6 +3609,9 @@ struct public_port {
 	u32					fc_npiv_nvram_tbl_addr;
 	u32					fc_npiv_nvram_tbl_size;
 	u32					transceiver_data;
+#define PMM_TRANSCEIVER_STATE_MASK		0x000000FF
+#define PMM_TRANSCEIVER_STATE_SHIFT		0x00000000
+#define PMM_TRANSCEIVER_STATE_PRESENT		0x00000001
 };
 
 /**************************************/
@@ -3943,6 +3946,14 @@ enum MFW_DRV_MSG_TYPE {
 	MFW_DRV_MSG_DCBX_REMOTE_MIB_UPDATED,
 	MFW_DRV_MSG_DCBX_OPERATIONAL_MIB_UPDATED,
 	MFW_DRV_MSG_ERROR_RECOVERY,
+	MFW_DRV_MSG_BW_UPDATE,
+	MFW_DRV_MSG_S_TAG_UPDATE,
+	MFW_DRV_MSG_GET_LAN_STATS,
+	MFW_DRV_MSG_GET_FCOE_STATS,
+	MFW_DRV_MSG_GET_ISCSI_STATS,
+	MFW_DRV_MSG_GET_RDMA_STATS,
+	MFW_DRV_MSG_FAILURE_DETECTED,
+	MFW_DRV_MSG_TRANSCEIVER_STATE_CHANGE,
 	MFW_DRV_MSG_MAX
 };
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 6937c88..39c831d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -440,6 +440,33 @@ int qed_mcp_load_req(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
+static void qed_mcp_handle_transceiver_change(struct qed_hwfn *p_hwfn,
+					      struct qed_ptt *p_ptt)
+{
+	u32 transceiver_state;
+
+	transceiver_state = qed_rd(p_hwfn, p_ptt,
+				   p_hwfn->mcp_info->port_addr +
+				   offsetof(struct public_port,
+					    transceiver_data));
+
+	DP_VERBOSE(p_hwfn,
+		   (NETIF_MSG_HW | QED_MSG_SP),
+		   "Received transceiver state update [0x%08x] from mfw [Addr 0x%x]\n",
+		   transceiver_state,
+		   (u32)(p_hwfn->mcp_info->port_addr +
+			 offsetof(struct public_port,
+				  transceiver_data)));
+
+	transceiver_state = GET_FIELD(transceiver_state,
+				      PMM_TRANSCEIVER_STATE);
+
+	if (transceiver_state == PMM_TRANSCEIVER_STATE_PRESENT)
+		DP_NOTICE(p_hwfn, "Transceiver is present.\n");
+	else
+		DP_NOTICE(p_hwfn, "Transceiver is unplugged.\n");
+}
+
 static void qed_mcp_handle_link_change(struct qed_hwfn *p_hwfn,
 				       struct qed_ptt *p_ptt,
 				       bool b_reset)
@@ -649,6 +676,9 @@ int qed_mcp_handle_events(struct qed_hwfn *p_hwfn,
 		case MFW_DRV_MSG_LINK_CHANGE:
 			qed_mcp_handle_link_change(p_hwfn, p_ptt, false);
 			break;
+		case MFW_DRV_MSG_TRANSCEIVER_STATE_CHANGE:
+			qed_mcp_handle_transceiver_change(p_hwfn, p_ptt);
+			break;
 		default:
 			DP_NOTICE(p_hwfn, "Unimplemented MFW message %d\n", i);
 			rc = -EINVAL;
-- 
1.9.3
