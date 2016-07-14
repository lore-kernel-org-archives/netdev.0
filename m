From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 04/10] net: sched: a dflt qdisc may be used with per
 cpu stats
Date: Wed, 13 Jul 2016 23:21:18 -0700
Message-ID: <20160714062117.8270.16275.stgit@john-Precision-Tower-5810>
References: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de, jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35072 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbcGNGVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 02:21:41 -0400
Received: by mail-pf0-f195.google.com with SMTP id t190so4295679pfb.2
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 23:21:41 -0700 (PDT)
In-Reply-To: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
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
index 2c3e23b..fc70204 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -647,18 +647,34 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
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
