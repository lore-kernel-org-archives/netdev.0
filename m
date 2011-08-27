From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/6] ixgbevf: Check if EOP has changed before using it
Date: Sat, 27 Aug 2011 00:09:27 -0700
Message-ID: <1314428971-7676-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314428971-7676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:65345 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750942Ab1H0HJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Aug 2011 03:09:35 -0400
In-Reply-To: <1314428971-7676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

There is a chance that between the time EOP is read and the time it is
used another transmit on a different CPU could have run and completed,
thus leaving EOP in a bad state.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index b1e1c2d..936532f 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -203,6 +203,9 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_adapter *adapter,
 	       (count < tx_ring->work_limit)) {
 		bool cleaned = false;
 		rmb(); /* read buffer_info after eop_desc */
+		/* eop could change between read and DD-check */
+		if (unlikely(eop != tx_ring->tx_buffer_info[i].next_to_watch))
+			goto cont_loop;
 		for ( ; !cleaned; count++) {
 			struct sk_buff *skb;
 			tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
@@ -232,6 +235,7 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_adapter *adapter,
 				i = 0;
 		}
 
+cont_loop:
 		eop = tx_ring->tx_buffer_info[i].next_to_watch;
 		eop_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
 	}
-- 
1.7.6
