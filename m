From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] macvlan: Move broadcasts into a work queue
Date: Wed, 9 Apr 2014 16:50:01 +0800
Message-ID: <20140409085001.GA12938@gondor.apana.org.au>
References: <20140407075347.GA26461@gondor.apana.org.au>
 <E1WX4P2-0006wA-9Q@gondolin.me.apana.org.au>
 <20140408095523.2d4e14bd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:52905 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758121AbaDIIuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 04:50:08 -0400
Content-Disposition: inline
In-Reply-To: <20140408095523.2d4e14bd@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 08, 2014 at 09:55:23AM -0700, Stephen Hemminger wrote:
>
> unlikely() with goto is redundant and unnecessary.
> 
> IMHO jumping into a block is bad code style
> 
> Why not just move err: to the end as in:

Good point.  Here is an updated patch.

macvlan: Move broadcasts into a work queue

Currently broadcasts are handled in network RX context, where
the packets are sent through netif_rx.  This means that the number
of macvlans will be constrained by the capacity of netif_rx.

For example, setting up 4096 macvlans practically causes all
broadcast packets to be dropped as the default netif_rx queue
size simply can't handle 4096 skbs being stuffed into it all
at once.

Fundamentally, we need to ensure that the amount of work handled
in each netif_rx backlog run is constrained.  As broadcasts are
anything but constrained, it either needs to be limited per run
or moved to process context.

This patch picks the second option and moves all broadcast handling
bar the trivial case of packets going to a single interface into
a work queue.  Obviously there also needs to be a limit on how
many broadcast packets we postpone in this way.  I've arbitrarily
chosen tx_queue_len of the master device as the limit (act_mirred
also happens to use this parameter in a similar way).

In order to ensure we don't exceed the backlog queue we will use
netif_rx_ni instead of netif_rx for broadcast packets.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 753a8c2..8b8220f 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -30,6 +30,7 @@
 #include <linux/if_link.h>
 #include <linux/if_macvlan.h>
 #include <linux/hash.h>
+#include <linux/workqueue.h>
 #include <net/rtnetlink.h>
 #include <net/xfrm.h>
 
@@ -40,10 +41,18 @@ struct macvlan_port {
 	struct hlist_head	vlan_hash[MACVLAN_HASH_SIZE];
 	struct list_head	vlans;
 	struct rcu_head		rcu;
+	struct sk_buff_head	bc_queue;
+	struct work_struct	bc_work;
 	bool 			passthru;
 	int			count;
 };
 
+struct macvlan_skb_cb {
+	const struct macvlan_dev *src;
+};
+
+#define MACVLAN_SKB_CB(__skb) ((struct macvlan_skb_cb *)&((__skb)->cb[0]))
+
 static void macvlan_port_destroy(struct net_device *dev);
 
 static struct macvlan_port *macvlan_port_get_rcu(const struct net_device *dev)
@@ -120,7 +129,7 @@ static int macvlan_broadcast_one(struct sk_buff *skb,
 	struct net_device *dev = vlan->dev;
 
 	if (local)
-		return dev_forward_skb(dev, skb);
+		return __dev_forward_skb(dev, skb);
 
 	skb->dev = dev;
 	if (ether_addr_equal_64bits(eth->h_dest, dev->broadcast))
@@ -128,7 +137,7 @@ static int macvlan_broadcast_one(struct sk_buff *skb,
 	else
 		skb->pkt_type = PACKET_MULTICAST;
 
-	return netif_rx(skb);
+	return 0;
 }
 
 static u32 macvlan_hash_mix(const struct macvlan_dev *vlan)
@@ -175,32 +184,32 @@ static void macvlan_broadcast(struct sk_buff *skb,
 			if (likely(nskb))
 				err = macvlan_broadcast_one(
 					nskb, vlan, eth,
-					mode == MACVLAN_MODE_BRIDGE);
+					mode == MACVLAN_MODE_BRIDGE) ?:
+				      netif_rx_ni(nskb);
 			macvlan_count_rx(vlan, skb->len + ETH_HLEN,
 					 err == NET_RX_SUCCESS, 1);
 		}
 	}
 }
 
