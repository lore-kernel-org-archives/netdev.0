From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: [next-queue PATCH v6 4/5] net/sched: Add support for HW offloading for CBS
Date: Wed, 11 Oct 2017 17:54:48 -0700
Message-ID: <20171012005449.26533-5-vinicius.gomes@intel.com>
References: <20171012005449.26533-1-vinicius.gomes@intel.com>
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us, levipearson@gmail.com, rodney.cummings@ni.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57397 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752807AbdJLA6b (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Oct 2017 20:58:31 -0400
In-Reply-To: <20171012005449.26533-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for offloading the CBS algorithm to the controller,
if supported. Drivers wanting to support CBS offload must implement
the .ndo_setup_tc callback and handle the TC_SETUP_CBS (introduced
here) type.

Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
---
 include/linux/netdevice.h |   1 +
 include/net/pkt_sched.h   |   9 ++++
 net/sched/sch_cbs.c       | 104 ++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 102 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 31bb3010c69b..1f6c44ef5b21 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -775,6 +775,7 @@ enum tc_setup_type {
 	TC_SETUP_CLSFLOWER,
 	TC_SETUP_CLSMATCHALL,
 	TC_SETUP_CLSBPF,
+	TC_SETUP_CBS,
 };
 
 /* These structures hold the attributes of xdp state that are being passed
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 259bc191ba59..7c597b050b36 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -146,4 +146,13 @@ static inline bool is_classid_clsact_egress(u32 classid)
 	       TC_H_MIN(classid) == TC_H_MIN(TC_H_MIN_EGRESS);
 }
 
+struct tc_cbs_qopt_offload {
+	u8 enable;
+	s32 queue;
+	s32 hicredit;
+	s32 locredit;
+	s32 idleslope;
+	s32 sendslope;
+};
+
 #endif
diff --git a/net/sched/sch_cbs.c b/net/sched/sch_cbs.c
index 29de3e2bc33f..610a72529b72 100644
--- a/net/sched/sch_cbs.c
+++ b/net/sched/sch_cbs.c
@@ -68,6 +68,8 @@
 #define BYTES_PER_KBIT (1000 / 8)
 
 struct cbs_sched_data {
+	bool offload;
+	int queue;
 	s64 port_rate; /* in bytes/s */
 	s64 last; /* timestamp in ns */
 	s64 credits; /* in bytes */
@@ -80,6 +82,11 @@ struct cbs_sched_data {
 	struct sk_buff *(*dequeue)(struct Qdisc *sch);
 };
 
+static int cbs_enqueue_offload(struct sk_buff *skb, struct Qdisc *sch)
+{
+	return qdisc_enqueue_tail(skb, sch);
+}
+
 static int cbs_enqueue_soft(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct cbs_sched_data *q = qdisc_priv(sch);
@@ -178,6 +185,11 @@ static struct sk_buff *cbs_dequeue_soft(struct Qdisc *sch)
 	return skb;
 }
 
+static struct sk_buff *cbs_dequeue_offload(struct Qdisc *sch)
+{
+	return qdisc_dequeue_head(sch);
+}
+
 static struct sk_buff *cbs_dequeue(struct Qdisc *sch)
 {
 	struct cbs_sched_data *q = qdisc_priv(sch);
@@ -189,14 +201,66 @@ static const struct nla_policy cbs_policy[TCA_CBS_MAX + 1] = {
 	[TCA_CBS_PARMS]	= { .len = sizeof(struct tc_cbs_qopt) },
 };
 
+static void cbs_disable_offload(struct net_device *dev,
+				struct cbs_sched_data *q)
+{
+	struct tc_cbs_qopt_offload cbs = { };
+	const struct net_device_ops *ops;
+	int err;
+
+	if (!q->offload)
+		return;
+
+	q->enqueue = cbs_enqueue_soft;
+	q->dequeue = cbs_dequeue_soft;
+
+	ops = dev->netdev_ops;
+	if (!ops->ndo_setup_tc)
+		return;
+
+	cbs.queue = q->queue;
+	cbs.enable = 0;
+
+	err = ops->ndo_setup_tc(dev, TC_SETUP_CBS, &cbs);
+	if (err < 0)
+		pr_warn("Couldn't disable CBS offload for queue %d\n",
+			cbs.queue);
+}
+
+static int cbs_enable_offload(struct net_device *dev, struct cbs_sched_data *q,
+			      const struct tc_cbs_qopt *opt)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	struct tc_cbs_qopt_offload cbs = { };
+	int err;
+
+	if (!ops->ndo_setup_tc)
+		return -EOPNOTSUPP;
+
+	cbs.queue = q->queue;
+
+	cbs.enable = 1;
+	cbs.hicredit = opt->hicredit;
+	cbs.locredit = opt->locredit;
+	cbs.idleslope = opt->idleslope;
+	cbs.sendslope = opt->sendslope;
+
+	err = ops->ndo_setup_tc(dev, TC_SETUP_CBS, &cbs);
+	if (err < 0)
+		return err;
+
+	q->enqueue = cbs_enqueue_offload;
+	q->dequeue = cbs_dequeue_offload;
+
+	return 0;
+}
+
 static int cbs_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct cbs_sched_data *q = qdisc_priv(sch);
 	struct net_device *dev = qdisc_dev(sch);
 	struct nlattr *tb[TCA_CBS_MAX + 1];
-	struct ethtool_link_ksettings ecmd;
 	struct tc_cbs_qopt *qopt;
-	s64 link_speed;
 	int err;
 
 	err = nla_parse_nested(tb, TCA_CBS_MAX, opt, cbs_policy, NULL);
@@ -208,23 +272,30 @@ static int cbs_change(struct Qdisc *sch, struct nlattr *opt)
 
 	qopt = nla_data(tb[TCA_CBS_PARMS]);
 
-	if (qopt->offload)
-		return -EOPNOTSUPP;
+	if (!qopt->offload) {
+		struct ethtool_link_ksettings ecmd;
+		s64 link_speed;
 
-	if (!__ethtool_get_link_ksettings(dev, &ecmd))
-		link_speed = ecmd.base.speed;
-	else
-		link_speed = SPEED_1000;
+		if (!__ethtool_get_link_ksettings(dev, &ecmd))
+			link_speed = ecmd.base.speed;
+		else
+			link_speed = SPEED_1000;
 
-	q->port_rate = link_speed * 1000 * BYTES_PER_KBIT;
+		q->port_rate = link_speed * 1000 * BYTES_PER_KBIT;
 
-	q->enqueue = cbs_enqueue_soft;
-	q->dequeue = cbs_dequeue_soft;
+		cbs_disable_offload(dev, q);
+	} else {
+		err = cbs_enable_offload(dev, q, qopt);
+		if (err < 0)
+			return err;
+	}
 
+	/* Everything went OK, save the parameters used. */
 	q->hicredit = qopt->hicredit;
 	q->locredit = qopt->locredit;
 	q->idleslope = qopt->idleslope;
 	q->sendslope = qopt->sendslope;
+	q->offload = qopt->offload;
 
 	return 0;
 }
