From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net: move rx and tx hash functions to net/core/flow_dissector.c
Date: Mon, 21 Jan 2013 18:39:24 +0800
Message-ID: <1358764764-3533-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:52971 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135Ab3AUKjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 05:39:48 -0500
Received: by mail-pa0-f47.google.com with SMTP id fa10so3326864pad.34
        for <netdev@vger.kernel.org>; Mon, 21 Jan 2013 02:39:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

__skb_tx_hash() and __skb_get_rxhash() are all for calculating hash
value based by some fields in skb, mostly used for selecting queues
by device drivers.

Meanwhile, net/core/dev.c is bloating.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
 net/core/dev.c            |  175 ---------------------------------------------
 net/core/flow_dissector.c |  173 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 173 insertions(+), 175 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b6d2b32..c69cd87 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -134,7 +134,6 @@
 #include <linux/cpu_rmap.h>
 #include <linux/net_tstamp.h>
 #include <linux/static_key.h>
-#include <net/flow_keys.h>
 
 #include "net-sysfs.h"
 
@@ -2636,136 +2635,6 @@ out:
 	return rc;
 }
 
-static u32 hashrnd __read_mostly;
-
-/*
- * Returns a Tx hash based on the given packet descriptor a Tx queues' number
- * to be used as a distribution range.
- */
-u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
-		  unsigned int num_tx_queues)
-{
-	u32 hash;
-	u16 qoffset = 0;
-	u16 qcount = num_tx_queues;
-
-	if (skb_rx_queue_recorded(skb)) {
-		hash = skb_get_rx_queue(skb);
-		while (unlikely(hash >= num_tx_queues))
-			hash -= num_tx_queues;
-		return hash;
-	}
-
-	if (dev->num_tc) {
-		u8 tc = netdev_get_prio_tc_map(dev, skb->priority);
-		qoffset = dev->tc_to_txq[tc].offset;
-		qcount = dev->tc_to_txq[tc].count;
-	}
-
-	if (skb->sk && skb->sk->sk_hash)
-		hash = skb->sk->sk_hash;
-	else
-		hash = (__force u16) skb->protocol;
-	hash = jhash_1word(hash, hashrnd);
-
-	return (u16) (((u64) hash * qcount) >> 32) + qoffset;
-}
-EXPORT_SYMBOL(__skb_tx_hash);
-
-static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
-{
-	if (unlikely(queue_index >= dev->real_num_tx_queues)) {
-		net_warn_ratelimited("%s selects TX queue %d, but real number of TX queues is %d\n",
-				     dev->name, queue_index,
-				     dev->real_num_tx_queues);
-		return 0;
-	}
-	return queue_index;
-}
-
-static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
-{
-#ifdef CONFIG_XPS
-	struct xps_dev_maps *dev_maps;
-	struct xps_map *map;
-	int queue_index = -1;
-
-	rcu_read_lock();
-	dev_maps = rcu_dereference(dev->xps_maps);
-	if (dev_maps) {
-		map = rcu_dereference(
-		    dev_maps->cpu_map[raw_smp_processor_id()]);
-		if (map) {
-			if (map->len == 1)
-				queue_index = map->queues[0];
-			else {
-				u32 hash;
-				if (skb->sk && skb->sk->sk_hash)
-					hash = skb->sk->sk_hash;
-				else
-					hash = (__force u16) skb->protocol ^
-					    skb->rxhash;
-				hash = jhash_1word(hash, hashrnd);
-				queue_index = map->queues[
-				    ((u64)hash * map->len) >> 32];
-			}
-			if (unlikely(queue_index >= dev->real_num_tx_queues))
-				queue_index = -1;
-		}
-	}
-	rcu_read_unlock();
-
-	return queue_index;
-#else
-	return -1;
-#endif
-}
-
-u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
-{
-	struct sock *sk = skb->sk;
-	int queue_index = sk_tx_queue_get(sk);
-
-	if (queue_index < 0 || skb->ooo_okay ||
-	    queue_index >= dev->real_num_tx_queues) {
-		int new_index = get_xps_queue(dev, skb);
-		if (new_index < 0)
-			new_index = skb_tx_hash(dev, skb);
-
-		if (queue_index != new_index && sk) {
-			struct dst_entry *dst =
-				    rcu_dereference_check(sk->sk_dst_cache, 1);
-
-			if (dst && skb_dst(skb) == dst)
-				sk_tx_queue_set(sk, queue_index);
-
-		}
-
-		queue_index = new_index;
-	}
-
-	return queue_index;
-}
-EXPORT_SYMBOL(__netdev_pick_tx);
-
-struct netdev_queue *netdev_pick_tx(struct net_device *dev,
-				    struct sk_buff *skb)
-{
-	int queue_index = 0;
-
-	if (dev->real_num_tx_queues != 1) {
-		const struct net_device_ops *ops = dev->netdev_ops;
-		if (ops->ndo_select_queue)
-			queue_index = ops->ndo_select_queue(dev, skb);
-		else
-			queue_index = __netdev_pick_tx(dev, skb);
-		queue_index = dev_cap_txqueue(dev, queue_index);
-	}
-
-	skb_set_queue_mapping(skb, queue_index);
-	return netdev_get_tx_queue(dev, queue_index);
-}
-
 static void qdisc_pkt_len_init(struct sk_buff *skb)
 {
 	const struct skb_shared_info *shinfo = skb_shinfo(skb);
@@ -3015,41 +2884,6 @@ static inline void ____napi_schedule(struct softnet_data *sd,
 	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
 }
 
-/*
- * __skb_get_rxhash: calculate a flow hash based on src/dst addresses
- * and src/dst port numbers.  Sets rxhash in skb to non-zero hash value
- * on success, zero indicates no valid hash.  Also, sets l4_rxhash in skb
- * if hash is a canonical 4-tuple hash over transport ports.
- */
-void __skb_get_rxhash(struct sk_buff *skb)
-{
-	struct flow_keys keys;
-	u32 hash;
-
-	if (!skb_flow_dissect(skb, &keys))
-		return;
-
-	if (keys.ports)
-		skb->l4_rxhash = 1;
-
-	/* get a consistent hash (same value on both flow directions) */
-	if (((__force u32)keys.dst < (__force u32)keys.src) ||
-	    (((__force u32)keys.dst == (__force u32)keys.src) &&
-	     ((__force u16)keys.port16[1] < (__force u16)keys.port16[0]))) {
-		swap(keys.dst, keys.src);
-		swap(keys.port16[0], keys.port16[1]);
-	}
-
-	hash = jhash_3words((__force u32)keys.dst,
-			    (__force u32)keys.src,
-			    (__force u32)keys.ports, hashrnd);
-	if (!hash)
-		hash = 1;
-
-	skb->rxhash = hash;
-}
-EXPORT_SYMBOL(__skb_get_rxhash);
-
 #ifdef CONFIG_RPS
 
 /* One global table that all flow-based protocols share. */
@@ -7308,12 +7142,3 @@ out:
 }
 
 subsys_initcall(net_dev_init);
