From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2] Fix locking in flush_backlog
Date: Tue, 23 Mar 2010 16:39:19 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1003231635190.360@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:26773 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365Ab0CWXjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 19:39:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to take spinlocks when dequeuing from input_pkt_queue in flush_backlog.
Also, flush_backlog can now be called directly from netdev_run_todo.

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
diff --git a/net/core/dev.c b/net/core/dev.c
index a03aab4..5e3dc28 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2766,17 +2766,19 @@ int netif_receive_skb(struct sk_buff *skb)
 EXPORT_SYMBOL(netif_receive_skb);
 
 /* Network device is going away, flush any packets still pending  */
-static void flush_backlog(void *arg)
+static void flush_backlog(struct net_device *dev, int cpu)
 {
-	struct net_device *dev = arg;
-	struct softnet_data *queue = &__get_cpu_var(softnet_data);
+	struct softnet_data *queue = &per_cpu(softnet_data, cpu);
 	struct sk_buff *skb, *tmp;
+	unsigned long flags;
 
+	spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);
 	skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
 		if (skb->dev == dev) {
 			__skb_unlink(skb, &queue->input_pkt_queue);
 			kfree_skb(skb);
 		}
+	spin_unlock_irqrestore(&queue->input_pkt_queue.lock, flags);
 }
 
 static int napi_gro_complete(struct sk_buff *skb)
@@ -5545,6 +5547,7 @@ void netdev_run_todo(void)
 	while (!list_empty(&list)) {
 		struct net_device *dev
 			= list_first_entry(&list, struct net_device, todo_list);
+		int i;
 		list_del(&dev->todo_list);
 
 		if (unlikely(dev->reg_state != NETREG_UNREGISTERING)) {
@@ -5556,7 +5559,8 @@ void netdev_run_todo(void)
 
 		dev->reg_state = NETREG_UNREGISTERED;
 
-		on_each_cpu(flush_backlog, dev, 1);
+		for_each_online_cpu(i)
+			flush_backlog(dev, i);
 
 		netdev_wait_allrefs(dev);
 
