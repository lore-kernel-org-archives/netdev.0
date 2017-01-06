From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/10] igb: close/suspend race in netif_device_detach
Date: Fri,  6 Jan 2017 02:48:50 -0800
Message-ID: <20170106104852.10363-9-jeffrey.t.kirsher@intel.com>
References: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:26908 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966301AbdAFKtY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 05:49:24 -0500
In-Reply-To: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

Similar to ixgbe, when an interface is part of a namespace it is
possible that igb_close() may be called while __igb_shutdown() is
running which ends up in a double free WARN and/or a BUG in
free_msi_irqs().

Extend the rtnl_lock() to protect the call to netif_device_detach() and
igb_clear_interrupt_scheme() in __igb_shutdown() and check for
netif_device_present() to avoid calling igb_clear_interrupt_scheme() a
second time in igb_close().

Also extend the rtnl lock in igb_resume() to netif_device_attach().

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 82069bc..594604e 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3275,7 +3275,9 @@ static int __igb_close(struct net_device *netdev, bool suspending)
 
 int igb_close(struct net_device *netdev)
 {
-	return __igb_close(netdev, false);
+	if (netif_device_present(netdev))
+		return __igb_close(netdev, false);
+	return 0;
 }
 
 /**
@@ -7564,6 +7566,7 @@ static int __igb_shutdown(struct pci_dev *pdev, bool *enable_wake,
 	int retval = 0;
 #endif
 
+	rtnl_lock();
 	netif_device_detach(netdev);
 
 	if (netif_running(netdev))
@@ -7572,6 +7575,7 @@ static int __igb_shutdown(struct pci_dev *pdev, bool *enable_wake,
 	igb_ptp_suspend(adapter);
 
 	igb_clear_interrupt_scheme(adapter);
+	rtnl_unlock();
 
 #ifdef CONFIG_PM
 	retval = pci_save_state(pdev);
@@ -7690,16 +7694,15 @@ static int igb_resume(struct device *dev)
 
 	wr32(E1000_WUS, ~0);
 
-	if (netdev->flags & IFF_UP) {
-		rtnl_lock();
+	rtnl_lock();
+	if (!err && netif_running(netdev))
 		err = __igb_open(netdev, true);
-		rtnl_unlock();
-		if (err)
-			return err;
-	}
 
-	netif_device_attach(netdev);
-	return 0;
+	if (!err)
+		netif_device_attach(netdev);
+	rtnl_unlock();
+
+	return err;
 }
 
 static int igb_runtime_idle(struct device *dev)
-- 
2.9.3
