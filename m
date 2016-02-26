From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 04/10] bnxt_en: Refactor bnxt_hwrm_set_coal().
Date: Fri, 26 Feb 2016 04:00:02 -0500
Message-ID: <1456477208-30692-5-git-send-email-michael.chan@broadcom.com>
References: <1456477208-30692-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:48151
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751255AbcBZJAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 04:00:47 -0500
In-Reply-To: <1456477208-30692-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a function to set all the coalescing parameters.  The function can
be used later to set both rx and tx coalescing parameters.

v2: Fixed function parameters formatting requested by DaveM.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index a7103b5..a391c9c 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3521,6 +3521,21 @@ static void bnxt_hwrm_ring_free(struct bnxt *bp, bool close_path)
 	}
 }
 
+static void bnxt_hwrm_set_coal_params(struct bnxt *bp, u32 max_bufs,
+	u32 buf_tmrs, u16 flags,
+	struct hwrm_ring_cmpl_ring_cfg_aggint_params_input *req)
+{
+	req->flags = cpu_to_le16(flags);
+	req->num_cmpl_dma_aggr = cpu_to_le16((u16)max_bufs);
+	req->num_cmpl_dma_aggr_during_int = cpu_to_le16(max_bufs >> 16);
+	req->cmpl_aggr_dma_tmr = cpu_to_le16((u16)buf_tmrs);
+	req->cmpl_aggr_dma_tmr_during_int = cpu_to_le16(buf_tmrs >> 16);
+	/* Minimum time between 2 interrupts set to buf_tmr x 2 */
+	req->int_lat_tmr_min = cpu_to_le16((u16)buf_tmrs * 2);
+	req->int_lat_tmr_max = cpu_to_le16((u16)buf_tmrs * 4);
+	req->num_cmpl_aggr_int = cpu_to_le16((u16)max_bufs * 4);
+}
+
 int bnxt_hwrm_set_coal(struct bnxt *bp)
 {
 	int i, rc = 0;
@@ -3553,15 +3568,8 @@ int bnxt_hwrm_set_coal(struct bnxt *bp)
 	if (bp->rx_coal_ticks < 25)
 		flags |= RING_CMPL_RING_CFG_AGGINT_PARAMS_REQ_FLAGS_RING_IDLE;
 
-	req.flags = cpu_to_le16(flags);
-	req.num_cmpl_dma_aggr = cpu_to_le16(max_buf);
-	req.num_cmpl_dma_aggr_during_int = cpu_to_le16(max_buf_irq);
-	req.cmpl_aggr_dma_tmr = cpu_to_le16(buf_tmr);
-	req.cmpl_aggr_dma_tmr_during_int = cpu_to_le16(buf_tmr_irq);
-	/* Minimum time between 2 interrupts set to buf_tmr x 2 */
-	req.int_lat_tmr_min = cpu_to_le16(buf_tmr * 2);
-	req.int_lat_tmr_max = cpu_to_le16(buf_tmr * 4);
-	req.num_cmpl_aggr_int = cpu_to_le16(max_buf * 4);
+	bnxt_hwrm_set_coal_params(bp, max_buf_irq << 16 | max_buf,
+				  buf_tmr_irq << 16 | buf_tmr, flags, &req);
 
 	mutex_lock(&bp->hwrm_cmd_lock);
 	for (i = 0; i < bp->cp_nr_rings; i++) {
-- 
1.8.3.1
