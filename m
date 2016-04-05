From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/15] fm10k: free MBX IRQ before clearing interrupt scheme
Date: Tue,  5 Apr 2016 13:02:22 -0700
Message-ID: <1459886547-146445-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459886547-146445-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33656 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759898AbcDEUCc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:02:32 -0400
In-Reply-To: <1459886547-146445-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

During fm10k_io_error_detected we were clearing the interrupt scheme
before we freed the MBX IRQ. This causes a kernel panic because the MBX
IRQ are assigned after MSI-X initialization. Clearing the interrupt
scheme results in removing the MSI-X entry table. Fix this by freeing
the MBX IRQ before we clear the interrupt scheme, as we do elsewhere in
the driver.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 3c7c819..da38af0 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -2274,11 +2274,11 @@ static pci_ers_result_t fm10k_io_error_detected(struct pci_dev *pdev,
 	if (netif_running(netdev))
 		fm10k_close(netdev);
 
+	fm10k_mbx_free_irq(interface);
+
 	/* free interrupts */
 	fm10k_clear_queueing_scheme(interface);
 
-	fm10k_mbx_free_irq(interface);
-
 	pci_disable_device(pdev);
 
 	/* Request a slot reset. */
-- 
2.5.5
