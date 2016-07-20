From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/20] fm10k: implement prepare_suspend and handle_resume
Date: Wed, 20 Jul 2016 15:23:49 -0700
Message-ID: <1469053438-85381-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4181 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755244AbcGTWYE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:04 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Implement fm10k_prepare_suspend and fm10k_handle_resume functions which
abstract around the now existing fm10k_prepare_for_reset and
fm10k_handle_reset. The new functions also handle stopping the service
task, which is something that the original re-init flow does not need.

Every other location that does a suspend/resume type flow is expected to
use these functions, because otherwise they may have conflicts with the
running watchdog routines. This also has the effect of preventing
possible surprise remove events during handling of FLR events and PCIe
errors.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 38 ++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 2963b41..a6ee046 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -2112,6 +2112,44 @@ static void fm10k_remove(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
+static void fm10k_prepare_suspend(struct fm10k_intfc *interface)
+{
+	/* the watchdog task reads from registers, which might appear like
+	 * a surprise remove if the PCIe device is disabled while we're
+	 * stopped. We stop the watchdog task until after we resume software
+	 * activity.
+	 */
+	set_bit(__FM10K_SERVICE_DISABLE, &interface->state);
+	cancel_work_sync(&interface->service_task);
+
+	fm10k_prepare_for_reset(interface);
+}
+
+static int fm10k_handle_resume(struct fm10k_intfc *interface)
+{
+	struct fm10k_hw *hw = &interface->hw;
+	int err;
+
+	/* reset statistics starting values */
+	hw->mac.ops.rebind_hw_stats(hw, &interface->stats);
+
+	err = fm10k_handle_reset(interface);
+	if (err)
+		return err;
+
+	/* assume host is not ready, to prevent race with watchdog in case we
+	 * actually don't have connection to the switch
+	 */
+	interface->host_ready = false;
+	fm10k_watchdog_host_not_ready(interface);
+
+	/* clear the service task disable bit to allow service task to start */
+	clear_bit(__FM10K_SERVICE_DISABLE, &interface->state);
+	fm10k_service_event_schedule(interface);
+
+	return err;
+}
+
 #ifdef CONFIG_PM
 /**
  * fm10k_resume - Restore device to pre-sleep state
-- 
2.5.5
