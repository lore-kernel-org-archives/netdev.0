From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netif_rx: receive path optimization
Date: Wed, 30 Mar 2005 13:28:15 -0800
Message-ID: <20050330132815.605c17d0@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch cleans up the netif_rx and related code in the network
receive core.

     - Eliminate vestiges of fastroute.
       The leftover statistics no longer needed.

     - Get rid of high/med/low threshold return from netif_rx.
       Drivers rarely check return value of netif_rx, and those
       that do can handle the DROP vs SUCCESS return

     - Remove dead code for RAND_LINE and OFFLINE_SAMPLE

     - Get rid of weight_p since setting sysctl has no effect.
       Increase default weight of netif_rx path because it can receive
       packets from multiple devices and loopback.

     - Separate out max packets per softirq vs. max queued packets.
       Today, netdev_max_burst is used for both. Add new parameter
       that is for the per-cpu max queued packets.

     - Increase queue defaults to meet modern CPU speeds.
       Make max_backlog be about 1ms, and max_queue be about 10ms

     - Switch to pure drop tail when queue fills.
       Better for TCP performance under load to drop a few packets
       then go into full discard mode.

This needs more testing on range of hardware before possible inclusion
in 2.6.13. Will split out to finer grain patches then.

diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	2005-03-30 13:17:14 -08:00
+++ b/include/linux/netdevice.h	2005-03-30 13:17:14 -08:00
@@ -164,12 +164,6 @@
 	unsigned total;
 	unsigned dropped;
 	unsigned time_squeeze;
-	unsigned throttled;
-	unsigned fastroute_hit;
-	unsigned fastroute_success;
-	unsigned fastroute_defer;
-	unsigned fastroute_deferred_out;
-	unsigned fastroute_latency_reduction;
 	unsigned cpu_collision;
 };
 
diff -Nru a/include/linux/sysctl.h b/include/linux/sysctl.h
--- a/include/linux/sysctl.h	2005-03-30 13:17:14 -08:00
+++ b/include/linux/sysctl.h	2005-03-30 13:17:14 -08:00
@@ -242,6 +242,7 @@
 	NET_CORE_MOD_CONG=16,
 	NET_CORE_DEV_WEIGHT=17,
 	NET_CORE_SOMAXCONN=18,
+	NET_CORE_MAX_QUEUE=19,
 };
 
 /* /proc/sys/net/ethernet */
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2005-03-30 13:17:14 -08:00
+++ b/net/core/dev.c	2005-03-30 13:17:14 -08:00
@@ -115,18 +115,6 @@
 #endif	/* CONFIG_NET_RADIO */
 #include <asm/current.h>
 
-/* This define, if set, will randomly drop a packet when congestion
- * is more than moderate.  It helps fairness in the multi-interface
- * case when one of them is a hog, but it kills performance for the
- * single interface case so it is off now by default.
- */
-#undef RAND_LIE
-
-/* Setting this will sample the queue lengths and thus congestion
- * via a timer instead of as each packet is received.
- */
-#undef OFFLINE_SAMPLE
-
 /*
  *	The list of packet types we will receive (as opposed to discard)
  *	and the routines to invoke.
@@ -159,11 +147,6 @@
 static struct list_head ptype_base[16];	/* 16 way hashed list */
 static struct list_head ptype_all;		/* Taps */
 
-#ifdef OFFLINE_SAMPLE
-static void sample_queue(unsigned long dummy);
-static struct timer_list samp_timer = TIMER_INITIALIZER(sample_queue, 0, 0);
-#endif
-
 /*
  * The @dev_base list is protected by @dev_base_lock and the rtln
  * semaphore.
@@ -215,7 +198,7 @@
  *	Device drivers call our routines to queue packets here. We empty the
  *	queue in the local softnet handler.
  */
-DEFINE_PER_CPU(struct softnet_data, softnet_data) = { 0, };
+DEFINE_PER_CPU(struct softnet_data, softnet_data);
 
 #ifdef CONFIG_SYSFS
 extern int netdev_sysfs_init(void);
@@ -1338,70 +1321,11 @@
 			Receiver routines
   =======================================================================*/
 
