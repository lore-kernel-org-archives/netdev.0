From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 8/9] nfp: add a helper for wrapping descriptor index
Date: Mon, 15 May 2017 17:55:22 -0700
Message-ID: <20170516005523.26124-9-jakub.kicinski@netronome.com>
References: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36375 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751287AbdEPA4Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 20:56:24 -0400
Received: by mail-pf0-f181.google.com with SMTP id m17so71278901pfg.3
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 17:56:24 -0700 (PDT)
In-Reply-To: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have a number of places where we calculate the descriptor
index based on a value which may have overflown.  Create a
macro for masking with the ring size.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h        |  3 +++
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 21 ++++++++++-----------
 2 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 66319a1026bb..7b9518cbe965 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -117,6 +117,9 @@ struct nfp_eth_table_port;
 struct nfp_net;
 struct nfp_net_r_vector;
 
+/* Convenience macro for wrapping descriptor index on ring size */
+#define D_IDX(ring, idx)	((idx) & ((ring)->cnt - 1))
+
 /* Convenience macro for writing dma address into RX/TX descriptors */
 #define nfp_desc_set_dma_addr(desc, dma_addr)				\
 	do {								\
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index a4c6878f1df1..c64514f8ee65 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -809,7 +809,7 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 	if (dma_mapping_error(dp->dev, dma_addr))
 		goto err_free;
 
-	wr_idx = tx_ring->wr_p & (tx_ring->cnt - 1);
+	wr_idx = D_IDX(tx_ring, tx_ring->wr_p);
 
 	/* Stash the soft descriptor of the head then initialize it */
 	txbuf = &tx_ring->txbufs[wr_idx];
@@ -852,7 +852,7 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 			if (dma_mapping_error(dp->dev, dma_addr))
 				goto err_unmap;
 
-			wr_idx = (wr_idx + 1) & (tx_ring->cnt - 1);
+			wr_idx = D_IDX(tx_ring, wr_idx + 1);
 			tx_ring->txbufs[wr_idx].skb = skb;
 			tx_ring->txbufs[wr_idx].dma_addr = dma_addr;
 			tx_ring->txbufs[wr_idx].fidx = f;
@@ -946,8 +946,7 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 		todo = qcp_rd_p + tx_ring->cnt - tx_ring->qcp_rd_p;
 
 	while (todo--) {
-		idx = tx_ring->rd_p & (tx_ring->cnt - 1);
-		tx_ring->rd_p++;
+		idx = D_IDX(tx_ring, tx_ring->rd_p++);
 
 		skb = tx_ring->txbufs[idx].skb;
 		if (!skb)
@@ -1023,11 +1022,11 @@ static bool nfp_net_xdp_complete(struct nfp_net_tx_ring *tx_ring)
 	done_all = todo <= NFP_NET_XDP_MAX_COMPLETE;
 	todo = min(todo, NFP_NET_XDP_MAX_COMPLETE);
 
-	tx_ring->qcp_rd_p = (tx_ring->qcp_rd_p + todo) & (tx_ring->cnt - 1);
+	tx_ring->qcp_rd_p = D_IDX(tx_ring, tx_ring->qcp_rd_p + todo);
 
 	done_pkts = todo;
 	while (todo--) {
-		idx = tx_ring->rd_p & (tx_ring->cnt - 1);
+		idx = D_IDX(tx_ring, tx_ring->rd_p);
 		tx_ring->rd_p++;
 
 		done_bytes += tx_ring->txbufs[idx].real_len;
@@ -1063,7 +1062,7 @@ nfp_net_tx_ring_reset(struct nfp_net_dp *dp, struct nfp_net_tx_ring *tx_ring)
 		struct sk_buff *skb;
 		int idx, nr_frags;
 
-		idx = tx_ring->rd_p & (tx_ring->cnt - 1);
+		idx = D_IDX(tx_ring, tx_ring->rd_p);
 		tx_buf = &tx_ring->txbufs[idx];
 
 		skb = tx_ring->txbufs[idx].skb;
@@ -1216,7 +1215,7 @@ static void nfp_net_rx_give_one(const struct nfp_net_dp *dp,
 {
 	unsigned int wr_idx;
 
-	wr_idx = rx_ring->wr_p & (rx_ring->cnt - 1);
+	wr_idx = D_IDX(rx_ring, rx_ring->wr_p);
 
 	nfp_net_dma_sync_dev_rx(dp, dma_addr);
 
@@ -1254,7 +1253,7 @@ static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
 	unsigned int wr_idx, last_idx;
 
 	/* Move the empty entry to the end of the list */
-	wr_idx = rx_ring->wr_p & (rx_ring->cnt - 1);
+	wr_idx = D_IDX(rx_ring, rx_ring->wr_p);
 	last_idx = rx_ring->cnt - 1;
 	rx_ring->rxbufs[wr_idx].dma_addr = rx_ring->rxbufs[last_idx].dma_addr;
 	rx_ring->rxbufs[wr_idx].frag = rx_ring->rxbufs[last_idx].frag;
@@ -1522,7 +1521,7 @@ nfp_net_tx_xdp_buf(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 		}
 	}
 
-	wr_idx = tx_ring->wr_p & (tx_ring->cnt - 1);
+	wr_idx = D_IDX(tx_ring, tx_ring->wr_p);
 
 	/* Stash the soft descriptor of the head then initialize it */
 	txbuf = &tx_ring->txbufs[wr_idx];
@@ -1610,7 +1609,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		dma_addr_t new_dma_addr;
 		void *new_frag;
 
-		idx = rx_ring->rd_p & (rx_ring->cnt - 1);
+		idx = D_IDX(rx_ring, rx_ring->rd_p);
 
 		rxd = &rx_ring->rxds[idx];
 		if (!(rxd->rxd.meta_len_dd & PCIE_DESC_RX_DD))
-- 
2.11.0
