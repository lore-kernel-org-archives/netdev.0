From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 11/12] i40e: support for suspend and resume
Date: Mon, 16 Dec 2013 01:38:57 -0800
Message-ID: <1387186738-13666-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387186738-13666-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:39292 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753010Ab3LPJjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 04:39:11 -0500
In-Reply-To: <1387186738-13666-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add basic support for handling suspend and resume.  We'll add
Wake-on-LAN support later.

Change-Id: Iea5e11c81bd9289a5bdbf086de8f626911a0b5ce
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 97 ++++++++++++++++++++++++++++-
 2 files changed, 97 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 24a47ee..40706c1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -133,6 +133,7 @@ enum i40e_state_t {
 	__I40E_GLOBAL_RESET_REQUESTED,
 	__I40E_EMP_RESET_REQUESTED,
 	__I40E_FILTER_OVERFLOW_PROMISC,
+	__I40E_SUSPENDED,
 };
 
 enum i40e_interrupt_policy {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 19ad3c0..fba0aad 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7749,7 +7749,11 @@ static pci_ers_result_t i40e_pci_error_detected(struct pci_dev *pdev,
 	dev_info(&pdev->dev, "%s: error %d\n", __func__, error);
 
 	/* shutdown all operations */
-	i40e_pf_quiesce_all_vsi(pf);
+	if (!test_bit(__I40E_SUSPENDED, &pf->state)) {
+		rtnl_lock();
+		i40e_prep_for_reset(pf);
+		rtnl_unlock();
+	}
 
 	/* Request a slot reset */
 	return PCI_ERS_RESULT_NEED_RESET;
@@ -7812,9 +7816,95 @@ static void i40e_pci_error_resume(struct pci_dev *pdev)
 	struct i40e_pf *pf = pci_get_drvdata(pdev);
 
 	dev_info(&pdev->dev, "%s\n", __func__);
+	if (test_bit(__I40E_SUSPENDED, &pf->state))
+		return;
+
+	rtnl_lock();
 	i40e_handle_reset_warning(pf);
+	rtnl_lock();
+}
+
+/**
+ * i40e_shutdown - PCI callback for shutting down
+ * @pdev: PCI device information struct
+ **/
+static void i40e_shutdown(struct pci_dev *pdev)
+{
+	struct i40e_pf *pf = pci_get_drvdata(pdev);
+
+	set_bit(__I40E_SUSPENDED, &pf->state);
+	set_bit(__I40E_DOWN, &pf->state);
+	rtnl_lock();
+	i40e_prep_for_reset(pf);
+	rtnl_unlock();
+
+	if (system_state == SYSTEM_POWER_OFF) {
+		pci_wake_from_d3(pdev, false);    /* No WoL support yet */
+		pci_set_power_state(pdev, PCI_D3hot);
+	}
+}
+
+#ifdef CONFIG_PM
+/**
+ * i40e_suspend - PCI callback for moving to D3
+ * @pdev: PCI device information struct
+ **/
+static int i40e_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct i40e_pf *pf = pci_get_drvdata(pdev);
+
+	set_bit(__I40E_SUSPENDED, &pf->state);
+	set_bit(__I40E_DOWN, &pf->state);
+	rtnl_lock();
+	i40e_prep_for_reset(pf);
+	rtnl_unlock();
+
+	pci_wake_from_d3(pdev, false);    /* No WoL support yet */
+	pci_set_power_state(pdev, PCI_D3hot);
+
+	return 0;
 }
 
+/**
+ * i40e_resume - PCI callback for waking up from D3
+ * @pdev: PCI device information struct
+ **/
+static int i40e_resume(struct pci_dev *pdev)
+{
+	struct i40e_pf *pf = pci_get_drvdata(pdev);
+	u32 err;
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+	/* pci_restore_state() clears dev->state_saves, so
+	 * call pci_save_state() again to restore it.
+	 */
+	pci_save_state(pdev);
+
+	err = pci_enable_device_mem(pdev);
+	if (err) {
+		dev_err(&pdev->dev,
+			"%s: Cannot enable PCI device from suspend\n",
+			__func__);
+		return err;
+	}
+	pci_set_master(pdev);
+
+	/* no wakeup events while running */
+	pci_wake_from_d3(pdev, false);
+
+	/* handling the reset will rebuild the device state */
+	if (test_and_clear_bit(__I40E_SUSPENDED, &pf->state)) {
+		clear_bit(__I40E_DOWN, &pf->state);
+		rtnl_lock();
+		i40e_reset_and_rebuild(pf, false);
+		rtnl_unlock();
+	}
+
+	return 0;
+}
+
+#endif
 static const struct pci_error_handlers i40e_err_handler = {
 	.error_detected = i40e_pci_error_detected,
 	.slot_reset = i40e_pci_error_slot_reset,
@@ -7826,6 +7916,11 @@ static struct pci_driver i40e_driver = {
 	.id_table = i40e_pci_tbl,
 	.probe    = i40e_probe,
 	.remove   = i40e_remove,
+#ifdef CONFIG_PM
+	.suspend  = i40e_suspend,
+	.resume   = i40e_resume,
+#endif
+	.shutdown = i40e_shutdown,
 	.err_handler = &i40e_err_handler,
 	.sriov_configure = i40e_pci_sriov_configure,
 };
-- 
1.8.3.1
