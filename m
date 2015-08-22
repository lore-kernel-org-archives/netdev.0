From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH v2 2/3] net: sched: allocate a handle to default qdiscs
Date: Sat, 22 Aug 2015 02:20:55 +0200
Message-ID: <1440202856-1645-3-git-send-email-phil@nwl.cc>
References: <1440202856-1645-1-git-send-email-phil@nwl.cc>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, brouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:58247 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752028AbbHVAU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2015 20:20:58 -0400
In-Reply-To: <1440202856-1645-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since tc_get_qdisc() does not allow to remove a qdisc with zero handle,
a handle needs to be allocated to default qdiscs (currently pfifo_fast
or mq) in order to allow removing them.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 include/net/sch_generic.h |  1 +
 net/sched/sch_api.c       |  3 ++-
 net/sched/sch_generic.c   | 11 +++++++++++
 3 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 4495193..2bfc898 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -391,6 +391,7 @@ void dev_deactivate(struct net_device *dev);
 void dev_deactivate_many(struct list_head *head);
 struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
 			      struct Qdisc *qdisc);
+u32 qdisc_alloc_handle(struct net_device *dev);
 void qdisc_reset(struct Qdisc *qdisc);
 void qdisc_destroy(struct Qdisc *qdisc);
 void qdisc_tree_decrease_qlen(struct Qdisc *qdisc, unsigned int n);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index f06aa01..224374c 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -723,7 +723,7 @@ EXPORT_SYMBOL(qdisc_class_hash_remove);
 /* Allocate an unique handle from space managed by kernel
  * Possible range is [8000-FFFF]:0000 (0x8000 values)
  */
-static u32 qdisc_alloc_handle(struct net_device *dev)
+u32 qdisc_alloc_handle(struct net_device *dev)
 {
 	int i = 0x8000;
 	static u32 autohandle = TC_H_MAKE(0x80000000U, 0);
@@ -739,6 +739,7 @@ static u32 qdisc_alloc_handle(struct net_device *dev)
 
 	return 0;
 }
+EXPORT_SYMBOL(qdisc_alloc_handle);
 
 void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 {
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 1fb65f9..68df721 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -741,6 +741,11 @@ static void attach_one_default_qdisc(struct net_device *dev,
 			netdev_info(dev, "activation failed\n");
 			return;
 		}
+#ifdef CONFIG_NET_SCHED
+		qdisc->handle = qdisc_alloc_handle(dev);
+		if (!qdisc->handle)
+			netdev_info(dev, "qdisc handle allocation failed\n");
+#endif
 		if (!netif_is_multiqueue(dev))
 			qdisc->flags |= TCQ_F_ONETXQUEUE;
 	}
@@ -763,6 +768,12 @@ static void attach_default_qdiscs(struct net_device *dev)
 	} else {
 		qdisc = qdisc_create_dflt(txq, &mq_qdisc_ops, TC_H_ROOT);
 		if (qdisc) {
+#ifdef CONFIG_NET_SCHED
+			qdisc->handle = qdisc_alloc_handle(dev);
+			if (!qdisc->handle)
+				netdev_info(dev,
+				            "qdisc handle allocation failed\n");
+#endif
 			dev->qdisc = qdisc;
 			qdisc->ops->attach(qdisc);
 		}
-- 
2.1.2
