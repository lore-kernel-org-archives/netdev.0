From: Changli Gao <xiaosuo@gmail.com>
Subject: rps: keep the old behavior on SMP without rps
Date: Wed, 31 Mar 2010 13:28:53 +0800
Message-ID: <4BB2DD95.90402@gmail.com>
Reply-To: xiaosuo@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, xiaosuo <xiaosuo@gmail.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:42883 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754272Ab0CaF3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 01:29:20 -0400
Received: by gyg13 with SMTP id 13so2604369gyg.19
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 22:29:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

keep the old behavior on SMP without rps

RPS introduces a lock operation to per cpu variable input_pkt_queue on
SMP whenever rps is enabled or not. On SMP without RPS, this lock isn't
needed at all.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
net/core/dev.c | 34 ++++++++++++++++++++++++++--------
1 file changed, 26 insertions(+), 8 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3e7fa16..14ad3b7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2314,13 +2314,19 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu)
 	local_irq_save(flags);
 	__get_cpu_var(netdev_rx_stat).total++;
 
+#ifdef CONFIG_RPS
 	spin_lock(&queue->input_pkt_queue.lock);
+#endif
 	if (queue->input_pkt_queue.qlen <= netdev_max_backlog) {
 		if (queue->input_pkt_queue.qlen) {
 enqueue:
 			__skb_queue_tail(&queue->input_pkt_queue, skb);
+#ifdef CONFIG_RPS
 			spin_unlock_irqrestore(&queue->input_pkt_queue.lock,
 			    flags);
+#else
+			local_irq_restore(flags);
+#endif
 			return NET_RX_SUCCESS;
 		}
 
@@ -2342,7 +2348,9 @@ enqueue:
 		goto enqueue;
 	}
 
+#ifdef CONFIG_RPS
 	spin_unlock(&queue->input_pkt_queue.lock);
+#endif
 
 	__get_cpu_var(netdev_rx_stat).dropped++;
 	local_irq_restore(flags);
@@ -2767,19 +2775,23 @@ int netif_receive_skb(struct sk_buff *skb)
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
+#ifdef CONFIG_RPS
+	spin_lock(&queue->input_pkt_queue.lock);
+#endif
 	skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
 		if (skb->dev == dev) {
 			__skb_unlink(skb, &queue->input_pkt_queue);
 			kfree_skb(skb);
 		}
-	spin_unlock_irqrestore(&queue->input_pkt_queue.lock, flags);
+#ifdef CONFIG_RPS
+	spin_unlock(&queue->input_pkt_queue.lock);
+#endif
 }
 
 static int napi_gro_complete(struct sk_buff *skb)
@@ -3092,14 +3104,22 @@ static int process_backlog(struct napi_struct *napi, int quota)
 	do {
 		struct sk_buff *skb;
 
+#ifdef CONFIG_RPS
 		spin_lock_irq(&queue->input_pkt_queue.lock);
+#else
+		local_irq_disable();
+#endif
 		skb = __skb_dequeue(&queue->input_pkt_queue);
 		if (!skb) {
 			__napi_complete(napi);
 			spin_unlock_irq(&queue->input_pkt_queue.lock);
 			break;
 		}
+#ifdef CONFIG_RPS
 		spin_unlock_irq(&queue->input_pkt_queue.lock);
+#else
+		local_irq_enable();
+#endif
 
 		__netif_receive_skb(skb);
 	} while (++work < quota && jiffies == start_time);
@@ -5549,7 +5569,6 @@ void netdev_run_todo(void)
 	while (!list_empty(&list)) {
 		struct net_device *dev
 			= list_first_entry(&list, struct net_device, todo_list);
-		int i;
 		list_del(&dev->todo_list);
 
 		if (unlikely(dev->reg_state != NETREG_UNREGISTERING)) {
@@ -5561,8 +5580,7 @@ void netdev_run_todo(void)
 
 		dev->reg_state = NETREG_UNREGISTERED;
 
-		for_each_online_cpu(i)
-			flush_backlog(dev, i);
+		on_each_cpu(flush_backlog, dev, 1);
 
 		netdev_wait_allrefs(dev);
 


