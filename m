From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 3/3] be2net: implement .sriov_configure() PCI callback
Date: Wed, 4 Mar 2015 00:44:34 -0500
Message-ID: <1425447874-5406-4-git-send-email-sathya.perla@emulex.com>
References: <1425447874-5406-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:7417 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753890AbbCDFl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 00:41:26 -0500
In-Reply-To: <1425447874-5406-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

This patch implements the .sriov_configure() PCI method to allow for
runtime enabling/disabling of VFs. The module param "num_vfs" is now
deprecated.
At the time of driver load the PF-pool resources are allocated to the PF.
When the user enables VFs, the resources are then re-distributed across
PFs and VFs based on the number of VFs enabled.
Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   3 -
 drivers/net/ethernet/emulex/benet/be_main.c | 169 ++++++++++++++++++----------
 2 files changed, 107 insertions(+), 65 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 4a97cbf..defe68c 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -3879,9 +3879,6 @@ int be_cmd_set_sriov_config(struct be_adapter *adapter,
 		struct be_nic_res_desc nic_vft;
 	} __packed desc;
 
-	if (BEx_chip(adapter) || lancer_chip(adapter))
-		return 0;
-
 	/* PF PCIE descriptor */
 	be_reset_pcie_desc(&desc.pcie);
 	desc.pcie.hdr.desc_type = PCIE_RESOURCE_DESC_TYPE_V1;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5f1e018..788c38a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -30,6 +30,9 @@ MODULE_DESCRIPTION(DRV_DESC " " DRV_VER);
 MODULE_AUTHOR("Emulex Corporation");
 MODULE_LICENSE("GPL");
 
+/* num_vfs module param is obsolete.
+ * Use sysfs method to enable/disable VFs.
+ */
 static unsigned int num_vfs;
 module_param(num_vfs, uint, S_IRUGO);
 MODULE_PARM_DESC(num_vfs, "Number of PCI VFs to initialize");
@@ -3449,7 +3452,8 @@ static int be_clear(struct be_adapter *adapter)
 	/* Re-configure FW to distribute resources evenly across max-supported
 	 * number of VFs, only when VFs are not already enabled.
 	 */
