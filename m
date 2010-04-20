From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC PATCH] net: Set sock's TX queue to match the RX queue
Date: Tue, 20 Apr 2010 23:10:13 +0100
Message-ID: <1271801414.2083.34.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:6228 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575Ab0DTWKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 18:10:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We generally expect TX work for a connected socket to be done on the
same CPU (or rather hardware thread) as RX work, so the RX and TX
queue selection should match.  Therefore, when a sock with a cached
destination receives an skb from a multi-RX-queue net device, set the
sock's TX queue index to the RX queue index of the skb, modulo the
number of TX queues on the cached output device.

This changes the representation of TX queue mapping to record how the
current queue selection (if any) was made.  We can make the initial
queue selection based on the current simple hash, then replace it once
we know which RX queue is selected.  For TCP and other connected
protocols, this should all be settled during the initial handshake
so the change of TX queue will not cause packet reordering.

I haven't given this a whole lot of testing yet.  I would be interested
to hear how this affects performance on different systems and whether
it's actually worth doing.

Ben.
---
 include/net/sock.h |   37 +++++++++++++++++++++++++++++--------
 net/core/dev.c     |    3 ++-
 net/core/sock.c    |   18 +++++++++++++++++-
 3 files changed, 48 insertions(+), 10 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 56df440..3cd2b17 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -108,7 +108,8 @@ struct net;
  *	@skc_node: main hash linkage for various protocol lookup tables
  *	@skc_nulls_node: main hash linkage for TCP/UDP/UDP-Lite protocol
  *	@skc_refcnt: reference count
- *	@skc_tx_queue_mapping: tx queue number for this connection
+ *	@skc_tx_queue_source: source for @skc_tx_queue_index
+ *	@skc_tx_queue_index: tx queue index for this connection
  *	@skc_hash: hash value used with various protocol lookup tables
  *	@skc_u16hashes: two u16 hash values used by UDP lookup tables
  *	@skc_family: network address family
@@ -132,7 +133,8 @@ struct sock_common {
 		struct hlist_nulls_node skc_nulls_node;
 	};
 	atomic_t		skc_refcnt;
-	int			skc_tx_queue_mapping;
+	u16			skc_tx_queue_source;
+	u16			skc_tx_queue_index;
 
 	union  {
 		unsigned int	skc_hash;
@@ -152,6 +154,12 @@ struct sock_common {
 #endif
 };
 
+enum sock_tx_queue_source {
+	SK_TX_QUEUE_SOURCE_NONE,
+	SK_TX_QUEUE_SOURCE_HASH,
+	SK_TX_QUEUE_SOURCE_RX_QUEUE
+};
+
 /**
   *	struct sock - network layer representation of sockets
   *	@__sk_common: shared layout with inet_timewait_sock
@@ -226,7 +234,8 @@ struct sock {
 #define sk_node			__sk_common.skc_node
 #define sk_nulls_node		__sk_common.skc_nulls_node
 #define sk_refcnt		__sk_common.skc_refcnt
-#define sk_tx_queue_mapping	__sk_common.skc_tx_queue_mapping
+#define sk_tx_queue_source	__sk_common.skc_tx_queue_source
+#define sk_tx_queue_index	__sk_common.skc_tx_queue_index
 
 #define sk_copy_start		__sk_common.skc_hash
 #define sk_hash			__sk_common.skc_hash
@@ -1134,24 +1143,29 @@ static inline void sock_put(struct sock *sk)
 extern int sk_receive_skb(struct sock *sk, struct sk_buff *skb,
 			  const int nested);
 
-static inline void sk_tx_queue_set(struct sock *sk, int tx_queue)
+static inline void
+sk_tx_queue_set(struct sock *sk, u16 index, enum sock_tx_queue_source source)
 {
-	sk->sk_tx_queue_mapping = tx_queue;
+	sk->sk_tx_queue_source = source;
+	sk->sk_tx_queue_index = index;
 }
 
+extern void
+__sk_tx_queue_set_from_rx_queue(struct sock *sk, const struct sk_buff *skb);
+
 static inline void sk_tx_queue_clear(struct sock *sk)
 {
-	sk->sk_tx_queue_mapping = -1;
+	sk->sk_tx_queue_source = SK_TX_QUEUE_SOURCE_NONE;
 }
 
 static inline int sk_tx_queue_get(const struct sock *sk)
 {
-	return sk->sk_tx_queue_mapping;
+	return sk->sk_tx_queue_index;
 }
 
 static inline bool sk_tx_queue_recorded(const struct sock *sk)
 {
-	return (sk && sk->sk_tx_queue_mapping >= 0);
+	return (sk && sk->sk_tx_queue_source != SK_TX_QUEUE_SOURCE_NONE);
 }
 
 static inline void sk_set_socket(struct sock *sk, struct socket *sock)
@@ -1423,6 +1437,13 @@ static inline void skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
 	skb->destructor = sock_rfree;
 	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
 	sk_mem_charge(sk, skb->truesize);
+	/*
+	 * If we're receiving through a multiqueue device, set the
+	 * TX queue to match the RX queue.
+	 */
+	if (sk->sk_dst_cache && skb_rx_queue_recorded(skb) &&
+	    unlikely(sk->sk_tx_queue_source != SK_TX_QUEUE_SOURCE_RX_QUEUE))
+		__sk_tx_queue_set_from_rx_queue(sk, skb);
 }
 
 extern void sk_reset_timer(struct sock *sk, struct timer_list* timer,
diff --git a/net/core/dev.c b/net/core/dev.c
index b31d5d6..576bb28 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2016,7 +2016,8 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 				queue_index = skb_tx_hash(dev, skb);
 
 			if (sk && rcu_dereference_check(sk->sk_dst_cache, 1))
-				sk_tx_queue_set(sk, queue_index);
+				sk_tx_queue_set(sk, queue_index,
+						SK_TX_QUEUE_SOURCE_HASH);
 		}
 	}
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 7effa1e..66719a7 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -362,6 +362,21 @@ void sk_reset_txq(struct sock *sk)
 }
 EXPORT_SYMBOL(sk_reset_txq);
 
+void __sk_tx_queue_set_from_rx_queue(struct sock *sk, const struct sk_buff *skb)
+{
+	struct dst_entry *dst = __sk_dst_get(sk);
+	u16 queue_index = skb_get_rx_queue(skb);
+	struct net_device *output_dev;
+
+	if (!dst)
+		return;
+	output_dev = dst->dev;
+	if (unlikely(queue_index >= output_dev->real_num_tx_queues))
+		queue_index %= output_dev->real_num_tx_queues;
+	sk_tx_queue_set(sk, queue_index, SK_TX_QUEUE_SOURCE_RX_QUEUE);
+}
+EXPORT_SYMBOL_GPL(__sk_tx_queue_set_from_rx_queue);
+
 struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie)
 {
 	struct dst_entry *dst = __sk_dst_get(sk);
@@ -966,7 +981,8 @@ static void sock_copy(struct sock *nsk, const struct sock *osk)
 #endif
 	BUILD_BUG_ON(offsetof(struct sock, sk_copy_start) !=
 		     sizeof(osk->sk_node) + sizeof(osk->sk_refcnt) +
-		     sizeof(osk->sk_tx_queue_mapping));
+		     sizeof(osk->sk_tx_queue_source) +
+		     sizeof(osk->sk_tx_queue_index));
 	memcpy(&nsk->sk_copy_start, &osk->sk_copy_start,
 	       osk->sk_prot->obj_size - offsetof(struct sock, sk_copy_start));
 #ifdef CONFIG_SECURITY_NETWORK
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

