From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next] net: e1000e: support txtd update delay via xmit_more
Date: Wed,  7 Jan 2015 10:49:22 +0100
Message-ID: <1420624162-24206-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42676 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751993AbbAGJt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 04:49:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't update tx tail descriptor if queue hasn't been stopped
and we know at least one more skb will be sent right away.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 332a298..214cb78 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5444,16 +5444,6 @@ static void e1000_tx_queue(struct e1000_ring *tx_ring, int tx_flags, int count)
 	wmb();
 
 	tx_ring->next_to_use = i;
-
-	if (adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
-		e1000e_update_tdt_wa(tx_ring, i);
-	else
-		writel(i, tx_ring->tail);
-
-	/* we need this if more than one processor can write to our tail
-	 * at a time, it synchronizes IO on IA64/Altix systems
-	 */
-	mmiowb();
 }
 
 #define MINIMUM_DHCP_PACKET_SIZE 282
@@ -5653,6 +5643,19 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 				    (MAX_SKB_FRAGS *
 				     DIV_ROUND_UP(PAGE_SIZE,
 						  adapter->tx_fifo_limit) + 2));
+
+		if (!skb->xmit_more ||
+		    netif_xmit_stopped(netdev_get_tx_queue(netdev, 0))) {
+			if (adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
+				e1000e_update_tdt_wa(tx_ring, tx_ring->next_to_use);
+			else
+				writel(tx_ring->next_to_use, tx_ring->tail);
+
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
