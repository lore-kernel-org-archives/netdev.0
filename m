From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 10/12] bnxt_en: Refactor tx completion path.
Date: Thu,  2 Feb 2017 11:55:38 -0500
Message-ID: <1486054540-366-11-git-send-email-michael.chan@broadcom.com>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:32946 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752139AbdBBQ4F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 11:56:05 -0500
Received: by mail-pg0-f48.google.com with SMTP id 204so7132604pge.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 08:56:05 -0800 (PST)
In-Reply-To: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XDP_TX requires a different function to handle completion.  Add a
function pointer to handle tx completion logic.  Regular TX rings
will be assigned the current bnxt_tx_int() for the ->tx_int()
function pointer.

Also, add a struct page pointer as a union with the current skb pointer
to the struct bnxt_sw_tx_bd.  XDP TX rings will use the struct page
pointer.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c |  5 ++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 10 +++++++++-
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 0292bea..ff651a0 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1762,7 +1762,7 @@ static int bnxt_poll_work(struct bnxt *bp, struct bnxt_napi *bnapi, int budget)
 	BNXT_CP_DB(cpr->cp_doorbell, cpr->cp_raw_cons);
 
 	if (tx_pkts)
-		bnxt_tx_int(bp, bnapi, tx_pkts);
+		bnapi->tx_int(bp, bnapi, tx_pkts);
 
 	if (event & BNXT_RX_EVENT) {
 		struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
@@ -3045,6 +3045,9 @@ static int bnxt_alloc_mem(struct bnxt *bp, bool irq_re_init)
 			if (i >= bp->tx_nr_rings_xdp)
 				bp->tx_ring[i].txq_index = i -
 					bp->tx_nr_rings_xdp;
+			else
+				bp->bnapi[j]->flags |= BNXT_NAPI_FLAG_XDP;
+			bp->bnapi[j]->tx_int = bnxt_tx_int;
 		}
 
 		rc = bnxt_alloc_stats(bp);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 9bc908f..6bf9444 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -515,7 +515,10 @@ struct rx_tpa_end_cmp_ext {
 #define BNXT_AGG_EVENT	2
 
 struct bnxt_sw_tx_bd {
-	struct sk_buff		*skb;
+	union {
+		struct sk_buff		*skb;
+		struct page		*page;
+	};
 	DEFINE_DMA_UNMAP_ADDR(mapping);
 	u8			is_gso;
 	u8			is_push;
@@ -664,6 +667,11 @@ struct bnxt_napi {
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
