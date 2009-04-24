From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] macvlan: proper multicast support
Date: Fri, 24 Apr 2009 09:48:08 -0700
Message-ID: <20090424094808.74d401d8@nehalam>
References: <20090423091425.73ed544c@s6510>
	<49F1D5EF.3020306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52000 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751610AbZDXQsO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Apr 2009 12:48:14 -0400
In-Reply-To: <49F1D5EF.3020306@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using macvlan's multicast packets don't get properly passed between
macvlan's which should be logically sharing the network.  Any multicast
packet sent on a macvlan should show up lower device and all other macvlan's.
Likewise a multicast packet sent on lower device should be received
by all macvlan's.

The following is one way to do it; build tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/macvlan.c      |   69 +++++++++++++++++++++++++++++++--------------
 include/linux/if_macvlan.h |    1 
 net/core/dev.c             |   11 +++++++
 3 files changed, 60 insertions(+), 21 deletions(-)

--- a/drivers/net/macvlan.c	2009-04-24 08:56:54.832616816 -0700
+++ b/drivers/net/macvlan.c	2009-04-24 09:47:31.617996161 -0700
@@ -101,14 +101,29 @@ static int macvlan_addr_busy(const struc
 	return 0;
 }
 
+static int macvlan_clone(struct sk_buff *skb, struct net_device *dev)
+{
+	struct sk_buff *nskb;
+
+	nskb = skb_clone(skb, GFP_ATOMIC);
+	if (!nskb)
+		return -ENOMEM;
+
+	nskb->dev = dev;
+	nskb->pkt_type = is_broadcast_ether_addr(eth_hdr(nskb)->h_dest)
+		? PACKET_BROADCAST : PACKET_MULTICAST;
+
+	netif_rx(nskb);
+	return 0;
+}
+
+
 static void macvlan_broadcast(struct sk_buff *skb,
-			      const struct macvlan_port *port)
+			      const struct macvlan_port *port,
+			      const struct macvlan_dev *originator)
 {
-	const struct ethhdr *eth = eth_hdr(skb);
 	const struct macvlan_dev *vlan;
 	struct hlist_node *n;
-	struct net_device *dev;
-	struct sk_buff *nskb;
 	unsigned int i;
 
 	if (skb->protocol == htons(ETH_P_PAUSE))
@@ -116,26 +131,18 @@ static void macvlan_broadcast(struct sk_
 
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++) {
 		hlist_for_each_entry_rcu(vlan, n, &port->vlan_hash[i], hlist) {
-			dev = vlan->dev;
+			struct net_device *dev = vlan->dev;
+			if (vlan == originator)
+				continue;
 
-			nskb = skb_clone(skb, GFP_ATOMIC);
-			if (nskb == NULL) {
+			if (macvlan_clone(skb, dev)) {
 				dev->stats.rx_errors++;
 				dev->stats.rx_dropped++;
-				continue;
+			} else {
+				dev->stats.rx_bytes += skb->len + ETH_HLEN;
+				dev->stats.rx_packets++;
+				dev->stats.multicast++;
 			}
-
-			dev->stats.rx_bytes += skb->len + ETH_HLEN;
-			dev->stats.rx_packets++;
-			dev->stats.multicast++;
-
-			nskb->dev = dev;
-			if (!compare_ether_addr(eth->h_dest, dev->broadcast))
-				nskb->pkt_type = PACKET_BROADCAST;
-			else
-				nskb->pkt_type = PACKET_MULTICAST;
-
-			netif_rx(nskb);
 		}
 	}
 }
@@ -153,7 +160,7 @@ static struct sk_buff *macvlan_handle_fr
 		return skb;
 
 	if (is_multicast_ether_addr(eth->h_dest)) {
-		macvlan_broadcast(skb, port);
+		macvlan_broadcast(skb, port, NULL);
 		return skb;
 	}
 
@@ -184,13 +191,31 @@ static struct sk_buff *macvlan_handle_fr
 	return NULL;
 }
 
+/* called from dev_start_xmit if multicast is sent on lower device */
+static void macvlan_transmit_multicast(struct net_device *dev,
+				       struct sk_buff *skb)
+{
+	const struct ethhdr *eth = eth_hdr(skb);
+	const struct macvlan_port *port;
+
+	port = rcu_dereference(skb->dev->macvlan_port);
+	if (port && is_multicast_ether_addr(eth->h_dest))
+		macvlan_broadcast(skb, port, NULL);
+}
+
 static int macvlan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	const struct macvlan_dev *vlan = netdev_priv(dev);
+	const struct ethhdr *eth = eth_hdr(skb);
 	unsigned int len = skb->len;
 	int ret;
 
 	skb->dev = vlan->lowerdev;
+	if (is_multicast_ether_addr(eth->h_dest)) {
+		macvlan_broadcast(skb, vlan->port, vlan);
+		macvlan_clone(skb, vlan->lowerdev);
+	}
+
 	ret = dev_queue_xmit(skb);
 
 	if (likely(ret == NET_XMIT_SUCCESS)) {
@@ -605,6 +630,7 @@ static int __init macvlan_init_module(vo
 
 	register_netdevice_notifier(&macvlan_notifier_block);
 	macvlan_handle_frame_hook = macvlan_handle_frame;
+	macvlan_transmit_hook = macvlan_transmit_multicast;
 
 	err = rtnl_link_register(&macvlan_link_ops);
 	if (err < 0)
@@ -620,6 +646,7 @@ static void __exit macvlan_cleanup_modul
 {
 	rtnl_link_unregister(&macvlan_link_ops);
 	macvlan_handle_frame_hook = NULL;
+	macvlan_transmit_hook = NULL;
 	unregister_netdevice_notifier(&macvlan_notifier_block);
 }
 
--- a/include/linux/if_macvlan.h	2009-04-24 09:10:45.056475851 -0700
+++ b/include/linux/if_macvlan.h	2009-04-24 09:11:06.884508032 -0700
@@ -2,5 +2,6 @@
 #define _LINUX_IF_MACVLAN_H
 
 extern struct sk_buff *(*macvlan_handle_frame_hook)(struct sk_buff *);
+extern void (*macvlan_transmit_hook)(struct net_device *, struct sk_buff *);
 
 #endif /* _LINUX_IF_MACVLAN_H */
--- a/net/core/dev.c	2009-04-24 08:59:30.185453953 -0700
+++ b/net/core/dev.c	2009-04-24 09:47:25.371638613 -0700
@@ -1758,6 +1758,12 @@ static struct netdev_queue *dev_pick_tx(
 	return netdev_get_tx_queue(dev, queue_index);
 }
 
+#if defined(CONFIG_MACVLAN) || defined(CONFIG_MACVLAN_MODULE)
+void (*macvlan_transmit_hook)(struct net_device *, struct sk_buff *)
+	__read_mostly;
+EXPORT_SYMBOL_GPL(macvlan_transmit_hook);
+#endif
+
 /**
  *	dev_queue_xmit - transmit a buffer
  *	@skb: buffer to transmit
@@ -1818,6 +1824,11 @@ int dev_queue_xmit(struct sk_buff *skb)
 			goto out_kfree_skb;
 	}
 
+#if defined(CONFIG_MACVLAN) || defined(CONFIG_MACVLAN_MODULE)
+	if (unlikely(skb->dev->macvlan_port))
+		macvlan_transmit_hook(dev, skb);
+#endif
+
 gso:
 	/* Disable soft irqs for various locks below. Also
 	 * stops preemption for RCU.
