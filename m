From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/3] ixgbe: Fix a memory leak in IEEE DCB
Date: Mon, 30 Apr 2012 16:16:33 -0700
Message-ID: <1335827794-26992-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1335827794-26992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48974 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757104Ab2D3XQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 19:16:37 -0400
In-Reply-To: <1335827794-26992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The driver was freeing memory in shutdown instead of remove.  As a result
we were leaking memory if IEEE DCB was enabled and we loaded/unloaded the
driver.  This change moves the freeing of the memory into the remove
routine where it belongs.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a7f3cd8..88f6b2e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4873,10 +4873,6 @@ static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 	}
 
 	ixgbe_clear_interrupt_scheme(adapter);
-#ifdef CONFIG_DCB
-	kfree(adapter->ixgbe_ieee_pfc);
-	kfree(adapter->ixgbe_ieee_ets);
-#endif
 
 #ifdef CONFIG_PM
 	retval = pci_save_state(pdev);
@@ -7224,6 +7220,11 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 
 	ixgbe_release_hw_control(adapter);
 
+#ifdef CONFIG_DCB
+	kfree(adapter->ixgbe_ieee_pfc);
+	kfree(adapter->ixgbe_ieee_ets);
+
+#endif
 	iounmap(adapter->hw.hw_addr);
 	pci_release_selected_regions(pdev, pci_select_bars(pdev,
 				     IORESOURCE_MEM));
-- 
1.7.7.6
