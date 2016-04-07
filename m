From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH v5 net-next 02/15] nfp: move link state interrupt request/free calls
Date: Thu,  7 Apr 2016 19:39:35 +0100
Message-ID: <1460054388-471-3-git-send-email-jakub.kicinski@netronome.com>
References: <1460054388-471-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:33150 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757077AbcDGSkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 14:40:21 -0400
Received: by mail-qg0-f54.google.com with SMTP id j35so71149258qge.0
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 11:40:21 -0700 (PDT)
In-Reply-To: <1460054388-471-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to be able to disable the link state interrupt when
the device is brought down.  We used to just free the IRQ
at the beginning of .ndo_stop().  As we now move towards
more ordered .ndo_open()/.ndo_stop() paths LSC allocation
should be placed in the "allocate resource" section.

Since the IRQ can't be freed early in .ndo_stop(), it is
disabled instead.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 23 +++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 0dae81454e77..5da1199e7afb 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1729,10 +1729,16 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 				      NFP_NET_IRQ_EXN_IDX, nn->exn_handler);
 	if (err)
 		return err;
+	err = nfp_net_aux_irq_request(nn, NFP_NET_CFG_LSC, "%s-lsc",
+				      nn->lsc_name, sizeof(nn->lsc_name),
+				      NFP_NET_IRQ_LSC_IDX, nn->lsc_handler);
+	if (err)
+		goto err_free_exn;
+	disable_irq(nn->irq_entries[NFP_NET_CFG_LSC].vector);
 
 	err = nfp_net_alloc_rings(nn);
 	if (err)
-		goto err_free_exn;
+		goto err_free_lsc;
 
 	err = netif_set_real_num_tx_queues(netdev, nn->num_tx_rings);
 	if (err)
@@ -1812,19 +1818,11 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 
 	netif_tx_wake_all_queues(netdev);
 
-	err = nfp_net_aux_irq_request(nn, NFP_NET_CFG_LSC, "%s-lsc",
-				      nn->lsc_name, sizeof(nn->lsc_name),
-				      NFP_NET_IRQ_LSC_IDX, nn->lsc_handler);
-	if (err)
-		goto err_stop_tx;
+	enable_irq(nn->irq_entries[NFP_NET_CFG_LSC].vector);
 	nfp_net_read_link_status(nn);
 
 	return 0;
 
-err_stop_tx:
-	netif_tx_disable(netdev);
-	for (r = 0; r < nn->num_r_vecs; r++)
-		nfp_net_tx_flush(nn->r_vecs[r].tx_ring);
 err_disable_napi:
 	while (r--) {
 		napi_disable(&nn->r_vecs[r].napi);
@@ -1834,6 +1832,8 @@ err_clear_config:
 	nfp_net_clear_config_and_disable(nn);
 err_free_rings:
 	nfp_net_free_rings(nn);
+err_free_lsc:
+	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
 err_free_exn:
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
 	return err;
@@ -1855,7 +1855,7 @@ static int nfp_net_netdev_close(struct net_device *netdev)
 
 	/* Step 1: Disable RX and TX rings from the Linux kernel perspective
 	 */
-	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
+	disable_irq(nn->irq_entries[NFP_NET_CFG_LSC].vector);
 	netif_carrier_off(netdev);
 	nn->link_up = false;
 
@@ -1876,6 +1876,7 @@ static int nfp_net_netdev_close(struct net_device *netdev)
 	}
 
 	nfp_net_free_rings(nn);
+	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
 
 	nn_dbg(nn, "%s down", netdev->name);
-- 
1.9.1
