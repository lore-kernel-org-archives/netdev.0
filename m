From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 11/21] ixgbe: fix AER error handling
Date: Tue,  3 Jan 2017 13:07:47 -0800
Message-ID: <20170103210757.38847-12-jeffrey.t.kirsher@intel.com>
References: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:25260 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935984AbdACVIN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 16:08:13 -0500
In-Reply-To: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Make sure that we free the IRQs in ixgbe_io_error_detected() when
responding to an PCIe AER error and also restore them when the
interface recovers from it.

Previously it was possible to trigger BUG_ON() check in free_msix_irqs()
in the case where we call ixgbe_remove() after a failed recovery from
AER error because the interrupts were not freed.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 476f012..9ca167c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -10082,7 +10082,7 @@ static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
 	}
 
 	if (netif_running(netdev))
-		ixgbe_down(adapter);
+		ixgbe_close_suspend(adapter);
 
 	if (!test_and_set_bit(__IXGBE_DISABLED, &adapter->state))
 		pci_disable_device(pdev);
@@ -10152,10 +10152,12 @@ static void ixgbe_io_resume(struct pci_dev *pdev)
 	}
 
 #endif
+	rtnl_lock();
 	if (netif_running(netdev))
-		ixgbe_up(adapter);
+		ixgbe_open(netdev);
 
 	netif_device_attach(netdev);
+	rtnl_unlock();
 }
 
 static const struct pci_error_handlers ixgbe_err_handler = {
-- 
2.9.3
