From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 03/12] bnxt_en: Add pci shutdown method.
Date: Tue,  4 Apr 2017 18:14:08 -0400
Message-ID: <1491344057-12663-4-git-send-email-michael.chan@broadcom.com>
References: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37305 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755157AbdDDWOl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 18:14:41 -0400
Received: by mail-wm0-f47.google.com with SMTP id x124so39885040wmf.0
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 15:14:41 -0700 (PDT)
In-Reply-To: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add pci shutdown method to put device in the proper WoL and power state.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 70cc313..10a9cda 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7617,6 +7617,10 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto init_err_pci_clean;
 
 	bnxt_get_wol_settings(bp);
+	if (bp->flags & BNXT_FLAG_WOL_CAP)
+		device_set_wakeup_enable(&pdev->dev, bp->wol);
+	else
+		device_set_wakeup_capable(&pdev->dev, false);
 
 	rc = register_netdev(dev);
 	if (rc)
@@ -7641,6 +7645,32 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return rc;
 }
 
+static void bnxt_shutdown(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct bnxt *bp;
+
+	if (!dev)
+		return;
+
+	rtnl_lock();
+	bp = netdev_priv(dev);
+	if (!bp)
+		goto shutdown_exit;
+
+	if (netif_running(dev))
+		dev_close(dev);
+
+	if (system_state == SYSTEM_POWER_OFF) {
+		bnxt_clear_int_mode(bp);
+		pci_wake_from_d3(pdev, bp->wol);
+		pci_set_power_state(pdev, PCI_D3hot);
+	}
+
+shutdown_exit:
+	rtnl_unlock();
+}
+
 /**
  * bnxt_io_error_detected - called when PCI error is detected
  * @pdev: Pointer to PCI device
@@ -7757,6 +7787,7 @@ static void bnxt_io_resume(struct pci_dev *pdev)
 	.id_table	= bnxt_pci_tbl,
 	.probe		= bnxt_init_one,
 	.remove		= bnxt_remove_one,
+	.shutdown	= bnxt_shutdown,
 	.err_handler	= &bnxt_err_handler,
 #if defined(CONFIG_BNXT_SRIOV)
 	.sriov_configure = bnxt_sriov_configure,
-- 
1.8.3.1
