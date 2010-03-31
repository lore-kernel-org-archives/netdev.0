From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] rps: keep the old behavior on SMP without rps
Date: Wed, 31 Mar 2010 14:16:22 +0800
Message-ID: <4BB2E8B6.8010201@gmail.com>
Reply-To: xiaosuo@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiaosuo <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.211.172]:41141 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757369Ab0CaGXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 02:23:08 -0400
Received: by ywh2 with SMTP id 2so6196740ywh.33
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 23:23:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

keep the old behavior on SMP without rps

RPS introduces a lock operation to per cpu variable input_pkt_queue on
SMP whenever rps is enabled or not. On SMP without RPS, this lock isn't
needed at all.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
net/core/dev.c | 42 ++++++++++++++++++++++++++++--------------
1 file changed, 28 insertions(+), 14 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3e7fa16..d154f3b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -207,6 +207,20 @@ static inline struct hlist_head *dev_index_hash(struct net *net, int ifindex)
 	return &net->dev_index_head[ifindex & (NETDEV_HASHENTRIES - 1)];
 }
 
+static inline void rps_lock(struct softnet_data *queue)
+{
+#ifdef CONFIG_RPS
+	spin_lock(&queue->input_pkt_queue.lock);
+#endif
+}
+
+static inline void rps_unlock(struct softnet_data *queue)
+{
+#ifdef CONFIG_RPS
+	spin_unlock(&queue->input_pkt_queue.lock);
+#endif
+}
+
 /* Device list insertion */
 static int list_netdevice(struct net_device *dev)
 {
@@ -2314,13 +2328,13 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu)
 	local_irq_save(flags);
 	__get_cpu_var(netdev_rx_stat).total++;
 
-	spin_lock(&queue->input_pkt_queue.lock);
+	rps_lock(queue);
 	if (queue->input_pkt_queue.qlen <= netdev_max_backlog) {
 		if (queue->input_pkt_queue.qlen) {
 enqueue:
 			__skb_queue_tail(&queue->input_pkt_queue, skb);
-			spin_unlock_irqrestore(&queue->input_pkt_queue.lock,
-			    flags);
+			rps_unlock(queue);
+			local_irq_restore(flags);
 			return NET_RX_SUCCESS;
 		}
 
@@ -2342,7 +2356,7 @@ enqueue:
 		goto enqueue;
 	}
 
-	spin_unlock(&queue->input_pkt_queue.lock);
+	rps_unlock(queue);
 
 	__get_cpu_var(netdev_rx_stat).dropped++;
 	local_irq_restore(flags);
@@ -2767,19 +2781,19 @@ int netif_receive_skb(struct sk_buff *skb)
 EXPORT_SYMBOL(netif_receive_skb);
 
 /* Network device is going away, flush any packets still pending  */
-static void flush_backlog(struct net_device *dev, int cpu)
+static void flush_backlog(void *arg)
 {
-	struct softnet_data *queue = &per_cpu(softnet_data, cpu);
+	struct net_device *dev = arg;
+	struct softnet_data *queue = &__get_cpu_var(softnet_data);
 	struct sk_buff *skb, *tmp;
-	unsigned long flags;
 
-	spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);
+	rps_lock(queue);
 	skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
 		if (skb->dev == dev) {
 			__skb_unlink(skb, &queue->input_pkt_queue);
 			kfree_skb(skb);
 		}
-	spin_unlock_irqrestore(&queue->input_pkt_queue.lock, flags);
+	rps_unlock(queue);
 }
 
 static int napi_gro_complete(struct sk_buff *skb)
@@ -3092,14 +3106,16 @@ static int process_backlog(struct napi_struct *napi, int quota)
 	do {
 		struct sk_buff *skb;
 
-		spin_lock_irq(&queue->input_pkt_queue.lock);
+		local_irq_disable();
+		rps_lock(queue);
 		skb = __skb_dequeue(&queue->input_pkt_queue);
 		if (!skb) {
 			__napi_complete(napi);
 			spin_unlock_irq(&queue->input_pkt_queue.lock);
 			break;
 		}
-		spin_unlock_irq(&queue->input_pkt_queue.lock);
+		rps_unlock(queue);
+		local_irq_enable();
 
 		__netif_receive_skb(skb);
 	} while (++work < quota && jiffies == start_time);
@@ -5549,7 +5565,6 @@ void netdev_run_todo(void)
 	while (!list_empty(&list)) {
 		struct net_device *dev
 			= list_first_entry(&list, struct net_device, todo_list);
-		int i;
 		list_del(&dev->todo_list);
 
 		if (unlikely(dev->reg_state != NETREG_UNREGISTERING)) {
@@ -5561,8 +5576,7 @@ void netdev_run_todo(void)
 
 		dev->reg_state = NETREG_UNREGISTERED;
 
-		for_each_online_cpu(i)
-			flush_backlog(dev, i);
+		on_each_cpu(flush_backlog, dev, 1);
 
 		netdev_wait_allrefs(dev);
 

