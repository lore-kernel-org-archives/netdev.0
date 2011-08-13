From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/4] ixgbe: Fix FCOE memory leak for DDP packets
Date: Sat, 13 Aug 2011 02:23:37 -0700
Message-ID: <1313227420-9974-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313227420-9974-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12891 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751117Ab1HMJXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Aug 2011 05:23:43 -0400
In-Reply-To: <1313227420-9974-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch is meant to fix a memory leak found via code review for FCOE.
Specifically on DDP flows the SKBs were being dropped without being
recycled, freed, or given to the stack.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e86297b..2279039 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1459,8 +1459,10 @@ static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		if (ixgbe_rx_is_fcoe(adapter, rx_desc)) {
 			ddp_bytes = ixgbe_fcoe_ddp(adapter, rx_desc, skb,
 						   staterr);
-			if (!ddp_bytes)
+			if (!ddp_bytes) {
+				dev_kfree_skb_any(skb);
 				goto next_desc;
+			}
 		}
 #endif /* IXGBE_FCOE */
 		ixgbe_receive_skb(q_vector, skb, staterr, rx_ring, rx_desc);
-- 
1.7.6

