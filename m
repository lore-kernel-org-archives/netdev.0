From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 11/13] nfp: reorganize pkt_off variable
Date: Fri, 10 Mar 2017 10:38:37 -0800
Message-ID: <20170310183839.39568-12-jakub.kicinski@netronome.com>
References: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35575 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755365AbdCJSje (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:39:34 -0500
Received: by mail-pg0-f44.google.com with SMTP id b129so41792055pgc.2
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 10:39:33 -0800 (PST)
In-Reply-To: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename pkt_off variable to dma_off, it should hold data offset
counting from beginning of DMA mapping.  Compute the value only
in XDP context.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 513f55dd746b..0e4fa6802733 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1453,7 +1453,7 @@ nfp_net_rx_drop(struct nfp_net_r_vector *r_vec, struct nfp_net_rx_ring *rx_ring,
 static bool
 nfp_net_tx_xdp_buf(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 		   struct nfp_net_tx_ring *tx_ring,
-		   struct nfp_net_rx_buf *rxbuf, unsigned int pkt_off,
+		   struct nfp_net_rx_buf *rxbuf, unsigned int dma_off,
 		   unsigned int pkt_len)
 {
 	struct nfp_net_tx_buf *txbuf;
@@ -1484,14 +1484,14 @@ nfp_net_tx_xdp_buf(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 	txbuf->pkt_cnt = 1;
 	txbuf->real_len = pkt_len;
 
-	dma_sync_single_for_device(dp->dev, rxbuf->dma_addr + pkt_off,
+	dma_sync_single_for_device(dp->dev, rxbuf->dma_addr + dma_off,
 				   pkt_len, DMA_BIDIRECTIONAL);
 
 	/* Build TX descriptor */
 	txd = &tx_ring->txds[wr_idx];
 	txd->offset_eop = PCIE_DESC_TX_EOP;
 	txd->dma_len = cpu_to_le16(pkt_len);
-	nfp_desc_set_dma_addr(txd, rxbuf->dma_addr + pkt_off);
+	nfp_desc_set_dma_addr(txd, rxbuf->dma_addr + dma_off);
 	txd->data_len = cpu_to_le16(pkt_len);
 
 	txd->flags = 0;
@@ -1541,7 +1541,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 	tx_ring = r_vec->xdp_ring;
 
 	while (pkts_polled < budget) {
-		unsigned int meta_len, data_len, data_off, pkt_len, pkt_off;
+		unsigned int meta_len, data_len, data_off, pkt_len;
 		struct nfp_net_rx_buf *rxbuf;
 		struct nfp_net_rx_desc *rxd;
 		dma_addr_t new_dma_addr;
@@ -1579,10 +1579,9 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		pkt_len = data_len - meta_len;
 
 		if (dp->rx_offset == NFP_NET_CFG_RX_OFFSET_DYNAMIC)
-			pkt_off = meta_len;
+			data_off = NFP_NET_RX_BUF_HEADROOM + meta_len;
 		else
-			pkt_off = dp->rx_offset;
-		data_off = NFP_NET_RX_BUF_HEADROOM + pkt_off;
+			data_off = NFP_NET_RX_BUF_HEADROOM + dp->rx_offset;
 
 		/* Stats update */
 		u64_stats_update_begin(&r_vec->rx_sync);
@@ -1592,10 +1591,12 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 
 		if (xdp_prog && !(rxd->rxd.flags & PCIE_DESC_RX_BPF &&
 				  dp->bpf_offload_xdp)) {
+			unsigned int dma_off;
 			int act;
 
+			dma_off = data_off - NFP_NET_RX_BUF_HEADROOM;
 			dma_sync_single_for_cpu(dp->dev,
-						rxbuf->dma_addr + pkt_off,
+						rxbuf->dma_addr + dma_off,
 						pkt_len, DMA_BIDIRECTIONAL);
 			act = nfp_net_run_xdp(xdp_prog, rxbuf->frag + data_off,
 					      pkt_len);
@@ -1605,7 +1606,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			case XDP_TX:
 				if (unlikely(!nfp_net_tx_xdp_buf(dp, rx_ring,
 								 tx_ring, rxbuf,
-								 pkt_off,
+								 dma_off,
 								 pkt_len)))
 					trace_xdp_exception(dp->netdev,
 							    xdp_prog, act);
-- 
2.11.0
