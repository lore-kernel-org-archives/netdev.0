From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/2] ixgbe: Identify FCoE rings earlier to resolve memory corruption w/ FCoE
Date: Tue, 17 Apr 2012 15:48:05 -0700
Message-ID: <1334702885-4411-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1334702885-4411-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10896 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751657Ab2DQWsJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 18:48:09 -0400
In-Reply-To: <1334702885-4411-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch makes it so that we identify FCoE rings earlier than
ixgbe_set_rx_buffer_len.  Instead we identify the Rx FCoE rings at
allocation time in ixgbe_alloc_q_vector.

The motivation behind this change is to avoid memory corruption when FCoE
is enabled.  Without this change we were initializing the rings at 0, and
2K on systems with 4K pages, then when we bumped the buffer size to 4K with
order 1 pages we were accessing offsets 2K and 6K instead of 0 and 4K.
This was resulting in memory corruptions.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Yi Zou <yi.zou@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |   10 ++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    8 --------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 027d7a7..ed1b47d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -622,6 +622,16 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter, int v_idx,
 		if (adapter->hw.mac.type == ixgbe_mac_82599EB)
 			set_bit(__IXGBE_RX_CSUM_UDP_ZERO_ERR, &ring->state);
 
+#ifdef IXGBE_FCOE
+		if (adapter->netdev->features & NETIF_F_FCOE_MTU) {
+			struct ixgbe_ring_feature *f;
+			f = &adapter->ring_feature[RING_F_FCOE];
+			if ((rxr_idx >= f->mask) &&
+			    (rxr_idx < f->mask + f->indices))
+				set_bit(__IXGBE_RX_FCOE_BUFSZ, &ring->state);
+		}
+
+#endif /* IXGBE_FCOE */
 		/* apply Rx specific ring traits */
 		ring->count = adapter->rx_ring_count;
 		ring->queue_index = rxr_idx;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9e2be8c..a7f3cd8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3154,14 +3154,6 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 			set_ring_rsc_enabled(rx_ring);
 		else
 			clear_ring_rsc_enabled(rx_ring);
-#ifdef IXGBE_FCOE
-		if (netdev->features & NETIF_F_FCOE_MTU) {
-			struct ixgbe_ring_feature *f;
-			f = &adapter->ring_feature[RING_F_FCOE];
-			if ((i >= f->mask) && (i < f->mask + f->indices))
-				set_bit(__IXGBE_RX_FCOE_BUFSZ, &rx_ring->state);
-		}
-#endif /* IXGBE_FCOE */
 	}
 }
 
-- 
1.7.7.6
