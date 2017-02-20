From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 09/10] qed: Don't allocate SBs using main PTT
Date: Mon, 20 Feb 2017 22:43:38 +0200
Message-ID: <1487623419-6442-10-git-send-email-Yuval.Mintz@cavium.com>
References: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46409 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751119AbdBTU7b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 15:59:31 -0500
In-Reply-To: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flows accessing registers require the flow to hold a PTT entry.
To protect 'major' load/unload flows a main_ptt is pre-allocated
to guarantee such flows wouldn't be blocked by PTT being
unavailable.

Status block initialization currently uses the main_ptt which
is incorrect, as this flow might run concurrently to others
[E.g., loading qedr while toggling qede]. That would have dire
effects as it means registers' access to device breaks and further
read/writes might access incorrect addresses.

Instead, when initializing status blocks acquire/release a PTT
as part of the flow.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 942c03c..4440ae7 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1072,6 +1072,7 @@ static u32 qed_sb_init(struct qed_dev *cdev,
 		       enum qed_sb_type type)
 {
 	struct qed_hwfn *p_hwfn;
+	struct qed_ptt *p_ptt;
 	int hwfn_index;
 	u16 rel_sb_id;
 	u8 n_hwfns;
@@ -1093,8 +1094,18 @@ static u32 qed_sb_init(struct qed_dev *cdev,
 		   "hwfn [%d] <--[init]-- SB %04x [0x%04x upper]\n",
 		   hwfn_index, rel_sb_id, sb_id);
 
-	rc = qed_int_sb_init(p_hwfn, p_hwfn->p_main_ptt, sb_info,
-			     sb_virt_addr, sb_phy_addr, rel_sb_id);
+	if (IS_PF(p_hwfn->cdev)) {
+		p_ptt = qed_ptt_acquire(p_hwfn);
+		if (!p_ptt)
+			return -EBUSY;
+
+		rc = qed_int_sb_init(p_hwfn, p_ptt, sb_info, sb_virt_addr,
+				     sb_phy_addr, rel_sb_id);
+		qed_ptt_release(p_hwfn, p_ptt);
+	} else {
+		rc = qed_int_sb_init(p_hwfn, NULL, sb_info, sb_virt_addr,
+				     sb_phy_addr, rel_sb_id);
+	}
 
 	return rc;
 }
-- 
1.9.3
