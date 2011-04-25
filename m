From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 4/6] tg3: Add EEH support
Date: Mon, 25 Apr 2011 15:42:48 -0700
Message-ID: <1303771370-32579-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4261 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756799Ab1DYWan (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2011 18:30:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds EEH support to the tg3 driver.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |  147 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 147 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index fb2139a..6bc43ed 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -15395,6 +15395,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		    pdev->dma_mask == DMA_BIT_MASK(32) ? 32 :
 		    ((u64)pdev->dma_mask) == DMA_BIT_MASK(40) ? 40 : 64);
 
+	pci_save_state(pdev);
+
 	return 0;
 
 err_out_apeunmap:
@@ -15551,11 +15553,156 @@ static SIMPLE_DEV_PM_OPS(tg3_pm_ops, tg3_suspend, tg3_resume);
 
 #endif /* CONFIG_PM_SLEEP */
 
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
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct tg3 *tp = netdev_priv(netdev);
+	pci_ers_result_t err = PCI_ERS_RESULT_NEED_RESET;
+
+	netdev_info(netdev, "PCI I/O error detected\n");
+
+	rtnl_lock();
+
+	if (!netif_running(netdev))
+		goto done;
+
+	tg3_phy_stop(tp);
+
+	tg3_netif_stop(tp);
+
+	del_timer_sync(&tp->timer);
+	tp->tg3_flags2 &= ~TG3_FLG2_RESTART_TIMER;
+
+	/* Want to make sure that the reset task doesn't run */
+	cancel_work_sync(&tp->reset_task);
+	tp->tg3_flags  &= ~TG3_FLAG_TX_RECOVERY_PENDING;
+	tp->tg3_flags2 &= ~TG3_FLG2_RESTART_TIMER;
+
+	netif_device_detach(netdev);
+
+	/* Clean up software state, even if MMIO is blocked */
+	tg3_full_lock(tp, 0);
+	tg3_halt(tp, RESET_KIND_SHUTDOWN, 0);
+	tg3_full_unlock(tp);
+
+done:
+	if (state == pci_channel_io_perm_failure)
+		err = PCI_ERS_RESULT_DISCONNECT;
+	else
+		pci_disable_device(pdev);
+
+	rtnl_unlock();
+
+	return err;
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
+	pci_ers_result_t rc = PCI_ERS_RESULT_DISCONNECT;
+	int err;
+
+	rtnl_lock();
+
+	if (pci_enable_device(pdev)) {
+		netdev_err(netdev, "Cannot re-enable PCI device after reset.\n");
+		goto done;
+	}
+
+	pci_set_master(pdev);
+	pci_restore_state(pdev);
+	pci_save_state(pdev);
+
+	if (!netif_running(netdev)) {
+		rc = PCI_ERS_RESULT_RECOVERED;
+		goto done;
+	}
+
+	err = tg3_power_up(tp);
+	if (err) {
+		netdev_err(netdev, "Failed to restore register access.\n");
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
+	int err;
+
+	rtnl_lock();
+
+	if (!netif_running(netdev))
+		goto done;
+
+	tg3_full_lock(tp, 0);
+	tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
+	err = tg3_restart_hw(tp, 1);
+	tg3_full_unlock(tp);
+	if (err) {
+		netdev_err(netdev, "Cannot restart hardware after reset.\n");
+		goto done;
+	}
+
+	netif_device_attach(netdev);
+
+	tp->timer.expires = jiffies + tp->timer_offset;
+	add_timer(&tp->timer);
+
+	tg3_netif_start(tp);
+
+	tg3_phy_start(tp);
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
 	.driver.pm	= TG3_PM_OPS,
 };
 
-- 
1.7.3.4


