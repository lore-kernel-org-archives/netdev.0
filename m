From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] rps: cleanups
Date: Tue, 20 Apr 2010 09:17:14 +0200
Message-ID: <1271747834.3845.206.camel@edumazet-laptop>
References: <1271683627.3845.44.camel@edumazet-laptop>
	 <1271686957.3845.49.camel@edumazet-laptop>
	 <1271689653.3845.73.camel@edumazet-laptop>
	 <20100419.132158.143863746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:44990 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718Ab0DTHRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 03:17:22 -0400
Received: by bwz19 with SMTP id 19so7189bwz.21
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 00:17:20 -0700 (PDT)
In-Reply-To: <20100419.132158.143863746.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 avril 2010 =C3=A0 13:21 -0700, David Miller a =C3=A9crit :

>=20
> It is getting increasingly complicated to follow who enables and
> disabled local cpu irqs in these code paths.  We could combat
> this by adding something like "_irq_enable()" to the function
> names.

Yes I agree, we need a general cleanup in this file

Thanks David !

[PATCH net-next-2.6] rps: cleanups

struct softnet_data holds many queues, so consistent use "sd" name
instead of "queue" is better.

Adds a rps_ipi_queued() helper to cleanup enqueue_to_backlog()

Adds a _and_irq_disable suffix to net_rps_action() name, as David
suggested.

incr_input_queue_head() becomes input_queue_head_incr()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    4=20
 net/core/dev.c            |  149 +++++++++++++++++++-----------------
 2 files changed, 82 insertions(+), 71 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 83ab3da..3c5ed5f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1401,10 +1401,10 @@ struct softnet_data {
 	struct napi_struct	backlog;
 };
=20
-static inline void incr_input_queue_head(struct softnet_data *queue)
+static inline void input_queue_head_incr(struct softnet_data *sd)
 {
 #ifdef CONFIG_RPS
-	queue->input_queue_head++;
+	sd->input_queue_head++;
 #endif
 }
=20
diff --git a/net/core/dev.c b/net/core/dev.c
index 05a2b29..70df048 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -208,17 +208,17 @@ static inline struct hlist_head *dev_index_hash(s=
truct net *net, int ifindex)
 	return &net->dev_index_head[ifindex & (NETDEV_HASHENTRIES - 1)];
 }
=20
-static inline void rps_lock(struct softnet_data *queue)
+static inline void rps_lock(struct softnet_data *sd)
 {
 #ifdef CONFIG_RPS
-	spin_lock(&queue->input_pkt_queue.lock);
+	spin_lock(&sd->input_pkt_queue.lock);
 #endif
 }
=20
-static inline void rps_unlock(struct softnet_data *queue)
+static inline void rps_unlock(struct softnet_data *sd)
 {
 #ifdef CONFIG_RPS
-	spin_unlock(&queue->input_pkt_queue.lock);
+	spin_unlock(&sd->input_pkt_queue.lock);
 #endif
 }
=20
@@ -2346,63 +2346,74 @@ done:
 }
=20
 /* Called from hardirq (IPI) context */
-static void trigger_softirq(void *data)
+static void rps_trigger_softirq(void *data)
 {
-	struct softnet_data *queue =3D data;
-	__napi_schedule(&queue->backlog);
+	struct softnet_data *sd =3D data;
+
+	__napi_schedule(&sd->backlog);
 	__get_cpu_var(netdev_rx_stat).received_rps++;
 }
+
 #endif /* CONFIG_RPS */
