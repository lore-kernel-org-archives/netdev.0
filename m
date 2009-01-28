From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/4]: net: Allow RX queue selection to seed TX queue
 hashing.
Date: Tue, 27 Jan 2009 16:40:27 -0800 (PST)
Message-ID: <20090127.164027.245779962.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43817
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751545AbZA1Ak3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 19:40:29 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 37F8735C003
	for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 16:40:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The idea is that drivers which implement multiqueue RX
pre-seed the SKB by recording the RX queue selected by
the hardware.

If such a seed is found on TX, we'll use that to select
the outgoing TX queue.

This helps get more consistent load balancing on router
and firewall loads.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |   15 +++++++++++++++
 net/core/dev.c         |    8 ++++++++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index cf2cb50..a2c2378 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1904,6 +1904,21 @@ static inline void skb_copy_queue_mapping(struct sk_buff *to, const struct sk_bu
 	to->queue_mapping = from->queue_mapping;
 }
 
+static inline void skb_record_rx_queue(struct sk_buff *skb, u16 rx_queue)
+{
+	skb->queue_mapping = rx_queue + 1;
+}
+
+static inline u16 skb_get_rx_queue(struct sk_buff *skb)
+{
+	return skb->queue_mapping - 1;
+}
+
+static inline bool skb_rx_queue_recorded(struct sk_buff *skb)
+{
+	return (skb->queue_mapping != 0);
+}
+
 #ifdef CONFIG_XFRM
 static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index 5379b0c..b21ad0b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1722,6 +1722,13 @@ static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
 		simple_tx_hashrnd_initialized = 1;
 	}
 
+	if (skb_rx_queue_recorded(skb)) {
+		u32 val = skb_get_rx_queue(skb);
+
+		hash = jhash_1word(val, simple_tx_hashrnd);
+		goto out;
+	}
+
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
 		if (!(ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)))
@@ -1759,6 +1766,7 @@ static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
 
 	hash = jhash_3words(addr1, addr2, ports, simple_tx_hashrnd);
 
+out:
 	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
 }
 
-- 
1.6.1.15.g159c88

