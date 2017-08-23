From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 1/3] nfp: don't hold PF lock while enabling SR-IOV
Date: Tue, 22 Aug 2017 23:22:42 -0700
Message-ID: <20170823062244.26580-2-jakub.kicinski@netronome.com>
References: <20170823062244.26580-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35910 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752291AbdHWGWw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 02:22:52 -0400
Received: by mail-pf0-f182.google.com with SMTP id c28so3475537pfe.3
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 23:22:52 -0700 (PDT)
In-Reply-To: <20170823062244.26580-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enabling SR-IOV VFs will cause the PCI subsystem to schedule a
work and flush its workqueue.  Since the nfp driver schedules its
own work we can't enable VFs while holding driver load.  Commit
6d48ceb27af1 ("nfp: allocate a private workqueue for driver work")
tried to avoid this deadlock by creating a separate workqueue.
Unfortunately, due to the architecture of workqueue subsystem this
does not guarantee a separate thread of execution.  Luckily
we can simply take pci_enable_sriov() from under the driver lock.

Take pci_disable_sriov() from under the lock too for symmetry.

Fixes: 6d48ceb27af1 ("nfp: allocate a private workqueue for driver work")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index d67969d3e484..3f199db2002e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -98,21 +98,20 @@ static int nfp_pcie_sriov_enable(struct pci_dev *pdev, int num_vfs)
 	struct nfp_pf *pf = pci_get_drvdata(pdev);
 	int err;
 
-	mutex_lock(&pf->lock);
-
 	if (num_vfs > pf->limit_vfs) {
 		nfp_info(pf->cpp, "Firmware limits number of VFs to %u\n",
 			 pf->limit_vfs);
-		err = -EINVAL;
-		goto err_unlock;
+		return -EINVAL;
 	}
 
 	err = pci_enable_sriov(pdev, num_vfs);
 	if (err) {
 		dev_warn(&pdev->dev, "Failed to enable PCI SR-IOV: %d\n", err);
-		goto err_unlock;
+		return err;
 	}
 
+	mutex_lock(&pf->lock);
+
 	err = nfp_app_sriov_enable(pf->app, num_vfs);
 	if (err) {
 		dev_warn(&pdev->dev,
@@ -129,9 +128,8 @@ static int nfp_pcie_sriov_enable(struct pci_dev *pdev, int num_vfs)
 	return num_vfs;
 
 err_sriov_disable:
-	pci_disable_sriov(pdev);
-err_unlock:
 	mutex_unlock(&pf->lock);
+	pci_disable_sriov(pdev);
 	return err;
 #endif
 	return 0;
@@ -158,10 +156,10 @@ static int nfp_pcie_sriov_disable(struct pci_dev *pdev)
 
 	pf->num_vfs = 0;
 
+	mutex_unlock(&pf->lock);
+
 	pci_disable_sriov(pdev);
 	dev_dbg(&pdev->dev, "Removed VFs.\n");
-
-	mutex_unlock(&pf->lock);
 #endif
 	return 0;
 }
-- 
2.11.0
