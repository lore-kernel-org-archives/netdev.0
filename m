From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] rps: overflow prevention for saturated cpus
Date: Thu,  6 Dec 2012 15:36:34 -0500
Message-ID: <1354826194-9289-1-git-send-email-willemb@google.com>
Cc: Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f202.google.com ([209.85.215.202]:64792 "EHLO
	mail-ea0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753499Ab2LFUnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 15:43:51 -0500
Received: by mail-ea0-f202.google.com with SMTP id j12so471007eaa.1
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 12:43:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RPS and RFS balance load across cpus with flow affinity. This can
cause local bottlenecks, where a small number or single large flow
(DoS) can saturate one CPU while others are idle.

This patch maintains flow affinity in normal conditions, but
trades it for throughput when a cpu becomes saturated. Then, packets
destined to that cpu (only) are redirected to the lightest loaded cpu
in the rxqueue's rps_map. This breaks flow affinity under high load
for some flows, in favor of processing packets up to the capacity
of the complete rps_map cpuset in all circumstances.

Overload on an rps cpu is detected when the cpu's input queue
exceeds a high watermark. This threshold, netdev_max_rps_backlog,
is configurable through sysctl. By default, it is the same as
netdev_max_backlog, the threshold at which point packets are
dropped. Therefore, the behavior is disabled by default. It is
enabled by setting the rps threshold lower than the drop threshold.

This mechanism is orthogonal to filtering approaches to handle
unwanted large flows (DoS). The goal here is to avoid dropping any
traffic until the entire system is saturated.

Tested:
Sent a steady stream of 1.4M UDP packets to a machine with four
RPS cpus 0--3, set in /sys/class/net/eth0/queues/rx-N/rps_cpus.
RFS is disabled to illustrate load balancing more clearly. Showing
the output from /proc/net/softnet_stat, columns 0 (processed), 1
(dropped), 2 (time squeeuze) and 9 (rps), for the relevant CPUs:

- without patch, 40 source IP addresses (i.e., balanced):
0: ok=00409483 drop=00000000 time=00001224 rps=00000089
1: ok=00496336 drop=00051365 time=00001551 rps=00000000
2: ok=00374380 drop=00000000 time=00001105 rps=00000129
3: ok=00411348 drop=00000000 time=00001175 rps=00000165

- without patch, 1 source IP address:
0: ok=00856313 drop=00863842 time=00002676 rps=00000000
1: ok=00000003 drop=00000000 time=00000000 rps=00000001
2: ok=00000001 drop=00000000 time=00000000 rps=00000001
3: ok=00000014 drop=00000000 time=00000000 rps=00000000

- with patch, 1 source IP address:
0: ok=00278675 drop=00000000 time=00000475 rps=00001201
1: ok=00276154 drop=00000000 time=00000459 rps=00001213
2: ok=00647050 drop=00000000 time=00002022 rps=00000000
3: ok=00276228 drop=00000000 time=00000464 rps=00001218

(let me know if commit messages like this are too wordy)
---
 Documentation/networking/scaling.txt |   12 +++++++++++
 include/linux/netdevice.h            |    3 ++
 net/core/dev.c                       |   37 ++++++++++++++++++++++++++++++++-
 net/core/sysctl_net_core.c           |    9 ++++++++
 4 files changed, 59 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/scaling.txt b/Documentation/networking/scaling.txt
index 579994a..f454564 100644
--- a/Documentation/networking/scaling.txt
+++ b/Documentation/networking/scaling.txt
@@ -135,6 +135,18 @@ packets have been queued to their backlog queue. The IPI wakes backlog
 processing on the remote CPU, and any queued packets are then processed
 up the networking stack.
 
+==== RPS Overflow Protection
+
+By selecting the same cpu from the cpuset for each packet in the same
+flow, RPS will cause load imbalance when input flows are not uniformly
+random. In the extreme case, a single flow, all packets are handled on a
+single CPU, which limits the throughput of the machine to the throughput
+of that CPU. RPS has optional overflow protection, which disables flow
+affinity when an RPS CPU becomes saturated: during overload, its packets
+will be sent to the least loaded other CPU in the RPS cpuset. To enable
+this option, set sysctl net.core.netdev_max_rps_backlog to be smaller than
+net.core.netdev_max_backlog. Setting it to half is a reasonable heuristic.
+
 ==== RPS Configuration
 
 RPS requires a kernel compiled with the CONFIG_RPS kconfig symbol (on
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 18c5dc9..84624fa 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2609,6 +2609,9 @@ extern void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
 				    const struct net_device_stats *netdev_stats);
 
 extern int		netdev_max_backlog;
+#ifdef CONFIG_RPS
+extern int		netdev_max_rps_backlog;
+#endif
 extern int		netdev_tstamp_prequeue;
 extern int		weight_p;
 extern int		bpf_jit_enable;
diff --git a/net/core/dev.c b/net/core/dev.c
index 2f94df2..08c99ad 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2734,6 +2734,9 @@ EXPORT_SYMBOL(dev_queue_xmit);
 int netdev_max_backlog __read_mostly = 1000;
 EXPORT_SYMBOL(netdev_max_backlog);
 
+#ifdef CONFIG_RPS
+int netdev_max_rps_backlog __read_mostly = 1000;
+#endif
 int netdev_tstamp_prequeue __read_mostly = 1;
 int netdev_budget __read_mostly = 300;
 int weight_p __read_mostly = 64;            /* old backlog weight */
@@ -2834,6 +2837,36 @@ set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	return rflow;
 }
 
