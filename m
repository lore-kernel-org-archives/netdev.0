From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 1/9] Take the distribution range definition out
 of skb_tx_hash()
Date: Mon, 13 Dec 2010 17:43:51 +0200
Message-ID: <1292255031.631.49.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3631 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754090Ab0LMPoC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Dec 2010 10:44:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the calcualation of the Tx hash for a given hash range into a separate
function and define the skb_tx_hash(), which calculates a Tx hash for a
[0; dev->real_num_tx_queues - 1] hash values range, using this
function (__skb_tx_hash()).

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 include/linux/netdevice.h |   10 ++++++++++
 include/linux/skbuff.h    |    5 +++--
 net/core/dev.c            |   15 ++++++++++-----
 3 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d31bc3c..445e682 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1747,6 +1747,16 @@ static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 		__netif_schedule(txq->qdisc);
 }

+/*
+ * Returns a Tx hash for the given packet when dev->real_num_tx_queues is used
+ * as a distribution range limit for the returned value.
+ */
+static inline u16 skb_tx_hash(const struct net_device *dev,
+			      const struct sk_buff *skb)
+{
+	return __skb_tx_hash(dev, skb, dev->real_num_tx_queues);
+}
+
 /**
  *	netif_is_multiqueue - test if device has multiple transmit queues
  *	@dev: network device
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 19f37a6..4c4bec6 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2165,8 +2165,9 @@ static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
 	return skb->queue_mapping != 0;
 }

-extern u16 skb_tx_hash(const struct net_device *dev,
-		       const struct sk_buff *skb);
+extern u16 __skb_tx_hash(const struct net_device *dev,
+			 const struct sk_buff *skb,
+			 unsigned int num_tx_queues);

 #ifdef CONFIG_XFRM
 static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
diff --git a/net/core/dev.c b/net/core/dev.c
index d28b3a0..b25dd08 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2112,14 +2112,19 @@ out:

 static u32 hashrnd __read_mostly;

-u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
+/*
+ * Returns a Tx hash based on the given packet descriptor a Tx queues' number
+ * to be used as a distribution range.
+ */
+u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
+		  unsigned int num_tx_queues)
 {
 	u32 hash;

 	if (skb_rx_queue_recorded(skb)) {
 		hash = skb_get_rx_queue(skb);
-		while (unlikely(hash >= dev->real_num_tx_queues))
-			hash -= dev->real_num_tx_queues;
+		while (unlikely(hash >= num_tx_queues))
+			hash -= num_tx_queues;
 		return hash;
 	}

@@ -2129,9 +2134,9 @@ u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
 		hash = (__force u16) skb->protocol ^ skb->rxhash;
 	hash = jhash_1word(hash, hashrnd);

-	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
+	return (u16) (((u64) hash * num_tx_queues) >> 32);
 }
-EXPORT_SYMBOL(skb_tx_hash);
+EXPORT_SYMBOL(__skb_tx_hash);

 static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
 {
--
1.7.0.4




