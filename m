From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e: implement split PCI error reset handler
Date: Fri,  6 Oct 2017 10:57:23 -0700
Message-ID: <20171006175727.868-12-jeffrey.t.kirsher@intel.com>
References: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17217 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752606AbdJFR5v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 13:57:51 -0400
In-Reply-To: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

This patch implements the PCI error handler reset_prepare and reset_done.
This allows us to handle function level reset.  Without this patch we
are unable to perform and recover from an FLR correctly and this will cause
VFs to be unable to recover from an FLR on the PF.

Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 9704cfef2f05..60b11fdeca2d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -12045,6 +12045,28 @@ static pci_ers_result_t i40e_pci_error_slot_reset(struct pci_dev *pdev)
 	return result;
 }
 
+/**
+ * i40e_pci_error_reset_prepare - prepare device driver for pci reset
+ * @pdev: PCI device information struct
+ */
+static void i40e_pci_error_reset_prepare(struct pci_dev *pdev)
+{
+	struct i40e_pf *pf = pci_get_drvdata(pdev);
+
+	i40e_prep_for_reset(pf, false);
+}
+
+/**
+ * i40e_pci_error_reset_done - pci reset done, device driver reset can begin
+ * @pdev: PCI device information struct
+ */
+static void i40e_pci_error_reset_done(struct pci_dev *pdev)
+{
+	struct i40e_pf *pf = pci_get_drvdata(pdev);
+
+	i40e_reset_and_rebuild(pf, false, false);
+}
+
 /**
  * i40e_pci_error_resume - restart operations after PCI error recovery
  * @pdev: PCI device information struct
@@ -12235,6 +12257,8 @@ static int i40e_resume(struct device *dev)
 static const struct pci_error_handlers i40e_err_handler = {
 	.error_detected = i40e_pci_error_detected,
 	.slot_reset = i40e_pci_error_slot_reset,
+	.reset_prepare = i40e_pci_error_reset_prepare,
+	.reset_done = i40e_pci_error_reset_done,
 	.resume = i40e_pci_error_resume,
 };
 
-- 
2.14.2
