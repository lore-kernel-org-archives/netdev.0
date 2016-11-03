From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next resend 06/13] nfp: add helper to reassign rings to IRQ vectors
Date: Thu,  3 Nov 2016 17:12:02 +0000
Message-ID: <1478193129-23476-7-git-send-email-jakub.kicinski@netronome.com>
References: <1478193129-23476-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35792 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932545AbcKCRM0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 13:12:26 -0400
Received: by mail-wm0-f41.google.com with SMTP id a197so81529wmd.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 10:12:25 -0700 (PDT)
In-Reply-To: <1478193129-23476-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of fixing ring -> vector relations up in ring swap functions
put the reassignment into a helper function which will reinit all
links.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 40 +++++++++-------------
 1 file changed, 16 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 97cc21eae466..2a4e1f1cb3c9 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1601,16 +1601,11 @@ static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt)
 static void
 nfp_net_tx_ring_set_swap(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
-	struct nfp_net_tx_ring *rings = s->rings;
 	struct nfp_net_ring_set new = *s;
-	unsigned int r;
 
 	s->dcnt = nn->txd_cnt;
 	s->rings = nn->tx_rings;
 
-	for (r = 0; r < nn->num_tx_rings; r++)
-		nn->tx_rings[r].r_vec->tx_ring = &rings[r];
-
 	nn->txd_cnt = new.dcnt;
 	nn->tx_rings = new.rings;
 }
@@ -1728,17 +1723,12 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 static void
 nfp_net_rx_ring_set_swap(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
-	struct nfp_net_rx_ring *rings = s->rings;
 	struct nfp_net_ring_set new = *s;
-	unsigned int r;
 
 	s->mtu = nn->netdev->mtu;
 	s->dcnt = nn->rxd_cnt;
 	s->rings = nn->rx_rings;
 
-	for (r = 0; r < nn->num_rx_rings; r++)
-		nn->rx_rings[r].r_vec->rx_ring = &rings[r];
-
 	nn->netdev->mtu = new.mtu;
 	nn->fl_bufsz = nfp_net_calc_fl_bufsz(nn, new.mtu);
 	nn->rxd_cnt = new.dcnt;
@@ -1759,6 +1749,14 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 	kfree(rings);
 }
 
+static void
+nfp_net_vector_assign_rings(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
+			    int idx)
+{
+	r_vec->rx_ring = idx < nn->num_rx_rings ? &nn->rx_rings[idx] : NULL;
+	r_vec->tx_ring = idx < nn->num_tx_rings ? &nn->tx_rings[idx] : NULL;
+}
+
 static int
 nfp_net_prepare_vector(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
 		       int idx)
@@ -1766,20 +1764,6 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 	struct msix_entry *entry = &nn->irq_entries[r_vec->irq_idx];
 	int err;
 
-	if (idx < nn->num_tx_rings) {
-		r_vec->tx_ring = &nn->tx_rings[idx];
-		nfp_net_tx_ring_init(r_vec->tx_ring, r_vec, idx);
-	} else {
-		r_vec->tx_ring = NULL;
-	}
-
-	if (idx < nn->num_rx_rings) {
-		r_vec->rx_ring = &nn->rx_rings[idx];
-		nfp_net_rx_ring_init(r_vec->rx_ring, r_vec, idx);
-	} else {
-		r_vec->rx_ring = NULL;
-	}
-
 	snprintf(r_vec->name, sizeof(r_vec->name),
 		 "%s-rxtx-%d", nn->netdev->name, idx);
 	err = request_irq(entry->vector, r_vec->handler, 0, r_vec->name, r_vec);
@@ -2100,6 +2084,9 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 		goto err_free_rx_rings;
 	}
 
+	for (r = 0; r < nn->max_r_vecs; r++)
+		nfp_net_vector_assign_rings(nn, &nn->r_vecs[r], r);
+
 	err = netif_set_real_num_tx_queues(netdev, nn->num_tx_rings);
 	if (err)
 		goto err_free_rings;
@@ -2247,11 +2234,16 @@ static void nfp_net_set_rx_mode(struct net_device *netdev)
 			 struct nfp_net_ring_set *rx,
 			 struct nfp_net_ring_set *tx)
 {
+	unsigned int r;
+
 	if (rx)
 		nfp_net_rx_ring_set_swap(nn, rx);
 	if (tx)
 		nfp_net_tx_ring_set_swap(nn, tx);
 
+	for (r = 0; r <	nn->max_r_vecs; r++)
+		nfp_net_vector_assign_rings(nn, &nn->r_vecs[r], r);
+
 	return __nfp_net_set_config_and_enable(nn);
 }
 
-- 
1.9.1
