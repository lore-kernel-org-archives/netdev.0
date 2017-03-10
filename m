From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 01/13] nfp: separate data path information from the reset of adapter structure
Date: Fri, 10 Mar 2017 10:38:27 -0800
Message-ID: <20170310183839.39568-2-jakub.kicinski@netronome.com>
References: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35099 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755365AbdCJSj0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:39:26 -0500
Received: by mail-pf0-f181.google.com with SMTP id j5so44843032pfb.2
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 10:39:26 -0800 (PST)
In-Reply-To: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move all data path information into a separate structure.  This way
we will be able to allocate new data path with all new rings etc.
and swap it in easily.

No functional changes.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       | 105 ++--
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 602 +++++++++++----------
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |   4 +-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  64 +--
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |  30 +-
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   |  30 +-
 .../net/ethernet/netronome/nfp/nfp_netvf_main.c    |  15 +-
 7 files changed, 436 insertions(+), 414 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 34f8c439f42f..7d2c38604372 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -50,14 +50,14 @@
 
 #include "nfp_net_ctrl.h"
 
-#define nn_err(nn, fmt, args...)  netdev_err((nn)->netdev, fmt, ## args)
-#define nn_warn(nn, fmt, args...) netdev_warn((nn)->netdev, fmt, ## args)
-#define nn_info(nn, fmt, args...) netdev_info((nn)->netdev, fmt, ## args)
-#define nn_dbg(nn, fmt, args...)  netdev_dbg((nn)->netdev, fmt, ## args)
-#define nn_warn_ratelimit(nn, fmt, args...)				\
+#define nn_err(nn, fmt, args...)  netdev_err((nn)->dp.netdev, fmt, ## args)
+#define nn_warn(nn, fmt, args...) netdev_warn((nn)->dp.netdev, fmt, ## args)
+#define nn_info(nn, fmt, args...) netdev_info((nn)->dp.netdev, fmt, ## args)
+#define nn_dbg(nn, fmt, args...)  netdev_dbg((nn)->dp.netdev, fmt, ## args)
+#define nn_dp_warn(dp, fmt, args...)					\
 	do {								\
 		if (unlikely(net_ratelimit()))				\
-			netdev_warn((nn)->netdev, fmt, ## args);	\
+			netdev_warn((dp)->netdev, fmt, ## args);	\
 	} while (0)
 
 /* Max time to wait for NFP to respond on updates (in seconds) */
@@ -434,18 +434,62 @@ struct nfp_stat_pair {
 };
 
 /**
- * struct nfp_net - NFP network device structure
+ * struct nfp_net_dp - NFP network device datapath data structure
  * @dev:		Backpointer to struct device
- * @netdev:             Backpointer to net_device structure
- * @is_vf:              Is the driver attached to a VF?
+ * @netdev:		Backpointer to net_device structure
+ * @is_vf:		Is the driver attached to a VF?
  * @bpf_offload_skip_sw:  Offloaded BPF program will not be rerun by cls_bpf
  * @bpf_offload_xdp:	Offloaded BPF program is XDP
  * @chained_metadata_format:  Firemware will use new metadata format
- * @ctrl:               Local copy of the control register/word.
- * @fl_bufsz:           Currently configured size of the freelist buffers
+ * @ctrl:		Local copy of the control register/word.
+ * @fl_bufsz:		Currently configured size of the freelist buffers
  * @rx_offset:		Offset in the RX buffers where packet data starts
  * @xdp_prog:		Installed XDP program
- * @fw_ver:             Firmware version
+ * @tx_rings:		Array of pre-allocated TX ring structures
+ * @rx_rings:		Array of pre-allocated RX ring structures
+ *
+ * @txd_cnt:		Size of the TX ring in number of descriptors
+ * @rxd_cnt:		Size of the RX ring in number of descriptors
+ * @num_r_vecs:		Number of used ring vectors
+ * @num_tx_rings:	Currently configured number of TX rings
+ * @num_stack_tx_rings:	Number of TX rings used by the stack (not XDP)
+ * @num_rx_rings:	Currently configured number of RX rings
+ */
+struct nfp_net_dp {
+	struct device *dev;
+	struct net_device *netdev;
+
+	unsigned is_vf:1;
+	unsigned bpf_offload_skip_sw:1;
+	unsigned bpf_offload_xdp:1;
+	unsigned chained_metadata_format:1;
+
+	u32 ctrl;
+	u32 fl_bufsz;
+
+	u32 rx_offset;
+
+	struct bpf_prog *xdp_prog;
+
+	struct nfp_net_tx_ring *tx_rings;
+	struct nfp_net_rx_ring *rx_rings;
+
+	/* Cold data follows */
+
+	unsigned int txd_cnt;
+	unsigned int rxd_cnt;
+
+	unsigned int num_r_vecs;
+
+	unsigned int num_tx_rings;
+	unsigned int num_stack_tx_rings;
+	unsigned int num_rx_rings;
+};
+
+/**
+ * struct nfp_net - NFP network device structure
+ * @dp:			Datapath structure
+ * @fw_ver:		Firmware version
  * @cap:                Capabilities advertised by the Firmware
  * @max_mtu:            Maximum support MTU advertised by the Firmware
  * @rss_hfunc:		RSS selected hash function
@@ -457,17 +501,9 @@ struct nfp_stat_pair {
  * @rx_filter_change:	Jiffies when statistics last changed
  * @rx_filter_stats_timer:  Timer for polling filter offload statistics
  * @rx_filter_lock:	Lock protecting timer state changes (teardown)
+ * @max_r_vecs:		Number of allocated interrupt vectors for RX/TX
  * @max_tx_rings:       Maximum number of TX rings supported by the Firmware
  * @max_rx_rings:       Maximum number of RX rings supported by the Firmware
- * @num_tx_rings:       Currently configured number of TX rings
- * @num_stack_tx_rings:	Number of TX rings used by the stack (not XDP)
- * @num_rx_rings:       Currently configured number of RX rings
- * @txd_cnt:            Size of the TX ring in number of descriptors
- * @rxd_cnt:            Size of the RX ring in number of descriptors
- * @tx_rings:           Array of pre-allocated TX ring structures
- * @rx_rings:           Array of pre-allocated RX ring structures
- * @max_r_vecs:	        Number of allocated interrupt vectors for RX/TX
- * @num_r_vecs:         Number of used ring vectors
  * @r_vecs:             Pre-allocated array of ring vectors
  * @irq_entries:        Pre-allocated array of MSI-X entries
  * @lsc_handler:        Handler for Link State Change interrupt
@@ -502,25 +538,10 @@ struct nfp_stat_pair {
  * @eth_port:		Translated ETH Table port entry
  */
 struct nfp_net {
-	struct device *dev;
-	struct net_device *netdev;
-
-	unsigned is_vf:1;
-	unsigned bpf_offload_skip_sw:1;
-	unsigned bpf_offload_xdp:1;
-	unsigned chained_metadata_format:1;
-
-	u32 ctrl;
-	u32 fl_bufsz;
-
-	u32 rx_offset;
-
-	struct bpf_prog *xdp_prog;
-
-	struct nfp_net_tx_ring *tx_rings;
-	struct nfp_net_rx_ring *rx_rings;
+	struct nfp_net_dp dp;
 
 	struct nfp_net_fw_version fw_ver;
+
 	u32 cap;
 	u32 max_mtu;
 
@@ -537,18 +558,10 @@ struct nfp_net {
 	unsigned int max_tx_rings;
 	unsigned int max_rx_rings;
 
-	unsigned int num_tx_rings;
-	unsigned int num_stack_tx_rings;
-	unsigned int num_rx_rings;
-
 	int stride_tx;
 	int stride_rx;
 
-	int txd_cnt;
-	int rxd_cnt;
-
 	unsigned int max_r_vecs;
-	unsigned int num_r_vecs;
 	struct nfp_net_r_vector r_vecs[NFP_NET_MAX_R_VECS];
 	struct msix_entry irq_entries[NFP_NET_MAX_IRQS];
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 2d964d030dbe..951d511643f1 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -86,18 +86,18 @@ void nfp_net_get_fw_version(struct nfp_net_fw_version *fw_ver,
 }
 
 static dma_addr_t
-nfp_net_dma_map_rx(struct nfp_net *nn, void *frag, unsigned int bufsz,
+nfp_net_dma_map_rx(struct nfp_net_dp *dp, void *frag, unsigned int bufsz,
 		   int direction)
 {
-	return dma_map_single(nn->dev, frag + NFP_NET_RX_BUF_HEADROOM,
+	return dma_map_single(dp->dev, frag + NFP_NET_RX_BUF_HEADROOM,
 			      bufsz - NFP_NET_RX_BUF_NON_DATA, direction);
 }
 
 static void
-nfp_net_dma_unmap_rx(struct nfp_net *nn, dma_addr_t dma_addr,
+nfp_net_dma_unmap_rx(struct nfp_net_dp *dp, dma_addr_t dma_addr,
 		     unsigned int bufsz, int direction)
 {
-	dma_unmap_single(nn->dev, dma_addr,
+	dma_unmap_single(dp->dev, dma_addr,
 			 bufsz - NFP_NET_RX_BUF_NON_DATA, direction);
 }
 
@@ -329,19 +329,22 @@ void
 nfp_net_irqs_assign(struct nfp_net *nn, struct msix_entry *irq_entries,
 		    unsigned int n)
 {
+	struct nfp_net_dp *dp = &nn->dp;
+
 	nn->max_r_vecs = n - NFP_NET_NON_Q_VECTORS;
-	nn->num_r_vecs = nn->max_r_vecs;
+	dp->num_r_vecs = nn->max_r_vecs;
 
 	memcpy(nn->irq_entries, irq_entries, sizeof(*irq_entries) * n);
 
-	if (nn->num_rx_rings > nn->num_r_vecs ||
-	    nn->num_tx_rings > nn->num_r_vecs)
+	if (dp->num_rx_rings > dp->num_r_vecs ||
+	    dp->num_tx_rings > dp->num_r_vecs)
 		nn_warn(nn, "More rings (%d,%d) than vectors (%d).\n",
-			nn->num_rx_rings, nn->num_tx_rings, nn->num_r_vecs);
+			dp->num_rx_rings, dp->num_tx_rings,
+			dp->num_r_vecs);
 
-	nn->num_rx_rings = min(nn->num_r_vecs, nn->num_rx_rings);
-	nn->num_tx_rings = min(nn->num_r_vecs, nn->num_tx_rings);
-	nn->num_stack_tx_rings = nn->num_tx_rings;
+	dp->num_rx_rings = min(dp->num_r_vecs, dp->num_rx_rings);
+	dp->num_tx_rings = min(dp->num_r_vecs, dp->num_tx_rings);
+	dp->num_stack_tx_rings = dp->num_tx_rings;
 }
 
 /**
@@ -396,11 +399,11 @@ static void nfp_net_read_link_status(struct nfp_net *nn)
 	nn->link_up = link_up;
 
 	if (nn->link_up) {
-		netif_carrier_on(nn->netdev);
-		netdev_info(nn->netdev, "NIC Link is Up\n");
+		netif_carrier_on(nn->dp.netdev);
+		netdev_info(nn->dp.netdev, "NIC Link is Up\n");
 	} else {
-		netif_carrier_off(nn->netdev);
-		netdev_info(nn->netdev, "NIC Link is Down\n");
+		netif_carrier_off(nn->dp.netdev);
+		netdev_info(nn->dp.netdev, "NIC Link is Down\n");
 	}
 out:
 	spin_unlock_irqrestore(&nn->link_status_lock, flags);
@@ -532,7 +535,7 @@ nfp_net_aux_irq_request(struct nfp_net *nn, u32 ctrl_offset,
 
 	entry = &nn->irq_entries[vector_idx];
 
-	snprintf(name, name_sz, format, netdev_name(nn->netdev));
+	snprintf(name, name_sz, format, netdev_name(nn->dp.netdev));
 	err = request_irq(entry->vector, handler, 0, name, nn);
 	if (err) {
 		nn_err(nn, "Failed to request IRQ %d (err=%d).\n",
@@ -619,7 +622,6 @@ static void nfp_net_tx_ring_stop(struct netdev_queue *nd_q,
 
 /**
  * nfp_net_tx_tso() - Set up Tx descriptor for LSO
- * @nn:  NFP Net device
  * @r_vec: per-ring structure
  * @txbuf: Pointer to driver soft TX descriptor
  * @txd: Pointer to HW TX descriptor
@@ -628,7 +630,7 @@ static void nfp_net_tx_ring_stop(struct netdev_queue *nd_q,
  * Set up Tx descriptor for LSO, do nothing for non-LSO skbs.
  * Return error on packet header greater than maximum supported LSO header size.
  */
-static void nfp_net_tx_tso(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
+static void nfp_net_tx_tso(struct nfp_net_r_vector *r_vec,
 			   struct nfp_net_tx_buf *txbuf,
 			   struct nfp_net_tx_desc *txd, struct sk_buff *skb)
 {
@@ -659,7 +661,7 @@ static void nfp_net_tx_tso(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
 
 /**
  * nfp_net_tx_csum() - Set TX CSUM offload flags in TX descriptor
- * @nn:  NFP Net device
+ * @dp:  NFP Net data path struct
  * @r_vec: per-ring structure
  * @txbuf: Pointer to driver soft TX descriptor
  * @txd: Pointer to TX descriptor
@@ -668,7 +670,8 @@ static void nfp_net_tx_tso(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
  * This function sets the TX checksum flags in the TX descriptor based
  * on the configuration and the protocol of the packet to be transmitted.
  */
-static void nfp_net_tx_csum(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
+static void nfp_net_tx_csum(struct nfp_net_dp *dp,
+			    struct nfp_net_r_vector *r_vec,
 			    struct nfp_net_tx_buf *txbuf,
 			    struct nfp_net_tx_desc *txd, struct sk_buff *skb)
 {
@@ -676,7 +679,7 @@ static void nfp_net_tx_csum(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
 	struct iphdr *iph;
 	u8 l4_hdr;
 
-	if (!(nn->ctrl & NFP_NET_CFG_CTRL_TXCSUM))
+	if (!(dp->ctrl & NFP_NET_CFG_CTRL_TXCSUM))
 		return;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
@@ -695,8 +698,7 @@ static void nfp_net_tx_csum(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
 	} else if (ipv6h->version == 6) {
 		l4_hdr = ipv6h->nexthdr;
 	} else {
-		nn_warn_ratelimit(nn, "partial checksum but ipv=%x!\n",
-				  iph->version);
+		nn_dp_warn(dp, "partial checksum but ipv=%x!\n", iph->version);
 		return;
 	}
 
@@ -708,8 +710,7 @@ static void nfp_net_tx_csum(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
 		txd->flags |= PCIE_DESC_TX_UDP_CSUM;
 		break;
 	default:
-		nn_warn_ratelimit(nn, "partial checksum but l4 proto=%x!\n",
-				  l4_hdr);
+		nn_dp_warn(dp, "partial checksum but l4 proto=%x!\n", l4_hdr);
 		return;
 	}
 
@@ -744,22 +745,24 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 	struct nfp_net_r_vector *r_vec;
 	struct nfp_net_tx_buf *txbuf;
 	struct netdev_queue *nd_q;
+	struct nfp_net_dp *dp;
 	dma_addr_t dma_addr;
 	unsigned int fsize;
 	int f, nr_frags;
 	int wr_idx;
 	u16 qidx;
 
+	dp = &nn->dp;
 	qidx = skb_get_queue_mapping(skb);
-	tx_ring = &nn->tx_rings[qidx];
+	tx_ring = &dp->tx_rings[qidx];
 	r_vec = tx_ring->r_vec;
-	nd_q = netdev_get_tx_queue(nn->netdev, qidx);
+	nd_q = netdev_get_tx_queue(dp->netdev, qidx);
 
 	nr_frags = skb_shinfo(skb)->nr_frags;
 
 	if (unlikely(nfp_net_tx_full(tx_ring, nr_frags + 1))) {
-		nn_warn_ratelimit(nn, "TX ring %d busy. wrp=%u rdp=%u\n",
-				  qidx, tx_ring->wr_p, tx_ring->rd_p);
+		nn_dp_warn(dp, "TX ring %d busy. wrp=%u rdp=%u\n",
+			   qidx, tx_ring->wr_p, tx_ring->rd_p);
 		netif_tx_stop_queue(nd_q);
 		u64_stats_update_begin(&r_vec->tx_sync);
 		r_vec->tx_busy++;
@@ -768,9 +771,9 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	/* Start with the head skbuf */
-	dma_addr = dma_map_single(nn->dev, skb->data, skb_headlen(skb),
+	dma_addr = dma_map_single(dp->dev, skb->data, skb_headlen(skb),
 				  DMA_TO_DEVICE);
-	if (dma_mapping_error(nn->dev, dma_addr))
+	if (dma_mapping_error(dp->dev, dma_addr))
 		goto err_free;
 
 	wr_idx = tx_ring->wr_p & (tx_ring->cnt - 1);
@@ -794,11 +797,11 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 	txd->mss = 0;
 	txd->l4_offset = 0;
 
-	nfp_net_tx_tso(nn, r_vec, txbuf, txd, skb);
+	nfp_net_tx_tso(r_vec, txbuf, txd, skb);
 
-	nfp_net_tx_csum(nn, r_vec, txbuf, txd, skb);
+	nfp_net_tx_csum(dp, r_vec, txbuf, txd, skb);
 
-	if (skb_vlan_tag_present(skb) && nn->ctrl & NFP_NET_CFG_CTRL_TXVLAN) {
+	if (skb_vlan_tag_present(skb) && dp->ctrl & NFP_NET_CFG_CTRL_TXVLAN) {
 		txd->flags |= PCIE_DESC_TX_VLAN;
 		txd->vlan = cpu_to_le16(skb_vlan_tag_get(skb));
 	}
@@ -812,9 +815,9 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 			frag = &skb_shinfo(skb)->frags[f];
 			fsize = skb_frag_size(frag);
 
-			dma_addr = skb_frag_dma_map(nn->dev, frag, 0,
+			dma_addr = skb_frag_dma_map(dp->dev, frag, 0,
 						    fsize, DMA_TO_DEVICE);
-			if (dma_mapping_error(nn->dev, dma_addr))
+			if (dma_mapping_error(dp->dev, dma_addr))
 				goto err_unmap;
 
 			wr_idx = (wr_idx + 1) & (tx_ring->cnt - 1);
@@ -853,7 +856,7 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 	--f;
 	while (f >= 0) {
 		frag = &skb_shinfo(skb)->frags[f];
-		dma_unmap_page(nn->dev, tx_ring->txbufs[wr_idx].dma_addr,
+		dma_unmap_page(dp->dev, tx_ring->txbufs[wr_idx].dma_addr,
 			       skb_frag_size(frag), DMA_TO_DEVICE);
 		tx_ring->txbufs[wr_idx].skb = NULL;
 		tx_ring->txbufs[wr_idx].dma_addr = 0;
@@ -862,13 +865,13 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 		if (wr_idx < 0)
 			wr_idx += tx_ring->cnt;
 	}
-	dma_unmap_single(nn->dev, tx_ring->txbufs[wr_idx].dma_addr,
+	dma_unmap_single(dp->dev, tx_ring->txbufs[wr_idx].dma_addr,
 			 skb_headlen(skb), DMA_TO_DEVICE);
 	tx_ring->txbufs[wr_idx].skb = NULL;
 	tx_ring->txbufs[wr_idx].dma_addr = 0;
 	tx_ring->txbufs[wr_idx].fidx = -2;
 err_free:
-	nn_warn_ratelimit(nn, "Failed to map DMA TX buffer\n");
+	nn_dp_warn(dp, "Failed to map DMA TX buffer\n");
 	u64_stats_update_begin(&r_vec->tx_sync);
 	r_vec->tx_errors++;
 	u64_stats_update_end(&r_vec->tx_sync);
@@ -885,7 +888,7 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 {
 	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
-	struct nfp_net *nn = r_vec->nfp_net;
+	struct nfp_net_dp *dp = &r_vec->nfp_net->dp;
 	const struct skb_frag_struct *frag;
 	struct netdev_queue *nd_q;
 	u32 done_pkts = 0, done_bytes = 0;
@@ -919,7 +922,7 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 
 		if (fidx == -1) {
 			/* unmap head */
-			dma_unmap_single(nn->dev, tx_ring->txbufs[idx].dma_addr,
+			dma_unmap_single(dp->dev, tx_ring->txbufs[idx].dma_addr,
 					 skb_headlen(skb), DMA_TO_DEVICE);
 
 			done_pkts += tx_ring->txbufs[idx].pkt_cnt;
@@ -927,7 +930,7 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 		} else {
 			/* unmap fragment */
 			frag = &skb_shinfo(skb)->frags[fidx];
-			dma_unmap_page(nn->dev, tx_ring->txbufs[idx].dma_addr,
+			dma_unmap_page(dp->dev, tx_ring->txbufs[idx].dma_addr,
 				       skb_frag_size(frag), DMA_TO_DEVICE);
 		}
 
@@ -947,7 +950,7 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 	r_vec->tx_pkts += done_pkts;
 	u64_stats_update_end(&r_vec->tx_sync);
 
-	nd_q = netdev_get_tx_queue(nn->netdev, tx_ring->idx);
+	nd_q = netdev_get_tx_queue(dp->netdev, tx_ring->idx);
 	netdev_tx_completed_queue(nd_q, done_pkts, done_bytes);
 	if (nfp_net_tx_ring_should_wake(tx_ring)) {
 		/* Make sure TX thread will see updated tx_ring->rd_p */
@@ -965,7 +968,7 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 static void nfp_net_xdp_complete(struct nfp_net_tx_ring *tx_ring)
 {
 	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
-	struct nfp_net *nn = r_vec->nfp_net;
+	struct nfp_net_dp *dp = &r_vec->nfp_net->dp;
 	u32 done_pkts = 0, done_bytes = 0;
 	int idx, todo;
 	u32 qcp_rd_p;
@@ -988,8 +991,8 @@ static void nfp_net_xdp_complete(struct nfp_net_tx_ring *tx_ring)
 		if (!tx_ring->txbufs[idx].frag)
 			continue;
 
-		nfp_net_dma_unmap_rx(nn, tx_ring->txbufs[idx].dma_addr,
-				     nn->fl_bufsz, DMA_BIDIRECTIONAL);
+		nfp_net_dma_unmap_rx(dp, tx_ring->txbufs[idx].dma_addr,
+				     dp->fl_bufsz, DMA_BIDIRECTIONAL);
 		__free_page(virt_to_page(tx_ring->txbufs[idx].frag));
 
 		done_pkts++;
@@ -1014,13 +1017,13 @@ static void nfp_net_xdp_complete(struct nfp_net_tx_ring *tx_ring)
 
 /**
  * nfp_net_tx_ring_reset() - Free any untransmitted buffers and reset pointers
- * @nn:		NFP Net device
+ * @dp:		NFP Net data path struct
  * @tx_ring:	TX ring structure
  *
  * Assumes that the device is stopped
  */
 static void
-nfp_net_tx_ring_reset(struct nfp_net *nn, struct nfp_net_tx_ring *tx_ring)
+nfp_net_tx_ring_reset(struct nfp_net_dp *dp, struct nfp_net_tx_ring *tx_ring)
 {
 	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
 	const struct skb_frag_struct *frag;
@@ -1034,8 +1037,8 @@ nfp_net_tx_ring_reset(struct nfp_net *nn, struct nfp_net_tx_ring *tx_ring)
 		tx_buf = &tx_ring->txbufs[idx];
 
 		if (tx_ring == r_vec->xdp_ring) {
-			nfp_net_dma_unmap_rx(nn, tx_buf->dma_addr,
-					     nn->fl_bufsz, DMA_BIDIRECTIONAL);
+			nfp_net_dma_unmap_rx(dp, tx_buf->dma_addr,
+					     dp->fl_bufsz, DMA_BIDIRECTIONAL);
 			__free_page(virt_to_page(tx_ring->txbufs[idx].frag));
 		} else {
 			struct sk_buff *skb = tx_ring->txbufs[idx].skb;
@@ -1043,13 +1046,13 @@ nfp_net_tx_ring_reset(struct nfp_net *nn, struct nfp_net_tx_ring *tx_ring)
 
 			if (tx_buf->fidx == -1) {
 				/* unmap head */
-				dma_unmap_single(nn->dev, tx_buf->dma_addr,
+				dma_unmap_single(dp->dev, tx_buf->dma_addr,
 						 skb_headlen(skb),
 						 DMA_TO_DEVICE);
 			} else {
 				/* unmap fragment */
 				frag = &skb_shinfo(skb)->frags[tx_buf->fidx];
-				dma_unmap_page(nn->dev, tx_buf->dma_addr,
+				dma_unmap_page(dp->dev, tx_buf->dma_addr,
 					       skb_frag_size(frag),
 					       DMA_TO_DEVICE);
 			}
@@ -1076,7 +1079,7 @@ nfp_net_tx_ring_reset(struct nfp_net *nn, struct nfp_net_tx_ring *tx_ring)
 	if (tx_ring == r_vec->xdp_ring)
 		return;
 
-	nd_q = netdev_get_tx_queue(nn->netdev, tx_ring->idx);
+	nd_q = netdev_get_tx_queue(dp->netdev, tx_ring->idx);
 	netdev_tx_reset_queue(nd_q);
 }
 
@@ -1085,7 +1088,7 @@ static void nfp_net_tx_timeout(struct net_device *netdev)
 	struct nfp_net *nn = netdev_priv(netdev);
 	int i;
 
-	for (i = 0; i < nn->netdev->real_num_tx_queues; i++) {
+	for (i = 0; i < nn->dp.netdev->real_num_tx_queues; i++) {
 		if (!netif_tx_queue_stopped(netdev_get_tx_queue(netdev, i)))
 			continue;
 		nn_warn(nn, "TX timeout on ring: %d\n", i);
@@ -1096,15 +1099,15 @@ static void nfp_net_tx_timeout(struct net_device *netdev)
 /* Receive processing
  */
 static unsigned int
-nfp_net_calc_fl_bufsz(struct nfp_net *nn, unsigned int mtu)
+nfp_net_calc_fl_bufsz(struct nfp_net_dp *dp, unsigned int mtu)
 {
 	unsigned int fl_bufsz;
 
 	fl_bufsz = NFP_NET_RX_BUF_HEADROOM;
-	if (nn->rx_offset == NFP_NET_CFG_RX_OFFSET_DYNAMIC)
+	if (dp->rx_offset == NFP_NET_CFG_RX_OFFSET_DYNAMIC)
 		fl_bufsz += NFP_NET_MAX_PREPEND;
 	else
-		fl_bufsz += nn->rx_offset;
+		fl_bufsz += dp->rx_offset;
 	fl_bufsz += ETH_HLEN + VLAN_HLEN * 2 + mtu;
 
 	fl_bufsz = SKB_DATA_ALIGN(fl_bufsz);
@@ -1137,7 +1140,7 @@ static void *
 nfp_net_rx_alloc_one(struct nfp_net_rx_ring *rx_ring, dma_addr_t *dma_addr,
 		     unsigned int fl_bufsz, bool xdp)
 {
-	struct nfp_net *nn = rx_ring->r_vec->nfp_net;
+	struct nfp_net_dp *dp = &rx_ring->r_vec->nfp_net->dp;
 	int direction;
 	void *frag;
 
@@ -1146,16 +1149,16 @@ nfp_net_rx_alloc_one(struct nfp_net_rx_ring *rx_ring, dma_addr_t *dma_addr,
 	else
 		frag = page_address(alloc_page(GFP_KERNEL | __GFP_COLD));
 	if (!frag) {
-		nn_warn_ratelimit(nn, "Failed to alloc receive page frag\n");
+		nn_dp_warn(dp, "Failed to alloc receive page frag\n");
 		return NULL;
 	}
 
 	direction = xdp ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
 
-	*dma_addr = nfp_net_dma_map_rx(nn, frag, fl_bufsz, direction);
-	if (dma_mapping_error(nn->dev, *dma_addr)) {
+	*dma_addr = nfp_net_dma_map_rx(dp, frag, fl_bufsz, direction);
+	if (dma_mapping_error(dp->dev, *dma_addr)) {
 		nfp_net_free_frag(frag, xdp);
-		nn_warn_ratelimit(nn, "Failed to map DMA RX buffer\n");
+		nn_dp_warn(dp, "Failed to map DMA RX buffer\n");
 		return NULL;
 	}
 
@@ -1163,23 +1166,24 @@ nfp_net_rx_alloc_one(struct nfp_net_rx_ring *rx_ring, dma_addr_t *dma_addr,
 }
 
 static void *
-nfp_net_napi_alloc_one(struct nfp_net *nn, int direction, dma_addr_t *dma_addr)
+nfp_net_napi_alloc_one(struct nfp_net_dp *dp, int direction,
+		       dma_addr_t *dma_addr)
 {
 	void *frag;
 
-	if (!nn->xdp_prog)
-		frag = napi_alloc_frag(nn->fl_bufsz);
+	if (!dp->xdp_prog)
+		frag = napi_alloc_frag(dp->fl_bufsz);
 	else
 		frag = page_address(alloc_page(GFP_ATOMIC | __GFP_COLD));
 	if (!frag) {
-		nn_warn_ratelimit(nn, "Failed to alloc receive page frag\n");
+		nn_dp_warn(dp, "Failed to alloc receive page frag\n");
 		return NULL;
 	}
 
-	*dma_addr = nfp_net_dma_map_rx(nn, frag, nn->fl_bufsz, direction);
-	if (dma_mapping_error(nn->dev, *dma_addr)) {
-		nfp_net_free_frag(frag, nn->xdp_prog);
-		nn_warn_ratelimit(nn, "Failed to map DMA RX buffer\n");
+	*dma_addr = nfp_net_dma_map_rx(dp, frag, dp->fl_bufsz, direction);
+	if (dma_mapping_error(dp->dev, *dma_addr)) {
+		nfp_net_free_frag(frag, dp->xdp_prog);
+		nn_dp_warn(dp, "Failed to map DMA RX buffer\n");
 		return NULL;
 	}
 
@@ -1247,7 +1251,7 @@ static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
 
 /**
  * nfp_net_rx_ring_bufs_free() - Free any buffers currently on the RX ring
- * @nn:		NFP Net device
+ * @dp:		NFP Net data path struct
  * @rx_ring:	RX ring to remove buffers from
  * @xdp:	Whether XDP is enabled
  *
@@ -1256,8 +1260,8 @@ static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
  * to restore required ring geometry.
  */
 static void
-nfp_net_rx_ring_bufs_free(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
-			  bool xdp)
+nfp_net_rx_ring_bufs_free(struct nfp_net_dp *dp,
+			  struct nfp_net_rx_ring *rx_ring, bool xdp)
 {
 	int direction = xdp ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
 	unsigned int i;
@@ -1270,7 +1274,7 @@ nfp_net_rx_ring_bufs_free(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
 		if (!rx_ring->rxbufs[i].frag)
 			continue;
 
-		nfp_net_dma_unmap_rx(nn, rx_ring->rxbufs[i].dma_addr,
+		nfp_net_dma_unmap_rx(dp, rx_ring->rxbufs[i].dma_addr,
 				     rx_ring->bufsz, direction);
 		nfp_net_free_frag(rx_ring->rxbufs[i].frag, xdp);
 		rx_ring->rxbufs[i].dma_addr = 0;
@@ -1280,13 +1284,13 @@ nfp_net_rx_ring_bufs_free(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
 
 /**
  * nfp_net_rx_ring_bufs_alloc() - Fill RX ring with buffers (don't give to FW)
- * @nn:		NFP Net device
+ * @dp:		NFP Net data path struct
  * @rx_ring:	RX ring to remove buffers from
  * @xdp:	Whether XDP is enabled
  */
 static int
-nfp_net_rx_ring_bufs_alloc(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
-			   bool xdp)
+nfp_net_rx_ring_bufs_alloc(struct nfp_net_dp *dp,
+			   struct nfp_net_rx_ring *rx_ring, bool xdp)
 {
 	struct nfp_net_rx_buf *rxbufs;
 	unsigned int i;
@@ -1298,7 +1302,7 @@ nfp_net_rx_ring_bufs_alloc(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
 			nfp_net_rx_alloc_one(rx_ring, &rxbufs[i].dma_addr,
 					     rx_ring->bufsz, xdp);
 		if (!rxbufs[i].frag) {
-			nfp_net_rx_ring_bufs_free(nn, rx_ring, xdp);
+			nfp_net_rx_ring_bufs_free(dp, rx_ring, xdp);
 			return -ENOMEM;
 		}
 	}
@@ -1335,17 +1339,18 @@ static int nfp_net_rx_csum_has_errors(u16 flags)
 
 /**
  * nfp_net_rx_csum() - set SKB checksum field based on RX descriptor flags
- * @nn:  NFP Net device
+ * @dp:  NFP Net data path struct
  * @r_vec: per-ring structure
  * @rxd: Pointer to RX descriptor
  * @skb: Pointer to SKB
  */
-static void nfp_net_rx_csum(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
+static void nfp_net_rx_csum(struct nfp_net_dp *dp,
+			    struct nfp_net_r_vector *r_vec,
 			    struct nfp_net_rx_desc *rxd, struct sk_buff *skb)
 {
 	skb_checksum_none_assert(skb);
 
-	if (!(nn->netdev->features & NETIF_F_RXCSUM))
+	if (!(dp->netdev->features & NETIF_F_RXCSUM))
 		return;
 
 	if (nfp_net_rx_csum_has_errors(le16_to_cpu(rxd->rxd.flags))) {
@@ -1462,7 +1467,7 @@ nfp_net_rx_drop(struct nfp_net_r_vector *r_vec, struct nfp_net_rx_ring *rx_ring,
 }
 
 static bool
-nfp_net_tx_xdp_buf(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
+nfp_net_tx_xdp_buf(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 		   struct nfp_net_tx_ring *tx_ring,
 		   struct nfp_net_rx_buf *rxbuf, unsigned int pkt_off,
 		   unsigned int pkt_len)
@@ -1478,7 +1483,7 @@ nfp_net_tx_xdp_buf(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
 		return false;
 	}
 
-	new_frag = nfp_net_napi_alloc_one(nn, DMA_BIDIRECTIONAL, &new_dma_addr);
+	new_frag = nfp_net_napi_alloc_one(dp, DMA_BIDIRECTIONAL, &new_dma_addr);
 	if (unlikely(!new_frag)) {
 		nfp_net_rx_drop(rx_ring->r_vec, rx_ring, rxbuf, NULL);
 		return false;
@@ -1495,7 +1500,7 @@ nfp_net_tx_xdp_buf(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
 	txbuf->pkt_cnt = 1;
 	txbuf->real_len = pkt_len;
 
-	dma_sync_single_for_device(nn->dev, rxbuf->dma_addr + pkt_off,
+	dma_sync_single_for_device(dp->dev, rxbuf->dma_addr + pkt_off,
 				   pkt_len, DMA_BIDIRECTIONAL);
 
 	/* Build TX descriptor */
@@ -1538,7 +1543,7 @@ static int nfp_net_run_xdp(struct bpf_prog *prog, void *data, unsigned int len)
 static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 {
 	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
-	struct nfp_net *nn = r_vec->nfp_net;
+	struct nfp_net_dp *dp = &r_vec->nfp_net->dp;
 	struct nfp_net_tx_ring *tx_ring;
 	struct bpf_prog *xdp_prog;
 	unsigned int true_bufsz;
@@ -1548,9 +1553,9 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 	int idx;
 
 	rcu_read_lock();
-	xdp_prog = READ_ONCE(nn->xdp_prog);
+	xdp_prog = READ_ONCE(dp->xdp_prog);
 	rx_dma_map_dir = xdp_prog ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
-	true_bufsz = xdp_prog ? PAGE_SIZE : nn->fl_bufsz;
+	true_bufsz = xdp_prog ? PAGE_SIZE : dp->fl_bufsz;
 	tx_ring = r_vec->xdp_ring;
 
 	while (pkts_polled < budget) {
@@ -1591,10 +1596,10 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		data_len = le16_to_cpu(rxd->rxd.data_len);
 		pkt_len = data_len - meta_len;
 
-		if (nn->rx_offset == NFP_NET_CFG_RX_OFFSET_DYNAMIC)
+		if (dp->rx_offset == NFP_NET_CFG_RX_OFFSET_DYNAMIC)
 			pkt_off = meta_len;
 		else
-			pkt_off = nn->rx_offset;
+			pkt_off = dp->rx_offset;
 		data_off = NFP_NET_RX_BUF_HEADROOM + pkt_off;
 
 		/* Stats update */
@@ -1604,10 +1609,10 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		u64_stats_update_end(&r_vec->rx_sync);
 
 		if (xdp_prog && !(rxd->rxd.flags & PCIE_DESC_RX_BPF &&
-				  nn->bpf_offload_xdp)) {
+				  dp->bpf_offload_xdp)) {
 			int act;
 
-			dma_sync_single_for_cpu(nn->dev,
+			dma_sync_single_for_cpu(dp->dev,
 						rxbuf->dma_addr + pkt_off,
 						pkt_len, DMA_BIDIRECTIONAL);
 			act = nfp_net_run_xdp(xdp_prog, rxbuf->frag + data_off,
@@ -1616,15 +1621,17 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			case XDP_PASS:
 				break;
 			case XDP_TX:
-				if (unlikely(!nfp_net_tx_xdp_buf(nn, rx_ring,
+				if (unlikely(!nfp_net_tx_xdp_buf(dp, rx_ring,
 								 tx_ring, rxbuf,
-								 pkt_off, pkt_len)))
-					trace_xdp_exception(nn->netdev, xdp_prog, act);
+								 pkt_off,
+								 pkt_len)))
+					trace_xdp_exception(dp->netdev,
+							    xdp_prog, act);
 				continue;
 			default:
 				bpf_warn_invalid_xdp_action(act);
 			case XDP_ABORTED:
-				trace_xdp_exception(nn->netdev, xdp_prog, act);
+				trace_xdp_exception(dp->netdev, xdp_prog, act);
 			case XDP_DROP:
 				nfp_net_rx_give_one(rx_ring, rxbuf->frag,
 						    rxbuf->dma_addr);
@@ -1637,14 +1644,14 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, NULL);
 			continue;
 		}
-		new_frag = nfp_net_napi_alloc_one(nn, rx_dma_map_dir,
+		new_frag = nfp_net_napi_alloc_one(dp, rx_dma_map_dir,
 						  &new_dma_addr);
 		if (unlikely(!new_frag)) {
 			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, skb);
 			continue;
 		}
 
-		nfp_net_dma_unmap_rx(nn, rxbuf->dma_addr, nn->fl_bufsz,
+		nfp_net_dma_unmap_rx(dp, rxbuf->dma_addr, dp->fl_bufsz,
 				     rx_dma_map_dir);
 
 		nfp_net_rx_give_one(rx_ring, new_frag, new_dma_addr);
@@ -1652,23 +1659,23 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		skb_reserve(skb, data_off);
 		skb_put(skb, pkt_len);
 
-		if (!nn->chained_metadata_format) {
-			nfp_net_set_hash_desc(nn->netdev, skb, rxd);
+		if (!dp->chained_metadata_format) {
+			nfp_net_set_hash_desc(dp->netdev, skb, rxd);
 		} else if (meta_len) {
 			void *end;
 
-			end = nfp_net_parse_meta(nn->netdev, skb, meta_len);
+			end = nfp_net_parse_meta(dp->netdev, skb, meta_len);
 			if (unlikely(end != skb->data)) {
-				nn_warn_ratelimit(nn, "invalid RX packet metadata\n");
+				nn_dp_warn(dp, "invalid RX packet metadata\n");
 				nfp_net_rx_drop(r_vec, rx_ring, NULL, skb);
 				continue;
 			}
 		}
 
 		skb_record_rx_queue(skb, rx_ring->idx);
-		skb->protocol = eth_type_trans(skb, nn->netdev);
+		skb->protocol = eth_type_trans(skb, dp->netdev);
 
-		nfp_net_rx_csum(nn, r_vec, rxd, skb);
+		nfp_net_rx_csum(dp, r_vec, rxd, skb);
 
 		if (rxd->rxd.flags & PCIE_DESC_RX_VLAN)
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
@@ -1722,12 +1729,12 @@ static int nfp_net_poll(struct napi_struct *napi, int budget)
 static void nfp_net_tx_ring_free(struct nfp_net_tx_ring *tx_ring)
 {
 	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
-	struct nfp_net *nn = r_vec->nfp_net;
+	struct nfp_net_dp *dp = &r_vec->nfp_net->dp;
 
 	kfree(tx_ring->txbufs);
 
 	if (tx_ring->txds)
-		dma_free_coherent(nn->dev, tx_ring->size,
+		dma_free_coherent(dp->dev, tx_ring->size,
 				  tx_ring->txds, tx_ring->dma);
 
 	tx_ring->cnt = 0;
@@ -1749,13 +1756,13 @@ static int
 nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt, bool is_xdp)
 {
 	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
-	struct nfp_net *nn = r_vec->nfp_net;
+	struct nfp_net_dp *dp = &r_vec->nfp_net->dp;
 	int sz;
 
 	tx_ring->cnt = cnt;
 
 	tx_ring->size = sizeof(*tx_ring->txds) * tx_ring->cnt;
-	tx_ring->txds = dma_zalloc_coherent(nn->dev, tx_ring->size,
+	tx_ring->txds = dma_zalloc_coherent(dp->dev, tx_ring->size,
 					    &tx_ring->dma, GFP_KERNEL);
 	if (!tx_ring->txds)
 		goto err_alloc;
@@ -1766,7 +1773,7 @@ nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt, bool is_xdp)
 		goto err_alloc;
 
 	if (!is_xdp)
-		netif_set_xps_queue(nn->netdev, &r_vec->affinity_mask,
+		netif_set_xps_queue(dp->netdev, &r_vec->affinity_mask,
 				    tx_ring->idx);
 
 	return 0;
@@ -1813,17 +1820,16 @@ nfp_net_tx_ring_set_swap(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
 	struct nfp_net_ring_set new = *s;
 
-	s->dcnt = nn->txd_cnt;
-	s->rings = nn->tx_rings;
-	s->n_rings = nn->num_tx_rings;
+	s->dcnt = nn->dp.txd_cnt;
+	s->rings = nn->dp.tx_rings;
+	s->n_rings = nn->dp.num_tx_rings;
 
-	nn->txd_cnt = new.dcnt;
-	nn->tx_rings = new.rings;
-	nn->num_tx_rings = new.n_rings;
+	nn->dp.txd_cnt = new.dcnt;
+	nn->dp.tx_rings = new.rings;
+	nn->dp.num_tx_rings = new.n_rings;
 }
 
-static void
-nfp_net_tx_ring_set_free(struct nfp_net *nn, struct nfp_net_ring_set *s)
+static void nfp_net_tx_ring_set_free(struct nfp_net_ring_set *s)
 {
 	struct nfp_net_tx_ring *rings = s->rings;
 	unsigned int r;
@@ -1841,12 +1847,12 @@ nfp_net_tx_ring_set_free(struct nfp_net *nn, struct nfp_net_ring_set *s)
 static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 {
 	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
-	struct nfp_net *nn = r_vec->nfp_net;
+	struct nfp_net_dp *dp = &r_vec->nfp_net->dp;
 
 	kfree(rx_ring->rxbufs);
 
 	if (rx_ring->rxds)
-		dma_free_coherent(nn->dev, rx_ring->size,
+		dma_free_coherent(dp->dev, rx_ring->size,
 				  rx_ring->rxds, rx_ring->dma);
 
 	rx_ring->cnt = 0;
@@ -1869,14 +1875,14 @@ nfp_net_rx_ring_alloc(struct nfp_net_rx_ring *rx_ring, unsigned int fl_bufsz,
 		      u32 cnt)
 {
 	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
-	struct nfp_net *nn = r_vec->nfp_net;
+	struct nfp_net_dp *dp = &r_vec->nfp_net->dp;
 	int sz;
 
 	rx_ring->cnt = cnt;
 	rx_ring->bufsz = fl_bufsz;
 
 	rx_ring->size = sizeof(*rx_ring->rxds) * rx_ring->cnt;
-	rx_ring->rxds = dma_zalloc_coherent(nn->dev, rx_ring->size,
+	rx_ring->rxds = dma_zalloc_coherent(dp->dev, rx_ring->size,
 					    &rx_ring->dma, GFP_KERNEL);
 	if (!rx_ring->rxds)
 		goto err_alloc;
@@ -1897,7 +1903,7 @@ static struct nfp_net_rx_ring *
 nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s,
 			    bool xdp)
 {
-	unsigned int fl_bufsz =	nfp_net_calc_fl_bufsz(nn, s->mtu);
+	unsigned int fl_bufsz =	nfp_net_calc_fl_bufsz(&nn->dp, s->mtu);
 	struct nfp_net_rx_ring *rings;
 	unsigned int r;
 
@@ -1911,7 +1917,7 @@ nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s,
 		if (nfp_net_rx_ring_alloc(&rings[r], fl_bufsz, s->dcnt))
 			goto err_free_prev;
 
-		if (nfp_net_rx_ring_bufs_alloc(nn, &rings[r], xdp))
+		if (nfp_net_rx_ring_bufs_alloc(&nn->dp, &rings[r], xdp))
 			goto err_free_ring;
 	}
 
@@ -1919,7 +1925,7 @@ nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s,
 
 err_free_prev:
 	while (r--) {
-		nfp_net_rx_ring_bufs_free(nn, &rings[r], xdp);
+		nfp_net_rx_ring_bufs_free(&nn->dp, &rings[r], xdp);
 err_free_ring:
 		nfp_net_rx_ring_free(&rings[r]);
 	}
@@ -1932,27 +1938,27 @@ nfp_net_rx_ring_set_swap(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
 	struct nfp_net_ring_set new = *s;
 
-	s->mtu = nn->netdev->mtu;
-	s->dcnt = nn->rxd_cnt;
-	s->rings = nn->rx_rings;
-	s->n_rings = nn->num_rx_rings;
+	s->mtu = nn->dp.netdev->mtu;
+	s->dcnt = nn->dp.rxd_cnt;
+	s->rings = nn->dp.rx_rings;
+	s->n_rings = nn->dp.num_rx_rings;
 
-	nn->netdev->mtu = new.mtu;
-	nn->fl_bufsz = nfp_net_calc_fl_bufsz(nn, new.mtu);
-	nn->rxd_cnt = new.dcnt;
-	nn->rx_rings = new.rings;
-	nn->num_rx_rings = new.n_rings;
+	nn->dp.netdev->mtu = new.mtu;
+	nn->dp.fl_bufsz = nfp_net_calc_fl_bufsz(&nn->dp, new.mtu);
+	nn->dp.rxd_cnt = new.dcnt;
+	nn->dp.rx_rings = new.rings;
+	nn->dp.num_rx_rings = new.n_rings;
 }
 
 static void
-nfp_net_rx_ring_set_free(struct nfp_net *nn, struct nfp_net_ring_set *s,
+nfp_net_rx_ring_set_free(struct nfp_net_dp *dp, struct nfp_net_ring_set *s,
 			 bool xdp)
 {
 	struct nfp_net_rx_ring *rings = s->rings;
 	unsigned int r;
 
 	for (r = 0; r < s->n_rings; r++) {
-		nfp_net_rx_ring_bufs_free(nn, &rings[r], xdp);
+		nfp_net_rx_ring_bufs_free(dp, &rings[r], xdp);
 		nfp_net_rx_ring_free(&rings[r]);
 	}
 
@@ -1960,15 +1966,15 @@ nfp_net_rx_ring_set_free(struct nfp_net *nn, struct nfp_net_ring_set *s,
 }
 
 static void
-nfp_net_vector_assign_rings(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
-			    int idx)
+nfp_net_vector_assign_rings(struct nfp_net_dp *dp,
+			    struct nfp_net_r_vector *r_vec, int idx)
 {
-	r_vec->rx_ring = idx < nn->num_rx_rings ? &nn->rx_rings[idx] : NULL;
+	r_vec->rx_ring = idx < dp->num_rx_rings ? &dp->rx_rings[idx] : NULL;
 	r_vec->tx_ring =
-		idx < nn->num_stack_tx_rings ? &nn->tx_rings[idx] : NULL;
+		idx < dp->num_stack_tx_rings ? &dp->tx_rings[idx] : NULL;
 
-	r_vec->xdp_ring = idx < nn->num_tx_rings - nn->num_stack_tx_rings ?
-		&nn->tx_rings[nn->num_stack_tx_rings + idx] : NULL;
+	r_vec->xdp_ring = idx < dp->num_tx_rings - dp->num_stack_tx_rings ?
+		&dp->tx_rings[dp->num_stack_tx_rings + idx] : NULL;
 }
 
 static int
@@ -1978,11 +1984,11 @@ nfp_net_prepare_vector(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
 	int err;
 
 	/* Setup NAPI */
-	netif_napi_add(nn->netdev, &r_vec->napi,
+	netif_napi_add(nn->dp.netdev, &r_vec->napi,
 		       nfp_net_poll, NAPI_POLL_WEIGHT);
 
 	snprintf(r_vec->name, sizeof(r_vec->name),
-		 "%s-rxtx-%d", nn->netdev->name, idx);
+		 "%s-rxtx-%d", nn->dp.netdev->name, idx);
 	err = request_irq(r_vec->irq_vector, r_vec->handler, 0, r_vec->name,
 			  r_vec);
 	if (err) {
@@ -2053,13 +2059,13 @@ void nfp_net_coalesce_write_cfg(struct nfp_net *nn)
 	/* copy RX interrupt coalesce parameters */
 	value = (nn->rx_coalesce_max_frames << 16) |
 		(factor * nn->rx_coalesce_usecs);
-	for (i = 0; i < nn->num_rx_rings; i++)
+	for (i = 0; i < nn->dp.num_rx_rings; i++)
 		nn_writel(nn, NFP_NET_CFG_RXR_IRQ_MOD(i), value);
 
 	/* copy TX interrupt coalesce parameters */
 	value = (nn->tx_coalesce_max_frames << 16) |
 		(factor * nn->tx_coalesce_usecs);
-	for (i = 0; i < nn->num_tx_rings; i++)
+	for (i = 0; i < nn->dp.num_tx_rings; i++)
 		nn_writel(nn, NFP_NET_CFG_TXR_IRQ_MOD(i), value);
 }
 
@@ -2074,9 +2080,9 @@ void nfp_net_coalesce_write_cfg(struct nfp_net *nn)
 static void nfp_net_write_mac_addr(struct nfp_net *nn)
 {
 	nn_writel(nn, NFP_NET_CFG_MACADDR + 0,
-		  get_unaligned_be32(nn->netdev->dev_addr));
+		  get_unaligned_be32(nn->dp.netdev->dev_addr));
 	nn_writew(nn, NFP_NET_CFG_MACADDR + 6,
-		  get_unaligned_be16(nn->netdev->dev_addr + 4));
+		  get_unaligned_be16(nn->dp.netdev->dev_addr + 4));
 }
 
 static void nfp_net_vec_clear_ring_data(struct nfp_net *nn, unsigned int idx)
@@ -2100,7 +2106,7 @@ static void nfp_net_clear_config_and_disable(struct nfp_net *nn)
 	unsigned int r;
 	int err;
 
-	new_ctrl = nn->ctrl;
+	new_ctrl = nn->dp.ctrl;
 	new_ctrl &= ~NFP_NET_CFG_CTRL_ENABLE;
 	update = NFP_NET_CFG_UPDATE_GEN;
 	update |= NFP_NET_CFG_UPDATE_MSIX;
@@ -2117,14 +2123,14 @@ static void nfp_net_clear_config_and_disable(struct nfp_net *nn)
 	if (err)
 		nn_err(nn, "Could not disable device: %d\n", err);
 
-	for (r = 0; r < nn->num_rx_rings; r++)
-		nfp_net_rx_ring_reset(&nn->rx_rings[r]);
-	for (r = 0; r < nn->num_tx_rings; r++)
-		nfp_net_tx_ring_reset(nn, &nn->tx_rings[r]);
-	for (r = 0; r < nn->num_r_vecs; r++)
+	for (r = 0; r < nn->dp.num_rx_rings; r++)
+		nfp_net_rx_ring_reset(&nn->dp.rx_rings[r]);
+	for (r = 0; r < nn->dp.num_tx_rings; r++)
+		nfp_net_tx_ring_reset(&nn->dp, &nn->dp.tx_rings[r]);
+	for (r = 0; r < nn->dp.num_r_vecs; r++)
 		nfp_net_vec_clear_ring_data(nn, r);
 
-	nn->ctrl = new_ctrl;
+	nn->dp.ctrl = new_ctrl;
 }
 
 static void
@@ -2152,7 +2158,7 @@ static int __nfp_net_set_config_and_enable(struct nfp_net *nn)
 	unsigned int r;
 	int err;
 
-	new_ctrl = nn->ctrl;
+	new_ctrl = nn->dp.ctrl;
 
 	if (nn->cap & NFP_NET_CFG_CTRL_RSS) {
 		nfp_net_rss_write_key(nn);
@@ -2168,22 +2174,22 @@ static int __nfp_net_set_config_and_enable(struct nfp_net *nn)
 		update |= NFP_NET_CFG_UPDATE_IRQMOD;
 	}
 
-	for (r = 0; r < nn->num_tx_rings; r++)
-		nfp_net_tx_ring_hw_cfg_write(nn, &nn->tx_rings[r], r);
-	for (r = 0; r < nn->num_rx_rings; r++)
-		nfp_net_rx_ring_hw_cfg_write(nn, &nn->rx_rings[r], r);
+	for (r = 0; r < nn->dp.num_tx_rings; r++)
+		nfp_net_tx_ring_hw_cfg_write(nn, &nn->dp.tx_rings[r], r);
+	for (r = 0; r < nn->dp.num_rx_rings; r++)
+		nfp_net_rx_ring_hw_cfg_write(nn, &nn->dp.rx_rings[r], r);
 
-	nn_writeq(nn, NFP_NET_CFG_TXRS_ENABLE, nn->num_tx_rings == 64 ?
-		  0xffffffffffffffffULL : ((u64)1 << nn->num_tx_rings) - 1);
+	nn_writeq(nn, NFP_NET_CFG_TXRS_ENABLE, nn->dp.num_tx_rings == 64 ?
+		  0xffffffffffffffffULL : ((u64)1 << nn->dp.num_tx_rings) - 1);
 
-	nn_writeq(nn, NFP_NET_CFG_RXRS_ENABLE, nn->num_rx_rings == 64 ?
-		  0xffffffffffffffffULL : ((u64)1 << nn->num_rx_rings) - 1);
+	nn_writeq(nn, NFP_NET_CFG_RXRS_ENABLE, nn->dp.num_rx_rings == 64 ?
+		  0xffffffffffffffffULL : ((u64)1 << nn->dp.num_rx_rings) - 1);
 
 	nfp_net_write_mac_addr(nn);
 
-	nn_writel(nn, NFP_NET_CFG_MTU, nn->netdev->mtu);
+	nn_writel(nn, NFP_NET_CFG_MTU, nn->dp.netdev->mtu);
 	nn_writel(nn, NFP_NET_CFG_FLBUFSZ,
-		  nn->fl_bufsz - NFP_NET_RX_BUF_NON_DATA);
+		  nn->dp.fl_bufsz - NFP_NET_RX_BUF_NON_DATA);
 
 	/* Enable device */
 	new_ctrl |= NFP_NET_CFG_CTRL_ENABLE;
@@ -2196,18 +2202,18 @@ static int __nfp_net_set_config_and_enable(struct nfp_net *nn)
 	nn_writel(nn, NFP_NET_CFG_CTRL, new_ctrl);
 	err = nfp_net_reconfig(nn, update);
 
-	nn->ctrl = new_ctrl;
+	nn->dp.ctrl = new_ctrl;
 
-	for (r = 0; r < nn->num_rx_rings; r++)
-		nfp_net_rx_ring_fill_freelist(&nn->rx_rings[r]);
+	for (r = 0; r < nn->dp.num_rx_rings; r++)
+		nfp_net_rx_ring_fill_freelist(&nn->dp.rx_rings[r]);
 
 	/* Since reconfiguration requests while NFP is down are ignored we
 	 * have to wipe the entire VXLAN configuration and reinitialize it.
 	 */
-	if (nn->ctrl & NFP_NET_CFG_CTRL_VXLAN) {
+	if (nn->dp.ctrl & NFP_NET_CFG_CTRL_VXLAN) {
 		memset(&nn->vxlan_ports, 0, sizeof(nn->vxlan_ports));
 		memset(&nn->vxlan_usecnt, 0, sizeof(nn->vxlan_usecnt));
-		udp_tunnel_get_rx_info(nn->netdev);
+		udp_tunnel_get_rx_info(nn->dp.netdev);
 	}
 
 	return err;
@@ -2236,12 +2242,12 @@ static void nfp_net_open_stack(struct nfp_net *nn)
 {
 	unsigned int r;
 
-	for (r = 0; r < nn->num_r_vecs; r++) {
+	for (r = 0; r < nn->dp.num_r_vecs; r++) {
 		napi_enable(&nn->r_vecs[r].napi);
 		enable_irq(nn->r_vecs[r].irq_vector);
 	}
 
-	netif_tx_wake_all_queues(nn->netdev);
+	netif_tx_wake_all_queues(nn->dp.netdev);
 
 	enable_irq(nn->irq_entries[NFP_NET_IRQ_LSC_IDX].vector);
 	nfp_net_read_link_status(nn);
@@ -2251,18 +2257,18 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 	struct nfp_net_ring_set rx = {
-		.n_rings = nn->num_rx_rings,
-		.mtu = nn->netdev->mtu,
-		.dcnt = nn->rxd_cnt,
+		.n_rings = nn->dp.num_rx_rings,
+		.mtu = nn->dp.netdev->mtu,
+		.dcnt = nn->dp.rxd_cnt,
 	};
 	struct nfp_net_ring_set tx = {
-		.n_rings = nn->num_tx_rings,
-		.dcnt = nn->txd_cnt,
+		.n_rings = nn->dp.num_tx_rings,
+		.dcnt = nn->dp.txd_cnt,
 	};
 	int err, r;
 
-	if (nn->ctrl & NFP_NET_CFG_CTRL_ENABLE) {
-		nn_err(nn, "Dev is already enabled: 0x%08x\n", nn->ctrl);
+	if (nn->dp.ctrl & NFP_NET_CFG_CTRL_ENABLE) {
+		nn_err(nn, "Dev is already enabled: 0x%08x\n", nn->dp.ctrl);
 		return -EBUSY;
 	}
 
@@ -2283,33 +2289,33 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 		goto err_free_exn;
 	disable_irq(nn->irq_entries[NFP_NET_IRQ_LSC_IDX].vector);
 
-	for (r = 0; r < nn->num_r_vecs; r++) {
+	for (r = 0; r < nn->dp.num_r_vecs; r++) {
 		err = nfp_net_prepare_vector(nn, &nn->r_vecs[r], r);
 		if (err)
 			goto err_cleanup_vec_p;
 	}
 
-	nn->rx_rings = nfp_net_rx_ring_set_prepare(nn, &rx, nn->xdp_prog);
-	if (!nn->rx_rings) {
+	nn->dp.rx_rings = nfp_net_rx_ring_set_prepare(nn, &rx, nn->dp.xdp_prog);
+	if (!nn->dp.rx_rings) {
 		err = -ENOMEM;
 		goto err_cleanup_vec;
 	}
 
-	nn->tx_rings = nfp_net_tx_ring_set_prepare(nn, &tx,
-						   nn->num_stack_tx_rings);
-	if (!nn->tx_rings) {
+	nn->dp.tx_rings = nfp_net_tx_ring_set_prepare(nn, &tx,
+						   nn->dp.num_stack_tx_rings);
+	if (!nn->dp.tx_rings) {
 		err = -ENOMEM;
 		goto err_free_rx_rings;
 	}
 
 	for (r = 0; r < nn->max_r_vecs; r++)
-		nfp_net_vector_assign_rings(nn, &nn->r_vecs[r], r);
+		nfp_net_vector_assign_rings(&nn->dp, &nn->r_vecs[r], r);
 
-	err = netif_set_real_num_tx_queues(netdev, nn->num_stack_tx_rings);
+	err = netif_set_real_num_tx_queues(netdev, nn->dp.num_stack_tx_rings);
 	if (err)
 		goto err_free_rings;
 
-	err = netif_set_real_num_rx_queues(netdev, nn->num_rx_rings);
+	err = netif_set_real_num_rx_queues(netdev, nn->dp.num_rx_rings);
 	if (err)
 		goto err_free_rings;
 
@@ -2335,11 +2341,11 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 	return 0;
 
 err_free_rings:
-	nfp_net_tx_ring_set_free(nn, &tx);
+	nfp_net_tx_ring_set_free(&tx);
 err_free_rx_rings:
-	nfp_net_rx_ring_set_free(nn, &rx, nn->xdp_prog);
+	nfp_net_rx_ring_set_free(&nn->dp, &rx, nn->dp.xdp_prog);
 err_cleanup_vec:
-	r = nn->num_r_vecs;
+	r = nn->dp.num_r_vecs;
 err_cleanup_vec_p:
 	while (r--)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
@@ -2358,15 +2364,15 @@ static void nfp_net_close_stack(struct nfp_net *nn)
 	unsigned int r;
 
 	disable_irq(nn->irq_entries[NFP_NET_IRQ_LSC_IDX].vector);
-	netif_carrier_off(nn->netdev);
+	netif_carrier_off(nn->dp.netdev);
 	nn->link_up = false;
 
-	for (r = 0; r < nn->num_r_vecs; r++) {
+	for (r = 0; r < nn->dp.num_r_vecs; r++) {
 		disable_irq(nn->r_vecs[r].irq_vector);
 		napi_disable(&nn->r_vecs[r].napi);
 	}
 
-	netif_tx_disable(nn->netdev);
+	netif_tx_disable(nn->dp.netdev);
 }
 
 /**
@@ -2377,17 +2383,18 @@ static void nfp_net_close_free_all(struct nfp_net *nn)
 {
 	unsigned int r;
 
-	for (r = 0; r < nn->num_rx_rings; r++) {
-		nfp_net_rx_ring_bufs_free(nn, &nn->rx_rings[r], nn->xdp_prog);
-		nfp_net_rx_ring_free(&nn->rx_rings[r]);
+	for (r = 0; r < nn->dp.num_rx_rings; r++) {
+		nfp_net_rx_ring_bufs_free(&nn->dp, &nn->dp.rx_rings[r],
+					  nn->dp.xdp_prog);
+		nfp_net_rx_ring_free(&nn->dp.rx_rings[r]);
 	}
-	for (r = 0; r < nn->num_tx_rings; r++)
-		nfp_net_tx_ring_free(&nn->tx_rings[r]);
-	for (r = 0; r < nn->num_r_vecs; r++)
+	for (r = 0; r < nn->dp.num_tx_rings; r++)
+		nfp_net_tx_ring_free(&nn->dp.tx_rings[r]);
+	for (r = 0; r < nn->dp.num_r_vecs; r++)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 
-	kfree(nn->rx_rings);
-	kfree(nn->tx_rings);
+	kfree(nn->dp.rx_rings);
+	kfree(nn->dp.tx_rings);
 
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
@@ -2401,8 +2408,8 @@ static int nfp_net_netdev_close(struct net_device *netdev)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 
-	if (!(nn->ctrl & NFP_NET_CFG_CTRL_ENABLE)) {
-		nn_err(nn, "Dev is not up: 0x%08x\n", nn->ctrl);
+	if (!(nn->dp.ctrl & NFP_NET_CFG_CTRL_ENABLE)) {
+		nn_err(nn, "Dev is not up: 0x%08x\n", nn->dp.ctrl);
 		return 0;
 	}
 
@@ -2427,7 +2434,7 @@ static void nfp_net_set_rx_mode(struct net_device *netdev)
 	struct nfp_net *nn = netdev_priv(netdev);
 	u32 new_ctrl;
 
-	new_ctrl = nn->ctrl;
+	new_ctrl = nn->dp.ctrl;
 
 	if (netdev->flags & IFF_PROMISC) {
 		if (nn->cap & NFP_NET_CFG_CTRL_PROMISC)
@@ -2438,13 +2445,13 @@ static void nfp_net_set_rx_mode(struct net_device *netdev)
 		new_ctrl &= ~NFP_NET_CFG_CTRL_PROMISC;
 	}
 
-	if (new_ctrl == nn->ctrl)
+	if (new_ctrl == nn->dp.ctrl)
 		return;
 
 	nn_writel(nn, NFP_NET_CFG_CTRL, new_ctrl);
 	nfp_net_reconfig_post(nn, NFP_NET_CFG_UPDATE_GEN);
 
-	nn->ctrl = new_ctrl;
+	nn->dp.ctrl = new_ctrl;
 }
 
 static void nfp_net_rss_init_itbl(struct nfp_net *nn)
@@ -2453,7 +2460,7 @@ static void nfp_net_rss_init_itbl(struct nfp_net *nn)
 
 	for (i = 0; i < sizeof(nn->rss_itbl); i++)
 		nn->rss_itbl[i] =
-			ethtool_rxfh_indir_default(i, nn->num_rx_rings);
+			ethtool_rxfh_indir_default(i, nn->dp.num_rx_rings);
 }
 
 static int
@@ -2471,24 +2478,23 @@ nfp_net_ring_swap_enable(struct nfp_net *nn, unsigned int *num_vecs,
 	if (tx)
 		nfp_net_tx_ring_set_swap(nn, tx);
 
-	swap(*num_vecs, nn->num_r_vecs);
-	swap(*stack_tx_rings, nn->num_stack_tx_rings);
-	*xdp_prog = xchg(&nn->xdp_prog, *xdp_prog);
+	swap(*num_vecs, nn->dp.num_r_vecs);
+	swap(*stack_tx_rings, nn->dp.num_stack_tx_rings);
+	*xdp_prog = xchg(&nn->dp.xdp_prog, *xdp_prog);
 
 	for (r = 0; r <	nn->max_r_vecs; r++)
-		nfp_net_vector_assign_rings(nn, &nn->r_vecs[r], r);
+		nfp_net_vector_assign_rings(&nn->dp, &nn->r_vecs[r], r);
 
-	if (!netif_is_rxfh_configured(nn->netdev))
+	if (!netif_is_rxfh_configured(nn->dp.netdev))
 		nfp_net_rss_init_itbl(nn);
 
-	err = netif_set_real_num_rx_queues(nn->netdev,
-					   nn->num_rx_rings);
+	err = netif_set_real_num_rx_queues(nn->dp.netdev, nn->dp.num_rx_rings);
 	if (err)
 		return err;
 
-	if (nn->netdev->real_num_tx_queues != nn->num_stack_tx_rings) {
-		err = netif_set_real_num_tx_queues(nn->netdev,
-						   nn->num_stack_tx_rings);
+	if (nn->dp.netdev->real_num_tx_queues != nn->dp.num_stack_tx_rings) {
+		err = netif_set_real_num_tx_queues(nn->dp.netdev,
+						   nn->dp.num_stack_tx_rings);
 		if (err)
 			return err;
 	}
@@ -2503,7 +2509,7 @@ nfp_net_check_config(struct nfp_net *nn, struct bpf_prog *xdp_prog,
 	/* XDP-enabled tests */
 	if (!xdp_prog)
 		return 0;
-	if (rx && nfp_net_calc_fl_bufsz(nn, rx->mtu) > PAGE_SIZE) {
+	if (rx && nfp_net_calc_fl_bufsz(&nn->dp, rx->mtu) > PAGE_SIZE) {
 		nn_warn(nn, "MTU too large w/ XDP enabled\n");
 		return -EINVAL;
 	}
@@ -2521,17 +2527,17 @@ nfp_net_ring_reconfig_down(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 			   struct nfp_net_ring_set *tx,
 			   unsigned int stack_tx_rings, unsigned int num_vecs)
 {
-	nn->netdev->mtu = rx ? rx->mtu : nn->netdev->mtu;
-	nn->fl_bufsz = nfp_net_calc_fl_bufsz(nn, nn->netdev->mtu);
-	nn->rxd_cnt = rx ? rx->dcnt : nn->rxd_cnt;
-	nn->txd_cnt = tx ? tx->dcnt : nn->txd_cnt;
-	nn->num_rx_rings = rx ? rx->n_rings : nn->num_rx_rings;
-	nn->num_tx_rings = tx ? tx->n_rings : nn->num_tx_rings;
-	nn->num_stack_tx_rings = stack_tx_rings;
-	nn->num_r_vecs = num_vecs;
-	*xdp_prog = xchg(&nn->xdp_prog, *xdp_prog);
-
-	if (!netif_is_rxfh_configured(nn->netdev))
+	nn->dp.netdev->mtu = rx ? rx->mtu : nn->dp.netdev->mtu;
+	nn->dp.fl_bufsz = nfp_net_calc_fl_bufsz(&nn->dp, nn->dp.netdev->mtu);
+	nn->dp.rxd_cnt = rx ? rx->dcnt : nn->dp.rxd_cnt;
+	nn->dp.txd_cnt = tx ? tx->dcnt : nn->dp.txd_cnt;
+	nn->dp.num_rx_rings = rx ? rx->n_rings : nn->dp.num_rx_rings;
+	nn->dp.num_tx_rings = tx ? tx->n_rings : nn->dp.num_tx_rings;
+	nn->dp.num_stack_tx_rings = stack_tx_rings;
+	nn->dp.num_r_vecs = num_vecs;
+	*xdp_prog = xchg(&nn->dp.xdp_prog, *xdp_prog);
+
+	if (!netif_is_rxfh_configured(nn->dp.netdev))
 		nfp_net_rss_init_itbl(nn);
 }
 
@@ -2542,24 +2548,24 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 	unsigned int stack_tx_rings, num_vecs, r;
 	int err;
 
-	stack_tx_rings = tx ? tx->n_rings : nn->num_tx_rings;
+	stack_tx_rings = tx ? tx->n_rings : nn->dp.num_tx_rings;
 	if (*xdp_prog)
-		stack_tx_rings -= rx ? rx->n_rings : nn->num_rx_rings;
+		stack_tx_rings -= rx ? rx->n_rings : nn->dp.num_rx_rings;
 
-	num_vecs = max(rx ? rx->n_rings : nn->num_rx_rings, stack_tx_rings);
+	num_vecs = max(rx ? rx->n_rings : nn->dp.num_rx_rings, stack_tx_rings);
 
 	err = nfp_net_check_config(nn, *xdp_prog, rx, tx);
 	if (err)
 		return err;
 
-	if (!netif_running(nn->netdev)) {
+	if (!netif_running(nn->dp.netdev)) {
 		nfp_net_ring_reconfig_down(nn, xdp_prog, rx, tx,
 					   stack_tx_rings, num_vecs);
 		return 0;
 	}
 
 	/* Prepare new rings */
-	for (r = nn->num_r_vecs; r < num_vecs; r++) {
+	for (r = nn->dp.num_r_vecs; r < num_vecs; r++) {
 		err = nfp_net_prepare_vector(nn, &nn->r_vecs[r], r);
 		if (err) {
 			num_vecs = r;
@@ -2597,13 +2603,13 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 			nn_err(nn, "Can't restore ring config - FW communication failed (%d,%d)\n",
 			       err, err2);
 	}
-	for (r = num_vecs - 1; r >= nn->num_r_vecs; r--)
+	for (r = num_vecs - 1; r >= nn->dp.num_r_vecs; r--)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 
 	if (rx)
-		nfp_net_rx_ring_set_free(nn, rx, *xdp_prog);
+		nfp_net_rx_ring_set_free(&nn->dp, rx, *xdp_prog);
 	if (tx)
-		nfp_net_tx_ring_set_free(nn, tx);
+		nfp_net_tx_ring_set_free(tx);
 
 	nfp_net_open_stack(nn);
 
@@ -2611,9 +2617,9 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 
 err_free_rx:
 	if (rx)
-		nfp_net_rx_ring_set_free(nn, rx, *xdp_prog);
+		nfp_net_rx_ring_set_free(&nn->dp, rx, *xdp_prog);
 err_cleanup_vecs:
-	for (r = num_vecs - 1; r >= nn->num_r_vecs; r--)
+	for (r = num_vecs - 1; r >= nn->dp.num_r_vecs; r--)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 	return err;
 }
@@ -2622,12 +2628,12 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 	struct nfp_net_ring_set rx = {
-		.n_rings = nn->num_rx_rings,
+		.n_rings = nn->dp.num_rx_rings,
 		.mtu = new_mtu,
-		.dcnt = nn->rxd_cnt,
+		.dcnt = nn->dp.rxd_cnt,
 	};
 
-	return nfp_net_ring_reconfig(nn, &nn->xdp_prog, &rx, NULL);
+	return nfp_net_ring_reconfig(nn, &nn->dp.xdp_prog, &rx, NULL);
 }
 
 static void nfp_net_stat64(struct net_device *netdev,
@@ -2636,7 +2642,7 @@ static void nfp_net_stat64(struct net_device *netdev,
 	struct nfp_net *nn = netdev_priv(netdev);
 	int r;
 
-	for (r = 0; r < nn->num_r_vecs; r++) {
+	for (r = 0; r < nn->dp.num_r_vecs; r++) {
 		struct nfp_net_r_vector *r_vec = &nn->r_vecs[r];
 		u64 data[3];
 		unsigned int start;
@@ -2683,7 +2689,7 @@ nfp_net_setup_tc(struct net_device *netdev, u32 handle, __be16 proto,
 		return -ENOTSUPP;
 
 	if (tc->type == TC_SETUP_CLSBPF && nfp_net_ebpf_capable(nn)) {
-		if (!nn->bpf_offload_xdp)
+		if (!nn->dp.bpf_offload_xdp)
 			return nfp_net_bpf_offload(nn, tc->cls_bpf);
 		else
 			return -EBUSY;
@@ -2702,7 +2708,7 @@ static int nfp_net_set_features(struct net_device *netdev,
 
 	/* Assume this is not called with features we have not advertised */
 
-	new_ctrl = nn->ctrl;
+	new_ctrl = nn->dp.ctrl;
 
 	if (changed & NETIF_F_RXCSUM) {
 		if (features & NETIF_F_RXCSUM)
@@ -2746,7 +2752,7 @@ static int nfp_net_set_features(struct net_device *netdev,
 			new_ctrl &= ~NFP_NET_CFG_CTRL_GATHER;
 	}
 
-	if (changed & NETIF_F_HW_TC && nn->ctrl & NFP_NET_CFG_CTRL_BPF) {
+	if (changed & NETIF_F_HW_TC && nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF) {
 		nn_err(nn, "Cannot disable HW TC offload while in use\n");
 		return -EBUSY;
 	}
@@ -2754,16 +2760,16 @@ static int nfp_net_set_features(struct net_device *netdev,
 	nn_dbg(nn, "Feature change 0x%llx -> 0x%llx (changed=0x%llx)\n",
 	       netdev->features, features, changed);
 
-	if (new_ctrl == nn->ctrl)
+	if (new_ctrl == nn->dp.ctrl)
 		return 0;
 
-	nn_dbg(nn, "NIC ctrl: 0x%x -> 0x%x\n", nn->ctrl, new_ctrl);
+	nn_dbg(nn, "NIC ctrl: 0x%x -> 0x%x\n", nn->dp.ctrl, new_ctrl);
 	nn_writel(nn, NFP_NET_CFG_CTRL, new_ctrl);
 	err = nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_GEN);
 	if (err)
 		return err;
 
-	nn->ctrl = new_ctrl;
+	nn->dp.ctrl = new_ctrl;
 
 	return 0;
 }
@@ -2846,7 +2852,7 @@ static void nfp_net_set_vxlan_port(struct nfp_net *nn, int idx, __be16 port)
 
 	nn->vxlan_ports[idx] = port;
 
-	if (!(nn->ctrl & NFP_NET_CFG_CTRL_VXLAN))
+	if (!(nn->dp.ctrl & NFP_NET_CFG_CTRL_VXLAN))
 		return;
 
 	BUILD_BUG_ON(NFP_NET_N_VXLAN_PORTS & 1);
@@ -2925,8 +2931,8 @@ static int nfp_net_xdp_offload(struct nfp_net *nn, struct bpf_prog *prog)
 	if (!nfp_net_ebpf_capable(nn))
 		return -EINVAL;
 
-	if (nn->ctrl & NFP_NET_CFG_CTRL_BPF) {
-		if (!nn->bpf_offload_xdp)
+	if (nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF) {
+		if (!nn->dp.bpf_offload_xdp)
 			return prog ? -EBUSY : 0;
 		cmd.command = prog ? TC_CLSBPF_REPLACE : TC_CLSBPF_DESTROY;
 	} else {
@@ -2939,20 +2945,20 @@ static int nfp_net_xdp_offload(struct nfp_net *nn, struct bpf_prog *prog)
 	/* Stop offload if replace not possible */
 	if (ret && cmd.command == TC_CLSBPF_REPLACE)
 		nfp_net_xdp_offload(nn, NULL);
-	nn->bpf_offload_xdp = prog && !ret;
+	nn->dp.bpf_offload_xdp = prog && !ret;
 	return ret;
 }
 
 static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 {
 	struct nfp_net_ring_set rx = {
-		.n_rings = nn->num_rx_rings,
-		.mtu = nn->netdev->mtu,
-		.dcnt = nn->rxd_cnt,
+		.n_rings = nn->dp.num_rx_rings,
+		.mtu = nn->dp.netdev->mtu,
+		.dcnt = nn->dp.rxd_cnt,
 	};
 	struct nfp_net_ring_set tx = {
-		.n_rings = nn->num_tx_rings,
-		.dcnt = nn->txd_cnt,
+		.n_rings = nn->dp.num_tx_rings,
+		.dcnt = nn->dp.txd_cnt,
 	};
 	int err;
 
@@ -2960,16 +2966,16 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 		nn_err(nn, "Does not support bpf_xdp_adjust_head()\n");
 		return -EOPNOTSUPP;
 	}
-	if (!prog && !nn->xdp_prog)
+	if (!prog && !nn->dp.xdp_prog)
 		return 0;
-	if (prog && nn->xdp_prog) {
-		prog = xchg(&nn->xdp_prog, prog);
+	if (prog && nn->dp.xdp_prog) {
+		prog = xchg(&nn->dp.xdp_prog, prog);
 		bpf_prog_put(prog);
-		nfp_net_xdp_offload(nn, nn->xdp_prog);
+		nfp_net_xdp_offload(nn, nn->dp.xdp_prog);
 		return 0;
 	}
 
-	tx.n_rings += prog ? nn->num_rx_rings : -nn->num_rx_rings;
+	tx.n_rings += prog ? nn->dp.num_rx_rings : -nn->dp.num_rx_rings;
 
 	/* We need RX reconfig to remap the buffers (BIDIR vs FROM_DEV) */
 	err = nfp_net_ring_reconfig(nn, &prog, &rx, &tx);
@@ -2980,7 +2986,7 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 	if (prog)
 		bpf_prog_put(prog);
 
-	nfp_net_xdp_offload(nn, nn->xdp_prog);
+	nfp_net_xdp_offload(nn, nn->dp.xdp_prog);
 
 	return 0;
 }
@@ -2993,7 +2999,7 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
 	case XDP_SETUP_PROG:
 		return nfp_net_xdp_setup(nn, xdp->prog);
 	case XDP_QUERY_PROG:
-		xdp->prog_attached = !!nn->xdp_prog;
+		xdp->prog_attached = !!nn->dp.xdp_prog;
 		return 0;
 	default:
 		return -EINVAL;
@@ -3025,9 +3031,9 @@ static const struct net_device_ops nfp_net_netdev_ops = {
 void nfp_net_info(struct nfp_net *nn)
 {
 	nn_info(nn, "Netronome NFP-6xxx %sNetdev: TxQs=%d/%d RxQs=%d/%d\n",
-		nn->is_vf ? "VF " : "",
-		nn->num_tx_rings, nn->max_tx_rings,
-		nn->num_rx_rings, nn->max_rx_rings);
+		nn->dp.is_vf ? "VF " : "",
+		nn->dp.num_tx_rings, nn->max_tx_rings,
+		nn->dp.num_rx_rings, nn->max_rx_rings);
 	nn_info(nn, "VER: %d.%d.%d.%d, Maximum supported MTU: %d\n",
 		nn->fw_ver.resv, nn->fw_ver.class,
 		nn->fw_ver.major, nn->fw_ver.minor,
@@ -3079,22 +3085,24 @@ struct nfp_net *nfp_net_netdev_alloc(struct pci_dev *pdev,
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 	nn = netdev_priv(netdev);
 
-	nn->netdev = netdev;
-	nn->dev = &pdev->dev;
+	nn->dp.netdev = netdev;
+	nn->dp.dev = &pdev->dev;
 	nn->pdev = pdev;
 
 	nn->max_tx_rings = max_tx_rings;
 	nn->max_rx_rings = max_rx_rings;
 
-	nn->num_tx_rings = min_t(unsigned int, max_tx_rings, num_online_cpus());
-	nn->num_rx_rings = min_t(unsigned int, max_rx_rings,
+	nn->dp.num_tx_rings = min_t(unsigned int,
+				    max_tx_rings, num_online_cpus());
+	nn->dp.num_rx_rings = min_t(unsigned int, max_rx_rings,
 				 netif_get_num_default_rss_queues());
 
-	nn->num_r_vecs = max(nn->num_tx_rings, nn->num_rx_rings);
-	nn->num_r_vecs = min_t(unsigned int, nn->num_r_vecs, num_online_cpus());
+	nn->dp.num_r_vecs = max(nn->dp.num_tx_rings, nn->dp.num_rx_rings);
+	nn->dp.num_r_vecs = min_t(unsigned int,
+				  nn->dp.num_r_vecs, num_online_cpus());
 
-	nn->txd_cnt = NFP_NET_TX_DESCS_DEFAULT;
-	nn->rxd_cnt = NFP_NET_RX_DESCS_DEFAULT;
+	nn->dp.txd_cnt = NFP_NET_TX_DESCS_DEFAULT;
+	nn->dp.rxd_cnt = NFP_NET_RX_DESCS_DEFAULT;
 
 	spin_lock_init(&nn->reconfig_lock);
 	spin_lock_init(&nn->rx_filter_lock);
@@ -3114,7 +3122,7 @@ struct nfp_net *nfp_net_netdev_alloc(struct pci_dev *pdev,
  */
 void nfp_net_netdev_free(struct nfp_net *nn)
 {
-	free_netdev(nn->netdev);
+	free_netdev(nn->dp.netdev);
 }
 
 /**
@@ -3156,7 +3164,7 @@ static void nfp_net_rss_init(struct nfp_net *nn)
 
 	func_bit = find_first_bit(&rss_cap_hfunc, NFP_NET_CFG_RSS_HFUNCS);
 	if (func_bit == NFP_NET_CFG_RSS_HFUNCS) {
-		dev_warn(nn->dev,
+		dev_warn(nn->dp.dev,
 			 "Bad RSS config, defaulting to Toeplitz hash\n");
 		func_bit = ETH_RSS_HASH_TOP_BIT;
 	}
@@ -3196,7 +3204,7 @@ int nfp_net_netdev_init(struct net_device *netdev)
 	struct nfp_net *nn = netdev_priv(netdev);
 	int err;
 
-	nn->chained_metadata_format = nn->fw_ver.major > 3;
+	nn->dp.chained_metadata_format = nn->fw_ver.major > 3;
 
 	/* Get some of the read-only fields from the BAR */
 	nn->cap = nn_readl(nn, NFP_NET_CFG_CAP);
@@ -3206,16 +3214,16 @@ int nfp_net_netdev_init(struct net_device *netdev)
 
 	/* Determine RX packet/metadata boundary offset */
 	if (nn->fw_ver.major >= 2)
-		nn->rx_offset = nn_readl(nn, NFP_NET_CFG_RX_OFFSET);
+		nn->dp.rx_offset = nn_readl(nn, NFP_NET_CFG_RX_OFFSET);
 	else
-		nn->rx_offset = NFP_NET_RX_OFFSET;
+		nn->dp.rx_offset = NFP_NET_RX_OFFSET;
 
 	/* Set default MTU and Freelist buffer size */
 	if (nn->max_mtu < NFP_NET_DEFAULT_MTU)
 		netdev->mtu = nn->max_mtu;
 	else
 		netdev->mtu = NFP_NET_DEFAULT_MTU;
-	nn->fl_bufsz = nfp_net_calc_fl_bufsz(nn, netdev->mtu);
+	nn->dp.fl_bufsz = nfp_net_calc_fl_bufsz(&nn->dp, netdev->mtu);
 
 	/* Advertise/enable offloads based on capabilities
 	 *
@@ -3226,31 +3234,31 @@ int nfp_net_netdev_init(struct net_device *netdev)
 	netdev->hw_features = NETIF_F_HIGHDMA;
 	if (nn->cap & NFP_NET_CFG_CTRL_RXCSUM) {
 		netdev->hw_features |= NETIF_F_RXCSUM;
-		nn->ctrl |= NFP_NET_CFG_CTRL_RXCSUM;
+		nn->dp.ctrl |= NFP_NET_CFG_CTRL_RXCSUM;
 	}
 	if (nn->cap & NFP_NET_CFG_CTRL_TXCSUM) {
 		netdev->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
-		nn->ctrl |= NFP_NET_CFG_CTRL_TXCSUM;
+		nn->dp.ctrl |= NFP_NET_CFG_CTRL_TXCSUM;
 	}
 	if (nn->cap & NFP_NET_CFG_CTRL_GATHER) {
 		netdev->hw_features |= NETIF_F_SG;
-		nn->ctrl |= NFP_NET_CFG_CTRL_GATHER;
+		nn->dp.ctrl |= NFP_NET_CFG_CTRL_GATHER;
 	}
 	if ((nn->cap & NFP_NET_CFG_CTRL_LSO) && nn->fw_ver.major > 2) {
 		netdev->hw_features |= NETIF_F_TSO | NETIF_F_TSO6;
-		nn->ctrl |= NFP_NET_CFG_CTRL_LSO;
+		nn->dp.ctrl |= NFP_NET_CFG_CTRL_LSO;
 	}
 	if (nn->cap & NFP_NET_CFG_CTRL_RSS) {
 		netdev->hw_features |= NETIF_F_RXHASH;
 		nfp_net_rss_init(nn);
-		nn->ctrl |= NFP_NET_CFG_CTRL_RSS;
+		nn->dp.ctrl |= NFP_NET_CFG_CTRL_RSS;
 	}
 	if (nn->cap & NFP_NET_CFG_CTRL_VXLAN &&
 	    nn->cap & NFP_NET_CFG_CTRL_NVGRE) {
 		if (nn->cap & NFP_NET_CFG_CTRL_LSO)
 			netdev->hw_features |= NETIF_F_GSO_GRE |
 					       NETIF_F_GSO_UDP_TUNNEL;
-		nn->ctrl |= NFP_NET_CFG_CTRL_VXLAN | NFP_NET_CFG_CTRL_NVGRE;
+		nn->dp.ctrl |= NFP_NET_CFG_CTRL_VXLAN | NFP_NET_CFG_CTRL_NVGRE;
 
 		netdev->hw_enc_features = netdev->hw_features;
 	}
@@ -3259,11 +3267,11 @@ int nfp_net_netdev_init(struct net_device *netdev)
 
 	if (nn->cap & NFP_NET_CFG_CTRL_RXVLAN) {
 		netdev->hw_features |= NETIF_F_HW_VLAN_CTAG_RX;
-		nn->ctrl |= NFP_NET_CFG_CTRL_RXVLAN;
+		nn->dp.ctrl |= NFP_NET_CFG_CTRL_RXVLAN;
 	}
 	if (nn->cap & NFP_NET_CFG_CTRL_TXVLAN) {
 		netdev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX;
-		nn->ctrl |= NFP_NET_CFG_CTRL_TXVLAN;
+		nn->dp.ctrl |= NFP_NET_CFG_CTRL_TXVLAN;
 	}
 
 	netdev->features = netdev->hw_features;
@@ -3276,14 +3284,14 @@ int nfp_net_netdev_init(struct net_device *netdev)
 
 	/* Allow L2 Broadcast and Multicast through by default, if supported */
 	if (nn->cap & NFP_NET_CFG_CTRL_L2BC)
-		nn->ctrl |= NFP_NET_CFG_CTRL_L2BC;
+		nn->dp.ctrl |= NFP_NET_CFG_CTRL_L2BC;
 	if (nn->cap & NFP_NET_CFG_CTRL_L2MC)
-		nn->ctrl |= NFP_NET_CFG_CTRL_L2MC;
+		nn->dp.ctrl |= NFP_NET_CFG_CTRL_L2MC;
 
 	/* Allow IRQ moderation, if supported */
 	if (nn->cap & NFP_NET_CFG_CTRL_IRQMOD) {
 		nfp_net_irqmod_init(nn);
-		nn->ctrl |= NFP_NET_CFG_CTRL_IRQMOD;
+		nn->dp.ctrl |= NFP_NET_CFG_CTRL_IRQMOD;
 	}
 
 	/* Stash the re-configuration queue away.  First odd queue in TX Bar */
@@ -3322,9 +3330,9 @@ void nfp_net_netdev_clean(struct net_device *netdev)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 
-	if (nn->xdp_prog)
-		bpf_prog_put(nn->xdp_prog);
-	if (nn->bpf_offload_xdp)
+	if (nn->dp.xdp_prog)
+		bpf_prog_put(nn->dp.xdp_prog);
+	if (nn->dp.bpf_offload_xdp)
 		nfp_net_xdp_offload(nn, NULL);
-	unregister_netdev(nn->netdev);
+	unregister_netdev(nn->dp.netdev);
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
index edfa59e51fdd..74125584260b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
@@ -54,7 +54,7 @@ static int nfp_net_debugfs_rx_q_read(struct seq_file *file, void *data)
 		goto out;
 	nn = r_vec->nfp_net;
 	rx_ring = r_vec->rx_ring;
-	if (!netif_running(nn->netdev))
+	if (!netif_running(nn->dp.netdev))
 		goto out;
 
 	rxd_cnt = rx_ring->cnt;
@@ -145,7 +145,7 @@ static int nfp_net_debugfs_tx_q_read(struct seq_file *file, void *data)
 	if (!r_vec->nfp_net || !tx_ring)
 		goto out;
 	nn = r_vec->nfp_net;
-	if (!netif_running(nn->netdev))
+	if (!netif_running(nn->dp.netdev))
 		goto out;
 
 	txd_cnt = tx_ring->cnt;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index a1bca2dca0a5..4620c1bba96e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -127,9 +127,9 @@ static const struct _nfp_net_et_stats nfp_net_et_stats[] = {
 };
 
 #define NN_ET_GLOBAL_STATS_LEN ARRAY_SIZE(nfp_net_et_stats)
-#define NN_ET_RVEC_STATS_LEN (nn->num_r_vecs * 3)
+#define NN_ET_RVEC_STATS_LEN (nn->dp.num_r_vecs * 3)
 #define NN_ET_RVEC_GATHER_STATS 7
-#define NN_ET_QUEUE_STATS_LEN ((nn->num_tx_rings + nn->num_rx_rings) * 2)
+#define NN_ET_QUEUE_STATS_LEN ((nn->dp.num_tx_rings + nn->dp.num_rx_rings) * 2)
 #define NN_ET_STATS_LEN (NN_ET_GLOBAL_STATS_LEN + NN_ET_RVEC_GATHER_STATS + \
 			 NN_ET_RVEC_STATS_LEN + NN_ET_QUEUE_STATS_LEN)
 
@@ -180,29 +180,29 @@ static void nfp_net_get_ringparam(struct net_device *netdev,
 
 	ring->rx_max_pending = NFP_NET_MAX_RX_DESCS;
 	ring->tx_max_pending = NFP_NET_MAX_TX_DESCS;
-	ring->rx_pending = nn->rxd_cnt;
-	ring->tx_pending = nn->txd_cnt;
+	ring->rx_pending = nn->dp.rxd_cnt;
+	ring->tx_pending = nn->dp.txd_cnt;
 }
 
 static int nfp_net_set_ring_size(struct nfp_net *nn, u32 rxd_cnt, u32 txd_cnt)
 {
 	struct nfp_net_ring_set *reconfig_rx = NULL, *reconfig_tx = NULL;
 	struct nfp_net_ring_set rx = {
-		.n_rings = nn->num_rx_rings,
-		.mtu = nn->netdev->mtu,
+		.n_rings = nn->dp.num_rx_rings,
+		.mtu = nn->dp.netdev->mtu,
 		.dcnt = rxd_cnt,
 	};
 	struct nfp_net_ring_set tx = {
-		.n_rings = nn->num_tx_rings,
+		.n_rings = nn->dp.num_tx_rings,
 		.dcnt = txd_cnt,
 	};
 
-	if (nn->rxd_cnt != rxd_cnt)
+	if (nn->dp.rxd_cnt != rxd_cnt)
 		reconfig_rx = &rx;
-	if (nn->txd_cnt != txd_cnt)
+	if (nn->dp.txd_cnt != txd_cnt)
 		reconfig_tx = &tx;
 
-	return nfp_net_ring_reconfig(nn, &nn->xdp_prog,
+	return nfp_net_ring_reconfig(nn, &nn->dp.xdp_prog,
 				     reconfig_rx, reconfig_tx);
 }
 
@@ -224,11 +224,11 @@ static int nfp_net_set_ringparam(struct net_device *netdev,
 	    txd_cnt < NFP_NET_MIN_TX_DESCS || txd_cnt > NFP_NET_MAX_TX_DESCS)
 		return -EINVAL;
 
-	if (nn->rxd_cnt == rxd_cnt && nn->txd_cnt == txd_cnt)
+	if (nn->dp.rxd_cnt == rxd_cnt && nn->dp.txd_cnt == txd_cnt)
 		return 0;
 
 	nn_dbg(nn, "Change ring size: RxQ %u->%u, TxQ %u->%u\n",
-	       nn->rxd_cnt, rxd_cnt, nn->txd_cnt, txd_cnt);
+	       nn->dp.rxd_cnt, rxd_cnt, nn->dp.txd_cnt, txd_cnt);
 
 	return nfp_net_set_ring_size(nn, rxd_cnt, txd_cnt);
 }
@@ -246,7 +246,7 @@ static void nfp_net_get_strings(struct net_device *netdev,
 			memcpy(p, nfp_net_et_stats[i].name, ETH_GSTRING_LEN);
 			p += ETH_GSTRING_LEN;
 		}
-		for (i = 0; i < nn->num_r_vecs; i++) {
+		for (i = 0; i < nn->dp.num_r_vecs; i++) {
 			sprintf(p, "rvec_%u_rx_pkts", i);
 			p += ETH_GSTRING_LEN;
 			sprintf(p, "rvec_%u_tx_pkts", i);
@@ -268,13 +268,13 @@ static void nfp_net_get_strings(struct net_device *netdev,
 		p += ETH_GSTRING_LEN;
 		strncpy(p, "tx_lso", ETH_GSTRING_LEN);
 		p += ETH_GSTRING_LEN;
-		for (i = 0; i < nn->num_tx_rings; i++) {
+		for (i = 0; i < nn->dp.num_tx_rings; i++) {
 			sprintf(p, "txq_%u_pkts", i);
 			p += ETH_GSTRING_LEN;
 			sprintf(p, "txq_%u_bytes", i);
 			p += ETH_GSTRING_LEN;
 		}
-		for (i = 0; i < nn->num_rx_rings; i++) {
+		for (i = 0; i < nn->dp.num_rx_rings; i++) {
 			sprintf(p, "rxq_%u_pkts", i);
 			p += ETH_GSTRING_LEN;
 			sprintf(p, "rxq_%u_bytes", i);
@@ -312,7 +312,7 @@ static void nfp_net_get_stats(struct net_device *netdev,
 			break;
 		}
 	}
-	for (j = 0; j < nn->num_r_vecs; j++) {
+	for (j = 0; j < nn->dp.num_r_vecs; j++) {
 		unsigned int start;
 
 		do {
@@ -338,13 +338,13 @@ static void nfp_net_get_stats(struct net_device *netdev,
 	}
 	for (j = 0; j < NN_ET_RVEC_GATHER_STATS; j++)
 		data[i++] = gathered_stats[j];
-	for (j = 0; j < nn->num_tx_rings; j++) {
+	for (j = 0; j < nn->dp.num_tx_rings; j++) {
 		io_p = nn->ctrl_bar + NFP_NET_CFG_TXR_STATS(j);
 		data[i++] = readq(io_p);
 		io_p = nn->ctrl_bar + NFP_NET_CFG_TXR_STATS(j) + 8;
 		data[i++] = readq(io_p);
 	}
-	for (j = 0; j < nn->num_rx_rings; j++) {
+	for (j = 0; j < nn->dp.num_rx_rings; j++) {
 		io_p = nn->ctrl_bar + NFP_NET_CFG_RXR_STATS(j);
 		data[i++] = readq(io_p);
 		io_p = nn->ctrl_bar + NFP_NET_CFG_RXR_STATS(j) + 8;
@@ -411,7 +411,7 @@ static int nfp_net_get_rxnfc(struct net_device *netdev,
 
 	switch (cmd->cmd) {
 	case ETHTOOL_GRXRINGS:
-		cmd->data = nn->num_rx_rings;
+		cmd->data = nn->dp.num_rx_rings;
 		return 0;
 	case ETHTOOL_GRXFH:
 		return nfp_net_get_rss_hash_opts(nn, cmd);
@@ -745,16 +745,16 @@ static void nfp_net_get_channels(struct net_device *netdev,
 	struct nfp_net *nn = netdev_priv(netdev);
 	unsigned int num_tx_rings;
 
-	num_tx_rings = nn->num_tx_rings;
-	if (nn->xdp_prog)
-		num_tx_rings -= nn->num_rx_rings;
+	num_tx_rings = nn->dp.num_tx_rings;
+	if (nn->dp.xdp_prog)
+		num_tx_rings -= nn->dp.num_rx_rings;
 
 	channel->max_rx = min(nn->max_rx_rings, nn->max_r_vecs);
 	channel->max_tx = min(nn->max_tx_rings, nn->max_r_vecs);
 	channel->max_combined = min(channel->max_rx, channel->max_tx);
 	channel->max_other = NFP_NET_NON_Q_VECTORS;
-	channel->combined_count = min(nn->num_rx_rings, num_tx_rings);
-	channel->rx_count = nn->num_rx_rings - channel->combined_count;
+	channel->combined_count = min(nn->dp.num_rx_rings, num_tx_rings);
+	channel->rx_count = nn->dp.num_rx_rings - channel->combined_count;
 	channel->tx_count = num_tx_rings - channel->combined_count;
 	channel->other_count = NFP_NET_NON_Q_VECTORS;
 }
@@ -765,25 +765,25 @@ static int nfp_net_set_num_rings(struct nfp_net *nn, unsigned int total_rx,
 	struct nfp_net_ring_set *reconfig_rx = NULL, *reconfig_tx = NULL;
 	struct nfp_net_ring_set rx = {
 		.n_rings = total_rx,
-		.mtu = nn->netdev->mtu,
-		.dcnt = nn->rxd_cnt,
+		.mtu = nn->dp.netdev->mtu,
+		.dcnt = nn->dp.rxd_cnt,
 	};
 	struct nfp_net_ring_set tx = {
 		.n_rings = total_tx,
-		.dcnt = nn->txd_cnt,
+		.dcnt = nn->dp.txd_cnt,
 	};
 
-	if (nn->num_rx_rings != total_rx)
+	if (nn->dp.num_rx_rings != total_rx)
 		reconfig_rx = &rx;
-	if (nn->num_stack_tx_rings != total_tx ||
-	    (nn->xdp_prog && reconfig_rx))
+	if (nn->dp.num_stack_tx_rings != total_tx ||
+	    (nn->dp.xdp_prog && reconfig_rx))
 		reconfig_tx = &tx;
 
 	/* nfp_net_check_config() will catch tx.n_rings > nn->max_tx_rings */
-	if (nn->xdp_prog)
+	if (nn->dp.xdp_prog)
 		tx.n_rings += total_rx;
 
-	return nfp_net_ring_reconfig(nn, &nn->xdp_prog,
+	return nfp_net_ring_reconfig(nn, &nn->dp.xdp_prog,
 				     reconfig_rx, reconfig_tx);
 }
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 8a9b3f3b95a8..3935d19a273d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -130,7 +130,7 @@ static u8 __iomem *nfp_net_map_area(struct nfp_cpp *cpp,
 }
 
 static void
-nfp_net_get_mac_addr_hwinfo(struct nfp_net *nn, struct nfp_cpp *cpp,
+nfp_net_get_mac_addr_hwinfo(struct nfp_net_dp *dp, struct nfp_cpp *cpp,
 			    unsigned int id)
 {
 	u8 mac_addr[ETH_ALEN];
@@ -141,22 +141,22 @@ nfp_net_get_mac_addr_hwinfo(struct nfp_net *nn, struct nfp_cpp *cpp,
 
 	mac_str = nfp_hwinfo_lookup(cpp, name);
 	if (!mac_str) {
-		dev_warn(nn->dev, "Can't lookup MAC address. Generate\n");
-		eth_hw_addr_random(nn->netdev);
+		dev_warn(dp->dev, "Can't lookup MAC address. Generate\n");
+		eth_hw_addr_random(dp->netdev);
 		return;
 	}
 
 	if (sscanf(mac_str, "%02hhx:%02hhx:%02hhx:%02hhx:%02hhx:%02hhx",
 		   &mac_addr[0], &mac_addr[1], &mac_addr[2],
 		   &mac_addr[3], &mac_addr[4], &mac_addr[5]) != 6) {
-		dev_warn(nn->dev,
+		dev_warn(dp->dev,
 			 "Can't parse MAC address (%s). Generate.\n", mac_str);
-		eth_hw_addr_random(nn->netdev);
+		eth_hw_addr_random(dp->netdev);
 		return;
 	}
 
-	ether_addr_copy(nn->netdev->dev_addr, mac_addr);
-	ether_addr_copy(nn->netdev->perm_addr, mac_addr);
+	ether_addr_copy(dp->netdev->dev_addr, mac_addr);
+	ether_addr_copy(dp->netdev->perm_addr, mac_addr);
 }
 
 /**
@@ -179,12 +179,12 @@ nfp_net_get_mac_addr(struct nfp_net *nn, struct nfp_pf *pf, unsigned int id)
 
 			nn->eth_port = &pf->eth_tbl->ports[i];
 
-			ether_addr_copy(nn->netdev->dev_addr, mac_addr);
-			ether_addr_copy(nn->netdev->perm_addr, mac_addr);
+			ether_addr_copy(nn->dp.netdev->dev_addr, mac_addr);
+			ether_addr_copy(nn->dp.netdev->perm_addr, mac_addr);
 			return;
 		}
 
-	nfp_net_get_mac_addr_hwinfo(nn, pf->cpp, id);
+	nfp_net_get_mac_addr_hwinfo(&nn->dp, pf->cpp, id);
 }
 
 static unsigned int nfp_net_pf_get_num_ports(struct nfp_pf *pf)
@@ -309,7 +309,7 @@ nfp_net_pf_alloc_port_netdev(struct nfp_pf *pf, void __iomem *ctrl_bar,
 	nn->ctrl_bar = ctrl_bar;
 	nn->tx_bar = tx_bar;
 	nn->rx_bar = rx_bar;
-	nn->is_vf = 0;
+	nn->dp.is_vf = 0;
 	nn->stride_rx = stride;
 	nn->stride_tx = stride;
 
@@ -331,7 +331,7 @@ nfp_net_pf_init_port_netdev(struct nfp_pf *pf, struct nfp_net *nn,
 	 */
 	nn->me_freq_mhz = 1200;
 
-	err = nfp_net_netdev_init(nn->netdev);
+	err = nfp_net_netdev_init(nn->dp.netdev);
 	if (err)
 		return err;
 
@@ -400,7 +400,7 @@ nfp_net_pf_spawn_netdevs(struct nfp_pf *pf,
 	/* Get MSI-X vectors */
 	wanted_irqs = 0;
 	list_for_each_entry(nn, &pf->ports, port_list)
-		wanted_irqs += NFP_NET_NON_Q_VECTORS + nn->num_r_vecs;
+		wanted_irqs += NFP_NET_NON_Q_VECTORS + nn->dp.num_r_vecs;
 	pf->irq_entries = kcalloc(wanted_irqs, sizeof(*pf->irq_entries),
 				  GFP_KERNEL);
 	if (!pf->irq_entries) {
@@ -445,7 +445,7 @@ nfp_net_pf_spawn_netdevs(struct nfp_pf *pf,
 err_prev_deinit:
 	list_for_each_entry_continue_reverse(nn, &pf->ports, port_list) {
 		nfp_net_debugfs_dir_clean(&nn->debugfs_dir);
-		nfp_net_netdev_clean(nn->netdev);
+		nfp_net_netdev_clean(nn->dp.netdev);
 	}
 	nfp_net_irqs_disable(pf->pdev);
 err_vec_free:
@@ -571,7 +571,7 @@ void nfp_net_pci_remove(struct nfp_pf *pf)
 	list_for_each_entry(nn, &pf->ports, port_list) {
 		nfp_net_debugfs_dir_clean(&nn->debugfs_dir);
 
-		nfp_net_netdev_clean(nn->netdev);
+		nfp_net_netdev_clean(nn->dp.netdev);
 	}
 
 	nfp_net_pf_free_netdevs(pf);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
index f6ed1aa9d94b..b5b6f69d1e0f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
@@ -58,7 +58,7 @@ void nfp_net_filter_stats_timer(unsigned long data)
 
 	spin_lock_bh(&nn->rx_filter_lock);
 
-	if (nn->ctrl & NFP_NET_CFG_CTRL_BPF)
+	if (nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF)
 		mod_timer(&nn->rx_filter_stats_timer,
 			  jiffies + NFP_NET_STAT_POLL_IVL);
 
@@ -132,7 +132,7 @@ nfp_net_bpf_get_act(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
 			return NN_ACT_TC_DROP;
 
 		if (is_tcf_mirred_egress_redirect(a) &&
-		    tcf_mirred_ifindex(a) == nn->netdev->ifindex)
+		    tcf_mirred_ifindex(a) == nn->dp.netdev->ifindex)
 			return NN_ACT_TC_REDIR;
 	}
 
@@ -160,7 +160,7 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 	act = ret;
 
 	max_mtu = nn_readb(nn, NFP_NET_CFG_BPF_INL_MTU) * 64 - 32;
-	if (max_mtu < nn->netdev->mtu) {
+	if (max_mtu < nn->dp.netdev->mtu) {
 		nn_info(nn, "BPF offload not supported with MTU larger than HW packet split boundary\n");
 		return -ENOTSUPP;
 	}
@@ -168,7 +168,7 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 	start_off = nn_readw(nn, NFP_NET_CFG_BPF_START);
 	done_off = nn_readw(nn, NFP_NET_CFG_BPF_DONE);
 
-	*code = dma_zalloc_coherent(nn->dev, code_sz, dma_addr, GFP_KERNEL);
+	*code = dma_zalloc_coherent(nn->dp.dev, code_sz, dma_addr, GFP_KERNEL);
 	if (!*code)
 		return -ENOMEM;
 
@@ -180,7 +180,7 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 	return 0;
 
 out:
-	dma_free_coherent(nn->dev, code_sz, *code, *dma_addr);
+	dma_free_coherent(nn->dp.dev, code_sz, *code, *dma_addr);
 	return ret;
 }
 
@@ -193,7 +193,7 @@ nfp_net_bpf_load_and_start(struct nfp_net *nn, u32 tc_flags,
 	u64 bpf_addr = dma_addr;
 	int err;
 
-	nn->bpf_offload_skip_sw = !!(tc_flags & TCA_CLS_FLAGS_SKIP_SW);
+	nn->dp.bpf_offload_skip_sw = !!(tc_flags & TCA_CLS_FLAGS_SKIP_SW);
 
 	if (dense_mode)
 		bpf_addr |= NFP_NET_CFG_BPF_CFG_8CTX;
@@ -207,13 +207,13 @@ nfp_net_bpf_load_and_start(struct nfp_net *nn, u32 tc_flags,
 		nn_err(nn, "FW command error while loading BPF: %d\n", err);
 
 	/* Enable passing packets through BPF function */
-	nn->ctrl |= NFP_NET_CFG_CTRL_BPF;
-	nn_writel(nn, NFP_NET_CFG_CTRL, nn->ctrl);
+	nn->dp.ctrl |= NFP_NET_CFG_CTRL_BPF;
+	nn_writel(nn, NFP_NET_CFG_CTRL, nn->dp.ctrl);
 	err = nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_GEN);
 	if (err)
 		nn_err(nn, "FW command error while enabling BPF: %d\n", err);
 
-	dma_free_coherent(nn->dev, code_sz, code, dma_addr);
+	dma_free_coherent(nn->dp.dev, code_sz, code, dma_addr);
 
 	nfp_net_bpf_stats_reset(nn);
 	mod_timer(&nn->rx_filter_stats_timer, jiffies + NFP_NET_STAT_POLL_IVL);
@@ -221,16 +221,16 @@ nfp_net_bpf_load_and_start(struct nfp_net *nn, u32 tc_flags,
 
 static int nfp_net_bpf_stop(struct nfp_net *nn)
 {
-	if (!(nn->ctrl & NFP_NET_CFG_CTRL_BPF))
+	if (!(nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF))
 		return 0;
 
 	spin_lock_bh(&nn->rx_filter_lock);
-	nn->ctrl &= ~NFP_NET_CFG_CTRL_BPF;
+	nn->dp.ctrl &= ~NFP_NET_CFG_CTRL_BPF;
 	spin_unlock_bh(&nn->rx_filter_lock);
-	nn_writel(nn, NFP_NET_CFG_CTRL, nn->ctrl);
+	nn_writel(nn, NFP_NET_CFG_CTRL, nn->dp.ctrl);
 
 	del_timer_sync(&nn->rx_filter_stats_timer);
-	nn->bpf_offload_skip_sw = 0;
+	nn->dp.bpf_offload_skip_sw = 0;
 
 	return nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_GEN);
 }
@@ -254,7 +254,7 @@ int nfp_net_bpf_offload(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
 		 * frames which didn't have BPF applied in the hardware should
 		 * be fine if software fallback is available, though.
 		 */
-		if (nn->bpf_offload_skip_sw)
+		if (nn->dp.bpf_offload_skip_sw)
 			return -EBUSY;
 
 		err = nfp_net_bpf_offload_prepare(nn, cls_bpf, &res, &code,
@@ -269,7 +269,7 @@ int nfp_net_bpf_offload(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
 		return 0;
 
 	case TC_CLSBPF_ADD:
-		if (nn->ctrl & NFP_NET_CFG_CTRL_BPF)
+		if (nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF)
 			return -EBUSY;
 
 		err = nfp_net_bpf_offload_prepare(nn, cls_bpf, &res, &code,
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
index 39407f7cc586..bc0bdbc1c8fd 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
@@ -84,12 +84,12 @@ static void nfp_netvf_get_mac_addr(struct nfp_net *nn)
 	put_unaligned_be16(nn_readw(nn, NFP_NET_CFG_MACADDR + 6), &mac_addr[4]);
 
 	if (!is_valid_ether_addr(mac_addr)) {
-		eth_hw_addr_random(nn->netdev);
+		eth_hw_addr_random(nn->dp.netdev);
 		return;
 	}
 
-	ether_addr_copy(nn->netdev->dev_addr, mac_addr);
-	ether_addr_copy(nn->netdev->perm_addr, mac_addr);
+	ether_addr_copy(nn->dp.netdev->dev_addr, mac_addr);
+	ether_addr_copy(nn->dp.netdev->perm_addr, mac_addr);
 }
 
 static int nfp_netvf_pci_probe(struct pci_dev *pdev,
@@ -211,7 +211,7 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 
 	nn->fw_ver = fw_ver;
 	nn->ctrl_bar = ctrl_bar;
-	nn->is_vf = 1;
+	nn->dp.is_vf = 1;
 	nn->stride_tx = stride;
 	nn->stride_rx = stride;
 
@@ -268,7 +268,8 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 
 	num_irqs = nfp_net_irqs_alloc(pdev, vf->irq_entries,
 				      NFP_NET_MIN_PORT_IRQS,
-				      NFP_NET_NON_Q_VECTORS + nn->num_r_vecs);
+				      NFP_NET_NON_Q_VECTORS +
+				      nn->dp.num_r_vecs);
 	if (!num_irqs) {
 		nn_warn(nn, "Unable to allocate MSI-X Vectors. Exiting\n");
 		err = -EIO;
@@ -282,7 +283,7 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 	 */
 	nn->me_freq_mhz = 1200;
 
-	err = nfp_net_netdev_init(nn->netdev);
+	err = nfp_net_netdev_init(nn->dp.netdev);
 	if (err)
 		goto err_irqs_disable;
 
@@ -327,7 +328,7 @@ static void nfp_netvf_pci_remove(struct pci_dev *pdev)
 	nfp_net_debugfs_dir_clean(&nn->debugfs_dir);
 	nfp_net_debugfs_dir_clean(&vf->ddir);
 
-	nfp_net_netdev_clean(nn->netdev);
+	nfp_net_netdev_clean(nn->dp.netdev);
 
 	nfp_net_irqs_disable(pdev);
 
-- 
2.11.0
