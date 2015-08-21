From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH 2/3] net: sched: allocate a handle to default qdiscs
Date: Fri, 21 Aug 2015 17:58:07 +0200
Message-ID: <1440172688-2163-3-git-send-email-phil@nwl.cc>
References: <1440172688-2163-1-git-send-email-phil@nwl.cc>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, brouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:37015 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753881AbbHUP6K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2015 11:58:10 -0400
In-Reply-To: <1440172688-2163-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since tc_get_qdisc() does not allow to remove a qdisc with zero handle,
a handle needs to be allocated to default qdiscs (currently pfifo_fast
or mq) in order to allow removing them.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 include/net/sch_generic.h | 1 +
 net/sched/sch_api.c       | 3 ++-
 net/sched/sch_generic.c   | 5 +++++
 3 files changed, 8 insertions(+), 1 deletion(-)

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
index 1fb65f9..ab614ee 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -634,6 +634,11 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 	if (IS_ERR(sch))
 		goto errout;
 	sch->parent = parentid;
+#ifdef CONFIG_NET_SCHED
+	sch->handle = qdisc_alloc_handle(dev_queue->dev);
+	if (!sch->handle)
+		goto errout;
+#endif
 
 	if (!ops->init || ops->init(sch, NULL) == 0)
 		return sch;
-- 
2.1.2
