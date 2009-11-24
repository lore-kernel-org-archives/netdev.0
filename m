From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 3/4] macvlan: implement bridge, VEPA and private mode
Date: Tue, 24 Nov 2009 00:56:05 +0000
Message-ID: <1259024166-28158-4-git-send-email-arnd@arndb.de>
References: <1259024166-28158-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Anna Fischer <anna.fischer@hp.com>, netdev@vger.kernel.org,
        bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        Mark Smith <lk-netdev@lk-netdev.nosense.org>,
        Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
        Arnd Bergmann <arnd@arndb.de>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Jens Osterkamp <jens@linux.vnet.ibm.com>,
        Patrick Mullaney <pmullaney@novell.com>,
        Stephen Hemminger <shemminger@vyatta.com>,
        Edge Virtual Bridging <evb@yahoogroups.com>,
        David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1259024166-28158-1-git-send-email-arnd@arndb.de>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

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
 drivers/net/macvlan.c |   75 +++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 67 insertions(+), 8 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index a0dea23..b840b3a 100644
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
 
 
@@ -129,11 +137,14 @@ static inline void macvlan_count_rx(const struct macvlan_dev *vlan, int length,
 }
 
 static int macvlan_broadcast_one(struct sk_buff *skb, struct net_device *dev,
-				 const struct ethhdr *eth)
+				 const struct ethhdr *eth, int local)
 {
 	if (!skb)
 		return NET_RX_DROP;
 
+	if (local)
+		return dev_forward_skb(dev, skb);
+
 	skb->dev = dev;
 	if (!compare_ether_addr_64bits(eth->h_dest,
 				       dev->broadcast))
@@ -145,7 +156,9 @@ static int macvlan_broadcast_one(struct sk_buff *skb, struct net_device *dev,
 }
 
 static void macvlan_broadcast(struct sk_buff *skb,
-			      const struct macvlan_port *port)
+			      const struct macvlan_port *port,
+			      struct net_device *src,
+			      enum macvlan_mode mode)
 {
 	const struct ethhdr *eth = eth_hdr(skb);
 	const struct macvlan_dev *vlan;
@@ -159,8 +172,12 @@ static void macvlan_broadcast(struct sk_buff *skb,
 
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++) {
 		hlist_for_each_entry_rcu(vlan, n, &port->vlan_hash[i], hlist) {
+			if ((vlan->dev == src) || !(vlan->mode & mode))
+				continue;
+
 			nskb = skb_clone(skb, GFP_ATOMIC);
-			err = macvlan_broadcast_one(nskb, vlan->dev, eth);
+			err = macvlan_broadcast_one(nskb, vlan->dev, eth,
+					 mode == MACVLAN_MODE_BRIDGE);
 			macvlan_count_rx(vlan, skb->len + ETH_HLEN,
 					 likely(err == NET_RX_SUCCESS), 1);
 		}
@@ -173,6 +190,7 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 	const struct ethhdr *eth = eth_hdr(skb);
 	const struct macvlan_port *port;
 	const struct macvlan_dev *vlan;
+	const struct macvlan_dev *src;
 	struct net_device *dev;
 
 	port = rcu_dereference(skb->dev->macvlan_port);
@@ -180,7 +198,20 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 		return skb;
 
 	if (is_multicast_ether_addr(eth->h_dest)) {
-		macvlan_broadcast(skb, port);
+		src = macvlan_hash_lookup(port, eth->h_source);
+		if (!src)
+			/* frame comes from an external address */
+			macvlan_broadcast(skb, port, NULL, MACVLAN_MODE_PRIVATE
+				| MACVLAN_MODE_VEPA | MACVLAN_MODE_BRIDGE);
+		else if (src->mode == MACVLAN_MODE_VEPA)
+			/* flood to everyone except source */
+			macvlan_broadcast(skb, port, src->dev,
+				MACVLAN_MODE_VEPA | MACVLAN_MODE_BRIDGE);
+		else if (src->mode == MACVLAN_MODE_BRIDGE)
+			/* flood only to VEPA ports, bridge ports
+			   already saw the frame */
+			macvlan_broadcast(skb, port, src->dev,
+				MACVLAN_MODE_VEPA);
 		return skb;
 	}
 
@@ -203,18 +234,46 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
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
+			int length = skb->len + ETH_HLEN;
+			int ret = dev_forward_skb(dest->dev, skb);
+			macvlan_count_rx(dest, length,
+					 likely(ret == NET_RX_SUCCESS), 0);
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
