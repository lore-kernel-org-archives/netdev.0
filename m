From: Michael Chan <michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 2/7] bnxt_en: Enable MSIX early in bnxt_init_one().
Date: Tue,  6 Dec 2016 12:09:33 -0500
Message-ID: <1481044178-25193-3-git-send-email-michael.chan@broadcom.com>
References: <1481044178-25193-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481044178-25193-1-git-send-email-michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

To better support the new RDMA driver, we need to move pci_enable_msix()
from bnxt_open() to bnxt_init_one().  This way, MSIX vectors are available
to the RDMA driver whether the network device is up or down.

Part of the existing bnxt_setup_int_mode() function is now refactored into
a new bnxt_init_int_mode().  bnxt_init_int_mode() is called during
bnxt_init_one() to enable MSIX.  The remaining logic in
bnxt_setup_int_mode() to map the IRQs to the completion rings is called
during bnxt_open().

Signed-off-by: Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Michael Chan <michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 183 +++++++++++++++++++-----------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |   1 +
 2 files changed, 115 insertions(+), 69 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 6cdfe3e..9178bf8 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4743,6 +4743,80 @@ static int bnxt_trim_rings(struct bnxt *bp, int *rx, int *tx, int max,
 	return 0;
 }
 
+static void bnxt_setup_msix(struct bnxt *bp)
+{
+	const int len = sizeof(bp->irq_tbl[0].name);
+	struct net_device *dev = bp->dev;
+	int tcs, i;
+
+	tcs = netdev_get_num_tc(dev);
+	if (tcs > 1) {
+		bp->tx_nr_rings_per_tc = bp->tx_nr_rings / tcs;
+		if (bp->tx_nr_rings_per_tc == 0) {
+			netdev_reset_tc(dev);
+			bp->tx_nr_rings_per_tc = bp->tx_nr_rings;
+		} else {
+			int i, off, count;
+
+			bp->tx_nr_rings = bp->tx_nr_rings_per_tc * tcs;
+			for (i = 0; i < tcs; i++) {
+				count = bp->tx_nr_rings_per_tc;
+				off = i * count;
+				netdev_set_tc_queue(dev, i, count, off);
+			}
+		}
+	}
+
+	for (i = 0; i < bp->cp_nr_rings; i++) {
+		char *attr;
+
+		if (bp->flags & BNXT_FLAG_SHARED_RINGS)
+			attr = "TxRx";
+		else if (i < bp->rx_nr_rings)
+			attr = "rx";
+		else
+			attr = "tx";
+
+		snprintf(bp->irq_tbl[i].name, len, "%s-%s-%d", dev->name, attr,
+			 i);
+		bp->irq_tbl[i].handler = bnxt_msix;
+	}
+}
+
+static void bnxt_setup_inta(struct bnxt *bp)
+{
+	const int len = sizeof(bp->irq_tbl[0].name);
+
+	if (netdev_get_num_tc(bp->dev))
+		netdev_reset_tc(bp->dev);
+
+	snprintf(bp->irq_tbl[0].name, len, "%s-%s-%d", bp->dev->name, "TxRx",
+		 0);
+	bp->irq_tbl[0].handler = bnxt_inta;
+}
+
+static int bnxt_setup_int_mode(struct bnxt *bp)
+{
+	int rc;
+
+	if (bp->flags & BNXT_FLAG_USING_MSIX)
+		bnxt_setup_msix(bp);
+	else
+		bnxt_setup_inta(bp);
+
+	rc = bnxt_set_real_num_queues(bp);
+	return rc;
+}
+
+static unsigned int bnxt_get_max_func_irqs(struct bnxt *bp)
+{
+	if (BNXT_PF(bp))
+		return bp->pf.max_irqs;
+#if defined(CONFIG_BNXT_SRIOV)
+	return bp->vf.max_irqs;
+#endif
+}
+
 void bnxt_set_max_func_irqs(struct bnxt *bp, unsigned int max_irqs)
 {
 	if (BNXT_PF(bp))
@@ -4753,16 +4827,12 @@ void bnxt_set_max_func_irqs(struct bnxt *bp, unsigned int max_irqs)
 #endif
 }
 
