From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH v4 net-next 11/15] nfp: sync ring state during FW reconfiguration
Date: Fri,  1 Apr 2016 22:06:47 +0100
Message-ID: <1459544811-24879-12-git-send-email-jakub.kicinski@netronome.com>
References: <1459544811-24879-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35367 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753906AbcDAVHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 17:07:12 -0400
Received: by mail-wm0-f51.google.com with SMTP id 191so4669963wmq.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 14:07:11 -0700 (PDT)
In-Reply-To: <1459544811-24879-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FW reconfiguration in .ndo_open()/.ndo_stop() should reset/
restore queue state.  Since we need IRQs to be disabled when
filling rings on RX path we have to move disable_irq() from
.ndo_open() all the way up to IRQ allocation.

nfp_net_start_vec() becomes trivial now so it's inlined.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 45 ++++++++--------------
 1 file changed, 16 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index f171a7da8931..2878ac021eda 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1520,6 +1520,7 @@ nfp_net_prepare_vector(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
 		nn_err(nn, "Error requesting IRQ %d\n", entry->vector);
 		return err;
 	}
+	disable_irq(entry->vector);
 
 	/* Setup NAPI */
 	netif_napi_add(nn->netdev, &r_vec->napi,
@@ -1648,13 +1649,14 @@ static void nfp_net_clear_config_and_disable(struct nfp_net *nn)
 
 	nn_writel(nn, NFP_NET_CFG_CTRL, new_ctrl);
 	err = nfp_net_reconfig(nn, update);
-	if (err) {
+	if (err)
 		nn_err(nn, "Could not disable device: %d\n", err);
-		return;
-	}
 
-	for (r = 0; r < nn->num_r_vecs; r++)
+	for (r = 0; r < nn->num_r_vecs; r++) {
+		nfp_net_rx_ring_reset(nn->r_vecs[r].rx_ring);
+		nfp_net_tx_ring_reset(nn, nn->r_vecs[r].tx_ring);
 		nfp_net_vec_clear_ring_data(nn, r);
+	}
 
 	nn->ctrl = new_ctrl;
 }
@@ -1722,6 +1724,9 @@ static int __nfp_net_set_config_and_enable(struct nfp_net *nn)
 
 	nn->ctrl = new_ctrl;
 
+	for (r = 0; r < nn->num_r_vecs; r++)
+		nfp_net_rx_ring_fill_freelist(nn->r_vecs[r].rx_ring);
+
 	/* Since reconfiguration requests while NFP is down are ignored we
 	 * have to wipe the entire VXLAN configuration and reinitialize it.
 	 */
@@ -1750,26 +1755,6 @@ static int nfp_net_set_config_and_enable(struct nfp_net *nn)
 }
 
 /**
- * nfp_net_start_vec() - Start ring vector
- * @nn:      NFP Net device structure
- * @r_vec:   Ring vector to be started
- */
-static void
-nfp_net_start_vec(struct nfp_net *nn, struct nfp_net_r_vector *r_vec)
-{
-	unsigned int irq_vec;
-
-	irq_vec = nn->irq_entries[r_vec->irq_idx].vector;
-
-	disable_irq(irq_vec);
-
-	nfp_net_rx_ring_fill_freelist(r_vec->rx_ring);
-	napi_enable(&r_vec->napi);
-
-	enable_irq(irq_vec);
-}
-
-/**
  * nfp_net_open_stack() - Start the device from stack's perspective
  * @nn:      NFP Net device to reconfigure
  */
@@ -1777,8 +1762,10 @@ static void nfp_net_open_stack(struct nfp_net *nn)
 {
 	unsigned int r;
 
-	for (r = 0; r < nn->num_r_vecs; r++)
-		nfp_net_start_vec(nn, &nn->r_vecs[r]);
+	for (r = 0; r < nn->num_r_vecs; r++) {
+		napi_enable(&nn->r_vecs[r].napi);
+		enable_irq(nn->irq_entries[nn->r_vecs[r].irq_idx].vector);
+	}
 
 	netif_tx_wake_all_queues(nn->netdev);
 
@@ -1903,8 +1890,10 @@ static void nfp_net_close_stack(struct nfp_net *nn)
 	netif_carrier_off(nn->netdev);
 	nn->link_up = false;
 
-	for (r = 0; r < nn->num_r_vecs; r++)
+	for (r = 0; r < nn->num_r_vecs; r++) {
+		disable_irq(nn->irq_entries[nn->r_vecs[r].irq_idx].vector);
 		napi_disable(&nn->r_vecs[r].napi);
+	}
 
 	netif_tx_disable(nn->netdev);
 }
@@ -1918,9 +1907,7 @@ static void nfp_net_close_free_all(struct nfp_net *nn)
 	unsigned int r;
 
 	for (r = 0; r < nn->num_r_vecs; r++) {
-		nfp_net_rx_ring_reset(nn->r_vecs[r].rx_ring);
 		nfp_net_rx_ring_bufs_free(nn, nn->r_vecs[r].rx_ring);
-		nfp_net_tx_ring_reset(nn, nn->r_vecs[r].tx_ring);
 		nfp_net_rx_ring_free(nn->r_vecs[r].rx_ring);
 		nfp_net_tx_ring_free(nn->r_vecs[r].tx_ring);
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
-- 
1.9.1
