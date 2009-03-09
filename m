From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: MACVLANs really best solution? How about a bridge with multiple bridge virtual interfaces? (was Re: [PATCH] macvlan: Support creating macvlans from macvlans)
Date: Mon, 09 Mar 2009 07:56:21 -0700
Message-ID: <m11vt6d9t6.fsf@fess.ebiederm.org>
References: <20090307211527.6e76d0b9.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
	<49B51A42.6050507@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>,
	greearb@candelatech.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, shemminger@linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58553 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbZCIO4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 10:56:30 -0400
In-Reply-To: <49B51A42.6050507@trash.net> (Patrick McHardy's message of "Mon\, 09 Mar 2009 14\:31\:46 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

> I agree on most points. There is one fundamental operational difference
> however. With macvlan, all MAC addresses are known are therefore can be
> programmed as secondary unicast addresses, while a bridge always uses
> promiscous mode and for unknown addresses needs to flood forward them.
>
> This could be changed in the bridging code of course for bridges
> consisting purely of local devices. Most of the bridging stuff isn't
> needed for macvlans though, so its probably easier to simply perform
> a lookup for local devices in macvlan on transmit, similar to what
> is done on reception.

What I haven't figured out is how you handle the transmit path for
broadcast and multicast ethernet traffic.  How do you test to see if
you have already preformed local transmission?

For discussion but not for application because it is incomplete:
This is what I came up with when I played with getting the local
transmission case working the other day.


>From 15e4a58ae0cea86338ef9d73ae14ba32e4819f5a Mon Sep 17 00:00:00 2001
From: Eric Biederman <ebiederm@xmission.com>
Date: Thu, 5 Mar 2009 07:46:10 -0800
Subject: [PATCH] macvlan: Reflect macvlan packets meant for other macvlan devices

Switch ports do not send packets back out the same port they came
in on.  This causes problems when using a macvlan device inside
of a network namespace as it becomes impossible to talk to
other macvlan devices.

Signed-off-by: Eric Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/macvlan.c |   92 ++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 68 insertions(+), 24 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index b5241fc..eb2539f 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -29,6 +29,7 @@
 #include <linux/if_link.h>
 #include <linux/if_macvlan.h>
 #include <net/rtnetlink.h>
+#include <net/xfrm.h>
 
 #define MACVLAN_HASH_SIZE	(1 << BITS_PER_BYTE)
 
@@ -61,7 +62,8 @@ static struct macvlan_dev *macvlan_hash_lookup(const struct macvlan_port *port,
 }
 
 static void macvlan_broadcast(struct sk_buff *skb,
-			      const struct macvlan_port *port)
+			      const struct macvlan_port *port,
+			      struct net_device *src)
 {
 	const struct ethhdr *eth = eth_hdr(skb);
 	const struct macvlan_dev *vlan;
@@ -77,6 +79,9 @@ static void macvlan_broadcast(struct sk_buff *skb,
 		hlist_for_each_entry_rcu(vlan, n, &port->vlan_hash[i], hlist) {
 			dev = vlan->dev;
 
+			if (dev == src)
+				continue;
+
 			nskb = skb_clone(skb, GFP_ATOMIC);
 			if (nskb == NULL) {
 				dev->stats.rx_errors++;
@@ -99,20 +104,45 @@ static void macvlan_broadcast(struct sk_buff *skb,
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
 
@@ -120,38 +150,52 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
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
+	dst_release(skb->dst);
+	skb->dst = NULL;
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
 
 static int macvlan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	const struct macvlan_dev *vlan = netdev_priv(dev);
 	unsigned int len = skb->len;
 	int ret;
 
-	skb->dev = vlan->lowerdev;
-	ret = dev_queue_xmit(skb);
-
+	ret = macvlan_queue_xmit(skb, dev);
 	if (likely(ret == NET_XMIT_SUCCESS)) {
 		dev->stats.tx_packets++;
 		dev->stats.tx_bytes += len;
-- 
1.6.1.2.350.g88cc

