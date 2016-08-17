From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 05/13] net: sched: a dflt qdisc may be used with per cpu
 stats
Date: Wed, 17 Aug 2016 12:35:25 -0700
Message-ID: <20160817193525.27032.68226.stgit@john-Precision-Tower-5810>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36548 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937AbcHQTfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 15:35:45 -0400
Received: by mail-oi0-f66.google.com with SMTP id b22so12990159oii.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 12:35:45 -0700 (PDT)
In-Reply-To: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
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
index af32418..f8fec81 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -645,18 +645,34 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
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