=20
 /*
+ * Check if this softnet_data structure is another cpu one
+ * If yes, queue it to our IPI list and return 1
+ * If no, return 0
+ */
+static int rps_ipi_queued(struct softnet_data *sd)
+{
+#ifdef CONFIG_RPS
+	struct softnet_data *mysd =3D &__get_cpu_var(softnet_data);
+
+	if (sd !=3D mysd) {
+		sd->rps_ipi_next =3D mysd->rps_ipi_list;
+		mysd->rps_ipi_list =3D sd;
+
+		__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+		return 1;
+	}
+#endif /* CONFIG_RPS */
+	return 0;
+}
+
+/*
  * enqueue_to_backlog is called to queue an skb to a per CPU backlog
  * queue (may be a remote CPU queue).
  */
 static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
 			      unsigned int *qtail)
 {
-	struct softnet_data *queue;
+	struct softnet_data *sd;
 	unsigned long flags;
=20
-	queue =3D &per_cpu(softnet_data, cpu);
+	sd =3D &per_cpu(softnet_data, cpu);
=20
 	local_irq_save(flags);
 	__get_cpu_var(netdev_rx_stat).total++;
=20
-	rps_lock(queue);
-	if (queue->input_pkt_queue.qlen <=3D netdev_max_backlog) {
-		if (queue->input_pkt_queue.qlen) {
+	rps_lock(sd);
+	if (sd->input_pkt_queue.qlen <=3D netdev_max_backlog) {
+		if (sd->input_pkt_queue.qlen) {
 enqueue:
-			__skb_queue_tail(&queue->input_pkt_queue, skb);
+			__skb_queue_tail(&sd->input_pkt_queue, skb);
 #ifdef CONFIG_RPS
-			*qtail =3D queue->input_queue_head +
-			    queue->input_pkt_queue.qlen;
+			*qtail =3D sd->input_queue_head + sd->input_pkt_queue.qlen;
 #endif
-			rps_unlock(queue);
+			rps_unlock(sd);
 			local_irq_restore(flags);
 			return NET_RX_SUCCESS;
 		}
=20
 		/* Schedule NAPI for backlog device */
-		if (napi_schedule_prep(&queue->backlog)) {
-#ifdef CONFIG_RPS
-			if (cpu !=3D smp_processor_id()) {
-				struct softnet_data *myqueue;
-
-				myqueue =3D &__get_cpu_var(softnet_data);
-				queue->rps_ipi_next =3D myqueue->rps_ipi_list;
-				myqueue->rps_ipi_list =3D queue;
-
-				__raise_softirq_irqoff(NET_RX_SOFTIRQ);
-				goto enqueue;
-			}
-#endif
-			__napi_schedule(&queue->backlog);
+		if (napi_schedule_prep(&sd->backlog)) {
+			if (!rps_ipi_queued(sd))
+				__napi_schedule(&sd->backlog);
 		}
 		goto enqueue;
 	}
=20
-	rps_unlock(queue);
+	rps_unlock(sd);
=20
 	__get_cpu_var(netdev_rx_stat).dropped++;
 	local_irq_restore(flags);
@@ -2903,17 +2914,17 @@ EXPORT_SYMBOL(netif_receive_skb);
 static void flush_backlog(void *arg)
 {
 	struct net_device *dev =3D arg;
-	struct softnet_data *queue =3D &__get_cpu_var(softnet_data);
+	struct softnet_data *sd =3D &__get_cpu_var(softnet_data);
 	struct sk_buff *skb, *tmp;
=20
-	rps_lock(queue);
-	skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
+	rps_lock(sd);
+	skb_queue_walk_safe(&sd->input_pkt_queue, skb, tmp)
 		if (skb->dev =3D=3D dev) {
-			__skb_unlink(skb, &queue->input_pkt_queue);
+			__skb_unlink(skb, &sd->input_pkt_queue);
 			kfree_skb(skb);
-			incr_input_queue_head(queue);
+			input_queue_head_incr(sd);
 		}
-	rps_unlock(queue);
+	rps_unlock(sd);
 }
=20
 static int napi_gro_complete(struct sk_buff *skb)
@@ -3219,23 +3230,23 @@ EXPORT_SYMBOL(napi_gro_frags);
 static int process_backlog(struct napi_struct *napi, int quota)
 {
 	int work =3D 0;
-	struct softnet_data *queue =3D &__get_cpu_var(softnet_data);
+	struct softnet_data *sd =3D &__get_cpu_var(softnet_data);
=20
 	napi->weight =3D weight_p;
 	do {
 		struct sk_buff *skb;
=20
 		local_irq_disable();
-		rps_lock(queue);
-		skb =3D __skb_dequeue(&queue->input_pkt_queue);
+		rps_lock(sd);
+		skb =3D __skb_dequeue(&sd->input_pkt_queue);
 		if (!skb) {
 			__napi_complete(napi);
-			rps_unlock(queue);
+			rps_unlock(sd);
 			local_irq_enable();
 			break;
 		}
-		incr_input_queue_head(queue);
-		rps_unlock(queue);
+		input_queue_head_incr(sd);
+		rps_unlock(sd);
 		local_irq_enable();
=20
 		__netif_receive_skb(skb);
@@ -3331,24 +3342,25 @@ EXPORT_SYMBOL(netif_napi_del);
  * net_rps_action sends any pending IPI's for rps.
  * Note: called with local irq disabled, but exits with local irq enab=
led.
  */
-static void net_rps_action(void)
+static void net_rps_action_and_irq_disable(void)
 {
 #ifdef CONFIG_RPS
-	struct softnet_data *locqueue =3D &__get_cpu_var(softnet_data);
-	struct softnet_data *remqueue =3D locqueue->rps_ipi_list;
+	struct softnet_data *sd =3D &__get_cpu_var(softnet_data);
+	struct softnet_data *remsd =3D sd->rps_ipi_list;
=20
-	if (remqueue) {
-		locqueue->rps_ipi_list =3D NULL;
+	if (remsd) {
+		sd->rps_ipi_list =3D NULL;
=20
 		local_irq_enable();
=20
 		/* Send pending IPI's to kick RPS processing on remote cpus. */
-		while (remqueue) {
-			struct softnet_data *next =3D remqueue->rps_ipi_next;
-			if (cpu_online(remqueue->cpu))
-				__smp_call_function_single(remqueue->cpu,
-							   &remqueue->csd, 0);
-			remqueue =3D next;
+		while (remsd) {
+			struct softnet_data *next =3D remsd->rps_ipi_next;
+
+			if (cpu_online(remsd->cpu))
+				__smp_call_function_single(remsd->cpu,
+							   &remsd->csd, 0);
+			remsd =3D next;
 		}
 	} else
 #endif
@@ -3423,7 +3435,7 @@ static void net_rx_action(struct softirq_action *=
h)
 		netpoll_poll_unlock(have);
 	}
 out:
-	net_rps_action();
+	net_rps_action_and_irq_disable();
=20
 #ifdef CONFIG_NET_DMA
 	/*
@@ -5595,7 +5607,7 @@ static int dev_cpu_callback(struct notifier_block=
 *nfb,
 	/* Process offline CPU's input_pkt_queue */
 	while ((skb =3D __skb_dequeue(&oldsd->input_pkt_queue))) {
 		netif_rx(skb);
-		incr_input_queue_head(oldsd);
+		input_queue_head_incr(oldsd);
 	}
=20
 	return NOTIFY_OK;
@@ -5812,24 +5824,23 @@ static int __init net_dev_init(void)
 	 */
=20
 	for_each_possible_cpu(i) {
-		struct softnet_data *queue;
+		struct softnet_data *sd =3D &per_cpu(softnet_data, i);
=20
-		queue =3D &per_cpu(softnet_data, i);
-		skb_queue_head_init(&queue->input_pkt_queue);
-		queue->completion_queue =3D NULL;
-		INIT_LIST_HEAD(&queue->poll_list);
+		skb_queue_head_init(&sd->input_pkt_queue);
+		sd->completion_queue =3D NULL;
+		INIT_LIST_HEAD(&sd->poll_list);
=20
 #ifdef CONFIG_RPS
-		queue->csd.func =3D trigger_softirq;
-		queue->csd.info =3D queue;
-		queue->csd.flags =3D 0;
-		queue->cpu =3D i;
+		sd->csd.func =3D rps_trigger_softirq;
+		sd->csd.info =3D sd;
+		sd->csd.flags =3D 0;
+		sd->cpu =3D i;
 #endif
=20
-		queue->backlog.poll =3D process_backlog;
-		queue->backlog.weight =3D weight_p;
-		queue->backlog.gro_list =3D NULL;
-		queue->backlog.gro_count =3D 0;
+		sd->backlog.poll =3D process_backlog;
+		sd->backlog.weight =3D weight_p;
+		sd->backlog.gro_list =3D NULL;
+		sd->backlog.gro_count =3D 0;
 	}
=20
 	dev_boot_phase =3D 0;


