From: Eldon Koyle <esk-netdev@esk.cs.usu.edu>
Subject: multiqueue, skb_get_queue_mapping() and netdev_get_tx_queue()
Date: Wed, 14 Jul 2010 17:13:53 -0600
Message-ID: <20100714231352.GA32397@esk.cs.usu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from esk.cs.usu.edu ([129.123.28.15]:36351 "EHLO esk.cs.usu.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757614Ab0GNXle (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jul 2010 19:41:34 -0400
Received: from esk by esk.cs.usu.edu with local (Exim 4.69)
	(envelope-from <esk@esk.cs.usu.edu>)
	id 1OZB9F-0000Kc-1W
	for netdev@vger.kernel.org; Wed, 14 Jul 2010 17:13:53 -0600
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like there is a potential for an out of bounds index anywhere
skb_get_queue_mapping(skb) (which just returns skb->queue_mapping) is
used to get an index for netdev_get_tx_queue() (and probably other
places) on a device with multiple rx/tx queues.

As I understand it, skb->queue_mapping should contain rx_queue + 1,
which can be out of range for netdev_get_tx_queue (which expects a
0-based index).

Am I misunderstanding something, or should all of these occurrences be
replaced with something more like the following?

static inline u16 skb_get_queue_index(const struct sk_buff *skb)
{
        return skb->queue_mapping ? skb->queue_mapping - 1 : 0;
}

Here is how it is commonly used (which looks incorrect to me):
In net/8021q/vlan_dev.c:
	static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
						    struct net_device *dev)
	{
		int i = skb_get_queue_mapping(skb);
		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
	...


And here is some other possibly pertinent code:
In include/linux/netdevice.h:
	static inline
	struct netdev_queue *netdev_get_tx_queue(const struct net_device *dev,
						 unsigned int index)
	{
		return &dev->_tx[index];
	}

In net/core/dev.c:
	struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
			void (*setup)(struct net_device *), unsigned int queue_count)
	...
		tx = kcalloc(queue_count, sizeof(struct netdev_queue), GFP_KERNEL);
	...
		dev->_tx = tx;
	...

In include/linux/skbuff.h:
	static inline u16 skb_get_queue_mapping(const struct sk_buff *skb)
	{
		return skb->queue_mapping;
	}
	...
	static inline void skb_record_rx_queue(struct sk_buff *skb, u16 rx_queue)
	{
		skb->queue_mapping = rx_queue + 1;
	}

	static inline u16 skb_get_rx_queue(const struct sk_buff *skb)
	{
		return skb->queue_mapping - 1;
	}


-- 
Eldon Koyle
-- 
Politicians are the same all over.  They promise to build a bridge even
where there is no river.
		-- Nikita Khrushchev
