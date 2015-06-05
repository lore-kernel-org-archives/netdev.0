From: Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>
Subject: [PATCH net] be2net: Replace dma/pci_alloc_coherent() calls with dma_zalloc_coherent()
Date: Fri,  5 Jun 2015 15:33:59 +0530
Message-ID: <1433498639-4749-1-git-send-email-sriharsha.basavapatna@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:60184 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750831AbbFEKNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 06:13:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several places in the driver (all in control paths) where
coherent dma memory is being allocated using either dma_alloc_coherent()
or the deprecated pci_alloc_consistent(). All these calls should be
changed to use dma_zalloc_coherent() to avoid uninitialized fields in
data structures backed by this memory.

Reported-by: Joerg Roedel <jroedel@suse.de>
Tested-by: Joerg Roedel <jroedel@suse.de>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>
---

Hi Dave,

This patch fixes a bug in be2net driver found by Joerg Roedel while
testing his dma_alloc_coherent() changes on an AMD/IOMMU platform.
The driver assumed memory returned by dma_alloc_coherent() is zeroed
out that was leading to some FW command failures. Please consider
applying this patch to the "net" and "stable" trees. Thanks.

---

 drivers/net/ethernet/emulex/benet/be_cmds.c    | 87 +++++++++++++++-----------
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 18 +++---
 drivers/net/ethernet/emulex/benet/be_main.c    | 15 +++--
 3 files changed, 67 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index fb140fa..c5e1d0a 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1720,9 +1720,9 @@ int be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf)
 	total_size = buf_len;
 
 	get_fat_cmd.size = sizeof(struct be_cmd_req_get_fat) + 60*1024;
-	get_fat_cmd.va = pci_alloc_consistent(adapter->pdev,
-					      get_fat_cmd.size,
-					      &get_fat_cmd.dma);
+	get_fat_cmd.va = dma_zalloc_coherent(&adapter->pdev->dev,
+					     get_fat_cmd.size,
+					     &get_fat_cmd.dma, GFP_ATOMIC);
 	if (!get_fat_cmd.va) {
 		dev_err(&adapter->pdev->dev,
 			"Memory allocation failure while reading FAT data\n");
@@ -1767,8 +1767,8 @@ int be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf)
 		log_offset += buf_size;
 	}
 err:
-	pci_free_consistent(adapter->pdev, get_fat_cmd.size,
-			    get_fat_cmd.va, get_fat_cmd.dma);
+	dma_free_coherent(&adapter->pdev->dev, get_fat_cmd.size,
+			  get_fat_cmd.va, get_fat_cmd.dma);
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
@@ -2215,12 +2215,12 @@ int be_cmd_read_port_transceiver_data(struct be_adapter *adapter,
 		return -EINVAL;
 
 	cmd.size = sizeof(struct be_cmd_resp_port_type);
-	cmd.va = pci_alloc_consistent(adapter->pdev, cmd.size, &cmd.dma);
+	cmd.va = dma_zalloc_coherent(&adapter->pdev->dev, cmd.size, &cmd.dma,
+				     GFP_ATOMIC);
 	if (!cmd.va) {
 		dev_err(&adapter->pdev->dev, "Memory allocation failed\n");
 		return -ENOMEM;
 	}
-	memset(cmd.va, 0, cmd.size);
 
 	spin_lock_bh(&adapter->mcc_lock);
 
@@ -2245,7 +2245,7 @@ int be_cmd_read_port_transceiver_data(struct be_adapter *adapter,
 	}
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
-	pci_free_consistent(adapter->pdev, cmd.size, cmd.va, cmd.dma);
+	dma_free_coherent(&adapter->pdev->dev, cmd.size, cmd.va, cmd.dma);
 	return status;
 }
 
@@ -2720,7 +2720,8 @@ int be_cmd_get_phy_info(struct be_adapter *adapter)
 		goto err;
 	}
 	cmd.size = sizeof(struct be_cmd_req_get_phy_info);
