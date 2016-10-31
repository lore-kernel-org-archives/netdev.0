From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 13/14] nfp: replace num_irqs with max_r_vecs
Date: Mon, 31 Oct 2016 20:43:21 +0000
Message-ID: <1477946602-19644-14-git-send-email-jakub.kicinski@netronome.com>
References: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35402 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034099AbcJaUoK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:44:10 -0400
Received: by mail-wm0-f49.google.com with SMTP id a197so43040013wmd.0
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 13:44:10 -0700 (PDT)
In-Reply-To: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

num_irqs is not used anywhere, replace it with max_r_vecs which holds
number of allocated RX/TX vectors and is going to be useful soon.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h        |  4 ++--
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 14 ++++++++------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 0ea6ebd329cf..e8713254786b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -456,7 +456,7 @@ struct nfp_stat_pair {
  * @rxd_cnt:            Size of the RX ring in number of descriptors
  * @tx_rings:           Array of pre-allocated TX ring structures
  * @rx_rings:           Array of pre-allocated RX ring structures
- * @num_irqs:	        Number of allocated interrupt vectors
+ * @max_r_vecs:	        Number of allocated interrupt vectors for RX/TX
  * @num_r_vecs:         Number of used ring vectors
  * @r_vecs:             Pre-allocated array of ring vectors
  * @irq_entries:        Pre-allocated array of MSI-X entries
@@ -540,7 +540,7 @@ struct nfp_net {
 	int txd_cnt;
 	int rxd_cnt;
 
-	unsigned int num_irqs;
+	unsigned int max_r_vecs;
 	unsigned int num_r_vecs;
 	struct nfp_net_r_vector r_vecs[NFP_NET_MAX_R_VECS];
 	struct msix_entry irq_entries[NFP_NET_MAX_IRQS];
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index f26c3927746f..4b866fc874b6 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -316,22 +316,24 @@ static int nfp_net_msix_alloc(struct nfp_net *nn, int nr_vecs)
 int nfp_net_irqs_alloc(struct nfp_net *nn)
 {
 	int wanted_irqs;
+	unsigned int n;
 
 	wanted_irqs = nn->num_r_vecs + NFP_NET_NON_Q_VECTORS;
 
-	nn->num_irqs = nfp_net_msix_alloc(nn, wanted_irqs);
-	if (nn->num_irqs == 0) {
+	n = nfp_net_msix_alloc(nn, wanted_irqs);
+	if (n == 0) {
 		nn_err(nn, "Failed to allocate MSI-X IRQs\n");
 		return 0;
 	}
 
-	nn->num_r_vecs = nn->num_irqs - NFP_NET_NON_Q_VECTORS;
+	nn->max_r_vecs = n - NFP_NET_NON_Q_VECTORS;
+	nn->num_r_vecs = nn->max_r_vecs;
 
-	if (nn->num_irqs < wanted_irqs)
+	if (n < wanted_irqs)
 		nn_warn(nn, "Unable to allocate %d vectors. Got %d instead\n",
-			wanted_irqs, nn->num_irqs);
+			wanted_irqs, n);
 
-	return nn->num_irqs;
+	return n;
 }
 
 /**
-- 
1.9.1
