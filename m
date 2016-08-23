From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 05/15] net: sched: a dflt qdisc may be used with
 per cpu stats
Date: Tue, 23 Aug 2016 13:24:45 -0700
Message-ID: <20160823202445.14368.4352.stgit@john-Precision-Tower-5810>
References: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: eric.dumazet@gmail.com, jhs@mojatatu.com, davem@davemloft.net,
        brouer@redhat.com, xiyou.wangcong@gmail.com,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35872 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755657AbcHWUZM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 16:25:12 -0400
Received: by mail-pa0-f66.google.com with SMTP id ez1so10424126pab.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 13:25:12 -0700 (PDT)
In-Reply-To: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable dflt qdisc support for per cpu stats before this patch a
dflt qdisc was required to use the global statistics qstats and
bstats.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/sch_generic.c |   24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 80544c2..910b4d15 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -646,18 +646,34 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 	struct Qdisc *sch;
 
 	if (!try_module_get(ops->owner))
-		goto errout;
+		return NULL;
 
 	sch = qdisc_alloc(dev_queue, ops);
 	if (IS_ERR(sch))
-		goto errout;
+		return NULL;
 	sch->parent = parentid;
 
-	if (!ops->init || ops->init(sch, NULL) == 0)
+	if (!ops->init)
 		return sch;
 
-	qdisc_destroy(sch);
+	if (ops->init(sch, NULL))
+		goto errout;
+
+	/* init() may have set percpu flags so init data structures */
+	if (qdisc_is_percpu_stats(sch)) {
+		sch->cpu_bstats =
+			netdev_alloc_pcpu_stats(struct gnet_stats_basic_cpu);
+		if (!sch->cpu_bstats)
+			goto errout;
+
+		sch->cpu_qstats = alloc_percpu(struct gnet_stats_queue);
+		if (!sch->cpu_qstats)
+			goto errout;
+	}
+
+	return sch;
 errout:
+	qdisc_destroy(sch);
 	return NULL;
 }
 EXPORT_SYMBOL(qdisc_create_dflt);