-static int bnxt_setup_msix(struct bnxt *bp)
+static int bnxt_init_msix(struct bnxt *bp)
 {
-	struct msix_entry *msix_ent;
-	struct net_device *dev = bp->dev;
 	int i, total_vecs, rc = 0, min = 1;
-	const int len = sizeof(bp->irq_tbl[0].name);
-
-	bp->flags &= ~BNXT_FLAG_USING_MSIX;
-	total_vecs = bp->cp_nr_rings;
+	struct msix_entry *msix_ent;
 
+	total_vecs = bnxt_get_max_func_irqs(bp);
 	msix_ent = kcalloc(total_vecs, sizeof(struct msix_entry), GFP_KERNEL);
 	if (!msix_ent)
 		return -ENOMEM;
@@ -4783,8 +4853,10 @@ static int bnxt_setup_msix(struct bnxt *bp)
 
 	bp->irq_tbl = kcalloc(total_vecs, sizeof(struct bnxt_irq), GFP_KERNEL);
 	if (bp->irq_tbl) {
-		int tcs;
+		for (i = 0; i < total_vecs; i++)
+			bp->irq_tbl[i].vector = msix_ent[i].vector;
 
+		bp->total_irqs = total_vecs;
 		/* Trim rings based upon num of vectors allocated */
 		rc = bnxt_trim_rings(bp, &bp->rx_nr_rings, &bp->tx_nr_rings,
 				     total_vecs, min == 1);
@@ -4792,43 +4864,10 @@ static int bnxt_setup_msix(struct bnxt *bp)
 			goto msix_setup_exit;
 
 		bp->tx_nr_rings_per_tc = bp->tx_nr_rings;
-		tcs = netdev_get_num_tc(dev);
-		if (tcs > 1) {
-			bp->tx_nr_rings_per_tc = bp->tx_nr_rings / tcs;
-			if (bp->tx_nr_rings_per_tc == 0) {
-				netdev_reset_tc(dev);
-				bp->tx_nr_rings_per_tc = bp->tx_nr_rings;
-			} else {
-				int i, off, count;
+		bp->cp_nr_rings = (min == 1) ?
+				  max_t(int, bp->tx_nr_rings, bp->rx_nr_rings) :
+				  bp->tx_nr_rings + bp->rx_nr_rings;
 
-				bp->tx_nr_rings = bp->tx_nr_rings_per_tc * tcs;
-				for (i = 0; i < tcs; i++) {
-					count = bp->tx_nr_rings_per_tc;
-					off = i * count;
-					netdev_set_tc_queue(dev, i, count, off);
-				}
-			}
-		}
-		bp->cp_nr_rings = total_vecs;
-
-		for (i = 0; i < bp->cp_nr_rings; i++) {
-			char *attr;
-
-			bp->irq_tbl[i].vector = msix_ent[i].vector;
-			if (bp->flags & BNXT_FLAG_SHARED_RINGS)
-				attr = "TxRx";
-			else if (i < bp->rx_nr_rings)
-				attr = "rx";
-			else
-				attr = "tx";
-
-			snprintf(bp->irq_tbl[i].name, len,
-				 "%s-%s-%d", dev->name, attr, i);
-			bp->irq_tbl[i].handler = bnxt_msix;
-		}
-		rc = bnxt_set_real_num_queues(bp);
-		if (rc)
-			goto msix_setup_exit;
 	} else {
 		rc = -ENOMEM;
 		goto msix_setup_exit;
@@ -4838,52 +4877,54 @@ static int bnxt_setup_msix(struct bnxt *bp)
 	return 0;
 
 msix_setup_exit:
-	netdev_err(bp->dev, "bnxt_setup_msix err: %x\n", rc);
+	netdev_err(bp->dev, "bnxt_init_msix err: %x\n", rc);
+	kfree(bp->irq_tbl);
+	bp->irq_tbl = NULL;
 	pci_disable_msix(bp->pdev);
 	kfree(msix_ent);
 	return rc;
 }
 
-static int bnxt_setup_inta(struct bnxt *bp)
+static int bnxt_init_inta(struct bnxt *bp)
 {
-	int rc;
-	const int len = sizeof(bp->irq_tbl[0].name);
-
-	if (netdev_get_num_tc(bp->dev))
-		netdev_reset_tc(bp->dev);
-
 	bp->irq_tbl = kcalloc(1, sizeof(struct bnxt_irq), GFP_KERNEL);
-	if (!bp->irq_tbl) {
-		rc = -ENOMEM;
-		return rc;
-	}
+	if (!bp->irq_tbl)
+		return -ENOMEM;
+
+	bp->total_irqs = 1;
 	bp->rx_nr_rings = 1;
 	bp->tx_nr_rings = 1;
 	bp->cp_nr_rings = 1;
 	bp->tx_nr_rings_per_tc = bp->tx_nr_rings;
 	bp->flags |= BNXT_FLAG_SHARED_RINGS;
 	bp->irq_tbl[0].vector = bp->pdev->irq;
-	snprintf(bp->irq_tbl[0].name, len,
-		 "%s-%s-%d", bp->dev->name, "TxRx", 0);
-	bp->irq_tbl[0].handler = bnxt_inta;
-	rc = bnxt_set_real_num_queues(bp);
-	return rc;
+	return 0;
 }
 
-static int bnxt_setup_int_mode(struct bnxt *bp)
+static int bnxt_init_int_mode(struct bnxt *bp)
 {
 	int rc = 0;
 
 	if (bp->flags & BNXT_FLAG_MSIX_CAP)
-		rc = bnxt_setup_msix(bp);
+		rc = bnxt_init_msix(bp);
 
 	if (!(bp->flags & BNXT_FLAG_USING_MSIX) && BNXT_PF(bp)) {
 		/* fallback to INTA */
-		rc = bnxt_setup_inta(bp);
+		rc = bnxt_init_inta(bp);
 	}
 	return rc;
 }
 
+static void bnxt_clear_int_mode(struct bnxt *bp)
+{
+	if (bp->flags & BNXT_FLAG_USING_MSIX)
+		pci_disable_msix(bp->pdev);
+
+	kfree(bp->irq_tbl);
+	bp->irq_tbl = NULL;
+	bp->flags &= ~BNXT_FLAG_USING_MSIX;
+}
+
 static void bnxt_free_irq(struct bnxt *bp)
 {
 	struct bnxt_irq *irq;
@@ -4902,10 +4943,6 @@ static void bnxt_free_irq(struct bnxt *bp)
 			free_irq(irq->vector, bp->bnapi[i]);
 		irq->requested = 0;
 	}
-	if (bp->flags & BNXT_FLAG_USING_MSIX)
-		pci_disable_msix(bp->pdev);
-	kfree(bp->irq_tbl);
-	bp->irq_tbl = NULL;
 }
 
 static int bnxt_request_irq(struct bnxt *bp)
