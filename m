From: Tom Herbert <therbert@google.com>
Subject: [PATCH 3/8] net: Call skb_get_hash in get_xps_queue and
 __skb_tx_hash
Date: Tue, 1 Jul 2014 21:32:27 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407012057580.23523@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:35595 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982AbaGBEc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:32:28 -0400
Received: by mail-pd0-f202.google.com with SMTP id r10so1766234pdi.1
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:32:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call standard function to get a packet hash instead of taking this from
skb->sk->sk_hash or only using skb->protocol.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |  2 +-
 include/linux/skbuff.h    |  2 +-
 net/core/flow_dissector.c | 29 +++++------------------------
 3 files changed, 7 insertions(+), 26 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 66f9a04..8b43a28 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2486,7 +2486,7 @@ static inline int netif_set_xps_queue(struct net_device *dev,
  * as a distribution range limit for the returned value.
  */
 static inline u16 skb_tx_hash(const struct net_device *dev,
-			      const struct sk_buff *skb)
+			      struct sk_buff *skb)
 {
 	return __skb_tx_hash(dev, skb, dev->real_num_tx_queues);
 }
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ec89301..b297af7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3005,7 +3005,7 @@ static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
 	return skb->queue_mapping != 0;
 }
 
-u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
+u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
 		  unsigned int num_tx_queues);
 
 static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 2ff8cd4..62d1cb6 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -196,12 +196,6 @@ static __always_inline u32 __flow_hash_3words(u32 a, u32 b, u32 c)
 	return jhash_3words(a, b, c, hashrnd);
 }
 
-static __always_inline u32 __flow_hash_1word(u32 a)
-{
-	__flow_hash_secret_init();
-	return jhash_1word(a, hashrnd);
-}
-
 static inline u32 __flow_hash_from_keys(struct flow_keys *keys)
 {
 	u32 hash;
@@ -253,7 +247,7 @@ EXPORT_SYMBOL(__skb_get_hash);
  * Returns a Tx hash based on the given packet descriptor a Tx queues' number
  * to be used as a distribution range.
  */
-u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
+u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
 		  unsigned int num_tx_queues)
 {
 	u32 hash;
@@ -273,13 +267,7 @@ u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
 		qcount = dev->tc_to_txq[tc].count;
 	}
 
-	if (skb->sk && skb->sk->sk_hash)
-		hash = skb->sk->sk_hash;
-	else
-		hash = (__force u16) skb->protocol;
-	hash = __flow_hash_1word(hash);
-
-	return (u16) (((u64) hash * qcount) >> 32) + qoffset;
+	return (u16) (((u64)skb_get_hash(skb) * qcount) >> 32) + qoffset;
 }
 EXPORT_SYMBOL(__skb_tx_hash);
 
@@ -351,17 +339,10 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 		if (map) {
 			if (map->len == 1)
 				queue_index = map->queues[0];
-			else {
-				u32 hash;
-				if (skb->sk && skb->sk->sk_hash)
-					hash = skb->sk->sk_hash;
-				else
-					hash = (__force u16) skb->protocol ^
-					    skb->hash;
-				hash = __flow_hash_1word(hash);
+			else
 				queue_index = map->queues[
-				    ((u64)hash * map->len) >> 32];
-			}
+				    ((u64)skb_get_hash(skb) * map->len) >> 32];
+
 			if (unlikely(queue_index >= dev->real_num_tx_queues))
 				queue_index = -1;
 		}
-- 
2.0.0.526.g5318336
