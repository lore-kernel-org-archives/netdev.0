From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbe: priority tagging FCoE frames without FCoE
	offload
Date: Mon, 26 Jul 2010 23:41:31 -0700
Message-ID: <20100727064058.24599.57844.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Yi Zou <yi.zou@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:41496 "EHLO
	qmta07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750908Ab0G0Gl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 02:41:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

The DCB user priority for FCoE is available regardless of whether
FCoE offload is enabled (IXGBE_FLAG_FCOE_ENABLED bit is set).
This allows proper DCB user priority tagging for FCoE
traffic on both 82598 and 82599 devices.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   45 +++++++++++++++++++++-------------------
 1 files changed, 24 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 9203759..bc22ab4 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4783,6 +4783,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 #ifdef CONFIG_IXGBE_DCB
 		/* Default traffic class to use for FCoE */
 		adapter->fcoe.tc = IXGBE_FCOE_DEFTC;
+		adapter->fcoe.up = IXGBE_FCOE_DEFTC;
 #endif
 #endif /* IXGBE_FCOE */
 	}
@@ -6147,21 +6148,26 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	int txq = smp_processor_id();
 
+#ifdef IXGBE_FCOE
+	if ((skb->protocol == htons(ETH_P_FCOE)) ||
+	    (skb->protocol == htons(ETH_P_FIP))) {
+		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
+			txq &= (adapter->ring_feature[RING_F_FCOE].indices - 1);
+			txq += adapter->ring_feature[RING_F_FCOE].mask;
+			return txq;
+		} else if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+			txq = adapter->fcoe.up;
+			return txq;
+		}
+	}
+#endif
+
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
 		while (unlikely(txq >= dev->real_num_tx_queues))
 			txq -= dev->real_num_tx_queues;
 		return txq;
 	}
 
-#ifdef IXGBE_FCOE
-	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
-	    ((skb->protocol == htons(ETH_P_FCOE)) ||
-	     (skb->protocol == htons(ETH_P_FIP)))) {
-		txq &= (adapter->ring_feature[RING_F_FCOE].indices - 1);
-		txq += adapter->ring_feature[RING_F_FCOE].mask;
-		return txq;
-	}
-#endif
 	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 		if (skb->priority == TC_PRIO_CONTROL)
 			txq = adapter->ring_feature[RING_F_DCB].indices-1;
@@ -6205,18 +6211,15 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 	tx_ring = adapter->tx_ring[skb->queue_mapping];
 
 #ifdef IXGBE_FCOE
-	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
-#ifdef CONFIG_IXGBE_DCB
-		/* for FCoE with DCB, we force the priority to what
-		 * was specified by the switch */
-		if ((skb->protocol == htons(ETH_P_FCOE)) ||
-		    (skb->protocol == htons(ETH_P_FIP))) {
-			tx_flags &= ~(IXGBE_TX_FLAGS_VLAN_PRIO_MASK
-				      << IXGBE_TX_FLAGS_VLAN_SHIFT);
-			tx_flags |= ((adapter->fcoe.up << 13)
-				     << IXGBE_TX_FLAGS_VLAN_SHIFT);
-		}
-#endif
+	/* for FCoE with DCB, we force the priority to what
+	 * was specified by the switch */
+	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED &&
+	    (skb->protocol == htons(ETH_P_FCOE) ||
+	     skb->protocol == htons(ETH_P_FIP))) {
+		tx_flags &= ~(IXGBE_TX_FLAGS_VLAN_PRIO_MASK
+			      << IXGBE_TX_FLAGS_VLAN_SHIFT);
+		tx_flags |= ((adapter->fcoe.up << 13)
+			      << IXGBE_TX_FLAGS_VLAN_SHIFT);
 		/* flag for FCoE offloads */
 		if (skb->protocol == htons(ETH_P_FCOE))
 			tx_flags |= IXGBE_TX_FLAGS_FCOE;

