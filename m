From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 13/13] nfp: add support for xdp_adjust_head()
Date: Fri, 10 Mar 2017 10:38:39 -0800
Message-ID: <20170310183839.39568-14-jakub.kicinski@netronome.com>
References: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:33566 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755461AbdCJSjf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:39:35 -0500
Received: by mail-pg0-f47.google.com with SMTP id 25so41795084pgy.0
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 10:39:34 -0800 (PST)
In-Reply-To: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support prepending data from XDP.  We are already always allocating
some headroom because FW may prepend metadata to packets.
xdp_adjust_head() can be supported by making sure that headroom is
big enough for XDP.  In case FW had prepended metadata to the packet,
however, we have to move it out of the way before we call XDP.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  2 +
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 98 +++++++++++++++-------
 2 files changed, 70 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 5f0547c6efb8..4d45f4573b57 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -439,6 +439,7 @@ struct nfp_stat_pair {
  * @bpf_offload_xdp:	Offloaded BPF program is XDP
  * @chained_metadata_format:  Firemware will use new metadata format
  * @rx_dma_dir:		Mapping direction for RX buffers
+ * @rx_dma_off:		Offset at which DMA packets (for XDP headroom)
  * @rx_offset:		Offset in the RX buffers where packet data starts
  * @ctrl:		Local copy of the control register/word.
  * @fl_bufsz:		Currently configured size of the freelist buffers
@@ -465,6 +466,7 @@ struct nfp_net_dp {
 	u8 chained_metadata_format:1;
 
 	u8 rx_dma_dir;
+	u8 rx_dma_off;
 
 	u8 rx_offset;
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index fe7c3f6d820d..f134f1808b9a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1100,6 +1100,7 @@ nfp_net_calc_fl_bufsz(struct nfp_net_dp *dp)
 	unsigned int fl_bufsz;
 
 	fl_bufsz = NFP_NET_RX_BUF_HEADROOM;
+	fl_bufsz += dp->rx_dma_off;
 	if (dp->rx_offset == NFP_NET_CFG_RX_OFFSET_DYNAMIC)
 		fl_bufsz += NFP_NET_MAX_PREPEND;
 	else
@@ -1181,11 +1182,13 @@ static void *nfp_net_napi_alloc_one(struct nfp_net_dp *dp, dma_addr_t *dma_addr)
 
 /**
  * nfp_net_rx_give_one() - Put mapped skb on the software and hardware rings
+ * @dp:		NFP Net data path struct
  * @rx_ring:	RX ring structure
  * @frag:	page fragment buffer
  * @dma_addr:	DMA address of skb mapping
  */
-static void nfp_net_rx_give_one(struct nfp_net_rx_ring *rx_ring,
+static void nfp_net_rx_give_one(const struct nfp_net_dp *dp,
+				struct nfp_net_rx_ring *rx_ring,
 				void *frag, dma_addr_t dma_addr)
 {
 	unsigned int wr_idx;
@@ -1199,7 +1202,8 @@ static void nfp_net_rx_give_one(struct nfp_net_rx_ring *rx_ring,
 	/* Fill freelist descriptor */
 	rx_ring->rxds[wr_idx].fld.reserved = 0;
 	rx_ring->rxds[wr_idx].fld.meta_len_dd = 0;
-	nfp_desc_set_dma_addr(&rx_ring->rxds[wr_idx].fld, dma_addr);
+	nfp_desc_set_dma_addr(&rx_ring->rxds[wr_idx].fld,
+			      dma_addr + dp->rx_dma_off);
 
 	rx_ring->wr_p++;
 	rx_ring->wr_ptr_add++;
@@ -1296,14 +1300,17 @@ nfp_net_rx_ring_bufs_alloc(struct nfp_net_dp *dp,
 
 /**
  * nfp_net_rx_ring_fill_freelist() - Give buffers from the ring to FW
+ * @dp:	     NFP Net data path struct
  * @rx_ring: RX ring to fill
  */
-static void nfp_net_rx_ring_fill_freelist(struct nfp_net_rx_ring *rx_ring)
+static void
+nfp_net_rx_ring_fill_freelist(struct nfp_net_dp *dp,
+			      struct nfp_net_rx_ring *rx_ring)
 {
 	unsigned int i;
 
 	for (i = 0; i < rx_ring->cnt - 1; i++)
-		nfp_net_rx_give_one(rx_ring, rx_ring->rxbufs[i].frag,
+		nfp_net_rx_give_one(dp, rx_ring, rx_ring->rxbufs[i].frag,
 				    rx_ring->rxbufs[i].dma_addr);
 }
 
@@ -1429,8 +1436,9 @@ nfp_net_parse_meta(struct net_device *netdev, struct sk_buff *skb,
 }
 
 static void
-nfp_net_rx_drop(struct nfp_net_r_vector *r_vec, struct nfp_net_rx_ring *rx_ring,
-		struct nfp_net_rx_buf *rxbuf, struct sk_buff *skb)
+nfp_net_rx_drop(const struct nfp_net_dp *dp, struct nfp_net_r_vector *r_vec,
+		struct nfp_net_rx_ring *rx_ring, struct nfp_net_rx_buf *rxbuf,
+		struct sk_buff *skb)
 {
 	u64_stats_update_begin(&r_vec->rx_sync);
 	r_vec->rx_drops++;
@@ -1442,7 +1450,7 @@ nfp_net_rx_drop(struct nfp_net_r_vector *r_vec, struct nfp_net_rx_ring *rx_ring,
 	if (skb && rxbuf && skb->head == rxbuf->frag)
 		page_ref_inc(virt_to_head_page(rxbuf->frag));
 	if (rxbuf)
-		nfp_net_rx_give_one(rx_ring, rxbuf->frag, rxbuf->dma_addr);
+		nfp_net_rx_give_one(dp, rx_ring, rxbuf->frag, rxbuf->dma_addr);
 	if (skb)
 		dev_kfree_skb_any(skb);
 }
@@ -1460,16 +1468,16 @@ nfp_net_tx_xdp_buf(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 	int wr_idx;
 
 	if (unlikely(nfp_net_tx_full(tx_ring, 1))) {
-		nfp_net_rx_drop(rx_ring->r_vec, rx_ring, rxbuf, NULL);
+		nfp_net_rx_drop(dp, rx_ring->r_vec, rx_ring, rxbuf, NULL);
 		return false;
 	}
 
 	new_frag = nfp_net_napi_alloc_one(dp, &new_dma_addr);
 	if (unlikely(!new_frag)) {
-		nfp_net_rx_drop(rx_ring->r_vec, rx_ring, rxbuf, NULL);
+		nfp_net_rx_drop(dp, rx_ring->r_vec, rx_ring, rxbuf, NULL);
 		return false;
 	}
-	nfp_net_rx_give_one(rx_ring, new_frag, new_dma_addr);
+	nfp_net_rx_give_one(dp, rx_ring, new_frag, new_dma_addr);
 
 	wr_idx = tx_ring->wr_p & (tx_ring->cnt - 1);
 
@@ -1500,14 +1508,24 @@ nfp_net_tx_xdp_buf(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 	return true;
 }
 
-static int nfp_net_run_xdp(struct bpf_prog *prog, void *data, unsigned int len)
+static int nfp_net_run_xdp(struct bpf_prog *prog, void *data, void *hard_start,
+			   unsigned int *off, unsigned int *len)
 {
 	struct xdp_buff xdp;
+	void *orig_data;
+	int ret;
+
+	xdp.data_hard_start = hard_start;
+	xdp.data = data + *off;
+	xdp.data_end = data + *off + *len;
 
-	xdp.data = data;
-	xdp.data_end = data + len;
+	orig_data = xdp.data;
+	ret = bpf_prog_run_xdp(prog, &xdp);
 
-	return bpf_prog_run_xdp(prog, &xdp);
+	*len -= xdp.data - orig_data;
+	*off += xdp.data - orig_data;
+
+	return ret;
 }
 
 /**
@@ -1539,6 +1557,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 
 	while (pkts_polled < budget) {
 		unsigned int meta_len, data_len, data_off, pkt_len;
+		u8 meta_prepend[NFP_NET_MAX_PREPEND];
 		struct nfp_net_rx_buf *rxbuf;
 		struct nfp_net_rx_desc *rxd;
 		dma_addr_t new_dma_addr;
@@ -1580,6 +1599,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			data_off = NFP_NET_RX_BUF_HEADROOM + meta_len;
 		else
 			data_off = NFP_NET_RX_BUF_HEADROOM + dp->rx_offset;
+		data_off += dp->rx_dma_off;
 
 		/* Stats update */
 		u64_stats_update_begin(&r_vec->rx_sync);
@@ -1594,25 +1614,35 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			     (dp->rx_offset && meta_len > dp->rx_offset))) {
 			nn_dp_warn(dp, "oversized RX packet metadata %u\n",
 				   meta_len);
-			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, NULL);
+			nfp_net_rx_drop(dp, r_vec, rx_ring, rxbuf, NULL);
 			continue;
 		}
 
 		if (xdp_prog && !(rxd->rxd.flags & PCIE_DESC_RX_BPF &&
 				  dp->bpf_offload_xdp)) {
 			unsigned int dma_off;
+			void *hard_start;
 			int act;
 
+			hard_start = rxbuf->frag + NFP_NET_RX_BUF_HEADROOM;
 			dma_off = data_off - NFP_NET_RX_BUF_HEADROOM;
-			dma_sync_single_for_cpu(dp->dev,
-						rxbuf->dma_addr + dma_off,
-						pkt_len, DMA_BIDIRECTIONAL);
-			act = nfp_net_run_xdp(xdp_prog, rxbuf->frag + data_off,
-					      pkt_len);
+			dma_sync_single_for_cpu(dp->dev, rxbuf->dma_addr,
+						dma_off + pkt_len,
+						DMA_BIDIRECTIONAL);
+
+			/* Move prepend out of the way */
+			if (xdp_prog->xdp_adjust_head) {
+				memcpy(meta_prepend, meta, meta_len);
+				meta = meta_prepend;
+			}
+
+			act = nfp_net_run_xdp(xdp_prog, rxbuf->frag, hard_start,
+					      &data_off, &pkt_len);
 			switch (act) {
 			case XDP_PASS:
 				break;
 			case XDP_TX:
+				dma_off = data_off - NFP_NET_RX_BUF_HEADROOM;
 				if (unlikely(!nfp_net_tx_xdp_buf(dp, rx_ring,
 								 tx_ring, rxbuf,
 								 dma_off,
@@ -1625,7 +1655,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			case XDP_ABORTED:
 				trace_xdp_exception(dp->netdev, xdp_prog, act);
 			case XDP_DROP:
-				nfp_net_rx_give_one(rx_ring, rxbuf->frag,
+				nfp_net_rx_give_one(dp, rx_ring, rxbuf->frag,
 						    rxbuf->dma_addr);
 				continue;
 			}
@@ -1633,18 +1663,18 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 
 		skb = build_skb(rxbuf->frag, true_bufsz);
 		if (unlikely(!skb)) {
-			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, NULL);
+			nfp_net_rx_drop(dp, r_vec, rx_ring, rxbuf, NULL);
 			continue;
 		}
 		new_frag = nfp_net_napi_alloc_one(dp, &new_dma_addr);
 		if (unlikely(!new_frag)) {
-			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, skb);
+			nfp_net_rx_drop(dp, r_vec, rx_ring, rxbuf, skb);
 			continue;
 		}
 
 		nfp_net_dma_unmap_rx(dp, rxbuf->dma_addr);
 
-		nfp_net_rx_give_one(rx_ring, new_frag, new_dma_addr);
+		nfp_net_rx_give_one(dp, rx_ring, new_frag, new_dma_addr);
 
 		skb_reserve(skb, data_off);
 		skb_put(skb, pkt_len);
@@ -1658,7 +1688,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 						 meta_len);
 			if (unlikely(end != meta + meta_len)) {
 				nn_dp_warn(dp, "invalid RX packet metadata\n");
-				nfp_net_rx_drop(r_vec, rx_ring, NULL, skb);
+				nfp_net_rx_drop(dp, r_vec, rx_ring, NULL, skb);
 				continue;
 			}
 		}
@@ -2151,7 +2181,7 @@ static int __nfp_net_set_config_and_enable(struct nfp_net *nn)
 	nn->dp.ctrl = new_ctrl;
 
 	for (r = 0; r < nn->dp.num_rx_rings; r++)
-		nfp_net_rx_ring_fill_freelist(&nn->dp.rx_rings[r]);
+		nfp_net_rx_ring_fill_freelist(&nn->dp, &nn->dp.rx_rings[r]);
 
 	/* Since reconfiguration requests while NFP is down are ignored we
 	 * have to wipe the entire VXLAN configuration and reinitialize it.
@@ -2877,10 +2907,6 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 	struct nfp_net_dp *dp;
 	int err;
 
-	if (prog && prog->xdp_adjust_head) {
-		nn_err(nn, "Does not support bpf_xdp_adjust_head()\n");
-		return -EOPNOTSUPP;
-	}
 	if (!prog && !nn->dp.xdp_prog)
 		return 0;
 	if (prog && nn->dp.xdp_prog) {
@@ -2897,6 +2923,11 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 	dp->xdp_prog = prog;
 	dp->num_tx_rings += prog ? nn->dp.num_rx_rings : -nn->dp.num_rx_rings;
 	dp->rx_dma_dir = prog ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
+	if (prog)
+		dp->rx_dma_off = XDP_PACKET_HEADROOM -
+			(nn->dp.rx_offset ?: NFP_NET_MAX_PREPEND);
+	else
+		dp->rx_dma_off = 0;
 
 	/* We need RX reconfig to remap the buffers (BIDIR vs FROM_DEV) */
 	err = nfp_net_ring_reconfig(nn, dp);
@@ -3124,6 +3155,13 @@ int nfp_net_netdev_init(struct net_device *netdev)
 	struct nfp_net *nn = netdev_priv(netdev);
 	int err;
 
+	/* XDP calls for 256 byte packet headroom which wouldn't fit in a u8.
+	 * We, however, reuse the metadata prepend space for XDP buffers which
+	 * is at least 1 byte long and as long as XDP headroom doesn't increase
+	 * above 256 the *extra* XDP headroom will fit on 8 bits.
+	 */
+	BUILD_BUG_ON(XDP_PACKET_HEADROOM > 256);
+
 	nn->dp.chained_metadata_format = nn->fw_ver.major > 3;
 
 	nn->dp.rx_dma_dir = DMA_FROM_DEVICE;
-- 
2.11.0
