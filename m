From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v2] rps: selective flow shedding during softnet overflow
Date: Mon, 22 Apr 2013 16:46:01 -0400
Message-ID: <1366663561-12305-1-git-send-email-willemb@google.com>
References: <CA+FuTSfyo5YdtLpyXPawYoppM7zj5cp1_k1hD7+qWL6DUpNd4Q@mail.gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
To: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f202.google.com ([209.85.213.202]:46172 "EHLO
	mail-ye0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755250Ab3DVUqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 16:46:03 -0400
Received: by mail-ye0-f202.google.com with SMTP id l8so737885yen.5
        for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 13:46:03 -0700 (PDT)
In-Reply-To: <CA+FuTSfyo5YdtLpyXPawYoppM7zj5cp1_k1hD7+qWL6DUpNd4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A cpu executing the network receive path sheds packets when its input
queue grows to netdev_max_backlog. A single high rate flow (such as a
spoofed source DoS) can exceed a single cpu processing rate and will
degrade throughput of other flows hashed onto the same cpu.

This patch adds a more fine grained hashtable. If the netdev backlog
is above a threshold, IRQ cpus track the ratio of total traffic of
each flow (using 4096 buckets, configurable). The ratio is measured
by counting the number of packets per flow over the last 256 packets
from the source cpu. Any flow that occupies a large fraction of this
(set at 50%) will see packet drop while above the threshold.

Tested:
Setup is a muli-threaded UDP echo server with network rx IRQ on cpu0,
kernel receive (RPS) on cpu0 and application threads on cpus 2--7
each handling 20k req/s. Throughput halves when hit with a 400 kpps
antagonist storm. With this patch applied, antagonist overload is
dropped and the server processes its complete load.

The patch is effective when kernel receive processing is the
bottleneck. The above RPS scenario is a extreme, but the same is
reached with RFS and sufficient kernel processing (iptables, packet
socket tap, ..).

Signed-off-by: Willem de Bruijn <willemb@google.com>

---

Changed v1->v2
- add fl->num_buckets element to use the actual allocated table length.
- disable the kconfig option by default, as it is workload specific.
---
 include/linux/netdevice.h  |  17 ++++++++
 net/Kconfig                |  11 +++++
 net/core/dev.c             |  48 ++++++++++++++++++++-
 net/core/net-procfs.c      |  16 ++++++-
 net/core/sysctl_net_core.c | 101 +++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 190 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f8898a4..d781cf1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1779,6 +1779,19 @@ static inline int unregister_gifconf(unsigned int family)
 	return register_gifconf(family, NULL);
 }
 
+#ifdef CONFIG_NET_FLOW_LIMIT
+#define FLOW_LIMIT_HISTORY	(1 << 8)	/* must be ^2 */
+struct sd_flow_limit {
+	u64			count;
+	unsigned int		num_buckets;
+	unsigned int		history_head;
+	u16			history[FLOW_LIMIT_HISTORY];
+	u8			buckets[];
+};
+
+extern int netdev_flow_limit_table_len;
+#endif /* CONFIG_NET_FLOW_LIMIT */
+
 /*
  * Incoming packets are placed on per-cpu queues
  */
@@ -1808,6 +1821,10 @@ struct softnet_data {
 	unsigned int		dropped;
 	struct sk_buff_head	input_pkt_queue;
 	struct napi_struct	backlog;
+
+#ifdef CONFIG_NET_FLOW_LIMIT
+	struct sd_flow_limit	*flow_limit;
+#endif
 };
 
 static inline void input_queue_head_incr(struct softnet_data *sd)
diff --git a/net/Kconfig b/net/Kconfig
index 1a22216..a0cbd3b 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -268,6 +268,17 @@ config BPF_JIT
 	  packet sniffing (libpcap/tcpdump). Note : Admin should enable
 	  this feature changing /proc/sys/net/core/bpf_jit_enable
 
