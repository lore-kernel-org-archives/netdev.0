From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH net-next 1/9] be2net: remove duplicate code in be_setup_wol()
Date: Fri, 10 Jul 2015 05:32:43 -0400
Message-ID: <1436520771-11656-2-git-send-email-sathya.perla@avagotech.com>
References: <1436520771-11656-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:56755 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753390AbbGJJ0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 05:26:32 -0400
In-Reply-To: <1436520771-11656-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh Purayil <kalesh.purayil@avagotech.com>

This change will make be_setup_wol() routine more compact and readable
by removing some duplicate code.

Signed-off-by: Kalesh AP <kalesh.purayil@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 28 +++++++++++-----------------
 1 file changed, 11 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6f64242..635c62f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3529,15 +3529,15 @@ err:
 
 static int be_setup_wol(struct be_adapter *adapter, bool enable)
 {
+	struct device *dev = &adapter->pdev->dev;
 	struct be_dma_mem cmd;
-	int status = 0;
 	u8 mac[ETH_ALEN];
+	int status;
 
 	eth_zero_addr(mac);
 
 	cmd.size = sizeof(struct be_cmd_req_acpi_wol_magic_config);
-	cmd.va = dma_zalloc_coherent(&adapter->pdev->dev, cmd.size, &cmd.dma,
-				     GFP_KERNEL);
+	cmd.va = dma_zalloc_coherent(dev, cmd.size, &cmd.dma, GFP_KERNEL);
 	if (!cmd.va)
 		return -ENOMEM;
 
@@ -3546,24 +3546,18 @@ static int be_setup_wol(struct be_adapter *adapter, bool enable)
 						PCICFG_PM_CONTROL_OFFSET,
 						PCICFG_PM_CONTROL_MASK);
 		if (status) {
-			dev_err(&adapter->pdev->dev,
-				"Could not enable Wake-on-lan\n");
-			dma_free_coherent(&adapter->pdev->dev, cmd.size, cmd.va,
-					  cmd.dma);
-			return status;
+			dev_err(dev, "Could not enable Wake-on-lan\n");
+			goto err;
 		}
-		status = be_cmd_enable_magic_wol(adapter,
-						 adapter->netdev->dev_addr,
-						 &cmd);
-		pci_enable_wake(adapter->pdev, PCI_D3hot, 1);
-		pci_enable_wake(adapter->pdev, PCI_D3cold, 1);
 	} else {
-		status = be_cmd_enable_magic_wol(adapter, mac, &cmd);
-		pci_enable_wake(adapter->pdev, PCI_D3hot, 0);
-		pci_enable_wake(adapter->pdev, PCI_D3cold, 0);
+		ether_addr_copy(mac, adapter->netdev->dev_addr);
 	}
 
-	dma_free_coherent(&adapter->pdev->dev, cmd.size, cmd.va, cmd.dma);
+	status = be_cmd_enable_magic_wol(adapter, mac, &cmd);
+	pci_enable_wake(adapter->pdev, PCI_D3hot, enable);
+	pci_enable_wake(adapter->pdev, PCI_D3cold, enable);
+err:
+	dma_free_coherent(dev, cmd.size, cmd.va, cmd.dma);
 	return status;
 }
 
-- 
2.4.1
