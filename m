From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/21] ixgbe: handle close/suspend race with netif_device_detach/present
Date: Tue,  3 Jan 2017 13:07:44 -0800
Message-ID: <20170103210757.38847-9-jeffrey.t.kirsher@intel.com>
References: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:3461 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756688AbdACVIK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 16:08:10 -0500
In-Reply-To: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

When an interface is part of a namespace it is possible that
ixgbe_close() may be called while __ixgbe_shutdown() is running
which ends up in a double free WARN and/or a BUG in free_msi_irqs().

To handle this situation we extend the rtnl_lock() to protect the
call to netif_device_detach() and ixgbe_clear_interrupt_scheme()
in __ixgbe_shutdown() and check for netif_device_present()
to avoid clearing the interrupts second time in ixgbe_close();

Also extend the rtnl lock in ixgbe_resume() to netif_device_attach().

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 6732c90..476f012 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6200,7 +6200,8 @@ int ixgbe_close(struct net_device *netdev)
 
 	ixgbe_ptp_stop(adapter);
 
-	ixgbe_close_suspend(adapter);
+	if (netif_device_present(netdev))
+		ixgbe_close_suspend(adapter);
 
 	ixgbe_fdir_filter_exit(adapter);
 
@@ -6245,14 +6246,12 @@ static int ixgbe_resume(struct pci_dev *pdev)
 	if (!err && netif_running(netdev))
 		err = ixgbe_open(netdev);
 
-	rtnl_unlock();
 
-	if (err)
-		return err;
-
-	netif_device_attach(netdev);
+	if (!err)
+		netif_device_attach(netdev);
+	rtnl_unlock();
 
-	return 0;
+	return err;
 }
 #endif /* CONFIG_PM */
 
@@ -6267,14 +6266,14 @@ static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 	int retval = 0;
 #endif
 
+	rtnl_lock();
 	netif_device_detach(netdev);
 
-	rtnl_lock();
 	if (netif_running(netdev))
 		ixgbe_close_suspend(adapter);
-	rtnl_unlock();
 
 	ixgbe_clear_interrupt_scheme(adapter);
+	rtnl_unlock();
 
 #ifdef CONFIG_PM
 	retval = pci_save_state(pdev);
-- 
2.9.3
