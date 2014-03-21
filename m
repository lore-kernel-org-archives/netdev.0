From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 2/4] net: use skb_get_hash in tx queue selection
Date: Thu, 20 Mar 2014 17:09:13 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1403201701500.7187@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:36242 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965612AbaCUAQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 20:16:22 -0400
Received: by mail-qa0-f73.google.com with SMTP id f11so204268qae.4
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 17:16:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__skb_get_hash tries to get the skb->hash from a connected socket
associated with an skb. __skb_tx_hash and get_xps_queue just call
skb_get_hash().

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |  2 +-
 include/linux/skbuff.h    |  2 +-
 net/core/flow_dissector.c | 22 +++++++++-------------
 3 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4b6d12c..a1fa2e4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2481,7 +2481,7 @@ static inline int netif_set_xps_queue(struct net_device *dev,
  * as a distribution range limit for the returned value.
  */
 static inline u16 skb_tx_hash(const struct net_device *dev,
-			      const struct sk_buff *skb)
+			      struct sk_buff *skb)
 {
 	return __skb_tx_hash(dev, skb, dev->real_num_tx_queues);
 }
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index aa2c22c..f392b74 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2863,7 +2863,7 @@ static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
 	return skb->queue_mapping != 0;
 }
 
-u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
+u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
 		  unsigned int num_tx_queues);
 
 static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 107ed12..432d35a 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -212,6 +212,12 @@ void __skb_get_hash(struct sk_buff *skb)
 	struct flow_keys keys;
 	u32 hash;
 
+	if (skb->sk && skb->sk->sk_hash) {
+		skb->hash = skb->sk->sk_hash;
+		skb->l4_hash = 1;
+		return;
+	}
+
 	if (!skb_flow_dissect(skb, &keys))
 		return;
 
@@ -240,7 +246,7 @@ EXPORT_SYMBOL(__skb_get_hash);
  * Returns a Tx hash based on the given packet descriptor a Tx queues' number
  * to be used as a distribution range.
  */
-u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
+u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
 		  unsigned int num_tx_queues)
 {
 	u32 hash;
@@ -260,11 +266,7 @@ u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
 		qcount = dev->tc_to_txq[tc].count;
 	}
 
-	if (skb->sk && skb->sk->sk_hash)
-		hash = skb->sk->sk_hash;
-	else
-		hash = (__force u16) skb->protocol;
-	hash = __flow_hash_1word(hash);
+	hash = __flow_hash_1word(skb_get_hash(skb));
 
 	return (u16) (((u64) hash * qcount) >> 32) + qoffset;
 }
@@ -339,13 +341,7 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 			if (map->len == 1)
 				queue_index = map->queues[0];
 			else {
-				u32 hash;
-				if (skb->sk && skb->sk->sk_hash)
-					hash = skb->sk->sk_hash;
-				else
-					hash = (__force u16) skb->protocol ^
-					    skb->hash;
-				hash = __flow_hash_1word(hash);
+				u32 hash = __flow_hash_1word(skb_get_hash(skb));
 				queue_index = map->queues[
 				    ((u64)hash * map->len) >> 32];
 			}
-- 
1.9.1.423.g4596e3a
