From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/12] ixgbe: Use packets to track Tx completions instead of a seperate value
Date: Sat, 17 Mar 2012 01:50:57 -0700
Message-ID: <1331974260-6383-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28252 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755950Ab2CQIvc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 04:51:32 -0400
In-Reply-To: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

A separate value was added to track Tx completions in order to determine if
the Tx unit was hung.  However we can do the same thing using the number of
packets completed without having to add another stat to the Tx ring.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 +----
 2 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index b1e3baf..6d4ef1a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -173,7 +173,6 @@ struct ixgbe_queue_stats {
 struct ixgbe_tx_queue_stats {
 	u64 restart_queue;
 	u64 tx_busy;
-	u64 completed;
 	u64 tx_done_old;
 };
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index efce423..832a9fc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -661,7 +661,7 @@ static void ixgbe_update_xoff_received(struct ixgbe_adapter *adapter)
 
 static u64 ixgbe_get_tx_completed(struct ixgbe_ring *ring)
 {
-	return ring->tx_stats.completed;
+	return ring->stats.packets;
 }
 
 static u64 ixgbe_get_tx_pending(struct ixgbe_ring *ring)
@@ -760,9 +760,6 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		if (!(eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)))
 			break;
 
-		/* count the packet as being completed */
-		tx_ring->tx_stats.completed++;
-
 		/* clear next_to_watch to prevent false hangs */
 		tx_buffer->next_to_watch = NULL;
 
-- 
1.7.7.6
