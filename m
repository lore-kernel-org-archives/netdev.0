From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] rps: shortcut net_rps_action()
Date: Mon, 19 Apr 2010 17:07:33 +0200
Message-ID: <1271689653.3845.73.camel@edumazet-laptop>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <1271489739.16881.4586.camel@edumazet-laptop>
	 <1271525519.3929.3.camel@bigi>
	 <1271583573.16881.4798.camel@edumazet-laptop>
	 <1271590476.16881.4925.camel@edumazet-laptop>
	 <1271669822.16881.7520.camel@edumazet-laptop>
	 <k2u412e6f7f1004190248s8ac633beof2475645e799f2ea@mail.gmail.com>
	 <1271679244.3845.43.camel@edumazet-laptop>
	 <p2u412e6f7f1004190528l65cc6253w8b7f43f2657b551d@mail.gmail.com>
	 <1271683627.3845.44.camel@edumazet-laptop>
	 <1271686957.3845.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:49992 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754414Ab0DSPHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 11:07:42 -0400
Received: by bwz25 with SMTP id 25so5705724bwz.28
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 08:07:40 -0700 (PDT)
In-Reply-To: <1271686957.3845.49.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 avril 2010 =C3=A0 16:22 +0200, Eric Dumazet a =C3=A9crit :

>=20
> Hmm, I just read again, and I now remember Tom used a single bitmap,
> then we had to add a second set because of a possible race.
>=20
> A list would be enough.
>=20

Here is the updated patch, using a single list instead of bitmap

RFC status becomes official patch ;)

Thanks Changli for your array suggestion !


[PATCH net-next-2.6] rps: shortcut net_rps_action()

net_rps_action() is a bit expensive on NR_CPUS=3D64..4096 kernels, even=
 if
RPS is not active.

Tom Herbert used two bitmasks to hold information needed to send IPI,
but a single LIFO list seems more appropriate.

Move all RPS logic into net_rps_action() to cleanup net_rx_action() cod=
e
(remove two ifdefs)

Move rps_remote_softirq_cpus into softnet_data to share its first cache
line, filling an existing hole.

In a future patch, we could call net_rps_action() from process_backlog(=
)
to make sure we send IPI before handling this cpu backlog.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    9 ++--
 net/core/dev.c            |   79 ++++++++++++++----------------------
 2 files changed, 38 insertions(+), 50 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 649a025..83ab3da 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1381,17 +1381,20 @@ static inline int unregister_gifconf(unsigned i=
nt family)
 }
=20
 /*
- * Incoming packets are placed on per-cpu queues so that
- * no locking is needed.
+ * Incoming packets are placed on per-cpu queues
  */
 struct softnet_data {
 	struct Qdisc		*output_queue;
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
=20
-	/* Elements below can be accessed between CPUs for RPS */
 #ifdef CONFIG_RPS
+	struct softnet_data	*rps_ipi_list;
+
+	/* Elements below can be accessed between CPUs for RPS */
 	struct call_single_data	csd ____cacheline_aligned_in_smp;
+	struct softnet_data	*rps_ipi_next;
+	unsigned int		cpu;
 	unsigned int		input_queue_head;
 #endif
 	struct sk_buff_head	input_pkt_queue;
diff --git a/net/core/dev.c b/net/core/dev.c
index 7abf959..f6ff2cf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2346,21 +2346,6 @@ done:
 	return cpu;
 }
