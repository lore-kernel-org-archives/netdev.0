From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 12/14] nfp: remove nfp_net_irqs_wanted()
Date: Mon, 31 Oct 2016 20:43:20 +0000
Message-ID: <1477946602-19644-13-git-send-email-jakub.kicinski@netronome.com>
References: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37210 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034043AbcJaUoJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:44:09 -0400
Received: by mail-wm0-f54.google.com with SMTP id t79so72833535wmt.0
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 13:44:09 -0700 (PDT)
In-Reply-To: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nfp_net_irqs_wanted() doesn't really encapsulate much logic,
remove it and inline the calculations.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 27 ++++------------------
 1 file changed, 4 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 49a1f54e0787..f26c3927746f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -308,28 +308,6 @@ static int nfp_net_msix_alloc(struct nfp_net *nn, int nr_vecs)
 }
 
 /**
- * nfp_net_irqs_wanted() - Work out how many interrupt vectors we want
- * @nn:       NFP Network structure
- *
- * We want a vector per CPU (or ring), whatever is smaller plus
- * NFP_NET_NON_Q_VECTORS for LSC etc.
- *
- * Return: Number of interrupts wanted
- */
-static int nfp_net_irqs_wanted(struct nfp_net *nn)
-{
-	unsigned int vecs;
-	int ncpus;
-
-	ncpus = num_online_cpus();
-
-	vecs = max_t(int, nn->num_tx_rings, nn->num_rx_rings);
-	vecs = min_t(int, vecs, ncpus);
-
-	return vecs + NFP_NET_NON_Q_VECTORS;
-}
-
-/**
  * nfp_net_irqs_alloc() - allocates MSI-X irqs
  * @nn:       NFP Network structure
  *
@@ -339,7 +317,7 @@ int nfp_net_irqs_alloc(struct nfp_net *nn)
 {
 	int wanted_irqs;
 
-	wanted_irqs = nfp_net_irqs_wanted(nn);
+	wanted_irqs = nn->num_r_vecs + NFP_NET_NON_Q_VECTORS;
 
 	nn->num_irqs = nfp_net_msix_alloc(nn, wanted_irqs);
 	if (nn->num_irqs == 0) {
@@ -2726,6 +2704,9 @@ struct nfp_net *nfp_net_netdev_alloc(struct pci_dev *pdev,
 	nn->num_tx_rings = min_t(int, nqs, max_tx_rings);
 	nn->num_rx_rings = min_t(int, nqs, max_rx_rings);
 
+	nn->num_r_vecs = max(nn->num_tx_rings, nn->num_rx_rings);
+	nn->num_r_vecs = min_t(unsigned int, nn->num_r_vecs, num_online_cpus());
+
 	nn->txd_cnt = NFP_NET_TX_DESCS_DEFAULT;
 	nn->rxd_cnt = NFP_NET_RX_DESCS_DEFAULT;
 
-- 
1.9.1
