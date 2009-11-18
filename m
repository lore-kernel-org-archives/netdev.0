From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/3] macvlan: Reflect macvlan packets meant for other macvlan devices
Date: Wed, 18 Nov 2009 23:32:56 +0000
Message-ID: <200911182332.56309.arnd@arndb.de>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de> <200911181047.07974.arnd@arndb.de> <m1pr7fdhkx.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Patrick Mullaney <pmullaney@novell.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@linux-foundation.com,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757662AbZKRXd5@vger.kernel.org>
In-Reply-To: <m1pr7fdhkx.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 18 November 2009 14:37:50 Eric W. Biederman wrote:
> Arnd Bergmann <arnd@arndb.de> writes:
> > On Wednesday 18 November 2009, Eric Dumazet wrote:
> >> 
> >> Why do you drop dst here ?
> >> 
> >> It seems strange, since this driver specifically masks out IFF_XMIT_DST_RELEASE
> >> in its macvlan_setup() :
> >> 
> >> dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;

It seems that we should never drop dst then. We either forward the frame to
netif_rx or to dev_queue_xmit, and from how I read it now, we want to keep
the dst in both cases.

> Please copy and ideally share code with the veth driver for recycling a skb.
> There are bunch of little things you have to do to get it right.  As I recally
> I was missing a few details in my original patch.

Are you thinking of something like the patch below? I haven't had the chance
to test this, but one thing it does is to handle the internal forwarding
differently from the receive path.

	Arnd <><

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 731017e..73f8cb1 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -114,6 +114,7 @@ static void macvlan_broadcast(struct sk_buff *skb,
 	struct net_device *dev;
 	struct sk_buff *nskb;
 	unsigned int i;
+	int err;
 
 	if (skb->protocol == htons(ETH_P_PAUSE))
 		return;
@@ -135,47 +136,28 @@ static void macvlan_broadcast(struct sk_buff *skb,
 				continue;
 			}
 
-			dev->stats.rx_bytes += skb->len + ETH_HLEN;
-			dev->stats.rx_packets++;
-			dev->stats.multicast++;
-
-			nskb->dev = dev;
-			if (!compare_ether_addr_64bits(eth->h_dest, dev->broadcast))
-				nskb->pkt_type = PACKET_BROADCAST;
-			else
-				nskb->pkt_type = PACKET_MULTICAST;
-
-			netif_rx(nskb);
+			if (mode == MACVLAN_MODE_BRIDGE) {
+				err = (dev_forward_skb(dev, nskb) < 0);
+			} else {
+				nskb->dev = dev;
+				if (!compare_ether_addr_64bits(eth->h_dest,
+							       dev->broadcast))
+					nskb->pkt_type = PACKET_BROADCAST;
+				else
+					nskb->pkt_type = PACKET_MULTICAST;
+				err = (netif_rx(nskb) != NET_RX_SUCCESS);
+			}
+			if (err) {
+				dev->stats.rx_dropped++;
+			} else {
+				dev->stats.rx_bytes += skb->len + ETH_HLEN;
+				dev->stats.rx_packets++;
+				dev->stats.multicast++;
+			}
 		}
 	}
 }
 
