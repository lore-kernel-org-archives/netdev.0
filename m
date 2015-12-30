From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 08/12] net: sched: a dflt qdisc may be used with per cpu
 stats
Date: Wed, 30 Dec 2015 09:53:58 -0800
Message-ID: <20151230175358.26257.12220.stgit@john-Precision-Tower-5810>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com
To: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36159 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754866AbbL3RyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:54:15 -0500
Received: by mail-pa0-f54.google.com with SMTP id yy13so48730459pab.3
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 09:54:14 -0800 (PST)
In-Reply-To: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
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
index 134fb95..be5d63a 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -641,18 +641,34 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
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
