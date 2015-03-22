From: Michael Braun <michael-dev@fami-braun.de>
Subject: [PATCH] macvlan: transmit multicast as unicast in source mode
Date: Sun, 22 Mar 2015 13:29:49 +0100
Message-ID: <1427027389-9691-1-git-send-email-michael-dev@fami-braun.de>
Cc: Michael Braun <michael-dev@fami-braun.de>,
	projekt-wlan@fem.tu-ilmenau.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fem.tu-ilmenau.de ([141.24.220.54]:41020 "EHLO
	mail.fem.tu-ilmenau.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbbCVMhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 08:37:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When having multiple remote mac addresses assigned to different macvlan
source devices created on top of the same other netdev, multicast packets
send on one interface will be also received by the remote machines
asssigned to the other macvlan device.

This is because multicast packets are transmitted as layer-2 multicast.
Thought, not all protocols need their multicast packets to be transmitted
as layer-2 multicast, esp. ARP, IPv4 and IPv6. Most importantly, IPv6
router advertisments will be processed even if received as layer-2 unicast.

So this patch adds support for replicating multicast packets and sending
them out as unicast by changing the destination mac address.
This fixes IPv6 autoconf addresses and routes on the remote stations
assigned to different macvlan devices.

There are two new flags: UNICAST and UNICAST_ALL. The first only rewrites
ARP, IPv4 and IPv6 (and their 802.1Q tagged variant), the latter rewrites
all multicast packets.

Signed-off-by: Michael Braun <michael-dev@fami-braun.de>
Cc: netdev@vger.kernel.org
Cc: projekt-wlan@fem.tu-ilmenau.de
---
 drivers/net/macvlan.c        | 86 ++++++++++++++++++++++++++++++++++++++++++--
 include/uapi/linux/if_link.h |  2 ++
 2 files changed, 85 insertions(+), 3 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index b5e3320..f7b375b 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -466,15 +466,52 @@ out:
 	return handle_res;
 }
 
+static void macvlan_xmit_unicast(struct sk_buff *skb, struct net_device *dev,
+				 struct macvlan_source_entry *entry,
+				 int need_clone)
+{
+	struct ethhdr *eth;
+	int err;
+
+	if (need_clone) {
+		skb = skb_clone(skb, GFP_ATOMIC);
+		if (!skb)
+			goto err;
+	}
+	err = skb_cow_clone_head(skb, ETH_HLEN);
+	if (unlikely(err))
+		goto err;
+
+	eth = (void *)skb->data;
+	ether_addr_copy(eth->h_dest, entry->addr);
+
+	skb->dev = dev;
+	dev_queue_xmit(skb);
+	return;
+err:
+	if (need_clone)
+		kfree_skb(skb);
+	else
+		dev_kfree_skb(skb);
+}
+
 static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	const struct macvlan_dev *vlan = netdev_priv(dev);
 	const struct macvlan_port *port = vlan->port;
 	const struct macvlan_dev *dest;
+	int asunicast = 0;
+	int ethertype = 0;
+	int i;
+	struct macvlan_source_entry *entry, *prev = NULL;
+	const struct hlist_head *h;
+	const struct ethhdr *eth = (void *)skb->data;
+	const struct vlan_ethhdr *ethvlan = (void *)skb->data;
 
-	if (vlan->mode == MACVLAN_MODE_BRIDGE) {
-		const struct ethhdr *eth = (void *)skb->data;
+	if (unlikely(skb->len < ETH_HLEN))
+		goto err;
 
+	if (vlan->mode == MACVLAN_MODE_BRIDGE) {
 		/* send to other bridge ports directly */
 		if (is_multicast_ether_addr(eth->h_dest)) {
 			macvlan_broadcast(skb, port, dev, MACVLAN_MODE_BRIDGE);
@@ -490,9 +527,48 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
+	if (vlan->mode != MACVLAN_MODE_SOURCE ||
+	    !is_multicast_ether_addr(eth->h_dest))
+		goto xmit_world;
+
+	if (vlan->flags & MACVLAN_FLAG_UNICAST_ALL) {
+		asunicast = 1;
+	} else if (vlan->flags & MACVLAN_FLAG_UNICAST) {
+		ethertype = ntohs(eth->h_proto);
+		if (ethertype == ETH_P_8021Q && skb->len >= VLAN_ETH_HLEN)
+			ethertype = ntohs(ethvlan->h_vlan_encapsulated_proto);
+		asunicast = (ethertype == ETH_P_ARP  ||
+			     ethertype == ETH_P_IP   ||
+			     ethertype == ETH_P_IPV6);
+	}
+
+	if (!asunicast)
+		goto xmit_world;
+
+	for (i = 0; i < MACVLAN_HASH_SIZE; i++) {
+		h = &port->vlan_source_hash[i];
+		hlist_for_each_entry_rcu(entry, h, hlist) {
+			if (entry->vlan != vlan)
+				continue;
+			if (prev)
+				macvlan_xmit_unicast(skb, vlan->lowerdev,
+						     prev, 1);
+			prev = entry;
+		}
+	}
+	if (prev)
+		macvlan_xmit_unicast(skb, vlan->lowerdev, prev, 0);
+	else
+		/* no source mac configured, so drop */
+		dev_kfree_skb(skb);
+	return NET_XMIT_SUCCESS;
+
 xmit_world:
 	skb->dev = vlan->lowerdev;
 	return dev_queue_xmit(skb);
+err:
+	dev_kfree_skb(skb);
+	return NET_XMIT_SUCCESS;
 }
 
 static inline netdev_tx_t macvlan_netpoll_send_skb(struct macvlan_dev *vlan, struct sk_buff *skb)
@@ -1100,6 +1176,10 @@ static void macvlan_port_destroy(struct net_device *dev)
 
 static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 {
+	const u16 allflags = MACVLAN_FLAG_NOPROMISC |
+			     MACVLAN_FLAG_UNICAST |
+			     MACVLAN_FLAG_UNICAST_ALL;
+
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
 			return -EINVAL;
@@ -1108,7 +1188,7 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	}
 
 	if (data && data[IFLA_MACVLAN_FLAGS] &&
-	    nla_get_u16(data[IFLA_MACVLAN_FLAGS]) & ~MACVLAN_FLAG_NOPROMISC)
+	    nla_get_u16(data[IFLA_MACVLAN_FLAGS]) & ~allflags)
 		return -EINVAL;
 
 	if (data && data[IFLA_MACVLAN_MODE]) {
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 756436e..4ca2030 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -333,6 +333,8 @@ enum macvlan_macaddr_mode {
 };
 
 #define MACVLAN_FLAG_NOPROMISC	1
+#define MACVLAN_FLAG_UNICAST	2
+#define MACVLAN_FLAG_UNICAST_ALL	4
 
 /* IPVLAN section */
 enum {
-- 
1.9.1
