From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e: use newer generic PM support instead of legacy PM callbacks
Date: Fri, 29 Sep 2017 17:45:01 -0700
Message-ID: <20170930004507.20072-10-jeffrey.t.kirsher@intel.com>
References: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:34215 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752645AbdI3Apu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 20:45:50 -0400
In-Reply-To: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Stop using the old legacy PM support, since we now have stable support
for the newer generic PM callbacks.

This has several advantages. First, we no longer have to manage our
own pci_save_state() and power changes, as it's preferred to have the
PCI stack do this. Second, these routines get called for both hibernate
and suspend to ram, so we can have the driver properly handle all the
suspend/resume flows that it needs to.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 54 +++++++++--------------------
 1 file changed, 17 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3ea4f8b942c3..c82360437024 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -12050,14 +12050,14 @@ static void i40e_shutdown(struct pci_dev *pdev)
 
 #ifdef CONFIG_PM
 /**
- * i40e_suspend - PCI callback for moving to D3
- * @pdev: PCI device information struct
+ * i40e_suspend - PM callback for moving to D3
+ * @dev: generic device information structure
  **/
-static int i40e_suspend(struct pci_dev *pdev, pm_message_t state)
+static int i40e_suspend(struct device *dev)
 {
+	struct pci_dev *pdev = to_pci_dev(dev);
 	struct i40e_pf *pf = pci_get_drvdata(pdev);
 	struct i40e_hw *hw = &pf->hw;
-	int retval = 0;
 
 	set_bit(__I40E_SUSPENDED, pf->state);
 	set_bit(__I40E_DOWN, pf->state);
@@ -12072,41 +12072,17 @@ static int i40e_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	i40e_free_misc_vector(pf);
 
-	retval = pci_save_state(pdev);
-	if (retval)
-		return retval;
-
-	pci_wake_from_d3(pdev, pf->wol_en);
-	pci_set_power_state(pdev, PCI_D3hot);
-
-	return retval;
+	return 0;
 }
 
 /**
- * i40e_resume - PCI callback for waking up from D3
- * @pdev: PCI device information struct
+ * i40e_resume - PM callback for waking up from D3
+ * @dev: generic device information structure
  **/
-static int i40e_resume(struct pci_dev *pdev)
+static int i40e_resume(struct device *dev)
 {
+	struct pci_dev *pdev = to_pci_dev(dev);
 	struct i40e_pf *pf = pci_get_drvdata(pdev);
-	u32 err;
-
-	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
-	/* pci_restore_state() clears dev->state_saves, so
-	 * call pci_save_state() again to restore it.
-	 */
-	pci_save_state(pdev);
-
-	err = pci_enable_device_mem(pdev);
-	if (err) {
-		dev_err(&pdev->dev, "Cannot enable PCI device from suspend\n");
-		return err;
-	}
-	pci_set_master(pdev);
-
-	/* no wakeup events while running */
-	pci_wake_from_d3(pdev, false);
 
 	/* handling the reset will rebuild the device state */
 	if (test_and_clear_bit(__I40E_SUSPENDED, pf->state)) {
@@ -12117,22 +12093,26 @@ static int i40e_resume(struct pci_dev *pdev)
 	return 0;
 }
 
-#endif
+#endif /* CONFIG_PM */
+
 static const struct pci_error_handlers i40e_err_handler = {
 	.error_detected = i40e_pci_error_detected,
 	.slot_reset = i40e_pci_error_slot_reset,
 	.resume = i40e_pci_error_resume,
 };
 
+static SIMPLE_DEV_PM_OPS(i40e_pm_ops, i40e_suspend, i40e_resume);
+
 static struct pci_driver i40e_driver = {
 	.name     = i40e_driver_name,
 	.id_table = i40e_pci_tbl,
 	.probe    = i40e_probe,
 	.remove   = i40e_remove,
 #ifdef CONFIG_PM
-	.suspend  = i40e_suspend,
-	.resume   = i40e_resume,
-#endif
+	.driver   = {
+		.pm = &i40e_pm_ops,
+	},
+#endif /* CONFIG_PM */
 	.shutdown = i40e_shutdown,
 	.err_handler = &i40e_err_handler,
 	.sriov_configure = i40e_pci_sriov_configure,
-- 
2.14.1