-static int macvlan_unicast(struct sk_buff *skb, const struct macvlan_dev *dest)
-{
-	struct net_device *dev = dest->dev;
-
-	if (unlikely(!dev->flags & IFF_UP)) {
-		kfree_skb(skb);
-		return NET_XMIT_DROP;
-	}
-
-	skb = skb_share_check(skb, GFP_ATOMIC);
-	if (!skb) {
-		dev->stats.rx_errors++;
-		dev->stats.rx_dropped++;
-		return NET_XMIT_DROP;
-	}
-
-	dev->stats.rx_bytes += skb->len + ETH_HLEN;
-	dev->stats.rx_packets++;
-
-	skb->dev = dev;
-	skb->pkt_type = PACKET_HOST;
-	netif_rx(skb);
-	return NET_XMIT_SUCCESS;
-}
-
-
 /* called under rcu_read_lock() from netif_receive_skb */
 static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 {
@@ -183,6 +165,7 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 	const struct macvlan_port *port;
 	const struct macvlan_dev *vlan;
 	const struct macvlan_dev *src;
+	struct net_device *dev;
 
 	port = rcu_dereference(skb->dev->macvlan_port);
 	if (port == NULL)
@@ -192,7 +175,7 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 		src = macvlan_hash_lookup(port, eth->h_source);
 		if (!src)
 			/* frame comes from an external address */
-			macvlan_broadcast(skb, port, NULL, MACVLAN_MODE_VEPA
+			macvlan_broadcast(skb, port, NULL, MACVLAN_MODE_PRIVATE
 				| MACVLAN_MODE_VEPA | MACVLAN_MODE_BRIDGE);
 		else if (src->mode == MACVLAN_MODE_VEPA)
 			/* flood to everyone except source */
@@ -210,7 +193,26 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 	if (vlan == NULL)
 		return skb;
 
-	macvlan_unicast(skb, vlan);
+	dev = vlan->dev;
+	if (unlikely(!(dev->flags & IFF_UP))) {
+		kfree_skb(skb);
+		return NULL;
+	}
+
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (!skb) {
+		dev->stats.rx_errors++;
+		dev->stats.rx_dropped++;
+		return NULL;
+	}
+
+	dev->stats.rx_bytes += skb->len + ETH_HLEN;
+	dev->stats.rx_packets++;
+	
+	skb->dev = dev;
+	skb->pkt_type = PACKET_HOST;
+	
+	netif_rx(skb);
 	return NULL;
 }
 
@@ -227,17 +229,12 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	const struct macvlan_dev *vlan = netdev_priv(dev);
 	const struct macvlan_port *port = vlan->port;
 	const struct macvlan_dev *dest;
-	const struct ethhdr *eth;
 
 	skb->protocol = eth_type_trans(skb, dev);
-	eth = eth_hdr(skb);
-
-	skb_dst_drop(skb);
-	skb->mark = 0;
-	secpath_reset(skb);
-	nf_reset(skb);
 
 	if (vlan->mode == MACVLAN_MODE_BRIDGE) {
+		const struct ethhdr *eth = eth_hdr(skb);
+
 		/* send to other bridge ports directly */
 		if (is_multicast_ether_addr(eth->h_dest)) {
 			macvlan_broadcast(skb, port, dev, MACVLAN_MODE_BRIDGE);
@@ -245,8 +242,17 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 
 		dest = macvlan_hash_lookup(port, eth->h_dest);
-		if (dest && dest->mode == MACVLAN_MODE_BRIDGE)
-			return macvlan_unicast(skb, dest);
+		if (dest && dest->mode == MACVLAN_MODE_BRIDGE) {
+			int length = dev_forward_skb(dest->dev, skb);
+			if (length < 0) {
+				dev->stats.rx_dropped++;
+			} else {
+				dev->stats.rx_bytes += length;
+				dev->stats.rx_packets++;
+			}
+
+			return NET_XMIT_SUCCESS;
+		}
 	}
 
 	return macvlan_xmit_world(skb, dev);
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index ade5b34..5bb7fb9 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -155,8 +155,6 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct veth_net_stats *stats, *rcv_stats;
 	int length, cpu;
 
-	skb_orphan(skb);
-
 	priv = netdev_priv(dev);
 	rcv = priv->peer;
 	rcv_priv = netdev_priv(rcv);
@@ -165,23 +163,13 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	stats = per_cpu_ptr(priv->stats, cpu);
 	rcv_stats = per_cpu_ptr(rcv_priv->stats, cpu);
 
-	if (!(rcv->flags & IFF_UP))
-		goto tx_drop;
-
-	if (skb->len > (rcv->mtu + MTU_PAD))
-		goto rx_drop;
-
-        skb->tstamp.tv64 = 0;
-	skb->pkt_type = PACKET_HOST;
-	skb->protocol = eth_type_trans(skb, rcv);
 	if (dev->features & NETIF_F_NO_CSUM)
 		skb->ip_summed = rcv_priv->ip_summed;
+	
+	length = dev_forward_skb(rcv, skb);
 
-	skb->mark = 0;
-	secpath_reset(skb);
-	nf_reset(skb);
-
-	length = skb->len;
+	if (length < 0)
+		goto drop;
 
 	stats->tx_bytes += length;
 	stats->tx_packets++;
@@ -189,17 +177,14 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	rcv_stats->rx_bytes += length;
 	rcv_stats->rx_packets++;
 
-	netif_rx(skb);
 	return NETDEV_TX_OK;
 
-tx_drop:
+drop:
 	kfree_skb(skb);
-	stats->tx_dropped++;
-	return NETDEV_TX_OK;
-
-rx_drop:
-	kfree_skb(skb);
-	rcv_stats->rx_dropped++;
+	if (length == -ENETDOWN)
+		stats->tx_dropped++;
+	else
+		rcv_stats->rx_dropped++;
 	return NETDEV_TX_OK;
 }
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 812a5f3..90225d6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1502,6 +1502,7 @@ extern int		dev_set_mac_address(struct net_device *,
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev,
 					    struct netdev_queue *txq);
+extern int		dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 
 extern int		netdev_budget;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index b8f74cf..ca89b81 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -104,6 +104,7 @@
 #include <net/dst.h>
 #include <net/pkt_sched.h>
 #include <net/checksum.h>
+#include <net/xfrm.h>
 #include <linux/highmem.h>
 #include <linux/init.h>
 #include <linux/kmod.h>
@@ -1352,6 +1353,42 @@ static inline void net_timestamp(struct sk_buff *skb)
 		skb->tstamp.tv64 = 0;
 }
 
+/**
+ * dev_forward_skb - loopback an skb to another netif
+ *
+ * @dev: destination network device
+ * @skb: buffer to forward
+ *
+ * dev_forward_skb can be used for injecting an skb from the
+ * start_xmit function of one device into the receive queue
+ * of another device.
+ */
+int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
+{
+	int sent;
+
+	skb_orphan(skb);
+
+	if (!(dev->flags & IFF_UP))
+		return -ENETDOWN;
+
+	if (skb->len > (dev->mtu + dev->hard_header_len))
+		return -EMSGSIZE;
+
+	skb->tstamp.tv64 = 0;
+	skb->pkt_type = PACKET_HOST;
+	skb->protocol = eth_type_trans(skb, dev);
+	skb->mark = 0;
+	secpath_reset(skb);
+	nf_reset(skb);
+	sent = skb->len;
+	if (netif_rx(skb) == NET_RX_DROP)
+		return -EBUSY;
+
+	return sent;
+}
+EXPORT_SYMBOL_GPL(dev_forward_skb);
+
 /*
  *	Support routine. Sends outgoing frames to any network
  *	taps currently in use.
