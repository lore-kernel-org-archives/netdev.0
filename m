From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 05/17] net: sched: a dflt qdisc may be used with per
 cpu stats
Date: Tue, 02 May 2017 08:37:39 -0700
Message-ID: <20170502153739.9304.36714.stgit@john-Precision-Tower-5810>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33513 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750770AbdEBPhy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:37:54 -0400
Received: by mail-pg0-f68.google.com with SMTP id s62so11382798pgc.0
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:37:54 -0700 (PDT)
In-Reply-To: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable dflt qdisc support for per cpu stats before this patch a dflt
qdisc was required to use the global statistics qstats and bstats.

This adds a static flags field to qdisc_ops that is propagated
into qdisc->flags in qdisc allocate call. This allows the allocation
block to completely allocate the qdisc object so we don't have
dangling allocations after qdisc init.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |    1 +
 net/sched/sch_generic.c   |   16 ++++++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 9531b81..83952af 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -172,6 +172,7 @@ struct Qdisc_ops {
 	const struct Qdisc_class_ops	*cl_ops;
 	char			id[IFNAMSIZ];
 	int			priv_size;
+	unsigned int		static_flags;
 
 	int 			(*enqueue)(struct sk_buff *skb,
 					   struct Qdisc *sch,
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 2f66b1f..8a03738 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -625,6 +625,19 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	qdisc_skb_head_init(&sch->q);
 	spin_lock_init(&sch->q.lock);
 
+	if (ops->static_flags & TCQ_F_CPUSTATS) {
+		sch->cpu_bstats =
+			netdev_alloc_pcpu_stats(struct gnet_stats_basic_cpu);
+		if (!sch->cpu_bstats)
+			goto errout1;
+
+		sch->cpu_qstats = alloc_percpu(struct gnet_stats_queue);
+		if (!sch->cpu_qstats) {
+			free_percpu(sch->cpu_bstats);
+			goto errout1;
+		}
+	}
+
 	spin_lock_init(&sch->busylock);
 	lockdep_set_class(&sch->busylock,
 			  dev->qdisc_tx_busylock ?: &qdisc_tx_busylock);
@@ -634,6 +647,7 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 			  dev->qdisc_running_key ?: &qdisc_running_key);
 
 	sch->ops = ops;
+	sch->flags = ops->static_flags;
 	sch->enqueue = ops->enqueue;
 	sch->dequeue = ops->dequeue;
 	sch->dev_queue = dev_queue;
@@ -641,6 +655,8 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	atomic_set(&sch->refcnt, 1);
 
 	return sch;
+errout1:
+	kfree(p);
 errout:
 	return ERR_PTR(err);
 }
