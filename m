From: subashab@codeaurora.org
Subject: Re: [PATCH] net: core: Fix race by  protecting process_queues at CPU
 hotplug
Date: Thu, 15 Jan 2015 19:03:03 -0000
Message-ID: <4504851fe2f44615e67cde94286a2fdd.squirrel@www.codeaurora.org>
References: <75547b88b7e2d15b35339a6321c3a929.squirrel@www.codeaurora.org>
    <1421305282.11734.38.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "Eric Dumazet" <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:60968 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752980AbbAOTDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 14:03:05 -0500
In-Reply-To: <1421305282.11734.38.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a CPU is hotplugged while processing incoming packets,
dev_cpu_callback() will copy the poll list from the offline
CPU and raise the softIRQ. In the same context, it will also
process process_queue of the offline CPU by de-queueing and
calling netif_rx. Due to this there is a potential for race
condition between process_backlog() and dev_cpu_callback()
accessing the same process_queue resource. This patch
protects this concurrent access by locking.

Signed-off-by: Prasad Sodagudi <psodagud@codeaurora.org>
Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 net/core/dev.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index df0b522..aa8f503 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3640,6 +3640,7 @@ static void flush_backlog(void *arg)
 	struct net_device *dev = arg;
 	struct softnet_data *sd = &__get_cpu_var(softnet_data);
 	struct sk_buff *skb, *tmp;
+	unsigned long flags;

 	rps_lock(sd);
 	skb_queue_walk_safe(&sd->input_pkt_queue, skb, tmp) {
@@ -3651,6 +3652,7 @@ static void flush_backlog(void *arg)
 	}
 	rps_unlock(sd);

+	spin_lock_irqsave(&sd->process_queue.lock, flags);
 	skb_queue_walk_safe(&sd->process_queue, skb, tmp) {
 		if (skb->dev == dev) {
 			__skb_unlink(skb, &sd->process_queue);
@@ -3658,6 +3660,7 @@ static void flush_backlog(void *arg)
 			input_queue_head_incr(sd);
 		}
 	}
+	spin_unlock_irqrestore(&sd->process_queue.lock, flags);
 }

 static int napi_gro_complete(struct sk_buff *skb)
@@ -4021,7 +4024,7 @@ static int process_backlog(struct napi_struct *napi,
int quota)
 {
 	int work = 0;
 	struct softnet_data *sd = container_of(napi, struct softnet_data, backlog);
-
+	unsigned long flags;
 #ifdef CONFIG_RPS
 	/* Check if we have pending ipi, its better to send them now,
 	 * not waiting net_rx_action() end.
@@ -4032,18 +4035,19 @@ static int process_backlog(struct napi_struct
*napi, int quota)
 	}
 #endif
 	napi->weight = weight_p;
-	local_irq_disable();
+	spin_lock_irqsave(&sd->process_queue.lock, flags);
 	while (work < quota) {
 		struct sk_buff *skb;
 		unsigned int qlen;

 		while ((skb = __skb_dequeue(&sd->process_queue))) {
-			local_irq_enable();
+			spin_unlock_irqrestore(&sd->process_queue.lock, flags);
 			__netif_receive_skb(skb);
-			local_irq_disable();
+			spin_lock_irqsave(&sd->process_queue.lock, flags);
 			input_queue_head_incr(sd);
 			if (++work >= quota) {
-				local_irq_enable();
+				spin_unlock_irqrestore(&sd->process_queue.lock,
+						       flags);
 				return work;
 			}
 		}
@@ -4054,6 +4058,7 @@ static int process_backlog(struct napi_struct *napi,
int quota)
 			skb_queue_splice_tail_init(&sd->input_pkt_queue,
 						   &sd->process_queue);

+
 		if (qlen < quota - work) {
 			/*
 			 * Inline a custom version of __napi_complete().
@@ -4069,7 +4074,7 @@ static int process_backlog(struct napi_struct *napi,
int quota)
 		}
 		rps_unlock(sd);
 	}
-	local_irq_enable();
+	spin_unlock_irqrestore(&sd->process_queue.lock, flags);

 	return work;
 }
@@ -5991,6 +5996,7 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 	struct sk_buff *skb;
 	unsigned int cpu, oldcpu = (unsigned long)ocpu;
 	struct softnet_data *sd, *oldsd;
+	unsigned long flags;

 	if (action != CPU_DEAD && action != CPU_DEAD_FROZEN)
 		return NOTIFY_OK;
@@ -6024,11 +6030,15 @@ static int dev_cpu_callback(struct notifier_block
*nfb,
 	raise_softirq_irqoff(NET_TX_SOFTIRQ);
 	local_irq_enable();

+	spin_lock_irqsave(&oldsd->process_queue.lock, flags);
 	/* Process offline CPU's input_pkt_queue */
 	while ((skb = __skb_dequeue(&oldsd->process_queue))) {
+		spin_unlock_irqrestore(&oldsd->process_queue.lock, flags);
 		netif_rx(skb);
+		spin_lock_irqsave(&oldsd->process_queue.lock, flags);
 		input_queue_head_incr(oldsd);
 	}
+	spin_unlock_irqrestore(&oldsd->process_queue.lock, flags);
 	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {
 		netif_rx(skb);
 		input_queue_head_incr(oldsd);
-- 
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
 a Linux Foundation Collaborative Project


> On Thu, 2015-01-15 at 03:13 +0000, subashab@codeaurora.org wrote:
>> I am seeing frequent crashes in high throughput conditions in a
>> multiprocessor system with kernel version 3.10 where cores are getting
>> hot
>> plugged. I have pinned the network stack to a particular core using
>> receive packet steering (RPS). At the time of crash, it looks like a
>> contention of the process_queue between dev_cpu_callback and
>> process_backlog.
>
> Your patch is mangled, hard to tell what is going on.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
