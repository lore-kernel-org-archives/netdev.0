From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net] nfp: use correct index to mask link state irq
Date: Thu, 16 Jun 2016 14:42:50 +0100
Message-ID: <1466084570-26549-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37729 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754221AbcFPNnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 09:43:17 -0400
Received: by mail-wm0-f49.google.com with SMTP id a66so58770755wme.0
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 06:43:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were using an incorrect define to get the irq vector number.
NFP_NET_CFG_LSC is a control BAR offset, LSC interrupt vector
index is called NFP_NET_IRQ_LSC_IDX.  For machines with less
than 30 CPUs this meant that we were disabling/enabling IRQ 0.
For bigger hosts we were just playing with the 31st RX/TX
interrupt.

Fixes: 0ba40af963f0 ("nfp: move link state interrupt request/free calls")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index fa47c14c743a..ba26bb356b8d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2015,7 +2015,7 @@ static void nfp_net_open_stack(struct nfp_net *nn)
 
 	netif_tx_wake_all_queues(nn->netdev);
 
-	enable_irq(nn->irq_entries[NFP_NET_CFG_LSC].vector);
+	enable_irq(nn->irq_entries[NFP_NET_IRQ_LSC_IDX].vector);
 	nfp_net_read_link_status(nn);
 }
 
@@ -2044,7 +2044,7 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 				      NFP_NET_IRQ_LSC_IDX, nn->lsc_handler);
 	if (err)
 		goto err_free_exn;
-	disable_irq(nn->irq_entries[NFP_NET_CFG_LSC].vector);
+	disable_irq(nn->irq_entries[NFP_NET_IRQ_LSC_IDX].vector);
 
 	nn->rx_rings = kcalloc(nn->num_rx_rings, sizeof(*nn->rx_rings),
 			       GFP_KERNEL);
@@ -2133,7 +2133,7 @@ static void nfp_net_close_stack(struct nfp_net *nn)
 {
 	unsigned int r;
 
-	disable_irq(nn->irq_entries[NFP_NET_CFG_LSC].vector);
+	disable_irq(nn->irq_entries[NFP_NET_IRQ_LSC_IDX].vector);
 	netif_carrier_off(nn->netdev);
 	nn->link_up = false;
 
-- 
1.9.1
