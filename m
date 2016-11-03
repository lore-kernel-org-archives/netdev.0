From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 04/13] nfp: reuse ring helpers on .ndo_open() path
Date: Thu,  3 Nov 2016 13:58:49 +0000
Message-ID: <1478181538-20778-5-git-send-email-jakub.kicinski@netronome.com>
References: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37191 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757724AbcKCN7T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 09:59:19 -0400
Received: by mail-wm0-f43.google.com with SMTP id t79so102817239wmt.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 06:59:18 -0700 (PDT)
In-Reply-To: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ring allocation helpers encapsulate all ring allocation and
initialization steps nicely.  Reuse them on .ndo_open() path.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 60 ++++++++--------------
 1 file changed, 20 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index b7b2851ebb6b..50aeaea9e318 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2051,6 +2051,13 @@ static void nfp_net_open_stack(struct nfp_net *nn)
 static int nfp_net_netdev_open(struct net_device *netdev)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
+	struct nfp_net_ring_set rx = {
+		.mtu = nn->netdev->mtu,
+		.dcnt = nn->rxd_cnt,
+	};
+	struct nfp_net_ring_set tx = {
+		.dcnt = nn->txd_cnt,
+	};
 	int err, r;
 
 	if (nn->ctrl & NFP_NET_CFG_CTRL_ENABLE) {
@@ -2075,38 +2082,22 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 		goto err_free_exn;
 	disable_irq(nn->irq_entries[NFP_NET_IRQ_LSC_IDX].vector);
 
-	nn->rx_rings = kcalloc(nn->num_rx_rings, sizeof(*nn->rx_rings),
-			       GFP_KERNEL);
-	if (!nn->rx_rings) {
-		err = -ENOMEM;
-		goto err_free_lsc;
-	}
-	nn->tx_rings = kcalloc(nn->num_tx_rings, sizeof(*nn->tx_rings),
-			       GFP_KERNEL);
-	if (!nn->tx_rings) {
-		err = -ENOMEM;
-		goto err_free_rx_rings;
-	}
-
 	for (r = 0; r < nn->num_r_vecs; r++) {
 		err = nfp_net_prepare_vector(nn, &nn->r_vecs[r], r);
 		if (err)
 			goto err_cleanup_vec_p;
 	}
-	for (r = 0; r < nn->num_tx_rings; r++) {
-		err = nfp_net_tx_ring_alloc(nn->r_vecs[r].tx_ring, nn->txd_cnt);
-		if (err)
-			goto err_free_tx_ring_p;
+
+	nn->rx_rings = nfp_net_rx_ring_set_prepare(nn, &rx);
+	if (!nn->rx_rings) {
+		err = -ENOMEM;
+		goto err_cleanup_vec;
 	}
-	for (r = 0; r < nn->num_rx_rings; r++) {
-		err = nfp_net_rx_ring_alloc(nn->r_vecs[r].rx_ring,
-					    nn->fl_bufsz, nn->rxd_cnt);
-		if (err)
-			goto err_flush_free_rx_ring_p;
 
-		err = nfp_net_rx_ring_bufs_alloc(nn, nn->r_vecs[r].rx_ring);
-		if (err)
-			goto err_free_rx_ring_p;
+	nn->tx_rings = nfp_net_tx_ring_set_prepare(nn, &tx);
+	if (!nn->tx_rings) {
+		err = -ENOMEM;
+		goto err_free_rx_rings;
 	}
 
 	err = netif_set_real_num_tx_queues(netdev, nn->num_tx_rings);
@@ -2139,25 +2130,14 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 	return 0;
 
 err_free_rings:
-	r = nn->num_rx_rings;
-err_flush_free_rx_ring_p:
-	while (r--) {
-		nfp_net_rx_ring_bufs_free(nn, nn->r_vecs[r].rx_ring);
-err_free_rx_ring_p:
-		nfp_net_rx_ring_free(nn->r_vecs[r].rx_ring);
-	}
-	r = nn->num_tx_rings;
-err_free_tx_ring_p:
-	while (r--)
-		nfp_net_tx_ring_free(nn->r_vecs[r].tx_ring);
+	nfp_net_tx_ring_set_free(nn, &tx);
+err_free_rx_rings:
+	nfp_net_rx_ring_set_free(nn, &rx);
+err_cleanup_vec:
 	r = nn->num_r_vecs;
 err_cleanup_vec_p:
 	while (r--)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
-	kfree(nn->tx_rings);
-err_free_rx_rings:
-	kfree(nn->rx_rings);
-err_free_lsc:
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
 err_free_exn:
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
-- 
1.9.1
