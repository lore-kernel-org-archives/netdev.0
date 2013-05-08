From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 1/4] be2net: provision VF resources before enabling SR-IOV
Date: Wed, 8 May 2013 17:35:47 +0530
Message-ID: <1368014750-25065-2-git-send-email-sathya.perla@emulex.com>
References: <1368014750-25065-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:10926 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754813Ab3EHMDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 08:03:09 -0400
In-Reply-To: <1368014750-25065-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the PF driver calls pci_enable_sriov(), the VFs may be probed
inline before the call returns. So, the resources required for all VFs
must be provisioned by the PF driver *before* calling pci_enable_sriov();
else, VF probe will fail.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6c52a60..b304b83 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2783,6 +2783,8 @@ static void be_vf_clear(struct be_adapter *adapter)
 		goto done;
 	}
 
+	pci_disable_sriov(adapter->pdev);
+
 	for_all_vfs(adapter, vf_cfg, vf) {
 		if (lancer_chip(adapter))
 			be_cmd_set_mac_list(adapter, NULL, 0, vf + 1);
@@ -2792,7 +2794,6 @@ static void be_vf_clear(struct be_adapter *adapter)
 
 		be_cmd_if_destroy(adapter, vf_cfg->if_handle, vf + 1);
 	}
-	pci_disable_sriov(adapter->pdev);
 done:
 	kfree(adapter->vf_cfg);
 	adapter->num_vfs = 0;
@@ -2889,13 +2890,8 @@ static int be_vf_setup(struct be_adapter *adapter)
 			dev_info(dev, "Device supports %d VFs and not %d\n",
 				 adapter->dev_num_vfs, num_vfs);
 		adapter->num_vfs = min_t(u16, num_vfs, adapter->dev_num_vfs);
-
-		status = pci_enable_sriov(adapter->pdev, num_vfs);
-		if (status) {
-			dev_err(dev, "SRIOV enable failed\n");
-			adapter->num_vfs = 0;
+		if (!adapter->num_vfs)
 			return 0;
-		}
 	}
 
 	status = be_vf_setup_init(adapter);
@@ -2944,6 +2940,15 @@ static int be_vf_setup(struct be_adapter *adapter)
 
 		be_cmd_enable_vf(adapter, vf + 1);
 	}
+
+	if (!old_vfs) {
+		status = pci_enable_sriov(adapter->pdev, adapter->num_vfs);
+		if (status) {
+			dev_err(dev, "SRIOV enable failed\n");
+			adapter->num_vfs = 0;
+			goto err;
+		}
+	}
 	return 0;
 err:
 	dev_err(dev, "VF setup failed\n");
@@ -3198,7 +3203,7 @@ static int be_setup(struct be_adapter *adapter)
 		be_cmd_set_flow_control(adapter, adapter->tx_fc,
 					adapter->rx_fc);
 
-	if (be_physfn(adapter) && num_vfs) {
+	if (be_physfn(adapter)) {
 		if (adapter->dev_num_vfs)
 			be_vf_setup(adapter);
 		else
-- 
1.7.1
