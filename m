From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/17] fm10k: prevent RCU issues during AER events
Date: Wed, 20 Apr 2016 23:09:17 -0700
Message-ID: <1461218969-68578-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8320 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751662AbcDUGJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 02:09:36 -0400
In-Reply-To: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

During an AER action response, we were calling fm10k_close without
holding the rtnl_lock() which could lead to possible RCU warnings being
produced due to 64bit stat updates among other causes. Similarly, we
need rtnl_lock() around fm10k_open during fm10k_io_resume. Follow the
same pattern elsewhere in the driver and protect the entire open/close
sequence.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index f099295..a604513 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -2271,6 +2271,8 @@ static pci_ers_result_t fm10k_io_error_detected(struct pci_dev *pdev,
 	if (state == pci_channel_io_perm_failure)
 		return PCI_ERS_RESULT_DISCONNECT;
 
+	rtnl_lock();
+
 	if (netif_running(netdev))
 		fm10k_close(netdev);
 
@@ -2279,6 +2281,8 @@ static pci_ers_result_t fm10k_io_error_detected(struct pci_dev *pdev,
 	/* free interrupts */
 	fm10k_clear_queueing_scheme(interface);
 
+	rtnl_unlock();
+
 	pci_disable_device(pdev);
 
 	/* Request a slot reset. */
@@ -2349,11 +2353,13 @@ static void fm10k_io_resume(struct pci_dev *pdev)
 	/* reset statistics starting values */
 	hw->mac.ops.rebind_hw_stats(hw, &interface->stats);
 
+	rtnl_lock();
+
 	err = fm10k_init_queueing_scheme(interface);
 	if (err) {
 		dev_err(&interface->pdev->dev,
 			"init_queueing_scheme failed: %d\n", err);
-		return;
+		goto unlock;
 	}
 
 	/* reassociate interrupts */
@@ -2370,6 +2376,9 @@ static void fm10k_io_resume(struct pci_dev *pdev)
 
 	if (!err)
 		netif_device_attach(netdev);
+
+unlock:
+	rtnl_unlock();
 }
 
 static const struct pci_error_handlers fm10k_err_handler = {
-- 
2.5.5
