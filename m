From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC (v3) 09/19] nfp: allocate ring SW structs dynamically
Date: Wed,  3 Feb 2016 11:45:15 +0000
Message-ID: <1454499925-16359-10-git-send-email-jakub.kicinski@netronome.com>
References: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35115 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932953AbcBCLpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 06:45:45 -0500
Received: by mail-wm0-f53.google.com with SMTP id r129so160910312wmr.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 03:45:44 -0800 (PST)
In-Reply-To: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To be able to switch rings more easily on config changes allocate
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
index 8299d4c002fb..faaa25dd5a1e 100644
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
 
@@ -1501,6 +1495,12 @@ nfp_net_prepare_vector(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
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
@@ -1691,6 +1691,15 @@ static int nfp_net_netdev_open(struct net_device *netdev)
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
@@ -1805,6 +1814,10 @@ err_free_tx_ring_p:
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
@@ -1850,6 +1863,9 @@ static int nfp_net_netdev_close(struct net_device *netdev)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 	}
 
+	kfree(nn->rx_rings);
+	kfree(nn->tx_rings);
+
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
 
-- 
1.9.1
