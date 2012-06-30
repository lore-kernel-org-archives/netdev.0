From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 01/10] net: Split core bits of dev_pick_tx into
	__dev_pick_tx
Date: Fri, 29 Jun 2012 17:16:18 -0700
Message-ID: <20120630001618.29939.26996.stgit@gitlad.jf.intel.com>
References: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com, bhutchings@solarflare.com,
	therbert@google.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:53686 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754115Ab2F3AP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 20:15:59 -0400
In-Reply-To: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change splits the core bits of dev_pick_tx into a separate function.
The main idea behind this is to make this code accessible to select queue
functions when they decide to process the standard path instead of their
own custom path in their select queue routine.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 include/linux/netdevice.h |    3 +++
 net/core/dev.c            |   51 ++++++++++++++++++++++++++-------------------
 2 files changed, 33 insertions(+), 21 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2c2ecea..3329d70 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2082,6 +2082,9 @@ static inline u16 skb_tx_hash(const struct net_device *dev,
 	return __skb_tx_hash(dev, skb, dev->real_num_tx_queues);
 }
 
+extern int __dev_pick_tx(const struct net_device *dev,
+			 const struct sk_buff *skb);
+
 /**
  *	netif_is_multiqueue - test if device has multiple transmit queues
  *	@dev: network device
diff --git a/net/core/dev.c b/net/core/dev.c
index 57c4f9b..b31a9ff 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2301,7 +2301,8 @@ static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
 	return queue_index;
 }
 
-static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
+static inline int get_xps_queue(const struct net_device *dev,
+				const struct sk_buff *skb)
 {
 #ifdef CONFIG_XPS
 	struct xps_dev_maps *dev_maps;
@@ -2339,11 +2340,37 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 #endif
 }
 
+int __dev_pick_tx(const struct net_device *dev, const struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+	int queue_index = sk_tx_queue_get(sk);
+
+	if (queue_index < 0 || skb->ooo_okay ||
+	    queue_index >= dev->real_num_tx_queues) {
+		int old_index = queue_index;
+
+		queue_index = get_xps_queue(dev, skb);
+		if (queue_index < 0)
+			queue_index = skb_tx_hash(dev, skb);
+
+		if (queue_index != old_index && sk) {
+			struct dst_entry *dst =
+			    rcu_dereference_check(sk->sk_dst_cache, 1);
+
+			if (dst && skb_dst(skb) == dst)
+				sk_tx_queue_set(sk, queue_index);
+		}
+	}
+
+	return queue_index;
+}
+EXPORT_SYMBOL(__dev_pick_tx);
+
 static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					struct sk_buff *skb)
 {
-	int queue_index;
 	const struct net_device_ops *ops = dev->netdev_ops;
+	int queue_index;
 
 	if (dev->real_num_tx_queues == 1)
 		queue_index = 0;
@@ -2351,25 +2378,7 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 		queue_index = ops->ndo_select_queue(dev, skb);
 		queue_index = dev_cap_txqueue(dev, queue_index);
 	} else {
-		struct sock *sk = skb->sk;
-		queue_index = sk_tx_queue_get(sk);
-
-		if (queue_index < 0 || skb->ooo_okay ||
-		    queue_index >= dev->real_num_tx_queues) {
-			int old_index = queue_index;
-
-			queue_index = get_xps_queue(dev, skb);
-			if (queue_index < 0)
-				queue_index = skb_tx_hash(dev, skb);
-
-			if (queue_index != old_index && sk) {
-				struct dst_entry *dst =
-				    rcu_dereference_check(sk->sk_dst_cache, 1);
-
-				if (dst && skb_dst(skb) == dst)
-					sk_tx_queue_set(sk, queue_index);
-			}
-		}
+		queue_index = __dev_pick_tx(dev, skb);
 	}
 
 	skb_set_queue_mapping(skb, queue_index);
