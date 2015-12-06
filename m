From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/15] fm10k: reinitialize queuing scheme after calling init_hw
Date: Sun,  6 Dec 2015 00:01:23 -0800
Message-ID: <1449388894-128573-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449388894-128573-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43991 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446AbbLFIBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2015 03:01:37 -0500
In-Reply-To: <1449388894-128573-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The init_hw function may fail, and in the case of VFs, it might change
the number of maximum queues available. Thus, for every flow which
checks init_hw, we need to ensure that we clear the queue scheme before,
and initialize it after. The fm10k_io_slot_reset path will end up
triggering a reset so fm10k_reinit needs this change. The
fm10k_io_error_detected and fm10k_io_resume also need to properly clear
and reinitialize the queue scheme.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 9c21d1e..faf8149 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -159,6 +159,9 @@ static void fm10k_reinit(struct fm10k_intfc *interface)
 
 	fm10k_mbx_free_irq(interface);
 
+	/* free interrupts */
+	fm10k_clear_queueing_scheme(interface);
+
 	/* delay any future reset requests */
 	interface->last_reset = jiffies + (10 * HZ);
 
@@ -175,6 +178,12 @@ static void fm10k_reinit(struct fm10k_intfc *interface)
 		goto reinit_err;
 	}
 
+	err = fm10k_init_queueing_scheme(interface);
+	if (err) {
+		dev_err(&interface->pdev->dev, "init_queueing_scheme failed: %d\n", err);
+		goto reinit_err;
+	}
+
 	/* reassociate interrupts */
 	fm10k_mbx_request_irq(interface);
 
@@ -2198,6 +2207,9 @@ static pci_ers_result_t fm10k_io_error_detected(struct pci_dev *pdev,
 	if (netif_running(netdev))
 		fm10k_close(netdev);
 
+	/* free interrupts */
+	fm10k_clear_queueing_scheme(interface);
+
 	fm10k_mbx_free_irq(interface);
 
 	pci_disable_device(pdev);
@@ -2270,6 +2282,12 @@ static void fm10k_io_resume(struct pci_dev *pdev)
 	/* reset statistics starting values */
 	hw->mac.ops.rebind_hw_stats(hw, &interface->stats);
 
+	err = fm10k_init_queueing_scheme(interface);
+	if (err) {
+		dev_err(&interface->pdev->dev, "init_queueing_scheme failed: %d\n", err);
+		return;
+	}
+
 	/* reassociate interrupts */
 	fm10k_mbx_request_irq(interface);
 
-- 
2.5.0
