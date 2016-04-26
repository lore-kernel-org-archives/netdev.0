From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 2/3] qed: Add PF max bandwidth configuration support
Date: Tue, 26 Apr 2016 10:56:09 -0400
Message-ID: <1461682570-745-3-git-send-email-manish.chopra@qlogic.com>
References: <1461682570-745-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:57832 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752215AbcDZPiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 11:38:14 -0400
In-Reply-To: <1461682570-745-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for PF maximum bandwidth update
or configuration notified by management firmware.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c |  68 ++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h |   2 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 138 ++++++++++++++++++------------
 drivers/net/ethernet/qlogic/qed/qed_mcp.h |  14 ++-
 4 files changed, 165 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 28e0619..4e99108 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -579,7 +579,7 @@ static int qed_hw_init_pf(struct qed_hwfn *p_hwfn,
 			p_hwfn->qm_info.pf_wfq = p_info->bandwidth_min;
 
 		/* Update rate limit once we'll actually have a link */
-		p_hwfn->qm_info.pf_rl = 100;
+		p_hwfn->qm_info.pf_rl = 100000;
 	}
 
 	qed_cxt_hw_init_pf(p_hwfn);
@@ -1775,3 +1775,69 @@ void qed_configure_vp_wfq_on_link_change(struct qed_dev *cdev, u32 min_pf_rate)
 						      min_pf_rate);
 	}
 }
