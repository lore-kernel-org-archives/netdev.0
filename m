From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC (v3) 06/19] nfp: move link state interrupt request/free calls
Date: Wed,  3 Feb 2016 11:45:12 +0000
Message-ID: <1454499925-16359-7-git-send-email-jakub.kicinski@netronome.com>
References: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:33744 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932782AbcBCLpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 06:45:42 -0500
Received: by mail-wm0-f54.google.com with SMTP id l66so159537635wml.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 03:45:41 -0800 (PST)
In-Reply-To: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
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
index 070645f9bc21..bebdae80ccda 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1727,10 +1727,16 @@ static int nfp_net_netdev_open(struct net_device *netdev)
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
@@ -1810,19 +1816,11 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 
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
@@ -1832,6 +1830,8 @@ err_clear_config:
 	nfp_net_clear_config_and_disable(nn);
 err_free_rings:
 	nfp_net_free_rings(nn);
+err_free_lsc:
+	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
 err_free_exn:
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
 	return err;
@@ -1853,7 +1853,7 @@ static int nfp_net_netdev_close(struct net_device *netdev)
 
 	/* Step 1: Disable RX and TX rings from the Linux kernel perspective
 	 */
-	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
+	disable_irq(nn->irq_entries[NFP_NET_CFG_LSC].vector);
 	netif_carrier_off(netdev);
 	nn->link_up = false;
 
@@ -1874,6 +1874,7 @@ static int nfp_net_netdev_close(struct net_device *netdev)
 	}
 
 	nfp_net_free_rings(nn);
+	nfp_net_aux_irq_free(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
 	nfp_net_aux_irq_free(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
 
 	nn_dbg(nn, "%s down", netdev->name);
-- 
1.9.1
