From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: [next-queue PATCH v9 3/6] net/sched: Add select_queue() class_ops for mqprio
Date: Mon, 16 Oct 2017 18:01:25 -0700
Message-ID: <20171017010128.22141-4-vinicius.gomes@intel.com>
References: <20171017010128.22141-1-vinicius.gomes@intel.com>
Cc: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        andre.guedes@intel.com, ivan.briano@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us, levipearson@gmail.com, rodney.cummings@ni.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20204 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753713AbdJQBBo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 21:01:44 -0400
In-Reply-To: <20171017010128.22141-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>

When replacing a child qdisc from mqprio, tc_modify_qdisc() must fetch
the netdev_queue pointer that the current child qdisc is associated
with before creating the new qdisc.

Currently, when using mqprio as root qdisc, the kernel will end up
getting the queue #0 pointer from the mqprio (root qdisc), which leaves
any new child qdisc with a possibly wrong netdev_queue pointer.

Implementing the Qdisc_class_ops select_queue() on mqprio fixes this
issue and avoid an inconsistent state when child qdiscs are replaced.

Signed-off-by: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
---
 net/sched/sch_mqprio.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 6bcdfe6e7b63..8c042ae323e3 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -396,6 +396,12 @@ static void mqprio_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 	}
 }
 
+static struct netdev_queue *mqprio_select_queue(struct Qdisc *sch,
+						struct tcmsg *tcm)
+{
+	return mqprio_queue_get(sch, TC_H_MIN(tcm->tcm_parent));
+}
+
 static const struct Qdisc_class_ops mqprio_class_ops = {
 	.graft		= mqprio_graft,
 	.leaf		= mqprio_leaf,
@@ -403,6 +409,7 @@ static const struct Qdisc_class_ops mqprio_class_ops = {
 	.walk		= mqprio_walk,
 	.dump		= mqprio_dump_class,
 	.dump_stats	= mqprio_dump_class_stats,
+	.select_queue	= mqprio_select_queue,
 };
 
 static struct Qdisc_ops mqprio_qdisc_ops __read_mostly = {
-- 
2.14.2
