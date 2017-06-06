From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 02/16] nfp: split out the allocation part of open
Date: Mon,  5 Jun 2017 17:01:43 -0700
Message-ID: <20170606000157.17556-3-jakub.kicinski@netronome.com>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33270 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751192AbdFFACQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 20:02:16 -0400
Received: by mail-pf0-f169.google.com with SMTP id 83so32351216pfr.0
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 17:02:16 -0700 (PDT)
In-Reply-To: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Our open/close implementations have 3 stages:
 - allocation/freeing of ring resources, irqs etc.,
 - device config,
 - device/stack enable (can't fail).

Right now all of those stages are placed in separate functions,
apart from allocation during open.  Fix that.  It will make it
easier for us to allocate resources for netdev-less vNICs.
Because we want to reuse allocation code in netdev-less vNICs
leave the netif_set_real_num_[rt]x_queues() calls inside open.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 57 +++++++++++++---------
 1 file changed, 35 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 770ef28c0380..bec51f4a9299 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2364,16 +2364,10 @@ static void nfp_net_open_stack(struct nfp_net *nn)
 	nfp_net_read_link_status(nn);
 }
 
-static int nfp_net_netdev_open(struct net_device *netdev)
+static int nfp_net_open_alloc_all(struct nfp_net *nn)
 {
-	struct nfp_net *nn = netdev_priv(netdev);
 	int err, r;
 
-	/* Step 1: Allocate resources for rings and the like
-	 * - Request interrupts
-	 * - Allocate RX and TX ring resources
-	 * - Setup initial RSS table
-	 */
 	err = nfp_net_aux_irq_request(nn, NFP_NET_CFG_EXN, "%s-exn",
 				      nn->exn_name, sizeof(nn->exn_name),
 				      NFP_NET_IRQ_EXN_IDX, nn->exn_handler);
@@ -2403,13 +2397,42 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 	for (r = 0; r < nn->max_r_vecs; r++)
 		nfp_net_vector_assign_rings(&nn->dp, &nn->r_vecs[r], r);
 
+	return 0;
+
+err_free_rx_rings:
+	nfp_net_rx_rings_free(&nn->dp);
+err_cleanup_vec:
+	r = nn->dp.num_r_vecs;
+err_cleanup_vec_p:
+	while (r--)
+		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
+	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
+err_free_exn:
+	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
+	return err;
+}
+
+static int nfp_net_netdev_open(struct net_device *netdev)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	int err;
+
+	/* Step 1: Allocate resources for rings and the like
+	 * - Request interrupts
+	 * - Allocate RX and TX ring resources
+	 * - Setup initial RSS table
+	 */
+	err = nfp_net_open_alloc_all(nn);
+	if (err)
+		return err;
+
 	err = netif_set_real_num_tx_queues(netdev, nn->dp.num_stack_tx_rings);
 	if (err)
-		goto err_free_rings;
+		goto err_free_all;
 
 	err = netif_set_real_num_rx_queues(netdev, nn->dp.num_rx_rings);
 	if (err)
-		goto err_free_rings;
+		goto err_free_all;
 
 	/* Step 2: Configure the NFP
 	 * - Enable rings from 0 to tx_rings/rx_rings - 1.
@@ -2420,7 +2443,7 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 	 */
 	err = nfp_net_set_config_and_enable(nn);
 	if (err)
-		goto err_free_rings;
+		goto err_free_all;
 
 	/* Step 3: Enable for kernel
 	 * - put some freelist descriptors on each RX ring
@@ -2432,18 +2455,8 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 
 	return 0;
 
-err_free_rings:
-	nfp_net_tx_rings_free(&nn->dp);
-err_free_rx_rings:
-	nfp_net_rx_rings_free(&nn->dp);
-err_cleanup_vec:
-	r = nn->dp.num_r_vecs;
-err_cleanup_vec_p:
-	while (r--)
-		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
-	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
-err_free_exn:
-	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
+err_free_all:
+	nfp_net_close_free_all(nn);
 	return err;
 }
 
-- 
2.11.0
