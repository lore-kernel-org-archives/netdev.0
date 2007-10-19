From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 6/7] tg3: Add PCI error recovery
Date: Fri, 19 Oct 2007 14:36:58 -0700
Message-ID: <1192829819.22064.560.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz,
	"Linas Vepstas" <linas@austin.ibm.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3124 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764131AbXJSVhN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 17:37:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds PCI error recovery support.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9920751..d866387 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5026,12 +5026,6 @@ static int tg3_poll_fw(struct tg3 *tp)
 	return 0;
 }
 
-/* Save PCI command register before chip reset */
-static void tg3_save_pci_state(struct tg3 *tp)
-{
-	pci_read_config_word(tp->pdev, PCI_COMMAND, &tp->pci_cmd);
-}
-
 /* Restore PCI state after chip reset */
 static void tg3_restore_pci_state(struct tg3 *tp)
 {
@@ -5107,12 +5101,6 @@ static int tg3_chip_reset(struct tg3 *tp)
 	 */
 	tp->nvram_lock_cnt = 0;
 
-	/* GRC_MISC_CFG core clock reset will clear the memory
-	 * enable bit in PCI register 4 and the MSI enable bit
-	 * on some chips, so we save relevant registers here.
-	 */
-	tg3_save_pci_state(tp);
-
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
@@ -12527,6 +12515,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		tg3_ape_lock_init(tp);
 	}
 
+	pci_read_config_word(tp->pdev, PCI_COMMAND, &tp->pci_cmd);
+
 	pci_set_drvdata(pdev, dev);
 
 	err = register_netdev(dev);
@@ -12706,11 +12696,148 @@ out:
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
+					      pci_channel_state_t state)
+{
+	int rc;
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct tg3 *tp = netdev_priv(netdev);
+	struct device *dev = &netdev->dev;
+
+	rtnl_lock();
+
+	dev_info(dev, "PCI I/O error detected on %s\n", netdev->name);
+
+	if (!netif_running(netdev)) {
+		rc = PCI_ERS_RESULT_NEED_RESET;
+		goto done;
+	}
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
+		napi_enable(&tp->napi);
+		rc = PCI_ERS_RESULT_DISCONNECT;
+		goto done;
+	}
+
+	rc = PCI_ERS_RESULT_NEED_RESET;
+
+done:
+	rtnl_unlock();
+
+	return rc;
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
+	int rc;
+
+	rtnl_lock();
+
+	pci_write_config_word(tp->pdev, PCI_COMMAND, tp->pci_cmd);
+
+	if (!netif_running(netdev)) {
+		rc = PCI_ERS_RESULT_RECOVERED;
+		goto done;
+	}
+
+	if (pci_enable_device(pdev)) {
+		printk(KERN_ERR "tg3: %s: "
+		       "Cannot re-enable PCI device after reset.\n",
+		       netdev->name);
+		rc = PCI_ERS_RESULT_DISCONNECT;
+		goto done;
+	}
+
+	pci_set_master(pdev);
+	pci_restore_msi_state(tp->pdev);
+	netif_device_attach(netdev);
+
+	tg3_full_lock(tp, 0);
+	tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
+	rc = tg3_restart_hw(tp, 1);
+	tg3_full_unlock(tp);
+	if (rc) {
+		printk(KERN_ERR "tg3: %s: "
+		       "Cannot restart hardware after reset.\n", netdev->name);
+		rc = PCI_ERS_RESULT_DISCONNECT;
+		goto done;
+	}
+
+	rc = PCI_ERS_RESULT_RECOVERED;
+
+done:
+	rtnl_unlock();
+
+	return rc;
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
+	rtnl_lock();
+
+	if (!netif_running(netdev))
+		goto done;
+
+	netif_wake_queue(netdev);
+
+	tp->timer.expires = jiffies + tp->timer_offset;
+	add_timer(&tp->timer);
+
+	tg3_netif_start(tp);
+
+done:
+	rtnl_unlock();
+}
+
+static struct pci_error_handlers tg3_err_handler = {
+	.error_detected	= tg3_io_error_detected,
+	.slot_reset	= tg3_io_slot_reset,
+	.resume		= tg3_io_resume
+};
+
 static struct pci_driver tg3_driver = {
 	.name		= DRV_MODULE_NAME,
 	.id_table	= tg3_pci_tbl,
 	.probe		= tg3_init_one,
 	.remove		= __devexit_p(tg3_remove_one),
+	.err_handler	= &tg3_err_handler,
 	.suspend	= tg3_suspend,
 	.resume		= tg3_resume
 };