-	if (be_physfn(adapter) && !pci_vfs_assigned(pdev)) {
+	if (skyhawk_chip(adapter) && be_physfn(adapter) &&
+	    !pci_vfs_assigned(pdev)) {
 		num_vf_qs = be_calculate_vf_qs(adapter,
 					       pci_sriov_get_totalvfs(pdev));
 		be_cmd_set_sriov_config(adapter, adapter->pool_res,
@@ -3712,13 +3716,12 @@ static void be_setup_init(struct be_adapter *adapter)
 
 static int be_get_sriov_config(struct be_adapter *adapter)
 {
-	struct device *dev = &adapter->pdev->dev;
 	struct be_resources res = {0};
 	int max_vfs, old_vfs;
 
-	/* Some old versions of BE3 FW don't report max_vfs value */
 	be_cmd_get_profile_config(adapter, &res, RESOURCE_LIMITS, 0);
 
+	/* Some old versions of BE3 FW don't report max_vfs value */
 	if (BE3_chip(adapter) && !res.max_vfs) {
 		max_vfs = pci_sriov_get_totalvfs(adapter->pdev);
 		res.max_vfs = max_vfs > 0 ? min(MAX_VFS, max_vfs) : 0;
@@ -3726,35 +3729,49 @@ static int be_get_sriov_config(struct be_adapter *adapter)
 
 	adapter->pool_res = res;
 
-	if (!be_max_vfs(adapter)) {
-		if (num_vfs)
-			dev_warn(dev, "SRIOV is disabled. Ignoring num_vfs\n");
-		adapter->num_vfs = 0;
-		return 0;
-	}
-
-	pci_sriov_set_totalvfs(adapter->pdev, be_max_vfs(adapter));
-
-	/* validate num_vfs module param */
+	/* If during previous unload of the driver, the VFs were not disabled,
+	 * then we cannot rely on the PF POOL limits for the TotalVFs value.
+	 * Instead use the TotalVFs value stored in the pci-dev struct.
+	 */
 	old_vfs = pci_num_vf(adapter->pdev);
 	if (old_vfs) {
-		dev_info(dev, "%d VFs are already enabled\n", old_vfs);
-		if (old_vfs != num_vfs)
-			dev_warn(dev, "Ignoring num_vfs=%d setting\n", num_vfs);
+		dev_info(&adapter->pdev->dev, "%d VFs are already enabled\n",
+			 old_vfs);
+
+		adapter->pool_res.max_vfs =
+			pci_sriov_get_totalvfs(adapter->pdev);
 		adapter->num_vfs = old_vfs;
-	} else {
-		if (num_vfs > be_max_vfs(adapter)) {
-			dev_info(dev, "Resources unavailable to init %d VFs\n",
-				 num_vfs);
-			dev_info(dev, "Limiting to %d VFs\n",
-				 be_max_vfs(adapter));
-		}
-		adapter->num_vfs = min_t(u16, num_vfs, be_max_vfs(adapter));
 	}
 
 	return 0;
 }
 
+static void be_alloc_sriov_res(struct be_adapter *adapter)
+{
+	int old_vfs = pci_num_vf(adapter->pdev);
+	u16 num_vf_qs;
+	int status;
+
+	be_get_sriov_config(adapter);
+
+	if (!old_vfs)
+		pci_sriov_set_totalvfs(adapter->pdev, be_max_vfs(adapter));
+
+	/* When the HW is in SRIOV capable configuration, the PF-pool
+	 * resources are given to PF during driver load, if there are no
+	 * old VFs. This facility is not available in BE3 FW.
+	 * Also, this is done by FW in Lancer chip.
+	 */
+	if (skyhawk_chip(adapter) && be_max_vfs(adapter) && !old_vfs) {
+		num_vf_qs = be_calculate_vf_qs(adapter, 0);
+		status = be_cmd_set_sriov_config(adapter, adapter->pool_res, 0,
+						 num_vf_qs);
+		if (status)
+			dev_err(&adapter->pdev->dev,
+				"Failed to optimize SRIOV resources\n");
+	}
+}
+
 static int be_get_resources(struct be_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
@@ -3800,40 +3817,12 @@ static int be_get_resources(struct be_adapter *adapter)
 		 be_max_uc(adapter), be_max_mc(adapter),
 		 be_max_vlans(adapter));
 
+	/* Sanitize cfg_num_qs based on HW and platform limits */
+	adapter->cfg_num_qs = min_t(u16, netif_get_num_default_rss_queues(),
+				    be_max_qs(adapter));
 	return 0;
 }
 
-static void be_sriov_config(struct be_adapter *adapter)
-{
-	struct device *dev = &adapter->pdev->dev;
-	u16 num_vf_qs;
-	int status;
-
-	status = be_get_sriov_config(adapter);
-	if (status) {
-		dev_err(dev, "Failed to query SR-IOV configuration\n");
-		dev_err(dev, "SR-IOV cannot be enabled\n");
-		return;
-	}
-
-	/* When the HW is in SRIOV capable configuration, the PF-pool
-	 * resources are equally distributed across the max-number of
-	 * VFs. The user may request only a subset of the max-vfs to be
-	 * enabled. Based on num_vfs, redistribute the resources across
-	 * num_vfs so that each VF will have access to more number of
-	 * resources. This facility is not available in BE3 FW.
-	 * Also, this is done by FW in Lancer chip.
-	 */
-	if (be_max_vfs(adapter) && !pci_num_vf(adapter->pdev)) {
-		num_vf_qs = be_calculate_vf_qs(adapter, adapter->num_vfs);
-		status = be_cmd_set_sriov_config(adapter,
-						 adapter->pool_res,
-						 adapter->num_vfs, num_vf_qs);
-		if (status)
-			dev_err(dev, "Failed to optimize SR-IOV resources\n");
-	}
-}
-
 static int be_get_config(struct be_adapter *adapter)
 {
 	int status, level;
@@ -3864,9 +3853,6 @@ static int be_get_config(struct be_adapter *adapter)
 				 "Using profile 0x%x\n", profile_id);
 	}
 
-	if (!BE2_chip(adapter) && be_physfn(adapter))
-		be_sriov_config(adapter);
-
 	status = be_get_resources(adapter);
 	if (status)
 		return status;
@@ -3876,9 +3862,6 @@ static int be_get_config(struct be_adapter *adapter)
 	if (!adapter->pmac_id)
 		return -ENOMEM;
 
-	/* Sanitize cfg_num_qs based on HW and platform limits */
-	adapter->cfg_num_qs = min(adapter->cfg_num_qs, be_max_qs(adapter));
-
 	return 0;
 }
 
@@ -4053,6 +4036,9 @@ static int be_setup(struct be_adapter *adapter)
 	if (!lancer_chip(adapter))
 		be_cmd_req_native_mode(adapter);
 
+	if (!BE2_chip(adapter) && be_physfn(adapter))
+		be_alloc_sriov_res(adapter);
+
 	status = be_get_config(adapter);
 	if (status)
 		goto err;
@@ -5274,7 +5260,6 @@ static int be_drv_init(struct be_adapter *adapter)
 
 	/* Must be a power of 2 or else MODULO will BUG_ON */
 	adapter->be_get_temp_freq = 64;
-	adapter->cfg_num_qs = netif_get_num_default_rss_queues();
 
 	return 0;
 
@@ -5598,6 +5583,60 @@ err:
 	dev_err(&adapter->pdev->dev, "EEH resume failed\n");
 }
 
