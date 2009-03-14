From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 2/6] netxen: add suspend resume support
Date: Fri, 13 Mar 2009 17:52:02 -0700
Message-ID: <1236991926-17892-3-git-send-email-dhananjay@netxen.com>
References: <1236991926-17892-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:47271 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760835AbZCNAwN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 20:52:13 -0400
In-Reply-To: <1236991926-17892-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detach network interface on PCI suspend and recreate hardware
context after resumes.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    1 +
 drivers/net/netxen/netxen_nic_hw.c   |   17 ++++++
 drivers/net/netxen/netxen_nic_main.c |  102 ++++++++++++++++++++++++++++------
 3 files changed, 102 insertions(+), 18 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 6185070..75cb30f 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1389,6 +1389,7 @@ void netxen_nic_read_w1(struct netxen_adapter *adapter, u32 index, u32 *value);
 
 int netxen_nic_get_board_info(struct netxen_adapter *adapter);
 void netxen_nic_get_firmware_info(struct netxen_adapter *adapter);
+int netxen_nic_wol_supported(struct netxen_adapter *adapter);
 
 int netxen_nic_hw_read_wx_128M(struct netxen_adapter *adapter,
 		ulong off, void *data, int len);
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 8db4ac3..c8faa53 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -2320,3 +2320,20 @@ void netxen_nic_get_firmware_info(struct netxen_adapter *adapter)
 	}
 }
 
+int
+netxen_nic_wol_supported(struct netxen_adapter *adapter)
+{
+	u32 wol_cfg;
+
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
+		return 0;
+
+	wol_cfg = netxen_nic_reg_read(adapter, NETXEN_WOL_CONFIG_NV);
+	if (wol_cfg & (1UL << adapter->portnum)) {
+		wol_cfg = netxen_nic_reg_read(adapter, NETXEN_WOL_CONFIG);
+		if (wol_cfg & (1 << adapter->portnum))
+			return 1;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 9445277..555b459 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -643,6 +643,18 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 	int val, err, first_boot;
 	struct pci_dev *pdev = adapter->pdev;
 
+	int first_driver = 0;
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
+		if (adapter->ahw.pci_func == 0)
+			first_driver = 1;
+	} else {
+		if (adapter->portnum == 0)
+			first_driver = 1;
+	}
+
+	if (!first_driver)
+		return 0;
+
 	first_boot = adapter->pci_read_normalize(adapter,
 			NETXEN_CAM_RAM(0x1fc));
 
@@ -859,7 +871,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct net_device *netdev = NULL;
 	struct netxen_adapter *adapter = NULL;
 	int i = 0, err;
-	int first_driver;
 	int pci_func_id = PCI_FUNC(pdev->devfn);
 	uint8_t revision_id;
 
@@ -978,20 +989,9 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 */
 	netxen_check_options(adapter);
 
-	first_driver = 0;
-	if (NX_IS_REVISION_P3(revision_id)) {
-		if (adapter->ahw.pci_func == 0)
-			first_driver = 1;
-	} else {
-		if (adapter->portnum == 0)
-			first_driver = 1;
-	}
-
-	if (first_driver) {
-		err = netxen_start_firmware(adapter);
-		if (err)
-			goto err_out_iounmap;
-	}
+	err = netxen_start_firmware(adapter);
+	if (err)
+		goto err_out_iounmap;
 
 	nx_update_dma_mask(adapter);
 
@@ -1062,8 +1062,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 err_out_disable_msi:
 	netxen_teardown_intr(adapter);
 
-	if (first_driver)
-		netxen_free_adapter_offload(adapter);
+	netxen_free_adapter_offload(adapter);
 
 err_out_iounmap:
 	netxen_cleanup_pci_map(adapter);
@@ -1114,6 +1113,71 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 	free_netdev(netdev);
 }
 
+static int
+netxen_nic_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+
+	struct netxen_adapter *adapter = pci_get_drvdata(pdev);
+	struct net_device *netdev = adapter->netdev;
+
+	netif_device_detach(netdev);
+
+	if (netif_running(netdev))
+		netxen_nic_down(adapter, netdev);
+
+	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC)
+		netxen_nic_detach(adapter);
+
+	pci_save_state(pdev);
+
+	if (netxen_nic_wol_supported(adapter)) {
+		pci_enable_wake(pdev, PCI_D3cold, 1);
+		pci_enable_wake(pdev, PCI_D3hot, 1);
+	}
+
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+
+	return 0;
+}
+
+static int
+netxen_nic_resume(struct pci_dev *pdev)
+{
+	struct netxen_adapter *adapter = pci_get_drvdata(pdev);
+	struct net_device *netdev = adapter->netdev;
+	int err;
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+
+	err = pci_enable_device(pdev);
+	if (err)
+		return err;
+
+	adapter->curr_window = 255;
+
+	err = netxen_start_firmware(adapter);
+	if (err) {
+		dev_err(&pdev->dev, "failed to start firmware\n");
+		return err;
+	}
+
+	if (netif_running(netdev)) {
+		err = netxen_nic_attach(adapter);
+		if (err)
+			return err;
+
+		err = netxen_nic_up(adapter, netdev);
+		if (err)
+			return err;
+
+		netif_device_attach(netdev);
+	}
+
+	return 0;
+}
+
 static int netxen_nic_open(struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
@@ -1649,7 +1713,9 @@ static struct pci_driver netxen_driver = {
 	.name = netxen_nic_driver_name,
 	.id_table = netxen_pci_tbl,
 	.probe = netxen_nic_probe,
-	.remove = __devexit_p(netxen_nic_remove)
+	.remove = __devexit_p(netxen_nic_remove),
+	.suspend = netxen_nic_suspend,
+	.resume = netxen_nic_resume
 };
 
 /* Driver Registration on NetXen card    */
-- 
1.6.0.2

