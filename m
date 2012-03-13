From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] ixgbe: Do no clear Tx status bits since eop_desc provides enough info
Date: Mon, 12 Mar 2012 21:03:44 -0700
Message-ID: <1331611432-30109-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43936 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751604Ab2CMEED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 00:04:03 -0400
In-Reply-To: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There isn't any need to clear the status bits in the descriptors due to the
fact that the eop_desc provides enough information for us to know
that we have cleaned to the last packet that the software has put on the
ring.  The status bits are cleared as a part of putting the frame on the
ring so as long as we do not read the descriptor bit prior to reading the
value eop_desc we should be able to guarantee that we will not clean beyond
the end of the current data stream.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0609643..a2c14bf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -763,6 +763,9 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		if (!eop_desc)
 			break;
 
+		/* prevent any other reads prior to eop_desc */
+		rmb();
+
 		/* if DD is not set pending work has not been completed */
 		if (!(eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)))
 			break;
@@ -773,12 +776,8 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		/* clear next_to_watch to prevent false hangs */
 		tx_buffer->next_to_watch = NULL;
 
-		/* prevent any other reads prior to eop_desc being verified */
-		rmb();
-
 		do {
 			ixgbe_unmap_tx_resource(tx_ring, tx_buffer);
-			tx_desc->wb.status = 0;
 			if (likely(tx_desc == eop_desc)) {
 				eop_desc = NULL;
 				dev_kfree_skb_any(tx_buffer->skb);
-- 
1.7.7.6
