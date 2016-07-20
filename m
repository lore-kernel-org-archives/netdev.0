From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/20] fm10k: use common flow for suspend and resume
Date: Wed, 20 Jul 2016 15:23:52 -0700
Message-ID: <1469053438-85381-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4181 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755400AbcGTWYG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:06 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Continuing the effort to commonize the similar suspend/resume flows,
finish up by using the new fm10k_handle_suspand and fm10k_handle_resume
functions for the standard suspend/resume flow.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 73 ++--------------------------
 1 file changed, 3 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index c60c3b0..b02361c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -2186,60 +2186,13 @@ static int fm10k_resume(struct pci_dev *pdev)
 	/* refresh hw_addr in case it was dropped */
 	hw->hw_addr = interface->uc_addr;
 
-	/* reset hardware to known state */
-	err = hw->mac.ops.init_hw(&interface->hw);
-	if (err) {
-		dev_err(&pdev->dev, "init_hw failed: %d\n", err);
-		return err;
-	}
-
-	/* reset statistics starting values */
-	hw->mac.ops.rebind_hw_stats(hw, &interface->stats);
-
-	rtnl_lock();
-
-	err = fm10k_init_queueing_scheme(interface);
-	if (err)
-		goto err_queueing_scheme;
-
-	err = fm10k_mbx_request_irq(interface);
-	if (err)
-		goto err_mbx_irq;
-
-	err = fm10k_hw_ready(interface);
-	if (err)
-		goto err_open;
-
-	err = netif_running(netdev) ? fm10k_open(netdev) : 0;
+	err = fm10k_handle_resume(interface);
 	if (err)
-		goto err_open;
-
-	rtnl_unlock();
-
-	/* assume host is not ready, to prevent race with watchdog in case we
-	 * actually don't have connection to the switch
-	 */
-	interface->host_ready = false;
-	fm10k_watchdog_host_not_ready(interface);
-
-	/* clear the service task disable bit to allow service task to start */
-	clear_bit(__FM10K_SERVICE_DISABLE, &interface->state);
-	fm10k_service_event_schedule(interface);
-
-	/* restore SR-IOV interface */
-	fm10k_iov_resume(pdev);
+		return err;
 
 	netif_device_attach(netdev);
 
 	return 0;
-err_open:
-	fm10k_mbx_free_irq(interface);
-err_mbx_irq:
-	fm10k_clear_queueing_scheme(interface);
-err_queueing_scheme:
-	rtnl_unlock();
-
-	return err;
 }
 
 /**
@@ -2259,27 +2212,7 @@ static int fm10k_suspend(struct pci_dev *pdev,
 
 	netif_device_detach(netdev);
 
-	fm10k_iov_suspend(pdev);
-
-	/* the watchdog tasks may read registers, which will appear like a
-	 * surprise-remove event once the PCI device is disabled. This will
-	 * cause us to close the netdevice, so we don't retain the open/closed
-	 * state post-resume. Prevent this by disabling the service task while
-	 * suspended, until we actually resume.
-	 */
-	set_bit(__FM10K_SERVICE_DISABLE, &interface->state);
-	cancel_work_sync(&interface->service_task);
-
-	rtnl_lock();
-
-	if (netif_running(netdev))
-		fm10k_close(netdev);
-
-	fm10k_mbx_free_irq(interface);
-
-	fm10k_clear_queueing_scheme(interface);
-
-	rtnl_unlock();
+	fm10k_prepare_suspend(interface);
 
 	err = pci_save_state(pdev);
 	if (err)
-- 
2.5.5
