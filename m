From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 1/5] nfp: make use of the DMA_ATTR_SKIP_CPU_SYNC attribute
Date: Fri, 21 Apr 2017 12:23:06 -0700
Message-ID: <20170421192310.193875-2-jakub.kicinski@netronome.com>
References: <20170421192310.193875-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:34736 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424797AbdDUTXW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:23:22 -0400
Received: by mail-oi0-f44.google.com with SMTP id x184so109562661oia.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:23:22 -0700 (PDT)
In-Reply-To: <20170421192310.193875-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DMA unmap may destroy changes CPU made to the buffer.  To make XDP
run correctly on non-x86 platforms we should use the
DMA_ATTR_SKIP_CPU_SYNC attribute.

Thanks to using the attribute we can now push the sync operation to the
common code path from XDP handler.

A little bit of variable name reshuffling is required to bring the
code back to readable state.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 54 ++++++++++++++--------
 1 file changed, 36 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index e2197160e4dc..71e5568a43ff 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -87,16 +87,30 @@ void nfp_net_get_fw_version(struct nfp_net_fw_version *fw_ver,
 
 static dma_addr_t nfp_net_dma_map_rx(struct nfp_net_dp *dp, void *frag)
 {
-	return dma_map_single(dp->dev, frag + NFP_NET_RX_BUF_HEADROOM,
-			      dp->fl_bufsz - NFP_NET_RX_BUF_NON_DATA,
-			      dp->rx_dma_dir);
+	return dma_map_single_attrs(dp->dev, frag + NFP_NET_RX_BUF_HEADROOM,
+				    dp->fl_bufsz - NFP_NET_RX_BUF_NON_DATA,
+				    dp->rx_dma_dir, DMA_ATTR_SKIP_CPU_SYNC);
+}
+
+static void nfp_net_dma_sync_dev_rx(struct nfp_net_dp *dp, dma_addr_t dma_addr)
+{
+	dma_sync_single_for_device(dp->dev, dma_addr,
+				   dp->fl_bufsz - NFP_NET_RX_BUF_NON_DATA,
+				   dp->rx_dma_dir);
 }
 
 static void nfp_net_dma_unmap_rx(struct nfp_net_dp *dp, dma_addr_t dma_addr)
 {
-	dma_unmap_single(dp->dev, dma_addr,
-			 dp->fl_bufsz - NFP_NET_RX_BUF_NON_DATA,
-			 dp->rx_dma_dir);
+	dma_unmap_single_attrs(dp->dev, dma_addr,
+			       dp->fl_bufsz - NFP_NET_RX_BUF_NON_DATA,
+			       dp->rx_dma_dir, DMA_ATTR_SKIP_CPU_SYNC);
+}
+
+static void nfp_net_dma_sync_cpu_rx(struct nfp_net_dp *dp, dma_addr_t dma_addr,
+				    unsigned int len)
+{
+	dma_sync_single_for_cpu(dp->dev, dma_addr - NFP_NET_RX_BUF_HEADROOM,
+				len, dp->rx_dma_dir);
 }
 
 /* Firmware reconfig
@@ -1167,6 +1181,8 @@ nfp_net_rx_alloc_one(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 		return NULL;
 	}
 
+	nfp_net_dma_sync_dev_rx(dp, *dma_addr);
+
 	return frag;
 }
 
@@ -1190,6 +1206,8 @@ static void *nfp_net_napi_alloc_one(struct nfp_net_dp *dp, dma_addr_t *dma_addr)
 		return NULL;
 	}
 
+	nfp_net_dma_sync_dev_rx(dp, *dma_addr);
+
 	return frag;
 }
 
@@ -1569,7 +1587,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 	tx_ring = r_vec->xdp_ring;
 
 	while (pkts_polled < budget) {
-		unsigned int meta_len, data_len, data_off, pkt_len;
+		unsigned int meta_len, data_len, meta_off, pkt_len, pkt_off;
 		u8 meta_prepend[NFP_NET_MAX_PREPEND];
 		struct nfp_net_rx_buf *rxbuf;
 		struct nfp_net_rx_desc *rxd;
@@ -1608,11 +1626,12 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		data_len = le16_to_cpu(rxd->rxd.data_len);
 		pkt_len = data_len - meta_len;
 
+		pkt_off = NFP_NET_RX_BUF_HEADROOM + dp->rx_dma_off;
 		if (dp->rx_offset == NFP_NET_CFG_RX_OFFSET_DYNAMIC)
-			data_off = NFP_NET_RX_BUF_HEADROOM + meta_len;
+			pkt_off += meta_len;
 		else
-			data_off = NFP_NET_RX_BUF_HEADROOM + dp->rx_offset;
-		data_off += dp->rx_dma_off;
+			pkt_off += dp->rx_offset;
+		meta_off = pkt_off - meta_len;
 
 		/* Stats update */
 		u64_stats_update_begin(&r_vec->rx_sync);
@@ -1621,7 +1640,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		u64_stats_update_end(&r_vec->rx_sync);
 
 		/* Pointer to start of metadata */
-		meta = rxbuf->frag + data_off - meta_len;
+		meta = rxbuf->frag + meta_off;
 
 		if (unlikely(meta_len > NFP_NET_MAX_PREPEND ||
 			     (dp->rx_offset && meta_len > dp->rx_offset))) {
@@ -1631,6 +1650,9 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			continue;
 		}
 
+		nfp_net_dma_sync_cpu_rx(dp, rxbuf->dma_addr + meta_off,
+					data_len);
+
 		if (xdp_prog && !(rxd->rxd.flags & PCIE_DESC_RX_BPF &&
 				  dp->bpf_offload_xdp)) {
 			unsigned int dma_off;
@@ -1638,10 +1660,6 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			int act;
 
 			hard_start = rxbuf->frag + NFP_NET_RX_BUF_HEADROOM;
-			dma_off = data_off - NFP_NET_RX_BUF_HEADROOM;
-			dma_sync_single_for_cpu(dp->dev, rxbuf->dma_addr,
-						dma_off + pkt_len,
-						DMA_BIDIRECTIONAL);
 
 			/* Move prepend out of the way */
 			if (xdp_prog->xdp_adjust_head) {
@@ -1650,12 +1668,12 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			}
 
 			act = nfp_net_run_xdp(xdp_prog, rxbuf->frag, hard_start,
-					      &data_off, &pkt_len);
+					      &pkt_off, &pkt_len);
 			switch (act) {
 			case XDP_PASS:
 				break;
 			case XDP_TX:
-				dma_off = data_off - NFP_NET_RX_BUF_HEADROOM;
+				dma_off = pkt_off - NFP_NET_RX_BUF_HEADROOM;
 				if (unlikely(!nfp_net_tx_xdp_buf(dp, rx_ring,
 								 tx_ring, rxbuf,
 								 dma_off,
@@ -1689,7 +1707,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 
 		nfp_net_rx_give_one(dp, rx_ring, new_frag, new_dma_addr);
 
-		skb_reserve(skb, data_off);
+		skb_reserve(skb, pkt_off);
 		skb_put(skb, pkt_len);
 
 		if (!dp->chained_metadata_format) {
-- 
2.11.0
