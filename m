From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 2/2] bnxt_en: Add workaround to detect bad opaque in rx completion (part 2)
Date: Tue, 10 May 2016 19:18:00 -0400
Message-ID: <1462922280-17851-3-git-send-email-michael.chan@broadcom.com>
References: <1462922280-17851-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36228 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406AbcEJXSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 19:18:12 -0400
Received: by mail-pf0-f182.google.com with SMTP id c189so11270820pfb.3
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 16:18:12 -0700 (PDT)
In-Reply-To: <1462922280-17851-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add detection and recovery code when the hardware returned opaque value
does not match the expected consumer index.  Once the issue is detected,
we skip the processing of all RX and LRO/GRO packets.  These completion
entries are discarded without sending the SKB to the stack and without
producing new buffers.  The function will be reset from a workqueue.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 60 +++++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  1 +
 2 files changed, 61 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 58999cd..c39a7f5 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -813,6 +813,46 @@ static inline struct sk_buff *bnxt_copy_skb(struct bnxt_napi *bnapi, u8 *data,
 	return skb;
 }
 
+static int bnxt_discard_rx(struct bnxt *bp, struct bnxt_napi *bnapi,
+			   u32 *raw_cons, void *cmp)
+{
+	struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
+	struct rx_cmp *rxcmp = cmp;
+	u32 tmp_raw_cons = *raw_cons;
+	u8 cmp_type, agg_bufs = 0;
+
+	cmp_type = RX_CMP_TYPE(rxcmp);
+
+	if (cmp_type == CMP_TYPE_RX_L2_CMP) {
+		agg_bufs = (le32_to_cpu(rxcmp->rx_cmp_misc_v1) &
+			    RX_CMP_AGG_BUFS) >>
+			   RX_CMP_AGG_BUFS_SHIFT;
+	} else if (cmp_type == CMP_TYPE_RX_L2_TPA_END_CMP) {
+		struct rx_tpa_end_cmp *tpa_end = cmp;
+
+		agg_bufs = (le32_to_cpu(tpa_end->rx_tpa_end_cmp_misc_v1) &
+			    RX_TPA_END_CMP_AGG_BUFS) >>
+			   RX_TPA_END_CMP_AGG_BUFS_SHIFT;
+	}
+
+	if (agg_bufs) {
+		if (!bnxt_agg_bufs_valid(bp, cpr, agg_bufs, &tmp_raw_cons))
+			return -EBUSY;
+	}
+	*raw_cons = tmp_raw_cons;
+	return 0;
+}
+
+static void bnxt_sched_reset(struct bnxt *bp, struct bnxt_rx_ring_info *rxr)
+{
+	if (!rxr->bnapi->in_reset) {
+		rxr->bnapi->in_reset = true;
+		set_bit(BNXT_RESET_TASK_SP_EVENT, &bp->sp_event);
+		schedule_work(&bp->sp_task);
+	}
+	rxr->rx_next_cons = 0xffff;
+}
+
 static void bnxt_tpa_start(struct bnxt *bp, struct bnxt_rx_ring_info *rxr,
 			   struct rx_tpa_start_cmp *tpa_start,
 			   struct rx_tpa_start_cmp_ext *tpa_start1)
@@ -830,6 +870,11 @@ static void bnxt_tpa_start(struct bnxt *bp, struct bnxt_rx_ring_info *rxr,
 	prod_rx_buf = &rxr->rx_buf_ring[prod];
 	tpa_info = &rxr->rx_tpa[agg_id];
 
+	if (unlikely(cons != rxr->rx_next_cons)) {
+		bnxt_sched_reset(bp, rxr);
+		return;
+	}
+
 	prod_rx_buf->data = tpa_info->data;
 
 	mapping = tpa_info->mapping;
@@ -981,6 +1026,14 @@ static inline struct sk_buff *bnxt_tpa_end(struct bnxt *bp,
 	dma_addr_t mapping;
 	struct sk_buff *skb;
 
+	if (unlikely(bnapi->in_reset)) {
+		int rc = bnxt_discard_rx(bp, bnapi, raw_cons, tpa_end);
+
+		if (rc < 0)
+			return ERR_PTR(-EBUSY);
+		return NULL;
+	}
+
 	tpa_info = &rxr->rx_tpa[agg_id];
 	data = tpa_info->data;
 	prefetch(data);
@@ -1147,6 +1200,12 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 	cons = rxcmp->rx_cmp_opaque;
 	rx_buf = &rxr->rx_buf_ring[cons];
 	data = rx_buf->data;
+	if (unlikely(cons != rxr->rx_next_cons)) {
+		int rc1 = bnxt_discard_rx(bp, bnapi, raw_cons, rxcmp);
+
+		bnxt_sched_reset(bp, rxr);
+		return rc1;
+	}
 	prefetch(data);
 
 	agg_bufs = (le32_to_cpu(rxcmp->rx_cmp_misc_v1) & RX_CMP_AGG_BUFS) >>
@@ -4465,6 +4524,7 @@ static void bnxt_enable_napi(struct bnxt *bp)
 	int i;
 
 	for (i = 0; i < bp->cp_nr_rings; i++) {
+		bp->bnapi[i]->in_reset = false;
 		bnxt_enable_poll(bp->bnapi[i]);
 		napi_enable(&bp->bnapi[i]->napi);
 	}
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 52f2d74..de9d53e 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -637,6 +637,7 @@ struct bnxt_napi {
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	atomic_t		poll_state;
 #endif
+	bool			in_reset;
 };
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
-- 
1.8.3.1
