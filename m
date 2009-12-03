From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/5] ixgbe: select FCoE Tx queue in
	ndo_select_queue
Date: Thu, 03 Dec 2009 13:32:44 -0800
Message-ID: <20091203213243.9291.21296.stgit@localhost.localdomain>
References: <20091203213221.9291.34218.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:54811
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755090AbZLCVc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:32:58 -0500
In-Reply-To: <20091203213221.9291.34218.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

This removes the Tx queue selection for FCoE traffic from ixgbe_xmit_frame()
and does it in the ndo_select_queue() call, moving all Tx queue selection
into a single routine.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 09990ed..e3dc68b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5286,10 +5286,19 @@ static int ixgbe_maybe_stop_tx(struct net_device *netdev,
 static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	int txq = smp_processor_id();
 
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
-		return smp_processor_id();
+		return txq;
 
+#ifdef IXGBE_FCOE
+	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
+	    (skb->protocol == htons(ETH_P_FCOE))) {
+		txq &= (adapter->ring_feature[RING_F_FCOE].indices - 1);
+		txq += adapter->ring_feature[RING_F_FCOE].mask;
+		return txq;
+	}
+#endif
 	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
 		return (skb->vlan_tci & IXGBE_TX_FLAGS_VLAN_PRIO_MASK) >> 13;
 
@@ -5304,7 +5313,7 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 	unsigned int first;
 	unsigned int tx_flags = 0;
 	u8 hdr_len = 0;
-	int r_idx = 0, tso;
+	int tso;
 	int count = 0;
 	unsigned int f;
 
@@ -5312,13 +5321,13 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 		tx_flags |= vlan_tx_tag_get(skb);
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 			tx_flags &= ~IXGBE_TX_FLAGS_VLAN_PRIO_MASK;
-			tx_flags |= (skb->queue_mapping << 13);
+			tx_flags |= ((skb->queue_mapping & 0x7) << 13);
 		}
 		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= IXGBE_TX_FLAGS_VLAN;
 	} else if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 		if (skb->priority != TC_PRIO_CONTROL) {
-			tx_flags |= (skb->queue_mapping << 13);
+			tx_flags |= ((skb->queue_mapping & 0x7) << 13);
 			tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
 			tx_flags |= IXGBE_TX_FLAGS_VLAN;
 		} else {
@@ -5327,8 +5336,7 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 		}
 	}
 
-	r_idx = skb->queue_mapping;
-	tx_ring = &adapter->tx_ring[r_idx];
+	tx_ring = &adapter->tx_ring[skb->queue_mapping];
 
 	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
 	    (skb->protocol == htons(ETH_P_FCOE))) {
@@ -5340,10 +5348,6 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 		tx_flags |= ((adapter->fcoe.up << 13)
 			      << IXGBE_TX_FLAGS_VLAN_SHIFT);
 #endif
-		r_idx = smp_processor_id();
-		r_idx &= (adapter->ring_feature[RING_F_FCOE].indices - 1);
-		r_idx += adapter->ring_feature[RING_F_FCOE].mask;
-		tx_ring = &adapter->tx_ring[r_idx];
 #endif
 	}
 	/* four things can cause us to need a context descriptor */

