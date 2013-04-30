From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 2/4] be2net: Fix ethtool get drvinfo
Date: Tue, 30 Apr 2013 17:07:37 +0530
Message-ID: <6ecf8164-2cef-4a5a-9a18-5c1ba2c41f7c@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Kalesh AP <kalesh.purayil@emulex.com>,
	"Somnath Kotur" <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:25250 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759520Ab3D3Liv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 07:38:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

Cannot issue any other mailbox command while firmware download is in progress.
The get_drvinfo ethtool hook can be invoked without acquiring any rtnl_lock.
So removing the be_get_fw_ver query from be_get_drvinfo ethtool hook as it times
out during firmware download.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |    1 +
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    8 ++------
 drivers/net/ethernet/emulex/benet/be_main.c    |    6 +++++-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 941aa1f..362efec 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -395,6 +395,7 @@ struct be_adapter {
 	u32 cmd_privileges;
 	/* Ethtool knobs and info */
 	char fw_ver[FW_VER_LEN];
+	char fw_on_flash[FW_VER_LEN];
 	int if_handle;		/* Used to configure filtering */
 	u32 *pmac_id;		/* MAC addr handle used by BE card */
 	u32 beacon_state;	/* for set_phys_id */
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 76b302f..abe471f 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -176,19 +176,15 @@ static void be_get_drvinfo(struct net_device *netdev,
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
index 1232e91..5544354 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3138,7 +3138,7 @@ static int be_setup(struct be_adapter *adapter)
 	if (status)
 		goto err;
 
-	be_cmd_get_fw_ver(adapter, adapter->fw_ver, NULL);
+	be_cmd_get_fw_ver(adapter, adapter->fw_ver, adapter->fw_on_flash);
 
 	if (adapter->vlans_added)
 		be_vid_config(adapter);
@@ -3717,6 +3717,10 @@ int be_load_fw(struct be_adapter *adapter, u8 *fw_file)
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
1.6.0.2
