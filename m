From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH] tg3: add PCI error recovery support
Date: Wed, 18 Jul 2007 18:48:26 -0500
Message-ID: <20070718234826.GO5771@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: strosake@us.ibm.com, wenxiong@us.ibm.com, tsenglin@us.ibm.com,
	cjlarsen@us.ibm.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, linux-pci@atrey.karlin.mff.cuni.cz,
	daisyc@us.ibm.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:51711 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965069AbXGRXs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 19:48:28 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6INmRnQ016971
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2007 19:48:27 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6INmRvZ192984
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2007 17:48:27 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6INmRXx007866
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2007 17:48:27 -0600
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add support for PCI Error Recovery for the tg3 ethernet
device driver. The general principles of operation are
described in Documentation/pci-error-recovery.txt
Other drivers having similar structure include e100,
e1000, ixgb, s2io, ipr, sym53c8xx_2, and lpfc

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: Michael Chan <mchan@broadcom.com>

----

Michael, you are listed as the tg3 maintainer; could you
please forward upstream if you agree?  

Tested on the PCI-E version of this adapter, on power6, 
for 85 (artificial) error injections (overnight) while
ftp'ing dvd iso images over the link. Worked well.

 drivers/net/tg3.c |  108 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 107 insertions(+), 1 deletion(-)

Index: linux-2.6.22-git2/drivers/net/tg3.c
===================================================================
--- linux-2.6.22-git2.orig/drivers/net/tg3.c	2007-07-17 11:07:30.000000000 -0500
+++ linux-2.6.22-git2/drivers/net/tg3.c	2007-07-18 15:10:09.000000000 -0500
@@ -64,7 +64,7 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.77"
+#define DRV_MODULE_VERSION	"3.77-a"
 #define DRV_MODULE_RELDATE	"May 31, 2007"
 
 #define TG3_DEF_MAC_MODE	0
@@ -12126,11 +12126,117 @@ out:
 	return err;
 }
 
+/**
+ * tg3_io_error_detected - called when PCI error is detected
+ * @pdev: Pointer to PCI device
+ * @state: The current pci connection state
+ *
+ * This function is called after a PCI bus error affecting
+ * this device has been detected. 
+ */
+static pci_ers_result_t tg3_io_error_detected(struct pci_dev *pdev,
+                                               pci_channel_state_t state)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct tg3 *tp = netdev_priv(netdev);
+	struct device *dev = &netdev->dev;
+
+	dev_info(dev, "PCI I/O error detected on %s\n", netdev->name);
+
+	if (!netif_running(netdev))
+		return PCI_ERS_RESULT_NEED_RESET;
+
+	/* Want to make sure that the reset task doesn't run */
+	cancel_work_sync(&tp->reset_task);
+	tg3_netif_stop(tp);
+	del_timer_sync(&tp->timer);
+	netif_device_detach(netdev);
+	pci_disable_device(pdev);
+
+	if (state == pci_channel_io_perm_failure) {
+		/* avoid hang in dev_close() with rtnl_lock held */
+		netif_poll_enable(netdev);
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/**
+ * tg3_io_slot_reset - called after the pci bus has been reset.
+ * @pdev: Pointer to PCI device
+ *
+ * Restart the card from scratch, as if from a cold-boot.
+ * At this point, the card has exprienced a hard reset,
+ * followed by fixups by BIOS, and has its config space
+ * set up identically to what it was at cold boot.
+ */
+static pci_ers_result_t tg3_io_slot_reset(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct tg3 *tp = netdev_priv(netdev);
+	int err;
+
+	if (!netif_running(netdev))
+		return PCI_ERS_RESULT_RECOVERED;
+
+	if (pci_enable_device(pdev)) {
+		printk(KERN_ERR "tg3: %s: "
+		       "Cannot re-enable PCI device after reset.\n", netdev->name);
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+
+	pci_set_master(pdev);
+	pci_restore_state(tp->pdev);
+	netif_device_attach(netdev);
+
+	tg3_full_lock(tp, 0);
+	tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
+	err = tg3_restart_hw(tp, 1);
+	tg3_full_unlock(tp);
+	if (err) {
+		printk(KERN_ERR "tg3: %s: "
+		       "Cannot restart hardware after reset.\n", netdev->name);
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+/**
+ * tg3_io_resume - called when traffic can start flowing again.
+ * @pdev: Pointer to PCI device
+ *
+ * This callback is called when the error recovery driver tells
+ * us that its OK to resume normal operation.
+ */
+static void tg3_io_resume(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct tg3 *tp = netdev_priv(netdev);
+
+	if (!netif_running(netdev))
+		return;
+
+	netif_wake_queue(netdev);
+
+	tp->timer.expires = jiffies + tp->timer_offset;
+	add_timer(&tp->timer);
+
+	tg3_netif_start(tp);
+}
+
+static struct pci_error_handlers tg3_err_handler = {
+	.error_detected = tg3_io_error_detected,
+	.slot_reset = tg3_io_slot_reset,
+	.resume = tg3_io_resume,
+};
+
 static struct pci_driver tg3_driver = {
 	.name		= DRV_MODULE_NAME,
 	.id_table	= tg3_pci_tbl,
 	.probe		= tg3_init_one,
 	.remove		= __devexit_p(tg3_remove_one),
+	.err_handler = &tg3_err_handler,
 	.suspend	= tg3_suspend,
 	.resume		= tg3_resume
 };
