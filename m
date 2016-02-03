From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC (v3) 08/19] nfp: make *x_ring_init do all the init
Date: Wed,  3 Feb 2016 11:45:14 +0000
Message-ID: <1454499925-16359-9-git-send-email-jakub.kicinski@netronome.com>
References: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:33779 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932936AbcBCLpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 06:45:44 -0500
Received: by mail-wm0-f52.google.com with SMTP id l66so159538788wml.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 03:45:43 -0800 (PST)
In-Reply-To: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nfp_net_[rt]x_ring_init functions used to be called from probe
path only and some of their functionality was spilled to the
call site.  In order to reuse them for ring reconfiguration
we need them to do all the init.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 28 ++++++++++++++--------
 1 file changed, 18 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index d39ac3553e1e..8299d4c002fb 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -348,12 +348,18 @@ static irqreturn_t nfp_net_irq_exn(int irq, void *data)
 /**
  * nfp_net_tx_ring_init() - Fill in the boilerplate for a TX ring
  * @tx_ring:  TX ring structure
+ * @r_vec:    IRQ vector servicing this ring
+ * @idx:      Ring index
  */
-static void nfp_net_tx_ring_init(struct nfp_net_tx_ring *tx_ring)
+static void
+nfp_net_tx_ring_init(struct nfp_net_tx_ring *tx_ring,
+		     struct nfp_net_r_vector *r_vec, unsigned int idx)
 {
-	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
 	struct nfp_net *nn = r_vec->nfp_net;
 
+	tx_ring->idx = idx;
+	tx_ring->r_vec = r_vec;
+
 	tx_ring->qcidx = tx_ring->idx * nn->stride_tx;
 	tx_ring->qcp_q = nn->tx_bar + NFP_QCP_QUEUE_OFF(tx_ring->qcidx);
 }
@@ -361,12 +367,18 @@ static void nfp_net_tx_ring_init(struct nfp_net_tx_ring *tx_ring)
 /**
  * nfp_net_rx_ring_init() - Fill in the boilerplate for a RX ring
  * @rx_ring:  RX ring structure
+ * @r_vec:    IRQ vector servicing this ring
+ * @idx:      Ring index
  */
-static void nfp_net_rx_ring_init(struct nfp_net_rx_ring *rx_ring)
+static void
+nfp_net_rx_ring_init(struct nfp_net_rx_ring *rx_ring,
+		     struct nfp_net_r_vector *r_vec, unsigned int idx)
 {
-	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
 	struct nfp_net *nn = r_vec->nfp_net;
 
+	rx_ring->idx = idx;
+	rx_ring->r_vec = r_vec;
+
 	rx_ring->fl_qcidx = rx_ring->idx * nn->stride_rx;
 	rx_ring->rx_qcidx = rx_ring->fl_qcidx + (nn->stride_rx - 1);
 
@@ -404,14 +416,10 @@ static void nfp_net_irqs_assign(struct net_device *netdev)
 		cpumask_set_cpu(r, &r_vec->affinity_mask);
 
 		r_vec->tx_ring = &nn->tx_rings[r];
-		nn->tx_rings[r].idx = r;
-		nn->tx_rings[r].r_vec = r_vec;
-		nfp_net_tx_ring_init(r_vec->tx_ring);
+		nfp_net_tx_ring_init(r_vec->tx_ring, r_vec, r);
 
 		r_vec->rx_ring = &nn->rx_rings[r];
-		nn->rx_rings[r].idx = r;
-		nn->rx_rings[r].r_vec = r_vec;
-		nfp_net_rx_ring_init(r_vec->rx_ring);
+		nfp_net_rx_ring_init(r_vec->rx_ring, r_vec, r);
 	}
 }
 
-- 
1.9.1
