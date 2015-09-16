From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/18] fm10k: disable service task during suspend
Date: Tue, 15 Sep 2015 17:36:29 -0700
Message-ID: <1442363803-47237-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:26285 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753076AbbIPAgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 20:36:48 -0400
In-Reply-To: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The service task reads some registers as part of its normal routine,
even while the interface is down. Normally this is ok. However, during
suspend we have disabled the PCI device. Due to this, registers will
read in the same way as a surprise-remove event. Disable the service
task while we suspend, and re-enable it after we resume. If we don't do
this, the device could be UP when you suspend and come back from resume
as closed (since fm10k closes the device when it gets a surprise
remove).

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index ce53ff2..8413ab5 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1983,6 +1983,16 @@ static int fm10k_resume(struct pci_dev *pdev)
 	if (err)
 		return err;
 
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
 	/* restore SR-IOV interface */
 	fm10k_iov_resume(pdev);
 
@@ -2010,6 +2020,15 @@ static int fm10k_suspend(struct pci_dev *pdev,
 
 	fm10k_iov_suspend(pdev);
 
+	/* the watchdog tasks may read registers, which will appear like a
+	 * surprise-remove event once the PCI device is disabled. This will
+	 * cause us to close the netdevice, so we don't retain the open/closed
+	 * state post-resume. Prevent this by disabling the service task while
+	 * suspended, until we actually resume.
+	 */
+	set_bit(__FM10K_SERVICE_DISABLE, &interface->state);
+	cancel_work_sync(&interface->service_task);
+
 	rtnl_lock();
 
 	if (netif_running(netdev))
-- 
2.4.3
