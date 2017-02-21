From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 3/3] bnxt_en: fix pci cleanup in bnxt_init_one() failure path
Date: Mon, 20 Feb 2017 19:25:18 -0500
Message-ID: <1487636718-21293-4-git-send-email-michael.chan@broadcom.com>
References: <1487636718-21293-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:35071 "EHLO
        mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751049AbdBUAZi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 19:25:38 -0500
Received: by mail-qt0-f176.google.com with SMTP id x35so25996783qtc.2
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 16:25:37 -0800 (PST)
In-Reply-To: <1487636718-21293-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@broadcom.com>

In the bnxt_init_one() failure path, bar1 and bar2 are not
being unmapped.  This commit fixes this issue.  Reorganize the
code so that bnxt_init_one()'s failure path and bnxt_remove_one()
can call the same function to do the PCI cleanup.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 76 ++++++++++++++++---------------
 1 file changed, 39 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 37b9f65..6dacdf1 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6676,6 +6676,31 @@ int bnxt_reserve_rings(struct bnxt *bp, int tx, int rx, int tcs, int tx_xdp)
 	return 0;
 }
 
+static void bnxt_unmap_bars(struct bnxt *bp, struct pci_dev *pdev)
+{
+	if (bp->bar2) {
+		pci_iounmap(pdev, bp->bar2);
+		bp->bar2 = NULL;
+	}
+
+	if (bp->bar1) {
+		pci_iounmap(pdev, bp->bar1);
+		bp->bar1 = NULL;
+	}
+
+	if (bp->bar0) {
+		pci_iounmap(pdev, bp->bar0);
+		bp->bar0 = NULL;
+	}
+}
+
+static void bnxt_cleanup_pci(struct bnxt *bp)
+{
+	bnxt_unmap_bars(bp, bp->pdev);
+	pci_release_regions(bp->pdev);
+	pci_disable_device(bp->pdev);
+}
+
 static int bnxt_init_board(struct pci_dev *pdev, struct net_device *dev)
 {
 	int rc;
@@ -6763,25 +6788,10 @@ static int bnxt_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->current_interval = BNXT_TIMER_INTERVAL;
 
 	clear_bit(BNXT_STATE_OPEN, &bp->state);
-
 	return 0;
 
 init_err_release:
-	if (bp->bar2) {
-		pci_iounmap(pdev, bp->bar2);
-		bp->bar2 = NULL;
-	}
-
-	if (bp->bar1) {
-		pci_iounmap(pdev, bp->bar1);
-		bp->bar1 = NULL;
-	}
-
-	if (bp->bar0) {
-		pci_iounmap(pdev, bp->bar0);
-		bp->bar0 = NULL;
-	}
-
+	bnxt_unmap_bars(bp, pdev);
 	pci_release_regions(pdev);
 
 init_err_disable:
@@ -7186,17 +7196,12 @@ static void bnxt_remove_one(struct pci_dev *pdev)
 	bnxt_hwrm_func_drv_unrgtr(bp);
 	bnxt_free_hwrm_resources(bp);
 	bnxt_dcb_free(bp);
-	pci_iounmap(pdev, bp->bar2);
-	pci_iounmap(pdev, bp->bar1);
-	pci_iounmap(pdev, bp->bar0);
 	kfree(bp->edev);
 	bp->edev = NULL;
 	if (bp->xdp_prog)
 		bpf_prog_put(bp->xdp_prog);
+	bnxt_cleanup_pci(bp);
 	free_netdev(dev);
-
-	pci_release_regions(pdev);
-	pci_disable_device(pdev);
 }
 
 static int bnxt_probe_phy(struct bnxt *bp)
@@ -7428,17 +7433,16 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->netdev_ops = &bnxt_netdev_ops;
 	dev->watchdog_timeo = BNXT_TX_TIMEOUT;
 	dev->ethtool_ops = &bnxt_ethtool_ops;
-
 	pci_set_drvdata(pdev, dev);
 
 	rc = bnxt_alloc_hwrm_resources(bp);
 	if (rc)
-		goto init_err;
+		goto init_err_pci_clean;
 
 	mutex_init(&bp->hwrm_cmd_lock);
 	rc = bnxt_hwrm_ver_get(bp);
 	if (rc)
-		goto init_err;
+		goto init_err_pci_clean;
 
 	bnxt_hwrm_fw_set_time(bp);
 
@@ -7482,11 +7486,11 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rc = bnxt_hwrm_func_drv_rgtr(bp);
 	if (rc)
-		goto init_err;
+		goto init_err_pci_clean;
 
 	rc = bnxt_hwrm_func_rgtr_async_events(bp, NULL, 0);
 	if (rc)
-		goto init_err;
+		goto init_err_pci_clean;
 
 	bp->ulp_probe = bnxt_ulp_probe;
 
@@ -7496,7 +7500,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netdev_err(bp->dev, "hwrm query capability failure rc: %x\n",
 			   rc);
 		rc = -1;
-		goto init_err;
+		goto init_err_pci_clean;
 	}
 
 	rc = bnxt_hwrm_queue_qportcfg(bp);
@@ -7504,7 +7508,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netdev_err(bp->dev, "hwrm query qportcfg failure rc: %x\n",
 			   rc);
 		rc = -1;
-		goto init_err;
+		goto init_err_pci_clean;
 	}
 
 	bnxt_hwrm_func_qcfg(bp);
@@ -7518,7 +7522,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rc) {
 		netdev_err(bp->dev, "Not enough rings available.\n");
 		rc = -ENOMEM;
-		goto init_err;
+		goto init_err_pci_clean;
 	}
 
 	/* Default RSS hash cfg. */
@@ -7548,15 +7552,15 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rc = bnxt_probe_phy(bp);
 	if (rc)
-		goto init_err;
+		goto init_err_pci_clean;
 
 	rc = bnxt_hwrm_func_reset(bp);
 	if (rc)
-		goto init_err;
+		goto init_err_pci_clean;
 
 	rc = bnxt_init_int_mode(bp);
 	if (rc)
-		goto init_err;
+		goto init_err_pci_clean;
 
 	rc = register_netdev(dev);
 	if (rc)
@@ -7573,10 +7577,8 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 init_err_clr_int:
 	bnxt_clear_int_mode(bp);
 
-init_err:
-	pci_iounmap(pdev, bp->bar0);
-	pci_release_regions(pdev);
-	pci_disable_device(pdev);
+init_err_pci_clean:
+	bnxt_cleanup_pci(bp);
 
 init_err_free:
 	free_netdev(dev);
-- 
1.8.3.1