-
-static int __init initialize_hashrnd(void)
-{
-	get_random_bytes(&hashrnd, sizeof(hashrnd));
-	return 0;
-}
-
-late_initcall_sync(initialize_hashrnd);
-
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 466820b..9d4c720 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -143,3 +143,176 @@ ipv6:
 	return true;
 }
 EXPORT_SYMBOL(skb_flow_dissect);
+
+static u32 hashrnd __read_mostly;
+
+/*
+ * __skb_get_rxhash: calculate a flow hash based on src/dst addresses
+ * and src/dst port numbers.  Sets rxhash in skb to non-zero hash value
+ * on success, zero indicates no valid hash.  Also, sets l4_rxhash in skb
+ * if hash is a canonical 4-tuple hash over transport ports.
+ */
+void __skb_get_rxhash(struct sk_buff *skb)
+{
+	struct flow_keys keys;
+	u32 hash;
+
+	if (!skb_flow_dissect(skb, &keys))
+		return;
+
+	if (keys.ports)
+		skb->l4_rxhash = 1;
+
+	/* get a consistent hash (same value on both flow directions) */
+	if (((__force u32)keys.dst < (__force u32)keys.src) ||
+	    (((__force u32)keys.dst == (__force u32)keys.src) &&
+	     ((__force u16)keys.port16[1] < (__force u16)keys.port16[0]))) {
+		swap(keys.dst, keys.src);
+		swap(keys.port16[0], keys.port16[1]);
+	}
+
+	hash = jhash_3words((__force u32)keys.dst,
+			    (__force u32)keys.src,
+			    (__force u32)keys.ports, hashrnd);
+	if (!hash)
+		hash = 1;
+
+	skb->rxhash = hash;
+}
+EXPORT_SYMBOL(__skb_get_rxhash);
+
+/*
+ * Returns a Tx hash based on the given packet descriptor a Tx queues' number
+ * to be used as a distribution range.
+ */
+u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
+		  unsigned int num_tx_queues)
+{
+	u32 hash;
+	u16 qoffset = 0;
+	u16 qcount = num_tx_queues;
+
+	if (skb_rx_queue_recorded(skb)) {
+		hash = skb_get_rx_queue(skb);
+		while (unlikely(hash >= num_tx_queues))
+			hash -= num_tx_queues;
+		return hash;
+	}
+
+	if (dev->num_tc) {
+		u8 tc = netdev_get_prio_tc_map(dev, skb->priority);
+		qoffset = dev->tc_to_txq[tc].offset;
+		qcount = dev->tc_to_txq[tc].count;
+	}
+
+	if (skb->sk && skb->sk->sk_hash)
+		hash = skb->sk->sk_hash;
+	else
+		hash = (__force u16) skb->protocol;
+	hash = jhash_1word(hash, hashrnd);
+
+	return (u16) (((u64) hash * qcount) >> 32) + qoffset;
+}
+EXPORT_SYMBOL(__skb_tx_hash);
+
+static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
+{
+	if (unlikely(queue_index >= dev->real_num_tx_queues)) {
+		net_warn_ratelimited("%s selects TX queue %d, but real number of TX queues is %d\n",
+				     dev->name, queue_index,
+				     dev->real_num_tx_queues);
+		return 0;
+	}
+	return queue_index;
+}
+
+static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
+{
+#ifdef CONFIG_XPS
+	struct xps_dev_maps *dev_maps;
+	struct xps_map *map;
+	int queue_index = -1;
+
+	rcu_read_lock();
+	dev_maps = rcu_dereference(dev->xps_maps);
+	if (dev_maps) {
+		map = rcu_dereference(
+		    dev_maps->cpu_map[raw_smp_processor_id()]);
+		if (map) {
+			if (map->len == 1)
+				queue_index = map->queues[0];
+			else {
+				u32 hash;
+				if (skb->sk && skb->sk->sk_hash)
+					hash = skb->sk->sk_hash;
+				else
+					hash = (__force u16) skb->protocol ^
+					    skb->rxhash;
+				hash = jhash_1word(hash, hashrnd);
+				queue_index = map->queues[
+				    ((u64)hash * map->len) >> 32];
+			}
+			if (unlikely(queue_index >= dev->real_num_tx_queues))
+				queue_index = -1;
+		}
+	}
+	rcu_read_unlock();
+
+	return queue_index;
+#else
+	return -1;
+#endif
+}
+
+u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+	int queue_index = sk_tx_queue_get(sk);
+
+	if (queue_index < 0 || skb->ooo_okay ||
+	    queue_index >= dev->real_num_tx_queues) {
+		int new_index = get_xps_queue(dev, skb);
+		if (new_index < 0)
+			new_index = skb_tx_hash(dev, skb);
+
+		if (queue_index != new_index && sk) {
+			struct dst_entry *dst =
+				    rcu_dereference_check(sk->sk_dst_cache, 1);
+
+			if (dst && skb_dst(skb) == dst)
+				sk_tx_queue_set(sk, queue_index);
+
+		}
+
+		queue_index = new_index;
+	}
+
+	return queue_index;
+}
+EXPORT_SYMBOL(__netdev_pick_tx);
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
+	}
+
+	skb_set_queue_mapping(skb, queue_index);
+	return netdev_get_tx_queue(dev, queue_index);
+}
+
+static int __init initialize_hashrnd(void)
+{
+	get_random_bytes(&hashrnd, sizeof(hashrnd));
+	return 0;
+}
+
+late_initcall_sync(initialize_hashrnd);
