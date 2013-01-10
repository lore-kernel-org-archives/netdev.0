From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH v2 01/10] net: Split core bits of netdev_pick_tx into
 __netdev_pick_tx
Date: Thu, 10 Jan 2013 10:56:51 -0800
Message-ID: <20130110185609.29578.40711.stgit@ahduyck-cp1.jf.intel.com>
References: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, therbert@google.com, ycai@google.com,
	eric.dumazet@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:28193 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752513Ab3AJS60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 13:58:26 -0500
In-Reply-To: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change splits the core bits of netdev_pick_tx into a separate function.
The main idea behind this is to make this code accessible to select queue
functions when they decide to process the standard path instead of their
own custom path in their select queue routine.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   57 +++++++++++++++++++++++++--------------------
 2 files changed, 33 insertions(+), 25 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0209ac3..608c3ac 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1403,6 +1403,7 @@ static inline void netdev_for_each_tx_queue(struct net_device *dev,
 
 extern struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 					   struct sk_buff *skb);
+extern u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb);
 
 /*
  * Net namespace inlines
diff --git a/net/core/dev.c b/net/core/dev.c
index 594830e..04f04e0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2495,37 +2495,44 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 #endif
 }
 
-struct netdev_queue *netdev_pick_tx(struct net_device *dev,
-				    struct sk_buff *skb)
+u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
 {
-	int queue_index;
-	const struct net_device_ops *ops = dev->netdev_ops;
-
-	if (dev->real_num_tx_queues == 1)
-		queue_index = 0;
-	else if (ops->ndo_select_queue) {
-		queue_index = ops->ndo_select_queue(dev, skb);
-		queue_index = dev_cap_txqueue(dev, queue_index);
-	} else {
-		struct sock *sk = skb->sk;
-		queue_index = sk_tx_queue_get(sk);
+	struct sock *sk = skb->sk;
+	int queue_index = sk_tx_queue_get(sk);
 
-		if (queue_index < 0 || skb->ooo_okay ||
-		    queue_index >= dev->real_num_tx_queues) {
-			int old_index = queue_index;
+	if (queue_index < 0 || skb->ooo_okay ||
+	    queue_index >= dev->real_num_tx_queues) {
+		int new_index = get_xps_queue(dev, skb);
+		if (new_index < 0)
+			new_index = skb_tx_hash(dev, skb);
 
-			queue_index = get_xps_queue(dev, skb);
-			if (queue_index < 0)
-				queue_index = skb_tx_hash(dev, skb);
-
-			if (queue_index != old_index && sk) {
-				struct dst_entry *dst =
+		if (queue_index != new_index && sk) {
+			struct dst_entry *dst =
 				    rcu_dereference_check(sk->sk_dst_cache, 1);
 
-				if (dst && skb_dst(skb) == dst)
-					sk_tx_queue_set(sk, queue_index);
-			}
+			if (dst && skb_dst(skb) == dst)
+				sk_tx_queue_set(sk, queue_index);
+
 		}
+
+		queue_index = new_index;
+	}
+
+	return queue_index;
+}
+
+struct netdev_queue *netdev_pick_tx(struct net_device *dev,
+				    struct sk_buff *skb)
+{
+	int queue_index = 0;
+
+	if (dev->real_num_tx_queues != 1) {
+		const struct net_device_ops *ops = dev->netdev_ops;
+		if (ops->ndo_select_queue)
+			queue_index = ops->ndo_select_queue(dev, skb);
+		else
+			queue_index = __netdev_pick_tx(dev, skb);
+		queue_index = dev_cap_txqueue(dev, queue_index);
 	}
 
 	skb_set_queue_mapping(skb, queue_index);
