From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: [next-queue PATCH v5 1/5] net/sched: Check for null dev_queue on create flow
Date: Tue, 10 Oct 2017 17:43:56 -0700
Message-ID: <20171011004400.14946-2-vinicius.gomes@intel.com>
References: <20171011004400.14946-1-vinicius.gomes@intel.com>
Cc: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        andre.guedes@intel.com, ivan.briano@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us, levipearson@gmail.com, rodney.cummings@ni.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36484 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932625AbdJKAqL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 20:46:11 -0400
In-Reply-To: <20171011004400.14946-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>

In qdisc_alloc() the dev_queue pointer was used without any checks
being performed. If qdisc_create() gets a null dev_queue pointer, it
just passes it along to qdisc_alloc(), leading to a crash. That
happens if a root qdisc implements select_queue() and returns a null
dev_queue pointer for an "invalid handle", for example, or if the
dev_queue associated with the parent qdisc is null.

This patch is in preparation for the next in this series, where
select_queue() is being added to mqprio and as it may return a null
dev_queue.

Signed-off-by: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
---
 net/sched/sch_generic.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index a0a198768aad..de2408f1ccd3 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -603,8 +603,14 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	struct Qdisc *sch;
 	unsigned int size = QDISC_ALIGN(sizeof(*sch)) + ops->priv_size;
 	int err = -ENOBUFS;
-	struct net_device *dev = dev_queue->dev;
+	struct net_device *dev;
+
+	if (!dev_queue) {
+		err = -EINVAL;
+		goto errout;
+	}
 
+	dev = dev_queue->dev;
 	p = kzalloc_node(size, GFP_KERNEL,
 			 netdev_queue_numa_node_read(dev_queue));
 
-- 
2.14.2