+config NET_FLOW_LIMIT
+	bool "Flow shedding under load"
+	default n
+	---help---
+	  The network stack has to drop packets when a receive processing CPUs
+	  backlog reaches netdev_max_backlog. If a few out of many active flows
+	  generate the vast majority of load, drop their traffic earlier to
+	  maintain capacity for the other flows. This feature provides servers
+	  with many clients some protection against DoS by a single (spoofed)
+	  flow that greatly exceeds average workload.
+
 menu "Network testing"
 
 config NET_PKTGEN
diff --git a/net/core/dev.c b/net/core/dev.c
index fad4c38..90190c4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3057,6 +3057,46 @@ static int rps_ipi_queued(struct softnet_data *sd)
 	return 0;
 }
 
+#ifdef CONFIG_NET_FLOW_LIMIT
+int netdev_flow_limit_table_len __read_mostly = (1 << 12);
+#endif
+
+static bool skb_flow_limit(struct sk_buff *skb, unsigned int qlen)
+{
+#ifdef CONFIG_NET_FLOW_LIMIT
+	struct sd_flow_limit *fl;
+	struct softnet_data *sd;
+	unsigned int old_flow, new_flow;
+
+	if (qlen < (netdev_max_backlog >> 1))
+		return false;
+
+	sd = &per_cpu(softnet_data, smp_processor_id());
+
+	rcu_read_lock();
+	fl = rcu_dereference(sd->flow_limit);
+	if (fl) {
+		new_flow = skb_get_rxhash(skb) & (fl->num_buckets - 1);
+		old_flow = fl->history[fl->history_head];
+		fl->history[fl->history_head] = new_flow;
+
+		fl->history_head++;
+		fl->history_head &= FLOW_LIMIT_HISTORY - 1;
+
+		if (likely(fl->buckets[old_flow]))
+			fl->buckets[old_flow]--;
+
+		if (++fl->buckets[new_flow] > (FLOW_LIMIT_HISTORY >> 1)) {
+			fl->count++;
+			rcu_read_unlock();
+			return true;
+		}
+	}
+	rcu_read_unlock();
+#endif
+	return false;
+}
+
 /*
  * enqueue_to_backlog is called to queue an skb to a per CPU backlog
  * queue (may be a remote CPU queue).
@@ -3066,13 +3106,15 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
 {
 	struct softnet_data *sd;
 	unsigned long flags;
+	unsigned int qlen;
 
 	sd = &per_cpu(softnet_data, cpu);
 
 	local_irq_save(flags);
 
 	rps_lock(sd);
-	if (skb_queue_len(&sd->input_pkt_queue) <= netdev_max_backlog) {
+	qlen = skb_queue_len(&sd->input_pkt_queue);
+	if (qlen <= netdev_max_backlog && !skb_flow_limit(skb, qlen)) {
 		if (skb_queue_len(&sd->input_pkt_queue)) {
 enqueue:
 			__skb_queue_tail(&sd->input_pkt_queue, skb);
@@ -6262,6 +6304,10 @@ static int __init net_dev_init(void)
 		sd->backlog.weight = weight_p;
 		sd->backlog.gro_list = NULL;
 		sd->backlog.gro_count = 0;
+
+#ifdef CONFIG_NET_FLOW_LIMIT
+		sd->flow_limit = NULL;
+#endif
 	}
 
 	dev_boot_phase = 0;
diff --git a/net/core/net-procfs.c b/net/core/net-procfs.c
index 569d355..2bf8329 100644
--- a/net/core/net-procfs.c
+++ b/net/core/net-procfs.c
@@ -146,11 +146,23 @@ static void softnet_seq_stop(struct seq_file *seq, void *v)
 static int softnet_seq_show(struct seq_file *seq, void *v)
 {
 	struct softnet_data *sd = v;
+	unsigned int flow_limit_count = 0;
 
-	seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
+#ifdef CONFIG_NET_FLOW_LIMIT
+	struct sd_flow_limit *fl;
+
+	rcu_read_lock();
+	fl = rcu_dereference(sd->flow_limit);
+	if (fl)
+		flow_limit_count = fl->count;
+	rcu_read_unlock();
+#endif
+
+	seq_printf(seq,
+		   "%08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
 		   sd->processed, sd->dropped, sd->time_squeeze, 0,
 		   0, 0, 0, 0, /* was fastroute */
