From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net] bnx2: Fix bug in bnx2_free_tx_skbs().
Date: Tue, 10 Jul 2012 13:04:40 -0700
Message-ID: <1341950680-12266-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3767 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752297Ab2GJTxO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 15:53:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In rare cases, bnx2x_free_tx_skbs() can unmap the wrong DMA address
when it gets to the last entry of the tx ring.  We were not using
the proper macro to skip the last entry when advancing the tx index.

Reported-by: Zongyun Lai <zlai@vmware.com>
Reviewed-by: Jeffrey Huang <huangjw@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index ac7b744..1fa4927 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -5372,7 +5372,7 @@ bnx2_free_tx_skbs(struct bnx2 *bp)
 			int k, last;
 
 			if (skb == NULL) {
-				j++;
+				j = NEXT_TX_BD(j);
 				continue;
 			}
 
@@ -5384,8 +5384,8 @@ bnx2_free_tx_skbs(struct bnx2 *bp)
 			tx_buf->skb = NULL;
 
 			last = tx_buf->nr_frags;
-			j++;
-			for (k = 0; k < last; k++, j++) {
+			j = NEXT_TX_BD(j);
+			for (k = 0; k < last; k++, j = NEXT_TX_BD(j)) {
 				tx_buf = &txr->tx_buf_ring[TX_RING_IDX(j)];
 				dma_unmap_page(&bp->pdev->dev,
 					dma_unmap_addr(tx_buf, mapping),
-- 
1.7.1
