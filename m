From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH v4 net-next 14/15] nfp: pass ring count as function parameter
Date: Fri,  1 Apr 2016 22:06:50 +0100
Message-ID: <1459544811-24879-15-git-send-email-jakub.kicinski@netronome.com>
References: <1459544811-24879-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35399 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753906AbcDAVHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 17:07:15 -0400
Received: by mail-wm0-f48.google.com with SMTP id 191so4670961wmq.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 14:07:14 -0700 (PDT)
In-Reply-To: <1459544811-24879-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Soon ring resize will call this functions with values
different than the current configuration we need to
explicitly pass the ring count as parameter.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 23 +++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 33001ce1d8bf..631168a1971e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1408,17 +1408,18 @@ static void nfp_net_tx_ring_free(struct nfp_net_tx_ring *tx_ring)
 /**
  * nfp_net_tx_ring_alloc() - Allocate resource for a TX ring
  * @tx_ring:   TX Ring structure to allocate
+ * @cnt:       Ring buffer count
  *
  * Return: 0 on success, negative errno otherwise.
  */
-static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring)
+static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt)
 {
 	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
 	struct nfp_net *nn = r_vec->nfp_net;
 	struct pci_dev *pdev = nn->pdev;
 	int sz;
 
-	tx_ring->cnt = nn->txd_cnt;
+	tx_ring->cnt = cnt;
 
 	tx_ring->size = sizeof(*tx_ring->txds) * tx_ring->cnt;
 	tx_ring->txds = dma_zalloc_coherent(&pdev->dev, tx_ring->size,
@@ -1471,18 +1472,20 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
  * nfp_net_rx_ring_alloc() - Allocate resource for a RX ring
  * @rx_ring:  RX ring to allocate
  * @fl_bufsz: Size of buffers to allocate
+ * @cnt:      Ring buffer count
  *
  * Return: 0 on success, negative errno otherwise.
  */
 static int
-nfp_net_rx_ring_alloc(struct nfp_net_rx_ring *rx_ring, unsigned int fl_bufsz)
+nfp_net_rx_ring_alloc(struct nfp_net_rx_ring *rx_ring, unsigned int fl_bufsz,
+		      u32 cnt)
 {
 	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
 	struct nfp_net *nn = r_vec->nfp_net;
 	struct pci_dev *pdev = nn->pdev;
 	int sz;
 
-	rx_ring->cnt = nn->rxd_cnt;
+	rx_ring->cnt = cnt;
 	rx_ring->bufsz = fl_bufsz;
 
 	rx_ring->size = sizeof(*rx_ring->rxds) * rx_ring->cnt;
@@ -1508,7 +1511,8 @@ err_alloc:
 }
 
 static struct nfp_net_rx_ring *
-nfp_net_shadow_rx_rings_prepare(struct nfp_net *nn, unsigned int fl_bufsz)
+nfp_net_shadow_rx_rings_prepare(struct nfp_net *nn, unsigned int fl_bufsz,
+				u32 buf_cnt)
 {
 	struct nfp_net_rx_ring *rings;
 	unsigned int r;
@@ -1520,7 +1524,7 @@ nfp_net_shadow_rx_rings_prepare(struct nfp_net *nn, unsigned int fl_bufsz)
 	for (r = 0; r < nn->num_rx_rings; r++) {
 		nfp_net_rx_ring_init(&rings[r], nn->rx_rings[r].r_vec, r);
 
-		if (nfp_net_rx_ring_alloc(&rings[r], fl_bufsz))
+		if (nfp_net_rx_ring_alloc(&rings[r], fl_bufsz, buf_cnt))
 			goto err_free_prev;
 
 		if (nfp_net_rx_ring_bufs_alloc(nn, &rings[r]))
@@ -1879,12 +1883,12 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 		if (err)
 			goto err_free_prev_vecs;
 
-		err = nfp_net_tx_ring_alloc(nn->r_vecs[r].tx_ring);
+		err = nfp_net_tx_ring_alloc(nn->r_vecs[r].tx_ring, nn->txd_cnt);
 		if (err)
 			goto err_cleanup_vec_p;
 
 		err = nfp_net_rx_ring_alloc(nn->r_vecs[r].rx_ring,
-					    nn->fl_bufsz);
+					    nn->fl_bufsz, nn->rxd_cnt);
 		if (err)
 			goto err_free_tx_ring_p;
 
@@ -2065,7 +2069,8 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 	}
 
 	/* Prepare new rings */
-	tmp_rings = nfp_net_shadow_rx_rings_prepare(nn, new_fl_bufsz);
+	tmp_rings = nfp_net_shadow_rx_rings_prepare(nn, new_fl_bufsz,
+						    nn->rxd_cnt);
 	if (!tmp_rings)
 		return -ENOMEM;
 
-- 
1.9.1
