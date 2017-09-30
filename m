From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: [next-queue PATCH v2 4/5] net/sched: Introduce Credit Based Shaper (CBS) qdisc
Date: Fri, 29 Sep 2017 17:26:56 -0700
Message-ID: <20170930002657.15291-5-vinicius.gomes@intel.com>
References: <20170930002657.15291-1-vinicius.gomes@intel.com>
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us, levipearson@gmail.com, rodney.cummings@ni.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36897 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752597AbdI3A13 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 20:27:29 -0400
In-Reply-To: <20170930002657.15291-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This queueing discipline implements the shaper algorithm defined by
the 802.1Q-2014 Section 8.6.8.2 and detailed in Annex L.

It's primary usage is to apply some bandwidth reservation to user
defined traffic classes, which are mapped to different queues via the
mqprio qdisc.

Initially, it only supports offloading the traffic shaping work to
supporting controllers.

Later, when a software implementation is added, the current dependency
on being installed "under" mqprio can be lifted.

Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Signed-off-by: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
---
 include/linux/netdevice.h |   1 +
 include/net/pkt_sched.h   |   9 ++
 net/sched/Kconfig         |  11 +++
 net/sched/Makefile        |   1 +
 net/sched/sch_cbs.c       | 225 ++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 247 insertions(+)
 create mode 100644 net/sched/sch_cbs.c

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f535779d9dc1..5d6fb06fd80f 100644
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
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index e70ed26485a2..c03d86a7775e 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -172,6 +172,17 @@ config NET_SCH_TBF
 	  To compile this code as a module, choose M here: the
 	  module will be called sch_tbf.
 
+config NET_SCH_CBS
+	tristate "Credit Based Shaper (CBS)"
+	---help---
+	  Say Y here if you want to use the Credit Based Shaper (CBS) packet
+	  scheduling algorithm.
+
+	  See the top of <file:net/sched/sch_cbs.c> for more details.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called sch_cbs.
+
 config NET_SCH_GRED
 	tristate "Generic Random Early Detection (GRED)"
 	---help---
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 7b915d226de7..80c8f92d162d 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -52,6 +52,7 @@ obj-$(CONFIG_NET_SCH_FQ_CODEL)	+= sch_fq_codel.o
 obj-$(CONFIG_NET_SCH_FQ)	+= sch_fq.o
 obj-$(CONFIG_NET_SCH_HHF)	+= sch_hhf.o
 obj-$(CONFIG_NET_SCH_PIE)	+= sch_pie.o
+obj-$(CONFIG_NET_SCH_CBS)	+= sch_cbs.o
 
 obj-$(CONFIG_NET_CLS_U32)	+= cls_u32.o
 obj-$(CONFIG_NET_CLS_ROUTE4)	+= cls_route.o
