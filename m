From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 1/9] net_sch: red: Add offload ability to RED qdisc
Date: Mon, 30 Oct 2017 09:56:05 +0100
Message-ID: <20171030085613.8697-2-jiri@resnulli.us>
References: <20171030085613.8697-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com,
        ogerlitz@mellanox.com, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:57234 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752634AbdJ3I4R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 04:56:17 -0400
Received: by mail-wr0-f193.google.com with SMTP id r79so11696703wrb.13
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 01:56:16 -0700 (PDT)
In-Reply-To: <20171030085613.8697-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add the ability to offload RED qdisc by using ndo_setup_tc.
There are four commands for RED offloading:
* TC_RED_SET: handles set and change.
* TC_RED_DESTROY: handle qdisc destroy.
* TC_RED_STATS: update the qdiscs counters (given as reference)
* TC_RED_XSTAT: returns red xstats.

Whether RED is being offloaded is being determined every time dump action
is being called because parent change of this qdisc could change its
offload state but doesn't require any RED function to be called.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h      |  1 +
 include/net/pkt_cls.h          | 30 ++++++++++++++
 include/uapi/linux/pkt_sched.h |  1 +
 net/sched/sch_red.c            | 90 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 122 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5e02f79..1dc9833 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -777,6 +777,7 @@ enum tc_setup_type {
 	TC_SETUP_CLSBPF,
 	TC_SETUP_BLOCK,
 	TC_SETUP_CBS,
+	TC_SETUP_QDISC_RED,
 };
 
 /* These structures hold the attributes of xdp state that are being passed
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 04caa24..6108c6a 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -712,4 +712,34 @@ struct tc_cookie {
 	u8  *data;
 	u32 len;
 };
+
+enum tc_red_command {
+	TC_RED_REPLACE,
+	TC_RED_DESTROY,
+	TC_RED_STATS,
+	TC_RED_XSTATS,
+};
+
+struct tc_red_qopt_offload_params {
+	u32 min;
+	u32 max;
+	u32 probability;
+	bool is_ecn;
+};
+struct tc_red_qopt_offload_stats {
+	struct gnet_stats_basic_packed *bstats;
+	struct gnet_stats_queue *qstats;
+};
+
+struct tc_red_qopt_offload {
+	enum tc_red_command command;
+	u32 handle;
+	u32 parent;
+	union {
+		struct tc_red_qopt_offload_params set;
+		struct tc_red_qopt_offload_stats stats;
+		struct red_stats *xstats;
+	};
+};
+
 #endif
diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 0e88cc2..743c42a 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -255,6 +255,7 @@ struct tc_red_qopt {
 #define TC_RED_ECN		1
 #define TC_RED_HARDDROP		2
 #define TC_RED_ADAPTATIVE	4
+#define TC_RED_OFFLOADED	8
 };
 
 struct tc_red_xstats {
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index fdfdb56..836e0e4 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -19,6 +19,7 @@
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
 #include <net/pkt_sched.h>
+#include <net/pkt_cls.h>
 #include <net/inet_ecn.h>
 #include <net/red.h>
 
@@ -148,11 +149,27 @@ static void red_reset(struct Qdisc *sch)
 	red_restart(&q->vars);
 }
 
+static void red_unoffload(struct Qdisc *sch)
+{
+	struct net_device *dev = qdisc_dev(sch);
+	struct tc_red_qopt_offload opt = {
+		.handle = sch->handle,
+		.command = TC_RED_DESTROY,
+		.parent = sch->parent,
+	};
+
+	if (!tc_can_offload(dev) || !dev->netdev_ops->ndo_setup_tc)
+		return;
+
+	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_QDISC_RED,  &opt);
+}
+
 static void red_destroy(struct Qdisc *sch)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
 
 	del_timer_sync(&q->adapt_timer);
+	red_unoffload(sch);
 	qdisc_destroy(q->qdisc);
 }
 
@@ -162,6 +179,28 @@ static const struct nla_policy red_policy[TCA_RED_MAX + 1] = {
 	[TCA_RED_MAX_P] = { .type = NLA_U32 },
 };
 
+static int red_offload(struct Qdisc *sch)
+{
+	struct red_sched_data *q = qdisc_priv(sch);
+	struct net_device *dev = qdisc_dev(sch);
+	struct tc_red_qopt_offload opt = {
+		.handle = sch->handle,
+		.command = TC_RED_REPLACE,
+		.parent = sch->parent,
+		.set = {
+			.min = q->parms.qth_min >> q->parms.Wlog,
+			.max = q->parms.qth_max >> q->parms.Wlog,
+			.probability = q->parms.max_P,
+			.is_ecn = red_use_ecn(q),
+		},
+	};
+
+	if (!tc_can_offload(dev) || !dev->netdev_ops->ndo_setup_tc)
+		return -EOPNOTSUPP;
+
+	return dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_QDISC_RED, &opt);
+}
+
 static int red_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
@@ -219,6 +258,7 @@ static int red_change(struct Qdisc *sch, struct nlattr *opt)
 		red_start_of_idle_period(&q->vars);
 
 	sch_tree_unlock(sch);
+	red_offload(sch);
 	return 0;
 }
 
@@ -244,6 +284,32 @@ static int red_init(struct Qdisc *sch, struct nlattr *opt)
 	return red_change(sch, opt);
 }
 
+static int red_dump_offload(struct Qdisc *sch, struct tc_red_qopt *opt)
+{
+	struct net_device *dev = qdisc_dev(sch);
+	struct tc_red_qopt_offload hw_stats = {
+		.handle = sch->handle,
+		.parent = sch->parent,
+		.command = TC_RED_STATS,
+		.stats.bstats = &sch->bstats,
+		.stats.qstats = &sch->qstats,
+	};
+	int err;
+
+	if (!tc_can_offload(dev) || !dev->netdev_ops->ndo_setup_tc)
+		return 0;
+
+	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_QDISC_RED,
+					    &hw_stats);
+	if (err == -EOPNOTSUPP)
+		return 0;
+
+	if (!err)
+		opt->flags |= TC_RED_OFFLOADED;
+
+	return err;
+}
+
 static int red_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
@@ -257,8 +323,13 @@ static int red_dump(struct Qdisc *sch, struct sk_buff *skb)
 		.Plog		= q->parms.Plog,
 		.Scell_log	= q->parms.Scell_log,
 	};
+	int err;
 
 	sch->qstats.backlog = q->qdisc->qstats.backlog;
+	err = red_dump_offload(sch, &opt);
+	if (err)
+		goto nla_put_failure;
+
 	opts = nla_nest_start(skb, TCA_OPTIONS);
 	if (opts == NULL)
 		goto nla_put_failure;
@@ -275,6 +346,7 @@ static int red_dump(struct Qdisc *sch, struct sk_buff *skb)
 static int red_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
+	struct net_device *dev = qdisc_dev(sch);
 	struct tc_red_xstats st = {
 		.early	= q->stats.prob_drop + q->stats.forced_drop,
 		.pdrop	= q->stats.pdrop,
@@ -282,6 +354,24 @@ static int red_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
 		.marked	= q->stats.prob_mark + q->stats.forced_mark,
 	};
 
+	if (tc_can_offload(dev) &&  dev->netdev_ops->ndo_setup_tc) {
+		struct red_stats hw_stats = {0};
+		struct tc_red_qopt_offload hw_stats_request = {
+			.handle = sch->handle,
+			.parent = sch->parent,
+			.command = TC_RED_XSTATS,
+			.xstats = &hw_stats,
+		};
+		if (!dev->netdev_ops->ndo_setup_tc(dev,
+						   TC_SETUP_QDISC_RED,
+						   &hw_stats_request)) {
+			st.early += hw_stats.prob_drop + hw_stats.forced_drop;
+			st.pdrop += hw_stats.pdrop;
+			st.other += hw_stats.other;
+			st.marked += hw_stats.prob_mark + hw_stats.forced_mark;
+		}
+	}
+
 	return gnet_stats_copy_app(d, &st, sizeof(st));
 }
 
-- 
2.9.5
