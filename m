From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 02/11] qed: Minor refactoring in interrupt code
Date: Thu, 1 Jun 2017 15:29:02 +0300
Message-ID: <20170601122911.22493-3-Yuval.Mintz@cavium.com>
References: <20170601122911.22493-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0069.outbound.protection.outlook.com ([104.47.41.69]:35180
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751078AbdFAM3p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 08:29:45 -0400
In-Reply-To: <20170601122911.22493-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Separate the portions controlling interrupt enablement form those
controlling the ability of HW to generate attentions.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_int.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index 9b655fa..7ecebb6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -1616,10 +1616,9 @@ void qed_int_igu_enable_int(struct qed_hwfn *p_hwfn,
 	qed_wr(p_hwfn, p_ptt, IGU_REG_PF_CONFIGURATION, igu_pf_conf);
 }
 
-int qed_int_igu_enable(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
-		       enum qed_int_mode int_mode)
+static void qed_int_igu_enable_attn(struct qed_hwfn *p_hwfn,
+				    struct qed_ptt *p_ptt)
 {
-	int rc = 0;
 
 	/* Configure AEU signal change to produce attentions */
 	qed_wr(p_hwfn, p_ptt, IGU_REG_ATTENTION_ENABLE, 0);
@@ -1632,6 +1631,16 @@ int qed_int_igu_enable(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 
 	/* Unmask AEU signals toward IGU */
 	qed_wr(p_hwfn, p_ptt, MISC_REG_AEU_MASK_ATTN_IGU, 0xff);
+}
+
+int
+qed_int_igu_enable(struct qed_hwfn *p_hwfn,
+		   struct qed_ptt *p_ptt, enum qed_int_mode int_mode)
+{
+	int rc = 0;
+
+	qed_int_igu_enable_attn(p_hwfn, p_ptt);
+
 	if ((int_mode != QED_INT_MODE_INTA) || IS_LEAD_HWFN(p_hwfn)) {
 		rc = qed_slowpath_irq_req(p_hwfn);
 		if (rc) {
-- 
2.9.4