-int netdev_max_backlog = 300;
-int weight_p = 64;            /* old backlog weight */
-/* These numbers are selected based on intuition and some
- * experimentatiom, if you have more scientific way of doing this
- * please go ahead and fix things.
- */
-int no_cong_thresh = 10;
-int no_cong = 20;
-int lo_cong = 100;
-int mod_cong = 290;
-
-DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
-
-
-static void get_sample_stats(int cpu)
-{
-#ifdef RAND_LIE
-	unsigned long rd;
-	int rq;
-#endif
-	struct softnet_data *sd = &per_cpu(softnet_data, cpu);
-	int blog = sd->input_pkt_queue.qlen;
-	int avg_blog = sd->avg_blog;
-
-	avg_blog = (avg_blog >> 1) + (blog >> 1);
-
-	if (avg_blog > mod_cong) {
-		/* Above moderate congestion levels. */
-		sd->cng_level = NET_RX_CN_HIGH;
-#ifdef RAND_LIE
-		rd = net_random();
-		rq = rd % netdev_max_backlog;
-		if (rq < avg_blog) /* unlucky bastard */
-			sd->cng_level = NET_RX_DROP;
-#endif
-	} else if (avg_blog > lo_cong) {
-		sd->cng_level = NET_RX_CN_MOD;
-#ifdef RAND_LIE
-		rd = net_random();
-		rq = rd % netdev_max_backlog;
-			if (rq < avg_blog) /* unlucky bastard */
-				sd->cng_level = NET_RX_CN_HIGH;
-#endif
-	} else if (avg_blog > no_cong)
-		sd->cng_level = NET_RX_CN_LOW;
-	else  /* no congestion */
-		sd->cng_level = NET_RX_SUCCESS;
-
-	sd->avg_blog = avg_blog;
-}
-
-#ifdef OFFLINE_SAMPLE
-static void sample_queue(unsigned long dummy)
-{
-/* 10 ms 0r 1ms -- i don't care -- JHS */
-	int next_tick = 1;
-	int cpu = smp_processor_id();
-
-	get_sample_stats(cpu);
-	next_tick += jiffies;
-	mod_timer(&samp_timer, next_tick);
-}
-#endif
+/* Reasonablly fast CPU can process 1 packet per us */
+int netdev_max_backlog = 1000;
+int netdev_max_queue   = 10000;
 
+DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat);
 
 /**
  *	netif_rx	-	post buffer to the network code
@@ -1414,16 +1338,12 @@
  *
  *	return values:
  *	NET_RX_SUCCESS	(no congestion)
- *	NET_RX_CN_LOW   (low congestion)
- *	NET_RX_CN_MOD   (moderate congestion)
- *	NET_RX_CN_HIGH  (high congestion)
  *	NET_RX_DROP     (packet was dropped)
  *
  */
 
 int netif_rx(struct sk_buff *skb)
 {
-	int this_cpu;
 	struct softnet_data *queue;
 	unsigned long flags;
 
@@ -1439,43 +1359,25 @@
 	 * short when CPU is congested, but is still operating.
 	 */
 	local_irq_save(flags);
-	this_cpu = smp_processor_id();
 	queue = &__get_cpu_var(softnet_data);
 
 	__get_cpu_var(netdev_rx_stat).total++;
-	if (queue->input_pkt_queue.qlen <= netdev_max_backlog) {
-		if (queue->input_pkt_queue.qlen) {
-			if (queue->throttle)
-				goto drop;
-
-enqueue:
-			dev_hold(skb->dev);
-			__skb_queue_tail(&queue->input_pkt_queue, skb);
-#ifndef OFFLINE_SAMPLE
-			get_sample_stats(this_cpu);
-#endif
-			local_irq_restore(flags);
-			return queue->cng_level;
-		}
+	if (likely(queue->input_pkt_queue.qlen <= netdev_max_queue)) {
+		if (unlikely(queue->input_pkt_queue.qlen == 0))
+			netif_rx_schedule(&queue->backlog_dev);
+
+		dev_hold(skb->dev);
+		__skb_queue_tail(&queue->input_pkt_queue, skb);
+		local_irq_restore(flags);
 
-		if (queue->throttle)
-			queue->throttle = 0;
-
-		netif_rx_schedule(&queue->backlog_dev);
-		goto enqueue;
-	}
+		return NET_RX_SUCCESS;
+	} else {
+		__get_cpu_var(netdev_rx_stat).dropped++;
+		local_irq_restore(flags);
 
-	if (!queue->throttle) {
-		queue->throttle = 1;
-		__get_cpu_var(netdev_rx_stat).throttled++;
+		kfree_skb(skb);
+		return NET_RX_DROP;
 	}
-
-drop:
-	__get_cpu_var(netdev_rx_stat).dropped++;
-	local_irq_restore(flags);
-
-	kfree_skb(skb);
-	return NET_RX_DROP;
 }
 
 int netif_rx_ni(struct sk_buff *skb)
@@ -1754,8 +1656,6 @@
 	smp_mb__before_clear_bit();
 	netif_poll_enable(backlog_dev);
 
-	if (queue->throttle)
-		queue->throttle = 0;
 	local_irq_enable();
 	return 0;
 }
