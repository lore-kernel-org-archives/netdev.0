From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/4] igb: Remove artificial restriction on RQDPC stat reading
Date: Tue, 18 Sep 2012 21:31:45 -0700
Message-ID: <1348029108-26659-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1348029108-26659-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50405 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753342Ab2ISEcB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 00:32:01 -0400
In-Reply-To: <1348029108-26659-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

For some reason the reading of the RQDPC register was being artificially
limited to 4K.  Instead of limiting the value we should read the value and
add the full amount.  Otherwise this can lead to a misleading number of
dropped packets when the actual value is in fact much higher.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Jeff Pieper   <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 19d7666..246646b 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4681,11 +4681,13 @@ void igb_update_stats(struct igb_adapter *adapter,
 	bytes = 0;
 	packets = 0;
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		u32 rqdpc_tmp = rd32(E1000_RQDPC(i)) & 0x0FFF;
+		u32 rqdpc = rd32(E1000_RQDPC(i));
 		struct igb_ring *ring = adapter->rx_ring[i];
 
-		ring->rx_stats.drops += rqdpc_tmp;
-		net_stats->rx_fifo_errors += rqdpc_tmp;
+		if (rqdpc) {
+			ring->rx_stats.drops += rqdpc;
+			net_stats->rx_fifo_errors += rqdpc;
+		}
 
 		do {
 			start = u64_stats_fetch_begin_bh(&ring->rx_syncp);
-- 
1.7.11.4