+
+int __qed_configure_pf_max_bandwidth(struct qed_hwfn *p_hwfn,
+				     struct qed_ptt *p_ptt,
+				     struct qed_mcp_link_state *p_link,
+				     u8 max_bw)
+{
+	int rc = 0;
+
+	p_hwfn->mcp_info->func_info.bandwidth_max = max_bw;
+
+	if (!p_link->line_speed && (max_bw != 100))
+		return rc;
+
+	p_link->speed = (p_link->line_speed * max_bw) / 100;
+	p_hwfn->qm_info.pf_rl = p_link->speed;
+
+	/* Since the limiter also affects Tx-switched traffic, we don't want it
+	 * to limit such traffic in case there's no actual limit.
+	 * In that case, set limit to imaginary high boundary.
+	 */
+	if (max_bw == 100)
+		p_hwfn->qm_info.pf_rl = 100000;
+
+	rc = qed_init_pf_rl(p_hwfn, p_ptt, p_hwfn->rel_pf_id,
+			    p_hwfn->qm_info.pf_rl);
+
+	DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
+		   "Configured MAX bandwidth to be %08x Mb/sec\n",
+		   p_link->speed);
+
+	return rc;
+}
+
+/* Main API to configure PF max bandwidth where bw range is [1 - 100] */
+int qed_configure_pf_max_bandwidth(struct qed_dev *cdev, u8 max_bw)
+{
+	int i, rc = -EINVAL;
+
+	if (max_bw < 1 || max_bw > 100) {
+		DP_NOTICE(cdev, "PF max bw valid range is [1-100]\n");
+		return rc;
+	}
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn	*p_hwfn = &cdev->hwfns[i];
+		struct qed_hwfn *p_lead = QED_LEADING_HWFN(cdev);
+		struct qed_mcp_link_state *p_link;
+		struct qed_ptt *p_ptt;
+
+		p_link = &p_lead->mcp_info->link_output;
+
+		p_ptt = qed_ptt_acquire(p_hwfn);
+		if (!p_ptt)
+			return -EBUSY;
+
+		rc = __qed_configure_pf_max_bandwidth(p_hwfn, p_ptt,
+						      p_link, max_bw);
+
+		qed_ptt_release(p_hwfn, p_ptt);
+
+		if (rc)
+			break;
+	}
+
+	return rc;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 7d5ed0c..81cf625 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -3837,7 +3837,7 @@ struct public_drv_mb {
 
 #define DRV_MSG_CODE_SET_LLDP                   0x24000000
 #define DRV_MSG_CODE_SET_DCBX                   0x25000000
-
+#define DRV_MSG_CODE_BW_UPDATE_ACK		0x32000000
 #define DRV_MSG_CODE_NIG_DRAIN                  0x30000000
 
 #define DRV_MSG_CODE_INITIATE_FLR               0x02000000
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index b89c9a8..578b09c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -473,6 +473,7 @@ static void qed_mcp_handle_link_change(struct qed_hwfn *p_hwfn,
 {
 	struct qed_mcp_link_state *p_link;
 	u32 status = 0;
+	u8 max_bw;
 
 	p_link = &p_hwfn->mcp_info->link_output;
 	memset(p_link, 0, sizeof(*p_link));
@@ -527,17 +528,15 @@ static void qed_mcp_handle_link_change(struct qed_hwfn *p_hwfn,
 		p_link->speed = 0;
 	}
 
+	if (p_link->link_up && p_link->speed)
+		p_link->line_speed = p_link->speed;
+	else
+		p_link->line_speed = 0;
+
+	max_bw = p_hwfn->mcp_info->func_info.bandwidth_max;
+
 	/* Correct speed according to bandwidth allocation */
-	if (p_hwfn->mcp_info->func_info.bandwidth_max && p_link->speed) {
-		p_link->speed = p_link->speed *
-				p_hwfn->mcp_info->func_info.bandwidth_max /
-				100;
-		qed_init_pf_rl(p_hwfn, p_ptt, p_hwfn->rel_pf_id,
-			       p_link->speed);
-		DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
-			   "Configured MAX bandwidth to be %08x Mb/sec\n",
-			   p_link->speed);
-	}
+	__qed_configure_pf_max_bandwidth(p_hwfn, p_ptt, p_link, max_bw);
 
 	p_link->an = !!(status & LINK_STATUS_AUTO_NEGOTIATE_ENABLED);
 	p_link->an_complete = !!(status &
@@ -648,6 +647,76 @@ int qed_mcp_set_link(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
+static void qed_read_pf_bandwidth(struct qed_hwfn *p_hwfn,
+				  struct public_func *p_shmem_info)
+{
+	struct qed_mcp_function_info *p_info;
+
+	p_info = &p_hwfn->mcp_info->func_info;
+
+	p_info->bandwidth_min = (p_shmem_info->config &
+				 FUNC_MF_CFG_MIN_BW_MASK) >>
+					FUNC_MF_CFG_MIN_BW_SHIFT;
+	if (p_info->bandwidth_min < 1 || p_info->bandwidth_min > 100) {
+		DP_INFO(p_hwfn,
+			"bandwidth minimum out of bounds [%02x]. Set to 1\n",
+			p_info->bandwidth_min);
+		p_info->bandwidth_min = 1;
+	}
+
+	p_info->bandwidth_max = (p_shmem_info->config &
+				 FUNC_MF_CFG_MAX_BW_MASK) >>
+					FUNC_MF_CFG_MAX_BW_SHIFT;
+	if (p_info->bandwidth_max < 1 || p_info->bandwidth_max > 100) {
+		DP_INFO(p_hwfn,
+			"bandwidth maximum out of bounds [%02x]. Set to 100\n",
+			p_info->bandwidth_max);
+		p_info->bandwidth_max = 100;
+	}
+}
+
+static u32 qed_mcp_get_shmem_func(struct qed_hwfn *p_hwfn,
+				  struct qed_ptt *p_ptt,
+				  struct public_func *p_data,
+				  int pfid)
+{
+	u32 addr = SECTION_OFFSIZE_ADDR(p_hwfn->mcp_info->public_base,
+					PUBLIC_FUNC);
+	u32 mfw_path_offsize = qed_rd(p_hwfn, p_ptt, addr);
+	u32 func_addr = SECTION_ADDR(mfw_path_offsize, pfid);
+	u32 i, size;
+
+	memset(p_data, 0, sizeof(*p_data));
+
+	size = min_t(u32, sizeof(*p_data),
+		     QED_SECTION_SIZE(mfw_path_offsize));
+	for (i = 0; i < size / sizeof(u32); i++)
+		((u32 *)p_data)[i] = qed_rd(p_hwfn, p_ptt,
+					    func_addr + (i << 2));
+	return size;
+}
+
+static void qed_mcp_update_bw(struct qed_hwfn *p_hwfn,
+			      struct qed_ptt *p_ptt)
+{
+	struct qed_mcp_function_info *p_info;
+	struct public_func shmem_info;
+	u32 resp = 0, param = 0;
+
+	qed_mcp_get_shmem_func(p_hwfn, p_ptt, &shmem_info,
+			       MCP_PF_ID(p_hwfn));
+
+	qed_read_pf_bandwidth(p_hwfn, &shmem_info);
+
+	p_info = &p_hwfn->mcp_info->func_info;
+
+	qed_configure_pf_max_bandwidth(p_hwfn->cdev, p_info->bandwidth_max);
+
+	/* Acknowledge the MFW */
+	qed_mcp_cmd(p_hwfn, p_ptt, DRV_MSG_CODE_BW_UPDATE_ACK, 0, &resp,
+		    &param);
+}
+
 int qed_mcp_handle_events(struct qed_hwfn *p_hwfn,
 			  struct qed_ptt *p_ptt)
 {
@@ -679,6 +748,9 @@ int qed_mcp_handle_events(struct qed_hwfn *p_hwfn,
 		case MFW_DRV_MSG_TRANSCEIVER_STATE_CHANGE:
 			qed_mcp_handle_transceiver_change(p_hwfn, p_ptt);
 			break;
+		case MFW_DRV_MSG_BW_UPDATE:
+			qed_mcp_update_bw(p_hwfn, p_ptt);
+			break;
 		default:
 			DP_NOTICE(p_hwfn, "Unimplemented MFW message %d\n", i);
 			rc = -EINVAL;
@@ -758,28 +830,6 @@ int qed_mcp_get_media_type(struct qed_dev *cdev,
 	return 0;
 }
 
-static u32 qed_mcp_get_shmem_func(struct qed_hwfn *p_hwfn,
-				  struct qed_ptt *p_ptt,
-				  struct public_func *p_data,
-				  int pfid)
-{
-	u32 addr = SECTION_OFFSIZE_ADDR(p_hwfn->mcp_info->public_base,
-					PUBLIC_FUNC);
-	u32 mfw_path_offsize = qed_rd(p_hwfn, p_ptt, addr);
-	u32 func_addr = SECTION_ADDR(mfw_path_offsize, pfid);
-	u32 i, size;
-
-	memset(p_data, 0, sizeof(*p_data));
-
-	size = min_t(u32, sizeof(*p_data),
-		     QED_SECTION_SIZE(mfw_path_offsize));
-	for (i = 0; i < size / sizeof(u32); i++)
-		((u32 *)p_data)[i] = qed_rd(p_hwfn, p_ptt,
-					    func_addr + (i << 2));
-
-	return size;
-}
-
 static int
 qed_mcp_get_shmem_proto(struct qed_hwfn *p_hwfn,
 			struct public_func *p_info,
@@ -818,26 +868,7 @@ int qed_mcp_fill_shmem_func_info(struct qed_hwfn *p_hwfn,
 		return -EINVAL;
 	}
 
-
-	info->bandwidth_min = (shmem_info.config &
-			       FUNC_MF_CFG_MIN_BW_MASK) >>
-			      FUNC_MF_CFG_MIN_BW_SHIFT;
-	if (info->bandwidth_min < 1 || info->bandwidth_min > 100) {
-		DP_INFO(p_hwfn,
-			"bandwidth minimum out of bounds [%02x]. Set to 1\n",
-			info->bandwidth_min);
-		info->bandwidth_min = 1;
-	}
-
-	info->bandwidth_max = (shmem_info.config &
-			       FUNC_MF_CFG_MAX_BW_MASK) >>
-			      FUNC_MF_CFG_MAX_BW_SHIFT;
-	if (info->bandwidth_max < 1 || info->bandwidth_max > 100) {
-		DP_INFO(p_hwfn,
-			"bandwidth maximum out of bounds [%02x]. Set to 100\n",
-			info->bandwidth_max);
-		info->bandwidth_max = 100;
-	}
+	qed_read_pf_bandwidth(p_hwfn, &shmem_info);
 
 	if (shmem_info.mac_upper || shmem_info.mac_lower) {
 		info->mac[0] = (u8)(shmem_info.mac_upper >> 8);
@@ -938,9 +969,10 @@ qed_mcp_send_drv_version(struct qed_hwfn *p_hwfn,
 
 	p_drv_version = &union_data.drv_version;
 	p_drv_version->version = p_ver->version;
+
 	for (i = 0; i < MCP_DRV_VER_STR_SIZE - 1; i += 4) {
 		val = cpu_to_be32(p_ver->name[i]);
-		*(u32 *)&p_drv_version->name[i * sizeof(u32)] = val;
+		*(__be32 *)&p_drv_version->name[i * sizeof(u32)] = val;
 	}
 
 	memset(&mb_params, 0, sizeof(mb_params));
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index 50917a2..29a51ad 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -40,7 +40,13 @@ struct qed_mcp_link_capabilities {
 struct qed_mcp_link_state {
 	bool    link_up;
 
-	u32     speed; /* In Mb/s */
+	/* Actual link speed in Mb/s */
+	u32	line_speed;
+
+	/* PF max speed in Mb/s, deduced from line_speed
+	 * according to PF max bandwidth configuration.
+	 */
+	u32     speed;
 	bool    full_duplex;
 
 	bool    an;
@@ -388,5 +394,9 @@ int qed_mcp_reset(struct qed_hwfn *p_hwfn,
  * @return true iff MFW is running and mcp_info is initialized
  */
 bool qed_mcp_is_init(struct qed_hwfn *p_hwfn);
-
+int qed_configure_pf_max_bandwidth(struct qed_dev *cdev, u8 max_bw);
+int __qed_configure_pf_max_bandwidth(struct qed_hwfn *p_hwfn,
+				     struct qed_ptt *p_ptt,
+				     struct qed_mcp_link_state *p_link,
+				     u8 max_bw);
 #endif
-- 
2.7.2
