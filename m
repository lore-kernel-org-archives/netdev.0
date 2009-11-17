From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/3] macvlan: Reflect macvlan packets meant for other macvlan devices
Date: Tue, 17 Nov 2009 22:39:08 +0000
Message-ID: <1258497551-25959-2-git-send-email-arnd@arndb.de>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@linux-foundation.com,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:53901 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755571AbZKQWl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 17:41:26 -0500
In-Reply-To: <1258497551-25959-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Biederman <ebiederm@xmission.com>

Switch ports do not send packets back out the same port they came
in on.	This causes problems when using a macvlan device inside
of a network namespace as it becomes impossible to talk to
other macvlan devices.

Signed-off-by: Eric Biederman <ebiederm@xmission.com>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/macvlan.c |   91 ++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 67 insertions(+), 24 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 3aabfd9..406b8b5 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -29,6 +29,7 @@
 #include <linux/if_link.h>
 #include <linux/if_macvlan.h>
 #include <net/rtnetlink.h>
+#include <net/xfrm.h>
 
 #define MACVLAN_HASH_SIZE	(1 << BITS_PER_BYTE)
 
@@ -102,7 +103,8 @@ static int macvlan_addr_busy(const struct macvlan_port *port,
 }
 
 static void macvlan_broadcast(struct sk_buff *skb,
-			      const struct macvlan_port *port)
+			      const struct macvlan_port *port,
+			      struct net_device *src)
 {
 	const struct ethhdr *eth = eth_hdr(skb);
 	const struct macvlan_dev *vlan;
@@ -118,6 +120,9 @@ static void macvlan_broadcast(struct sk_buff *skb,
 		hlist_for_each_entry_rcu(vlan, n, &port->vlan_hash[i], hlist) {
 			dev = vlan->dev;
 
+			if (dev == src)
+				continue;
+
 			nskb = skb_clone(skb, GFP_ATOMIC);
 			if (nskb == NULL) {
 				dev->stats.rx_errors++;
@@ -140,20 +145,45 @@ static void macvlan_broadcast(struct sk_buff *skb,
 	}
 }
 
+static int macvlan_unicast(struct sk_buff *skb, const struct macvlan_dev *dest)
+{
+	struct net_device *dev = dest->dev;
+
+	if (unlikely(!dev->flags & IFF_UP)) {
+		kfree_skb(skb);
+		return NET_XMIT_DROP;
+	}
+
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (!skb) {
+		dev->stats.rx_errors++;
+		dev->stats.rx_dropped++;
+		return NET_XMIT_DROP;
+	}
+
+	dev->stats.rx_bytes += skb->len + ETH_HLEN;
+	dev->stats.rx_packets++;
+
+	skb->dev = dev;
+	skb->pkt_type = PACKET_HOST;
+	netif_rx(skb);
+	return NET_XMIT_SUCCESS;
+}
+
+
 /* called under rcu_read_lock() from netif_receive_skb */
 static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 {
 	const struct ethhdr *eth = eth_hdr(skb);
 	const struct macvlan_port *port;
 	const struct macvlan_dev *vlan;
-	struct net_device *dev;
 
 	port = rcu_dereference(skb->dev->macvlan_port);
 	if (port == NULL)
 		return skb;
 
 	if (is_multicast_ether_addr(eth->h_dest)) {
-		macvlan_broadcast(skb, port);
+		macvlan_broadcast(skb, port, NULL);
 		return skb;
 	}
 
@@ -161,27 +191,43 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 	if (vlan == NULL)
 		return skb;
 
-	dev = vlan->dev;
-	if (unlikely(!(dev->flags & IFF_UP))) {
-		kfree_skb(skb);
-		return NULL;
-	}
+	macvlan_unicast(skb, vlan);
+	return NULL;
+}
 
-	skb = skb_share_check(skb, GFP_ATOMIC);
-	if (skb == NULL) {
-		dev->stats.rx_errors++;
-		dev->stats.rx_dropped++;
-		return NULL;
-	}
+static int macvlan_xmit_world(struct sk_buff *skb, struct net_device *dev)
+{
+	const struct macvlan_dev *vlan = netdev_priv(dev);
+	__skb_push(skb, skb->data - skb_mac_header(skb));
+	skb->dev = vlan->lowerdev;
+	return dev_queue_xmit(skb);
+}
 
-	dev->stats.rx_bytes += skb->len + ETH_HLEN;
-	dev->stats.rx_packets++;
+static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	const struct macvlan_dev *vlan = netdev_priv(dev);
+	const struct macvlan_port *port = vlan->port;
+	const struct macvlan_dev *dest;
+	const struct ethhdr *eth;
 
-	skb->dev = dev;
-	skb->pkt_type = PACKET_HOST;
+	skb->protocol = eth_type_trans(skb, dev);
+	eth = eth_hdr(skb);
 
-	netif_rx(skb);
-	return NULL;
+	skb_dst_drop(skb);
+	skb->mark = 0;
+	secpath_reset(skb);
+	nf_reset(skb);
+
+	if (is_multicast_ether_addr(eth->h_dest)) {
+		macvlan_broadcast(skb, port, dev);
+		return macvlan_xmit_world(skb, dev);
+	}
+
+	dest = macvlan_hash_lookup(port, eth->h_dest);
+	if (dest)
+		return macvlan_unicast(skb, dest);
+
+	return macvlan_xmit_world(skb, dev);
 }
 
 static netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
@@ -189,13 +235,10 @@ static netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 {
 	int i = skb_get_queue_mapping(skb);
 	struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
-	const struct macvlan_dev *vlan = netdev_priv(dev);
 	unsigned int len = skb->len;
 	int ret;
 
-	skb->dev = vlan->lowerdev;
-	ret = dev_queue_xmit(skb);
-
+	ret = macvlan_queue_xmit(skb, dev);
 	if (likely(ret == NET_XMIT_SUCCESS)) {
 		txq->tx_packets++;
 		txq->tx_bytes += len;
-- 
1.6.3.3

