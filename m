From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 02/12] nfp: set driver VF limit
Date: Sat, 27 May 2017 17:34:01 -0700
Message-ID: <20170528003411.17603-3-jakub.kicinski@netronome.com>
References: <20170528003411.17603-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34468 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750777AbdE1Aeo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 20:34:44 -0400
Received: by mail-pf0-f177.google.com with SMTP id 9so32597312pfj.1
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 17:34:43 -0700 (PDT)
In-Reply-To: <20170528003411.17603-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI subsystem has support for drivers limiting the number of VFs
available below what the IOV capability claims.  Make use of it.

While at it remove the #ifdef/#endif on CONFIG_PCI_IOV, it was
there to avoid unnecessary warnings in case device read failed
but kernel doesn't have SR-IOV support anyway.  Device reads
should not fail.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index f22f56c9218f..ba174e163834 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -73,20 +73,22 @@ static const struct pci_device_id nfp_pci_device_ids[] = {
 };
 MODULE_DEVICE_TABLE(pci, nfp_pci_device_ids);
 
-static void nfp_pcie_sriov_read_nfd_limit(struct nfp_pf *pf)
+static int nfp_pcie_sriov_read_nfd_limit(struct nfp_pf *pf)
 {
-#ifdef CONFIG_PCI_IOV
 	int err;
 
 	pf->limit_vfs = nfp_rtsym_read_le(pf->cpp, "nfd_vf_cfg_max_vfs", &err);
 	if (!err)
-		return;
+		return pci_sriov_set_totalvfs(pf->pdev, pf->limit_vfs);
 
 	pf->limit_vfs = ~0;
+	pci_sriov_set_totalvfs(pf->pdev, 0); /* 0 is unset */
 	/* Allow any setting for backwards compatibility if symbol not found */
-	if (err != -ENOENT)
-		nfp_warn(pf->cpp, "Warning: VF limit read failed: %d\n", err);
-#endif
+	if (err == -ENOENT)
+		return 0;
+
+	nfp_warn(pf->cpp, "Warning: VF limit read failed: %d\n", err);
+	return err;
 }
 
 static int nfp_pcie_sriov_enable(struct pci_dev *pdev, int num_vfs)
@@ -373,14 +375,18 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_devlink_unreg;
 
-	nfp_pcie_sriov_read_nfd_limit(pf);
+	err = nfp_pcie_sriov_read_nfd_limit(pf);
+	if (err)
+		goto err_fw_unload;
 
 	err = nfp_net_pci_probe(pf);
 	if (err)
-		goto err_fw_unload;
+		goto err_sriov_unlimit;
 
 	return 0;
 
+err_sriov_unlimit:
+	pci_sriov_set_totalvfs(pf->pdev, 0);
 err_fw_unload:
 	if (pf->fw_loaded)
 		nfp_fw_unload(pf);
@@ -411,6 +417,7 @@ static void nfp_pci_remove(struct pci_dev *pdev)
 	nfp_net_pci_remove(pf);
 
 	nfp_pcie_sriov_disable(pdev);
+	pci_sriov_set_totalvfs(pf->pdev, 0);
 
 	devlink_unregister(devlink);
 
-- 
2.11.0
