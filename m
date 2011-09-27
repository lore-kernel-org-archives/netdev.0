From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 2/2] be2net: Show newly flashed FW ver in ethtool
Date: Tue, 27 Sep 2011 16:43:55 +0530
Message-ID: <747547b9-60c7-41b7-9584-23d0374b4503@exht2.ad.emulex.com>
References: <1317122035-5533-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Suresh Reddy <Suresh.Reddy@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:4968 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752766Ab1I0LOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 07:14:14 -0400
In-Reply-To: <1317122035-5533-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fix provides a newly flashed FW version (appended, in braces) along with
the currently running FW version via ethtool. The newly flashed version runs only after a system reset.

Signed-off-by: Suresh Reddy <Suresh.Reddy@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c    |   31 ++++++++++++++----------
 drivers/net/ethernet/emulex/benet/be_cmds.h    |    3 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   14 +++++++++-
 drivers/net/ethernet/emulex/benet/be_main.c    |    5 +---
 4 files changed, 33 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 6bc07c7..4b655b8 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1444,32 +1444,37 @@ err:
 	spin_unlock_bh(&adapter->mcc_lock);
 }
 
-/* Uses Mbox */
-int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver)
+/* Uses synchronous mcc */
+int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver,
+			char *fw_on_flash)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_get_fw_version *req;
 	int status;
 
-	if (mutex_lock_interruptible(&adapter->mbox_lock))
-		return -1;
+	spin_lock_bh(&adapter->mcc_lock);
 
-	wrb = wrb_from_mbox(adapter);
-	req = embedded_payload(wrb);
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 
+	req = embedded_payload(wrb);
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_GET_FW_VERSION);
-
+				OPCODE_COMMON_GET_FW_VERSION);
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_GET_FW_VERSION, sizeof(*req));
+				OPCODE_COMMON_GET_FW_VERSION, sizeof(*req));
 
-	status = be_mbox_notify_wait(adapter);
+	status = be_mcc_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_get_fw_version *resp = embedded_payload(wrb);
-		strncpy(fw_ver, resp->firmware_version_string, FW_VER_LEN);
+		strcpy(fw_ver, resp->firmware_version_string);
+		if (fw_on_flash)
+			strcpy(fw_on_flash, resp->fw_on_flash_version_string);
 	}
-
-	mutex_unlock(&adapter->mbox_lock);
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
 
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index b61eac7..abaa90c 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1444,7 +1444,8 @@ extern int be_cmd_get_stats(struct be_adapter *adapter,
 			struct be_dma_mem *nonemb_cmd);
 extern int lancer_cmd_get_pport_stats(struct be_adapter *adapter,
 			struct be_dma_mem *nonemb_cmd);
-extern int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver);
+extern int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver,
+		char *fw_on_flash);
 
 extern int be_cmd_modify_eqd(struct be_adapter *adapter, u32 eq_id, u32 eqd);
 extern int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id,
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index f144a6f..bf8153e 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -118,14 +118,24 @@ static const char et_self_tests[][ETH_GSTRING_LEN] = {
 #define BE_ONE_PORT_EXT_LOOPBACK 0x2
 #define BE_NO_LOOPBACK 0xff
 
-static void
-be_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
+static void be_get_drvinfo(struct net_device *netdev,
+				struct ethtool_drvinfo *drvinfo)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
+	char fw_on_flash[FW_VER_LEN];
+
+	memset(fw_on_flash, 0 , sizeof(fw_on_flash));
+	be_cmd_get_fw_ver(adapter, adapter->fw_ver, fw_on_flash);
 
 	strcpy(drvinfo->driver, DRV_NAME);
 	strcpy(drvinfo->version, DRV_VER);
 	strncpy(drvinfo->fw_version, adapter->fw_ver, FW_VER_LEN);
+	if (memcmp(adapter->fw_ver, fw_on_flash, FW_VER_LEN) != 0) {
+		strcat(drvinfo->fw_version, " [");
+		strcat(drvinfo->fw_version, fw_on_flash);
+		strcat(drvinfo->fw_version, "]");
+	}
+
 	strcpy(drvinfo->bus_info, pci_name(adapter->pdev));
 	drvinfo->testinfo_len = 0;
 	drvinfo->regdump_len = 0;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2b7d1ba..1a7b24c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2528,6 +2528,7 @@ static int be_setup(struct be_adapter *adapter)
 
 	adapter->link_speed = -1;
 
+	be_cmd_get_fw_ver(adapter, adapter->fw_ver, NULL);
 	return 0;
 
 rx_qs_destroy:
@@ -3147,10 +3148,6 @@ static int be_get_config(struct be_adapter *adapter)
 	int status;
 	u8 mac[ETH_ALEN];
 
-	status = be_cmd_get_fw_ver(adapter, adapter->fw_ver);
-	if (status)
-		return status;
-
 	status = be_cmd_query_fw_cfg(adapter, &adapter->port_num,
 			&adapter->function_mode, &adapter->function_caps);
 	if (status)
-- 
1.7.4
