From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC (v3) 07/19] nfp: break up nfp_net_{alloc|free}_rings
Date: Wed,  3 Feb 2016 11:45:13 +0000
Message-ID: <1454499925-16359-8-git-send-email-jakub.kicinski@netronome.com>
References: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36037 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932934AbcBCLpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 06:45:43 -0500
Received: by mail-wm0-f49.google.com with SMTP id p63so160978962wmp.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 03:45:42 -0800 (PST)
In-Reply-To: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nfp_net_{alloc|free}_rings contained strange mix of allocations
and vector initialization.  Remove it, declare vector init as
a separate function and handle allocations explicitly.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 126 ++++++++-------------
 1 file changed, 47 insertions(+), 79 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index bebdae80ccda..d39ac3553e1e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1486,91 +1486,40 @@ err_alloc:
 	return -ENOMEM;
 }
 
-static void __nfp_net_free_rings(struct nfp_net *nn, unsigned int n_free)
+static int
+nfp_net_prepare_vector(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
+		       int idx)
 {
-	struct nfp_net_r_vector *r_vec;
-	struct msix_entry *entry;
+	struct msix_entry *entry = &nn->irq_entries[r_vec->irq_idx];
+	int err;
 
-	while (n_free--) {
-		r_vec = &nn->r_vecs[n_free];
-		entry = &nn->irq_entries[r_vec->irq_idx];
+	snprintf(r_vec->name, sizeof(r_vec->name),
+		 "%s-rxtx-%d", nn->netdev->name, idx);
+	err = request_irq(entry->vector, r_vec->handler, 0, r_vec->name, r_vec);
+	if (err) {
+		nn_err(nn, "Error requesting IRQ %d\n", entry->vector);
+		return err;
+	}
 
-		nfp_net_rx_ring_free(r_vec->rx_ring);
-		nfp_net_tx_ring_free(r_vec->tx_ring);
+	/* Setup NAPI */
+	netif_napi_add(nn->netdev, &r_vec->napi,
+		       nfp_net_poll, NAPI_POLL_WEIGHT);
 
-		irq_set_affinity_hint(entry->vector, NULL);
-		free_irq(entry->vector, r_vec);
+	irq_set_affinity_hint(entry->vector, &r_vec->affinity_mask);
 
-		netif_napi_del(&r_vec->napi);
-	}
-}
+	nn_dbg(nn, "RV%02d: irq=%03d/%03d\n", idx, entry->vector, entry->entry);
 
-/**
- * nfp_net_free_rings() - Free all ring resources
- * @nn:      NFP Net device to reconfigure
- */
-static void nfp_net_free_rings(struct nfp_net *nn)
-{
-	__nfp_net_free_rings(nn, nn->num_r_vecs);
+	return 0;
 }
 
-/**
- * nfp_net_alloc_rings() - Allocate resources for RX and TX rings
- * @nn:      NFP Net device to reconfigure
- *
- * Return: 0 on success or negative errno on error.
- */
-static int nfp_net_alloc_rings(struct nfp_net *nn)
+static void
+nfp_net_cleanup_vector(struct nfp_net *nn, struct nfp_net_r_vector *r_vec)
 {
-	struct nfp_net_r_vector *r_vec;
-	struct msix_entry *entry;
-	int err;
-	int r;
+	struct msix_entry *entry = &nn->irq_entries[r_vec->irq_idx];
 
-	for (r = 0; r < nn->num_r_vecs; r++) {
-		r_vec = &nn->r_vecs[r];
-		entry = &nn->irq_entries[r_vec->irq_idx];
-
-		/* Setup NAPI */
-		netif_napi_add(nn->netdev, &r_vec->napi,
-			       nfp_net_poll, NAPI_POLL_WEIGHT);
-
-		snprintf(r_vec->name, sizeof(r_vec->name),
-			 "%s-rxtx-%d", nn->netdev->name, r);
-		err = request_irq(entry->vector, r_vec->handler, 0,
-				  r_vec->name, r_vec);
-		if (err) {
-			nn_dbg(nn, "Error requesting IRQ %d\n", entry->vector);
-			goto err_napi_del;
-		}
-
-		irq_set_affinity_hint(entry->vector, &r_vec->affinity_mask);
-
-		nn_dbg(nn, "RV%02d: irq=%03d/%03d\n",
-		       r, entry->vector, entry->entry);
-
-		/* Allocate TX ring resources */
-		err = nfp_net_tx_ring_alloc(r_vec->tx_ring);
-		if (err)
-			goto err_free_irq;
-
-		/* Allocate RX ring resources */
-		err = nfp_net_rx_ring_alloc(r_vec->rx_ring);
-		if (err)
-			goto err_free_tx;
-	}
-
-	return 0;
-
-err_free_tx:
-	nfp_net_tx_ring_free(r_vec->tx_ring);
-err_free_irq:
 	irq_set_affinity_hint(entry->vector, NULL);
-	free_irq(entry->vector, r_vec);
-err_napi_del:
 	netif_napi_del(&r_vec->napi);
-	__nfp_net_free_rings(nn, r);
-	return err;
+	free_irq(entry->vector, r_vec);
 }
 
 /**
@@ -1734,9 +1683,19 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 		goto err_free_exn;
 	disable_irq(nn->irq_entries[NFP_NET_CFG_LSC].vector);
 
-	err = nfp_net_alloc_rings(nn);
-	if (err)
-		goto err_free_lsc;
+	for (r = 0; r < nn->num_r_vecs; r++) {
+		err = nfp_net_prepare_vector(nn, &nn->r_vecs[r], r);
+		if (err)
+			goto err_free_prev_vecs;
+
+		err = nfp_net_tx_ring_alloc(nn->r_vecs[r].tx_ring);
+		if (err)
+			goto err_cleanup_vec_p;
+
+		err = nfp_net_rx_ring_alloc(nn->r_vecs[r].rx_ring);
+		if (err)
+			goto err_free_tx_ring_p;
+	}
 
 	err = netif_set_real_num_tx_queues(netdev, nn->num_tx_rings);
 	if (err)
@@ -1829,8 +1788,15 @@ err_disable_napi:
 err_clear_config:
 	nfp_net_clear_config_and_disable(nn);
 err_free_rings:
-	nfp_net_free_rings(nn);
-err_free_lsc:
+	r = nn->num_r_vecs;
+err_free_prev_vecs:
+	while (r--) {
+		nfp_net_rx_ring_free(nn->r_vecs[r].rx_ring);
+err_free_tx_ring_p:
+		nfp_net_tx_ring_free(nn->r_vecs[r].tx_ring);
+err_cleanup_vec_p:
+		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
+	}
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
 err_free_exn:
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
@@ -1871,9 +1837,11 @@ static int nfp_net_netdev_close(struct net_device *netdev)
 	for (r = 0; r < nn->num_r_vecs; r++) {
 		nfp_net_rx_flush(nn->r_vecs[r].rx_ring);
 		nfp_net_tx_flush(nn->r_vecs[r].tx_ring);
+		nfp_net_rx_ring_free(nn->r_vecs[r].rx_ring);
+		nfp_net_tx_ring_free(nn->r_vecs[r].tx_ring);
+		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 	}
 
-	nfp_net_free_rings(nn);
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
 
-- 
1.9.1