+static int be_pci_sriov_configure(struct pci_dev *pdev, int num_vfs)
+{
+	struct be_adapter *adapter = pci_get_drvdata(pdev);
+	u16 num_vf_qs;
+	int status;
+
+	if (!num_vfs)
+		be_vf_clear(adapter);
+
+	adapter->num_vfs = num_vfs;
+
+	if (adapter->num_vfs == 0 && pci_vfs_assigned(pdev)) {
+		dev_warn(&pdev->dev,
+			 "Cannot disable VFs while they are assigned\n");
+		return -EBUSY;
+	}
+
+	/* When the HW is in SRIOV capable configuration, the PF-pool resources
+	 * are equally distributed across the max-number of VFs. The user may
+	 * request only a subset of the max-vfs to be enabled.
+	 * Based on num_vfs, redistribute the resources across num_vfs so that
+	 * each VF will have access to more number of resources.
+	 * This facility is not available in BE3 FW.
+	 * Also, this is done by FW in Lancer chip.
+	 */
+	if (skyhawk_chip(adapter) && !pci_num_vf(pdev)) {
+		num_vf_qs = be_calculate_vf_qs(adapter, adapter->num_vfs);
+		status = be_cmd_set_sriov_config(adapter, adapter->pool_res,
+						 adapter->num_vfs, num_vf_qs);
+		if (status)
+			dev_err(&pdev->dev,
+				"Failed to optimize SR-IOV resources\n");
+	}
+
+	status = be_get_resources(adapter);
+	if (status)
+		return be_cmd_status(status);
+
+	/* Updating real_num_tx/rx_queues() requires rtnl_lock() */
+	rtnl_lock();
+	status = be_update_queues(adapter);
+	rtnl_unlock();
+	if (status)
+		return be_cmd_status(status);
+
+	if (adapter->num_vfs)
+		status = be_vf_setup(adapter);
+
+	if (!status)
+		return adapter->num_vfs;
+
+	return 0;
+}
+
 static const struct pci_error_handlers be_eeh_handlers = {
 	.error_detected = be_eeh_err_detected,
 	.slot_reset = be_eeh_reset,
@@ -5612,6 +5651,7 @@ static struct pci_driver be_driver = {
 	.suspend = be_suspend,
 	.resume = be_pci_resume,
 	.shutdown = be_shutdown,
+	.sriov_configure = be_pci_sriov_configure,
 	.err_handler = &be_eeh_handlers
 };
 
@@ -5625,6 +5665,11 @@ static int __init be_init_module(void)
 		rx_frag_size = 2048;
 	}
 
+	if (num_vfs > 0) {
+		pr_info(DRV_NAME " : Module param num_vfs is obsolete.");
+		pr_info(DRV_NAME " : Use sysfs method to enable VFs\n");
+	}
+
 	return pci_register_driver(&be_driver);
 }
 module_init(be_init_module);
-- 
2.2.0
