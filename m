From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/12] e1000e: do not schedule the Tx queue until ready
Date: Wed,  8 Jun 2011 15:56:32 -0700
Message-ID: <1307573800-24868-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307573800-24868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:3611 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755246Ab1FHW4p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 18:56:45 -0400
In-Reply-To: <1307573800-24868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Start the Tx queue when the interface is brought up in e1000e_up() but do
not schedule the queue until link is up as detected in the watchdog task
which sets netif_carrier_on.

Also flush the descriptors and clean the Tx and Rx rings before resetting
the hardware when bringing the interface down otherwise there is a small
window where the watchdog task can be triggered with netif_carrier_off
and the Tx ring not yet empty which causes an additional and unnecessary
reset.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/netdev.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index c4a23c7..bc99458 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3347,7 +3347,7 @@ int e1000e_up(struct e1000_adapter *adapter)
 		e1000_configure_msix(adapter);
 	e1000_irq_enable(adapter);
 
-	netif_wake_queue(adapter->netdev);
+	netif_start_queue(adapter->netdev);
 
 	/* fire a link change interrupt to start the watchdog */
 	if (adapter->msix_entries)
@@ -3414,17 +3414,16 @@ void e1000e_down(struct e1000_adapter *adapter)
 	e1000e_update_stats(adapter);
 	spin_unlock(&adapter->stats64_lock);
 
+	e1000e_flush_descriptors(adapter);
+	e1000_clean_tx_ring(adapter);
+	e1000_clean_rx_ring(adapter);
+
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
 
 	if (!pci_channel_offline(adapter->pdev))
 		e1000e_reset(adapter);
 
-	e1000e_flush_descriptors(adapter);
-
-	e1000_clean_tx_ring(adapter);
-	e1000_clean_rx_ring(adapter);
-
 	/*
 	 * TODO: for power management, we could drop the link and
 	 * pci_disable_device here.
-- 
1.7.5.2

