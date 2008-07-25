From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net: eliminate refcounting in backlog queue
Date: Fri, 25 Jul 2008 12:32:12 -0700
Message-ID: <20080725123212.393314a9@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:52508 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751028AbYGYTcO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 15:32:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid the overhead of atomic increment/decrement on each received packet.
This helps performance of non-NAPI devices (like loopback).
Use cleanup function to walk queue on each cpu and clean out any
left over packets.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/dev.c	2008-07-25 11:27:07.000000000 -0700
+++ b/net/core/dev.c	2008-07-25 11:43:55.000000000 -0700
@@ -1909,7 +1909,6 @@ int netif_rx(struct sk_buff *skb)
 	if (queue->input_pkt_queue.qlen <= netdev_max_backlog) {
 		if (queue->input_pkt_queue.qlen) {
 enqueue:
-			dev_hold(skb->dev);
 			__skb_queue_tail(&queue->input_pkt_queue, skb);
 			local_irq_restore(flags);
 			return NET_RX_SUCCESS;
@@ -2270,6 +2269,20 @@ out:
 	return ret;
 }
 
+/* Network device is going away, flush any packets still pending  */
+static void flush_backlog(void *arg)
+{
+	struct net_device *dev = arg;
+	struct softnet_data *queue = &__get_cpu_var(softnet_data);
+	struct sk_buff *skb, *tmp;
+
+	skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
+		if (skb->dev == dev) {
+			__skb_unlink(skb, &queue->input_pkt_queue);
+			kfree_skb(skb);
+		}
+}
+
 static int process_backlog(struct napi_struct *napi, int quota)
 {
 	int work = 0;
@@ -2279,7 +2292,6 @@ static int process_backlog(struct napi_s
 	napi->weight = weight_p;
 	do {
 		struct sk_buff *skb;
-		struct net_device *dev;
 
 		local_irq_disable();
 		skb = __skb_dequeue(&queue->input_pkt_queue);
@@ -2288,14 +2300,9 @@ static int process_backlog(struct napi_s
 			local_irq_enable();
 			break;
 		}
-
 		local_irq_enable();
 
-		dev = skb->dev;
-
 		netif_receive_skb(skb);
-
-		dev_put(dev);
 	} while (++work < quota && jiffies == start_time);
 
 	return work;
@@ -4165,6 +4172,8 @@ void netdev_run_todo(void)
 
 		dev->reg_state = NETREG_UNREGISTERED;
 
+		on_each_cpu(flush_backlog, dev, 1);
+
 		netdev_wait_allrefs(dev);
 
 		/* paranoia */
