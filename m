From: Tom Herbert <therbert@google.com>
Subject: rps: Fix build with CONFIG_SMP disabled
Date: Thu, 18 Mar 2010 00:14:55 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1003180011580.17439@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:52108 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732Ab0CRHPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 03:15:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rps: Fixed build with CONFIG_SMP not enabled.

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index de1a52b..726ecd1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1341,7 +1341,9 @@ struct softnet_data {
 	struct sk_buff		*completion_queue;
 
 	/* Elements below can be accessed between CPUs for RPS */
+#ifdef CONFIG_SMP
 	struct call_single_data	csd ____cacheline_aligned_in_smp;
+#endif
 	struct sk_buff_head	input_pkt_queue;
 	struct napi_struct	backlog;
 };
diff --git a/net/core/dev.c b/net/core/dev.c
index 17b1686..1a7e1d1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2174,6 +2174,7 @@ int weight_p __read_mostly = 64;            /* old backlog weight */
 
 DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
 
+#ifdef CONFIG_SMP
 /*
  * get_rps_cpu is called from netif_receive_skb and returns the target
  * CPU from the RPS map of the receiving queue for a given skb.
@@ -2293,6 +2294,7 @@ static void trigger_softirq(void *data)
 	__napi_schedule(&queue->backlog);
 	__get_cpu_var(netdev_rx_stat).received_rps++;
 }
+#endif /* CONFIG_SMP */
 
 /*
  * enqueue_to_backlog is called to queue an skb to a per CPU backlog
@@ -2320,6 +2322,7 @@ enqueue:
 
 		/* Schedule NAPI for backlog device */
 		if (napi_schedule_prep(&queue->backlog)) {
+#ifdef CONFIG_SMP
 			if (cpu != smp_processor_id()) {
 				struct rps_remote_softirq_cpus *rcpus =
 				    &__get_cpu_var(rps_remote_softirq_cpus);
@@ -2328,6 +2331,9 @@ enqueue:
 				__raise_softirq_irqoff(NET_RX_SOFTIRQ);
 			} else
 				__napi_schedule(&queue->backlog);
+#else
+			__napi_schedule(&queue->backlog);
+#endif
 		}
 		goto enqueue;
 	}
@@ -2367,9 +2373,13 @@ int netif_rx(struct sk_buff *skb)
 	if (!skb->tstamp.tv64)
 		net_timestamp(skb);
 
+#ifdef CONFIG_SMP
 	cpu = get_rps_cpu(skb->dev, skb);
 	if (cpu < 0)
 		cpu = smp_processor_id();
+#else
+	cpu = smp_processor_id();
+#endif
 
 	return enqueue_to_backlog(skb, cpu);
 }
@@ -2735,6 +2745,7 @@ out:
  */
 int netif_receive_skb(struct sk_buff *skb)
 {
+#ifdef CONFIG_SMP
 	int cpu;
 
 	cpu = get_rps_cpu(skb->dev, skb);
@@ -2743,6 +2754,9 @@ int netif_receive_skb(struct sk_buff *skb)
 		return __netif_receive_skb(skb);
 	else
 		return enqueue_to_backlog(skb, cpu);
+#else
+	return __netif_receive_skb(skb);
+#endif
 }
 EXPORT_SYMBOL(netif_receive_skb);
 
@@ -3168,6 +3182,7 @@ void netif_napi_del(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(netif_napi_del);
 
+#ifdef CONFIG_SMP
 /*
  * net_rps_action sends any pending IPI's for rps.  This is only called from
  * softirq and interrupts must be enabled.
@@ -3184,6 +3199,7 @@ static void net_rps_action(cpumask_t *mask)
 	}
 	cpus_clear(*mask);
 }
+#endif
 
 static void net_rx_action(struct softirq_action *h)
 {
@@ -3191,8 +3207,10 @@ static void net_rx_action(struct softirq_action *h)
 	unsigned long time_limit = jiffies + 2;
 	int budget = netdev_budget;
 	void *have;
+#ifdef CONFIG_SMP
 	int select;
 	struct rps_remote_softirq_cpus *rcpus;
+#endif
 
 	local_irq_disable();
 
@@ -3255,6 +3273,7 @@ static void net_rx_action(struct softirq_action *h)
 		netpoll_poll_unlock(have);
 	}
 out:
+#ifdef CONFIG_SMP
 	rcpus = &__get_cpu_var(rps_remote_softirq_cpus);
 	select = rcpus->select;
 	rcpus->select ^= 1;
@@ -3262,6 +3281,9 @@ out:
 	local_irq_enable();
 
 	net_rps_action(&rcpus->mask[select]);
+#else
+	local_irq_enable();
+#endif
 
 #ifdef CONFIG_NET_DMA
 	/*
@@ -6204,9 +6226,11 @@ static int __init net_dev_init(void)
 		queue->completion_queue = NULL;
 		INIT_LIST_HEAD(&queue->poll_list);
 
+#ifdef CONFIG_SMP
 		queue->csd.func = trigger_softirq;
 		queue->csd.info = queue;
 		queue->csd.flags = 0;
+#endif
 
 		queue->backlog.poll = process_backlog;
 		queue->backlog.weight = weight_p;
