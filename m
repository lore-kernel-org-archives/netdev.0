From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 07/15] net: move netdev_pick_tx and dependencies to net/core/dev.c
Date: Tue, 12 May 2015 14:56:13 +0200
Message-ID: <1431435381-7164-8-git-send-email-jiri@resnulli.us>
References: <1431435381-7164-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, tom@herbertland.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:32961 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932962AbbELM5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 08:57:01 -0400
Received: by wgin8 with SMTP id n8so8829768wgi.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 05:57:00 -0700 (PDT)
In-Reply-To: <1431435381-7164-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

next to its user. No relation to flow_dissector so it makes no sense to
have it in flow_dissector.c

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/dev.c            | 78 +++++++++++++++++++++++++++++++++++++++++++++++
 net/core/flow_dissector.c | 78 -----------------------------------------------
 2 files changed, 78 insertions(+), 78 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3e7838f..8ef30be 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2936,6 +2936,84 @@ int dev_loopback_xmit(struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(dev_loopback_xmit);
 
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
+		    dev_maps->cpu_map[skb->sender_cpu - 1]);
+		if (map) {
+			if (map->len == 1)
+				queue_index = map->queues[0];
+			else
+				queue_index = map->queues[reciprocal_scale(skb_get_hash(skb),
+									   map->len)];
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
+static u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
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
+		if (queue_index != new_index && sk &&
+		    rcu_access_pointer(sk->sk_dst_cache))
+			sk_tx_queue_set(sk, new_index);
+
+		queue_index = new_index;
+	}
+
+	return queue_index;
+}
+
+struct netdev_queue *netdev_pick_tx(struct net_device *dev,
+				    struct sk_buff *skb,
+				    void *accel_priv)
+{
+	int queue_index = 0;
+
+#ifdef CONFIG_XPS
+	if (skb->sender_cpu == 0)
+		skb->sender_cpu = raw_smp_processor_id() + 1;
+#endif
+
+	if (dev->real_num_tx_queues != 1) {
+		const struct net_device_ops *ops = dev->netdev_ops;
+		if (ops->ndo_select_queue)
+			queue_index = ops->ndo_select_queue(dev, skb, accel_priv,
+							    __netdev_pick_tx);
+		else
+			queue_index = __netdev_pick_tx(dev, skb);
+
+		if (!accel_priv)
+			queue_index = netdev_cap_txqueue(dev, queue_index);
+	}
+
+	skb_set_queue_mapping(skb, queue_index);
+	return netdev_get_tx_queue(dev, queue_index);
+}
+
 /**
  *	__dev_queue_xmit - transmit a buffer
  *	@skb: buffer to transmit
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 07ca11d..04f8723 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -431,81 +431,3 @@ u32 skb_get_poff(const struct sk_buff *skb)
 
 	return __skb_get_poff(skb, skb->data, &keys, skb_headlen(skb));
 }
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
-		    dev_maps->cpu_map[skb->sender_cpu - 1]);
-		if (map) {
-			if (map->len == 1)
-				queue_index = map->queues[0];
-			else
-				queue_index = map->queues[reciprocal_scale(skb_get_hash(skb),
-									   map->len)];
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
-static u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
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
-		if (queue_index != new_index && sk &&
-		    rcu_access_pointer(sk->sk_dst_cache))
-			sk_tx_queue_set(sk, new_index);
-
-		queue_index = new_index;
-	}
-
-	return queue_index;
-}
-
-struct netdev_queue *netdev_pick_tx(struct net_device *dev,
-				    struct sk_buff *skb,
-				    void *accel_priv)
-{
-	int queue_index = 0;
-
-#ifdef CONFIG_XPS
-	if (skb->sender_cpu == 0)
-		skb->sender_cpu = raw_smp_processor_id() + 1;
-#endif
-
-	if (dev->real_num_tx_queues != 1) {
-		const struct net_device_ops *ops = dev->netdev_ops;
-		if (ops->ndo_select_queue)
-			queue_index = ops->ndo_select_queue(dev, skb, accel_priv,
-							    __netdev_pick_tx);
-		else
-			queue_index = __netdev_pick_tx(dev, skb);
-
-		if (!accel_priv)
-			queue_index = netdev_cap_txqueue(dev, queue_index);
-	}
-
-	skb_set_queue_mapping(skb, queue_index);
-	return netdev_get_tx_queue(dev, queue_index);
-}
-- 
2.4.0
