From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 7/7] qed: Use BDQ resource for storage protocols
Date: Tue, 28 Mar 2017 15:12:56 +0300
Message-ID: <1490703176-429-8-git-send-email-Yuval.Mintz@cavium.com>
References: <1490703176-429-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:41217 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752028AbdC1MNp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 08:13:45 -0400
In-Reply-To: <1490703176-429-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Until now, qed used some port-defined value as BDQ index for both iSCSI
and FCoE.

As management firmware now treats BDQ as a resource and tells each PF
its BDQ-range, start using a valure from that range instead.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h       |  2 --
 drivers/net/ethernet/qlogic/qed/qed_fcoe.c  | 30 +++++++++++++++++++--------
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c | 32 +++++++++++++++++++----------
 3 files changed, 42 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index cf71295..8c85fd2 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -71,8 +71,6 @@
 
 #define QED_WFQ_UNIT	100
 
-#define ISCSI_BDQ_ID(_port_id) (_port_id)
-#define FCOE_BDQ_ID(_port_id) ((_port_id) + 2)
 #define QED_WID_SIZE            (1024)
 #define QED_PF_DEMS_SIZE        (4)
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_fcoe.c b/drivers/net/ethernet/qlogic/qed/qed_fcoe.c
index cbc8141..60921b7 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_fcoe.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_fcoe.c
@@ -191,7 +191,7 @@ struct qed_fcoe_conn {
 	p_data->q_params.cq_sb_pi = fcoe_pf_params->gl_rq_pi;
 	p_data->q_params.cmdq_sb_pi = fcoe_pf_params->gl_cmd_pi;
 
-	p_data->q_params.bdq_resource_id = FCOE_BDQ_ID(p_hwfn->port_id);
+	p_data->q_params.bdq_resource_id = (u8)RESC_START(p_hwfn, QED_BDQ);
 
 	DMA_REGPAIR_LE(p_data->q_params.bdq_pbl_base_address[BDQ_ID_RQ],
 		       fcoe_pf_params->bdq_pbl_base_addr[BDQ_ID_RQ]);
@@ -512,19 +512,31 @@ static void __iomem *qed_fcoe_get_db_addr(struct qed_hwfn *p_hwfn, u32 cid)
 static void __iomem *qed_fcoe_get_primary_bdq_prod(struct qed_hwfn *p_hwfn,
 						   u8 bdq_id)
 {
-	u8 bdq_function_id = FCOE_BDQ_ID(p_hwfn->port_id);
-
-	return (u8 __iomem *)p_hwfn->regview + GTT_BAR0_MAP_REG_MSDM_RAM +
-	       MSTORM_SCSI_BDQ_EXT_PROD_OFFSET(bdq_function_id, bdq_id);
+	if (RESC_NUM(p_hwfn, QED_BDQ)) {
+		return (u8 __iomem *)p_hwfn->regview +
+		       GTT_BAR0_MAP_REG_MSDM_RAM +
+		       MSTORM_SCSI_BDQ_EXT_PROD_OFFSET(RESC_START(p_hwfn,
+								  QED_BDQ),
+						       bdq_id);
+	} else {
+		DP_NOTICE(p_hwfn, "BDQ is not allocated!\n");
+		return NULL;
+	}
 }
 
 static void __iomem *qed_fcoe_get_secondary_bdq_prod(struct qed_hwfn *p_hwfn,
 						     u8 bdq_id)
 {
-	u8 bdq_function_id = FCOE_BDQ_ID(p_hwfn->port_id);
-
-	return (u8 __iomem *)p_hwfn->regview + GTT_BAR0_MAP_REG_TSDM_RAM +
-	       TSTORM_SCSI_BDQ_EXT_PROD_OFFSET(bdq_function_id, bdq_id);
+	if (RESC_NUM(p_hwfn, QED_BDQ)) {
+		return (u8 __iomem *)p_hwfn->regview +
+		       GTT_BAR0_MAP_REG_TSDM_RAM +
+		       TSTORM_SCSI_BDQ_EXT_PROD_OFFSET(RESC_START(p_hwfn,
+								  QED_BDQ),
+						       bdq_id);
+	} else {
+		DP_NOTICE(p_hwfn, "BDQ is not allocated!\n");
+		return NULL;
+	}
 }
 
 struct qed_fcoe_info *qed_fcoe_alloc(struct qed_hwfn *p_hwfn)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
index 098766f..2f8ac75 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
@@ -216,7 +216,7 @@ struct qed_iscsi_conn {
 		p_queue->cq_cmdq_sb_num_arr[i] = cpu_to_le16(val);
 	}
 
-	p_queue->bdq_resource_id = ISCSI_BDQ_ID(p_hwfn->port_id);
+	p_queue->bdq_resource_id = (u8)RESC_START(p_hwfn, QED_BDQ);
 
 	DMA_REGPAIR_LE(p_queue->bdq_pbl_base_address[BDQ_ID_RQ],
 		       p_params->bdq_pbl_base_addr[BDQ_ID_RQ]);
@@ -593,21 +593,31 @@ static void __iomem *qed_iscsi_get_db_addr(struct qed_hwfn *p_hwfn, u32 cid)
 static void __iomem *qed_iscsi_get_primary_bdq_prod(struct qed_hwfn *p_hwfn,
 						    u8 bdq_id)
 {
-	u8 bdq_function_id = ISCSI_BDQ_ID(p_hwfn->port_id);
-
-	return (u8 __iomem *)p_hwfn->regview + GTT_BAR0_MAP_REG_MSDM_RAM +
-			     MSTORM_SCSI_BDQ_EXT_PROD_OFFSET(bdq_function_id,
-							     bdq_id);
+	if (RESC_NUM(p_hwfn, QED_BDQ)) {
+		return (u8 __iomem *)p_hwfn->regview +
+		       GTT_BAR0_MAP_REG_MSDM_RAM +
+		       MSTORM_SCSI_BDQ_EXT_PROD_OFFSET(RESC_START(p_hwfn,
+								  QED_BDQ),
+						       bdq_id);
+	} else {
+		DP_NOTICE(p_hwfn, "BDQ is not allocated!\n");
+		return NULL;
+	}
 }
 
 static void __iomem *qed_iscsi_get_secondary_bdq_prod(struct qed_hwfn *p_hwfn,
 						      u8 bdq_id)
 {
-	u8 bdq_function_id = ISCSI_BDQ_ID(p_hwfn->port_id);
-
-	return (u8 __iomem *)p_hwfn->regview + GTT_BAR0_MAP_REG_TSDM_RAM +
-			     TSTORM_SCSI_BDQ_EXT_PROD_OFFSET(bdq_function_id,
-							     bdq_id);
+	if (RESC_NUM(p_hwfn, QED_BDQ)) {
+		return (u8 __iomem *)p_hwfn->regview +
+		       GTT_BAR0_MAP_REG_TSDM_RAM +
+		       TSTORM_SCSI_BDQ_EXT_PROD_OFFSET(RESC_START(p_hwfn,
+								  QED_BDQ),
+						       bdq_id);
+	} else {
+		DP_NOTICE(p_hwfn, "BDQ is not allocated!\n");
+		return NULL;
+	}
 }
 
 static int qed_iscsi_setup_connection(struct qed_hwfn *p_hwfn,
-- 
1.9.3
