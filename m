From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 09/13] nfp: store dma direction in data path structure
Date: Fri, 10 Mar 2017 10:38:35 -0800
Message-ID: <20170310183839.39568-10-jakub.kicinski@netronome.com>
References: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:33557 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932724AbdCJSjc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:39:32 -0500
Received: by mail-pg0-f45.google.com with SMTP id 25so41794675pgy.0
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 10:39:31 -0800 (PST)
In-Reply-To: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of testing if xdp_prog is present store the dma direction
in data path structure.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       | 11 ++++--
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 45 ++++++++--------------
 2 files changed, 24 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 5a92f6e41dae..db92463da440 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -438,6 +438,7 @@ struct nfp_stat_pair {
  * @bpf_offload_skip_sw:  Offloaded BPF program will not be rerun by cls_bpf
  * @bpf_offload_xdp:	Offloaded BPF program is XDP
  * @chained_metadata_format:  Firemware will use new metadata format
+ * @rx_dma_dir:		Mapping direction for RX buffers
  * @ctrl:		Local copy of the control register/word.
  * @fl_bufsz:		Currently configured size of the freelist buffers
  * @rx_offset:		Offset in the RX buffers where packet data starts
@@ -458,10 +459,12 @@ struct nfp_net_dp {
 	struct device *dev;
 	struct net_device *netdev;
 
-	unsigned is_vf:1;
-	unsigned bpf_offload_skip_sw:1;
-	unsigned bpf_offload_xdp:1;
-	unsigned chained_metadata_format:1;
+	u8 is_vf:1;
+	u8 bpf_offload_skip_sw:1;
+	u8 bpf_offload_xdp:1;
+	u8 chained_metadata_format:1;
+
+	u8 rx_dma_dir;
 
 	u32 ctrl;
 	u32 fl_bufsz;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index a9359da64f80..ab03f2f301cd 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -85,20 +85,18 @@ void nfp_net_get_fw_version(struct nfp_net_fw_version *fw_ver,
 	put_unaligned_le32(reg, fw_ver);
 }
 
-static dma_addr_t
-nfp_net_dma_map_rx(struct nfp_net_dp *dp, void *frag, int direction)
+static dma_addr_t nfp_net_dma_map_rx(struct nfp_net_dp *dp, void *frag)
 {
 	return dma_map_single(dp->dev, frag + NFP_NET_RX_BUF_HEADROOM,
 			      dp->fl_bufsz - NFP_NET_RX_BUF_NON_DATA,
-			      direction);
+			      dp->rx_dma_dir);
 }
 
-static void
-nfp_net_dma_unmap_rx(struct nfp_net_dp *dp, dma_addr_t dma_addr,
-		     int direction)
+static void nfp_net_dma_unmap_rx(struct nfp_net_dp *dp, dma_addr_t dma_addr)
 {
 	dma_unmap_single(dp->dev, dma_addr,
-			 dp->fl_bufsz - NFP_NET_RX_BUF_NON_DATA, direction);
+			 dp->fl_bufsz - NFP_NET_RX_BUF_NON_DATA,
+			 dp->rx_dma_dir);
 }
 
 /* Firmware reconfig
@@ -991,8 +989,7 @@ static void nfp_net_xdp_complete(struct nfp_net_tx_ring *tx_ring)
 		if (!tx_ring->txbufs[idx].frag)
 			continue;
 
-		nfp_net_dma_unmap_rx(dp, tx_ring->txbufs[idx].dma_addr,
-				     DMA_BIDIRECTIONAL);
+		nfp_net_dma_unmap_rx(dp, tx_ring->txbufs[idx].dma_addr);
 		__free_page(virt_to_page(tx_ring->txbufs[idx].frag));
 
 		done_pkts++;
@@ -1037,8 +1034,7 @@ nfp_net_tx_ring_reset(struct nfp_net_dp *dp, struct nfp_net_tx_ring *tx_ring)
 		tx_buf = &tx_ring->txbufs[idx];
 
 		if (tx_ring == r_vec->xdp_ring) {
-			nfp_net_dma_unmap_rx(dp, tx_buf->dma_addr,
-					     DMA_BIDIRECTIONAL);
+			nfp_net_dma_unmap_rx(dp, tx_buf->dma_addr);
 			__free_page(virt_to_page(tx_ring->txbufs[idx].frag));
 		} else {
 			struct sk_buff *skb = tx_ring->txbufs[idx].skb;
@@ -1139,7 +1135,6 @@ static void *
 nfp_net_rx_alloc_one(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 		     dma_addr_t *dma_addr)
 {
-	int direction;
 	void *frag;
 
 	if (!dp->xdp_prog)
@@ -1151,9 +1146,7 @@ nfp_net_rx_alloc_one(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 		return NULL;
 	}
 
-	direction = dp->xdp_prog ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
-
-	*dma_addr = nfp_net_dma_map_rx(dp, frag, direction);
+	*dma_addr = nfp_net_dma_map_rx(dp, frag);
 	if (dma_mapping_error(dp->dev, *dma_addr)) {
 		nfp_net_free_frag(frag, dp->xdp_prog);
 		nn_dp_warn(dp, "Failed to map DMA RX buffer\n");
@@ -1163,9 +1156,7 @@ nfp_net_rx_alloc_one(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 	return frag;
 }
 
-static void *
-nfp_net_napi_alloc_one(struct nfp_net_dp *dp, int direction,
-		       dma_addr_t *dma_addr)
+static void *nfp_net_napi_alloc_one(struct nfp_net_dp *dp, dma_addr_t *dma_addr)
 {
 	void *frag;
 
@@ -1178,7 +1169,7 @@ nfp_net_napi_alloc_one(struct nfp_net_dp *dp, int direction,
 		return NULL;
 	}
 
-	*dma_addr = nfp_net_dma_map_rx(dp, frag, direction);
+	*dma_addr = nfp_net_dma_map_rx(dp, frag);
 	if (dma_mapping_error(dp->dev, *dma_addr)) {
 		nfp_net_free_frag(frag, dp->xdp_prog);
 		nn_dp_warn(dp, "Failed to map DMA RX buffer\n");
@@ -1260,7 +1251,6 @@ static void
 nfp_net_rx_ring_bufs_free(struct nfp_net_dp *dp,
 			  struct nfp_net_rx_ring *rx_ring)
 {
-	int direction = dp->xdp_prog ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
 	unsigned int i;
 
 	for (i = 0; i < rx_ring->cnt - 1; i++) {
@@ -1271,8 +1261,7 @@ nfp_net_rx_ring_bufs_free(struct nfp_net_dp *dp,
 		if (!rx_ring->rxbufs[i].frag)
 			continue;
 
-		nfp_net_dma_unmap_rx(dp, rx_ring->rxbufs[i].dma_addr,
-				     direction);
+		nfp_net_dma_unmap_rx(dp, rx_ring->rxbufs[i].dma_addr);
 		nfp_net_free_frag(rx_ring->rxbufs[i].frag, dp->xdp_prog);
 		rx_ring->rxbufs[i].dma_addr = 0;
 		rx_ring->rxbufs[i].frag = NULL;
@@ -1478,7 +1467,7 @@ nfp_net_tx_xdp_buf(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 		return false;
 	}
 
-	new_frag = nfp_net_napi_alloc_one(dp, DMA_BIDIRECTIONAL, &new_dma_addr);
+	new_frag = nfp_net_napi_alloc_one(dp, &new_dma_addr);
 	if (unlikely(!new_frag)) {
 		nfp_net_rx_drop(rx_ring->r_vec, rx_ring, rxbuf, NULL);
 		return false;
@@ -1544,12 +1533,10 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 	unsigned int true_bufsz;
 	struct sk_buff *skb;
 	int pkts_polled = 0;
-	int rx_dma_map_dir;
 	int idx;
 
 	rcu_read_lock();
 	xdp_prog = READ_ONCE(dp->xdp_prog);
-	rx_dma_map_dir = xdp_prog ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
 	true_bufsz = xdp_prog ? PAGE_SIZE : dp->fl_bufsz;
 	tx_ring = r_vec->xdp_ring;
 
@@ -1639,14 +1626,13 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, NULL);
 			continue;
 		}
-		new_frag = nfp_net_napi_alloc_one(dp, rx_dma_map_dir,
-						  &new_dma_addr);
+		new_frag = nfp_net_napi_alloc_one(dp, &new_dma_addr);
 		if (unlikely(!new_frag)) {
 			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, skb);
 			continue;
 		}
 
-		nfp_net_dma_unmap_rx(dp, rxbuf->dma_addr, rx_dma_map_dir);
+		nfp_net_dma_unmap_rx(dp, rxbuf->dma_addr);
 
 		nfp_net_rx_give_one(rx_ring, new_frag, new_dma_addr);
 
@@ -2899,6 +2885,7 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 
 	dp->xdp_prog = prog;
 	dp->num_tx_rings += prog ? nn->dp.num_rx_rings : -nn->dp.num_rx_rings;
+	dp->rx_dma_dir = prog ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
 
 	/* We need RX reconfig to remap the buffers (BIDIR vs FROM_DEV) */
 	err = nfp_net_ring_reconfig(nn, dp);
@@ -3128,6 +3115,8 @@ int nfp_net_netdev_init(struct net_device *netdev)
 
 	nn->dp.chained_metadata_format = nn->fw_ver.major > 3;
 
+	nn->dp.rx_dma_dir = DMA_FROM_DEVICE;
+
 	/* Get some of the read-only fields from the BAR */
 	nn->cap = nn_readl(nn, NFP_NET_CFG_CAP);
 	nn->max_mtu = nn_readl(nn, NFP_NET_CFG_MAX_MTU);
-- 
2.11.0
