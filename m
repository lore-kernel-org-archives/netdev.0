From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 3/9] be2net: refactor function initalization sequence into be_func_init()
Date: Mon, 23 Feb 2015 04:20:10 -0500
Message-ID: <1424683216-29611-4-git-send-email-sathya.perla@emulex.com>
References: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:5932 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625AbbBWJRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 04:17:20 -0500
In-Reply-To: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function initialization sequence is executed in be_probe(), be_resume
and be_eeh_resume(). Move this code to a new routine called be_func_init()
to prevent code duplication.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |  4 ++
 drivers/net/ethernet/emulex/benet/be_main.c | 76 ++++++++++++-----------------
 2 files changed, 36 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 36916cf..8a8a230 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -720,6 +720,10 @@ int be_fw_wait_ready(struct be_adapter *adapter)
 	}
 
 	do {
+		/* There's no means to poll POST state on BE2/3 VFs */
+		if (BEx_chip(adapter) && be_virtfn(adapter))
+			return 0;
+
 		stage = be_POST_stage_get(adapter);
 		if (stage == POST_STAGE_ARMFW_RDY)
 			return 0;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 40c8f85..fda2e5d 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5250,6 +5250,35 @@ static inline char *nic_name(struct pci_dev *pdev)
 	}
 }
 
+/* Wait for the FW to be ready and perform the required initialization */
+static int be_func_init(struct be_adapter *adapter)
+{
+	int status;
+
+	status = be_fw_wait_ready(adapter);
+	if (status)
+		return status;
+
+	if (be_reset_required(adapter)) {
+		status = be_cmd_reset_function(adapter);
+		if (status)
+			return status;
+
+		/* Wait for interrupts to quiesce after an FLR */
+		msleep(100);
+	}
+
+	/* Tell FW we're ready to fire cmds */
+	status = be_cmd_fw_init(adapter);
+	if (status)
+		return status;
+
+	/* Allow interrupts for other ULPs running on NIC function */
+	be_intr_set(adapter, true);
+
+	return 0;
+}
+
 static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 {
 	struct be_adapter *adapter;
@@ -5301,27 +5330,7 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 	if (status)
 		goto unmap_bars;
 
-	/* sync up with fw's ready state */
-	if (be_physfn(adapter)) {
-		status = be_fw_wait_ready(adapter);
-		if (status)
-			goto drv_cleanup;
-	}
-
-	if (be_reset_required(adapter)) {
-		status = be_cmd_reset_function(adapter);
-		if (status)
-			goto drv_cleanup;
-
-		/* Wait for interrupts to quiesce after an FLR */
-		msleep(100);
-	}
-
-	/* Allow interrupts for other ULPs running on NIC function */
-	be_intr_set(adapter, true);
-
-	/* tell fw we're ready to fire cmds */
-	status = be_cmd_fw_init(adapter);
+	status = be_func_init(adapter);
 	if (status)
 		goto drv_cleanup;
 
@@ -5401,17 +5410,7 @@ static int be_resume(struct pci_dev *pdev)
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 
-	status = be_fw_wait_ready(adapter);
-	if (status)
-		return status;
-
-	status = be_cmd_reset_function(adapter);
-	if (status)
-		return status;
-
-	be_intr_set(adapter, true);
-	/* tell fw we're ready to fire cmds */
-	status = be_cmd_fw_init(adapter);
+	status = be_func_init(adapter);
 	if (status)
 		return status;
 
@@ -5529,18 +5528,7 @@ static void be_eeh_resume(struct pci_dev *pdev)
 
 	pci_save_state(pdev);
 
-	status = be_cmd_reset_function(adapter);
-	if (status)
-		goto err;
-
-	/* On some BE3 FW versions, after a HW reset,
-	 * interrupts will remain disabled for each function.
-	 * So, explicitly enable interrupts
-	 */
-	be_intr_set(adapter, true);
-
-	/* tell fw we're ready to fire cmds */
-	status = be_cmd_fw_init(adapter);
+	status = be_func_init(adapter);
 	if (status)
 		goto err;
 
-- 
2.2.0
