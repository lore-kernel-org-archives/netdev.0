From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 6/9] nfp: store device pointer for the fastpath
Date: Wed,  8 Mar 2017 08:57:05 -0800
Message-ID: <20170308165708.96087-7-jakub.kicinski@netronome.com>
References: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:36041 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753658AbdCHQ7E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:59:04 -0500
Received: by mail-pg0-f54.google.com with SMTP id 187so15171116pgb.3
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:58:14 -0800 (PST)
In-Reply-To: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We really only need the device pointer on the fast path, stash it at
the beginning of the adapter structure and move pci_dev pointer down.
This saves up a few lines of code.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  6 ++-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 51 ++++++++++------------
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |  5 +--
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   |  7 ++-
 4 files changed, 31 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 50413eea9540..4ad27570b6c4 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -435,7 +435,7 @@ struct nfp_stat_pair {
 
 /**
  * struct nfp_net - NFP network device structure
- * @pdev:               Backpointer to PCI device
+ * @dev:		Backpointer to struct device
  * @netdev:             Backpointer to net_device structure
  * @is_vf:              Is the driver attached to a VF?
  * @bpf_offload_skip_sw:  Offloaded BPF program will not be rerun by cls_bpf
@@ -496,11 +496,12 @@ struct nfp_stat_pair {
  * @debugfs_dir:	Device directory in debugfs
  * @ethtool_dump_flag:	Ethtool dump flag
  * @port_list:		Entry on device port list
+ * @pdev:		Backpointer to PCI device
  * @cpp:		CPP device handle if available
  * @eth_port:		Translated ETH Table port entry
  */
 struct nfp_net {
-	struct pci_dev *pdev;
+	struct device *dev;
 	struct net_device *netdev;
 
 	unsigned is_vf:1;
@@ -588,6 +589,7 @@ struct nfp_net {
 
 	struct list_head port_list;
 
+	struct pci_dev *pdev;
 	struct nfp_cpp *cpp;
 
 	struct nfp_eth_table_port *eth_port;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 8b5fa6fe8807..397d9e82ed0e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -89,7 +89,7 @@ static dma_addr_t
 nfp_net_dma_map_rx(struct nfp_net *nn, void *frag, unsigned int bufsz,
 		   int direction)
 {
-	return dma_map_single(&nn->pdev->dev, frag + NFP_NET_RX_BUF_HEADROOM,
+	return dma_map_single(nn->dev, frag + NFP_NET_RX_BUF_HEADROOM,
 			      bufsz - NFP_NET_RX_BUF_NON_DATA, direction);
 }
 
@@ -97,7 +97,7 @@ static void
 nfp_net_dma_unmap_rx(struct nfp_net *nn, dma_addr_t dma_addr,
 		     unsigned int bufsz, int direction)
 {
-	dma_unmap_single(&nn->pdev->dev, dma_addr,
+	dma_unmap_single(nn->dev, dma_addr,
 			 bufsz - NFP_NET_RX_BUF_NON_DATA, direction);
 }
 
@@ -768,9 +768,9 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	/* Start with the head skbuf */
-	dma_addr = dma_map_single(&nn->pdev->dev, skb->data, skb_headlen(skb),
+	dma_addr = dma_map_single(nn->dev, skb->data, skb_headlen(skb),
 				  DMA_TO_DEVICE);
-	if (dma_mapping_error(&nn->pdev->dev, dma_addr))
+	if (dma_mapping_error(nn->dev, dma_addr))
 		goto err_free;
 
 	wr_idx = tx_ring->wr_p & (tx_ring->cnt - 1);
@@ -812,9 +812,9 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 			frag = &skb_shinfo(skb)->frags[f];
 			fsize = skb_frag_size(frag);
 
-			dma_addr = skb_frag_dma_map(&nn->pdev->dev, frag, 0,
+			dma_addr = skb_frag_dma_map(nn->dev, frag, 0,
 						    fsize, DMA_TO_DEVICE);
-			if (dma_mapping_error(&nn->pdev->dev, dma_addr))
+			if (dma_mapping_error(nn->dev, dma_addr))
 				goto err_unmap;
 
 			wr_idx = (wr_idx + 1) & (tx_ring->cnt - 1);
@@ -853,8 +853,7 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 	--f;
 	while (f >= 0) {
 		frag = &skb_shinfo(skb)->frags[f];
-		dma_unmap_page(&nn->pdev->dev,
-			       tx_ring->txbufs[wr_idx].dma_addr,
+		dma_unmap_page(nn->dev, tx_ring->txbufs[wr_idx].dma_addr,
 			       skb_frag_size(frag), DMA_TO_DEVICE);
 		tx_ring->txbufs[wr_idx].skb = NULL;
 		tx_ring->txbufs[wr_idx].dma_addr = 0;
@@ -863,7 +862,7 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 		if (wr_idx < 0)
 			wr_idx += tx_ring->cnt;
 	}
-	dma_unmap_single(&nn->pdev->dev, tx_ring->txbufs[wr_idx].dma_addr,
+	dma_unmap_single(nn->dev, tx_ring->txbufs[wr_idx].dma_addr,
 			 skb_headlen(skb), DMA_TO_DEVICE);
 	tx_ring->txbufs[wr_idx].skb = NULL;
 	tx_ring->txbufs[wr_idx].dma_addr = 0;
@@ -920,8 +919,7 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 
 		if (fidx == -1) {
 			/* unmap head */
-			dma_unmap_single(&nn->pdev->dev,
-					 tx_ring->txbufs[idx].dma_addr,
+			dma_unmap_single(nn->dev, tx_ring->txbufs[idx].dma_addr,
 					 skb_headlen(skb), DMA_TO_DEVICE);
 
 			done_pkts += tx_ring->txbufs[idx].pkt_cnt;
@@ -929,8 +927,7 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 		} else {
 			/* unmap fragment */
 			frag = &skb_shinfo(skb)->frags[fidx];
-			dma_unmap_page(&nn->pdev->dev,
-				       tx_ring->txbufs[idx].dma_addr,
+			dma_unmap_page(nn->dev, tx_ring->txbufs[idx].dma_addr,
 				       skb_frag_size(frag), DMA_TO_DEVICE);
 		}
 
@@ -1027,7 +1024,6 @@ nfp_net_tx_ring_reset(struct nfp_net *nn, struct nfp_net_tx_ring *tx_ring)
 {
 	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
 	const struct skb_frag_struct *frag;
-	struct pci_dev *pdev = nn->pdev;
 	struct netdev_queue *nd_q;
 
 	while (tx_ring->rd_p != tx_ring->wr_p) {
@@ -1047,13 +1043,13 @@ nfp_net_tx_ring_reset(struct nfp_net *nn, struct nfp_net_tx_ring *tx_ring)
 
 			if (tx_buf->fidx == -1) {
 				/* unmap head */
-				dma_unmap_single(&pdev->dev, tx_buf->dma_addr,
+				dma_unmap_single(nn->dev, tx_buf->dma_addr,
 						 skb_headlen(skb),
 						 DMA_TO_DEVICE);
 			} else {
 				/* unmap fragment */
 				frag = &skb_shinfo(skb)->frags[tx_buf->fidx];
-				dma_unmap_page(&pdev->dev, tx_buf->dma_addr,
+				dma_unmap_page(nn->dev, tx_buf->dma_addr,
 					       skb_frag_size(frag),
 					       DMA_TO_DEVICE);
 			}
@@ -1157,7 +1153,7 @@ nfp_net_rx_alloc_one(struct nfp_net_rx_ring *rx_ring, dma_addr_t *dma_addr,
 	direction = xdp ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
 
 	*dma_addr = nfp_net_dma_map_rx(nn, frag, fl_bufsz, direction);
-	if (dma_mapping_error(&nn->pdev->dev, *dma_addr)) {
+	if (dma_mapping_error(nn->dev, *dma_addr)) {
 		nfp_net_free_frag(frag, xdp);
 		nn_warn_ratelimit(nn, "Failed to map DMA RX buffer\n");
 		return NULL;
@@ -1181,7 +1177,7 @@ nfp_net_napi_alloc_one(struct nfp_net *nn, int direction, dma_addr_t *dma_addr)
 	}
 
 	*dma_addr = nfp_net_dma_map_rx(nn, frag, nn->fl_bufsz, direction);
-	if (dma_mapping_error(&nn->pdev->dev, *dma_addr)) {
+	if (dma_mapping_error(nn->dev, *dma_addr)) {
 		nfp_net_free_frag(frag, nn->xdp_prog);
 		nn_warn_ratelimit(nn, "Failed to map DMA RX buffer\n");
 		return NULL;
@@ -1499,7 +1495,7 @@ nfp_net_tx_xdp_buf(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
 	txbuf->pkt_cnt = 1;
 	txbuf->real_len = pkt_len;
 
-	dma_sync_single_for_device(&nn->pdev->dev, rxbuf->dma_addr + pkt_off,
+	dma_sync_single_for_device(nn->dev, rxbuf->dma_addr + pkt_off,
 				   pkt_len, DMA_BIDIRECTIONAL);
 
 	/* Build TX descriptor */
@@ -1611,7 +1607,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 				  nn->bpf_offload_xdp)) {
 			int act;
 
-			dma_sync_single_for_cpu(&nn->pdev->dev,
+			dma_sync_single_for_cpu(nn->dev,
 						rxbuf->dma_addr + pkt_off,
 						pkt_len, DMA_BIDIRECTIONAL);
 			act = nfp_net_run_xdp(xdp_prog, rxbuf->frag + data_off,
@@ -1728,12 +1724,11 @@ static void nfp_net_tx_ring_free(struct nfp_net_tx_ring *tx_ring)
 {
 	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
 	struct nfp_net *nn = r_vec->nfp_net;
-	struct pci_dev *pdev = nn->pdev;
 
 	kfree(tx_ring->txbufs);
 
 	if (tx_ring->txds)
-		dma_free_coherent(&pdev->dev, tx_ring->size,
+		dma_free_coherent(nn->dev, tx_ring->size,
 				  tx_ring->txds, tx_ring->dma);
 
 	tx_ring->cnt = 0;
@@ -1756,13 +1751,12 @@ nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt, bool is_xdp)
 {
 	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
 	struct nfp_net *nn = r_vec->nfp_net;
-	struct pci_dev *pdev = nn->pdev;
 	int sz;
 
 	tx_ring->cnt = cnt;
 
 	tx_ring->size = sizeof(*tx_ring->txds) * tx_ring->cnt;
-	tx_ring->txds = dma_zalloc_coherent(&pdev->dev, tx_ring->size,
+	tx_ring->txds = dma_zalloc_coherent(nn->dev, tx_ring->size,
 					    &tx_ring->dma, GFP_KERNEL);
 	if (!tx_ring->txds)
 		goto err_alloc;
@@ -1849,12 +1843,11 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 {
 	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
 	struct nfp_net *nn = r_vec->nfp_net;
-	struct pci_dev *pdev = nn->pdev;
 
 	kfree(rx_ring->rxbufs);
 
 	if (rx_ring->rxds)
-		dma_free_coherent(&pdev->dev, rx_ring->size,
+		dma_free_coherent(nn->dev, rx_ring->size,
 				  rx_ring->rxds, rx_ring->dma);
 
 	rx_ring->cnt = 0;
@@ -1878,14 +1871,13 @@ nfp_net_rx_ring_alloc(struct nfp_net_rx_ring *rx_ring, unsigned int fl_bufsz,
 {
 	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
 	struct nfp_net *nn = r_vec->nfp_net;
-	struct pci_dev *pdev = nn->pdev;
 	int sz;
 
 	rx_ring->cnt = cnt;
 	rx_ring->bufsz = fl_bufsz;
 
 	rx_ring->size = sizeof(*rx_ring->rxds) * rx_ring->cnt;
-	rx_ring->rxds = dma_zalloc_coherent(&pdev->dev, rx_ring->size,
+	rx_ring->rxds = dma_zalloc_coherent(nn->dev, rx_ring->size,
 					    &rx_ring->dma, GFP_KERNEL);
 	if (!rx_ring->rxds)
 		goto err_alloc;
@@ -3089,6 +3081,7 @@ struct nfp_net *nfp_net_netdev_alloc(struct pci_dev *pdev,
 	nn = netdev_priv(netdev);
 
 	nn->netdev = netdev;
+	nn->dev = &pdev->dev;
 	nn->pdev = pdev;
 
 	nn->max_tx_rings = max_tx_rings;
@@ -3164,7 +3157,7 @@ static void nfp_net_rss_init(struct nfp_net *nn)
 
 	func_bit = find_first_bit(&rss_cap_hfunc, NFP_NET_CFG_RSS_HFUNCS);
 	if (func_bit == NFP_NET_CFG_RSS_HFUNCS) {
-		dev_warn(&nn->pdev->dev,
+		dev_warn(nn->dev,
 			 "Bad RSS config, defaulting to Toeplitz hash\n");
 		func_bit = ETH_RSS_HASH_TOP_BIT;
 	}
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index f04d0b8e84ad..8a9b3f3b95a8 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -141,8 +141,7 @@ nfp_net_get_mac_addr_hwinfo(struct nfp_net *nn, struct nfp_cpp *cpp,
 
 	mac_str = nfp_hwinfo_lookup(cpp, name);
 	if (!mac_str) {
-		dev_warn(&nn->pdev->dev,
-			 "Can't lookup MAC address. Generate\n");
+		dev_warn(nn->dev, "Can't lookup MAC address. Generate\n");
 		eth_hw_addr_random(nn->netdev);
 		return;
 	}
@@ -150,7 +149,7 @@ nfp_net_get_mac_addr_hwinfo(struct nfp_net *nn, struct nfp_cpp *cpp,
 	if (sscanf(mac_str, "%02hhx:%02hhx:%02hhx:%02hhx:%02hhx:%02hhx",
 		   &mac_addr[0], &mac_addr[1], &mac_addr[2],
 		   &mac_addr[3], &mac_addr[4], &mac_addr[5]) != 6) {
-		dev_warn(&nn->pdev->dev,
+		dev_warn(nn->dev,
 			 "Can't parse MAC address (%s). Generate.\n", mac_str);
 		eth_hw_addr_random(nn->netdev);
 		return;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
index 18a851eb3508..f6ed1aa9d94b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
@@ -168,8 +168,7 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 	start_off = nn_readw(nn, NFP_NET_CFG_BPF_START);
 	done_off = nn_readw(nn, NFP_NET_CFG_BPF_DONE);
 
-	*code = dma_zalloc_coherent(&nn->pdev->dev, code_sz, dma_addr,
-				    GFP_KERNEL);
+	*code = dma_zalloc_coherent(nn->dev, code_sz, dma_addr, GFP_KERNEL);
 	if (!*code)
 		return -ENOMEM;
 
@@ -181,7 +180,7 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 	return 0;
 
 out:
-	dma_free_coherent(&nn->pdev->dev, code_sz, *code, *dma_addr);
+	dma_free_coherent(nn->dev, code_sz, *code, *dma_addr);
 	return ret;
 }
 
@@ -214,7 +213,7 @@ nfp_net_bpf_load_and_start(struct nfp_net *nn, u32 tc_flags,
 	if (err)
 		nn_err(nn, "FW command error while enabling BPF: %d\n", err);
 
-	dma_free_coherent(&nn->pdev->dev, code_sz, code, dma_addr);
+	dma_free_coherent(nn->dev, code_sz, code, dma_addr);
 
 	nfp_net_bpf_stats_reset(nn);
 	mod_timer(&nn->rx_filter_stats_timer, jiffies + NFP_NET_STAT_POLL_IVL);
-- 
2.11.0
