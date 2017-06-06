From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 01/16] nfp: reorder open and close functions
Date: Mon,  5 Jun 2017 17:01:42 -0700
Message-ID: <20170606000157.17556-2-jakub.kicinski@netronome.com>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33267 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751209AbdFFACP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 20:02:15 -0400
Received: by mail-pf0-f171.google.com with SMTP id 83so32351079pfr.0
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 17:02:15 -0700 (PDT)
In-Reply-To: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will soon reuse parts of .ndo_stop() for clean up after errors
in .ndo_open().  Reorder the associated functions to make that possible.

No functional changes.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 140 ++++++++++-----------
 1 file changed, 70 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index c3235d03b8eb..770ef28c0380 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2276,6 +2276,76 @@ static int nfp_net_set_config_and_enable(struct nfp_net *nn)
 }
 
 /**
+ * nfp_net_close_stack() - Quiesce the stack (part of close)
+ * @nn:	     NFP Net device to reconfigure
+ */
+static void nfp_net_close_stack(struct nfp_net *nn)
+{
+	unsigned int r;
+
+	disable_irq(nn->irq_entries[NFP_NET_IRQ_LSC_IDX].vector);
+	netif_carrier_off(nn->dp.netdev);
+	nn->link_up = false;
+
+	for (r = 0; r < nn->dp.num_r_vecs; r++) {
+		disable_irq(nn->r_vecs[r].irq_vector);
+		napi_disable(&nn->r_vecs[r].napi);
+	}
+
+	netif_tx_disable(nn->dp.netdev);
+}
+
+/**
+ * nfp_net_close_free_all() - Free all runtime resources
+ * @nn:      NFP Net device to reconfigure
+ */
+static void nfp_net_close_free_all(struct nfp_net *nn)
+{
+	unsigned int r;
+
+	for (r = 0; r < nn->dp.num_rx_rings; r++) {
+		nfp_net_rx_ring_bufs_free(&nn->dp, &nn->dp.rx_rings[r]);
+		nfp_net_rx_ring_free(&nn->dp.rx_rings[r]);
+	}
+	for (r = 0; r < nn->dp.num_tx_rings; r++) {
+		nfp_net_tx_ring_bufs_free(&nn->dp, &nn->dp.tx_rings[r]);
+		nfp_net_tx_ring_free(&nn->dp.tx_rings[r]);
+	}
+	for (r = 0; r < nn->dp.num_r_vecs; r++)
+		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
+
+	kfree(nn->dp.rx_rings);
+	kfree(nn->dp.tx_rings);
+
+	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
+	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
+}
+
+/**
+ * nfp_net_netdev_close() - Called when the device is downed
+ * @netdev:      netdev structure
+ */
+static int nfp_net_netdev_close(struct net_device *netdev)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	/* Step 1: Disable RX and TX rings from the Linux kernel perspective
+	 */
+	nfp_net_close_stack(nn);
+
+	/* Step 2: Tell NFP
+	 */
+	nfp_net_clear_config_and_disable(nn);
+
+	/* Step 3: Free resources
+	 */
+	nfp_net_close_free_all(nn);
+
+	nn_dbg(nn, "%s down", netdev->name);
+	return 0;
+}
+
+/**
  * nfp_net_open_stack() - Start the device from stack's perspective
  * @nn:      NFP Net device to reconfigure
  */
@@ -2377,76 +2447,6 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 	return err;
 }
 
-/**
- * nfp_net_close_stack() - Quiescent the stack (part of close)
- * @nn:	     NFP Net device to reconfigure
- */
-static void nfp_net_close_stack(struct nfp_net *nn)
-{
-	unsigned int r;
-
-	disable_irq(nn->irq_entries[NFP_NET_IRQ_LSC_IDX].vector);
-	netif_carrier_off(nn->dp.netdev);
-	nn->link_up = false;
-
-	for (r = 0; r < nn->dp.num_r_vecs; r++) {
-		disable_irq(nn->r_vecs[r].irq_vector);
-		napi_disable(&nn->r_vecs[r].napi);
-	}
-
-	netif_tx_disable(nn->dp.netdev);
-}
-
-/**
- * nfp_net_close_free_all() - Free all runtime resources
- * @nn:      NFP Net device to reconfigure
- */
-static void nfp_net_close_free_all(struct nfp_net *nn)
-{
-	unsigned int r;
-
-	for (r = 0; r < nn->dp.num_rx_rings; r++) {
-		nfp_net_rx_ring_bufs_free(&nn->dp, &nn->dp.rx_rings[r]);
-		nfp_net_rx_ring_free(&nn->dp.rx_rings[r]);
-	}
-	for (r = 0; r < nn->dp.num_tx_rings; r++) {
-		nfp_net_tx_ring_bufs_free(&nn->dp, &nn->dp.tx_rings[r]);
-		nfp_net_tx_ring_free(&nn->dp.tx_rings[r]);
-	}
-	for (r = 0; r < nn->dp.num_r_vecs; r++)
-		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
-
-	kfree(nn->dp.rx_rings);
-	kfree(nn->dp.tx_rings);
-
-	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
-	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
-}
-
-/**
- * nfp_net_netdev_close() - Called when the device is downed
- * @netdev:      netdev structure
- */
-static int nfp_net_netdev_close(struct net_device *netdev)
-{
-	struct nfp_net *nn = netdev_priv(netdev);
-
-	/* Step 1: Disable RX and TX rings from the Linux kernel perspective
-	 */
-	nfp_net_close_stack(nn);
-
-	/* Step 2: Tell NFP
-	 */
-	nfp_net_clear_config_and_disable(nn);
-
-	/* Step 3: Free resources
-	 */
-	nfp_net_close_free_all(nn);
-
-	nn_dbg(nn, "%s down", netdev->name);
-	return 0;
-}
-
 static void nfp_net_set_rx_mode(struct net_device *netdev)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
-- 
2.11.0
