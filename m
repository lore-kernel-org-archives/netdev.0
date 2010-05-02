From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v3] net: fix softnet_stat
Date: Sun,  2 May 2010 23:42:16 +0800
Message-ID: <1272814936-4902-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:39790 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754457Ab0EBPmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 11:42:46 -0400
Received: by pwj9 with SMTP id 9so886964pwj.19
        for <netdev@vger.kernel.org>; Sun, 02 May 2010 08:42:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix softnet_stat

Per cpu variable softnet_data.total was shared between IRQ and SoftIRQ context
without any protection. And enqueue_to_backlog should update the netdev_rx_stat
of the target CPU.

This patch renames softnet_data.total to softnet_data.processed: the number of
packets processed in uppper levels(IP stacks).

softnet_stat data is moved into softnet_data.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/linux/netdevice.h |   17 +++++++----------
 net/core/dev.c            |   26 ++++++++++++--------------
 net/sched/sch_generic.c   |    2 +-
 3 files changed, 20 insertions(+), 25 deletions(-)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 40d4c20..c39938f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -218,16 +218,6 @@ struct neighbour;
 struct neigh_parms;
 struct sk_buff;
 
-struct netif_rx_stats {
-	unsigned total;
-	unsigned dropped;
-	unsigned time_squeeze;
-	unsigned cpu_collision;
-	unsigned received_rps;
-};
-
-DECLARE_PER_CPU(struct netif_rx_stats, netdev_rx_stat);
-
 struct netdev_hw_addr {
 	struct list_head	list;
 	unsigned char		addr[MAX_ADDR_LEN];
@@ -1390,6 +1380,12 @@ struct softnet_data {
 	struct sk_buff		*completion_queue;
 	struct sk_buff_head	process_queue;
 
+	/* stats */
+	unsigned		processed;
+	unsigned		time_squeeze;
+	unsigned		cpu_collision;
+	unsigned		received_rps;
+
 #ifdef CONFIG_RPS
 	struct softnet_data	*rps_ipi_list;
 
@@ -1399,6 +1395,7 @@ struct softnet_data {
 	unsigned int		cpu;
 	unsigned int		input_queue_head;
 #endif
+	unsigned		dropped;
 	struct sk_buff_head	input_pkt_queue;
 	struct napi_struct	backlog;
 };
diff --git a/net/core/dev.c b/net/core/dev.c
index 100dcbd..36d53be 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2205,8 +2205,6 @@ int netdev_max_backlog __read_mostly = 1000;
 int netdev_budget __read_mostly = 300;
 int weight_p __read_mostly = 64;            /* old backlog weight */
 
-DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
-
 #ifdef CONFIG_RPS
 
 /* One global table that all flow-based protocols share. */
@@ -2366,7 +2364,7 @@ static void rps_trigger_softirq(void *data)
 	struct softnet_data *sd = data;
 
 	__napi_schedule(&sd->backlog);
-	__get_cpu_var(netdev_rx_stat).received_rps++;
+	sd->received_rps++;
 }
 
 #endif /* CONFIG_RPS */
@@ -2405,7 +2403,6 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
 	sd = &per_cpu(softnet_data, cpu);
 
 	local_irq_save(flags);
-	__get_cpu_var(netdev_rx_stat).total++;
 
 	rps_lock(sd);
 	if (skb_queue_len(&sd->input_pkt_queue) <= netdev_max_backlog) {
@@ -2429,9 +2426,9 @@ enqueue:
 		goto enqueue;
 	}
 
+	sd->dropped++;
 	rps_unlock(sd);
 
-	__get_cpu_var(netdev_rx_stat).dropped++;
 	local_irq_restore(flags);
 
 	kfree_skb(skb);
@@ -2806,7 +2803,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
 			skb->dev = master;
 	}
 
-	__get_cpu_var(netdev_rx_stat).total++;
+	__get_cpu_var(softnet_data).processed++;
 
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
@@ -3490,7 +3487,7 @@ out:
 	return;
 
 softnet_break:
-	__get_cpu_var(netdev_rx_stat).time_squeeze++;
+	sd->time_squeeze++;
 	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
 	goto out;
 }
@@ -3691,17 +3688,17 @@ static int dev_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
-static struct netif_rx_stats *softnet_get_online(loff_t *pos)
+static struct softnet_data *softnet_get_online(loff_t *pos)
 {
-	struct netif_rx_stats *rc = NULL;
+	struct softnet_data *sd = NULL;
 
 	while (*pos < nr_cpu_ids)
 		if (cpu_online(*pos)) {
-			rc = &per_cpu(netdev_rx_stat, *pos);
+			sd = &per_cpu(softnet_data, *pos);
 			break;
 		} else
 			++*pos;
-	return rc;
+	return sd;
 }
 
 static void *softnet_seq_start(struct seq_file *seq, loff_t *pos)
@@ -3721,12 +3718,12 @@ static void softnet_seq_stop(struct seq_file *seq, void *v)
 
 static int softnet_seq_show(struct seq_file *seq, void *v)
 {
-	struct netif_rx_stats *s = v;
+	struct softnet_data *sd = v;
 
 	seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
-		   s->total, s->dropped, s->time_squeeze, 0,
+		   sd->processed, sd->dropped, sd->time_squeeze, 0,
 		   0, 0, 0, 0, /* was fastroute */
-		   s->cpu_collision, s->received_rps);
+		   sd->cpu_collision, sd->received_rps);
 	return 0;
 }
 
@@ -5869,6 +5866,7 @@ static int __init net_dev_init(void)
 	for_each_possible_cpu(i) {
 		struct softnet_data *sd = &per_cpu(softnet_data, i);
 
+		memset(sd, 0, sizeof(*sd));
 		skb_queue_head_init(&sd->input_pkt_queue);
 		skb_queue_head_init(&sd->process_queue);
 		sd->completion_queue = NULL;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index aeddabf..a969b11 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -94,7 +94,7 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 		 * Another cpu is holding lock, requeue & delay xmits for
 		 * some time.
 		 */
-		__get_cpu_var(netdev_rx_stat).cpu_collision++;
+		__get_cpu_var(softnet_data).cpu_collision++;
 		ret = dev_requeue_skb(skb, q);
 	}
 
