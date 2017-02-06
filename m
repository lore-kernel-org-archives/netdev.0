From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v3 10/12] bnxt_en: Refactor tx completion path.
Date: Mon,  6 Feb 2017 16:55:41 -0500
Message-ID: <1486418143-8958-11-git-send-email-michael.chan@broadcom.com>
References: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:33108 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752106AbdBFV4K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 16:56:10 -0500
Received: by mail-pg0-f47.google.com with SMTP id 204so31843255pge.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 13:56:10 -0800 (PST)
In-Reply-To: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XDP_TX requires a different function to handle completion.  Add a
function pointer to handle tx completion logic.  Regular TX rings
will be assigned the current bnxt_tx_int() for the ->tx_int()
function pointer.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 5 ++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 5 +++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 412a8de..64dc94d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1765,7 +1765,7 @@ static int bnxt_poll_work(struct bnxt *bp, struct bnxt_napi *bnapi, int budget)
 	BNXT_CP_DB(cpr->cp_doorbell, cpr->cp_raw_cons);
 
 	if (tx_pkts)
-		bnxt_tx_int(bp, bnapi, tx_pkts);
+		bnapi->tx_int(bp, bnapi, tx_pkts);
 
 	if (event & BNXT_RX_EVENT) {
 		struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
@@ -3048,6 +3048,9 @@ static int bnxt_alloc_mem(struct bnxt *bp, bool irq_re_init)
 			if (i >= bp->tx_nr_rings_xdp)
 				bp->tx_ring[i].txq_index = i -
 					bp->tx_nr_rings_xdp;
+			else
+				bp->bnapi[j]->flags |= BNXT_NAPI_FLAG_XDP;
+			bp->bnapi[j]->tx_int = bnxt_tx_int;
 		}
 
 		rc = bnxt_alloc_stats(bp);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 4c3289a..6dc43f5 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -664,6 +664,11 @@ struct bnxt_napi {
 	struct bnxt_rx_ring_info	*rx_ring;
 	struct bnxt_tx_ring_info	*tx_ring;
 
+	void			(*tx_int)(struct bnxt *, struct bnxt_napi *,
+					  int);
+	u32			flags;
+#define BNXT_NAPI_FLAG_XDP	0x1
+
 	bool			in_reset;
 };
 
-- 
1.8.3.1
