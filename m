From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 2/9] be2net: get rid of be_get_initial_config() call from be_probe()
Date: Mon, 23 Feb 2015 04:20:09 -0500
Message-ID: <1424683216-29611-3-git-send-email-sathya.perla@emulex.com>
References: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:32982 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748AbbBWJRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 04:17:15 -0500
In-Reply-To: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of the code to fetch the adapter state is in be_setup()->be_get_config().
So, move the code from be_get_initial_config() to be_get_config().

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 38 ++++++++++-------------------
 1 file changed, 13 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index ae8ad55..40c8f85 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3771,13 +3771,25 @@ static void be_sriov_config(struct be_adapter *adapter)
 
 static int be_get_config(struct be_adapter *adapter)
 {
+	int status, level;
 	u16 profile_id;
-	int status;
+
+	status = be_cmd_get_cntl_attributes(adapter);
+	if (status)
+		return status;
 
 	status = be_cmd_query_fw_cfg(adapter);
 	if (status)
 		return status;
 
+	if (BEx_chip(adapter)) {
+		level = be_cmd_get_fw_log_level(adapter);
+		adapter->msg_enable =
+			level <= FW_LOG_LEVEL_DEFAULT ? NETIF_MSG_HW : 0;
+	}
+
+	be_cmd_get_acpi_wol_cap(adapter);
+
 	be_cmd_query_port_name(adapter);
 
 	if (be_physfn(adapter)) {
@@ -3967,8 +3979,6 @@ static int be_setup(struct be_adapter *adapter)
 
 	be_set_rx_mode(adapter->netdev);
 
-	be_cmd_get_acpi_wol_cap(adapter);
-
 	status = be_cmd_set_flow_control(adapter, adapter->tx_fc,
 					 adapter->rx_fc);
 	if (status)
@@ -5179,24 +5189,6 @@ static void be_remove(struct pci_dev *pdev)
 	free_netdev(adapter->netdev);
 }
 
-static int be_get_initial_config(struct be_adapter *adapter)
-{
-	int status, level;
-
-	status = be_cmd_get_cntl_attributes(adapter);
-	if (status)
-		return status;
-
-	if (BEx_chip(adapter)) {
-		level = be_cmd_get_fw_log_level(adapter);
-		adapter->msg_enable =
-			level <= FW_LOG_LEVEL_DEFAULT ? NETIF_MSG_HW : 0;
-	}
-
-	return 0;
-}
-
-
 /* If any VFs are already enabled don't FLR the PF */
 static bool be_reset_required(struct be_adapter *adapter)
 {
@@ -5333,10 +5325,6 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 	if (status)
 		goto drv_cleanup;
 
-	status = be_get_initial_config(adapter);
-	if (status)
-		goto drv_cleanup;
-
 	status = be_setup(adapter);
 	if (status)
 		goto drv_cleanup;
-- 
2.2.0