-	cmd.va = pci_alloc_consistent(adapter->pdev, cmd.size, &cmd.dma);
+	cmd.va = dma_zalloc_coherent(&adapter->pdev->dev, cmd.size, &cmd.dma,
+				     GFP_ATOMIC);
 	if (!cmd.va) {
 		dev_err(&adapter->pdev->dev, "Memory alloc failure\n");
 		status = -ENOMEM;
@@ -2754,7 +2755,7 @@ int be_cmd_get_phy_info(struct be_adapter *adapter)
 				BE_SUPPORTED_SPEED_1GBPS;
 		}
 	}
-	pci_free_consistent(adapter->pdev, cmd.size, cmd.va, cmd.dma);
+	dma_free_coherent(&adapter->pdev->dev, cmd.size, cmd.va, cmd.dma);
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
@@ -2805,8 +2806,9 @@ int be_cmd_get_cntl_attributes(struct be_adapter *adapter)
 
 	memset(&attribs_cmd, 0, sizeof(struct be_dma_mem));
 	attribs_cmd.size = sizeof(struct be_cmd_resp_cntl_attribs);
-	attribs_cmd.va = pci_alloc_consistent(adapter->pdev, attribs_cmd.size,
-					      &attribs_cmd.dma);
+	attribs_cmd.va = dma_zalloc_coherent(&adapter->pdev->dev,
+					     attribs_cmd.size,
+					     &attribs_cmd.dma, GFP_ATOMIC);
 	if (!attribs_cmd.va) {
 		dev_err(&adapter->pdev->dev, "Memory allocation failure\n");
 		status = -ENOMEM;
@@ -2833,8 +2835,8 @@ int be_cmd_get_cntl_attributes(struct be_adapter *adapter)
 err:
 	mutex_unlock(&adapter->mbox_lock);
 	if (attribs_cmd.va)
-		pci_free_consistent(adapter->pdev, attribs_cmd.size,
-				    attribs_cmd.va, attribs_cmd.dma);
+		dma_free_coherent(&adapter->pdev->dev, attribs_cmd.size,
+				  attribs_cmd.va, attribs_cmd.dma);
 	return status;
 }
 
