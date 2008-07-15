From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: TXQ real_num_tx_queues comments/questions
Date: Tue, 15 Jul 2008 03:05:31 -0700 (PDT)
Message-ID: <20080715.030531.227856924.davem@davemloft.net>
References: <1216114621.3535.18.camel@johannes.berg>
	<20080715.023954.234208581.davem@davemloft.net>
	<1216115349.3535.20.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1216115349.3535.20.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Tue, 15 Jul 2008 11:49:09 +0200

> Yes, I think we can fix it by deferring the requeue to a workqueue,
> using synchronize_net() and putting RCU protection against the
> select_queue call.

I'm respinning my net-tx-2.6 tree at the moment and I'll
make patch 8 look like below.

When I get to the mac80211 bits I'll add the appropriate
synchronize_net() call.

netdev: Add netdev->select_queue() method.

Devices or device layers can set this to control the queue selection
performed by dev_pick_tx().

This function runs under RCU protection, which allows overriding
functions to have some way of synchronizing with things like dynamic
->real_num_tx_queues adjustments.

This makes the spinlock prefetch in dev_queue_xmit() a little bit
less effective, but that's the price right now for correctness.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

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
