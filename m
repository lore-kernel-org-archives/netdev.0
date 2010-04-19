From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] rps: shortcut net_rps_action()
Date: Mon, 19 Apr 2010 11:37:02 +0200
Message-ID: <1271669822.16881.7520.camel@edumazet-laptop>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi>  <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <1271489739.16881.4586.camel@edumazet-laptop>
	 <1271525519.3929.3.camel@bigi>
	 <1271583573.16881.4798.camel@edumazet-laptop>
	 <1271590476.16881.4925.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:47560 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075Ab0DSJhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 05:37:15 -0400
Received: by bwz25 with SMTP id 25so5262986bwz.28
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 02:37:13 -0700 (PDT)
In-Reply-To: <1271590476.16881.4925.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net_rps_action() is a bit expensive on NR_CPUS=64..4096 kernels, even if
RPS is not active.

I add a flag to scan cpumask only if at least one IPI was scheduled.
Even cpumask_weight() might be expensive on some setups, where
nr_cpumask_bits could be very big (4096 for example)

Move all RPS logic into net_rps_action() to cleanup net_rx_action() code
(remove two ifdefs)

Move rps_remote_softirq_cpus into softnet_data to share its first cache
line, filling an existing hole.

In a future patch, we could call net_rps_action() from process_backlog()
to make sure we send IPI before handling this cpu backlog.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    5 +-
 net/core/dev.c            |   73 ++++++++++++++++--------------------
 2 files changed, 38 insertions(+), 40 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 649a025..283d3ef 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1389,8 +1389,11 @@ struct softnet_data {
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
 
-	/* Elements below can be accessed between CPUs for RPS */
 #ifdef CONFIG_RPS
+	unsigned int		rps_ipis_scheduled;
+	unsigned int		rps_select;
+	cpumask_t		rps_mask[2];
+	/* Elements below can be accessed between CPUs for RPS */
 	struct call_single_data	csd ____cacheline_aligned_in_smp;
 	unsigned int		input_queue_head;
 #endif
diff --git a/net/core/dev.c b/net/core/dev.c
index 7abf959..3e6e420 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2347,19 +2347,14 @@ done:
 }
 
 /*
- * This structure holds the per-CPU mask of CPUs for which IPIs are scheduled
+ * sofnet_data holds the per-CPU mask of CPUs for which IPIs are scheduled
  * to be sent to kick remote softirq processing.  There are two masks since
- * the sending of IPIs must be done with interrupts enabled.  The select field
+ * the sending of IPIs must be done with interrupts enabled.  The rps_select field
  * indicates the current mask that enqueue_backlog uses to schedule IPIs.
  * select is flipped before net_rps_action is called while still under lock,
  * net_rps_action then uses the non-selected mask to send the IPIs and clears
  * it without conflicting with enqueue_backlog operation.
  */
-struct rps_remote_softirq_cpus {
-	cpumask_t mask[2];
-	int select;
-};
-static DEFINE_PER_CPU(struct rps_remote_softirq_cpus, rps_remote_softirq_cpus);
 
 /* Called from hardirq (IPI) context */
 static void trigger_softirq(void *data)
@@ -2403,10 +2398,10 @@ enqueue:
 		if (napi_schedule_prep(&queue->backlog)) {
 #ifdef CONFIG_RPS
 			if (cpu != smp_processor_id()) {
-				struct rps_remote_softirq_cpus *rcpus =
-				    &__get_cpu_var(rps_remote_softirq_cpus);
+				struct softnet_data *myqueue = &__get_cpu_var(softnet_data);
 
-				cpu_set(cpu, rcpus->mask[rcpus->select]);
+				cpu_set(cpu, myqueue->rps_mask[myqueue->rps_select]);
+				myqueue->rps_ipis_scheduled = 1;
 				__raise_softirq_irqoff(NET_RX_SOFTIRQ);
 				goto enqueue;
 			}
@@ -2911,7 +2906,9 @@ int netif_receive_skb(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(netif_receive_skb);
 
-/* Network device is going away, flush any packets still pending  */
+/* Network device is going away, flush any packets still pending
+ * Called with irqs disabled.
+ */
 static void flush_backlog(void *arg)
 {
 	struct net_device *dev = arg;
@@ -3340,24 +3337,36 @@ void netif_napi_del(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(netif_napi_del);
 
-#ifdef CONFIG_RPS
 /*
- * net_rps_action sends any pending IPI's for rps.  This is only called from
- * softirq and interrupts must be enabled.
+ * net_rps_action sends any pending IPI's for rps.
+ * Note: called with local irq disabled, but exits with local irq enabled.
  */
-static void net_rps_action(cpumask_t *mask)
+static void net_rps_action(void)
 {
-	int cpu;
+#ifdef CONFIG_RPS
+	if (percpu_read(softnet_data.rps_ipis_scheduled)) {
+		struct softnet_data *queue = &__get_cpu_var(softnet_data);
+		int cpu, select = queue->rps_select;
+		cpumask_t *mask;
+		
+		queue->rps_ipis_scheduled = 0;
+		queue->rps_select ^= 1;
 
-	/* Send pending IPI's to kick RPS processing on remote cpus. */
-	for_each_cpu_mask_nr(cpu, *mask) {
-		struct softnet_data *queue = &per_cpu(softnet_data, cpu);
-		if (cpu_online(cpu))
-			__smp_call_function_single(cpu, &queue->csd, 0);
-	}
-	cpus_clear(*mask);
-}
+		local_irq_enable();
+
+		mask = &queue->rps_mask[select];
+
+		/* Send pending IPI's to kick RPS processing on remote cpus. */
+		for_each_cpu_mask_nr(cpu, *mask) {
+			struct softnet_data *remqueue = &per_cpu(softnet_data, cpu);
+			if (cpu_online(cpu))
+				__smp_call_function_single(cpu, &remqueue->csd, 0);
+		}
+		cpus_clear(*mask);
+	} else
 #endif
+		local_irq_enable();
+}
 
 static void net_rx_action(struct softirq_action *h)
 {
@@ -3365,10 +3374,6 @@ static void net_rx_action(struct softirq_action *h)
 	unsigned long time_limit = jiffies + 2;
 	int budget = netdev_budget;
 	void *have;
-#ifdef CONFIG_RPS
-	int select;
-	struct rps_remote_softirq_cpus *rcpus;
-#endif
 
 	local_irq_disable();
 
@@ -3431,17 +3436,7 @@ static void net_rx_action(struct softirq_action *h)
 		netpoll_poll_unlock(have);
 	}
 out:
-#ifdef CONFIG_RPS
-	rcpus = &__get_cpu_var(rps_remote_softirq_cpus);
-	select = rcpus->select;
-	rcpus->select ^= 1;
-
-	local_irq_enable();
-
-	net_rps_action(&rcpus->mask[select]);
-#else
-	local_irq_enable();
-#endif
+	net_rps_action();
 
 #ifdef CONFIG_NET_DMA
 	/*