-		   sd->cpu_collision, sd->received_rps);
+		   sd->cpu_collision, sd->received_rps, flow_limit_count);
 	return 0;
 }
 
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index cfdb46a..297df31 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -87,6 +87,93 @@ static int rps_sock_flow_sysctl(ctl_table *table, int write,
 }
 #endif /* CONFIG_RPS */
 
+#ifdef CONFIG_NET_FLOW_LIMIT
+static int flow_limit_cpu_sysctl(ctl_table *table, int write,
+				 void __user *buffer, size_t *lenp,
+				 loff_t *ppos)
+{
+	static DEFINE_MUTEX(flow_limit_update_mutex);
+	struct sd_flow_limit *cur;
+	struct softnet_data *sd;
+	cpumask_var_t mask;
+	int i, len, ret = 0;
+
+	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
+		return -ENOMEM;
+
+	if (write) {
+		ret = cpumask_parse_user(buffer, *lenp, mask);
+		if (ret)
+			goto done;
+
+		len = sizeof(*cur) + netdev_flow_limit_table_len;
+		mutex_lock(&flow_limit_update_mutex);
+		for_each_possible_cpu(i) {
+			sd = &per_cpu(softnet_data, i);
+			cur = rcu_dereference_protected(sd->flow_limit,
+				      lockdep_is_held(flow_limit_update_mutex));
+			if (cur && !cpumask_test_cpu(i, mask)) {
+				RCU_INIT_POINTER(sd->flow_limit, NULL);
+				synchronize_rcu();
+				kfree(cur);
+			} else if (!cur && cpumask_test_cpu(i, mask)) {
+				cur = kzalloc(len, GFP_KERNEL);
+				cur->num_buckets = netdev_flow_limit_table_len;
+				if (!cur) {
+					/* not unwinding previous changes */
+					ret = -ENOMEM;
+					goto write_unlock;
+				}
+				rcu_assign_pointer(sd->flow_limit, cur);
+			}
+		}
+write_unlock:
+		synchronize_rcu();
+		mutex_unlock(&flow_limit_update_mutex);
+	} else {
+		if (*ppos || !*lenp) {
+			*lenp = 0;
+			goto done;
+		}
+
+		cpumask_clear(mask);
+		rcu_read_lock();
+		for_each_possible_cpu(i) {
+			sd = &per_cpu(softnet_data, i);
+			if (rcu_dereference(sd->flow_limit))
+				cpumask_set_cpu(i, mask);
+		}
+		rcu_read_unlock();
+
+		len = cpumask_scnprintf(buffer, *lenp, mask);
+		*lenp = len + 1;
+		*ppos += len + 1;
+	}
+
+done:
+	free_cpumask_var(mask);
+	return ret;
+}
+
+static int flow_limit_table_len_sysctl(ctl_table *table, int write,
+				       void __user *buffer, size_t *lenp,
+				       loff_t *ppos)
+{
+	unsigned int old, *ptr;
+	int ret;
+
+	ptr = table->data;
+	old = *ptr;
+	ret = proc_dointvec(table, write, buffer, lenp, ppos);
+	if (!ret && write && !is_power_of_2(*ptr)) {
+		*ptr = old;
+		ret = -EINVAL;
+	}
+
+	return ret;
+}
+#endif /* CONFIG_NET_FLOW_LIMIT */
+
 static struct ctl_table net_core_table[] = {
 #ifdef CONFIG_NET
 	{
@@ -180,6 +267,20 @@ static struct ctl_table net_core_table[] = {
 		.proc_handler	= rps_sock_flow_sysctl
 	},
 #endif
+#ifdef CONFIG_NET_FLOW_LIMIT
+	{
+		.procname	= "flow_limit_cpu_bitmap",
+		.mode		= 0644,
+		.proc_handler	= flow_limit_cpu_sysctl
+	},
+	{
+		.procname	= "flow_limit_table_len",
+		.data		= &netdev_flow_limit_table_len,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= flow_limit_table_len_sysctl
+	},
+#endif /* CONFIG_NET_FLOW_LIMIT */
 #endif /* CONFIG_NET */
 	{
 		.procname	= "netdev_budget",
-- 
1.8.2.1
