From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 1/3] be2net: ignore get/set profile FW cmd failures
Date: Fri, 1 Aug 2014 17:47:30 +0530
Message-ID: <1406895452-29514-2-git-send-email-sathya.perla@emulex.com>
References: <1406895452-29514-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:6599 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755244AbaHAMPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 08:15:45 -0400
In-Reply-To: <1406895452-29514-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Old versions of BE3 FW may not support cmds to re-provision (and hence
optimize) resources/queues in SR-IOV config. Do not treat this FW cmd
failure as fatal and fail the function initialization. Instead, just
enable SR-IOV with the resources provided by the FW.

Prior to the "create optimal number of queues on SR-IOV config" patch
such failures were ignored.
Fixes: bec84e6b2 ("create optimal number of queues on SR-IOV config")

Reported-by: Eduardo Habkost <ehabkost@redhat.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   67 +++++++++++++++------------
 1 files changed, 37 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9c50814..da4d386 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3342,22 +3342,17 @@ static int be_get_sriov_config(struct be_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
 	struct be_resources res = {0};
-	int status, max_vfs, old_vfs;
-
-	status = be_cmd_get_profile_config(adapter, &res, 0);
-	if (status)
-		return status;
-
-	adapter->pool_res = res;
+	int max_vfs, old_vfs;
 
 	/* Some old versions of BE3 FW don't report max_vfs value */
+	be_cmd_get_profile_config(adapter, &res, 0);
+
 	if (BE3_chip(adapter) && !res.max_vfs) {
 		max_vfs = pci_sriov_get_totalvfs(adapter->pdev);
 		res.max_vfs = max_vfs > 0 ? min(MAX_VFS, max_vfs) : 0;
 	}
 
-	adapter->pool_res.max_vfs = res.max_vfs;
-	pci_sriov_set_totalvfs(adapter->pdev, be_max_vfs(adapter));
+	adapter->pool_res = res;
 
 	if (!be_max_vfs(adapter)) {
 		if (num_vfs)
@@ -3366,6 +3361,8 @@ static int be_get_sriov_config(struct be_adapter *adapter)
 		return 0;
 	}
 
+	pci_sriov_set_totalvfs(adapter->pdev, be_max_vfs(adapter));
+
 	/* validate num_vfs module param */
 	old_vfs = pci_num_vf(adapter->pdev);
 	if (old_vfs) {
@@ -3423,6 +3420,35 @@ static int be_get_resources(struct be_adapter *adapter)
 	return 0;
 }
 
+static void be_sriov_config(struct be_adapter *adapter)
+{
+	struct device *dev = &adapter->pdev->dev;
+	int status;
+
+	status = be_get_sriov_config(adapter);
+	if (status) {
+		dev_err(dev, "Failed to query SR-IOV configuration\n");
+		dev_err(dev, "SR-IOV cannot be enabled\n");
+		return;
+	}
+
+	/* When the HW is in SRIOV capable configuration, the PF-pool
+	 * resources are equally distributed across the max-number of
+	 * VFs. The user may request only a subset of the max-vfs to be
+	 * enabled. Based on num_vfs, redistribute the resources across
+	 * num_vfs so that each VF will have access to more number of
+	 * resources. This facility is not available in BE3 FW.
+	 * Also, this is done by FW in Lancer chip.
+	 */
+	if (be_max_vfs(adapter) && !pci_num_vf(adapter->pdev)) {
+		status = be_cmd_set_sriov_config(adapter,
+						 adapter->pool_res,
+						 adapter->num_vfs);
+		if (status)
+			dev_err(dev, "Failed to optimize SR-IOV resources\n");
+	}
+}
+
 static int be_get_config(struct be_adapter *adapter)
 {
 	u16 profile_id;
@@ -3439,27 +3465,8 @@ static int be_get_config(struct be_adapter *adapter)
 				 "Using profile 0x%x\n", profile_id);
 	}
 
-	if (!BE2_chip(adapter) && be_physfn(adapter)) {
-		status = be_get_sriov_config(adapter);
-		if (status)
-			return status;
-
-		/* When the HW is in SRIOV capable configuration, the PF-pool
-		 * resources are equally distributed across the max-number of
-		 * VFs. The user may request only a subset of the max-vfs to be
-		 * enabled. Based on num_vfs, redistribute the resources across
-		 * num_vfs so that each VF will have access to more number of
-		 * resources. This facility is not available in BE3 FW.
-		 * Also, this is done by FW in Lancer chip.
-		 */
-		if (!pci_num_vf(adapter->pdev)) {
-			status = be_cmd_set_sriov_config(adapter,
-							 adapter->pool_res,
-							 adapter->num_vfs);
-			if (status)
-				return status;
-		}
-	}
+	if (!BE2_chip(adapter) && be_physfn(adapter))
+		be_sriov_config(adapter);
 
 	status = be_get_resources(adapter);
 	if (status)
-- 
1.7.1
