From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 1/8] qed: Warn PTT usage by wrong hw-function
Date: Thu, 6 Apr 2017 15:58:28 +0300
Message-ID: <1491483515-13502-2-git-send-email-Yuval.Mintz@cavium.com>
References: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53174 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754270AbdDFM7D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 08:59:03 -0400
In-Reply-To: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PTT entries are per-hwfn; If some errneous flow is trying
to use a PTT belonging to a differnet hwfn warn user, as this
can break every register accessing flow later and is very hard
to root-cause.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_hw.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_hw.c b/drivers/net/ethernet/qlogic/qed/qed_hw.c
index 79e584a..a05feb3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hw.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_hw.c
@@ -58,6 +58,7 @@ struct qed_ptt {
 	struct list_head	list_entry;
 	unsigned int		idx;
 	struct pxp_ptt_entry	pxp;
+	u8			hwfn_id;
 };
 
 struct qed_ptt_pool {
@@ -79,6 +80,7 @@ int qed_ptt_pool_alloc(struct qed_hwfn *p_hwfn)
 		p_pool->ptts[i].idx = i;
 		p_pool->ptts[i].pxp.offset = QED_BAR_INVALID_OFFSET;
 		p_pool->ptts[i].pxp.pretend.control = 0;
+		p_pool->ptts[i].hwfn_id = p_hwfn->my_id;
 		if (i >= RESERVED_PTT_MAX)
 			list_add(&p_pool->ptts[i].list_entry,
 				 &p_pool->free_list);
@@ -193,6 +195,11 @@ static u32 qed_set_ptt(struct qed_hwfn *p_hwfn,
 
 	offset = hw_addr - win_hw_addr;
 
+	if (p_ptt->hwfn_id != p_hwfn->my_id)
+		DP_NOTICE(p_hwfn,
+			  "ptt[%d] of hwfn[%02x] is used by hwfn[%02x]!\n",
+			  p_ptt->idx, p_ptt->hwfn_id, p_hwfn->my_id);
+
 	/* Verify the address is within the window */
 	if (hw_addr < win_hw_addr ||
 	    offset >= PXP_EXTERNAL_BAR_PF_WINDOW_SINGLE_SIZE) {
-- 
1.9.3
