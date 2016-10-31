From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 14/14] nfp: bring back support for different ring counts
Date: Mon, 31 Oct 2016 20:43:22 +0000
Message-ID: <1477946602-19644-15-git-send-email-jakub.kicinski@netronome.com>
References: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38438 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033727AbcJaUoL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:44:11 -0400
Received: by mail-wm0-f41.google.com with SMTP id n67so251682744wme.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 13:44:11 -0700 (PDT)
In-Reply-To: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We used to always allocate the same number of TX and RX rings
so the support for having r_vectors without one of the rings
was dropped.  That makes us, however, unnecessarily limited
to 8 TX rings (8 is the Linux RSS default) most of the time.
Also we are about to add channel count configuration via
ethtool, so bring that support back.  TX rings can now default
to num_online_cpus() and RX rings to netif_get_num_default_rss_queues().

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 118 +++++++++++++--------
 1 file changed, 71 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 4b866fc874b6..97e0bbef13d1 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -483,13 +483,13 @@ static void nfp_net_irqs_assign(struct net_device *netdev)
 	struct nfp_net_r_vector *r_vec;
 	int r;
 
-	/* Assumes nn->num_tx_rings == nn->num_rx_rings */
-	if (nn->num_tx_rings > nn->num_r_vecs) {
-		nn_warn(nn, "More rings (%d) than vectors (%d).\n",
-			nn->num_tx_rings, nn->num_r_vecs);
-		nn->num_tx_rings = nn->num_r_vecs;
-		nn->num_rx_rings = nn->num_r_vecs;
-	}
+	if (nn->num_rx_rings > nn->num_r_vecs ||
+	    nn->num_tx_rings > nn->num_r_vecs)
+		nn_warn(nn, "More rings (%d,%d) than vectors (%d).\n",
+			nn->num_rx_rings, nn->num_tx_rings, nn->num_r_vecs);
+
+	nn->num_rx_rings = min(nn->num_r_vecs, nn->num_rx_rings);
+	nn->num_tx_rings = min(nn->num_r_vecs, nn->num_tx_rings);
 
 	nn->lsc_handler = nfp_net_irq_lsc;
 	nn->exn_handler = nfp_net_irq_exn;
