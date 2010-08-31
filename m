From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 03/10] qlcnic: fix mac addr read
Date: Tue, 31 Aug 2010 07:29:33 -0700
Message-ID: <1283264980-25881-4-git-send-email-amit.salecha@qlogic.com>
References: <1283264980-25881-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:57099 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757457Ab0HaO3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 10:29:41 -0400
In-Reply-To: <1283264980-25881-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o Mac addr was read from flash for every fw reset
for Non-priviledge function.It should be read only once.
o Remove unnecessary get_mac_addr callback

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    2 --
 drivers/net/qlcnic/qlcnic_hw.c   |   13 -------------
 drivers/net/qlcnic/qlcnic_main.c |   28 +++++++++++++---------------
 3 files changed, 13 insertions(+), 30 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index b35fc8e..9c87044 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1260,7 +1260,6 @@ int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable);
 int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter);
 void qlcnic_update_cmd_producer(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_tx_ring *tx_ring);
-int qlcnic_get_mac_addr(struct qlcnic_adapter *adapter, u8 *mac);
 void qlcnic_clear_ilb_mode(struct qlcnic_adapter *adapter);
 int qlcnic_set_ilb_mode(struct qlcnic_adapter *adapter);
 void qlcnic_fetch_mac(struct qlcnic_adapter *, u32, u32, u8, u8 *);
@@ -1347,7 +1346,6 @@ static inline u32 qlcnic_tx_avail(struct qlcnic_host_tx_ring *tx_ring)
 extern const struct ethtool_ops qlcnic_ethtool_ops;
 
 struct qlcnic_nic_template {
-	int (*get_mac_addr) (struct qlcnic_adapter *, u8*);
 	int (*config_bridged_mode) (struct qlcnic_adapter *, u32);
 	int (*config_led) (struct qlcnic_adapter *, u32, u32);
 	int (*start_firmware) (struct qlcnic_adapter *);
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 5e6f486..670a54a 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -715,19 +715,6 @@ int qlcnic_change_mtu(struct net_device *netdev, int mtu)
 	return rc;
 }
 
-int qlcnic_get_mac_addr(struct qlcnic_adapter *adapter, u8 *mac)
-{
-	u32 crbaddr;
-	int pci_func = adapter->ahw.pci_func;
-
-	crbaddr = CRB_MAC_BLOCK_START +
-		(4 * ((pci_func/2) * 3)) + (4 * (pci_func & 1));
-
-	qlcnic_fetch_mac(adapter, crbaddr, crbaddr+4, pci_func & 1, mac);
-
-	return 0;
-}
-
 /*
  * Changes the CRB window to the specified window.
  */
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 771a160..3f2f93b 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -322,7 +322,7 @@ qlcnic_read_mac_addr(struct qlcnic_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 
-	if (adapter->nic_ops->get_mac_addr(adapter, mac_addr) != 0)
+	if (qlcnic_get_mac_address(adapter, mac_addr) != 0)
 		return -EIO;
 
 	memcpy(netdev->dev_addr, mac_addr, ETH_ALEN);
@@ -378,14 +378,12 @@ static const struct net_device_ops qlcnic_netdev_ops = {
 };
 
 static struct qlcnic_nic_template qlcnic_ops = {
-	.get_mac_addr = qlcnic_get_mac_address,
 	.config_bridged_mode = qlcnic_config_bridged_mode,
 	.config_led = qlcnic_config_led,
 	.start_firmware = qlcnic_start_firmware
 };
 
 static struct qlcnic_nic_template qlcnic_vf_ops = {
-	.get_mac_addr = qlcnic_get_mac_address,
 	.config_bridged_mode = qlcnicvf_config_bridged_mode,
 	.config_led = qlcnicvf_config_led,
 	.start_firmware = qlcnicvf_start_firmware
@@ -668,7 +666,6 @@ static void
 qlcnic_check_options(struct qlcnic_adapter *adapter)
 {
 	u32 fw_major, fw_minor, fw_build;
-	char brd_name[QLCNIC_MAX_BOARD_NAME_LEN];
 	struct pci_dev *pdev = adapter->pdev;
 	struct qlcnic_info nic_info;
 
@@ -678,17 +675,6 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 
 	adapter->fw_version = QLCNIC_VERSION_CODE(fw_major, fw_minor, fw_build);
 
-	if (!(adapter->flags & QLCNIC_ADAPTER_INITIALIZED))
-		if (qlcnic_read_mac_addr(adapter))
-			dev_warn(&pdev->dev, "failed to read mac addr\n");
-	if (adapter->portnum == 0) {
-		get_brd_name(adapter, brd_name);
-
-		pr_info("%s: %s Board Chip rev 0x%x\n",
-				module_name(THIS_MODULE),
-				brd_name, adapter->ahw.revision_id);
-	}
-
 	dev_info(&pdev->dev, "firmware v%d.%d.%d\n",
 			fw_major, fw_minor, fw_build);
 
@@ -1468,6 +1454,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	int err;
 	uint8_t revision_id;
 	uint8_t pci_using_dac;
+	char brd_name[QLCNIC_MAX_BOARD_NAME_LEN];
 
 	err = pci_enable_device(pdev);
 	if (err)
@@ -1535,6 +1522,17 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_decr_ref;
 	}
 
+	if (qlcnic_read_mac_addr(adapter))
+		dev_warn(&pdev->dev, "failed to read mac addr\n");
+
+	if (adapter->portnum == 0) {
+		get_brd_name(adapter, brd_name);
+
+		pr_info("%s: %s Board Chip rev 0x%x\n",
+				module_name(THIS_MODULE),
+				brd_name, adapter->ahw.revision_id);
+	}
+
 	qlcnic_clear_stats(adapter);
 
 	qlcnic_setup_intr(adapter);
-- 
1.6.0.2

