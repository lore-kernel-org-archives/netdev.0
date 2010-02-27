From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbe: move TC_PRIO_CONTROL check into
	ixgbe_select_queue()
Date: Fri, 26 Feb 2010 16:21:36 -0800
Message-ID: <20100227002135.32576.23757.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:59402
	"EHLO qmta14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966663Ab0B0AV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 19:21:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Move TC_PRIO_CONTROL check and queue remapping into
ixgbe_select_queue().  Remapping queues after the qdisc
can result in the wrong qdisc queue being stopped with
netif_stop_subqueue().  Even if this is resolved and the
correct queue is stopped it can result in a queue being
blocked by TC_PRIO_CONTROL frames uneccesarily.  Moving
this into the select_queue routine maintains alignment
between tx_rings and qdisc queues.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a961da2..45e3532 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5639,8 +5639,14 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 		return txq;
 	}
 #endif
-	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
-		return (skb->vlan_tci & IXGBE_TX_FLAGS_VLAN_PRIO_MASK) >> 13;
+	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+		if (skb->priority == TC_PRIO_CONTROL)
+			txq = adapter->ring_feature[RING_F_DCB].indices-1;
+		else
+			txq = (skb->vlan_tci & IXGBE_TX_FLAGS_VLAN_PRIO_MASK)
+			       >> 13;
+		return txq;
+	}
 
 	return skb_tx_hash(dev, skb);
 }
@@ -5667,14 +5673,9 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= IXGBE_TX_FLAGS_VLAN;
 	} else if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-		if (skb->priority != TC_PRIO_CONTROL) {
-			tx_flags |= ((skb->queue_mapping & 0x7) << 13);
-			tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
-			tx_flags |= IXGBE_TX_FLAGS_VLAN;
-		} else {
-			skb->queue_mapping =
-				adapter->ring_feature[RING_F_DCB].indices-1;
-		}
+		tx_flags |= ((skb->queue_mapping & 0x7) << 13);
+		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
+		tx_flags |= IXGBE_TX_FLAGS_VLAN;
 	}
 
 	tx_ring = adapter->tx_ring[skb->queue_mapping];

