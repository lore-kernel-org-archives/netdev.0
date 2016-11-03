From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next resend 05/13] nfp: loosen relation between rings and IRQs vectors
Date: Thu,  3 Nov 2016 17:12:01 +0000
Message-ID: <1478193129-23476-6-git-send-email-jakub.kicinski@netronome.com>
References: <1478193129-23476-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:33517 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932578AbcKCRM0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 13:12:26 -0400
Received: by mail-wm0-f51.google.com with SMTP id c184so4858624wmd.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 10:12:25 -0700 (PDT)
In-Reply-To: <1478193129-23476-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upcoming XDP support will break the assumption that one can iterate
over IRQ vectors to get to all the rings easily.  Use nn->.x_ring
arrays directly.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 50aeaea9e318..97cc21eae466 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1920,9 +1920,9 @@ static void nfp_net_clear_config_and_disable(struct nfp_net *nn)
 		nn_err(nn, "Could not disable device: %d\n", err);
 
 	for (r = 0; r < nn->num_rx_rings; r++)
-		nfp_net_rx_ring_reset(nn->r_vecs[r].rx_ring);
+		nfp_net_rx_ring_reset(&nn->rx_rings[r]);
 	for (r = 0; r < nn->num_tx_rings; r++)
-		nfp_net_tx_ring_reset(nn, nn->r_vecs[r].tx_ring);
+		nfp_net_tx_ring_reset(nn, &nn->tx_rings[r]);
 	for (r = 0; r < nn->num_r_vecs; r++)
 		nfp_net_vec_clear_ring_data(nn, r);
 
@@ -2000,7 +2000,7 @@ static int __nfp_net_set_config_and_enable(struct nfp_net *nn)
 	nn->ctrl = new_ctrl;
 
 	for (r = 0; r < nn->num_rx_rings; r++)
-		nfp_net_rx_ring_fill_freelist(nn->r_vecs[r].rx_ring);
+		nfp_net_rx_ring_fill_freelist(&nn->rx_rings[r]);
 
 	/* Since reconfiguration requests while NFP is down are ignored we
 	 * have to wipe the entire VXLAN configuration and reinitialize it.
@@ -2173,11 +2173,11 @@ static void nfp_net_close_free_all(struct nfp_net *nn)
 	unsigned int r;
 
 	for (r = 0; r < nn->num_rx_rings; r++) {
-		nfp_net_rx_ring_bufs_free(nn, nn->r_vecs[r].rx_ring);
-		nfp_net_rx_ring_free(nn->r_vecs[r].rx_ring);
+		nfp_net_rx_ring_bufs_free(nn, &nn->rx_rings[r]);
+		nfp_net_rx_ring_free(&nn->rx_rings[r]);
 	}
 	for (r = 0; r < nn->num_tx_rings; r++)
-		nfp_net_tx_ring_free(nn->r_vecs[r].tx_ring);
+		nfp_net_tx_ring_free(&nn->tx_rings[r]);
 	for (r = 0; r < nn->num_r_vecs; r++)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 
-- 
1.9.1