@@ -1491,11 +1491,12 @@ static int nfp_net_poll(struct napi_struct *napi, int budget)
 {
 	struct nfp_net_r_vector *r_vec =
 		container_of(napi, struct nfp_net_r_vector, napi);
-	unsigned int pkts_polled;
-
-	nfp_net_tx_complete(r_vec->tx_ring);
+	unsigned int pkts_polled = 0;
 
-	pkts_polled = nfp_net_rx(r_vec->rx_ring, budget);
+	if (r_vec->tx_ring)
+		nfp_net_tx_complete(r_vec->tx_ring);
+	if (r_vec->rx_ring)
+		pkts_polled = nfp_net_rx(r_vec->rx_ring, budget);
 
 	if (pkts_polled < budget) {
 		napi_complete_done(napi, pkts_polled);
@@ -1743,7 +1744,7 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 	if (!rings)
 		return;
 
-	for (r = 0; r < nn->num_r_vecs; r++) {
+	for (r = 0; r < nn->num_rx_rings; r++) {
 		nfp_net_rx_ring_bufs_free(nn, &rings[r]);
 		nfp_net_rx_ring_free(&rings[r]);
 	}
@@ -1758,11 +1759,19 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 	struct msix_entry *entry = &nn->irq_entries[r_vec->irq_idx];
 	int err;
 
-	r_vec->tx_ring = &nn->tx_rings[idx];
-	nfp_net_tx_ring_init(r_vec->tx_ring, r_vec, idx);
+	if (idx < nn->num_tx_rings) {
+		r_vec->tx_ring = &nn->tx_rings[idx];
+		nfp_net_tx_ring_init(r_vec->tx_ring, r_vec, idx);
+	} else {
+		r_vec->tx_ring = NULL;
+	}
 
-	r_vec->rx_ring = &nn->rx_rings[idx];
-	nfp_net_rx_ring_init(r_vec->rx_ring, r_vec, idx);
+	if (idx < nn->num_rx_rings) {
+		r_vec->rx_ring = &nn->rx_rings[idx];
+		nfp_net_rx_ring_init(r_vec->rx_ring, r_vec, idx);
+	} else {
+		r_vec->rx_ring = NULL;
+	}
 
 	snprintf(r_vec->name, sizeof(r_vec->name),
 		 "%s-rxtx-%d", nn->netdev->name, idx);
@@ -1839,13 +1848,13 @@ void nfp_net_coalesce_write_cfg(struct nfp_net *nn)
 	/* copy RX interrupt coalesce parameters */
 	value = (nn->rx_coalesce_max_frames << 16) |
 		(factor * nn->rx_coalesce_usecs);
-	for (i = 0; i < nn->num_r_vecs; i++)
+	for (i = 0; i < nn->num_rx_rings; i++)
 		nn_writel(nn, NFP_NET_CFG_RXR_IRQ_MOD(i), value);
 
 	/* copy TX interrupt coalesce parameters */
 	value = (nn->tx_coalesce_max_frames << 16) |
 		(factor * nn->tx_coalesce_usecs);
-	for (i = 0; i < nn->num_r_vecs; i++)
+	for (i = 0; i < nn->num_tx_rings; i++)
 		nn_writel(nn, NFP_NET_CFG_TXR_IRQ_MOD(i), value);
 }
 
@@ -1903,27 +1912,33 @@ static void nfp_net_clear_config_and_disable(struct nfp_net *nn)
 	if (err)
 		nn_err(nn, "Could not disable device: %d\n", err);
 
-	for (r = 0; r < nn->num_r_vecs; r++) {
+	for (r = 0; r < nn->num_rx_rings; r++)
 		nfp_net_rx_ring_reset(nn->r_vecs[r].rx_ring);
+	for (r = 0; r < nn->num_tx_rings; r++)
 		nfp_net_tx_ring_reset(nn, nn->r_vecs[r].tx_ring);
+	for (r = 0; r < nn->num_r_vecs; r++)
 		nfp_net_vec_clear_ring_data(nn, r);
-	}
 
 	nn->ctrl = new_ctrl;
 }
 
 static void
-nfp_net_vec_write_ring_data(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
-			    unsigned int idx)
+nfp_net_rx_ring_hw_cfg_write(struct nfp_net *nn,
+			     struct nfp_net_rx_ring *rx_ring, unsigned int idx)
 {
 	/* Write the DMA address, size and MSI-X info to the device */
-	nn_writeq(nn, NFP_NET_CFG_RXR_ADDR(idx), r_vec->rx_ring->dma);
-	nn_writeb(nn, NFP_NET_CFG_RXR_SZ(idx), ilog2(r_vec->rx_ring->cnt));
-	nn_writeb(nn, NFP_NET_CFG_RXR_VEC(idx), r_vec->irq_idx);
+	nn_writeq(nn, NFP_NET_CFG_RXR_ADDR(idx), rx_ring->dma);
+	nn_writeb(nn, NFP_NET_CFG_RXR_SZ(idx), ilog2(rx_ring->cnt));
+	nn_writeb(nn, NFP_NET_CFG_RXR_VEC(idx), rx_ring->r_vec->irq_idx);
+}
 
-	nn_writeq(nn, NFP_NET_CFG_TXR_ADDR(idx), r_vec->tx_ring->dma);
-	nn_writeb(nn, NFP_NET_CFG_TXR_SZ(idx), ilog2(r_vec->tx_ring->cnt));
-	nn_writeb(nn, NFP_NET_CFG_TXR_VEC(idx), r_vec->irq_idx);
+static void
+nfp_net_tx_ring_hw_cfg_write(struct nfp_net *nn,
+			     struct nfp_net_tx_ring *tx_ring, unsigned int idx)
+{
+	nn_writeq(nn, NFP_NET_CFG_TXR_ADDR(idx), tx_ring->dma);
+	nn_writeb(nn, NFP_NET_CFG_TXR_SZ(idx), ilog2(tx_ring->cnt));
+	nn_writeb(nn, NFP_NET_CFG_TXR_VEC(idx), tx_ring->r_vec->irq_idx);
 }
 
 static int __nfp_net_set_config_and_enable(struct nfp_net *nn)
@@ -1948,8 +1963,10 @@ static int __nfp_net_set_config_and_enable(struct nfp_net *nn)
 		update |= NFP_NET_CFG_UPDATE_IRQMOD;
 	}
 
-	for (r = 0; r < nn->num_r_vecs; r++)
-		nfp_net_vec_write_ring_data(nn, &nn->r_vecs[r], r);
+	for (r = 0; r < nn->num_tx_rings; r++)
+		nfp_net_tx_ring_hw_cfg_write(nn, &nn->tx_rings[r], r);
+	for (r = 0; r < nn->num_rx_rings; r++)
+		nfp_net_rx_ring_hw_cfg_write(nn, &nn->rx_rings[r], r);
 
 	nn_writeq(nn, NFP_NET_CFG_TXRS_ENABLE, nn->num_tx_rings == 64 ?
 		  0xffffffffffffffffULL : ((u64)1 << nn->num_tx_rings) - 1);
