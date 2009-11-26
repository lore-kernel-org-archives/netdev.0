From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCHv3 3/4] macvlan: implement bridge, VEPA and private mode
Date: Thu, 26 Nov 2009 17:07:10 +0100
Message-ID: <1259251631-11617-4-git-send-email-arnd@arndb.de>
References: <1259251631-11617-1-git-send-email-arnd@arndb.de>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Patrick Mullaney <pmullaney@novell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:55818 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760699AbZKZQHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 11:07:31 -0500
In-Reply-To: <1259251631-11617-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows each macvlan slave device to be in one
of three modes, depending on the use case:

MACVLAN_PRIVATE:
  The device never communicates with any other device
  on the same upper_dev. This even includes frames
  coming back from a reflective relay, where supported
  by the adjacent bridge.

MACVLAN_VEPA:
  The new Virtual Ethernet Port Aggregator (VEPA) mode,
  we assume that the adjacent bridge returns all frames
  where both source and destination are local to the
  macvlan port, i.e. the bridge is set up as a reflective
  relay.
  Broadcast frames coming in from the upper_dev get
  flooded to all macvlan interfaces in VEPA mode.
  We never deliver any frames locally.

MACVLAN_BRIDGE:
  We provide the behavior of a simple bridge between
  different macvlan interfaces on the same port. Frames
  from one interface to another one get delivered directly
  and are not sent out externally. Broadcast frames get
  flooded to all other bridge ports and to the external
  interface, but when they come back from a reflective
  relay, we don't deliver them again.
  Since we know all the MAC addresses, the macvlan bridge
  mode does not require learning or STP like the bridge
  module does.

Based on an earlier patch "macvlan: Reflect macvlan packets
meant for other macvlan devices" by Eric Biederman.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Eric Biederman <ebiederm@xmission.com>
---
 drivers/net/macvlan.c |   80 ++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 72 insertions(+), 8 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 1e7faf9..d6bd843 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -29,9 +29,16 @@
 #include <linux/if_link.h>
 #include <linux/if_macvlan.h>
 #include <net/rtnetlink.h>
+#include <net/xfrm.h>
 
 #define MACVLAN_HASH_SIZE	(1 << BITS_PER_BYTE)
 
+enum macvlan_mode {
+	MACVLAN_MODE_PRIVATE	= 1,
+	MACVLAN_MODE_VEPA	= 2,
+	MACVLAN_MODE_BRIDGE	= 4,
+};
+
 struct macvlan_port {
 	struct net_device	*dev;
 	struct hlist_head	vlan_hash[MACVLAN_HASH_SIZE];
@@ -59,6 +66,7 @@ struct macvlan_dev {
 	struct macvlan_port	*port;
 	struct net_device	*lowerdev;
 	struct macvlan_rx_stats *rx_stats;
+	enum macvlan_mode	mode;
 };
 
 
@@ -134,11 +142,14 @@ static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
 }
 
 static int macvlan_broadcast_one(struct sk_buff *skb, struct net_device *dev,
-				 const struct ethhdr *eth)
+				 const struct ethhdr *eth, bool local)
 {
 	if (!skb)
 		return NET_RX_DROP;
 
+	if (local)
+		return dev_forward_skb(dev, skb);
+
 	skb->dev = dev;
 	if (!compare_ether_addr_64bits(eth->h_dest,
 				       dev->broadcast))
@@ -150,7 +161,9 @@ static int macvlan_broadcast_one(struct sk_buff *skb, struct net_device *dev,
 }
 
 static void macvlan_broadcast(struct sk_buff *skb,
-			      const struct macvlan_port *port)
+			      const struct macvlan_port *port,
+			      struct net_device *src,
+			      enum macvlan_mode mode)
 {
 	const struct ethhdr *eth = eth_hdr(skb);
 	const struct macvlan_dev *vlan;
@@ -164,8 +177,12 @@ static void macvlan_broadcast(struct sk_buff *skb,
 
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++) {
 		hlist_for_each_entry_rcu(vlan, n, &port->vlan_hash[i], hlist) {
+			if (vlan->dev == src || !(vlan->mode & mode))
+				continue;
+
 			nskb = skb_clone(skb, GFP_ATOMIC);
-			err = macvlan_broadcast_one(nskb, vlan->dev, eth);
+			err = macvlan_broadcast_one(nskb, vlan->dev, eth,
+					 mode == MACVLAN_MODE_BRIDGE);
 			macvlan_count_rx(vlan, skb->len + ETH_HLEN,
 					 err == NET_RX_SUCCESS, 1);
 		}
@@ -178,6 +195,7 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 	const struct ethhdr *eth = eth_hdr(skb);
 	const struct macvlan_port *port;
 	const struct macvlan_dev *vlan;
+	const struct macvlan_dev *src;
 	struct net_device *dev;
 	unsigned int len;
 
@@ -186,7 +204,25 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 		return skb;
 
 	if (is_multicast_ether_addr(eth->h_dest)) {
-		macvlan_broadcast(skb, port);
+		src = macvlan_hash_lookup(port, eth->h_source);
+		if (!src)
+			/* frame comes from an external address */
+			macvlan_broadcast(skb, port, NULL,
+					  MACVLAN_MODE_PRIVATE |
+					  MACVLAN_MODE_VEPA    |
+					  MACVLAN_MODE_BRIDGE);
+		else if (src->mode == MACVLAN_MODE_VEPA)
+			/* flood to everyone except source */
+			macvlan_broadcast(skb, port, src->dev,
+					  MACVLAN_MODE_VEPA |
+					  MACVLAN_MODE_BRIDGE);
+		else if (src->mode == MACVLAN_MODE_BRIDGE)
+			/*
+			 * flood only to VEPA ports, bridge ports
+			 * already saw the frame on the way out.
+			 */
+			macvlan_broadcast(skb, port, src->dev,
+					  MACVLAN_MODE_VEPA);
 		return skb;
 	}
 
@@ -212,18 +248,46 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 	return NULL;
 }
 
+static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	const struct macvlan_dev *vlan = netdev_priv(dev);
+	const struct macvlan_port *port = vlan->port;
+	const struct macvlan_dev *dest;
+
+	if (vlan->mode == MACVLAN_MODE_BRIDGE) {
+		const struct ethhdr *eth = (void *)skb->data;
+
+		/* send to other bridge ports directly */
+		if (is_multicast_ether_addr(eth->h_dest)) {
+			macvlan_broadcast(skb, port, dev, MACVLAN_MODE_BRIDGE);
+			goto xmit_world;
+		}
+
+		dest = macvlan_hash_lookup(port, eth->h_dest);
+		if (dest && dest->mode == MACVLAN_MODE_BRIDGE) {
+			unsigned int length = skb->len + ETH_HLEN;
+			int ret = dev_forward_skb(dest->dev, skb);
+			macvlan_count_rx(dest, length,
+					 ret == NET_RX_SUCCESS, 0);
+
+			return NET_XMIT_SUCCESS;
+		}
+	}
+
+xmit_world:
+	skb->dev = vlan->lowerdev;
+	return dev_queue_xmit(skb);
+}
+
 static netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 				      struct net_device *dev)
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