=20
-/*
- * This structure holds the per-CPU mask of CPUs for which IPIs are sc=
heduled
- * to be sent to kick remote softirq processing.  There are two masks =
since
- * the sending of IPIs must be done with interrupts enabled.  The sele=
ct field
- * indicates the current mask that enqueue_backlog uses to schedule IP=
Is.
- * select is flipped before net_rps_action is called while still under=
 lock,
- * net_rps_action then uses the non-selected mask to send the IPIs and=
 clears
- * it without conflicting with enqueue_backlog operation.
- */
-struct rps_remote_softirq_cpus {
-	cpumask_t mask[2];
-	int select;
-};
-static DEFINE_PER_CPU(struct rps_remote_softirq_cpus, rps_remote_softi=
rq_cpus);
-
 /* Called from hardirq (IPI) context */
 static void trigger_softirq(void *data)
 {
@@ -2403,10 +2388,12 @@ enqueue:
 		if (napi_schedule_prep(&queue->backlog)) {
 #ifdef CONFIG_RPS
 			if (cpu !=3D smp_processor_id()) {
-				struct rps_remote_softirq_cpus *rcpus =3D
-				    &__get_cpu_var(rps_remote_softirq_cpus);
+				struct softnet_data *myqueue;
+
+				myqueue =3D &__get_cpu_var(softnet_data);
+				queue->rps_ipi_next =3D myqueue->rps_ipi_list;
+				myqueue->rps_ipi_list =3D queue;
=20
-				cpu_set(cpu, rcpus->mask[rcpus->select]);
 				__raise_softirq_irqoff(NET_RX_SOFTIRQ);
 				goto enqueue;
 			}
@@ -2911,7 +2898,9 @@ int netif_receive_skb(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(netif_receive_skb);
=20
-/* Network device is going away, flush any packets still pending  */
+/* Network device is going away, flush any packets still pending
+ * Called with irqs disabled.
+ */
 static void flush_backlog(void *arg)
 {
 	struct net_device *dev =3D arg;
@@ -3340,24 +3329,33 @@ void netif_napi_del(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(netif_napi_del);
=20
-#ifdef CONFIG_RPS
 /*
- * net_rps_action sends any pending IPI's for rps.  This is only calle=
d from
- * softirq and interrupts must be enabled.
+ * net_rps_action sends any pending IPI's for rps.
+ * Note: called with local irq disabled, but exits with local irq enab=
led.
  */
-static void net_rps_action(cpumask_t *mask)
+static void net_rps_action(void)
 {
-	int cpu;
+#ifdef CONFIG_RPS
+	struct softnet_data *locqueue =3D &__get_cpu_var(softnet_data);
+	struct softnet_data *remqueue =3D locqueue->rps_ipi_list;
=20
-	/* Send pending IPI's to kick RPS processing on remote cpus. */
-	for_each_cpu_mask_nr(cpu, *mask) {
-		struct softnet_data *queue =3D &per_cpu(softnet_data, cpu);
-		if (cpu_online(cpu))
-			__smp_call_function_single(cpu, &queue->csd, 0);
-	}
-	cpus_clear(*mask);
-}
+	if (remqueue) {
+		locqueue->rps_ipi_list =3D NULL;
+
+		local_irq_enable();
+
+		/* Send pending IPI's to kick RPS processing on remote cpus. */
+		while (remqueue) {
+			struct softnet_data *next =3D remqueue->rps_ipi_next;
+			if (cpu_online(remqueue->cpu))
+				__smp_call_function_single(remqueue->cpu,
+							   &remqueue->csd, 0);
+			remqueue =3D next;
+		}
+	} else
 #endif
+		local_irq_enable();
+}
=20
 static void net_rx_action(struct softirq_action *h)
 {
@@ -3365,10 +3363,6 @@ static void net_rx_action(struct softirq_action =
*h)
 	unsigned long time_limit =3D jiffies + 2;
 	int budget =3D netdev_budget;
 	void *have;
-#ifdef CONFIG_RPS
-	int select;
-	struct rps_remote_softirq_cpus *rcpus;
-#endif
=20
 	local_irq_disable();
=20
@@ -3431,17 +3425,7 @@ static void net_rx_action(struct softirq_action =
*h)
 		netpoll_poll_unlock(have);
 	}
 out:
-#ifdef CONFIG_RPS
-	rcpus =3D &__get_cpu_var(rps_remote_softirq_cpus);
-	select =3D rcpus->select;
-	rcpus->select ^=3D 1;
-
-	local_irq_enable();
-
-	net_rps_action(&rcpus->mask[select]);
-#else
-	local_irq_enable();
-#endif
+	net_rps_action();
=20
 #ifdef CONFIG_NET_DMA
 	/*
@@ -5841,6 +5825,7 @@ static int __init net_dev_init(void)
 		queue->csd.func =3D trigger_softirq;
 		queue->csd.info =3D queue;
 		queue->csd.flags =3D 0;
+		queue->cpu =3D i;
 #endif
=20
 		queue->backlog.poll =3D process_backlog;