+/* @return cpu under normal conditions, another rps_cpu if backlogged. */
+static int get_rps_overflow_cpu(int cpu, const struct rps_map* map)
+{
+       struct softnet_data *sd;
+       unsigned int cur, tcpu, min;
+       int i;
+
+       if (skb_queue_len(&per_cpu(softnet_data, cpu).input_pkt_queue) <
+           netdev_max_rps_backlog || !map)
+               return cpu;
+
+       /* leave room to prioritize the flows sent to the cpu by rxhash. */
+       min = netdev_max_rps_backlog;
+       min -= min >> 3;
+
+       for (i = 0; i < map->len; i++) {
+               tcpu = map->cpus[i];
+               if (cpu_online(tcpu)) {
+                       sd = &per_cpu(softnet_data, tcpu);
+                       cur = skb_queue_len(&sd->input_pkt_queue);
+                       if (cur < min) {
+                               min = cur;
+                               cpu = tcpu;
+                       }
+               }
+       }
+
+       return cpu;
+}
+
 /*
  * get_rps_cpu is called from netif_receive_skb and returns the target
  * CPU from the RPS map of the receiving queue for a given skb.
@@ -2912,7 +2945,7 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 
 		if (tcpu != RPS_NO_CPU && cpu_online(tcpu)) {
 			*rflowp = rflow;
-			cpu = tcpu;
+			cpu = get_rps_overflow_cpu(tcpu, map);
 			goto done;
 		}
 	}
@@ -2921,7 +2954,7 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 		tcpu = map->cpus[((u64) skb->rxhash * map->len) >> 32];
 
 		if (cpu_online(tcpu)) {
-			cpu = tcpu;
+			cpu = get_rps_overflow_cpu(tcpu, map);
 			goto done;
 		}
 	}
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index d1b0804..c1b7829 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -129,6 +129,15 @@ static struct ctl_table net_core_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+#ifdef CONFIG_RPS
+	{
+		.procname	= "netdev_max_rps_backlog",
+		.data		= &netdev_max_rps_backlog,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+#endif
 #ifdef CONFIG_BPF_JIT
 	{
 		.procname	= "bpf_jit_enable",
-- 
1.7.7.3
