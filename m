From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make simple TX hash little endian safe.
Date: Mon, 21 Jul 2008 09:44:33 -0700 (PDT)
Message-ID: <20080721.094433.235903960.davem@davemloft.net>
References: <1216630088-10328-1-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47627
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750996AbYGUQod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:44:33 -0400
In-Reply-To: <1216630088-10328-1-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon, 21 Jul 2008 10:48:07 +0200

> Currently it will not use the lower
> bits at all on big endian system, mapping e.g. all connections to a single
> queue on a local network which only differs in the low bits.
> 
> Also fold the upper 16 bits always in the lower 16bits.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

I plan to make this use jhash plus a reciprocol multiply
to fix the hash effectiveness as well as get rid of the
modulus and make the hash not attackable.

Something like the patch below.

Thanks.

diff --git a/net/core/dev.c b/net/core/dev.c
index 2eed17b..7e2d527 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -124,6 +124,8 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/in.h>
+#include <linux/jhash.h>
+#include <linux/random.h>
 
 #include "net-sysfs.h"
 
@@ -1668,34 +1670,37 @@ out_kfree_skb:
  *          --BLG
  */
 
+static u32 simple_tx_hashrnd;
+static int simple_tx_hashrnd_initialized = 0;
+
 static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
 {
-	u32 *addr, *ports, hash, ihl;
+	u32 addr1, addr2, ports;
+	u32 hash, ihl;
 	u8 ip_proto;
-	int alen;
+
+	if (unlikely(!simple_tx_hashrnd_initialized)) {
+		get_random_bytes(&simple_tx_hashrnd, 4);
+		simple_tx_hashrnd_initialized = 1;
+	}
 
 	switch (skb->protocol) {
 	case __constant_htons(ETH_P_IP):
 		ip_proto = ip_hdr(skb)->protocol;
-		addr = &ip_hdr(skb)->saddr;
+		addr1 = ip_hdr(skb)->saddr;
+		addr2 = ip_hdr(skb)->daddr;
 		ihl = ip_hdr(skb)->ihl;
-		alen = 2;
 		break;
 	case __constant_htons(ETH_P_IPV6):
 		ip_proto = ipv6_hdr(skb)->nexthdr;
-		addr = &ipv6_hdr(skb)->saddr.s6_addr32[0];
+		addr1 = ipv6_hdr(skb)->saddr.s6_addr32[3];
+		addr2 = ipv6_hdr(skb)->daddr.s6_addr32[3];
 		ihl = (40 >> 2);
-		alen = 8;
 		break;
 	default:
 		return 0;
 	}
 
-	ports = (u32 *) (skb_network_header(skb) + (ihl * 4));
-
-	hash = 0;
-	while (alen--)
-		hash ^= *addr++;
 
 	switch (ip_proto) {
 	case IPPROTO_TCP:
@@ -1705,14 +1710,17 @@ static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
 	case IPPROTO_AH:
 	case IPPROTO_SCTP:
 	case IPPROTO_UDPLITE:
-		hash ^= *ports;
+		ports = *((u32 *) (skb_network_header(skb) + (ihl * 4)));
 		break;
 
 	default:
+		ports = 0;
 		break;
 	}
 
-	return hash % dev->real_num_tx_queues;
+	hash = jhash_3words(addr1, addr2, ports, simple_tx_hashrnd);
+
+	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
 }
 
 static struct netdev_queue *dev_pick_tx(struct net_device *dev,
