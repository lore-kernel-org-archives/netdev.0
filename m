From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 1/3] be2net: cleanup be_get_drvinfo()
Date: Mon, 27 May 2013 12:38:36 +0530
Message-ID: <6fb960d6-380d-4b40-b6f1-82240a3540ff@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>,
	Kalesh AP <kalesh.purayil@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:17643 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756585Ab3E0HJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 03:09:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing the be_cmd_get_fw_ver() query from be_get_drvinfo() and invoking
the same from be_setup() and/or post firmware download.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |    1 +
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    8 ++------
 drivers/net/ethernet/emulex/benet/be_main.c    |    6 +++++-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index f544b29..edce38b 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -397,6 +397,7 @@ struct be_adapter {
 	u32 cmd_privileges;
 	/* Ethtool knobs and info */
 	char fw_ver[FW_VER_LEN];
+	char fw_on_flash[FW_VER_LEN];
 	int if_handle;		/* Used to configure filtering */
 	u32 *pmac_id;		/* MAC addr handle used by BE card */
 	u32 beacon_state;	/* for set_phys_id */
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 3d4461a..f3ee077 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -177,19 +177,15 @@ static void be_get_drvinfo(struct net_device *netdev,
 				struct ethtool_drvinfo *drvinfo)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	char fw_on_flash[FW_VER_LEN];
-
-	memset(fw_on_flash, 0 , sizeof(fw_on_flash));
-	be_cmd_get_fw_ver(adapter, adapter->fw_ver, fw_on_flash);
 
 	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
 	strlcpy(drvinfo->version, DRV_VER, sizeof(drvinfo->version));
-	if (!memcmp(adapter->fw_ver, fw_on_flash, FW_VER_LEN))
+	if (!memcmp(adapter->fw_ver, adapter->fw_on_flash, FW_VER_LEN))
 		strlcpy(drvinfo->fw_version, adapter->fw_ver,
 			sizeof(drvinfo->fw_version));
 	else
 		snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
-			 "%s [%s]", adapter->fw_ver, fw_on_flash);
+			 "%s [%s]", adapter->fw_ver, adapter->fw_on_flash);
 
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 7892361..0f21c35 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3201,7 +3201,7 @@ static int be_setup(struct be_adapter *adapter)
 	if (status)
 		goto err;
 
-	be_cmd_get_fw_ver(adapter, adapter->fw_ver, NULL);
+	be_cmd_get_fw_ver(adapter, adapter->fw_ver, adapter->fw_on_flash);
 
 	if (adapter->vlans_added)
 		be_vid_config(adapter);
@@ -3793,6 +3793,10 @@ int be_load_fw(struct be_adapter *adapter, u8 *fw_file)
 	else
 		status = be_fw_download(adapter, fw);
 
+	if (!status)
+		be_cmd_get_fw_ver(adapter, adapter->fw_ver,
+				  adapter->fw_on_flash);
+
 fw_exit:
 	release_firmware(fw);
 	return status;
-- 
1.5.6.1
