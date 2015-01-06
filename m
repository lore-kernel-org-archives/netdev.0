From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next] net: e1000: support txtd update delay via xmit_more
Date: Tue,  6 Jan 2015 16:16:59 +0100
Message-ID: <1420557419-18869-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:40355 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754388AbbAFPRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 10:17:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't update tx tail descriptor if we queue hasn't been stopped and
we know at least one more skb will be sent right away.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 83140cb..714b727 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -2977,7 +2977,6 @@ static void e1000_tx_queue(struct e1000_adapter *adapter,
 			   struct e1000_tx_ring *tx_ring, int tx_flags,
 			   int count)
 {
-	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_tx_desc *tx_desc = NULL;
 	struct e1000_tx_buffer *buffer_info;
 	u32 txd_upper = 0, txd_lower = E1000_TXD_CMD_IFCS;
@@ -3031,11 +3030,6 @@ static void e1000_tx_queue(struct e1000_adapter *adapter,
 	wmb();
 
 	tx_ring->next_to_use = i;
-	writel(i, hw->hw_addr + tx_ring->tdt);
-	/* we need this if more than one processor can write to our tail
-	 * at a time, it synchronizes IO on IA64/Altix systems
-	 */
-	mmiowb();
 }
 
 /* 82547 workaround to avoid controller hang in half-duplex environment.
@@ -3263,6 +3257,14 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 		/* Make sure there is space in the ring for the next send. */
 		e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
 
+		if (!skb->xmit_more ||
+		    netif_xmit_stopped(netdev_get_tx_queue(netdev, 0))) {
+			writel(tx_ring->next_to_use, hw->hw_addr + tx_ring->tdt);
+			/* we need this if more than one processor can write to our tail
+			 * at a time, it synchronizes IO on IA64/Altix systems
+			 */
+			mmiowb();
+		}
 	} else {
 		dev_kfree_skb_any(skb);
 		tx_ring->buffer_info[first].time_stamp = 0;
-- 
2.0.5
