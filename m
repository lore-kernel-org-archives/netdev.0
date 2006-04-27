From: akpm@osdl.org
Subject: [patch 5/9] PCI Error Recovery: e100 network device driver
Date: Thu, 27 Apr 2006 02:30:39 -0700
Message-ID: <200604270932.k3R9W76P025321@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, linas@linas.org,
	jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16591 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965025AbWD0JcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 05:32:13 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: linas@austin.ibm.com (Linas Vepstas)

Various PCI bus errors can be signaled by newer PCI controllers.  This
patch adds the PCI error recovery callbacks to the intel ethernet e100
device driver.  The patch has been tested, and appears to work well.

Signed-off-by: Linas Vepstas <linas@linas.org>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/e100.c |   75 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 75 insertions(+)

diff -puN drivers/net/e100.c~pci-error-recovery-e100-network-device-driver drivers/net/e100.c
--- devel/drivers/net/e100.c~pci-error-recovery-e100-network-device-driver	2006-04-10 23:21:20.000000000 -0700
+++ devel-akpm/drivers/net/e100.c	2006-04-10 23:21:20.000000000 -0700
@@ -2726,6 +2726,80 @@ static void e100_shutdown(struct pci_dev
 		DPRINTK(PROBE,ERR, "Error enabling wake\n");
 }
 
+/* ------------------ PCI Error Recovery infrastructure  -------------- */
+/**
+ * e100_io_error_detected - called when PCI error is detected.
+ * @pdev: Pointer to PCI device
+ * @state: The current pci conneection state
+ */
+static pci_ers_result_t e100_io_error_detected(struct pci_dev *pdev, pci_channel_state_t state)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+
+	/* Similar to calling e100_down(), but avoids adpater I/O. */
+	netdev->stop(netdev);
+
+	/* Detach; put netif into state similar to hotplug unplug. */
+	netif_poll_enable(netdev);
+	netif_device_detach(netdev);
+
+	/* Request a slot reset. */
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/**
+ * e100_io_slot_reset - called after the pci bus has been reset.
+ * @pdev: Pointer to PCI device
+ *
+ * Restart the card from scratch.
+ */
+static pci_ers_result_t e100_io_slot_reset(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct nic *nic = netdev_priv(netdev);
+
+	if (pci_enable_device(pdev)) {
+		printk(KERN_ERR "e100: Cannot re-enable PCI device after reset.\n");
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+	pci_set_master(pdev);
+
+	/* Only one device per card can do a reset */
+	if (0 != PCI_FUNC(pdev->devfn))
+		return PCI_ERS_RESULT_RECOVERED;
+	e100_hw_reset(nic);
+	e100_phy_init(nic);
+
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+/**
+ * e100_io_resume - resume normal operations
+ * @pdev: Pointer to PCI device
+ *
+ * Resume normal operations after an error recovery
+ * sequence has been completed.
+ */
+static void e100_io_resume(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct nic *nic = netdev_priv(netdev);
+
+	/* ack any pending wake events, disable PME */
+	pci_enable_wake(pdev, 0, 0);
+
+	netif_device_attach(netdev);
+	if (netif_running(netdev)) {
+		e100_open(netdev);
+		mod_timer(&nic->watchdog, jiffies);
+	}
+}
+
+static struct pci_error_handlers e100_err_handler = {
+	.error_detected = e100_io_error_detected,
+	.slot_reset = e100_io_slot_reset,
+	.resume = e100_io_resume,
+};
 
 static struct pci_driver e100_driver = {
 	.name =         DRV_NAME,
@@ -2737,6 +2811,7 @@ static struct pci_driver e100_driver = {
 	.resume =       e100_resume,
 #endif
 	.shutdown =     e100_shutdown,
+	.err_handler = &e100_err_handler,
 };
 
 static int __init e100_init_module(void)
_