@@ -6695,6 +6732,7 @@ static void bnxt_remove_one(struct pci_dev *pdev)
 	cancel_work_sync(&bp->sp_task);
 	bp->sp_event = 0;
 
+	bnxt_clear_int_mode(bp);
 	bnxt_hwrm_func_drv_unrgtr(bp);
 	bnxt_free_hwrm_resources(bp);
 	bnxt_dcb_free(bp);
@@ -6990,10 +7028,14 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rc)
 		goto init_err;
 
-	rc = register_netdev(dev);
+	rc = bnxt_init_int_mode(bp);
 	if (rc)
 		goto init_err;
 
+	rc = register_netdev(dev);
+	if (rc)
+		goto init_err_clr_int;
+
 	netdev_info(dev, "%s found at mem %lx, node addr %pM\n",
 		    board_info[ent->driver_data].name,
 		    (long)pci_resource_start(pdev, 0), dev->dev_addr);
@@ -7002,6 +7044,9 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	return 0;
 
+init_err_clr_int:
+	bnxt_clear_int_mode(bp);
+
 init_err:
 	pci_iounmap(pdev, bp->bar0);
 	pci_release_regions(pdev);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 8327d0d..1461355 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1024,6 +1024,7 @@ struct bnxt {
 #define BNXT_STATE_FN_RST_DONE	2
 
 	struct bnxt_irq	*irq_tbl;
+	int			total_irqs;
 	u8			mac_addr[ETH_ALEN];
 
 #ifdef CONFIG_BNXT_DCB
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
