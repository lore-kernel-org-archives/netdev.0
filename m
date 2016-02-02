From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 11/11] RFC: net: RPS bulk enqueue to backlog
Date: Tue, 02 Feb 2016 22:15:27 +0100
Message-ID: <20160202211512.16315.89019.stgit@firesoul>
References: <20160202211051.16315.51808.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>, tom@herbertland.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	ogerlitz@mellanox.com, gerlitz.or@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37762 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754596AbcBBVP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 16:15:29 -0500
In-Reply-To: <20160202211051.16315.51808.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NEED TO CLEAN UP PATCH (likely still contains bugs...)

When enabling Receive Packet Steering (RPS) like :

 echo 32768 > /proc/sys/net/core/rps_sock_flow_entries

 for N in $(seq 0 7) ; do
    echo 4096 > /sys/class/net/${DEV}/queues/rx-$N/rps_flow_cnt
    echo f >  /sys/class/net/${DEV}/queues/rx-$N/rps_cpus
    grep -H . /sys/class/net/${DEV}/queues/rx-$N/rps_cpus
 done

I noticed high contention on enqueue_to_backlog().  To mitigate
this introduce enqueue_list_to_backlog(), which allow to enqueue
an entire skb list, instead of having to take the per packet cost.

The skb list's needed for bulk enqueing are constructed in the
per CPU area of softnet_data.  And thus, can be constructed
without heavy CPU synchronization.

I'm excited about the performance improvement of this patch:

Before:
 Ethtool(mlx5p2  ) stat:      7246630 (      7,246,630) <= rx3_packets /sec
After:
 Ethtool(mlx5p2  ) stat:      9182886 (      9,182,886) <= rx3_packets /sec
Improvement:
 (1/9182886-1/7246630)*10^9 = saving -29.0 ns

The benchmark is a single pktgen flow, which is RPS directed to
another CPU, for further processing via process_backlog().  The
remote CPU cannot handle the load and this CPU drops packets when
it cannot get them enqueued.
---
 include/linux/netdevice.h |   10 +++
 net/core/dev.c            |  133 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 140 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 11df9af41a3c..dc5baef95d27 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -633,6 +633,15 @@ struct rps_dev_flow {
 };
 #define RPS_NO_FILTER 0xffff
 
+struct rps_cpu_queue {
+	struct sk_buff_head skb_list;
+	int to_cpu;
+	struct rps_dev_flow *rflow;
+	struct net_device *dev;
+};
+#define RPS_CPU_QUEUES		2 /* Must be power of 2 */
+#define RPS_CPU_QUEUES_MASK	(RPS_CPU_QUEUES - 1)
+
 /*
  * The rps_dev_flow_table structure contains a table of flow mappings.
  */
@@ -2662,6 +2671,7 @@ struct softnet_data {
 	unsigned int		received_rps;
 #ifdef CONFIG_RPS
 	struct softnet_data	*rps_ipi_list;
+	struct rps_cpu_queue	local_rps_queue[RPS_CPU_QUEUES];
 #endif
 #ifdef CONFIG_NET_FLOW_LIMIT
 	struct sd_flow_limit __rcu *flow_limit;
diff --git a/net/core/dev.c b/net/core/dev.c
index 35c92a968937..0a231529bc0c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3736,6 +3736,60 @@ drop:
 	return NET_RX_DROP;
 }
 