-/* called under rcu_read_lock() from netif_receive_skb */
-static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
+static void macvlan_process_broadcast(struct work_struct *w)
 {
-	struct macvlan_port *port;
-	struct sk_buff *skb = *pskb;
-	const struct ethhdr *eth = eth_hdr(skb);
-	const struct macvlan_dev *vlan;
-	const struct macvlan_dev *src;
-	struct net_device *dev;
-	unsigned int len = 0;
-	int ret = NET_RX_DROP;
+	struct macvlan_port *port = container_of(w, struct macvlan_port,
+						 bc_work);
+	struct sk_buff *skb;
+	struct sk_buff_head list;
+
+	skb_queue_head_init(&list);
+
+	spin_lock_bh(&port->bc_queue.lock);
+	skb_queue_splice_tail_init(&port->bc_queue, &list);
+	spin_unlock_bh(&port->bc_queue.lock);
+
+	while ((skb = __skb_dequeue(&list))) {
+		const struct macvlan_dev *src = MACVLAN_SKB_CB(skb)->src;
+
+		rcu_read_lock();
 
-	port = macvlan_port_get_rcu(skb->dev);
-	if (is_multicast_ether_addr(eth->h_dest)) {
-		skb = ip_check_defrag(skb, IP_DEFRAG_MACVLAN);
-		if (!skb)
-			return RX_HANDLER_CONSUMED;
-		eth = eth_hdr(skb);
-		src = macvlan_hash_lookup(port, eth->h_source);
 		if (!src)
 			/* frame comes from an external address */
 			macvlan_broadcast(skb, port, NULL,
@@ -213,20 +222,77 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 			macvlan_broadcast(skb, port, src->dev,
 					  MACVLAN_MODE_VEPA |
 					  MACVLAN_MODE_BRIDGE);
-		else if (src->mode == MACVLAN_MODE_BRIDGE)
+		else
 			/*
 			 * flood only to VEPA ports, bridge ports
 			 * already saw the frame on the way out.
 			 */
 			macvlan_broadcast(skb, port, src->dev,
 					  MACVLAN_MODE_VEPA);
-		else {
+
+		rcu_read_unlock();
+
+		kfree_skb(skb);
+	}
+}
+
+static void macvlan_broadcast_enqueue(struct macvlan_port *port,
+				      struct sk_buff *skb)
+{
+	int err = -ENOMEM;
+
+	skb = skb_clone(skb, GFP_ATOMIC);
+	if (!skb)
+		goto err;
+
+	spin_lock(&port->bc_queue.lock);
+	if (skb_queue_len(&port->bc_queue) < skb->dev->tx_queue_len) {
+		__skb_queue_tail(&port->bc_queue, skb);
+		err = 0;
+	}
+	spin_unlock(&port->bc_queue.lock);
+
+	if (err)
+		goto err;
+
+	schedule_work(&port->bc_work);
+	return;
+
+err:
+	atomic_long_inc(&skb->dev->rx_dropped);
+}
+
+/* called under rcu_read_lock() from netif_receive_skb */
+static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
+{
+	struct macvlan_port *port;
+	struct sk_buff *skb = *pskb;
+	const struct ethhdr *eth = eth_hdr(skb);
+	const struct macvlan_dev *vlan;
+	const struct macvlan_dev *src;
+	struct net_device *dev;
+	unsigned int len = 0;
+	int ret = NET_RX_DROP;
+
+	port = macvlan_port_get_rcu(skb->dev);
+	if (is_multicast_ether_addr(eth->h_dest)) {
+		skb = ip_check_defrag(skb, IP_DEFRAG_MACVLAN);
+		if (!skb)
+			return RX_HANDLER_CONSUMED;
+		eth = eth_hdr(skb);
+		src = macvlan_hash_lookup(port, eth->h_source);
+		if (src && src->mode != MACVLAN_MODE_VEPA &&
+		    src->mode != MACVLAN_MODE_BRIDGE) {
 			/* forward to original port. */
 			vlan = src;
-			ret = macvlan_broadcast_one(skb, vlan, eth, 0);
+			ret = macvlan_broadcast_one(skb, vlan, eth, 0) ?:
+			      netif_rx(skb);
 			goto out;
 		}
 
+		MACVLAN_SKB_CB(skb)->src = src;
+		macvlan_broadcast_enqueue(port, skb);
+
 		return RX_HANDLER_PASS;
 	}
 
@@ -764,6 +830,9 @@ static int macvlan_port_create(struct net_device *dev)
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
 		INIT_HLIST_HEAD(&port->vlan_hash[i]);
 
+	skb_queue_head_init(&port->bc_queue);
+	INIT_WORK(&port->bc_work, macvlan_process_broadcast);
+
 	err = netdev_rx_handler_register(dev, macvlan_handle_frame, port);
 	if (err)
 		kfree(port);
@@ -776,6 +845,7 @@ static void macvlan_port_destroy(struct net_device *dev)
 {
 	struct macvlan_port *port = macvlan_port_get_rtnl(dev);
 
+	cancel_work_sync(&port->bc_work);
 	dev->priv_flags &= ~IFF_MACVLAN_PORT;
 	netdev_rx_handler_unregister(dev);
 	kfree_rcu(port, rcu);

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
