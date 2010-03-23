From: Tom Herbert <therbert@google.com>
Subject: [PATCH] Fix locking in flush_backlog
Date: Mon, 22 Mar 2010 23:04:40 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1003222257470.3718@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:30476 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754138Ab0CWGEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 02:04:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to take spinlocks when dequeuing from input_pkt_queue in 
flush_backlog.  Also, with the spinlock the backlog queues can
be flushed directly from netdev_run_todo.

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index a03aab4..e7db656 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2765,20 +2765,6 @@ int netif_receive_skb(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(netif_receive_skb);
 
-/* Network device is going away, flush any packets still pending  */
-static void flush_backlog(void *arg)
-{
-	struct net_device *dev = arg;
-	struct softnet_data *queue = &__get_cpu_var(softnet_data);
-	struct sk_buff *skb, *tmp;
-
-	skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
-		if (skb->dev == dev) {
-			__skb_unlink(skb, &queue->input_pkt_queue);
-			kfree_skb(skb);
-		}
-}
-
 static int napi_gro_complete(struct sk_buff *skb)
 {
 	struct packet_type *ptype;
@@ -5545,6 +5531,7 @@ void netdev_run_todo(void)
 	while (!list_empty(&list)) {
 		struct net_device *dev
 			= list_first_entry(&list, struct net_device, todo_list);
+		int i;
 		list_del(&dev->todo_list);
 
 		if (unlikely(dev->reg_state != NETREG_UNREGISTERING)) {
@@ -5556,7 +5543,22 @@ void netdev_run_todo(void)
 
 		dev->reg_state = NETREG_UNREGISTERED;
 
-		on_each_cpu(flush_backlog, dev, 1);
+		/* Flush backlog queues of any pending packets */
+		for_each_online_cpu(i) {
+			struct softnet_data *queue = &per_cpu(softnet_data, i);
+			struct sk_buff *skb, *tmp;
+			unsigned long flags;
+
+			spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);
+			skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
+				if (skb->dev == dev) {
+					__skb_unlink(skb,
+					    &queue->input_pkt_queue);
+					kfree_skb(skb);
+				}
+			spin_unlock_irqrestore(&queue->input_pkt_queue.lock,
+			    flags);
+		}
 
 		netdev_wait_allrefs(dev);
 