+static int enqueue_list_to_backlog(struct sk_buff_head *skb_list, int cpu,
+				   unsigned int *qtail, struct net_device *dev)
+{
+       unsigned int qlen, qlen_drop;
+       struct softnet_data *sd;
+       struct sk_buff *skb;
+       unsigned long flags;
+
+       sd = &per_cpu(softnet_data, cpu);
+
+       local_irq_save(flags);
+
+       rps_lock(sd);
+       if (!netif_running(dev))
+               goto drop;
+       qlen = skb_queue_len(&sd->input_pkt_queue);
+       /* NOTICE: Had to drop !skb_flow_limit(skb, qlen) check here */
+       if (qlen <= netdev_max_backlog) {
+               if (qlen) {
+enqueue:
+                       //__skb_queue_tail(&sd->input_pkt_queue, skb);
+                       skb_queue_splice_tail_init(skb_list,
+                                                  &sd->input_pkt_queue);
+                       input_queue_tail_incr_save(sd, qtail);
+                       rps_unlock(sd);
+                       local_irq_restore(flags);
+                       return NET_RX_SUCCESS;
+               }
+
+               /* Schedule NAPI for backlog device
+                * We can use non atomic operation since we own the queue lock
+                */
+               if (!__test_and_set_bit(NAPI_STATE_SCHED, &sd->backlog.state)) {
+                       if (!rps_ipi_queued(sd))
+                               ____napi_schedule(sd, &sd->backlog);
+               }
+               goto enqueue;
+       }
+
+drop:
+       qlen_drop = skb_queue_len(skb_list);
+       sd->dropped += qlen_drop;
+       rps_unlock(sd);
+
+       local_irq_restore(flags);
+
+       atomic_long_add(qlen_drop, &dev->rx_dropped);
+       while ((skb = __skb_dequeue(skb_list)) != NULL) {
+               __kfree_skb_defer(skb);
+       }
+       return NET_RX_DROP;
+}
+
+
 static int netif_rx_internal(struct sk_buff *skb)
 {
 	int ret;
@@ -4211,14 +4265,43 @@ static int netif_receive_skb_internal(struct sk_buff *skb)
 #ifdef CONFIG_RPS
 	if (static_key_false(&rps_needed)) {
 		struct rps_dev_flow voidflow, *rflow = &voidflow;
+		struct softnet_data *sd = this_cpu_ptr(&softnet_data);
+		struct rps_cpu_queue *lq; /* softnet cpu local queue (lq) */
+
 		int cpu = get_rps_cpu(skb->dev, skb, &rflow);
+		if (cpu < 0)
+			goto no_rps;
+
+		/* RPS destinated packet */
+		// XXX: is local_irq_disable needed here?
+		sd = this_cpu_ptr(&softnet_data);
+		lq = &sd->local_rps_queue[cpu & RPS_CPU_QUEUES_MASK];
 
-		if (cpu >= 0) {
-			ret = enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
+		if (lq->to_cpu == cpu && lq->dev == skb->dev) {
+			/* Bonus, RPS dest match prev CPU, q pkt for later */
+			__skb_queue_tail(&lq->skb_list, skb);
+			lq->rflow = rflow;
 			rcu_read_unlock();
-			return ret;
+			return NET_RX_SUCCESS;
 		}
+		if (unlikely(lq->to_cpu < 0))
+			goto init_localq;
+
+		/* No match, bulk enq to remote cpu backlog */
+		ret = enqueue_list_to_backlog(&lq->skb_list, lq->to_cpu,
+					      &lq->rflow->last_qtail, lq->dev);
+	init_localq: /* start new localq (lq) */
+		/* XXX: check if lq->skb_list was already re-init'ed */
+		skb_queue_head_init(&lq->skb_list);
+		__skb_queue_tail(&lq->skb_list, skb);
+		lq->rflow = rflow;
+		lq->to_cpu = cpu;
+		lq->dev = skb->dev;
+
+		rcu_read_unlock();
+		return ret;
 	}
+no_rps:
 #endif
 	ret = __netif_receive_skb(skb);
 	rcu_read_unlock();
@@ -4579,6 +4662,30 @@ gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(napi_gro_receive);
 
+static void rps_flush_local_queues(struct softnet_data *sd)
+{
+#ifdef CONFIG_RPS
+	int i;
+
+//	local_irq_disable(); //TEST
+//	if (!sd)
+	sd = this_cpu_ptr(&softnet_data);
+
+	/* Bulk flush any remaining locally queued packets for RPS */
+	for (i = 0; i < RPS_CPU_QUEUES; i++) {
+		struct rps_cpu_queue *lq = &sd->local_rps_queue[i];
+
+		if (skb_queue_empty(&lq->skb_list))
+			continue;
+
+		enqueue_list_to_backlog(&lq->skb_list, lq->to_cpu,
+					&lq->rflow->last_qtail, lq->dev);
+		// FAILS: lq->to_cpu = -1;
+	}
+//	local_irq_enable(); //TEST
+#endif
+}
+
 void napi_gro_receive_list(struct napi_struct *napi,
 			   struct sk_buff_head *skb_list,
 			   struct net_device *netdev)
@@ -4594,6 +4701,10 @@ void napi_gro_receive_list(struct napi_struct *napi,
 		skb_gro_reset_offset(skb);
 		napi_skb_finish(dev_gro_receive(napi, skb), skb);
 	}
+#ifdef CONFIG_RPS
+//	if (static_key_false(&rps_needed))
+//		rps_flush_local_queues(NULL);
+#endif
 }
 EXPORT_SYMBOL(napi_gro_receive_list);
 
@@ -4747,6 +4858,8 @@ static void net_rps_action_and_irq_enable(struct softnet_data *sd)
 
 		local_irq_enable();
 
+//		rps_flush_local_queues(NULL);
+
 		/* Send pending IPI's to kick RPS processing on remote cpus. */
 		while (remsd) {
 			struct softnet_data *next = remsd->rps_ipi_next;
@@ -5176,6 +5289,8 @@ static void net_rx_action(struct softirq_action *h)
 	__kfree_skb_flush();
 	local_irq_disable();
 
+        rps_flush_local_queues(NULL);
+
 	list_splice_tail_init(&sd->poll_list, &list);
 	list_splice_tail(&repoll, &list);
 	list_splice(&list, &sd->poll_list);
@@ -8085,6 +8200,9 @@ static int __init net_dev_init(void)
 
 	for_each_possible_cpu(i) {
 		struct softnet_data *sd = &per_cpu(softnet_data, i);
+#ifdef CONFIG_RPS
+		int j;
+#endif
 
 		skb_queue_head_init(&sd->input_pkt_queue);
 		skb_queue_head_init(&sd->process_queue);
@@ -8094,6 +8212,15 @@ static int __init net_dev_init(void)
 		sd->csd.func = rps_trigger_softirq;
 		sd->csd.info = sd;
 		sd->cpu = i;
+		for (j = 0; j < RPS_CPU_QUEUES; j++) {
+			struct rps_cpu_queue *lq = &sd->local_rps_queue[j];
+
+			skb_queue_head_init(&lq->skb_list);
+			lq->to_cpu = -1;
+			// XXX: below not needed
+			lq->rflow = NULL;
+			lq->dev = NULL;
+		}
 #endif
 
 		sd->backlog.poll = process_backlog;
