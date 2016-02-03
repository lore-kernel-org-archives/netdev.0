From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC (v3) 18/19] nfp: pass ring count as function parameter
Date: Wed,  3 Feb 2016 11:45:24 +0000
Message-ID: <1454499925-16359-19-git-send-email-jakub.kicinski@netronome.com>
References: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35284 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933039AbcBCLpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 06:45:53 -0500
Received: by mail-wm0-f44.google.com with SMTP id r129so160915677wmr.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 03:45:53 -0800 (PST)
In-Reply-To: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
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
index 0153fce33dff..2c86a10abcd3 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1405,17 +1405,18 @@ static void nfp_net_tx_ring_free(struct nfp_net_tx_ring *tx_ring)
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
@@ -1468,18 +1469,20 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
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
@@ -1505,7 +1508,8 @@ err_alloc:
 }
 
 static struct nfp_net_rx_ring *
-nfp_net_shadow_rx_rings_prepare(struct nfp_net *nn, unsigned int fl_bufsz)
+nfp_net_shadow_rx_rings_prepare(struct nfp_net *nn, unsigned int fl_bufsz,
+				u32 buf_cnt)
 {
 	struct nfp_net_rx_ring *rings;
 	unsigned int r;
@@ -1517,7 +1521,7 @@ nfp_net_shadow_rx_rings_prepare(struct nfp_net *nn, unsigned int fl_bufsz)
 	for (r = 0; r < nn->num_rx_rings; r++) {
 		nfp_net_rx_ring_init(&rings[r], nn->rx_rings[r].r_vec, r);
 
-		if (nfp_net_rx_ring_alloc(&rings[r], fl_bufsz))
+		if (nfp_net_rx_ring_alloc(&rings[r], fl_bufsz, buf_cnt))
 			goto err_free_prev;
 
 		if (nfp_net_rx_ring_bufs_alloc(nn, &rings[r]))
@@ -1871,12 +1875,12 @@ static int nfp_net_netdev_open(struct net_device *netdev)
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
 
@@ -2057,7 +2061,8 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 	}
 
 	/* Prepare new rings */
-	tmp_rings = nfp_net_shadow_rx_rings_prepare(nn, new_fl_bufsz);
+	tmp_rings = nfp_net_shadow_rx_rings_prepare(nn, new_fl_bufsz,
+						    nn->rxd_cnt);
 	if (!tmp_rings)
 		return -ENOMEM;
 
-- 
1.9.1