@@ -232,10 +303,16 @@ static int cbs_change(struct Qdisc *sch, struct nlattr *opt)
 static int cbs_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct cbs_sched_data *q = qdisc_priv(sch);
+	struct net_device *dev = qdisc_dev(sch);
 
 	if (!opt)
 		return -EINVAL;
 
+	q->queue = sch->dev_queue - netdev_get_tx_queue(dev, 0);
+
+	q->enqueue = cbs_enqueue_soft;
+	q->dequeue = cbs_dequeue_soft;
+
 	qdisc_watchdog_init(&q->watchdog, sch);
 
 	return cbs_change(sch, opt);
@@ -244,8 +321,11 @@ static int cbs_init(struct Qdisc *sch, struct nlattr *opt)
 static void cbs_destroy(struct Qdisc *sch)
 {
 	struct cbs_sched_data *q = qdisc_priv(sch);
+	struct net_device *dev = qdisc_dev(sch);
 
 	qdisc_watchdog_cancel(&q->watchdog);
+
+	cbs_disable_offload(dev, q);
 }
 
 static int cbs_dump(struct Qdisc *sch, struct sk_buff *skb)
@@ -262,7 +342,7 @@ static int cbs_dump(struct Qdisc *sch, struct sk_buff *skb)
 	opt.locredit = q->locredit;
 	opt.sendslope = q->sendslope;
 	opt.idleslope = q->idleslope;
-	opt.offload = 0;
+	opt.offload = q->offload;
 
 	if (nla_put(skb, TCA_CBS_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
-- 
2.14.2
