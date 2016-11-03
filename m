From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 09/13] nfp: reorganize nfp_net_rx() to get packet offsets early
Date: Thu,  3 Nov 2016 13:58:54 +0000
Message-ID: <1478181538-20778-10-git-send-email-jakub.kicinski@netronome.com>
References: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38315 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757648AbcKCN7Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 09:59:24 -0400
Received: by mail-wm0-f54.google.com with SMTP id n67so103129007wme.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 06:59:23 -0700 (PDT)
In-Reply-To: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calculate packet offsets early in nfp_net_rx() so that we will be
able to use them in upcoming XDP handler.  While at it move relevant
variables into the loop scope.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 56 ++++++++++++----------
 1 file changed, 30 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 506362729607..2ab63661a6fd 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1383,16 +1383,17 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 {
 	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
 	struct nfp_net *nn = r_vec->nfp_net;
-	unsigned int data_len, meta_len;
-	struct nfp_net_rx_buf *rxbuf;
-	struct nfp_net_rx_desc *rxd;
-	dma_addr_t new_dma_addr;
 	struct sk_buff *skb;
 	int pkts_polled = 0;
-	void *new_frag;
 	int idx;
 
 	while (pkts_polled < budget) {
+		unsigned int meta_len, data_len, data_off, pkt_len, pkt_off;
+		struct nfp_net_rx_buf *rxbuf;
+		struct nfp_net_rx_desc *rxd;
+		dma_addr_t new_dma_addr;
+		void *new_frag;
+
 		idx = rx_ring->rd_p & (rx_ring->cnt - 1);
 
 		rxd = &rx_ring->rxds[idx];
@@ -1408,22 +1409,6 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		pkts_polled++;
 
 		rxbuf =	&rx_ring->rxbufs[idx];
-		skb = build_skb(rxbuf->frag, nn->fl_bufsz);
-		if (unlikely(!skb)) {
-			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, NULL);
-			continue;
-		}
-		new_frag = nfp_net_napi_alloc_one(nn, &new_dma_addr);
-		if (unlikely(!new_frag)) {
-			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, skb);
-			continue;
-		}
-
-		nfp_net_dma_unmap_rx(nn, rx_ring->rxbufs[idx].dma_addr,
-				     nn->fl_bufsz, DMA_FROM_DEVICE);
-
-		nfp_net_rx_give_one(rx_ring, new_frag, new_dma_addr);
-
 		/*         < meta_len >
 		 *  <-- [rx_offset] -->
 		 *  ---------------------------------------------------------
@@ -1438,20 +1423,39 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		 */
 		meta_len = rxd->rxd.meta_len_dd & PCIE_DESC_RX_META_LEN_MASK;
 		data_len = le16_to_cpu(rxd->rxd.data_len);
+		pkt_len = data_len - meta_len;
 
 		if (nn->rx_offset == NFP_NET_CFG_RX_OFFSET_DYNAMIC)
-			skb_reserve(skb, NFP_NET_RX_BUF_HEADROOM + meta_len);
+			pkt_off = meta_len;
 		else
-			skb_reserve(skb,
-				    NFP_NET_RX_BUF_HEADROOM + nn->rx_offset);
-		skb_put(skb, data_len - meta_len);
+			pkt_off = nn->rx_offset;
+		data_off = NFP_NET_RX_BUF_HEADROOM + pkt_off;
 
 		/* Stats update */
 		u64_stats_update_begin(&r_vec->rx_sync);
 		r_vec->rx_pkts++;
-		r_vec->rx_bytes += skb->len;
+		r_vec->rx_bytes += pkt_len;
 		u64_stats_update_end(&r_vec->rx_sync);
 
+		skb = build_skb(rxbuf->frag, nn->fl_bufsz);
+		if (unlikely(!skb)) {
+			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, NULL);
+			continue;
+		}
+		new_frag = nfp_net_napi_alloc_one(nn, &new_dma_addr);
+		if (unlikely(!new_frag)) {
+			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, skb);
+			continue;
+		}
+
+		nfp_net_dma_unmap_rx(nn, rx_ring->rxbufs[idx].dma_addr,
+				     nn->fl_bufsz, DMA_FROM_DEVICE);
+
+		nfp_net_rx_give_one(rx_ring, new_frag, new_dma_addr);
+
+		skb_reserve(skb, data_off);
+		skb_put(skb, pkt_len);
+
 		if (nn->fw_ver.major <= 3) {
 			nfp_net_set_hash_desc(nn->netdev, skb, rxd);
 		} else if (meta_len) {
-- 
1.9.1
