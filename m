From: amit.salecha@qlogic.com
Subject: [PATCHv3 NEXT 4/5] qlcnic: aer support
Date: Tue, 13 Jul 2010 23:33:34 -0700
Message-ID: <1279089215-23231-5-git-send-email-amit.salecha@qlogic.com>
References: <1279089215-23231-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:7903 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752389Ab0GNGdg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jul 2010 02:33:36 -0400
In-Reply-To: <1279089215-23231-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Pci error recovery support added.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    1 +
 drivers/net/qlcnic/qlcnic_main.c |  137 +++++++++++++++++++++++++++++++++++++-
 2 files changed, 137 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 02a50e6..0644642 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -911,6 +911,7 @@ struct qlcnic_mac_req {
 #define __QLCNIC_DEV_UP 		1
 #define __QLCNIC_RESETTING		2
 #define __QLCNIC_START_FW 		4
+#define __QLCNIC_AER			5
 
 #define QLCNIC_INTERRUPT_TEST		1
 #define QLCNIC_LOOPBACK_TEST		2
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 0995f90..d5c94a3 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -34,6 +34,7 @@
 #include <linux/ipv6.h>
 #include <linux/inetdevice.h>
 #include <linux/sysfs.h>
+#include <linux/aer.h>
 
 MODULE_DESCRIPTION("QLogic 1/10 GbE Converged/Intelligent Ethernet Driver");
 MODULE_LICENSE("GPL");
@@ -1306,6 +1307,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_disable_pdev;
 
 	pci_set_master(pdev);
+	pci_enable_pcie_error_reporting(pdev);
 
 	netdev = alloc_etherdev(sizeof(struct qlcnic_adapter));
 	if (!netdev) {
@@ -1437,6 +1439,7 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 
 	qlcnic_release_firmware(adapter);
 
+	pci_disable_pcie_error_reporting(pdev);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
@@ -2521,6 +2524,9 @@ static void
 qlcnic_schedule_work(struct qlcnic_adapter *adapter,
 		work_func_t func, int delay)
 {
+	if (test_bit(__QLCNIC_AER, &adapter->state))
+		return;
+
 	INIT_DELAYED_WORK(&adapter->fw_work, func);
 	schedule_delayed_work(&adapter->fw_work, round_jiffies_relative(delay));
 }
@@ -2631,6 +2637,128 @@ reschedule:
 	qlcnic_schedule_work(adapter, qlcnic_fw_poll_work, FW_POLL_DELAY);
 }
 
+static int qlcnic_is_first_func(struct pci_dev *pdev)
+{
+	struct pci_dev *oth_pdev;
+	int val = pdev->devfn;
+
+	while (val-- > 0) {
+		oth_pdev = pci_get_domain_bus_and_slot(pci_domain_nr
+			(pdev->bus), pdev->bus->number,
+			PCI_DEVFN(PCI_SLOT(pdev->devfn), val));
+
+		if (oth_pdev && (oth_pdev->current_state != PCI_D3cold))
+			return 0;
+	}
+	return 1;
+}
+
+static int qlcnic_attach_func(struct pci_dev *pdev)
+{
+	int err, first_func;
+	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
+	struct net_device *netdev = adapter->netdev;
+
+	pdev->error_state = pci_channel_io_normal;
+
+	err = pci_enable_device(pdev);
+	if (err)
+		return err;
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_set_master(pdev);
+	pci_restore_state(pdev);
+
+	first_func = qlcnic_is_first_func(pdev);
+
+	if (qlcnic_api_lock(adapter))
+		return -EINVAL;
+
+	if (first_func) {
+		adapter->need_fw_reset = 1;
+		set_bit(__QLCNIC_START_FW, &adapter->state);
+		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
+		QLCDB(adapter, DRV, "Restarting fw\n");
+	}
+	qlcnic_api_unlock(adapter);
+
+	err = adapter->nic_ops->start_firmware(adapter);
+	if (err)
+		return err;
+
+	qlcnic_clr_drv_state(adapter);
+	qlcnic_setup_intr(adapter);
+
+	if (netif_running(netdev)) {
+		err = qlcnic_attach(adapter);
+		if (err) {
+			qlcnic_clr_all_drv_state(adapter);
+			clear_bit(__QLCNIC_AER, &adapter->state);
+			netif_device_attach(netdev);
+			return err;
+		}
+
+		err = qlcnic_up(adapter, netdev);
+		if (err)
+			goto done;
+
+		qlcnic_config_indev_addr(netdev, NETDEV_UP);
+	}
+ done:
+	netif_device_attach(netdev);
+	return err;
+}
+
+static pci_ers_result_t qlcnic_io_error_detected(struct pci_dev *pdev,
+						pci_channel_state_t state)
+{
+	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
+	struct net_device *netdev = adapter->netdev;
+
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
+
+	if (state == pci_channel_io_normal)
+		return PCI_ERS_RESULT_RECOVERED;
+
+	set_bit(__QLCNIC_AER, &adapter->state);
+	netif_device_detach(netdev);
+
+	cancel_delayed_work_sync(&adapter->fw_work);
+
+	if (netif_running(netdev))
+		qlcnic_down(adapter, netdev);
+
+	qlcnic_detach(adapter);
+	qlcnic_teardown_intr(adapter);
+
+	clear_bit(__QLCNIC_RESETTING, &adapter->state);
+
+	pci_save_state(pdev);
+	pci_disable_device(pdev);
+
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+static pci_ers_result_t qlcnic_io_slot_reset(struct pci_dev *pdev)
+{
+	return qlcnic_attach_func(pdev) ? PCI_ERS_RESULT_DISCONNECT :
+				PCI_ERS_RESULT_RECOVERED;
+}
+
+static void qlcnic_io_resume(struct pci_dev *pdev)
+{
+	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
+
+	pci_cleanup_aer_uncorrect_error_status(pdev);
+
+	if (QLCRD32(adapter, QLCNIC_CRB_DEV_STATE) == QLCNIC_DEV_READY &&
+	    test_and_clear_bit(__QLCNIC_AER, &adapter->state))
+		qlcnic_schedule_work(adapter, qlcnic_fw_poll_work,
+						FW_POLL_DELAY);
+}
+
+
 static int
 qlcnicvf_start_firmware(struct qlcnic_adapter *adapter)
 {
@@ -3436,6 +3564,11 @@ static void
 qlcnic_config_indev_addr(struct net_device *dev, unsigned long event)
 { }
 #endif
+static struct pci_error_handlers qlcnic_err_handler = {
+	.error_detected = qlcnic_io_error_detected,
+	.slot_reset = qlcnic_io_slot_reset,
+	.resume = qlcnic_io_resume,
+};
 
 static struct pci_driver qlcnic_driver = {
 	.name = qlcnic_driver_name,
@@ -3446,7 +3579,9 @@ static struct pci_driver qlcnic_driver = {
 	.suspend = qlcnic_suspend,
 	.resume = qlcnic_resume,
 #endif
-	.shutdown = qlcnic_shutdown
+	.shutdown = qlcnic_shutdown,
+	.err_handler = &qlcnic_err_handler
+
 };
 
 static int __init qlcnic_init_module(void)
-- 
1.6.0.2

