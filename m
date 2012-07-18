From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] ixgbevf: Do not rewind the Rx ring before bumping tail
Date: Wed, 18 Jul 2012 13:31:49 -0700
Message-ID: <1342643516-2696-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5779 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755963Ab2GRUcA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 16:32:00 -0400
In-Reply-To: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The driver is going back one step from its' previous location before
bumping tail. This is incorrect.  We should just be writing the value of
next_to_use into the tail register.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index b88218c..c27ce44 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -375,8 +375,6 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_adapter *adapter,
 no_buffers:
 	if (rx_ring->next_to_use != i) {
 		rx_ring->next_to_use = i;
-		if (i-- == 0)
-			i = (rx_ring->count - 1);
 
 		ixgbevf_release_rx_desc(&adapter->hw, rx_ring, i);
 	}
@@ -1240,9 +1238,8 @@ static void ixgbevf_configure(struct ixgbevf_adapter *adapter)
 	ixgbevf_configure_rx(adapter);
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		struct ixgbevf_ring *ring = &adapter->rx_ring[i];
-		ixgbevf_alloc_rx_buffers(adapter, ring, ring->count);
-		ring->next_to_use = ring->count - 1;
-		writel(ring->next_to_use, adapter->hw.hw_addr + ring->tail);
+		ixgbevf_alloc_rx_buffers(adapter, ring,
+					 IXGBE_DESC_UNUSED(ring));
 	}
 }
 
-- 
1.7.10.4
