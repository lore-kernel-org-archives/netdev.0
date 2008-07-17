From: David Miller <davem@davemloft.net>
Subject: [PATCH 11/31]: net: Implement simple sw TX hashing.
Date: Thu, 17 Jul 2008 05:16:35 -0700 (PDT)
Message-ID: <20080717.051635.124264554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51642
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758779AbYGQMQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 08:16:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It just xor hashes over IPv4/IPv6 addresses and ports of transport.

The only assumption it makes is that skb_network_header() is set
correctly.

With bug fixes from Eric Dumazet.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7ca9564..467bfb3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -121,6 +121,9 @@
 #include <linux/ctype.h>
 #include <linux/if_arp.h>
 #include <linux/if_vlan.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/in.h>
 
 #include "net-sysfs.h"
 
@@ -1665,6 +1668,53 @@ out_kfree_skb:
  *          --BLG
  */
 
+static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
+{
+	u32 *addr, *ports, hash, ihl;
+	u8 ip_proto;
+	int alen;
+
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_IP):
+		ip_proto = ip_hdr(skb)->protocol;
+		addr = &ip_hdr(skb)->saddr;
+		ihl = ip_hdr(skb)->ihl;
+		alen = 2;
+		break;
+	case __constant_htons(ETH_P_IPV6):
+		ip_proto = ipv6_hdr(skb)->nexthdr;
+		addr = &ipv6_hdr(skb)->saddr.s6_addr32[0];
+		ihl = (40 >> 2);
+		alen = 8;
+		break;
+	default:
+		return 0;
+	}
+
+	ports = (u32 *) (skb_network_header(skb) + (ihl * 4));
+
+	hash = 0;
+	while (alen--)
+		hash ^= *addr++;
+
+	switch (ip_proto) {
+	case IPPROTO_TCP:
+	case IPPROTO_UDP:
+	case IPPROTO_DCCP:
+	case IPPROTO_ESP:
+	case IPPROTO_AH:
+	case IPPROTO_SCTP:
+	case IPPROTO_UDPLITE:
+		hash ^= *ports;
+		break;
+
+	default:
+		break;
+	}
+
+	return hash % dev->real_num_tx_queues;
+}
+
 static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					struct sk_buff *skb)
 {
@@ -1672,6 +1722,8 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 
 	if (dev->select_queue)
 		queue_index = dev->select_queue(dev, skb);
+	else if (dev->real_num_tx_queues > 1)
+		queue_index = simple_tx_hash(dev, skb);
 
 	skb_set_queue_mapping(skb, queue_index);
 	return netdev_get_tx_queue(dev, queue_index);
-- 
1.5.6.2.255.gbed62

