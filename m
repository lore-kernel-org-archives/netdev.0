From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next] qed: Prevent stack corruption on MFW interaction
Date: Sun, 6 Nov 2016 17:12:27 +0200
Message-ID: <1478445147-23163-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:32824 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751872AbcKFPNC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2016 10:13:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver uses a union for copying data to & from management firmware
when interacting with it.
Problem is that the function always copies sizeof(union) while commit
2edbff8dcb5d ("qed: Learn resources from management firmware") is casting
a union elements which is of smaller size [24-byte instead of 88-bytes].

Also, the union contains some inappropriate elements which increase its
size [should have been 32-bytes]. While this shouldn't corrupt other
PF messages to the MFW [as management firmware enforces permissions so
that each PF is allowed to write only to its own mailbox] we fix this
here as well.

Fixes: 2edbff8dcb5d ("qed: Learn resources from management firmware")
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
Hi Dave,

This fix is intended for `net-next' [as its fixing a patch not
yet in `net'].

Thanks,
Yuval
---
 drivers/net/ethernet/qlogic/qed/qed_hsi.h |  1 -
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 16 ++++++++++++----
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 048f9a3..f5a4ebb 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -8581,7 +8581,6 @@ struct resource_info {
 	struct drv_version_stc drv_version;
 
 	struct lan_stats_stc lan_stats;
-	u64 reserved_stats[11];
 	struct ocbb_data_stc ocbb_info;
 	struct temperature_status_stc temp_info;
 	struct resource_info resource;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index d8e499e..6dd3ce4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -1697,19 +1697,27 @@ int qed_mcp_get_resc_info(struct qed_hwfn *p_hwfn,
 			  u32 *p_mcp_resp, u32 *p_mcp_param)
 {
 	struct qed_mcp_mb_params mb_params;
-	union drv_union_data *p_union_data;
+	union drv_union_data union_data;
 	int rc;
 
 	memset(&mb_params, 0, sizeof(mb_params));
+	memset(&union_data, 0, sizeof(union_data));
 	mb_params.cmd = DRV_MSG_GET_RESOURCE_ALLOC_MSG;
 	mb_params.param = QED_RESC_ALLOC_VERSION;
-	p_union_data = (union drv_union_data *)p_resc_info;
-	mb_params.p_data_src = p_union_data;
-	mb_params.p_data_dst = p_union_data;
+
+	/* Need to have a sufficient large struct, as the cmd_and_union
+	 * is going to do memcpy from and to it.
+	 */
+	memcpy(&union_data.resource, p_resc_info, sizeof(*p_resc_info));
+
+	mb_params.p_data_src = &union_data;
+	mb_params.p_data_dst = &union_data;
 	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
 	if (rc)
 		return rc;
 
+	/* Copy the data back */
+	memcpy(p_resc_info, &union_data.resource, sizeof(*p_resc_info));
 	*p_mcp_resp = mb_params.mcp_resp;
 	*p_mcp_param = mb_params.mcp_param;
 
-- 
1.9.3
