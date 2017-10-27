From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 3/6] net/sched: Add select_queue() class_ops for mqprio
Date: Fri, 27 Oct 2017 09:57:03 -0700
Message-ID: <20171027165706.85527-4-jeffrey.t.kirsher@intel.com>
References: <20171027165706.85527-1-jeffrey.t.kirsher@intel.com>
Cc: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48070 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752649AbdJ0Q5b (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Oct 2017 12:57:31 -0400
In-Reply-To: <20171027165706.85527-1-jeffrey.t.kirsher@intel.com>
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
Tested-by: Henrik Austad <henrik@austad.us>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 net/sched/sch_mqprio.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 51c2b289c69b..4d5ed45123f0 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -575,6 +575,12 @@ static void mqprio_walk(struct Qdisc *sch, struct qdisc_walker *arg)
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
@@ -582,6 +588,7 @@ static const struct Qdisc_class_ops mqprio_class_ops = {
 	.walk		= mqprio_walk,
 	.dump		= mqprio_dump_class,
 	.dump_stats	= mqprio_dump_class_stats,
+	.select_queue	= mqprio_select_queue,
 };
 
 static struct Qdisc_ops mqprio_qdisc_ops __read_mostly = {
-- 
2.14.2