@@ -2024,20 +1924,18 @@
 {
 }
 
+/* Output softnet statistics.
+ * For compatiablity include zero's for old deprecated values
+ * for throttling and fastroute statistics.
+ */
 static int softnet_seq_show(struct seq_file *seq, void *v)
 {
 	struct netif_rx_stats *s = v;
 
 	seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
-		   s->total, s->dropped, s->time_squeeze, s->throttled,
-		   s->fastroute_hit, s->fastroute_success, s->fastroute_defer,
-		   s->fastroute_deferred_out,
-#if 0
-		   s->fastroute_latency_reduction
-#else
-		   s->cpu_collision
-#endif
-		  );
+		   s->total, s->dropped, s->time_squeeze, 
+		   0, 0, 0, 0, 0,
+		   s->cpu_collision);
 	return 0;
 }
 
@@ -3279,21 +3177,13 @@
 
 		queue = &per_cpu(softnet_data, i);
 		skb_queue_head_init(&queue->input_pkt_queue);
-		queue->throttle = 0;
-		queue->cng_level = 0;
-		queue->avg_blog = 10; /* arbitrary non-zero */
 		queue->completion_queue = NULL;
 		INIT_LIST_HEAD(&queue->poll_list);
 		set_bit(__LINK_STATE_START, &queue->backlog_dev.state);
-		queue->backlog_dev.weight = weight_p;
+		queue->backlog_dev.weight = 128;
 		queue->backlog_dev.poll = process_backlog;
 		atomic_set(&queue->backlog_dev.refcnt, 1);
 	}
-
-#ifdef OFFLINE_SAMPLE
-	samp_timer.expires = jiffies + (10 * HZ);
-	add_timer(&samp_timer);
-#endif
 
 	dev_boot_phase = 0;
 
diff -Nru a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
--- a/net/core/sysctl_net_core.c	2005-03-30 13:17:14 -08:00
+++ b/net/core/sysctl_net_core.c	2005-03-30 13:17:14 -08:00
@@ -13,12 +13,8 @@
 #ifdef CONFIG_SYSCTL
 
 extern int netdev_max_backlog;
-extern int weight_p;
-extern int no_cong_thresh;
-extern int no_cong;
-extern int lo_cong;
-extern int mod_cong;
-extern int netdev_fastroute;
+extern int netdev_max_queue;
+
 extern int net_msg_cost;
 extern int net_msg_burst;
 
@@ -27,7 +23,6 @@
 extern __u32 sysctl_wmem_default;
 extern __u32 sysctl_rmem_default;
 
-extern int sysctl_core_destroy_delay;
 extern int sysctl_optmem_max;
 extern int sysctl_somaxconn;
 
@@ -83,14 +78,6 @@
 		.proc_handler	= &proc_dointvec
 	},
 	{
-		.ctl_name	= NET_CORE_DEV_WEIGHT,
-		.procname	= "dev_weight",
-		.data		= &weight_p,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
-	},
-	{
 		.ctl_name	= NET_CORE_MAX_BACKLOG,
 		.procname	= "netdev_max_backlog",
 		.data		= &netdev_max_backlog,
@@ -99,33 +86,9 @@
 		.proc_handler	= &proc_dointvec
 	},
 	{
-		.ctl_name	= NET_CORE_NO_CONG_THRESH,
-		.procname	= "no_cong_thresh",
-		.data		= &no_cong_thresh,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
-	},
-	{
-		.ctl_name	= NET_CORE_NO_CONG,
-		.procname	= "no_cong",
-		.data		= &no_cong,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
-	},
-	{
-		.ctl_name	= NET_CORE_LO_CONG,
-		.procname	= "lo_cong",
-		.data		= &lo_cong,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
-	},
-	{
-		.ctl_name	= NET_CORE_MOD_CONG,
-		.procname	= "mod_cong",
-		.data		= &mod_cong,
+		.ctl_name	= NET_CORE_MAX_QUEUE,
+		.procname	= "netdev_max_queue",
+		.data		= &netdev_max_queue,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