@@ -1975,7 +1992,7 @@ static int __nfp_net_set_config_and_enable(struct nfp_net *nn)
 
 	nn->ctrl = new_ctrl;
 
-	for (r = 0; r < nn->num_r_vecs; r++)
+	for (r = 0; r < nn->num_rx_rings; r++)
 		nfp_net_rx_ring_fill_freelist(nn->r_vecs[r].rx_ring);
 
 	/* Since reconfiguration requests while NFP is down are ignored we
@@ -2067,20 +2084,22 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 	for (r = 0; r < nn->num_r_vecs; r++) {
 		err = nfp_net_prepare_vector(nn, &nn->r_vecs[r], r);
 		if (err)
-			goto err_free_prev_vecs;
-
+			goto err_cleanup_vec_p;
+	}
+	for (r = 0; r < nn->num_tx_rings; r++) {
 		err = nfp_net_tx_ring_alloc(nn->r_vecs[r].tx_ring, nn->txd_cnt);
 		if (err)
-			goto err_cleanup_vec_p;
-
+			goto err_free_tx_ring_p;
+	}
+	for (r = 0; r < nn->num_rx_rings; r++) {
 		err = nfp_net_rx_ring_alloc(nn->r_vecs[r].rx_ring,
 					    nn->fl_bufsz, nn->rxd_cnt);
 		if (err)
-			goto err_free_tx_ring_p;
+			goto err_flush_free_rx_ring_p;
 
 		err = nfp_net_rx_ring_bufs_alloc(nn, nn->r_vecs[r].rx_ring);
 		if (err)
-			goto err_flush_rx_ring_p;
+			goto err_free_rx_ring_p;
 	}
 
 	err = netif_set_real_num_tx_queues(netdev, nn->num_tx_rings);
@@ -2113,17 +2132,21 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 	return 0;
 
 err_free_rings:
-	r = nn->num_r_vecs;
-err_free_prev_vecs:
+	r = nn->num_rx_rings;
+err_flush_free_rx_ring_p:
 	while (r--) {
 		nfp_net_rx_ring_bufs_free(nn, nn->r_vecs[r].rx_ring);
-err_flush_rx_ring_p:
+err_free_rx_ring_p:
 		nfp_net_rx_ring_free(nn->r_vecs[r].rx_ring);
+	}
+	r = nn->num_tx_rings;
 err_free_tx_ring_p:
+	while (r--)
 		nfp_net_tx_ring_free(nn->r_vecs[r].tx_ring);
+	r = nn->num_r_vecs;
 err_cleanup_vec_p:
+	while (r--)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
-	}
 	kfree(nn->tx_rings);
 err_free_rx_rings:
 	kfree(nn->rx_rings);
@@ -2162,12 +2185,14 @@ static void nfp_net_close_free_all(struct nfp_net *nn)
 {
 	unsigned int r;
 
-	for (r = 0; r < nn->num_r_vecs; r++) {
+	for (r = 0; r < nn->num_rx_rings; r++) {
 		nfp_net_rx_ring_bufs_free(nn, nn->r_vecs[r].rx_ring);
 		nfp_net_rx_ring_free(nn->r_vecs[r].rx_ring);
+	}
+	for (r = 0; r < nn->num_tx_rings; r++)
 		nfp_net_tx_ring_free(nn->r_vecs[r].tx_ring);
+	for (r = 0; r < nn->num_r_vecs; r++)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
-	}
 
 	kfree(nn->rx_rings);
 	kfree(nn->tx_rings);
@@ -2686,7 +2711,6 @@ struct nfp_net *nfp_net_netdev_alloc(struct pci_dev *pdev,
 {
 	struct net_device *netdev;
 	struct nfp_net *nn;
-	int nqs;
 
 	netdev = alloc_etherdev_mqs(sizeof(struct nfp_net),
 				    max_tx_rings, max_rx_rings);
@@ -2702,9 +2726,9 @@ struct nfp_net *nfp_net_netdev_alloc(struct pci_dev *pdev,
 	nn->max_tx_rings = max_tx_rings;
 	nn->max_rx_rings = max_rx_rings;
 
-	nqs = netif_get_num_default_rss_queues();
-	nn->num_tx_rings = min_t(int, nqs, max_tx_rings);
-	nn->num_rx_rings = min_t(int, nqs, max_rx_rings);
+	nn->num_tx_rings = min_t(unsigned int, max_tx_rings, num_online_cpus());
+	nn->num_rx_rings = min_t(unsigned int, max_rx_rings,
+				 netif_get_num_default_rss_queues());
 
 	nn->num_r_vecs = max(nn->num_tx_rings, nn->num_rx_rings);
 	nn->num_r_vecs = min_t(unsigned int, nn->num_r_vecs, num_online_cpus());
-- 
1.9.1
