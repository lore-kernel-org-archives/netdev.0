From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH] net: flush the softnet backlog in process context
Date: Wed, 27 Jul 2016 12:37:54 +0200
Message-ID: <1e1b4ce29a5c254ab3ca605003bb622afb204c87.1469615619.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33754 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753024AbcG0Kit (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2016 06:38:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently in process_backlog(), the process_queue dequeuing is
performed with local IRQ disabled, to protect against
flush_backlog(), which runs in hard IRQ context.

This patch moves the flush operation to a work queue and runs the
callback with bottom half disabled to protect the process_queue
against dequeuing.
Since process_queue is now always manipulated in bottom half context,
the irq disable/enable pair around the dequeue operation are removed.

To keep the flush time as low as possible, the flush
works are scheduled on all online cpu simultaneously, using the
high priority work-queue and statically allocated, per cpu,
work structs.

Overall this change increases the time required to destroy a device
to improve slightly the packets reinjection performances.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/core/dev.c | 72 ++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 50 insertions(+), 22 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 2a9c39f..9b8cfab 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4292,15 +4292,25 @@ int netif_receive_skb(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(netif_receive_skb);
 
-/* Network device is going away, flush any packets still pending
- * Called with irqs disabled.
- */
-static void flush_backlog(void *arg)
+struct flush_work {
+	struct net_device *dev;
+	struct work_struct work;
+};
+
+DEFINE_PER_CPU(struct flush_work, flush_works);
+
+/* Network device is going away, flush any packets still pending */
+static void flush_backlog(struct work_struct *work)
 {
-	struct net_device *dev = arg;
-	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
+	struct flush_work *flush = container_of(work, typeof(*flush), work);
+	struct net_device *dev = flush->dev;
 	struct sk_buff *skb, *tmp;
+	struct softnet_data *sd;
+
+	local_bh_disable();
+	sd = this_cpu_ptr(&softnet_data);
 
+	local_irq_disable();
 	rps_lock(sd);
 	skb_queue_walk_safe(&sd->input_pkt_queue, skb, tmp) {
 		if (skb->dev == dev) {
@@ -4310,6 +4320,7 @@ static void flush_backlog(void *arg)
 		}
 	}
 	rps_unlock(sd);
+	local_irq_enable();
 
 	skb_queue_walk_safe(&sd->process_queue, skb, tmp) {
 		if (skb->dev == dev) {
@@ -4318,6 +4329,27 @@ static void flush_backlog(void *arg)
 			input_queue_head_incr(sd);
 		}
 	}
+	local_bh_enable();
+}
+
+static void flush_all_backlogs(struct net_device *dev)
+{
+	unsigned int cpu;
+
+	get_online_cpus();
+
+	for_each_online_cpu(cpu) {
+		struct flush_work *flush = per_cpu_ptr(&flush_works, cpu);
+
+		INIT_WORK(&flush->work, flush_backlog);
+		flush->dev = dev;
+		queue_work_on(cpu, system_highpri_wq, &flush->work);
+	}
+
+	for_each_online_cpu(cpu)
+		flush_work(&per_cpu_ptr(&flush_works, cpu)->work);
+
+	put_online_cpus();
 }
 
 static int napi_gro_complete(struct sk_buff *skb)
@@ -4805,8 +4837,9 @@ static bool sd_has_rps_ipi_waiting(struct softnet_data *sd)
 
 static int process_backlog(struct napi_struct *napi, int quota)
 {
-	int work = 0;
 	struct softnet_data *sd = container_of(napi, struct softnet_data, backlog);
+	bool again = true;
+	int work = 0;
 
 	/* Check if we have pending ipi, its better to send them now,
 	 * not waiting net_rx_action() end.
@@ -4817,23 +4850,20 @@ static int process_backlog(struct napi_struct *napi, int quota)
 	}
 
 	napi->weight = weight_p;
-	local_irq_disable();
-	while (1) {
+	while (again) {
 		struct sk_buff *skb;
 
 		while ((skb = __skb_dequeue(&sd->process_queue))) {
 			rcu_read_lock();
-			local_irq_enable();
 			__netif_receive_skb(skb);
 			rcu_read_unlock();
-			local_irq_disable();
 			input_queue_head_incr(sd);
-			if (++work >= quota) {
-				local_irq_enable();
+			if (++work >= quota)
 				return work;
-			}
+
 		}
 
+		local_irq_disable();
 		rps_lock(sd);
 		if (skb_queue_empty(&sd->input_pkt_queue)) {
 			/*
@@ -4845,16 +4875,14 @@ static int process_backlog(struct napi_struct *napi, int quota)
 			 * and we dont need an smp_mb() memory barrier.
 			 */
 			napi->state = 0;
-			rps_unlock(sd);
-
-			break;
+			again = false;
+		} else {
+			skb_queue_splice_tail_init(&sd->input_pkt_queue,
+						   &sd->process_queue);
 		}
-
-		skb_queue_splice_tail_init(&sd->input_pkt_queue,
-					   &sd->process_queue);
 		rps_unlock(sd);
+		local_irq_enable();
 	}
-	local_irq_enable();
 
 	return work;
 }
@@ -6711,7 +6739,7 @@ static void rollback_registered_many(struct list_head *head)
 		unlist_netdevice(dev);
 
 		dev->reg_state = NETREG_UNREGISTERING;
-		on_each_cpu(flush_backlog, dev, 1);
+		flush_all_backlogs(dev);
 	}
 
 	synchronize_net();
-- 
1.8.3.1
