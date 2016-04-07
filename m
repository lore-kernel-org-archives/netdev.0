From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH v5 net-next 09/15] nfp: move filling ring information to FW config
Date: Thu,  7 Apr 2016 19:39:42 +0100
Message-ID: <1460054388-471-10-git-send-email-jakub.kicinski@netronome.com>
References: <1460054388-471-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:34897 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757388AbcDGSka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 14:40:30 -0400
Received: by mail-qk0-f171.google.com with SMTP id o6so34594885qkc.2
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 11:40:29 -0700 (PDT)
In-Reply-To: <1460054388-471-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nfp_net_[rt]x_ring_{alloc,free} should only allocate or free
ring resources without touching the device.  Move setting
parameters in the BAR to separate functions.  This will make
it possible to reuse alloc/free functions to allocate new
rings while the device is running.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 50 ++++++++++++++--------
 1 file changed, 32 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index a6a917fe8e31..342335d09fb2 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1387,10 +1387,6 @@ static void nfp_net_tx_ring_free(struct nfp_net_tx_ring *tx_ring)
 	struct nfp_net *nn = r_vec->nfp_net;
 	struct pci_dev *pdev = nn->pdev;
 
-	nn_writeq(nn, NFP_NET_CFG_TXR_ADDR(tx_ring->idx), 0);
-	nn_writeb(nn, NFP_NET_CFG_TXR_SZ(tx_ring->idx), 0);
-	nn_writeb(nn, NFP_NET_CFG_TXR_VEC(tx_ring->idx), 0);
-
 	kfree(tx_ring->txbufs);
 
 	if (tx_ring->txds)
@@ -1430,11 +1426,6 @@ static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring)
 	if (!tx_ring->txbufs)
 		goto err_alloc;
 
-	/* Write the DMA address, size and MSI-X info to the device */
-	nn_writeq(nn, NFP_NET_CFG_TXR_ADDR(tx_ring->idx), tx_ring->dma);
-	nn_writeb(nn, NFP_NET_CFG_TXR_SZ(tx_ring->idx), ilog2(tx_ring->cnt));
-	nn_writeb(nn, NFP_NET_CFG_TXR_VEC(tx_ring->idx), r_vec->irq_idx);
-
 	netif_set_xps_queue(nn->netdev, &r_vec->affinity_mask, tx_ring->idx);
 
 	nn_dbg(nn, "TxQ%02d: QCidx=%02d cnt=%d dma=%#llx host=%p\n",
@@ -1458,10 +1449,6 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 	struct nfp_net *nn = r_vec->nfp_net;
 	struct pci_dev *pdev = nn->pdev;
 
-	nn_writeq(nn, NFP_NET_CFG_RXR_ADDR(rx_ring->idx), 0);
-	nn_writeb(nn, NFP_NET_CFG_RXR_SZ(rx_ring->idx), 0);
-	nn_writeb(nn, NFP_NET_CFG_RXR_VEC(rx_ring->idx), 0);
-
 	kfree(rx_ring->rxbufs);
 
 	if (rx_ring->rxds)
@@ -1501,11 +1488,6 @@ static int nfp_net_rx_ring_alloc(struct nfp_net_rx_ring *rx_ring)
 	if (!rx_ring->rxbufs)
 		goto err_alloc;
 
-	/* Write the DMA address, size and MSI-X info to the device */
-	nn_writeq(nn, NFP_NET_CFG_RXR_ADDR(rx_ring->idx), rx_ring->dma);
-	nn_writeb(nn, NFP_NET_CFG_RXR_SZ(rx_ring->idx), ilog2(rx_ring->cnt));
-	nn_writeb(nn, NFP_NET_CFG_RXR_VEC(rx_ring->idx), r_vec->irq_idx);
-
 	nn_dbg(nn, "RxQ%02d: FlQCidx=%02d RxQCidx=%02d cnt=%d dma=%#llx host=%p\n",
 	       rx_ring->idx, rx_ring->fl_qcidx, rx_ring->rx_qcidx,
 	       rx_ring->cnt, (unsigned long long)rx_ring->dma, rx_ring->rxds);
@@ -1630,6 +1612,17 @@ static void nfp_net_write_mac_addr(struct nfp_net *nn, const u8 *mac)
 		  get_unaligned_be16(nn->netdev->dev_addr + 4) << 16);
 }
 
+static void nfp_net_vec_clear_ring_data(struct nfp_net *nn, unsigned int idx)
+{
+	nn_writeq(nn, NFP_NET_CFG_RXR_ADDR(idx), 0);
+	nn_writeb(nn, NFP_NET_CFG_RXR_SZ(idx), 0);
+	nn_writeb(nn, NFP_NET_CFG_RXR_VEC(idx), 0);
+
+	nn_writeq(nn, NFP_NET_CFG_TXR_ADDR(idx), 0);
+	nn_writeb(nn, NFP_NET_CFG_TXR_SZ(idx), 0);
+	nn_writeb(nn, NFP_NET_CFG_TXR_VEC(idx), 0);
+}
+
 /**
  * nfp_net_clear_config_and_disable() - Clear control BAR and disable NFP
  * @nn:      NFP Net device to reconfigure
@@ -1637,6 +1630,7 @@ static void nfp_net_write_mac_addr(struct nfp_net *nn, const u8 *mac)
 static void nfp_net_clear_config_and_disable(struct nfp_net *nn)
 {
 	u32 new_ctrl, update;
+	unsigned int r;
 	int err;
 
 	new_ctrl = nn->ctrl;
@@ -1658,9 +1652,26 @@ static void nfp_net_clear_config_and_disable(struct nfp_net *nn)
 		return;
 	}
 
+	for (r = 0; r < nn->num_r_vecs; r++)
+		nfp_net_vec_clear_ring_data(nn, r);
+
 	nn->ctrl = new_ctrl;
 }
 
+static void
+nfp_net_vec_write_ring_data(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
+			    unsigned int idx)
+{
+	/* Write the DMA address, size and MSI-X info to the device */
+	nn_writeq(nn, NFP_NET_CFG_RXR_ADDR(idx), r_vec->rx_ring->dma);
+	nn_writeb(nn, NFP_NET_CFG_RXR_SZ(idx), ilog2(r_vec->rx_ring->cnt));
+	nn_writeb(nn, NFP_NET_CFG_RXR_VEC(idx), r_vec->irq_idx);
+
+	nn_writeq(nn, NFP_NET_CFG_TXR_ADDR(idx), r_vec->tx_ring->dma);
+	nn_writeb(nn, NFP_NET_CFG_TXR_SZ(idx), ilog2(r_vec->tx_ring->cnt));
+	nn_writeb(nn, NFP_NET_CFG_TXR_VEC(idx), r_vec->irq_idx);
+}
+
 /**
  * nfp_net_start_vec() - Start ring vector
  * @nn:      NFP Net device structure
@@ -1768,6 +1779,9 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 	 * - Set the Freelist buffer size
 	 * - Enable the FW
 	 */
+	for (r = 0; r < nn->num_r_vecs; r++)
+		nfp_net_vec_write_ring_data(nn, &nn->r_vecs[r], r);
+
 	nn_writeq(nn, NFP_NET_CFG_TXRS_ENABLE, nn->num_tx_rings == 64 ?
 		  0xffffffffffffffffULL : ((u64)1 << nn->num_tx_rings) - 1);
 
-- 
1.9.1
