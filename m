From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/7] net/sched: Change behavior of mq select_queue()
Date: Thu, 26 Oct 2017 10:17:09 -0700
Message-ID: <20171026171714.45087-3-jeffrey.t.kirsher@intel.com>
References: <20171026171714.45087-1-jeffrey.t.kirsher@intel.com>
Cc: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:17534 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932328AbdJZRRh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 13:17:37 -0400
In-Reply-To: <20171026171714.45087-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>

Currently, the class_ops select_queue() implementation on sch_mq
returns a pointer to netdev_queue #0 when it receives and invalid
qdisc id. That can be misleading since all of mq's inner qdiscs are
attached to a valid netdev_queue.

Here we fix that by returning NULL when a qdisc id is invalid. This is
aligned with how select_queue() is implemented for sch_mqprio in the
next patch on this series, keeping a consistent behavior between these
two qdiscs.

Signed-off-by: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
Tested-by: Henrik Austad <henrik@austad.us>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 net/sched/sch_mq.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index f3a3e507422b..213b586a06a0 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -130,15 +130,7 @@ static struct netdev_queue *mq_queue_get(struct Qdisc *sch, unsigned long cl)
 static struct netdev_queue *mq_select_queue(struct Qdisc *sch,
 					    struct tcmsg *tcm)
 {
-	unsigned int ntx = TC_H_MIN(tcm->tcm_parent);
-	struct netdev_queue *dev_queue = mq_queue_get(sch, ntx);
-
-	if (!dev_queue) {
-		struct net_device *dev = qdisc_dev(sch);
-
-		return netdev_get_tx_queue(dev, 0);
-	}
-	return dev_queue;
+	return mq_queue_get(sch, TC_H_MIN(tcm->tcm_parent));
 }
 
 static int mq_graft(struct Qdisc *sch, unsigned long cl, struct Qdisc *new,
-- 
2.14.2
