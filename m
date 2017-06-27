From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 12/14] nfp: reorder SR-IOV config and nfp_app SR-IOV callbacks
Date: Tue, 27 Jun 2017 00:50:26 -0700
Message-ID: <20170627075028.4009-13-jakub.kicinski@netronome.com>
References: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35259 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751658AbdF0Hv1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 03:51:27 -0400
Received: by mail-pg0-f44.google.com with SMTP id j186so11971600pge.2
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 00:51:21 -0700 (PDT)
In-Reply-To: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We previously assumed that app callback can be guaranteed to be
executed before SR-IOV is actually enabled.  Given that we can't
guarantee that SR-IOV will be disabled during probe or that we
will be able to disable it on remove, we should reorder the callbacks.
We should also call the app's sriov_enable if SR-IOV was enabled
during probe.

Application FW must be able to disable VFs internally and not depend
on them being removed at PCIe level.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c     | 40 ++++++++++-------------
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 10 ++++++
 2 files changed, 27 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index d47adb4c86d6..a0f3df8572d6 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -107,17 +107,18 @@ static int nfp_pcie_sriov_enable(struct pci_dev *pdev, int num_vfs)
 		goto err_unlock;
 	}
 
-	err = nfp_app_sriov_enable(pf->app, num_vfs);
+	err = pci_enable_sriov(pdev, num_vfs);
 	if (err) {
-		dev_warn(&pdev->dev, "App specific PCI sriov configuration failed: %d\n",
-			 err);
+		dev_warn(&pdev->dev, "Failed to enable PCI SR-IOV: %d\n", err);
 		goto err_unlock;
 	}
 
-	err = pci_enable_sriov(pdev, num_vfs);
+	err = nfp_app_sriov_enable(pf->app, num_vfs);
 	if (err) {
-		dev_warn(&pdev->dev, "Failed to enable PCI sriov: %d\n", err);
-		goto err_app_sriov_disable;
+		dev_warn(&pdev->dev,
+			 "App specific PCI SR-IOV configuration failed: %d\n",
+			 err);
+		goto err_sriov_disable;
 	}
 
 	pf->num_vfs = num_vfs;
@@ -127,8 +128,8 @@ static int nfp_pcie_sriov_enable(struct pci_dev *pdev, int num_vfs)
 	mutex_unlock(&pf->lock);
 	return num_vfs;
 
-err_app_sriov_disable:
-	nfp_app_sriov_disable(pf->app);
+err_sriov_disable:
+	pci_disable_sriov(pdev);
 err_unlock:
 	mutex_unlock(&pf->lock);
 	return err;
@@ -136,17 +137,20 @@ static int nfp_pcie_sriov_enable(struct pci_dev *pdev, int num_vfs)
 	return 0;
 }
 
-static int __nfp_pcie_sriov_disable(struct pci_dev *pdev)
+static int nfp_pcie_sriov_disable(struct pci_dev *pdev)
 {
 #ifdef CONFIG_PCI_IOV
 	struct nfp_pf *pf = pci_get_drvdata(pdev);
 
+	mutex_lock(&pf->lock);
+
 	/* If the VFs are assigned we cannot shut down SR-IOV without
 	 * causing issues, so just leave the hardware available but
 	 * disabled
 	 */
 	if (pci_vfs_assigned(pdev)) {
 		dev_warn(&pdev->dev, "Disabling while VFs assigned - VFs will not be deallocated\n");
+		mutex_unlock(&pf->lock);
 		return -EPERM;
 	}
 
@@ -156,20 +160,10 @@ static int __nfp_pcie_sriov_disable(struct pci_dev *pdev)
 
 	pci_disable_sriov(pdev);
 	dev_dbg(&pdev->dev, "Removed VFs.\n");
-#endif
-	return 0;
-}
 
-static int nfp_pcie_sriov_disable(struct pci_dev *pdev)
-{
-	struct nfp_pf *pf = pci_get_drvdata(pdev);
-	int err;
-
-	mutex_lock(&pf->lock);
-	err = __nfp_pcie_sriov_disable(pdev);
 	mutex_unlock(&pf->lock);
-
-	return err;
+#endif
+	return 0;
 }
 
 static int nfp_pcie_sriov_configure(struct pci_dev *pdev, int num_vfs)
@@ -471,11 +465,11 @@ static void nfp_pci_remove(struct pci_dev *pdev)
 
 	devlink = priv_to_devlink(pf);
 
+	nfp_net_pci_remove(pf);
+
 	nfp_pcie_sriov_disable(pdev);
 	pci_sriov_set_totalvfs(pf->pdev, 0);
 
-	nfp_net_pci_remove(pf);
-
 	devlink_unregister(devlink);
 
 	kfree(pf->rtbl);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 49c4910fbcc6..4d22e1cc013e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -488,8 +488,16 @@ static int nfp_net_pf_app_start(struct nfp_pf *pf)
 	if (err)
 		goto err_ctrl_stop;
 
+	if (pf->num_vfs) {
+		err = nfp_app_sriov_enable(pf->app, pf->num_vfs);
+		if (err)
+			goto err_app_stop;
+	}
+
 	return 0;
 
+err_app_stop:
+	nfp_app_stop(pf->app);
 err_ctrl_stop:
 	nfp_net_pf_app_stop_ctrl(pf);
 	return err;
@@ -497,6 +505,8 @@ static int nfp_net_pf_app_start(struct nfp_pf *pf)
 
 static void nfp_net_pf_app_stop(struct nfp_pf *pf)
 {
+	if (pf->num_vfs)
+		nfp_app_sriov_disable(pf->app);
 	nfp_app_stop(pf->app);
 	nfp_net_pf_app_stop_ctrl(pf);
 }
-- 
2.11.0
