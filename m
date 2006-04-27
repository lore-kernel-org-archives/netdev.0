From: akpm@osdl.org
Subject: [patch 4/9] PCI Error Recovery: e1000 network device driver
Date: Thu, 27 Apr 2006 02:30:38 -0700
Message-ID: <200604270932.k3R9W6j6025318@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, linas@linas.org,
	jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15823 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965024AbWD0JcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 05:32:13 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Linas Vepstas <linas@linas.org>

Various PCI bus errors can be signaled by newer PCI controllers.  This
patch adds the PCI error recovery callbacks to the intel gigabit ethernet
e1000 device driver.  The patch has been tested, and appears to work well.

[akpm@osdl.org: minor cleanups]
Signed-off-by: Linas Vepstas <linas@linas.org>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/e1000/e1000_main.c |  116 ++++++++++++++++++++++++++++++-
 1 files changed, 115 insertions(+), 1 deletion(-)

diff -puN drivers/net/e1000/e1000_main.c~pci-error-recovery-e1000-network-device-driver drivers/net/e1000/e1000_main.c
--- devel/drivers/net/e1000/e1000_main.c~pci-error-recovery-e1000-network-device-driver	2006-04-22 01:39:15.000000000 -0700
+++ devel-akpm/drivers/net/e1000/e1000_main.c	2006-04-22 01:39:15.000000000 -0700
@@ -227,6 +227,16 @@ static int e1000_resume(struct pci_dev *
 static void e1000_netpoll (struct net_device *netdev);
 #endif
 
+static pci_ers_result_t e1000_io_error_detected(struct pci_dev *pdev,
+                     pci_channel_state_t state);
+static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev);
+static void e1000_io_resume(struct pci_dev *pdev);
+
+static struct pci_error_handlers e1000_err_handler = {
+	.error_detected = e1000_io_error_detected,
+	.slot_reset = e1000_io_slot_reset,
+	.resume = e1000_io_resume,
+};
 
 static struct pci_driver e1000_driver = {
 	.name     = e1000_driver_name,
@@ -236,8 +246,9 @@ static struct pci_driver e1000_driver = 
 	/* Power Managment Hooks */
 #ifdef CONFIG_PM
 	.suspend  = e1000_suspend,
-	.resume   = e1000_resume
+	.resume   = e1000_resume,
 #endif
+	.err_handler = &e1000_err_handler,
 };
 
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
@@ -3076,6 +3087,10 @@ e1000_update_stats(struct e1000_adapter 
 
 #define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
 
+	/* Prevent stats update while adapter is being reset */
+	if (adapter->link_speed == 0)
+		return;
+
 	spin_lock_irqsave(&adapter->stats_lock, flags);
 
 	/* these counters are modified from e1000_adjust_tbi_stats,
@@ -4625,4 +4640,103 @@ e1000_netpoll(struct net_device *netdev)
 }
 #endif
 
+/**
+ * e1000_io_error_detected - called when PCI error is detected
+ * @pdev: Pointer to PCI device
+ * @state: The current pci conneection state
+ *
+ * This function is called after a PCI bus error affecting
+ * this device has been detected.
+ */
+static pci_ers_result_t e1000_io_error_detected(struct pci_dev *pdev,
+						pci_channel_state_t state)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct e1000_adapter *adapter = netdev->priv;
+
+	netif_device_detach(netdev);
+
+	if (netif_running(netdev))
+		e1000_down(adapter);
+
+	/* Request a slot slot reset. */
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/**
+ * e1000_io_slot_reset - called after the pci bus has been reset.
+ * @pdev: Pointer to PCI device
+ *
+ * Restart the card from scratch, as if from a cold-boot. Implementation
+ * resembles the first-half of the e1000_resume routine.
+ */
+static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct e1000_adapter *adapter = netdev->priv;
+
+	if (pci_enable_device(pdev)) {
+		printk(KERN_ERR "e1000: Cannot re-enable PCI device after "
+				"reset.\n");
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+	pci_set_master(pdev);
+
+	pci_enable_wake(pdev, 3, 0);
+	pci_enable_wake(pdev, 4, 0); /* 4 == D3 cold */
+
+	/* Perform card reset only on one instance of the card */
+	if (PCI_FUNC (pdev->devfn) != 0)
+		return PCI_ERS_RESULT_RECOVERED;
+
+	e1000_reset(adapter);
+	E1000_WRITE_REG(&adapter->hw, WUS, ~0);
+
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+/**
+ * e1000_io_resume - called when traffic can start flowing again.
+ * @pdev: Pointer to PCI device
+ *
+ * This callback is called when the error recovery driver tells us that
+ * its OK to resume normal operation. Implementation resembles the
+ * second-half of the e1000_resume routine.
+ */
+static void e1000_io_resume(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct e1000_adapter *adapter = netdev->priv;
+	uint32_t manc, swsm;
+
+	if (netif_running(netdev)) {
+		if (e1000_up(adapter)) {
+			printk(KERN_ERR "e1000: can't bring device back up "
+					"after reset\n");
+			return;
+		}
+	}
+
+	netif_device_attach(netdev);
+
+	if (adapter->hw.mac_type >= e1000_82540 &&
+	    adapter->hw.media_type == e1000_media_type_copper) {
+		manc = E1000_READ_REG(&adapter->hw, MANC);
+		manc &= ~(E1000_MANC_ARP_EN);
+		E1000_WRITE_REG(&adapter->hw, MANC, manc);
+	}
+
+	switch (adapter->hw.mac_type) {
+	case e1000_82573:
+		swsm = E1000_READ_REG(&adapter->hw, SWSM);
+		E1000_WRITE_REG(&adapter->hw, SWSM, swsm | E1000_SWSM_DRV_LOAD);
+		break;
+	default:
+		break;
+	}
+
+	if (netif_running(netdev))
+		mod_timer(&adapter->watchdog_timer, jiffies);
+}
+
 /* e1000_main.c */
_
