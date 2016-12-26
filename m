From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: [PATCH v1] net: dev_weight: TX/RX orthogonality
Date: Mon, 26 Dec 2016 10:49:23 +0100
Message-ID: <1482745763-15082-1-git-send-email-matthias.tafelmeier@gmx.net>
Cc: hagen@jauu.net, fw@strlen.de, edumazet@google.com,
        daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:64341 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755328AbcLZJtq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Dec 2016 04:49:46 -0500
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

This patch therefore introduces an independent configurability via procfs to
userland.
---
 include/linux/netdevice.h  |  3 ++-
 net/core/dev.c             |  7 ++++---
 net/core/sysctl_net_core.c | 12 ++++++++++--
 net/sched/sch_generic.c    |  2 +-
 4 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 994f742..3616b35 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3794,7 +3794,8 @@ void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
 
 extern int		netdev_max_backlog;
 extern int		netdev_tstamp_prequeue;
-extern int		weight_p;
+extern int		weight_p_rx;
+extern int		weight_p_tx;
 
 bool netdev_has_upper_dev(struct net_device *dev, struct net_device *upper_dev);
 struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 8db5a0b..fc9e506 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3427,7 +3427,8 @@ EXPORT_SYMBOL(netdev_max_backlog);
 
 int netdev_tstamp_prequeue __read_mostly = 1;
 int netdev_budget __read_mostly = 300;
-int weight_p __read_mostly = 64;            /* old backlog weight */
+int weight_p_rx __read_mostly = 64;            /* old backlog weight */
+int weight_p_tx __read_mostly = 64;
 
 /* Called with irq disabled */
 static inline void ____napi_schedule(struct softnet_data *sd,
@@ -4833,7 +4834,7 @@ static int process_backlog(struct napi_struct *napi, int quota)
 		net_rps_action_and_irq_enable(sd);
 	}
 
-	napi->weight = weight_p;
+	napi->weight = weight_p_rx;
 	while (again) {
 		struct sk_buff *skb;
 
@@ -8377,7 +8378,7 @@ static int __init net_dev_init(void)
 #endif
 
 		sd->backlog.poll = process_backlog;
-		sd->backlog.weight = weight_p;
+		sd->backlog.weight = weight_p_rx;
 	}
 
 	dev_boot_phase = 0;
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 2a46e40..7eaa33a 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -269,13 +269,21 @@ static struct ctl_table net_core_table[] = {
 		.extra1		= &min_rcvbuf,
 	},
 	{
-		.procname	= "dev_weight",
-		.data		= &weight_p,
+		.procname	= "dev_weight_rx",
+		.data		= &weight_p_rx,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "dev_weight_tx",
+		.data		= &weight_p_tx,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+
+	{
 		.procname	= "netdev_max_backlog",
 		.data		= &netdev_max_backlog,
 		.maxlen		= sizeof(int),
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6eb9c8e..8457e8c 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -247,7 +247,7 @@ static inline int qdisc_restart(struct Qdisc *q, int *packets)
 
 void __qdisc_run(struct Qdisc *q)
 {
-	int quota = weight_p;
+	int quota = weight_p_tx;
 	int packets;
 
 	while (qdisc_restart(q, &packets)) {
-- 
2.7.4
