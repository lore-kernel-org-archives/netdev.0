From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: [PATCH v3] net: dev_weight: TX/RX orthogonality
Date: Wed, 28 Dec 2016 10:42:14 +0100
Message-ID: <1482918134-10483-1-git-send-email-matthias.tafelmeier@gmx.net>
References: <20161227164758.GA10870@localhost.localdomain>
Cc: hagen@jauu.net, fw@strlen.de, edumazet@google.com,
        daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:59092 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751181AbcL1Jmm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Dec 2016 04:42:42 -0500
In-Reply-To: <20161227164758.GA10870@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oftenly, introducing side effects on packet processing on the other half
of the stack by adjusting one of TX/RX via sysctl is not desirable.
There are cases of demand for asymmetric, orthogonal configurability.

This holds true especially for nodes where RPS for RFS usage on top is
configured and therefore use the 'old dev_weight'. This is quite a
common base configuration setup nowadays, even with NICs of superior processing
support (e.g. aRFS).

A good example use case are nodes acting as noSQL data bases with a
large number of tiny requests and rather fewer but large packets as responses.
It's affordable to have large budget and rx dev_weights for the
requests. But as a side effect having this large a number on TX
processed in one run can overwhelm drivers.

This patch therefore introduces an independent configurability via sysctl to
userland.
---
 Documentation/sysctl/net.txt | 21 +++++++++++++++++++++
 include/linux/netdevice.h    |  2 ++
 net/core/dev.c               |  4 +++-
 net/core/sysctl_net_core.c   | 14 ++++++++++++++
 net/sched/sch_generic.c      |  2 +-
 5 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index f0480f7..53cef32 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -61,6 +61,27 @@ The maximum number of packets that kernel can handle on a NAPI interrupt,
 it's a Per-CPU variable.
 Default: 64
 
+dev_weight_rx_bias
+--------------
+
+RPS (e.g. RFS, aRFS) processing is competing with the registered NAPI poll function 
+of the driver for the per softirq cycle netdev_budget. This parameter influences 
+the proportion of the configured netdev_budget that is spent on RPS based packet 
+processing during RX softirq cycles. It is further meant for making current 
+dev_weight adaptable for asymmetric CPU needs on RX/TX side of the network stack.
+(see dev_weight_tx_bias) It is effective on a per CPU basis. Determination is based 
+on dev_weight and is calculated multiplicative (dev_weight * dev_weight_rx_bias).
+Default: 1
+
+dev_weight_tx_bias
+--------------
+
+Scales the maximum number of packets that can be processed during a TX softirq cycle.
+Effective on a per CPU basis. Allows scaling of current dev_weight for asymmetric 
+net stack processing needs. Be careful to avoid making TX softirq processing a CPU hog.
+Calculation is based on dev_weight (dev_weight * dev_weight_tx_bias).
+Default: 1
+
 default_qdisc
 --------------
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 994f742..46b4b66 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3795,6 +3795,8 @@ void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
 extern int		netdev_max_backlog;
 extern int		netdev_tstamp_prequeue;
 extern int		weight_p;
+extern int		dev_weight_rx_bias;
+extern int		dev_weight_tx_bias;
 
 bool netdev_has_upper_dev(struct net_device *dev, struct net_device *upper_dev);
 struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 8db5a0b..7ce1736 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3428,6 +3428,8 @@ EXPORT_SYMBOL(netdev_max_backlog);
 int netdev_tstamp_prequeue __read_mostly = 1;
 int netdev_budget __read_mostly = 300;
 int weight_p __read_mostly = 64;            /* old backlog weight */
+int dev_weight_rx_bias __read_mostly = 1;            /* bias for backlog weight */
+int dev_weight_tx_bias __read_mostly = 1;            /* bias for output_queue quota */
 
 /* Called with irq disabled */
 static inline void ____napi_schedule(struct softnet_data *sd,
@@ -4833,7 +4835,7 @@ static int process_backlog(struct napi_struct *napi, int quota)
 		net_rps_action_and_irq_enable(sd);
 	}
 
-	napi->weight = weight_p;
+	napi->weight = weight_p * dev_weight_rx_bias;
 	while (again) {
 		struct sk_buff *skb;
 
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 2a46e40..2197388 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -276,6 +276,20 @@ static struct ctl_table net_core_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "dev_weight_rx_bias",
+		.data		= &dev_weight_rx_bias,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.procname	= "dev_weight_tx_bias",
+		.data		= &dev_weight_tx_bias,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
 		.procname	= "netdev_max_backlog",
 		.data		= &netdev_max_backlog,
 		.maxlen		= sizeof(int),
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6eb9c8e..19374ef 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -247,7 +247,7 @@ static inline int qdisc_restart(struct Qdisc *q, int *packets)
 
 void __qdisc_run(struct Qdisc *q)
 {
-	int quota = weight_p;
+	int quota = weight_p * dev_weight_tx_bias;
 	int packets;
 
 	while (qdisc_restart(q, &packets)) {
-- 
2.7.4
