From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] ixgbe: Priority tag FIP frames
Date: Wed, 24 Mar 2010 15:45:00 -0700
Message-ID: <20100324224500.6653.28216.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Robert Love <robert.w.love@intel.com>,
	Chris Leech <christopher.leech@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:48673
	"EHLO qmta14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750826Ab0CXWpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 18:45:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Love <robert.w.love@intel.com>

Currently FIP (FCoE Initialization Protocol) frames
are going untagged. This causes various problems
with FCFs (switches) that have negotiated a priority
over dcbx. This patch tags FIP frames with the same
priority as the FCoE frames.

Signed-off-by: Robert Love <robert.w.love@intel.com>
Signed-off-by: Chris Leech <christopher.leech@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   26 +++++++++++++++++---------
 1 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a9147e5..997d997 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5628,7 +5628,8 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 
 #ifdef IXGBE_FCOE
 	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
-	    (skb->protocol == htons(ETH_P_FCOE))) {
+	    ((skb->protocol == htons(ETH_P_FCOE)) ||
+	     (skb->protocol == htons(ETH_P_FIP)))) {
 		txq &= (adapter->ring_feature[RING_F_FCOE].indices - 1);
 		txq += adapter->ring_feature[RING_F_FCOE].mask;
 		return txq;
@@ -5675,18 +5676,25 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 
 	tx_ring = adapter->tx_ring[skb->queue_mapping];
 
-	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
-	    (skb->protocol == htons(ETH_P_FCOE))) {
-		tx_flags |= IXGBE_TX_FLAGS_FCOE;
 #ifdef IXGBE_FCOE
+	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
 #ifdef CONFIG_IXGBE_DCB
-		tx_flags &= ~(IXGBE_TX_FLAGS_VLAN_PRIO_MASK
-			      << IXGBE_TX_FLAGS_VLAN_SHIFT);
-		tx_flags |= ((adapter->fcoe.up << 13)
-			      << IXGBE_TX_FLAGS_VLAN_SHIFT);
-#endif
+		/* for FCoE with DCB, we force the priority to what
+		 * was specified by the switch */
+		if ((skb->protocol == htons(ETH_P_FCOE)) ||
+		    (skb->protocol == htons(ETH_P_FIP))) {
+			tx_flags &= ~(IXGBE_TX_FLAGS_VLAN_PRIO_MASK
+				      << IXGBE_TX_FLAGS_VLAN_SHIFT);
+			tx_flags |= ((adapter->fcoe.up << 13)
+				     << IXGBE_TX_FLAGS_VLAN_SHIFT);
+		}
 #endif
+		/* flag for FCoE offloads */
+		if (skb->protocol == htons(ETH_P_FCOE))
+			tx_flags |= IXGBE_TX_FLAGS_FCOE;
 	}
+#endif
+
 	/* four things can cause us to need a context descriptor */
 	if (skb_is_gso(skb) ||
 	    (skb->ip_summed == CHECKSUM_PARTIAL) ||

