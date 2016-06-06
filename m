From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [net-next PATCH 2/3] be2net: Enable Wake-On-LAN from shutdown for Skyhawk
Date: Mon,  6 Jun 2016 07:22:09 -0400
Message-ID: <1465212130-510-3-git-send-email-sathya.perla@broadcom.com>
References: <1465212130-510-1-git-send-email-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:15324 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751322AbcFFLkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 07:40:08 -0400
In-Reply-To: <1465212130-510-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>

Skyhawk does support wake-up from ACPI shutdown state - S5, provided the
platform supports it (like Auxiliary power source etc). The changes listed
below are done to fix this.

1) There's no need to defer the HW configuration of WOL to be_suspend().
Remove this in be_suspend() and move it to be_set_wol() ethtool function
so it is configured directly in the context of ethtool. This automatically
takes care of the shutdown case.

2) The driver incorrectly uses WOL_CAP field in the FW response to
get_acpi_wol_cap() command, to determine if WOL is enabled. Instead the
driver must rely on the macaddr field in the response to infer WOL state.

3) In be_get_config() during init, if we find that WOL is enabled in FW,
call pci_enable_wake() to enable pmcsr.pme_en bit. This is needed to
support persistent WOL configuration provided by the FW in some platforms.

4) Remove code in be_set_wol() that writes to PCICFG_PM_CONTROL_OFFSET
to set pme_en bit; pci_enable_wake() sets that.

Fixes: 028991e49 ("Enabling Wake-on-LAN is not supported in S5 state")
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c    |  5 ++-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |  4 ++-
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 35 ++++++++++++++++++---
 drivers/net/ethernet/emulex/benet/be_main.c    | 42 ++------------------------
 4 files changed, 39 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index bef92c4..ddc8611 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -4023,7 +4023,10 @@ int be_cmd_get_acpi_wol_cap(struct be_adapter *adapter)
 		resp = (struct be_cmd_resp_acpi_wol_magic_config_v1 *)cmd.va;
 
 		adapter->wol_cap = resp->wol_settings;
-		if (adapter->wol_cap & BE_WOL_CAP)
+
+		/* Non-zero macaddr indicates WOL is enabled */
+		if (adapter->wol_cap & BE_WOL_CAP &&
+		    !is_zero_ether_addr(resp->magic_mac))
 			adapter->wol_en = true;
 	}
 err:
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index b63ae37..855a170 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1556,7 +1556,9 @@ struct be_cmd_resp_acpi_wol_magic_config_v1 {
 	u8 rsvd0[2];
 	u8 wol_settings;
 	u8 rsvd1[5];
-	u32 rsvd2[295];
+	u32 rsvd2[288];
+	u8 magic_mac[6];
+	u8 rsvd3[22];
 } __packed;
 
 #define BE_GET_WOL_CAP			2
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 2ff6916..c569cd7 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -793,6 +793,11 @@ static void be_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 static int be_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
+	struct device *dev = &adapter->pdev->dev;
+	struct be_dma_mem cmd;
+	u8 mac[ETH_ALEN];
+	bool enable;
+	int status;
 
 	if (wol->wolopts & ~WAKE_MAGIC)
 		return -EOPNOTSUPP;
@@ -802,12 +807,32 @@ static int be_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 		return -EOPNOTSUPP;
 	}
 
-	if (wol->wolopts & WAKE_MAGIC)
-		adapter->wol_en = true;
-	else
-		adapter->wol_en = false;
+	cmd.size = sizeof(struct be_cmd_req_acpi_wol_magic_config);
+	cmd.va = dma_zalloc_coherent(dev, cmd.size, &cmd.dma, GFP_KERNEL);
+	if (!cmd.va)
+		return -ENOMEM;
 
-	return 0;
+	eth_zero_addr(mac);
+
+	enable = wol->wolopts & WAKE_MAGIC;
+	if (enable)
+		ether_addr_copy(mac, adapter->netdev->dev_addr);
+
+	status = be_cmd_enable_magic_wol(adapter, mac, &cmd);
+	if (status) {
+		dev_err(dev, "Could not set Wake-on-lan mac address\n");
+		status = be_cmd_status(status);
+		goto err;
+	}
+
+	pci_enable_wake(adapter->pdev, PCI_D3hot, enable);
+	pci_enable_wake(adapter->pdev, PCI_D3cold, enable);
+
+	adapter->wol_en = enable ? true : false;
+
+err:
+	dma_free_coherent(dev, cmd.size, cmd.va, cmd.dma);
+	return status;
 }
 
 static int be_test_ddr_dma(struct be_adapter *adapter)
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 8601047..32823a7 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3636,40 +3636,6 @@ err:
 	return -EIO;
 }
 
-static int be_setup_wol(struct be_adapter *adapter, bool enable)
-{
-	struct device *dev = &adapter->pdev->dev;
-	struct be_dma_mem cmd;
-	u8 mac[ETH_ALEN];
-	int status;
-
-	eth_zero_addr(mac);
-
-	cmd.size = sizeof(struct be_cmd_req_acpi_wol_magic_config);
-	cmd.va = dma_zalloc_coherent(dev, cmd.size, &cmd.dma, GFP_KERNEL);
-	if (!cmd.va)
-		return -ENOMEM;
-
-	if (enable) {
-		status = pci_write_config_dword(adapter->pdev,
-						PCICFG_PM_CONTROL_OFFSET,
-						PCICFG_PM_CONTROL_MASK);
-		if (status) {
-			dev_err(dev, "Could not enable Wake-on-lan\n");
-			goto err;
-		}
-	} else {
-		ether_addr_copy(mac, adapter->netdev->dev_addr);
-	}
-
-	status = be_cmd_enable_magic_wol(adapter, mac, &cmd);
-	pci_enable_wake(adapter->pdev, PCI_D3hot, enable);
-	pci_enable_wake(adapter->pdev, PCI_D3cold, enable);
-err:
-	dma_free_coherent(dev, cmd.size, cmd.va, cmd.dma);
-	return status;
-}
-
 static void be_vf_eth_addr_generate(struct be_adapter *adapter, u8 *mac)
 {
 	u32 addr;
@@ -4294,6 +4260,8 @@ static int be_get_config(struct be_adapter *adapter)
 	}
 
 	be_cmd_get_acpi_wol_cap(adapter);
+	pci_enable_wake(adapter->pdev, PCI_D3hot, adapter->wol_en);
+	pci_enable_wake(adapter->pdev, PCI_D3cold, adapter->wol_en);
 
 	be_cmd_query_port_name(adapter);
 
@@ -5463,9 +5431,6 @@ static int be_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct be_adapter *adapter = pci_get_drvdata(pdev);
 
-	if (adapter->wol_en)
-		be_setup_wol(adapter, true);
-
 	be_intr_set(adapter, false);
 	be_cancel_err_detection(adapter);
 
@@ -5494,9 +5459,6 @@ static int be_pci_resume(struct pci_dev *pdev)
 
 	be_schedule_err_detection(adapter, ERR_DETECTION_DELAY);
 
-	if (adapter->wol_en)
-		be_setup_wol(adapter, false);
-
 	return 0;
 }
 
-- 
2.4.1
