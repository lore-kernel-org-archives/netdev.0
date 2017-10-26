From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/7] net/sched: Check for null dev_queue on create flow
Date: Thu, 26 Oct 2017 10:17:08 -0700
Message-ID: <20171026171714.45087-2-jeffrey.t.kirsher@intel.com>
References: <20171026171714.45087-1-jeffrey.t.kirsher@intel.com>
Cc: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:17534 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932127AbdJZRRi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 13:17:38 -0400
In-Reply-To: <20171026171714.45087-1-jeffrey.t.kirsher@intel.com>
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
Tested-by: Henrik Austad <henrik@austad.us>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 net/sched/sch_generic.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6ced7c89c141..aa74aa42b5d7 100644
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
