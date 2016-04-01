From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH v4 net-next 03/15] nfp: break up nfp_net_{alloc|free}_rings
Date: Fri,  1 Apr 2016 22:06:39 +0100
Message-ID: <1459544811-24879-4-git-send-email-jakub.kicinski@netronome.com>
References: <1459544811-24879-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37374 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753451AbcDAVHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 17:07:04 -0400
Received: by mail-wm0-f54.google.com with SMTP id p65so5353393wmp.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 14:07:03 -0700 (PDT)
In-Reply-To: <1459544811-24879-1-git-send-email-jakub.kicinski@netronome.com>
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
index 9ce04b179fac..b435d15ef8d6 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1489,91 +1489,40 @@ err_alloc:
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
@@ -1737,9 +1686,19 @@ static int nfp_net_netdev_open(struct net_device *netdev)
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
@@ -1832,8 +1791,15 @@ err_disable_napi:
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
@@ -1874,9 +1840,11 @@ static int nfp_net_netdev_close(struct net_device *netdev)
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
