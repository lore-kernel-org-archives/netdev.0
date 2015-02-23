From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 9/9] be2net: move be_func_init() call inside be_setup()
Date: Mon, 23 Feb 2015 04:20:16 -0500
Message-ID: <1424683216-29611-10-git-send-email-sathya.perla@emulex.com>
References: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:32983 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbbBWJRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 04:17:18 -0500
In-Reply-To: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Every time be_setup() is called, the driver will have to wait for the
function/FW to be properly initialized. So, it make sense to move this call
inside be_setup().

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 88 ++++++++++++++---------------
 1 file changed, 42 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 7aa1a4d..b2277a4 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3944,11 +3944,53 @@ static inline int fw_major_num(const char *fw_ver)
 	return fw_major;
 }
 
+/* If any VFs are already enabled don't FLR the PF */
+static bool be_reset_required(struct be_adapter *adapter)
+{
+	return pci_num_vf(adapter->pdev) ? false : true;
+}
+
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
+
+		/* We can clear all errors when function reset succeeds */
+		be_clear_all_error(adapter);
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
 static int be_setup(struct be_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
 	int status;
 
+	status = be_func_init(adapter);
+	if (status)
+		return status;
+
 	be_setup_init(adapter);
 
 	if (!lancer_chip(adapter))
@@ -4903,44 +4945,6 @@ static void be_netdev_init(struct net_device *netdev)
 	netdev->ethtool_ops = &be_ethtool_ops;
 }
 
-/* If any VFs are already enabled don't FLR the PF */
-static bool be_reset_required(struct be_adapter *adapter)
-{
-	return pci_num_vf(adapter->pdev) ? false : true;
-}
-
-/* Wait for the FW to be ready and perform the required initialization */
-static int be_func_init(struct be_adapter *adapter)
-{
-	int status;
-
-	status = be_fw_wait_ready(adapter);
-	if (status)
-		return status;
-
-	if (be_reset_required(adapter)) {
-		status = be_cmd_reset_function(adapter);
-		if (status)
-			return status;
-
-		/* Wait for interrupts to quiesce after an FLR */
-		msleep(100);
-
-		/* We can clear all errors when function reset succeeds */
-		be_clear_all_error(adapter);
-	}
-
-	/* Tell FW we're ready to fire cmds */
-	status = be_cmd_fw_init(adapter);
-	if (status)
-		return status;
-
-	/* Allow interrupts for other ULPs running on NIC function */
-	be_intr_set(adapter, true);
-
-	return 0;
-}
-
 static void be_cleanup(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -4959,10 +4963,6 @@ static int be_resume(struct be_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	int status;
 
-	status = be_func_init(adapter);
-	if (status)
-		return status;
-
 	status = be_setup(adapter);
 	if (status)
 		return status;
@@ -5365,10 +5365,6 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 	if (status)
 		goto unmap_bars;
 
-	status = be_func_init(adapter);
-	if (status)
-		goto drv_cleanup;
-
 	status = be_setup(adapter);
 	if (status)
 		goto drv_cleanup;
-- 
2.2.0
