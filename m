From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] net: e1000e: support txtd update delay via xmit_more
Date: Thu, 22 Jan 2015 18:37:11 -0800
Message-ID: <1421980631-1955-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:16352 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754257AbbAWChY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 21:37:24 -0500
In-Reply-To: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Don't update Tx tail descriptor if queue hasn't been stopped
and we know at least one more skb will be sent right away.

Signed-off-by: Florian Westphal <fw@strlen.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 25 +++++++++++++++----------
 1 file changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index aa39a81..1e8c40f 100644
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
@@ -5655,6 +5645,21 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 				    (MAX_SKB_FRAGS *
 				     DIV_ROUND_UP(PAGE_SIZE,
 						  adapter->tx_fifo_limit) + 2));
+
+		if (!skb->xmit_more ||
+		    netif_xmit_stopped(netdev_get_tx_queue(netdev, 0))) {
+			if (adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
+				e1000e_update_tdt_wa(tx_ring,
+						     tx_ring->next_to_use);
+			else
+				writel(tx_ring->next_to_use, tx_ring->tail);
+
+			/* we need this if more than one processor can write
+			 * to our tail at a time, it synchronizes IO on
+			 *IA64/Altix systems
+			 */
+			mmiowb();
+		}
 	} else {
 		dev_kfree_skb_any(skb);
 		tx_ring->buffer_info[first].time_stamp = 0;
-- 
1.9.3
