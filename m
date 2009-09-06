From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 5/6] netxen: refactor firmware info code
Date: Sat,  5 Sep 2009 20:43:11 -0700
Message-ID: <1252208592-2240-6-git-send-email-dhananjay@netxen.com>
References: <1252208592-2240-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:25068 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1754037AbZIFDnM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Sep 2009 23:43:12 -0400
In-Reply-To: <1252208592-2240-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Combine netxen_get_firmware_info(), netxen_check_options()
  so that they are updated every time firmware is reset.
o Set dma mask everytime firmware is reset.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    1 -
 drivers/net/netxen/netxen_nic_hw.c   |   59 --------------
 drivers/net/netxen/netxen_nic_main.c |  141 +++++++++++++++++++++++----------
 3 files changed, 98 insertions(+), 103 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 5bbc40b..df03ea4 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1263,7 +1263,6 @@ void netxen_pcie_sem_unlock(struct netxen_adapter *, int);
 	netxen_pcie_sem_unlock((a), 7)
 
 int netxen_nic_get_board_info(struct netxen_adapter *adapter);
-void netxen_nic_get_firmware_info(struct netxen_adapter *adapter);
 int netxen_nic_wol_supported(struct netxen_adapter *adapter);
 
 /* Functions from netxen_nic_init.c */
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index cbfd610..555bc4a 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -2240,65 +2240,6 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter)
 	}
 }
 
-void netxen_nic_get_firmware_info(struct netxen_adapter *adapter)
-{
-	u32 fw_major, fw_minor, fw_build;
-	char brd_name[NETXEN_MAX_SHORT_NAME];
-	char serial_num[32];
-	int i, offset, val;
-	int *ptr32;
-	struct pci_dev *pdev = adapter->pdev;
-
-	adapter->driver_mismatch = 0;
-
-	ptr32 = (int *)&serial_num;
-	offset = NX_FW_SERIAL_NUM_OFFSET;
-	for (i = 0; i < 8; i++) {
-		if (netxen_rom_fast_read(adapter, offset, &val) == -1) {
-			dev_err(&pdev->dev, "error reading board info\n");
-			adapter->driver_mismatch = 1;
-			return;
-		}
-		ptr32[i] = cpu_to_le32(val);
-		offset += sizeof(u32);
-	}
-
-	fw_major = NXRD32(adapter, NETXEN_FW_VERSION_MAJOR);
-	fw_minor = NXRD32(adapter, NETXEN_FW_VERSION_MINOR);
-	fw_build = NXRD32(adapter, NETXEN_FW_VERSION_SUB);
-
-	adapter->fw_version = NETXEN_VERSION_CODE(fw_major, fw_minor, fw_build);
-
-	if (adapter->portnum == 0) {
-		get_brd_name_by_type(adapter->ahw.board_type, brd_name);
-
-		printk(KERN_INFO "NetXen %s Board S/N %s  Chip rev 0x%x\n",
-				brd_name, serial_num, adapter->ahw.revision_id);
-	}
-
-	if (adapter->fw_version < NETXEN_VERSION_CODE(3, 4, 216)) {
-		adapter->driver_mismatch = 1;
-		dev_warn(&pdev->dev, "firmware version %d.%d.%d unsupported\n",
-				fw_major, fw_minor, fw_build);
-		return;
-	}
-
-	dev_info(&pdev->dev, "firmware version %d.%d.%d\n",
-			fw_major, fw_minor, fw_build);
-
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
-		i = NXRD32(adapter, NETXEN_SRE_MISC);
-		adapter->ahw.cut_through = (i & 0x8000) ? 1 : 0;
-		dev_info(&pdev->dev, "firmware running in %s mode\n",
-		adapter->ahw.cut_through ? "cut-through" : "legacy");
-	}
-
-	if (adapter->fw_version >= NETXEN_VERSION_CODE(4, 0, 222))
-		adapter->capabilities = NXRD32(adapter, CRB_FW_CAPABILITIES_1);
-
-	adapter->flags &= ~NETXEN_NIC_LRO_ENABLED;
-}
-
 int
 netxen_nic_wol_supported(struct netxen_adapter *adapter)
 {
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index b2fd713..304618a 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -318,44 +318,6 @@ err_out:
 	return err;
 }
 
-static void
-netxen_check_options(struct netxen_adapter *adapter)
-{
-	if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
-		adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_10G;
-		adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_10G;
-	} else if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
-		adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_1G;
-		adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_1G;
-	}
-
-	adapter->msix_supported = 0;
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
-		adapter->msix_supported = !!use_msi_x;
-		adapter->rss_supported = !!use_msi_x;
-	} else if (adapter->fw_version >= NETXEN_VERSION_CODE(3, 4, 336)) {
-		switch (adapter->ahw.board_type) {
-		case NETXEN_BRDTYPE_P2_SB31_10G:
-		case NETXEN_BRDTYPE_P2_SB31_10G_CX4:
-			adapter->msix_supported = !!use_msi_x;
-			adapter->rss_supported = !!use_msi_x;
-			break;
-		default:
-			break;
-		}
-	}
-
-	adapter->num_txd = MAX_CMD_DESCRIPTORS;
-
-	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
-		adapter->num_lro_rxd = MAX_LRO_RCV_DESCRIPTORS;
-		adapter->max_rds_rings = 3;
-	} else {
-		adapter->num_lro_rxd = 0;
-		adapter->max_rds_rings = 2;
-	}
-}
-
 static int
 netxen_check_hw_init(struct netxen_adapter *adapter, int first_boot)
 {
@@ -733,12 +695,110 @@ err_out:
 	return err;
 }
 
