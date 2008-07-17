From: David Miller <davem@davemloft.net>
Subject: [PATCH 9/31]: netdev: Add netdev->select_queue() method.
Date: Thu, 17 Jul 2008 05:16:24 -0700 (PDT)
Message-ID: <20080717.051624.264544962.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51636
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757127AbYGQMQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 08:16:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Devices or device layers can set this to control the queue selection
performed by dev_pick_tx().

This function runs under RCU protection, which allows overriding
functions to have some way of synchronizing with things like dynamic
->real_num_tx_queues adjustments.

This makes the spinlock prefetch in dev_queue_xmit() a little bit
less effective, but that's the price right now for correctness.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    3 +++
 net/core/dev.c            |    9 ++++++---
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fdac115..9464e64 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -724,6 +724,9 @@ struct net_device
 	void                    (*poll_controller)(struct net_device *dev);
 #endif
 
+	u16			(*select_queue)(struct net_device *dev,
+						struct sk_buff *skb);
+
 #ifdef CONFIG_NET_NS
 	/* Network namespace this network device is inside */
 	struct net		*nd_net;
diff --git a/net/core/dev.c b/net/core/dev.c
index f027a1a..7ca9564 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1670,6 +1670,9 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 {
 	u16 queue_index = 0;
 
+	if (dev->select_queue)
+		queue_index = dev->select_queue(dev, skb);
+
 	skb_set_queue_mapping(skb, queue_index);
 	return netdev_get_tx_queue(dev, queue_index);
 }
@@ -1710,14 +1713,14 @@ int dev_queue_xmit(struct sk_buff *skb)
 	}
 
 gso:
-	txq = dev_pick_tx(dev, skb);
-	spin_lock_prefetch(&txq->lock);
-
 	/* Disable soft irqs for various locks below. Also
 	 * stops preemption for RCU.
 	 */
 	rcu_read_lock_bh();
 
+	txq = dev_pick_tx(dev, skb);
+	spin_lock_prefetch(&txq->lock);
+
 	/* Updates of qdisc are serialized by queue->lock.
 	 * The struct Qdisc which is pointed to by qdisc is now a
 	 * rcu structure - it may be accessed without acquiring
-- 
1.5.6.2.255.gbed62

