From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 05/11] qed: Add aux. function translating sb_id -> igu_sb_id
Date: Thu, 1 Jun 2017 15:29:05 +0300
Message-ID: <20170601122911.22493-6-Yuval.Mintz@cavium.com>
References: <20170601122911.22493-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0079.outbound.protection.outlook.com ([104.47.32.79]:44384
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751223AbdFAMaM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 08:30:12 -0400
In-Reply-To: <20170601122911.22493-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An additional step for relaxing the IGU order assumption, we now add
an auxiliary function that can be used for finding the HW status block
that's associated with a given MSI-x vector.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_int.c | 31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index 92744cf..3307978 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -1412,15 +1412,26 @@ void qed_int_sb_setup(struct qed_hwfn *p_hwfn,
 				    sb_info->igu_sb_id, 0, 0);
 }
 
-/**
- * @brief qed_get_igu_sb_id - given a sw sb_id return the
- *        igu_sb_id
- *
- * @param p_hwfn
- * @param sb_id
- *
- * @return u16
- */
+static u16 qed_get_pf_igu_sb_id(struct qed_hwfn *p_hwfn, u16 vector_id)
+{
+	struct qed_igu_block *p_block;
+	u16 igu_id;
+
+	for (igu_id = 0; igu_id < QED_MAPPING_MEMORY_SIZE(p_hwfn->cdev);
+	     igu_id++) {
+		p_block = &p_hwfn->hw_info.p_igu_info->entry[igu_id];
+
+		if (!(p_block->status & QED_IGU_STATUS_VALID) ||
+		    !p_block->is_pf ||
+		    p_block->vector_number != vector_id)
+			continue;
+
+		return igu_id;
+	}
+
+	return QED_SB_INVALID_IDX;
+}
+
 static u16 qed_get_igu_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id)
 {
 	u16 igu_sb_id;
@@ -1429,7 +1440,7 @@ static u16 qed_get_igu_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id)
 	if (sb_id == QED_SP_SB_ID)
 		igu_sb_id = p_hwfn->hw_info.p_igu_info->igu_dsb_id;
 	else if (IS_PF(p_hwfn->cdev))
-		igu_sb_id = sb_id + p_hwfn->hw_info.p_igu_info->igu_base_sb;
+		igu_sb_id = qed_get_pf_igu_sb_id(p_hwfn, sb_id + 1);
 	else
 		igu_sb_id = qed_vf_get_igu_sb_id(p_hwfn, sb_id);
 
-- 
2.9.4
