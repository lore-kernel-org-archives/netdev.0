From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2 2/2] net: initialize hashrnd in flow_dissector with net_get_random_once
Date: Wed, 23 Oct 2013 20:06:00 +0200
Message-ID: <20131023180600.GD2403@order.stressinduktion.org>
References: <20131023111219.GA31531@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53334 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208Ab3JWSGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 14:06:01 -0400
Content-Disposition: inline
In-Reply-To: <20131023111219.GA31531@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We also can defer the initialization of hashrnd in flow_dissector
to its first use. Since net_get_random_once is irq safe now we don't
have to audit the call paths if one of this functions get called by an
interrupt handler.

Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2: Reword the commit message only. It looked horribly.

 net/core/flow_dissector.c | 34 +++++++++++++++++++++-------------
 1 file changed, 21 insertions(+), 13 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index f8e25ac..5cac36e 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -184,6 +184,22 @@ ipv6:
 EXPORT_SYMBOL(skb_flow_dissect);
 
 static u32 hashrnd __read_mostly;
+static __always_inline void __flow_hash_secret_init(void)
+{
+	net_get_random_once(&hashrnd, sizeof(hashrnd));
+}
+
+static __always_inline u32 __flow_hash_3words(u32 a, u32 b, u32 c)
+{
+	__flow_hash_secret_init();
+	return jhash_3words(a, b, c, hashrnd);
+}
+
+static __always_inline u32 __flow_hash_1word(u32 a)
+{
+	__flow_hash_secret_init();
+	return jhash_1word(a, hashrnd);
+}
 
 /*
  * __skb_get_rxhash: calculate a flow hash based on src/dst addresses
@@ -210,9 +226,9 @@ void __skb_get_rxhash(struct sk_buff *skb)
 		swap(keys.port16[0], keys.port16[1]);
 	}
 
-	hash = jhash_3words((__force u32)keys.dst,
-			    (__force u32)keys.src,
-			    (__force u32)keys.ports, hashrnd);
+	hash = __flow_hash_3words((__force u32)keys.dst,
+				  (__force u32)keys.src,
+				  (__force u32)keys.ports);
 	if (!hash)
 		hash = 1;
 
@@ -248,7 +264,7 @@ u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
 		hash = skb->sk->sk_hash;
 	else
 		hash = (__force u16) skb->protocol;
-	hash = jhash_1word(hash, hashrnd);
+	hash = __flow_hash_1word(hash);
 
 	return (u16) (((u64) hash * qcount) >> 32) + qoffset;
 }
@@ -340,7 +356,7 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 				else
 					hash = (__force u16) skb->protocol ^
 					    skb->rxhash;
-				hash = jhash_1word(hash, hashrnd);
+				hash = __flow_hash_1word(hash);
 				queue_index = map->queues[
 				    ((u64)hash * map->len) >> 32];
 			}
@@ -395,11 +411,3 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 	skb_set_queue_mapping(skb, queue_index);
 	return netdev_get_tx_queue(dev, queue_index);
 }
-
-static int __init initialize_hashrnd(void)
-{
-	get_random_bytes(&hashrnd, sizeof(hashrnd));
-	return 0;
-}
-
-late_initcall_sync(initialize_hashrnd);
-- 
1.8.3.1