@@ -2972,9 +2974,10 @@ int be_cmd_get_mac_from_list(struct be_adapter *adapter, u8 *mac,
 
 	memset(&get_mac_list_cmd, 0, sizeof(struct be_dma_mem));
 	get_mac_list_cmd.size = sizeof(struct be_cmd_resp_get_mac_list);
-	get_mac_list_cmd.va = pci_alloc_consistent(adapter->pdev,
-						   get_mac_list_cmd.size,
-						   &get_mac_list_cmd.dma);
+	get_mac_list_cmd.va = dma_zalloc_coherent(&adapter->pdev->dev,
+						  get_mac_list_cmd.size,
+						  &get_mac_list_cmd.dma,
+						  GFP_ATOMIC);
 
 	if (!get_mac_list_cmd.va) {
 		dev_err(&adapter->pdev->dev,
@@ -3047,8 +3050,8 @@ int be_cmd_get_mac_from_list(struct be_adapter *adapter, u8 *mac,
 
 out:
 	spin_unlock_bh(&adapter->mcc_lock);
-	pci_free_consistent(adapter->pdev, get_mac_list_cmd.size,
-			    get_mac_list_cmd.va, get_mac_list_cmd.dma);
+	dma_free_coherent(&adapter->pdev->dev, get_mac_list_cmd.size,
+			  get_mac_list_cmd.va, get_mac_list_cmd.dma);
 	return status;
 }
 
@@ -3101,8 +3104,8 @@ int be_cmd_set_mac_list(struct be_adapter *adapter, u8 *mac_array,
 
 	memset(&cmd, 0, sizeof(struct be_dma_mem));
 	cmd.size = sizeof(struct be_cmd_req_set_mac_list);
-	cmd.va = dma_alloc_coherent(&adapter->pdev->dev, cmd.size,
-				    &cmd.dma, GFP_KERNEL);
+	cmd.va = dma_zalloc_coherent(&adapter->pdev->dev, cmd.size, &cmd.dma,
+				     GFP_KERNEL);
 	if (!cmd.va)
 		return -ENOMEM;
 
@@ -3291,7 +3294,8 @@ int be_cmd_get_acpi_wol_cap(struct be_adapter *adapter)
 
 	memset(&cmd, 0, sizeof(struct be_dma_mem));
 	cmd.size = sizeof(struct be_cmd_resp_acpi_wol_magic_config_v1);
-	cmd.va = pci_alloc_consistent(adapter->pdev, cmd.size, &cmd.dma);
+	cmd.va = dma_zalloc_coherent(&adapter->pdev->dev, cmd.size, &cmd.dma,
+				     GFP_ATOMIC);
 	if (!cmd.va) {
 		dev_err(&adapter->pdev->dev, "Memory allocation failure\n");
 		status = -ENOMEM;
@@ -3326,7 +3330,8 @@ int be_cmd_get_acpi_wol_cap(struct be_adapter *adapter)
 err:
 	mutex_unlock(&adapter->mbox_lock);
 	if (cmd.va)
-		pci_free_consistent(adapter->pdev, cmd.size, cmd.va, cmd.dma);
+		dma_free_coherent(&adapter->pdev->dev, cmd.size, cmd.va,
+				  cmd.dma);
 	return status;
 
 }
@@ -3340,8 +3345,9 @@ int be_cmd_set_fw_log_level(struct be_adapter *adapter, u32 level)
 
 	memset(&extfat_cmd, 0, sizeof(struct be_dma_mem));
 	extfat_cmd.size = sizeof(struct be_cmd_resp_get_ext_fat_caps);
-	extfat_cmd.va = pci_alloc_consistent(adapter->pdev, extfat_cmd.size,
-					     &extfat_cmd.dma);
+	extfat_cmd.va = dma_zalloc_coherent(&adapter->pdev->dev,
+					    extfat_cmd.size, &extfat_cmd.dma,
+					    GFP_ATOMIC);
 	if (!extfat_cmd.va)
 		return -ENOMEM;
 
@@ -3363,8 +3369,8 @@ int be_cmd_set_fw_log_level(struct be_adapter *adapter, u32 level)
 
 	status = be_cmd_set_ext_fat_capabilites(adapter, &extfat_cmd, cfgs);
 err:
-	pci_free_consistent(adapter->pdev, extfat_cmd.size, extfat_cmd.va,
-			    extfat_cmd.dma);
+	dma_free_coherent(&adapter->pdev->dev, extfat_cmd.size, extfat_cmd.va,
+			  extfat_cmd.dma);
 	return status;
 }
 
@@ -3377,8 +3383,9 @@ int be_cmd_get_fw_log_level(struct be_adapter *adapter)
 
 	memset(&extfat_cmd, 0, sizeof(struct be_dma_mem));
 	extfat_cmd.size = sizeof(struct be_cmd_resp_get_ext_fat_caps);
-	extfat_cmd.va = pci_alloc_consistent(adapter->pdev, extfat_cmd.size,
-					     &extfat_cmd.dma);
+	extfat_cmd.va = dma_zalloc_coherent(&adapter->pdev->dev,
+					    extfat_cmd.size, &extfat_cmd.dma,
+					    GFP_ATOMIC);
 
 	if (!extfat_cmd.va) {
 		dev_err(&adapter->pdev->dev, "%s: Memory allocation failure\n",
@@ -3396,8 +3403,8 @@ int be_cmd_get_fw_log_level(struct be_adapter *adapter)
 				level = cfgs->module[0].trace_lvl[j].dbg_lvl;
 		}
 	}
-	pci_free_consistent(adapter->pdev, extfat_cmd.size, extfat_cmd.va,
-			    extfat_cmd.dma);
+	dma_free_coherent(&adapter->pdev->dev, extfat_cmd.size, extfat_cmd.va,
+			  extfat_cmd.dma);
 err:
 	return level;
 }
@@ -3595,7 +3602,8 @@ int be_cmd_get_func_config(struct be_adapter *adapter, struct be_resources *res)
 
 	memset(&cmd, 0, sizeof(struct be_dma_mem));
 	cmd.size = sizeof(struct be_cmd_resp_get_func_config);
-	cmd.va = pci_alloc_consistent(adapter->pdev, cmd.size, &cmd.dma);
+	cmd.va = dma_zalloc_coherent(&adapter->pdev->dev, cmd.size, &cmd.dma,
+				     GFP_ATOMIC);
 	if (!cmd.va) {
 		dev_err(&adapter->pdev->dev, "Memory alloc failure\n");
 		status = -ENOMEM;
@@ -3635,7 +3643,8 @@ int be_cmd_get_func_config(struct be_adapter *adapter, struct be_resources *res)
 err:
 	mutex_unlock(&adapter->mbox_lock);
 	if (cmd.va)
-		pci_free_consistent(adapter->pdev, cmd.size, cmd.va, cmd.dma);
+		dma_free_coherent(&adapter->pdev->dev, cmd.size, cmd.va,
+				  cmd.dma);
 	return status;
 }
 
@@ -3656,7 +3665,8 @@ int be_cmd_get_profile_config(struct be_adapter *adapter,
 
 	memset(&cmd, 0, sizeof(struct be_dma_mem));
 	cmd.size = sizeof(struct be_cmd_resp_get_profile_config);
-	cmd.va = pci_alloc_consistent(adapter->pdev, cmd.size, &cmd.dma);
+	cmd.va = dma_zalloc_coherent(&adapter->pdev->dev, cmd.size, &cmd.dma,
+				     GFP_ATOMIC);
 	if (!cmd.va)
 		return -ENOMEM;
 
@@ -3702,7 +3712,8 @@ int be_cmd_get_profile_config(struct be_adapter *adapter,
 		res->vf_if_cap_flags = vf_res->cap_flags;
 err:
 	if (cmd.va)
-		pci_free_consistent(adapter->pdev, cmd.size, cmd.va, cmd.dma);
+		dma_free_coherent(&adapter->pdev->dev, cmd.size, cmd.va,
+				  cmd.dma);
 	return status;
 }
 
@@ -3717,7 +3728,8 @@ static int be_cmd_set_profile_config(struct be_adapter *adapter, void *desc,
 
 	memset(&cmd, 0, sizeof(struct be_dma_mem));
 	cmd.size = sizeof(struct be_cmd_req_set_profile_config);
-	cmd.va = pci_alloc_consistent(adapter->pdev, cmd.size, &cmd.dma);
+	cmd.va = dma_zalloc_coherent(&adapter->pdev->dev, cmd.size, &cmd.dma,
+				     GFP_ATOMIC);
 	if (!cmd.va)
 		return -ENOMEM;
 
@@ -3733,7 +3745,8 @@ static int be_cmd_set_profile_config(struct be_adapter *adapter, void *desc,
 	status = be_cmd_notify_wait(adapter, &wrb);
 
 	if (cmd.va)
-		pci_free_consistent(adapter->pdev, cmd.size, cmd.va, cmd.dma);
+		dma_free_coherent(&adapter->pdev->dev, cmd.size, cmd.va,
+				  cmd.dma);
 	return status;
 }
 
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index b765c24..2835dee 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -264,8 +264,8 @@ static int lancer_cmd_read_file(struct be_adapter *adapter, u8 *file_name,
 	int status = 0;
 
 	read_cmd.size = LANCER_READ_FILE_CHUNK;
-	read_cmd.va = pci_alloc_consistent(adapter->pdev, read_cmd.size,
-					   &read_cmd.dma);
+	read_cmd.va = dma_zalloc_coherent(&adapter->pdev->dev, read_cmd.size,
+					  &read_cmd.dma, GFP_ATOMIC);
 
 	if (!read_cmd.va) {
 		dev_err(&adapter->pdev->dev,
@@ -289,8 +289,8 @@ static int lancer_cmd_read_file(struct be_adapter *adapter, u8 *file_name,
 			break;
 		}
 	}
-	pci_free_consistent(adapter->pdev, read_cmd.size, read_cmd.va,
-			    read_cmd.dma);
+	dma_free_coherent(&adapter->pdev->dev, read_cmd.size, read_cmd.va,
+			  read_cmd.dma);
 
 	return status;
 }
@@ -818,8 +818,9 @@ static int be_test_ddr_dma(struct be_adapter *adapter)
 	};
 
 	ddrdma_cmd.size = sizeof(struct be_cmd_req_ddrdma_test);
-	ddrdma_cmd.va = dma_alloc_coherent(&adapter->pdev->dev, ddrdma_cmd.size,
-					   &ddrdma_cmd.dma, GFP_KERNEL);
+	ddrdma_cmd.va = dma_zalloc_coherent(&adapter->pdev->dev,
+					    ddrdma_cmd.size, &ddrdma_cmd.dma,
+					    GFP_KERNEL);
 	if (!ddrdma_cmd.va)
 		return -ENOMEM;
 
@@ -941,8 +942,9 @@ static int be_read_eeprom(struct net_device *netdev,
 
 	memset(&eeprom_cmd, 0, sizeof(struct be_dma_mem));
 	eeprom_cmd.size = sizeof(struct be_cmd_req_seeprom_read);
-	eeprom_cmd.va = dma_alloc_coherent(&adapter->pdev->dev, eeprom_cmd.size,
-					   &eeprom_cmd.dma, GFP_KERNEL);
+	eeprom_cmd.va = dma_zalloc_coherent(&adapter->pdev->dev,
+					    eeprom_cmd.size, &eeprom_cmd.dma,
+					    GFP_KERNEL);
 
 	if (!eeprom_cmd.va)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6f9ffb9..e43cc8a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4605,8 +4605,8 @@ static int lancer_fw_download(struct be_adapter *adapter,
 
 	flash_cmd.size = sizeof(struct lancer_cmd_req_write_object)
 				+ LANCER_FW_DOWNLOAD_CHUNK;
-	flash_cmd.va = dma_alloc_coherent(dev, flash_cmd.size,
-					  &flash_cmd.dma, GFP_KERNEL);
+	flash_cmd.va = dma_zalloc_coherent(dev, flash_cmd.size,
+					   &flash_cmd.dma, GFP_KERNEL);
 	if (!flash_cmd.va)
 		return -ENOMEM;
 
@@ -4739,8 +4739,8 @@ static int be_fw_download(struct be_adapter *adapter, const struct firmware* fw)
 	}
 
 	flash_cmd.size = sizeof(struct be_cmd_write_flashrom);
-	flash_cmd.va = dma_alloc_coherent(dev, flash_cmd.size, &flash_cmd.dma,
-					  GFP_KERNEL);
+	flash_cmd.va = dma_zalloc_coherent(dev, flash_cmd.size, &flash_cmd.dma,
+					   GFP_KERNEL);
 	if (!flash_cmd.va)
 		return -ENOMEM;
 
@@ -5291,16 +5291,15 @@ static int be_drv_init(struct be_adapter *adapter)
 	int status = 0;
 
 	mbox_mem_alloc->size = sizeof(struct be_mcc_mailbox) + 16;
-	mbox_mem_alloc->va = dma_alloc_coherent(dev, mbox_mem_alloc->size,
-						&mbox_mem_alloc->dma,
-						GFP_KERNEL);
+	mbox_mem_alloc->va = dma_zalloc_coherent(dev, mbox_mem_alloc->size,
+						 &mbox_mem_alloc->dma,
+						 GFP_KERNEL);
 	if (!mbox_mem_alloc->va)
 		return -ENOMEM;
 
 	mbox_mem_align->size = sizeof(struct be_mcc_mailbox);
 	mbox_mem_align->va = PTR_ALIGN(mbox_mem_alloc->va, 16);
 	mbox_mem_align->dma = PTR_ALIGN(mbox_mem_alloc->dma, 16);
-	memset(mbox_mem_align->va, 0, sizeof(struct be_mcc_mailbox));
 
 	rx_filter->size = sizeof(struct be_cmd_req_rx_filter);
 	rx_filter->va = dma_zalloc_coherent(dev, rx_filter->size,
-- 
2.2.0.65.g9abc44b