diff --git a/net/sched/sch_cbs.c b/net/sched/sch_cbs.c
new file mode 100644
index 000000000000..3e0fb0b92160
--- /dev/null
+++ b/net/sched/sch_cbs.c
@@ -0,0 +1,225 @@
+/*
+ * net/sched/sch_cbs.c	Credit Based Shaper
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Vinicius Costa Gomes <vinicius.gomes@intel.com>
+ *
+ */
+
+/* Credit Based Shaper (CBS)
+   =========================
+
+   This is a simple rate-limiting shaper aimed at TSN applications on
+   systems with known traffic workloads.
+
+   Its algorithm is defined by the IEEE 802.1Q-2014 Specification,
+   Section 8.6.8.2, and explained in more detail in the Annex L of the
+   same specification.
+
+   There are four tunables to be considered:
+
+	'idleslope': Idleslope is the rate of credits that is
+	accumulated (in kilobits per second) when there is at least
+	one packet waiting for transmission. Packets are transmitted
+	when the current value of credits is equal or greater than
+	zero. When there is no packet to be transmitted the amount of
+	credits is set to zero. This is the main tunable of the CBS
+	algorithm.
+
+	'sendslope':
+	Sendslope is the rate of credits that is depleted (it should be a
+	negative number of kilobits per second) when a transmission is
+	ocurring. It can be calculated as follows, (IEEE 802.1Q-2014 Section
+	8.6.8.2 item g):
+
+	sendslope = idleslope - port_transmit_rate
+
+	'hicredit': Hicredit defines the maximum amount of credits (in
+	bytes) that can be accumulated. Hicredit depends on the
+	characteristics of interfering traffic,
+	'max_interference_size' is the maximum size of any burst of
+	traffic that can delay the transmission of a frame that is
+	available for transmission for this traffic class, (IEEE
+	802.1Q-2014 Annex L, Equation L-3):
+
+	hicredit = max_interference_size * (idleslope / port_transmit_rate)
+
+	'locredit': Locredit is the minimum amount of credits that can
+	be reached. It is a function of the traffic flowing through
+	this qdisc (IEEE 802.1Q-2014 Annex L, Equation L-2):
+
+	locredit = max_frame_size * (sendslope / port_transmit_rate)
+*/
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/skbuff.h>
+#include <net/netlink.h>
+#include <net/sch_generic.h>
+#include <net/pkt_sched.h>
+
+struct cbs_sched_data {
+	s32 queue;
+	s32 locredit;
+	s32 hicredit;
+	s32 sendslope;
+	s32 idleslope;
+};
+
+static int cbs_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+		       struct sk_buff **to_free)
+{
+	return qdisc_enqueue_tail(skb, sch);
+}
+
+static const struct nla_policy cbs_policy[TCA_CBS_MAX + 1] = {
+	[TCA_CBS_PARMS]	= { .len = sizeof(struct tc_cbs_qopt) },
+};
+
+static int cbs_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct cbs_sched_data *q = qdisc_priv(sch);
+	struct tc_cbs_qopt_offload cbs = { };
+	struct nlattr *tb[TCA_CBS_MAX + 1];
+	const struct net_device_ops *ops;
+	struct tc_cbs_qopt *qopt;
+	struct net_device *dev;
+	int err;
+
+	err = nla_parse_nested(tb, TCA_CBS_MAX, opt, cbs_policy, NULL);
+	if (err < 0)
+		return err;
+
+	err = -EINVAL;
+	if (!tb[TCA_CBS_PARMS])
+		goto done;
+
+	qopt = nla_data(tb[TCA_CBS_PARMS]);
+
+	dev = qdisc_dev(sch);
+	ops = dev->netdev_ops;
+
+	cbs.queue = q->queue;
+	cbs.enable = 1;
+	cbs.hicredit = qopt->hicredit;
+	cbs.locredit = qopt->locredit;
+	cbs.idleslope = qopt->idleslope;
+	cbs.sendslope = qopt->sendslope;
+
+	err = -EOPNOTSUPP;
+	if (!ops->ndo_setup_tc)
+		goto done;
+
+	err = ops->ndo_setup_tc(dev, TC_SETUP_CBS, &cbs);
+	if (err < 0)
+		goto done;
+
+	q->hicredit = cbs.hicredit;
+	q->locredit = cbs.locredit;
+	q->idleslope = cbs.idleslope;
+	q->sendslope = cbs.sendslope;
+
+done:
+	return err;
+}
+
+static int cbs_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct cbs_sched_data *q = qdisc_priv(sch);
+	struct net_device *dev = qdisc_dev(sch);
+
+	if (!opt)
+		return -EINVAL;
+
+	q->queue = sch->dev_queue - netdev_get_tx_queue(dev, 0);
+
+	return cbs_change(sch, opt);
+}
+
+static void cbs_destroy(struct Qdisc *sch)
+{
+	struct cbs_sched_data *q = qdisc_priv(sch);
+	struct tc_cbs_qopt_offload cbs = { };
+	const struct net_device_ops *ops;
+	struct net_device *dev;
+	int err;
+
+	q->hicredit = 0;
+	q->locredit = 0;
+	q->idleslope = 0;
+	q->sendslope = 0;
+
+	dev = qdisc_dev(sch);
+	ops = dev->netdev_ops;
+
+	if (!ops->ndo_setup_tc)
+		return;
+
+	cbs.queue = q->queue;
+	cbs.enable = 0;
+
+	err = ops->ndo_setup_tc(dev, TC_SETUP_CBS, &cbs);
+	if (err < 0)
+		pr_warn("Couldn't reset queue %d to default values\n",
+			cbs.queue);
+}
+
+static int cbs_dump(struct Qdisc *sch, struct sk_buff *skb)
+{
+	struct cbs_sched_data *q = qdisc_priv(sch);
+	struct nlattr *nest;
+	struct tc_cbs_qopt opt;
+
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (!nest)
+		goto nla_put_failure;
+
+	opt.hicredit = q->hicredit;
+	opt.locredit = q->locredit;
+	opt.sendslope = q->sendslope;
+	opt.idleslope = q->idleslope;
+
+	if (nla_put(skb, TCA_CBS_PARMS, sizeof(opt), &opt))
+		goto nla_put_failure;
+
+	return nla_nest_end(skb, nest);
+
+nla_put_failure:
+	nla_nest_cancel(skb, nest);
+	return -1;
+}
+
+static struct Qdisc_ops cbs_qdisc_ops __read_mostly = {
+	.next		=	NULL,
+	.id		=	"cbs",
+	.priv_size	=	sizeof(struct cbs_sched_data),
+	.enqueue	=	cbs_enqueue,
+	.dequeue	=	qdisc_dequeue_head,
+	.peek		=	qdisc_peek_dequeued,
+	.init		=	cbs_init,
+	.reset		=	qdisc_reset_queue,
+	.destroy	=	cbs_destroy,
+	.change		=	cbs_change,
+	.dump		=	cbs_dump,
+	.owner		=	THIS_MODULE,
+};
+
+static int __init cbs_module_init(void)
+{
+	return register_qdisc(&cbs_qdisc_ops);
+}
+
+static void __exit cbs_module_exit(void)
+{
+	unregister_qdisc(&cbs_qdisc_ops);
+}
+module_init(cbs_module_init)
+module_exit(cbs_module_exit)
+MODULE_LICENSE("GPL");
-- 
2.14.2
