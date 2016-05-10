From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 1/2] bnxt_en: Add workaround to detect bad opaque in rx completion (part 1)
Date: Tue, 10 May 2016 19:17:59 -0400
Message-ID: <1462922280-17851-2-git-send-email-michael.chan@broadcom.com>
References: <1462922280-17851-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33672 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574AbcEJXSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 19:18:11 -0400
Received: by mail-pf0-f170.google.com with SMTP id 206so10934317pfu.0
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 16:18:11 -0700 (PDT)
In-Reply-To: <1462922280-17851-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a rare hardware bug that can cause a bad opaque value in the RX
or TPA completion.  When this happens, the hardware may have used the
same buffer twice for 2 rx packets.  In addition, the driver will also
crash later using the bad opaque as the index into the ring.

The rx opaque value is predictable and is always monotonically increasing.
The workaround is to keep track of the expected next opaque value and
compare it with the one returned by hardware during RX and TPA start
completions.  If they miscompare, we will not process any more RX and
TPA completions and exit NAPI.  We will then schedule a workqueue to
reset the function.

This patch adds the logic to keep track of the next rx consumer index.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 3 +++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 1 +
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 9d4e8e1..58999cd 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -867,6 +867,7 @@ static void bnxt_tpa_start(struct bnxt *bp, struct bnxt_rx_ring_info *rxr,
 
 	rxr->rx_prod = NEXT_RX(prod);
 	cons = NEXT_RX(cons);
+	rxr->rx_next_cons = NEXT_RX(cons);
 	cons_rx_buf = &rxr->rx_buf_ring[cons];
 
 	bnxt_reuse_rx_data(rxr, cons, cons_rx_buf->data);
@@ -1245,6 +1246,7 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 
 next_rx:
 	rxr->rx_prod = NEXT_RX(prod);
+	rxr->rx_next_cons = NEXT_RX(cons);
 
 next_rx_no_prod:
 	*raw_cons = tmp_raw_cons;
@@ -2486,6 +2488,7 @@ static void bnxt_clear_ring_indices(struct bnxt *bp)
 			rxr->rx_prod = 0;
 			rxr->rx_agg_prod = 0;
 			rxr->rx_sw_agg_prod = 0;
+			rxr->rx_next_cons = 0;
 		}
 	}
 }
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 8b823ff..52f2d74 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -584,6 +584,7 @@ struct bnxt_rx_ring_info {
 	u16			rx_prod;
 	u16			rx_agg_prod;
 	u16			rx_sw_agg_prod;
+	u16			rx_next_cons;
 	void __iomem		*rx_doorbell;
 	void __iomem		*rx_agg_doorbell;
 
-- 
1.8.3.1
