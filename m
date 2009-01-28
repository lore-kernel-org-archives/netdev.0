From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/4]: net: Get rid of by-hand TX queue hashing.
Date: Tue, 27 Jan 2009 16:40:36 -0800 (PST)
Message-ID: <20090127.164036.174928428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43823
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751761AbZA1Aki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 19:40:38 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2FF9135C003
	for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 16:40:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We now only TX hash on pre-computed SKB properties.

The thinking is:

1) High performance routing and firewalling setups will
   have a multiqueue capable card used for receive, and
   therefore would have RX queue recordings made into
   the SKB which can be used for the TX side hash.

2) Locally generated packets will have an attached socket
   and thus a valid sk->sk_hash to make use of.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c |   73 ++++++++++---------------------------------------------
 1 files changed, 14 insertions(+), 59 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index cb8caa9..e61b95c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1708,72 +1708,27 @@ out_kfree_skb:
 	return 0;
 }
 
-static u32 simple_tx_hashrnd;
-static int simple_tx_hashrnd_initialized = 0;
+static u32 skb_tx_hashrnd;
+static int skb_tx_hashrnd_initialized = 0;
 
-static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
+static u16 skb_tx_hash(struct net_device *dev, struct sk_buff *skb)
 {
-	u32 addr1, addr2, ports;
-	u32 hash, ihl;
-	u8 ip_proto = 0;
+	u32 hash;
 
-	if (unlikely(!simple_tx_hashrnd_initialized)) {
-		get_random_bytes(&simple_tx_hashrnd, 4);
-		simple_tx_hashrnd_initialized = 1;
+	if (unlikely(!skb_tx_hashrnd_initialized)) {
+		get_random_bytes(&skb_tx_hashrnd, 4);
+		skb_tx_hashrnd_initialized = 1;
 	}
 
 	if (skb_rx_queue_recorded(skb)) {
-		u32 val = skb_get_rx_queue(skb);
-
-		hash = jhash_1word(val, simple_tx_hashrnd);
-		goto out;
-	}
-
-	if (skb->sk && skb->sk->sk_hash) {
-		u32 val = skb->sk->sk_hash;
-
-		hash = jhash_1word(val, simple_tx_hashrnd);
-		goto out;
-	}
-
-	switch (skb->protocol) {
-	case htons(ETH_P_IP):
-		if (!(ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)))
-			ip_proto = ip_hdr(skb)->protocol;
-		addr1 = ip_hdr(skb)->saddr;
-		addr2 = ip_hdr(skb)->daddr;
-		ihl = ip_hdr(skb)->ihl;
-		break;
-	case htons(ETH_P_IPV6):
-		ip_proto = ipv6_hdr(skb)->nexthdr;
-		addr1 = ipv6_hdr(skb)->saddr.s6_addr32[3];
-		addr2 = ipv6_hdr(skb)->daddr.s6_addr32[3];
-		ihl = (40 >> 2);
-		break;
-	default:
-		return 0;
-	}
-
-
-	switch (ip_proto) {
-	case IPPROTO_TCP:
-	case IPPROTO_UDP:
-	case IPPROTO_DCCP:
-	case IPPROTO_ESP:
-	case IPPROTO_AH:
-	case IPPROTO_SCTP:
-	case IPPROTO_UDPLITE:
-		ports = *((u32 *) (skb_network_header(skb) + (ihl * 4)));
-		break;
-
-	default:
-		ports = 0;
-		break;
-	}
+		hash = skb_get_rx_queue(skb);
+	} else if (skb->sk && skb->sk->sk_hash) {
+		hash = skb->sk->sk_hash;
+	} else
+		hash = skb->protocol;
 
-	hash = jhash_3words(addr1, addr2, ports, simple_tx_hashrnd);
+	hash = jhash_1word(hash, skb_tx_hashrnd);
 
-out:
 	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
 }
 
@@ -1786,7 +1741,7 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 	if (ops->ndo_select_queue)
 		queue_index = ops->ndo_select_queue(dev, skb);
 	else if (dev->real_num_tx_queues > 1)
-		queue_index = simple_tx_hash(dev, skb);
+		queue_index = skb_tx_hash(dev, skb);
 
 	skb_set_queue_mapping(skb, queue_index);
 	return netdev_get_tx_queue(dev, queue_index);
-- 
1.6.1.15.g159c88

