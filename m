From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 03/16] e1000e: do not wakeup Tx queue until ready
Date: Tue,  8 Feb 2011 04:29:14 -0800
Message-ID: <1297168167-15755-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58635 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753651Ab1BHM3e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Feb 2011 07:29:34 -0500
In-Reply-To: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When restarting the adapter via calls to e1000e_down() followed by
e1000e_up() (for example when restarting autonegotiation via ethtool),
packets can be queued for transmit before link is actually up and
netif_carrier_on is set.  This was causing the watchdog_task to do an
extra unnecessary reset of the adapter.  Delaying the wakeup of the Tx
queue until link is up prevents the reset.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/netdev.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 80614c9..3c95d6b 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3324,8 +3324,6 @@ int e1000e_up(struct e1000_adapter *adapter)
 		e1000_configure_msix(adapter);
 	e1000_irq_enable(adapter);
 
-	netif_wake_queue(adapter->netdev);
-
 	/* fire a link change interrupt to start the watchdog */
 	if (adapter->msix_entries)
 		ew32(ICS, E1000_ICS_LSC | E1000_ICR_OTHER);
@@ -3638,8 +3636,6 @@ static int e1000_open(struct net_device *netdev)
 
 	e1000_irq_enable(adapter);
 
-	netif_start_queue(netdev);
-
 	adapter->idle_check = true;
 	pm_runtime_put(&pdev->dev);
 
@@ -4265,6 +4261,7 @@ static void e1000_watchdog_task(struct work_struct *work)
 				phy->ops.cfg_on_link_up(hw);
 
 			netif_carrier_on(netdev);
+			netif_wake_queue(netdev);
 
 			if (!test_bit(__E1000_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
-- 
1.7.4

