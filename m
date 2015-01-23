From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] net: e1000: support txtd update delay via xmit_more
Date: Thu, 22 Jan 2015 18:37:10 -0800
Message-ID: <1421980631-1955-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:16348 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753484AbbAWChY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 21:37:24 -0500
In-Reply-To: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Don't update Tx tail descriptor if we queue hasn't been stopped and
we know at least one more skb will be sent right away.

Signed-off-by: Florian Westphal <fw@strlen.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 9242982..7f997d3 100644
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
@@ -3264,6 +3258,15 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 		/* Make sure there is space in the ring for the next send. */
 		e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
 
+		if (!skb->xmit_more ||
+		    netif_xmit_stopped(netdev_get_tx_queue(netdev, 0))) {
+			writel(tx_ring->next_to_use, hw->hw_addr + tx_ring->tdt);
+			/* we need this if more than one processor can write to
+			 * our tail at a time, it synchronizes IO on IA64/Altix
+			 * systems
+			 */
+			mmiowb();
+		}
 	} else {
 		dev_kfree_skb_any(skb);
 		tx_ring->buffer_info[first].time_stamp = 0;
-- 
1.9.3
