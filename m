From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 6/7] bnxt_en: Modify init sequence to support shared or non shared rings.
Date: Sat, 2 Jan 2016 23:45:03 -0500
Message-ID: <1451796304-23220-7-git-send-email-mchan@broadcom.com>
References: <1451796304-23220-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:14464 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbcACEpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2016 23:45:07 -0500
In-Reply-To: <1451796304-23220-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modify ring memory allocation and MSIX setup to support shared or
non shared rings and do the proper mapping.  Default is still to
use shared rings.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 42 +++++++++++++++++++++++--------
 1 file changed, 32 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 4f7b231..f956949 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2496,7 +2496,7 @@ static void bnxt_free_mem(struct bnxt *bp, bool irq_re_init)
 
 static int bnxt_alloc_mem(struct bnxt *bp, bool irq_re_init)
 {
-	int i, rc, size, arr_size;
+	int i, j, rc, size, arr_size;
 	void *bnapi;
 
 	if (irq_re_init) {
@@ -2535,9 +2535,14 @@ static int bnxt_alloc_mem(struct bnxt *bp, bool irq_re_init)
 		if (!bp->tx_ring)
 			return -ENOMEM;
 
-		for (i = 0; i < bp->tx_nr_rings; i++) {
-			bp->tx_ring[i].bnapi = bp->bnapi[i];
-			bp->bnapi[i]->tx_ring = &bp->tx_ring[i];
+		if (bp->flags & BNXT_FLAG_SHARED_RINGS)
+			j = 0;
+		else
+			j = bp->rx_nr_rings;
+
+		for (i = 0; i < bp->tx_nr_rings; i++, j++) {
+			bp->tx_ring[i].bnapi = bp->bnapi[j];
+			bp->bnapi[j]->tx_ring = &bp->tx_ring[i];
 		}
 
 		rc = bnxt_alloc_stats(bp);
@@ -4066,7 +4071,7 @@ static int bnxt_setup_msix(struct bnxt *bp)
 {
 	struct msix_entry *msix_ent;
 	struct net_device *dev = bp->dev;
-	int i, total_vecs, rc = 0;
+	int i, total_vecs, rc = 0, min = 1;
 	const int len = sizeof(bp->irq_tbl[0].name);
 
 	bp->flags &= ~BNXT_FLAG_USING_MSIX;
@@ -4081,7 +4086,10 @@ static int bnxt_setup_msix(struct bnxt *bp)
 		msix_ent[i].vector = 0;
 	}
 
-	total_vecs = pci_enable_msix_range(bp->pdev, msix_ent, 1, total_vecs);
+	if (!(bp->flags & BNXT_FLAG_SHARED_RINGS))
+		min = 2;
+
+	total_vecs = pci_enable_msix_range(bp->pdev, msix_ent, min, total_vecs);
 	if (total_vecs < 0) {
 		rc = -ENODEV;
 		goto msix_setup_exit;
@@ -4093,7 +4101,7 @@ static int bnxt_setup_msix(struct bnxt *bp)
 
 		/* Trim rings based upon num of vectors allocated */
 		rc = bnxt_trim_rings(bp, &bp->rx_nr_rings, &bp->tx_nr_rings,
-				     total_vecs, true);
+				     total_vecs, min == 1);
 		if (rc)
 			goto msix_setup_exit;
 
@@ -4115,12 +4123,21 @@ static int bnxt_setup_msix(struct bnxt *bp)
 				}
 			}
 		}
-		bp->cp_nr_rings = max_t(int, bp->rx_nr_rings, bp->tx_nr_rings);
+		bp->cp_nr_rings = total_vecs;
 
 		for (i = 0; i < bp->cp_nr_rings; i++) {
+			char *attr;
+
 			bp->irq_tbl[i].vector = msix_ent[i].vector;
+			if (bp->flags & BNXT_FLAG_SHARED_RINGS)
+				attr = "TxRx";
+			else if (i < bp->rx_nr_rings)
+				attr = "rx";
+			else
+				attr = "tx";
+
 			snprintf(bp->irq_tbl[i].name, len,
-				 "%s-%s-%d", dev->name, "TxRx", i);
+				 "%s-%s-%d", dev->name, attr, i);
 			bp->irq_tbl[i].handler = bnxt_msix;
 		}
 		rc = bnxt_set_real_num_queues(bp);
@@ -4158,6 +4175,7 @@ static int bnxt_setup_inta(struct bnxt *bp)
 	bp->tx_nr_rings = 1;
 	bp->cp_nr_rings = 1;
 	bp->tx_nr_rings_per_tc = bp->tx_nr_rings;
+	bp->flags |= BNXT_FLAG_SHARED_RINGS;
 	bp->irq_tbl[0].vector = bp->pdev->irq;
 	snprintf(bp->irq_tbl[0].name, len,
 		 "%s-%s-%d", bp->dev->name, "TxRx", 0);
@@ -5365,8 +5383,12 @@ static int bnxt_setup_tc(struct net_device *dev, u8 tc)
 
 	if (tc) {
 		int max_rx_rings, max_tx_rings, rc;
+		bool sh = false;
+
+		if (bp->flags & BNXT_FLAG_SHARED_RINGS)
+			sh = true;
 
-		rc = bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, true);
+		rc = bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, sh);
 		if (rc || bp->tx_nr_rings_per_tc * tc > max_tx_rings)
 			return -ENOMEM;
 	}
-- 
1.8.3.1