+static void
+netxen_check_options(struct netxen_adapter *adapter)
+{
+	u32 fw_major, fw_minor, fw_build;
+	char brd_name[NETXEN_MAX_SHORT_NAME];
+	char serial_num[32];
+	int i, offset, val;
+	int *ptr32;
+	struct pci_dev *pdev = adapter->pdev;
+
+	adapter->driver_mismatch = 0;
+
+	ptr32 = (int *)&serial_num;
+	offset = NX_FW_SERIAL_NUM_OFFSET;
+	for (i = 0; i < 8; i++) {
+		if (netxen_rom_fast_read(adapter, offset, &val) == -1) {
+			dev_err(&pdev->dev, "error reading board info\n");
+			adapter->driver_mismatch = 1;
+			return;
+		}
+		ptr32[i] = cpu_to_le32(val);
+		offset += sizeof(u32);
+	}
+
+	fw_major = NXRD32(adapter, NETXEN_FW_VERSION_MAJOR);
+	fw_minor = NXRD32(adapter, NETXEN_FW_VERSION_MINOR);
+	fw_build = NXRD32(adapter, NETXEN_FW_VERSION_SUB);
+
+	adapter->fw_version = NETXEN_VERSION_CODE(fw_major, fw_minor, fw_build);
+
+	if (adapter->portnum == 0) {
+		get_brd_name_by_type(adapter->ahw.board_type, brd_name);
+
+		printk(KERN_INFO "NetXen %s Board S/N %s  Chip rev 0x%x\n",
+				brd_name, serial_num, adapter->ahw.revision_id);
+	}
+
+	if (adapter->fw_version < NETXEN_VERSION_CODE(3, 4, 216)) {
+		adapter->driver_mismatch = 1;
+		dev_warn(&pdev->dev, "firmware version %d.%d.%d unsupported\n",
+				fw_major, fw_minor, fw_build);
+		return;
+	}
+
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
+		i = NXRD32(adapter, NETXEN_SRE_MISC);
+		adapter->ahw.cut_through = (i & 0x8000) ? 1 : 0;
+	}
+
+	dev_info(&pdev->dev, "firmware v%d.%d.%d [%s]\n",
+			fw_major, fw_minor, fw_build,
+			adapter->ahw.cut_through ? "cut-through" : "legacy");
+
+	if (adapter->fw_version >= NETXEN_VERSION_CODE(4, 0, 222))
+		adapter->capabilities = NXRD32(adapter, CRB_FW_CAPABILITIES_1);
+
+	adapter->flags &= ~NETXEN_NIC_LRO_ENABLED;
+
+	if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
+		adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_10G;
+		adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_10G;
+	} else if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
+		adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_1G;
+		adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_1G;
+	}
+
+	adapter->msix_supported = 0;
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
+		adapter->msix_supported = !!use_msi_x;
+		adapter->rss_supported = !!use_msi_x;
+	} else if (adapter->fw_version >= NETXEN_VERSION_CODE(3, 4, 336)) {
+		switch (adapter->ahw.board_type) {
+		case NETXEN_BRDTYPE_P2_SB31_10G:
+		case NETXEN_BRDTYPE_P2_SB31_10G_CX4:
+			adapter->msix_supported = !!use_msi_x;
+			adapter->rss_supported = !!use_msi_x;
+			break;
+		default:
+			break;
+		}
+	}
+
+	adapter->num_txd = MAX_CMD_DESCRIPTORS;
+
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+		adapter->num_lro_rxd = MAX_LRO_RCV_DESCRIPTORS;
+		adapter->max_rds_rings = 3;
+	} else {
+		adapter->num_lro_rxd = 0;
+		adapter->max_rds_rings = 2;
+	}
+}
+
 static int
 netxen_start_firmware(struct netxen_adapter *adapter)
 {
 	int val, err, first_boot;
 	struct pci_dev *pdev = adapter->pdev;
 
+	/* required for NX2031 dummy dma */
+	err = nx_set_dma_mask(adapter);
+	if (err)
+		return err;
+
 	if (!netxen_can_start_firmware(adapter))
 		goto wait_init;
 
@@ -811,7 +871,6 @@ wait_init:
 
 	nx_update_dma_mask(adapter);
 
-	netxen_nic_get_firmware_info(adapter);
 	netxen_check_options(adapter);
 
 	return 0;
@@ -1191,10 +1250,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	revision_id = pdev->revision;
 	adapter->ahw.revision_id = revision_id;
 
-	err = nx_set_dma_mask(adapter);
-	if (err)
-		goto err_out_free_netdev;
-
 	rwlock_init(&adapter->adapter_lock);
 	spin_lock_init(&adapter->tx_clean_lock);
 	INIT_LIST_HEAD(&adapter->mac_list);
-- 
1.6.0.2

