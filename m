From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 03/16] nfp: reuse ring free code on close
Date: Mon,  5 Jun 2017 17:01:44 -0700
Message-ID: <20170606000157.17556-4-jakub.kicinski@netronome.com>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36600 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751242AbdFFACR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 20:02:17 -0400
Received: by mail-pf0-f177.google.com with SMTP id m17so90021652pfg.3
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 17:02:17 -0700 (PDT)
In-Reply-To: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the close path reuse the ring free helpers introduced for runtime
reconfiguration.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 14 +++-----------
 1 file changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index bec51f4a9299..23419883cfd4 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2303,20 +2303,12 @@ static void nfp_net_close_free_all(struct nfp_net *nn)
 {
 	unsigned int r;
 
-	for (r = 0; r < nn->dp.num_rx_rings; r++) {
-		nfp_net_rx_ring_bufs_free(&nn->dp, &nn->dp.rx_rings[r]);
-		nfp_net_rx_ring_free(&nn->dp.rx_rings[r]);
-	}
-	for (r = 0; r < nn->dp.num_tx_rings; r++) {
-		nfp_net_tx_ring_bufs_free(&nn->dp, &nn->dp.tx_rings[r]);
-		nfp_net_tx_ring_free(&nn->dp.tx_rings[r]);
-	}
+	nfp_net_tx_rings_free(&nn->dp);
+	nfp_net_rx_rings_free(&nn->dp);
+
 	for (r = 0; r < nn->dp.num_r_vecs; r++)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 
-	kfree(nn->dp.rx_rings);
-	kfree(nn->dp.tx_rings);
-
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
 }
-- 
2.11.0
