From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH v4 net-next 05/15] nfp: allocate ring SW structs dynamically
Date: Fri,  1 Apr 2016 22:06:41 +0100
Message-ID: <1459544811-24879-6-git-send-email-jakub.kicinski@netronome.com>
References: <1459544811-24879-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37400 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbcDAVHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 17:07:05 -0400
Received: by mail-wm0-f48.google.com with SMTP id p65so5354205wmp.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 14:07:05 -0700 (PDT)
In-Reply-To: <1459544811-24879-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To be able to switch rings more easly on config changes allocate
them dynamically, separately from nfp_net structure.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  6 ++---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 28 +++++++++++++++++-----
 2 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index ab264e1bccd0..0a87571a7d9c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -472,6 +472,9 @@ struct nfp_net {
 
 	u32 rx_offset;
 
+	struct nfp_net_tx_ring *tx_rings;
+	struct nfp_net_rx_ring *rx_rings;
+
 #ifdef CONFIG_PCI_IOV
 	unsigned int num_vfs;
 	struct vf_data_storage *vfinfo;
@@ -504,9 +507,6 @@ struct nfp_net {
 	int txd_cnt;
 	int rxd_cnt;
 
-	struct nfp_net_tx_ring tx_rings[NFP_NET_MAX_TX_RINGS];
-	struct nfp_net_rx_ring rx_rings[NFP_NET_MAX_RX_RINGS];
-
 	u8 num_irqs;
 	u8 num_r_vecs;
 	struct nfp_net_r_vector r_vecs[NFP_NET_MAX_TX_RINGS];
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 7233471af7a8..8f7e2e044811 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -414,12 +414,6 @@ static void nfp_net_irqs_assign(struct net_device *netdev)
 		r_vec->irq_idx = NFP_NET_NON_Q_VECTORS + r;
 
 		cpumask_set_cpu(r, &r_vec->affinity_mask);
-
-		r_vec->tx_ring = &nn->tx_rings[r];
-		nfp_net_tx_ring_init(r_vec->tx_ring, r_vec, r);
-
-		r_vec->rx_ring = &nn->rx_rings[r];
-		nfp_net_rx_ring_init(r_vec->rx_ring, r_vec, r);
 	}
 }
 
@@ -1504,6 +1498,12 @@ nfp_net_prepare_vector(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
 	struct msix_entry *entry = &nn->irq_entries[r_vec->irq_idx];
 	int err;
 
+	r_vec->tx_ring = &nn->tx_rings[idx];
+	nfp_net_tx_ring_init(r_vec->tx_ring, r_vec, idx);
+
+	r_vec->rx_ring = &nn->rx_rings[idx];
+	nfp_net_rx_ring_init(r_vec->rx_ring, r_vec, idx);
+
 	snprintf(r_vec->name, sizeof(r_vec->name),
 		 "%s-rxtx-%d", nn->netdev->name, idx);
 	err = request_irq(entry->vector, r_vec->handler, 0, r_vec->name, r_vec);
@@ -1694,6 +1694,15 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 		goto err_free_exn;
 	disable_irq(nn->irq_entries[NFP_NET_CFG_LSC].vector);
 
+	nn->rx_rings = kcalloc(nn->num_rx_rings, sizeof(*nn->rx_rings),
+			       GFP_KERNEL);
+	if (!nn->rx_rings)
+		goto err_free_lsc;
+	nn->tx_rings = kcalloc(nn->num_tx_rings, sizeof(*nn->tx_rings),
+			       GFP_KERNEL);
+	if (!nn->tx_rings)
+		goto err_free_rx_rings;
+
 	for (r = 0; r < nn->num_r_vecs; r++) {
 		err = nfp_net_prepare_vector(nn, &nn->r_vecs[r], r);
 		if (err)
@@ -1808,6 +1817,10 @@ err_free_tx_ring_p:
 err_cleanup_vec_p:
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 	}
+	kfree(nn->tx_rings);
+err_free_rx_rings:
+	kfree(nn->rx_rings);
+err_free_lsc:
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
 err_free_exn:
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
@@ -1853,6 +1866,9 @@ static int nfp_net_netdev_close(struct net_device *netdev)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 	}
 
+	kfree(nn->rx_rings);
+	kfree(nn->tx_rings);
+
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
 
-- 
1.9.1
