From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC (v3) 12/19] nfp: preallocate RX buffers early in .ndo_open
Date: Wed,  3 Feb 2016 11:45:18 +0000
Message-ID: <1454499925-16359-13-git-send-email-jakub.kicinski@netronome.com>
References: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36125 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933039AbcBCLps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 06:45:48 -0500
Received: by mail-wm0-f54.google.com with SMTP id p63so160981819wmp.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 03:45:47 -0800 (PST)
In-Reply-To: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We want the .ndo_open() to have following structure:
 - allocate resources;
 - configure HW/FW;
 - enable the device from stack perspective.
Therefore filling RX rings needs to be moved to the beginning
of .ndo_open().

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 34 +++++++---------------
 1 file changed, 11 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index b640e1693377..1e1e0f7ac077 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1664,28 +1664,19 @@ static void nfp_net_clear_config_and_disable(struct nfp_net *nn)
  * @nn:      NFP Net device structure
  * @r_vec:   Ring vector to be started
  */
-static int nfp_net_start_vec(struct nfp_net *nn, struct nfp_net_r_vector *r_vec)
+static void
+nfp_net_start_vec(struct nfp_net *nn, struct nfp_net_r_vector *r_vec)
 {
 	unsigned int irq_vec;
-	int err = 0;
 
 	irq_vec = nn->irq_entries[r_vec->irq_idx].vector;
 
 	disable_irq(irq_vec);
 
-	err = nfp_net_rx_ring_bufs_alloc(r_vec->nfp_net, r_vec->rx_ring);
-	if (err) {
-		nn_err(nn, "RV%02d: couldn't allocate enough buffers\n",
-		       r_vec->irq_idx);
-		goto out;
-	}
 	nfp_net_rx_ring_fill_freelist(r_vec->rx_ring);
-
 	napi_enable(&r_vec->napi);
-out:
-	enable_irq(irq_vec);
 
-	return err;
+	enable_irq(irq_vec);
 }
 
 static int nfp_net_netdev_open(struct net_device *netdev)
@@ -1740,6 +1731,10 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 		err = nfp_net_rx_ring_alloc(nn->r_vecs[r].rx_ring);
 		if (err)
 			goto err_free_tx_ring_p;
+
+		err = nfp_net_rx_ring_bufs_alloc(nn, nn->r_vecs[r].rx_ring);
+		if (err)
+			goto err_flush_rx_ring_p;
 	}
 
 	err = netif_set_real_num_tx_queues(netdev, nn->num_tx_rings);
@@ -1812,11 +1807,8 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 	 * - enable all TX queues
 	 * - set link state
 	 */
-	for (r = 0; r < nn->num_r_vecs; r++) {
-		err = nfp_net_start_vec(nn, &nn->r_vecs[r]);
-		if (err)
-			goto err_disable_napi;
-	}
+	for (r = 0; r < nn->num_r_vecs; r++)
+		nfp_net_start_vec(nn, &nn->r_vecs[r]);
 
 	netif_tx_wake_all_queues(netdev);
 
@@ -1825,18 +1817,14 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 
 	return 0;
 
-err_disable_napi:
-	while (r--) {
-		napi_disable(&nn->r_vecs[r].napi);
-		nfp_net_rx_ring_reset(nn->r_vecs[r].rx_ring);
-		nfp_net_rx_ring_bufs_free(nn, nn->r_vecs[r].rx_ring);
-	}
 err_clear_config:
 	nfp_net_clear_config_and_disable(nn);
 err_free_rings:
 	r = nn->num_r_vecs;
 err_free_prev_vecs:
 	while (r--) {
+		nfp_net_rx_ring_bufs_free(nn, nn->r_vecs[r].rx_ring);
+err_flush_rx_ring_p:
 		nfp_net_rx_ring_free(nn->r_vecs[r].rx_ring);
 err_free_tx_ring_p:
 		nfp_net_tx_ring_free(nn->r_vecs[r].tx_ring);
-- 
1.9.1
