From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH 2/2] qed: Don't use attention PTT for configuring BW
Date: Mon, 27 Feb 2017 11:06:33 +0200
Message-ID: <1488186393-3938-3-git-send-email-Yuval.Mintz@cavium.com>
References: <1488186393-3938-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:57051 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751700AbdB0JGy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 04:06:54 -0500
In-Reply-To: <1488186393-3938-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 653d2ffd6405 ("qed*: Fix link indication race") introduced another
race - one of the inner functions called from the link-change flow is
explicitly using the slowpath context dedicated PTT instead of gaining
that PTT from the caller. Since this flow can now be called from
a different context as well, we're in risk of the PTT breaking.

Fixes: 653d2ffd6405 ("qed*: Fix link indication race")
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h     | 4 +++-
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 6 +++---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 3 ++-
 3 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 61a9cd5..00c17fa 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -688,7 +688,9 @@ static inline u8 qed_concrete_to_sw_fid(struct qed_dev *cdev,
 #define OOO_LB_TC 9
 
 int qed_configure_vport_wfq(struct qed_dev *cdev, u16 vp_id, u32 rate);
-void qed_configure_vp_wfq_on_link_change(struct qed_dev *cdev, u32 min_pf_rate);
+void qed_configure_vp_wfq_on_link_change(struct qed_dev *cdev,
+					 struct qed_ptt *p_ptt,
+					 u32 min_pf_rate);
 
 void qed_clean_wfq_db(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
 #define QED_LEADING_HWFN(dev)   (&dev->hwfns[0])
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index d6c5a81..e2a081c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -3198,7 +3198,8 @@ int qed_configure_vport_wfq(struct qed_dev *cdev, u16 vp_id, u32 rate)
 }
 
 /* API to configure WFQ from mcp link change */
-void qed_configure_vp_wfq_on_link_change(struct qed_dev *cdev, u32 min_pf_rate)
+void qed_configure_vp_wfq_on_link_change(struct qed_dev *cdev,
+					 struct qed_ptt *p_ptt, u32 min_pf_rate)
 {
 	int i;
 
@@ -3212,8 +3213,7 @@ void qed_configure_vp_wfq_on_link_change(struct qed_dev *cdev, u32 min_pf_rate)
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
-		__qed_configure_vp_wfq_on_link_change(p_hwfn,
-						      p_hwfn->p_dpc_ptt,
+		__qed_configure_vp_wfq_on_link_change(p_hwfn, p_ptt,
 						      min_pf_rate);
 	}
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 314022d..87fde20 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -679,7 +679,8 @@ static void qed_mcp_handle_link_change(struct qed_hwfn *p_hwfn,
 
 	/* Min bandwidth configuration */
 	__qed_configure_pf_min_bandwidth(p_hwfn, p_ptt, p_link, min_bw);
-	qed_configure_vp_wfq_on_link_change(p_hwfn->cdev, p_link->min_pf_rate);
+	qed_configure_vp_wfq_on_link_change(p_hwfn->cdev, p_ptt,
+					    p_link->min_pf_rate);
 
 	p_link->an = !!(status & LINK_STATUS_AUTO_NEGOTIATE_ENABLED);
 	p_link->an_complete = !!(status &
-- 
1.9.3
