From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 06/12] bnxt_en: Add suspend/resume callbacks.
Date: Tue,  4 Apr 2017 18:14:11 -0400
Message-ID: <1491344057-12663-7-git-send-email-michael.chan@broadcom.com>
References: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35536 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755173AbdDDWOr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 18:14:47 -0400
Received: by mail-wm0-f53.google.com with SMTP id y22so36451462wmh.0
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 15:14:46 -0700 (PDT)
In-Reply-To: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add suspend/resume callbacks using the newer dev_pm_ops method.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 57 +++++++++++++++++++++++++++++++
 1 file changed, 57 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index e432d0a..4e77bbf 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7703,6 +7703,62 @@ static void bnxt_shutdown(struct pci_dev *pdev)
 	rtnl_unlock();
 }
 
+#ifdef CONFIG_PM_SLEEP
+static int bnxt_suspend(struct device *device)
+{
+	struct pci_dev *pdev = to_pci_dev(device);
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct bnxt *bp = netdev_priv(dev);
+	int rc = 0;
+
+	rtnl_lock();
+	if (netif_running(dev)) {
+		netif_device_detach(dev);
+		rc = bnxt_close(dev);
+	}
+	bnxt_hwrm_func_drv_unrgtr(bp);
+	rtnl_unlock();
+	return rc;
+}
+
+static int bnxt_resume(struct device *device)
+{
+	struct pci_dev *pdev = to_pci_dev(device);
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct bnxt *bp = netdev_priv(dev);
+	int rc = 0;
+
+	rtnl_lock();
+	if (bnxt_hwrm_ver_get(bp) || bnxt_hwrm_func_drv_rgtr(bp)) {
+		rc = -ENODEV;
+		goto resume_exit;
+	}
+	rc = bnxt_hwrm_func_reset(bp);
+	if (rc) {
+		rc = -EBUSY;
+		goto resume_exit;
+	}
+	bnxt_get_wol_settings(bp);
+	if (netif_running(dev)) {
+		rc = bnxt_open(dev);
+		if (!rc)
+			netif_device_attach(dev);
+	}
+
+resume_exit:
+	rtnl_unlock();
+	return rc;
+}
+
+static SIMPLE_DEV_PM_OPS(bnxt_pm_ops, bnxt_suspend, bnxt_resume);
+#define BNXT_PM_OPS (&bnxt_pm_ops)
+
+#else
+
+#define BNXT_PM_OPS NULL
+
+#endif /* CONFIG_PM_SLEEP */
+
 /**
  * bnxt_io_error_detected - called when PCI error is detected
  * @pdev: Pointer to PCI device
@@ -7820,6 +7876,7 @@ static void bnxt_io_resume(struct pci_dev *pdev)
 	.probe		= bnxt_init_one,
 	.remove		= bnxt_remove_one,
 	.shutdown	= bnxt_shutdown,
+	.driver.pm	= BNXT_PM_OPS,
 	.err_handler	= &bnxt_err_handler,
 #if defined(CONFIG_BNXT_SRIOV)
 	.sriov_configure = bnxt_sriov_configure,
-- 
1.8.3.1
