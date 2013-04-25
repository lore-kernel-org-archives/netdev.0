From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH net 1/2] be2net: Fixed memory leak
Date: Thu, 25 Apr 2013 16:26:55 +0530
Message-ID: <f26077ac-01c8-44c4-b863-ffcdd5feedda@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Suresh Reddy <suresh.reddy@emulex.com>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:33214 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754630Ab3DYKzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 06:55:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@emulex.com>

Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   38 ++++++++++++++++-----------
 1 file changed, 22 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index ce5af9b..24c80d1 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2493,6 +2493,9 @@ int be_cmd_get_cntl_attributes(struct be_adapter *adapter)
 	struct mgmt_controller_attrib *attribs;
 	struct be_dma_mem attribs_cmd;
 
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
+
 	memset(&attribs_cmd, 0, sizeof(struct be_dma_mem));
 	attribs_cmd.size = sizeof(struct be_cmd_resp_cntl_attribs);
 	attribs_cmd.va = pci_alloc_consistent(adapter->pdev, attribs_cmd.size,
@@ -2500,12 +2503,10 @@ int be_cmd_get_cntl_attributes(struct be_adapter *adapter)
 	if (!attribs_cmd.va) {
 		dev_err(&adapter->pdev->dev,
 				"Memory allocation failure\n");
-		return -ENOMEM;
+		status = -ENOMEM;
+		goto err;
 	}
 
-	if (mutex_lock_interruptible(&adapter->mbox_lock))
-		return -1;
-
 	wrb = wrb_from_mbox(adapter);
 	if (!wrb) {
 		status = -EBUSY;
@@ -2525,8 +2526,9 @@ int be_cmd_get_cntl_attributes(struct be_adapter *adapter)
 
 err:
 	mutex_unlock(&adapter->mbox_lock);
-	pci_free_consistent(adapter->pdev, attribs_cmd.size, attribs_cmd.va,
-					attribs_cmd.dma);
+	if (attribs_cmd.va)
+		pci_free_consistent(adapter->pdev, attribs_cmd.size,
+				    attribs_cmd.va, attribs_cmd.dma);
 	return status;
 }
 
@@ -2826,6 +2828,9 @@ int be_cmd_get_acpi_wol_cap(struct be_adapter *adapter)
 			    CMD_SUBSYSTEM_ETH))
 		return -EPERM;
 
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
+
 	memset(&cmd, 0, sizeof(struct be_dma_mem));
 	cmd.size = sizeof(struct be_cmd_resp_acpi_wol_magic_config_v1);
 	cmd.va = pci_alloc_consistent(adapter->pdev, cmd.size,
@@ -2833,12 +2838,10 @@ int be_cmd_get_acpi_wol_cap(struct be_adapter *adapter)
 	if (!cmd.va) {
 		dev_err(&adapter->pdev->dev,
 				"Memory allocation failure\n");
-		return -ENOMEM;
+		status = -ENOMEM;
+		goto err;
 	}
 
-	if (mutex_lock_interruptible(&adapter->mbox_lock))
-		return -1;
-
 	wrb = wrb_from_mbox(adapter);
 	if (!wrb) {
 		status = -EBUSY;
@@ -2869,7 +2872,8 @@ int be_cmd_get_acpi_wol_cap(struct be_adapter *adapter)
 	}
 err:
 	mutex_unlock(&adapter->mbox_lock);
-	pci_free_consistent(adapter->pdev, cmd.size, cmd.va, cmd.dma);
+	if (cmd.va)
+		pci_free_consistent(adapter->pdev, cmd.size, cmd.va, cmd.dma);
 	return status;
 
 }
@@ -3001,16 +3005,18 @@ int be_cmd_get_func_config(struct be_adapter *adapter)
 	int status;
 	struct be_dma_mem cmd;
 
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
+
 	memset(&cmd, 0, sizeof(struct be_dma_mem));
 	cmd.size = sizeof(struct be_cmd_resp_get_func_config);
 	cmd.va = pci_alloc_consistent(adapter->pdev, cmd.size,
 				      &cmd.dma);
 	if (!cmd.va) {
 		dev_err(&adapter->pdev->dev, "Memory alloc failure\n");
-		return -ENOMEM;
+		status = -ENOMEM;
+		goto err;
 	}
-	if (mutex_lock_interruptible(&adapter->mbox_lock))
-		return -1;
 
 	wrb = wrb_from_mbox(adapter);
 	if (!wrb) {
@@ -3050,8 +3056,8 @@ int be_cmd_get_func_config(struct be_adapter *adapter)
 	}
 err:
 	mutex_unlock(&adapter->mbox_lock);
-	pci_free_consistent(adapter->pdev, cmd.size,
-			    cmd.va, cmd.dma);
+	if (cmd.va)
+		pci_free_consistent(adapter->pdev, cmd.size, cmd.va, cmd.dma);
 	return status;
 }
 
-- 
1.7.9.5
