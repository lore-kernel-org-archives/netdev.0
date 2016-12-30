From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/21] ixgbevf: handle race between close and suspend on shutdown
Date: Fri, 30 Dec 2016 01:33:29 -0800
Message-ID: <20161230093341.14674-10-jeffrey.t.kirsher@intel.com>
References: <20161230093341.14674-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:54391 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752236AbcL3Jdr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Dec 2016 04:33:47 -0500
In-Reply-To: <20161230093341.14674-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

When an interface is part of a namespace it is possible that
ixgbevf_close() may be called while ixgbevf_suspend() is running
which ends up in a double free WARN and/or a BUG in free_msi_irqs()

To handle this situation we extend the rtnl_lock() to protect the
call to netif_device_detach() and check for !netif_device_present()
to avoid entering close while in suspend.

Also added rtnl locks to ixgbevf_queue_reset_subtask().

CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 6d4bef5..8574f21 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3242,6 +3242,9 @@ int ixgbevf_close(struct net_device *netdev)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 
+	if (!netif_device_present(netdev))
+		return 0;
+
 	ixgbevf_down(adapter);
 	ixgbevf_free_irq(adapter);
 
@@ -3268,6 +3271,8 @@ static void ixgbevf_queue_reset_subtask(struct ixgbevf_adapter *adapter)
 	 * match packet buffer alignment. Unfortunately, the
 	 * hardware is not flexible enough to do this dynamically.
 	 */
+	rtnl_lock();
+
 	if (netif_running(dev))
 		ixgbevf_close(dev);
 
@@ -3276,6 +3281,8 @@ static void ixgbevf_queue_reset_subtask(struct ixgbevf_adapter *adapter)
 
 	if (netif_running(dev))
 		ixgbevf_open(dev);
+
+	rtnl_unlock();
 }
 
 static void ixgbevf_tx_ctxtdesc(struct ixgbevf_ring *tx_ring,
@@ -3796,17 +3803,17 @@ static int ixgbevf_suspend(struct pci_dev *pdev, pm_message_t state)
 	int retval = 0;
 #endif
 
+	rtnl_lock();
 	netif_device_detach(netdev);
 
 	if (netif_running(netdev)) {
-		rtnl_lock();
 		ixgbevf_down(adapter);
 		ixgbevf_free_irq(adapter);
 		ixgbevf_free_all_tx_resources(adapter);
 		ixgbevf_free_all_rx_resources(adapter);
 		ixgbevf_clear_interrupt_scheme(adapter);
-		rtnl_unlock();
 	}
+	rtnl_unlock();
 
 #ifdef CONFIG_PM
 	retval = pci_save_state(pdev);
-- 
2.9.3
