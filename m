From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 3/3] bnxt_en: Fix crash in bnxt_free_tx_skbs() during tx timeout.
Date: Thu, 28 Jan 2016 03:11:22 -0500
Message-ID: <1453968682-10014-4-git-send-email-mchan@broadcom.com>
References: <1453968682-10014-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:3533 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934813AbcA1ILZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 03:11:25 -0500
In-Reply-To: <1453968682-10014-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ring index j is not wrapped properly at the end of the ring, causing
it to reference pointers past the end of the ring.  For proper loop
termination and to access the ring properly, we need to increment j and
mask it before referencing the ring entry.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index ebc5413..5dc89e5 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1490,10 +1490,11 @@ static void bnxt_free_tx_skbs(struct bnxt *bp)
 
 			last = tx_buf->nr_frags;
 			j += 2;
-			for (k = 0; k < last; k++, j = NEXT_TX(j)) {
+			for (k = 0; k < last; k++, j++) {
+				int ring_idx = j & bp->tx_ring_mask;
 				skb_frag_t *frag = &skb_shinfo(skb)->frags[k];
 
-				tx_buf = &txr->tx_buf_ring[j];
+				tx_buf = &txr->tx_buf_ring[ring_idx];
 				dma_unmap_page(
 					&pdev->dev,
 					dma_unmap_addr(tx_buf, mapping),
-- 
1.8.3.1
