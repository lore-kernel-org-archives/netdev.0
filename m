From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH 13/13] net_sched: return NULL instead of ERR_PTR for qdisc_alloc()
Date: Tue,  4 Nov 2014 09:56:36 -0800
Message-ID: <1415123796-8093-14-git-send-email-xiyou.wangcong@gmail.com>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:62510 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117AbaKDR5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:57:00 -0500
Received: by mail-pa0-f51.google.com with SMTP id kq14so14992686pab.10
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:57:00 -0800 (PST)
In-Reply-To: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It always returns ENOFBUFS so we can return NULL
and let its callers set this errno.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_api.c     | 4 ++--
 net/sched/sch_generic.c | 5 ++---
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 38c42bd..27bfd75 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -905,8 +905,8 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 		goto err_out;
 
 	sch = qdisc_alloc(dev_queue, ops);
-	if (IS_ERR(sch)) {
-		err = PTR_ERR(sch);
+	if (!sch) {
+		err = -ENOBUFS;
 		goto err_out2;
 	}
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 29db9c8..b474fbb 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -585,7 +585,6 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	void *p;
 	struct Qdisc *sch;
 	unsigned int size = QDISC_ALIGN(sizeof(*sch)) + ops->priv_size;
-	int err = -ENOBUFS;
 	struct net_device *dev = dev_queue->dev;
 
 	p = kzalloc_node(size, GFP_KERNEL,
@@ -620,7 +619,7 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 
 	return sch;
 errout:
-	return ERR_PTR(err);
+	return NULL;
 }
 
 struct Qdisc *qdisc_create_internal(struct netdev_queue *dev_queue,
@@ -633,7 +632,7 @@ struct Qdisc *qdisc_create_internal(struct netdev_queue *dev_queue,
 		goto errout;
 
 	sch = qdisc_alloc(dev_queue, ops);
-	if (IS_ERR(sch))
+	if (!sch)
 		goto errout;
 	sch->parent = parentid;
 
-- 
1.8.3.1
