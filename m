From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] net: Fix issue with netdev_tx_reset_queue not resetting queue from XOFF state
Date: Mon, 12 Mar 2012 21:03:42 -0700
Message-ID: <1331611432-30109-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43936 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751284Ab2CMED6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 00:03:58 -0400
In-Reply-To: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

We are seeing dev_watchdog hangs on several drivers.  I suspect this is due
to the __QUEUE_STATE_STACK_XOFF bit being set prior to a reset for link
change, and then not being cleared by netdev_tx_reset_queue.  This change
corrects that.

In addition we were seeing dev_watchdog hangs on igb after running the
ethtool tests.  We found this to be due to the fact that the ethtool test
runs the same logic as ndo_start_xmit, but we were never clearing the XOFF
flag since the loopback test in ethtool does not do byte queue accounting.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    3 ++-
 include/linux/netdevice.h                 |    1 +
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index fda8247..e96cef8 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2752,6 +2752,8 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
 
 	txdctl |= E1000_TXDCTL_QUEUE_ENABLE;
 	wr32(E1000_TXDCTL(reg_idx), txdctl);
+
+	netdev_tx_reset_queue(txring_txq(ring));
 }
 
 /**
@@ -3244,7 +3246,6 @@ static void igb_clean_tx_ring(struct igb_ring *tx_ring)
 		buffer_info = &tx_ring->tx_buffer_info[i];
 		igb_unmap_and_free_tx_resource(tx_ring, buffer_info);
 	}
-	netdev_tx_reset_queue(txring_txq(tx_ring));
 
 	size = sizeof(struct igb_tx_buffer) * tx_ring->count;
 	memset(tx_ring->tx_buffer_info, 0, size);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b195a34..4bf314f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1939,6 +1939,7 @@ static inline void netdev_completed_queue(struct net_device *dev,
 static inline void netdev_tx_reset_queue(struct netdev_queue *q)
 {
 #ifdef CONFIG_BQL
+	clear_bit(__QUEUE_STATE_STACK_XOFF, &q->state);
 	dql_reset(&q->dql);
 #endif
 }
-- 
1.7.7.6
