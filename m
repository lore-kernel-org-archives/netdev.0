From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 09/14] nfp: use AND instead of modulo to get ring indexes
Date: Mon, 31 Oct 2016 20:43:17 +0000
Message-ID: <1477946602-19644-10-git-send-email-jakub.kicinski@netronome.com>
References: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:34613 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034017AbcJaUoH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:44:07 -0400
Received: by mail-wm0-f44.google.com with SMTP id u144so10409630wmu.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 13:44:07 -0700 (PDT)
In-Reply-To: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already force ring sizes to be power of 2 so replace
modulo operations with AND (size - 1) in index calculations.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index b43d2dbae368..7225ab61a120 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -778,7 +778,7 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 	if (dma_mapping_error(&nn->pdev->dev, dma_addr))
 		goto err_free;
 
-	wr_idx = tx_ring->wr_p % tx_ring->cnt;
+	wr_idx = tx_ring->wr_p & (tx_ring->cnt - 1);
 
 	/* Stash the soft descriptor of the head then initialize it */
 	txbuf = &tx_ring->txbufs[wr_idx];
@@ -822,7 +822,7 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 			if (dma_mapping_error(&nn->pdev->dev, dma_addr))
 				goto err_unmap;
 
-			wr_idx = (wr_idx + 1) % tx_ring->cnt;
+			wr_idx = (wr_idx + 1) & (tx_ring->cnt - 1);
 			tx_ring->txbufs[wr_idx].skb = skb;
 			tx_ring->txbufs[wr_idx].dma_addr = dma_addr;
 			tx_ring->txbufs[wr_idx].fidx = f;
@@ -917,7 +917,7 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 		todo = qcp_rd_p + tx_ring->cnt - tx_ring->qcp_rd_p;
 
 	while (todo--) {
-		idx = tx_ring->rd_p % tx_ring->cnt;
+		idx = tx_ring->rd_p & (tx_ring->cnt - 1);
 		tx_ring->rd_p++;
 
 		skb = tx_ring->txbufs[idx].skb;
@@ -992,7 +992,7 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 		int nr_frags, fidx, idx;
 		struct sk_buff *skb;
 
-		idx = tx_ring->rd_p % tx_ring->cnt;
+		idx = tx_ring->rd_p & (tx_ring->cnt - 1);
 		skb = tx_ring->txbufs[idx].skb;
 		nr_frags = skb_shinfo(skb)->nr_frags;
 		fidx = tx_ring->txbufs[idx].fidx;
@@ -1129,7 +1129,7 @@ static void nfp_net_rx_give_one(struct nfp_net_rx_ring *rx_ring,
 {
 	unsigned int wr_idx;
 
-	wr_idx = rx_ring->wr_p % rx_ring->cnt;
+	wr_idx = rx_ring->wr_p & (rx_ring->cnt - 1);
 
 	/* Stash SKB and DMA address away */
 	rx_ring->rxbufs[wr_idx].frag = frag;
@@ -1164,7 +1164,7 @@ static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
 	unsigned int wr_idx, last_idx;
 
 	/* Move the empty entry to the end of the list */
-	wr_idx = rx_ring->wr_p % rx_ring->cnt;
+	wr_idx = rx_ring->wr_p & (rx_ring->cnt - 1);
 	last_idx = rx_ring->cnt - 1;
 	rx_ring->rxbufs[wr_idx].dma_addr = rx_ring->rxbufs[last_idx].dma_addr;
 	rx_ring->rxbufs[wr_idx].frag = rx_ring->rxbufs[last_idx].frag;
@@ -1413,7 +1413,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 	int idx;
 
 	while (pkts_polled < budget) {
-		idx = rx_ring->rd_p % rx_ring->cnt;
+		idx = rx_ring->rd_p & (rx_ring->cnt - 1);
 
 		rxd = &rx_ring->rxds[idx];
 		if (!(rxd->rxd.meta_len_dd & PCIE_DESC_RX_DD))
-- 
1.9.1
