From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: [next-queue PATCH v5 4/5] net/sched: Add support for HW offloading for CBS
Date: Tue, 10 Oct 2017 17:43:59 -0700
Message-ID: <20171011004400.14946-5-vinicius.gomes@intel.com>
References: <20171011004400.14946-1-vinicius.gomes@intel.com>
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us, levipearson@gmail.com, rodney.cummings@ni.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:22284 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756713AbdJKApb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 20:45:31 -0400
In-Reply-To: <20171011004400.14946-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for offloading the CBS algorithm to the controller,
if supported.

Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
---
 net/sched/sch_cbs.c | 92 ++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 81 insertions(+), 11 deletions(-)

diff --git a/net/sched/sch_cbs.c b/net/sched/sch_cbs.c
index 5e1f72df1abd..2812bac4092b 100644
--- a/net/sched/sch_cbs.c
+++ b/net/sched/sch_cbs.c
@@ -69,6 +69,7 @@
 
 struct cbs_sched_data {
 	bool offload;
+	int queue;
 	s64 port_rate; /* in bytes/s */
 	s64 last; /* timestamp in ns */
 	s64 credits; /* in bytes */
@@ -81,6 +82,11 @@ struct cbs_sched_data {
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
@@ -179,6 +185,11 @@ static struct sk_buff *cbs_dequeue_soft(struct Qdisc *sch)
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
@@ -190,14 +201,37 @@ static const struct nla_policy cbs_policy[TCA_CBS_MAX + 1] = {
 	[TCA_CBS_PARMS]	= { .len = sizeof(struct tc_cbs_qopt) },
 };
 
+static void disable_cbs_offload(struct net_device *dev,
+				struct cbs_sched_data *q)
+{
+	struct tc_cbs_qopt_offload cbs = { };
+	const struct net_device_ops *ops;
+	int err;
+
+	if (!q->offload)
+		return;
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
 static int cbs_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct cbs_sched_data *q = qdisc_priv(sch);
 	struct net_device *dev = qdisc_dev(sch);
+	struct tc_cbs_qopt_offload cbs = { };
 	struct nlattr *tb[TCA_CBS_MAX + 1];
-	struct ethtool_link_ksettings ecmd;
+	const struct net_device_ops *ops;
 	struct tc_cbs_qopt *qopt;
-	s64 link_speed;
 	int err;
 
 	err = nla_parse_nested(tb, TCA_CBS_MAX, opt, cbs_policy, NULL);
@@ -209,18 +243,48 @@ static int cbs_change(struct Qdisc *sch, struct nlattr *opt)
 
 	qopt = nla_data(tb[TCA_CBS_PARMS]);
 
-	if (qopt->offload)
-		return -EOPNOTSUPP;
+	q->enqueue = cbs_enqueue_offload;
+	q->dequeue = cbs_dequeue_offload;
 
-	if (!__ethtool_get_link_ksettings(dev, &ecmd))
-		link_speed = ecmd.base.speed;
-	else
-		link_speed = SPEED_1000;
+	if (!qopt->offload) {
+		struct ethtool_link_ksettings ecmd;
+		s64 link_speed;
 
-	q->port_rate = link_speed * 1000 * BYTES_PER_KBIT;
+		if (!__ethtool_get_link_ksettings(dev, &ecmd))
+			link_speed = ecmd.base.speed;
+		else
+			link_speed = SPEED_1000;
 
-	q->enqueue = cbs_enqueue_soft;
-	q->dequeue = cbs_dequeue_soft;
+		q->port_rate = link_speed * 1000 * BYTES_PER_KBIT;
+
+		q->enqueue = cbs_enqueue_soft;
+		q->dequeue = cbs_dequeue_soft;
+
+		disable_cbs_offload(dev, q);
+
+		err = 0;
+		goto done;
+	}
+
+	cbs.queue = q->queue;
+
+	cbs.enable = 1;
+	cbs.hicredit = qopt->hicredit;
+	cbs.locredit = qopt->locredit;
+	cbs.idleslope = qopt->idleslope;
+	cbs.sendslope = qopt->sendslope;
+
+	ops = dev->netdev_ops;
+
+	err = -EOPNOTSUPP;
+	if (!ops->ndo_setup_tc)
+		goto done;
+
+	err = ops->ndo_setup_tc(dev, TC_SETUP_CBS, &cbs);
+
+done:
+	if (err < 0)
+		return err;
 
 	q->hicredit = qopt->hicredit;
 	q->locredit = qopt->locredit;
@@ -234,10 +298,13 @@ static int cbs_change(struct Qdisc *sch, struct nlattr *opt)
 static int cbs_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct cbs_sched_data *q = qdisc_priv(sch);
+	struct net_device *dev = qdisc_dev(sch);
 
 	if (!opt)
 		return -EINVAL;
 
+	q->queue = sch->dev_queue - netdev_get_tx_queue(dev, 0);
+
 	qdisc_watchdog_init(&q->watchdog, sch);
 
 	return cbs_change(sch, opt);
@@ -246,8 +313,11 @@ static int cbs_init(struct Qdisc *sch, struct nlattr *opt)
 static void cbs_destroy(struct Qdisc *sch)
 {
 	struct cbs_sched_data *q = qdisc_priv(sch);
+	struct net_device *dev = qdisc_dev(sch);
 
 	qdisc_watchdog_cancel(&q->watchdog);
+
+	disable_cbs_offload(dev, q);
 }
 
 static int cbs_dump(struct Qdisc *sch, struct sk_buff *skb)
-- 
2.14.2
