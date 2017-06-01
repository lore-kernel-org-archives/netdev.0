From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 01/11] qed: Make qed_int_cau_conf_pi() static
Date: Thu, 1 Jun 2017 15:29:01 +0300
Message-ID: <20170601122911.22493-2-Yuval.Mintz@cavium.com>
References: <20170601122911.22493-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0042.outbound.protection.outlook.com ([104.47.40.42]:12352
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751078AbdFAM3l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 08:29:41 -0400
In-Reply-To: <20170601122911.22493-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_int.c | 68 +++++++++++++++----------------
 drivers/net/ethernet/qlogic/qed/qed_int.h | 18 --------
 2 files changed, 34 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index 6ac6d80..9b655fa 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -1300,6 +1300,40 @@ void qed_init_cau_sb_entry(struct qed_hwfn *p_hwfn,
 	SET_FIELD(p_sb_entry->data, CAU_SB_ENTRY_STATE1, cau_state);
 }
 
+static void qed_int_cau_conf_pi(struct qed_hwfn *p_hwfn,
+				struct qed_ptt *p_ptt,
+				u16 igu_sb_id,
+				u32 pi_index,
+				enum qed_coalescing_fsm coalescing_fsm,
+				u8 timeset)
+{
+	struct cau_pi_entry pi_entry;
+	u32 sb_offset, pi_offset;
+
+	if (IS_VF(p_hwfn->cdev))
+		return;
+
+	sb_offset = igu_sb_id * PIS_PER_SB;
+	memset(&pi_entry, 0, sizeof(struct cau_pi_entry));
+
+	SET_FIELD(pi_entry.prod, CAU_PI_ENTRY_PI_TIMESET, timeset);
+	if (coalescing_fsm == QED_COAL_RX_STATE_MACHINE)
+		SET_FIELD(pi_entry.prod, CAU_PI_ENTRY_FSM_SEL, 0);
+	else
+		SET_FIELD(pi_entry.prod, CAU_PI_ENTRY_FSM_SEL, 1);
+
+	pi_offset = sb_offset + pi_index;
+	if (p_hwfn->hw_init_done) {
+		qed_wr(p_hwfn, p_ptt,
+		       CAU_REG_PI_MEMORY + pi_offset * sizeof(u32),
+		       *((u32 *)&(pi_entry)));
+	} else {
+		STORE_RT_REG(p_hwfn,
+			     CAU_REG_PI_MEMORY_RT_OFFSET + pi_offset,
+			     *((u32 *)&(pi_entry)));
+	}
+}
+
 void qed_int_cau_conf_sb(struct qed_hwfn *p_hwfn,
 			 struct qed_ptt *p_ptt,
 			 dma_addr_t sb_phys,
@@ -1366,40 +1400,6 @@ void qed_int_cau_conf_sb(struct qed_hwfn *p_hwfn,
 	}
 }
 
-void qed_int_cau_conf_pi(struct qed_hwfn *p_hwfn,
-			 struct qed_ptt *p_ptt,
-			 u16 igu_sb_id,
-			 u32 pi_index,
-			 enum qed_coalescing_fsm coalescing_fsm,
-			 u8 timeset)
-{
-	struct cau_pi_entry pi_entry;
-	u32 sb_offset, pi_offset;
-
-	if (IS_VF(p_hwfn->cdev))
-		return;
-
-	sb_offset = igu_sb_id * PIS_PER_SB;
-	memset(&pi_entry, 0, sizeof(struct cau_pi_entry));
-
-	SET_FIELD(pi_entry.prod, CAU_PI_ENTRY_PI_TIMESET, timeset);
-	if (coalescing_fsm == QED_COAL_RX_STATE_MACHINE)
-		SET_FIELD(pi_entry.prod, CAU_PI_ENTRY_FSM_SEL, 0);
-	else
-		SET_FIELD(pi_entry.prod, CAU_PI_ENTRY_FSM_SEL, 1);
-
-	pi_offset = sb_offset + pi_index;
-	if (p_hwfn->hw_init_done) {
-		qed_wr(p_hwfn, p_ptt,
-		       CAU_REG_PI_MEMORY + pi_offset * sizeof(u32),
-		       *((u32 *)&(pi_entry)));
-	} else {
-		STORE_RT_REG(p_hwfn,
-			     CAU_REG_PI_MEMORY_RT_OFFSET + pi_offset,
-			     *((u32 *)&(pi_entry)));
-	}
-}
-
 void qed_int_sb_setup(struct qed_hwfn *p_hwfn,
 		      struct qed_ptt *p_ptt, struct qed_sb_info *sb_info)
 {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.h b/drivers/net/ethernet/qlogic/qed/qed_int.h
index 0ae0bb4..a8e48e1 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.h
@@ -79,24 +79,6 @@ enum qed_coalescing_fsm {
 };
 
 /**
- * @brief qed_int_cau_conf_pi - configure cau for a given
- *        status block
- *
- * @param p_hwfn
- * @param p_ptt
- * @param igu_sb_id
- * @param pi_index
- * @param state
- * @param timeset
- */
-void qed_int_cau_conf_pi(struct qed_hwfn *p_hwfn,
-			 struct qed_ptt *p_ptt,
-			 u16 igu_sb_id,
-			 u32 pi_index,
-			 enum qed_coalescing_fsm coalescing_fsm,
-			 u8 timeset);
-
-/**
  * @brief qed_int_igu_enable_int - enable device interrupts
  *
  * @param p_hwfn
-- 
2.9.4
