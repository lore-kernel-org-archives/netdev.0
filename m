From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH v2 net-next 01/12] be2net: add a few log messages
Date: Tue, 2 Sep 2014 09:56:46 +0530
Message-ID: <1409632017-15655-2-git-send-email-sathya.perla@emulex.com>
References: <1409632017-15655-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:26660 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064AbaIBEYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 00:24:30 -0400
In-Reply-To: <1409632017-15655-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the following log messages to help debugging
failure cases:
1) log FW version number: this is useful when driver initialization
fails and the FW version number cannot be queried via ethtool
2) per function resource limits for BEx chips: these values are
currently being printed only for Skyhawk and Lancer
3) PCI BAR mapping failure
4) function_mode/caps queried from FW: this helps catch any FW bugs
that could advertise wrong capabilities to the driver

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    4 ++++
 drivers/net/ethernet/emulex/benet/be_main.c |   20 ++++++++++++--------
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 4370ec1..ca9ec18 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1771,6 +1771,7 @@ int be_cmd_get_fw_ver(struct be_adapter *adapter)
 	status = be_mcc_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_get_fw_version *resp = embedded_payload(wrb);
+
 		strcpy(adapter->fw_ver, resp->firmware_version_string);
 		strcpy(adapter->fw_on_flash, resp->fw_on_flash_version_string);
 	}
@@ -2018,6 +2019,9 @@ int be_cmd_query_fw_cfg(struct be_adapter *adapter)
 		adapter->function_mode = le32_to_cpu(resp->function_mode);
 		adapter->function_caps = le32_to_cpu(resp->function_caps);
 		adapter->asic_rev = le32_to_cpu(resp->asic_revision) & 0xFF;
+		dev_info(&adapter->pdev->dev,
+			 "FW config: function_mode=0x%x, function_caps=0x%x\n",
+			 adapter->function_mode, adapter->function_caps);
 	}
 
 	mutex_unlock(&adapter->mbox_lock);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 93ff8ef..3d33049 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3413,16 +3413,16 @@ static int be_get_resources(struct be_adapter *adapter)
 		if (be_roce_supported(adapter))
 			res.max_evt_qs /= 2;
 		adapter->res = res;
-
-		dev_info(dev, "Max: txqs %d, rxqs %d, rss %d, eqs %d, vfs %d\n",
-			 be_max_txqs(adapter), be_max_rxqs(adapter),
-			 be_max_rss(adapter), be_max_eqs(adapter),
-			 be_max_vfs(adapter));
-		dev_info(dev, "Max: uc-macs %d, mc-macs %d, vlans %d\n",
-			 be_max_uc(adapter), be_max_mc(adapter),
-			 be_max_vlans(adapter));
 	}
 
+	dev_info(dev, "Max: txqs %d, rxqs %d, rss %d, eqs %d, vfs %d\n",
+		 be_max_txqs(adapter), be_max_rxqs(adapter),
+		 be_max_rss(adapter), be_max_eqs(adapter),
+		 be_max_vfs(adapter));
+	dev_info(dev, "Max: uc-macs %d, mc-macs %d, vlans %d\n",
+		 be_max_uc(adapter), be_max_mc(adapter),
+		 be_max_vlans(adapter));
+
 	return 0;
 }
 
@@ -3633,6 +3633,7 @@ static int be_setup(struct be_adapter *adapter)
 		goto err;
 
 	be_cmd_get_fw_ver(adapter);
+	dev_info(dev, "FW version is %s\n", adapter->fw_ver);
 
 	if (BE2_chip(adapter) && fw_major_num(adapter->fw_ver) < 4) {
 		dev_err(dev, "Firmware on card is old(%s), IRQs may not work.",
@@ -4506,6 +4507,7 @@ static int be_map_pci_bars(struct be_adapter *adapter)
 	return 0;
 
 pci_map_err:
+	dev_err(&adapter->pdev->dev, "Error in mapping PCI BARs\n");
 	be_unmap_pci_bars(adapter);
 	return -ENOMEM;
 }
@@ -4822,6 +4824,8 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 	struct net_device *netdev;
 	char port_name;
 
+	dev_info(&pdev->dev, "%s version is %s\n", DRV_NAME, DRV_VER);
+
 	status = pci_enable_device(pdev);
 	if (status)
 		goto do_none;
-- 
1.7.1
